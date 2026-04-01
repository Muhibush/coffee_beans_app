package extractor

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/coffee-beans-app/scraper/internal/model"
)

// GenericExtractor is the fallback extractor for custom roastery websites.
// It uses OpenGraph meta tags and Schema.org JSON-LD for data extraction.
type GenericExtractor struct{}

func (e *GenericExtractor) Name() string { return "generic" }

// CanHandle always returns true — it's the fallback extractor.
func (e *GenericExtractor) CanHandle(productURL string) bool {
	return true
}

func (e *GenericExtractor) Extract(ctx context.Context, productURL string) (*model.RawProduct, error) {
	log.Printf("[generic] Extracting from: %s", productURL)

	// Simple HTTP fetch (no browser needed for generic sites)
	client := &http.Client{
		Timeout: 15 * time.Second,
		// Follow redirects
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			if len(via) >= 10 {
				return fmt.Errorf("too many redirects")
			}
			return nil
		},
	}

	req, err := http.NewRequestWithContext(ctx, "GET", productURL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
	req.Header.Set("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch page: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("page returned status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	doc, err := goquery.NewDocumentFromReader(strings.NewReader(string(body)))
	if err != nil {
		return nil, fmt.Errorf("failed to parse HTML: %w", err)
	}

	raw := &model.RawProduct{
		Currency: "IDR",
	}

	// Strategy 1: Try Schema.org JSON-LD
	e.extractJSONLD(doc, raw)

	// Strategy 2: OpenGraph meta tags (fill in any gaps)
	e.extractOpenGraph(doc, raw)

	// Strategy 3: Standard HTML fallback
	if raw.Title == "" {
		e.extractHTML(doc, raw)
	}

	if raw.Title == "" {
		return nil, fmt.Errorf("could not extract product title from page")
	}

	log.Printf("[generic] Extracted: %s", raw.Title)
	return raw, nil
}

func (e *GenericExtractor) extractJSONLD(doc *goquery.Document, raw *model.RawProduct) {
	doc.Find(`script[type="application/ld+json"]`).Each(func(i int, s *goquery.Selection) {
		content := strings.TrimSpace(s.Text())
		if content == "" {
			return
		}

		// Try to parse as Product
		var product jsonLDProduct
		if err := json.Unmarshal([]byte(content), &product); err == nil && product.Type == "Product" {
			if product.Name != "" {
				raw.Title = product.Name
			}
			if product.Description != "" {
				raw.Description = product.Description
			}
			raw.ImageURLs = append(raw.ImageURLs, parseJSONLDImage(product.Image)...)

			if product.Offers != nil {
				price := parseJSONLDPrice(product.Offers.Price)
				if price == 0 {
					price = parseJSONLDPrice(product.Offers.LowPrice)
				}
				if price > 0 {
					raw.Price = price
				}
				if product.Offers.PriceCurrency != "" {
					raw.Currency = product.Offers.PriceCurrency
				}
			}
			return
		}

		// Try @graph structure
		var graphContainer struct {
			Graph []json.RawMessage `json:"@graph"`
		}
		if err := json.Unmarshal([]byte(content), &graphContainer); err == nil {
			for _, item := range graphContainer.Graph {
				var candidate jsonLDProduct
				if err := json.Unmarshal(item, &candidate); err == nil && candidate.Type == "Product" {
					if candidate.Name != "" {
						raw.Title = candidate.Name
					}
					if candidate.Description != "" {
						raw.Description = candidate.Description
					}
					raw.ImageURLs = append(raw.ImageURLs, parseJSONLDImage(candidate.Image)...)

					if candidate.Offers != nil {
						price := parseJSONLDPrice(candidate.Offers.Price)
						if price > 0 {
							raw.Price = price
						}
					}
				}
			}
		}
	})
}

func (e *GenericExtractor) extractOpenGraph(doc *goquery.Document, raw *model.RawProduct) {
	if raw.Title == "" {
		if content, exists := doc.Find(`meta[property="og:title"]`).Attr("content"); exists {
			raw.Title = content
		}
	}

	if raw.Description == "" {
		if content, exists := doc.Find(`meta[property="og:description"]`).Attr("content"); exists {
			raw.Description = content
		}
	}

	if len(raw.ImageURLs) == 0 {
		if content, exists := doc.Find(`meta[property="og:image"]`).Attr("content"); exists && content != "" {
			raw.ImageURLs = append(raw.ImageURLs, content)
		}
	}

	// Try price from meta tags
	if raw.Price == 0 {
		if content, exists := doc.Find(`meta[property="product:price:amount"]`).Attr("content"); exists {
			raw.Price = parsePriceString(content)
		}
	}
}

func (e *GenericExtractor) extractHTML(doc *goquery.Document, raw *model.RawProduct) {
	// Try common product title selectors
	titleSelectors := []string{
		"h1.product-title",
		"h1.product-name",
		"h1.product_title",
		".product-title h1",
		"h1",
	}

	for _, sel := range titleSelectors {
		title := strings.TrimSpace(doc.Find(sel).First().Text())
		if title != "" {
			raw.Title = title
			break
		}
	}

	// Try common price selectors
	priceSelectors := []string{
		".product-price",
		".price",
		"[class*='price']",
		".product_price",
	}

	for _, sel := range priceSelectors {
		price := strings.TrimSpace(doc.Find(sel).First().Text())
		if price != "" {
			raw.Price = parsePriceString(price)
			break
		}
	}

	// Try common image selectors
	if len(raw.ImageURLs) == 0 {
		imgSelectors := []string{
			".product-image img",
			".product-photo img",
			".product-featured-image",
			"[class*='product'] img",
		}

		for _, sel := range imgSelectors {
			if src, exists := doc.Find(sel).First().Attr("src"); exists && src != "" {
				raw.ImageURLs = append(raw.ImageURLs, src)
				break
			}
		}
	}

	// Description
	if raw.Description == "" {
		descSelectors := []string{
			".product-description",
			".product-details",
			"[class*='description']",
		}
		for _, sel := range descSelectors {
			desc := strings.TrimSpace(doc.Find(sel).First().Text())
			if desc != "" {
				raw.Description = desc
				break
			}
		}
	}
}

package extractor

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/go-rod/rod"

	"github.com/coffee-beans-app/scraper/internal/browser"
	"github.com/coffee-beans-app/scraper/internal/model"
)

// TokopediaExtractor handles product extraction from Tokopedia.
type TokopediaExtractor struct{}

func (e *TokopediaExtractor) Name() string { return "tokopedia" }

func (e *TokopediaExtractor) CanHandle(productURL string) bool {
	return strings.Contains(productURL, "tokopedia.com") ||
		strings.Contains(productURL, "tk.tokopedia.com")
}

func (e *TokopediaExtractor) Extract(ctx context.Context, productURL string) (*model.RawProduct, error) {
	log.Printf("[tokopedia] Extracting from: %s", productURL)

	b := browser.Get()
	page, err := b.NavigateWithStealth(ctx, productURL)
	if err != nil {
		return nil, fmt.Errorf("failed to navigate: %w", err)
	}
	defer page.MustClose()

	// Wait extra for Tokopedia's JS to render — it's heavy
	time.Sleep(3 * time.Second)

	// Get the final URL after redirects (handles tk.tokopedia.com short links)
	finalURL := page.MustInfo().URL
	log.Printf("[tokopedia] Final URL: %s", finalURL)

	// Strategy 1: Try JSON-LD first (most reliable structured data)
	raw, err := e.extractFromJSONLD(page)
	if err == nil && raw.Title != "" {
		log.Printf("[tokopedia] Extracted via JSON-LD: %s", raw.Title)
		raw.SourceURL = finalURL
		return raw, nil
	}
	log.Printf("[tokopedia] JSON-LD extraction failed or empty, falling back to DOM: %v", err)

	// Strategy 2: Fall back to DOM parsing
	raw, err = e.extractFromDOM(page)
	if err != nil {
		return nil, fmt.Errorf("both JSON-LD and DOM extraction failed: %w", err)
	}

	raw.SourceURL = finalURL
	return raw, nil
}

// jsonLDProduct represents the Schema.org Product structure from JSON-LD.
type jsonLDProduct struct {
	Type        string        `json:"@type"`
	Name        string        `json:"name"`
	Description string        `json:"description"`
	Image       interface{}   `json:"image"` // can be string or []string
	Offers      *jsonLDOffers `json:"offers"`
}

type jsonLDOffers struct {
	Type          string `json:"@type"`
	Price         interface{} `json:"price"` // can be string or number
	PriceCurrency string `json:"priceCurrency"`
	LowPrice      interface{} `json:"lowPrice"`
	HighPrice     interface{} `json:"highPrice"`
}

func (e *TokopediaExtractor) extractFromJSONLD(page *rod.Page) (*model.RawProduct, error) {
	// Execute JS to find and return JSON-LD content
	result := page.MustEval(`() => {
		const scripts = document.querySelectorAll('script[type="application/ld+json"]');
		const results = [];
		scripts.forEach(s => {
			try {
				const data = JSON.parse(s.textContent);
				if (data['@type'] === 'Product' || (Array.isArray(data['@graph']) && data['@graph'].some(g => g['@type'] === 'Product'))) {
					results.push(s.textContent);
				}
			} catch(e) {}
		});
		return results.length > 0 ? results[0] : '';
	}`).Str()

	if result == "" {
		return nil, fmt.Errorf("no Product JSON-LD found")
	}

	// Try parsing as direct Product
	var product jsonLDProduct
	if err := json.Unmarshal([]byte(result), &product); err != nil {
		// Try parsing as @graph container
		var graphContainer struct {
			Graph []json.RawMessage `json:"@graph"`
		}
		if err2 := json.Unmarshal([]byte(result), &graphContainer); err2 != nil {
			return nil, fmt.Errorf("failed to parse JSON-LD: %w", err)
		}
		for _, item := range graphContainer.Graph {
			var candidate jsonLDProduct
			if err := json.Unmarshal(item, &candidate); err == nil && candidate.Type == "Product" {
				product = candidate
				break
			}
		}
	}

	if product.Name == "" {
		return nil, fmt.Errorf("JSON-LD Product has no name")
	}

	raw := &model.RawProduct{
		Title:       product.Name,
		Description: product.Description,
		ImageURLs:   parseJSONLDImage(product.Image),
		Currency:    "IDR",
	}

	// Parse price from offers
	if product.Offers != nil {
		raw.Price = parseJSONLDPrice(product.Offers.Price)
		if raw.Price == 0 {
			raw.Price = parseJSONLDPrice(product.Offers.LowPrice)
		}
		if product.Offers.PriceCurrency != "" {
			raw.Currency = product.Offers.PriceCurrency
		}
	}

	return raw, nil
}

func (e *TokopediaExtractor) extractFromDOM(page *rod.Page) (*model.RawProduct, error) {
	// Extract using DOM selectors
	result := page.MustEval(`() => {
		const getTextBySelector = (sel) => {
			const el = document.querySelector(sel);
			return el ? el.textContent.trim() : '';
		};

		const getAttrBySelector = (sel, attr) => {
			const el = document.querySelector(sel);
			return el ? el.getAttribute(attr) || '' : '';
		};

		// Title — try multiple selectors
		let title = getTextBySelector('h1[data-testid="lblPDPDetailProductName"]') ||
			getTextBySelector('h1.css-1320e5d') ||
			getTextBySelector('h1') ||
			getAttrBySelector('meta[property="og:title"]', 'content');

		// Price
		let price = getTextBySelector('[data-testid="lblPDPDetailProductPrice"]') ||
			getTextBySelector('.price') ||
			'';

		// Image
		let image = getAttrBySelector('[data-testid="PDPImageMain"] img', 'src') ||
			getAttrBySelector('.css-1c345mg img', 'src') ||
			getAttrBySelector('meta[property="og:image"]', 'content') ||
			'';

		// Description
		let desc = getTextBySelector('[data-testid="lblPDPDescriptionProduk"]') ||
			getAttrBySelector('meta[property="og:description"]', 'content') ||
			'';

		// Variants (weight/grind options)
		let variants = [];
		const variantElements = document.querySelectorAll('[data-testid^="btnPDPVariant"]');
		variantElements.forEach(el => {
			variants.push({
				name: el.textContent.trim(),
				price: 0
			});
		});

		return JSON.stringify({
			title: title,
			price: price,
			image: image,
			description: desc,
			variants: variants
		});
	}`).Str()

	var domData struct {
		Title       string `json:"title"`
		Price       string `json:"price"`
		Image       string `json:"image"`
		Description string `json:"description"`
		Variants    []struct {
			Name  string `json:"name"`
			Price int64  `json:"price"`
		} `json:"variants"`
	}

	if err := json.Unmarshal([]byte(result), &domData); err != nil {
		return nil, fmt.Errorf("failed to parse DOM data: %w", err)
	}

	if domData.Title == "" {
		return nil, fmt.Errorf("could not extract title from DOM")
	}

	raw := &model.RawProduct{
		Title:       domData.Title,
		Description: domData.Description,
		Price:       parsePriceString(domData.Price),
		Currency:    "IDR",
	}

	if domData.Image != "" {
		raw.ImageURLs = []string{domData.Image}
	}

	for _, v := range domData.Variants {
		raw.Variants = append(raw.Variants, model.RawVariant{
			Name:  v.Name,
			Price: v.Price,
		})
	}

	return raw, nil
}

package extractor

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/url"
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

func (e *TokopediaExtractor) CanHandleBulk(storeURL string) bool {
	return e.CanHandle(storeURL)
}

func (e *TokopediaExtractor) ExtractURLs(ctx context.Context, storeURL string, maxProducts int) ([]model.BulkProduct, error) {
	log.Printf("[tokopedia] Extracting bulk URLs from: %s", storeURL)

	b := browser.Get()
	page, err := b.NavigateWithStealth(ctx, storeURL)
	if err != nil {
		return nil, fmt.Errorf("failed to navigate: %w", err)
	}
	defer page.MustClose()

	// Wait extra for Tokopedia's JS to render
	time.Sleep(5 * time.Second)

	// Determine username/shop name from URL to filter out other links
	parsed, err := url.Parse(storeURL)
	if err != nil {
		return nil, fmt.Errorf("invalid URL: %w", err)
	}
	parts := strings.Split(strings.Trim(parsed.Path, "/"), "/")
	var username string
	if len(parts) > 0 {
		username = parts[0]
	}

	productsMap := make(map[string]bool)
	var products []model.BulkProduct

	// Normalize shop name for filtering
	shopPattern := "/" + username + "/"

	// Infinite scroll logic
	scrollWait := 2 * time.Second
	for i := 0; i < 10; i++ { // limit scroll attempts
		// Execute JS to get links and titles
		results, err := page.Eval(fmt.Sprintf(`() => {
			const arr = [];
			// Find all anchors that likely point to products in this shop
			const links = document.querySelectorAll('a[href*="%s"]');
			
			links.forEach(a => {
				const href = a.href;
				if (!href || href.includes('/review') || href.includes('/etalase') || href.endsWith('/product')) return;

				// Try to find a title within the anchor or nearby
				// data-testid="linkProductName" is the most specific for Tokopedia
				const titleEl = a.querySelector('[data-testid="linkProductName"], .prd_link-product-name') || a;
				const title = titleEl.innerText.trim();
				
				// Products usually have multi-word titles and a certain length
				if (title.length > 5 && title.split(' ').length >= 2) {
					arr.push({ url: href, title: title });
				}
			});
			return arr;
		}`, shopPattern))
		if err != nil {
			log.Printf("[tokopedia] JS evaluate failed during bulk scrape: %v", err)
			break
		}
		
		type jsResult struct {
			URL   string `json:"url"`
			Title string `json:"title"`
		}
		var items []jsResult
		results.Value.Unmarshal(&items)

		prevLen := len(productsMap)
		
		for _, item := range items {
			href := item.URL
			// Strip query params and fragments
			if u, err := url.Parse(href); err == nil {
				u.RawQuery = ""
				u.Fragment = ""
				href = u.String()
			}

			// Final sanity check on the URL
			if !productsMap[href] {
				productsMap[href] = true
				products = append(products, model.BulkProduct{
					Title: item.Title,
					URL:   href,
				})
			}
		}

		if maxProducts > 0 && len(products) >= maxProducts {
			break
		}

		// Check if we didn't find any new links
		if len(productsMap) == prevLen && i > 0 {
			break
		}

		// Scroll down
		page.MustEval(`() => window.scrollBy(0, 1000)`)
		time.Sleep(scrollWait)
	}

	if maxProducts > 0 && len(products) > maxProducts {
		products = products[:maxProducts]
	}

	log.Printf("[tokopedia] Extracted %d product items successfully", len(products))
	return products, nil
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

	// Strategy 1: JSON-LD for base metadata
	raw, err := e.extractFromJSONLD(page)
	if err != nil || raw == nil || raw.Title == "" {
		log.Printf("[tokopedia] JSON-LD extraction failed or empty, using empty base: %v", err)
		raw = &model.RawProduct{}
	} else {
		log.Printf("[tokopedia] Base metadata extracted via JSON-LD: %s", raw.Title)
	}

	// Strategy 2: DOM for variants and potential gaps
	domData, err := e.extractFromDOM(page)
	if err != nil {
		if raw.Title == "" {
			return nil, fmt.Errorf("extraction failed: JSON-LD failed and DOM failed: %w", err)
		}
		log.Printf("[tokopedia] DOM extraction failed, but using JSON-LD data: %v", err)
	} else {
		// Merge DOM data into JSON-LD data if JSON-LD missed anything
		if raw.Title == "" {
			raw.Title = domData.Title
		}
		if raw.Description == "" {
			raw.Description = domData.Description
		}
		if raw.Price == 0 {
			raw.Price = domData.Price
		}
		if len(raw.ImageURLs) == 0 && len(domData.ImageURLs) > 0 {
			raw.ImageURLs = domData.ImageURLs
		}
		// ALWAYS take variants from DOM if available
		if len(domData.Variants) > 0 {
			raw.Variants = domData.Variants
		}
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

		// Title
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
		// Tokopedia uses multiple structures for variants. 
		// btnPDPVariant is common for buttons. 
		// We also check for dropdown values if needed, but buttons are primary for specialty coffee.
		let variants = [];
		const variantElements = document.querySelectorAll('[data-testid^="btnPDPVariant"]');
		variantElements.forEach(el => {
			const text = el.textContent.trim();
			if (text) {
				variants.push({
					name: text,
					price: 0
				});
			}
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

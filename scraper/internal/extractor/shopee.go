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

// ShopeeExtractor handles product extraction from Shopee Indonesia.
type ShopeeExtractor struct{}

func (e *ShopeeExtractor) Name() string { return "shopee" }

func (e *ShopeeExtractor) CanHandle(productURL string) bool {
	return strings.Contains(productURL, "shopee.co.id")
}

func (e *ShopeeExtractor) Extract(ctx context.Context, productURL string) (*model.RawProduct, error) {
	log.Printf("[shopee] Extracting from: %s", productURL)

	b := browser.Get()
	page, err := b.NavigateWithStealth(ctx, productURL)
	if err != nil {
		return nil, fmt.Errorf("failed to navigate: %w", err)
	}
	defer page.MustClose()

	// Shopee loads content heavily via JS — extra wait
	time.Sleep(4 * time.Second)

	// Strategy 1: Try JSON-LD
	raw, err := e.extractFromJSONLD(page)
	if err == nil && raw.Title != "" {
		log.Printf("[shopee] Extracted via JSON-LD: %s", raw.Title)
		return raw, nil
	}
	log.Printf("[shopee] JSON-LD extraction failed, falling back to DOM: %v", err)

	// Strategy 2: DOM parsing
	raw, err = e.extractFromDOM(page)
	if err != nil {
		return nil, fmt.Errorf("both JSON-LD and DOM extraction failed: %w", err)
	}

	return raw, nil
}

func (e *ShopeeExtractor) extractFromJSONLD(page *rod.Page) (*model.RawProduct, error) {
	result := page.MustEval(`() => {
		const scripts = document.querySelectorAll('script[type="application/ld+json"]');
		const results = [];
		scripts.forEach(s => {
			try {
				const data = JSON.parse(s.textContent);
				if (data['@type'] === 'Product') {
					results.push(s.textContent);
				}
			} catch(e) {}
		});
		return results.length > 0 ? results[0] : '';
	}`).Str()

	if result == "" {
		return nil, fmt.Errorf("no Product JSON-LD found")
	}

	var product jsonLDProduct
	if err := json.Unmarshal([]byte(result), &product); err != nil {
		return nil, fmt.Errorf("failed to parse JSON-LD: %w", err)
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

	if product.Offers != nil {
		raw.Price = parseJSONLDPrice(product.Offers.Price)
		if raw.Price == 0 {
			raw.Price = parseJSONLDPrice(product.Offers.LowPrice)
		}
	}

	return raw, nil
}

func (e *ShopeeExtractor) extractFromDOM(page *rod.Page) (*model.RawProduct, error) {
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
		let title = getTextBySelector('div.WBVL_7 span') ||
			getTextBySelector('div[class*="product-title"] span') ||
			getTextBySelector('h1') ||
			getAttrBySelector('meta[property="og:title"]', 'content');

		// Price
		let price = getTextBySelector('div.pmmxKx') ||
			getTextBySelector('div[class*="product-price"] span') ||
			'';

		// Image
		let image = getAttrBySelector('div.WBVL_7 img', 'src') ||
			getAttrBySelector('div[class*="image-carousel"] img', 'src') ||
			getAttrBySelector('meta[property="og:image"]', 'content') ||
			'';

		// Description
		let desc = getTextBySelector('div.f7AU53') ||
			getTextBySelector('div[class*="product-detail"]') ||
			getAttrBySelector('meta[property="og:description"]', 'content') ||
			'';

		// Variants
		let variants = [];
		const variantButtons = document.querySelectorAll('button[class*="product-variation"]');
		variantButtons.forEach(el => {
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

package extractor

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/coffee-beans-app/scraper/internal/model"
)

// ShopifyExtractor handles product extraction from Shopify-powered stores.
// It uses the Shopify JSON API endpoint (.json) for fast, reliable extraction
// without needing a headless browser.
type ShopifyExtractor struct{}

func (e *ShopifyExtractor) Name() string { return "shopify" }

// knownShopifyDomains are roastery domains known to run on Shopify.
// Add new domains here as they are discovered.
var knownShopifyDomains = []string{
	"fugolcoffeeroasters.com",
	// Add more known Shopify roastery domains here
}

func (e *ShopifyExtractor) CanHandle(productURL string) bool {
	lower := strings.ToLower(productURL)

	// Check for myshopify.com domains
	if strings.Contains(lower, ".myshopify.com") {
		return true
	}

	// Check known Shopify domains
	for _, domain := range knownShopifyDomains {
		if strings.Contains(lower, domain) {
			return true
		}
	}

	// Check if the URL has the /products/ path pattern (common Shopify)
	if strings.Contains(lower, "/products/") {
		// We'll try Shopify-style extraction; the generic extractor is the fallback
		return true
	}

	return false
}

// shopifyProductResponse represents the Shopify product JSON API response.
type shopifyProductResponse struct {
	Product shopifyProduct `json:"product"`
}

type shopifyProduct struct {
	ID          int64              `json:"id"`
	Handle      string             `json:"handle"`
	Title       string             `json:"title"`
	BodyHTML    string             `json:"body_html"`
	Vendor      string             `json:"vendor"`
	ProductType string             `json:"product_type"`
	Tags        string             `json:"tags"`
	Variants    []shopifyVariant   `json:"variants"`
	Images      []shopifyImage     `json:"images"`
	Image       *shopifyImage      `json:"image"`
}

type shopifyVariant struct {
	ID                  int64   `json:"id"`
	Title               string  `json:"title"`
	Price               string  `json:"price"`
	CompareAtPrice      string  `json:"compare_at_price"`
	Option1             string  `json:"option1"`
	Option2             string  `json:"option2"`
	Option3             string  `json:"option3"`
	Grams               int     `json:"grams"`
	Weight              float64 `json:"weight"`
	WeightUnit          string  `json:"weight_unit"`
	Available           bool    `json:"available"`
}

type shopifyImage struct {
	ID        int64  `json:"id"`
	Src       string `json:"src"`
	Width     int    `json:"width"`
	Height    int    `json:"height"`
}

func (e *ShopifyExtractor) CanHandleBulk(storeURL string) bool {
	return e.CanHandle(storeURL)
}

type shopifyCollectionProduct struct {
	Handle string `json:"handle"`
}

// shopifyCollectionResponse represents a Shopify collection JSON response containing multiple products.
type shopifyCollectionResponse struct {
	Products []shopifyCollectionProduct `json:"products"`
}

func (e *ShopifyExtractor) ExtractURLs(ctx context.Context, storeURL string, maxProducts int) ([]string, error) {
	log.Printf("[shopify] Extracting bulk URLs from: %s", storeURL)

	parsed, err := url.Parse(storeURL)
	if err != nil {
		return nil, fmt.Errorf("invalid store URL: %w", err)
	}

	cleanPath := strings.TrimRight(parsed.Path, "/")
	var jsonURL string
	if strings.Contains(cleanPath, "/collections/") || cleanPath == "" {
		jsonURL = parsed.Scheme + "://" + parsed.Host + cleanPath + "/products.json"
	} else {
		jsonURL = parsed.Scheme + "://" + parsed.Host + cleanPath + ".json"
	}

	log.Printf("[shopify] Bulk JSON endpoint: %s", jsonURL)

	client := &http.Client{Timeout: 15 * time.Second}
	req, err := http.NewRequestWithContext(ctx, "GET", jsonURL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch Shopify Collection JSON: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Shopify JSON endpoint returned status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	var collectionResp shopifyCollectionResponse
	if err := json.Unmarshal(body, &collectionResp); err != nil {
		return nil, fmt.Errorf("failed to parse Shopify JSON collection: %w", err)
	}

	if len(collectionResp.Products) == 0 {
		return nil, fmt.Errorf("no products found in collection")
	}

	// base URL for reconstructing product URLs
	baseURL := parsed.Scheme + "://" + parsed.Host

	var urls []string
	for i, product := range collectionResp.Products {
		if maxProducts > 0 && i >= maxProducts {
			break
		}
		if product.Handle != "" {
			urls = append(urls, baseURL+"/products/"+product.Handle)
		}
	}

	log.Printf("[shopify] Extracted %d product URLs successfully", len(urls))
	return urls, nil
}

func (e *ShopifyExtractor) Extract(ctx context.Context, productURL string) (*model.RawProduct, error) {
	log.Printf("[shopify] Extracting from: %s", productURL)

	// Build the JSON endpoint URL
	jsonURL := buildShopifyJSONURL(productURL)
	log.Printf("[shopify] JSON endpoint: %s", jsonURL)

	// HTTP request with timeout
	client := &http.Client{Timeout: 15 * time.Second}
	req, err := http.NewRequestWithContext(ctx, "GET", jsonURL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch Shopify JSON: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Shopify JSON endpoint returned status %d (this site might not be Shopify)", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	var shopifyResp shopifyProductResponse
	if err := json.Unmarshal(body, &shopifyResp); err != nil {
		return nil, fmt.Errorf("failed to parse Shopify JSON (site might not be Shopify): %w", err)
	}

	product := shopifyResp.Product
	if product.Title == "" {
		return nil, fmt.Errorf("Shopify product has no title")
	}

	log.Printf("[shopify] Found product: %s (%d variants)", product.Title, len(product.Variants))

	// Build raw product
	raw := &model.RawProduct{
		Title:       product.Title,
		Description: stripHTML(product.BodyHTML),
		Currency:    "IDR",
	}

	// Collect images
	if product.Image != nil {
		raw.ImageURLs = append(raw.ImageURLs, product.Image.Src)
	}
	for _, img := range product.Images {
		if product.Image == nil || img.ID != product.Image.ID {
			raw.ImageURLs = append(raw.ImageURLs, img.Src)
		}
	}

	// Process variants
	for _, v := range product.Variants {
		price := parseShopifyPrice(v.Price)
		name := buildVariantName(v)

		if len(product.Variants) == 1 {
			// Single variant — use as main price
			raw.Price = price
			// Try to extract weight from variant data
			if v.Grams > 0 {
				raw.Weight = fmt.Sprintf("%dg", v.Grams)
			} else if v.Weight > 0 {
				raw.Weight = fmt.Sprintf("%.0f%s", v.Weight, v.WeightUnit)
			}
		}

		raw.Variants = append(raw.Variants, model.RawVariant{
			Name:  name,
			Price: price,
		})
	}

	// Store extra data
	raw.ExtraData = map[string]string{
		"vendor":       product.Vendor,
		"product_type": product.ProductType,
		"tags":         product.Tags,
	}

	return raw, nil
}

// buildShopifyJSONURL converts a product URL to its JSON API endpoint.
func buildShopifyJSONURL(productURL string) string {
	// Remove query string and hash
	u := productURL
	if idx := strings.Index(u, "?"); idx != -1 {
		u = u[:idx]
	}
	if idx := strings.Index(u, "#"); idx != -1 {
		u = u[:idx]
	}

	// Remove trailing slash
	u = strings.TrimRight(u, "/")

	// Append .json
	return u + ".json"
}

// buildVariantName builds a descriptive name from variant data.
func buildVariantName(v shopifyVariant) string {
	parts := []string{}

	if v.Option1 != "" && v.Option1 != "Default Title" {
		parts = append(parts, v.Option1)
	}
	if v.Option2 != "" {
		parts = append(parts, v.Option2)
	}
	if v.Option3 != "" {
		parts = append(parts, v.Option3)
	}

	if len(parts) == 0 {
		// Fall back to weight data
		if v.Grams > 0 {
			return fmt.Sprintf("%dg", v.Grams)
		}
		return v.Title
	}

	return strings.Join(parts, " - ")
}

// parseShopifyPrice parses Shopify's price string (usually in "85000.00" format).
func parseShopifyPrice(priceStr string) int64 {
	// Remove any currency symbols and spaces
	priceStr = strings.TrimSpace(priceStr)
	if priceStr == "" {
		return 0
	}

	// Shopify prices are typically in "85000.00" format
	// We want the integer part (IDR doesn't use decimal)
	if idx := strings.Index(priceStr, "."); idx != -1 {
		priceStr = priceStr[:idx]
	}

	return parsePriceString(priceStr)
}

// stripHTML removes HTML tags from a string (simple approach).
func stripHTML(html string) string {
	// Simple regex-free HTML stripping
	var result strings.Builder
	inTag := false

	for _, r := range html {
		switch {
		case r == '<':
			inTag = true
		case r == '>':
			inTag = false
			result.WriteRune(' ')
		case !inTag:
			result.WriteRune(r)
		}
	}

	// Clean up whitespace
	text := result.String()
	text = strings.ReplaceAll(text, "&nbsp;", " ")
	text = strings.ReplaceAll(text, "&amp;", "&")
	text = strings.ReplaceAll(text, "&lt;", "<")
	text = strings.ReplaceAll(text, "&gt;", ">")
	text = strings.ReplaceAll(text, "&#39;", "'")
	text = strings.ReplaceAll(text, "&quot;", "\"")

	// Collapse whitespace
	fields := strings.Fields(text)
	return strings.Join(fields, " ")
}

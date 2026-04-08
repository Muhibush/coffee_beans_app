package extractor

import (
	"context"
	"fmt"
	"net/url"
	"strings"

	"github.com/coffee-beans-app/scraper/internal/model"
)

// Extractor defines the interface for source-specific data extraction.
type Extractor interface {
	// Extract fetches and parses product data from the given URL.
	Extract(ctx context.Context, productURL string) (*model.RawProduct, error)
	// CanHandle returns true if this extractor supports the given URL.
	CanHandle(productURL string) bool
	// Name returns the source identifier.
	Name() string
}

// BulkExtractor defines the interface for extracting multiple product URLs from a store.
type BulkExtractor interface {
	// ExtractURLs fetches and returns product URLs and titles from the given store/collection URL.
	ExtractURLs(ctx context.Context, storeURL string, maxProducts int) ([]model.BulkProduct, error)
	// CanHandleBulk returns true if this extractor supports bulk scraping for the given URL.
	CanHandleBulk(storeURL string) bool
	// Name returns the source identifier.
	Name() string
}

// registry holds all registered extractors in priority order.
var registry []Extractor

// bulkRegistry holds all registered bulk extractors.
var bulkRegistry []BulkExtractor

// Register adds an extractor to the registry.
func Register(e Extractor) {
	registry = append(registry, e)
}

// RegisterBulk adds a bulk extractor to the registry.
func RegisterBulk(e BulkExtractor) {
	bulkRegistry = append(bulkRegistry, e)
}

// init registers all extractors. Order matters — more specific patterns first.
func init() {
	Register(&TokopediaExtractor{})
	Register(&ShopifyExtractor{})
	Register(&GenericExtractor{}) // fallback — must be last

	RegisterBulk(&TokopediaExtractor{})
	RegisterBulk(&ShopifyExtractor{})
}

// Route finds the appropriate extractor for a given URL and extracts the data.
func Route(ctx context.Context, rawURL string) (*model.RawProduct, error) {
	// Normalize the URL
	rawURL = strings.TrimSpace(rawURL)
	if rawURL == "" {
		return nil, fmt.Errorf("empty URL provided")
	}

	// Validate URL format
	parsed, err := url.Parse(rawURL)
	if err != nil {
		return nil, fmt.Errorf("invalid URL: %w", err)
	}
	if parsed.Scheme == "" {
		rawURL = "https://" + rawURL
	}

	// Find matching extractor
	for _, ext := range registry {
		if ext.CanHandle(rawURL) {
			product, err := ext.Extract(ctx, rawURL)
			if err != nil {
				return nil, fmt.Errorf("[%s] extraction failed: %w", ext.Name(), err)
			}
			product.Source = ext.Name()
			product.SourceURL = rawURL
			return product, nil
		}
	}

	return nil, fmt.Errorf("no extractor found for URL: %s", rawURL)
}

// RouteBulk finds the appropriate bulk extractor for a given URL and extracts product items.
func RouteBulk(ctx context.Context, rawURL string, maxProducts int) ([]model.BulkProduct, string, error) {
	// Normalize the URL
	rawURL = strings.TrimSpace(rawURL)
	if rawURL == "" {
		return nil, "", fmt.Errorf("empty URL provided")
	}

	// Validate URL format
	parsed, err := url.Parse(rawURL)
	if err != nil {
		return nil, "", fmt.Errorf("invalid URL: %w", err)
	}
	if parsed.Scheme == "" {
		rawURL = "https://" + rawURL
	}

	// Find matching bulk extractor
	for _, ext := range bulkRegistry {
		if ext.CanHandleBulk(rawURL) {
			products, err := ext.ExtractURLs(ctx, rawURL, maxProducts)
			if err != nil {
				return nil, ext.Name(), fmt.Errorf("[%s] bulk extraction failed: %w", ext.Name(), err)
			}
			return products, ext.Name(), nil
		}
	}

	return nil, "", fmt.Errorf("no bulk extractor found for URL: %s", rawURL)
}

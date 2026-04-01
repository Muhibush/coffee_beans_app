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

// registry holds all registered extractors in priority order.
var registry []Extractor

// Register adds an extractor to the registry.
func Register(e Extractor) {
	registry = append(registry, e)
}

// init registers all extractors. Order matters — more specific patterns first.
func init() {
	Register(&TokopediaExtractor{})
	Register(&ShopeeExtractor{})
	Register(&ShopifyExtractor{})
	Register(&GenericExtractor{}) // fallback — must be last
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

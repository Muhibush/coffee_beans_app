package extractor

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

// Shared utility functions used across multiple extractors.

// pricePattern matches numeric price values, potentially with dots or commas as thousands separators.
var pricePattern = regexp.MustCompile(`[\d.,]+`)

// parsePriceString extracts a numeric price from a formatted string.
// Handles formats like "Rp85.000", "Rp 85,000", "85000", "85000.00"
func parsePriceString(s string) int64 {
	if s == "" {
		return 0
	}

	// Find all numeric-like sequences
	match := pricePattern.FindString(s)
	if match == "" {
		return 0
	}

	// Remove thousands separators (dots and commas) based on context:
	// "85.000" (IDR style) → 85000
	// "85,000" (western style) → 85000
	// "85000.00" (decimal) → 85000

	// If ends with .00 or .0, it's a decimal — remove it
	if strings.HasSuffix(match, ".00") || strings.HasSuffix(match, ".0") {
		match = match[:strings.LastIndex(match, ".")]
	}

	// Remove remaining dots and commas (thousands separators)
	match = strings.ReplaceAll(match, ".", "")
	match = strings.ReplaceAll(match, ",", "")

	val, err := strconv.ParseInt(match, 10, 64)
	if err != nil {
		return 0
	}

	return val
}

// parseJSONLDImage extracts image URLs from JSON-LD image field which can be
// a string, []string, or []interface{}.
func parseJSONLDImage(img interface{}) []string {
	if img == nil {
		return nil
	}

	switch v := img.(type) {
	case string:
		if v != "" {
			return []string{v}
		}
	case []interface{}:
		var urls []string
		for _, item := range v {
			if s, ok := item.(string); ok && s != "" {
				urls = append(urls, s)
			}
		}
		return urls
	case []string:
		return v
	}

	return nil
}

// parseJSONLDPrice extracts a price from JSON-LD offers which can be
// a string or a number.
func parseJSONLDPrice(price interface{}) int64 {
	if price == nil {
		return 0
	}

	switch v := price.(type) {
	case float64:
		return int64(v)
	case int64:
		return v
	case string:
		return parsePriceString(v)
	case fmt.Stringer:
		return parsePriceString(v.String())
	}

	return 0
}

package extractor

import (
	"testing"
)

func TestParsePriceString(t *testing.T) {
	tests := []struct {
		input    string
		expected int64
	}{
		{"Rp85.000", 85000},
		{"Rp 85,000", 85000},
		{"85000", 85000},
		{"85000.00", 85000},
		{"Rp52.000", 52000},
		{"IDR 120.000", 120000},
		{"", 0},
		{"Free", 0},
		{"Rp1.250.000", 1250000},
	}

	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T) {
			result := parsePriceString(tt.input)
			if result != tt.expected {
				t.Errorf("parsePriceString(%q) = %d, want %d", tt.input, result, tt.expected)
			}
		})
	}
}

func TestParseJSONLDImage(t *testing.T) {
	tests := []struct {
		name     string
		input    interface{}
		expected int // expected number of URLs
	}{
		{"string", "https://example.com/img.jpg", 1},
		{"array of strings", []interface{}{"img1.jpg", "img2.jpg"}, 2},
		{"nil", nil, 0},
		{"empty string", "", 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := parseJSONLDImage(tt.input)
			if len(result) != tt.expected {
				t.Errorf("expected %d images, got %d: %v", tt.expected, len(result), result)
			}
		})
	}
}

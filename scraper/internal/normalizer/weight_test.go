package normalizer

import (
	"testing"
)

func TestExtractWeights(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected []string // normalized weight strings
	}{
		{
			name:     "single gram",
			input:    "Kopi Arabika Gayo 250gr",
			expected: []string{"250g"},
		},
		{
			name:     "gram with space",
			input:    "Kopi 500 gram Natural",
			expected: []string{"500g"},
		},
		{
			name:     "kilogram",
			input:    "Coffee Beans 1kg Pack",
			expected: []string{"1kg"},
		},
		{
			name:     "multiple weights",
			input:    "Available in 100g and 250g",
			expected: []string{"100g", "250g"},
		},
		{
			name:     "case insensitive",
			input:    "Kopi 200GR Premium",
			expected: []string{"200g"},
		},
		{
			name:     "no weight",
			input:    "Premium Coffee Beans",
			expected: nil,
		},
		{
			name:     "gram lowercase",
			input:    "Watermelon Smash 100 gram",
			expected: []string{"100g"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := ExtractWeights(tt.input)

			if tt.expected == nil && result != nil {
				t.Errorf("expected nil, got %v", result)
				return
			}

			if len(result) != len(tt.expected) {
				t.Errorf("expected %d weights, got %d: %v", len(tt.expected), len(result), result)
				return
			}

			for i, exp := range tt.expected {
				if result[i].Normalized != exp {
					t.Errorf("weight[%d]: expected %s, got %s", i, exp, result[i].Normalized)
				}
			}
		})
	}
}

func TestExtractFirstWeight(t *testing.T) {
	tests := []struct {
		input             string
		expectedNormalized string
		expectedRaw       string
	}{
		{"Kopi 250gr Arabika", "250g", "250gr"},
		{"No weight here", "", ""},
		{"Pack 1kg", "1kg", "1kg"},
	}

	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T) {
			norm, raw := ExtractFirstWeight(tt.input)
			if norm != tt.expectedNormalized {
				t.Errorf("normalized: expected %q, got %q", tt.expectedNormalized, norm)
			}
			if raw != tt.expectedRaw {
				t.Errorf("raw: expected %q, got %q", tt.expectedRaw, raw)
			}
		})
	}
}

package normalizer

import (
	"testing"
)

func TestCleanTitle(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "marketplace full noise",
			input:    "PROMO!! Biji Kopi Aceh Gayo 250gr - Fullwash Ready!",
			expected: "Aceh Gayo Fullwash",
		},
		{
			name:     "tokopedia style title",
			input:    "Kopi Arabika Watermelon Smash 100 gram Natural Biji Bubuk",
			expected: "Watermelon Smash Natural",
		},
		{
			name:     "clean title stays clean",
			input:    "Ethiopia Guji Grade 1",
			expected: "Ethiopia Guji",
		},
		{
			name:     "specialty coffee prefix",
			input:    "Specialty Coffee Flores Bajawa 250g",
			expected: "Flores Bajawa",
		},
		{
			name:     "multiple noise words",
			input:    "TERLARIS! Fresh Biji Kopi Arabika Aceh Gayo 500gr Murah",
			expected: "Aceh Gayo",
		},
		{
			name:     "simple name",
			input:    "Watermelon Smash",
			expected: "Watermelon Smash",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := CleanTitle(tt.input)
			if result != tt.expected {
				t.Errorf("CleanTitle(%q)\n  got:  %q\n  want: %q", tt.input, result, tt.expected)
			}
		})
	}
}

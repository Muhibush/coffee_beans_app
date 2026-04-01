package normalizer

import (
	"testing"
)

func TestExtractSpecs(t *testing.T) {
	tests := []struct {
		name   string
		title  string
		desc   string
		check  func(t *testing.T, specs CoffeeSpecs)
	}{
		{
			name:  "Process - Natural",
			title: "Aceh Gayo Natural 250g",
			desc:  "Single origin dari Aceh dengan proses Natural",
			check: func(t *testing.T, specs CoffeeSpecs) {
				if specs.Process != "Natural" {
					t.Errorf("Process: expected 'Natural', got %q", specs.Process)
				}
			},
		},
		{
			name:  "Process - Washed in description",
			title: "Ethiopia Guji 250g",
			desc:  "Washed process coffee from Ethiopia Guji zone with altitude 1800-2100 masl",
			check: func(t *testing.T, specs CoffeeSpecs) {
				if specs.Process != "Washed Process" {
					t.Errorf("Process: expected 'Washed Process', got %q", specs.Process)
				}
			},
		},
		{
			name:  "Origin - Aceh Gayo",
			title: "Single Origin Aceh Gayo",
			desc:  "",
			check: func(t *testing.T, specs CoffeeSpecs) {
				if specs.Origin != "Aceh Gayo" {
					t.Errorf("Origin: expected 'Aceh Gayo', got %q", specs.Origin)
				}
			},
		},
		{
			name:  "Origin - Flores Bajawa",
			title: "Flores Bajawa Honey",
			desc:  "",
			check: func(t *testing.T, specs CoffeeSpecs) {
				if specs.Origin != "Flores Bajawa" {
					t.Errorf("Origin: expected 'Flores Bajawa', got %q", specs.Origin)
				}
			},
		},
		{
			name:  "Altitude extraction",
			title: "Ethiopia Guji",
			desc:  "Grown at 1800 masl in the highlands",
			check: func(t *testing.T, specs CoffeeSpecs) {
				if specs.Altitude != "1800 masl" {
					t.Errorf("Altitude: expected '1800 masl', got %q", specs.Altitude)
				}
			},
		},
		{
			name:  "Altitude range",
			title: "Ethiopia Guji",
			desc:  "Altitude 1800-2100 masl",
			check: func(t *testing.T, specs CoffeeSpecs) {
				if specs.Altitude != "1800 - 2100 masl" {
					t.Errorf("Altitude: expected '1800 - 2100 masl', got %q", specs.Altitude)
				}
			},
		},
		{
			name:  "Variety - Typica",
			title: "Aceh Gayo Typica",
			desc:  "",
			check: func(t *testing.T, specs CoffeeSpecs) {
				if len(specs.Variety) == 0 || specs.Variety[0] != "Typica" {
					t.Errorf("Variety: expected ['Typica'], got %v", specs.Variety)
				}
			},
		},
		{
			name:  "Notes - Chocolate and Citrus",
			title: "Coffee beans",
			desc:  "Notes of chocolate and citrus with a floral aroma",
			check: func(t *testing.T, specs CoffeeSpecs) {
				found := map[string]bool{}
				for _, n := range specs.Notes {
					found[n] = true
				}
				if !found["Chocolate"] {
					t.Errorf("Notes: expected to find 'Chocolate' in %v", specs.Notes)
				}
				if !found["Citrus"] {
					t.Errorf("Notes: expected to find 'Citrus' in %v", specs.Notes)
				}
				if !found["Floral"] {
					t.Errorf("Notes: expected to find 'Floral' in %v", specs.Notes)
				}
			},
		},
		{
			name:  "Watermelon title extracts notes",
			title: "Kopi Arabika Watermelon Smash",
			desc:  "Rasa watermelon yang segar",
			check: func(t *testing.T, specs CoffeeSpecs) {
				found := map[string]bool{}
				for _, n := range specs.Notes {
					found[n] = true
				}
				if !found["Watermelon"] {
					t.Errorf("Notes: expected to find 'Watermelon' in %v", specs.Notes)
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			specs := ExtractSpecs(tt.title, tt.desc)
			tt.check(t, specs)
		})
	}
}

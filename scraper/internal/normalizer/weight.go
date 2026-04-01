package normalizer

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

// weightPattern matches weight values in product titles/descriptions.
// Examples: "250gr", "500 gram", "1kg", "100g", "1 kilogram"
var weightPattern = regexp.MustCompile(`(?i)(\d+)\s*(gram|gr|g|kg|kilogram)\b`)

// WeightMatch holds a parsed weight occurrence.
type WeightMatch struct {
	Raw        string // original matched text e.g. "250gr"
	Value      int    // numeric value
	Unit       string // standardized unit: "g" or "kg"
	Normalized string // display string: "250g", "1kg"
}

// ExtractWeights finds all weight values in the given text.
func ExtractWeights(text string) []WeightMatch {
	matches := weightPattern.FindAllStringSubmatch(text, -1)
	if len(matches) == 0 {
		return nil
	}

	var results []WeightMatch
	seen := make(map[string]bool)

	for _, m := range matches {
		if len(m) < 3 {
			continue
		}

		val, err := strconv.Atoi(m[1])
		if err != nil {
			continue
		}

		unit := standardizeUnit(m[2])
		normalized := fmt.Sprintf("%d%s", val, unit)

		// Deduplicate
		if seen[normalized] {
			continue
		}
		seen[normalized] = true

		results = append(results, WeightMatch{
			Raw:        m[0],
			Value:      val,
			Unit:       unit,
			Normalized: normalized,
		})
	}

	return results
}

// ExtractFirstWeight extracts the first weight found in text.
// Returns the normalized string (e.g. "250g") and the raw match.
func ExtractFirstWeight(text string) (normalized string, raw string) {
	weights := ExtractWeights(text)
	if len(weights) == 0 {
		return "", ""
	}
	return weights[0].Normalized, weights[0].Raw
}

// standardizeUnit normalizes weight unit strings.
func standardizeUnit(unit string) string {
	lower := strings.ToLower(unit)
	switch lower {
	case "kg", "kilogram":
		return "kg"
	default: // "gram", "gr", "g"
		return "g"
	}
}

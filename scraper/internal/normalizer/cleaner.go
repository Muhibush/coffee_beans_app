package normalizer

import (
	"regexp"
	"sort"
	"strings"
)

// noiseWords are marketing/generic words stripped from titles to produce a clean name.
var noiseWords = []string{
	// Marketing noise
	"promo", "murah", "ready", "terlaris", "best seller", "bestseller",
	"diskon", "sale", "flash sale", "special", "limited",
	// Generic coffee words (removed from clean name, not from specs extraction)
	"specialty coffee", "speciality coffee", "single origin",
	"kopi arabika", "kopi robusta", "kopi",
	"arabika", "robusta", "arabica",
	"biji kopi", "biji", "bubuk kopi", "bubuk",
	"coffee beans", "coffee bean", "coffee",
	"roasted bean", "roasted beans", "roasted",
	"grade 1", "grade1",
	"original", "100%", "fresh",
	// Grind types in title (ignored per user decision)
	"whole bean", "ground",
}

// sortedNoiseWords are noiseWords sorted by length descending so that
// longer phrases (e.g. "specialty coffee") are matched before shorter
// substrings (e.g. "special").
var sortedNoiseWords []string

func init() {
	sortedNoiseWords = make([]string, len(noiseWords))
	copy(sortedNoiseWords, noiseWords)
	sort.Slice(sortedNoiseWords, func(i, j int) bool {
		return len(sortedNoiseWords[i]) > len(sortedNoiseWords[j])
	})
}

// specialCharsPattern matches special characters to strip from titles.
var specialCharsPattern = regexp.MustCompile(`[!@#$%^&*()\[\]{}<>|\\/:;'"\-_+=~` + "`" + `]+`)

// multiSpacePattern matches multiple consecutive spaces.
var multiSpacePattern = regexp.MustCompile(`\s{2,}`)

// CleanTitle strips weight, noise words, and special characters from a product title
// to produce a clean bean name.
func CleanTitle(title string) string {
	cleaned := title

	// 1. Remove weight matches
	weightMatches := weightPattern.FindAllString(cleaned, -1)
	for _, wm := range weightMatches {
		cleaned = strings.ReplaceAll(cleaned, wm, " ")
	}

	// 2. Remove noise words (case-insensitive, longest first)
	lower := strings.ToLower(cleaned)
	for _, noise := range sortedNoiseWords {
		noiseLower := strings.ToLower(noise)
		idx := strings.Index(lower, noiseLower)
		for idx != -1 {
			cleaned = cleaned[:idx] + " " + cleaned[idx+len(noise):]
			lower = strings.ToLower(cleaned)
			idx = strings.Index(lower, noiseLower)
		}
	}

	// 3. Remove special characters
	cleaned = specialCharsPattern.ReplaceAllString(cleaned, " ")

	// 4. Collapse multiple spaces and trim
	cleaned = multiSpacePattern.ReplaceAllString(cleaned, " ")
	cleaned = strings.TrimSpace(cleaned)

	// 5. Title-case each word
	cleaned = toTitleCase(cleaned)

	return cleaned
}

// toTitleCase capitalizes the first letter of each word.
func toTitleCase(s string) string {
	words := strings.Fields(s)
	for i, w := range words {
		if len(w) > 0 {
			words[i] = strings.ToUpper(w[:1]) + strings.ToLower(w[1:])
		}
	}
	return strings.Join(words, " ")
}

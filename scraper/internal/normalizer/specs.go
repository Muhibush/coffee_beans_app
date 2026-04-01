package normalizer

import (
	"regexp"
	"strings"
)

// Coffee processing methods (case-insensitive match against title + description).
var processKeywords = []string{
	"full wash", "fullwash", "fully washed",
	"semi wash", "semi washed", "semiwash",
	"natural process", "natural",
	"washed process", "washed",
	"honey process", "honey",
	"anaerobic natural", "anaerobic washed", "anaerobic",
	"wet hulled", "wet hull", "giling basah",
	"wine process", "wine",
	"carbonic maceration",
	"lactic",
}

// Coffee variety/cultivar keywords.
var varietyKeywords = []string{
	"sigarar utang", "sigararutang",
	"typica", "bourbon", "caturra", "catuai",
	"sl28", "sl34", "sl 28", "sl 34",
	"heirloom",
	"kartika", "andungsari", "lini s", "lini-s",
	"ateng", "ateng super",
	"jember", "s-795", "s795",
	"tim tim", "timtim",
	"gesha", "geisha",
	"catimor",
	"rasuna",
	"abyssinia",
}

// Origin keywords (Indonesian regions + common international origins).
var originKeywords = map[string]string{
	// Indonesian origins — map variant spellings to canonical name
	// Compound names first (longer keys get priority via longest-match)
	"aceh gayo":       "Aceh Gayo",
	"gayo":            "Aceh Gayo",
	"aceh":            "Aceh",
	"lintong":         "Lintong",
	"sidikalang":      "Sidikalang",
	"sumatera":        "Sumatera",
	"sumatra":         "Sumatera",
	"mandailing":      "Mandailing",
	"toraja sapan":    "Toraja Sapan",
	"toraja kalosi":   "Toraja Kalosi",
	"toraja":          "Toraja",
	"sapan":           "Toraja Sapan",
	"kalosi":          "Toraja Kalosi",
	"enrekang":        "Enrekang",
	"flores bajawa":   "Flores Bajawa",
	"flores manggarai": "Flores Manggarai",
	"flores":          "Flores",
	"bajawa":          "Flores Bajawa",
	"manggarai":       "Flores Manggarai",
	"bali kintamani":  "Bali Kintamani",
	"kintamani":       "Bali Kintamani",
	"bali":            "Bali",
	"java":            "Java",
	"jawa barat":      "Jawa Barat",
	"jawa timur":      "Jawa Timur",
	"papua wamena":    "Papua Wamena",
	"wamena":          "Papua Wamena",
	"papua":           "Papua",
	"sulawesi":        "Sulawesi",
	"bengkulu":        "Bengkulu",
	"lampung":         "Lampung",
	"temanggung":      "Temanggung",
	// Common international origins
	"ethiopia guji":      "Ethiopia Guji",
	"ethiopia yirgacheffe": "Ethiopia Yirgacheffe",
	"ethiopia sidamo":    "Ethiopia Sidamo",
	"ethiopia":           "Ethiopia",
	"ethiopian":          "Ethiopia",
	"colombia":           "Colombia",
	"colombian":          "Colombia",
	"brazil":             "Brazil",
	"brazilian":          "Brazil",
	"kenya":              "Kenya",
	"kenyan":             "Kenya",
	"guatemala":          "Guatemala",
	"guji":               "Ethiopia Guji",
	"yirgacheffe":        "Ethiopia Yirgacheffe",
	"sidamo":             "Ethiopia Sidamo",
}

// Tasting note keywords.
var noteKeywords = []string{
	"chocolate", "cokelat", "dark chocolate",
	"citrus", "jeruk",
	"floral", "bunga",
	"fruity", "buah",
	"nutty", "kacang", "nuts",
	"berry", "blueberry", "strawberry", "raspberry",
	"caramel", "karamel",
	"spicy", "rempah",
	"wine", "winey",
	"honey", "madu",
	"tropical", "tropis",
	"stone fruit",
	"vanilla",
	"brown sugar", "gula merah",
	"jasmine", "melati",
	"tea", "teh",
	"apple", "apel",
	"mango", "mangga",
	"watermelon", "semangka",
	"melon",
	"peach",
	"plum",
	"grape", "anggur",
	"lemon", "lime",
	"orange", "jeruk",
	"cinnamon", "kayu manis",
	"tobacco", "tembakau",
	"earthy",
	"smoky",
	"sweet",
	"cocoa", "kakao",
	"hazelnut",
	"almond",
	"peanut",
	"cherry",
	"blackberry",
	"papaya", "pepaya",
}

// Roast level keywords.
var roastLevelKeywords = map[string]string{
	"light roast":        "Light",
	"light":              "Light",
	"medium light":       "Medium Light",
	"medium-light":       "Medium Light",
	"medium roast":       "Medium",
	"medium":             "Medium",
	"medium dark":        "Medium Dark",
	"medium-dark":        "Medium Dark",
	"dark roast":         "Dark",
	"dark":               "Dark",
	"omni roast":         "Omni",
	"omni":               "Omni",
	"city roast":         "Medium",
	"full city":          "Medium Dark",
	"filter roast":       "Light",
	"espresso roast":     "Medium Dark",
}

// altitudePattern matches altitude values like "1800 masl", "1200 mdpl", "1500m asl".
var altitudePattern = regexp.MustCompile(`(?i)(\d{3,4})\s*(?:-\s*(\d{3,4})\s*)?(?:m\.?\s*a\.?\s*s\.?\s*l\.?|masl|mdpl|meter|m\s+dpl)`)

// CoffeeSpecs holds extracted coffee-specific metadata.
type CoffeeSpecs struct {
	Process    string   `json:"process,omitempty"`
	RoastLevel string   `json:"roast_level,omitempty"`
	Variety    []string `json:"variety,omitempty"`
	Notes      []string `json:"notes,omitempty"`
	Origin     string   `json:"origin,omitempty"`
	Altitude   string   `json:"altitude,omitempty"`
}

// ExtractSpecs extracts coffee specs from combined title + description text.
func ExtractSpecs(title, description string) CoffeeSpecs {
	// Combine title and description for searching
	combined := strings.ToLower(title + " " + description)

	specs := CoffeeSpecs{}
	specs.Process = extractProcess(combined)
	specs.RoastLevel = extractRoastLevel(combined)
	specs.Variety = extractVariety(combined)
	specs.Notes = extractNotes(combined)
	specs.Origin = extractOrigin(combined)
	specs.Altitude = extractAltitude(combined)

	return specs
}

func extractProcess(text string) string {
	// Check longer phrases first to avoid partial matches
	for _, keyword := range processKeywords {
		if strings.Contains(text, strings.ToLower(keyword)) {
			return toTitleCase(keyword)
		}
	}
	return ""
}

func extractRoastLevel(text string) string {
	// Check longer phrases first (order matters in the map iteration isn't guaranteed,
	// so we use a sorted approach)
	longestMatch := ""
	longestLen := 0

	for keyword, level := range roastLevelKeywords {
		if strings.Contains(text, keyword) && len(keyword) > longestLen {
			longestMatch = level
			longestLen = len(keyword)
		}
	}
	return longestMatch
}

func extractVariety(text string) []string {
	var found []string
	seen := make(map[string]bool)

	for _, keyword := range varietyKeywords {
		if strings.Contains(text, strings.ToLower(keyword)) {
			canonical := toTitleCase(keyword)
			if !seen[canonical] {
				seen[canonical] = true
				found = append(found, canonical)
			}
		}
	}
	return found
}

func extractNotes(text string) []string {
	var found []string
	seen := make(map[string]bool)

	for _, keyword := range noteKeywords {
		if strings.Contains(text, strings.ToLower(keyword)) {
			canonical := toTitleCase(keyword)
			if !seen[canonical] {
				seen[canonical] = true
				found = append(found, canonical)
			}
		}
	}
	return found
}

func extractOrigin(text string) string {
	// Find longest matching origin keyword for specificity
	// e.g. "aceh gayo" should match before "aceh"
	longestMatch := ""
	longestLen := 0

	for keyword, canonical := range originKeywords {
		if strings.Contains(text, keyword) && len(keyword) > longestLen {
			longestMatch = canonical
			longestLen = len(keyword)
		}
	}
	return longestMatch
}

func extractAltitude(text string) string {
	matches := altitudePattern.FindStringSubmatch(text)
	if len(matches) < 2 {
		return ""
	}

	if matches[2] != "" {
		return matches[1] + " - " + matches[2] + " masl"
	}
	return matches[1] + " masl"
}

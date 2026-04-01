package model

// RawProduct holds the raw extracted data from any source before normalization.
type RawProduct struct {
	SourceURL   string            `json:"source_url"`
	Source      string            `json:"source"` // "tokopedia", "shopify", "generic"
	Title       string            `json:"title"`
	Price       int64             `json:"price"`    // in IDR, 0 if not found
	Currency    string            `json:"currency"` // "IDR"
	ImageURLs   []string          `json:"image_urls"`
	Description string            `json:"description"`
	Weight      string            `json:"weight"` // raw weight string e.g. "250 gram"
	Variants    []RawVariant      `json:"variants"`
	ExtraData   map[string]string `json:"extra_data"` // catch-all for source-specific data
}

// RawVariant represents a product variant as found on the source page.
type RawVariant struct {
	Name  string `json:"name"`  // e.g. "250g", "Biji", "Bubuk"
	Price int64  `json:"price"` // price in IDR
}

// ScrapedBean is the normalized output matching the beans table schema.
// This is returned to the Flutter admin for review before saving.
type ScrapedBean struct {
	CleanName   string             `json:"clean_name"`
	ImageURL    string             `json:"image_url"`
	Process     string             `json:"process,omitempty"`
	RoastLevel  string             `json:"roast_level,omitempty"`
	Variety     []string           `json:"variety,omitempty"`
	Notes       []string           `json:"notes,omitempty"`
	Origin      string             `json:"origin,omitempty"`
	Altitude    string             `json:"altitude,omitempty"`
	Description string             `json:"description,omitempty"`
	Variants    map[string]Variant `json:"variants"`
	Source      string             `json:"source"`
	SourceURL   string             `json:"source_url"`
}

// Variant holds pricing and buy links for a specific weight.
type Variant struct {
	Price       int64  `json:"price"`
	BuyURL      string `json:"buy_url"`
	Marketplace string `json:"marketplace"` // "tokopedia", "web"
	GrindType   string `json:"grind_type,omitempty"` // "biji" (whole bean), "bubuk" (ground) — only if from variant
}

// ScrapeRequest is the incoming API request body.
type ScrapeRequest struct {
	URL string `json:"url"`
}

// ScrapeResponse is the API response envelope.
type ScrapeResponse struct {
	Success bool        `json:"success"`
	Data    *ScrapedBean `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

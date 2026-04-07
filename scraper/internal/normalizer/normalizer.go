package normalizer

import (
	"strings"

	"github.com/coffee-beans-app/scraper/internal/model"
)

// Normalize takes raw extracted product data and produces a clean ScrapedBean.
func Normalize(raw *model.RawProduct) *model.ScrapedBean {
	bean := &model.ScrapedBean{
		Source:    raw.Source,
		SourceURL: raw.SourceURL,
	}

	// 1. Clean the title to produce clean_name
	bean.CleanName = CleanTitle(raw.Title)

	// 2. Set the primary image
	if len(raw.ImageURLs) > 0 {
		bean.ImageURL = raw.ImageURLs[0]
	}

	// 3. Set description
	bean.Description = raw.Description

	// 4. Extract coffee specs from title + description
	specs := ExtractSpecs(raw.Title, raw.Description)
	bean.Process = specs.Process
	bean.RoastLevel = specs.RoastLevel
	bean.Variety = specs.Variety
	bean.Notes = specs.Notes
	bean.Origin = specs.Origin
	bean.Altitude = specs.Altitude

	// 5. Build variants map
	bean.Variants = buildVariants(raw)

	return bean
}

// buildVariants constructs the weight-keyed variants map (in grams) from raw product data.
func buildVariants(raw *model.RawProduct) map[int]model.Variant {
	variants := make(map[int]model.Variant)
	marketplace := mapSourceToMarketplace(raw.Source)

	// If raw has explicit variants from the page
	if len(raw.Variants) > 0 {
		for _, rv := range raw.Variants {
			// Try to extract weight from variant name in grams
			grams, _ := ExtractFirstWeightGrams(rv.Name)
			grindType := extractGrindType(rv.Name)

			// Fallback to title weight if variant name doesn't specify weight
			if grams == 0 {
				titleGrams, _ := ExtractFirstWeightGrams(raw.Title)
				if titleGrams > 0 {
					grams = titleGrams
				} else {
					grams = -1 // Unknown weight placeholder
				}
			}

			price := rv.Price
			if price == 0 {
				price = raw.Price
			}

			existing, exists := variants[grams]
			if exists {
				// Merge info
				if grindType != "" {
					existing.GrindType = grindType
				}
				// If we find a non-zero price, keep it
				if existing.Price == 0 {
					existing.Price = price
				}
				variants[grams] = existing
			} else {
				variants[grams] = model.Variant{
					Price:       price,
					BuyURL:      raw.SourceURL,
					Marketplace: marketplace,
					GrindType:   grindType,
				}
			}
		}
	}

	// If no weight variants were extracted (or all were invalid), use the main product info
	if len(variants) == 0 {
		grams, _ := ExtractFirstWeightGrams(raw.Title)
		if grams == 0 {
			grams, _ = ExtractFirstWeightGrams(raw.Weight)
		}
		if grams == 0 {
			grams = -1 // Unknown weight placeholder
		}

		variants[grams] = model.Variant{
			Price:       raw.Price,
			BuyURL:      raw.SourceURL,
			Marketplace: marketplace,
		}
	}

	return variants
}

// extractGrindType checks if a variant name indicates a grind type.
func extractGrindType(name string) string {
	lower := strings.ToLower(name)
	switch {
	case strings.Contains(lower, "bubuk") || strings.Contains(lower, "ground"):
		return "ground"
	case strings.Contains(lower, "biji") || strings.Contains(lower, "whole bean") || strings.Contains(lower, "bean"):
		return "whole_bean"
	default:
		return ""
	}
}

// mapSourceToMarketplace maps source identifiers to marketplace label.
func mapSourceToMarketplace(source string) string {
	switch source {
	case "tokopedia":
		return "tokopedia"
	case "shopify":
		return "web"
	default:
		return "web"
	}
}

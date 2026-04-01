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

// buildVariants constructs the weight-keyed variants map from raw product data.
func buildVariants(raw *model.RawProduct) map[string]model.Variant {
	variants := make(map[string]model.Variant)
	marketplace := mapSourceToMarketplace(raw.Source)

	// If raw has explicit variants from the page
	if len(raw.Variants) > 0 {
		for _, rv := range raw.Variants {
			// Try to extract weight from variant name
			weightKey, _ := ExtractFirstWeight(rv.Name)

			if weightKey == "" {
				// Check if it's a grind type variant (biji/bubuk)
				// Per user: extract grind type if it comes from variant
				grindType := extractGrindType(rv.Name)
				if grindType != "" {
					// Use the weight from the title if available
					titleWeight, _ := ExtractFirstWeight(raw.Title)
					if titleWeight == "" {
						titleWeight = "unknown"
					}

					// Append grind info to weight key
					key := titleWeight
					existing, exists := variants[key]
					if exists {
						// Update existing variant with grind info
						existing.GrindType = grindType
						variants[key] = existing
					} else {
						price := rv.Price
						if price == 0 {
							price = raw.Price
						}
						variants[key] = model.Variant{
							Price:       price,
							BuyURL:      raw.SourceURL,
							Marketplace: marketplace,
							GrindType:   grindType,
						}
					}
					continue
				}
				continue // Skip variants without weight or grind info
			}

			price := rv.Price
			if price == 0 {
				price = raw.Price
			}

			variants[weightKey] = model.Variant{
				Price:       price,
				BuyURL:      raw.SourceURL,
				Marketplace: marketplace,
			}
		}
	}

	// If no weight variants were extracted, use the main product info
	if len(variants) == 0 {
		weightKey, _ := ExtractFirstWeight(raw.Title)
		if weightKey == "" {
			weightKey, _ = ExtractFirstWeight(raw.Weight)
		}
		if weightKey == "" {
			weightKey = "unknown"
		}

		variants[weightKey] = model.Variant{
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
	case "shopee":
		return "shopee"
	case "shopify":
		return "web"
	default:
		return "web"
	}
}

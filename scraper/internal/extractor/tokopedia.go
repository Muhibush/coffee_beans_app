package extractor

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/go-rod/rod"

	"github.com/coffee-beans-app/scraper/internal/browser"
	"github.com/coffee-beans-app/scraper/internal/model"
)

// TokopediaExtractor handles product extraction from Tokopedia.
type TokopediaExtractor struct{}

func (e *TokopediaExtractor) Name() string { return "tokopedia" }

func (e *TokopediaExtractor) CanHandle(productURL string) bool {
	return strings.Contains(productURL, "tokopedia.com") ||
		strings.Contains(productURL, "tk.tokopedia.com")
}

func (e *TokopediaExtractor) CanHandleBulk(storeURL string) bool {
	return e.CanHandle(storeURL)
}

func (e *TokopediaExtractor) ExtractURLs(ctx context.Context, storeURL string, maxProducts int) ([]model.BulkProduct, error) {
	log.Printf("[tokopedia] Extracting bulk URLs from: %s", storeURL)

	// Determine username/shop name from URL to filter out other links
	parsed, err := url.Parse(storeURL)
	if err != nil {
		return nil, fmt.Errorf("invalid URL: %w", err)
	}
	parts := strings.Split(strings.Trim(parsed.Path, "/"), "/")
	var username string
	if len(parts) > 0 {
		username = parts[0]
	}
	shopPattern := username

	// Clean base URL for product listing
	baseURL := strings.TrimRight(storeURL, "/")
	if !strings.Contains(baseURL, "/product") {
		baseURL += "/product"
	}

	pageNumber := 1
	productsMap := make(map[string]bool)
	var products []model.BulkProduct

	b := browser.Get()

	// Multi-page sequential probing loop
	for {
		// Graceful exit check
		if err := ctx.Err(); err != nil {
			log.Printf("[tokopedia] Stopping crawl: %v", err)
			return products, err
		}

		// Construct the URL for the Produk tab with full pagination.
		// Tokopedia's store pages have tabs: Beranda (home), Produk (all products), Ulasan (reviews).
		// We need the Produk tab which uses "tab=product" or the correct sort/filter parameters.
		currentURL := fmt.Sprintf("%s/page/%d?ob=5&page=%d&perpage=80", baseURL, pageNumber, pageNumber)
		log.Printf("[tokopedia] Probing page %d: %s", pageNumber, currentURL)

		// Open a FRESH stealth page for each page probe.
		page, err := b.NavigateWithStealth(ctx, currentURL)
		if err != nil {
			log.Printf("[tokopedia] Failed to navigate to page %d: %v", pageNumber, err)
			break
		}


		// Wait for the product grid to appear (up to 10 seconds)
		log.Printf("[tokopedia] Page %d: Waiting for product grid to render...", pageNumber)
		_, waitErr := page.Timeout(10 * time.Second).Element(`div[data-testid="master-product-card"], a[href*="` + shopPattern + `"]`)
		if waitErr != nil {
			log.Printf("[tokopedia] Page %d: No product grid found after 10s wait, may be empty page", pageNumber)
		}

		// Extra settle time for JS hydration
		select {
		case <-ctx.Done():
			page.Close()
			return products, ctx.Err()
		case <-time.After(3 * time.Second):
		}

		// Debug: log the page state with full window dimension info
		res, _ := page.Eval(`() => ({
			scrollHeight: document.body.scrollHeight,
			innerWidth: window.innerWidth,
			innerHeight: window.innerHeight,
			outerWidth: window.outerWidth,
			outerHeight: window.outerHeight,
			devicePixelRatio: window.devicePixelRatio,
			title: document.title,
			allLinks: document.querySelectorAll('a').length,
			shopLinks: document.querySelectorAll('a[href*="` + shopPattern + `"]').length,
			productCards: document.querySelectorAll('div[data-testid="master-product-card"]').length,
			productGrids: document.querySelectorAll('[data-testid="divSRPContentProducts"]').length,
			htmlLength: document.documentElement.outerHTML.length,
		})`)
		if res != nil {
			type debugInfo struct {
				ScrollHeight    int    `json:"scrollHeight"`
				InnerWidth      int    `json:"innerWidth"`
				InnerHeight     int    `json:"innerHeight"`
				OuterWidth      int    `json:"outerWidth"`
				OuterHeight     int    `json:"outerHeight"`
				DevicePixelRatio float64 `json:"devicePixelRatio"`
				Title           string `json:"title"`
				AllLinks        int    `json:"allLinks"`
				ShopLinks       int    `json:"shopLinks"`
				ProductCards    int    `json:"productCards"`
				ProductGrids    int    `json:"productGrids"`
				HTMLLength      int    `json:"htmlLength"`
			}
			var info debugInfo
			res.Value.Unmarshal(&info)
			log.Printf("[tokopedia] Page %d debug: scroll=%d, window=%dx%d, outer=%dx%d, dpr=%.1f, allLinks=%d, shopLinks=%d, cards=%d, grids=%d, html=%d bytes",
				pageNumber, info.ScrollHeight, info.InnerWidth, info.InnerHeight, info.OuterWidth, info.OuterHeight,
				info.DevicePixelRatio, info.AllLinks, info.ShopLinks, info.ProductCards, info.ProductGrids, info.HTMLLength)
		}

		// Save debug screenshot for page 1 so we can inspect what the browser sees
		if pageNumber == 1 {
			screenshotData, screenshotErr := page.Screenshot(true, nil)
			if screenshotErr == nil {
				screenshotPath := "/tmp/tokopedia_debug_page1.png"
				if writeErr := os.WriteFile(screenshotPath, screenshotData, 0644); writeErr == nil {
					log.Printf("[tokopedia] Page 1 screenshot saved to %s (%d bytes)", screenshotPath, len(screenshotData))
				} else {
					log.Printf("[tokopedia] Page 1 screenshot captured (%d bytes) but failed to save: %v", len(screenshotData), writeErr)
				}
			}
		}

		// EXTRACTION STRATEGY:
		// 1. First try extracting from embedded SSR data (__NEXT_DATA__, inline JSON)
		//    — this contains ALL products server-side, regardless of rendering
		// 2. If that fails, fall back to scrolling + DOM extraction

		log.Printf("[tokopedia] Page %d: Attempting SSR data extraction...", pageNumber)
		productsOnThisPageCount := 0

		// Try SSR extraction: Tokopedia embeds product data in script tags
		ssrResults, ssrErr := page.Eval(`() => {
			const urls = new Set();
			const products = [];
			const shopPat = '` + shopPattern + `';

			// Strategy 1: Extract from __NEXT_DATA__ (Next.js SSR data)
			const nextData = document.querySelector('script#__NEXT_DATA__');
			if (nextData) {
				try {
					const text = nextData.textContent;
					// Find all URLs matching the shop pattern
					const urlRegex = new RegExp('https?://www\\.tokopedia\\.com/' + shopPat + '/[^"\\s]+', 'g');
					const matches = text.match(urlRegex) || [];
					matches.forEach(u => {
						if (!u.includes('/review') && !u.includes('/etalase') && !u.endsWith('/product')) {
							urls.add(u);
						}
					});
				} catch(e) {}
			}

			// Strategy 2: Scan ALL script tags and inline JSON for product URLs
			document.querySelectorAll('script').forEach(s => {
				const text = s.textContent || '';
				if (text.length < 100) return; // skip tiny scripts
				const urlRegex = new RegExp('https?://www\\.tokopedia\\.com/' + shopPat + '/[^"\\s\\\\]+', 'g');
				const matches = text.match(urlRegex) || [];
				matches.forEach(u => {
					// Clean up escaped characters
					const clean = u.replace(/\\u002F/g, '/').replace(/\\\//g, '/');
					if (!clean.includes('/review') && !clean.includes('/etalase') && 
						!clean.includes('/flash-sale') && !clean.endsWith('/product') &&
						!clean.endsWith(shopPat) && !clean.endsWith(shopPat + '/') &&
						clean.length > ('https://www.tokopedia.com/' + shopPat + '/').length + 5) {
						urls.add(clean);
					}
				});
			});

			// Strategy 3: Also grab from visible DOM links as a fallback
			document.querySelectorAll('a[href*="' + shopPat + '"], a[href*="/p/"]').forEach(el => {
				const href = el.href;
				if (!href) return;
				const lowHref = href.toLowerCase();
				if (lowHref.includes('/review') || lowHref.includes('/etalase') || 
					lowHref.includes('/flash-sale') || lowHref.endsWith('/product') ||
					lowHref.endsWith(shopPat) || lowHref.endsWith(shopPat + '/')) return;
				if (lowHref.includes(shopPat) || lowHref.includes('/p/')) {
					urls.add(href);
				}
			});

			// Convert to array with titles (use URL slug as title if needed)
			urls.forEach(u => {
				// Clean the URL, strip query params before we use it
				const urlObj = u.split('?')[0];
				
				// Extra filter for non-product URLs
				if (urlObj.includes('/sold') || urlObj.includes('/product/page')) return;

				// Extract title from URL slug
				const parts = urlObj.split('/');
				const slug = parts[parts.length - 1] || parts[parts.length - 2] || '';
				const title = slug.split('-').filter(w => w.length > 0 && !w.match(/^[0-9a-f]{10,}$/)).join(' ');
				
				if (title.length > 3) {
					products.push({ url: urlObj, title: title });
				}
			});

			return { products: products, source: urls.size > 0 ? 'ssr+dom' : 'none' };
		}`)

		if ssrErr == nil {
			type ssrProduct struct {
				URL   string `json:"url"`
				Title string `json:"title"`
			}
			type ssrResult struct {
				Products []ssrProduct `json:"products"`
				Source   string       `json:"source"`
			}
			var items ssrResult
			ssrResults.Value.Unmarshal(&items)
			log.Printf("[tokopedia] Page %d: SSR extraction found %d URLs (source: %s)", pageNumber, len(items.Products), items.Source)

			for _, item := range items.Products {
				href := item.URL
				if u, err := url.Parse(href); err == nil {
					u.RawQuery = ""
					u.Fragment = ""
					href = u.String()
				}

				if !productsMap[href] {
					productsMap[href] = true
					// Try to get a better title from the DOM for this URL
					title := item.Title
					products = append(products, model.BulkProduct{
						Title: title,
						URL:   href,
					})
					productsOnThisPageCount++
				}
			}
		} else {
			log.Printf("[tokopedia] Page %d: SSR extraction failed: %v", pageNumber, ssrErr)
		}

		// Close this page — we'll open a new one for the next probe
		page.Close()

		log.Printf("[tokopedia] Page %d finished. Found %d new products (Total so far: %d)", pageNumber, productsOnThisPageCount, len(products))

		// Stop condition: if this page yielded ZERO new products after deep scrolling,
		// we have reached the end of the store catalog.
		if productsOnThisPageCount == 0 {
			log.Printf("[tokopedia] Page %d returned no new products. Ending catalog crawl.", pageNumber)
			break
		}

		pageNumber++
		if maxProducts > 0 && len(products) >= maxProducts {
			break
		}
	}

	// Cleanup results if we exceeded maxProducts
	if maxProducts > 0 && len(products) > maxProducts {
		products = products[:maxProducts]
	}

	log.Printf("[tokopedia] Extracted %d product items successfully", len(products))
	return products, nil
}

func (e *TokopediaExtractor) Extract(ctx context.Context, productURL string) (*model.RawProduct, error) {
	log.Printf("[tokopedia] Extracting from: %s", productURL)

	b := browser.Get()
	page, err := b.NavigateWithStealth(ctx, productURL)
	if err != nil {
		return nil, fmt.Errorf("failed to navigate: %w", err)
	}
	defer page.Close() // Use Close() instead of MustClose() to avoid panicking on timeout

	// Wait extra for Tokopedia's JS to render — it's heavy
	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	case <-time.After(3 * time.Second):
	}

	// Get the final URL after redirects (handles tk.tokopedia.com short links)
	info, err := page.Info()
	if err != nil {
		log.Printf("[tokopedia] Failed to get page info: %v", err)
		return nil, fmt.Errorf("failed to get page info: %w", err)
	}
	finalURL := info.URL
	log.Printf("[tokopedia] Final URL: %s", finalURL)

	// Strategy 1: JSON-LD for base metadata
	raw, err := e.extractFromJSONLD(page)
	if err != nil || raw == nil || raw.Title == "" {
		log.Printf("[tokopedia] JSON-LD extraction failed or empty, using empty base: %v", err)
		raw = &model.RawProduct{}
	} else {
		log.Printf("[tokopedia] Base metadata extracted via JSON-LD: %s", raw.Title)
	}

	// Strategy 2: DOM for variants and potential gaps
	domData, err := e.extractFromDOM(page)
	if err != nil {
		if raw.Title == "" {
			return nil, fmt.Errorf("extraction failed: JSON-LD failed and DOM failed: %w", err)
		}
		log.Printf("[tokopedia] DOM extraction failed, but using JSON-LD data: %v", err)
	} else {
		// Merge DOM data into JSON-LD data if JSON-LD missed anything
		if raw.Title == "" {
			raw.Title = domData.Title
		}
		if raw.Description == "" {
			raw.Description = domData.Description
		}
		if raw.Price == 0 {
			raw.Price = domData.Price
		}
		if len(raw.ImageURLs) == 0 && len(domData.ImageURLs) > 0 {
			raw.ImageURLs = domData.ImageURLs
		}
		// ALWAYS take variants from DOM if available
		if len(domData.Variants) > 0 {
			raw.Variants = domData.Variants
		}
	}

	raw.SourceURL = finalURL
	return raw, nil
}

// jsonLDProduct represents the Schema.org Product structure from JSON-LD.
type jsonLDProduct struct {
	Type        string        `json:"@type"`
	Name        string        `json:"name"`
	Description string        `json:"description"`
	Image       interface{}   `json:"image"` // can be string or []string
	Offers      *jsonLDOffers `json:"offers"`
}

type jsonLDOffers struct {
	Type          string      `json:"@type"`
	Price         interface{} `json:"price"` // can be string or number
	PriceCurrency string      `json:"priceCurrency"`
	LowPrice      interface{} `json:"lowPrice"`
	HighPrice     interface{} `json:"highPrice"`
}

func (e *TokopediaExtractor) extractFromJSONLD(page *rod.Page) (*model.RawProduct, error) {
	// Execute JS to find and return JSON-LD content
	res, err := page.Eval(`() => {
		const scripts = document.querySelectorAll('script[type="application/ld+json"]');
		const results = [];
		scripts.forEach(s => {
			try {
				const data = JSON.parse(s.textContent);
				if (data['@type'] === 'Product' || (Array.isArray(data['@graph']) && data['@graph'].some(g => g['@type'] === 'Product'))) {
					results.push(s.textContent);
				}
			} catch(e) {}
		});
		return results.length > 0 ? results[0] : '';
	}`)
	if err != nil {
		return nil, fmt.Errorf("failed to evaluate JSON-LD: %w", err)
	}
	result := res.Value.Str()

	if result == "" {
		return nil, fmt.Errorf("no Product JSON-LD found")
	}

	// Try parsing as direct Product
	var product jsonLDProduct
	if err := json.Unmarshal([]byte(result), &product); err != nil {
		// Try parsing as @graph container
		var graphContainer struct {
			Graph []json.RawMessage `json:"@graph"`
		}
		if err2 := json.Unmarshal([]byte(result), &graphContainer); err2 != nil {
			return nil, fmt.Errorf("failed to parse JSON-LD: %w", err)
		}
		for _, item := range graphContainer.Graph {
			var candidate jsonLDProduct
			if err := json.Unmarshal(item, &candidate); err == nil && candidate.Type == "Product" {
				product = candidate
				break
			}
		}
	}

	if product.Name == "" {
		return nil, fmt.Errorf("JSON-LD Product has no name")
	}

	raw := &model.RawProduct{
		Title:       product.Name,
		Description: product.Description,
		ImageURLs:   parseJSONLDImage(product.Image),
		Currency:    "IDR",
	}

	// Parse price from offers
	if product.Offers != nil {
		raw.Price = parseJSONLDPrice(product.Offers.Price)
		if raw.Price == 0 {
			raw.Price = parseJSONLDPrice(product.Offers.LowPrice)
		}
		if product.Offers.PriceCurrency != "" {
			raw.Currency = product.Offers.PriceCurrency
		}
	}

	return raw, nil
}

func (e *TokopediaExtractor) extractFromDOM(page *rod.Page) (*model.RawProduct, error) {
	// Extract using DOM selectors
	res, err := page.Eval(`() => {
		const getTextBySelector = (sel) => {
			const el = document.querySelector(sel);
			return el ? el.textContent.trim() : '';
		};

		const getAttrBySelector = (sel, attr) => {
			const el = document.querySelector(sel);
			return el ? el.getAttribute(attr) || '' : '';
		};

		// Title
		let title = getTextBySelector('h1[data-testid="lblPDPDetailProductName"]') ||
			getTextBySelector('h1.css-1320e5d') ||
			getTextBySelector('h1') ||
			getAttrBySelector('meta[property="og:title"]', 'content');

		// Price
		let price = getTextBySelector('[data-testid="lblPDPDetailProductPrice"]') ||
			getTextBySelector('.price') ||
			'';

		// Image
		let image = getAttrBySelector('[data-testid="PDPImageMain"] img', 'src') ||
			getAttrBySelector('.css-1c345mg img', 'src') ||
			getAttrBySelector('meta[property="og:image"]', 'content') ||
			'';

		// Description
		let desc = getTextBySelector('[data-testid="lblPDPDescriptionProduk"]') ||
			getAttrBySelector('meta[property="og:description"]', 'content') ||
			'';

		// Variants (weight/grind options)
		let variants = [];
		const variantElements = document.querySelectorAll('[data-testid^="btnPDPVariant"]');
		variantElements.forEach(el => {
			const text = el.textContent.trim();
			if (text) {
				variants.push({
					name: text,
					price: 0
				});
			}
		});

		return JSON.stringify({
			title: title,
			price: price,
			image: image,
			description: desc,
			variants: variants
		});
	}`)
	if err != nil {
		return nil, fmt.Errorf("failed to evaluate DOM data: %w", err)
	}
	result := res.Value.Str()

	var domData struct {
		Title       string `json:"title"`
		Price       string `json:"price"`
		Image       string `json:"image"`
		Description string `json:"description"`
		Variants    []struct {
			Name  string `json:"name"`
			Price int64  `json:"price"`
		} `json:"variants"`
	}

	if err := json.Unmarshal([]byte(result), &domData); err != nil {
		return nil, fmt.Errorf("failed to parse DOM data: %w", err)
	}

	if domData.Title == "" {
		return nil, fmt.Errorf("could not extract title from DOM")
	}

	raw := &model.RawProduct{
		Title:       domData.Title,
		Description: domData.Description,
		Price:       parsePriceString(domData.Price),
		Currency:    "IDR",
	}

	if domData.Image != "" {
		raw.ImageURLs = []string{domData.Image}
	}

	for _, v := range domData.Variants {
		raw.Variants = append(raw.Variants, model.RawVariant{
			Name:  v.Name,
			Price: v.Price,
		})
	}

	return raw, nil
}

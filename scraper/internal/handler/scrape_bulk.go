package handler

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/coffee-beans-app/scraper/internal/extractor"
	"github.com/coffee-beans-app/scraper/internal/model"
)

// BulkScrapeTimeout is the maximum time allowed for a bulk scrape operation.
// Bulk scraping can be slow due to infinite scrolling.
const BulkScrapeTimeout = 120 * time.Second

// BulkScrapeHandler handles POST /scrape-bulk requests.
func BulkScrapeHandler(w http.ResponseWriter, r *http.Request) {
	// Only accept POST
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "only POST method is accepted")
		return
	}

	// Parse request body
	var req model.BulkScrapeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body: "+err.Error())
		return
	}

	if req.URL == "" {
		writeError(w, http.StatusBadRequest, "url field is required")
		return
	}

	log.Printf("[handler] Bulk Scrape request for: %s (max_products: %d)", req.URL, req.MaxProducts)

	// Create a context with timeout
	ctx, cancel := context.WithTimeout(r.Context(), BulkScrapeTimeout)
	defer cancel()

	// Route to the appropriate bulk extractor
	urls, sourceName, err := extractor.RouteBulk(ctx, req.URL, req.MaxProducts)
	if err != nil {
		log.Printf("[handler] Bulk Extraction failed: %v", err)
		writeJSON(w, http.StatusInternalServerError, model.BulkScrapeResponse{
			Success: false,
			Error:   "bulk extraction failed: " + err.Error(),
		})
		return
	}

	log.Printf("[handler] Successfully extracted %d URLs from%s", len(urls), sourceName)

	// Return success response
	writeJSON(w, http.StatusOK, model.BulkScrapeResponse{
		Success:      true,
		URLs:         urls,
		ProductCount: len(urls),
	})
}

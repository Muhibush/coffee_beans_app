package handler

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/coffee-beans-app/scraper/internal/extractor"
	"github.com/coffee-beans-app/scraper/internal/model"
	"github.com/coffee-beans-app/scraper/internal/normalizer"
)

// ScrapeTimeout is the maximum time allowed for a single scrape operation.
const ScrapeTimeout = 60 * time.Second

// ScrapeHandler handles POST /scrape requests.
func ScrapeHandler(w http.ResponseWriter, r *http.Request) {
	// Only accept POST
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "only POST method is accepted")
		return
	}

	// Parse request body
	var req model.ScrapeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body: "+err.Error())
		return
	}

	if req.URL == "" {
		writeError(w, http.StatusBadRequest, "url field is required")
		return
	}

	log.Printf("[handler] Scrape request for: %s", req.URL)

	// Create a context with timeout
	ctx, cancel := context.WithTimeout(r.Context(), ScrapeTimeout)
	defer cancel()

	// Route to the appropriate extractor
	rawProduct, err := extractor.Route(ctx, req.URL)
	if err != nil {
		log.Printf("[handler] Extraction failed: %v", err)
		writeError(w, http.StatusInternalServerError, "extraction failed: "+err.Error())
		return
	}

	// Normalize the raw data
	bean := normalizer.Normalize(rawProduct)

	log.Printf("[handler] Successfully scraped: %s (%s)", bean.CleanName, bean.Source)

	// Return success response
	writeJSON(w, http.StatusOK, model.ScrapeResponse{
		Success: true,
		Data:    bean,
	})
}

// HealthHandler responds to GET /health for liveness checks.
func HealthHandler(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{
		"status": "ok",
		"time":   time.Now().Format(time.RFC3339),
	})
}

func writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("[handler] Failed to encode response: %v", err)
	}
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, model.ScrapeResponse{
		Success: false,
		Error:   message,
	})
}

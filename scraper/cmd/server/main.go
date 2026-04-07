package main

import (
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/coffee-beans-app/scraper/internal/browser"
	"github.com/coffee-beans-app/scraper/internal/handler"
)

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, Origin")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Set up routes
	mux := http.NewServeMux()
	mux.HandleFunc("/scrape", handler.ScrapeHandler)
	mux.HandleFunc("/scrape-bulk", handler.BulkScrapeHandler)
	mux.HandleFunc("/health", handler.HealthHandler)

	// Graceful shutdown
	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
		<-sigChan

		log.Println("[server] Shutting down...")
		browser.Get().Close()
		os.Exit(0)
	}()

	addr := ":" + port
	log.Printf("[server] Coffee Beans Scraper starting on http://localhost%s", addr)
	log.Printf("[server] POST /scrape       — Scrape a single product URL")
	log.Printf("[server] POST /scrape-bulk  — Scrape multiple product URLs from a store")
	log.Printf("[server] GET  /health       — Health check")

	if err := http.ListenAndServe(addr, corsMiddleware(mux)); err != nil {
		log.Fatalf("[server] Failed to start: %v", err)
	}
}

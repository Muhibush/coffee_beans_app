---
name: Coffee Beans Scraper
description: Documentation and instructions on how to use and maintain the Go scraper service
---

# Coffee Beans Scraper Skill

The Scraper is a Go-based service that uses `go-rod` to extract product data from e-commerce stores (like Tokopedia and Shopify) and normalize it.

## API Endpoints
- `POST /scrape` - Scrapes a single product URL
- `POST /scrape-bulk` - Scrapes multiple product URLs from a store
- `GET /health` - Health check

## How to Run the Scraper Service

1. Change directory to the scraper tool:
   ```bash
   cd scraper
   ```

2. Run the main server file:
   ```bash
   go run cmd/server/main.go
   ```

By default it runs on `http://localhost:8080`. You can configure the port by exporting the `PORT` environment variable.

## Development

The scraper is modularly designed under the `internal/` directory:
- `internal/handler` - API route definitions and request/response parsing
- `internal/extractor` - Contains store-specific metadata parsing logic (Tokopedia, Shopify, etc.)
- `internal/normalizer` - Takes raw scraped text and cleans it up (extracts weight, resolves processing methods, etc.)
- `internal/browser` - Reusable `go-rod` headless browser instance manager

Always ensure you add adequate tests and keep selectors updated, as the DOM for these stores changes often.

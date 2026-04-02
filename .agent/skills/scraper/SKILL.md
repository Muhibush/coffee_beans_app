---
name: Coffee Beans Scraper
description: Documentation and instructions on how to use and maintain the Go scraper service
---

# Coffee Beans Scraper Skill

The Scraper is a Go-based service that uses `go-rod` to extract product data from e-commerce stores (like Tokopedia and Shopify) and normalize it.

## API Endpoints

The scraper exposes REST endpoints to trigger extractions. By default, the server runs on `http://localhost:8080`.

### 1. Single Product Scrape (`POST /scrape`)
Extracts and normalizes data from a single product page (e.g., a specific coffee bean on Tokopedia).

**Request:**
```bash
curl -X POST http://localhost:8080/scrape \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.tokopedia.com/roastery/ethiopia-guji-250g"}'
```

**What it does:**
1. Opens a headless browser (`go-rod`) to bypass bot protection.
2. Extracts raw HTML/JSON data specific to the marketplace (Tokopedia or Shopify).
3. Normalizes the output into a structured `ScrapedBean` object (cleans product names, standardizes weights into `g` or `kg`, extracts processing methods and tasting notes).

### 2. Bulk Store Scrape (`POST /scrape-bulk`)
Extracts multiple product URLs from a store's main catalog or index page.

**Request:**
```bash
curl -X POST http://localhost:8080/scrape-bulk \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.tokopedia.com/roastery", "max_products": 10}'
```

**What it does:**
1. Navigates to the main roastery store page.
2. Identifies product grid elements and extracts valid product links.
3. Scrolls and paginates if necessary to collect up to `max_products`.
4. Returns an array of URLs that can subsequently be fed into the `/scrape` endpoint.

### 3. Health Check (`GET /health`)
Verifies the service is running.

**Request:**
```bash
curl http://localhost:8080/health
```

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

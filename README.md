# Coffee Beans App

A high-performance, mobile-first web platform (MWeb) designed to aggregate and normalize specialty coffee data from various Indonesian roasteries and marketplaces, providing a distraction-free catalog for users and zero-effort management for roasteries.

## Architecture

Distributed micro-frontend/micro-service model:
- **Frontend**: Flutter Web (CanvasKit/WASM)
- **Database/Auth**: Supabase (PostgreSQL)
- **Scraper Service**: Go (go-rod and goquery)

## Scraper Service

The Scraper service is a Go-based normalization engine used to aggregate marketplace data from Tokopedia, Shopee, Shopify, and local roasteries.

### Running the Scraper

1. Navigate to the `scraper` folder:
   ```bash
   cd scraper
   ```
2. Start the service:
   ```bash
   go run cmd/server/main.go
   ```

### Scraper API Endpoints

- `POST /scrape` - Scrapes a single product URL.
- `POST /scrape-bulk` - Scrapes multiple product URLs from a store.
- `GET /health` - Health check.

The scraper engine parses data, standardizes weights into `g` and `kg`, cleans product names from promotional noise, and normalizes processing methods.

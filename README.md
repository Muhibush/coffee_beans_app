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

The scraper exposes REST endpoints to trigger extractions. By default, the server runs on `http://localhost:8080`.

#### 1. Single Product Scrape (`POST /scrape`)
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

#### 2. Bulk Store Scrape (`POST /scrape-bulk`)
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

#### 3. Health Check (`GET /health`)
Verifies the service is running.

**Request:**
```bash
curl http://localhost:8080/health
```

### Data Pipeline
The scraper engine parses data, standardizes weights into `g` and `kg`, cleans product names from promotional noise, and normalizes processing methods. This data is then returned for deep-merge upserting into Supabase using PostgreSQL `jsonb_set` based on `roastery_id + slugify(clean_name)` fingerprinting to prevent duplicates across multiple variants (like 250g and 1kg sizes).

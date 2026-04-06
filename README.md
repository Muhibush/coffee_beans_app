# ☕ Coffee Beans App

[![Platform: Flutter Web](https://img.shields.io/badge/Platform-Flutter%20Web-02569B?logo=flutter)](https://flutter.dev)
[![Engine: Go](https://img.shields.io/badge/Engine-Go-00ADD8?logo=go)](https://go.dev)
[![Database: Supabase](https://img.shields.io/badge/Database-Supabase-3ECF8E?logo=supabase)](https://supabase.com)
[![Deployment: Vercel](https://img.shields.io/badge/Deployment-Vercel-000000?logo=vercel)](https://vercel.com)

**Discover specialty coffee from Indonesia's finest roasteries.**

Coffee Beans App is a high-performance, mobile-first web platform (MWeb) designed to aggregate and normalize specialty coffee data from various Indonesian roasteries and marketplaces (Tokopedia, Shopee, Shopify stores) into one **distraction-free catalog**.

---

## 🚀 The Problem & Solution

### The Fragmented Coffee Scene
Indonesian specialty coffee buyers currently face fragmented listings, noisy product titles filled with promotional trash ("PROMO MURAH READY..."), and duplicate entries where the same bean sold in different weights appears as separate products.

### Our Intelligent Approach
- **Aggregation**: Leverages a Go-based scraper to pull data from multiple sources.
- **Normalization**: Standardizes names, weights, and metadata (processing methods, variety, etc.).
- **Master-Variant Architecture**: Merges multiple weights (100g, 200g, 1kg) under a single "master bean" entry.
- **Unified Discovery**: Advanced filtering by variety, process, and tasting notes across all roasteries.

---

## 🏗️ Technical Stack

- **Frontend**: Flutter Web (CanvasKit/WASM) using **BLoC** for state management.
- **Backend/Scraper**: **Go (Golang)** with `go-rod` (headless) and `goquery`.
- **Database & Auth**: **Supabase** (PostgreSQL) with Row Level Security (RLS).
- **Routing**: **Go Router** managing a Shell + Detail navigation split.
- **Infrastructure**: **Vercel** for frontend delivery and **GitHub Actions** for automated bulk scraping.

---

## 🎨 Design System & UI/UX

The app follows a "Premium Indonesian Specialty Coffee Aggregator" identity:
- **Philosophy**: Distraction-free, mobile-native feel, and native-app-like experience.
- **Typography**: Strictly uses the **Inter** font family.
- **Format**: Prices are formatted in Indonesian Rupiah (e.g., `Rp 125.000`).
- **Color Palette**:
  - `Primary`: #6F4E37 (Coffee Brown)
  - `Surface`: #FBF8F4 (Warm Off-white)
  - `Accent`: #2E7D32 (Success Green)

---

## 🗄️ Database Strategy & Schema

### The "Fingerprint" Pattern
To prevent duplicates, each bean is assigned a unique `fingerprint`:
`roastery_id + slugify(clean_name)`
This ensures that "Aceh Gayo 250g" and "Aceh Gayo 500g" are merged into a single entry.

### Primary Tables
- **`roasteries`**: Brand profiles with `social_links` (JSONB).
- **`beans`**: Product data using `variants` (JSONB) to map multiple storefront links and prices to a single record.
- **`filter_metadata`**: Dynamic source for UI filter chips (Variety, Process, Origin, Notes).

---

## 🕸️ Scraper Service (Go)

The Scraper service is the normalization engine. It performs extraction via headless browsers to bypass bot protection and standardizes the output.

### API Endpoints
The scraper runs on `http://localhost:8080` by default.

- **`POST /scrape`**: Extracts data from a single product URL.
- **`POST /scrape-bulk`**: Extracts multiple product URLs from a store index page.
- **`GET /health`**: Health check.

### Running the Scraper
```bash
cd scraper
go run cmd/server/main.go
```

---

## 🛠️ Local Development & Setup

### Prerequisites
- Flutter SDK (3.x+)
- Go (1.21+)
- Supabase CLI

### Environment Configuration
1.  **Go Service**: Create a `.env` file in the `scraper` directory.
2.  **Flutter App**: Configure `web/assets/config.json`.

```env
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE=your_service_role # (Internal scraper use only)
```

### Database Setup
Refer to the [Supabase Setup Guide](docs/supabase_setup_guide.md) to apply migrations and RLS policies.

---

## 📝 License & Copyright
This project is proprietary. Developed for the Indonesian Specialty Coffee Scene. © 2026.

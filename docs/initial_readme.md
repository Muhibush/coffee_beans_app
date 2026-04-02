# Coffee Beans App: The Specialty Coffee Discovery Engine

**Coffee Beans App** is a high-performance, mobile-first web platform (MWeb) designed to aggregate and normalize specialty coffee data from various Indonesian roasteries and marketplaces. 

By leveraging a **Master-Variant architecture** and an intelligent **Go-based normalization engine**, it provides users with a clean, distraction-free catalog while offering roasteries a "zero-effort" management experience.

---

## 🏗️ System Architecture

The ecosystem is built on a distributed micro-frontend/micro-service model:

* **Frontend:** Flutter Web (CanvasKit/WASM) — State managed via **BLoC**.
* **Database & Auth:** **Supabase** (PostgreSQL) with Row Level Security (RLS).
* **Scraper Service:** **Go (Golang)** utilizing `go-rod` (headless) and `goquery`.
* **Infrastructure:** **Vercel** (Global Edge CDN) + **GitHub Actions** (Scheduled Bulk Scraping).

---

## 🚀 Key Features

### 👤 User Experience
* **Clean Discovery:** Every bean is a "Master Product." No duplicate listings just because of weight differences.
* **Advanced Filtering:** Dynamic filtering for **Variety** (Typica, Sigarar Utang), **Process** (Natural, Anaerobic), and **Origin**.
* **Marketplace Aggregator:** Compare prices and availability across Tokopedia, Shopee, and direct WhatsApp links in one view.
* **Roastery Directory:** Searchable database of Indonesian roasteries by name and city.

### 🛡️ Admin Suite
* **Zero-Effort Entry:** Paste a marketplace URL $\rightarrow$ Go Scraper normalizes data $\rightarrow$ Bean is created as a `Draft`.
* **Bulk Management:** Multi-select interface to **Publish**, **Draft**, or **Unpublish** hundreds of beans across roasteries.
* **Multi-tenant Control:** Manage independent roastery profiles, social links (JSONB), and active status.

---

## 🗄️ Database Strategy

The core of the application relies on PostgreSQL's **JSONB** and **Array** types to handle the inherent messiness of marketplace data.

### **The "Fingerprint" Pattern**
To prevent duplicates, each bean is assigned a unique `fingerprint`:
`roastery_id` + `slugify(clean_name)`
This ensures that "Aceh Gayo 250g" and "Aceh Gayo 500g" are merged into a single entry.

### **Schema Summary**
| Table | Purpose | Key Columns |
| :--- | :--- | :--- |
| `roasteries` | Brand profiles | `social_links` (JSONB) |
| `beans` | Product data | `variants` (JSONB), `variety` (TEXT[]), `notes` (TEXT[]) |
| `filter_metadata` | UI Filter source | `category`, `label`, `is_active` |

---

## 🕸️ The Go Normalization Engine

The scraper acts as a data refinery, moving through a 3-step pipeline:

1.  **Extraction:** Uses `go-rod` with a stealth plugin to bypass marketplace anti-bot measures (Cloudflare/PerimeterX).
2.  **Standardization:** * **Weight:** Regex `(?i)\s*(\d+)\s*(gram|gr|g|kg)` maps all units to a standard `g` or `kg` key.
    * **Noise Removal:** Strips marketing fluff (e.g., "PROMO", "READY", "MURAH") to create a `clean_name`.
3.  **Deep-Merge Upsert:** Uses the `jsonb_set` function to inject new marketplace links into specific weight keys within the `variants` column without overwriting existing data.

---

## 🛣️ Routing Structure (`go_router`)

| Path | Access | Description |
| :--- | :--- | :--- |
| `/` | Public | Landing page & About info. |
| `/beans` | Public | The main searchable catalog. |
| `/roasteries` | Public | Roastery directory (Search by name/city). |
| `/admin-login` | Public | Supabase Auth entry point. |
| `/admin/roastery` | Admin | Multi-roastery management dashboard. |
| `/admin/roastery/:id/beans` | Admin | Inventory control & Scraper trigger. |

---

## 🛠️ Local Development & Deployment

### **Prerequisites**
* Flutter SDK (3.x+)
* Go (1.21+)
* Supabase CLI

### **Environment Variables**
Create a `.env` file for the Go service and a `web/assets/config.json` for Flutter:
```env
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE=your_service_role (for Scraper)
```

### **Deployment**
* **Frontend:** Deploy to Vercel. Ensure `vercel.json` is configured for SPA routing.
* **Scraper:** Deploy as an API on Render/Railway or as an Edge Function.
* **Database:** Apply migrations found in `/supabase/migrations`.

---

## 📝 License
This project is proprietary. Developed for the Indonesian Specialty Coffee Scene. 2026.
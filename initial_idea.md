# 🛠️ Technical Master Doc: Coffee Beans App (2026)

## 1. System Architecture & Hosting
* **Frontend:** Flutter Web (CanvasKit/WASM). Optimized for **Mobile Web (MWeb)**.
* **Backend:** Supabase (PostgreSQL, Auth, Edge Functions).
* **Scraper Microservice:** Go (Golang) using `go-rod` (Stealth) and `goquery`.
* **Hosting:** **Vercel** for Frontend (100GB Bandwidth limit).
    * *Vercel Config:* `vercel.json` must rewrite all sources to `index.html` for SPA routing.
* **Processing:** **GitHub Actions** for high-resource bulk scraping (bypassing Data Center IP blocks).

---

## 2. Database Schema (PostgreSQL)

### **Roastery Management**
```sql
CREATE TABLE roasteries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL INDEX,
    city TEXT NOT NULL,
    bio TEXT,
    logo_url TEXT,
    social_links JSONB DEFAULT '{}'::jsonb, -- Keys: instagram, tokopedia, shopee, web
    is_active BOOLEAN DEFAULT true
);
```

### **The Bean Catalog (Fingerprint Pattern)**
```sql
CREATE TABLE beans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    roastery_id UUID REFERENCES roasteries(id) ON DELETE CASCADE,
    clean_name TEXT NOT NULL, -- Name without weight/noise
    fingerprint TEXT UNIQUE NOT NULL, -- Format: roastery_id-slugified-name
    variety TEXT[] DEFAULT '{}', -- E.g. ['Sigarar Utang', 'Typica']
    notes TEXT[] DEFAULT '{}', -- E.g. ['Chocolate', 'Nutty']
    process TEXT, -- E.g. 'Natural', 'Wash'
    roast_level TEXT, -- E.g. 'Medium'
    status TEXT CHECK (status IN ('published', 'draft', 'unpublished')) DEFAULT 'draft',
    variants JSONB DEFAULT '{}'::jsonb -- Keyed by weight
);
```
**Example `variants` Payload:**
```json
{
  "250g": { "price": 95000, "tokopedia": "url", "shopee": "url", "wa": "url" },
  "500g": { "price": 180000, "tokopedia": "url" }
}
```

### **Dynamic Metadata (Filter Engine)**
```sql
CREATE TABLE filter_metadata (
    id SERIAL PRIMARY KEY,
    category TEXT NOT NULL, -- 'variety', 'process', 'origin', 'note'
    label TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true
);
```

---

## 3. Go Scraper Implementation Details

### **Normalization Pipeline**
1.  **Regex Weight Extraction:** `(?i)\s*(\d+)\s*(gram|gr|g|kg)`. Standardize to `g` or `kg`.
2.  **Noise Removal:** Strip keywords: `Promo, Murah, Ready, Biji, Kopi, [A-Z0-9]`.
3.  **Fingerprint:** `RoasteryID` + `Lower(CleanName)` (alphanumeric only).

### **Deep-Merge Upsert Logic**
When scraping a new URL, the Go service must not overwrite the entire row. It uses `jsonb_set` to target a specific weight variant.
```sql
-- SQL logic for Go UPSERT
INSERT INTO beans (roastery_id, clean_name, fingerprint, variants, status)
VALUES ($1, $2, $3, $4, 'draft')
ON CONFLICT (fingerprint) 
DO UPDATE SET 
  variants = jsonb_set(beans.variants, ARRAY[$5], EXCLUDED.variants->$5, true);
```

---

## 4. App Routing & Page Logic (GoRouter)

### **User Routes (Public)**
* **`/` (Home):** Static info page, mission statement, featured roasteries.
* **`/beans` (Catalog):** * *Features:* Search input + Advanced Filter Sheet.
    * *Filters:* Dynamic chips sourced from `filter_metadata` (Variety, Process, Roastery, Price Range).
* **`/beans/:id` (Detail):** * *Features:* Hero image, technical specs table, weight choice-chips.
    * *Logic:* Selecting a weight chip updates the price and buy-button URLs from the `variants` JSONB.
* **`/roasteries` (Search):** Search roasteries by name/city.
* **`/roastery/:id` (Profile):** Roastery bio, social links (IG/Web/Shop), and a bean grid hard-filtered to that roastery.

### **Admin Routes (Auth Guarded)**
* **`/admin-login`:** Supabase Auth entry.
* **`/admin/roastery`:** List of all roasteries with "Is Active" toggles.
* **`/admin/roastery/:id`:** Profile editor (Logo upload, Social JSONB edit).
* **`/admin/roastery/:id/beans`:** * *Features:* Bulk checkboxes + Floating Action Bar.
    * *Actions:* **Publish, Draft, Unpublish** (Targeted status update).
    * *Trigger:* Scraper input field (Manual URL scrape).
* **`/admin/roastery/:id/beans/:id`:** Detailed editor for cleaning up scraped metadata (Arrays, Process, Roast Level).

---

## 5. Implementation Directives for Antigravity

1.  **State Management:** Use BLoC (Catalog, Admin, Auth modules).
2.  **UI Components:** * `BeanCard` must support `isAdmin` mode with status badges and checkboxes.
    * Use `FilterChip` for varieties and notes based on `filter_metadata` table.
3.  **Security:** * Set Supabase RLS: `anon` users can only see `beans` where `status = 'published'`.
    * GoRouter `redirect` must check `Supabase.instance.client.auth.currentSession` for all `/admin` routes.
4.  **Marketplace Interop:** Implement `url_launcher` with custom schemes (`tokopedia://`, `shopeeid://`) for native app transitions, falling back to HTTPS.

---
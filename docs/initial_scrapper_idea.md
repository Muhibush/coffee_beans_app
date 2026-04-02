## 🛠️ 1. Scraping Architecture: Hybrid Approach

You cannot rely on a single library for Indonesian marketplaces (Tokopedia/Shopee) because of their aggressive Cloudflare and PerimeterX protection.

* **Engine A: `goquery` (Fast/Static):** Used for roastery-owned websites (Shopify, WooCommerce). High speed, low memory.
* **Engine B: `go-rod` + `stealth` (Headless/JS):** Used for marketplaces. Simulates a real browser to bypass "Are you a robot?" challenges.
* **Engine C: GitHub Actions (Bulk Runner):** Since marketplaces often ban data-center IPs (AWS/DigitalOcean), running bulk scrapes via GitHub Actions provides fresh runner IPs and free compute.

---

## 🧼 2. The Normalization Pipeline

This is where messy titles become clean database records.

### **A. Weight Extraction & Standardization**
Marketplace titles are inconsistent (e.g., "Gayo 250gr", "Gayo 500 gram"). 
* **Regex:** `(?i)\s*(\d+)\s*(gram|gr|g|kg)`
* **Logic:** * If unit matches `kg`, multiply value by 1000 or store as `1kg`.
    * Standardize all `gr`, `gram`, `G` to `g`.
    * **Result:** `250g`, `500g`, `1kg`.

### **B. Title Cleaning (The "Clean Name")**
To prevent the same bean appearing twice, we strip "Weight" and "Marketing Fluff" from the title.
* **Input:** `PROMO!! Biji Kopi Aceh Gayo 250gr - Fullwash Ready!`
* **Process:** 1.  Remove weight match (`250gr`).
    2.  Remove noise words: `Ready, Promo, Murah, Terlaris, Biji, Kopi, Fresh`.
    3.  Remove special characters: `!!, -, [, ]`.
* **Output:** `Aceh Gayo Fullwash`.

### **C. Fingerprinting**
The `fingerprint` is the unique key that prevents duplicates.
* **Formula:** `roastery_id` + `slugify(clean_name)`.
* **Example:** `7b2...` + `aceh-gayo-fullwash`.

---

## 🗄️ 3. The "Deep Merge" Upsert Logic

This is the most critical part of the Go service. It ensures that if a roastery adds a 500g variant later, it **merges** into the existing 250g product instead of creating a new row.

```go
func UpsertBean(db *sql.DB, b Bean, weightKey string, variantData map[string]interface{}) error {
	query := `
		INSERT INTO beans (roastery_id, clean_name, fingerprint, variants, status)
		VALUES ($1, $2, $3, $4, 'draft')
		ON CONFLICT (fingerprint) 
		DO UPDATE SET 
			variants = jsonb_set(
				beans.variants, 
				ARRAY[$5], 
				EXCLUDED.variants->$5, 
				true
			)
		RETURNING id;
	`
    // $4 is the full initial variants JSONB: {"250g": {...}}
    // $5 is the specific weight key being added: "250g"
	return db.QueryRow(query, b.RoasteryID, b.CleanName, b.Fingerprint, b.VariantsJSON, weightKey).Scan(&b.ID)
}
```

---

## 🧠 4. Extraction Strategy per Source

| Source Type | Strategy | Target Data |
| :--- | :--- | :--- |
| **Marketplaces** | `go-rod` + Stealth | Extract from `window.__INITIAL_STATE__` or specific JSON-LD script tags to get clean price/image data without parsing messy HTML. |
| **Shopify Sites** | `goquery` | Append `.js` or `.json` to the product URL to get raw, structured JSON data directly from the roastery's backend. |
| **Generic Sites** | `goquery` | Parse OpenGraph tags: `og:title`, `og:image`, and Schema.org `Product` ld+json. |

---

## 🚀 5. Advanced Data Points (The "Coffee Specs")

Your scraper should attempt to find these in the product description using keyword matching:
* **Process:** Search for `Natural, Wash, Honey, Anaerobic`.
* **Variety:** Search for `Typica, Sigarar Utang, Ateng, Bourbon, Kartika`.
* **Altitude:** Regex `(\d{3,4})\s?(masl|mdpl)`.
* **Notes:** Match against your `filter_metadata` labels (e.g., if description contains "cokelat", tag with "Chocolate").

---

## 📝 Admin Workflow Integration

1.  **Manual:** Admin pastes a Tokopedia link in Flutter. 
2.  **API Call:** Flutter hits Go Service `/scrape?url=...`.
3.  **Response:** Go service returns a JSON of the parsed data.
4.  **Review:** Admin sees a pre-filled form in Flutter, tweaks the `variety` or `notes`, and hits **Save**.
5.  **DB Update:** The bean moves from `draft` to `published`.

Does this level of detail cover the "how-to" for the scraper, or do you want to see the specific **Go-Rod** stealth configuration for Tokopedia?
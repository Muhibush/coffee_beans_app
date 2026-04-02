---
trigger: always_on
---

# CODING_RULES

## General Principles

- **Business Logic:** State Management is handled strictly using BLoC pattern (`Catalog`, `Admin`, `Auth` modules).
- **Component Responsibility:** UI widgets handle presentation while BLoCs handle logic and external interactions (Supabase, Scraper APIs). 
- **Scraper / Normalization:**
  - Standardize weight to `g` or `kg`.
  - Clean name stripping noise (Promo, Murah, Ready).
  - Fingerprint logic: `roastery_id` + `slugify(clean_name)` prevents duplicates.
  - Deep-Merge Upsert: Scraper updates specific dictionary keys inside `variants` without wiping other weights using PostgreSQL `jsonb_set`.
  - **Endpoints**: Offers `/scrape` for extracting a single product URL and `/scrape-bulk` for full store page extraction.
  - **Reference**: Developers & agents modifying the scraper MUST consult `.agent/skills/scraper/SKILL.md`.

---

## Logic / Backend

- **Supabase Interaction:**
  - Scraper inserts as 'draft', admin reviews and moves to 'publish'.
- **Flutter Interop:**
  - `url_launcher` handling custom schemes (`tokopedia://`, `shopeeid://`) natively when possible, falling back to HTTPS.

---

## Navigation

- **Router Usage:** Uses `go_router` exclusively for all routing logic on both public and admin routes.
- **Protected Routes:**
  - `go_router` `redirect` must explicitly check `Supabase.instance.client.auth.currentSession` for all routes under `/admin`.

---

## State Management

- **BLoC:** Primary tool for application state. Grouped into Catalog, Admin, and Auth domains.
- **Action Pattern:** Triggers BLoC events on user interaction, state emitted back to UI.

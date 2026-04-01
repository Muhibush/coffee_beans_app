---
trigger: always_on
---

# AGENT_CONTEXT

## PROJECT OVERVIEW

- **Project Name:** Coffee Beans App
- **Repository:** coffee_beans_app
- **Purpose:** A high-performance, mobile-first web platform (MWeb) designed to aggregate and normalize specialty coffee data from various Indonesian roasteries and marketplaces, providing a distraction-free catalog for users and zero-effort management for roasteries.
- **Core Functionality:** Advanced filtering, marketplace aggregation, roastery directory, Go-based normalization engine, Master-Variant architecture mapping multiple weights to one bean.
- **Architecture:** Distributed micro-frontend/micro-service model. Frontend is Flutter Web (CanvasKit/WASM), Database/Auth is Supabase (PostgreSQL), Scraper Microservice is Go (fetch via go-rod and goquery), with Github Actions for bulk scraping.

---

## TECH STACK

| Layer              | Technology                                              |
|--------------------|--------------------------------------------------------|
| **Framework**      | Flutter Web (CanvasKit/WASM)                           |
| **Language**       | Dart, Go (Golang), SQL                                 |
| **State Management**| BLoC                                                   |
| **API Client**     | Dio                                                    |
| **Database**       | Supabase (PostgreSQL)                                  |
| **Auth**           | Supabase Auth                                          |
| **Scraper Engine** | Go (`go-rod`, `goquery`)                               |
| **Deployment**     | Vercel (Frontend), GitHub Actions (Processing)         |

---

## DATABASE SCHEMA SUMMARY

- `roasteries`: Brand profiles with `social_links` (JSONB)
- `beans`: Product data (draft, published) with `variants` (JSONB), `variety` (TEXT[]), `notes` (TEXT[])
- `filter_metadata`: Dynamic UI filter source (`category`, `label`, `is_active`)

---

## COMMON TASK LOCATIONS

| Task                      | Technology/Location                                       |
|---------------------------|-----------------------------------------------------------|
| Frontend App Logic        | Flutter / BLoC (`Catalog`, `Admin`, `Auth` modules)       |
| Routing Configuration     | `go_router` in Flutter                                    |
| Data Normalization        | Go Scraper Service (`goquery`, `go-rod`)                  |
| Database/Auth             | Supabase (PostgreSQL, RLS)                                |

---

## ROUTING MAP

| Path                              | Access   | Description                                       |
|-----------------------------------|----------|---------------------------------------------------|
| `/`                               | Public   | Static info page, mission statement, featured.    |
| `/beans`                          | Public   | Searchable catalog with advanced filters.         |
| `/beans/:id`                      | Public   | Detail view with weight choice-chips & buy links. |
| `/roasteries`                     | Public   | Search roasteries by name/city.                   |
| `/roastery/:id`                   | Public   | Roastery bio, social links, bean grid.            |
| `/admin-login`                    | Public   | Supabase Auth entry.                              |
| `/admin/roastery`                 | Admin    | Multi-roastery management dashboard.              |
| `/admin/roastery/:id`             | Admin    | Profile editor (Logo, Social).                    |
| `/admin/roastery/:id/beans`       | Admin    | Inventory control, bulk actions, Scraper trigger. |
| `/admin/roastery/:id/beans/:id`   | Admin    | Detailed bean editor.                             |

---

## DATA FLOW

```
[Flutter UI/Admin] -> [Supabase PostgreSQL (via RLS)] -> [go_router / BLoC State Update]
[Marketplace/Roastery Site] -> [Go Scraper] -> [Deep-Merge Upsert] -> [Supabase PostgreSQL]
```

**Scraper Flow:** Extraction -> Normalization (regex for weight, clean_name) -> Deep-Merge Upsert using `jsonb_set` based on `roastery_id + slugify(clean_name)` fingerprint.

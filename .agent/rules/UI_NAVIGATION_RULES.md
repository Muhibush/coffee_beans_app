---
trigger: always_on
---

# 🚀 UI & Navigation Rules

## 📌 Overview

Vercel-hosted Single Page Application mapping directly onto a Flutter CanvasKit/WASM interface. All routing runs through `go_router`.

---

## 🛠 1. Navigation Scoping

### Main Pages (Public)
- `/` — Home (Landing, about, featured)
- `/beans` — Catalog (Search + Advanced Filter Sheet)
- `/roasteries` — Roastery Directory (Search by name/city)

### Detail Pages (Public)
- `/beans/:id` — Detail view, specs, pricing, marketplace links.
- `/roastery/:id` — Roastery profile, bio, filtered bean grid.

### Admin Pages (Guarded)
- `/admin-login` — Auth Gateway
- `/admin/roastery` — Dashboard of roasteries
- `/admin/roastery/:id` — Roastery Profile Editor
- `/admin/roastery/:id/beans` — Bulk Inventory Management
- `/admin/roastery/:id/beans/:id` — Deep editing of parsed scraped bean specifics

### Bottom Navigation Bar

Public app uses a bottom navigation bar with **3 tabs**: Home, Beans, Roastery.

| Page             | Path             | Bottom Nav Visible? |
|------------------|------------------|---------------------|
| Home             | `/`              | ✅ Yes              |
| Beans Catalog    | `/beans`         | ✅ Yes              |
| Roastery Dir.    | `/roasteries`    | ✅ Yes              |
| Bean Detail      | `/beans/:id`     | ❌ No               |
| Roastery Profile | `/roastery/:id`  | ❌ No               |

### Router Structure

```
GoRouter
├── StatefulShellRoute (BottomNavigationBar scaffold)
│   ├── /              → HomePage
│   ├── /beans         → BeansCatalogPage    (GridView, 2 columns)
│   └── /roasteries    → RoasteriesPage      (ListView)
│
├── /beans/:id         → BeanDetailPage      (no shell, no bottom nav)
└── /roastery/:id      → RoasteryProfilePage (no shell, no bottom nav)
```

Use `StatefulShellRoute` from `go_router` to preserve scroll position and state when switching between bottom nav tabs.

---

## 📱 2. Public Screen Wireframes

### 🏠 Home — `/`

```
┌─────────────────────────────────────┐
│  ≡                    Coffee Beans  │
│─────────────────────────────────────│
│                                     │
│  ┌─────────────────────────────────┐│
│  │                                 ││
│  │         ☕ Coffee Beans         ││
│  │                                 ││
│  │    Discover specialty coffee    ││
│  │    from Indonesia's finest      ││
│  │    roasteries                   ││
│  │                                 ││
│  │        [ Explore Beans ]        ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│  ── About ──────────────────────── │
│                                     │
│  We aggregate and normalize         │
│  specialty coffee data from         │
│  Indonesian roasteries &            │
│  marketplaces into one              │
│  distraction-free catalog.          │
│                                     │
│  ── Featured Beans ────────────── │
│                                     │
│  ┌───────────────┐ ┌───────────────┐│
│  │ ┌───────────┐ │ │ ┌───────────┐ ││
│  │ │           │ │ │ │           │ ││
│  │ │    IMG    │ │ │ │    IMG    │ ││
│  │ │           │ │ │ │           │ ││
│  │ └───────────┘ │ │ └───────────┘ ││
│  │ Ethiopia Guji │ │ Aceh Gayo     ││
│  │ Roastery A    │ │ Roastery B    ││
│  │ 🏷 Washed     │ │ 🏷 Natural    ││
│  │ Rp 85.000     │ │ Rp 120.000    ││
│  └───────────────┘ └───────────────┘│
│                                     │
│─────────────────────────────────────│
│  [🏠]      🫘       🏪            │
│  Home     Beans   Roastery          │
│  ━━━━                               │
└─────────────────────────────────────┘
```

### 🫘 Beans Catalog — `/beans`

```
┌─────────────────────────────────────┐
│  ≡                      Beans       │
│─────────────────────────────────────│
│  ┌─────────────────────────────────┐│
│  │ 🔍 Search beans...              ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ ⚙ Filters                    ▼ ││
│  │                                 ││
│  │ Variety:  [All ▾]               ││
│  │ Process:  [All ▾]               ││
│  │ Origin:   [All ▾]               ││
│  │ Notes:    [All ▾]               ││
│  │                                 ││
│  │   [ Reset ]    [ Apply ]        ││
│  └─────────────────────────────────┘│
│                                     │
│  Showing 24 beans                   │
│                                     │
│  ┌───────────────┐ ┌───────────────┐│
│  │ ┌───────────┐ │ │ ┌───────────┐ ││
│  │ │           │ │ │ │           │ ││
│  │ │    IMG    │ │ │ │    IMG    │ ││
│  │ │           │ │ │ │           │ ││
│  │ └───────────┘ │ │ └───────────┘ ││
│  │ Ethiopia Guji │ │ Aceh Gayo     ││
│  │ Roastery A    │ │ Roastery B    ││
│  │ 🏷 Washed     │ │ 🏷 Natural    ││
│  │ Rp 85.000     │ │ Rp 120.000    ││
│  └───────────────┘ └───────────────┘│
│  ┌───────────────┐ ┌───────────────┐│
│  │ ┌───────────┐ │ │ ┌───────────┐ ││
│  │ │           │ │ │ │           │ ││
│  │ │    IMG    │ │ │ │    IMG    │ ││
│  │ │           │ │ │ │           │ ││
│  │ └───────────┘ │ │ └───────────┘ ││
│  │ Toraja Sapan  │ │ Bali Kintam.  ││
│  │ Roastery C    │ │ Roastery D    ││
│  │ 🏷 Honey      │ │ 🏷 Washed     ││
│  │ Rp 95.000     │ │ Rp 78.000     ││
│  └───────────────┘ └───────────────┘│
│               ...                   │
│─────────────────────────────────────│
│  🏠       [🫘]       🏪            │
│  Home     Beans    Roastery         │
│           ━━━━━                     │
└─────────────────────────────────────┘
```

### 🏪 Roastery Directory — `/roasteries`

```
┌─────────────────────────────────────┐
│  ≡                   Roasteries     │
│─────────────────────────────────────│
│  ┌─────────────────────────────────┐│
│  │ 🔍 Search by name or city...    ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ ┌─────┐                         ││
│  │ │     │  Roastery A              ││
│  │ │Logo │  📍 Jakarta              ││
│  │ │     │  12 beans                ││
│  │ └─────┘                         ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ ┌─────┐                         ││
│  │ │     │  Roastery B              ││
│  │ │Logo │  📍 Bandung              ││
│  │ │     │  8 beans                 ││
│  │ └─────┘                         ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ ┌─────┐                         ││
│  │ │     │  Roastery C              ││
│  │ │Logo │  📍 Yogyakarta           ││
│  │ │     │  15 beans                ││
│  │ └─────┘                         ││
│  └─────────────────────────────────┘│
│               ...                   │
│─────────────────────────────────────│
│  🏠        🫘       [🏪]           │
│  Home     Beans    Roastery         │
│                    ━━━━━━━━         │
└─────────────────────────────────────┘
```

### 🫘 Bean Detail — `/beans/:id`

```
┌─────────────────────────────────────┐
│  ← Back                            │
│─────────────────────────────────────│
│  ┌─────────────────────────────────┐│
│  │                                 ││
│  │                                 ││
│  │           Bean Image            ││
│  │            (hero)               ││
│  │                                 ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│  Ethiopia Guji Grade 1              │
│  by Roastery A                      │
│                                     │
│  ── Specs ──────────────────────── │
│                                     │
│  Origin     Ethiopia, Guji          │
│  Process    Washed                  │
│  Variety    Heirloom                │
│  Altitude   1,800 - 2,100 masl     │
│                                     │
│  ── Tasting Notes ─────────────── │
│                                     │
│  ┌──────┐ ┌──────────┐ ┌─────────┐ │
│  │Citrus│ │Chocolate │ │ Floral  │ │
│  └──────┘ └──────────┘ └─────────┘ │
│                                     │
│  ── Weight ────────────────────── │
│                                     │
│  ┌───────┐ ┌───────┐ ┌───────┐     │
│  │[100g] │ │ 200g  │ │  1kg  │     │
│  └───────┘ └───────┘ └───────┘     │
│   selected                          │
│                                     │
│  💰 Price: Rp 85.000               │
│                                     │
│  ── Buy From ──────────────────── │
│                                     │
│  ┌─────────────────────────────────┐│
│  │  🛒  Buy on Tokopedia        → ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │  🛒  Buy on Shopee           → ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │  🌐  Visit Website           → ││
│  └─────────────────────────────────┘│
│                                     │
│              (no bottom nav)        │
└─────────────────────────────────────┘
```

### 🏪 Roastery Profile — `/roastery/:id`

```
┌─────────────────────────────────────┐
│  ← Back                            │
│─────────────────────────────────────│
│                                     │
│           ┌─────────┐              │
│           │         │              │
│           │  Logo   │              │
│           │         │              │
│           └─────────┘              │
│         Roastery Name A             │
│         📍 Jakarta, Indonesia       │
│                                     │
│  ── About ──────────────────────── │
│                                     │
│  Specialty coffee roastery          │
│  focused on single-origin           │
│  Indonesian beans since 2018.       │
│                                     │
│  ── Social Links ──────────────── │
│                                     │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │  🌐  │ │  🛒  │ │  📸  │       │
│  │ Web  │ │Tokped│ │ Insta │       │
│  └──────┘ └──────┘ └──────┘       │
│                                     │
│  ── Beans (12) ────────────────── │
│                                     │
│  ┌───────────────┐ ┌───────────────┐│
│  │ ┌───────────┐ │ │ ┌───────────┐ ││
│  │ │           │ │ │ │           │ ││
│  │ │    IMG    │ │ │ │    IMG    │ ││
│  │ │           │ │ │ │           │ ││
│  │ └───────────┘ │ │ └───────────┘ ││
│  │ Ethiopia Guji │ │ Aceh Gayo     ││
│  │ 🏷 Washed     │ │ 🏷 Natural    ││
│  │ Rp 85.000     │ │ Rp 120.000    ││
│  └───────────────┘ └───────────────┘│
│  ┌───────────────┐ ┌───────────────┐│
│  │ ┌───────────┐ │ │ ┌───────────┐ ││
│  │ │           │ │ │ │           │ ││
│  │ │    IMG    │ │ │ │    IMG    │ ││
│  │ │           │ │ │ │           │ ││
│  │ └───────────┘ │ │ └───────────┘ ││
│  │ Toraja Sapan  │ │ Flores Bajawa ││
│  │ 🏷 Honey      │ │ 🏷 Natural    ││
│  │ Rp 95.000     │ │ Rp 88.000     ││
│  └───────────────┘ └───────────────┘│
│               ...                   │
│                                     │
│              (no bottom nav)        │
└─────────────────────────────────────┘
```

Note: On the Roastery Profile page, BeanCard omits the roastery name since all beans belong to the same roastery.

---

## 🔗 3. Navigation Flow

```
                    ┌──────────────────────────────────────────────┐
                    │            Bottom Navigation Bar             │
                    │                                              │
                    │     🏠 Home     🫘 Beans     🏪 Roastery    │
                    └──────┬──────────────┬──────────────┬─────────┘
                           │              │              │
                           ▼              ▼              ▼
                      ┌─────────┐   ┌──────────┐   ┌────────────┐
                      │    /    │   │  /beans   │   │/roasteries │
                      │  Home   │   │  Catalog  │   │ Directory  │
                      └─────────┘   └────┬─────┘   └─────┬──────┘
                                         │                │
                                    tap card          tap card
                                         │                │
                                         ▼                ▼
                                  ┌────────────┐   ┌──────────────┐
                                  │ /beans/:id │   │/roastery/:id │
                                  │ Bean Detail│   │ Profile +    │
                                  │ (no nav)   │   │ Bean Grid    │
                                  └──────┬─────┘   └──────┬───────┘
                                         │                │
                                     ← Back           ← Back
                                         │                │
                                         ▼                ▼
                                    returns to       returns to
                                    /beans           /roasteries
                                                          │
                                                     tap bean card
                                                          │
                                                          ▼
                                                   ┌────────────┐
                                                   │ /beans/:id │
                                                   │ Bean Detail│
                                                   └────────────┘
```

---

## 🏗 4. Vercel Configuration Check

- Ensure `vercel.json` is correctly configured to rewrite all sources (`/(.*)`) to `index.html` allowing `go_router` to pick up and orchestrate the Single Page App routing directly on load or refresh.

---

## 🔄 5. Flow Expectations

- **Navigation:** Use the `go` route (`go()` or `goNamed()`) for navigating between screens.
- **App link handoffs:** From detail pages, when selecting a checkout/market button, use `url_launcher` to launch the url on an external browser. No need to open the native specific app.
- **Scraping Flow:** Admin hits `/admin/roastery/:id/beans`, sets a URL, API generates JSON, Flutter takes JSON into memory structure for review, Admin clicks "Save", transitions from `draft` -> `published`.

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

---

## Folder Structure

```
lib/
├── main.dart                         # Entry point (Supabase initialization)
│
├── main/                             # Global Application Logic
│   ├── repository/
│   │   └── main_repository.dart      # Shared repository for global data
│   └── bloc/
│       ├── main_bloc.dart            # Root state management
│       ├── main_event.dart
│       └── main_state.dart
│
├── pages/                            # Feature-Level Organization
│   ├── home/
│   │   ├── home_page.dart            # Page entry (DI: Bloc Providers)
│   │   └── widget/
│   │       ├── home_view.dart        # Main layout
│   │       ├── hero_section.dart
│   │       ├── about_section.dart
│   │       └── featured_beans_grid.dart
│   │
│   ├── beans_catalog/
│   │   ├── beans_catalog_page.dart
│   │   ├── bloc/
│   │   │   ├── catalog_bloc.dart
│   │   │   ├── catalog_event.dart
│   │   │   └── catalog_state.dart
│   │   ├── repository/
│   │   │   └── catalog_repository.dart
│   │   └── widget/
│   │       ├── beans_catalog_view.dart
│   │       ├── filter_sort_chip_bar.dart
│   │       ├── filter_bottom_sheet.dart
│   │       ├── sort_bottom_sheet.dart
│   │       └── beans_grid.dart
│   │
│   ├── bean_detail/
│   │   ├── bean_detail_page.dart
│   │   ├── bloc/
│   │   │   ├── bean_detail_bloc.dart
│   │   │   ├── bean_detail_event.dart
│   │   │   └── bean_detail_state.dart
│   │   ├── repository/
│   │   │   └── bean_detail_repository.dart
│   │   └── widget/
│   │       ├── bean_detail_view.dart
│   │       ├── specs_table.dart
│   │       ├── tasting_notes_text.dart
│   │       ├── weight_choice_chips.dart
│   │       └── buy_buttons.dart
│   │
│   ├── roasteries/
│   │   ├── roasteries_page.dart
│   │   ├── bloc/
│   │   │   ├── roasteries_bloc.dart
│   │   │   ├── roasteries_event.dart
│   │   │   └── roasteries_state.dart
│   │   ├── repository/
│   │   │   └── roasteries_repository.dart
│   │   └── widget/
│   │       ├── roasteries_view.dart
│   │       └── roastery_card.dart
│   │
│   ├── roastery_profile/
│   │   ├── roastery_profile_page.dart
│   │   ├── bloc/
│   │   │   ├── roastery_profile_bloc.dart
│   │   │   ├── roastery_profile_event.dart
│   │   │   └── roastery_profile_state.dart
│   │   ├── repository/
│   │   │   └── roastery_profile_repository.dart
│   │   └── widget/
│   │       ├── roastery_profile_view.dart
│   │       ├── social_links_section.dart
│   │       └── roastery_beans_grid.dart
│   │
│   ├── admin_login/
│   │   ├── admin_login_page.dart
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   └── widget/
│   │       └── admin_login_view.dart
│   │
│   ├── admin_dashboard/
│   │   ├── admin_dashboard_page.dart
│   │   ├── bloc/
│   │   │   ├── admin_dashboard_bloc.dart
│   │   │   ├── admin_dashboard_event.dart
│   │   │   └── admin_dashboard_state.dart
│   │   ├── repository/
│   │   │   └── admin_dashboard_repository.dart
│   │   └── widget/
│   │       ├── admin_dashboard_view.dart
│   │       └── admin_roastery_card.dart
│   │
│   ├── admin_roastery_edit/
│   │   ├── admin_roastery_edit_page.dart
│   │   ├── bloc/
│   │   │   ├── admin_roastery_edit_bloc.dart
│   │   │   ├── admin_roastery_edit_event.dart
│   │   │   └── admin_roastery_edit_state.dart
│   │   ├── repository/
│   │   │   └── admin_roastery_edit_repository.dart
│   │   └── widget/
│   │       └── admin_roastery_edit_view.dart
│   │
│   ├── admin_bean_list/
│   │   ├── admin_bean_list_page.dart
│   │   ├── bloc/
│   │   │   ├── admin_bean_list_bloc.dart
│   │   │   ├── admin_bean_list_event.dart
│   │   │   └── admin_bean_list_state.dart
│   │   ├── repository/
│   │   │   └── admin_bean_list_repository.dart
│   │   └── widget/
│   │       ├── admin_bean_list_view.dart
│   │       ├── scraper_input.dart
│   │       ├── status_filter_chip.dart
│   │       └── admin_bean_card.dart
│   │
│   └── admin_bean_edit/
│       ├── admin_bean_edit_page.dart
│       ├── bloc/
│       │   ├── admin_bean_edit_bloc.dart
│       │   ├── admin_bean_edit_event.dart
│       │   └── admin_bean_edit_state.dart
│       ├── repository/
│       │   └── admin_bean_edit_repository.dart
│       └── widget/
│           ├── admin_bean_edit_view.dart
│           ├── variant_editor.dart
│           └── chip_list_editor.dart
│
├── model/                            # Global Data Entities
│   ├── bean_model.dart
│   ├── roastery_model.dart
│   ├── filter_metadata_model.dart
│   └── scraped_bean_model.dart
│
├── widget/                           # App-wide Reusable UI Components
│   ├── bean_card.dart                # The base bean card used in all grids
│   ├── search_bar_widget.dart
│   ├── scaffold_with_nav_bar.dart
│   └── status_badge.dart
│
├── utils/                            # Core Logic & Infrastructure
│   ├── api_provider/
│   │   └── supabase_client.dart      # Supabase singleton
│   ├── design_system/
│   │   ├── app_colors.dart           # Color constants
│   │   └── app_text_styles.dart      # Text style constants
│   ├── router/
│   │   └── app_router.dart           # All route definitions
│   ├── environment.dart              # Environment config
│   └── url_launcher_helper.dart      # url_launcher wrapper
│
└── l10n/                             # Localization (future)
    └── intl_id.arb
```


---
trigger: always_on
---

# 🔒 Repository Security Rules

These are mandatory security practices for any AI assistant or agent working on this repository. Violations are treated as critical security incidents.

---

## 1. Environment Variable Protection

- **NEVER** commit environment files or configuration secrets.
- **PROACTIVELY** verify that any new configuration file containing sensitive keys is added to `.gitignore`.
- **Project-specific sensitive files:**
    - `.env` (contains `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE`)
    - `web/assets/config.json` (Flutter environment configuration)

---

## 2. No Hardcoded Secrets

- **NEVER** hardcode API keys, database credentials, or secret configuration values directly in source code.
- **USE** environment parsing libraries in Go or Flutter to load these during run-time.
- **List of critical variables (do not include values!):**
    - `SUPABASE_URL`
    - `SUPABASE_ANON_KEY`
    - `SUPABASE_SERVICE_ROLE`

---

## 3. Database Security (Supabase RLS)

- **Strict RLS Enforcement:**
  - `anon` users MUST ONLY see `beans` where `status = 'published'`. Do not expose drafts or unpublished beans without authentication.
- **Scraper / Edge Functions:**
  - Only the internal Go scraper service is allowed to use `SUPABASE_SERVICE_ROLE` to bypass Row Level Security when extracting and aggregating marketplace data.

---

## 4. Frontend Route Guards

- Always secure `/admin/*` routes at the router level. Use `go_router` redirects that check `Supabase.instance.client.auth.currentSession`. No client page should render admin data if the session is absent.

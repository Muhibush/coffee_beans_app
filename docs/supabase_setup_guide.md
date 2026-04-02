# Supabase Preparation Guide

This guide details the steps required to set up the Supabase PostgreSQL database for the Coffee Beans App. It includes schema creation, relationships, constraints, and Row Level Security (RLS) policies according to the project's security rules.

## 1. Project Initialization

1. Log in to [Supabase](https://supabase.com/).
2. Create a new organization and project if you haven't already.
3. Once the database provisions, navigate to the **SQL Editor** in the left sidebar to execute the schema definitions below.

> [!IMPORTANT]
> The Go Scraper connects to Supabase using the `SUPABASE_SERVICE_ROLE` key to bypass RLS during batch inserts and deep-merges. Ensure you do not expose this key in your frontend Flutter application.

## 2. Table Schemas

Execute the following SQL to create the required tables.

### 1. `roasteries` Table
Stores roastery brand profiles.
```sql
CREATE TABLE roasteries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    bio TEXT,
    logo_url TEXT,
    social_links JSONB DEFAULT '{}'::jsonb, -- Keys: instagram, tokopedia, shopee, web
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- Optimize queries searching for roasteries by name
CREATE INDEX idx_roasteries_name ON roasteries(name);
```

### 2. `beans` Table
Core catalog adopting the "Fingerprint Pattern" to consolidate variants.
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
    variants JSONB DEFAULT '{}'::jsonb, -- Keyed by weight
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- Optimize status lookups for public catalogs
CREATE INDEX idx_beans_status ON beans(status);
```

### 3. `filter_metadata` Table
Feeds dynamic filters in the UI.
```sql
CREATE TABLE filter_metadata (
    id SERIAL PRIMARY KEY,
    category TEXT NOT NULL, -- 'variety', 'process', 'origin', 'note'
    label TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true
);
```

---

## 3. Row Level Security (RLS) Policies

> [!WARNING]
> Security rules dictate that `anon` users must never see `draft` or `unpublished` beans.

Enable RLS on all tables:
```sql
ALTER TABLE roasteries ENABLE ROW LEVEL SECURITY;
ALTER TABLE beans ENABLE ROW LEVEL SECURITY;
ALTER TABLE filter_metadata ENABLE ROW LEVEL SECURITY;
```

### Policies for `beans`

**1. Public Read Access (Anon):**
Only published beans are visible to the public.
```sql
CREATE POLICY "Allow public read-only access to published beans"
ON beans
FOR SELECT
USING (status = 'published');
```

**2. Admin Full Access (Authenticated):**
Assuming authenticated users are admins that can perform full CRUD via the admin panel.
```sql
CREATE POLICY "Allow full access for authenticated admins"
ON beans
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
```

### Policies for `roasteries`

**1. Public Read Access (Anon):**
Only active roasteries should be visible to public users.
```sql
CREATE POLICY "Allow public read-only access to active roasteries"
ON roasteries
FOR SELECT
USING (is_active = true);
```

**2. Admin Full Access (Authenticated):**
```sql
CREATE POLICY "Allow full access for authenticated admins"
ON roasteries
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
```

### Policies for `filter_metadata`

**1. Public Read Access:**
Public users must be able to load filter chips.
```sql
CREATE POLICY "Allow public read to active filters"
ON filter_metadata
FOR SELECT
USING (is_active = true);
```

**2. Admin Full Access (Authenticated):**
```sql
CREATE POLICY "Allow full access for authenticated admins"
ON filter_metadata
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
```

---

## 4. Environment Variables Checklist

Ensure these variables are secured. **Never commit them to version control.**

**Flutter Web Frontend (`web/assets/config.json`):**
- `SUPABASE_URL`: Setup URL from your Supabase Dashboard
- `SUPABASE_ANON_KEY`: Setup Anon key from your Supabase Dashboard

**Go Scraper Backend (`.env`):**
- `SUPABASE_URL`: Setup URL from your Supabase Dashboard
- `SUPABASE_SERVICE_ROLE`: 🚨 **WARNING:** Keep this secret. Used for bypassing RLS during bulk scrape pushes.

## 5. Next Steps
1. Insert some dummy roasteries into the `roasteries` table to get valid UUIDs.
2. Provide these UUIDs to the Go Scraper to test the URL bulk extraction and target normalization pipeline.

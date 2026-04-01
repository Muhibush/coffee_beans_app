---
trigger: always_on
---

# 🎨 Design System & UI Components

## 📌 Overview

A mobile-first web app (MWeb) optimized using Flutter Web (CanvasKit/WASM). Distraction-free catalog optimized for discovering specialty coffee.

---

## 🏗 Core UI Components

### **1. BeanCard**
- **Usage:** Main list rendering on `/beans` and `/roastery/:id` routes.
- **Key Features:**
    - Must support an `isAdmin` mode context.
    - When `isAdmin` is true, displays status badges (`published`, `draft`, `unpublished`).
    - When `isAdmin` is true, displays checkboxes for bulk actions (Publish, Draft, Unpublish).

### **2. FilterChip**
- **Usage:** Used on `/beans` (Advanced Filter Sheet) and `/beans/:id` metadata details.
- **Key Features:**
    - Drives UI from the database: Sourced dynamically from the `filter_metadata` table.
    - Covers categories: `variety`, `process`, `origin`, `note`.

### **3. Weight Choice-Chips**
- **Usage:** Detail page `/beans/:id`.
- **Key Features:**
    - Selecting a weight chip dynamically updates the price and buy-button URLs by pulling data from the `variants` JSONB mapping.

---

## 🎨 Design Tokens

- **Mobile First Focus:** UI scaling must prioritize typical mobile web viewports.

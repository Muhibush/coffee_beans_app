# 🚀 UI & Navigation Rules

## 📌 Overview

[Define the primary layout and navigation philosophy, e.g., "consistent, native mobile-app-like experience following the Master-Detail pattern."]

---

## 🛠 1. Navigation Scoping

Categorize every screen into a specific scope:

### Main Tabs (Core Destinations)
[List root-level pages visible in the main navigation (e.g., Bottom Navigation Bar).]
- `/` — [Home]
- `/[path]` — [Tab A]

### Detail Pages (Sub-Pages)
[List screens pushed onto the stack from a main tab.]
- `/[path]/new`, `/[path]/:id` — [Form/Detail View]

### Public Pages (No Auth Required)
- `/login` — [Login]
- `/onboarding` — [Intro]

---

## 📱 2. Primary Navigation Bar

- **Visibility:** [Specify when the main navigation bar (BottomNav, Sidebar) should be visible or hidden.]
- **Persistence:** [Specify if the active state must be remembered when navigating back.]

---

## 🏗 3. Header & Navigation Logic

### Main Tabs (Master Pages)
- [Define rules for header buttons, e.g., "No back button on main tabs."]
- [Define rules for left/right elements in the header.]

### Detail Pages (Sub-Pages)
- [Define rules for back buttons, e.g., "Mandatory back button that triggers navigate(-1)."]
- [Define contextual title requirements.]

---

## 📌 4. Sticky Elements

Apply to all pages without exception:

| Requirement        | Rule                                                          |
|--------------------|---------------------------------------------------------------|
| **Header Position**| [e.g., sticky; top: 0; z-50]                                  |
| **Footer Position**| [e.g., sticky; bottom: 0; z-50]                               |
| **Background**     | [Specify opacity or color requirements]                       |

---

## 📐 5. Page Layout Template

Every page should follow a consistent structure:

```tsx
<div className="[container-classes]">
    {/* Header Component */}
    <Header ... />

    {/* Scrollable Content */}
    <main className="[padding-classes]">
        {/* Page content */}
    </main>

    {/* Optional: Footer Component */}
    <Footer ... />
</div>
```

---

## ⚠️ 6. Enforcement Checklist

- ❌ [e.g., Never allow the header to scroll off-screen.]
- ❌ [e.g., Never show main navigation on Detail Pages.]
- ✅ [e.g., Always use the standardized Header component.]
- ✅ [e.g., Always implement proper bottom padding for sticky footers.]

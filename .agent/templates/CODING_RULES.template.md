# CODING_RULES

## General Principles

- **Business Logic:** [Define where business logic should live (e.g., store, service, hook) and where it should NEVER live (e.g., render methods).]
- **Component Responsibility:** [Define what components should handle, e.g., only rendering and event delegation.]
- **TypeScript:** [Define requirements for typing, where shared models live, and how to handle feature-specific types.]

---

## Styling

- **[Styling Method]:** [e.g., Use Tailwind utility classes exclusively. Define rules for custom CSS or inline styles.]
- **Class Composition:** [Define how to merge classes, e.g., using a `cn()` utility.]
- **Design Tokens:** [Instruct to use custom tokens (colors, spacing, etc.) and forbid arbitrary values.]

---

## Icons/Assets

- **[Icon/Asset Source]:** [Define the library or component used for icons and any logic for auto-generating assets/icons.]
- **Naming Conventions:** [Define naming standards for images, icons, and other assets.]

---

## Navigation

- **Router Usage:** [Specify which router library to use and how to navigate programmatically.]
- **Protected Routes:** [Define how to wrap components in authentication or authorization guards.]

---

## State Management

- **[Tool/Library Name]:** [Describe the primary tool for state and how it interacts with the backend or local storage.]
- **Persistence:** [Define which data should be persisted and where (e.g., Firestore, LocalStorage, Cookies).]
- **Action Pattern:** [Describe how state updates should be handled (e.g., via exported store actions).]
- **Naming Conventions:** [Define standard naming for state files and variables.]

---

## Naming Conventions

| Type         | Convention   | Example                               |
|--------------|-------------|---------------------------------------|
| **Stores/State** | [e.g., camelCase, use[Name]Store] | `useUserStore.ts` |
| **Components** | [e.g., PascalCase] | `Header.tsx`                         |
| **Utils**    | [e.g., camelCase] | `formatValue.ts`                     |
| **Folders**  | [e.g., snake_case] | `feature_folder/`                    |

---

## File Organization

[Describe the folder structure for a typical feature or module.]

```
/[source_directory]/<feature_name>/
├── [view_dir]/     # UI Components
├── [logic_dir]/    # State/Logic/Hooks
└── [widget_dir]/   # Feature-specific sub-components
```

---

## DO NOT

- ❌ [List common bad practices to avoid in this project.]
- ❌ [e.g., Do not use arbitrary color values.]
- ❌ [e.g., Do not mix logic in component JSX.]

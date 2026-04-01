# AGENT_CONTEXT

## PROJECT OVERVIEW

- **Project Name:** [Insert Project Name]
- **Repository:** [Insert Repository Name]
- **Purpose:** [Provide a high-level description of what the project does and who it's for.]
- **Core Functionality:** [List the primary features and capabilities.]
- **Architecture:** [Describe the high-level architecture, e.g., PWA, Monolith, Microservices, and the backend/database used.]

---

## TECH STACK

| Layer              | Technology                                              |
|--------------------|--------------------------------------------------------|
| **Framework**      | [e.g., React, Next.js, Vue, etc.]                      |
| **Language**       | [e.g., TypeScript, JavaScript, Python, etc.]           |
| **State Management**| [e.g., Zustand, Redux, Context API, etc.]              |
| **Database**       | [e.g., Cloud Firestore, PostgreSQL, MongoDB, etc.]     |
| **Auth**           | [e.g., Firebase Auth, Auth0, JWT, etc.]                 |
| **Styling**        | [e.g., Tailwind CSS, CSS Modules, Styled Components]    |
| **Deployment**     | [e.g., Firebase Hosting, Vercel, AWS, etc.]            |

---

## PROJECT STRUCTURE

### `/[primary_source_directory]/` — [Feature/Module Label]
[Describe how code is organized within the main source directory.]
- `/[module_name]/` — [Description of what this module contains]
    - `/[sub_dir]/` — [e.g., components, logic, types]

### `/[ui_components_directory]/` — Reusable UI Components
[Describe where reusable UI components live and any naming conventions.]

### `/[state_management_directory]/` — Global State
[Describe the location and purpose of global state files.]

---

## COMMON TASK LOCATIONS

| Task                      | Location                                                  |
|---------------------------|-----------------------------------------------------------|
| [Feature A] Logic & State  | `[path/to/logic]`                                         |
| [Feature B] Logic & State  | `[path/to/logic]`                                         |
| Routing Configuration     | `[path/to/routing]`                                       |
| Data Models (Types)       | `[path/to/types]`                                         |
| Firebase/API Config       | `[path/to/config]`                                        |

---

## ROUTING MAP

| Path                      | Component          | Type         |
|---------------------------|--------------------|--------------|
| `/`                       | [HomeComponent]    | [Main/Tab]   |
| `/login`                  | [LoginComponent]   | [Public]     |
| `/[path]`                 | [DetailComponent]  | [Detail]     |

---

## DATA FLOW

```
[Triggering Action] → [State/Logic Layer] → [Backend/Storage API] → [Data Sync/Callback] → [State Update] → [UI Re-render]
```

**Authentication Flow:** [Briefly describe how users are authenticated and how state is initialized.]

---

## NPM SCRIPTS

| Script             | Command                                              |
|--------------------|------------------------------------------------------|
| `npm run dev`      | [Start development server]                           |
| `npm run build`    | [Build production bundle]                            |
| `npm run deploy`   | [Deploy to hosting]                                  |
| `npm run lint`     | [Run linter]                                         |

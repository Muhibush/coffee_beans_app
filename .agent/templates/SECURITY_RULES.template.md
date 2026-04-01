# 🔒 Repository Security Rules

These are mandatory security practices for any AI assistant or agent working on this repository. Violations are treated as critical security incidents.

---

## 1. Environment Variable Protection

- **NEVER** commit files ending in [List extensions, e.g., .env, .env.local, .secret].
- **PROACTIVELY** verify that any new configuration file containing sensitive keys is added to `.gitignore`.
- **ALWAYS** check `git ls-files --cached` if a sensitive file might be tracked accidentally.
- **Project-specific sensitive files:**
    - [e.g., .env.production]

---

## 2. No Hardcoded Secrets

- **NEVER** hardcode API keys, private keys, authentication tokens, database credentials, or secret configuration values directly in source code.
- **USE** [Specify method, e.g., Vite environment variables: import.meta.env.VITE_*]
- **DOCUMENT** all required env vars in `.env.example` with placeholder values.
- **List of critical variables (do not include values!):**
    - [e.g., VITE_API_KEY]

---

## 3. Git Hygiene

- **VERIFY** staged changes with `git status` before any commit.
- **STOP** and notify the user immediately if a secret is detected in staged changes or git history.
- **DO NOT** use broad commands like `git add .` blindly — stage files explicitly.
- **Target .gitignore entries:**
    ```
    [List common patterns for this project]
    ```

---

## 4. Leak Remediation

If a secret is accidentally committed:
1. **REVOKE** and **ROTATE** the compromised secret immediately.
2. Remove the file from git history using tools like `git filter-repo`.
3. Force-push the cleaned history.

---

## 5. [Backend-Specific] Security

- [Define rules for database access control, e.g., Firebase Security Rules.]
- **NEVER** deploy with open permissions (e.g., read/write access for everyone) to production.

---

*Failure to follow these rules is a critical security violation.*

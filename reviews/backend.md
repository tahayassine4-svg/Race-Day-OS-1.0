# Backend Code Review Checklist

Used by the Code-Reviewer agent to evaluate all backend/API/service/database code changes. Mark each item PASS / FAIL / N/A.

---

## Authentication & Authorization

- [ ] **Identity from session, not request** — user ID and role are always sourced from the authenticated session/token, never from the request body or query params
- [ ] **Authorization checked per request** — every route that accesses user-owned data verifies the requesting user has permission for that specific resource

## Input Validation

- [ ] **Input validated at system boundaries** — all external input (request body, query params, path params) is validated before use; invalid input returns a 400 with a clear message
- [ ] **No raw user input in queries** — database queries use parameterized queries or ORM methods; no string concatenation with user-provided values

## Error Handling

- [ ] **Errors handled at system boundaries** — all async operations are wrapped in try/catch or equivalent; unhandled promise rejections are not possible
- [ ] **No stack traces in responses** — error responses return user-safe messages; internal error details are logged server-side only, never sent to the client

## Secrets & Configuration

- [ ] **No hardcoded secrets** — no API keys, database credentials, or tokens in source code; all sensitive values come from environment variables
- [ ] **No secrets logged** — logging statements never include tokens, passwords, or API keys — even at debug level

## Data Integrity

- [ ] **Database operations use transactions where needed** — multi-step writes that must succeed together use a transaction; partial writes are impossible
- [ ] **Sensitive data not over-exposed** — API responses return only the fields the client needs; no accidental exposure of password hashes, internal IDs, or admin-only fields

## Code Quality

- [ ] **Single responsibility** — each route handler, service function, or database function does one thing
- [ ] **No dead code** — no commented-out blocks, unused imports, or unreachable branches

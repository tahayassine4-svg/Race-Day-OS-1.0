# Frontend Code Review Checklist

Used by the Code-Reviewer agent to evaluate all frontend/UI code changes. Mark each item PASS / FAIL / N/A.

---

## Components

- [ ] **Single responsibility** — each component does one thing; no component mixes data fetching, business logic, and rendering
- [ ] **Size limit** — no component or file exceeds 200 lines; oversized files are split at logical boundaries
- [ ] **Props typed** — all component props have explicit TypeScript types; no `any` or implicit types
- [ ] **No inline styles** — all styling uses Tailwind classes or the project's defined CSS system; no `style={{}}` attributes

## Data & State

- [ ] **No secrets in client code** — no API keys, tokens, or sensitive values in frontend files; env vars are prefixed `NEXT_PUBLIC_` only where safe to expose
- [ ] **User input sanitized** — any value rendered from user input uses the framework's built-in escaping; no `dangerouslySetInnerHTML` with unescaped user content
- [ ] **Loading and error states handled** — every async operation shows a loading indicator and a user-facing error message; no silent failures

## Accessibility

- [ ] **Interactive elements keyboard-accessible** — buttons, links, and form controls are reachable via Tab and operable via Enter/Space
- [ ] **Images have alt text** — all `<img>` elements have descriptive `alt` attributes; decorative images use `alt=""`

## Responsiveness

- [ ] **Responsive at 375px, 768px, 1280px** — no layout breaks, overflow, or unreadable text at the three standard viewports

## Code Quality

- [ ] **No dead code** — no commented-out code blocks, unused imports, or unreachable branches
- [ ] **Console logs removed** — no `console.log`, `console.error`, or debug output in production-bound code

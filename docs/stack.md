# Tech Stack — PaceCrew

## Recommended Stack

| Layer | Technology | Rationale |
|---|---|---|
| Framework | Next.js 14 (App Router) | Full-stack single codebase; server components for data-heavy planning pages; client components for interactive race-day views; best-in-class Vercel deployment |
| Styling | Tailwind CSS v3 | Utility-first, fast responsive breakpoints; enforces the desktop-planning / mobile-race-day split cleanly |
| UI components | shadcn/ui | Unstyled, copy-paste components built on Radix UI primitives; accessible, fully customizable, no bundle bloat |
| Auth | Auth.js v5 (NextAuth) | Supports email/password + Google OAuth out of the box; session stored in JWT or DB adapter; works with Next.js App Router |
| Database | PostgreSQL via Supabase | Managed Postgres; generous free tier; built-in Realtime subscriptions for live crew dashboard updates without a separate WebSocket service |
| ORM | Drizzle ORM | TypeScript-first, lightweight schema definition and migrations; faster than Prisma for this data shape; works directly with Supabase Postgres |
| Real-time | Supabase Realtime | Broadcasts row-level changes to all connected clients; used for live arrival logging → projected time updates; no extra infra |
| Deployment | Vercel | Zero-config Next.js deployment; preview URLs per branch; free tier covers portfolio traffic |

## Alternatives Considered

| Option | Why rejected |
|---|---|
| Remix | Good DX but smaller ecosystem; Vercel/Next.js edge is stronger for the planning-heavy data fetching pattern here |
| Prisma | Heavier runtime, slower cold starts, more complex migrations than Drizzle for this data model |
| Firebase / Firestore | Real-time is excellent but NoSQL is a poor fit for the relational race/segment/station/crew model |
| Railway + Express backend | Separate backend adds deploy complexity with no benefit for a portfolio-scale single-tenant app |
| Pusher / Ably for real-time | Supabase Realtime eliminates a third paid service; acceptable latency for this use case |

## Setup Instructions

### Prerequisites

- Node.js 20+
- pnpm (preferred) or npm
- A Supabase project (free tier at supabase.com)
- A Google OAuth app (for Google login, optional in dev)

### Local Development

```bash
# 1. Install dependencies
pnpm install

# 2. Copy env template
cp .env.example .env.local

# 3. Set required env vars (see below)

# 4. Push DB schema
pnpm db:push

# 5. Start dev server
pnpm dev
```

### Required Environment Variables

```
# Supabase
DATABASE_URL=postgresql://...
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...

# Auth.js
AUTH_SECRET=<random 32-char string>
AUTH_URL=http://localhost:3000

# Google OAuth (optional in dev)
AUTH_GOOGLE_ID=
AUTH_GOOGLE_SECRET=

# Email provider (for magic links / email verification)
AUTH_RESEND_KEY=
```

### Project Structure

```
pacecrew/
├── CLAUDE.md
├── .env.example
├── docs/
├── tasks/
├── reports/
├── app/
│   ├── frontend/                   ← Next.js App Router root
│   │   ├── (auth)/                 ← login, register, callback pages
│   │   ├── (app)/                  ← authenticated runner pages
│   │   │   ├── dashboard/          ← list of runner's races
│   │   │   ├── races/[id]/         ← race planning shell
│   │   │   │   ├── setup/          ← course + aid station setup
│   │   │   │   ├── pacing/         ← pace plan builder
│   │   │   │   ├── fueling/        ← fueling plan builder
│   │   │   │   ├── crew/           ← crew roster + assignments
│   │   │   │   └── checklist/      ← per-station card builder
│   │   │   └── layout.tsx
│   │   ├── crew/[token]/           ← magic-link crew view (no auth)
│   │   │   ├── page.tsx            ← crew dashboard
│   │   │   └── station/[id]/       ← per-station crew card
│   │   ├── layout.tsx
│   │   └── globals.css
│   ├── backend/
│   │   ├── db/
│   │   │   ├── schema.ts           ← Drizzle schema (all entities)
│   │   │   └── migrations/
│   │   ├── lib/
│   │   │   ├── auth.ts             ← Auth.js config
│   │   │   ├── supabase.ts         ← Supabase client (server + browser)
│   │   │   └── pacing.ts           ← pacing engine (pure functions)
│   │   │   └── fueling.ts          ← fueling engine (pure functions)
│   │   └── actions/                ← Next.js Server Actions
│   │       ├── race.ts
│   │       ├── station.ts
│   │       ├── crew.ts
│   │       └── events.ts
│   └── shared/
│       ├── types/                  ← shared TypeScript types
│       └── utils/                  ← shared helpers
├── tests/
│   ├── unit/                       ← pacing + fueling engine unit tests
│   └── e2e/                        ← Playwright end-to-end tests
└── drizzle.config.ts
```

## Key Architectural Decisions

### Desktop planning / mobile race-day split
- Planning routes (`/races/[id]/setup`, `/pacing`, etc.) use a sidebar layout, dense data tables, and forms optimized for a 1280px+ viewport.
- Crew route (`/crew/[token]`) uses a full-width stacked card layout, large tap targets, and minimal text density — designed for 375px+ in bright sunlight.
- A single `useMediaQuery` hook or Tailwind breakpoints enforce this; no separate codebase.

### Magic link implementation
- When the runner activates sharing, the server generates a `crew_token` (UUID v4) stored on the Race row.
- The crew URL is `/crew/[crew_token]` — no JWT, no session, just a hard-to-guess UUID.
- The crew token grants read access to the race plan and write access to `StationEvent` records (arrival logging, notes) only.
- Runner can rotate the token at any time to revoke crew access.

### Real-time architecture
- Supabase Realtime listens on the `station_events` table for `INSERT` events.
- On insert, the client re-fetches projections via a server action or recalculates client-side using the pacing engine (pure functions, safe to run in browser).
- No WebSocket management code in app — Supabase client handles reconnects.

### Pacing and fueling engines
- Implemented as pure TypeScript functions in `app/backend/lib/pacing.ts` and `fueling.ts`.
- No side effects, no DB calls — takes a plan object, returns computed values.
- Unit-testable in isolation; same functions run server-side (planning save) and client-side (live race-day recalculation).

# Packet 01: Foundation & Auth

## Goal

A working Next.js project with authentication, the full database schema, and a bare dashboard shell — the skeleton every future packet builds on top of.

## Requirements

- Initialize Next.js 14 (App Router) with TypeScript, Tailwind CSS, and shadcn/ui
- Configure Drizzle ORM pointing at a Supabase Postgres database
- Define the complete DB schema in one file: Race, AidStation, Segment, PacePlan, FuelPlan, CrewMember, CrewAssignment, StationChecklist, StationEvent
- Implement Auth.js v5 with two providers: email/password (Credentials) and Google OAuth
- Protect authenticated routes under `/(app)/` with a session middleware check
- Build a minimal dashboard page (`/dashboard`) that shows "No races yet" when the account is empty, with a placeholder "New Race" button (not wired up yet)
- Build sign-in (`/auth/login`) and sign-up (`/auth/register`) pages using shadcn/ui form components
- Provide `.env.example` with all required variable names

## Acceptance Criteria

- [ ] `pnpm dev` starts without errors
- [ ] `pnpm db:push` applies the full schema to Supabase with no errors
- [ ] A new user can register with email + password and land on `/dashboard`
- [ ] A user can sign in with Google OAuth and land on `/dashboard`
- [ ] Navigating to `/dashboard` without a session redirects to `/auth/login`
- [ ] All schema tables exist in Supabase after `db:push`
- [ ] `.env.example` documents every required variable

## Test Cases

- [ ] Register with a new email → session cookie set → redirect to `/dashboard` with "No races yet" state
- [ ] Sign in with Google → session cookie set → redirect to `/dashboard`
- [ ] Sign out → session cleared → `/dashboard` redirects to `/auth/login`
- [ ] Run `pnpm db:push` on a fresh Supabase project → all 9 tables created with correct columns and foreign keys

## Dependencies

None — this is Packet 1.

## Out of Scope

- Any race data creation or editing (Packet 02)
- The "New Race" button does not need to work — placeholder only
- Email verification flows
- Password reset
- User profile / account settings page

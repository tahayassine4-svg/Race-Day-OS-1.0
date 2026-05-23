# App Vision — Race Day OS

## App Name

**Race Day OS**

## Summary

PaceCrew is a web application that replaces the fragile system of spreadsheets, printed PDFs, and WhatsApp threads that ultra runners and their crews cobble together before and during a 100-mile or 100k race. A runner sets up their race once — segments, pacing scenarios, fueling targets, crew assignments, and per-station checklists — and the app generates a shared, living plan that crew members open on their phones via a magic link (no account required). On race day, when a crew member taps "Runner arrived," the app recalculates all projected arrival times and finish time in real-time so every crew member, everywhere on course, sees the same updated picture. The entire planning surface is desktop-optimized for the weeks before; the race-day surface is mobile-first for crew on the ground.

## Target Users

- **Primary:** First or early 100-mile / 100k runner with 2–4 crew members and 6–12 crew-accessible aid stations. Currently managing race logistics in spreadsheets and shared docs. Anxious about missing cutoffs, messing up fueling, or confusing crew.
- **Secondary:** Experienced crew members who have supported multiple runners and want a single organized view instead of digging through printed packets and WhatsApp threads on race day.

## Core Features (MVP)

1. **Race and course setup** — Runner defines race profile (name, date, distance, cutoff) and enters aid stations with metadata (crew access, pacer access, drop bag, services type). Segments between stations record distance and elevation gain/loss.

1a. **GPX + aid station import** — Runner uploads a GPX file (course track + waypoints) and optionally an Excel/CSV aid station sheet. The app parses both client-side, shows an elevation profile, and lets the runner place segment markers interactively. On confirm, all stations and segments are written to the DB in a single transaction, replacing any manual entry.

2. **Pacing and timing engine** — Runner sets a goal finish time; the app calculates per-segment duration and projected arrival clock times. Per-segment manual pace overrides allow for slow/steep sections. Three scenarios (optimistic / base / pessimistic) can be built simultaneously.

3. **Fueling and hydration planner** — Runner sets global targets (calories/hour, fluid/hour, sodium/hour); the app multiplies by per-segment duration to compute required fuel per segment, with cumulative totals and item-level notes (gels, real food, crew-prepared bottles).

4. **Crew roster and assignments** — Runner adds crew names and phone numbers, then assigns crew members to specific crew-accessible stations with optional role tags (driver, main handler, pacer, photographer).

5. **Per-station checklists** — Structured cards for every aid station: runner-side tasks (refills, salt tabs, gear swaps, mental anchors) and crew-side tasks (what to prepare, what to observe, what to carry out).

6. **Live arrival logging and auto-projection** — Crew taps "Arrived" on their phone; actual time is recorded, paces-so-far are computed, and projected arrival times for all remaining stations and the finish update instantly for everyone.

7. **Shared crew view (magic link)** — Runner generates a shareable URL. Crew opens it on their phone — no account, no install. Each crew member sees their next station, the ETA window, their task list, and a running log of past station arrivals and runner condition notes.

8. **Runner account** — Email + password or Google OAuth. Runner owns one or more races and controls the shared link.

## Out of Scope (v1)

- Strava / third-party course database import (GPX + Excel import now in v1 — see 1a above)
- Drop-bag packing planner (station checklists cover this sufficiently in v1)
- Print-to-PDF export
- Integrated crew chat or voice notes
- Live timing feed integration (race-published splits)
- Native mobile app or offline sync
- Billing / subscription / paywall
- AI pacing or fueling suggestions

## Success Criteria

- [ ] A runner can set up a full race plan (segments, pacing, fueling, crew, checklists) in under 30 minutes on desktop
- [ ] A crew member can open the magic link on a phone, find their next station and task list, and log the runner's arrival — without any instruction from the runner
- [ ] When a crew member logs an arrival, all other crew members' projected ETAs update within 3 seconds
- [ ] The app is usable without errors on Chrome/Safari mobile at 375px width

## Key Constraints

- Single Next.js codebase — no separate backend service
- Free-tier deployable (Vercel + Supabase free tiers must cover a portfolio project's traffic)
- Zero-install, zero-account for crew — magic link must be the only barrier
- No native app; responsive web only in v1

## Resolved Decisions

- **App name:** Race Day OS
- **Magic link write access:** Crew can write via the shared link — arrival logging and condition notes are crew-writable. Trust model is "anyone with the link can write"; token rotation handles revocation. Security hardening is post-v1.
- **Multi-race:** A runner account can hold multiple races in v1. Dashboard lists all races.

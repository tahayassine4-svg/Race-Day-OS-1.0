# Packet 06: Shared Crew View (Magic Link)

## Goal

A runner generates a single shareable URL; any crew member who opens it on their phone sees a mobile-optimized dashboard with their assigned stations, ETAs, task lists, and the runner's full station log — no account required.

## Requirements

- Runner can generate a crew link from the race detail page: clicking "Generate Crew Link" creates a `crew_token` (UUID v4) stored on the Race record and displays the shareable URL
- Runner can rotate the token (invalidates the old link, generates a new one)
- Crew route at `/crew/[token]` is fully public (no auth check); serves a mobile-optimized layout distinct from the planning shell
- Crew dashboard (`/crew/[token]`) shows:
  - Race name, start time, runner name (from account display name)
  - Ordered list of all aid stations with: station name, distance marker, projected arrival time (from active pacing scenario), crew access badge, "Arrived" button (only on crew-accessible stations)
  - Stations that have been logged show actual arrival time, status badge (Ahead / On Pace / Behind — based on actual vs projected), and any condition notes
  - "Your stations" section at top (if viewer is a named crew member — see notes below): highlighted cards for their assigned stations only
- Per-station crew card at `/crew/[token]/station/[stationId]`:
  - Station name, projected ETA, crew task checklist (read-only), runner task checklist (read-only)
  - Mental anchor note (read-only)
  - Fueling targets for that segment (calories, fluid, sodium)
  - "Runner Arrived" button → logs `actual_arrival` timestamp to `StationEvent`
  - Condition notes field → logs free-text notes to `StationEvent` (e.g., "Looks tired, stomach issues")
  - "Runner Departed" button → logs `actual_departure` timestamp
- The crew link does not require crew members to identify themselves; "Your stations" feature is best-effort via a name param in the URL (`/crew/[token]?crew=Alice`) — no login required

## Acceptance Criteria

- [ ] Runner generates a crew link — URL is displayed and copyable
- [ ] Opening the crew link in a new browser (no session) loads the crew dashboard without redirect to login
- [ ] Crew dashboard is usable at 375px width (no horizontal scroll, no clipped text)
- [ ] All aid stations appear in order with projected arrival times
- [ ] "Runner Arrived" on a station creates a StationEvent record with the current timestamp
- [ ] Condition notes field accepts text input and saves on submit
- [ ] Rotating the token: old URL returns 404 / redirects to expired page; new URL works
- [ ] Per-station crew card shows task checklists, fueling info, and mental anchor (read-only)

## Test Cases

- [ ] Open crew link in incognito browser → dashboard loads → station list visible → no login prompt
- [ ] Tap "Runner Arrived" on station 3 → StationEvent created → station 3 shows actual arrival time and status badge
- [ ] Enter condition note "Cramping, took extra salt" → save → refresh page → note still visible
- [ ] Rotate token → old URL → loads expired/invalid message → new URL → dashboard loads
- [ ] Open `/crew/[token]?crew=Alice` where Alice is assigned to stations 2 and 6 → "Your stations" section shows stations 2 and 6 highlighted at top
- [ ] View on iPhone SE (375×667): no horizontal overflow, buttons are at least 44px tall

## Dependencies

Packets 02, 03, 04, 05 — race setup, pacing plan, fueling plan, and crew assignments must all exist to populate the crew view meaningfully. Crew link generation only requires Packet 02 as a hard dependency.

## Out of Scope

- Real-time updates when another crew member logs an arrival (that is Packet 07)
- Crew authentication or individual crew accounts
- Push notifications to crew phones
- Crew-side editing of task checklists or race plan
- Offline mode / service worker caching

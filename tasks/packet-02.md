# Packet 02: Race & Course Setup

## Goal

A runner can create a race, define all aid stations with their metadata, and review the full course on a race detail page — the structured data that every other module reads from.

## Requirements

- "New Race" button on dashboard opens a race creation form: name, date/time, cutoff time, distance (km or miles), elevation (total gain), location name, and optional race guide URL
- After creation, runner lands on a race detail page at `/races/[id]`
- Race detail page has a sidebar nav with placeholder links for: Setup (active), Pacing, Fueling, Crew, Checklists — these pages do not need to work yet
- On the Setup tab, runner can add aid stations one by one: name, distance marker (km/mi from start), crew access (yes/no), pacer access (yes/no), drop bag available (yes/no), services type (full aid / water only / medical)
- Aid stations are displayed in a sortable list ordered by distance marker
- Each adjacent pair of aid stations auto-generates a Segment record with computed distance (difference between markers) — runner can manually add elevation gain/loss per segment
- Runner can edit or delete any aid station; the segment list updates accordingly
- Dashboard lists all races for the logged-in runner with name, date, distance, and station count

## Acceptance Criteria

- [ ] Runner can create a race with all required fields and it persists to DB
- [ ] Runner can add 10+ aid stations to a race without errors
- [ ] Aid stations display in distance-marker order
- [ ] Segments are auto-generated between consecutive stations; segment distance is correct (difference of markers)
- [ ] Editing a station's distance marker updates the adjacent segment distances
- [ ] Deleting a station removes it and its adjacent segments
- [ ] Dashboard shows all races for the logged-in user only (no cross-user leakage)
- [ ] Race detail page loads without errors for a race with 0 stations and for a race with 12 stations

## Test Cases

- [ ] Create a race → appears on dashboard → click to open detail page → no errors
- [ ] Add 3 stations at mile 10, 20, 30 → two segments created: 10 mi and 10 mi each
- [ ] Edit station 2's marker from 20 to 25 → segment 1 becomes 15 mi, segment 2 becomes 5 mi
- [ ] Delete station 2 → one segment created: 20 mi (station 1 to station 3) — or station 1 and 3 become the new adjacent pair
- [ ] Log in as User B → cannot see User A's races

## Dependencies

Packet 01 — auth and DB schema must exist.

## Out of Scope

- GPX or course database import (manual entry only)
- Elevation profile chart or course map visualization
- Pacing, fueling, or crew assignment (those are Packets 03–05)
- Print or export of any kind

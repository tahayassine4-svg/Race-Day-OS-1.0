# Packet 05: Crew & Station Checklists

## Goal

A runner can add crew members, assign them to specific aid stations with roles, and build per-station runner and crew checklists — producing the full set of "station cards" that drive race-day execution.

## Requirements

- Crew tab at `/races/[id]/crew` is now active
- Crew roster: add/edit/delete crew members with name and phone number
- Station assignments: for each crew-accessible aid station, assign one or more crew members with an optional role tag (Driver, Main Handler, Pacer, Photographer, Support)
- Crew member can be assigned to multiple stations
- Checklists tab at `/races/[id]/checklists` is now active
- Per-station checklist cards — one card per aid station (all stations, not just crew-accessible):
  - **Runner tasks:** ordered list of items the runner should do at this station (refill bottles, take salt tab, change socks, etc.); items can be added, reordered, deleted
  - **Crew tasks:** ordered list of items the crew should have ready or do (prepare bottles, check for blisters, swap headlamp, etc.); shown only if station has crew access
  - **Mental anchor:** optional free-text note the runner writes to their future self (e.g., "This is where it gets dark. Remember why you're here.")
- A "station card" preview shows how the card will look to crew on race day (read-only formatted view)

## Acceptance Criteria

- [ ] Runner can add 4 crew members with name and phone number; all persist to DB
- [ ] Each crew member can be assigned to multiple stations; one station can have multiple crew members
- [ ] Crew assignments appear on the station list in the Setup tab (crew name badges next to crew-accessible stations)
- [ ] Every aid station (crew-accessible or not) has a checklist card
- [ ] Runner tasks and crew tasks are independently editable per station
- [ ] Items can be reordered via drag-and-drop or up/down buttons
- [ ] Mental anchor note saves and persists on reload
- [ ] Station card preview renders the runner task list, crew task list, and mental anchor in a clean read-only layout
- [ ] Crew tasks section is hidden on the card for non-crew-accessible stations

## Test Cases

- [ ] Add 3 crew members → all appear in roster → assign crew member 1 to station 3 and 7 → both assignments saved
- [ ] Add 5 runner tasks to station 4 → reorder them → reload → order persists
- [ ] Station with crew_access = false → checklist card shows no crew tasks section
- [ ] Mental anchor: type "You trained for this." → save → reload → text still present
- [ ] Station card preview for a crew station shows runner tasks + crew tasks + mental anchor in formatted view

## Dependencies

Packet 02 — aid stations and crew access flags must exist.

## Out of Scope

- Drop-bag packing lists as a separate module (free-text notes in crew tasks cover this for v1)
- Crew-side editing of checklists (crew can view but not edit checklists via the magic link)
- Automated checklist templates or AI suggestions
- Pacer-specific briefing docs

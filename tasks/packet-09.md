# Packet 09: Elevation Profile + Interactive Segment Builder

## Goal

Give the user a visual, interactive way to define race segments from the imported GPX track. They see the full elevation profile with aid station positions overlaid as markers, click to adjust or add segment break points, review the resulting segment table (distance, elev gain/loss per segment), edit station details inline, and confirm — which writes the final `aidStations` and `segments` rows to the DB and feeds directly into the existing pacing engine.

---

## Requirements

- Create `components/import/elevation-chart.tsx` (client component):
  - Renders a recharts `AreaChart` with:
    - X-axis: cumulative distance in km (from `races.gpxTrackPoints`)
    - Y-axis: elevation in metres
    - Filled area for the elevation profile
    - Vertical dashed `ReferenceLine` for each station position (colour-coded: orange = crew access, grey = no crew)
    - Draggable station markers are not required — clicking near a station's distance on the chart selects it for editing in the table below (highlight the row)
  - Accepts props: `trackPoints: TrackPoint[]`, `stations: DraftStation[]`, `onStationClick: (index: number) => void`
  - Tooltip on hover shows: distance km, elevation m
  - No custom drag logic — interaction is in the table, not on the chart

- Define `DraftStation` type (in `lib/types/import.ts` or inline):
  ```ts
  type DraftStation = {
    id: string          // temp uuid (crypto.randomUUID)
    name: string
    distanceKm: number  // position on course
    crewAccess: boolean
    dropBag: boolean
    services: string    // 'full' | 'water' | 'medical'
    cutoffTime: string  // HH:MM string, empty = no cutoff
    isStart: boolean    // first station = race start
    isFinish: boolean   // last station = finish line
  }
  ```

- Create `components/import/segment-builder-table.tsx` (client component):
  - Renders one editable row per `DraftStation`
  - Columns: #, Name (text input), Dist km (number input, 1 decimal), Crew (checkbox), Drop Bag (checkbox), Services (select: Full / Water / Medical), Cutoff (time input HH:MM), Elev Gain ↑ (read-only, computed), Elev Loss ↓ (read-only, computed)
  - First row (Start) and last row (Finish) have name pre-filled and distance locked (0 and total km)
  - "Add station" button appends a new row at a distance between the last two rows (midpoint)
  - "Remove" button per row (disabled for Start and Finish rows)
  - Row highlighted when selected via chart click
  - Elevation gain/loss per segment computed from `gpxTrackPoints`: sum of positive / negative altitude changes between the two station distances
  - All changes are local state only (no DB writes) until Confirm

- Create `app/(app)/races/[id]/import/builder/page.tsx` (server component wrapper + client `BuilderClient`):
  - Server component: fetch `race.gpxTrackPoints` and `race.importedStations` from DB; if either is null, redirect to `/races/[id]/import`
  - Pass data to `BuilderClient`
  - `BuilderClient` holds `draftStations` in `useState`, initialised from `importedStations`; always ensures a Start station at 0 km and a Finish station at total km
  - Layout: elevation chart on top (full width), segment builder table below
  - "← Back to Import" link at top-left
  - "Confirm & Apply →" primary button at bottom-right:
    1. Validates: all station names non-empty, distances strictly increasing, no two stations within 0.1 km
    2. On validation pass: calls `confirmImport` server action
    3. On success: redirects to `/races/[id]/pacing`
    4. On validation error: shows inline error messages per row, does not submit

- Create `actions/import.ts` addition — `confirmImport(raceId, draftStations)` server action:
  - Validates raceId belongs to session user
  - Deletes existing `aidStations` and `segments` for this race (cascade handles pace_plans and fuel_plans)
  - Inserts new `aidStations` rows from `draftStations` in order, setting `sortOrder`, `cutoffSeconds` (parsed from HH:MM relative to race start time)
  - Inserts new `segments` rows: one per consecutive station pair, with `distanceKm`, `elevGainM`, `elevLossM` computed from track points
  - Calls `clearImportData(raceId)` to null out `importedStations`
  - Updates `races.distanceKm` and `races.elevationGainM` from the confirmed segment totals
  - All DB writes in a single transaction

- Update `docs/vision.md` — remove "GPX import" from the Out of Scope list and add it to Core Features as item 1a

---

## Acceptance Criteria

- [ ] Elevation chart renders the full track profile with station markers at correct positions
- [ ] Editing a station name in the table updates immediately (no save button needed)
- [ ] Moving a station's distance value updates the elevation gain/loss columns in real-time
- [ ] Adding a station inserts a row between the surrounding two and the chart marker appears
- [ ] Removing a station removes its row and chart marker
- [ ] Confirm button is disabled until all validation passes; error messages appear inline for each failing row
- [ ] On confirm, `aidStations` and `segments` are correctly written to DB with proper `sortOrder`
- [ ] Pacing page at `/races/[id]/pacing` loads without error after confirm (existing pacing engine works with the new segments)
- [ ] `npm run type-check` passes
- [ ] `npm run build` passes

---

## Test Cases

- [ ] Builder loads with 6 stations from a real GPX — verify chart shows 6 markers and table shows 6 rows
- [ ] Edit station name → confirm → reload setup page → name persists in DB
- [ ] Add a station → confirm → DB has N+1 stations and N+1 segments
- [ ] Remove a station → confirm → DB has N-1 stations and N-1 segments
- [ ] Confirm with a duplicate distance → validation error shown, no DB write
- [ ] Confirm with blank station name → validation error shown, no DB write
- [ ] After confirm, pacing page loads (no 500 error)
- [ ] type-check: PASS
- [ ] build: PASS

---

## Dependencies

- Packet 08 complete: `races.gpxTrackPoints`, `races.importedStations`, `actions/import.ts (saveImportData)` must exist
- `recharts` installed (done in Packet 08)
- Existing pacing engine (`lib/pacing.ts`) and pacing page unchanged — segments feed in automatically via existing DB queries

---

## Out of Scope

- Drag-to-reposition station markers on the chart (click-to-select + table edit is sufficient)
- Undo/redo history in the builder
- Saving a draft mid-edit (builder is a single-session flow; navigating away loses unsaved changes — acceptable for MVP)
- Elevation data smoothing or noise reduction
- Multi-lap / looped course support

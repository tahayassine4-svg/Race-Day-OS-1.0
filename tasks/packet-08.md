# Packet 08: GPX + Excel Import Pipeline

## Goal

Replace the friction-heavy manual course entry with an import-first flow. When creating or editing a race, the user uploads a GPX file (course track + waypoints) and optionally an Excel aid station sheet. Both files are parsed client-side, the results are summarised on screen, and the parsed data is persisted to the race record so Packet 09 can build the interactive segment editor on top of it.

Manual entry remains available as a fallback (skip import).

---

## Requirements

- Install `xlsx` (SheetJS) and `recharts` npm packages (recharts used in Packet 09 but installed here to keep dependency changes in one packet)
- Extend `lib/gpx-parser.ts`:
  - Add `TrackPoint` type: `{ cumKm: number; ele: number }`
  - Add `parseGPXToTrack(text: string): { points: TrackPoint[]; totalKm: number; elevGainM: number; error?: string }` — parses the full track, then samples down to ≤ 500 points evenly (always include first + last)
  - Existing `parseGPXFile` and `parseCSVStations` exports must remain unchanged
- Create `lib/excel-parser.ts`:
  - Accepts an `ArrayBuffer` (from `FileReader`)
  - Uses `xlsx` to read the first sheet
  - Auto-detects columns by matching header names (case-insensitive) against known aliases:
    - Name: `name`, `station`, `aid station`, `checkpoint`
    - Distance km: `distance`, `dist`, `km`, `distance (km)`, `dist km`
    - Crew: `crew`, `crew access`, `crew accessible`
    - Drop bag: `drop`, `drop bag`, `dropbag`
    - Services: `services`, `service`, `type`
    - Cutoff: `cutoff`, `cutoff time`, `time limit`
  - Returns `{ stations: ParsedStation[]; columnMap: Record<string, string>; unmappedHeaders: string[]; error?: string }`
  - If fewer than 2 required columns (Name + Distance) are detected, returns an error with `unmappedHeaders` listed so the user can see what was found
- Add 3 new JSONB / varchar columns to the `races` table in `lib/db/schema.ts`:
  - `gpxTrackPoints jsonb` — sampled `TrackPoint[]` (≤ 500 pts), null until imported
  - `importedStations jsonb` — `ParsedStation[]` holding the raw merged station list (GPX waypoints + Excel rows, deduplicated by proximity ≤ 0.5 km), null until imported and cleared after user confirms in Packet 09
  - `importSource varchar(20)` — `'manual' | 'gpx' | 'excel' | 'gpx+excel'`, default `'manual'`
- Add `cutoffSeconds integer` column to `aidStations` table (seconds from race start; null = no cutoff)
- Run `npm run db:push` (or `npx drizzle-kit push`) to apply schema — document this in the packet report
- Create `app/(app)/races/[id]/import/page.tsx`:
  - Two file drop zones, side by side on desktop, stacked on mobile:
    1. **GPX file** — `.gpx` only; shows a green check + summary (total km, elev gain, waypoints found) after successful parse; shows error state if parse fails
    2. **Aid Station Sheet** — `.xlsx`, `.xls`, `.csv` accepted; shows green check + station count + column mapping badges after parse; shows error state + unmapped headers if column detection fails
  - Both zones support click-to-browse and drag-and-drop
  - Files are parsed entirely client-side (no upload to server at this step)
  - A "Skip — enter manually" link at the bottom routes to `/races/[id]/setup`
  - A "Continue to Segment Builder →" primary button is enabled only when at least the GPX file is successfully parsed; clicking it:
    1. Calls `saveImportData` server action with the sampled track points + merged station list
    2. Navigates to `/races/[id]/import/builder`
  - If only Excel is uploaded (no GPX): disable the Continue button and show inline hint: "GPX file required to build the elevation profile. Add a GPX file or skip to manual entry."
- Create `actions/import.ts` with two server actions:
  - `saveImportData(raceId, trackPoints, stations, source)` — writes to `races.gpxTrackPoints`, `races.importedStations`, `races.importSource`, `races.distanceKm`, `races.elevationGainM`; validates raceId belongs to session user
  - `clearImportData(raceId)` — sets `importedStations` to null (called by Packet 09 after confirmation)
- Update the race creation redirect: after a new race is saved in `actions/race.ts`, redirect to `/races/[id]/import` instead of `/races/[id]/setup`
- Add a nav entry or button on the existing `/races/[id]/setup` page: "Re-import from GPX / Excel" → links to `/races/[id]/import` (allows replacing course data without deleting the race)

---

## Acceptance Criteria

- [ ] A `.gpx` file with `<trkpt>` elements and `<wpt>` waypoints parses correctly: total km, elevation gain, and station list appear in the summary card
- [ ] A `.gpx` file with only a track (no waypoints) parses correctly with a clear message: "No waypoints found — stations will come from your Excel sheet or manual entry"
- [ ] An Excel file with standard column names (Name, Distance, Crew, Drop Bag) auto-maps and shows a "4 columns mapped" badge
- [ ] An Excel file with non-standard headers shows the unmapped header names and disables the Continue button with an explanation
- [ ] Uploading both GPX + Excel merges stations: GPX waypoints and Excel rows within 0.5 km of each other are deduplicated (Excel data wins for name/crew/dropbag/services)
- [ ] `saveImportData` server action rejects calls from users who don't own the race (returns 403)
- [ ] After clicking Continue, `races.gpxTrackPoints` and `races.importedStations` are populated in the DB
- [ ] `npm run type-check` passes
- [ ] `npm run build` passes

---

## Test Cases

- [ ] Parse `tests/fixtures/sample.gpx` — verify km and elevation values match known file
- [ ] Parse an Excel file with exact column headers — verify all stations extracted
- [ ] Parse an Excel file with aliases ("Checkpoint", "Dist km", "Crew Access") — verify auto-mapping
- [ ] Parse an Excel file with no recognisable headers — verify error message lists the actual headers found
- [ ] Upload both GPX + Excel with overlapping stations — verify deduplication (1 station per location, Excel name wins)
- [ ] type-check: PASS
- [ ] build: PASS

---

## Dependencies

- Packets 01–07 complete (race record exists, session auth works)
- `lib/gpx-parser.ts` already exists — extend, do not rewrite
- DB must be accessible for `db:push` (Supabase connection string in `.env.local`)

---

## Out of Scope

- Server-side file storage (files are parsed in the browser, only the extracted data hits the DB)
- GPX segment-by-segment split without waypoints (handled in Packet 09 interactively)
- PDF aid station sheets
- Strava or third-party API imports
- The interactive elevation chart and segment builder (Packet 09)
- Editing the imported station list before the builder (edits happen in Packet 09)

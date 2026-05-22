# Packet 04: Fueling Planner

## Goal

A runner sets global fueling targets (calories, fluid, sodium per hour) and the app calculates exactly how much fuel is needed per segment and per station, with cumulative totals and item-level notes the crew can act on.

## Requirements

- Fueling tab at `/races/[id]/fueling` is now active
- Global targets form: calories per hour (kcal/h), fluid per hour (ml/h), sodium per hour (mg/h) — with sensible defaults (e.g., 250 kcal/h, 500 ml/h, 500 mg/h)
- Pure TypeScript fueling engine in `app/backend/lib/fueling.ts`:
  - Input: global targets, per-segment planned duration (from active pacing scenario)
  - Output: per-segment required calories, fluid, and sodium; running cumulative totals
- Fueling results displayed as a table: station name | segment duration | calories | fluid | sodium | cumulative calories | cumulative fluid
- Per-station notes section: free-text field for item-level specifics (e.g., "2 gels + 1 bar", "crew has pizza", "switch to broth after mile 60") — stored as FuelPlan.items
- Race-level summary: total calories, total fluid, total sodium across all segments
- Runner can override global targets for individual segments (e.g., higher calories on long climbs)

## Acceptance Criteria

- [ ] Setting global targets recalculates all per-segment values immediately (no save-and-reload)
- [ ] Per-segment calories = (segment duration in hours) × (calories/h target), correct to within 1 kcal rounding
- [ ] Cumulative totals are strictly increasing and match the sum of segment values
- [ ] Race summary totals match the sum of all segment values
- [ ] Per-station notes save and persist on reload
- [ ] Overriding one segment's targets does not affect other segments
- [ ] Fueling engine is a pure function: unit-testable in isolation from DB
- [ ] Page renders correctly with 0 segments and with 15 segments

## Test Cases

- [ ] Set 250 kcal/h; segment 1 duration = 2h → segment 1 calories = 500 kcal
- [ ] 10 segments, each 1h → cumulative calories at station 10 = 10 × hourly target
- [ ] Override segment 3 to 400 kcal/h → only segment 3 changes; all others unchanged
- [ ] Add note "2 gels + broth" to station 5 → save → reload page → note still present
- [ ] Unit test: `computeFuelPlan({ targets, segments })` returns correct per-segment and cumulative values

## Dependencies

Packet 03 — planned segment durations from the active pacing scenario are required inputs for the fueling engine.

## Out of Scope

- Specific product database (gel brands, calories per unit) — item notes are free-text only in v1
- Automatic gut-training recommendations
- Integration with nutrition tracking apps
- Fueling plan per crew bag / drop bag (that is a Should-have for v1.1)

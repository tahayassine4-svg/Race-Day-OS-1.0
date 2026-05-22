# Packet 03: Pacing Engine

## Goal

A runner can set a goal finish time, see per-segment pace and projected arrival clock times auto-calculated across all stations, and optionally override pace per segment or build up to three scenarios (optimistic / base / pessimistic).

## Requirements

- Pacing tab at `/races/[id]/pacing` is now active
- Runner sets a goal finish time (total hours:minutes); the engine distributes effort across segments proportional to segment distance by default
- Pure TypeScript pacing engine in `app/backend/lib/pacing.ts`:
  - Input: race start time, segments (distance, elev gain/loss), goal finish time, per-segment overrides
  - Output: per-segment planned pace (min/km or min/mi), planned duration, and projected arrival clock time at each station end
  - Elevation adjustment: apply a simple grade-adjusted pace modifier (e.g., +X sec/km per 100m gain) configurable by the runner
- Pacing results displayed as a table: station name | distance | elev | pace | segment duration | projected arrival time
- Runner can override pace for any individual segment; remaining unoverridden segments auto-recalculate to still hit goal time
- Three named scenarios: runner can toggle between Optimistic, Base, Pessimistic — each stores its own goal time and overrides independently
- "Active scenario" is stored on the Race record; it is the one used by Packets 04–07
- Race start time used as the clock anchor (set in race setup, editable here)

## Acceptance Criteria

- [ ] Setting a goal finish time populates all segment paces and arrival times with no manual input
- [ ] Projected arrival at the final station equals race start time + goal finish time (within ±1 minute rounding)
- [ ] Overriding one segment's pace causes all other unoverridden segments to recalculate so total time still matches goal
- [ ] Three scenarios exist and are independently editable
- [ ] Switching active scenario updates all projected times visibly
- [ ] Pacing engine is a pure function: same input always produces same output (unit-testable)
- [ ] Pacing table renders correctly for a race with 1 segment and a race with 15 segments

## Test Cases

- [ ] Race: 100 miles, goal: 24:00, flat course (no elevation) → every segment pace ≈ 14:24/mi → final arrival = start + 24h
- [ ] Override segment 3 to 20:00/mi (slower) → remaining segment paces recalculate → total still = 24h
- [ ] Add 1000m elevation gain to segment 1 → with grade adjustment enabled, segment 1 slows → other segments compensate
- [ ] Unit test: `computePacePlan({ ... })` returns deterministic output for given inputs
- [ ] Switch from Base to Pessimistic scenario → table updates immediately without page reload

## Dependencies

Packet 02 — segments must exist with distance and elevation data.

## Out of Scope

- Live race-day recalculation (Packet 07)
- Elevation profile chart
- Terrain type or surface adjustments beyond grade
- Heart-rate or power-based pacing models
- Export of pace plan

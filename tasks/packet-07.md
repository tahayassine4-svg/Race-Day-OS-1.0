# Packet 07: Live Race Day (Real-Time Updates & Projections)

## Goal

When any crew member logs a runner's arrival, every other crew member's dashboard updates within 3 seconds — projected times recalculate based on actual pace so far, and status badges show whether the runner is ahead, on pace, or behind.

## Requirements

- Supabase Realtime subscription on the `station_events` table: any INSERT or UPDATE to `station_events` for a given race triggers a live update on all connected crew dashboards for that race
- On arrival log: recompute all remaining projected arrival times using actual paces from logged arrivals so far
  - Actual pace for completed segments = (actual_arrival[n] – actual_arrival[n-1]) / segment_distance
  - For remaining segments: blend actual pace trend with original planned pace (configurable weight, default: 80% actual trend, 20% plan)
  - Reuse `computePacePlan` pure function from Packet 03, feeding in actual elapsed times as new anchors
- Status badge per station:
  - **Ahead** (green): actual arrival was earlier than projected by > 5 minutes
  - **On Pace** (yellow): within ±5 minutes of projected
  - **Behind** (red): actual arrival was later than projected by > 5 minutes
- Updated projected finish time displayed prominently on crew dashboard
- Estimated time to next crew station displayed as a countdown ("ETA: ~47 min")
- Runner detail page (authenticated, at `/races/[id]`) also subscribes to Realtime and shows live arrival log and status badges so the runner or support can monitor from a laptop
- All real-time updates are non-breaking: if a client loses connection, they see the last known state and a "Reconnecting…" indicator; on reconnect they get the latest state

## Acceptance Criteria

- [ ] Two browser windows open to the same crew link: logging arrival in window 1 updates window 2 within 3 seconds without a page reload
- [ ] After logging arrivals at stations 1–3, projected arrival times for stations 4–N update to reflect actual pace trend
- [ ] Status badges display correctly: a runner who arrived 10 min early shows Ahead (green); 3 min late shows Behind (red)
- [ ] Projected finish time updates after every logged arrival
- [ ] Disconnecting and reconnecting a client: state is consistent with latest arrivals after reconnect
- [ ] "Reconnecting…" indicator is visible while Supabase Realtime is disconnected (simulate by toggling network in DevTools)
- [ ] Runner's authenticated race detail page receives the same Realtime updates

## Test Cases

- [ ] Open crew dashboard in two incognito windows (A and B) → log arrival in A → B updates within 3 seconds
- [ ] Log arrivals at first 3 stations at exactly planned times → status badges all show "On Pace" → remaining projections unchanged
- [ ] Log arrivals at first 3 stations each 15 min early → status badges "Ahead" → remaining projected times shift earlier
- [ ] Log arrival at station 5 that is 30 min late → remaining projections shift later → projected finish time increases
- [ ] Disable network in DevTools on window B → log arrival in A → re-enable network in B → B shows latest state
- [ ] Unit test: `recomputeProjections(actualArrivals, segments, plan)` returns correct updated projected times

## Dependencies

Packets 02, 03, 06 — race segments, pacing plan, and crew view (with StationEvent writes) must all exist. Supabase Realtime must be enabled for the `station_events` table in the Supabase project settings.

## Out of Scope

- Push notifications (in-app browser updates only)
- SMS or email alerts when runner is behind pace
- Automated pacer or crew dispatch suggestions
- AI-based pacing adjustment recommendations
- Offline-first sync with conflict resolution

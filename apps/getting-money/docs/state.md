phase: REPORTER
app: getting-money
packet: 08
status: PACKET_08_COMPLETE — v1 feature-complete; 63/63 tests green; unsigned archive verified; signing+upload handed to Yassine
last_action: review round 2 — fixed payoff-clobber on the Debt→Rounds shortcut via requestPayoff(.full) that survives the tab-switch reload; rendered payoff-active Rounds state; 67/67 green
branch: packet-08-history-polish
commit: (committing now)
next_step: Yassine configures DEVELOPMENT_TEAM + signing and archives to TestFlight (steps in reports/packet-08-report.md). Optional fast-follows: branded launch screen, stored daily-debt snapshot for a debt-trend chart.
timestamp: 2026-06-14T04:26:00Z
notes: |
  All 8 packets COMPLETE. App builds, 63 tests pass, archives unsigned.
  TestFlight is the only remaining step and requires an Apple Developer team — Yassine owns it.
  DEBUG fixtures: -GMSeedDebtFixture, -GMSeedHistoryFixture, -GMInitialTab <tab> (screenshot helpers only).

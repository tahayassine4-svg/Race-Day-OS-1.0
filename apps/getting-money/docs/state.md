phase: REPORTER_COMPLETE
app: getting-money
packet: 14 — Home-Screen Widget (Daily Targets)
status: TESTED — read-only daily-targets widget built; app publishes today's snapshot to App Group group.com.yassine.gettingmoney; 98/98 tests; widget UI + App Group write verified on simulator; freshness hardened (publish on background + new-day reset). Provisioning steps required before TestFlight (see packet-14-report).
last_action: Built WidgetKit extension + App Group snapshot publisher, future-proofed for optional Dips, ran 96/96 tests, screenshot-verified the widget content + on-disk App Group write.
branch: packet-14-widget
commit: —
next_step: Yassine completes App Group + widget App ID provisioning (packet-14-report → Provisioning), bumps build number, archives with automatic signing, uploads to TestFlight.
timestamp: 2026-06-14T16:55:00Z
notes: |
  Widget is READ-ONLY (tap-to-open), not interactive +1 — chosen per the user's stated fallback to avoid moving the live SwiftData store into the App Group (TestFlight data-safety). Live store untouched; no schema/migration change.
  Optional Dips appears in the widget automatically when enabled (buildSnapshot filters .isEnabled) — verified with -GMEnableDips.
  App Group: group.com.yassine.gettingmoney (identical in both entitlements + WidgetShared). Widget bundle id: com.yassine.gettingmoney.widget.
  New files: Shared/WidgetShared.swift, GettingMoney/Services/WidgetSnapshotPublisher.swift, GettingMoneyWidget/*, both *.entitlements, GettingMoneyTests/WidgetSnapshotTests.swift.
  DEBUG screenshot harness: -GMWidgetPreview renders DailyTargetsContent in-app (simctl can't capture live widgets).
  Prior context (P09–P13): debt day-close + cap, live payback, actionable rounds, dashboard day selector, past-day corrections. Last app commit 8bc2972.
  System skills (repo .claude/skills): resume-app, ui-test.

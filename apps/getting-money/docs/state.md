phase: REPORTER
app: getting-money
packet: 11 (Actionable Rounds + Settings fixes)
status: PACKET_11_COMPLETE — all reported issues fixed. 88/88 tests green; archives unsigned; TestFlight-ready. Signing+upload is Yassine's.
last_action: Reworked Rounds into an actionable workout (tick circles → balance, up to 10, editable, completion derived from tagged reps). Fixed dips toggle (can turn off) + removed pull-up cap. Verified end-to-end in Simulator + /ui-test sweep + archive succeeds.
branch: packet-09-debt-day-close
commit: packet-11 feat + settings-fix committed
next_step: Yassine configures DEVELOPMENT_TEAM + signing and uploads to TestFlight (steps in reports/packet-08-report.md). Optional polish: animated rep count-up; branded launch screen.
timestamp: 2026-06-14T13:25:00Z
notes: |
  Debt loop (P09 day-close + cap, P10 live payback) and Rounds loop (P11 tick→balance) both work end-to-end.
  Rounds completion derived from RepEntry.sourceRoundNumber tags (survives reload + replaceRoundPlans).
  Pull-up cap removed (AppSettings.pullupCap field kept, unused). Dips toggle always present for optional rows.
  DEBUG fixtures: -GMSeedDebtFixture, -GMSeedHistoryFixture, -GMSeedMissedDaysFixture, -GMSeedPaybackFixture, -GMSeedRoundDoneFixture, -GMEnableDips, -GMInitialTab <tab>, -GMPayoffFull.
  Reports: qa-full-ui-test.md, packet-09-report.md, packet-10.md, packet-11.md, qa-ui-test-2.md. Artifacts: reports/artifacts/qa/*.png.
  System skills (repo .claude/skills): resume-app, ui-test.

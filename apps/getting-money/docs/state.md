phase: REPORTER_COMPLETE
app: getting-money
packet: 13 — Past-Day Rep Corrections
status: TESTED_AND_EXPORTED — past days can be opened from Dashboard into Log, corrected, saved, reconciled against debt, and the refreshed IPA is ready for TestFlight upload.
last_action: Added past-day Log corrections, preserved Dashboard selected-date context, ran 92/92 tests, verified the simulator UI flow with screenshots, archived, and exported a Packet 13 IPA.
branch: packet-09-debt-day-close
commit: —
next_step: Upload apps/getting-money/build/export-p13/GettingMoney.ipa to App Store Connect/TestFlight for bundle ID com.yassine.gettingmoney.
timestamp: 2026-06-14T13:23:00Z
notes: |
  TestFlight signing fix verified in reports/testflight-signing-fix.md.
  Latest Packet 13 archive: apps/getting-money/build/GettingMoney-P13.xcarchive. Latest IPA: apps/getting-money/build/export-p13/GettingMoney.ipa (bundle com.yassine.gettingmoney, version 1.0.0, build 2).
  Debt loop (P09 day-close + cap, P10 live payback) and Rounds loop (P11 tick→balance) both work end-to-end.
  Dashboard Daily selector (P12) is verified with reports/artifacts/qa/p12-dashboard-daily-toggle.png.
  One missed day debt QA verified with reports/qa-one-missed-day-debt-test.md and p13-one-missed-day-*.png artifacts.
  Past-day correction UI verified with reports/packet-13-report.md and p13-past-day-*.jpg artifacts.
  Rounds completion derived from RepEntry.sourceRoundNumber tags (survives reload + replaceRoundPlans).
  Pull-up cap removed (AppSettings.pullupCap field kept, unused). Dips toggle always present for optional rows.
  DEBUG fixtures: -GMSeedDebtFixture, -GMSeedOneMissedDayFixture, -GMSeedHistoryFixture, -GMSeedMissedDaysFixture, -GMSeedPaybackFixture, -GMSeedRoundDoneFixture, -GMEnableDips, -GMInitialTab <tab>, -GMPayoffFull.
  Reports: qa-full-ui-test.md, packet-09-report.md, packet-12-report.md, packet-13-report.md, qa-one-missed-day-debt-test.md, qa-ui-test-2.md. Artifacts: reports/artifacts/qa/*.
  System skills (repo .claude/skills): resume-app, ui-test.

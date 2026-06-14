# Packet Index — Getting Money

App: native iOS (Swift 6 · SwiftUI · SwiftData local-only) → TestFlight. Build order follows the layer cake: foundation → data → targets → logging/earnings → debt → rounds → payback → polish/TestFlight.

| # | Name | UI? | Status | Branch | Commit |
|---|------|-----|--------|--------|--------|
| 01 | Foundation + Premium Design System | UI | COMPLETE | packet-01-02-foundation-persistence | 9b8d597 |
| 02 | Local Data Models + Persistence (SwiftData) | backend (+small Settings UI) | COMPLETE | packet-01-02-foundation-persistence | 9b8d597 |
| 03 | Targets + Two-Week Progression | UI | COMPLETE | packet-03-targets-progression | 415ae17 |
| 04 | Rep Logging + EarningsEngine | UI | COMPLETE | packet-04-rep-logging | f741440 |
| 05 | DebtEngine + Debt Dashboard | UI | COMPLETE | packet-05-debt-engine | 03b4122 |
| 06 | Rounds / Circles Planner | UI | COMPLETE | packet-06-rounds-planner | 6cc00bb |
| 07 | Dynamic Debt Payback Planner | UI | COMPLETE | packet-07-payback-planner | 12a56f0 |
| 08 | History, Polish + TestFlight Readiness | UI | COMPLETE | packet-08-history-polish | e33a58f |

Source root: `apps/getting-money/GettingMoney/` · Tests: `apps/getting-money/GettingMoneyTests/` · Mockups: `apps/getting-money/design/packet-NN.png` (dark/lime/coral, from `design/reference-mockup.png`).

phase: TESTER → GIT
app: getting-money
packet: 20 — Training Bank redesign (from Claude Design file)
status: BUILD GREEN · all 6 screens screenshot-verified vs design · 108 tests (104 pass, 2 PRE-EXISTING failures unrelated to this packet). COMMITTED on branch.
last_action: Full presentation redesign to the "Training Bank" Claude Design file. Reused the entire data/service/ViewModel layer (no engine/model changes); rewrote tokens + all screens + shell.
branch: packet-20-training-bank-redesign
commit: (this packet's commit)
next_step: Release .xcarchive → REPORTER. Awaiting Yassine on gate items below.
timestamp: 2026-07-11T15:12:00Z
notes: |
  WHAT CHANGED (Packet 20):
  - New brand fonts bundled + runtime-registered: Space Grotesk (display/numbers), Manrope (body). OFL, from google/fonts.
  - Design tokens rewritten (GMTheme/GMTypography/GMSpacing): lime #C6F833 accent, coral #FF5B5B debt, dark radial backdrop. Legacy pixel tokens retained temporarily so the outgoing views still compile.
  - New component kit (DesignSystem/Bank/): AmbientBackground, WalletCard (scroll-collapse), StatusPill, ExerciseGoalCard, CoinFlipView, GMToast/ToastCenter, FloatingTabBar, ScrollOffset.
  - Screens rewritten/new: DashboardScreen, RoundsScreen, BankScreen (NET-NEW), DebtScreen, TargetsScreen, OnboardingView (NET-NEW, @AppStorage gated).
  - New shell AppRootView: custom floating tab bar (Dashboard/Rounds/Bank/Debt) + gear→Targets + toast host + onboarding gate. Same scenePhase day-close + widget publish preserved.
  - New VMs/logic: BankViewModel; DashboardViewModel.logReps (toast breakdown); RoundsViewModel.exercises/debtByKey/logExtra; DebtViewModel finance options 1..7. Engines untouched.
  - Tests added: TrainingBankRedesignTests (4, all green) covering logReps breakdown + Bank economy.

  SCREENSHOTS: scratchpad/shots/p20-{dashboard,onboarding,rounds,bank,debt-clean,targets-clean}.png — all match the design file.

  ⚠️ GATE ITEMS FOR YASSINE (see report):
  1. Two tests RED (ReconciliationTests: day-close debt == 40). PROVEN pre-existing on baseline 43d7d5a — NOT a regression of this packet. In the economic core; worth a dedicated fix packet.
  2. The approved nav change dropped the old Settings tab, which also hosted the BETA data export/reset + progression amount/interval tuning. New Targets screen exposes only the auto-progression toggle. Those utilities are currently unreachable — decide if they need a home.
  3. Dead pixel views + legacy tokens remain in-tree (harmless, compiling). Cleanup deferred.

  KNOWN COSMETIC (follow-ups): dashboard/targets "100" left-glyph tightness; Bank "Missed reps +$0" sign.

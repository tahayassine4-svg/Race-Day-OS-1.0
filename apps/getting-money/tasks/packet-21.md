# Packet 21 — Main Menu Fix, Alive Animations, Splash, Reset

UI? Yes (dashboard, targets, launch). Backend? Tiny (wire the existing reset).

## Goal
Make the main menu (Dashboard) render correctly and feel top-tier alive: fix the
glitched upper half, make the wallet card genuinely animated on device, add a
branded animated splash on launch, restore a way to reset all reps on the device,
and tighten motion across the shell.

## Diagnosed bugs (verified on Simulator, 2026-07-11)
1. **Glitched upper half** — `DashboardScreen` puts the `WalletCard` in a pinned
   `Section` header whose backdrop gradient overhangs `-60pt` above the card
   (`pinnedBackdrop`). At rest it paints *over* the greeting row, showing a dim
   ghosted "Your Bank" + washed-out greeting behind the status bar. Fix: restructure
   the header so the greeting sits above the pinned region and the backdrop never
   overlaps it (opacity driven by collapse progress only when actually scrolled).
2. **Card "not animated / weirdly animated"** — the sheen uses
   `.onAppear + withAnimation(repeatForever(autoreverses:false))`: it snaps back
   instantly at the loop end and dies whenever the pinned header re-renders during
   scroll (collapse changes). Fix: drive the sheen (and coin shimmer) from a
   `TimelineView`/phase animator so it survives re-renders, sweeps → pauses → sweeps,
   and respects Reduce Motion.

## Scope
- Dashboard top: greeting row always crisp; wallet card collapse stays smooth
  (spring-tracked, no jumps); status pill + goal cards get a one-time staggered
  entrance (fade + 8pt rise); balance changes count up (`contentTransition(.numericText)` everywhere money changes).
- Wallet card: TimelineView-driven sheen; subtle idle "breathing" of the coins;
  tilt-on-press. All gated by `accessibilityReduceMotion`.
- Splash: branded launch overlay (bank glyph coin drops + lime pulse ring +
  wordmark fade, ~1.1s, skips on Reduce Motion) shown once per cold launch over the
  ambient backdrop, then cross-fades into the dashboard.
- Reset: "Danger zone" section on the Targets screen — "Reset all reps" with a
  destructive confirmation dialog → calls the existing
  `SettingsViewModel.resetAllData()` (`LocalStore.resetAllLocalData`), reloads all
  VMs and republishes the widget. (Restores the utility lost in Packet 20 —
  gate item #2.)
- Tab switches: content cross-fade + slight vertical parallax (150–220 ms per
  ui-system motion rules).

## Acceptance criteria
- [ ] At rest, no ghosted/dimmed duplicate of the greeting or bank name anywhere
      on the dashboard (screenshot-verified vs mockup).
- [ ] Scrolling collapses the wallet card smoothly; releasing anywhere leaves no
      half-state jitter.
- [ ] The wallet sheen visibly animates on device/Simulator and keeps animating
      after scrolling; disabled under Reduce Motion.
- [ ] Cold launch shows the splash animation once, then the dashboard; Reduce
      Motion gets a plain fade.
- [ ] Targets screen offers "Reset all reps" behind a destructive confirmation;
      confirming zeroes reps/debt/bank on device and the dashboard + widget
      reflect it immediately.
- [ ] All existing tests stay green; new tests cover reset wiring (VM → store)
      and splash gating logic.

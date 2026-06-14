---
name: ui-test
description: Run a full UI / system test of a built iOS app — drive every feature in the Simulator, verify the numbers are computed correctly (not just that screens render), fix display/wiring bugs inline, surface design gaps as gates, and report in a structured format. Use whenever Yassine says "test the UI", "run a full UI test", "do a UI test of <app>", "check all the features work", or "make sure the numbers are right".
---

# Full UI / System Test

This skill runs the **TESTER** phase as a complete, app-driving QA pass — not just unit
tests. The goal is to answer three questions Yassine cares about: **do all the features
work, do the numbers calculate right, and does the system work end-to-end?** Fix what's
broken; surface what needs a decision; only report "all green" when it truly is.

Start your response with `**Phase: TESTER**`.

## 0. Orient
- Resolve which app (see `apps/<name>/`; legacy apps at repo root). Read `prompts/tester.md`
  and `knowledge/ios-testing.md` (they govern this phase).
- Find the Simulator + tooling: `xcrun simctl list devices available | grep -i iphone`
  (use a booted one or boot one), `which xcodegen`, `xcodebuild -version`.

## 1. Baseline (never edit before this is green)
- `xcodegen generate` (if the app uses it), then run the **full unit suite**:
  `xcodebuild test -project <App>.xcodeproj -scheme <App> -destination 'platform=iOS Simulator,id=<UDID>'`.
- A red baseline is reported immediately — you can't tell what your changes broke otherwise.

## 2. Learn what the numbers SHOULD be (this is what makes it a real test)
Read the calculation engines, ViewModels, and formatting so you can **compute expected
values by hand**, then compare to what's on screen. "Looks reasonable" is not the bar.
- Engines/services (the math), ViewModels (wiring), number/format helpers (how values render).
- Find the app's DEBUG seed/launch-arg fixtures (e.g. `grep -rn "ProcessInfo\|arguments\|Fixture\|InitialTab"`).
  Map each fixture → which screens/numbers it populates, and note the default `repValue`/units.
- **Critical check:** is every headline number reachable in a *static* seeded state? If the
  core loop's live number (e.g. "earned today") can only appear after interactive taps and
  no fixture reaches it, add a tiny DEBUG seed fixture — far cheaper than UI automation.

## 3. Drive the app — screenshot every screen in every meaningful state
The factory's verification method is **seeded launch args + `simctl` screenshots**, not a
standing XCUITest target (don't build one unless a single tap-flow leaves real doubt).
- Build + install once with a controlled path:
  `xcodebuild build ... -derivedDataPath build/dd`; app at `build/dd/Build/Products/Debug-iphonesimulator/<App>.app`.
- For each (state, tab): **reinstall for clean state if any fixture is additive**
  (e.g. logging fixtures accumulate across launches), launch with the fixture + initial-tab
  args, `sleep 3`, then `xcrun simctl io booted screenshot out.png`. Read every screenshot.
- Cover **every tab in both empty and populated states**: first-launch/empty, populated
  with realistic data, and each special state the app has (debt, payoff, streaks, etc.).

## 4. Compute-then-compare + judge each finding
For every screen, assert the displayed number equals your hand-computed value. When something
is off, classify it:
- **Display / wiring / formatting bug** (hardcoded value, dead button, wrong binding, wrong
  format, contradictory state between screens) → **fix it inline.** Add/extend a test that
  proves the fix, rebuild, re-screenshot to confirm. This is in scope.
- **Spec / design question** ("is this number supposed to be X or Y?", an unimplemented or
  underspecified mechanic) → **do NOT guess.** "Fix" presupposes the intended value. Surface
  it as a gate with a concrete proposal and the specific decision needed. (See `CLAUDE.md`:
  new scope needs a gate; surface blockers.)
- Honor the **3-retry limit** per `CLAUDE.md` — if one fix fails three times, write an
  escalation instead of grinding.
- Re-run the full unit suite after fixes; keep it green.

## 5. Report (structured, honest)
Write `apps/<name>/reports/qa-full-ui-test.md` and update `docs/state.md` (phase: TESTER).
Report in this shape:
- **Verdict** up top: shippable / not — and why in one line.
- **Bugs fixed** — file:line, what was wrong, the fix, the test, the screenshot proof.
- **Gaps surfaced** — the design decision needed + a concrete proposed packet.
- **Coverage table** — each screen, the states checked, the exact numbers verified.
- **Static-screenshot limits** — state plainly what screenshots can't exercise (segmented
  controls, share sheets, confirmation dialogs, tap-driven navigation) and how those are
  otherwise covered (unit/integration tests, code read). Naming the limits is what makes
  the report trustworthy.
- Save artifacts under `reports/artifacts/qa/`.

## Rules
- **Don't commit** unless Yassine directs it (or hand off to GIT per the factory flow).
  Surface gates before declaring done — if a core feature is inert, you cannot report "all
  features work."
- **Use the advisor** before committing to the test strategy and before declaring done.
- This skill fixes bugs and surfaces decisions; it does not invent product behavior.

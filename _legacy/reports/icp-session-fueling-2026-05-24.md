# ICP Session Report — Fueling Tab Focus
## Date: 2026-05-24

---

## Persona

I'm Alex — a serious ultra runner with 4 finishes including a 100-miler, who currently plans every race across a Google Sheet (pacing), a separate notes app (fueling), and a Word doc for crew. My core frustration is that changing my goal time means touching all three manually. I came to the Fueling tab expecting to set my hourly targets, see how they break down by segment, and feel confident walking into the race knowing exactly what I need at each station.

---

## Flows Tested

| Flow | Status | Notes |
|---|---|---|
| First look at Fueling tab (no segments) | ✅ Completed | Form visible, structure clear |
| Set global fueling targets (Cal/h, Fluid/h, Sodium/h) | ❌ Blocked | "Apply targets" drops session → login page |
| Understand what the table columns mean | ⚠️ Partial | Reviewed from code — blocked from testing live |
| Per-segment override flow | ⚠️ Partial | Reviewed from code — blocked from testing live |
| Station notes field discovery | ❌ Blocked | Field exists but nearly invisible |
| Mobile view of fueling tab | ❌ Blocked | Session dropped before mobile capture |

---

## Findings

### Flow 1 — First impression (no segments)

**What I did:** Landed on the Fueling tab with no segments set up yet.

**What I found:**
The form appears immediately — "Global fueling targets" with three fields: Cal/h (kcal), Fluid/h (ml), Sodium/h (mg), and an "Apply targets" button. Below is a dashed empty state pointing me to add aid stations. The structure is logical and I knew what to do.

However, the defaults (250 cal/h, 500 ml/h, 500 mg/h) appear pre-filled with no explanation of where those numbers come from. For a runner who doesn't know their targets yet, there's no guidance — is 250 right for a 100-miler? Too low? Is 500 mg sodium enough at altitude? The form treats me like I already know, which I do, but a runner a few races in might not.

**Severity:** MINOR

---

### Flow 2 — Saving global targets (BLOCKING BUG)

**What I did:** Entered 250 / 500 / 500 into the three fields and clicked "Apply targets."

**What I found:** The page immediately redirected me to the login screen. My data may or may not have been saved — I had no way to know. When I logged back in, the values appeared to have persisted (from a previous session), but the save action itself destroyed my session.

From Alex's perspective: I just spent time entering my nutrition numbers and the app logged me out. I have no idea if it saved. I'm not clicking through that again without knowing it won't happen.

**Severity:** BLOCKING — users cannot save fueling targets. Complete loss of trust in the flow.

**Screenshot:** fuel-05-after-save-targets.png (shows login page after clicking Apply)

---

### Flow 3 — Understanding the table (code review, no segments)

**What I did:** Read the FuelingTable component to understand what Alex would see once segments exist.

**What I found:**

The table headers are: Segment | Time | Cal | Fluid | Sodium | ∑Cal | ∑Fluid | (actions)

Several issues:

1. **"∑Cal" and "∑Fluid" but no "∑Sodium"** — cumulative sodium is missing. For a 30-hour ultra, sodium management is as important as calories. Hyponatremia is a real risk. Alex would want to see cumulative sodium trending up across the race.

2. **"Cal" column has no unit in the cell** — the fluid cells show "ml" or "L" inline, sodium shows "mg", but the calorie cells show a bare number (e.g., "1,250"). Alex would wonder: is that kcal? kJ? The header says "Cal" but the form above says "Cal/h (kcal)". Inconsistency creates doubt.

3. **"∑" symbol** — mathematically correct but not natural for a runner. "Total Cal so far" or "Running Cal" would be clearer. An ultra runner coming from a spreadsheet is used to column labels like "Cumulative" or "Running total."

4. **No unit on the table's Cal column** — see point 2.

**Severity:** ANNOYING (items 1, 2) / MINOR (item 3)

---

### Flow 4 — Per-segment override flow (code review)

**What I did:** Reviewed the inline edit expand pattern for per-segment overrides.

**What I found:**
- Override is triggered by an "Override" button on the row. The row expands inline with three mini-fields.
- The edit labels say: "Cal/h", "Fluid ml/h", "Sodium mg/h" — these are inconsistent with the global form which uses "Cal/h (kcal)", "Fluid/h (ml)", "Sodium/h (mg)". Minor but noticeable if you're reading carefully.
- A manual override is flagged with a "✎" amber symbol on the Cal column. Clever, but if Alex doesn't notice it, they won't know which segments were customized.
- To reset, there's a "Clear" button. Good. But there's no confirmation — one misclick clears a custom value Alex spent time on.

Alex would use this for specific segments: "Night miles — I eat less. Day miles after a long climb — I eat more." The concept is solid, the interaction is usable.

**Severity:** ANNOYING (missing override summary / one-click clear risk) / MINOR (label inconsistency)

---

### Flow 5 — Station notes field discovery

**What I did:** Examined the FuelingTable component for the notes field.

**What I found:** There's a notes input below every segment row. It's completely borderless, transparent background, with muted placeholder text ("Notes for [Station]…"). On first use, a runner would scroll right past it. Alex would absolutely use this: "pick up Tailwind and extra gels here" or "crew hands me warm food at Winfield." But they'd never find it without being told it exists.

The feature saves on blur (losing focus), which is the right UX. But there's no visual indicator that a note was saved, and the field is invisible until focused.

**Severity:** ANNOYING — a genuinely useful feature that most users will miss.

---

### Flow 6 — No connection to race time or estimated total

**What I did:** Looked at what the page shows when all data is present.

**What I found:** The FuelSummary card at the bottom shows totals: X kcal, X.XL fluid, Xg sodium. These are calculated from segment durations × hourly rates. Good.

But there's no bridge between the global targets form and the race's estimated total time. Alex knows they plan to run Leadville in 28 hours. At 250 cal/h, that's 7,000 kcal. The app could show this immediately — "At 250 cal/h × your ~28h plan = 7,000 kcal" — right in the global targets card, before segments exist.

Right now that insight is locked behind the full setup flow (aid stations → pacing → back to fueling). Alex would want to see the total math as a sanity check as soon as they type their hourly rate.

**Severity:** ANNOYING — the most useful calculation the app could show is held behind two prerequisite flows.

---

## What Worked Well

- **Page structure**: Global targets → per-segment table → race totals is the right order. Matches how Alex thinks: set the rate, see the breakdown, verify the total.
- **FuelSummary totals card**: Clean, large numbers, correct unit formatting (L vs ml, g vs mg). Alex would glance at this first.
- **Inline override without leaving the page**: The expand-in-row pattern is good. No modal, no new page. Keeps Alex in context.
- **ml→L and mg→g automatic formatting**: The app converts 1000ml to 1.0L in display. Small touch that shows the app respects real-world units.
- **"Per-segment fuel totals will appear here once you add aid stations" + CTA**: The empty state is honest and actionable.

---

## Missing or Confusing

- **No guidance on what target values are realistic**: A runner new to structured fueling has no idea if 200 cal/h or 350 cal/h is appropriate. A short tooltip or a range indicator ("typical: 200–350 cal/h") would de-risk the entry.
- **No unit toggle (oz vs ml)**: American ultra runners think in oz. 500 ml/h = 16.9 oz/h — many won't do that math.
- **No cumulative sodium column in the table**: The ∑ columns stop at Cal and Fluid. Sodium matters just as much for long ultras.
- **Notes field is invisible**: The most discoverable feature should be the notes field — runners have a lot of station-specific information. Right now it looks like a blank gap under each row.
- **"Apply targets" button text**: "Apply" implies spreading to segments. "Save" implies storing. The actual behavior is save + recompute. The label creates ambiguity.
- **No save confirmation**: When the save works (in theory), there's no toast or visual confirmation. Alex would be left wondering if anything changed.

---

## Overall Impression

> The structure is right — hourly targets flowing into per-segment breakdowns is exactly how I think about fueling a 100-miler. But right now, clicking "Apply targets" kicks me out to the login page. That's the whole tab, broken. If the save bug were fixed and the totals card showed me the race total even before segments existed, I'd actually use this tab every training cycle to stress-test my nutrition plan. Right now I can't trust that anything I type will stick.

**NPS Score: 4/10** — The concept is right, the execution has a blocking bug and the table needs a few meaningful columns. Fix the save and show me the total math upfront, and this becomes the most useful tab in the app.

---

## Top 3 Recommendations (for the engineering team)

1. **Fix the session drop on "Apply targets" — BLOCKING** (`GlobalTargetsForm` / `saveGlobalTargets` action). This is the single most damaging bug: it logs the user out mid-flow with no confirmation that their data was saved. Until this is fixed, the entire Fueling tab is broken in Playwright testing and likely in production for any session edge case. Investigate why the Server Action invalidates the Next-Auth session and add a visible save confirmation (toast/inline) so users know the action succeeded.

2. **Add cumulative sodium column to FuelingTable and show race total preview in GlobalTargetsForm** (`fueling-table.tsx` + `global-targets-form.tsx`). Add `∑Sodium` next to `∑Cal` and `∑Fluid` in the table. More importantly: in the GlobalTargetsForm, once the race has an estimated finish time (from pacing), show "At X cal/h × ~Yh = Z kcal total" inline below the inputs. This is the calculation Alex wants immediately — don't hide it behind the full setup flow.

3. **Make the station notes field visible and add a save indicator** (`fueling-table.tsx`). Give the notes input a visible bottom border by default (not just on focus). Add a subtle "Saved" flash after `handleNoteBlur` completes. This is a high-value feature — runners have a lot of station-specific information (what to pick up, what crew will hand them) — but its current invisible styling means virtually no one will discover it.

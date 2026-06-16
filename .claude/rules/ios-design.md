---
description: HIG principles, Liquid Glass (iOS 26), functional motion, thumb-zone ergonomics, accessibility, anti-slop rules — read by DESIGNER and UI_REVIEWER for any packet that creates or changes UI.
globs:
  - "apps/*/design/**"
  - "apps/**/Views/**/*.swift"
  - "apps/**/*View.swift"
  - "apps/**/*Screen.swift"
alwaysApply: false
---

# iOS Design — Delight, HIG, and Anti-Slop

> The **Designer** and **UI-Reviewer** read this. Goal: apps that feel native, premium, and intentional — like Apple Design Award winners, not AI-generated templates. The mockup is approved against these principles at the Design Gate.

## The three HIG foundations

- **Clarity** — every element communicates its purpose immediately. High-contrast, legible type; precise spacing; clear cues. Reduce cognitive load.
- **Deference** — the UI is subordinate to the user's content. Minimize decorative chrome, heavy borders, gratuitous gradients. Let content take center stage.
- **Depth** — layers, translucent materials, and motion establish spatial hierarchy. Digital actions feel tangible.

Apple ≠ Material. iOS is flat surfaces, content-driven layout, structured translucency — not drop-shadow elevation stacks.

## The 2026 frontier (apply where it fits the brief)

- **Liquid Glass (iOS 26):** UI surfaces behave as dynamic materials that refract/reflect content beneath them — not static blurred rectangles. **Contrast is now dynamic:** a control that passes contrast over a light background can vanish over a dark photo. Build adaptive *semantic* colors and test legibility across light/dark AND varied background content. Static contrast checks are insufficient.
- **Functional motion:** animation is interaction language, not decoration. Physics-based spring/compression confirms input (tactile press → spring-back) without text alerts. Align with native SwiftUI/UIKit physics to avoid micro-stutter. **Every animation must be motivated:** hierarchy, feedback, continuity, or state change. Never motion for show.
- **Ambient / system presence:** the best apps extend beyond their own window.

## Ergonomics & touch (non-negotiable)

- ~75% of interactions are single-thumb → primary actions live in the **bottom third**. Use bottom sheets (`UISheetPresentationController` / `.presentationDetents`) for menus, filters, sharing.
- **44×44 pt minimum** touch target; ~12 pt padding around bezeled controls. Correct sizing cuts tap errors ~30%.
- Don't just scale a desktop/web layout down (the Balatro lesson) — re-optimize hit targets and spacing for the hand.

## Accessibility from the start (not an afterthought)

- **Dynamic Type** — text scales across all accessibility sizes without breaking layout.
- **Contrast** — body text ≥ 4.5:1, large text ≥ 3:1.
- **VoiceOver** — descriptive `accessibilityLabel` on every interactive element; reading order matches visual order.
- **Color independence** — color is never the sole status indicator (pair with icon/text/shape).
- **Reduced Motion** — swap deep z-axis/spring transitions for cross-fades when the user enables it.
- **Haptics** — pair with sound or visual change to make interactions tactile.

## Navigation patterns

- **Tab bars** — top-level nav on iPhone. Short labels, sparing badges.
- **Sidebars** — iPad/Mac.
- **Sheets/modals** — self-contained secondary flows; support swipe-to-dismiss and detents (`.medium`/`.large`).

## What Apple Design Award winners actually do (steal these moves)

- **Tide Guide** — chrono-shifted palette tracking daylight; progressive disclosure (clean default, deep data on tap); deep system integration (widgets, Live Activities, App Intents, watchOS) so the app becomes an ambient service.
- **Crouton** — interaction designed for real-world constraints (hands-free pagination via TrueDepth in the kitchen); ML to remove tedium (VisionKit OCR of cookbooks).
- **Gentler Streak** — humane framing (rest as progress), an abstract mascot to convey state over raw metrics, self-relative summaries instead of leaderboards.
- **CapWords / Blackbox / Sago Mini** — transmute the physical world into the interface; calibrated friction tuned to the user (e.g. "delayed run" for preschoolers); wordless visual communication.

**The throughline:** a strong, specific *concept* drives the design. Deep platform integration. Progressive density. Empathy for the actual context of use. That concept is what separates a winner from a template — find it for each app.

## Design tokens the Designer must define (in the app's `docs/ui-system.md`)

- **ONE controlled accent** doing real work; semantic colors (success/warning/destructive) reserved for feedback only. Defined in **light AND dark** (off-black/off-white, never pure #000/#fff). Adaptive for Liquid Glass surfaces.
- **Type roles** — real hierarchy via weight/size/color; native system font (San Francisco / Dynamic Type) by default; a brand font only with justification. Tabular figures for metrics/counts.
- **Spacing scale** + **corner-radius scale**, consistent across screens.
- **Motion intensity** — what springs, what fades, what gets haptics; reduced-motion fallback.

## Anti-AI-slop checklist (avoid unless the brief explicitly asks)

- No purple/blue startup gradients; no beige+brass "luxury" trope by default.
- No three identical equal-width feature cards; no box-in-box-in-box nesting.
- No neon outer glows, oversaturated accents, gradient text by default.
- No placeholder names ("John Doe"), brand-slop ("Acme/Nexus"), or fake-perfect numbers (99.99%).
- No filler verbs ("Elevate", "Seamless", "Unleash", "Next-gen").
- Empty / loading / error states are *designed*, not afterthoughts.

## Native-app rule

The HTML mockup rendered at the Design Gate is a **visual spec only** — it exists to approve direction, palette, hierarchy, and layout. The Implementer writes native SwiftUI to match it, and the built UI is verified against the approved PNG with a real simulator screenshot before the packet passes.

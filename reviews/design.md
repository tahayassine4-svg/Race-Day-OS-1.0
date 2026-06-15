# Design Review Checklist — Premium, Native, Anti-Slop iOS UI

Used by the **Designer** (creating mockups) and the **UI-Reviewer** (validating the built UI). Goal: interfaces that feel native and intentional — like an Apple Design Award winner, not an AI template. Backed by `knowledge/ios-design.md`. Every item is contextual — apply what fits the brief.

## The one-line Design Read
- [ ] Stated before any pixels: "Reading this as: <app kind> for <audience>, with a <vibe> language, leaning <direction>." The audience picks the aesthetic, not the agent's taste.

## The concept (anti-generic)
- [ ] There is ONE specific concept driving the design (the ADA-winner throughline), not "clean and modern." Progressive disclosure, an ambient/contextual idea, or a humane framing — something a competitor couldn't copy with a recolor.

## HIG foundations
- [ ] **Clarity** — every element's purpose is immediate; high contrast, legible type, precise spacing.
- [ ] **Deference** — UI is subordinate to content; minimal chrome, no gratuitous borders/gradients.
- [ ] **Depth** — layers/translucency/motion create spatial hierarchy (iOS flat surfaces + structured translucency, not Material drop-shadow stacks).

## Color
- [ ] ONE controlled accent doing real work; semantic colors (success/warning/destructive) reserved for feedback only, consistent across the whole product.
- [ ] Light AND dark defined; dark mirrors the hierarchy. No pure #000/#fff — off-black/off-white.
- [ ] **Liquid Glass contrast** — on translucent surfaces, color/text stays legible over varied (light AND dark) background content; adaptive, not a single static value.
- [ ] No AI-default palettes: no purple/blue startup gradient, no beige+brass "luxury" trope unless the brand calls for it.

## Typography
- [ ] Real hierarchy via weight + size + color — not one weight everywhere.
- [ ] San Francisco / Dynamic Type by default; a brand font only when justified. Serif only if genuinely editorial.
- [ ] Metrics/counts/progress use tabular figures.

## Layout, structure & ergonomics
- [ ] One strong structural move per screen; no box-in-box-in-box nesting.
- [ ] Primary actions in the thumb zone, touch targets sized per `knowledge/ios-design.md` § Ergonomics & touch.
- [ ] Native navigation patterns: tab bar (iPhone top-level), sheets with detents for secondary flows, sidebar (iPad/Mac).
- [ ] No three identical equal-width cards by default; cards only where elevation means real hierarchy — otherwise group with spacing + hairlines.
- [ ] Consistent corner-radius + spacing scales; the UI breathes.
- [ ] Don't just shrink a desktop/web layout — re-tune for the hand.

## Data & progress visuals
- [ ] "How much is done" shown visually (rings/bars/gauges) where the product tracks progress — not just raw numbers.
- [ ] Charts/visuals are real and meaningful, not decorative filler or fake dashboards.
- [ ] Empty, loading, and error states are designed.

## Motion
- [ ] Every animation is motivated: hierarchy, feedback, continuity, or state change. No motion for show.
- [ ] Physics-based spring/press feedback aligned to native SwiftUI behavior; tasteful completion feedback + haptics on native.

## Accessibility
- [ ] Meets `knowledge/ios-design.md` § Accessibility from the start (Dynamic Type, contrast, VoiceOver, color independence, Reduced Motion, haptics).

## Anti-AI-tells (avoid unless the brief asks)
- [ ] No neon outer glows, oversaturated accents, or gradient text by default.
- [ ] No placeholder names ("John Doe"), brand-slop ("Acme/Nexus"), fake-perfect numbers (99.99%).
- [ ] No filler verbs ("Elevate", "Seamless", "Unleash", "Next-gen").

## Native-app rule
- [ ] The HTML mockup is a VISUAL SPEC only. The built SwiftUI is verified against the approved `design/packet-NN.png` with a real Simulator screenshot before the packet passes.

# Design Review Checklist — Premium, Anti-Slop UI

Used by the Designer (when creating mockups) and the UI-Reviewer (when validating the built UI). The goal is interfaces that look intentional and expensive, not templated. Every item is contextual — apply what fits the brief.

## The one-line Design Read
- [ ] Stated before any pixels: "Reading this as: <app kind> for <audience>, with a <vibe> language, leaning <direction>." The audience picks the aesthetic, not the agent's taste.

## Color
- [ ] ONE controlled accent doing real work. Semantic colors (warning/destructive/success) reserved for feedback only.
- [ ] Accent used consistently across the whole product — no surprise second accent in a later section.
- [ ] No generic AI-default palettes: avoid purple/blue startup gradients and warm beige+brass "luxury" tropes unless the brand explicitly calls for them.
- [ ] Light AND dark values defined; dark mode mirrors the hierarchy, not a different theme. No pure #000 / #fff — use off-black / off-white.

## Typography
- [ ] Real hierarchy through weight, size, and color — not one weight everywhere.
- [ ] Native system font or a deliberate brand font. Inter only when a neutral/standard feel is explicitly wanted. Serif only when genuinely editorial/luxury and justified.
- [ ] Numbers that matter (counts, progress, metrics) use tabular/monospaced figures.

## Layout & structure
- [ ] One strong structural move per screen, not many noisy ones. No box-in-box-in-box nesting.
- [ ] Cards used only where elevation communicates real hierarchy; otherwise group with spacing and hairlines.
- [ ] No three identical equal-width feature cards as a default. Vary composition.
- [ ] Consistent corner-radius scale across the screen.
- [ ] Generous, consistent spacing scale. The UI breathes.

## Data & progress visuals (the "how much is done" moment)
- [ ] Progress/completion shown visually (rings, bars, gauges) where the product is about tracking — not just raw numbers.
- [ ] Charts/visuals are real and meaningful, not decorative filler or fake dashboards.
- [ ] Empty, loading, and error states are designed, not afterthoughts.

## Motion (when in scope)
- [ ] Every animation is motivated: hierarchy, storytelling, feedback, or state transition. No motion for show.
- [ ] Spring/ease transitions on state changes; subtle press feedback on repeated controls; tasteful completion feedback (and haptics on native).
- [ ] Honors reduced-motion / accessibility settings.

## Anti-AI-tells (avoid unless the brief asks)
- [ ] No neon outer glows by default, no oversaturated accents, no excessive gradient text.
- [ ] No generic placeholder names ("John Doe"), no "Acme/Nexus" brand-slop, no fake-perfect numbers (50%, 99.99%).
- [ ] No filler verbs ("Elevate", "Seamless", "Unleash", "Next-gen").
- [ ] No decorative scroll cues, version stamps, or locale/weather strips as ornament.

## Native-app note
- [ ] For iOS/Android, the HTML mockup is a visual spec only. The built native UI is verified against it with a real device/simulator screenshot before the packet passes.

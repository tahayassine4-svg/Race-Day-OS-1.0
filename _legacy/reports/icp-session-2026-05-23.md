# ICP Session Report — 2026-05-23

## Persona

I am Alex, a 38-year-old serious amateur ultra runner 12 weeks out from my first Leadville 100. I have 3 crew members, I currently plan in Google Sheets, and I sent my crew a 6-page Word doc last race that they never fully read. I am here to replace all of that with one link.

---

## Flows Tested

| Flow | Status | Notes |
|---|---|---|
| First landing / login page | ✅ Completed | No value proposition — app name only |
| Registration | ✅ Completed | Green confirmation shown |
| Dashboard | ✅ Completed | Race card clean, "+ New Race" visible |
| Race overview & navigation | ✅ Completed | 7 section tabs, race metadata visible |
| Pacing | ⚠️ Partial | Empty state shown — no segments in DB |
| Fueling | ⚠️ Partial | Empty state shown — gated behind Setup |
| Crew setup | ⚠️ Partial | Add form works, share link is secondary UI |
| Crew mobile view | ❌ Blocked | **PostgresError crash on page load** |
| Checklists | ✅ Completed | Per-station cards with runner/crew sections |
| Import (GPX) | ✅ Completed | Drop zone + elevation preview visible |
| Live race day view | ⚠️ Partial | Empty state — no stations set up |

---

## Findings

### First landing

**What I did:** Typed `localhost:3000` — got redirected to the login page.

**What I found:** The page header says "Race Day OS" and the subtext says "Sign in to your account." That is all the context a new visitor gets. There is no sentence explaining what this app does. If someone forwarded me this URL cold, I would not know if I was signing into a race registration system, a training log, or a crew coordination tool.

**Severity:** ANNOYING

**Fix:** One line directly under "Race Day OS": *"Plan your race. Brief your crew. Track your finish."* That is all it takes.

---

### Dashboard

**What I did:** Logged in, landed on `/dashboard`.

**What I found:** Clean race card for "Leadville Trail 100" with date (Sat Aug 22, 2026), location (Leadville, CO), distance (160.9 km), and a "0 stations" status line. The "+ New Race" button is in the top right. The subtitle "Plan and coordinate your ultra races" is a good micro-tagline.

**Severity:** MINOR — what works

The "0 stations" line in the race card is a useful signal. As Alex, I immediately understand: I need to go set up my stations before I can do anything else. I just wish the card told me HOW to continue (a "Continue setup →" CTA would be more direct than making me click into the race to figure it out).

---

### Race overview & navigation

**What I did:** Clicked into the race card.

**What I found:** Race header shows name, date, location, distance — exactly what I need at a glance. The left sidebar has 7 tabs: Setup, Pacing, Fueling, Crew, Checklists, Live, Re-import from GPX / Excel. Every section I need is reachable in one click.

**Severity:** MINOR — works well

The navigation structure is right. The "Re-import from GPX / Excel" label in the nav is a bit verbose — I'd call it "Import" and let the page explain what it imports.

---

### Pacing — empty state

**What I did:** Clicked "Pacing."

**What I found:** The main content area says: *"No segments yet. Add aid stations in the Setup tab first."* The word "Setup tab" is a hyperlink.

**Severity:** ANNOYING

This is the right message but the wrong experience. I came here to enter my goal time — 26 hours — and see my splits. In my spreadsheet, I can enter a goal time before I know all the stations. The app blocks me entirely until Setup is done. I understand the dependency, but I should at least be able to set my goal finish time on this page as a "placeholder" so when I do add stations, the splits calculate immediately. Right now this page tells me to go somewhere else and come back.

The empty state guidance is correct — it links to Setup. But it is a text line with no button, no visual affordance. Make it a real CTA: **"Add your first aid station →"** with a button that takes me directly to Setup.

---

### Fueling — empty state

**What I did:** Clicked "Fueling."

**What I found:** Identical to the pacing empty state: *"No segments yet. Add aid stations in the Setup tab first."*

**Severity:** ANNOYING

Same problem as pacing, compounded. I cannot even set my calories-per-hour target before adding stations. My old approach was to open a notes app and write "300 cal/hr, 20 oz/hr" and then multiply manually. Race Day OS should let me enter those targets upfront and calculate later. Right now I cannot do anything on this page until Setup is complete.

The pattern of "all sections gated behind Setup" creates a linear onboarding funnel that the app does not communicate. As Alex, I clicked through five tabs expecting to plan my race, and every one redirected me back to Setup. There is no progress indicator, no checklist, no "Step 1 of 3" guidance on the race overview. I did not know where to start.

---

### Crew setup

**What I did:** Clicked "Crew." Saw "Crew Roster (0)" with an inline add form (Name \*, Phone optional). Below the form: *"No crew-accessible stations. Mark stations as crew-accessible in the Setup tab."*

**What I found — add form:** The form only asks for Name and Phone. No role field, no station assignment. After adding a crew member, I assume I assign them to stations later — but the form does not tell me that. I filled in "Sarah" and "+1 555-0100" and clicked "Add member." That is clean.

**What I found — share link:** In the left sidebar, under "CREW LINK," there is a small button: **"Generate Crew Link."** This is the most important action on this page and it is buried in the sidebar in 12px text with no explanation. I almost missed it.

**Severity (crew form):** MINOR — simple and clear

**Severity (share link placement):** ANNOYING — this should be a full-width button at the top of the crew section: *"Generate & share crew link →"* with a brief explanation: *"Your crew opens this link on their phone — no account needed."*

---

### Crew mobile view — BUG

**What I did:** Obtained the crew link URL and opened it simulated at 375px (iPhone) viewport.

**What I found:** The page shows a Next.js Runtime error: **"PostgresError — invalid input syntax for type uuid: 'crew-roster'"**

**Severity:** BLOCKING

This is a crash. A crew member opening the shared link on race day would see a server error page, not their station view. The app is navigating to `/crew/crew-roster` with the literal string "crew-roster" as the token — which is not a valid UUID and causes a Postgres query to fail hard. This needs to be fixed before any crew member uses this in the field.

**Fix:** The "Generate Crew Link" button must complete the token creation before returning a shareable URL. Validate that `crewToken` is a real UUID before constructing the crew link URL. The link should not be surfaced (and definitely not shared) until a valid token exists.

---

### Checklists

**What I did:** Clicked "Checklists."

**What I found:** Per-station cards are visible with separate runner-side and crew-side sections. The structure is exactly right.

**Severity:** MINOR — works well

The runner/crew separation is smart. I would add one thing: a small "copy from previous race" or "template" option so experienced ultra runners who use the same checklist every race can reuse it. But this is a v2 wish, not a blocking issue.

---

### Import (GPX + Excel)

**What I did:** Navigated to "Re-import from GPX / Excel."

**What I found:** Clear drop zone for GPX file, Excel/CSV option, and an elevation profile preview area. This is one of the best pages in the app — it immediately communicates what to upload and why (the elevation chart shows you what you will get).

**Severity:** MINOR — works well

The elevation preview before committing is the right design. It replaces the step where I'd download the GPX, open it in a separate tool, and confirm the elevation profile matches the race. Now I can do it here.

---

### Live race day view

**What I did:** Clicked "Live."

**What I found:** The page shows "🔴 Live Monitoring" (green radio icon), "0 of 0 stations logged," and "No aid stations set up yet." in the content area.

**Severity:** ANNOYING

The live view empty state is functional but cold. On race morning, a crew member who clicks Live and sees "No aid stations set up yet." does not understand what that means or what to do. Replace this with: *"Race plan not complete — [runner name] needs to finish setting up aid stations before the live view activates."* That is a message crew can understand and act on.

Also: when the race IS set up, the projected finish time should be the biggest element on this page — a clock showing the current projection, updating live. Right now there is no hierarchy that communicates this. On race day, every crew member is watching that one number.

---

## What Worked Well

- **Dashboard empty state:** "Create your first race to start building your crew plan, pacing strategy, and race-day OS." — exactly right. Clear CTA, explains the payoff.
- **Race card metadata:** Date, location, distance, "0 stations" status — I immediately know the state of my plan at a glance.
- **7-tab navigation:** All planning sections are one click away from any race page. No hunting.
- **Import page:** Drop zone + elevation preview is a genuinely better experience than downloading and cross-checking separately.
- **Checklist structure:** Runner-side / crew-side per station is the right data model.
- **Green confirmation on registration:** Small but clear — "Account created, sign in below." No ambiguity.

---

## Missing or Confusing

1. **No app value proposition on the login page.** First-time visitors see a sign-in form with no context.
2. **No onboarding progress indicator.** After creating a race, I do not know that I must complete Setup before any other tab is useful. A "Step 1: Course → Step 2: Pacing → Step 3: Crew" checklist on the race overview would orient me immediately.
3. **Goal time entry is blocked.** I cannot set my 26-hour goal on the Pacing tab without first adding segments. This is the first thing any runner wants to do.
4. **Calorie/fluid targets are blocked.** I cannot set my hourly targets on Fueling without segments. Same problem.
5. **Crew link is not prominent.** "Generate Crew Link" is a sidebar button. It should be the headline action of the Crew page.
6. **Crew mobile crashes with a PostgresError.** This is a real bug in production.
7. **Live view empty state is technical.** "No aid stations set up yet" is developer language, not crew language.

---

## Overall Impression

> "The bones are all here. I can see exactly what this will be when it is full — a single place that replaces my spreadsheet, my Word doc, and my WhatsApp thread. But right now I could not actually experience it because everything depends on doing Setup first, and I did not know that. And when I tried to preview what my crew would see on race day, the app crashed. I would not send this link to my crew yet."

**NPS Score: 6/10** — The structure and vision are right. The execution has two real problems: an opaque onboarding sequence that does not guide new users through the required order of steps, and a crash on the most critical crew-facing feature. Fix those and this becomes an 8 or 9 immediately.

---

## Top 3 Recommendations (for the engineering team)

**1. Fix the crew link crash before anything else.**
The PostgresError on `/crew/crew-roster` is a hard crash visible to end users. A crew member opening this on race morning would see a server error, not their station view. Root cause: the crew token is not being generated before the link is constructed or shared. Validate that `crewToken` is a real UUID before exposing a shareable URL. This is the highest-priority fix in the app.

**2. Add a "Getting started" progress checklist to the race overview page.**
Every section (Pacing, Fueling, Crew stations, Live) gates its content behind having aid stations in Setup. This is a correct dependency, but the app does not communicate it. A runner who creates a race and immediately clicks Pacing sees an empty page with no explanation of why. Add a progress card to the race overview: `[ ] Add aid stations (Setup) → [ ] Set your goal pace → [ ] Add crew and generate link → [ ] You're race-day ready`. This single change eliminates the most common dead-end in the new user flow.

**3. Let runners set their goal time and hourly targets without segments.**
The Pacing page's goal finish time field and the Fueling page's calories/hour, fluid/hour, sodium/hour fields should be enterable before any segments exist. These are race-level settings, not segment-level. A runner who lands on Pacing should be able to type "26:00" immediately — the splits will auto-calculate as soon as they add stations. Locking these fields behind Setup completion removes the one action every runner wants to do first.

---

*Session conducted: 2026-05-23 | Flows: 10 | Findings: 2 blocking, 6 annoying, 9 minor | Screenshots: /tmp/icp-session/*

# ParentVeda - Product & Feature Reference
_A complete picture of what exists today: the pregnancy app, father mode, the parenting app, Ask Veda, and the platform underneath._

## How to read this document

This is a **product reference**, not a code walkthrough. It describes what ParentVeda *is*, what a parent actually sees and does, the psychology and design rules that govern every screen, and the architecture those screens sit on.

It was assembled by reading the live codebase (the Flutter app and the Ask Veda backend service) rather than from planning documents, so it reflects what is genuinely built as of this writing - including what is real, what is seeded placeholder data, and what is deliberately parked.

The final section, **"Rules any new module must follow"**, distils the conventions a new part of the product would need to inherit to feel native rather than bolted on.

---

## 1. What ParentVeda is

ParentVeda is a **calm, bilingual (English + Hinglish) companion for Indian parents**, built in Flutter, currently spanning two life stages:

1. **The pregnancy app** - a week-by-week journey from week 4 to birth, for the mother, with a paired **father mode**.
2. **The parenting app** - a separate, structurally isolated experience for life after birth, organised around the child rather than the calendar.

Around those sit shared systems: an **Ask Veda** answer engine, a **content backend** (Supabase + Directus CMS), **commerce and booking**, a **doctor-side** experience, a **brand partnership layer**, and a **personalization engine** that quietly tunes what each family sees.

The product's centre of gravity is not features - it is **emotional posture**. The theme file states the brief plainly: *"premium, soothing, trustworthy... airy, soft, calm, never loud. Think calm nursery, not toy store."* Nearly every design decision in this document follows from that sentence.

### 1.1 Who it is for

- **The expecting mother** - the primary user. Everything in the pregnancy app is driven by her due date.
- **The father** - a genuinely separate experience, reached by pairing with her account using a code. Not a read-only mirror; he has his own content, his own journal, and his own visual identity.
- **The parent after birth** - the parenting app, keyed to the child (and both parents share it).
- **Doctors and experts** - the same app boots into a doctor dashboard for verified experts.

### 1.2 What makes it distinctive

- **India-first, not localised-after.** Nutrition is bajra, amla, khichdi and nimbu paani. "Can I...?" answers carry an Indian-context card. Garbh Sanskar is a first-class pillar, not a novelty. Hinglish is real conversational Hinglish in Latin script, addressing the mother as *Maa*.
- **Original content throughout.** Stories, fables, lullabies, affirmations and mythology retellings are all originally written and IP-safe, stated explicitly in the data files.
- **Calm over gamification.** No streaks-as-pressure, no scores, no red alarm states, no shaming. The one deliberate exception is consultation reminders, for reasons explained in section 9.
- **Emotional framing over utility.** The Due Date Calculator is described in its own source as *"not a utility - the first chapter of the journey."* The weight tracker exists to reframe weight as *"my body is supporting my baby"* and forbids above/below-target colouring.

---

## 2. Product psychology and design principles

These are the rules that hold the product together. Several are enforced structurally (by tests or by API shape), not merely by convention.

### 2.1 A feature is never hidden

The single most important rule in the product, stated in the personalization doc: **personalization changes content, never availability.**

> A mother who has never logged a medication must still learn that the medication tracker exists. The empty state **is** the feature's advertisement.

So every section always renders. Only its *empty copy* varies - inviting the action, reflecting a good state, or gracefully acknowledging a gap. The Home screen's medication card is the reference implementation: with nothing logged, it still appears, explains itself, and offers a CTA.

This is enforced by API shape, not discipline: the ordering function returns **every** item it was given, and the recommendation function returns **weights** rather than a filter - so no screen *can* use the personalization engine to hide something.

### 2.2 Personalization has exactly three layers - and navigation is not one

1. **Content** - the same screen, different material inside it.
2. **Recommendation** - nothing moves or disappears; the ranking gets smarter.
3. **Contextual prioritisation** - reordering only.

> There is no Layer 4. Navigation is not a layer.

The reasoning is that **everyone must learn one ParentVeda**. If structure varied per family, support becomes impossible, documentation is wrong for half the users, and a mother who learned the app in her first pregnancy is lost in her second.

### 2.3 Derive, never ask

A signal is either derived from data the app already holds or declared by the mother - **never both**. Week, trimester, language, logged symptoms, active medications, completed scans, and even *twins* are derived. Only genuinely unknowable things are asked (conditions, priorities, diet, parity, learning style).

> Asking for something we already hold is how a personalization engine turns back into the onboarding questionnaire we were told not to build.

Questions are asked **progressively and in context** - inline, never modal, once ever, always stating what they unlock, and visibly skippable. They appear exactly where the answer pays off: the gestational-diabetes question sits on the Weight Tracker, because that is where it changes the reading.

### 2.4 One brain, two doors

A recurring architectural principle, applied three separate times:

- **Personalization** - one family profile serves both pregnancy and parenting, so a mother who says she is vegetarian while pregnant is never asked again after birth.
- **Ask Veda** - one backend service serves the app and (next) WhatsApp; neither client contains any AI.
- **Booking** - one engine serves both stages, so a birthing class booked while pregnant and a postnatal yoga pack a year later appear in **one history**.

The reasoning each time is identical: *two of a thing is what makes an app feel like two apps.*

### 2.5 Never invent data about a family

There is a dedicated test - among the most product-significant in the suite - asserting that a fresh child has **no** measurements, no pre-filled health or growth or vaccine data, no seeded name likes, and that no screen can render a `{child}` placeholder without resolving it. Seed and demo rows are marked by an empty id and are **never uploaded**, so a fictional sample child can never leak into a real account.

### 2.6 Fail soft, always

- A cloud failure never crashes a screen; the app degrades to local data.
- An unreachable payment function falls back to the free preview rather than trapping the user.
- Unknown personalization signals match nothing - silence costs a parent nothing.
- An uninitialised backend behaves exactly like being logged out.

### 2.7 The database enforces; the client does not promise

Privacy rules live in Postgres row-level security, not in app code, because *anyone can write their own client*. Where an answer must combine data that individuals are not allowed to see raw, the rows stay private and a database function returns only the computed answer (see the baby-naming example in section 8.4).

### 2.8 Comment out, never delete

Superseded UI is commented in place with a "kept for revert" note rather than removed. This is why the codebase contains dormant-but-intact versions of the classic weekly carousel, the offline Ask Veda engine, older hospital-bag screens, and retired pillars. Anyone reading the code alongside this document will meet these constantly.

### 2.9 Other standing rules

- **No decorative emoji** in UI chrome - clean line icons instead. (Content may carry meaningful glyphs.)
- **Medical safety is explicit**: every clinical surface ends with a disclaimer card; every week carries a red-flags line; emergency phrasing routes calmly to a doctor rather than alarming.
- **The app generates row ids**, so local and cloud rows share one identity and syncing is a trivial idempotent merge.

---

## 3. Design language

### 3.1 The mother's palette - "Warm Nest"

| Role | Hex | Use |
|---|---|---|
| Primary - purple | `#6A30B6` | One clear action per screen; hero gradients |
| Secondary - coral/pink | `#FF5A79` | Warmth, highlights, mother accents |
| Tertiary - earthy brown | `#7A4600` | Grounded accents, Garbh Sanskar |
| Neutral - warm grey | `#7B757F` | Text and structure |
| Danger | `#D92D20` | Destructive actions only |

Surfaces: a soft lavender-white canvas `#FBF9FE` (**never pure grey**), white cards, and tinted lavender containers. Shadows are lavender-tinted and barely there.

**Shape and elevation:** cards 20-24 radius, buttons and inputs 16, chips and pills fully round. Near-flat - surface tints are preferred over drop shadows. Generous padding, comfortable line height.

### 3.2 Typography - three fonts, three jobs

- **Fraunces** (soft display serif) - hero moments only: the splash, big section titles, quoted read-aloud text. *Never in UI widgets.*
- **Plus Jakarta Sans** - section titles, card titles, in-app headers.
- **Manrope** - all body copy, captions, chips, buttons.

### 3.3 The father's palette - "Slate"

A deliberate counterpart rather than a recolour: warm cream background `#F4EFE8`, deep blue-charcoal ink `#22333B`, and **deep slate `#2E5266` replacing purple and coral entirely**, with an amber/terracotta `#E0915B` for "do this today" moments. Headers move to Fraunces serif.

The structure, components and images stay byte-identical to the mother's - **only colour and header fonts change** - so the two experiences are recognisably one product.

### 3.4 The parenting palette

The parenting app re-declares its own flat constant set (background `#FBF9FE`, ink `#2F2C30`, purple `#6A30B6`, coral `#FF5A79`, title ink `#2D144C`). It deliberately does **not** import the pregnancy theme - the two apps never import each other's screens, so they can evolve independently.

### 3.5 Recurring UI patterns

- A **floating pill tab bar**, detached from the screen edge, where the active tab expands into a filled pill with icon *and* label - so the parent always knows what each tab is.
- **Hero cards** with soft gradients and translucent decorative circles.
- **Section briefs that open full-screen pop-ups** rather than expanding inline.
- **Progressive disclosure** - the answer in ten seconds above the fold, depth below.
- **Horizontal progress bars, not percentage rings** - a deliberate app-wide replacement.
- **Segmented toggles** for two-way views, **filter chips** for lists.
- **A "why this matters" or "why now" line** attached to almost every recommendation.

---

## 4. The pregnancy app

### 4.1 Entry: splash, auth, onboarding

**Splash** - a 2.2-second branded beat: the mark fades and scales over a lavender-to-blush gradient with soft glowing blobs, under the tagline *"Your trusted parenting companion."* It then routes based on stored auth state and role.

**Auth** is a self-contained flow of about eleven screens in a distinct "soft solid" treatment (radial purple-to-white wash, glass cards, floating dots):

`welcome -> login | signup -> role -> (mother: profile -> success) | (father: pair code -> pairing -> paired)`, plus a `forgot -> otp -> reset` recovery branch.

- **Welcome** carries a social-proof chip, a headline - *"Care that grows with your family."* - and three feature pills: **Track / Learn / Community**.
- **Role** offers three cards: *I'm the mother*, *I'm the father - I have a partner code* (teal), and a test-only *I'm a doctor*.
- **Profile (mother)** contains a three-way **"I AM CURRENTLY: Trying / Pregnant / New parent"** selector, a due-date field with a "calculate my due date" link, and a WhatsApp opt-in. **The due date is mandatory** - the finish button is gated with *"Add the date above to continue - everything else is built around it."*
- **Success** offers an optional "Have an invite code?" referral door.

Email and password authentication is real (Supabase). Social logins and the password-recovery branch are **UI-only stubs** today.

### 4.2 The shell

Five destinations in an `IndexedStack` behind the floating pill tab bar:

| # | Tab | What it is |
|---|---|---|
| 1 | **Today** | The daily moment - the emotional home |
| 2 | **Prepare** | Guided learning and paid services |
| 3 | **Tools** | The toolbox, and the Journey Map |
| 4 | **Calendar** | The command centre for what happened and what's next |
| 5 | **Community** | The social layer |

**Profile is not a tab** - it is reached only from the avatar on the Today screen, alongside a Saved bookmark and a global search.

Also always present: a **global "Ask Veda" button** floating over every route in both apps (hiding itself over sheets, dialogs and takeovers), and a once-per-campaign brand **Premiere** check that resolves to nothing on almost every launch.

### 4.3 Today - the Daily Moment

A single vertical scroll, in this order:

1. **Brand header** with bookmark, search and avatar.
2. **A doorway into the parenting app** (a temporary preview banner).
3. **The gradient hero card** - the emotional centre. Time-aware greeting, **"Week N - Day D"** in large serif, a two-line brief for the week, a **horizontal trimester progress bar**, and three in-hero shortcuts: **Baby / Mother / What's next**, each deep-linking into that week's detail. Tapping anywhere opens the week.
4. **Today's Parenting Tip** - featured editorial with a quoted title, a bold insight line, a preview and a "Read more" into a full reader.
5. **Launch Spotlight** and an **invite nudge** - both render nothing unless live.
6. **"Today's journey"** - the daily ritual set:
   - **Today's Video** with a *"Why now"* reason line.
   - **Today's Garbh Sanskar** - an N/5 counter, a day streak, a short explainer, then three ritual rows (Shravan / Samvad and Vichara / Kriya) each showing *today's specific item* with a completion tick.
   - **My Journal** - four large circular quick-entries: write a memory, note for baby, add a photo, record voice.
   - **Medication and supplements** - today's doses as tap-to-tick rows plus her reminders; renders even when empty, with an explanation and a CTA.
   - **Today's Reads** - day-rotating Articles / Research simplified / Books, each check-offable.
   - **Products carousel** - day-rotating picks with affiliate badges where relevant.

### 4.4 The weekly journey (weeks 4-40)

Reached from the Home hero, the Journey Map, Calendar and search. A collapsing header shows trimester, week and date range over a compact week bar; future weeks are **locked** until reached.

**The content schema.** A bilingual JSON file holds 37 week objects, each containing: a baby snapshot (milestone, headline, size as fruit/length/weight, and a *reveal* line written in the baby's voice); baby development (*"what I'm doing"*, also in the baby's voice); the mother's journey (physical changes, emotional state, symptoms, self-care, reassurance); nutrition (theme, focus nutrients, why now, foods, an **Indian superfood of the week**, a meal idea); an action plan (do this week, skip this week, **red flags**, a **myth-buster**); Garbh Sanskar (raga, affirmation, reflection prompt, spoken line); reflect-and-remember prompts; and a **partner corner** (what she may feel, what you can do, one mission, a share message).

**What a week looks like**, as a vertical flow:

1. **Size hero** - a progress ring around a circular figure showing either the **real per-week baby photograph** or a fruit comparison, with a Baby/Fruit toggle, a floating milestone pill, and three stat cards (size, length, weight).
2. **Weekly video card.**
3. **About your baby** - a brief that opens a long-form article woven with media, then "Baby Science" facts as tappable rows opening large focused dialogs.
4. **For you, mum** - a two-way toggle between *You this week* (a four-part read, then self-care and reassurance cards) and *Health this week* (symptoms and diet).
5. **What's next** - three tabs: Baby, Mom, and Scans (upcoming scans and appointments).
6. **A deliberately minimal inline bridge** back to the daily home - one line and an arrow, explicitly not a card, "so it reminds without nagging."
7. **This week's videos** - a 9:16 reel-style feed.
8. **This week's reads** - a server-driven article carousel that hides itself when a week has none.
9. **Trimester tips**, then a **share-with-partner** card that composes a WhatsApp-ready summary.
10. **Week 40 only:** a celebration finale and keepsake booklet.

The baby's lines can be **narrated aloud** by a baby-voice service, muteable from the app bar.

### 4.5 Garbh Sanskar

Framed in its own source as *"not a content library - a 5 to 15 minute daily ritual."* It deliberately splits into two surfaces: a **daily** face on Home (one item per pillar, with completion and streak) and a **library** face in Tools (the full repository, with no "today" framing and no completion).

| Pillar | Meaning | What it contains |
|---|---|---|
| **Shravan** | Sacred listening | Raga sessions with morning/evening badges, a player, and a month 1-9 library |
| **Vichara** | Positive contemplation | Sacred insights (sloka, meaning, lesson), gentle brain-fitness games, uplifting reads |
| **Samvad** | Womb connection | Four tabs - Affirmations, Stories, Mantras and lullabies, Spiritual reading |
| **Kriya** | Breath and grounding | Guided breathing and meditation, plus the brain-fitness games |
| **Ahara** | Nourishment | Built, but commented out of both surfaces (kept for revert) |

The **Samvad** content is authored with explicit intent per trimester: welcoming affirmations in the first, expressive read-aloud scripts with deliberately dramatic punctuation for the "peak auditory window" in the second, and birth visualisations in the third. Every piece is rendered in large, high-line-height type **sized to be read aloud**.

The **brain-fitness games** (word search, sudoku, logic, memory match) are explicitly non-competitive: *no countdown timers, no scores, no harsh fail states*, and grids are generated so they are always solvable.

### 4.6 Calendar

*"The pregnancy command centre - where am I, what's happened, what's next."* It merges scans, appointments, journal entries, health logs, bookings, tool events and her own personal events into three tabs: **Journey Timeline**, **Calendar** (a month grid with coloured day markers, a collapsible colour-code legend, and a selected-day panel), and **Upcoming**. Adding a personal event supports **voice dictation**.

### 4.7 Community

A personalised social layer over seeded data, in its own blush palette. Deliberately **no gender communities**. One scroll contains: a utility icon row (doctor mode, bookmarks, activity, search), a serif header - *"Walking together"* - then **Your communities**, **Recommended for you** (both always rendered), a **For you / Following** feed toggle, filter chips including **Experts only**, and the feed itself: expandable posts, photo grids, polls, likes, comments, bookmarks, and a doctor **endorse** action. Posting is real and cloud-synced; expert badges and counts are seeded.

### 4.8 Prepare

The commerce and guided-learning tab, in a lighter editorial visual system. A hero, an optional *presented by* strip, a recommended rail, and four category tiles:

1. **Courses and Cohorts** - a unified catalogue of self-paced courses, live cohorts and masterclasses, with search, kind filters and topic chips.
2. **Birthing Classes** - a six-class course where class one is a free preview.
3. **Yoga** - trimester-safe classes, live or recorded, sharing the parenting app's yoga engine.
4. **Nutrition** - an assessment leading to recommended plans and a nutritionist consult.

**1:1 Consultations** live inside these funnels: five specialists, each with a profile and slot booking, framed as *"pick an expert, pick a slot, private video call; notes saved to your health record."*

### 4.9 Profile

Reached from the Home avatar. A stack of vault cards: invite your partner (the pairing code, with share and copy), My Journal, My Bump Journey, the Dear Baby vault, Saved, **Personalise ParentVeda** (with a live completeness percentage), a language toggle, an invite-a-friend banner, Memories, and the WhatsApp opt-in - plus testing affordances (reset to week 20, enter doctor mode) and sign out.

The **Personalise** screen is explicitly *not* an onboarding form: nothing is required, nothing blocks, and every question states what it unlocks, under the reassurance *"it never hides anything or moves things around."*

---

## 5. Father mode

### 5.1 How he gets there

The mother's Profile shows a persistent **pairing code** with share and copy actions. The father signs up, chooses *"I'm the father - I have a partner code"*, enters it, and a server function links the two accounts. His role persists, and he lands in the same shell with a different branch.

A dev-only **Mom | Dad** pill on the Today tab flips the whole shell for design review; it is explicitly marked for removal before launch.

### 5.2 What changes

The **structure is identical** - five destinations behind the same floating pill - but the content and colour change entirely:

| Slot | Mother | Father |
|---|---|---|
| 1 | Today | Today (his own daily) |
| 2 | Prepare | **Journey** - the same weekly stack, Slate-skinned |
| 3 | Tools | Reads |
| 4 | Calendar | Read (his read-aloud) |
| 5 | Community | Journal |

He does not get Tools, Calendar, Community or Prepare.

### 5.3 His voice

Where the mother's copy is soft, first-person and celebratory, his is plain-spoken, second-person and instructional without nagging - short declaratives, no exclamation marks:

> *"Tonight, don't fix it. Just sit with her."*
> *"Presence beats solutions."*
> *"Your voice is one they already know."*

### 5.4 His screens

- **Today** - a Slate gradient hero (week, headline, trimester bar, and Baby / Mother / What's next shortcuts), then: a **daily tip for Dad**; **Support your partner** (what she's carrying this week, with a warm amber "DO THIS TODAY" action and a ten-item detail list); **today's read** in a looping swipe carousel; **read to your baby** (today's Samvad piece as a quote block); **scans and appointments** ("coming up for her", with an "already done" toggle that marks it for *both* of them); and **his journal** with four quick-add circles.
- **Reads** - articles, research summaries and book summaries in a genuinely premium reader with a reading-progress bar, a table of contents, font sizing and cream/sepia/dark modes, plus *why this matters*, *research simplified* and a **myth vs fact** card.
- **Read aloud** - the same four Samvad tabs as the mother. He gets a **distinct affirmations slice**; stories, mantras and spiritual readings are mirrored. Crucially **he cannot customise**: the spiritual tab shows exactly what she chose, and says so - *"she picks the spiritual reading in her app, and it shows up here for you."*
- **Journal** - deliberately the small cousin of hers: no filters, no milestones, no health logs. Entries group by pregnancy week, support photo carousels and voice notes, and live in a **completely separate store** so his entries never mix with hers. She can view a **combined (you + Dad) booklet** from her side.
- **Stories, Fables and Mythology** - sixty original pieces across three tabs, each with a *dad note* framing line. Retired from his home but still reachable from Reads.

**Known limits today:** his name and week are hard-coded to a demo value in places, his tab labels are not localised, the weekly re-skin is currently gated to week 20, and the "switch to Mom's view" action is a stub.

---

## 6. The Tools hub

The mother's third tab: a purple **Journey Map** hero, a contextual profiling strip, then a two-column grid of roughly twenty-two tiles. The grid is **reordered by her stated priorities** using a stable sort that returns every tile - *"she still learns one Tools tab with the same twenty-two things in it."*

### 6.1 Journey Map

A winding illustrated trail from week 4 to birth on a lilac-to-sage gradient, with week checkpoints and typed milestone nodes (achievement, medical, baby, mother, journey, feature), a **pulsing "you are here" marker**, and an auto-scroll that lands on her current week. Reaching a major milestone triggers a full-screen celebration. Two contextual banners exist: an **overdue** note past the due date (*"baby comes when ready"*) and a **late-joiner catch-up** banner letting her date milestones already behind her.

### 6.2 The trackers

- **Baby Movement** - explicitly *"awareness, not counting."* A tap-to-log heart circle, a confined summary, at most twelve recent times behind an expander, and an optional note that saves into the **Dear Baby** vault. Sessions end automatically when she leaves.
- **Weight Tracker** - reframes weight as *"my body is supporting my baby."* The spec forbids above/below-target colouring or judgement. A one-time setup produces a personalised range; the dashboard shows current weight, total gain as a single calm line, a *"your body supporting"* breakdown, an educational *"where weight comes from"* contributor list (explicitly estimates, not measurements), and full history with the pre-pregnancy baseline. The plotted chart exists but is **switched off**.
- **Kegel Care** - *self-care and birth preparation, not a workout.* No levels, XP, streaks or achievements. Three always-visible explainer cards, a pregnancy-aware adaptive routine that changes by week, a customise sheet, and a guided session with an animated breathing ring, **spoken cues**, haptics and an emoji feel-check at the end.
- **Contraction Tracker** - calm, non-alarmist decision support. A three-phase state machine (home / active / rest) with large stopwatch circles, a live session list, and an **assessment banner** ranging from *no pattern* through *early labour* to *emergency*, with a symptoms sheet acting as a safety override. It speaks its interpretation aloud, and produces a **doctor-ready summary**.

### 6.3 The planners

- **Ready for Birth** (the live hospital bag) - rebuilt so that within seconds she knows one thing: *"if labour starts today, am I ready?"* A readiness ring, a **"let's pack together"** guided flow with small wins, four category cards (Mom / Baby / Documents / Partner and extras) using **progressive disclosure** so no item is visible until she enters, per-item *why pack this* lines, "I don't need this" and "the hospital provides these" groups, and a persistent **"Labour started?"** bar leading to a calm grab-list: *"First - take a breath. You have time."*
- **Product Checklist** - she builds her own named lists from the catalogue, each item carrying a custom note, with curated starter lists and a filtered product picker.
- **Medication and Supplements** - a *"nourishment companion"*, never shaming or gamified. Daily and weekly views, a weekday awareness grid rather than a compliance score, multi-time alarms, and a disclaimer.
- **Reminders** - self-authored nudges with preset quick-add chips.

### 6.4 The knowledge tools

- **Tests, Scans and Reports** - one merged library replacing two older tiles, with a segmented toggle between *Tests and Scans* and *Findings and Conditions*, trimester filter chips, structured detail pages (including an "understanding your report" parameter breakdown), and a medical disclaimer on **every** page.
- **Can I...?** - the fastest way to settle an everyday worry. A verdict card in a small colour language (safe / in moderation / avoid), then the short answer, why, **trimester-by-trimester rows**, an **Indian context card**, related questions, and an Ask Veda handoff.
- **Symptom Companion** - calm understanding, not triage: what's common around this week, category chips, and per-symptom pages answering *how common, why it happens, what helps, when to call the doctor*. Logging is optional and flows into the Journal and Calendar.
- **Due Date Calculator** - *"the first chapter of the journey."* Five methods (LMP, conception, IVF, ultrasound, known EDD); the result "blooms" into a roadmap with milestones, a trimester breakdown, a conception window and a month view, ending in **"Start My Pregnancy Journey."**
- **Spiritual Reading** - a respectful, surface-level look at how traditions approach calm, gratitude and motherhood, framed as comfort and curiosity rather than instruction, with interested / not-interested marks that re-sort the list.
- **Product Guide** - deep research pages shared identically by both apps: the recommendation, ratings, a one-line verdict and best-for chips in ten seconds, with an honesty line about what to watch out for, then progressive depth (why we like it, expert video, community experience, ingredients explained, research in plain language, compare).

### 6.5 The keepsakes

- **My Journal** - the chronological memory timeline: memories, photos, notes for baby, and auto-generated milestone and health entries, with filters, a grouped list or a flip-through booklet, and the **combined (you + Dad)** view.
- **Bump Journey** - *a memory book, not a gallery*: a week-by-week timeline with milestone badges, gentle capture prompts, then-and-now comparison, caption suggestions and trimester filters.
- **Read Next** - stage-aware reading where **recommendations are primary and search secondary**, with a weekly pick, a looking-ahead row, curated books with a companion reader, and a *"why this matters now"* line on every item.

### 6.6 Products and cart

Reached from Home, search and Ask Veda rather than a Tools tile. Framed as a **trust-first decision engine, not a storefront**: each category opens with a twenty-second guidance card, then scored "ParentVeda Picks" carrying badges and visible trust (a score pill, why-rows and things-to-consider rows). Product detail adds a verdict, a week-relevance timeline and structured parent reviews. **Prices and scores are illustrative seed data**, and checkout is a preview that takes no payment.

## 7. The parenting app

The pregnancy app ends at birth; the parenting app runs from day one to age five. It is a **self-contained module that imports nothing from the pregnancy code** - the two halves stay code-isolated and agree only on values (palette, card language).

Its organising question is stated in the home screen's own source: **"Who is my child today?"** - and beneath it, *"What does my child need from me today?"*

### 7.1 The most important structural decision: Leaps became Phases

The parenting app was originally built on **Wonder Weeks** (ten "mental leaps" at fixed weeks). That was deliberately torn out, for three documented reasons:

1. The framework **failed replication** - the original author's own PhD student could not reproduce the fussy periods at the predicted weeks.
2. It **stops at about 20 months**, leaving nothing for ages two to five.
3. It **contradicted the product's own commitment**: *"telling every parent their baby is 'in Leap 5' at the same week is the opposite of personalisation."*

The spine is now **20 age phases aligned to AAP/CDC guidance**, of deliberately unequal width, organised around well-child-visit checkpoints and using the **AAP 75% threshold** ("most children can do this by now" - adopted in the 2022 revision specifically to stop "wait and see" delays).

The twenty phases run from *The fourth trimester* through *The first screening*, *One year old*, *Words gathering*, *Real conversation* to *Getting ready for school*.

Exactly **one insight survived** from Wonder Weeks - that a fussy patch often precedes a new skill - kept as *content inside phases*, never as structure. The legacy leap code still compiles and is kept dark for revert.

### 7.2 Navigation

The parenting app is entered from a doorway on the pregnancy Home and anchored to a single named route, which keeps the navigation stack shallow and tells the global Ask Veda button which app is on screen.

**Five hero tabs** in a floating pill identical in shape to the pregnancy app's: **My Child · AskVeda · Tools · Community · Products.**

Everything else lives in an **Explore drawer** of about twenty rows: My Child, Family Profile, Guided journeys, His journey (the phase map), Watch, Skill Development, Health, Recipes, Recommendations, READ, Courses and Masterclasses, Yoga and Classes, My Bookings, Invite a friend, Memories, Find help, Dadi/Nani Nuskhe, Investments, Astrology, and Journal V2.

### 7.3 A deliberate visual convergence

An explicit product mandate drove a harmonisation pass: *"the user shouldn't be able to differentiate between the two apps."*

The finding was that the colours were **already identical hexes declared twice** - the divergence was entirely in **form**, because the parenting app had no shared card component and every screen hand-rolled its own. The fix introduced shared primitives (one card, one section card, one carousel, one divider), unified the radius, matched the gutter to 18px, and - most tellingly - replaced the parenting **purple glow** shadow with the pregnancy **ink lift**, described as *"the single biggest visual tell that the two apps were not the same product."*

Genuine parenting-only conventions that remain: **no emoji anywhere**, no green on child and journal surfaces, diagonal-stripe placeholders standing in for photography, and a warm serif-forward "editorial calm" voice.

### 7.4 My Child - the home

The largest single screen in the module. Its scroll, in order:

- **Header** - mark and wordmark, then search, profile and the Explore hamburger.
- **The hero** - a purple gradient card with a warm pink bloom, carrying the child's photo and name (both opening a **multi-child switcher**), the age, a **phase journey bar** ("PHASE n OF 20", the phase name and tagline, a 0-5 year track with one tick per phase and a dot at the current position, and the next phase named), then a **growth** row of three stats - weight, height, head - each against a gentle "expected for his age" reference.
- **Today's Parenting Tip** - the twin of the pregnancy Grow module, indexed by day-of-year so it is stable within a day and rotates by itself.
- **Today's video**, resolved from the phase's category so there is never an empty case.
- **Child snapshot** - five flat rows (Brain, Physical, Language, Emotional, Nutrition), each with a stage headline, a colour-coded status pill, a written insight, and a quiet way in.
- **Coming up** - deliberately reframed to show **only what is next**, led by *"None of this is due yet. Knowing what is around the corner is how you help him get there."*
- **Journal** - four capture tiles: guided memory, quick capture, write a story, letter to the child.
- **Videos**, **Reads** and **Picks for this phase** - three carousels; picks sit last on purpose, *"the one place on the page that is about buying."*
- **Questions parents ask** - three rotating FAQs written to answer the 3am question honestly: *"Is this fussiness my fault?" - "No. Hard stretches come from his brain reorganising itself."*

### 7.5 Development - a companion, not a tracker

Framed hard in its own source: *"a development **companion** - not a tracker, assessment or checklist."* Progress is expressed as **words on a soft arc**, never percentages or grades, across eight areas (thinking, language, gross motor, fine motor, emotional, social, creativity, self-care).

Screens cover today's focus, a birth-to-five map with "you are here", per-area pages that always end in three "go deeper" rails (watch, learn, explore), per-activity pages with materials and safety notes and a quiet **"we did this"** (never a streak), and a **gentle check-in** that is explicitly *"not an assessment"* - soft adaptive questions, no score, no comparison, and a kind suggestion to mention anything to the paediatrician.

### 7.6 What Changed? - a ParentVeda original

Something suddenly different with the baby? The parent searches a library of about twenty-five concerns, each keyed by a **recognisable quote** - *"suddenly wakes every 2 hours"*, *"will only sleep on me"*, *"turns away and clamps his mouth shut"*, *"falls apart and cries every evening"*, *"keeps tugging at his ears"*.

Each concern is a self-contained mini-flow with **its own questions** and a likely-cause result carrying a tone - **calm** (a normal, reassuring cause), **caution** (worth getting checked), or **urgent** (see a doctor now) - which drives both the copy and the visual treatment. The doctor disclaimer stays on screen throughout: **a guided starting point, never a diagnosis.**

### 7.7 Health - a living companion

*"Not an EMR, not a document store: the child's health as a calm, understandable story."* One continuous flow with **no tabs and no folders**: a compact snapshot, a tools row (ID and documents, doctor visit companion, emergency card, health guide), a bucketed timeline preview, growth, vaccinations, an "add and view records" invitation - renamed from "medical history" because *"that described a folder; this is a request"* - and insights that appear **only when there is genuinely something to say**.

Standouts:

- **The Doctor Visit Companion** - generates a clean, shareable pre-appointment summary: age, growth, vaccinations, medications, allergies, recent history and reports, **plus the questions the parent saved for the doctor**. *"Never a diagnosis - just organised facts."*
- **The Emergency Card** - *"the one screen you can hand to anyone in a crisis"*: name, photo, DOB, weight, blood group, allergies, contacts, paediatrician, current medicines.
- **Growth Journey** - *"the percentile is one quiet piece of evidence, never the headline."* A calm chart with a soft typical-range band and the child's own line; the emotional headline is *"growing consistently"*, never a number.
- **Vaccinations** - modelled as chronological **age visits**, each with its vaccines, a government/IAP note and one educational insight. Status language is deliberately reassuring - **done / due now / upcoming**, *never "missed", never "critical"*. Detail pages teach before acting (why it matters, diseases prevented, expected reactions, myths, FAQs, after-care with red flags), and reminders are real local notifications. A three-way **cost comparison** shows what the government programme covers free, what the IAP recommends on top, and real private price ranges.
- **Documents** - fixed categories for the papers of early childhood, with **genuine file upload** into private storage rather than the picker's temp path, *"because a photographed birth certificate used to rot on the device even before you changed phones."*

### 7.8 Food - a companion, not a recipe library

*"Recipes V2 answers one question: what should I feed my child today?"* So a recipe carries the **why**, key nutrients, serving frequency, storage, common mistakes, substitutions, and a **"healthier ParentVeda version"** toggle that shows what changed and why. Positioning is **Indian-family first, evidence-based, no calorie counting, no diet culture**.

The signature pieces are the **Smart Meal Builder** (say the meal, the time you have and what is in the kitchen; get three to five recipes that fit, each explained for the child's stage, with missing ingredients added to the shopping list), a regenerable meal plan that keeps slot balance, and an auto-generated shopping list.

A notable product correction: tapping "Nutrition" used to open Recipes, *"which answers a question the parent of a two-month-old is not asking. Before six months there is nothing to cook."* The order is now non-negotiable: what nutrition is about at this age, then **milk by route**, then the nutrients that matter, then solids only once relevant, and **recipes last, as links out**. Everything is written as ranges with an explicit *"he is not an average"* caveat.

### 7.9 Watch - video learning, not video feed

*"A personalised video **learning** experience (not YouTube, not Reels). Every video carries learning metadata only - topic, age, expert, duration - never likes, views, followers or trending."*

Two modes over one catalogue: **Quick Learn** (30-90 second vertical clips) and **Deep Learn** (5-30 minute sessions), sharing recommendations, continue-watching, collections and progress.

The player is the signature: learning-only actions (**save, share, ask Veda** - never like or comment), and **instead of a comment feed**, a curated **"learn next" chain** that walks the parent onward through activity, article, product, recipe, community and Ask Veda. No autoplay-to-nowhere.

Two deliberate opposites sit side by side: **Quick Learn is finite** - after the curated set it ends on a calm *"that's enough for now"* card - while **Shorts loops forever**, the deliberate contrast.

**The video engine is genuinely built**: ParentVeda hosts its own video and plays it natively, so there is no third-party branding to hide. Everything on screen is ParentVeda's own overlay; autoplay is off; playback resumes from the last saved second; and fullscreen reparents the same player instance so playback never restarts. Screen-security is honest about scope - *"UX-grade deterrence, not DRM"* - and off by default.

### 7.10 READ, Community, Recommendations, Products

- **READ** - *"a premium reading experience, not a blog"*, answering *"what should I read today to be a more confident parent?"* One **Today's Read (not ten)**, continue-reading, and collections. The reader carries a progress bar, contents, font sizing, light/sepia/dark modes, inline expandable tips, **myth-vs-fact cards**, an evidence note, and a read-next chain.
- **Community** - a faithful parenting replica of the pregnancy community, reusing the same shared social layer with parenting rooms and posts, so the pregnancy feed is untouched.
- **Recommendations** - *"not a catalogue or a feed"* but a curated engine answering *"what is genuinely worth my time for my child today?"* Every item carries **the ParentVeda take: why we recommend it and what to consider.** It scores by age-fit, stage-fit and interest overlap, diversifies by category, and **explains why each recommendation appears**, across fourteen categories and ten smart collections - including *"Indian Story Books - our own tales, our own faces."*
- **Products** - *"Research first. Buy when you're sure."* Concern-based entry points, per-subcategory guidance with explicit **look-for** and **avoid** lists, trust-first detail pages (what is inside and how it works, the ParentVeda take, good and consider, "choose this if", the research behind the claims, provenance-tagged reviews), and **compare as a first-class tool** that holds no products of its own and explains its rules rather than failing silently.

### 7.11 Journal V2, naming, and the journey tools

- **Journal V2** - a keepsake **storybook**: a "continue reading" panel, recent moments, and an immersive paper reader with title page, contents, chapter dividers, photo spreads and an end page. Capture is *"two taps to a saved memory"*. An **"email to your child"** feature asks only for an address and opens the mail composer with subject and body **already written**.
- **Baby naming** - two complete generations exist; **V2 is the live path**: *"not a database to search - a gentle journey from the first spark to the name that becomes the first chapter of your child's story."* Both parents swipe independently and **only mutual likes ever surface**; the deep-dive adds an **AI name story**, a **ParentVeda perspective** (*educate, never influence*) and a **decision companion**; and choosing a name ends by opening the Journal to write *"The Story Behind My Name"* as Chapter One.
- **Four "journey" tools** share one grammar - an emotional hero, a **sub-ten-second quick log**, a plain-language insight, learn-while-tracking rows and a soft timeline: **Growth**, **Feeding** (breast, bottle or solids, where solids are recorded as *ate / tasted / refused* and **celebrated either way**), **Sleep** (*"understand sleep, not chase it"* - no "good/poor sleep" labels anywhere), and **Development** (*"milestones are observations to celebrate, never a test"*, where marking one observed takes a note, *"turning a checkbox into a memory"*).
- **Guided journeys** - the other shape: *"a path with a day 1 and a day 30, meant to be walked once."* Each day is a two-or-three-sentence read (*"a parent holding a baby has one hand and about ninety seconds"*), one concrete action, and often a line naming when to ask a real person. Self-paced with **no lock-outs**: *"a parent who misses four days has not failed anything."*
- **Dadi/Nani ke Nuskhe** - traditional remedies, each validated by an ayurvedic panel and cross-checked by a paediatrician, with the differentiator being an explicit **"when NOT to use - see a doctor instead"** block.

---

## 8. Ask Veda

### 8.1 What it is

A mother types any question in plain language and gets back **not a chat reply but a structured results page**. The internal framing: *"Ask Veda should feel like a Google results page for your pregnancy question, not a chatbot."*

Three principles govern it:

1. **One brain, two doors** - all AI logic lives in one backend service; the app and (next) WhatsApp are only entry points. Neither client contains any AI.
2. **One mother, one journey** - there is deliberately **no domain gating**. A postpartum mother can still ask about the anatomy scan and get a full answer, phrased in the past tense. Stage is **context for framing, never a filter**.
3. **Grounded, not generative** - the model may answer only from ParentVeda's own content or a whitelist of medical authorities, and is instructed to say it has no answer rather than improvise. **Community posts are permanently excluded as a source**, because opinions must never ground an answer.

### 8.2 The seven-section answer

Every response returns **every section key**, even when empty:

| # | Section | Source |
|---|---|---|
| 1 | **Veda Answer** - the direct answer | generated |
| 2 | **What this means for you** | generated, stage-aware |
| 3 | **Recommended next actions** | generated |
| 4 | **More information** (+ videos) | retrieved pointers |
| 5 | **Community insights** | not built - shows "coming soon" |
| 6 | **Products** | retrieved pointers |
| 7 | **Services / experts** | retrieved pointers |

Empty sections render a **"coming soon"** card rather than collapsing, so the format never looks like limited scope. Every card carries the app's own identity for the item, so tapping opens **the real article, not a snippet**.

### 8.3 How it works

A separate Python service that **shares but never owns** the ParentVeda database. Its pipeline runs the cheapest and safest checks first and the paid model call last:

`rate limit -> daily spend cap -> red-flag safety routing -> cache (exact, then semantic) -> one wide semantic search -> confidence floor -> generate sections 1-3 -> build pointer sections 4-7 -> cache and log`

- **Embeddings** run locally on CPU; **vectors live in the shared Postgres**; retrieval happens **inside the database**.
- The model is a **small, fast open model** chosen by benchmark: it was cheaper *and more accurate for grounded work*, because larger models added specifics that were not in the source content - a grounding risk.
- **Red-flag routing** short-circuits retrieval entirely for emergency phrases and returns a **calm** doctor-routing message, deliberately without alarm styling.
- **Caching is stage-bucketed**, so the same question caches separately per trimester or child age. Questions about *her own data* are **never cached**, and dosage-style questions are exact-match only.
- **The content flywheel:** anything the library cannot answer is answered from a **whitelist of medical authorities** (so she is never dead-ended), logged as a **content gap ranked by how often it is asked**, and drafted for a human editor - *never auto-published*. Every failure becomes tomorrow's owned content, and the gap list **is** the editorial to-do list.

Personalisation is a written instruction rather than a filter: the prompt describes her stage in plain English, so at four months postpartum the answer says *"During your pregnancy, the anatomy scan checked..."* while at week twelve it says *"you're still a bit ahead of the anatomy scan."*

The knowledge base ingests published articles, website posts, and - crucially - **the app's own offline corpus exported from the Dart source** (safety verdicts, symptoms, scan guides, readings, recipes, parenting knowledge). That export was the pivotal move: the parenting side previously had nothing to ground on, and the corpus went from 19 chunks to over 900.

### 8.4 In the app

Both Ask Veda screens are visually identical: a pinned white search pill, stage-wise suggestion cards, and the seven sections below. **One question, one result page - no chat history.** A global floating button opens it from every route in both apps, and contextual handoffs pass a question in from the safety checker, report help, vaccination pages, product guides and search.

If the service is unreachable the screen shows a calm **"connect to the internet"** card with a retry - **never a misleading offline answer**. The former on-device keyword engine is kept dormant but intact for revert.

---

## 9. The platform underneath

### 9.1 State

Every piece of state is a **singleton store** with a local cache, optional cloud sync, and screens listening directly. The local-first rule is absolute: a store shows its cached data **instantly, before any network call**, and **a cloud failure is never a crash**.

Four seams carry the sync: a single repository that every table call goes through (attaching identity automatically and no-oping when logged out), a **mixin for light key-value stores** that pushes the whole blob on any change, a **child-scoped sibling** for co-parented data, and a **registry** that re-runs every store's sync after a late login so data appears without an app restart.

The sync algorithm is an **id-keyed merge**, which is why the house rule is that **the app generates the row id** - local and cloud rows share one identity, making the merge trivial and idempotent.

### 9.2 Data

Around fifty-six tables across thirty-six migrations. Two gates guard every request: a **grant** (may this role touch the table at all) and **row-level security** (which rows). Four ownership shapes recur:

| Shape | Rule | Used for |
|---|---|---|
| **Own-row** - the pregnancy default | you see only your rows | journal, symptoms, saved items |
| **Co-parented** - the parenting default | scoped by child; the user id becomes *attribution*, not the access key | everything about the baby - both parents read and write |
| **Couple-scoped** | rows stay private; a database function returns only a derived answer | baby-name matches |
| **Write-only** | insert granted, no read policy at all | behavioural analytics |

The worked example that best explains the philosophy: two paired parents swipe names independently, a name is a match only if both liked it, and **neither may ever see the other's individual likes** - because seeing her list first means you just ratify it, and the second opinion becomes worthless. Rather than widening read access and *promising* not to display it, the votes stay private in every direction and a database function returns **only the intersection**. The generalisable rule: *when an answer must combine data individuals are not allowed to see raw, keep the rows private and put a function in front that returns only the computed answer.*

### 9.3 Content delivery

A separate concern from user data, solving one problem: bundled content means changing one word requires an app-store release.

**Four pillars:** content lives in **Supabase**; it is edited in **Directus** (self-hosted, free); content images are on **Cloudflare R2** (zero egress); video will be on **Bunny Stream** (parked until real videos exist).

The key architectural fact: **the app reads content from the database directly, never from the CMS.** So the CMS's load scales with the number of *editors*, not users - it can be a cheap, sleepy box forever. **One CMS feeds the app, the website, and the Ask Veda knowledge base**: publish once, everywhere reads it.

### 9.4 Bilingual

One toggle swaps the language wholesale - *"no language ever leaks into the other mode."* Roughly **1,700-1,800 bilingual UI strings** live in a single class, alongside bilingual content objects. The Hindi is **real conversational Hinglish in Latin script**, not formal Hindi.

### 9.5 Notifications

Local notifications are wrapped defensively - timezone-aware so a "9:00 AM" reminder means 9am locally, and every call guarded so a missing permission never crashes anything. Recurring medication schedules are materialised in a rolling window because platforms cap pending notifications.

**WhatsApp** is server-side by design: the sender is a privileged server function, never the client. A scheduler mirrors the app's week calculation exactly *so WhatsApp and the app can never disagree*, enqueues one message per mother per week with a **dedupe key that makes re-runs harmless**, and currently drains to a **mock sender** that proves the whole path without anything leaving the database.

---

## 10. Commerce, brand, and the doctor side

### 10.1 The booking engine

Everything reduces to one idea: **you buy an entitlement, then you spend it on slots.** Before it existed, the paid services were static catalogue entries with a price string and a booked-id set - **no real time, no seats, no credits, no history.**

**One engine serves both stages**, so a birthing class booked while pregnant and a postnatal yoga pack a year later appear in **one history** - *"two engines would split that in half, which is exactly what makes an app feel like two apps."*

**Time is real** (stored UTC, shown local) - the old string-based times are *"why nothing could ever remind a parent about a class: there was no time to compare against."* **The live call is one nullable field**, so the video provider stays a pluggable detail.

**Seat caps are the one thing that cannot be local**: if two mothers claim the last seat simultaneously, only a single authority can decide - so the seat count is never written by a client, and every booking goes through an atomic server function. **Payments** use the full three-step flow with **server-side signature verification**, never a trust-the-client shortcut.

### 10.2 Brand Studio

*Not an advertising platform - a brand **partnership** platform*, with the distinction enforced structurally.

**One door:** brand content enters the UI through a single resolver that returns a campaign or nothing. **One order that must never reverse:** education, then confidence, then recommendation, then commerce - so a slot may only exist where the parent is already learning or deciding.

Fifteen brand products reduce to **four archetypes**: a **takeover** (rare, once per campaign, three to six times a year - the only interruption permitted), a **destination** (visited on purpose, never pushed), **presented-by** (*the brand pays for the existence of the thing, never its contents*), and **ranked inventory** (entry into a list, gated by a quality floor and a **rank floor** - never a score bonus, never the top slot).

Nine invariants are pinned as **tests, not prose**, including: targeting can only narrow, **personalization never means more ads**, a global kill switch empties every slot, **ratings are untouchable** (byte-identical with the studio on, off, and with a live campaign for that exact brand), disclosure is always present, and **research pages stay clean**.

### 10.3 Referrals

Two ideas shape it: **the code is the source of truth and the link is a convenience** (a code survives being screenshotted, read aloud, or pasted into a chat - links do not), and **rewards are entitlements**, granted into the credit system that already exists rather than inventing a second currency.

The code alphabet **deliberately excludes ambiguous glyphs**, because *"a referral code gets read aloud down a phone and retyped by someone holding a baby."* And the client is explicitly **not the authority** - it keeps the UI honest and fails fast offline, but the server re-runs every check, *"because a client that decides who gets paid is a client that can be edited."*

### 10.4 Doctor mode

One app, two audiences: the same binary boots into a doctor dashboard. A doctor is a doctor - pregnancy specialists and parenting experts are unified into one directory with a stage tag.

The **availability engine** follows real practice software - working hours, then sessions, then duration, then exceptions - and **slots are derived, never hand-stored**, so the parent's list and the doctor's intent are the same thing by construction. It replaced an earlier model where *"a doctor working 10:30-13:00 and 17:00-20:30 - the ordinary Indian clinic pattern - could not express their working day at all."*

The **consult policy** answers the three questions every telemedicine platform must: doctor cancels (parent made whole immediately, in full), parent no-shows (doctor paid after a **ten-minute grace**, because joining five minutes late is ordinary life), and late cancellation (free up to two hours before; inside that the credit is not returned but **one free reschedule** is given, because taking money *and* the appointment would be punitive).

Reminders are the **one place the product is deliberately pushy**: *"a missed consultation is the worst outcome in the whole product - the parent waited, paid, and nobody came."*

### 10.5 Memories

Shareable keepsake cards for two milestones. **Templates do all the layout** - the parent fills in words and a photo and never moves anything. Every template is drawn in code, so **no image assets ship** and each is crisp at any export size. The card is made **entirely on-device**, and the analytics deliberately carry **no name, no date, no message, no photo** - only closed vocabularies - *"which is the only way an analytics table belongs anywhere near a keepsake feature."*

---

## 11. Current status

### 11.1 Genuinely built and persisted

Auth and partner pairing; the full pregnancy weekly journey with real per-week photography; Garbh Sanskar; all pregnancy trackers; journal, bump journey and keepsakes; scans and appointments shared across the couple; the parenting child profile with multi-child support; growth with percentile estimation; feeding, sleep and milestone logs; vaccinations with real reminders; health records with real file upload; reading and watch progress; recommendations; naming; community posting; bookings with server-side seat claims; the Ask Veda service end to end; the content CMS with images on R2.

### 11.2 Real engine, seeded data

Ask Veda (real retrieval; the corpus is authored content); the Deep Learn video player (real native playback pointed at a placeholder file until signed URLs arrive); product scores and prices (explicitly illustrative); community expert badges and counts.

### 11.3 Explicitly mock or pending

- **All payment flows** are mock and labelled on screen - no money moves.
- **Video**: Quick Learn, Shorts and recorded yoga are still mock surfaces; the Ask Veda video section is not yet ingested.
- **Ask Veda deployment** - the service still runs locally; WhatsApp is mock-only pending the provider account.
- **Community insights** (Ask Veda section 5) is not built.
- **Social logins** and the password-recovery branch are UI-only.
- A long, honest list of **"coming soon"** actions: journal edit/share/print, name pronunciation audio, some exports.

### 11.4 Testing scaffolding to remove before launch

The dev-only Mom/Dad preview pill; "reset to week 20"; the doctor-role picker in auth; a due date pinned to week 20; and a father experience whose week re-skin is currently gated to a single week with a hard-coded name.

---

## 12. Rules any new module must follow

This section exists for anyone designing a **new stage or module** for ParentVeda. These are the conventions that make a feature feel native rather than bolted on.

### 12.1 Structure

1. **Do not add a navigation layer.** Personalization changes content, ranking and order - never where things live. Everyone learns one ParentVeda.
2. **A feature is never hidden.** Every section renders even when empty; only the empty copy changes. The empty state is the feature's advertisement.
3. **One brain, two doors.** If a capability already exists for another stage (booking, Ask Veda, personalization, community, content), extend it rather than building a parallel one. Two of a thing is what makes an app feel like two apps.
4. **Isolate the module's screens** the way the parenting app is isolated - importing nothing from another stage's screens - while sharing *services* and agreeing on values.

### 12.2 Voice and tone

5. **Companion, not tracker.** Every major surface in the product describes itself this way, and it changes the copy fundamentally.
6. **Warm language is a contract**: emerging rather than behind; due now rather than missed; celebrated either way rather than pass/fail.
7. **No gamification** - no points, streaks-as-pressure, badges, or lock-outs.
8. **Never a diagnosis.** Any diagnostic-shaped surface routes to a clinician, ends with a disclaimer, and distinguishes calm from urgent without alarm styling.
9. **Explain the why.** Every recommendation carries both why it is recommended *and* what to consider.
10. **Be honest about what is not built** - "link coming" rather than a dead button, "no payment is taken" rather than a fake receipt.

### 12.3 Craft

11. **Bilingual from the first string** - English and conversational Hinglish, never one retrofitted later.
12. **India-first content**, not localised afterwards.
13. **Original content only** - no copyrighted rhymes, stories or text.
14. **No decorative emoji** in chrome; line icons instead.
15. **Match the design language**: the shared card shell, 18px gutters, near-flat elevation, Fraunces for hero moments only, horizontal progress rather than percentage rings, progressive disclosure with the answer in ten seconds above the fold.
16. **Comment out, never delete** superseded work.

### 12.4 Data and privacy

17. **Local-first**: show cached data instantly; sync after; never crash on a cloud failure.
18. **The app generates row ids** so sync stays an idempotent merge.
19. **Choose the right ownership shape** - own-row, co-parented, couple-scoped (private rows plus a derived answer), or write-only.
20. **Never invent data about a family.** Seed content must be structurally incapable of reaching a real account.
21. **Derive, never ask** what the app already knows; ask progressively, in context, stating the payoff.
22. **Money and seats are decided server-side**, always.

### 12.5 The specific hook for a Trying-to-Conceive stage

Two things already in the codebase are worth knowing:

- **The onboarding profile screen already offers "I AM CURRENTLY: Trying / Pregnant / New parent"** - a three-way selector the mother can already choose. Today the value is **captured but not persisted**, and the personalization documentation explicitly flags it as *the natural future home for a trying-to-conceive stage*. That is the intended entry point.
- **The Tools hub already lists a "Due date and ovulation" tile** that currently shows a "coming soon" message, and the yoga catalogue already carries a **Post-IVF** category. The product has been leaving room for this stage.

A TTC module would also inherit, with no new infrastructure: the booking engine (one history across stages), Ask Veda (which by design refuses to gate answers by stage), the personalization store (one family profile across stages), the content CMS (a new `domain` tag needs no migration), the community layer, the brand and referral systems, and the co-parenting model - which matters, because trying to conceive is a **two-person** experience and the product already knows how to pair two accounts and share data between them.

The open questions a TTC design must answer are therefore not technical but editorial: **what replaces the due date as the spine** (the app's entire pregnancy experience is driven by one date), **what the daily ritual is** when there is no week number to advance, **how to hold hope and disappointment month after month** without gamifying either, and **how to be honest about medical limits** in a domain where anxiety is the default emotional state.

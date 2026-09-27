# TTC launch walk — "could she use this tomorrow?"

Started 2026-09-27 on the main phone (RZCX50ZKLBA, S21 FE), release build with `PV_DEV=true`. Asked by the user:
walk the whole Trying to Conceive side as a recursive tree (home, then each door, then everything inside it, to the
last tap), judge every screen as if the stage launched tomorrow, and recheck it against the gap analysis PDF
(`Downloads/competitor-walks/combined-ttc/v2/`). Structure and content first; the per-door UI/UX elevation with the
competitor study comes after, as its own pass.

Rules of the walk: navigate freely, never leave a log behind (a log needed to see a state is made and undone), no
settings changed. Screens are judged on four questions: does it work, is it clear in one read, is it what the PDF
asked for, and would a first-time user know what to do next.

Severity: **B** = launch blocker (broken, wrong, misleading, dead end) · **C** = confusing or off the PDF, fix before
launch · **P** = polish, can wait for the UI/UX pass.

## Tree and findings

(Filled in as the walk goes. Each finding: id, where, what, severity, status.)

### 0. Found while starting

- **W0.1** Home quick actions (Period, Symptoms, Sex, Test): the new round buttons exposed no tap action to screen
  readers (`excludeSemantics` also drops the InkWell's action). **B** (accessibility). FIXED in code: the Semantics
  node carries `onTap`.

### 1. Home → hero → Cycle Companion

- **W1.1** Fertile window length disagrees with itself: hero "today and 6 more days", companion "Fertile days 27 Sep
  to 3 Oct, 7 days", while every read and the window screen's words say six days ending ON ovulation (the user's
  decision, 2026-09-26; the tool was left shading 7 because tools were out of scope then). **B** (two answers to one
  question). Fix: the resolver's window becomes six days ending on ovulation everywhere.
- **W1.2** Companion "Your dates": each row judges the cycle BEFORE its start (`start - previous`) instead of the cycle
  that began on it (`CycleStore.cycleFrom`, which exists for exactly this), and one message serves every rejected gap:
  a 10-day gap reads "A gap this long is usually a month that wasn't logged". The CURRENT cycle's row also says NOT
  COUNTED. **B** (wrong reason on her own data). Fix: row reads `cycleFrom`; no verdict on the current cycle; short
  and long gaps get their own sentence.
- **W1.3** Companion "Your rhythm": "Your first full cycle 28 days" when no full cycle has counted; 28 is the starting
  guess. **C**. Fix: say it is a starting guess until two periods are logged (the K2 rule), and name her own first
  cycle when there is one.

### 2. Home → Messages · Fertility Window · Calendar · Family Timeline

- Messages list: clear (the message, "What we send" with a switch each, phone notifications). OK.
- **W2.1** Message → Fertility Window: subtitle reads "Cycle day 9 · Sep" (the day number of the date is missing).
  **C**. Also three names for one thing on one path: home "Your fertile days", app bar "Fertility Window", title
  "Your fertile days", messages "fertile window". **C**: one name.
- Fertility Window "Why six days" explains the 7th shaded day as a margin, so this screen is coherent; W1.1 is the
  hero and companion counting 7 as "fertile days". Fix: 6 everywhere, the margin day shown only here, labelled.
- **W2.2** Calendar opened from Today's header lights **You** in the bar (`TtcPage(tab: 3)`, a V1 index). **B** (she
  thinks she changed tab). Fix: the calendar is a pushed page of Today.
- **W2.3** Calendar marks only the first day of each period; the companion says 19 to 23 Sep. **C** (the legend's
  "Period" promises the days). Fix: shade logged bleed days.
- **P2.4** Calendar "Today" card: "If this cycle works, your due date would be around 20 Jun 2027". A conception-date
  calculator is standard (What to Expect has one), but on the home's calendar every day it can read as pressure. For
  the UI/UX pass.
- **P2.5** Family Timeline "Logged your first period · 30 Aug" shows the day she logged, not the period (5 Aug). Polish.

### 3. Home → daily insight cards

- Chance of conceiving → Fertility Window; Cycle day → Companion; How did today feel → the logger; nutrition, myth
  and movement → sheets. All reachable, all right destinations.
- **W3.1** A daily insight opened in the reader says "By ParentVeda editorial" (`ttc_insight_read.dart:144`); the
  byline rule is "ParentVeda team". **C**.
- **W3.2** Its note "…ask them — they know your case…" carries an em dash (the TTC voice has none). The string is
  the shared `kPvShortPieceCallout`, also used by pregnancy, so TTC gets its own copy rather than a pregnancy edit. **C**.
- **P3.3** The insight's cover is a pale grey drawn book: reads as a missing image. For the UI/UX pass (phase or
  topic art).

### 4. Home, the rest (doors row to the foot)

- Doors row: all nine, Fertile window first in the window (situation order). Sanskar: five small things, no streak.
  Journal, Record a positive test and the estimates line are present. No community. OK against the checklist.
- **W4.1** "Recommended reads for today" holds the old chapter card ("Preparing Together · Next: Knowing Your Rhythm,
  from the day you log your next period" with ME / US / WHAT'S NEXT) although she has logged many periods and the
  hero already knows her cycle day. Wrong promise, and a chapter panel under a reads heading. **B**.
- **W4.2** Recommended products and recommended reads show flat tinted blocks with a bag or nothing where the
  picture goes. On the first screen a new user scrolls, it reads unfinished. **C** (photos owed; at least a drawn
  mark per category until then).
- **W4.3** "Talk to experts" shows bare roles with a grey person glyph (Gynaecologist, Fertility specialist,
  Nutritionist); the checklist asks for named roster experts with photo and qualification where they exist. **C**.

### 5. Door 1 — Fertile window (6 tabs: When and how 14 · Waiting and testing 9 · Sex and closeness 6 · What he can do 4 · What you can do 5 · See a doctor 3)

- Hero photo, search, tab cards, question headings, rails and list rows all render; "Should I test?" chat works and
  agrees with the calendar (period due 17 Oct). Content matches the PDF's asks for this door.
- **W5.1** Six tabs, two visible on arrival and no peek of a third: tabs 3 to 6 are undiscoverable. **C** (UI pass,
  STILL-OPEN §79.11): a visible peek, or fewer tabs.
- **W5.2** Myth story opens with "REVIEWED BY · ParentVeda team": the team is not a reviewer; the byline rule is
  "By ParentVeda team" with no review claim. **C** (honesty).
- **W5.3** Tile "How often is best" opens the read "Timing, and the advice you can let go of" at its top: the tap
  lands on a different title. Audit every tile for this (script). **C**.
- **P5.4** Every rail card is a tinted block with a big format glyph (page, question mark, play), so rails read as
  templates; reads open under a grey drawn book. For the UI/UX pass (photos or topic art).

### 6. The whole door tree, audited in code (every tile of all nine doors)

A temporary test walked `kTtcFocusPages`: every tab, section and tile, where each tile goes and whether it resolves
(reads, surfaces, doors, recipes, video slots), plus every read in `kTtcReads` (short answer, byline, paragraph
length, em dashes, read-next, next steps, whether any door links it).

- All read, surface, door and recipe targets resolve. Two tabs with no sections (PCOS "Where do I stand", Mind & body
  "Today") are tool tabs by design (`toolSurfaceId`). OK.
- Every read has a short answer; no "editorial" byline, no team byline marked reviewed, no paragraph over 60 words, no
  em dash, every read-next and next-step target resolves. OK.
- **W6.1** 89 tiles carry a shorter title than the read they open; almost all are the same question said shorter, which
  is fine. Three promise something the read's top does not: "Which days can you get pregnant?" → "How conception
  works"; "What to eat and avoid" → "The three months before"; "Vitamin D, B12 and iron" → "When to start what, and how
  early". **C**. Fix: land them on the section that answers (`atHeading`).
- **W6.2** The twelve treatment reads (trigger shot, transfer day, the wait after IVF or IUI, the beta test, negative
  after treatment, baseline scan, frozen transfer, monitoring scans, IUI day, embryo days, fresh or frozen, review
  appointment) are reachable ONLY from a running round's screens and Learn. Someone reading up before a round, most of
  the IVF door's visitors, cannot find them on the IVF door. **B** (content built and hidden). Fix: put them in the IVF
  door's "Going through it" tab under the questions they answer.
- **W6.3** "Food, insulin and PCOS" exists twice on the PCOS door's path: a video tile with that title (a film still to
  make) and a read with that title that no door links. The read is the thing the PDF asked for (with a sample Indian
  menu). **C**. Fix: the read joins the PCOS "What helps" tab beside the film.
- Video tiles: seven slots not yet filmed open the "still making this film" sheet. Decided (videos treated as real). OK.

### 7. Doors 2 to 9 on the phone (hero, tabs, the special blocks)

All eight open in the new design with the user's photographs, search and tab cards; tool tabs work (PCOS "Where do I
stand" eight questions inline; Mind & body "Today" two practice cards and two small things). The IVF door shows
"Starting treatment?" with Start, and the start flow opens on "What kind of treatment is this?" (seven kinds).

- **W7.1** PCOS self-check question 7 asks "How long have you been trying?", which the app already knows from her
  journey (derive, never ask). **C**. Fix: prefill from her months trying and let her change it.
- **W7.2** Accessibility: the IVF "Starting treatment?" card's Start button is not its own element (merged into the
  section, not pressable by a screen reader), and the start flow's seven options expose no button role. Same family as
  W0.1. **B** (accessibility). Fix: a sweep of custom tappables (GestureDetector without Semantics) across TTC.
- **W7.3** After a loss, pinned "Go to a hospital today, not tomorrow": after the six signs, four sentences of prose
  are drawn as bullets ("These are signs of heavy bleeding or infection.", "Both can be treated…", "Trust yourself on
  this.", "If something feels wrong, get seen.") so the list reads as ten signs. **B** (an urgent list must be exact).
  Fix: the flag block keeps signs as bullets and the closing prose as a paragraph.
- **W7.4** After a loss hero: "…and people who've been through it too", a promise of the community that is held back.
  **C**. Fix: reword to what is there (Care Circle, a counsellor).
- **W7.5** Taking a while, pinned "Don't wait for the twelve months": "book now if … you're 36 or over", while the app's
  age rule is six months from 35. **C** (age said the same everywhere). Fix: one age line, the same as the check card.
- **P7.6** Mind & body has a "Getting ready" tab (12 things) that repeats the Getting ready door. Declutter candidate
  for the UI/UX pass.

### 8. Tabs — Learn · Products · Tools

- Learn: search, topics, pick up where you left off, the 101 path with read ticks, films honestly "on the way", a
  section per door with its tabs as chips. OK.
- **P8.1** Learn: the Fertile window topic says "27 reads" while its section says "Show all 18"; the section is named
  "Conceiving & the fertile window" while the door is "Fertile window". Polish (one count, one name).
- Products: real photographs, shop by need, trust labels. OK in shape.
- **W8.2** Products: star ratings and counts ("4.6 (3120)") and a "BESTSELLER" badge: if these are seed values, they
  are invented numbers on a health product (the rules forbid invented numbers). **C** — confirm the source; hide them
  until real. (Shared store, so the fix is store-wide or TTC-gated.)
- **W8.3** Products: "Home pregnancy test", brand PREGA NEWS, shows a Clearblue test in its photo. **C** (a photo of a
  different brand misleads).
- **W8.4** Tools › Symptom companion opens the RETIRED generic tracker (`openTtcTracker('symptoms')`: five-point
  sliders), while the home's Symptoms opens the new logger (`ttc_symptom_log`). Two loggers for one job. **B**.
  Tools › Mood is the same family: a five-point mood scale beside the logger's thirteen feelings of trying. **C**.
- **W8.5** Tools › Should I get help? asks "How old are you?" although the age band is saved once and read everywhere
  (the months-trying question is correctly prefilled). **C**. Fix: prefill the saved age band, same as months.
- **W8.6** Tools › Talk to an expert: the page title reads "Learn" (eyebrow "Preparing together"); the six people are
  generic ("A ParentVeda expert", two "A fertility specialist" at ₹899 and ₹1,299 with nothing to tell them apart).
  **B** (title) / **C** (names: roster experts with name, photo and qualification, or at least what differs).
- **P8.7** Tools list: "1 days logged". Polish. "Fertility window" (tool) vs "Fertile window" (door) naming, see W2.1.

## Fix batch 1 — 2026-09-27 (code done; suite and device check next)

| id | status | what changed |
|---|---|---|
| W1.1 | FIXED | `ttcWindowClosesAfterOvulation` 1 → 0: six days ending on ovulation everywhere (hero, companion, messages, calendar, report, chapters). The chapter engine now reads the shared constants instead of its own `ov - 5` / `ov + 1`. Window screen and glossary lose the "we add the day after" sentence (Hinglish note too). |
| W1.2 | FIXED | Companion rows read `CycleStore.cycleFrom` (the cycle that began on that date); the current cycle has no verdict; a short gap says "Too short to be a whole cycle…", a long one keeps its sentence. |
| W1.3 | FIXED | Rhythm label: "A starting guess" when no cycle has counted. |
| W2.1 | FIXED | Window subtitle shows the date ("Cycle day 9 · 27 Sep"); "Fertile window" is the one name (app bar, Tools). |
| W2.2 | FIXED | Calendar lights Today, not You (`ttcV3ActiveFor`). |
| W2.3 | FIXED | Calendar shades logged bleeding days after day one, lighter. |
| W3.1/3.2 | FIXED | Daily insight byline "ParentVeda team"; TTC's own short-piece note without the em dash (pregnancy's unchanged). |
| W4.1 | FIXED | The chapter follows the cycle once there is one (the 28-day "young journey" rule is kept for revert); "Preparing Together" is for someone with nothing logged. |
| W4.2 | FIXED (products) | The home's product rail shows the store's photographed "where most couples start" cards; the guide rail stays as the empty-catalogue fallback. Read covers stay for the UI pass. |
| W5.1 | FIXED | TTC tab cards 168 → 150dp so a third tab always peeks (pregnancy untouched). |
| W5.2 | FIXED | Story pill: "BY · ParentVeda team" for the team, "REVIEWED BY · name" for a person, never the words twice. |
| W6.1 | FIXED | Three tiles land on the section that answers them (`atHeading`); "Which days can you get pregnant?" now opens the timing read. |
| W6.2 | FIXED | IVF door "Going through it" gains "What happens at each step?" (eight reads, in round order) and "The wait, and after the result" (four). |
| W6.3 | FIXED | PCOS "What helps" gains the read "Food, insulin and PCOS: a day of eating". |
| W7.1 | FIXED | PCOS quick check prefills "How long have you been trying?" from her journey. |
| W7.2 / W0.1 | FIXED | Seven `Semantics(excludeSemantics: true)` buttons carry `onTap` (home blood-test line, round card pills, round screen buttons and options, the start card, the IVF panel pills and reads). Shared screens scanned: none. |
| W7.3 | FIXED | Door urgent lists: signs only as bullets; the closing advice after a blank line renders as a paragraph (five reads given the break). |
| W7.4 | FIXED | After a loss hero promises "someone to talk to", not a community. |
| W7.5 | FIXED, doctor check owed | One age rule: 35 and six months. "When it's time to see a doctor" (short answer, body, pinned list, evidence now naming ASRM/ACOG with NICE's 36 as the UK line), the IVF pinned list, and the fertility-help tool's age rule (fires at six months at 35+, not at once from 36). |
| W8.2 | FIXED | TTC shelf shows no seed ratings, counts, named parent quotes, percentages or badges (`kTtcShowSeedReviews`, a build define, off). |
| W8.3 | FIXED | Prega News test and LH strips lose the Clearblue photo and the pregnant-belly photo; an LH strip photo is owed. |
| W8.4 | FIXED | Tools › Symptom companion and Mood open the new logger. |
| W8.5 | NOT A BUG | The tool asks age only when none is saved (this phone had none). Retracted. |
| W8.6 | FIXED (title) | "Talk to an expert" and "Courses" pages carry their own titles; TTC's Learn eyebrow is "Trying to conceive". Named experts: user decision owed. |
| P8.7 | FIXED | "1 day logged". |

**Owed to the user (decisions):** (1) which roster experts are bookable at launch, with photo and price, for the
home's "Talk to experts" and the consults page (W4.3, W8.6); (2) doctor check of the new age wording (W7.5) and of
the six-day window everywhere (W1.1).

### The user's answers (2026-09-27) and what was done

- **Experts: "i gave u an excel for experts right.. put them for now".** From the roster in
  `MASTER-CONTENT-PLAN-v3.xlsx` (plus Dr Surbhi Sharma, onboarded separately): the consults page and the home's
  "Talk to experts" rail show people, not roles. Fertility consult and IVF prep: Dr Surbhi Sharma (IVF gynaecologist,
  Bloom IVF). Gynae consult, couple assessment, the PCOS programme and "Fertility, honestly": Dr Ruchika Sood (IVF
  gynaecologist). Nutrition: Akanksha Srivastava. Psychology and After a loss: Parmeshwari. Fertility yoga: Dr Kajal
  Sharma. The andrologist stays a role: the roster has none. A consult row reads "role · what it is", so one person
  with two consults is told apart; the home cards carry initials, the name, a verified tick, role and price.
  (`pv_learn_catalog.dart` `_ttcRosterFor`, `ttc_home_v3.dart` `_ExpertRail`.)
- **Age: "do what flo and what to expect have done, making sure to adjust according to indian women".** The ASRM/ACOG
  lines both apps use: under 35, twelve months; 35 and over, six months; over 40, straight away. The see-a-doctor read
  says all three, its pinned list adds 40, and the fertility-help tool gains an "over 40, don't wait" rule. The Indian
  adjustment is a population fact, said as one: Indian AMH studies find egg reserve falls a few years earlier than in
  European women (J Hum Reprod Sci 2022, 54,473 women; Fertil Steril 2013), so a woman in her early thirties who is
  planning may ask her doctor about an AMH test. Never a prediction about her. Doctor check still owed.
- The Learn eyebrow change (W8.6) was reverted: `ttc_polish_test` records the decision that it carries her chapter,
  and with the chapter now following her cycle it says the right thing.

## Walk 2 on build 6, and fix batch 2 — 2026-09-27

Verified on the phone: six-day window everywhere, Companion rows and "A starting guess", calendar lights Today, IVF
"Going through it" (18 things), After a loss signs then advice, the peek of the third tab, the store photos on the
home, roster experts on the home and the consults page, the chapter following the cycle.

Found and fixed in batch 2:
- **W9.1** Home hero: about sixty points of empty band between the date range and the quick buttons. Block 150 → 128,
  gap 18 → 10 (the FittedBox scales a rare long pairing). **C** FIXED.
- **W9.2** Home chapter card: ME / US / WHAT'S NEXT drew as three full-width stacked buttons. Cause: a Container with an
  `alignment` inside a Wrap expands to the full width. Sized by padding now. **C** FIXED.
- **W9.3** Home reads rail: blank tinted blocks. Now the read's photograph, or the tint with a book mark. **C** FIXED.
- **W9.4** Calendar lights Today (W2.2) but the shared nav bar ignores a tap on the lit tab, so Today did nothing
  there. `PvNavBar.onReselect` (optional, null everywhere else): TTC sends Today home from a pushed page, and scrolls a
  tab back to the top. **B** FIXED.
- **W9.5** Consults: Dr Ruchika Sood twice with the same line (the row keeps the role up to its first "·"). The couple
  assessment leads with its name. **C** FIXED.
- **W9.6** Tools › Medication and Appointments had no side gutter (content ran to the glass); Medication printed its
  no-advice note twice and an "estimates" footer that is about cycle dates. **B** (layout) FIXED.
- **W9.7** Supplements: "Folic acid" listed twice. `add` returns the existing row for the same name and person. **C**
  FIXED.
- **W9.8** You tab, the user's choice "Short and grouped" (Flo, Clue, Lifesum on Mobbin): the identity line carries
  how long and her cycles; the details list folds into a "Your answers" row; four groups (Your health: notes for your
  doctor, records, treatment with its state, your answers · Your app: messages, what you see · Bookings and orders:
  programmes and sessions, bookings, addresses); Calendar, Companion and Fertile window leave You (Today and Tools
  hold them); no Children dash while trying; no dash in the partner line; the developer section sits last, under the
  footer, so it reads as apart from the release screen. Other stages unchanged (`PvYouStageContent.groups` is null
  for them). FIXED.
- Seen and fine: Medical tests, Vaccinations, Records, Courses (one free course, honest), Nutrition planner, Journey
  map, Can I…?, the checklist, BMI, the journal, the treatment start flow's first screen.

## Fix batch 3 — relevance ("cakes, not pizza"), the calendar, home taps — 2026-09-27

The user's rule: everything on a screen must make sense on that screen, and every tap must land where its label
promises (a bakery filtered for cakes should not show a pizza). Recorded as a standing rule in memory.

- **Relevance audit** of every door, tab, section and tile (scratchpad `relevance_audit.md`): 11 MUST, 46 SHOULD. A
  helper agent fixed all MUST and every clean SHOULD in `lib/ttc/focus/*` (old tiles commented, kept for revert),
  reviewed by the lead. Highlights: consult tiles open the offering they name (a psychologist tile opened a list of
  doctors), His side's "Zinc / CoQ10" became two products, "His emotional side" opens a read about him, seven film
  tiles that pointed at unmade films now point at finished films with the same promise, PCOS "What your cycle shows"
  opens the cycle report (not the same check as the tab above it), Mind & body's Getting ready tab is trimmed to sleep
  and a labelled link, After a loss gains "When grief needs more help" and an ectopic-signs tile, IVF's Track tab
  regains "Your medicines and timings", and "How conception works" finally has a door tile.
  Left for the owner (agent's list): a door tile cannot choose a tab yet; a Booking tile with an offering id opens
  nothing (none remain, the test should say so); a "When to test" film and a "Line eyes" myth card need new writing;
  two Getting ready films stay off the door by an earlier decision; four film tiles still wait for films.
- **Home taps:** "See everyone" opens the consults (it opened the whole catalogue with a pregnancy course);
  "Write" and "How today felt" open the writing sheet (a memory, a feeling); "Log for today" opens the logger (it
  opened the calendar); "The two of you" (it opened his side, which is its own pass) is "For the doctor".
- **Learn:** "Continue" offers only this stage's courses ("The Complete Pregnancy Guide" showed while trying).
- **Calendar redesign** (the user: "looks old and outdated"; Mobbin: Fitbit, Flo, Apple Health, Oura): a page of
  Today with a back arrow, a large "Calendar" title and a Today chip (no wordmark header, no "Everything, in one
  place"); the month flat on the page with a large name and two round arrows (no card); the colour key one quiet line
  (no folding card); the day card titled with the date and "Cycle day N", with "Log symptoms" and "Edit period dates";
  the family timeline a quiet link. A round's long key labels wrap (an overflow at 360dp the date test caught).
- **Hero ⓘ:** right after the date line (it floated alone at the edge), in the accent and a size up (it looked dull).
- **Logger search:** not filled white inside its grey pill (a box inside a box); Ask Veda's field opted out too.
- **You:** the identity line leaves out "cycles not sure".
- **Next, after her side is complete:** his side of trying to conceive ("his side", not "father mode"): study Flo for
  Partners on Mobbin, recommend what he sees (the hero and insights for him, likely no doors), then build.

## Her side: last checks, and his side begun — 2026-09-27

Her side, closing items: a door tile can name the tab it opens on (`TtcDoorTile.group`; Taking a while's "Mind and
body" lands on Hard days); a Booking tile with an offering id opens that offering (it opened nothing);
`test/ttc_relevance_test.dart` holds atHeading targets, consult ids and door tabs; the unscoped programmes page is
titled "Programmes and sessions" (it said "Learn"); "Bookings" opens "Your learning", deliberately one list across the
journey (kept). Tap-checked on the phone: You's rows, Products' shop-by-need rows, the home's links.

**His side of trying to conceive** (the user: after her side; "his side", not "father mode"; hero and today's
insights stay, doors can go; Flo for Partners studied on Mobbin, notes in scratchpad `his_side_research.md`):
- **W10.1 On V3, the home that ships, he saw HER home** (her symptoms, her Sex log, her doors): only V1's Today
  checked `TtcPartnerMode`. `ttc_home_version.dart` now routes to his Today (`TtcPartnerTodayScreen`) whichever version
  is on. **B** FIXED. (The account path by which a paired partner's device sets this is the father-mode pass the user
  scheduled separately.)
- His Today, brought to the V3 language: white ground (the sand ground read as the older app), the date header in her
  header's shape, the hero without the amber circle stuck behind "What's next", "For you today" as a rail of up to
  three pieces written for him (one card before), and one door, his own (His side). Everything else was already right
  and stays: his round line, his mission, his practice, supporting her by her chapter, tonight's question, her body
  explained, his half, Ask Veda (sends the chapter, never her cycle day), the shared journal.
  `test/ttc_his_side_home_test.dart`.
- **W10.2 His tabs were all hers.** Tools listed her period, symptoms, weight, mood and a PCOS check for him. Flo for
  Partners' line is copied: he sees what is his and what is shared, and never logs or edits hers. His Tools
  (`ttcToolGroupsFor(him:)`, `kTtcHisToolIds`) = her fertile window (to read), his own health (renamed "Your health"
  for him, since "Partner health · His half of this" named him in the third person), the shared journal, talk to an
  expert, medical tests, records, appointments, courses, journey map; search and the recents strip keep to that set.
  **B** FIXED. Learn keeps the one library for both (Flo gives partners the pieces about her body too), but his own
  door and Mind and body lead the topics (`kTtcHisLearnFirst`). **C** FIXED. Products: only one product is marked
  for him (zinc and folic acid), so a his "for you" shelf would be one card; left as her shelf and logged as owed
  content (STILL-OPEN §79.13), not a near-empty shelf.
- **W10.3 Build 10 on the phone, as him** (2026-09-27): his Today, Tools and Learn are his; her home returns on
  switching back. Fixed from the walk: the floating Her / Him pill sat over his cards on every scroll and is gone (his
  phone reaches this screen by pairing; the preview switch is in You › Developer, as for her V3 home) **C**; "For you
  today" moved up under his mission (it sat eighth, under his door) and its cards fit what they hold (a third of each
  was blank) **C**; his Tools says its own opening line and heads her window "Her cycle", not "Your body" **C**.

## Simplicity pass on her home, and TTC as the reference — 2026-09-27 (the user)

The user: every screen must say what it is in simple English; remove what makes her ask "why is this here?"; one app,
so a section that exists on two stages is drawn one way, the best one (ours, a competitor's, or Mobbin's), and
Trying to conceive is the reference the pregnancy side will copy later.

Done on her home (`lib/screens/ttc/ttc_home_v3.dart`, `ttc_daily_insights.dart`):
- **Recommended reads for today carries only reads.** The "Trying Together" chapter card (a chapter is not a read, and
  its name explained nothing) and the "See everything" row are commented out. The reads are three **rows** (74dp photo
  or the door's drawn page mark, serif title, "TOPIC · N MIN READ"), the pregnancy home's shape, which is also how
  Learn and the doors draw a read. Flo's rail of full-photo cards needs a strong picture per read; ours showed empty
  book-icon boxes.
- **"See all" sits in the section heading** (journal, experts), never a full-width row of its own.
- **Journal:** three drawn tiles (Something you noticed · How today felt · For the doctor), each opening that writer,
  and one line "Your partner can read what you write here." "Log for today" (it opened the symptom logger) is gone;
  the Symptoms button at the top does that.
- **Record a positive test** is a white card with a drawn well, title and chevron, not a hairline text row.
- **Hero:** the dates sit in a soft pill ending in a chevron; the ⓘ is gone (it promised an explanation and opened her
  cycle).
- **Insight cards say what they mean:** "Chance of pregnancy today" with a line at every level ("Your best days to
  try", "Your fertile days", "Your fertile days have begun", "Not one of your fertile days"); "Day of your cycle ·
  Counted from day 1 of your period".
- **Sanskar cards show today's thought, question or step,** not what the part is for, so Done has something to
  refer to.
- **Chapter names never stand alone:** `ttcChapterPlainPart` (one plain line per part of the month) and
  `ttcChapterHisTitle` (his hero: "Her fertile days", "The wait before testing") in `lib/ttc/ttc_chapter.dart`. The
  experts page eyebrow names the stage ("Trying to conceive"), not the chapter. His hero drops the 1-to-5 chapter bar
  and the "Next: The Waiting Days" line.
- **You › Your things:** the three tiles are one height (the Journal tile, with no count, drew shorter).

**Reference table: sections TTC now draws best, for pregnancy and parenting to copy when the user says so**

| Section | TTC (reference) | Pregnancy today | Parenting today |
|---|---|---|---|
| Recommended reads | 3 rows, photo or drawn mark, topic · minutes, no chapter card, no "See everything" row | 3 rows (`V3ReadRow`), same shape | a rail of cards (`_ReadRail`), eyebrow "Read" |
| Section "See all" | a link in the heading | full-width "Open your journal" pill | full-width rows |
| Journal on the home | 3 drawn tiles + who-reads-it line, "See all" in the heading | `V3JournalSection` (2 tiles + full-width pill) | — |
| Door out / key action at the foot | white card, drawn well, chevron | — | — |

## Build 11 on the phone, after the tools pass — 2026-09-27, night

Walked: her home, journal (writer + page), experts page, Tools hub, logger, fertile window, calendar, Companion, You,
Learn, supplements, medication, vaccinations, records, BMI, checklist, Should I get help?. Fixed from the walk:
- **B — "how long trying" had two sources.** You showed the onboarding answer ("over a year"); every calculation
  (`TtcStore.daysTrying`: Should I get help?'s prefill, the six-months-at-35 and one-year checks) counted from the day
  she entered the stage, because onboarding V2 saves the answer only to her profile. `journeyStart` now falls back to
  her answer, counted back from the day she entered, at its low end (`ttcStartFromAnswer`,
  `test/ttc_trying_start_test.dart`).
- **C — the insight cards' new captions ran through the corner drawing** (shared tile): a card with a caption no
  longer paints the decorative art, in every stage.
- **C — one name per thing:** the home's journal tile says "A memory" (the writer's word); the Tools tile says "Our
  journal" (the page's); the experts rail uses the roster's titles ("IVF gynaecologist"), as the consults page does;
  "Before your window" is "Before your fertile days", as the Companion's own line says it; the window's "Open now" is
  "Your fertile days have begun", as the home says it; "Symptom companion" and "Mood" (both opened the one logger)
  are one tile, "Symptoms and mood"; tool eyebrows are the tile's name (helper, in progress).
- **C — the journal writer drew a thick outline** round the words (the app's input theme wins over `border:`); it is
  a page again. You's "Your partner partner" lost its repeated tag. The Journal tile under Your things carries a
  count like its neighbours.
- **C — a read with no photo wears its door's drawing** on the home and in Learn alike (was three identical page icons);
  Record a positive test wears the Test button's icon (the capsule read as a medicine).
- **C — Tools tiles opened two kinds of screen** (the tool shell, and plain white pages with a door crumb or a bright
  purple button): supplements, tests, vaccinations, Can I, food ideas, journey map, BMI and the checklist move onto the
  tool shell (helper, in progress).

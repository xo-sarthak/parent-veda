# TTC gap plan — the golden PDF, turned into work (ANALYSIS, nothing executed yet)

Written 2026-09-26. Source of truth, by the user's decision: the TTC gap analysis v2
(`Downloads\competitor-walks\combined-ttc\v2\TTC-Gap-Analysis-v2-Flo-WhatToExpect-vs-ParentVeda.pdf` + `.xlsx`,
generated from `sections_v2.py`, `aspects_v2.py` and `work/*.json` in the same folder). "Whatever that PDF says has to
be done; whatever it says should not be there, tell me and comment it out." All new and changed text follows
`docs/TTC-VOICE.md`, with the free plagiarism check (`plag.py`, 8-word overlap vs the captured Flo + What to Expect
text) run on every batch, and tool notes kept in `docs/TTC-TOOLS-UX-NOTES.md`. Scope: the TTC stage only.

> **RESUME HERE (after a compaction) — state on 2026-09-27**
> - BUILT and green: the whole gap plan (134 reads, 9 doors in the new design with our own hero photos, tabs Today ·
>   Learn · Products · Tools · You, messages + chats, cycle-aware home, one date resolver `ttcDayContext`, the
>   treatment round B1-B10, Mobbin review fixes). Last full suite: 4991 pass + 1 line-ending-fragile test fixed.
> - COMMIT PENDING: list `scratchpad/commit_files_all.txt` (223 files, mtime since the 2026-09-26 snapshot),
>   message `scratchpad/commit-msg-gap.txt`. Scratchpad = `C:\Users\sarth\AppData\Local\Temp\claude\C--Projects-parentveda\c42be61c-fd0d-4b6f-a338-b0287c75211a\scratchpad`. Before giving commands: re-run `eol.py --fix`,
>   refresh the list (find lib test tools docs -newer scratchpad/orig/lib/ttc/ttc_store.dart), full
>   `flutter test --no-pub --concurrency=2` (default concurrency ran the machine out of RAM once).
> - NEXT: **Ask Veda (B11 + TTC content refresh)**. The user granted access to `C:\Projects\parentveda-askveda`
>   and said: understand the repo first so nothing breaks; its content pool needs all the new TTC content. Research
>   and a safe 10-step plan: `scratchpad/research_askveda.md`. Steps 2-4 are code; steps 5-8 WRITE TO THE LIVE
>   SHARED SUPABASE, so ask the user before running them. Ingest costs nothing (local embeddings); only smoke-test
>   answers cost (tiny Groq). The fixed "She is NOT pregnant" framing must become step-aware (result, waiting,
>   test day): flag for Dr Surbhi Sharma.
> - Owed to the user later: phone walk; doctors' fact checks (lists in this log); setup-screen notes (section 9).

**Status:** analysis given 2026-09-26; decisions made; execution done (see RESUME HERE and the log).

---

## 1. What the PDF asks for, in numbers

- 885 competitor pieces judged: 335 to add (235 new, 100 into something we have), 136 we already have, 197 belong
  to another stage, 210 not to add. Plus FAQs, chats, community groups and tools (~31 more adds).
- Those 335 pieces are NOT 335 things to write. Many are the same topic told several ways (Flo alone has five
  pieces on a late period). Clustered by topic they come to **about 60 new reads**, ~25 short daily cards, one
  Indian meal plan and a handful of short answers.
- On our side: 23 sections reviewed, 45 changes, 8 new sections/tabs, 11 "Behind" areas.

## 2. Already done since the PDF was written (warmth pass, 2026-09-26)

- Reads now use "you", contractions, plain words (PDF: Behind — How reads are written, P2 items).
- Made-up reviewer names are gone (PDF: Behind — Trust, P1). NOTE: done differently from the PDF — see decision 1.
- "Reviewed August 2026" removed from evidence lines (PDF: Trust, P1).
- The two-week wait, window length and reminder wording are consistent.
- NOT yet done from that tab: "The short answer" box, question headings (only 3 of 258 headings are questions),
  paragraphs over 50 words (143 of 802 paragraphs, 18%), a Share button.

## 3. The work, in seven streams

### A. New content (the biggest stream; P1 unless marked)
| Where | What to write | Competitor pieces behind it |
|---|---|---|
| Fertile window › **Waiting and testing** (new tab) | The two-week wait, day by day · When to test, and which test · A faint line, explained (with a drawing) · Implantation bleeding or your period? · Late period, negative test · Early signs, and why most are also PMS · Feeling pregnant but no positive test | 36 (16 P1) |
| **Body and cycle** (new door) › Other conditions | Endometriosis and trying · Thyroid and the TSH test · Fibroids that matter · Blocked tubes and the HSG · High prolactin · Genital TB (common in India) · Pelvic infection · "7 things that can delay conception" | 39 (6 P1) |
| Body and cycle › Your cycle | What counts as late · Irregular cycles when it isn't PCOS · Five kinds of bleeding · Spotting · Ovulation pain · Is a "normal" cycle real? | 37 (5 P1) |
| Body and cycle › Intimate health (P2/P3) | Discharge that needs a doctor · Yeast and BV · UTIs · Washing with water, not products | 41 (0 P1) |
| Mind & body › **Hard days** (new tab) | Your period came, what now? · When other people's news is hard · Should you tell family? · When trying takes over your life · Three answers for "koi good news?" | 5 + PDF list |
| Fertile window › **Sex and closeness** (new tab) | When sex feels like homework · Low desire, hers and his · Pain during sex (incl. vaginismus) · Lubricants · Sex after the window · Keeping it close | 21 (2 P1) |
| Getting ready › **Meal plan** (new tab) | 7-day Indian vegetarian plan (eggless and Jain swaps, shopping list) · 10 everyday recipes · Ask a dietitian: 10 questions · Iron before pregnancy · Omega-3 without fish | 8 (1 P1) |
| After a loss › Understand | Chemical pregnancy · Ectopic pregnancy: signs that need a hospital today · Recurrent miscarriage: when to get tested · Trying again: the feelings | 10+ |
| IVF & IUI › **Age and second baby** (P2, new tab) | Trying after 35 · after 40 · How long it usually takes · A second baby · Egg freezing in India. Donor routes and surrogacy only after a legal check (ART Act 2021, Surrogacy Act 2021) | 12 |
| IVF & IUI (P3) | A glossary of clinic words · Ovulation tablets in plain words (letrozole, clomiphene) | 8 |
| His side (P2) | Erection or ejaculation trouble under pressure · age/weight/stress parts · folic acid for men | 15 |
| Can I…? and Myths (P3) | Alcohol before knowing · vaping · peeing or showering after sex | 16 |
| Home daily cards (P1) | Phase set: 5 period-day, 7 waiting-day (one per day), 3 late, 5 window cards | — |

### B. The reader format (P1, every read, old and new)
- A boxed **"The short answer"** (2–3 sentences) under every title. Needs one new optional field on `PvRead` and the
  reader drawing it; then written for all 52 existing reads.
- Headings as her questions; no paragraph over 50 words; a heading every 2–3 paragraphs.
- A **Share** button (title, one-line summary, app link; WhatsApp first). P2.

### C. The home and the daily experience
- P1: late → "Time to test" + "How to take a test"; period day 1 → a kind line.
- P1: daily cards and the 4 recommended reads chosen by her **cycle phase**, not the date.
- P2: one-tap "Sex" and "Test" next to "Check symptoms"; doors ordered by her situation; the 12-month (6 if 35+ or
  irregular) "it may be time for a check" card.
- P2: a new **"Trying, but not pregnant yet?"** door that gathers existing pieces; first on the home after 6 months.
- P3: calendar "Period expected" and "if this cycle works, your due date would be around…"; one live community
  thread near the bottom.

### D. The app speaks first (P1)
- Five messages: window opens (onboarding already promises this and nothing sends it), period logged, late by a
  day, end of cycle, trying 6+ months. Each can be switched off. No emoji.
- Three scripted chats, no AI, rules only: "Should I test?" (first), "My period came", "My cycle report".
- Cycle report: "your report is ready", a one-line summary, one next step (keeping our no-verdict rule).

### E. Community
- P1: typed member counts hidden until real; the poll made votable; one pinned warm thread per room.
- P2: rooms "The two-week wait" (auto-joined on natural cycles) and "Trying over 35"; IVF and IUI merged.
- P3: "In the <room> room" at the end of each door, labelled "Experiences from members — not medical advice".
- Seeding with real questions needs a human moderator; code can only make the counts honest.

### F. Logging, partner, settings
- P2: four feelings (Hopeful, Guilty, Can't stop thinking about it, Hard on myself) with a gentle link after three
  days; "Log this for today" at the end of symptom and test reads; "What a faint line means" under the test log.
- P3: a whole-cycle temperature chart; Kegels and Breathing in "the rest of the day".
- P1: the partner pairing screen promise about the journal made true. P2: a picture of his day; P3: a nightly
  "Tonight, ask her" question.
- P2: "Hide sex and intimacy content" switch (needed before the Sex and closeness tab ships). P3: age band, asked
  once, used for the 35+ timing.

### G. Learning shapes
- P1: "Trying to conceive 101", a free 7-step course built from reads we already have.
- P1: six short videos (fertile window, when to test, stress, his side, PCOS, when to see someone). Filming is not
  code: I can write the scripts and captions. Until they exist, the 16 empty video tiles should not show (see
  decision 2).

## 4. What the PDF says should NOT be there (declutter candidates)
1. "Loved by 50,000+ parents" on the first screen (a made-up number). Lives in the shared onboarding, not TTC.
2. The 16 video tiles that never play.
3. Ask Veda's "Videos for this are coming soon" / "Community insights are coming soon" / "More reading… coming soon".
4. Typed community member counts (1,284, 8,640…).
5. The poll that cannot be voted on (fix it or take it out).
6. "How long have you been trying?" asked twice (onboarding and the TTC intro).

The PDF's 210 "don't add" verdicts are about competitor pieces (contraception, teen and general period content,
choosing a baby's sex, US-only facts), so they remove nothing from our app. From our own tool notes (not the PDF),
further declutter candidates: two PCOS tools covering the same ground, two near-identical "should I get help?"
tools, and made-up product scores and badges.

## 5. Proposed order of execution
1. **Fixes and declutter** (small, quick): the six items above that sit in TTC, the journal promise.
2. **Reader format**: the short-answer field and box, question headings and paragraph splits on all 52 reads,
   Share.
3. **P1 content**: Waiting and testing → Hard days → Body and cycle (Other conditions first, then Your cycle) →
   Sex and closeness (with the hide switch) → Meal plan → the four loss reads → the phase daily cards.
4. **The home and messages**: phase-aware home, the five messages, "Should I test?", report-ready, 12-month card,
   Sex/Test buttons, TTC 101, the "Trying, but not pregnant yet?" door.
5. **P2/P3**: Age and second baby, glossary and tablets, His side additions, Can I and myths, Intimate health,
   logging feelings and chart, partner additions, calendar lines, community rooms and pins, age band.
6. **Decisions that change the frame**: navigation (tabs), videos.

Each batch: `docs/TTC-VOICE.md`, the plagiarism check, `flutter analyze` + full tests, tool notes updated, the
expert sign-off list regenerated (`tools/ttc_expert_signoff.py`), commit commands for only these files. Helpers
writing new reads get the PDF's topic and our own summary of each competitor piece, never the competitor's text.

## 6. Decisions needed from the user
1. **Trust.** The PDF's most urgent item says: until a doctor has really reviewed a read, show "BY ParentVeda
   team" with no tick. On 2026-09-26 the user chose real roster names. Recommended: keep the real names but show
   "BY" without the tick until each expert signs off (the PDF's intent, with the user's names). ~60 new reads will
   raise the same question.
2. **Hiding empty things vs "a feature is never hidden"** (CLAUDE.md). The PDF says hide empty video tiles and
   "coming soon" sections. Recommended: comment them out with a kept-for-revert note (the user's own instruction),
   and record the exception.
3. **Onboarding.** "Loved by 50,000+", "Where are you with this?", the check-up and "is he getting ready"
   questions live in the shared onboarding (another terminal's Onboarding V2), outside TTC. Recommended: do only
   the TTC intro parts (ask once; "Where are you with this?") and leave the shared screen to its owner.
4. **Navigation.** Option A (Today · Learn · Community · Tools · You; Products and Talk to expert move into Tools
   and the home) or B (keep the tabs, add Read and Community rows high on the home). Recommended: B first, because
   A changes the frame for every stage.
5. **Videos.** Scripts and captions now, filming later?
6. **Donor routes and surrogacy.** Defer until a legal check, as the PDF says?

## 7. The user's answers (2026-09-26)
1. **Community: held back, not released initially → hide it** in TTC (comment out every entry point, kept for
   revert). The PDF's community items become notes for later, not work now.
2. **Doctor names: as the PDF says** → every TTC read and story back to "BY ParentVeda team", `reviewed: false`, no
   tick; the roster names stay only in `docs/TTC-EXPERT-SIGNOFF.md` as the planned reviewers.
3. **Video tiles stay** (videos will be uploaded; the tiles mark where). Treat them as real videos: change titles,
   placement or which slots exist where the PDF says. No scripts needed. Everything else "coming soon" gets BUILT
   where the PDF says how.
4. **Setup screens: note the PDF's feedback, do not execute** (handled separately by the user).
5. **Bottom tabs: as the PDF says** (option A), without Community since it is held back.
6. **Donor routes and surrogacy: write them**, factual only. Anything beyond facts, tell the user later.
7. **Door design:** where the final output is a door, use the NEW door design language already applied on the
   pregnancy side (Scans and tests, Complications). Refer to it; never change the pregnancy side.

## 8. Final answers and GO (2026-09-26, later) — EXECUTION STARTED
- The PDF is the source of truth for the app. Use the Mobbin MCP for every design question (plus what Flo and What
  to Expect do).
- **New doctors onboarded:** Dr Neha (lactation consultant, prenatal and postnatal coach) and **Dr Surbhi Sharma
  (IVF gynaecologist, Bloom IVF)**. Roster = the Excel "Expert roster" + these two.
- **Tabs:** Today · Learn · Products · Tools · You (Products takes Community's slot; everything that was under More
  moves into You). While on the tabs, ELEVATE each tab screen's UI/UX (Mobbin + Flo/WTE references).
- **Doors:** all 9 (7 existing + Body and cycle + Trying, but not pregnant yet?) in the NEW door design language
  (pregnancy: Scans and tests, Complications). Pregnancy side is reference only.
- **Doctor names:** real names WITH the verified tick where a roster doctor suits the article; "ParentVeda team"
  where none does. (Overrides answer 2 in section 7.)
- Continuous job, no stopping; efficiency not compromised; ask for anything needed.

### Execution log
- 2026-09-26 — started. Phase 1 foundations + research agents (door design, Mobbin tab references).
- 2026-09-26 — Research done (scratchpad: research_doors.md = mirror the pregnancy door engine as TtcDoorScreen, reuse
  neutral widgets; research_tabs.md = nav/More/Learn/You/community map; research_mobbin_tabs.md = Mobbin briefs for
  Learn/Products/Tools/You; Flo tabs Today·Insights·Secret Chats·Messages·Partner; WTE not in Mobbin).
- Built by lead: `PvRead.shortAnswer` (optional) + "THE SHORT ANSWER" box in `pv_reader_screen.dart` (before the
  lede; other stages unaffected). Community hidden: Ask Veda Community insights commented; after-loss bracket extras →
  notApplicable (bracket_model_test updated, restore note); after-loss hub support need commented; loss video
  surfaceNext commented. Ask Veda "More information" now BUILT (`ttcReadsMatching` in ttc_reads_data.dart, local word
  match over TTC reads); Products/Services "coming soon" → link cards (shelf; consults). Videos "coming soon" kept
  (user: video placeholders stay).
- Helpers running: content W1 waiting · W2 body conditions · W3 body cycle · W4 intimate · W5 hard days · W6 sex ·
  W7 meal plan · W8 loss more · W9 age/second baby/donor/surrogacy/glossary/tablets · W10 extras (new files
  lib/ttc/reads/ttc_reads_<slug>.dart; brief scratchpad/AGENT-BRIEF-CONTENT.md; topic packs scratchpad/topics/);
  existing reads X1 conceiving+ready · X2 pcos+ivf (IVF → Dr Surbhi Sharma) · X3 his side+loss+mind (brief
  AGENT-BRIEF-EXISTING.md); DE door engine (TtcDoorScreen, lib/screens/ttc/doors/, 7 doors' data, community tiles
  hidden); T tabs (Today·Learn·Products·Tools·You, TtcLearnScreen, You with TTC bar, Tools expert tile, More retired).
- NEXT after helpers: wire new read files into ttc_reads_data.dart; door data pass for the new tabs + 2 new doors
  (Body and cycle 172; Trying, but not pregnant yet?); heading → atHeading fixes; then stream C (home), D (messages +
  scripted chats), F (logging, partner, settings), phase daily cards, TTC 101 course; setup-screen feedback as NOTES
  only; tool notes + sign-off list kept current; full tests; commit commands.

## 9. Setup screens: the PDF's feedback, NOTED ONLY (the user handles these separately)
Source: gap analysis "Section by section › First-time setup" and "Behind — Onboarding". Nothing here is executed.
1. **Remove "Loved by 50,000+ parents"** (P1). A made-up number on the first screen. Lives in
   `lib/screens/auth/onboarding/onboarding_flow.dart:442` and `lib/localization/app_language.dart:3899`
   (`uiLovedByParents`). PDF's replacement line: "For the whole journey: trying, expecting, raising." (reword to
   avoid "journey" per TTC-VOICE).
2. **Stop asking "How long have you been trying?" twice** (P2): onboarding asks it, then the TTC intro
   (`lib/screens/ttc/ttc_intro_flow.dart`) asks again with different options. Keep the onboarding one and its kind
   replies; skip it in the TTC intro when answered; save it in the one place the fertility-help tool and home read.
3. **Add "Where are you with this?"** (P2): Trying now / Planning to start soon / Just learning for now. Reply for
   planning: "Good time to be here. The three months before trying matter most. We'll start there." Use it to put
   Getting ready first on the home.
4. **Add two questions** (P3): "Have you had a check-up for trying?" (Not yet → "Worth booking. It's one visit, and
   it catches the few things that matter before, not after." → opens the checklist first) and "Is he doing anything
   to get ready?" (I didn't know he needed to → His side higher on the home).
5. **An expert screen after the privacy screen** (P2, once reviewers are real): their photos and "The people who
   check what you read. Every piece in the trying section is checked by a practising Indian doctor before you see
   it." Now possible for the named experts once they sign off (`docs/TTC-EXPERT-SIGNOFF.md`).
- 2026-09-26 — W5 hard days DONE (lib/ttc/reads/ttc_reads_hard_days.dart, 6 reads, all OK, plag 0; Parmeshwari). OWED from it: a relationship-safety read for Mind & body › Talk (abuse, dangerous relationship; pack items P2) — not a hard-days read; stress-delays-period + communication passed to X3. Note: ttc_read_period_came has a clinical fold (chemical/ectopic signs) under a psychologist byline → consider Dr Ruchika Sood co-review in sign-off.
- 2026-09-26 — W7 meal plan DONE (ttc_reads_meal_plan.dart, 5 reads, Akanksha Srivastava; plag 0). Vitamin A line + links passed to X1.
- 2026-09-26 — W4 intimate DONE (ttc_reads_body_intimate.dart, 6 reads incl. STI testing; Dr Ruchika Sood; plag 0; every pack item placed). Confirm later: Suraksha Clinics/ICTC naming, lab prices.
- 2026-09-26 — W6 sex DONE (ttc_reads_sex.dart, 6 reads; Parmeshwari / Dr Vaishnavi / Dr Ruchika Sood; plag 0; all 20 pack items). OWED before the tab ships: 'Hide sex and intimacy content' switch (You › preferences) gating the Sex and closeness tab + related cards.
- 2026-09-26 — W8 loss DONE (ttc_reads_loss_more.dart, 5 reads: chemical, ectopic, miscarriage causes, recurrent, feelings; plag 0). Management section passed to X3.
- 2026-09-26 — W3 cycle DONE (ttc_reads_body_cycle.dart, 8 reads; Dr Ruchika Sood; plag 0). Clinical glance owed: ibuprofen-around-ovulation tip wording.
- 2026-09-26 — W10 extras DONE (ttc_reads_extra.dart, 6 reads: his pressure, his age, ovulation tests irregular, after abortion, money before baby, first gyn visit; plag 0). 'How long it takes' = W9's read, wire into Fertile window › How to try too. ADD-TO-EXISTING checklist → scratchpad/add_to_existing.md, sent to X1/X2/X3. PCOS hair carousel iron + vitamin D note → door data pass.
- 2026-09-26 — W2 conditions DONE (ttc_reads_body_conditions.dart, 9 reads incl. ovarian cysts; Surbhi Sharma: endometriosis, fibroids/polyps, tubes/HSG; Ruchika Sood: thyroid, prolactin, TB, PID, overview, cysts; plag 0). Fixed: 'ttc_tracker' nextSteps → 'ttc_symptom_log' (router deliberately has no ttc_tracker); brief corrected. CHECK ALL new files for ttc_tracker at wiring.
- 2026-09-26 — W1 waiting DONE (ttc_reads_waiting.dart, 8 reads; Dr Ruchika Sood; plag 0). Faint-line drawing = design owed. Ids sent to D and F.
- 2026-09-26 — W9 age DONE (ttc_reads_age.dart, 10 reads incl. follicle scans; Dr Surbhi Sharma; plag 0). ALL 10 content helpers DONE. Aggregator wired: waiting, hard_days, meal_plan, body_intimate, sex, loss_more, body_cycle, body_conditions, extra, age. pv_read_shape_test + ttc_clinical_review_test GREEN on all reads. IVF additions (twins, lesser-known treatments, reasons it takes longer, first-visit checklist, gentle pelvic exam) passed to X2. Facts to confirm listed per helper report (ART/Surrogacy Act details, egg freezing costs, letrozole status, NICE age table).
- 2026-09-26 — X2 PCOS+IVF DONE (22 reads: shortAnswer, questions, 63 paragraphs split, IVF → Dr Surbhi Sharma; all ADD TO OURS placed; plag 0). Minor owed: ttc_fertility_help_rules.dart review-pack 'article:' strings cite old headings ("Reasons not to wait at all" → "When shouldn't you wait at all?", "The usual guideline" → "How long should you try first?"); PCOS hair carousel iron/vitamin D card → door pass; link pcos_meds from IVF door.
- 2026-09-26 — X3 his side+loss+mind DONE (18 reads; all ADD TO OURS placed; community nextSteps commented; plag 0). 4 atHeading anchors sent to DE (after_loss 162/231, mind_body 185/241).
- 2026-09-26 — X1 conceiving+getting ready DONE (12 reads; all ADD TO OURS + myths placed; plag 0). 5 more atHeading anchors (mind_body 342/365/371/389/395) sent to DE. ALL CONTENT HELPERS DONE: 121 TTC reads, every one with shortAnswer, question headings, ≤50-word paragraphs.
- 2026-09-26 — F logging+partner DONE: 4 trying feelings (hopeful, guilty, cant_stop_thinking, hard_on_myself) + gentle 3-day line → ttc_read_trying_takes_over; 'What a faint line means' link; Kegels + Breathing; whole-cycle temperature chart (old sparkline commented); 30 'Tonight, ask her' questions + card on his view; TtcPartnerDayExample. Lead applied pv_partner_screen.dart: TTC can-see adds shared journal, never-sees 'Your private journal', em dash removed, day example placed; unskipped the promise test (green). Emoji removed from pairingShareText.
- 2026-09-26 — D messages + chats DONE: TtcMessagesStore (computed, not queued; 5 messages: window opens, period
  came, late, cycle report, trying a while; per-kind switches + phone on/off; notification ids 918101-918105),
  lib/ttc/ttc_period_due.dart, TtcMessagesScreen, chats in lib/screens/ttc/chats/ (should test, period came, cycle
  report) + surfaces ttc_messages, ttc_chat/*, ttc_cycle_report, ttc_door/<id>; main.dart init after ReminderStore.
  Lead FIXED an existing bug D found: IVF trigger reminders were wiped by cancelAll on every launch →
  TtcTreatmentStore.rearmAfterStartup() chained in main.dart. OWED: entry points (home envelope + unread dot, "Should
  I test?" on waiting card, You row "Messages", period logged → period_came chat, cycle report "Walk me through it",
  symptom log test row, doors); notification tap → open destination (NotificationService has no tap handler);
  BACKEND-PATTERNS section "computed, not queued". Setup note (user's): onboarding reminders choice →
  TtcMessagesStore.setPhoneOn(_reminders) (§9).
- 2026-09-26 — T tabs DONE: Today · Learn · Products · Tools · You. TtcLearnScreen (search, browse by topic, your reading, start here, films as upcoming, shelves per door, myths, courses, common questions); Products shop-by-need (TTC only); Tools +Talk to an expert (25), find field, recent strip, list rows (grid commented); You tab via PvYouScreen.bottomNav (TTC only), More items → You rows; More retired. Lead added 'ttc_learn' surface + label. OWED: docs/BOTTOM-NAV-MAP.html + tools/nav_map.py refresh; STILL-OPEN entry.
- 2026-09-26 — DE doors DONE: TtcDoorScreen (lib/screens/ttc/doors/: screen, rail, search) + TtcSearchStore; openTtcDoor wired in home/_openBracket, semen report, door tile (old pushes commented); model additive (TtcTile meta/keywords, TtcFocusGroup mark/inlineLabel/inlineSurfaceId, TtcFocusPage heroTitle); 7 doors: heroTitle + marks, community tiles commented, IVF reviewedBy Surbhi; all atHeading anchors resolve; test/ttc_door_screen_test.dart 26 green. Lead fixed ttc_read_his_side_pressure folded section (his side never folds). HOW TO ADD a door/tab: see report (focus file + kTtcFocusPages entry + bracket; counts in ttc_mind_body_test/bracket_model_test/door test).
- 2026-09-26 — Lead: lib/ttc/ttc_content_prefs.dart (TtcContentPrefs.hideIntimate, key ttc_hide_intimate; kTtcIntimateGroupId 'sex'; kTtcIntimateReadIds) + init in main.dart. DD (door data pass) launched: new tabs waiting/sex/hard/meals/age + loss/his side/getting ready placements + PCOS hair card + NEW doors ttc_body_cycle (172) and ttc_not_yet; switch gating in door screen + search. NEXT: C (home + entry points + You toggle for hideIntimate + Learn gating) after P (phase cards) finishes.
- 2026-09-26 — Lead: BACKEND-PATTERNS §16m 'A message is computed, not queued' (+ the cancel-all startup trap); fertility_help_rules review-pack article strings → new question headings; W11 safety read launched (relationship safety, Mind & body › Talk). C (home + entry points + You switch + Learn gating + TTC 101) launched. P phase cards done (19 tests green; TtcDayPhase in lib/ttc/ttc_phase.dart; ttcInsightsForPhase; ttcReadIdsForPhase).
- 2026-09-26 — Lead: tools/nav_map.py TTC V3 tabs updated (Learn · Products · Tools · You; old entries noted for revert) and docs/BOTTOM-NAV-MAP.html regenerated.
- 2026-09-26 — W11 safety DONE (ttc_read_relationship_safety, Parmeshwari; plag 0) and wired. Check: NFHS-5 ~29 per cent figure; 1091 varies by state. Door placement (Mind & body › Talk) sent to DD.
- 2026-09-26 — DD door data DONE: tabs Waiting and testing + Sex and closeness (Fertile window; 'Your window' + 'How to try' merged into 'When and how', id trying), Hard days (Mind & body), Meal plan (Getting ready), Age and second baby (IVF & IUI) + loss/his side/getting ready placements + PCOS hair card + safety read in Talk; NEW doors ttc_body_cycle (Body and cycle, 172) and ttc_not_yet (tile 'Taking a while', 250); ttcDoorVisiblePage filter for hideIntimate (+ search); tests updated (9 doors, 63 cells); full suite 4703 green at its end. Lead: ttc_door/<id> surface now opens TtcDoorScreen (old import commented). Hero photos for 2 new doors owed (DOOR-CONTENT-OWED).
- 2026-09-26 — P phase cards reported: TtcDayPhase + ttcDayPhaseForCycleDay (lib/ttc/ttc_phase.dart), ttcPhaseInsights (20 new cards) + ttcAllInsights, ttcInsightsForPhase, kTtcPhaseReadIds + ttcReadIdsForPhase (lib/ttc/ttc_phase_reads.dart); card→read pairing sent to C.
- 2026-09-26 — C home DONE: lib/ttc/ttc_home_situation.dart (late advice, period day 1, phase picks, sex toggle, door order, check-card months, due date), lib/ttc/ttc_home_prefs.dart (check dismiss, 101 progress, kTtc101ReadIds), lib/screens/ttc/ttc_home_gap.dart; home: envelope + unread, Time to test, period-day-1 line, Sex/Test one-tap, phase cards + reads, See everything → Learn, Should I test? rail card, check card, New here? 101 card, doors ordered by situation; entry points in symptom log, cycle report, cycle companion, V1 today; calendar lines; Learn gated + Start here = TTC 101; You rows Messages + What you see (switch sheet). Late logic shared with messages. Sex button stays under the switch (PDF: timing information stays). OWED P3: age band asked from the 'Trying after 35' read + age tab higher for 35+ in IVF & IUI (age band exists only in the fertility-help tool).
- 2026-09-26 — FINAL: eol restored (16 files); flutter analyze lib: no errors/warnings in touched files; FULL SUITE 4755 passed, 5 skipped, 0 failed; plag 0 on all reads + doors. Commit list scratchpad/commit_files_all.txt (183 files, mtime since the snapshot), message scratchpad/commit-msg-gap.txt. Not walked on a device (user: phone check not possible now).
- 2026-09-26 — User: TTC must be personalised by her cycle date and CONSISTENT (hero + today's insights by date; age the same everywhere; doors the same, only order shifts per PDF — offered a fixed order if preferred). Launched AF (age asked from ttc_read_age_after_35 + age tab second for 35+ in IVF door; faint-line drawing in code) and K (consistency pass: one resolver for cycle day/phase/window/due/late/ownership/age; scenario-matrix test test/ttc_date_consistency_test.dart). Hero image prompt (9 doors, one block) given to the user; they will supply images → resize, upload to R2 parentveda-images, wire heroImageUrl. Competitor coverage checked: Flo library complete (805); Flo home seen in states before window (10d, 3d), window, period day 1, late 8-9d; NOT seen: waiting days (offer a 15-min top-up at the phone walk).
- 2026-09-26 — AF DONE: age asked once at the top of ttc_read_age_after_35 (PvReadSection.custom → TtcAgeBandAsk; saves via TtcFertilityHelpStore.setAgeBand, same key ttc_fhelp_answers); IVF door puts 'age' tab second for 35+ (ttcDoorOrderedGroups, refersAtPresentation); faint-line drawing (TtcFaintLineDrawing) in ttc_read_faint_line; new lib/ttc/ttc_read_blocks.dart + lib/screens/ttc/ttc_read_blocks_view.dart; both TTC reader openers pass customBlock. 16 new tests green.
- 2026-09-26 — K consistency DONE: lib/ttc/ttc_day_context.dart (ttcDayContext) routes every date surface; 11 disagreements fixed; test/ttc_date_consistency_test.dart (29); full suite 4800 green. USER DECISIONS: (1) clinic mode ONLY when real clinic dates exist in the treatment tracker; label-only = own cycle everywhere; once treating, show only relevant things (no fertile days); design an easy IVF/IUI flow + future partner-clinic dates; (2) first cycle like Flo/WTE: predict from first period with stated length else 28, 'rough guess'; plus lead choices: irregular = spread >7 days everywhere (FIGO), earlier cycles show their own-length fertile days (competitors do). Launched K2 (resolver rules) and TF (design doc docs/TTC-TREATMENT-FLOW.md, no code) — build of the flow after the user reads TF.
- 2026-09-26 — K2 DONE: ownership = real clinic dates (TtcStore.ownership → ttcTimingOwnershipFromEvidence), first cycle stated length else 28 (statedCycleLength local only), kTtcIrregularSpreadDays = 7 everywhere, earlier cycles look-back windows; suite 4831 green except 1 fixed test. TF design DONE: docs/TTC-TREATMENT-FLOW.md; user decisions recorded in its §7 (mode on first treatment date; never close quietly, visible check-in at 7 days, ask on return after 30+ days; fertile days back after next period). Launched TB (B1-B4: round model, switch, start/plan/result/check-in screens, home) and W12 (12 treatment reads, ttc_reads_treatment.dart). NEXT: B5-B8 + B10 (calendar, messages, IVF door, pregnancy dating by transfer, his side); B11 Ask Veda needs parentveda-askveda access (ask user).
- 2026-09-26 — User: use Mobbin for every design/structure decision and for new things; run all new doors + new things against Mobbin for consistency. Launched MR (read-only review → scratchpad/mobbin_review.md). Apply its fixes AFTER TB finishes (shared screens), then B5-B8/B10, W12 wiring, full tests, commit.
- 2026-09-26 — W12 treatment reads DONE (12 ttc_read_tx_*, Dr Surbhi Sharma; plag 0) and wired (134 reads). 15 facts for Dr Surbhi Sharma listed in the W12 report (IUI timing, FET timing, progesterone duration, ART Act limits, citations).
- 2026-09-26 — User suggestion (at the end, only if needed): use Mobbin freely to ELEVATE TTC doors/new things beyond the pregnancy patterns, keeping the door skeleton and structural consistency; sent to MR as an 'Elevations' section.
- 2026-09-26 — MR review DONE (scratchpad/mobbin_review.md: 13 P1, ~35 P2, ~22 P3, 12 optional elevations, 23 Mobbin links). Top: door disclaimer wording, flag as one dot beside a paragraph, Learn/Tools boxed rows + Material glyphs (use drawn marks; shared unboxed row), Tools old header, Messages row count vs dot, messages empty state, chat answer tray, home triple 'Should I test?' + Sex button vs hide switch + snackbar, short-answer box is a banned tinted box (+ Hinglish eyebrow). APPLY after TB finishes.
- 2026-09-26 — TB B1-B4 DONE (round model in ttc_treatment blob, ttcTreatmentPhase S0-S11, switch from first treatment date, check-ins never auto-close, announcements + 7-day undo, start/plan/result screens, 10 hero states, 18 treatment cards; suite 4925 green). Sex/Test row hidden only on IVF-shaped rounds (kept). Launched TB2 (B5 calendar, B6 treatment messages, B7 IVF door panels, B8 pregnancy dated by transfer, B10 his side, G-read mapping, door + Messages review fixes) and RF (review fixes: Learn, Tools, You, chats, home, short answer, temperature chart, partner preview, shop-by-need + elevations). Owed: BACKEND-PATTERNS entry (round state in the blob; one-time flags local), STILL-OPEN note, B11 Ask Veda (needs parentveda-askveda access).
- 2026-09-26 — RF review fixes DONE: shared unboxed row lib/screens/doors/pv_list_row.dart (Learn, Tools, shop-by-need); Learn drawn marks + topics for all 9 doors + one matcher; Tools V3 header + PvLiveSearch + library hits; You dot not number, names from ttcToolById; chats bottom answer tray + disclaimer + house date sheet (FAB hidden on ttc_chat/*); home one 'Should I test?' on late days, switch hides Sex chip, 44pt targets, Sex log Undo; short answer between hairlines (no tinted box; Hinglish eyebrow removed); temperature chart tap-to-read + today line; partner preview white card. 30 new tests green. Behaviour notes: Tools Fertility window → ttc_window; sentence-case tool names; films not tappable in Learn. Found (shared, not fixed): 360dp overflows in You journey row, store honesty strip, hero band. Lead decisions: keep the unread dot (record exception), 9-door grid as is, You boxed list as is (shared).
- 2026-09-27 — Final suite (concurrency 2): 4991 pass + 1 line-ending-fragile source test fixed (now 79/79 in its file). Hero images: 9 JPGs 1200px (~100-160 KB) uploaded to R2 (tools/read_images/upload_to_r2.py), wired into all 9 focus files (old Unsplash URLs commented); door tests green. Ask Veda repo access granted by the user: Explore helper mapping C:\Projects\parentveda-askveda first (user: understand it before changing; its content pool needs all the new TTC content).
- 2026-09-27 — His side hero regenerated by the user (plain shoes, no marks), uploaded as ttc_door_his_side_v2.jpg (new name: the old URL is cached a year) and wired. All 9 door heroes DONE.
- 2026-09-27 — Ask Veda research DONE → scratchpad/research_askveda.md (plan + risks). Ledger RESUME HERE written at the top. User: context at 89%, compaction next.
- 2026-09-27 — Ask Veda B11 + pool CODE DONE (both repos). Service (C:\Projects\parentveda-askveda): AskRequest.treatment_step -> answer() -> describe_ttc_stage step-aware opener/closer (not pregnant / does not know yet / positive test; unknown step fails safe to not pregnant), cache key ttc:<chapter>:<path>:<ownership>:<step|->; pytest 130 pass (+6). App: ask_veda_service sends treatment_step; ttc_askveda_screen sends ttcHomeRoundPhaseOn(now)?.name (never partner), deep links ttcread_/ttcdoor_, insight lookup over every card set, hide-intimacy filter on cards; ttcTileSlug/ttcTileBySlug in ttc_focus_data; export adds 134 ttcread + phase/treatment ttcinsight + 33 ttcdoor, twin only when Hi != En, dup ids fail (530 docs, was 324); test/ttc_askveda_pool_test.dart; STILL-OPEN §79.12, BACKEND-PATTERNS §16p, CONTENT-BACKEND log. NEXT: user go-ahead for the live Supabase refresh (delete trying rows+chunks, import, embed, clear ttc:% cache, smoke test); Dr Surbhi to review the step framing.
- 2026-09-27 — LIVE Ask Veda TTC pool refreshed with the user's go-ahead (530 rows, 1834 chunks, ttc:% cache cleared). Embedding cache repaired (HF blocked; tokenizer from Qdrant GCS tarball, verified cosine 1.0). Smoke test found Groq RETIRED llama-3.1-8b-instant (all Ask Veda answers fail; STILL-OPEN 79.12a, model decision owed); with openai/gpt-oss-20b (process override only) answers are grounded and cite new ttcread_ cards; transfer-cramps question NO_ANSWER from retrieval rank (79.12b). Full app suite 5001 pass. Phone build (release, PV_DEV, build 3) started; user approved the install.

# Remaining changes, smallest code work first

Written 2026-10-14, after the small-fixes commit `c1204b0`. Skilling is out of scope.
Items marked **(held)** wait on your word. Sizes are rough: S = under an hour, M = a few hours,
L = a day or more.

## Small

1. **Phases: DONE 2026-10-14 (was items 1 and 2).** The Drive "My Child phase-wise content" docs are
   the only phase text. The old Wonder Weeks leaps are unwired: the Development door tab is "Phases"
   and opens the phase map, and the leaps read and its links are commented out. Phases 1–15 show only
   their doc; phases 16–20 show their name, age and "This phase's guide is being written" until
   PH016–PH020 arrive. STILL-OPEN §85.
   The two leap films are retired too; new phase films to come from you. The leap article
   "Phase 4, decoded" is retired as well. Phases 16–20 keep their "When to call the doctor" lines
   until their docs land (confirmed by you).
3. **Yoga ₹599 (S, held).** `prenatal_yoga_screen.dart:111` and `pp_yoga_data.dart:477` hard-code the
   price. Kept for now; it moves to the server price when the backend holds one (STILL-OPEN §83.6).
4. **Parenting yoga "Live group" with no schedule (S, decide).** STILL-OPEN §83.7: show a schedule,
   or say how a time is chosen.
5. **Expert sign-off (held, not code).** No TTC page shows "Reviewed by" today, because the sign-off
   gate in `lib/ttc/ttc_expert_signoff.dart` is empty, so every piece says "By ParentVeda team". The
   doctors' names are still in the data and come back, with the tick, one piece at a time as
   sign-offs return. STILL-OPEN §78.1 is updated to say so (gated, not closed).
5a. **Superfood recipe photos (S).** 8 new recipes have no chosen photo (STILL-OPEN §83.8).
5b. **Parenting Ask Veda colours (S, decide).** It was moved to pregnancy's white and ink, beyond the
   brief (STILL-OPEN §83.11). Keep or revert.

## Medium

6. **Tap feedback, second pass: DONE 2026-10-15 (`9223ce4`).** 1,338 taps now settle when pressed,
   across all stages; a test fails on any new tap without it. 75 left alone on purpose (backdrops,
   drags, keyboard dismiss, conditional taps). All 7,846 tests pass. Optional later: the 40
   conditional taps by hand. STILL-OPEN §83.10.
7. **Add to calendar (M).** Scans and appointments into the phone's calendar.
8. **Baby vault: DONE 2026-10-15 (with item 12).** Read aloud on every letter, "open your letters" at
   birth, and the letters book PDF, sealed until birth. Waits on a device check. STILL-OPEN §83.2.
9. **Door consistency pass (M).** One layout and set of controls across every door (STILL-OPEN §83.14).
10. **Flash cards for heavy tools (M).** A short card deck in front of tools that are a lot to take in.

## Large

11. **Recipes screen: PILOT BUILT 2026-10-15, waits on your look.**
    - The Mobbin study is MOBBIN-DISCOVERY §21.
    - The new recipe page and the new photo card are on ONE dish: Mixed dal khichdi (7–8 months),
      from Drive "Recipes (not reviewed)". To see it: Feeding door → Recipes by age → the khichdi
      card. It leads the First Foods, Lunch and Dinner rails.
    - Every other dish keeps the old page and card, side by side with it, until you say yes.
    - The photo is in (`assets/recipes/pp_7_8m_mixed_dal_khichdi.webp`, made in ChatGPT from the prompt below).
    - After a yes:
      - the other 27 of the band;
      - the page and card on all dishes;
      - a photo prompt per dish.
    - STILL-OPEN §83.14a.
12. **Keepsake PDF: DONE 2026-10-15, folded into item 8.** It was the Baby vault's book: the letters
    as a PDF, unlocked at birth.
13. **Condition reads (L, content).** The condition pages owed their reads.
14. **Investment explainers (L, content).** The money explainers for parents.
15. **Ask Veda pregnancy review (L, two repos).** Walk the pregnancy answers. Fixes to the answers live
    in `C:\Projects\parentveda-askveda`, so this needs that repo open.
16. **All phases screen: REDESIGN BUILT 2026-10-15, waits on your look and the paintings.**
    - Mobbin pass first (MOBBIN-DISCOVERY §24): Noom course map, Alan journey,
      Duolingo sections, Moonly chapters, Flo. Declined: locks, coins and streaks, a dark theme.
    - `phase_map_screen.dart` now opens on the child's own phase (a painting card with "Open this
      phase"), then five chapters (Newborn, Baby, Young toddler, Toddler, Little kid) with a chip row
      that jumps to each, and every phase as a round painting on a dashed rail. Past phases get a ✓,
      the current one is bigger and ringed. Nothing is locked. From 600 px wide it becomes a 2-column
      grid of tiles. The old screen is kept commented out for revert.
    - To see it: Parenting home → the phase hero → all phases.
    - Paintings: 20 prompts in `docs/PHASE-PAINTING-PROMPTS.md` (house style of the onboarding
      paintings). Until a painting is dropped in as `assets/phases/phase_NN.webp`, that phase shows
      its number in its own colour. No code change needed per painting.
    - Test: `test/phase_map_screen_test.dart` (9 tests) plus 261 related parenting tests pass.
17. **Phases 16–20 into the app (S once the files are local).** The five docs are in Drive. The
    converter (`tools/phase_pages/docx_to_dart.py`) is already widened for their titles and asides,
    and rerunning it left phases 1–15 unchanged. Waits on the five .docx files being downloaded into
    the local "My Child phase-wise content" folder. Then: convert, the dropped-lines audit, the age
    and cross-link checks, the "1–15" comments and tests to "1–20", STILL-OPEN §85.

## Drive content: what is missing, where the app differs, and issues in the docs

**Kept current after every Drive drop** (the user, 2026-10-14). The Drive docs are the source of
truth, so every gap is listed here in one place: what the doc does not give, where the app shows
something other than the doc and why, and what is wrong inside a doc. Fix the doc, tell me, and I
pull it in. Detail and history stay in the STILL-OPEN section named on each block.

### Recipes (not reviewed) — STILL-OPEN §83.14a
- **In the folder:** one recipe doc, "7-8 month band (PROMPT4) FINAL", with 28 recipes.
  - One is in the app (the pilot, REC-11).
  - The other 27 come in after you approve the page. Six of them replace old near-duplicates (your
    call): Suji kheer, Beetroot and carrot mash, Tomato and carrot soup, Oats porridge, Soft idli
    pieces, Soft paneer cubes.
- **Missing:** the four recipe docs the other files point to (Prompt 4 for 12–18m, 18–23m, 2–3y,
  4–5y; 89–95 recipes each).
- **Missing:** any recipe doc for 6 months, 9–11 months, 3–4 years or 5+.
- **Not recipes:** the four "PROMPT3" files are ingredient and nutrient pages. They are parked.
  - A recipe's "More on ParentVeda · INGREDIENT" link waits for them.
  - Their own issues, to fix in the doc:
    - `whole-grains` is created twice.
    - Folate and Zinc pages are linked but never written.
    - The "standard allergen line" is worded three ways.
    - Several introduction ages look late and need the medical review: strawberry, guava,
      mushroom, quinoa and others "from 2 / 4 years".
    - Each file seems to end mid-sentence. Worth opening in Word to check.
- **Doc issue, all:** "Editorial Review Pending, Medical Review Pending". None reviewed.
- **Doc issue, 7–8m:** the doc's tail is cut off at "Standing…" (the standing review flags).
- **Doc issue, REC-11:** "More on ParentVeda" names the article "First combination meals" and the
  ingredient "Masoor dal". Neither exists in the app, so neither is linked.
- **The khichdi photo: DONE 2026-10-15.** Made in ChatGPT from the prompt below and saved as
  `assets/recipes/pp_7_8m_mixed_dal_khichdi.webp` (1200x900). The prompt is the template for the rest.

  > A top-down 45° food photograph of a small serving of Indian baby khichdi for a 7–8-month-old:
  > a soft, thick, pale-yellow mash of rice, moong dal and masoor dal with tiny soft flecks of
  > orange carrot and green lauki, with a few glistening drops of ghee on top. It is in a small
  > steel katori (baby bowl) on a light wooden board next to a small silicone baby spoon. There is
  > a pinch of turmeric and a few grains of raw moong dal scattered lightly beside the bowl. Soft
  > natural daylight from a window on the left, gentle shadows, warm and homely, an Indian home
  > kitchen feel. Realistic, not styled restaurant food. The mash must look smooth and spoonable
  > with no whole grains, no chillies, no tadka, no salt crystals and no garnish leaves. No text,
  > no logos, no hands, no people. Square-ish 4:3 landscape frame, the dish centred with space
  > around it, shallow depth of field, natural colours, high detail.

### My Child phases (PH001–PH020) — STILL-OPEN §85
- **Missing:** PH016–PH020 (19 months to 5 years). Those phases say "This phase's guide is being
  written" and keep only the old "When to call the doctor" lines (your call, 2026-10-14).
  **Update 2026-10-15:** all five are now in Drive and read in full. They are not in the app yet:
  the Drive tool cannot save a .docx, so they wait on you downloading them into the local folder
  (Large item 17).
- **Doc issue, PH016:** the age is on the title line ("Words and Opinions 19–24 months"), and editor
  notes are left in: "Word count: 201 ✓", "Milestone Pages — … — Revised", a stray
  "PH016 · Words and Opinions" under "ACTIVITY PAGE PH016", and "(≈90 words)" after headings.
- **Doc issue, PH017:** the fifth Living Through card ("Trying the Fork") ends in a broken fragment
  "ords)", and "~205 words — within 180–220 ✓" is left in.
- **Doc issue, PH018:** three editor's notes are left in the doc: "Why I changed the Language
  milestone…", "Important: I would remove 'If your toddler shows no curiosity…'", and "Important
  revision: I would remove the original variation involving a step stool…". Its typical age reads
  31–36 months; the app labels phase 18 as 31–35 months (same span, end month 36).
- **Doc issue, PH019 and PH020:** word-count and checklist notes such as "(203 words — within
  180–220 ✓)", "(5 cards ✓ …)", "(3 bullets ✓)".
- **App differs:** the converter drops all the editor notes above, so none shows in the app. They
  should still come out of the docs.
- **Missing:** new phase films. Brain Development in Watch is empty since the leap films went.
- **Doc issue, PH015:** the activity "Naming All the Feelings" is named on a milestone page but never
  written. The app shows the name with no link.
- **Doc issue, PH010:** two names differ between the snapshot and the milestone pages: "Pointing to
  Show / Share Interest", "Sharing with / With You". Pick one each.
- **Doc issue, PH004:** the file is "Phase 4 - Finding a Rhythm"; the rest are "PH0xx - Name".
- **Doc issue, all:** no time or difficulty on activities, so the app says "At your pace".
- **Doc issue, all:** "Needs paediatric panel sign-off"; none signed. Shipped on your word.
- **App differs:** the age page shows no Feeding now / Sleep now for phases 1–15; the docs have no
  such section and the old text is gone.
- **App differs:** Ask Veda does not know the phase text yet (needs the askveda repo).

### Pregnancy week pages — STILL-OPEN §84
- **Missing:** weeks 1–4 and 24–40. Week 19 skipped at your request.
- **Doc issue, weeks 5–23:** "Symptom cards require medical review before publishing"; not reviewed.
- **Doc issue, week 22:** the swelling card says "call promptly" without naming the doctor (a
  preeclampsia sign). It reads fine on screen under "When to contact your doctor"; tighten the doc.
- **Doc issue, weeks 5–8:** the partner scan lists predate the week+4 standard (week 20's appendix).
- **App differs:** Ask Veda does not know the week text yet.

### Garbh Sanskar sheet — STILL-OPEN §86
- **Missing:** the 45 Shravan audio tracks (brief: `docs/GARBH-AUDIO-OWED.md`).
- **Doc issue, no text given** (left out until written): Hindu: Shiva Raksha Stotram, Panchmukhi
  Hanuman Kavach, Devi Chandi Kavach, Sri Vishnu Sahasranama, Sri Lalitha Sahasranamam, Dattatraya
  Prabhu Kavach, Ramcharitmanas Chaupai. Muslim: Surah Maryam, Yusuf, Luqman, Ar-Rahman,
  Al-Waqi'ah, Al-Mulk. Christian: "The Perfect Peace (Philippians 4)".
- **App differs:** three Hindu meanings lost a claim sentence (Krishna Gayatri, Hanuman Chalisa,
  Brahma Gayatri); claim columns are dropped; NIV verses swapped for WEB.
- **App differs:** the Stories shelf shows the stories reached so far, not all 280.
- **Owed:** a read-through by someone of each faith before launch.

### Book summaries — STILL-OPEN §87
- **Missing:** "Garbh Sanskar: Ancient Secrets to Give Birth to Genius" (in Volume Three's contents,
  never written); Volume Four, Part 1 (books 1–12); cover art.
- **App differs:** quotes the docs mark unverifiable are left out; What to Expect's companion is
  English only, so Hindi readers lose the old translation.

### Pregnancy FAQs — STILL-OPEN §88
- **Missing:** Month 9 (weeks 36–40). Weeks 36+ suggest Month 8's questions.
- **Doc issue:** 8 related titles match no FAQ (e.g. "Is placenta previa dangerous?", "How much tea
  and coffee is safe?"). Dropped from the related rail until the doc names a real question.
- **Held:** 39 FAQs waiting for clinical sign-off.
- **App differs:** the writers' Verification notes are not shown.
- **Owed by you:** the live load into Ask Veda (export, import, ingest, deploy).

### Products sheets — STILL-OPEN §89
- **Missing:** prices, buy links and photos for every shortlist product.
- **Held:** Portable Fetal Dopplers and Herbal Anti-Nausea Teas (20), until clinical review.
- **Doc issue, toys:** PV-CRA-001..015 used twice (foil art and crayons); 83 toys "not yet
  verified"; some rows look like product and brand are swapped; no ages in the Products Master, so
  145 toys show for all ages.
- **Doc issue, kids' books:** the scoring sheets are empty; "Why Recommended" only repeats the theme.

## Needs you, not code

- **Ask Veda hosting.** The Railway trial ended and the service is down. Pick a host or plan.
- **Supabase.** Run migrations 0092 and 0096 (the recipe-doc columns; nothing needs 0096 yet). Grant the three `service_role` permissions Ask Veda needs.
  Confirm 0088, 0089, 0090 and the expert-photos bucket.
- **Phone OTP.** The `phone-otp-send` and `phone-otp-verify` functions are not deployed; they need
  the MSG91 secrets (STILL-OPEN §83.12).
- **Phase docs (Drive).** Fix the six doc issues (PH015's missing activity, PH010's two names, the
  Phase 4 file name, activity times, panel sign-off) and the editor notes left in PH016–PH020.
  Download PH016–PH020 as .docx into the local "My Child phase-wise content" folder. Then I pull
  them in.
- **Phase paintings.** Generate the 20 in ChatGPT from `docs/PHASE-PAINTING-PROMPTS.md` and send
  them as `phase_01` … `phase_20`.
- **Phase films.** New films for the phases; Brain Development in Watch is empty until then.
- **Daily insight tab images.** Marked "to discuss" (STILL-OPEN §83.13).
- **Device checks.** His side of pregnancy, the TTC calendar, and the small fixes (his week page, the
  Talk to someone icon on all three homes, "Up next" on Milestones, the press settle), and the
  phases change (Development door → Phases, a doc phase, a 2-year-old's "guide is being written"),
  and the tap feedback (press a card, scroll a list starting on a card, tap an icon inside a card:
  only the icon moves).
- **Device check, Baby vault.** Write two letters, read one aloud, "Read them all", tap the sealed book;
  then "Baby has arrived", the home card, the envelope, and download and share the book.
- **Device check, all phases screen.** Parenting home → phase hero → all phases: the NOW card, the
  chapter chips, a tap on a past and a future phase, and a tablet if one is to hand.
- **Push.** `9223ce4` (tap feedback) and anything before it not yet pushed.

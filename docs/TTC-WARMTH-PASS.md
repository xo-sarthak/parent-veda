# TTC warmth pass — the ledger (READ FIRST after a compaction)

Started 2026-09-25. Owner: this terminal. Only THIS work gets committed from here — other terminals share the tree.

## What the user asked for (their words, condensed)

> "There is a lot of text content on our application… it seems very AI. The competitor apps' language is warm,
> comforting, friendly… human, soft, cares about us. For every text piece in trying to conceive, humanize it in a
> warmer tone. Remove the em dashes wherever not needed. Not just the content pieces — the whole TTC application
> (version 3: the doors, tools, everything) should feel warm and humanized, every piece of text."

Plus, added 2026-09-25:
1. **A plagiarism check** — the same articles may go on the website, and copied text would hurt search ranking.
2. **Style guide first**, then **ONE article** as the pilot, shown to the user before anything else.
3. Explain the "before/after pairs" and the "banned list".
4. **Tool notes, kept alongside** (`docs/TTC-TOOLS-UX-NOTES.md`): for every TOOL (tools are not just text),
   note how it could be simpler, more usable and easier to understand for someone new to TTC. Do NOT change how
   any tool works — notes only. Tool TEXT still gets the warmth rewrite like everything else.
5. Keep this ledger complete so a compaction loses nothing. Parallel helpers are allowed; I monitor them.

## Scope (measured 2026-09-25)

~132,000 words of on-screen English in 138 files, ~1,470 dashes:
- `lib/ttc/reads/` — 61k words (the 51 long reads, 7 doors) — half of everything
- `lib/ttc/ttc_daily_data.dart` 9.3k · `lib/screens/ttc/ttc_strings.dart` 7.8k (all screen text) · `lib/ttc/focus/` 6.9k (door tiles, carousels, myths)
- `ttc_chapter_data.dart` 5.3k · `ttc_products_data.dart` 5.0k · `ttc_partner_data.dart` 2.9k · `ttc_can_i_data.dart` 2.2k
- ~25 smaller files: tests, precheck, videos, practice, trackers, garbh course, prepare, shop, PCOS check, BMI rules,
  fertility-help rules, vaccines, IVF readiness, semen reading, milestones, brackets (door tiles), records, cycle report…
- ONLY the V3 stage (retired classic/V1 screens are out of scope; shared strings are in).
- Measuring script: `…/scratchpad/ttc_text_size.py` (re-run to track dashes and words).

## Rules for the rewrite (never break these)

- **Meaning is frozen.** Doses, numbers, timings, red-flag signs, "see a doctor today" lines, clinic-owned dates,
  never-a-personal-probability, never-a-diagnosis, the disclaimers' substance. Warmer words, same facts.
- **Keys are frozen.** Some English strings are identities (persisted, compared, map keys, `.en` of LocalizedText,
  ids, enum names). Change DISPLAY text only. If unsure whether a string is a key, grep its uses first.
- **Hindi side untouched.** Existing `_t(en, hi)` pairs: rewrite the English only; leave the Hindi (policy: new work
  is English). They will drift slightly — accepted.
- **Do not copy competitors.** Their text is a TONE reference only. No sentence of theirs goes in verbatim
  (the plagiarism check below enforces this).
- **Tests.** Some tests assert exact strings. Update a test only when the string change is intended; never weaken a
  safety test (`test/ttc_clinical_review_test.dart` and friends). `flutter analyze` clean + full suite green per batch.
- **Commit only my files**, explicit paths, message via file, no co-author trailer.

## Plagiarism check — the plan (explained to the user 2026-09-25)

Two layers:
1. **Against the two competitors (free, local, now).** We hold Flo's and What to Expect's text on disk
   (`Downloads\competitor-walks\flo-ttc\`, `wte-ttc\pages\`). Compare every one of our TTC reads against all of it
   with overlapping 8-word sequences; flag any read sharing sequences. Run on the CURRENT text (baseline) and again on
   every rewritten batch.
2. **Against the whole web (paid, needs the user).** Copyscape Premium API — the standard for this. Needs the user
   to open an account and give an API key; sending our text to it is sending it outside, so only with their go-ahead.
   Cost at their published rate (verify at sign-up): about US$0.03 per check up to 200 words + US$0.01 per extra
   100 words → one 1,200-word read ≈ US$0.13 (≈ ₹11); all 51 reads ≈ US$7 (≈ ₹600); all ~132k words ≈ US$15
   (≈ ₹1,300). Run it on the FINAL text, before anything goes on the website.
   Note for SEO: the same text in the app and on our own website is fine; what hurts is text that matches OTHER sites.

Status: layer 1 not yet run · **layer 2 ON HOLD (user, 2026-09-25: "hold on to the API money spend").** Layer 1
runs side by side with the rewrite, on every batch, from the start of execution (not before the pilot).

## The style guide — APPROVED 2026-09-26

`docs/TTC-VOICE.md`: one page — the rules, before/after examples taken from OUR text (about ten; the
number is not fixed, it is "enough to show every rule"), and the banned list.

Banned list = words, phrases and habits the rewrite must never produce, because they make text sound machine-made or
falsely cheerful. Draft (to confirm with the user): "journey" (as a metaphor), "navigate", "empower", "delve",
"embark", "you've got this", "rest assured", "it's important to note", "in today's world", "remember,", "Let's dive
in", "game-changer", "holistic" (unless literal), exclamation marks, emoji, rhetorical-question openers stacked
("Wondering…? Worried…?"), "we understand how you feel", tricolons everywhere ("calm, clear and kind"), em dashes as a
default punctuation, jokes at painful moments.

## Order of work

The user's order (2026-09-25, after the compaction): style guide → THEY APPROVE → ONE pilot article, shown next to
the old one → THEY APPROVE → execution with parallel helpers, with the plagiarism check (layer 1) and the tool notes
done side by side during execution.

1. Style guide `docs/TTC-VOICE.md` → show the user.  [DONE, APPROVED 2026-09-26]
2. PILOT article: SKIPPED by the user ("I don't need a sample article now… start with execution").
3. After the pilot is approved: execution. Pilot area first (TTC home text + the whole Fertile window door), then
4. parallel helpers by area (one per door's reads; daily; strings; tools; chapters; partner; products; small
   files). I review each batch: guide compliance, dash count, meaning unchanged, keys unchanged, plagiarism layer 1,
   analyze + tests. Tool notes collected into `docs/TTC-TOOLS-UX-NOTES.md` as each tool is touched.
6. Phone walk → commit in batches (only my files).

## Expert names — DECIDED 2026-09-25

The user: use `C:\Users\sarth\Downloads\MASTER-CONTENT-PLAN-v3.xlsx`, sheet **"Expert roster"**, ONLY for the
doctors' names and information. The invented names (Dr. Ananya Rao, Dr. Meera Krishnan, Dr. Vikram Nair,
Dr. Sharanya Menon, Meghna Iyer) are replaced in TTC during the pass. Roles come from the sheet; the invented
"14 years" and "reviewed August 2026" are dropped (nothing in the sheet supports them).

Proposed mapping (roster "Mainly owns" column):

| Invented name (TTC count) | Real roster name | Role shown |
|---|---|---|
| Dr. Ananya Rao, Gynaecologist (~32) | Dr Ruchika Sood | IVF gynaecologist |
| Dr. Meera Krishnan, Fertility specialist (~17) | Dr Ruchika Sood (option: Dr Simranpreet Sandhu for IVF basics only) | IVF gynaecologist |
| Dr. Vikram Nair, Andrologist (~14) | Dr Ruchika Sood ("All TTC fertility"); NO andrologist on the roster | IVF gynaecologist |
| Dr. Sharanya Menon, Perinatal psychologist (~8) | Parmeshwari | Clinical psychologist |
| Meghna Iyer, Fertility nutritionist (~4) | Akanksha Srivastava | Maternal and child nutritionist |

Also on the roster for TTC: Dr Kajal Sharma (Ayurvedic garbh sanskar + yoga), Dr Fathima (medicine safety).
Videos (`lib/ttc/ttc_videos_data.dart`, all unfilmed, url null) credit the same invented names → same mapping (it
becomes the filming plan). Pregnancy/parenting files also use these names: OUT of scope (TTC only), noted for later.

Flags told to the user: the "REVIEWED BY" tick must become true (each expert actually reads her pieces), so a
sign-off list per expert is produced during the pass (`docs/TTC-EXPERT-SIGNOFF.md`); no andrologist on the roster
for the "His side" door; Dr Ruchika Sood becomes the name on most TTC pieces (the sheet already calls her the
single sign-off bottleneck).

## EXECUTION (started 2026-09-26) — how it is run

The user (2026-09-26): "The language needs to be simple… in a way the human can easily understand in one go. Don't
flex your English." The guide's "After" examples are the baseline. "Start the execution right away… deploy agents…
do it in a continuous way as a job. Don't stop in between… if you have a doubt, ask at the end. Keep doing the
plagiarism [free check]. Maintain the tools notes." Doctor names: real roster names where they make sense, else
"ParentVeda team".

Final expert mapping used: Ananya Rao and Meera Krishnan → Dr Ruchika Sood (IVF gynaecologist); Sharanya Menon →
Parmeshwari (Clinical psychologist); Meghna Iyer → Akanksha Srivastava (Maternal and child nutritionist); Vikram
Nair (his side, no male-fertility expert on the roster) → "ParentVeda team" with `reviewed: false` (shows "BY",
no tick) and authorRole "Written from the sources listed at the end". Invented years and "reviewed <month>"
dropped; evidence lines "Reviewed August 2026." → "Sources checked August 2026."

Scratchpad (session temp dir `…\c42be61c-…\scratchpad\`):
- `AGENT-BRIEF.md` — the brief every helper follows (rules, key safety, Dart mechanics, names, checks, tool notes).
- `orig/` — snapshot of all 138 TTC files BEFORE the pass (taken 2026-09-26; the tree matched HEAD for TTC).
- `warmcheck.py <files>` — vs orig: dashes, banned words, CAPS, numbers lost/gained, Devanagari changed,
  'per cent' count, word-count ratio. `UNCHANGED` tag = string not touched (missed / Hindi side / kept key).
- `plag.py [files]` — layer 1: 8-word runs shared with Flo + WTE captured text (475k 8-grams indexed).
  BASELINE before the pass: 9 matches, all stock phrases ("from the first day of one period to the…").
- `batches.py` / `batches.json` — the 12 batches; every file assigned once; only `ttc_today_screen.dart` (V1
  home, retired) is out.
- `uxnotes/<batch>.md` — tool notes from helpers → merged into `docs/TTC-TOOLS-UX-NOTES.md` by me.
- `test_baseline.txt` — full suite before the pass.

The 12 batches (helpers launched 2026-09-26, running in parallel; helpers do NOT edit tests, run git, flutter test
or dart format; I fix tests after):
A-pcos · B-ivf (+treatment tracker, care pathway) · C-his-side (+semen reader) · D-getting-ready · E-daily ·
F-home-chrome (ttc_strings + all shell screens) · G-mind-loss (+mood, ritual, journal, care circle) ·
H-window-chapters (+chapter data, window tool) · I-programmes-shop (products, prepare, videos, practice, garbh
course) · J-partner-tests-canI (+vaccines, supplements, medication, appointments) · K1-assessments (precheck, PCOS
check, PCOS stand, BMI, fertility help, IVF readiness) · K2-trackers (symptoms, cycle companion/report, records,
habits, calendar).

After the helpers: I review each batch (warmcheck + plag + read samples) → merge tool notes → `flutter analyze` →
full `flutter test`, fix tests whose exact strings changed (never weaken safety tests) → write
`docs/TTC-EXPERT-SIGNOFF.md` (which pieces each named expert must read) → phone walk → commit commands for ONLY
these files → questions for the user at the end.

## Open decisions

- Copyscape: ON HOLD by the user (no API spend for now).
- Expert mapping: DECIDED 2026-09-26 (see EXECUTION above).

## Progress log

- 2026-09-25 — plan agreed; this ledger + tool-notes file created; user compacting the chat next.
- 2026-09-25 (after compaction) — user: Copyscape on hold; free competitor check side by side during execution;
  expert names from the roster sheet; guide → approve → one pilot article → approve → parallel execution.
  `docs/TTC-VOICE.md` written (14 rules, what never changes, banned list, 11 before/after pairs from our text,
  how each rewrite is checked, notes for helpers). Shown to the user; waiting for approval.
- 2026-09-26 — user approved the guide, skipped the pilot, said go: continuous run, agents, free plagiarism
  check, tool notes, names = roster or "ParentVeda team". Built warmcheck.py + plag.py, snapshot orig/, baseline
  plag = 9 stock-phrase matches, launched 12 helpers (batches above). Baseline test run started.
- 2026-09-26 — baseline suite: 4445 passed, 5 skipped, 0 failed (ran while helpers were starting).
- 2026-09-26 — E-daily DONE + reviewed: daily_data 158 English fields rewritten, 67→0 dashes, plag 0, numbers intact; kept keys: nutrientEn labels, eyebrows, 'ParentVeda editorial' (reader_unification_test), 'How did today feel?' (tests). No tool notes.
- 2026-09-26 — D-getting-ready DONE + reviewed: 9 reads, 10,817→10,486 words, dashes→0, plag 0; numbers lost only from removed fake bylines (2026/14/16); tile titles kept (ttc_getting_ready_brief_test asserts them). Found 3 TTC files outside the scoped folders (lib/data/journeys/ttc_journeys.dart, lib/data/hubs/ttc_hubs.dart, lib/services/ttc_records_pdf.dart): snapshotted to orig/, helper L-journeys-hubs launched. Out of scope, noted for later: lib/data/community_data.dart + lib/data/mind_mood_data.dart carry the fake names too (pregnancy/community).
- 2026-09-26 — J-partner-tests-canI DONE + reviewed: 9 files changed, 71 dashes→0, plag 0; kept keys: test/supplement/vaccine names, TtcVerdict labels, costHi. UX notes in uxnotes/J (vaccine 'Had it' saves today's date; can't type own supplement; CoQ10 name clash between partners).
- 2026-09-26 — A-pcos DONE + reviewed: 11 reads 13,175→13,066 words, 110 dashes→0, plag 0 (1 match reworded), code skeleton identical (codeonly.py OK); kept: group labels + headings tapped by ttc_focus_groups_test, 'Cycle Companion'. Tests to check: expert_link_coverage_test, pp_expert_links_test, ttc_after_loss_test (fake names). codeonly.py added to scratchpad (code-skeleton equality vs orig).
- 2026-09-26 — C-his-side DONE + reviewed: 10 reads 11,252→10,990, ~141 dashes→0, plag 0, all reads ParentVeda team + reviewed:false; door blurb no longer claims 'Written by an andrologist'. Test to fix: ttc_his_side_test 'Kept with your reports — open the folder' → now 'Kept with your reports. Open the folder'. Saved record strings + limit names kept. uxnotes/C.
- 2026-09-26 — K2-trackers, G-mind-loss, F-home-chrome DONE + reviewed (codeonly OK except cycle_companion interpolation rewrite, inspected: valid). Lead fixes: ttc_focus_screen.dart:2748 myth story reviewedBy 'ParentVeda medical review' → 'ParentVeda team'; ttc_focus_pcos.dart:568 'Reviewed by a gynaecologist' → 'Reviewed by Dr Ruchika Sood, IVF gynaecologist'. Pending: ttc_focus_conceiving.dart:309 same 'ParentVeda medical review' (H still running). Tests to fix: ttc_tools_test:458 ('did not write'), ttc_cycle_spans_test:273 ('We would rather not guess' → "We'd rather not guess"), ttc_medication_test:108, ttc_teaching_test:118 + :76 ('AFTER ovulation'). User decisions to raise at end: 'Chance of conceiving' label + 'Most likely' (no number, kept); intro language button shows हिन्दी but gives Latin Hindi; K2 code issues (two symptom loggers share keys; records Save silently no-op; TtcHabitsScreen unreachable/broken); G (journal tap only deletes; ritual 0/5 counter vs no-score; care circle add = coming soon).
- 2026-09-26 — 25 files had lost CRLF (helpers' rewrites + my sed -i) → restored with scratchpad/eol.py --fix. RUN eol.py --fix AGAIN after the last helper, before tests/commit.
- 2026-09-26 — H-window-chapters DONE + reviewed (codeonly OK, eol OK, plag 0). Lead fix: ttc_focus_conceiving.dart:309 'ParentVeda medical review' → 'ParentVeda team'. Tests to fix: saved_screen_wiring_test + saved_store_test ('How conception actually works' → 'How conception works'), ttc_focus_carousel_test + ttc_focus_page_test:371/372 ('What he should do' → 'What he can do', 'What she should do' → 'What you can do'), ttc_home_hero_test (chapter 'Next: Knowing Your Rhythm, from…'), fake-name tests. RAISE WITH USER: window-length inconsistency pre-existing (reads: 6 days ending ON ovulation = ASRM; chapter_data + window screen: ending the day AFTER; window glossary lists 7 days) — clinical call, text left as was.
- 2026-09-26 — K1-assessments DONE + reviewed (21 files, plag 0, 2 Flo matches reworded). Kept: medicalReview / kBmiReviewRegister / fertility-help trigger+article (not shown, test-read). Tests to fix: ttc_pcos_checker_test L44/64/84 ('genuinely reassuring' → "that's reassuring as far as it goes"), ttc_focus_groups_test L405 ('A read of your own pattern' → 'A look at your own pattern.'). UX raise: two PCOS tools overlap; fertility-help vs IVF-readiness near-duplicates; IVF readiness result leads with the paid consult.
- 2026-09-26 — L-journeys-hubs DONE + reviewed (titles synced with renamed reads; plag 0). Lead fix: ttc_records_v2.dart 'number not typed' ×3 → 'not entered' to match the PDF.
- 2026-09-26 — ALL 13 helpers DONE. Lead consistency pass: video tile title synced (focus_mind_body 'Why "just relax" is the wrong advice'); broken anchor fixed (focus_mind_body atHeading 'What to actually eat' → 'What to eat'; all 13 anchors resolve); trigger reminder text corrected to the real schedule (4 h and 15 min before; Hinglish side corrected too, factual); Anjali Deshmukh (invented yoga lead, 2 films) → Dr Kajal Sharma, 'Ayurveda and yoga teacher'; records 'not typed' → 'not entered'. Global: plag 0 on all 141 files; eol fixed; flutter analyze lib = no errors, no new TTC issues. docs/TTC-TOOLS-UX-NOTES.md merged (43 tools, 'Start here' list of 12 behaviour issues, priority table). docs/TTC-EXPERT-SIGNOFF.md written (Ruchika Sood 48, ParentVeda team 15, Parmeshwari 7, Akanksha 4, Kajal Sharma 2). Full test run in progress → scratchpad/test_after.txt.
- 2026-09-26 — Tests: first full run after the pass 14 failures → fixed (8 tests updated to new wording, safety meaning kept; 4 thin reads restored above 600 words; cycle companion date row keeps en dash (overflow); 'What he/you should do' headings restored (collided with group labels); mood 'It's not a score'). Second full run: 4444 passed, 1 failed = garbh_games_engine_test nonogram 0.75px overflow, NOT ours, passes alone (flaky). Guide marked APPROVED + dash exceptions. STILL-OPEN §78 written. Commit message: scratchpad/commit-msg-warmth.txt. Changed lib list: scratchpad/changed_lib.txt (90). DONE pending user commit + phone walk.
- 2026-09-26 — User answers: (1) window → six days ending ON ovulation everywhere: done in ttc_chapter_data (both sides), ttc_strings fertilityWindowNote (both sides), ttc_window_screen (legend, glossary, WHY SIX DAYS, +1 day note); tool still shades 7 days (no tool change), words now call the 7th a margin. (2) Real names stay; lists NOT sent yet → sign-off doc has Sent/Signed columns + generator tools/ttc_expert_signoff.py. (3) No tool fixes; keep UX notes current → added 'How these notes were made' (all from code, none walked; coverage 28 + 15). (4) Non-TTC names not a concern. (5) No phone walk now. TTC tests 1297 green. STILL-OPEN §78.2 resolved, §78.1a added; restored LF on STILL-OPEN (python text-mode write had made it CRLF). Commit list now 104 files.

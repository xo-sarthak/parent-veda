# BEFORE-LAUNCH: everything that must be done or decided before real users

**Created 2026-10-17** at the user's request: one list, so nothing that blocks a launch hides in a 10,000-line
tracker. Built from an industry-standards review of the backend, plus a sweep of every `*.md` in the repo for
pre-launch items (each one pointed back to its source).

## How this file works

- **One line per item.** Each says what to do, who owns it, and where its detail lives (`STILL-OPEN §x` means
  `docs/STILL-OPEN.md`). The detail stays in the source doc; this file is the index you act from.
- **Every item is dated.** `added` is when it reached this list. Tick a done item as `[x]` with `done <date>`.
  Never delete one: a done list is evidence.
- **Tiers:**
  - **BLOCKER**: the app must not reach real users with this open.
  - **LAUNCH**: should be done before launch; a short, named exception is possible.
  - **DECIDE**: a decision only the user can make, and the build waits on it.
  - **CHECK**: the docs disagree, or nobody recorded the outcome. Find out, then retier or tick.
- **Owners:** `user` (you), `dev` (code work), `clinician`, `dietitian`, `legal`, `website` (the website
  terminal).
- **Maintenance rule:** whenever work finds something that must happen before launch, it's added here in the same
  change. When closing a step in `docs/BACKEND-SYNC-LOG.md`, re-check this file. Another terminal may write here
  too: re-read, append, never reflow.

---

## 0. The short list: launch blockers

The docs' own blockers (STILL-OPEN header, line 20), plus the ones this review adds. Detail is in the sections
below.

- [ ] **BLOCKER** · Remove the demo partners (`demo_%`, `demo_org_%`); a fake doctor is live on a public page · user · STILL-OPEN §1.3 · added 2026-10-17
- [ ] **BLOCKER** · `assetlinks.json` returns 404; needs the Play App Signing SHA-256 · website, once on Play · STILL-OPEN §1.1 · added 2026-10-17
- [ ] **BLOCKER** · Website `APP_LIVE` → true on listing day, plus the store redirect and `referrer` on `/invite/` · website · STILL-OPEN §1.2, §8.2 · added 2026-10-17
- [ ] **BLOCKER** · `kPremiereAlwaysShow` → `false` (still `true`, `lib/brand/premiere_screen.dart:47`) · dev · STILL-OPEN §1.4 · added 2026-10-17
- [ ] **BLOCKER** · `kDailyPopupAlwaysShow` → `false` (still `true`, `lib/screens/post_pregnancy/daily_tip_popup.dart:66`) · dev · STILL-OPEN §5.12, §12.4 · added 2026-10-17
- [ ] **BLOCKER** · Testing scaffolding out of the release build: the Mom/Dad preview pill, "Reset to Week 20 · testing", the doctor-role picker, `_PreviewBar` (`home_screen.dart:92`), `_FatherPreviewBar` · dev · app-review master §11.4, HANDOFF.md · added 2026-10-17
- [ ] **BLOCKER** · Google sign-in in release: a second Android OAuth client with the release / Play SHA-1, and the consent screen published out of Testing · user · AUTH-SETUP §1b, §1c · added 2026-10-17
- [ ] **BLOCKER** · A published privacy notice, and the web account-deletion page Google Play requires (parentveda.in) · user + website · STILL-OPEN §67.3, AUTH-SETUP §3c · added 2026-10-17
- [ ] **BLOCKER** · A staging database, and migrations through a tracked tool rather than pasted into the live SQL editor (§1 below) · user + dev · added 2026-10-17
- [ ] **BLOCKER** · Crash and sync-failure reporting, so a silently failing table is seen (§7 below) · user + dev · added 2026-10-17
- [ ] **BLOCKER** · Clinical sign-off on the medical copy that ships (§4 below). Nothing has been sent to the experts yet · user sends, clinicians sign · TTC-EXPERT-SIGNOFF · added 2026-10-17
- [ ] **BLOCKER** · Seed trust signals made true or removed: fake reviewer names, "N mothers" counts, the default 4.9 rating, seed roster names, wrong bylines · user · STILL-OPEN §12.4, §65.3, §81.5, §81.23, §16.2 · added 2026-10-17

Blockers for **real money** and **sponsors** are in §5. They gate those features, not the free app.

---

## 1. Backend and data

### Sync and data safety (this session's work; history in `docs/BACKEND-SYNC-LOG.md`)
- [x] **LAUNCH** · Run `supabase/migrations/0100_sync_guard_newer_wins.sql` · user · sync log step 4 · added 2026-10-17 · **done 2026-10-17**
- [ ] **LAUNCH** · The two-phone walk for sync steps 1–4: delete offline on phone A, sync B, check it stays gone; edit on both, check the newer wins · user + dev · sync log · added 2026-10-17
- [x] **LAUNCH** · Run `supabase/migrations/0101_pp_logs_sync_clock.sql` (Parenting logs: clock, soft delete, guard) · user · sync log step 5 · added 2026-10-17 · **done 2026-10-17**
- [x] **LAUNCH** · Run `supabase/migrations/0104_pp_records_sync_clock.sql` (documents, health, milestones, vaccines, emergency card: clock, soft delete, guard, shared reminder time) · user · sync log step 6 · added 2026-10-18 · **done 2026-10-18**
- [ ] **LAUNCH** · The two-phone walk for step 6: a vaccine reminder set on A buzzes on B; switched off on B, A stops; un-tick a dose on B, A shows it; clear the emergency card on A, it stays cleared on B; remove an allergy offline, it stays removed · user + dev · sync log step 6 · added 2026-10-18
- [x] **LAUNCH** · Run `supabase/migrations/0105_pp_children_votes_sync_clock.sql` (child profile + name votes: clock, soft delete, guard), before installing a build with step 7 · user · sync log step 7 · added 2026-10-20 · **done 2026-10-20**
- [x] **LAUNCH** · Run `supabase/migrations/0106_preg_part1_sync_clock.sql` (Pregnancy part 1: clock, soft delete, guard, the father_missions UPDATE policy), before installing a build with step 8 · user · sync log step 8 · added 2026-10-20 · **done 2026-10-21**
- [x] **LAUNCH** · (done 2026-10-21: run, job 3 active) Run `supabase/migrations/0109_purge_removed.sql` (the 90-day purge of soft-deleted rows, scheduled with pg_cron; never `children`) and its check (one active `pv-purge-removed` job) · user · sync log steps 11 and 12 · added 2026-10-21
- [ ] **LAUNCH** · Device check for steps 11 and 12: sign out with a medicine alarm set, nothing rings; sign in as someone else, no birth plan, search history or messages from the last person; a fresh install signs in and the logs upload quickly · user + dev · sync log steps 11 and 12 · added 2026-10-21
- [x] **LAUNCH** · (decided 2026-10-22: sync it all except Skilling; built as step 13) DECIDE: phone-only personal data (birth plan, Garbh journal, memories, BMI history, condition answers, the skilling journal and portfolio) is lost for good at sign-out, while the sign-out sheet says it stays saved. Move each to a cloud blob (the non-shopping half of step 10), or change the sheet's words · user · STILL-OPEN-BACKEND §4 · added 2026-10-21
- [x] **LAUNCH** · (run 2026-10-22, commit `8c466d0`) Run `supabase/migrations/0110_state_merge_and_records.sql` (the per-item merge, the `memories` and `garbh_journal_entries` tables, `profiles.pregnancy_ended_at`) and its checks · user · sync log step 13 · added 2026-10-22
- [ ] **CHECK** · Device walk for step 13: fill in the birth plan, a memory with a photo, a BMI reading and some TTC answers, sign out and back in, and everything returns; two phones tick different hospital-bag items and both stay · user · sync log step 13 · added 2026-10-22
- [ ] **DECIDE** · Skilling's child records (journal, portfolio, voice, practice, the child's profile) stay on the phone pending a consent and legal review for children's data; decide before launch whether they sync · user · sync log step 13 · added 2026-10-22
- [ ] **DECIDE** · "Pregnancy ended" now lives on her profile, which a linked partner can read (0009). Confirm that his app should know, and how it should show it · user · sync log step 13 · added 2026-10-22
- [x] **LAUNCH** · Run `supabase/migrations/0107_preg_part2_sync_clock.sql` (Pregnancy part 2: clock, soft delete, guard, medicine alarms column, symptom severity 'strong'), before installing a build with step 9 · user · sync log step 9 · added 2026-10-21 · **done 2026-10-21**
- [ ] **LAUNCH** · The two-phone walk for step 9, one account: a medicine alarm set on A buzzes on B; delete the medicine on A, B stops; tick the same medicine on both offline, one log; un-mark a scan, it stays un-marked and the partner no longer sees it; Strong symptom on A shows on B; a weight entry deleted offline stays gone; the kegel routine changed on A is on B · user + dev · sync log step 9 · added 2026-10-21
- [ ] **LAUNCH** · The two-phone walk for step 8, one account: delete a calendar note offline, it stays gone; clear a mood on A, cleared on B; un-keep an affirmation, it stays un-kept; remove a reminder on A, B stops buzzing; delete a bump photo, gone on B and from Storage · user + dev · sync log step 8 · added 2026-10-20
- [ ] **LAUNCH** · The two-phone walk for step 7: rename the child on A while B logs a weight, the name holds; remove a child on A, it stays gone on B; restore it on B, it is back on A with its records; skip a liked name offline, it stays skipped · user + dev · sync log step 7 · added 2026-10-20
- [ ] **LAUNCH** · The two-phone walk for step 5, both parents on one child: log a feed on A, delete it on B, sync A, check it stays gone; correct the other parent's feed, check "logged by" does not change · user + dev · sync log step 5 · added 2026-10-17
- [ ] **LAUNCH** · Pregnancy and Parenting row stores still bring deleted data back (~30 tables, union merge, hard deletes) · dev · STILL-OPEN-BACKEND §1 · added 2026-10-17 · *2026-10-17: the six Parenting logs are fixed (step 5, 0101 run 2026-10-17). 2026-10-18: documents, health, milestones, vaccines and the emergency card too (step 6, 0104 run 2026-10-18). 2026-10-20: name votes and the child profile (step 7, 0105 run 2026-10-20). 2026-10-20: Pregnancy part 1 (step 8, 0106 run 2026-10-21). 2026-10-21: Pregnancy part 2 (step 9, 0107 run 2026-10-21): every row table is now fixed; what is left is the blobs (step 10)*
- [ ] **LAUNCH** · Uploads outside TTC fail silently, so the sign-out sheet can say "saved" while changes are unsent · dev · STILL-OPEN-BACKEND §3 · added 2026-10-17
- [ ] **DECIDE** · How rows both parents write are merged, per table (child profile, emergency cards) · user · STILL-OPEN-BACKEND §6 · added 2026-10-17
- [ ] **LAUNCH** · Blob stores: per-item merge for curated lists (hospital bag, checklists, cart, saved readings). Until then two phones can overwrite each other · dev · STILL-OPEN-BACKEND §2 · added 2026-10-17
- [ ] **CHECK** · "TTC sync has never run against the live database": probably superseded by 0097–0099; confirm with the two-phone walk, then tick · user · STILL-OPEN §9.1 · added 2026-10-17
- [ ] **CHECK** · Confirm the timeline never synced: `select count(*) from journey_timeline;`, then again after the app has opened on 0099 · user · sync log step 2 · added 2026-10-17

### How the database is changed (from the 2026-10-17 review)
- [ ] **BLOCKER** · **A staging Supabase project.** Every migration runs there first, then on production. Today every migration goes straight onto the live database · user (create the project) + dev (wire it) · added 2026-10-17
- [ ] **LAUNCH** · **Tracked migrations** (`supabase db push`, or the CLI's migration history) instead of pasting into the SQL editor. The database then knows which migrations have run, and the "did 0099 run?" question can't happen · dev · added 2026-10-17
- [ ] **LAUNCH** · **Backups and point-in-time restore.** No doc mentions it. Confirm the Supabase plan includes PITR, and write down how to restore · user · added 2026-10-17
- [ ] **LAUNCH** · **RLS tested by running it, not by reading it.** A test that signs in as two real users against a local Supabase (or pgTAP) and proves a partner can read, but can't change, the other's rows · dev · added 2026-10-17

### Data and content in the database
- [ ] **LAUNCH** · Products never loaded into `products`, so the server prices orders from the phone's figure (`priced_by: client`). On hold as admin-panel work · user · STILL-OPEN §65.1 · added 2026-10-17
- [ ] **LAUNCH** · A "Potty and toilet" shop subcategory: potty, seat insert, step stool, travel potty, cloth trainer pants. The Potty door links `pp_products/Potties` and `pp_products/Travel potties`, which say "we haven't picked" with a tip until then · catalogue · DOOR-CONTENT-OWED PT10 · added 2026-10-25
- [ ] **LAUNCH** · First 40 shop gaps: a baby massage oil (plain, fragrance-free), a plain cradle (the bassinet shelf is mostly smart bassinets), an underarm digital thermometer, a soft postpartum binder. Each First 40 link says so with a tip until then · catalogue · DOOR-CONTENT-OWED FF15–FF17 · added 2026-10-25
- [ ] **LAUNCH** · Recipes mirror and incremental Ask Veda ingest (28 new dishes missing; the retired `tomatocarrotsoup` still published). In progress in another terminal · dev + user · STILL-OPEN §65.1 · added 2026-10-17
- [ ] **LAUNCH** · Live load of the pregnancy FAQs (export, import, ingest, deploy) · user · STILL-OPEN §88.0 · added 2026-10-17
- [ ] **LAUNCH** · Ask Veda has no parenting corpus, week pages or phase docs (a two-repo change) · dev · STILL-OPEN §82.7, §84, §85 · added 2026-10-17
- [ ] **LAUNCH** · The `export-my-data` edge function isn't built (the row says "Coming") · dev · STILL-OPEN §67.1 · added 2026-10-17
- [ ] **LAUNCH** · The partner-sharing switch is local only; the server ignores it until it's a `profiles` column · dev · STILL-OPEN §67.2 · added 2026-10-17
- [ ] **LAUNCH** · Content edits have no history ("last write wins, silently"); an audit trigger is owed · dev · STILL-OPEN §7.2 · added 2026-10-17
- [ ] **CHECK** · The three `service_role` grants (recipes, reads, products): STILL-OPEN §80.15 says owed, REMAINING-CHANGES says done · user · added 2026-10-17
- [ ] **CHECK** · Was the demo re-seeded after 0089? Unknown · user · STILL-OPEN §5.4k · added 2026-10-17
- [x] **LAUNCH** · Run **0102** (Onboarding V3: `profiles.due_date_source` + `dating_date`, `children.birth_mode` + `born_weeks`, the `ttc_ready_plans` table, `link_as_partner` refuses instead of re-pairing), then flip `kChildBirthColumns` to true in `pp_child_profile.dart` · user runs, dev flips · ONBOARDING.md §4, STILL-OPEN §62.6 · added 2026-10-17 · *done 2026-10-17: the user ran 0102; `kChildBirthColumns` flipped to true*
- [ ] **LAUNCH** · Run **0103**: a partner can read, never delete, her `ttc_journeys` and `ttc_treatment` rows (one `for all` policy split into four) · user · BACKEND-PATTERNS §16jj-b · added 2026-10-17
- [ ] **LAUNCH** · Walk the V3 onboarding on a phone, every path: trying (getting ready, on our own, clinic), his trying, pregnancy (four dating ways, twins, gentle), his pregnancy, parenting (twins, a second child), skilling, partner with a code; then her "Did he send you a code?" link · user + dev · STILL-OPEN §62.6 · added 2026-10-17

---

### Affiliate prices (2026-10-21, STILL-OPEN §96.8)
- [x] **LAUNCH** · Run `supabase/migrations/0108_products_affiliate.sql` (asin, price_checked_at, ext_rating, ext_review_count on products) · user · STILL-OPEN §96.8 · added 2026-10-21 · **done 2026-10-21**
- [ ] **DECIDE** · Which exact Amazon listing each affiliate product points at; type the ASIN, price and date into `lib/data/products/pv_affiliate.dart` (empty on purpose; nothing invented) · user · STILL-OPEN §96.8 · added 2026-10-21
- [ ] **LAUNCH** · Creators API credentials (Associates Central → Manage Credentials; old PA-API keys do not work, PA-API 5 is retired), then deploy and schedule `affiliate-refresh` · user + dev · BACKEND-PATTERNS §16ii-p · added 2026-10-21

## 2. Security and privacy

- [ ] **LAUNCH** · The skilling journal's AES key sits in `shared_preferences` beside the data; move it to the platform keystore (`flutter_secure_storage`). Needs the user's OK for the dependency · dev · STILL-OPEN §103.3, §105.3 · added 2026-10-17
- [ ] **LAUNCH** · `care_partners.trust` is unconstrained `jsonb`; only the website's allowlist stops an advertising label under a doctor's name · dev · STILL-OPEN §4.2 · added 2026-10-17
- [ ] **LAUNCH** · The Directus presentation pass before anyone else gets a login: `brand_sample_claims` would name rows by home address · user · STILL-OPEN §7.1, DIRECTUS-SETUP §1b · added 2026-10-17
- [ ] **LAUNCH** · Expert registration numbers really checked before a clinician goes live (`kTtcRegistrationChecksRecorded = false`) · user · STILL-OPEN §16.0 · added 2026-10-17
- [ ] **CHECK** · The email templates carry `{{ .Token }}` and OTP length is 6, at least for the doctor app's magic link. Nothing marks it done · user · AUTH-SETUP §3b · added 2026-10-17
- [ ] **CHECK** · Server-side rate limit on the SMS send (per phone, per IP). BACKEND-PATTERNS describes a rule; confirm it's live · dev · ONBOARDING.md History A · added 2026-10-17
- [ ] **CHECK** · The `directus_cms` role has a password and gets "permission denied" on `journal_entries`. STILL-OPEN §7 says it was proved; tick if so · user · DIRECTUS-SETUP §0 · added 2026-10-17
- [ ] **LAUNCH** · Sponsor-uploaded resources: a review path and a "never medical advice" rule before any sponsor uploads · dev · STILL-OPEN §11.5 · added 2026-10-17

---

## 3. Legal and compliance

- [ ] **BLOCKER** · Privacy notice published; Help and About given content · user · STILL-OPEN §67.3, PROFILE-AUDIT §10 · added 2026-10-17
- [ ] **BLOCKER** · The account-deletion web route on parentveda.in (a Google Play requirement) · website · AUTH-SETUP §3c · added 2026-10-17
- [ ] **LAUNCH** · DPDP: verifiable parental consent for under-18s (skilling 6+ ships); the rules bite by May 2027. No consent flow is built · legal + dev · MARKET-LANDSCAPE · added 2026-10-17
- [ ] **LAUNCH** · Legal review of the child-private journal against DPDP's parental-consent rules · legal · STILL-OPEN §103.1, §103.3, §105.3 · added 2026-10-17
- [ ] **BLOCKER** · A lawyer and a clinician confirm Childline 1098, Tele-MANAS 14416 and the crisis sheet's wording ("not optional before a public launch") · legal + clinician · STILL-OPEN §105.2 · added 2026-10-17
- [ ] **LAUNCH** · The crisis pathway, designed by a child psychologist and a lawyer (today a deliberate stub) · clinician + legal · STILL-OPEN §103.3 · added 2026-10-17
- [ ] **LAUNCH** · Donor-route and surrogacy reads checked against the ART Act and Surrogacy Act · legal · TTC-GAP-PLAN §6–§7, STILL-OPEN §79.3 · added 2026-10-17
- [ ] **LAUNCH** · When real prices land, MRP is a legal ceiling (sell below, never above) · dev · BACKEND-PATTERNS §16hh · added 2026-10-17

---

## 4. Clinical and content review

**The gate:** `docs/TTC-EXPERT-SIGNOFF.md` is "the list to send each expert before launch". **Status: nothing sent
yet.** Dr Ruchika Sood alone has 72 pieces. There's no male-fertility specialist, and she isn't in `kExperts`.

- [ ] **BLOCKER** · Send the sign-off lists; record each expert's sign-off · user · TTC-EXPERT-SIGNOFF · added 2026-10-17
- [ ] **BLOCKER** · TTC clinical copy: a doctor's read (it has had a product review only), with statements P1–P3 held for the specialist · clinician · STILL-OPEN §9.3–§9.4, TTC-SPEC §7–§8, TTC-IVF-REVIEW · added 2026-10-17
- [ ] **BLOCKER** · The 27 condition pages, especially the `callNow` lists · clinician · STILL-OPEN §14.4 · added 2026-10-17
- [ ] **LAUNCH** · Preeclampsia personalisation ruling; Tele-MANAS confirmed; Mind & Mood counsellor review (`docs/MIND-MOOD-REVIEW.md` written, not sent) · clinician · STILL-OPEN §14.1–§14.3 · added 2026-10-17
- [ ] **LAUNCH** · South Asian obesity cut-off, 25.0 or 27.5 ("the highest-value question") · clinician · STILL-OPEN §15.6 · added 2026-10-17
- [ ] **LAUNCH** · TTC facts to confirm: egg-freezing costs, letrozole, NICE ages, NFHS-5, the 1091 helpline, lab and strip prices, the ibuprofen tip, and treatment timings (Dr Surbhi Sharma) · clinician · STILL-OPEN §79.3–§79.14 · added 2026-10-17
- [ ] **LAUNCH** · Week-page sources; the six moment lines (Tdap especially); the BP/sugar wording, the twin growth line, partner reads, Move timing · clinician · STILL-OPEN §81.2, §81.9(d), §81.17–§81.23 · added 2026-10-17
- [ ] **BLOCKER** · Two citations written from memory (Brennan 2007; Paulson & Bazemore 2010) checked against the papers or removed · dev · STILL-OPEN §81.17–§81.23 · added 2026-10-17
- [ ] **LAUNCH** · Every parenting `REQUIRED_REVIEW`: 40 Din-by-din lines, 12 visit cards, mood questions, `kVaxPrivateOnly`, paternity leave, 289 food ages, 139 recipes (dietitian), car-seat and cot safety · clinician + dietitian · STILL-OPEN §82.5–§82.6, PP-SECTIONS-STATE · added 2026-10-17
- [ ] **LAUNCH** · Health tools (tools pass, 2026-10-25), all marked `REQUIRED_REVIEW`: the two new symptom concerns in Is my baby OK? (Vomiting, A cough: every question and result, `pp_what_changed_data.dart`); Fever check's new low-reading branch over 3 months and its thresholds (`pp_fever_check_screen.dart`); growth curves on corrected age to 24 months (`GrowthStore.ageFor`); home-remedy verdicts and the five new avoid entries (ghutti, kajal or surma, oil in ears or nose, gripe water, honey under 1; hing and the mustard-oil garlic rub now caution, `pp_nuskhe_data.dart`) · paediatrician · docs/pp-tool-plans/08-16-health.md · added 2026-10-25
- [ ] **LAUNCH** · Food tools (tools pass, 2026-10-25), all marked `REQUIRED_REVIEW`: added sugar and jaggery from 24 months (festival sweets kept at 12 as "an occasional taste"); grapes quartered from 6 months; whole egg, fish and chicken from 6 months in the chart and the allergen walk-through; Veggie Maggi and Dhokla from 12 months; the allergic-reaction red flags and their emergency line (`pp_food_safety.dart`), and the allergen keywords that match a child's allergies to foods and recipes · paediatrician + dietitian · docs/pp-tool-plans/22-24-food.md · added 2026-10-25
- [ ] **LAUNCH** · You, Maa tools (tools pass, 2026-10-25), all marked `REQUIRED_REVIEW`: the four mood questions (the PHQ-2 and GAD-2 pairs, in plain words) and their two answers; Can I...?'s seven "See a doctor today" red flags (three new: chest pain, a wound, thoughts of harm), alcohol "Best avoided", fasting under six months, telmisartan and losartan, weight-loss pills, chickenpox near the birth, the two-wheeler line, and every answer against its sources line (LactMed, NHS, FOGSI, IAP); pelvic floor squeezes from six weeks in Can I, Kegel Care and `pf_ex_kegels` (some clinicians start gentle squeezes within days); Kegel Care's numbers (relax twice the hold, ten breaths); `po_gentle_rec` as "gentle enough for the first weeks" · perinatal counsellor + obstetrician + pharmacist + lactation consultant + women's health physio · docs/pp-tool-plans/25-28-you-maa.md · added 2026-10-25
- [ ] **LAUNCH** · Development tools (tools pass, 2026-10-25), all marked `REQUIRED_REVIEW`: the gentle check-in's ages, when each question is first asked and when a "not yet" counts (`CheckInQ.askFrom` / `flagFrom` / `countsFrom`, `pp_development_data.dart`; smile 2/3, voice 4/6, sit 6/9, babble 6/9, pulling up 12/15, showing 12/18, words 12/16, two words 24, understood by others 36, lost skill from 6; ordinary questions count 3 months after first asked); and the 19 first-year milestone windows and "discuss" months, which carry no source (`pp_milestones_data.dart`, now the check-in's source too) · paediatrician · docs/pp-tool-plans/17-21-development.md · added 2026-10-25
- [ ] **LAUNCH** · False endorsements still in the app: `article_reader_screen.dart` says "Reviewed by our medical panel" (three places) and no panel has reviewed it; `pp_nuskhe_data.dart` keeps named BAMS reviewers (`kDefaultPanel`, not shown today). Remove or gate them behind a real sign-off, the way TTC bylines are gated · content · docs/pp-tool-plans/08-16-health.md · added 2026-10-25
- [ ] **LAUNCH** · Health door (door 2 build, 2026-10-25), all marked `REQUIRED_REVIEW`, the go-now list first: the fifteen new pages (dengue and no NSAIDs, a fit with fever, dog, snake and scorpion bites and the free rabies vaccine, head bumps, sore throat, Deworming Day dates, the Anemia Mukt Bharat iron syrup schedule, the Vitamin A schedule, heat stroke, insect bites and repellent ages, boys and girls, nosebleeds, U-WIN's age scope, ABHA steps, the medicine box) and the fifteen deepened pages · paediatrician · docs/pp-door-plans/02-health.md §5, §12 · added 2026-10-25
- [ ] **LAUNCH** · Health shelves: the Forehead Thermometer's claims against `fever_reading` ("check with a digital one"), and no scented lotion sold on the eczema page. Rule H4 holds by test: Health never sells or links to buy a medicine, supplement, syrup, ORS brand or drops · content · docs/pp-door-plans/02-health.md §3f · added 2026-10-25
- [ ] **LAUNCH** · You, Maa door (door 3 build, 2026-10-25), all marked `REQUIRED_REVIEW`: the eight new pages first (contraception after birth: LAM's three conditions, PPIUCD timing, Antara, Chhaya, sterilisation; the sugar test after GDM; BP after pre-eclampsia and its go-now list; Hb, VIA and breast checks; fathers' low mood; spacing), then the thin-page additions (thyroid phase timings, the birth-trauma figure, fasting) and `move_running` from three months · gynaecologist (pelvic-health physio for the running and exercise lines) · docs/pp-door-plans/03-you-maa.md §8, §13 · added 2026-10-25
- [ ] **LAUNCH** · You, Maa legal and scheme lines checked against the current government text: PMMVY (₹5,000 / ₹6,000 second girl), JSY, the Domestic Violence Act 2005, 181, One Stop Centres, NALSA 15100 (`work_schemes`, `people_safe_at_home`, `people_separated`) · content + legal · docs/pp-door-plans/03-you-maa-content.md · added 2026-10-25
- [ ] **LAUNCH** · Development door (door 4 build, 2026-10-25), all marked `REQUIRED_REVIEW`: the new page "Movement signs worth showing a doctor" (`dev_movement_signs`: stiff or floppy, fisting after 4 months, one side before 12 months, sitting by 9, weight-bearing by 12, walking by 18, a lost skill this week; the RBSK/DEIC line), the M-CHAT line on `dev_age_1_2`, and the phases rewrite of `dev_leaps_lens` · developmental paediatrician or paediatric physio · docs/pp-door-plans/04-development.md §12 · added 2026-10-25
- [ ] **LAUNCH** · Potty door (door 5 build, 2026-10-25), all marked `REQUIRED_REVIEW`: the new doctor lines (wet nights after six months dry, pain, thirst, snoring; travel constipation at three days, no laxative without asking; holding all day at school), bedwetting named as enuresis with "one child in six at five", the alarm and desmopressin as a doctor's choice after six, soiling (encopresis) as constipation, pinworms and whole-family treatment, front-to-back wiping on the doll activity, and the pull-ups rewrite · paediatrician · docs/pp-door-plans/05-potty.md §12, 05-potty-content.md Part B · added 2026-10-25
- [ ] **LAUNCH** · First 40 door (door 6 build, 2026-10-25), all marked `REQUIRED_REVIEW`: the birth vaccines (BCG, OPV-0, Hep B, where each goes, the BCG scar), "What your baby can see" (20 to 30 cm, colour, the three eye signs), the nappy page's first-year part (green, frequency, after solids, the same-day signs), the oil table's mustard and sunflower rows, the four "old rules for you" (bathing after a birth or a C-section, the binder, early walking and clots, water) · paediatrician (the baby lines), gynaecologist (her lines) · docs/pp-door-plans/06-first40.md §12, 06-first40-content.md §5 and R1–R3 · added 2026-10-25
- [ ] **LAUNCH** · First 40 legal and scheme lines checked against the current government text: birth registration within 21 days and free in that window (RBD Act 1969, amended 2023), JSY, JSSK and PMMVY 2.0 as described on `f40_rest_and_food`, Tele-MANAS 14416 · content + legal · docs/pp-door-plans/06-first40-content.md §3, §5 · added 2026-10-25
- [ ] **LAUNCH** · Real women's health physios and perinatal counsellors in the roster (each has two `Expert.seeded` placeholders; until then their rows say "joining soon" and point at the gynaecologists, `kPpJoiningSoon`). Owed categories: an adult postpartum nutritionist, a couples or family counsellor · ops (onboarding, `ADMIN-PANEL.md`) · DOOR-CONTENT-OWED YM16, YM17 · added 2026-10-25
- [ ] **BLOCKER** · Symptom cards for weeks 5–23 ("require medical review before publishing"; shipped on the user's word) · clinician · STILL-OPEN §84 · added 2026-10-17
- [ ] **LAUNCH** · Paediatric panel sign-off on each phase's doctor lines, milestones and activities · clinician · STILL-OPEN §85 · added 2026-10-17
- [ ] **LAUNCH** · 39 held pregnancy FAQs (bleeding, ectopic, preeclampsia and others); fetal dopplers and herbal teas held · clinician · STILL-OPEN §88, §89 · added 2026-10-17
- [ ] **LAUNCH** · Can-I trimester notes; `kFoodValues` (dietitian); the Ready-to-Try test list and folic acid wording; regional food blocks · clinician + dietitian · STILL-OPEN §68.5, §70, §92 · added 2026-10-17
- [ ] **LAUNCH** · The 14 tip sources and a view on paediatrician overrides · clinician · STILL-OPEN §9.1b · added 2026-10-17
- [ ] **LAUNCH** · ₹ scan-cost ranges in `scan_extras.dart` · clinician · LEVEL-MAP-STATE, PROBLEM-HUB-AUDIT · added 2026-10-17
- [ ] **LAUNCH** · A faith read-through of the spiritual content; WEB verses checked against a printed WEB · user arranges · STILL-OPEN §86 · added 2026-10-17
- [ ] **DECIDE** · Every pregnancy read is `reviewed: false`, and Ask Veda grounds answers in them; decide whether that can ship · user · PREGNANCY-ASKVEDA-HANDOFF · added 2026-10-17
- [ ] **LAUNCH** · Father copy is a working draft ("mine, not yours") · user · STILL-OPEN §10.1–§10.2 · added 2026-10-17
- [ ] **LAUNCH** · Six parenting "Ask Veda" rows open Brain, not Ask Veda (quick action, two recipe rows, three watch screens, a reco row); route them to `openPpAskVeda` · dev · STILL-OPEN §100.2 · added 2026-10-24

---

## 5. Payments, messaging and money

**Real money** (STILL-OPEN header line 22: §2.1, §2.2, §5.1 block it):
- [ ] **DECIDE** · Attribution across partners, commission rates (seeded at 0), a ledger writer, payouts, settlement, tax, Razorpay Route linked accounts · user · STILL-OPEN §2.1–§2.3 · added 2026-10-17
- [ ] **LAUNCH** · A Directus Flow or form to approve partners (today it's SQL-editor only; "raise this until it is done") · dev · STILL-OPEN §5.1 · added 2026-10-17
- [ ] **LAUNCH** · Booking payments are stubbed (Buy charges nothing); the payout policy (the 7th of the month) is unconfirmed; a no-show still pays · user + dev · STILL-OPEN §5.4d–§5.4f · added 2026-10-17
- [ ] **LAUNCH** · Referral credits still granted on the phone; `paid_by = 'unpaid'` not refused · dev · STILL-OPEN §11.7 · added 2026-10-17
- [ ] **LAUNCH** · Coupon attribution: `expert_id` on `programme_coupons`, a per-sale row, commission sources · dev · STILL-OPEN §13.0 · added 2026-10-17
- [ ] **LAUNCH** · Orders: no webhook past `paid`; no WhatsApp shipping template, though the screen promises one; no returns, refunds, stock or delivery estimate · dev · STILL-OPEN §65.4, §65.9 · added 2026-10-17
- [ ] **CHECK** · Razorpay live keys and merchant KYC: no doc records moving off test mode · user · STILL-OPEN §65.2 · added 2026-10-17

**Messaging:**
- [ ] **BLOCKER** · Phone OTP: `MSG91_AUTHKEY` and `MSG91_OTP_TEMPLATE_ID` secrets, DLT-registered template including the 11-character SMS hash · user · STILL-OPEN §83.12, ONBOARDING.md History A · added 2026-10-17
- [ ] **LAUNCH** · WhatsApp off Meta's test number (Meta verification); Render paid tier · user · CONTENT-BACKEND, ONBOARDING.md History A · added 2026-10-17
- [x] **LAUNCH** · Run migration `0111_wa_weekly_guide_stage.sql`: the weekly WhatsApp guide kept going to a mother after a loss or an early birth (it read `due_date` only, never `life_stage`) · user · global-changes plan, Phase 0 · added 2026-10-23 · **DONE 2026-10-24** (user ran it; it does not cover a loss, see 0112)
- [x] **LAUNCH** · Run migration `0112_wa_weekly_guide_loss.sql`: the weekly WhatsApp guide still went to a mother who reported a loss and stayed in pregnancy (a loss does not change `life_stage`) · user · STAGE-TRANSITIONS B1 · added 2026-10-24 · **DONE 2026-10-24** (user ran it)
- [ ] **BLOCKER** · Cloud row ids collide across users: `journey_timeline`, `ttc_cycles` and `ttc_cycle_signals` are keyed by `id` alone, and the ids are a date or a fixed name, so a second woman's period on the same day never syncs · user decides, then dev (sync work) · STAGE-TRANSITIONS B9, STILL-OPEN §101.9 · added 2026-10-24 · **BUILT 2026-10-24** (sync step 14): run `0113_rows_keyed_per_person.sql`, then its check query (17 rows of `user_id,id`), then install the next build · 0113 RUN 2026-10-25 (check query: 17 rows of `user_id,id`); left: install the next build
- [x] **BLOCKER** · A child's records are not read per child: with twins or two children, each child's page shows both children's growth, milestones, health records and documents, and a vaccine marked done for one reads as done for the other (the care logs are being fixed in sync step 15) · user decides, then dev (sync work) · STAGE-TRANSITIONS B11 · added 2026-10-25 · DONE 2026-10-25 c70a791 (sync step 16; every child pulled too)
- [x] **DECIDE** · Per-pregnancy records (the `pregnancies` table): a pregnancy after a loss shows the lost pregnancy's bump photos, scans and bag · user · STAGE-TRANSITIONS R1, STILL-OPEN §101.1 · added 2026-10-24 · DECIDED and BUILT 2026-10-25 (kept for her, view or delete; sync step 18, 656bbb3)
- [x] **RUN** · Migration `0114_pregnancies.sql` (one row per pregnancy, partner read, on the purge list), then install the next build · user · BACKEND-SYNC-LOG step 18 · added 2026-10-25 · run 2026-10-25; next build still to install
- [x] **RUN** · Migration `0115_pp_food_tries.sql` (the foods a child has tried, shared with the co-parent; guarded; on the purge list), then install the next build. Until it runs, first tries stay on the phone and the push is refused quietly · user · BACKEND-SYNC-LOG step 20 · added 2026-10-25 · run 2026-10-25
- [ ] **LAUNCH** · The partner's phone never sees her stage change or her loss (it reads his own profile row) · dev · STAGE-TRANSITIONS R2, STILL-OPEN §101.2 · added 2026-10-24

**Sponsors** (STILL-OPEN line 21: §11.6 blocks the sponsor programme):
- [ ] **DECIDE** · An email provider (Resend, SES or Postmark), so activation codes have a sender · user · STILL-OPEN §11.6 · added 2026-10-17
- [ ] **LAUNCH** · Every real sponsor has `dev_bypass_code` null (the check SQL is in the doc) · dev · STILL-OPEN §11.6 · added 2026-10-17

**AI costs:**
- [ ] **DECIDE** · A paid LLM tier before launch (Anthropic credit was $0 on 2026-10-13); the Can-I vision key pricing · user · STILL-OPEN §79.12a, §88, §68.1 · added 2026-10-17

---

## 6. App store and release

- [ ] **BLOCKER** · The four website and Play items in §0 (assetlinks, `APP_LIVE`, invite redirect) · website · added 2026-10-17
- [ ] **DECIDE** · `kTtcShelfFilmPreview` (still `true`, `ttc_kind_cards.dart:2133`): "must be off before launch", after you've seen it · user · STILL-OPEN §80.13 · added 2026-10-17
- [ ] **DECIDE** · Does the TTC door sit on the pregnancy home? (a routing decision) · user · TTC-SPEC §8 Q1 · added 2026-10-17
- [ ] **LAUNCH** · Build number bumped automatically (it's manual today), so a stale APK can't ship · dev · STILL-OPEN §5.14 · added 2026-10-17
- [ ] **LAUNCH** · Device walks owed: Google sign-in, Phone Number Hint, OTP on a real device, the never-walked skilling doors, and the REMAINING-CHANGES device checks · user + dev · STILL-OPEN §62.1, §67.4, §69.1, §90.7, §91, §92, §105.3 · added 2026-10-17
- [ ] **LAUNCH** · Bundle the Fraunces and Manrope TTFs for the poster PDF (Devanagari partner names print broken offline) · dev · STILL-OPEN §4.2b · added 2026-10-17
- [ ] **LAUNCH** · TTC launch-sanity items still without a fix note: K1–K5 (calendar), D12, D19; H17 and D13 are decisions owed · dev + user · TTC-LAUNCH-SANITY · added 2026-10-17
- [ ] **CHECK** · The due-date restore before release: it appears restored (`pregnancy_controller.dart:349`); confirm and tick · dev · SESSION doc · added 2026-10-17
- [ ] **DECIDE** · The Developer section's "Stage · testing" chips ship in every build (`kPvShipDeveloperSection = true`, `pv_you_screen.dart:119`, the user's 2026-10-07 ask). They are the only way a parent can move from Parenting to Pregnancy, and they change the stage with nothing else (a parent lands on the old pregnancy at week 40, overdue). Turn the section off for store builds, or keep it and accept that · user · STAGE-TRANSITIONS G1 · added 2026-10-24
- [ ] **LAUNCH** (iOS only) · Apple Developer account ($99/yr ≈ ₹8,300), Sign in with Apple, `Info.plist` URL types, `apple-app-site-association` · user · AUTH-SETUP §4 · added 2026-10-17

---

## 7. Monitoring and operations

**The sweep found nothing in any doc** for crash reporting, uptime alerts or database backups. That's the gap the
2026-10-17 review named: the family timeline's uploads were refused from day one, and nobody could have known.

- [ ] **BLOCKER** · **Crash and error reporting** (for example Sentry, or Firebase Crashlytics, which is free), including **sync failures**: today `PvSyncHealth` sees a refused upload on the phone and tells nobody. Report the store, table and error, never the user's data · user (account) + dev · added 2026-10-17
- [ ] **LAUNCH** · **Uptime alerts** on Ask Veda and the edge functions · user + dev · added 2026-10-17
- [ ] **LAUNCH** · **Backups and PITR** confirmed (see §1) · user · added 2026-10-17
- [ ] **BLOCKER** · Ask Veda hosting: the Railway trial ended and the service is down; pick a host or plan. The Directus → Ask Veda reindex Flow waits on it · user · REMAINING-CHANGES, STILL-OPEN §7.0 · added 2026-10-17
- [ ] **CHECK** · The `LLM_API_KEY` repo secret for the daily model probe (`.github/workflows/llm-smoke.yml`) · user · STILL-OPEN §79.12a · added 2026-10-17
- [ ] **CHECK** · Images: `kReadImageBase` already points at R2, so the upload may be done. Door heroes are still Unsplash hotlinks, and `pub-*.r2.dev` is rate-limited, so use a custom domain for production · user · STILL-OPEN §70.3, CONTENT-BACKEND · added 2026-10-17
- [ ] **LAUNCH** · Directus host: Render's free tier sleeps and its disk is ephemeral; move to the paid tier at go-live · user · CONTENT-BACKEND · added 2026-10-17
- [ ] **LAUNCH** · Funnel analytics beyond the tab tap · dev · STILL-OPEN §65.9 · added 2026-10-17
- [ ] **LAUNCH** · Notifications: `syncAll` cancels everything, so each scheduler must join the launch chain (the real fix is owed); notification taps don't open their destination · dev · BACKEND-PATTERNS §16m, STILL-OPEN §79.2, §79.14(b) · added 2026-10-17
- [ ] **LAUNCH** · Phone walk of the 2026-10-20 batch: Cycle Companion ring and temperature card, the plan's week and reminders (set one, restart the phone, it still rings), the intro pop-up, the article service card · user + dev · STILL-OPEN §96 · added 2026-10-21

---

## 8. Content gaps (not gates in the docs' own words; listed so they're decided, not forgotten)

- [ ] **DECIDE** · Ship with placeholders or hold: the 45 Garbh Shravan tracks, every yoga video, week pages 1–4 and 24–40, FAQ Month 9, the 373 shortlist products' prices and photos · user · DOOR-CONTENT-OWED, STILL-OPEN §84, §86, §88, §89, §91 · added 2026-10-17
- [ ] **DECIDE** · Recordings and discussion groups are sold on the buy sheet but not built (the copy is kept deliberately) · user · STILL-OPEN §5.2 · added 2026-10-17
- [ ] **LAUNCH** · The HR web portal is unbuilt, and must not be Directus · dev · ADMIN-PANEL §7a, STILL-OPEN §11.1 · added 2026-10-17
- [ ] **CHECK** · The user's review of the 90 rewritten myth boxes and the four paragraphs added to `preg_diet_read_food_myths` (claude.ai/artifact/Fj8i53uDYF4Cdtr6ZKoN4x) · user · STILL-OPEN §96.6 · added 2026-10-21
- [ ] **CHECK** · A doctor reviews the IVF and IUI step facts (how long, does it hurt, what to ask) in `lib/ttc/ttc_treatment_journey.dart` · user + clinician · STILL-OPEN §97.3 · added 2026-10-22
- [ ] **CHECK** · The 16 IVF and IUI step films are filmed, or ship as notes-only placeholders (a DECIDE with the other content gaps above) · user · DOOR-CONTENT-OWED TTC3 · added 2026-10-22

---

## Done

(Ticked items move here with their date, oldest first.)

- 2026-10-17 · Migration 0100 (server-side newer-wins guard) run by the user · §1
- 2026-10-17 · Migration 0101 (Parenting logs sync clock and guard) run and checked by the user, six of six tables · §1
- 2026-10-18 · Migration 0104 (Parenting records sync clock, soft delete, guard, shared reminder time) run and checked by the user, 11 of 11 tables · §1
- 2026-10-20 · Migration 0105 (child profile + name votes: clock, soft delete, guard) run by the user · §1
- 2026-10-21 · Migration 0106 (Pregnancy part 1: clock, soft delete, guard, the father_missions UPDATE policy) run and checked by the user, 9 of 9 tables · §1
- 2026-10-21 · Migration 0107 (Pregnancy part 2: clock, soft delete, guard, medications.alarms, symptom severity 'strong') run and checked by the user, 10 of 10 tables · §1
- 2026-10-21 · Migration 0108 (affiliate fields on products: asin, price_checked_at, ext_rating, ext_review_count) run by the user · §1

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
- [ ] **LAUNCH** · Run `supabase/migrations/0101_pp_logs_sync_clock.sql` (Parenting logs: clock, soft delete, guard) · user · sync log step 5 · added 2026-10-17
- [ ] **LAUNCH** · The two-phone walk for step 5, both parents on one child: log a feed on A, delete it on B, sync A, check it stays gone; correct the other parent's feed, check "logged by" does not change · user + dev · sync log step 5 · added 2026-10-17
- [ ] **LAUNCH** · Pregnancy and Parenting row stores still bring deleted data back (~30 tables, union merge, hard deletes) · dev · STILL-OPEN-BACKEND §1 · added 2026-10-17 · *2026-10-17: the six Parenting logs are fixed (step 5, 0101 to run); left: Parenting documents, health, milestones, vaccines, and all of Pregnancy*
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
- [ ] **LAUNCH** · Recipes mirror and incremental Ask Veda ingest (28 new dishes missing; the retired `tomatocarrotsoup` still published). In progress in another terminal · dev + user · STILL-OPEN §65.1 · added 2026-10-17
- [ ] **LAUNCH** · Live load of the pregnancy FAQs (export, import, ingest, deploy) · user · STILL-OPEN §88.0 · added 2026-10-17
- [ ] **LAUNCH** · Ask Veda has no parenting corpus, week pages or phase docs (a two-repo change) · dev · STILL-OPEN §82.7, §84, §85 · added 2026-10-17
- [ ] **LAUNCH** · The `export-my-data` edge function isn't built (the row says "Coming") · dev · STILL-OPEN §67.1 · added 2026-10-17
- [ ] **LAUNCH** · The partner-sharing switch is local only; the server ignores it until it's a `profiles` column · dev · STILL-OPEN §67.2 · added 2026-10-17
- [ ] **LAUNCH** · Content edits have no history ("last write wins, silently"); an audit trigger is owed · dev · STILL-OPEN §7.2 · added 2026-10-17
- [ ] **CHECK** · The three `service_role` grants (recipes, reads, products): STILL-OPEN §80.15 says owed, REMAINING-CHANGES says done · user · added 2026-10-17
- [ ] **CHECK** · Was the demo re-seeded after 0089? Unknown · user · STILL-OPEN §5.4k · added 2026-10-17

---

## 2. Security and privacy

- [ ] **LAUNCH** · The skilling journal's AES key sits in `shared_preferences` beside the data; move it to the platform keystore (`flutter_secure_storage`). Needs the user's OK for the dependency · dev · STILL-OPEN §103.3, §105.3 · added 2026-10-17
- [ ] **LAUNCH** · `care_partners.trust` is unconstrained `jsonb`; only the website's allowlist stops an advertising label under a doctor's name · dev · STILL-OPEN §4.2 · added 2026-10-17
- [ ] **LAUNCH** · The Directus presentation pass before anyone else gets a login: `brand_sample_claims` would name rows by home address · user · STILL-OPEN §7.1, DIRECTUS-SETUP §1b · added 2026-10-17
- [ ] **LAUNCH** · Expert registration numbers really checked before a clinician goes live (`kTtcRegistrationChecksRecorded = false`) · user · STILL-OPEN §16.0 · added 2026-10-17
- [ ] **CHECK** · The email templates carry `{{ .Token }}` and OTP length is 6, at least for the doctor app's magic link. Nothing marks it done · user · AUTH-SETUP §3b · added 2026-10-17
- [ ] **CHECK** · Server-side rate limit on the SMS send (per phone, per IP). BACKEND-PATTERNS describes a rule; confirm it's live · dev · ONBOARDING-AUDIT · added 2026-10-17
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
- [ ] **BLOCKER** · Symptom cards for weeks 5–23 ("require medical review before publishing"; shipped on the user's word) · clinician · STILL-OPEN §84 · added 2026-10-17
- [ ] **LAUNCH** · Paediatric panel sign-off on each phase's doctor lines, milestones and activities · clinician · STILL-OPEN §85 · added 2026-10-17
- [ ] **LAUNCH** · 39 held pregnancy FAQs (bleeding, ectopic, preeclampsia and others); fetal dopplers and herbal teas held · clinician · STILL-OPEN §88, §89 · added 2026-10-17
- [ ] **LAUNCH** · Can-I trimester notes; `kFoodValues` (dietitian); the Ready-to-Try test list and folic acid wording; regional food blocks · clinician + dietitian · STILL-OPEN §68.5, §70, §92 · added 2026-10-17
- [ ] **LAUNCH** · The 14 tip sources and a view on paediatrician overrides · clinician · STILL-OPEN §9.1b · added 2026-10-17
- [ ] **LAUNCH** · ₹ scan-cost ranges in `scan_extras.dart` · clinician · LEVEL-MAP-STATE, PROBLEM-HUB-AUDIT · added 2026-10-17
- [ ] **LAUNCH** · A faith read-through of the spiritual content; WEB verses checked against a printed WEB · user arranges · STILL-OPEN §86 · added 2026-10-17
- [ ] **DECIDE** · Every pregnancy read is `reviewed: false`, and Ask Veda grounds answers in them; decide whether that can ship · user · PREGNANCY-ASKVEDA-HANDOFF · added 2026-10-17
- [ ] **LAUNCH** · Father copy is a working draft ("mine, not yours") · user · STILL-OPEN §10.1–§10.2 · added 2026-10-17

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
- [ ] **BLOCKER** · Phone OTP: `MSG91_AUTHKEY` and `MSG91_OTP_TEMPLATE_ID` secrets, DLT-registered template including the 11-character SMS hash · user · STILL-OPEN §83.12, ONBOARDING-AUDIT · added 2026-10-17
- [ ] **LAUNCH** · WhatsApp off Meta's test number (Meta verification); Render paid tier · user · CONTENT-BACKEND, ONBOARDING-AUDIT · added 2026-10-17

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

---

## 8. Content gaps (not gates in the docs' own words; listed so they're decided, not forgotten)

- [ ] **DECIDE** · Ship with placeholders or hold: the 45 Garbh Shravan tracks, every yoga video, week pages 1–4 and 24–40, FAQ Month 9, the 373 shortlist products' prices and photos · user · DOOR-CONTENT-OWED, STILL-OPEN §84, §86, §88, §89, §91 · added 2026-10-17
- [ ] **DECIDE** · Recordings and discussion groups are sold on the buy sheet but not built (the copy is kept deliberately) · user · STILL-OPEN §5.2 · added 2026-10-17
- [ ] **LAUNCH** · The HR web portal is unbuilt, and must not be Directus · dev · ADMIN-PANEL §7a, STILL-OPEN §11.1 · added 2026-10-17

---

## Done

(Ticked items move here with their date, oldest first.)

- 2026-10-17 · Migration 0100 (server-side newer-wins guard) run by the user · §1

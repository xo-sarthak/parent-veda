# ParentVeda+ (the doctor app) — audit and rework plan

*Written 2026-09-18. Mobbin audit #8. All seven questions answered the same
day. **BUILT the same evening, and WALKED** on the phone (all five tabs;
six fixes from the walk, listed in STILL-OPEN §5.4). The sign-in screens are
the one thing not yet seen on a device. §6 at the end = what landed.*

**The ask.** The doctor app exists (`lib/main_doctor.dart`, `--flavor doctor`)
and works, but it looks like the classic parent app — violet everywhere, a
purple-gradient money card, small type — and it does not do the one thing that
makes a doctor trust a platform: show them, transparently and itemised, what
they have earned from what, at what cut, and when it will be paid. The user
wants a rework: modern but plain, easy to read for a clinician in their
forties or fifties, with an in-app "admin panel" of earnings across every way
a doctor makes money here (consultations, masterclasses, cohorts, recorded
courses, videos made through our channel, referrals), plus a home screen that
says what needs attention and what is coming, appointments, joining classes,
and availability that is trivial to set and pause.

---

## 1. What exists today (read before touching it)

| Piece | File | State |
|---|---|---|
| Entry + boot | `lib/main_doctor.dart` | Good. Five stores, identity from the server, no dropdown. Keep. |
| Sign in | `screens/doctor/doctor_auth_screen.dart` | Email + password. Account must already be linked in `expert_accounts` — by SQL today. |
| Shell | `doctor_scaffold.dart` | 5 tabs: Home · Appointments · Availability · Impact · Profile. `ppPurple` active tab, `ppBg` ground — pre-dates the base-UI rule. |
| Home | `doctor_home_screen.dart` | Header, testing stage toggle, stat row, upcoming calls, sessions, availability card. Structure fine, look classic. |
| Appointments | `doctor_appointments_screen.dart` | Today / Upcoming / Past, past surfaces prescriptions owed. **Structure is right.** |
| Availability | `doctor_schedule_screen.dart` + `doctor/doctor_schedule.dart` | **Model is right** (sessions per weekday, rules, time off, date overrides, pause) and saves to `doctor_schedule`, which the parent side reads. The **screen** is a three-section editor of chips and steppers. |
| Impact | `doctor_impact_screen.dart` / `_tab.dart` | Aggregate referral counts from `partner_impact()`; Earnings one tap inside. |
| Earnings | `doctor_earnings_screen.dart` + `doctor/doctor_earnings.dart` | **Computed on the phone**: consult bookings × catalogue price × `kDoctorSharePct = 0.80`. Consults only. No masterclass, cohort, course or video money. "Set up payouts" is a snackbar. Purple gradient hero. |
| Onboarding | `doctor_onboarding_screen.dart` | Walkthrough that saves nothing (STILL-OPEN §12.3, blocked on Directus). |
| Prescription, referral kit, QR poster | `doctor_prescription_screen.dart`, `doctor_referral_kit_screen.dart`, `care_poster_screen.dart` | Work. Keep, restyle only. |

**What the database can say about a doctor's money today: almost nothing.**

- `booking_bookings` has **no amount column**. What a parent paid is looked up
  from the catalogue on the phone at display time, so a price change rewrites
  history.
- `programme_experts` has **no share column**. A masterclass host's cut does
  not exist anywhere.
- The 80% lives in a **Dart constant**. No per-doctor deal, no volume tier
  (the Commercial Terms workbook says 85% above 20 sessions a month —
  STILL-OPEN §13.0).
- `care_commission_rules.rate_bps` is capped at 50% — right for a *referral*
  commission, wrong for a *delivery* share. §13.0 already concluded they are
  two tables.
- There is **no payouts table**, no settlement status, no statement.
- Booking payment is still stubbed (Buy mints an entitlement and charges
  nothing). The other terminal's Razorpay functions are for **products/orders**
  (`0083`), not bookings.

So "transparent earnings" is a backend build first and a screen second. A
screen over a client-side constant would be a prettier version of the same
untrustworthy number.

---

## 2. Mobbin — what was searched, what was found

Queried 2026-09-18 by flow/description. Provider-side apps in the library:
Airbnb (host), Turo (host), DoorDash Dasher, Fiverr, Upwork, Airtasker,
Jobber, Future Pro (coach side), Posh, Luma, OpenPhone, Swarm, Linktree, Slack.
**Not in:** Uber Driver (falls through to the rider app), Practo, Doctolib,
Fresha, Booksy, Square Appointments, Calendly.

| Question | Reference | The decision it carries |
|---|---|---|
| Provider home | [Airbnb host Today](https://mobbin.com/flows/44b957df-0c8c-4a6d-bcd1-1ab5b5c33f36) · [Future Pro coach home](https://mobbin.com/screens/2b5839c4-0519-4df7-9341-bd7fd3a0f60b) | Greeting → **one blocker card at the top** ("Account info is needed — Required to get paid") → the next thing as a big card with its two actions → "Your next steps". Attention first, then time. |
| Earnings overview | [Turo Business › Earnings](https://mobbin.com/screens/eb3cbd96-13be-4073-9c23-5ea6a38f0b3e) · [Cash App key stats](https://mobbin.com/screens/dc7db548-1b0b-4980-b7f0-779609a93904) | One big "earned in <period>", then a **legend of sources with an amount each** (trip · upcoming · reimbursements · incentives · missed). Cash App: total → net → count, fees named in one line. |
| Per-item statement | [Turo host receipt](https://mobbin.com/flows/c79e1003-c04a-4de4-8e62-4b0436baa88e) · [alias sale breakdown](https://mobbin.com/screens/97f87d71-214e-4d9e-8772-5391e21493b2) | Printed-receipt grammar: price → fee (with **one sentence saying what the fee is for**, and the percentage) → **YOU EARNED**. |
| Payouts | [Turo transaction history](https://mobbin.com/screens/7ae17c22-0184-4155-91bc-d0a562cd26df) · [DoorDash payout history](https://mobbin.com/screens/532cce0a-6c20-4fe1-90dd-ec2acb02f71a) · [Upwork statement](https://mobbin.com/screens/fd723811-5779-4de4-85a0-56c505e8651b) · [Airtasker](https://mobbin.com/screens/324da200-b2f5-4d3f-a58b-ab9f4ace93ee) | **"We owe you ₹X · Next payout <date>"** — the plainest money copy found. DoorDash names the lag ("deposits in 2–3 business days"). Upwork: statement period + category filter, fees as their own negative lines. Airtasker: CSV export. |
| Availability | [OpenPhone business hours](https://mobbin.com/screens/72182039-391a-4fd8-9f5f-6f987e6bd15b) · [Swarm hours](https://mobbin.com/screens/cc52684e-8a19-4232-8e1f-2e21ddca13a0) · [Linktree availability](https://mobbin.com/screens/34e1efc7-cebf-4deb-8b44-e6218737aae5) | **Seven rows, one per day, hours or "Closed all day", chevron.** One master switch at the top. Swarm's "Edit Mon–Fri / Edit Sat–Sun" shortcuts. Rules (buffer, notice, window) on a second screen, not beside the days. |
| Working day | [Jobber today's appointments](https://mobbin.com/screens/f50ec472-c3f8-4bdc-8bd5-dbd856936025) · [Apple Store upcoming](https://mobbin.com/screens/010ffa81-7808-4692-8140-09b04cf01a65) | Segments Completed / Active / To go; one card shape; dated list. Confirms our Today/Upcoming/Past. |
| Class host view | [Posh event overview](https://mobbin.com/screens/f5323054-01d7-4174-b79c-dae33cde6b96) · [Luma manage event](https://mobbin.com/screens/3b8c4f96-7cfe-44a4-9b1f-0f18ccc678ce) | Seats sold / capacity, sales timeline, then a plain list of actions. A host manages a class from one page. |
| Front door | [Slack logging in](https://mobbin.com/flows/de477ac6-8b59-412c-9970-5d019c540254) | Email → "Check your email" / six-character code. No password to invent. "Use password" as the fallback, not the default. |

**Declined.** Charts as the primary view (Fiverr, Revolut Business, Turo's
bar chart) — a 45-year-old clinician wants the number and the list, not a
curve; a chart may sit *under* the legend later. Dark money screens (Revolut,
alias) — off-brand. Gamified rewards (TikTok monetisation, Commons) —
nothing to gamify. Ratings/performance tabs (Turo "All-Star host") — we do not
rank doctors against each other; the truth hierarchy puts the clinician above
us, not the other way round.

---

## 3. The plan

### Phase 0 — the money model (backend; the real work)

**Principle.** A statement is a record of *what happened*, not a recomputation
of what the rules say now. Every number a doctor is shown must come from a
row that was written when the event occurred, with the rate that applied
*then* frozen into it. That is the difference between a ledger and a report;
the current Earnings screen is a report over a constant.

Three tables, all reached through `my_expert_ids()` like every other gate:

```
expert_share_rules      the deal — source × (expert override) × tier
  source        consultation | masterclass | cohort | course | video | referral | other
  expert_id     null = platform default; set = this doctor's deal
  min_monthly   tier floor (0; 20 for the 85% consult tier)
  share_bps     0..10000  — NOT capped at 50%; a delivery share is not a commission
  effective_from / effective_to

expert_earnings         the ledger — append-only, one row per money event
  id, expert_id, source, ref_kind (booking|order|programme|manual), ref_id
  occurred_at
  gross_paise           what the parent paid, at the time
  share_bps             the rate that applied, FROZEN
  expert_paise          gross × share, computed at write, stored
  platform_paise        the rest
  status                accrued | payable | paid | reversed
  payout_id             null until settled
  note                  "Video: Sleep basics — fixed fee" for manual rows
  reversal_of           set on a reversal row; the original is never edited

expert_payouts          the settlement — one row per transfer
  id, expert_id, period_from, period_to, amount_paise
  status                scheduled | processing | paid | failed
  paid_at, method (manual_neft | razorpay_route), reference (UTR / transfer id)
  bank_last4
```

Why three and not one: rules change (a doctor negotiates 85%), earnings must
not (last month's statement cannot move), and payouts group many earnings into
one bank transfer that either lands or fails as a unit. Each has a different
lifetime and a different writer.

**Writers.**
- `accrue_expert_earning()` — a `SECURITY DEFINER` function, called by a
  trigger on `booking_bookings` when a booking is confirmed. Writes `accrued`.
  When real payment capture exists it flips `accrued → payable`. Two statuses
  so it is correct both now (payment stubbed) and later.
- `settle_my_bookings()` (`0078`) already knows a no-show; it gains a reversal
  row rather than an UPDATE.
- Manual entries (videos, a fixed fee) — admin-only, through Directus, with a
  mandatory note. The doctor sees the note.
- Payouts are **manual first**: an admin marks a period paid with a UTR.
  Razorpay Route (KYC per doctor) comes after; the table shape does not change.

**Readers.** `my_earnings_summary(period)`, `my_earnings(period, source)`,
`my_payouts()`, `my_payout(id)`. Aggregates for an organisation, breakdown by
doctor beside it — the `sponsor_dashboard` shape, again.

**Seed rates** come from the Commercial Terms workbook (§13.0): consultation
8000 bps, 8500 above 20/month; course 7000 through our channels, 4500 via the
expert's own coupon; multi-expert +2000 to the code holder. **Zero is seeded
until the user confirms** — the same reason `care_commission_rules` seeds zero:
an invented percentage in front of a doctor is worse than a blank.

`booking_bookings` gets no amount column; the ledger carries the gross. A
migration under the next free number *after* the other terminal's (`0083` is
theirs; **ask before taking `0084`**).

**Videos — the workflow (decided 2026-09-18).** There is no YouTube channel
yet, so no videos and no video money; the user wants the *flow* to exist so
that when there is, the only inputs are **a link and a percentage**. So:

```
expert_videos           the capability record — one row per film made with a doctor
  id, expert_id, url, title, share_bps, added_at, retired_at
```

- Admin adds the row in Directus: paste the link, type the doctor's share.
  That is the whole onboarding of a video.
- Money arrives monthly, by hand, because there is no ad-revenue API we
  should trust for payouts: admin reads the video's revenue for the month
  from YouTube Studio and calls `accrue_video_earning(video_id, period,
  gross_paise)`. The function looks up `share_bps` **at that moment**,
  freezes it into the `expert_earnings` row (`source = 'video'`,
  `ref_kind = 'video'`, `ref_id = the video`), and never reads it again.
- The doctor's Earnings screen shows **Videos** as a source like any other:
  the row lists each film with its link, and each month's receipt reads
  "Video earned ₹ / your share (x%) / you earned ₹". Empty state until then:
  *"No videos yet. When ParentVeda films with you, each one appears here with
  its share."*
- Nothing else is special-cased. A video is a `ref_kind`; the ledger,
  payouts, statements and the screen are the same code as a consultation.

### Phase 1 — base UI on the doctor shell

Apply DESIGN-SYSTEM §4.0 exactly: white ground, Newsreader + Manrope, ink
pill for the one commit button, violet only as eyebrow/link/switch/verified
mark, nav per §4.9 (neutral, labels always on, filled icon + `action` for the
active tab, no container). One `doctor_chrome.dart` holding the shared pieces
(page header, section head, list row, stat pair, blocker card, receipt line),
the way `onboarding_chrome.dart` does for onboarding. `pp_common.dart` is not
touched.

**For the audience:** body 15–16 not 12.5; meta 13 not 10.5; tap targets ≥ 48;
no gesture-only actions; every list row has a chevron; numbers in `₹1,20,000`
Indian grouping. This is the one place the design system is *tightened*, not
loosened.

### Phase 2 — the screens, in build order

1. **Sign in.** Email → six-digit code (Supabase `signInWithOtp`,
   `shouldCreateUser: false` — the server refuses an email nobody provisioned,
   which is the "no verification, just in" the user described, done safely).
   New `expert_invites(email, expert_id)`; a trigger links `expert_accounts` on
   first sign-in, so onboarding a doctor becomes one Directus row and the SQL
   in `main_doctor.dart`'s header goes away. Unknown email → "This email isn't
   registered with ParentVeda+" and a WhatsApp/email line to us. Password
   stays as the fallback link.
2. **Home** (Airbnb host + Future Pro). Greeting · **Needs your attention**
   (payout account not set · prescription owed · class starts in 30 min ·
   booking to confirm — each a row with one action) · **Next up** as a big card
   with Join/Prepare · rest of today · **This week** stat pair (calls, classes,
   earned, "we owe you") · one line "Taking bookings · Mon–Sat" with the pause
   switch. Stage toggle stays, under Profile → Developer.
3. **Appointments.** Keep Today/Upcoming/Past. Classes appear in the same day
   list as consults — a masterclass is a booked hour. Bigger card, one shape.
4. **Classes** (from Home and Profile, not a tab). Posh/Luma: each programme I
   host — seats sold / capacity, next session, "Start class" via
   `open_session_room()` (exists, `0079`), attendee first names only.
5. **Availability** (OpenPhone/Swarm). Master switch "Taking bookings" · seven
   rows · tap a day → sheet listing its sessions with Add/Remove · "Same hours
   Mon–Sat" shortcut · Time off as a list with Add · "Consultation rules" as
   one row to a second screen · the live preview stays at the bottom, it is
   the reason a doctor trusts the screen. The model does not change.
6. **Earnings — the admin panel** (Turo + Cash App + DoorDash).
   - Top: **"We owe you ₹X"** · "Next payout <date>" · period selector (this
     month / last month / this year / all time).
   - **By source**: Consultations · Masterclasses · Cohorts · Courses · Videos ·
     Referrals — each a row: amount, count, the rate in words ("80% of ₹…").
     Empty sources still render, with "Nothing yet from …" — a feature is
     never hidden, and the empty row is the advertisement.
   - Tap a source → itemised list → tap an item → **receipt**: Parent paid ₹ /
     ParentVeda fee (20%) −₹ with the one sentence / **You earned ₹** / status.
   - **Payouts** segment: scheduled / processing / paid, each → the items it
     contained, the UTR, the bank last4.
   - **Statement**: monthly CSV/PDF share (Airtasker). A doctor's accountant
     needs this more than the doctor does.
   - Referral impact (the aggregate families count) lives inside Referrals here;
     the separate Impact tab goes (see Q1).
7. **Profile.** What parents see (name, credential, fee, photo) · Payout
   account (form → a verification queue, never live on save) · Notifications ·
   Referral kit · Developer (stage toggle, version) · Sign out.

Tab set: **Home · Appointments · Availability · Earnings · Profile** — five,
treatment identical to the parent nav.

### Phase 3 — first-run setup

Not the five-step walkthrough. On first sign-in, three rows on Home's
attention stack: confirm your profile · set your hours · add a payout account
(Airbnb's "Required to get paid"). Each row disappears when done; nothing
blocks the dashboard. The document/KYC walkthrough stays parked on Directus
(§12.3) — an upload with nowhere to go is a submission to nowhere.

### Phase 4 — build, walk, ledger

`flutter build apk --release --flavor doctor -t lib/main_doctor.dart`; clear
the stale-`libapp.so` intermediates first (session ledger). **Device only when
the user says so** — the other terminals hold it. Then the MOBBIN-DISCOVERY
row flips to built.

---

## 4. Cross-path with the other terminals — hold points

- **Payments.** `booking/payment_service.dart`, `supabase/functions/razorpay-*`,
  `0083` are theirs and are about products/orders. My ledger writer hooks
  `booking_bookings`, not `orders`. The one shared future seam is "payment
  captured → `accrued` becomes `payable`"; that hook is written as a function
  they can call, not an edit to their file.
- **Migration numbers.** `0084` may be theirs. Ask.
- **`pp_common.dart`** — not touched; the doctor app gets its own chrome file.
- **Device** — not touched until told.
- **`docs/STILL-OPEN.md`** — shared; doctor sections are §5.x and §13.0, theirs
  are §100+.

---

## 5. Questions for the user (answers change the build)

1. ~~Earnings replaces Impact as a tab?~~ **DECIDED 2026-09-18: yes.**
   Earnings is the tab; the families count lives inside Referrals.
2. ~~Videos through our channel — how is the money computed?~~ **DECIDED
   2026-09-18: a workflow, not a formula.** No channel exists yet; the flow
   needs only a link and a percentage per video, and monthly revenue typed in
   by admin. Written up under Phase 0, "Videos — the workflow".
3. ~~Seed the rates from the Commercial Terms workbook?~~ **DECIDED
   2026-09-18: seed PLACEHOLDERS so the build works; the user will send the
   workbook and the numbers get replaced.** The placeholder seed, every row
   flagged `note = 'PLACEHOLDER — awaiting Commercial Terms workbook'`:

   | source | share_bps | basis |
   |---|---|---|
   | consultation | 8000 (8500 above 20/month) | §13.0's memory of the workbook |
   | masterclass | 7000 | assumed = course, via our channels |
   | cohort | 7000 | assumed = course |
   | course (recorded) | 7000 / 4500 via own coupon | §13.0 |
   | video | 5000 | pure assumption |
   | referral | unchanged — `care_commission_rules`, still zero | §2.2 |

   `expert_share_rules.note` exists for exactly this: a number a doctor is
   shown carries where it came from. The screen shows the percentage, never
   the note.
4. ~~Payouts manual first, Razorpay Route after KYC?~~ **DECIDED 2026-09-18:
   manual first.** Short form: no inbound money yet, rates unconfirmed, KYC
   is its own product, ten doctors is a spreadsheet; the `expert_payouts`
   row is shaped for Route already, so switching later adds a webhook
   writer, not a migration. Written up as BACKEND-PATTERNS §16f.
5. ~~Sign-in by email code, password as fallback?~~ **DECIDED 2026-09-18: yes.**
6. ~~Show the parent's gross on every receipt?~~ **DECIDED 2026-09-18: yes.**
7. ~~Migration number~~ **DECIDED 2026-09-18: `0084` is ours.**

---

## 6. What was built (2026-09-18, the same evening)

| Piece | File | Notes |
|---|---|---|
| The ledger | `supabase/migrations/0084_expert_earnings.sql` | `expert_share_rules` · `expert_earnings` · `expert_payouts` · `expert_videos` · `expert_payout_accounts` · `expert_invites`; the booking trigger; `book_slot` gains `price_paise`; six readers; three admin writers. **Written, not run** — the user applies it. |
| The store | `lib/doctor/doctor_ledger.dart` | Local-first over the readers; caches per expert; `savePayoutAccount` is loud. |
| The chrome | `lib/screens/doctor/doctor_chrome.dart` | §4.0 with type and targets tightened for 40+; reuses `ObPrimary`/`ObSecondary`, `PvPress`, the palette. Never `pp_common`. |
| Sign in | `doctor_auth_screen.dart` | Email → six-digit code (`signInWithOtp` / `verifyOTP`), password as the fallback link; `claimInvite()` before resolve. |
| Home | `doctor_home_tab.dart` | Attention stack · next consult as a card · later today · this week · your classes · the bookings switch. |
| Appointments | `doctor_appointments_tab.dart` | Today/Upcoming/Past kept; classes in the day list; cancel/no-show through the server, reported on its answer. |
| Classes | `doctor_classes_screen.dart` + `doctor_class_launch.dart` | The host's "may I go live" rule in one place. |
| Availability | `doctor_availability_tab.dart` | Seven rows, a day sheet, "same hours everywhere", rules on their own screen, time off, the live preview. Model unchanged. |
| Earnings | `doctor_earnings_tab.dart` · `doctor_source_screen.dart` · `doctor_payouts_screen.dart` · `doctor_payout_account_screen.dart` | We owe you · blocker · period · by source (every source renders) · itemised → receipt · payouts → detail · CSV statement. Referrals row opens the existing Impact screen. |
| Profile | `doctor_profile_tab.dart` | What parents see (read-only) · payout account · classes · referral kit · practice setup · Developer (stage toggle) · sign out. |
| Shell | `doctor_scaffold.dart` | Five tabs on `PvNavBar`. |
| Tests | `test/doctor_app_shell_test.dart` · `test/doctor_tabs_render_test.dart` | Reachability, the RPC/column contract against the SQL, no-money-on-the-phone, formatting, every tab at 360dp logged out. `content_migrations_test` allow-list carries the six tables with reasons. |
| Docs | BACKEND-PATTERNS §16f · DIRECTUS-SETUP §4c · STILL-OPEN §5.4, §13.0 | |

**Owed** — STILL-OPEN §5.4a–i. The two that gate a demo: run `0084`, and
put `{{ .Token }}` in the Magic Link template.

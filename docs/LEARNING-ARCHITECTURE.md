# Learning architecture: courses, masterclasses, cohorts, live and recordings

**Written 2026-10-29** from the L1 audit (plan: `learning-architecture-audit.md`, detail in
`course-receipts-then-community-p2.md`). The audit was read-only. Every recommendation in §4 was **accepted by the
user on 2026-10-29** ("go with all the recommendations": industry standard, don't deviate). The prototype was signed off the same day, and the user added one requirement: **Your bookings is the one history** of what she has booked and bought, the same in every stage (L.22, LA-27).

**Read in order.**
1. The map: what exists and who decides each part.
2. The model.
3. The checklist.
4. The decisions.
5. The issue ledger: the list of what is left, ticked off pass by pass.
6. The costs.
7. How the work runs.

**Why this file exists.** Nothing on the learning side is live yet: no recorded masterclass and no live session. The
user wants the first real masterclass, course or cohort to be **plug and play**: add a `programmes` row and its
sessions, upload a video, and nothing else. This is the moment to get the shape right, before real money and real
data make every change a migration of someone's purchase.

---

## 1. The map: who decides what (as found, 2026-10-28)

**The one-line summary.** The **phone** decides price, whether she paid, what she owns, session times and attendance.
The **server** decides seats, the LiveKit room and its join window, and moderation. Everything in §5 moves a decision
from the first list to the second.

**Why that matters (the general fact).** Anything the phone decides, the person holding the phone can change. Prefs
can be edited, requests can be replayed, and a modified app sends what it likes. The server is the only party
the user cannot rewrite, so anything worth money or privacy must be decided there. The phone's copy is a **cache** of
the server's answer, never the answer.

### Catalogue and products

| Piece | Where | Decides |
|---|---|---|
| What an offering is (`Offering`, `OfferingKind`, `EntitlementGrant`) | `lib/booking/booking_models.dart:55-181` | Phone |
| Offerings are derived from display models | `lib/booking/booking_catalog.dart:274-305` (learn), `:335-366` (Prepare) | Phone |
| A recorded course | The builder returns `null`, so a course has no offering | Nobody: **a course cannot be sold today** |
| Class packs | Yoga `booking_catalog.dart:247-258`, TTC `:372-401`, Mind and Mood `:422-448` | Phone |
| Lessons vs sessions | `PvLearnLesson` (has `videoUrl`) and `PvLearnSession` (free-text `when`), `lib/data/learn/pv_learn_view.dart:73-100` | Phone |
| The server catalogue | `programmes`, `programme_sessions`, `programme_experts`, `programme_coupons` (`0054_programmes.sql`), the view `programmes_published` (`0056`), age window (`0124`) | Server, **but the app uses only the label and status** |
| Price | `programmes.price_paise` (0054:58). It becomes the label "₹1,499" (`programme_store.dart:93-100`), and `booking_catalog.dart:713-717` turns the label back into paise. Bundled Dart strings too (`pp_learning_data.dart:272…`) | Phone. The server price round-trips through a display string |

### Money

| Piece | Where | Decides |
|---|---|---|
| Free | `payment_service.dart:79`: `amountMinor <= 0` returns `free` without calling the server | Phone |
| Price charged | `razorpay-create-order/index.ts:82-98` charges the client's `amountMinor` for an `offeringId`. Shop `lines` are priced from `products` (:40-63), falling back to the client amount (:93) | **Phone** for courses |
| Auth on the payment functions | Both are deployed `--no-verify-jwt` (create :21, verify :128), and neither reads a JWT | Nobody: anonymous endpoints |
| Verify | `razorpay-verify-payment/index.ts:175-180`: HMAC check, then `{valid}` | The phone decides what the payment bought |
| Receipt | None. `BookingStore.purchase()` mints into prefs and the user_state blob (`booking_store.dart:320-340`); called from `pv_learn_flow.dart:75,83,97` | Phone |
| No-charge preview | `notConfigured` counts as success (`pv_learn_flow.dart:484-485`; `pv_checkout_screen.dart` ~:100). Nothing checks for a release build | **Phone, even in a release build** |
| Shop orders | `orders` (`0083:95-111`), client-written through `pv_order_store.dart:278`. RLS lets the owner set `status='paid'` (`0083:126-132`); no unique `payment_id` | Phone |
| Refunds | `refund_window_hours`, `refund_void_on_recording` (0054:78-81) are read by nothing. The copy promises three different rules (`pv_offering_content.dart:304-632`) | Nobody |
| Expert earnings | `expert_earning_from_booking` (0084:371-420): gross = the booking's `price_paise` = the client's `p_price_paise` | Phone |
| Consult credits (the good pattern) | `consult_credits` (0066:101): one row per credit, no client write, granted by `grant_consult_credits` (not callable by users), spent by attaching a `booking_id` under a unique index | Server |
| Sponsor credits | `confirm_sponsor_activation` → `grant_consult_credits` (0067:200) | Server |
| Referral credits | `referral_store.dart:243` → `grantFloatingCredit`, local blob only | Phone |

### Seats and schedule

| Piece | Where | Decides |
|---|---|---|
| `book_slot` (last definition) | `0084_expert_earnings.sql:73-132` (earlier: 0029:100, 0066:336) | Server for seats; phone for everything else |
| Slot creation | The first caller creates the slot with its own expert, start, capacity and join URL (0084:98-103) | **Phone** |
| Seat lock, full, already booked | `FOR UPDATE`, 0084:105-119 | Server ✓ |
| Payment check in `book_slot` | None, in any version | Nobody |
| **Credit claim** | 0066:414-433 attached a credit to the booking. **The 0084 rewrite dropped it.** | Nobody, since 0084 |
| Session times shown | `_generate` (`booking_catalog.dart:466-510`): masterclass now + 5..8 days at 20:00, cohort now + 8..13 days at 19:00, one slot `${id}_s0` | Phone |
| The real timetable | `publish_programme` copies `programme_sessions` into `booking_slots` as `ps_<id>` (0054:413-427). **The app never asks for those ids.** | Server, unused |
| Parent cancel | `cancel_booking` (0066:447-486): frees the seat; returns the credit if > `credit_return_hours` (4) away. That return finds nothing since 0084 | Server |
| Expert cancel / no-show | `expert_cancel_booking` (0077:75-147) | Server |

### Live (LiveKit)

| Piece | Where | Decides |
|---|---|---|
| Token gate | `livekit-token/index.ts:309` (getUser) → `join_context_for_booking` (0079:108-142): the booking owner, or an expert via `my_expert_ids()` | Server ✓. It accepts any booking that isn't cancelled, **paid or not** |
| Fallback | `join_room_for_booking` (0075) at `livekit-token:393`: no role and no window; publishing defaults to true | Server, wrongly permissive |
| Host opens a room | `open_session_room` (0079:213-302) takes slot, offering, expert, start, duration and capacity from the phone (`call_session.dart:244-253`, `doctor_class_launch.dart:80-101`), and creates the slot if it is missing | **Phone** |
| Room name | `bkroom_<slot_id>` from the database's answer (`livekit-token:170`, `livekit-moderate:172`) | Server ✓ |
| Publish grant | `can_publish` from SQL (0079:129-134); the token at `livekit-token:241` | Server ✓ |
| Raise hand | A data message (`group_call_screen.dart:72, 345-352, 637`); the host grants through `livekit-moderate` `allowSpeak` (:212-230) | Server for the grant ✓ |
| Token expiry | End + 30 min, at least now + 30 min; 4 h when there is no end (`livekit-token:183-191`). Moderation token 60 s, one room | Server ✓ |
| Join window | Attendee 10 min early, host 30 min, tail 15 min (0079:86-87, 139, 148-163, 229-230) | Server ✓ |
| Room capacity | No CreateRoom call. Capacity is only token metadata (`livekit-token:218`) | Nobody |
| Moderation | `livekit-moderate`: muteAll, allowSpeak/denySpeak, remove, endRoom; gate `can_moderate_slot` (0079:314-327) | Server ✓ |
| Attendance | Self-reported: `record_consult_join` / `record_consult_leave` (0078:98-172) from `group_call_screen.dart:426-450`; `settle_my_bookings` (0078:187-219). The migration's header says it can be spoofed | Phone |
| Host never arrives | "Waiting for … to begin" for ever (`group_call_screen.dart:869`). Host attendance not recorded (:436) | Nobody |
| Secrets | `LIVEKIT_API_SECRET` only in Deno env; none in `lib/` | Server ✓ |

### Identity of an expert

| Piece | Where | Decides |
|---|---|---|
| `expert_accounts` | `0030_expert_side.sql:29-33`: `grant select, insert, update … to authenticated`; the policy checks only `auth.uid() = user_id` | **Phone: any account can claim any `expert_id`** |
| `my_expert_ids()` Route A | `0073_one_partner_no_exceptions.sql:80-82`: trusts that row | — |
| The safe path | `claim_expert_invite()` (0084:~710-735): links an account only to the expert whose invite matches her verified email | Server ✓, but the table grant gets around it |
| Dev picker | `DoctorSession.enter()` (`lib/doctor/doctor_session.dart:266-275`) upserts `expert_accounts` from a dropdown; its own comment calls it the testing affordance | Phone |

### Recordings

| Piece | Where | State |
|---|---|---|
| Egress | None in `supabase/functions` or `lib/` | Not built |
| Lesson video | No learning lesson has a `videoUrl` ("Video · arriving", `pv_lesson_screen.dart:11-15,119`) | Not built |
| Watch videos | `pvResolveVideoUrl` (`post_pregnancy/video/pv_video_config.dart`); the dev placeholder is in a **public** `videos` bucket, used only under `kDebugMode` | Public |
| Buckets | `media` private, per-user (0013); `expert-photos` public (0090) | — |
| Entitlement | `EntitlementGrant.recordingAccess`; `BookingStore.ownsRecording()` has **no call sites** | Sold, not delivered |

### Doctor side

| Piece | Where | State |
|---|---|---|
| Routing | `main_doctor.dart:161-166`: `DoctorScaffold` if `DoctorSession.active`, else `DoctorAuthScreen` | ✓ |
| Her classes, seat counts, Go live | `doctor_classes_screen.dart:32-96`; home `doctor_home_tab.dart:97-100` | ✓ |
| People booked | Consults named (`doctor_home_tab.dart:98, 634`) via `expert_roster()` (`lib/doctor/doctor_roster.dart:59`); class attendees counted only, deliberately | ✓ |
| Discussion, unread, post, pin | None. The Inbox is a task list (`doctor_inbox_screen.dart:13-45`) | Not built |
| Panel / co-host | None in the app. A slot has one `expert_id` | Not built |

### Discussion

`hasThread()` / `ownsDiscussion()` have no call sites; "private discussion group" is sold on the buy sheet
(`booking_sheet.dart:178`) and in the copy (`pv_offering_content.dart:333, 522-568`). Not built.

---

## 2. The model

**One offering** is the product. It has:

- **runs**: one batch of it, with dates. A recorded course has one evergreen run. A cohort that runs again gets
  "Batch 2" as a new run. A masterclass repeated next month is a new run too.
- **sessions**: the dated live occurrences of a run, i.e. the timetable.
- **lessons**: the recorded items. A finished session's recording becomes a lesson.
- **hosts**: one lead and any number of co-hosts or moderators.
- **one discussion** per run. Each post may be tagged to a lesson or a session.

| Kind | Sessions | Lessons |
|---|---|---|
| Masterclass | 1 | 0, then 1 after the recording |
| Cohort | N, over days or weeks | Its recordings, added as they happen |
| Course | 0 | N |
| Class pack | A seat count (credits) against recurring sessions | — |

A consultation is not an offering. It stays on the expert's fee plus `consult_credits`.

**Where each part lives** (all existing tables except one):

| Part | Table |
|---|---|
| Offering | `programmes` (0054). **This is the offering, for every learning kind** (L.1) |
| Run | `programme_runs`, **new** (L.3) |
| Session | `programme_sessions` (0054), gaining `run_id` |
| Bookable seat | `booking_slots` as `ps_<session id>`, written by `publish_programme` (0054:413-427) |
| Lesson | Lesson rows on the programme (they carry the video host's asset id, never a public URL) |
| Host | `programme_experts` (0054:141-151), role host / co_host / moderator |
| Receipt | `course_purchases`, **new**, server-written only |
| Discussion | Community phase 2's offering room, keyed by run |

**Why reuse `programmes` instead of a new `offering_catalog`.** Two tables that each hold a price will drift apart,
and then which one charges her? `programmes` already holds price, capacity, refund fields, sessions, hosts, coupons,
the medical/marketing review workflow and the Directus wiring. The cost: every bundled Dart programme must be seeded
as a real published row under the app's id, and a contract test must hold the two lists equal.

**The one access rule.** `has_course_access(offering, what, run)`, where `what` is `seat`, `recording` or `thread`.
Booking, joining, playback and posting all ask this one function. There is no second place where the answer could
differ.

---

## 3. The checklist (status as found, 2026-10-28)

`OK` is right as it stands. `GAP` means missing. `FLAW` means it exists and is wrong.

| Area | Item | Status | Where |
|---|---|---|---|
| **Money** | Price comes from the server | FLAW (courses); OK with a GAP (shop) | `razorpay-create-order:82-98` |
| | The server writes the receipt, once per payment id | GAP | `razorpay-verify-payment:175-180` |
| | Webhook backstop | GAP | no function |
| | Refunds revoke access | GAP | 0054:78-81 unused |
| | A free offering gets a real receipt | GAP | `payment_service.dart:79` |
| | The no-charge preview cannot reach a release build | FLAW | `pv_learn_flow.dart:484` |
| | Payment functions know who is calling | GAP | `--no-verify-jwt`, no JWT read |
| **Access** | One server rule decides seat, recording and thread | GAP | phone blob |
| | Access duration | FLAW | phone clock, `booking_models.dart:298` |
| | Cancellation and no-show defined | Partly: seat OK, credit broken since 0084, money absent | 0066:447, 0077 |
| | Partner or sponsor grant | OK for sponsors; GAP for referrals | 0067:200; `referral_store.dart:243` |
| **Schedule** | Times, capacity and host from the server | FLAW | `booking_catalog.dart:466-510`, 0084:98-103 |
| | A timetable change is a server edit and the people booked are told | GAP | — |
| **Live** | Tokens only for a valid booking or host | OK in shape; FLAW in practice (unpaid bookings, expert self-claim) | 0079:108-142, 0030:29 |
| | Room name from the server | OK | `livekit-token:170` |
| | Roles: host publishes, attendees speak when allowed | OK | 0079:129-134, `livekit-moderate:212-230` |
| | Token expiry | OK | `livekit-token:183-191` |
| | Early-join window | OK | 0079:86-163 |
| | Capacity enforced in the room | GAP | no CreateRoom |
| | Host moderation | OK, only as safe as `expert_accounts` (FLAW) | `livekit-moderate` |
| | Webhooks give attendance (feeds STILL-OPEN §5.4f) | GAP | 0078 self-report |
| | Host never arrives | GAP | `group_call_screen.dart:869` |
| | Secrets server-side | OK | Deno env |
| | Fallback path gives attendees publish rights | FLAW (small) | `livekit-token:238-241, 393, 409` |
| **Recordings** | Egress to storage | GAP | none |
| | Private storage, playback only after the access rule | GAP | — |
| | Long videos streamed (HLS) | GAP | — |
| **Panel** | Several hosts per offering, each with access, badge and earnings share | GAP (app); the table exists | 0054:141-151, 0056 |
| **Doctor side** | Offerings ✓, people booked ✓; discussion, unread, post, pin | GAP | `doctor_inbox_screen.dart` |
| **Discussion** | Who reads and writes; team notices and pins; survives the end | GAP (sold, not built) | `booking_sheet.dart:178` |

---

## 4. The decisions (accepted 2026-10-29)

**Asked, and answered "recommended" across the board.**

| # | Question | Decided | Why, and what it costs |
|---|---|---|---|
| L.1 | What is the offering on the server | **`programmes`**, for masterclass, cohort, course and class pack. The bundled Dart programmes are seeded as published rows under the app's ids. Consults stay on fee + `consult_credits`. Part A's separate `offering_catalog` is dropped | One price column, not two. Costs a seed and a parity test (§2) |
| L.3 | Cohort runs | **`programme_runs`**. Sessions and purchases belong to a run; each run has its own discussion; a repeated masterclass is a new run | Batch 2 doesn't land among strangers from batch 1. Costs one table and a `run` argument on the access rule |
| L.7 | Recording host | **Mux**: signed playback, free basic encoding, 100,000 free delivered minutes a month. LiveKit egress → a private S3-compatible bucket → Mux imports → the asset id on the lesson | A mature signed-playback API at about $18 (₹1,584) a month at launch scale. Bunny is cheaper but its India delivery price is unconfirmed. Playback sits behind one function, so moving later is one file |
| L.12 | Refund rule | **Masterclass:** full refund until 24 h before start. **Cohort:** full refund before the first session. **Course:** 7 days, if she has opened no more than lesson 1. Stored per programme. **A refund revokes the seat, the recording and the discussion** | One rule the copy can quote. The three conflicting promises in the copy are rewritten to match |
| L.13 | How long access lasts | **Recordings and the discussion: for life.** Class-pack seats expire (yoga 30 days, as today). A cohort's live seats end with its run | The industry norm (Udemy, Maven). The storage cost is small (§6) |
| L.14 | Host never arrives | **+10 min:** the waiting room says "Dr X hasn't joined yet. We've told the team" (Preply). **+20 min** with no host (from the webhook): the session is `host_missed`; her seat or credit comes back, she is offered a refund, and the expert is not paid | Closes STILL-OPEN §5.4f's "a doctor who no-shows is paid". Needs L.15 first |
| L.18 | Shop orders: the client can set `paid` | **Folded into L2.** The same `payment_orders` + verify path writes the shop order's paid status | One receipt pattern, not two |
| L.22 | Where she sees what she has booked and bought (asked by the user 2026-10-29) | **Your bookings is the one history, for the whole app.** The screen exists (`PvMyLearningScreen`, Profile › Your bookings, the same profile in all four stages; rows carry a stage word, nothing switches on stage). Keep Upcoming, Continue, Credits and Past as built; add **Payments** (every payment and refund with amount, date, status and its receipt); a cohort shows its batch and its next session from the server timetable; past sessions show attendance (L3) and the recording. All of it read from the server (`booking_bookings` as today, plus `my_purchases`), cached on the phone. Shop orders stay in Your orders | One place, so a reinstall or a new phone shows the same history, and a parent who moves from pregnancy to parenting keeps hers. Costs: `my_purchases` returns amount, status and refund date (L2b), and the Payments section plus reading receipts instead of local minting (L2c) |

**Obvious: chosen and recorded, not asked.**

| # | Decided | Why |
|---|---|---|
| L.2 | One discussion per offering run. Each post may be tagged "About: Lesson 3". Under each lesson player, a small thread shows only that lesson's posts (Mindvalley's Lesson \| Discussions) | A small cohort split into per-lesson rooms is a row of empty rooms |
| L.4 | Anyone with a receipt, plus hosts and moderators, may read and post, at any time: before, during, after, and after the end | No time window. The live in-call chat is a separate thing (phase 4) |
| L.5 | Hosts come from `programme_experts`, which already exists. Fix the view (0056) that returns only the first accepted expert. Every host can read, post with the badge, answer and pin; remove and mute stay with moderators | The table already exists. The earnings split across a panel follows 0084's share rules; flag it in L2 if that needs a decision |
| L.6 | A ParentVeda team post plus pin in any offering discussion; the pinned notice also shows on the course page. Push comes in phase 3 | As Part B planned |
| L.8 | The host publishes; attendees speak when the host allows (raise hand) | Already built and granted on the server. Keep it |
| L.9 | `programme_sessions` is the timetable. The app books the `ps_<id>` slots `publish_programme` writes. `book_slot` refuses a slot it didn't make | The server half exists; this is mostly wiring |
| L.10 | **Revoke insert and update on `expert_accounts`** from `authenticated`. Only `claim_expert_invite` writes it. The dev picker moves to a dev-only function | See §5, the first BLOCKER |
| L.11 | **Restore 0066's credit claim in `book_slot`**, plus a contract test that reads the *last* definition | See §5 |
| L.15 | A LiveKit webhook (participant joined / left, room finished) writes attendance on the server. The phone's report stays only as a fallback | Self-report can be spoofed, and money (L.14, §5.4f) now depends on attendance |
| L.16 | The room is created on the server with `maxParticipants` = seats + hosts | Defence in depth: a leaked token can't overfill the room |
| L.17 | A `payment_mode` row (`stub` / `live`). `notConfigured` grants only through `record_stub_purchase`, which works only in `stub` | Keeps today's no-charge preview for development; one switch closes it |
| L.19 | `open_session_room` reads only an existing server slot; it never creates one from phone values | The same flaw as `book_slot`'s on-demand slots |
| L.20 | Remove the 0075 fallback in `livekit-token` (0076 is deployed) | The fallback gives attendees publish rights |
| L.21 | Both payment functions read the JWT; create-order binds the order to the user, and verify refuses a different user | An order belongs to someone |

---

## 5. The issue ledger

Each issue has a tier, the pass that fixes it, and a status. **New issues are added here as they are found.** Tick
with a date and commit hash; never delete a line.

Tiers: **BLOCKER** means nothing is sold until it's fixed. **LAUNCH** means before real users. **LATER** means
written down so it isn't lost.

### BLOCKER

- [x] **LA-1 · Any account can become any expert.** The table grant (`0030:29-33`) gets around `claim_expert_invite`.
  With a self-claimed id, an account can get a host token with publish rights, join that expert's consults, mute,
  remove or end their rooms, and read their roster. *The general fact: row-level security that checks "it's your
  row" is not enough when the value in the row is the privilege. A table grant overrides every careful function
  built on top of it.* · L.10 · pass **L2a** · built 2026-10-29 in `0123` (grant revoked, `dev_claim_expert` behind `dev_testers`), **closed 2026-10-29**, `ad5be7de`, 0123 run and checked on the live DB
- [x] **LA-2 · A credit can be spent twice (0084 regression).** `book_slot`'s rewrite dropped 0066's credit claim.
  Sponsor credits (0067) are never attached to a booking; `cancel_booking`'s return finds nothing. *The general fact:
  `create or replace` swaps the whole body, so whatever an earlier migration added is silently gone unless it is
  copied forward. The guard is a test that reads the last definition.* · L.11 · pass **L2a** · built 2026-10-29 in `0123`, guarded by `test/learning_security_contract_test.dart`; **closed 2026-10-29**, `ad5be7de`, 0123 run and checked on the live DB
- [x] **LA-3 · A host can open a room for any slot, at any time, with phone-supplied values.** `open_session_room`
  creates the slot from what the phone sends (0079:252-258). · L.19 · pass **L2a** · built 2026-10-29 in `0123` (stored slot only; the five unused arguments stay until L3); **closed 2026-10-29**, `ad5be7de`, 0123 run and checked on the live DB
- [ ] **LA-4 · The client sets the price.** Pay ₹1 for a ₹2,499 course with a valid signature
  (`razorpay-create-order:82-98`). · L.1 · pass **L2b** · open
- [ ] **LA-5 · The server keeps no record of a purchase.** Verify returns `{valid}`; the phone mints access. Edit the
  prefs and you own any course. · L.1, L.17 · pass **L2b** (server) + **L2c** (app) · open
- [ ] **LA-6 · `book_slot` trusts the client and never checks payment.** Expert, capacity, start and price come from
  the caller; the slot is created on demand; unpaid is not refused (STILL-OPEN §11.7). The client price flows into
  the expert's earnings. · L.9 · pass **L2b** · open
- [ ] **LA-7 · The no-charge preview can reach a release build.** `notConfigured` counts as success. · L.17 · pass
  **L2b** + **L2c** · open
- [ ] **LA-8 · The payment functions don't know who is calling.** `--no-verify-jwt` and no JWT read. · L.21 · pass
  **L2b** · open
- [ ] **LA-9 · A paid video would be public.** None exist yet. The rule: private storage, playback only after
  `has_course_access(…,'recording')`, signed and short-lived. · L.7 · pass **L3** · open (must close before the
  first upload)

### LAUNCH

- [ ] **LA-10 · Session times are invented on the phone.** The real `ps_<id>` slots exist and go unused. · L.9 ·
  **L2b** + **L2c** · open
- [ ] **LA-11 · No webhook backstop.** A phone that dies mid-payment leaves a paid order with no receipt. · L.1 ·
  **L2b** · open
- [ ] **LA-12 · No refunds, and the copy promises three different rules.** · L.12 · **L2b** (server) + **L2c**
  (copy) · open
- [ ] **LA-13 · Shop orders: the client can set `paid`.** No unique `payment_id`. · L.18 · **L2b** · open
- [ ] **LA-14 · A recorded course cannot be sold** (the builder returns `null`). · L.1 · **L2c** · open
- [ ] **LA-15 · Only the first host is visible** (0056 view). · L.5 · **L2b** · open
- [ ] **LA-16 · Attendance is self-reported.** · L.15 · **L3** · open
- [ ] **LA-17 · Host never arrives: nothing happens, and the expert is still paid** (STILL-OPEN §5.4f). · L.14 ·
  **L3** · open
- [ ] **LA-18 · Room capacity is not enforced in the room.** · L.16 · **L3** · open
- [ ] **LA-19 · No recording pipeline** (egress → bucket → Mux → lesson → signed playback). The buy sheet sells "a
  recording to keep". · L.7 · **L3** · open
- [ ] **LA-20 · No discussion, though it is sold** ("private discussion group"). · L.2–L.6 · **L4** · open
- [ ] **LA-21 · Doctor side: no discussion, unread counts, posting or pinning.** · L.5 · **L4** · open
- [ ] **LA-22 · A timetable change reaches no one.** A server edit must notify the people booked (a pinned team
  notice first; push in phase 3). · L.6 · **L4** · open
- [ ] **LA-27 · Your bookings shows no payments or refunds, and a bought course lives only on the phone.** A
  reinstall or a second phone loses course access and the history. · L.22 · **L2b** (`my_purchases` fields) + **L2c**
  (Payments section, receipts read from the server) · open

### LATER

- [ ] **LA-23 · Referral credits are granted on the phone only** (`referral_store.dart:243`). Same fix shape as 0067:
  grant through `grant_consult_credits`. · — · unassigned · open
- [ ] **LA-24 · The 0075 fallback in `livekit-token`.** · L.20 · **L3** · open
- [ ] **LA-25 · Raise hand has no rate limit.** · — · **L3** · open
- [ ] **LA-26 · Comments pinned to a video timestamp** (YouTube). Declined for now. · — · — · parked

---

## 6. Costs (looked up 2026-10-28; ₹88 = $1)

**LiveKit Cloud** (livekit.com/pricing):

| | Build, $0 | Ship, $50/mo (₹4,400) |
|---|---|---|
| Participant minutes | 5,000 | 150,000, then $0.0005/min |
| Concurrent connections | 100 | 1,000 |
| Recording (transcode) minutes | 60 | 600, then $0.02/min video |
| Data to viewers | 50 GB | 250 GB, then $0.12/GB |

Worked example: a 60-minute masterclass, 40 parents and 1 host, is about 2,460 participant minutes, about 25 GB down
(an estimate at 720p), and 60 recording minutes.
- **Build** covers about 2 classes a month and 1 recording.
- **Ship** covers about 10 recorded classes. Data runs out first, not minutes. Each extra class is about $4.20
  (₹370), roughly ₹9 an attendee on a ₹1,499 class.

**So: Build for testing, Ship from the first real paid class.**

**Recording hosts**, for a 100-hour library watched for 500 viewer-hours a month:

| Host | A month | Notes |
|---|---|---|
| **Mux (chosen)** | ~$18 (₹1,584) | Storage $0.003/min/month; 100,000 delivered minutes free, then $0.001/min; basic encoding free; signed playback built in |
| Bunny Stream | ~$6–14 (₹530–1,230) | $0.01/GB storage, delivery from $0.005/GB, $1 minimum; India rate not listed |
| Cloudflare Stream | ~$60 (₹5,280) | $5 per 1,000 minutes stored, $1 per 1,000 delivered |
| Supabase Storage | ~$13 (₹1,190) over Pro | No HLS: a whole MP4 over mobile data. Short clips only |

**Razorpay:** about 2% a payment plus 18% GST on the fee, roughly ₹59 (~$0.70) on ₹2,499. Charged only once live.

---

## 7. How the work runs

The order follows one rule: **close what can be abused today, then the server, then the app, then features on top.**
Each step depends only on the steps before it.

| Pass | What | Migration | The user does |
|---|---|---|---|
| **L1** | This doc, BEFORE-LAUNCH rows, MOBBIN-DISCOVERY §39, the prototype (https://claude.ai/artifact/NjtHCJ3J6fLfquN7Tbhdf1: course page, discussion, lesson player, timetable, waiting room, doctor offerings, refund, Your bookings). **Signed off 2026-10-29**, with Your bookings as the one history added (L.22) | — | Signed off |
| **L2a** | LA-1, LA-2, LA-3: the security hotfix. Contract test on the last `book_slot` | `0123` | Runs it; as an ordinary user, tries to insert into `expert_accounts`, which must be refused |
| **L2b** | Server receipts and schedule: seeded `programmes`, `programme_runs`, refund rules, `payment_orders`, `course_purchases`, `payment_mode`, `has_course_access`, `record_course_purchase`, `my_purchases` (returning amount, status, paid and refunded dates, payment id and stage, for Your bookings, L.22), `claim_free_offering`, `record_stub_purchase`, the refund function, `book_slot` reading only server values, shop paid status; create-order, verify and a new `razorpay-webhook` | next free (≥ `0126`) | Runs it; deploys three functions; sets `RAZORPAY_WEBHOOK_SECRET`; adds the test webhook; checks that `book_slot` with no purchase is refused in live mode |
| **L2c** | The app on the server: `PaymentService` sends only the id; `my_purchases()` replaces local minting (kept for revert); the app books `ps_<id>`; the preview through the stub; a recorded course sellable; refund copy; Your bookings gains Payments and reads receipts from the server (L.22) | — | Installs the build; walks buy → book → join in test mode |
| **L3** | `livekit-webhook` (attendance, +10 / +20 states), room capacity, the 0075 fallback removed, egress → bucket → Mux → lesson, playback through `has_course_access`; Your bookings' Past shows attendance and the recording | next free | Creates a Mux account; LiveKit Ship before the first paid class |
| **L4** | Community phase 2 on this model (Part B of `course-receipts-then-community-p2.md`), including the doctor's "Your offerings" | next free | As in Part B |

**Why L2b and L2c are separate.** While L2b is live and L2c isn't, the old app keeps working because the server is
still in `stub` mode. When you change a contract, the server learns the new shape first and the client moves
after, so the people already using it never see a break.

**Migration numbers** (2026-10-29): `0123` is free and is L2a's. `0124` (programme age window) and `0125` (Mind and
Mood entries) are other terminals'. Every later pass re-checks `ls supabase/migrations` first and takes the next
free number. Never rename another terminal's file.

**Done means:**
- every BLOCKER in §5 is ticked or explicitly parked by the user;
- the tests are green and the call sites have been grepped;
- the first real masterclass, course or cohort goes on sale by adding a `programmes` row, its sessions and a video,
  with no code change.

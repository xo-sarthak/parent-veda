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
| L.23 | The expert's cut (asked 2026-10-29, in L2b) | **Variable per offering, by agreement.** `programme_experts` carries `share_bps` or `share_flat_paise` for that expert on that programme; empty falls back to the expert's rule, then the format's default (0084). A credit-covered seat (sponsor, referral, pack) earns the same cut of the same server price as a paid one | The user: "it's not decided, it might be variable according to the course or the format... an agreement with the expert". A flat amount covers the cheap-masterclass case a percentage cannot |
| L.24 | Refunds for consults and class packs (asked 2026-10-29) | **Support only for now.** No self-serve button; support refunds unspent credits from the dashboard and the webhook voids them | L.12 covers masterclass, cohort and course only. Cancelling a consult in time already returns the credit (0066) |
| L.25 | How a class recording starts (asked 2026-10-29, L3 D1) | **By itself, when the host joins a class.** Consults are never recorded. "Recorded" shows in the call; the host can stop it (what was recorded so far is kept) | A recording is sold, so it cannot depend on a host remembering a button. Consults are clinical |
| L.26 | How the team is told at +10 / +20 (L3 D2) | **An `ops_alerts` row, posted to a Discord or Slack incoming webhook** (pg_net; the URL in Vault as `team_alert_webhook_url`). No URL: the row only | Free and instant; WhatsApp would need an approved template and the test number reaches registered phones only |
| L.27 | Does the host rule cover 1:1 consults (L3 D3) | **Yes.** A doctor who never joins: her credit back, the doctor not paid, the parent told at +10 and +20 | STILL-OPEN §5.4f is about consults; 20 minutes is most of a 30-minute consult |
| L.29 | The cancel window and a late move (credits fix, 2026-10-30) | **One window, the server's: 4 hours (`booking_policy.credit_return_hours`).** Cancel before it and the credit comes back; inside it the credit stays with the session. A booking can be moved any time before the window, never inside it; the phone's "one free reschedule" is withdrawn | The user, 2026-10-30: "drop it". Practo and Zocdoc allow moves up to a cutoff, not after. The phone said 2 hours and a free move; the server had neither, so she lost the credit and then the booking |
| L.30 | A credit returned through no fault of hers (credits fix) | **It lives at least 30 more days** (`expires_at = greatest(expires_at, now() + 30 days)`) when the host missed or the expert cancelled | A 30-day pack credit returned on day 29 would be useless. ClassPass extends returned credits the same way |
| L.31 | Who is paid when she cancels late or does not come (credits fix) | **The doctor, in both cases.** A late cancel that keeps her credit makes the earning payable, as `missed` already did | The hour was held and cannot be resold. Industry standard (Practo, Zocdoc); the phone's ConsultPolicy already said so |
| L.32 | A session nobody can vouch for (credits fix) | **Held for a person.** No host seen, or the host left and did not come back: no seat settles and no one is paid until `resolve_host_alert` says whether the host came | A guess either way costs someone money; a short hold costs nothing |
| L.28 | The original file after Mux imports it (L3 D4) | **Kept** in the private `recordings` bucket | The master copy, and the way out if Mux is replaced. About 1 GB a class hour, ~$0.02 (₹1.8) a month |

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
- [x] **LA-4 · The client sets the price.** Pay ₹1 for a ₹2,499 course with a valid signature
  (`razorpay-create-order:82-98`). · L.1 · pass **L2b** · built 2026-10-29 in `0126` + the three Razorpay functions, **closed 2026-10-29**, `7575940a`, 0126 run (VERIFY all true), functions deployed, secret set, test webhook added (`price_offering`; the client amount is read only in stub mode, for an offering the server cannot price)
- [ ] **LA-5 · The server keeps no record of a purchase.** Verify returns `{valid}`; the phone mints access. Edit the
  prefs and you own any course. · L.1, L.17 · pass **L2b** (server) + **L2c** (app) · server half · built 2026-10-29 in `0126` + the three Razorpay functions, server half **closed 2026-10-29**, `7575940a`, 0126 run and deployed (`course_purchases`, written by verify and the webhook); app half **built 2026-10-29 in L2c**, waiting on commit and the walk (signed in, ownership is derived from `my_purchases()`; `BookingStore.acquire` is the one buy path; `purchase()` has no production caller)
- [x] **LA-6 · `book_slot` trusts the client and never checks payment.** Expert, capacity, start and price come from
  the caller; the slot is created on demand; unpaid is not refused (STILL-OPEN §11.7). The client price flows into
  the expert's earnings. · L.9 · pass **L2b** · built 2026-10-29 in `0126` + the three Razorpay functions, **closed 2026-10-29**, `7575940a`, 0126 run (VERIFY all true), functions deployed, secret set, test webhook added (server values only; unpaid raises `payment required` in live mode; the stub branch keeps today's app working)
- [ ] **LA-7 · The no-charge preview can reach a release build.** `notConfigured` counts as success. · L.17 · pass
  **L2b** + **L2c** · server half · built 2026-10-29 in `0126` + the three Razorpay functions, server half **closed 2026-10-29**, `7575940a`, 0126 run and deployed (`payment_mode`, `record_stub_purchase`); app half **built 2026-10-29 in L2c**, waiting on commit and the walk (`notConfigured` now asks `record_stub_purchase`; a create-order refusal keeps its reason instead of falling back to the preview)
- [x] **LA-8 · The payment functions don't know who is calling.** `--no-verify-jwt` and no JWT read. · L.21 · pass
  **L2b** · built 2026-10-29 in `0126` + the three Razorpay functions, **closed 2026-10-29**, `7575940a`, 0126 run (VERIFY all true), functions deployed, secret set, test webhook added (both read the JWT; verify refuses another user's order)
- [x] **LA-28 · Thirty-one internal functions were callable by any signed-in account** (found 2026-10-29 while building L2b). They were revoked `from public` only; Supabase grants every new function to `anon` and `authenticated` by name, so the revoke closed a path nobody used. `grant_consult_credits` (fifty free consults), `grant_plan`, `write_expert_earning`, `void_consult_credits`, `publish_programme`, `approve_care_partner`, `mint_partner_token`, the `phone_otp_*` set and more. *The general fact: a privilege can arrive by several paths, and a revoke closes one. Check with `has_function_privilege`, not by reading the migration.* · — · pass **L2b** · built 2026-10-29 in `0126` + the three Razorpay functions, **closed 2026-10-29**, `7575940a`, 0126 run (VERIFY all true), functions deployed, secret set, test webhook added (all overloads revoked from anon and authenticated; `test/learning_money_contract_test.dart` fails on a bare `from public`)
- [ ] **LA-9 · A paid video would be public.** None exist yet. The rule: private storage, playback only after
  `has_course_access(…,'recording')`, signed and short-lived. · L.7 · pass **L3** · open (must close before the
  first upload) · **live 2026-10-29**, `54875c57`, 0128 run, functions deployed. Still open until the Mux account and S3 keys are set and one class recording has been walked from the call to Your bookings › Watch: the private `recordings` bucket has no policies, `programme_recordings` has no client grants, Mux assets are created with a signed playback policy, and `recording-playback` signs a two-hour token only after `recording_for_playback` / `lesson_video` say yes (`has_course_access`, plus a seat in that session, plus the lesson-1 preview)

### LAUNCH

- [ ] **LA-10 · Session times are invented on the phone.** The real `ps_<id>` slots exist and go unused. · L.9 ·
  **L2b** + **L2c** · server half · built 2026-10-29 in `0126` + the three Razorpay functions, server half **closed 2026-10-29**, `7575940a`, 0126 run and deployed (sessions mirror to slots on every write, under the offering id); app half **built 2026-10-29 in L2c**, waiting on commit and the walk (classes show only the `ps_` slots; no session = no date, the user's decision; see LA-33)
- [x] **LA-11 · No webhook backstop.** A phone that dies mid-payment leaves a paid order with no receipt. · L.1 ·
  **L2b** · built 2026-10-29 in `0126` + the three Razorpay functions, **closed 2026-10-29**, `7575940a`, 0126 run (VERIFY all true), functions deployed, secret set, test webhook added (**reopened 2026-10-29: it was added on a different Razorpay account from the key's, so it never fires; re-add on the right account with a new secret**); **re-added 2026-10-29** on the key's account with a fresh secret, the same value set as `RAZORPAY_WEBHOOK_SECRET`. Proof is the first test payment's delivery showing 200 in the Razorpay log) (`razorpay-webhook`; the user adds the webhook in the Razorpay dashboard)
- [ ] **LA-12 · No refunds, and the copy promises three different rules.** · L.12 · **L2b** (server) + **L2c**
  (copy) · server half · built 2026-10-29 in `0126` + the three Razorpay functions, server half **closed 2026-10-29**, `7575940a`, 0126 run and deployed (`request_refund`, `record_refund`, the rule per programme; the money is returned by support from the dashboard until a refund function exists, LA-31); copy and button **built 2026-10-29 in L2c**, waiting on commit and the walk (every trust row and FAQ quotes the rule; consults and packs say support, and 4 hours to move a time, as 0066 does; `request_refund` from the receipt sheet)
- [x] **LA-13 · Shop orders: the client can set `paid`.** No unique `payment_id`. · L.18 · **L2b** · built 2026-10-29 in `0126` + the three Razorpay functions, **closed 2026-10-29**, `7575940a`, 0126 run (VERIFY all true), functions deployed, secret set, test webhook added (an unproven `paid` is demoted to `placed`; unique index)
- [ ] **LA-14 · A recorded course cannot be sold** (the builder returns `null`). · L.1 · **L2c** · **built 2026-10-29 in L2c**, waiting on commit and the walk (paid courses sell as `off_<id>` / `off_pg_<id>`; lesson 1 stays the preview; the lesson player calls `record_lesson_open`)
- [x] **LA-15 · Only the first host is visible** (0056 view). · L.5 · **L2b** · built 2026-10-29 in `0126` + the three Razorpay functions, **closed 2026-10-29**, `7575940a`, 0126 run (VERIFY all true), functions deployed, secret set, test webhook added (`hosts`, lead host prefers role `host`)
- [x] **LA-16 · Attendance is self-reported.** · L.15 · **L3** · open · **closed 2026-10-29**, `54875c57`, 0128 run (VERIFY all true, the sweep is cron job 4 and succeeds every minute), five functions deployed, LiveKit webhook added. First proof in use: a call's `livekit-webhook` deliveries answering 200 in the function logs (`livekit-webhook` checks LiveKit's signature, `record_room_event` writes `consult_sessions` with source `livekit`; `_settle_slot` lets LiveKit's record decide when it saw anyone in the room, the phone's otherwise; the minute sweep settles ended sessions; Your bookings adopts the server's attended / missed)
- [x] **LA-17 · Host never arrives: nothing happens, and the expert is still paid** (STILL-OPEN §5.4f). · L.14 ·
  **L3** · open · **closed 2026-10-29**, `54875c57`, 0128 run (VERIFY all true, the sweep is cron job 4 and succeeds every minute), five functions deployed, LiveKit webhook added. First proof in use: a call's `livekit-webhook` deliveries answering 200 in the function logs (`sweep_live_sessions` every minute: +10 a `host_late` notice; +20 with LiveKit evidence of attendees and none of a host, `_declare_host_missed` cancels every seat with `cancel_reason = 'host_missed'`, returns credits, and the 0084 trigger reverses the expert's accrual; no evidence at all raises `host_unknown` and changes nothing; `_refund_check` says yes whatever the date; both waiting rooms show +10 and poll `session_state` from +20; consults too, L.27)
- [x] **LA-18 · Room capacity is not enforced in the room.** · L.16 · **L3** · open · **closed 2026-10-29**, `54875c57`, 0128 run (VERIFY all true, the sweep is cron job 4 and succeeds every minute), five functions deployed, LiveKit webhook added. First proof in use: a call's `livekit-webhook` deliveries answering 200 in the function logs (`livekit-token` calls CreateRoom before minting, `max_participants` = seats + hosts + 1 from `room_max_participants`; fails open, the database is the first lock)
- [ ] **LA-19 · No recording pipeline** (egress → bucket → Mux → lesson → signed playback). The buy sheet sells "a
  recording to keep". · L.7 · **L3** · open · **live 2026-10-29**, `54875c57`, 0128 run, functions deployed. Still open until the Mux account and S3 keys are set and one class recording has been walked from the call to Your bookings › Watch (host joins a class → `begin_recording` → room-composite egress to the bucket → `egress_ended` → a 24-hour signed URL → a Mux asset → `mux-webhook` writes the playback id → Your bookings › Past "Watch", and a course lesson plays when a row with its `lesson_id` is ready). Needs the Mux account and the S3 keys before it can be walked
- [ ] **LA-20 · No discussion, though it is sold** ("private discussion group"). · L.2–L.6 · **L4** · open
- [ ] **LA-21 · Doctor side: no discussion, unread counts, posting or pinning.** · L.5 · **L4** · open
- [ ] **LA-22 · A timetable change reaches no one.** A server edit must notify the people booked (a pinned team
  notice first; push in phase 3). · L.6 · **L4** · open
- [ ] **LA-27 · Your bookings shows no payments or refunds, and a bought course lives only on the phone.** A
  reinstall or a second phone loses course access and the history. · L.22 · **L2b** (`my_purchases` fields) + **L2c**
  (Payments section, receipts read from the server) · server half · built 2026-10-29 in `0126` + the three Razorpay functions, server half **closed 2026-10-29**, `7575940a`, 0126 run and deployed (`my_purchases` returns amount, status, provider, mode, payment id, stage, paid / refund dates and the refund rule's verdict); app half **built 2026-10-29 in L2c**, waiting on commit and the walk (Your bookings › Payments, receipts cached per account, receipt sheet with the refund button)

- [x] **LA-29 · A consult's start time is the parent's pick, not checked against the doctor's schedule.** **closed 2026-10-29**, `54875c57`, 0128 run (VERIFY all true, the sweep is cron job 4 and succeeds every minute), five functions deployed, LiveKit webhook added. First proof in use: a call's `livekit-webhook` deliveries answering 200 in the function logs: `slot_fits_schedule` (a line-for-line SQL port of `generateSlots`, in IST) runs before `book_slot` creates a consult slot, raising `outside schedule`; both copies answer `test/fixtures/schedule_parity_cases.json` (29 cases; `select * from _schedule_parity_selftest() where not ok` must return no rows). Original note: `book_slot` makes a real-expert consult slot with the server's expert, duration, one seat and price, and refuses a past start, but does not yet read `doctor_schedule` (0033). · L.9 · **L2c** or **L3** · open. **Not built in L2c (2026-10-29), recommended for L3's migration:** the schedule-to-times rule is about 200 lines of Dart (`DoctorSchedule`: sessions, consult rules, time off, overrides); checking it on the server means porting it to SQL (`slot_fits_schedule(expert, start)`) with a parity test holding the two copies equal. Until then the server enforces a real expert, a future start, one seat and its own price
- [ ] **LA-30 · The 20 bundled consults have no server price.** They belong to bundled (fictional) experts: yoga 1:1s, the pregnancy specialists, Mind and Mood, the TTC doctors. A consult is priced from its expert's `expert_profiles` fee (L.1), so these sell only in stub mode. Before live, each becomes a real expert (booked as `off_exp_<id>`) or is withdrawn, the same rule as `ppExpertIsPlaceholder`. · L.1 · **L2c** + content · **decided 2026-10-29 by the user: "anything that has no price becomes opening soon"**; app half **built in L2c** (`offeringHasServerPrice`: a consult not under `off_exp_`; the page says "Opening soon", any other buy path gets the same sentence from the server's `unknown_offering`). Open for content: each becomes a real expert or stays opening soon
- [ ] **LA-31 · Refund money is returned by hand.** `request_refund` decides and revokes access at once; support then refunds in the Razorpay dashboard, and the webhook marks it refunded. Automating it is one function calling Razorpay's refund API. · L.12 · before the first real refund · open
- [x] **LA-32 · `book_slot` still receives five phone values it no longer needs** (found 2026-10-29 in L2c). Expand half live 2026-10-29, `54875c57`, 0128 run (defaults on expert, start, length, capacity, stage and title; same types, so it replaces rather than overloads). **Contract built 2026-10-29 after the run**, waiting on the commit: an offering the server prices is booked by its ids (plus her start for a consult); only an offering the server cannot price still sends the slot values, for the stub branch (`BookingStore.reserve`, `SupabaseRepo.bookSlot`). Left for the next learning migration: drop the 6-argument `open_session_room`, then stop sending the host's descriptor (`CallSession.fetchHostJoin`). Original note: Expert, start, length, capacity and join url have no SQL defaults, and PostgREST matches a call by its argument names, so the app cannot stop sending them yet. The server reads them only for a consult's start and the stub branch. Fix: a migration gives them defaults (expand), then the app stops sending them (contract). BACKEND-PATTERNS 16zzk §5 · L.9 · **L3** · open
- [ ] **LA-33 · No seeded programme has a host, so no session can become a slot** (found 2026-10-29 in L2c). `_mirror_session` writes a `ps_` slot only for a programme with an accepted lead host in `programme_experts`; none of the 47 seeded rows has one. Since L2c the app shows only those slots, so every bundled class reads "No dates open right now" until the panel links a host and adds sessions. This is the plug-and-play path working as designed, not a bug, but it is the first thing to do before a class can be walked · L.5, L.9 · content, before the L2c walk · open. Walk set up 2026-10-29: `mc_sleepreg` hosted by `sp_ob` (doctor@test.com), one session, slot `ps_mc_sleepreg_s1` checked on the live DB. The other 46 programmes still have no host

- [x] **LA-34 · Consult times were worked out in the phone's time zone** (found 2026-10-29 in L3). `generateSlots` built times with `DateTime(day…)`, local time, so a parent abroad was offered the doctor's 10:00 in her own zone. Once the server checks the schedule in IST (LA-29) those bookings would be refused. Fixed in the same pass: the parent's path runs the rule on IST wall clock (`istWallClock`, a fixed +05:30; India keeps one offset all year), and on an Indian phone the slot ids and times are unchanged · LA-29 · **L3** · **closed 2026-10-29**, `54875c57`. Also (after the run): a doctor who has saved no schedule is now offered the starter clinic, the one the server assumes, not the old made-up calendar (whose 18:30 the server would refuse). The doctor's own preview still runs in local time (she is in India)

**Credits fix (audit 2026-10-29, built 2026-10-30 in `0135_credits_truth.sql`, waiting on the run).** Each line
was checked against the function's last definition; `test/credits_truth_contract_test.dart` pins them, and a pgserver
run on a stub schema checked 41 behaviours.

- [ ] **LA-35 · A late cancel showed "credit back".** `cancel_booking` returned nothing, so the phone counted every
  cancel as a return; inside 4 hours the server had kept it. Now it returns `{ok, credit_returned, late, reason}`, a
  kept credit is `cancel_reason = 'late_cancel'` (still counted as used), and the window is read from the server
  (`booking_terms`). · L.29 · built 2026-10-30
- [ ] **LA-36 · Past bookings could be cancelled.** Both cancel functions refused only `cancelled`, so an attended
  session could be cancelled, reversing a payable earning (and, on the expert side, returning the credit). Now:
  upcoming only, idempotent; a doctor's no-show only after the 10-minute grace. · built 2026-10-30
- [ ] **LA-37 · A reschedule inside the window lost the credit, then the booking.** It was release-then-reserve
  from the phone. Now `reschedule_booking` is one transaction (a savepoint around release and claim) and is refused
  inside the window. · L.29 · built 2026-10-30
- [ ] **LA-38 · A host-missed purchase was refundable twice.** Any host-missed booking on the offering, ever, made
  every purchase refundable, consults and packs included (their credit had already come back). Now: masterclass and
  cohort only, the seat this purchase paid for in its run, and not if she holds or used another seat there. Expert
  cancellations count the same. · L.14, L.24 · built 2026-10-30
- [ ] **LA-39 · A refund cancelled seats it had not paid for.** `_revoke_purchase` cancelled every upcoming booking
  on the offering, leaving a sponsor's or another pack's credit spent on a dead seat. Now only this purchase's seats.
  · built 2026-10-30
- [ ] **LA-40 · A returned credit could come back expired.** · L.30 · built 2026-10-30
- [ ] **LA-41 · A started or closed slot could be booked.** · built 2026-10-30
- [ ] **LA-42 · The doctor's tap counted as the host being there.** `_host_seen` accepted the app's own row, written
  before the connection; LiveKit's record now wins when it has any rows. · built 2026-10-30
- [ ] **LA-43 · `host_unknown` settled anyway, and paid.** Now held until `resolve_host_alert`; the sweep also raises
  `host_left` for a host who left with 15+ minutes to go (gap A). · L.32 · built 2026-10-30
- [ ] **LA-44 · A late cancel paid nobody.** The credit was kept and the earning reversed. Now payable. · L.31 ·
  built 2026-10-30
- [ ] **LA-45 · The sponsor card counted every credit.** It mirrored the total, so bought and pack credits showed as
  the employer's (and twice); credits were re-read only at launch. Now `fromSource('sponsor')`, refreshed with
  bookings. · built 2026-10-30
- [ ] **LA-46 · A failed cancel looked like a cancel.** The repo swallowed the error and the phone cancelled anyway,
  and the merge never put the booking back. Now the phone cancels only on the server's `ok`, and says why when it
  cannot. · built 2026-10-30

A parent who does not come to a consult forfeits the credit and the doctor is paid. That was already the rule
(`_settle_slot` marks `missed`); it is recorded as L.31, not rebuilt.

### LATER### LATER

- [ ] **LA-23 · Referral credits are granted on the phone only** (`referral_store.dart:243`). Same fix shape as 0067:
  grant through `grant_consult_credits`. · — · unassigned · open
- [x] **LA-24 · The 0075 fallback in `livekit-token`.** · L.20 · **L3** · open · built 2026-10-29 in L3 (removed; an authorisation error is now a 500, never a role-less token), closed 2026-10-29, `54875c57`, deployed
- [x] **LA-25 · Raise hand has no rate limit.** · — · **L3** · open · built 2026-10-29 in L3, closed 2026-10-29, `54875c57`, deployed (sender cooldown 5 s; the host's screen ignores more than 3 hands or questions a minute from one person; "Pause hands and questions" sets that person's `can_publish_data` false at the media server through `livekit-moderate` `silenceHand`)
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
| **L2b** · **closed 2026-10-29, `7575940a`, 0126 run, functions deployed** | Server receipts and schedule: seeded `programmes`, `programme_runs`, refund rules, `payment_orders`, `course_purchases`, `payment_mode`, `has_course_access`, `record_course_purchase`, `my_purchases` (returning amount, status, paid and refunded dates, payment id and stage, for Your bookings, L.22), `claim_free_offering`, `record_stub_purchase`, the refund function, `book_slot` reading only server values, shop paid status; create-order, verify and a new `razorpay-webhook` | next free (≥ `0126`) | Runs it; deploys three functions; sets `RAZORPAY_WEBHOOK_SECRET`; adds the test webhook; checks that `book_slot` with no purchase is refused in live mode |
| **L2c** · **built 2026-10-29, not committed** | The app on the server: `PaymentService` sends only the id; `my_purchases()` replaces local minting (kept for revert); the app books `ps_<id>`; the preview through the stub; a recorded course sellable; refund copy; Your bookings gains Payments and reads receipts from the server (L.22) | — | Installs the build; walks buy → book → join in test mode |
| **L3** · **closed 2026-10-29, `54875c57`, 0128 run, functions deployed, LiveKit webhook added** (recordings open until Mux) | `livekit-webhook` (attendance, +10 / +20 states), room capacity, the 0075 fallback removed, egress → bucket → Mux → lesson, playback through `has_course_access`; Your bookings' Past shows attendance and the recording; LA-29 schedule check with a parity table; LA-32 expand; LA-34 | `0128` (`0127` went to TTC records) | Runs 0128 and its VERIFY; deploys five functions; adds the LiveKit webhook; S3 keys; then a Mux account for the recording walk; LiveKit Ship before the first paid class |
| **Credits fix** · **built 2026-10-30, waiting on the run** | LA-35 to LA-46: a cancel tells the truth, a one-transaction reschedule, refunds once, held sessions, the 6-argument `open_session_room` dropped | `0135` | Runs it and its VERIFY block |
| **L4** | Community phase 2 on this model (Part B of `course-receipts-then-community-p2.md`), including the doctor's "Your offerings" | next free | As in Part B |

**Why L2b and L2c are separate.** While L2b is live and L2c isn't, the old app keeps working because the server is
still in `stub` mode. When you change a contract, the server learns the new shape first and the client moves
after, so the people already using it never see a break.

**Migration numbers** (2026-10-29): L3 took `0128`; `0127` is another terminal's (TTC records, T4). L2b took `0126`. `0123` is free and is L2a's. `0124` (programme age window) and `0125` (Mind and
Mood entries) are other terminals'. Every later pass re-checks `ls supabase/migrations` first and takes the next
free number. Never rename another terminal's file.

**Done means:**
- every BLOCKER in §5 is ticked or explicitly parked by the user;
- the tests are green and the call sites have been grepped;
- the first real masterclass, course or cohort goes on sale by adding a `programmes` row, its sessions and a video,
  with no code change.

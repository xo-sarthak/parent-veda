# Notifications, Phase 6b: server push

GLOBAL-CHANGES #12, Phase 6b. Written 2026-10-29. **Status: PLAN ONLY. Nothing is
built until the user says so.** Read `docs/NOTIFICATIONS-PLAN.md` first: 6a is the
local half (three stores, one cap of two a day, offers off until she says yes, a
ready check on every type), and 6b is built on top of it, never instead of it.

## Out of scope

- **WhatsApp.** Its own engine (0015-0018, 0111, 0112). 6b copies its shape and
  does not touch it.
- **Care messages from the server.** Tips, check-ins, dated moments, the new week:
  these stay local and computed (6a). 6b sends only **offers and announcements**.
- **Anything targeted by TTC cycle phase or treatment step.** Those facts stay on
  the phone (decision 9). TTC campaigns target "trying" as a whole.
- **Images or rich media in a push, action buttons, and a per-user best send
  time.**
- **Any Firebase product other than Cloud Messaging.** No Analytics,
  Crashlytics, Auth, Firestore or Remote Config.
- **ParentVeda+ (the doctor app).** It gets no push in 6b (decision 6).
- **Directus screens for campaigns.** Campaigns are created with SQL functions
  now. Directus later writes the same table (decision 5).
- **Time zones other than India.** Every send is at 19:00 IST. `profiles.timezone`
  exists, but nothing outside India is served yet.
- **Fixing `syncAll`'s cancel-all** (BACKEND-PATTERNS §16m, BEFORE-LAUNCH line
  334). Still owed, and still its own pass. 6b adds no local scheduler, so it
  does not make that trap worse.

## The idea, in one line

**The server sends a normal notification, the way every app in this field does,
so it arrives on iPhone as reliably as on Android. To keep 6a's promises, the
phone uploads the few facts the server cannot know.** Those are which evenings
are already taken, and whether she is in a quiet period after a loss. The server
never recomputes what the phone knows. It only reads what the phone tells it.

## Why the server decides (and what it costs)

Two ways were weighed on 2026-10-29:

| | **Server sends a visible notification** (chosen) | Server sends a silent nudge, the phone decides |
|---|---|---|
| iPhone | Reliable | Apple throttles silent pushes and drops them after a force-quit |
| The cap | The server needs a copy of the phone's plan | Exact, because the phone's own planner decides |
| Loss and opt-out | The server needs a copy | The phone checks its own state, even offline |
| Who does it | Flo, BabyCenter, nearly everyone | Few |

The user's call: **"we need server side then like other apps do, can't
compromise on iPhone users."**

**The trade-off we accepted.** The server's copy of her plan can be a few hours
stale, and a stale copy can be wrong. If she logs something that creates a new
evening message after her phone last uploaded, and the server books the same
evening, she gets three that day. That is rare, because it needs a new evening
message *and* a campaign on the same day *and* no app open in between. It is
also small, because it is one extra, never a missed care message. The rest of
this plan is about keeping that copy small, fresh and safe when it is missing.

**The general fact.** Moving a decision to a server means moving its inputs
there too, and a copied input is a cache. A cache needs one of two things: a
rule for when it is too old, or a shape where "missing" means the safe answer.
We use the second (see "busy evenings" below).

## The flow

```
 phone                               Supabase                          Firebase
 -----                               --------                          --------
 register token  ──────────────►  push_devices
 consent yes/no  ──(retried)───►  push_consent
 busy evenings,  ──────────────►  push_audience
 quiet flag
                                  10:00 IST  pv_push_enqueue()  (pg_cron)
                                    decides who gets what, today,
                                    writes push_sends rows (queued)
 refresh reads   ◄──────────────  push_sends (own rows)
 today's booking: its own
 evening message goes to
 Messages only
                                  19:00 IST  push-send edge function (pg_cron + pg_net)
                                    reads queued rows, sends  ─────────►  FCM ──► APNs (iPhone)
                                    marks sent / failed,                     └──► Android
                                    deletes dead tokens
 tap  ──► opens the campaign's page (B0)
```

**Decide, then send, and never in one step.** The same split as WhatsApp's B3/B4.
`pv_push_enqueue` only writes rows. `push-send` only drains them. A cron job that
fires twice hits the unique key and does nothing. A sender that crashes halfway
picks up the rows still `queued` on the next run, so a half-finished send resumes
and is never repeated.

## The tables

### `push_devices`: where to reach her

| Column | Note |
|---|---|
| `user_id` | uuid, references `auth.users`, `on delete cascade` |
| `device_id` | text, minted by the app once per install (app-generated ids, CLAUDE.md) |
| `token` | the FCM token. It rotates, and the new one overwrites the row |
| `platform` | `android` / `ios` |
| `app_version` | so a send can skip builds too old to route the tap |
| `last_seen_at` | refreshed on each app open |
| primary key | (`user_id`, `device_id`) |

**Writes go only through functions.** `pv_push_register(device_id, token,
platform, app_version)` is `security definer` because it must also delete **the
same token under any other account**. One phone signed in as two people one
after the other must not keep the first person's offers. RLS can't let her
delete another person's row, and it shouldn't. A definer function can, after
checking `auth.uid()`. `pv_push_unregister(device_id)` runs on sign-out, before
the session goes. **No select policy:** nothing in the app reads tokens. This is
the write-only shape, BACKEND-PATTERNS §8.

### `push_consent`: her yes or no, per stage

| Column | Note |
|---|---|
| `user_id`, `stage` | primary key. Stage is `ttc` / `pregnancy` / `parenting` (decision 2) |
| `granted` | boolean |
| `decided_at` | when she answered (the DPDP Act record, like `wa_consent_at`) |
| `source` | `messages_card` / `messages_switch` |

**Why a table and not the existing blob.** Her answer already syncs inside
`user_state` (`preg_messages`, `ttc_messages`, `pp_messages`, items `offers` and
`offersAsked`). The rule from §16jj is: a column when someone other than this
phone reads it. The sender is that reader, and a key inside a jsonb blob is a
`where` clause nobody writes well. The blob keeps what it has, because the phone
still reads it there. The table is written alongside it, as one more write.

**A "no" is never fire-and-forget.** Elsewhere, a cloud write that fails is
dropped (CLAUDE.md). A dropped opt-out would mean offers keep coming after she
said no, so the opt-out goes through a retrying outbox until the server confirms
it. The "yes" can be fire-and-forget: if it fails, she simply gets nothing yet,
which is the safe direction. **One rule, worth keeping: the cost of losing a
write decides how hard you try to deliver it.**

Writes go through `pv_push_consent(stage, granted, source)`, own row only. Own
select is allowed, so the phone can check the server agrees.

### `push_audience`: the facts the phone tells the server

| Column | Note |
|---|---|
| `user_id` | primary key |
| `busy_evenings` | `date[]`, the evenings in the next 14 days where the phone has already set a 19:00-slot notification |
| `quiet` | boolean, the phone's "no offers now" (loss, see decision 8) |
| `planned_at` | when the phone last uploaded |

**Why busy evenings and not free ones.** Pick the shape where missing data means
the true answer. The phone only sets notifications up to 14 days ahead. So any
evening *not* in the list, including every evening past the upload's horizon,
really is free on that phone. With a "free evenings" list, a phone that hadn't
opened the app in three weeks would have no free evenings left, and would never
get a re-engagement offer. Both lists hold the same information. Only one of
them is right by default.

The upload comes from `FamilyPhone.rearm()`, which already knows the winners for
every slot, so there is no new computing on the phone, only a write of what it
just decided. It is fire-and-forget and coalesced to at most one per rearm. A
lost upload costs at worst one extra notification on one evening, so a retry is
not worth it.

### `push_campaigns`: what to say

| Column | Note |
|---|---|
| `id` | text, a readable slug (`garbh-sanskar-class-nov`) |
| `kind` | `offer` / `announcement` |
| `title`, `body` | fixed text, with no placeholders (decision 10) |
| `link_kind`, `link_id` | what the tap opens, in the vocabulary `SavedItemOpener` already maps (`course`, `product`, `expert`, `read`) |
| `stages` | `text[]` |
| `week_from`, `week_to` | pregnancy weeks, nullable |
| `child_months_from`, `child_months_to` | parenting, nullable |
| `starts_on`, `ends_on` | dates (IST) |
| `status` | `draft` / `approved` / `cancelled` |
| `created_at`, `approved_at` | |

**Typed columns, not a `target jsonb`.** A column can be checked, indexed and
pinned by a contract test. A jsonb rule can express targeting the sender doesn't
implement, which is CLAUDE.md's "a config object that can express more states
than the product has is a bug surface", in a table.

Readable by `authenticated` when `status = 'approved'` (the phone shows today's
booked campaign in Messages). Written only by `service_role` and the admin
functions.

### `push_sends`: the log, and the booking

| Column | Note |
|---|---|
| `id` | uuid |
| `campaign_id`, `user_id` | unique together: **one campaign reaches a person at most once** |
| `send_on` | the date (IST) |
| `status` | `queued` / `sent` / `failed` / `skipped` |
| `error`, `devices_sent`, `sent_at` | |

Server-written only. **Own select allowed**, because this table is also the
booking: the phone reads its rows for the coming days and gives that evening to
the campaign, so its own message for that evening goes to Messages without
ringing.

## How each rule holds

### The cap: two a day (decision 3)

- A campaign takes the **evening slot (19:00)** and nothing else.
- `pv_push_enqueue` books her only on an evening **not** in `busy_evenings`, and
  only if no other campaign is already booked for her that evening.
- **At most two campaigns a week per person** (decision 11). Without a weekly
  limit, "two a day" would allow fourteen offers a week, the top complaint
  about Flo in the 6a research.
- On the phone, a booking counts as rank 6 (offer) or 5.5 (announcement) in
  `familyPhonePlan`. If the phone learns of a booking before 19:00, its own
  evening message goes to Messages only.
- Quiet hours need no new code: 19:00 sits inside 6a's 8 am to 7 pm window.

### Consent (decision 2)

A send needs all four of these:
1. `push_consent.granted` for her **current** stage (`profiles.life_stage`).
2. A token in `push_devices`.
3. On Android, the "Offers and new things" channel switched on (the OS drops it
   otherwise, and we cannot see that, which is fine).
4. The phone's notification permission (the OS enforces it).

**Uninstall:** FCM answers `UNREGISTERED` on the next send, and `push-send`
deletes that token. **Sign-out:** `pv_push_unregister` plus FCM `deleteToken`.
**Account delete:** cascade. **Reinstall and sign back in:** her consent comes
back from the cloud. It stands until she withdraws it, which is how the DPDP
Act treats consent.

Announcements need the same yes as offers in 6b (decision 7). Apple 4.5.4
covers "promotional", and a "new feature" note sits close enough to that line
not to argue it.

### Never on a loss path (decision 8)

- **Pregnancy:** the server already knows. The same condition as WhatsApp 0112:
  `pregnancy_ended_at` is null, or `pregnancy_ended_at < life_stage_at`.
- **TTC:** the phone sets `push_audience.quiet = true` while 6a's TTC daily
  kinds are silent after a loss (cycle start null until her first period). The
  server reads it.
- **Every stage:** a missing `push_audience` row is not quiet, because a phone
  that never uploaded has had no loss recorded on it either. The pregnancy check
  covers the case that matters most even with no row.
- `pv_push_enqueue` applies both checks. A test pins each side, as
  `stage_transitions_test` does for WhatsApp.

### A clinic-owned date is never second-guessed

- The week comes from `profiles.due_date`, read exactly as WhatsApp reads it
  (`wa_pregnancy_week`). That stored date already is the clinic's when
  `due_date_source` says so. The server reads it and never recomputes it from a
  period date.
- A campaign's text has **no placeholders** (decision 10), so it can never say
  "you are at 20 weeks". `pv_campaign_create` refuses a body or title containing
  `{{`, or a week or day number.

### Targeting without recomputing

| Target | The server reads | New from the phone |
|---|---|---|
| Stage | `profiles.life_stage` | nothing |
| Pregnancy week | `profiles.due_date` through `wa_pregnancy_week` | nothing |
| Child age | `children.dob` for her children (the rows `my_child_ids()` gives her) | nothing |
| TTC phase | not used | nothing |
| Loss quiet | 0112 condition, `push_audience.quiet` | `quiet` |
| Busy evenings | `push_audience.busy_evenings` | `busy_evenings` |

Two new facts leave the phone, and neither is health data in itself.

## Who creates a campaign (decision 5)

SQL functions in the Supabase SQL editor now. Directus writes the same table
later.

| Function | Does |
|---|---|
| `pv_campaign_create(...)` | Creates a `draft`. Refuses placeholders, an empty link, or an `ends_on` before `starts_on` |
| `pv_campaign_dry_run(id)` | Returns how many people would get it today, and how many are skipped and why (no consent, busy, quiet, weekly limit) |
| `pv_campaign_test(id)` | Sends it now to **your own devices only**, whatever the targeting |
| `pv_campaign_approve(id)` / `pv_campaign_cancel(id)` | Moves the status. A cancel also marks its `queued` rows `skipped` |

**Content is editable, rules are not.** Title, body, link, targeting and dates
are data. The cap, consent, loss quiet, weekly limit, send time and ranks are in
code (the SQL functions and the phone), and no row can change them.

## Tap routing first (decision 4, build step B0)

Today a tap is matched by notification id (`NotificationService._deliverTap`),
and STILL-OPEN §79.14(b) records that taps don't always open their page. A
push has no local id, so it carries its destination in its data
(`link_kind`, `link_id`). B0 makes every tap, local or pushed, open through one
opener (the one `SavedItemOpener` already is for saved items). The app's
research found "a message that opens the wrong page" among the top complaints,
so a push that lands on the home screen is a failure, not a detail.

### As built: B0 (2026-10-30)

**The address travels with the notification.** Each notification now carries a
payload, `{"link_kind": ..., "link_id": ...}`, in the same shape a push's data
will have. One opener, `NotificationOpener.open`
(`lib/screens/notification_opener.dart`), turns it into a page. `main.dart`
registers it with `NotificationService.setLinkOpener`. A tap that launches the
app is held until it is registered.

| Piece | File | What it does |
|---|---|---|
| `NotificationLink` | `lib/services/notification_link.dart` | The two fields, `payload` / `parse` / `fromData`. Pure |
| Payload in and out | `lib/services/notification_service.dart` | `scheduleOneOff(payload:)`. The tap and launch handlers read `r.payload`. A payload goes to `openLink`, and no payload goes to the old id listeners |
| Every stage message | the three messages stores | Armed with `ttc_message` / `preg_message` / `pp_message` plus the message's own id. `messageById` looks it up |
| Old notifications | `handlePhoneTap` in each store | Ones armed before B0 have no payload. The id is guessed into a message as before, then sent to the same opener as a link |
| The one opener | `lib/screens/notification_opener.dart` | Stage messages: waits for the store, finds the message by id, marks it read, hands it to its stage's own opener. `product` / `course` / `expert` / `read` open the page, or say it has gone. An unknown kind says "needs a newer ParentVeda" |

**Gaps closed:**

- **The message was guessed.** "The newest of its kind" opened today's tip from
  yesterday's notification. Now the tap opens that exact message.
- **Silent taps.** A gone message, a page that doesn't resolve (Pregnancy
  check-in, scans; TTC destinations) and a profile that never opens (the
  10-second wait in TTC and Pregnancy) now show a pvToast and open the nearest
  real place.
- **Parenting landed on the home screen** for four kinds. On the user's call:
  - a new stage opens `PhaseDetailScreen`;
  - the Monday activity opens the page for the stage the child was in that
    Monday;
  - the tip opens that morning's tip (`SavedTipScreen`);
  - the age note stays on the child's home, because that is the age page.

**Test:** `test/notifications_b0_tap_test.dart` pins every kind in all three
stages to its destination. A new kind with no row fails the build. It also
covers the by-id tap, the payload shape, the toasts and the wiring.
`last_profile_test`, `preg_messages_test` and `ttc_tools_pass_e_test` were
updated for the new path, and the eight phone fakes took the `payload`
parameter.

**Out of B0, owed:**

- **14 older schedulers still only open the app on a tap.** They are
  reminders, medicines, vaccines, appointments, bookings, sessions, referrals,
  brand messages, prescriptions, feeding, mood check, health records, the TTC
  ready plan and habits, and the doctor app. Each now only needs a `payload:`
  and a kind in the opener.
- The `syncAll` fix (STILL-OPEN §79.14(b)), as planned.
- A tip for a child who was not active when it was armed was picked with no
  correction for prematurity. The tap opens it with that child's correction.
  For a baby born early, the page and the notification can be a few days of
  age apart. Same day, same child, so it is accepted.
- The phone walk (B6).

### As built: B1 (2026-10-30)

**Firebase is in the app, and a build without its config still starts.**
`firebase_core` ^5.1.0 and `firebase_messaging` ^17.0.1, FCM only (no
Analytics). The Firebase project is `parentveda-15ec4`, with three Android
apps registered: `com.parentveda.app`, `.doctor` and `.partners` (the partner
flavour arrived with Partner Editions P1 and needs registering too).

| Piece | File | What it does |
|---|---|---|
| `PushService` | `lib/services/push_service.dart` | `init()` starts Firebase. If that throws (no config), push stays off: `ready == false`, the logged-out shape, nothing wired. If it starts, a tap from the background (`onMessageOpenedApp`) and a tap that launched the app (`getInitialMessage`) both go to `openLink(NotificationLink.fromData(data))` |
| The call | `lib/main.dart` | `PushService.instance.init()`, not awaited, right after `setLinkOpener`. A launch tap is held by B0's opener until it is registered, so the order is safe either way |
| The plugin, guarded | `android/settings.gradle.kts`, `android/app/build.gradle.kts` | Google services plugin 4.5.0, declared `apply false`, applied only `if (file("google-services.json").exists())`. Applied always, a missing file fails the BUILD, not the app |
| Secrets | `.gitignore` | `*firebase-adminsdk*.json` (the old patterns missed Firebase's key file name) and `android/app/google-services.json`, plus the iPhone plist for B7 |

**Why the guard is in Gradle and in Dart:** "no config must not crash" has two
places to fail. Gradle would refuse to build; Dart would throw at start. Each
side holds the rule on its own.

**Every flavour's app id must be in `google-services.json`.** Once applied,
the plugin checks every variant. A new flavour means registering its id in
Firebase and downloading the file again; the test fails on a fourth flavour
to say so.

**Not in B1:** the token and its upload (B2); permission (the app already asks
through `flutter_local_notifications`); a push that arrives while the app is
open, and the Android notification channel pushes use (B4/B5). The doctor and
partner apps never call `PushService` (decision 6), though the plugin is
compiled into them.

**Test:** `test/push_b1_test.dart`: Firebase throwing is caught (async, sync
and the real plugin with no platform); taps are wired once; a tap opens its
link or is held; the guarded plugin; the three flavours; main.dart wiring and
the doctor/partner apps left out; both ignore lines.

**Owed:** the real proof is a build. Build `--flavor parent` once with the file
and once with it moved away, plus `--flavor doctor` and `--flavor partner` with
it, and start each on a phone. On the user's word. The setup (steps 1 to 3)
is done; the service-account key (step 4) is created and kept outside the
repo until B4.

### As built: B2 (2026-10-30)

**The server now has what it needs to decide, and nothing reads it yet.**
Migration `0140_push_devices_consent_audience.sql` (run it before installing a
B2 build). The phone writes only through four functions; no table grants
insert or update.

| Piece | File | What it does |
|---|---|---|
| Tables + functions | `supabase/migrations/0140_push_devices_consent_audience.sql` | `push_devices`, `push_consent`, `push_audience`, and `pv_push_register` / `pv_push_unregister` / `pv_push_consent` / `pv_push_audience`, all `security definer`, each checking `auth.uid()` |
| The wire | `lib/services/push_wire.dart` | The four function names, one builder per parameter list, the stage and source words. The only way the push classes reach Supabase |
| The token | `lib/services/push_service.dart` | On app open and sign-in (the auth stream), only when `ready`: `pv_push_register` with a per-install `device_id` and `linkVersion`. Again when FCM rotates the token. `signOut()`: queued consent, then `pv_push_unregister`, then FCM `deleteToken`, each limited to 5 s. An expired session deletes the token on the phone only |
| Sign-out | `lib/screens/profile/pv_account_actions.dart` | `PushService.signOut()` runs **before** `auth.signOut()`; afterwards there is no session to prove whose row it is |
| Consent | `lib/services/push_consent.dart` | Called from the offers card and switch in all three stores. A "no" goes to disk first and is retried (app open, sign-in, sign-out, then 30 s, 2 min, every 10 min). A "yes" is sent once |
| Audience | `lib/services/push_audience.dart`, `lib/services/family_phone_plan.dart` | After each re-arm, every evening that rings in the next 14 days (Pregnancy, Parenting and TTC), plus TTC `quiet`. Only once all three stores have loaded, only when it changed |
| Wipe | `lib/services/auth/local_wipe.dart` | Keeps `push_device_id` and the consent queue |

**Changed from the plan above, each for a reason:**

- **The stage is `trying`, not `ttc`**: `profiles.life_stage`'s own word, so B3
  joins consent to the profile with a plain `=`.
- **`link_version int` in place of `app_version`.** The server's question is
  "can this build open this link kind?". A number raised by hand when the
  opener learns a kind (`PushService.linkVersion`, now 1) answers it. A
  version string answers a different question and is awkward to compare.
- **`pv_push_consent` takes when she decided.** A queued "no" can land hours
  late. The server keeps the newest decision by that time (clamped to now), so
  a late "no" from one phone never overwrites a later "yes" from another.
- **The token is unique across the whole table**, not only cleared by the
  function: one phone, one account, as a rule of the schema.

**TTC quiet** is `CycleStore.restartOn != null && lastPeriodStart == null`: a
loss recorded while trying, and no period logged since. It is the same condition
that silences 6a's daily TTC kinds, derived, not stored.

**Found while testing:** a consent flush that began as one account could send
its entry after the account switched, and the RPC writes as whoever is signed in
now. Each send re-checks the account right before it goes.

**Kept on the deprecated token API on purpose.** firebase_messaging 17 deprecates
`getToken` / `deleteToken` / `onTokenRefresh` for `register()` / `onRegistered`,
which return a Firebase Installation ID for a newer direct-send path. B4's
sender uses the HTTP v1 API, whose documented target is the token. Moving to
the ID is a B4 decision, taken with the sender.

**Test:** `test/push_b2_contract_test.dart`: each builder's keys equal the
function's parameters in 0140; the three tables' columns; the stage, source and
platform words equal the checks (and stage equals `profiles.life_stage`); no
direct grants, one select policy; the token rule and newest-wins; the queue (a
"no" kept on failure, a "yes" never queued, latest wins per stage, an entry waits
for its own account, logged out records nothing); busy evenings; the upload
coalescing; the wiring (sign-out order, the wipe, FamilyPhone, all three stores);
PushService with and without Firebase. `auth_delete_account_test` and
`sync_reset_coverage_test` list the two new keys and two files, with why.

**Owed from B2:**
- ~~Run 0140 (the user), before installing.~~ Run 2026-10-30.
- People who said yes before B2 have no consent row. No real users yet; a tester
  switches offers off and on once.
- The phone walk (B6): sign in and see a `push_devices` row; switch offers off
  and on and see `push_consent`; open Messages and see `push_audience`; sign out
  and see the device row gone.
- B1's build check still stands.

### As built: B3 (2026-10-30)

**The server now decides who gets what tonight, and writes it down. Nothing
sends yet (B4).** Migration `0143_push_campaigns_and_sends.sql` (run it
before installing a B5 build; B3 has no phone build of its own beyond the
quiet flag). Verify by hand: `supabase/seed/verify_push_campaigns.sql`
(50 checks, ends in a red "error" that is the report and rolls everything
back).

| Piece | Where | What it does |
|---|---|---|
| `push_campaigns` | 0143 | The text, link, stages, week / child-month range, dates, `priority`, status. Readable by her only once approved AND booked for her |
| `push_sends` | 0143 | The booking and the log: `send_on`, `send_before` (21:00 IST), status, `tapped_at` (B5). Unique per (campaign, person) and per (person, evening) unless skipped. Own select |
| `pv_push_holdout` | 0143 | The 10%: md5 of a salted user id, never `hashtext` |
| `pv_push_check` | 0143 | **Every rule, once.** One row per campaign and person in its stages, with the first rule that failed |
| `pv_push_enqueue` | 0143, cron `push-enqueue-daily` 04:30 UTC = 10:00 IST | Takes the rows with no reason, keeps one per person (priority, then sooner end), inserts `on conflict do nothing`. Books nothing once tonight's cutoff has passed |
| `pv_campaign_create` / `_dry_run` / `_approve` / `_cancel` | 0143 | The SQL-editor admin. Create rewrites a draft only; dry run counts outcomes, including `another_campaign_wins`; cancel turns queued bookings to `skipped` |
| The quiet flag | `lib/services/push_audience.dart` | `pushTtcQuiet` = trying AND (after a loss OR two-week wait / late OR an active treatment round). Still one yes/no |

**The rules, in the order `pv_push_check` tries them:** not live, no
consent for her current stage, no device able to open the link, holdout,
signed up within 7 days, the 0112 loss condition, phone quiet, a child born in
the last 14 days (hers or her partner's, not removed), week / child-age
targeting, this campaign already reached her, a busy evening, another
booking tonight, a campaign in the 7 days ending tonight (cap **1**).

**Why it is shaped this way:**

- **One function holds the rules; enqueue and the dry run both read it.**
  A dry run that kept its own copy would be right on the day it was written
  and drift after. Two readers of one rule cannot disagree.
- **The text rules are table checks.** Length, placeholders, a week or day
  number, the stage words, the link kinds, dates in order. Directus will write
  the table directly (decision 5) and skip every function; a check on the
  table holds for every writer.
- **"One an evening" is a unique index as well as a rule.** Two runs at once
  could each read "nothing booked" and both insert. A rule a race can break
  needs a constraint.
- **The weekly cap counts 7 rolling days**, not the calendar week, so a
  Sunday and the Monday after are not "one a week" twice.
- **md5 for the holdout.** `hashtext` is not promised stable across Postgres
  upgrades; a holdout that reshuffles mixes the groups and the measurement is
  lost.
- **No function is open to the app.** `pv_push_check` reads everyone's consent
  and audience. Revoked from `public`, `anon` and `authenticated` (Supabase
  grants new functions to both by default); `service_role` only.

**Changed from the plan above, each for a reason:**

- **The stage gate on the quiet flag.** A TTC cycle that reads "late" because
  she got pregnant would have silenced her pregnancy offers for good. The flag
  now speaks only while she is trying; a pregnancy loss is the server's own
  0112 check.
- **A phase that can't be worked out reads as quiet** (the safe direction).
- **"Active treatment" is any open round** (IVF, IUI, FET, tablets) from its
  first date until she closes it: `ttcTreatmentActive`, the same function
  the TTC home uses.
- **The week/day check lets a hyphen through.** "Week 20", "3 days left" and
  "20th week" are refused; "a 7-day trial" is not a count about her and passes.
- **`pv_push_link_needs(kind)`** answers "which build opens this kind" (all
  four kinds need 1 today). Raise it with `PushService.linkVersion`.

**For B4 (the sender):** read `queued` rows for today, send only while
`now() < send_before`, else mark them `skipped` with error `past_cutoff`.
Fill `sent_at`, `devices_sent`, `status`, `error`. The phone's tap needs the
booking's `id` in the push data to fill `tapped_at` (B5).

**Test:** `test/push_b3_contract_test.dart` pins both tables' columns, the
constants (1 a week, 10%, 7 days, 14 days, 21:00, the 10:00 cron), the rule
order and its doc comment, the 0112 condition word for word, no TTC table read,
the text checks (the week/day regex run against real titles), every link kind
in `NotificationOpener.kinds`, the grants and both policies, cancel, and the
quiet flag's truth table and wiring.

**Owed from B3:**
- ~~Run 0143, then the verify file (the user).~~ Run 2026-10-30: cron job 5, verify PASSED 50 FAILED 0, none skipped.
- **A stale quiet flag.** The flag is as fresh as her last app open. If she
  opens the app in her fertile window and not again for five days, the server
  still reads "not quiet" in her two-week wait. The fix, if the walk shows it
  matters: `quiet_evenings date[]`, the busy-evenings shape.
- Campaign text can still be edited after approval by a direct table write
  (the Directus phase should lock it).

## Costs

List prices as of 2026-10. Re-check them at build time. ₹84 = $1.

| Item | USD | INR |
|---|---|---|
| Firebase Cloud Messaging, Android and iPhone | $0, no per-message charge | ₹0 |
| Firebase project (Spark plan, FCM only) | $0 | ₹0 |
| Edge function calls: about 10 a day for the sender | $0 within the plan (Free 500K a month, Pro 2M) | ₹0 |
| `push_sends` rows: 10,000 people × 8 a month ≈ 80,000 small rows | $0 within the plan | ₹0 |
| `pg_cron`, `pg_net` | $0 | ₹0 |
| Apple Developer Program (iPhone only, already on BEFORE-LAUNCH) | $99 a year | ≈ ₹8,300 a year |
| A Mac or a cloud build service, to build for iPhone | from $0 (Codemagic has a free tier) | from ₹0 |

**At our size, 6b costs nothing extra on Android.** iPhone costs only the Apple
account you need for the App Store anyway.

## Setup the user does

**Android (free, about 15 minutes):**
1. Make a Firebase project at firebase.google.com.
2. Add two Android apps: `com.parentveda.app` and `com.parentveda.app.doctor`.
   The doctor app gets no push, but the Google services build plugin fails a
   flavor whose app id isn't registered, so registering it keeps that build
   working.
3. Download `google-services.json` (it covers both) for `android/app/`.
4. Create a service-account key for the FCM HTTP v1 API, and paste it into
   Supabase as a function secret (`FCM_SERVICE_ACCOUNT`). FCM's old "server
   key" has been retired, so v1 is the only way.

**iPhone (when the Apple account exists):**
5. Apple Developer account.
6. In Apple's console: the App ID `com.parentveda.app` with Push Notifications
   on, and an APNs auth key (`.p8`). Upload the key to Firebase.
7. `GoogleService-Info.plist`, and in Xcode the Push Notifications and
   Background Modes capabilities. That needs a Mac or a cloud build service.

**Supabase:**
8. Run the 6b migrations in the SQL editor.
9. Turn on `pg_net` (Database, Extensions). It's new to this project and lets
   `pg_cron` call the edge function.

## Build order (each step on the user's word)

| Step | What | Done when |
|---|---|---|
| B0 | One tap opener for every notification, local and pushed | A tap on each 6a kind opens its page. The `syncAll` fix stays out of scope. **BUILT 2026-10-30**, see "As built: B0" |
| B1 | Firebase in the app (`firebase_core`, `firebase_messaging`). It must not crash with no config: an unconfigured Firebase behaves like being logged out | The app starts on a build with no `google-services.json`. **BUILT 2026-10-30**, see "As built: B1"; the build check is owed |
| B2 | Migration: `push_devices`, `push_consent`, `push_audience` and their functions. Phone: register, unregister on sign-out, consent with the retrying opt-out, the audience upload from `FamilyPhone` | Contract test pins every column the phone sends (as `ttc_schema_contract_test`). **BUILT 2026-10-30**, see "As built: B2"; 0140 run 2026-10-30 |
| B3 | Migration: `push_campaigns`, `push_sends`, `pv_push_enqueue`, the admin functions, the 10:00 IST cron. Plus decisions 15 to 22 (holdout, `tapped_at`, 7-day grace, wider quiet incl. the phone flag, priority, cutoff, length limits, 1 a week) | `supabase/seed/verify_push_campaigns.sql` passes by hand. **BUILT 2026-10-30** (04132625), see "As built: B3"; 0143 run, verify 50/0 |
| B4 | Edge function `push-send`: FCM HTTP v1, batches, dead tokens, the 19:00 IST cron through `pg_net` | `pv_campaign_test` reaches your phone |
| B5 | Phone: read bookings, give the evening to the campaign, show it in Messages | Planner tests: a booked evening never rings two |
| B6 | Phone walk, on the user's word | See "Owed" |
| B7 | iPhone, once the Apple account exists | One test campaign on an iPhone |

The wiring gate applies to each step: grep the call site of every new function
before calling it done.

## Risks

- **Phone makers that kill apps.** Xiaomi, Oppo and Vivo let a user "force
  stop" an app, and a force-stopped app gets nothing until it is opened again.
  This is true for every app. We can't fix it, only avoid making it worse (no
  wake locks, no background service).
- **Three in a day.** The rare stale-plan case above. Accepted. If the phone walk
  shows it is not rare, the fix is to book a day ahead instead of the same day.
- **Firebase on a build without config.** It must fail quietly, not crash (B1).
- **A campaign link the build cannot open.** `app_version` on the device row lets
  the enqueue skip builds older than the link kind needs.

## Decision record

| # | Question | Recommended | User's call | Date |
|---|---|---|---|---|
| 1 | Who decides what rings: the server or the phone? | The phone (silent nudge) | **The server, like other apps: "can't compromise on iPhone users"** | 2026-10-29 |
| 2 | Offers consent: one switch, or one per stage? | Per stage, as 6a has it | Recommended | 2026-10-29 |
| 3 | Does a campaign count against the two a day? | Yes, evening slot, rank 6 (offer) or 5.5 (announcement) | Recommended | 2026-10-29 |
| 4 | Fix tap routing first? | Yes, B0 | Recommended | 2026-10-29 |
| 5 | Who creates campaigns? | SQL functions now, Directus later, same table | Recommended | 2026-10-29 |
| 6 | Push in ParentVeda+ (doctor app)? | Not in 6b | Recommended | 2026-10-29 |
| 7 | Do announcements need the offers yes? | Yes, the same yes | Recommended ("all recommended") | 2026-10-29 |
| 8 | How does the server know about a loss? | Pregnancy: the 0112 condition. TTC: a `quiet` flag from the phone | Recommended ("all recommended") | 2026-10-29 |
| 9 | Target TTC by cycle phase? | No, stage only. Phase stays on the phone | Recommended ("all recommended") | 2026-10-29 |
| 10 | Placeholders in campaign text? | None in 6b. Fixed text only | Recommended ("all recommended") | 2026-10-29 |
| 11 | A weekly limit on campaigns per person? | Two a week | Recommended ("all recommended") | 2026-10-29 |
| 12 | Firebase: which parts? | FCM only, on both platforms (one sending path) | Yes: "im on board with firebase" | 2026-10-29 |
| 13 | Busy evenings or free evenings? | Busy, so a missing upload means free, which is true | Recommended (a design detail, found writing this plan) | 2026-10-29 |
| 14 | Android and iPhone together? | Android first (B0 to B6), iPhone as B7 | **"android first, apple later"** | 2026-10-29 |
| 15 | A holdout group that never gets campaigns? | Yes, 10%, a fixed hash of user_id, so push's effect on daily use can be measured | Recommended ("all 7") | 2026-10-30 |
| 16 | Record a tap? | `push_sends.tapped_at`, added in B3, filled by the phone in B5 | Recommended ("all 7") | 2026-10-30 |
| 17 | Campaigns in her first days? | None in the first 7 days after sign-up | Recommended ("all 7") | 2026-10-30 |
| 18 | Quiet beyond a loss? | Also the TTC two-week wait, active IVF/IUI treatment (both through the phone's `quiet` flag), and the first 14 days after a birth (server) | Recommended ("all 7") | 2026-10-30 |
| 19 | Two campaigns compete for one evening? | A `priority` column, then the one ending sooner | Recommended ("all 7") | 2026-10-30 |
| 20 | A send running late? | Each booking carries a cutoff (21:00 IST); B4 skips past it, never a night buzz | Recommended ("all 7") | 2026-10-30 |
| 21 | Text length? | `pv_campaign_create` refuses a title over ~50 or a body over ~150 characters (lock-screen truncation) | Recommended ("all 7") | 2026-10-30 |
| 22 | Weekly limit at launch (revises row 11)? | One a week, one constant, raised to two once open and opt-out rates look healthy | Recommended: **"cap 1 at launch"** | 2026-10-30 |

Rows 7 to 11 and 13 were written while turning the agreed calls into tables.
The user's "all recommended" covered them. If any reads wrong, change it here
before B2.

## Owed

- **Before B2:** ~~the user's Firebase setup (steps 1 to 4)~~ done 2026-10-30
  (project `parentveda-15ec4`, three Android apps, key kept outside the repo),
  and `pg_net` (step 9), turned on by the user 2026-10-30.
- **During the build:** ~~a BACKEND-PATTERNS section for 6b~~ written with B2
  (§16zzz-a), and B2's sync-log step (step 31). Still owed: the BEFORE-LAUNCH lines below.
  Original note: a BACKEND-PATTERNS section for 6b. It should cover
  "moving a decision moves its inputs", "the cost of losing a write decides how
  hard you deliver it" and "pick the shape where missing means the true answer".
  Also a `docs/BACKEND-SYNC-LOG.md` step for the new tables, and BEFORE-LAUNCH
  lines for the Firebase project, the Play listing's notification disclosure,
  and the DPDP check (line 144) extended to server offers.
- **After the build:** a phone walk on the user's word. A test campaign arrives
  at 19:00. A busy evening is skipped. "Not now" stops the next one. Sign-out
  stops it on that phone. A tap opens the page.

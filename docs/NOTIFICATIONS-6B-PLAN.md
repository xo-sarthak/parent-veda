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
| B0 | One tap opener for every notification, local and pushed | A tap on each 6a kind opens its page. The `syncAll` fix stays out of scope |
| B1 | Firebase in the app (`firebase_core`, `firebase_messaging`). It must not crash with no config: an unconfigured Firebase behaves like being logged out | The app starts on a build with no `google-services.json` |
| B2 | Migration: `push_devices`, `push_consent`, `push_audience` and their functions. Phone: register, unregister on sign-out, consent with the retrying opt-out, the audience upload from `FamilyPhone` | Contract test pins every column the phone sends (as `ttc_schema_contract_test`) |
| B3 | Migration: `push_campaigns`, `push_sends`, `pv_push_enqueue`, the admin functions, the 10:00 IST cron | The SQL in "How to test" passes by hand |
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

Rows 7 to 11 and 13 were written while turning the agreed calls into tables.
The user's "all recommended" covered them. If any reads wrong, change it here
before B2.

## Owed

- **Before B2:** the user's Firebase setup (steps 1 to 4) and `pg_net` (step 9).
- **During the build:** a BACKEND-PATTERNS section for 6b. It should cover
  "moving a decision moves its inputs", "the cost of losing a write decides how
  hard you deliver it" and "pick the shape where missing means the true answer".
  Also a `docs/BACKEND-SYNC-LOG.md` step for the new tables, and BEFORE-LAUNCH
  lines for the Firebase project, the Play listing's notification disclosure,
  and the DPDP check (line 144) extended to server offers.
- **After the build:** a phone walk on the user's word. A test campaign arrives
  at 19:00. A busy evening is skipped. "Not now" stops the next one. Sign-out
  stops it on that phone. A tap opens the page.

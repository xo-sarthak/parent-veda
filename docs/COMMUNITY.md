# Community — the plan, the build, and what is left

> **Read this instead of re-deriving.** One file for the shared community:
> what the user asked for, every decision with its answer, the architecture
> and why, what is built (with file paths), what the user owes before it is
> live, and the phases after. Started 2026-10-28. Plan approved the same day
> (`C:\Users\sarth\.claude\plans\so-this-is-the-modular-mango.md`); step 1.0
> prototype signed off: https://claude.ai/artifact/7nneRodFwYbU7qBdGxCAnS

---

## Out of scope for phase 1, said plainly

- **Push notifications.** No FCM in the app yet. Replies reach her through the
  "Replies to you" inbox and the count on the home card. Phase 3.
- **Video posts.** Photos only. Phase 3.
- **Course / cohort discussion threads and live-session chat.** The data model
  has room kinds `offering` and `session` ready; nothing mounts them. Phase 2/4.
- **Expert answers and the verified badge.** Phase 2 (from `expert_profiles`).
- **Search, follow, edit-after-posting, birth clubs.** Phase 2.
- **Realtime.** Feeds refresh on open and on pull. Phase 3.
- **Ask Veda.** Nothing changes there: community is never an Ask Veda source.

---

## The brief (user, 2026-10-28)

A place where a mother at any stage (trying → pregnant → parenting) posts an
issue and others respond. Twitter / Flo Secret Chats in shape. Anonymous or
real name. Profiles. Rooms follow her stage. Posts, polls, images, comments,
likes, saves, hashtags, rooms, verified experts. Full backend with
monitoring and removal of explicit content. **The first build must be usable
and safe to make live**, not a slice; later phases enhance it. The three old
community UIs are to be eradicated ("they are all looking bad"), the design
comes fresh from Mobbin, the app's own drawn marks are used, member marks are
distinguishable from room marks, toasts say what happened, motion where it
helps, buttons where people's thumbs expect them.

## Decisions

| # | Question | Recommended | User's answer (2026-10-28) |
|---|---|---|---|
| 1 | One shared UI or three stage UIs | One shared, `lib/screens/community/` | One shared; the three old UIs eradicated (commented out of reach, files kept for revert) |
| 2 | How a post goes live | Live at once + server word check + auto-hide at 3 reports + crisis first in queue | As recommended |
| 3 | Photos in v1 | Yes, held until a moderator approves | As recommended |
| 4 | Entry points | Home card + More + re-enabled door links, tabs unchanged | As recommended (may change later) |
| 5 | Card title | "Parents like you" (fathers use the app) | Recommendations accepted |
| 6 | Default identity when posting | Community name | Accepted |
| 7 | Renaming the community name | Once every 30 days (stops mute-dodging) | Accepted |
| 8 | Replies inbox content | Replies only, no likes | Accepted |
| 9 | Room member counts | Shown from 50 members | Accepted |
| 10 | Post button placement | Top right (Reddit/X/Threads habit; the keyboard covers the bottom) | "If it's at the top right, it's fine" |
| 11 | Where the More entry sits | (asked by the user after commit 9b9dabb9) | **One place in every stage:** its own "Community" section on More, after the journey rows, the same row ("Community" / "Rooms for your stage, to read or to talk", the twoFigures mark) in Pregnancy, Trying and Parenting. Off Trying's You. The home card stays on all three homes. Pinned by `test/community_reachability_test.dart`. |

---

## Architecture, and why (the learning part)

**1. Anonymity is a column problem; RLS works on rows.** A `select` policy
that lets B read A's anonymous post also hands B the `user_id` column. So the
app's roles have **no table rights at all** on the 13 community tables; every
read and write is a `security definer` function that returns a resolved
author (community name or first name) and an `is_mine` flag, never a user id.
*Cost:* no free PostgREST filtering; every query shape is a function.
*Gain:* anonymity that cannot leak through a forgotten column.
Pinned by `test/community_anonymity_test.dart`.

**2. Two faces, never joined.** One community name per member (anonymous
posts) and her first name (named posts). No server answer puts both on one
object; a profile is one face; a block stores the label she saw, so her
blocked list cannot join the two either.

**3. Writes return their outcome.** `community_create_post` etc. return
`{ok, status: live|held, crisis}` or `{ok:false, reason}`. The app turns that
into one toast (`communityOutcomeToast`). *Why not fire-and-forget like the
rest of the app:* she must be told a post is waiting for review, or she will
think it vanished.

**4. The app mints ids; creates are idempotent.** A post written offline sits
in the store's outbox with its own id and is retried on launch / refresh. A
retry of a post that already landed returns its existing outcome, so a
dropped connection can never make two posts. Same trick as `PvReviewStore`.

**5. Counters are kept by triggers.** `like_count`, `comment_count` live on
the row; a card reads one row and never counts. Comment count is
*recomputed* (not +1/−1) because a reply moves between live/held/removed.

**6. Safety words are code, not content.** `community_check_text` (SQL) is
the rule; `lib/services/community_safety.dart` is a mirror so the helplines
appear *while she types*. `test/community_safety_parity_test.dart` keeps them
equal. Crisis posts stay **live** (silencing her is worse) and go first in
the moderator queue; held posts (abuse, links, phone numbers) are visible to
their author only, labelled "waiting for a quick review".

**7. Report → auto-hide → human.** A report hides the post for the reporter
at once; three distinct reporters hide it for everyone until a moderator
decides. Every moderator action requires a reason and writes an audit row
(`community_mod_actions`).

**8. Photos are private until approved.** Private bucket `community-media`;
path `<postId>/<random>.jpg` (a uid in the path would de-anonymise her); the
app asks Storage for short-lived signed URLs, and Storage signs only what its
policy allows (approved, live, no block — or her own, or a moderator).

**9. Local first.** Feeds, rooms, her standing and the outbox are cached in
`shared_preferences`; the community opens instantly on the last thing she
saw, offline or logged out, then refreshes.

**10. Rooms are rows, ranked by stage.** Personalisation changes order only
(her stage's rooms first in the rail and the feed score ×1.6, joined ×1.4);
every room is reachable from every stage.

---

## As built (phase 1) — 2026-10-28

### Backend
| File | What |
|---|---|
| `supabase/migrations/0121_community.sql` | 13 tables (profiles, rooms, members, posts, comments, media, reactions, poll votes, reports, blocks, hidden, moderators, audit), all locked; counter triggers; the safety check; 22 app functions (read, write, moderate); 21 seeded rooms, each with its own drawn mark |
| `supabase/migrations/0122_community_media.sql` | Private bucket + three storage policies through two definer checks |

App functions: `community_me`, `community_join`, `community_mark_seen`,
`community_rooms_list`, `community_set_room`, `community_feed`,
`community_post`, `community_comments_list`, `community_activity`,
`community_face`, `community_create_post`, `community_add_media`,
`community_comment`, `community_react`, `community_vote`, `community_report`,
`community_hide`, `community_block`, `community_blocked_list`,
`community_unblock`, `community_delete`, `community_mod_queue`,
`community_mod_act`.

Limits: 5 posts / hour, 15 replies / 10 min, poll 2–4 options for 1/3/7 days,
4 photos (5 MB, jpeg/png/webp), titles 4–160, bodies ≤ 4000, replies ≤ 2000,
replies one level deep.

### App
| File | What |
|---|---|
| `lib/models/pv_community.dart` | Plain classes; no user id anywhere |
| `lib/services/pv_community_store.dart` | Singleton store: cached feeds, outbox, optimistic likes/votes, photo upload, signed URLs, moderation calls; `debugBackend` seam for tests |
| `lib/services/community_safety.dart` | Crisis + hold mirror, helplines (Tele-MANAS 14416, iCall, 112) |
| `lib/services/remote/supabase_repo.dart` | `+ uploadPrivateFile`, `+ signedUrls`, `+ rpcJson` (throws on failure so "no" and "offline" differ) |
| `lib/screens/community/community_marks.dart` | Rooms draw the app's marks (`TtcMarkLeading`, solid glyph in a disc); members draw a **face mark** (a ring with a line glyph, 8 glyphs × 6 hues); first-name face is an ink circle with her initial |
| `community_chrome.dart` | Routes, post card, poll, photos, like pop, sheets (first time, report, block, menus, room picker), helplines, outcome toasts |
| `community_home_screen.dart` | `community` — pills For you / My rooms / Saved / My posts, room rail, feed, folding "Write a post" |
| `community_room_screen.dart` | `community/room/<id>` — mark, blurb, Join, Top/New, mute/leave/rules |
| `community_post_screen.dart` | `community/post/<id>` — post, poll, photos, Top/Newest/Mine, threads, docked reply bar with face switch |
| `community_compose_screen.dart` | `community/compose` — rises as a full-screen dialog; room → face → title/body; photo + poll toolbar; Post top right; helplines while typing; discard confirm |
| `community_profile_screen.dart` | `community/profile` — one face; her own: switch faces, rename, blocked list |
| `community_activity_screen.dart` | `community/activity` — replies to her, clears the unread count |
| `community_moderation_screen.dart` | `community/moderation` — At risk / Reported / Held / Photos, actions with reasons |
| `community_home_card.dart` | "Parents like you" on the pregnancy, TTC and parenting homes |

**Wiring:** `main.dart` inits `PvCommunityStore` (old `CommunityStore` init
commented, kept for revert); `global_ask_fab.dart` hides the Ask button on
`community*` routes (the corner belongs to "Write a post" / the reply bar);
the home card sits in `home_v3_screen.dart` (before Commerce),
`ttc_home_v3.dart` (after People) and `pp_home_v3.dart` (before Questions);
the old routes and door links now open the new screens (see the wiring list
in the commit). Saved posts are `SavedKind.post` in the app's one Saved list.

**Motion:** cards fade-and-lift in, staggered; the heart pops; poll bars grow
from zero; sheets slide between steps; the compose button folds while
scrolling; the composer rises from the bottom; the reply-as face flips.

**Tests:** `community_schema_contract_test.dart` (every call and param exists
in 0121; grants; rooms; unique marks; private bucket),
`community_anonymity_test.dart`, `community_safety_parity_test.dart`,
`community_store_test.dart` (outbox, held, rollback, logged out, and the
screens: home, card, first-time sheet, composer Post position, helplines
while typing, a thread).

---

## What the user must do before it is live

1. **DONE 2026-10-28.** **Run migrations** `0121_community.sql` then `0122_community_media.sql`
   in the Supabase SQL editor (in order).
2. **DONE 2026-10-28.** **Make yourself a moderator** (Dashboard → SQL, your user id from
   Authentication → Users):
   `insert into public.community_moderators (user_id, role) values ('<your uid>', 'admin');`
3. **Verify the helpline numbers** (Tele-MANAS 14416, iCall 9152987821, 112) —
   listed in `docs/BEFORE-LAUNCH.md`.
4. **Decide who moderates and the reply time** promised in the report
   thank-you ("within 24 hours"), and **name a grievance officer** (India IT
   Rules 2021 for user content) — `docs/BEFORE-LAUNCH.md`.
   **Grievance officer named 2026-10-28: Deepti Sekhri, parentvedateam@gmail.com,**
   shown in the app as Rule 3(2) asks: `CommunityGrievanceLine` under the
   welcome rules, the room's house rules and the report thank-you; a tap opens
   mail, or copies the address with a toast. Still owed: the takedown process (acknowledge in 24 hours,
   resolve in 15 days, intimate images down in 24 hours); and who moderates
   day to day.
5. **Walk it on the phone with two accounts** (build on your word): A posts
   under the community name with a photo → B sees the text, not the photo →
   approve the photo in Moderation → B sees it → B reports → type "I can't go
   on" in the composer → A blocks B → sign out and reopen (cache + invitation).

Cost: Supabase plan as is; photos in Storage at launch volume ≈ $0 (₹0).

---

## RESUME HERE (for a fresh session)

- **Phase 1:** committed `9b9dabb9`; the "one place on More" follow-up (decision 11) is in a second commit.
- **The user's steps** are in "What the user must do" above. Done on 2026-10-28: the migrations, the moderator row, and the grievance officer named (Deepti Sekhri). The officer's contact is in the app. Still open: the takedown process, the helplines, and the phone walk.
- **Phase 2 is planned (2026-10-28).** Plan `C:\Users\sarth\.claude\plans\sparkling-floating-seahorse.md` (approved). Its decisions are in "Phase 2: plan and decisions" below. Mobbin pass: MOBBIN-DISCOVERY §38. Prototype: https://claude.ai/artifact/2NZoJdbk7CJqdBxuT6bhBY, **waiting for the user's sign-off; no Flutter or SQL before it.** After sign-off: write migration 0123 and widen the tests, then build steps 1 to 7 in order.
- **Order suggested:** (1) course and cohort threads with verified experts, (2) birth clubs and follow, (3) search, editing within 15 minutes, and editorial prompt posts.
- **Read first:** this file, `docs/BACKEND-PATTERNS.md` §16zzd, `supabase/migrations/0121_community.sql`, `lib/services/pv_community_store.dart` and `lib/screens/community/community_chrome.dart`. Don't re-read the 8 superseded screens.
- **The rules that hold:**
  - the app never gets a select on a community table;
  - every new read is a security-definer function that returns `is_mine`, never `user_id`;
  - every write returns its outcome;
  - the safety word lists change in SQL and Dart together, and the parity test enforces it.

---

## Phase 2: plan and decisions (2026-10-28)

### Out of scope for phase 2, said plainly

- **Crisis posts routed to experts (the second half of W20).** The user, 2026-10-28: "keep it only till moderators for now". This widens once the app is mature. Crisis posts stay in the moderator crisis queue. The expert queue holds only questions a member asked for. "Ask an expert to look" on a crisis post answers "A moderator is already looking at this, and the helplines are on your post."
- **Editing replies.** Posts only for now.
- **Per-batch threads, push, realtime, video.** Phases 3 and 4.

### What the code decided before anyone asked

- **A thread opens on a booking, not a purchase.**
  - `EntitlementGrant.discussionThread` exists only on the phone and in the `user_state` blob.
  - The server's one record of a seat is `booking_bookings`, written only by the definer `book_slot()`.
  - So a recording-only buyer's thread stays locked until she books a seat. A client's claim is never an access check.
- **The expert badge comes from a person's `expert_accounts` row whose `expert_profiles` row is published.**
  - It does not come from `my_expert_ids()`, which also hands a hospital login every clinician under it.
  - It shows on named posts only, because a badge on an anonymous post would unmask one of very few people.
- **The app passes the due month for the birth club, the same way it already passes the stage.** The server copy of the due date can lag behind the phone and outlives a loss.
- **The phase 1 tests read `0121` by a fixed path.** They are widened to 0121 + 0122 + 0123 before any 0123 function is called.

### Decisions

| # | Question | Recommended | User's answer (2026-10-28) |
|---|---|---|---|
| P2.1 | What opens a course thread | A non-cancelled booking for the offering, the offering's expert, or a moderator | Plan approved |
| P2.2 | Thread per offering or per batch | Per offering (no batch concept on the server) | Plan approved |
| P2.3 | Default face in a course thread | First name; the community name one tap away | Plan approved (open on the prototype) |
| P2.4 | The expert badge | `expert_accounts` + published profile, on named posts and replies only, with a footer: "General guidance from a verified expert, not a diagnosis. For your own care, ask your doctor." | Plan approved (footer wording open on the prototype) |
| P2.5 | Who may ask an expert | The post's author, once per post | Plan approved |
| P2.6 | Which experts see crisis posts (W20) | Every verified expert | **Moderators only for now; widen later** |
| P2.7 | Birth club after a loss | Leave automatically, with one quiet line | **Ask her: a Stay / Leave sheet, once, and nothing changes until she taps** |
| P2.8 | Following | "My rooms" becomes "Following" (joined rooms + followed tags + followed people) | As recommended |
| P2.9 | Following a person | One face, they are not told, no counts anywhere | Plan approved |
| P2.10 | Search | Postgres full-text search on live posts (`english`, `websearch_to_tsquery`) plus rooms and #tags | Plan approved |
| P2.11 | Editing | Posts only, title and body, 15 minutes, online only; the safety check runs again | **Posts only** |
| P2.12 | Editorial prompts | A moderator-only function posting as "ParentVeda team", pinned 0 to 14 days, an audit row, cannot be blocked | Plan approved |
| P2.13 | Over-35 room (STILL-OPEN §79.5) | Seed `preg_over_35` in 0123 | Plan approved |
| P2.14 | Migrations | One `0123_community_phase2.sql` | Plan approved |

---

## Phases after this

**Phase 2 — depth:** course/cohort threads (room `kind='offering'`, access
checked against her booking, mounted under `PvOfferingScreen`, consuming
`EntitlementGrant.discussionThread`); verified experts (badge from
`my_expert_ids()` / `expert_profiles`, an Experts comment filter, endorse,
"ask an expert to look" queue in the doctor flavour, crisis posts routed to
it — completing W20); birth clubs (lazy due-month rooms); follow rooms /
hashtags / members; Postgres full-text search; edit within 15 minutes;
editorial prompt posts by a labelled team account.

**Phase 3 — reach:** FCM push for replies (Firebase setup, device-token
table, send function; FCM itself is free); Realtime on an open thread; short
video posts through the same pending → approved → signed pipeline;
automated image screening (Google Vision SafeSearch ≈ $1.50 ≈ ₹125 per 1,000
images) so risky photos are seen first; a Directus view over the same rows;
moderator analytics.

**Phase 4 — live sessions:** room `kind='session'` attached to
`GroupCallScreen`, so in-call questions continue as a thread afterwards.

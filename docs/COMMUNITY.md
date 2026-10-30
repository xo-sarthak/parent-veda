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

- **Phase 3 is PLANNED (2026-10-30), nothing built.** Read "Phase 3: plan and decisions" at the end of this file.
  Next: **P0, the prototype** (one Artifact, signed off by the user before any Flutter), then C3-1 (live thread, needs
  nothing else). C3-2 (alerts) waits for 6B's B4 sender, which the notifications terminal builds.
- **Phase 2 is BUILT (2026-10-30).** L4a committed `5e1ab087`, 0137 run; **L4b built in the next chat** (birth clubs,
  Following, search, #tags, edit, prompts from Moderation, Over-35): see "App (L4b)" below. **Left: the phone walk**
  (two accounts + an expert login on the doctor flavour), and Ask Veda is untouched (no ingest needed). Phase 3 (push,
  realtime) is next when the user calls it.
- *History:* **Phase 2 L4a is BUILT (2026-10-30), not yet committed or run.** Migration `0137_community_phase2.sql` (0136 was
  taken by Partner Editions P1) holds the WHOLE phase 2 server (D4: one file). The app half built so far: course
  discussions, the team voice and pin, experts, the moved-session notice, and the doctor's Your offerings. See
  "As built (phase 2)" below. **Next: the user runs 0137 + its VERIFY block; then L4b in a fresh chat** (birth clubs,
  Following, search, tags, edit, prompts in Moderation, Over-35 on the rail), per
  `C:\Users\sarth\.claude\plans\l4-plan.md` "L4b chat".
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

### Amended by L4 (2026-10-30) — where these rows changed

The L4 plan (`C:\Users\sarth\.claude\plans\l4-plan.md`, approved 2026-10-30) put phase 2 on the learning model
(docs/LEARNING-ARCHITECTURE.md L.2–L.6). Where it differs from the table above, it wins:

| Row | Now |
|---|---|
| P2.1 | `has_course_access(programme, 'thread', run)`: a receipt for the run, **a non-cancelled booking on a slot of that run, including one paid by a sponsor's or a pack's credit (D3)**, a route A host, or a moderator. For life, no time window (B2) |
| P2.2 | **Per offering RUN** (`programme_runs`, L.3): Batch 2 has its own room, `run_<run id>` |
| P2.3 | First name, with a **one-time heads-up** the first time she writes in a course (B4) |
| P2.4 | The footer is the wording above, word for word (B4) |
| new D1 | A timetable change writes a **pinned team notice from the server**, automatically (a trigger path in `_mirror_session`) |
| new D2 | A moderator's own named post shows **her first name + a "Moderator" chip**; "ParentVeda team" appears only through the explicit team voice |
| new D4 | One migration (`0137`), the app in two chats (L4a, L4b) |

---

## As built (phase 2) — L4a, 2026-10-30

### Backend: `supabase/migrations/0137_community_phase2.sql` (one file, the whole phase 2 server)

Verified locally on Postgres (pgserver) with a stub schema before hand-over: 0121 + 0137 apply cleanly and a scenario
covers run access (receipt, credit seat, host; a stranger refused), the badge and role, team posts, the trigger-written
notice, unread marks, search, edit, the crisis refusal, endorsements, birth clubs, following, the doctor's offerings,
and a leak scan (no user id in any answer). Harness: the session scratchpad's `l4a/run.py`.

| Piece | What it does |
|---|---|
| Tables | `community_rooms` + `programme_id`, `run_id`; members + `via` ('self' / 'auto'); posts + `edited_at`, `pinned_until`, `about_kind`/`about_id`, `moved_from`, a generated `search` tsvector (GIN), identity 'team', `user_id` nullable only for 'team'. New, all locked: `community_endorsements`, `community_follows`, `community_expert_requests`, `community_room_seen` |
| `has_course_access` (thread) | + moderator, + a booked seat on that run (credit or free; a 'purchase' booking defers to the receipt so a refund closes the room), + route A host only. Recordings keep `my_expert_ids()` |
| `community_room_access` | The one room rule, called from `community_can_see`, so every read (feed, post, comments, face, search, photos) holds it |
| `community_offering_room(p_programme, p_run)` | Creates `run_<id>` lazily; the server picks her run (receipt → booked session → hint → current run); answers `access`, `reason` ('book' / 'refunded'), `is_host`, `is_mod`; an entrant joins as 'auto' |
| `community_room_seen` + `unread` | A per-person, per-room high-water mark |
| `community_author` | team → "ParentVeda team"; named → `moderator` flag + `expert` object (route A + published); anon → never a badge |
| `community_create_post` | Room access; `p_about_kind`/`p_about_id` (a session must belong to the room's run); an expert's named post needs no community name (falls back to the profile's full name). Old 7-arg signature dropped first |
| `community_feed` | Scopes `following`, `tag`; pinned first in a room; For you leaves out course rooms and other months' clubs; `p_about_*` filter. Old 7-arg signature dropped first |
| `community_create_prompt` / `community_pin` | Team posts (moderators; rooms, clubs and course rooms); pin 1–14 days (moderators anywhere, a course's hosts in its room); audit rows |
| `community_ask_expert` / `_queue` / `_claim` / `community_endorse` | Author asks once; crisis refused; claims lapse after a day; an endorsement counts as five likes in Top; an expert's named reply marks the request answered |
| `expert_my_offerings()` | Her runs as an accepted route A host: role, seats booked/capacity, next session, unread |
| `_mirror_session` → `_community_timetable_notice` | Reads the slot's old start BEFORE the upsert; after it, if the start moved and anyone holds an upcoming seat, writes a pinned team notice ("This session has moved from … to … (India time)") in the run's room, `moved_from` set, `pinned_until` = the new start, older notices for that session unpinned, audit row with actor null |
| L4b's server half, already here | `community_birth_club`, `community_follow` / `_following_list`, `community_search`, `community_edit_post`, seed room `preg_over_35` |

### App (L4a)

| Where | What |
|---|---|
| `lib/models/pv_community.dart` | Author `moderator` / `expert`; post `about`, `pinned`, `editedAt`, `movedFrom`, `hostRole`, `expertAsked`; room `kind`, `programmeId`, `runId`, `access`, `unread`; `PvOfferingRoom`, `PvExpertRequest`, `PvExpertOffering`; outcome `noAccess` |
| `lib/services/pv_community_store.dart` | `offeringRoom`, `roomSeen`, feed `about`, `createPost(about:)`, `createPrompt`, `pin`, `askExpert`, `expertQueue`, `expertClaim`, `endorse`, `myOfferings`, `movedFrom`, `loadCourseNotices`, the B4 heads-up flag |
| `community_offering_thread.dart` (new) | The course-page section (pinned notice, three newest, "Open the discussion"; or the blurred invitation) and the lesson's Discussion tab |
| `pv_offering_screen.dart` | Section mounted after "More like this", only where the grant sells a discussion |
| `pv_lesson_screen.dart` | Lesson \| Discussion tabs after the actions; listens to BookingStore and the community store |
| `community_room_screen.dart` | Course variant: no Join, no Leave, the batch line, about pills; room seen on open; "Post as ParentVeda team" for moderators |
| `community_compose_screen.dart` | About chip; course rooms default to her first name with the one-time heads-up; team mode with pin days |
| `community_chrome.dart` / `community_marks.dart` / `community_post_screen.dart` | The seal and "Dr Name · category"; role and Moderator chips; the team's ink square; Pinned and About on cards; Pin in the post menu; team posts cannot be blocked or opened as a face; the expert footer, "Found helpful by", Endorse, the Experts pill and "Ask an expert to look" |
| `pv_my_learning_screen.dart` | A booked class that moved reads "Moved from …" from the pinned notice |
| Doctor flavour | `main_doctor.dart` inits the store; `doctor_offerings_screen.dart` (Your offerings → the room as host) and `doctor_community_queue_screen.dart` (new); home section 8 is "Your offerings" + "Parents asking an expert to look", the go-live ClassCard unchanged under it |

### App (L4b), 2026-10-30 (the server half was already in 0137)

| Where | What |
|---|---|
| `pv_community_store.dart` | `syncBirthClub` (called from `refreshMe`; the month is derived on the phone: due date in Pregnancy, in Parenting the due month if the youngest real child was born within two months of it, else that child's birth month; Trying sends nothing; a no-op when she is already in the right club), `clubAfterLoss` + `answerClubAfterLoss`, `following` / `loadFollowing` / `follow`, `search` + recent searches (phone only), `canEdit` / `editPost` (online only; an outbox post is edited in place), tag feeds through `loadFeed(scope: 'tag')`, her club first in `rooms` |
| `community_home_screen.dart` | Search icon; "My rooms" → **Following** (rooms + #tags + people) with Manage; the after-a-loss Stay / Leave sheet, once, nothing changes until she taps (closing it asks again next visit); the rail card of her club reads "Due May 2027" ("May 2027 babies" in Parenting) |
| `community_search_screen.dart` (new, `community/search`) | Debounced search; #tags, rooms, then posts; recent searches with Clear; offline and no-result states |
| `community_tag_screen.dart` (new, `community/tag/<tag>`) | A tag's feed, newest first, with Follow / Following |
| `community_chrome.dart` | Routes and openers; `CommunityBodyText` (tappable #tags in a post's words); Edit in the post menu inside 15 minutes; `communityClubLine` |
| `community_compose_screen.dart` | Edit mode (title and words only, "Save", the safety check runs again on the server); a team prompt opened from Moderation picks its room |
| `community_profile_screen.dart` | Follow / Following on someone else's face (they are not told); "Following" in her own menu beside Blocked (`showCommunityFollowing`) |
| `community_room_screen.dart` | A birth club shows its "Due …" line |
| `community_moderation_screen.dart` | "Write a prompt" (posts as ParentVeda team, pin 0–14 days) |

The Over-35 room needed no app code: it is a seeded room, so `community_rooms_list` brings it onto the rail.

Tests: `community_phase2_test` gains birth clubs (month sent, no-op when already in, Trying sends nothing, Stay survives
the next sync, Leave does not come back, the home sheet), Following (the pill, tag follow, unfollow by row id), search,
and edit (refused on the phone after 15 minutes, saved inside, a late server answer, Edit in the menu);
`community_reachability_test` checks the new routes are reached only from inside Community and every new store call
has a screen caller.

Tests: `community_schema_contract_test` and `community_anonymity_test` now read every community migration through
`test/support/community_sql.dart` (last definition wins; a parenthesis-counting parser); new
`community_phase2_contract_test` and `community_phase2_test` (L4a cases; L4b adds its own).

**Push is not built (phase 3).** A moved session reaches people through the pinned notice on the course page, in the
discussion and on the booking card. What phase 3 still owes for LA-22: an FCM message to everyone with an upcoming
seat when `_community_timetable_notice` fires.

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

---

## Phase 3: plan and decisions (2026-10-30)

Planned in one chat, plan only. The user accepted every recommendation ("you can go with all of your
recommendations"). Mobbin pass: MOBBIN-DISCOVERY §40. **Nothing is built.**

### Out of scope for phase 3, said plainly

- **A Directus view over community rows (old item 5): moved out.** The admin panel is not ready, and Directus reads
  tables as a privileged role, so it would see `user_id` (anonymity) and act outside the definer functions that write
  audit rows. A later pass needs a view with no user id, read only.
- **Crisis routing to experts (W20, second half):** still held. Crisis alerts go to moderators only.
- **Push in the doctor app**, the expert queue included (6B decision 6).
- **6B's campaigns, the audience upload, B5, iPhone (B7):** the notifications track's.
- **Pushes for likes, follows, or new posts in a room; email digests.**
- **Typing indicators, presence, video replies, clips over 60 seconds, live streaming** (phase 4).
- **Screening that approves or rejects on its own.**
- WhatsApp, Hindi.

### What the code decided before anyone asked

- **6B's B2 and B3 are built** (0140, 0143). `push_consent` is per stage and `push_sends` is campaign-only; both stay
  as they are. Community adds its OWN consent table and queue beside them.
- **The sender is shared.** 6B's B4 reads only `pv_push_due()` and writes only `pv_push_mark()`, every minute
  (written into NOTIFICATIONS-6B-PLAN.md, "For B4, agreed with Community phase 3"). Community adds a branch to those
  two functions and never edits the sender.
- **Supabase's ready-made "send me database changes" Realtime cannot be used.** The app has no rights on community
  tables, and that path sends the whole row, `user_id` included (§16zzd). Live threads use a private **broadcast**
  carrying only `{post_id}`; the phone then re-reads through `community_comments_list`.
- **"Replied to you" is not stored anywhere.** `community_activity` (0121:609) derives it at read time. The push queue
  must use the same rule, so both read one helper, and a test checks they agree.
- **Mux is already set up** (L3: `recording-playback`, `mux-webhook`). Video posts reuse it, so the Mux key stays in
  one function.
- **The device's `link_version` (0140)** already answers "can this build open a community link?". The new link kinds
  raise `PushService.linkVersion` to 2.

### Decisions

| # | Question | Recommended | User (2026-10-30) |
|---|---|---|---|
| C1 | Wait for 6B, or build alongside? | Alongside: own consent + queue, the shared B4 sender | Recommended |
| C2 | Lock-screen wording | No content: "New reply in ParentVeda Community · Someone replied to your post." No room, title, text or name (phones are shared; room names say "loss", "IVF") | Recommended |
| C3 | Moved-session alert | On once she books, a switch to turn it off | Recommended |
| C4 | Reply limits | 3 a day; replies to one post combine (`collapse_key` = post); quiet 21:00 to 08:00 IST, then one at 08:00; beyond the 3, Activity only | Recommended |
| C5 | The care cap | Community alerts sit outside 6a's cap: she started these conversations. Their own limits instead (C4) | Recommended |
| C6 | Loss | Replies continue (she posted and wants to hear back; C2 makes them neutral). No room-wide pushes ever. A pregnancy-stage class after a loss (0112 condition) gets no moved-session push; the pinned notice still shows | Recommended |
| C7 | Moderators | A crisis post alerts moderators (topic `moderation`), within W20's "moderators only" | Recommended |
| C8 | Consent ask | In context, after her first post goes live (LinkedIn's pattern), never at launch | Recommended |
| C9 | Realtime shape | Private broadcast, topic `post:<id>`, authorised through `community_can_see`, payload `{post_id}` only | Recommended |
| C10 | Screening | Google Vision SafeSearch **sorts the queue, never decides**: breastfeeding and birth photos read as risky | Recommended |
| C11 | Video | 60 s, one per post, basic quality, pending until a moderator watches it; straight from the phone to Mux (an upload link only for her own post), never through our bucket | Recommended |
| C12 | Video on anonymous posts | Allowed, with a one-time "Faces and voices can show who you are" | Recommended |
| C13 | Where push triggers hang | Triggers on `community_comments` / `community_posts`, never a rewrite of `community_comment` or `_community_timetable_notice` (§16zzi: a rewrite can drop 0137's lines) | Recommended |
| C14 | Migration numbers | None fixed here. Each pass runs `ls supabase/migrations` and takes the next free number | Recommended |

### Passes (each one migration plus the app; each needs only the ones before)

| Pass | Server | App | Done when | Prototype |
|---|---|---|---|---|
| **P0** | — | One Artifact: opt-in sheet, notification settings, the new-replies pill, video compose / processing / player, the analytics tab | User signs it off | — |
| **C3-1 Live thread** | Policy on `realtime.messages`; a trigger broadcasting `{post_id}` when a reply arrives or changes status | Subscribe on open, leave on close; "N new replies" pill (the list never moves under her finger); pull still works if Realtime fails | A second phone's reply shows the pill; no user id in the broadcast (contract test) | Yes |
| **C3-2 Alerts** (after 6B's B4) | Community consent table (`replies`, `bookings`, `moderation`); queue; triggers for replies (shared recipient helper, C4 limits, per-post mute), moved sessions (team posts with `moved_from`, to seat holders, C6) and crisis to moderators; a branch in `pv_push_due` / `pv_push_mark` | Opt-in sheet, settings, "Turn off replies for this post", link kinds `community_post` and `booking` (linkVersion 2), Android channels "Replies" and "Your bookings", rows in `notifications_b0_tap_test` | One reply rings once, three combine, a muted post is silent, a moved session rings everyone booked | Yes |
| **C3-3 Image screening** | Likelihood columns on media; `add_media` calls `community-screen` (Vision) through `pg_net` | A risk chip in Moderation's photo queue, riskiest first | A test image is scored and sorted; nothing approved by itself | No |
| **C3-4 Video posts** | Media `kind='video'`, Mux ids, `processing`; `community-video-upload` (new); community branches in `mux-webhook` and `recording-playback`; three thumbnails screened by C3-3 | Picker (60 s), upload progress, processing state, player, video review in Moderation | She posts a clip, B sees nothing, a moderator approves, B plays it through a signed link | Yes |
| **C3-5 Moderator analytics** | `community_mod_stats(p_days)`, moderators only, counts only, from `community_mod_actions` | "This week" tab in Moderation: open per queue, oldest crisis waiting, median time to first action, share inside the 24-hour takedown | Numbers match a hand count | Yes |

Tests scoped to `community_*`, `push_*`, `notifications_b0_tap_test`.

### Costs (Mux and Supabase checked 2026-10-30; Vision from phase 1's figure; ₹84 = $1)

| Item | USD | INR | At launch |
|---|---|---|---|
| FCM | $0 | ₹0 | $0 |
| Sender every minute | inside the Supabase plan | ₹0 | $0 |
| Realtime | Pro: 500 connected at once + 5M messages a month included; then $10 per 1,000 connections, $2.50 per 1M messages | ₹840 / ₹210 | $0 |
| Mux upload (basic) | free | ₹0 | $0 |
| Mux storage | $0.0024 per minute per month | ₹0.20 | 500 one-minute clips a month, kept a year: ≈ $14 a month after 12 months (₹1,210) |
| Mux viewing | 100,000 minutes a month free, then $0.0008 a minute | ₹0.07 | $0 |
| Vision SafeSearch | 1,000 a month free, then $1.50 per 1,000 | ₹126 | ≈ $5 a month (₹440) |

**Owed by the user before C3-4:** Mux's free plan stores only 10 videos; video needs pay-as-you-go ($20 of usage
included a month, ≈ ₹1,680). Check which plan the L3 account is on. Before C3-3: a Google Cloud key with the Vision
API on, and a privacy-policy line that photos are screened by Google (DPDP).

### P0 signed off (2026-10-30)

Prototype: https://claude.ai/artifact/WhnEf3SekmCeUjSsREEAND (10 screens). The user: "I like the prototype."

| # | Question | Recommended | User (2026-10-30) |
|---|---|---|---|
| P0-1 | She taps "Not now" on the reply-alerts ask: ask again later? | No. The switch stays in Settings, Notifications, Community | Recommended |
| P0-2 | Moderator alert wording | "A post may need a moderator now" / "Open Moderation to see it." | Keep it; it only has to be clear to a moderator |
| P0-3 | Moderator alert in quiet hours | Rings at any hour (someone may be at risk); the moderator can turn it off | Recommended, and **on by default** |
| P0-4 | Tapping the new-replies pill | Scroll to the first new reply, ring the new ones for two seconds | Recommended |
| P0-5 | Photos and video on one post | Photos or one video, never both | Recommended. Photo limits: keep what phase 1 built (below) |
| P0-6 | Approving a video | Only after the moderator has played it to the end | Recommended |

**P0-5, the photo limits, checked in the code rather than added.** Phase 1 already caps photos twice, once per
side. The phone allows **4 per post** and shrinks each one before upload (`pickMultiImage(maxWidth: 1600,
imageQuality: 85, limit: left)`, `community_compose_screen.dart`), which usually lands at 0.3 to 0.8 MB. The server
refuses any file over **5 MB**, or anything that is not JPEG, PNG or WebP (`community-media` bucket, 0122). The two
limits do different jobs. The phone's limit is for her: a small file uploads quickly on a weak connection. The
server's limit is for us: a modified app cannot skip it. Nothing new is needed.

**How moderators work (the user asked, 2026-10-30).** A moderator uses the same parent app with their own account.
What makes them a moderator is one row in `community_moderators` holding their account id, added from the Supabase
dashboard (0121). That is a setting on the server, not a separate login or a separate app. The app learns it from
`community_me().is_mod`, and only then shows the shield on Community home that opens Moderation. Every moderator
action is checked again on the server by `community_is_mod()` and written to `community_mod_actions` with their
name. A changed app therefore gains nothing: hiding the shield is presentation, and the check is the server's. From
C3-2, a moderator's phone also gets the "Moderation" alerts (P0-3), on the phone where they are signed in. The
doctor app does not get them (6B decision 6).

## As built (phase 3) — C3-1, the live thread (2026-10-30)

### Server: `supabase/migrations/0145_community_live_thread.sql`

- **`community_comment_broadcast()` + trigger `community_comments_broadcast`** (after insert, or an update of
  `status` / `deleted_at`, on `community_comments`). It calls `realtime.send({post_id}, 'reply', 'post:<id>',
  private)`. A held reply's insert sends nothing. Its approval does send.
- **`community_can_listen(topic)`**, granted to `authenticated` only. It is `community_can_see` for the post the topic
  names. The policy `community_post_listen` on `realtime.messages` is **SELECT only**. There is no insert policy, so a
  phone can never send on a post topic.
- **Verify:** `supabase/seed/verify_community_live.sql` (10 checks, ends in a red ERROR that rolls everything back).

**The patterns are in BACKEND-PATTERNS §16zzz-e (renumbered: B4 took 16zzz-d).** Short form, kept here:
1. **Signal, then re-read.** The broadcast says "post X changed" and carries no data. The phone re-reads through the
   same definer function as always, so blocks, holds and faces apply without being re-implemented in a second
   channel. The cost is one extra RPC per change. In return, Realtime does not need its own privacy rules. The
   ready-made Postgres Changes stream would have sent the row, `user_id` included.
2. **A side channel never blocks the main write.** `realtime.send` sits in its own `BEGIN ... EXCEPTION` block. In
   PL/pgSQL that block is a savepoint, so if Realtime fails, only the signal is rolled back and her reply still
   saves. A missed signal costs a pill. A failed reply would cost her words.
3. **Listen-only topics.** On a private channel, a SELECT policy decides who may join and an INSERT policy decides
   who may send. Leaving out INSERT means only the database speaks on these topics.
4. **A policy runs as the user.** That is why it calls a granted wrapper (`community_can_listen`), not the revoked
   helper underneath it.

### App

- `SupabaseRepo.listenBroadcast(topic, event, onSignal)` + `PvLiveListen` (the only Realtime code in the app;
  `RealtimeChannelConfig(private: true)`). Returns null when signed out or when Supabase is not initialised.
- `PvCommunityStore`: `watchPost` / `unwatchPost`. A signal waits 700 ms so that a burst of replies causes one
  re-read. The re-read lands in a **waiting buffer**, never in the list on screen. `newReplies(id)` counts what is
  new, using `communityNewReplyIds`, which leaves out her own replies. `showNewReplies(id)` swaps the buffer in.
  `loadComments` (pull to refresh) clears the buffer.
- `CommunityPostScreen`: watches the post while it is open, shows the ink "N new replies" pill at the top, and on a
  tap scrolls to the first new reply and rings the new ones in the tick blue for two seconds. If she is on Mine or
  Experts, it switches to Newest, because those filters could hide the new replies. A reply threaded under another
  opens its thread.

### Tests

`test/community_live_thread_test.dart` (9): what the payload carries, listen-only access, the savepoint, no rewrite of
0137 (C13), the new-reply rule, signed out does nothing, the pill with a list that does not move, her own reply
raising nothing, and the screen's wiring. All community tests: 112 pass.

### Owed by the user

1. Run `0145_community_live_thread.sql` (RUN 2026-10-30). Wake Realtime once: Dashboard > Realtime > Inspector, join any channel. Its daily partitions only exist after a first connection; the first verify found none. Then run `supabase/seed/verify_community_live.sql` and expect "10 passed, 0 failed".
2. Phone walk with two accounts: A opens a post, B replies, and A sees "1 new reply" without the list moving.
3. Nothing to switch on in the dashboard. The project is on the FREE plan (seen 2026-10-30): Realtime there allows 200 concurrent connections and 2M messages a month, ample before launch; Pro raises it to 500 concurrent
   connections and 5M messages a month).

**NEXT:** C3-2 alerts, once 6B's B4 sender is committed (it is in the tree as 0144, not yet committed).

# ParentVeda Personalization Engine

The intelligence layer that makes ParentVeda feel personal without making it feel
unfamiliar. This document is the architecture; it is written to be read before
the code, and to be the thing we check against afterwards.

---

## 1. The one principle

> Personalization influences **content**, **recommendations** and
> **priority-ordering** only. Never navigation, information architecture, screen
> hierarchy, feature locations or section names.

Every user learns **one** ParentVeda. The engine adapts *what* she sees and
*what is surfaced first*, never *where she finds it*. Features read the profile;
they never restructure themselves around it.

The comparison worth holding on to is Spotify. Six hundred million people share
Home / Search / Library. Nobody's app is structurally different from anybody
else's. Everybody's Home is full of different things.

### What is personalized

Content shown, recommendations, order of cards, "Today's Focus", suggested next
actions, articles, videos, products, recipes, activities, AI responses,
notifications.

### What is identical for everyone

Bottom navigation, menu structure, screen hierarchy, feature locations, names of
sections, overall UX patterns.

### Why the guardrail exists

The source prompt contains lines that can be read either way — "every screen
should feel unique to that family", "the Home screen should adapt immediately".
Read as content, they are right. Read as structure, they produce a different app
per user: support becomes impossible, documentation is wrong for half the users,
and a mother who learned ParentVeda in her first pregnancy is lost in her
second. A screen feels unique through its **content**, never its **structure**.

---

## 2. The three layers

**Layer 1 — Content.** Same screen, same cards, different material inside them.
Different articles, videos, recipes, tips, insights.

**Layer 2 — Recommendation.** Nothing moves, nothing disappears; the ranking
gets smarter. "Because your baby has eczema, here are three articles on skin
care." Products suited to sensitive skin rather than every lotion.

**Layer 3 — Contextual prioritization.** Reordering only. A mother with
gestational diabetes sees the diet and sugar-tracking cards near the top of the
health surfaces. Nothing is removed. Nothing is renamed. Only the order changes.

There is no Layer 4. Navigation is not a layer.

---

## 3. The emptiness rule

**A feature is never hidden. Content is what gets personalized.**

Personalization may reorder and it may boost. It may never subtract. And
emptiness may never subtract either — because hiding an empty section does not
merely remove content, it removes *the knowledge that the feature exists*. A
mother who has never logged a medication must still learn that ParentVeda has a
medication tracker. The empty state **is** the feature's advertisement.

The comparisons are exact. Substack asks your interests to rank your feed; it
does not remove the publish button from people who have not written yet. Spotify
does not hide "create playlist" from someone with no playlists. Amazon does not
hide wishlists from someone without one. No product asks whether you would like
a feature to exist — it was built for a purpose, and personalization is about
*content*: articles, books, products, recipes, ordering. Not about which
features a user is permitted to see.

Every section therefore always renders. The only thing that varies is what its
empty state says:

| Situation | What the empty state says |
|---|---|
| User has not used the feature yet | Name the feature and invite the action — *"No medications added yet — track yours"* |
| User has used it and is currently clear | Reflect the good state — *"No medications left today, all clear"* |
| Content pool has nothing for this week/leap | Graceful line, and log it — this is a content gap to author, not a UI state to normalise |

**Reference implementation already in the codebase:** `_medicationSection`
(`home_screen_b.dart:1505`). It always returns its `HomeCard`; when
`meds.isEmpty` it shows explanatory copy plus a `HomePrimaryButton` CTA into the
tracker. Anything shaped like this is correct. Copy it.

### Degradation tiers for any personalized surface

1. Personalized content exists → show it, with the "why" line
   (*"Because you're managing gestational diabetes…"*)
2. No personalized match, pool has items → show the normal generic content,
   silently. No "why" line, no apology, no empty slot. She sees exactly what an
   unpersonalized user sees.
3. Pool itself is empty → the section still renders, with the empty state above.

Personalization must never create a *new* reason for something to vanish, and
nothing may vanish for being empty either.

---

## 4. Signals

### Derive, never ask

A signal is either derived or declared, never both. Asking for something we
already hold is how a personalization engine turns back into the onboarding
questionnaire we were told not to build.

| Already held | Source |
|---|---|
| Due date, week, day, trimester, overdue | `PregnancyController` |
| Language | `PregnancyController.language` |
| Name, role, partner | `profiles` table via `PregnancyController` |
| Child name, sex, DOB, age, growth | `ChildProfileStore` |
| Twins, delivery type, season, hospital-provides | `ReadyBirthContextStore` |
| Logged symptoms | `SymptomStore` |
| Active medications | `MedicineStore` |
| Religion / tradition for read-to-baby | `ReadToBabyStore` |
| Spiritual interested / not-interested | `SpiritualPrefsStore` |
| Which home modules she actually opens | `HomeContentController._engaged` |
| Scans completed and upcoming | `ScansStore` |

### Declared, per journey

One store, stage-scoped vocabularies. Different questions, same engine.

| Signal | Trying to conceive | Pregnancy | Parenting |
|---|---|---|---|
| Conditions | later | gestational diabetes, low-lying placenta, anemia, thyroid, hypertension, high-risk | eczema, CMPA, food allergy, reflux, colic, tongue tie, asthma, low birth weight, developmental delay, hearing, vision *(built)* |
| Priorities | later | nutrition, sleep, anxiety, birth prep, fitness, baby development, symptoms | sleep, feeding, development, nutrition, behaviour, learning, milestones, brain, play, health *(built)* |
| Diet | shared | veg / non-veg / egg / Jain / vegan | shared |
| Parity | shared | first baby / subsequent | shared |
| Learning style | shared | shared | *(built — journey-agnostic, reuse)* |
| Notify topics | shared | shared | *(built — journey-agnostic, reuse)* |

Journey stage is **declared, defaulting to pregnancy** — not derived. Deriving
it was tried and rejected: the child profile is seeded with a demo child, so
"has a child" answers *parenting* for everyone, and a due date outlives the
birth. In practice consumers rarely need it, since a pregnancy screen already
knows it is one and asks for that vocabulary directly. Note that
`auth_flow_screen.dart:81` already renders a `pregnant | new | trying` selector
that is never persisted or read; reviving it is the natural home for
trying-to-conceive, which has no derivable marker at all.

**Twins is derived, never asked** — `ReadyBirthContextStore` already holds it,
so `PregCondition` deliberately omits it and `expectingTwins` reads across.
This is the derive-don't-ask rule catching a real duplication that had already
slipped in once.

---

## 5. The engine API

Five methods. Features consume these; they never reach past them into raw
fields to make layout decisions.

| Method | Layer | Contract |
|---|---|---|
| `orderByPriority(items, keyOf)` | 3 | Stable sort. Returns **every** item it was given, reordered. Cannot drop one. |
| `recoBoosts()` | 2 | `{signal: weight}` for a scorer. Weights, not filters. Health signals rank strongest. |
| `matchesSignal(text)` | 2 | Cheap "does this topic line match a family signal" for content filters. |
| `personalizedFocus()` | 1 | A focus *line*, not a layout. Always returns something; ends in a generic fallback. |
| `aiContext()` | AI | One-line natural-language family summary, so Ask Veda never re-asks what we know. |

Non-subtraction is a property of the API itself, not a convention: a sort that
returns all items and a weight map that cannot exclude are structurally unable
to hide a feature.

---

## 6. Where it plugs in

Both apps read one store. This is the same shape as Ask Veda's "one brain, two
doors": a mother who says she is vegetarian during pregnancy is not asked again
after the baby arrives.

### Pregnancy

| Layer | Surface | Hook |
|---|---|---|
| 3 | Tools hub | `tools_hub_screen.dart:76` — 22 tiles, flat hardcoded list, zero personalization today |
| AI | Ask Veda | `veda_context.dart:43` `gather()` — the designated injection point; its own header says only `gather()` changes when profiles land |
| 2 | Products carousel | `home_screen_b.dart:726` — products carry a `score` field the carousel currently ignores |
| 2 | Daily Reads | `read_next_data.dart:715` — week filter plus `day % n` rotation |
| 2 | Sponsored ranking | `rank_floor.dart:29` — scoring function already injected by the host |
| 1 | Today's Video | `watch_learn_screen.dart:25` |
| 1 | Focus line | `home_screen_b.dart:376` hero / `home_modules.dart:470` GrowModule |

### Parenting (built)

| Layer | Surface | Hook |
|---|---|---|
| 2 | Recommendations | `pp_reco_data.dart:1065` — live |
| — | Brand audience targeting | `brand_context.dart:34` — live, already shared by both apps |

### Precedent worth copying

`SpiritualPrefsStore.rank()` is currently the only preference-driven reordering
in the app: interested floats up, not-interested sinks, nothing disappears.
That is exactly the shape every Layer 3 consumer should take.

---

## 7. Test discipline

Two halves. Both are required.

**Invariants — personalization did not restructure the app**

- The Tools hub renders the same *set* of tiles for every profile; only order differs
- Bottom navigation is identical across profiles
- No section is renamed by any profile
- No feature becomes unreachable
- No personalized list is shorter than its unpersonalized equivalent
- **A section with no data still renders.** A brand-new user with every store
  empty sees every section, each with its call-to-action empty state — this is
  how she discovers the features exist

**Liveness — personalization actually does something**

- Two materially different profiles produce a different Tools order
- Two materially different profiles produce different recommendations
- `aiContext()` reflects declared signals

The second half is not optional, and the reason is recorded in
`docs/` history: the Brand Studio Premiere never rendered for months because
every test asserted only what should *not* appear. Absence-only tests hide dead
features. A personalization engine that changes nothing passes an invariant
suite perfectly.

---

## 8. Phases

| # | Phase | Changes | User-visible |
|---|---|---|---|
| 0 | Neutral store | Move out of `screens/post_pregnancy/` into `lib/services/`; imports only | No |
| 1 | Pregnancy vocabulary | Stage, pregnancy conditions/priorities, diet, parity; derive-don't-ask wiring | No |
| 2 | Entry points | A row in the pregnancy profile screen; progressive asks in context. No new navigation | Yes |
| 3 | Tools ordering | `orderByPriority` over the existing 22 tiles | Yes |
| 4 | Ask Veda context | Profile fields into `gather()` | Yes |
| 5 | Tests | Invariants and liveness | No |

Deferred to a later pass, deliberately: products carousel, daily reads, Today's
Video, home focus line. All Layer 1/2 wins that touch the pregnancy home's
render path, which is better left settled immediately after a UI harmonisation.

---

## 9. Open items

- **Existing hide-when-empty sections.** Being audited across both apps; any
  section that disappears when its store is empty gets converted to a
  call-to-action empty state, per section 3. (Note: the pregnancy medication
  section was initially assumed to be a violation and is not — it is the
  reference implementation. Verify before converting.)
- **Trying to conceive.** Vocabulary not yet designed. The architecture reserves
  room; `auth_flow_screen.dart:81` holds the dead selector to revive.
- ~~**Progressive profiling triggers.**~~ DONE. `ProfileAskStrip`
  (`lib/widgets/profile_ask_strip.dart`) is the one component; it is the first
  and only caller of `shouldAsk()`, which had sat unused since it was written.
  Wired at: Symptom Companion, Weight Tracker (dashboard, not the one-time setup
  flow — a once-ever strip is wasted on a screen visited once), Tests/Scans &
  Reports, and the Tools hub (where the answer re-sorts the grid directly
  below). Rules: inline never modal, once ever whether answered or dismissed,
  states its payoff, one tap, visibly skippable.
- **Diet strip placement.** `dietStrip()` is built and tested but not yet wired
  to a screen — the pregnancy nutrition surfaces live inside the weekly flow and
  want a careful insertion point rather than a quick one.
- ~~**Analytics.**~~ BUILT, and shipped OFF.
  `lib/services/profile_analytics.dart` follows the same sink pattern as
  `BrandAnalytics` and `PvVideoAnalytics`: the app emits facts, a sink decides
  what to do with them, and swapping in Supabase later is one line that touches
  no call site. Nothing leaves the device today.

  Every event carries a **surface** (`symptom_companion`, `weight_tracker`,
  `tests_scans_reports`, `tools_hub`). That field is the point: the same
  question can succeed in one place and fail in another, and without it the
  data cannot tell a bad question from a bad placement. The four current
  placements were judgement calls; this is how they get checked.

  **Recording is always on**, on-device only. Profile → "Personalization
  analytics" is the window onto it: live event stream, session/install ids,
  current completeness. The buffer resets each launch by design — it is for
  observability, not storage.

  Each record carries a **UTC timestamp**, a **sessionId** (new per launch) and
  an **installId** (persisted). Both ids are random; we never read a hardware
  identifier, even though `device_info_plus` is already a dependency. Without
  the ids a completion rate can only be counted per *view*, which cannot
  distinguish 200 mothers seeing a strip once from 40 seeing it five times.

  `fieldUpdated` fires from **`FamilyProfileStore._save()`**, not from any
  screen — the store is the funnel every write already passes through, so a new
  consumer cannot forget to report a change. `stripAbandoned` fires from the
  strip's `dispose()` when it was shown and neither answered nor dismissed.

  **Known imprecision, stated rather than hidden:** `stripShown` fires when the
  strip is built into the tree, not when her eyes reach it. Every current
  placement is near the top of its screen so the two mostly coincide, but rates
  derived from it run slightly optimistic. Real scroll visibility would need a
  VisibilityDetector; revisit only if the numbers look strange.

  **Remaining for real tester data:** a durable sink. `setSink()` is built and
  tested (including that a throwing sink cannot break a session), so it is one
  line in `main.dart` plus a ~30-line class. It needs a Supabase table, which is
  the other terminal's territory — see §10.

  The constraint stands and is written into the file header: analytics improve
  the questions, never pressure the mother. A low completion rate means fix the
  wording or the placement — never re-ask, badge, or gate.

---

## 10. Handover: the analytics sink (not built)

Everything up to the device boundary is done. Crossing it needs a table and a
sink class, and migrations belong to whoever is on the backend — `0020` and
`0021` are in flight as this is written, so a `0022` here would collide.

Proposed table. Deliberately dumb: raw events, no aggregation. Rates are
DERIVED downstream, never computed on the client — the same rule the Brand
Studio analytics follow.

```sql
create table profile_events (
  id           bigserial primary key,
  install_id   text        not null,   -- random, anonymous, persists per install
  session_id   text        not null,   -- random, new each launch
  event        text        not null,   -- stripShown | stripAnswered | ...
  field        text,                   -- pregHealth | diet | parity | ...
  value        text,                   -- the option chosen; enum labels only
  surface      text,                   -- symptom_companion | tools_hub | ...
  percent      int,                    -- completeness snapshots only
  at           timestamptz not null,
  created_at   timestamptz not null default now()
);

create index on profile_events (install_id, at);
create index on profile_events (event, surface);
```

`ProfileAnalyticsRecord.toMap()` already emits exactly these column names, so
the sink is a straight insert with no mapping layer.

RLS: insert-only for the app role. Nothing in this table should ever be read
back to the client — it exists to judge our questions, not to feed a screen.

There is no `user_id` on purpose. `install_id` is anonymous and pre-auth; when
real accounts land the two can be joined server-side without the client ever
sending an identity it did not need to.

### The queries these answer

```sql
-- Completion rate per surface, counted per MOTHER rather than per view.
select surface,
       count(distinct install_id) filter (where event = 'stripAnswered')::float
     / nullif(count(distinct install_id) filter (where event = 'stripShown'), 0)
         as completion_rate
from profile_events
where field = 'pregHealth'
group by surface;
-- Same question, two placements. A big gap means the PLACEMENT is wrong.

-- What mothers actually want help with (content commissioning signal).
select value, count(distinct install_id) as mothers
from profile_events
where event = 'stripAnswered' and field = 'pregPriorities'
group by value order by mothers desc;

-- Are profiles filling up over time?
select date_trunc('week', at) as week, avg(percent)
from profile_events
where event = 'completenessSnapshot'
group by 1 order by 1;
```

# The family model — who owns what, across every stage

**Written 2026-09-16.** The answer to one question the user put plainly:
*"Baby sits at the top; mother and father connect to it — but at trying to
conceive there is no baby, so how do you link anything?"* Read this before
adding any table that has a `user_id`, a `child_id`, or a `stage` on it.

---

## 1. The rule

**The person is the root of identity. The child is the root of what is logged
about the child. Stage is a tag, never an owner.**

| Thing | Owner | Why |
|---|---|---|
| Account, sign-in, phone, WhatsApp consent | the person (`profiles`) | she exists before any baby does |
| Cycle, symptoms, journal, scans, due date | the person | it is her body; the partner may read, never write (0012) |
| Feeds, sleep, vaccines, growth, milestones, documents | **the child** (`children`, via `my_child_ids()`) | both parents log the same baby; a per-parent copy would fork every record (0021) |
| The timeline | the person, readable by the couple (`journey_timeline`) | one continuous story from trying to parenting |
| **Saved items — bookmarks** | **the person** | a bookmark is an act she did; it is hers in every stage after |
| Partner link | between two persons (`profiles.partner_id`) | he links to *her*, and reaches her children through her |

This is not new. It is what `0001`, `0009`, `0021` and `0041` already do. What
was missing is that **nobody had said it**, so each new feature re-decided it —
seven saved-sets in seven stores, two Saved hubs, and a reader whose bookmark
never left the phone.

## 2. What the shipped apps do (Mobbin, 2026-09-16)

- **Flo** — one account; *My goal* switches the mode (Track cycle → Get
  pregnant → Track pregnancy). Switching to pregnancy asks the week and
  "activates pregnancy mode"; nothing about the account changes. The partner
  links to *her* with a code.
- **Clue** — the same; *Switch mode* on the account, with the previous mode's
  data intact.
- **Apple Health** — *Add a Current Pregnancy* under the person, with four
  ways to date it; *Log a Past Pregnancy* exists, so a pregnancy is a
  **record with a start and an end**, not a state the account is in.
- **Fitbit Family** — the adult is *Family manager*; children are added
  under her and can be switched between.
- Nobody makes the baby the account. Nobody loses a saved thing when the mode
  changes.

## 3. The journey — how a person moves through the stages

```
 trying ──(positive test)──► pregnancy ──(birth)──► parenting ──(age 6)──► skilling
    ▲                                                   │
    └───────────────── second baby ─────────────────────┘
```

- **Forward is the only direction, and the second baby is the only way back.**
  A parent who wants to "look at" pregnancy again is welcome to — content is
  never hidden — but the *stage*, the thing that decides her home screen, only
  moves back by adding a pregnancy.
- **A pregnancy becomes a child.** At birth, `children` gets a row; the
  pregnancy's data stays on the person. Today the pregnancy is
  `profiles.due_date` + `life_stage`, one at a time. **The second baby needs a
  `pregnancies` table** (start, dating method, due date, outcome, child_id)
  so the first pregnancy is not overwritten — that is Apple Health's "log a
  past pregnancy" and it is owed, not built. Recorded in STILL-OPEN §61.
- **Loss.** A pregnancy can end without a child. The stage moves back to
  trying; nothing she saved or wrote is deleted; and the app must not push
  pregnancy content at her afterwards. That is a personalisation rule
  (content and order, never structure), and the `pregnancies.outcome` column
  is where it reads from.
- **Twins** are two `children` rows from one pregnancy.

## 4. Where a person can join, and what happens

| Joins at | Asked (onboarding) | Created | Home |
|---|---|---|---|
| Trying | stage | nothing else; the TTC intro flow runs on the TTC home | TTC V3 |
| Pregnant | stage · date + method | `due_date`, `DueDateSource` (→ `pregnancies` row when that lands) | Pregnancy V3 |
| Parent 0–5 | stage · baby's name + birthday | one `children` row | Parenting V3 |
| Skilling 6+ | stage · child's name + age | one `children` row (age-derived dob) + `SkChildStore` | `SkillingPreviewScreen` for now |
| Partner, any stage | *Partner* + her code | `partner_id` both ways | Father shell; her stage decides its content |

Whatever she joins at, **everything below her account is the same tables**, so
moving forward never migrates data — it adds a row.

## 5. Saved items — the table this document was written to justify

`0081_saved_items.sql`. One table for every bookmark in the app.

```
saved_items (
  user_id     uuid   → auth.users        WHO saved it (owner, RLS key)
  kind        text                       article | video | recipe | product |
                                         question | read_to_baby | post | tool | activity | tip
  item_id     text                       the content id inside that kind
  stage       text?                      WHERE she was when she saved it — a tag
  child_id    text? → children (set null) WHICH child it was about, if any — a tag
  title       text                       snapshot, so the row renders if the content goes
  subtitle    text?                      snapshot
  saved_at    timestamptz
  updated_at  timestamptz                last-writer-wins across devices
  removed_at  timestamptz?               tombstone — an unsave that must beat a stale save
  primary key (user_id, kind, item_id)
)
```

**Why these exact choices** — each one is an edge case someone will hit:

| Edge case | What happens | Because |
|---|---|---|
| Saved in trying, now pregnant | still there, under *All*; *Trying* chip shows it | owner is the person; `stage` is a tag |
| Second baby | every save from the first is still there; `child_id` filters, never hides | owner is the person |
| Partner saves something | it is *his* list, on his account | a bookmark is personal; the couple shares the child's records, not each other's reading |
| The article is edited or removed from the library | the row still renders its snapshot title with *No longer available · Remove* | `title` is a snapshot; a bookmark found by comparing a live title orphans on every edit (read_to_baby_saved_store's own header says so) |
| Unsaved on phone B while phone A is offline, then A comes back | the unsave wins | `removed_at` tombstone, last `updated_at` wins; a union merge would resurrect it |
| Same article saved twice, or saved in two stages | one row; `stage` keeps the first | primary key on (user, kind, item) — the app-generates-the-identity rule, with no uuid needed because the natural key *is* the identity |
| Logged out, saves locally, later signs in | local rows push up with their own `saved_at`; cloud rows come down; nothing clobbers | merge by key, not "cloud wins" |
| Account deleted | rows go | `on delete cascade` |
| An older app meets a `kind` it does not know | the row is kept and skipped on screen | forward-compatible; never crash on content vocabulary |
| The seven old saved-sets on an existing install | imported once into `saved_items`, then the old sets are read no more | nothing a tester saved this month is lost on update |

**Not shared with the partner, deliberately.** Sharing a bookmark is a feature
(a "send to partner" action), not a default, and a shared list makes "my
saved" mean "our saved" in a product that also holds her private symptoms.
If wanted later: a `shared` boolean and a read policy — one migration.

## 6. The Saved screen — one, for the whole app

*All* first, kind chips with counts, newest first, a stage chip row beneath
when she has saves from more than one stage (Withings' grouped *All*, NYT's
chips). Every row opens the thing itself — `SavedItemOpener` maps kind →
screen, and that map is the single place "what does tapping a saved thing do"
is answered. Reached from Profile › Saved and from both V3 homes. The two old
hubs stay, commented at their call sites.

## 7. What this closes and what it opens

Closes: "will I lose it when I move stage" (no, by construction); the
seven-stores problem; STILL-OPEN §9.7's hold on reader bookmarks.
Opens: `pregnancies` (§61.1); a unified product catalogue across stages,
which the user has asked for and which is the same shape as this — one table,
stage as a tag (§61.2).

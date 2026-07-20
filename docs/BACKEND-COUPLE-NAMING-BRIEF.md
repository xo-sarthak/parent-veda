# Backend brief — pairing, the father on the parenting side, and couple name matching

Written 19 July 2026. A self-contained addition to
`docs/BACKEND-PARENTING-BRIEF.md`; everything in that brief still stands.

Read §1 first. It is a five-minute fix that should not wait for the rest.

---

## 1. START HERE — the UI currently claims something untrue

`NameMatchStore` (`pp_names_data.dart`) has exactly one list, `_liked`, and:

```dart
int get matchedCount => _liked.length;
```

There is **no partner concept anywhere in the naming code** — zero references
to partner, father or spouse across `pp_names_data.dart` and
`pp_names_v2_data.dart`. But the UI says:

* *"3 names you've **both** said yes to"* — `name_matches_screen.dart`
* *"names are waiting in the ones you **both** love"* — `name_journey_feed_screen.dart`
* *"matched"* on the naming home

So a mother who likes six names alone is told her partner liked all six. **This
is not a missing backend. It is the app asserting a mutual agreement that never
happened**, and a couple who compare screens find out immediately.

**Do this first, before any schema work:** change the copy to "names you like".
It is honest, it takes minutes, and it stops the app making a claim it cannot
support. Restore the "both" language only once §4 is real.

---

## 2. The pairing model — context the naming feature depends on

This already exists and works. It is written down because the naming feature is
the first place it becomes user-visible, and whoever builds §4 needs the whole
shape.

### The flow

1. **Mother signs up** as `role = 'mother'`. A `pairing_code` is generated for
   her (`0009_pairing.sql`, `gen_pairing_code()`).
2. **She shares the code** with her partner.
3. **Father signs up** as `role = 'father'` and enters the code. The accounts
   link: `profiles.partner_id` is set, and his own unused code is cleared
   (`auth_flow_screen.dart` — *"the father shares no code"*).
4. From then on they are **one couple, one baby, two accounts**. This is
   deliberately not "several ids floating around" — every child-scoped row
   resolves through this single link.
5. **Pregnancy side:** the father has a deliberately limited experience.
6. **Baby is born → the app moves to the parenting side.** The pairing persists
   unchanged. It is the same link, still doing the same job.

### What is different about the parenting side

**On the parenting side the father is a full participant.** Mother and father
see the same screens; there is no reduced father experience the way there is
during pregnancy. Verified in code: nothing under `lib/screens/post_pregnancy/`
branches on role — it is role-blind by design.

This matters for backend work because it means **every parenting feature is
co-parented by default**. Both parents read and write the same child's rows.
That is already how `0021_children` and the `ChildSync` tables behave:

```sql
using (auth.uid() = user_id or user_id = public.my_partner_id())
```

`public.my_partner_id()` (from `0009`) is the single expression for "the person
I am paired with". **Do not introduce a second way of saying this.** Every new
child-scoped policy should resolve through it.

### Where the pairing becomes visible

Everywhere else, pairing is invisible plumbing — both parents simply see the
same health record, the same growth curve, the same documents.

**Baby naming is the first feature where the two accounts are visibly, actively
two people.** That is the whole point of §4: it is where a parent can see that
they and their partner are working on the same baby, together, and where the
link stops being infrastructure and becomes the experience.

---

## 3. What the naming feature actually is

Tinder, for baby names, between two paired parents.

* Each parent swipes through names **independently**.
* A name becomes a **match** only when BOTH have liked it.
* Neither sees the other's likes before their own — otherwise the second parent
  is ratifying the first one's list, which defeats the point entirely.
* Matches flow into "the ones you both love" → shortlist → compare → chosen →
  the name story.

The rest of the journey (collections, taste quiz, shortlist, compare, crown)
already works locally and needs nothing.

**Solo use must keep working.** A parent with no paired partner still likes
names and builds a shortlist; she simply has no matches. Logged out, everything
stays local, exactly as the other stores behave.

---

## 4. Data shape

One row per parent per name — NOT one per couple. A match is **derived**, never
stored, so it cannot drift out of step with the underlying likes.

```sql
create table name_votes (
  id          bigserial primary key,
  child_id    uuid not null references children(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  liked       boolean not null,          -- false = explicitly skipped
  created_at  timestamptz not null default now(),
  unique (child_id, user_id, name)
);
```

**Why child-scoped:** a couple naming their second baby starts fresh.
`child_id` gives that for free and matches the `ChildSync` pattern already used
for health, growth, feeds, sleeps, milestones and documents.

`unique (child_id, user_id, name)` makes a re-swipe an upsert, not a duplicate.

### RLS — and how it differs from every other table so far

* **Insert / update / delete:** own rows only, `auth.uid() = user_id`. Neither
  parent may vote on the other's behalf.
* **Select:** both paired parents, via `public.my_partner_id()`. This is
  *required* — the match is computed from both sides.

### The match query

```sql
select name
from name_votes
where child_id = $1 and liked
group by name
having count(distinct user_id) = 2;
```

Derived, not stored. If one parent un-likes a name, the match simply stops
being returned.

---

## 5. The rule that matters most

**Do not show a parent their partner's individual votes.**

Select permission is needed to compute matches, so the client *could* read the
other person's likes and display them. It must not. A parent who can see what
their partner liked before swiping is no longer giving an independent opinion,
and the feature is worth nothing if the second vote merely echoes the first.

Expose matches through a narrow read — a view, an RPC, or a client helper that
only ever returns the intersection. Nothing in the UI should be able to answer
"what did my partner like?" for an unmatched name.

Worth an invariant test, in the same spirit as
`pp_no_fabricated_child_data_test.dart`.

---

## 6. Client side

`NameMatchStore` needs:

* `_liked` → per-user votes synced to `name_votes` via `ChildSync`
* a new `matches` list, populated from the intersection query
* `matchedCount` reading from `matches`, **not** `_liked.length`

That last line is the actual bug. Everything else is plumbing.

---

## 7. Not in scope

* The naming journey's other steps — collections, quiz, shortlist, compare,
  crown, name story — all work and need nothing.
* **V1 (the classic Name Finder) is retired** as of 19 July. V2 is the only
  path; the V1|V2 toggle and `NameVersionStore` are dead and commented. Do not
  sync `NameVersionStore`.
* `PpTrackerStore` is likewise dead — the feeding and sleep journeys replaced
  its screens, and `FeedingStore` / `SleepStore` already sync. Correctly skipped.

---

## 8. The standard this is being held to

Stated because it explains why these briefs are this specific.

The app is approaching feature-completion on both the pregnancy and parenting
sides, with trying-to-conceive still ahead. The remaining work is not more
features — it is making sure the base is solid enough that everything above it
can be trusted:

* **sync that genuinely works**, so a parent never loses her child's record;
* **personalization that genuinely personalizes**, rather than a profile that
  collects answers and changes nothing;
* **the mother-and-father flow working end to end**, which is what §2 and §4
  are about;
* **health, growth, documents and vaccinations holding real entered data**,
  with seed content never masquerading as a parent's own.

Debug toggles, review switches and placeholder states are known and will be
swept in a dedicated polish pass — deliberately last, so the whole flow can be
seen working first. They are not a reason to weaken anything above.

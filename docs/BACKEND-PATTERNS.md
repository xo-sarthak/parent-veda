# ParentVeda — Backend Patterns (a learning doc)

**Purpose.** Not a checklist (that's `supabase/BACKEND-PLAN.md`). This teaches
*how* the persistence backend actually works and *why* each pattern is shaped
the way it is — so the next feature can be built by recognising which pattern it
needs rather than reinventing one. Every pattern points at real files.

If you read one thing, read **§2 (RLS)** and **§7 (the name-privacy trick)**.
The rest hangs off those two ideas.

---

## 1. The one mental model: two layers on every request

A logged-in app talks to Postgres through Supabase using the **`authenticated`**
role. Every single query passes two gates, in order:

1. **GRANT** — "may this role touch this table *at all*?" Table-wide. Yes/no.
2. **RLS (Row-Level Security)** — "which *rows* may it touch?" Row-by-row.

Miss the GRANT and you get `permission denied for table X` (code `42501`) — the
request never even reaches the row rules. That's why every migration has this:

```sql
grant select, insert, update, delete on public.pp_medications to authenticated;
alter table public.pp_medications enable row level security;
```

The Supabase Table-Editor UI adds the grant for you; raw SQL does **not**, which
is the single most common "it worked in the dashboard but not from SQL" bug.

**Key idea:** the security lives in the *database*, not the app. Even if the
Flutter code had a bug and asked for someone else's row, Postgres refuses. The
client can't be the thing that keeps data private, because anyone can write
their own client. This is the whole reason we push rules down into SQL.

---

## 2. RLS — the four policies, and `auth.uid()`

RLS is off by default; `enable row level security` turns it on, and once on, a
table with **no policies denies everything**. You then add policies that grant
access back. A policy is just a boolean SQL expression evaluated per row.

The magic function is **`auth.uid()`** — inside any policy it returns the id of
the logged-in user making *this* request. So "you can only see your own rows"
is literally:

```sql
create policy "medications own select" on public.medications for select
  using (auth.uid() = user_id);
```

Four verbs, four policies (`select`, `insert`, `update`, `delete`). Two use
different clauses, and the difference matters:

- **`using (...)`** — filters *existing* rows. Applies to select/update/delete.
  "Which rows may I read / change / remove?"
- **`with check (...)`** — validates a *new or changed* row's values. Applies to
  insert/update. "Is the row I'm writing allowed to look like this?"

An insert uses `with check` because there's no existing row to filter — you're
vetting what's about to land. That's how we stop someone forging authorship:

```sql
create policy "pp_medications child insert" on public.pp_medications for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
```

`auth.uid() = user_id` in the check means you cannot insert a row *claiming* to
be someone else — the `user_id` you write must be your own.

**Reference:** `0001_create_profiles.sql` (the simplest own-row set),
`0005_health.sql` (own-row on real feature tables).

---

## 3. The three ownership shapes we use

Every table's RLS is one of three shapes. Picking the shape *is* the design
decision; the SQL follows from it.

### (a) Own-row — the pregnancy default
"This row is mine; nobody else sees it." `auth.uid() = user_id` on all four.
Used for personal data: my symptoms, my journal, my saved videos.

### (b) Co-parented — the parenting default
"This row is about a CHILD; both paired parents read *and* write it." A feed one
parent logs is the same row the other can correct.

Here `user_id` stops being the lock and becomes **attribution** — a note saying
"Dad logged this", useful for display, but *not* what grants access. Access runs
through the child (§4). Contrast with the pregnancy side, where the partner may
only *read* (`0012_share_scans.sql` widens SELECT only). Parenting widens
update and delete too — that's the deliberate deviation, because the app shows
both parents the same screens for the same baby.

### (c) Couple-scoped — the special case
"This row is mine, but a *derived* answer combines it with my partner's."
Baby-name votes (§7). Own-rows-only RLS, but a function reaches across the pair.

**How to choose:** ask "who is this row *about*?"
- About me, private → (a).
- About the baby → (b).
- About me, but the feature's whole point is comparing with my partner → (c).

---

## 4. `security definer` — the trick that makes co-parenting possible

Co-parenting needs a policy to say "…or a child I co-parent." But *how does the
database know which children I co-parent?* That's in the `children` table — and
if a policy on a child-scoped table queries `children`, which itself has RLS,
you get **infinite recursion** (its policies query back, forever).

The escape is a **`security definer`** function. Normally SQL runs with *your*
permissions (`security invoker`). A `security definer` function runs with the
permissions of whoever *created* it (a superuser) — so it reads `children`
*bypassing that table's RLS*, returns a plain list, and the recursion is broken.

```sql
create or replace function public.my_child_ids()
returns setof text
language sql
stable
security definer set search_path = ''
as $$
  select id from public.children
  where user_id = auth.uid()
     or user_id = public.my_partner_id();
$$;
```

Then every child-scoped policy is a one-liner:

```sql
using (child_id in (select public.my_child_ids()))
```

Three details that are load-bearing, not decoration:
- **`security definer`** — the whole point: read past RLS without recursing.
- **`set search_path = ''`** — a security hardening. Without it, a definer
  function can be tricked into calling a malicious `children` from another
  schema. Forcing an empty search path means every name must be fully qualified
  (`public.children`), so there's nothing to hijack. **Always pair these two.**
- **`stable`** — tells Postgres the result won't change within one statement, so
  it can call the function *once per query* instead of once per row. On a table
  with thousands of feeds that's the difference between fast and unusable.

`public.my_partner_id()` (from `0009_pairing.sql`) is the same trick, one level
down: it reads *your* profile row to find your partner, with definer rights so
the pairing policies can call it without recursing.

**The rule this buys us:** there is exactly ONE expression for "the person I'm
paired with" (`my_partner_id`) and ONE for "children I may touch"
(`my_child_ids`). Never write a second way of saying either — a second
definition is a second thing to get wrong, and they *will* drift.

**Reference:** `0021_children.sql`.

---

## 5. Two homes for data: the KV table vs a real table

Not every store deserves its own table. We split on one question: **do you ever
need to query INTO the data, or only load the whole blob?**

- **A real per-feature table** when you filter, sort, join, or count *inside* the
  data: "this child's feeds, newest first", "vaccines marked done". Health,
  growth, feeds, sleep, milestones, documents.
- **The generic `user_state` KV table** (`0011_user_state.sql`) when the store is
  just "shared_preferences, but in the cloud" — one JSON blob you load whole and
  never query into. Saved lists, reading progress, preferences.

`user_state` is `(user_id, store_key) → jsonb`. Each light store picks a
`store_key` and syncs one blob. **No migration** to add one — that's the payoff.

Crucial constraint that has bitten us: **`user_state` RLS is own-only.** So
child-shared data can *never* live there — a feed log in `user_state` would be
invisible to the other parent, silently breaking co-parenting. KV = personal
only. If two people must see it, it needs a real table with a co-parent policy.

**Reference:** `0011_user_state.sql`, `lib/services/remote/cloud_synced_store.dart`.

---

## 6. Local-first sync — the client half

The database rules above are only half the story. The app is **local-first**:

1. On startup a store loads its `shared_preferences` cache and shows it
   *instantly*, before any network call. The app opens and works offline.
2. *Then* it syncs with the cloud, and a failure there is **never** a crash —
   every sync call is wrapped in `try/catch` and degrades to local-only. Logged
   out, the whole thing is a silent no-op and the app runs from cache.

Two client seams implement this:

- **`SupabaseRepo`** (`lib/services/remote/supabase_repo.dart`) — the one place
  every table call goes through. It attaches `user_id` automatically and returns
  `[]`/no-op when logged out, so "only my data" and "works offline" live in one
  spot instead of being re-implemented per store. It has an own-user half
  (`fetch`, `insert`) and a co-parented half (`fetchByChild`, `updateShared`,
  `deleteShared`) that drops the user filter and lets RLS do the scoping.
- **`CloudSyncedStore`** (the mixin) — for KV stores. It overrides
  `notifyListeners()` to also push the blob up, so *one* override covers every
  mutation site. A `_cloudReady` flag stops the load-from-cache notifications
  from clobbering the cloud before it's read.

Sync itself is an **id-keyed merge**: fetch the cloud rows into a map by id,
push up anything only local has, adopt the union. This is why the house rule is
"the app generates the row id" — local row and cloud row share one id, so the
merge is trivial and idempotent.

A subtle robustness fix worth remembering: `SupabaseRepo.userId` returns `null`
(not throws) when Supabase isn't initialised, because touching
`Supabase.instance` before init *asserts*. Without that guard, an uninitialised
backend would crash stores instead of degrading to local — the opposite of the
rule. Any "is the backend available?" gate must fail soft.

---

## 7. The worked example: keeping each parent's name-votes private

This is the pattern worth understanding in full, because it shows the limit of
RLS and how to go past it.

**The feature.** Two paired parents swipe baby names independently. A name is a
"match" only when *both* liked it. The rule that makes it worth anything: **a
parent must never see their partner's individual likes** — if you see their list
first, you just ratify it, and the second opinion is worthless.

**Why plain RLS can't do this.** To compute the overlap, *someone* has to read
both parents' votes. The obvious move is to widen SELECT to the partner:

```sql
-- what the brief proposed — and why we DIDN'T do it
using (auth.uid() = user_id or user_id = public.my_partner_id())
```

That works — the client fetches both sides and intersects them. But it hands the
**client** every one of the partner's votes. "Don't display them" is then a
*promise the app makes*, not a rule the database enforces. Anyone reading the
table directly, or a future screen added in good faith, breaks it. A privacy
rule the client is merely asked to honour is not a privacy rule.

**What we did instead.** Keep the votes table **own-rows-only in every
direction, SELECT included** — the partner's rows are simply unreadable to you.
Then expose the overlap through a `security definer` function that reads both
sides but returns *only the intersection*:

```sql
create policy "pp_name_votes own select" on public.pp_name_votes for select
  using (auth.uid() = user_id);            -- you cannot read your partner's votes

create or replace function public.pp_name_matches()
returns setof text
language sql
stable
security definer set search_path = ''
as $$
  select v.name
  from public.pp_name_votes v
  where v.liked
    and v.user_id in (auth.uid(), public.my_partner_id())
  group by v.name
  having count(distinct v.user_id) = 2;   -- BOTH of us liked it
$$;
```

The function runs with definer rights, so it *can* read both parents' rows — but
it's a sealed box. It returns names, never *whose* vote produced them, and never
a name only one person liked (`having count(distinct user_id) = 2`). There is no
query a client can write that answers "what did my partner like?" for an
unmatched name, because the raw rows never leave the database. **The privacy is
enforced by Postgres, not by our discipline.** That's the whole lesson.

Two more properties fall out for free:
- **Unpaired?** `my_partner_id()` is `null`, so only your own rows are in scope,
  the distinct-user count can't reach 2, and the result is empty. Solo use just
  works — you build a shortlist, you have no matches. No special-casing.
- **A match is derived, never stored.** There's no second "matches" table to
  drift. Un-like a name and it simply stops being returned next call.

**The generalisable shape:** when an answer must combine data that individuals
aren't allowed to see raw, don't widen read access — keep the rows private and
put a `security definer` function in front that returns *only the computed
answer*. Same trick as `my_child_ids`, aimed at privacy instead of recursion.

**Reference:** `0027_pp_name_votes.sql`,
`lib/screens/post_pregnancy/pp_names_data.dart` (the client calls the function
via `SupabaseRepo.callFunction('pp_name_matches')` — it *cannot* compute the
match itself, by design).

---

## 8. A fourth ownership shape: write-only (analytics)

§3 gave three shapes for data you *own*. Analytics is a fourth: data **nobody
reads back into the app at all.** `profile_events` (`0028`) records which
profiling questions were shown and answered, to judge the questions — it feeds a
dashboard, never a screen.

That flips the usual worry. Normally we ask "who may *read* this?" Here reading
is the whole risk: the table is a behavioural log, and if a client could pull it
you'd leak everyone's activity. So the shape is **insert-only, never readable**:

```sql
grant insert on public.profile_events to anon, authenticated;   -- write, both roles
grant usage  on sequence public.profile_events_id_seq to anon, authenticated;
alter table public.profile_events enable row level security;

create policy "profile_events insert only" on public.profile_events for insert
  to anon, authenticated
  with check (true);
-- and NO select/update/delete policy: RLS then denies all three.
```

Four things here are easy to get wrong and each is load-bearing:

- **`to anon, authenticated`** — the strips run *before login*, so the anonymous
  role must be able to insert. Most tables only grant to `authenticated`.
- **No `user_id`** — the row is keyed to a random `install_id`, not an account.
  Analytics shouldn't force an identity the feature didn't need; the join to a
  real user can happen server-side later. So there's nothing to check ownership
  against, and `with check (true)` is correct (the worst abuse is junk rows, not
  a leak).
- **The absent policies ARE the security.** With RLS on, a verb with no policy
  is denied. Writing no select policy is not an oversight — it's how "nobody
  reads this" is enforced. The dashboard still reads it, because `service_role`
  bypasses RLS entirely.
- **The sequence grant.** `bigserial` auto-fills `id` via `nextval()` on a
  sequence, and that needs its own `grant usage on sequence` — the table grant
  doesn't cover it. Miss it and every insert fails with "permission denied for
  sequence", which looks baffling because the table grant is obviously present.

**One client-side pairing that completes the contract:** the insert must not
read the new row back. Supabase's `.insert(row)` without `.select()` sends
`Prefer: return=minimal`, so no read happens. If a client *did* `.select()` the
inserted row, PostgREST would need SELECT — which we deliberately denied — and
the whole call would fail. So "write-only" is enforced on both ends: the DB
refuses reads, and the client is built never to ask for one
(`SupabaseRepo.fireEvent`).

**Reference:** `0028_profile_events.sql`,
`lib/services/remote/supabase_profile_sink.dart`. Contrast with §7: there the
rows are private but a computed *answer* is exposed; here nothing is exposed to
the app at all.

## 9. Reading list, in order

1. `0001_create_profiles.sql` — the two layers (grant + RLS), own-row.
2. `0011_user_state.sql` — the KV escape hatch.
3. `0009_pairing.sql` — `my_partner_id`, the first `security definer`.
4. `0021_children.sql` — `my_child_ids`, co-parenting.
5. `0022_pp_health.sql` — the co-parent pattern applied at scale.
6. `0027_pp_name_votes.sql` — privacy past the limit of RLS.
7. `0028_profile_events.sql` — the write-only shape (deny reads on purpose).
8. `lib/services/remote/supabase_repo.dart` + `cloud_synced_store.dart` — the
   client half of everything above.

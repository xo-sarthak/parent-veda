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

## 9. The admin panel: three boundaries, three different mechanisms

Added 2026-07-28, from building migrations `0045`–`0055`. The panel is worth
studying as system design because it needed **three different kinds of
boundary**, and each one is enforced by a different mechanism. Using the wrong
mechanism for a boundary is how most of these systems leak.

### (a) "Which tables may the CMS touch at all?" → **Postgres GRANTs**

Directus has its own permissions UI. It is a convenience layer, not a boundary:
those permissions are rows in the same admin interface they are meant to
restrain, so one mis-click makes them wider.

`0045` moved the boundary somewhere the UI cannot reach — a dedicated
`directus_cms` role with **allow-list** grants. Content tables get CRUD, config
tables get select+update, and the ~65 user-data tables get *nothing*.

Two properties worth copying:

* **The deny list is never written down.** A new role has no privileges by
  default, and this project grants only to `anon` / `authenticated` /
  `service_role`, never to `PUBLIC`. So the safe state is the default state.
  Enumerating what to deny would rot the day someone adds table 77 and forgets.
* **The friction is the feature.** A new content table does not appear in
  Directus until someone adds a grant *and* a policy. That is annoying exactly
  once per table, and it means access is always a deliberate act.
  `test/content_migrations_test.dart` fails if a grant appears outside a
  reviewed list, so the list stays a review rather than a wishlist.

### (b) "Which rows may it see?" → **RLS policies**

A grant gets you past the privilege check; the *policy* decides which rows. Both
must pass, and forgetting the second is the subtle one:

| Missing | Symptom |
|---|---|
| the GRANT | "permission denied" — loud, obvious |
| the POLICY | **zero rows** — looks like empty data, not a permission problem |

That second failure had a specific consequence here. Content tables carry
`using (status = 'published')` for the app. Without an additional CMS policy,
Directus would connect fine, list the collection, and show an editor everything
*except their own drafts* — which reads as a broken save button, not a
permissions bug.

### (c) "May this person do this *act*?" → **`security definer` functions**

Approving a doctor is not a row edit. It is a decision with preconditions:
registration present, KYC present, licence unexpired. Modelled as a `status`
dropdown, an unverified doctor gets approved by someone who assumed the checks
happened elsewhere.

So the rule lives in a function that **refuses**, with `execute` revoked from
public and granted to `service_role` alone. The doctor's own app cannot call it
regardless of how any panel is configured — the permission is on the function,
not on the screen that calls it.

The general shape, reusable well beyond this:

> **When an operation has preconditions, make the operation a function and put
> the preconditions inside it.** Then no caller can skip them, because there is
> no path that does not go through the check.

### (d) The lesson that cost a real defect: a `raise` erases what it explains

Every gate originally did this:

```sql
perform public._audit(... 'refused' ...);   -- record the blocked attempt
raise exception 'cannot approve %: ...';    -- refuse
```

Correct-looking, and wrong. `raise exception` **aborts the transaction**, and
aborting undoes everything the transaction did — including the audit INSERT one
line above. Successes committed; refusals erased themselves. The log could
answer "who approved this doctor" but not "who tried and was stopped", which is
the question asked after something goes wrong.

`0055` returns `{ok, code, message}` instead of raising, so nothing aborts and
the row commits.

**The generalisable fact:** *anything written inside a transaction that later
aborts is lost — logs, metrics, queued notifications, all of it.* If a record
must survive a failure, it cannot be written by the thing that fails.

**And the trade-off, because there always is one.** Raising made a careless
caller fail loudly (HTTP 4xx). Returning is HTTP 200, so a caller that ignores
the body reports success for an approval that never happened. That was accepted
deliberately: an unchecked caller is a bug in one place, visible the first time
anyone tests it; a missing audit row is evidence nobody can recover. Recorded in
`STILL-OPEN.md` §4.4a so the reasoning outlives the decision.

### (e) One authority per fact

Programmes needed seats. There was already a seat counter — `book_slot()` in
`0029`, with a `FOR UPDATE` lock. Publishing a programme therefore *mirrors* its
sessions into `booking_slots` rather than counting separately.

Two counters for one fact will disagree eventually, and the disagreement shows
up as a double-booked session on the day. Same reason `0040` made the database
the only thing that mints a referral token: the app used to derive one too, and
a token with no matching row scanned, looked right, and credited nobody — printed
on a poster for two years.

> Before adding a counter, a token generator or an id scheme, look for the one
> that already exists.

### Verifying it without a test harness

There is no integration-test harness for SQL here. `supabase/seed/verify_admin_gates.sql`
is the cheap substitute: it exercises every refusal path, reports pass/fail, and
**raises at the end so the whole thing rolls back** — a transaction abort used
deliberately, for the same property that caused the bug in (d). One paste, a
readable report, nothing left behind. It is what found the defect.

---

## 10. Multi-tenancy: letting a customer see their own data and nothing else

The sponsor programme (`0057`–`0060`) is the first place ParentVeda has a
*second kind of customer* reading the database — an employer, looking at
take-up of a benefit they bought for their staff. That is a different problem
from co-parenting, and it is worth its own section because the failure mode is
categorical: one company seeing another company's rows is not a bug you patch,
it is the end of the product.

### (a) Never ask "is this user Premium?" — ask "does this user have X?"

The obvious design is a `plan` column and `if plan == 'premium'` at each gate.
It survives one plan. Then it is `if premium or employer`, then `or insurer`,
then `or hospital` — and every one of those conditions lives in **app code**, so
onboarding a new customer type means a release, a review, and a rollout to
people who never update.

Capabilities invert it (`0057`). A gate asks one question that never changes
("may this user book a sponsored consultation?"); *who may* is a row in
`plan_capabilities`. Adding an insurer tier becomes data entry.

The migration was seeded so the `free` plan grants everything, which means it
changed nothing on the day it ran. **That is what makes it safe to ship an
architecture before the product decisions it will eventually carry** — the same
trick `0019` and `0036` used. Making something Premium later is deleting one
row.

> The general fact: a design that turns future *decisions* into future *data*
> is worth an extra table. A design that turns them into future *conditions* is
> not, because conditions accumulate in the place that is hardest to change.

### (b) The tenant is resolved from the session, never from a parameter

```sql
create function public.sponsor_roster() returns table (...)
  security definer as $$
  select ... where m.sponsor_id = public.my_sponsor_admin_id();
$$;
```

`my_sponsor_admin_id()` reads `auth.uid()`. There is no argument, so there is
nothing for a modified client to change and no shape of the call that answers
about another company. Same reasoning as `expert_roster()` in `0030`.

This also settles a question that keeps coming back: is a guessable URL like
`/portal/acme` a risk? No — **the URL must never determine access; the session
must.** Scope the query to the caller in Postgres and a guessed URL returns
zero rows.

### (c) The return type IS the privacy policy

`sponsor_roster()` returns `work_email, status, activated_at, removed_at`. Not
`user_id`, not a name, not a booking, not a last-seen.

A caller cannot select a column a function does not return. So the promise made
to the employee — *your employer sees whether you activated, never what you
did* — is enforced by a **signature** rather than by everyone remembering. A
policy can be forgotten; a column that does not exist cannot be selected.

Compare with `0034`, where the *opposite* call was right: `expert_roster()` was
widened to include the patient's name and due date, because a doctor about to
see someone needs to know who. Same mechanism, opposite answer — which is the
point. The return type is where you make that decision, and it is the only place
it is enforced.

### (d) Aggregate in the database, not in the client

Every number on the HR dashboard arrives already counted. The alternative —
returning rows and counting in Dart — leaks by construction: to compute *how
many consultations*, the client would first have to **hold the consultations**.

> If a screen shows a total, ask what the client had to receive in order to
> compute it. That, not the total, is what you shipped.

It is also why a web portal later is a front-end job rather than a rebuild: the
product is the functions.

### (e) k-anonymity: when an aggregate is still a name

"Three consultations this month" is anonymous at Infosys and is a *name* at a
thirty-person startup. So behavioural figures are withheld below a cohort of
`n` (default 5, a **config row** so a privacy decision can be tightened without
a release), and the API returns `null` with a `suppressed` flag — not `0`.

The null-versus-zero distinction is the whole thing. A zero is a claim about
the company ("nobody is using it"); a null is a statement about our policy. Show
the wrong one and a sponsor concludes the benefit is failing.

**What is *not* suppressed:** seats and activation counts. Those are commercial
facts about a contract the customer signed, they are not behaviour, and refusing
to tell someone how many of their own seats are used would be absurd. The line
is behaviour, not headcount — and drawing it in the right place is what makes
the rest of the suppression credible.

### (f) Column-level grants do not narrow a table-level grant

A real Postgres trap, hit in `0059`. `0058` had done:

```sql
grant select, insert, update, delete on public.sponsors to directus_cms;
```

Then `0059` added a demo-only `dev_bypass_code` column that the CMS must never
write. The instinct is:

```sql
revoke update (dev_bypass_code) on public.sponsors from directus_cms;   -- does nothing useful
```

It does not work. A table-level `UPDATE` grant is a single privilege covering
every column, present and future; a column-level revoke cannot carve a hole in
it. The fix is to drop the table-level grant and re-grant an explicit column
list:

```sql
revoke insert, update on public.sponsors from directus_cms;
grant insert (id, name, kind, plan_id, ...), update (name, kind, ...)
  on public.sponsors to directus_cms;
```

> The general fact: privileges in Postgres are granted, not subtracted. If you
> need an exception, you need a narrower grant — not a revoke on top of a broad
> one. The same is true of RLS: policies are permissive by default and OR
> together, so adding one never restricts anything.

### (g) A backdoor is acceptable only if it is findable

`0059` exists because there is no email provider yet (`STILL-OPEN` §11.6), so
activation could not be demonstrated at all. The tempting fix — return the real
code from `request_sponsor_activation()` — deletes the feature while leaving the
UI *looking* like it still verifies, which is worse than having no verification,
because the appearance would be trusted.

What was done instead is worth generalising into four properties any deliberate
weakening should have:

1. **Scoped to one row**, not a global flag or an environment variable. A
   forgotten demo sponsor cannot weaken anyone else.
2. **Everything else stays real** — domain match, active customer, free seat,
   rate limit, attempt limit, single use. Only the inbox is skipped.
3. **Audited as a different fact.** A bypassed grant returns
   `activated_dev_bypass`, so `admin_audit` distinguishes it from a verified
   one. *A backdoor you cannot find in the log is the one that stays.*
4. **Unreachable from the panel**, via (f) above, and constrained by the
   database (`length >= 10`) so it cannot become guessable.

Plus a one-line audit anybody can run: `select id from public.sponsors where
dev_bypass_code is not null;`

### Verifying it

`supabase/seed/verify_sponsor_gates.sql`, same shape as `verify_admin_gates.sql`:
every refusal path, real tables, a borrowed session via `set_config
('request.jwt.claims', ...)` so `auth.uid()` resolves, and `raise exception` at
the end to roll it all back. It asserts the cross-tenant case explicitly —
including creating a member of the *other* sponsor first, because a leak test
with nothing to leak passes for the wrong reason.

---

## 11. Three ways a migration lies about having run

All three were hit for real on 2026-07-30, within an hour, and each cost time
because the error message points somewhere other than the cause.

### `create or replace function` will not rename a parameter

Replacing a function is idempotent *until* you change a parameter's **name**.
Then Postgres refuses:

```
cannot change name of input parameter "p_speciality"
```

The statement fails, **the old version stays**, and the rest of the script
carries on. So the function exists, the migration file looks applied, and the
signature quietly does not match what the file says. Nothing in the database
records that a statement was skipped.

The only way out is to drop and re-create:

```sql
drop function if exists public.create_care_partner(text, text, text, text,
                                                   text, text, text, text);
```

Which means the drop needs the OLD signature — the one you no longer have in
front of you. Hence the introspection habit below.

**The habit:** when a function behaves as though a migration did not run, look
before diagnosing.

```sql
select proname, pg_get_function_identity_arguments(oid) as args
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'public' and proname like 'partner%';
```

### A `GRANT` names a function by its exact argument types

```sql
grant execute on function public.create_care_partner(text, text, text, text,
                                                     text, text, text, text)
  to directus_cms;
```

If the deployed signature has drifted by even one type, this fails with:

```
ERROR: function public.create_care_partner(...) does not exist
```

Which is true of the signature you *named*, and reads as *"the migration was
never run"* — sending you to check the wrong thing entirely. The function is
right there.

**The fix is to grant what exists rather than what you believe exists**
(`0070_partner_accounts_cms.sql`):

```sql
do $$
declare r record;
begin
  for r in
    select p.oid::regprocedure as sig
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.proname in ('create_care_partner', 'mint_partner_token')
  loop
    execute format('grant execute on function %s to directus_cms', r.sig);
  end loop;
end $$;
```

`oid::regprocedure` renders the signature Postgres actually has. This cannot
drift, and it survives someone adding a default parameter later.

### Re-running an old migration can resurrect what a newer one replaced

The sting in the tail of the first case. `0052` superseded `0040`'s
`create_care_partner` by adding a ninth parameter for the audit actor. Adding a
parameter creates a SECOND function, so after re-running `0040` the database
held both — and a caller passing eight arguments would get the version that
writes **no audit row**. Silently. The audit trail would have gaps that nothing
explains.

```sql
select p.oid::regprocedure, has_function_privilege('directus_cms',p.oid,'execute')
  from pg_proc p join pg_namespace n on n.oid=p.pronamespace
 where n.nspname='public' and p.proname='create_care_partner';
```

Two rows where you expect one is the tell.

**So a migration is only idempotent against the schema it was written for.**
Re-running an old one is not free once a later migration has changed the same
object. When you must, check for duplicates afterwards — and leave a warning in
the older file, as `0040` now carries.

**The general shape**, and why all three sit in one section: an error naming
something you wrote is easy to trust. An error saying a thing *does not exist*,
when you can plainly see that it does, almost always means you named a
**different** thing — a different signature, a different schema, a different
role. Check what is there before deciding what is wrong.

---

## 12. One entity, many capabilities — modelling partners without exceptions

*Added 2026-07-30, after getting the same table wrong twice.*

`0072` and `0073` model everyone ParentVeda partners with: a doctor in her own
clinic, a 400-bed hospital, an IVF centre, a diagnostic lab, a nutritionist.
The lesson is not about doctors. It is about what happens when you model people
by **what they do** instead of **who they are**.

### (a) The mistake: splitting an identity by activity

The first design had two records. `care_partners` for *"we vetted this person
and they refer families"*; a separate `experts` for *"this person takes
consultations"*.

It reads sensibly and it is wrong, because one doctor may refer families, take
consults, teach a masterclass and review articles. Split by activity and the
same person exists twice, and the two copies drift the first time a phone
number changes.

The correct shape was already in this codebase — `0057`'s entitlement engine:

> Never ask *"is this user Premium?"* Ask *"does this user hold capability X?"*

Applied here: never ask *"is this a partner or an expert?"* Ask *"what may this
entity do?"* So there is **one identity** and **optional capability records**
hanging off it, none required:

```
care_partners  ── WHO THEY ARE. One row, forever. KYC lives here.
   ├── partner_referrals   they refer families      (0037)
   ├── expert_profiles     they deliver something   (0072)
   ├── programme_experts   they teach THIS thing    (0054)
   └── partner_accounts    they can sign in         (0068)
```

A doctor who only refers has one row. One who does everything has four. Gaining
a capability six months later is **adding a row**, never re-onboarding.

> Generally: when you catch yourself writing `type_a_table` and `type_b_table`
> for things that are the same noun doing different verbs, the verbs belong in
> their own tables and the noun belongs in one.

### (b) The second mistake: an exception in the schema

Fixing (a) still left *"who delivers this programme?"* An organisation might
teach without ever consulting, so requiring an `expert_profiles` row felt
wrong — it meant a hospital inventing a consulting profile it does not offer.

So: two host columns on `programme_experts`, `expert_id` **or** `partner_id`,
exactly one set.

Also wrong, and wrong one level down. **Two host columns is itself an
exception** — every query about "who is hosting" carries a branch. The rule was
removed from the functions and reintroduced in the table.

Postgres refused it outright, which was a favour:

```
ERROR: 42P16: column "expert_id" is in a primary key
```

A primary-key column cannot be nullable. The constraint was pointing at the
design flaw.

**The answer was smaller than both attempts.** An organisation gets a deliverer
row like everybody else, with one boolean inside it:

```
expert_profiles
  expert_id  partner_id  name             takes_consults  fee_paise
  meera      cp_meera    Dr Meera Rao     true            80000
  apollo     cp_apollo   Apollo Hospital  false           0
  arjun      cp_apollo   Dr Arjun Nair    true            60000
```

That is not Apollo pretending to consult. It is Apollo having an entry in the
**deliverer catalogue** — the app's existing vocabulary, already used by
`booking_slots.expert_id` and `expert_accounts.expert_id`. Whether it takes 1:1
appointments is one optional fact *inside* the row, not a reason for a second
column.

`programme_experts` then needed no change at all: one host column, composite key
intact, `assign_programme_expert`'s `ON CONFLICT` still working.

> If a design needs a special case in the schema, the model is wrong one level
> up. A boolean inside a row beats a second column beside it, which beats a
> second table.

### (c) The layer was already there

The "which hospital does this doctor come from" link needed no new column:

```
partner_id points at YOURSELF     → you are your own partner  (Meera)
partner_id points at SOMEBODY     → you come from them        (Arjun → Apollo)
```

A `care_partners.parent_partner_id` was proposed and rejected: it would have
been a **second answer to a question that already had one**, and the two would
disagree eventually.

### (d) One resolver, or a bug generator

Two login routes existed — `expert_accounts` (a person), `partner_accounts` (an
organisation) — and almost every consulting gate resolved through the first
only. So a hospital could sign in, see a dashboard, be invited to teach, and
then accept nothing, see no bookings, set no hours, write no prescriptions.
Every failure silent, or wearing an error about something else
(`not an expert account`).

That is not five bugs. It is **one missing primitive, discovered five times**.

```sql
create function public.my_expert_ids() returns setof text ...
-- a solo doctor   -> their own id
-- an organisation -> every deliverer under it
```

Every gate became `expert_id in (select my_expert_ids())`. The branch is gone
from **one** place, so the next feature cannot forget it — there is nowhere left
to put it.

> When the same conditional appears in five gates, it is not five conditionals.
> Extract it, and the sixth gate gets it for free.

### (e) The depth arrives for free

`expert_roster()` now returns `expert_id`, so Apollo sees *which clinician* each
booking belongs to; `partner_referrals.expert_id` records *who handed a QR
over*, so `partner_referral_breakdown()` answers "which of our doctors brought
these families".

Aggregate for the organisation, breakdown by member beside it — deliberately the
same shape as `sponsor_dashboard` / `sponsor_roster` (§10), because it is the
same question asked of a different customer. `company : employees` is
`hospital : doctors`. Same privacy line too: numbers and names of *members*,
never anything about the families.

### (f) Two Postgres traps hit while building it

**`create or replace` with a different arity creates an OVERLOAD.** Adding a
fifth defaulted argument to `mint_partner_token` did not replace the four-arg
version — it added a second function. Both accept `mint_partner_token('cp_x')`,
so Postgres refuses the call as ambiguous and every existing caller breaks at
once, with an error about function resolution rather than about anything anyone
changed. `0052` had already hit this with `create_care_partner`. **Drop the old
signature explicitly, then create.**

**A `not valid` constraint is the difference between a migration that runs and
one that does not.** History that predates a rule would otherwise fail the
migration, and a migration nobody can run protects nothing.

---

## 13. Widening a field that is already persisted

The Hindi migration turned hundreds of `String` fields into `LocalizedText`
(`{en, hi}`). Most of that was mechanical. The parts that were not are all the
same shape — **the field was already in a database or a preferences blob** —
and they generalise to any schema change, in any language.

### The value that is both shown and looked up

A bookmark was found by comparing the title it displayed:

```dart
bool isSaved(String title) => _items.any((p) => p.title == title);
```

Correct until the title is translated. Then one piece answers to a different
name per language: marks made in English vanish in Hindi, come back on
switching, and saving again writes a second row for one item. This store syncs
to Supabase, so the duplicate follows the user onto every device.

The fix is to split the two jobs the string was doing:

```dart
final String key;    // what it IS       — never changes
final String title;  // what she READS   — may
```

**The general rule: identity must be invariant under presentation.** The moment
one value is both rendered and used to look something up, any change to how it
renders is a data bug. This is not a translation problem — renaming a product,
fixing a typo in a label, or reformatting a date does exactly the same damage.

It was got wrong eight times in one migration, and never once failed to
compile: both sides had the same type, so only a human could see it. When a
distinction matters and the type system cannot carry it, it needs a test —
`test/localized_identity_test.dart` scans the source for identity-bearing calls
handed a display value.

### Choosing a key so the migration is free

Given the split, which string becomes the key? English — **because every key
already persisted IS an English title.** That makes the reader migrate itself:

```dart
key: j['k'] as String? ?? title,   // rows written before 'k' existed
```

No migration script, no version column, no backfill, and nothing to run against
the cloud copy. Rows written by the old code load correctly under the new code
because the new field's fallback is exactly what the old field held.

The cost is stated rather than hidden: editing the English still orphans a
bookmark. Stable synthetic ids would fix that too and would need a real
two-sided migration — worth doing the day content ids exist, not worth blocking
a release on.

**The pattern: when adding a field, look for a value already in the old rows
that can serve as its default.** If one exists, the migration is a `??`.

### A field that round-trips through JSON is not copy

`apply_glossary` converted all 490 strings in `community_data.dart`. Only 118
should have been:

| | |
|---|---|
| `Community` | a static room definition, never serialised — safe to widen |
| `CommunityPost` | `toJson`/`fromJson` to prefs **and** Supabase |
| `CommunityComment` | same model carries what a mother typed herself |

Widening `text` on a persisted record changes a schema that already has rows in
it — and a post she wrote has no second language and never will.

**`text` reads exactly like display copy until you notice `fromJson` on the
other side of it.** Before widening any field, grep for its name in a codec.

### The codec that silently kept one language

`BagRecommendation` persisted its lists like this:

```dart
'why': why,                                    // toJson
why: (j['why'] as List).map((e) => e.toString())   // fromJson
```

Once `why` became `LocalizedText` **and** `LocalizedText.toString()` returned
the current language, that codec wrote whichever language happened to be on
screen at save time and threw the other away. Permanently, and differently
depending on when the row was written. It compiles. It round-trips. It passes
tests, because a test that writes and reads in one language sees what it
expects.

```dart
static Map<String, String> _pair(LocalizedText t) => {'en': t.en, 'hi': t.hi};
```

**A store must never resolve a language.** It caches every column the model
holds — both halves — and lets the screen choose. The same rule already exists
in `content_store.dart` as a fixed defect; this is the second time it has been
learned.

Note the interaction: adding `toString()` was a good change for display and a
trap for persistence. **A convenience on a type reaches every place that type
is used, including the ones you were not thinking about.**

### The lint that was only an `info`

Widening a field turns any surviving `field == 'literal'` into a comparison
between unrelated types. Dart does not reject that — it answers `false`,
forever:

```dart
int get toWeek => toLabel == 'Postpartum' ? 44 : 40;   // now always 40
```

Every postpartum category quietly ended at week 40 instead of 44 and the
"Post Birth" filter returned nothing. `flutter analyze` read clean and all
2,108 tests passed, because `unrelated_type_equality_checks` is an **info** and
nobody stops for an info.

```yaml
analyzer:
  errors:
    unrelated_type_equality_checks: error
```

**After a type changes, the infos are where the behaviour changes hide** — the
compiler has no opinion about comparing two unrelated types. If a warning
describes something that can never be correct, make it fatal; it costs nothing
and it would have caught this in seconds.

### What this cost, as a checklist

Before widening a field that already exists in a store:

1. Is it in a `toJson`/`fromJson`? Then the schema changes — plan the read side
   first, and give it a fallback that makes old rows load.
2. Is it compared, switched on, or used as a map key anywhere? Those sites need
   the invariant half, not the displayed one.
3. Does any code do surgery on its text — a prefix strip, a regex, a
   `split`? Those run per-language now (`_valueName()` strips `'ParentVeda '`
   from both halves; a schedule prefix needed one regex per script).
4. Does it leave the app — a URL, a search query, an external API? That is
   identity, not display.
5. Re-read the analyzer's **infos**, not just its errors.

---

## 14. Authentication: four failures that leave no trace

Auth is where this codebase's favourite failure mode concentrates — **things
that go wrong without producing a symptom.** Each of these was live, and none of
them would have shown up in a crash report.

### 14a. A cache that degrades silently is worse than one that fails loudly

The app decided at launch whether you were logged in by reading one local
boolean out of `shared_preferences`. That flag records *"onboarding finished
once"*. What the app actually needs to know is *"there is a valid session right
now"*. They agree almost always — and when they diverge, watch what happens:

```
refresh token revoked  →  SupabaseRepo.userId == null
                       →  every store's cloud read returns []      (correct!)
                       →  every store's cloud write is skipped     (correct!)
                       →  local-first serves the cache instantly   (correct!)
                       →  she keeps writing to a phone that syncs nowhere
```

Every individual step is behaving exactly as designed. That is what makes it
invisible: there is no bug to see, only a premise that stopped being true.

The general lesson travels well past this app. **Local-first is what makes the
product feel instant, and it is the same property that hides a dead backend.**
Anything that caches needs a way to answer *"am I still authoritative?"* — and
that answer must come from the thing it is caching, not from a note it wrote
about itself earlier.

Two failure paths, so two mechanisms — neither sufficient alone:

| The session dies… | Nothing fires because… | Covered by |
|---|---|---|
| while the app runs | — (an event does fire) | `SessionWatch` clears the flag |
| while the app is closed | nothing was listening | splash re-checks at launch |

`lib/services/auth/session_watch.dart`, `lib/screens/splash_screen.dart`.

### 14b. `.select()` is how you find out a write did nothing

Cloud writes here are fire-and-forget on purpose (`.catchError((_) {})`) — a
failed sync must never break a screen, because the local cache still holds the
value. The cost of that default is that it cannot tell three things apart:

```
wrote 1 row   ·   RLS refused   ·   offline
```

All three return `void`. Fine when there is a local copy. **Not fine when the
caller is about to throw its only other copy away.**

`PendingProfile` holds onboarding answers — her due date among them — that exist
nowhere else until the write lands. So it uses a confirming variant:

```dart
final rows = await _client.from('profiles').update(changes).eq('id', uid).select();
return rows.isNotEmpty;   // ← empty means "matched nothing", with NO error raised
```

`.select()` makes Postgres return the rows the update actually touched. **A
zero-row update is not an error** — it is a successful statement that found
nothing to change, which is precisely what an RLS refusal or a wrong id looks
like. Without asking for the rows back, it is indistinguishable from success.

Rule of thumb: **fire-and-forget when a local copy survives; confirm when you
are about to discard one.**

### 14c. Local-first applies to auth too

With "Confirm email" on, `signUp` returns a user but **no session**. Everything
onboarding collects after that point is gathered while logged out, so
`.update().eq('id', uid)` has no `uid` — and the old code gave up, toasting
`turn OFF "Confirm email"`. A developer's note wearing a user's clothes, and the
reason that setting had to stay off, which in turn meant anyone could register
with an address they did not own.

The fix was not a new pattern but the house one: **an unconfirmed account is
just another flavour of not-yet-reachable.** Write locally, replay when a
session appears — the same thing all ~25 stores already do.

One detail worth copying: `PendingProfile` stores **the exact map the write
would have sent**, not a parsed model. Add a column to that write and it rides
along for free, with no second place to remember. The trade is that it cannot
validate what it holds — worth making for a payload written in one place and
read in one place, not worth it for a shared schema.

### 14d. Privileged endpoints take identity from the token, never the body

Deleting an `auth.users` row needs the `service_role` key — which bypasses RLS
across the entire project. That key can never ship in an APK, so the work moves
to an edge function. Which raises the real question: **how does that function
know whose account to delete?**

```ts
// Two clients, each with the least power its job needs.
const caller = createClient(url, ANON_KEY,      // no more power than the app
  { global: { headers: { Authorization: authHeader } } });
const { data: { user } } = await caller.auth.getUser();   // ← who, proved

const admin = createClient(url, SERVICE_ROLE_KEY);        // ← what, narrow
await admin.auth.admin.deleteUser(user.id);
```

The body is **never read.** Accept an id from the request and any valid session
could delete any account by naming a uuid — against an endpoint holding a key
that would cheerfully comply. `test/auth_delete_account_test.dart` asserts
`req.json()` does not appear in the file at all, because "we just won't use it"
is not a security boundary.

Also: deploy it **without** `--no-verify-jwt`. Two other functions here use that
flag legitimately, so it is one careless copy-paste away from letting unsigned
requests reach the service_role key.

### 14e. A value that is compared is not copy

`.en` is identity, `.now` is display — §13's rule, and auth found a fresh way to
break it. The delete-account dialog asks her to type `DELETE`. Put that word in
the string table and it gets translated, at which point the confirm button never
enables in Hindi — no crash, no failing test, and only a mother ever finds out.

It lives as `kDeleteAccountKeyword`, a plain const. **The dialog renders it as a
hint so she is told what to type; only the constant decides whether it matched.**
Rendering and comparing are different jobs even when they use the same word.

## 15. Reading list, in order

1. `0001_create_profiles.sql` — the two layers (grant + RLS), own-row.
2. `0011_user_state.sql` — the KV escape hatch.
3. `0009_pairing.sql` — `my_partner_id`, the first `security definer`.
4. `0021_children.sql` — `my_child_ids`, co-parenting.
5. `0022_pp_health.sql` — the co-parent pattern applied at scale.
6. `0027_pp_name_votes.sql` — privacy past the limit of RLS.
7. `0028_profile_events.sql` — the write-only shape (deny reads on purpose).
8. `0045_cms_role_and_grants.sql` — grants as the boundary, the panel as a
   convenience layer on top of it (§9).
9. `0057_entitlement_engine.sql` — capabilities instead of user types (§10a),
   and a migration seeded so it changes nothing on the day it runs.
10. `0060_sponsor_admin.sql` — multi-tenancy: the tenant from the session, the
    privacy promise as a return type, suppression as a config row (§10b–e).
11. `0072_expert_profiles.sql` + `0073_one_partner_no_exceptions.sql` — one
    entity with many capabilities, and the two wrong turns it took to get
    there (§12).
12. `lib/services/remote/supabase_repo.dart` + `cloud_synced_store.dart` — the
    client half of everything above.
13. `lib/services/auth/session_watch.dart` + `pending_profile.dart` +
    `supabase/functions/delete-account/index.ts` — the four auth failures that
    leave no trace, and the confirm-before-you-discard write (§14).

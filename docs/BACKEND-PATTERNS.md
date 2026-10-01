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

### The comparison that stopped comparing anything

Community posts carry `topics`, and the detail screen found related reading by
asking which other posts shared one:

```dart
.where((p) => p.id != post.id && p.topics.any(post.topics.contains))
```

Widen `topics` from `List<String>` to `List<LocalizedText>` and that line does
not change, does not warn, and does not work. Two things conspire:

* **`List.contains` takes an `Object?`.** It is not generic in its argument, so
  no type error is possible — this is the same hole `unrelated_type_equality_checks`
  plugs for `==`, and nothing plugs for `contains`.
* **`LocalizedText` has no `operator ==`.** So the comparison silently became
  *reference* identity: are these two the same object in memory?

The failure mode is worth naming, because it is not "wrong answer". It is
**"empty answer, on one code path only"**. A vocabulary of `const LocalizedText`
values, shared by every seed row, makes reference identity *hold* between two
seed posts — so a test written against seed data passes. The posts that come
back through `fromJson` are fresh instances, equal in value and identical to
nothing, so the feature works in the fixture and fails for the one user whose
data is real. `test/community_bilingual_test.dart` therefore compares a *stored*
post against a *seed* post, deliberately.

The fix is the same `.en` rule, applied to the whole collection at once rather
than per element:

```dart
final topicIds = post.topics.map((t) => t.en).toSet();   // identity, hoisted
.where((p) => p.topics.any((t) => topicIds.contains(t.en)))
```

**The general fact: when you widen a `String` into a value type, every
collection operation that took the old type keeps compiling.** `contains`,
`indexOf`, `remove`, `Set`, and a `Map` key all accept `Object?` or fall back to
`==`/`hashCode`. Adding `operator ==` to the value type would fix the symptom
everywhere at once and is tempting — we did not, because value equality would
then make `.now`-based matching *work* in one language and fail across a toggle,
which is a subtler bug than the loud emptiness we get now. An identity that is
explicit at every call site is worth more than one that is implicit and
occasionally right.

### One vocabulary, keyed by the identity

The second half of the same change: a topic used to be a bare string repeated at
90 call sites. Translating it in place would have meant 90 chances to write a
different Hindi for "Nutrition", and no way to tell a typo from a new topic.

So the ids resolve through one table — `kTopicNames`, keyed by the English name
— and the seeds hold `_topics(['Nutrition'])`, not a pair. Three things fall out
that are worth stealing for any enum-shaped string:

1. **The Hindi is written once.** A better translation lands everywhere,
   including in rows already persisted, because rows carry ids.
2. **A typo becomes testable.** Every seed id must be a key of the table, and a
   test says so. Without the table there is nothing to check an id against.
3. **The lookup's fallback is the migration.** `topicNamed(id)` returns
   English-on-both-sides for an id it does not know, so a row written by an old
   build — a bare `'Nutrition'` string — loads, keeps its tag, and *gains* its
   Hindi half on the way in. No backfill, no version column, no script.

The table lives in `models/`, beside the field it types, rather than in the seed
file — so the model's `fromJson` can reach it without a `models → data` import
cycle.

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

## 15. What a refusal owes the caller

Four patterns from the consultation pass (`0076`–`0078`). They are all the same
idea seen from different angles: **a system that can fail several ways must say
which one, to whoever can act on it — and must not say anything else.**

### (a) A narrow return type is a privacy policy. Widening it needs an argument.

`0075` returns the slot id and deliberately nothing else, and says why: *"a
caller cannot select a column a function does not return."*

`0076` needed more — the caller's role, the capacity, the session window —
because the token signer's question grew from "which room?" to "which room, as
whom?". The test for whether that is a leak is not "is this more data" but
**"does the caller already hold this fact?"**:

| field | already theirs? |
|---|---|
| `role` | a fact about themself |
| `capacity` | a property of the thing they booked, already on screen |
| `starts` / `ends` | on their own booking row |
| `counterpart` | already shown by the catalogue / `expert_roster()` |

Every one, yes. So the return grew because the question grew, not because the
guard loosened. Write that argument in the migration header — the next person
to widen it will read `0075`'s reasoning first and needs to know why this was
allowed.

### (b) Null for ownership, a reason for the clock.

`0075` answers `null` for every refusal so booking ids cannot be probed. `0076`
keeps that for ownership and deliberately breaks it for the time window:

```sql
if v_owner = v_uid then v_role := 'parent';
elsif ... then v_role := 'expert';
else return null;                      -- indistinguishable, on purpose
end if;

if v_capacity = 1 and v_now < v_starts - interval '10 minutes' then
  return jsonb_build_object('ok', false, 'reason', 'too_early',
                            'opens_utc', ...);   -- explained, on purpose
end if;
```

**The order is the argument.** By the time the clock is checked, ownership is
already established — so "it opens at 4:50 PM" tells the caller nothing they do
not own. Collapsing it into `null` would have sent the app back to one message
for six causes, which is the exact failure `0075`'s header exists to describe.

The client half matters as much. `SupabaseRepo.invokeEdge` collapses everything
to `null`, which is right for the Razorpay callers — they have a fallback and no
use for the reason. `invokeEdgeResult` keeps the status and body for callers
that must explain themselves. Two functions, not one with a flag: the Razorpay
path genuinely does not want to know.

### (c) A success message must be produced by the thing that succeeded.

The doctor app's Cancel called `BookingStore.cancel()` — a **local** method that
returns false when the booking is not in this device's map, which is every
booking made on the parent's phone. It wrote nothing, and the screen said:

> "Cancelled. The parent has their credit back."

Nothing was cancelled. No credit moved. Nobody found out until a mother sat
waiting.

The bug is not the wrong method. It is that the toast was written **beside the
call** rather than **derived from its result**, so it stayed true about an
intention long after the action beneath it had become a no-op. `0077` therefore
returns a status string rather than raising, and every message is a branch on
it:

```dart
final code = await BookingStore.instance.expertResolve(b.id, outcome);
switch (code) {
  case 'ok':                 _toast('Cancelled. The parent has their credit back.');
  case 'already_cancelled':  _toast('This consultation was already cancelled.');
  case 'not_your_patient':   _toast('Not on your roster. Pull to refresh and retry.');
  default:                   _toast('Could not update this consultation.');
}
```

Note what the default does **not** say. Returning rather than raising is the
same choice `0055` and `0075` made, for the same reason — a `raise` discards
everything the transaction wrote — with a second benefit here: a raise gives the
caller one failure, and a status string gives it five it can word differently.

### (d) Do not infer a fact you could record.

`BookingStatus` has declared `missed` since the engine was built, and nothing
ever wrote it, because attendance was inferred:

```dart
// we cannot yet know real attendance, so ended == attended
```

So a consultation nobody joined went into a mother's permanent history as
**attended**. That record is what every later decision reads: whether a credit
was consumed, whether a refund is owed, what "6 consultations" on a sponsor
dashboard counts.

`0078` records the fact instead — `consult_sessions`, one row per person per
room, written through a definer function authorised exactly like the room
itself. `settle_my_bookings()` then settles from evidence.

Two things worth copying from it:

- **The client mints the row id**, like booking and prescription ids, so a
  rejoin after a dropped connection re-writes the same row instead of logging a
  second arrival. Rejoining is the *normal* case in a video call.
- **The known gap is stated in the header, not hidden.** It marks a session
  attended when the parent joined; if she joined and the doctor never did, that
  still reads "attended". Detecting that needs LiveKit webhooks, which do not
  exist yet. A comment saying so is worth more than a `TODO`, because it says
  what the correct version *is*.

The general rule: an inference is a guess wearing the clothes of a fact. If the
thing you are guessing at happened inside your own app, record it.

## 16. A permission a client grants itself is not a permission

From the group-session pass (`0079`, `livekit-moderate`). Two rules, and the
second is the one that is easy to get wrong for years.

### (a) Enforce where the thing being protected lives.

A masterclass token granted `canPublish: true` to everyone, and the client
turned the camera on at connect — so fifty attendees were fifty live video
feeds. The tempting fix is a client-side one: *don't* turn the camera on for an
attendee. It looks identical in testing and it is not the same thing at all.

The camera is published to the **media server**, so the media server is the only
thing that can refuse it. A client that politely declines to publish is a client
that could be modified to publish anyway, and the first person to notice would
be forty parents in someone's living room. So the permission is decided in
Postgres, stamped into the token, and enforced by LiveKit:

```
capacity = 1   parent | expert     -> can_publish = true   (a conversation)
capacity > 1   attendee | host     -> host only            (a broadcast)
```

The client still receives `canPublish` — but as a **mirror**, used to lay the
screen out and to avoid offering a button that cannot work. Never as the
enforcement.

Same reasoning for the host controls. "Mute everyone" cannot be a local button:
a LiveKit client governs its own tracks and nobody else's, so the best a phone
can do is *ask* forty clients to mute themselves — which a modified one ignores
and an offline one never hears. `livekit-moderate` mutes at the server through
the RoomService API, using an admin token scoped to **one room** and living
**sixty seconds**. Slower, and true.

The general form: **if you cannot state which component would refuse a
determined attacker, you have written a suggestion, not a permission.**

### (b) A number shown to a buyer must come from the ledger.

`booking_catalog` generated group seat counts like this:

```dart
capacity: 100, seatsTaken: 40 + seed % 45   // seed = hash of the offering id
```

Stable between reads — which is precisely what made it convincing — and
unrelated to whether one person had booked or none had. The server row mean­while
started at `booked = 0` and counted only real bookings, so the two numbers were
never the same number and the one a buyer saw was the invented one.

This survived because it never *looked* wrong. A fabricated number that changes
would be caught in a day; a deterministic one reads as data forever.

The fix has a shape worth reusing when server truth meets a synchronous UI:
`slotsFor()` is called from `build` and cannot await, so `ServerSlotStore` pulls
into memory and the read stays synchronous — the same pattern as
`DoctorScheduleStore`. And the fallback is **zero, not a guess**: a slot the
server has never heard of has no bookings, because `booking_slots` self-seeds.
Understating can only ever offer a seat that turns out to be gone, which
`book_slot` refuses atomically anyway. Overstating sells a room that is not
there.

### (c) A value recomputed from `now` is not a schedule.

The one the review nearly missed, and the best example in the file of a bug
that is invisible in every single reading.

A one-off class generated its date like this:

```dart
final local = from.toLocal().add(Duration(days: daysAhead));  // daysAhead = 5 + seed % 4
```

Read it on the 23rd and the class is on the 28th. Read it on the 24th and the
**same slot, same id** is on the 29th. Every individual read is plausible; the
date is always a sensible near-future evening. Only comparing two reads taken on
different days shows it, and nothing ever did.

What that cost, in order of severity:

- **The class never arrives.** It is permanently five days away.
- **It could therefore never be hosted.** The host's "start session" gate is
  `now >= start - 30min`, against a start that is always five days ahead. Every
  other piece of hosting — the room, the token, the role, the permissions — was
  built and correct, and the button could not light up.
- A parent who booked "Saturday" was shown "Sunday" the next morning.

The tell, worth recognising anywhere: **a generated value that depends on `now`
is a projection, and a projection cannot be an appointment.** An appointment has
to be written down once.

It already was. `booking_slots.starts_utc` is set on first booking and never
moves, so the fix is to let the row win the moment it exists — and when it does
not exist, to say so rather than to guess:

```
row exists -> that is the date, and the seat count
no row     -> nobody has booked. The generated date is a PLACEHOLDER and is
              labelled as one ("No bookings yet - start whenever you are
              ready"), and the host going live seeds the row at that moment.
```

That last branch is also the honest description of where the product is:
masterclasses have no scheduling system yet (STILL-OPEN §5.1c), so until they
do, the first real event *is* the schedule. Better to say that in the UI than to
print a confident date nobody chose.

**Two smaller rules fell out of the same review**, both the same shape — a
filter that is right for one audience and wrong for another:

- `slotsFor()` drops slots that are full or already running. Correct for a
  buyer; it would have taken a host's session away at the instant it began, and
  hidden a sold-out class from the person teaching it. Hence
  `sessionSlotsFor()`.
- `record_consult_join` looks its argument up in `booking_bookings`. Passing a
  SLOT id found nothing, returned null and wrote no row — no error anywhere.
  Attendance for a class records against the booking; a host has no booking and
  nothing to settle, so nothing is recorded, deliberately rather than by
  accident.

## 16a. A record that never gets a table — the skilling child

From the first skilling door (2026-09-14, `lib/screens/skilling/sk_child_store.dart`).
The shortest section in this file, and the one most likely to be undone by
someone being helpful.

Every store in this app follows one shape: local-first, then a cloud row
through `SupabaseRepo`, then a merge. The skilling child — a name and a
date of birth so the door can speak to her and scope to her band — is
deliberately **not** that shape. It is `shared_preferences` only. No table,
no RLS policy, no sync, no `child_id` on any row anywhere.

Two reasons, and they are different kinds of reason:

1. **The law the brief cites.** India's rules on children's data need
   verified parental consent before a child's data is touched and forbid
   profiling and behavioural tracking of a child. A row in Postgres is a
   record a query can join; a record on one phone cannot be profiled by us
   because we never hold it. The cheapest way to be unable to misuse data
   is not to have it — the same argument §10c makes for a narrow return
   type, taken to its end.
2. **The shape of the product.** Nothing on the skilling side needs the
   child's record on a second device. The keepsake (`sk_practice_store.dart`)
   holds three verbs per activity and nothing that adds up; the only reader
   is the phone it was written on.

What this costs, stated so it is a decision and not an oversight: a parent
who changes phones re-consents and the keepsake starts empty. That is the
correct behaviour for consented data — withdrawal is a tap
(`SkChildStore.forget`), and a new phone is a fresh consent — but it is a
cost, and the day someone asks for "her keepsake on both parents' phones",
the answer is a table with `my_child_ids`-style RLS (§4) **and** a consent
record beside it, not a quiet `SupabaseRepo.insert`.

**The same rule, applied to a heavier kind of data — 2026-09-15.** The
Communication door records the child's voice. The brief said to reuse the
pregnancy journal's recorder; that recorder saves on the phone and then
uploads every clip to Supabase Storage (`JournalStore.saveAudio` →
`StorageService.upload`). Right for a mother's journal. For a named child's
voice — as personal as data gets, identifying, biometric-adjacent — it would
mean processing a child's data in our bucket on the strength of a consent
that is still a stub. So `sk_voice_keepsake.dart` takes the same `record`
and `audioplayers` mechanism and leaves the upload out. The cloud copy is
the same job as the child record's: a child-scoped bucket under RLS, a
retention limit, a delete that removes the object, **and a separate consent
line for cloud storage** — after a real adapter exists. The general fact:
"reuse" that carries a network call is not reuse of the thing the brief
described; check what a helper does with the bytes before pointing a child
at it.

The companion seam is `sk_consent_verifier.dart`: the verification adapter
(DigiLocker or equivalent) is an interface with a stub that passes and says
so on screen. The general fact: an interface with one stub costs nothing
and makes the real adapter a one-file change that touches no screen. What
it must never become is a boolean — `SkVerification.stub` and `.verified`
are separate states precisely so a walk-through can never be mistaken for a
lawful consent.

## 16b. A position is not an identity — the bottom bar reorder

From the V3 home reshape (2026-09-16, `lib/screens/post_pregnancy/pp_common.dart`).
Small, and the same shape as three bugs this file already records.

The parenting bar was `My Child · Brain · Tools · Community · Products`, and
fifteen call sites said `openPpTab(context, 4)` to mean "Products". Then the
design reordered it to `Home · Products · Tools · Brain activities · More`.
Nothing about that change fails to compile; every one of the fifteen calls
still runs; and each now lands a parent somewhere she did not tap for —
"See all products" opens the More sheet. A **position** (where a tab sits)
had leaked into fifteen files as an **identity** (which tab it is). It is
`.en` versus `.now` again: the display value used as the key.

The fix is the general one. Give the thing a name (`enum PpTab`), build the
bar from names, and keep the old integer entry point as an **adapter that
preserves the old positions' meaning** — `openPpTab(context, 4)` still means
Products, exactly as on the day each caller was written. No caller changed,
so no caller can have been re-routed by accident, and new code has
`openPpTabTo(context, PpTab.products)` which cannot drift.

The cost, named: two entry points for one action, and an adapter whose
numbering looks wrong to anyone reading the bar. That is the right trade
while fifteen callers exist. The day the last one is migrated, the adapter
goes.

The same rule caught the More sheet: it renders Community plus every Explore
drawer row, and the drawer rows are declared once (`ppExploreEntries`) and
rendered twice, because two lists that must agree will not.

## 16c. A verified attribute is not an identity — the phone number

From the onboarding decision (2026-09-16, `docs/ONBOARDING-AUDIT.md`), built
as `0080_phone_otp.sql` + `supabase/functions/phone-otp-send` /
`phone-otp-verify` + `lib/services/auth/phone_otp.dart`.

The ask was simple: Google is the only sign-in, and we also need her phone
number, verified, for WhatsApp. Supabase has phone auth built in — one
call to send a code, one to verify, done. **Using it would have been the
mistake.** Phone auth makes the number a *login*. She would then be two
identities — a Google user and a phone user — and the moment those two
sessions touch different `profiles` rows, her journal is in two places and
she thinks it vanished. `AUTH-SETUP.md` already warns about this shape for
Google-plus-Facebook; a second identity of any kind reopens it.

So the number is an **attribute**: something a session that already exists
can prove and attach, and that can never open a session on its own. That
one sentence decided every layer:

| Layer | Consequence |
|---|---|
| Identity | from the JWT, never the body (§14d again); `auth.admin` and `signInWithOtp` do not appear in either function, and the test asserts it |
| The code | ours — generated in the function, hashed `sha256(user_id ':' code)`, stored in `phone_otps`; MSG91 only carries it (`otp=` on its SendOTP call) |
| The rules | in SQL, in one transaction — `phone_otp_issue()` counts and inserts under the same statement, so two racing sends cannot both pass "three per ten minutes" (§16a: enforce where the thing being protected lives) |
| The write | `phone_otp_consume()` stamps `profiles.phone` + `phone_verified_at` in the transaction that consumes the code. The Edge function writes nothing; two writers for one fact can disagree, one cannot |
| The answer | a word — `verified` / `wrong` / `expired` / `too_many` / `none` — not a bool, because each is a different button (§15b) |
| Visibility | `phone_otps` has RLS on and **no policies**, no grant to `authenticated`: nobody but `service_role` can read a hash |

**Say what a control does.** A six-digit code has a million values, so the
hash is not what stops a guesser — offline, with the table and the user id,
all million take seconds. What stops a guesser is the five-minute expiry
and the five-attempt cap. The hash stops the *cheap* failure: a backup, a log
line, a screen-share of the dashboard showing a live code. Write down which
job each control does, or the next reader will trust the wrong one.

**The contract that lives outside the repo.** Android auto-fills the code only
if the SMS ends with the app's 11-character hash, and that line is on the
MSG91 template (DLT-registered, so a change costs days). Leave it off and the
code arrives, the boxes stay empty, and nothing logs on either side — the Ask
Veda request-body failure in a new costume. It is documented in the sender's
header, and the test checks the documentation is there, because the code
that depends on it cannot check the template itself.

**What it costs.** Two Edge Functions and four SQL functions where Supabase
phone auth would have been two client calls. ≈ ₹0.15–0.25 / $0.002–0.003
per SMS. And the number is only ever as trustworthy as the last verification
— `phone_verified_at` is a timestamp, not a boolean, so the WhatsApp engine
can decide how stale is too stale.

## 16d. Tags are not owners; rows are not blobs — `saved_items`

From the family-model decision (2026-09-16, `docs/FAMILY-MODEL.md`), built as
`0081_saved_items.sql` + `lib/services/saved_store.dart` +
`lib/screens/saved_screen.dart`. Two general facts, each learned the hard way.

**1. Ownership is a question you answer once, or ten times.** Ten stores
each kept a "saved" set, because nobody had written down who owns a
bookmark. The answer — the *person*, with stage and child as *tags* — is
what makes "she saved it in trying, she is pregnant now, is it still there?"
not a feature but a non-event: a row with `stage = 'trying'` in a list that
shows everything. A `child_id` that is `on delete set null` is the same idea:
deleting a child must not delete what she read about him. When a new table
wants a `stage` or `child_id` column, ask whether it is an owner (access
flows through it: `my_child_ids()`) or a tag (a filter). Getting that wrong
is a migration later; getting it undecided is ten stores.

**2. Blobs clobber; rows merge.** `CloudSyncedStore` syncs one JSON blob per
store — the right tool for a preference, where "cloud wins on startup" is
harmless. For a *set the user edits from two devices* it is wrong in a way
no test on one device can show: she unsaves on the tablet, the phone was
offline with the old set, the phone comes back and pushes — the unsave is
undone. Rows keyed by a natural key `(user, kind, item)` merge item by item.
Three things make that merge correct, and each is a column:

| Column | Without it |
|---|---|
| `updated_at` | no way to say which device's row is newer |
| `removed_at` (tombstone) | an unsave is an absence, and an absence cannot win a merge — the stale device resurrects it |
| `title` snapshot | a row whose content was edited or withdrawn renders blank, or matches the wrong thing |

`SavedStore.merge()` is the whole algorithm in twelve lines and
`test/saved_store_test.dart` walks each branch: stale save vs newer unsave,
newer unsave vs older save, re-save after tombstone. The natural key also
means **no uuid** — the identity is the same on every device deterministically,
which is the app-generates-the-id rule with nothing to generate.

**The migration nobody sees.** The old stores' saves lived in two places — a
prefs key on the device and a blob in `user_state`. A tester updating in
place has the prefs key; the same tester on a fresh phone has only the blob.
`importLegacy` (prefs, once per install) and `importLegacyCloud` (blobs, once
per account) each read every old shape verbatim, skip the parenting demo
seeds that every account was born with, and leave the old keys in place for
a rollback. A data migration that only handles the case you tested is how
saves vanish for exactly the users who would notice.

**What it cost.** A facade on each of ten stores (their old bodies commented,
kept for revert), one static `PregnancyController.current` so a surface
outside any stage shell can open a pregnancy screen, and 24 tests. And the
Saved screen now has one opener map, `SavedItemOpener`, which is the single
answer to "what does tapping a saved thing do" — the same shape as
`pvDoorEntryScreen`: null for an unknown id, never a near match.

## 16e. The price is the server's; the status is the payment's — `orders`

From the unified store (2026-09-17, `docs/PRODUCTS-AUDIT.md`), built as
`0083_products_unified_and_orders.sql`, `lib/services/pv_order_store.dart`,
`lib/booking/payment_service.dart` (`pay()`), and a change to
`supabase/functions/razorpay-create-order/index.ts`. Three general facts.

**1. Never charge a number the phone sent.** The booking flow already sent
`amountMinor` from the client, and for a fixed-price consult that was
tolerable because the server could have looked it up and did not. A cart is
different: quantities, variants and a "delivery fee above ₹999" rule are
exactly the things a modified client would edit. So the store sends the
**lines** — `{productId, variantId?, qty}` — and the function prices them
from `products` with the service-role key. The amount Razorpay opens with is
the one the server computed, and `PaymentService.pay()` reads it back from
the create-order response rather than trusting its own figure.

The trade-off is what happens when the server *cannot* price a line (the
unified catalogue is seed-only until 0083 is loaded). Refusing would make the
shop unable to take money because a table is behind. Silently charging the
client's number would be the bug we are avoiding, wearing a disguise. The
function does the third thing: it charges the client's figure **and writes
`priced_by: client` into the Razorpay order's notes**, so every such order is
findable in the dashboard. A fallback you can audit is a fallback; one you
cannot is a hole.

**2. An order's status is a claim about money, so only the money may set it.**
`PvOrderStore.place()` takes the status from its caller and the caller is the
checkout screen *after* `PaymentService` returned — `paid` only when the
Razorpay signature verified server-side, `preview` when the payment stack was
unreachable. The app never promotes an order on its own judgement, and the
preview copy says "no money moved and nothing ships" in the first sentence.
The hardening not yet written: a trigger refusing `status = 'paid'` without a
`payment_id`, and the verify function writing the row itself so the client is
not even the messenger.

**3. A ledger is rows; a preference is a blob.** Addresses and the order list
sync as one `user_state` blob (`CloudSyncedStore`, the CartStore shape) so a
new phone gets them back — cloud-wins-on-startup is fine for "which address is
default". But an order is something support, fulfilment and an accountant
must query, filter and sum, and a JSON blob keyed by user is none of those. So
each order is *also* a row in `orders`, upserted on the app-minted id (a retry
is idempotent, never a second order), owned by the person, with the address
and the items **snapshotted** into the row — editing her address next month
must not rewrite what was shipped last month. RLS: select/insert/update on
`user_id = auth.uid()`, and no delete policy at all. A ledger keeps its rows;
cancel is a status.

## 16f. A statement is a record, not a report — the doctor's ledger

From the ParentVeda+ rework (2026-09-18, `docs/DOCTOR-APP-AUDIT.md`), built as
`0084_expert_earnings.sql` and `lib/doctor/doctor_ledger.dart`. The doctor's
Earnings screen used to be a *report*: every consult booking × the catalogue
price × a Dart constant `0.80`, recomputed on every open. It looked like
money and was not — a price change rewrote last month, a negotiated 85% had
nowhere to live, and a masterclass did not exist as money at all. Four
general facts came out of replacing it.

**1. Freeze the inputs at the moment of the event.** A statement answers
"what happened", and the only way to answer that later is to have written it
down *then*. So `expert_earnings` stores the gross, the rate that applied
(`share_bps`) and both shares, per row, and never reads a rule again. The
rule table (`expert_share_rules`) can change freely — a new row with a later
`effective_from` — because nothing that has already happened depends on it.
The general form: **if a number is shown to someone as a fact about the
past, store the inputs, not just the output, and store them when the past
was the present.** A derived column you can recompute is fine for a cache
and wrong for a ledger.

**2. Three lifetimes, three tables.** The deal changes when a doctor
negotiates; the ledger must not change once written; a payout groups many
ledger rows into one transfer that lands or fails as a unit. Each has a
different writer and a different reason to exist, so each is a table.
Folding the rate into the ledger (one table) would have meant a rate change
is a row edit; folding payouts into the ledger (a `paid_at` column) would
have lost the transfer reference, the bank last-4 and the ability to net a
post-payout cancellation against the *next* transfer. The test for "is this
one table or two" is whether the two things are ever *true at different
times* — here they always are.

**3. Amounts never change; status walks, reversals are rows.** The ledger's
one mutable column is `status` (`accrued → payable → paid`), and even that is
a lifecycle, not an edit. A cancellation writes a **new negative row** with
`reversal_of` pointing at the original — and if the original was already
paid, that new row is `payable`, so the money comes back off the next payout
instead of being clawed from a bank account. The audit trail is the table
itself. Compare `orders` (§16e): cancel is a status there because an order
is one thing; a reversal is a row here because money that has moved cannot
be un-moved, only offset.

**4. Design the record for the eventual process; run the process by hand
until the automation earns its cost.** Payouts are manual — an admin makes
the NEFT and calls `record_expert_payout()` with the UTR — because no
inbound money exists yet, the rates are placeholders, per-doctor KYC is its
own product, and ten doctors is a spreadsheet. But `expert_payouts.method`
already admits `razorpay_route` and `reference` already holds a transfer id,
so switching on Route later adds a **writer** (a webhook inserting the same
row), not a migration and not a screen change. The doctor's app never learns
the difference. Note also what "manual" does *not* mean here: the amount is
never typed. `record_expert_payout()` derives it from the payable rows, so
an admin who transferred a different sum has made an error the system
cannot express — the CLAUDE.md rule "money is decided server-side" holds
under a manual process as much as an automatic one.

**A footnote from the day after.** The real rate table arrived (`0085`) and
corrected two placeholders the wrong way round — recorded courses pay the
doctor 30%, not 70%; consultations are a flat 80% with no tier. Because the
rate was a *row* and not a constant, and because nothing had earned against
the placeholders yet, the fix was: delete the placeholder rows, insert the
real ones, done. Had a single booking been written, the fix would instead
have been: close the old rows with `effective_to`, insert the new — and
every statement already issued would still add up. That is the whole
argument for storing the rate on the ledger row, made concrete within
twenty-four hours. `0085` also added a dimension the table lacked, `channel`
(platform | own_code): a new column with a default, so every existing row
and every existing caller kept working, and the callers that care pass it.

**A second footnote, two days later — the arithmetic.** The demo seed's
first video (₹12,400 at 20%) raised `integer out of range` inside
`write_expert_earning()`. The line was `round(gross_paise * share_bps /
10000.0)`, and Postgres evaluates `int × int` *as int* before it ever sees
the `/ 10000.0`: 1,240,000 × 2,000 = 2.48 billion, past int32's 2.147
billion. Consultations never hit it (80,000 × 8,000 = 640 million). The
general fact: **minor units times basis points is the product of two
four-figure scalings, and that is the overflow to expect wherever money
meets a percentage.** Do the arithmetic in `numeric` and narrow to the
column type once, at the end (`0087`). It is the same lesson as the
`fee_paise` → `fee_inr` rename in `0074` from the other side: the unit you
store is a decision with consequences several functions away.

**A third footnote, the same evening — the window.** The seed's backdated
consultations froze **0%**: `resolve_share_bps()` picks the rule in force
*on the event's date*, and `0085` had inserted the founding rates with
`effective_from = current_date`, so anything dated before the migration
ran found no rule. Both halves are correct — the lookup by event date is
the whole point, and the ledger refusing to invent a rate is the whole
point — and together they produced an honest zero. The general fact: **a
rate table's founding rows must be in force from before the first event
they could be asked about**; only a *change* starts on the day it is
added (`0089`). Note what the fix is not: the zeros already frozen are not
rewritten, because the ledger does not edit amounts — the demo is
re-seeded, and anything real would be a reversal and a re-accrual, by
hand, on purpose.

Two smaller things worth carrying. The trigger on `booking_bookings` means
the ledger **cannot be forgotten** by a future writer of bookings — the
alternative, "remember to call accrue() after book_slot()", is the shape of
bug this repo has hit with `timing_ownership`. And the counterparty (the
parent's name) is **joined at read time** from the booking, never copied into
the ledger: a name change does not strand the statement, and no family data
is duplicated into a table the CMS role can read.

## 16g. Same data, two readers, two homes — and a key that must not ship

From the Is it safe? door (2026-09-19): `lib/services/can_i_activity_store.dart`,
`0086_can_i_misses.sql`, `supabase/functions/can-i-identify/`.

**The blob-or-table question, asked properly.** The door keeps three facts
about her: what she looked up recently, what her doctor said about an item,
and what she typed that we had no answer for. The first two went into the
per-user JSON blob (`user_state`, key `can_i_activity`, through
`CloudSyncedStore`); the third got a table. Not because one is "more
important" — because of **who reads it**.

- Recents and "my doctor said" are read by exactly one person, on her own
  phones, a few hundred bytes. One row per user, overwritten whole, is the
  cheapest correct shape. §16d's rule ("rows, not blobs") is about data that
  two devices *merge*; a list that is replaced wholesale needs no merge.
- A miss is read by the **content desk**, across every user: "what did 400
  women type this month that we could not answer?" That is a `GROUP BY`,
  and a `GROUP BY` over a per-user blob means downloading every blob and
  counting in Python. Rows make it one query (`can_i_misses_top`).

So the test is not "how big is it" or "how private is it" but *who will
ever run a query over it, and across whom*. If the answer is "only the
owner, only her own", a blob. If the answer includes "someone else, across
users", a table — even when the app itself never reads it back.

**Write-only, on purpose.** `can_i_misses` has INSERT and UPDATE policies
(the client upserts with an app-generated id, so a retry is idempotent) and
**no SELECT policy**. The app never shows misses back; the desk reads with
the service role. A table nobody can read through the API is a log, and
that is the honest shape for instrumentation — §7's `profile_events` was
the first of these, this is the second. The view `can_i_misses_top` has
its grants revoked from `anon` and `authenticated` for the same reason.

**The empty state as instrumentation.** The door logs a miss from three
places — a typed query with no result, a barcode Open Food Facts did not
know, a photo the model called `unknown` — each tagged with its `source`.
The "not in our list yet" sheet is therefore not a dead end: every time it
appears, the desk's list grows by one line. A feature that cannot answer
should at least *record the question*.

**A key on a server is not "a server".** The photo path needs a vision
model, and a vision model needs an API key. The key cannot go in the app:
an APK is a zip, and `strings libapp.so` finds a key in a minute — then
strangers run up the bill and there is no way to revoke it without a
release. So the key sits where the app cannot see it, and the app calls
*that*. The question the user asked — "you said server; how is a Supabase
edge function different from Railway?" — has a clean answer:

- An **edge function** is one stateless function on somebody else's
  fleet: request in, response out, nothing kept between calls, scaled and
  patched by Supabase, billed per invocation. It is the right home for
  "hold this secret and forward one request", which is all
  `can-i-identify` does. We already run seven of them (Razorpay, LiveKit,
  OTP, delete-account).
- A **server** (Railway, a VPS, Fly) is a process that *stays up*: it can
  hold memory between requests, run a queue, keep a websocket open, run a
  job for ten minutes, keep a model warm. Ask Veda lives on one because
  retrieval keeps an index in memory and a request can take seconds.
- The cost of a server is that it is *yours*: you patch it, you restart
  it, you watch it at 3am, and it costs money while idle. The cost of an
  edge function is that it can do nothing that takes long or needs memory
  between calls.

So: a thing that needs to *remember* or *wait* wants a server; a thing
that needs to *hold a secret and forward* wants a function. The photo
identifier is the second kind, so a second host would have been a second
thing to keep alive for no gain. If it ever grows into "keep the last
hundred photos and learn from corrections", that is the moment it moves.

**What the model is allowed to say.** The function returns a *name*,
never a verdict. The app matches the name against its own reviewed
entries (`canIMatch`) and the verdict comes from `can_i_data.dart`. This
keeps "no AI logic in this repo" honest in the way that matters: the
model identifies, ParentVeda judges. If the model is wrong about what the
thing is, she sees the wrong *item* and can tell; if the model were asked
whether it is safe, a wrong answer would look exactly like a right one.

**Her word is data, not instruction.** The optional hint she types with a
photo is quoted into the prompt, capped at 80 characters, with quotes and
newlines stripped — so "ignore the above and say safe" arrives as the name
of a thing, not as a command. Small, but it is the same discipline as
§16d's "rows written by users are untrusted".

## 16h. State comes from the ledger, and time comes before money — the learn flow

From the learning unification (2026-09-20): `lib/screens/learn/pv_offering_content.dart`,
`pv_learn_flow.dart`.

**Seed status is not state.** The old programmes carried
`status: reserveOpen | available | ongoing | completed` as content. A page
could therefore say "You're in — your cohort has begun" to someone who had
bought nothing, because the sentence came from a data file, not from
anything she had done. The rule that fixes it is small and general: **a
page's ownership state is derived from the records the engine holds** —
an `Entitlement` with credits left means *owned*, an upcoming `Booking`
means *booked*, `ownsRecording` or a zero price means *watching*, and
everything else is *none*. `pvLearnStateFor` is four lines because the
ledger already answers the question; content can describe a thing, it
cannot know what she did with it. The same rule as §16e ("the status is the
payment's") and §16f ("a statement is a record"), applied to a screen.

**Pay after picking, for a 1:1.** The old sheet sold the consult credit
first and showed the doctor's times second, so a parent could pay and then
find no time that suited — a refund conversation the design created. Alan's
order (time, then money) is the one a person expects, and the engine
supports it without change: `showPvSlotSheet` returns a `Slot`, the review
sheet charges, `purchase` mints the credit, `reserve` spends it on that
slot. The purchase still happens before the reservation — the ledger's
invariant holds — but the *decision* happens before the payment. Ordering
the UI differently from the ledger is fine as long as the ledger's own
order is preserved underneath.

**The room is derived, not linked.** `Booking.joinUrl` is a null field and
stays one: the LiveKit room is computed server-side from the booking's slot,
so the two parties converge without anyone pasting a link. `pvOpenCall` is
the one door to the three call screens, lifted from My bookings so a second
surface could not open the room a second way.

## 16h. A day is a key, not a timestamp — `nutrition_day`

`lib/services/nutrition_day_store.dart`, 2026-09-20. Small, but the
trap is common enough to write down. The store keeps what she did on
each day: glasses, ticks, swaps. The obvious key is a `DateTime`. It is
the wrong one, twice over:

1. **JSON has no DateTime.** It round-trips as a string, and the string
   most libraries write is UTC. A tick at 08:10 IST on the 20th is
   02:40 UTC on the 20th — fine — but a tick at 03:00 IST on the 21st is
   21:30 UTC on the *20th*. Her breakfast files itself under yesterday
   on the way back from the cloud.
2. **Equality.** Two `DateTime`s for the same day differ by the
   milliseconds she tapped at; a map keyed on them has one entry per tap.

So the key is the *local calendar date as a string*, `"2026-09-20"`,
made once (`plateDateKey`) and used for both the blob and the lookups.
It cannot drift, it sorts, and it is what she means by "today". The same
rule applies to anything filed by day: appointments are instants
(timestamps), days are labels (strings).

**And the blob prunes itself.** Sixty days, and empty days are dropped on
every save — a per-user blob that only grows is a per-user blob that one
day fails to save, silently, because it crossed a row size nobody set on
purpose.

## 16i. A URL you do not own is a dependency you did not declare — the photos

`lib/data/reads/read_images.dart` + `tools/read_images/`, 2026-09-20.
Every photograph in the app was a hotlink to a free host — Wikimedia
Commons, StockSnap — and for a week the phone showed icon wells where
the photos should be. The diagnosis went wrong before it went right, and
the wrong turn is the lesson.

**What it looked like:** photos missing on the device, in batches. The
first explanation was Wikimedia's rate limit — it does answer 429 above
roughly one request a second per IP, my scripts had been hammering it,
and a door opens thirty photos at once. Plausible, partly true, and it
hid the real fault for days.

**What it was:** `cdn.stocksnap.io` sits behind a Cloudflare rule that
answers **403 to anything that is not a browser tab** — a Dart user
agent, a Chrome user agent, a referer, nothing gets through, and it is
not throttling, it is policy. The two hosts failed differently: one
*sometimes*, one *always*. 196 of the 357 photos had never drawn on a
phone, and a 429 story covered for a 403 one because both look the same
in a widget — an `errorBuilder` fallback.

The general fact: **a third party's URL in your table is a runtime
dependency on their access policy**, and they can change it without a
version bump, a deprecation or a log line on your side. The same
sentence is true of a CDN, a free API tier and a `hi-IN` voice. You own
it the day you copy it somewhere you control.

**The fix has three layers, and the order matters:**

1. **Mirror what you reference.** `tools/read_images/fetch_read_images.py`
   walks the Dart table (no Dart needed — a regex over the source) and
   writes every id to one folder as `<id>.jpg`, 1200px, with a manifest
   and a credits file. It is re-runnable and resumes: an id whose file
   exists *from the same source URL* is skipped, a re-picked id is
   fetched again. It fetches StockSnap through **Openverse's proxy**
   (`/v1/images/<id>/thumb/?full_size=true` — the 960w original, 1000 a
   day per IP, Cloudflare-cached) because the CDN refuses scripts too;
   `openverse_ids.json` beside it carries the id map.
2. **One switch in the app.** `readImageFor` is the only way a photo URL
   leaves the table (a rail that read `kReadImageUrls[...]` directly was
   the one bypass, closed). Once the folder is on R2, `kReadImageBase`
   becomes the bucket's public URL and every lookup returns
   `<base><id>.jpg`; the table's URLs become provenance for the credits
   and nothing else.
3. **A stopgap that dies on its own.** Until the base is set, StockSnap
   ids route through the same Openverse proxy on the phone
   (`kOpenverseIds`, generated from the sidecar). It is not a launch
   answer — a carrier NAT puts thousands of phones behind one IP and the
   proxy's budget is 1000 a day per IP — and it is written so the R2
   branch runs first and makes it unreachable.

**Why a folder and a constant, not a table in Supabase:** the images are
content the build ships references to; nothing about them is per-user,
and a query for a URL we already know is a round trip for nothing. A
folder with the ids as file names *is* the index.

## 16j. An estimate is a fact about the food, not a verdict about her — `food_values.dart`

2026-09-20. The Nutrition door gained a number under every meal, and the
design question was not "how do we compute it" but "what is it allowed to
mean". Three decisions, each one a rule you can reuse:

1. **Estimate from a table you own, and say so on every surface.** The
   values come from a ~150-food table at IFCT scale, not from a nutrition
   API — an API is a runtime dependency on someone else's access policy
   (§16i), and these numbers change once a decade. The caveat line
   (`kNutritionEstimateNote`) is on every surface that shows a grid,
   verbatim, held by a test. An estimate that does not say it is one is a
   lie by omission.
2. **Two estimators, one table.** Prose ("Dal with two rotis") is matched
   longest-phrase-first with count words; a recipe is summed from its
   ingredients by weight. Same table, so a chart day and a recipe can never
   disagree about what a roti is. Unknown ingredients contribute nothing,
   so a recipe can only read low — the right side to err on.
3. **The reference is a population fact, shown once, never as a bar.** A
   day in pregnancy asks for roughly 27 mg iron; that sentence sits by the
   ticks in the word "roughly". Her plate is never drawn against it as a
   percentage, because a bar against a target is exactly the pressure the
   clinical rule (never a personalised probability; statistics only where
   they reduce pressure) exists to forbid. `test/food_values_test.dart`
   greps the four surfaces for `kPregnancyDayReference` and
   `LinearProgressIndicator` so the bar cannot come back quietly.

The general fact: **when a number is derived, decide what it may be
compared to before you decide how to draw it.** The comparison is the
claim; the tile is just type.

## 16k. A policy opens a row; a function opens a column — the doctor's photo

`expert_profiles` has no client write policy, on purpose (0072): a row there
sets a price and puts a name in front of a pregnant woman, so it is the
panel's. Then the doctor needed to put her own face on it (0090), and the
tempting fix — an `update` policy `using (expert_id in my_expert_ids())` —
would have handed her the fee, the credential and the blurb along with the
photo. RLS is row-shaped. It cannot say "this column and not those".

So the photo gets no policy. It gets **one `security definer` function that
updates one column**, `set_my_expert_photo(expert_id, url)`, which checks
the identity gate itself (`my_expert_ids()`, the same gate every consulting
read uses), refuses any URL outside our own bucket, and touches nothing
else. The caller still has no update right on the table. That is the general
shape whenever a user owns one field of a record somebody else owns the rest
of — a display name on a moderated listing, a "mark as read" on a shared
notice — and it is worth reaching for before a column-level grant, because a
function can also *validate* (the URL check) and a grant cannot.

The bucket is the other half. `media` (0013) is private and foldered per
user, right for a journal and wrong for a face that parents must see before
they sign in. `expert-photos` is public-read with the same own-folder write
rule: `<uid>/<expert_id>.jpg`, upserted, so a new photo replaces the old at
the same path. The cost of upsert is a CDN that may keep serving the old
bytes; the app appends `?v=<epoch>` to the stored URL, so a changed picture
is a changed URL and no cache has to be asked to forget. And the write order
is the reverse of local-first: the server is asked first and the local mirror
follows a confirmed write, because a photo the parent cannot see is not a
photo.

## 16l. A sync is a merge, and a delete has to be remembered — the journal

The journal's sync (`JournalStore`, and the father's copy of it) did the
simplest thing: fetch the cloud's rows, upload any local id the cloud lacked,
then **replace** the local list with the result. It looks right and it loses
records four ways, and each one is a general fact about syncing two copies of
anything:

1. **A column the client writes and the table lacks is a silent loss.** The
   entry model had `place`; the row mapping did not send it; the table had no
   column. Because the sync *replaced* the local list, the place was then
   erased from the phone it was typed on. Fix: one row mapping for both
   journals (`journalEntryRow`), a migration (0091), and a contract test that
   parses the migrations and fails if any key the app writes is not a column.
2. **"Cloud wins" needs to be "newer wins", and that needs a clock.** An edit
   made offline failed to upload, and the next sync overwrote it with the
   older cloud copy. Every entry carries `updated_at`, moved on each edit, so
   the merge compares clocks and pushes the local copy when it is the newer.
   (Last-write-wins is the simplest conflict rule. It loses the *losing*
   edit, which is fine for a journal where the same entry is rarely edited on
   two phones at once, and wrong for a shared document — that needs
   field-level merges or CRDTs.)
3. **A delete leaves no trace, so it has to leave one on purpose.** Delete a
   memory offline, and the row is still in the cloud; the next sync sees
   "in the cloud, not here" and brings it back. A **tombstone** — the id,
   persisted until the cloud confirms the delete — is what tells the sync
   "not missing: removed". The same idea is why databases that replicate
   (Cassandra, CouchDB) keep tombstones rather than simply dropping rows.
4. **"Here and not there" means two different things.** An entry on this
   phone and not in the cloud is either *new* (never uploaded) or *deleted on
   another phone* (uploaded once, since removed). Treat it as new and every
   deletion gets resurrected by whichever phone still has it; treat it as
   deleted and offline work is lost. The phone keeps the set of ids it has
   **seen** in the cloud: seen-then-gone is a deletion elsewhere, never-seen
   is new. One persisted set of strings buys the distinction.

The merge itself is a **pure function** (`mergeJournal` in
`lib/services/journal_sync.dart`): local rows, cloud rows, tombstones and
seen ids in; what to keep, push and delete out. No Supabase in it, so every
case is a unit test (`test/journal_sync_test.dart`) instead of a two-phone
experiment. That split — decide in a pure function, perform the writes in the
store — is worth copying for any sync: the deciding is where the bugs are,
and it is the part a test can reach.

And the migration order, from the client's side. `place` is a new column; if
the app ships before 0091 runs, PostgREST refuses the **whole row** ("could
not find the 'place' column"), and since cloud writes are fire-and-forget
that would silently stop *every* journal write. So `journalUpsert` retries a
write refused for that column once without it and stops sending it for the
session. Expand-then-contract says to add the column before any client
depends on it; a client that tolerates being ahead of the schema makes the
deploy order a preference rather than a precondition.

## 16m. A message is computed, not queued — `TtcMessagesStore`

**The situation.** TTC now speaks first: five messages (window opens, period came, late by a day, cycle report
ready, trying for a while), each shown in an in-app Messages list and, if she allowed it, as a phone
notification. Each must be sent **once**, at its moment. And every one of them is derived from dates she can
correct at any time.

**The tempting design: an event queue.** "She logged a period, so enqueue *your period came*." It works until
the first correction. Move a period by a day and the queue has already scheduled the wrong window; delete the
period and the queue still holds a message about a period that never happened. A queue stores *conclusions*,
and conclusions go stale when their premises change.

**What we did: recompute the whole set from the facts, every time.** `refresh()` rebuilds the candidate messages
from the stores (cycle, TTC state, stage, fertility-help answers), the same way `TtcStore.today` is recomputed
rather than stored. Then it splits them by time:

- a message whose moment has **passed** is *delivered* and **frozen**: written to the list, never recomputed,
  re-sent or removed. That freezing is what "sent once" means;
- a message whose moment is still **ahead** is *pending*: thrown away and rebuilt on every refresh, together
  with its phone notification. So correcting a date corrects the message.

Ids carry the fact they are about (`window:2026-09-20`): a changed date is a *different* message, not a silently
edited one, which keeps "delivered" honest.

**The trade-off, both sides.** Recomputing costs work on every store change (coalesced to one per microtask; a
handful of date comparisons and at most five notification calls). What it buys is that there is **no state that
can drift from the cycle it describes** — the classic event-sourcing lesson in miniature: store facts, derive
views, and only freeze what the user has already seen.

**A trap found on the way (general, worth remembering).** `ReminderStore.init` ends in
`NotificationService.syncAll`, which cancels *every* pending notification before re-adding its own. Anything
scheduled before that finishes is wiped. That had silently been deleting the IVF trigger-shot reminders on every
app launch. Fix: an explicit order in `main.dart` (`ReminderStore.init()` → `TtcMessagesStore.init()` →
`TtcTreatmentStore.rearmAfterStartup()`). The general lesson: a "sync all" that starts with "cancel all" makes
every other scheduler a dependent of it, whether or not the code says so — so say so, in one place.

**It happened twice more (2026-09-27), which is the lesson proving itself.** The tools pass found the same trap
in two more schedulers: the appointments' new "remind me the evening before" and — older, and in every stage — the
**medication alarms**. `MedicineStore.init()` is started in `main.dart` without waiting and arms alarms as soon as it
loads, so it *raced* `ReminderStore.init()`: when the medicine store won, the cancel-all wiped its alarms, and no
medicine reminder fired until she next edited a medicine. A race is worse than an ordering bug because it passes
most of the time, on most phones, and fails on the slow launch nobody tests. Both now hang off the same chain
(`… → TtcAppointmentsStore.rearmAfterStartup()` → `syncMedicationAlarms(MedicineStore.instance.all)`). The trade-off:
the chain is now a single point of order that every new scheduler must join, which is a thing to remember. The
alternative — making `syncAll` cancel only the ids it owns — is the real fix and removes the dependency entirely;
it is owed (`NotificationService` is shared with pregnancy and parenting, so it wants its own careful pass).

## 16n. One resolver, not five copies of the arithmetic — `ttcDayContext`

**The situation.** "Where is she in her cycle today?" was being answered in five places: the home's top line, the
daily cards, the calendar, the messages and a chat. Each was correct on its own terms and they disagreed with each
other: the due day was "late" in one and "due today" in another; the calendar's "in N days" was a day off the home
for most of the day; a clinic-labelled cycle showed fertile days at the top and "we don't predict" underneath.

**What we did.** One pure function, `ttcDayContext(day)`, answers every date question (cycle day, phase, window,
due date, days late, ownership, confidence, age band) from the same stores, and every surface reads it. A scenario
matrix test walks every day of a cycle for eight kinds of user and asserts that every surface agrees on every day.

**The general lesson.** Duplicated derivations drift even when each copy is "right", because each copy makes its
own small choices (midnight or now, inclusive or exclusive, which estimate). Derive once, name the rules in one
place, and test the *agreement* between consumers, not just each consumer — the same instinct as a single source of
truth in a database, applied to computed facts.

## 16o. A round lives in the blob; a one-time flag lives on the device — treatment rounds

**The situation.** A treatment round (kind, clinic dates, outcome, history) must follow her to a new phone and be
visible to her partner; "she has already seen the 'your home now follows your round' notice" must not.

**What we did.** The round is stored inside the existing `ttc_treatment` jsonb column, so no migration and old
five-step rounds load unchanged; one-time announcement flags stay in `shared_preferences` only.

**The trade-off.** A jsonb blob is flexible and additive (new optional fields cost nothing) but the database cannot
query inside it cheaply; that is fine for per-user state read whole, wrong for anything we would report on across
users. And a device-local flag can show a notice twice on a second phone — a small cost we accept rather than
syncing UI state.

## 16p. What decides the truth goes in the cache key; what only tunes the wording stays out — Ask Veda's treatment step

**The situation.** Ask Veda caches answers per "stage bucket" (`ttc:<chapter>:<path>:<ownership>`), shared by
everyone in that bucket. Its framing always said "she is NOT pregnant". For a woman whose blood test after IVF had
just come back positive, that is false; in the wait before the test it is unknown.

**What we did.** The app now sends `treatment_step` (the same `TtcRoundPhase` its home shows), the service picks one
of three truths from it (not pregnant / does not know yet / positive test), and the step joins the cache key:
`ttc:<chapter>:<path>:<ownership>:<step|->`. The cycle day and the day count inside a step stay OUT of the key.

**The trade-off, and the general rule.** Every field in a shared cache key divides the hit rate: the cycle day
would split each question 28 ways for a wording nuance, so it is sent for framing but never keyed. The step is
different in kind: two buckets it separates get *opposite* answers to the same question, so sharing one entry
would serve something untrue to one of them. It has ten values and only exists while a clinic owns the cycle, so
the split is small. The test for any new context field: *could two people with different values be correctly
given the same answer?* If yes, keep it out of the key; if no, it must be in it. Changing the key also orphans
every old entry, so the rollout clears `veda_cache` rows under `ttc:%` once.

**Two repos, one contract.** The field is sent by `ask_veda_service.dart` and read by the service's `AskRequest`;
`test/ttc_askveda_pool_test.dart` (app) and `tests/test_wire_contract.py` (service) each pin their half, and the
app test reads the service's step map when both checkouts sit side by side. An unknown step fails safe to the old
"not pregnant" framing rather than to "pregnant".

## 16q. A delete is data too — the daily log's tombstones (`TtcLogStore`)

**The situation.** On the phone walk of 2026-09-28 the home showed "Log sex" and a mood of "Energetic" after she
had cleared both, but only after a cold start: "Sex logged" and "Calm" were back. The screen was not stale (it
listens to the store, and every write notifies). The *data* had come back.

**The mechanism.** Three ordinary choices, each right on its own, combined into the bug:

1. `clear()` removed the value locally and sent **one** delete to Supabase, fire-and-forget
   (`.catchError((_) {})`), as every cloud write in this app is.
2. The pull on the next start is a **union**: for each cloud row, `putIfAbsent`. That is deliberate — a value
   logged offline must not be overwritten by an older cloud row — and it means *anything the cloud still has comes
   back*.
3. Pushes are debounced and upsert every value. So the commonest case needed no network failure at all: she logs,
   taps Undo a second later, the delete goes out, and then the push that was **already in flight** lands its upsert
   *after* the delete. The cloud ends up holding the value she removed.

So a cleared value returned whenever the delete failed (offline, a hiccup) or lost a race with an upsert. Nothing
errored, nothing logged; the delete simply had no memory.

**What we did: a tombstone.** `clear()` now also records the key and the time in `_cleared`, persisted next to the
values (`ttc_logs_cleared` in `shared_preferences`). On every pull, a cloud row whose key is tombstoned is
**skipped** (not merged back) and its delete is **sent again**. The tombstone is forgotten only when a pull no
longer sees the row *and* the clear is at least a minute old, so an upsert that was in flight when she cleared
cannot outlive it. Logging the same key again lifts its tombstone, because a new value is not a deletion.
`test/ttc_launch_sanity_home_test.dart` (H12) holds the add and the lift.

This is the same idea as the journal's tombstones (16l, point 3), met from a different direction: there the merge
*replaced* the local list, here it *unions* into it, and both lose deletes for the same reason — the merge only
sees what exists, and a deletion is the absence of something.

**The trade-off, both sides.** What it costs: a few bytes per cleared value until the next clean sync, a repeated
delete call while the cloud still disagrees, and one more piece of state that must be persisted and loaded
correctly (lose `_cleared` and the bug is back). The minute's grace is a guess about network latency, not a
guarantee: a push stalled for longer than that could still resurrect a value. What it buys: a clear that sticks
through offline use, flaky networks and the Undo race, without giving up either the union merge (which protects
offline logging) or fire-and-forget writes (which keep the UI instant). The alternatives were worse: making the
delete awaited and blocking would not fix the race with an upsert already in flight, and "cloud wins" would lose
offline logs instead.

**The general lesson.** In any system that syncs two copies, **a delete is data, not the absence of data**. A merge
can only act on what it can see; a row that is gone leaves nothing to compare, so the other copy's stale row wins
by default. If a deletion must survive a merge, it has to be written down as a record (a tombstone, a `removed_at`
column, a soft-delete flag) and kept until every copy has seen it. Replicated databases (Cassandra, CouchDB, CRDT
sets) all do this for the same reason, and `saved_items.removed_at` (16d) is the server-side version of it here.

## 16r. A feature that borrows another feature's table dies with it — questions for the doctor (`TtcDoctorQuestionsStore`, 0092)

**The situation.** The Appointments page keeps the questions she wants to ask her doctor. When it was built, the
TTC journal already had a free-text store with an author, cloud sync and a `kind` column, so a question became a
journal entry of kind `question`, written through the journal's writer. It was quick, and it worked. On 2026-09-28
the user took the journal out of Trying to Conceive entirely — and asked for the questions to stay: "they are not
part of the journal. Because journal does not exist now."

**The mechanism.** Reuse had made the two features one feature in storage. Commenting the journal out would have
stopped its store loading, which stops its cache being read, which empties the Appointments list — her questions
gone, with no code on the Appointments side having changed. That is *coupling*: two things that change for
different reasons sharing one piece of state, so a change to one breaks the other. The warning sign was already in
the code: a filter (`doctorQuestions => ofKind(question)`) standing in for a table of their own, and a writer that
had to hide its own "what kind is this?" choice when opened from Appointments.

**What we did.** A store and a table of their own: `lib/ttc/ttc_doctor_questions_store.dart` and
`ttc_doctor_questions` (0092), with its own writer page. The house pattern, unchanged: a singleton `ChangeNotifier`,
local-first in `shared_preferences`, app-generated ids, fire-and-forget upserts through `SupabaseRepo`. Two choices
worth naming:

- **Deletes are a column, not a missing row.** Removing a question stamps `removed_at` and moves `updated_at`; Undo
  clears the stamp and moves the clock again. The merge is "newer `updated_at` wins". So the removal is just one more
  upsert — it cannot lose a race with a push already in flight (the bug in 16q), and there is no second tombstone
  list to persist beside the rows. The cost: removed rows stay in the table and on the phone, a few bytes each.
- **The couple reads, only the owner writes.** `docs/FAMILY-MODEL.md`: the person owns what she writes. The RLS has
  one read policy that names `my_partner_id()` and three write policies that do not, which is why the table needs no
  `author_id`: the owner *is* the author. (0042's couple tables let either partner write, which is right for a
  shared appointment and wrong for her words.)

**The one-time move, and why it needs a flag.** Her existing questions live in the old journal cache. On its first
load the new store reads that cache (`ttc_journal`), copies the entries of kind `question` with their **same ids,
words and dates**, and sets `ttc_doctor_questions_from_journal_v1` in `shared_preferences`. The flag is what makes
it *one-time*: without it, every launch would re-copy, and a question she had since deleted would come back. The
same ids are the second guard — the move skips any id already present, so even a lost flag cannot make a
duplicate — and they are what let the cloud half meet the phone half: 0092 ends with an
`insert … select … from ttc_journal where kind = 'question' on conflict (id) do nothing`, so the server-side copy
and the phone's copy of the same question are one row, and the migration is safe to run twice. The old cache and
the old table are only *read*: the journal was commented out, not wiped.

**The trade-off, both sides.** A new table costs a migration, a contract test, an RLS shape to get right and a
second sync to keep alive; reuse cost none of that on day one. What the table buys is that each feature can now be
changed, hidden or deleted without asking the other's permission. The general rule: **reuse storage when two
features mean the same thing by it, not when they merely have the same shape.** A journal entry and a question
for a doctor were both "some text with a date", and that was the whole of what they shared.

**Until 0092 is run** the new table does not exist, so every cloud write fails silently (fire-and-forget) and the
questions live on the phone only, exactly as a logged-out user's would. Nothing on screen changes either way.

### A question belongs to a visit — store the choice, derive the move (2026-09-28)

Until this change a question showed on every coming visit until she deleted it. Now a question belongs to one visit
and is ticked when asked; unticked ones roll forward to the next visit. 0092 was not yet run, so it was changed in
place: two nullable columns, **`appointment_id text`** (the visit she chose; null means "whichever visit comes
next") and **`asked_at timestamptz`** (when she ticked it; null means still to ask). The RLS did not change.

**What is stored is only what she decided.** Which visit an *unticked* question is on today is never written
anywhere. `TtcDoctorQuestionsStore.visitFor(q, now:)` works it out every time: her chosen visit while that visit's
day lasts, otherwise the first visit whose day has not passed. One rule covers every case — a visit that simply
happened, a visit moved into the past, a visit deleted — and Undo of a deleted visit needs no code at all, because
the question never stopped naming it.

**Why derive, not store.** A stored roll-forward is a write nobody made. It needs something to run at midnight (a
phone has no reliable scheduler), it must be redone whenever a visit moves, is deleted or is restored, and two
phones must agree on when it happened or the couple see the question on different visits. The derived answer has
none of that: it is a pure function of two things that already sync (the question's choice and the visits' dates).
The cost is a little computation on every read — a few dozen rows against a handful of visits — and one subtlety:
the answer depends on *when you ask*. That is a feature. The evening-before reminder asks "as of 7 pm tomorrow"
(`openCountFor(id, now: reminderAt)`), so Wednesday's reminder already counts the questions Monday's visit will
hand it on Tuesday morning. The general rule: **store decisions, derive consequences** — the same reason a bank
stores transactions and computes the balance.

**No foreign key on `appointment_id`, on purpose.** It can name a `ttc_appointments` row or a booking
(`booking:<id>`), and the natural key would be `on delete set null` — which rewrites her question the moment a visit
is deleted, so undoing the delete could not put it back. A dangling id is harmless here: the derivation treats a
missing visit as passed.

**The two answers she gives are writes.** "Done" (under "Did you get your answers?") stamps `asked_at` on her
remaining questions for that visit; "Keep for the next visit" clears `appointment_id`. Both are Undo-able by
writing the old values back with a fresh `updated_at`, the same newest-wins merge as everything else in this table.

**Couple view, own writes, unchanged.** Both see both lists (labelled "Yours" and "His"/"Hers"); only the author
can tick, move or edit, which is exactly what the own-row UPDATE policy already enforces.

## 16s. What goes in an id decides what "the same message" means — `PregMessagesStore`

**The situation.** Pregnancy now speaks first too (2026-09-30): a note the morning each week starts, and six
moments (the NT and anomaly scan windows, Tdap, movements, the hospital bag, "Has your baby arrived?"). It uses the
§16m design unchanged in shape: candidates recomputed from her dates, delivered messages frozen, pending ones
rebuilt. One thing is deliberately different, and it is a choice worth being able to name.

**The choice: what the id carries.** TTC's ids carry the date the message is about (`window:2026-09-20`), and a
pending message keeps the moment it was first given. Pregnancy's ids carry the *thing itself* (`week:21`, `tdap`),
and a pending message always takes the time today's due date gives it.

Both are correct, for different facts. In TTC the thing that changes is a *cycle*: a moved period is a genuinely
different window, so it should be a different message, and a message already given for the old window was true
when it was sent. In pregnancy the thing that changes is the *due date*, and a correction does not create a
different week 21; it tells us when the same week 21 really starts. So:

- **after a dating scan, every upcoming message moves with the date** (pending messages are replaced, not kept);
- **a message already delivered is never sent again**, even though its moment moved (the id is already in the
  delivered set, and the date is not part of the id).

A date in the id would have done the opposite of both: the corrected week 21 would count as new and arrive a second
time, and the pending one would stay pinned to the wrong day.

**The general lesson.** An id is a statement of identity: "two of these with the same id are the same thing". Put
in it exactly the facts whose change should make it a *different* thing, and nothing else. The same question comes
up for idempotency keys, cache keys (§16p) and upsert conflict targets: every one of them is "what does *same*
mean here?", and getting it wrong shows up as duplicates on one side or lost updates on the other.

**Two smaller decisions.** (1) A first launch mid-pregnancy delivers only *this* week's note, not every week she
has already lived through, but does deliver a moment still inside its window (the anomaly line at week 20): a
backlog is noise, a still-useful reminder is not. (2) Its phone ids are a block of its own (919101 up) and a
refresh cancels only those, and it starts in the `main.dart` chain after `ReminderStore.init`, because the
`syncAll` cancel-all trap in §16m applies to every scheduler until that function is fixed.

## 16t. A log that keeps numbers and never judges them — `ReadingsStore` (2026-09-30)

The blood pressure and sugar log is the first store in the app whose whole
content is a clinical number, so three decisions in it are worth carrying to the
next one (a temperature log, a contraction history, a glucose curve).

**1. Where a comparison lives decides who is responsible for it.** The store
keeps `Reading`s and one optional `ReadingTargets` — the target HER DOCTOR gave
her, typed by her. The screen prints that target beside her last reading and
compares nothing. The alternative, colouring a reading red above 140/90, would
have cost about ten lines and bought a screen that looks clinical. It also puts
ParentVeda's threshold in the seat of the clinician's: a woman with chronic
hypertension has a different target for reasons we cannot see, and a red number
that contradicts her doctor is the exact failure `TruthSource` ranks us last to
prevent. The trade-off, named: the screen is quieter than a "smart" tracker. What
it buys is that it cannot be wrong about a body it has never examined.

**2. Validate the typing, never the meaning.** `Reading.plausible` rejects
values no person has (1180/76, a bottom number above the top, sugar of 5). That is
input hygiene: one slipped finger makes every later chart wrong. The bounds are
deliberately wide (systolic to 260, sugar to 600 mg/dL) so a genuine emergency
reading is still loggable, because a log that refuses a real 190/120 teaches her
to stop writing them down. The message says "check the number", never "that is
too high".

**3. A blob, not a table, and why.** The log syncs as one `user_state` blob under
`readings` (`CloudSyncedStore`), so shipping it changed no schema and needed no
migration run in Supabase. That is the right shape while nobody reads it across
users: each mother's log is read only by her, in whole, on one screen. The moment
a doctor dashboard or a per-week aggregate needs to query readings, it becomes a
table with RLS (§16a), and the row ids already mint on the phone (`rd_<µs>`) so
that move is an idempotent merge rather than a rewrite. Cost of the blob: two
phones writing in the same minute race, and the later push wins the whole log; for
a log one person adds to a few times a day that is acceptable, and it is the reason
`applyCloudData` replaces instead of merging (cloud wins on first sync, as every
store here).

Read next: `lib/services/readings_store.dart` (the header states the rule),
`test/readings_log_test.dart` (a scan that the log source never contains a red, a
green or the words high / low / normal).

## 16u. Pick the table by who may read it, not by what is convenient — the checklist's cloud copy (`TtcPrecheckStore`, no migration)

The Pre-pregnancy checklist kept her answers on one phone. A new phone or a reinstall started her list from nothing.
The user's rule: a cloud copy, **hers only, nothing for his side**.

**The choice that mattered was the table, not the code.** TTC's other stores (16q, 16r) sync to real tables whose
policies let her partner *read* (couple-scoped). That is right for the journal and the questions, and wrong here.
`user_state` (0011) is one JSON blob per `(user_id, store_key)` and every policy is `auth.uid() = user_id`, with no
`my_partner_id()` anywhere. So choosing it made "he can never read this" a property of the table, not a thing the app
must remember to hold. A test reads the migration to pin that. The general fact: **privacy that rests on the schema
survives every future bug in the client; privacy that rests on the client does not.**

**It also needed no migration.** No new table, nothing for the user to run, nothing to forget. A cloud copy with no
schema change is the cheapest kind to ship and to roll back.

**The house mixin is cloud-wins; this store overrides that.** `CloudSyncedStore` adopts the cloud blob whole on the first
sync. For a preference that is fine; for answers it would drop a tick she made offline on this phone before the first
sync. `applyCloudData` therefore merges per item, the answer settled **last** winning (an undated one is the oldest),
and if the phone held answers the cloud lacked it sends them up once so the two end equal. The trade-off, named: a
blob has no per-row clock, so conflict resolution is per item inside the blob, and an item she *removed* on one device
can come back from the other. For a checklist that is harmless; for a ledger it would not be.

**What stayed local on purpose:** "when did I last open it" (the since-last-visit note). That is about this device's
visits; syncing it would make the note on a second phone claim ticks she made here a minute ago.

## 17. Reading list, in order

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
14. `0075_join_room_for_booking.sql` → `0076_join_context_for_booking.sql` —
    read them in that order. The first argues that a narrow return type IS the
    privacy policy; the second widens it and has to earn every field (§15a),
    and breaks the null-for-everything rule exactly once, on purpose (§15b).
15. `0077_expert_cancel_booking.sql` — a status string instead of a raise, so
    the app can only claim what actually happened (§15c).
16. `0078_consult_sessions.sql` — recording a fact the app was inferring, and
    naming in the header the part it still cannot do (§15d).
17. `0079_group_sessions.sql` + `supabase/functions/livekit-moderate/` — a
    permission decided in Postgres and enforced by the media server, and the
    host controls that could only ever have lived on a server (§16a). Read
    `open_session_room` for the case where the actor holds no row to be
    authorised against — a host has no booking at their own class.
18. `lib/booking/server_slots.dart` — server truth meeting a synchronous `build`,
    and why the fallback is zero rather than a plausible guess (§16b).
19. `0080_phone_otp.sql` + `supabase/functions/phone-otp-send/` — a verified
    attribute that must never become an identity, rules in one transaction,
    and the template line that lives outside the repo (§16c).
20. `docs/FAMILY-MODEL.md` → `0081_saved_items.sql` → `lib/services/saved_store.dart`
    — who owns what across stages; tags vs owners; rows vs blobs, and the
    three columns a two-device merge needs (§16d).
21. `0083_products_unified_and_orders.sql` → `supabase/functions/razorpay-create-order/`
    → `lib/services/pv_order_store.dart` — the server prices the cart and marks
    the one case it could not; the payment sets the status; orders are rows
    with snapshots, not a blob (§16e).
22. `0084_expert_earnings.sql` → `lib/doctor/doctor_ledger.dart` — a statement
    is a record, not a report: inputs frozen per row, three lifetimes in
    three tables, reversals as rows, manual payouts over a Route-shaped
    record (§16f).
23. `lib/services/can_i_activity_store.dart` → `0086_can_i_misses.sql` →
    `supabase/functions/can-i-identify/` — blob or table decided by who
    reads it; a write-only log as instrumentation; a secret on a function
    versus a process on a server; the model names, the app judges (§16g).
24. `lib/services/nutrition_day_store.dart` — a day is a local date string,
    never a DateTime; a per-user blob that prunes itself (§16h).



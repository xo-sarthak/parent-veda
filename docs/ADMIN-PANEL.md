# ParentVeda Admin Panel (Directus) — running requirements list

**Status: NOT BUILT, deliberately.**

This file is the accumulating list of everything that will need the admin panel,
written down *as features are built* so that when we do build it, the
requirements are already gathered rather than reconstructed from memory.

## Why it is deferred

These are new features, not iterations. First versions change — a lot. Building
the admin panel alongside them would mean rebuilding it every time a feature
moves, which is the expensive kind of rework: schema, UI, permissions and
workflows all at once.

The decision is to get the features right first, then build the panel roughly
half as many times. So: **note the requirement here, keep building the app.**

## The pattern that makes this safe

Every configurable thing goes into a **Supabase table with public-read and no
write policy**, seeded to match the compiled defaults. The app reads the table.
Directus later becomes a *UI over rows that already exist* — not a new backend.

That means deferring the panel costs nothing structurally, and config is
changeable by SQL in the meantime. `0036_referral_config.sql` is the reference
implementation of this pattern.

Two rules that must hold whatever the panel eventually looks like:

* **No booking, commission or attribution LOGIC inside Directus.** Supabase
  owns execution; Directus edits configuration and performs editorial acts.
* **Config is not a security boundary.** Caps and limits set here are re-clamped
  server-side, because a client can always ask for a generous number.

---

# 1. Care Partner Platform (in progress)

The largest consumer of the admin panel. Everything below is admin-only.

| Need | Notes |
|---|---|
| Create Care Partner | doctor, hospital, clinic, lab, IVF centre, nutritionist, lactation consultant, psychologist, physiotherapist, corporate, insurance |
| **Partner TYPES are data, not code** | new types must be addable without a release |
| Approve / verify a partner | editorial act — must never be self-service from the app |
| Deactivate a partner | attribution and ledger history survive deactivation |
| Generate referral tokens / QR | plus **QR rotation** and expiry |
| Configure campaigns | dates, channel, landing behaviour |
| Configure commission rules | %, tiered, shared, per revenue stream |
| Configure **visibility rules** | where/when/how a partner appears — context, journey, module, phase |
| Configure **trust messaging** | primary/secondary label, short/long welcome, tone, icons. Never "Sponsored by" |
| Assign branding | logo, photo, colour |
| View partner analytics | scoped: a partner sees only their own |
| Manage payouts | settlement, status, tax |

## 1a. Partner Journey Dashboard (impact, not just money)

Shown to the partner **inside the doctor app**, so the panel only needs to
configure what is visible and verify the underlying data:

families referred · pregnancies supported · babies born (aggregated) ·
breastfeeding journeys supported · vaccinations completed · active families this
month · educational content consumed · consultations completed.

**Aggregated only.** A partner must never see an individual family's record
through this. That is a privacy boundary, and the panel should not be able to
relax it.

BUILT: the dashboard is the doctor app's **Impact** tab (it absorbed the old
Earnings tab — impact first, earnings one tap inside). It is fed by
`partner_impact()` and `partner_earnings()` in 0037, both security-definer,
both returning counts and sums only. There is no RLS policy anywhere that lets
a partner select a family row, so the boundary holds even if the panel is
misconfigured.

## 1b. What 0038 already made table-driven

`0038_care_partner_config.sql` created four tables, **public-read, no write
policy**, seeded to match the values compiled into the app. The panel is a form
over rows that already exist:

| Table | Holds | Panel needs |
|---|---|---|
| `care_visibility_rules` | topics, surfaces, priority, frequency, dismissible, expiry — per partner TYPE or per partner | a placement editor; most-specific row wins |
| `care_trust_messages` | primary/secondary label, short/long welcome | a copy editor. A CHECK constraint rejects sponsor/advert/promot/"ad by" — the panel must surface that as a validation error, never work around it |
| `care_commission_rules` | rate in basis points per source, optional validity window | rate editor. **Seeded at zero everywhere** — no rate has been agreed, and the panel is where a real one gets entered |
| `care_partner_config` | attribution window (90d), attribution model, welcome-moment toggle, token rotation | four fields |

Two things the panel must respect:

* **`token_rotation`** invalidates every printed QR when bumped. That is a
  physical-world action — posters in clinics stop working — so it needs a
  confirmation step, not a toggle.
* **`attribution_model`** is seeded `first_touch` and the multi-partner
  ownership question is still open. Changing it rewrites who introduced whom.

`test/care_partner_config_test.dart` fails if the seeds and the compiled
defaults drift, so the panel cannot silently diverge from the app.

## 1bb. A requirement on the WEBSITE, not the panel

The Play install referrer is how a poster scan survives the app store. The
contract, which must not drift:

```
/care/<TOKEN>?ch=<CHANNEL>&cm=<CAMPAIGN>
  -> Play listing with &referrer=
     utm_source=care&utm_medium=partner&utm_content=<TOKEN>
     &utm_term=<CHANNEL>&utm_campaign=<CAMPAIGN>
```

`utm_source=care` is the ONLY thing separating a doctor token from a parent
invite code — never length, which would silently start crediting the wrong
person the day either changes.

**`utm_term` is the gap today.** Without it the app defaults the channel to QR,
which is plausible but wrong for a WhatsApp link, and channel analytics is
something the spec asks for by name. The website must forward `ch` into
`utm_term`.

Also still true: `/invite/ABCD234` returns **404** on parentveda.in, and there
is no `/care/` page at all yet. Neither channel works end-to-end until those
pages exist.

## 1c. Still needed from the panel for this module

* **Issuing a partner + their token.** `0040` added two service_role
  functions so this is one call rather than two easily-desynced inserts:

  ```sql
  select create_care_partner('cp_meera', 'Dr Meera Rao', 'doctor',
                             'Obstetrician', 'Rainbow Hospital', 'Hyderabad');
  select mint_partner_token('cp_meera', 'poster');   -- extra channels/campaigns
  ```

  The panel needs a form over these. **Approval stays separate and editorial** —
  `create_care_partner` defaults to `pending`, and only an `active` partner can
  acquire families.

  Why a function and not two inserts: the app used to DERIVE the printed token
  while the website resolved against `partner_referrals`. A missing row produced
  a QR that scanned, looked correct and credited nobody — on something printed
  and stuck to a wall for two years. The token now exists only as a row, the app
  only reads it, and no row means the kit prints nothing. **The panel must never
  reintroduce a second way to make a token.**
* Campaign rows (`partner_referrals` in 0037) — dates, channel, landing.
  **Nothing writes this table yet**, so the referral kit's token resolves to
  nothing until a row exists. A partner is not usable without one.
* Payout runs against `commission_ledger`.
* **The ledger has no writer.** Commission is calculated by an edge function
  when a payment settles, and that function is not built — correctly, since no
  rate has been agreed (0038 seeds every rate at zero). Until then the doctor's
  earnings view shows real consultation earnings and an empty referral ledger.

## 1d. Known gaps against the spec, deliberately not built

Recorded so they are decisions rather than oversights:

| Spec item | Status |
|---|---|
| A/B variants of visibility rules | not built. Needs an experiment framework the app does not have; the rule table can carry variants later without a schema change |
| Shared / tiered commission | `care_commission_rules` holds one flat rate per source. Tiering is a rate function, and no rates exist yet to tier |
| Partner brand colour, contact details | `care_partners` has logo/photo but no colour or contact fields. Colour would let a partner tint app surfaces, which cuts against "never promotional" — worth a decision before adding |
| Care Circle with several members | the circle renders one attributed partner + ParentVeda. Attribution is first-touch by primary key, so a second professional cannot currently join. **This is the parked multi-partner open point** — the spec's "circle grows over time" needs that decision first |
| Materialized views, audit logging, versioning | not built. Volume does not need them yet; audit logging becomes necessary the day the panel exists, since it logs admin acts |
| Realtime | not used. Impact numbers are read on open, which is what a dashboard needs |

---

# 2. One-to-many programmes — NOT BUILT AT ALL

The whole module. Per the backend spec: **ParentVeda owns the products; experts
only deliver them.** Experts must not be able to create masterclasses.

Needed in the panel: programme creation, publishing workflow (draft → medical
review → marketing review → scheduled → published → completed → archived),
scheduling, expert assignment, pricing, coupons, categories, landing pages,
media, certificates, reports.

This is the single biggest reason the panel will be needed, and it is why the
1:1 flow was built first — 1:1 needs no admin panel at all.

---

# 3. Doctor / expert side

| Need | Status |
|---|---|
| **Verification & approval** | Onboarding screens exist with "Skip for now"; **nothing approves anyone**. Uploading is a submission, not a credential. Approval must be an editorial act in the panel, never in the app the applicant controls. This now also gates the referral kit: no approved `care_partners` row, no QR. |
| KYC + bank details review | tied to payouts (Razorpay Route + linked accounts) |
| Qualification / registration checks | council number, certificates |
| Licence renewal tracking | flagged in the spec, not built |
| Expert activation / deactivation | |
| Consultation pricing | currently derived from catalogue data |

---

# 4. Brand Studio (built, config still compiled in)

The engine ships; the campaign data is a Dart file. Moving it to a table is the
next step, following the `0036` pattern.

* brands (id, name, colour, logo, landing URL) — **logos are still missing**
* campaigns per slot, schedule, audience, caps, creative
* the 5 open flags: product-guide sponsorship, compare sponsorship, placeholder
  brands, missing brand film, sampling fulfilment
* **ParentVeda Certified** — independent evaluation, published methodology.
  **Never sellable.** The panel must be able to grant it and must never expose
  it as a campaign option.
* sampling fulfilment — claim list export. NOTE the promise made on screen:
  the brand receives *a count, never a name or address*.

---

# 5. Content (long-standing)

Growing content types: articles, recipes, videos, Learn collections. Per the
earlier decision: Directus over Supabase per-type tables, public-read, video as
reference only. Fixed weekly content stays bundled in the app.

See `ParentVeda-Content-Brief.pdf` for the full inventory of what needs writing.

## 5a. Content currently has TWO write paths, and they can drift

*Raised 2026-07-27 while ingesting the TTC corpus. Nothing is broken today — but
this is the thing to settle before an editor is let loose on the panel.*

The same knowledge lives in two places, written two different ways:

| Path | Where it lands | What reads it |
|---|---|---|
| **A — a developer edits Dart** (`lib/ttc/*.dart`, `lib/data/*.dart`, `pp_*_data.dart`) | bundled in the app binary | **the app's own screens** (TTC pages, Can-I, tests, products, recipes…) |
| **B — an editor uses Directus** | Supabase (`articles`, `content_posts`, `veda_knowledge`) | **Ask Veda** (the RAG service), and `articles` also feeds the app's weekly-reads carousel via `ContentRepo` |

Ask Veda is already fully path-B: it *only* reads Supabase, so a Directus publish
plus `POST /reindex` makes it answerable with no app release. That half is done.

**The gap is the app's own screens.** They still render from the bundled Dart. So
today:

* An editor adds a TTC insight in Directus → it appears **in Ask Veda's answers**
  but **not** on the TTC screens.
* A developer adds one in Dart → it appears **on the screens** but is invisible to
  Ask Veda until `tool/export_ttc_corpus.dart` (or `export_veda_corpus.dart`) is
  re-run and re-ingested.

The export tools keep B in sync *from* A. Nothing syncs the other way.

**What to decide when we build the panel** (not now):

1. **Which content types become editor-owned**, and therefore must move to
   Supabase-first with the app fetching them. `articles` already works this way —
   `ContentRepo` / `ArticleStore` (cache + bundled fallback) is the pattern to copy.
2. **Which stay bundled on purpose.** Fixed weekly content is already a deliberate
   "stays in the app" decision; the same may be right for TTC chapter copy, which
   is closer to product design than to editorial.
3. **Retire the export tools for anything that becomes Supabase-first** — once a
   type is editor-owned, re-exporting it from Dart would overwrite an editor's
   work. Until then the export is the source of truth and must be re-run whenever
   the Dart data changes.

Until (1)–(3) are settled, the honest rule is: **Dart is the source, Supabase is a
published copy for Ask Veda.** An editor's Directus edit reaches Ask Veda but not
the screens — so don't promise editors otherwise.

---

# 6. Referral, parent-to-parent (built, table-driven)

Already follows the pattern — `referral_config` (0036) holds rewards, caps,
qualification rules and dates. The panel just needs a form over it.

**Keep this SEPARATE from the Care Partner platform.** Parent→parent is a
joining bonus between two parents; doctor→parent is a commercial relationship
with a professional. Same plumbing where it helps, different products.

---

# 7. HR / enterprise — a THIRD surface, not an extension of this one

*Scoped 2026-07-28 from two product docs: the HR Portal ("Benefit Management
Portal") and the employee-app enterprise experience. Not started. Recorded now,
per the rule at the bottom of this file, so the detail does not have to be
reconstructed later.*

`corporate` and `insurance` are already Care Partner types, so that model does
not need rebuilding.

## 7a. The HR Portal must not be Directus

Directus is **internal** — ParentVeda staff editing ParentVeda's own data. The
HR Portal is **external customers** managing their own company's benefit. Three
properties make it a different product:

* **Multi-tenant.** Every read is scoped to one company. Google's HR must never
  see Infosys's employee list.
* **External users.** HR staff are not ParentVeda staff.
* **A privacy boundary the spec says must be structural** — *"the system should
  enforce these restrictions technically, not just by policy."*

Serving that from Directus would mean multi-tenancy enforced by permission
filters edited in the same admin UI they are meant to constrain — the exact
failure `0045` exists to remove, except a misconfiguration now leaks one paying
customer's data to another. The spec also asks for something Directus is not by
design: *"a modern Employee Benefits Management Platform, not a dashboard filled
with tables."*

**So: a separate web app** (naturally alongside the Next.js site), reading
Supabase through RLS scoped by company. It is the largest single piece of this
programme.

## 7b. What DOES belong in this Directus panel

The ParentVeda-side acts of running a corporate customer — small, roughly one
migration plus a few collections:

| Need | Note |
|---|---|
| Create a company / enterprise account | Onboarding a customer is ops, not HR self-serve |
| Approved email domains | `@google.com`, `@google.co.in` — what activation checks |
| Plan, seats purchased, renewal date, status | HR sees this read-only in their Billing screen |
| Benefit definitions | Premium + N consultation credits + masterclass access. Config, the `0036` pattern |
| Provision the first HR user | Somebody has to create the account HR logs into |
| Invoices / subscription oversight | The ParentVeda side of billing |

## 7c. Privacy is the architecture, not a screen

The spec's hard rule: HR sees **activation status and anonymous aggregates**,
never behaviour. Three consequences that must be designed in, not bolted on:

1. **HR reads only pre-aggregated views.** If the portal can query anything
   per-employee beyond activation status, the promise is policy rather than a
   boundary. The aggregation layer is the only thing that touches user data.
2. **k-anonymity is a feature.** *"If only three employees are pregnant, do not
   create pregnancy-specific analytics."* That is a suppression rule living in
   SQL, and it needs a threshold decision — 5 is common, 10 is safer. Without
   it, a 20-person company's "anonymous" analytics identify individuals.
3. **The employee↔company link is sensitive on its own.** That row says "this
   user works at Google"; joined to anything else it de-anonymises. It must be
   reachable only by the aggregation layer, never by an HR-facing query.

## 7d. Decisions needed before any schema

* **Suppression threshold** for analytics (see above).
* **Are company events `programmes` scoped to a company?** Strong recommendation
  yes — `0054` already has programmes, sessions, expert assignment, capacity and
  a publishing workflow. A company webinar is a programme with an audience
  restriction; a parallel events system means two schedulers and two
  registration flows to keep in step. Cost today is one additive column.
* **Moderating company-uploaded resources.** HR uploads documents that render
  *inside the app*. Third-party content in a health product needs a review path
  and a hard rule that it is never medical advice.
* **Consultation credits must reuse the existing entitlement/booking engine**,
  not fork it. Two systems that each believe they know how many consultations
  remain will disagree. Same argument as programmes reusing `booking_slots`.
* **Support impersonation** — useful for troubleshooting, dangerous by
  definition. Decide deliberately or not at all.

## 7e. A tension to resolve deliberately

`CLAUDE.md` says *a feature is never hidden*; the enterprise spec says the
enterprise layer must be *"completely hidden for consumer users."* Both hold if
the split is: the **activation entry point** is always visible ("Does your
employer provide ParentVeda Premium?"), and the **Employer Benefits section**
appears only once activated. Worth deciding on purpose rather than discovering.

## 7f. Sizing, honestly

| Piece | Size |
|---|---|
| Directus collections for companies / plans | Small |
| Supabase schema + entitlements + activation (work email → OTP → domain → seats) | Medium |
| Analytics with k-anonymity | Medium, and subtle |
| App-side enterprise layer (activation, Employer Benefits, privacy centre, credits) | Medium |
| **HR Portal web app** | **Large — a new product surface** |

Larger than everything the admin panel has needed so far, and the portal is most
of it. **Sequenced after the current panel is configured and running** — nothing
here is blocked by it, and running a real panel first is the best input into
designing one for external customers.

---

# 8. Operational

* audit logging on every admin action (who approved what, when)
* soft delete + versioning
* role-scoped analytics — admin, doctor, hospital, partner
* payout runs and settlement status

---

## Sibling files

`docs/DIRECTUS-SETUP.md` is the runbook for actually configuring the panel —
which collections to register, the field interfaces and why each guess Directus
makes is wrong, the three roles, the two publish webhooks, and the cross-repo
handoffs to the website and Ask Veda. This file says what is needed; that one
says how to set it up.

`docs/STILL-OPEN.md` holds every parked item across the whole product — launch
blockers, decisions waiting on the user, half-built areas. Where something needs
the admin panel it is described here and merely linked from there, so the two
files never disagree.

## Keeping this file honest

Add to it **when the requirement appears**, not later. If a feature ships with a
hardcoded value that a business person will eventually want to change, that is
an admin-panel requirement and it belongs here the same day.

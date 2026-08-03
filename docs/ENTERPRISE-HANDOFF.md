# Enterprise / Sponsor build — handoff

**Written 2026-07-29** so the next session can start building immediately rather
than re-deriving. Read this, `docs/ADMIN-PANEL.md` §7 and `docs/STILL-OPEN.md`
§11, and you have everything.

**Goal:** something demonstrable to a senior — a parent activates with a work
email, Premium appears, and HR can see uptake.

> ## STATUS — 2026-07-29, end of session: §2 (a)–(e) are BUILT
>
> Everything below in "what to build next" now exists. Migrations `0059`
> (demo bypass) and `0060` (sponsor admin) are written but **not yet run** —
> that is the one outstanding action, along with `supabase/seed/sponsor_demo.sql`.
>
> | Built | Where |
> |---|---|
> | Employer Benefits row (always visible) | `lib/screens/profile_screen.dart` — `_EmployerBenefitsCard` |
> | Signup step — the door most employees arrive by | `lib/screens/auth/auth_flow_screen.dart` — `_employer()`, between `'profile'` and `'success'` |
> | Activation flow (email → code → welcome) | `lib/screens/enterprise/activation_flow_screen.dart` |
> | The benefits screen | `lib/screens/enterprise/employer_benefits_screen.dart` |
> | HR dashboard + roster | `lib/screens/enterprise/sponsor_dashboard_screen.dart` |
> | Refusal vocabulary, both languages | `lib/screens/enterprise/enterprise_common.dart` |
> | Credit bridge (reuses `grantFloatingCredit`) | `lib/services/sponsor_benefits.dart`, attached in `main.dart` |
> | HR stats reader | `lib/services/sponsor_admin_store.dart` |
> | Eligibility roster (the sheet HR sends) | `0061` — `sponsor_eligible_people`, CSV-imported via Directus |
> | Consumer-domain guard | `0062` — `gmail.com` can never be a sponsor domain |
> | Monthly trend, no snapshot table | `0063` — `sponsor_trend()`, derived from `activated_at` |
> | Roster reconcile — report, then act | `0064` — `sponsor_roster_stale()` / `sponsor_roster_revoke()` |
> | Engagement measurement | `0065` — `usage_events` (insert-only) + `sponsor_engagement()`; `lib/services/usage_events.dart` |
> | Web portal (login / dashboard / people / report) | `C:\parentveda-web` → `src/app/portal/` |
> | 74 tests | `test/sponsor_enterprise_test.dart` |
> | SQL verification | `supabase/seed/verify_sponsor_gates.sql` |
>
> **To demo:** run `0059`, `0060`, then `supabase/seed/sponsor_demo.sql`.
> Activate in-app with any address `@parentveda-demo.com`, code
> `DEMO-ACTIVATE-2026`. To see the HR side, `grant_plan(<your uid>,
> 'sponsor_admin', 'internal', 'demo_northwind', null, 'demo setup')`.
>
> **New open points opened by this work:** `STILL-OPEN` §11.7 (the credit is
> granted client-side), §11.8 (an admin consumes a seat), §11.9 (company
> events/resources have no audience scope). The design reasoning is written up
> in `BACKEND-PATTERNS` §10.
>
> **Next free migration number is `0066`.**
>
> **How a customer is onboarded, end to end:** create the `sponsors` row →
> import their staff sheet into `sponsor_eligible_people` (Directus CSV
> import; columns `work_email`, `sponsor_id`, `full_name`, `employee_ref`,
> emails **lowercased in the spreadsheet first** or the CHECK rejects them) →
> tell HR to announce it. Domains are the fallback for a customer who never
> sends a list, not the primary path.

---

## 1. What is already built (do not rebuild)

### Migration `0057` — the entitlement engine

Capability-driven, not user-type-driven. Never ask "is this user Premium?";
ask "does this user have capability X?".

| Object | Notes |
|---|---|
| `capabilities` | id, name, description, category, active |
| `plans` | id, name, kind (`consumer`\|`sponsor`\|`internal`), active |
| `plan_capabilities` | the matrix — plan_id + capability_id |
| `user_entitlements` | user_id, plan_id, **source**, source_ref, starts_at, ends_at |

**Functions:**
* `has_capability(p_capability text) -> boolean` — derives the user from
  `auth.uid()`, never a parameter. Granted to `authenticated`.
* `my_capabilities() -> setof text` — everything the caller holds, one round trip.
* `grant_plan(p_user_id, p_plan_id, p_source, p_source_ref, p_ends_at, p_actor) -> jsonb`
* `revoke_plan_by_source(p_user_id, p_source, p_source_ref, p_actor) -> jsonb`
  — removes only what ONE source granted, so an employee who leaves keeps a
  Premium they bought. That is why `source` exists.

**Seeded:** five capabilities — `consultation_credit`, `sponsor_events`,
`sponsor_resources`, `sponsor_announcements`, `masterclass_access` — and a
`free` plan granting all of them. **Nothing is locked today.** Making something
Premium later is two rows, not a release.

### Migration `0058` — sponsors and activation

| Object | Notes |
|---|---|
| `sponsors` | id, name, **kind** (employer\|insurer\|hospital\|ngo…), plan_id, seats_purchased, status (pending\|active\|suspended\|ended), renewal_at, logo_url, support_contact |
| `sponsor_domains` | domain (PK, lowercase, no `@`), sponsor_id. **NOT public-read** — it is a customer list |
| `sponsor_members` | user_id + sponsor_id (PK), work_email, status, activated_at. **Own-row read only.** Unique index on `lower(work_email)` |
| `sponsor_activation_codes` | service_role only, no grants at all |

**Functions:**
* `request_sponsor_activation(p_work_email) -> jsonb` — granted to
  `authenticated`. Refusal codes: `invalid_email`, `not_eligible`,
  `already_activated`, `no_seats_left`, `too_many_requests`. Success code
  `code_sent`. **The code is never returned in the response.**
* `confirm_sponsor_activation(p_work_email, p_code) -> jsonb` — granted to
  `authenticated`. Codes: `not_signed_in`, `no_pending_code`, `code_expired`,
  `too_many_attempts`, `wrong_code`, `sponsor_inactive`, `no_seats_left`,
  success `activated`. Calls `grant_plan(..., 'sponsor', sponsor_id, ...)`.
* `my_sponsor() -> jsonb` — `{sponsor_id, name, kind, logo_url,
  support_contact, activated_at}` or `{}`. Granted to `authenticated`.
* `remove_sponsor_member(p_sponsor_id, p_user_id, p_actor) -> jsonb` —
  service_role only. Soft-removes and revokes only the sponsor's grant.

**Seeded plan:** `employer_standard`, kind `sponsor`, granting all capabilities.

### App — `lib/services/entitlement_store.dart`

Singleton `ChangeNotifier`, local-first, cached in `entitlements_v1`.
Already wired in `main.dart`.

```dart
EntitlementStore.instance.capabilities      // Set<String>
EntitlementStore.instance.sponsor           // SponsorInfo?  (id,name,kind,logoUrl,supportContact,activatedAt)
EntitlementStore.instance.isSponsored       // bool
EntitlementStore.instance.can(Caps.sponsorEvents)
EntitlementStore.instance.requestActivation(email)   // -> {ok, code, message}
EntitlementStore.instance.confirmActivation(email, code)
EntitlementStore.instance.refresh()
```

`Caps` holds the capability id constants. **`can()` decides what to SHOW, never
what to ALLOW** — every real gate is enforced again server-side.

Catches an uninitialised Supabase rather than throwing (tests, no-key builds).

---

## 2. What to build next, in order

### (a) Employer Benefits section — `lib/screens/profile_screen.dart`

That screen is a `ListView` of `_VaultCard`-style blocks. Add one.

* **Always visible:** "Employer Benefits" row. If not activated →
  "Activate employer benefits". If activated → "ParentVeda Premium ·
  provided by {sponsor.name}".
* This resolves the tension between `CLAUDE.md`'s *a feature is never hidden*
  and the spec's *hidden for consumer users*: the **entry point** is always
  shown; the **benefits section** only after activating.
* Contents once activated: premium status, consultation credits, company
  events, company resources, support contact.
* Listen with `AnimatedBuilder(animation: EntitlementStore.instance, ...)`.

### (b) Activation flow — new `lib/screens/enterprise/`

Three screens, `Navigator` + `MaterialPageRoute`, `RouteSettings(name:)`:

1. **Work email** — "Your employer may already provide Premium." One field,
   Continue → `requestActivation()`. Show `message` on refusal; **branch on
   `code`, never the wording.**
2. **Code entry** — 6 digits → `confirmActivation()`. Handle `wrong_code`,
   `code_expired`, `too_many_attempts` distinctly.
3. **Welcome** — "Provided by {company}", then immediately the privacy
   promise: your employer cannot see your pregnancy, your child, your journal,
   your Ask Veda conversations, your searches. Only anonymous aggregate uptake.

Also add an entry point in `auth_flow_screen.dart` — an optional step in
`_profile()` beside the WhatsApp opt-in, or a screen between `'profile'` and
`'success'`. It is a `_screen` string state machine with a `_backMap`.

### (c) ⚠️ A demo path, because nothing sends the code

`STILL-OPEN` §11.6: there is no email provider. `request_sponsor_activation`
writes a valid code that reaches nobody.

For a demo, add a **dev-only** way to complete activation — e.g. a migration
adding `sponsors.dev_bypass_code text`, checked *only* when set, with a comment
saying it must be null in production and a test asserting no seeded sponsor has
one. Do NOT weaken the real path: without the code, anyone typing
`someone@google.com` gets Premium.

### (d) Consultation credits — reuse, do not invent

`lib/booking/booking_store.dart` already has `grantFloatingCredit()` and
`kAnyConsultOffering` — a credit not bound to one expert, built for referral
rewards. Enterprise credits use that. **One authority per fact**; a second
credit counter will disagree with the first.

### (e) HR stats — in-app, `sponsor_admin` capability

Decided: HR sees stats **inside the app**, not a web portal (STILL-OPEN §11.1,
still open as a preference but this is the current direction).

* New capability `sponsor_admin`, granted by a plan, revealing a "Programme"
  section.
* Needs **pre-aggregated views** (`sponsor_dashboard`, `sponsor_utilisation`)
  filtering on the caller's sponsor, resolved from `auth.uid()` — never passed
  in, exactly like `expert_roster()`.
* Shows: eligible · activated · activation rate · active this month ·
  consultations booked/completed · upcoming events.
* **Employees list shows ELIGIBILITY ONLY** — name, work email, status,
  activation date. Never usage. This is where the product promise is kept.
* **Suppression below n = 5.** A 30-person company's "anonymous" analytics
  identify people otherwise. Config row, not a constant.
* Export should be a consistent **report**, not a raw CSV (§11.2).

---

## 3. Rules that must not be broken

* **Singleton `ChangeNotifier`, `Navigator`, stage-first folders.** Every source
  PDF specifies Riverpod/GoRouter/feature-first. `CLAUDE.md` rejects all three;
  the briefs are wrong, not the codebase. The user has confirmed this twice.
* **Gates RETURN `{ok, code, message}`, never `raise`.** A raise aborts the
  transaction and discards the audit row written a line earlier — the defect
  `0055` fixed. Use `public._refuse(...)` / `public._allow(...)`.
* **Server-side enforcement.** `can()` is a rendering hint.
* **`sponsor_members` is the sensitive table** — it says where a person works.
  Only the aggregation layer touches it.
* **Local-first.** Uninitialised backend behaves exactly like logged out.
* **Bilingual from the first string** — `_p(english, hindi)`, Hindi in
  **Devanagari**. The parameter is still *named* `hinglish` in code pending the
  rename; the ~92 enterprise strings are not migrated yet. See CLAUDE.md.
* **Next free migration number is `0059`.** Claim it in the commit that writes
  it; never reserve ahead (a held-then-deferred `0050` once became a hole).

---

## 4. Verification

* `flutter analyze` clean of new issues; full suite green (~1556 tests).
* **Wiring gate** — grep the call site of every new store before calling it done.
* `supabase/seed/verify_sponsor_gates.sql`, modelled on
  `verify_admin_gates.sql`: exercise every activation refusal inside a
  transaction that rolls back, assert each refusal is **recorded**, and end
  with `raise exception` so nothing persists. That pattern found a real defect
  once already.
* A test that no sponsor-facing view exposes a user id.
* A cross-tenant test: as sponsor A, query the views, get zero of sponsor B.

## 5. Working agreements

* **Do not run git.** Give the user commands; explicit file paths, no `-A`.
  No `Co-Authored-By`.
* User prefers **continuous execution** — build through the phases, one commit
  at the end, don't stop per phase.
* **Explain trade-offs and mechanisms** — the user is learning backend and
  system design through this product (`CLAUDE.md` working agreements).
* Other terminals work in this repo. Only stage files you touched.

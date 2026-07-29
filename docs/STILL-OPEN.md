# Still Open

Everything parked, undecided, or half-built — in one place, so nothing gets
quietly dropped between sessions.

**Last updated:** 2026-07-29

## How to use this file

* **Add the day it appears.** A thing you decide to leave for later is an open
  point at that moment, not when you remember it.
* **Never delete an entry — move it to §12 Closed** with what was decided and
  when. Half the value here is being able to see why something was left.
* Each entry says what is *blocked* by it. Most block nothing today; a few
  block launch or block money moving, and those are marked.
* `docs/ADMIN-PANEL.md` is the sibling file: it collects everything that needs
  the Directus panel. Where an item lives in both, this file links there rather
  than repeating it.

**Blocking launch:** §1.1, §1.2, §1.3
**Blocking the sponsor programme:** §11.6 — the activation code has no sender
**Blocking real money:** §2.1, §2.2, §5.1
**Everything else** can wait without harm.

---

# 1. Launch blockers

## 1.1 `assetlinks.json` is not served

`https://parentveda.in/.well-known/assetlinks.json` → **404**.

Without it, `/care/<TOKEN>` and `/invite/<CODE>` open in a browser even when the
app is installed, instead of opening the app. The app's manifest already
declares `autoVerify` for both paths, so the file is the only missing half.

Needs the **Play App Signing** SHA-256 from the Play Console — *not* a local
debug keystore fingerprint. Correctly parked until the app is uploaded.

**Owner:** website terminal, once the app is on Play.

## 1.2 `APP_LIVE = false` on the website

`src/lib/invite.ts`. Both `/care/` and `/invite/` render fully and show the
code, but neither redirects to Play, because there is no listing to redirect to.
Redirecting now would send every scan to a 404 store page.

One-line flip on listing day. Nothing else changes.

## 1.3 Demo rows must be removed before launch

`care_partner_demo.sql` and `care_partner_demo_orgs.sql` insert nine fake
partners (`demo_%`, `demo_org_%`), including **Dr Vikram Sethi**, whose
`trust.primary` is literally `"Sponsored by"` — deliberately, as the test for
the website's allowlist.

If those rows reach production, a fake doctor is live on a public page.

```sql
delete from public.partner_referrals where partner_id like 'demo\_%';
delete from public.care_partners      where id         like 'demo\_%';
```

---

# 2. Decisions needed before real money moves

## 2.1 Attribution ownership across several partners

Parked deliberately — *"a really good point"*.

A parent scans Dr A's QR. Months later she scans Hospital B's. Who owns the
commission?

Today: **first touch, forever**, enforced by `partner_attributions.user_id`
being the primary key. `care_partner_config.attribution_model` is seeded
`first_touch` so the default is a recorded decision rather than an accident.

The tension is real: Module 5's Care Circle implies several partners at once,
while Module 2 says attribution is permanent. Options are first-touch-forever,
last-touch, shared commission, or Care Circle membership without commission.

Does **not** block anything now — it is a later-in-time event. Must be settled
before commission is paid, and changing it later rewrites who introduced whom.

**Knock-on:** §4.1 (the Care Circle can only hold one partner) waits on this.

## 2.2 No commission rates have been agreed

`care_commission_rules` (0038) is seeded at **zero for every source**,
deliberately — an invented 2.5% would put a number in front of a doctor that
nobody at ParentVeda approved.

Until a rate exists, the ledger accrues nothing and the doctor's Impact tab
shows real consultation earnings beside an empty referral ledger.

## 2.3 The commission ledger has no writer

`commission_ledger` (0037) is correct, immutable and append-only — and nothing
writes to it. Entries are meant to be created by an edge function when a
payment settles. That function is not built, correctly, since §2.2 is undecided.

Also unbuilt: payout runs, settlement status, tax handling, Razorpay Route
linked accounts.

---

# 3. Memories / share cards

Paused by explicit decision. **Gaps 1 and 2 must ship together** — syncing the
saved list without the photos gives empty frames on a new phone.

## 3.1 Photo upload to Storage

Photos live only on the device. Needs `StorageService` →
`media/<uid>/memory/`.

*Already fixed and not part of this:* picked photos are copied out of
image_picker's purgeable cache, so they no longer vanish.

## 3.2 Saved-timeline sync — **merge semantics undecided**

Cloud-wins (the `CloudSyncedStore` default) can silently lose a card made
offline. Union-merge by id with tombstones cannot.

**Recommendation: union-merge.**

## 3.3 More entry points (Gap 4)

Parked. Known where it lives during testing.

---

# 4. Care Partner platform

Built and wired; these are the deliberate gaps. Full list with reasoning in
`docs/ADMIN-PANEL.md` §1d.

## 4.1 The Care Circle holds exactly one partner

The spec says the circle "grows over time" — doctor, hospital, lactation
consultant, ParentVeda. Today it renders one attributed partner plus
ParentVeda, because attribution is first-touch by primary key.

**Blocked on §2.1.** Not a bug; a consequence of an undecided question.

## 4.2 `care_trust_messages` is read by nobody

0038 created it with per-type default copy and a CHECK constraint blocking
advertising language. Neither the app nor the website reads it — both read
`care_partners.trust`.

Inert until the admin panel wires it. Noted so it is not mistaken for working
config. **Consequence today:** `care_partners.trust` is plain `jsonb` with *no*
constraint, so the website's allowlist is the only thing standing between a bad
row and a doctor's name under an advertising label.

## 4.3 No campaign rows exist

`partner_referrals` carries `campaign_id`, and nothing creates campaigns —
dates, channel, landing behaviour. Admin panel work.

**Half closed (2026-07-27).** `0051` adds `create_partner_campaign()`, which
mints a token carrying a campaign and channel — and refuses for a partner who is
not `active`, so a campaign cannot print a code for someone nobody vouched for.
What remains is the Directus Flow that calls it. See `docs/DIRECTUS-SETUP.md`.

## 4.4 Not built, deliberately

A/B variants of visibility rules · shared/tiered commission (flat basis points
only) · partner brand colour and contact details · materialized views ·
versioning · Realtime.

**Audit logging is now built** (`0050`): `admin_audit`, append-only, written
*inside* each `0051` function so it cannot be bypassed by calling them another
way. Directus's own activity log records that a Flow ran, not what the database
agreed to or what it checked first — which is the question anyone actually asks
afterwards. The panel reads it through the `admin_audit_log` view, never the
table, so there is no path to editing the record of your own actions.

### 4.4a Refused admin actions were not audited — FIXED 2026-07-28 (`0055`)

**Resolved.** `0055_gates_return_refusals.sql` redefines all seven gates to
RETURN `{ok, code, message}` instead of raising, so nothing aborts and the audit
row commits with the call. `verify_admin_gates.sql` was updated to read the
returned `ok` rather than trap an exception, and now also asserts that every
refusal carries a machine-readable `code` — a Flow branches on the code; the
message is for the human reading the failure.

**The trade-off this accepted, and the obligation it creates:** a raise made a
careless caller fail loudly; a returned `{ok:false}` is HTTP 200, so **a Directus
Flow that ignores the body will report success for an approval that never
happened.** Every Flow MUST branch on `{{$last.ok}}`. That is now load-bearing
rather than good practice — see `docs/DIRECTUS-SETUP.md` §5d. It is the right
trade because a Flow that does not check its result is a Flow bug, visible the
first time anyone looks; losing the audit row was a design defect no Flow could
compensate for.

*Original entry, kept per the rule at the top of this file:*

Verified against the live database by `supabase/seed/verify_admin_gates.sql`:
17 checks passed, 1 failed.

Every gate in `0051`/`0054` does `perform _audit(...)` and then
`raise exception`. The raise aborts the transaction, which rolls back the audit
insert made a line earlier. So **successes are logged and refusals are not** —
backwards, since the blocked attempts are the rows the log exists for. Today
`admin_audit` records "who approved this doctor" but nothing about who tried and
was stopped.

Nothing is broken in the gates themselves: all five refusal paths on
`approve_care_partner`, plus rotation confirmation, campaign-for-a-pending-
partner and all five on `publish_programme`, refuse correctly.

**The fix:** the gates should RETURN a refusal rather than raise one —
`jsonb {ok, code, message}` — so the audit row survives the call. The Directus
Flow then branches on `ok` instead of relying on a PostgREST error.

The trade-off is real and worth stating: a raise makes a careless Flow fail
loudly, whereas a returned `{ok:false}` will read as HTTP 200 and a Flow that
ignores the body will report success. But that is a *Flow* bug, fixable in the
Flow; losing the audit row is a *design* bug that no Flow can compensate for.
`docs/DIRECTUS-SETUP.md` §5d already says the Flow must assert on the response.

Touches `approve_care_partner`, `deactivate_care_partner`,
`create_partner_campaign`, `rotate_partner_tokens`, `remove_demo_partners`,
`assign_programme_expert`, `publish_programme`, and the expectations in
`test/admin_actions_test.dart`.

**Brand colour deserves a decision, not just deferral:** letting a partner tint
app surfaces cuts directly against "never promotional".

---

# 5. Doctor side

## 5.1 Verification and approval belong in Directus

Raise this until it is done.

Onboarding screens exist with "Skip for now". **Nothing approves anyone.**
Uploading a certificate is a submission, not a credential. Approval must be an
editorial act in the panel, never in the app the applicant controls.

This now also gates the referral kit: no `active` partner row → no QR. `0040`
added `create_care_partner()` and `mint_partner_token()` (service_role only) so
the panel has functions to sit on top of.

**Unblocked, not finished (2026-07-27).** `0051` adds `approve_care_partner()`,
and the point of it is the refusal rather than the update. It reads
`care_partner_verification` (`0050`) and raises unless the council, the
registration number and the KYC reference are all present and the registration
has not expired. So approval cannot be a dropdown someone clicks assuming the
checks happened elsewhere, and licence expiry gets looked at on the one occasion
anyone reliably would — the moment they are about to rely on it. Every call,
allowed or refused, writes `admin_audit`.

Verification paperwork is a **separate, private table on purpose**:
`care_partners` is public-read so a parent can see "Invited by Dr Meera Rao"
before she has an account, which means any column added there is world-readable.
A council registration number and a KYC reference are not public identity.

**Still needed:** the Directus Flow that calls the function, and a form over
`care_partner_verification` for capturing the paperwork. Until then approval is
possible from the SQL editor but not from the panel — so keep raising this.
`test/admin_actions_test.dart` holds the invariants meanwhile.

## 5.2 One-to-many programmes — not built at all

Masterclasses and cohorts. The single biggest reason the admin panel will be
needed, and why 1:1 was built first: 1:1 needs no panel.

## 5.3 Gaps on the 1:1 side

Cancel/reschedule from the **parent** side · an in-app notification centre
(waiting on Firebase) · no-show from the parent's view.

---

# 6. Brand Studio

Detail in `docs/BRAND-STUDIO.md`.

## 6.1 Native Discovery breadth
Needs article/FAQ → product tagging. Manual (safe) vs automatic keyword match
(risky in health copy). **Recommendation: manual.**

## 6.2 Sampling fulfilment
Registrations reach nobody. Demo-only, or a Supabase table with CSV export.
**Not** sending the list to the brand — the screen promises the brand receives
*a count, never a name or address*.

## 6.3 ParentVeda Certified
Only a `certified` bool exists. The visible half — badge, a "what Certified
means" page, published criteria, one demo certified brand — is unbuilt and is
pure front-end. Must never be sellable.

## 6.4 Partner logos
Drop 7 PNGs into `assets/brand/partners/`; monogram fallback until then.

Do **not** retry random web image sources. Already tried, inspected and
rejected: two were other brands' vintage adverts, one was a real child's photo.

---

# 7. Admin panel (Directus)

Not built at all — no collections, for any table. Deliberate: features are
still churning, and rebuilding the panel each time is the expensive kind of
rework.

Full running requirements: **`docs/ADMIN-PANEL.md`**. Keep adding to it the day
a requirement appears.

Adding a doctor today is SQL:

```sql
select create_care_partner('cp_meera', 'Dr Meera Rao', 'doctor',
                           'Obstetrician', 'Rainbow Hospital', 'Hyderabad');
```

Coming later and already noted there: the **HR / corporate panel** for when
ParentVeda is sold to companies. `corporate` and `insurance` are already Care
Partner types so that model does not need rebuilding.

Also noted there (**§5a**, raised 2026-07-27): content currently has **two write
paths** — a developer editing bundled Dart, and an editor publishing to Supabase
via Directus. Ask Veda already reads only Supabase, but the app's own screens
still render from the bundled Dart, so a Directus edit reaches Ask Veda's answers
and not the screens. Which types become editor-owned (and therefore
Supabase-first, `ContentRepo`-style) is a decision to settle before editors are
given the panel.

---

# 8. Website ↔ app contract

## 8.1 `utm_term` must carry the channel

The `/care/` page forwards `ch` → `utm_term`. If that ever stops, every scan is
recorded as a QR and a doctor's WhatsApp message is counted as poster traffic.
Wrong data reads as real data.

`test/care_website_contract_test.dart` runs the app's parser against the
website's real output and fails if the two drift.

## 8.2 `/invite/` still has no store redirect

It renders the code, but has no Play button and no `referrer`. Fine today — the
app is not listed. On launch day a friend installing from a shared link would
arrive with nothing attached unless this is done at the same time as §1.2.

## 8.3 Trust labels are duplicated in two places

The website enforces an **allowlist**; the app enforces a **blocklist** that
fails closed to "Invited by". Both are correct, and they are separate lists.

**Adding a new label needs both sides changed together.** Currently allowed on
the website: Invited by · Recommended by · Connected through · Your Care
Partner · Supported by · Provided by.

---

# 9. Trying to Conceive

Full record in `docs/TTC-SPEC.md` (§6 what was built, §7 what was not).
Repeated here because this file is the one place open points are findable.

## 9.0 The due-date SOURCE does not sync

`DueDateSource` lives in `shared_preferences` only. The cloud profile carries
`due_date` but no column saying where it came from, so a second device restores
the date and reads the source as `unknown` — which counts as **ours**, so it is
safe, but the flag does not travel.

Blocks nothing today, because no pregnancy screen consults the flag yet. It
becomes real the moment one does: her phone would defer to the scan and his
would not. One nullable `due_date_source` column on `profiles` when that day
comes.

## 9.1 TTC sync has never run against the live database

`0041` and `0042` are **applied** (2026-07-27), and the Dart↔SQL contract is
enforced by `ttc_schema_contract_test.dart` — 48 assertions covering every
column, order-by, upsert conflict target and NOT NULL the client relies on.

What has *not* happened is a single real round-trip. Nothing has ever been
written to `ttc_cycles` by a signed-in user.

That matters more than it sounds, because **every TTC cloud write is
fire-and-forget** (`.catchError((_) {})`) so a network hiccup never reaches the
UI. The cost is that an RLS refusal looks identical to success from inside the
app: the local half works perfectly and the table simply stays empty. No test
can catch that — only a live session can.

**Plan agreed:** the user signs in, Claude drives the UI, and we check
`select * from ttc_cycles` together. Ten minutes. Until then, sync is
proven-by-contract, not proven-live.

## 9.1b The inference boundary is named but not yet enforced everywhere

`lib/services/journey_state.dart` now answers, for any stage: *what may
ParentVeda infer, and what must come from a clinician?* It is default-deny, so a
new `Inferable` is safe until somebody permits it in code.

**`Inferable.gestationalAge` now has a writer** (2026-07-27). `DueDateSource`
records how the date was arrived at, the Due Date Calculator supplies it from the
method she already picks, and `PregnancyController.dueDateFromClinic` reports it.
A scan, an IVF transfer and "my doctor told me" are the clinic's; a last period
and a conception date are ours.

**What is not done:** no pregnancy *screen* consults it yet. Nothing today shows
a competing number, so there is no live defect — the app stores one date and
derives from it. The gap is that a woman who set her date by last period and
later had a scan keeps the old number silently. The calculator now tells her a
scan should replace it; it does not yet prompt her after the fact.

Also still unread: `Inferable.growthExpectation` / `developmentalStage` —
parenting is currently permitted both. Worth a clinician's view on whether a
paediatrician's own assessment should ever override ours.

Blocks nothing. The value is that the next one of these gets found by asking the
question rather than by shipping it.

## 9.2 Ask Veda videos are still "coming soon"

Deep-linking now lands on the item (§10). Videos remain the exception: the
section renders and says so, because there is no hosted video content to ingest
yet. Same wait the other two stages are in — Bunny Stream is parked until real
videos exist.

## 9.3 Clinical seed copy has not been medically reviewed

**The brief is written: `docs/TTC-IVF-REVIEW.md`.** Hand it to a fertility
specialist — ~30 minutes, every question answerable in a line. It covers the
IVF/treatment decisions plus the eleven clinically loaded claims in the wider
library (AMH, TSH thresholds, semen analysis, HSG, the ectopic warning).

**Status 2026-07-27:** the brief has been through a **product review**, not a
clinical one, and the reviewer said so explicitly. Their answers are recorded in
`§7` of the brief. Q1 is no longer the worry it was — ovulation induction is now
split by whether a clinic is monitoring, not by drug name, and the reviewer
estimated 90–95% of patients can answer that. What remains genuinely open is
listed in §9.4.

Below is what the entry originally said, kept because it is still true until
someone answers.

The engine's arithmetic is conventional and defensible (luteal-phase
subtraction, a 5-day-before to 1-day-after window). The *content* explaining
AMH, PCOS, IVF and test interpretation is authored seed copy and should be read
by a doctor before launch. Same standing as §5.1's verification gap.

## 9.4 Three clinical statements held back on purpose

A product review proposed adding these. They are the only recommendations from
that pass that **add** a clinical claim rather than softening one, so they are
written into `docs/TTC-IVF-REVIEW.md §7` for the specialist and deliberately
**not** in the product:

| # | Statement | Why held |
|---|---|---|
| P1 | Trigger hCG detectable ~10–14 days | A specific window we have no basis to state, however hedged. |
| P2 | OHSS risk roughly trigger → 1–2 weeks after | Same; plus a stated window risks her dismissing symptoms outside it. |
| P3 | Adding *severe abdominal pain*, *reduced urine output*, *persistent vomiting* to the OHSS urgent list | We lean toward adding — a longer list of reasons to call a clinic errs the right way — but it is a clinician's call. |

Everything else from that review **is** implemented, because it moved toward
less certainty: fasting instructions deferred to the clinic, no numbers on
trigger drift, TSH not stated as a universal target, HSG no longer promising
improved fertility, AMH clarified as ovarian response rather than egg quality.

The pathway wording is **resolved and shipped**. Both questions asked about
clinical *events* — scans, a trigger injection — which are proxies: a
natural-cycle FET has neither and the clinic still owns the timing, and a fully
medicated transfer has no trigger at all. They now ask the principle, with the
events demoted to examples underneath:

> **1.** Is your fertility clinic deciding the important dates for this cycle?
> *Scans or blood tests · a trigger injection · IUI timing · egg retrieval ·
> embryo transfer*
>
> **2.** Has medication taken over WHEN ovulation or transfer happens — an
> injection that sets the hour, or a fully medicated schedule?
> *If your own body still decides the day, answer no.*

What remains open is whether they hold for pathways we have not thought of.
That is now a question in the brief rather than a wording note.

## 9.5 The Ask Veda FAB still overlaps content on pregnancy and parenting

TTC is fixed; the other two stages are not, and they have the identical problem
for the identical reason.

The FAB is mounted in `MaterialApp.builder`, above every route, so it is
invisible to layout — no screen reserves room for it, no `Scaffold` knows it is
there, and a list's last rows end up under a 56px opaque circle. On TTC that
blocked a delete `×`, a room's **Join**, and a consultation's price. It is
undiscoverable rather than merely ugly: from where the user sits the control is
not obscured, it is absent, and "scroll further" is not something anyone tries
when a list has visibly ended.

**The fix already exists and is shared:** `kAskFabReserve` in
`lib/widgets/global_ask_fab.dart`, derived from the FAB's own offset and size so
it cannot drift. Adopting it is mechanical — point each stage's scroll padding at
it, the way `ttcBottomInset` now does.

**Why it is parked rather than done.** Pregnancy and parenting are shipped and
carry real user data, and the rule here is that they get extended additively, not
swept. It is also a visible change to two apps' bottom spacing on every screen,
which is a product call rather than a bug fix. `test/ttc_fab_clearance_test.dart`
shows the shape a matching test would take.

One thing to decide with it: the FAB sits at `bottom: 150` whenever
`AppNav.index == todayTab` and we are not in parenting — a condition meant for
the pregnancy Today tab's Mom|Dad pill, but which is also true inside TTC. It
happens to be right there (TTC has its own Her|Him overlay at `bottom: 96`), so
the reserve is sized for the taller position. If either overlay moves, revisit
the pair together.

## 9.6 `TtcInsight.forPartner` is an inert flag

It defaults to `true` and nothing anywhere sets it `false`, so the partner
screen's `where((i) => i.forPartner)` selects all twenty-five insights. Not
broken — the intent is documented on the field — but it is currently a config
option expressing a state the product does not have, which is the shape this
codebase has said it does not want.

Either author some insights that are genuinely hers alone, or drop the field.
Cheap either way; noted so it is a decision rather than a leftover.


## 9.7 TTC attachments do not sync

`TtcRecord.attachments` is cached locally and is deliberately absent from the
cloud row: `pushToCloud` names its columns explicitly and does not name this
one. So a report attached on one phone is not on the next one.

That is the agreed position while the UI is being finalised — TTC takes no new
schema. The **files themselves** already travel: `StorageService.upload()`
returns a storage object path once signed in and the original local path
otherwise, so switching the backend on starts uploading them without a code
change. What is missing is only the *list*.

Closing it: one nullable `files jsonb` (or `text[]`) column on `ttc_records`,
one line in `pushToCloud`, one line in the row decode. Ten minutes plus a
migration — stated here so it is a decision rather than a surprise on the day
someone reinstalls.

## 9.8 TTC medication uses the app-wide `medications` table

`ttc_medication_screen.dart` writes through `MedicineStore`, which is app-level
(`lib/services/`) and already backed by `medications` / `medication_logs`. That
is deliberate — a medication is a fact about a person, not about a stage, and it
meant the feature needed no new schema at all.

The consequence worth knowing: a medication recorded in TTC is the *same row*
the pregnancy Medicine Tracker reads. That is almost certainly right — the
letrozole she was on before conceiving is the same letrozole afterwards, and the
transition engine's promise is that nothing restarts. But it is a shared-surface
decision nobody has explicitly signed off, so it is written down here.

If the two stages ever need separate lists, `MedType` already distinguishes
them and a filter is one line. Do not build a second store.

**A second, smaller gap in the same place.** `Medication` has no author field,
where `TtcSupplement` has `TtcAuthor`. So the TTC medication list cannot say
whose a row is.

This is **not** a privacy problem in production: on a real paired setup his
phone holds his own `MedicineStore` rows and hers holds hers, so neither ever
sees the other's. It only shows up behind the Her|Him *testing* switch, where
one device is pretending to be two — and there it is the testing affordance
behaving as designed, not a leak.

It becomes real work only if you want both partners' medication visible in one
list, which male-factor treatment would eventually justify. `TtcAuthor` on the
model plus a segmented control is the shape; it needs a column, so it waits with
everything else here.

---

# 10. Content

## 10.1 Father Mode weekly copy is a working draft

37 weeks of `father_insight` are written and shipped, one per week
(`lib/data/father/journey_week_NN.json`). They have the right shape and voice
but **they are mine, not yours** — replace them when real copy is written.

Dropping in real copy needs no code change. Adding `supporting_partner`,
`connecting_with_baby` or `mission` to a week's JSON overrides the derivation
for that section only; `father_week_content_test.dart` asserts the override
list is exactly `[22, 28]`, so it will fail the moment a new one lands and make
the change deliberate.

Two specific things a human should look at:

* **The Hindi is transliterated Hinglish**, matching the existing house style
  across the app. It wants a native read before launch — not a translation
  check, a *does-a-father-actually-talk-like-this* check.
* **The missions read correctly but were written for a "partner"**, not
  specifically a father — they derive from `partnerCorner.oneMission`. Nothing
  is wrong in them; the question is whether the voice is his.

## 10.2 Father DAILY copy is derived, and is a working draft

**The one-prototype-day bug is fixed** (see §12). What remains is the same note
as §10.1: the father's daily card is now built from the mother's 259-day pool,
re-voiced, and that is a working arrangement rather than authored father copy.

Two things a human should decide when real copy exists:

* **The Learn card is her `grow` block verbatim.** It reads fine to a father —
  it is parenting wisdom, not pregnancy education — but it is her wording.
* **The mission lead-ins are three fixed strings** ("Do this with her today",
  "Say this to her today", "Make this happen for her today"), chosen by the
  nurture type. Three phrases across 259 days will start to feel like a
  template; more variants, or per-week ones, would fix that cheaply.

Dropping an authored `journey`-style father day file in still overrides the
derivation for that day — the precedence is the same as the weekly.

## 10.3 Content brief is a snapshot, not an inventory

`ParentVeda-Content-Brief.pdf` lists every content slot as of 25 July. Work
since then — the parenting Learn/Watch/Food expansions, Care Partner trust
copy, these father weeks — is not in it. Regenerate rather than patch when it
drifts far enough to mislead; the source is `app-review/_source/`, which
belongs to the other terminal.

---

# 11. Sponsor / enterprise programme

*Opened 2026-07-28 alongside the entitlement engine build. Full scoping in
`docs/ADMIN-PANEL.md` §7; these are the points deliberately left open.*

## 11.1 Where HR actually sees their stats — IN-APP BUILT, WEB STILL OPEN

**Update 2026-07-29:** the in-app surface is built (`0060` + Profile → Employer
Benefits → Programme, behind the `sponsor_admin` capability). The web option
stays open rather than closed: the two read the same functions, so a `/portal`
page later is a front-end job. The original reasoning is kept below because the
argument against a phone has not gone away, it has only been outweighed by
being able to ship something.

The aggregation views are the product; the screen over them is a thin renderer.
That is deliberate, because the surface is not settled:

* **In-app** (a `sponsor_admin` capability revealing a Programme section) reuses
  auth, sessions, RLS and the design system — nothing new to secure. But HR
  works at a desk, a phone is a poor surface for a dense table, and some HR
  contacts are not parents, so "install our pregnancy app to see your
  dashboard" is an odd ask mid-procurement.
* **Web** (`/portal` in `C:\parentveda-web`) has the right ergonomics but no
  authentication exists there at all today.

**A security point worth recording, because it will come up again:** a guessable
URL like `/acme` is not the risk. The URL must never determine access — the
session must. Resolve `sponsor_id` from the authenticated user and scope every
query to it in Postgres, exactly as `expert_roster()` derives the expert from
`auth.uid()` rather than a parameter. Then a guessed URL returns nothing.

**Decision deferred on purpose.** Both surfaces read the same views, so this is
a front-end choice made later, not an architecture one made now.

## 11.2 "Download" should be a report, not an export

HR forwards numbers to leadership far more often than they browse. A raw CSV
makes that their formatting problem. The deliverable is a consistent, branded
report — same shape every month, ready to forward. Treat it as a first-class
output rather than an afterthought on whichever screen wins §11.1.

## 11.3 Usage analytics — wanted, not built

The sponsor dashboard ships with **activation, seats and consultations**, all
derivable from real tables. Not available, and asked for:

* average time spent in the app, per employee cohort
* session frequency / monthly-active depth
* feature and capability adoption

All three need a **usage event stream the app does not have**. `profile_events`
(0028) is anonymous by design (`install_id`, no `user_id`) and tracks profiling
strips only, so it cannot answer them.

Wanted for the product generally, not only for sponsors — "how long is someone
spending in the app" is a question worth answering for ParentVeda itself.
Deliberately out of the first build because every event is a privacy surface in
a product whose promise is that the employer sees nothing personal, and it
should be designed once, properly, rather than bolted onto a sponsor feature.

## 11.4 Leavers

Work-email domain verification cannot tell that someone left the company. Seats
reclaim only at renewal unless an eligibility file (an HR-uploaded roster) is
added. That feature is normally what forces a portal to exist, and it is
deliberately out of v1.

## 11.5 Company-uploaded resources are third-party content in a health product

Sponsors upload documents that render inside the app. Needs a review path and a
hard rule that they are never medical advice, before any sponsor uploads.

## 11.6 Activation codes have no sender — LAUNCH BLOCKER for sponsors

`0058` creates the one-time code, its expiry, the attempt limit and the
verification. **Nothing sends it.** There is no transactional email provider
wired to this project — WhatsApp via MSG91 is the only outbound channel that
exists, and a work-email benefit cannot verify a work email over WhatsApp.

So `request_sponsor_activation()` writes a valid code that never reaches anyone,
and `confirm_sponsor_activation()` can only be completed by reading the code out
of the database. **The activation flow is inert until an edge function sends the
email.** Stated rather than assumed, per CLAUDE.md: either both halves land or
the app half is inert and we say so.

Needs: an email provider (Resend/SES/Postmark), an edge function triggered by
the insert, and a template. Roughly a day, but it is somebody's decision which
provider.

**Do not be tempted to skip the code.** Without it, anyone who types
`someone@google.com` gets Premium — the domain list becomes free access for the
internet. The code is the only thing proving control of the address.

**Interim, so this can be demonstrated (0059).** A nullable
`sponsors.dev_bypass_code`: when set, that one sponsor also accepts a fixed
string. Everything else on the path stays real — domain match, active sponsor,
free seat, rate limit, single use, attempt limit — only the inbox is skipped.
Kept honest three ways: it is opt-in per sponsor rather than a global flag, a
check constraint refuses anything under ten characters, and a bypassed grant
audits as `activated_dev_bypass` rather than `activated`, so it is findable.
Directus cannot set it (0059 replaces the table-level grant on `sponsors` with a
column list that omits it). **Every real customer must have it null**:

```sql
select id, name, status from public.sponsors where dev_bypass_code is not null;
```

The rejected alternative was returning the real code from
`request_sponsor_activation()`. That deletes the feature while leaving the UI
looking like it still has it — which is worse than absent, because it would be
trusted.

## 11.7 The sponsored consultation credit is granted client-side

`SponsorBenefits.sync()` mints the floating credit in `BookingStore` once the
server confirms the capability. The credit is therefore a **local** fact:
`book_slot()` (0029) counts seats but does not check an entitlement, so a
modified client could book without one.

Not new — the referral reward has worked this way since `0035`, and this reuses
that counter deliberately rather than inventing a second one. But it is now the
same mechanism carrying something an employer paid for, which raises what a
defect costs.

The fix is a check inside `book_slot()`, not a better client: mark consult
offerings as capability-gated and refuse there. Deferred because payments are
still stubbed, so nothing about the money path is settled yet.

## 11.8 A sponsor admin consumes a seat

`my_sponsor_admin_id()` (0060) resolves the company from the caller's
`sponsor_members` row, so an HR person must activate like any employee. Simple,
and it means granting the plan to the wrong person still shows them nothing
unless they also control an address at that domain.

The cost: an HR contact who is not a parent takes one of the seats their company
bought, and an HR contact at an agency cannot administer at all. Acceptable at
this size; the fix is a nullable `sponsor_members.role` or a separate
`sponsor_admins` table, and it should wait until a real customer hits it rather
than be guessed at now.

## 11.9 Company events and resources have no audience scope

`sponsor_events` and `sponsor_resources` capabilities are registered and the
Employer Benefits screen renders their sections, but `programmes` (0054) has no
`sponsor_id` audience column, so there is nothing to filter by and nothing to
show. The sections say so plainly rather than showing a fabricated zero.

One additive column on `programmes` plus a filter in `programmes_published`
closes it. Left until a sponsor actually wants to run a session, because a
scoping rule invented before its first use is a guess.

---

# 12. Closed

Kept so the reasoning survives.

| Item | Outcome | When |
|---|---|---|
| **Father Mode showed one prototype day for the whole pregnancy** | Only day 143 was ever authored and `dayFor()` returned "the nearest authored day", so every father read a week-20 card from week 4 to week 40 — the same shape as the weekly bug, in the other module. His day is now derived from the mother's 259-day pool, shuffled within the week so the two rarely open the same card. The shuffle also carries the safety filter: 37 of her `grow` blocks speak to her body ("Your Body Is Already Parenting"), and no week has more than 3 of 7 flagged, so walking the week for a father-safe day always finds one. Her `nurture.content` (60 flagged of 259) is never shown to him at all; the mission is re-framed from its title and one-line remember | 2026-07-28 |
| Migrations `0043_ttc_treatment.sql` and `0044_ttc_care_pathway.sql` were written but not applied | Both applied. `0043` means treatment dates reach his phone too — a retrieval date is not one person's. `0044` is the one that mattered most: until it ran, her two pathway answers stayed device-local, so **his** app fell back to the pathway default. On an unmonitored letrozole cycle her side correctly gave the fertile window back and his still behaved as though a clinic owned the timing — the exact defect the care-pathway work existed to fix, live on the partner's device | 2026-07-27 |
| **The app could not tell a due date it calculated from one a clinic gave** | The pregnancy version of the IVF window, and the stage with real users. The Due Date Calculator has always asked *how* she got the date — last period, conception, IVF transfer, ultrasound, "my doctor told me" — and then threw the answer away. Now `DueDateSource` travels with it: three of the five are the clinic's, and when one of those is the source, gestational age is theirs. Where she used a last period, the calculator says plainly that a scan date should replace it. `unknown` counts as **ours**, because assuming a clinic gave a date we cannot account for would silence our estimate on no evidence | 2026-07-27 |
| Both pathway questions asked about clinical **events**, not the principle | "Is your clinic tracking this with scans?" and "are you on medication that controls ovulation?" are proxies. A natural-cycle FET has no scan-and-trigger and the clinic still owns the timing; a fully medicated transfer has no trigger at all; letrozole is medication and is about ovulation, so an unmonitored patient could answer yes and lose the window she should have kept. They now ask *is your clinic deciding the important dates* and *has medication taken over when it happens*, with the events demoted to an examples line so she does not have to translate her cycle into our vocabulary | 2026-07-27 |
| **Clinical ownership was implied but never stated** | The truth hierarchy says whose answer wins when two conflict. It does not say what we may do when there is no conflict at all. Written down as the companion rule: where a clinician owns a decision we may **explain** it, **remind** about it and help her **prepare** for it — never recreate, reinterpret or compete with it. Explaining what a dating scan measures is help; recalculating gestational age after one is not | 2026-07-27 |
| **Nothing said which source wins when two disagree** | The rule had been written three times, one case at a time, none aware of the others: an LH strip beats the calendar, a temperature shift beats the calendar, clinic dates beat everything. Named once as `TruthSource` (`lib/services/truth_hierarchy.dart`): clinician → lab → imaging → verified medication → her own observation → device → **ParentVeda's calculation** → population estimate. Ours is second from bottom deliberately, and a test asserts it stays there. Orthogonal to the other two rules, not a replacement: `Inferable` says *which fact*, `TimingOwnership` says *may we generate a value*, this says *which value wins* | 2026-07-27 |
| The confidence phrase appeared on **clinic paths** | Small but incoherent: the Cycle Companion said "based on your cycles so far" one screen away from a page promising we defer to the clinic. Prediction language now renders only where we predict | 2026-07-27 |
| A single trigger reminder, two hours out, with no way to say it was done | Two reminders now — four hours (be somewhere you can do this, get the injection ready) and fifteen minutes (it is now). The second is only safe because of the **Taken** tick that silences both: an exact-minute alert to someone who already did it is alarm dressed as help. Rescheduling the trigger un-ticks it, since the clinic moved the appointment | 2026-07-27 |
| Confidence ignored evidence it already held | Lowered now when the current cycle has run past its own history, or when a recorded gap is long enough to be a missed log or an anovulatory cycle. A product review suggested six screening questions instead (PCOS, postpartum, breastfeeding, perimenopause, recent contraception, recent loss) — declined, because *derive, never ask*: those would have traded her time for our comfort. A signal logged this cycle still overrides the doubt | 2026-07-27 |
| The next-milestone card had no day count | Added, deliberately **second and smaller**. Leading with a countdown makes the screen something to endure; leading with the milestone makes it an appointment she has. Leaving the number out entirely is worse — she counts it herself. "in 9 days", not "9 days remaining" | 2026-07-27 |
| No rule on showing conception or IVF success rates | Written down: **never a probability attached to this family** — no "your chance this month", nothing computed from her profile. Population statistics stay allowed where they reduce pressure rather than set a target. Enforced by a test that scans the source rather than the seed lists, and which also asserts the statistics did not simply get deleted | 2026-07-27 |
| "Who owns this clinical decision?" existed only inside TTC | Generalised into `JourneyState` (`lib/services/journey_state.dart`) — one place answering stage, pathway, clinical ownership, next milestone, and **what may be inferred versus what must come from a clinician**, across all three stages. Built as a pure read model that owns no state, deliberately **not** an engine that drives screens: per-stage screen composition would be personalising structure, which the product forbids. A test asserts the boundary and the TTC engine can never disagree | 2026-07-27 |
| **Treatment type was the wrong thing to branch on** | The first IVF fix keyed off `TtcPath` and treated everything except "natural" as clinic-run. Unmonitored letrozole and monitored-letrozole-with-a-trigger are both "ovulation induction" and need opposite behaviour, so it over-corrected — withholding the fertile window from people whose own bodies still decided the timing. Replaced with **`TimingOwnership`** (parentveda / clinicGuided / clinicControlled), derived from the pathway **plus two questions she can answer**: is a clinic tracking this cycle, and does medication decide when. Seven clinically-motivated flags, in versioned code — deliberately not a 28-flag profile, not a database table and not CMS-editable, because a clinical safety rule should not acquire a network dependency or a dropdown. The middle tier is the gain: on a natural-cycle FET her LH surge is exactly what the clinic times around, so we stop predicting but keep listening | 2026-07-27 |
| The two-week wait counted toward her **period** on a medicated cycle | Real defect. Progesterone support usually delays the period, so the app was telling IVF couples theirs was "late" — which means nothing on a treatment cycle and reads as hope. Now counts to the **beta hCG blood test** on the date the clinic gave, and the "expected period" calendar marker is suppressed on clinic paths | 2026-07-27 |
| Suppressing the IVF window left the tools honest but useless | Replaced with a **treatment cycle**: she enters the dates her clinic gave her (stim start, trigger, retrieval, transfer, beta), Today shows the next milestone, the Calendar plots them, and the trigger gets a reminder two hours before — the one moment where being precise clinically matters. The app stopped competing with the clinic and started carrying what it said | 2026-07-27 |
| An **IVF couple was shown a calendar fertility window** | Real defect, and the worst kind — it could contradict their clinic. `TtcFertilityWindowScreen` shipped in Phase 3 with no reference to `TtcPath` at all, so a medicated cycle got the same "Peak / High" reading as a natural one. Now suppressed **in the engine** (`TtcJourneyState.clinicLed`), so no surface can render one however it asks; the three cycle tools show a clinic-led card instead, and the Ovulation Companion stops asking for LH strips it would ignore | 2026-07-27 |
| TTC was reachable only via a card on the **pregnancy** home | **Decided: the stage chosen at signup is the stage you land in.** Whichever card is tapped on the auth Profile step — Trying / Pregnant / New parent — becomes `LifeStageStore` and the splash boots that shell from then on. Reads the pref directly, because the store loads async and would still be null at splash. `TtcPage` marks the app live so the Ask Veda FAB still appears for a user who never passes through `MainScaffold`. **The preview door on the pregnancy home stays** — it is how an existing account reaches TTC without signing up again, which is also why testing is unaffected | 2026-07-27 |
| TTC community could be read but not written to | `writeTtcPost` goes through the shared `CommunityStore.addPost`, with anonymity offered — the stage where people write about a loss or a diagnosis needs it | 2026-07-27 |
| Ask Veda pointers opened the whole library | `focusId` on the tests, Can I…? and products screens: the item expands and scrolls into view, a "for him" test flips the segment, and the rest of the library stays on screen | 2026-07-27 |
| TTC migrations `0041` + `0042` were written but not applied | Applied to the project. Schema/client agreement pinned by `ttc_schema_contract_test.dart` (48 assertions) — a renamed column would otherwise have failed silently, because every sync write is fire-and-forget | 2026-07-27 |
| Inside TTC the Ask Veda FAB opened the **pregnancy** Ask Veda | Real defect — it routed on "is parenting on the stack?", so a trying-to-conceive question came back framed for a pregnant woman with a meaningless `week`. Now a three-way branch on `ttc/today`, pinned by `ttc_askveda_test.dart` | 2026-07-27 |
| Ask Veda had no TTC door, context or corpus | `TtcAskVedaScreen` + `stage/chapter/ttc_path/months_trying` as additive framing (never a filter), TTC red flags incl. ectopic and OHSS, and 324 bilingual docs ingested (index 927 → 1251 chunks). Partner door sends `chapter` and never `cycle_day`, so his device cannot route around the own-row `ttc_cycles` rule | 2026-07-27 |
| `/invite/<CODE>` returned 404 | Page built and live; renders the code | 2026-07-26 |
| `/care/<TOKEN>` did not exist | Built, verified against the spec byte-for-byte | 2026-07-27 |
| Doctor's QR token was **derived** in the app while the website resolved it from `partner_referrals` | Real defect — a missing row produced a QR that scanned, looked right and credited nobody. `0040` makes the database mint tokens; the app only reads them, and prints nothing when there is no row | 2026-07-26 |
| Care token was lost through the Play install | Install referrer now carries it, told apart from a parent invite by `utm_source`, never by length | 2026-07-26 |
| `CareFrequency` and `dismissible` were configurable and did nothing | Enforced, with `CarePresenceStore` remembering what was shown and dismissed | 2026-07-26 |
| Funnel timestamps declared in 0037, never written | `0039` writes and clamps them; the funnel renders on the Impact tab | 2026-07-26 |
| Website named partners whose `status` was not `active` | Fixed — the app refuses attribution for those, so naming them promised something the product would not keep | 2026-07-27 |
| Website `ORGANISATION_TYPES` guessed three values that do not exist, missed three that do | Corrected against `CarePartnerType.known`; demo rows added for `diagnostic_lab`, `corporate`, `ivf_centre` | 2026-07-27 |
| Website invite validator accepted `4-12 [A-Z0-9]` | Tightened to exactly 7 from the restricted alphabet | 2026-07-27 |
| App package was `com.example.parentveda` | Renamed `com.parentveda.app` — Play rejects `example` | 2026-07-25 |
| Black screen across the app | `GlobalAskFab` collapsed the root Stack when hidden | 2026-07-25 |

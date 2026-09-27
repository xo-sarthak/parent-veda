# Still Open

Everything parked, undecided, or half-built — in one place, so nothing gets
quietly dropped between sessions.

**Last updated:** 2026-09-17

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

**Blocking launch:** §1.1, §1.2, §1.3, §1.4
**Blocking the sponsor programme:** §11.6 — the activation code has no sender
**Blocking real money:** §2.1, §2.2, §5.1
**Everything else** can wait without harm.

> **Numbering (2026-09-17):** sections below 100 belong to the pregnancy /
> parenting / TTC / home streams and continue the sequence; **100–199 belong
> to skilling** (Confidence is §100). Two terminals appending to one counter
> collided on §42, §58 and twice on §57/§62 in a day; a reserved block per
> stream is the fix. The committed §42 and §58 duplicates stay as they are.

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

## 1.4 `kPremiereAlwaysShow` is `true`

`lib/brand/premiere_screen.dart`. The Premiere takeover currently fires on
**every app open**, bypassing its once-per-campaign cap and any previous
dismissal.

Switched on deliberately so the flagship can be looked at — one impression per
campaign, three to six campaigns a year, and no way to see it again short of
wiping app storage made it nearly impossible to review.

**It must be `false` before launch.** The cap is not a technical limit, it is
the thing that makes a full-screen takeover acceptable at all. Seen once it is
a launch story; seen on every open it is an advert a parent cannot escape — and
this app is opened at 2am by someone who is worried, which is the wrong moment
to be sold to for the fourth time.

One line, no other change:

```dart
bool kPremiereAlwaysShow = false;
```

Tools → Brand Studio → "Show me" does the same thing without the flag, and does
not change what a real parent gets.

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

## 3.3 More entry points (Gap 4) — TTC done 2026-07-30, the rest still parked

**TTC now has one.** The positive-test transition screen offers a keepsake, and
that is the only place in the stage that does.

The reasoning is the useful part, because "add more entry points" was the wrong
framing. `MemoryType` is `{expecting, welcomeBaby}` and TTC needs no third: this
stage's final moment **is** the expecting announcement, so the card that already
existed was the right card.

`ttc_milestones.dart` has eleven milestones — first cycle logged, ovulation
learned, tests done, lifestyle tracked. **None of the other ten gets a card.** A
shareable graphic for "cycle 6 logged" would be grotesque, and more to the point
most people trying to conceive are deliberately private about it. Offering a card
at every milestone turns a private year into something with a publish button on
it. A test asserts the offer appears in exactly one file.

It is **offered, never prompted**: secondary styling, below the primary action,
absent from the confirm dialog on the way in, and worded *"Make a card, if you
want to"*. Plenty of people reach a positive test carrying a previous loss and
will not announce anything for weeks.

Still parked: pregnancy and parenting already have theirs, and no further entry
points are planned until someone asks for one.

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

## 4.2b The QR pass is done — what is left of it

Built: `partner_accounts` (0068) so an ORGANISATION is a partner in its own
right; a poster with a **print-ready A4 + cut-in-half A5 PDF** (vector QR) and
a PNG for sending; a debug workbench that walks scan → attribution without a
Play listing; and rotation with a grace window (0069). See §12 for the defects
it fixed.

Still open, and all of it small:

* **`link_partner_account` is SQL only.** Attaching a login to a hospital is a
  one-liner in the editor (`supabase/seed/link_partner_login.sql`). Fine at ten
  partners; a panel form at a hundred. Recorded in `docs/ADMIN-PANEL.md §1c-bis`.
* **No rotation UI.** `rotate_partner_token()` exists and is deliberately
  service_role. It needs a confirmation flow before any human touches it,
  because it kills printed posters.
* **`partner_token_history()` is not surfaced.** A partner can be told why their
  old code stopped working; nothing shows them yet.
* **Print PDF fonts are fetched, not bundled.** `CarePosterPdf` loads Fraunces
  and Manrope through `PdfGoogleFonts`, which downloads them. Offline it falls
  back to Helvetica — which has **no Unicode support**, so a partner name with
  an accent, or a Devanagari word in an organisation's name, would print broken.
  The load is guarded so the PDF always builds, and a fallback chain is set, but
  the honest fix before launch is bundling the two TTFs (~300 KB) as assets.
  Nothing else in the app cares, because nothing else in the app ends up on
  paper.

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

## 5.1b Rotating a QR drops the per-doctor layer — KNOWN, NOT URGENT

*Raised 2026-07-30, while building `0073`. Left broken on purpose, with a
workaround, rather than half-fixed.*

**What is fine.** `0073` gave a referral two layers: `partner_referrals.expert_id`
records WHO handed a code over, so Apollo can see which of its clinicians brought
which families (`partner_referral_breakdown()`). Aggregate for the organisation,
breakdown by doctor beside it — the same shape as `sponsor_dashboard`.

**What is broken.** `rotate_partner_token()` (`0069`) was written when a partner
had exactly ONE code, which was true of every partner that existed. It now:

```sql
update public.partner_referrals set retired_at = now(), expires_at = now() + 30d
 where partner_id = p_partner_id;      -- retires ALL of them
v_new := public.mint_partner_token(p_partner_id);   -- mints exactly ONE
```

So a hospital with a code per clinician comes back from a rotation holding a
single organisation-wide code:

```
BEFORE          cp_apollo/—, cp_apollo/arjun, cp_apollo/priya, cp_apollo/rahul
AFTER           cp_apollo/—                    ← one code, no person layer
```

**Why it is nasty rather than obvious.** Nothing errors. Rotation succeeds,
returns a token, posters keep working through the grace window. What silently
stops is the breakdown: every family arriving afterwards attributes to
`expert_id = NULL`, so each doctor's number **freezes at its historical value
and never grows again**. The figures are not wrong — those families really did
come through them — they simply stop. The person most likely to notice is the
doctor, months later, asking why their number has not moved.

**Why it was not fixed in `0073`.**

1. **It is a different kind of change.** Rotation is about invalidating things
   that are PRINTED, and the 30-day grace window is a real-world safety
   property, not a technicality. Making it remint N codes changes what
   invalidation means, and raises a question only a human can answer: *when a
   hospital rotates, does a doctor who has already left get a new code?*
   Silently dropping theirs is the right outcome or a lost one depending on why
   they left.
2. **It is a gate.** Every gate here has been through
   `supabase/seed/verify_admin_gates.sql` — each refusal path exercised inside a
   transaction that rolls back. Bundling a rotation rewrite into a migration
   about identity would ship it without that pass, and rotation is the one
   function whose failure mode is *posters on walls stop working*.

**The workaround, until it is fixed:** rotate BEFORE handing out per-doctor
codes, not after. If a rotation happens anyway, remint each doctor by hand —
the argument exists:

```sql
select public.mint_partner_token('cp_apollo', 'qr', null, null, 'arjun');
select public.mint_partner_token('cp_apollo', 'qr', null, null, 'priya');
```

**When it is fixed**, it needs its own migration and its own verification pass,
and the decision above settled first. Design write-up for the whole partner
model: `docs/BACKEND-PATTERNS.md` §12.

## 5.1c Panel work for the booking side — DEFERRED, checklist written

Raised 2026-07-30. `0072`/`0073` are run and the app works from the bundled
catalogue, so nothing is broken while this waits — but **adding a doctor is
still SQL**, which is the exact thing those migrations existed to remove.

Full click-by-click list in `docs/DIRECTUS-SETUP.md` **§4c**: register
`expert_profiles`, `programmes`, `programme_sessions`, `programme_experts`;
make `programme_experts.expert_id` a Many-to-One so the masterclass host is a
dropdown rather than a typed id; and the two traps that matter —
`takes_consults` as a real toggle, and `fee_paise` labelled **paise, not
rupees**.

Deferred by decision: testing 1:1 and 1:many end to end comes first. Do it in
the same sitting as §1b (the presentation pass), since both are Data Model work
on the same screens.

## 5.1d `programmes.price_paise` still stores minor units — minor, deferred

`0074` moved the consult fee to whole rupees (`expert_profiles.fee_inr`) because
an editor typing 800 and getting ₹8 was silent and passed every constraint.
`programmes.price_paise` was left alone.

The convention now in force, so the next column gets it right:

* **`_inr`** — whole rupees. Typed by a person, read by a person.
  `products.price_inr`, `expert_profiles.fee_inr`.
* **`_paise`** — minor units, handed to a payment gateway.
  `programmes.price_paise`.

Both are defensible; having both is the inconsistency. `price_paise` was not
changed today because it may already hold live rows, which makes it a data
migration rather than a rename, and because the same trap is smaller there —
programme prices are set far less often than a doctor is onboarded.

Fix it when programmes next get touched, or leave it: the field note is enough
for a column edited once a quarter, and it is not enough for one edited every
time a clinician signs up. That difference is the whole reason `0074` exists.

## 5.4 ParentVeda+ rework — BUILT and WALKED 2026-09-18 (signed-in half; sign-in screen not yet)

Mobbin audit #8, `docs/DOCTOR-APP-AUDIT.md`. The five tabs (Home ·
Appointments · Availability · Earnings · Profile), the email-code front door,
the ledger (`0084`) and the Earnings admin panel are built and green
(`test/doctor_app_shell_test.dart`, `test/doctor_tabs_render_test.dart`).
Walked on the Samsung the same evening as Dr Aparna (a session already on
the phone): Home, Appointments, Availability (+ a day sheet), Earnings (+ a
source screen), Profile. Six things found and fixed on the spot — the hours
line compacted to "10am–1pm, 5–8pm", a "How a consultation works" group
under Appointments' empty state (no card over blank space), the trailing
column of a row capped rather than flexed (a switch mid-row, "Obstetricia /
n"), `DcKeyValue` for label/value rows, the payout-account read made loud
(`selectAllOrNull`) so a missing table no longer nags "add your bank
account", and an unknown rate reads "—" instead of "You keep 0%". **The
sign-in screens are not walked** — that needs a sign-out and a way back in
(the Magic Link template, or the test doctor's password). What is open, in
the order it bites:

**5.4a ~~The rates are placeholders.~~ REAL since `0085` (2026-09-19).** The
user sent the Commercial Terms table; `0085_expert_share_rates.sql` retires
the placeholders and seeds it: consultations a flat **80%** (no 85% tier —
§13.0's memory was wrong), live courses **55%**, recorded courses **30%
through ours / 55% through the doctor's own code**, videos, articles and
affiliate **20%**, sponsorship as the named face **35%**, product
endorsement **10%** (10–15% per deal, override per expert). It adds a
`channel` (platform | own_code) to the rules and the ledger. **The user runs
`0085`** the way they ran `0084`.

Still not modelled, by design, each a manual row with a note until it is:
a live course with several experts ("55% pool, split by time devoted" —
`programme_experts` holds no time weights); the additional 10% for a
multi-expert sale through the doctor's own code (rides on §13.0 items 1–3);
sponsorship on the brand's own channels (a licensing fee, share 100%, fee
as gross); a co-developed product's "20% of margin" (margin is not a
column). `own_code` is never *written* yet — the trigger passes `platform`
for every booking until coupon attribution exists.

**5.4b The Magic Link email template.** Sign-in by code sends through
Supabase's **Magic Link** template, which must carry `{{ .Token }}` and not
`{{ .ConfirmationURL }}` — the same trap AUTH-SETUP §3b fixed for Reset
Password. The user does this in the dashboard; until then the code email
arrives empty and nothing on the app side can tell. Also confirm Email OTP
length is 6.

**5.4c `0084` is written, not run.** The user applies it in the SQL editor.
Until it runs, the ledger readers 404, the store keeps an empty cache, and
every Earnings number is ₹0 with its empty-state copy — correct, and not the
feature.

**5.4d Bookings still have no real money.** Buy mints an entitlement and
charges nothing, so every ledger row is `accrued → payable` on a gross the
catalogue price supplied (now recorded on the booking as `price_paise`).
When booking payment lands, the capture should flip `accrued` to `payable`
in the same transaction — a function the payment side can call;
`write_expert_earning` is the seam. The other terminal owns
`payment_service.dart` / `razorpay-*`; hand this over rather than editing
theirs.

**5.4e Payouts are manual.** `record_expert_payout()` after the NEFT, with
the UTR. Razorpay Route later = a webhook writer, not a migration. The 7th
of the following month is the policy (`next_payout_date()`), chosen by the
build, not yet confirmed by the user.

**5.4f A no-show still pays.** The trigger marks `missed` as `payable`
(consult_policy: the doctor is paid). A doctor who *themselves* no-shows is
not detected anywhere (§5.3) and would be paid too. Needs the doctor-side
session record before it can be reversed automatically.

**5.4g Programme money is capacity-based.** The trigger calls a slot with
capacity 1 a consultation and everything else a programme, then looks the
kind up in `programmes`. A compiled-catalogue masterclass with no
`programmes` row lands as `masterclass` at the booking's recorded price —
fine — but a 1:1 offering with capacity > 1 would be misfiled. None exists.

**5.4h Not built, deliberately:** the annual statement (PDF with PAN), a
chart under the by-source legend, attendee names on a class, editing the
public profile in-app (§5.1: editorial), self-serve rate negotiation.

**5.4j The Home hero (2026-09-19, audit #8b) — WALKED 2026-09-21.** Three
CC0 photographs by hour of day (`assets/doctor/`, credits in
`doctor_hero_images.dart`), the date, the greeting, one information line,
the doctor's own photograph (`expert_profiles.photo_url`, via
`DoctorSession.profile`), the first card overlapping the band, and a "How
parents see you" card. Three fixes from the walk: the first child under the
band is always a card (the eyebrow sat half on the photo); an empty source
row says the rate once, not the invitation and the rate; a ground strip
fades in over the status-bar inset as the band scrolls off, with the clock
flipping light → dark. The **sign-in screens were walked the same day**:
the code route sends (Supabase accepts; `doctor@test.com` is not a real
inbox, so no code can arrive for it), the password route signs in and
resolves. Owed: the photo credits are listed in code but not yet shown
under Profile → About; a doctor with no `photo_url` sees her initial, which
is honest but is the thing the panel should fill first; the seed has not
been run yet (`0085` has — the rows read 80 / 55 / 30 / 20 / 35 / 10).

**5.4k Home v2 (2026-09-21, audit #8c) — BUILT and WALKED with the seeded
month.** The user's two calls: the home read as plain (a stack of empty
cards), and leading with "add your bank account" was unfair. Mobbin's
seller/host homes answered both. Fixed spine: hero → next up (or the week
strip) → quick actions → this week (+ slots open, + the bookings switch)
→ set up your practice (rail, gone at 4/4) → needs you (≤3 rows, see all)
→ for you (three doctor reads, `lib/data/reads/doctor_reads.dart`) → from
ParentVeda (`0088 expert_notices`) → classes → public card. The variable
pile is `doctor_tasks.dart`, shown as the bell count, the rows and
`DoctorInboxScreen`. Owed: the seed's masterclass does not appear under
Classes (classes come from the compiled catalogue, not `booking_slots` —
the §5.1c gap); the read covers are Openverse-proxied StockSnap, to be
mirrored to R2 with the others; `0088` and `0089` must be RUN; the demo
must be re-seeded after `0089` (its backdated rows froze 0%).

**5.4l Every tab is a door (2026-09-21, audit #8d) — BUILT and WALKED.**
All five tabs open on a photograph with an eyebrow, a Fraunces heading and
a blurb, a bell with the pending count and the avatar; the sheet rides over
the photo with parallax and the clock flips light/dark at the cover point.
`DoctorMark` (`doctor_art.dart`) replaces the Material icons in every
well; switches are ink. Owed: photo credits under Profile → About; the
parallax is judged by eye, not by test. (Availability and Profile got
plates of their own the same evening — `hero_availability.jpg`,
`hero_profile.jpg` — after Home and Profile showed the same picture after
five.)

**5.4m The walk's three corrections (2026-09-21, audit §9.1) — BUILT and
WALKED.** Date as the hero's eyebrow, a sentence with a relative day, and
three figures on the photograph; the bar floats like parenting's; the bell
holds derived UPDATES (`doctor_updates.dart`, read-state local) and the
chores are one swipe rail on Home. Owed: a server-side read-state if the
doctor ever uses two phones (today it is per device); the seeded earnings
all say "just now" because the seed stamps `occurred_at = now()` — spread
them over the month when the seed is next touched; `DoctorInboxScreen` is
unreachable, delete after a week if nothing is missed.

**5.4n Three more from the walk (2026-09-21, later).** Back on any
non-Home tab returns to Home (`PopScope` in `doctor_scaffold.dart`) — a
task's verb switches a tab, so Back had nothing to pop and closed the app;
"Write" on the prescriptions card lands on Appointments → Past
(`DoctorAppointmentsTab.openOn`), where the owed ones are; the referral kit
moved onto the doctor chrome (it was the last screen in the parenting
palette — violet code, violet icons, a tinted foot panel) with WhatsApp's
own glyph on its row. Owed: the kit's card shows the care-partner demo
identity ("Dr Meera Rao · Rainbow Hospital") rather than the signed-in
doctor — `PartnerDashboardStore` resolves the partner from its own seed,
not from `expert_profiles`; join them when the partner approval flow lands
(§13.0).

**5.4o The sweep (2026-09-21, later) — DONE.** No Material icon in a well
and no parenting palette on any reachable doctor screen (audit §9.2);
prescription, poster, practice-setup and the kit are on the chrome; a
ring placement for rows that explain. Owed: the practice-setup form still
sends nothing (it never did — `DoctorOnboardingStore` records skips only);
the upload rows say so and point at partners@parentveda.com. (Moot the same
evening — see §5.4p: the form is unreachable.)

**5.4p Earnings walls, the form that asked twice, the photo (2026-09-21,
later still) — BUILT; photo NOT walked to the server.** Stat row and
attention card unboxed (audit §9.3). Practice-setup row commented out —
KYC happens before the account. The photo: `doctor_photo_sheet.dart`,
`DoctorSession.setPhoto/clearPhoto`, `SupabaseRepo.uploadPublicFile`,
migration `0090_expert_photo.sql`. **The user must (1) create the PUBLIC
bucket `expert-photos` in the dashboard, (2) run 0090,** then pick a photo
on the phone and check it lands on the profile and in the parent app's
directory. Owed: nothing crops the picture — the avatar shows a centre
square of whatever was chosen; a square crop step is the next thing if
doctors send landscape shots.

**5.4i Kept for revert, unreachable:** `doctor_home_screen.dart`,
`doctor_appointments_screen.dart`, `doctor_schedule_screen.dart`,
`doctor_impact_tab.dart`, `doctor_earnings_screen.dart`,
`doctor_profile_screen.dart`, `doctor_earnings.dart`. Delete after the walk
if nothing is missed.

## 5.2 One-to-many programmes — BUILT 2026-08-23, with two things parked

Masterclasses and cohorts. Six defects were itemised here after the
consultation audit; five are closed and the sixth is deliberately parked.

**What the group pass built** (`0079`, `livekit-moderate`,
`lib/booking/group_call_screen.dart`):

1. **A host can get into their own class.** Every join function resolved a room
   FROM A BOOKING, and a host has no booking — they did not buy a seat at their
   own masterclass. `open_session_room()` (0079) is their front door: it
   verifies them through `my_expert_ids()`, self-seeds the slot if nobody has
   booked yet (same pattern as `book_slot`), and opens **30 minutes early**
   against an attendee's ten, so a teacher can set up before anyone arrives.
   `doctor_home_screen._sessionRow` — an inert `Container` with no
   `GestureDetector` — is now the handle on it.
2. **Attendees arrive silent.** `canPublish` is no longer an unconditional
   `true`: the database decides it (`can_publish`, 0079) and the token enforces
   it, so a modified client cannot grant itself a camera in someone's class.
   `canPublishData` stays on for everyone — that is the hand-raise and the Q&A.
3. **A class renders as a class.** `GroupCallScreen` is a separate screen, so
   the 1:1 path is untouched. Speaker view rather than a grid: the host holds
   the stage, promoted speakers get a filmstrip, everyone else is a name in the
   participant list. A grid of forty tiles of forty people who cannot speak and
   have no camera on is forty pictures of nothing.
4. **Host controls that are real.** Mute-all, remove, invite-to-speak and
   end-for-everyone go through the `livekit-moderate` edge function, which
   holds the API secret, asks Postgres one question (`can_moderate_slot`) and
   calls LiveKit's RoomService. They **cannot** be done client-side: a client
   governs its own tracks and nobody else's, so a local "mute everyone" can
   only ask forty clients to mute themselves — ignored by a modified one,
   unheard by an offline one, and the host would be looking at a muted-looking
   list while a live kitchen carried on being broadcast.
   Promotion is live, with no reconnect: the alternative is dropping someone
   out of a class in order to let them speak in it.
5. **A class has a date that stays still.** Found in review, and it was the
   deeper reason a masterclass could not be hosted. A one-off slot is generated
   as `now + 5..8 days`, recomputed on every read — so asked on the 23rd the
   class fell on the 28th, and asked on the 24th the SAME SLOT (same id) fell
   on the 29th. The class never arrived; a parent who booked "Saturday" was
   shown "Sunday" the next morning; and a host's start-time was permanently
   five days in the future, so the Start button could never light up no matter
   what was built behind it.
   `booking_slots.starts_utc` is written once and never moves, so it is now the
   date whenever a row exists. With no row nobody has booked, the generated
   date stays an honest placeholder, and the host may **go live whenever** —
   seeding the row at that moment. Which is honest about where the product is:
   programmes have no scheduling system yet (§5.1c), so until they do, the
   first real event IS the schedule.
   `sessionSlotsFor()` also exists now because `slotsFor()` drops slots that
   are full or already running — right for a buyer, and it would have taken a
   host's session away at the exact moment it began.

6. **Seat counts come from the ledger.** `booking_catalog` generated
   `seatsTaken: 40 + seed % 45` from a hash of the offering id — stable between
   reads, which is exactly what made it convincing, and unrelated to whether
   anybody had booked. `ServerSlotStore` reads `booking_slots` and
   `slotsFor()` merges it. A slot the server has never heard of now reads as
   **zero taken**, which is the truth.
   ⚠️ This is visible: a new class that used to advertise "60 seats left" now
   says all of them are. That was social proof, and it was invented; reverting
   is a one-line change in `_withRealSeatCount` if it is wanted back as an
   explicit marketing decision rather than an accident.
7. **`RoomOptions`** — `adaptiveStream` and `dynacast` on, which at forty
   participants is the difference between a class and a melted phone.

8. **Group attendance is recorded against the booking.** Also found in review:
   the first cut passed the SLOT id to `record_consult_join`, which looks its
   argument up in `booking_bookings` — so it found nothing, returned null, and
   wrote no row, silently. `settle_my_bookings` would not have matched it
   either. Attendees now record against their booking; a host has no booking
   and nothing to settle, so nothing is recorded for them, deliberately rather
   than by accident.

### Still parked, on purpose

- **Recordings.** `EntitlementGrant.recordingAccess` is granted for
  masterclasses, `booking_sheet.dart` sells *"recording to keep"* and says
  *"Your recording is in My Bookings"*, and `BookingStore.ownsRecording()`
  still has **zero call sites**. Nothing records anything: there is no LiveKit
  egress, no storage bucket, no player. This needs decisions that are not
  engineering ones — where recordings live, how long they are kept, and what
  that storage costs per class — so it is a separate piece of work.
  **The copy stays**, deliberately: it describes what we intend to give.
- **The discussion thread.** Same shape. `ownsDiscussion()` has zero call
  sites and the buy sheet advertises *"private discussion group"*. Not built.

`0054_programmes.sql` and `§5.1c` (registering programmes in Directus, making
the masterclass host a dropdown rather than a typed id) are unchanged and still
the admin-panel work.

## 5.3 Gaps on the 1:1 side

Cancel/reschedule from the **parent** side · an in-app notification centre
(waiting on Firebase) · no-show from the parent's view.

**Closed by the consultation pass (2026-08-23)** — recorded so this list stays
a list of what is open:

- Role in the session (`0076`), so both apps can say who is on the call.
- The join window enforced on both sides — `joinableAt()` had no callers and
  the server never looked at the clock at all.
- A pre-join green room, with the camera/mic permission asked where a refusal
  can be explained.
- Real connection states: reconnecting, weak line, ended, retry, rejoin. A
  dropped call used to render as "Waiting for Dr. Neha to join".
- The consult clock starts when the second person arrives, warns five minutes
  from the end, and stops on disconnect.
- Wakelock, Android foreground-service permissions, iOS background audio, and
  usage strings that mention consultations rather than journalling.
- The doctor's Cancel / Mark-no-show actually writing something (`0077`) — they
  called a local-only method that no-opped for every real booking and toasted
  success anyway.
- Attendance from evidence rather than the clock (`0078`), which is what
  finally writes `BookingStatus.missed`.
- Prescriptions: the prescriber named, an arrival notification, top billing in
  My Bookings while fresh, a one-tap copy into Health → Prescriptions and the
  medicine tracker, the doctor's form prefilled so it stops inviting duplicates,
  and a write that no longer reports success when signed out.

### Still open on the 1:1 side after that pass

- ~~**Doctor schedules are device-local.**~~ **WRONG — RETRACTED 2026-08-23,
  the same day it was written.** This claimed a parent never sees a doctor's
  real hours. She does, and has since `0033`. The whole path exists:
  `DoctorScheduleStore.save()` upserts to `doctor_schedule`; the read policy is
  `using (true)` *specifically* so a parent can see when a doctor is free;
  `syncFromServer()` pulls every row; and **`lib/main.dart:191-193` calls it in
  the PARENT app at startup**, after `Supabase.initialize` has already restored
  the session — so there is not even a race.

  Worth keeping as a worked example of the failure this repo keeps hitting from
  the *other* direction. The wiring gate says "grep the call site before
  claiming something is done". The mirror of it is just as expensive: the audit
  read `DoctorScheduleStore` (local map, `shared_preferences`) and
  `booking_catalog._fromSchedule` (reads that map in-process), concluded
  "device-local", and never grepped `syncFromServer`. Two files agreed with each
  other and the third file — the one that wires them — was never opened.
  **Grep the call site before declaring something MISSING, not only before
  declaring it done.**

  The one real residue is freshness, and it is small: the sync runs once per app
  launch, so a doctor who publishes new hours while a parent's app is already
  open is not seen until the next launch. Adding it to `ContentRegistry` (which
  already refreshes on app resume) would close that. Not urgent — clinic hours
  are not edited hourly.
- **A doctor no-show is not detected.** `settle_my_bookings()` (`0078`) marks a
  session attended when the *parent* joined; if she joined and the clinician
  never did, it still reads "attended" — better than before, not the whole
  truth, and the case that most deserves a refund. Needs the counterpart's
  attendance to be trustworthy, i.e. LiveKit webhooks.
- **No in-call chat, screen share, or post-call notes/rating.**
  `canPublishData: true` is already granted and the data channel is unused.
  `ConsultResolution.freeReschedule` is computed and read by no UI.
- **A prescription cannot be amended or deleted** — `0032` grants no UPDATE or
  DELETE to anybody. The doctor's form now prefills and warns, but a wrong dose
  is still permanent.
- **No frequency field** on a consult prescription, though the parent's own
  medication form has one; doctors fold it into free-text Dosage.
- **A prescription is tied to an account, not a child.** A parent with two
  children gets an unattributed script.
- **The whole consult surface is English-only and unmarked.** `call_screen.dart`
  is worse — it is *mixed*, with three `S.now` strings among hardcoded English.
  None of it carries `_en(`, so every audit in the repo counts this surface as
  finished. See CLAUDE.md on why that is the `can_i_data` failure mode.
- `health_guide_screen.dart` still ships a static mockup with a hardcoded
  *"Prescribed by Dr. Ananya Rao in Jan 2026"*.

---

# 6. Brand Studio

Detail in `docs/BRAND-STUDIO.md`.

## 5.9 Grow — three versions live behind one Explore row

Skill Development now opens `GrowHomeScreen`, which carries a **V1 | V2 | V3**
pill (session-only, opens on V1). Built 2026-08-01 so the redesign brief could
be compared against what ships rather than argued about.

* **V1** — `DevelopmentHomeScreen`, the real screen, constructed as-is. Not a
  copy: a reimplementation would drift and the comparison would then be against
  something that never shipped.
* **V2** — the brief as written, *including* the breakable streak, the
  celebration screen and the Map/check-in removed from the home. Filing those
  edges off would have produced a V2 that was really V3 wearing the brief's
  title.
* **V3** — the reframe without the rewrite: capabilities kept, Map and check-in
  one tap down, a week that fills instead of a streak that breaks, and a sixth
  capability so self-care has somewhere to live.

Nothing was deleted. `kDevActivities` still holds its eight, the eight areas are
intact, and the old Explore row is commented in place.

### How the brief's two conflicting instructions were read

The brief says both of these, four lines apart:

> Include ● Daily streaks ● Progress animations ● Activity completion
> celebration ● Gentle encouragement
>
> Avoid gamification that feels childish.

**Reading taken (decided 2026-08-01): the guardrail names a KIND of
gamification, not gamification itself.** What it points at is childishness —
badges, confetti, cartoon mascots, points, levels. So the explicit
include-list stands and the guardrail is enforced against those devices
specifically. When a document's general line fights its specific line, the
specific one wins; the general line is usually the one written first and
thought about least.

So V2 has the streak, the celebration and a progress animation (the streak
number counting up), and carries no badge, confetti or mascot anywhere.
`grow_versions_test.dart` holds both halves, because a reading that lives only
in a comment gets quietly reversed.

**One addition the brief did not ask for:** an (i) on the streak explaining how
it works, including *"a missed day sets it back to zero"*. A number that can
reset should say so before it does, not after — otherwise a parent learns the
rule by losing fourteen days. It is deliberately not softened: "don't worry if
you miss a day" sitting above a counter that disagrees would be a lie, and a
cheerful explanation of a punishing rule reads worse than the rule alone.

### Decisions still yours

1. **Streak or no streak.** A counter that resets to zero, beside the words
   "your child's brain", punishes the parent who had a hard fortnight. V3 argues
   against it; V2 implements it. This is a product call, not a technical one.
2. **Does one of these replace Skill Development, or does "Grow" ship
   alongside it?** The brief assumes replacement; the repo's rules assume
   additive. Until this is answered, all three stay.

### The content gap, which is the real blocker

The library went from 8 activities to **47**, spanning birth to five — the
original eight were all infant activities, so a five-year-old had nothing.

It is still **thin per age band**: only 4 activities suit a 30-month-old
exactly, and 5 suit a 60-month-old. `growActivitiesForAge()` widens the window
(±0, ±6, ±12, ±24 months) until at least 14 are available, because a daily
feature must not repeat inside a fortnight — but that is a mitigation, not a
fix. **Roughly 120–150 activities is where this stops being propped up.**

Where they come from — written in-house, licensed, or generated and clinically
reviewed — is undecided and is the long pole for whichever version ships.

## 5.10 Health Wallet — two live versions behind one Explore row

Explore → "Health" and the parenting home's Health quick action now both open
`WalletHomeScreen`, which carries a version pill (session-only). Built
2026-08-01, same arrangement as Grow §5.9.

**Still undecided, and it is the same question as Grow's:** which of the two
wins, and does it replace the Health row or ship beside it. Until that is
answered both stay.

* ~~**V1** — `HealthHomeScreen`, the real screen, constructed as-is.~~
  **Retired from the toggle 2026-08-01**, once the comparison against what
  ships had been made. Commented in place, screen still on disk, Explore's
  direct row still commented — reinstating it is one line in
  `WalletHomeScreen` plus the default in `WalletVersionStore`.
* **V2** — the Health Wallet brief as written, *including* the "Healthy" status
  card and auto-creating reminders from an uploaded document. **Now the
  default.**
* **V3** — the brief's structure with two changes, both safety rather than
  taste (below).

The pill now reads **V2 | V3**.

Most of the brief already existed. Timeline, Records, Growth, Doctor Visit and
the Emergency editor are shipped screens that already match what it describes,
and all of them are reused rather than rebuilt. The genuinely new surfaces are
the **Reminders hub** and the **Emergency card**, and those are shared by V2
and V3 because the versions do not disagree about them.

### The two things V3 changes

**1. The status card does not say "Healthy".** The brief leads its home with a
green dot and that word. ParentVeda knows what has been typed into it, which is
not the same thing, and the gap is where the harm sits: a child with an
unlogged problem still gets a green dot, so the parent who most needs a nudge
is the one most reassured. V3 answers a question it can answer — *is anything
waiting for you?* — and carries a "what this card is, and is not" sheet.

Same reasoning `TruthSource` already uses: ParentVeda's own calculation sits
second from the bottom, below the mother's own observation. A computed
"Healthy" would put it at the top.

**2. Nothing is created from a document without a human confirming it.** The
brief wants an uploaded prescription to create medicine reminders
automatically. A misread dose then becomes a recurring alarm for the wrong
amount, on time, with the app's authority behind it. V3 keeps the extraction
and adds a confirm step.

Both are asserted in `test/health_wallet_test.dart` rather than left in a
comment.

### Deliberate omissions, so they are not mistaken for gaps

* **Medicine is not in the Reminders hub.** Dose alarms are set on the
  medication record itself, so the time, the dose and the alarm cannot
  disagree. The hub explains where it went rather than leaving a parent to
  conclude it is missing.
* **Vaccination is linked, not absorbed.** The brief lists it as one row inside
  Records; it is a large shipped tracker with its own schedule, reminders and
  learn-why pages. Folding it in would duplicate or strand it.
* **The emergency QR encodes the details, not a URL.** An emergency is the one
  moment there may be no signal. The trade — anyone who can see the code can
  read the card — is correct for a card whose purpose is to be read by a
  stranger in a hurry, and it carries nothing beyond the first two minutes: no
  history, no reports, no address.

### ⚠️ CROSS-REPO HANDOVER — the "Smart AI" half is not built

The brief's document-extraction (detect medicines, identify doctor, detect
visit date, classify the document) **does not exist and must not be built
here.** There is no OCR or entity extraction in this repo by design — AI lives
in the Ask Veda service, `C:\Projects\parentveda-askveda`, a separate
codebase. The upload screen says so on screen rather than faking a progress bar
that fills up to invented results.

What the service needs to add, written down so this is a handover and not a
silent gap:

* an endpoint taking an image or PDF
* returning `{document_type, medicines[], doctor, visit_date}`
* **with a per-field confidence**, because V3's confirm screen needs to show
  which fields to look at hardest

Until that exists, both versions store the document and the parent types what
they want searchable.

## 5.11 Parenting review — two passes, applied 2026-08-01

Two review documents ("parenting app changes - 1" and "- 2"), written weeks
apart. **Pass 2 overrides pass 1 where they disagree** — the clearest case being
Today's parenting tip, which pass 1 asked to fix and pass 2 asked to remove.
Held by `test/parenting_review_test.dart`.

Everything removed is **commented in place** with its screen still on disk.

### The "WhatsApp feedback" was pass 1 — RESOLVED 2026-08-01

Three items in pass 2 point at "feedback shared on whats app" (2·3 the baby
profile, 2·21 the My Child section, Products·1 the product changes). **That
feedback IS pass 1**, confirmed by the user, so all three were already covered
by implementing it. Both documents are now fully applied.

Two things surfaced when that was rechecked:

* **"Add to compare"** was already in the right place on the parenting product
  page — a row between "From verified parents" and "Compare with alternatives",
  exactly as pass 1 specifies.
* **"Across pregnancy and parenting" had NOT been done.** Only the
  within-parenting half was. Now fixed — see below.

### Judgement calls worth knowing about

* **"Remove watch tab in this phase video section" (2·6)** was read as the
  **Watch button** inside the "This phase, in a video" card — the card already
  opens the player, so the button was a second control for the thing you had
  just tapped. The other possible reading is the whole "Videos for this phase"
  rail; say so and it is a two-line change.
* **"Remove phase explanation from tools" (2·9)** was **already done** in the
  17–18 July review, when the "His Leap Window" hero came out. Asserted in the
  tests so nobody re-does it.
* **Due date "coming soon" (2·20)** was read as a bug report about the old
  Tools row, resolved by 2·18's routing rather than by adding a coming-soon
  state.

### Deliberately not built, and why

* **Birth weight does NOT adjust the expected-weight figure.** It is stored,
  asked for at registration, and shown as a fact ("Born at 3.1 kg · +3.4 kg
  since"). Shifting the WHO expected curve by a child's birth weight is a
  clinical calculation about one particular child — the class of thing
  CLAUDE.md puts behind a clinician, and where `TruthSource` deliberately ranks
  our own calculation low. **Needs clinical sign-off before it is wired.**
* **`children.birth_weight_kg` has no column yet.** `Child.fromRow` reads it
  defensively and tolerates its absence, so nothing crashes — but birth weight
  does not survive to the cloud until a migration adds it.
* **The stage switch itself.** Due date / Track ovulation ask their question
  and then say plainly that moving a family across is still being built.
  Pushing a pregnancy home over a toddler's data would be worse than saying so.
* **No short video on the daily tip.** The review allows "content OR video
  (short one)"; only content is built, because no tip has a video attached and
  a play button that opens nothing is worse than its absence.
* **The tip sources want a clinician's read.** Each of the 14 tips now carries
  a mechanism and a named body of work. They deliberately avoid precise
  citations — a fabricated-looking reference is the one error a reader cannot
  catch — but they are health-adjacent copy and should be reviewed.

### The product template across both apps

The two product pages are deliberately **not** the same code. The pregnancy one
is bilingual and carries affiliate rules, a cart, a checklist and a week
timeline that only means anything before birth; rewriting it into the parenting
one would be a rewrite of a shipped stage and would drag the whole pregnancy
commerce flow with it.

What a parent experiences as "a different template" is the section NAMES and
their ORDER, so those are aligned, with new bilingual strings:

| shared name | was, on the pregnancy page |
|---|---|
| At a glance | ParentVeda Verdict |
| ParentVeda's take | Why we picked it |
| From verified parents | What parents say |
| Compare with alternatives | Related |
| How ParentVeda reviews this (!) | did not exist on either page |

The week timeline stays — consistency is about the shared sections, and a
pregnancy page losing something useful to match a parenting page is consistency
bought at the wrong price.

**Still missing on the pregnancy side, and it is content rather than code:**
"What's inside & how it works" and "Read the research" have no equivalent data
on a pregnancy `Product`. They were not faked.

⚠️ **A mistake worth recording.** The first attempt renamed `_GuidanceCard`'s
heading to "What's inside & how it works" — but that card renders on the
CATEGORY screen, not the product detail, so it aligned nothing and would have
retitled a category's buying advice into a product's ingredient list. The order
test caught it. Reverted, with a note in place.

### Four existing tests retired

`post_pregnancy_smoke_test.dart` and `pp_ui_harmony_test.dart` each had tests
asserting behaviour this review removed. They are commented in place with a
pointer to their replacements. **Note for the other terminal:**
`post_pregnancy_smoke_test.dart` is normally theirs — it was edited only
because the review removed what it asserted.

### One real bug found while wiring

The tip pop-up fired before `DailyTipStore` had loaded, so `shownToday` read an
empty value and a parent could be shown a tip she had already dismissed that
morning — worst on a slow device, where an extra modal is least welcome. Now
gated on the store being ready.

## 5.12 The daily pop-up, and saved collections on the parenting side

Follow-up to §5.11, 2026-08-01. **Parenting side only** — pregnancy is on hold
for this by decision, and TTC is out because there is no content for it.

The sequence on app open is now: **brand takeover → today's card**. The brand
one is `await`ed, because `showPremiereIfAny()` returns a Future that completes
when its route pops; without the await both sheets land in the same frame and a
parent meets them stacked.

**The card shuffles daily** — even days something to read, odd days a short
video. Both are savable. The video plays in place rather than throwing a parent
into the Watch tab, which would lose the moment the pop-up exists to create, and
it saves into `WatchStore`, so a video saved here is the same saved video as one
bookmarked anywhere else.

Only the **quick** videos are eligible: a pop-up is a thirty-second moment, and
offering a twelve-minute masterclass in one is offering something nobody is
about to start. Twelve shorts exist, so it does not repeat inside a fortnight.

**Saved collections** now exist on the parenting side, reached from a bookmark
in the My Child header — same icon and same placement as the pregnancy home has
had all along. It owns no state: it reads `WatchStore`, `ReadingStore` and
`DailyTipStore`, so there is one saved list rather than three that drift. All
three groups render even when empty.

### ⚠️ `kDailyPopupAlwaysShow` is `true`

`lib/screens/post_pregnancy/daily_tip_popup.dart`. The card fires on **every app
open** rather than once a day, so it can actually be reviewed — seeing it once
and never again makes it impossible to look at.

Named to match `kPremiereAlwaysShow` (§1.4) so both testing overrides turn up in
one search. **Both must be `false` before launch.** Once a day is what makes a
pop-up welcome; on every open it is a door a parent has to push through at 3am,
and this app is opened at 3am by someone who is worried.

The date-keyed `shownToday` check is untouched behind the flag, so turning it
off restores once-a-day with no other change.

```dart
bool kDailyPopupAlwaysShow = false;
```

### Still not built

* **No video on the pregnancy side.** Held by decision, not by difficulty.
* **Tips are not personalised by age.** The rotation is by day-of-year, so a
  four-month-old and a four-year-old get the same tip. Fine for fourteen
  general tips; wrong the moment the set grows.

## 5.13 The four Explore redesigns, and the nav restyle

2026-08-02. Four briefs (Recipes, Recommendations, Read, Courses) describing one
page, and saying so themselves — "should feel like its sibling", "so all three
sections feel like part of one cohesive Explore experience".

So the shape is built once in `pp_explore_kit.dart` and applied four times:

    expert banner -> search -> filters/chips -> a personalised "chosen for you"
    -> horizontal sections with See more -> dedicated listing pages

`test/explore_redesign_test.dart` holds both that each screen followed its own
brief AND that all four still use the kit — the second is the one that rots
first, and it is what stops the fifth person copying a card instead of
importing one.

**Nothing was deleted.** All four old screens are on disk and their Explore rows
are commented in place.

### The stack the briefs asked for, and why it was declined

All four specify **Riverpod, GoRouter, Theme Extensions and
CachedNetworkImage**. `CLAUDE.md` refuses the first two with reasons already
taken more than once — a second state paradigm means two ways to do everything,
and the route *name* is load-bearing here (`global_ask_fab` reads it), which
GoRouter would break. The layout and behaviour of every brief are built exactly
as written; the plumbing is this codebase's. A test asserts no Riverpod or
GoRouter symbol appears in any of the five new files.

`cached_network_image` is not a dependency and none of this content is network
imagery yet, so `ExploreThumb` draws a tinted panel with the category icon.
Dropping real photography in later changes one widget.

### The bottom nav

Restyled for readability from the reference screens, **parenting only** — the
pregnancy bar is untouched, and a test asserts that.

The old bar turned the ACTIVE tab into a horizontal pill and left the other four
as an icon over an **8.5pt** label. Two problems: 8.5pt is there to be seen, not
read, and because the active tab changed *shape*, the whole row re-flowed on
every tap. Now every tab is the same shape and colour alone marks the active
one, at 11pt. Old bar commented in place.

### Content gaps, not built and not faked

* **No photography.** Every brief is "image-first" and there are no images. The
  layout is right and the pictures are missing, which is the honest half to be
  missing.
* **Per-outcome course detail.** The Courses brief wants each learning outcome
  to expand into "detailed explanation, examples, practical tips". The
  catalogue has the outcomes and not the detail, so the expansion says what it
  can rather than generating filler.
* **Beverages** has no category in the recipe data; four recipes are matched by
  id in `recipes_explore_screen.dart`. Give beverages a real category and that
  list should go.
* **Pagination.** Every brief asks for it. Catalogues are 40–90 items, so
  everything renders at once; the listing screens are structured so a paged
  source drops in without a redesign.

## 5.14 ⚠️ SHARING AN APK — the trap that already caught us once

2026-08-02. A build was sent out for review and the reviewer saw an **eight-day-
old app with the Flutter logo on it**. Three things combined, and each one is
worth knowing separately.

### 1. Flavours renamed the output, and left the old file behind

Before the doctor app existed, `flutter build apk --release` wrote:

    build/app/outputs/flutter-apk/app-release.apk

After flavours were added (31 July), the output became `app-parent-release.apk`
— and **`app-release.apk` was never deleted**. It sat in the same folder, with
the name everyone recognises, frozen at 25 July.

Worse: it can never be refreshed. With flavours defined, `flutter build apk`
*without* `--flavor` fails, so nothing ever overwrites it. It is a permanent
decoy with the most obvious filename in the directory.

Both stale files have been renamed to `STALE-*.apk.bak`.

### 2. The build number had never moved

`pubspec.yaml` said `version: 1.0.0+1` for every build ever made. The `+N` is
the Android **versionCode**, and Android only refuses an install when the
incoming versionCode is *lower* than the installed one. With every build stamped
`1`, Android could not tell two builds apart — so a July APK installed cleanly
over an August one and took the app backwards, silently.

Now `1.0.0+2`. **Bump it for every build you hand to somebody**, or pass
`--build-number=N` for a one-off.

### 3. Why `flutter run` looked fine

It rebuilds from source and installs what it just built, so it is never affected
by a stale artifact. A working `flutter run` says nothing about whether the APK
on disk is current — which is exactly why this went unnoticed.

### The commands

```
# parent app
flutter build apk --release --flavor parent -t lib/main.dart
#   -> build/app/outputs/flutter-apk/app-parent-release.apk

# doctor app (ParentVeda+)
flutter build apk --release --flavor doctor -t lib/main_doctor.dart
#   -> build/app/outputs/flutter-apk/app-doctor-release.apk
```

**Check the timestamp before sending anything.** `ls -l` on the file is a
two-second habit that would have caught this.

### Why the APK was 147 MB — and the fix

**138 of the 147 MB is native libraries.** Assets are 6.4 MB, Dart-compiled
`libapp.so` is 18.8 MB, and the rest is three copies of everything:

| ABI | size | who needs it |
|---|---|---|
| `x86_64` | 52.8 MB | **emulators only** — no phone |
| `arm64-v8a` | 46.3 MB | essentially every phone since ~2018 |
| `armeabi-v7a` | 38.9 MB | older 32-bit devices |

The big libraries per ABI are `libapp.so` (18.8), `libjingle_peerconnection`
(11.5 — LiveKit/WebRTC for consults), `libflutter.so` (11.0) and
`libbarhopper_v3` (4.7 — ML Kit, for the QR scanner). All four are real
dependencies; none can go without removing a feature.

So the only lossless saving is **not shipping three ABIs in one file**:

```
flutter build apk --release --flavor parent -t lib/main.dart --split-per-abi
```

That writes one APK per ABI. **Send `app-arm64-v8a-parent-release.apk`** — it
is the right one for essentially any phone made in the last several years, and
it is roughly a third of the combined size. Nothing is compromised: a split APK
contains exactly the code that device would have used anyway.

### ⚠️ THE STALE AOT SNAPSHOT — the second, worse trap

2026-08-02, found after two APKs shipped with a correct launcher icon and
days-old UI. That pairing is the signature, and it is worth memorising:

> **Android resources rebuilt. The Dart did not.**

Proved by hashing the compiled Dart out of two APKs built twelve hours apart,
with real code changes committed in between:

```
app-doctor-release.apk        08-02 00:41   caccd8d5…  9,831,312 bytes
app-arm64-v8a-doctor-release  08-02 13:39   caccd8d5…  9,831,312 bytes
```

**Byte-identical.** `libapp.so` — the AOT-compiled Dart, i.e. the entire app —
had not been regenerated for days, while `flutter build` reported success every
time and the icons and resources updated correctly on each run.

That is why it went unnoticed: everything about the build LOOKED right. The file
was new, the timestamp was current, the size was plausible, the icon was
correct. Only the part that matters was old.

**The fix is `flutter clean` before a build you are going to share.** After it,
the parent snapshot went from 18.8 MB to 20,054,928 bytes — i.e. it actually
recompiled.

**Cost:** a clean release build takes ~30 minutes for three ABIs, against ~2
minutes incremental. Worth it only for builds that leave the machine; keep using
incremental builds and `flutter run` for yourself.

**Root cause not established.** The observable fact is solid — identical bytes
across changed source — but exactly which cache key failed to invalidate is not
known. Candidates: Flutter's `.dart_tool/flutter_build` dependency hashing, or a
flavour/target key collision between `--flavor parent -t lib/main.dart` and
`--flavor doctor -t lib/main_doctor.dart` sharing one cache. If it recurs,
that pair is where to look first.

### How to check an APK before sending it

Timestamps lie here; hashes do not.

```
unzip -p <apk> lib/arm64-v8a/libapp.so | md5sum
```

Different from the last one you shipped → the Dart really rebuilt. Identical
after you changed code → the cache is stale, run `flutter clean`.

### Still worth doing

* The build number is manual. A CI step, or a pre-share script that bumps it,
  would remove the one thing here that depends on remembering.
* If a tester's phone ever refuses the arm64 build, they are on a 32-bit
  device — send the `armeabi-v7a` one instead. Nothing else changes.

## 6.1 Native Discovery breadth — **manual tagging DECIDED 2026-07-31**

Manual it is, and the reason is now on record: two wrong pairings had already
shipped, both from a tag typed without reading the content around it.

* a paneer cutlet recipe → a peekaboo cloth book
* a wooden grasping ring reco → a white-noise soother

An off-topic product is *worse* than no product. A missing link is invisible; a
wrong one teaches a parent the row is an advert, and after that she stops
tapping the ones that are useful. Automatic keyword matching would have
produced exactly these, faster.

Both fixed. Coverage now follows a stated rule rather than taste — **every
recipe whose age band opens at 6 months carries the weaning spoon set, and
nothing older does** (8 recipes), so a new recipe inherits the decision instead
of re-arguing it. `test/native_discovery_test.dart` holds all four content
types — recipes, articles, videos, recommendations — and fails a pairing whose
subject never appears in the content's own words. The first version of that
test only checked recipes, which is precisely why the reco mis-tag survived.

**Still open, and it is a catalogue problem, not a tagging one:** `Feeding` has
only three products (`bottle`, `spoons`, `steriliser`), so every one of the 28
recipes can honestly point at one thing. Widening this means adding genuinely
food-adjacent products first — a suction bowl set, a bib, freezer purée trays,
a high chair — and *then* tagging. Adding more tags to the current catalogue
would only put the same spoon set on more pages.

## 6.2 Sampling fulfilment — **DONE 2026-07-31**

`0071_brand_sample_claims.sql`. The claim now saves, the fulfilment desk is a
Directus collection (select + update: read the address, mark it posted), and
the brand gets `brand_sample_counts()` and nothing else.

What is left is operational, not code: **nobody is watching the desk.** A claim
lands and sits at `status = 'claimed'` until a human opens Directus and posts a
parcel. Before running a real campaign, decide who does that and how often.

## 6.3 ParentVeda Certified
Only a `certified` bool exists. The visible half — badge, a "what Certified
means" page, published criteria, one demo certified brand — is unbuilt and is
pure front-end. Must never be sellable.

## 6.4 Partner logos — placeholders in place 2026-07-31

Seven generated wordmark tiles now sit in `assets/brand/partners/`, in each
brand's real colour, so the `logoAsset` path renders for the first time instead
of always falling through to the monogram.

They are **not the real trademarks**, deliberately. Replace with licensed assets
from contracted partners before anything public-facing, and delete any brand you
have no agreement with — the README in that folder says the same.

Do **not** retry random web image sources for these. Already tried, inspected
and rejected: two were other brands' vintage adverts, one was a real child's
photo.

---

# 7. Admin panel (Directus)

**Update 2026-07-30 — it exists now.** Directus is live on Render as the
`directus_cms` Postgres role (`0045`), ~20 collections registered, and the
boundary is proved: `permission denied for table journal_entries`. The text
below is kept because the reasoning for delaying it was right; what follows are
the gaps that remain.

## 7.0 Publish reaches two of three readers

One write, three readers, and only one of them is automatic:

| Reader | How it learns | State |
|---|---|---|
| **The app** | reads Supabase directly | ✅ nothing needed |
| **The website** | caches 60s; a webhook flushes it | ✅ **done 2026-07-30** — `POST /api/revalidate` + a non-blocking Directus Flow. `REVALIDATE_SECRET` set in Vercel and verified |
| **Ask Veda** | keeps its OWN pgvector index | ⛔ **blocked — see below** |

### The Ask Veda Flow is blocked on deploying Ask Veda

`POST /reindex` exists (Phase 8, guarded by `reindex_secret`), and as of
2026-07-30 `recipes`, `reads` and `products` are registered in the ingest's
`SOURCE_SPECS`. Both halves are built and tested. **The Flow still cannot be
created**, for a dull reason: Ask Veda has never been deployed.
`lib/ask_veda_config.dart` points at `http://127.0.0.1:8000` over an
`adb reverse` tunnel, and the repo has no `render.yaml`, `fly.toml` or
`Procfile` at all. Directus runs on Render and cannot reach a laptop.

**Until then, content reaches Ask Veda only when someone runs the ingest by
hand** (`python -m ingest.ingest`). Fine at the current publishing rate; a real
gap the moment publishing is weekly, because the failure is silent — an article
that was never indexed is never found, and the only symptom is Veda saying "I
don't know" about content we published ourselves.

Phase 9 is bigger than pointing a Flow at a URL: it needs a host chosen, a
deploy config written, and somewhere for the embedding model to live (it
downloads on first run, which is a cold-start problem on a free tier).

## 7.1 The panel labels rows badly out of the box — CHECKLIST IN THE RUNBOOK

**Deferred by decision 2026-07-30** ("very repetitive, I will do this at the
very end"). The full checklist — display templates, icons, columns, presets —
is `docs/DIRECTUS-SETUP.md` **§1b**. `content_posts` is done as the worked
example; the rest remain, and that table grows every time a collection is
registered — it is the running list, so add a row there rather than here.

⚠️ **`brand_sample_claims` is not optional to template.** Its first text column
is `address`, so without one Directus names every row by a fragment of a home
address, everywhere a row is named.

**Do it before anyone else gets a login**, for a reason that is easy to miss:
the column layout is stored **per user**, so setting it up now fixes only your
own view. A new Editor gets Body / Category / ID back. Only the Display
Template and a role-blank Preset apply to everyone.

Raised 2026-07-30 from a real attempt to find an article. A collection with no
**Display Template** makes Directus pick the first text-ish field, so
`content_posts` names every row by the first 30 characters of `body` — three
different articles all reading `If you're reading t…`.

Fix is per collection: Display Template (`{{title}}`) plus a sensible list
layout. The table of templates for every registered collection is in
`docs/DIRECTUS-SETUP.md`. **Do it when a collection is registered, not later** —
a bad template also poisons every relation picker that points at that
collection.

## 7.2 Content edits have no history in the database

Both a developer (via SQL) and an editor (via Directus) can write the same
`content_posts` row. **Last write wins, silently.** Directus's Activity &
Revisions covers its own edits and reverts; a SQL write bypasses Directus
entirely and leaves no trace anywhere.

Turning on Activity & Revisions closes half of it. Closing it properly means an
audit trigger on the content tables in Postgres — the same reasoning as
`admin_audit`: *the panel is a convenience layer, the database is the
authority*, so history belongs where the writes actually land.

---

## 7.3 Original note — why the panel was delayed

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

**The after-the-fact prompt now exists (2026-07-30).**
`PregnancyController.dueDateMayBeStale` is true when the date is OURS
(`lastPeriod` or `conception`) and she is past **week 14** — a dating scan runs
six to fourteen weeks and the combined/NT scan sits at eleven to fourteen, so
past fourteen she has had one if she was ever going to. Asking earlier would be
asking about an appointment she is already worrying about.

Surfaced as a quiet line under the **Due Date Calculator tile** in Tools, not as
a banner on the home. Nothing is wrong today — the app holds one date and derives
everything from it consistently — so this is a correction *opportunity*, not an
error, and the tile she opens to change the date is the moment the sentence is
useful. A test asserts the home never carries it.

`unknown` is excluded deliberately: it means an older install whose origin we
cannot account for, and telling someone to "update" a date we never recorded the
source of is a guess wearing a suggestion's clothes.

Worded as an offer — *"If you have had a dating scan since, its date is the
better one"* — never a correction. `TruthSource` puts her clinician above our
calculation, and there is no clinician in the room here.

**What is still not done:** `Inferable.growthExpectation` /
`developmentalStage` remain unread, and nothing yet reconciles two dates if she
enters a second one.

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

## 9.6 `TtcInsight.forPartner` is an inert flag — CLOSED 2026-07-30, leave it

It defaults to `true` and nothing anywhere sets it `false`, so the partner
screen's `where((i) => i.forPartner)` selects all twenty-five insights. Not
broken — the intent is documented on the field — but it is currently a config
option expressing a state the product does not have, which is the shape this
codebase has said it does not want.

**Decided: leave it as is.** This was code tidiness written up as an open
point, which was a mistake — it belonged in a comment, not on a list beside the
FAB.

The reasoning for keeping it: TTC is still in development, not testing. New
sections are coming, and a flag already threaded through the model and the
partner screen is cheaper to have in place than to add back the day content
genuinely diverges. Dropping it would change nothing any user sees, so the only
argument for dropping was that the code implies a curation nobody authored — and
that is a comment's job to explain, not a refactor's.

**Do not raise this again.** If insights are ever written that are hers alone,
set `forPartner: false` on them and the filter starts doing the work it was
declared for.


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

* **The Hindi is transliterated Hinglish**, matching the house style *at the
  time it was written*. That style was dropped on 2026-08-03 for Devanagari,
  and the father copy has **not** been migrated — so this is now two jobs, not
  one: convert the script, and then get the native read it always wanted. Not a
  translation check, a *does-a-father-actually-talk-like-this* check. Doing the
  script conversion first would waste the reader's pass on copy that may not
  survive it.
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

## 11.0 What the benefit contains — DECIDED 2026-07-30 (`0067`)

Left open for weeks because it is a product decision, then taken because an
engine that can express anything and currently expresses nothing is not
flexibility, it is an unfinished product.

**An activated employee gets:**

1. **Two one-to-one consultations a year.**
2. **Every masterclass, included.**
3. Nothing else that is bounded.

**Why two, not one or unlimited.** One is a sample: it gets saved "for when
something is really wrong", never spent, and HR sees a take-up number with
nothing behind it. Unlimited is unbudgetable — a consultation is a real hour of
a real clinician, so cost is linear and the sales conversation becomes about
risk instead of value. Two is enough that the first gets spent on something
ordinary, which is when somebody learns the benefit is real.

**Why masterclasses are unlimited.** Recorded, one-to-many, marginal cost of the
tenth attendee ≈ 0.

> **The rule, for the next tier:** meter what costs you per use, include what
> does not. Credits for clinician hours; open access to recordings. A model that
> ignores this either bleeds on the hours or insults people over the recordings.

**Removed from the plan:** `sponsor_events` and `sponsor_resources`. `0058`
seeded them and there is nothing behind either — `programmes` has no sponsor
audience scope, so two sections rendered "nothing scheduled yet". *A capability
granting access to an empty set is worse than an absent feature, because
somebody reads it as a feature.* Re-add the row the day a sponsor runs a
session (§11.9).

**Note what `0067` does NOT do:** it locks nothing for existing users.
Masterclasses stay free. The difference the employer plan buys is the
consultations — a thing free users never had, not a thing taken away. Metering
masterclasses later is deleting one row; doing it in that migration would have
been a product decision smuggled into plumbing.

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

## 11.2 "Download" should be a report, not an export — BUILT

**Update 2026-07-30.** `/portal/report` on the website: one page, same shape
every month, print-to-PDF. Headline sentence, four figures, a month-by-month
table, and a section stating what the report does *not* contain.

Two decisions worth keeping:

* **A page, not a CSV.** A CSV makes formatting HR's problem, so what leaves the
  building is a spreadsheet pasted into an email — and whatever the reader
  concludes from raw columns is what we shipped.
* **Print-to-PDF, not a generated PDF.** A server-side PDF means a rendering
  library, a font pipeline, and a second layout to keep in step with the page.
  The browser already has all of it.

The limits section is not modesty. A report listing only what it can prove
invites the reader to assume everything else is being watched.

Still open: a **monthly email** of it, which needs the same provider as §11.6.

### Original reasoning

HR forwards numbers to leadership far more often than they browse. A raw CSV
makes that their formatting problem. The deliverable is a consistent, branded
report — same shape every month, ready to forward. Treat it as a first-class
output rather than an afterthought on whichever screen wins §11.1.

## 11.3 Usage analytics — BUILT (0065), and the earlier position was wrong

**Update 2026-07-30.** `usage_events` records session shape per user;
`sponsor_engagement()` exposes monthly totals with the same suppression.

The original text below argued for *not* building it, on the grounds that the
rows would become a liability. **That was too strong, and the correction is
worth keeping** — there is no technical reason a per-user measurement cannot be
exposed only as an aggregate, and `sponsor_dashboard()` has done exactly that
for consultations since `0060`. Refusing to measure was refusing to answer a
question ParentVeda needs for itself: you cannot improve a product you cannot
see being used.

So it is built **for ParentVeda**, with the sponsor view as a downstream
consumer. That order is the design: shaped around HR's questions it would answer
those and nothing else, and the day you want to know why people drop off at week
12 you would start again.

Four constraints hold the line, and they are the reason this is not a
surveillance product:

* **Insert-only.** No select grant, no select policy — same shape as `0028`. A
  client cannot read the log back. *If a select policy ever appears there, the
  behavioural log becomes downloadable.*
* **No content, only shape.** `surface` is a screen name from a closed list
  (`UsageSurface` in `lib/services/usage_events.dart`). There is no column for a
  query, a question, an article or an answer — so "she opened Ask Veda" is
  recordable and "she asked about bleeding at week 9" is not.
* **Never granted to the CMS.** Not a form, not a report, not an export.
* **It expires.** `prune_usage_events(400)`. Not scheduled by the migration —
  a delete job that starts running the moment a migration lands is how a
  backfill disappears overnight. Turn it on deliberately.

**No per-surface breakdown is offered to a sponsor.** "Your people spend most of
their time in Health" sounds harmless and narrows down who is worried about what
in a small team. ParentVeda answers that from the raw table; the employer does
not get it at all.

Still open: the **product-side analysis surfaces**. The queries are written at
the bottom of `0065` (weekly actives, median session, retention cohorts) but
nothing renders them — they are run by hand in the SQL editor. That is fine
until it isn't.

### Original text, kept because the reasoning is still half-right

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

## 11.4 Leavers — MOSTLY SOLVED by the roster (0061)

*Original text: domain verification cannot tell that someone left, so seats
reclaim only at renewal unless an eligibility file is added.*

**Update 2026-07-29.** The eligibility file exists: `sponsor_eligible_people`,
loaded from the sheet HR sends, and it **outranks the domain rule** — a sponsor
with a roster is judged only on the roster, so removing a leaver from the sheet
actually removes them rather than letting them fall through to their still-
matching email domain.

The rule is derived, not configured: *if a sponsor has a roster, the roster is
the truth; if they never sent one, the domain is.* An `eligibility_mode` column
with three values was the obvious alternative and was rejected — two of those
values would never be chosen, and a config that can express more states than the
product has is a bug surface.

**What is still open:**

* **Revoking eligibility does not revoke a live benefit.** Taking someone off
  the sheet stops future activations; withdrawing the Premium they already hold
  is `remove_sponsor_member()`, a separate deliberate act. That separation is
  intentional — a benefit should not vanish because someone edited a
  spreadsheet — but it means a leaver keeps access until someone acts.
* ~~**Nothing reconciles a re-uploaded sheet.**~~ Built in `0064`, as two
  functions on purpose: `sponsor_roster_stale(sponsor, latest_batch)` reports
  what *would* be revoked and how many of those people are currently using the
  benefit; `sponsor_roster_revoke(sponsor, emails[], actor)` acts on an
  **explicit list**. It takes the addresses rather than recomputing the diff, so
  the thing approved and the thing done are the same thing. Set `import_batch`
  on every CSV upload or the diff has nothing to compare against.

  Deliberately never automatic: *"forty people left"* and *"the CSV was
  truncated"* are identical input, and only a person can tell which. **When two
  very different intentions produce the same bytes, do not infer the
  intention.**

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

## 11.7 The sponsored consultation credit is granted client-side — FIXED (0066)

**Update 2026-07-30.** Credits are a server-side ledger. `book_slot()` claims a
real row or records the booking as `unpaid`; a client can no longer mint one.

The questions this forced answers to are the fixed ones — the answers may
change, the questions will not:

| Question | Answer taken | Where |
|---|---|---|
| Counter or ledger? | **Ledger. One row is one credit.** Nothing adds or subtracts, so there is no race to lose | `consult_credits` |
| Double-spend? | A unique partial index on `booking_id`. Impossible, not unlikely | `consult_credits_booking_idx` |
| Replay / re-sync? | `(user_id, grant_key, seq)` unique. Granting twice grants once | `grant_consult_credits` |
| Cancellation? | Credit returns if cancelled **≥ 4h** before; spent otherwise. Config row | `booking_policy.credit_return_hours` |
| Leaver? | **Unspent voided, booked and attended untouched** | `void_consult_credits` |
| Unpaid booking? | Allowed, and **recorded as `unpaid`**. Enforcement is one condition away | `booking_bookings.paid_by` |
| How does the server know a consult from a class? | **`capacity = 1`** — a number it already holds and already trusts | `book_slot` |

Still open:

* **Referral rewards still grant locally.** `ReferralStore` calls
  `grantFloatingCredit()`; it should call `grant_consult_credits(..., 'referral',
  <reward id>)` server-side when a reward qualifies. The ledger is already the
  right shape; this is a two-hour job and the same hole, one source over.
* **No money moves.** A purchase becomes
  `grant_consult_credits(..., 'purchase', <razorpay payment id>)`. That is why
  this was built now rather than twice.
* **`paid_by = 'unpaid'` is not refused.** Deliberate: payments are stubbed and
  refusing today would break every existing booking. Flip it when Razorpay lands.
* **A scoped credit for a multi-seat offering cannot be spent** — the
  `capacity = 1` test blocks it. Nothing grants one yet; a bought class pack
  would need the exact-scope case exempting.

### Original text

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
| **An organisation could never see its own numbers or its own QR** | Every partner-facing read authorised through `care_partners.expert_id -> expert_accounts -> auth.uid()`. `expert_id` is nullable by design and `kExperts` is a compiled catalogue no institution belongs in, so a hospital, IVF centre or lab could hold a token, be named correctly on `/care/`, and then see nothing at all — its kit reading "not set up yet" permanently. 0068 adds `partner_accounts` and one authorisation helper accepting both routes. `expert_id` now means only "this partner also consults" | 2026-07-30 |
| **A signed-in organisation would have shown a stranger name as its own** | `doctorInfoById()` falls back to the FIRST doctor in the catalogue for an unknown id, so both the partner home header and the profile would have rendered some other doctor's name and credential. Same class as the `expert_roster` bug. Both now resolve a doctor only when the session actually consults, and otherwise show the partner's own name, type and city | 2026-07-30 |
| **The app chose which token was current, client-side** | It sorted `partner_referrals` and took the newest ACTIVE row. A rotated token stays active through its grace window, so that sort would have handed a partner a code on its way out — and they would have printed it. `my_partner_token()` (0069) decides on the server, excluding retired and expired | 2026-07-30 |
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

---

# 12. Deferred out of the 2026-08-04 refinement pass

The device walk in `docs/REFINEMENT-PASS.md` produced fourteen questions. Most
were answered and built. These are the ones deliberately parked, recorded here
so they are not lost between now and launch.

## 12.1 Child Snapshot and the Grow domain cards are hardcoded for a 4-month-old

`my_child_screen.dart` (`_snapshot()`) and the four Grow domain cards carry
literal prose — "a first roll any day now", "coos stretching into aah-goo",
"solids open up around 6 months" — regardless of the child's actual age. On a
newborn's profile they sat directly beneath a phase card correctly reading
"0–4 weeks".

**Parked on purpose.** The age-banded content for the parenting stage does not
exist yet; that writing is ongoing. Hardcoding is the honest interim, because
the alternative is deriving prose we do not have.

The *numbers* were a different problem and are fixed: Vaccination and the
product comparison had the age typed in as "4 months" while
`ChildProfileStore.ageLabel` already derived it correctly. Those now ask.

**When the content lands:** the shape needed is one entry per domain per age
band, keyed the way `pp_phases_data.dart` already keys phases. The snapshot then
reads the band for `ageInMonths` instead of a literal list.

Also still literal: `journal_v2/jv2_data.dart` → `jvChildAge = '2 years, 4
months old'`, part of the Journal demo world (see 12.2).

## 12.2 My Journal is a demo, with the real path written and commented

Greets "Priya", child "Aarav", entries dated 2025. **Decision: it stays a demo
for now**, but the real-data code sits beside it commented out, so shipping is a
comment swap rather than a rewrite. See `journal_v2/jv2_data.dart`.

## 12.3 Doctor practice setup is a walkthrough, and stays one

`doctor_onboarding_screen.dart` has no controllers: nothing typed is saved, the
chips do not select, the three Uploads are dead, and Finish pops silently. Text
also bleeds between steps, because the fields are bare `TextField`s at the same
position in the same list and Flutter reuses their editing state.

**Decision: leave it.** Real state is only worth building against a place for
the submissions to go, and that is the admin panel.

**Blocked on `docs/ADMIN-PANEL.md`.** What it needs from there:

| The app must send | The panel must provide |
|---|---|
| Profile, qualifications, council registration | A queue with approve / reject / request-changes |
| Three document uploads (degree, council, identity) | Storage + a viewer, and a rejection reason |
| Payout details (account, IFSC, PAN) | A verification step separate from the profile one |

Until that exists, uploading is a submission to nowhere. The screen's own header
comment already says approval "must never live in the app the applicant
controls" — which is right, and is exactly why this waits.

## 12.4 Still open from the pass, untouched

- **Placeholder art and video.** Every Products/Recipes/Watch thumbnail, and the
  one playable clip. Waiting on the Cloud Player/CDN setup.
- **Demo signals kept deliberately:** community view counts, a pre-set
  "Following", the Nuskhe review-panel claim, "ParentVeda-verified purchase
  reviews". All must become true or go before launch.
- **Brand Studio's real brand names** in the user-facing Explore drawer.
- `kPremiereAlwaysShow` and `kDailyPopupAlwaysShow` are still `true`.
- **Pregnancy tools inside the parenting app** — Memories' "We're Expecting",
  Yoga leading with prenatal/IVF, Baby names. No restructuring for now.

## 13.0 An expert's code means two different things — DECIDED 2026-08-04

Raised while designing "let the parent type a doctor's code". The flow is one
remembered code, offered at two moments and editable at both:

| Situation | At sign-up | At course purchase |
|---|---|---|
| Came via QR | pre-filled | pre-filled, same code |
| Typed it manually | typed | pre-filled from that |
| Skipped | empty, skippable | empty, can type it here |

Clean as a UI. The trap is that the same typed string **means something
different at each point**, and the commercial terms already price them apart.

**At sign-up it is ATTRIBUTION** — "Dr Neha introduced me." Permanent,
`first_touch`, a 90-day earning window. Built: `partner_referrals`,
`mint_partner_token()`, `care_partner_engine.dart`, `care_commission_rules`,
`commission_ledger`, the poster PDF, the partner dashboard. The only missing
piece is a screen to TYPE it — `holdToken()` has four call sites and three are
the install referrer, the deep link, and a debug screen.

**At purchase it is a COUPON** — "this SALE came through Dr Neha," which the
Commercial Terms workbook prices differently:

- Single-expert course through ParentVeda channels — **0.70 / 0.30**
- Single-expert course through **her own coupon code** — **0.45 / 0.55**
- Multi-expert via a specific expert's code — *"20% additional paid to the
  expert applying her coupon code"*

`programme_coupons` (0054) exists with a `preview_programme_coupon()` validator,
is correctly not public-read, and has **no `expert_id` column** and **zero
references in the app**. So today it cannot record whose code was used, which is
exactly what those rows need.

### THE DECISION: split, not refuse and not move

A parent attributed to Dr A who enters Dr B's code at checkout:

* **Dr A keeps the standing attribution.** `first_touch` is not overturned by a
  later code — that rule exists so a partner who did the introducing is not
  displaced by whoever happened to be nearest at the till.
* **Dr B earns the coupon share on THAT SALE ONLY.** Nothing about the parent's
  standing relationship changes.

Rejected: **refuse** (then why is the field editable?) and **move** (contradicts
`first_touch`, and rewards the last touch over the first).

### What this needs, when it gets built

1. `expert_id` on `programme_coupons`, so a redemption knows whose code it was.
2. A per-sale attribution row — the ledger currently models a partner earning on
   an attributed parent, not on a single transaction.
3. Commission sources for the workbook's other rows: `care_commission_rules`
   allows `consultation | masterclass | cohort | subscription | product |
   course | referral | other`, with nothing for **ad revenue**, **affiliate**
   or **brand sponsorship**.
4. ~~⚠️ `rate_bps` is capped at **5000 (50%)**…~~ **ANSWERED 2026-09-18 by
   `0084`:** the delivery share is its own table, `expert_share_rules`,
   `share_bps` to 10000, per-expert override and a `min_monthly` tier — the
   two-tables conclusion, built. `care_commission_rules` keeps its cap for
   referrals.
5. ~~The 80% currently lives in `kDoctorSharePct`…~~ **ANSWERED 2026-09-18:**
   `kDoctorSharePct` is referenced only by the retired
   `doctor_earnings_screen.dart` (`test/doctor_app_shell_test.dart` holds
   that). Rates are rows; the ledger freezes the one that applied into every
   earning. ⚠️ The seeded rates are **placeholders** until the workbook is
   found — see §5.4.

Items 1–3 still stand. None of this blocks the code-entry screen, which can
ship against attribution alone. Items 1–3 block paying a *coupon* share
correctly; the *delivery* share is now paid correctly.

---

## 14.0 The clinical-review list — OPEN, and it needs a named clinician

Things this app says that are **medically load-bearing and reviewed by nobody**.
They are collected here rather than left as `REQUIRED_TO_CONFIRM` comments
scattered across files, because a comment in a Dart file is not a queue and
nobody is working from it.

⚠️ **This list is not a research task.** Every item below has already been
researched as far as public sources allow; what is missing is a person with a
licence saying yes. Adding more research to it does not shorten it.

### 14.1 Preeclampsia sends no personalisation signal — DELIBERATE, needs a ruling

`PregCondition` gained seven values on 2026-08-20 (see
`docs/CONDITION-SIGNALS-HANDOFF.md`). Preeclampsia was **not** one of them, and
this is the one omission on that list that is a clinical judgement rather than a
structural rule.

**The tempting mapping is `hypertension`, and the case against it:** preeclampsia
is raised blood pressure **plus** proteinuria **plus** organ involvement. Treating
the two as one thing would have Ask Veda answer a preeclampsia question with
high-blood-pressure framing — on the most dangerous condition in the library, in
the direction of under-stating it.

**The case for mapping it anyway:** she currently gets nothing. A woman who has
declared preeclampsia gets no BP-aware content and no Ask Veda context at all,
which is its own kind of wrong.

**Three options, for whoever rules on it:**

1. **Leave null.** Status quo. Honest, and she gets nothing.
2. **Map to `hypertension`.** She gets BP-aware content immediately; the app
   treats the two as the same condition.
3. **Give it its own enum value.** Most correct. Costs a second cross-repo round
   with the Ask Veda service, which must then hold preeclampsia-specific
   retrieval and framing rather than inheriting hypertension's.

**Recommendation on the record: (3), but only alongside real corpus coverage.**
Recognising the string without content behind it produces a confidently framed
answer with nothing under it, which on this condition is the worst of the three.

⚠️ **Do not map it service-side as a workaround.** That puts the app and the
service in disagreement about her, with no way for either to detect it.

Enforced by `test/conditions_personalisation_test.dart`, which fails the build if
preeclampsia gains a signal — so this stays a decision rather than drifting.

### 14.2 The crisis helpline is wired but unconfirmed

`Tele-MANAS, 14416` (fallback `1800-891-4416`), in
`lib/data/mind_mood_data.dart`, flagged `REQUIRED_TO_CONFIRM`.

It replaced KIRAN (`1800-599-0019`), which has been merged into Tele-MANAS.
**Research is done; sign-off is not.** The general lesson is worth keeping: a
helpline is the one constant in an app that can go stale without anybody
touching the code — the number was real, the constant was correct, no test could
fail, and it had still stopped being the right number.

### 14.3 Mind & Mood copy is counsellor-unreviewed

Six "more than a mood" articles, all six self-check questions, and the safety
question that routes to the crisis screen. Export is written and ready at
`docs/MIND-MOOD-REVIEW.md`; it has not been sent.

### 14.4 The 27 condition pages have had no clinical read

The whole library — `lib/data/conditions_data.dart` — was written from research,
not reviewed. `callNow` lists are the highest-stakes part: they decide what makes
a mother pick up the phone today, and both directions are harmful.


---

# 15. TTC V3 — the level-map pass

Everything left after building the seven doors against
`parentveda-level-map-checklist.xlsx` and then walking the built stage on a
phone. Nothing here blocks a build; three of the five are content or production
rather than code.

## 15.1 Two surfaces share some facts, and can drift apart

⚠️ **This entry has been wrong twice, and both wrong versions are worth keeping
here, because the mistake is the reusable part.**

**First version: "the chapter copy is unreachable."** False.
`ttc_journey_map_screen.dart:180` opens any chapter, so a woman can browse to
Trying Together whenever she likes.

**Second version: "a door cannot aim into a chapter, so it needs
`ttc_chapter/<id>`."** Also false, and this one had a fix attached to it, which
is worse. **No door anywhere opens the chapter reader.** The hubs and journeys
point only at `ttc_read/…`; `ttc_chapter` appears in three brackets' `content`
declaration — a data-model line, not a rendered door — and on the home's "where
you are" card. Nothing was trying to aim, so there was nothing to fix.

**What both versions got wrong was the category.** A chapter and an article are
not two attempts at the same thing:

| | what it answers | when she meets it |
|---|---|---|
| **chapter** | *where am I right now* | because the engine has her there |
| **article** | *what about this topic* | because she went looking |

Chapters are TTC's version of pregnancy weeks and parenting phases — a position
in time, part of a narrative she is living. An article is reference, complete,
on demand. Every stage in this app has both, and they are supposed to. Judging
one against the other is like calling a week page a duplicate of a condition
page.

**So the architecture is right and nothing here needs building.** What is
genuinely true is much smaller:

The six-day window is *explained* in two places, by different hands, reviewed at
different times:

| where | reached by |
|---|---|
| `ttc_reads_data.dart:712, 734` | Fertile window → Improve my chances → "Timing, and the advice worth putting down" |
| `ttc_chapter_data.dart:315, 336` | Journey map → Trying Together → Me |

Both also put down the lie-still-afterwards myth, separately. **They can drift.**
Edit one and the other keeps saying the old thing, with nothing failing
anywhere — and the clinical review that covered the chapter did not cover the
article.

That is a content-operations rule, not a code change: **edit both or neither.**
`grep -rn "six day" lib/ttc/` finds every mention; the two above are the ones
that explain rather than restate.

**Do not re-raise this as an architecture problem.** It has been escalated twice
already and dissolved both times.

## 15.2 Video slot ids collide across journeys

`PvVideoSlot` ids were unique per read, not per journey step, so two steps in
different journeys could resolve the same slot and show the same film under two
different headings. Partly fixed: `JourneyElement` now carries an explicit
`videoSlot`, which makes the mapping stated rather than derived.

What is still open is the other half — nothing asserts that a slot is claimed by
at most one step. `test/journey_test.dart` now has the shape to copy: the
"two cards on one screen never lead to the same place" pair does exactly this
for surfaces. It wants the same check for slots, and it is worth doing before
any real film is cut, because after that the collision is a re-shoot rather than
a config edit.

## 15.3 Fifteen video slots have no film — PRODUCTION, not code

Every slot in `lib/ttc/ttc_videos_data.dart` has `url: null`, which is the one
flag the reader and the journey renderer read. Chapters and takeaways are
already written for each, deliberately: they were written *before* filming so
they brief the shoot rather than describe it afterwards.

The placeholder is a real designed state, not an empty box — it says COMING
SOON, shows the runtime, and names what the film will cover. So this is
plug-and-play: drop a URL in, the slot goes live, no other change.

Blocked on hosting. Self-hosted MP4/HLS per the Watch engine decision — Supabase
Storage now, Bunny or Cloudflare later. **YouTube is dead and is not to be
re-proposed.**

## 15.4 Eight products have no buy path — PRODUCTION, not code

The product cards in the TTC journeys research honestly and then stop. The
affiliate link is the missing half, and it is a commercial decision (which
network, what disclosure line) before it is a code one. `lib/brand/` already
holds the archetypes this has to be expressed through; see §13.0 for the
attribution rule it inherits.

## 15.5 The new TTC surfaces are local-only

`TtcPcosCheckStore`, `TtcPrecheckStore`, `TtcBmiStore`, `TtcFertilityHelpStore`
and `TtcVaccineStore` all persist to `shared_preferences` and none of them
writes to Supabase. Reinstall and the answers are gone.

This is the same agreed position as §9.7 — TTC takes no new schema while the UI
is still moving — and it is stated here rather than discovered later. Two of
them matter more than the others when it does get done: the PCOS check and the
readiness self-check produce a **doctor summary** she may well be relying on
having, and losing that on a new phone is worse than losing a BMI number.

Closing it is the `CloudSyncedStore` pattern already used elsewhere, one table
per store or one `user_state` key each. Decide which when TTC schema opens.

## 15.6 The South Asian obesity threshold is not settled

`kBmiObeseCutSouthAsian = 25.0` in `lib/ttc/ttc_bmi_rules.dart`, per WHO
Asia-Pacific, ICMR and NICE 2023. More recent ICMR material gives **27.5**. The
two disagree by enough to move a real woman between categories, and this app
tells her which one she is in.

**Decided 2026-08-21 — the FRAMING, not the number.** Both standards keep being
shown, because showing one alone hides that a threshold is a choice someone made
rather than a fact about her body. But **South Asian stays primary**: the
audience is Indian, the international band reads Indian bodies badly, and a
screen that leads with the international number is quietly telling an Indian
woman she is fine at a weight the guidance for her population does not agree
about. The label carries the standard's name so the reader can see which lens
she is being read through.

**Still open, and narrowed to one question: is the South Asian obesity cut-off
25.0 or 27.5?** Nothing about the audience settles that — both numbers come from
guidance written for this audience, and they disagree. It needs the same named
clinician §14.0 is waiting on, and it is the highest-value question on that list
because it is the only one where the answer changes what a specific woman is
told about herself.

Shipping 25.0 meanwhile is the conservative side: it puts MORE women into a
"worth a conversation" band than 27.5 would, and the copy in that band is
explicitly a conversation-starter rather than a verdict. Erring toward "worth
asking a doctor" is the safer error for a tool that must never diagnose.

**Do not change the number without changing the register entry with it.**

## 15.7 The FAB still covers body text mid-scroll

Distinct from §9.5, which is about the *end* of a list. `kAskFabReserve` fixes
that case and TTC uses it everywhere. What it cannot fix is a long prose screen
where, at some scroll positions, the 56px circle simply sits on top of a line of
text — and a reader is nothing but long prose.

Padding cannot help: the FAB is not in layout, and on a short page there is
nothing to push down at all. That last case bit the see-a-specialist screen,
where it covered three lines of the safety disclaimer; the local fix was to move
the disclaimer above the buttons, which was the right change for its own reasons.

The real answers are a product call, not a bug fix: hide the FAB while scrolling
down and bring it back on scroll-up, or suppress it by route name on reading
surfaces the way `kPremiereRoute` and `kCallRoute` already are. The second is
cheaper and worse — a reading screen is exactly where a question occurs to her.

Not urgent. Written down because it will be re-noticed on every device walk
otherwise.

## 16.0 An expert profile the panel cannot fill — OPENED 2026-08-27

`Expert` gained a credentials block on 2026-08-27 — `qualifications`,
`experience`, `practisesAt`, `registration`, `memberships` — because the expert
profile was reading as a credit rather than a profile. Reported as: *"when I
click on the profile what I see about this doctor should be a bit more in
depth… qualifications, what she is, what she does."*

**`expert_profiles` has no columns for any of it.** So the picture today is
split down the middle:

| Where the expert comes from | What her profile shows |
|---|---|
| Bundled seed (`lib/experts/*.dart`, the six Parenting entries) | Degrees, years, hospital, council registration, memberships |
| Published from the panel (`ExpertStore`) | Name, credential line, blurb — and an absent credentials block |

`ExpertStore.fromMap` deliberately does not fake it. Most find-help blurbs open
with the degrees (`'MBBS, DCH · newborn care…'`) and splitting on the first `·`
would have filled the block for free. That was rejected: **a credential is a
claim about a real clinician, and the app must never compute one.** A missing
qualification shows nothing; a derived one is ParentVeda asserting a degree
nobody verified, on a screen where a mother is deciding whether to trust a
doctor with her baby.

What the migration needs:

1. `expert_profiles.qualifications` (`text[]`), `experience` (`text`),
   `practises_at` (`text`), `registration` (`text`), `memberships` (`text[]`).
2. `ExpertStore.fromMap` and `toCacheMap` to carry all five. ⚠️ **Both, or
   neither** — a field read by `fromMap` and missing from `toCacheMap` is
   correct before a restart and empty after one, which is the note already on
   `toCacheMap`.
3. Directus fields on the Experts collection, in the same batched pass as the
   rest (see the Directus setup memory).
4. **An operator step, not a code step:** registration numbers are shown and
   never verified by the app. The profile prints them under a plain
   "Registration" label with no tick and no "verified" wording, precisely so
   nothing implies we checked. Someone has to actually check them before a real
   clinician goes live.

Also still open, and smaller: the ~40 find-help doctors have no credentials
block at all. They are lean placeholder rows whose degrees live in `blurb`, and
they should get real records when real supply replaces them — the same day
`kSeededExpertIds` empties out.

---

## 16.1 Reviews on an expert profile are Parenting-shaped

`Expert.reviews` is `List<(String, String, String)>` — plain English tuples. The
Pregnancy roster added on 2026-08-27 therefore ships with `reviews: const []`
and the profile hides the block, even though the same mothers' reviews already
exist, bilingually, on the consultation and masterclass pages a tap away
(`Review` in `lib/data/prepare_data.dart`, `LocalizedText` on every field).

Nothing is wrong on screen — a hidden empty block is correct behaviour. But a
Pregnancy expert's profile is quieter than it needs to be, and the fix is not a
copy-paste: it is deciding whether `Expert.reviews` becomes a real type shared
with `Review`, which touches ~30 importers of a shipped stage. Parked
deliberately rather than done badly under a UI change.

---

## 16.2 TTC names people the roster has never heard of — OPEN

Pregnancy, Parenting and the shared yoga marketplace all resolve a named person
to one profile as of 2026-08-27. **TTC does not**, and it is worth being precise
about why, because it is two different problems wearing one label.

**TTC's paid offerings name nobody.** `TtcOffering` carries an `expertId`
(`ttc_dr_fertility`, `ttc_dr_gynae`, `ttc_dr_androl`, `ttc_yoga_lead`,
`ttc_nutritionist`, `ttc_psychologist`) and **nothing in `kExperts` has those
ids**, so `ttc_prepare_screen.dart` renders no name at all. That is not a dead
tap — there is nothing to tap. Fixing it means writing six real people, which
is content, not wiring, and it should happen alongside whoever will actually
take those consultations.

**TTC's reads and videos name people who are the wrong people.** Eight TTC
articles and several videos are credited to `Dr. Ananya Rao` — who exists, and
is Parenting's **paediatrician**, whose subject is infant sleep and
vaccinations. `Dr. Vikram Nair` and `Dr. Sharanya Menon` exist nowhere.

⚠️ **This is why those bylines were deliberately NOT made tappable in the same
pass.** Wiring them would have been two lines and would have made the app worse:
tapping a fertility article's author would have opened a paediatrician's
profile, which is the `expert_roster` / `doctorInfoById` defect — a real
person's name presented as somebody else's — reintroduced on purpose. The
existing `pp_expert_links_test` already argues exactly this point: *"a journey
written by a lactation consultant and credited to a paediatrician is a smaller
error than an invented person and it is still a wrong one."*

The fix is a content decision before it is a code one: TTC needs its own
fertility specialist, andrologist and counsellor, and the thirteen bylines need
reassigning to them. Once those exist with ids, TTC joins the same seam
(`lib/experts/expert_link.dart`) that Pregnancy did, and
`test/expert_link_coverage_test.dart` gains a TTC group.

---

---

## 17.0 The V3 TTC rebuild left three things parked — OPENED 2026-08-30

The Trying-to-Conceive home, the fertile-window door, the tab bar and the
first-run flow were rebuilt against a handwritten spec benchmarked on iMumz
(entry flow), Mylo (language and the "I don't know" escape) and Flo (the cycle
header and the daily rail). Three things could not be finished in code — two of
them are content, and the third is a decision.

### 17.1 Eleven video slots are declared and none has a file — PRODUCTION, not code

Every slot renders `PvVideoPlaceholder` — real 16:9 geometry, the title in the
type it will use, and deliberately **not tappable**, so nobody taps a play
control that plays nothing. What is missing is the file and only the file.

* **The introduction**, first screen after language in `ttc_intro_flow.dart`.
  Two slots, not one: `ttc_intro_en` and `ttc_intro_hi`, chosen by the language
  picked one screen earlier. A single id would have guaranteed English audio for
  a Hindi user the day the files landed.
* **One per door screen** — six, `<bracketId>_intro`, declared on the TTC hub
  configs in `lib/data/hubs/ttc_hubs.dart`. `ProblemHubScreen` shows the film
  where a slot is set and the old support line where it is not, so pregnancy and
  parenting are untouched. `test/ttc_intro_flow_test.dart` holds both halves of
  that: every TTC hub has a slot, and no other stage's does.
* **The conceiving focus page** — `ttc_conceiving_intro` at the top of the page,
  plus two films inside it: `ttc_video_sperm_health` and `ttc_video_pressure`.
  Held by `test/ttc_focus_page_test.dart`, which asserts no two tiles share a
  slot — two films on one id means one of them can never be delivered.

**Eleven films is a real content bill**, and more if the introduction is made in
both languages. Worth costing before commissioning, and worth asking whether the
door films should be much shorter than the introduction.

All of it needs self-hosted MP4/HLS. **YouTube is dead** — tested to exhaustion
on 2026-07-12, systemically blocked, code removed. Supabase Storage now, Bunny
or Cloudflare later, same as the Watch engine.


### 17.2 The daily rail has drawn marks where the reference has photographs

`_DailyRail` in `ttc_home_v3.dart` renders five circles using `V3DailyArt` in a
tinted disc — the stage's existing visual language. The reference uses image
thumbnails. Real per-item art would need an asset pipeline for five items that
rotate daily by day-of-year, which is a content commitment, not a widget. The
current form degrades honestly and needs no assets; revisit if the rail tests
well.

### 17.3 V3 is still behind the dev toggle, and everything above is inside it

`TtcHomeVersionStore` defaults to `v1`. The whole of this rebuild — header,
rail, reordered sections, the new tab bar — is only visible after tapping **V3**
on the pill top-right. The first-run flow is the exception: it gates at
`TtcHomeScreen`, so it runs on both versions.

**Making V3 the default is a product decision and has not been taken.** V1 is
the most clinically-reviewed screen in the app, held by four test files, and
promoting a replacement is not something to do as a side effect of a UI batch.

## 18.0 PCOS and IVF are built; what is parked — OPENED 2026-08-31

Both doors are focus pages now and both are wired, tested and committed
(`0edc26c`). Nothing below blocks a build. It is recorded here because most of
it is a decision or an asset rather than code, and because a session that picks
this up later will not otherwise know which deviations were deliberate.

### 18.1 ~~The IVF readiness tool persists nothing~~ — FIXED 2026-09-03

It read `FertilityHelpContext` to prefill two questions and wrote nothing back,
so every visit re-asked all six and `hasCompleted` never became true. It worked
perfectly and remembered nothing.

**What blocked it was two sets of age bands, and the ruling was to stop having
two of anything.** The live screen used the brief's bands (under 35 / 35-37 /
38-40 / over 40); the engine behind it used its own (under 30 / 30-35 / 36-39 /
40+). "Under 35" is both "under 30" and "30 to 35", so no honest mapping
existed.

**The brief's bands are now the system.** `FertilityAgeBand` carries them,
`IvfAge` is retired, and `IvfReadinessAnswers.writeThrough` saves through to
`TtcFertilityHelpStore` on the way to the result — modelled on
`PcosStandAnswers.writeThrough`, deliberately the same shape.

Three rules inside the write-through, each held by a test:

* **Only what she answered.** The flow asks six of the store's ten questions;
  `miscarriages`, `pain`, `pelvic` and `cancer` stay untouched. A default in a
  clinical question she never saw is a "no" she never said, feeding a rule that
  decides whether she is told to see somebody.
* **"Not sure" is not an answer.** The store can hold named conditions or an
  explicit "none" and has no way to hold "she does not know"; writing "none"
  would convert an absence of information into information. Same for an undone
  or unclear semen test — only a found issue becomes `yes`, only a normal result
  becomes `no`.
* **`pathway` is written as the store's own word** (`current` / `done`), not an
  enum's `.name`, because it is switched on as a raw string and a mismatch would
  fall through to `notStarted` silently.

⚠️ **AND THE REFERRAL RULE NOW OVER-REFERS BY UP TO ONE YEAR, ON PURPOSE.**
NICE refers at presentation from 36; the band is 35-37, so 36 sits inside a band
and the rule cannot be exact. Referring from 35 costs an unnecessary
appointment. Not referring until 38 delays care for the 36- and 37-year-olds the
rule exists to catch. This tool's own promise is that it "only says whether a
conversation is worth having", so where it is unsure it leans toward the
conversation.

**If that year ever needs to be exact, the answer is a date of birth, not a
fifth band.** `FamilyProfileStore` already holds `dob`; nothing collects it yet
(§18.7). With a real age the referral rule reads 36 and the reassurance rule
reads 35, both correct, with nothing translated between them.

### 18.2 ~~Three IVF tiles are a different format from the brief~~ — CLOSED 2026-09-03

**This note was stale and was repeated as current on 2026-09-03. Correcting it
here rather than deleting it, because the mistake is the useful part.**

All three shipped as articles and have done since the IVF rebuild:

* "What a package leaves out" → `ttc_read_ivf_package`
* "Is egg retrieval painful?" → `ttc_read_ivf_retrieval`
* "Can I work through a cycle?" → `ttc_read_ivf_working`

The carousel and myth-card versions are commented out beneath each one in
`ttc_focus_ivf.dart`, kept for revert. I wrote this section on 2026-08-31,
converted the tiles the same week, and then read the section back as fact.
**The file was right and the note was wrong** — which is the whole hazard of a
parked-items doc: it is trusted precisely because nobody re-checks it.

**Still true, and still the user's call:** the brief asks for the consult to be
"shown across" the sections, and it appears **once** — `TtcBookingTile`, one
instance, in the first section. Deliberate: repeating a paid tile down a help
page is how it starts to feel like a funnel.

### 18.2a "How to read a clinic's success rate" — WRITTEN 2026-09-03

**Correction first.** I described this as "the last item in the IVF brief with
no tile and no content". There **was** a tile — a six-card `TtcCarouselTile` in
the *How do we choose a clinic?* section — and I wrote the article without
seeing it, then filed it under *money*, briefly giving the door two tiles with
the same title. Both mistakes are the same one: reporting from a summary rather
than from the file. Same failure as 18.2 below, in the same session.

Now resolved: the article sits **where the carousel was**, in *How do we choose
a clinic?*, and the carousel is commented out beneath it, kept for revert.

The six cards were right about *what* to ask and had nowhere to put the *why*.
"Per transfer excludes every cycle that never reached one" is true and is not
enough — somebody comparing two clinics needs to hold all six questions at once
while looking at two numbers, and a swipe deck can only show her one.

**The scope is the safety, and it is one sentence:** it teaches the *measures*
and never applies them. No benchmark figure, no clinic named, no personal
chance; every quantity relational (higher, wider, smaller) rather than numeric,
because a number in an article becomes a target on a screenshot.

It covers what "success" is counting (positive test / clinical pregnancy / live
birth / cumulative — four things wearing one word), what the denominator does
(per cycle started vs per collection vs per transfer, each step dropping the
people for whom things went least well), case-mix and why an overall figure is
the least useful one on the page, small-sample wobble, and what a rate cannot
see at all — including that a clinic taking difficult cases looks worse on
paper for doing something generous.

⚠️ **Clinical read still owed**, with the three articles written the same week.
The byline is inherited, not earned.

### 18.2b Date of birth would make the age rule exact — THE FIX, NOT YET BUILT

Kept in the plainest form, because it is the answer to a question that will be
asked again:

> **The only way to make it exact is to ask for date of birth once at sign-up —
> then it knows she's 36, not "35 to 37", and the question disappears. That's
> already half-built and waiting on onboarding.**

The question it disappears is 18.1's: the referral rule wants 36, the band is
35-37, and a band cannot tell them apart, so the rule over-refers by up to a
year on purpose. With a real age there is no band to translate — the referral
rule reads 36, the reassurance rule reads 35, both correct.

**Half-built means:** `FamilyProfileStore` holds `dob` and derives `age` on
every read. Nothing collects it. See §18.7, and note it pays twice — the IVF
readiness flow currently asks age as its own first question, which it would stop
doing.

### 18.3 The clinical line appears on both IVF graphics, not one — DELIBERATE

"The shape ranks the days against each other. It is not a probability." sits
under both the list and the curve on the fertility window screen. The design
puts it under the curve only. It stayed on both because 1a's own column header
reads **"Chance on that day"** above bars of varying width, which is the same
invitation to read a probability — arguably the line is needed more there.

### 18.4 The fertility window screen is violet; its door is rose — DECISION

Built from the Claude Design project, whose `accentHue` defaults to **273**;
everything on the screen derives from it. The `ttc_conceiving` bracket whose
tile opens it is **hue 344**. So the tile is rose and the screen is violet — a
discontinuity invisible in the design file, where the screen is shown alone.

Related, and the sharper half: `--pv-action` is `#6A30B6`, hue ≈272 — the ramp
hue. The design system's own rule is that the action colour is *"spent at
decision points… NEVER a surface, a card fill"*, and the ramp fills seven bars
and a curve area directly under an eyebrow set in it. It may be fine — the ramp
runs at 34–52% saturation against the brand's ~59%, so it reads as a tint
family. It is recorded because it is the same tension the design's own note
raises about the screen it replaced.

### 18.5 PCOS is waiting on designs, not on code

The user is designing Cycle Companion, the calendar and the tests library, and
will hand them over to be wired. **Do not redesign these** — implement what
arrives. The symptom logger is signed off and needs no design.

**⚠️ "Where do I stand" is no longer signed off — reopened 2026-09-02 and
reworked on request.** Four things changed and they are worth knowing before
touching it again:

* **The option controls are blocks, not pills** (`_OptionBlock`), laid out by
  `_Options`, which divides the row instead of wrapping to content width. The
  ragged right-hand margin down all eight questions was the reported
  "space being wasted"; a short last row now stretches to fill.
* **An answer can be tapped off again.** Every question was optional and
  irreversible at the same time, which contradicted the screen's own "you can
  leave any of these blank". Held by two tests in `ttc_pcos_stand_test.dart`.
* **The question cards were tightened**, not redesigned — padding and gaps
  only, ~60pt back across the eight.
* **The group rail on the PCOS door is squarish tabs**, tinted at rest and
  carrying a second line that says what is inside
  (`_GroupTab` in `ttc_focus_screen.dart`). This is the *third* attempt at a
  square tab there; the first two failed because they were white and empty, and
  that note is on the widget.

One mechanical item is still genuinely outstanding: `ttc_pcos_stand_screen.dart`
predates `ttc_tool_chrome.dart` and still carries its own copies of the hero,
sheet, question card, option blocks and buttons. They are close to identical,
which is exactly the state that drifts — the chrome's header says "change both,
or change neither" until it is folded in. Held on purpose while designs are in
flight, because restructuring a working screen mid-redesign is churn.

### 18.6 Assets owed, not code

* `ttc_pcos_intro` — "PCOS in five minutes", also the PCOS page hero
* `ttc_pcos_movement` — "Gentle movement for PCOS"
* `ttc_infertility_intro` — the IVF page hero
* `ttc_ivf_cycle_walkthrough` — "An IVF cycle, start to finish"
* `ttc_ivf_two_week_wait` — "Getting through the two-week wait"

All five render honest coming-soon placeholders at real 16:9, so no layout
shifts when files land. See 17.1, which this extends rather than replaces.

### 18.7 Date of birth is stored and one thing still reads nothing

`FamilyProfileStore` now holds `dob` and derives `age` on every read, and the
PCOS nudge fires at six months from 35 off it. **Nothing collects it yet** —
onboarding is where the user intends to ask. Until then `age` is null on every
device and that branch stays quiet, which is the behaviour it had before.

The IVF readiness flow still asks age as its own first question. Once
onboarding writes a DOB, that question can prefill from it rather than being
asked twice across two doors.

---

**None of the above blocks a build.** All of it blocks being comfortable, and
14.2 and 14.4 are the two that reach a mother at her worst moment.

## 19.0 The cycle report was rebuilt from the design project — OPENED 2026-09-02

`Cycle Report.dc.html` drew three artboards. Two ship, one was mined for a
part, and the screen it replaced is still doing most of the work. Nothing below
blocks a build.

**Where it is in the app:** TTC home (V3) → the daily rail → the **Cycle report**
circle. Also from an insight card on the same home, and from the foot of the
symptom logger, **See your cycle report**.

### 19.1 The dial and the calendar both ship; the road did not — DECISION

1a and 1b are the same cycle drawn two ways, so both render behind a
`TtcCycleViewToggle` — **Dial** first, calendar one tap away. The choice is not
remembered between visits: a picture is chosen to answer the question in front
of her, not to declare a preference, and a stored setting nobody set is worse
than a default. If people flip it every single time, that is the evidence for
persisting it, and there is none yet.

1c, **the road**, was not built. Its proportional bar said what the ring and the
grid already say. Its **timeline was lifted out and now appears under both**
pictures in place of the flat four-card list each of them had — connected stops,
numbered, carrying each stretch's length and whether it is done, now or ahead.
That was the user's own pick from the artboard.

### 19.2 The bands are stronger than `v2BlockTint` — DELIBERATE DEVIATION

The door playbook says `v2BlockTint(hue, p)` for every tint. `ttc_phase_colours.dart`
does not, and the reasoning was checked on screen before it was written.

`v2BlockTint` keeps only the hue and stamps 32% saturation / 91% lightness. That
is right for a tinted block behind a heading, where four are never asked to be
told apart. Four ring arcs at a 16pt stroke and twenty-eight calendar squares
are a different job — there the colour **is** the information. Compared side by
side, the wash puts the four stretches within a couple of points of each other.

So: **the repo's hues, unchanged** — 344 / 206 / 160 / 268, three of them the
app's own `V2BlockHues` — at the design's saturation and lightness. The hue
question turned out to be empty; 344 against the design's 350 resolves as
`#EFE1E5` vs `#EFE1E3`.

The accessors take a `TtcPhase`, never a hue, so they cannot spread into
ordinary cards and leave the app with two answers to "how tinted is a tinted
block". **If a second colour-coded diagram wants this treatment, give it its own
narrow accessor rather than widening these.**

### 19.3 Four of the five report states are undesigned and keep what they ship

The design drew one state — a cycle with a period, an estimate and four
stretches. `TtcReportState` has five. The other four (nothing logged,
clinic-held, no estimate, thin) **render exactly as they did before**, on the old
chrome, with their existing reviewed copy.

That means the screen has two different frames depending on her data, which is a
real wart and is why it is written down. It is not resolvable in code: a hero
line for clinic-held would have to name a phase in 40pt type above a panel
explaining that naming a phase is not ours to do. **The user is designing these.**

### 19.4 What the design has that the screen does not

* **The bottom nav** on all three artboards — a canvas convention. The report is
  pushed from three places and has never had one.
* **The spine chip** ("Cycle day 12") above the hero title. The ring's centre
  already reads "Day 12 · of 28 · 31 Aug", and a second copy two inches above it
  is one more thing to keep in agreement. Restore it if the chip is wanted.
* **A temperature or weight line drawn across the ring**, which the design's
  fact block promises in words — *"add either on any day and a line appears
  across the ring"* — but never draws. **Not built, and the promise is still on
  screen**, per the standing rule that aspirational copy stays. What ships
  instead: the existing chart, kept as its own section below the timeline
  whenever there are two or more readings. It carries an axis, a unit, date
  ticks, phase bands and marker rows, and throwing it away to honour a fact
  block would have cost a reviewed reading of her month.

### 19.5 One shared file gained one parameter

`TtcToolScaffold` in `ttc_tool_chrome.dart` — shared with the other door
sessions — has a new optional `heroLead`. It is for a control that **scopes
everything below it**, which is why the cycle picker cannot live in the sheet:
the page would begin answering before she has said which cycle she is asking
about. It is deliberately one widget and not a list; a hero with a stack of
controls is the toolbar `TtcToolClose` exists to avoid.

### 19.6 `TtcCycleReport.days` and `ttcCyclePhaseSpans` answer different questions

Worth writing down because conflating them cost a round trip. `days` is **what
she logged**, so it stops at today and should. The four stretches are **the
shape of the cycle**, known in full the moment a period is logged, because they
are arithmetic on the estimated ovulation day and the cycle length. Today's date
does one job in them: it decides which stretch carries "You are here".

`test/ttc_cycle_spans_test.dart` holds the distinction — its fixtures put today
mid-cycle on purpose and assert about the part that is ahead, because a test run
on a finished cycle would not have caught it.


### 19.7 The field's chroma is equalised across every hue — 2026-09-02

`V3HeroField` used one recipe for every hue: `HSL(hue, .58, .62)` on the deep
stop. HSL saturation is not chroma, so measured as CIELAB C* that recipe gave
**32 for the clinical blue and 68 for the PCOS magenta** — more than twice the
colour, from the same integer in code. Invisible on a small tinted block, and
the loudest thing on screen when the field *is* the page surface.

A first fix damped a 280–320 band to a flat 0.62. It was half an answer:
Fertile Window at 273 sits outside that band at C* 67, so two of the three
screens still disagreed, and a band only ever covers the hues someone has
already complained about.

`v3FieldChroma(hue)` now **solves** for the saturation that lands any hue on a
target C* of 26, and returns it as a fraction of the recipe's own. Nothing is
special-cased and no hue is named, so a hue nobody has drawn yet is already
handled. The target sits below the quietest hue the app had, so equalising also
lightens — which is the other half of what was asked.

* **Hues are untouched.** 288 is still 288; every `v2BlockTint` on every page is
  byte-identical. Only the full-page wash spends less.
* Wired at all nine `V3HeroField` call sites.
* ⚠️ **Every stage's field moved, not only TTC.** Parenting, pregnancy, skilling
  and the hubs all render quieter now. That is the intent — one rule, one look —
  but it has only been seen on TTC. Worth a pass over the other stages on a
  device.

### 19.8 Checkboxes are single-purpose again — 2026-09-02

"Where do I stand" briefly drew a checkbox on every option. The reasoning was
that with deselect available each question is "none or one" and so behaves like
a set of checkboxes — true of the mechanics, wrong about the reading. **A
checkbox promises you may choose more than one**, and seven of the eight
questions broke that promise on the second tap.

Only the hair-area picker, the one genuine multi-select, ticks now.
`test/ttc_pcos_stand_test.dart` holds both halves: deselect still works, and a
single-choice option never grows a checkbox.

Related, same pass: the tool's action is white with a hairline and an ink label
— `_QuietButton`'s treatment from the symptom logger, whose own header already
declared it *"one button treatment on this stage"*. That screen had been the odd
one out since it shipped, first in the accent and then in ink.

### 19.9 The grouped page's sheet must fill the screen — FIXED

Ungrouped, the focus page is eleven sections and the sheet always outgrew its
`minHeight` of 0.72 screens. Grouped, it shows **one** group — Track is a single
rail — so the sheet stopped short, the list ended with it, and the hero field
was left showing under the last card.

Two separate causes, both now closed and both worth knowing because they recur:

* `minHeightFactor` is **1** on a grouped page. A full viewport is the smallest
  number that cannot fail, because the hero has already been scrolled past by
  the time the sheet's foot is reachable.
* `Transform.translate` **moves paint and not layout**. Lifting the sheet over
  the photographic hero left its painted bottom edge 38pt above where the layout
  thought it ended. `_Sheet.extraBottom` repays exactly that, and
  `kTtcHeroOverlap` is used at both ends so the two cannot drift.

### 19.10 ⚠️ `ttc_data_chain_test` is a DATE BOMB, not a regression

Recorded because a handoff this session guessed wrong about it, and the next
person will guess the same way.

`test/ttc_data_chain_test.dart` › *"and Today says WHY rather than showing a
hole"* logs a period on the hardcoded date **25 July 2026** and then renders
`TtcTodayScreen` against the **real** clock. On 2 September 2026 that is cycle
day 40, the screen correctly prints "Cycle day 40", and the test's
`find.textContaining('day 40'), findsNothing` catches it.

That assertion exists to prove the old *"ovulation around day 40"* defect never
returns. It is matching an ordinary cycle-day readout by calendar coincidence.

* It is **not** caused by the cycle-report work, the PCOS work, or the chroma
  work. `ttc_today_screen.dart` imports none of those files.
* **It passes again the next day**, which is worse than failing permanently.

The fix is to assert on the phrasing (`'ovulation around day'`) or to freeze the
clock in that test. Not done — it guards a clinical defect and belongs to
whoever owns that file.


## 20.0 Cycle Companion rebuilt, and `CycleStore` learned a new fact — 2026-09-02

Built from the "Cycle Companion" design project. **Where to look:** anywhere
that opens `ttc_cycle` — the TTC home, the PCOS door's Track group, the
fertility-help screen, the Tools hub.

### 20.1 Period LENGTH is captured for the first time

`CycleStore` stored start dates and nothing else, so "how long is my period"
was unanswerable and the cycle report banded its first stretch off
`kTtcAssumedBleedDays` — a hardcoded five standing in for data.

It now holds `_bleedDays`, keyed by start date like the LH and temperature
signals already were. Chips (3/4/5/6/7+) rather than an end date, decided before
the screen was designed: a count is one tap, it works when she logs three days
late, and it is exactly what the picture needs. `kBleedStillOn` is a separate
sentinel because "she has not said" and "she said, and it is ongoing" are
different answers and both are common.

`kTtcAssumedBleedDays` is now a **fallback**, not the rule — `ttcBleedDaysFor`
prefers what she recorded, and falls back while a period is still going, because
a band that lengthens each morning would be the app inventing the fact it is
waiting for.

⚠️ **Cloud sync does not carry bleed days yet.** They persist locally and
survive a restart, but `pushToCloud` / `pullFromCloud` were not extended, so a
second device sees the dates and not the lengths. Nothing breaks — the fallback
covers it — but it is a real gap.

### 20.2 Two operations that lose data silently, and the guards for them

Both are worth knowing because the obvious implementation of each is wrong.

* **Correcting a date** as a remove-then-add drops the bleed length, the LH
  strip and the temperature shift, because all three are keyed by the start
  date and `removePeriodStart` clears them on the way out. Nudging a date by one
  day would erase everything she recorded about that cycle, and nothing would
  look wrong afterwards. `movePeriodStart` carries them across; the test asserts
  the counter-example too.
* **Undo** that restores only the date gives back a row that lost its length.
  `detailsFor` captures what hangs off a period BEFORE it is removed, and
  `restorePeriodStart` puts it back — and re-pushes to cloud, because the
  removal deleted that row explicitly and a local-only restore would be undone
  by the next sync.

Swipe-and-undo was chosen over a confirm sheet: a confirm taxes every delete to
protect against the rare mistake, an undo taxes only the mistake.

### 20.3 Her rhythm survives a refusal — a mistake caught by an old test

The first cut showed the rhythm numbers only in the healthy state. A test
fixture months in the past then failed, and it was right to: an overdue cycle
stops the estimate dead, and her last four cycle lengths are exactly as true
that day as the day before. **Refusing to draw THIS cycle is not a reason to
stop stating her history.** The numbers are withheld only when the engine has
called the history itself untrustworthy, which is what the screen this replaced
already had right.

Related, same pass: the refusal card's "Your rhythm" placeholder and the rhythm
section carried the same label, so the words appeared twice — once over an
explanation and once over the numbers whose absence it was explaining. The
placeholder now shows only when there really are no numbers.

### 20.4 Reused rather than rebuilt

The ring is `TtcCycleRing`, built for the report; the four stretches come from
`ttcCyclePhaseSpans`; the colours are `ttcPhaseBand` / `ttcPhaseMark` /
`ttcPhaseInk`. Asked for directly — *"we already have ring colors, so use what
we have"*. Two screens drawing one cycle from one source cannot disagree
about it.

The one new drawing is `_DaysGrid`, and the reason it is not `TtcCycleGrid` is
worth keeping: the report's grid runs cycle day 1..28 in order, which is right
for reading a cycle as a cycle. This one sits under dates she recognises, so it
starts on the correct weekday and carries the month where it turns over. Same
colours, same spans, different question.

### 20.5 Still open on this screen

* **Symptoms, temperature and LH readings are still not shown here.** All three
  are stored and all three are absent — the brief listed them and this pass did
  not reach them. The report shows the first two.
* **The old screen body is commented out, not deleted**, in
  `ttc_cycle_screens.dart`, so the comparison can be made rather than
  remembered.
* **Not seen on a device.**


## 21.0 PCOS, finished against its brief — 2026-09-02

`pcos_rebuild.pdf` steps 1–5 and Part 2 are complete. What follows is what is
genuinely left, what was closed, and the deviations that are decided so nobody
re-opens them.

### 21.1 ⚠️ NOBODY CAN SEE ANY OF IT — the one real blocker

`ttcFocusPageFor` is called from **one place**, `ttc_home_v3.dart`, and
`TtcHomeVersionStore` defaults to **v1**. So on a real device the PCOS door does
not exist.

⚠️ **AND IT IS NOT THAT V1 SHOWS AN OLDER PCOS — V1 SHOWS NO PCOS AT ALL.** This
was written the wrong way round first, and the correction matters because it
changes the decision. `bracketsFor(LifeStage.tryingToConceive)` — the "Start
anywhere" grid, the only surface that lists problem areas — appears in
`ttc_home_v3.dart` and nowhere else. Every stage is the same: the bracket grid
is a V3 construct. V1's tabs are Today · Prepare · Tools · Calendar · Community,
and none of them reaches a bracket.

So `kTtcPcos` (the hub config) and `kTtcActPcosLibrary` (the accordion) exist in
the code and **nothing on V1 opens them**.

**To see the difference:** TTC → the You tab → the `V1 | V3` pill
(`ttc_profile_screen.dart` line ~444). On V3 the home carries the bracket grid
and PCOS is in it; on V1 there is no grid and no way in.

Two consequences:

* The brief's **step 4** — "remove the old accordion and the double-rendered
  sections" — is moot rather than pending. The accordion is already
  unreachable; there is nothing to remove from a user's path. Deleting the code
  is hygiene, not product.
* **Promoting V3 takes nothing away from anyone.** For PCOS it is purely
  additive: V1 users have no door today and would gain one. The general caution
  in §17.3 still applies to the rest of the home — V1 is the most
  clinically-reviewed screen in the app — but the PCOS half of that decision has
  no downside to weigh.

⚠️ **And nothing inside the V3 door leads backwards.** Audited tile by tile: the
page reaches four surfaces (`ttc_cycle`, `ttc_symptom_log`, `ttc_pcos_check`,
`ttc_community`), twelve reads, one recipe, one offering, one consult action and
three video slots. `ttc_pcos_check` resolves to `TtcPcosStandScreen`, with the
older `TtcPcosCheckScreen` commented out in the router. `kTtcActPcosLibrary`
appears zero times on the page.

### 21.2 §18.5 is CLOSED — and two of its three items were never PCOS

It listed three designs owed: Cycle Companion, the calendar, the tests library.

* **Cycle Companion** — built (§20).
* **The calendar and the tests library** — **dropped from this list on purpose.**
  They were on it because they sat in the PCOS Track group; following the
  brief's own step 2 list, both were removed from that group. Neither appears
  anywhere in PCOS now. They are general TTC tools reached from the home, the
  More screen, journey steps and other brackets, and redesigning them is a job
  about those tools rather than about finishing PCOS.

**The mechanical item is now DONE.** `ttc_pcos_stand_screen.dart` predated
`ttc_tool_chrome.dart` and carried its own copies of the shell, the close
button, the progress hairline, the question card, the result block, its heading,
the privacy line and both buttons. All nine are gone; the screen wears the
shared chrome. 1,140 lines → 936, and no behaviour changed on it.

Two things came out of the fold that are worth keeping:

* **`TtcToolScaffold.intro` is nullable now.** It was required on a stated
  argument — on a screen that could be mistaken for a diagnostic quiz, "this is
  not a diagnosis" arriving at the end arrives too late. That argument is about
  a screen that ASKS. The RESULT screen has already been framed, and inventing a
  second sentence to satisfy a constructor would be copy on the page to please
  the compiler. **Leave it out only where nothing is being asked.**
* **`TtcToolPrimary` is white with a hairline, not `ttcPurple`.** The rule was
  already written on `_QuietButton` — *"one button treatment on this stage"* —
  and restated directly: the buttons are not purple. The accent is spent at
  decision points, never laid down as a surface, and a full-width filled bar is
  a surface whatever it does when tapped.

  ⚠️ **This changed `ttc_ivf_readiness_screen.dart` as well**, the only other
  caller. That is the point of folding rather than forking — the PCOS tool had
  already been corrected by hand, and leaving the shared one purple would have
  meant two TTC tools with two primary buttons and a rule only one obeyed. It
  has not been looked at on a device.

### 21.2b One duplication is left, and it is the stand screen being AHEAD

`_Options` / `_OptionBlock` / `_Opt` stayed private, and so did the four
controls built on them (`_Chips`, `_YesNo`, `_Degree`, `_AreaPicker`). The
shared equivalents are `TtcToolPill` and `TtcToolChoice`, which lay options out
as a `Wrap` of label-sized pills — the exact thing that was rejected on this
screen: *"eight short questions… a lot of spaces again, being wasted."* The
private set divides the row instead, so a short last row stretches rather than
leaving two-thirds empty, and it drops the checkbox on single-choice questions.

So this is not drift to correct downwards. **Promoting the private set into
`ttc_tool_chrome.dart` would fix the same wasted space on IVF readiness**, the
only other caller — but it is a visible change to that screen's questions and it
is a design call rather than hygiene. Left for a decision.

### 21.3 Infographic is a format, and it is one frame

Added because the brief marks two tiles Infographic and no such format existed,
so both shipped as six-card carousels. The rule came with the request:
*"infographic only consists of 1 slide — in one slide provide required info."*

`TtcInfographicTile` therefore has **no `cards` and no `slides`** — there is
nowhere for a second frame to go, and a subject that needs one was never an
infographic. Both tiles are "X or Y" questions, which is the shape a single
frame beats a carousel at: the halves sit side by side, so the difference is the
picture rather than something carried across a swipe.

`ttc_focus_groups_test.dart` holds the only rule that can still be broken —
two to four points a column, and a headline that never merely repeats the title.

⚠️ **"Hair changes, explained" stays a carousel.** The brief marks it *Guide*,
not Infographic, and a guide is genuinely step-shaped. Do not sweep it in.

### 21.4 Owed, and not code

Four assets. All four render honest coming-soon placeholders at real geometry,
so nothing shifts when files land.

* `ttc_pcos_intro` — "PCOS in five minutes"
* `ttc_pcos_movement` — "Gentle movement for PCOS"
* `ttc_pcos_food_insulin` — "Food, insulin and PCOS" *(added 2026-09-02; the
  brief says "reuse existing" and no such film exists anywhere in the repo)*
* **The hero photograph** — currently a placeholder Unsplash URL, one line in
  `ttc_focus_pcos.dart`

### 21.5 Decided deviations — do not re-open

* **Guide → carousel.** No Guide format; a guide is step-shaped and a carousel
  is that.
* **Recipe → a real recipe** on the shipped `RecipeDetailScreen`, added as the
  ninth tile format. **Community** is the tenth, and **Infographic** the
  eleventh. Each was added rather than borrowing `TtcToolTile`, because the chip
  is the promise about what happens when she taps.
* **"Your realistic odds with PCOS" → "Conceiving with PCOS, realistically."** A
  possessive plus a probability word is the banned construction, and
  `ttc_clinical_review_test.dart` scans source for it.
* **Track uses a rail, not full-width cards.** The brief asks for tool-style
  cards; asked and answered — leave it as a rail.
* **The five groups are a selector rail, not a tab bar.** See §1 of the door
  playbook, amended.
* **The card's title sits ON the image**, up to four lines, rather than below it
  at two.

---

## 22.0 Records rebuilt from the design project — 2026-09-03

`TTC Records.dc.html` (project `a08f49db`) drew eight options. Six were built —
**1a, 1d, 1e, 1f, 1g, 1h** — and two were deliberately not. What follows is what
is open, what was refused, and what only the user can decide.

The code lives in three files:

| File | What it holds |
|---|---|
| `lib/ttc/ttc_records_grouping.dart` | The grouping, the coverage count, and the change/gap arithmetic. No widgets. |
| `lib/screens/ttc/ttc_records_v2.dart` | Every screen and sheet: the list body, the trend, the detail, the viewer, add, "Type it", the appointment card. |
| `lib/screens/ttc/ttc_records_screen.dart` | The frame only. The old flat list and the old add dialog are commented out below it, kept for revert. |

**Where to look in the app:** TTC → Tools → **Health Records** (or **Reports**,
which is the same folder narrowed to library results).

---

### 22.1 Two designs drawn and not taken — NOT DEFECTS

Both are recorded at the head of `ttc_records_v2.dart` with the argument, so
going back is a decision rather than an archaeology exercise.

* **1b — the date spine.** The same records kept in date order under a month
  spine. Its argument is real: she remembers "the tests before the last cycle",
  not "my AMH readings". It lost to 1a because recency is one question and 1a
  answers three (has this changed, what is not here, whose is this). **If
  recency turns out to matter more than direction, 1b is the design to go
  back to** — and the old flat list is still in the file.
* **1c — the dot chart.** Lost to 1d on data shape, not on taste. This library
  holds a thyroid panel with a photo and no number, an HSG whose result is a
  sentence, and a semen analysis that is three values in one result. A chart
  renders none of them.

### 22.2 "Share as PDF" — BUILT 2026-09-03

Built, not parked. I called this a big piece of work and it was not: the
machinery already ships and is used in six places. `pdf: ^3.11.1`,
`printing: ^5.13.4` and `share_plus` are all in `pubspec.yaml`, and
`lib/services/pdf_fonts.dart` already solves the hard part (loading a font set
that has Devanagari, and refusing rather than exporting empty boxes).

`lib/services/ttc_records_pdf.dart` follows `diet_chart_pdf.dart` exactly.
**Where to look:** the appointment card at the foot of Health Records → the
sheet → **Share as PDF**, top right.

Three decisions inside it are worth knowing:

* **The sheet shows six results; the PDF carries everything.** Not an
  inconsistency. The sheet is read over her shoulder in ninety seconds. The PDF
  is read by a clinician who has never met her, alone, and a medical summary
  that silently stops at six is an omission that can change a decision without
  anybody knowing it happened.
* **Photos travel with it,** one captioned page each. A summary that says
  "photo saved" and does not carry the photo is worse than one that never
  mentioned it — the reader now knows a document exists and cannot see it.
* **A PDF attachment cannot be embedded as an image and is named rather than
  dropped**, under "Files that could not travel". An absence you can see is a
  different thing from an absence you cannot.

### 22.3 The viewer cannot brighten the screen — ONE DEPENDENCY, USER'S CALL

The design raises screen brightness when a report opens, which is right: a lab
sheet photographed under a tube light is read at arm's length by somebody else.

**What it actually needs:** the `screen_brightness` package, and nothing else.
It sets *window* brightness rather than system brightness, so there is no
Android permission and no iOS entitlement, and the OS restores the phone's own
setting when the app leaves the foreground. Roughly ten lines — set on push,
reset on pop.

**Why it is not already in:** it is a new third-party dependency on the
render path of a medical document, and adding one without asking is not this
repo's habit. Say yes and it takes one pass.

Until then the label is deliberately **not** shown — a screen claiming to have
brightened itself when it has not is worse than one that says nothing. Noted in
the class doc on `TtcSheetViewer`.

### 22.4 NAMES — DECIDED, NOT YET BUILT (2026-09-03)

**Decision: the app will ask for names at sign-in, hers and her partner's.**
When the partner signs in on his own device, he is asked for his.

Nothing in the app collects an adult name today. `ChildProfileStore.instance.name`
exists for the parenting stage and there is no equivalent for either parent —
so ownership currently reads **"You"** and **"Partner"** via `ttcWhose()` in
`ttc_records_v2.dart`.

**What changes when names land**, in one place each:

| Where | Today | With names |
|---|---|---|
| `ttcWhose(bool)` | `'You'` / `'Partner'` | the two names |
| Row leading mark | no avatar | the design's two-letter monogram (AA / RS) |
| PDF "Whose" column | `Her` / `Partner` | the two names |
| Appointment sheet | unattributed rows | attributed rows |

`ttcWhose()` is the single seam — every one of those reads it or would. The
monogram is the only new drawing, and the design already specifies it.

**Still open inside the decision:** what happens when the partner never signs
in. A name asked of her *about* him is a different thing from a name he gave,
and only one of those should appear on a document leaving the phone. Worth
settling before the sign-in screen is written, not after.

### 22.5 What the rebuild fixed that was never filed as a bug

Worth writing down, because none of these were on any list:

* **The app has stored attachment refs since records shipped and had never once
  displayed one.** The folder held her reports and could only show their
  filenames. `TtcSheetViewer` is the first time a saved report is visible.
* **A photo-only record could be created and never completed.** `TtcRecord`
  has always defaulted `value` to `''`, so a record with no number was already
  representable — there was simply no way back to type one in. "Type it" on the
  row and "Type the number" on the detail screen close it, and
  `TtcRecord.copyWith` learned `value`/`unit`/`forPartner` for exactly that.
* **The library's plain-language note nearly went missing.** The old card
  printed it beside every library result. The redesign has no room for it on a
  row, so it moved to the detail screen under "What this test measures" —
  a move, recorded, rather than a silent regression.

### 22.6 The interpretation rule, restated because this screen is where it breaks

Nothing in these three files interprets a value. No normal range, no high or
low, no colour that means anything. A trend of her own three readings with the
dates on them is a **description**; the same three with a shaded band behind
them is a second opinion from a phone.

`ttcReadingChange()` returns **null** — says nothing — wherever the arithmetic
would not be honest: a text result, a photographed result with no number, or two
readings in different units. It is the same shape as every other refusal in this
stage: structural, not a flag somebody can flip.

Two tests hold it (`test/ttc_care_test.dart`), and the coverage block says
**"not added"** rather than "missing", because "missing" is a judgement about
the clinician looking after her and "not added" is a fact about this folder.

### 22.7 Reading a report photograph — HELD 2026-09-03, deliberately

**Held, not rejected.** Nothing is to be built for this until the decision below
is made, because it means changing `C:\Projects\parentveda-askveda` — a second
repo — and that is not a thing to start sideways out of a records screen.

**What prompted it:** the empty state's first copy read *"One photograph today,
and in a year this screen answers the questions a consultation opens with."* It
sounded like upload-and-get-insights and was read that way immediately. The copy
is fixed (see the comment on `TtcRecordsEmpty`), but the question it raised is a
real one and worth answering properly rather than dropping.

#### The rule, already decided one product over — do not re-litigate it

The parenting Health Wallet asked for exactly this: upload a prescription,
auto-detect medicines, auto-create reminders. §5.10 settled it:

> **Extraction is fine. Silent creation is the problem.** A misread dose becomes
> a recurring alarm telling a parent to give the wrong amount of the right drug,
> on time, with the app's authority behind it.

Records is the same shape. A folder that files **12 ng/mL** when the sheet said
**1.2** is that failure in different clothes, and worse in one way: the number
then travels into a PDF and gets handed to a clinician.

**So whatever is built: extracted text is a DRAFT, never a saved value.** It
lands in a confirm step and nothing enters the folder until a person has read it
back against the paper.

#### Extending it — a record knows whether a human checked it

Asked for on 2026-09-03 and worth writing down while the reason is fresh.

A record should carry **whether its value was confirmed by a person**, and say
so on the row. Not for liability — the disclaimer already covers that, and a
disclaimer is not a design. For the reader:

* A number she typed and a number a camera guessed are **different kinds of
  fact**, and the truth hierarchy in this app already says so — her own
  observation sits above ParentVeda's calculation, and an OCR reading is
  squarely a calculation.
* The one moment it matters is the handover. An unconfirmed value going into
  the PDF, unmarked, is the app asserting something no human ever checked to a
  clinician who cannot tell the difference.

**Shape:** one nullable bool on `TtcRecord` (`confirmedByPerson`), defaulting to
true for everything typed by hand — every record that exists today was typed, so
the migration is "old rows are confirmed" and there is no backfill. The PDF marks
the unconfirmed ones. Nothing else changes.

#### The on-device question, answered

**Samsung's camera OCR is Samsung's.** It is a vendor feature in their camera and
gallery apps; no third-party app can call it, and a Redmi or a Motorola does not
have it. That is why "the phone can already do this" does not translate into
"the app can already do this".

**What an app can use:**

| Route | Where the model lives | Works on every device? |
|---|---|---|
| ML Kit, **bundled** | Inside our APK | Yes — same behaviour on a ₹8,000 Redmi as on a Galaxy S24 |
| ML Kit, **Play-Services-delivered** | Downloaded once, on first use | Needs Play Services and one online moment |
| Apple Vision (iOS) | Built into iOS 13+ | Yes, on iOS, at zero size cost |

Bundling is the one that removes the variability entirely, and the price is app
size: roughly **4–5 MB** on Android for the Latin-script model, more on iOS
depending on which pods come along. **Latin script only** — fine here, because
Indian lab reports are printed in English; Devanagari would be a second model.

⚠️ **Numbers above are from documentation, not from a build of this app.**
Measure the real APK delta before committing to it.

#### The part that is actually hard, and it is not the OCR

OCR returns **lines of text**. A lab report is a **table** — test name, value,
unit, reference range, sometimes two columns and a letterhead. Turning

```
S. ANTI-MULLERIAN HORMONE (AMH)    1.2    ng/mL    1.0 - 4.0
```

into `{test: AMH, value: 1.2, unit: ng/mL}` is parsing, and it is where this
either works or quietly produces nonsense. Two ways:

* **Regex against `ttcTests`** — eleven known names, on-device, free, no
  document leaves the phone. Fails on layouts it has not seen, and *fails
  visibly*: it finds nothing and she types it, which is the flow that already
  exists.
* **An LLM in the AskVeda service** — handles messy layouts, and sends a medical
  document to a server to save someone thirty seconds of typing.

**Recommendation, for when this is picked up: on-device ML Kit + regex + the
confirm step.** A lab report is among the most private things she owns; this
route means it never leaves the phone, costs **$0 / ₹0** per scan, and works in
a clinic basement with no signal.

**The cheap experiment that decides it:** photograph five real Indian lab
reports and see what on-device OCR returns. If regex can find the eleven test
names in those five, the LLM route is not needed and no cross-repo work
happens at all. That test costs an afternoon and no money, and it should happen
before anything is written in either repo.

#### If it ever goes to AskVeda, this is what that repo owes

Written down now so it is a handover and not a gap — the same discipline
CLAUDE.md requires for any two-repo change:

* An endpoint taking an image and returning
  `{test_name, value, unit, taken_on}` **with per-field confidence**.
* Confidence is not decoration: the confirm screen should pre-select what it is
  sure of and leave the rest blank rather than guessing into a field.
* It must be able to answer **"I could not read this"**. A service that always
  returns something will eventually return something wrong with the same
  confidence as something right.
* Nothing about interpretation. It transcribes. Ranges, flags and verdicts are
  not its job and are not anybody's job in this product.

---

## 23.0 Getting ready, built from the brief — 2026-09-03

Fourth door on the PCOS/IVF shape, from `getting_ready_rebuild.pdf`.

**Where to look:** TTC home → **Getting ready**. Five tabs, Diet first.

| File | What it is |
|---|---|
| `lib/ttc/focus/ttc_focus_getting_ready.dart` | The page: 5 groups, 7 sections, 17 tiles |
| `lib/ttc/reads/ttc_reads_getting_ready.dart` | +4 new articles |
| `lib/screens/ttc/ttc_habits_screen.dart` | "Track what you're working on" |

---

### 23.1 The brief's central worry was already solved — STEP 5 WAS FREE

The rebuild asks whether the content model can point many cards at one item,
and says to build that first if it cannot. **It can, and it never worked any
other way.** A tile carries a `readId` / `surfaceId` / `productId` — an
identifier, never a copy of the text. The article lives once in `kTtcReads`;
any number of tiles on any number of pages may name it.

`ttc_focus_page_test.dart` enforces the other half: every id on every page must
resolve, so a card pointing at renamed content fails the build rather than
rendering perfectly and doing nothing.

Step 5b is live: the fertile-window door's "What she should do" now also carries
`ttc_read_what_to_cut` and `ttc_read_weight_kindly` alongside the two read ids
it already shared. Not copies — the same ids.

### 23.2 The carrier screening article — WRITTEN AND WIRED. THIS ENTRY WAS STALE

⚠️ **CORRECTED 2026-09-05, and the staleness did real damage.** Everything
below the line was true when written and stopped being true later the same day:
`ttc_read_carrier_screening` exists in `ttc_reads_getting_ready.dart`, it is
about thalassemia carrier screening (HbA2 by HPLC), and
`ttc_focus_getting_ready.dart:279` carries a tile that opens it. Nothing is
waiting on anybody.

Because this entry still said otherwise, "confirm the carrier screening test"
was reported to the user on 2026-09-05 as the **first blocker** in a summary of
what the TTC doors still need. It was not a blocker and had not been one for a
day.

**This is the third time in this stage that a stale `STILL-OPEN` entry has been
repeated as fact** (see §18.2 and §24.7). The pattern is always the same and it
is worth naming: this document is trusted precisely because it is the place
things are written down, so nobody re-derives it — which makes a wrong line here
more expensive than a wrong line in code, where the compiler or a test would
disagree. **When closing an item, edit its section. Do not only add a new one
further down.**

The original entry, kept because it records why the article was held at first:

---

### ~~23.2 The carrier screening article is NOT written — WAITING ON YOU~~

The brief lists *"The carrier screening that matters in India"* and says, in its
own words, to confirm which screen is meant with the content author before it
goes into copy. It reads like **thalassemia carrier screening**, and "reads
like" is not good enough when naming a medical test to somebody who may go and
order it.

**So there is no tile and no placeholder.** A card whose article does not exist
opens nothing, and the reachability test would fail the build — correctly.

**What is needed from you:** confirm the test. If it is thalassemia carrier
screening (HbA2 / HPLC), say so and it is written the same day. It is a real
gap for an India-first product — carrier frequency is high in several
communities here and it is the one preconception test most Western guidance
does not emphasise.

Partly covered meanwhile: `ttc_read_preconception_tests` carries a "Being a
carrier is not being ill" section, so the subject is not absent from the door.

### 23.3 The habit trackers WERE merged — DONE 2026-09-04, this entry was stale

⚠️ **CORRECTED 2026-09-05. Second stale entry in this section** — see §23.2 for
the first, and the rule that came out of it: *when closing an item, edit its
section; do not only add a new one further down.*

The merge shipped the day after this was written. `kTtcHabitMerge` in
`ttc_log_store.dart` maps `sleep` / `exercise` / `stress` / `lifestyle` onto
`habits`, **applied on read rather than as a one-off rewrite** — because the
cloud table keys on the tracker id too, so a device that migrated locally would
pull the old rows straight back on the next sync. Nothing is destroyed; a revert
is deleting the map. It is safe only because the nine field ids were unique
across all four trackers, which is written down there.

The original entry follows, because its reasoning is why the merge took the
shape it did:

---

### ~~23.3 The habit trackers were NOT merged — DELIBERATE DEVIATION~~

The brief says "ONE tracker, reuse and consolidate the separate
sleep/movement/stress trackers". **One destination was built; the stores were
not merged.**

`TtcLogStore` keys every entry as `tracker/field/day`. Merging three ids into
one either strands every row a user has already logged or needs a migration
that rewrites her history — on a store whose whole promise is that it records
without judging. A shipped store with real entries is not a thing to restructure
for a layout.

So `ttc_habits` gathers four trackers (sleep, exercise, stress, **and
lifestyle** — alcohol and tobacco live there, and the brief names those as two
of the four habits) in one place, each still writing where it always wrote.
Nothing migrated, and the Tools hub keeps all eight.

**If they should genuinely become one tracker, that is a data decision with a
migration attached and it needs saying explicitly.**

⚠️ **No streaks, no score, no "3 of 4 today".** Habit UI reaches for those by
reflex, and every one turns "I did not sleep well" into a failure — on a screen
opened by somebody already wondering whether her body is the problem. Each row
shows days recorded, which is a fact about her logging rather than a verdict.

### 23.4 A twelfth tile format — `TtcDoTile`, chip "Do"

Same argument the ninth and tenth were added under: the alternative was
`TtcToolTile` putting the chip **"Tool"** over "Habits worth building now". A
tool is something you operate and put down; sleep and movement are things you do
for weeks. The chip is the promise about what happens when she taps.

The sealed union made both call sites fail to compile the moment it was added,
which is the point of it.

### 23.5 Three test assertions were quietly gates on future doors

Worth recording as a pattern, because it happened three times in one build:

* `ttc_focus_page_test.dart` — "every carousel has cards" and "every video
  declares a slot" each opened with `expect(..., isNotEmpty)`. Written when the
  group was pinned to conceiving; once it started iterating every page, those
  became **"every door must contain a carousel and a film, forever"**. Getting
  ready has no carousel and that is correct. Both re-homed to the pinned
  conceiving group as "this page uses both".
* `ttc_focus_groups_test.dart` — "the conceiving door is still one long scroll"
  looped every page *skipping pcos and infertility*, so any new grouped door
  failed it. Now names conceiving directly, and a genuinely useful guard was
  added in its place: **a grouped page must tag every section**, since an
  untagged section on a grouped page renders under no tab at all.

The shape of the mistake: a rule written while there were three of something
becomes a rule about the fourth. Worth watching for on door five.

### 23.6 What was reused, and what the door gained

**Reused, unchanged:** `ttc_read_three_months_before`, `ttc_read_folic_acid`,
`ttc_read_preconception_tests`, `ttc_read_stress_fertility` (Mind and body stays
its owner), `ttc_read_whose_side` (His side stays its owner), and the surfaces
`ttc_nutrition`, `ttc_supplements`, `ttc_vaccinations`, `ttc_tests`,
`ttc_precheck`, `ttc_precheck/lifestyle`.

**New articles:** `ttc_read_what_to_cut`, `ttc_read_supplement_timing`,
`ttc_read_weight_kindly`, `ttc_read_coming_off_birth_control`,
`ttc_read_meds_and_conditions`.

**Two films stopped being invisible.** `ttc_vid_three_months_before` and
`ttc_vid_preconception_tests` were already written, chaptered and waiting on
files in `ttc_videos_data.dart`, and were reachable from nowhere — this area had
no page to put them on. Still placeholders; still owed the actual footage.

**Added, not in the brief:** a "Keep the reports together" tile pointing at
Records. A door that sends somebody to order six tests and offers nowhere to put
the results creates a shoebox of paper.

⚠️ **Clinical read owed on the four new articles**, as with the IVF set. The
byline is inherited from the door, not earned on these.

### 23.7 The journey it replaces is untouched

`kTtcPreconceptionReadiness` in `ttc_journeys.dart` — six steps, ten elements,
every one of them re-slotted into the new page. It stays on disk and stays
registered; `ttcFocusPageFor` is checked before hubs and journeys, so the page
wins. Nothing was deleted to make room, and reverting is removing one line from
`kTtcFocusPages`.

The hub's `kTtcActPreconceptionReadiness` "coming soon" branch in
`ttc_home_v3.dart` is now unreachable through the bracket. Left in place — it is
the fallback if the page is ever unregistered.

---

## 24.0 The TTC product flow, from the design project — 2026-09-03

Three screens — categories, shelf, product — built from "ParentVeda Product
Flow" and wired **only into the V3 doors**, as asked.

**Where to look:** any V3 door → a product tile → the product page → "Everything
in {category}" → the shelf → "The other shelves" → categories. Surface id
`ttc_shop`.

| File | What it is |
|---|---|
| `lib/screens/ttc/ttc_shop_v3.dart` | All three screens, one set of components |
| `lib/ttc/ttc_products_data.dart` | The model grew 6 fields; a tenth product added |
| `test/ttc_shop_test.dart` | 27 tests — honesty, plus the five in §24.8 about how it draws |

---

### 24.1 The old product surfaces are untouched — INSTRUCTION, NOT OVERSIGHT

The brief says three screens replace nine across all stages. They do not.
`products_screen.dart`, the five parenting surfaces and the Guide hub are all
still live and unedited. Asked for directly: *"apply this screen or wire the
screen only for the trying-to-conceive V3 ones. Don't mess around the old
random product screens."*

`ttc_products_screen.dart` also stays, still routed at `ttc_products`, because
Ask Veda's deep links land there (`ttcprod_folic` → its `focusId`). Two surfaces
over one catalogue is the drift risk, and it survives here only because both
read `ttcProducts` and neither holds a copy of any text.

**Open:** whether the old flat library retires once Ask Veda's pointers are
repointed. Not urgent, and not to be done quietly.

### 24.2 `pvScore /100` was NOT ported — and this is the important one

The parenting design puts a big number at the top as its "one large true fact":
**88/100**, with "92% of parents recommend" and "86% of experts say buy".

**None of those three exist for TTC and none can be honestly derived.** There is
no review corpus, no expert panel and no rating history behind these ten
entries. A 0–100 figure computed from nothing would be the most
authoritative-looking thing on the page and the least true.

**Replaced by `TtcEvidence` — strong / mixed / thin — which is a real fact and
the more useful one.** For a fertility product the question is almost never "is
this a good bottle", it is "does this do anything". Held by a test.

### 24.3 There is no Buy button — MISSING DATA, NOT A REFUSAL

The design's sticky buy bar and affiliate interstitial are the sharpest things
in it, and the interstitial's last line — *"it never changes what we recommend
or how we rate a product"* — is the whole reason a trust-first page may carry a
Buy button at all.

**`TtcProduct` has no retailer, no URL and no affiliate relationship.** A Buy
button that opens nothing is worse than none, and building the interstitial now
would be a screen nothing can reach. The sticky bar carries price and Compare.

**Needs, before it can be built:** a retailer/URL field, an affiliate decision,
and the Brand Studio rules applied (rank floor, never a score bonus, never the
top slot, research pages stay clean).

### 24.4 A tenth product was added, and it is the one we say no to

`fertility_blend` — *"A 'fertility blend' multivitamin"*, band **skip**,
evidence **thin**.

The data file's header has claimed since it shipped that *"several of them exist
mainly to talk a couple out of buying something"*. **None of the nine actually
did** — every one was worth buying in some circumstance, which made the honesty
structural rather than visible. A shelf where nothing is ever rated "generally
not needed" cannot be told apart from a shelf with no way to say it.

`ttc_read_supplement_timing` already says this in prose. Saying it on the shelf,
where the money is spent, is worth more. No brand is named and the "what's good"
column is honestly filled rather than left empty to make the point.

Held by a test: at least one product must carry `skip`, and it must be readable
on the shelf.

### 24.5 Four blocks render as honest empties, not as invention

* **Ratings** — no corpus. The block states what it will hold, and is not
  tappable.
* **Research** — the evidence band is real and the reads carry sources;
  per-product study cards would mean summarising trials nobody here has read.
* **Photography** — the hatch block at the real 230pt, so nothing reflows when
  photographs land. **Ten product photographs are owed.**
* **Ingredients** — dropped entirely. It is a skincare block; a folic acid
  tablet's ingredient list is folic acid.

### 24.6 What is genuinely thin, and worth saying out loud

**The catalogue is ten items across five categories** — Books and Wellness hold
one each. The shelf grid, the compare tray and the filter both work and are
barely exercised at this size.

That is not a bug and the fix is not padding. If the shelf is to feel like a
shelf, the honest additions are things people in this stage actually buy:
prenatal multivitamins (as a band, not a blend), pregnancy test strips in bulk,
period-tracking thermometers, his-side supplements, and a wellness shelf that
is mostly `skip`. **Each needs the same treatment as the ten: a band, an
evidence rating, and a caveat that is never empty.**

### 24.7 Not built from the design, and why

* **Search with recent + popular** — the categories screen has no search. Ten
  products across five rows is a list you read, not a corpus you search.
* **A price filter** — STALE ABOVE, CORRECTED 2026-09-04. The shelf no longer
  has a chip row; it has a Filters **button** opening a sheet over three real
  dimensions (band, evidence, whose it is) plus a separate sort control, which
  is what the design specifies and what I should have built the first time.
  Brand became a field, so a brand filter is now possible and simply is not
  built. **Price still is not filtered, deliberately** — four bands over ten
  items leaves two empty and one holding everything.
* **Related guides rail** — a product does not yet know which reads relate to
  it. Worth adding as a `readIds` field; it is the cheapest real improvement on
  this list.
* **Loading skeletons** — everything is compiled-in constants. There is no load.

---

### 24.8 The three device-visible defects, and why the suite was green — 2026-09-04

Reported from screenshots after two rounds of me fixing the wrong thing:
*"yellow lines still visible, search bar still not fixed and for compare see in
app we have a whole compare screen already present."* All three were real, all
three shipped past a full green run, and each fails in a way worth writing down
because the mechanism is general.

**1. The amber underlines were never an overflow.** I read them as
`RenderFlex` overflow twice and fixed two genuine but unrelated overflows.
Flutter draws a **dashed amber underline under every string** in a region that
has no `Material` ancestor, and **yellow-and-black diagonal hatching along one
edge** for overflow. In a screenshot they are both "yellow marks near text".
The compare bar, the compare pill and the sticky buy bar are all `Positioned`
children of a `Stack` that is a *sibling* of the `Scaffold`, so nothing above
them supplies one. Each is now wrapped in `Material(type:
MaterialType.transparency)`, which costs nothing and also gives them ink
splashes.

**2. `border: InputBorder.none` is not an override of an input theme.** The
app's global `InputDecorationTheme` sets `filled: true` with
`scheme.surfaceContainer` plus its own focused border
(`lib/theme/app_theme.dart:489`). A widget-level `border:` replaces only the
*fallback* — `enabledBorder` and `focusedBorder` still come from the theme, and
`filled` is untouched. That is why a field explicitly asked to be plain
rendered as a lilac panel with a purple ring inside a white bar. Every slot the
theme fills now has to be turned off by name.

**3. Compare is a screen now, not a bottom sheet** — `TtcCompareScreen`, built
on `ProductsCompareScreen`'s anatomy: three states (nothing / one / two
picked), overview cards you can remove in place, one column-divided table over
the *union* of the two spec lists, and a buy bar per product. The shop entry's
compare row also opened nothing below two picked, which reads as a dead control
and was reported as one; it opens at any count now, because there is a useful
page at zero and at one.

**OPEN — the parenting compare screen could not simply be pushed, and the fix
for that is a refactor nobody has approved.** `ProductsCompareScreen` is typed
on `PpProduct`, reads `PpCompareStore`, calls `openPpTab(context, 4)` in its
empty state, and is painted in `ppPurple` on `ppBg`. Converting a `TtcProduct`
across drops `band` and `evidence` — the two facts the TTC shelf exists to show
— and seeding `PpCompareStore` with TTC items would surface them on the
parenting product cards, which read the same store. So there are now two
comparison screens over one layout.

The honest resolution is to lift the layout into one widget both stages hand
their own products to. It edits shipped parenting code, so it waits for a
decision rather than riding along in a bug-fix pass. **Until then, a change to
either comparison has to be made in both.**

### 24.9 Still no "Add to cart" — NOT AN OMISSION

Asked for directly. There is no cart in the app: no store, no line items, no
quantity, no checkout, and every buy control in every stage hands off to a
retailer. A button that adds to a basket nobody can open is worse than no
button. **Needs a decision:** either a real basket (a store, a screen, a
persisted list, and a hand-off that carries several products at once), or
"Buy now" stays the only commit action. The second is what ships today.

---

## 25.0 His side, rebuilt from the brief — 2026-09-04

Fifth door on the PCOS/IVF/Getting-ready shape, from `his_side_rebuild.pdf`.
Two parts: the restructure, and the one net-new tool.

**Where to look:** TTC home → **His side**. Five tabs, Understand first.

| File | What it is |
|---|---|
| `lib/ttc/focus/ttc_focus_his_side.dart` | The page: 5 groups, 9 sections, 16 tiles |
| `lib/ttc/ttc_semen_limits.dart` | The WHO 2021 reference limits, as data |
| `lib/ttc/ttc_semen_reading.dart` | The tool's logic. No widgets in it |
| `lib/screens/ttc/ttc_semen_report_screen.dart` | The tool's screen |
| `lib/ttc/reads/ttc_reads_his_side.dart` | +4 articles |
| `test/ttc_his_side_test.dart` | 34 tests, all about safety rather than layout |

---

### 25.1 The WHO numbers stopped being prose — THE IMPORTANT STRUCTURAL CHANGE

Until now the four reference limits existed in exactly one place: a bullet list
inside `ttc_read_semen_analysis`, doctor-written and reviewed as prose. Correct,
while nothing computed with them.

The tool computes with them. The obvious move was to type `16 / 42 / 30 / 4`
into it, and it is the wrong one — **two copies of a clinical threshold in one
app is how an article and a tool quietly disagree after a guideline update.**
The brief says so: *"pull the reference limits from the same doctor-reviewed
source the articles use, do not hardcode independent numbers."*

So the numbers moved into `ttc_semen_limits.dart` and **the article's bullets
are now generated from them.** One edit, both places. A test asserts every
figure still appears in the article's rendered text.

The framings moved with the numbers rather than being left behind: the
strict-morphology caveat and the progressive-motility remark are fields on the
limit, so no caller can render a comparison without them.

### 25.2 The tool's rules are the tests, not the prose

`ttcReadSemenReport` is one pure function with five routes. Every rule from the
brief is asserted:

* **No verdict, on any path.** Nine shapes of entry are run through a banned-
  phrase scan — "you are fertile", "infertile", "your chance", "score". And
  structurally: `TtcSemenReading` has no field a score could live in.
* **Order is the safety.** A red flag beats good numbers; a red flag beats
  azoospermia; azoospermia beats a low number. A man with a lump and a normal
  count must be told about the lump, and a repeat suggested first would delay
  it. ⚠️ **Reordering those branches is a clinical change, not a refactor.**
* **A single low number is never a conclusion.** First test → repeat. Repeat →
  have both read together, never a third.
* **Exactly at the limit is in the usual range**, not below. Held for
  morphology at 4, where it matters most.
* **The abstinence flag survives good numbers** — a sample produced after
  twelve days is not comparable to the reference limits whatever it said.
* **Never advise stopping a prescribed medicine.** Testosterone is one of the
  four red flags, and "stop taking it" is exactly what a man reads into that.

### 25.3 The three original articles were not touched — DELIBERATE

Step 7 says migrate without losing content, and the brief is emphatic that this
is the strongest material in the stage: doctor-authored, WHO 2021, India
specifics (gutka and khaini named rather than "tobacco", real INR costs).

**So they were reused whole rather than split.** A section lifted out of an
argument reads as a fragment, and the argument is the part that took a doctor to
write. The four new pieces are written alongside them.

⚠️ **Clinical read owed on the four new articles.** They carry Dr. Vikram Nair's
byline, inherited from the door rather than earned on these.

### 25.4 What is single-sourced, and the one reference that was missing

* **His side owns male-factor content.** Getting ready's "His part" and IVF's
  tests card already named its reads by id. **The fertile-window door did
  not** — its one section about him had no way through to the area written
  about him. Two referencing tiles added there.
* **"Keep his reports with yours" and IVF's "Keep your reports together" are
  one surface** (`ttc_records`) shown in two doors. Held by a test that also
  fails if one door lists it twice.
* **"The half nobody talks about" is one offering id**, on the headline and in
  tab three.
* **"His emotional side" is a door.** A `TtcDoorTile` to `ttc_mind_body`, the
  area itself, not one of its articles (it was `ttc_read_stress_fertility`
  until 2026-09-06). The brief: *"do not build stress content here."*

### 25.5 Brought back to the brief — 2026-09-06

The first build substituted the nearest existing thing for several tiles the
brief named. The user's rule, now in the door's header comment: **reuse only
what IS the thing, or can be made so with a small change. Never pick the
closest thing and put it there because it sounds like what was asked.** Every
substitution below was undone against that rule.

| Brief | Was | Now |
|---|---|---|
| "What three months looks like" — Guide, the 12-week plan | article tile opening `ttc_read_heat_habits` | `TtcGuideTile` → `ttc_read_three_months`, written: day one, weeks 1 / 2–6 / 7–11 / 12 |
| "Zinc and CoQ10, honestly" — Article + Product | a product shelf only | `ttc_read_zinc_coq10` written (Cochrane, the MOXI trial, trial doses, INR), shelf beside it |
| "The case for testing early" — short card that bridges into tab 2 | opened `ttc_read_semen_analysis`, same as tab 2's first tile | `ttc_read_case_for_testing` written; read-next is the test article, next step is the tool |
| "Reasons to be seen sooner" — calm red-flag card (reuse callout) | absent | `pinnedRedFlagReadIds: ['ttc_read_whose_side']` on the Talk group. The doctor's own callout, one copy, visible without opening anything |
| "What he can track" — Tool, private, his side | `ttc_tools`, the whole hub | new surface `ttc_partner_health` → the partner-health tracker, directly |
| "Talk / Consult (andrologist)" ×2 | `kTtcActConsult`, the consults shelf | `kTtcOfferingAndrologist` (`ttc_consult_androl`); `openTtcFocusTile` resolves an offering id on a Talk tile |
| Step 7, "remove the accordions" | three `collapsible: true` sections | unfolded; content untouched |
| Tool: volume input | in the logic, not on the form — a dead field | asked, optional, reported with no line |
| Tool: abstinence "in days" | five buckets, "under 2" stored as 1 | a number of days |
| Tool: "Keep his reports with yours (saves it)" | opened the folder, saved nothing | writes a `TtcRecord` (`testId: 'semen'`, `forPartner: true`, value = every number in report order, note = first/repeat + abstinence), once per reading, then opens the folder. `TtcRecordsStore.ensureLoaded()` added — see below |
| Tool: "opens the andrologist consult" | consults shelf | the offering, with the shelf as fallback if it is ever removed |
| Tool: usual range → "point to couple-level readiness in IVF and IUI" | one sentence, no link | `coupleReadiness` on the reading; a quiet gateway card in the IVF hue opens the IVF door, whose first tab is "Is it time to get help?" |

**Why `ensureLoaded` exists** — a general fact, not a local fix. The records
store loads its cache in its constructor, asynchronously, and the load does
`_items..clear()..addAll(cached)`. Any caller that constructs the singleton and
writes in the same breath races that clear: the new row goes in, the load
completes, the row is gone. Every earlier caller was a screen that only read,
so a listener rebuild after the load hid the race. The tool is the first
write-before-read caller, and it lost its record until the write awaited the
load. A store that can be written should expose its load as a future.

**Still deliberate:**

* **The three original articles are reused whole** (§25.3). The brief's "split
  the long articles into the rails" is met by the seven written pieces around
  them rather than by cutting the doctor's argument into fragments.
* **The masterclass points at `ttc_partner_workshop`.** There is no
  `ttc_course_male` offering. Rename it in the catalogue if "The half nobody
  talks about" should be its public name.
* **Tab 5 (Talk) stays separate**, with the red-flag card now pinned on it.
* **The bridge is content, not a tab switch.** "The case for testing early"
  ends where tab 2 begins; it does not change the selected tab on tap, because
  no tile on any door does and a tile that navigates the page it sits on would
  be a new kind of thing.

### 25.6 What is left — and it is no longer code

**Audited 2026-09-06 against `his_side_rebuild.pdf` line by line: every step of
Part 1 and every rule of Part 2 is built, wired and tested.** Ten reads exist,
all twenty tile targets resolve, the three referenced film slots are defined,
both supplement products are in the shelf, `test/ttc_his_side_test.dart` passes
at 48. What remains needs a camera, a photographer or a doctor — not an editor.

**Three films, not two.** `ttc_vid_whose_side` (288s), `ttc_vid_semen_analysis`
(342s) and `ttc_vid_heat_habits` (306s) — 15 minutes 36 seconds, 12 chapters,
all written with expert names and takeaways. The third is the hero of
`ttc_read_heat_habits` rather than a door tile, which is why an earlier version
of this section undercounted it. **No film exists for any of them**, and the
tiles render `PvVideoPlaceholder` honestly rather than a play control that
plays nothing (`PvVideoSlot.isLive` is false while `url` is null).

**One hero photograph.** `heroImageUrl` is an Unsplash placeholder. The brief
for this door is specific about the frame: a couple, not a lone man and not a
woman — see the two corrections in the door's header comment.

⚠️ **Seven of the ten reads claim a clinical review that never happened.**
Three originals say *"reviewed August 2026"* and were genuinely written by a
doctor. The four of 2026-09-04 and the three of 2026-09-06 carry the same
byline shape — four say August, three say September — and **none of the seven
has been past a clinician.** That is a byline asserting a review that did not
occur, which is worse than no byline. Either get the read or strip the date.
`ttc_read_zinc_coq10` is the most perishable: it quotes trial doses and Indian
retail prices.

**Twenty rail-card illustrations**, part of the 170 across all seven doors.
Every tile is a flat tinted block today.

**Two small decisions, neither blocking:**

* The tool saves the record dated **today**. A "date on the report" input is
  the one field the brief's save could still want, since a report is often
  weeks old by the time it is typed in.
* The masterclass points at `ttc_partner_workshop`. Rename it in the catalogue
  if *"The half nobody talks about"* should be its public name.

---

## 26.0 After a loss, rebuilt from the brief — 2026-09-04

Sixth door, and the one that departs from the shape on purpose.

**Where to look:** TTC home → **After a loss**. Four tabs, **Your body** first.

| File | What it is |
|---|---|
| `lib/ttc/focus/ttc_focus_after_loss.dart` | The page: 4 groups, 6 sections, 11 tiles |
| `lib/screens/reader/pv_reader_screen.dart` | `openAtHeading` — the mechanism behind "promote" |
| `lib/ttc/ttc_focus_data.dart` | `atHeading` on Guide/Article; `pinnedRedFlagReadId` on a group |
| `test/ttc_after_loss_test.dart` | 13 tests, mostly about invisible failures |

---

### 26.1 "Promote" needed a mechanism, or it would have been a lie

The brief asks for six cards that reference a **section** of an existing
article — single source, shown twice, never copied.

Built with `readId` alone, all six open the same article **at the top**, and a
woman who tapped *"Rh status and retained tissue"* is left scrolling two
thousand words for the paragraph she was promised. That is worse than a copy,
because it looks like it worked.

So `PvReaderScreen` gained `openAtHeading`, and the tiles gained `atHeading`.
**It matches on heading text, not an index** — an index silently points at the
wrong section the day somebody inserts a paragraph, and a wrong section is
unnoticeable in review. A heading that no longer exists opens at the top, which
is the safe failure, and a test asserts every anchor still resolves so it is not
also a silent one.

### 26.2 Three deliberate departures from the other doors

* **"Your body" is the default tab.** Every other door opens on explanation.
  Days after a loss the first need is physical reassurance and the hospital red
  flag, not causes.
* ⚠️ **There is no tool, and there must not be one.** The only candidate is a
  recovery tracker, and turning miscarriage recovery into a number to log is the
  one place a tool does harm rather than help. Held by a test that fails if any
  group grows a `toolSurfaceId` or any tool tile appears.
* **Nothing is sold from the top.** Every other door carries a course in the
  headline slot; this page has none. The cohort sits last, on the Support tab,
  described as four sessions with people and carrying no price — which is the
  bracket's own stated rule, "reached through a person, not a product row".

### 26.3 The red flags are pinned, and they are the articles' own words

Two tabs pin a callout above their rails. **The group names a read; the screen
renders that read's `whenToSeeSomeone`.** Typing the words onto the group would
put a clinical warning in two places — the doctor-reviewed article and a data
file nobody reviews — and the day they diverge, the one on the landing is the
one she reads first.

⚠️ **The Support flag carries the self-harm routing**, which the brief says
must not be lost or buried. Rendering the callout whole rather than an excerpt
is what guarantees that, and a test asserts the sentence is still in it.

### 26.4 Three cards the brief lists that are NOT built, each with a reason

* **"What recurrent-loss investigation looks like"** — that content is the third
  *paragraph* of "When investigation is worth asking for", not a section of its
  own. A second card would anchor to the same heading and land in the same
  place, which is exactly the fake promotion the anchor exists to prevent.
  **Fixing it means splitting a doctor-reviewed article**, which the brief's own
  rules forbid. Your call: split the article, or drop the card.
* **The optional "On trying again" video** — there is one loss video slot in the
  catalogue and it is already used. Inventing a second id would put a
  coming-soon card on the page that no file can ever be mapped to. One entry in
  `ttc_videos_data.dart` away.
* **The bleeding infographic** — `TtcInfographicTile` requires two real columns
  and there is no empty state, correctly. An infographic about normal bleeding
  after a miscarriage is clinical content a doctor writes.

  **The slot is not empty.** It carries the article's own "The bleeding"
  section, promoted — the exact material the infographic will illustrate. When
  the picture is supplied, the guide steps aside.

### 26.5 Written rather than stubbed — two myth cards

`TtcMythTile` needs both halves to exist, so the two new micro-cards were
written rather than placeheld:

* **"You can ovulate before your first period"** — from the callout inside the
  recovery article. It is the piece of information most often left unsaid, and
  finding out afterwards is worse than reading it.
* **"A miscarriage is not a pattern"** — one loss does not change the odds for
  the next pregnancy.

Both restate material the articles already carry, in the myth/fact shape the
brief asked for. ⚠️ **These two are the only new prose in the area, and they
have not had a clinical read.** Everything else is the two Dr. Ananya Rao
articles, untouched.

### 26.6 Still owed

* **The old landing route.** The brief says to remove the now-orphaned route to
  "Understand recovery & trying again". The focus page is checked before hubs,
  so the bracket already opens the new page — but the hub config and its
  `kTtcActLossRecoveryLibrary` action are still in `ttc_hubs.dart`. Left in
  place as the fallback if the page is unregistered; **worth deciding whether it
  retires.**
* **One hero photograph.** Unsplash placeholder, same as three other doors.
* **The closing line** the brief specifies — *"This settles when you know your
  body is recovering normally…"* — is not rendered. `TtcFocusPage` has no
  closing-line slot, and adding one for a single door is a change worth asking
  about rather than assuming.

---

## 27.0 The fertile-window door caught up to the shape — 2026-09-05

The first door built in the stage was the last one still on the old format.
Asked for directly: *"the fertile window, that first door is using the old
format. If you compare it with PCOS and IVF… implement the current format on
it. Structure wise."* Structure only — no copy was rewritten and no tile was
added or removed.

**Where to look:** TTC home → **Conceiving & the fertile window**. Five tabs,
Your window first.

| File | What changed |
|---|---|
| `lib/ttc/focus/ttc_focus_conceiving.dart` | `groups` added, seven sections tagged, one moved |
| `lib/ttc/ttc_focus_data.dart` | A stale comment on `TtcFocusSection.group` |
| `test/ttc_focus_groups_test.dart` | The guard test inverted; three new |
| `test/ttc_focus_page_test.dart` | Two assertions that were right for a scroll |

---

### 27.1 The two orderings were arguments, and a rail does not have an order

This is the part worth reading. Two comments in the file were **load-bearing
rationale attached to section order**:

* *"HIS SECTION COMES BEFORE HERS, AND THAT ORDER IS THE POINT"* — a male
  factor is involved in about half of couples who take longer than expected,
  and in this market the advice, the testing and the blame land on her.
* *"THE PAGE ENDS BY ROUTING TO A PERSON"* — CLAUDE.md's rule that anything
  clinical routes calmly to a doctor.

**In a grouped page neither sentence can be true, because nothing is "further
down" any more.** A tab is on the rail or it is not. Restructuring silently
would have left two comments explaining an order that no longer existed — the
worst kind of stale, because it reads as a reason and enforces nothing.

So both were re-homed onto **rail position**, which is stronger than what they
had: his tab sits before hers on a rail that is permanently visible at the same
size, rather than first in a scroll most people never finish; the doctor is the
last card and always one tap away rather than one long scroll away. Both are
now **asserted in `ttc_focus_groups_test.dart`**, because a rationale nothing
enforces is a rationale that quietly goes.

**The general lesson:** when a comment justifies an *ordering*, changing the
container invalidates the comment. Grep for the rationale, not just the code.

### 27.2 Grouping made one mis-filing visible

"Does stress stop pregnancy?" sat fifth, between what she should do and the
doctor. It is the third of three myth-corrections about the act of trying —
beside "does more sex help?" and "does position matter?" — and it only sat where
it sat because a scroll has room for anything. It moved into **How to try**.

⚠️ **The near miss: it is NOT under "What she can do".** Filing stress under her
is precisely the reflex the door's own his-before-hers argument exists to
correct. There is a test for it.

### 27.3 The hero film came off, and nothing was orphaned

`ttc_conceiving_intro` was the page's hero video. **It has no entry in
`ttc_videos_data.dart` at all** — a bare slot id, so the first door of the stage
opened on a coming-soon box. Commented out, matching PCOS and IVF.

The check that mattered before removing it: the four TTC films that *are*
written and chaptered each have a tile somewhere. This one never did, so there
was no film to relocate. The declaration in `ttc_hubs.dart:107` is untouched and
still works if the page is ever unregistered.

### 27.4 The guard test inverted, and that is the test working

`ttc_focus_groups_test.dart` carried *"the conceiving door is still one long
scroll"*, guarding against the door drifting into the grouped shape as
somebody's tidy-up. The shape has now been asked for, so the guard was
**re-decided rather than deleted** — it became the mirror question: has any door
drifted *back* to a plain scroll, stranding its `group` tags?

### 27.5 Still owed

* **A fifth hero photograph.** This door now carries an Unsplash placeholder
  like the other four, so the count in §24–26 goes from four to five.
* Nothing else. No copy was touched, no tile added, no read written.

---

## 28.0 Mind & body, rebuilt — the stage is complete — 2026-09-05

Seventh and last TTC door, from `ParentVeda_Mindbody_rebuild_final.pdf`
(30 Aug 2026). **Every bracket in the stage now opens a focus page and none
opens a hub.**

**Where to look:** TTC home → **Mind & body**. Five tabs, **Today** first, and
Today is a do-it screen rather than a rail.

| File | What it is |
|---|---|
| `lib/ttc/focus/ttc_focus_mind_body.dart` | The door: 5 groups, 11 sections |
| `lib/ttc/ttc_practice_data.dart` | The 12 practices, defined once |
| `lib/ttc/ttc_mind_today.dart` | Rotation + done-today. No widgets, no store |
| `lib/screens/ttc/ttc_mind_today_screen.dart` | The do-it screen |
| `lib/screens/ttc/ttc_practice_screen.dart` | One screen for all 12 practices |
| `lib/ttc/reads/ttc_reads_mind_body.dart` | +4 guides |
| `test/ttc_mind_body_test.dart` | 24 tests, mostly about the position |

---

### 28.1 The brief asks for something arithmetic cannot give — SAY IT PLAINLY

*"Rotate so the same card does not repeat within seven days."* Each library
holds **six** cards. Seven days without a repeat needs seven distinct cards;
with six, the seventh day must repeat one. Pigeonhole, not an implementation
problem.

Built as the strongest thing available: a strict cycle through all six before
any returns — **no repeat within six days**, with the gap always exactly six
rather than random. A shuffle-with-memory was rejected because it can serve the
same card on three consecutive Mondays, and somebody who only practises at the
weekend then sees one card forever.

**To get to seven: one more card in each library.** That is the whole fix.

### 28.2 Six of the twelve durations are OURS, not the brief's

The brief gives a time for five cards ("3 min" ×3, "ten-minute walk",
"two-minute" ×2) and is silent on the rest. A Do card without a time cannot be
planned around — "have I got time for this before work" is the only question
anyone asks of one — so these were filled in and are listed here for
correction:

| Practice | Ours |
|---|---|
| Hip openers: butterfly and slow lunge | 5 min |
| Slow sun salutation, three rounds | 6 min |
| Long out-breath, in four out six | 3 min |
| Alternate nostril breathing | 4 min |
| Box breathing | 3 min |
| Ten slow breaths together | 2 min |

### 28.3 "Two-minute calm listen" was built without audio, deliberately

The title reads as a guided audio track, and we have no audio pipeline in this
stage. Rather than ship a card that opens a coming-soon box, it is built as an
**attention practice** — sit still, find the furthest sound, then the nearest,
move between them. That is a legitimate reading of the name, it needs no asset,
and it works today. **If an audio track was intended, this one needs rebuilding
rather than adjusting.**

### 28.4 Two myth cards are written out, and the brief says promote

`TtcMythTile` needs both halves as literal strings, so there is no way to point
one at a section and have it render. "Stop thinking about it and it will happen"
and "Does it make a smarter baby?" both restate material the two locked articles
already carry. Same compromise as the two After-a-loss myth cards. ⚠️ **With the
four new guides, that is six pieces of new prose in this area owed a clinical
read.**

### 28.5 What the model gained, and why each was on the second asking

Three changes to shared code, and none of them was built for this door alone:

* **`TtcFocusPage.closingLine`.** After a loss asked for a closing line on
  2026-09-04 and was refused (§26.6) — one caller does not justify a field on a
  shared model. Mind & body asked in the same words, so it is a field now, and
  **After a loss can have its line by filling it in.**
* **`TtcFocusGroup.pinnedRedFlagReadIds` is a list.** It was singular, which fit
  After a loss only because that door wanted its two flags on two different
  tabs. Mind & body wants both on Talk, from two different articles. *A field
  whose cardinality was inferred from the first caller; the second caller is
  where you find out.*
* **`TtcDoorTile`, the 16th format.** The first tile whose destination is
  another focus area rather than a piece of content. Only "His part of this"
  needs it. ⚠️ **The brief marks nine cards `reference` and eight of them are
  NOT this** — they are ordinary Article tiles carrying Getting ready's own
  `readId`, which is what single-sourcing actually looks like. There is no
  "Reference" chip, because that word describes our content model rather than
  what happens when she taps.

### 28.6 The old landing is gone; the old ritual screen is not

`kTtcMindBody` is commented out of `kTtcHubs`, so the two-door hub has no
entrance. `ttc_ritual` — the five-part "Trying Together" ritual — **still
exists and is still routed**, because it is reachable from the bracket's
Activities layer (which the workbook wants live) and from `ttc_journeys.dart`.

**Open:** whether the ritual retires. It is now a screen with no door in front
of it, reached only from two registries. The five parts it teaches are covered
by the new practice library; what it has that the library does not is the
couple-together framing. **Needs a decision.**

### 28.7 Still owed

* **Clinical read on six pieces** — four guides (§28.4) plus two myth cards.
* **One hero photograph.** Unsplash placeholder, the sixth owed.
* **One film** — `ttc_vid_mind_longer_session`, written and chaptered, awaiting
  footage. Brings the stage's owed films to five.
* **The partner's Today is not wired.** The brief says *"Both partners see
  Today. Their picked cards may differ."* `ttcPracticeOfTheDay` takes an
  `offset` and `kTtcPartnerOffset` exists and is tested, but nothing on the
  partner surface calls it. **The logic is done and unreached — the wiring gate,
  recorded rather than claimed.**

---

## 29.0 The home hero: fixed height, and it speaks all cycle — 2026-09-05

From three Flo screenshots: *"the homescreen hero is fixed in size i mean height
wise and then the message also keeps on changing, which we lack… i guess mostly
its a loop."* Both were real, and the second was the bigger one.

| File | What changed |
|---|---|
| `lib/ttc/ttc_home_hero.dart` | **New.** The state machine, pure, no strings |
| `lib/screens/ttc/ttc_strings.dart` | 8 new strings for the four new states |
| `lib/screens/ttc/ttc_home_v3.dart` | `_WindowLine` chooses words; fixed height |
| `test/ttc_home_hero_test.dart` | +9, walking a whole cycle day by day |

---

### 29.1 The hero went quiet for half of every cycle, and no test noticed

It had five states, four of them refusals. The fifth said either "your fertile
days are here" or "your fertile days open in N days". **The moment the window
closed, `ttcFertileWindowNow` rolled forward onto NEXT cycle's window** — so
from then until her period arrived, roughly a fortnight, the hero said
*"Expected around 20 Sep to 25 Sep, based on your usual cycle"* and did not
change again.

Fourteen days of one unchanging sentence about a cycle she is not in yet, at the
point in the month she is thinking about this most. **Nothing failed.** Every
individual state rendered correctly; the hole was in the coverage. That is why
the new tests walk all 28 days rather than checking interesting ones.

Four states added, so the loop now closes: `windowOpen` (with days remaining),
`windowLastDay`, `waiting`, `periodDue`, `periodLate`.

### 29.2 What we did NOT copy from the reference, and why

Two of Flo's three hero lines are unavailable to us, and neither is a matter of
house style:

* **"Best chances of conceiving"** is a chance framing on the home screen — a
  personalised probability by implication, forbidden by CLAUDE.md and scanned
  for by `ttc_clinical_review_test.dart`. Ours says WHEN, never HOW LIKELY:
  *"Your fertile days end today"* carries the same information and promises
  nothing.
* **"Time for a pregnancy test in 10 days"** is a countdown to an OUTCOME, which
  `ttc_home_hero_test.dart` already forbade for the chapter copy. It turns the
  second week of the wait into a number getting smaller. **We count to her
  period instead** — the same arithmetic pointed at a cycle event rather than a
  verdict on her.

Also refused: the word **"late"**. It implies a schedule she failed to keep and
most people read it as a hint. The state says *"3 days past your usual length"*.
There is a test.

### 29.3 The height, and the thing fixing it alone would not have fixed

`blockHeight = 146`, measured against the worst case (two lines of headline, two
of body, plus the cycle-day row) rather than a typical one. The headline runs to
one line on most days and two on others, so the strip, the buttons and
everything below them sat at a different height depending on where in her cycle
she was.

⚠️ **A fixed box is not enough on its own.** With the footer left to flow, "Cycle
day 14" still hopped by a line between days *inside* a box that no longer
changed size. It is pinned to the bottom with a `Spacer`.

### 29.4 A regression I introduced, and the test that caught it

Replacing the open-window body with the new count dropped the dates — "1 Sep to
6 Sep" — which is the line that lets somebody plan a week.
`ttc_daily_insights_test.dart` failed on it. The body now carries both: they
answer different questions and there is room.

### 29.5 The hero follows the strip — CLOSED SAME DAY, from the screenshots

⚠️ **This was §29.5's open question and the answer was already in the
screenshots.** I asked whether the hero should follow the selected day. Looking
again at the reference: its strip sits on the **3rd** while TODAY is the **5th**,
and the hero reads *"today and 2 more days"*; move the strip to the 5th and the
same hero reads *"end today"*. It follows. The user's answer was one line: *"i
shared screenshot of flo see how they did, i guess they do and we can follow
same."*

Worth noting how the question arose. **Everything else in that header already
followed the selection** — the date above it, the insight cards
(`ttcPickForToday(now: selected)`), the symptom sheet, and the two actions,
which already dim on a future day (`enabled: !selected.isAfter(todayDate)`). The
hero was the single widget still reading today, so standing on the 3rd produced
a page about the 3rd with one sentence about the 5th in the middle of it, and
nothing on screen said which was which.

**The mechanism.** `TtcFertileWindow` carries `openNow` and `daysUntilOpen`,
both measured from today — using them is what pinned the hero. It also carries
`opensCycleDay` / `closesCycleDay`, which are *within-cycle* numbers describing
the same window in a frame that does not move. The state machine now compares
the selected day's cycle day against those.

Two states were added, and both exist to stop the change from lying:

* **`pastCycle`** — a selected day in an EARLIER cycle. We estimate ovulation
  for the cycle she is in, from that cycle's signals. Reconstructing a window
  for two months ago means assuming her usual length and her usual luteal phase
  and printing the result as history; she would have no way to tell it from one
  we actually estimated. So it refuses, and prints no cycle day.
* **`periodExpectedBy`** — a FUTURE day at or past the expected period. The
  strip runs six days forward, so on day 26 of a 28-day cycle she can select a
  day the arithmetic calls overdue and the calendar calls Thursday. *"3 days
  past your usual length"* is false about a day that has not happened.


### 29.7 The whole thing was dead on a clinic-run account — 2026-09-05

Reported from the device, after §29.1–29.5 shipped: *"nothing changed as i said…
Still your clinic holds. This is the line that I keep seeing again and again,
nothing changes."*

Correct. `ttcHomeHeroLine` opened with an early return on `clinicInvolved`, ABOVE
every state added the day before. On an account where a clinic runs the timing —
which is every IVF and IUI pathway — the hero could not reach any of them.

⚠️ **The field's own doc comment forbids exactly what I did with it.**
`ttc_chapter.dart:222`:

> *Convenience for the many surfaces that only care "is anyone else involved?" —
> a card heading, a disclaimer. **Anything that changes what is COMPUTED must use
> `behaviour` instead.***

And the refusal it was trying to enforce **was already enforced one layer down**:
`ttcFertileWindowNow` opens with `if (!today.behaviour.showsFertilityWindow)
return null`. The guard was not merely misplaced; it was redundant. Removing it
loses nothing — a test now walks all 28 days of a clinic-run cycle and asserts no
window state is reachable.

**What a clinic actually forbids is a prediction, not a fact.** Her cycle day is
her own logged period subtracted from the date — the one number on that screen
that is hers rather than ours. So a clinic-run cycle now leads on **"Cycle day
9"**, which moves every morning, with the clinic note as one short line beneath.
The old two-line body is commented out, kept for revert: it is good writing in a
slot that has to say something new daily, and the reasoning it carries already
lives on `TtcTreatmentEntryCard`, where somebody asking "why is there no
estimate" actually goes.

⚠️ **THE SUITE WAS GREEN THE WHOLE TIME, AND THAT IS THE PART WORTH KEEPING.**
Nine states, tested day by day across a whole cycle — and every one of those
tests ran as the DEFAULT pathway. They all agreed with each other and none of
them touched the branch that mattered. The gap was not which state was checked;
it was **which account the test ran as**. There is now a clinic-pathway group.

### 29.8 The gap above the buttons — which end the slack sits at

Also reported: *"the spacing also is like weird… a lot of spaces there between
that heading and the entry date row."*

The fixed block was 146 with content top-aligned and a `Spacer` pushing the
cycle-day footer down. On a one-line headline with no footer — which is exactly
what the clinic state was — most of the box was empty, immediately above the two
buttons.

**A fixed box always has slack on short days; that is the price of the page not
jumping.** The fix is not how much slack there is but which end it sits at. It is
140 now and bottom-aligned, so the leftover height falls between the day strip
and the text, where the strip already has air, instead of between the text and
the buttons, where it reads as a hole. Same pixels, and only one arrangement
looks like a mistake.

### 29.6 Still open

* **Only the TTC home hero changed.** Pregnancy and parenting heroes are
  untouched and have their own shapes.
* **The reference dims future-day actions and we already do** — worth knowing
  it was not part of this change; `enabled: !selected.isAfter(todayDate)` was
  already there.

---

## 31.0 The twelve practice cards, with players — 2026-09-05

From `ParentVeda_Mindbody_twelve_practice_cards.pdf` (30 Aug 2026): full content
for every card in Mind & body's practice tab, plus an animation spec.

**Where to look:** TTC home → Mind & body → **The practice** → any card.

| File | What changed |
|---|---|
| `lib/ttc/ttc_practice_data.dart` | Rewritten to the brief; `TtcPracticeAnim` union |
| `lib/screens/ttc/ttc_practice_player.dart` | **New.** Five players |
| `lib/screens/ttc/ttc_practice_screen.dart` | Rebuilt around the player |
| `lib/ttc/ttc_focus_data.dart` | `TtcFocusGroup.note` |
| `test/ttc_mind_body_test.dart` | 28 tests, +5 |

---

### 31.1 Four of my six invented durations were wrong, and all six erred LONG

§28.2 recorded that the first brief timed only five cards and that I filled the
other six from judgement. All twelve are now stated, and the breathing practices
are **one minute**, where I had written three and four.

Every guess was too long, which is not a coincidence: **a three-minute practice
feels more substantial to write than a one-minute one.** The brief is shorter on
purpose — a minute is what somebody actually does. Worth remembering the next
time a gap gets filled by judgement: the bias has a direction.

### 31.2 The safety line was on twelve cards; it belongs on one tab

The brief puts this in a heading — *"Safety line shown once on the practice tab,
not on every card"* — and the first build put it on all twelve, which is the
reflex. A warning repeated on every card stops being read by the third one, and
each card already carries its own specific `skipIf`, which is different every
time and therefore still read.

This is what `TtcFocusGroup.note` was added for. ⚠️ **It is deliberately NOT a
`pinnedRedFlagReadId`** — that renders a doctor-written `whenToSeeSomeone`
callout from a real article ("go to a hospital today, not tomorrow"). This is a
practical caution about stretching with no article behind it, and dressing it as
a clinical red flag spends that alarm on the wrong thing.

### 31.3 The honest split the brief draws, kept

*"The six breathing cards can be built completely in code, today, with no
artwork. The six movement cards need drawn figure animation, which Claude Code
cannot produce."*

**Built and working now** — one breathing component, configured per card, exactly
as asked:

| Card | Configuration |
|---|---|
| Long out-breath | in 4s, out 6s, 60s |
| Box breathing | 4/4/4/4, 64s, **traces a square** |
| Alternate nostril | 4/4, 90s, names the live nostril |
| Ten breaths together | in 4s out 6s, counts 1–10, **two ring markers** |
| Body relaxation | outline figure, region lit by the current step, 120s |
| Calm listen | pulsing light + 120s ring, **no bundled audio** |

**Scaffolded, awaiting artwork** — `TtcFigureAnim.assetPath` is read from the
card's data, so a Rive/Lottie file drops in with no code change. The Rive package
is deliberately **not** in `pubspec.yaml` yet: adding a dependency for six files
that do not exist is how a pubspec collects things nobody uses.

### 31.4 One deliberate departure: the step list does not advance on a timer

The brief asks for *"a step list that advances on a timer with the current step
highlighted"*. It advances on a **tap** instead, with forward/back controls and
the session ring still running the clock.

The reason is the brief's own shared rule: *"No countdown pressure… Leaving
mid-way is fine."* A list that moves on its own is a countdown by another name —
it takes the step away while you are still in it, and on a floor practice you are
not looking at the phone when it happens. **Say if you want it timed; it is one
field.**

### 31.5 The five animations to commission

⚠️ **`ttcAnimationsOwed()` derives this list from the data** rather than anybody
maintaining it — a hand-written list is wrong the first time a card changes.
There is a test on it.

| Card | Loop | View |
|---|---|---|
| Loosen-up: neck, shoulders, side bends | ~30s, loops | Front |
| Cat and cow, then child's pose | loops on a breath cue | Side |
| Hip openers: butterfly and slow lunge | two-part, both sides | Side |
| Legs up the wall | held pose, very little motion | Side |
| Slow sun salutation | full sequence, longest of the six | Side |

"A ten-minute walk" needs no figure, on the brief's own instruction — it is a
plain timer.

### 31.6 Still owed

* **The five Rive files** above.
* **A wake-lock for the ten-minute walk.** The brief asks for a timer that
  "keeps running when the screen locks". The clock is wall-clock arithmetic
  rather than a counter, so it is *correct* after the screen sleeps and wakes —
  but nothing keeps the screen awake, which needs a plugin. Correctness is
  there; the convenience is not.
* **Clinical read** on the area's six new pieces (§28.4) — unchanged.

---

## 32.0 Mind & body, second pass — the tab that looked wrong, and the course that was never built — 2026-09-10

Two things, from re-executing the three Mind & body PDFs against what shipped on
2026-09-05.

The report was *"the user interface looks very bad starting from today's
movement"*. Everything §28 and §31 asserted was still true — right practice,
right copy, no streak, tool rendering in place of a rail — and the tab still
looked broken, because **none of what was wrong was content**.

| File | What changed |
|---|---|
| `lib/screens/ttc/ttc_mind_today_screen.dart` | Redrawn in the door's palette; insets itself; `padded` flag |
| `lib/screens/ttc/ttc_practice_player.dart` | `TtcPracticeSkin`; `.sit()`; player height is a minimum |
| `lib/screens/ttc/ttc_practice_screen.dart` | Palette throughout; live step is a filled row; practice hue |
| `lib/ttc/ttc_garbh_course.dart` | **New.** The eight sessions, as data |
| `lib/ttc/ttc_garbh_course_store.dart` | **New.** Opened sessions, and session 8's picks |
| `lib/screens/ttc/ttc_garbh_course_screen.dart` | **New.** The course, and one session |
| `lib/ttc/ttc_mind_today.dart` | `ttcTodaysMove` / `ttcTodaysBreathe` sit in front of the rotation |
| `lib/ttc/reads/ttc_reads_mind_body.dart` | Three sections the guides brief specifies and the guides lacked |
| `lib/ttc/reads/ttc_reads_his_side.dart` | The sleep section another door was already pointing at |
| `lib/ttc/focus/ttc_focus_mind_body.dart` | The eight promote blurbs, as the brief writes them |
| `lib/screens/ttc/ttc_partner_screen.dart` | His Today, at last — see 32.8 |
| `test/ttc_garbh_course_test.dart` | **New**, 25 |
| `test/ttc_mind_body_test.dart` | +3 — geometry and phone-width render |

### 32.1 Three mechanical reasons a correct screen looked broken

Worth keeping separately from "it was restyled", because each is a rule rather
than a matter of taste and each can come back.

1. **No horizontal padding.** `TtcFocusScreen` wraps its own children in `_pad`
   (18) and hands a GROUP TOOL through **untouched** — on the assumption the
   tool insets itself, which `TtcPcosStandBody` does via `ttcToolPad` and this
   did not. So every card on the door's DEFAULT tab ran edge to edge under
   headings that did not. *The general fact: whenever one widget renders another
   widget's content in place of its own, the gutter has to belong to exactly one
   of them, and which one has to be written down.*
2. **The wrong palette entirely.** Today painted in the fixed TTC tool tokens —
   `ttcPurple` on `Colors.white` — while the door around it paints in
   `V2PaletteStore.instance.current` at the bracket's hue. A violet card on a
   sand page is not a card that needs restyling; it is a card from another
   screen. The practice detail screens and all six players had the same fault.
3. **Flat white boxes where the door uses tinted blocks.** The two practices are
   the most important objects on the door and were the plainest things on it.

### 32.2 The free course was a description of itself

`ttc_focus_mind_body.dart`'s Go deeper tile read *"taught properly rather than
described"* and opened `ttc_prepare` — the **catalogue** the course is listed
in, where it was one card describing eight sessions at a price of zero, above a
Buy button and an empty slot list. Reachable, tappable, wrong.

**This is the wiring gate's blind spot, and it is worth naming.** Every existing
test asked whether the tile opened *something*. It did. What no test asked was
whether the thing it opened was the thing the tile promised — and in general no
test can. What `ttc_garbh_course_test.dart` does instead is assert the
*specific* destination by type, which is only possible because somebody looked
once.

Four call sites construct `TtcOfferingScreen`, so the redirect for the free
course lives **inside** it rather than at each of them.

### 32.3 The rotation and session 8 disagree, and both are honoured

The rebuild brief: Today rotates a card a day. The course brief: session 8
*"must WRITE the user's picks into their Today tab"*. Both, as written, cannot
be true at once.

Resolved by making the rotation the **default** rather than the only behaviour.
`ttcPracticeOfTheDay` stays a pure function of the date — the tests that assert
a reinstall gives the same card still hold — and `ttcTodaysMove` /
`ttcTodaysBreathe` sit in front of it, consulting the store. Someone who never
opens the course sees exactly what the rebuild describes. Someone who has just
spent eight sessions deciding what she likes is not handed a different card the
next morning. Today says which of the two is on screen, and offers the way back.

### 32.4 Three sections the guides brief specifies and the guides did not have

Not restyling — missing content, found by reading
`ParentVeda_Mindbody_new_guides.pdf` against the shipped prose:

* **"If you live with family"** and **"If one of you works shifts"** in *Fixing
  a bedtime you will actually keep*. The brief calls the first *"the part most
  advice ignores"*, and it is right: a bedtime page written for a flat of two
  does not apply to most people reading it here.
* **"Before a wedding or a festival"** in *When family keeps asking*. The rest
  of that guide answers one question from one person; a wedding is the same
  question from nine people in front of each other, and the advice is
  logistical rather than verbal.

### 32.5 A cross-reference to a section that did not exist

The sleep guide's brief ends *"See the sleep section in His side for his half."*
There is no sleep section in His side. Pointing that sentence at the nearest
existing article would have been exactly the failure that
`reuse-only-the-thing-itself` describes, so **the section was written** — added
to `ttc_read_heat_habits`, which is already titled "Heat, habits and time" and
is where a habit with real evidence behind it belongs.

### 32.6 Judgement calls worth knowing about

* **The practice detail screen now opens in its library's hue** (104 Move, 206
  Breathe) rather than the door's 42. Tapping a sage block and landing on a sand
  page reads as having arrived somewhere else. `kTtcMindHue` is kept and
  documented rather than deleted.
* **The step list's live row is filled, not merely bolder.** On a floor practice
  the phone is at arm's length on the mat, and w700 against w400 in the same
  colour is not a difference you can find at that distance.
* **The movement placeholder no longer apologises.** It was a grey icon and the
  words "Follow the steps below" — an apology in the largest object on screen,
  on six of the twelve cards. Still no figure, still no pretending there is one.
* **The player's height is a minimum, not a fixed 232.** The body scan is a
  Column of a figure *and* the name of the part currently lit, and that caption
  wraps; at the largest accessibility sizes it striped the screen.
* **Progress on the course is a sentence, not a bar.** "3 of 8" is a debt
  statement on a course whose closing note is that there is nothing to keep up
  with.

### 32.7 Still owed

* **Clinical read** on the eight sessions, on top of the six pieces at §28.7.
  Nothing in the course is a new clinical claim, but nobody qualified has read
  it.
* **Session 4's audio.** "Listen to a short calm piece" — we bundle no audio, on
  the same reasoning as `mb_listen` (§28.3): the choice is personal and often
  religious. The session says "play your own", which is honest and is also less
  than the brief pictures.
* **The five Rive files** (§31.5) — unchanged, and session 5 now wants them too.
* **The partner's Today is still not wired** (§28.7) — unchanged.
  `kTtcPartnerOffset` remains logic without a caller.
* **A wake-lock for the ten-minute walk** (§31.6) — unchanged.
* **`ttc_mind_today` as a pushed route was a naked Column** until this pass — no
  scaffold, no ground, no way back. It now has `TtcToolScaffold`. Nothing links
  to it yet, so this was fixed on the way past rather than because it broke.

---

### 32.8 Recheck against the three PDFs — two gaps closed, one conflict left open

The pass above was re-walked card by card against the briefs' own lists. Three
things came out of it.

**The partner's Today is now wired.** The rebuild brief's STEP 3 says *"Both
partners see Today. Their picked cards may differ. Either can complete alone,
and it does not count against the other."* `kTtcPartnerOffset` and the `offset`
parameter existed and were tested from the first build, and nothing called them
— recorded honestly at §28.7 rather than claimed, and open ever since. His
Today now carries a practice card directly under his mission, half a library
away from hers, in the Slate palette.

One caveat that is worth knowing rather than fixing: the Mom|Dad pill is a
**testing** switch on a single device, so flipping it does not swap
`TtcLogStore` underneath. In the real product his half arrives through the
pairing code on his own install, and the rows are separate because the devices
are. "It does not count against the other" therefore holds by construction in
production and not in the dev toggle.

**Three points the guides brief specifies, missing from *Bringing him into
this*.** "Do things together that are not about trying" — which is the sentence
that gives the couple practice card a reason to be opened; "not on the day a
period arrives"; and the framing warning under *what tends not to work*, whose
symptom is not refusal but delay. The guide's own warning was about scheduling,
which is a different and also real failure, so all four now sit together.

**The one conflict, and it is left open on purpose.** The brief's sub-tab map
titles the film card *"Preconception garbh sanskar, taught"*. That cannot ship:
the article directly above it is *"Preconception garbh sanskar, honestly"*, and
`ttc_focus_page_test.dart` forbids two tiles in one section opening with the
same three words.

That rule is not a house preference. It was added 2026-09-03 after two such
pairs shipped in Getting ready and **both were reported on sight** as one card
printed twice. Taking an exemption for this pair would deliberately reintroduce
the thing that was complained about, so the card reads *"The eight sessions,
taught"* — the brief's load-bearing word, three different opening words — and
the film's own title in `ttc_videos_data.dart` is untouched, which is what
`reuse` actually protects.

**Yours to settle:** whether the brief's exact title matters more than the
rail's duplicate-reading rule. Nothing else in the three PDFs is unimplemented
except the items listed at §32.7.

**Deviations worth naming, all small:**

* **Box breathing runs 64s, not the brief's "total 60s".** Four whole rounds of
  4-4-4-4 is 64, and the card's own step 5 says *"Do four rounds, which is about
  one minute."* Cutting the fourth round short at 12 seconds to hit a round
  number would contradict the instruction on the same screen.
* **Session 3's five-minute sit gets a plain ring**, where the brief pictures a
  seated outline figure with a light at the point of attention. No such
  component exists; the body-scan figure moves DOWN the body, which is the other
  half of that session. The timer is the honest fallback and the session works
  without it, which the brief requires anyway.
* **Session 4 bundles no audio** — see §32.7.

---

## 33.0 Scans & tests becomes the first pregnancy door — 2026-09-10

Built from `ParentVeda_Scans_and_tests_rebuild.pdf`. First of eight pregnancy
briefs, and the first pregnancy area to take the five-sub-tab shape the TTC
doors use. The playbook is `docs/PREGNANCY-DOOR-BUILD.md`; this records the
decisions that are arguable and the things still owed.

### 33.1 A second door engine, and why it is not a merge

The TTC focus engine — `TtcFocusPage` + `TtcFocusScreen` — is the same idea,
built first, and it is welded to TTC by its **payloads**: an article names an id
in `kTtcReads`, a tool names a surface only `ttcScreenForSurface` resolves, a
product names a row in the TTC catalogue. Pregnancy's own destinations — a scan
page, the report locker, the decoder — have no way to be expressed over there.

So there are two engines sharing a shape. What they genuinely share is already
shared and stage-neutral: `V2Palette`, `V3HeroField`, `V3BracketArt`, `PvRead`,
`PvReaderScreen`, `pv_placeholders` — which is what lets a pregnancy door look
identical to a TTC door without either file importing the other.

**The cost, stated honestly: the coverflow's geometry now exists twice.** Design
4a's numbers are in `ttc_focus_screen.dart` and again in `pv_door_carousel.dart`.
If the design moves, both move.

**The seam for merging them later**, and it is small: the carousel reads exactly
four things off a group — `label`, `icon`, `hue`, and a pre-computed count line
— so a shared version takes those four values rather than a model. Lift the
model and the renderer to a stage-neutral home and give each stage an injected
resolver for reads and surfaces, the way `PvReaderScreen` already takes
`openRead` / `openSurface`. That is a one-import change per TTC file. **Not
attempted now** because TTC is being worked on in parallel and a shared-file
edit is everybody's conflict.

### 33.2 Two briefs disagree about the red flag, and both are right

`scans_hub_v2.dart` deleted the urgent strip with the strongest argument made
about that hub: *nobody discovers an emergency by scrolling.* A woman with
one-sided pain is not browsing her scan records; putting the warning there does
not reach her, it only makes a records screen alarming for the thousands of
people who are fine.

This brief pins "Call your doctor if" back. Both hold, because they are about
different places: that argument was about a strip at the top of a **landing**,
which every visitor met before anything else. This is one tab of five, named
**Talk**, which somebody opens because they are already thinking about reaching a
person. It is nowhere else on the door, so the woman checking when her next scan
is never meets it.

### 33.3 The heading had to move with the list

The brief asks to remove the duplicate topics — breech and cord around neck
appear twice in the decoder. They do: `all` was every finding including the
popular six directly above it.

Worth noticing why it survived review. **Neither list is wrong on its own.**
"Popular topics" is correct and "All topics" is literally correct; the
duplication exists only in the space between two headings that are each
accurate. A list meaning *all* and a list meaning *some of these* cannot both be
complete and disjoint.

So the six are subtracted **and the heading changed to "More topics"** — a
heading promising everything over a list missing six entries is the same untruth
pointing the other way. Only while unfiltered: with a chip on, "Popular topics"
is itself filtered and subtracting a near-empty list would hide topics for no
visible reason.

### 33.4 Two of the six new pieces were marked "short" and are not

The brief marks "What to keep, and why" and "Take it to your appointment" as
short guides. They are full `PvRead`s at the same floor as everything else —
four sections, 600+ words, an FAQ, named sources, an urgent when-to-see-someone.

The floor was kept rather than argued with: these sit on a rail beside nine rich
scan pages, and a two-paragraph card there does not read as concise, it reads as
the one nobody finished. Where a subject genuinely had less to say the answer
was to find the substance it was missing — what a lab actually keeps and for how
long, what a receipt is worth at an insurance desk — not to pad it.

### 33.5 Judgement calls worth knowing about

* **"Add a report" is not a card.** The brief lists it as a `[Tool]` on My
  reports. The locker rendered above it already carries its own add button, and
  a card whose tap does what the button six points above it does is the
  door-in-front-of-a-door again. The locker **is** "Add a report".
* **"A word on the report you do not know" opens the decoder's SEARCH**, not the
  decoder. The decoder is already on screen above that card — its chips and
  topic lists are the tab — so a card opening the same screen again would be a
  link to where she is standing.
* **The hero keeps "Your scans, in one place." over an eyebrow reading "SCANS &
  TESTS".** `TtcFocusPage` deliberately has no title field, because that screen
  once shipped headed "Getting pregnant" behind a tile reading "Fertile window".
  The drift is prevented here a different way: the exact words on the tile she
  tapped are still on screen, above the sentence.
* **The appointment checklist does not count anything.** No progress bar, no
  "4 of 18", no streak. A counter on a list of things you are nervous enough to
  write down is a debt statement. The one number shown is on the share button,
  where it says how long the message will be.
* **Its ticks are local and deliberately not synced.** Every other store in this
  stage registers with `SyncRegistry`. What she is nervous enough to ask about
  is a more sensitive signal than most of what this app stores and has no
  clinical value to anyone later; there is also nothing to merge. If it is ever
  synced, that is a decision about privacy first and plumbing second.

### 33.6 Still owed

* **Clinical read on the six new pieces.** Nothing in them is a new clinical
  claim and every figure is sourced, but nobody qualified has read them.
* **"What the scan person can and cannot tell you" has no content.** It is the
  one COMING SOON card on the door. `content_slots.dart` has declared it for
  this bracket for months and nothing has been written. It is a four-minute
  read: why they go quiet, why they will not discuss the sex, and who gives you
  the result — and two thirds of that is already written inside
  `preg_scan_read_sex_law`, so it is closer to done than it looks.
* **The hero photographs are hotlinked Unsplash URLs, not bundled assets.** All
  five pregnancy doors now carry one (`heroImageUrl`), each downloaded and
  looked at before wiring — see the header of `pv_door_scans.dart` for why that
  step is the whole rule. Two candidates were rejected on 2026-09-10 for
  carrying a US clinic's signage, which is the same fault that shipped once
  already. What is still owed: they are a NETWORK dependency in a local-first
  app. The failure mode is benign — `errorBuilder` returns nothing and the
  drawn V3 hero shows instead — but on a slow connection the hero is blank for
  a beat. Bundling them under `assets/doors/` is the fix, and it needs the
  licence line recorded per image.
* **The cost ranges carry September 2026 and will rot.** They are duplicated in
  spirit with `kScanCost`, which is the per-scan source; if one moves, move both.
* **`ScanQuestionsStore` has no cloud shape** — see §33.5. Deliberate, recorded
  here so it reads as a decision rather than an omission.
* **The seven other pregnancy briefs.** They are data files now, plus whatever
  tools each one asks for. `docs/PREGNANCY-DOOR-BUILD.md` §2 lists the three
  shared lines each will touch.

---

## 34.0 Complications & conditions, the second pregnancy door — 2026-09-10

Built from `ParentVeda_Complications_rebuild_clean.pdf`. Five sub-tabs on the
same engine as Scans; the engine itself needed two new tile types and one new
field, and nothing else.

### 34.1 The brief said "never keep a second copy" and the app has eleven

`kAllConditions` (27 deep 8-part pages) and `kReportFindings` (27
reassurance-first 7-part pages) both exist. Six subjects share an id outright —
`anemia`, `breech`, `fibroids`, `high_bp`, `preeclampsia`, `rh_negative` — and
five more share a subject under different ids. Two cards this brief names by
hand, "Cord looped around the neck" and "Placenta sitting low", exist ONLY as
findings, so its own browse rail cannot be built from Complications alone.

**Decided: one page per QUESTION, not one page per word.** Conditions answer
"my doctor said I have X"; findings answer "my report says X". A woman holding a
report at 11pm and a woman whose obstetrician has just told her the same word
want different objects — the first wants to know whether to panic, the second
wants to know what happens now. Collapsing them makes one of those two readers
worse off and it is not obvious which.

So the brief's rule reads as **never a second copy of the same ANSWER**, the
door links across for the two subjects it does not own, and the rule is written
into `docs/PREGNANCY-DOOR-BUILD.md` §4a so it is not re-litigated per door.

**The alternative was considered and rejected on cost, not principle:** merging
would mean reconciling two clinical voices per subject and re-pointing the Scans
decoder — a door shipped hours earlier on a brief that said reuse it.

⚠️ **The test enforces the boundary rather than the split.** `and they are the
two Complications does not own` asserts that a finding tile is used ONLY where
no condition page answers the same question. Add a `nuchal_cord` condition page
and it fails, which is correct: at that point somebody has to decide whether
both answers are genuinely needed.

### 34.2 Four cards marked "reslot" were new work

The brief moves "When blood pressure gets dangerous", "Handling pregnancy sugar
in India", "The daily thyroid tablet" and "Iron, from food and tablets" out of
their condition pages as `[Guide] reslot`. None existed at that depth:
`ConditionEntry.management` is one ~40-word paragraph, and the blood-pressure
one is `high_bp.callNow` — four bullet lines.

A Guide chip promises a thing you act on, and opening a forty-word paragraph
from one is the chip lying about length. So they are written properly, to the
same floor as everything else. **Six new articles on this door**, with the two
the brief already called new.

The paragraphs they grew from are untouched. Somebody reading the gestational
diabetes page still wants a short answer about management in place.

### 34.3 A plain line on every condition, not just the ten named

The brief gives plain one-liners for ten conditions and asks that each browse
row show one. `ConditionEntry.plainLine` is **required**, and all 27 are filled —
the brief's ten verbatim, the rest to the same pattern.

Optional would have been worse: a list where some rows explain themselves and
some do not, with the silent ones being exactly the rarer conditions, where a
mother is least likely to know the word.

The browse rows now show `plainLine` where they showed `reassurance`. The
reassurance still renders on the page; in a list it was two lines answering a
question she has not asked yet.

### 34.4 Judgement calls worth knowing about

* **"Add a condition to my journey" opens the search screen.** The brief says
  reuse the existing "Add to my journey" action — and that action lives ON a
  condition page, because adding one requires having chosen one. From a door
  there is no condition yet. Building a second adder would be a second way to
  write the same set.
* **Two pinned flags on one door.** The assembled same-day list on the safety
  tab, the stage's standing pregnancy list on Talk. Different lists, different
  questions. §12 of the playbook.
* **Sub-tab 1 carries no cards.** All three things the brief lists for it — the
  search, the "My doctor told me" chip, the Most-common list — are the inline
  screen. A fourth card would be something the brief did not ask for.
* **The two-way door renders inside the tab.** `_DoorGate` asks whether the
  visit is diagnosed-real or curiosity, and the answer changes what the area
  offers. A door that skipped it would bypass a question the screen exists to
  ask.
* **The checklist system was generalised at its second caller**, not its third.
  See §11 of the playbook. `scan_questions_ticked` is kept as the scans list's
  preference key so nobody mid-list lost their ticks.

### 34.5 Still owed

* **Clinical read on the six new articles**, on top of the six at §33.6. Nothing
  in them is a new clinical claim and every figure is sourced, but nobody
  qualified has read them.
* **Clinical read on the assembled same-day list.** It is assembled from
  reviewed pages by construction and the test proves the provenance — but the
  five-line SELECTION is an editorial act nobody clinical has signed off.
* **The 17 conditions not on the browse rail** are reachable only through
  sub-tab 1's search and Most-common list. That is the brief's own shape and it
  means miscarriage, preeclampsia, cholestasis and HELLP are search-only. Worth
  a look on a device before deciding it is right.
* **`plainLine` for the 17 unnamed conditions is mine, not the brief's.** They
  follow the pattern and they have not been reviewed against the brief's voice.
* ~~**No photograph on either door's hero.**~~ Both now carry one — 2026-09-10.
  See §33.6 for what is still owed about how they are served.
* **Six briefs left.** Belly and skin, Garbh Sanskar (two), Labour prep, Mind
  and mood, Nutrition.

---

## 35.0 Nutrition & diet, the third pregnancy door — 2026-09-10

Built from `ParentVeda_Nutrition_rebuild.pdf`. The most reuse of the three by a
wide margin: roughly seventy cards declared, and exactly two things written.

Its brief opens with a box headed *"nothing here is a new page to build"* and
closes with a rule no other brief has: *"If you cannot find a page that this map
says to reuse, STOP and list it in your output rather than creating a new one."*
Walking the code first found every list it names. Three things it did not know
are below.

### 35.1 The tile model collapsed before this door was written

Nutrition needs six more "one id, one lookup, one push" tile types — nutrients,
diet stages, diet conditions, recipes, charts, fasting. Added as classes that
would have been seventeen tile types by door eight.

`PvDoorScanTile`, `PvDoorConditionTile` and `PvDoorFindingTile` became one
`PvDoorEntryTile` carrying a `PvDoorLibrary` enum. Three classes to one, six
avoided, and one router case instead of nine.

**And it is not the config object this file's own header forbids.** That rule is
about a tile with several INDEPENDENT payload fields where most combinations are
illegal and constructible. This has one payload field and one selector; the only
error possible is an id not in its library, which no type system catches and the
wiring test does. What is lost is the compiler naming an unhandled case — worth
it at nine libraries, not worth it at three.

### 35.2 Three things the brief did not know

* **An eleventh condition guide exists.** "Overweight in pregnancy" is in
  `kConditionGuides` and absent from the brief's list of ten. It is on the rail:
  this door REPLACED the landing, so showing ten of eleven would make the
  eleventh unreachable — the wiring gate pointing the other way.
* **Fasting topics are not pages.** All eight are title-and-paragraph rows
  rendered inline on `FastingScreen`, not tappable, with no detail screen. So
  the door carries ONE fasting card rather than eight pointing at one
  destination. **This is the item the brief asked to have listed.**
* **The fourth paid tier is "Book a consultation"**, not "Book one session". The
  brief says do not change the labels, so it keeps its own.

### 35.3 A dead coming-soon that Complications had already made live

`_ComplicationsLink`, at the foot of every diet-condition page, read *"More on
this, and related warning signs, lives in Complications, coming soon"* and was
deliberately not tappable — correct when it was written, because there was no
Complications screen. There is one now, shipped hours earlier.

**This is the inverse of the failure the wiring gate exists for**, and it is
harder to find: a real destination sitting behind a card that says it does not
exist. Nothing is broken, nothing fails, and it stays wrong until somebody
remembers.

> **The general lesson: a coming-soon marker is a claim with an expiry date, and
> nothing expires it. When a thing ships, grep for what promised it.**

Seven guides now link — six the brief names plus `constipation_piles`, which the
brief said owns its content and has no page. `piles` exists. Walking the code
beat the brief.

### 35.4 Single source, read so it does not destroy content

The brief: *"the diet card LINKS to that Complications page and does not restate
the condition."* Read as "the card opens Complications instead", that throws away
the eating advice — the one thing somebody taps for on a nutrition door.

It was also unnecessary. Every `ConditionGuide` is already pure diet — "pair
carbs with protein", "iron-rich foods: dal, greens" — with no symptoms, no tests
and no management. The rule was satisfied by construction; only the link was
missing. So the card opens the diet page and the diet page's footer opens the
condition.

### 35.5 Judgement calls worth knowing about

* **Cravings folded into the food checker**, which is the brief's own call. Two
  bodies in one scroll, nothing merged — each keeps its own state. The seam is a
  heading that says why the badges change from Safe/Limit/Avoid to Yes/In small
  amounts.
* **The four paid tiers are rendered, not re-carded.** `ExpertOptionsBlock` IS
  the four tiers with its own header and booking sheet; four cards beside it
  would be four copies of its rows, and "keep the tiers exactly as they are" is
  easiest to guarantee by not retyping them.
* **The disclaimer is a NOTE, not a red flag.** The flag treatment is coral and
  urgent; spending that on a disclaimer spends an alarm on a caveat.
* **Cards are built from the libraries, not typed.** Seventy hand-written cards
  is seventy chances for a label to drift from the page it opens, invisibly.
* **"Add this to your plate now" is one read with four sections**, not four
  cards. She sees the stage she is in; the other three would be noise on a rail
  already carrying the four existing stage guides.

### 35.6 Still owed

* **Nutrition has not been walked on a handset.** Scans and Complications were;
  the device came off before this one. Sub-tab 1 is the piece to look at — it is
  the longest inline body in the app, two screens in one scroll.
* **Eight fasting pages.** See §35.2. Each `FastingTopic` has a title and a body
  and would make a small page easily; the brief forbade building them, so the
  decision is the user's.
* **Clinical read** on `preg_diet_read_add_now`, on top of the twelve at §33.6
  and §34.5.
* **`_firstSentence` trims seventy blurbs from page summaries.** They read well
  today; nobody has checked all seventy by eye.
* **Five briefs left.** Belly and skin, Garbh Sanskar (two), Labour prep, Mind
  and mood.

---

## 36.0 Belly & skin, the fourth pregnancy door — 2026-09-10

Built from `ParentVeda_Belly_and_skin_rebuild.pdf`. The brief's own summary is
*"this area needs almost no rebuild"*, and it was right: nineteen reads, the
Ingredient Safety Checker, the itching screen and the bump keepsake all existed
and were carried whole.

### 36.1 Four tabs, and the first brief to argue against the shape

*"There is no paid consult here and only one real medical flag (the
itching-of-palms-and-soles warning), which is better kept prominent inside the
Itching read than pulled into a thin Talk tab."*

That is the right call and worth recording as a precedent: **a fifth tab built
to match the other doors is the content-management view of a product** —
organised by how we happened to build the last one rather than by what this area
has.

### 36.2 An even ring hid a whole tab, and only a device or a render test finds it

The carousel's seam fade exists for the frame where a card flips from one side
of the ring to the other. On a five-ring no card ever rests at that distance. On
a **four**-ring one always does — so the fourth card rendered at zero opacity and
the door came out as three cards under four dots.

Fixed by skipping the fade on even rings. **The trade, stated honestly:** a card
genuinely crossing during a drag now flips sides visibly instead of doing it
under cover. It happens at x ≈ ±170, inside the track's own edge mask, at 0.6
scale, mid-gesture — a smaller cost than a tab that is not on screen at rest.

⚠️ **Five is still the better shape.** This makes four work; it does not make
four equal. Worth a look on a handset before the next even-numbered door.

### 36.3 A survey that "found" a gap the source did not have

An early pass here reported two pages missing a `videoSubtitle` and supplied
them from the brief. Both already had one, and the words added were
**byte-identical** to the words already there — the regex that found the gap
assumed a field order the file does not always keep.

> **Worth remembering as a shape: a survey that reads source with a regex will
> find gaps the source does not have, and the fix looks like ordinary content
> work.** It only failed because Dart rejects a duplicate named argument. Had
> the field been a list, it would have shipped a silent duplicate.

### 36.4 Judgement calls worth knowing about

* **Rails are built from `kBsPages`, not listed.** The brief says the named
  cards are "the visible ones, not the full inventory" and adds "+ any other
  reads already built". A hand-typed list would have shipped exactly the named
  cards and quietly dropped anything added later — on a door that replaced the
  only route those pages had.
* **The card line is the page's own `videoSubtitle`.** `BsPage` has no blurb
  field; what it has is the film's one-liner, and those ARE the brief's card
  lines verbatim on all nineteen — its map was written from this field. So no
  new copy is written anywhere on this door.
* **The bump keepsake gained an embedded form with real actions.** Its add is a
  FAB and its compare is an app-bar action, neither of which has a home inline —
  so the embedded body gives both a row at the foot. Same `_addFlow`, same
  `_openCompare`; only where they are pressed changed. Without it the tab would
  have been a keepsake you cannot add a photo to.
* **The two retitles are the only content change**, exactly as the brief says.

### 36.5 Still owed

* **Neither Nutrition nor Belly & skin has been walked on a handset.** The
  device came off mid-Nutrition. Two things to look at first: Nutrition's
  sub-tab 1 (the longest inline body in the app — two screens in one scroll) and
  this door's four-card ring (§36.2).
* **The embedded bump actions are untested on a device.** The button row is new
  placement of existing actions and has only been checked by the render test.
* **`BsArea.itching` is an enum value with no `BsPage`.** The itching read is
  its own screen, which is why the door carries a tool card rather than a
  library entry for it. Harmless, and worth knowing before somebody adds a
  nineteenth page expecting it to appear on the Itching rail.
* **Four briefs left.** Garbh Sanskar (two), Labour prep, Mind and mood — plus
  Symptoms, which this brief names as the last pregnancy area and which has no
  PDF in the folder yet.

---

## 37.0 Labour prep, the fifth pregnancy door — 2026-09-10

Built from `ParentVeda_Labour_prep_rebuild.pdf`. The first tools-first door: the
default tab is a timer, not a read, because near the due date somebody opens the
app to DO something.

**A rule worth keeping from it: a door's default tab is whichever one somebody
opens the app for.** Scans opens on the timeline, Complications on the search,
this on the timer. Never the most important content — the thing she came to do.

### 37.1 Two tools are cards, not inline, and it is the engine's one deviation

Every other tool tab renders its tool in place. These two do not.

The contraction timer is a phase machine with a live session, a `PopScope` that
saves when you leave it, voice guidance, a safety sheet, a history screen, and an
interface that is one enormous button. Embedded it would sit below a carousel
inside a scrolling page: **the save-on-pop never fires because you never pop**,
three app-bar actions including the safety check have nowhere to live, and a
woman timing a contraction has to scroll to find the button.

The packer adds a second reason — it carries a `bottomNavigationBar`, the pinned
"Labour started?" alert the brief names, and a bottom bar has no meaning inside
somebody else's scroll.

> **So the test is not "is it a tool", it is "is it a list".** A tool whose
> content is a list embeds. A tool that owns the screen — a timer, a camera,
> anything with a live session or a pinned bar — gets a card and keeps its
> screen. The tab is still not a rail, which is what the briefs actually forbid.

`pv_door_labour_test.dart` holds this so it is not "tidied" back by someone
reading only the rule.

### 37.2 The voice rule cost one bilingual edit

The brief: *"Every line the user reads is spoken TO her, warmly… NEVER like a
legal notice."* It names the offender: the timer's disclaimer, headed "A timer,
not a diagnosis" over a body opening "ParentVeda is not a medical or diagnostic
service."

Rewritten in `app_language.dart` — **heading and first sentence only, in both
languages**, with every word of the actual safety untouched. Its closing line
turned out to be the brief's own second human line already, word for word.

⚠️ **Both sides moved together.** A rewritten English beside a stale Hindi would
leave the Hindi build carrying the legal framing on a safety notice. `midwife`
stays Latin because the surrounding string already has it that way — shipped
content is the tiebreaker, per the bilingual skill.

### 37.3 The birth-plan card is absent, and the brief asked for it

The brief marks *"Your birth plan, and how to make one"* as `[Guide] reuse
(pulled out of the old accordion)`. There is no accordion and no birth-plan
content. `pregnancy_journeys.dart` REMOVED that step, with a note saying why —
*"The birth-plan tool does not exist, so the step promised a page and delivered
a grey card."*

That was a considered decision by somebody who had seen the grey card. Re-adding
the card here would reverse it silently, so **it is omitted and this is the
record.** It is the user's call: build the tool, or leave the card out.

### 37.4 Six coming-soon cards, and the area says so itself

This is the first door where most of a tab is owed. The videos and reads are
declared in `kPgBirthPrep` as `owed: true` elements, or as `JourneyRead`s whose
`surfaceId` is — in the model's own words — *"Null until a real article exists
behind it."*

They hold their place at full size and do not tap. The alternative was a rail of
three where the brief describes six, and a door that quietly forgets what the
area promised. CLAUDE.md: aspirational copy stays; the gap is recorded.

### 37.5 A thing that looked like a bug and was not

`PrepProgram(course_birthprep).lessons` lists **four** lessons while its
`durationLabel` says "6 lessons". That looked like the missing classes 5 and 6.

It is not: the real six-class list is `kBirthingClasses`, a separate model, and
all six are there exactly as the brief names them with class 1 free. **Two
parallel lists describe the same course** — worth knowing, and not this door's
to reconcile.

### 37.6 Still owed

* ~~**Three doors now unwalked on a handset**~~ — walked 2026-09-10, see §38.
* **The six owed pieces** at §37.4 — two videos and four reads. The area
  promises them on the door now, which makes the debt visible rather than
  larger.
* **The birth-plan tool** — see §37.3.
* **Clinical read** on `preg_labour_read_pain_relief`, on top of the thirteen at
  §33.6, §34.5 and §35.6. This one has the most figures in it: the epidural
  cost range, the caesarean myth correction, and the anaesthetist-availability
  framing.
* **Three briefs left.** Garbh Sanskar (two PDFs, a coupled pair) and Mind and
  mood. Symptoms has no PDF yet.


---

## 38.0 Walking Nutrition, Belly & skin and Labour prep on a phone — 2026-09-10

Galaxy S21 FE, 1080x2340, `--flavor parent`. Every tab of all three doors, plus
a log tailed for `RenderFlex` / overflow / exception the whole time.

**No exceptions and no overflows.** The engine held: the even-ring seam fix
(§36.2) draws all four Belly & skin cards, the long inline `CanIEatBody` scrolls
as one body, and `_EmbeddedActions` renders on the bump keepsake. What the walk
found instead was seven things that are only visible on glass.

### 38.1 What was fixed

* **One sentence, three times.** Nutrition's Talk tab printed its area
  disclaimer as the tab note, again as the door's `closingLine`, and a third
  time in the engine's `PvDoorDisclaimer` immediately below — which says the
  stronger version anyway. Labour prep did the same with one literal constant
  used as both `note` and `closingLine`.
  *Two fixes, deliberately different.* The engine now skips a closing line that
  is **identical** to the open tab's note; Nutrition's line, which merely said
  the same thing in other words, was dropped in the data. An engine cannot tell
  that two differently worded cautions mean the same thing, and one that
  guessed would start hiding lines somebody wrote on purpose.
  **The general shape: a safety line repeated is a safety line devalued.** Three
  statements of one caution read as boilerplate and get skipped.

* **"Read" wore a magnifying glass.** `PvDoorFormat.read` mapped to
  `Icons.search_rounded` — reasoned, because a read is a lookup. On Belly &
  skin, where nineteen of twenty-two cards are reads, that mark paints at 96pt
  behind every one of them and the tab reads as a wall of search boxes. Now
  `find_in_page_outlined`. **An icon chosen for what it MEANS has to be checked
  for what it LOOKS LIKE at the size and repetition it ships at.**

* **A rail of one.** Four sections across the three doors held a single tile,
  and a horizontal rail of one card is a 142pt block with two-thirds of the row
  empty beside it — which reads as content that failed to load. Single-tile
  sections now render as wide rows whatever their tab's layout says, which also
  buys back the blurb a rail card cannot afford.

* **A price nobody could see, under a passing test.** The Birthing Course card
  is the one paid tile on Labour prep, and its ₹1,499 lived in the blurb. A rail
  card draws the badge, `meta` and the title — never the blurb. So
  `pv_door_labour_test.dart` asserted "the card names the price on its face",
  the assertion was true, and the face said "Complete Birthing Course" and
  nothing else. The price moved to `meta`, and a registry-wide test now requires
  any tile with a ₹ in its blurb to carry it in `meta` too.
  **Asserting a string exists on a model is not asserting it reaches a screen.**

* **A card that repeated its own heading.** "Diet charts" under "Ready-made diet
  charts" — the second time this has shipped (the first was "Fasting" under
  "Fasting"). Renamed to "Browse every chart", and there is now a registry-wide
  test for it.

* **"What he can actually do."** Two cards below that heading say "whoever comes
  with you", which is the careful phrase and was written on purpose. The heading
  assumed a husband. Now "What your partner can actually do".

* **One search bar that looked like two.** The Complications and Cravings
  search fields each draw their own white pill and then set
  `border: InputBorder.none` on the `TextField` inside it. That removes the
  OUTLINE and not the FILL — and `app_theme.dart` sets `filled: true` with a
  grey `surfaceContainer` on every `InputDecoration` in the app. So a grey
  rounded rect painted inside the white pill, starting just right of the
  magnifier. Both now pass `filled: false`.
  **A widget that draws its own chrome has to switch the theme's OFF, not
  merely avoid adding to it.** A theme default applies unless overridden, and
  setting a different `border` is not an override of `fill`.

* **Every door has a hero photograph again** — see §38.2.

### 38.2 The photographs, and the process that is the actual guarantee

All five pregnancy doors now set `heroImageUrl`. The Scans door had one removed
in §33 because it turned out to be a Western urology clinic with the department
legible on a badge, under the words "Your scans, in one place".

**The rule that came out of that is not "no photographs". It is "look at it
first."** Every image here was fetched to disk and opened before its URL was
written into a Dart file. Two candidates were rejected on exactly the old fault:
a US clinic with a wall poster and a lab brand in frame, and a second with an ID
badge. Subjects are chosen to carry no institution — hands, a bump, a report, a
plate; never a building, a uniform or signage.

| Door | Subject |
|---|---|
| Scans & tests | A woman holding her scan printout against her bump |
| Complications | Hands on a bump in window light, black and white — the quietest of the five, because this is the door somebody opens worried |
| Nutrition | A South Indian veg thali on a banana leaf — the blurb says "for an Indian kitchen" and the picture has to agree with the sentence |
| Belly & skin | An Indian woman in late pregnancy, hand on her bump, outdoors |
| Labour prep | Hands cradling a very late bump before a wooden door |

`pv_door_scans_test.dart` holds the shape around them — every door has one, no
two are the same, each is requested at a `w=900&fit=crop` crop — and says in its
own comment that it cannot check the thing that actually matters.

### 38.2a Scans and Complications re-walked after the engine changes — 2026-09-11

The single-tile rule, the read icon and the closing-line skip all touch the
engine under the two doors committed earlier. Both walked end to end on the
handset: no exceptions, no overflows, and the single-tile rule is an
improvement on Scans' Talk tab, whose two lone cards are now proper rows.

Two more instances of the old-card fault turned up on Scans and were fixed the
same way as the Complications browse list: the report tool's "Popular topics"
rows (`report_screen.dart`, a pre-V2 screen whose rows now take the live
palette while the rest of it is left alone) and the "Add a report" card in
`scan_reports_screen.dart`, which sat directly above a `PvDoorRow` in a
different card language. Every `SolutionCard` inside a door body is now gone;
`SolutionCard` itself is untouched and still correct on the hubs that have not
become doors.

### 38.3 What the walk found and did NOT fix

These need a decision rather than a patch.

* **The bump keepsake is in the old palette.** Sub-tab 4 of Belly & skin renders
  `BumpJourneyBody` in place, and it arrives with hot-coral buttons and a
  purple-to-pink gradient banner on a calm cream V3 door. Every other inline
  tool is palette-driven. Recolouring it is a change to a shipped screen that
  also lives in Tools, so it is not this pass's call.
* **Sub-tab 1 of Nutrition is 64 food rows long before the Cravings heading.**
  The fold is the brief's own instruction and the seam heading is there, but a
  woman who came for cravings scrolls past every food in the app to reach them.
* **"Pre-pregnancy" is the second card under "Food for your stage"** on the
  Pregnancy door. All four stage guides are on the rail, which is the brief;
  whether the pre-conception one belongs on this stage's rail is a content call.
* **"What actually happens" on Labour prep is three coming-soon cards and
  nothing else** — an entire section greyed out, on the tab a woman opens to
  understand birth. Honest, and the thinnest tab in the area. See §37.4.
* **The Ask Veda FAB permanently covers the third card of every rail.** It does
  not scroll, so it sits over the same screen position on every door. Global,
  pre-existing, and louder on a rail layout than on a list.
* **The Classic/V3 pill on the V3 home covers the Nutrition tile's icon.** Also
  pre-existing, also global, and it sits on a door tile.
* **~30 other `InputBorder.none` fields carry the same latent fault.** Grep
  `InputBorder.none` in `lib/screens/`: every one of them is a field that draws
  its own chrome, and any that also draws its own background is painting the
  theme's grey inside it. Two were fixed because they are on these doors. The
  rest are shipped screens where the grey may well be the intended look — this
  is a sweep somebody should do deliberately with a phone, not a find-and-
  replace.


### 38.4 Decisions taken on the walk's findings — 2026-09-11

* **Cravings under 64 food rows** → a UX redesign, not a reorder. Design
  brief written: `docs/design-prompts/CAN-I-EAT-THIS-DESIGN-PROMPT.md`
  (gitignored, as all prompts are). Nothing changes in code until it comes back.
* **"Pre-pregnancy" on the stage rail** → kept, last on the rail, and her own
  trimester leads via `PvDoorSection.lead` — the engine's first ranking hook.
  Same four cards for everyone; the order is hers. Tested.
* **The bump keepsake's palette** → a UX redesign of the whole inline body.
  Brief: `docs/design-prompts/BUMP-RITUAL-DESIGN-PROMPT.md`.
* **The birth-plan tool** → the brief asks for it, so it is built. Brief for
  the screen: `docs/design-prompts/BIRTH-PLAN-DESIGN-PROMPT.md`; the model,
  store and wiring are done now (see §38.5) and the screen is a plain working
  version to be re-skinned when the design lands.

### 38.5 ⏰ REMINDER — one format for articles and reads — DISCUSSED 2026-09-16, see §60

**The user wants a discussion before any more of this is decided, once
Garbh Sanskar and Mind and mood are built.** Raise it then, unprompted.

What is on the table: the app now has at least four ways to present a written
piece — `PvReaderScreen` for `PvRead`s, the older article reader, the
condition and scan detail screens, and the report tool's finding pages — and
two words for it on the door ("Read" vs "Article", see `PvDoorFormat`'s own
comment on why they were kept apart). On 2026-09-11 the Complications browse
list was switched from a `READ` chip to `Article` to match the door's rails,
and the user asked for that to be held as an open question rather than a
precedent: *"I want to discuss a singular format to view article/reads."*

So until that discussion: **do not unify readers, and do not rename chips
further.** The choice made on 2026-09-11 stands only because it is
consistent within one door.

### 38.6 The birth plan exists — 2026-09-11

Built on the user's decision (*"the PDF says it, so we need it"*):

* `lib/data/birth_plan_data.dart` — six sections, twelve questions, every
  choice phrased as a preference. A test refuses any label that opens as an
  instruction and any string that leans ("safer", "recommended").
* `lib/services/birth_plan_store.dart` — one JSON document in prefs, local
  only and deliberately not synced (same reasoning as the checklists, plus:
  the share sheet IS the sync, by her hand). Single-choice questions are
  enforced by the store, not the screen.
* `lib/screens/pregnancy/birth_plan_screen.dart` — the plain working version
  on the door's tool chrome. **A Claude Design brief replaces it:**
  `docs/design-prompts/BIRTH-PLAN-DESIGN-PROMPT.md`, written against the model
  so the design cannot ask for what the data does not hold.
* On the Labour prep door as a **tool** card between the pain-relief primer
  and the owed options read. `pv_door_labour_test.dart`'s "absent" assertion
  is now its opposite, with the history in the comment.

**Two things it made possible and that are NOT done, because they reverse
somebody's decision:**

* **The journey step.** `pregnancy_journeys.dart` removed "Can I write it
  down?" on review, because the tool did not exist. That reason is gone. It is
  one uncomment with `surfaceId: kLabourSurfaceBirthPlan`. Your call.
* **The hospital-bag item.** `ready_for_birth_data.dart` has
  `docs_birthplan` — "Birth plan (if you have one)" — which could now open the
  tool. The bag item model has no link field; adding one is small.

**Still owed:** the designed screen; a clinical read of the section leads
(they explain nothing clinical, but they are copy on a birth screen); and a
decision on whether the summary should also offer "copy" beside "share" for
people who paste it into a hospital's own form.

---

## 39.0 Sleep, the first parenting door — 2026-09-11

Built from `ParentVeda_Sleep_rebuild.pdf`. The CONTENT is the parenting
section engine (`PpSection` / `pp_content.dart`), rebuilt to the brief; the
SHELL she opens it through is a parenting copy of the door the TTC and
pregnancy doors wear — decided on a phone the same day, after the brief's
own landing-and-library shape was built and seen (*"i need exact same
structure ui as other doors"*). Nothing in the pregnancy engine
(`pv_door_*`, `lib/screens/doors/`) was touched or imported; parenting has
`lib/data/doors/pp_door_data.dart` + `pp_door_sleep.dart` and
`lib/screens/post_pregnancy/doors/`, with the coverflow copied a third time
and its seam finally taken (plain values, not a model).
`test/pp_sleep_door_test.dart` holds both the brief's map and the shell as
assertions.

⚠️ **The brief said "do NOT flatten into pregnancy-style sub-tabs."** The
user overrode that for the shell only, having seen both. The seven
collections are intact as the section's areas; the door groups them on five
tabs (`pp_door_sleep.dart` says which and why). The brief's landing items
survive as tool rows (tracker on tab 1, Sleep Sounds on tab 5) and the
closing row (Talk to a sleep expert, under every tab).

### 39.1 What changed, in one list

* **The age rule.** `PpSection.autoScope` (Sleep only) removes the band
  chips and locks the library to her band; the landing says "FOR {name} ·
  {band}" instead of offering a chooser. `rowMonths` on `PpTable` (her row
  hoisted, tagged) and `PpChartCard` (marked in place) makes the night-waking
  table, the naps-by-age table and the regression timeline lead with her
  row. The "Is she sleeping enough?" tool and its six "check the range for
  her exact age" links are gone (commented). The five age charts are one
  title, "Her sleep right now"; auto-scope shows one.
* **Four new block types** in `pp_content.dart`: `PpCarousel` (full-screen
  story, `pp_story_screen.dart`, swipe-up opens a linked page),
  `PpInteractive` (night step-through and walk-through checklist,
  `pp_interactive_screen.dart`), `PpAnimation` and `PpIllustration` (drawn in
  code, `pp_content_art.dart`). Three page flags: `toolSurfaceId`,
  `linkedOnly`, `pinned`. All documented in `docs/PP-SECTION-PATTERN.md`.
* **Reformats:** cycles → animation; settling, malish, swaddling → video
  (three new slots); 3am → night interactive; sleep space → checklist
  interactive; bed-sharing and back-to-sleep → labelled illustrations; the
  worry set and the music myths → carousels.
* **New:** wake windows tool (`pp_wake_windows`, `pp_wake_windows_screen.dart`,
  numbers pinned to the tracker's by test), the overtired baby, sleep away
  from home, dummy/soother, and *Where we stand on sleep training* — pinned,
  with the push-back script. Night weaning and own cot/room already existed
  under other titles and were moved and retitled, not rewritten.
* **Merged/cut:** "The hour before bed" folded into the routine page; the
  checker cut; "Log her sleep" no longer a tool row because it IS the hub's
  second door. Sleep Sounds stays the one tool.
* **Single source:** the collection 7 library page is now generated from
  `kPpSoundCategories`, so the catalogue and the player cannot disagree. The
  tanpura drone points at Garbh Sanskar's `raga_drone.wav` — the brief's
  "shares assets with Shravan" — and is the first track that actually plays.

### 39.2 Needs a decision

* ~~Format badges on the hub landing~~ — moot: the Sleep tile opens the door
  directly (`pp_home_v3._openBracket` consults `kPpDoors` before the hub),
  and every door card and row carries its chip. `kPpSleep` (the hub config)
  stays as the door's hero and closing source and is not rendered for Sleep.
  The `PpSectionScreen` library for Sleep is likewise unreachable rather than
  deleted: the router sends `pp_section/parenting_sleep[/area]` to the door,
  on the tab that holds the area.
* **The photo hero.** Nearly every "sleeping baby" stock photograph shows the
  baby on her front, which is the one thing collection 5 says never to do.
  The one in use (Hu Chen, Unsplash) is a close face and fist with the
  position out of frame. Swap the URL in `pp_door_sleep.dart` if a better one
  turns up; the rule in `PpDoor.heroImageUrl` is the constraint.
* **The 4-month regression is now 3–6 months only** (was also newborn), and
  8–10 months / toddler wobbles are likewise narrowed to their own bands,
  because the brief says "the other regressions surface at their ages". The
  cost: a parent at 2½ months cannot read ahead about the thing that hits at
  3½. If that is wrong, the fix is the band tag, one line each.
* **`pp_sleep_check` still resolves in the router.** Feeding's food chart
  shares the screen, so the route stays; nothing in Sleep points at it. Leave,
  or retire the Sleep half of the screen's copy.
* **The other nine sections keep their age chips.** The brief says the age
  rule is app-wide; it is one `autoScope: true` per section when each
  section's own rebuild arrives, plus `rowMonths` on their age-arc tables.

### 39.3 Owed

* **Films for the new slots:** `sleep/where_we_stand` (3 min),
  `sleep/malish_demo` (9 min), `sleep/swaddle_demo` (5 min). Plus the two the
  brief calls "coming soon" that already had slots: the three-parents night
  waking film and the regressions explainer.
* **Artwork, optionally.** The cycle animation and both illustrations are
  drawn in code and are the finished state; `PpIllustration.asset` replaces a
  painter with a file and keeps the legend.
* **Clinical read of the seven new pieces**, in particular the wake-window
  spans past 12 months (the tracker only goes that far; the tool extends to
  five years), the dummy page, and the stance page's summary of the
  sleep-training evidence.
* **Tracks the old library page listed and the player does not:** Aaja
  Nindiya Aaja, Lalla Lalla Lori, Thaai Thaai, Raag Nilambari (present),
  Raag Bageshri, Bansuri, several nature loops and stories. They are in the
  kept-for-revert comment at the foot of `pp_sleep_content.dart`; if wanted,
  they are added to `pp_sounds_data.dart` and appear on both screens.

### 38.7 "Can I eat this?" rebuilt from the design — 2026-09-11

The first Claude Design round-trip on the pregnancy doors. The prototype
(`Can I Eat This.dc.html`, project 9df51a8c…) was read through `DesignSync`,
checked against the brief's must-nots and the two models, and rebuilt as
`lib/screens/nutrition/can_i_eat_body.dart` — self-contained now, no longer a
stack of the two old bodies. Seven widget tests hold the design's promises.

**What the design changed that is behaviour, not skin:** search filters in
place (was a full-screen delegate); a food row expands in place (was a push);
a craving expands with its recipe as a fact block (was a push). All three
were the brief's own "not a new screen unless you can argue for it".

**Two departures, both in the file header:** the food row also shows `myth`;
the prototype's footer disclaimer is dropped because the door renders one.

**Now a question:** `FoodCheckScreen` and `CravingsScreen` still exist as
standalone screens (Tools hub, global search) and still wear the old
presentation — a push-per-row list with emoji. Two UIs for one question.
Either point them at the new body (and retire `FoodCheckBody`/`CravingsBody`
— comment out, never delete) or accept the difference as "the door is the new
front". Your call; the door tab does not depend on it.

**Not owed, worth knowing:** the long-tail verdicts and foods the prototype
placed to make the grouping legible are NOT what shipped — the body reads the
real library, so nothing the design invented reached the app. The category
names matched the library exactly.

### 38.8 The bump ritual rebuilt from the design — 2026-09-11

Second Claude Design round-trip. The board offered three main views; the
user picked **1a**, it was built, and on the phone with real photos it read
as a wall of full-width images. Rebuilt the same day as **1a's top over 1b's
album** — header, add card and Then & Now, then trimester bands with a two-up
grid read forward. The user's words: *"what if the person has done it for
every week? They keep scrolling with such big images thrown at their face."*
Recorded because it is the first time a board's chosen direction was
overturned by the phone rather than by the brief. Built as
`lib/screens/belly_skin/bump_ritual_screen.dart` — `BumpRitualBody` for the
door tab and `BumpRitualScreen` (door-family chrome) for the four other
callers. `bump_journey_screen.dart` is retired in place with a note, not
deleted; `BumpStore` and `BumpBookScreen` are unchanged apart from the book
screen's new `initialAction`.

**Behaviour that is new, not skin:** "Save as one image" on Then & Now
(`RepaintBoundary` → PNG → share sheet); the book sheet opening straight to
download or print. Everything else is the shipped store under a new front.

**Not carried over from the old screen, on purpose:** the trimester and
"captioned" and "favourites" filters (the design has no filter — the timeline
is the whole book, and favourites are marked on the photo, not filtered); the
"capture this week?" nudge (the add card IS the nudge); the milestone trophies.
If anyone misses the filters, they are one Wrap of chips over the same list.

**Owed:** the moments' copy is English-only new copy per policy; the old
screen's Hindi milestone strings (`jrHalfway` etc.) are no longer read from
this screen. And a device check of Then & Now's share with two real photos —
the test harness cannot render a `RepaintBoundary` to PNG.

### 38.9 One card language, everywhere — 2026-09-12

The user, walking every door: *"we should need to maintain symmetry."* Two
engine rules reversed in one change:

* **"Tool tabs get full-width rows"** (`PvDoorLayout.stack`) — gone as a
  drawing instruction. The enum stays as a description of the tab.
* **"A section of one tile gets a full-width row"** — gone. A rail of one is
  a rail. The gutter it leaves costs less than a second card language.

`_WideTile` is retired in place. `PvDoorRow` stays for the screens that are
lists by nature INSIDE a door (Find a condition, the report tool's topics).
`_RailCard` is promoted to `PvDoorRailCard` in the chrome so an embedded tool
can draw the card without a tile — the reports locker's "Add a report" is the
first. A render test now walks every tab of every door and fails if the rail
count differs from the section count.

**Two more repeated cautions found and fixed on the way:** My scans printed
the timeline footer and the door's closing line (same sentence) back to back —
the door's line is now the full footer, verbatim, and the embedded timeline
does not draw its own; and Labour prep's timer note ended with the closing
line's sentence, so the note is now one sentence.

**And a bug older than the doors:** there was no way to mark a scan done. The
timeline said "Not marked as done", the Next screen said "mark it on your
timeline", and the only callers of `markCompleted` were the old home and the
father's daily. Each timeline row now carries "Mark as done" — **only once its
window has opened** (the first cut put it on every row; *"how can I be asking
someone to mark a scan a month ahead?"*) — and "Undo done" on done rows.

**Still open from this pass:** `ScanDetailScreen` has no done control either;
the row is the one place for now. And Mind & mood — its PDF was never opened
(`ParentVeda_Mind_and_mood_final.pdf`); the tile still opens the old landing
whose eyebrow reads "Pregnancy mental health". Next.


---

## 40.0 Mind & mood, the sixth pregnancy door — 2026-09-12

Built from `ParentVeda_Mind_and_mood_final.pdf`. The area was already the
fullest in the stage (26 reads, a real breathing tool, a grounding flow, a
screener, mood log, worry journal, three offerings, a crisis path), so the
door is mostly a new front — plus a lot of verbatim copy.

### 40.1 What the brief asked for and got

* **The duplication bug, fixed.** "Check how I am feeling" and "Help me feel
  better" both pushed the old landing. They open the door on Track and on
  Feel now, through a new `PvDoorScreen.initialGroup`. The old landing is
  retired in place. The eyebrow reads "Mind & mood", the tile's own words.
* **Verbatim copy, all of it:** nine "Is this normal" reads rebuilt under new
  titles; seven "What no one talks about" reads, new; "Fear of being a bad
  mother" rebuilt; "Baby blues, or something more?" new; the same-day red flag
  as the fourth tab's pinned flag; eighteen affirmations; the four-step
  hard-day reset (was a coming-soon film, now a guided screen on the breathing
  circle). Every read carries the byline from one constant. The test pins
  first and last sentences.
* **Do not drop anything.** The rails read `kMmArticles` by group; a test
  asserts every read in the library is on the door and none sits on two tabs.
  The six "more than a mood" reads moved to sub-tab 4, where the brief puts
  perinatal depression; the five "everyday care" reads and the three unnamed
  fears stay on Understand.
* **Cross-links, not copies.** "Fear of labour" links to Labour prep's birth
  tab, "Fear something is wrong" to Scans, "Bringing him in" to the partner
  piece — through an injected callback so the article screen never learns
  how to open a door. Every read also gets a "talk to someone" foot.

### 40.2 What the brief asked for and could NOT get — STOPPED AND LISTED

> Every door's such list now lives in one file, `docs/DOOR-CONTENT-OWED.md`,
> to be tackled once at the end. This section is the story; that file is the
> ledger.

The brief's rule: *"Use that copy VERBATIM… If a referenced page is missing,
STOP and list it."* Three `[new]` cards have no copy in section 3:

* **Tell your doctor** [Guide new] — "How to raise it, with Ask Veda to word
  it." No copy. **Coming soon on the door.** The prose is owed by whoever
  writes the briefs; not written here.
* **Your partner can feel this too** [Read new · optional] — no copy, marked
  optional. **Omitted.** The existing partner piece is linked from "Bringing
  him in" instead, which is where the brief points at it.
* **Helpline numbers** [Guide new] — no prose, and none needed: it is the
  numbers `mind_mood_data.dart` already holds (Tele-MANAS 14416 /
  1800-891-4416, emergency 112). Built as a screen listing them. Those numbers
  are still marked `REQUIRED_TO_CONFIRM` in the data file, as before.

And one deliberate deviation: **no Ask Veda card on Talk**, same as Scans —
the FAB is on every screen with the door's context.

### 40.3 ~~Not walked on a phone~~ — walked 2026-09-12, see §42.4

The other terminal held the device for this build. Every tab draws in the
render test at 360dp, the four new screens pump without exception (one
overflow was caught and fixed — the offering's price row), the reset walks
its steps and the affirmations show one at a time. **Still owed: a handset
walk**, the same as every other door got, before this one is called done.

### 40.4 Still owed

* ~~The handset walk (§40.3).~~ Done; findings and fixes at §42.4.
* "Tell your doctor" copy (§40.2).
* Clinical review of the seventeen new/rebuilt reads and the red flag — the
  brief names a reviewer and a date, but nobody here has read them.
* The four calming tracks and five meditations are still coming-soon; the
  brief says reference Garbh Sanskar's Shravan assets, which would be a
  wiring job once those assets are in the repo.
* **Two briefs left:** Garbh Sanskar (the coupled pair).

---

## 41.0 Feeding, the second parenting door — 2026-09-12

Built from `ParentVeda_Feeding_rebuild.pdf` on the Sleep door's shell and
rules (STILL-OPEN §39): content in `pp_feeding_content.dart`, the shell in
`lib/data/doors/pp_door_feeding.dart`, the contract in
`test/pp_feeding_door_test.dart`. Nothing in the pregnancy engine touched.

### 41.1 What changed, in one list

* **The age rule.** `autoScope: true`; "Can he eat this?" lost its age
  chips and its "pick that first" line (answers for his age, says so once);
  "What to feed at this age" is a new auto-scoped screen
  (`pp_what_to_feed_screen.dart`) that MERGES the three surfaces the brief
  named: his day of food (the `age_charts` pages for his band, rendered
  through the same block renderer), the "Is he getting enough?" signs card
  (read from `bf_how_often` by id), and the regional swaps page. The
  collection is hidden on the door (`PpDoor.hiddenAreaIds`), not deleted —
  it is the tool's data.
* **Reformats:** latch and positions → video (positions gets its own slot);
  bottle → video with a five-card glance; textures → a drawn four-katori
  illustration; allergens → a checklist interactive (eight allergens, tick
  what he has had, ends on the list still to do, closing routes to the
  allergy page); choking prevention → a "cut it this way" illustration;
  allergic reaction → a mild / call-now illustration plus three cards.
  "Reading the growth chart" → a card that opens the Growth journey, where
  the percentile read already lives (its duplicate prose kept for revert).
* **New:** how much formula by age (chart, her row leads); setting up for
  solids; constipation when solids start (→ Health); **If he chokes: what to
  do** (video + the sequence, pinned as the Safe tab's red flag); gagging vs
  choking (carousel); vitamin D and supplements.
* **Links the brief asked for:** "not making enough" → feed tracker; sick
  days → Health; constipation → Health; the choking page → the response.
* **The door:** five tabs — Milk feeds (breast + formula, mastitis red flag,
  Log his feeds), Starting solids (What to feed + Can he eat this lead the
  rail), Cooking for him (Recipes), Growing well (weight gain + not eating,
  Track his growth), Keeping it safe (choking response red flag). Closing:
  lactation expert. Hero: NHN / Unsplash, a toddler upright in a high chair.
* **One renderer fix seen on the phone:** a long chart-card value collapsed
  the label to one letter per line; the row is now 5:7 and the value wraps.
  Every section's chart cards benefit.

### 41.2 Needs a decision

* **The allergen tracker does not remember.** The brief says "an allergen
  tracker: tick egg, peanut…". It is a walk-through (introduced / not yet)
  that ends on the list still to do, and it forgets on close — the same
  rule as the sleep-space checklist. A persistent tracker is a store, a
  table and a sync contract; if the brief meant that, it is a small backend
  job and this screen is its front.
* **The three "what to feed" surfaces are one now,** and `pp_food_chart`
  points at the new screen. `PpChartBrowserScreen` (the chooser version) is
  kept and still routed for Sleep's old `pp_sleep_check`, which nothing
  reaches. Retire it, or leave it as the engine for a section that has not
  been rebuilt.
* **"Baby not eating food" still holds `picky_sweet_packet`** ("He only wants
  biscuits and chips") and the breast collection holds `bf_biting` — neither
  is in the brief's map. Kept, per "do not drop reused pages this map did
  not name".

### 41.3 Owed

* Films: `feeding/positions_demo` (8 min), `feeding/back_blows_demo`
  (5 min). The latch, bottle, textures and choking-safety slots existed.
* **Clinical review, and it is not optional here:** the choking response
  sequence (back blows, chest thrusts, abdominal thrusts, CPR hand-off),
  the formula amounts table, the allergen list and its high-risk caveat,
  the vitamin D dose line. All marked REQUIRED_REVIEW in the file.
* Artwork, optionally, for the three new drawn illustrations.
* The handset walk covered the hero, the five tabs, the merged tool and
  the chart fix; the interactive tracker and the two illustrations were
  seen only in tests.

---

## 42.0 Garbh Sanskar, the seventh pregnancy door — 2026-09-12

The last two briefs are a pair: `ParentVeda_Garbh_Sanskar_rebuild.pdf` puts
a door on the area, `..._pillars_build.pdf` builds the four pillars behind it
to final. The user chose door first, then pillars one at a time; this is the
door. Not walked on a phone — the other terminal holds it.

### 42.1 The two briefs disagree about the premise

The door brief says *"this area is already fully built"*; the pillars brief
says the four pillars *"are placeholders today"*. The code says the second:
ten Shravan tracks and one bundled drone that all of them play; a Samvad
narrator that is a "coming soon" line; a 4×4 Sudoku with three fixed boards;
a "Guided Relaxation" that is a breathing pattern named `relax`. The
recording, the daily picks, the games, the breathing circle, the ritual
picker, the journal and the invite flow are real.

So the door reuses everything as it is and **nothing on it is coming-soon**:
every card opens a screen that exists, and the placeholder is inside the
screen. That is the pillars job, and it is in `docs/DOOR-CONTENT-OWED.md` §7.

### 42.2 What the engine grew, and why each one

* **`kPvDoorTabSurface`** — a surface id that switches the door to one of
  its own tabs instead of pushing. Today is a launcher (*"Today only opens
  the tabs below, it does not repeat their libraries"*), and a push would
  stack a second Listen on a door that has one. The screen intercepts it in
  `_openTile`; the router resolves it as true and never builds a screen; the
  Scans registry test skips these tiles and the door's own test checks the
  target tab exists.
* **`PvDoorSection.inline`** — a section whose rail a widget draws. "Whatever
  is picked shows on Today" means the rail depends on `GarbhJournalStore`,
  and a page built once cannot know it. `GarbhRitualRail` listens and draws
  the picker card plus one card per picked ritual, as a horizontal ListView
  of `PvDoorRailCard`s so the symmetry test counts it like any section.
* **`PvDoorGroup.noteFor`** — the tab note as a function of her week. "Why
  this week" is `garbhWeekReason(week)`, banded by what is forming.
* **`PvDoorAudioTile` grew a live form** beside the coming-soon one, the
  same pair as `PvDoorReadTile`. Mind & mood's four tracks use `.comingSoon`;
  Shravan's ten open their player.
* **`PvDoorFormat.game` / `PvDoorGameTile`** — the brief marks the puzzles
  [Game], and "Tool" over Sudoku would be the chip lying.

### 42.3 Calls made

* **The one new item is the closing line.** The map puts "Where this comes
  from" on My Journal; the brief's own box says *"one new note added at
  AREA LEVEL"*. The closing line is the area-level note the engine has, so
  it renders under every tab. It is the only copy in the door file that was
  written rather than carried.
* **STOP IF is the pinned flag on For you**, titled "Stop and call your
  doctor today if...", the six lines from `_StopIfCard._signs` unchanged,
  the safety note as its footer. It opens the Kriya screen.
* **The honesty line is For you's tab note**, verbatim: "This one is for
  you, and it will not make your baby cleverer."
* **The six affirmations open the record-first screen** on that piece
  (`GarbhSamvadDailyScreen.piece`), not the library's inline card. Her voice
  is the point; a card that opened a page with no record button would have
  demoted it.
* **My Journal is the tab** (`GarbhJournalScreen(embedded: true)`): header,
  the album by week, then write-a-letter and invite as two rail cards in a
  horizontal scroll (not a ListView, so the tool tab counts no rails). The
  "stays yours" sentence is the tab note.
* **`garbh_daily` now opens the door.** `GarbhDailyScreen` is retired in
  place, one commented line in `surface_router.dart`. The home's "Today's
  Garbh Sanskar" block still opens each pillar's daily screen directly —
  untouched, as the brief asks.
* **Vichara's stories are not on the door.** The brief does not name them
  and the retired landing had already dropped that pillar.
* **Games opened from the rail do not mark the day done** (`markComplete:
  false`) — the door keeps no score.

### 42.4 Walked on the phone — 2026-09-12, and what it found

Both owed walks done on the S21 FE: Garbh Sanskar and Mind & mood.

* **A saved album that never loaded.** `GarbhJournalStore.init()` existed
  and nothing called it. Her rituals, the japa count and every recording
  were written to prefs and never read back after a restart — and because
  the store's set was empty until loaded, the first toggle after a restart
  overwrote the saved set with one item. Found because the ritual rail
  showed no Japa after a reinstall. Wired in `main.dart` beside the sibling
  stores; a source test pins it. This was live before the door.
* **A launcher tap changed the content under her thumb and nothing said
  which tab she was on.** The Today card sits a screen below the selector.
  `_openTile` now scrolls the selector into view on a switch.
* **The Tools tab still opened the old pillar menu.** `tools_hub_screen`'s
  Garbh tile pushed `GarbhScreen` — the "pick a pillar" library the door
  replaced — so the area had two front doors. It opens the door now.
* **Sudoku's keypad overflowed by 26px** at this width. Horizontal scroll.
* **The ritual picker's COUNTER badge touched the Japa blurb.** A gap.
* **Mind & mood's hard-day reset printed its title twice** (scaffold and
  intro heading) and showed "That is it. Nothing to log..." under the Start
  button before she had started. The intro has no heading now, and the close
  line is the last step's body only.
* **Tele-MANAS's toll-free number** now reads 1800-891-4416 on the button;
  the dial string is the untouched constant.
* Listen's tab note said "her calm" — third person on a screen spoken to
  her. Fixed.

Seen and left: the global Ask Veda FAB sits over the right end of any
full-width primary button (the reset's Start, Next) — app-wide, not a door
thing. The Shravan player's honest "sample plays here" line and its emoji
illustration are the pillars brief's.
* **The four pillars to final** — the second brief. Order agreed with the
  user: Kriya, Buddhi, Samvad, Shravan last. Audio hosting decided:
  **Cloudflare R2** (zero egress; `NarrationService` already anticipates
  it). What each pillar owes is the ledger's, not this file's — twelve rows
  in `docs/DOOR-CONTENT-OWED.md` §7, one per job.
* **All eight pregnancy briefs are now built.** The reminder at §38.5 — one
  format for articles and reads — is due.

---

## 43.0 Kriya to final — one breathing circle, and a relaxation that is a session — 2026-09-12

First of the four Garbh Sanskar pillars, from
`ParentVeda_Garbh_Sanskar_pillars_build.pdf`. Not walked on a phone — the
other terminal holds it.

### 43.1 Three circles became one

The brief: *"build the breathing as ONE reusable component... the SAME
component the Mind & body preconception practice uses."* There were three:
Garbh's `_BreathingScreen` (an AnimationController per phase, looping until
Finish), Mind & mood's `MmBreathingScreen` (an async phase loop with a chosen
duration) and TTC's `_Breath` (a stopwatch, a ring, a square for box
breathing, a nostril side). Each correct; each a different breath.

**`PvBreathingCircle` (`lib/widgets/breathing_circle.dart`) is stateless and
clock-driven:** a `BreathPattern` and elapsed seconds in, the shape, the
word and the count out. That is what made it shareable — each screen keeps
its own session (loop until Finish; run for the chosen length; a stopwatch
and a progress ring) and hands the circle the seconds. A widget that owned a
clock would own the one thing the three screens do differently.

**The three area models stay** (`BreathPhase`, `MmBreathPhase`,
`TtcBreathAnim`) and each converts in one `toBreathPattern()`; renaming a
model across three stages for a widget's convenience is the diff that loses
a Hindi label. `test/breath_pattern_test.dart` holds each conversion.

Two visible changes, both deliberate: **the count counts up** everywhere
("one, two, three, four" — Garbh used to count down), and **Garbh's box
breathing is a square** now, as TTC's always was.

TTC's stick figure (`_FigurePainter`) moved with it, to
`lib/widgets/figure_highlight.dart`, because the relaxation lights the same
figure.

### 43.2 Guided Relaxation is a session

`GarbhRelaxationScreen` walks `kKriyaRelaxation`: thirteen steps, 480
seconds, head to toe, the current part lit on the figure, the script printed
under each heading and spoken through `GarbhNarrator`. Pause stops the voice
and resume re-speaks the step from its first word (TTS engines do not resume
mid-sentence); the clock is tick-accumulated so a pause is ticks that do not
add, and so the widget test drives the whole eight minutes with `pump`.
A raga underneath is optional and is Shravan's — `kShravan` through
`RagaAudioStore`, the single player — so today it is the drone, and the day
Shravan gets real files this gets them.

**The narrator:** a file when the narration manifest lists one under the
step's key, the device's TTS when not — `NarrationService`'s own pattern.
Its own `FlutterTts` rather than `BabyVoiceService`, because that one is
pitched 1.8 for the "your baby says" cards. **The manifest keys, for the
recording:** `kriya.relax.settle`, `.face`, `.jaw`, `.neck`, `.arms`,
`.chest`, `.belly`, `.back`, `.thighs`, `.calves`, `.feet`, `.whole`,
`.return`. Thirteen entries in `assets/narration/manifest_hi.json` and the
TTS is never used again.

**The script is original and claims nothing.** The belly step says the baby
is there and this rest is hers — and stops. The test greps every step for
smarter / cleverer / brain / develop / healthier and the like.

### 43.3 Boundaries kept

* Mind & mood **links** to the relaxation (one card on Feel → Breathe,
  `kGarbhSurfaceRelax`) and does not rebuild it; the test proves nothing on
  that door is titled relaxation.
* STOP IF and the safety note are on the relaxation's intro, above Begin;
  the flag is `KriyaStopIfCard`, the same widget the Kriya screen draws.
* No yoga pose is referenced, so nothing links to Yoga & fitness.
* Nothing celebrates at the end. The close is the data's line.

### 43.4 Still owed

* **The handset walk** — the shared circle on all three screens (Garbh,
  Mind & mood, TTC), the relaxation's voice at the chosen rate, the raga
  underneath, the figure.
* **A recorded voice** for the thirteen steps (manifest entries, no code).
* **A drawn figure** (`KriyaRelaxation.figureAsset`; a Rive/Lottie player is
  added to `PvFigureHighlight` the day a file exists — no player package for
  a file nobody has drawn).
* **Background playback that survives a locked screen** for the raga — the
  SHARED block asks for it; `RagaAudioStore` deliberately does not, and its
  header says why. Shravan's turn.
* Three pillars left: Buddhi, Samvad, Shravan.

---

## 44.0 Buddhi to final — four games that are games — 2026-09-12

Second of the four Garbh Sanskar pillars. Not walked on a phone — the
other terminal holds it.

### 44.1 What each one was, and is

| Game | Was | Is |
|---|---|---|
| Word Search | 9×9, an 8-word pool, tap two ends, across/down | 10×10, a 40-word calm pool, drag or tap-tap, across/down/diagonal, new grid every open |
| Sudoku | 4×4, three hand-typed boards | 9×9 easy by default, a gentle 6×6, generator with a uniqueness check, conflicts, pencil notes, Check, Hint, no timer |
| Logic Puzzle | four multiple-choice questions | a nonogram (picross): ten hand-drawn 5×5/6×6 pictures, fill/cross modes, completed clues dim, Hint |
| Memory Match | 8 emoji pairs | 8 pairs of line icons, moves counted quietly |

**Custom, not a package**, all four — stated as the brief asks. A Sudoku
generator with a uniqueness check is ~120 lines of pure Dart in
`games/sudoku_engine.dart`, tested without a widget; a package would bring
its own difficulty ladder and no 6×6. The nonogram is smaller.

**None feeds My Journal.** `test/garbh_games_engine_test.dart` greps the
four files for the journal store's name. Finishing may mark the pillar done
for today (`markComplete`), which the door passes as false.

### 44.2 Calls made

* **Every generated Sudoku has exactly one solution** (cells are removed
  only while the solver still finds one). That is what makes Hint the
  truth for a cell and Check honest. Completion is still "full and
  conflict-free", not equality with the stored answer.
* **Nonogram pictures are hand-drawn, not generated.** Random grids make
  valid puzzles but not satisfying ones. Solved means the clues are met;
  the picture's name is shown only on finish, because before then it is the
  answer.
* **The games moved onto V3's neutrals with Buddhi's indigo.** They still
  wore Garbh's pre-V3 cream and Vichara's green — the one Garbh surface
  that never migrated. The shared chrome is `games/game_chrome.dart`.
* **The old 4×4 and the quiz** are at the foot of `garbh_games.dart`,
  commented, kept for revert; `SudokuGame` and `LogicGame` keep their names
  so `gameForPuzzle` did not change.
* **Sudoku's keypad scrolls** — ten keys do not fit 360dp (the 4×4's five
  already overflowed; §42.4).

### 44.3 Still owed

* **The handset walk** — drag selection in Word Search, the 9×9 at phone
  width (cell size, pencil marks legible), the nonogram's clue gutter.
* Two pillars left: Samvad, Shravan.

---

## 42.0 Health, the third parenting door — 2026-09-12

Built from `ParentVeda_Health_rebuild.pdf` on the door shell (§39). Content
in `pp_health_content.dart`, the shell in `lib/data/doors/pp_door_health.dart`,
the contract in `test/pp_health_door_test.dart`. Mostly a reslot: eleven
collections, fifty-nine pages, all seven tools were already built. Decisions
taken with the user before starting: **six tabs** (the brief's call, to be
judged on a phone), **reframe** the dosing page, **scaffold** the four new
safety pieces (the brief supplies their copy), and the door is the home.

### 42.1 What changed, in one list

* **Six tabs:** Something's wrong (default; fever, cough, tummy, rash,
  other; tools Fever check + Something suddenly different; a pinned "Is this
  an emergency?" that jumps to Tab 2) · Get help now (the canonical red
  flag pinned; signs film; the three speeds as a story; emergency card
  tool; choking response; two scaffolds; the "believe yourself" footer) ·
  His shots · Growing well · Keeping him well · His records and the visit
  (dashboard + emergency card + doctor visit as tools).
* **Single source, done:** `kPpGoNowSigns` (`pp_health_red_flags.dart`) is
  the one go-now list — the Get help now page, the fever red-flags page and
  the fever check's gate all read it; the three hand-written copies are
  merged and kept for revert. Home remedies open the one tool filtered
  (`pp_nuskhe/<category>`); the two per-illness remedy pages are cards
  that open it. The vaccination chart, the create-your-card page and the
  records page are `linkedOnly` — their tools lead. "Not sure what is
  wrong" is hidden — it IS the What Changed flow.
* **Choking response is canonical in Health** (`health_choking_response`,
  moved from Feeding with its copy); Feeding's card opens it through the
  new `pp_page/<section>/<page>` surface, which opens one page of another
  section without landing on that door's selector.
* **Reformats:** thermometer routes, dehydration signs and the rash grid
  are drawn illustrations; blocked nose, ORS and giving medicine lead with
  video; the sponging myths are a carousel inside the fever article; the
  three speeds are a story.
* **The dosing reframe:** `fever_dosing` is now "reading the dose right" —
  find his weight, the strength on the label, that bottle's own row, that
  box's syringe, write it down — plus the five overdose mistakes. The
  mg-by-weight table and the gaps card are in a comment and a test fails
  if a dose range appears in live copy.
* **Engine additions:** `PpPage.comingSoon` (a full-size card that does not
  tap, chip "Coming soon", must be in the owed ledger or the test fails);
  `PpDoorTab.jumpToTabId` / `footer`; the `pp_page/` and `pp_nuskhe/`
  router prefixes; `ppPageScreen` so the router can hand back a page.

### 42.2 Needs a decision

* **Six tabs.** The coverflow was drawn for five; the sixth rides the ring.
  Look at it on the phone; the merge the brief names, if five wins, is
  Growing well into Keeping him well (one line in `pp_door_health.dart`).
* **The fever check still has an age chooser.** The tool prefills his age
  and lets it be changed, on a stated reason (a grandmother checking
  another child). The brief names only the library tab bar. Left; say if
  it should go.
* **Hero photo:** CDC, Unsplash, a stethoscope check-up. Dated look. Swap
  the URL if a better free one turns up.

### 42.3 Owed

* The four scaffolds' copy (HL2–HL4 in `docs/DOOR-CONTENT-OWED.md`) and the
  back-blows film. **The go-now list needs a paediatrician** — it is now the
  union of three lists, marked REQUIRED_REVIEW, and it is the most
  consequential list in the parenting app.
* The handset walk: the wireless connection dropped mid-install, so this
  door has not been seen on a phone yet.

---

## 45.0 Samvad to final — the library is complete and the narrator speaks — 2026-09-12

Third of the four Garbh Sanskar pillars. Not walked on a phone — the other
terminal holds it. The user's call on the copy: write it, no review pass.

### 45.1 What the survey found, and what was built

Recording was already real and already filed by week. The library was
larger than the brief assumed — 16 affirmations, 16 stories, 16 original
lullabies, seven traditions of original reflections — so most of the brief's
"write real content in all four tabs" was already there. What was not:

* **Mantras.** The "Mantras & lullabies" shelf showed the trimester's
  speaking cards under the word mantra. `samvad_mantras_data.dart` is the
  real thing: eleven traditional, public-domain lines — Vedic, Upanishadic,
  Pali, the Mool Mantar, the Basmala, the KJV blessing, one Hindustani folk
  lullaby — each with its script, a transliteration, one plain line of
  meaning and a named source. The transliteration is what she reads aloud
  and what the narrator speaks (the Hindi voice cannot read Arabic or
  Gurmukhi). "Chanda mama door ke" and "Lalla lalla lori" were left out on
  purpose; the foot of the file says why.
* **Four more affirmations** (twenty now), English-only by policy, in the
  style already there.
* **The narrator.** "Or listen to the narrator read it" was a snackbar
  saying coming soon. It speaks now through `GarbhNarrator` — renamed from
  `KriyaNarrator` the moment a second pillar needed it — a recording when
  the manifest lists one under `samvad.<piece id>`, the device's voice at a
  gentle pace when not. Still a text link under the record button, never a
  button of equal weight.
* **Read aloud from every shelf card.** The library offered only Save,
  which made it a reading list; every card opens the record-first screen on
  that piece now. A mantra opens on its transliteration, not its full card.
* **The album lists titles.** A recording's journal entry was titled with
  the whole passage — two hundred words for a story. `GarbhPrompt.title`
  exists for exactly this and is what is written now.

### 45.2 Manifest keys, for the recordings

`samvad.rtb_<slug>` for every `ReadAloudPiece` (slug from the English
title, e.g. `samvad.rtb_you_are_loved`), `samvad.mantra_<id>` for the
eleven mantras, `samvad.<prompt id>` for the trimester speaking cards.
`test/samvad_library_test.dart` proves every key is unique. Same manifest
file as Kriya's, same replacement rule: a line per passage, no code.

### 45.3 Kept, deliberately

* Spiritual reading stays original reflection, no scripture quoted — its
  file's decision — with the tradition off by default until she chooses;
  the mantra shelf is the other half, the lines themselves. The brief
  allowed either.
* The trimester speaking cards still rotate as today's pick; they just
  stopped being called mantras.

### 45.4 Still owed

* **The handset walk** — the narrator's voice on a mantra transliteration
  (does en-IN TTS say "Om bhur bhuvah" acceptably), the three-line mantra
  card, Read aloud from a story.
* **Recordings** for the library — manifest entries.
* **Hindi for the four new affirmations**, if ever asked for.
* One pillar left: Shravan, on Cloudflare R2.

A test lesson, written down because it cost ten minutes: **an un-mocked
platform channel in a widget test never completes — it does not throw.**
`await`ing anything that reaches `flutter_tts` from a test body hangs for
the framework's ten-minute limit. Fire, pump, assert on state; never await
the plugin.

---

## 46.0 Shravan to final — nine real recordings, a manifest, and a cache — 2026-09-12

The last of the four Garbh Sanskar pillars. Not walked on a phone — the
other terminal holds it. The user's call: no audio files of their own; source
them.

### 46.1 Where the sound came from, and the rule that chose it

Every track is on **archive.org**, by a **named recordist**, under a
**public-domain dedication** (CC0, the old CC PD dedication, or the Public
Domain Mark set by the recordist). Direct links, no login, no egress bill,
each item's own page beside it as `sourceUrl`. The SHARED block's rule —
*"When in doubt, leave it out"* — decided the rest:

* Five Carnatic veena recordings: two by **L. Ramakrishnan** (Kiravani
  alapana, "Shri Nilotpala Nayike"), three by **Veena Kinhal** (Nata,
  Vasanta, Simhendramadhyamam). Both artists self-published these with a PD
  dedication; the description names the concert or the studio.
* Four field recordings from **radio aporee** contributors: light rain with
  birds (alfa00, County Clare), sea waves from a distance (Piotrek Zyla,
  Dabki), birds at a forest's edge in fog (maciej janasik, Mechlin), and
  **evening prayer bells at Prakrti temple, New Delhi** (Piotrek Zyla).
* Left out: every "Ravi Shankar collection" and Bollywood item marked
  public-domain on archive.org (the mark is the uploader's, not the label's);
  every item with no creator; a veena *tutorial*; Pixabay and Freesound
  (downloads need an account). Two Taiwanese temple recordings with traffic
  and voices in them lost to the Delhi bells.

**Lengths are the recordings'**, not the brief's: `kShravan.minutes` was
updated (5, 3, 14, 12, 8 / 7, 11, 13, 3) and a test holds it to the
manifest. Sleep Raga at twelve minutes and Baby Bonding Raga at three are
what exists; a longer bonding raga is one more archive.org search.

### 46.2 What was built

* **`assets/audio/shravan_manifest.json`** — one entry per track: id,
  title, category, durationSec, `file` (what plays), `sourceUrl`, licence,
  attribution, note. Replacing a track is editing this file.
* **`ShravanLibrary`** — reads the manifest at startup (`main.dart`, the
  journal-store lesson), answers what plays (a cached file, else the URL),
  downloads to the app's support directory (`.part` then rename), lists
  what is saved. Nothing throws to a screen; no entry means the drone.
* **`RagaAudioStore`** plays URLs now (`isUrl`, stated by the caller, never
  sniffed) and sets an **audio context** — Android `stayAwake` + media
  usage, iOS playback category — so a track keeps playing with the screen
  off. Manifest tracks do not loop; they end, which is what fires
  `onFinished` and the journal's "what your baby heard".
* **`ShravanTrackPlayer`** — one widget for the daily screen and the
  library detail: the real player, the recordist's line under it, a "Save
  for offline" pill. **The first play is the download**: the stream she
  hears is fetched again into the cache, so the second play needs no data.
  With no manifest entry it draws exactly what shipped — the drone and the
  "sample" line.
* **`ShravanCreditsScreen`** — every track's recordist, licence and source.
  The brief asks for credits only for CC-BY; these are shown regardless.
  A card on the door's Listen tab and a link on the detail screen open it.
* **Body Awareness Journey is a script** (`kKriyaBodyAwareness`, nine
  minutes, awareness not release) on the relaxation screen — the brief's
  own allowance. The narration key now carries the SESSION id
  (`kriya.body_awareness.<step>` / `kriya.relax.<step>`): both scripts have
  a `face` and a `belly`, and a step-only key would have played one's
  recording for the other. Found by the test; §43.2's key list is
  unchanged for the relaxation.

### 46.3 Walked on the phone — 2026-09-13, all four pillars

* **Shravan streams, caches, and keeps playing with the screen off.** A
  first play streamed from archive.org within seconds, the real length
  appeared (4:33), "Saving…" became "Saved offline" mid-track, and the
  position ran on through a dark screen with the OS showing the app
  holding media focus. **One bug:** the first build rebuilt the player on
  the cached file the moment the download landed (keyed on the source),
  and the old card's dispose stopped the stream mid-track. The source is
  resolved once per mount now — the stream this time, the file next time.
* **Kriya's relaxation** narrates each step (Google TTS, utterances in the
  log), advances on time, pauses, ends. The raga underneath does play —
  the OS's playback-config "idle" for the MediaPlayer was a red herring;
  MediaPlayer's own "media started" fires at Begin and every twelve
  seconds as the drone loops. The figure's highlight was invisible at the
  tint's 20% over white; it is an ink-grey disc now.
* **Buddhi:** the 9×9 fits 360dp with legible pencil marks; Hint fills the
  selected cell. **Two bugs:** the keypad's 8 and 9 sat under the Ask Veda
  FAB in a scrolling row (two rows now, clear of it), and **drag selection
  in Word Search lost every vertical drag to the ListView** — a pan
  recogniser never beats the parent scrollable's vertical one. Declaring
  the grid's own vertical and horizontal recognisers makes it the inner
  arena member, which wins the tie; across, down and diagonal all select.
* **Samvad:** the mantra shelf shows script, transliteration, meaning and
  source; Read aloud opens the record-first screen on the transliteration;
  the narrator link speaks and flips to "Stop the narrator".
* **The shared circle** on Mind & mood draws a square for box breathing,
  word and count from the clock, "0:56 left".
* Seen and left: the Ask Veda FAB still covers the right end of full-width
  buttons everywhere (§42.4); the Kriya flag card's heading reads "STOP IF"
  while the door's flag reads "Stop and call your doctor today if…" — the
  same list, two headings.

### 46.4 Still owed
* ~~**Cloudflare R2.**~~ Done 2026-09-13: the nine tracks re-encoded to
  128 kbps (ffmpeg, tags carry title / recordist / licence), uploaded to
  bucket `parentveda-audio` under `shravan/` beside the narration's `hi/`,
  each object curl-verified and byte-compared before the manifest's nine
  `file` URLs moved. `sourceUrl` stays on archive.org. Still on the
  `pub-*.r2.dev` development host — a custom domain is one host edit in
  the manifest and one constant in `narration_service.dart`, before launch.
* **A media notification with lock-screen controls.** Playback survives a
  locked screen now, but she cannot pause it from there. That is
  `audio_service` (a foreground service, both platforms' config) and it is
  the reason `RagaAudioStore`'s header waited. One more plugin, done
  properly, or not at all.
* **A longer Baby Bonding Raga** (three minutes today) if one turns up with
  the same provenance.
* **Background audio under the relaxation** — the raga chips on the
  relaxation intro still play the drone (`_kShravanAsset`); the day they
  read the manifest is a ten-line change in `garbh_relaxation_screen.dart`,
  left for the walk so it is heard first.

**All four pillars are built.** The Garbh Sanskar area is complete as
briefed; the ledger's remaining rows are recordings and hosting, not code.

---

## 47.0 Development, the fourth parenting door — 2026-09-12

Built to `Development_Parenting.pdf`, the **reissued** brief of 31 Aug 2026,
which says on its last line that it replaces `ParentVeda_Development_rebuild.pdf`.
The two disagree on every tab, so the user chose: reissued. The door is
`lib/data/doors/pp_door_development.dart`; the contract is
`test/pp_development_door_test.dart`. Walked on a phone at day one; see 48.5.

### 47.1 What was found that the brief did not know

* **Two datasets, not one.** The brief: "the four areas of growing are just a
  closer look at that same list." The tracker (`pp_milestones`) runs on
  `MilestoneStore` — 18 milestones in six domains; the Brain / Physical /
  Language / Emotional pages run on `DevArea` skills in
  `pp_development_data.dart`. Ticking in one does not tick the other. The
  join is a hand map, `_kAreaForDomain` in `milestone_journey_screen.dart`,
  and each domain sheet in the tracker now ends with "Look closer at
  thinking" into the area page. Making them one list is a data job — logged
  as DV2 in `docs/DOOR-CONTENT-OWED.md`.
* **The check-in had no surface.** The hub pushed `DevelopmentCheckinScreen`
  directly; the door needed an id. `pp_dev_checkin`, in the router.
* **A tab of tools alone drew nothing.** The shell rides tools on the first
  rail, and The leaps / Talk and check have no area under them. The shell now
  synthesises one rail headed with the tab's name when a tab has tools and no
  areas (`pp_door_screen.dart`, `_body`). Pregnancy's engine untouched.
* **Two tabs are age-scoped as a whole.** "When will my baby..." is up to two
  years ("drops away after 2, on purpose"), The leaps the first twenty months.
  `PpDoorTab.toMonths`; the selector shows five, then four, for an older
  child. A three-year-old's mother never sees "when will my baby roll over".

### 47.2 The merges and the reframe

* **One tracker.** `pp_on_track` (three groups) and `pp_milestones` (windows,
  flip-cards, find-it search, explore by area) were one list two ways. The
  journey survives; it gained the "Usually settled by now" group (observed
  first, then closed windows; `foundations` excludes observed so nothing
  counts twice) and the checklist's closing line word for word. `pp_on_track`
  opens the journey; `OnTrackChecklistScreen` is kept, unreferenced.
* **The hub beside the reassurance.** `pp_development` (today's pick, the
  activities) is the one Tool on What to do, so a parent who opens the
  activities is one swipe from "the normal range is much wider than you
  think". The hub's own screen is unchanged.
* **The leap dates came off.** The calendar printed his own dates ("3 Oct –
  27 Oct") and "he is in Phase 4 right now". Now `Leap.aroundLabel` — "around
  4 to 6 months", to the nearest half month — "may be in", "ABOUT NOW", and
  the caveat in the header, not the footer. The phase detail page likewise.
  `startDate`/`endDate` stay for the phase alarm. The library's honest leap
  read (`dev_leaps_lens`) untouched, as the brief asks.
* **Tummy time is a film first.** Slot `development/tummy_time`, the six
  steps under it. DV3.

### 47.3 Open, for the user

* **Six tabs on a phone, again.** The brief's call; walk it and decide, as
  with Health. If five, the merge is Talk and check into On track (the
  checker as a tool there, the closing already everywhere).
* **Order on Tab 1.** The shell puts tools first, so "Where he is right now"
  leads the rail and the three reassurance reads follow. The brief lists the
  reads first. The tracker IS the on-track answer, so this seems right; say
  if the reads should lead.
* **"Talk to a specialist" is the closing, not a Tab 6 card.** The closing
  draws under every tab including Tab 6, so a second card there was the same
  thing twice. If the tab should carry its own card, it is one `PpDoorTool`.
* **The hub's two doors** (`kPpDevelopment` in `parenting_hubs.dart`) are
  bypassed on V3 — the tile opens the door — and untouched for the older
  home.

---

## 48.0 Behaviour, the fifth parenting door — 2026-09-13

Built to `Behaviour_Parenting.pdf` (31 Aug 2026). The door is
`lib/data/doors/pp_door_behaviour.dart`; the contract is
`test/pp_behaviour_door_test.dart`. Walked on a phone at day one; see 48.5.

### 48.1 The brief said "no tabs"; the door has five

"Behaviour is a Sleep or Feeding type area, not a Health or Development one.
One clean library plus a tools rail. Do NOT invent a five-tab structure." The
standing call (§39, decided on a phone) is that every parenting door wears the
shell, so the twelve areas needed a grouping the brief did not draw. The
user's, from three options: **Crying, the first year · Tantrums and the ziddi
years · He keeps doing this · Scared, shy or clingy · Calm and guidance.**
Tools ride the tab they belong to (scripts on Tantrums, and on Crying for the
infant's parent; the checker on He keeps doing this); the psychologist is the
closing.

### 48.2 What the shell learned

* **A tab with nothing for his band drops.** An infant's parent sees one tab;
  a four-year-old's sees four, without Crying. `_tabs` in
  `pp_door_screen.dart`: a tab stays if any of its areas is in his band, or
  it has no areas at all (a tools tab, like Development's leaps). The brief's
  age rule was "other bands hidden, not one tap away", and an empty tab is
  the emptiest kind of one tap away.
* **The breathing circle is an animation kind.** `PpAnimationKind.breathing`
  renders `PvBreathingCircle` (`lib/widgets/breathing_circle.dart`) on
  `kPpBalloonBreath` (in 3, out 5). One circle app-wide, as that widget's
  header demands; `pp_section_test` now treats a leading animation like a
  leading video for the intro rule.

### 48.3 The merges, in one list

* `lying` ("She told me a lie") merged into `beh_older_lying`, taking its film,
  script and doctor line with it. `beh_cooperation` is a reference card into
  `beh_not_listening` (`pp_page/parenting_behaviour/...`). The area "Lying,
  back-talk and screens" dissolved: `siblings` reslotted into Three to six,
  the const kept. The aggression mechanism is `beh_anger`'s; `hitting_biting`
  and `beh_no_hitting` link to it. `defiance` links to `beh_ziddi` for the
  will-before-words explanation (both areas kept, on the user's call).
* Reformats: `crying_too_much` is the dark step-through (eight screens, the
  never-shake screen among them, the get-help line as its closing);
  `beh_balloon_breathing` the circle; `beh_calm_jar` a film; the screen-time
  chart hoists his row.
* New: `beh_back_talk` from the brief's copy, verbatim. Two new areas as
  eleven coming-soon cards (BH1–BH11 in the ledger), the self-touching page
  included on the user's call.
* The scripts tool lost its age chips (`scripts_library_screen.dart`, kept for
  revert); the checker opens pre-filtered via `pp_what_changed/behaviour`,
  and the home's dead `kPpActBehaviour` arm is commented with a pointer.

### 48.4 Open, for the user

* **Six-vs-five stays open for Health and Development**; Behaviour is five.
* **The crying-too-much screens want a clinical read** (BH13): the copy is
  the article's, cut into eight, but a safety page in a new medium is worth
  one more pair of eyes.
* **The scripts tool's "for the family" copy** on the infant tab is mine, not
  the brief's; say if it should read like the toddler card.

### 48.5 Decided on a phone, 2026-09-13

* **Six tabs on Health and Development.** Seen on the selector; kept.
* **The closing is a card, on every door.** Sleep's sentence (representation
  B) is commented in `pp_door_sleep.dart`; `PpDoor.closingLine` stays for
  revert, unset everywhere.
* **Read, then the tool for it.** Development's On track rail goes normal
  range → tracker → worth checking → check-in → born early, on the user's
  call ("educate someone before the tool"). `PpDoorTool.afterPageId` in the
  shell; a tool with no page stays at the front.
* **The infant-tab scripts blurb** was never on screen: rail cards draw a
  tool's label and chip only, so the question was moot. Left as data.
* **Noticed, not touched:** the Ask Veda FAB sits over the last lines of
  every story screen (Sleep's 3am too). Hiding it on stories is the FAB's
  route-name check, `global_ask_fab.dart`.

### 48.6 Locked tabs, not hidden ones — 2026-09-13

Seeing Behaviour at day one — one card on the selector — the user's call:
"do it like a game: show them, but locked, with the open one at the top, so
they don't lose access, know what's coming, and the section does not look
bare." So the shell now tells three states apart per tab (`_lockFor` in
`pp_door_screen.dart`): **open** (an area in his band, or a tools-only tab),
**locked** (every area's band starts after his age — drawn misted with a lock,
"From 1 year" as the card's second line, after the open tabs; selecting it
shows a panel "This opens when he turns 1. Nothing here is due before then"
and the closing), **past** (`toMonths` reached, or every band closed behind
him — gone, as the briefs ask). The unlock age is the earliest `fromMonths`
of the tab's areas' bands. Behaviour at day one: Crying open, four locked.
Seen on the phone.


---

## 49.0 Potty, the sixth parenting door — 2026-09-13

Built to `Potty_Parenting.pdf`. The door is `lib/data/doors/pp_door_potty.dart`;
the contract is `test/pp_potty_door_test.dart`. Walked on a phone at day one; see 49.3.

### 49.1 The calls

* **Five tabs** from seven areas, the user's from two options: How long this
  takes (the pinned timeline) · Catching the su-su · Starting out (readiness,
  day by day, and the three activities) · Accidents
  and going backwards · Dry nights, doing it herself. No tools on any tab,
  no red flag, no quiz — the brief's stance, kept and tested.
* **Widen** (judgement call 1): readiness, starting out and accidents now
  carry `['learning', 'dry']`, so a four-year-old still training or
  withholding reaches them; su-su stays baby-only, dry nights 3 to 6. The
  door shows a baby's parent two tabs open and three locked (From 1 year ×2,
  From 3 years); a two-year-old's has su-su gone and dry nights locked.
* **The three-day method** (judgement call 2): a coming-soon page in
  Starting out, PT2, copy to come with the holding-it-in warning built in.
* **The two-door hub collapses** by the tile opening the door;
  `kPpPotty`'s two doors and the `kPpActPotty*` arms on the home stay for
  the older home.

### 49.2 Single source, as links

The Indian-toilet page leads with the one film (`potty/indian_toilet`) and
the washing-and-wiping page points at it instead of teaching the mug twice.
The yeast-rash line points at Health's rash grid; withholding at Health's
constipation page; regressions at Behaviour and the leaps read. Four
scaffolds: no star charts, three-day method, pull-ups, taking longer (PT1–4).

### 49.3 Open

* The Indian-toilet page's badge is now VIDEO (it leads with the film); the
  other film-led pages here keep ARTICLE as the brief lists them. Say if the
  badge should follow the film everywhere.
* Walked on the phone at day one (2026-09-13): two tabs open, three locked,
  pages render. One thing to know: the first tab is named "How long, and is
  she ready", and for a baby only the timeline shows on it — readiness is
  1 to 6, so its rail is hidden inside an open tab rather than locked. The
  tab name over-promised for that one band. **Decided:** readiness moved
  to Starting out, the first tab is "How long this takes" alone.

---

## 50.0 Early Learning, the seventh parenting door — 2026-09-13

Built to `Early_Learning_Parenting.pdf`. The door is
`lib/data/doors/pp_door_early_learning.dart`; the contract is
`test/pp_early_learning_door_test.dart`. Walked on a phone at day one; see 50.3.

### 50.1 The calls

* **Five tabs** from the brief's four, on the user's call: the school tab
  split where the code already had two areas — Do something today · Stories
  and rhymes · Good habits · Before letters and numbers · Starting school.
  Everyday things at the front; the school tab is one of five, not the door.
* **Call 1, split:** the old home's "Prepare for school" door now deep-links
  to the school tab (`areaForAction` in `pp_home_v3.dart`); the V3 tile opens
  the door on Do something today.
* **Call 2, keep both:** the five habit twins (sharing, waiting, kindness,
  truth, screens) stay here as build-the-habit pages and each links to its
  Behaviour in-the-moment page by `pp_page/` (sharing → sharing, waiting →
  sharing, kindness → beh_friendships, truth → beh_older_lying, screens →
  beh_screen_ending). The two section-level links became page links.
* **The activity picker is not a tool on the door.** The first tab's rail IS
  the set for his age; a Tool card opening the same set was the door-and-tool
  duplication the brief names. `pp_activities` still exists for the older
  home and the links into it.

### 50.2 Owed

Two scaffolds (rhymes, the language page: EL1–EL2) and the real job, the 58
story audios and 15 films (EL3–EL4). The tracker tool points at
`pp_milestones`, the one tracker after Development's merge.

### 50.3 Open

* For a baby, three of five tabs are locked (habits from 1, before letters
  from 2, school from 3). That is the content's own banding, seen on the
  phone; if it reads as too much grey, the habits area's `_fromOne` is the
  one worth questioning (a hand-washing habit starts before one).

---

## 51.0 First 40 Days, the eighth parenting door — 2026-09-13

Built to `First_40_Days_Prompt.pdf`. The door is
`lib/data/doors/pp_door_first40.dart`; the contract is
`test/pp_first40_door_test.dart`. Walked on a phone at day one.

### 51.1 The calls

* **Five tabs** from ten areas: Din by din · When to rush · Maa ki dekhbhaal
  · Samjho your newborn · Feeding, sleep and the rest. The mother is third
  (judgement call 2's lean); no red strip and no closing card, both on the
  brief; the go-now list is the first card of tab two.
* **Judgement call 1, the real day spine, is NOT built.** Four fixed
  day-range pages stand in, auto-scoped by band. Logged FF10 and in
  PARENTING-DOORS-REVIEW.md: it is real build effort and the user asked for
  speed first.
* **One crisis screen.** "When the crying will not stop" opens Behaviour's
  dark story by `pp_page/`; its step-list is in a comment. One latch film
  (Feeding's), one malish, swaddle and settling film (Sleep's) — the shared
  slot ids, with the film's own title, since `pp_section_test` holds one
  title per slot id. One oil comparison (the malish page links). The
  short-cycles explanation is "Newborn sleep, honestly"'s.
* **Reformats:** first bath a film; the nappy page a drawn colour strip
  (`poopColours`); skin and noises as carousels (each page its one block,
  doctor line and India note as the last slides); safe sleep as Sleep's
  drawing; soothing video-first.
* **Two tools dropped from the door** that the brief's rail names:
  `pp_baby_ok_check` (the Is My Baby OK? area's first page opens it) and
  `pp_ask_veda` (the Puchho page is that card). A Tool card beside each
  would be the same thing twice on one tab. Feeding and growth tools stay.
* **The sticky-eye slide** on the skin carousel is one line I wrote
  (REQUIRED_REVIEW); the brief asked to "add one card". Everything else new
  is a scaffold (FF1–FF5).
* The long badges the briefs use now shorten on the chip ("Flagged
  quick-reference" was truncating): Red flag, Flagged, Comparison, Day by
  day, Audio.

---

## 52.0 You, Maa, the ninth parenting door — 2026-09-13

Built to `You_Parenting_Maa_rebuild.pdf`. The door is
`lib/data/doors/pp_door_you_maa.dart`; the contract is
`test/pp_you_maa_door_test.dart`.

### 52.1 The calls

* **Five tabs** from ten areas: How are you today, Maa? (the triage and the
  mind area) · Your body (body, pelvic floor) · Moving and eating · The
  people in your house (and the circle) · Going back. Her bands are her
  own (`kPpPostpartumBands`); the section auto-scopes on them.
* **The frightening-thoughts route is pinned** above the rails on the
  landing tab, in the red-flag treatment with the eyebrow "READ THIS ONE
  FIRST" (the shell reads the page's `ROUTE` format for it). One tap from
  `pp_crisis_path`, as the brief insists. No tools, no scored tracker, and
  a test that no page here reaches the baby's checker.
* **Judgement call 1, consolidate:** You, Maa is the one home for her
  recovery. First 40 Days' bleeding, stitches and C-section pages are
  windows into `body_lochia`, `body_perineum`, `body_csection_early` (their
  copy in comments); its breasts and pregnant-again scaffolds became windows
  into `body_breasts` and `people_intimacy`; Feeding's mastitis flag links
  in. The owed ledger's FF1–FF2 close into YM3.
* **Judgement call 2, collapse:** the tile opens the door. The hub's two
  doors stay for the older home.

### 52.2 The wiring

* The eight shop links → `pp_products`; the four circle links → a new
  Community room `mothers_4th_trimester` (`community_data.dart`, English
  only) opened by a new router prefix `pp_community/<roomId>`.
* The two consult rosters the brief calls "declared not-ready" are seeded
  in `pp_experts_data.dart` already (Maternal mental health,
  Physiotherapist); the closing opens the first.
* The dead card: `_backToWork` carries `bands: _cleared`, so it locks
  "From 2 months" in the first six weeks instead of drawing an empty card.
  (Two months is the band boundary the data calls "6 weeks".)
* Two scaffolds: her own sleep (`body_your_sleep`), her thyroid
  (`body_thyroid`), in Your body.

### 52.3 Open

* The lock label reads "From 2 months" where the band is called "6 weeks
  to 3 months". A per-band lock label would fix the wording.
* The recipes are pages here and links to `pp_food`; the brief wants them
  tagged postpartum inside the shared recipe library (YM6).

### 52.4 Walked on the phone — 2026-09-14

Every tab renders; the pinned route reads "READ THIS ONE FIRST"; Going back
is locked at day one; First 40 Days' bleeding card opens You's page and
comes back. Two lines the shell wrote in the baby's voice read wrong here
("FOR YOUR BABY · THE FIRST 6 WEEKS", "This opens when your baby is 2 months
old"); `PpDoor.aboutHer` flips them to "FOR YOU" and "when you are 2 months
in". The cross-section windows are now tabled in PARENTING-DOORS-REVIEW.md
on the user's ask.


---

## 53.0 What to buy — the shop, kept a shop — 2026-09-14

Built to `What_to_buy_parenting.pdf`, which is explicit: "do not wrap it in a
section, do not add tabs, do not merge the two doors." The user agreed; the
tile stays the two-door hub (guides / catalogue). The contract is
`test/pp_what_to_buy_test.dart`. Walked on a phone 2026-09-14: the eight
Coming soon rows on the guides hub; "Compare malish oils" lands on a loaded
tray with the guidance panel reading the shelf card.

### 53.1 The three fixes

* **The empty compare tray.** `pp_compare/<shelf>` in the router seeds the
  Compare Manager with that shelf's products (up to the tray's two), so the
  seven "compare swaddles / nappy rash creams / …" links from Health and
  First 40 Days land loaded. Bare `pp_compare` keeps the empty state. Three
  of the seven have no true shelf (nasal aspirators and cough-and-cold →
  First aid; malish oils → Lotions), logged WB10.
* **The chooser's wrong guide.** `guideForProduct` no longer matches on a
  name keyword or a category word (that offered the steriliser guide to the
  anti-colic bottle and nothing to the Steam Steriliser); it matches by id
  and an explicit map, now including the parenting catalogue's own ids.
  The old fallback is in a comment.
* **The skip link.** Development's "Things worth buying, and things worth
  skipping" points at the guides (`pp_product_guide`), where skipping lives.

### 53.2 One source, a soft default, eight placeholders

* The compare screen's "what actually matters" panel reads the shelf's
  guidance card (`compareGuideForShelf`); `kCompareGuides`, the third
  hand-written copy, is read by nothing and kept for revert.
* Call 1 (soft-scope, agreed): the discovery grid sorts her stage's
  categories first when no stage filter is chosen (`ppStageForMonths`);
  nothing is hidden. Call 2 (near-empty shelves, agreed): owned as they are.
* Eight placeholder guides (`ProductGuide.comingSoon`) hold rows on the hub
  under a Coming soon chip and do not open; the guide contract test skips
  them. WB1–WB8 in the ledger.

---

## 54.0 Traditions, the last parenting door — 2026-09-14

Built to `Traditions_Parenting.pdf`. The door is
`lib/data/doors/pp_door_traditions.dart`; the contract is
`test/pp_traditions_door_test.dart`. Walked on a phone 2026-09-14: five
tabs, the placeholders, the drawn customs picture; nothing to fix.

### 54.1 The calls

* **Five tabs** from eight areas: Coming up now · Welcoming her home · The
  first years · In every faith · Small, safe and honest. Only the first
  changes with her age; nothing locks or drops on this door. No red flag,
  no closing, both on the brief.
* **Call 1, the two sensitive pages** (when the mother is kept apart; if you
  would rather not do a ceremony at all): added as scaffolds, TR4 and TR8,
  tone to be read by the user before either ships.
* **Call 2, the first festivals:** its own small area, on the last tab.

### 54.2 Single source and the picture

* The newborn-gathering safety block and the blade rule keep their short
  in-context lines word for word (the brief: "do not change any doctor
  callout or safety line") and each of the ten pages that carried them
  links to the one full block on "On the day: blades, piercing and heat",
  which itself links to Health's go-now list.
* "Keeping it small" already pointed at the cost chart; annaprashan's food
  page already pointed at Feeding and the food surface. Verified, tested.
* The newborn-customs page gained a drawn four-cell illustration
  (`newbornCustoms`: kajal on the sole, the bare cord, the frog-leg swaddle,
  the unbound head); the card text stays.
* Eight placeholders TR1–TR8; the two the brief puts "at the top" sit on
  the first tab after her stage's chart, with Find a name after the naming
  read.

### 54.3 The sanity pass across all eleven — 2026-09-14

On the user's ask, each brief's target structure was re-read against the
code. Every page, tool, reformat, merge and [NEW] scaffold a brief names is
present or logged; the deliberate deviations are all lines in
`docs/PARENTING-DOORS-REVIEW.md` (the shell over the briefs' library model;
the tools left off two doors where their page already opens them; the
Development day spine not built; the You recipes not yet tagged in the
recipe library; the two First 40 Days tools). A new gate,
`test/pp_doors_sanity_test.dart`, holds the wiring across all doors at once:
every surface resolves, every link lands, every coming-soon card is owed,
every window page carries no copy. The status table at the top of the
review file is the one place to see where each tile stands.

---

## 55.0 Coding, the first skilling door, and the skilling shell — 2026-09-14

Appended at the end because this file is shared with the pregnancy and
parenting terminals. Built to `ParentVeda_Coding_structure_v2.pdf` (11 Sep
2026) in the skilling terminal. The door is `lib/data/doors/sk_door_coding.dart`
over `lib/data/skilling/skilling_coding_*.dart`; the shell is
`lib/screens/skilling/` (see `docs/SKILLING-DOOR-BUILD.md` — the pattern doc,
the decided rules, and every point GENERIC to skill doors, which this file
does not repeat); the contract is `test/sk_coding_door_test.dart`; the
cross-door gate is `test/sk_doors_sanity_test.dart`; content owed is
`docs/DOOR-CONTENT-OWED.md` S1–S8; the review list is
`docs/SKILLING-DOORS-REVIEW.md`.

### 55.1 What changed

* **A fourth door engine**, copied from parenting's the way parenting's was
  copied from pregnancy's, importing neither: `sk_door_data.dart`,
  `sk_door_screen / carousel / chrome`, a block model + one renderer
  (`sk_content.dart`), `SkDoorContent` with named slots, a router.
* **The brief's five child surfaces are the five tabs**, in the brief's
  order, on the user's call; the four parent surfaces are one screen
  behind the grown-up gate, reached from the closing card. Consult is held,
  so no Consult card.
* **The Coding bracket's five cells are live** — the first in the stage —
  longhand, workbook text kept, extras and consult `notReady`.
  `bracket_model_test.dart`'s "no skilling layer is live" became the
  router assertion its own comment said it would.
* **The preview**: the Coding tile opens the door in a debug build (plan
  sheet otherwise and for the other eleven); the banner says so; the two
  "open questions" cards now state the answers (old wording kept for
  revert); the compass lights a point by practice.
* **36 activity slots, 12 lessons, 6 AI cards, 6 courses, 9 products, the
  parent note** — all placeholders, all coming soon, all in the ledger.
  Not one word of activity, lesson, course or product copy is authored.

### 55.2 The user's calls, in one place

1a the door is `kDebugMode`, the preview ships · 2a+ own child store,
pre-filled from the parenting child at 6 or over · 3a under six: child
tabs locked, grown-up open · 4 the brief literally · 5a+c sum in words, or
a PIN if set · 6 skilling's own product shelf · 7a enrol is a stub sheet.

### 55.3 Needs a decision (door-specific)

* **The hero photo** (bricks, no face). Swap or keep — review file.
* **The three button labels** on an activity and the six rail headings
  ("Putting steps in order"…) are mine, in the brief's words for the child.
* **Whether the parent note draws the keepsake** or stays authored-only.
* **The regrouping suggestions** (A, B, C in the review file) — after the
  walk, not before.

### 55.4 Owed

Rows S1–S8 in `docs/DOOR-CONTENT-OWED.md`. The three Coding task PDFs exist
and are the next pass; two of them name fields the shell does not have
(the 8–11 access rail; the 11–14 resume marker) — both are generic to the
doors and are listed in `SKILLING-DOOR-BUILD.md` §9, not here. Not walked
on a phone yet.

### 55.5 The three fills — 2026-09-14

All 36 activities mapped verbatim from `tasks/coding/` (Tasks 1–3 of 36)
into the scaffold's ids; ledger rows S1–S3 closed. Two things the tasks
said to STOP on, and what was done: the **access rail** is built as a
shell slot (`SkDoorContent.access`, `SkAccessScreen`, `sk_access/<door>`,
the Grown-ups card leading Things to do — S9); the **resume marker** is
flagged, not built (`SKILLING-DOOR-BUILD.md` §9). One field added to
`SkActivity` at the fill: `withGrownUp` (the AI-literacy projects' mark).
One allow-listed "score" (the quiz the child builds). Three cross-links to
unbuilt doors logged in the review file. Not walked on a phone.

### 55.6 Walked on the phone — 2026-09-14

At 8, 5 and 12, through the gate, an activity's three buttons, the sum
gate, the grown-up screen, settings, and the locked state. Six fixes in
the fill commit, listed in the review file; the one with teeth is the Ask
Veda FAB, which was reachable from every child screen and is now hidden on
`sk_`/`sk/` routes in `global_ask_fab.dart`. Nothing else in the walk
contradicted the brief.

---

## 56.0 Communication, the second skilling door — 2026-09-15

Appended at the end; this file is shared. Built to
`ParentVeda_Communication_structure.pdf` (11 Sep 2026) on the shell Coding
laid. The door is `lib/data/doors/sk_door_communication.dart` over
`lib/data/skilling/skilling_communication_*.dart`; the contract is
`test/sk_communication_door_test.dart`; owed content is
`docs/DOOR-CONTENT-OWED.md` SC1–SC10; the review list is
`docs/SKILLING-DOORS-REVIEW.md`. Generic points are in
`docs/SKILLING-DOOR-BUILD.md` §9, not here.

### 56.1 The calls — 2026-09-15

1a the recorder is the pregnancy journal's mechanism without its upload
(`sk_voice_keepsake.dart`; the journal file untouched) · 2A the five cards
are the brief's surface table — three band sets, Lessons, Your voice, saved
— with band cards locking ahead and dropping behind · 3a Confidence and
Expression stay separate; the recorder is built once in the shell · 4a the
course shelf carries the brief's three plus one "Speaking in English, too"
per level, mother tongue first, no fluency sold · 5a skilling's own product
shelf.

### 56.2 What changed

Three shell slots (`SkDoorTab.bandId`, `SkDoorContent.voiceKeepsake`,
`SkDoorContent.boundaryNote`), a voice store + record sheet + screen, the
`sk_voice/<door>` surface, one consent line for recordings, the activity
screen's record row. 36 activity slots, 27 lessons, 12 courses, 12
products, the parent note and the boundary note — all placeholders, all in
the ledger. The bracket's five cells live; the workbook's "rubric tracker"
refused into the voice keepsake, as the brief says. Not walked on a phone.

### 56.3 Needs a decision (door-specific)

* The record sheet's copy ("Keep it", "Not this one", "Listen back") is
  mine — review file.
* Whether the words list belongs under the recordings or on its own tab.
* The hero photo.

### 56.4 The two fills — 2026-09-15

Tasks 7 and 8 of 36 mapped verbatim into `cm_68_*` and `cm_811_*`; ledger
rows SC1–SC2 closed; the 11 to 14 band stays coming soon until its task is
written. The tasks named one field the model lacked — `offersRecording`,
true on the four storytelling activities — and a rule the structure brief
did not: recording is "optional, off by default, only with parent setup
and consent". So `SkChildStore.voiceAllowed` (default false) and a switch
on the grown-up screen; the record row and the Record button wait on it,
and the keepsake screen invites the grown-up meanwhile. The vocabulary
scan learned that "points land" is a point made (`cm_68_11`, allow-listed
by name). Not walked on a phone.

## 57.0 Parenting V3 home, reshaped to the Claude Design — 2026-09-16

The user's seven-point brief became a Claude Design prompt, the design
(`parenting-homescreen`, "ParentVeda V3 Home") came back, and the screen was
built to it: `lib/screens/post_pregnancy/pp_home_v3.dart`, with the state in
`pp_home_activities_store.dart`, the derivation in `pp_home_changes.dart`,
the More sheet in `pp_more_sheet.dart`, and the bar in `pp_common.dart`.
Not walked on a phone yet.

### 57.1 The calls

- **What to buy is the first tile**, reordered at the grid rather than in
  `kParentingBrackets` — the registry's order is documentary.
- **Video first** in This phase explained; the separate Watch section is
  commented out, its video moved up. Three resource cards under the text:
  What changes next (phase map), Something changed? (What Changed library),
  When to call the doctor (Baby OK check).
- **How {name} is doing shows only what is changing**: one card per domain
  with an AAP milestone this phase, from `AgePhase.milestones`. Not
  `kDevAreas`, whose words are fixed at a four-month-old. Tap → sheet: video,
  text, more.
- **Three activities a day**, Done stays, Change swaps at once, the sent-away
  one sits out fourteen days, tomorrow is fresh. `PpHomeActivitiesStore`
  writes completions THROUGH to `GrowStore` so the Brain tab agrees.
- **Read / Recommended / My journal** renamed to the brief's words; reads and
  products age-ranked with the rest filling to three and six.
- **Bar**: Home · Products · Tools · Brain activities · More, app-wide (the
  bar is one component on eight screens, so it cannot be V3-only). `PpTab`
  enum; `openPpTab(int)` kept as an adapter with the OLD positions' meaning
  so no caller was silently re-routed.
- **More** is a sheet: Community first, then the design's six, then every
  remaining Explore drawer row, from ONE list (`ppExploreEntries`).

### 57.2 Assumptions made without asking — say if wrong

1. **"Asked a lot" and "Looking ahead" stay** under My journal. Neither the
   brief nor the design mentions them; a section is not removed on
   inference. One line each to comment out.
2. **Side gutter stays 18dp**, the V3 family's, not the design's 24 — the
   pregnancy and TTC V3 homes use 18 and the three must read as one app.
3. **Settings → Family profile.** There is no parenting settings screen; the
   pregnancy `ProfileScreen` needs a `PregnancyController`.
4. **The "Current" (V1) home also gets the new bar** — same component.

### 57.3 Walked on the phone — 2026-09-16

SM G990B2, debug parent flavour. Every section renders in the design's
order; the bar reads Home · Products · Tools · Brain activities · More with
the two-line label legible and the icons level; Done dims and holds, Change
swaps in place with its chip; More opens the sheet; a change card opens
video → text → more. Four things found and fixed in the same pass:

1. The four journal chips stacked one per line, full width — a `Container`
   with `alignment:` fills whatever a `Wrap` offers. Padding alone now.
2. The category chip stretched across the change sheet — a ListView hands
   its children a tight width. `_Chip` sizes itself with `Align(widthFactor:
   1)` so it is the width of its word wherever it is placed.
3. "Most children calms when held" — the milestone is third-person singular
   and was spliced after a plural. It stands as its own sentence now.
4. A day-one baby was offered "Ball drop (6–9 mo)" while 0–3 mo cards sat
   unused: the widened pool was ranked without caring which tier a card came
   from. Exact fit ranks above the widened band, in the store and the sheet.

Also seen, not mine: the Current | V3 pill is a fixed overlay and sits over
whatever scrolls under it (the video card, the journal title). Pre-existing;
it is testing chrome that comes out before launch.

### 57.4 Owed

- The change-sheet video and read are the domain's first catalogue items,
  not the age's: the Self-care card at 0–4 weeks shows "Fever, without the
  panic" and "Starting solids". The catalogue has no self-care content for a
  newborn, so the fallback shows. Content, not code — the day per-age
  videos and reads exist, `PhaseChange.video` / `.read` are the two getters
  to point at them.
- `PpHomeActivitiesStore` is local only. If picks must follow her to a new
  phone, `CloudSyncedStore` + a table, as GrowStore does.
- The Ask Veda FAB position is unchanged; the design shows it above the bar
  on the right, which is where `global_ask_fab.dart` already puts it.


## 58.0 Pregnancy V3 home, reshaped to the Claude Design — 2026-09-16

The "Pregnancy Home V3" design (project `cbb69aa9-88ab-4250-b1ea-c80f78b9a356`,
option 1a with 1d for the shelf and 1c for playback) applied to
`lib/screens/home_v3_screen.dart`. New files: `lib/screens/v2/v3_week_film.dart`
(the inline film, the shelf row, the PvVideo→WatchVideo adapter and
`PregnancyFilmRepository`), `lib/screens/v2/v3_film_screen.dart` (where a
shelf row opens), `V3GarbhBlock` in `v3_garbh.dart`. Not walked on a phone.

### 58.1 The calls

- **The page is three inset columns with two full-bleed things between**:
  the film and the Garbh band. It was one padded column after the hero.
- **This Week Explained** is the week's `v2VideoFor(week)` film, directly
  under the doors, 16:9 edge to edge, **playing in place** — the poster
  becomes the player where it stood. The old "Recommended Watch" card that
  showed the same film below the journal is commented out.
- **The engine is the parenting `PvVideoPlayer`**, which gained two additive
  flags: `inline` (no back arrow, no fullscreen button — a `ListView` cannot
  host fullscreen and a tab root cannot pop) and `autoStart` (the home has
  already drawn the play control, so the player must not ask twice). Its
  `LocalWatchRepository` is NOT reused: it resolves ids against the parenting
  catalogue with `orElse: first`, so a pregnancy id would have silently played
  the first parenting lesson. `PregnancyFilmRepository` resolves from the
  video it is handed. Progress lands in `WatchStore` keyed by catalogue id.
- **No play control that plays nothing.** The pregnancy catalogue has no
  files. Without a URL the poster says "WEEK N FILM · ARRIVING", has no play
  button, and the tap goes where the old card went (`todays_video`). On a dev
  build the five recommended ids are mapped to the sample in
  `pv_video_config.dart` so the control is real there.
- **Garbh Sanskar** is a 172dp full-bleed band with the practice card
  overlapping it by 22. Rows are name + today's line + a done-mark; the photo
  tiles and tags are not drawn (still on the model, still in the old
  section). **The done-mark is a control**: tap ticks or unticks via
  `GarbhStore.markDone/undoDone`; the row still opens the pillar.
- **My journal**: only the title changed, per option 1g. The two quick
  actions stay.
- **Watch These Videos This Week**: three rows from `v3ShelfVideosFor` —
  same-week videos, the film excluded, recommended → expert → skill → birth →
  newborn, no nearest-week fallback. A row opens `V3FilmScreen`, the
  pregnancy stage's first video page (fullscreen hosted the WatchPlayerScreen
  way).
- **Use these tools** title is now 'Count, track, time'; the tiles still
  switch on usage history, the title no longer says which rule picked them.
- **Hero** 392 → 340. The design draws 300; the ask was "a bit".

### 58.2 Assumptions made without asking — say if wrong

1. **Medicine reminder card left as it was.** Content matches the design
   (label, rows, Manage list / Remind me); the design puts the tick on the
   left with no capsule well, and the shipped card puts it on the right for a
   reason recorded in `v3_daily.dart`. Not re-litigated.
2. **Invite block stays** at the foot. Not in the design; a section is not
   removed on inference.
3. **The film stops when scrolled two screens away** — the ListView disposes
   it, position is saved, the next tap resumes. Not kept alive on purpose.
4. **The Classic | V3 pill** still overlays the hero; testing chrome.

### 58.3 Walked on the phone — 2026-09-16

SM G990B2, debug parent flavour. The hero reads at 340; This Week Explained
sits under the doors and plays in place (0:17 dev sample) with no back arrow
and no fullscreen control; the Garbh band and card overlap as drawn and the
done-mark ticks and unticks in the pillar's accent; the journal title is the
new line over the untouched card; the shelf renders as option 1d; products,
"Count, track, time" and the invite block close the page. Two things found
and fixed in the same pass:

1. **The film page showed a play button that played nothing.** For an
   unmapped film the parenting engine's own poster mounted, and that poster
   draws a play circle whether or not a source exists. `V3FilmPoster` is now
   shared by the home block and the page; without a file it says "FILM ·
   ARRIVING" and has no control.
2. **The film page was empty** — a player, a title, one line. The user saw
   it: "its not good if user gets to see empty screens." Filled with things
   that exist and are about the film: a "Try it now" door to the tool the
   film teaches (`_toolFor`, only where the subject IS the tool — kegel,
   movement, scans, hospital bag, contractions), three reads found by the
   film's own title words through `readSearch` and filled from the week's
   recommendations, and the other films for the week. No chapters or
   takeaways — those are content for films not yet shot.
3. **The invite button was a solid violet slab** — "looks old ui, very
   purple". Every other secondary action on the page is the quiet outlined
   pill; it is that pill now, reading "Send an invite" ("Click here" is web
   copy). The old button is commented in `v3_daily.dart`.

### 58.4 Two more from the walk — the bar, and the day that never moved

- **The bar now matches parenting's.** One component (`PvNavBar`) on both
  stages, but this stage handed it filled `_rounded` glyphs where parenting
  hands `_outlined` ones — so the same pill looked heavier here. Now
  `home_outlined · school_outlined · handyman_outlined ·
  calendar_today_outlined · groups_outlined`, the accent is `primary500`
  (parenting's `ppPurple`) rather than the bar's default `primary600`, and
  the inset is parenting's 16 · 16 · 18 (was 14 · 14 · 14;
  `_kNavBarBottomInset` follows). Names and positions unchanged. The father
  (Slate) tab set was not touched.
- **The no-date placeholder advances.** It was "16 weeks from today",
  recomputed on every launch, so with no due date the app sat at week 20
  day 140 with the same photograph every morning. TTC's cycle day moves
  because it is derived from a SAVED start and today's date; the pregnancy
  placeholder is now anchored the same way — `pregnancy_placeholder_anchor`,
  written once on the first date-less open, never shown, cleared by
  `resetForTesting`. Verified on the phone by backdating the anchor three
  days: Week 21, day 3, the week-21 photograph, its own learning line.
  Caveat: `_now` is fixed at construction, so a session left open across
  midnight ticks on the next launch, not at 00:00. Not a new limitation —
  a real due date behaved the same way.
  ⚠️ Debug-tooling trap found on the way: editing
  `FlutterSharedPreferences.xml` under `run-as` after a `force-stop` can be
  silently undone by Android's `.bak` recovery if the stop landed mid-write.
  Stop, wait, check for the `.bak`, then edit.

### 58.5 Owed

- **The "arriving" state with `kUseDevVideos` off** was not walked; the
  five `rec_*` ids are mapped on the dev build, so the home film always
  played. The shelf's unmapped films exercised the state on the page.
- **"Try it now · Kegel"** uses the surface's own label from `kAppSurfaces`,
  which is terse. If a friendlier line is wanted it belongs on the surface,
  so the Tools tab says the same thing.
- **Move the video engine out of `post_pregnancy/video/`** to `lib/widgets/`
  now that two stages import it. Pure move; nothing changes.
- **Real stills for the film and the shelf** — the tinted grounds are
  honest placeholders. Content, not code.
- **A "Saved" tile** in Use these tools (the design's fourth) — `saved` is
  not in `_ToolsRow._face` today.

### 56.5 Walked on the phone — 2026-09-16

At 12 and at 8, and the recorder end to end (the first real microphone
use in the stage). Four fixes in the walk commit, listed in the review
file; the one with a general lesson is the store that appended on load —
a lazy `load()` into a store that may already hold rows is a merge, and a
merge needs an identity; both keepsake stores now merge by id. The child
type sizes moved to one set of constants at a middle setting on the
user's reaction. The device is released.

### 56.6 The third band, written here — 2026-09-17

No Task 9 PDF existed; the user asked for it to be written. Claude Code
wrote it, and on the user's call it sits with the other task PDFs
(`tasks/communication/`, `.pdf` and the editable `.md`), first page
saying who wrote it and when, in the other tasks' shape and under their
rules; the twelve activities are generated from it verbatim into the
Dart — the first activity copy authored by Claude Code rather than
received. The ledger row (SC3) says the copy is owed a review by the task
author. Three calls
worth their look are in the review file: two writing-shaped activities,
a friend counting fillers out loud (the app counts nothing), and
observed-versus-assumed as describing rather than thinking. The
Communication door's thirty-six are now all real. Not walked after.

---

## 100.0 Confidence, the third skilling door — 2026-09-16

(Numbered 57, then 62, when written — the parenting terminal took both the
same day, once while this was being renumbered. Two writers cannot share a
sequence, so from here the SKILLING sections take 100 and up; the other
terminals' numbering runs below. Nothing else in this file refers to it.)

Appended at the end; this file is shared. Built to
`ParentVeda_Confidence_structure.pdf` (11 Sep 2026), "the one that actually
sells", on the shell as it stood after Communication. The door is
`lib/data/doors/sk_door_confidence.dart` over
`lib/data/skilling/skilling_confidence_*.dart`; the contract is
`test/sk_confidence_door_test.dart`; owed content is
`docs/DOOR-CONTENT-OWED.md` SF1–SF11; the review list is
`docs/SKILLING-DOORS-REVIEW.md`. Generic points: `SKILLING-DOOR-BUILD.md` §9.

### 100.1 The calls — 2026-09-16

1a the paid door as placeholders behind the gate (course shelf + a coach
row), the booking engine named as the pass after a real coach exists · 2a
the coach on the grown-up screen under the classes, one closing card ·
3b six cards, the brief's six child surfaces, the recorder and the
keepsake as two cards onto one screen's two halves · 4a "notice one thing
you did" as a prompt after listen-back, stored nowhere.

### 100.2 What changed

Four shell slots (`coach`, `voiceSelfReview`, `voiceTitle`, the `SkBreath`
block rendering the app's one breathing circle), the `sk_record/<door>`
surface. 36 activity slots, 18 lesson slots, 6 courses, 9 products, the
parent note, the boundary note, the coach — placeholders, all in the
ledger — and one built page, the steady-your-nerves breath. The bracket's
six cells live: the first live Consult in the stage, the rubric tracker
refused into Hear yourself back. The recorder's plugin calls are guarded
and its permission wait bounded, which is what let a widget test hold the
sheet. Not walked on a phone.

### 100.3 Needs a decision (door-specific)

* Six cards on the selector — seen on a phone, or not.
* The self-review prompt's words, the coach row's words, the two lines
  under the breath — all mine.
* Whether "With a coach" oversells a placeholder course title.

### 100.4 Walked on the phone — 2026-09-17

At 8, the whole door. Two fixes, both content: the hero photograph (a
chalkboard in it read a cancer lesson — a hero is read at full size and
every word in it is the door's) and the voice screen's copy, which was
Communication's and is now a per-door slot (`voiceBlurb`,
`voiceEmptyLine`). The recorder, the self-review prompt, the breath page
and the coach row all behaved. Not rebuilt on the phone after the fixes —
the other terminal held the build — so the swap is seen at the next walk.

### 100.5 The three bands filled — 2026-09-17

Tasks 4, 5 and 6 of 36, verbatim, thirty-six activities; every field
diffed against the PDF text by script. One field added, `breathPageId`,
because three activities say "open the breathing circle" and the model
had no way to say which page — a page id, not a bool, so the circle keeps
one home. Seven `offersRecording`, the tasks' seven. Two named things do
not exist and were listed, not built: the Thinking door's "question ideas,
not elders" line, and "the door's help line" for a child whose distress
runs deeper than a rough talk (the door has only the parent-facing
boundary note; whether any skilling door should carry a child-facing help
line is a generic call). The tasks name the pregnancy recorder as the one
to reuse; skilling's own, built on the 2026-09-15 call, is what the rows
open. Walked after the fill the same day: the breath row, the record
row, the end line, all as built; the preview's "Coding opens its door"
note now counts its doors instead of naming one.

## 58.0 TTC V3 home, the lower half in the parenting grammar — 2026-09-16

Built directly, no Claude Design round — the widgets it would have drawn
already existed in `pp_home_v3.dart`, and drawing them again could only
drift. Everything above and including the seven doors is untouched.
`lib/screens/ttc/ttc_home_v3.dart`, `ttc_strings.dart`. Walked on the phone
the same day.

### 58.1 The calls, all the user's

- **"Sanskar", not "Samskar"** — the section shipped with the Sanskrit
  transliteration and it was a misspelling for this app. Still
  "Garbhadhana Sanskar", never "Garbh Sanskar" (that is the pregnancy
  practice); the distinction lives in the first word.
- **"Improve your chances" is gone.** The old comment defended it as a
  general framing; asked again, the answer was no — on a fertility home a
  sentence that sets a target is a target.
- **No counter, no streak.** The 0/5 and "3 days" the ritual card carried
  are gone, on the grounds the parenting brief and the Grow feature gave.
  Completing from the home — the parity invariant — is held by a Done pill
  per part; `test/ttc_home_v3_parity_test.dart` now asserts five pills and
  that one becomes "Done today" without navigating, and that no fraction
  is drawn.

### 58.2 What changed

Sanskar: `_Head` + body line, then five `_SanskarCard`s (tinted mark, the
part's name, TODAY'S prompt, the why, Done) and a footer line. Products:
parenting's card shape, opens the product page (`openTtcProductPage`) not
the shop front; a category chip where parenting has a why-line, because the
"never a benefit under a supplement" rule stands. Reads: renamed, rail in
parenting's shape (cover band, "READ · N MIN", title, standfirst). Journal:
parenting's invite card with a pen square and this stage's four doors.
People: four role cards (gynaecologist, fertility specialist, nutritionist,
psychologist), each opening ITS consultation, then "See everyone". Roles
not names — `TtcOffering.expertId` resolves to no record yet.

### 58.2a Then the design arrived, and the band — 2026-09-16, later

The user ran the Claude Design after all (`TTC V3 Home`, project
49005443). It agreed with the build on every section and differed on
details, which are now the design's: the Sanskar parts are ROWS with the
Done pill on the right, the chapter card carries Me · Us · What's next as
pills on itself, the reads and products cards keep their wells inside the
padding, the journal card is a 64dp pen well beside the prompt with the
chips across the card, the experts wear a person mark, "See everyone" is a
surface card, the test door is a hairline row.

Two more calls from the walk that followed:

- **A photograph behind the Sanskar, "like pregnancy V3".** `_SanskarBlock`
  mirrors `V3GarbhBlock`: a 196dp full-bleed band (the Mind & body door's
  own photo, not a new id picked blind), the dark scrim, the gold eyebrow,
  the title in white, the (i) to the ritual screen, and the first row
  lifting 22dp onto the band. The explainer text was first a card lifting
  onto the band; "i dont need a separate card just for so much text, looks
  bland" — so the text is one line on the photograph and the first ROW
  lifts instead. The done-dim moved from the card to its contents, because
  a translucent card on a photograph let the band through.
- **"Cut it short."** The five-line Ayurveda paragraph is one sentence
  plus the name's gloss. Paragraph kept in ttc_strings.dart for revert.
- **The bottom bar's icons are line icons now**, the same glyphs pregnancy
  and parenting use for the same tabs. TTC was the one bar of three still
  drawing filled `home_rounded` / `school_rounded` / `widgets_rounded`;
  sharing `PvNavBar` never covered the icons, which each stage supplies.

### 58.3 Found on the walk, fixed

- The hero field showed through under the disclaimer: the `ListView` still
  reserved `ttcBottomInset` OUTSIDE the sheet while the sheet reserved 150
  inside — the "padding is a window onto the field" bug parenting's sheet
  note describes. Pre-existing. The sheet reserves `max(ttcBottomInset,
  150)` now and the scroll view reserves nothing.
- The product card had a dead band between chip and price at parenting's
  226dp (no why-line here). 214.
- Both stages' chips shrink with an ellipsis instead of overflowing —
  "SUPPLEMENTS" was 2.6px over under the test font.

### 58.4 Owed

- Expert names on the four cards, the day `expertId` resolves to a person.
- The chapter card and its Me · Us · What's next tabs kept their existing
  shape; the design prompt had the tabs ON the card. Cosmetic, and the two
  widgets are reachable and tested as they are.

---

## 101.0 Thinking, the fourth skilling door — 2026-09-17

Built to `ParentVeda_Thinking_structure.pdf` ("the stage's default shape,
so the work here is editorial, not structural") on the shell as it stood
after Confidence. The door is `lib/data/doors/sk_door_thinking.dart` over
`lib/data/skilling/skilling_thinking_*.dart`; the contract is
`test/sk_thinking_door_test.dart`; owed content is
`docs/DOOR-CONTENT-OWED.md` ST1–ST11; the review list is
`docs/SKILLING-DOORS-REVIEW.md`. Generic points: `SKILLING-DOOR-BUILD.md` §9.

### 101.1 The calls — 2026-09-17

1a the careful framing: sharp checking of claims, forwards and arguments;
"question the idea, respect the person" kept apart; never framed as
arguing with parents or teachers · 2a spotting-fake as a headline strand
of this door, its own lesson set, built once with Coding (this door the
reasoning, Coding the mechanism) · 3a the extras reshape as a "Just for
fun" lesson set (a riddle, a friendly debate per band), with the
workbook's certificate becoming the keepsake's name on this door.

### 101.2 What changed

One shell slot, `SkDoorContent.keepsakeTitle` (the shared keepsake under
the door's name, "You kept thinking" — one store, one screen). Six moves
from the brief's table, 36 activity slots, four lesson sets (33 slots),
four courses, nine products, the parent note under the brief's own title
— placeholders, all in the ledger. The bracket's six cells live; the
rubric tracker refused into the keepsake; the progress report dropped;
Consult held. Nothing AI-literacy authored here: Coding's AI pages are
coming soon, so the strand leaves the cross-link slot the brief's prompt
asks for and lists it. Not walked on a phone.

### 101.3 Needs a decision (door-specific)

* The strand's child-facing name, "Is this true?", versus the brief's
  "spotting fake".
* Whether the linking page between Thinking's strand and Coding's AI set
  is authored on this door or on Coding's when both fills exist — one
  page, one owner.
* The hero photo.

---

## 102.0 Stillness, the fifth skilling door — 2026-09-17

Built to `ParentVeda_Stillness_structure.pdf` ("the door with the most
already built behind it, and a streak it should refuse for its own
reason") on the shell as it stood after Thinking. The door is
`lib/data/doors/sk_door_stillness.dart` over
`lib/data/skilling/skilling_stillness_*.dart`; the contract is
`test/sk_stillness_door_test.dart`; owed content is
`docs/DOOR-CONTENT-OWED.md` SL1–SL12; the review list is
`docs/SKILLING-DOORS-REVIEW.md`. Generic points: `SKILLING-DOOR-BUILD.md` §9.

### 102.1 The calls — 2026-09-17

1a **the streak refused, on the record with its reason**: "a streak turns
a non-striving practice into a target, and a broken streak makes a child
feel she has failed at calming down" — the most defensible streak in the
stage, refused because it defeats the practice, not only because of the
rule · 2a engines reused (the breathing circle, the app's one audio
player, the garbh theme), sessions kid-authored where the pregnancy
content does not transfer, adapted where it does (yoga → gentle moving,
the Kriya body-scan → resting), each card marked which · 3a the
invitation to return is one line on the keepsake, no number in it, never
a notification · 4a the settle breath built as the one page, the source
Focus, Feelings and Memory will reference.

### 102.2 What changed

One shell slot, `SkDoorContent.keepsakeInvite`. Six practices from the
brief's table, 36 practice slots, three session sets (24 slots) marked
Kid-native or Adapted, three recorded series, nine products, the parent
note under the brief's own title, one built page (`sl_settle`, the one
circle, the brief's words). The bracket's six cells live; the streak
tracker refused into the keepsake; extras dropped outright and what is
left, the unmeasured record, is the keepsake; Consult held. The engines
named by the brief were all found; none rebuilt; the audio player is
wired the day a session exists. Not walked on a phone.

### 102.3 Needs a decision (door-specific)

* Whether Confidence's `cf_breath` becomes a window onto `sl_settle` (one
  page, one owner) or keeps its own words on the same circle.
* The keepsake's third word, "I made something", on a breathing practice.
* The hero photo: play in a misty grove, not a child sitting still.

---

## 103.0 Feelings, the sixth skilling door — 2026-09-18

Built to `ParentVeda_Feelings_structure.pdf` ("the mental-health door,
and the one that carries the most weight of all twelve") on the shell as
it stood after Stillness. The door is `lib/data/doors/sk_door_feelings.
dart` over `lib/data/skilling/skilling_feelings_*.dart`, with three new
shell files — `sk_safety.dart`, `sk_journal.dart`, `sk_crisis_pathway.
dart`; the contract is `test/sk_feelings_door_test.dart`; owed content is
`docs/DOOR-CONTENT-OWED.md` FE1–FE14; the review list is
`docs/SKILLING-DOORS-REVIEW.md`. Generic points: `SKILLING-DOOR-BUILD.md` §9.

### 103.1 The calls — 2026-09-18

1a **the journal child-private by default** — the parent owns the
account, consent and deletion and does not read entries; help is one tap
away inside the journal; **flagged for legal review** against DPDP's
parental-consent rules, the brief's own "one of the two heaviest calls in
the whole build" · 2a the off-ramp shows **real numbers, flagged verify**
(Childline 1098, Tele-MANAS 14416) with tap-to-call; a release build
hides anything still flagged · 3a **AES-256-GCM at rest** via
`pointycastle`, made a direct dependency (it was already in the lock via
Supabase; no version changed) · 4a the off-ramp as **a bar at the foot of
every child screen** of the door, ungated on purpose — the one ungated
link off a child screen in the stage, on the record.

### 103.2 What changed

Two shell slots (`journal`, `safety`) and three shell files. The off-ramp
bar and sheet (records nothing, anywhere). The private journal: an index
with ids and dates and no text; each page sealed in its own file with a
fresh nonce; one reader, her own page; the parent can delete it and
cannot read it; withdrawing consent forgets it with the key. The crisis
pathway as a stub that does nothing and STOPS. Six SEL skills from the
brief's table, 36 activity slots, two lesson sets marked "Needs review"
on every card, one window onto Stillness's settle breath (the stage's
first cross-door window), three recorded series, nine products, the
parent note under the brief's own title. The bracket: five cells live,
Consult held, and extras `notApplicable` — the stage's first refused
cell, with the brief's reason ("an emotional progress report on a child
is unthinkable, and it is a score"), named as the one exception in
`bracket_model_test`. Not walked on a phone.

### 103.3 Needs a decision, and three reviews before anything ships

* **Legal:** the child-private journal against DPDP parental consent.
* **Clinical:** every scenario, prompt and the parent note — nothing is
  authored until a child psychologist has reviewed a task; and the
  helpline wording.
* **Legal and clinical:** the helpline numbers themselves (verify).
* **Key custody:** the journal's key must move from `shared_preferences`
  to the platform keystore — a dependency call (`flutter_secure_storage`
  or equal).
* **The crisis pathway** is designed by a child psychologist and a lawyer,
  not here. What they decide is listed in `sk_crisis_pathway.dart`.
* Whether the off-ramp bar should also sit on Confidence (its task 6
  names "the door's help line") or on every door.
* The keepsake's third word on a feelings activity; the hero photo.

---

## 104.0 Making (Creativity & expression), the seventh skilling door — 2026-09-18

Built to `ParentVeda_Creativity_structure.pdf` ("the one door whose plan
already refuses scoring") on the shell as it stood after Feelings. The
door is `lib/data/doors/sk_door_making.dart` over
`lib/data/skilling/skilling_making_*.dart`, with one new shell file,
`sk_portfolio.dart`; the contract is `test/sk_making_door_test.dart`; owed
content is `docs/DOOR-CONTENT-OWED.md` MK1–MK10; the review list is
`docs/SKILLING-DOORS-REVIEW.md`. Generic points: `SKILLING-DOOR-BUILD.md` §9.

### 104.1 The calls — 2026-09-18

1a the showcase **private by default**: no cross-user gallery, no likes,
no ratings, no featured wall · 2a **the least commercial door, kept so**:
a light class shelf (an art and a music class per level), Consult held —
the opposite of Confidence, on purpose, "the door that proves the app
means what it says" · 3a the showcase as **a show mode on this phone**,
because the journal's "invite someone to see" is a link whose other half
does not exist in this repo · 4a **photo capture built now**, on-device,
the voice posture: behind the parent's switch, off by default, copied
into documents, parent-deletable, never analysed or judged.

### 104.2 What changed

Two shell slots (`photosAllowed` on the child record, `portfolio` on the
door content) and one shell file. The portfolio screen composes the
three keepsakes — photos (new), recordings (the voice keepsake), words
(the shared keepsake) — and carries the show mode. Six moves from the
brief's table, 36 activity slots, three prompt sets (27 slots: art,
music, making — all three, because "creativity for kids quietly means
colouring"), six small classes, twelve products whose every blurb names
the free path, the parent note under the brief's own title. The
bracket: six cells live, the portfolio tracker surviving as a portfolio,
the showcase kept and held private, Consult held. Not walked on a phone.

### 104.3 Needs a decision (door-specific)

* The who-for names in the show mode (`kSkShowingTo`) — mine; the
  invite's six exactly, or these.
* Whether the 6 to 8 fill should window into parenting Early Learning's
  art and messy play, or only name it.
* The hero photo.

---

## 105.0 The skilling stage comes out from behind kDebugMode — 2026-09-22

The user's call, in his words: "can u make sure skilling isnt debug only so
that it's visible to ppl i share the apk with … the whole side of the app I
mean when I say skilling."

### 105.1 What was actually gating it

One line: `if (!kDebugMode) return false;` at the top of `skOpenDoor`
(`lib/screens/skilling/sk_surface_router.dart`). Every way INTO the stage
already shipped — onboarding's "Skilling — 6 and up", the splash route,
the pregnancy home's door shelf, the parenting Explore drawer — and
`test/skilling_doorway_test.dart` has guarded that since the stage was
built. What did not ship was the last hop: a tile fell through to its plan
sheet instead of opening the door. So the preview screen was visible to
everyone and the seven built doors were visible to nobody but a debug
build.

That gate was the original call (2026-09-14, question 1: "the preview
ships, the door does not") and every one of the twelve door briefs repeats
"do not move the stage out from behind kDebugMode". **That instruction is
now overridden, deliberately, by the person whose product it is.** It is
recorded here rather than quietly dropped, because a brief-level rule
being reversed is exactly the kind of thing the next agent will otherwise
re-impose.

### 105.2 The one thing that had to change with it

The Feelings door's safety off-ramp hid any helpline still flagged
`verify` when the build was release — "a wrong number is worse than none",
written when only a developer could reach the door. The moment the stage
ships, that rule inverts the door's purpose: a child taps "Talk to
someone" and gets a sheet with no number on it. A dead end on the off-ramp
is the worse failure, so `SkHelpline.verify` is now a LEDGER flag (FE11)
and not a display filter; every line shows in every build, and a test
holds that no build mode decides what a child can see.

**Still owed, and not optional before a public launch:** a lawyer and a
clinician confirm Childline 1098, Tele-MANAS 14416 and the sheet's
wording. A helpline that has moved is the one defect in this stage that
could cost a child the call she needed.

### 105.3 What a stranger with the APK now sees, all of it owed somewhere

* Seven doors of twelve open; five keep their plan sheet.
* Of the seven, three (Coding, Communication, Confidence) have real
  activity copy; the rest are "Coming soon" cards by design, and the
  Feelings content is deliberately unwritten pending clinical review.
* Four of the seven (Thinking, Stillness, Feelings, Making) have never
  been walked on a device.
* The Feelings journal's AES key sits beside the data
  (`SkJournalKeyStore`, ledger FE10) — acceptable for a preview build,
  not for a launch.
* The journal's child-private default still wants legal review against
  DPDP (§103.3).

None of these are new; what is new is who can see them.

---

## 59.0 Onboarding is decided against the Mobbin audit; three things it leaves open — OPENED 2026-09-16

`docs/ONBOARDING-AUDIT.md` holds the audit, the seven-screen decision and the
Claude Design brief. Nothing is built yet; the brief goes to Claude Design
first. What the decision leaves behind:

### 59.1 The phone ask on day 3 — parked until the app is done

The number is collected on screen 7, after the reveal, as a tap (Phone Number
Hint) and an auto-filled OTP. The user's own instinct, and the audit's, is that
the ask would land better on day 3 inside the app, at the first moment there is
something concrete to send on WhatsApp. **Decided: onboarding now; day-3 as an
A/B later.** Needs an in-app ask surface and a flag for which arm she saw.

### 59.2 Skilling has no home — `SkillingPreviewScreen` stands in

The Stage tile now writes `LifeStage.skilling` and the splash routes it to the
preview screen. That screen was built as a design preview and says so in its
class doc; it is now a destination and needs to be read as one — an entry to
every skilling door, and the parent gate. A real skilling home is owed.

### 59.3 §22.4 — the partner's name — CLOSED by the flow

Hers from Google on the Hello screen; his from his own Google on his own
device; the invite may carry a nickname that never leaves the phone. No new
question, no name held that its owner did not give.

### 59.4 The old `AuthFlowScreen` — kept, commented at the splash call site

Email + password, Apple, Facebook, the forgot/otp/reset chain and the "Soft
solid" design all stay in the file for revert. No user has an email account
yet, which is why the cut costs nothing now and would cost something later.

---

## 60.0 Reading converges on one reader; the card format is found and parked — OPENED 2026-09-16

The §38.5 discussion happened, against Mobbin (`docs/READER-AUDIT.md`). The
user's benchmark is the TTC reader — *"How conception actually works"* in the
Fertile window door, `PvReaderScreen` — and the decision keeps it and adds
five things (Reviewed-by row, collapsed References, "Was this helpful?" pills,
related rows, Read next as a two-card rail). Nothing is built yet; the brief
in §6 of that doc goes to Claude Design first.

### 60.1 Four models become one — adapters, not rewrites

`ReadItem`, `ReadArticle` and `Article` converge on `PvRead` through
`fromX()` adapters so no seed data is rewritten. The three old readers stay,
commented at their call sites. Books (`ReadItem.type == book`) do NOT
converge — they route to the Book Companion; a book is a product, not an
article.

### 60.2 The chip — one word, "Article" — APPLIED 2026-09-17

`PvDoorFormat.read` keeps its enum value (persisted in door data) and takes
the label `'Article'`; `SolutionType.read`'s chip says ARTICLE too. The
look-up/read-through distinction lives inside the piece (glossary or FAQ
section first, TOC visible), which is where every app in the set puts it.
Closes the 2026-09-11 question.

### 60.6 The format is confirmed; the reader gained its picture frame and one tile family — 2026-09-17

The user, on the phone: *"I like this format… this article format has to be
applied for all the articles in each and every door."* Two changes he asked
for on the article first, both done: **Read next** is the same tile as *What
you can do with this* (type well, chip, teaser, the read's photo when it has
one — `resolveRead` seam on the reader); and **every article has a picture
frame on top** — `PvRead.imageUrl`, drawn by the reader when the caller
passes no `hero`, and a type-tinted band with the mark while no picture has
been chosen (he allowed "blank with just a space"). The first adapter landed
with it: the TTC **daily insight** opens in the reader
(`lib/ttc/ttc_insight_read.dart`; `TtcInsightScreen` commented at five call
sites, kept). Short pieces carry a shared, non-urgent when-to-ask line and a
byline with no verified mark (`PvRead.reviewed = false`).

**The rollout — DONE 2026-09-17, same day.** Parenting door pages (every
page of every section; blocks the reader does not model ride as
`PvReadSection.custom` and `PpBlockView` draws them inside the frame); the
six pregnancy detail screens the doors open (conditions, scans, report
findings, nutrients, mind and mood, belly and skin); the three older models
(`ReadItem` except books, `ReadArticle`, `Article`). Each old screen's
`build` hands its model to the reader through `read_adapters.dart` and keeps
its previous body as `buildClassic`; every caller — door, home, Saved,
search — gets the one format untouched. Features the old screens carried
travelled with them: the condition film, add-to-journey behind the
diagnosed door, the gynaecologist offer with its role filter; the scan's
appointment / line-by-line / decoder / consult / Ask Veda tiles; the
finding's Ask Veda; the weekly read's mark-done (ticks the home's box); the
library's mid-piece film, related films and mark-as-read. Walked on the
phone: a condition, a parenting chart page, the daily insight, the
conception article. `test/reader_unification_test.dart` is the guard.

**2026-09-18 — the chip names the thing, so the thing comes first.** A
parenting page chipped Chart opened on a title, byline and serif lede with
the chart below the fold — "it just looks like text." `pp_page_read.dart`
now hoists the blocks a format names (chart, table, cards, illustration,
animation, audio, steps, script) to the head of the body and lifts no lede;
the reader draws no empty lede rule. Guarded in
`reader_unification_test.dart`. Walked: Sleep → "Her sleep right now".

**2026-09-18 — the pregnancy side, done to the bar.** (1) *Declutter:* the
"Mark as read" / "Mark as done" buttons are gone from every article —
completion is derived from reading to the end (`PvReaderScreen.onReadToEnd`,
still ticks the home's daily-reads box); a parenting consult block is a foot
tile, never a purple button mid-piece; an empty lede draws no rule. (2) *The
twenty thin weekly reads are written out* — `pregnancy_reads_weekly_a..d.dart`,
each at the library's bar (four sections, three headings, FAQ, 600+ words,
named sources, urgent when-to-see-someone); `ReadItemScreen` opens the full
piece by id; `pregnancy_reads_shape_test` holds them. (3) *Pictures:*
`lib/data/reads/read_images.dart` — one free-licence photograph per pregnancy
read (32 of 34), chosen for subject through the Openverse API (rawpixel CC0,
Flickr CC BY), credit printed under the frame; the home's read rail shows the
same picture as the page. (4) Doors back in registry order — Sleep first.

**Still owed from it:** pictures for `preg_scan_read_calm`,
`preg_week_read_res_music` (no honest match found; they draw the band), for
the TTC and parenting reads, and for the parenting door pages (~400 —
a content pass with a picker, not a script);
`MmArticleScreen`'s paid footer for the "more than mood" group (the
counselling booking sheet) is not yet a tile — it opens through `onTalk`
where a screen passes one; the classic Warm Nest home's three readers
(`GrowReaderScreen`, `FatherLearnReaderScreen`, `StoryReaderScreen`) are
classic-only and untouched; the video placeholder gradients were softened
(`pv_placeholders.dart`) so a coming-soon film is a well, not a violet slab.

### 60.3 The card format — owed to the home, not the reader

Flo's Daily insights, Blinkist Shorts, Deepstash: one idea per card,
segmented progress, the last card is a verb. Spec in READER-AUDIT §2.3. It
belongs to the V3 homes' daily rail. Not built; raise when the homes settle.

### 60.5 The five additions are BUILT on `PvReaderScreen` — 2026-09-16

Shown first on the user's benchmark, *How conception actually works* (TTC V3 →
Fertile window door → the read; `lib/ttc/reads/ttc_reads_conceiving.dart`,
id `ttc_read_how_conception_works`). Because the screen is shared, every
`PvRead` in TTC and pregnancy carries them; the user reviews the one article
and the format is then confirmed for everything V3 opens.

1. *Reviewed by* row with the verified mark on the person (moved up from the
   evidence block, with the rationale that travelled with it).
2. *References* as a collapsed disclosure, last in the body.
3. *Was this helpful?* — two outlined pills; the answer lives in
   `PvReadStore.helpfulOf` locally (`pv_read_helpful`). **Owed:** a server
   column the recommendations engine reads; not until something consumes it.
4. Related rows — already there as the *What you can do with this* tile grid
   (`nextSteps`); kept as tiles, the V3 signature, rather than churned to rows.
5. *Read next* as a two-card rail; the benchmark article gained a second id
   so the rail shows two.
The old evidence block and stacked rows are kept in the file for revert.
Adapters for the other three models and the chip word: not started — waiting
on the user's look.

### 60.4 Father reads converge last

Father mode has its own chrome; the reader must render inside the Slate look
before `father_reads_screen.dart` goes behind a comment.

---

## 61.0 The family model is written down; two things it makes owed — OPENED 2026-09-16

`docs/FAMILY-MODEL.md` states the rule the schema already followed and nobody
had said: the person is the root of identity and of bookmarks; the child is
the root of what is logged about the child; stage is a tag, never an owner.
`saved_items` (0081) is the first table built against it — one bookmark
table for the whole app, ten old saved-sets behind facades, one Saved screen
reached from every home. Built and tested; **not deployed** — `supabase db
push` is the user's.

### 61.1 A `pregnancies` table — the second baby's real requirement

Today a pregnancy is `profiles.due_date` + `life_stage`, one at a time. The
second pregnancy overwrites the first. Apple Health's "log a past pregnancy"
is the shape: a row per pregnancy (start, dating method, due date, outcome,
`child_id` once born). `DueDateSource` already exists to fill the method
column. Also where a loss is recorded, so the app can stop pushing pregnancy
content afterwards (personalisation reads `outcome`). Not built.

### 61.2 One product catalogue across stages — BUILT 2026-09-17

The user's own words: three product sections, one per stage, "makes no
sense". Same shape as saved_items — one table, stage as a tag, the current
stage as the default filter, switchable. Built the same day from the Mobbin
marketplace audit (`docs/PRODUCTS-AUDIT.md`): `lib/screens/products/`,
`PvCatalogStore`, migration 0083. What it still owes is §65.

### 61.3 Sharing a bookmark with the partner

Deliberately personal for now (FAMILY-MODEL §5). If wanted: a `shared`
boolean and a partner read policy — one migration, no store change.

### 61.4 The two old hubs and ten old saved-sets — commented, kept for revert

`saved_hub_screen.dart`, `pp_saved_hub_screen.dart`, and the old bodies of
VideoStore / ProductStore / CanIStore / ReadNextStore / PvReadStore /
CommunityStore / ReadToBabySavedStore / WatchStore / ReadingStore /
DailyTipStore. Delete after a release cycle with no revert.

### 61.5 Five V3 taps that fell back to classic — CLOSED

`home_v3_screen.dart`: the week hero, the avatar, the film-unavailable
fallback, the Garbh "about", and the reads rows all called `_open(context,
'<today surface>')`, which set `TodayVersion.classic` and stopped — the "tap
the article, land on the classic home" defect. Each now opens the thing it
names; `test/saved_screen_wiring_test.dart` refuses any live `_open` to a
Today/Profile surface. The remaining `_open` uses (`shop`, `tests_scans`)
are real tab switches and stay.

---

## 62.0 The first run is built; V3 is the default; what is still owed — OPENED 2026-09-17

`lib/screens/auth/onboarding/` — `OnboardingFlow` is what the splash pushes.
Built from the Claude Design "ParentVeda Onboarding" plus a question block:
two or three give-back questions per stage (`onboarding_questions.dart`),
after the date and before the reveal, each writing to `FamilyProfileStore`.
The old `AuthFlowScreen` is kept, commented at the splash, and still pushed by
the new flow for its two branches (partner pairing, doctor). Migration 0082
lets `profiles.life_stage` accept `skilling` and brings the pairing code to
six characters so both code sheets are one length (Swiggy/Zomato use six).

**V3 is the default** on all three homes (`TodayVersionStore`,
`PpHomeVersionStore`, `TtcHomeVersionStore`) — closes §17.3. The splash now
routes every stage to its own home: parenting to `PpHomeScreen`, skilling to
`SkillingPreviewScreen`, instead of everyone through the pregnancy shell.

### 62.1 Not walked on a phone yet

Google sign-in, the Phone Number Hint sheet, the SMS auto-fill and the OTP
functions need a real device and deployed functions (0080, mock mode is
enough). Tests cover every screen after sign-in.

### 62.2 "Was this helpful?" has no server column

`PvReadStore.helpfulOf` is local. When the recommendations engine reads it
server-side, add a column and a push; not before.

### 62.3 Twins, and the second child at onboarding

The Stage screen says "Expecting twins or more? You can say so later" and
there is no later yet. The Date screen adds one child; a second is added from
inside Parenting. Both are `pregnancies` / multi-child work (§61.1).

### 62.4 Reveal art

The reveal draws a tinted panel with the week/month label where the design
has the week-14 baby illustration. `assets/baby/` has per-week JPGs for
pregnancy; wiring the right one by week, and finding month art for parenting,
is a small follow-up.

### 62.5 The design project could carry the questions

The Claude Design has the seven screens; the question screens exist only in
code. If the design is to stay the reference, the question artboards should be
added there (DesignSync can push them) — not done, since the user is reviewing
the built screens directly.

---

## 63.0 The base UI is being settled — white ground, ink buttons, one type family — OPENED 2026-09-17

The user's brief: settle colour, type, buttons and components once, from what
the long-standing and current apps do (Mobbin), so V3 keeps its restraint and
nothing new regresses. Done so far, all reversible and recorded in
`docs/BASE-UI-DECISIONS.md` §1: white page ground everywhere; Plus Jakarta
Sans retired into Manrope through the `pvJakarta` seam (DESIGN-SYSTEM §2.2's
own decision, finally executed); the theme's FilledButton / ElevatedButton
became the ink pill and OutlinedButton the white pill; the onboarding chrome
follows the rule; the Premiere is off at app open.

### 63.1 Seven calls for the user — BASE-UI-DECISIONS §2 — ANSWERED 2026-09-17

FAB stays violet · pills moved to Profile → Developer · Fraunces replaced by
Newsreader · accent unchanged · ramp, radii, dark mode as recommended. The
sweep (§63.2) is unblocked.

### 63.2 The sweep — hand-rolled violet buttons, call-site renames, Garbh constants

24 hand-rolled `AppTheme.primary` fills and 43 `0xFF6A30B6` uses to sort into
"accent, correct" and "button, migrate to the theme". Classic screens last.

### 63.3 Walked on white — the user's own path, 2026-09-17

Pregnancy V3 home → stage menu → TTC V3 home → Fertile window door → the
conception article (its "Worth raising with a doctor" callout, its two tool
cards) → "See this cycle's window" → the clinic-dates screen → Ovulation
kits. What the walk found and fixed, on top of the §1 list: the tool sheets
were 0.72 of a screen and carried the nav clearance OUTSIDE the sheet, so
the hero field's lower arc bled through as a lilac bloom under every short
tool and under every tool's last card (`ttc_tool_chrome`, `ttc_window`,
`ttc_infographic`, `problem_hub`); TTC meta text and hairlines were lavender
(`ttcMuted`, `ttcBorder`) — grey now; the stage menu's icons were violet —
ink now; Ovulation kits had no Read next, so its foot was blank space.
Still owed: the parenting V3 home and the onboarding on the phone (needs a
sign-out), and the sweep.

### 63.4 Motion — what "jittery on exiting a door" turned out to be — 2026-09-17

Three things, all on every door, none of them the transition itself (the
user likes the same push between two articles): every TTC rail tile with
drawn art ran its own six-second loop at 60 fps (`TtcIllustration`), the
deck's four blurred cards were re-rasterised on every frame the page moved
(`ImageFiltered` with no layer of its own), and the hero field's few
thousand draw calls sat in the page's own layer. Fixed: rail art no longer
animates (`TtcHeroArt.animate = false` on rails), each blurred card and the
field are behind a `RepaintBoundary`. The fourth thing was the build: a
debug APK is JIT-compiled and stutters on first passes through any code —
motion is judged on the **release** build, which is what is on the phone
now. If it still jitters there, the next step is a `--profile` run with the
timeline, not more guessing. Also in this pass: the ripple is the classic
grey one, shaped by the control (`InkSparkle` ignored clips and drew a
violet rectangle on the rounded References row).

### 63.5 The push transition — fade-forwards on Android, 2026-09-18

The Cupertino push dimmed the page underneath (the "overlay" the user saw
on every door, opening and closing) and its edge-swipe fought the doors'
horizontal rails ("a single swipe back turns into two"). Android now uses
its own fade-forwards transition — same horizontal family, no dim, back
with the system gesture. iOS keeps Cupertino. `app_theme.dart`.

### 63.6 The scans timeline, redrawn — 2026-09-18

"I hate this screen… this whole corporate thing, two colours, Done Next
Later." Mobbin (Zocdoc, Superpower, Fable): one card for what is next, the
rest a dated list. `ScanTimelineBody`: an *Up next* card (name, window,
booked date or "No date added yet", one white pill), then *The usual run*
— week block, name, one meta line, a tick circle that toggles done. Legend,
station dots, "Mark as done" links and NEXT UP / DONE pills retired (kept
in the file for revert). Walked on the phone.

### 63.13 Read photos from rawpixel carry a watermark — FIXED 2026-09-19 (22 swapped to StockSnap CC0 via Openverse; rule: never `images.rawpixel.com/image_*` previews)

22 of the 32 URLs in `read_images.dart` are `images.rawpixel.com/image_1300/…`
previews, and rawpixel tiles its logo across a preview (seen on "Take it to
your appointment" — fetched and looked at). They cannot ship. Replace each
through Openverse with `source=flickr,wikimedia` (CC BY / CC0 files served
clean), keep the credit line, re-run `pregnancy_reads_shape_test`. The 10
Flickr `_b.jpg` files are fine.

### 63.18 Read photos: one host, verified; bundling as assets owed — 2026-09-19

`read_images.dart` is 96 entries, all `cdn.stocksnap.io`, every one
fetched and checked as a real JPEG (the ten Flickr files are gone: Flickr's
CDN resets connections from Indian networks — all ten failed, all others
served). The user still saw icons on Scans & tests on the phone — either an
older build or StockSnap blocked on that network. **Decided (the user, 2026-09-19):** the photos go to Cloudflare R2, the
same bucket the Garbh audio uses — upload the 96 files, point the table at
`r2.dev` URLs, keep the credit. Not bundled. Owed with the R2 custom domain.

### 63.17 The Ask Veda FAB is OFF — 2026-09-19

`FabState.kAskFabEnabled = false` (global_ask_fab.dart). The user: "hide
it for now, we have a separate discussion on it." Every door page keeps
its "Ask Veda about …" row and the search screen its last row. The door
sheets' foot inset reads the flag (24pt off, 164 on). Decide with §63.11:
placement, a drawn mark, whether it lives only on reads.

### 63.16 One doctor page, keyed by the doctor — BUILT 2026-09-19; the data seam owed

**Built.** `ProviderProfileScreen` is the one doctor page (base UI; Mobbin:
Zocdoc, Airbnb host, Preply, Udemy instructor): avatar · name · role ·
location · top pick · ★ / N reviews / years · About · Why · Helps with ·
**Sessions with her** (1:1 + every masterclass, course, cohort and class
she hosts, as rows) · Qualifications (unfolds) · From parents · a sticky
"Book a 1:1 · ₹" pill. The pregnancy consult list opens it directly;
`ConsultationDetailScreen` (the slot picker in between) is retired to a
fallback. The 1:1 row opens a slot sheet (ink pills) → the Prepare confirm
sheet. The "Next: today 6pm" pill is off the list.

**The user's brief for the data:** "plug and play — we give you a document
or spreadsheet that says this doctor does these things, and it shows up
wherever she is." Where that stands:

| Fact | Keyed by the doctor today? | Where |
|---|---|---|
| Who she is (name, role, location, rating, blurb, why, tags, qualifications) | YES — `expert_profiles` row, merged over Dart by `ExpertStore` (0072) | cloud |
| Whether she takes 1:1s | YES — `expert_profiles.takes_consults` | cloud |
| Her masterclasses / cohorts / courses | YES — `programmes` + `programme_experts(expert_id)` (0054) | cloud |
| Her real slots | YES — `DoctorScheduleStore`, from ParentVeda+ | cloud |
| Pregnancy 1:1 price, the 4 demo slots, 2 reviews | **NO** — on `Specialist` (prepare_data.dart), matched to the Expert BY NAME in the profile | Dart |
| Pregnancy Prepare courses' host | **NO** — `instructorName: String`, matched by name | Dart |
| Reviews | **NO** — a tuple list on `Expert`, empty for pregnancy people | Dart |

**Owed (the spreadsheet job):** one `expert_id` column on `Specialist` and
on `PrepProgram` (then the name matches go); a `reviews` table keyed by
`expert_id` (the same shape Products uses, named reviews); a per-doctor
consult price on `expert_profiles`. With those three, the sheet is one row
per doctor + one row per offering, and every surface that names her reads
the same rows. The profile's `Specialist` seam is the only place the two
models meet — remove it when the ids land.

### 63.15 Scans & tests — second review round done — 2026-09-19

PREGNANCY-DOORS-REVIEW §1, second table. Owed from it: photos for the 27
findings and 15 conditions (`finding_<id>`, `condition_<id>` in
read_images.dart — rows fall back to the icon well until then); the
"Report" default title when she skips "Which one is this?" (a photo
should get a name from the day, e.g. "Report · 19 Sep"); onboarding's
"Week 1" placeholder card. The leaf-format table is DESIGN-SYSTEM §4.0
addendum 3.

### 63.14 The door walk — Complications done — 2026-09-19

See `docs/PREGNANCY-DOORS-REVIEW.md` §2. New door-wide rule: written
sections are lists (DESIGN-SYSTEM §4.0 addendum 2) — this changed every
door's all-article sections at once; walk each as its door comes up. The
condition gate is off; "Add to my journey" confirms on tap. Owed: the
phone walk (device dozed), the 15 condition reads for thinness. Also seen:
the daily tip returns on every foreground, not once a day — check
`_maybeShowTip` in home_v3_screen.dart. Next door: Is it safe?

### 63.12 The door walk — Scans & tests done; the recipe — 2026-09-19

`docs/PREGNANCY-DOORS-REVIEW.md` holds the table for each door. Scans &
tests: search bar; timeline's date sheet (inline calendar + slots; a real
`Appointment`); "What is next" tool retired; scan reads carry their own
parameters + interpretation; line-by-line tool retired; decoder tab
without its own search, ink pills, compact rows; the pinned flag and every
callout un-boxed (§4.0 addendum); Talk merged to one section; checklist
rows; the Prepare kit inked; consults restructured (Zocdoc/Preply/Alan);
pickers and text buttons ink app-wide. Owed on this door: the booking flow
under the consult detail (shared with the doctors terminal); the locker
walked with a real report. Next door: Complications.

### 63.11 The Ask Veda FAB — DONE 2026-09-19 (two-tone violet, lifted above the nav pill; BASE-UI §2.1). Owed: a drawn Veda mark in place of the stock sparkle — the user: "maybe change the logo for Ask Veda"

The user: "very purple and outdated… like a sore thumb on the Products
page and the new pages. Not a lot of changes, a little tweak so it matches
the new app." Queued behind the door selector. BASE-UI-DECISIONS §2.1 was
(a) keep the violet; the user has now answered (b). Direction when it is
built: the pill family (§4.0) — ink or white, the mark in line, a shadow
not a fill — checked against Mobbin's floating assistants before touching
`global_ask_fab.dart`.

### 63.10 Search — built on pregnancy doors; owed elsewhere — 2026-09-18

`PvSearchBar` in every pregnancy door's hero; `PvSearchScreen` over
`kPvDoorPages`; `PvSearchStore` for recents. DESIGN-SYSTEM §4.0e. Owed:
the same bar on parenting doors (`pp_door_screen`, index over
`PpDoorPage`s) and TTC (`ttc_focus_screen`, index over the TTC pages) —
each stage's index is its own door data; the screen and store are shared.
Also owed: the weekly reads (`pregnancyWeeklyReadFor`) are not in the
index, being home content rather than door tiles.

### 63.9 A note on each scan — 2026-09-18

The Up-next card carries two pills: *Add the date* (the appointments
screen) and *Add a note* — a bottom sheet, one field, Save / Delete. The
note is hers: `ScansStore.noteFor / setNote`, `shared_preferences` key
`scans_notes`, shown on the card and as the scan's row meta in the run.
Held by `test/scan_note_test.dart`. **Owed:** the cloud column
(`completed_scans` has no notes; a `scan_notes` table keyed by user +
scan id, LWW like the rest — BACKEND-PATTERNS §sync), and the partner
seeing her note. The user's launch rule, recorded here for the next
feature: *"whatever that button does should be working… not static."*

### 63.8 Tap feedback as a component — DESIGN-SYSTEM §4.0c, 2026-09-18

`PvPress` / `PvTick` / `pvCommitFeedback` in `lib/widgets/pv_feedback.dart`;
wired on the scans timeline, the reader's foot, the checklist and
onboarding. **Owed:** the door rail cards and the home door grid (a press
settle), the story deck's chevrons, the TTC insight rail — as each is
walked.

### 63.7 One format per tag — DESIGN-SYSTEM §4.0b, 2026-09-18

CARDS pages open as the story deck (15 of 32; the rest carry a film, a
consult offer or a chart the deck cannot hold, or are empty, and open in the
reader with their cards listed); the chart card is the same white data card
as the table; Activity / Ceremony / Recipe open on their steps; Red-flag
pages open on their flags; Guide and Myth-vs-fact chips say Article; the
checklist's share bar is the theme's ink pill. **2026-09-18, evening:** four selectors exist behind flags in
`pv_door_screen.dart` — rail (Flo, on Scans & tests), tiles (on
Complications), low deck (everywhere else), chips (none). BASE-UI-DECISIONS
§2.8 has the record; the user picks rail vs tiles, then it rolls to every
door of all three stages and the other three retire. **Owed:** the TTC and parenting tag surfaces walked on the phone; the empty
CARDS pages (Potty pull-ups, taking longer; Traditions ×3; Health accidents)
are still empty.

## 64.0 The TTC home names a window the tool refuses — SEEN 2026-09-17

On the same account, at the same minute, the V3 home's hero said *"Your
fertile days are today and 2 more days · 13 Sep to 19 Sep"* and the Fertile
window tool said *"Your clinic is watching this cycle… so we do not name a
date."* Both are deliberate: the hero calls `ttcFertileWindowNow(
ignoreOwnership: true)` because the pathway's clinic guess is a GUESS and
her real clinic dates are checked first (`ttc_home_hero.dart`, the long note
above that call); the tool honours `behaviour.showsFertilityWindow` because
a clinic-run cycle is the wrong model for a six-day picture. Each is right
on its own terms and together they contradict her on one screen pair —
"prediction language only where we predict" (CLAUDE.md) cannot hold on the
home if the tool has just deferred. Not a base-UI matter; it needs one
decision about which surface yields when the pathway is a guess and no
clinic dates exist. Recorded, not fixed.

## 65.0 The unified store is built; what it still owes — OPENED 2026-09-17

`docs/PRODUCTS-AUDIT.md` is the audit and the architecture. Nine screens in
`lib/screens/products/`, one model, one catalogue folded from the three old
ones by adapters, one compare tray, an order/address store, `PaymentService.pay()`
shared with bookings, migration 0083, and the create-order function pricing
cart lines server-side. Products is slot 2 on all three bars; Prepare and
Courses are the first tile of their Tools hubs. Every old product screen is a
facade; every old body is `…Classic`, kept for revert. 4,109 tests green.

### 65.1 Deploy 0083 and load the catalogue into `products`

`supabase db push` is the user's. Until the unified rows are in the table the
create-order function cannot price a line and charges the phone's figure with
`priced_by: client` on the Razorpay order — visible in the dashboard, not
silent, but not the server's number either. The adapters
(`buildPvCatalog()`) are the import script; a one-off that writes them as
rows is not written yet. `PvCatalogStore.applyRows` is the seam on the app
side; nothing calls it yet.

### 65.2 A device walk of all three storefronts — WALKED 2026-09-17 (pregnancy shell)

Walked on the Galaxy S21 FE the same evening, in versus format against the
Mobbin references (`scratchpad/shots/v*.png` during the session; the
references are in `PRODUCTS-AUDIT.md` §2). Storefront → stage switch → shelf
→ product → zoom → bag → checkout → address → Razorpay (a real test payment,
`pay_TdAI2mS3GamCis`, verified server-side) → placed → orders. Twelve
defects found on the phone and fixed:

1. `UsageSurface` allow-list did not know `products` — the tab tap asserted.
2. Rails had ~40 dp of slack under the cards (fixed-height ListView) → a
   content-sized Row in a horizontal scroll view.
3. The same product in two rails → recommends rail deduped against for-you.
4. Size chips rendered full-width → a Container's `alignment` in a Wrap.
5. The sort chip overflowed beside a counted Filters chip → Flexible + cap.
6. "For you · 0 weeks" on a phone with no saved child → no clock.
7. TTC's own PARENTVEDA PICK badge above the mark → badge dropped.
8. Pros/cons chips repeated the lists above, truncated → dropped.
9. Floating top buttons over the page's text once scrolled → white bar.
10. "Compare with similar" and "You might also like" showed the same item →
    related is cross-category.
11. The "Added to your bag" snack outlived navigation and sat on the bag's
    commit; every ink snack sat on the ink bar and "looked like one" (the
    user) → white, hairlined, lifted above both the bar and the Ask pill.
12. The Ask pill sat on "View order" → hidden on bag/checkout/placed/zoom.
13. Razorpay did not prefill the phone → `+91` prefix.

Plus what the user asked for on the walk: the hero band (`pv_hero_band.dart`)
and the motion pass (`PRODUCTS-MOTION-AND-ASSETS.md`).

**Not walked:** the parenting and TTC shells' own bars on the store (the
phone was signed in as pregnancy; the bar is drawn by `PvStoreNav` from
`chrome`, pinned by test, but unseen). Do those two first next time.

### 65.3 Seed content that must be replaced before launch

- Reviewer names on "ParentVeda recommends" (Dr. Meera Iyer, Dr. Anaya Rao,
  Dr. Vikram Sethi) are the Guide data's seed experts, not real reviewers.
- Photographs are free-licence Unsplash shots of the object type, captioned
  "Representative photo". Real product shots replace them per product in
  `pv_product_extras.dart` (a source-file photo always sits first).
- The pregnancy "best overall" recommendations were written in this build;
  the parenting ones are the Guides' verdicts; TTC's are the source file's.
- `expertsPct` / `parentsPct` on the parenting side are the Guide's own
  derived figures, carried because the Guide already showed them. The unified
  model never derives one; those inherited numbers should become measured or
  null when real review data exists.

### 65.4 Order status cannot move past what the app knows

`paid` is set after the signature verifies; nothing ever sets shipped /
delivered. That is a webhook (Razorpay → `orders.status`, then the
fulfilment side) and a WhatsApp template; the placed screen promises "a
WhatsApp update when it leaves", which is a promise the outbox can keep once
the template exists. The 7-day returns line is copy, not a flow.

### 65.5 An Ask Veda row on the product page

Every stage's Ask Veda is a different screen; the product page has no row
because wiring the wrong one is worse than none. One `askVedaFor(stage)`
opener in the surface routers, then a row under "What experts say".

### 65.6 Brand Studio on the shelf

Sponsored placement obeys the rank floor (`lib/brand/rank_floor.dart`) on the
old shelves; the unified shelf sorts on band and review count and reads no
campaign. Wire `rankFloor` into `PvShelfScreen`'s sort before any campaign
targets a product.

### 65.7 Retire the classic bodies after a release cycle

`ProductsScreenClassic`, `ProductsDiscoveryScreenClassic`, both
`ProductDetailScreenClassic`s, `ProductsCompareScreenClassic`,
`Products(Sub)CategoryScreenClassic`, `ProductGuideHubScreenClassic`,
`ProductGuideScreenClassic`, `openProductWithGuideCheckClassic`,
`TtcShopScreenClassic` and its shelf/product/compare, `TtcProductsScreenClassic`,
`PpCompareStore`, `TtcCompareTray`, and their pinned tests. Same clock as §61.4.

### 65.8 Two small facades that changed behaviour, on purpose

- Ask Veda's `ttcprod_<id>` deep link opens the product page directly, not
  the flat list with a highlight (test updated, `ttc_open_points_test`).
- The Guide's "which view?" chooser is gone; a product with a Guide opens the
  one page that now carries the Guide's layers.

### 65.9 What the product engine is still missing — the honest list, 2026-09-17

The user asked for it in one place. Ordered by what a shopper would hit
first, not by effort.

**Commerce that is a screen but not yet a system**
- Order status after `paid`: no webhook, no packed/shipped/delivered, no
  WhatsApp template. The placed screen promises a WhatsApp update it cannot
  send yet (§65.4).
- Returns and cancellation: copy only ("7 days"). No cancel button on an
  order, no return flow, no refund path through Razorpay.
- Stock: nothing knows a quantity. "Only 2 left" (Amazon Haul) and
  sold-out states do not exist; a variant cannot be unavailable.
- Delivery estimate and pincode check: "3–6 days" is a constant. CRED's
  "delivery in 3–6 days · Home, 453331" needs a serviceability lookup.
- Coupons / promo codes: the checkout has no field. (Expert codes are
  decided as attribution OR coupon — STILL-OPEN §13.0 — and neither reaches
  the store yet.)
- Multiple addresses are stored but there is no address book screen outside
  checkout; no edit, only add and pick.
- Guest checkout: `PvOrderStore` syncs only when logged in; a logged-out
  order is local to the phone forever.
- Server-priced orders depend on 0083 being loaded (§65.1); until then the
  Razorpay order is stamped `priced_by: client`.

**Trust layer**
- Reviews are seed. No write path: a parent cannot rate or review, and the
  "asked two weeks after delivery" line in the reviews empty state is a
  promise without a job behind it.
- "Helpful" on a review, review photos, verified-purchase marks — none.
- Expert films: the cards open nothing (`videoId` is a stub on the Guide
  side too).
- The reviewer names on "ParentVeda recommends" are seed experts.
- Q&A ("Ask a question", Sephora; "Ask Rufus", Amazon) — the natural home is
  an Ask Veda row on the product page (§65.5), not built.

**Discovery**
- Search is substring-only over name/brand/category/best-for; no typo
  tolerance, no synonyms ("pacifier" ≠ "soother"), no recent searches, no
  suggestions as you type.
- Filters have no age/week filter on the parenting/pregnancy shelves and no
  "concern" entry (rashes, colic) — the old parenting discovery had both.
- Brand pages ("From the brand", Amazon; Instagram shops) — a brand is a
  string, not a destination.
- Recently viewed ("Pick up where you left off", Etsy) — not kept.
- Saved products have a home (Saved · Products) but no price-drop or
  back-in-stock signal.

**Catalogue**
- 59 products. Real shelves need hundreds; the adapters are the import
  script and the table is ready (0083), the rows are not.
- Photos are representative stock (§65.3); category marks are Material
  glyphs (`PRODUCTS-MOTION-AND-ASSETS.md` §2.2).
- Hindi: the store is English-only by policy (CLAUDE.md); the pregnancy
  catalogue's Devanagari names are not surfaced.

**Monetisation**
- Brand Studio's rank floor is not wired into the shelf sort (§65.6); no
  sponsored slot on the storefront; no affiliate tracking parameter on the
  retailer URLs (the Amazon links are plain searches).
- Bundles / "frequently bought together" — none.

**Engineering**
- No analytics on the funnel beyond the tab tap (`UsageEvents`): card taps,
  add-to-bag, checkout start, payment outcome are unrecorded.
- Image caching is Flutter's in-memory cache only; no disk cache package —
  a cold open refetches every photo.
- The Classic bodies and their pinned tests are still compiled (§65.7).

## 66.0 The question miner is built and run; four things it could not reach — OPENED 2026-09-18

`tools/question_miner/` collects question text (never answers) from public
sources, tags each question with a stage and a door-aligned topic, clusters
by meaning per stage and ranks by demand. Output: `research/questions/`
(workbook `parentveda_questions.xlsx`, CSVs, generated README). Read the
tool's README for sources and method.

**Reddit OAuth credentials were not in hand.** The brief said they were
provided; nothing was on disk or in the environment. The run used the
public RSS feeds instead, which Reddit now limits to ONE request per clock
minute per IP (measured from `x-ratelimit-*` headers), so Reddit is the
shallowest source in the pool: one page of new, hot and top-of-year per
sub. When the credentials exist, put them in `tools/question_miner/.env`
(`REDDIT_CLIENT_ID`, `REDDIT_CLIENT_SECRET`, `REDDIT_USER_AGENT`) and run
`python tools/question_miner/run.py run --sources reddit` — PRAW pulls up
to 1,000 titles per listing at 100 req/min, the whole Reddit pass takes
about five minutes, the other sources carry forward, and the pool is
re-clustered. This is the one open point that changes the ranking.

**Google "People also ask" is not reachable by HTTP.** The SERP HTML comes
back 200 without the PAA block (rendered client-side). Substitute in the
run: the autocomplete expansion (`<why/how/is it safe…> stem`, `stem a…z`,
then one level deeper), which is the same demand signal one step earlier.
If PAA is still wanted, it is a browser-driven job (Claude in Chrome over
~100 queries), not a fetcher.

**Semrush is off the table until the user says otherwise** (decided
2026-09-18: "we will decide its use in future"). Recorded only so nobody
re-proposes it as a collector: it would give question keywords with India
search volumes, and the account currently has no API units anyway.

**Hinglish clusters run small.** Parentune and BabyChakra questions are
largely romanised Hindi; the English embedding model does not read it, so
`qm/normalize.py` maps ~150 common Hinglish words to English before
embedding. That lands "mera baby khana nahi khata" beside "baby not eating"
but misses longer sentences, which cluster among themselves. Options: a
multilingual embedder (none reachable offline yet — HuggingFace is
connection-reset from this network; `fetch_model.py` uses a mirror), or
widening the word map as the unclear bucket shows what is missed.

Also dead on 2026-09-18, for the record: Momspresso (TLS handshake fails),
Quora (Cloudflare challenge), Bing PAA (client-rendered).

## 67.0 You — one profile for four stages is built; what it still owes — OPENED 2026-09-19

`lib/screens/profile/` (docs/PROFILE-AUDIT.md). Eight sections in one
order on every stage; the avatar on all four homes opens it;
`ProfileScreen` and `TtcProfileScreen` are facades. Built on the user's
five decisions: *You*; avatar entry; *Notes for your doctor* in; *Download
my data* present as "Coming"; one partner switch. Not walked on a device
(the phone was out of bounds for this pass).

### 67.1 Download my data needs an edge function

The row is on `PvDataPrivacyScreen` and says *Coming*. Her rows are spread
across a dozen tables with RLS on each, and only a function running as
the service role can gather them into one file for one user. Shape when
built: `export-my-data` edge function, answers only for the token's own
user (the `delete-account` pattern), writes a JSON (later a zip) to a
private storage bucket, returns a signed URL that expires in an hour. The
row then opens that URL. Until then the copy says so, because a row that
pretends to work is worse than one that says when.

### 67.2 Partner sharing is one local switch; the server does not know

`kPvPartnerShareKey` (`pv_partner_share_week`) is a `shared_preferences`
bool read by nothing on the server. The partner sees what the existing
RLS lets a paired partner see, which is unchanged by the switch. That is
honest on screen (the partner page says what is shared and what never
is) but the switch itself is inert until it becomes a column on
`profiles` (`share_week_with_partner boolean default true`) that the
partner-read policies check. Per-thing switches (calendar / journal /
records) were declined for v1 — the user's call — and belong in the same
migration when they come.

### 67.3 Privacy notice, Help, About

Three rows that end in a snack today: the privacy notice (no published
document yet), Help (no support channel — the snack names an email), and
About (a sheet with the honest four sentences). Each is a row so the
place exists; each needs its content.

### 67.4 The device walk

Every stage's You, the child page, the partner page, the doctor notes,
the language sheet (TTC flips `TtcLang`, the others `controller.setLanguage`),
the sign-out round trip, the delete flow with the typed keyword, and the
*View as* pill with a paired partner. Same versus format as the store
walk: ours beside the Mobbin reference. Also the products hero band's
loop, which landed in the same commit and has not been seen on a phone.

### 67.5 The classic bodies

`ProfileScreenClassic` and `TtcProfileScreenClassic` are kept for revert
and pushed by nothing (`test/pv_you_test.dart` holds that). Retire them
after a release cycle, with §65.7's store bodies. The classic pregnancy
profile's *Enter doctor mode · testing* was NOT carried to You: the
doctor app is its own flavour now (BACKEND-PATTERNS §12) and the
in-app switch was the pre-flavour road.

### 67.6 Skilling's You is the parent's, in a debug build

`LifeStage.skilling` is still not a persisted stage; You for skilling is
reached from the preview home's avatar and from the grown-up page, both
behind `kDebugMode` like the rest of the stage. When the stage ships, its
You needs nothing new — the content row already exists — only the door.

## 68.0 Is it safe? is rebuilt as a door; what it still owes — OPENED 2026-09-19

`lib/screens/can_i/` (door, group, answer, identify, widgets),
`lib/data/can_i_groups.dart`, `lib/data/reads/can_i_read.dart`,
`lib/services/can_i_activity_store.dart`, `0086_can_i_misses.sql`,
`supabase/functions/can-i-identify/`. Seven Mobbin passes in
MOBBIN-DISCOVERY §11; the walk in PREGNANCY-DOORS-REVIEW §3. Built, not
walked — the phone was out for this pass.

### 68.1 The vision key — a pricing decision, then a secret
The photo path is wired end to end and returns `not_configured` until
`CAN_I_VISION_PROVIDER` and the matching key are set. The user's call,
after a pricing discussion. Brackets at ~1,200 tokens a photo, 10,000
lookups a month: Groq Llama 4 Scout ≈ $2 / ₹170; Gemini 2.5 Flash ≈ $2 /
₹170; Claude Haiku 4.5 ≈ $15 / ₹1,250. Accuracy on Indian foods is the
real difference; test 30 photos on each before picking. Then:
`supabase functions deploy can-i-identify` and two `secrets set` lines
(the function's header has them).

### 68.2 Migration 0086 is written, not run
`can_i_misses` + the desk's view. Run it; the misses log is inert until
then (the client's upsert fails silently, as designed).

### 68.3 Scan placement — decided on the device
`kCanIScanAtFoot` (can_i_door.dart): TRUE = pinned pill at the bottom
centre (payments-app placement, the user's suggestion), FALSE = two
rounds beside the field (Yuka). Both built; the user judges on the phone.
"It should not be like it was looking way better in the hero section."

### 68.4 Photos — placeholders from two free pools, R2 later
193 item photos + 4 shelf photos in `read_images.dart` (`cani_<id>`,
`cani_shelf_<category>`), picked by hand from Wikimedia Commons and
StockSnap (via Openverse) contact sheets. Roughly a fifth are stand-ins
(a related dish, a generic tablet) and a few have none and fall back to
the icon well. The end state is cut-outs on white on Cloudflare R2
(§63.18); the map is the only thing that changes.

### 68.5 Trimester notes — 82 / 65 / 78, written 2026-09-19
Before this pass 4 / 3 / 4 entries had a trimester note; "for you, week
N" had nothing to say. Written for every entry where the trimester
genuinely changes the answer (`cani_trimester.py` in the session
scratchpad seeded them; the notes live in `can_i_data.dart`). **Owed: a
clinical read of the new notes.** They are general, hedged and defer to
the doctor, but they have not had a clinician's eyes.

### 68.6 Can I entries are not in the Everywhere search
`pvSearchIndex()` is keyed by `PvDoorPage`, and Is it safe? is a surface,
not a door page. The door's own field covers it; "papaya" typed on the
Scans door does not find it. Small seam: a `PvSearchHit` without a page.

### 68.7 "What changed this week" on the home
The notes now make it derivable: entries whose note for her new
trimester exists. A home card on the trimester crossing ("3 answers
changed for you") is the natural use; out of this door's scope.

### 68.8 The old screen
`CanIScreen.buildClassic`, `_CategoryScreen`, `CanIAnswerScreen`,
`_SavedScreen`, `_CanISearchDelegate` and `kCanIPopular` stay in
`can_i_screen.dart` for revert. Retire after the walk.

### 68.9 Open Food Facts coverage
Regional Indian brands are often absent; the "not in the food database"
sheet handles it and logs the barcode. If misses show one brand
repeatedly, OFF accepts contributions — or a small own table of
barcode → entry for the fifty most-scanned packets.

### 68.10 The answer is a verdict page, not a read — DECIDED on the phone 2026-09-19
`CanIVerdictScreen` behind `kCanIAnswerAsVerdict` (can_i_answer.dart);
the reader path (`CanIAnswerReader` + `pvReadFromCanI`) stays for revert
and for reader-shaped seams. DESIGN-SYSTEM §4.0 addendum 5 has the rule.
Also from the walk: the bracket hue is 136 (green) not 232; one camera
button with a photo-first chooser instead of two buttons; *Yours* (Saved
+ recents) under the field instead of Saved at the foot; the reader's foot
reserve now follows `kAskFabEnabled`. The user's standing note for this
door: *"either it serves the purpose or not. It needs to look good."*

### 68.11 Photos, second pass — Wikidata "depicts"
The first pass (Commons text search, first hit) put a cocktail on
Pineapple and a couple-with-dog on Sex. Second pass: item → Wikidata Q →
Commons `haswbstatement:P180=Q` sorted by incoming links (the pictures
Wikipedia itself uses), reviewed on sheets. Entries with no tagged photo
keep the first-pass pick or the icon well. Still placeholders until R2
(§63.18), which the Wikimedia 429 made urgent: a free host throttles by
IP, and Indian carriers put thousands of users behind one.

## 69.0 Learn — one funnel for five kinds is built; what it still owes — OPENED 2026-09-20

`lib/screens/learn/` (docs/LEARNING-AUDIT.md). One Learn home, one
Offering page with ten sections in one order, one slot sheet, one review
sheet, one Booked page, one player, one My learning; twenty-five retired
screens are facades over them and the doctor page's rows and Book pill go
through the same flow. Built on the user's five decisions, all as
recommended. Not walked on a device.

### 69.1 The device walk

Every stage's Learn home; one offering of each kind; a full booking of a
consult (slot → review → Razorpay test → Booked → the LiveKit green room)
and of a masterclass (date card → review → Booked → the group room); a
class pack (review → slots → Booked, credits counting down); the free
garbh course (a lesson opens its practice screen, the tick comes back);
the doctor page's rows; the covers (topic placeholders — a wrong subject
is a data edit in `pv_learn_images.dart`). Versus format, ours beside the
Mobbin reference.

### 69.2 Reviews on offerings — one review system

Decision 3: the store's `reviews` table when it can take an `offering_id`
beside `product_id` (one column, nullable, a check that exactly one is
set). Until then the page reads the source models' seed reviews. The
"honest count" rule from the store applies: no number that is not a row.

### 69.3 Lesson progress is local only

`PvLearnProgressStore` is `shared_preferences`. It belongs with bookmarks
in the family model (hers, across her phones) — a `user_state` key through
`CloudSyncedStore` is the cheap correct shape (BACKEND-PATTERNS §16g's
argument: one reader, replaced whole).

### 69.4 The films

No lesson has a video; the player says "Film · arriving" over the cover and
shows the lesson notes. `PvLearnLesson.videoUrl` is the seam. When the
watch library carries course films, the adapter fills it and the poster
becomes `PvVideoPlayer` — nothing else moves.

### 69.5 Calendar export

The Booked page's *Calendar* action sets the one-hour reminder and says
export is coming. An `.ics` share or `add_2_calendar` is the whole job.

### 69.6 Retire the classics

Twenty-five `…Classic` bodies, pushed by nothing. Retire with §65.7 and
§67.5 after a release cycle. `MindMood`'s talk offerings still run
`showBookingSheetClassic`; giving them a `PvOfferingView` adapter retires
that too.

### 69.7 The store's category tiles — DONE 2026-09-20, walked once, redone

First cut mapped Unsplash ids from memory; the user's walk found a cat in
a blanket under Books and a sofa under Stretch mark care. **An id
remembered is not a photo seen.** Redone the way the nutrition dishes
were: each object searched on Wikimedia Commons, candidates laid on a
contact sheet, looked at, chosen (`lib/data/products/pv_category_images.dart`,
nineteen, 500-px thumbs — Wikimedia refuses 640). `PvRetryImage` tries
again at 2 s and 5 s because Commons answers 429 to a strip of nineteen
asking at once. Two are the weakest and worth a glance on the next walk:
*Stretch mark care* (a small-brand cocoa-butter jar) and *Skincare* (two
branded baby washes). The learn covers (§69.1) still carry the first
cut's Unsplash ids and need the same treatment.

### 69.8 The store walk of 2026-09-20 — done, and one thing to decide

Fixed from the user's walk, all against Mobbin:

- **One search pill.** The home's pill and the search screen's were two
  look-alike containers at different x and y, so tapping made a second
  shape appear under the first. `PvSearchPill` is one widget, one
  geometry, Hero-linked; the back arrow lives inside it (UNIQLO, SKIMS).
- **A search panel with something in it.** Recent (with a clear — eBay,
  StubHub), Try (suggested searches — On, Gymshark), Shop by category
  with the photo tiles (Gojek). As she types: matching categories as
  rows first (SKIMS), then the stage chips and the grid. `PvSearchHistory`,
  local, eight entries.
- **A wishlist.** The heart saved to You → Saved → Products, three taps
  away and unsigned. Now a heart with a count in the store header opens
  `PvWishlistScreen` (Myntra), hers first then the other chapters.
- **No notice on the heart.** The snack rose to a third of the screen
  ("a very abrupt position"); the heart now fills with a small pop and
  the header count says where it went. `pvSnack` is unchanged for the
  compare messages, which sit above a real bar.
- **The 20-second guide** is a white card with a hairline, the eyebrow,
  the line, and LOOK FOR / SKIP with ink marks — no tinted well, no green
  ticks or red crosses. The old card is `_guidanceClassic`.
- **The shelf grid** is rows sized to content (`PvProductGridSliver`),
  one gap between rows; the fixed-ratio grid left a different slack under
  every card ("the spacing is not defined").

**To decide — the "ParentVeda recommends" box on the product page.** The
user does not like the filled violet well "popping up in the centre" and
asked what other apps do. Mobbin (2026-09-20): Liven marks an expert
review with the expert's avatar, name and credential and a small
EXPERT REVIEWED pill; Faire and Commons use a round seal with a
one-line explanation; Amazon's Choice and Udemy's Bestseller are small
ink tags on the card, not bands on the page. Three options:

1. **A signature, not a box (recommended).** White card, hairline, the
   violet eyebrow PARENTVEDA RECOMMENDS, the reason in plain ink, and
   the reviewer as a person — initials disc, name, credential, the
   verified mark — Liven's shape. It converts because a named clinician
   vouches, and it follows the base UI (white, ink, violet only on the
   eyebrow). The "before you buy" line stays as a quiet second paragraph.
2. **A seal.** A round ParentVeda mark at the top of the section with the
   reason beside it (Faire, Commons). Distinctive, but a seal is a claim
   of authority in a shape, and the store's honesty rules put the reason
   and the name above the shape.
3. **Tag only.** Keep the PARENTVEDA PICK tag on the image and drop the
   band to a plain paragraph. Least visible; the user asked for something
   that "pops into the eyes", so no.

**Picked: option 1, built 2026-09-20.** `_recommend` on `pv_product_screen.dart`
is the signature card; the tinted well is `_recommendClassic`, kept for
revert. The two cautionary bands keep the same card with their word as
the eyebrow and the tone dot in place of the mark — a caution is not a
signature.

## 69.0 Nutrition is a day — BUILT 2026-09-20, walk owed

`lib/screens/nutrition/door/` (door, meal sheet, need screen, recipe +
cook mode, recipes grid, shopping list, preference sheet),
`lib/data/nutrition/nutrition_plate.dart` (the plate, the needs, chart
scoring), `lib/data/nutrition/nutrition_photos.dart` (dish sentence →
photo), `lib/services/nutrition_day_store.dart` (per-day blob).
The home tile opens `NutritionDoorScreen` behind `kNutritionDoorAsDay`;
the five-tab `PvDoorScreen` over `kNutritionDoor` stays for revert.
Research in MOBBIN-DISCOVERY §12. Tests: test/nutrition_door_test.dart.

### 69.1 Built, in one line each
Today's plate from the best-fit chart (trimester × diet × region ×
condition), deterministic per date; Swap (the chart's swaps + the other
days' same slot) and "not today"; five needs as ticks with a burst, foods
and recipes behind each; eight glasses; craving chips that log and open
the craving page, with a seven-day pattern line; recipes hers-first with
the unticked needs leading; a recipe page with a servings stepper, Add to
my list, numbered method and Cook mode (screen awake); the shopping list
with Send; diet + region in one sheet; the library (charts, fasting,
nutrients, Is it safe?) as rows; the dieticians unchanged.

### 69.2 "Can I eat this?" retired from this door
Nutrition's old first tab was a 64-food safety checker — a second Is it
safe?. One home per fact: the row "Is this food safe?" opens the Is it
safe? door. **Owed:** merge the 64 `kFoodEntries` into the 193 Can I
entries where they add a food we lack, then retire `food_verdict_screen`
and `can_i_eat_body`.

### 69.3 Photos
~48 dish keys + 17 recipes through the reviewed pipeline (Wikidata
depicts, then Commons text), by eye, Wikimedia/StockSnap hosts, R2 later.
A sentence with no known dish shows the slot icon.

### 69.4 The reminder (Tier 2)
`NutritionDayStore.reminder` exists; the one gentle daily nudge is NOT
wired to NotificationService yet — one line of opt-in on the door and a
`scheduleOneOff` at 8 pm "Did you get your iron today?" is the whole job.

### 69.5 Owed content
Eight fasting pages (§35.6, still); a clinical read of `kPlateNeeds`
lines; the plate slots' names come from each chart and vary ("Evening"
vs "Snack") — harmonise across the nineteen contents.

### 69.6 Not walked
The phone dropped off USB as the first build finished. Walk list in
PREGNANCY-DOORS-REVIEW §4.

## 70.0 Nutrition, back inside the door language — 2026-09-20, on the phone

The day screen (§69) stood outside the door shell and the user called it on
the device: *"make it consistent, like Scans & tests and Complications …
I want to maintain consistency throughout the application."* So:

- The Nutrition tile opens the ordinary `PvDoorScreen` over `kNutritionDoor`
  again (`kNutritionDoorAsDay = false`; the standalone screen stays for
  revert). Nutrition joins `kPvDoorRailDoors`.
- **Today is the first tab's inline tool** (`NutritionTodayBody`: plate,
  ticks, glasses, cravings, eating-your-way) — the way My scans is the
  timeline. Under it, two tiles: *Is this food safe?* (→ the Is it safe?
  door) and *Your shopping list*.
- "Can I eat this?" is retired from the door (a second Is it safe?);
  nutrients fold into *What to eat now* so the door keeps five tabs.
- **Recipes** is a tab: an inline rail of `PvDoorRailCard`s **with photos**
  (the card gained an optional `imageUrl`, reader next-step treatment), then
  every recipe as tiles; a recipe opens `RecipeCookScreen`.
- **Every nutrition leaf is a read in the one reader** (`nutrition_reads.dart`:
  nutrient, stage, condition-diet, and the eight fasting pages — §35.6 paid).
  The old `NutrientDetailScreen`, `StageDetailScreen`,
  `ConditionDetailScreen`, `RecipeDetailScreen`, `FastingScreen` are
  unreached, kept for revert.
- **Talk** is `NutritionTalkBody`: the nutritionist's card → her profile and
  the real booking sheet; the violet `ExpertOptionsBlock` with its
  snackbar-only "Request this" is retired.
- The chart browser and craving page lose their violet (ink + hairline).

### 70.1 Owed
Photos for the stage / condition / nutrient / fasting reads (`dietstage_`,
`dietcond_`, `nutrient_`, `fasting_` ids) — the rows show icon wells until
then; `pvDoorTileReadImageId` needs those libraries. The same host
question as everywhere (§63.18): R2 first.

### 70.2 The second pass on the phone — 2026-09-20 evening
- **Rail-card marks** are the drawn `IntentMark`s Scans and Complications
  use (plate, nextStep, cuppedHands, calendarDay, askDoctor), not Material
  icons.
- **Recipes is a grid, not a rail.** The user asked "is a rail the right
  way to show recipes — yes or no". No: Crouton, Kitchen Stories,
  Woolworths and CREME show a library as a filterable photo grid led by
  one card. The tab is `RecipesGridBody` (Cook today lead → need chips →
  two across); `NutritionRecipeRail` is kept for revert; `kDietSurfaceRecipes`
  (the pushed library) has no tile any more because the tab IS it.
- **Photo cards** drop the white mist for a dark bottom gradient with
  white type (`PvDoorRailCard.imageUrl`).
- **A new hero** — two hands cupping cherry tomatoes (StockSnap, CC0),
  picked by eye from a contact sheet, in the read-image table as
  `nutrition_hero` so the mirror carries it. Is it safe? wears `cani_hero`
  (a market's crates) with the same door-hero geometry.
- **Seen and fixed:** dinner wore lunch's thali because 'roti' matched
  before 'paneer' (dish keys reordered, pinned in a test); the curd photo
  was a naivaidya offering (re-picked); the grid's second row gave up on
  Wikimedia's 429 after two retries (`CanIPhoto` now tries four times over
  a minute, jittered).
- **Charts & fasting** and the fasting list are the door's ordinary tool
  cards and read rows; photos for those reads stay owed (§70.1).

### 70.4 The deep dive — 2026-09-20 evening (MOBBIN-DISCOVERY §14)
Click by click at the user's ask ("recursive tree"). Built and walked:
- **Chart = plan** (`diet_chart_plan_screen.dart`): day strip → the plate's
  photo rows → "Make this my chart" (`NutritionDayStore.pinnedChartId`;
  Today follows) → Swaps / Go easy on at 16pt → doctor's note rule-left →
  six-tile day total. The boxed `DietChartScreen` is unreached, kept.
- **Today once**: "Your plate" + date; the Today / Tomorrow chips retired
  (kept commented); "From the … chart · See the week" under the plate.
- **Bigger questions** = five reads (`dietq_`, `PvDoorLibrary.dietQuestion`);
  `NutritionsScreen` unreached.
- **Recipes**: `RecipeMeal` + `RecipeKind` on the model; seven bucket tiles
  (`kRecipeBuckets`) over the need chips; **24 new recipes**
  (`nutrition_recipes_more.dart`) — 40 total.
- **A number under every meal** (`food_values.dart`, `test/food_values_test.dart`):
  glance on every row and card, `NutritionValuesGrid` on sheet / recipe /
  chart day / whole plate, the caveat on each, the reference once by the
  ticks in "roughly". No bars, no Σ.
- **Talk** lists every nutritionist from `mergedExperts()` (real first).
- No white mist: the meal sheet's and the Is it safe? found-sheet's fades
  removed (kept commented).

### 70.5 The second walk — gutters, the chart browser, View all (same evening)
- **The wall.** The door wrapped every inline tool in `pvDoorPad` and the
  three Nutrition bodies padded themselves too — text 36pt in, every rail
  clipped at the gutter. `kPvDoorSelfPaddedTools` (pv_door_screen.dart)
  lists tools that lay out their own gutter; the door leaves them alone.
  `test/pv_door_renders_test.dart` "every rail runs edge to edge" now
  fails any rail on any door whose box does not start at x=0. Checked: no
  other door had it.
- **"View all ›"** on a section heading: `PvDoorSection.moreSurfaceId` +
  `railMax`. The charts rail shows eight; View all opens the browser.
- **`DietChartBrowseScreen`** replaces the filter form (`DietChartsScreen`,
  unreached, kept): two edge-to-edge chip rails (diet · stage; condition ·
  region), full-width cards with a distinct dish photo each, the focus
  line, "3 days · Vegetarian · Second trimester", "Your chart" marked.
  MOBBIN §14 (Tempo, Blue Apron, HelloFresh, Blinkit).
- **`PvDoorFormat.plan`** — a chart's chip says Plan, not Tool (and not
  Guide, which would turn the rail into a list).
- "What she can do for you" → "What they can do for you".

### 70.8 The user's second walk — 2026-09-22 (MOBBIN-DISCOVERY §16)

His list, and what was done (`test/nutrition_second_pass_test.dart`):

1. **Today / What to eat now marks** → the sun (`sunMark`) and the cutlery
   (`forkMark`); six marks added (`sunMark forkMark chaiMark snackMark
   bowlMark sweetMark`).
2. **"From the Non-vegetarian chart"** → a card row: calendar mark in a well,
   THIS PLATE FOLLOWS / YOUR CHART eyebrow, the chart's name in Fraunces,
   "See the week".
3. + 6. **Cravings** → every craving page is a `PvRead` (`pvReadFromCraving`,
   nutrition_reads.dart) in the one reader: the verdict at her week as the
   opening callout (reassure / note / urgent by verdict), why · how to have
   it safely · when to skip · alternatives (only when not a plain yes) ·
   Make it at home (ingredients + numbered method) · the doctor line; the
   dish photo where the table has one. `CravingDetailScreen.build` is the
   facade, `buildClassic` kept. **Eating your way** is not a section any
   more: `NutritionPreferenceRow` (diet · region · "Tap to change") sits
   under the plate's heading on Today and under "What are you after?" on
   Recipes (his "how do I change it?"). The old section is a comment.
4. **Did you get…** → the reference paragraph is gone; each tick carries its
   number ("27 mg") under the name; the row is five `Expanded` cells across
   the gutter (it was a `FittedBox` → Row that shrank to content and huddled
   left); the unticked ring wears the need's own hue.
5. **Research** (§16 below): every nutrition app KEEPS the day — ‹ Today ›
   with a date, a week strip with ticks on logged days (MyFitnessPal), water
   as glasses per day with the day's litres (Yazio, Lifesum, Flo), a weekly
   bar of intake (Lifesum, Yazio's history). Our `NutritionDayStore` already
   keys ticks, water and swaps by date — the data IS a log; what is missing
   is the way back (yesterday) and the week view. **Not built; his call.**
7. **Swap** → two sheets. The row → `showMealSheet`: photo, slot + dish, a
   "Cook it" row where the library has the recipe (`recipeForMeal`), the
   six tiles ONCE, "On the plate" (each dish's share, from `matchMeal`),
   Swap + Not today. "Strong in" is gone from the sheet. Swap →
   `showSwapSheet`: "Instead of <dish>", the alternatives with photo, glance
   line and ±kcal, one tap swaps and the row washes with the tint
   (`PlateRow` is stateful; `didUpdateWidget` runs the flash). "Put it back"
   when swapped; the chart's ideas at the foot. The plate's total already
   followed swaps.
8. **What to eat now images** → nutrient / stage / condition / fasting reads
   take a dish photo from their own food lists (`_photoFromFoods`) until a
   picture is picked by eye. (§70.3 still owes the real set.)
9. **Recipes**: bucket tiles wear drawn marks in nine hues
   (`recipeBucketMark/Hue`; the photo path kept for revert); recipe cards'
   marks are bare, in the need's hue (no wells); `NutritionMarkLegend` above
   the grid; the recipe page is facts line → three marks with amounts →
   Ingredients → Method → six tiles + Did you know at the foot (the library:
   MFP, Lifesum, Yazio, HelloFresh, Noom all put one line of numbers under
   the title and the ingredients next); chart-day dishes open the meal
   sheet read-only; recipe-card names are 14.5 like the plate rows; Talk's
   four rows wear four hues. **Nutrient hues**: iron 344 · calcium 206 ·
   protein 26 · folate 104 · fibre 42 (`nutritionNeedHue`), everywhere.

**Open from his list:** "No items in it … the UI when no items are there" —
which screen? (the shopping list, the Recipes grid under a bucket + need,
or the cravings pattern line); the fasting rows' real photos; the water /
nutrition log decision (5).

### 70.7 What the user still wants to change on Nutrition
"A few changes on the Nutrition side" — to be given after the pregnancy
home (2026-09-21). Not yet specified.

### 70.6 Seven days, the week at a glance, pictorial nutrients — 2026-09-21
- **Every English chart has seven days** (`diet_chart_days_more.dart`, spliced
  into `kChartContent`; the Hindi chart keeps three). Every new line is in
  the food-values table (the test holds it). The plate rotates through
  seven now.
- **The week at a glance** (`_WeekGrid` on `DietChartPlanScreen`): days
  across, meals down, the dish's first words in each cell, the chosen day
  underlined, tap a column → that day. Scrolls under the gutter.
- **Pictorial nutrients:** `NutritionTopThree` — the three needs a dish is
  strongest in as the ticks' own marks with amounts, on the recipe page and
  the meal sheet; the text pills are gone (`nutritionGlance` strings kept
  in data for revert). `Recipe.fact` — one "Did you know" per recipe (41),
  a rule-left line under the marks.
- **Asked, awaiting his call:** the Day 1·2·3 chip strip on the plan screen
  duplicates the grid's tappable header — comment it out? The recipe grid
  cards could carry the three marks tiny instead of the kcal line.

**Owed from the dive**
- ~~Charts: three days → seven.~~ Done on the 21st (all but the Hindi chart).
- **Category illustrations** (Blinkit-style 3D, one style) — Higgsfield,
  seven images, on his go; the tiles take a URL.
- **Photos for 14 of the 24 new recipes** — the dish-word fallback holds;
  Openverse's general index was thin for them (10 picked).
- The values are estimates from a hand table; a dietician's review of
  `kFoodValues` before launch would be right.

### 70.3 The photos — mirrored; R2 is the launch blocker (see BACKEND-PATTERNS §16i)
`cdn.stocksnap.io` answers 403 to the phone (any user agent), so **196 of
357 photos had never drawn on a device** — read for a week as Wikimedia
throttling. Done today: every StockSnap id routes through Openverse's
proxy on the phone (a stopgap, 1000/day per IP, dies when
`kReadImageBase` is set); 62 food ids re-picked from StockSnap by eye plus
the two heroes; every credit's URL-encoded artist name decoded; **all 357
ids mirrored** to `C:\Users\sarth\Downloads\parentveda-images\` with
`manifest.json` + `CREDITS.txt` (`tools/read_images/fetch_read_images.py`,
resumable, `openverse_ids.json` sidecar). **Owed, and it blocks launch:**
the user uploads the folder to an R2 bucket (flat, ids as names), then
`kReadImageBase` = the bucket's public URL. Also owed: the door heroes
that are still Unsplash hotlinks (Scans, Complications and the parenting
doors) into the same table, so one switch covers all of them.

## 71.0 The search bar's flow — one template, every door — 2026-09-20

Built on Is it safe? after the user rejected "Yours" at the top of the page,
then lifted out at his ask. `lib/screens/doors/pv_live_search.dart`:
`PvLiveSearch` (three states, scroll-to-top on focus, `run`, `release`),
`PvLiveSearchScope` (Back twice), `PvLiveSearchWords` (the fade),
`PvLiveSearchField`, `pvLiveSearchRecallHeading`, `PvLiveSearchWayOn`,
`pvLiveSearchSheetMin`. Research: MOBBIN-DISCOVERY §13. Held by
`test/pv_live_search_test.dart` (the states; both consumers use the
template and grew no field of their own).

- **Is it safe?** runs on it: Yours gone from the top (kept for revert in
  `_welcome`), Asked most first, one *Saved answers* row at the foot,
  recents + saved in `_recall` under focus.
- **Every shell door** runs on it: the hero bar is live; results come from
  `pvSearchIndexOf(page)` (the door's tiles + its libraries) as
  `PvSearchHitRow`s; focus shows `PvSearchStore.recent`; under results
  "Search everywhere for …" (→ `PvSearchScreen` with `query`) and "Ask Veda
  about …". `PvSearchBar` + `openPvSearch(door:)` is a comment now.
- The Nutrition recipes joined the index as library hits
  (`_nutritionLibraries`) — they stopped being tiles when the Recipes tab
  became the grid, and "ragi" found nothing on the phone.
- Walked: Nutrition ("ragi" → two recipes, field at the top, Back twice →
  idle), Complications (Recent on focus), Is it safe? (recall + fade).

### 71.1 Owed
- The home's search (no bar there by decision, 2026-09-18) stays the pushed
  screen. If the home ever gets a bar, it takes this template.
- Is it safe?'s field and the shell's are the same widget now; the camera
  round beside the field (`!kCanIScanAtFoot`) is the one per-door
  `trailing` — nobody else uses it yet.
- A door with Saved of its own (only Is it safe? today) draws Saved in
  recall itself; if a second door grows saved items, lift that into the
  template too.

## 72.0 The pregnancy home takes the TTC fold — 2026-09-21

docs/PREG-HOME-HERO-PLAN.md, Tiers 1 and 2, BUILT (not yet walked — the
phone was on Nutrition with the user). Research: MOBBIN-DISCOVERY §15.

**Shared, lifted from TTC** (`lib/screens/v2/`): `PvDayStrip` (the sliding
disc, the today marker from the live clock, one-time centring, `markFor`
slot, `onPhoto` tone, `daysForward`) and `PvInsightRail` / `PvInsightTile`
/ `PvInsightMark` (`PvInsightArt` + baby · size · scan · question). TTC's
`_WeekStrip` and `_InsightTile` are wrappers over them; the originals are
commented out in ttc_home_v3.dart, kept for revert; `TtcInsightArt` is a
typedef. TTC's tests pass unchanged (`ttc_day_` keys kept).

**The pregnancy fold** (`home_v3_screen.dart`, `v2/v3_sections.dart`):
- The day strip ON the photograph, under the chrome row: white digits, a
  white disc with an ink digit; runs back to day one of the pregnancy (max
  six months) and **not forward** — her future weeks are the reveal, and a
  cell that cannot be selected is not drawn. A dot under a day she logged a
  symptom on.
- The hero's title is **"Week 14 · Day 3"**; the subtitle is the milestone
  alone ("Second trimester.") — the week no longer said twice. Under the
  title the size line, tappable (the size sheet); a white **"This week ›"**
  pill (Flo's Details) opens the week stack. The learning line left the
  photograph for the first insight card. The block sizes itself to its words
  with a 372 minimum (`ConstrainedBox` over `StackFit.passthrough`) instead
  of a fixed 340 — a long line wraps instead of striping.
- **My daily insights · Today/Yesterday/<date>** (`preg_daily_insights.dart`):
  *Log how today feels* (today only; gives way to *You logged nausea → what
  helps* → the symptom's own page) · *Coming up: a scan in ≤14 days* (the
  old "Coming up" row folded in; `V2ComingUp` on the home is a comment) ·
  *This week: learning to …* (→ the week stack) · *About the size of a
  guava* (→ the size sheet) · *Eat today: Iron* (first need not ticked →
  Nutrition) · *Is it safe? …* (one a day → the verdict) · *Read* (the
  week's first read). Every `PregInsightGo` resolved in one exhaustive
  switch. The whole page follows the selected date
  (`PregnancyController.dayForDate`); `previewDay` still wins.
- **The size sheet** (`v2/preg_size_sheet.dart`): WEEK n · the line · the
  toggle (Fruit & veg · Kitchen · Sweets, ink chips, persisted by
  `PregSizeSetStore`) · the baby's photo (the object's picture slot beside
  it, empty until §72.1) · LENGTH · WEIGHT tiles · What your baby is doing ·
  Did you know · the averages line ("your scan is the measure") · This week.
- **Three Indian sets, weeks 4–40** (`lib/data/preg_size_sets.dart`, 111
  entries): fruit & veg and kitchen compare by length; sweets by length to
  week 13 and **by weight from 14** ("About as heavy as a boondi laddoo") —
  no sweet is 40 cm long, but a 1 kg box of laddoos is a thing everyone has
  carried. The Western list stays as the per-entry fallback. weekContent.json
  week 5 had week 15's size pasted in ("Apple, 9.0 to 10.5 cm, 70 g") —
  fixed to a sesame seed / about 2 mm.
- `test/preg_home_fold_test.dart` (16): strip keyed per date, no future
  cell, the title once, the sheet + toggle, the heading follows the strip,
  the rail edge to edge, which cards a day earns, every week has all three
  comparisons with no repeats, dayForDate ↔ dateForDay.

### 72.0a Restructured to the TTC fold — 2026-09-22 (the user's walk)

"Trying to Conceive looks 1000 times better … right now the pregnancy
looks like randomly placed stuff." The full-bleed photograph hero
(`V3Hero`) is a comment now; `lib/screens/v2/v3_preg_hero.dart` is the fold:
`V3HeroField` behind (hue by trimester: 104 · 24 · 268) → [avatar · date of
the selected day · saved] → `PvDayStrip` (ink disc, six days ahead) → **the
baby in a 216dp disc** (Flo, Clue and Stardust all draw the baby in a disc
on a tinted field — MOBBIN §17) → "Week n · Day d" → the size line → an
ink "This week ›" pill → `V3PregSheet`, the white sheet the rest of the
page rides on (TTC's `_Sheet`, with the nav clearance inside it). No
greeting, no milestone line. The status bar is dark again.

The week sheet says more: milestone (heading) + week headline, what the
baby is doing, did-you-know, **For you this week** (physical changes,
emotional state, self-care tip from `WeekContent.mom`). The fruit · kitchen
· sweets toggle is **off** (`kPregSizeToggle`) until each entry has a
picture — "the images don't change"; the sets and the store stay.

**The baby art.** The earlier 2D set is in the repo: `lib/data/baby-images/
Week NN.jpeg` (37 files, 296×295, a soft-pink figure on pink, drawn to be
circle-clipped — see the old `assets/baby/README.md` in 0906564). It is
exactly the Flo/Clue disc treatment; the disc takes it as a 2× upscale when
the user says so. Structure first (done), images second (his order).

### 72.0b Flo's fold, exactly — 2026-09-22, second pass on the phone

"A profile photo put in between … two different things put together, not
one whole thing … do it exactly like Flo." So: the field is the art's own
peach (`kPregFieldHue` = 20) in every trimester; the figure is the 2D set,
`assets/baby2d/week_NN.png` (37, 560px, built by scratchpad/baby2d.py from
lib/data/baby-images with a radial alpha fade so the painted halo dissolves
into the field — no clip, no ring); "Week n / Day d" sit inside the glow at
the top and a white **Details** pill at its foot; no size line, no "This
week" pill (the insight card says the size). **Details** = `lib/screens/
preg_week_screen.dart` (`openPregWeek`, route `pregnancy/week`): the figure
big on the field, a back round, a chip strip of weeks across its foot
(locked weeks dimmed, `isLocked` — `unlockAllWeeks` ships true), then the
sheet: What happens in week n · the desk line (no named reviewer, so none
printed) · Length · Weight · About the size of · milestone + headline · what
the baby is doing · did you know · For you this week · the averages line.
The "This week" and "About the size of" cards open it. `showPregSizeSheet`
is opened by nothing (revert).

### 72.1 Owed
- The 2D set is in (§72.0b); the photographs in assets/baby/ are unused by
  the home now (the week stack still reads them).
- **Comparison pictures** (plan §8): cut-outs on white, one per entry (111),
  picked by eye, mirrored to R2 — fruit and kitchen as photos; sweets as
  renders when there are credits (none today). `PregSizeSheet.objectImageUrl`
  is the slot; a test should pin word ↔ image.
- **Tier 3** — the week chip strip + photo swipe on the week stack (not the
  home).
- **Parenting takes the skeleton** — day strip → the child's hero → insights
  → doors; the widgets are shared now, so it is data + one hero.
- Insight cards we do not have the content for: *Myth or fact* (three
  pregnancy reads carry a mythFact opening; not a rotation) and *Move* (no
  pregnancy movement set). Both wait on content, not code.
- The 'Eat today' card names the first need not ticked in plate order; it
  could weigh the week's nutrition theme (`WeekContent.nutrition`) instead.
- The user's own read of the sets — several late-week sweets are boxes and
  tins ("a 2 kg bag of sugar", "a Diwali hamper"); he may prune.

## 73.0 The Symptoms door — 2026-09-22, built and walked

Research: MOBBIN-DISCOVERY §18. `lib/data/doors/pv_door_symptoms.dart`,
`lib/data/symptoms/`, `lib/screens/symptoms/door/`,
`test/symptoms_door_test.dart` (14). Walked on the phone the same day.

**The door** (`pregnancy_symptoms`, card rail like Nutrition): Today ·
Is this normal? · By symptom · Your week · Talk.
- **Today** is the check-in, an inline tool: a day strip (`PvDayStrip`,
  edge to edge, a dot under a day she logged) so yesterday can be logged;
  COMMON IN WEEK n — eight discs picked by `symptomsCommonAt(week)` (peak
  weeks first, then the trimester, then the rest; stable); "Something else
  · n more" folds the rest by area; tap = mild, tap again = the severity
  sheet (mild / moderate / strong / not today after all); "What helps"
  draws one line per logged symptom and opens its read; an evening
  reminder switch (`symptoms_evening`, 20:30, off by default).
- **Is this normal?** is a tool, not a list of reads: ten questions in her
  words (`kNormalQuestions`), a verdict pill (usually fine / call today /
  call now) and, on every "now" row, a **Call** round that opens the
  dialler. Each row opens its read. The questions reach the door's search
  through `_symptomLibraries`.
- **By symptom** — 33 (`kSymptomLibrary` = the companion's 12 + 21 new),
  six areas with their own tint and mark; every tile carries `keywords`
  ("chakkar", "peshab") so the search finds it by the word she types —
  `PvDoorTile.keywords` is new and in the haystack.
- **Your week** — Clue's grid (a row per symptom, a dot per day sized by
  strength), THE PATTERN as counts only, Send my week (the note as it will
  read → Share / Copy).
- **Talk** — the pinned five-line "call now" flag, then the consult tile.
- The store learned days: `setOn`, `unlogOn`, `severityOn`, `weekCounts`,
  `daysLoggedInWeek`; every write is the usual local-first fire-and-forget.
- 26 drawn marks added to `IntentMark` for the door and its symptoms.

**Clinical rules held:** nothing is computed about her (the week counts
days; no trend, no score); the urgent five are fixed and never
personalised; every read ends on the disclaimer; the Call round dials an
empty dialler because the app must never guess her hospital's number.

### 73.1 Owed
- **The door's own hero photograph** — it borrows the back-pain read's.
- **A care-circle phone number** for the Call round (today it opens the
  dialler empty). Lives with the family model (§61), not this door.
- **The symptom reads have no photo** — the reader shows the grey
  placeholder. One photo per area (six) would do; per symptom is 33.
- ~~**The marks' hand**~~ — DONE 2026-09-22 (§73.2).
- **The date strip on the check-in** — kept so yesterday can be logged
  (Huckleberry); the user asked why it is there. One line to remove if he
  would rather Today logs today only.
- Water / nutrition week view (§70.8) — still a decision, not a build.

### 73.2 The check-in draws in TTC's hand — 2026-09-22

The user, walking the door: *"in trying to conceive we have those face
designs that have been drawn — can we do something for this as well?"*
Decided yes, on the reasoning in `ttc_mood_face.dart`: the same woman
makes the same gesture a stage earlier, and two hands for one gesture read
as two apps.

- `TtcGlyph` grew a `// ---- pregnancy` group of **23** line glyphs (flame,
  knot, spoon, bowlSlash, spiral, breath, breathSlash, drip, tingle, veins,
  sideAche, bolt, jitter, cloudStar, scratch, tooth, heat, scent,
  dropRepeat, puff, bounce, basinDown, tighten), drawn under TTC's two
  rules — objects and places, never anatomy, never a body. `TtcGlyphMark`
  paints one by name. **9 reuse** a TTC shape (queasy, headAche, battery,
  expand, spine, bellyAche, moonEye, spots, pelvis); mood swings wears the
  swings **face**, the only face. 9 + 23 + 1 = the 33.
- The door keys its own ids (`symptomGlyphFor`, `symptomMoodFor`,
  `symptomLineMark` in `symptoms_widgets.dart`); the filled `symptomMark`
  set stays for the door's cards and as the revert (the old lines are
  comments at each call site).
- `test/symptoms_door_test.dart` holds TTC's rule: no symptom may fall to
  the filled mark, no two share a glyph, only the feeling has a face, and
  every mark paints at 18 and 34.
- Checked by eye on a rendered contact sheet (no phone — the other
  terminal had it); four were redrawn on sight: swelling read as an eye,
  vivid dreams as a crown, hiccups as a dome, the spoon as a key.
- **Walked on the phone** the same day, with the marks reading at 34pt and
  18pt. Three things came out of that walk:
  * **Tap toggles.** The user: *"tapping again should un-select it."* The
    second tap opened the strength sheet, so clearing a mis-tap cost a sheet
    and a read — a check-in has to be as cheap to undo as to make. Now tap =
    on/off, **hold** = how strong (and the sheet's "Not today after all"
    only shows for something already logged).
  * **The home's "You logged" cards** both wore the generic symptom art,
    which also ran under a long value ("Constipation"). `PvInsightTile` took
    an optional `artWidget`, drawn **top-right** (the painted set is anchored
    bottom-right, which is where the value is); the pregnancy rail passes the
    symptom's own drawn mark.
  * **A real bug behind it:** that card looked the symptom up in `kSymptoms`
    — the old 12-strong seed list — while the door logs from the 33-strong
    library, so anything she logged from the other 21 produced **no card at
    all**, silently. Now `symptomById`. The general shape: two lists for one
    concept, one of them a subset, and the lookup on the small one fails by
    omission, never by error.
- **Owed:** the area *headings* and door cards still
  wear the filled marks — that is the intended split (cards are the door's
  chrome; the check-in is hers), not a leftover.

### 73.3 The door says each thing once — 2026-09-22, the user's second walk

Four notes off the phone, all of them the same shape: **a surface with two
homes**.

- **"Is this normal?" said the ten twice.** The tab's tool drew the ten
  questions; under it, "The five to call about" opened
  `SymptomsNormalScreen` — the same ten rows. The user: *"you have listed a
  lot of things under 'is this normal?', then under 'if it is one of these,
  call — do not read' you have listed the same ones... we need to be a
  little bit cautious about this section as it's sensitive."* Right on both
  counts: on a safety tab, a list that appears twice teaches her to skim it.
  Now the five have ONE home (the pinned flag on Talk), the ten are the
  answers, and the section under them is what neither covers — **"What to
  say when you call"** (`symptoms/calling`): the six things the person
  answering the phone asks, in order. Stationery, not triage — the same six
  whatever she is calling about, which is why it is safe to print.
- **"Send my week" had three homes** (Today, Your week, Talk). Now one, on
  Your week. Today's section is gone entirely: the check-in IS that tab.
- **By symptom was thirty-three identical brown documents.** Every row wore
  its format's mark (`pageMark`), because that is the engine's rule. A tile
  may now carry its own mark — `pvDoorTileArt` in the ROUTER, so the door
  engine still knows nothing about symptoms — and each row wears the
  symptom's own drawn mark.
- **The reads opened on a generic band.** The reader's default head is the
  read hue plus a large white book, so all thirty-three opened the same.
  `symptomReadHero` gives each one its mark, large, on its area's colour.
  ⚠️ This is the ANSWER to "we need images", not a placeholder for one:
  symptom photography is stock-fake or clinical, and a drawn mark is both
  individual and honest.
- **Your week lost its wall.** "The pattern" sat in a lavender rounded
  rectangle — *"the whole purple background thing with a rectangle soft
  edges is happening"*. It is now a caption under a hairline rule. The grid
  itself: the DATE under each weekday letter (a week she can point at),
  today as an ink disc (the day strip's own language), each day's dot on a
  hairline track so a sparse week still reads as seven days, and a key for
  the three dot sizes (a `Wrap`, not a `Row` — three words overflow 360dp).

**Not done, and it needs the device:** none of this has been walked. The
build was blocked at the time by another terminal's in-flight edit to
`lib/screens/learn/pv_learn_screen.dart` (whole-program compile), so the
visual check is owed.

### 69.9 Prepare and Learn are two doors to one room

`PrepareHubScreen` (Tools → Prepare) holds four tiles and three of them
are now Learn's: *Courses & Cohorts* is a facade over `PvLearnScreen`,
*Birthing Classes* is the offering `course_birthprep`, and the paid half
of *Yoga* is the class packs. The fourth, *Nutrition*, has had its own
door on the home since the nutrition pass. So Tools now shows **Learn**
and **Prepare** side by side and they overlap almost entirely.

Retiring Prepare's tile is one line — except that `YogaHomeScreen` (the
recorded yoga library, not just the paid classes) is reachable in
pregnancy ONLY from that hub, and the *Yoga & fitness* door opens the
bracket rather than the library. So the order is: give the library a door
of its own, then retire Prepare's tile and keep the hub for revert. Not
done while the doors are another terminal's working tree.

### 69.10 The learn covers are drawn, and what would make them photographs

The Unsplash-by-topic map (§69.7's leftover) is gone. On the phone it put
ONE photograph — a woman on a sofa with two toddlers and a tablet — on
*The Complete Pregnancy Guide*, *Birth Confidence Masterclass*, *Birth
Prep Essentials* and *Birth-Ready Bootcamp*, one under the other in a
single scroll, and a second, of students at laptops, on both cohorts.
Wrong subject AND structurally repeating: keying a picture to a topic
WORD means every programme sharing a topic shares the picture, and the
catalogue is built out of a handful of topics on purpose.

Every cover is now an `IntentMark` on a field in the programme's hue
(`pv_learn_images.dart`, `PvLearnDrawnCover`) — the same drawn family the
doors and the hubs use, reused by meaning, which is that family's own
rule.

**The seam for real photographs is live and empty**: `kPvLearnCovers`,
keyed by programme id, checked before anything else, and `PvLearnCover`
falls back to the drawn cover if the URL 404s. Filling it needs a library
to pick from, and on 2026-09-22 there was not one:

| Source | Why not |
|---|---|
| Wikimedia Commons | Licence fine, pictures wrong. These subjects return ethnographic archive photographs, a 1907 oil painting and an Egyptian ostracon. It is an encyclopaedia's library — which is exactly why it dresses the store's OBJECTS and the recipe dishes so well. |
| Openverse | Amateur Flickr snapshots (a poster on a wall, a screen grab with a "click to read more" banner). Filtered to licences allowing COMMERCIAL use it returns sixteen results for "prenatal yoga", nine of them one red-carpet launch. |
| Unsplash | Right licence, right pictures, search needs an API key — and choosing ids without SEEING them is the mistake being undone here. |

So: **a free Unsplash access key, or our own photographs, fills the map in
an afternoon** and every card and hero picks them up with no other change.

### 69.11 The review section — rebuilt, and what the reviews table owes it

One block now, shared: `PvReviewBlock` / `PvReviewRail`
(`lib/screens/products/pv_review_block.dart`), on the offering page and on
the product page. Researched on Mobbin at the user's ask. What was taken,
and what was deliberately not:

| Seen | Ours |
|---|---|
| Preply · Coursera · Meetup — a rail of quote cards | **Taken.** A testimonial should read as a voice, so the quote leads in Newsreader under a quote mark, not as a bordered box in a stack. |
| Nobody — who the reviewer was at the time | **Ours.** Every review already carries `who` / `context` ("28 weeks", "delivered Apr 2025"). Promoted out of the grey byline onto its own line. A woman reading a birth course's reviews is asking whether the writer was anything like her. |
| Zocdoc — named sub-ratings (bedside manner 4.9, wait time 4.5) | **Owed.** Needs a per-dimension aggregate we do not hold. |
| Urban Company — word-bands, Excellent (138) / Good (24) | **Owed.** Needs per-star counts. |
| Etsy · Temu — counted topic chips you can filter by | **Owed.** Needs tags on every review ever left. |
| Ulta — PROS / CONS as counted word lists | **Owed.** Same. |

The four owed all need the **reviews table**. `pv_reviews_screen.dart`
already refused distribution bars for this reason and wrote down why —
"bars drawn from the handful of reviews we show would look like a
measurement of the whole" — and that holds. When the table lands, the
bands and the chips are the first thing to build on it, in that order.

Also from the same walk: the offering page's FAQ splashed a rectangular
ripple over a rounded card and opened with no animation; it now has a
shaped ink-grey splash, `AnimatedSize` and one rotating chevron. And the
commit bar's left column stopped being a price slot once the price is
paid — it reads progress ("4 lessons / none watched yet", "2 of 4 /
lessons watched") instead of "Yours / yours to keep", which said one fact
three times counting the hero's tag.

## 74.0 Fitness & yoga — the next door, brief written 2026-09-22

Material only, nothing built. `docs/FITNESS-DOOR-BRIEF.md`; research in
MOBBIN-DISCOVERY §19.

**Why this one:** ten pregnancy brackets, eight doors. The two without are
*Is it safe?* and *Fitness & yoga*, and Is it safe? already has a
purpose-built search-first screen (`can_i_door.dart`, §10) that tabs would
spoil — it is deliberately not a `PvDoorPage`. So Fitness is the gap.

**What exists and must not be rebuilt:** 27 month-tagged `YogaSession`s
(bilingual, shipped Devanagari — never strip); `can_i_data`'s activity
verdicts for walking, swimming, cycling, running, dancing, gym, trekking and
lifting, each with per-trimester notes; the Kegel tool.

**Proposed:** five tabs — Today (one practice for her month, derived;
the `_kCurrentMonth = 7` screen turned out to be dead code — its only call
site is commented out — so the live surface the door replaces is
`YogaHomeScreen` with `kPregnancyYogaCategories`), Practise (chips over rows), Is it safe
to…? (the eight verdicts rendered in place, reading `can_i_data`, never
restated), Pelvic floor (the Kegel tool + reads), Talk (the stop-and-call flag
for movement + consult).

**Three questions for the user before any build:**
1. Video, or a no-video list-plus-timer player? (Recommendation: no video —
   the current screen already plays into a placeholder, and shooting 27
   prenatal sessions is a production project.)
2. Pose art: drawn marks in the TTC/Symptoms hand, or photographs?
3. Should "how are you today?" be asked here, or DERIVED from the Symptoms
   check-in ("derive, never ask")?

**Owed content if it goes ahead:** step lists for 27 sessions, an `avoid`
line per session, pose art, three pelvic-floor reads.

## 75.0 The Recipes tab takes Blinkit's shape — 2026-09-22

Research and the full adopted/declined list: MOBBIN-DISCOVERY §20. Built, not
walked.

- Bucket tiles: horizontal rail → **3-across grid**, all nine visible.
- `RecipeCard` takes an optional `recipeId` and then carries a **save heart**
  on its photo, wired to `SavedStore` — which closed a real wiring gap:
  `SavedKind.recipe` and the Saved screen's Recipes section existed with no
  way to put anything in them.
- A **"The ones you kept"** rail above the buckets, rendered only when she has
  saved something.

### 75.1 Done in the second pass (same day, after the user read the declines)
- **`Recipe.minutes`, required**, on all 41 recipes across both recipe files
  (the required field is what found the second file). Drawn on the card with
  a clock, under the title.
- **The marks moved onto the photo** as white discs, Blinkit's chip position.
- **Per-ingredient Add** on the recipe page, feeding the shopping list that
  already existed; the whole-recipe button remains.
- **Four dish photographs re-picked by eye** and re-mirrored to R2 — see
  MOBBIN §20a for the table and for why the URL table alone was not enough.

### 75.2 Still owed
- **"Cook in minutes"** as its own section, and a *Quick* chip — now possible
  since every recipe has a time.
- **Photo quality, not correctness.** The four are right; Commons has little
  styled photography of regional Indian home food. A shoot or a licensed set
  is the only way past that ceiling.
- `nut_sambar` still leads with idli, and the `kOpenverseIds` entry for
  `nut_shukto` is now stale (harmless — the proxy only fires for
  stocksnap/flickr URLs).
- A walk on the phone.

### 73.4 The phone walk, 2026-09-23 — photos for every symptom, and four fixes

Walked on the user's S21 FE. The Symptoms cleanup (0565ed5) and the Recipes
rework (e9d8ac8) both hold on the phone. What the walk found, all fixed:

- **By symptom gets real photographs.** The user: *"we should be using real
  images of course."* Every read shows **the thing that helps, never her
  body** — ginger tea for nausea, a glass of milk for heartburn, a knitted
  hot-water bottle for the back, a moon lamp for sleep, a stopwatch for
  timing tightenings, a C-shaped pillow for the pelvis. Photographs of
  pregnant bodies are stock-fake or clinical, and Commons does objects well
  and people badly. 31 picked by eye from contact sheets, at the SQUARE crop
  a row actually shows (three first picks failed there and were swapped),
  approved by the user, licences checked (CC BY / BY-SA / CC0 / public
  domain — nothing NC or ND), credited, mirrored to R2 and read back live.
  **Nosebleeds and round ligament keep their drawn mark** — nothing on
  Commons was fit (toilet rolls; people carrying mats), and the fallback is
  the design, not a gap.
  - The wiring was one line: rows already show a photo whenever
    `pvDoorTileReadImageId` names one, so `PvDoorLibrary.symptom` now answers
    `symptom_<id>`. The header gives way to the reader's own photo head,
    which prints the credit.
- **The Jain kadhi khichdi showed a bowl of raw onion** beside a dish "made
  without onion or garlic" — the shared `nut_khichdi` photo. Replaced with
  plain khichdi on a steel thali. The prettier candidate had potato in it,
  which Jain cooking also avoids: the same mistake in a new form.
  ⚠️ **Fixing the shared photo changed nothing on the card, first time
  round.** `nutritionRecipePhoto` checks the recipe's OWN `nut_r_<id>` before
  the shared `nut_<dish>`, and the Jain recipe had its own ("Kadhi and
  Khichdi of Bardoli", the onion one). Caught only because the phone was
  looked at after the fix. Both now point at the approved photo. The same
  precedence explains yesterday's four dish fixes: they corrected charts and
  plates, while the recipe cards already had right photos of their own. The
  general trap: when a lookup has a more specific key that wins, a fix to the
  general key is invisible wherever the specific one exists — check what the
  screen RESOLVES, not what you edited.
- **"0.8 tsp mustard seeds."** The servings stepper leaked decimals.
  `kitchenQty` rounds each unit to the finest step a kitchen has — spoons
  and cups to quarters (¾ tsp), pieces to halves, grams to 5/10/25 — and a
  test runs every ingredient through 1–6 servings for a stray decimal point.
- **Seven buckets in threes** left Soups alone on a row, with a band of white
  under every row. Four across, and the square gives way before the labels.
- **"What to say when you call" wore the tool format's sliders.** A drawn
  phone (`IntentMark.phoneMark`), through `pvDoorTileMark` — the card twin
  of the row hook, so the door engine still knows nothing about symptoms.
- **Short tool screens showed the tinted field under the sheet.** The
  sheet's full-screen minimum was removed on 2026-09-19 because a DOOR's
  ground is white; a TOOL paints a tinted field under everything, so there
  the gap showed. `PvDoorToolScaffold` fills only the space its content
  leaves with the ground — no extra scroll on a short screen, none lost on
  a long one. Fixes every tool screen, not one.

**On the user's phone, cleaned up:** the symptoms logged during the walk
were removed from his real log. The evening reminder was found ON and left
alone — nobody knows who switched it on.


---

## 76.0 Garbh Sanskar — one "today", and the same shape as Scans — 2026-09-23, built and walked

The user: *"The home section is for like what you can do today. The door is
basically like this is the whole library for you."* And, mid-build: *"make it
consistent as the structural situation as well, like the way we have our
other doors like scans and tests."*

**Done:**

- **One drawing of today's practice.** `GarbhTodayPractice`
  (`lib/screens/garbh/garbh_today_practice.dart`) renders on the pregnancy
  home AND as the door's Today tab. Before: the home drew today's real picks
  and opened the OLD standalone pillar screens; the door drew four generic
  cards whose text never changed. Two copies drift; one cannot.
  `test/garbh_symmetry_test.dart` holds both call sites.
- **A pillar tap opens the door at its tab** — from the home a push, inside
  the door a tab switch (`PvDoorTabSwitch`, an InheritedWidget the door
  offers, so the component never needs to know where it lives).
- **"About" on the home opens the door.** It opened the old `GarbhScreen`
  library — with the streak card the brief forbids — under a comment saying
  it opened the door.
- **Pillar photographs mirrored and credited** (`garbh_pillar_*`): Shravan
  and Samvad kept from Unsplash (were hotlinked, no licence line); Buddhi and
  Kriya replaced by eye — puzzle pieces (CC0) and a lit diya (CC BY-SA 4.0).
- **Today's ticks travel with her account** (`GarbhStore.cloudData` now
  carries `done` + `doneDate`). Still no streak anywhere on the component.
- **Structure = the finished doors.** On the card rail across the hero
  (`kPvDoorRailDoors`), a drawn mark on every tab (sun, headphones, page,
  lotus, book), Today is the TAB'S TOOL like Symptoms' check-in and
  Nutrition's plate, and a section of only tracks now draws as ROWS with
  the minutes and a play mark — Oura's Sleep list on Mobbin, and the row
  Scans already uses for reads (`pvDoorSectionIsRows`). Test: every tab on
  Scans, Symptoms, Nutrition, Complications and Garbh wears a mark.

**Owed:**

- **§76.1 Pictures for 27 tiles.** Every Garbh tile now has a picture key —
  its surface id with `/` as `_` (`garbh_listen_rain`,
  `garbh_play_sudoku`…; `pvDoorGarbhPhotoKey`). Absent a picture, the tile
  draws its format mark, as before. ChatGPT prompts handed to the user
  2026-09-23; when the PNGs land: resize, mirror to R2, add to
  `kReadImageUrls`/credits.
- **§76.2 No Talk tab — decided, not forgotten.** The four clinical doors
  end on Talk (flag, then people). Garbh has no expert to book — none in the
  booking data — and the brief puts the STOP IF flag on For you, beside the
  breath practices it is about. A Talk tab with only a generic doctor card
  would be a tab for symmetry's sake. Revisit if a Garbh teacher joins.
- **§76.3 "Today's pick" on Listen and Talk and read is still generic** —
  "Today's raga", "Today's passage to read aloud" — while Today names
  "Baby Bonding Raga". Correct destinations, wrong words; wants the pick's
  own title (a dynamic tile, or an inline section).
- **§76.4 `GarbhJournalStore` is phone-only** (entries, rituals, japa,
  recordings). Text parts can sync through `CloudSyncedStore`; the voice
  recordings need a private storage bucket — the user's call.

---

## 77.0 My Journal — redrawn to be opened, and synced to every phone — 2026-09-23

The user: *"I was never the fan of the designs that we have for the journal"*,
then, on the first clean redraw: *"not something she would be like, let's
open it… it should be beautiful."* And: *"the whole record is maintained not
locally but wherever she logs in, on whichever device."*

**Built** (`lib/screens/journal/pv_journal_screen.dart`; the old screen is
`JournalScreenClassic`, still the book views; `JournalScreen` is exported
under the old name, so every caller opens the new one):

- **A cover** — her newest photo (a memory's or a bump photo), else a painting
  per trimester, with "Dear little one," over it; parallax as it scrolls.
- **Forty weeks** — 40 dots filling on open: ink where she kept something,
  a ring on this week, "26 weeks until you meet". Not a streak: no gaps
  counted, no total but the weeks until the birth.
- **This week's question** — `lib/data/journal_prompts.dart`, 30 questions a
  grown child would want answered, banded by week; Write it opens the compose
  screen with the question as the entry's name; Say it records; another
  question turns in.
- **Weeks as pages** — a week with a photo is a photo card (stoic.'s
  Journey); rows otherwise (5 Minute Journal's date block, a serif, the big
  photo); a photo flies into the entry page (Hero); weeks rise in turn.
- **An entry opens to be read** — photo pager, date, title, words, voice
  notes, place; Edit and Delete on the page (was tap = edit, long-press =
  delete, no way to just read).
- **One way to write a memory** — the home's "Add a memory" opened a
  text-only sheet; it now opens the journal's compose screen.
- **Paper ground** (`kJournalPaper`, #FAF7F2) — the one page that is not
  white, on purpose; one constant to revert.

**Sync fixed, both journals** (`lib/services/journal_sync.dart`, BACKEND-
PATTERNS §16l): place now reaches the cloud (migration **0091 — the user must
run it**; the app tolerates it not being run yet); newer-wins merge instead of
cloud-wins; tombstones so an offline delete is not resurrected; a seen-ids set
so a delete on one phone is not undone by another. The father's store also
now removes his uploaded photos when an entry is deleted.

**Owed:**

- **§77.1 Paintings** for the cover (`journal_cover_t1..3`, only when she has
  no photo) and the question card (`journal_question_t1..3`) — ChatGPT
  prompts handed over 2026-09-23. The drawn sky stands in until then.
- **§77.2 The book views** ("Read it as a book", "With your partner's
  entries") are still the old screen's purple booklet. Next pass.
- **§77.3 The compose screen** is base UI but plain; it could take the
  journal's paper and serif.
- **§77.4 First sync after upgrading** has no seen-ids yet, so an entry
  deleted on another phone BEFORE this build can come back once. Cannot be
  told apart from a new one without that history.

## 78.0 TTC warmth pass — every word in the stage, rewritten warm and simple — 2026-09-26

Every user-facing English string in the TTC V3 stage (141 files, ~111k words) was rewritten to
`docs/TTC-VOICE.md` (the user approved it: "simple… understood in one go, don't flex your English").
Facts, numbers, doses, warnings, keys and the Hindi side were held; the free competitor check
(8-word overlap vs the captured Flo and What to Expect text) is 0 on every file. The made-up
reviewer names are gone from TTC. The ledger is `docs/TTC-WARMTH-PASS.md`. Owed:

- **§78.1 Expert sign-off.** The app now shows "REVIEWED BY" and a tick next to REAL roster
  names (Dr Ruchika Sood 48 pieces, Parmeshwari 7, Akanksha Srivastava 4, Dr Kajal Sharma 2).
  True only once each reads her list: `docs/TTC-EXPERT-SIGNOFF.md`. His side (10 reads) says
  "By ParentVeda team", no tick, because the roster has no male-fertility specialist.
  Dr Ruchika Sood is not in `kExperts`, so her byline may not open a profile.
- **§78.2 The fertile window's length — RESOLVED 2026-09-26.** It disagreed across the stage
  (reads: six days ending ON ovulation; chapter data and window screen: ending the day AFTER;
  the window glossary: seven days). The user chose the standard definition. Every explanation
  now says six days ending on ovulation day (both language sides where the fact was stated).
  The tool still shades seven days (`ttcWindowClosesAfterOvulation = 1`, unchanged by
  decision: no tool changes in this pass); the words now say the extra day is a margin
  because our ovulation date is an estimate.
- **§78.1a** The sign-off list is regenerated from code by `tools/ttc_expert_signoff.py`
  and has Sent / Signed off columns. Nothing is sent yet; the user will send it later.
- **§78.3 Tool behaviour found while rewriting** (notes only, nothing changed):
  `docs/TTC-TOOLS-UX-NOTES.md`, "Start here" — two symptom loggers sharing saved keys, the
  records Save silently doing nothing, vaccine "Had it" saving today's date, supplements that
  cannot be typed and a CoQ10 name clash between partners, made-up product scores and badges,
  the language button offering Devanagari and giving Latin Hindi, duplicated PCOS and
  "get help" tools, the trigger picker saving 9 pm when dismissed.
- **§78.4 Same made-up names outside TTC:** `lib/data/community_data.dart`,
  `lib/data/mind_mood_data.dart` and several pregnancy reads still carry them.
- **§78.5 Hindi drift.** Only the English side was rewritten; the Latin-script Hindi
  sides of `_p`/`_t` pairs still carry the old meaning word for word (two factual fixes made on
  both sides: the trigger reminder timing, and the fertile window ending on ovulation day).

## 79.0 TTC gap plan — the golden gap analysis built into the stage — 2026-09-26

The TTC gap analysis v2 (Flo + What to Expect vs ParentVeda) is the source of truth for the TTC stage, on the
user's decision. Plan, decisions and full execution log: `docs/TTC-GAP-PLAN.md`. Built this session: 70 new reads
(122 total, every read with a "short answer", question headings, paragraphs of 50 words or fewer), new door tabs
(Waiting and testing, Sex and closeness, Hard days, Meal plan, Age and second baby), two new doors (Body and cycle;
Trying, but not pregnant yet?), all nine doors in the new door design (`TtcDoorScreen`, mirrored from the pregnancy
engine, pregnancy untouched), the tabs Today · Learn · Products · Tools · You, five messages + three scripted chats,
logging additions, partner fixes, the shared-phone switch, phase-aware daily cards. Community hidden for launch.
Owed:

- **§79.1 Hero photos** for the two new doors (`docs/DOOR-CONTENT-OWED.md`).
- **§79.2 Notification tap** does not open the message's destination (NotificationService has no tap handler).
- **§79.3 Facts to confirm by the named experts** (listed per helper in the gap-plan log): ART and Surrogacy Act
  details, egg-freezing costs, letrozole status in India, the NICE age table, NFHS-5 figures, helpline numbers
  (1091 varies by state), lab and strip prices, the ibuprofen-around-ovulation tip, Suraksha/ICTC naming.
- **§79.4 Setup screens**: the PDF's onboarding feedback is NOTED ONLY in `docs/TTC-GAP-PLAN.md` §9 (the user
  handles it separately), plus carrying the onboarding reminders choice into `TtcMessagesStore.setPhoneOn`.
- **§79.5 Community** (held back): its PDF items (honest counts, votable poll, two-week-wait and over-35 rooms,
  pinned threads, live thread on the home) wait for the release decision; every entry point is commented, not
  deleted.
- **§79.6 Faint-line drawing** (a design asset) for `ttc_read_faint_line`.
- **§79.7 Six videos** the PDF names (fertile window, when to test, stress, his side, PCOS, when to see someone):
  the placeholder tiles stay until the films are uploaded.
- **§79.8 Treatment rounds** (built 2026-09-26, `docs/TTC-TREATMENT-FLOW.md`): round model in the `ttc_treatment`
  blob, clinic mode only on real clinic dates from the first treatment date, check-ins never close a round on their
  own, announcements + 7-day undo, start/plan/result screens, calendar bands, treatment messages, IVF door panels,
  pregnancy dated from the transfer (`DueDateSource.ivfTransfer`), a round line on his side. Owed: **B11 Ask Veda**
  (send the treatment step; two-repo change, needs `C:\Projects\parentveda-askveda`), **B12 partner clinics**
  (later), and Dr Surbhi Sharma's check of the "(confirm)" timings and of IUI dating when no period is logged.
- **§79.9 Date consistency** (built 2026-09-26): every date surface reads `ttcDayContext`
  (`lib/ttc/ttc_day_context.dart`), proven by `test/ttc_date_consistency_test.dart`. Decided: ownership = real clinic
  dates; first cycle predicts from her stated length else 28 (rough guess); irregular = spread over 7 days
  (`kTtcIrregularSpreadDays`); earlier cycles show look-back windows. Owed: syncing her stated cycle length (local
  only; needs a `ttc_journeys` column); STILL-OPEN §30 is effectively resolved by the ownership rule.
- **§79.10 Shared 360dp overflows found, not fixed** (all stages): the You screen's journey row
  (`pv_you_screen.dart:438`), the store's honesty strip (`pv_store_screen.dart:552`) and the hero band
  (`pv_hero_band.dart:289`, `:342`).
- **§79.11 Doors with six tabs** (four doors, IVF included): a later call on whether to trim; hero photos for all
  nine doors are coming from the user (prompts given 2026-09-26).
- **§79.12 Ask Veda B11 + TTC content pool — CODE DONE 2026-09-27, live refresh waits on the user.** Both repos:
  the app sends `treatment_step` (`ttcHomeRoundPhaseOn(...).name`, never from the partner) and the service
  (`parentveda-askveda/app/prompt.py` `_TREATMENT_STEPS`) makes the opener step-aware: *not pregnant* through
  collection and between rounds, *does not know yet* from transfer to test day, *a positive blood test* at result.
  Cache key gains the step (`ttc:<chapter>:<path>:<ownership>:<step|->`). The export (`tool/export_ttc_corpus.dart`)
  now adds the 134 reads (`ttcread_`), the phase and treatment cards (`ttcinsight_`) and door prose (`ttcdoor_`);
  the screen opens each, and "Hide sex and intimacy content" also filters Ask Veda's cards. **Owed:** (a) the user's
  go-ahead for the live Supabase steps (delete old `trying` rows and chunks, import, embed, clear `veda_cache`
  `ttc:%`, smoke test); (b) **Dr Surbhi Sharma to review the three openers and closers** in `prompt.py` (the wait
  says symptoms are mostly the medicines and no home test before the blood test; the result says very early, no
  odds, her clinic plans the next tests).
  - **LIVE REFRESH DONE 2026-09-27** (user's go-ahead): 324 old `trying` rows and chunks deleted, 530 imported,
    1834 chunks embedded, `ttc:%` cache cleared (script: session scratchpad `refresh_ttc_pool.py`). The
    embedding model's cache had lost its tokenizer files and Hugging Face (and hf-mirror) are blocked by the ISP;
    restored from Qdrant's GCS tarball (`tokenizer.json`/`vocab.txt` byte-identical to HF, `model_max_length` set
    to HF's 512), verified cosine 1.0 against 8 stored vectors. Run ingest with `HF_HUB_OFFLINE=1`.
  - **§79.12a GROQ RETIRED `llama-3.1-8b-instant`** (found in the smoke test): every Ask Veda answer, all stages,
    fails with model_not_found until `LLM_MODEL` changes. Tested `openai/gpt-oss-20b` (process override only):
    format followed, answers grounded, new `ttcread_` cards returned. Decision owed: which model; then update
    `app/config.py` default and the cost constants in `app/answer.py` (priced for the old model).
  - **§79.12b Retrieval rank:** "cramps after embryo transfer" gets NO_ANSWER although the two-week-wait read's
    FAQ answers it: that chunk ranks 10th and the model reads the top 6 (`answer_context_k`). Options: raise
    `answer_context_k` (shared by all stages), or export each FAQ as its own question-shaped doc.

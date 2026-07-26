# Still Open

Everything parked, undecided, or half-built — in one place, so nothing gets
quietly dropped between sessions.

**Last updated:** 2026-07-27

## How to use this file

* **Add the day it appears.** A thing you decide to leave for later is an open
  point at that moment, not when you remember it.
* **Never delete an entry — move it to §9 Closed** with what was decided and
  when. Half the value here is being able to see why something was left.
* Each entry says what is *blocked* by it. Most block nothing today; a few
  block launch or block money moving, and those are marked.
* `docs/ADMIN-PANEL.md` is the sibling file: it collects everything that needs
  the Directus panel. Where an item lives in both, this file links there rather
  than repeating it.

**Blocking launch:** §1.1, §1.2, §1.3
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

## 4.4 Not built, deliberately

A/B variants of visibility rules · shared/tiered commission (flat basis points
only) · partner brand colour and contact details · materialized views · audit
logging · versioning · Realtime.

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

# 9. Closed

Kept so the reasoning survives.

| Item | Outcome | When |
|---|---|---|
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

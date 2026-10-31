# Partner Editions — MASTER PLAN

> Written 2026-10-29. **Start every session here:** take the next unticked phase in the table, then read only that app's plan:
> [DOCTOR-APP.md](DOCTOR-APP.md) (D-phases) · [PARTNERS-APP.md](PARTNERS-APP.md) (P-phases). Parent-app phases (A1, A2) are at the bottom of this file and run LAST.
> One phase = one short chat.

## Why
Doctors, IVF centres, schools and employers hold the trust that ParentVeda doesn't have yet
(notes p.5–7). Families they bring should *see* them, members should get an exclusive edition,
and the organisation's admin needs a login with stats. Products, referrals and B2B are the three
revenue lines, so this has to work end to end. Storyboard:
https://claude.ai/artifact/8YGaoXWaS44DZmK5S573sZ

## Decided (2026-10-29, the user)
| # | Question | Decision |
|---|---|---|
| D1 | How far does a partner's brand go into the parent app? | Co-brand edition: lockup, welcome, exclusive rail, You chip. No partner colours, no change of navigation. Supersedes the July "one line saying who paid" (`employer_benefits_screen.dart:14–17`). |
| D2 | Where do org admins see stats? | **ParentVeda Partners**, a third flavour from this repo. |
| D3 | Doctors | Most are individuals with their own clinic. They are their own partner and use **ParentVeda+** only. The Partners app is for organisations with several people (employer, school, IVF centre with several doctors). In the parent app a doctor is a "Your doctor" line, never a lockup. |
| D4 | Order | Doctor app and Partners app first (no other terminal is in them). **Parent app last.** |
| D5 | A "viewed" count on the Content tab (2026-10-30) | No. Booked and used only (STILL-OPEN §11.9). |
| D6 | A stage mix for sponsors (2026-10-30) | No, never (STILL-OPEN §11.10). |
| D7 | Email sender for activation codes (2026-10-30) | Resend (STILL-OPEN §11.6). Still to build. |
| D8 | A renewed contract after `ended` (2026-10-30) | Ops re-grants by hand; no trigger (STILL-OPEN §11.4). |

## Recommended defaults, written down (the user can overrule any row)
| # | Question | Default | Why |
|---|---|---|---|
| R1 | Does an HR admin take a paid seat? (STILL-OPEN §11.8) | No. New `sponsor_admins(user_id, sponsor_id)` table; `my_sponsor_admin_id()` reads it first, then falls back to today's rule. | An admin is a role, not a member; and the fallback keeps current demos working. |
| R2 | When a contract ends | `ended` revokes members' sponsored plans via the existing `revoke_plan_by_source('sponsor', id)`; `suspended` hides the admin's view and blocks new activations but keeps members' benefits. | Today nothing revokes, so Premium runs on for free forever. A suspension is often a late invoice and shouldn't punish employees. |
| R3 | Hiding small numbers for clinics and doctors | Counts of families joined, scanned, installed or active are shown as-is: they are referral facts. Any *breakdown* (stage mix, what they use) is hidden below 5, as for sponsors. | Matches the sponsor rule: contract facts are never hidden, behaviour is. |
| R4 | A doctor working inside a clinic | Sees **their own** slice (families from their own code), never the whole clinic's. New `my_doctor_referrals()`; `caller_owns_partner` stays unchanged. | Widening `caller_owns_partner` would hand every member doctor the whole clinic's numbers. |
| R5 | Clinic manager (org login) opening ParentVeda+ | Once the Partners app exists, ParentVeda+ refuses an org-only login with "This account is for ParentVeda Partners" and the next step. Until then, unchanged. | Today an org login gets three broken tabs ("No consulting identity"). |
| R6 | Partners app sign-in | Email + password, the same accounts as the web portal (`signInWithPassword`). | One account works on web and phone. Supabase's built-in email covers password reset at demo volume, and the provider decision (§11.6) still blocks launch. |
| R7 | One login, several organisations | Out of scope. One organisation per login, as today (`partner_accounts.user_id` PK; oldest sponsor wins). | No partner has asked; recorded so nobody builds it by accident. |
| R8 | iOS | Android only for both new flavours, as the doctor app is today (no iOS schemes exist). | Recorded in BEFORE-LAUNCH. |
| R9 | Who edits an org's exclusive content | We do (SQL now, Directus later). The Partners app's Content tab is read-only. | Clinical content safety, and admin-panel-not-ready. |

## Out of scope, said plainly
- Partner colours or themes in the parent app (D1).
- A roster CSV upload by HR in the app (ops imports it; STILL-OPEN §11).
- Real money movement and payouts (STILL-OPEN §5.4 d/e).
- The email provider choice (Resend / SES / Postmark): **the user's decision; still a launch blocker** for activation codes.
- Ask Veda: untouched, so no two-repo change.

## Phases (tick with date + commit hash)
| Phase | App | Session goal | Migration? | Depends on |
|---|---|---|---|---|
| **D1** ✓ 2026-10-29, hash in memory | Doctor | Identity and boot hardening | yes (small): `0132` | — |
| **D2** ✓ 2026-10-29, hash in memory | Doctor | "Families you brought" + a doctor's own referral slice + the right code in the kit | yes | D1 |
| **D3** ✓ 2026-10-29, hash in memory | Doctor | QR rotation keeps per-doctor codes (§5.1b) | yes: `0134` | D2 |
| **P1** ✓ 2026-10-30, hash in memory | Partners | New flavour, shell, sign-in, one org resolver, admin-without-seat | yes: `0136` | — |
| **P2** ✓ 2026-10-30, hash in memory | Partners | Employer and school: Overview, People, Report | small: `0138` (self-removal refused) | P1 |
| **P3** ✓ 2026-10-30, hash in memory | Partners | IVF centre: Overview, per-doctor table; ParentVeda+ refuses org logins (R5) | yes: `0139` (`care_org_dashboard`) | P1, D2 |
| **P4** ✓ 2026-10-30 (0142 RUN, verify 20/0), hash in memory | Partners + DB | Exclusive content: audience columns, Content tab, contract end (R2) | yes | P2 |
| **A1** ✓ 2026-10-30, hash in memory | Parent (LAST) | `PartnerBrand` resolver, lockup strip, "Your doctor" line, welcome sheet in new onboarding | no | P4 |
| **A2** ✓ 2026-10-31, hash in memory | Parent (LAST) | "Exclusively for you" rail, You chip with logo + benefit meter | no | A1, P4 |

| **A3** ✓ 2026-10-31, hash in memory | Parent (+ DB) | Partner offers, a doctor's benefit card on You, and one "Your benefits" row and page (detail at the bottom) | yes (small RPC): `0148` (RUN 2026-10-31, verify 11/0) | A2 |
| **A4** ✓ 2026-10-31 (0149 RUN, verify 24/0, Edge Function redeployed; hash in memory) | DB + Edge + Parent | Auto-apply a partner offer at checkout, server-side (the storyboard's "Auto-applied"; see A3 as built) | yes (money path): `0149` | A3 |

D-phases and P-phases can run in either order; P3 needs D2 for `my_doctor_referrals` shape parity.

## Rules for every phase
- `git status` before the first edit; touch only the phase's files; format only edited files.
- Next free migration number is checked at build time (0128 exists and is waiting to be run).
  Every new RPC is `security definer`, `search_path = ''`, granted to `authenticated` only, and
  answers a non-owner with zeros or `{ok:false, code}`, never someone else's rows.
- Run that app's tests + `flutter analyze` on touched files. Wiring gate: grep the call site.
- Give the user git commands (explicit paths, `-F` message file). Don't run git.
- Same commit: tick the phase here, update BACKEND-PATTERNS (patterns learned), STILL-OPEN
  (§5, §11), BEFORE-LAUNCH (new blockers), and the memory pointer.


---

## PARENT APP (LAST: after other terminals are done)
Kept short; this was detailed in the storyboard.
- **A1:** `lib/services/partner_brand.dart` (singleton, listens to `EntitlementStore` +
  `CarePartnerStore`; sponsor owns the lockup, a doctor is a line), a `lib/widgets/partner_lockup.dart`
  strip (logo, `BrandMark` fallback; **not** `PresentedBy`, per `care_visibility.dart:14–17`), and
  one-line inserts in `home_v3_screen.dart`, `ttc/ttc_home_v3.dart`, `post_pregnancy/pp_home_v3.dart`.
  `care_welcome_sheet.dart` wired into `onboarding_flow.dart`; the `invited` box gets the partner variant.
- **A2:** the "Exclusively for {name}" rail reading P4's filtered programmes (the view's `audience_sponsor_id` /
  `audience_partner_id`); **first make `ProgrammeStore` refresh on a change of signed-in user and clear its cache on
  sign-out** (found in P4: the view now answers per account, the cache is one key); You chip with logo
  (`pv_you_screen.dart:598`) + a benefit meter; update the `employer_benefits_screen.dart:14–17` comment (D1).

### A1 as built (2026-10-30)
Two decisions from the user, made before the build:
- **The strip sits under the top row, as in the storyboard.** It is not the first item on the white sheet. Each hero
  got one nullable slot: `V3PregHero.partner`, TTC `_CycleHeader.partner` and Parenting `_PaintedHero.partner`. Each
  home passes `partner: PartnerStrip(p: p)`.
- **A care partner's home line is on by default.** `CareVisibilityRule.defaultsFor` gained `CareSurface.home` (the
  old set is kept for revert). The home is exempt from frequency, because a line that disappeared after a tab switch
  would read as a fault. Her dismissal, expiry and the partner's status still apply. An admin can still remove home
  from one partner.

What was built:
- `lib/services/partner_brand.dart` decides **who**. A sponsor gives the lockup. A care partner gives the line, unless
  there is a sponsor, in which case the lockup takes the strip. `careLineLabel` returns "Your doctor" for a person and
  "Your clinic" for an organisation; `careLineDetail` returns the organisation or the city.
- `lib/widgets/partner_lockup.dart` decides **how**. The lockup is a white pill with a hairline: the ParentVeda mark,
  "ParentVeda × {name}", then their logo, or a monogram in ink when there is no logo. It is not `PresentedBy`, uses no
  partner colours, and taps through to `EmployerBenefitsScreen` (route `employer`). The doctor line goes through
  `CarePartnerSlot`, using the new `CarePartnerCardShape.home`: a hairline box, the avatar, "Your doctor · name", the
  place underneath, a chevron, and the dismiss inside the box. The line taps through to the Care Circle.
- **Spacing:** the strip owns a 14pt gap above it and takes zero room without a partner, so a plain family's homes
  are unchanged. On Pregnancy and TTC it sits between the top row and the existing 16pt gap above the day strip. On
  Parenting it is positioned on the painting at `top + 10 + 38`, and the painting keeps its height so the caption
  does not move. The gutter is 18 on all three.
- **Onboarding:** step 7 of `_finish` calls `applyPending()`, then `CareJourney.pregnancyStarted()` when there is a due
  date, then `showCareWelcome`, all inside a try so it can never block her. The welcome screen's invited box has a
  doctor variant ("Recommended by …", or "by your doctor" when the lookup cannot read the tables before sign-up).
- Tests: `test/partner_brand_test.dart` (resolver, strip, 360pt overflow, wiring gate on source) and
  `test/care_visibility_test.dart`, where the home group replaces the "home is off" test, kept for revert.
- What A1 left is in STILL-OPEN §5.1f; the logo hosting and the phone walk are in BEFORE-LAUNCH.

### A2 as built (2026-10-31)
Four decisions from the user, made before the build:
- **The storyboard's wording, with full names.** The eyebrow is "Only for Northwind Systems families", "… parents" for
  a school, and "From Dr Meera Rao" or "From Bloom Fertility Centre" for a care partner. The title is "Included with
  your benefit", "From your school" or "For Dr Meera Rao's patients". MASTER's "Exclusively for {name}" was shorthand,
  and the storyboard rules. Shortening a name ("Northwind") would mean guessing, so it is not done.
- **The rail holds programmes plus a consult card.** The consult card ("1 of 2 left · Book a consult") shows when the
  sponsor's plan includes consultations, and it opens Benefits. The offer card is owed (STILL-OPEN §5.1g).
- **No exclusive content means no rail.** It takes no room, the same as having no partner.
- **The sponsor and credits stores refetch on sign-in too.** Same mechanism as the ProgrammeStore fix.

What was built:
- **ProgrammeStore follows the account (done first).**
  - `ContentStore.forgetForAccount()` goes back to the seed, clears `served` and the throttle, and bumps a generation
    number, so a fetch that lands after the switch is dropped.
  - `ProgrammeStore` registers it with `SyncRegistry.registerReset`, and an unforced fetch with
    `SyncRegistry.register`. The disk half was already handled by `LocalWipe` on sign-out and by
    `LocalOwner.ensureCurrent()` at launch.
  - The cache key is now `content_programmes_v2`, because rows now carry `audience_sponsor_id` /
    `audience_partner_id` (`LearningProgram`, both nullable, plus `isExclusive`).
  - `EntitlementStore` and `CreditsStore` gained `SyncRegistry.register(refresh)`.
- **The rail** (`lib/widgets/partner_exclusive_rail.dart`).
  - `partnerRailFor()` is pure. It returns the words and the partner's programmes that are not completed.
  - A sponsor's rail wins, the same rule as the strip. A care partner's leads only when there is no sponsor rail.
  - The name comes through `PartnerBrand` (`PartnerLockupInfo` gained the sponsor `id`).
  - Cards are 150 wide and grow with text up to 1.3×, in ParentVeda's grey panel with ink text. No partner colours
    (D1, which overrules the storyboard's tint), and no logo for a doctor (D3).
- **Spacing is each home's own.** Each home passes its own head and gaps:
  - Pregnancy: the head on 22/12, first in `V3PregSheet`. The next head keeps its own 22.
  - TTC: after the sheet's 26, then head, 14, cards, 26.
  - Parenting: after the sheet's 22, then head, 12, cards, 26.
  With nothing to draw, the rail is a zero-size box.
- **You.** All three stages draw `PvProfileHero`. The old `chip: sponsor?.name` lines are on layouts no stage
  reaches, and are kept for revert.
  - The hero gained a nullable `partner` slot under the status line. It takes `PartnerYouChip`: `PartnerMark` (now
    public; the logo, or a monogram in ink) and the name.
  - Under the hero, `PartnerBenefitCard` reads "Your Northwind Systems benefit", then "1 of 2 consults left" with a
    6pt ink meter from `CreditsStore` and `SponsorBenefits`, then "Valid until …" and "Masterclasses are included."
    where they apply.
  - The card is white with a hairline, on the profile's 18 gutter and 28 group gap, and opens Benefits (route
    `employer`). A sponsor only (D3).
- `employer_benefits_screen.dart:14–17`: the July "one line saying who paid" is replaced by the D1 co-brand
  paragraph, with the old text kept for revert.
- Tests: `test/partner_editions_a2_test.dart` covers:
  - the store reset and resync, and the cache round trip;
  - the rail's rule and its words;
  - 360pt at 1× and 1.5× for the rail, the chip and the card;
  - zero room with no partner;
  - the wiring gate on all three homes and the hero.
- What A2 left is in STILL-OPEN §5.1g; the phone walk is in BEFORE-LAUNCH.

After the build, three more answers from the user (2026-10-31):
- **`CarePartnerStore` refetches on sign-in too** (`SyncRegistry.register(refreshFromServer)`).
- **The offer card is A3**, its own small phase with the coupon RPC (table above).
- **A doctor family's You page is unchanged**, after a replica: https://claude.ai/artifact/7ZPoYurF4pzoqXFrByaaWe. **Revised the same day:** a doctor or clinic with a real benefit gets a words-only card in A3.

Found and fixed in the same pass, not A2's own: Settings had lost "About ParentVeda" (picked by position, and the Our
experts row moved it). Detail in STILL-OPEN §5.1g.

### A3 (planned 2026-10-31, the user)
Three parts, one phase. Same rules as A1 and A2: the storyboard and D1–D8 rule, `git status` first, touch only A3's
files, one-line inserts, comment out never delete, English only, no partner colours, no navigation change.
1. **Partner offers.** 0142 gave `programme_coupons` an audience (`audience_sponsor_id` / `audience_partner_id`), but
   nothing on the phone can read a coupon by audience. Add one RPC that returns **the caller's own** audience coupons
   only: `security definer`, `search_path = ''`, granted to `authenticated` only, using `_audience_ok(auth.uid(), …)`.
   It returns the code, label, discount and expiry, never another family's coupon or any usage counts. Check the next
   free migration number at build time (0147 is the latest on 2026-10-31). Write a `verify_*.sql` too. **The user
   runs the migration.** Then add the storyboard's offer card to the A2 rail ("15% off lactation consults ·
   Auto-applied"), using the rail's existing card.
2. **A doctor's or clinic's benefit card on You.** Storyboard row 3, doctor variant: "From Dr Meera Rao", what she gets
   (their offer, and the sessions only their patients see), and "Your health details stay private". **Words only:** no
   logo, no monogram, no meter (D3). Show it only when there is at least one real benefit; otherwise it takes no room.
   A sponsor's card still wins the slot under the hero (one partner, as for the strip). Revises A2's "doctor family:
   nothing on You".
3. **"Your benefits" on You, always shown.** One row on the You page opening one Benefits page that lists the
   employer's benefits and the doctor's offer and sessions together. With no partner it reads "Does your employer
   offer ParentVeda?" (a feature is never hidden). `employer_benefits_screen.dart` gains a care-partner section. A
   rename of its title is fine; keep the route name `employer`, which others detect. Why: **Parenting has no way in
   to Benefits** for a parent with no sponsor. `pp_more_sheet.dart` has no Benefits row, and the profile's own
   "Employer benefits" row (`_supportRows` in `pv_you_screen.dart`) is in a list the live Settings never shows. Check
   Pregnancy's and TTC's More rows still open the same page, so there is one page, not two.

Open for the A3 chat to ask, only if the storyboard is silent: where exactly the "Your benefits" row sits on You
(its own group under the hero card, or a row in an existing group), and the page's new title.

### A3 as built (2026-10-31)
Two decisions from the user, made before the build:
- **True words now, auto-apply later (A4).** Nothing applies a coupon today: `price_offering` / `open_payment_order`
  (0126) ignore coupons, and no screen calls `preview_programme_coupon`. So the offer card reads "15% off {label}" and
  "Until 30 Nov", never the storyboard's "Auto-applied", and Benefits says plainly that checkout does not take offers
  yet. Auto-apply is phase A4 (table above), because it changes the amount Razorpay is asked for.
- **"Your benefits" is the last row of Your things** on the shared profile (all three stages). No new group, so the
  page's spacing is unchanged. The page is titled "Your benefits"; the route stays `employer`.

What was built:
- **`0148_partner_offers.sql`** (the user runs it, before installing the build).
  - `programme_coupons.label` (nullable, 1 to 60 characters): what an offer is for, written by ops.
  - `my_partner_offers()`: no arguments, so it can only mean the caller. `security definer`, `search_path = ''`,
    `authenticated` only. Returns code, kind, value, label (else the programme's title), programme id, end date and
    whose audience. Only audience coupons (a public coupon is still found by typing it, 0054's rule); only live,
    unexpired, not used up; only through `_audience_ok`; never a coupon for a programme the caller cannot see; never
    `redeemed` or `max_redemptions`.
  - `supabase/seed/verify_partner_offers.sql`: 11 checks, rolled back.
- **`lib/services/partner_offer_store.dart`**: memory only (no coupon code on disk), `SyncRegistry` reset + resync,
  a generation guard, and an offer past its end date drops on the phone between fetches.
- **The rail**: `PartnerRail.offers`; an offer alone is enough for a rail; sponsor offers go to the sponsor's rail and
  a care partner's to theirs (a sponsor still wins). The card is the rail's own `_Card`: chip "Offer", the headline,
  the end date; it opens Benefits.
- **You**: `PartnerCareBenefitCard` under `PartnerBenefitCard`. Words only (no logo, no monogram, no meter, D3):
  "From Dr Meera Rao", the offer's headline or "2 sessions only Dr Meera Rao's patients see", and "Your doctor's
  sessions and offer live here. Your health details stay private." It uses the rail's rule with no sponsor, so the
  card and the doctor's rail cannot disagree; it takes no room without a real benefit, and none beside a sponsor.
  `PartnerBenefitsRow` ("Your benefits") names what is behind it: the sponsor, the doctor, or "Does your employer
  offer ParentVeda?".
- **Benefits** (`employer_benefits_screen.dart`): three states. A sponsor: as before, with its offers among the rows,
  then the doctor's section if there is one. No sponsor but a doctor with a benefit: the doctor's section, then the
  employer question with its pill. Neither: the empty state, unchanged. The doctor's section is in words with our own
  drawn mark, and ends with "What {name} sees".
- Pregnancy's and TTC's More rows already open this same page (route `employer`), so there is one page. Their titles
  still say "Employer benefits" (not renamed: not asked).
- Tests: `test/partner_editions_a3_test.dart` (28): parsing, the store's reset, the migration's shape, the rail's rule,
  never "Auto-applied", the card's words, no room, a sponsor keeps the slot, the row's three lines, the page's three
  states, 360pt at 1x and 1.5x, and the wiring gate.
- What A3 left is in STILL-OPEN §5.1g; the migration, A4 and the phone walk are in BEFORE-LAUNCH.

### A4 (planned 2026-10-31, the user)
Auto-apply a partner offer at checkout. Same rules as A1 to A3, plus: **money is decided on the server**, and the
phone only ever shows what the server answered. Migration `0149` (the next free number on 2026-10-31; check again at
build time). The user runs it, then redeploys `razorpay-create-order`, before installing the build.

**Out of scope, said plainly**
- **Consults.** A coupon names a programme (or any programme), never an expert. Consults are bought as credits, the
  expert's cut comes from the booking, and sponsors already give two consult credits. A consult is never discounted
  in A4, so ops labels offers against programmes only (the storyboard's "15% off lactation consults" cannot be true
  yet). STILL-OPEN row.
- **Typing a public code.** The "Apply offer" list shows her own partner offers only. A public code typed by hand
  (`preview_programme_coupon`, 0054) stays unwired.
- **An expert's own code and its share** (`programme_coupons.expert_id`, STILL-OPEN §13.0 item 2).
- **Real money between ParentVeda and the partner** (who funds the discount): STILL-OPEN §5.4 d/e.
- **Free via an offer.** Razorpay cannot take ₹0. "Free for our staff" stays an exclusive programme priced at ₹0.
- **A rupees-saved total on the partner's Content tab.** Not until a partner asks.
- **An admin screen for offers.** Ops writes offer rows in SQL (R9; admin-panel-not-ready). A4 ships a commented
  example insert.

**Decision record**
| # | Question | Recommended | The user's answer |
|---|---|---|---|
| 1 | Where is the discount decided? | A closed helper `_offers_for(uid, offering)` on the server, beside `price_offering` (not inside it: it is also seat value, earnings and titles, and every parent can call it). `open_payment_order` and the stub path use it; the phone's quote uses it too, so the quote and the charge cannot differ. Ops sets each offer's kind and value on `programme_coupons` | Agreed. Ops must be able to input what the discount is |
| 2 | Several offers | The best saving for her is applied by default (tie: the one ending soonest). One offer per order, never stacked. A ₹0 programme stays free and uses none; credits are spent before money | Best by default, **and she can pick another**: an "Apply offer" list at checkout shows all her offers for that purchase, as every platform does |
| 3 | When a use counts | When the receipt is written (`_write_purchase`'s insert branch, same transaction). Abandoned or failed: 0. A refund does not give it back | Agreed |
| 4 | Offer ends or runs out between order and capture | Honour the order's price (Razorpay already took it). Each tap on Pay re-prices | Agreed |
| 5 | Consults | Out of A4 | Agreed |
| 6 | Words on the phone | Checkout: list price struck through, the price she pays, "Partner offer applied · {label}". "Auto-applied" returns on the rail card and the welcome sheet's "Applied automatically at checkout" returns, **in the same commit** as the server path. Benefits drops "Checkout does not take offers yet". Your bookings shows the offer on a receipt | Agreed |
| 7 | Partner's Content tab | No change: `redeemed` is already shown with the small-numbers hide (0142); it starts moving | Agreed |
| 8 | The expert's cut on a discounted sale | Paid on the list price; ParentVeda absorbs the discount | Agreed: experts never earn less |
| 9 | Her pick no longer applies at Pay | Fall back to the best offer that does, and the Razorpay sheet shows the server's amount | Default (follows from 2 and 4) |
| 10 | An offer that would make it free | Not allowed: percent 1 to 99; a flat offer must leave at least ₹1 | Default (follows from out of scope) |

**To build**
1. `0149_partner_offer_checkout.sql`
   - `payment_orders` and `course_purchases` gain `list_paise`, `discount_paise`, `coupon_code` (nullable; old rows
     read as no offer). The order freezes them at open; the receipt copies them. An invoice, not a lookup.
   - `programme_coupons`: `percent` value 1 to 99 (a check constraint; read the live rows first, as 0126 learned).
   - `_offers_for(uid, offering)`: closed (revoked from `authenticated`). Programmes only (`source = 'programme'`),
     live, unexpired, under the cap, `_audience_ok`, the programme visible to her. Each offer with its saving in paise
     and the price after it; best first. A flat offer that would leave under ₹1 is skipped.
   - `my_offer_quote(p_offering_id)`: no user argument (16zzz-j point 1). Returns list price, her offers for it with
     what each saves, and which one is best. Never usage counts.
   - `open_payment_order` gains `p_coupon_code` (default null). Her pick if `_offers_for` still has it, else the best.
     Writes list, discount and code on the row. The old five-argument version is dropped in the same file so there is
     one signature.
   - `record_stub_purchase` takes the same optional code and the same rule, so a stub walk shows the discount.
   - `_write_purchase`: copies the three columns from the order; in the insert branch only,
     `redeemed = redeemed + 1` for the order's code (the row lock serialises it; `on conflict do nothing` keeps a
     replayed capture from counting twice).
   - `book_slot` and the expert's earnings: unchanged, on purpose (decision 8).
   - `my_purchases()` adds `list_paise`, `discount_paise`.
   - A commented example insert for ops: a percent and a flat offer with label, end date, cap and audience.
2. `razorpay-create-order`: pass `couponCode` through as `p_coupon_code`; nothing else. The user redeploys it.
3. Phone
   - `PaymentService.checkout` / `pay` send the chosen code.
   - Checkout (the three call sites: `pv_learn_flow.dart`, `booking_sheet.dart` for programmes only,
     `ttc_prepare_screen.dart`): asks `my_offer_quote`, shows the struck-through price and "Partner offer applied ·
     {label}", and an "Apply offer" row opening the list of her offers for this purchase, best marked. With no offer,
     nothing changes on screen.
   - The rail card and the welcome sheet say "Auto-applied"; Benefits loses "Checkout does not take offers yet";
     Your bookings shows "15% off" on a receipt with a discount.
   - The A3 test that bans "Auto-applied" becomes one that requires `my_offer_quote` in 0149 and its call site.
4. Docs in the same commit: tick A4 here, BACKEND-PATTERNS (the frozen-price order, counting the fact, quote and
   charge from one function), STILL-OPEN §5.1g (close the A4 row, add the consult row), BEFORE-LAUNCH (0149, the
   redeploy, the phone walk), memory pointer.

**What must be proven**
- `supabase/seed/verify_partner_offer_checkout.sql` (rolled back): a member's order opens discounted; a non-member's
  at full price; best of two wins; her pick wins when valid and falls back when not; another family's code is
  refused; expired, used-up and inactive offers are not applied; a consult is never discounted; percent 100 is
  refused; the order freezes list, discount and code; capture copies them to the receipt; a replayed capture counts
  `redeemed` once; a failed order counts 0; a refund leaves the count; the quote equals the order amount; the quote
  takes no user argument and returns no counts; the stub path applies the same offer; the expert's booking value is
  the list price.
- `test/partner_editions_a4_test.dart`: quote parsing; the struck price only when the server says so; the offer list
  and her pick; "Auto-applied" only with the server function; the Benefits line gone; 360pt at 1x and 1.5x; the
  wiring gate at all three checkout sites; the sync reset clears any chosen code.

### A4 as built (2026-10-31)
Built to the decision record above; nothing in the code contradicted it. What was built:
- **`0149_partner_offer_checkout.sql`** (the user runs it after 0148, then redeploys `razorpay-create-order`, then
  installs the build). Safe in that order: the old Edge Function's five named arguments still resolve to the new
  six-argument `open_payment_order` (the code defaults to null, so the best offer applies), so the migration can land
  before the redeploy without breaking checkout.
  - `payment_orders` and `course_purchases` gain `list_paise`, `discount_paise`, `coupon_code`.
  - `programme_coupons_percent_range` (percent 1 to 99). The migration reads the live rows first and **stops, naming
    the codes**, if any percent coupon is outside 1 to 99, rather than rewriting what an offer is worth.
  - `_offers_for(uid, offering)` (closed): audience offers only, programmes only, live, under the cap, `_audience_ok`,
    a programme she can see; free stays free; anything leaving under ₹1 is skipped (percent and flat alike, since a
    99% offer on a ₹1.50 price would leave under ₹1 too). Best first: saving, then ending soonest, then code.
  - `_offer_pick(quote, code)` (closed): her code if the rule still lists it, else the best. One place, used by the
    order and the stub.
  - `my_offer_quote(p_offering_id)`: no user argument; list price, her offers with saving and price, the best. Never
    usage counts.
  - `open_payment_order(..., p_coupon_code default null)`: the old five-argument version dropped in the same file.
  - `record_stub_purchase(p_offering_id, p_coupon_code default null)`: the old one-argument version dropped.
  - `_write_purchase` gains three trailing defaults (the stub's frozen price); an order's own columns win. In the
    insert branch only, `redeemed = redeemed + 1`. The old eight-argument version dropped.
  - `my_purchases()` adds `list_paise`, `discount_paise` (not the code).
  - `price_offering`, `book_slot`, the expert's earnings and the refund path: unchanged, on purpose.
  - A commented example insert for ops (a percent and a flat offer; flat values are paise).
  - `supabase/seed/verify_partner_offer_checkout.sql`: 24 checks, rolled back (the consult check says SKIP, not
    FAIL, if an expert fixture cannot be seeded on that database).
- **`razorpay-create-order`**: passes `couponCode` as `p_coupon_code` (offerings only); nothing else.
- **Phone**
  - `lib/booking/offer_quote.dart`: `OfferQuote` / `QuotedOffer` (parse `my_offer_quote`), `OfferQuoteStore` (memory
    only, `SyncRegistry.registerReset` clears every quote and pick, a generation guard), `offerRupees`.
  - `PaymentService.checkout` sends her pick (default: the store's pick for that offering, so the three sites need no
    extra argument); `BookingStore.acquire` sends it to `record_stub_purchase` on the stub path.
  - `lib/widgets/partner_offer_checkout.dart`: `PartnerOfferCheckout` (list price struck, the price she pays,
    "Partner offer applied · 15% off …", an "Apply offer" row opening "Your offers" with the best marked) and
    `partnerOfferPayLabel`. It takes no room without an offer. On the Learn review sheet (`pv_learn_flow.dart`), the
    Parenting booking sheet (`booking_sheet.dart`, programmes only) and TTC's offering page (`ttc_prepare_screen.dart`,
    the classic fallback). Each pay button shows the quoted price.
  - The rail card says "Auto-applied · Until 30 Nov"; the welcome sheet (`care_welcome_sheet.dart`) says "Partner
    offers · Applied automatically at checkout" only when that partner has a live offer for her (and refreshes her
    offers when it opens, since attribution has only just bound); Benefits' offer rows say "Applied automatically at
    checkout…" instead of "Checkout does not take offers yet".
  - Your bookings: the receipt sheet shows "Partner offer · 15% off · was ₹500". `Purchase.offerLine` says a percent
    only when the server's own floor arithmetic reproduces it, else rupees.
- Tests: `test/partner_editions_a4_test.dart` (25). The A3 test that banned "Auto-applied" is kept commented out for
  revert. A2, A3 and the booking, learning and money contract tests stay green; `sync_reset_coverage_test` is still red
  for the four stores that were red before A4 (`community_alerts`, `pv_catalog_store`, `pv_community_store`,
  `pv_review_store`), not for this one.
- Left: STILL-OPEN §5.1g "Left by A4". BEFORE-LAUNCH: 0149, the redeploy, the phone walk.

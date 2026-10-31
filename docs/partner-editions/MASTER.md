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

| **A3** | Parent (+ DB) | Partner offers, a doctor's benefit card on You, and one "Your benefits" row and page (detail at the bottom) | yes (small RPC) | A2 |

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

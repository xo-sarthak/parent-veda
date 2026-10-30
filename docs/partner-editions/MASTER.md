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
| **A2** | Parent (LAST) | "Exclusively for you" rail, You chip with logo + benefit meter | no | A1, P4 |

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


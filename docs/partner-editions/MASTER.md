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
| **D1** | Doctor | Identity and boot hardening | yes (small) | — |
| **D2** | Doctor | "Families you brought" + a doctor's own referral slice + the right code in the kit | yes | D1 |
| **D3** | Doctor | QR rotation keeps per-doctor codes (§5.1b) | yes | D2 |
| **P1** | Partners | New flavour, shell, sign-in, one org resolver, admin-without-seat | yes | — |
| **P2** | Partners | Employer and school: Overview, People, Report | no (uses existing RPCs) | P1 |
| **P3** | Partners | IVF centre: Overview, per-doctor table; ParentVeda+ refuses org logins (R5) | maybe | P1, D2 |
| **P4** | Partners + DB | Exclusive content: audience columns, Content tab, contract end (R2) | yes | P2 |
| **A1** | Parent (LAST) | `PartnerBrand` resolver, lockup strip, "Your doctor" line, welcome sheet in new onboarding | no | P4 |
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
- **A2:** the "Exclusively for {name}" rail reading P4's filtered programmes; You chip with logo
  (`pv_you_screen.dart:598`) + a benefit meter; update the `employer_benefits_screen.dart:14–17` comment (D1).

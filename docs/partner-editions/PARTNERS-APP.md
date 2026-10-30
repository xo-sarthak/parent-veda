# Partner Editions — PARTNERS APP PLAN (ParentVeda Partners)

> Phases P1–P4. Decisions and defaults (D1–D4, R1–R9) and the session rules live in [MASTER.md](MASTER.md); read its phase table first.

**Reuses (verified):** `SponsorAdminStore` (`sponsor_dashboard`, `sponsor_roster`,
`sponsor_trend`), `sponsor_engagement` (0065, called by nobody yet), the care-partner RPCs, the
web portal's behaviour (`C:\parentveda-web\src\app\portal\`: password auth, dashboard, people,
report). Flavour wiring is copied from the doctor app: `android/app/build.gradle.kts:53–64`,
`src/doctor/res/mipmap-*`, the `${appLabel}` manifest placeholder.

## P1: Flavour, shell, sign-in, one resolver
1. Android flavour `partner`: `applicationIdSuffix ".partners"`, label "ParentVeda Partners", own
   icons (`src/partner/res/mipmap-*`), no OAuth intent filter. `lib/main_partner.dart` boots only
   what it needs (Supabase, `PartnerOrgSession`, `NotificationService` not needed).
   Build: `flutter build apk --release --flavor partner -t lib/main_partner.dart` → Downloads.
2. Migration: `sponsor_admins(user_id, sponsor_id, added_at, added_by)` (R1); `my_sponsor_admin_id()`
   reads it first. One unified RPC `my_partner_org()` returns
   `{ok, kind: 'sponsor'|'care_org', id, name, sponsor_kind, logo_url, status}`; sponsor wins if both.
   `kind` drives which Overview renders. Check `sponsors.kind` allows `school` (add to the check if not).
3. `lib/partner_app/partner_org_session.dart`: singleton `ChangeNotifier`, resolve enum
   `resolved | notAnAdmin | suspended | unreachable`.
4. Sign-in screen (password, show/hide, "Forgot password?" using Supabase reset). Refusals, each with
   a next step:
   - not an admin: "This email isn't set up for ParentVeda Partners. Ask your ParentVeda contact." Then sign out.
   - a doctor's email: "You're a doctor on ParentVeda. Use ParentVeda+."
   - a parent's email: "This is the parent account. Get ParentVeda."
   - suspended: "Your programme is paused. Contact your ParentVeda manager." (R2)
   - offline / not initialised: calm retry screen, never a crash.
5. Shell: `PvNavBar` with Overview · People · Content · Account; named routes; Back on any tab
   other than Overview goes to Overview (doctor-app pattern). Account: org name, logo, signed-in email,
   support contact, sign out (clears every store).
Tests: `partner_app_shell_test` (boot, tabs, routes, refusals), and a SQL contract test for `my_partner_org`.

### P1 as built (2026-10-30)
| # | What shipped | Where |
|---|---|---|
| 1 | Flavour `partner`: suffix `.partners`, label "ParentVeda Partners", no `src/partner/AndroidManifest.xml` (so no OAuth callback). Icons: the family mark plus a purple disc with three rising bars, made by the same generator, which now takes a flavour argument so adding one leaves the other two icon sets unchanged | `android/app/build.gradle.kts`, `android/app/src/partner/res/`, `tools/gen_launcher_icons.py` (`python tools/gen_launcher_icons.py partner`) |
| 2 | `sponsor_admins(user_id PK, sponsor_id, added_at, added_by)`: own-row read, no write policy. `my_sponsor_admin_id()` reads it first (active sponsors only), then the 0060 rule, so every sponsor RPC accepts a seatless admin with no change of its own | `0136_partner_org_admins.sql` |
| 2+ | `my_partner_org()` → `{ok, kind, id, name, sponsor_kind, partner_type, logo_url, status, support_contact}`. Sponsor wins. A care_org is **Route A only** (`partner_accounts`): Route B is a doctor. It **reports** status rather than filtering, so a paused admin is told why. A non-admin gets `{ok:false, code}`: `doctor` / `parent` (onboarded profile) / `not_an_admin` / `not_signed_in`. `sponsors.kind` is free text, so `school` needed no check change | `0136` |
| 3 | `PartnerOrgSession`: singleton, not cached to disk (as `SponsorAdminStore`), resolve enum `resolved / notAnAdmin / suspended / unreachable`. Two seams (`ask`, `signedIn`) let the test drive the real path with no mocking framework | `lib/partner_app/partner_org_session.dart` |
| 4 | Sign-in: password with show/hide; "Forgot password?" is the parent app's **code** flow (email, then a 6-digit code, then a new password), not a link. Refusals carry the next step (doctor → ParentVeda+, parent → ParentVeda, otherwise → your ParentVeda contact). Paused, not started and ended each get their own line. Offline and backend-down share one calm hold screen; Sign out appears whenever someone is signed in | `lib/screens/partner_app/partner_auth_screen.dart`, `partner_hold_screen.dart`, `partner_words.dart`, `lib/main_partner.dart` |
| 5 | Shell: `PvNavBar`, Overview · People (Doctors for an IVF centre) · Content · Account; Back on any tab returns to Overview. Overview, People and Content open on their empty states (the house rule, not placeholders); P2–P4 replace them in `partner_tabs.dart`. Account: logo (initial fallback), org name, signed-in email, ParentVeda support, the members' support line, sign out | `partner_scaffold.dart`, `partner_tabs.dart` |
| 5+ | One sign-out, `forgetPartnerOrgOnThisPhone()`: signs out, then clears `PartnerOrgSession`, `SponsorAdminStore` (new `clear()`; it had no way to forget a roster) and `PartnerDashboardStore`. Every path calls it; the test fails if one signs out around it | `lib/partner_app/partner_sign_out.dart`, `lib/services/sponsor_admin_store.dart` |
| 6 | Verify pass: borrows the oldest user, walks nothing → parent → doctor → care_org → sponsor wins → paused → ended, checks the seatless admin's dashboard answers and a paused one's does not; rolls back by raising the report | `supabase/seed/verify_partner_org.sql` |

**Not done, said plainly.** "Named routes": P1 pushes no route (tabs are a state switch, as in the doctor app), so
there is nothing to name yet; the test that every `MaterialPageRoute` under `lib/screens/partner_app/` carries
`RouteSettings(name:)` is in place for P2. **Found, not fixed (outside P1):** the `/invite` and `/care` App Links
live in `src/main`, so the doctor and partner flavours claim them too, and a phone with all three apps sees a
chooser on a referral link (BEFORE-LAUNCH).

**Found while testing:** a `TextEditingController` notifies on *selection* as well as text, and an autofocused field
sets its selection on first layout. The sign-in screen cleared its error on any notification, so a refusal carried in
from the boot (a restored doctor login) was wiped before it was seen: a blank form, no reason. It now clears only on a
change of text. `DoctorAuthScreen` has the same listener but never sets an error before first layout, so it is not
affected today (left alone: P1 does not touch the doctor app).

Tests: `partner_app_shell_test` (25: resolver outcomes, boot, refusals, paused, shell tabs and Back, sign-out
coverage, flavour and icons, the 0136 contract on the **latest** definitions). **Run 0136, then
`verify_partner_org.sql`, then give an admin a `sponsor_admins` row (SQL at the foot of 0136).**

## P2: Employer and school views
1. **Overview** from `sponsor_dashboard` + `sponsor_trend(12)` + `sponsor_engagement(6)`. KPIs: seats
   (or "Unlimited" when null), activated with rate, active this month, consults used of included.
   Trend strip. "Where your families are" and "Most used" only when not suppressed; otherwise
   "Shown once 5 people have activated" (the server's `min_cohort`, never a hard-coded 5).
2. **People** from `sponsor_roster`: all three statuses, active / not_activated / removed, plus
   `full_name`. **Fixes the existing bug** in `SponsorMemberRow` (`sponsor_admin_store.dart:40,44`),
   which shows not-yet-activated people as "Removed" (shared store, so the in-app HR screen gets the fix
   too). Search, filter chips, a remove action with an in-page confirm (no dialog), using the
   existing `sponsor_remove_member`. Empty roster: an explanation card ("Send us your staff list…").
   Edge cases: unlimited seats; seats_left = 0 (warning chip); an admin trying to remove themselves
   (refused client-side and server-side); an email that's in the list but has activated under a
   different address (shows in both lists, as the server returns it).
3. **Report**: monthly summary screen mirroring the portal's report page. Share as an image/PDF
   through the OS share sheet (no print dialogs).
4. Stale copy fix: "time in the app is not measured" (`sponsor_dashboard_screen.dart:261–268`) is
   wrong since 0065.
5. School wording: `sponsor_kind == 'school'` swaps "employees" → "parents", "staff list" → "parent list".
Tests: `partner_overview_test` (suppressed / unsuppressed / unlimited seats), `sponsor_roster_status_test`
(the bug), and a render test for each tab.

## P3: IVF centre view (care_org)
1. Overview from `partner_impact` + `partner_funnel` + `partner_earnings`; a **per-doctor table** from
   `partner_referral_breakdown()` (first caller in the codebase): doctor, families, latest. Behaviour
   breakdowns hidden below 5 (R3); counts shown.
2. People tab for care_org = "Your doctors" (no family names ever). Adding a doctor stays SQL (§5.1c);
   the screen says "To add a doctor, contact your ParentVeda manager."
3. R5: ParentVeda+ refuses an org-only login and points to Partners (`doctor_auth_screen.dart`).
   Edge cases: an org login that is *also* a clinician (has `expert_accounts`) stays in ParentVeda+ as a doctor.
Tests: `partner_care_org_test` and `doctor_app_shell_test` (org refusal).

## P4: Exclusive content and contract end
1. Migration: `programmes.audience_sponsor_id`, `audience_partner_id` (nullable, FK);
   `programmes_published` filters them (null = everyone; set = only members of that sponsor, or
   families attributed to that partner). The same goes for `programme_coupons` + `expert_id` (STILL-OPEN §13.0).
   RLS test with two users: a non-member gets zero rows. Close §11.9.
2. Content tab: list of this org's exclusive programmes and offers with booked/viewed counts
   (suppressed below 5). Read-only (R9). Empty: "No exclusive sessions yet. Your ParentVeda manager can
   set one up."
3. R2 trigger: sponsor `status → ended` calls `revoke_plan_by_source('sponsor', id)`; `suspended`
   doesn't. Test both. Update STILL-OPEN §11.4.

## Verification (every P-phase)
Demo sponsor seed (`supabase/seed/sponsor_demo.sql`, `@parentveda-demo.com`, `DEMO-ACTIVATE-2026`)
plus a `sponsor_admins` row → sign in on the partner flavour → numbers match the portal for the same
account. A demo care_org login → per-doctor table matches `partner_referral_breakdown` in SQL. On the
phone only with the user's go-ahead.


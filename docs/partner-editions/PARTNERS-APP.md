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

### P2 as built (2026-10-30)

**Dropped from the plan, said plainly.**
- **"Where your families are" (a stage mix) and "Most used" (a section breakdown).** No RPC returns either, and
  0065 declines the second on purpose: in a small team "your people spend their time in Health" narrows down who is
  worried about what. The portal's report says so in its "does not contain" list. Building the stage mix needs a
  migration *and* a privacy decision (is "how many of your employees are pregnant" behaviour or a contract fact?);
  parked as STILL-OPEN §11.10, for the user. Overview's privacy note says the section-breakdown half in the product's voice.
- **"Consults used of included."** No server figure says how many consultations a sponsor's plan includes, so the KPI
  is consultations booked, with attended and upcoming under it. Parked with §11.10.

| # | What shipped | Where |
|---|---|---|
| 1 | Overview: Seats (or Unlimited / No cap), Activated with take-up ("of your list" or "of seats", the server's denominator), Active this month (`sponsor_engagement`'s current month), Consultations. Behaviour is "—" plus the reason when withheld, and every threshold sentence uses the server's `min_cohort`. Take-up bars (12 months, with the three-month change said plainly, down as well as up) and "Coming back" bars (6 months; a withheld month is a hairline and a dash, never a zero bar). A full programme gets a red notice with the next step. Pull to refresh; error with Try again; not-loaded keeps P1's empty state | `lib/screens/partner_app/partner_sponsor_overview.dart` |
| 2 | Store: `SponsorMemberRow` reads all three statuses (`isActive / isNotActivated / isRemoved`) plus `full_name`; an unknown status reads as not started (it claims nothing). `sponsor_engagement(6)` fetched in `refresh()`, not fatal, like the trend. **The bug:** the in-app HR screen split on `!isActive`, so everyone not yet started showed as "Removed —". Fixed there too (three lists; not-started always shown, they are HR's follow-up list) | `lib/services/sponsor_admin_store.dart`, `lib/screens/enterprise/sponsor_dashboard_screen.dart` |
| 3 | People: name (HR's own) or email, status and date; search by name or email; filter segments with counts (All / Activated / Not started / Removed). Remove only on active people, opening an **in-page** confirm in the row (what is lost, what is not; Remove / Keep). Not-started people leave by an updated list, and the page says how. The admin's own row reads "· You" and has no Remove. All seats taken: a chip and the next step. Empty roster: P1's explanation card | `lib/screens/partner_app/partner_sponsor_people.dart` |
| 3+ | **Self-removal refused on the server too** (the plan said both sides; no RPC did it): `0138` adds `cannot_remove_self` to `sponsor_remove_member`, on the **uid**, before the remove. A work email and a login email are often different addresses for one person, so the app's email check is only a shortcut. A legacy (0060) admin who removed herself would have locked herself out | `supabase/migrations/0138_sponsor_remove_not_self.sql` |
| 4 | Report: Overview → "Monthly report" (named route `partner/report`) mirrors the portal page: headline sentence, four figures, consultations or why withheld, month by month (a table, withheld months a dash), what it does not contain. "Share as PDF" goes through the OS share sheet. One `PartnerReport` model feeds both the screen and the PDF, so they can only differ in typography; the PDF uses built-in Helvetica, so it builds offline | `lib/partner_app/partner_report.dart`, `lib/screens/partner_app/partner_report_screen.dart` |
| 5 | Stale copy: the HR screen's "time in the app… we do not measure that last one at all" corrected in English and Hindi (0065 measures it, monthly totals only, withheld for small groups); the old line commented out, kept for revert | `sponsor_dashboard_screen.dart` |
| 6 | School wording from `org.peopleWord` / `isSchool` throughout: parents, parent list | the two new tabs, `partner_words.dart` |

Tests: `partner_overview_test` (11: suppressed with a server threshold of 7, unsuppressed, unlimited seats, full,
not loaded, error, report route, model arithmetic, PDF bytes), `partner_people_test` (8), `sponsor_roster_status_test`
(7, incl. the 0138 contract). `partner_app_shell_test` unchanged and green. **Run 0138 before the walk** (until then
the app's email check still stops the common case).

## P3: IVF centre view (care_org)
1. Overview from `partner_impact` + `partner_funnel` + `partner_earnings`; a **per-doctor table** from
   `partner_referral_breakdown()` (first caller in the codebase): doctor, families, latest. Behaviour
   breakdowns hidden below 5 (R3); counts shown.
2. People tab for care_org = "Your doctors" (no family names ever). Adding a doctor stays SQL (§5.1c);
   the screen says "To add a doctor, contact your ParentVeda manager."
3. R5: ParentVeda+ refuses an org-only login and points to Partners (`doctor_auth_screen.dart`).
   Edge cases: an org login that is *also* a clinician (has `expert_accounts`) stays in ParentVeda+ as a doctor.
Tests: `partner_care_org_test` and `doctor_app_shell_test` (org refusal).

### P3 as built (2026-10-30)

**Changed from the plan, said plainly.** The plan read the Overview from `partner_impact` + `partner_funnel` +
`partner_earnings` and the per-doctor table from `partner_referral_breakdown()`. Checked against `my_partner_org()`
first:
- the three that take `p_partner_id` **agree** (the app passes the Route A id `my_partner_org()` returned, and
  `caller_owns_partner` always lets that through);
- `partner_referral_breakdown()` **does not**: it takes no id, sums every partner the login owns by either route and
  groups by doctor only, so a centre manager who is also a doctor with her own practice gets both in one table;
- `partner_impact` / `partner_funnel` send behaviour (pregnancies, children, consults, vaccinations, reads, activated)
  with no small-number rule, so hiding it in the app would not hide it (R3);
- and `PartnerDashboardStore.load()` resolves through `my_care_partner()`, which prefers her own practice (0132).

The user chose (2026-10-30) **one new zero-argument RPC, `care_org_dashboard()` (0139)**, shaped like
`sponsor_dashboard`. The four shared RPCs and ParentVeda+ are unchanged. `partner_referral_breakdown()` still has no
caller (STILL-OPEN §5.1e).

| # | What shipped | Where |
|---|---|---|
| 1 | `care_org_dashboard()` → `{ok, partner_id, min_cohort, suppressed, families, scanned, installed, signed_up, active_30d, activated, pregnancies, children, consultations, vaccinations, content_read, earnings[], doctors[]}`. It finds the centre by **calling `my_partner_org()`** (not a copy of its join), and answers only a live care_org: otherwise `{ok:false, code: not_a_care_org | not_live}`. Referral facts and money as they are; behaviour null below `min_cohort` (the sponsors' config row, so one privacy dial), base = the centre's families. Same counting definitions as `partner_funnel` / `partner_impact` | `supabase/migrations/0139_care_org_dashboard.sql` |
| 1+ | Per-doctor rows, three kinds so every family is filed: `doctor` (each published doctor of the centre, **even at 0**: the empty row is the nudge), `former` (a code naming a doctor no longer listed; attribution is history), `centre` (the centre's own code). Name, count, and the **day** of the latest family (`::date`, not a timestamp: a time can be laid against an appointment book) | `0139` |
| 2 | `CareOrgStore`: singleton, not cached to disk, one `ask` seam for tests. Behaviour that arrives with `suppressed: true` is dropped on the phone too (belt and braces). A failed load keeps what was shown and says so | `lib/partner_app/care_org_store.dart` |
| 3 | Overview: Families joined, Active (30 days), From code to family (scanned / installed / signed up, with the "a scan is counted only for a family who joined" line), What families did (six figures, "—" and "Shown once N families join" with the server's N), the top three doctors and "All N on the Doctors tab", earnings by kind and status, and the privacy note. Pull to refresh; Try again; P1's empty state until loaded | `lib/screens/partner_app/partner_care_overview.dart` |
| 4 | Your doctors: "N doctors listed · N families in all", a row per doctor / former doctor / the centre's code, "No families yet. Hand out their code." for an empty one, and "No family is ever named: each row is a count. To add a doctor, contact your ParentVeda manager." P1's empty state when the centre has no doctors and no families | `lib/screens/partner_app/partner_care_doctors.dart` |
| 5 | Wiring: `partner_tabs.dart` opens both for a care_org (P1's empty states commented out, kept for revert). `PartnerLoadProblem` takes an optional `onRetry`. Sign-out clears `CareOrgStore` (P1's `PartnerDashboardStore.reset()` stays: P3 does not fill it, but the parent build's doctor mode can) | `partner_tabs.dart`, `partner_sponsor_overview.dart`, `lib/partner_app/partner_sign_out.dart`, `partner_words.dart` |
| 6 | **R5.** `DoctorResolve.orgLogin`: in the standalone ParentVeda+ only, a login whose only identity is a `partner_accounts` row is refused (session not activated), signed out, and told "This account is for ParentVeda Partners, the app for clinics and centres. Sign in there to see your centre's numbers." Both doors: after sign-in, and on boot for a restored session. A login that **also** has `expert_accounts` resolves as a doctor first, unchanged. The parent build's doctor mode is unchanged | `lib/doctor/doctor_session.dart`, `lib/screens/doctor/doctor_auth_screen.dart`, `lib/main_doctor.dart` |
| 6+ | **Found and fixed on the way:** `DoctorAuthScreen` cleared its error on *any* controller notification, including the selection an autofocused field sets on first layout. P1 found this on the Partners sign-in and left ParentVeda+ alone because nothing set an error before first layout; the new boot refusal does, so it now clears only on a change of text | `doctor_auth_screen.dart` |
| 7 | Verify pass: borrows the oldest user as the centre's login and four more as families; walks nobody → nothing → centre below 5 (held back, per-doctor sums) → threshold 2 (shown) → dual login (own practice not mixed in) → no family id or token in the answer → paused → sponsor wins. Rolls back by raising the report | `supabase/seed/verify_care_org_dashboard.sql` |

Tests: `partner_care_org_test` (19: the model, the store, Overview unsuppressed / suppressed with a threshold of 7 /
empty / error, Doctors rows and empty, the 0139 contract on the **latest** definitions, the four shared RPCs still at
0068/0073, wiring). `doctor_app_shell_test` gains the R5 group (3). `doctor_identity_edge_test` updated for the fourth
outcome and the second sign-out. **Run 0139, then `verify_care_org_dashboard.sql`, before the care_org walk.**

**To see it on a phone (Route A).** The demo admin is a sponsor admin, and a sponsor wins, so a care_org walk needs a
second login: create it in Authentication → Users with a password (R6), then
`select public.link_partner_account((select id from auth.users where email = '<that email>'), 'demo_org_ivf', 'demo');`
(Nova IVF Fertility, from `care_partner_demo_orgs.sql`). It has no doctors or families yet, so it opens on the empty
states; the per-doctor table needs `expert_profiles.partner_id = 'demo_org_ivf'` rows and attributions.

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


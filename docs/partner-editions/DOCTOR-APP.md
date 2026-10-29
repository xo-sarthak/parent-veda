# Partner Editions — DOCTOR APP PLAN (ParentVeda+)

> Phases D1–D3. Decisions and defaults (D1–D4, R1–R9) and the session rules live in [MASTER.md](MASTER.md); read its phase table first.

**Today (verified):** `lib/main_doctor.dart` boots 5 stores and resolves identity through
`DoctorSession.resolveFromServer` (`lib/doctor/doctor_session.dart:341–384`): an
`expert_accounts` row first, else `my_care_partner()`. There are five tabs
(`doctor_scaffold.dart:113–119`). Referral data comes from
`lib/care_partner/partner_dashboard_store.dart:175–239` (`partner_impact`, `partner_funnel`,
`partner_earnings`, `my_partner_token`); nothing calls `partner_referral_breakdown`.

## D1: Identity and boot hardening
Edge cases and fixes:
1. **`Supabase.initialize` throws** (`main_doctor.dart:79`, no try/catch): wrap it and boot into a
   calm "Can't reach ParentVeda right now · Try again" screen. Same rule as the parent app: an
   uninitialised backend behaves like signed-out, never crashes.
2. **Offline at launch:** today it's about 12s of spinner, then the sign-in screen, with a live session
   and no explanation. Fix: if a session exists and the resolve *timed out* (distinct from "no
   identity"), show an offline state with Retry instead of the sign-in screen. `resolveFromServer`
   returns an enum (`resolved | notADoctor | unreachable`) instead of a bool.
3. **Sign-out leaves data behind** (`doctor_profile_tab.dart:258–280`): also clear
   `DoctorRoster`, `PrescriptionStore`, `DoctorScheduleStore`, and cancel `DoctorReminders`
   notifications. Test: sign out, then sign in as a different doctor and see none of the first one's bookings.
4. **"Developer · Test as" switch visible in release** (`doctor_profile_tab.dart:203–223`):
   gate it behind `PV_DEV` (as the parent app does). Add it to the BEFORE-LAUNCH line 36 list.
5. **`my_care_partner()` has `limit 1` with no ORDER BY** (0068:209–238): add a deterministic
   order (own-partner first, then `created_at`). Migration.
6. **Member doctor of a clinic** resolves as an expert, but `my_care_partner()` returns nothing,
   so the kit says "code on its way" forever. D1 makes the session *know* its org
   (`expert_profiles.partner_id`, read as `orgPartnerId`) so D2 can show the right thing. The
   header shows "Dr X · Bloom Fertility Centre".
7. **Unknown expert id** (`doctor_directory.dart:96` null): today it falls into the org-style Home.
   Fix: build the profile from the server row (`expert_profiles`), not only the compiled catalogue.
8. **Boot doesn't call `claimInvite()`** (only sign-in does): call it on boot when signed in but
   unresolved, so an invite accepted on another device still lands.
Tests: extend `doctor_app_shell_test` (init failure, offline state), `partner_account_test`
(sign-out clears every store), and add `doctor_identity_edge_test`.

### D1 as built (2026-10-29)
| # | What shipped | Where |
|---|---|---|
| 1 | `startBackend()` wraps `Supabase.initialize`; a failure opens `DoctorCantReach` with Try again, which retries the init and then resolves | `main_doctor.dart`, `screens/doctor/doctor_cant_reach.dart` |
| 2 | `enum DoctorResolve { resolved, notADoctor, unreachable }`. A timeout on the first question returns at once (6s, not 12s); a failure on either is unreachable. The boot shows the signed-in can't-reach screen; the sign-in screen no longer signs out a doctor whose check timed out | `doctor_session.dart`, `doctor_auth_screen.dart` |
| 3 | `forgetDoctorOnThisPhone()`: reminders, session, roster, prescriptions, schedule, ledger, partner dashboard. Reminders now record the booking ids they arm (`doctor_reminders_armed`) so sign-out cancels exactly those, not the parent build's own alarms. Both sign-out paths call it | `doctor/doctor_sign_out.dart`, `doctor_reminders.dart` |
| 3+ | Found: the doctor app never pulled a schedule. `restoreMine(expertId)` fetches hers when the phone has none; a local schedule still wins (it may hold an unpushed edit, and has no timestamp to compare) | `doctor_schedule_store.dart`, `doctor_scaffold.dart` |
| 4 | "Test as" behind `kDebugMode \|\| PV_DEV` | `doctor_profile_tab.dart` |
| 5 | `0132`: own practice first, then `created_at`, then `id` | `supabase/migrations/0132_my_care_partner_order.sql` |
| 6 | `DoctorPublicProfile` keeps `partner_id` + `domain`; the session reads the partner row (public) and keeps it as `orgPartnerId`/`orgName` only when its `expert_id` is not hers. Profile shows "credential · clinic". (Home's hero has no subtitle slot, so the line is on Profile.) | `doctor_session.dart`, `doctor_profile_tab.dart` |
| 7 | `doctorInfoFor(id, profile:)` falls back to her own server row; the five call sites use it | `doctor_directory.dart` + 5 screens |
| 8 | Boot: `notADoctor` while signed in → `claimInvite()` → resolve once more | `main_doctor.dart` |

Tests: `doctor_identity_edge_test` (new, 18), `partner_account_test` (+3), `doctor_app_shell_test` (+3);
`sync_reset_coverage_test` allowlist names the doctor sign-out. Walk owed (STILL-OPEN §5.4q).

## D2: Families you brought + the doctor's own slice
1. Migration: `my_doctor_referrals()` returns `{scanned, installed, signed_up, active_30d,
   booked_me}` for referrals whose `expert_id ∈ my_expert_ids()` **and** that the caller consults as
   (an org login gets none here, R4). An own-partner doctor gets the same numbers as `partner_impact`.
   Test asserting parity for the solo doctor.
2. `my_partner_token()` returns, per R4, the caller's **own** code: a doctor gets the token with
   `expert_id` = them, else the own-partner org token. An org login gets only `expert_id is null`.
   (Today an org can be shown one doctor's code as "your code".) Fixes STILL-OPEN §5.4n too: the kit
   shows the signed-in doctor, not the seeded demo identity.
3. Home card "Families you brought" (`doctor_home_tab.dart`, after This week): Joined · Active · Booked
   you, "Counts only. Families stay private." Empty state: "No families yet. Share your QR" with a
   button to the kit (a feature is never hidden). The store loads on Home, not only from Earnings.
4. "How parents see you": a preview of the parent-app "Your doctor · Dr X, <clinic>" line (the parent
   side is built in A1; this is the same widget, so build it shared in `lib/care_partner/`).
5. **Impact screen error state** (`doctor_impact_screen.dart` has none; `isNotAPartner` unused):
   add an error flag to the store; show "Couldn't load your numbers · Try again"; distinguish a doctor who
   isn't a partner yet ("Your code is being set up. We'll tell you when it's ready").
Tests: `partner_dashboard_test` (new shape, error flag), `doctor_tabs_render_test` (home card
empty and filled), and a SQL contract test for `my_doctor_referrals` columns.

### D2 as built (2026-10-29)
| # | What shipped | Where |
|---|---|---|
| 0 | **Found:** `attribute_to_partner` never copied the token's `expert_id` onto the attribution (0073 documented the column; nothing wrote it), so every per-doctor count was zero. 0133 copies it, blocks a member doctor scanning her own per-doctor code (self-referral), backfills from the token (nulls only), and turns 0037's three-argument form into a forwarder (defaults kept: `create or replace` cannot drop them) | `0133_my_doctor_referrals.sql` |
| 1 | `my_doctor_referrals()` → `{scanned, installed, signed_up, active_30d, booked_me}`. "Me" = her `expert_accounts` row only (not `my_expert_ids()`), so an org login gets zeros. Hers = attributions naming her, plus her own practice's org-wide code. Solo parity by identical definitions with `partner_funnel.signed_up` / `partner_impact.active_this_month`; VERIFY block runs it for real. Booked you = her slots, not cancelled | `0133` |
| 2 | `my_partner_token()`: her per-doctor code (only while `expert_profiles.partner_id` still matches) → her own practice's → an org login's `expert_id is null` code. The store asks for the token and the slice **outside** the partner check, because a member doctor owns no partner row. The kit is ready on the token alone and names the signed-in doctor (`_kitIdentity`); an org login is named as the org. Closes §5.4n | `0133`, `partner_dashboard_store.dart`, `doctor_referral_kit_screen.dart` |
| 3 | Home "Families you brought" after This week: Joined · Active (last 30 days) · Booked you + "Counts only. Families stay private."; empty → "No families yet" + Share your QR; failed → Try again; loading → a bar. Loads on Home (post-frame, since Home already listens) and on pull-to-refresh | `doctor_home_tab.dart` (`_FamiliesCard`) |
| 4 | `YourDoctorLine` + `yourDoctorLabel()` in `lib/care_partner/`, parent palette; Home's "How parents see you" shows it above the public card | `your_doctor_line.dart`, `doctor_home_tab.dart` |
| 5 | `loadFailed` on the store (and `isNotAPartner` is never true after a failure). Impact: "Couldn't load your numbers · Try again"; "Your code is being set up…" when the server says no partner and no code; a member doctor with her own code sees her three counts | `partner_dashboard_store.dart`, `doctor_impact_screen.dart` |

Tests: `doctor_referrals_test` (new, 29: store shape and flags, Home card in four states, Impact in three, kit identity for member / seeded / org, the line, and 0133 contracts). The plan's `doctor_tabs_render_test` and `partner_dashboard_test` additions were put in this one file instead, so D2 reads in one place. Walk owed (STILL-OPEN §5.4r). **Run 0133 before installing.**

## D3: QR rotation keeps per-doctor codes (STILL-OPEN §5.1b)
`rotate_partner_token` retires every token and mints one org-wide token, so per-doctor counts
silently freeze. Fix: rotation re-mints one fresh token per active member doctor
(`mint_partner_token(..., p_expert_id)`) inside the same transaction, keeps the grace window, and
records the reason. Edge cases: a doctor who left the clinic (`partner_id` changed) is not re-minted;
an own-partner doctor rotates only their own token. Extend `care_rotation_test`. Close §5.1b.


# Remaining changes, smallest code work first

Written 2026-10-14, after the small-fixes commit `c1204b0`. Skilling is out of scope.
Items marked **(held)** wait on your word. Sizes are rough: S = under an hour, M = a few hours,
L = a day or more.

## Small

1. **Phases: DONE 2026-10-14 (was items 1 and 2).** The Drive "My Child phase-wise content" docs are
   the only phase text. The old Wonder Weeks leaps are unwired: the Development door tab is "Phases"
   and opens the phase map, and the leaps read and its links are commented out. Phases 1–15 show only
   their doc; phases 16–20 show their name, age and "This phase's guide is being written" until
   PH016–PH020 arrive. STILL-OPEN §85.
   The two leap films are retired too; new phase films to come from you. The leap article
   "Phase 4, decoded" is retired as well.
3. **Yoga ₹599 (S, held).** `prenatal_yoga_screen.dart:111` and `pp_yoga_data.dart:477` hard-code the
   price. Kept for now; it moves to the server price when the backend holds one (STILL-OPEN §83.6).
4. **Parenting yoga "Live group" with no schedule (S, decide).** STILL-OPEN §83.7: show a schedule,
   or say how a time is chosen.
5. **Expert sign-off (held, not code).** No TTC page shows "Reviewed by" today, because the sign-off
   gate in `lib/ttc/ttc_expert_signoff.dart` is empty, so every piece says "By ParentVeda team". The
   doctors' names are still in the data and come back, with the tick, one piece at a time as
   sign-offs return. STILL-OPEN §78.1 is updated to say so (gated, not closed).
5a. **Superfood recipe photos (S).** 8 new recipes have no chosen photo (STILL-OPEN §83.8).
5b. **Parenting Ask Veda colours (S, decide).** It was moved to pregnancy's white and ink, beyond the
   brief (STILL-OPEN §83.11). Keep or revert.

## Medium

6. **Tap feedback, second pass (M).** About 1,400 older taps (mostly parenting) have no press settle
   (STILL-OPEN §83.10). The owed list in §63.8 is done.
7. **Add to calendar (M).** Scans and appointments into the phone's calendar.
8. **Baby vault (M).** Read aloud for the letters, and "open your letters" at birth.
9. **Door consistency pass (M).** One layout and set of controls across every door (STILL-OPEN §83.14).
10. **Flash cards for heavy tools (M).** A short card deck in front of tools that are a lot to take in.

## Large

11. **Recipes screen (L).** Study Mobbin first, then build (STILL-OPEN §83.14).
12. **Keepsake PDF (L).** The pregnancy or baby keepsake, exported as a PDF.
13. **Condition reads (L, content).** The condition pages owed their reads.
14. **Investment explainers (L, content).** The money explainers for parents.
15. **Ask Veda pregnancy review (L, two repos).** Walk the pregnancy answers. Fixes to the answers live
    in `C:\Projects\parentveda-askveda`, so this needs that repo open.

## Needs you, not code

- **Ask Veda hosting.** The Railway trial ended and the service is down. Pick a host or plan.
- **Supabase.** Run migration 0092. Grant the three `service_role` permissions Ask Veda needs.
  Confirm 0088, 0089, 0090 and the expert-photos bucket.
- **Phone OTP.** The `phone-otp-send` and `phone-otp-verify` functions are not deployed; they need
  the MSG91 secrets (STILL-OPEN §83.12).
- **Daily insight tab images.** Marked "to discuss" (STILL-OPEN §83.13).
- **Device checks.** His side of pregnancy, the TTC calendar, and the small fixes (his week page, the
  Talk to someone icon on all three homes, "Up next" on Milestones, the press settle).

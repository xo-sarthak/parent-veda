// =============================================================================
//  Account actions — sign out, delete — shared by every stage's You screen
// -----------------------------------------------------------------------------
//  Two flows that used to live inside the pregnancy profile (with a copy of
//  sign-out inside the TTC one). Lifted here unchanged in behaviour:
//
//  SIGN OUT drops Google's cached account too (Play Services keeps its own,
//  so dropping only our session lets the next Google tap re-enter the same
//  account with no picker), clears the auth flag, then hands back to the
//  auth flow when the pregnancy shell is up (that flow re-loads the profile
//  and re-syncs on success), or pops to the root otherwise.
//
//  ⚠️ AND SINCE 2026-10-17 IT WIPES THIS PHONE. "Local data is not touched"
//  was the rule, and it meant the next person to sign in on the phone had the
//  last person's cycles, logs and saved things merged INTO THEIR ACCOUNT by
//  the first sync. Now a sheet says what happens (Perplexity on Mobbin:
//  "Signing out will clear your history from this device. Synced queries are
//  available upon signing back in"), warns if a change has not reached the
//  account yet, and on confirm the local cache is wiped and every store
//  emptied (`LocalOwner.wipeThisPhone`). The account keeps everything.
//  Signing out of an app that was never signed in wipes nothing: that data
//  belongs to nobody else.
//
//  DELETE ACCOUNT keeps the typed-keyword confirmation and `DeleteAccount.run`
//  (the edge function that answers only for the token's own user). The
//  consequences are shown as bullets before the keyword, Urban Company's
//  shape: a person deleting an account should read what goes with it.
// =============================================================================

import '../auth/onboarding/onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../localization/app_language.dart';
import '../../services/auth/delete_account.dart';
import '../../services/app_shell.dart';
import '../../services/auth/social_auth.dart';
import '../../services/father_preview.dart';
import '../../services/notification_service.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/remote/sync_registry.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/auth/local_owner.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show FabState;
import '../auth/auth_flow_screen.dart';
import 'pv_you_chrome.dart';
import '../../widgets/pv_toast.dart';

/// The words on the sign-out sheet (2026-10-17), here so a test can find them.
const String kPvSignOutTitle = 'Sign out?';
const String kPvSignOutBody =
    'Signing out removes your data from this phone. It stays saved in your '
    'account and comes back when you sign in again.';
const String kPvSignOutPending =
    "Some changes haven't reached your account yet. Connect to the internet "
    'and wait a moment, or sign out anyway and lose them.';

/// Skilling's child records stay on the phone by decision (consent and legal
/// review for children's data, 2026-09; kept so in step 13, 2026-10-22), so
/// "it stays saved in your account" is not true for them. Said only when
/// there is something to lose.
const String kPvSignOutSkilling =
    "Skilling's journal, photos and recordings are kept only on this phone, "
    'so signing out removes them for good.';

/// The prefs keys the five Skilling stores keep (sk_child_store, sk_journal,
/// sk_portfolio, sk_practice_store, sk_voice_keepsake).
const List<String> kPvSkillingKeys = [
  'sk_journal',
  'sk_portfolio',
  'sk_voice',
  'sk_practice',
];

/// True when this phone holds Skilling records a sign-out would remove.
Future<bool> pvHasSkillingOnPhone() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    for (final k in kPvSkillingKeys) {
      final v = prefs.get(k);
      if (v is String && v.isNotEmpty && v != '[]' && v != '{}') return true;
      if (v is List && v.isNotEmpty) return true;
    }
  } catch (_) {}
  return false;
}

/// Asks before signing out, and says what happens to her data. True to go.
Future<bool> pvConfirmSignOut(BuildContext context) async {
  final p = pvStorePalette;
  final pending = SyncRegistry.hasPendingChanges;
  final skilling = await pvHasSkillingOnPhone();
  if (!context.mounted) return false;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(kPvSignOutTitle,
                    style: pvFraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: p.ink1)),
              ),
              PvRoundIcon(
                icon: Icons.close_rounded,
                size: 34,
                onTap: () => Navigator.of(ctx).pop(false),
              ),
            ]),
            const SizedBox(height: 10),
            Text(kPvSignOutBody,
                key: const ValueKey('pv_sign_out_body'),
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
            if (skilling) ...[
              const SizedBox(height: 10),
              Text(kPvSignOutSkilling,
                  key: const ValueKey('pv_sign_out_skilling'),
                  style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
            ],
            if (pending) ...[
              const SizedBox(height: 12),
              Row(
                  key: const ValueKey('pv_sign_out_pending'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(Icons.cloud_off_outlined,
                          size: 17, color: p.ink1),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(kPvSignOutPending,
                          style: pvManrope(
                              fontSize: 13.5,
                              height: 1.45,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                    ),
                  ]),
            ],
            const SizedBox(height: 18),
            InkWell(
              key: const ValueKey('pv_sign_out_confirm'),
              onTap: () => Navigator.of(ctx).pop(true),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.ink1,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(pending ? 'Sign out anyway' : 'Sign out',
                    style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Stay signed in',
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: p.ink2)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return ok == true;
}

Future<void> pvSignOut(BuildContext context) async {
  final nav = Navigator.of(context);
  final controller = PregnancyController.current;
  // Ask first, and say what happens (2026-10-17). Only when signed in: the
  // same function also opens sign-in from the "Not signed in" row.
  final wasSignedIn = SupabaseRepo.isLoggedIn;
  if (wasSignedIn && !await pvConfirmSignOut(context)) return;
  // ⚠️ THREE SEPARATE TRIES, NOT ONE (2026-10-10). The three steps used to
  // share one `try`, so the first failure skipped the rest. The one that
  // fails in practice is `Supabase.instance`, which THROWS when the backend
  // never initialised (offline first launch, a bad key, a widget test), and
  // that skipped clearing the local flag, so the app still believed she was
  // through onboarding. The general point: when steps are independent, one
  // failure must not cancel the others, so each gets its own guard.
  // Trade-off: no step can report why it failed. What it buys is that the
  // local half, the half we own, always happens, and an uninitialised backend
  // behaves exactly like being logged out.
  try {
    await SocialAuth.signOutGoogle();
  } catch (_) {
    /* best-effort: it already swallows its own plugin errors */
  }
  try {
    await Supabase.instance.client.auth.signOut();
  } catch (_) {
    /* no backend, or no network: the local sign-out below still happens */
  }
  try {
    await (await SharedPreferences.getInstance()).setBool(
      kAuthCompletedKey,
      false,
    );
  } catch (_) {
    /* best-effort */
  }
  // ⚠️ THIS PHONE FORGETS THE PERSON (2026-10-17): the local cache is
  // wiped and every store emptied, so the next account to sign in starts
  // clean and nothing of hers is uploaded into it. Her account keeps it all.
  if (wasSignedIn) {
    try {
      await LocalOwner.wipeThisPhone();
    } catch (_) {/* best-effort */}
  }
  // Signed out means silent (2026-10-10): no reminder rings for someone who
  // has left. See NotificationService.silenceForSignOut.
  //
  // ⚠️ AFTER THE WIPE, NOT BEFORE (2026-10-21, sync log step 12). It used to
  // run first, and the wipe's `prefs.clear()` then deleted the very flag it
  // had set, so the next reminder any store scheduled rang for someone who
  // had signed out. The general point: a "clear everything" step undoes any
  // state written before it, so state that must survive goes after. Kept for
  // revert: this block sat above the wipe.
  try {
    await NotificationService.instance.silenceForSignOut();
  } catch (_) {/* best-effort */}
  // The Ask Veda button stays off the sign-in screens.
  FabState.instance.markAppSignedOut();
  // ⚠️ THE WHOLE STACK GOES (2026-10-10). This used to push onboarding ON TOP
  // of the signed-in app, so back returned into it; and with no pregnancy
  // controller it popped to the first route, which is the stage's own home,
  // so the tap appeared to do nothing. Now the stack is replaced by the
  // cold-start splash, which reads the cleared flag and opens onboarding, and
  // on finishing lands her in the home of the stage she picks. See
  // AppShell.openSignedOut. The branches below are the fallback when nothing
  // is registered (a widget test that pumped a screen directly), kept as
  // they were.
  if (AppShell.openSignedOut(nav)) return;
  if (controller == null) {
    nav.popUntil((r) => r.isFirst);
    return;
  }
  nav.push(
    MaterialPageRoute<void>(
      // ⚠️ SIGN OUT USED TO LAND ON THE OLD SCREEN — 2026-09-22. The splash
      // has pushed `OnboardingFlow` since it was built, but this door still
      // opened `AuthFlowScreen`, so the single most common way to see the
      // first-run experience — sign out and look — showed the retired one.
      // That is the wiring gate exactly: correct code nobody reaches. The old
      // screen stays as the DOCTOR and PARTNER branch (the flow pushes it
      // itself for those), and as the body this is kept for revert:
      //   builder: (_) => AuthFlowScreen(onDone: …, onDoctor: …),
      builder: (_) => OnboardingFlow(
        pregnancy: controller,
        onDone: (stageId, isFather) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(kAuthCompletedKey, true);
            await prefs.setString(kUserRoleKey, isFather ? 'father' : 'mother');
          } catch (_) {
            /* best-effort */
          }
          await controller.loadProfileFromCloud();
          SyncRegistry.resyncAll();
          if (isFather) {
            FatherPreview.instance.on = true;
            nav.popUntil((r) => r.isFirst);
          } else {
            FatherPreview.instance.on = false;
            nav.pop();
          }
        },
      ),
    ),
  );
}

/// The consequences, the keyword, the call, the goodbye.
Future<void> pvDeleteAccount(BuildContext context) async {
  final p = pvStorePalette;
  final s = S.now;
  final input = TextEditingController();
  final nav = Navigator.of(context);

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: input,
            builder: (ctx, v, _) {
              final ok =
                  v.text.trim().toUpperCase() ==
                  kDeleteAccountKeyword.toUpperCase();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Delete your account',
                          style: pvFraunces(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: p.ink1,
                          ),
                        ),
                      ),
                      PvRoundIcon(
                        icon: Icons.close_rounded,
                        size: 34,
                        onTap: () => Navigator.of(ctx).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final t in const [
                    'Everything you logged, saved, wrote and ordered is deleted from our servers.',
                    'Your children\'s records go with it.',
                    'A paired partner loses the link, not their own account.',
                    'Bookings you have paid for are not refunded by this.',
                    'It cannot be undone.',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•  ',
                            style: pvManrope(fontSize: 13.5, color: p.ink2),
                          ),
                          Expanded(
                            child: Text(
                              t,
                              style: pvManrope(
                                fontSize: 13.5,
                                height: 1.45,
                                color: p.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Type $kDeleteAccountKeyword to confirm',
                    style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: input,
                    autofocus: true,
                    style: pvManrope(fontSize: 15, color: p.ink1),
                    decoration: InputDecoration(
                      hintText: kDeleteAccountKeyword,
                      hintStyle: pvManrope(fontSize: 14, color: p.ink3),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: kPvLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: p.ink1, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: ok ? () => Navigator.of(ctx).pop(true) : null,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ok ? const Color(0xFFC6295A) : p.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Delete my account',
                        style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ok ? Colors.white : p.ink3,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
  // ⚠️ NOT DISPOSED THE MOMENT THE SHEET CLOSES (2026-10-01, the user: a red
  // screen, "'_dependents.isEmpty': is not true", on Delete account). The
  // future completes when the route is popped, but the sheet is still on
  // screen for its exit animation and its field and listener are still
  // attached to [input]; disposing under them tore the tree down mid-frame.
  // The name editor in pv_you_screen.dart waits for the same reason. Kept for
  // revert: `input.dispose();` here.
  Future<void>.delayed(const Duration(milliseconds: 600), input.dispose);
  if (confirmed != true) return;

  // One notice that turns from "working" into the answer, in place.
  // ignore: use_build_context_synchronously
  final working = pvToastWorking(nav.context, s.deleteAccountWorking);
  final ok = await DeleteAccount.run();
  if (!ok) {
    working.gentle(s.deleteAccountFailed);
    return;
  }
  working.dismiss();
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(s.deleteAccountDoneTitle),
      content: Text(s.deleteAccountDoneBody),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            // Same landing as sign out (2026-10-10): the account is gone, so
            // the app it belonged to must not stay on screen underneath.
            // Kept for revert: nav.popUntil((r) => r.isFirst);
            FabState.instance.markAppSignedOut();
            if (!AppShell.openSignedOut(nav)) {
              nav.popUntil((r) => r.isFirst);
            }
          },
          child: Text(s.closeLabel),
        ),
      ],
    ),
  );
}

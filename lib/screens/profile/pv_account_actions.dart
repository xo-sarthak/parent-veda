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
//  and re-syncs on success), or pops to the root otherwise. Local data is
//  not touched — local-first means signing out is not deleting.
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
import '../../services/auth/social_auth.dart';
import '../../services/father_preview.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/remote/sync_registry.dart';
import '../../theme/pv_fonts.dart';
import '../auth/auth_flow_screen.dart';
import 'pv_you_chrome.dart';

Future<void> pvSignOut(BuildContext context) async {
  final nav = Navigator.of(context);
  final controller = PregnancyController.current;
  try {
    await SocialAuth.signOutGoogle();
    await Supabase.instance.client.auth.signOut();
    await (await SharedPreferences.getInstance()).setBool(
      kAuthCompletedKey,
      false,
    );
  } catch (_) {
    /* best-effort */
  }
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
  final messenger = ScaffoldMessenger.of(context);
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

  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(s.deleteAccountWorking)));
  final ok = await DeleteAccount.run();
  messenger.clearSnackBars();
  if (!ok) {
    messenger.showSnackBar(SnackBar(content: Text(s.deleteAccountFailed)));
    return;
  }
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
            nav.popUntil((r) => r.isFirst);
          },
          child: Text(s.closeLabel),
        ),
      ],
    ),
  );
}

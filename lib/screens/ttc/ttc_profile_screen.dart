// =============================================================================
//  TTC Profile - the account surface the stage never had
// -----------------------------------------------------------------------------
//  Before this, the TTC shell was five tabs and a logo with no actions: no
//  language control, no sign-out, no way to correct anything. Three consequences,
//  all real:
//
//    * Hinglish was UNREACHABLE for anyone who signed up as trying-to-conceive.
//      TtcLang was only ever set by the door on the pregnancy home, so a family
//      who landed here from the splash had thousands of words of Hinglish
//      written for them and no way to see any of it.
//    * There was no sign-out anywhere in the stage.
//    * Once `pv_life_stage` was 'trying', the splash made ttc/today the root and
//      nothing routed back - one system-back press exited the app.
//
//  Mirrors the pregnancy Profile deliberately, including its convention of
//  labelling a testing-only affordance "· testing" in the open, which that
//  screen already does twice.
//
//  ---------------------------------------------------------------------------
//  WHY THE STAGE SWITCH IS A TESTING AFFORDANCE AND NOT A FEATURE
//
//  A family trying to conceive is not pregnant, and pregnancy content would land
//  badly on someone in the middle of a hard month. Their real way forward is
//  recording a positive test, which carries the journey across rather than
//  dropping them into a different app. The switch exists so the team can move
//  between shells without re-onboarding - the same reason the pregnancy Profile
//  carries "Reset to Week 20 · testing".
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/life_stage_store.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_store.dart';
import '../auth/auth_flow_screen.dart' show kAuthCompletedKey;
import 'ttc_common.dart';
import 'ttc_strings.dart';

void openTtcProfile(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcProfileScreen(),
    settings: const RouteSettings(name: 'ttc/profile'),
  ));
}

class TtcProfileScreen extends StatelessWidget {
  const TtcProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcLang.instance, TtcStore.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final today = TtcStore.instance.today;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
              TtcBackBar(title: t.profileTitle),
              const SizedBox(height: 20),

              // Who and where - the same two lines the pregnancy Profile opens
              // with, so the stages read as one app.
              Row(children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: ttcPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline_rounded,
                      size: 26, color: ttcPurple),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(today.chapter.title(hi), style: ttcJakarta(17)),
                        const SizedBox(height: 3),
                        Text(today.chapter.focus(hi), style: ttcBody(12.5)),
                      ]),
                ),
              ]),
              const SizedBox(height: 24),

              // ---- language ------------------------------------------------
              //  The reason this screen exists.
              TtcCard(
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ttcPanel,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.translate_rounded,
                        size: 19, color: ttcPurple),
                  ),
                  const SizedBox(width: 13),
                  Expanded(child: Text(t.profileLanguage, style: ttcJakarta(15))),
                  _LangSegment(hi: hi, t: t),
                ]),
              ),
              const SizedBox(height: 14),

              // ---- partner -------------------------------------------------
              //  Says what is true rather than offering a button that does
              //  nothing. Pairing is real work and it is not done.
              TtcCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.favorite_border_rounded,
                            size: 17, color: ttcPurple),
                        const SizedBox(width: 9),
                        Text(t.profilePartner, style: ttcJakarta(15)),
                      ]),
                      const SizedBox(height: 9),
                      Text(t.profilePartnerSoon, style: ttcBody(12.5, h: 1.55)),
                    ]),
              ),
              const SizedBox(height: 24),

              // ---- testing -------------------------------------------------
              ttcSectionTitle(t.profileStageSwitch),
              TtcCard(
                color: ttcPanel,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.profileStageSwitchBody, style: ttcBody(12.5, h: 1.55)),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => _toPregnancy(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: ttcPurple, width: 1.2),
                          ),
                          child: Text(t.profileGoPregnancy,
                              style: ttcBody(13.5,
                                  color: ttcPurple, w: FontWeight.w800)),
                        ),
                      ),
                    ]),
              ),
              const SizedBox(height: 24),

              // ---- sign out ------------------------------------------------
              TtcCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.profileSignOutBody, style: ttcBody(12.5, h: 1.55)),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => _signOut(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: const Color(0xFFE9A0A8), width: 1.2),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout_rounded,
                                    size: 16, color: Color(0xFFD9556A)),
                                const SizedBox(width: 8),
                                Text(t.profileSignOut,
                                    style: ttcBody(13.5,
                                        color: const Color(0xFFD9556A),
                                        w: FontWeight.w800)),
                              ]),
                        ),
                      ),
                    ]),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Hands the app back to the pregnancy shell.
  ///
  /// Sets the stage and pops to the root, which re-runs the splash's routing.
  /// Deliberately does NOT touch the due date or write a timeline event - that
  /// is what the positive-test transition is for, and conflating the two would
  /// make a testing switch look like a life event.
  Future<void> _toPregnancy(BuildContext context) async {
    final nav = Navigator.of(context);
    LifeStageStore.instance.setStage(LifeStage.pregnancy);
    try {
      await (await SharedPreferences.getInstance())
          .setString(LifeStageStore.kLifeStageKey, LifeStage.pregnancy.id);
    } catch (_) {/* best-effort, same as every other TTC write */}
    nav.popUntil((r) => r.isFirst);
  }

  /// Same shape as the pregnancy Profile's: clear the session and the local
  /// flag, then replay the auth flow over the app.
  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    try {
      await Supabase.instance.client.auth.signOut();
      await (await SharedPreferences.getInstance())
          .setBool(kAuthCompletedKey, false);
    } catch (_) {/* best-effort */}
    nav.popUntil((r) => r.isFirst);
  }
}

/// Hinglish | English, matching the pregnancy Profile's segmented control.
class _LangSegment extends StatelessWidget {
  const _LangSegment({required this.hi, required this.t});

  final bool hi;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool active, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? ttcPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: ttcBody(12.5,
                    color: active ? Colors.white : ttcSoft,
                    w: FontWeight.w800)),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ttcPanel,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg(t.profileHinglish, hi, () => TtcLang.instance.hinglish = true),
        seg(t.profileEnglish, !hi, () => TtcLang.instance.hinglish = false),
      ]),
    );
  }
}

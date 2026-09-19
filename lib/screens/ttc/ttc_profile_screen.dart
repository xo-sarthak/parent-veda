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
import '../../services/auth/social_auth.dart';
import '../profile/pv_you_screen.dart';
import 'ttc_common.dart';
import 'ttc_home_version.dart';
import 'ttc_journey_map_screen.dart';
import 'ttc_strings.dart';

// ⚠️ FACADE since 2026-09-19. Both the opener and the screen land on the
// unified You screen (`lib/screens/profile/pv_you_screen.dart`) for the
// trying stage. The body below is kept, byte for byte, as
// `TtcProfileScreenClassic` for revert; nothing pushes it. Its language,
// sign-out and testing switches all have a home on You (Preferences, Account
// and the debug-only Developer section).
void openTtcProfile(BuildContext context) =>
    openPvYou(context, stage: LifeStage.tryingToConceive);

class TtcProfileScreen extends StatelessWidget {
  const TtcProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PvYouScreen(stage: LifeStage.tryingToConceive);
}

/// The pre-2026-09-19 TTC profile. Kept for revert; nothing pushes it.
class TtcProfileScreenClassic extends StatelessWidget {
  const TtcProfileScreenClassic({super.key});

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
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
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

              // ---- your chapter --------------------------------------------
              //
              // ⚠️ THIS IS NOW THE ONLY DOOR TO THE JOURNEY MAP ON V3. The V3
              // home carried it as a chip above the big line; moving it here
              // is what was asked for, and the cost is real and worth stating:
              // "which chapter am I in" is a question this stage generates
              // constantly, and the answer went from always-visible to two taps
              // away. If the map's usage falls, this is why.
              //
              // Reachability is intact, which is the part that is not
              // negotiable — see the wiring gate in CLAUDE.md.
              ttcSectionTitle(t.profileYourChapter),
              TtcCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'ttc/journey_map'),
                  builder: (_) => const TtcJourneyMapScreen(),
                )),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ttcPanel,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.map_outlined,
                        size: 19, color: ttcPurple),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(today.chapter.title(hi), style: ttcJakarta(15)),
                          const SizedBox(height: 2),
                          Text(t.profileJourneyMap, style: ttcBody(12)),
                        ]),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: ttcMuted),
                ]),
              ),
              const SizedBox(height: 24),

              // ---- testing -------------------------------------------------
              //
              // ⚠️ BOTH DEV TOGGLES LIVE HERE NOW, NOT FLOATING OVER THE HOME.
              //
              // They were two pills pinned over the Today screen — one on each
              // bottom corner — which is where a sandbox control is easiest to
              // reach and worst to look at: they overlapped the door grid, sat
              // on top of the Ask FAB's clearance, and appeared in every
              // screenshot anyone took of the product.
              //
              // ⚠️ AND PROFILE IS THE ONLY PLACE THEY COULD GO. The version
              // toggle has to be reachable from the version that is DEFAULT —
              // Current — or V3 becomes unreachable the moment it stops being
              // pinned to the home. Profile is on both versions and on both
              // partners' shells, which makes it the one surface that can hold
              // a control for switching between them.
              ttcSectionTitle(t.profileTesting),
              TtcCard(
                color: ttcPanel,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⚠️ THE SEGMENT SITS BELOW ITS LABEL, NOT TRAILING IT.
                      //
                      // Trailing, both controls sat hard against the right
                      // edge — which is where the Ask Veda FAB floats, over
                      // every route, in no screen's layout. The version toggle
                      // was rendered underneath it and could not be tapped.
                      //
                      // `ttcBottomInset` protects the END of a scroll from the
                      // FAB; nothing protects the right edge mid-list. So the
                      // rule for this stage is: no interactive control pinned
                      // to the right margin outside the bottom inset.
                      Text(t.profileHomeVersion, style: ttcJakarta(14)),
                      const SizedBox(height: 6),
                      Text(t.profileHomeVersionBody,
                          style: ttcBody(12, h: 1.5)),
                      const SizedBox(height: 11),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: _VersionSegment()),
                      const SizedBox(height: 16),
                      ttcDivider(),
                      const SizedBox(height: 16),
                      Text(t.profileViewAs, style: ttcJakarta(14)),
                      const SizedBox(height: 6),
                      Text(t.profileViewAsBody, style: ttcBody(12, h: 1.5)),
                      const SizedBox(height: 11),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: _ModeSegment(t: t)),
                    ]),
              ),
              const SizedBox(height: 24),

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
  /// Hands the app back to the pregnancy shell where that is possible, and says
  /// so plainly where it is not.
  ///
  /// The stage is written FIRST and the navigation is second, in that order on
  /// purpose. If the swap fails we are still in the state she asked for, and the
  /// next launch honours it; if the write failed we would have moved her into a
  /// shell the app does not believe she is in.
  ///
  /// `leaveTtcForPregnancy` handles both stacks this button can sit on - see its
  /// doc in `ttc_common.dart`. The snackbar is now the genuinely-stuck path
  /// only, not the ordinary one.
  Future<void> _toPregnancy(BuildContext context) async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final t = TtcS.current();

    LifeStageStore.instance.setStage(LifeStage.pregnancy);

    if (!leaveTtcForPregnancy(nav)) {
      messenger.showSnackBar(SnackBar(
        content: Text(t.stageSetReopen),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ));
    }
  }

  /// Same shape as the pregnancy Profile's: clear the session and the local
  /// flag, then replay the auth flow over the app.
  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    try {
      // Same reason as the pregnancy Profile's sign-out: Play Services keeps
      // its own cached account, so dropping only our session would let the next
      // Google tap re-enter the same account with no picker.
      await SocialAuth.signOutGoogle();
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


/// Current | V3, in Profile.
///
/// ⚠️ IT SUBSCRIBES TO THE STORE ITSELF. `TtcHomeVersionStore` notifies, and a
/// `const` child of a rebuilt ancestor is canonicalised by Dart — so the
/// segment would keep showing the old selection while the home behind it
/// changed. That bug has appeared five times in this codebase; the rule is that
/// a widget displaying store state listens to that store.
class _VersionSegment extends StatelessWidget {
  const _VersionSegment();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: TtcHomeVersionStore.instance,
        builder: (context, _) {
          final store = TtcHomeVersionStore.instance;
          Widget seg(String label, TtcHomeVersion v) {
            final on = store.version == v;
            return GestureDetector(
              onTap: () => store.set(v),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: on ? ttcPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(label,
                    style: ttcBody(12,
                        color: on ? Colors.white : ttcMuted,
                        w: FontWeight.w800)),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ttcLine),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              seg('Current', TtcHomeVersion.v1),
              seg('V3', TtcHomeVersion.v3),
            ]),
          );
        },
      );
}

/// Her | Him, in Profile. Same listening rule as above.
class _ModeSegment extends StatelessWidget {
  const _ModeSegment({required this.t});

  final TtcS t;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: TtcPartnerMode.instance,
        builder: (context, _) {
          final him = TtcPartnerMode.instance.on;
          Widget seg(String label, bool on, VoidCallback tap) =>
              GestureDetector(
                onTap: tap,
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  decoration: BoxDecoration(
                    color: on ? (him ? ttcSlate : ttcPurple) : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(label,
                      style: ttcBody(12,
                          color: on ? Colors.white : ttcMuted,
                          w: FontWeight.w800)),
                ),
              );

          return Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ttcLine),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              seg(t.partnerHer, !him, () => TtcPartnerMode.instance.on = false),
              seg(t.partnerHim, him, () => TtcPartnerMode.instance.on = true),
            ]),
          );
        },
      );
}

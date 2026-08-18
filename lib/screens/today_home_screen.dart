// =============================================================================
//  TodayHomeScreen — one door, two Todays
// -----------------------------------------------------------------------------
//  The Today tab now opens THIS, which decides which home is on screen:
//
//      Classic  the shipped Today (home_screen_b.dart), untouched
//      Focus    the experiment  (home_focus_screen.dart)
//
//  WHY A WRAPPER RATHER THAN AN EDIT. Editing the shipped home to add a mode
//  would mean the thing being compared against is no longer the thing that
//  ships. The Grow experiment already learned this: "V1 IS THE REAL SCREEN, NOT
//  A COPY". Classic here constructs HomeScreenB exactly as MainScaffold used
//  to, so nothing about it changes while the experiment runs — and if Focus is
//  dropped, deleting this file and restoring one line in main_scaffold is the
//  whole revert.
//
//  THE PILL FLOATS in a Stack rather than being pushed into either home's
//  header, for the same reason: Classic gets a toggle without a single line of
//  Classic changing.
//
//  DEFAULT IS CLASSIC. An experiment that opts everyone in by default is not an
//  experiment, it is a release.
// =============================================================================

import 'package:flutter/material.dart';
import 'v2/v2_palette.dart';
// Kept for revert with the GroundPicker below.
// ignore: unused_import
import 'v2/ground_picker.dart';

import '../services/home_content_controller.dart';
import '../services/landing_focus.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'home_focus_screen.dart';
import 'home_v3_screen.dart';
import 'home_screen_b.dart';

/// Which Today is on screen. Session-only on purpose — see [TodayVersionStore].
enum TodayVersion { classic, focus, v3 }

/// The toggle's state.
///
/// NOT PERSISTED, deliberately, and this is the one decision here worth
/// arguing about. A persisted toggle means a reviewer opens the app days later
/// still in an experimental home and reports its bugs as the product's. Session
/// -only means every launch starts from what actually ships, and seeing the
/// experiment is always a deliberate act.
///
/// LandingFocus, by contrast, IS persisted — because that is a parent's real
/// preference about her own app, not a reviewer's temporary lens.
class TodayVersionStore extends ChangeNotifier {
  TodayVersionStore._();
  static final TodayVersionStore instance = TodayVersionStore._();

  TodayVersion _v = TodayVersion.classic;
  TodayVersion get version => _v;

  void set(TodayVersion v) {
    if (_v == v) return;
    _v = v;
    notifyListeners();
  }
}

class TodayHomeScreen extends StatefulWidget {
  const TodayHomeScreen({
    super.key,
    required this.pregnancy,
    required this.home,
  });

  final PregnancyController pregnancy;
  final HomeContentController home;

  @override
  State<TodayHomeScreen> createState() => _TodayHomeScreenState();
}

class _TodayHomeScreenState extends State<TodayHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Local-first: read her saved focus before the first frame that needs it.
    // Safe to call repeatedly — init() returns early once loaded.
    LandingFocus.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ LISTENS TO BOTH STORES, AND THE SECOND ONE IS A BUG FIX.
    //
    // It listened to `TodayVersionStore` only. `AppTheme.scaffoldBackground` and
    // friends are now getters that read the ground store — so switching the
    // ground changed what they RETURN and repainted nothing, because no widget
    // above Classic had been told to rebuild.
    //
    // V3 appeared to work and Classic appeared broken, which made it look like a
    // Classic problem. It was neither: V3 listens to `V2PaletteStore` inside
    // itself, Classic does not, and the shared parent listened to neither.
    //
    // ⚠️ THE GENERAL LESSON, worth more than the fix: **turning a `const` into a
    // getter changes the VALUE but not the DEPENDENCY.** Flutter repaints on
    // notification, not on a value differing from last frame. A dynamic token is
    // only half a migration until something listens to it.
    return ListenableBuilder(
      listenable: Listenable.merge(
          [TodayVersionStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final v = TodayVersionStore.instance.version;
        final body = switch (v) {
          // The screen that ships today, constructed exactly as MainScaffold
          // used to construct it. Do not replace this with a copy.
          TodayVersion.classic => HomeScreenB(
              pregnancy: widget.pregnancy,
              home: widget.home,
            ),
          TodayVersion.focus => HomeFocusScreen(
              pregnancy: widget.pregnancy,
              home: widget.home,
            ),
          // Direction "2a" from the Claude Design pass. Sits beside the other
          // two rather than replacing either — three versions on one phone is
          // the only way to compare them honestly.
          TodayVersion.v3 => HomeV3Screen(
              pregnancy: widget.pregnancy,
              home: widget.home,
            ),
        };
        return Stack(children: [
          Positioned.fill(child: body),
          // BOTTOM LEFT, not top right.
          //
          // Top-right is where the shipped Today puts its header icons — the
          // bookmark, search, profile and menu — and the pill landed squarely
          // on top of three of them, so Classic could not be used while the
          // toggle was on screen. Found on a device; it is not visible in the
          // code, because the header lives in the OTHER file.
          //
          // Bottom-left is the one free corner: the Ask Veda FAB owns
          // bottom-right, and the Mom|Dad testing pill floats at bottom: 96 on
          // this exact tab. Matching that offset puts the two testing controls
          // at the same height on opposite sides, which reads as chrome rather
          // than as content.
          Positioned(
            bottom: 96,
            left: 16,
            // TWO CONTROLS, STACKED, ONE CORNER.
            //
            // ⚠️ The version pill is STILL NEEDED and that is not sentiment:
            // Classic is better wired and its content is more finished than
            // V3's, so it remains the honest thing to compare against. What was
            // dropped is FOCUS — three versions was the part nobody was choosing
            // between any more, and it made the pill wide enough to clip the
            // door labels behind it.
            //
            // The ground picker goes ABOVE the version pill rather than beside
            // it, because the two ask different questions and a single row of
            // six segments reads as one control with six options.
            //
            // NOT const on the pill. A const widget is canonicalised, so it
            // never rebuilt when the store changed: the body swapped while the
            // pill went on showing the old selection.
            // ⚠️ THE GROUND PICKER IS OFF. Kept for revert:
            //
            //   const GroundPicker(),
            //   const SizedBox(height: 8),
            //
            // It did its job. Four whites were compared on a real phone, and
            // #F5F3F6 won on measurement rather than taste — it was the only
            // candidate leaving a white card a usable edge against the page
            // (+4.9 L, against +0.8 at pure white). `_baseline` in
            // `v2_palette.dart` and the four `AppTheme` ground getters all carry
            // that value now, so the comparison has nothing left to compare.
            //
            // The reason it comes out rather than staying as a harmless debug
            // affordance: it floated over the bottom of every screen and covered
            // two rows of door labels and the referral card. A control that
            // obscures the thing it exists to help you judge has stopped helping.
            //
            // ⚠️ IF THIS COMES BACK, `GroundPicker` STILL WORKS — the store,
            // `GroundSpec`, `kGrounds` and the four `AppTheme` getters are all
            // untouched. Uncommenting the two lines is the whole revert. That is
            // also the reason those tokens stayed getters rather than being
            // folded back to consts: reverting a const would mean re-editing 66
            // call sites.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _TodayVersionPill(),
              ],
            ),
          ),
        ]);
      },
    );
  }
}

class _TodayVersionPill extends StatelessWidget {
  const _TodayVersionPill();

  @override
  Widget build(BuildContext context) {
    final store = TodayVersionStore.instance;
    Widget seg(String label, TodayVersion v) {
      final on = store.version == v;
      return GestureDetector(
        onTap: () => store.set(v),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: on ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: on ? Colors.white : AppTheme.primary,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // ⚠️ FOCUS IS GONE FROM THE PILL, NOT FROM THE APP.
        // `TodayVersion.focus` and `home_focus_screen.dart` both still exist and
        // still work — the value is simply no longer offered, because nobody is
        // choosing between three homes any more. Restore the line below to get
        // it back.
        //
        // seg('Focus', TodayVersion.focus),
        seg('Classic', TodayVersion.classic),
        seg('V3', TodayVersion.v3),
      ]),
    );
  }
}

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

import '../services/home_content_controller.dart';
import '../services/landing_focus.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'home_focus_screen.dart';
import 'home_screen_b.dart';

/// Which Today is on screen. Session-only on purpose — see [TodayVersionStore].
enum TodayVersion { classic, focus }

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
    return ListenableBuilder(
      listenable: TodayVersionStore.instance,
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
            // NOT const. A const widget is canonicalised, so this one never
            // rebuilt when the store changed: the body swapped to Focus while
            // the pill went on showing Classic as selected.
            child: _TodayVersionPill(),
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
        seg('Classic', TodayVersion.classic),
        seg('Focus', TodayVersion.focus),
      ]),
    );
  }
}

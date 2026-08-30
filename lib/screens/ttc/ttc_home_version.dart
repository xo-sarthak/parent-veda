// =============================================================================
//  The TTC home's V1 / V3 toggle
// -----------------------------------------------------------------------------
//  Fourth toggle of this exact shape — `GrowVersionStore`, `WalletVersionStore`,
//  `NameVersionStore`, `PpHomeVersionStore`. Singleton ChangeNotifier, a wrapper
//  that swaps the body, a floating pill in a Stack so V1 needs no edits at all.
//
//  ⚠️ V1 IS `TtcTodayScreen` AND IS NOT TOUCHED. It is the most carefully
//  clinically-reviewed screen in the product — `ttc_home_hero_test`,
//  `ttc_today_shape_test`, `ttc_clinical_review_test` and
//  `ttc_rhythm_honesty_test` all hold it — and none of that is at risk here,
//  because nothing about it changes.
//
//  SESSION-SCOPED, NOT PERSISTED. Same call as the other three: nobody should
//  open the app days later in an experimental home and report its layout as the
//  product's.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'ttc_common.dart';
import 'ttc_home_v3.dart';
import 'ttc_intro_flow.dart';
import 'ttc_today_screen.dart';

enum TtcHomeVersion {
  /// `TtcTodayScreen` — what ships today.
  v1,

  /// The bracket grid.
  v3,
}

class TtcHomeVersionStore extends ChangeNotifier {
  TtcHomeVersionStore._();
  static final TtcHomeVersionStore instance = TtcHomeVersionStore._();

  TtcHomeVersion _v = TtcHomeVersion.v1;
  TtcHomeVersion get version => _v;

  void set(TtcHomeVersion v) {
    if (v == _v) return;
    _v = v;
    notifyListeners();
  }
}

/// What the splash and the stage doors push instead of `TtcTodayScreen`.
///
/// ⚠️ IT ALSO OWNS THE FIRST-RUN GATE, and this is the only place that can. The
/// introduction has to run on ARRIVING IN THE STAGE — which is not the same
/// moment as signing up, because a woman can reach TTC from the pregnancy
/// home's doorway months after creating an account. Every route into the stage
/// goes through this widget (`openTtc`, the splash, the profile's stage switch),
/// so gating here is what makes "once, on first arrival" actually mean that.
///
/// ⚠️ AND IT GATES BOTH VERSIONS, NOT JUST V3. The rest of this batch is V3-only
/// by instruction; the introduction is not a home design, it is the stage's
/// front door, and a woman toggled onto V1 who has never seen the stage needs it
/// just as much. Nothing it writes is V3-specific — a period date, a journey
/// start and a pathway are read by V1's screens identically.
class TtcHomeScreen extends StatefulWidget {
  const TtcHomeScreen({super.key});

  @override
  State<TtcHomeScreen> createState() => _TtcHomeScreenState();
}

class _TtcHomeScreenState extends State<TtcHomeScreen> {
  /// null = still asking `shared_preferences`.
  ///
  /// ⚠️ THREE STATES, NOT TWO. Rendering the home while the answer is unknown
  /// and swapping to the introduction a frame later is the flicker every
  /// first-run flow ships with once; holding an empty ground for one frame is
  /// invisible and correct.
  bool? _introOwed;

  @override
  void initState() {
    super.initState();
    TtcIntroGate.owed().then((owed) {
      if (mounted) setState(() => _introOwed = owed);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_introOwed == null) {
      return const Scaffold(backgroundColor: ttcBg, body: SizedBox.shrink());
    }
    if (_introOwed == true) {
      return TtcIntroFlow(onDone: () => setState(() => _introOwed = false));
    }
    return const _TtcHomeBody();
  }
}

class _TtcHomeBody extends StatelessWidget {
  const _TtcHomeBody();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: TtcHomeVersionStore.instance,
        builder: (context, _) => Stack(children: [
          switch (TtcHomeVersionStore.instance.version) {
            TtcHomeVersion.v1 => const TtcTodayScreen(),
            TtcHomeVersion.v3 => const TtcHomeV3(),
          },
          // ⚠️ LEFT AND HIGH, not bottom-right. TTC's Ask FAB has its own
          // clearance rules — `test/ttc_fab_clearance_test.dart` exists because
          // this stage's bottom-right corner is already spoken for — and a
          // control that switches the experiment must not sit under the thing
          // it is being compared against.
          // Top right, like the other two stages. See the note in
          // pp_home_version.dart for why the bottom strip was the wrong place
          // for it in the first place.
          Positioned(
              right: 14,
              top: MediaQuery.of(context).viewPadding.top + 56,
              child: const _Pill()),
        ]),
      );
}

/// Sandbox chrome. Goes when one of the two wins.
///
/// ⚠️ IT SUBSCRIBES TO THE STORE ITSELF even though the wrapper above already
/// rebuilds on every change, and that is not redundancy. A `const` widget is
/// canonicalised by Dart, so a rebuild produces an instance IDENTICAL to the
/// previous one and Flutter short-circuits the subtree — the body swaps and the
/// pill goes on showing the old segment. That bug has now appeared five times in
/// this codebase.
///
/// The rule: **a widget that displays store state subscribes to that store
/// itself.** Ancestor rebuilds are an optimisation, not a guarantee.
class _Pill extends StatelessWidget {
  const _Pill();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: TtcHomeVersionStore.instance,
        builder: (context, _) => _pill(),
      );

  Widget _pill() {
    final store = TtcHomeVersionStore.instance;
    Widget seg(String label, TtcHomeVersion v) {
      final on = store.version == v;
      return InkWell(
        onTap: () => store.set(v),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: on ? AppTheme.primary600 : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : AppTheme.primary700)),
        ),
      );
    }

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          seg('Current', TtcHomeVersion.v1),
          seg('V3', TtcHomeVersion.v3),
        ]),
      ),
    );
  }
}

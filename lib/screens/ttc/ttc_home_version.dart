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
import 'ttc_home_v3.dart';
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
class TtcHomeScreen extends StatelessWidget {
  const TtcHomeScreen({super.key});

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
          const Positioned(left: 16, bottom: 96, child: _Pill()),
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

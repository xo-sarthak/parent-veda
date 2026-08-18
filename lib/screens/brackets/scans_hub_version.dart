// =============================================================================
//  Scans & tests — the V1 / V2 toggle
// -----------------------------------------------------------------------------
//  Sixth toggle of this exact shape — `GrowVersionStore`, `WalletVersionStore`,
//  `NameVersionStore`, `PpHomeVersionStore`, `TtcHomeVersionStore`. Singleton
//  ChangeNotifier, a wrapper that swaps the body, a floating pill in a Stack so
//  V1 needs no edits at all.
//
//  ⚠️ V1 IS NOT TOUCHED. `kScansHub` keeps its six doors, its urgent strip and
//  its red-flag door, and `scans_hub_test.dart` / `problem_hub_test.dart` still
//  hold all of it. That is the point of a toggle rather than a rewrite: the
//  comparison is only fair if the thing being compared against is still real.
//
//  SESSION-SCOPED, NOT PERSISTED. Same call as the other five: nobody should
//  open the app days later in an experimental version and report its layout as
//  the product's.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';

enum ScansHubVersion {
  /// Six doors, from the reconciliation Excel's six journey steps.
  v1,

  /// Three doors: My scans · My reports · Understand a result.
  v2,
}

class ScansHubVersionStore extends ChangeNotifier {
  ScansHubVersionStore._();
  static final ScansHubVersionStore instance = ScansHubVersionStore._();

  /// ⚠️ DEFAULTS TO V2. The toggle exists to judge the new shape, and a
  /// comparison that opens on the old one gets looked at half as often.
  ScansHubVersion _v = ScansHubVersion.v2;
  ScansHubVersion get version => _v;

  void set(ScansHubVersion v) {
    if (v == _v) return;
    _v = v;
    notifyListeners();
  }
}

/// The floating pill. Sits in a Stack over whichever version is showing.
class ScansVersionPill extends StatelessWidget {
  const ScansVersionPill({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [ScansHubVersionStore.instance, V2PaletteStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final v = ScansHubVersionStore.instance.version;

          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.line),
              boxShadow: [
                BoxShadow(
                  // Tinted to the ground, never black — §2.5.
                  color: const Color(0xFFD0C8DC).withValues(alpha: 0.55),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _seg('V1', v == ScansHubVersion.v1, p,
                  () => ScansHubVersionStore.instance.set(ScansHubVersion.v1)),
              _seg('V2', v == ScansHubVersion.v2, p,
                  () => ScansHubVersionStore.instance.set(ScansHubVersion.v2)),
            ]),
          );
        },
      );

  Widget _seg(String label, bool on, V2Palette p, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: on ? p.action : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: on ? p.onAction : p.ink3)),
        ),
      );
}

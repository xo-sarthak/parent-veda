// =============================================================================
//  Shravan - the V1 / V2 toggle
// -----------------------------------------------------------------------------
//  Seventh toggle of this exact shape - `GrowVersionStore`, `WalletVersionStore`,
//  `NameVersionStore`, `PpHomeVersionStore`, `TtcHomeVersionStore`,
//  `ScansHubVersionStore`. Singleton ChangeNotifier, a wrapper that swaps the
//  body, a floating pill in a Stack so V1 needs no edits at all.
//
//  ⚠️ THIS EXISTS BECAUSE THE ANSWER TO "KEEP BOTH OR DROP ONE" WAS NEITHER.
//
//  The Shravan library ended up with two shapes: the month-by-month programme
//  that shipped first, and the flat "See all ragas" list added for the rebuild.
//  The obvious calls were to delete one or to keep both, and both are guesses -
//  they answer different questions ("what is the programme" vs "which one do I
//  want right now") and which serves a mother better is a thing you find out by
//  looking, not by arguing.
//
//  So: a toggle, and the new one is judged against a real V1 rather than a
//  memory of it.
//
//  ⚠️ V1 IS NOT TOUCHED. `_ShravanLibrary` keeps its month-by-month grouping
//  exactly as it was. A comparison is only fair if the thing being compared
//  against is still real.
//
//  ⚠️ SESSION-SCOPED, NOT PERSISTED. Same call as the other six: nobody should
//  open the app days later in an experimental version and report its layout as
//  the product's.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/pv_fonts.dart';
import 'v2/v2_palette.dart';

enum ShravanVersion {
  /// The month-by-month listening programme, grouped by pregnancy month.
  v1,

  /// The flat pick-one list, grouped by kind: ragas, nature, guided.
  v2,
}

class ShravanVersionStore extends ChangeNotifier {
  ShravanVersionStore._();
  static final ShravanVersionStore instance = ShravanVersionStore._();

  /// ⚠️ DEFAULTS TO V2. The toggle exists to judge the new shape, and a
  /// comparison that opens on the old one gets looked at half as often.
  ShravanVersion _v = ShravanVersion.v2;
  ShravanVersion get version => _v;

  void set(ShravanVersion v) {
    if (v == _v) return;
    _v = v;
    notifyListeners();
  }
}

/// The floating pill. Sits in a Stack over whichever version is showing.
class ShravanVersionPill extends StatelessWidget {
  const ShravanVersionPill({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [ShravanVersionStore.instance, V2PaletteStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final v = ShravanVersionStore.instance.version;

          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.line),
              boxShadow: [
                BoxShadow(
                  // Tinted to the ground, never black.
                  color: const Color(0xFFD0C8DC).withValues(alpha: 0.55),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _seg('V1', v == ShravanVersion.v1, p,
                  () => ShravanVersionStore.instance.set(ShravanVersion.v1)),
              _seg('V2', v == ShravanVersion.v2, p,
                  () => ShravanVersionStore.instance.set(ShravanVersion.v2)),
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

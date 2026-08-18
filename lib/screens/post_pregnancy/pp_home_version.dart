// =============================================================================
//  The parenting home's V1 / V3 toggle
// -----------------------------------------------------------------------------
//  Same shape as three toggles already in this folder — `GrowVersionStore`
//  (Brain), `WalletVersionStore` (Health), `NameVersionStore` (Baby names): a
//  singleton ChangeNotifier, a wrapper that swaps the body, and a floating pill
//  in a Stack so V1 needs no edits at all.
//
//  ⚠️ V1 IS `MyChildScreen(home: true)` AND IS NOT TOUCHED. Fifteen sections,
//  all working, all still the default. The toggle exists so the bracket grid can
//  be looked at beside it rather than instead of it — which is the same reason
//  pregnancy has Classic / Focus / V3.
//
//  NO V2. The numbering is deliberately not contiguous: "V3" here means "the
//  same thing pregnancy calls V3", and matching the names across stages is worth
//  more than a tidy sequence. Someone comparing the two stages should not have
//  to learn that parenting's V2 is pregnancy's V3.
//
//  SESSION-SCOPED, NOT PERSISTED. Same call as the pregnancy palette bar: nobody
//  should open the app days later in an experimental home and report its layout
//  as the product's.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../theme/app_theme.dart';
import 'my_child_screen.dart';
import 'pp_home_v3.dart';

enum PpHomeVersion {
  /// `MyChildScreen(home: true)` — what ships today.
  v1,

  /// The bracket grid.
  v3,
}

class PpHomeVersionStore extends ChangeNotifier {
  PpHomeVersionStore._();
  static final PpHomeVersionStore instance = PpHomeVersionStore._();

  PpHomeVersion _v = PpHomeVersion.v1;
  PpHomeVersion get version => _v;

  void set(PpHomeVersion v) {
    if (v == _v) return;
    _v = v;
    notifyListeners();
  }
}

/// What `home_screen_b.dart` pushes instead of `MyChildScreen` directly.
class PpHomeScreen extends StatelessWidget {
  const PpHomeScreen({super.key, this.lang = AppLanguage.english});

  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    // ⚠️ LISTENING IS LOAD-BEARING. The pill reads the store, so the wrapper has
    // to subscribe to it — reading a store inside build() without listening is
    // the bug that made the pregnancy version pill show "Classic" while the body
    // had already swapped, and it has now appeared three times in this codebase.
    return ListenableBuilder(
      listenable: PpHomeVersionStore.instance,
      builder: (context, _) {
        final v = PpHomeVersionStore.instance.version;
        return Stack(children: [
          switch (v) {
            PpHomeVersion.v1 => const MyChildScreen(home: true),
            PpHomeVersion.v3 => PpHomeV3(lang: lang),
          },
          // LEFT, not right. On the right it sat underneath the global Ask FAB
          // and the V3 segment was unreachable — the control that switches the
          // experiment being covered by the thing it is meant to be compared
          // against. Pregnancy puts its version pill bottom-left for the same
          // reason.
          const Positioned(left: 16, bottom: 96, child: _Pill()),
        ]);
      },
    );
  }
}

/// Sandbox chrome. Goes when one of the two wins.
///
/// ⚠️ IT LISTENS TO THE STORE ITSELF, and the reason is a Flutter subtlety worth
/// writing down.
///
/// The wrapper above already rebuilds on every store change, so in principle the
/// pill would come along for the ride. It did not: the pill was mounted as
/// `const _Pill()`, and when a rebuild produces a widget **identical** to the
/// previous one — which a const instance always is, because Dart canonicalises
/// them — Flutter short-circuits and does not rebuild that subtree at all. So
/// the body swapped to V3 and the pill went on showing "Current" as the active
/// segment.
///
/// This is the FOURTH time this class of bug has appeared in this codebase:
/// today_home_screen's version pill, v2_block_grid's art toggle, main_scaffold's
/// Focus|V3 pill, and now this. The first three were "read a store without
/// listening"; this one is subtler, because the listening was there and `const`
/// silently cancelled it.
///
/// The rule that covers all four: **a widget that displays store state should
/// subscribe to that store itself, rather than relying on an ancestor.**
/// Ancestor rebuilds are an optimisation, not a guarantee.
class _Pill extends StatelessWidget {
  const _Pill();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: PpHomeVersionStore.instance,
        builder: (context, _) => _pill(),
      );

  Widget _pill() {
    final store = PpHomeVersionStore.instance;
    Widget seg(String label, PpHomeVersion v) {
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
          seg('Current', PpHomeVersion.v1),
          seg('V3', PpHomeVersion.v3),
        ]),
      ),
    );
  }
}

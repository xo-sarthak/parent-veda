// What a save says (toasts pass, 2026-10-15).
//
// Before this, ~30 bookmark and save taps across the app answered with an
// icon flip and nothing else, so a save looked like it might not have
// happened, and nothing told her where it went. Mobbin, the same day: NYT
// ("Article saved. View it in the You tab."), Google ("Saved to Favourite
// pages · Edit"), Flo ("Click here to see all your bookmarks"), AllTrails
// ("Removed from Favorites · Undo"). So: a save names the place and offers
// View; an unsave offers Undo.
//
// ⚠️ NOT FOR THE STORE'S PRODUCT HEART. That one says it with the icon, on
// purpose (test/pv_store_test.dart: "the heart fills without a notice"): it
// sits on a grid of cards, and a notice per heart while browsing is noise.
import 'package:flutter/material.dart';

import '../services/life_stage_store.dart';
import '../widgets/pv_toast.dart';
import 'saved_screen.dart';

/// Call AFTER the toggle, with the state it landed in. [undo] puts it back
/// (usually the same toggle again). [where] names the place when it is not
/// the general saved list ("Saved to your recipes"). [canView] is false for
/// a save that has no list of its own to open yet: the words still confirm
/// it, but a View that lands on a list without it would be a broken promise.
/// [onView] opens a stage's own library instead of the general one.
void pvSaveToast(
  BuildContext context, {
  required bool nowSaved,
  VoidCallback? undo,
  String? where,
  bool canView = true,
  VoidCallback? onView,
}) {
  if (nowSaved) {
    // Captured now: the notice can outlive the screen that raised it.
    final nav = Navigator.maybeOf(context, rootNavigator: true);
    pvToast(context, where ?? (canView ? 'Saved to your library' : 'Saved'),
        kind: PvToastKind.saved,
        action: canView ? 'View' : null,
        onAction: !canView ? null : onView ?? () => _openSaved(nav));
  } else {
    pvToast(context, 'Removed from your saved',
        kind: PvToastKind.undo,
        action: undo == null ? null : 'Undo',
        onAction: undo);
  }
}

void _openSaved(NavigatorState? nav) {
  if (nav == null || !nav.mounted) return;
  nav.push(MaterialPageRoute<void>(
    builder: (_) => SavedScreen(stage: LifeStageStore.instance.stage?.id),
    settings: const RouteSettings(name: 'saved'),
  ));
}

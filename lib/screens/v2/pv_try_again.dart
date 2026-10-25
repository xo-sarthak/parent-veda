// =============================================================================
//  "Trying again": trying for another baby, from the family (2026-10-25)
// -----------------------------------------------------------------------------
//  docs/STAGE-TRANSITIONS.md R1, the last real move it lacked. The drawer's
//  "Track ovulation > Yes, we are trying" ended on "coming soon"; Parenting You
//  had "Expecting again?" and nothing for the step before it.
//
//  THE SHAPE is the calm page (F4): what changes, what stays, one ink button,
//  a quiet "Not now". It asks nothing itself. The TTC home's own introduction
//  asks the three questions (last period, how long, a clinic) the moment it
//  opens, because the move owes it again: one set of questions for trying,
//  wherever she arrives from.
//
//  ⚠️ THE MOVE IS `startTryingFromFamily` (stage_moves.dart). This file shows
//  the page, makes the TTC home the root and offers the undo.
//
//  ⚠️ THE TTC HOME BECOMES THE ROOT, IT IS NOT PUSHED. The family switch
//  treats the root as the stage's own home and pops to it to go "back to
//  Trying"; pushed over the parenting home, that pop would land on Parenting.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/father_preview.dart';
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/stage_moves.dart';
import '../../widgets/pv_feedback.dart';
import '../../widgets/pv_toast.dart';
import '../post_pregnancy/phase_map_screen.dart' show PhasePainting;
import '../post_pregnancy/pp_child_profile.dart';
import '../post_pregnancy/pp_home_version.dart' show PpHomeScreen;
import '../post_pregnancy/pp_phases_data.dart' show kPhases;
import '../skilling/skilling_preview_screen.dart';
import '../ttc/ttc_common.dart' show ttcHomeRoute;
import '../ttc/ttc_home_version.dart' show TtcHomeScreen;
import 'pv_celebration.dart';

const String kPvTryAgainRoute = 'family/try_again';

/// The row's words, in the family sheet and in You.
const String kTryAgainTitle = 'Trying for another baby?';
const String kTryAgainSheetTitle = 'Start trying again';

/// Whether "Trying again" is offered on this phone, now.
bool tryingAgainOffered() => tryingAgainOfferedFor(
      stage: LifeStageStore.instance.stage,
      father: FatherPreview.instance.on,
    );

/// The page's words. Pure, so the tests read them.
@visibleForTesting
({String title, String line, List<String> changes}) tryAgainWords(List<String> childNames) {
  final kids = switch (childNames.length) {
    0 => 'Your child',
    1 => childNames.first,
    2 => '${childNames[0]} and ${childNames[1]}',
    _ => '${childNames.sublist(0, childNames.length - 1).join(', ')} and ${childNames.last}',
  };
  final one = childNames.length <= 1;
  return (
    title: 'Trying for another baby',
    line: 'ParentVeda opens on trying to conceive: your cycle, your window, and what helps.',
    changes: [
      'We ask three short questions first: your last period, how long, and whether a clinic is involved. Each can be skipped.',
      one
          ? '$kids keeps their own home, one tap away in the name at the top.'
          : '$kids keep their own homes, one tap away in the name at the top.',
      'Their messages, vaccines and everything you have logged stay as they are.',
      'Changed your mind? Undo is on the next screen, and in You.',
    ],
  );
}

void openTryAgain(BuildContext context, {bool replace = false}) {
  final names = [
    for (final c in ChildProfileStore.instance.children)
      if (c.name != Child.placeholder) c.name,
  ];
  final w = tryAgainWords(names);
  final route = MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPvTryAgainRoute),
    builder: (_) => PvCelebrationScreen(
      painting: PhasePainting(phase: kPhases.first),
      title: w.title,
      line: w.line,
      changes: w.changes,
      primary: 'Start trying',
      onPrimary: _start,
      secondary: 'Not now',
      onSecondary: (c) => Navigator.of(c).maybePop(),
    ),
  );
  final nav = Navigator.of(context);
  replace ? nav.pushReplacement(route) : nav.push(route);
}

Future<void> _start(BuildContext context) async {
  pvCommitFeedback();
  final nav = Navigator.of(context);
  await startTryingFromFamily();
  await TryAgainUndo.instance.refresh();
  openTtcAsRoot(nav);
  // Told after it happened, with the way back (the house pattern).
  final ctx = nav.context;
  if (!ctx.mounted) return;
  pvToast(ctx, 'Moved to trying to conceive.', kind: PvToastKind.done, action: 'Undo', onAction: () async {
    await undoTryingFromFamily();
    await TryAgainUndo.instance.refresh();
    openFamilyRootAfterTryingUndo(nav);
  });
}

/// The TTC home as the navigator's only route, as the splash puts it.
void openTtcAsRoot(NavigatorState nav) {
  nav.pushAndRemoveUntil(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: ttcHomeRoute),
      builder: (_) => const TtcHomeScreen(),
    ),
    (_) => false,
  );
}

/// After the undo: the home of the stage she came back to, as the root.
void openFamilyRootAfterTryingUndo(NavigatorState nav) {
  final lang = PregnancyController.current?.language ?? AppLanguage.english;
  // Each written out with its own route name: the last-profile observer and
  // its scan read the names (last_profile.dart).
  final Route<void> home = LifeStageStore.instance.stage == LifeStage.skilling
      ? MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'skilling'),
          builder: (_) => SkillingPreviewScreen(lang: lang),
        )
      : MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'pp/my_child'),
          builder: (_) => PpHomeScreen(lang: lang),
        );
  nav.pushAndRemoveUntil(home, (_) => false);
}

/// Whether "Not trying after all?" is offered: the trying on screen came from
/// the family move on this phone. `tryingCameFromFamily` reads storage, and a
/// You row decides as it draws, so the answer is held here and refreshed when
/// it can change (the move, its undo, the first look).
class TryAgainUndo extends ChangeNotifier {
  TryAgainUndo._();
  static final TryAgainUndo instance = TryAgainUndo._();

  bool _from = false;
  bool _read = false;

  bool get offered {
    if (!_read) {
      _read = true;
      refresh();
    }
    return _from && LifeStageStore.instance.stage == LifeStage.tryingToConceive;
  }

  Future<void> refresh() async {
    final v = await tryingCameFromFamily().catchError((_) => false);
    _read = true;
    if (v == _from) return;
    _from = v;
    notifyListeners();
  }
}

/// "Not trying after all?" from You: the same undo as the notice's.
Future<void> undoTryAgainFromYou(BuildContext context) async {
  final nav = Navigator.of(context);
  await undoTryingFromFamily();
  await TryAgainUndo.instance.refresh();
  openFamilyRootAfterTryingUndo(nav);
  final ctx = nav.context;
  if (ctx.mounted) pvToast(ctx, 'Back to your family. Nothing you logged was removed.', kind: PvToastKind.done);
}

// =============================================================================
//  The three doors — trying to conceive · pregnancy · parenting
// -----------------------------------------------------------------------------
//  ParentVeda is three stages in one binary, and until now moving between them
//  meant knowing which incantation each one wanted:
//
//    pregnancy   AppShell.openPregnancy(nav)   — replaces the whole stack
//    TTC         openTtc(context)              — pushes ttcHomeRoute
//    parenting   push PpHomeScreen('pp/my_child')
//
//  Three different mechanisms, each correct, each written for one call site.
//  This file is the single door every stage switcher goes through, so a screen
//  that wants to offer the three stages does not have to learn all three.
//
//  ⚠️ NAVIGATING IS NOT THE SAME AS DECLARING A STAGE, AND THIS DOES ONLY THE
//  FIRST. `LifeStageStore` is deliberately NOT written here.
//
//  That is not an oversight — it is the existing behaviour of both doors this
//  replaces, and the reason matters: the parenting doorway on the pregnancy
//  home is a PREVIEW, and `openTtc` is a visit. A pregnant mother looking at
//  what parenting will be like has not stopped being pregnant, and rewriting
//  her life stage because she tapped a menu would change which home the app
//  boots into tomorrow, which content the personalisation engine serves, and
//  what the backend thinks is happening to her.
//
//  A real transition IS a different act, and it already has its own screens:
//  `ttc_transition.dart` moves TTC → pregnancy on a positive test, and it
//  writes the stage, records `enteredAt`, and says so. Anything that permanent
//  should be a decision, not a side effect of navigation.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/post_pregnancy/pp_home_version.dart';
import '../screens/ttc/ttc_common.dart';

/// One of the three places a family can be.
///
/// Deliberately NOT `LifeStage`. That enum is an identity persisted to
/// `shared_preferences` and sent to the backend, and it carries a fourth value
/// (`skilling`) that is not a destination. This is a menu, and a menu should
/// not be able to express a state the product does not have.
enum StageDoor { tryingToConceive, pregnancy, parenting }

extension StageDoorCopy on StageDoor {
  String get label => switch (this) {
        StageDoor.tryingToConceive => 'Trying to conceive',
        StageDoor.pregnancy => 'Pregnancy',
        StageDoor.parenting => 'Parenting',
      };

  IconData get icon => switch (this) {
        StageDoor.tryingToConceive => Icons.favorite_border_rounded,
        StageDoor.pregnancy => Icons.pregnant_woman_rounded,
        StageDoor.parenting => Icons.child_care_outlined,
      };
}

/// Opens [door], using whichever navigation that stage actually needs.
///
/// Returns false only when the pregnancy shell is asked for and nothing is
/// registered — a widget test, or a build where `main.dart` has not run — so a
/// caller can say something true rather than appear to do nothing.
bool openStageDoor(BuildContext context, StageDoor door) {
  final nav = Navigator.of(context);
  switch (door) {
    case StageDoor.pregnancy:
      // ⚠️ `leaveTtcForPregnancy` DESPITE THE NAME, and it is the right
      // function from all three stages rather than a TTC-only one. What it
      // actually does is "get me back to the root and make sure the root is
      // pregnancy": it pops to the first route, and only rebuilds the shell if
      // that first route turned out to be TTC's. From the pregnancy stack it
      // pops home; from parenting — which is pushed on top of the pregnancy
      // shell — it pops back to a live shell with her tab, her scroll position
      // and her controllers all intact. Rebuilding would have thrown those
      // away for no reason.
      return leaveTtcForPregnancy(nav);

    case StageDoor.tryingToConceive:
      openTtc(context);
      return true;

    case StageDoor.parenting:
      // The same route name the pregnancy home's doorway pushes, because
      // `openPpTab` pops back to it. A second name for the same screen is how
      // the parenting tabs would start landing on a stranded copy.
      nav.push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/my_child'),
        builder: (_) => const PpHomeScreen(),
      ));
      return true;
  }
}

/// Shows the three doors as a small menu **anchored to [anchor]**, appearing to
/// come out of the button that was tapped.
///
/// ⚠️ ANCHORED, NOT A DIALOG OR A SHEET. A modal over the whole screen is a
/// different gesture — it says "stop what you are doing and answer this". This
/// is a control on a header; the menu belongs to the button, so it opens beside
/// it and closes on a tap anywhere else. `showMenu` positions against the
/// overlay, which is why the button's own `RenderBox` has to be measured rather
/// than guessed.
///
/// [anchor] is the key on the button's box. Returns without doing anything if
/// it has not been laid out — which is only possible if this is called before
/// the first frame, and doing nothing is better than an exception in a header.
Future<void> showStageDoorMenu(BuildContext context, GlobalKey anchor) async {
  final box = anchor.currentContext?.findRenderObject() as RenderBox?;
  final overlay =
      Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
  if (box == null || overlay == null) return;

  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final bottomRight =
      box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay);
  final rect = RelativeRect.fromRect(
    Rect.fromPoints(topLeft, bottomRight),
    Offset.zero & overlay.size,
  );

  final chosen = await showMenu<StageDoor>(
    context: context,
    position: rect,
    color: Colors.white,
    elevation: 8,
    shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    items: [
      for (final d in StageDoor.values)
        PopupMenuItem<StageDoor>(
          value: d,
          height: 46,
          child: Row(children: [
            Icon(d.icon, size: 19, color: const Color(0xFF6A30B6)),
            const SizedBox(width: 12),
            Text(d.label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F2C30))),
          ]),
        ),
    ],
  );

  if (chosen == null) return;
  // ⚠️ THE CONTEXT HAS SURVIVED AN AWAIT. `showMenu` is a route, so anything
  // could have happened while it was open — including this screen being popped.
  if (!context.mounted) return;
  openStageDoor(context, chosen);
}

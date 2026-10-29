// =============================================================================
//  "Questions for your doctor" - the three lists, one tool (C1, 2026-10-30)
// -----------------------------------------------------------------------------
//  The Scans, Complications and Nutrition doors each hold a list of questions
//  to tick and take in (`kPvChecklists`). They were one tool with three
//  subjects, reached only from those doors. The Tools row and global search
//  open this sheet; each line opens its list as its own door opens it, so the
//  ticks and the colour are the ones she already knows.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/checklists/pv_checklist.dart' show pvChecklistById;
import '../../data/doors/pv_door_complications.dart' show kCondSurfaceQuestions;
import '../../data/doors/pv_door_nutrition.dart' show kDietSurfaceQuestions;
import '../../data/doors/pv_door_scans.dart' show kScansSurfaceQuestions;
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_toast.dart';
import '../doors/pv_door_router.dart' show pvDoorScreenFor;
import '../doors/pv_list_row.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import '../v2/v2_palette.dart' show v2BlockTint;

/// The three lists: the door id that opens each, its checklist id, its mark
/// and its door's hue (the router passes the same hue).
const List<(String, String, TtcTabMark, double)> kPregQuestionLists = [
  (kScansSurfaceQuestions, 'scan_questions', TtcTabMark.vialReport, 206),
  (kCondSurfaceQuestions, 'condition_questions', TtcTabMark.magnifier, 186),
  (kDietSurfaceQuestions, 'diet_questions', TtcTabMark.bowl, 104),
];

/// Shows the sheet, then opens the list she picks under its door's own route
/// name, so the Ask button reads it the same as from the door.
Future<void> showPregQuestionLists(BuildContext context, PregnancyController c) async {
  final p = pvStorePalette;
  final picked = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Questions for your doctor',
                style: pvFraunces(
                    fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 6),
            Text('Tick what matters to you and take the list in with you.',
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
            const SizedBox(height: 12),
            PvRowGroup(p: p, children: [
              for (final (id, listId, tab, hue) in kPregQuestionLists)
                if (pvChecklistById(listId) case final list?)
                  PvListRow(
                    key: ValueKey('preg_questions_$id'),
                    p: p,
                    leading: TtcMarkLeading(tab: tab, tint: v2BlockTint(hue, p)),
                    title: list.title,
                    onTap: () => Navigator.of(ctx).pop(id),
                  ),
            ]),
          ],
        ),
      ),
    ),
  );
  if (picked == null || !context.mounted) return;
  final w = pvDoorScreenFor(picked, c);
  if (w == null) {
    pvToast(context, 'That list could not open just now. Its door opens it too.');
    return;
  }
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: picked),
    builder: (_) => w,
  ));
}

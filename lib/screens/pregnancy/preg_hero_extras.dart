// =============================================================================
//  The pregnancy hero's two additions — 2026-09-30
// -----------------------------------------------------------------------------
//  From the pregnancy gap analysis, "Home & daily":
//
//  1. "Show ... 'weeks to go' on the hero" (P2). What to Expect's first lines
//     end "20 Wks to go!"; Flo shows the count with an (i) that explains how
//     weeks are counted. The hero now says "20 weeks to go" under the day, with
//     an (i) that opens [showPregHowWeeksCounted]. The SIZE half of the PDF's
//     line is left off on the user's own call (2026-09-22: the size is on the
//     insight card, and saying it twice was "a wastage of space").
//
//  2. "After week 37, ask gently whether the baby has arrived" (P2). The
//     hand-off to the parenting home was the best of the three apps and hidden
//     inside You. From week 37 a quiet card sits at the foot of the hero:
//     "Has your baby arrived? [Yes, tell ParentVeda] [Not yet]". "Not yet"
//     rests it for three days, on this phone ([PregArrivalPrompt]).
//
//  Past the due date the hero keeps counting ("40 weeks and 3 days") and
//  offers "Past your due date: what happens now", the labour door's own read.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/stage_gateway.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../profile/pv_you_sheets.dart' show showPvAddChildSheet;
import '../v2/v2_palette.dart';

/// The read "Past your due date" opens (the Labour door's own).
const String kPregPastDueReadId = 'preg_labour_read_past_due';

/// The line under "Day N": how long is left, from [daysToDue] (negative once
/// the date has passed).
String pregTimeLeft(int daysToDue) {
  if (daysToDue < 0) return 'Past your due date';
  if (daysToDue == 0) return 'Your due date is today';
  if (daysToDue < 7) return daysToDue == 1 ? '1 day to go' : '$daysToDue days to go';
  final w = daysToDue ~/ 7;
  return w == 1 ? '1 week to go' : '$w weeks to go';
}

/// "40 weeks and 3 days", for a day past the due date. Null before it.
String? pregPastDueCount(int daysToDue) {
  if (daysToDue >= 0) return null;
  final over = -daysToDue;
  final weeks = 40 + over ~/ 7;
  final days = over % 7;
  if (days == 0) return '$weeks weeks';
  return '$weeks weeks and ${days == 1 ? '1 day' : '$days days'}';
}

/// "How your weeks are counted": the (i) after the time left.
Future<void> showPregHowWeeksCounted(BuildContext context, PregnancyController c) {
  final p = V2PaletteStore.instance.current;
  final owned = c.dueDateSource.clinicOwned;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('How your weeks are counted',
              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
          const SizedBox(height: 12),
          for (final para in [
            'Pregnancy is counted from the first day of your last period, not from the day you conceived. '
                'That is about two weeks earlier, so at week 20 your baby has been growing for about 18 weeks.',
            'Doctors everywhere count this way, so the week here is the week on your scan reports. '
                'A full pregnancy is 40 weeks, and anywhere from 37 to 42 is normal.',
            owned
                ? 'Your date came from your doctor, a scan or your transfer, so that is the one we follow.'
                : 'If your doctor gives you a date from a scan, that is the one we follow. You can change it in You, under Due date.',
          ]) ...[
            Text(para, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2)),
            const SizedBox(height: 10),
          ],
        ]),
      ),
    ),
  );
}

// =============================================================================
//  "Has your baby arrived?"
// =============================================================================

/// Whether the card is resting after a "Not yet". On this phone only; the
/// cost of losing it is one more gentle question.
class PregArrivalPrompt extends ChangeNotifier {
  PregArrivalPrompt._();
  static final PregArrivalPrompt instance = PregArrivalPrompt._();

  static const String kSnoozeKey = 'preg_arrival_snooze_until_v1';

  /// How long "Not yet" rests the card.
  static const Duration rest = Duration(days: 3);

  DateTime? _until;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(kSnoozeKey);
      _until = raw == null ? null : DateTime.tryParse(raw);
      notifyListeners();
    } catch (_) {/* shown, which is the safe side */}
  }

  /// Shown from week 37, unless resting.
  bool showsFor(int currentWeek, {DateTime? now}) {
    if (currentWeek < 37) return false;
    final u = _until;
    return u == null || !(now ?? DateTime.now()).isBefore(u);
  }

  Future<void> notYet({DateTime? now}) async {
    _until = (now ?? DateTime.now()).add(rest);
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setString(kSnoozeKey, _until!.toIso8601String());
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTest() {
    _until = null;
    _loaded = false;
  }
}

/// The card at the foot of the hero.
class PregArrivalCard extends StatelessWidget {
  const PregArrivalCard({super.key, required this.p});
  final V2Palette p;

  Future<void> _yes(BuildContext context) async {
    pvCommitFeedback();
    // The same sheet and the same move as You › "Baby has arrived".
    final added = await showPvAddChildSheet(context, arrival: true);
    if (added && context.mounted) {
      LifeStageStore.instance.setStage(LifeStage.parenting);
      openStageDoor(context, StageDoor.parenting);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('preg_arrival_card'),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Has your baby arrived?',
              style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 4),
          Text('Tell us when you are ready. Nothing from your pregnancy is deleted.',
              style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            FilledButton(
              key: const ValueKey('preg_arrival_yes'),
              style: FilledButton.styleFrom(
                  backgroundColor: p.ink1, foregroundColor: p.ground, shape: const StadiumBorder()),
              onPressed: () => _yes(context),
              child: Text('Yes, tell ParentVeda',
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ground)),
            ),
            TextButton(
              key: const ValueKey('preg_arrival_not_yet'),
              onPressed: () {
                pvCommitFeedback();
                PregArrivalPrompt.instance.notYet();
              },
              child: Text('Not yet',
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
            ),
          ]),
        ]),
      );
}

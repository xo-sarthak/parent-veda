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
//
//  ⚠️ FROM 42 WEEKS THE CARD SAYS MORE (2026-10-25, STAGE-TRANSITIONS R7).
//  Nothing prompted past 42 weeks: the same "Has your baby arrived?" sat there
//  for as long as the app thought she was pregnant. Two weeks past the due
//  date, one of three things is true, and the card now names all three:
//  the baby is here (tell us), the date was wrong (change it: the likeliest,
//  a scan moved it and nobody updated the app), or she is still pregnant,
//  and then the one thing we say is to call her doctor or hospital today.
//  Not a diagnosis, and no advice on what the doctor will do. "Not yet" rests
//  it for a day instead of three.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/preg_week_extras.dart' show pregMonthFor, pregTrimesterFor;
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/remote/cloud_merged_store.dart';
// import '../../services/remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)
import '../../services/stage_gateway.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../doors/pv_door_router.dart' show openPvDoorRead;
import '../profile/pv_you_sheets.dart' show showPvAddChildSheet;
import '../v2/pv_celebration.dart' show openBirthCelebration;
import '../v2/v2_palette.dart';
import 'preg_chrome.dart' show pregFilledStyle;

/// The read "Past your due date" opens (the Labour door's own).
const String kPregPastDueReadId = 'preg_labour_read_past_due';

/// The read "How your weeks are counted" opens (Your first weeks door's own,
/// relevance Batch 6).
const String kPregCountingReadId = 'preg_first_read_counting';

/// Days past the due date from which the arrival card says more: 42 weeks
/// and 0 days (R7).
const int kPregPostTermDays = 14;

/// True from 42 weeks: [daysPastDue] is how many days the due date has passed
/// (0 or less before it).
bool pregIsPostTerm(int daysPastDue) => daysPastDue >= kPregPostTermDays;

/// The line under "Day N": how long is left, from [daysToDue] (negative once
/// the date has passed).
String pregTimeLeft(int daysToDue) {
  if (daysToDue < 0) return 'Past your due date';
  if (daysToDue == 0) return 'Your due date is today';
  if (daysToDue < 7) return daysToDue == 1 ? '1 day to go' : '$daysToDue days to go';
  final w = daysToDue ~/ 7;
  return w == 1 ? '1 week to go' : '$w weeks to go';
}

/// The week PAGE a mother past her due date belongs on (2026-09-30): 41 from
/// 41 weeks (a full week past), 42 from 42 weeks, and null before that, where week
/// 40's own page still fits ("40 weeks and 3 days"). It follows the hero's count
/// ([pregPastDueCount]) exactly, so the line under "Week 41" and the page it opens
/// cannot disagree. The pages exist (`preg_week_extras_special.dart`, "One week
/// past your due date" and "Two weeks past") but the home clamped the week to 40,
/// so Details opened week 40 for as long as she waited. The figure's art stays at
/// week 40 (there is none past it, `pregBabyArt` clamps), the carry-forward the
/// user chose.
///
/// [daysToDue] is negative once the date has passed, as in [pregTimeLeft].
int? pregPastDueWeek(int daysToDue) {
  if (daysToDue >= 0) return null;
  final over = -daysToDue;
  if (over < 7) return null;
  return over < 14 ? 41 : 42;
}

/// The hero's two lines for pregnancy day [day] (days since the first day of
/// her last period): ("7 weeks", "and 4 days"), or ("8 weeks", null) on a whole
/// week. At 7 weeks 4 days she is IN her 8th week, so the week's page is week
/// 8 while the count says 7 (user 2026-10-23: "why say week 8 w/o being in
/// one??"). Doctors and scan reports say it this way.
(String, String?) pregWeeksAndDays(int day) {
  final d = day < 0 ? 0 : day;
  final w = d ~/ 7, r = d % 7;
  return (
    w == 1 ? '1 week' : '$w weeks',
    r == 0 ? null : 'and ${r == 1 ? '1 day' : '$r days'}',
  );
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

/// "Month 6 · Second trimester" for [week] (relevance Batch 6, 2026-10-28),
/// from the same two functions the week page prints, so the hero and the
/// page can never disagree.
String pregMonthLine(int week) =>
    'Month ${pregMonthFor(week)} · ${pregTrimesterFor(week)}';

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
            // Why the count and the week's page differ by one (2026-10-23).
            '7 weeks and 4 days means you are in your 8th week, so the page you see is week 8.',
            'Doctors everywhere count this way, so the week here is the week on your scan reports. '
                'A full pregnancy is 40 weeks, and anywhere from 37 to 42 is normal.',
            owned
                ? 'Your date came from your doctor, a scan or your transfer, so that is the one we follow.'
                : 'If your doctor gives you a date from a scan, that is the one we follow. You can change it in You, under Due date.',
            // Which month and trimester this week is (relevance Batch 6,
            // 2026-10-28), with no due date left out: the week is a guess.
            if (c.isDueDateSet)
              'Week ${c.currentWeek} is in month ${pregMonthFor(c.currentWeek)}, '
                  'in the ${pregTrimesterFor(c.currentWeek).toLowerCase()}.',
          ]) ...[
            Text(para, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2)),
            const SizedBox(height: 10),
          ],
          // The whole explanation, one tap on: every week as a month and a
          // trimester. The sheet closes first, so Back returns to the home.
          PvPress(child: GestureDetector(
            key: const ValueKey('preg_how_counted_read'),
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(ctx).pop();
              openPvDoorRead(context, kPregCountingReadId, c);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Weeks, months and trimesters',
                    style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, size: 18, color: p.ink1),
              ]),
            ),
          )),
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
///
/// In the cloud since step 13 (2026-10-22, sync log): it was phone-only, so a
/// "Not yet" on one phone still asked on the other, and a sign-out forgot it.
/// One item: `snooze_until` (ISO).
class PregArrivalPrompt extends ChangeNotifier with CloudMergedStore {
  PregArrivalPrompt._();
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   PregArrivalPrompt._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
  static final PregArrivalPrompt instance = PregArrivalPrompt._();

  static const String kSnoozeKey = 'preg_arrival_snooze_until_v1';

  /// How long "Not yet" rests the card.
  static const Duration rest = Duration(days: 3);

  /// From 42 weeks a day is long enough (R7).
  static const Duration postTermRest = Duration(days: 1);

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
    await syncMergedFromCloud();
  }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'preg_arrival_prompt';

  @override
  Map<String, Object?> cloudItems() =>
      {if (_until != null) 'snooze_until': _until!.toIso8601String()};

  @override
  void applyCloudItems(Map<String, Object?> items) {
    final v = items['snooze_until'];
    _until = v is String ? DateTime.tryParse(v) : null;
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (_until == null) {
        await p.remove(kSnoozeKey);
      } else {
        await p.setString(kSnoozeKey, _until!.toIso8601String());
      }
    } catch (_) {}
  }

  /// Shown from week 37, unless resting.
  bool showsFor(int currentWeek, {DateTime? now}) {
    if (currentWeek < 37) return false;
    final u = _until;
    return u == null || !(now ?? DateTime.now()).isBefore(u);
  }

  Future<void> notYet({DateTime? now, bool postTerm = false}) async {
    _until = (now ?? DateTime.now()).add(postTerm ? postTermRest : rest);
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setString(kSnoozeKey, _until!.toIso8601String());
    } catch (_) {}
  }

  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  //   // are wiped, the singleton was not.
  //   void _resetForAccount() {
  //     resetForTest();
  //     notifyListeners();
  //   }

  @visibleForTesting
  void resetForTest() {
    _until = null;
    _loaded = false;
  }
}

/// The card at the foot of the hero.
class PregArrivalCard extends StatelessWidget {
  const PregArrivalCard({
    super.key,
    required this.p,
    this.daysPastDue = 0,
    this.forPartner = false,
    this.onDueDate,
  });
  final V2Palette p;

  /// How many days the due date has passed today (0 or less before it).
  final int daysPastDue;

  /// His side: the words speak of her, and he cannot change her date.
  final bool forPartner;

  /// Opens her due date (R7's "My due date changed"); null on his side.
  final VoidCallback? onDueDate;

  Future<void> _yes(BuildContext context) async {
    pvCommitFeedback();
    // The same sheet and the same move as You › "Baby has arrived".
    final added = await showPvAddChildSheet(context, arrival: true);
    if (added && context.mounted) {
      LifeStageStore.instance.setStage(LifeStage.parenting);
      // The birth page first (F4, 2026-10-25), then her baby's home. Kept for
      // revert: openStageDoor(context, StageDoor.parenting); alone.
      await openBirthCelebration(context, then: (c) => openStageDoor(c, StageDoor.parenting));
    }
  }

  @override
  Widget build(BuildContext context) {
    final late = pregIsPostTerm(daysPastDue);
    final weeksPast = daysPastDue ~/ 7;
    return Container(
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
          // Kept for revert, the only line before R7:
          //   'Tell us when you are ready. Nothing from your pregnancy is deleted.'
          if (!late)
            Text('Tell us when you are ready. Nothing from your pregnancy is deleted.',
                style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2))
          else
            Text(
                key: const ValueKey('preg_arrival_post_term'),
                forPartner
                    ? 'Her due date was $weeksPast weeks ago. If your baby is here, tell us when you are ready. '
                        'If she is still pregnant, she should call her doctor or hospital today.'
                    : 'Your due date was $weeksPast weeks ago. If your baby is here, tell us when you are ready. '
                        'If you are still pregnant, call your doctor or hospital today.',
                style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            FilledButton(
              key: const ValueKey('preg_arrival_yes'),
              style: pregFilledStyle(), // the one ink, #2F2C30
              onPressed: () => _yes(context),
              child: Text('Yes, tell ParentVeda',
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            // From 42 weeks the date may simply be wrong (R7).
            if (late && onDueDate != null)
              TextButton(
                key: const ValueKey('preg_arrival_due_date'),
                onPressed: () {
                  pvCommitFeedback();
                  onDueDate!();
                },
                child: Text('My due date changed',
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
            TextButton(
              key: const ValueKey('preg_arrival_not_yet'),
              onPressed: () {
                pvCommitFeedback();
                PregArrivalPrompt.instance.notYet(postTerm: late);
              },
              child: Text('Not yet',
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
            ),
          ]),
        ]),
      );
  }
}

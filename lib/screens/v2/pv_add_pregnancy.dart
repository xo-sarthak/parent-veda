// =============================================================================
//  "Add a pregnancy": expecting again, from the family (2026-10-25)
// -----------------------------------------------------------------------------
//  docs/STAGE-TRANSITIONS.md F2. A parent in Parenting or the learning space
//  had no way into a new pregnancy: the only route was the Developer stage
//  chips, and the drawer's "Expecting again? Start here." ended on "coming
//  soon". R1 made each pregnancy its own record, so a new one now starts clean
//  beside her children.
//
//  THE SHAPE is Apple Health's "Add a Current Pregnancy" (Mobbin): one page,
//  the ways of dating it as one choice, one date, one button. The four ways
//  and their words are the due-date screen's (`kPregDueDateWays`), and the
//  arithmetic is the calculator's (`ddcComputeEdd`), so a date never differs
//  by a day between two screens. `PregDueDateScreen` itself is not reused: it
//  edits the running controller, which still holds the last pregnancy's date.
//
//  ⚠️ THE MOVE IS `startPregnancyFromFamily` (stage_moves.dart). This file
//  only asks for the date, shows the page and opens the pregnancy home.
//
//  ⚠️ SHE ONLY. A father cannot date her pregnancy; his side follows hers
//  (and his phone does not yet see her stage change: STAGE-TRANSITIONS R2).
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/father_preview.dart';
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/pregnancy_records.dart';
import '../../services/stage_gateway.dart';
import '../../services/stage_moves.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_date_sheet.dart';
import '../../widgets/pv_feedback.dart';
import '../../widgets/pv_toast.dart';
import '../post_pregnancy/phase_map_screen.dart' show PhasePainting;
import '../post_pregnancy/pp_child_profile.dart';
import '../post_pregnancy/pp_phases_data.dart' show kPhases;
import '../pregnancy/preg_due_date_screen.dart' show kPregDueDateWays, pregDueDateOrder;
import '../products/pv_store_chrome.dart' show PvChip, PvCommit, kPvLine, pvStorePalette;
import '../skilling/skilling_preview_screen.dart';
import '../tools/due_date_calculator_screen.dart' show DdcMethod, ddcComputeEdd, ddcSourceFor;
import '../ttc/ttc_common.dart' show leaveTtcForPregnancy;
import 'pv_celebration.dart';
import 'v2_palette.dart';
import 'pv_moment_paintings.dart';

const String kPvAddPregnancyRoute = 'family/add_pregnancy';

/// The row's words, in the family sheet and in You.
const String kAddPregnancyTitle = 'Add a pregnancy';
const String kExpectingAgainTitle = 'Expecting again?';

/// Pure, so the tests read it: whether "Add a pregnancy" is offered. A parent
/// (Parenting or the learning space), on her side, with no pregnancy going.
/// Trying has its own "I'm pregnant"; a pregnancy already going is one.
@visibleForTesting
bool addPregnancyOfferedFor({
  required LifeStage? stage,
  required bool father,
  required bool pregnancyOngoing,
}) =>
    (stage == LifeStage.parenting || stage == LifeStage.skilling) &&
    !father &&
    !pregnancyOngoing;

bool addPregnancyOffered() => addPregnancyOfferedFor(
      stage: LifeStageStore.instance.stage,
      father: FatherPreview.instance.on,
      pregnancyOngoing: PregnancyRecords.instance.current != null,
    );

/// [replace]: in place of the screen that asked (the drawer's "Are you
/// pregnant?"), so back does not return to a question already answered.
void openAddPregnancy(BuildContext context, {bool replace = false}) {
  final route = MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPvAddPregnancyRoute),
    builder: (_) => const PvAddPregnancyScreen(),
  );
  final nav = Navigator.of(context);
  replace ? nav.pushReplacement(route) : nav.push(route);
}

/// "Not sure yet" counts her at about four weeks, the same assumption the
/// positive test makes with no period logged, and says a scan will set it.
const int kNotSureDaysToDue = 280 - 28;

/// The week [edd] makes [today], counted the controller's way.
@visibleForTesting
int addPregnancyWeekFor(DateTime edd, DateTime today) {
  final days = _day(edd).difference(_day(today)).inDays;
  return (40 - (days / 7).floor()).clamp(1, 42);
}

/// Why a due date cannot be this new pregnancy's, or null when it can. A
/// pregnancy that is still going (not past its date, not more than about ten
/// months ahead) that began after her youngest child was born.
@visibleForTesting
String? addPregnancyRefusal({
  required DateTime edd,
  required DateTime today,
  DateTime? youngestDob,
  String? youngestName,
}) {
  final e = _day(edd), t = _day(today);
  if (e.isBefore(t)) return 'That due date has passed. Check it and try again.';
  if (e.isAfter(t.add(const Duration(days: 300)))) {
    return 'That is more than ten months away. Check the date and try again.';
  }
  if (youngestDob != null && e.subtract(const Duration(days: 280)).isBefore(_day(youngestDob))) {
    final who = youngestName == null ? 'your youngest' : "$youngestName's";
    return 'That would start this pregnancy before $who birthday. Check the date and try again.';
  }
  return null;
}

/// The page's words, pure so the tests read them.
@visibleForTesting
({String title, String line, List<String> changes, String primary}) addPregnancyCelebrationWords({
  required int week,
  required bool sureOfDate,
  required List<String> childNames,
  // How the last pregnancy ended (STILL-OPEN §61.1, 2026-10-26). [lastKept]:
  // one is kept to look back on, so the line promising it is true.
  // [afterLoss]: it was a loss, so the line makes room for the worry.
  bool lastKept = true,
  bool afterLoss = false,
}) {
  final one = childNames.length == 1 ? childNames.first : null;
  return (
    title: 'A new pregnancy',
    // Kept for revert: the sure-of-date line for everyone,
    //   'Week $week. Take it one day at a time.'
    line: sureOfDate
        ? (afterLoss
            ? 'Week $week. After everything, hope and worry can sit together. One day at a time.'
            : 'Week $week. Take it one day at a time.')
        : 'About week $week for now. Add the date from your scan when you have it.',
    changes: [
      'This pregnancy starts clean: its own weeks, bag and birth plan',
      if (one != null)
        "$one's home stays exactly as it is. Switch from the name at the top"
      else if (childNames.length > 1)
        "Your children's homes stay exactly as they are. Switch from the name at the top",
      if (lastKept) 'Your last pregnancy is kept for you, under Your pregnancies',
    ],
    primary: 'Open my pregnancy',
  );
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

String _long(DateTime d) {
  const m = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

/// After an undo, back to the home she came from: her child's, or the
/// learning space. Pushed over the pregnancy shell, as after a birth.
void openFamilyHomeAfterUndo(BuildContext context) {
  if (LifeStageStore.instance.stage == LifeStage.skilling) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'skilling'),
      builder: (_) => SkillingPreviewScreen(
          lang: PregnancyController.current?.language ?? AppLanguage.english),
    ));
  } else {
    openStageDoor(context, StageDoor.parenting);
  }
}

class PvAddPregnancyScreen extends StatefulWidget {
  const PvAddPregnancyScreen({super.key, this.today});

  /// Tests pin the day.
  final DateTime? today;

  @override
  State<PvAddPregnancyScreen> createState() => _PvAddPregnancyScreenState();
}

/// The four ways plus "Not sure yet" (null).
class _PvAddPregnancyScreenState extends State<PvAddPregnancyScreen> {
  DdcMethod? _method = pregDueDateOrder(0).first;
  bool _notSure = false;
  DateTime? _date;
  int _gaWeeks = 8, _gaDays = 0;
  int _embryoDay = 5;
  bool _busy = false;

  DateTime get _today => _day(widget.today ?? DateTime.now());

  Child? get _youngest {
    final kids = ChildProfileStore.instance;
    if (!kids.hasRealChild) return null;
    Child? y;
    for (final c in kids.children) {
      if (y == null || c.dob.isAfter(y.dob)) y = c;
    }
    return y;
  }

  DateTime? get _edd {
    if (_notSure) return _today.add(const Duration(days: kNotSureDaysToDue));
    final m = _method;
    if (_date == null || m == null) return null;
    return ddcComputeEdd(
      method: m,
      lmp: _date,
      // The fifth way, Conception date (P3 D1): the ways list is shared.
      conception: _date,
      known: _date,
      scan: _date,
      transfer: _date,
      gaWeeks: _gaWeeks,
      gaDays: _gaDays,
      embryoDay: _embryoDay,
    );
  }

  String? _refusal(DateTime edd) {
    final y = _youngest;
    return addPregnancyRefusal(
      edd: edd,
      today: _today,
      youngestDob: y?.dob,
      youngestName: y == null || y.name == Child.placeholder ? null : y.name,
    );
  }

  Future<void> _pick() async {
    final m = _method;
    if (m == null) return;
    final known = m == DdcMethod.known;
    final first = known ? _today : _today.subtract(const Duration(days: 300));
    final last = known ? _today.add(const Duration(days: 300)) : _today;
    final d = await showPvDateSheet(
      context,
      title: kPregDueDateWays[m]!.$2,
      initial: _date ?? (known ? _today.add(const Duration(days: 200)) : last),
      first: first,
      last: last,
    );
    if (d != null) setState(() => _date = _day(d));
  }

  Future<void> _save() async {
    final edd = _edd;
    if (edd == null || _refusal(edd) != null || _busy) return;
    setState(() => _busy = true);
    pvCommitFeedback();
    final source = _notSure ? DueDateSource.unknown : ddcSourceFor(_method!);
    await startPregnancyFromFamily(due: edd, source: source, today: _today);
    if (!mounted) return;
    final words = addPregnancyCelebrationWords(
      week: addPregnancyWeekFor(edd, _today),
      sureOfDate: !_notSure,
      childNames: [
        for (final c in ChildProfileStore.instance.children)
          if (c.name != Child.placeholder) c.name,
      ],
      // Read after the move: the record before this one is the last one.
      lastKept: PregnancyRecords.instance.beforeCurrent != null,
      afterLoss: PregnancyRecords.instance.pregnantAfterLoss,
    );
    var done = false;
    void open(BuildContext c) {
      if (done) return;
      done = true;
      final nav = Navigator.of(c);
      leaveTtcForPregnancy(nav);
      // Told after it happened, with the way back (the house pattern).
      final ctx = nav.context;
      pvToast(ctx, 'Added your pregnancy.', kind: PvToastKind.done, action: 'Undo', onAction: () async {
        await undoPregnancyFromFamily();
        if (ctx.mounted) openFamilyHomeAfterUndo(ctx);
      });
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      settings: const RouteSettings(name: kPvCelebrationRoute),
      // Back does what the button does: the move has happened either way.
      builder: (page) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) open(page);
        },
        child: PvCelebrationScreen(
          // Its own painting once the file lands; the phase painting until then
      // (2026-10-26). Kept for revert: painting: PhasePainting(phase: kPhases.first),
      painting: PvMomentPainting(moment: PvMoment.newPregnancy, fallback: PhasePainting(phase: kPhases.first)),
          title: words.title,
          line: words.line,
          changes: words.changes,
          primary: words.primary,
          onPrimary: open,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final edd = _edd;
    final refusal = edd == null ? null : _refusal(edd);
    final ok = edd != null && refusal == null;
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(backgroundColor: p.ground, elevation: 0, foregroundColor: p.ink1),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Text(kAddPregnancyTitle,
                style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w500, height: 1.15, color: p.ink1)),
            const SizedBox(height: 8),
            Text('Tell us how far along you are. This pregnancy gets its own weeks, and your '
                "children's homes stay as they are.",
                style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2)),
            const SizedBox(height: 22),
            _eyebrow(p, 'How do you know it?'),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in pregDueDateOrder(0))
                PvChip(
                  key: ValueKey('add_preg_way_${m.name}'),
                  label: kPregDueDateWays[m]!.$1,
                  selected: !_notSure && _method == m,
                  onTap: () => setState(() {
                    _notSure = false;
                    _method = m;
                    _date = null;
                  }),
                ),
              PvChip(
                key: const ValueKey('add_preg_way_not_sure'),
                label: 'Not sure yet',
                selected: _notSure,
                onTap: () => setState(() {
                  _notSure = true;
                  _date = null;
                }),
              ),
            ]),
            const SizedBox(height: 18),
            if (_notSure)
              Text('We will count you at about 4 weeks for now. When you have a date from your '
                  'scan or your doctor, change it under You, Due date, and every week follows it.',
                  style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2))
            else
              _field(p, kPregDueDateWays[_method]!.$2,
                  _date == null ? 'Tap to choose' : _long(_date!), _pick,
                  key: const ValueKey('add_preg_date_field')),
            if (!_notSure && _method == DdcMethod.ultrasound) ...[
              const SizedBox(height: 12),
              _eyebrow(p, 'How far along the scan said'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: _stepper(p, '$_gaWeeks weeks', () {
                  if (_gaWeeks > 5) setState(() => _gaWeeks--);
                }, () {
                  if (_gaWeeks < 24) setState(() => _gaWeeks++);
                })),
                const SizedBox(width: 10),
                Expanded(
                    child: _stepper(p, _gaDays == 1 ? '1 day' : '$_gaDays days', () {
                  if (_gaDays > 0) setState(() => _gaDays--);
                }, () {
                  if (_gaDays < 6) setState(() => _gaDays++);
                })),
              ]),
            ],
            if (!_notSure && _method == DdcMethod.ivf) ...[
              const SizedBox(height: 12),
              _eyebrow(p, 'Embryo age at transfer'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final d in const [3, 5])
                  PvChip(
                    label: 'Day $d',
                    selected: _embryoDay == d,
                    onTap: () => setState(() => _embryoDay = d),
                  ),
              ]),
            ],
            if (edd != null) ...[
              const SizedBox(height: 20),
              Container(
                key: const ValueKey('add_preg_result'),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kPvLine),
                ),
                child: ok
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Week ${addPregnancyWeekFor(edd, _today)} · due ${_long(edd)}',
                            style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
                        if (_notSure) ...[
                          const SizedBox(height: 4),
                          Text('An estimate until your scan.',
                              style: pvManrope(fontSize: 13.5, color: p.ink2)),
                        ],
                      ])
                    : Text(refusal!, style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink1)),
              ),
            ],
            const SizedBox(height: 22),
            PvCommit(
              key: const ValueKey('add_preg_save'),
              label: kAddPregnancyTitle,
              busy: _busy,
              onTap: ok ? _save : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _eyebrow(V2Palette p, String s) => Text(s.toUpperCase(),
      style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: p.ink2));

  Widget _field(V2Palette p, String label, String value, VoidCallback onTap, {Key? key}) => Material(
        key: key,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), side: const BorderSide(color: kPvLine)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: pvManrope(fontSize: 12.5, color: p.ink3)),
              const SizedBox(height: 4),
              Text(value, style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
            ]),
          ),
        ),
      );

  Widget _stepper(V2Palette p, String label, VoidCallback minus, VoidCallback plus) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: kPvLine),
        ),
        child: Row(children: [
          IconButton(onPressed: minus, icon: Icon(Icons.remove_rounded, size: 18, color: p.ink2)),
          Expanded(
            child: Text(label,
                textAlign: TextAlign.center,
                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
          IconButton(onPressed: plus, icon: Icon(Icons.add_rounded, size: 18, color: p.ink2)),
        ]),
      );
}

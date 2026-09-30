// =============================================================================
//  "Your due date" — change it in the place it is shown
// -----------------------------------------------------------------------------
//  2026-09-30, from the pregnancy gap analysis ("You · Let her change the due
//  date where it is shown", P1): the Due date row in You › Details opened a
//  profile screen with no due-date field, so after her dating scan the only
//  way to fix the date was to find Tools › Due Date. Flo's Pregnancy Mode and
//  What to Expect's Pregnancy Details both change it in one place.
//
//  THE FOUR WAYS ONBOARDING OFFERS, in the same words: Last period, Doctor's
//  date, Scan date, IVF transfer. After week 12 "Scan date" leads, because by
//  then most women have had a dating scan and that is the better date.
//
//  ⚠️ THE ARITHMETIC IS THE CALCULATOR'S, NOT A COPY. `ddcComputeEdd` and
//  `ddcSourceFor` (tools/due_date_calculator_screen.dart) are the one place the
//  formulas and the ownership rule live; onboarding uses them too. A second
//  copy would drift, and a due date that differs by a day between two screens
//  is a week number that differs on some days.
//
//  ⚠️ A CLINIC'S DATE IS NOT OURS TO REPLACE QUIETLY (CLAUDE.md, clinical
//  invariants: treating clinician outranks ParentVeda's calculation). When her
//  date came from a scan, her doctor or a transfer and she picks "Last period",
//  the screen says so before she saves. It does not stop her: it is her date,
//  and her doctor may have told her to. It only makes sure she knows which
//  number is usually the one to follow.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_date_sheet.dart';
import '../../widgets/pv_feedback.dart';
import '../products/pv_store_chrome.dart' show PvChip, PvCommit, kPvLine, pvStorePalette, pvSnack;
import '../v2/v2_palette.dart';
import '../tools/due_date_calculator_screen.dart' show DdcMethod, ddcComputeEdd, ddcSourceFor;

const String kPregDueDateRoute = 'pregnancy/due_date';

void openPregDueDate(BuildContext context, PregnancyController c) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPregDueDateRoute),
    builder: (_) => PregDueDateScreen(pregnancy: c),
  ));
}

/// The four ways, in onboarding's words: the pill, and what the date field asks.
const Map<DdcMethod, (String, String)> kPregDueDateWays = {
  DdcMethod.lmp: ('Last period', 'First day of your last period'),
  DdcMethod.known: ("Doctor's date", 'The due date you were given'),
  DdcMethod.ultrasound: ('Scan date', 'The day of your dating scan'),
  DdcMethod.ivf: ('IVF transfer', 'The day of the embryo transfer'),
};

/// The order the ways are offered in: "Scan date" first from week 12.
List<DdcMethod> pregDueDateOrder(int week) => week >= 12
    ? const [DdcMethod.ultrasound, DdcMethod.known, DdcMethod.lmp, DdcMethod.ivf]
    : const [DdcMethod.lmp, DdcMethod.known, DdcMethod.ultrasound, DdcMethod.ivf];

/// Where her current date came from, in words.
String pregDueDateFrom(DueDateSource s) => switch (s) {
      DueDateSource.scan => 'your scan',
      DueDateSource.clinician => 'your doctor',
      DueDateSource.ivfTransfer => 'your transfer date',
      DueDateSource.lastPeriod => 'your last period',
      DueDateSource.conception => 'your conception date',
      DueDateSource.unknown => '',
    };

/// True when saving [method] would put our calculation over a date her clinic
/// gave her. Only "Last period" is ours among the four; the other three are
/// the clinic's own.
bool pregDueDateOverridesClinic(DueDateSource current, DdcMethod method) =>
    current.clinicOwned && !ddcSourceFor(method).clinicOwned;

class PregDueDateScreen extends StatefulWidget {
  const PregDueDateScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<PregDueDateScreen> createState() => _PregDueDateScreenState();
}

class _PregDueDateScreenState extends State<PregDueDateScreen> {
  late DdcMethod _method = pregDueDateOrder(widget.pregnancy.currentWeek).first;
  DateTime? _date;
  int _gaWeeks = 12, _gaDays = 0;
  int _embryoDay = 5;

  PregnancyController get _c => widget.pregnancy;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime? get _edd => _date == null
      ? null
      : ddcComputeEdd(
          method: _method,
          lmp: _date,
          known: _date,
          scan: _date,
          transfer: _date,
          gaWeeks: _gaWeeks,
          gaDays: _gaDays,
          embryoDay: _embryoDay,
        );

  /// A due date for a pregnancy that is still going: at most three weeks past,
  /// at most about ten months ahead.
  bool _plausible(DateTime edd) {
    final today = _day(DateTime.now());
    return !edd.isBefore(today.subtract(const Duration(days: 21))) &&
        !edd.isAfter(today.add(const Duration(days: 300)));
  }

  (DateTime, DateTime) _bounds() {
    final today = _day(DateTime.now());
    return switch (_method) {
      DdcMethod.known => (today.subtract(const Duration(days: 21)), today.add(const Duration(days: 300))),
      _ => (today.subtract(const Duration(days: 300)), today),
    };
  }

  Future<void> _pick() async {
    final (first, last) = _bounds();
    final d = await showPvDateSheet(
      context,
      title: kPregDueDateWays[_method]!.$2,
      initial: _date ?? (_method == DdcMethod.known ? _c.dueDate : last),
      first: first,
      last: last,
    );
    if (d != null) setState(() => _date = _day(d));
  }

  Future<void> _save() async {
    final edd = _edd;
    if (edd == null || !_plausible(edd)) return;
    pvCommitFeedback();
    await _c.setDueDate(edd, source: ddcSourceFor(_method));
    if (!mounted) return;
    Navigator.of(context).maybePop();
    pvSnack(context, 'Saved. Your weeks now follow this date.');
  }

  static String _long(DateTime d) {
    const m = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  /// The week this date would make today, counted the controller's way.
  static int _weekFor(DateTime edd) {
    final days = _day(edd).difference(_day(DateTime.now())).inDays;
    return (40 - (days / 7).floor()).clamp(1, 42);
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final from = pregDueDateFrom(_c.dueDateSource);
    final edd = _edd;
    final ok = edd != null && _plausible(edd);
    final warnClinic = pregDueDateOverridesClinic(_c.dueDateSource, _method);
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(backgroundColor: p.ground, elevation: 0, foregroundColor: p.ink1),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Text('Your due date',
                style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w500, height: 1.15, color: p.ink1)),
            const SizedBox(height: 8),
            Text(
                _c.isDueDateSet
                    ? 'Now ${_long(_c.dueDate)}${from.isEmpty ? '' : ', from $from'}.'
                    : 'No date saved yet. Add one and every week in the app follows it.',
                style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2)),
            const SizedBox(height: 22),
            _eyebrow(p, 'How do you know it?'),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in pregDueDateOrder(_c.currentWeek))
                PvChip(
                  key: ValueKey('preg_due_way_${m.name}'),
                  label: kPregDueDateWays[m]!.$1,
                  selected: _method == m,
                  onTap: () => setState(() {
                    _method = m;
                    _date = null;
                  }),
                ),
            ]),
            const SizedBox(height: 18),
            _field(p, kPregDueDateWays[_method]!.$2,
                _date == null ? 'Tap to choose' : _long(_date!), _pick,
                key: const ValueKey('preg_due_date_field')),
            if (_method == DdcMethod.ultrasound) ...[
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
              const SizedBox(height: 6),
              Text('It is printed on the scan report, often as "GA" or "gestational age".',
                  style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3)),
            ],
            if (_method == DdcMethod.ivf) ...[
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
                key: const ValueKey('preg_due_result'),
                padding: const EdgeInsets.all(16),
                // White with a hairline: no tinted block behind text.
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kPvLine),
                ),
                child: ok
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_long(edd),
                            style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: p.ink1)),
                        const SizedBox(height: 4),
                        Text('That makes this week ${_weekFor(edd)}.',
                            style: pvManrope(fontSize: 13.5, color: p.ink2)),
                      ])
                    : Text(
                        "That date doesn't fit a pregnancy that is still going. Check it and try again.",
                        style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink1)),
              ),
            ],
            if (warnClinic) ...[
              const SizedBox(height: 14),
              Row(
                key: const ValueKey('preg_due_clinic_note'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: p.ink2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'Your date now comes from $from. A date from a scan or your doctor is '
                        'usually the one to follow, so change it this way only if they have '
                        'told you to.',
                        style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 22),
            PvCommit(
              key: const ValueKey('preg_due_save'),
              label: 'Save this date',
              onTap: ok ? _save : null,
            ),
            const SizedBox(height: 12),
            Text('Your weeks, your week pages and your reminders all follow this date.',
                style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3)),
          ],
        ),
      ),
    );
  }

  Widget _eyebrow(V2Palette p, String s) => Text(s.toUpperCase(),
      // A group label inside the form: grey caps, never the brand violet.
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
              Text(value,
                  style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
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

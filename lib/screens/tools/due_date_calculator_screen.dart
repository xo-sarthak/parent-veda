// =============================================================================
//  DueDateCalculatorScreen — the warm "gateway" calculator
// -----------------------------------------------------------------------------
//  Not a utility — the first chapter of the journey. Pick a method (LMP /
//  conception / IVF / ultrasound / known), and the result blooms into a
//  pregnancy roadmap (EDD, current week·day·trimester, mini timeline, key
//  milestones, trimester breakdown, conception window, month view) ending in
//  "Start My Pregnancy Journey" → sets the app's real due date.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';

enum DdcMethod { lmp, conception, ivf, ultrasound, known }

/// Pure estimated-due-date math, shared by the Tools calculator and the sign-up
/// "calculate your due date" sheet. Keeping the formulas in one place means both
/// stay in sync. Returns null until the method's required date is provided.
DateTime? ddcComputeEdd({
  required DdcMethod method,
  DateTime? lmp,
  DateTime? conception,
  DateTime? transfer,
  DateTime? scan,
  DateTime? known,
  int cycle = 28,
  int embryoDay = 5,
  int gaWeeks = 8,
  int gaDays = 0,
}) {
  switch (method) {
    case DdcMethod.lmp:
      return lmp?.add(Duration(days: 280 + (cycle - 28)));
    case DdcMethod.conception:
      return conception?.add(const Duration(days: 266));
    case DdcMethod.ivf:
      return transfer?.add(Duration(days: 266 - embryoDay));
    case DdcMethod.ultrasound:
      return scan?.add(Duration(days: 280 - (gaWeeks * 7 + gaDays)));
    case DdcMethod.known:
      return known;
  }
}

class DueDateCalculatorScreen extends StatefulWidget {
  const DueDateCalculatorScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<DueDateCalculatorScreen> createState() =>
      _DueDateCalculatorScreenState();
}

class _DueDateCalculatorScreenState extends State<DueDateCalculatorScreen> {
  DdcMethod _method = DdcMethod.lmp;
  DateTime? _lmp, _conception, _transfer, _scan, _known;
  int _cycle = 28;
  int _embryoDay = 5;
  int _gaWeeks = 8, _gaDays = 0;
  DateTime? _edd;

  PregnancyController get p => widget.controller;

  @override
  void initState() {
    super.initState();
    // If she's already set her due date, open straight to the saved roadmap
    // (with the Recalculate / edit option) instead of a blank calculator — she
    // sees her stored date, she doesn't have to compute it again.
    if (p.isDueDateSet) _edd = p.dueDate;
  }

  static const List<BoxShadow> _soft = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 14, offset: Offset(0, 6)),
  ];

  DateTime _dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime? _compute() => ddcComputeEdd(
        method: _method,
        lmp: _lmp,
        conception: _conception,
        transfer: _transfer,
        scan: _scan,
        known: _known,
        cycle: _cycle,
        embryoDay: _embryoDay,
        gaWeeks: _gaWeeks,
        gaDays: _gaDays,
      );

  @override
  Widget build(BuildContext context) {
    final s = S(p.language);
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(s.ddcTitle,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: _edd == null ? _inputView(s) : _resultView(s, _edd!),
    );
  }

  // ===========================================================================
  //  Input
  // ===========================================================================
  Widget _inputView(S s) {
    final ready = _compute() != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        Text(s.ddcHeader,
            style: GoogleFonts.fraunces(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary900,
                height: 1.15)),
        const SizedBox(height: 6),
        Text(s.ddcSub,
            style: GoogleFonts.manrope(
                fontSize: 13.5, height: 1.5, color: AppTheme.neutral600)),
        const SizedBox(height: 20),
        Text(s.ddcMethod,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary900)),
        const SizedBox(height: 10),
        _methodCards(s),
        const SizedBox(height: 18),
        _inputs(s),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: ready ? () => setState(() => _edd = _compute()) : null,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(s.ddcCalculate,
                style: GoogleFonts.manrope(
                    fontSize: 15, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _methodCards(S s) {
    final items = <(DdcMethod, IconData, String)>[
      (DdcMethod.lmp, Icons.calendar_month_rounded, s.ddcLmp),
      (DdcMethod.conception, Icons.favorite_rounded, s.ddcConception),
      (DdcMethod.ivf, Icons.science_rounded, s.ddcIvf),
      (DdcMethod.ultrasound, Icons.monitor_heart_rounded, s.ddcUltrasound),
      (DdcMethod.known, Icons.event_available_rounded, s.ddcKnown),
    ];
    return Column(
      children: [
        for (final it in items)
          GestureDetector(
            onTap: () => setState(() => _method = it.$1),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _method == it.$1
                    ? AppTheme.primary500.withValues(alpha: 0.08)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _method == it.$1
                        ? AppTheme.primary500
                        : AppTheme.outlineVariant,
                    width: _method == it.$1 ? 1.5 : 1),
              ),
              child: Row(children: [
                Icon(it.$2,
                    size: 20,
                    color: _method == it.$1
                        ? AppTheme.primary500
                        : AppTheme.neutral500),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(it.$3,
                      style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                ),
                if (_method == it.$1)
                  const Icon(Icons.check_circle_rounded,
                      size: 20, color: AppTheme.primary500),
              ]),
            ),
          ),
      ],
    );
  }

  Widget _inputs(S s) {
    switch (_method) {
      case DdcMethod.lmp:
        return Column(children: [
          _dateField(s, s.ddcLmpDate, _lmp, (d) => setState(() => _lmp = d)),
          const SizedBox(height: 14),
          _cycleSelector(s),
        ]);
      case DdcMethod.conception:
        return _dateField(s, s.ddcConceptionDate, _conception,
            (d) => setState(() => _conception = d));
      case DdcMethod.ivf:
        return Column(children: [
          _dateField(s, s.ddcTransferDate, _transfer,
              (d) => setState(() => _transfer = d)),
          const SizedBox(height: 14),
          _segChips(s.ddcEmbryoDay, [
            (3, s.ddcDay3),
            (5, s.ddcDay5),
          ], _embryoDay, (v) => setState(() => _embryoDay = v)),
        ]);
      case DdcMethod.ultrasound:
        return Column(children: [
          _dateField(
              s, s.ddcScanDate, _scan, (d) => setState(() => _scan = d)),
          const SizedBox(height: 14),
          _gaStepper(s),
        ]);
      case DdcMethod.known:
        return _dateField(
            s, s.ddcKnownDate, _known, (d) => setState(() => _known = d),
            future: true);
    }
  }

  Widget _dateField(S s, String label, DateTime? value, ValueChanged<DateTime> onPick,
      {bool future = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.neutral600)),
      const SizedBox(height: 6),
      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? now,
            firstDate: future ? now : DateTime(now.year - 1),
            lastDate: future ? DateTime(now.year + 1, now.month + 1) : now,
          );
          if (picked != null) onPick(_dOnly(picked));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _soft),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: AppTheme.primary500),
            const SizedBox(width: 12),
            Text(value == null ? s.ddcPickDate : s.formatLongDate(value),
                style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: value == null
                        ? AppTheme.neutral400
                        : AppTheme.primary900)),
          ]),
        ),
      ),
    ]);
  }

  Widget _cycleSelector(S s) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${s.ddcCycle}: $_cycle ${s.ddcDays}',
          style: GoogleFonts.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.neutral600)),
      Slider(
        value: _cycle.toDouble(),
        min: 21,
        max: 35,
        divisions: 14,
        label: '$_cycle',
        onChanged: (v) => setState(() => _cycle = v.round()),
      ),
    ]);
  }

  Widget _segChips(String label, List<(int, String)> opts, int selected,
      ValueChanged<int> onPick) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.neutral600)),
      const SizedBox(height: 8),
      Row(children: [
        for (final o in opts)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onPick(o.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: selected == o.$1
                      ? AppTheme.primary500
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: selected == o.$1 ? null : _soft,
                ),
                child: Text(o.$2,
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: selected == o.$1
                            ? Colors.white
                            : AppTheme.neutral700)),
              ),
            ),
          ),
      ]),
    ]);
  }

  Widget _gaStepper(S s) {
    Widget step(String l, int v, VoidCallback dec, VoidCallback inc) => Row(
          children: [
            Text(l,
                style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neutral600)),
            const Spacer(),
            _rnd(Icons.remove_rounded, dec),
            SizedBox(
                width: 34,
                child: Text('$v',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary900))),
            _rnd(Icons.add_rounded, inc),
          ],
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.ddcGa,
          style: GoogleFonts.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.neutral600)),
      const SizedBox(height: 8),
      step(s.weekWord, _gaWeeks,
          () => setState(() => _gaWeeks = (_gaWeeks - 1).clamp(4, 40)),
          () => setState(() => _gaWeeks = (_gaWeeks + 1).clamp(4, 40))),
      const SizedBox(height: 6),
      step(s.ddcDaysLabel, _gaDays,
          () => setState(() => _gaDays = (_gaDays - 1).clamp(0, 6)),
          () => setState(() => _gaDays = (_gaDays + 1).clamp(0, 6))),
    ]);
  }

  Widget _rnd(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppTheme.primary700),
        ),
      );

  // ===========================================================================
  //  Result (the roadmap)
  // ===========================================================================
  Widget _resultView(S s, DateTime edd) {
    final today = _dOnly(DateTime.now());
    final daysToEdd = edd.difference(today).inDays;
    final day = (280 - daysToEdd).clamp(1, 280);
    final week = ((day - 1) ~/ 7 + 1).clamp(1, 40);
    final dayOfWeek = ((day - 1) % 7) + 1;
    final start = edd.subtract(const Duration(days: 280));

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        // celebration
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary500, AppTheme.primary700],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: _soft,
          ),
          child: Column(children: [
            const Text('🤍', style: TextStyle(fontSize: 34)),
            const SizedBox(height: 10),
            Text(s.ddcResultLead,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85))),
            const SizedBox(height: 6),
            Text(s.formatLongDate(edd),
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99)),
              child: Text(
                  '${s.weekDayLine(week, dayOfWeek)} · ${s.trimesterName(week)}',
                  style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ]),
        ),
        const SizedBox(height: 18),

        // timeline preview
        _card(s.ddcTimeline, _timelineBar(s, week)),
        const SizedBox(height: 14),

        // key milestones
        _card(s.ddcMilestones, _milestones(s, week)),
        const SizedBox(height: 14),

        // trimester breakdown
        _card(s.ddcTrimesters, _trimesters(s, start, edd)),
        const SizedBox(height: 14),

        // conception window + months
        _card(s.ddcConceptionTitle, _conceptionMonths(s, edd, week)),
        const SizedBox(height: 18),

        // conversion
        _conversion(s, edd),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _edd = null),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(s.ddcRecalculate),
          ),
        ),
      ],
    );
  }

  Widget _card(String title, Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: _soft),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary900)),
          const SizedBox(height: 14),
          child,
        ]),
      );

  Widget _timelineBar(S s, int week) {
    final frac = (week / 40).clamp(0.0, 1.0);
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final x = (w * frac).clamp(0.0, w);
      return SizedBox(
        height: 48,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: 0,
            right: 0,
            top: 30,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(99)),
            ),
          ),
          Positioned(
            left: 0,
            top: 30,
            child: Container(
              height: 8,
              width: x,
              decoration: BoxDecoration(
                  color: AppTheme.primary500,
                  borderRadius: BorderRadius.circular(99)),
            ),
          ),
          Positioned(
            left: (x - 30).clamp(0.0, w - 60),
            top: 0,
            child: Column(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.primary900,
                    borderRadius: BorderRadius.circular(99)),
                child: Text(s.youAreHere,
                    style: GoogleFonts.manrope(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ]),
          ),
          Positioned(
            left: (x - 7).clamp(0.0, w - 14),
            top: 26,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppTheme.primary500, width: 3)),
            ),
          ),
        ]),
      );
    });
  }

  Widget _milestones(S s, int week) {
    final ms = <(int, String)>[
      (8, s.ddcMsHeartbeat),
      (12, s.ddcMsNt),
      (20, s.ddcMsAnomaly),
      (24, s.ddcMsViability),
      (28, s.ddcMsThirdTri),
      (37, s.ddcMsFullTerm),
      (40, s.ddcMsDue),
    ];
    return Column(
      children: [
        for (final m in ms)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(
                  week >= m.$1
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: week >= m.$1
                      ? AppTheme.primary500
                      : AppTheme.neutral300),
              const SizedBox(width: 10),
              Expanded(
                child: Text(m.$2,
                    style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary900)),
              ),
              Text(s.jrWeekLabel(m.$1),
                  style: GoogleFonts.manrope(
                      fontSize: 11.5, color: AppTheme.neutral500)),
            ]),
          ),
      ],
    );
  }

  Widget _trimesters(S s, DateTime start, DateTime edd) {
    Widget row(String label, DateTime a, DateTime b) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
            ),
            Text('${s.formatShortDate(a)} – ${s.formatShortDate(b)}',
                style: GoogleFonts.manrope(
                    fontSize: 12, color: AppTheme.neutral600)),
          ]),
        );
    final t1End = start.add(const Duration(days: 13 * 7));
    final t2End = start.add(const Duration(days: 27 * 7));
    return Column(children: [
      row(s.trimesterName(8), start, t1End),
      row(s.trimesterName(20), t1End, t2End),
      row(s.trimesterName(32), t2End, edd),
    ]);
  }

  Widget _conceptionMonths(S s, DateTime edd, int week) {
    final conception = edd.subtract(const Duration(days: 266));
    final month = ((week - 1) / 4.444).floor().clamp(0, 8) + 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.spa_rounded, size: 16, color: AppTheme.secondary500),
        const SizedBox(width: 8),
        Expanded(
          child: Text('${s.ddcConceptionAround}: ${s.formatLongDate(conception)}',
              style: GoogleFonts.manrope(
                  fontSize: 13, color: AppTheme.neutral700)),
        ),
      ]),
      const SizedBox(height: 14),
      Text(s.ddcMonths,
          style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.neutral600)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (int m = 1; m <= 9; m++)
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: m == month
                    ? AppTheme.primary500
                    : AppTheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Text('$m',
                  style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color:
                          m == month ? Colors.white : AppTheme.neutral600)),
            ),
        ],
      ),
    ]);
  }

  Widget _conversion(S s, DateTime edd) {
    final benefits = <(IconData, String)>[
      (Icons.child_care_rounded, s.ddcBenWeekly),
      (Icons.wb_sunny_rounded, s.ddcBenDaily),
      (Icons.event_note_rounded, s.ddcBenScans),
      (Icons.self_improvement_rounded, s.ddcBenGarbh),
      (Icons.healing_rounded, s.ddcBenSymptoms),
      (Icons.luggage_rounded, s.ddcBenBag),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.secondary100, AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: _soft,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.ddcReady,
            style: GoogleFonts.fraunces(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary900)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final b in benefits)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(b.$1, size: 16, color: AppTheme.primary500),
                const SizedBox(width: 6),
                Text(b.$2,
                    style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary800)),
              ]),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              await p.setDueDate(edd);
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(s.ddcStarted)));
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(s.ddcStart,
                style: GoogleFonts.manrope(
                    fontSize: 15, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

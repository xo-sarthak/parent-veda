// =============================================================================
//  Whole journey: the pregnancy, week by week (2026-10-17)
// -----------------------------------------------------------------------------
//  Replaces the old calendar's Timeline tab, which was one 280-day list where
//  every weight and every kick count was its own row. Now (Runna 9eb278de,
//  Flo 347a171b, stoic. 5e124ffa):
//
//    · one card per week: its dates, the milestone, the usual check that
//      starts that week, and COUNTS of what she logged ("2 weights · 1 note");
//    · the week she is in is ringed and says "You are here", and the page
//      opens scrolled to it;
//    · the trimester switch at the top jumps to its first week;
//    · a card opens that week's page; a count opens that day in the calendar
//      (this page pops with the date and the hub picks it).
// =============================================================================

import 'package:flutter/material.dart';

import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import 'preg_cal_data.dart';
import 'preg_cal_parts.dart';
import 'preg_cal_sheets.dart';
import 'preg_calendar_hub.dart' show pregCalListenable;

class PregCalJourneyScreen extends StatefulWidget {
  const PregCalJourneyScreen({super.key, required this.controller, this.today});
  final PregnancyController controller;
  final DateTime? today;

  @override
  State<PregCalJourneyScreen> createState() => _PregCalJourneyScreenState();
}

class _PregCalJourneyScreenState extends State<PregCalJourneyScreen> {
  static const int _first = PregnancyController.firstContentWeek; // 4
  static const int _last = PregnancyController.lastContentWeek; // 40

  late final DateTime _today = pregDayOnly(widget.today ?? DateTime.now());
  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _weekKeys = {};
  final Map<int, GlobalKey> _triKeys = {1: GlobalKey(), 2: GlobalKey(), 3: GlobalKey()};

  PregnancyController get p => widget.controller;
  int get _nowWeek => pregWeekOf(p.dueDate, _today);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _weekKeys[_nowWeek.clamp(_first, _last)]?.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.15);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: pregCalListenable(p),
        builder: (context, _) => _build(context),
      );

  Widget _build(BuildContext context) {
    final items = pregCalItems();
    final checks = pregChecks();
    final curTri = pregTrimesterFor(pregCompletedWeeks(p.dueDate, _today));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: kPvInk),
        title: Text('Whole journey', style: pregCalSerif(22)),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: kPregCalTint, borderRadius: BorderRadius.circular(999)),
            child: Row(children: [
              for (final t in const [1, 2, 3])
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: t == curTri,
                    child: pregCalTap(
                      onTap: () {
                        final ctx = _triKeys[t]!.currentContext;
                        if (ctx != null) {
                          Scrollable.ensureVisible(ctx,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: t == curTri ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('${['', '1st', '2nd', '3rd'][t]} trimester',
                            textAlign: TextAlign.center,
                            style: pvManrope(
                                fontSize: 12.5, fontWeight: FontWeight.w700, color: kPvInk)),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
        Expanded(
          // A Column in a scroll view, not a lazy list: every week must be
          // laid out so "open on this week" and the trimester jump can find it.
          child: SingleChildScrollView(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(16, 0, 16, kAskFabReserve + 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var w = _first; w <= _last; w++) ...[
                if (w == _first || w == 15 || w == 29)
                  _trimesterHead(w == _first ? 1 : (w == 15 ? 2 : 3)),
                _weekCard(w, items, checks),
                const SizedBox(height: 8),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  // Week 15 is the first week IN the second trimester (14 completed weeks),
  // week 29 the first in the third (28 completed): the same boundary
  // `pregTrimesterFor` states for the whole calendar.
  Widget _trimesterHead(int t) => Padding(
        key: _triKeys[t],
        padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(kPregTrimesterNames[t], style: pregCalSerif(20)),
          const SizedBox(height: 2),
          Text(
              const ['', 'Up to 13 weeks 6 days', '14 weeks to 27 weeks 6 days', '28 weeks to birth'][t],
              style: pregCalBody(size: 12.5, color: pvStorePalette.ink3)),
        ]),
      );

  String _countLabel(PregCalKind k, int n) => switch (k) {
        PregCalKind.appointment => '$n ${n == 1 ? 'appointment' : 'appointments'}',
        PregCalKind.check => '$n ${n == 1 ? 'check done' : 'checks done'}',
        PregCalKind.weight => '$n ${n == 1 ? 'weight' : 'weights'}',
        PregCalKind.kicks => '$n ${n == 1 ? 'kick count' : 'kick counts'}',
        PregCalKind.symptom => '$n ${n == 1 ? 'symptom' : 'symptoms'}',
        PregCalKind.note => '$n ${n == 1 ? 'note' : 'notes'}',
        PregCalKind.journal => '$n journal',
      };

  Widget _weekCard(int w, List<PregCalItem> items, List<PregCheck> checks) {
    final pal = pvStorePalette;
    final start = pregWeekStart(p.dueDate, w);
    final end = start.add(const Duration(days: 6));
    final inWeek = [
      for (final i in items)
        if (!i.date.isBefore(start) && !i.date.isAfter(end)) i
    ];
    final byKind = <PregCalKind, List<PregCalItem>>{};
    for (final i in inWeek) {
      byKind.putIfAbsent(i.kind, () => []).add(i);
    }
    final miles = pregMilestonesForWeek(w);
    final starting = [for (final c in checks) if (c.fromWeek == w) c];
    final now = w == _nowWeek;
    final past = w < _nowWeek;
    final key = _weekKeys.putIfAbsent(w, () => GlobalKey());
    final quiet = !now && miles.isEmpty && starting.isEmpty && byKind.isEmpty;
    final dates = '${pregShortDate(start)} – ${pregShortDate(end)}';

    return Semantics(
      key: key,
      button: true,
      label: 'Week $w, $dates${now ? ', you are here' : ''}',
      child: pregCalTap(
        onTap: () => pregCalOpenWeek(context, p, w),
        child: Container(
          width: double.infinity,
          padding: quiet
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
              : EdgeInsets.all(now ? 14 : 12),
          decoration: BoxDecoration(
            color: past ? const Color(0xFFFCFCFB) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: now ? kPvInk : kPvLine, width: now ? 2 : 1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('Week $w', style: pregCalSerif(quiet ? 15 : 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(dates,
                    style: pregCalBody(size: 12, weight: FontWeight.w600, color: pal.ink3)),
              ),
              if (now)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                      color: kPvInk, borderRadius: BorderRadius.circular(999)),
                  child: Text('You are here',
                      style: pvManrope(
                          fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
            ]),
            for (final m in miles) ...[
              const SizedBox(height: 6),
              _line(Icons.star_outline_rounded, m.title.en, pal.ink2),
            ],
            for (final c in starting) ...[
              const SizedBox(height: 6),
              _line(Icons.health_and_safety_outlined,
                  '${c.title} · ${c.windowLabel.replaceFirst('Around', 'usually')}',
                  pregCalMeta(PregCalKind.check).color),
            ],
            if (byKind.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final k in PregCalKind.values)
                  if (byKind[k] != null)
                    Semantics(
                      button: true,
                      label: '${_countLabel(k, byKind[k]!.length)}, open that day',
                      excludeSemantics: true,
                      child: pregCalTap(
                        onTap: () => Navigator.of(context).pop(byKind[k]!.first.date),
                        child: PregCalKindChip(kind: k, label: _countLabel(k, byKind[k]!.length)),
                      ),
                    ),
              ]),
            ],
            if (now) ...[
              const SizedBox(height: 8),
              Text('Tap to open this week: your baby, your body, what to do.',
                  style: pregCalBody(size: 12, color: pal.ink3)),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text, Color color) => Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: pregCalBody(size: 13, color: color))),
      ]);
}

// =============================================================================
//  PpPumpScreen — the pump log (surface pp_pump), 2026-10-07
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P2 (Behind · Logging): "Our pages tell her to pump
//  ... and give her no way to keep track. Add Pump as a fourth choice in 'Log
//  a feed' (left ml, right ml)." The store and table are the fork's
//  (`PumpStore`, `pp_pump_logs`, child-scoped and co-parented, 0094): the
//  record answers "how much expressed milk is there for the baby", and the
//  person who needs that is whoever gives the bottle.
//
//  Mobbin: Google Health's add sheet (a time row defaulting to now, one Save)
//  and its week of bars (refs in pp_care_parts.dart); Copilot's large amount
//  with the unit beside it for the steppers
//  https://mobbin.com/screens/c0396b88-57a1-4745-9a84-0b22f866151d.
//
//  NO TARGET. How much a mother pumps varies widely and says little about how
//  much her baby gets at the breast; a goal here would only frighten.
// =============================================================================

import 'package:flutter/material.dart';

import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../pregnancy/preg_tool_parts.dart' show PregFoldRow;
import '../products/pv_store_chrome.dart' show PvCommit;
import '../v2/v2_palette.dart';
import '../../theme/pv_fonts.dart';
import 'pp_care_log_data.dart';
import 'pp_care_parts.dart';

class PpPumpScreen extends StatefulWidget {
  const PpPumpScreen({super.key});

  @override
  State<PpPumpScreen> createState() => _PpPumpScreenState();
}

class _PpPumpScreenState extends State<PpPumpScreen> {
  final _store = PumpStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  List<int> _mlWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = 6; i >= 0; i--)
        _store.all.where((x) {
          final d = DateTime(x.time.year, x.time.month, x.time.day);
          return d == today.subtract(Duration(days: i));
        }).fold(0, (s, x) => s + x.totalMl),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final today = _store.todays;
        final last = _store.last;
        final avg = _store.avgSessionMl7d;
        return PregToolScaffold(
          hue: 206,
          eyebrow: 'Feeding',
          mark: IntentMark.feedMark,
          title: 'Pumping',
          intro: 'A quick record of what you express, so whoever gives the bottle knows what there is.',
          children: [
            pregToolPad(PpCareStats([
              ('${_store.mlToday} ml', 'pumped today'),
              (avg == null ? 'None yet' : '$avg ml', 'a session, last 7 days'),
              (last == null ? 'None yet' : ppCareAgo(last.time), 'last session'),
            ])),
            const SizedBox(height: 18),
            pregToolPad(PvCommit(key: const ValueKey('pp_pump_log'), label: 'Log a session', onTap: _openSheet)),
            const SizedBox(height: 26),
            pregToolPad(ppCareHeading("Today's sessions")),
            const SizedBox(height: 6),
            if (today.isEmpty)
              pregToolPad(Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Nothing logged today. Log a session when you pump; left and right, or just the total.',
                    key: const ValueKey('pp_pump_empty'),
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
              ))
            else
              for (final x in today)
                pregToolPad(PpCareEntryRow(
                  key: ValueKey('pp_pump_row_${x.id}'),
                  title: '${x.totalMl} ml',
                  when: x.time,
                  detail: [
                    if (x.leftMl != null) 'Left ${x.leftMl} ml',
                    if (x.rightMl != null) 'Right ${x.rightMl} ml',
                    if (x.durationMin != null) '${x.durationMin} min',
                  ].join(' · '),
                  onRemove: () {
                    _store.remove(x.id);
                    ppCareSaved(context, 'Session removed.', undo: () => _store.add(x));
                  },
                )),
            const SizedBox(height: 26),
            pregToolPad(ppCareHeading('This week')),
            const SizedBox(height: 12),
            pregToolPad(PpWeekBars(values: _mlWeek(), unit: 'ml')),
            const SizedBox(height: 18),
            pregToolPad(Text(
              'How much you pump is not how much your baby gets at the breast. '
              'If you are worried about your supply, a lactation consultant can help.',
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
            )),
            const SizedBox(height: 18),
            // Storing it (gap analysis P2, What to Expect's "Breast Milk Storage
            // Guidelines", 2026-10-07). Pregnancy's fold row. The figures are
            // the CDC's, the same our family pages use.
            // REQUIRED_REVIEW (lactation consultant): the times below.
            pregToolPad(PregFoldRow(
              keyPrefix: 'pp_pump_storage',
              fold: 'storage',
              icon: Icons.kitchen_outlined,
              title: 'Storing expressed milk',
              body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final line in const [
                  'Room temperature: use within 4 hours.',
                  'Fridge, at the back: use within 4 days.',
                  'Freezer: best within 6 months, and up to 12.',
                  'Thawed milk: use within 24 hours, and never refreeze it.',
                  'Warm it in a bowl of warm water, never in a microwave.',
                  'Label each bag or bottle with the date.',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(line, style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1)),
                  ),
              ]),
            )),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  void _openSheet() {
    var when = DateTime.now();
    var left = 0;
    var right = 0;
    int? minutes;
    final note = TextEditingController();
    showPpCareSheet(
      context,
      title: 'Log a pumping session',
      saveLabel: 'Save session',
      body: (setSheet) => [
        ppCareLabel('When'),
        PpWhenRow(when: when, onChanged: (t) => setSheet(() => when = t)),
        const SizedBox(height: 16),
        _MlStepper(label: 'Left', value: left, keyName: 'left', onChanged: (v) => setSheet(() => left = v)),
        const SizedBox(height: 10),
        _MlStepper(label: 'Right', value: right, keyName: 'right', onChanged: (v) => setSheet(() => right = v)),
        const SizedBox(height: 16),
        ppCareLabel('How long, if you know'),
        ppCareChoices<int>(
          values: const [10, 15, 20, 30],
          selected: minutes,
          label: (m) => '$m min',
          allowNone: true,
          keyPrefix: 'pp_pump_min',
          onPick: (m) => setSheet(() => minutes = m),
        ),
        const SizedBox(height: 16),
        ppCareLabel('Note'),
        ppCareNoteField(note),
      ],
      onSave: () {
        if (left == 0 && right == 0) {
          ppCareSaved(context, 'Nothing saved: add how much from at least one side.');
          return;
        }
        _store.log(
          time: when,
          leftMl: left == 0 ? null : left,
          rightMl: right == 0 ? null : right,
          durationMin: minutes,
          note: ppCareNoteValue(note),
        );
        ppCareSaved(context, 'Pumping saved: ${left + right} ml, ${ppCareWhen(when).toLowerCase()}.');
      },
    );
  }
}

class _MlStepper extends StatelessWidget {
  const _MlStepper({required this.label, required this.value, required this.keyName, required this.onChanged});
  final String label;
  final int value;
  final String keyName;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    Widget btn(IconData icon, int delta, String k) => IconButton.outlined(
          key: ValueKey('pp_pump_${keyName}_$k'),
          tooltip: delta > 0 ? 'Add 10 ml' : 'Take away 10 ml',
          onPressed: () => onChanged((value + delta).clamp(0, 500)),
          icon: Icon(icon, color: p.ink1),
        );
    return Row(children: [
      SizedBox(
        width: 64,
        child: Text(label, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
      btn(Icons.remove_rounded, -10, 'minus'),
      Expanded(
        child: Center(
          child: Text('$value ml',
              key: ValueKey('pp_pump_${keyName}_value'),
              style: pvFraunces(fontSize: 26, fontWeight: FontWeight.w600, color: p.ink1)),
        ),
      ),
      btn(Icons.add_rounded, 10, 'plus'),
    ]);
  }
}

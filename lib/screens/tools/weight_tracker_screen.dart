// =============================================================================
//  Weight Tracker
// -----------------------------------------------------------------------------
//  Two experiences: a one-time onboarding (pre-pregnancy weight, with an
//  OPTIONAL height → personalized gain range) and an ongoing dashboard that
//  reframes weight as "my body is supporting my baby" — never a scorecard.
//  Per the product spec: the gain number is shown calmly, never celebrated or
//  judged, and the chart never shows above/below-target or warning colours.
//
//  Entries are kept individually — multiple weigh-ins per day are allowed and
//  never overwrite each other (so the record never appears to "reset").
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/app_theme.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final _store = ToolsStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.weightToolTitle),
        actions: [
          // The single top-level add affordance — labelled so it's obvious what
          // the + does. (Only once the profile is set.)
          AnimatedBuilder(
            animation: _store,
            builder: (context, _) => _store.weightOnboarded
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton.icon(
                      onPressed: () =>
                          showAddWeight(context, widget.controller),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.secondary600,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(s.addWeightShort),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          if (!_store.weightOnboarded) {
            return _SetupFlow(
              controller: widget.controller,
              onDone: () => setState(() {}),
            );
          }
          return _Dashboard(controller: widget.controller);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Onboarding (height optional)
// ---------------------------------------------------------------------------

class _SetupFlow extends StatefulWidget {
  const _SetupFlow({required this.controller, required this.onDone});
  final PregnancyController controller;
  final VoidCallback onDone;

  @override
  State<_SetupFlow> createState() => _SetupFlowState();
}

class _SetupFlowState extends State<_SetupFlow> {
  int _step = 0;
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  double? _weight;
  double? _height; // optional

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  ({double min, double max}) _gainFor(double w, double h) {
    final bmi = w / ((h / 100) * (h / 100));
    if (bmi < 18.5) return (min: 12.5, max: 18.0);
    if (bmi < 25) return (min: 11.5, max: 16.0);
    if (bmi < 30) return (min: 7.0, max: 11.5);
    return (min: 5.0, max: 9.0);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;

    if (_step == 1 && _weight != null) {
      final gain = _height != null ? _gainFor(_weight!, _height!) : null;
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: [
          const Center(child: Text('❤️', style: TextStyle(fontSize: 56))),
          const SizedBox(height: 12),
          Center(child: Text(s.profileTitleWeight, style: text.headlineMedium)),
          const SizedBox(height: 24),
          _summaryCard(s.startingWeightLabel,
              '${_weight!.toStringAsFixed(1)} ${s.kgUnit}', text),
          if (_height != null)
            _summaryCard(s.heightLabel,
                '${_height!.toStringAsFixed(0)} ${s.cmUnit}', text),
          if (gain != null)
            _summaryCard(
              s.recommendedGainLabel,
              '${gain.min.toStringAsFixed(1)} – ${gain.max.toStringAsFixed(1)} ${s.kgUnit}',
              text,
              note: s.weightGuidelineNote,
            )
          else
            _noteCard(s.gainNeedsHeight, text),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await ToolsStore.instance.setWeightProfile(_weight!, _height);
              widget.onDone();
            },
            child: Text(s.startTrackingCta),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        const Center(child: Text('⚖️', style: TextStyle(fontSize: 56))),
        const SizedBox(height: 16),
        Text(s.weightWelcomeBody, style: text.bodyLarge),
        const SizedBox(height: 24),
        Text(s.prePregnancyWeightLabel, style: text.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _weightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '60.0',
            suffixText: s.kgUnit,
            helperText: s.prePregnancyWeightHelper,
          ),
        ),
        const SizedBox(height: 20),
        Text(s.heightOptional, style: text.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _heightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '160',
            suffixText: s.cmUnit,
            helperText: s.heightHelper,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () {
            final w = double.tryParse(_weightCtrl.text.trim());
            if (w == null) return; // weight required; height optional
            final h = double.tryParse(_heightCtrl.text.trim());
            setState(() {
              _weight = w;
              _height = (h != null && h > 0) ? h : null;
              _step = 1;
            });
          },
          child: Text(s.continueCta),
        ),
      ],
    );
  }

  Widget _summaryCard(String label, String value, TextTheme text,
      {String? note}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodyMedium),
          const SizedBox(height: 4),
          Text(value,
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          if (note != null) ...[
            const SizedBox(height: 8),
            Text(note, style: text.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _noteCard(String note, TextTheme text) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primary50,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(note, style: text.bodyMedium),
      );
}

// ---------------------------------------------------------------------------
//  Dashboard
// ---------------------------------------------------------------------------

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.controller});
  final PregnancyController controller;

  /// Educational contributor estimates (kg), anchored on the spec's week-23
  /// example and scaled by week. Not exact measurements.
  Map<String, double> _contributors(int week) {
    final f = week / 23.0;
    double r(double v) => (v * f * 10).round() / 10;
    return {
      'baby': r(0.6),
      'placenta': r(0.5),
      'amniotic': r(0.4),
      'blood': r(1.2),
      'breast': r(0.5),
      'energy': r(1.5),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final store = ToolsStore.instance;
    final week = controller.currentWeek;
    final latest = store.latestWeight;
    final pre = store.prePregnancyWeight ?? 0;
    final gain = latest != null ? latest.weight - pre : null;
    final entries = store.weightEntries; // newest first

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        // Hero: current weight (or empty state).
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.secondary50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: latest == null
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${s.weekWord} $week', style: text.bodyMedium),
                  const SizedBox(height: 8),
                  Text(s.weightEmptyState(week), style: text.bodyLarge),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${s.weekWord} $week', style: text.bodyMedium),
                  const SizedBox(height: 6),
                  Text('${latest.weight.toStringAsFixed(1)} ${s.kgUnit}',
                      style: text.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${s.currentWeightLabel} · ${s.lastUpdatedLabel}: '
                      '${_lastUpdated(s, latest)}',
                      style: text.bodySmall),
                ]),
        ),
        const SizedBox(height: 14),
        // Supportive insight.
        _card(context, title: s.bodySupportingTitle, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heartLine(text, s.supportGrowingBaby),
            _heartLine(text, s.supportPlacenta),
            _heartLine(text, s.supportAmniotic),
            _heartLine(text, s.supportBlood),
            const SizedBox(height: 8),
            Text(s.everyPregnancyUnique, style: text.bodySmall),
          ],
        )),
        const SizedBox(height: 14),
        // Weight gain (calm — small, not celebrated).
        if (gain != null)
          _card(context, title: s.weightGainSince, child: Text(
            '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)} ${s.kgUnit}',
            style: text.titleLarge?.copyWith(color: AppTheme.neutral700),
          )),
        if (gain != null) const SizedBox(height: 14),
        // Where weight comes from.
        _card(context, title: s.whereWeightComesFrom, child: _contributorsView(
          context, _contributors(week), s, text,
        )),
        const SizedBox(height: 14),
        // What changed (only once there is at least one entry).
        if (latest != null)
          _card(context, title: s.whatChangedTitle, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heartLine(text, s.changedBabyGrew),
              _heartLine(text, s.changedAmniotic),
              _heartLine(text, s.changedBlood),
              _heartLine(text, s.changedUterus),
            ],
          )),
        if (latest != null) const SizedBox(height: 14),
        // Weekly insight.
        _card(context, title: s.thisWeekLabel,
            child: Text(s.weeklyWeightInsight(week), style: text.bodyLarge)),
        const SizedBox(height: 14),
        // Chart.
        if (entries.isNotEmpty)
          _card(context, title: s.weightChartTitle, child: _ChartView(
            controller: controller,
          )),
        if (entries.isNotEmpty) const SizedBox(height: 14),
        // History — every entry, with column headings.
        if (entries.isNotEmpty)
          _card(context, title: s.weightHistoryTitle, child: Column(
            children: [
              _historyHeader(s, text),
              const Divider(height: 16),
              for (int i = 0; i < entries.length; i++) ...[
                _historyRow(context, entries[i], pre, s, text),
                Divider(height: 1, color: AppTheme.outlineVariant),
              ],
              // The starting (pre-pregnancy) weight — the baseline every "change"
              // is measured from. Tinted + badged so it reads as the origin.
              if (pre > 0) _startingRow(pre, s, text),
            ],
          )),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => showAddWeight(context, controller),
          icon: const Icon(Icons.add_rounded),
          label: Text(s.addTodaysWeight),
        ),
      ],
    );
  }

  String _lastUpdated(S s, WeightEntry e) {
    final d = DateTime.tryParse(e.timeIso);
    if (d == null) return e.dateIso;
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return '${s.todayWord} · ${s.formatClock(d)}';
    }
    return s.formatShortDate(d);
  }

  Widget _card(BuildContext context,
      {required String title, required Widget child}) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  Widget _heartLine(TextTheme text, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('❤️ ', style: TextStyle(fontSize: 13)),
          Expanded(child: Text(label, style: text.bodyLarge)),
        ]),
      );

  Widget _contributorsView(BuildContext context, Map<String, double> c, S s,
      TextTheme text) {
    final labels = {
      'baby': s.contributorBaby,
      'placenta': s.contributorPlacenta,
      'amniotic': s.contributorAmniotic,
      'blood': s.contributorBlood,
      'breast': s.contributorBreast,
      'energy': s.contributorEnergy,
    };
    final maxV = c.values.fold<double>(0, (a, b) => b > a ? b : a);
    return Column(children: [
      for (final entry in c.entries) ...[
        Row(children: [
          SizedBox(width: 96, child: Text(labels[entry.key]!, style: text.bodyMedium)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: maxV <= 0 ? 0 : entry.value / maxV,
                minHeight: 8,
                backgroundColor: AppTheme.surfaceContainerHigh,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primary400),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('${entry.value.toStringAsFixed(1)} ${s.kgUnit}',
              style: text.labelMedium),
        ]),
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 2),
      Text(s.estimatesNote, style: text.bodySmall),
    ]);
  }

  /// Column headings for the history table.
  Widget _historyHeader(S s, TextTheme text) {
    final style = text.labelSmall?.copyWith(
      color: AppTheme.neutral500,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    );
    return Row(children: [
      Expanded(flex: 5, child: Text(s.dateLabel, style: style)),
      Expanded(flex: 3, child: Text(s.weekWord, style: style)),
      Expanded(flex: 4, child: Text(s.weightLabel, style: style)),
      SizedBox(width: 56, child: Text(s.changeLabel, style: style, textAlign: TextAlign.right)),
    ]);
  }

  Widget _historyRow(
      BuildContext context, WeightEntry e, double pre, S s, TextTheme text) {
    final d = DateTime.tryParse(e.timeIso) ?? DateTime.tryParse(e.dateIso);
    final change = e.weight - pre;
    return InkWell(
      onLongPress: () => _confirmDelete(context, e, s),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            flex: 5,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d != null ? s.formatShortDate(d) : e.dateIso,
                  style: text.bodyMedium),
              if (d != null)
                Text(s.formatClock(d),
                    style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
            ]),
          ),
          Expanded(flex: 3, child: Text('${e.week}', style: text.bodyMedium)),
          Expanded(
            flex: 4,
            child: Text('${e.weight.toStringAsFixed(1)} ${s.kgUnit}',
                style: text.bodyLarge),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
              textAlign: TextAlign.right,
              style: text.labelMedium?.copyWith(color: AppTheme.neutral500),
            ),
          ),
        ]),
      ),
    );
  }

  /// The pre-pregnancy starting weight, shown as the origin row of the history —
  /// a leading "START" chip + label (sharing the Date+Week width so it never
  /// crowds), with the weight aligned under the Weight column.
  Widget _startingRow(double pre, S s, TextTheme text) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        // Date + Week columns combined (flex 8) → roomy for chip + label.
        Expanded(
          flex: 8,
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                s.startWord.toUpperCase(),
                style: text.labelSmall?.copyWith(
                  color: AppTheme.primary700,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                s.startingWeightLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary800,
                ),
              ),
            ),
          ]),
        ),
        // Weight column (flex 4) — lines up with the Weight heading above.
        Expanded(
          flex: 4,
          child: Text(
            '${pre.toStringAsFixed(1)} ${s.kgUnit}',
            style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        // Change column (fixed 56) — baseline, so a quiet dash.
        SizedBox(
          width: 56,
          child: Text('—',
              textAlign: TextAlign.right,
              style: text.labelMedium?.copyWith(color: AppTheme.neutral400)),
        ),
      ]),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WeightEntry e, S s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(s.deleteEntryQ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
        ],
      ),
    );
    if (ok == true) await ToolsStore.instance.deleteWeightEntry(e.id);
  }
}

/// The add-weight bottom sheet, shared by the top app-bar button and the bottom
/// button. Allows any past date; multiple entries per day are kept.
Future<void> showAddWeight(
    BuildContext context, PregnancyController controller) async {
  final s = S(controller.language);
  final ctrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime date = DateTime.now();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    showDragHandle: true,
    builder: (ctx) {
      final text = Theme.of(ctx).textTheme;
      return StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              22, 4, 22, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.addWeightTitle, style: text.headlineSmall),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: s.currentWeightLabel, suffixText: s.kgUnit),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime(date.year - 1),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setSheet(() => date = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: s.dateLabel),
                    child: Text(s.formatLongDate(date)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(labelText: s.notesOptional),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final w = double.tryParse(ctrl.text.trim());
                      if (w == null) return;
                      final now = DateTime.now();
                      final ts = DateTime(date.year, date.month, date.day,
                          now.hour, now.minute, now.second);
                      ToolsStore.instance.addWeightEntry(WeightEntry(
                        id: 'w_${now.microsecondsSinceEpoch}',
                        dateIso:
                            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                        timeIso: ts.toIso8601String(),
                        week: controller.currentWeek,
                        weight: w,
                        notes: notesCtrl.text.trim(),
                      ));
                      Navigator.of(ctx).pop();
                    },
                    child: Text(s.saveCta),
                  ),
                ),
              ]),
        );
      });
    },
  );
}

// ---------------------------------------------------------------------------
//  Weight chart: actual line (by date) over a soft recommended-range band.
// ---------------------------------------------------------------------------

class _ChartView extends StatelessWidget {
  const _ChartView({required this.controller});
  final PregnancyController controller;

  /// Fractional gestational week for an entry, from its actual date — so two
  /// entries on different days land at different x positions (and same-day ones
  /// sit together), instead of every entry snapping to an integer week.
  double _weekOf(WeightEntry e) {
    final raw = DateTime.tryParse(e.timeIso) ?? DateTime.tryParse(e.dateIso);
    if (raw == null) return controller.currentWeek.toDouble();
    final today = DateTime.now();
    final daysAgo =
        DateTime(today.year, today.month, today.day).difference(
            DateTime(raw.year, raw.month, raw.day)).inDays;
    final pday = (controller.currentDay - daysAgo).clamp(1, 280);
    return (pday / 7.0).clamp(4.0, 40.0);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final store = ToolsStore.instance;
    final pre = store.prePregnancyWeight ?? 0;
    final gain = store.recommendedGain;
    final points = [
      for (final e in store.weightEntries)
        (week: _weekOf(e), weight: e.weight),
    ]..sort((a, b) => a.week.compareTo(b.week));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 180,
        width: double.infinity,
        child: CustomPaint(
          painter: _WeightChartPainter(
            points: points,
            preWeight: pre,
            gainMin: gain?.min ?? 11.5,
            gainMax: gain?.max ?? 16.0,
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        _legendDot(AppTheme.primary500),
        const SizedBox(width: 6),
        Text(s.chartActualWeight, style: text.labelSmall),
        const SizedBox(width: 16),
        _legendDot(AppTheme.primary100),
        const SizedBox(width: 6),
        Text(s.chartRecommendedRange, style: text.labelSmall),
      ]),
      const SizedBox(height: 10),
      Text(s.chartFooter, style: text.bodySmall),
    ]);
  }

  Widget _legendDot(Color c) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)));
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.points,
    required this.preWeight,
    required this.gainMin,
    required this.gainMax,
  });

  final List<({double week, double weight})> points;
  final double preWeight;
  final double gainMin;
  final double gainMax;

  static const double _wkStart = 4;
  static const double _wkEnd = 40;

  @override
  void paint(Canvas canvas, Size size) {
    // Y range covers the recommended band and any actual entries, with padding.
    var minW = preWeight;
    var maxW = preWeight + gainMax + 3;
    for (final p in points) {
      if (p.weight < minW) minW = p.weight - 1;
      if (p.weight > maxW) maxW = p.weight + 1;
    }
    final span = (maxW - minW) <= 0 ? 1 : (maxW - minW);

    double x(double week) =>
        (week - _wkStart) / (_wkEnd - _wkStart) * size.width;
    double y(double w) => size.height - ((w - minW) / span) * size.height;

    // Recommended range band.
    final band = Path()
      ..moveTo(x(_wkStart), y(preWeight))
      ..lineTo(x(_wkEnd), y(preWeight + gainMin))
      ..lineTo(x(_wkEnd), y(preWeight + gainMax))
      ..lineTo(x(_wkStart), y(preWeight))
      ..close();
    canvas.drawPath(
        band, Paint()..color = AppTheme.primary100.withValues(alpha: 0.6));

    // Actual line + dots.
    if (points.isNotEmpty) {
      final line = Paint()
        ..color = AppTheme.primary500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path();
      for (int i = 0; i < points.length; i++) {
        final p = Offset(x(points[i].week), y(points[i].weight));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, line);
      final dot = Paint()..color = AppTheme.primary500;
      for (final p in points) {
        canvas.drawCircle(Offset(x(p.week), y(p.weight)), 4, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter old) =>
      old.points != points ||
      old.preWeight != preWeight ||
      old.gainMin != gainMin ||
      old.gainMax != gainMax;
}

// =============================================================================
//  Weight Tracker
// -----------------------------------------------------------------------------
//  Two experiences: a one-time onboarding (pre-pregnancy weight + height →
//  personalized gain range) and an ongoing dashboard that reframes weight as
//  "my body is supporting my baby" — never a scorecard. Per the product spec:
//  the gain number is shown calmly, never celebrated or judged, and the chart
//  never shows above/below-target or warning colours.
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
      appBar: AppBar(title: Text(s.weightToolTitle)),
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
//  Onboarding
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
  double? _height;

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

    if (_step == 1 && _weight != null && _height != null) {
      final gain = _gainFor(_weight!, _height!);
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: [
          const Center(child: Text('❤️', style: TextStyle(fontSize: 56))),
          const SizedBox(height: 12),
          Center(child: Text(s.profileTitleWeight, style: text.headlineMedium)),
          const SizedBox(height: 24),
          _summaryCard(s.startingWeightLabel,
              '${_weight!.toStringAsFixed(1)} ${s.kgUnit}', text),
          _summaryCard(s.heightLabel,
              '${_height!.toStringAsFixed(0)} ${s.cmUnit}', text),
          _summaryCard(
            s.recommendedGainLabel,
            '${gain.min.toStringAsFixed(1)} – ${gain.max.toStringAsFixed(1)} ${s.kgUnit}',
            text,
            note: s.weightGuidelineNote,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await _store(context).setWeightProfile(_weight!, _height!);
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
        Text(s.heightLabel, style: text.titleMedium),
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
            final h = double.tryParse(_heightCtrl.text.trim());
            if (w == null || h == null || h <= 0) return;
            setState(() {
              _weight = w;
              _height = h;
              _step = 1;
            });
          },
          child: Text(s.continueCta),
        ),
      ],
    );
  }

  ToolsStore _store(BuildContext _) => ToolsStore.instance;

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
        if (store.weightEntries.isNotEmpty)
          _card(context, title: s.weightChartTitle, child: _ChartView(
            controller: controller,
          )),
        if (store.weightEntries.isNotEmpty) const SizedBox(height: 14),
        // History.
        if (store.weightEntries.isNotEmpty)
          _card(context, title: s.weightHistoryTitle, child: Column(
            children: [
              for (final e in store.weightEntries)
                _historyRow(context, e, pre, s, text),
            ],
          )),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => _addWeight(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(s.addTodaysWeight),
        ),
      ],
    );
  }

  String _lastUpdated(S s, WeightEntry e) {
    final d = DateTime.tryParse(e.dateIso);
    if (d == null) return e.dateIso;
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return s.todayWord;
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

  Widget _historyRow(
      BuildContext context, WeightEntry e, double pre, S s, TextTheme text) {
    final d = DateTime.tryParse(e.dateIso);
    final change = e.weight - pre;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(
          child: Text(d != null ? s.formatShortDate(d) : e.dateIso,
              style: text.bodyMedium),
        ),
        Expanded(
          child: Text('${s.weekWord} ${e.week}', style: text.bodyMedium),
        ),
        Expanded(
          child: Text('${e.weight.toStringAsFixed(1)} ${s.kgUnit}',
              style: text.bodyLarge),
        ),
        Text('${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
            style: text.labelMedium?.copyWith(color: AppTheme.neutral500)),
      ]),
    );
  }

  Future<void> _addWeight(BuildContext context) async {
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
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    ToolsStore.instance.addWeightEntry(WeightEntry(
                      dateIso:
                          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
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
}

// ---------------------------------------------------------------------------
//  Simple weight chart: actual line over a soft recommended-range band.
// ---------------------------------------------------------------------------

class _ChartView extends StatelessWidget {
  const _ChartView({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final store = ToolsStore.instance;
    final pre = store.prePregnancyWeight ?? 0;
    final gain = store.recommendedGain;
    final entries = [...store.weightEntries]
      ..sort((a, b) => a.week.compareTo(b.week));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 180,
        width: double.infinity,
        child: CustomPaint(
          painter: _WeightChartPainter(
            entries: entries,
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
    required this.entries,
    required this.preWeight,
    required this.gainMin,
    required this.gainMax,
  });

  final List<WeightEntry> entries;
  final double preWeight;
  final double gainMin;
  final double gainMax;

  static const int _wkStart = 4;
  static const int _wkEnd = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final minW = preWeight;
    final maxW = preWeight + gainMax + 3;
    double x(int week) =>
        (week - _wkStart) / (_wkEnd - _wkStart) * size.width;
    double y(double w) =>
        size.height - ((w - minW) / (maxW - minW)) * size.height;

    // Recommended range band.
    final band = Path()
      ..moveTo(x(_wkStart), y(preWeight))
      ..lineTo(x(_wkEnd), y(preWeight + gainMin))
      ..lineTo(x(_wkEnd), y(preWeight + gainMax))
      ..lineTo(x(_wkStart), y(preWeight))
      ..close();
    canvas.drawPath(
        band, Paint()..color = AppTheme.primary100.withValues(alpha: 0.6));

    // Actual line.
    if (entries.isNotEmpty) {
      final line = Paint()
        ..color = AppTheme.primary500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path();
      for (int i = 0; i < entries.length; i++) {
        final p = Offset(x(entries[i].week), y(entries[i].weight));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, line);
      final dot = Paint()..color = AppTheme.primary500;
      for (final e in entries) {
        canvas.drawCircle(Offset(x(e.week), y(e.weight)), 4, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter old) =>
      old.entries != entries ||
      old.preWeight != preWeight ||
      old.gainMin != gainMin ||
      old.gainMax != gainMax;
}

// =============================================================================
//  Contraction Tracker
// -----------------------------------------------------------------------------
//  A calm, non-alarmist decision-support tool: effortless tap-to-time, automatic
//  pattern insights (never a diagnosis), and a doctor-ready summary. No emergency
//  language, predictions, risk scores or red warning screens. Per the spec.
// =============================================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/app_theme.dart';

const Color _activeColor = Color(0xFFE8833A); // orange - active contraction
const Color _restColor = Color(0xFF3B82C4); // blue - rest interval

enum _Phase { home, active, rest }

class ContractionTrackerScreen extends StatefulWidget {
  const ContractionTrackerScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<ContractionTrackerScreen> createState() =>
      _ContractionTrackerScreenState();
}

class _ContractionTrackerScreenState extends State<ContractionTrackerScreen> {
  _Phase _phase = _Phase.home;
  final List<Contraction> _current = [];
  Timer? _tick;
  String? _sessionId;
  DateTime? _activeStart;
  DateTime? _lastStart;
  DateTime? _lastEnd;
  int _pendingInterval = 0;

  /// The mother's answer to the gentle labour prompt this session ('yes'/'no').
  String? _laborResponse;
  bool _askedLabor = false;

  /// Layer-2 medical symptoms (defaults = all clear).
  ContractionSymptoms _symptoms = const ContractionSymptoms();

  @override
  void initState() {
    super.initState();
    ToolsStore.instance.init();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  S get _s => S(widget.controller.language);

  void _ensureTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _startContraction() {
    final now = DateTime.now();
    _sessionId ??= now.microsecondsSinceEpoch.toString();
    _pendingInterval =
        _lastStart == null ? 0 : now.difference(_lastStart!).inSeconds;
    _activeStart = now;
    HapticFeedback.lightImpact();
    setState(() => _phase = _Phase.active);
    _ensureTick();
  }

  void _endContraction() {
    final now = DateTime.now();
    final start = _activeStart!;
    _current.add(Contraction(
      startIso: start.toIso8601String(),
      endIso: now.toIso8601String(),
      durationSeconds: now.difference(start).inSeconds,
      intervalSeconds: _pendingInterval,
    ));
    _lastStart = start;
    _lastEnd = now;
    HapticFeedback.lightImpact();
    setState(() => _phase = _Phase.rest);
    _ensureTick();
    _save();
    _maybePromptLabor();
  }

  Future<void> _save() async {
    if (_current.isEmpty || _sessionId == null) return;
    final first = DateTime.tryParse(_current.first.startIso) ?? DateTime.now();
    await ToolsStore.instance.saveContractionSession(ContractionSession(
      id: _sessionId!,
      dateIso: first.toIso8601String(),
      contractions: List.of(_current),
      laborResponse: _laborResponse,
    ));
  }

  /// Once per session, if the pattern looks like active labour, gently ask the
  /// mother how she feels and remember her answer.
  void _maybePromptLabor() {
    if (_askedLabor) return;
    // Don't stack the gentle "feels like labour?" ask on top of an emergency.
    if (_symptoms.isEmergency) return;
    if (classifyContractions(_current) != LaborState.activeLabor) return;
    _askedLabor = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showLaborPrompt();
    });
  }

  Future<void> _showLaborPrompt() async {
    final s = _s;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final text = Theme.of(ctx).textTheme;
        return AlertDialog(
          title: Text(s.laborPromptTitle),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.laborPromptBody, style: text.bodyMedium),
                const SizedBox(height: 12),
                Text(s.consultProvider,
                    style: text.bodySmall?.copyWith(color: AppTheme.neutral600)),
              ]),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _setLabor('no');
                },
                child: Text(s.laborNo)),
            FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _setLabor('yes');
                },
                child: Text(s.laborYes)),
          ],
        );
      },
    );
  }

  void _setLabor(String response) {
    setState(() => _laborResponse = response);
    _save();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_s.laborSavedNote)));
    }
  }

  Future<void> _endSession() async {
    await _save();
    _tick?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  // ---- stats ----------------------------------------------------------------

  double get _avgDuration {
    if (_current.isEmpty) return 0;
    final sum = _current.fold<int>(0, (a, c) => a + c.durationSeconds);
    return sum / _current.length;
  }

  double get _avgIntervalSec {
    final intervals =
        _current.where((c) => c.intervalSeconds > 0).map((c) => c.intervalSeconds);
    if (intervals.isEmpty) return 0;
    return intervals.reduce((a, b) => a + b) / intervals.length;
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) => _save(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.contractionToolTitle),
          actions: [
            IconButton(
              tooltip: s.safetyCheckTitle,
              icon: Icon(
                Icons.health_and_safety_rounded,
                color: _symptoms.isEmergency ? const Color(0xFFC62828) : null,
              ),
              onPressed: _showSafetySheet,
            ),
            IconButton(
              tooltip: s.historyLabel,
              icon: const Icon(Icons.history_rounded),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    _ContractionHistoryScreen(controller: widget.controller),
              )),
            ),
          ],
        ),
        body: SafeArea(
          child: switch (_phase) {
            _Phase.home => _homeView(context),
            _Phase.active => _activeView(context),
            _Phase.rest => _restView(context),
          },
        ),
      ),
    );
  }

  // ---- Home -----------------------------------------------------------------

  Widget _homeView(BuildContext context) {
    final s = _s;
    final text = Theme.of(context).textTheme;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          children: [
            if (_symptoms.isEmergency) ...[
              _assessBanner(s),
              const SizedBox(height: 16),
            ],
            // What contractions are + true vs false (Braxton Hicks) + how to time.
            _aboutCard(s, text),
            const SizedBox(height: 14),
            // Clear "we're a timer, not a medical app" disclaimer.
            _disclaimerCard(s, text),
            const SizedBox(height: 16),
            _safetyCard(s),
            const SizedBox(height: 30),
            const Center(child: Text('🤍', style: TextStyle(fontSize: 56))),
            const SizedBox(height: 16),
            Text(s.contractionEmpty,
                textAlign: TextAlign.center, style: text.bodyLarge),
          ],
        ),
      ),
      _bottomButton(context, s.contractionStartedCta, _activeColor,
          _startContraction),
    ]);
  }

  // ---- Active ---------------------------------------------------------------

  Widget _activeView(BuildContext context) {
    final s = _s;
    final text = Theme.of(context).textTheme;
    final elapsed =
        _activeStart == null ? 0 : DateTime.now().difference(_activeStart!).inSeconds;
    return Column(children: [
      Expanded(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(s.currentContraction, style: text.titleMedium),
            const SizedBox(height: 4),
            Text(s.contractionNumber(_current.length + 1),
                style: text.labelMedium?.copyWith(color: AppTheme.neutral500)),
            const SizedBox(height: 22),
            _timerCircle(s.formatStopwatch(elapsed), _activeColor),
            const SizedBox(height: 24),
            Text(s.tapWhenEnds, style: text.bodyMedium),
          ]),
        ),
      ),
      _bottomButton(context, s.contractionEndedCta, _activeColor, _endContraction),
    ]);
  }

  // ---- Rest -----------------------------------------------------------------

  Widget _restView(BuildContext context) {
    final s = _s;
    final text = Theme.of(context).textTheme;
    final rest =
        _lastEnd == null ? 0 : DateTime.now().difference(_lastEnd!).inSeconds;
    final last = _current.isNotEmpty ? _current.last : null;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          children: [
            _assessBanner(s),
            const SizedBox(height: 12),
            _safetyCard(s),
            const SizedBox(height: 18),
            Center(child: Text(s.timeSinceLast, style: text.titleMedium)),
            const SizedBox(height: 14),
            Center(child: _timerCircle(s.formatStopwatch(rest), _restColor)),
            const SizedBox(height: 20),
            Row(children: [
              if (last != null)
                Expanded(
                    child: _stat(text, s.lastContractionLabel,
                        s.minSecLabel(last.durationSeconds))),
              Expanded(
                  child: _stat(text, s.avgDurationLabel,
                      s.minSecLabel(_avgDuration.round()))),
              Expanded(
                  child: _stat(text, s.avgIntervalLabel,
                      s.minSecLabel(_avgIntervalSec.round()))),
            ]),
            const SizedBox(height: 22),
            // The session, building live in front of the mother.
            _sessionList(s, text),
            const SizedBox(height: 16),
            if (_current.length >= 3)
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _SummaryScreen(
                    controller: widget.controller,
                    contractions: List.of(_current),
                  ),
                )),
                icon: const Icon(Icons.insights_rounded, size: 18),
                label: Text(s.viewSummaryCta),
              ),
            const SizedBox(height: 10),
            TextButton(onPressed: _endSession, child: Text(s.endSessionCta)),
          ],
        ),
      ),
      _bottomButton(
          context, s.contractionStartedCta, _activeColor, _startContraction),
    ]);
  }

  ({Color color, IconData icon}) _levelStyle(AssessLevel l) {
    switch (l) {
      case AssessLevel.emergency:
        return (color: const Color(0xFFC62828), icon: Icons.warning_amber_rounded);
      case AssessLevel.preterm:
        return (color: const Color(0xFFD9822B), icon: Icons.priority_high_rounded);
      case AssessLevel.activeLabor:
        return (color: _activeColor, icon: Icons.favorite_rounded);
      case AssessLevel.laborLikely:
        return (color: const Color(0xFFE6A817), icon: Icons.trending_up_rounded);
      case AssessLevel.earlyLabor:
        return (color: _restColor, icon: Icons.water_drop_rounded);
      case AssessLevel.noPattern:
        return (color: _restColor, icon: Icons.timelapse_rounded);
      case AssessLevel.insufficient:
        return (color: AppTheme.neutral500, icon: Icons.timelapse_rounded);
    }
  }

  /// The final assessment banner (Layer 2 override applied over Layer 1).
  Widget _assessBanner(S s) {
    final text = Theme.of(context).textTheme;
    final level = assessContractions(
        _current, widget.controller.currentWeek, _symptoms);
    final style = _levelStyle(level);
    final key = _levelKey(level);
    final urgent =
        level == AssessLevel.emergency || level == AssessLevel.preterm;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: urgent ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: style.color.withValues(alpha: urgent ? 0.6 : 0.3),
            width: urgent ? 1.4 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(style.icon, color: style.color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(s.assessTitle(key),
                style: text.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800, color: style.color)),
          ),
          if (_laborResponse != null) _laborChip(s, text, _laborResponse == 'yes'),
        ]),
        const SizedBox(height: 6),
        Text(s.assessSummary(key),
            style: text.bodyMedium?.copyWith(color: AppTheme.neutral800)),
        // ALWAYS point to the doctor - even on a calm "no pattern" reading, since
        // timing can't rule labour in or out. (Emergency/preterm already carry
        // their own urgent contact message, so skip the softer line there.)
        if (!urgent) ...[
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.local_hospital_outlined,
                size: 15, color: AppTheme.neutral500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(s.ctAlwaysConsult,
                  style: text.bodySmall?.copyWith(color: AppTheme.neutral600)),
            ),
          ]),
        ],
      ]),
    );
  }

  /// "Understanding contractions" - what they are, true vs false (Braxton
  /// Hicks), and how to time one. Helps a first-time user know what this is.
  Widget _aboutCard(S s, TextTheme text) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: _restColor),
            const SizedBox(width: 8),
            Text(s.ctAboutTitle,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(s.ctAboutBody,
              style: text.bodyMedium?.copyWith(height: 1.5)),
        ]),
      );

  /// The "this is a timer, not a diagnosis / not a medical app" disclaimer -
  /// kept clearly visible so the tool never reads as medical advice.
  Widget _disclaimerCard(S s, TextTheme text) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33D9822B)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.health_and_safety_outlined,
              size: 20, color: Color(0xFFB36B12)),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.ctDisclaimerTitle,
                  style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB36B12))),
              const SizedBox(height: 4),
              Text(s.ctDisclaimerBody,
                  style: text.bodySmall
                      ?.copyWith(color: AppTheme.neutral700, height: 1.45)),
            ]),
          ),
        ]),
      );

  /// The Layer-2 symptom "safety check" entry - shows current state + Update.
  Widget _safetyCard(S s) {
    final text = Theme.of(context).textTheme;
    final reported = _symptoms.anyReported;
    final emergency = _symptoms.isEmergency;
    final color = emergency
        ? const Color(0xFFC62828)
        : (reported ? const Color(0xFFD9822B) : AppTheme.tertiary500);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Icon(Icons.health_and_safety_rounded, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.safetyCheckTitle,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(reported ? s.safetyReported : s.safetyAllClear,
                style: text.bodySmall?.copyWith(color: AppTheme.neutral600)),
          ]),
        ),
        TextButton(onPressed: _showSafetySheet, child: Text(s.safetyUpdate)),
      ]),
    );
  }

  Future<void> _showSafetySheet() async {
    final s = _s;
    var sym = _symptoms;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppTheme.surface,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final text = Theme.of(ctx).textTheme;
          Widget q(String title, List<(String, String)> opts, String current,
              void Function(String) onPick) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final (label, value) in opts)
                      ChoiceChip(
                        label: Text(label),
                        selected: current == value,
                        onSelected: (_) => setSheet(() => onPick(value)),
                      ),
                  ]),
                  const SizedBox(height: 18),
                ]);
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 4, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.safetyCheckTitle, style: text.headlineSmall),
                    const SizedBox(height: 6),
                    Text(s.safetyCheckSub,
                        style:
                            text.bodySmall?.copyWith(color: AppTheme.neutral600)),
                    const SizedBox(height: 18),
                    q(s.qWaterBroken, [
                      (s.optNo, 'no'),
                      (s.optYes, 'yes'),
                      (s.optNotSure, 'unsure'),
                    ], sym.waterBroken, (v) => sym = sym.copyWith(waterBroken: v)),
                    q(s.qBleeding, [
                      (s.bleedNone, 'none'),
                      (s.bleedLight, 'light'),
                      (s.bleedHeavy, 'heavy'),
                    ], sym.bleeding, (v) => sym = sym.copyWith(bleeding: v)),
                    q(s.qMovementReduced, [
                      (s.optNo, 'no'),
                      (s.optYes, 'yes'),
                      (s.optNotSure, 'unsure'),
                    ], sym.movementReduced,
                        (v) => sym = sym.copyWith(movementReduced: v)),
                    q(s.qSeverePain, [
                      (s.optNo, 'no'),
                      (s.optYes, 'yes'),
                    ], sym.severePain, (v) => sym = sym.copyWith(severePain: v)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() => _symptoms = sym);
                          Navigator.of(ctx).pop();
                        },
                        child: Text(s.doneWord),
                      ),
                    ),
                  ]),
            ),
          );
        });
      },
    );
  }

  Widget _laborChip(S s, TextTheme text, bool yes) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: (yes ? _activeColor : _restColor).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(s.feltInLabour(yes),
            style: text.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: yes ? _activeColor : _restColor)),
      );

  /// The contractions logged so far this session, newest first - so the record
  /// grows in front of the mother without opening the summary or history.
  Widget _sessionList(S s, TextTheme text) {
    if (_current.isEmpty) return const SizedBox.shrink();
    final items = _current.reversed.toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(s.thisSessionContractions,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const Spacer(),
          Text('${_current.length}',
              style: text.titleSmall?.copyWith(
                  color: _activeColor, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 28),
          Expanded(child: Text(s.timeColumn, style: text.labelSmall)),
          Expanded(child: Text(s.durationColumn, style: text.labelSmall)),
          Expanded(child: Text(s.intervalColumn, style: text.labelSmall)),
        ]),
        const Divider(height: 14),
        for (int i = 0; i < items.length; i++)
          _sessionRow(s, text, items[i], _current.length - i),
      ]),
    );
  }

  Widget _sessionRow(S s, TextTheme text, Contraction c, int number) {
    final start = DateTime.tryParse(c.startIso) ?? DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        SizedBox(
            width: 28,
            child: Text('$number',
                style: text.labelMedium?.copyWith(
                    color: AppTheme.neutral500, fontWeight: FontWeight.w700))),
        Expanded(child: Text(s.formatClock(start), style: text.bodyMedium)),
        Expanded(
            child: Text(s.minSecLabel(c.durationSeconds), style: text.bodyMedium)),
        Expanded(
            child: Text(
                c.intervalSeconds == 0 ? '-' : s.minSecLabel(c.intervalSeconds),
                style: text.bodyMedium)),
      ]),
    );
  }

  // ---- shared bits ----------------------------------------------------------

  Widget _timerCircle(String label, Color color) {
    return Container(
      width: 230,
      height: 230,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 52, fontWeight: FontWeight.w800, color: color)),
    );
  }

  Widget _stat(TextTheme text, String label, String value) => Column(children: [
        Text(value,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: text.labelSmall),
      ]);

  Widget _bottomButton(
      BuildContext context, String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: color),
          onPressed: onTap,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Pattern insight (shared)
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
//  Two-layer assessment engine (NOT a diagnosis - see the product spec)
//   Layer 1 - classify the pattern from the contraction data alone.
//   Layer 2 - a medical-symptom override that takes priority over Layer 1.
// ---------------------------------------------------------------------------

enum LaborState { insufficient, noPattern, earlyLabor, laborLikely, activeLabor }

enum AssessLevel {
  insufficient,
  noPattern,
  earlyLabor,
  laborLikely,
  activeLabor,
  preterm,
  emergency,
}

/// The mother's reported symptoms (Layer 2 inputs). Defaults are the "all-clear"
/// values; gestational age comes from her profile, not here.
class ContractionSymptoms {
  const ContractionSymptoms({
    this.waterBroken = 'no', // no | yes | unsure
    this.bleeding = 'none', // none | light | heavy
    this.movementReduced = 'no', // no | yes | unsure
    this.severePain = 'no', // no | yes
  });
  final String waterBroken;
  final String bleeding;
  final String movementReduced;
  final String severePain;

  bool get isEmergency =>
      waterBroken == 'yes' ||
      bleeding == 'heavy' ||
      movementReduced == 'yes' ||
      severePain == 'yes';

  bool get anyReported =>
      waterBroken != 'no' ||
      bleeding != 'none' ||
      movementReduced != 'no' ||
      severePain != 'no';

  ContractionSymptoms copyWith({
    String? waterBroken,
    String? bleeding,
    String? movementReduced,
    String? severePain,
  }) =>
      ContractionSymptoms(
        waterBroken: waterBroken ?? this.waterBroken,
        bleeding: bleeding ?? this.bleeding,
        movementReduced: movementReduced ?? this.movementReduced,
        severePain: severePain ?? this.severePain,
      );
}

double _mean(Iterable<num> xs) {
  if (xs.isEmpty) return 0;
  // Sum with a loop (not reduce) - reduce on a List<int> would reject the
  // widened num closure at runtime ("(num,num)=>num is not (int,int)=>int").
  num sum = 0;
  for (final x in xs) {
    sum += x;
  }
  return sum / xs.length;
}

/// Interval regularity 0..1 (1 = perfectly even), from the coefficient of
/// variation. Needs at least two intervals.
double _regularity(List<int> intervals) {
  if (intervals.length < 2) return 0;
  final m = _mean(intervals);
  if (m <= 0) return 0;
  final variance = _mean(intervals.map((i) => (i - m) * (i - m)));
  final cv = variance <= 0 ? 0.0 : math.sqrt(variance) / m;
  return (1 - cv).clamp(0.0, 1.0);
}

bool _intervalsDecreasing(List<int> intervals) {
  if (intervals.length < 4) return false;
  final half = intervals.length ~/ 2;
  return _mean(intervals.sublist(half)) < _mean(intervals.sublist(0, half)) * 0.95;
}

bool _durationsIncreasing(List<int> durations) {
  if (durations.length < 4) return false;
  final half = durations.length ~/ 2;
  return _mean(durations.sublist(half)) > _mean(durations.sublist(0, half)) * 1.05;
}

int _trackingSeconds(List<Contraction> cs) {
  if (cs.isEmpty) return 0;
  final start = DateTime.tryParse(cs.first.startIso);
  final end = DateTime.tryParse(cs.last.endIso);
  if (start == null || end == null) return 0;
  return end.difference(start).inSeconds;
}

/// Layer 1 - classify the pattern from the contractions alone.
LaborState classifyContractions(List<Contraction> cs) {
  final n = cs.length;
  if (n < 3) return LaborState.insufficient;

  final durs = cs.map((c) => c.durationSeconds).toList();
  final avgDur = _mean(durs);
  final ints =
      cs.where((c) => c.intervalSeconds > 0).map((c) => c.intervalSeconds).toList();
  final avgIntSec = ints.isEmpty ? double.infinity : _mean(ints);
  final avgIntMin = avgIntSec / 60;
  final reg = _regularity(ints);
  final tracking = _trackingSeconds(cs);

  // State 4 - Active labour likely.
  if (avgIntSec <= 300 &&
      avgDur >= 60 &&
      reg >= 0.80 &&
      (tracking >= 3600 || n >= 8)) {
    return LaborState.activeLabor;
  }
  // State 3 - Labour pattern likely.
  if (n >= 5 && avgDur > 30 && avgIntSec <= 600 && reg >= 0.70) {
    return LaborState.laborLikely;
  }
  // State 2 - Possible early labour.
  if (n >= 5 &&
      avgDur >= 20 &&
      avgDur <= 45 &&
      avgIntMin >= 5 &&
      avgIntMin <= 20 &&
      reg >= 0.5 &&
      (_intervalsDecreasing(ints) || _durationsIncreasing(durs))) {
    return LaborState.earlyLabor;
  }
  // State 1 - No clear labour pattern (fallback for 3+ contractions).
  return LaborState.noPattern;
}

/// Layer 2 over Layer 1, applying the override priority order.
AssessLevel assessContractions(
    List<Contraction> cs, int gestationWeeks, ContractionSymptoms sym) {
  if (sym.isEmergency) return AssessLevel.emergency;
  final state = classifyContractions(cs);
  final laborish = state == LaborState.earlyLabor ||
      state == LaborState.laborLikely ||
      state == LaborState.activeLabor;
  if (gestationWeeks < 37 && laborish) return AssessLevel.preterm;
  return switch (state) {
    LaborState.activeLabor => AssessLevel.activeLabor,
    LaborState.laborLikely => AssessLevel.laborLikely,
    LaborState.earlyLabor => AssessLevel.earlyLabor,
    LaborState.noPattern => AssessLevel.noPattern,
    LaborState.insufficient => AssessLevel.insufficient,
  };
}

String _levelKey(AssessLevel l) => switch (l) {
      AssessLevel.emergency => 'emergency',
      AssessLevel.preterm => 'preterm',
      AssessLevel.activeLabor => 'active',
      AssessLevel.laborLikely => 'likely',
      AssessLevel.earlyLabor => 'early',
      AssessLevel.noPattern => 'noPattern',
      AssessLevel.insufficient => 'insufficient',
    };

/// The pattern summary line (Layer 1 only) for the static summary screen.
String contractionPattern(S s, List<Contraction> cs) {
  final state = classifyContractions(cs);
  final level = switch (state) {
    LaborState.activeLabor => AssessLevel.activeLabor,
    LaborState.laborLikely => AssessLevel.laborLikely,
    LaborState.earlyLabor => AssessLevel.earlyLabor,
    LaborState.noPattern => AssessLevel.noPattern,
    LaborState.insufficient => AssessLevel.insufficient,
  };
  return s.assessSummary(_levelKey(level));
}

// ---------------------------------------------------------------------------
//  Session summary
// ---------------------------------------------------------------------------

class _SummaryScreen extends StatelessWidget {
  const _SummaryScreen({required this.controller, required this.contractions});
  final PregnancyController controller;
  final List<Contraction> contractions;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final cs = contractions;
    final durations = cs.map((c) => c.durationSeconds).toList();
    final intervals =
        cs.where((c) => c.intervalSeconds > 0).map((c) => c.intervalSeconds).toList();
    final avgDur = durations.isEmpty
        ? 0
        : (durations.reduce((a, b) => a + b) / durations.length).round();
    final avgIntSec = intervals.isEmpty
        ? 0
        : (intervals.reduce((a, b) => a + b) / intervals.length).round();
    final longest = durations.isEmpty ? 0 : durations.reduce((a, b) => a > b ? a : b);
    final shortestIntSec =
        intervals.isEmpty ? 0 : intervals.reduce((a, b) => a < b ? a : b);

    String summaryText() => '${s.lastHourLabel}:\n'
        '${cs.length} ${s.contractionsLoggedLabel.toLowerCase()}.\n'
        '${s.avgDurationLabel}: ${s.minSecLabel(avgDur)}.\n'
        '${s.avgIntervalLabel}: ${s.minSecLabel(avgIntSec)}.\n'
        '${s.longestDurationLabel}: ${s.minSecLabel(longest)}.\n'
        '${s.shortestIntervalLabel}: ${s.minSecLabel(shortestIntSec)}.\n'
        '${contractionPattern(s, cs)}\n'
        '${s.consultProvider}';

    return Scaffold(
      appBar: AppBar(title: Text(s.sessionSummaryTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(s.currentPatternLabel, style: text.headlineSmall),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.7,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _metric(text, s.contractionsLoggedLabel, '${cs.length}'),
              _metric(text, s.avgDurationLabel, s.minSecLabel(avgDur)),
              _metric(text, s.avgIntervalLabel, s.minSecLabel(avgIntSec)),
              _metric(text, s.longestDurationLabel, s.minSecLabel(longest)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(contractionPattern(s, cs), style: text.bodyLarge),
              const SizedBox(height: 8),
              Text(s.consultProvider, style: text.bodySmall),
            ]),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: summaryText()));
              messenger.showSnackBar(SnackBar(content: Text(s.summaryCopied)));
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(s.copySummaryCta),
          ),
        ],
      ),
    );
  }

  Widget _metric(TextTheme text, String label, String value) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style:
                      text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label, style: text.labelSmall),
            ]),
      );
}

// ---------------------------------------------------------------------------
//  History + session detail
// ---------------------------------------------------------------------------

class _ContractionHistoryScreen extends StatelessWidget {
  const _ContractionHistoryScreen({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.historyLabel)),
      body: AnimatedBuilder(
        animation: ToolsStore.instance,
        builder: (context, _) {
          final sessions = ToolsStore.instance.contractionSessions;
          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Text(s.noContractionSessions,
                    textAlign: TextAlign.center, style: text.bodyMedium),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              for (final session in sessions)
                _sessionCard(context, session, s, text),
            ],
          );
        },
      ),
    );
  }

  Widget _sessionCard(
      BuildContext context, ContractionSession session, S s, TextTheme text) {
    final date = DateTime.tryParse(session.dateIso);
    final cs = session.contractions;
    final durations = cs.map((c) => c.durationSeconds).toList();
    final intervals =
        cs.where((c) => c.intervalSeconds > 0).map((c) => c.intervalSeconds).toList();
    final avgDur = durations.isEmpty
        ? 0
        : (durations.reduce((a, b) => a + b) / durations.length).round();
    final avgIntSec = intervals.isEmpty
        ? 0
        : (intervals.reduce((a, b) => a + b) / intervals.length).round();
    final labor = session.laborResponse;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              _SessionDetailScreen(controller: controller, session: session),
        )),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(date != null ? s.formatLongDate(date) : session.dateIso,
                    style: text.titleMedium),
              ),
              if (labor != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (labor == 'yes' ? _activeColor : _restColor)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(s.feltInLabour(labor == 'yes'),
                      style: text.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: labor == 'yes' ? _activeColor : _restColor)),
                ),
            ]),
            const SizedBox(height: 6),
            Text(
                '${cs.length} ${s.contractionsLoggedLabel.toLowerCase()} · '
                '${s.avgDurationLabel} ${s.minSecLabel(avgDur)} · '
                '${s.avgIntervalLabel} ${s.minSecLabel(avgIntSec)}',
                style: text.bodyMedium),
          ]),
        ),
      ),
    ),
    );
  }
}

class _SessionDetailScreen extends StatelessWidget {
  const _SessionDetailScreen({required this.controller, required this.session});
  final PregnancyController controller;
  final ContractionSession session;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.sessionSummaryTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          if (session.laborResponse != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (session.laborResponse == 'yes' ? _activeColor : _restColor)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Icon(Icons.favorite_rounded,
                    size: 18,
                    color: session.laborResponse == 'yes'
                        ? _activeColor
                        : _restColor),
                const SizedBox(width: 8),
                Text(s.feltInLabour(session.laborResponse == 'yes'),
                    style: text.titleSmall),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          Row(children: [
            Expanded(child: Text(s.timeColumn, style: text.labelMedium)),
            Expanded(child: Text(s.durationColumn, style: text.labelMedium)),
            Expanded(child: Text(s.intervalColumn, style: text.labelMedium)),
          ]),
          const Divider(),
          for (final c in session.contractions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Expanded(
                    child: Text(
                        s.formatClock(
                            DateTime.tryParse(c.startIso) ?? DateTime.now()),
                        style: text.bodyMedium)),
                Expanded(
                    child: Text(s.minSecLabel(c.durationSeconds),
                        style: text.bodyMedium)),
                Expanded(
                    child: Text(
                        c.intervalSeconds == 0
                            ? '-'
                            : s.minSecLabel(c.intervalSeconds),
                        style: text.bodyMedium)),
              ]),
            ),
        ],
      ),
    );
  }
}

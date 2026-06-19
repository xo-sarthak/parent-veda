// =============================================================================
//  Contraction Tracker
// -----------------------------------------------------------------------------
//  A calm, non-alarmist decision-support tool: effortless tap-to-time, automatic
//  pattern insights (never a diagnosis), and a doctor-ready summary. No emergency
//  language, predictions, risk scores or red warning screens. Per the spec.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/app_theme.dart';

const Color _activeColor = Color(0xFFE8833A); // orange — active contraction
const Color _restColor = Color(0xFF3B82C4); // blue — rest interval

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
  }

  Future<void> _save() async {
    if (_current.isEmpty || _sessionId == null) return;
    final first = DateTime.tryParse(_current.first.startIso) ?? DateTime.now();
    await ToolsStore.instance.saveContractionSession(ContractionSession(
      id: _sessionId!,
      dateIso: first.toIso8601String(),
      contractions: List.of(_current),
    ));
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(s.contractionIntro, style: text.bodyMedium),
            ),
            const SizedBox(height: 40),
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
            const SizedBox(height: 24),
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
            Center(child: Text(s.timeSinceLast, style: text.titleMedium)),
            const SizedBox(height: 20),
            Center(child: _timerCircle(s.formatStopwatch(rest), _restColor)),
            const SizedBox(height: 24),
            Row(children: [
              if (last != null)
                Expanded(
                    child: _stat(text, s.lastContractionLabel,
                        s.secLabel(last.durationSeconds))),
              Expanded(
                  child: _stat(text, s.avgDurationLabel,
                      s.secLabel(_avgDuration.round()))),
              Expanded(
                  child: _stat(text, s.avgIntervalLabel,
                      s.minLabel((_avgIntervalSec / 60).round()))),
            ]),
            const SizedBox(height: 20),
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

String contractionPattern(S s, List<Contraction> cs) {
  if (cs.isEmpty) return '';
  final durations = cs.map((c) => c.durationSeconds);
  final avgDur = durations.reduce((a, b) => a + b) / cs.length;
  final intervals = cs.where((c) => c.intervalSeconds > 0).map((c) => c.intervalSeconds);
  if (intervals.isEmpty) return s.patternIrregular;
  final avgIntMin = (intervals.reduce((a, b) => a + b) / intervals.length) / 60;
  if (avgIntMin >= 15) return s.patternIrregular;
  if (avgIntMin >= 8) return s.patternBuilding;
  if (avgIntMin <= 7 && avgDur > 45) return s.patternRegular;
  return s.patternBuilding;
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
    final avgInt = intervals.isEmpty
        ? 0
        : ((intervals.reduce((a, b) => a + b) / intervals.length) / 60).round();
    final longest = durations.isEmpty ? 0 : durations.reduce((a, b) => a > b ? a : b);
    final shortestInt = intervals.isEmpty
        ? 0
        : (intervals.reduce((a, b) => a < b ? a : b) / 60).round();

    String summaryText() => '${s.lastHourLabel}:\n'
        '${cs.length} ${s.contractionsLoggedLabel.toLowerCase()}.\n'
        '${s.avgDurationLabel}: ${s.secLabel(avgDur)}.\n'
        '${s.avgIntervalLabel}: ${s.minLabel(avgInt)}.\n'
        '${s.longestDurationLabel}: ${s.secLabel(longest)}.\n'
        '${s.shortestIntervalLabel}: ${s.minLabel(shortestInt)}.\n'
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
              _metric(text, s.avgDurationLabel, s.secLabel(avgDur)),
              _metric(text, s.avgIntervalLabel, s.minLabel(avgInt)),
              _metric(text, s.longestDurationLabel, s.secLabel(longest)),
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
    final avgInt = intervals.isEmpty
        ? 0
        : ((intervals.reduce((a, b) => a + b) / intervals.length) / 60).round();
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
            Text(date != null ? s.formatLongDate(date) : session.dateIso,
                style: text.titleMedium),
            const SizedBox(height: 6),
            Text(
                '${cs.length} ${s.contractionsLoggedLabel.toLowerCase()} · '
                '${s.avgDurationLabel} ${s.secLabel(avgDur)} · '
                '${s.avgIntervalLabel} ${s.minLabel(avgInt)}',
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
                    child: Text(s.secLabel(c.durationSeconds),
                        style: text.bodyMedium)),
                Expanded(
                    child: Text(
                        c.intervalSeconds == 0
                            ? '—'
                            : s.minLabel((c.intervalSeconds / 60).round()),
                        style: text.bodyMedium)),
              ]),
            ),
        ],
      ),
    );
  }
}

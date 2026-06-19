// =============================================================================
//  Kegel Care
// -----------------------------------------------------------------------------
//  Pregnancy self-care & birth preparation — NOT a workout or gamified app.
//  No levels, XP, streaks or achievements. A pregnancy-aware adaptive routine
//  (3 stages by week), a guided hold/relax session, and a calm "Care Journey".
//  Per the product spec.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/app_theme.dart';

/// A resolved routine for the current week + adaptive offsets.
({String Function(S) stage, int hold, int relax, int reps, int minutes})
    _routineFor(int week) {
  // Base routine by pregnancy stage.
  int baseHold;
  int baseReps;
  String Function(S) stage;
  if (week <= 16) {
    baseHold = 3;
    baseReps = 8;
    stage = (s) => s.kegelStage1;
  } else if (week <= 28) {
    baseHold = 5;
    baseReps = 10;
    stage = (s) => s.kegelStage2;
  } else {
    baseHold = 8;
    baseReps = 12;
    stage = (s) => s.kegelStage3;
  }
  final store = ToolsStore.instance;
  final hold = (baseHold + store.kegelHoldAdjust).clamp(3, 10);
  final reps = (baseReps + store.kegelRepAdjust).clamp(8, 15);
  final relax = hold;
  final minutes = (((hold + relax) * reps) / 60).ceil();
  return (stage: stage, hold: hold, relax: relax, reps: reps, minutes: minutes);
}

class KegelCareScreen extends StatefulWidget {
  const KegelCareScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<KegelCareScreen> createState() => _KegelCareScreenState();
}

class _KegelCareScreenState extends State<KegelCareScreen> {
  final _store = ToolsStore.instance;
  bool _whyExpanded = false;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  S get _s => S(widget.controller.language);

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.kegelToolTitle),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => _CareJourneyScreen(controller: widget.controller),
            )),
            icon: const Icon(Icons.favorite_rounded, size: 18),
            label: Text(s.careJourneyCta),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final r = _routineFor(widget.controller.currentWeek);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              // Hero
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.secondary50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.kegelHeroTitle, style: text.titleLarge),
                      const SizedBox(height: 8),
                      Text(s.kegelHeroBody, style: text.bodyMedium),
                      const SizedBox(height: 10),
                      _benefit(text, s.kegelBenefitBladder),
                      _benefit(text, s.kegelBenefitSupport),
                      _benefit(text, s.kegelBenefitRecovery),
                      const SizedBox(height: 8),
                      Text(s.kegelFollowProvider, style: text.bodySmall),
                    ]),
              ),
              const SizedBox(height: 14),
              // Current routine
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.currentRoutineLabel,
                          style: text.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(r.stage(s),
                          style: text.labelMedium
                              ?.copyWith(color: AppTheme.secondary600)),
                      const SizedBox(height: 12),
                      _routineRow(text, s.holdLabel, '${r.hold} ${s.secShort}'),
                      _routineRow(
                          text, s.relaxLabel, '${r.relax} ${s.secShort}'),
                      _routineRow(text, s.repsLabel, '${r.reps}'),
                      _routineRow(
                          text, s.estTimeLabel, s.minutesShort(r.minutes)),
                    ]),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.whyThisRoutine,
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(s.whyThisRoutineBody, style: text.bodyMedium),
                    ]),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _SessionScreen(
                    controller: widget.controller,
                    hold: r.hold,
                    relax: r.relax,
                    reps: r.reps,
                  ),
                )),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(s.startCareSession),
              ),
              const SizedBox(height: 18),
              // Why am I doing this (collapsible)
              _Expandable(
                title: s.whyAmIDoingThis,
                body: s.whyAmIDoingThisBody,
                expanded: _whyExpanded,
                onToggle: () => setState(() => _whyExpanded = !_whyExpanded),
              ),
              const SizedBox(height: 14),
              // Safety
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.fatherAmber.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.kegelSafetyTitle,
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _bullet(text, s.kegelSafetyPain),
                      _bullet(text, s.kegelSafetyBleeding),
                      _bullet(text, s.kegelSafetyDizziness),
                      _bullet(text, s.kegelSafetyContractions),
                    ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _benefit(TextTheme text, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          const Text('❤️ ', style: TextStyle(fontSize: 13)),
          Expanded(child: Text(label, style: text.bodyLarge)),
        ]),
      );

  Widget _bullet(TextTheme text, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('•  '),
          Expanded(child: Text(label, style: text.bodyMedium)),
        ]),
      );

  Widget _routineRow(TextTheme text, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: text.bodyMedium),
              Text(value,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ]),
      );
}

class _Expandable extends StatelessWidget {
  const _Expandable({
    required this.title,
    required this.body,
    required this.expanded,
    required this.onToggle,
  });
  final String title;
  final String body;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(children: [
        ListTile(
          title: Text(title,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          trailing: Icon(
              expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
          onTap: onToggle,
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(body, style: text.bodyMedium),
            ),
          ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Guided session (hold / relax countdown across reps)
// ---------------------------------------------------------------------------

class _SessionScreen extends StatefulWidget {
  const _SessionScreen({
    required this.controller,
    required this.hold,
    required this.relax,
    required this.reps,
  });
  final PregnancyController controller;
  final int hold;
  final int relax;
  final int reps;

  @override
  State<_SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<_SessionScreen> {
  Timer? _timer;
  bool _holding = true; // hold phase vs relax
  int _rep = 1;
  late int _remaining;
  bool _paused = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.hold;
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) _advance();
      });
    });
  }

  void _advance() {
    HapticFeedback.lightImpact();
    if (_holding) {
      _holding = false;
      _remaining = widget.relax;
    } else {
      // finished a full rep
      if (_rep >= widget.reps) {
        _finish();
        return;
      }
      _rep++;
      _holding = true;
      _remaining = widget.hold;
    }
  }

  void _finish() {
    _timer?.cancel();
    setState(() => _done = true);
  }

  Future<void> _saveFeedback(String feedback) async {
    await ToolsStore.instance.recordKegelSession(
      holdSeconds: widget.hold,
      relaxSeconds: widget.relax,
      repetitions: widget.reps,
      feedback: feedback,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    final color = _holding ? AppTheme.secondary500 : AppTheme.primary400;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.kegelToolTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _done
            ? _completion(context, s, text)
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.16),
                      border: Border.all(color: color, width: 4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_holding ? s.holdLabel : s.relaxLabel,
                            style: text.headlineMedium?.copyWith(color: color)),
                        const SizedBox(height: 6),
                        Text('$_remaining',
                            style: text.displayLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(s.repOf(_rep, widget.reps), style: text.titleMedium),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _paused = !_paused),
                        icon: Icon(_paused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded),
                        label: Text(_paused ? s.resumeLabel : s.pauseLabel),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        label: Text(s.exitLabel),
                      ),
                    ],
                  ),
                ]),
              ),
      ),
    );
  }

  Widget _completion(BuildContext context, S s, TextTheme text) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Spacer(),
        const Text('❤️', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(s.kegelSessionDoneTitle,
            textAlign: TextAlign.center, style: text.headlineMedium),
        const SizedBox(height: 12),
        Text(s.kegelSessionDoneBody,
            textAlign: TextAlign.center, style: text.bodyLarge),
        const SizedBox(height: 28),
        Text(s.howDidItFeel, style: text.titleMedium),
        const SizedBox(height: 14),
        _feedbackButton(s, '😊', s.feedbackEasy, 'easy'),
        const SizedBox(height: 10),
        _feedbackButton(s, '🙂', s.feedbackComfortable, 'comfortable'),
        const SizedBox(height: 10),
        _feedbackButton(s, '😓', s.feedbackDifficult, 'difficult'),
        const Spacer(),
      ]),
    );
  }

  Widget _feedbackButton(S s, String emoji, String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _saveFeedback(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text('$emoji   $label'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Care Journey (replaces a "levels" screen) + history
// ---------------------------------------------------------------------------

class _CareJourneyScreen extends StatelessWidget {
  const _CareJourneyScreen({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.careJourneyCta)),
      body: AnimatedBuilder(
        animation: ToolsStore.instance,
        builder: (context, _) {
          final store = ToolsStore.instance;
          final r = _routineFor(controller.currentWeek);
          final last = store.kegelLast != null
              ? DateTime.tryParse(store.kegelLast!)
              : null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(s.careJourneyTitle, style: text.headlineMedium),
              const SizedBox(height: 16),
              _stat(text, s.stageLabel, r.stage(s)),
              _stat(text, s.currentRoutineLabel,
                  '${r.hold} ${s.secShort} · ${r.relax} ${s.secShort} · ${r.reps} ${s.repsLabel.toLowerCase()}'),
              _stat(text, s.sessionsCompletedLabel, '${store.kegelSessions}'),
              _stat(text, s.completedThisWeekLabel,
                  '${store.kegelCompletedThisWeek}'),
              _stat(text, s.lastCompletedLabel,
                  last != null ? s.formatLongDate(last) : s.neverWord),
              const SizedBox(height: 20),
              if (store.kegelHistory.isNotEmpty) ...[
                Text(s.historyLabel, style: text.headlineSmall),
                const SizedBox(height: 10),
                for (final rec in store.kegelHistory)
                  _historyRow(context, rec, s, text),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _stat(TextTheme text, String label, String value) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(label, style: text.bodyMedium)),
              const SizedBox(width: 12),
              Text(value,
                  style:
                      text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ]),
      );

  Widget _historyRow(
      BuildContext context, KegelRecord rec, S s, TextTheme text) {
    final d = DateTime.tryParse(rec.dateIso);
    final fb = switch (rec.feedback) {
      'easy' => s.feedbackEasy,
      'difficult' => s.feedbackDifficult,
      _ => s.feedbackComfortable,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(d != null ? s.formatShortDate(d) : rec.dateIso,
            style: text.bodyMedium),
        Text(
            '${rec.holdSeconds}${s.secShort} · ${rec.repetitions} ${s.repsLabel.toLowerCase()}',
            style: text.labelSmall),
        Text(fb, style: text.labelMedium),
      ]),
    );
  }
}

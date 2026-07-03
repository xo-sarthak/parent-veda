// =============================================================================
//  Kegel Care
// -----------------------------------------------------------------------------
//  Pregnancy self-care & birth preparation — NOT a workout or gamified app.
//  No levels, XP, streaks or achievements. A pregnancy-aware adaptive routine
//  (3 stages by week), a guided hold/relax session, and a calm "Care Journey".
//  Per the product spec.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/app_theme.dart';

typedef _Routine = ({
  String Function(S) stage,
  int hold,
  int relax,
  int reps,
  int minutes,
});

int _minutesFor(int hold, int relax, int reps) =>
    (((hold + relax) * reps) / 60).ceil();

/// The RECOMMENDED routine for the current week + adaptive offsets.
_Routine _recommendedFor(int week) {
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
  return (
    stage: stage,
    hold: hold,
    relax: relax,
    reps: reps,
    minutes: _minutesFor(hold, relax, reps),
  );
}

/// The EFFECTIVE routine that's actually used — the user's custom one if set,
/// otherwise the recommended one.
_Routine _routineFor(int week) {
  final rec = _recommendedFor(week);
  final store = ToolsStore.instance;
  if (store.hasCustomKegelRoutine) {
    final hold = store.kegelCustomHold!;
    final relax = store.kegelCustomRelax!;
    final reps = store.kegelCustomReps!;
    return (
      stage: rec.stage,
      hold: hold,
      relax: relax,
      reps: reps,
      minutes: _minutesFor(hold, relax, reps),
    );
  }
  return rec;
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
  bool _howExpanded = true; // "What is a Kegel" opens by default, at the top.

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
              // Hero ("Pelvic Floor Care") removed per request — its intro now
              // lives inside the "Why am I doing this?" collapsible below.
              // What is a Kegel & how to do it — at the top, OPEN by default.
              _Expandable(
                title: s.kegelHowTitle,
                body: s.kegelHowBody,
                expanded: _howExpanded,
                onToggle: () => setState(() => _howExpanded = !_howExpanded),
              ),
              const SizedBox(height: 14),
              // Current routine — now contains the ℹ️ "Why this routine?", the
              // Edit ✏️ (Customize), and the Start session button.
              _currentRoutineCard(context, s, text, r),
              const SizedBox(height: 14),
              // "Why this routine?" box removed — it opens from the ℹ️ in the
              // card. Standalone "Start Care Session" button removed — now in card.
              // Why am I doing this? — now holds the Pelvic Floor Care intro
              // (its old text dropped).
              _Expandable(
                title: s.whyAmIDoingThis,
                expanded: _whyExpanded,
                onToggle: () => setState(() => _whyExpanded = !_whyExpanded),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
              // Safety — styled as a clear WARNING banner, not a plain text box.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0x66E08A2B), width: 1.4),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFC9700F), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(s.kegelSafetyTitle,
                                  style: text.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFA85B0C))),
                            ),
                          ]),
                      const SizedBox(height: 10),
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

  /// The "Current routine" card: shows the effective routine, an info (i) that
  /// explains the recommendation, and a Customize button (with Reset when a
  /// custom routine is active).
  Widget _currentRoutineCard(
      BuildContext context, S s, TextTheme text, _Routine r) {
    final rec = _recommendedFor(widget.controller.currentWeek);
    final isCustom = _store.hasCustomKegelRoutine;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(s.currentRoutineLabel,
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (isCustom) ...[
                  const SizedBox(width: 8),
                  _badge(text, s.customLabel),
                ],
              ]),
              const SizedBox(height: 4),
              // Replaces the old stage line ("Building consistency"). Tapping
              // this ℹ️ opens the "Why this routine?" explanation.
              InkWell(
                onTap: () => _showWhyThisRoutine(context, s),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: AppTheme.secondary600),
                    const SizedBox(width: 5),
                    Text(s.whyThisRoutine,
                        style: text.labelMedium?.copyWith(
                            color: AppTheme.secondary600,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
          // Edit (✏️) — opens the Customize sheet (moved here from the old
          // bottom "Customize" button; Reset-to-recommended lives in the sheet).
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: s.customizeLabel,
            onPressed: () => _showCustomize(context, s, rec),
            icon: const Icon(Icons.edit_rounded, size: 20),
          ),
        ]),
        const SizedBox(height: 8),
        _routineRow(text, s.holdLabel, '${r.hold} ${s.secShort}'),
        _routineRow(text, s.relaxLabel, '${r.relax} ${s.secShort}'),
        _routineRow(text, s.repsLabel, '${r.reps}'),
        _routineRow(text, s.estTimeLabel, s.minutesShort(r.minutes)),
        if (isCustom) ...[
          const SizedBox(height: 6),
          Text(
            '${s.recommendedLabel}: ${rec.hold} ${s.secShort} · '
            '${rec.relax} ${s.secShort} · ${rec.reps} '
            '${s.repsLabel.toLowerCase()}',
            style: text.bodySmall?.copyWith(color: AppTheme.neutral500),
          ),
        ],
        const SizedBox(height: 14),
        // Start session — replaces the old "Customize" button (the standalone
        // Start Care Session button was removed; Customize is now the ✏️ above).
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
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
        ),
      ]),
    );
  }

  Widget _badge(TextTheme text, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.secondary50,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(label.toUpperCase(),
            style: text.labelSmall?.copyWith(
              color: AppTheme.secondary600,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            )),
      );

  /// Opens the "Why this routine?" explanation (from the ℹ️ in the card).
  Future<void> _showWhyThisRoutine(BuildContext context, S s) {
    final text = Theme.of(context).textTheme;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.whyThisRoutine),
        content: Text(s.whyThisRoutineBody, style: text.bodyMedium),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text(s.gotIt)),
        ],
      ),
    );
  }

  // Old recommended-routine info popup — no longer used (the ℹ️ now shows "Why
  // this routine?"); kept for revert.
  // ignore: unused_element
  Future<void> _showRecommendInfo(BuildContext context, S s, _Routine rec) {
    final text = Theme.of(context).textTheme;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.recommendedLabel),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${rec.hold} ${s.secShort} · ${rec.relax} ${s.secShort} · '
                '${rec.reps} ${s.repsLabel.toLowerCase()}',
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(s.kegelCustomizeInfo, style: text.bodyMedium),
            ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text(s.gotIt)),
        ],
      ),
    );
  }

  Future<void> _showCustomize(BuildContext context, S s, _Routine rec) async {
    int hold = _store.kegelCustomHold ?? rec.hold;
    int relax = _store.kegelCustomRelax ?? rec.relax;
    int reps = _store.kegelCustomReps ?? rec.reps;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppTheme.surface,
      builder: (ctx) {
        final text = Theme.of(ctx).textTheme;
        return StatefulBuilder(builder: (ctx, setSheet) {
          final minutes = _minutesFor(hold, relax, reps);
          return Padding(
            padding: EdgeInsets.fromLTRB(
                22, 4, 22, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.customizeRoutineTitle, style: text.headlineSmall),
                  const SizedBox(height: 6),
                  Text(s.kegelCustomizeInfo,
                      style:
                          text.bodySmall?.copyWith(color: AppTheme.neutral600)),
                  const SizedBox(height: 12),
                  _stepper(text, s.holdLabel, '${s.recommendedLabel}: ${rec.hold}',
                      '$hold ${s.secShort}',
                      () => setSheet(() => hold = (hold - 1).clamp(2, 15)),
                      () => setSheet(() => hold = (hold + 1).clamp(2, 15))),
                  _stepper(
                      text,
                      s.relaxLabel,
                      '${s.recommendedLabel}: ${rec.relax}',
                      '$relax ${s.secShort}',
                      () => setSheet(() => relax = (relax - 1).clamp(2, 15)),
                      () => setSheet(() => relax = (relax + 1).clamp(2, 15))),
                  _stepper(text, s.repsLabel, '${s.recommendedLabel}: ${rec.reps}',
                      '$reps',
                      () => setSheet(() => reps = (reps - 1).clamp(5, 25)),
                      () => setSheet(() => reps = (reps + 1).clamp(5, 25))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.estTimeLabel, style: text.bodyMedium),
                          Text(s.minutesShort(minutes),
                              style: text.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                        ]),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        _store.setKegelCustomRoutine(
                            hold: hold, relax: relax, reps: reps);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(s.saveCta),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        _store.clearKegelCustomRoutine();
                        Navigator.of(ctx).pop();
                      },
                      child: Text(s.resetToRecommended),
                    ),
                  ),
                ]),
          );
        });
      },
    );
  }

  Widget _stepper(TextTheme text, String label, String sub, String value,
      VoidCallback onMinus, VoidCallback onPlus) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
            Text(sub,
                style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
          ]),
        ),
        _roundBtn(Icons.remove_rounded, onMinus),
        SizedBox(
          width: 64,
          child: Text(value,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ),
        _roundBtn(Icons.add_rounded, onPlus),
      ]),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) => Material(
        color: AppTheme.secondary50,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: AppTheme.secondary600),
          ),
        ),
      );
}

class _Expandable extends StatelessWidget {
  const _Expandable({
    required this.title,
    this.body,
    this.child,
    required this.expanded,
    required this.onToggle,
  });
  final String title;
  final String? body; // simple text body
  final Widget? child; // OR a rich body (e.g. the pelvic-floor intro)
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
              child: child ?? Text(body ?? '', style: text.bodyMedium),
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

class _SessionScreenState extends State<_SessionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final FlutterTts _tts = FlutterTts();
  bool _holding = true; // hold phase vs relax
  int _rep = 1;
  bool _done = false;
  bool _sound = true;

  int get _phaseSeconds => _holding ? widget.hold : widget.relax;
  int get _remaining =>
      (_phaseSeconds * (1 - _ctrl.value)).ceil().clamp(0, _phaseSeconds);
  bool get _paused => !_ctrl.isAnimating && !_done;

  @override
  void initState() {
    super.initState();
    _sound = ToolsStore.instance.kegelVoiceOn;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.hold),
    )..addStatusListener(_onStatus);
    _initTts();
    _startPhase(); // begin the first hold
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tts.stop();
    super.dispose();
  }

  /// A normal-pitch voice (deliberately NOT the baby voice) for hold/relax cues.
  Future<void> _initTts() async {
    try {
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setLanguage('en-IN');
    } catch (_) {/* audio is an enhancement, never fatal */}
  }

  Future<void> _speak(String word) async {
    if (!_sound) return;
    try {
      await _tts.stop();
      await _tts.speak(word);
    } catch (_) {}
  }

  void _startPhase() {
    _ctrl.duration = Duration(seconds: _phaseSeconds);
    _ctrl.forward(from: 0);
    HapticFeedback.lightImpact();
    _speak(_holding ? 'Hold' : 'Relax');
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_holding) {
      setState(() => _holding = false);
      _startPhase();
    } else if (_rep >= widget.reps) {
      _finish();
    } else {
      setState(() {
        _rep++;
        _holding = true;
      });
      _startPhase();
    }
  }

  void _finish() {
    _ctrl.stop();
    _speak('Well done');
    setState(() => _done = true);
  }

  void _togglePause() {
    if (_ctrl.isAnimating) {
      _ctrl.stop();
    } else {
      _ctrl.forward(); // resume from where it paused
    }
    setState(() {});
  }

  void _toggleSound() {
    setState(() => _sound = !_sound);
    ToolsStore.instance.setKegelVoice(_sound);
    if (!_sound) _tts.stop();
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
        actions: [
          IconButton(
            tooltip: s.voiceCuesLabel,
            onPressed: _toggleSound,
            icon: Icon(
                _sound ? Icons.volume_up_rounded : Icons.volume_off_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _done
            ? _completion(context, s, text)
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  const Spacer(),
                  // Animated ring that depletes over the phase + a gentle
                  // inflate-while-holding / settle-while-relaxing pulse.
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      final frac = (1 - _ctrl.value).clamp(0.0, 1.0);
                      final scale = _holding
                          ? 1 + 0.05 * _ctrl.value
                          : 1.05 - 0.05 * _ctrl.value;
                      return SizedBox(
                        width: 250,
                        height: 250,
                        child: CustomPaint(
                          painter: _RingPainter(progress: frac, color: color),
                          child: Center(
                            child: Transform.scale(
                              scale: scale,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_holding ? s.holdLabel : s.relaxLabel,
                                      style: text.headlineSmall
                                          ?.copyWith(color: color)),
                                  const SizedBox(height: 4),
                                  Text('$_remaining',
                                      style: text.displayLarge?.copyWith(
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(s.repOf(_rep, widget.reps), style: text.titleMedium),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _togglePause,
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

// ---------------------------------------------------------------------------
//  Session ring — a soft disc with a depleting arc for the current phase.
// ---------------------------------------------------------------------------

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  /// 1.0 = phase just started (full ring), 0.0 = phase complete (empty).
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;

    // Soft inner disc behind the text.
    canvas.drawCircle(
        center, radius - 6, Paint()..color = color.withValues(alpha: 0.10));

    // Track + depleting arc.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = color.withValues(alpha: 0.15);
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

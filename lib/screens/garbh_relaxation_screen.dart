// =============================================================================
//  Guided Relaxation — Kriya's eight minutes, head to toe
// -----------------------------------------------------------------------------
//  Built from the Garbh Sanskar pillars brief, pillar 4, 12 Sep 2026. Before
//  this, "Guided Relaxation" was a breathing pattern named `relax` on the
//  same circle as every other practice — the placeholder the door listed as
//  G11 in `docs/DOOR-CONTENT-OWED.md`. This is the session: a narrated
//  progressive-relaxation script, a timer, a calm visual, the current body
//  part lit on a figure, and a raga underneath if she wants one.
//
//  ⚠️ THE SCREEN NAMES NO STEP. `kKriyaRelaxation` is walked, not typed
//  here: the title, the seconds, the words and the figure position are the
//  data's. A recorded voice arrives by manifest (see `GarbhNarrator`). A
//  drawn figure arrives by `figureAsset`. The screen is the player.
//
//  ⚠️ THE SCRIPT IS PRINTED, NOT ONLY SPOKEN. TTC's rule for its practices
//  is the same one here: readable on its own for someone who cannot hear it,
//  or has the phone on silent, or has no TTS engine at all. Every step's
//  words are under its heading the whole time it runs.
//
//  ⚠️ THE RAGA IS SHRAVAN'S, SINGLE SOURCE. *"Optional background audio
//  pulled from the Shravan library (single source, do not duplicate audio)."*
//  The chips list `kShravan`'s ragas and play through `RagaAudioStore`, the
//  one player. Today every one of them is the bundled drone — Shravan's own
//  placeholder, G1 in the ledger — and the day Shravan gets real files, so
//  does this. Only a track this screen STARTED is stopped when it ends; one
//  she already had playing is hers.
//
//  ⚠️ PAUSE RESTARTS THE STEP'S WORDS. TTS engines do not resume mid-sentence
//  reliably, so pause stops the voice and resume speaks the current step from
//  its first word. The clock resumes where it stopped. A step that restarts
//  cleanly reads better than one picking up mid-clause.
//
//  ⚠️ NO CELEBRATION AT THE END. No chime, no confetti, no "well done" — the
//  same rule every practice in the app holds. The close line is the data's.
//
//  ⚠️ STOP IF, ON THE INTRO, WHOLE. The pillars brief: *"Keep visible and
//  human: the 'Stop and call your doctor today if...' red-flag list ... and
//  the 'support your bump' note."* Both are on the intro, above Begin, and
//  the flag is the same widget the Kriya screen draws.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/garbh_data.dart';
import '../data/kriya_relaxation_data.dart';
import '../models/garbh_content.dart' show GarbhKind;
import '../services/garbh_store.dart';
import '../services/garbh_narrator.dart';
import '../services/pregnancy_controller.dart';
import '../services/raga_audio_store.dart';
import '../theme/pv_fonts.dart';
import '../widgets/figure_highlight.dart';
import 'doors/pv_door_chrome.dart';
import 'garbh_screen.dart' show KriyaStopIfCard;
import 'v2/v2_palette.dart';

/// The file every Shravan track plays today. See the header.
const String _kShravanAsset = 'audio/raga_drone.wav';

class GarbhRelaxationScreen extends StatefulWidget {
  const GarbhRelaxationScreen({
    super.key,
    required this.pregnancy,
    this.daily = false,
    this.session = kKriyaRelaxation,
  });

  final PregnancyController pregnancy;

  /// Marks Kriya done on finish. False from the door, which keeps no score.
  final bool daily;
  final KriyaRelaxation session;

  @override
  State<GarbhRelaxationScreen> createState() => _GarbhRelaxationScreenState();
}

enum _Phase { intro, running, finished }

class _GarbhRelaxationScreenState extends State<GarbhRelaxationScreen> {
  _Phase _phase = _Phase.intro;
  bool _paused = false;
  Timer? _timer;
  int _step = -1;

  /// Milliseconds into the session. Accumulated per tick rather than read
  /// from a stopwatch, so a pause is simply ticks that do not add — and so a
  /// widget test can drive the whole eight minutes with `pump(duration)`.
  int _elapsedMs = 0;
  static const int _tickMs = 200;

  /// The Shravan track chosen on the intro; null is quiet.
  String? _bgId;
  bool _startedBg = false;

  KriyaRelaxation get s => widget.session;
  double get _elapsed => _elapsedMs / 1000;

  @override
  void dispose() {
    _timer?.cancel();
    _leaveSession();
    super.dispose();
  }

  /// Index of the step [elapsed] seconds falls in.
  int _stepAt(double elapsed) {
    var acc = 0;
    for (var i = 0; i < s.steps.length; i++) {
      acc += s.steps[i].seconds;
      if (elapsed < acc) return i;
    }
    return s.steps.length;
  }

  void _begin() {
    setState(() {
      _phase = _Phase.running;
      _paused = false;
      _step = -1;
      _elapsedMs = 0;
    });
    WakelockPlus.enable().catchError((Object _) {});
    _startBg();
    _timer?.cancel();
    _timer = Timer.periodic(
        const Duration(milliseconds: _tickMs), (_) => _tick(_tickMs));
    _tick(0);
  }

  void _tick(int addMs) {
    if (!mounted || _paused) return;
    _elapsedMs += addMs;
    final i = _stepAt(_elapsed);
    if (i >= s.steps.length) {
      _finish();
      return;
    }
    if (i != _step) {
      setState(() => _step = i);
      final st = s.steps[i];
      GarbhNarrator.instance
          .speak(s.narrationKeyFor(st), st.script, lang: widget.pregnancy.language);
    } else {
      setState(() {}); // the clock line
    }
  }

  void _togglePause() {
    if (_paused) {
      setState(() => _paused = false);
      final st = s.steps[_step.clamp(0, s.steps.length - 1)];
      GarbhNarrator.instance
          .speak(s.narrationKeyFor(st), st.script, lang: widget.pregnancy.language);
      _resumeBg();
    } else {
      setState(() => _paused = true);
      GarbhNarrator.instance.pause();
      _pauseBg();
    }
  }

  void _finish() {
    _timer?.cancel();
    _leaveSession();
    if (widget.daily) GarbhStore.instance.markDone('kriya');
    if (mounted) setState(() => _phase = _Phase.finished);
  }

  void _end() {
    _timer?.cancel();
    _leaveSession();
    if (mounted) setState(() => _phase = _Phase.intro);
  }

  void _leaveSession() {
    GarbhNarrator.instance.stop();
    WakelockPlus.disable().catchError((Object _) {});
    if (_startedBg) {
      RagaAudioStore.instance.stop();
      _startedBg = false;
    }
  }

  // ---- the raga underneath -------------------------------------------------

  void _startBg() {
    if (_bgId == null) return;
    final store = RagaAudioStore.instance;
    if (store.isPlayingAsset(_kShravanAsset)) return; // hers already
    final title = kShravan.firstWhere((a) => a.id == _bgId).title.now;
    _startedBg = true;
    store.toggle(_kShravanAsset, title: title, loop: true);
  }

  void _pauseBg() {
    if (!_startedBg) return;
    final store = RagaAudioStore.instance;
    if (store.isPlayingAsset(_kShravanAsset)) store.toggle(_kShravanAsset);
  }

  void _resumeBg() {
    if (!_startedBg) return;
    final store = RagaAudioStore.instance;
    if (!store.isPlayingAsset(_kShravanAsset)) store.toggle(_kShravanAsset);
  }

  // ---- drawing ---------------------------------------------------------------

  String _left() {
    final left = (s.totalSeconds - _elapsed).clamp(0, s.totalSeconds).ceil();
    return '${left ~/ 60}:${(left % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(42, p);
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.42)
        .withLightness(0.34)
        .toColor();
    final minutes = (s.totalSeconds / 60).round();

    return PopScope(
      onPopInvokedWithResult: (_, _) => _leaveSession(),
      child: PvDoorToolScaffold(
        hue: 42,
        eyebrow: 'Kriya',
        title: s.title,
        intro: '$minutes minutes, head to toe. Your calm and your grounding; '
            'nothing here is a claim about the baby.',
        children: switch (_phase) {
          _Phase.intro => _intro(p, tint, ink),
          _Phase.running => _running(p, tint, ink),
          _Phase.finished => _finished(p, ink),
        },
      ),
    );
  }

  List<Widget> _intro(V2Palette p, Color tint, Color ink) {
    final t = garbhTrimester(widget.pregnancy.currentWeek);
    final ragas = kShravan.where((a) => a.kind == GarbhKind.raga).toList();
    return [
      pvDoorPad(Text(s.intro,
          style: pvManrope(fontSize: 15, height: 1.6, color: p.ink1))),
      const SizedBox(height: 18),
      pvDoorPad(Text('A raga underneath, if you like',
          style: pvManrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.ink3))),
      const SizedBox(height: 10),
      pvDoorPad(Wrap(spacing: 8, runSpacing: 8, children: [
        _Chip(
            p: p,
            ink: ink,
            label: 'Quiet',
            selected: _bgId == null,
            onTap: () => setState(() => _bgId = null)),
        for (final a in ragas)
          _Chip(
              p: p,
              ink: ink,
              label: a.title.now,
              selected: _bgId == a.id,
              onTap: () => setState(() => _bgId = a.id)),
      ])),
      const SizedBox(height: 22),
      pvDoorPad(Text(kriyaSafety(t).now,
          style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2))),
      const SizedBox(height: 14),
      pvDoorPad(const KriyaStopIfCard()),
      const SizedBox(height: 22),
      pvDoorPad(_Pill(p: p, label: 'Begin', strong: true, onTap: _begin)),
      const SizedBox(height: 10),
    ];
  }

  List<Widget> _running(V2Palette p, Color tint, Color ink) {
    final st = s.steps[_step.clamp(0, s.steps.length - 1)];
    final progress = (_elapsed / s.totalSeconds).clamp(0.0, 1.0);
    return [
      pvDoorPad(Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: st.part),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          // ⚠️ THE DISC IS INK, NOT THE TINT. At the tint's 20% over white
          // the highlight was invisible on the phone (2026-09-13); a grey
          // disc reads as "here" without shouting.
          builder: (context, v, _) => PvFigureHighlight(
            highlight: v,
            accent: p.ink2,
            line: p.ink3,
            asset: s.figureAsset,
            height: 170,
          ),
        ),
      )),
      const SizedBox(height: 10),
      pvDoorPad(Text('${_step + 1} of ${s.steps.length}',
          style: pvManrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.ink3))),
      const SizedBox(height: 6),
      pvDoorPad(AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: Column(
          key: ValueKey(st.id),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(st.title,
                style: pvFraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    letterSpacing: -0.5,
                    color: p.ink1)),
            const SizedBox(height: 10),
            Text(st.script,
                style: pvManrope(fontSize: 14.5, height: 1.6, color: p.ink1)),
          ],
        ),
      )),
      const SizedBox(height: 18),
      pvDoorPad(Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: p.line,
              valueColor: AlwaysStoppedAnimation(ink),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('${_left()} left',
            style: pvManrope(fontSize: 12.5, color: p.ink3)),
      ])),
      const SizedBox(height: 18),
      pvDoorPad(Row(children: [
        Expanded(
          child: _Pill(
              p: p,
              label: _paused ? 'Resume' : 'Pause',
              strong: true,
              onTap: _togglePause),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Pill(p: p, label: 'End', strong: false, onTap: _end),
        ),
      ])),
      const SizedBox(height: 10),
    ];
  }

  List<Widget> _finished(V2Palette p, Color ink) => [
        pvDoorPad(Text(s.close,
            style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: p.ink1))),
        const SizedBox(height: 22),
        pvDoorPad(_Pill(
            p: p,
            label: 'Done',
            strong: true,
            onTap: () => Navigator.of(context).maybePop())),
        const SizedBox(height: 10),
        pvDoorPad(_Pill(
            p: p,
            label: 'Once more',
            strong: false,
            onTap: () => setState(() => _phase = _Phase.intro))),
      ];
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.p,
      required this.ink,
      required this.label,
      required this.selected,
      required this.onTap});
  final V2Palette p;
  final Color ink;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? ink.withValues(alpha: 0.12) : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? ink : p.line),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? ink : p.ink2)),
        ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.p,
      required this.label,
      required this.strong,
      required this.onTap});
  final V2Palette p;
  final String label;
  final bool strong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: strong ? p.ink1 : p.line, width: strong ? 1.2 : 1),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: strong ? p.ink1 : p.ink2)),
        ),
      );
}

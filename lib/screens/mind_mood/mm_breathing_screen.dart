// =============================================================================
//  MmBreathingScreen - guided, animated, follow-along breathing
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE MOST-USED TOOL IN THE SECTION. Built for real, not a stub:
//  a genuine expanding/contracting circle driven by an AnimationController,
//  phase labels ("Breathe in" / "Hold" / "Breathe out"), a selectable
//  session length, and a real running timer.
//
//  The three patterns come from `kMmBreathingExercises` in mind_mood_data.dart
//  - this screen knows nothing about which pattern it is running beyond the
//  phase list it is handed, so a fourth pattern is a data change, not a
//  rebuild of this screen.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/mind_mood_data.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';

class MmBreathingScreen extends StatefulWidget {
  const MmBreathingScreen({super.key, required this.exercise});
  final MmBreathingExercise exercise;

  @override
  State<MmBreathingScreen> createState() => _MmBreathingScreenState();
}

class _MmBreathingScreenState extends State<MmBreathingScreen>
    with SingleTickerProviderStateMixin {
  static const double _minScale = 0.55;
  static const double _maxScale = 1.0;

  late final AnimationController _scale = AnimationController(
    vsync: this,
    lowerBound: _minScale,
    upperBound: _maxScale,
    value: _minScale,
  );

  int _durationSec = kMmBreathDurationsSec[0];
  bool _running = false;
  bool _cancelled = false;
  bool _finished = false;
  int _elapsed = 0;
  int _phaseIndex = 0;
  Timer? _clock;

  @override
  void dispose() {
    _cancelled = true;
    _clock?.cancel();
    _scale.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _running = true;
      _finished = false;
      _cancelled = false;
      _elapsed = 0;
      _phaseIndex = 0;
    });
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed++);
      if (_elapsed >= _durationSec && _running) {
        _stop(completed: true);
      }
    });
    await _runLoop();
  }

  Future<void> _runLoop() async {
    final phases = widget.exercise.phases;
    while (!_cancelled && mounted && _elapsed < _durationSec) {
      for (var i = 0; i < phases.length; i++) {
        if (_cancelled || !mounted || _elapsed >= _durationSec) break;
        setState(() => _phaseIndex = i);
        final phase = phases[i];
        switch (phase.action) {
          case MmBreathAction.expand:
            await _scale
                .animateTo(_maxScale,
                    duration: Duration(seconds: phase.seconds),
                    curve: Curves.easeInOut)
                .catchError((_) {});
            break;
          case MmBreathAction.contract:
            await _scale
                .animateTo(_minScale,
                    duration: Duration(seconds: phase.seconds),
                    curve: Curves.easeInOut)
                .catchError((_) {});
            break;
          case MmBreathAction.hold:
            await Future<void>.delayed(Duration(seconds: phase.seconds));
            break;
        }
      }
    }
  }

  void _stop({bool completed = false}) {
    _cancelled = true;
    _clock?.cancel();
    if (!mounted) return;
    setState(() {
      _running = false;
      _finished = completed;
    });
  }

  String _durationLabel(int sec) => sec < 60
      ? '$sec sec'
      : (sec % 60 == 0 ? '${sec ~/ 60} min' : '${sec ~/ 60}.5 min');

  String _remainingLabel(int sec) {
    final s = sec.clamp(0, 1 << 30);
    final m = s ~/ 60;
    final r = s % 60;
    return '$m:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(160, p); // SolutionType.tool's hue, app-wide
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.36)
        .toColor();

    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 20, 0),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.arrow_back_rounded, color: p.ink2),
              ),
              Expanded(
                child: Text(widget.exercise.name.now,
                    textAlign: TextAlign.center,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: p.ink2)),
              ),
              const SizedBox(width: 40),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_running && !_finished) ...[
                    Text(widget.exercise.description.now,
                        textAlign: TextAlign.center,
                        style: pvManrope(
                            fontSize: 14, height: 1.55, color: p.ink2)),
                    const SizedBox(height: 10),
                    Text(widget.exercise.why.now,
                        textAlign: TextAlign.center,
                        style: pvManrope(
                            fontSize: 12.5, height: 1.5, color: p.ink3)),
                    const SizedBox(height: 34),
                  ],
                  if (_running) ...[
                    _BreathCircle(scale: _scale, tint: tint, ink: ink),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        widget.exercise.phases[_phaseIndex].label.now,
                        key: ValueKey(_phaseIndex),
                        style: pvFraunces(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: p.ink1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                        '${_remainingLabel(_durationSec - _elapsed)} left',
                        style: pvManrope(fontSize: 12.5, color: p.ink3)),
                  ] else if (_finished) ...[
                    Icon(Icons.check_circle_outline_rounded,
                        size: 48, color: ink),
                    const SizedBox(height: 16),
                    Text('That is a full session.',
                        textAlign: TextAlign.center,
                        style: pvFraunces(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                    const SizedBox(height: 8),
                    Text(
                        'However you feel right now is exactly the right '
                        'way to feel.',
                        textAlign: TextAlign.center,
                        style: pvManrope(
                            fontSize: 13.5, height: 1.5, color: p.ink2)),
                  ] else ...[
                    _BreathCircle(scale: _scale, tint: tint, ink: ink),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
            child: _running
                ? _OutlinedPill(
                    label: 'Stop',
                    color: p.ink3,
                    onTap: () => _stop(),
                  )
                : Column(children: [
                    if (!_finished) ...[
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        children: [
                          for (final d in kMmBreathDurationsSec)
                            _DurationChip(
                              label: _durationLabel(d),
                              selected: d == _durationSec,
                              tint: tint,
                              ink: ink,
                              p: p,
                              onTap: () => setState(() => _durationSec = d),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    _OutlinedPill(
                      label: _finished ? 'Do another round' : 'Begin',
                      color: ink,
                      onTap: _start,
                    ),
                  ]),
          ),
        ]),
      ),
    );
  }
}

class _BreathCircle extends StatelessWidget {
  const _BreathCircle({required this.scale, required this.tint, required this.ink});
  final Animation<double> scale;
  final Color tint;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scale,
      builder: (context, _) {
        final size = 150 + (scale.value - 0.55) / 0.45 * 90;
        return Container(
          width: 240,
          height: 240,
          alignment: Alignment.center,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [tint.withValues(alpha: 0.9), tint.withValues(alpha: 0.35)],
              ),
              border: Border.all(color: ink.withValues(alpha: 0.25), width: 1.2),
            ),
          ),
        );
      },
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip(
      {required this.label,
      required this.selected,
      required this.tint,
      required this.ink,
      required this.p,
      required this.onTap});
  final String label;
  final bool selected;
  final Color tint;
  final Color ink;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? tint.withValues(alpha: 0.55) : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? ink.withValues(alpha: 0.4) : p.line),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? ink : p.ink2)),
        ),
      ),
    );
  }
}

class _OutlinedPill extends StatelessWidget {
  const _OutlinedPill({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color, width: 1.4),
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: pvManrope(
                    fontSize: 15, fontWeight: FontWeight.w700, color: color)),
          ),
        ),
      ),
    );
  }
}

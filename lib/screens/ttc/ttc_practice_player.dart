// =============================================================================
//  The practice players — one per animation kind
// -----------------------------------------------------------------------------
//  From the animation spec in `ParentVeda_Mindbody_twelve_practice_cards.pdf`.
//  Reference feel, in the brief's words: *"the Bend stretching app. A simple
//  looping figure, a timer, a step line, and nothing else on screen. Calm, no
//  music, no voice, no scores."*
//
//  ⚠️ ONE BREATHING COMPONENT, CONFIGURED FOUR WAYS. The brief asks for this
//  explicitly — *"Build this once and reuse it"* — and it is the difference
//  between four players that drift and one that cannot. Box breathing traces a
//  square instead of a circle, alternate nostril adds a side indicator, and ten
//  breaths together counts to ten with two markers. All three are `TtcBreathAnim`
//  fields, not separate widgets.
//
//  ⚠️ EVERY PLAYER IS OPTIONAL. The brief: *"The step text must be readable on
//  its own for someone who cannot see the animation."* So none of these owns the
//  steps, the timer or the safety note — the screen draws those, and the player
//  sits above them. A card with no player at all still works.
//
//  ⚠️ AND NOTHING CELEBRATES. No confetti, no chime, no "well done" — the brief
//  forbids all three, and the reason is the same one that keeps streaks out of
//  this area: a screen that celebrates finishing makes the days you did not open
//  it into days you let something down.
// =============================================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_practice_data.dart';
import 'ttc_common.dart';

/// Where a session is, in whole seconds.
///
/// ⚠️ ELAPSED IS COMPUTED FROM A TIMESTAMP, NOT COUNTED UP BY THE TICKER. A
/// counter that increments on every tick drifts, and drifts by more the longer
/// the practice runs and the busier the device is — which is worst on the
/// ten-minute walk, the one session somebody actually leaves running. Wall-clock
/// arithmetic is also what survives the screen locking.
class _Clock {
  Duration held = Duration.zero;
  DateTime? startedAt;

  bool get running => startedAt != null;

  Duration get elapsed =>
      held + (startedAt == null ? Duration.zero : DateTime.now().difference(startedAt!));

  void start() => startedAt ??= DateTime.now();

  void pause() {
    if (startedAt == null) return;
    held += DateTime.now().difference(startedAt!);
    startedAt = null;
  }

  void reset() {
    held = Duration.zero;
    startedAt = null;
  }
}

/// The shared session shell: a player, a ring, and pause / restart.
class TtcPracticeSession extends StatefulWidget {
  const TtcPracticeSession({super.key, required this.practice});

  final TtcPractice practice;

  @override
  State<TtcPracticeSession> createState() => TtcPracticeSessionState();
}

class TtcPracticeSessionState extends State<TtcPracticeSession> {
  final _clock = _Clock();
  Timer? _ticker;

  int get _total => widget.practice.anim.seconds;
  int get _left => (_total - _clock.elapsed.inSeconds).clamp(0, _total);

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_clock.running) {
        _clock.pause();
        _ticker?.cancel();
        _ticker = null;
      } else {
        if (_left == 0) _clock.reset();
        _clock.start();
        // 100ms rather than 1s: the breathing circle moves continuously, and a
        // one-second tick makes it step rather than glide.
        _ticker = Timer.periodic(
            const Duration(milliseconds: 100), (_) => setState(() {}));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final anim = widget.practice.anim;
    final done = _left == 0 && _clock.elapsed.inSeconds > 0;
    final t = _clock.elapsed.inMilliseconds / 1000.0;
    final progress = _total == 0 ? 0.0 : (t / _total).clamp(0.0, 1.0);

    return Column(children: [
      SizedBox(
        height: 232,
        child: Center(
          child: switch (anim) {
            TtcBreathAnim() => _Breath(
                spec: anim, seconds: t, progress: progress,
                running: _clock.running),
            TtcBodyScanAnim() =>
              _BodyScan(steps: widget.practice.steps, progress: progress),
            TtcListenAnim() => _Listen(seconds: t, progress: progress),
            TtcFigureAnim() =>
              _Figure(spec: anim, progress: progress),
            TtcTimerAnim() => _PlainTimer(left: _left, progress: progress),
          },
        ),
      ),
      const SizedBox(height: 18),

      // ---- pause / start, and nothing that scores ------------------------
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _clock.running ? ttcPanel : ttcPurple,
              borderRadius: BorderRadius.circular(999),
              border: _clock.running ? Border.all(color: ttcBorder) : null,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                  _clock.running
                      ? Icons.pause_rounded
                      : done
                          ? Icons.replay_rounded
                          : Icons.play_arrow_rounded,
                  size: 19,
                  color: _clock.running ? ttcTitleInk : Colors.white),
              const SizedBox(width: 8),
              Text(
                  _clock.running
                      ? 'Pause'
                      : done
                          ? 'Again'
                          : 'Start',
                  style: ttcBody(14.5,
                      color: _clock.running ? ttcTitleInk : Colors.white,
                      w: FontWeight.w700)),
            ]),
          ),
        ),
      ]),

      if (done) ...[
        const SizedBox(height: 14),
        // ⚠️ THE FLATTEST SENTENCE THAT IS STILL WARM. No "well done", no
        // score, no streak. The brief bans a celebration animation on finishing
        // and the reasoning goes further than the animation: praise for
        // finishing is what makes not finishing a failure.
        Text('That is the whole thing.',
            style: ttcBody(13, color: ttcSoft, h: 1.5)),
      ],
    ]);
  }
}

// =============================================================================
//  The breathing component — built once, configured per card
// =============================================================================

enum _Phase { inhale, hold, exhale, holdEmpty }

class _Breath extends StatelessWidget {
  const _Breath(
      {required this.spec,
      required this.seconds,
      required this.progress,
      required this.running});

  final TtcBreathAnim spec;
  final double seconds;
  final double progress;
  final bool running;

  /// Where in one cycle we are, and how far through that phase.
  (_Phase, double, int) _at() {
    final cycle = spec.cycle.toDouble();
    var p = cycle == 0 ? 0.0 : seconds % cycle;

    if (p < spec.inhale) return (_Phase.inhale, p / spec.inhale, p.ceil());
    p -= spec.inhale;
    if (spec.hold > 0 && p < spec.hold) {
      return (_Phase.hold, p / spec.hold, p.ceil());
    }
    if (spec.hold > 0) p -= spec.hold;
    if (p < spec.exhale) return (_Phase.exhale, p / spec.exhale, p.ceil());
    p -= spec.exhale;
    return (_Phase.holdEmpty, spec.holdEmpty == 0 ? 1 : p / spec.holdEmpty,
        p.ceil());
  }

  @override
  Widget build(BuildContext context) {
    final (phase, within, count) = _at();

    // The figure is large on the in-breath and small on the out-breath, and
    // holds where the practice holds. Nothing else on screen moves.
    final scale = switch (phase) {
      _Phase.inhale => 0.55 + 0.45 * within,
      _Phase.hold => 1.0,
      _Phase.exhale => 1.0 - 0.45 * within,
      _Phase.holdEmpty => 0.55,
    };

    final word = switch (phase) {
      _Phase.inhale => 'Breathe in',
      _Phase.hold => 'Hold',
      _Phase.exhale => 'Breathe out',
      _Phase.holdEmpty => 'Hold empty',
    };

    final rounds =
        spec.cycle == 0 ? 0 : (seconds / spec.cycle).floor() + 1;

    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
          painter: _RingPainter(
              progress: progress, twoMarkers: spec.twoMarkers),
        ),
      ),
      // ⚠️ A SQUARE FOR BOX BREATHING. "This one is naturally a square, not a
      // circle" — four equal phases around four equal sides, so the shape is
      // teaching the timing rather than decorating it.
      AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            color: ttcPurple.withValues(alpha: 0.14),
            shape: spec.square ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: spec.square ? BorderRadius.circular(18) : null,
            border: Border.all(color: ttcPurple.withValues(alpha: 0.5), width: 2),
          ),
        ),
      ),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(running ? word : 'Ready',
            style: ttcBody(13.5, color: ttcTitleInk, w: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(running ? '$count' : '',
            style: pvFraunces(
                fontSize: 30, fontWeight: FontWeight.w600, color: ttcPurple)),
        if (spec.countTo != null && running) ...[
          const SizedBox(height: 2),
          Text('Breath ${rounds.clamp(1, spec.countTo!)} of ${spec.countTo}',
              style: ttcBody(11.5, color: ttcSoft)),
        ],
        // ⚠️ THE SIDE, BECAUSE THE PRACTICE IS ABOUT WHICH SIDE. Alternate
        // nostril breathing with no indication of which nostril is a diagram of
        // ordinary breathing.
        if (spec.nostrils && running) ...[
          const SizedBox(height: 2),
          Text(
              phase == _Phase.inhale
                  ? (rounds.isOdd ? 'In through the LEFT' : 'In through the RIGHT')
                  : (rounds.isOdd
                      ? 'Out through the RIGHT'
                      : 'Out through the LEFT'),
              style: ttcBody(11.5, color: ttcSoft, w: FontWeight.w700)),
        ],
      ]),
    ]);
  }
}

// =============================================================================
//  The other four
// =============================================================================

/// Attention moving down the body, one named part at a time.
class _BodyScan extends StatelessWidget {
  const _BodyScan({required this.steps, required this.progress});
  final List<String> steps;
  final double progress;

  @override
  Widget build(BuildContext context) {
    // The first and last steps are settling in and coming out, so the scan
    // itself runs over the middle ones.
    final body = steps.length > 2 ? steps.sublist(1, steps.length - 1) : steps;
    final i = (progress * body.length).floor().clamp(0, body.length - 1);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 210,
        height: 150,
        child: CustomPaint(
          painter: _FigurePainter(
              highlight: body.isEmpty ? 0 : i / body.length),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: 260,
        child: Text(body.isEmpty ? '' : body[i],
            textAlign: TextAlign.center,
            style: ttcBody(13, color: ttcTitleInk, h: 1.4)),
      ),
    ]);
  }
}

/// A soft pulse and a ring. No audio is bundled — she brings her own.
class _Listen extends StatelessWidget {
  const _Listen({required this.seconds, required this.progress});
  final double seconds;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.85 + 0.15 * math.sin(seconds * 0.9);
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(painter: _RingPainter(progress: progress)),
      ),
      Transform.scale(
        scale: pulse,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              ttcPurple.withValues(alpha: 0.28),
              ttcPurple.withValues(alpha: 0.04),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 96),
        child: Text('Play your own',
            style: ttcBody(11.5, color: ttcSoft, w: FontWeight.w700)),
      ),
    ]);
  }
}

/// A drawn figure when one exists, and an honest placeholder until then.
class _Figure extends StatelessWidget {
  const _Figure({required this.spec, required this.progress});
  final TtcFigureAnim spec;
  final double progress;

  @override
  Widget build(BuildContext context) {
    // ⚠️ WHEN `assetPath` IS FILLED, A Rive OR Lottie PLAYER GOES HERE AND
    // NOTHING ELSE CHANGES. The path is read from the card's data exactly so
    // that dropping a file in is a data edit. The package is not added yet
    // because adding a dependency for six files that do not exist is how a
    // pubspec collects things nobody uses.
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(painter: _RingPainter(progress: progress)),
      ),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.self_improvement_rounded,
            size: 58, color: ttcPurple.withValues(alpha: 0.35)),
        const SizedBox(height: 10),
        SizedBox(
          width: 190,
          child: Text('Follow the steps below.',
              textAlign: TextAlign.center,
              style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
        ),
      ]),
    ]);
  }
}

/// Ten minutes, and nothing else.
class _PlainTimer extends StatelessWidget {
  const _PlainTimer({required this.left, required this.progress});
  final int left;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final m = left ~/ 60;
    final s = left % 60;
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(painter: _RingPainter(progress: progress)),
      ),
      Text('$m:${s.toString().padLeft(2, '0')}',
          style: pvFraunces(
              fontSize: 40, fontWeight: FontWeight.w600, color: ttcTitleInk)),
    ]);
  }
}

// =============================================================================
//  Painters
// =============================================================================

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, this.twoMarkers = false});
  final double progress;
  final bool twoMarkers;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 6;

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = ttcBorder);

    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = ttcPurple);

    // ⚠️ TWO MARKERS FOR THE ONE PRACTICE THAT IS FOR TWO PEOPLE. It is a small
    // thing and it is the only thing on screen that says "this one is not
    // yours alone" — which is the entire point of that card.
    final dots = twoMarkers ? 2 : 1;
    for (var i = 0; i < dots; i++) {
      final a = -math.pi / 2 + 2 * math.pi * progress + (i * 0.22);
      canvas.drawCircle(c + Offset(math.cos(a) * r, math.sin(a) * r), 6,
          Paint()..color = ttcPurple);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.twoMarkers != twoMarkers;
}

/// A body outline with one region lit. [highlight] runs 0 (head) → 1 (feet).
class _FigurePainter extends CustomPainter {
  const _FigurePainter({required this.highlight});
  final double highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = ttcBorder;

    final cx = size.width / 2;
    final top = 14.0;
    final bottom = size.height - 10;

    // head, spine, arms, legs — deliberately schematic. It is a position
    // indicator, not an anatomy drawing.
    canvas.drawCircle(Offset(cx, top + 10), 10, line);
    canvas.drawLine(Offset(cx, top + 22), Offset(cx, bottom - 34), line);
    canvas.drawLine(Offset(cx - 26, top + 40), Offset(cx + 26, top + 40), line);
    canvas.drawLine(
        Offset(cx, bottom - 34), Offset(cx - 18, bottom), line);
    canvas.drawLine(
        Offset(cx, bottom - 34), Offset(cx + 18, bottom), line);

    final y = top + (bottom - top) * highlight.clamp(0.0, 1.0);
    canvas.drawCircle(
        Offset(cx, y),
        17,
        Paint()..color = ttcPurple.withValues(alpha: 0.20));
  }

  @override
  bool shouldRepaint(_FigurePainter old) => old.highlight != highlight;
}

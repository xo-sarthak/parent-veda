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
import '../../widgets/breathing_circle.dart';
import '../../widgets/figure_highlight.dart';
import '../v2/v2_palette.dart';
import 'ttc_mind_today_screen.dart' show kTtcMoveHue, kTtcBreatheHue;

// -----------------------------------------------------------------------------
//  The two colours every player draws with
// -----------------------------------------------------------------------------
//  ⚠️ RESOLVED ONCE AND PASSED DOWN, NOT READ IN SIX PAINTERS. These used to be
//  the fixed TTC tool tokens — a violet circle and a lilac ring — which is why
//  a breathing practice opened from a sand-coloured door looked like a screen
//  borrowed from somewhere else. The accent is now the practice's OWN hue, the
//  same one its block wears on Today, so the card you tapped and the circle you
//  get are the same colour.
//
//  A painter cannot read an inherited widget, so this travels as a value rather
//  than through the tree.
class TtcPracticeSkin {
  const TtcPracticeSkin({required this.p, required this.accent});

  final V2Palette p;

  /// The moving part: the circle, the arc, the count.
  final Color accent;

  /// The still part behind it. A hairline, never a shadow.
  Color get track => p.line;

  /// The skin for one practice, from the palette on screen.
  factory TtcPracticeSkin.of(TtcPractice practice) => TtcPracticeSkin.atHue(
      practice.kind == TtcPracticeKind.move ? kTtcMoveHue : kTtcBreatheHue);

  /// The calm end of the pair, for a sit that belongs to no library.
  factory TtcPracticeSkin.breathe() => TtcPracticeSkin.atHue(kTtcBreatheHue);

  factory TtcPracticeSkin.atHue(double hue) {
    final p = V2PaletteStore.instance.current;
    return TtcPracticeSkin(
      p: p,
      // The block tint is a pale wash — right behind large type, far too weak
      // for a 5pt arc — so the accent is that hue taken down to ink strength.
      accent: HSLColor.fromColor(v2BlockTint(hue, p))
          .withSaturation(0.44)
          .withLightness(0.36)
          .toColor(),
    );
  }
}

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
///
/// ⚠️ TWO WAYS IN, AND THE SECOND ONE IS WHY THIS TAKES AN ANIM RATHER THAN A
/// PRACTICE. The garbh sanskar course asks twice for a plain sit with a ring
/// behind nothing at all — session 1's two minutes of sitting still, session 3's
/// five minutes of attention on the breath — and neither is a card in the
/// library, because neither is a thing you would put on Today. Building a second
/// timer for them would be a second clock to keep in step with this one; the
/// brief's instruction for the whole course is *"Reuse, do not rebuild."*
///
/// So the widget holds what it actually draws with, and `TtcPracticeSession.sit`
/// is the door for anything that has a duration and no card.
class TtcPracticeSession extends StatefulWidget {
  TtcPracticeSession({super.key, required TtcPractice practice})
      : anim = practice.anim,
        steps = practice.steps,
        skinFor = (() => TtcPracticeSkin.of(practice));

  /// A ring, a clock, and nothing else. For a sit the course asks for.
  TtcPracticeSession.sit({super.key, required int seconds})
      : anim = TtcTimerAnim(seconds: seconds),
        steps = const [],
        skinFor = (() => TtcPracticeSkin.breathe());

  final TtcPracticeAnim anim;

  /// Only the body scan reads these — it names the part it is lighting.
  final List<String> steps;

  /// ⚠️ A CLOSURE, NOT A COLOUR. The palette can change under a running session
  /// (the ground switcher repaints the whole app), so the skin has to be
  /// resolved in `build` rather than captured in the constructor.
  final TtcPracticeSkin Function() skinFor;

  @override
  State<TtcPracticeSession> createState() => TtcPracticeSessionState();
}

class TtcPracticeSessionState extends State<TtcPracticeSession> {
  final _clock = _Clock();
  Timer? _ticker;

  int get _total => widget.anim.seconds;
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
    final skin = widget.skinFor();
    final p = skin.p;
    final anim = widget.anim;
    final done = _left == 0 && _clock.elapsed.inSeconds > 0;
    final t = _clock.elapsed.inMilliseconds / 1000.0;
    final progress = _total == 0 ? 0.0 : (t / _total).clamp(0.0, 1.0);

    return Column(children: [
      // ⚠️ A MINIMUM, NOT A FIXED HEIGHT, AND IT WAS FIXED UNTIL 2026-09-10.
      // Five of the six players are a ring with something small in the middle
      // and fit 232 forever. The body scan is the odd one: it is a Column of a
      // figure AND the name of the body part currently lit, and that caption
      // wraps to as many lines as the step needs — three, at the largest
      // accessibility sizes, which pushed the whole Column past a hard 232 and
      // striped the screen. A floor is enough to stop a breathing circle
      // jumping between phases, and nothing needs a ceiling.
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 232),
        child: Center(
          child: switch (anim) {
            TtcBreathAnim() => _Breath(
                spec: anim, seconds: t, progress: progress,
                running: _clock.running, skin: skin),
            TtcBodyScanAnim() =>
              _BodyScan(steps: widget.steps, progress: progress, skin: skin),
            TtcListenAnim() =>
              _Listen(seconds: t, progress: progress, skin: skin),
            TtcFigureAnim() => _Figure(progress: progress, skin: skin),
            TtcTimerAnim() =>
              _PlainTimer(left: _left, progress: progress, skin: skin),
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
              color: _clock.running ? p.surfaceAlt : skin.accent,
              borderRadius: BorderRadius.circular(999),
              border: _clock.running ? Border.all(color: p.line) : null,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                  _clock.running
                      ? Icons.pause_rounded
                      : done
                          ? Icons.replay_rounded
                          : Icons.play_arrow_rounded,
                  size: 19,
                  color: _clock.running ? p.ink1 : Colors.white),
              const SizedBox(width: 8),
              Text(
                  _clock.running
                      ? 'Pause'
                      : done
                          ? 'Again'
                          : 'Start',
                  style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _clock.running ? p.ink1 : Colors.white)),
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
        Text("That's the whole thing.",
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
      ],
    ]);
  }
}

// =============================================================================
//  The breathing component — built once, configured per card
// =============================================================================

// ⚠️ THE CIRCLE ITSELF IS `PvBreathingCircle` NOW — 2026-09-12. This was the
// first "one component, configured four ways" in the app, and the Garbh
// pillars brief asked for one component across ALL areas, not one per stage.
// What is TTC's stays here: the progress ring, the two markers, the count-to
// line and the nostril side. The shape, the word and the count are the shared
// widget's, fed the same stopwatch. The old body is in git.
class _Breath extends StatelessWidget {
  const _Breath(
      {required this.spec,
      required this.seconds,
      required this.progress,
      required this.running,
      required this.skin});

  final TtcBreathAnim spec;
  final double seconds;
  final double progress;
  final bool running;
  final TtcPracticeSkin skin;

  @override
  Widget build(BuildContext context) {
    final pattern = spec.toBreathPattern();
    final m = pattern.at(seconds);
    // Step 0 is always the in-breath; the rest of the nostril logic reads
    // the cycle number, as before.
    final inhaling = m.index == 0;
    final rounds = m.cycle;

    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
          painter: _RingPainter(
              progress: progress,
              twoMarkers: spec.twoMarkers,
              accent: skin.accent,
              track: skin.track),
        ),
      ),
      PvBreathingCircle(
        pattern: pattern,
        elapsed: seconds,
        tint: skin.accent,
        ink: skin.p.ink1,
        running: running,
        // ⚠️ A SQUARE FOR BOX BREATHING. "This one is naturally a square, not
        // a circle" — four equal phases around four equal sides.
        square: spec.square,
        size: 150,
        below: !running
            ? null
            : Column(mainAxisSize: MainAxisSize.min, children: [
                if (spec.countTo != null)
                  Text(
                      'Breath ${rounds.clamp(1, spec.countTo!)} of '
                      '${spec.countTo}',
                      style:
                          pvManrope(fontSize: 11.5, color: skin.p.ink2)),
                // ⚠️ THE SIDE, BECAUSE THE PRACTICE IS ABOUT WHICH SIDE.
                // Alternate nostril breathing with no indication of which
                // nostril is a diagram of ordinary breathing.
                if (spec.nostrils)
                  Text(
                      inhaling
                          ? (rounds.isOdd
                              ? 'In through the left'
                              : 'In through the right')
                          : (rounds.isOdd
                              ? 'Out through the right'
                              : 'Out through the left'),
                      style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: skin.p.ink2)),
              ]),
      ),
    ]);
  }
}

// =============================================================================
//  The other four
// =============================================================================

/// Attention moving down the body, one named part at a time.
class _BodyScan extends StatelessWidget {
  const _BodyScan(
      {required this.steps, required this.progress, required this.skin});
  final List<String> steps;
  final double progress;
  final TtcPracticeSkin skin;

  @override
  Widget build(BuildContext context) {
    // The first and last steps are settling in and coming out, so the scan
    // itself runs over the middle ones.
    final body = steps.length > 2 ? steps.sublist(1, steps.length - 1) : steps;
    final i = (progress * body.length).floor().clamp(0, body.length - 1);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // The shared figure — TTC drew it first, Kriya's relaxation reuses it.
      PvFigureHighlight(
        highlight: body.isEmpty ? 0 : i / body.length,
        accent: skin.accent,
        line: skin.track,
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: 260,
        child: Text(body.isEmpty ? '' : body[i],
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 13, height: 1.4, color: skin.p.ink1)),
      ),
    ]);
  }
}

/// A soft pulse and a ring. No audio is bundled — she brings her own.
class _Listen extends StatelessWidget {
  const _Listen(
      {required this.seconds, required this.progress, required this.skin});
  final double seconds;
  final double progress;
  final TtcPracticeSkin skin;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.85 + 0.15 * math.sin(seconds * 0.9);
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
            painter: _RingPainter(
                progress: progress,
                accent: skin.accent,
                track: skin.track)),
      ),
      Transform.scale(
        scale: pulse,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              skin.accent.withValues(alpha: 0.28),
              skin.accent.withValues(alpha: 0.04),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 96),
        child: Text('Play your own music',
            style: pvManrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: skin.p.ink2)),
      ),
    ]);
  }
}

/// A drawn figure when one exists, and an honest placeholder until then.
class _Figure extends StatelessWidget {
  const _Figure({required this.progress, required this.skin});
  final double progress;
  final TtcPracticeSkin skin;

  @override
  Widget build(BuildContext context) {
    // ⚠️ WHEN `assetPath` IS FILLED, A Rive OR Lottie PLAYER GOES HERE AND
    // NOTHING ELSE CHANGES. The path is read from the card's data exactly so
    // that dropping a file in is a data edit. The package is not added yet
    // because adding a dependency for six files that do not exist is how a
    // pubspec collects things nobody uses.
    //
    // ⚠️ WHAT THE PLACEHOLDER SHOWS WAS THE HALF THAT LOOKED UNFINISHED. It
    // was a grey icon and the sentence "Follow the steps below" -- an apology,
    // in the largest object on the screen, on six of the twelve cards. The mark
    // is now a wash rather than a subject, the ring it sits in is real
    // information, and the two words left are an instruction rather than a
    // notice about something missing. Nothing is invented: there is still no
    // figure here, and no pretending there is one.
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
            painter: _RingPainter(
                progress: progress,
                accent: skin.accent,
                track: skin.track)),
      ),
      Icon(Icons.self_improvement_rounded,
          size: 104, color: skin.accent.withValues(alpha: 0.10)),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Follow the steps',
            style: pvManrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: skin.p.ink2)),
        const SizedBox(height: 4),
        Text('as you go',
            style: pvManrope(fontSize: 12.5, color: skin.p.ink3)),
      ]),
    ]);
  }
}

/// Ten minutes, and nothing else.
class _PlainTimer extends StatelessWidget {
  const _PlainTimer(
      {required this.left, required this.progress, required this.skin});
  final int left;
  final double progress;
  final TtcPracticeSkin skin;

  @override
  Widget build(BuildContext context) {
    final m = left ~/ 60;
    final s = left % 60;
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
            painter: _RingPainter(
                progress: progress,
                accent: skin.accent,
                track: skin.track)),
      ),
      Text('$m:${s.toString().padLeft(2, '0')}',
          style: pvFraunces(
              fontSize: 40, fontWeight: FontWeight.w600, color: skin.p.ink1)),
    ]);
  }
}

// =============================================================================
//  Painters
// =============================================================================

class _RingPainter extends CustomPainter {
  const _RingPainter(
      {required this.progress,
      required this.accent,
      required this.track,
      this.twoMarkers = false});
  final double progress;
  final Color accent;
  final Color track;
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
          ..color = track);

    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = accent);

    // ⚠️ TWO MARKERS FOR THE ONE PRACTICE THAT IS FOR TWO PEOPLE. It is a small
    // thing and it is the only thing on screen that says "this one is not
    // yours alone" — which is the entire point of that card.
    final dots = twoMarkers ? 2 : 1;
    for (var i = 0; i < dots; i++) {
      final a = -math.pi / 2 + 2 * math.pi * progress + (i * 0.22);
      canvas.drawCircle(c + Offset(math.cos(a) * r, math.sin(a) * r), 6,
          Paint()..color = accent);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.twoMarkers != twoMarkers ||
      old.accent != accent ||
      old.track != track;
}

/// A body outline with one region lit. [highlight] runs 0 (head) → 1 (feet).
// ⚠️ MOVED TO `lib/widgets/figure_highlight.dart` as `PvFigurePainter`,
// 2026-09-12. Kept for revert.
// class _FigurePainter extends CustomPainter {
//   const _FigurePainter(
//       {required this.highlight, required this.accent, required this.line});
//   final double highlight;
//   final Color accent;
//   final Color line;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final stroke = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.4
//       ..strokeCap = StrokeCap.round
//       ..color = line;
//
//     final cx = size.width / 2;
//     final top = 14.0;
//     final bottom = size.height - 10;
//
//     // head, spine, arms, legs — deliberately schematic. It is a position
//     // indicator, not an anatomy drawing.
//     canvas.drawCircle(Offset(cx, top + 10), 10, stroke);
//     canvas.drawLine(Offset(cx, top + 22), Offset(cx, bottom - 34), stroke);
//     canvas.drawLine(Offset(cx - 26, top + 40), Offset(cx + 26, top + 40), stroke);
//     canvas.drawLine(
//         Offset(cx, bottom - 34), Offset(cx - 18, bottom), stroke);
//     canvas.drawLine(
//         Offset(cx, bottom - 34), Offset(cx + 18, bottom), stroke);
//
//     final y = top + (bottom - top) * highlight.clamp(0.0, 1.0);
//     canvas.drawCircle(
//         Offset(cx, y),
//         17,
//         Paint()..color = accent.withValues(alpha: 0.20));
//   }
//
//   @override
//   bool shouldRepaint(_FigurePainter old) =>
//       old.highlight != highlight ||
//       old.accent != accent ||
//       old.line != line;
// }

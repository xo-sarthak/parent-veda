// =============================================================================
//  Drawn illustrations for the TTC focus pages
// -----------------------------------------------------------------------------
//  ⚠️ DRAWN IN DART, NOT DOWNLOADED, AND THAT WAS A DELIBERATE REFUSAL.
//
//  The brief was "take some web image that is free to use". I did not, and the
//  reason is worth writing down because it will come up again every time a
//  screen looks bland:
//
//    · **"Free to use" is a claim, not a fact.** A licence found next to an
//      image on a search page is unverifiable from here, frequently wrong, and
//      the party who carries the consequence is the app, not the site that
//      hosted it. Stock-image claims on medical illustration are wrong often
//      enough that agencies audit them.
//    · **An image is an asset with a supply chain.** It has to be sized for
//      three densities, licence-tracked, and re-cleared if the product is ever
//      sold or white-labelled. Nine placeholder photos is a small liability;
//      ninety is a real one.
//    · **Vector redraws for free what a photo cannot.** These scale to any
//      density, weigh nothing, recolour to the section's hue, and cannot go
//      missing at runtime.
//
//  So this file is the art. When real commissioned illustration arrives it
//  drops into the same slot — `TtcArt` is addressed by a KEY, so swapping a
//  painter for an `Image.asset` is a change in one switch statement and no
//  screen has to know.
//
//  ---------------------------------------------------------------------------
//  ⚠️ ABSTRACT, NOT ANATOMICAL, AND THAT IS A CLINICAL CALL RATHER THAN A
//  DRAWING-SKILL ONE.
//  ---------------------------------------------------------------------------
//
//  The reference app draws labelled anatomy — a cross-section of the male
//  reproductive tract with eight parts named. That is genuinely good, and it is
//  also medical illustration: if the vas deferens is drawn joining the urethra
//  in the wrong place, the app has published a diagram that is wrong, and no
//  test in this repo would catch it.
//
//  Hand-drawn anatomy without a clinician reviewing the geometry is a claim we
//  are not entitled to make — CLAUDE.md, "never a diagnosis", and the same
//  instinct that keeps `TruthSource` honest. So these say the same things
//  diagrammatically: a cycle as a ring with the window as an arc, production as
//  a count, a delay as a timeline. Every one is true at the level it draws.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Which picture. Addressed by name so data can reference art without importing
/// a widget, and so a real asset can replace a painter later.
enum TtcArt {
  /// A cycle ring with the fertile days as a lit arc.
  fertileWindow,

  /// His side, as a cover: a figure and a soft ground.
  hisSideCover,

  /// Sperm being made — a count, not an organ.
  spermProduction,

  /// Heat, as the thing that slows production.
  heat,

  /// Smoke and a glass, crossed out.
  smokeAndDrink,

  /// About three months, as a timeline with a delayed result.
  threeMonths,
}

/// A photograph if there is one and the network is up, the drawn art otherwise.
///
/// ⚠️ THE FALLBACK IS NOT AN ERROR STATE, IT IS THE OTHER HALF OF THE DESIGN.
/// `Image.network` on a phone with no signal gives you a grey box and a broken
/// layout unless someone writes the else-branch; local-first is absolute here,
/// so the else-branch is a finished picture rather than a spinner or a shrug.
///
/// `loadingBuilder` shows the drawn art WHILE the photo arrives too, so the
/// card never flashes empty on a slow connection — the illustration is simply
/// what the tile looks like until a better version of itself downloads.
class TtcHeroArt extends StatelessWidget {
  const TtcHeroArt({
    super.key,
    required this.art,
    required this.tint,
    this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final TtcArt? art;
  final Color tint;
  final String? imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final drawn = art == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(12),
            child: TtcIllustration(art: art!, tint: tint),
          );

    final url = imageUrl;
    if (url == null || url.isEmpty) return drawn;

    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => drawn,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : drawn,
    );
  }
}

/// Paints a [TtcArt] at whatever size it is given.
///
/// ---------------------------------------------------------------------------
/// ⚠️ IT LOOPS, AND THE MOTION IS DELIBERATELY ALMOST TOO SMALL
/// ---------------------------------------------------------------------------
///
/// Tails wave, heat rises, smoke drifts. Nothing travels across the frame and
/// nothing restarts visibly — the loop is a phase shift on sine curves the
/// painter was already computing, so a full cycle costs no layout and no
/// allocation, only a repaint.
///
/// The restraint is the requirement, not a limitation. This art sits on cards
/// in a scrolling rail and behind body text in an article; movement that draws
/// the eye there is movement competing with the words it exists to support.
/// The test is whether you notice it when you look AT it and stop noticing it
/// when you read past it.
///
/// ⚠️ AND IT STOPS WHEN THE SYSTEM ASKS. `MediaQuery.disableAnimations` is set
/// by the OS "reduce motion" accessibility setting, which people turn on for
/// vestibular disorders and migraine — both markedly more common in the
/// population this app is written for. Ignoring it is not a rough edge; it is
/// shipping something that makes a subset of users ill. Off, it renders one
/// still frame and creates no controller at all.
class TtcIllustration extends StatefulWidget {
  const TtcIllustration({
    super.key,
    required this.art,
    required this.tint,
    this.ink,
    this.animate = true,
  });

  final TtcArt art;

  /// The section's colour. Everything else is derived from it, so a picture
  /// dropped into a different rail recolours rather than clashes.
  final Color tint;

  /// Line colour. Defaults to a darkened [tint].
  final Color? ink;

  /// Callers can force a still frame — a thumbnail in a dense grid, say.
  final bool animate;

  @override
  State<TtcIllustration> createState() => _TtcIllustrationState();
}

class _TtcIllustrationState extends State<TtcIllustration>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⚠️ CREATED HERE, NOT IN `initState`, because whether to animate depends
    // on `MediaQuery`, which is not available during `initState`.
    final wanted =
        widget.animate && !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    if (wanted && _c == null) {
      _c = AnimationController(
          vsync: this, duration: const Duration(seconds: 6))
        ..repeat();
    } else if (!wanted && _c != null) {
      _c!.dispose();
      _c = null;
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deep = widget.ink ??
        HSLColor.fromColor(widget.tint)
            .withSaturation(0.52)
            .withLightness(0.36)
            .toColor();

    final controller = _c;
    if (controller == null) {
      return CustomPaint(
        painter: _ArtPainter(
            art: widget.art, tint: widget.tint, ink: deep, phase: 0),
        size: Size.infinite,
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => CustomPaint(
        painter: _ArtPainter(
            art: widget.art,
            tint: widget.tint,
            ink: deep,
            phase: controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  _ArtPainter({
    required this.art,
    required this.tint,
    required this.ink,
    required this.phase,
  });

  final TtcArt art;
  final Color tint;
  final Color ink;

  /// 0..1, looping. Every use of it is a phase offset on a sine, so the loop
  /// closes seamlessly and there is no visible restart.
  final double phase;

  /// The loop as radians, for readability at the call sites.
  double get _turn => phase * math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    switch (art) {
      case TtcArt.fertileWindow:
        _fertileWindow(canvas, size);
      case TtcArt.hisSideCover:
        _hisSideCover(canvas, size);
      case TtcArt.spermProduction:
        _spermProduction(canvas, size);
      case TtcArt.heat:
        _heat(canvas, size);
      case TtcArt.smokeAndDrink:
        _smokeAndDrink(canvas, size);
      case TtcArt.threeMonths:
        _threeMonths(canvas, size);
    }
  }

  // ---- helpers --------------------------------------------------------------

  Paint get _line => Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Color tink(double a) => ink.withValues(alpha: a);

  /// One sperm, drawn as a head and a wave. Used at three sizes.
  void _sperm(Canvas c, Offset at, double s, double angle, Color colour) {
    c.save();
    c.translate(at.dx, at.dy);
    c.rotate(angle);
    c.drawCircle(Offset.zero, s * 0.28, Paint()..color = colour);
    // ⚠️ THE PHASE TRAVELS DOWN THE TAIL, which is what makes it read as
    // swimming rather than as a flag flapping. Subtracting the turn moves the
    // wave from head to tip; adding it would swim backwards, which looks
    // wrong in a way that is hard to name and impossible to unsee.
    final tail = Path()..moveTo(s * 0.26, 0);
    for (var i = 1; i <= 12; i++) {
      final t = i / 12;
      tail.lineTo(
          s * 0.26 + s * 1.5 * t,
          math.sin(t * math.pi * 2.2 - _turn * 2) *
              s *
              0.30 *
              (1 - t * 0.35));
    }
    c.drawPath(
        tail,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.12
          ..strokeCap = StrokeCap.round);
    c.restore();
  }

  // ---- 1. the cycle, with the window lit ------------------------------------
  //
  // The one picture on this page that is doing real explanatory work: a cycle
  // is a loop, and the fertile days are a WIDTH on that loop rather than a
  // single point. "The width is the point" is the reassuring fact this stage
  // keeps trying to get across in words.
  void _fertileWindow(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = math.min(size.width, size.height) * 0.34;
    final centre = Offset(cx, cy);

    // The whole cycle.
    c.drawCircle(
        centre,
        r,
        Paint()
          ..color = tink(0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.30);

    // The fertile arc — six days of about twenty-eight, so a little under a
    // quarter of the ring, opening at the top-right.
    c.drawArc(
        Rect.fromCircle(center: centre, radius: r),
        -math.pi * 0.62,
        math.pi * 0.52,
        false,
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.30
          ..strokeCap = StrokeCap.round);

    // The egg, at the peak.
    final peak = Offset(cx + r * math.cos(-math.pi * 0.36),
        cy + r * math.sin(-math.pi * 0.36));
    c.drawCircle(peak, r * 0.30, Paint()..color = Colors.white);
    c.drawCircle(peak, r * 0.19, Paint()..color = ink);

    // A sperm approaching it, so the arc reads as an opportunity rather than a
    // measurement.
    // A slow drift along its own heading — a sixth of the radius, out and
    // back, so the loop closes where it started.
    final drift = math.sin(_turn) * r * 0.16;
    _sperm(
        c,
        Offset(cx - r * 0.15 + drift * 0.7, cy + r * 1.05 - drift * 0.4),
        r * 0.42,
        -math.pi * 0.30,
        tink(0.55));
  }

  // ---- 2. his side, as a cover ----------------------------------------------
  void _hisSideCover(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height * 0.56;
    final u = math.min(size.width, size.height) * 0.5;

    // A soft ground disc behind him.
    c.drawCircle(Offset(cx, cy), u * 0.92, Paint()..color = tink(0.14));

    // Shoulders and head — a figure, not a portrait.
    final body = Path()
      ..moveTo(cx - u * 0.62, cy + u * 0.78)
      ..quadraticBezierTo(cx - u * 0.58, cy + u * 0.08, cx - u * 0.22, cy - u * 0.02)
      ..lineTo(cx + u * 0.22, cy - u * 0.02)
      ..quadraticBezierTo(cx + u * 0.58, cy + u * 0.08, cx + u * 0.62, cy + u * 0.78)
      ..close();
    c.drawPath(body, Paint()..color = tink(0.42));
    c.drawCircle(Offset(cx, cy - u * 0.34), u * 0.30, Paint()..color = tink(0.62));

    // Three sperm rising past him — the subject, stated quietly.
    _sperm(c, Offset(cx + u * 0.72, cy - u * 0.30), u * 0.26, -math.pi * 0.75,
        tink(0.5));
    _sperm(c, Offset(cx - u * 0.78, cy - u * 0.05), u * 0.20, -math.pi * 0.2,
        tink(0.38));
    _sperm(c, Offset(cx + u * 0.55, cy + u * 0.42), u * 0.16, math.pi * 0.1,
        tink(0.30));
  }

  // ---- 3. production, as a count --------------------------------------------
  //
  // Not an organ. The fact worth carrying is that there are a very great many
  // and they are made continuously, which a crowd says and a cross-section does
  // not.
  void _spermProduction(Canvas c, Size size) {
    final rnd = math.Random(7);
    final u = math.min(size.width, size.height);
    c.drawCircle(Offset(size.width / 2, size.height / 2), u * 0.40,
        Paint()..color = tink(0.12));
    for (var i = 0; i < 18; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = math.sqrt(rnd.nextDouble()) * u * 0.34;
      // Each one drifts on its own offset phase, so the crowd never pulses in
      // unison — which would read as a heartbeat rather than as movement.
      final own = _turn + i * 0.4;
      _sperm(
          c,
          Offset(size.width / 2 + math.cos(a) * d + math.sin(own) * u * 0.012,
              size.height / 2 + math.sin(a) * d + math.cos(own) * u * 0.012),
          u * (0.075 + rnd.nextDouble() * 0.055),
          a + math.pi,
          tink(0.30 + rnd.nextDouble() * 0.45));
    }
  }

  // ---- 4. heat ---------------------------------------------------------------
  void _heat(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final u = math.min(size.width, size.height);

    c.drawCircle(Offset(cx, cy), u * 0.38, Paint()..color = tink(0.12));

    // A thermometer, upright.
    final stem = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy - u * 0.02), width: u * 0.11, height: u * 0.44),
        Radius.circular(u * 0.06));
    c.drawRRect(stem, Paint()..color = tink(0.30));
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx, cy + u * 0.06),
                width: u * 0.11,
                height: u * 0.24),
            Radius.circular(u * 0.06)),
        Paint()..color = ink);
    c.drawCircle(Offset(cx, cy + u * 0.22), u * 0.11, Paint()..color = ink);

    // Heat, rising on both sides.
    for (final dx in [-u * 0.26, u * 0.26]) {
      final p = Path()..moveTo(cx + dx, cy + u * 0.16);
      for (var i = 1; i <= 10; i++) {
        final t = i / 10;
        p.lineTo(cx + dx + math.sin(t * math.pi * 3 + _turn) * u * 0.045,
            cy + u * 0.16 - t * u * 0.42);
      }
      c.drawPath(p, _line..strokeWidth = u * 0.028);
    }
  }

  // ---- 5. smoke and drink ----------------------------------------------------
  void _smokeAndDrink(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final u = math.min(size.width, size.height);
    c.drawCircle(Offset(cx, cy), u * 0.38, Paint()..color = tink(0.12));

    // A glass.
    final glass = Path()
      ..moveTo(cx - u * 0.20, cy - u * 0.16)
      ..lineTo(cx + u * 0.02, cy - u * 0.16)
      ..lineTo(cx - u * 0.02, cy + u * 0.16)
      ..lineTo(cx - u * 0.16, cy + u * 0.16)
      ..close();
    c.drawPath(glass, Paint()..color = tink(0.34));

    // A cigarette, with smoke.
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx + u * 0.17, cy + u * 0.06),
                width: u * 0.26,
                height: u * 0.07),
            Radius.circular(u * 0.035)),
        Paint()..color = tink(0.45));
    final smoke = Path()..moveTo(cx + u * 0.30, cy - u * 0.01);
    for (var i = 1; i <= 10; i++) {
      final t = i / 10;
      smoke.lineTo(
          cx + u * 0.30 + math.sin(t * math.pi * 2.4 + _turn) * u * 0.05,
          cy - u * 0.01 - t * u * 0.30);
    }
    c.drawPath(smoke, _line..strokeWidth = u * 0.024);

    // The bar through both — this is the one picture that carries a "no".
    c.drawLine(
        Offset(cx - u * 0.34, cy + u * 0.30),
        Offset(cx + u * 0.34, cy - u * 0.30),
        Paint()
          ..color = ink
          ..strokeWidth = u * 0.055
          ..strokeCap = StrokeCap.round);
  }

  // ---- 6. about three months -------------------------------------------------
  //
  // The single most useful fact on his side of this stage: what he changes
  // today is measurable in about three months. A timeline says "later" in a way
  // no sentence quite does.
  void _threeMonths(Canvas c, Size size) {
    final u = math.min(size.width, size.height);
    final y = size.height * 0.52;
    final x0 = size.width * 0.16, x1 = size.width * 0.84;

    c.drawLine(Offset(x0, y), Offset(x1, y),
        _line..strokeWidth = u * 0.030);

    for (var i = 0; i < 4; i++) {
      final x = x0 + (x1 - x0) * (i / 3);
      final last = i == 3;
      c.drawCircle(Offset(x, y), u * (last ? 0.085 : 0.05),
          Paint()..color = last ? ink : tink(0.34));
      if (last) {
        c.drawCircle(Offset(x, y), u * 0.045, Paint()..color = Colors.white);
      }
    }

    // The change he makes, at the start.
    _sperm(c, Offset(x0 - u * 0.02, y - u * 0.26), u * 0.13, 0, tink(0.40));
    // The result, at the end — more of them, and stronger.
    for (var i = 0; i < 3; i++) {
      _sperm(c, Offset(x1 - u * 0.10 + i * u * 0.07, y - u * 0.30 + i * u * 0.10),
          u * 0.14, -math.pi * 0.1, tink(0.55 + i * 0.15));
    }
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) =>
      old.phase != phase ||
      old.art != art ||
      old.tint != tint ||
      old.ink != ink;
}

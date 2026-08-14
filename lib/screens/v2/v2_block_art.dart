// =============================================================================
//  V2BlockArt — the six door marks, drawn rather than generated
// -----------------------------------------------------------------------------
//  WHY VECTORS INSTEAD OF THE RENDERED OBJECTS.
//
//  The generated set kept failing in ways no re-prompt fixed. Two of the six
//  came back as several objects in one picture (two paper stacks, three play
//  cards) because the prompt asked for variations. All six came back cream,
//  because the prompt never specified colour. And all six landed in the soft-
//  clay 3D style that every image model produces right now — which is the same
//  problem as the purple gradient: not ugly, just unmistakably machine-made.
//
//  Drawing them solves all three at once and adds things generation cannot:
//
//    · ONE HAND. Same geometry, same stroke, same corner treatment, always.
//    · PALETTE-AWARE. They take their ink from the ground they sit on, so all
//      five palettes stay coherent without six more exports each.
//    · WEIGHTLESS. No PNGs, no 668KB, no double-padding, nothing to re-crop.
//
//  THE TRADE, STATED HONESTLY: these are flatter and more graphic than the
//  render objects. Less tactile. Whether that is better is a taste question the
//  phone answers faster than an argument, which is why both sets exist behind a
//  toggle rather than one replacing the other.
//
//  Drawing rules, so a seventh mark added later still belongs:
//    · One stroke weight, scaled from the tile.
//    · Round caps and joins everywhere — the wordmark is soft, so this is too.
//    · No fills except where an object is genuinely solid.
//    · Everything inside a 100x100 space, scaled by the painter.
// =============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum V2Mark { practice, week, scan, read, watch, ask }

class V2BlockArt extends StatelessWidget {
  const V2BlockArt(
      {super.key, required this.mark, required this.tint, required this.ink});

  final V2Mark mark;

  /// THE TILE'S OWN PASTEL, and the mark derives everything from it.
  ///
  /// ⚠️ THE FIRST RESTYLE FAILED HERE, and the failure is the useful part. It
  /// took one colour — `ink` at 72% — and filled every shape with it, so all
  /// six marks came out as grey lumps on six different pastels. Compared with
  /// the tip card's sky, which was liked, the missing ingredient was obvious in
  /// hindsight and invisible in the code: **the sky has a warm SATURATED focal
  /// object against a pale ground.** The sun is the picture. Remove it and you
  /// have hills.
  ///
  /// So the mark now builds a three-tone set out of this one pastel:
  ///   · the tile itself stays the pale sky,
  ///   · `_seed` — the same hue at full strength — is the focal object,
  ///   · `_land` — that hue carried halfway to ink — is the ground.
  /// Which means each door is its own colour rather than six greys, and it
  /// happens automatically for a seventh tile added later.
  final Color tint;

  /// Only for the ground mix and fine detail. Never the fill of the object —
  /// that was the whole mistake.
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final h = HSLColor.fromColor(tint);
    // Saturation and lightness are FIXED, hue is not: the controlled-pastel
    // rule from DESIGN-LAYER §4a, applied one step darker. Six hues at one
    // saturation still read as one system; six saturations do not.
    final seed = h.withSaturation(0.46).withLightness(0.46).toColor();
    return CustomPaint(
        painter: _MarkPainter(mark, seed, Color.lerp(seed, ink, 0.45)!),
        size: Size.infinite);
  }
}

/// Exposed for the offline preview recipe documented in v3_tip_art.dart — six
/// marks judged side by side beats six builds and six days.
CustomPainter blockMarkPainter(V2Mark m, Color seed, Color land) =>
    _MarkPainter(m, seed, land);

/// -----------------------------------------------------------------------------
///  RESTYLED to the language the tip card's sky established, because that one
///  was liked and the outline version was not.
///
///  The originals were pure outline: 3.4px strokes, no fills, floating in the
///  middle of a tinted square. Outline-only reads as DIAGRAM — an exploded view
///  in a manual — and a diagram is something you study, not a door you push.
///  The sky reads as a picture because it is filled shapes, layered front to
///  back, with one saturated focal object.
///
///  Two moves transfer, and they are the whole restyle:
///
///  1. ONE FILLED FOCAL SHAPE per mark, in the tile's own hue at full strength.
///     Fill is what separates picture from diagram.
///  2. LINE ONLY FOR DETAIL — and barely any, because line was carrying the
///     mark before and is now supporting a fill.
///
///  A third move was tried and REVERSED: a shared ground band at the foot of
///  every tile. See the note in paint(). It copied the sky's hills rather than
///  the sky's atmosphere, and it forced a book and an ultrasound strip to
///  pretend they were outdoors.
///
///  AND THEY ARE BIGGER. The old authoring kept everything inside roughly the
///  middle 60% of the box, so after the grid's padding the object took about
///  half the tile and read as timid.
///
///  Rules, so a seventh mark added later still belongs:
///    · Authored in a 100x100 box, scaled by the painter.
///    · The halo runs first, always. It is what the set shares now.
///    · One filled focal object in `seed`, centred on the box. Detail in
///      `land` or in white. Never mix the two roles.
class _MarkPainter extends CustomPainter {
  _MarkPainter(this.mark, this.seed, this.land);

  final V2Mark mark;

  /// The focal object. Full strength, one per mark.
  final Color seed;

  /// The ground it stands on. Never used for the object.
  final Color land;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final s = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);

    Paint obj([double a = 0.92]) => Paint()..color = seed.withValues(alpha: a);
    Paint hair(Color c, [double w = 2.3]) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c;

    // ---- THE LAND IS GONE, and taking it out was the right call -----------
    //
    // Two overlapping rises used to sit at the foot of every mark, carried over
    // from the tip card's sky on the theory that a shared horizon is what made
    // six marks read as one set. That was a literal reading of the wrong thing:
    // what worked about the sky was its ATMOSPHERE — one lit object with air
    // around it — not the hills specifically. Repeating a landscape under a
    // book, a play button and an ultrasound strip made six pictures that had to
    // pretend to be outdoors, which is a costume, not a system.
    //
    // What replaces it does the same job without the fiction:
    //   · the tile's own gradient well (see v2_block_grid) gives the object a
    //     lit top and a settled foot, which is what the horizon was really for;
    //   · a soft halo behind each object grounds it without a floor.
    // The set still reads as one hand — same fills, same weights, same halo —
    // and none of them has to be a place.
    canvas.drawCircle(
      Offset(50 * s, 50 * s),
      42 * s,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(50 * s, 50 * s),
          42 * s,
          [land.withValues(alpha: 0.20), land.withValues(alpha: 0.0)],
          [0.25, 1.0],
        ),
    );

    switch (mark) {
      // ⚠️ WAS A LUMP. Cloth draped over a rise read as a rock, because a
      // filled curve with a flat bottom IS a rock whatever the curve does.
      // Practice is a still moment, so: a stone dropped in water. Reads at
      // 110dp, and it keeps the old mark's one exemption — still the only mark
      // with no straight line anywhere in it.
      case V2Mark.practice:
        // The ripple version was closer, but concentric ellipses around a disc
        // read as an ORBIT — atom, loading spinner, radio button. Three petals
        // read as one thing and nothing else, and a lotus is Indian in form
        // rather than in applied motif, which is the twice-sourced rule from
        // DESIGN-LAYER §4 doing its job.
        void petal(double turns, double alpha) {
          canvas.save();
          canvas.translate(50 * s, 78 * s);
          canvas.rotate(turns);
          canvas.drawPath(
            Path()
              ..moveTo(0, 0)
              ..quadraticBezierTo(-19 * s, -30 * s, 0, -54 * s)
              ..quadraticBezierTo(19 * s, -30 * s, 0, 0)
              ..close(),
            obj(alpha),
          );
          canvas.restore();
        }

        petal(-0.72, 0.42);
        petal(0.72, 0.42);
        petal(0, 0.92);

      // Seed pod with a seam: growth, and about to open. The one shape that
      // survived both restyles unchanged.
      case V2Mark.week:
        canvas.drawPath(
          Path()
            ..moveTo(50 * s, 8 * s)
            ..cubicTo(90 * s, 30 * s, 90 * s, 62 * s, 50 * s, 84 * s)
            ..cubicTo(10 * s, 62 * s, 10 * s, 30 * s, 50 * s, 8 * s)
            ..close(),
          obj(),
        );
        canvas.drawLine(Offset(50 * s, 18 * s), Offset(50 * s, 74 * s),
            hair(Colors.white.withValues(alpha: 0.5), 2.2));

      // Ultrasound strip: three frames on a tape, the middle one exposed. The
      // only mark with hard corners, because it is the only clinical one — the
      // same reason Scans is the only cool tile in v2_palette.dart.
      case V2Mark.scan:
        canvas.drawLine(Offset(19 * s, 8 * s), Offset(19 * s, 80 * s),
            hair(seed.withValues(alpha: 0.45), 2.4));
        for (var i = 0; i < 3; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(29 * s, (9 + i * 24) * s, 56 * s, 18 * s),
              Radius.circular(3 * s),
            ),
            i == 1 ? obj() : obj(0.26),
          );
        }

      // ⚠️ WAS A HANDBAG. A filled rectangle with an arc rising off its top
      // edge is a handbag, and no amount of intent changes that. An OPEN BOOK
      // is the shape everyone already reads: two pages meeting at a spine, the
      // near one darker so it has depth instead of symmetry.
      case V2Mark.read:
        canvas.drawPath(
          Path()
            ..moveTo(50 * s, 28 * s)
            ..quadraticBezierTo(30 * s, 17 * s, 9 * s, 23 * s)
            ..lineTo(9 * s, 63 * s)
            ..quadraticBezierTo(30 * s, 57 * s, 50 * s, 68 * s)
            ..close(),
          obj(0.5),
        );
        canvas.drawPath(
          Path()
            ..moveTo(50 * s, 28 * s)
            ..quadraticBezierTo(70 * s, 17 * s, 91 * s, 23 * s)
            ..lineTo(91 * s, 63 * s)
            ..quadraticBezierTo(70 * s, 57 * s, 50 * s, 68 * s)
            ..close(),
          obj(),
        );

      // ⚠️ WAS THE YOUTUBE LOGO. A wide rounded rectangle with a triangle
      // knocked out of it stopped being a generic play symbol years ago — it is
      // one company's mark, and borrowing it on the tile that opens OUR video
      // is the worst possible place for it. A disc with the triangle knocked
      // out reads as play everywhere and belongs to nobody.
      case V2Mark.watch:
        canvas.drawPath(
          Path.combine(
            PathOperation.difference,
            Path()
              ..addOval(Rect.fromCircle(
                  center: Offset(50 * s, 50 * s), radius: 31 * s)),
            Path()
              ..moveTo(41 * s, 35 * s)
              ..lineTo(70 * s, 50 * s)
              ..lineTo(41 * s, 65 * s)
              ..close(),
          ),
          obj(),
        );

      // Two pebbles, one behind the other — a conversation, not a question
      // mark and not a speech bubble.
      case V2Mark.ask:
        canvas.drawOval(
            Rect.fromLTWH(44 * s, 10 * s, 48 * s, 42 * s), obj(0.34));
        canvas.drawOval(Rect.fromLTWH(9 * s, 32 * s, 54 * s, 46 * s), obj());
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.mark != mark || old.seed != seed || old.land != land;
}

/// Which set of door marks the grid draws.
///
/// PERSISTED, unlike the palette bar, and the difference is deliberate.
///
/// The palette bar resets each launch so nobody opens the app days later in an
/// experimental ground and reports its colours as the product's. That argument
/// does not transfer here: this control only exists INSIDE V3, which is already
/// a screen you have to opt into, so there is no state to protect anyone from.
/// Not persisting it just meant a choice was thrown away every relaunch —
/// which reads as the toggle not working at all.
class V2BlockArtMode extends ChangeNotifier {
  V2BlockArtMode._() {
    _load();
  }
  static final V2BlockArtMode instance = V2BlockArtMode._();

  static const _key = 'v3_block_art_vector';

  bool _vector = false;
  bool get vector => _vector;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_key);
    if (v != null && v != _vector) {
      _vector = v;
      notifyListeners();
    }
  }

  Future<void> set(bool v) async {
    if (v == _vector) return;
    _vector = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, v);
  }
}

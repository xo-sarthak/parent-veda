// =============================================================================
//  Memories — the templates
// -----------------------------------------------------------------------------
//  Every template lays the whole card out itself; the parent only supplies the
//  words and a photo. Built entirely in Flutter (gradients, drawn florals,
//  typography) so there are no image assets to ship and each one is crisp at
//  any export size. A template = an archetype (a layout) dressed in a palette.
//  Adding one is a single entry in [kMemoryTemplates].
// =============================================================================

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'memory_models.dart';
import '../localization/app_language.dart';
import '../theme/pv_fonts.dart';

// ---------------------------------------------------------------------------
//  Palettes — calm, timeless colour worlds
// ---------------------------------------------------------------------------

const _blush = MemoryPalette(
  bg: [Color(0xFFFDF3F5), Color(0xFFF7E2E8)],
  ink: Color(0xFF4A2B33), soft: Color(0xFF9B7680),
  accent: Color(0xFFDD8496), panel: Color(0xFFFFFFFF),
);
const _sage = MemoryPalette(
  bg: [Color(0xFFF1F5F0), Color(0xFFE1EBDE)],
  ink: Color(0xFF33402F), soft: Color(0xFF74836C),
  accent: Color(0xFF88A87C), panel: Color(0xFFFFFFFF),
);
const _terracotta = MemoryPalette(
  bg: [Color(0xFFFBF0E6), Color(0xFFF4DDC6)],
  ink: Color(0xFF5A3A24), soft: Color(0xFF9B7355),
  accent: Color(0xFFC8792B), panel: Color(0xFFFFF8F0),
);
const _midnight = MemoryPalette(
  bg: [Color(0xFF211D33), Color(0xFF322C4A)],
  ink: Color(0xFFFFFFFF), soft: Color(0xFFBDB6D0),
  accent: Color(0xFFCBA968), panel: Color(0xFF35304C),
);
const _cream = MemoryPalette(
  bg: [Color(0xFFFAF7F1), Color(0xFFEFE8DC)],
  ink: Color(0xFF3A352E), soft: Color(0xFF857D70),
  accent: Color(0xFFB9A98D), panel: Color(0xFFFFFFFF),
);
const _lavender = MemoryPalette(
  bg: [Color(0xFFF5F1FB), Color(0xFFE8DFF6)],
  ink: Color(0xFF3A2D4E), soft: Color(0xFF7E6F94),
  accent: Color(0xFF9B7ACB), panel: Color(0xFFFFFFFF),
);
const _sky = MemoryPalette(
  bg: [Color(0xFFEFF5FA), Color(0xFFDCEAF4)],
  ink: Color(0xFF25384A), soft: Color(0xFF6C8194),
  accent: Color(0xFF6FA8CF), panel: Color(0xFFFFFFFF),
);

// Added for the reference-inspired set. Ivory/gold is the announcement-card
// default across every sample: warm paper, one metallic line, nothing else.
const _ivory = MemoryPalette(
  bg: [Color(0xFFFCFAF6)],
  ink: Color(0xFF2E2A24), soft: Color(0xFF8A8175),
  accent: Color(0xFFC0A268), panel: Color(0xFFFFFFFF),
);
// Porcelain: the engraved-toile look — one ink colour on unbleached paper.
const _porcelain = MemoryPalette(
  bg: [Color(0xFFF7F4EC)],
  ink: Color(0xFF2F4A63), soft: Color(0xFF7C93A8),
  accent: Color(0xFF5B7FA3), panel: Color(0xFFFFFFFF),
);
// Powder: the sky/cloud card. Two blues and nothing sharp.
const _powder = MemoryPalette(
  bg: [Color(0xFFE9F2FA), Color(0xFFCFE3F3)],
  ink: Color(0xFF1F3A57), soft: Color(0xFF5E7C99),
  accent: Color(0xFF7FB2DA), panel: Color(0xFFFFFFFF),
);

// ---------------------------------------------------------------------------
//  Per-type copy
// ---------------------------------------------------------------------------

String _eyebrow(MemoryData d) =>
    d.type == MemoryType.expecting ? "WE'RE EXPECTING" : 'WELCOME';

String _title(MemoryData d) {
  if (d.type == MemoryType.expecting) {
    return d.coupleNames.trim().isNotEmpty
        ? d.coupleNames.trim()
        : S.now.uiMemoryBabyOnTheWay;
  }
  return d.babyName.trim().isNotEmpty
      ? d.babyName.trim()
      : S.now.uiMemoryOurLittleOne;
}

/// Small stat lines under the title (birth details / due month).
List<String> _details(MemoryData d) {
  if (d.type == MemoryType.expecting) {
    return [if (d.dueMonth.trim().isNotEmpty) 'Arriving ${d.dueMonth.trim()}'];
  }
  return [
    [
      if (d.birthDate.trim().isNotEmpty) d.birthDate.trim(),
      if (d.birthTime.trim().isNotEmpty) d.birthTime.trim(),
    ].join(' · '),
    [
      if (d.weight.trim().isNotEmpty) d.weight.trim(),
      if (d.length.trim().isNotEmpty) d.length.trim(),
    ].join(' · '),
  ].where((s) => s.isNotEmpty).toList();
}

String _footerNames(MemoryData d) =>
    d.type == MemoryType.expecting ? '' : d.parentNames.trim();

// ---------------------------------------------------------------------------
//  Shared pieces
// ---------------------------------------------------------------------------

TextStyle _serif(double s, Color c, {FontWeight w = FontWeight.w500, double h = 1.08}) =>
    pvFraunces(fontSize: s, color: c, fontWeight: w, height: h, letterSpacing: -0.3);

TextStyle _sans(double s, Color c, {FontWeight w = FontWeight.w500, double ls = 0}) =>
    pvManrope(fontSize: s, color: c, fontWeight: w, letterSpacing: ls);

/// Devanagari anywhere in the string.
///
/// Not "is the app in Hindi" — this asks about THIS text. The name on a
/// keepsake card is whatever the mother typed, and she can type Devanagari
/// while reading the app in English, or a Latin name while reading it in
/// Hindi. The font has to follow the characters, not the setting.
final RegExp _devanagari = RegExp('[ऀ-ॿ]');

/// Calligraphy. Every announcement card in the reference set leans on a script
/// for exactly one phrase — the name, or "Coming Soon" — and sets everything
/// else in small caps. Used the same way here: one script line per card, never
/// two, because two scripts on one card is where a keepsake starts to look like
/// a template.
///
/// PARISIENNE HAS NO DEVANAGARI, and there is no calligraphic Devanagari face
/// in the bundle to swap in — script faces for the script are rare and none
/// carries the weight range the rest of this file assumes. So a Devanagari name
/// falls back to the serif, which IS Devanagari-aware (Noto Serif Devanagari
/// via pvFraunces).
///
/// Losing the calligraphy is a real cost, and it is the smaller one. Without
/// this the card renders the mother's own baby's name in whatever the platform
/// substitutes — tofu boxes on some devices — on the one screen in the app she
/// is most likely to screenshot and send to her family.
TextStyle _script(double s, Color c, {double h = 1.0, String? forText}) {
  if (forText != null && _devanagari.hasMatch(forText)) {
    return pvFraunces(
      fontSize: s * 0.92,   // the serif runs larger on the body; match the eye
      color: c,
      height: h < 1.3 ? 1.35 : h,   // matras need the room, as in pv_fonts
      fontWeight: FontWeight.w500,
    );
  }
  return GoogleFonts.parisienne(fontSize: s, color: c, height: h);
}

/// The script version of the title. Falls back to the serif when the name is
/// long enough that calligraphy stops being readable — a nine-letter name in
/// Parisienne is beautiful, a twenty-eight character couple line is not.
Widget _scriptTitle(MemoryData d, MemoryPalette p, double size, {Color? color}) {
  final t = _title(d);
  final long = t.length > 18;
  return Text(
    t,
    textAlign: TextAlign.center,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: long
        ? _serif(size * 0.62, color ?? p.ink, w: FontWeight.w500)
        : _script(size, color ?? p.ink, h: 1.15, forText: t),
  );
}

/// A small-caps line with a hairline either side. The reference cards use this
/// to carry the date without letting it compete with the name.
Widget _ruledLine(String text, MemoryPalette p, {Color? color, double gap = 10}) {
  if (text.trim().isEmpty) return const SizedBox.shrink();
  final c = color ?? p.soft;
  Widget rule() => Expanded(
      child: Container(height: 0.8, color: c.withValues(alpha: 0.45)));
  return Row(children: [
    rule(),
    // Flexible, not a bare Padding: "12 December 2026 · 6:40 AM" in tracked-out
    // caps is wider than the card, and two Expanded rules either side leave the
    // centre nothing to give. Unconstrained it overflowed by 21px to the right.
    Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: Text(text.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _sans(9.5, c, w: FontWeight.w700, ls: 2.2)),
      ),
    ),
    rule(),
  ]);
}

Widget _eyebrowText(MemoryData d, MemoryPalette p, {Color? color}) => Text(
      _eyebrow(d),
      style: _sans(11, color ?? p.accent, w: FontWeight.w800, ls: 3.2),
    );

Widget _titleText(MemoryData d, MemoryPalette p, double size, {Color? color}) => Text(
      _title(d),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: _serif(size, color ?? p.ink, w: FontWeight.w600),
    );

Widget _detailText(MemoryData d, MemoryPalette p, {Color? color}) {
  final lines = _details(d);
  if (lines.isEmpty) return const SizedBox.shrink();
  return Column(mainAxisSize: MainAxisSize.min, children: [
    for (final l in lines)
      Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(l,
            textAlign: TextAlign.center,
            style: _sans(11.5, color ?? p.soft, w: FontWeight.w600)),
      ),
  ]);
}

Widget _messageText(MemoryData d, MemoryPalette p, {Color? color}) {
  final m = d.message.trim();
  if (m.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 44),
    child: Text('“$m”',
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: _serif(13, (color ?? p.soft), w: FontWeight.w400, h: 1.5)
            .copyWith(fontStyle: FontStyle.italic)),
  );
}

Widget _footer(MemoryData d, MemoryPalette p, {Color? color}) {
  final names = _footerNames(d);
  final c = color ?? p.soft;
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Expanded(
      child: Text(names,
          style: _sans(10, c, w: FontWeight.w700, ls: 0.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    ),
    // Subtle brand mark — a keepsake, not an ad.
    Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.eco_rounded, size: 9, color: c.withValues(alpha: 0.7)),
      const SizedBox(width: 3),
      Text('ParentVeda',
          style: _sans(8.5, c.withValues(alpha: 0.7), w: FontWeight.w700, ls: 0.3)),
    ]),
  ]);
}

/// The photo, panned/zoomed inside a fixed frame. Shape is a circle or a
/// rounded rectangle; the parent's transform only moves within it.
Widget _photo(MemoryPhoto? photo, {required double w, required double h, bool circle = false, Color? ring}) {
  final radius = circle ? BorderRadius.circular(w) : BorderRadius.circular(18);
  Widget inner;
  if (photo == null) {
    inner = const SizedBox.shrink();
  } else {
    inner = ClipRRect(
      borderRadius: radius,
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Transform.translate(
          offset: photo.offset,
          child: Transform.scale(
            scale: photo.scale,
            child: Image.file(File(photo.path), width: w, height: h, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
  return Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      borderRadius: radius,
      border: ring != null ? Border.all(color: ring, width: 3) : null,
    ),
    clipBehavior: Clip.antiAlias,
    child: inner,
  );
}

Widget _bg(MemoryPalette p, MemoryFormat f, Widget child, {CustomPainter? deco}) => SizedBox(
      width: f.size.width,
      height: f.size.height,
      child: Stack(children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: p.bg.length > 1
                  ? LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight, colors: p.bg)
                  : null,
              color: p.bg.length == 1 ? p.bg.first : null,
            ),
          ),
        ),
        if (deco != null) Positioned.fill(child: CustomPaint(painter: deco)),
        Positioned.fill(child: child),
      ]),
    );

// ---------------------------------------------------------------------------
//  Decorative painters — drawn, never assets
// ---------------------------------------------------------------------------

class _FloralCorners extends CustomPainter {
  _FloralCorners(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    void sprig(Offset o, double dir) {
      final path = Path()..moveTo(o.dx, o.dy);
      path.relativeQuadraticBezierTo(18 * dir, 10, 30 * dir, 30);
      canvas.drawPath(path, p);
      for (var i = 1; i <= 4; i++) {
        final t = i / 5;
        final bx = o.dx + 30 * dir * t;
        final by = o.dy + 30 * t * t + 6 * t;
        canvas.drawOval(
            Rect.fromCenter(center: Offset(bx + 6 * dir, by - 5), width: 9, height: 5), p);
        canvas.drawOval(
            Rect.fromCenter(center: Offset(bx - 5 * dir, by + 4), width: 9, height: 5), p);
      }
    }

    sprig(const Offset(26, 26), 1);
    sprig(Offset(size.width - 26, 26), -1);
    sprig(Offset(26, size.height - 26), 1);
    sprig(Offset(size.width - 26, size.height - 26), -1);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ArchMotif extends CustomPainter {
  _ArchMotif(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    // A gentle Indian-arch outline near the top.
    final w = size.width, cx = w / 2;
    final path = Path()
      ..moveTo(cx - 120, 150)
      ..lineTo(cx - 120, 70)
      ..arcToPoint(Offset(cx + 120, 70), radius: const Radius.circular(120))
      ..lineTo(cx + 120, 150);
    canvas.drawPath(path, p);
    // Sun rays fan above the arch.
    for (var i = -3; i <= 3; i++) {
      final a = i * 0.24 - math.pi / 2;
      canvas.drawLine(
          Offset(cx, 70), Offset(cx + 40 * math.cos(a), 70 + 40 * math.sin(a)), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RibbonBow extends CustomPainter {
  _RibbonBow(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;
    const top = 34.0;

    // Two loops and a knot.
    void loop(double dir) {
      canvas.drawPath(
        Path()
          ..moveTo(cx, top)
          ..cubicTo(cx + 46 * dir, top - 30, cx + 74 * dir, top + 6,
              cx + 34 * dir, top + 20)
          ..cubicTo(cx + 22 * dir, top + 26, cx + 8 * dir, top + 14, cx, top),
        p,
      );
    }

    loop(1);
    loop(-1);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, top + 6), width: 13, height: 10), p);

    // Tails that fall away and become the side borders — this is what makes
    // the card read as one ribbon rather than a bow with a box under it.
    void tail(double dir) {
      final endY = size.height - 46;
      canvas.drawPath(
        Path()
          ..moveTo(cx + 4 * dir, top + 14)
          ..cubicTo(cx + 60 * dir, top + 60, cx + 118 * dir, size.height * 0.34,
              cx + 128 * dir, size.height * 0.62)
          ..cubicTo(cx + 134 * dir, size.height * 0.82, cx + 96 * dir, endY,
              cx + 54 * dir, endY + 6),
        p,
      );
    }

    tail(1);
    tail(-1);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// An arch window with a sprig at its foot — the shape almost every printed
/// announcement in the reference set is built on.
class _ArchWindow extends CustomPainter {
  _ArchWindow(this.color, this.fill);
  final Color color;
  final Color fill;
  @override
  void paint(Canvas canvas, Size size) {
    const m = 22.0;
    final w = size.width - m * 2, h = size.height - m * 2;
    final r = w / 2;
    final path = Path()
      ..moveTo(m, m + h)
      ..lineTo(m, m + r)
      ..arcToPoint(Offset(m + w, m + r), radius: Radius.circular(r))
      ..lineTo(m + w, m + h)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1);

    // Two sprigs at the foot of the arch.
    final sp = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    void sprig(double x, double dir) {
      final base = size.height - m - 14;
      canvas.drawPath(
          Path()
            ..moveTo(x, base)
            ..relativeQuadraticBezierTo(14 * dir, -10, 26 * dir, -26),
          sp);
      for (var i = 1; i <= 3; i++) {
        final t = i / 4;
        final bx = x + 26 * dir * t, by = base - 26 * t * t - 6 * t;
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(bx + 5 * dir, by - 4), width: 8, height: 4.5),
            sp);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(bx - 4 * dir, by + 4), width: 8, height: 4.5),
            sp);
      }
    }

    sprig(m + 26, 1);
    sprig(size.width - m - 26, -1);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// An engraved double rule with corner leaves. One ink colour, like a printed
/// plate — the formal end of the range.
class _ToileBorder extends CustomPainter {
  _ToileBorder(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final outer = Rect.fromLTWH(16, 16, size.width - 32, size.height - 32);
    final inner = Rect.fromLTWH(21, 21, size.width - 42, size.height - 42);
    canvas.drawRect(outer, p);
    canvas.drawRect(inner, p..strokeWidth = 0.6);

    // Corner leaves, drawn inward.
    final lp = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    void corner(double x, double y, double dx, double dy) {
      for (var i = 0; i < 4; i++) {
        final o = 9.0 + i * 8;
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(x + dx * o, y + dy * o), width: 11, height: 5),
            lp);
      }
    }

    corner(28, 28, 1, 1);
    corner(size.width - 28, 28, -1, 1);
    corner(28, size.height - 28, 1, -1);
    corner(size.width - 28, size.height - 28, -1, -1);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Soft clouds and a scatter of stars.
class _Clouds extends CustomPainter {
  _Clouds(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final c = Paint()..color = Colors.white.withValues(alpha: 0.55);
    void cloud(double x, double y, double s) {
      canvas.drawCircle(Offset(x, y), 17 * s, c);
      canvas.drawCircle(Offset(x + 18 * s, y + 4 * s), 13 * s, c);
      canvas.drawCircle(Offset(x - 18 * s, y + 5 * s), 12 * s, c);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x - 26 * s, y + 4 * s, 52 * s, 13 * s),
              Radius.circular(7 * s)),
          c);
    }

    cloud(size.width * 0.18, size.height * 0.14, 1.0);
    cloud(size.width * 0.84, size.height * 0.24, 0.8);
    cloud(size.width * 0.30, size.height * 0.88, 1.15);
    cloud(size.width * 0.80, size.height * 0.80, 0.9);

    final sp = Paint()..color = color.withValues(alpha: 0.55);
    void star(double x, double y, double r) {
      final path = Path();
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        final rad = i.isEven ? r : r * 0.34;
        final px = x + rad * math.cos(a), py = y + rad * math.sin(a);
        i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
      }
      canvas.drawPath(path..close(), sp);
    }

    star(size.width * 0.86, size.height * 0.10, 7);
    star(size.width * 0.10, size.height * 0.36, 5);
    star(size.width * 0.92, size.height * 0.52, 4.5);
    star(size.width * 0.16, size.height * 0.66, 6);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Dots extends CustomPainter {
  _Dots(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withValues(alpha: 0.14);
    for (var y = 20.0; y < size.height; y += 26) {
      for (var x = 20.0; x < size.width; x += 26) {
        canvas.drawCircle(Offset(x, y), 1.4, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ---------------------------------------------------------------------------
//  Archetypes — layouts, dressed by a palette
// ---------------------------------------------------------------------------

/// Every archetype is the same shape: a block of content at the top and the
/// footer pinned to the bottom of a FIXED-size card.
///
/// A plain Column + Spacer overflows the instant the content is taller than the
/// card - a long name, a three-line message, or simply a template whose fixed
/// gaps add up (the Sage Bloom floral card overflowed by 11px with an EMPTY
/// message). A memory card is exported as an image, so it can never scroll and
/// must never show an overflow stripe.
///
/// So the content block scales down to fit instead. At normal lengths nothing
/// changes; past that it shrinks gently rather than breaking. Expanded (not
/// Flexible) keeps the footer welded to the bottom edge.
Widget _cardBody({
  required EdgeInsets padding,
  required double innerWidth,
  required List<Widget> content,
  required Widget footer,
  Alignment align = Alignment.topCenter,
}) =>
    Padding(
      padding: padding,
      child: Column(children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: align,
            child: SizedBox(
              width: innerWidth,
              child: Column(mainAxisSize: MainAxisSize.min, children: content),
            ),
          ),
        ),
        const SizedBox(height: 10),
        footer,
      ]),
    );

/// Calm centred layout, optional round photo. The default keepsake.
Widget _archMinimal(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  return _bg(p, t.format,
      _cardBody(
        padding: const EdgeInsets.fromLTRB(30, 46, 30, 26),
        innerWidth: t.format.size.width - 60,
        footer: _footer(d, p),
        content: [
          _eyebrowText(d, p),
          const SizedBox(height: 18),
          if (t.usesPhoto && d.photo != null) ...[
            _photo(d.photo, w: 120, h: 120, circle: true, ring: p.panel),
            const SizedBox(height: 22),
          ],
          _titleText(d, p, t.usesPhoto ? 34 : 42),
          const SizedBox(height: 12),
          _detailText(d, p),
          const SizedBox(height: 16),
          _messageText(d, p),
        ],
      ),
      deco: _Dots(p.accent));
}

/// Photo fills the card; text sits on a soft scrim. Portrait-first.
Widget _archPhotoHero(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  return _bg(p, t.format,
      Stack(children: [
        if (d.photo != null)
          Positioned.fill(child: _photo(d.photo, w: t.format.size.width, h: t.format.size.height)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.62)],
                stops: const [0.35, 1],
              ),
            ),
          ),
        ),
        // Hero text hugs the BOTTOM of the photo, so the scaling block is
        // bottom-aligned and the eyebrow stays pinned at the top.
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 26),
          child: Column(children: [
            _eyebrowText(d, p, color: Colors.white),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: t.format.size.width - 60,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    _titleText(d, p, 40, color: Colors.white),
                    const SizedBox(height: 12),
                    _detailText(d, p, color: Colors.white.withValues(alpha: 0.9)),
                    const SizedBox(height: 14),
                    _messageText(d, p, color: Colors.white.withValues(alpha: 0.92)),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _footer(d, p, color: Colors.white),
          ]),
        ),
      ]));
}

/// A thin frame, centred stack, rounded photo — quietly elegant.
Widget _archFramed(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  return _bg(p, t.format,
      Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: p.accent.withValues(alpha: 0.55), width: 1.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: _cardBody(
            padding: const EdgeInsets.fromLTRB(26, 34, 26, 22),
            // the outer all(18) frame eats 36 before this padding's 52
            innerWidth: t.format.size.width - 88,
            footer: _footer(d, p),
            content: [
              _eyebrowText(d, p),
              const SizedBox(height: 16),
              if (t.usesPhoto && d.photo != null) ...[
                _photo(d.photo, w: t.format.size.width - 92, h: t.format == MemoryFormat.portrait ? 220 : 130, ring: p.panel),
                const SizedBox(height: 20),
              ],
              _titleText(d, p, 34),
              const SizedBox(height: 10),
              _detailText(d, p),
              const SizedBox(height: 14),
              _messageText(d, p),
            ],
          ),
        ),
      ),
      deco: null);
}

/// Floral corners around a soft centred card.
Widget _archFloral(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  return _bg(p, t.format,
      _cardBody(
        padding: const EdgeInsets.fromLTRB(34, 56, 34, 30),
        innerWidth: t.format.size.width - 68,
        footer: _footer(d, p),
        content: [
          _eyebrowText(d, p),
          const SizedBox(height: 20),
          if (t.usesPhoto && d.photo != null) ...[
            _photo(d.photo, w: 128, h: 128, circle: true, ring: p.panel),
            const SizedBox(height: 22),
          ],
          _titleText(d, p, t.usesPhoto ? 34 : 40),
          const SizedBox(height: 12),
          _detailText(d, p),
          const SizedBox(height: 16),
          _messageText(d, p),
        ],
      ),
      deco: _FloralCorners(p.accent));
}

/// Warm, ornamented — an Indian-inspired arch motif.
Widget _archIndian(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  return _bg(p, t.format,
      _cardBody(
        padding: const EdgeInsets.fromLTRB(30, 70, 30, 28),
        innerWidth: t.format.size.width - 60,
        footer: _footer(d, p),
        content: [
          _eyebrowText(d, p),
          const SizedBox(height: 60),
          if (t.usesPhoto && d.photo != null) ...[
            _photo(d.photo, w: 120, h: 120, circle: true, ring: p.accent),
            const SizedBox(height: 20),
          ],
          _titleText(d, p, t.usesPhoto ? 32 : 40),
          const SizedBox(height: 12),
          _detailText(d, p),
          const SizedBox(height: 14),
          _messageText(d, p),
        ],
      ),
      deco: _ArchMotif(p.accent));
}

// ---------------------------------------------------------------------------
//  Reference-inspired archetypes
// ---------------------------------------------------------------------------
//  Drawn from the announcement cards people actually post. Four things recur in
//  every one of them and are carried through here:
//
//   * ONE script line, never two. The name is the calligraphy; everything else
//     is small caps. Two scripts on a card is where a keepsake starts to look
//     like a template.
//   * The date is RULED, not centred loose — a hairline either side keeps it
//     from competing with the name.
//   * Ornament frames the card, it does not fill it. The middle stays empty.
//   * Parents are named at the foot, small. The card is about the baby.
//
//  All five go through _cardBody, so they inherit the overflow fix rather than
//  each one having to remember it.

/// A drawn bow whose tails fall away and become the side border. The most
/// copied announcement shape there is, and the calmest.
Widget _archRibbon(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  final details = _details(d);
  return _bg(p, t.format,
      _cardBody(
        padding: const EdgeInsets.fromLTRB(52, 96, 52, 26),
        innerWidth: t.format.size.width - 104,
        align: Alignment.center,
        footer: _footer(d, p),
        content: [
          _eyebrowText(d, p),
          const SizedBox(height: 22),
          _scriptTitle(d, p, 46),
          const SizedBox(height: 20),
          if (details.isNotEmpty) _ruledLine(details.first, p),
          if (details.length > 1) ...[
            const SizedBox(height: 8),
            Text(details[1],
                textAlign: TextAlign.center,
                style: _sans(10, p.soft, w: FontWeight.w600, ls: 1.2)),
          ],
          const SizedBox(height: 16),
          _messageText(d, p),
        ],
      ),
      deco: _RibbonBow(p.accent));
}

/// An arch window on a coloured mat, sprigs at its foot. The printed-card
/// shape: the mat does the framing so the type can stay small.
Widget _archArchWindow(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  final details = _details(d);
  final inset = t.format == MemoryFormat.portrait ? 46.0 : 40.0;
  return _bg(p, t.format,
      _cardBody(
        padding: EdgeInsets.fromLTRB(inset, inset + 26, inset, 22),
        innerWidth: t.format.size.width - inset * 2,
        align: Alignment.center,
        footer: _footer(d, p),
        content: [
          if (t.usesPhoto && d.photo != null) ...[
            _photo(d.photo, w: 104, h: 104, circle: true, ring: p.panel),
            const SizedBox(height: 18),
          ],
          Text(_eyebrow(d),
              textAlign: TextAlign.center,
              style: _sans(9.5, p.soft, w: FontWeight.w700, ls: 2.6)),
          const SizedBox(height: 12),
          _scriptTitle(d, p, 42),
          const SizedBox(height: 16),
          if (details.isNotEmpty) _ruledLine(details.first, p, gap: 8),
          const SizedBox(height: 14),
          _messageText(d, p),
        ],
      ),
      deco: _ArchWindow(p.accent, p.panel));
}

/// Photo on top, a colour panel beneath it carrying every word. The layout for
/// a card that is mostly a photograph and still has to say four things.
Widget _archSplit(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  final w = t.format.size.width;
  final photoH = t.format == MemoryFormat.portrait ? 300.0 : 168.0;
  final details = _details(d);
  return _bg(p, t.format,
      Column(children: [
        SizedBox(
          height: photoH,
          width: w,
          child: d.photo != null
              ? _photo(d.photo, w: w, h: photoH)
              // No photo yet: a calm panel rather than a grey hole, so the
              // template still reads as a design in the picker.
              : DecoratedBox(decoration: BoxDecoration(color: p.panel)),
        ),
        Expanded(
          child: Container(
            width: w,
            color: p.bg.first,
            child: _cardBody(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 20),
              innerWidth: w - 56,
              align: Alignment.center,
              footer: _footer(d, p),
              content: [
                _eyebrowText(d, p),
                const SizedBox(height: 12),
                _scriptTitle(d, p, 36),
                const SizedBox(height: 14),
                for (final line in details)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(line.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: _sans(9.5, p.soft, w: FontWeight.w700, ls: 1.8)),
                  ),
                const SizedBox(height: 8),
                _messageText(d, p),
              ],
            ),
          ),
        ),
      ]));
}

/// An engraved double rule with corner leaves, and the date set as a large
/// numeral between hairlines. The formal end of the range.
Widget _archToile(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  final details = _details(d);
  return _bg(p, t.format,
      _cardBody(
        padding: const EdgeInsets.fromLTRB(44, 52, 44, 26),
        innerWidth: t.format.size.width - 88,
        align: Alignment.center,
        footer: _footer(d, p),
        content: [
          Text(_eyebrow(d),
              textAlign: TextAlign.center,
              style: _sans(9.5, p.soft, w: FontWeight.w700, ls: 3.4)),
          const SizedBox(height: 20),
          Text(_title(d).toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _serif(27, p.ink, w: FontWeight.w600, h: 1.16)
                  .copyWith(letterSpacing: 1.6)),
          const SizedBox(height: 20),
          if (details.isNotEmpty) _ruledLine(details.first, p, gap: 12),
          if (details.length > 1) ...[
            const SizedBox(height: 10),
            Text(details[1],
                textAlign: TextAlign.center,
                style: _sans(9.5, p.soft, w: FontWeight.w600, ls: 1.6)),
          ],
          const SizedBox(height: 18),
          _messageText(d, p),
        ],
      ),
      deco: _ToileBorder(p.accent));
}

/// Clouds, stars, and one word of the message set in script. The soft one —
/// and the only template where the parent's own words carry the card.
Widget _archSky(MemoryTemplate t, MemoryData d) {
  final p = t.palette;
  final details = _details(d);
  return _bg(p, t.format,
      _cardBody(
        padding: const EdgeInsets.fromLTRB(38, 54, 38, 24),
        innerWidth: t.format.size.width - 76,
        align: Alignment.center,
        footer: _footer(d, p),
        content: [
          _eyebrowText(d, p),
          const SizedBox(height: 18),
          _scriptTitle(d, p, 44),
          const SizedBox(height: 16),
          if (details.isNotEmpty)
            Text(details.first.toUpperCase(),
                textAlign: TextAlign.center,
                style: _sans(10, p.soft, w: FontWeight.w700, ls: 2.2)),
          const SizedBox(height: 16),
          _messageText(d, p),
        ],
      ),
      deco: _Clouds(p.accent));
}

// ---------------------------------------------------------------------------
//  The registry — ~16 templates across both milestones
// ---------------------------------------------------------------------------

MemoryTemplate _t(String id, MemoryType type, MemoryStyle style, String name,
        MemoryFormat fmt, MemoryPalette pal, bool photo,
        Widget Function(MemoryTemplate, MemoryData) b) =>
    MemoryTemplate(
        id: id, type: type, style: style, name: name, format: fmt,
        palette: pal, usesPhoto: photo, builder: b);

final List<MemoryTemplate> kMemoryTemplates = [
  // ---- We're Expecting ----
  _t('exp_blush_min', MemoryType.expecting, MemoryStyle.minimal, 'Blush', MemoryFormat.square, _blush, false, _archMinimal),
  _t('exp_sage_floral', MemoryType.expecting, MemoryStyle.floral, 'Sage Bloom', MemoryFormat.square, _sage, true, _archFloral),
  _t('exp_cream_framed', MemoryType.expecting, MemoryStyle.elegant, 'Cream Frame', MemoryFormat.portrait, _cream, true, _archFramed),
  _t('exp_terra_indian', MemoryType.expecting, MemoryStyle.indian, 'Marigold', MemoryFormat.square, _terracotta, false, _archIndian),
  _t('exp_hero', MemoryType.expecting, MemoryStyle.modern, 'Portrait', MemoryFormat.portrait, _blush, true, _archPhotoHero),
  _t('exp_lav_min', MemoryType.expecting, MemoryStyle.minimal, 'Lavender', MemoryFormat.square, _lavender, false, _archMinimal),
  _t('exp_midnight', MemoryType.expecting, MemoryStyle.modern, 'Midnight', MemoryFormat.square, _midnight, false, _archMinimal),
  _t('exp_sky_framed', MemoryType.expecting, MemoryStyle.neutral, 'Sky Frame', MemoryFormat.square, _sky, true, _archFramed),

  // ---- Welcome Baby ----
  _t('wb_blush_min', MemoryType.welcomeBaby, MemoryStyle.minimal, 'Blush', MemoryFormat.square, _blush, false, _archMinimal),
  _t('wb_sage_floral', MemoryType.welcomeBaby, MemoryStyle.floral, 'Sage Bloom', MemoryFormat.square, _sage, true, _archFloral),
  _t('wb_cream_framed', MemoryType.welcomeBaby, MemoryStyle.elegant, 'Cream Frame', MemoryFormat.portrait, _cream, true, _archFramed),
  _t('wb_terra_indian', MemoryType.welcomeBaby, MemoryStyle.indian, 'Marigold', MemoryFormat.square, _terracotta, true, _archIndian),
  _t('wb_hero', MemoryType.welcomeBaby, MemoryStyle.modern, 'Portrait', MemoryFormat.portrait, _sky, true, _archPhotoHero),
  _t('wb_lav_floral', MemoryType.welcomeBaby, MemoryStyle.floral, 'Lavender Bloom', MemoryFormat.square, _lavender, true, _archFloral),
  _t('wb_midnight', MemoryType.welcomeBaby, MemoryStyle.modern, 'Midnight', MemoryFormat.square, _midnight, true, _archMinimal),
  _t('wb_cream_min', MemoryType.welcomeBaby, MemoryStyle.neutral, 'Cream', MemoryFormat.square, _cream, false, _archMinimal),

  // ---- The reference set: ten cards drawn from real announcements ----------
  // Five per milestone, one per archetype, so both types get the full range
  // rather than the expecting side quietly getting the good ones.
  _t('exp_ribbon_ivory', MemoryType.expecting, MemoryStyle.elegant, 'Ribbon', MemoryFormat.portrait, _ivory, false, _archRibbon),
  _t('exp_arch_sage', MemoryType.expecting, MemoryStyle.floral, 'Arch', MemoryFormat.portrait, _sage, false, _archArchWindow),
  _t('exp_toile_porcelain', MemoryType.expecting, MemoryStyle.elegant, 'Engraved', MemoryFormat.portrait, _porcelain, false, _archToile),
  _t('exp_sky_powder', MemoryType.expecting, MemoryStyle.watercolour, 'Clouds', MemoryFormat.square, _powder, false, _archSky),
  _t('exp_split_blush', MemoryType.expecting, MemoryStyle.modern, 'Split', MemoryFormat.portrait, _blush, true, _archSplit),

  _t('wb_ribbon_ivory', MemoryType.welcomeBaby, MemoryStyle.elegant, 'Ribbon', MemoryFormat.portrait, _ivory, false, _archRibbon),
  _t('wb_arch_lav', MemoryType.welcomeBaby, MemoryStyle.floral, 'Arch', MemoryFormat.portrait, _lavender, true, _archArchWindow),
  _t('wb_toile_porcelain', MemoryType.welcomeBaby, MemoryStyle.elegant, 'Engraved', MemoryFormat.portrait, _porcelain, false, _archToile),
  _t('wb_sky_powder', MemoryType.welcomeBaby, MemoryStyle.watercolour, 'Clouds', MemoryFormat.square, _powder, false, _archSky),
  _t('wb_split_cream', MemoryType.welcomeBaby, MemoryStyle.modern, 'Split', MemoryFormat.portrait, _cream, true, _archSplit),
];

List<MemoryTemplate> templatesFor(MemoryType type) =>
    kMemoryTemplates.where((t) => t.type == type).toList();

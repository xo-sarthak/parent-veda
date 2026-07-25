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

// ---------------------------------------------------------------------------
//  Per-type copy
// ---------------------------------------------------------------------------

String _eyebrow(MemoryData d) =>
    d.type == MemoryType.expecting ? "WE'RE EXPECTING" : 'WELCOME';

String _title(MemoryData d) {
  if (d.type == MemoryType.expecting) {
    return d.coupleNames.trim().isNotEmpty ? d.coupleNames.trim() : 'Baby on the way';
  }
  return d.babyName.trim().isNotEmpty ? d.babyName.trim() : 'Our little one';
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
    GoogleFonts.fraunces(fontSize: s, color: c, fontWeight: w, height: h, letterSpacing: -0.3);

TextStyle _sans(double s, Color c, {FontWeight w = FontWeight.w500, double ls = 0}) =>
    GoogleFonts.manrope(fontSize: s, color: c, fontWeight: w, letterSpacing: ls);

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
];

List<MemoryTemplate> templatesFor(MemoryType type) =>
    kMemoryTemplates.where((t) => t.type == type).toList();

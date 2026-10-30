// The community's two mark families, kept apart on purpose (the user,
// 2026-10-28: "distinguish … the drawn marks or glyphs so that we are able to
// distinguish between profile and everything").
//
//  · A ROOM draws the app's own drawn mark (`TtcMarkLeading`: a tinted disc
//    with a SOLID glyph), the same family as Tools and the doors, so a room
//    reads as a place in ParentVeda. Each room has its own mark; none is
//    shared (0121 seeds them, chosen by eye from a rendered sheet).
//  · A MEMBER draws a FACE MARK: a RING with a LINE glyph inside. Never a
//    filled disc, so a person can never be mistaken for a room, and never an
//    animal or a face, so a community name stays a name and not a cartoon.
//    Her first-name face is an ink circle with her initial: the one dark
//    mark on the page, so "this is under my real name" is visible at a
//    glance.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/pv_community.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import '../ttc/doors/ttc_tab_art.dart';
import '../ttc/ttc_tool_marks.dart';
import '../v2/v2_palette.dart';

/// A room's drawn mark from its stored key ('tab:sprout', 'tool:cycle').
class CommunityRoomMark extends StatelessWidget {
  const CommunityRoomMark({super.key, required this.mark, required this.hue, this.size = 44});

  final String mark;
  final double hue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue % 360, V2PaletteStore.instance.current);
    final parts = mark.split(':');
    TtcTabMark? tab;
    TtcToolMark? tool;
    if (parts.length == 2) {
      if (parts[0] == 'tab') {
        tab = TtcTabMark.values.where((m) => m.name == parts[1]).firstOrNull;
      } else if (parts[0] == 'tool') {
        tool = TtcToolMark.values.where((m) => m.name == parts[1]).firstOrNull;
      }
    }
    return TtcMarkLeading(tab: tab, tool: tool, tint: tint, size: size);
  }
}

/// The line glyphs a community name can carry. Eight of them, six hues:
/// 48 faces, picked by the member's seed.
enum CommunityFaceGlyph { moon, leaf, drop, sun, wave, star, hill, bud }

const List<double> kCommunityFaceHues = [104, 26, 206, 42, 344, 262];

CommunityFaceGlyph communityFaceGlyph(int seed) =>
    CommunityFaceGlyph.values[seed % CommunityFaceGlyph.values.length];
double communityFaceHue(int seed) => kCommunityFaceHues[(seed ~/ 8) % kCommunityFaceHues.length];

/// A member's face mark.
class CommunityFaceMark extends StatelessWidget {
  const CommunityFaceMark({super.key, required this.author, this.size = 36});

  final PvCommunityAuthor author;
  final double size;

  @override
  Widget build(BuildContext context) {
    // (0137) The house: an ink SQUARE with a leaf, so it never reads as a
    // member's round face or a room's tinted mark.
    if (author.team) {
      return ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: kPvInk, borderRadius: BorderRadius.circular(size * 0.3)),
          child: Icon(Icons.eco_outlined, size: size * 0.52, color: Colors.white),
        ),
      );
    }
    if (!author.anon) {
      final shown = author.expert?.name ?? author.label;
      final trimmed = shown.trim().replaceFirst(RegExp(r'^Dr\.?\s+'), '');
      final initial = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
      final face = Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: kPvInk, shape: BoxShape.circle),
        child: Text(
          initial,
          style: pvManrope(fontSize: size * 0.42, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
        ),
      );
      if (author.expert == null) return ExcludeSemantics(child: face);
      // The verified seal, from the server's expert register only.
      final seal = size * 0.48;
      return Semantics(
        label: 'Verified expert',
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(clipBehavior: Clip.none, children: [
            face,
            Positioned(
              right: -seal * 0.2,
              bottom: -seal * 0.2,
              child: Container(
                width: seal,
                height: seal,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.verified_rounded, size: seal, color: const Color(0xFF1D74E0)),
              ),
            ),
          ]),
        ),
      );
    }
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: CommunityFacePainter(
            glyph: communityFaceGlyph(author.seed),
            hue: communityFaceHue(author.seed),
          ),
        ),
      ),
    );
  }
}

class CommunityFacePainter extends CustomPainter {
  CommunityFacePainter({required this.glyph, required this.hue});
  final CommunityFaceGlyph glyph;
  final double hue;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final tint = HSLColor.fromAHSL(1, hue, 0.36, 0.92).toColor();
    final ink = HSLColor.fromAHSL(1, hue, 0.42, 0.34).toColor();
    canvas.drawCircle(c, s / 2, Paint()..color = tint);
    // The ring: what makes a face a face and not a room.
    canvas.drawCircle(
      c,
      s / 2 - s * 0.06,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, s * 0.045)
        ..color = ink.withValues(alpha: 0.55),
    );
    final u = s / 24; // glyphs are drawn on a 24-unit grid
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, 1.7 * u)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ink;
    canvas.save();
    canvas.translate(c.dx - 12 * u * 0.62, c.dy - 12 * u * 0.62);
    canvas.scale(u * 0.62);
    final p = Path();
    switch (glyph) {
      case CommunityFaceGlyph.moon:
        p
          ..moveTo(16.5, 15.5)
          ..arcToPoint(const Offset(8.5, 5), radius: const Radius.circular(7))
          ..arcToPoint(const Offset(16.5, 15.5), radius: const Radius.circular(7.6), clockwise: false);
      case CommunityFaceGlyph.leaf:
        p
          ..moveTo(5, 19)
          ..quadraticBezierTo(5, 5, 19, 5)
          ..quadraticBezierTo(19, 19, 5, 19)
          ..moveTo(5, 19)
          ..lineTo(13, 11);
      case CommunityFaceGlyph.drop:
        p
          ..moveTo(12, 4)
          ..quadraticBezierTo(18, 11, 18, 14.5)
          ..arcToPoint(const Offset(6, 14.5), radius: const Radius.circular(6))
          ..quadraticBezierTo(6, 11, 12, 4);
      case CommunityFaceGlyph.sun:
        p.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 3.8));
        for (var k = 0; k < 8; k++) {
          final a = k * math.pi / 4;
          p
            ..moveTo(12 + math.cos(a) * 6.6, 12 + math.sin(a) * 6.6)
            ..lineTo(12 + math.cos(a) * 8.8, 12 + math.sin(a) * 8.8);
        }
      case CommunityFaceGlyph.wave:
        for (final y in [9.5, 14.5]) {
          p
            ..moveTo(4, y)
            ..cubicTo(7, y - 3, 9, y + 3, 12, y)
            ..cubicTo(15, y - 3, 17, y + 3, 20, y);
        }
      case CommunityFaceGlyph.star:
        for (var k = 0; k < 10; k++) {
          final a = -math.pi / 2 + k * math.pi / 5;
          final r = k.isEven ? 8.0 : 3.6;
          final pt = Offset(12 + math.cos(a) * r, 12.6 + math.sin(a) * r);
          k == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
        }
        p.close();
      case CommunityFaceGlyph.hill:
        p
          ..moveTo(3.5, 18)
          ..lineTo(9.5, 9.5)
          ..lineTo(13.5, 14.5)
          ..lineTo(16, 12)
          ..lineTo(20.5, 18)
          ..close();
      case CommunityFaceGlyph.bud:
        p
          ..moveTo(12, 20)
          ..lineTo(12, 12.5)
          ..moveTo(12, 12.5)
          ..quadraticBezierTo(6, 12.5, 6, 6)
          ..quadraticBezierTo(12, 6, 12, 12.5)
          ..moveTo(12, 12.5)
          ..quadraticBezierTo(18, 12.5, 18, 6)
          ..quadraticBezierTo(12, 6, 12, 12.5);
    }
    canvas.drawPath(p, pen);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CommunityFacePainter old) => old.glyph != glyph || old.hue != hue;
}

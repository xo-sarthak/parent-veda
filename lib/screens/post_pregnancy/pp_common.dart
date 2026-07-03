// =============================================================================
//  Post-Pregnancy — shared styling & building blocks ("Editorial Calm")
// -----------------------------------------------------------------------------
//  Self-contained styling for the NEW parenting app (My Child · AskVeda ·
//  Community · Products). Kept inside the post_pregnancy module so nothing here
//  depends on the pregnancy app — the two products stay fully isolated.
//  Direction A "Editorial Calm": magazine-like, serif-forward, airy, restrained
//  to a single purple accent. Palette mirrors the Claude Design mock.
// =============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---- palette ----------------------------------------------------------------
const Color ppBg = Color(0xFFFBF9FE);
const Color ppInk = Color(0xFF2F2C30);
const Color ppSoft = Color(0xFF69636C);
const Color ppPurple = Color(0xFF6A30B6);
const Color ppCoral = Color(0xFFFF5A79);
const Color ppPanel = Color(0xFFF3EEF7);
const Color ppMuted = Color(0xFFA99CBB);
const Color ppBorder = Color(0xFFE7DFEE);
const Color ppHair = Color(0xFFEFEAF2);
const Color ppLine = Color(0xFFE4E2E5);
const Color ppCoralTint = Color(0xFFFFF0F3);
const Color ppBrown = Color(0xFF7A4600);
const Color ppPanelDiv = Color(0xFFE1D7EC);
const Color ppStripeA = Color(0xFFEFE7F5);
const Color ppStripeB = Color(0xFFF6F0FA);

// ---- text -------------------------------------------------------------------
TextStyle ppFraunces(double size,
        {FontWeight w = FontWeight.w400, Color color = ppInk, double h = 1.12}) =>
    GoogleFonts.fraunces(
        fontSize: size, fontWeight: w, height: h, letterSpacing: -0.4, color: color);

TextStyle ppJakarta(double size, {FontWeight w = FontWeight.w700, Color color = ppInk}) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: color);

TextStyle ppBody(double size,
        {Color color = ppSoft, double h = 1.6, FontWeight w = FontWeight.w400}) =>
    GoogleFonts.manrope(fontSize: size, height: h, color: color, fontWeight: w);

// ---- small parts ------------------------------------------------------------
Widget ppEyebrow(String t, {Color color = ppCoral, double spacing = 1.4}) => Text(
      t.toUpperCase(),
      style: GoogleFonts.manrope(
          fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: spacing, color: color),
    );

Widget ppDivider() => Container(height: 1, color: ppLine);

Widget ppLangToggle() => Text.rich(
      TextSpan(children: const [
        TextSpan(text: 'EN', style: TextStyle(color: ppPurple, fontWeight: FontWeight.w600)),
        TextSpan(text: ' · ', style: TextStyle(color: Color(0xFFC7BBD6))),
        TextSpan(text: 'हिं', style: TextStyle(color: ppMuted, fontWeight: FontWeight.w600)),
      ]),
      style: GoogleFonts.manrope(fontSize: 12),
    );

Widget ppSeeAll([String label = 'See all →']) => Text(label,
    style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: ppPurple));

// Diagonal-striped placeholder (stands in for imagery/video, as in the mock).
class PpStriped extends StatelessWidget {
  const PpStriped({
    super.key,
    required this.height,
    this.width,
    this.radius = 0,
    this.colorA = ppStripeA,
    this.colorB = ppStripeB,
    this.border = false,
    this.child,
  });
  final double height;
  final double? width;
  final double radius;
  final Color colorA;
  final Color colorB;
  final bool border;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: border ? Border.all(color: const Color(0xFFECE5F2)) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _StripePainter(colorA, colorB),
        child: SizedBox(height: height, width: width ?? double.infinity, child: child),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.a, this.b);
  final Color a;
  final Color b;
  static const double band = 11;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = b);
    final p = Paint()
      ..color = a
      ..strokeWidth = band
      ..style = PaintingStyle.stroke;
    for (double d = -size.height; d < size.width + size.height; d += band * 2) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) => old.a != a || old.b != b;
}

// ---- shared floating bottom nav (My Child · AskVeda · Community · Products) --
//  The parenting app's 4 hero tabs. Only My Child + Products are built; the
//  others show a gentle "coming soon". "My Child" pops back to the home route
//  (named 'pp/my_child' by the doorway) from any depth. Pass onProducts to push
//  the Products discovery screen from a non-products tab.
class PpBottomNav extends StatelessWidget {
  const PpBottomNav({super.key, required this.active, this.onProducts});

  /// 0 = My Child · 1 = AskVeda · 2 = Community · 3 = Products
  final int active;
  final VoidCallback? onProducts;

  static const List<String> _labels = ['My Child', 'AskVeda', 'Community', 'Products'];

  void _tap(BuildContext context, int i) {
    if (i == active) return;
    if (i == 0) {
      Navigator.of(context).popUntil((r) => r.isFirst || r.settings.name == 'pp/my_child');
    } else if (i == 3 && onProducts != null) {
      onProducts!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget tab(int i) {
      final on = i == active;
      return Expanded(
        child: GestureDetector(
          onTap: () => _tap(context, i),
          behavior: HitTestBehavior.opaque,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: on ? ppPurple : Colors.transparent, shape: BoxShape.circle),
            ),
            const SizedBox(height: 5),
            Text(_labels[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: ppBody(11, color: on ? ppPurple : ppMuted, w: on ? FontWeight.w700 : FontWeight.w600)),
          ]),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEFEAF4)),
            boxShadow: const [BoxShadow(color: Color(0x1E6A30B6), blurRadius: 26, offset: Offset(0, 10))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [tab(0), tab(1), tab(2), tab(3)]),
        ),
      ),
    );
  }
}

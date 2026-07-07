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

import 'askveda_screen.dart';
import 'community_screen.dart';
import 'courses_screen.dart';
import 'pp_products_data.dart';
import 'product_detail_screen.dart';
import 'products_discovery_screen.dart';
import 'tools_hub_screen.dart';

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

// A location chip (pin · label · caret) used across the Problem Solver / local-services
// screens. Visual only — the city is fixed to the mock's Delhi NCR for now.
Widget ppLocationPill(String city) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.place_outlined, size: 13, color: ppPurple),
        const SizedBox(width: 5),
        Text(city, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: ppInk)),
        const SizedBox(width: 3),
        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: ppMuted),
      ]),
    );

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
/// Central tab navigation for the parenting app: pop back to the My Child home
/// (route 'pp/my_child') so the stack stays shallow, then push the target tab.
void openPpTab(BuildContext context, int index) {
  final nav = Navigator.of(context);
  nav.popUntil((r) => r.isFirst || r.settings.name == 'pp/my_child');
  switch (index) {
    case 1:
      nav.push(MaterialPageRoute<void>(builder: (_) => const AskVedaScreen()));
      break;
    case 2:
      nav.push(MaterialPageRoute<void>(builder: (_) => const ToolsHubScreen()));
      break;
    case 3:
      nav.push(MaterialPageRoute<void>(builder: (_) => const CommunityScreen()));
      break;
    case 4:
      nav.push(MaterialPageRoute<void>(builder: (_) => const ProductsDiscoveryScreen()));
      break;
    // 0 = My Child: the popUntil above already returned to it.
  }
}

class PpBottomNav extends StatelessWidget {
  const PpBottomNav({super.key, required this.active});

  /// 0 = My Child · 1 = AskVeda · 2 = Tools · 3 = Community · 4 = Products
  final int active;

  static const List<String> _labels = ['My Child', 'AskVeda', 'Tools', 'Community', 'Products'];

  void _tap(BuildContext context, int i) {
    if (i == active) return;
    openPpTab(context, i);
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
                style: ppBody(10.5, color: on ? ppPurple : ppMuted, w: on ? FontWeight.w700 : FontWeight.w600)),
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
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(children: [tab(0), tab(1), tab(2), tab(3), tab(4)]),
        ),
      ),
    );
  }
}

// ---- shared deep-dive pieces (back bar, section divider, rows) --------------
// No longer used — the product/deeper rows now route to real destinations.
// Kept (commented) in case a future placeholder needs it.
// void _ppSoon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
//     );

Widget ppBack(BuildContext context, String label) => GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.arrow_back, size: 20, color: ppSoft),
        const SizedBox(width: 12),
        Flexible(child: Text(label, style: ppBody(14, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );

Widget ppSectionDivider() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: SizedBox(height: 1, child: ColoredBox(color: ppLine)),
    );

// A round back button (34px lavender circle with ←) as used on the newer
// tracker/finder frames — with an optional uppercase eyebrow and/or trailing
// widget on the right. Tapping pops the current route.
Widget ppCircleBack(BuildContext context, {String? eyebrow, Widget? trailing}) => Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, size: 17, color: ppInk),
          ),
        ),
        if (eyebrow != null) ...[
          const SizedBox(width: 12),
          Expanded(child: ppEyebrow(eyebrow, color: ppMuted, spacing: 1.4)),
        ] else
          const Spacer(),
        ?trailing,
      ],
    );

// An explained product row (image · title + why · price). Tapping opens the
// real product detail when a [productId] is given, otherwise the Products
// section — never a dead "coming soon".
Widget ppProductRow(BuildContext context, String title, String desc, String price,
        {bool top = false, bool bottom = false, String? productId}) =>
    GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => productId != null
              ? ProductDetailScreen(product: productById(productId))
              : const ProductsDiscoveryScreen())),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            border: Border(
          top: top ? const BorderSide(color: ppHair) : BorderSide.none,
          bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
        )),
        child: Row(children: [
          const PpStriped(height: 48, width: 48, radius: 14, border: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(desc, style: ppBody(12)),
            ]),
          ),
          const SizedBox(width: 10),
          Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
        ]),
      ),
    );

// A "go deeper" row (pill · text · →). Routes to the real surface for its pill
// (FAQ → Ask Veda, Room → Community, Course → Courses) — never a dead end.
Widget ppDeeperRow(BuildContext context, String pill, String text, {bool top = false, bool bottom = false}) =>
    GestureDetector(
      onTap: () {
        switch (pill) {
          case 'Course':
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CoursesScreen()));
          case 'Room':
            openPpTab(context, 3); // Community
          default: // FAQ and anything else → Ask Veda
            openPpTab(context, 1);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
            border: Border(
          top: top ? const BorderSide(color: ppHair) : BorderSide.none,
          bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
        )),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
            child: Text(pill, style: ppBody(10, color: ppPurple, w: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: ppBody(14, color: ppInk, h: 1.4))),
          const SizedBox(width: 10),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );

// Soft purple card shadow.
const List<BoxShadow> ppCardShadow = [
  BoxShadow(color: Color(0x266A30B6), blurRadius: 26, spreadRadius: -12, offset: Offset(0, 14)),
];

// Commerce trust row (iMumz-style): money-back · pay-later · pause · EMI.
// Used on the paid funnel pages to make the offer feel real.
Widget ppGuaranteeRow() {
  Widget item(IconData icon, String label) => Expanded(
        child: Column(children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppPanelDiv)),
            child: Icon(icon, size: 20, color: ppPurple),
          ),
          const SizedBox(height: 9),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ppBody(10.5, color: ppSoft, h: 1.3, w: FontWeight.w600)),
        ]),
      );
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    item(Icons.replay_rounded, '7-day money-back'),
    item(Icons.event_available_outlined, 'Pay now,\njoin anytime'),
    item(Icons.pause_circle_outline, '90-day\npause plan'),
    item(Icons.credit_card_outlined, 'EMI options\navailable'),
  ]);
}

// A pill toggle switch (visual state). on = purple, knob right.
Widget ppSwitch(bool on) => Container(
      width: 44,
      height: 26,
      decoration: BoxDecoration(color: on ? ppPurple : ppLine, borderRadius: BorderRadius.circular(999)),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 150),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
      ),
    );

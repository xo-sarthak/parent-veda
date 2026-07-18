// =============================================================================
//  Post-Pregnancy - shared styling & building blocks ("Editorial Calm")
// -----------------------------------------------------------------------------
//  Self-contained styling for the NEW parenting app (My Child · AskVeda ·
//  Community · Products). Kept inside the post_pregnancy module so nothing here
//  depends on the pregnancy app - the two products stay fully isolated.
//  Direction A "Editorial Calm": magazine-like, serif-forward, airy, restrained
//  to a single purple accent. Palette mirrors the Claude Design mock.
// =============================================================================


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ask_veda/veda_core.dart';
import '../product_guide/product_guide_chooser.dart';
import 'askveda_screen.dart';
import 'community_screen.dart';
import 'parenting_veda.dart';
import 'course_detail_screen.dart';
import 'courses_screen.dart';
import 'pp_courses_data.dart';
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
// Heading ink - matches the pregnancy app's primary900 (#2D144C), the dark
// purple-black it uses for section & card titles (slightly warmer than ppInk).
const Color ppTitleInk = Color(0xFF2D144C);

// ---- text -------------------------------------------------------------------
TextStyle ppFraunces(double size,
        {FontWeight w = FontWeight.w400, Color color = ppInk, double h = 1.12}) =>
    GoogleFonts.fraunces(
        fontSize: size, fontWeight: w, height: h, letterSpacing: -0.4, color: color);

TextStyle ppJakarta(double size, {FontWeight w = FontWeight.w700, Color color = ppTitleInk}) =>
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
// screens. Visual only - the city is fixed to the mock's Delhi NCR for now.
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

  // Mirrors the pregnancy app's PvTabBar: a floating white pill where the active
  // tab expands into a purple icon+label pill and the rest are icon + tiny label,
  // so the two apps' bottom navs read as the same component.
  static const List<(IconData, String)> _tabs = [
    (Icons.child_care_rounded, 'My Child'),
    (Icons.auto_awesome_rounded, 'AskVeda'),
    (Icons.widgets_rounded, 'Tools'),
    (Icons.groups_rounded, 'Community'),
    (Icons.shopping_bag_rounded, 'Products'),
  ];

  void _tap(BuildContext context, int i) {
    if (i == active) return;
    openPpTab(context, i);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x292D144C), blurRadius: 28, offset: Offset(0, 8))],
      ),
      child: Row(children: [for (int i = 0; i < _tabs.length; i++) _item(context, i)]),
    );
  }

  Widget _item(BuildContext context, int i) {
    final on = i == active;
    final (icon, label) = _tabs[i];
    final child = GestureDetector(
      onTap: () => _tap(context, i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: on ? 12 : 4, vertical: on ? 9 : 6),
        decoration: BoxDecoration(
          color: on ? ppPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        // Active = horizontal pill (icon + label). Inactive = icon + tiny label.
        child: on
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 21, color: Colors.white),
                const SizedBox(width: 6),
                Text(label, style: ppBody(12.5, color: Colors.white, w: FontWeight.w700)),
              ])
            : Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 20, color: ppMuted),
                const SizedBox(height: 3),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: ppBody(8.5, color: ppMuted, w: FontWeight.w600)),
              ]),
      ),
    );
    // The active pill sizes to its content; the four inactive tabs share the rest
    // evenly (Expanded) so the row can't overflow, even under the wide test font.
    return on ? child : Expanded(child: child);
  }
}

// ---- shared deep-dive pieces (back bar, section divider, rows) --------------
// No longer used - the product/deeper rows now route to real destinations.
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
// tracker/finder frames - with an optional uppercase eyebrow and/or trailing
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

// An explained product row (image · title + why · price). When a [productId] is
// given it ALWAYS shows that product's own name + price (from the catalog) and
// opens exactly that product - so the row can never display one thing and open
// another. The caller's [title]/[price] are only used as a fallback when there's
// no productId (then it opens the Products section). [desc] is the contextual
// "why it helps here" line and is always the caller's.
Widget ppProductRow(BuildContext context, String title, String desc, String price,
    {bool top = false, bool bottom = false, String? productId}) {
  final product = productId != null ? productById(productId) : null;
  final shownTitle = product?.name ?? title;
  final shownPrice = product?.priceLabel ?? price;
  return GestureDetector(
    onTap: () {
      if (product != null) {
        // If this product has a ParentVeda Product Guide, ask which view;
        // otherwise open the normal detail page with no friction.
        openProductWithGuideCheck(context,
            id: product.id,
            name: product.name,
            onOpenNormal: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => ProductDetailScreen(product: product))));
      } else {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProductsDiscoveryScreen()));
      }
    },
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
            Text(shownTitle, style: ppBody(14, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(desc, style: ppBody(12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 10),
        Text(shownPrice, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
      ]),
    ),
  );
}

// A "frequently-asked-question" answer sheet - shows the actual answer inline
// (via the shared Veda engine) so an "FAQ" tap answers the question instead of
// bouncing to a search screen. Offers a follow-up in Ask Veda underneath.
void ppFaqSheet(BuildContext context, String question) {
  final VedaAnswerView v = parentingVedaAnswer(question);
  final answer = v.answer.trim().isNotEmpty
      ? v.answer.trim()
      : 'Here\'s the short version - and you can ask Veda for more detail below.';
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, sc) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: ListView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(99)),
                child: Text('FAQ', style: ppBody(11, color: ppPurple, w: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 12),
            Text(question, style: ppFraunces(22, h: 1.2)),
            const SizedBox(height: 14),
            Text(answer, style: ppBody(14.5, color: ppInk, h: 1.6)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AskVedaScreen(initialQuery: question)));
              },
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                const Icon(Icons.auto_awesome_outlined, size: 16, color: ppPurple),
                const SizedBox(width: 8),
                Flexible(child: Text('Ask a follow-up in Ask Veda', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 14, color: ppPurple),
              ]),
            ),
            const SizedBox(height: 16),
            Text('General guidance for your child\'s stage - please confirm anything important with your paediatrician.', style: ppBody(11.5, color: ppMuted, h: 1.5)),
          ],
        ),
      ),
    ),
  );
}

// A "go deeper" row (pill · text · →). Routes to the real surface for its pill
// (FAQ → Ask Veda, Room → Community, Course → Courses) - never a dead end.
Widget ppDeeperRow(BuildContext context, String pill, String text, {bool top = false, bool bottom = false}) =>
    GestureDetector(
      onTap: () {
        switch (pill) {
          case 'Course':
            // Open the matching focused course (with the named lesson marked
            // "start here"); fall back to the Courses list if nothing matches.
            final course = courseByDeeperText(text);
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) =>
                course != null ? CourseDetailScreen(course: course, highlight: text) : const CoursesScreen()));
          case 'Room':
            openPpTab(context, 3); // Community
          default: // FAQ and anything else → answer it inline (not a redirect)
            ppFaqSheet(context, text);
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
// =============================================================================
//  Card language — shared with the pregnancy app
// -----------------------------------------------------------------------------
//  The two apps already share a palette exactly (ppPurple == AppTheme.primary500,
//  ppBg == scaffoldBackground, and so on — they are the same hexes, declared
//  twice). What made them feel like different products was FORM, and mostly this:
//  parenting cards floated on a purple glow with a negative spread, while
//  pregnancy cards sit on a quiet ink lift. Side by side, that reads as two
//  design teams.
//
//  These constants adopt the pregnancy convention (home_modules.dart HomeCard:
//  radius 26, hairline outline, primary900 @5% / blur 22 / spread 0 / y+10).
//  Nothing here imports AppTheme — the two apps stay code-isolated; only the
//  values agree.
// =============================================================================

/// The dominant card radius on the pregnancy home. Parenting radii had drifted
/// across 16/17/18/20/22/24/26 because every card hand-rolled its decoration.
const double ppCardRadius = 26;

/// The pregnancy app's card lift: ink-tinted, no spread, a soft drop.
const List<BoxShadow> ppCardShadow = [
  BoxShadow(color: Color(0x0D2D144C), blurRadius: 22, offset: Offset(0, 10)),
];

// The old parenting-only shadow: a purple glow that lifted cards off the page
// with a negative spread. Kept for revert — this was the single biggest visual
// tell that the two apps were not the same product.
// const List<BoxShadow> ppCardShadow = [
//   BoxShadow(color: Color(0x266A30B6), blurRadius: 26, spreadRadius: -12, offset: Offset(0, 14)),
// ];

/// One card shell for the whole parenting app, so radius/border/shadow can
/// never drift apart again. [tinted] gives the faint accent wash the pregnancy
/// HomeCard uses for a highlighted module.
BoxDecoration ppCardDecoration({
  double radius = ppCardRadius,
  Color? accent,
  bool tinted = false,
  Color background = Colors.white,
}) =>
    BoxDecoration(
      color: tinted ? null : background,
      gradient: tinted && accent != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent.withValues(alpha: 0.07), background],
            )
          : null,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: tinted && accent != null ? accent.withValues(alpha: 0.20) : ppLine,
      ),
      boxShadow: ppCardShadow,
    );

/// The card itself. Prefer this over hand-rolling a Container: it is what keeps
/// the parenting app looking like the pregnancy app a tap away.
Widget ppCard({
  required Widget child,
  EdgeInsets padding = const EdgeInsets.fromLTRB(20, 18, 20, 20),
  double radius = ppCardRadius,
  Color? accent,
  bool tinted = false,
  VoidCallback? onTap,
}) {
  final card = Container(
    width: double.infinity,
    padding: padding,
    decoration: ppCardDecoration(radius: radius, accent: accent, tinted: tinted),
    child: child,
  );
  if (onTap == null) return card;
  return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: card);
}

/// A section eyebrow in the pregnancy app's voice: uppercase Manrope, tight and
/// small, in primary. Parenting sections announced themselves with a plain
/// Jakarta 18 title and no eyebrow, which is why its pages read flatter.
Widget ppSectionEyebrow(String text, {Color color = ppPurple}) => Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: color,
        ),
      ),
    );

/// A whole section as one card, with its heading on top — the pregnancy home's
/// HomeCard, ported. Every section on that home (Weekly Snapshot, Today's Tip,
/// Today's Read…) is a card; the parenting home left its sections as bare text
/// on the background, which is most of why the two felt like different apps.
///
/// Items inside should be flat rows separated by hairlines, NOT nested cards —
/// a card of cards reads as clutter. Use [ppRowDivider] between them.
Widget ppSectionCard({
  required String eyebrow,
  required IconData icon,
  required Widget child,
  Color accent = ppPurple,
  String? title,
  Widget? trailing,
  bool tinted = false,
  EdgeInsets padding = const EdgeInsets.fromLTRB(18, 16, 18, 18),
}) =>
    ppCard(
      padding: padding,
      accent: accent,
      tinted: tinted,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              eyebrow.toUpperCase(),
              style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: accent),
            ),
          ),
          ?trailing,
        ]),
        if (title != null) ...[
          const SizedBox(height: 9),
          Text(title, style: ppJakarta(18)),
        ],
        const SizedBox(height: 14),
        child,
      ]),
    );

/// A hairline between rows inside a [ppSectionCard].
Widget ppRowDivider() => Container(height: 1, color: ppHair, margin: const EdgeInsets.symmetric(vertical: 4));

/// A horizontal carousel with an integrated gradient header band — the exact
/// shape of the pregnancy home's "Today's recommended products" rail, which
/// packs a title, a See-all and a scroller into far less height than a plain
/// eyebrow + title + loose rail did on the parenting side.
Widget ppCarousel({
  required Color accent,
  required String title,
  required double railHeight,
  required List<Widget> items,
  String seeAll = 'See all',
  VoidCallback? onSeeAll,
  IconData? icon,
}) =>
    Container(
      clipBehavior: Clip.antiAlias,
      decoration: ppCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 13, 12, 13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [accent, Color.lerp(accent, const Color(0xFF2D144C), 0.30)!],
            ),
          ),
          child: Row(children: [
            if (icon != null) ...[Icon(icon, size: 17, color: Colors.white), const SizedBox(width: 9)],
            Expanded(
              child: Text(title,
                  style: ppFraunces(19, color: Colors.white, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                behavior: HitTestBehavior.opaque,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(seeAll, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                  const Icon(Icons.chevron_right_rounded, size: 17, color: Colors.white),
                ]),
              ),
          ]),
        ),
        SizedBox(
          height: railHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => items[i],
          ),
        ),
      ]),
    );

/// A small "eyebrow + heading" lead that sits ABOVE a card on the page (not
/// inside it) — the pregnancy home's "WEEKLY SNAPSHOT" + "Today's journey"
/// device, used to introduce the hero and the video, which had no heading and
/// so ran into each other.
Widget ppLead(String eyebrow, String title, {IconData? icon, Color accent = ppCoral}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(),
            style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: ppPurple)),
        const SizedBox(height: 5),
        Row(children: [
          if (icon != null) ...[Icon(icon, size: 19, color: accent), const SizedBox(width: 8)],
          Flexible(child: Text(title, style: ppJakarta(20), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ],
    );

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

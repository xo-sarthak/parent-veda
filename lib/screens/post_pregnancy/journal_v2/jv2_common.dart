// =============================================================================
//  My Journal V2 — shared design tokens & building blocks
// -----------------------------------------------------------------------------
//  A new, isolated "keepsake Storybook" journal (reached from the Explore
//  drawer, below Astrology). Reuses ParentVeda's palette/typography from
//  pp_common — NO green anywhere — and adds a warm "paper" set that gives the
//  Storybook its heirloom-book feel. Photos are represented by soft toned
//  gradient tiles (JvPhoto), not blank placeholders. Nothing here touches the
//  existing journal; the two live side by side.
// =============================================================================

import 'package:flutter/material.dart';

import '../pp_common.dart';

export '../pp_common.dart';

// ---- warm "paper" palette (storybook only — no green) -----------------------
const Color jvPaper = Color(0xFFFBF7F0); // ivory book paper
const Color jvPaperDeep = Color(0xFFF3EADB); // beige page / card
const Color jvPaperEdge = Color(0xFFE9DEC9); // page-edge shadow
const Color jvPaperLine = Color(0xFFE6DBC7); // hairline on paper
const Color jvSepia = ppBrown; // chapter labels / dates on paper
const Color jvGold = Color(0xFFCBA85E); // spine foil / accents

// A soft warm card shadow (minimal, per spec).
const List<BoxShadow> jvSoftShadow = [
  BoxShadow(color: Color(0x1A6A30B6), blurRadius: 26, spreadRadius: -16, offset: Offset(0, 12)),
];

// ---- toned "photo" tiles (stand in for real photography) --------------------
const List<List<Color>> _jvTints = [
  [Color(0xFFEDE7F6), Color(0xFFD8C7EC)], // lavender
  [Color(0xFFFBE4EC), Color(0xFFF3C9D8)], // blush
  [Color(0xFFF4ECDD), Color(0xFFE6D4B8)], // sand
  [Color(0xFFEAE6F1), Color(0xFFD3CBE4)], // stone lilac
  [Color(0xFFFCEADE), Color(0xFFF1CFB6)], // peach
  [Color(0xFFF0E9F5), Color(0xFFDDCDEC)], // soft violet
];

// Curated, royalty-free photography (Unsplash) mapped by seed to the memory
// topics — mother & baby, child & dog, family, beach, play, newborn. Loaded at
// runtime over the network; the gradient above stays as the loading/offline
// fallback so a tile is never blank.
const String _jvQ = '?w=900&q=70&auto=format&fit=crop';
const List<String> jvImages = [
  'https://images.unsplash.com/photo-1542385151-efd9000785a0$_jvQ', // 0 mother & baby
  'https://images.unsplash.com/photo-1595762834093-8964e63a87b9$_jvQ', // 1 child & dog
  'https://images.unsplash.com/photo-1624272864537-8ecc72b67958$_jvQ', // 2 family / child
  'https://images.unsplash.com/photo-1634845965031-c47a09f22ac2$_jvQ', // 3 baby at the beach
  'https://images.unsplash.com/photo-1628676306092-1238ef1dc851$_jvQ', // 4 family play
  'https://images.unsplash.com/photo-1533483595632-c5f0e57a1936$_jvQ', // 5 newborn
  'https://images.unsplash.com/photo-1510154221590-ff63e90a136f$_jvQ', // 6 newborn
  'https://images.unsplash.com/photo-1560707854-fb9a10eeaace$_jvQ', // 7 mother & baby
];

/// A calm, toned tile that stands in for a photograph. `seed` picks a warm
/// tint so different memories read as different pictures; never blank.
class JvPhoto extends StatelessWidget {
  const JvPhoto({super.key, this.seed = 0, this.height, this.width, this.radius = 0, this.child, this.dim = false});
  final int seed;
  final double? height;
  final double? width;
  final double radius;
  final Widget? child;
  final bool dim; // darken slightly for text-over-photo

  @override
  Widget build(BuildContext context) {
    final t = _jvTints[seed.abs() % _jvTints.length];
    final url = jvImages[seed.abs() % jvImages.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(fit: StackFit.expand, children: [
          // gradient base — shows while the photo loads and if it can't be fetched
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: t),
            ),
          ),
          // the real photograph
          Image.network(
            url,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                child: child,
              );
            },
            loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox.shrink(),
            errorBuilder: (context, error, stack) => const SizedBox.shrink(),
          ),
          if (dim)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0x73000000)]),
              ),
            ),
          ?child,
        ]),
      ),
    );
  }
}

// ---- small building blocks --------------------------------------------------
Widget jvPad(Widget c, [double h = 24]) => Padding(padding: EdgeInsets.symmetric(horizontal: h), child: c);

BoxDecoration jvCard({Color color = Colors.white, double radius = 22, Color? border}) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border ?? ppHair),
      boxShadow: jvSoftShadow,
    );

/// Primary pill button (filled purple).
Widget jvButton(String label, VoidCallback onTap, {bool filled = true, IconData? trailing}) => GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? ppPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: filled ? null : Border.all(color: ppPurple),
          boxShadow: filled ? const [BoxShadow(color: Color(0x596A30B6), blurRadius: 26, spreadRadius: -10, offset: Offset(0, 12))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: ppBody(15, color: filled ? Colors.white : ppPurple, w: FontWeight.w700)),
          if (trailing != null) ...[const SizedBox(width: 8), Icon(trailing, size: 18, color: filled ? Colors.white : ppPurple)],
        ]),
      ),
    );

/// Round back button (34px) + optional centre title + optional trailing.
Widget jvTopBar(BuildContext context, {String? title, Widget? trailing, VoidCallback? onBack}) => Row(children: [
      GestureDetector(
        onTap: onBack ?? () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, size: 17, color: ppInk),
        ),
      ),
      if (title != null) Expanded(child: Text(title, textAlign: TextAlign.center, style: ppJakarta(16))) else const Spacer(),
      if (trailing != null) trailing else const SizedBox(width: 36),
    ]);

/// A little hardcover book render (deep aubergine, gold-foil title + sprig) —
/// our heirloom cover, no green. Reused on the home, library, print & reader.
class JvBookCover extends StatelessWidget {
  const JvBookCover({super.key, this.width = 96, this.height = 128, this.title = 'OUR STORY', this.subtitle = jvChildUpper, this.since});
  final double width;
  final double height;
  final String title;
  final String subtitle;
  final String? since;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(3),
          bottomLeft: Radius.circular(3),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4A3A6B), Color(0xFF2E2440)]),
        boxShadow: const [BoxShadow(color: Color(0x662E2440), blurRadius: 22, spreadRadius: -8, offset: Offset(0, 12))],
      ),
      child: Row(children: [
        // spine highlight
        Container(width: 5, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)]))),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: height * 0.12),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: ppFraunces(width * 0.14, color: const Color(0xFFF3ECDD)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: height * 0.05),
              Container(width: width * 0.24, height: 1, color: jvGold),
              SizedBox(height: height * 0.05),
              Text(subtitle, textAlign: TextAlign.center, style: ppBody(width * 0.1, color: jvGold, w: FontWeight.w700).copyWith(letterSpacing: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Icon(Icons.spa_outlined, size: width * 0.16, color: jvGold),
              if (since != null)
                Padding(
                  padding: EdgeInsets.only(top: height * 0.03),
                  child: Text(since!, textAlign: TextAlign.center, style: ppBody(width * 0.075, color: const Color(0xFFC9C0D8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
            ]),
          ),
        ),
      ]),
    );
  }
}

const String jvChildUpper = 'AARAV';

// ---- journal bottom nav (Our Story · Moments · [+] · Letters · Search) -------
class JvBottomNav extends StatelessWidget {
  const JvBottomNav({super.key, required this.active, required this.onTab, required this.onAdd});

  /// 0 Our Story · 1 Moments · 2 Letters · 3 Search
  final int active;
  final ValueChanged<int> onTab;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    Widget tab(int i, IconData icon, String label) {
      final on = i == active;
      return Expanded(
        child: GestureDetector(
          onTap: () => onTab(i),
          behavior: HitTestBehavior.opaque,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: on ? ppPurple : ppMuted),
            const SizedBox(height: 3),
            Text(label, style: ppBody(10, color: on ? ppPurple : ppMuted, w: on ? FontWeight.w700 : FontWeight.w500)),
          ]),
        ),
      );
    }

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEFEAF4)),
        boxShadow: const [BoxShadow(color: Color(0x1E6A30B6), blurRadius: 26, offset: Offset(0, 10))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        tab(0, Icons.auto_stories_outlined, 'Our Story'),
        tab(1, Icons.grid_view_rounded, 'Moments'),
        // centre add button
        GestureDetector(
          onTap: onAdd,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppPurple,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 20, spreadRadius: -6, offset: Offset(0, 8))],
            ),
            child: const Icon(Icons.add, size: 26, color: Colors.white),
          ),
        ),
        tab(2, Icons.mail_outline_rounded, 'Letters'),
        tab(3, Icons.search_rounded, 'Search'),
      ]),
    );
  }
}

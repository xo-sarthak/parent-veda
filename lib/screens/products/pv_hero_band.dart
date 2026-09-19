// =============================================================================
//  PvHeroBand — the storefront's swipeable hero cards
// -----------------------------------------------------------------------------
//  The one element every marketplace opens with and the audit's rail-first
//  build left out (the user, on the phone: "isn't there a hero section with
//  swipe cards — a marketplace feeling"). Amazon Haul's promo band, Myntra's
//  banner carousel, Blinkit's featured card: a full-bleed photo, an eyebrow,
//  a headline, one call to action, dots underneath, a slow auto-advance that
//  stops the moment she touches it.
//
//  ⚠️ NO BRAND ASSETS YET, AND NOTHING FAKE IN THEIR PLACE. The slides are
//  built from the catalogue itself: the stage's strongest recommendation, the
//  category that matters most right now with its 20-second line, the second
//  recommendation. Each is a real destination. When a campaign or a designed
//  banner exists (Brand Studio, a launch) it becomes a `PvHeroSlide` with an
//  asset — the band does not change.
//
//  Dark-on-photo text is the one place the store departs from "colour only in
//  wells": a hero is a photograph with words on it (H&M, Zara), and the scrim
//  is ink, not brand.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../theme/pv_fonts.dart';
import 'pv_product_screen.dart';
import 'pv_shelf_screen.dart';
import 'pv_store_chrome.dart';

class PvHeroSlide {
  const PvHeroSlide({
    required this.eyebrow,
    required this.title,
    required this.sub,
    required this.cta,
    required this.image,
    required this.hue,
    required this.onTap,
    this.mark = false,
    this.heroTag,
  });
  final String eyebrow;
  final String title;
  final String sub;
  final String cta;
  final String? image;
  final double hue;
  final void Function(BuildContext) onTap;

  /// Draw the verified mark beside the eyebrow (a recommendation slide).
  final bool mark;

  /// When set, the photo is a Hero that becomes the product page's first frame.
  final String? heroTag;
}

/// The stage's slides, from the catalogue. Three, at most.
List<PvHeroSlide> pvHeroSlidesFor(LifeStage stage) {
  final store = PvCatalogStore.instance;
  final s = stage.shopStage;
  final reco = store.recommended(s, limit: 4).where((p) => p.hasImage).toList();
  final slides = <PvHeroSlide>[];

  PvHeroSlide product(PvProduct p, String eyebrow) => PvHeroSlide(
    eyebrow: eyebrow,
    title: p.name,
    sub: p.reco?.reason ?? p.summary,
    cta: 'See why',
    image: p.images.first,
    hue: p.hue,
    mark: true,
    heroTag: 'pv_img_hero_${p.id}',
    onTap: (c) => Navigator.of(c).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PvProductScreen(productId: p.id, heroTag: 'pv_img_hero_${p.id}'),
        settings: RouteSettings(name: '$kPvProductRoutePrefix${p.id}'),
      ),
    ),
  );

  if (reco.isNotEmpty) slides.add(product(reco.first, 'ParentVeda recommends'));

  // The category that matters right now: the first for-you product's shelf.
  final now = store.forYou(s, limit: 1);
  if (now.isNotEmpty) {
    final cat = store.category(now.first.categoryId);
    if (cat != null) {
      final photo = store.inCategory(cat.id).where((p) => p.hasImage).toList();
      slides.add(
        PvHeroSlide(
          eyebrow: switch (s) {
            LifeStage.pregnancy => 'Around now',
            LifeStage.parenting => 'At this age',
            _ => 'Where to start',
          },
          title: cat.name,
          sub:
              cat.guidance?.line ??
              'What to look for, what to skip, and the shelf.',
          cta: 'Shop ${cat.name}',
          image: photo.isEmpty ? null : photo.first.images.first,
          hue: cat.hue,
          onTap: (c) => Navigator.of(c).push(
            MaterialPageRoute<void>(
              builder: (_) => PvShelfScreen(categoryId: cat.id),
              settings: RouteSettings(name: 'store/shelf/${cat.id}'),
            ),
          ),
        ),
      );
    }
  }

  if (reco.length > 1) slides.add(product(reco[1], 'Reviewed for you'));
  return slides;
}

class PvHeroBand extends StatefulWidget {
  const PvHeroBand({super.key, required this.slides});
  final List<PvHeroSlide> slides;

  @override
  State<PvHeroBand> createState() => _PvHeroBandState();
}

class _PvHeroBandState extends State<PvHeroBand> {
  // ⚠️ THE BAND LOOPS — the user's call (2026-09-19): the last card swipes
  // on to the first and the first swipes back to the last, with no dead
  // edge either way. A `PageView` cannot wrap by itself, so the trick every
  // marketplace carousel uses: give it a huge virtual page count, map each
  // virtual index onto a real slide with `% n`, and start in the middle so
  // both directions have thousands of pages of runway. Nothing is
  // duplicated in memory — the builder is lazy and only the visible card
  // and its neighbours exist.
  static const int _virtual = 100000;

  late final int _origin = widget.slides.isEmpty
      ? 0
      : (_virtual ~/ 2) - ((_virtual ~/ 2) % widget.slides.length);
  late final PageController _pages = PageController(
    viewportFraction: 0.9,
    initialPage: _origin,
  );
  Timer? _auto;

  /// The virtual page; `_page` is the real slide it shows.
  late int _virtualPage = _origin;
  int get _page =>
      widget.slides.isEmpty ? 0 : _virtualPage % widget.slides.length;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  /// A slow advance (Myntra's ~5 s), cancelled for good on her first touch —
  /// a carousel that keeps moving under a thumb is the thing people hate.
  void _arm() {
    _auto?.cancel();
    if (widget.slides.length < 2) return;
    _auto = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _touched || !_pages.hasClients) return;
      // Always forward: a wrap is just the next virtual page.
      _pages.animateToPage(
        _virtualPage + 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _auto?.cancel();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    if (widget.slides.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 196,
          child: Listener(
            onPointerDown: (_) => _touched = true,
            child: PageView.builder(
              controller: _pages,
              // One slide needs no loop and no runway.
              itemCount: widget.slides.length < 2 ? 1 : _virtual,
              onPageChanged: (i) => setState(() => _virtualPage = i),
              // Every card has a neighbour on both sides now, so the gutter
              // is symmetric — the "first card, no left gap" special case
              // is gone with the edge it was for.
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _HeroCard(
                  slide: widget.slides[i % widget.slides.length],
                ),
              ),
            ),
          ),
        ),
        if (widget.slides.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? p.ink1 : p.ink1.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.slide});
  final PvHeroSlide slide;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final well = HSLColor.fromAHSL(1, slide.hue, 0.30, 0.90).toColor();
    return InkWell(
      onTap: () => slide.onTap(context),
      borderRadius: BorderRadius.circular(22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (slide.image != null)
              Hero(
                tag: slide.heroTag ?? 'pv_hero_${slide.title}',
                child: Image.network(
                  slide.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => Container(color: well),
                  frameBuilder: (c, child, frame, sync) => sync
                      ? child
                      : AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 300),
                          child: Container(color: well, child: child),
                        ),
                ),
              )
            else
              Container(color: well),
            // The scrim: ink, bottom-heavy, so the words read on any photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.25, 1],
                  colors: [Color(0x00000000), Color(0xB3000000)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      if (slide.mark) ...[
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        slide.eyebrow.toUpperCase(),
                        style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    slide.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvFraunces(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    slide.sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 11),
                  // No `alignment` on this Container (it would fill the column).
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slide.cta,
                          style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: p.ink1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

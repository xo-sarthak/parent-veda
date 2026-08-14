// =============================================================================
//  V3 sections — the pieces 2a has and V2 does not
// -----------------------------------------------------------------------------
//  V3 is the Claude Design direction "2a": grid-led like 1a, but carrying 1b's
//  full-bleed hero. Four things differ from V2, and each is a change 2a made
//  that beat what was already built:
//
//  1. THE HEADER SITS ON THE HERO. V2 goes header -> grid -> hero, so the first
//     thing on screen is six tiles. V3 merges header and hero into one
//     full-bleed block, so the first thing is the photograph with her name on
//     it. Same content, different first impression.
//
//  2. READS ARE A VERTICAL LIST. V2 used a horizontal rail copied from Flo. A
//     rail suits browsing MANY items; a list suits reading a FEW curated ones,
//     and a daily home is the second case. It also survives being read
//     one-handed at 2am, which a sideways swipe does not. The full library
//     lives in the Reads tab, where a rail earns its place.
//
//  3. THE PRACTICE CARD HAS A VERB. "Begin · 3 min" rather than a card that is
//     merely tappable.
//
//  4. THE PRODUCTS SECTION SAYS "PRICES SHOWN". The wedge stated in the
//     interface rather than only implemented — she does not have to notice that
//     the prices are there, the heading tells her.
//
//  ENGLISH ONLY via `.en`, same as V2. See v2_sections.dart for why.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/product_models.dart';
import '../../models/read_item.dart';
import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';
import 'v2_sections.dart' show v2CoverTint, v2ReadCover;

// -----------------------------------------------------------------------------
//  The merged hero
// -----------------------------------------------------------------------------

/// Header and hero as one full-bleed block.
///
/// Her name, the line under it and the avatar sit ON the photograph; the week
/// and the day's sentence sit at its foot. Nothing above it, no card around it.
class V3Hero extends StatelessWidget {
  const V3Hero({
    super.key,
    required this.name,
    required this.subtitle,
    required this.week,
    required this.day,
    required this.learning,
    required this.p,
    this.onTap,
    this.onAvatar,
    this.onSaved,
  });

  final String name;
  final String subtitle;
  final int week;
  final int day;
  final String learning;
  final V2Palette p;
  final VoidCallback? onTap;
  final VoidCallback? onAvatar;
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    final ww = week.toString().padLeft(2, '0');
    // ⚠️ NO CARD, NO RADIUS, NO MARGIN — this is the whole point of the block.
    //
    // The first cut wrapped it in an 18px-inset rounded card, which turned a
    // photograph you look THROUGH into a picture you look AT. Direction 2a has
    // no boundary here at all: the image runs to the edges of the screen and
    // the status bar sits over it. The caller cancels the list's horizontal
    // padding so this can bleed.
    return InkWell(
      onTap: onTap,
      child: SizedBox(
          height: 392,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/baby/week_$ww.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: p.surfaceAlt)),
            // Two scrims, not one. The type sits at BOTH ends of this block, so
            // a single bottom gradient left her name unreadable against a light
            // frame. Dark at top and bottom, clear through the middle where the
            // photograph is doing the work.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x8C000000),
                      Color(0x1A000000),
                      Color(0xB8000000),
                    ],
                    stops: [0, 0.42, 1],
                  ),
                ),
              ),
            ),
            Padding(
              // Top inset clears the status bar, which now sits over the
              // photograph rather than above it.
              padding: EdgeInsets.fromLTRB(
                  18, MediaQuery.of(context).padding.top + 14, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: pvFraunces(
                                    fontSize: 25,
                    letterSpacing: -0.62,
                                    fontWeight: FontWeight.w600,
                                    height: 1.15,
                                    color: Colors.white)),
                            const SizedBox(height: 3),
                            Text(subtitle,
                                style: pvJakarta(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: Colors.white.withValues(alpha: 0.8))),
                          ]),
                    ),
                    const SizedBox(width: 10),
                    // The saved mark, from 2a's own label: "avatar with ring +
                    // saved". Two separate doors, not one — her saved things
                    // and her profile are different places, and burying saved
                    // behind the avatar is how it stops being used.
                    _HeroIcon(
                        icon: Icons.bookmark_border_rounded, onTap: onSaved),
                    const SizedBox(width: 8),
                    _Avatar(name: name, onTap: onAvatar),
                  ]),
                  const Spacer(),
                  Text('WEEK $week · DAY $day',
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 6),
                  Text(learning,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 26,
                    letterSpacing: -0.65,
                          fontWeight: FontWeight.w600,
                          height: 1.18,
                          color: Colors.white)),
                ],
              ),
            ),
          ]),
        ),
    );
  }
}

/// A circular glass button on the photograph. Same treatment as the avatar so
/// the two read as a pair rather than as a control and a decoration.
class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.18),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.4),
          ),
          child: Icon(icon, size: 19, color: Colors.white),
        ),
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.onTap});
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().replaceFirst(RegExp(r'^Today,\s*'), '')[0].toUpperCase();
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.4),
        ),
        child: Text(initial,
            style: pvJakarta(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  Vertical read rows
// -----------------------------------------------------------------------------

/// One read as a row: cover, title, and `CATEGORY · N MIN` on a single line.
///
/// Metadata on ONE line rather than category above and time below — it reads as
/// one fact about the article instead of two separate labels.
class V3ReadRow extends StatelessWidget {
  const V3ReadRow({super.key, required this.item, required this.p, this.onTap});

  final ReadItem item;
  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 74,
              height: 74,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: v2CoverTint(item.id, p),
                borderRadius: BorderRadius.circular(12),
              ),
              // The tint stays as the ground; the photograph sits on it. When
              // a category has no photo the tint alone shows, which is an
              // honest blank rather than a wrong picture.
              child: Builder(builder: (_) {
                final url = v2ReadCover(item.category.en);
                if (url == null) return const SizedBox.shrink();
                return Image.network(url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink());
              }),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title.en,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 16,
                    letterSpacing: -0.4,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            color: p.ink1)),
                    const SizedBox(height: 5),
                    Text(
                        '${item.category.en.toUpperCase()} · ${item.readingTime.en.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: p.ink3)),
                  ]),
            ),
          ]),
        ),
      );
}

// -----------------------------------------------------------------------------
//  Vertical product rows
// -----------------------------------------------------------------------------

/// One product as a row: photo, name, price, and the affiliate label inline.
///
/// The price is never below the fold of its own card and never behind a tap.
class V3ProductRow extends StatelessWidget {
  const V3ProductRow(
      {super.key, required this.item, required this.p, this.onTap});

  final Product item;
  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(children: [
            Container(
              width: 58,
              height: 58,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: v2CoverTint('prod-${item.id}', p),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(productImageUrlV3(item),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink()),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name.en,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvJakarta(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                    if (item.isAffiliate) ...[
                      const SizedBox(height: 3),
                      Text('AFFILIATE',
                          style: pvManrope(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: p.ink3)),
                    ],
                  ]),
            ),
            const SizedBox(width: 10),
            Text(item.price,
                style: pvManrope(
                    fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
          ]),
        ),
      );
}

/// Indirection so this file does not import product_data just for one helper.
String Function(Product) productImageUrlV3 = (p) => p.imageUrl;

// -----------------------------------------------------------------------------
//  Section head with a right-hand note
// -----------------------------------------------------------------------------

/// ⭐ "THINGS THAT HELP · PRICES SHOWN".
///
/// The best two words in the whole design. The wedge — *you always know the
/// price before the pitch* — said out loud in the interface, so she does not
/// have to notice the prices are there.
class V3SectionHead extends StatelessWidget {
  const V3SectionHead(
      {super.key,
      required this.eyebrow,
      required this.title,
      required this.p,
      this.note});

  final String eyebrow;
  final String title;
  final String? note;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(eyebrow.toUpperCase(),
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: p.action.withValues(alpha: 0.85))),
            if (note != null) ...[
              const Spacer(),
              Text(note!.toUpperCase(),
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: p.ink3)),
            ],
          ]),
          const SizedBox(height: 5),
          Text(title,
              style: pvFraunces(
                  fontSize: 21,
                    letterSpacing: -0.53,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: p.ink1)),
        ],
      );
}

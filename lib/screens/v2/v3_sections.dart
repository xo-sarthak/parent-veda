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

import '../../data/reads/pregnancy_reads_weekly_a.dart' show kPregWeekReadPrefix;
import '../../data/reads/read_images.dart';
import '../../models/product_models.dart';
import '../../models/read_item.dart';
import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';
import 'v3_hero_chrome.dart';
import 'v2_sections.dart' show v2CoverTint, v2ReadCover;

// -----------------------------------------------------------------------------
//  The merged hero
// -----------------------------------------------------------------------------

/// Header and hero as one full-bleed block.
///
/// Her name, the line under it and the avatar sit ON the photograph; under
/// them the day strip; at the foot the week and the day, the size line and a
/// "This week" pill. Nothing above it, no card around it.
///
/// ⚠️ RESHAPED 2026-09-21 TO THE TTC FOLD (docs/PREG-HOME-HERO-PLAN.md). The
/// hero used to carry a WEEK n · DAY d chip and the day's "learning" line at
/// 26pt; the chip is now the title and the learning line is the first card of
/// the insights rail under the hero, so the photograph says the week and the
/// size and nothing else — Flo's disc says "14 weeks" and "Details", and that
/// is the whole of it. The old foot is commented out below, kept for revert;
/// [learning] stays on the signature for the same reason.
class V3Hero extends StatelessWidget {
  const V3Hero({
    super.key,
    required this.name,
    required this.subtitle,
    required this.week,
    required this.day,
    this.learning = '',
    required this.p,
    this.strip,
    this.sizeLine,
    this.onSize,
    this.onThisWeek,
    this.height = 340,
    this.onTap,
    this.onSpine,
    this.onAvatar,
    this.onSaved,
  });

  final String name;
  final String subtitle;
  final int week;

  /// The day of pregnancy (1–280) OR the day within the week (1–7); the title
  /// shows the day within the week either way.
  final int day;
  final String learning;
  final V2Palette p;

  /// The day strip, rendered under the chrome row on the photograph
  /// (`PvDayStrip(onPhoto: true)`). Null: no strip (the pre-2026-09-21 shape).
  final Widget? strip;

  /// "About the size of a peach · 8.7 cm · 43 g". Null hides the line.
  final String? sizeLine;

  /// The size line's tap — the size sheet.
  final VoidCallback? onSize;

  /// The pill at the foot — the week stack. Null hides the pill.
  final VoidCallback? onThisWeek;

  /// 340 without the strip; the home passes 372 with it — the strip is 84
  /// and the foot lost the 3-line learning block, so the net is small.
  final double height;
  /// The whole photograph. Historically the ONLY way through to the week, and
  /// it goes to the Today tab.
  final VoidCallback? onTap;

  /// ⚠️ THE SPINE CHIP'S OWN DESTINATION, AND NOT `onTap`.
  ///
  /// The chip first shipped reusing `onTap`, and it landed on the CLASSIC HOME
  /// instead of the weekly stack. The mechanism is the risk the plan wrote down
  /// as R1 and I then walked straight into: `onTap` runs `surfaceId ->
  /// homeFor() -> AppNav.go(tabIndex)`, which is a TAB SHORTCUT, not a push. It
  /// switches to the Today tab — and the Today tab IS the classic home.
  ///
  /// The general lesson, which is what makes this worth six lines: **a callback
  /// named after a gesture ("onTap") tells you nothing about where it goes.**
  /// Reusing one because it is already wired to roughly the right area is how a
  /// chip that says WEEK 40 ends up somewhere that is not week 40.
  final VoidCallback? onSpine;
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
    // ⚠️ A MINIMUM HEIGHT, NOT A FIXED ONE (2026-09-21). It was
    // `SizedBox(height: 340)` over `StackFit.expand`: 392 -> 340 on
    // 2026-09-16 with the "Pregnancy Home V3" design (the design draws the
    // hero at 300; the user asked for "a bit" less than what shipped). With
    // the day strip on the photograph the foot's content varies more — a
    // long size line wraps, a large text scale grows everything — and a fixed
    // box turned that into an overflow stripe across the pill. Now the
    // photograph covers whatever the words need and is never shorter than
    // [height]: the Stack passes the Column's size through, the image and
    // the scrims fill it, and `spaceBetween` keeps the foot at the foot when
    // there is room to spare.
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Stack(fit: StackFit.passthrough, children: [
            // ---- HARD CUT. THE DISSOLVE IS REVERTED -----------------------
            //
            // Three attempts, all removed, and the record is worth keeping so
            // nobody rebuilds one of them:
            //
            //   1. A page-coloured overlay ramping evenly across 88px. Read as
            //      fog — white rising INTO the image rather than the image
            //      ending.
            //   2. The same overlay on a convex curve, clear for two thirds
            //      then closing. Cleaner, still read as white arriving.
            //   3. A ShaderMask fading the image's own alpha, which also faded
            //      the black scrim so nothing was left to dirty the blend.
            //      Technically the correct dissolve. Still wrong on the phone.
            //
            // WHY ALL THREE FAILED, which is the part that generalises: the
            // bottom of this photograph is dark saturated red and the page is
            // near-white. That is a long perceptual distance, and ANY gradual
            // route across it spends 30–80px being neither — a band of
            // in-between colour that the eye reads as a third substance. A
            // blend only disappears when the two things being blended are close
            // in luminance; these are as far apart as the app gets.
            //
            // A hard edge has none of that problem. One image ends, the next
            // section begins, and the eye reads it as two things rather than as
            // a smear between them. Reverted at the user's call after looking
            // at all three, which is the right way to settle it.
            Positioned.fill(
              child: Image.asset('assets/baby/week_$ww.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: p.surfaceAlt)),
            ),
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
              // Back to 22. It went to 86 to keep the type clear of the
              // dissolve; with the dissolve gone the type has the foot of the
              // image back, which is where it was designed to sit.
              padding: EdgeInsets.fromLTRB(
                  18, MediaQuery.of(context).padding.top + (strip == null ? 14 : 8), 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                  // ⚠️ THE STRIP IS THE FIRST THING ON THE PHOTOGRAPH
                  // (2026-09-21, the user, looking at the TTC home: "the
                  // dates should be the top most … we don't need that
                  // Goodnight lying over it"). So with a strip the greeting
                  // comes off the hero — the name lives on the avatar and in
                  // You — and the row under the strip carries the milestone
                  // line and the chrome. Without a strip the old header
                  // (greeting over subtitle) still renders, for revert.
                  if (strip case final s?) ...[
                    s,
                    const SizedBox(height: 10),
                  ],
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                      child: strip != null
                          ? Text(subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvJakarta(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.white.withValues(alpha: 0.8)))
                          : Column(
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
                                    fontSize: 14,
                                    height: 1.4,
                                    color: Colors.white.withValues(alpha: 0.8))),
                          ]),
                    ),
                    const SizedBox(width: 10),
                    // The saved mark, from 2a's own label: "avatar with ring +
                    // saved". Two separate doors, not one — her saved things
                    // and her profile are different places, and burying saved
                    // behind the avatar is how it stops being used.
                    // Was a bare `_HeroIcon` + `_Avatar` pair local to this
                    // file. Now the shared chrome, so parenting and TTC carry
                    // literally the same widget rather than a lookalike — the
                    // journal section already taught what happens otherwise.
                    V3HeroChrome(
                      tone: V3HeroTone.onPhoto,
                      p: p,
                      initial: name.isEmpty ? '' : name.trim().characters.last,
                      onSaved: onSaved,
                      onProfile: onAvatar,
                    ),
                  ]),
                  ]),
                  // The gap between the strip and the foot when the block is
                  // at its minimum; `spaceBetween` opens it further when the
                  // block has room. Was a `Spacer`, which cannot live in a
                  // column whose height is not bounded.
                  const SizedBox(height: 22),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                  if (strip == null) ...[
                    // ---- THE OLD FOOT — kept for revert (2026-09-21) --------
                    // ⚠️ THE EYEBROW IS THE DOOR TO THE WEEKLY STACK, and on
                    // THIS stage that is a fix rather than a feature. The
                    // route already existed: the whole photograph was one
                    // enormous hit target wired straight through to the
                    // weekly snapshot, with no affordance — the "correct but
                    // unreachable" failure in its purest form. The photograph
                    // stays tappable; a bigger target is never the problem.
                    V3SpineChip(
                        label: 'WEEK $week · DAY $day',
                        tone: V3HeroTone.onPhoto,
                        p: p,
                        onTap: onSpine ?? onTap),
                    const SizedBox(height: 8),
                    Text(learning,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 26,
                            letterSpacing: -0.65,
                            fontWeight: FontWeight.w600,
                            height: 1.18,
                            color: Colors.white)),
                  ] else ...[
                    // ---- THE NEW FOOT: the week, the size, the door ---------
                    //
                    // "Week 14 · Day 3" is the title now — the one fact she
                    // opened the app for, at the size the learning line had.
                    // Under it the size line, tappable (the size sheet), and
                    // the pill that opens the week — Flo's "Details", in our
                    // ink-on-white.
                    Text('Week $week · Day ${((day - 1) % 7) + 1}',
                        style: pvFraunces(
                            fontSize: 30,
                            letterSpacing: -0.75,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                            color: Colors.white)),
                    if (sizeLine case final line?) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: onSize,
                        behavior: HitTestBehavior.opaque,
                        child: Text(line,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvJakarta(
                                fontSize: 14.5,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9))),
                      ),
                    ],
                    if (onThisWeek != null) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: Colors.white,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            onTap: onThisWeek,
                            customBorder: const StadiumBorder(),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 9, 12, 9),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text('This week',
                                    style: pvManrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: p.ink1)),
                                const SizedBox(width: 2),
                                Icon(Icons.chevron_right_rounded,
                                    size: 18, color: p.ink1),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                  ]),
                ],
              ),
            ),
          ]),
        ),
    );
  }
}

// SUPERSEDED BY `V3HeroChrome` (v3_hero_chrome.dart), which parenting and TTC
// now share. Kept commented for revert rather than deleted: these two are the
// ORIGINALS the shared widget was derived from, so if the shared version ever
// has to be unwound, this is what pregnancy goes back to.
//
// /// A circular glass button on the photograph. Same treatment as the avatar so
// /// the two read as a pair rather than as a control and a decoration.
// class _HeroIcon extends StatelessWidget {
//   const _HeroIcon({required this.icon, this.onTap});
//   final IconData icon;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) => InkWell(
//         onTap: onTap,
//         customBorder: const CircleBorder(),
//         child: Container(
//           width: 40,
//           height: 40,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.white.withValues(alpha: 0.18),
//             border:
//                 Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.4),
//           ),
//           child: Icon(icon, size: 19, color: Colors.white),
//         ),
//       );
// }
//
// class _Avatar extends StatelessWidget {
//   const _Avatar({required this.name, this.onTap});
//   final String name;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final initial = name.trim().isEmpty
//         ? '?'
//         : name.trim().replaceFirst(RegExp(r'^Today,\s*'), '')[0].toUpperCase();
//     return InkWell(
//       onTap: onTap,
//       customBorder: const CircleBorder(),
//       child: Container(
//         width: 40,
//         height: 40,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white.withValues(alpha: 0.18),
//           border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.4),
//         ),
//         child: Text(initial,
//             style: pvJakarta(
//                 fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
//       ),
//     );
//   }
// }
//
// // -----------------------------------------------------------------------------
// //  Vertical read rows
// // -----------------------------------------------------------------------------
//
// /// One read as a row: cover, title, and `CATEGORY · N MIN` on a single line.
// ///
// /// Metadata on ONE line rather than category above and time below — it reads as
// /// one fact about the article instead of two separate labels.
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
                // The article's own picture first (read_images.dart, the
                // same one its frame shows), else the category's. A rail
                // card and the page it opens should share a photograph.
                final url = readImageFor('$kPregWeekReadPrefix${item.id}') ??
                    v2ReadCover(item.category.en);
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
                            fontSize: 11.5,
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
                              fontSize: 10,
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
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: p.action.withValues(alpha: 0.85))),
            if (note != null) ...[
              const Spacer(),
              Text(note!.toUpperCase(),
                  style: pvManrope(
                      fontSize: 11.5,
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

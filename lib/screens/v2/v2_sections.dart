// =============================================================================
//  V2 sections — the rest of the Focus home, designed rather than inherited
// -----------------------------------------------------------------------------
//  WHY THESE EXIST INSTEAD OF THE SHIPPED CARDS.
//
//  The first cut of the Focus experiment reused GrowModule, TodaysVideoCard and
//  the rest, on the argument that a comparison against copies is dishonest.
//  That was right about comparison and wrong about the brief: it produced a
//  designed hero sitting on top of somebody else's screen, and everything below
//  the grid read as random. A home screen is judged whole.
//
//  So these are palette-aware presentations of the SAME real content the
//  shipped cards read — HomeDay's grow / garbhSanskar / story / talk, and real
//  ReadItems from read_next_data. Nothing here is invented copy: if a field is
//  empty the section hides rather than filling itself in.
//
//  ENGLISH ONLY, AND ENFORCED BY `.en`.
//  Every string reads `.en`, never `.now`. `.now` follows the app's language, so
//  an English-only screen inside a Hindi app came out half-and-half. `.en` is
//  the identity side of LocalizedText and is exactly right here: this screen is
//  English by decision, not by the user's setting. When the experiment graduates
//  it goes through the string table properly and these become `.now`.
//
//  ⚠️ Which means: do NOT copy this file's `.en` habit into shipped screens.
//  There it would pin a mother to English regardless of what she chose.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/product_data.dart';
import '../../data/read_next_data.dart';
import '../../models/home_day.dart';
import '../../models/product_models.dart';
import '../../models/pv_video.dart';
import '../../models/read_item.dart';
import '../../models/scan_appointment.dart';
import '../../services/scans_store.dart';
import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';

// -----------------------------------------------------------------------------
//  Shared chrome
// -----------------------------------------------------------------------------

/// Section heading. Small-caps label above a Fraunces line — the pattern the
/// two best surfaces in the app (Prepare, TTC) already use.
class V2SectionHead extends StatelessWidget {
  const V2SectionHead(
      {super.key, required this.eyebrow, required this.title, required this.p});

  final String eyebrow;
  final String title;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: p.action.withValues(alpha: 0.85))),
          const SizedBox(height: 5),
          Text(title,
              style: pvFraunces(
                  fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
        ],
      );
}

/// A soft cover tint derived from a key.
///
/// This is the "controlled pastel variety" technique from docs/DESIGN-LAYER.md
/// §4a: the HUE varies per item so a grid never repeats itself, while
/// SATURATION and LIGHTNESS are pinned so the set still reads as one system.
/// It is also why a rail of a dozen cards needs no artwork to stop looking like
/// a spreadsheet.
Color v2CoverTint(String key, V2Palette p) {
  var h = 0;
  for (final c in key.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  final hue = (h % 360).toDouble();
  // Warm grounds get a fractionally deeper tint or the card edge disappears.
  final light = p.id == 'baseline' || p.id == 'C' ? 0.90 : 0.87;
  return HSLColor.fromAHSL(1, hue, 0.34, light).toColor();
}

/// The card shell every section shares, so radius, border and inset are
/// decided once rather than per section.
class V2Card extends StatelessWidget {
  const V2Card(
      {super.key,
      required this.child,
      required this.p,
      this.onTap,
      this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final V2Palette p;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: child,
        ),
      );
}

// -----------------------------------------------------------------------------
//  This week — the one full-bleed moment on the page
// -----------------------------------------------------------------------------

/// Full-bleed image, one number, one line. Q8: one floating subject, nothing
/// competing.
///
/// The week photograph is dark and full-frame, which is wrong at 110dp in the
/// grid and right here at full width — so the grid tile is an abstract object
/// and the real baby lives at the size it deserves.
class V2WeekHero extends StatelessWidget {
  const V2WeekHero(
      {super.key,
      required this.week,
      required this.day,
      required this.learning,
      required this.p,
      this.onTap});

  final int week;
  final int day;
  final String learning;
  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ww = week.toString().padLeft(2, '0');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          AspectRatio(
            aspectRatio: 16 / 11,
            child: Image.asset('assets/baby/week_$ww.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: p.surfaceAlt)),
          ),
          // A scrim, not a tint: the type has to survive whatever the
          // photograph does behind it, and these images vary a lot week to
          // week.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  stops: const [0.45, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('WEEK $week · DAY $day',
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: Colors.white.withValues(alpha: 0.85))),
              const SizedBox(height: 5),
              Text(learning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvFraunces(
                      fontSize: 24,
                    letterSpacing: -0.6,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: Colors.white)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  Today's practice
// -----------------------------------------------------------------------------

class V2PracticeCard extends StatelessWidget {
  const V2PracticeCard(
      {super.key,
      required this.garbh,
      required this.p,
      this.onTap,
      this.actionLabel});

  final GarbhSanskarDaily garbh;
  final V2Palette p;
  final VoidCallback? onTap;

  /// When set, the card ends with a verb ("Begin") rather than merely being
  /// tappable. A card that can be tapped but never says what tapping does is
  /// the passive version of the same control — see the interactive-feedback
  /// point in docs/UI-UX-LEARNINGS.md.
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final title = garbh.title.en.trim();
    final desc = garbh.description.en.trim();
    if (title.isEmpty) return const SizedBox.shrink();

    // ⚠️ NO IMAGE HERE, AND THAT IS THE FIX.
    //
    // This card first showed assets/blocks/block_practice.png — the same cloth
    // as the Practice tile in the grid, two rows above it on the same screen.
    // Reusing one object twice on one screen reads as running out of assets,
    // which is exactly what had happened.
    //
    // It is now type-led on a filled tint. That removes the duplication and
    // gives the page a second rhythm: everything around it is image-first, so
    // the one card that is all words reads as a pause rather than a gap.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          // ⚠️ PALETTE ONLY. This was v2BlockTint(practice) — a sage green
          // from the block-hue scale, which is a system for 110dp tiles and
          // not part of the brand palette. At full width it became a large
          // flat green panel that belonged to nothing: not the violet, not the
          // ground, not any accent with a stated job.
          //
          // A tint scale for small marks is not a licence to colour a whole
          // card. surfaceAlt is the palette's own quiet block.
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.self_improvement_rounded,
                size: 17, color: p.ink1.withValues(alpha: 0.55)),
            const SizedBox(width: 7),
            if (garbh.durationMinutes > 0)
              Text('${garbh.durationMinutes} MIN',
                  style: pvManrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: p.ink1.withValues(alpha: 0.55))),
          ]),
          const SizedBox(height: 10),
          Text(title,
              style: pvFraunces(
                  fontSize: 22,
                    letterSpacing: -0.55,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: p.ink1)),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(desc,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: pvJakarta(
                    fontSize: 13.5,
                    height: 1.55,
                    color: p.ink1.withValues(alpha: 0.72))),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: p.action,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(actionLabel!,
                  style: pvJakarta(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.onAction)),
            ),
          ],
        ]),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  Reads rail
// -----------------------------------------------------------------------------

/// Named rail, two cards visible, rich cover, stripped metadata.
///
/// Q2 in practice: the cover pulls the eye, and the card carries a category, a
/// title and a reading time — nothing that accrues. Reading time is a courtesy
/// (it tells her what she is committing to), not a score.
class V2ReadsRail extends StatelessWidget {
  const V2ReadsRail(
      {super.key, required this.items, required this.p, this.onOpen});

  final List<ReadItem> items;
  final V2Palette p;
  final void Function(ReadItem)? onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 214,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final r = items[i];
          return SizedBox(
            width: 168,
            child: InkWell(
              onTap: onOpen == null ? null : () => onOpen!(r),
              borderRadius: BorderRadius.circular(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 108,
                  decoration: BoxDecoration(
                    color: v2CoverTint(r.id, p),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.line),
                  ),
                ),
                const SizedBox(height: 9),
                Text(r.category.en.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: p.ink3)),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(r.title.en,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: p.ink1)),
                ),
                const SizedBox(height: 4),
                Text(r.readingTime.en,
                    style: pvManrope(fontSize: 11, color: p.ink3)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  A quiet quote block — the insight of the day
// -----------------------------------------------------------------------------

/// The one place on the page where type is the whole design.
///
/// No card, no border: an inset rule and a Fraunces line on the page ground.
/// It exists because a home screen made entirely of cards has no rhythm, and
/// this is the section a mother can read without deciding anything.
class V2InsightBlock extends StatelessWidget {
  const V2InsightBlock({super.key, required this.line, required this.p});

  final String line;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    if (line.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: p.action.withValues(alpha: 0.35), width: 2)),
      ),
      child: Text(line,
          style: pvFraunces(
              fontSize: 19,
                    letterSpacing: -0.48,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: p.ink1)),
    );
  }
}

// -----------------------------------------------------------------------------
//  A two-line prompt card (Read to your baby / Something to say)
// -----------------------------------------------------------------------------

class V2PromptCard extends StatelessWidget {
  const V2PromptCard(
      {super.key,
      required this.title,
      required this.body,
      required this.icon,
      required this.p,
      this.eyebrow,
      this.onTap});

  final String title;
  final String body;
  final IconData icon;
  final V2Palette p;

  /// What this card IS.
  ///
  /// These shipped unlabelled under a heading that said "Two small things",
  /// so a card reading "The Flower That Finally Bloomed" gave no clue that it
  /// was a story to read aloud to the baby. The content model names them —
  /// "Read To Your Baby", "Talk To Your Baby" — and stripping that in the name
  /// of a clean layout made them anonymous.
  final String? eyebrow;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (title.trim().isEmpty) return const SizedBox.shrink();
    return V2Card(
      p: p,
      onTap: onTap,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: v2CoverTint(title, p),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: p.ink1.withValues(alpha: 0.7)),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (eyebrow != null) ...[
              Text(eyebrow!.toUpperCase(),
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: p.ink3)),
              const SizedBox(height: 4),
            ],
            Text(title,
                style: pvFraunces(
                    fontSize: 16.5,
                    letterSpacing: -0.41,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: p.ink1)),
            if (body.trim().isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: pvJakarta(fontSize: 13, height: 1.55, color: p.ink2)),
            ],
          ]),
        ),
      ]),
    );
  }
}

/// Real reads for this day, or an empty list. Kept here so the screen does not
/// have to know how read_next_data is shaped.
List<ReadItem> v2ReadsFor(int week, int day) {
  try {
    return dailyArticleReads(week, day, count: 6);
  } catch (_) {
    return const [];
  }
}

// -----------------------------------------------------------------------------
//  Products — a rail, not another banner
// -----------------------------------------------------------------------------

/// Today's product picks, rotating by day, as a horizontal rail.
///
/// WHY A RAIL AND NOT A STACKED CARD. Commerce on this screen was two
/// full-width banners at the very foot — a lot of vertical space for two units,
/// and products themselves were missing entirely. A rail shows five or six in
/// the height of one banner, and it sits mid-page where she will actually see
/// it rather than after everything else.
///
/// ⭐ THE PRICE IS ON THE CARD, ALWAYS. `docs/DESIGN-DECISIONS.md` W04: *you
/// always know the price before the pitch.* A product tile that makes her tap
/// to discover cost is the pattern the review corpus indicts. The TTC stage
/// already ships this — `TODAY'S PICK — ₹400–₹900` — and this matches it.
///
/// The affiliate badge is on the card for the same reason. Disclosure belongs
/// where the decision is made, not in a footer.
class V2ProductRail extends StatelessWidget {
  const V2ProductRail(
      {super.key, required this.items, required this.p, this.onOpen});

  final List<Product> items;
  final V2Palette p;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      // WHY THIS SHRANK FROM 196 TO 172, and why the name/price gap existed.
      //
      // The name sat in an Expanded, so it ate whatever height the card had
      // left and pushed the price to the floor. A two-line name closed the gap;
      // a one-line name left a finger's width of nothing between the product
      // and its price — and since the price is the whole point of this section
      // ("prices shown", the wedge stated out loud), separating the two was
      // exactly backwards. Now the column is its natural height and the price
      // sits under the name where it belongs.
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          return SizedBox(
            width: 132,
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Stack(children: [
                  Container(
                    height: 108,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: v2CoverTint('prod-${it.id}', p),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(productImageUrl(it),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink()),
                  ),
                  if (it.isAffiliate)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999)),
                        child: Text('Affiliate',
                            style: pvManrope(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                ]),
                const SizedBox(height: 8),
                Text(it.name.en,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvJakarta(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: p.ink1)),
                const SizedBox(height: 3),
                Text(it.price,
                    style: pvManrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: p.ink2)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

/// Today's picks, one per relevant category, rotating by day.
///
/// Same selection as the shipped carousel in home_screen_b — the rule is
/// copied, not the widget, for the reason given at the head of this file.
List<Product> v2ProductsFor(int week, int day) {
  try {
    final picks = <Product>[];
    for (final c in recommendedCategories(week)) {
      final ps = productsForCategory(c.id);
      if (ps.isNotEmpty) picks.add(ps[day % ps.length]);
      if (picks.length >= 6) break;
    }
    return picks;
  } catch (_) {
    return const [];
  }
}

// -----------------------------------------------------------------------------
//  Coming up — the only time-sensitive thing on the page
// -----------------------------------------------------------------------------

/// The next appointment, with a real countdown.
///
/// WHY THIS EXISTS AND WHY IT IS THE ONLY ONE. Everything else on this screen is
/// content — read this, practise this — and content is a reason to browse, not a
/// reason to open. This is the one line that answers "is there anything I need
/// to know today". Exactly one, deliberately: a screen with several competing
/// deadlines is the alarm clock this product refuses to be.
///
/// ⚠️ IT RENDERS NOTHING WHEN THERE IS NOTHING. No "no appointments yet" empty
/// state, no zero. A row that appears only when it has something to say cannot
/// become a thing waiting to be cleared.
class V2ComingUp extends StatelessWidget {
  const V2ComingUp({super.key, required this.p, this.onTap});

  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ScansStore.instance,
      builder: (context, _) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        Appointment? next;
        int? days;
        for (final a in ScansStore.instance.appointments) {
          if (a.status != 'upcoming') continue;
          final d = DateTime.tryParse(a.dateIso);
          if (d == null) continue;
          final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
          if (diff < 0) continue;
          next = a;
          days = diff;
          break; // appointments are already sorted soonest-first
        }
        if (next == null || days == null) return const SizedBox.shrink();

        final when = days == 0
            ? 'Today'
            : days == 1
                ? 'Tomorrow'
                : 'In $days days';

        return V2Card(
          p: p,
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: v2CoverTint('coming-up', p),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event_rounded,
                  size: 18, color: p.ink1.withValues(alpha: 0.7)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('COMING UP',
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: p.ink3)),
                const SizedBox(height: 3),
                Text(next.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvJakarta(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink1)),
              ]),
            ),
            const SizedBox(width: 10),
            Text(when,
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: p.action)),
          ]),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
//  Today's video
// -----------------------------------------------------------------------------

/// The recommended video for this week, as one card.
///
/// Same selection rule as the shipped `TodaysVideoCard` — the recommended-
/// category video whose week range covers her, falling back to the nearest.
/// Reimplemented here rather than imported because the shipped one is private
/// and carries AppTheme colours; the RULE is copied, not the pixels.
PvVideo? v2VideoFor(int week) {
  final recs =
      kVideos.where((v) => v.category == VideoCategory.recommended).toList();
  for (final v in recs) {
    if (v.matchesWeek(week)) return v;
  }
  if (recs.isEmpty) return null;
  recs.sort((a, b) =>
      (a.weekStart - week).abs().compareTo((b.weekStart - week).abs()));
  return recs.first;
}

class V2VideoCard extends StatelessWidget {
  const V2VideoCard({super.key, required this.video, required this.p, this.onTap});

  final PvVideo video;
  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => V2Card(
        p: p,
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // No real media yet — a tinted well with a play mark, not a fake
          // thumbnail of a video that does not exist.
          Stack(children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: v2CoverTint('video-${video.id}', p),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: p.surface.withValues(alpha: 0.92),
                      shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow_rounded, size: 26, color: p.ink1),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(video.duration,
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(video.title.en,
                  style: pvFraunces(
                      fontSize: 17,
                    letterSpacing: -0.43,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: p.ink1)),
              if (video.reason.en.trim().isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(video.reason.en,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvJakarta(fontSize: 13, height: 1.5, color: p.ink2)),
              ],
            ]),
          ),
        ]),
      );
}

// -----------------------------------------------------------------------------
//  Cover imagery for reads
// -----------------------------------------------------------------------------

/// A photograph per read CATEGORY, not per article.
///
/// The rail first shipped with flat tinted squares and nothing on them. That was
/// described at the time as the "controlled pastel" technique, which was wrong:
/// in the reference the pastel is the ground BEHIND an image, not a substitute
/// for one. A coloured rectangle is a placeholder however carefully its hue was
/// chosen.
///
/// Per CATEGORY rather than per article, deliberately. Articles keep arriving —
/// the website's reads feed into this — so per-article art is a commitment that
/// grows without end, and an article added on a Tuesday would land back at a
/// blank square. Seven images cover everything, forever, and repeat only inside
/// a category where the repetition reads as a section rather than a gap.
///
/// ⚠️ Stock photographs, not commissioned art. Same caveat as the product
/// images: right subject, not our subject. Replace when there is real art.
const Map<String, String> _kReadCategoryPhoto = {
  'Preparation': 'photo-1448582649076-3981753123b5',
  'Baby Development': 'photo-1580301762395-21ce84d00bc6',
  'Mother Changes': 'photo-1645456040842-221cf6d87e65',
  'Emotional Wellbeing': 'photo-1658279366796-e0c28623cd27',
  'Nutrition': 'photo-1546069901-ba9599a7e63c',
  'Partner Support': 'photo-1506014299253-3725319c0f69',
  'Pregnancy Guide': 'photo-1506880018603-83d5b814b5a6',
};

/// Cover URL for a read, or null when its category has no photograph — in which
/// case the tint alone is used, which is the honest fallback rather than a
/// wrong picture.
String? v2ReadCover(String categoryEn) {
  final id = _kReadCategoryPhoto[categoryEn.trim()];
  return id == null
      ? null
      : 'https://images.unsplash.com/$id?w=300&h=300&fit=crop';
}

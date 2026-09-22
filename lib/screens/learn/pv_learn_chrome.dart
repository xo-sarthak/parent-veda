// =============================================================================
//  Learn chrome — the pieces every learning screen is built from
// -----------------------------------------------------------------------------
//  On the store's chrome (`pv_store_chrome.dart`), the same base-UI rule:
//  white ground, hairlines, ink pills, Newsreader for titles, Manrope for
//  everything else, brand violet only on eyebrows. Nothing here knows what
//  kind of thing it is drawing — a card is a card whether the thing is a
//  course or a consult; the kind is a word on a tag.
//
//  Grammar, from the audit (docs/LEARNING-AUDIT.md §3):
//    card       cover · kind tag · title · who · one fact line · price
//    row        Peloton's schedule row: time block · title · who · a tick
//    fact strip four facts under the title (Peloton, Preply, Udemy)
//    trust row  icon · bold · quiet (Airbnb, Preply)
//    lesson row number · title · minutes · tick or lock (Udemy, Tiimo)
//    week card  label · title · when · points (pliability, MasterClass)
//    commit bar price · one verb (every one of them)
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../data/learn/pv_learn_images.dart';
import '../../data/learn/pv_learn_view.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pv_learn_art.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart'
    show kPvLine, kPvStar, pvStorePalette, PvRoundIcon, PvCommit;
import '../v2/v2_palette.dart';

export '../products/pv_store_chrome.dart'
    show
        kPvLine,
        kPvStar,
        pvStorePalette,
        PvCoverBlock,
        PvRoundIcon,
        PvCommit,
        PvSecondary,
        PvChip,
        pvSnack,
        PvSectionHead,
        kPvStickyBarClearance;

const String kPvLearnRoute = 'learn';
const String kPvOfferingRoutePrefix = 'learn/offering/';

/// The cover. A drawn mark on its own field — or a photograph, the day we
/// own one.
///
/// ⚠️ DRAWN, NOT PHOTOGRAPHED — 2026-09-22. `pvLearnCoverFor` now returns
/// null for everything, so in practice every cover on this screen is the
/// mark. `pv_learn_images.dart` carries the whole argument: the stock photos
/// repeated four to a scroll and were about the wrong subject, and Commons —
/// which dresses the store and the recipes properly — has no editorial
/// photography of prenatal classes to replace them with. The photo branch is
/// kept live rather than deleted because it costs one null check and it is
/// the entire integration when a real shoot lands.
class PvLearnCover extends StatelessWidget {
  const PvLearnCover({
    super.key,
    required this.view,
    this.radius = 16,
    this.fit = BoxFit.cover,
  });
  final PvOfferingView view;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final drawn = PvLearnDrawnCover(view: view, radius: radius);
    final url = view.cover;
    if (url == null) return drawn;
    final tint = HSLColor.fromAHSL(1, view.hue, 0.18, 0.95).toColor();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        fit: fit,
        gaplessPlayback: true,
        frameBuilder: (c, child, frame, wasSync) {
          if (wasSync) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: frame == null
                ? Container(key: const ValueKey('well'), color: tint)
                : SizedBox.expand(key: const ValueKey('img'), child: child),
          );
        },
        errorBuilder: (_, e, s) => drawn,
      ),
    );
  }
}

/// The field a learn mark sits on.
///
/// Composition, and the reason for each part: a flat pastel reads as a
/// missing image, so the ground is a soft diagonal in the programme's own
/// hue — light at the top-left, a step darker at the bottom-right, the same
/// two tones `PvCoverBlock` uses. A single centred glyph on that reads as an
/// icon rather than a cover, so the mark is drawn TWICE: once very large and
/// very faint, bled off the right edge, and once at reading size a little
/// above centre. The faint one is what turns a glyph into a picture — it
/// gives the card depth and an edge to run off, which is the whole trick a
/// photograph was doing.
///
/// ⚠️ NO HALO, per DESIGN-SYSTEM §3.1 — the mark sits straight on the field,
/// never on a white disc. The field is already light enough to carry it.
class PvLearnDrawnCover extends StatelessWidget {
  const PvLearnDrawnCover({super.key, required this.view, this.radius = 16});
  final PvOfferingView view;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final mark = pvLearnMarkFor(view.topics, view.kind);
    final a = HSLColor.fromAHSL(1, view.hue, 0.34, 0.945).toColor();
    final b = HSLColor.fromAHSL(1, view.hue, 0.30, 0.875).toColor();
    final tint = HSLColor.fromAHSL(1, view.hue, 0.30, 0.90).toColor();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: LayoutBuilder(
        builder: (context, c) {
          final side = c.maxWidth.isFinite && c.maxHeight.isFinite
              ? (c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight)
              : 160.0;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [a, b],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The ghost: big, faint, running off the right edge.
                Positioned(
                  // Further off the edge and fainter than the first cut: at
                  // 0.16 and only a third out, the ghost read as a SECOND
                  // object on the card rather than as texture behind the
                  // first — on the 4:3 hero its rounded corner looked like a
                  // stray panel of interface.
                  right: -side * 0.46,
                  bottom: -side * 0.34,
                  width: side * 1.35,
                  height: side * 1.35,
                  child: Opacity(
                    opacity: 0.10,
                    child: HubIntentArt(mark: mark, tint: tint),
                  ),
                ),
                // The mark, read at a glance.
                Align(
                  alignment: const Alignment(-0.06, -0.14),
                  child: SizedBox(
                    width: side * 0.40,
                    height: side * 0.40,
                    child: HubIntentArt(mark: mark, tint: tint),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The kind, as a small white tag over a photo or an ink tag on white.
class PvKindTag extends StatelessWidget {
  const PvKindTag(
    this.label, {
    super.key,
    this.onPhoto = false,
    this.live = false,
  });
  final String label;
  final bool onPhoto;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: onPhoto ? Colors.white.withValues(alpha: 0.92) : p.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFC6295A),
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label.toUpperCase(),
            style: pvManrope(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: p.ink1,
            ),
          ),
        ],
      ),
    );
  }
}

/// The rail card. Fixed width so a rail scrolls; cover 16:10.
class PvLearnCard extends StatelessWidget {
  const PvLearnCard({
    super.key,
    required this.view,
    required this.onTap,
    this.width = 212,
    this.why,
  });
  final PvOfferingView view;
  final VoidCallback onTap;
  final double width;

  /// Personalisation's one-line reason, when the rail is "Chosen for you".
  final String? why;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    // The card's one line.
    //
    // `pvLearnFacts` rather than `view.facts`, so a live card never
    // advertises a date that has been and gone — and for anything live that
    // date IS the line, because when it happens is the whole question.
    //
    // ⚠️ FOR EVERYTHING ELSE THE VALUE ALONE IS NOT A SENTENCE. The strip
    // prints a value over its label and reads fine as two rows ("4" over
    // "lessons"); a card has one line, so it needs the phrase. Hence the
    // duration label first for anything recorded — "4 lessons", "3 weeks ·
    // live" — and the fact only as the floor.
    final facts = pvLearnFacts(view);
    final fact = view.isLive && facts.isNotEmpty
        ? facts.first.value
        : view.durationLabel.isNotEmpty
        ? view.durationLabel
        : facts.isEmpty
        ? ''
        : facts.first.value;
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: PvLearnCover(view: view),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: PvKindTag(
                    view.kind.label,
                    onPhoto: true,
                    live: view.isLive && view.kind != PvLearnKind.consult,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              view.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvFraunces(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              view.expert.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 12.5, color: p.ink2),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    fact,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12, color: p.ink3),
                  ),
                ),
                Text(
                  view.priceLabel,
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: p.ink1,
                  ),
                ),
              ],
            ),
            if (why != null) ...[
              const SizedBox(height: 6),
              Text(
                why!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 11.5, height: 1.35, color: p.action),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A rail of cards with the store's 16-px gutter. Empty → nothing; the
/// caller renders the invitation.
class PvLearnRail extends StatelessWidget {
  const PvLearnRail({
    super.key,
    required this.views,
    required this.onOpen,
    this.whyFor,
  });
  final List<PvOfferingView> views;
  final void Function(PvOfferingView) onOpen;
  final String? Function(PvOfferingView)? whyFor;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        for (var i = 0; i < views.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          PvLearnCard(
            view: views[i],
            onTap: () => onOpen(views[i]),
            why: whyFor?.call(views[i]),
          ),
        ],
      ],
    ),
  );
}

/// Peloton's schedule row: a time block, the thing, who, and a trailing
/// state. `leading` is the two-line block (day / time) or a thumbnail.
class PvLearnRow extends StatelessWidget {
  const PvLearnRow({
    super.key,
    required this.title,
    required this.sub,
    required this.onTap,
    this.leadTop,
    this.leadBottom,
    this.view,
    this.trailing,
    this.tag,
    this.live = false,
    this.initials,
    this.price,
    this.foot,
  });
  final String title;
  final String sub;
  final VoidCallback onTap;
  final String? leadTop;
  final String? leadBottom;
  final PvOfferingView? view;
  final Widget? trailing;
  final String? tag;
  final bool live;

  /// ⚠️ A PERSON WEARS INITIALS, NOT A STOCK PHOTO — 2026-09-22, the walk.
  /// The consult list drew each doctor's row with a topic placeholder, so
  /// the same yoga silhouette sat beside three different names and a
  /// breathing coach wore a photo of baby toys. A picture that is not of
  /// the person is worse than no picture: it reads as her, and it repeats.
  /// Set this and the row draws a tinted disc with her initials instead.
  final String? initials;

  /// Right-aligned, before the chevron. The fee, on a row you choose from.
  final String? price;

  /// A third, quieter line — the rating and the next free time. Zocdoc's
  /// "next available" is the one thing a person reads on a provider row.
  final String? foot;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            if (initials != null)
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.surfaceAlt,
                ),
                child: Text(
                  initials!,
                  style: pvManrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: p.ink1,
                  ),
                ),
              )
            else if (leadTop != null)
              SizedBox(
                width: 58,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leadTop!,
                      style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: p.ink3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      leadBottom ?? '',
                      style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: p.ink1,
                      ),
                    ),
                  ],
                ),
              )
            else if (view != null)
              SizedBox(
                width: 64,
                height: 46,
                child: PvLearnCover(view: view!, radius: 10),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag != null) ...[
                    PvKindTag(tag!, live: live),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12.5, color: p.ink2),
                  ),
                  if (foot != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      foot!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: p.ink1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (price != null) ...[
              Text(
                price!,
                style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: p.ink1,
                ),
              ),
              const SizedBox(width: 6),
            ],
            trailing ??
                Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ],
        ),
      ),
    );
  }
}

/// Four facts under a title. Value large, label small — Peloton's
/// "1 week · 7 days/week · 8 classes · 15–30 min/day".
class PvFactStrip extends StatelessWidget {
  const PvFactStrip({super.key, required this.facts});
  final List<PvLearnFact> facts;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final shown = facts.take(4).toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: kPvLine)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < shown.length; i++)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: i == 0 ? BorderSide.none : BorderSide(color: kPvLine),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⚠️ SHRINK BEFORE YOU BREAK — the user, 2026-09-22:
                    // "reduce font size to fit text fully … only once you
                    // can't optimise the text any other way". Four cells on
                    // a 390-px phone give each value ~85 px, and "Recording"
                    // wrapped as "Recordin / g". The values are short by
                    // construction now; this is the floor — one line,
                    // scaled down to fit, never broken mid-word.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        shown[i].value,
                        maxLines: 1,
                        style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: p.ink1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      shown[i].label,
                      // Two lines. A label like "watch anytime" is a phrase,
                      // and clipping it to "watch anyti…" loses the only
                      // word that carried the meaning.
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 11,
                        height: 1.25,
                        color: p.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Icon · bold line · quiet line. Three per page (Airbnb).
class PvTrustRow extends StatelessWidget {
  const PvTrustRow(this.trust, {super.key});
  final PvLearnTrust trust;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PvLearnRing(mark: trust.mark, p: p),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trust.title,
                  style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trust.line,
                  style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Number · title · minutes · a tick, a lock, or a play mark.
class PvLessonRow extends StatelessWidget {
  const PvLessonRow({
    super.key,
    required this.index,
    required this.lesson,
    required this.onTap,
    this.done = false,
    this.current = false,
    this.gated = false,
  });
  final int index;
  final PvLearnLesson lesson;
  final VoidCallback? onTap;
  final bool done;
  final bool current;

  /// Locked because she has not bought it — different from `lesson.locked`,
  /// which is the content's own ordering.
  final bool gated;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final locked = gated || lesson.locked;
    final Widget mark = done
        ? Icon(Icons.check_circle_rounded, size: 20, color: p.ink1)
        : locked
        ? Icon(Icons.lock_outline_rounded, size: 18, color: p.ink3)
        : Icon(
            Icons.play_circle_outline_rounded,
            size: 20,
            color: current ? p.ink1 : p.ink3,
          );
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: kPvLine)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 26,
              child: Text(
                '$index',
                style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: locked ? p.ink3 : p.ink1,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: pvManrope(
                      fontSize: 14,
                      fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                      height: 1.3,
                      color: locked ? p.ink2 : p.ink1,
                    ),
                  ),
                  if (lesson.blurb != null && lesson.blurb!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      lesson.blurb!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 12,
                        height: 1.35,
                        color: p.ink3,
                      ),
                    ),
                  ],
                  if (lesson.minutes > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      '${lesson.minutes} min',
                      style: pvManrope(fontSize: 11.5, color: p.ink3),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            mark,
          ],
        ),
      ),
    );
  }
}

/// A cohort week or a masterclass block (pliability's week cards).
class PvWeekCard extends StatelessWidget {
  const PvWeekCard(
    this.session, {
    super.key,
    this.index = 0,
    this.current = false,
  });
  final PvLearnSession session;
  final int index;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: current ? p.ink1 : kPvLine,
          width: current ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                session.label.toUpperCase(),
                style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: p.action,
                ),
              ),
              const Spacer(),
              if (session.when.isNotEmpty)
                Text(
                  session.when,
                  style: pvManrope(fontSize: 11.5, color: p.ink3),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            session.title,
            style: pvFraunces(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: p.ink1,
            ),
          ),
          if (session.points.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final pt in session.points)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('·  ', style: pvManrope(fontSize: 13, color: p.ink3)),
                    Expanded(
                      child: Text(
                        pt,
                        style: pvManrope(
                          fontSize: 13,
                          height: 1.4,
                          color: p.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// The person. Initials in a tinted disc (the roster has no photos), name,
/// role, a chevron when there is a page to open.
class PvExpertCard extends StatelessWidget {
  const PvExpertCard({
    super.key,
    required this.expert,
    required this.onTap,
    this.line,
  });
  final PvLearnExpert expert;
  final VoidCallback? onTap;
  final String? line;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final initials = expert.name
        .replaceAll('Dr. ', '')
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPvLine),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.surfaceAlt,
              ),
              child: Text(
                initials.toUpperCase(),
                style: pvManrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: p.ink1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expert.name,
                    style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    line ?? expert.role,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.35,
                      color: p.ink2,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ],
        ),
      ),
    );
  }
}

/// A parent's review, the store's card.
/// ⚠️ KEPT FOR REVERT — nothing builds this as of 2026-09-22. The offering
/// page's proof section is `PvReviewBlock` now (the rail of quote cards);
/// this is the bordered box it replaced, and it stays because reverting the
/// section is then one line rather than a rewrite.
class PvLearnReviewCard extends StatelessWidget {
  const PvLearnReviewCard(this.review, {super.key});
  final PvLearnReview review;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPvLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= review.stars
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 15,
                  color: kPvStar,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${review.name} · ${review.who}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 12, color: p.ink3),
                ),
              ),
            ],
          ),
          if (review.quote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.quote,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section title in the learn pages — Fraunces, with an optional quiet lead.
class PvLearnHead extends StatelessWidget {
  const PvLearnHead(
    this.title, {
    super.key,
    this.lead,
    this.action,
    this.onAction,
  });
  final String title;
  final String? lead;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: pvFraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: p.ink1,
                  ),
                ),
              ),
              if (action != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    action!,
                    style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.ink1,
                    ),
                  ),
                ),
            ],
          ),
          if (lead != null) ...[
            const SizedBox(height: 4),
            Text(
              lead!,
              style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
            ),
          ],
        ],
      ),
    );
  }
}

/// A tick list — what you'll take away.
class PvTickList extends StatelessWidget {
  const PvTickList(this.items, {super.key});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Column(
      children: [
        for (final t in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_rounded, size: 16, color: p.ink1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t,
                    style: pvManrope(fontSize: 14, height: 1.45, color: p.ink1),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The sticky bar: price on the left, one verb on the right. Rises a beat
/// after the page lands, as the store's does.
class PvLearnCommitBar extends StatelessWidget {
  const PvLearnCommitBar({
    super.key,
    required this.price,
    required this.unit,
    required this.verb,
    required this.onTap,
    this.busy = false,
    this.note,
  });
  final String price;
  final String unit;
  final String verb;
  final VoidCallback? onTap;
  final bool busy;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) =>
            FractionalTranslation(translation: Offset(0, t), child: child),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: kPvLine)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      price,
                      style: pvFraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: p.ink1,
                      ),
                    ),
                    Text(
                      note ?? unit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 12, color: p.ink3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // A fixed width: PvCommit's own Row expands, so it needs a
              // bound, and the verb is at most four words.
              SizedBox(
                width: 184,
                child: PvCommit(label: verb, onTap: onTap, busy: busy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The learn pages' top bar: back, an eyebrow, a title, an optional action.
class PvLearnTopBar extends StatelessWidget {
  const PvLearnTopBar({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
  });
  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PvRoundIcon(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Text(
                    eyebrow!.toUpperCase(),
                    style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: p.action,
                    ),
                  ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: p.ink1,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// The four facts under a title — and, for anything live, the first two
/// taken from the ENGINE rather than from the seed.
///
/// ⚠️ A DATE THAT HAS ALREADY HAPPENED IS NOT A FACT. Every live programme
/// carries a `startLabel` written by hand when it was seeded. On 22
/// September the Birth Confidence Masterclass card read "LIVE · Sun 13 Jul ·
/// 8:00 pm" — ten weeks stale, and long enough that the cell truncated it
/// mid-word as well. `BookingCatalog` knows when the next run actually is,
/// and `ServerSlotStore` refreshes it, so the answer is to derive rather
/// than store: the day, then the time, then whatever else the seed said.
///
/// ⚠️ DERIVED AT RENDER, NOT AT BUILD. This deliberately does not live in
/// the adapter that builds `PvOfferingView`, even though that is where facts
/// come from, because the catalogue is cached for the session while slots
/// arrive from the server afterwards. A fact computed once at startup goes
/// stale in exactly the way this function exists to prevent.
/// A person's initials for a disc. One definition, because the consult rows,
/// the expert chips, the review sheet and an offering's "with —" line must
/// all shorten the same name the same way.
String pvLearnInitials(String name) {
  final parts = name
      .replaceAll('Dr. ', '')
      .replaceAll('Dr ', '')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((w) => w[0].toUpperCase()).join();
}

List<PvLearnFact> pvLearnFacts(PvOfferingView v) {
  final o = v.offering;
  if (o == null || !v.isLive || v.kind == PvLearnKind.consult) return v.facts;
  final slots = BookingCatalog.instance.slotsFor(o.id);
  if (slots.isEmpty) return v.facts;
  final start = slots.first.startsUtc;
  return [
    PvLearnFact(pvLearnDay(start), 'next'),
    PvLearnFact(pvLearnTime(start), 'starts'),
    ...v.facts.where((f) => f.label != 'when' && f.label != 'starts').take(2),
  ];
}

/// Dates in the app's one voice. UTC in, local out.
String pvLearnDay(DateTime utc) {
  final d = utc.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(d.year, d.month, d.day);
  final diff = that.difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${w[d.weekday - 1]} ${d.day} ${m[d.month - 1]}';
}

String pvLearnTime(DateTime utc) {
  final d = utc.toLocal();
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  return '$h:$mm ${d.hour < 12 ? 'am' : 'pm'}';
}

/// "in 22 h" / "in 3 days" / "now" — the Booked page's countdown.
String pvLearnCountdown(DateTime startsUtc, DateTime endsUtc) {
  final now = DateTime.now().toUtc();
  if (now.isAfter(endsUtc)) return 'over';
  if (now.isAfter(startsUtc.subtract(const Duration(minutes: 10)))) {
    return 'now';
  }
  final d = startsUtc.difference(now);
  if (d.inMinutes < 60) return 'in ${d.inMinutes} min';
  if (d.inHours < 48) return 'in ${d.inHours} h';
  return 'in ${d.inDays} days';
}

/// A palette getter for files that only need the type.
V2Palette get pvLearnPalette => pvStorePalette;

// =============================================================================
//  Today's smaller parts - the info sheet, and rows instead of cards
// -----------------------------------------------------------------------------
//  Both halves of one decision: WHAT IS TODAY FOR?
//
//  The answer we settled on is three things — where am I, what is worth doing,
//  what is happening in my body — with everything else one tap in. Today was
//  trying to be all three of a home, a reader and a toolbox at once, which is
//  why it read heavy at the same word count as the other two stages. Not too
//  much text. Too many purposes.
//
//  ---------------------------------------------------------------------------
//  Why the hero needed an info button rather than more lines
//
//  The hero had accumulated FOUR attempts to explain the chapter: a "Next:"
//  line, a FOCUS label, a WORTH DOING line, and the chapter name doing double
//  duty as both label and explanation. None had room to explain properly, so all
//  four were vague — and one of them ("Next: Knowing Your Rhythm") named an
//  internal chapter the reader has no reason to recognise yet.
//
//  A hero ORIENTS. An info sheet EXPLAINS. Separating those two jobs is the
//  whole fix, and it is the same principle as folding a paragraph behind "More":
//  the content exists, it just does not all have to be shouted at once.
//
//  Note what the sheet is built from: `overview`, `nextUp()` and `goal()` — the
//  three things cut from the hero. Nothing was deleted. They were moved
//  somewhere they have room to be sentences instead of fragments.
//
//  ---------------------------------------------------------------------------
//  Why rows instead of cards
//
//  Measured rather than assumed: TTC's Today had eleven sections and the
//  parenting home has about eleven too. Identical. The difference was never
//  quantity — parenting renders most of its content as ROWS (six compact row
//  builders: a domain row, a win, a quick action, a big row), and TTC gave every
//  single topic a full-height card with an eyebrow, a title, a paragraph and a
//  fold.
//
//      A row is a line you scan. A card is a small article you have to read.
//
//  Eleven cards feels like far more than eleven rows at the same word count.
//  That is structural, not textual, and no amount of capping paragraphs fixes
//  it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_chapter_data.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

// ---- the chapter info sheet -------------------------------------------------

/// The ⓘ beside the chapter title.
///
/// Deliberately a quiet outline glyph on the hero's own gradient rather than a
/// filled button: it is an offer to read more, not an alert that something needs
/// attention.
class TtcChapterInfoButton extends StatelessWidget {
  const TtcChapterInfoButton({
    super.key,
    required this.chapter,
    required this.t,
  });

  final TtcChapter chapter;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showTtcChapterInfo(context, chapter, t),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
        child: Icon(Icons.info_outline_rounded,
            size: 19, color: Colors.white.withValues(alpha: 0.85)),
      ),
    );
  }
}

/// What this chapter is, in the four questions people actually have.
Future<void> showTtcChapterInfo(
    BuildContext context, TtcChapter chapter, TtcS t) async {
  final hi = t.hinglish;
  final content = ttcChapterContent[chapter];
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: ttcBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: ttcLine,
                      borderRadius: BorderRadius.circular(999))),
            ),
            const SizedBox(height: 20),
            ttcEyebrow(t.infoWhatThisIs),
            const SizedBox(height: 8),
            Text(chapter.title(hi),
                style: ttcFraunces(24, w: FontWeight.w600, color: ttcTitleInk)),
            const SizedBox(height: 10),
            Text(chapter.tagline(hi), style: ttcBody(13.5, h: 1.6)),

            if (content != null) ...[
              const SizedBox(height: 16),
              Text(hi ? content.overviewHi : content.overviewEn,
                  style: ttcBody(14, color: ttcInk, h: 1.7)),
            ],

            const SizedBox(height: 22),
            ttcDivider(),
            const SizedBox(height: 18),

            // Where the hero's "Next:" line went. Here it can say what it means
            // instead of compressing a chapter transition into one clause.
            _block(t.infoWhatMovesYouOn, chapter.nextUp(hi)),

            const SizedBox(height: 18),
            // Where WORTH DOING went. It was static for all 28 days of a
            // chapter, so on the hero it became wallpaper by day three. Here it
            // is read once, on purpose.
            _block(t.infoWorthDoing, chapter.goal(hi)),

            const SizedBox(height: 18),
            // The sentence that was nowhere on the screen at all, and is
            // probably the most useful one in the chapter.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ttcPanel,
                borderRadius: BorderRadius.circular(ttcCardRadius),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ttcEyebrow(t.infoNotToWorry, color: ttcPurple),
                    const SizedBox(height: 9),
                    Text(chapter.reassurance(hi),
                        style: ttcBody(13.5, color: ttcTitleInk, h: 1.65)),
                  ]),
            ),

            const SizedBox(height: 20),
            TtcDisclaimer(t: t),
          ],
        ),
      ),
    ),
  );
}

Widget _block(String label, String body) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
      const SizedBox(height: 7),
      Text(body, style: ttcBody(13.5, color: ttcInk, h: 1.6)),
    ]);

// ---- rows instead of cards --------------------------------------------------

/// One line in the "Today" list.
///
/// Deliberately NOT a card. Icon, label, one line, chevron — the shape
/// parenting's home uses for almost everything it shows.
class TtcTodayRow extends StatelessWidget {
  const TtcTodayRow({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.onTap,
    this.meta = '',
    this.last = false,
  });

  final IconData icon;
  final String eyebrow;
  final String title;

  /// A read time, a duration, a price. Right-aligned, never a count of
  /// something outstanding.
  final String meta;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ttcPanel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: ttcPurple),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eyebrow.toUpperCase(),
                        style: ttcBody(9, color: ttcMuted, w: FontWeight.w800)),
                    const SizedBox(height: 3),
                    // Up to TWO lines, not one.
                    //
                    // One line was stricter than the thing this was copied
                    // from: parenting's own rows wrap to two ("Hands clasp at
                    // his chest and he pushes up. A first roll any day now.").
                    // And on the device the cost showed immediately — the myth
                    // row read "Irregular periods mean you cannot conc…", which
                    // truncates the claim mid-word. For a myth the statement IS
                    // the hook, so cutting it loses the row's whole purpose.
                    //
                    // Two lines is still a row. It is scannable, it is not an
                    // article, and it does not cut a sentence in half to prove
                    // a point about density.
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ttcBody(13.5,
                            color: ttcInk, w: FontWeight.w700, h: 1.35)),
                  ]),
            ),
            if (meta.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(meta,
                  style: ttcBody(11, color: ttcMuted, w: FontWeight.w700)),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 19, color: ttcMuted),
          ]),
        ),
        if (!last) ttcDivider(),
      ]),
    );
  }
}

/// Where a row opens when there is no screen to send it to.
///
/// Three of the collapsed cards — the myth, today's nutrition, today's movement
/// — have no detail screen anywhere in the app. Turning them into rows without
/// this would have deleted their content rather than folded it, which is the
/// one thing the whole density exercise was not allowed to do.
///
/// A sheet rather than a pushed screen because that is honest about the size of
/// what is behind it: two paragraphs is not a destination.
Future<void> showTtcRowSheet(
  BuildContext context, {
  required String eyebrow,
  required String title,
  required List<Widget> body,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: ttcBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: ttcLine,
                      borderRadius: BorderRadius.circular(999))),
            ),
            const SizedBox(height: 20),
            ttcEyebrow(eyebrow),
            const SizedBox(height: 9),
            Text(title,
                style: ttcFraunces(22, w: FontWeight.w600, color: ttcTitleInk)),
            const SizedBox(height: 16),
            ...body,
          ],
        ),
      ),
    ),
  );
}

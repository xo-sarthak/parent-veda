// =============================================================================
//  PvReviewBlock — one review section, for a course, a consult or a product
// -----------------------------------------------------------------------------
//  Mobbin, 2026-09-22, the user's ask ("refer that section also from mobbin,
//  should look good not just bland, and once finalised it can be added to
//  products as well"). What the good ones actually do, and what we took:
//
//   Zocdoc "What patients are saying"  overall + TWO NAMED SUB-RATINGS
//                                      (bedside manner 4.9, wait time 4.5)
//   Urban Company                      word-bands, not star rows —
//                                      Excellent (138) / Good (24) / Bad (0)
//   Etsy · Temu                        counted topic chips you can filter by
//   Ulta                               PROS / CONS as counted word lists
//   Preply · Coursera · Meetup         a HORIZONTAL RAIL of quote cards
//   Meetup                             tags under each review
//
//  ⚠️ FOUR OF THOSE SIX NEED DATA WE DO NOT HOLD, and this is the whole
//  design decision. Sub-ratings, word-bands, counted chips and pros/cons are
//  all aggregates over every review ever left. We hold a headline rating, a
//  count, and a HANDFUL of reviews. `pv_reviews_screen.dart` already refused
//  distribution bars for exactly this reason and wrote down why: "bars drawn
//  from the handful of reviews we show would look like a measurement of the
//  whole". That decision is right and reversing it quietly to make a screen
//  prettier would be the worst kind of design work — a number that looks
//  measured and is not. The bars, the bands and the chips wait for the
//  reviews table (STILL-OPEN §69.10).
//
//  So this block is built on the two devices that run on what we DO hold:
//
//   1. THE RAIL. Reviews stop being a stack of bordered boxes — the "bland"
//      the user is describing — and become cards you swipe, led by the quote
//      set in Newsreader at reading size with a drawn quote mark. A
//      testimonial should look like a voice, not a form field.
//   2. WHO SAID IT. The one thing we have that Etsy and Temu do not: every
//      review carries WHEN SHE WAS — "32 weeks then", "delivered Apr 2025",
//      "second baby". A woman reading a birth course's reviews is not asking
//      what the average is. She is asking whether the woman who wrote it was
//      anything like her. So `context` is promoted out of the grey byline
//      into a line of its own under her name.
//
//  ⚠️ STARS ARE DRAWN ONLY WHEN THEY SAY SOMETHING. Five gold stars on every
//  card is five pieces of noise; a three-star review is information. A card
//  at full marks shows none, and the headline carries the average.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'pv_store_chrome.dart';

/// One voice, whatever model it came from. The learn catalogue and the store
/// both build these — see the two adapters at the foot of this file.
class PvReviewVoice {
  const PvReviewVoice({
    required this.name,
    required this.context,
    required this.quote,
    this.stars = 5,
    this.note = '',
    this.endorsed = false,
    this.endorsedLabel = '',
  });

  final String name;

  /// Where she was when she said it — the line this block exists for.
  final String context;
  final String quote;
  final int stars;

  /// The store's "watch out" — a caveat inside a positive review. Kept
  /// because a review that says one honest bad thing is worth more than
  /// three that gush, and hiding it would be the opposite of the point.
  final String note;

  /// "Would buy again" / "Would book again".
  final bool endorsed;
  final String endorsedLabel;
}

/// The section. Title, the headline figure, the rail, and one way out.
class PvReviewBlock extends StatelessWidget {
  const PvReviewBlock({
    super.key,
    required this.title,
    required this.voices,
    this.rating,
    this.countLabel = '',
    this.sourceLine = '',
    this.onAll,
    this.allLabel = 'Read all',
    this.hue = 268,
  });

  final String title;
  final List<PvReviewVoice> voices;
  final double? rating;

  /// "640 mothers" — the aggregate, printed as words rather than as a bar,
  /// because words cannot be mistaken for a measurement we did not take.
  final String countLabel;

  /// Who is allowed to leave one. Amazon-style "verified purchase", said in
  /// our own voice; empty hides it.
  final String sourceLine;

  final VoidCallback? onAll;
  final String allLabel;
  final double hue;

  @override
  Widget build(BuildContext context) {
    if (voices.isEmpty && rating == null) return const SizedBox.shrink();
    final p = pvStorePalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- the headline ---------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
          child: Text(
            title,
            style: pvFraunces(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: p.ink1,
            ),
          ),
        ),
        if (rating != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  rating!.toStringAsFixed(1),
                  style: pvFraunces(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    letterSpacing: -1,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (var i = 1; i <= 5; i++)
                            Icon(
                              i <= rating!.round()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 16,
                              color: kPvStar,
                            ),
                        ],
                      ),
                      if (countLabel.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          countLabel,
                          style: pvManrope(fontSize: 12.5, color: p.ink3),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onAll != null) PvSecondary(label: allLabel, onTap: onAll),
              ],
            ),
          ),
        // ---- the rail -------------------------------------------------------
        if (voices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: PvReviewRail(voices: voices, hue: hue),
          ),
        if (sourceLine.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Text(
              sourceLine,
              style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3),
            ),
          ),
      ],
    );
  }
}

/// The rail on its own, for a screen that already has a headline of its own
/// — the product page holds `parentsPct` ("92% would buy again"), which the
/// learn side has no equivalent of, and throwing that away to share a widget
/// would be sharing for its own sake.
///
/// ⚠️ EDGE TO EDGE, ALWAYS. The rail pads ITSELF by 20 and must therefore be
/// handed out of any surrounding gutter — the standing rule, and the exact
/// thing that makes a horizontal list look walled in.
class PvReviewRail extends StatelessWidget {
  const PvReviewRail({super.key, required this.voices, this.hue = 268});
  final List<PvReviewVoice> voices;
  final double hue;

  @override
  Widget build(BuildContext context) {
    final tint = HSLColor.fromAHSL(1, hue, 0.30, 0.94).toColor();
    final seed = HSLColor.fromAHSL(1, hue, 0.34, 0.42).toColor();
    // ⚠️ A FIXED HEIGHT, AND IT IS NOT A STYLE CHOICE. A rail lives in a
    // `SliverToBoxAdapter`, which hands its child UNBOUNDED height. Inside
    // that, `CrossAxisAlignment.stretch` has nothing to stretch to and the
    // `Spacer` that pins each card's byline to its foot resolves to
    // infinity — and the failure is not a red box in this widget, it takes
    // the whole viewport with it: the offering page rendered as a blank
    // white screen with only the commit bar, which sits outside the scroll
    // view, still drawn. Bounding the rail here is what makes both legal.
    // The quote is clamped to match; the rest is one tap away.
    // ⚠️ ONE REVIEW IS NOT A RAIL. With a single card the fixed height has
    // nothing to equalise, and the `Spacer` that pins a byline to the foot of
    // the tallest card opens a hole under a short quote that reads as a
    // loading state. So a lone voice is laid out as what it is: one card,
    // sized to its words, across the width it has.
    if (voices.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _Voice(
          voice: voices.first,
          tint: tint,
          seed: seed,
          width: double.infinity,
          spread: false,
        ),
      );
    }
    return SizedBox(
      height: _railHeight(voices),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < voices.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              _Voice(voice: voices[i], tint: tint, seed: seed),
            ],
          ],
        ),
      ),
    );
  }
}

/// How tall the rail stands: its tallest card, estimated.
///
/// ⚠️ ESTIMATED, BECAUSE IT CANNOT BE MEASURED HERE. The obvious answer is
/// `IntrinsicHeight`, and it does not work: inside a horizontally scrolling
/// viewport the Row is offered INFINITE width, so every quote measures as one
/// line and the rail comes out a third of the height it needs. So the line
/// count is worked out from the character count against the card's known text
/// width — exact enough for four lines of one size in one font, and generous
/// by design, because a rail slightly too tall loses a little white and one
/// slightly too short clips a woman's last sentence.
///
/// A single review is the case this exists for: a rail of one card at a fixed
/// 250 left a hole between the quote and the byline big enough to read as a
/// loading state.
double _railHeight(List<PvReviewVoice> voices) {
  var lines = 1;
  for (final v in voices) {
    // 242pt of text width at 15.5pt Newsreader runs to about 42 characters a
    // line — counted off the device, not guessed: "The one place that told me
    // what to actually" is one line of this card.
    final l = (v.quote.length / 42).ceil().clamp(1, 4);
    if (l > lines) lines = l;
  }
  // Padding, the quote mark, the quote, the gap, the byline — and 12 of
  // slack, because the cost of the two estimates above being a few points
  // low is a clipped half-line of somebody's sentence, and the cost of them
  // being a few points high is nothing anyone will see.
  var h = 28 + 38 + lines * 24.0 + 12 + 32 + 12;
  if (voices.any((v) => v.stars < 5)) h += 22;
  if (voices.any((v) => v.note.isNotEmpty)) h += 42;
  if (voices.any((v) => v.endorsed && v.endorsedLabel.isNotEmpty)) h += 32;
  return h;
}

/// One card on the rail.
///
/// ⚠️ A FIXED WIDTH AND AN UNFIXED HEIGHT. The rail's Row stretches, so every
/// card in a rail takes the height of the tallest — otherwise a two-line
/// quote beside a five-line one leaves a ragged bottom edge, which is most of
/// what made the old stack look unfinished.
class _Voice extends StatelessWidget {
  const _Voice({
    required this.voice,
    required this.tint,
    required this.seed,
    this.width = 274,
    this.spread = true,
  });
  final PvReviewVoice voice;
  final Color tint;
  final Color seed;
  final double width;

  /// Push the byline to the foot of the card. True on a rail, where every
  /// card is the height of the tallest and the bylines must line up; false
  /// for a single card, which is only as tall as its own words.
  final bool spread;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final v = voice;
    return SizedBox(
      width: width,
      child: Container(
        key: const ValueKey('pv_review_voice_card'),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        // ⚠️ WHITE WITH A HAIRLINE, NOT A TINT (2026-09-29). A quote is text,
        // and a tinted slab behind text is the one thing the base UI rules
        // out ("tints are for tags and pills"). The product page and Learn
        // both draw this card, so both change. The tint moves to what IS a
        // tag: the initials disc and the endorsed pill.
        // Kept for revert (2026-09-29): color: tint, and no border.
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPvLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: spread ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // The quote mark, in the block's own ink. Typographic rather than
            // drawn: it IS a letterform, and Newsreader already owns it.
            Text(
              '“',
              style: pvFraunces(
                fontSize: 40,
                height: 0.9,
                fontWeight: FontWeight.w500,
                color: seed.withValues(alpha: 0.42),
              ),
            ),
            if (v.stars < 5)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      Icon(
                        i <= v.stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: kPvStar,
                      ),
                  ],
                ),
              ),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                v.quote,
                maxLines: spread ? 4 : 8,
                overflow: TextOverflow.ellipsis,
                style: pvFraunces(
                  fontSize: 15.5,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: p.ink1,
                ),
              ),
            ),
            if (v.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                // The one honest caveat, kept visible.
                'Watch out: ${v.note}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2),
              ),
            ],
            if (spread) const Spacer(),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  // The tint, now the card is white (2026-09-29). Kept for
                  // revert: Colors.white.withValues(alpha: 0.75).
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tint,
                  ),
                  child: Text(
                    _initials(v.name),
                    style: pvManrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: seed,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: p.ink1,
                        ),
                      ),
                      if (v.context.isNotEmpty)
                        Text(
                          v.context,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(fontSize: 11.5, color: p.ink3),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (v.endorsed && v.endorsedLabel.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                // The tint, a tag on a white card (2026-09-29). Kept for
                // revert: Colors.white.withValues(alpha: 0.75).
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '✓  ${v.endorsedLabel}',
                  style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: seed,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .replaceAll('Dr. ', '')
        .split(RegExp(r'[ .]'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((w) => w[0].toUpperCase()).join();
  }
}

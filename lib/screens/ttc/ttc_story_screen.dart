// =============================================================================
//  TtcStoryScreen — a carousel as a full screen, not a sheet
// -----------------------------------------------------------------------------
//  ⚠️ WHY THE BOTTOM SHEET HAD TO GO.
//
//  A carousel used to open in `showTtcRowSheet` — a half-height panel sliding
//  up over the page. That was wrong for a reason worth stating, because the
//  sheet is the right answer elsewhere in this app and will be reached for
//  again:
//
//    A sheet says "a small aside, and you are still on the page behind me". It
//    is right for a definition, a confirm, a quick log. It is wrong for the
//    main content, because it caps the height at something less than a screen,
//    keeps a dimmed page competing behind it, and tells the reader before they
//    start that what they tapped was minor.
//
//  Tapping a piece of content should open that piece of content, full screen,
//  every time. Article, carousel, video — the same promise.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE SHAPE IS THE STORY FORMAT, AND THE PARTS ARE NOT DECORATION
//  ---------------------------------------------------------------------------
//
//  Segmented progress bar, close, an eyebrow, one big line of type, one big
//  picture, arrows. Every part is doing a job:
//
//    · **Segments, not a page count.** "3 of 7" is a number to get through;
//      seven short bars is a shape you can see the end of. The reference uses
//      the same device, and so does every story UI, because it is the one
//      progress indicator people already know how to read.
//    · **One idea per slide.** The old carousel cards held a title and a
//      paragraph and were scrollable inside a sheet — three levels of reading
//      inside a thing you swipe. A slide holds a sentence and a picture.
//    · **Arrows AND taps AND swipe.** Three ways forward because this format is
//      used by people who have never used it. The reference draws visible
//      chevrons for the same reason.
//
//  ⚠️ IT IS NOT TIMED. Instagram advances on its own; this does not, and must
//  not. The content here is clinical and is read at whatever speed it is read
//  at — an auto-advancing slide about sperm counts is a slide someone loses
//  halfway through and cannot politely get back.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_focus_data.dart';
import '../../ttc/ttc_expert_signoff.dart' show ttcStoryReviewer;
import 'ttc_illustrations.dart';
import 'ttc_story_skin.dart';

class TtcStoryScreen extends StatefulWidget {
  const TtcStoryScreen({
    super.key,
    required this.title,
    required this.cards,
    required this.hue,
    this.reviewedBy,
    this.coverTitle,
    this.coverBlurb,
    this.coverArt,
    this.coverHue,
    this.myth,
    this.fact,
  });

  final String title;
  final List<TtcCarouselCard> cards;
  final double hue;

  /// "Reviewed by `name`" — the reference puts this on every slide, and it is
  /// the single cheapest trust signal on a clinical carousel.
  final String? reviewedBy;

  /// A title card before the first slide.
  final String? coverTitle;
  final String? coverBlurb;
  final TtcArt? coverArt;
  final double? coverHue;

  /// ⚠️ A MYTH'S COVER SAYS BOTH HALVES (launch sanity D4, D14, 2026-09-28).
  /// A myth deck used to open on its title with the one-line blurb at the
  /// very foot of an empty slide, and the card's own title could be a true
  /// statement under a "Myth vs fact" chip. With [myth] and [fact] set, the
  /// cover draws a labelled MYTH block and a labelled FACT block under the
  /// title, in the reading zone, so the answer is on the first screen and
  /// the two can never be confused. Any authored slides follow as the why.
  /// MacroFactor's labelled definition cards are the shape: a small label,
  /// then the words in a card of their own
  /// (https://mobbin.com/screens/9e560e12-1d1d-4347-bd48-80595ad2dccc).
  final String? myth;
  final String? fact;

  @override
  State<TtcStoryScreen> createState() => _TtcStoryScreenState();
}

class _TtcStoryScreenState extends State<TtcStoryScreen> {
  final _controller = PageController();
  int _index = 0;

  /// The cover, prepended, so every index arithmetic below stays one list.
  ///
  /// ⚠️ BUILT ONCE IN `initState`, NOT IN `build`. A getter that composed this
  /// list on every frame would hand `PageView.builder` a new list identity each
  /// rebuild — which is harmless here and is the exact habit that causes a
  /// controller to lose its page on the screen where it is not harmless.
  late final List<TtcCarouselCard> _slides = [
    if (widget.coverTitle != null)
      TtcCarouselCard(
        title: widget.coverTitle!,
        body: widget.coverBlurb ?? '',
        art: widget.coverArt,
        hue: widget.coverHue,
      ),
    ...widget.cards,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0) return;
    if (next >= _slides.length) {
      Navigator.of(context).maybePop();
      return;
    }
    _controller.animateToPage(next,
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ THE GROUND IS THE SLIDE'S SKIN, NOT THE APP PALETTE. See the head of
    // `ttc_story_skin.dart` — a washed stage tint cannot make a screen feel
    // like a place, because the pastel wheel was designed precisely so that no
    // screen shouts. A story is the one surface that is allowed to.
    final skin = ttcSkinFor(_index);
    final ground = skin.top;

    return Scaffold(
      backgroundColor: ground,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        color: ground,
        child: SafeArea(
        child: Column(children: [
          // ---- progress and close ------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(children: [
              for (var i = 0; i < _slides.length; i++) ...[
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= _index
                          ? skin.onTop
                          : skin.onTop.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                if (i != _slides.length - 1) const SizedBox(width: 5),
              ],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 0),
            child: Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(widget.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          color: skin.onTop.withValues(alpha: 0.7))),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: skin.onTop,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ]),
          ),

          // ---- the slides ---------------------------------------------------
          Expanded(
            child: Stack(children: [
              PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _Slide(
                    card: _slides[i],
                    skin: ttcSkinFor(i),
                    index: i,
                    // ⚠️ NO "REVIEWED BY" UNTIL SIGNED OFF (launch sanity,
                    // H14's follow-up, 2026-09-28). Door carousels named
                    // Dr Ruchika Sood and Dr Surbhi Sharma, who have not
                    // read them. Until the title is in their set in
                    // `kTtcSignedOffStories` it reads "BY · ParentVeda
                    // team". Kept for revert: reviewedBy: widget.reviewedBy,
                    reviewedBy:
                        ttcStoryReviewer(widget.reviewedBy, widget.title),
                    // Only the cover carries the myth and the fact.
                    myth: i == 0 && widget.coverTitle != null
                        ? widget.myth
                        : null,
                    fact: i == 0 && widget.coverTitle != null
                        ? widget.fact
                        : null),
              ),

              // ⚠️ TAP TARGETS OVER THE WHOLE HEIGHT, not just the chevrons.
              // Everyone who has used a story taps the edges; the chevrons are
              // for everyone who has not.
              Positioned.fill(
                child: Row(children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _go(-1),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _go(1),
                    ),
                  ),
                ]),
              ),

              if (_index > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Chevron(
                      icon: Icons.chevron_left_rounded, onTap: () => _go(-1)),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: _Chevron(
                    icon: Icons.chevron_right_rounded, onTap: () => _go(1)),
              ),
            ]),
          ),
        ]),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.card,
    required this.skin,
    required this.index,
    this.reviewedBy,
    this.myth,
    this.fact,
  });

  final TtcCarouselCard card;
  final TtcSlideSkin skin;
  final int index;
  final String? reviewedBy;

  /// The cover of a myth deck: both halves, labelled (see the screen).
  final String? myth;
  final String? fact;

  @override
  Widget build(BuildContext context) {
    final heading = pvManrope(
        fontSize: 25,
        fontWeight: FontWeight.w800,
        height: 1.22,
        letterSpacing: -0.4,
        color: skin.onTop);
    final headingStrong = heading.copyWith(fontStyle: FontStyle.italic);

    final bodyStyle = pvManrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: skin.onBottom);
    final bodyStrong = bodyStyle.copyWith(
        fontWeight: FontWeight.w800, fontStyle: FontStyle.italic);

    // ⚠️ A SLIDE WITH NO PICTURE READS FROM THE TOP (launch sanity D4,
    // 2026-09-28). The bands put the heading in the top field, the picture in
    // the middle and the payoff in the bottom one; with no picture the middle
    // was 70% empty colour and the answer sat at the very foot of the screen
    // ("The short answer is no." alone at the bottom of a maroon slide). So a
    // text slide is ONE field of the slide's top colour, the heading, and the
    // words straight under it, where the eye already is. Lloyds' recommended
    // reads are the shape: one colour field, a heading, the paragraph under it
    // (https://mobbin.com/screens/3e0474a3-661d-40be-9f44-48557f873633).
    // A slide WITH a drawing keeps the bands, which exist for it (Stardust's
    // Daily Decode: the picture, then the words,
    // https://mobbin.com/screens/66ebdc01-ab26-4960-894e-2d98c0357307).
    // Kept for revert: every slide took the banded layout below.
    if (card.art == null) {
      return _textSlide(heading, headingStrong);
    }

    return Stack(fit: StackFit.expand, children: [
      // ---- the bands -----------------------------------------------------
      TtcStoryBackground(skin: skin, seed: index),

      // ---- confetti, in the middle field only -----------------------------
      if (!skin.twoBand)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 90),
            child: TtcConfetti(
                colour: skin.onMid.withValues(alpha: 0.16), seed: index),
          ),
        ),

      // ---- content --------------------------------------------------------
      //
      // ⚠️ THE THREE PIECES SIT IN THE THREE BANDS, which is the whole reason
      // the bands exist. Heading in the top field, picture floating in the
      // middle, the payoff line in the bottom. Laid out with flex rather than
      // fixed offsets so a two-band skin collapses gracefully.
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (reviewedBy != null && index == 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: skin.onTop.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              // ⚠️ ONE BYLINE, AND ONLY A PERSON "REVIEWS" (launch walk,
              // 2026-09-27). Values that already say "Reviewed by …" read
              // twice, and "REVIEWED BY · ParentVeda team" claimed a review
              // nobody did; the team is "BY", as in the reader.
              // Kept for revert: Text('REVIEWED BY  ·  $reviewedBy',
              child: Text(ttcStoryByline(reviewedBy!),
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: skin.onTop)),
            ),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 10),

          // ⚠️ THE HEADING IS THE SLIDE. Big, sans, heavy, with the stressed
          // phrase in italic — the reference's voice, and the thing that makes
          // a slide read as somebody talking rather than as a caption.
          RichText(
            text: TextSpan(
                children: ttcEmphasise(card.title, heading, headingStrong)),
          ),

          // ---- the picture, floating in the middle band ------------------
          if (card.art != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: TtcIllustration(
                    art: card.art!,
                    tint: skin.bottom == skin.mid
                        ? skin.top
                        : skin.bottom,
                    ink: skin.onMid),
              ),
            )
          else
            const Spacer(),

          // ---- the payoff, in the bottom band ----------------------------
          if (card.body.isNotEmpty)
            RichText(
              text: TextSpan(
                  children: ttcEmphasise(card.body, bodyStyle, bodyStrong)),
            ),
          const SizedBox(height: 6),
        ]),
      ),
    ]);
  }
}

extension on _Slide {
  /// The byline pill, on the first slide only.
  Widget? _byline(Color on) {
    if (reviewedBy == null || index != 0) return null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: on.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(ttcStoryByline(reviewedBy!),
          style: pvManrope(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: on)),
    );
  }

  /// A slide with no drawing: one field, the heading, the words under it,
  /// and on a myth's cover the labelled Myth and Fact blocks. Scrolls when a
  /// long fact runs past the screen; the story's tap zones stay on top.
  Widget _textSlide(TextStyle heading, TextStyle headingStrong) {
    final on = skin.onTop;
    final bodyStyle = pvManrope(
        fontSize: 18, fontWeight: FontWeight.w500, height: 1.5, color: on);
    final bodyStrong = bodyStyle.copyWith(
        fontWeight: FontWeight.w800, fontStyle: FontStyle.italic);
    final byline = _byline(on);
    return ColoredBox(
      key: const ValueKey('ttc_story_text_slide'),
      color: skin.top,
      child: SingleChildScrollView(
        // Room on the right for the chevron.
        padding: const EdgeInsets.fromLTRB(24, 12, 56, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (byline != null) ...[byline, const SizedBox(height: 18)],
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
                children: ttcEmphasise(card.title, heading, headingStrong)),
          ),
          if (card.body.isNotEmpty) ...[
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                  children: ttcEmphasise(card.body, bodyStyle, bodyStrong)),
            ),
          ],
          if (myth case final m? when m.isNotEmpty)
            _mythBlock(kTtcStoryMythLabel, m, on),
          if (fact case final f? when f.isNotEmpty)
            _mythBlock(kTtcStoryFactLabel, f, on),
        ]),
      ),
    );
  }

  /// One labelled half of a myth: the label small and spaced, the words in a
  /// soft card of the slide's own ink.
  Widget _mythBlock(String label, String words, Color on) => Padding(
        key: ValueKey('ttc_story_${label.toLowerCase()}'),
        padding: const EdgeInsets.only(top: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: on.withValues(alpha: 0.78))),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: on.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(words,
                style: pvManrope(
                    fontSize: 16.5,
                    fontWeight: label == kTtcStoryFactLabel
                        ? FontWeight.w700
                        : FontWeight.w500,
                    height: 1.5,
                    color: on)),
          ),
        ]),
      );
}

/// The two labels on a myth's cover. English only (new copy).
const String kTtcStoryMythLabel = 'Myth';
const String kTtcStoryFactLabel = 'Fact';

class _Chevron extends StatelessWidget {
  const _Chevron({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Material(
          // White always — the chevrons sit across a band boundary on most
          // slides, so a colour derived from either field is wrong on the
          // other. White with a shadow is the one treatment that reads on
          // teal, cream and rose alike.
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
                width: 38,
                height: 38,
                child: Icon(icon, size: 24, color: TtcStoryPalette.ink)),
          ),
        ),
      );
}

/// The pill on a story's first slide: "REVIEWED BY · Dr Name, role" for a
/// person, "BY · ParentVeda team" for the team, and never the words twice.
String ttcStoryByline(String raw) {
  var who = raw.trim();
  final lead = RegExp(r'^(reviewed\s+by|by)\s*[:·]?\s*', caseSensitive: false);
  who = who.replaceFirst(lead, '');
  final team = who.toLowerCase().contains('parentveda');
  return '${team ? 'BY' : 'REVIEWED BY'}  ·  $who';
}

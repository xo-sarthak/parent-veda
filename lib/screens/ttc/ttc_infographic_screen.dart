// =============================================================================
//  An infographic — one frame, and that is the whole rule
// -----------------------------------------------------------------------------
//  ⚠️ ONE SLIDE. NOT A SHORT CAROUSEL.
//
//  Stated directly when the format was asked for: *"infographic only consists
//  of 1 slide, so keep that in mind — in one slide provide required info."*
//
//  That is a real constraint and not a style note, because it changes what the
//  content has to be. A carousel can afford six beats and a build-up; an
//  infographic has to answer its own title in one look. The two tiles that
//  became infographics were both "X or Y" questions, and a comparison is the
//  thing a single frame does better than any number of slides — the two halves
//  are side by side, so the difference IS the picture rather than something the
//  reader has to hold in their head across a swipe.
//
//  ⚠️ SO IT MUST NOT GROW. If a subject needs a seventh point, it was never an
//  infographic — it is a carousel or a read. The model below deliberately has
//  no `cards` list and no `slides`: there is nowhere for a second frame to go.
//
//  ⚠️ AND IT DOES NOT SCROLL BY DESIGN, ONLY BY NECESSITY. At 360pt with the
//  largest accessibility text a two-column comparison will overflow, so the
//  page scrolls rather than clipping. That is a safety net, not permission to
//  write past the fold.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_focus_data.dart';
import '../../ttc/ttc_expert_signoff.dart'
    show ttcStoryReviewer, ttcStoryBylineIsPerson;
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';
import 'ttc_common.dart';

class TtcInfographicScreen extends StatelessWidget {
  const TtcInfographicScreen({
    super.key,
    required this.tile,
    required this.hue,
    this.topic,
  });

  final TtcInfographicTile tile;
  final double hue;

  /// What the comparison is about, for the eyebrow ("PCOS"). Optional: when a
  /// caller does not pass one, the part of an "X or Y" title before "or" is
  /// the topic, which is true of every infographic that exists.
  final String? topic;

  /// Below this sheet width the two columns stack, left over right, so long
  /// points stop wrapping every three words. Every phone we test on is under
  /// it; a tablet or an unfolded phone keeps them side by side.
  static const double kStackBelow = 400;

  String? get _topic {
    if (topic != null) return topic;
    final i = tile.title.indexOf(' or ');
    return i > 0 ? tile.title.substring(0, i) : null;
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;

    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(children: [
        Positioned.fill(
          child: V3HeroField(
            accent: v2BlockTint(hue % 360, p),
            ground: p.ground,
            variant: 3,
            chroma: v3FieldChroma(hue % 360),
          ),
        ),
        ListView(
          // Zero — the sheet owns the clearance (ttc_tool_chrome.dart).
          padding: EdgeInsets.zero,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Back(p: p),
                      const SizedBox(height: 14),
                      // ⚠️ THE TOPIC, NOT THE FORMAT (2026-09-27).
                      // "INFOGRAPHIC" told her what kind of page this is and
                      // nothing about what it is on. Kept for revert:
                      //   Text('INFOGRAPHIC', ...)
                      if (_topic != null) ...[
                        Text(_topic!.toUpperCase(),
                            style: pvManrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                                color: p.ink2)),
                        const SizedBox(height: 8),
                      ],
                      Text(tile.title,
                          style: pvFraunces(
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              height: 1.18,
                              letterSpacing: -0.5,
                              color: p.ink1)),
                    ]),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: p.ground,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, -6)),
                ],
              ),
              constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height),
              padding:
                  const EdgeInsets.fromLTRB(18, 24, 18, 28 + ttcBottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⚠️ THE ANSWER FIRST, IN ONE LINE. An infographic whose
                  // headline is a restatement of its title has spent the
                  // reader's first look on nothing. This line is the thing she
                  // came for; the two columns are why it is true.
                  Text(tile.headline,
                      style: ttcFraunces(19,
                          w: FontWeight.w600, color: ttcTitleInk, h: 1.3)),
                  const SizedBox(height: 20),

                  // ⚠️ SIDE BY SIDE, AND `IntrinsicHeight` SO THEY MATCH. A
                  // comparison where one column is visibly taller reads as one
                  // side mattering more. The playbook's own warning applies:
                  // `CrossAxisAlignment.stretch` on a Row inside a ListView
                  // throws on an infinite height, and `IntrinsicHeight` is the
                  // remedy — over two small boxes, not a list.
                  //
                  // ⚠️ STACKED ON A PHONE (2026-09-27). Two columns of about
                  // 160pt wrapped every point every few words, and comparing
                  // rows of different lengths across them was hard. Below
                  // [kStackBelow] the two halves sit one above the other,
                  // each whole; wider, they stay side by side.
                  LayoutBuilder(
                    builder: (context, box) => box.maxWidth < kStackBelow
                        ? Column(
                            key: const ValueKey('ttc_infographic_stacked'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Column(column: tile.left, p: p),
                              const SizedBox(height: 10),
                              _Column(column: tile.right, p: p),
                            ],
                          )
                        : IntrinsicHeight(
                            key: const ValueKey('ttc_infographic_side_by_side'),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                    child: _Column(column: tile.left, p: p)),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: _Column(column: tile.right, p: p)),
                              ],
                            ),
                          ),
                  ),

                  if (tile.footnote != null) ...[
                    const SizedBox(height: 20),
                    // ⚠️ THE FOOTNOTE IS WHERE THE CLINICAL LINE LIVES, and on
                    // both of these it is the same shape: what a scan or a test
                    // can and cannot settle, and what to ask for. A comparison
                    // that stops at the difference leaves her better informed
                    // and no better off.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: ttcPanel,
                          borderRadius: BorderRadius.circular(ttcCardRadius)),
                      child: Text(tile.footnote!,
                          style: ttcBody(13.5, h: 1.6, color: ttcInk)),
                    ),
                  ],

                  // ⚠️ NO "REVIEWED BY" AND NO TICK UNTIL SIGNED OFF (launch
                  // sanity, H14's follow-up, 2026-09-28). Both PCOS
                  // comparisons said "Reviewed by Dr Ruchika Sood" beside a
                  // verified mark, and she has not read them. Until the
                  // title is in her set in `kTtcSignedOffStories` the line
                  // reads "By ParentVeda team", with no mark. Kept for
                  // revert: the verified icon and `tile.reviewedBy!` always.
                  if (ttcStoryReviewer(tile.reviewedBy, tile.title)
                      case final shown?) ...[
                    const SizedBox(height: 18),
                    Row(children: [
                      if (ttcStoryBylineIsPerson(shown)) ...[
                        Icon(Icons.verified_outlined, size: 15, color: p.ink3),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                            ttcStoryBylineIsPerson(shown)
                                ? shown
                                : 'By ParentVeda team',
                            key: const ValueKey('ttc_infographic_byline'),
                            style: ttcBody(11.5, color: ttcMuted,
                                w: FontWeight.w700)),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.column, required this.p});

  final TtcInfographicColumn column;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final hue = (column.hue ?? 288) % 360;
    final tint = v2BlockTint(hue, p);
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.44)
        .withLightness(0.32)
        .toColor();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(ttcCardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(column.label,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: -0.2,
                  color: ink)),
          const SizedBox(height: 10),
          for (final point in column.points) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // A dot rather than a bullet glyph, so it takes the column's own
              // colour instead of the font's.
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 7, right: 8),
                decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
              ),
              Expanded(
                child: Text(point,
                    style: ttcBody(12.5, h: 1.45, color: ttcTitleInk)),
              ),
            ]),
            const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Back',
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.arrow_back, size: 22, color: p.ink1),
          ),
        ),
      );
}

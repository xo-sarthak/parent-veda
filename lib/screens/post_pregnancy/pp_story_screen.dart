// =============================================================================
//  PpStoryScreen — a parenting carousel as a full screen
// -----------------------------------------------------------------------------
//  ⚠️ THE SAME SHAPE AS THE TTC STORY SCREEN, IN THE PARENTING PALETTE.
//
//  `lib/screens/ttc/ttc_story_screen.dart` worked out what a content carousel
//  is: segmented progress, close, an eyebrow, one big line of type, a payoff
//  line, chevrons, and taps on both edges. Every part is doing a job and none
//  of it is decoration; read that file's header before changing the shape.
//
//  It is copied rather than imported, for the reason the pregnancy door
//  selector gives for copying the TTC coverflow: TTC is being worked on in
//  parallel, and a parenting screen that imports a TTC widget is a parenting
//  screen that breaks when TTC changes a constructor. The payload differs too
//  — a parenting card can link to a sibling page, which a TTC card cannot.
//
//  ⚠️ WHAT IS DIFFERENT, AND WHY:
//
//  * **The ground is the V3 palette, not a story skin.** TTC's slides are
//    allowed to shout, and its skins are built for that. Parenting V3 is cream
//    and pastel everywhere, and a carousel that opened onto a saturated teal
//    band would read as a different product two taps from the home. So each
//    slide sits on a `v2BlockTint`, walking the hue a little per slide — you
//    still feel you have moved, without leaving the app you were in.
//  * **Swipe UP opens the page a slide links to.** The worry set is four
//    summaries, each of a page that still exists. The brief's rule is "no
//    second copies", so the slide is short and the full page is one gesture
//    away — the gesture stories already use for "more". A visible pill says
//    the same thing for anyone who has never swiped up on anything.
//
//  ⚠️ IT IS NOT TIMED, for the reason the TTC file gives: this is read at
//  whatever speed it is read at.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';

class PpStoryScreen extends StatefulWidget {
  /// The dim ground. Not black: OLED black under white type is the harshest
  /// contrast a screen can show, and this is read half asleep.
  static const Color dimGround = Color(0xFF17203A);

  const PpStoryScreen({
    super.key,
    required this.title,
    required this.cards,
    required this.hue,
    this.coverTitle,
    this.coverBlurb,
    this.onPage,
    this.dim = false,
  });

  /// The brief's "dark and dim" for a story read at 3am: the same slides on
  /// a deep ground with light type. Nothing else changes.
  final bool dim;

  /// The eyebrow on every slide — what this carousel is.
  final String title;
  final List<PpCarouselCard> cards;
  final double hue;

  final String? coverTitle;
  final String? coverBlurb;

  /// How a linked slide opens its page. Injected, like every other navigation
  /// in `pp_content.dart`, so the screen knows nothing about the section.
  final void Function(BuildContext context, String pageId)? onPage;

  @override
  State<PpStoryScreen> createState() => _PpStoryScreenState();
}

class _PpStoryScreenState extends State<PpStoryScreen> {
  final _controller = PageController();
  int _index = 0;

  /// The cover, prepended, so every index below is one list. Built once in the
  /// field initialiser for the reason the TTC screen gives: a list composed in
  /// `build` hands the `PageView` a new identity every frame.
  late final List<PpCarouselCard> _slides = [
    if (widget.coverTitle != null)
      PpCarouselCard(widget.coverTitle!, widget.coverBlurb ?? ''),
    ...widget.cards,
  ];

  bool get _hasCover => widget.coverTitle != null;

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

  void _openLinked(BuildContext context) {
    final card = _slides[_index];
    final id = card.pageId;
    if (id == null || widget.onPage == null) return;
    widget.onPage!(context, id);
  }

  double _hueFor(int i) => (widget.hue + i * 23) % 360;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final ground = widget.dim
        ? PpStoryScreen.dimGround
        : v2BlockTint(_hueFor(_index), p);
    final card = _slides[_index];
    final linked = card.pageId != null && widget.onPage != null;
    final ink1 = widget.dim ? Colors.white : p.ink1;
    final ink2 = widget.dim ? Colors.white.withValues(alpha: 0.7) : p.ink2;

    return Scaffold(
      backgroundColor: ground,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        color: ground,
        child: SafeArea(
          child: Column(children: [
            // ---- progress and close ----------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(children: [
                for (var i = 0; i < _slides.length; i++) ...[
                  Expanded(
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: ink1.withValues(alpha: i <= _index ? 0.7 : 0.18),
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
                            color: ink2)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: ink1,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ]),
            ),

            // ---- the slides --------------------------------------------------
            Expanded(
              child: GestureDetector(
                // ⚠️ SWIPE UP OPENS THE LINKED PAGE. A vertical drag on a
                // horizontal PageView is otherwise ignored, so claiming it here
                // costs nothing and gives the gesture stories already mean by
                // "more". Only fires on a slide that has somewhere to go.
                onVerticalDragEnd: !linked
                    ? null
                    : (d) {
                        final v = d.primaryVelocity ?? 0;
                        if (v < -250) _openLinked(context);
                      },
                child: Stack(children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => _Slide(
                      card: _slides[i],
                      p: p,
                      dim: widget.dim,
                      isCover: _hasCover && i == 0,
                      position: _hasCover ? i : i + 1,
                      count: widget.cards.length,
                      linked: _slides[i].pageId != null && widget.onPage != null,
                    ),
                  ),

                  // ⚠️ TAP TARGETS OVER THE WHOLE HEIGHT, not only the
                  // chevrons. Everyone who has used a story taps the edges;
                  // the chevrons are for everyone who has not.
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
                          icon: Icons.chevron_left_rounded,
                          p: p,
                          onTap: () => _go(-1)),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _Chevron(
                        icon: Icons.chevron_right_rounded,
                        p: p,
                        onTap: () => _go(1)),
                  ),

                  // ⚠️ THE PILL SITS ABOVE THE TAP ZONES, LIKE THE CHEVRONS.
                  // It was drawn inside the slide first, underneath the
                  // full-height edge-tap layer, and every tap on it went to
                  // the arena as "next slide" instead. Nothing failed; the
                  // pill simply never opened anything. Caught by the widget
                  // test in `test/pp_sleep_door_test.dart`.
                  if (linked)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 18,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _openLinked(context),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: p.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: p.line),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.keyboard_arrow_up_rounded,
                                  size: 18, color: p.action),
                              const SizedBox(width: 4),
                              Text('Swipe up for the full page',
                                  style: pvManrope(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: p.ink1)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
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
    required this.p,
    required this.isCover,
    this.dim = false,
    required this.position,
    required this.count,
    required this.linked,
  });

  final PpCarouselCard card;
  final V2Palette p;
  final bool isCover;
  final bool dim;

  /// 1-based, excluding the cover.
  final int position;
  final int count;

  /// Leaves room at the foot for the pill the screen draws over this slide.
  final bool linked;

  @override
  Widget build(BuildContext context) {
    final ink = dim ? Colors.white : p.ink1;
    final accent = dim ? const Color(0xFFB9C4F2) : p.action;
    final heading = pvFraunces(
        fontSize: isCover ? 30 : 26,
        fontWeight: FontWeight.w600,
        height: 1.18,
        letterSpacing: -0.6,
        color: ink);
    final body = pvManrope(
        fontSize: 16, fontWeight: FontWeight.w500, height: 1.55, color: ink);

    final eyebrow = isCover
        ? '$count ${count == 1 ? 'SLIDE' : 'SLIDES'}'
        : card.myth
            ? 'THE MYTH'
            : '$position OF $count';

    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow,
            style: pvManrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: accent)),
        const SizedBox(height: 14),
        // ⚠️ THE HEADING IS THE SLIDE. On a myth card it is the myth, set as
        // speech, so the reader hears it the way it is said to her.
        Text(card.myth ? '"${card.title}"' : card.title, style: heading),
        const Spacer(),
        if (card.body.isNotEmpty) ...[
          if (card.myth) ...[
            Text('WHAT IS TRUE',
                style: pvManrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: accent)),
            const SizedBox(height: 8),
          ],
          Text(card.body, style: body),
        ],
        // Room for the pill the screen overlays on a linked slide.
        SizedBox(height: linked ? 58 : 6),
      ]),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.icon, required this.p, required this.onTap});

  final IconData icon;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Material(
          color: p.surface,
          shape: CircleBorder(side: BorderSide(color: p.line)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
                width: 38,
                height: 38,
                child: Icon(icon, size: 24, color: p.ink1)),
          ),
        ),
      );
}

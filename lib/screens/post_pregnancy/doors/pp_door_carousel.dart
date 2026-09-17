// =============================================================================
//  The parenting door selector — design 4a's "Carousel · mist falloff"
// -----------------------------------------------------------------------------
//  ⚠️ THE THIRD COPY, AND THE SEAM IS NOW REAL. The control was built on the
//  TTC fertile-window door, copied to the pregnancy doors because TTC was
//  being worked on in parallel, and copied here for the same reason twice
//  over: both other engines are open in other terminals. The pregnancy copy
//  names the seam — "a shared version would take those four values rather
//  than a model" — and this copy takes it: `PpDoorTab` is label, icon, hue
//  and an id, and nothing else is read. Geometry and reasoning are the
//  pregnancy file's, verbatim. If the design moves, three files move.
//
//  ---------------------------------------------------------------------------
//  WHAT IT IS
//  ---------------------------------------------------------------------------
//  Design source: "Health Cards Options" turn 4, option 4a. Five cards on one
//  3D track, ALL FIVE ON SCREEN: the chosen one flat and forward, the row
//  receding on both sides in three steps — the neighbour at 0.80 scale and 92%
//  opacity, the one behind it at 0.60 and 72%, each pushed further out and
//  tilted a little more, with a blur that grows with depth and a tint that
//  deepens as it recedes, so distance never means invisible. Both edges of the
//  track fade to 45%, so the far cards soften rather than being sliced by the
//  screen. Under the track, five dots.
//
//  ⚠️ WHY A CAROUSEL AND NOT A ROW OF TABS. The objection that kept sub-tabs
//  out of these doors for a long time is about choosing blind: a tab bar lights
//  one word, hides the rest, and tells you nothing about what is behind them.
//  This is not that. All five are on screen from the first frame, named, before
//  anything is chosen — the choice is made after seeing the options.
//
//  ---------------------------------------------------------------------------
//  ⚠️ FOUR WAYS TO BUILD THIS THAT DO NOT WORK, ALL OF THEM TRIED ON THE
//  ORIGINAL. Every one compiles, renders, and looks plausible in a still frame.
//  ---------------------------------------------------------------------------
//
//  **1. `AnimatedContainer(transform: …)`.** The obvious move, and it destroys
//  the effect. `Matrix4Tween` interpolates by calling `Matrix4.decompose` —
//  translation, quaternion, scale — which has nowhere to put a perspective row.
//  Every intermediate frame is therefore drawn FLAT, and the cards slide about
//  in 2D before snapping into depth at the end. The lesson generalises: a
//  matrix tween is an affine tween, and perspective is not affine.
//
//  **2. Reordering `Stack` children without keys.** The cards must be painted
//  far-to-near (a `Stack` has no z-index, so paint order IS the z-index), and
//  that order changes every time the selection moves. With no keys, Flutter
//  matches children by slot: the element in slot 0 is reused for whichever card
//  is now furthest away, so its state and its animation belong to the previous
//  occupant. Nothing travels — the tiles simply change. This needs both fixes
//  together, because (1) hides it.
//
//  **3. Discrete state plus a transition.** The CSS original is written that
//  way because CSS has to be: an integer index and a transition to cover the
//  jump. Ported literally it gives a control that ignores the finger until a
//  threshold trips and then animates on its own — a slideshow, not a track.
//
//  So: ONE `double` is the state. [_position] is the fractional index of the
//  card in the middle; every card's transform, opacity, scale, tilt, blur and
//  tint are computed from it each frame, and dragging moves it directly.
//
//  **4. `Transform(filterQuality: …)` while moving.** Flutter's own cure for
//  text shimmering under an animated scale, and with it set the card is drawn
//  flat into a bitmap and the matrix goes through `ImageFilter.matrix` instead
//  of the canvas — which on a device does NOT draw the perspective the vector
//  path draws. A widget that renders one way in motion and another at rest has
//  two geometries, and every difference between them is a "settle" the eye
//  sees. Pick one path.
//
//  ---------------------------------------------------------------------------
//  The geometry, and why it is CSS's rather than an approximation of it
//  ---------------------------------------------------------------------------
//
//  4a writes the transform per step `a = |o|`, with `s = sign(o)`:
//
//      translateX(s · (96 + (a−1)·74))   — 0, ±96, ±170
//      translateZ(−a · 60)               — 0, −60, −120
//      translateY(a · 8)                 — the ladder steps down as it recedes
//      rotateY(−s · (24 + (a−1)·8)deg)   — 0, ∓24°, ∓32°
//      rotateX(a ? 3deg : 0)
//      scale(1, .8, .6)
//
//  under `perspective: 1000px`, where `o` is the signed distance round the
//  ring. Every one of those is a straight line between its whole-step values,
//  and [_DoorCard] evaluates the LINE rather than the steps — so the frames in
//  between are what a CSS transition would have produced.
//
//  Two things have to be right for that to survive the port:
//
//   1. **Multiplication order.** CSS applies a transform list left-to-right as
//      matrix multiplication — `T · Ry · Rx · S`. Matrix4's cascade
//      post-multiplies in the same order, so the cascade below is not merely
//      similar to the CSS, it is the same matrix.
//
//   2. **The sign on the perspective entry.** Flutter's usual flip-card recipe
//      is `setEntry(3, 2, 0.001)`, which gives `w = 1 + z/1000` — positive z
//      recedes. CSS is `w = 1 − z/d`, where positive z comes TOWARD you. Using
//      the Flutter idiom with CSS's numbers therefore inverts the depth: the
//      neighbours come forward and the chosen card sinks. That still animates
//      and still looks deliberate, so it would not be caught by looking at it.
//      `-1 / 1000` keeps CSS's convention, which is what lets every other
//      number in the design be copied across unchanged.
//
//  The blur is applied INSIDE the transform, as CSS does: `filter` renders in
//  the element's own space and the transform applies to the result, so a card
//  at 0.6 scale carries a blur 0.6 as wide on screen. Putting the
//  `ImageFiltered` outside the `Transform` would blur in screen space and the
//  far cards would be softer than the design.
//
//  The general fact, worth more than this screen: porting a transform is not
//  porting the numbers. It is porting the numbers PLUS the coordinate
//  convention they were written against, and the convention is the half nobody
//  writes down.
// =============================================================================

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/doors/pp_door_data.dart';
import '../../../theme/pv_fonts.dart';
import '../../v2/v2_palette.dart';

/// ⚠️ THESE KEYS EXIST SO THE WIRING CAN BE ASSERTED, AND THAT IS THE ONLY
/// REASON. A test can prove the door declares five groups and prove nothing at
/// all about whether the selector actually builds them — the exact
/// correct-but-unreachable shape this repo keeps hitting.
const Key kPpDoorCarouselKey = Key('pv-door-carousel');

/// One dot, addressable. The far pair sits at the back of the ladder, two
/// swipes away by drag, so the dot is the only one-tap route to it.
Key pvDoorDotKey(int i) => ValueKey('pv-door-dot-$i');

/// One side of the track — `-1` for the card on the left, `1` for the right.
///
/// Named rather than found by position because the zones are transparent, and a
/// test aiming at a coordinate would be asserting the geometry by accident.
Key pvDoorZoneKey(int step) => ValueKey('pv-door-zone-$step');

/// Card size. 4a draws a 172×132 landscape card in a 390pt frame.
///
/// ⚠️ FIXED, NOT PROPORTIONAL. At 360pt — the narrowest screen this app is
/// designed against — the back pair run past the edge of the track and are cut
/// by its mask, which fades to 45% there so the cut reads as mist rather than
/// as an edge. Pinching the numbers until all five fit would flatten the ladder
/// into a row.
const double kPpDoorCardWidth = 172;
const double kPpDoorCardHeight = 132;

/// The track's height — 4a's 146 — and where in it the cards sit. The cards are
/// laid out 4pt down and step down a further 8 per place round the ring, so the
/// back pair sit lowest; the shadow under the front card takes the rest.
const double kPpDoorTrackHeight = 146;
const double _cardTop = 4;

/// 4a's edge fade: 45% at the edge, 82% a tenth of the way in, solid across the
/// middle 44%. The values are the design's; they are what makes the back pair
/// soften into the sheet rather than stop at the screen.
const List<double> _edgeFadeStops = [0, .10, .28, .72, .90, 1];
const List<double> _edgeFadeAlphas = [.45, .82, 1, 1, .82, .45];

/// The hue at full depth.
///
/// ⚠️ SOLVED FOR CONTRAST, NOT PICKED. A single fixed lightness looks
/// consistent in code and is not: at L .42 white type clears 4.5:1 on a blue
/// and a rose and fails it on a sage, a sand and a teal — yellow-greens carry
/// far more luminance than blues at the same number.
///
/// So this solves for the lightness that puts every hue at the same contrast
/// against white, and a group added later is legible without anyone checking.
/// The target is 4.8:1 rather than the 4.5 floor because the label sits at 16pt
/// and the count at 11pt, and a floor met exactly is a floor that fails the
/// moment someone nudges a size.
Color ppDoorDeep(double hue) {
  const target = 4.8;
  const saturation = 0.44;

  double luminance(double lightness) {
    final c = HSLColor.fromAHSL(1, hue % 360, saturation, lightness).toColor();
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  var lo = 0.05;
  var hi = 0.70;
  for (var i = 0; i < 24; i++) {
    final mid = (lo + hi) / 2;
    // Darker means more contrast, so a mid that is too pale moves the ceiling.
    if (1.05 / (luminance(mid) + 0.05) < target) {
      hi = mid;
    } else {
      lo = mid;
    }
  }
  return HSLColor.fromAHSL(1, hue % 360, saturation, (lo + hi) / 2).toColor();
}

// =============================================================================
//  The track
// =============================================================================

class PpDoorCarousel extends StatefulWidget {
  const PpDoorCarousel({
    super.key,
    required this.groups,
    required this.counts,
    required this.selected,
    required this.p,
    required this.onPick,
    this.locked = const [],
  });

  final List<PpDoorTab> groups;

  /// ⚠️ A LOCKED TAB IS SHOWN, NOT HIDDEN. Per group: true when the tab
  /// holds nothing for his age yet. The card is drawn misted with a lock
  /// on it, the way a game shows a level that is coming, so the section
  /// never looks bare and she knows what opens when. The user's call,
  /// 2026-09-13. The screen orders locked cards after the open ones.
  final List<bool> locked;

  /// The second line on each card — "4 things", "Your timeline".
  ///
  /// ⚠️ PASSED IN, COUNTED BY THE SCREEN, NEVER TYPED. A hand-written count
  /// goes stale silently: nothing fails, the number is simply wrong, and it is
  /// wrong on the one line whose whole job is to be trusted before a tap.
  final List<String> counts;

  final int selected;
  final V2Palette p;
  final ValueChanged<int> onPick;

  /// The track, 4a's 12pt under it, and the dot row with its tap padding. One
  /// number, so the sheet's spacing does not have to know the parts.
  static const double height =
      kPpDoorTrackHeight + _dotGap + _PpDoorDots.height;

  static const double _dotGap = 12 - _PpDoorDots.tapPad;

  @override
  State<PpDoorCarousel> createState() => _PpDoorCarouselState();
}

class _PpDoorCarouselState extends State<PpDoorCarousel>
    with SingleTickerProviderStateMixin {
  /// ⚠️ THE WHOLE STATE OF THE TRACK, AND IT IS A `double` ON PURPOSE.
  ///
  /// The fractional index of the card in the middle. At 1.0 the second card is
  /// square on; at 1.5 the track is exactly halfway between two cards, with
  /// both turned 16° and neither in front. Dragging writes to it directly, so
  /// the cards follow the finger instead of waiting for it to finish.
  ///
  /// It is allowed outside `[0, count)` while a drag or a settle is running —
  /// [_offsetOf] wraps, so −0.4 and 4.6 describe the same picture. It is
  /// normalised on settle, so it cannot wander after a hundred swipes.
  late double _position = widget.selected.toDouble();

  /// ⚠️ BUILT IN `initState`, NOT `late final`. A `late final` controller is
  /// only constructed on first use — and if the door is opened and closed
  /// without the track ever moving, that first use is `dispose()` itself, which
  /// then builds a `Ticker` against an element that is already deactivated and
  /// throws. A lazy field whose initialiser reads the element tree is a lazy
  /// field that can run at the worst possible moment.
  late final AnimationController _settle;
  late final CurvedAnimation _curve;

  /// Where the current settle started and where it is going. Plain fields, not
  /// a `Tween` rebuilt per settle — see [_settleTo].
  double _from = 0;
  double _to = 0;

  int get _count => widget.groups.length;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(
      vsync: this,
      // 4a's .48s, and it is the number that makes the track feel like objects
      // rather than a slideshow: long enough to read the turn, short enough
      // that a second swipe never has to wait.
      duration: const Duration(milliseconds: 480),
    );
    // Leaves fast, arrives slowly — 4a's cubic-bezier(.2,.8,.2,1), so the eye
    // can follow which card took the middle instead of finding it there.
    _curve = CurvedAnimation(parent: _settle, curve: Curves.easeOutCubic);
    // ⚠️ ONE LISTENER, ADDED ONCE. Building a fresh `Tween` and calling
    // `addListener` inside `_settleTo` never removes the previous one — so a
    // door left open through twenty swipes runs twenty `setState`s per frame,
    // all writing the same value. Nothing looks wrong; it just gets slower the
    // longer you stay.
    _settle.addListener(
        () => setState(() => _position = _from + (_to - _from) * _curve.value));
    // ⚠️ AND THE NORMALISATION. Every settle target is
    // `_position + _offsetOf(target)` — the short way round, which is what
    // makes the ring a ring — so the position moves by ±1 per step and never
    // comes back. Swipe one way six times and it is at 6, or −6.
    //
    // Nothing about the cards notices, because [_offsetOf] wraps: 6 and 1
    // describe the same picture exactly. So the bug hides behind the very
    // mechanism that makes the loop work, and it takes a two-lap test to see —
    // one step from a fresh position is always correct. What it breaks is the
    // dot row, which reduces a distance and cannot do that outside one lap.
    _settle.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      final wrapped = _position - _count * (_position / _count).floorToDouble();
      if (wrapped == _position) return;
      // Subtracting whole laps changes nothing on screen — every offset is
      // taken modulo the count — so this is invisible, which is the point.
      setState(() => _position = _from = _to = wrapped);
    });
  }

  @override
  void didUpdateWidget(covariant PpDoorCarousel old) {
    super.didUpdateWidget(old);
    if (old.selected == widget.selected) return;
    // The selection can move from outside — a dot tap answered by the parent,
    // or a rebuild. Glide to it rather than jumping, and ONLY if the track is
    // not already on its way there.
    //
    // ⚠️ A SETTLE TARGET IS A POSITION ON AN UNBOUNDED LINE, NEVER AN INDEX.
    // Settling to `widget.selected.toDouble()` — 4.0 as a plain number, from a
    // position near 0 — sends the ring four cards RIGHT to reach the card that
    // is one step LEFT. The end state is right, so every content test passes
    // and the dot row lands correctly. It only shows on a handset, as a track
    // that "is not a loop".
    final heading = _settle.isAnimating ? _to : _position;
    final headingIndex = ((heading.round() % _count) + _count) % _count;
    if (headingIndex != widget.selected) {
      _settleTo(_position + _offsetOf(widget.selected));
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _settle.dispose();
    super.dispose();
  }

  /// The signed distance from the middle of the track to card [i], the short
  /// way round the ring.
  ///
  /// ⚠️ IT WRAPS, so card five is one step from card one rather than four. That
  /// is what makes the track continuous — without it the last card is a wall,
  /// and a fan of cards with a wall at one end is a list drawn in perspective.
  double _offsetOf(int i) {
    final half = _count / 2;
    var o = i - _position;
    while (o > half) {
      o -= _count;
    }
    while (o < -half) {
      o += _count;
    }
    return o;
  }

  /// Glide the track to [target] and tell the screen which card won.
  ///
  /// ⚠️ THE TWEEN RUNS ON THE POSITION, NOT ON THE MATRIX. See failure (1) in
  /// the header: interpolating the matrix itself flattens every frame between
  /// the two ends. Interpolating the one number the matrix is built from means
  /// every frame is a real perspective frame.
  void _settleTo(double target) {
    _from = _position;
    _to = target;
    _settle
      ..reset()
      ..forward();
  }

  /// ⚠️ EVERY ROUTE TO A NEW CARD GOES THROUGH HERE — a zone, a dot, the end of
  /// a drag — so the haptic cannot be wired to two of the three and forgotten
  /// on the last. `selectionClick` is the light one a picker uses;
  /// `mediumImpact` would read as a notification, and changing tab is not one.
  void _land(int i) {
    final target = ((i % _count) + _count) % _count;
    // Settle even when the group has not changed: a drag that did not travel
    // far enough still has to put the track back where it was.
    _settleTo(_position + _offsetOf(target));
    if (target == widget.selected) return;
    HapticFeedback.selectionClick();
    widget.onPick(target);
  }

  void _step(int direction) => _land(widget.selected + direction);

  // ---- the drag -------------------------------------------------------------
  //
  // ⚠️ THE TRACK FOLLOWS THE FINGER. 4a advances a whole card once a 28pt
  // threshold trips, because CSS cannot do better; ported literally that gives
  // a control which ignores you and then moves by itself. Here the drag writes
  // straight to [_position], so the cards turn as the thumb moves and the
  // gesture can be taken back halfway.

  /// Where the track was when the finger landed, so [_dragEnd] can tell a drag
  /// that has already crossed into the next card from one that has not.
  double _dragFrom = 0;

  void _dragStart(DragStartDetails _) {
    _settle.stop();
    _dragFrom = _position;
  }

  void _dragUpdate(DragUpdateDetails d) {
    // ⚠️ A CARD'S WIDTH OF FINGER IS A CARD'S WORTH OF TURN. Dividing by the
    // neighbour's 96pt of sideways travel instead makes the front card track
    // the neighbour's centre exactly — and a thumb's ordinary swipe, 250pt or
    // so, then spins the ring two and a half cards. Faithful, and twitchy.
    setState(() => _position -= d.delta.dx / kPpDoorCardWidth);
  }

  void _dragEnd(DragEndDetails d) {
    // ⚠️ A FLICK COUNTS AS ONE CARD, NEVER MORE, which is what stops a fast,
    // short swipe dying halfway — and what stops a fast, long one overshooting.
    // Velocity is points per second; three cards' worth a second is about the
    // speed at which a gesture reads as a throw rather than a nudge. The flick
    // is only added if the drag has not already crossed into the next card, so
    // a long throw lands one card on, not two.
    final v = d.velocity.pixelsPerSecond.dx;
    final crossed = _position.round() - _dragFrom.round();
    final flick = v.abs() > kPpDoorCardWidth * 3 && crossed == 0
        ? (v < 0 ? 1 : -1)
        : 0;
    _land(_position.round() + flick);
  }

  /// Indices sorted far-to-near.
  ///
  /// A `Stack` has no z-index, so PAINT ORDER IS THE Z-INDEX — this sort is the
  /// whole of 4a's `z: 10 − a`. See failure (2) in the header for why every
  /// card that comes out of here must also carry a key.
  List<int> _paintOrder() {
    final order = List<int>.generate(_count, (i) => i);
    order.sort((a, b) => _offsetOf(b).abs().compareTo(_offsetOf(a).abs()));
    return order;
  }

  /// Which side is being pressed, so the card behind it could answer the
  /// finger. −1 or +1 while a side zone is held, 0 otherwise.
  int _heldStep = 0;

  void _hold(int v) {
    if (_heldStep != v && mounted) setState(() => _heldStep = v);
  }

  /// The group [step] places round the ring from the chosen one.
  int _indexAt(int step) => (widget.selected + step + _count) % _count;

  String _countFor(int i) =>
      i < widget.counts.length ? widget.counts[i] : '';

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return SizedBox(
      key: kPpDoorCarouselKey,
      height: PpDoorCarousel.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _dragStart,
        onHorizontalDragUpdate: _dragUpdate,
        onHorizontalDragEnd: _dragEnd,
        onHorizontalDragCancel: () => _land(_position.round()),
        child: Column(
          children: [
            SizedBox(
              height: kPpDoorTrackHeight,
              child: Stack(
                children: [
                  // ---- the picture ---------------------------------------
                  //
                  // ⚠️ THE TRACK CLIPS, AND THE CLIP IS DRESSED AS MIST. 4a
                  // masks the track — `mask-image: linear-gradient(90deg, .45,
                  // .82 10%, 1 28%, 1 72%, .82 90%, .45)` — so the back pair
                  // fade into the sheet at the sides rather than being sliced
                  // by the phone.
                  //
                  // Why `ClipRect` AND `ShaderMask`, when CSS needs only the
                  // mask: a CSS mask is clipped to the element's box, so a
                  // pixel outside the track is simply not drawn. Flutter's
                  // `ShaderMask` draws its gradient over the widget's own rect
                  // and leaves anything painted OUTSIDE that rect alone — so
                  // without the clip, the part of a far card that runs past the
                  // track's edge would come through at full strength, sharp,
                  // exactly where the design wants it faintest. The clip is the
                  // half of `mask-image` Flutter does not do for you.
                  //
                  // `BlendMode.dstIn` keeps the child's colour and multiplies
                  // its alpha by the gradient's.
                  //
                  // ⚠️ AND NOTHING HERE TAKES A TAP. A perspective-transformed
                  // widget is tappable somewhere other than where it is
                  // painted: `RenderTransform` paints with the full matrix but
                  // hit-tests through `removePerspectiveTransform`, which
                  // clears only row 2 and column 2 — and `rotateY` couples x
                  // into z, leaving a residue at [3][0] that nothing strips.
                  // On the neighbour card a tap aimed at the middle of the
                  // label lands about 18pt to its right in card-local space,
                  // past the end of a short word. So the track is a picture,
                  // and the untransformed zones below take the taps.
                  //
                  // The general fact: painting and hit testing are two passes
                  // over the same tree that do not have to agree, and 3D is
                  // where they stop agreeing.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRect(
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (rect) => LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: _edgeFadeStops,
                            colors: [
                              for (final a in _edgeFadeAlphas)
                                Colors.black.withValues(alpha: a),
                            ],
                          ).createShader(rect),
                          child: Padding(
                            padding: const EdgeInsets.only(top: _cardTop),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                for (final i in _paintOrder())
                                  _PpDoorCard(
                                    // ⚠️ THE KEY IS LOAD-BEARING, NOT
                                    // TIDINESS. The list above is re-sorted
                                    // every frame; without an identity, Flutter
                                    // reuses each slot's element for whatever
                                    // card now occupies it. See failure (2).
                                    key: ValueKey(widget.groups[i].id),
                                    group: widget.groups[i],
                                    inside: _countFor(i),
                                    locked: i < widget.locked.length &&
                                        widget.locked[i],
                                    offset: _offsetOf(i),
                                    count: _count,
                                    index: i,
                                    held: _heldStep != 0 &&
                                        _offsetOf(i).round() == _heldStep,
                                    p: p,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ---- the two side targets ------------------------------
                  //
                  // The middle is the width of the front card, which sits at
                  // z 0 and is therefore drawn at its true size — the one card
                  // whose painted width IS [kPpDoorCardWidth]. The sides take
                  // whatever the screen has left, so on a narrow phone they
                  // stay usable rather than shrinking with the foreshortened
                  // card they stand for.
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          child: _PpDoorZone(
                            key: pvDoorZoneKey(-1),
                            step: -1,
                            group: widget.groups[_indexAt(-1)],
                            onHold: _hold,
                            onTap: () => _step(-1),
                          ),
                        ),
                        // ⚠️ INERT ON PURPOSE, AND STILL PRESENT. The front
                        // card is already chosen, so there is nothing for a tap
                        // to do — but the gap has to exist to stop the side
                        // zones meeting in the middle, where a tap on the front
                        // card would swing the track sideways for no reason the
                        // reader could name.
                        const SizedBox(width: kPpDoorCardWidth),
                        Expanded(
                          child: _PpDoorZone(
                            key: pvDoorZoneKey(1),
                            step: 1,
                            group: widget.groups[_indexAt(1)],
                            onHold: _hold,
                            onTap: () => _step(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PpDoorCarousel._dotGap),
            _PpDoorDots(
              groups: widget.groups,
              position: _position,
              selected: widget.selected,
              p: p,
              onPick: _land,
            ),
          ],
        ),
      ),
    );
  }
}

/// One side of the track: a transparent target that brings the card on that
/// side forward.
///
/// ⚠️ IT CARRIES THE SEMANTICS FOR THE CARD IT STANDS FOR. The cards themselves
/// sit under an `IgnorePointer` and are no longer buttons, so without this a
/// screen reader would find a track it could not operate. The label names the
/// group the tap would open, not "previous" or "next" — a direction is only
/// useful to someone who can already see what is on either side.
class _PpDoorZone extends StatelessWidget {
  const _PpDoorZone({
    super.key,
    required this.step,
    required this.group,
    required this.onHold,
    required this.onTap,
  });

  final int step;
  final PpDoorTab group;
  final ValueChanged<int> onHold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: group.label,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => onHold(step),
          onTapCancel: () => onHold(0),
          onTapUp: (_) => onHold(0),
          onTap: onTap,
        ),
      );
}

// =============================================================================
//  The layered mark
// -----------------------------------------------------------------------------
//  Five parts, drawn in a 96×96 space and painted at 74, all from the group's
//  own hue:
//
//    · a radial disc, r 33, lit off-centre at (38%, 30%) — light → mid
//    · a hairline ring, r 41, at 22% — the disc's edge, a little outside it
//    · a broken arc across the top, r 39, at 34%, trailing off
//    · a second arc under it, r 34, at 28%, springing the other way
//    · three dots of falling size, at 50% / 35% / 28%
//
//  and outside the rotation, a horizon: a shallow curve across the foot at 30%.
//
//  ⚠️ THE ROTATION IS PER GROUP AND IT IS THE WHOLE TRICK. `i * 26 − 12`
//  degrees. Five cards carrying the SAME drawing in five colours read as one
//  thing tinted five ways; the same drawing turned five ways reads as five
//  places. It costs one number and it is the difference between a palette and a
//  set of marks.
//
//  ⚠️ AND THE DOT CLUSTER IS SEEDED PER GROUP, NOT RANDOM. A `Random()` here
//  would redraw the mark on every rebuild — the card would shimmer as the track
//  moved, which is the kind of thing that gets diagnosed as a rendering bug
//  three months later.
// =============================================================================

/// The hand-listed dot positions, per group: (x, y) three times over.
const List<List<double>> _kMarkDots = [
  [74, 24, 84, 40, 66, 12],
  [22, 26, 12, 42, 32, 15],
  [72, 74, 84, 60, 62, 86],
  [26, 72, 14, 58, 36, 84],
  [76, 46, 86, 62, 70, 30],
];

/// The mark's palette: the same hue at two strengths.
///
/// ⚠️ NOT ROUTED THROUGH `v2BlockTint`. Those are the app's BLOCK tints, solved
/// for a large flat panel; the mark needs a light and a mid that sit within a
/// few percent of each other or the disc turns into a bullseye. The only value
/// that leaves this file is the deep — [ppDoorDeep] — because it is the one
/// that has to clear 4.5:1 against white type.
Color _markLight(double h) =>
    HSLColor.fromAHSL(1, h % 360, 0.46, 0.93).toColor();
Color _markMid(double h) =>
    HSLColor.fromAHSL(1, h % 360, 0.30, 0.82).toColor();

class _PpDoorMark extends CustomPainter {
  const _PpDoorMark({required this.hue, required this.index, this.grey = false});

  final double hue;
  final int index;

  /// A locked card's mark: the same drawing in grey.
  final bool grey;

  @override
  void paint(Canvas canvas, Size size) {
    // Everything below is written in the design's 96-unit space and scaled
    // once, so the numbers in the code are the numbers in the design file.
    canvas.scale(size.width / 96);
    final deep = grey ? const Color(0xFF8A8592) : ppDoorDeep(hue);
    final d = _kMarkDots[index % _kMarkDots.length];
    const c = Offset(48, 48);

    Paint hair(double width, double opacity) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = deep.withValues(alpha: opacity);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate((index * 26 - 12) * math.pi / 180);
    canvas.translate(-c.dx, -c.dy);

    // The disc, lit from up and to the left.
    canvas.drawCircle(
      c,
      33,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.24, -0.40), // cx 38% cy 30%
          radius: 0.78,
          colors: [_markLight(hue), _markMid(hue)],
        ).createShader(Rect.fromCircle(center: c, radius: 33)),
    );

    // The ring just outside it.
    canvas.drawCircle(c, 41, hair(1, 0.22));

    // A broken arc over the top, dashed 86-on 200-off — on a 39pt
    // half-circumference (≈123) that stops about two thirds of the way across,
    // an arc that trails off rather than closing.
    canvas.drawArc(Rect.fromCircle(center: c, radius: 39), math.pi,
        math.pi * (86 / 123), false, hair(1.25, 0.34));

    // And a second, springing the other way underneath.
    //
    // ⚠️ ITS CENTRE IS NOT THE MARK'S CENTRE. The design writes it as an SVG
    // arc command — `M18 66 A34 34 0 0 0 78 66` — which gives two endpoints and
    // a radius and lets the renderer solve for the middle. A 60-unit chord at
    // radius 34 puts that middle 16 units off the chord, at (48, 50), and
    // sweep-flag 0 says take the half that bulges downward. Drawing it around
    // (48, 48) instead is two units of drift that reads as the lower arc not
    // quite belonging to the disc.
    canvas.drawArc(
        Rect.fromCircle(center: const Offset(48, 50), radius: 34),
        151.93 * math.pi / 180,
        -123.86 * math.pi / 180,
        false,
        hair(1, 0.28));

    // The cluster: three dots of falling size and falling weight.
    for (final (i, r, a) in [(0, 4.5, 0.50), (1, 2.4, 0.35), (2, 1.4, 0.28)]) {
      canvas.drawCircle(Offset(d[i * 2], d[i * 2 + 1]), r,
          Paint()..color = deep.withValues(alpha: a));
    }
    canvas.restore();

    // ⚠️ THE HORIZON IS OUTSIDE THE ROTATION, on purpose. Everything else
    // turns; this one line stays level on all five cards, so the marks read as
    // five views of one place rather than five unrelated drawings. Turning it
    // with the rest loses that instantly.
    canvas.drawPath(
      Path()
        ..moveTo(4, 82)
        ..quadraticBezierTo(48, 70, 92, 80),
      hair(1, 0.30),
    );
  }

  @override
  bool shouldRepaint(_PpDoorMark old) =>
      old.hue != hue || old.index != index || old.grey != grey;
}

/// One card on the track — a drawing, at a position on a ring.
///
/// ⚠️ STATELESS, AND REBUILT EVERY FRAME OF A DRAG. It holds no animation of
/// its own: [offset] arrives already interpolated and the card just draws where
/// that says. Anything animating in here would be a second clock running
/// against the track's, and the one that loses is whichever finished last.
class _PpDoorCard extends StatelessWidget {
  const _PpDoorCard({
    super.key,
    required this.group,
    required this.inside,
    required this.offset,
    required this.count,
    required this.index,
    required this.held,
    required this.p,
    this.locked = false,
  });

  final PpDoorTab group;

  /// The second line — "4 things", "Your timeline". Counted by the screen.
  final String inside;

  /// Drawn misted with a lock: nothing here for his age yet.
  final bool locked;

  /// Signed distance from the middle of the track, fractional while it moves.
  final double offset;

  /// How many cards are on the ring. Sets where the far side is — the one place
  /// a card has to vanish, because it is about to reappear on the other side.
  final int count;

  /// Position in the door's group list. Seeds the mark, so a group's drawing is
  /// the same every time it is looked at.
  final int index;

  /// Whether the zone in front of this card is being pressed. Pushed down from
  /// the track rather than held here, because the finger never lands on this
  /// widget — see the hit-testing note in the track's build.
  final bool held;

  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final o = offset;
    final a = o.abs();
    final s = o.sign;
    final h = group.hue % 360;
    final deep = ppDoorDeep(group.hue);

    // ⚠️ EVERY ONE OF THESE IS CONTINUOUS IN `o`. At a == 0 they are 4a's
    // chosen-card values, at a == 1 its neighbour values and at a == 2 its
    // back-pair values; the frames between are what a CSS transition would have
    // produced and what the finger is actually dragging through.
    //
    // Where 4a's table is a straight line — scale drops 0.2 a step, z 60, y 8 —
    // the line is written once. Where it bends at the neighbour — the sideways
    // travel is 96 for the first step and 74 for the second, the turn 24° then
    // 8° more — `ladder` bends with it.
    final near = (1 - a).clamp(0.0, 1.0); // 1 in the middle, 0 at a neighbour
    final one = a.clamp(0.0, 1.0); // the first step, saturating
    double ladder(double first, double rest) =>
        a <= 1 ? first * a : first + rest * (a - 1);

    // ⚠️ NO PRESS-SCALE, AND IT WAS A JITTER ON THE ORIGINAL. A zone's
    // `onTapDown` also fires at the START OF A SWIPE, once the finger has sat
    // for the press timeout, and is cancelled the moment the drag wins: the
    // neighbour shrank a twentieth and popped back before the track had moved a
    // point. On a tap it was shrink, pop, then glide — three movements for one
    // gesture. 4a has no press state; the turn is the feedback. [held] still
    // arrives, so the plumbing stays for a tweened version if one is wanted:
    //   final scale = (1 - 0.2 * a) * (held ? 0.95 : 1);
    final scale = 1 - 0.2 * a;

    // ⚠️ NOTHING IS HIDDEN — THAT IS THE WHOLE OF 4a — EXCEPT AT THE SEAM. The
    // design's opacities are 1, .92, .72 and every card on a five-ring is
    // within two steps of the middle, so all five are drawn. But the ring has a
    // far side, at |o| = count/2, where a card stops being "two to the right"
    // and becomes "two to the left" in one frame, and its x flips sign. On a
    // five-ring that point is behind the mask's edge and mostly off screen; the
    // fade over the last half step before it is what makes the crossing
    // invisible rather than merely unlikely to be noticed.
    final misted = a <= 1 ? 1 - 0.08 * a : 0.92 - 0.20 * (a - 1);

    // ⚠️ AN EVEN RING HAS A CARD RESTING EXACTLY ON THE SEAM, AND FADING IT
    // WOULD HIDE A WHOLE TAB — 2026-09-10, found building a FOUR-tab door.
    //
    // On a five-ring no card ever sits at `count / 2` (2.5), so the fade above
    // only ever bites mid-crossing. On a four-ring one card always sits at
    // exactly 2.0, which is the wrap point — so the same formula rendered it at
    // zero, and Belly & skin came out as three cards under four dots.
    //
    // The trade, stated honestly: with the fade off, a card genuinely crossing
    // during a drag flips sides visibly instead of doing it under cover. It
    // happens at |o| ≈ 2, which is x ≈ ±170 — inside the track's own edge mask,
    // at 0.6 scale, mid-gesture. A visible flip there costs less than a tab
    // that is simply not on screen at rest.
    //
    // ⚠️ SO AN ODD NUMBER OF TABS IS STILL THE BETTER SHAPE, and five is what
    // every other door has. This makes four work; it does not make four equal.
    final seam = count.isEven
        ? 1.0
        : ((count / 2 - a) / 0.5).clamp(0.0, 1.0);
    final opacity = (misted * seam).clamp(0.0, 1.0);

    if (opacity == 0) return const SizedBox.shrink();

    // See the header for why the perspective entry is negative.
    final m = Matrix4.identity()
      ..setEntry(3, 2, -1 / 1000)
      ..translateByDouble(s * ladder(96, 74), 8 * a, -60 * a, 1)
      ..rotateY(-s * ladder(24, 8) * math.pi / 180)
      ..rotateX(3 * one * math.pi / 180)
      ..scaleByDouble(scale, scale, 1, 1);

    // 4a's `filter: blur(a·1.1px)`. A CSS blur radius is a Gaussian sigma, so
    // the number crosses over unchanged.
    //
    // ⚠️ THE `saturate()` HALF OF THAT FILTER IS NOT APPLIED. It costs a
    // `ColorFiltered` layer per receding card — four offscreen passes a frame
    // on top of the four blurs — for a shift the eye cannot find next to the
    // tint deepening in `field` below. On a mid-range phone the layers, not the
    // maths, are what turn a glide into a stutter, and a stutter reads as
    // jitter.
    final blur = 1.1 * a;

    // 4a's "tint that deepens as it recedes": a 150° two-stop field with both
    // stops walking darker and a touch more saturated per step.
    // `linear-gradient(150deg, …)` measures clockwise from straight up, so the
    // line runs (sin150, −cos150) = (0.5, 0.866) — down and to the right.
    //
    // ⚠️ A LOCKED CARD LOSES ITS COLOUR, NOT JUST ITS COUNT. On a phone the
    // first cut kept the hue, the icon and the name at full weight, and the
    // lock badge alone had to say "not yet" — it did not. Locked, the field
    // is grey paper, the mark is grey, the name is metadata-grey, and the
    // second line says LOCKED. Seen and asked for, 2026-09-13.
    final sat = locked ? 0.04 : 1.0;
    final field = LinearGradient(
      begin: const Alignment(-0.5, -0.866),
      end: const Alignment(0.5, 0.866),
      colors: [
        HSLColor.fromAHSL(1, h, (0.32 + 0.03 * a) * sat, 0.94 - 0.07 * a).toColor(),
        HSLColor.fromAHSL(1, h, (0.26 + 0.05 * a) * sat, 0.91 - 0.10 * a).toColor(),
      ],
    );
    final ink = locked ? p.ink3 : deep;

    // ⚠️ A SOFT RIM, NOT A HARD RING. Both values are the group's own hue at
    // two strengths, so no new colour is introduced to say which card is
    // forward — the geometry already says it, and the rim's job is only to give
    // the card an edge.
    final rim = locked
        ? p.line
        : Color.lerp(
            HSLColor.fromAHSL(0.32, h, 0.24, 0.60 - 0.04 * a).toColor(),
            HSLColor.fromAHSL(0.55, h, 0.32, 0.62).toColor(),
            near,
          )!;

    Widget card = SizedBox(
      width: kPpDoorCardWidth,
      height: kPpDoorCardHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: field,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: rim, width: 1),
          boxShadow: near > 0
              ? [
                  // The hue's own shadow, not black: a coloured block casting a
                  // grey shadow reads as a sticker on the page rather than a
                  // part of it.
                  BoxShadow(
                    color:
                        HSLColor.fromAHSL(0.38 * near, h, 0.34, 0.42).toColor(),
                    blurRadius: 26,
                    spreadRadius: -12,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        // ⚠️ A STACK, NOT A COLUMN. Stacking the mark above the text makes them
        // share the card's height: a 74pt mark and a two-line name like
        // "Understand a result" do not both fit under each other, and the card
        // paints an overflow stripe.
        //
        // The Column is the mistake, not the sizes. The mark "sits in a FIELD
        // rather than on a patch" — it is the card's surface, not an item
        // stacked on top of one, so the name lies over its lower edge and
        // neither has to give way. It is also what lets the mark bleed off the
        // edge.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 4a's mark: 74pt, top-right, with the ring round the disc running
            // just past the corner. And it drifts — `translateX(−s·a·7px)`, a
            // few points against the turn, so the drawing slides across its
            // card as the card comes round.
            Positioned(
              top: 10,
              right: 10,
              width: 74,
              height: 74,
              child: Transform.translate(
                offset: Offset(-o * 7, 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PpDoorMark(hue: group.hue, index: index, grey: locked),
                      ),
                    ),
                    // The group's own icon at the centre of its mark — the
                    // thing that keeps the drawing a TAB rather than
                    // decoration.
                    Transform.translate(
                      offset: const Offset(-2, -3),
                      child: Icon(locked ? Icons.lock_outline_rounded : group.icon,
                          size: 26, color: ink),
                    ),
                  ],
                ),
              ),
            ),
            // ---- the lock, over a misted card ---------------------------
            if (locked)
              Positioned(
                top: 12,
                left: 13,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: p.surface.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    border: Border.all(color: p.line),
                  ),
                  child: Icon(Icons.lock_outline_rounded, size: 16, color: p.ink3),
                ),
              ),
            Positioned(
              left: 13,
              right: 13,
              bottom: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(group.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: -0.3,
                          color: locked ? p.ink3 : p.ink1)),
                  const SizedBox(height: 3),
                  // ⚠️ THE COUNT FADES WITH DISTANCE, THE NAME DOES NOT. 4a
                  // hides a neighbour's whole label, which works there because
                  // its art carries the identity on its own. Ours has to keep
                  // the name — a nameless neighbour is a coloured rectangle,
                  // and she would have to swipe to find out what she was
                  // swiping to. The count is the part that is only useful once
                  // you have chosen, so it is the part that goes.
                  Opacity(
                    opacity: near,
                    child: Text(inside,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ink.withValues(alpha: locked ? 1 : 0.75))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // ---- the mist ----------------------------------------------------------
    //
    // ⚠️ THE FRONT CARD GETS NO FILTER LAYER AT ALL. `ImageFiltered` renders
    // its child into an offscreen layer and composites it back, every frame of
    // a drag. At a == 0 that would be a blur of zero and still cost the layer.
    // So the card that is looked at most is the plain widget, and the filter
    // only exists on the cards that are actually receding.
    //
    // The order matters and is CSS's: `filter` is applied in the card's own
    // space and the transform to the filtered result, so the filter sits INSIDE
    // the `Transform`. `TileMode.decal` is what lets a blurred card's edges
    // soften into nothing; the default clamp would smear its edge pixels
    // outward into a hard, slightly wider rectangle.
    if (a > 0.01) {
      // ⚠️ A REPAINT BOUNDARY ROUND THE BLUR — 2026-09-17. A blur is
      // re-rasterised on every frame the layer above it moves, and the deck
      // sits inside a page that scrolls and slides out on pop; four blurred
      // cards re-rendering at 60 fps through a route transition is the
      // "jittery when exiting a door" the user saw. The boundary lets the
      // engine keep the blurred raster between frames while the deck is at
      // rest, so a scroll or a pop composites a cached image rather than
      // recomputing the filter.
      card = RepaintBoundary(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
              sigmaX: blur, sigmaY: blur, tileMode: TileMode.decal),
          child: card,
        ),
      );
    }

    return Opacity(
      opacity: opacity,
      child: Transform(
        transform: m,
        // ⚠️ CENTRE, AND IT IS NOT COSMETIC — IT IS WHERE THE VANISHING POINT
        // GOES. CSS puts `perspective` on the PARENT, so every card recedes
        // toward one point at the middle of the track. Flutter has no parent
        // perspective: the entry rides in each card's own matrix, so the
        // vanishing point sits at that card's `alignment`.
        //
        // The two only agree because every card is laid out at the SAME place —
        // the `Stack` centres them all and the matrix does the displacing — so
        // "the centre of this card" and "the centre of the track" are the same
        // point. Give the cards real positions instead of transforms and each
        // one starts receding toward itself, which looks like five separate
        // animations rather than one track.
        alignment: Alignment.center,
        // ⚠️ NO `filterQuality`, ON PURPOSE. See failure (4) in the header.
        child: card,
      ),
    );
  }
}

/// The counter under the track.
///
/// ⚠️ IT IS NOT DECORATION. Two of five cards are small, misted and half off
/// the track, and this is the thing that says plainly how many there are and
/// which one is open. It is also tappable: a dot is a smaller target than a
/// card, but it is the shortest route to the far pair, which otherwise takes
/// two swipes to reach.
///
/// ⚠️ THE LIT DOT STRETCHES WITH THE TRACK, not after it. It reads [position],
/// the same fractional number the cards do, so halfway through a drag the pill
/// is halfway between two dots. A dot row that waits for the gesture to finish
/// and then jumps is the tell that a carousel is a slideshow.
class _PpDoorDots extends StatelessWidget {
  const _PpDoorDots({
    required this.groups,
    required this.position,
    required this.selected,
    required this.p,
    required this.onPick,
  });

  final List<PpDoorTab> groups;
  final double position;
  final int selected;
  final V2Palette p;
  final ValueChanged<int> onPick;

  /// 4a's dot: 5pt tall, 5 wide at rest and 18 lit.
  static const double dot = 5;
  static const double lit = 18;

  /// Transparent target above and below the painted dot.
  static const double tapPad = 7;

  static const double height = dot + 2 * tapPad;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < groups.length; i++)
            Builder(builder: (context) {
              // How much of the lit state this dot is holding right now. The
              // ring wraps, so the distance has to as well, or the last dot and
              // the first would hand over by travelling through the middle.
              //
              // ⚠️ MODULO FIRST, AND THAT IS THE WHOLE OF A SHIPPED BUG ON THE
              // ORIGINAL. Reducing `(i - position).abs()` with
              // `if (o > n/2) o = n - o` is correct only while `position` is
              // inside one lap — and the track's position legitimately leaves
              // it, because each step settles the short way round rather than
              // to an index. Six steps one way puts it at ±6, `n - o` goes
              // NEGATIVE, `1 - o` comes out above 1, and every dot clamps to
              // fully lit.
              //
              // Dart's `%` on a double returns a non-negative result for a
              // positive divisor, so one modulo puts the distance in `[0, n)`
              // for any position at all, and the fold after it in `[0, n/2]`.
              final n = groups.length;
              var o = (i - position) % n;
              if (o > n / 2) o = n - o;
              final on = (1 - o).clamp(0.0, 1.0);
              return Padding(
                key: pvDoorDotKey(i),
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Semantics(
                  selected: i == selected,
                  button: true,
                  label: groups[i].label,
                  child: GestureDetector(
                    onTap: () => onPick(i),
                    behavior: HitTestBehavior.opaque,
                    // ⚠️ THE PAINTED DOT IS 5pt AND THE TARGET IS NOT. A 5pt
                    // hit box is far under any touch minimum; the transparent
                    // padding carries the tap and the dot only draws it.
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: tapPad),
                      child: SizedBox(
                        width: dot + (lit - dot) * on,
                        height: dot,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            // The lit dot takes the group's own deep hue, so
                            // the counter changes colour with the card it
                            // points at. One hue, two strengths.
                            color: Color.lerp(p.ink1.withValues(alpha: 0.14),
                                ppDoorDeep(groups[i].hue), on),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      );
}

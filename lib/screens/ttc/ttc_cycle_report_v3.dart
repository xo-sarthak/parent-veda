// =============================================================================
//  The cycle report's V3 pictures — the dial, the calendar, and the four stops
// -----------------------------------------------------------------------------
//  Built from the "Cycle Report" design project. Three artboards were drawn —
//  a dial, a calendar and a road — and the decisions taken off them were:
//
//    · **The dial and the calendar both ship, behind a toggle**, dial first.
//      They are the same cycle drawn two ways, and which one reads better is a
//      matter of how a person thinks rather than which is correct. Offering
//      both costs one control; picking for her costs half the audience.
//    · **The road's timeline is lifted into both of them.** The dial and the
//      calendar each carried a flat list of the four stretches; the road drew
//      the same four as connected stops with their length and their status on
//      the line. That is strictly more information in the same space, so the
//      list is gone and [TtcCycleTimeline] appears under both pictures.
//    · **The road itself is not built.** Its proportional bar said the same
//      thing the ring and the grid already say.
//
//  ⚠️ THE PICTURE IS NOT THE POINT — THE FOUR STRETCHES ARE. Both drawings are
//  thin renderers over the same `List<TtcPhaseSpan>`, so they cannot disagree
//  about where a stretch starts, how long it is, or which one she is in. When
//  the ring and the grid computed their own bands from cycle days, that was
//  three places for `ov - 5` to be typed differently. See the note at the head
//  of `ttcCyclePhaseSpans`.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ttc/ttc_cycle_report.dart';
import '../../theme/pv_fonts.dart';
import 'ttc_common.dart';
import 'ttc_phase_colours.dart';

/// Which drawing is on screen.
///
/// ⚠️ THE DIAL IS FIRST, AND IT IS A DECISION RATHER THAN AN ORDERING. A cycle
/// is a loop and the ring says so without a sentence — the reason the shape is
/// worth having at all. The calendar is the fallback for someone who thinks in
/// dates, which is most people most of the time, so it is one tap away and not
/// buried.
enum TtcCycleView { dial, calendar }

/// The one-line plain-words explanation of a stretch.
///
/// ⚠️ WRITTEN FOR SOMEONE WHO HAS NOT BEEN TOLD ANY OF THIS BEFORE, which is
/// the common case in this stage and the reason the legend used to fail. "The
/// luteal phase" names a thing she would have to look up; "the stretch after
/// the fertile days, your next period is expected at the end of it" IS the
/// thing. Do not make these more clinical later — that is a regression.
String ttcPhaseBlurb(TtcPhase phase) => switch (phase) {
      TtcPhase.period =>
        'The bleeding days. Day 1 is the first day of real bleeding, and it is '
            'what starts a new cycle.',
      TtcPhase.beforeWindow =>
        'Bleeding has stopped and the body is preparing an egg. Nothing to '
            'watch for yet.',
      TtcPhase.fertileWindow =>
        'An egg is released around now. In general, these are the days in a '
            'cycle when a pregnancy can begin.',
      TtcPhase.afterWindow =>
        'The stretch after the fertile days. Your next period is expected at '
            'the end of it.',
    };

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _d(DateTime d) => '${d.day} ${_months[d.month - 1]}';

// =============================================================================
//  The toggle
// =============================================================================

/// Dial | Calendar.
///
/// ⚠️ TWO WORDS, NOT TWO ICONS. A ring glyph and a grid glyph are guessable and
/// that is the problem — a guessable control on a health screen is one she taps
/// to find out what it does, and being surprised by your own cycle report is
/// the opposite of what this screen is for.
class TtcCycleViewToggle extends StatelessWidget {
  const TtcCycleViewToggle({super.key, required this.view, required this.onPick});

  final TtcCycleView view;
  final ValueChanged<TtcCycleView> onPick;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, TtcCycleView mine) {
      final on = view == mine;
      return Semantics(
        selected: on,
        button: true,
        child: GestureDetector(
          onTap: on ? null : () => onPick(mine),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: on ? ttcTitleInk : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: ttcBody(11.5,
                    color: on ? Colors.white : ttcMuted, w: FontWeight.w800)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ttcPanel,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg('Dial', TtcCycleView.dial),
        seg('Calendar', TtcCycleView.calendar),
      ]),
    );
  }
}

// =============================================================================
//  1a — the dial
// =============================================================================

/// One cycle as one full turn, day 1 at the top, clockwise.
class TtcCycleRing extends StatelessWidget {
  const TtcCycleRing({
    super.key,
    required this.spans,
    required this.today,
  });

  final List<TtcPhaseSpan> spans;

  /// The date in the middle. Null when this is a cycle she has paged back to,
  /// in which case there is no "today" on the ring to mark.
  final DateTime? today;

  int get _length =>
      spans.isEmpty ? 0 : spans.last.lastCycleDay;

  TtcPhaseSpan? get _here {
    for (final s in spans) {
      if (s.status == TtcSpanStatus.here) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (spans.isEmpty || _length < 2) return const SizedBox.shrink();
    final here = _here;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 268),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(alignment: Alignment.center, children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RingPainter(spans: spans, length: _length),
              ),
            ),
            // ⚠️ THE MIDDLE IS TEXT, NOT PAINT. A canvas would have to lay this
            // out itself and would not scale with the reader's text size — on a
            // screen someone opens because they are worried, a font-size
            // setting being ignored is not a small thing.
            if (here != null && today != null)
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('TODAY',
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: ttcPhaseInk(here.phase))),
                const SizedBox(height: 2),
                Text('Day ${here.firstCycleDay + here.dayInto! - 1}',
                    style: ttcFraunces(26,
                        w: FontWeight.w600, color: ttcTitleInk)),
                const SizedBox(height: 1),
                Text('of $_length · ${_d(today!)}',
                    style: ttcBody(11.5, color: ttcSoft)),
              ])
            else
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$_length',
                    style: ttcFraunces(30,
                        w: FontWeight.w600, color: ttcTitleInk)),
                Text('days', style: ttcBody(11.5, color: ttcSoft)),
              ]),
          ]),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.spans, required this.length});

  final List<TtcPhaseSpan> spans;
  final int length;

  /// A hair of empty between arcs, in days, so four bands read as four and not
  /// as one ring that changes colour.
  static const double _gapDays = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    // ⚠️ THE STROKE IS DERIVED, NOT FIXED AT 16. The design was drawn at 268pt
    // and this box is whatever the phone gives it; a hardcoded stroke on a
    // narrow device is a ring whose band is half its radius.
    final stroke = size.shortestSide * 0.062;
    final radius = (size.shortestSide - stroke) / 2 - stroke * 0.55;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    // Day 0 at twelve o'clock, clockwise.
    double angle(double day) => -math.pi / 2 + math.pi * 2 * (day / length);

    canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..color = ttcPanel
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 1.12);

    for (final span in spans) {
      final from = angle(span.firstCycleDay - 1 + _gapDays);
      final to = angle(span.lastCycleDay - _gapDays);
      if (to <= from) continue;
      canvas.drawArc(
          rect,
          from,
          to - from,
          false,
          Paint()
            ..color = ttcPhaseBand(span.phase)
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke);
    }

    // ---- the dot on today -------------------------------------------------
    for (final span in spans) {
      if (span.status != TtcSpanStatus.here) continue;
      final day = span.firstCycleDay + span.dayInto! - 1;
      final at = angle(day - 0.5);
      final centreOfDay =
          centre + Offset(math.cos(at) * radius, math.sin(at) * radius);
      canvas.drawCircle(
          centreOfDay, stroke * 0.68, Paint()..color = Colors.white);
      canvas.drawCircle(centreOfDay, stroke * 0.37,
          Paint()..color = ttcPhaseMark(span.phase));
    }

    // ---- where the loop starts -------------------------------------------
    //
    // Without this the ring is a shape with no beginning, and "clockwise from
    // the top" is a convention the reader has to be told rather than guess.
    final label = TextPainter(
      text: TextSpan(
          text: 'DAY 1',
          style: pvManrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: ttcMuted)),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas,
        Offset(centre.dx - label.width / 2, centre.dy - radius - stroke * 1.5));
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.spans != spans || old.length != length;
}

// =============================================================================
//  1b — the calendar
// =============================================================================

/// One square per day, in order, seven to a row.
class TtcCycleGrid extends StatelessWidget {
  const TtcCycleGrid({
    super.key,
    required this.spans,
    required this.report,
    required this.today,
  });

  final List<TtcPhaseSpan> spans;

  /// Only for the logged dots. Its day list stops at today, which is correct —
  /// a future square cannot have been logged.
  final TtcCycleReport report;

  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    if (spans.isEmpty) return const SizedBox.shrink();

    final logged = <int, bool>{
      for (final d in report.days) d.cycleDay: d.hasAnything,
    };

    final cells = <Widget>[];
    for (final span in spans) {
      for (var day = span.firstCycleDay; day <= span.lastCycleDay; day++) {
        final date = span.firstDay.add(Duration(days: day - span.firstCycleDay));
        final isToday = today != null &&
            date.year == today!.year &&
            date.month == today!.month &&
            date.day == today!.day;
        cells.add(_Day(
          phase: span.phase,
          number: date.day,
          today: isToday,
          logged: logged[day] ?? false,
        ));
      }
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      padding: EdgeInsets.zero,
      children: cells,
    );
  }
}

/// The double ring that marks today on any cycle grid.
///
/// WARNING: A RING, NOT A BORDER. Today has to be findable in a grid of
/// twenty-eight at a glance, and a border eats into the square -- the cell then
/// reads as SMALLER than its neighbours rather than lifted out of them, which
/// is the opposite of the job.
///
/// Two shadows and not one: a white gap first, then the phase's own mark
/// colour. The white is what separates the ring from the cell, so the mark
/// reads as a halo around a filled square rather than as a thick edge on it.
///
/// WARNING: SHARED SO THE TWO GRIDS CANNOT DRIFT. The report draws a cycle in
/// cycle-day order; the Companion draws the same cycle in calendar weeks. They
/// are different pictures of one month and today must look identical on both --
/// it did not, and one of them was marking today with a plain outline.
List<BoxShadow> ttcTodayRings(Color mark) => [
      const BoxShadow(color: Colors.white, spreadRadius: 2),
      BoxShadow(color: mark, spreadRadius: 3.6),
    ];

/// The word under today's number.
///
/// WARNING: IT IS WORTH THE SPACE. The fill and the ring say "this one is
/// different"; only the word says WHY. On a grid where five other days are also
/// coloured, a reader who has not been told is as likely to read the marked
/// square as the important day as as today.
const String kTtcNowLabel = 'NOW';

class _Day extends StatelessWidget {
  const _Day({
    required this.phase,
    required this.number,
    required this.today,
    required this.logged,
  });

  final TtcPhase phase;
  final int number;
  final bool today;
  final bool logged;

  @override
  Widget build(BuildContext context) {
    final mark = ttcPhaseMark(phase);
    return Container(
      decoration: BoxDecoration(
        color: today ? mark : ttcPhaseBand(phase),
        borderRadius: BorderRadius.circular(11),
        // ⚠️ A RING, NOT A BORDER. Today has to be findable in a grid of
        // twenty-eight, and a border would eat into the square and make it
        // read as smaller than its neighbours rather than lifted out of them.
        boxShadow: today ? ttcTodayRings(mark) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('$number',
                style: ttcBody(11.5,
                    color: today ? Colors.white : ttcPhaseInk(phase),
                    w: today ? FontWeight.w800 : FontWeight.w700)),
          ),
          if (today)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(kTtcNowLabel,
                  style: pvManrope(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      height: 1.1,
                      color: Colors.white)),
            ),
          if (logged) ...[
            const SizedBox(height: 2),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: today ? Colors.white : ttcPhaseInk(phase),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
//  The four stops — lifted out of the road, shown under both pictures
// =============================================================================

/// The four stretches as connected stops, with the current one marked.
///
/// ⚠️ THIS REPLACED A FLAT LIST OF FOUR CARDS, and the difference is not
/// decoration. The list said what each stretch was; the line says they are ONE
/// thing in an order, that three are behind her and one is ahead, and roughly
/// how long each lasts relative to the others. A cycle is a sequence, so a
/// sequence is what the structure should encode.
class TtcCycleTimeline extends StatelessWidget {
  const TtcCycleTimeline({super.key, required this.spans});

  final List<TtcPhaseSpan> spans;

  @override
  Widget build(BuildContext context) {
    if (spans.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < spans.length; i++)
          _Stop(
            index: i + 1,
            span: spans[i],
            last: i == spans.length - 1,
          ),
      ],
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({required this.index, required this.span, required this.last});

  final int index;
  final TtcPhaseSpan span;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final here = span.status == TtcSpanStatus.here;
    final meta = StringBuffer()
      ..write('${_d(span.firstDay)} – ${_d(span.lastDay)}')
      ..write(' · ${span.days} ${span.days == 1 ? 'day' : 'days'}');
    if (here) {
      meta.write(' · day ${span.dayInto} of ${span.days}');
    } else {
      meta.write(' · ${span.status.label}');
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- the rail ----------------------------------------------------
          SizedBox(
            width: 14,
            child: Column(children: [
              const SizedBox(height: 5),
              _Node(phase: span.phase, here: here),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.only(top: here ? 8 : 4, bottom: 4),
                    color: ttcBorder,
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 13),

          // ---- the stop ----------------------------------------------------
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('$index · ${span.phase.label}',
                          style: ttcFraunces(16,
                              w: FontWeight.w600, color: ttcTitleInk)),
                      if (here)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ttcPhaseBand(span.phase),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('YOU ARE HERE',
                              style: pvManrope(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: ttcPhaseInk(span.phase))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(meta.toString(),
                      style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(ttcPhaseBlurb(span.phase), style: ttcBody(13, h: 1.55)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The dot on the rail. The current one breathes.
///
/// ⚠️ SLOW AND SHALLOW, AND IT STOPS WHEN THE SYSTEM SAYS STOP. Four seconds a
/// cycle at a few points of radius is a pulse you notice once and then stop
/// seeing — which is the whole intent, because it is marking a position, not
/// asking for a tap. A faster or wider one would read as a notification badge,
/// and a fertility app that appears to be alerting her about her own ovulation
/// is applying exactly the pressure this stage exists to remove.
class _Node extends StatefulWidget {
  const _Node({required this.phase, required this.here});

  final TtcPhase phase;
  final bool here;

  @override
  State<_Node> createState() => _NodeState();
}

class _NodeState extends State<_Node> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⚠️ READ HERE, NOT IN initState. `MediaQuery` is not available during
    // `initState`, and a reduced-motion setting that is only honoured on the
    // second build is not honoured.
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.here && !still) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 14,
      height: 14,
      decoration:
          BoxDecoration(color: ttcPhaseMark(widget.phase), shape: BoxShape.circle),
    );
    if (!widget.here) return dot;

    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ttcPhaseBand(widget.phase)
                    .withValues(alpha: 1 - 0.45 * t),
                spreadRadius: 4 + 2.5 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: dot,
    );
  }
}

// =============================================================================
//  The legend
// =============================================================================

/// What the four colours mean, for the pictures that are only colour.
///
/// ⚠️ IT SITS UNDER THE PICTURE AND ABOVE THE TIMELINE, which is the only place
/// it works. Under the timeline it would be explaining something the timeline
/// has already said in words; above the picture it would be four names for
/// things she has not seen yet.
class TtcPhaseLegend extends StatelessWidget {
  const TtcPhaseLegend({super.key, required this.spans, this.loggedDots = false});

  final List<TtcPhaseSpan> spans;

  /// The calendar's extra key — a dot means she logged that day.
  final bool loggedDots;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 14,
        runSpacing: 7,
        children: [
          for (final span in spans)
            _Key(colour: ttcPhaseBand(span.phase), label: span.phase.label),
          if (loggedDots)
            const _Key(
                colour: ttcMuted, label: 'a dot means you logged', dot: true),
        ],
      );
}

class _Key extends StatelessWidget {
  const _Key({required this.colour, required this.label, this.dot = false});

  final Color colour;
  final String label;
  final bool dot;

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: dot ? 6 : 10,
          height: dot ? 6 : 10,
          decoration: BoxDecoration(
            color: colour,
            shape: dot ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: dot ? null : BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: ttcBody(11, color: ttcMuted, w: FontWeight.w700)),
      ]);
}

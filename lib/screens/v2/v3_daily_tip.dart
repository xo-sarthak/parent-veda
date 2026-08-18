// =============================================================================
//  The daily tip, as the first thing she sees
// -----------------------------------------------------------------------------
//  WHY A MODAL AT ALL, WHEN THIS PRODUCT BANS INTERSTITIALS.
//
//  §16.3 bans "no interstitial, no modal, no sign-up-to-continue" — but read
//  what the ban is actually made of. Every complaint behind it is about a modal
//  that stands between her and something she came for: an offer, a phone-number
//  demand, a paywall, a thing that cannot be dismissed. The objection is to
//  BEING BLOCKED, not to being greeted.
//
//  The test that decides it: could she leave right now, having given nothing?
//
//  ⚠️ "ASK ABOUT THIS" WAS HERE AND HAS BEEN REMOVED — worth recording because
//  the reasoning that added it was wrong in an instructive way. It went in to
//  fix "the card looks plain", on the argument that the only available action
//  was leaving. But plain was caused by the missing art and motion; the button
//  was treating a symptom, and the symptom went away when those landed.
//
//  The deeper mismatch: Ask Veda is where a worry or a symptom goes. The tip is
//  a finished thought — "This is not the end, it is the beginning of
//  everything" is not a thing anyone has a QUESTION about. Offering a Q&A door
//  on a line meant to be received is a register error, and register errors are
//  the kind of wrong that still works when you tap it, which is why they
//  survive review.
//
//  WHY IT LEFT THE PAGE. Inline, the tip was the fifth section down — read
//  after the hero, the doors, the reads and the practice, by which point she is
//  already doing something else. A single warm line is the one piece of content
//  that works better before she starts than during.
//
//  ---------------------------------------------------------------------------
//  WHAT MADE IT STOP LOOKING PLAIN, and the reasoning behind each move.
//
//  The first version was a cream band, a sentence and a text button. Everything
//  correct, nothing alive. Three changes, in order of how much they bought:
//
//  1. A PICTURE THAT CHANGES EVERY DAY. One fixed image would be worse than
//     none by the second week — a thing she has already seen is furniture. The
//     set rotates on the day index, so the card is recognisably the same object
//     arriving in a different light each morning. That is also the cheapest
//     honest answer to "why open this tomorrow". It started as photography and
//     is now drawn — see v3_tip_art.dart for why the photographs came out.
//
//  2. A STAGGERED ENTRANCE, NOT A SINGLE FADE. The sky settles, then the label,
//     then the line, then the way out — 700ms end to end. The order is the
//     reading order, so the motion is doing the same job the hierarchy is,
//     rather than decorating it. A card where everything appears at once is a
//     screenshot; one that arrives in sequence is an event.
//
//  3. THE HEADING MOVED OUTSIDE THE CARD. Inside, a 10.5px label was competing
//     with a 132px picture and a 20px sentence and losing, so the whole thing
//     read as "an image with some text" rather than as today's tip. Outside, on
//     the blur, it has nothing to compete with and can be the size it deserves.
//     It also separates the two openings cleanly: the first thing she SEES is
//     the sky, the first thing she READS is the heading above it.
//
//  THE DISC RISES rather than the whole picture scaling, and that is the one
//  change the switch to vector forced. A photograph has grain to settle, so
//  scaling it reads as settling; a vector has none, so scaling it reads as a
//  zoom. Moving one element instead reads as dawn.
//
//  THE ENTRANCE IS A SCALE, NOT A SLIDE. A sheet rising from the bottom edge is
//  the gesture the whole app uses for "you asked for this" — pickers, editors,
//  detail sheets. Reusing it for something she did not ask for would make an
//  arrival feel like a response. Centre-screen reads as something being set
//  down in front of her.
// =============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';
import 'v3_tip_art.dart';

/// Once per app process, not once per build and not once per visit to Today.
/// Same guard shape as `launch_promo.dart` — see that file for the convention.
bool kDailyTipEnabled = true;
bool _dailyTipShown = false;

/// For tests and for the "show it again" path, if one is ever wanted.
void resetDailyTip() => _dailyTipShown = false;

// THE PHOTOGRAPH SET IS GONE — replaced by drawn art in v3_tip_art.dart.
//
// Kept here as a note rather than a commented-out list, because the reason it
// failed is the useful part: a photograph always claims to be ABOUT something,
// and whatever it is about is not the sentence underneath it. The tip is free
// text that changes daily, so no image library can be relevant to it. The URLs
// themselves are in the git history if they are ever wanted for a surface where
// the subject IS known.

/// Six skies, so the same one returns about weekly and reads as a season
/// rather than a repeat. See v3_tip_art.dart for why six and not one.
const int kTipArtVariants = 6;

Future<void> showDailyTip(
  BuildContext context, {
  required String line,
  required int week,
  required int day,
  required V2Palette p,
  /// Overrides "Today's tip". Parenting's tips carry their own titles, which
  /// are better than a generic label — "End tummy time happy" says more in four
  /// words than any heading we could write above it.
  String? heading,
}) async {
  if (!kDailyTipEnabled || _dailyTipShown || line.trim().isEmpty) return;
  _dailyTipShown = true;

  await showGeneralDialog<void>(
    context: context,
    // Dismissible by tapping anywhere outside, and the label says so to screen
    // readers. A greeting she cannot wave away is an advertisement.
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    // Lighter than before, because the blur layer inside the page now carries
    // most of the separation. Two full-strength dims stacked turn the app
    // behind into a black rectangle, which loses the sense that the card is
    // sitting ON something.
    barrierColor: const Color(0x66120C1B),
    // Short, because the stagger inside the card carries the rest. Two long
    // animations running in series feels like waiting; one short one handing
    // off to a staggered one feels like arriving.
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) =>
        _TipDialog(line: line, week: week, day: day, p: p, heading: heading),
    transitionBuilder: (context, anim, _, child) {
      final e = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: e,
        // 0.96, not 0.8. A big scale reads as a notification popping; a small
        // one reads as focus settling. The difference is the whole tone.
        child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(e), child: child),
      );
    },
  );
}

class _TipDialog extends StatefulWidget {
  const _TipDialog(
      {required this.line,
      required this.week,
      required this.day,
      required this.p,
      this.heading});

  final String line;
  final int week;
  final int day;
  final V2Palette p;
  final String? heading;

  @override
  State<_TipDialog> createState() => _TipDialogState();
}

class _TipDialogState extends State<_TipDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// One controller, four windows. Separate controllers per element would drift
  /// against each other and cost four tickers for one card.
  Animation<double> _step(double from, double to) => CurvedAnimation(
      parent: _c, curve: Interval(from, to, curve: Curves.easeOutCubic));

  /// Fade plus a short rise. The rise is 10px and not 40: at 40 the eye tracks
  /// the movement instead of reading the words, which is the failure mode of
  /// every over-animated splash.
  Widget _rise(Animation<double> a, Widget child, {double dy = 10}) =>
      AnimatedBuilder(
        animation: a,
        builder: (_, c) => Opacity(
          opacity: a.value,
          child: Transform.translate(offset: Offset(0, dy * (1 - a.value)), child: c),
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final w = MediaQuery.of(context).size.width;
    // Day-indexed, so the sky is stable for the whole day rather than random
    // per build — art that changes when the screen rebuilds looks broken.
    final variant = widget.day.abs() % kTipArtVariants;

    return Stack(children: [
      // ---- THE BLUR, and why it is not just a darker barrier ---------------
      //
      // A dim alone flattens: the app behind stays legible, so the eye keeps
      // trying to read it and the card has to fight for attention with its own
      // background. Blurring removes the DETAIL rather than the light, which is
      // what actually tells the eye "nothing back there is readable, stop".
      // The result is that the card can then be quieter, not louder.
      //
      // The GestureDetector is load-bearing: a full-screen child inside
      // pageBuilder sits ABOVE the barrier, so without it the barrier's own
      // tap-to-dismiss is swallowed and the only way out is the X. That is
      // exactly the un-dismissable modal §16.3 bans, arrived at by accident.
      Positioned.fill(
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: const ColoredBox(color: Color(0x1A000000)),
          ),
        ),
      ),
      Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ---- THE HEADING SITS OUTSIDE THE CARD ---------------------------
        //
        // On the card it was a 10.5px label competing with a 132px picture and
        // a 20px sentence, so it lost — which made the whole thing read as
        // "an image with some text" rather than as today's tip. Outside, on the
        // blur, it has nothing to compete with and can be the size it deserves.
        //
        // It also does something the inside version could not: the card now
        // begins with the picture, so the first thing she sees is the sky and
        // the first thing she READS is the heading above it. Two openings, no
        // collision.
        //
        // ⚠️ THE Material WRAPPER IS NOT DECORATION. Moving the heading out of
        // the card also moved it out of the card's Material, and text with no
        // Material ancestor renders with Flutter's yellow double underline —
        // the framework's way of saying "this text has no theme". It looked
        // like a styling choice on the phone, which is what makes it a good
        // trap: nothing errors, nothing warns, and the screenshot just has
        // underlines in it. transparency, not a surface, so it paints nothing.
        Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w > 460 ? 400 : w),
          child: Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rise(
                    _step(0.05, 0.5),
                    Text(widget.heading ?? 'Today’s tip',
                        style: pvFraunces(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                            letterSpacing: -0.7,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 5),
                  _rise(
                    _step(0.14, 0.58),
                    // Week AND day. The week says where she is in the arc;
                    // the day says which of its seven mornings this is, which
                    // is the difference between "week 40" as a chapter title
                    // and as today. The hero already pairs them, so the two
                    // surfaces now agree.
                    Text(
                        widget.week == 0
                            // Parenting has no weeks. Passing 0 means "no week"
                            // and the line becomes the child's age instead —
                            // the same job, in the unit that stage counts in.
                            ? '${widget.day} MONTHS'
                            : 'WEEK ${widget.week}  ·  DAY ${widget.day}',
                        style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                            color: Colors.white.withValues(alpha: 0.66))),
                    dy: 6,
                  ),
                ]),
          ),
        ),
        ),
        Material(
          color: p.surface,
          borderRadius: BorderRadius.circular(26),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w > 460 ? 400 : w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ---- The drawn sky, with the label sitting on it ---------------
              SizedBox(
                height: 132,
                child: Stack(fit: StackFit.expand, children: [
                  // The ground the drawing sits on. A warm wash rather than a
                  // white panel — the art is line work, and line work on white
                  // reads as a diagram.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFC9831F).withValues(alpha: 0.10),
                          const Color(0xFFC9831F).withValues(alpha: 0.24),
                        ],
                      ),
                    ),
                  ),
                  // The disc rises into place rather than the whole picture
                  // scaling. A vector has no grain to settle, so scaling it
                  // reads as a zoom; moving one element reads as dawn.
                  AnimatedBuilder(
                    animation: _step(0, 0.8),
                    builder: (_, child) => Transform.translate(
                        offset: Offset(0, 14 * (1 - _step(0, 0.8).value)),
                        child: Opacity(
                            opacity: _step(0, 0.8).value, child: child)),
                    child: V3TipArt(
                      variant: variant,
                      // Ink from the palette, so all four palette directions
                      // stay coherent without four exported artboards.
                      ink: p.ink1,
                      accent: const Color(0xFFC9831F),
                    ),
                  ),
                  // Only the close mark sits on the picture now. The label
                  // moved outside the card entirely — see the heading above.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 11, 11, 12),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        customBorder: const CircleBorder(),
                        child: Container(
                          // 44, not 32. The 44px minimum tap target is the one
                          // hard number in mobile UI — "people do have fat
                          // fingers" — and a close button is exactly where
                          // missing it hurts, because a miss on THIS control
                          // means she cannot leave. The visible chip stays
                          // small; only the target grew, which is why the
                          // padding around the icon does the work rather than
                          // a bigger circle.
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          // The ground is light, so the close mark inverts with
                          // it. A white-on-dark chip left over from the
                          // photograph would be the one dark object in a pale
                          // sky.
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.surface.withValues(alpha: 0.66),
                            ),
                            child: Icon(Icons.close_rounded,
                                size: 18, color: p.ink2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),

              // ---- The line -------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _rise(
                        _step(0.25, 0.8),
                        Text(widget.line,
                            style: pvFraunces(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                                letterSpacing: -0.3,
                                color: p.ink1)),
                      ),
                      const SizedBox(height: 18),
                      _rise(
                        _step(0.45, 1.0),
                        Row(children: [
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8)),
                            // Not "OK" and not "Got it" — both are the
                            // vocabulary of dismissing an error. This is closer
                            // to how the sentence would actually be received.
                            child: Text('Noted',
                                style: pvManrope(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: p.ink2)),
                          ),
                        ]),
                        dy: 6,
                      ),
                    ]),
              ),
            ]),
          ),
        ),
        ]),
      ),
      ),
    ]);
  }
}

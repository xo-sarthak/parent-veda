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
//  This one is the opposite shape. It is the product's own content, it asks for
//  nothing, it costs one tap or one tap-anywhere to clear, and it appears once
//  per launch rather than once per screen. If it ever grows a CTA, a countdown
//  or a second page, it has become the thing the rule bans and it should go.
//
//  WHY IT LEFT THE PAGE. Inline, the tip was the fifth section down — read
//  after the hero, the doors, the reads and the practice, by which point she is
//  already doing something else. A single warm line is the one piece of content
//  that works better before she starts than during. Moving it also buys back a
//  section's worth of scroll on a page that had grown long.
//
//  THE ENTRANCE IS A SCALE, NOT A SLIDE. A sheet rising from the bottom edge is
//  the gesture the whole app uses for "you asked for this" — pickers, editors,
//  detail sheets. Reusing it for something she did not ask for would make an
//  arrival feel like a response. Centre-screen, fading up from 96%, reads as
//  something being set down in front of her.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';

/// Once per app process, not once per build and not once per visit to Today.
/// Same guard shape as `launch_promo.dart` — see that file for the convention.
bool kDailyTipEnabled = true;
bool _dailyTipShown = false;

/// For tests and for the "show it again" path, if one is ever wanted.
void resetDailyTip() => _dailyTipShown = false;

Future<void> showDailyTip(
  BuildContext context, {
  required String line,
  required int week,
  required V2Palette p,
}) async {
  if (!kDailyTipEnabled || _dailyTipShown || line.trim().isEmpty) return;
  _dailyTipShown = true;

  await showGeneralDialog<void>(
    context: context,
    // Dismissible by tapping anywhere outside, and the label says so to screen
    // readers. A greeting she cannot wave away is an advertisement.
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: const Color(0xB3120C1B),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) => _TipDialog(line: line, week: week, p: p),
    transitionBuilder: (context, anim, _, child) {
      final e = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: e,
        // 0.96, not 0.8. A big scale reads as a notification popping; a small
        // one reads as focus settling. The difference is the whole tone.
        child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(e),
            child: child),
      );
    },
  );
}

class _TipDialog extends StatelessWidget {
  const _TipDialog({required this.line, required this.week, required this.p});

  final String line;
  final int week;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Material(
          color: p.surface,
          borderRadius: BorderRadius.circular(26),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w > 460 ? 400 : w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ---- A band of ground, so the card has a top rather than
              // starting abruptly in text. Tertiary family: structural warmth,
              // never an action — see the colour table in DESIGN-LAYER.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 18, 16, 16),
                color: const Color(0xFFC9831F).withValues(alpha: 0.12),
                child: Row(children: [
                  Expanded(
                    child: Text('TODAY’S TIP  ·  WEEK $week',
                        style: pvManrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: const Color(0xFF8A5A12))),
                  ),
                  // A second way out, for anyone who does not know the barrier
                  // is tappable. Two exits is not clutter on a thing that
                  // arrives uninvited.
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 19, color: p.ink3),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The line itself, at display size in Fraunces. It is the
                      // only thing on the card, so it gets to be large — a tip
                      // set at body size inside a dialog reads as a system
                      // message rather than as something worth keeping.
                      Text(line,
                          style: pvFraunces(
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              letterSpacing: -0.3,
                              color: p.ink1)),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8)),
                          // Not "OK" and not "Got it" — both are the vocabulary
                          // of dismissing an error. This is closer to how the
                          // sentence would actually be received.
                          child: Text('Noted',
                              style: pvManrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: p.action)),
                        ),
                      ),
                    ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

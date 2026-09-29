// =============================================================================
//  The practice card family: one shape for every card she does something with
// -----------------------------------------------------------------------------
//  ⚠️ WHY THIS FILE EXISTS (2026-09-28). The user on the phone: the Movement
//  and Breath cards on Mind & body › Today did not have "the basics right:
//  placement, font, positioning of text", then "do this Headspace thing for
//  ALL cards like this ... especially Preconception Sanskar and Mind and body".
//  The fixed card is `_PracticeBlock` in ttc_mind_today_screen.dart. The
//  Sanskar cards on the home, the ritual page, the course sessions and the rest
//  of Today each drew their own version with their own padding, radius and
//  fonts, which is how four cards that are one idea ended up looking like four
//  apps. The numbers live here once so a Sanskar card and a Mind & body card
//  are the same object with different words.
//
//  The rules, from Headspace and Calm practice cards
//  (https://mobbin.com/screens/d05b1798-9389-4073-999b-693b84cca19e, and the
//  Today list https://mobbin.com/screens/efc82d96-660f-4e91-bff9-1f3d083c34eb):
//   · no art, icon or watermark behind text; the card's tint says what it is;
//   · two text styles for content (title, body) and at most one quiet meta
//     line;
//   · one clear action, an ink pill; "Done today" is a chip at the top;
//   · even padding (18/16/18/18), one left edge, radius 22.
//
//  ⚠️ THE NUMBERS MATCH `_PracticeBlock` EXACTLY, and that card is left drawing
//  its own copy on purpose: it is the lead's reference and was walked on the
//  phone. If one changes, change the other.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_daily_data.dart' show TtcRitualPart;
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcTitleInk;

// ⚠️ THE ONE PICKER FOR "TODAY'S MOVEMENT" AND "TODAY'S BREATH", RE-EXPORTED
// (launch sanity MB18, 2026-09-28). The home already imports this file for
// the card family, so it reaches the picker here and its own edit stays one
// line per call site. See `ttcSanskarItems` in lib/ttc/ttc_mind_today.dart.
export '../../ttc/ttc_mind_today.dart' show ttcSanskarItems, ttcTodaysMoveTip;

/// The corner every card in the family takes.
const double kTtcCardRadius = 22;

/// The inset every card in the family takes: 18 at the sides and foot, 16 at
/// the top (the top is where the chip or the title's cap height sits, and a
/// full 18 above it reads as more air above than below).
const EdgeInsets kTtcCardPad = EdgeInsets.fromLTRB(18, 16, 18, 18);

/// The card's title: serif, one weight.
TextStyle ttcCardTitle(V2Palette p) => pvFraunces(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.18,
  letterSpacing: -0.4,
  color: p.ink1,
);

/// The card's body.
TextStyle ttcCardBody(V2Palette p) =>
    pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2);

/// The one quiet line for plain facts ("About 3 minutes · Standing").
TextStyle ttcCardMeta(V2Palette p) => pvManrope(
  fontSize: 12.5,
  height: 1.4,
  fontWeight: FontWeight.w600,
  color: p.ink3,
);

/// The ink-strength version of a card's tint, for the chip's words and the
/// filled "Done today" chip. The same numbers `_PracticeBlock` uses.
Color ttcCardDeep(Color tint) =>
    HSLColor.fromColor(tint).withSaturation(0.46).withLightness(0.34).toColor();

/// The hue of each Sanskar part. One source for the home's cards and the
/// ritual page, so the card she taps and the part that opens are one colour.
/// These were the home's own numbers (the design's hues, part by part).
double ttcRitualPartHue(TtcRitualPart part) => switch (part) {
  TtcRitualPart.reflection => 42,
  TtcRitualPart.breath => 104,
  TtcRitualPart.conversation => 268,
  TtcRitualPart.gratitude => 344,
  TtcRitualPart.action => 26,
};

/// A small rounded label: the kind of card at the top left, or "Done today".
class TtcCardChip extends StatelessWidget {
  const TtcCardChip({
    super.key,
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
  });

  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;

  /// "Done today", filled in the card's deep colour.
  factory TtcCardChip.done(String label, Color tint) => TtcCardChip(
    label: label,
    icon: Icons.check_rounded,
    fg: Colors.white,
    bg: ttcCardDeep(tint).withValues(alpha: 0.92),
  );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: fg),
        const SizedBox(width: 5),
        Text(
          label,
          style: pvManrope(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ],
    ),
  );
}

/// The card's one action: ink fill, white words, an icon after them.
///
/// With no [onTap] it is drawn only, for a card whose whole surface is the
/// tap (the Today practices); with one it is its own button.
class TtcInkPill extends StatelessWidget {
  const TtcInkPill({
    super.key,
    required this.label,
    this.icon = Icons.arrow_forward_rounded,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Kept for revert (2026-09-29): the pill read p.ink1; it is the switch
    // black now (ttcTitleInk), so the palette is not read here.
    //   final p = V2PaletteStore.instance.current;
    final pill = Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 12, 9),
      decoration: BoxDecoration(
        color: ttcTitleInk,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: Colors.white),
        ],
      ),
    );
    if (onTap == null) return pill;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: pill,
      ),
    );
  }
}

/// A second, quieter action beside the ink pill (Undo, Write about it): a
/// white pill with a hairline, the stage's one secondary button treatment.
class TtcQuietPill extends StatelessWidget {
  const TtcQuietPill({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: p.ink1),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.ink1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  The cycle palette: one set of colours for every picture of her cycle
// -----------------------------------------------------------------------------
//  Written 2026-09-27 (night), after the user walked build 13: "for the cycle
//  that represents your 28-day cycle, the colour above is blue, the cycle shows
//  pink, purple, green… why so many colours thrown around randomly? What was
//  the need of blue? And please elevate the colours of the cycle, they look
//  faded."
//
//  ⚠️ WHAT WAS WRONG, SO IT IS NOT REBUILT. The same fact wore a different
//  colour on each screen:
//
//    · fertile days were GREEN on the Companion ring and the report, PINK on the
//      calendar capsule, VIOLET on the Fertile window tool;
//    · "today" and "selected" were the brand violet on the calendar, so they
//      read as fertile days;
//    · the report's hero took each phase's own hue, so a woman in the days
//      before her fertile days saw a BLUE page (hue 206) that meant nothing she
//      had been told;
//    · the four ring colours were 32 to 40 percent saturated at 80 percent
//      lightness: close to each other and close to the white card.
//
//  ⚠️ THE RULE NOW: COLOUR ONLY WHERE IT MEANS SOMETHING. Two colours carry
//  meaning, and everything else is a quiet grey (Flo's and Clue's rings and
//  Flo's cycle report do exactly this: red period, one colour for fertile days,
//  the rest grey. Mobbin: Clue ring eed61cd1, Flo ring c6cea36c, Flo report
//  9bc6e5a9, Fitbit calendar 6a40d81c, Withings calendar c11ddcfd):
//
//    · ROSE is bleeding: her period, and the day the next one is due (as an
//      outline, because it has not happened).
//    · VIOLET is fertile days, deepest on ovulation. Violet because it is the
//      stage's own colour and because the Fertile window tool, rebuilt today,
//      already draws its ramp in hue 273. Never red for ovulation (the design
//      system keeps red for destructive actions).
//    · The days before the fertile days and the wait after them are two greys
//      from the app's own ink family, light then deeper, so the four parts still
//      read as four on a ring without a third and fourth hue.
//    · TODAY and a SELECTED day are INK, the base UI's pill colour, never a
//      cycle colour, so "today" can never be mistaken for a phase.
//    · A logged day is a small ink dot. A clinic date is a hollow ink dot.
//
//  ⚠️ FULLER, AS ASKED. The fills are strong enough to carry white numerals
//  (period #D9466E and fertile #8F52CF both pass 4:1 against white), so the
//  ring and the grid read as a diagram rather than a wash.
//
//  ⚠️ ONE FILE. Every cycle view reads from here: the Companion's ring, legend
//  and rows, the calendar's grid and key, the cycle report's dial, grid, key,
//  timeline and chart, and the Fertile window's ramp, bars and curve. If a new
//  cycle picture needs a colour that is not here, add it here with its meaning,
//  do not type a hex at the call site. `test/ttc_cycle_palette_test.dart` scans
//  those files for stray colours.
// =============================================================================

// =============================================================================
//  ⚠️ RED AND TEAL SINCE 2026-10-17. The user, holding our ring and calendar
//  next to Clue's, Flo's and Withings' (Mobbin eed61cd1, 785854fd, 4bbe6258):
//  "the user interface is looking very bland… even the ring, the calendar…
//  I don't even like the colour choices." The rule above still holds, two
//  colours that mean something and quiet ones for the rest, but the two are
//  now the ones the whole category reads without a key: RED is bleeding
//  (Clue, Flo, Apple, Fitbit) and TEAL is fertile days (Clue's ring and
//  calendar). The plum-rose and the violet sat close to the app's purple
//  chrome, so a fertile day read as a button. The brand purple stays for
//  buttons, chrome and TODAY. The 2026-09-27 values are kept beside each
//  constant for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_chapter.dart' show FertilityLevel;
import '../../ttc/ttc_cycle_report.dart' show TtcPhase;
import '../../ttc/ttc_treatment_round.dart' show TtcRoundBand;
import 'ttc_common.dart' show ttcTitleInk;

/// Every colour a picture of her cycle may use, each with one meaning.
abstract final class TtcCycleColours {
  // ---- the two colours that mean something ---------------------------------

  /// Bleeding: her period days, the period marker in a chart, the rose outline
  /// on the day the next one is due.
  // Kept for revert (2026-10-17): Color(0xFFD9466E).
  static const Color period = Color(0xFFE0434A);

  /// A soft rose, behind text or as a chart band.
  // Kept for revert (2026-10-17): Color(0xFFFBDDE5).
  static const Color periodTint = Color(0xFFFDE3E4);

  /// Rose text on [periodTint] or white.
  // Kept for revert (2026-10-17): Color(0xFF9E1F46).
  static const Color periodInk = Color(0xFFA3202A);

  /// Fertile days, as a fill: a ring arc, a grid square, a legend swatch, the
  /// Fertile window's curve.
  // Kept for revert (2026-10-17): Color(0xFF8F52CF).
  static const Color fertile = Color(0xFF17958F);

  /// A soft violet, behind text or as a chart band.
  // Kept for revert (2026-10-17): Color(0xFFEBDDF8).
  static const Color fertileTint = Color(0xFFD3F1EE);

  /// Violet text on [fertileTint] or white.
  // Kept for revert (2026-10-17): Color(0xFF5A2596).
  static const Color fertileInk = Color(0xFF0C6B66);

  /// The day of ovulation: the deepest violet, a dot or bold numerals.
  // Kept for revert (2026-10-17): Color(0xFF6B319B).
  static const Color ovulation = Color(0xFF0E7F79);

  // ---- the two quiet parts --------------------------------------------------

  /// The days between the period and the fertile days.
  // Kept for revert (2026-10-17): Color(0xFFE4DFEA).
  static const Color before = Color(0xFFE6DEF3);

  /// The wait after the fertile days, until the next period.
  ///
  /// ⚠️ A WARM SAND, NOT A SECOND GREY (the user, 2026-09-28: "two colours
  /// seem very same, that can cause confusion"). Two lilac-greys a little
  /// apart in lightness read as one colour on the ring and in the legend. The
  /// days before the window stay a cool light grey; the wait is warm, so the
  /// two quiet parts differ in hue as well as lightness. Kept for revert:
  /// Color(0xFFC9C1D3).
  // Kept for revert (2026-10-17): Color(0xFFDCCBB5).
  static const Color waiting = Color(0xFFF7D9C2);

  /// Text on either grey, and their small marks.
  static const Color quietInk = Color(0xFF4A4254);

  // ---- marks that are not phases -------------------------------------------

  /// Today, and a day she has selected. The base UI's ink, never a cycle
  /// colour.
  /// ⚠️ INK, AS IT WAS (2026-10-17, the user: the circle round today on the
  /// home hero "was black before, so let it stay black only"). Purple for
  /// one build, kept for revert: ttcPurple.
  static const Color today = ttcTitleInk;

  /// A day she logged something (a symptom, a number, a journal line).
  static const Color logged = ttcTitleInk;

  /// A date her clinic gave her. Drawn hollow, so it is not the logged dot.
  static const Color clinic = ttcTitleInk;

  /// The hue the Fertile window tool's hero field is drawn in. The same
  /// violet family as [fertile].
  // Kept for revert (2026-10-17): 273.
  static const double fertileHue = 176;

  /// The hue of the rose family, for a hero field during her period.
  // Kept for revert (2026-10-17): 344.
  static const double periodHue = 357;

  // ---- per phase ------------------------------------------------------------

  /// The fill for a phase: a ring arc, a grid square, a legend swatch.
  static Color fill(TtcPhase phase) => switch (phase) {
        TtcPhase.period => period,
        TtcPhase.beforeWindow => before,
        TtcPhase.fertileWindow => fertile,
        TtcPhase.afterWindow => waiting,
      };

  /// Numerals and marks sitting ON [fill].
  static Color onFill(TtcPhase phase) => switch (phase) {
        TtcPhase.period || TtcPhase.fertileWindow => Colors.white,
        _ => quietInk,
      };

  /// A soft version of the phase, for a chip or a chart band behind a line.
  static Color tint(TtcPhase phase) => switch (phase) {
        TtcPhase.period => periodTint,
        // Kept for revert (2026-10-17): Color(0xFFF3F0F6).
        TtcPhase.beforeWindow => const Color(0xFFF4F0FA),
        TtcPhase.fertileWindow => fertileTint,
        // Kept for revert (2026-09-28): Color(0xFFE9E5EE).
        // Kept for revert (2026-10-17): Color(0xFFF6EDE1).
        TtcPhase.afterWindow => const Color(0xFFFDF0E6),
      };

  /// Text naming a phase, on [tint] or white.
  static Color ink(TtcPhase phase) => switch (phase) {
        TtcPhase.period => periodInk,
        TtcPhase.fertileWindow => fertileInk,
        _ => quietInk,
      };

  /// A small solid mark for a phase: a timeline node, a legend dot. The greys
  /// are taken a step darker so a 14pt dot still shows on white.
  static Color mark(TtcPhase phase) => switch (phase) {
        TtcPhase.period => period,
        // Kept for revert (2026-10-17): Color(0xFFB7AEC2).
        TtcPhase.beforeWindow => const Color(0xFFA996C9),
        TtcPhase.fertileWindow => fertile,
        // Kept for revert (2026-09-28): Color(0xFF948AA1).
        // Kept for revert (2026-10-17): Color(0xFFB0875A).
        TtcPhase.afterWindow => const Color(0xFFD9915B),
      };

  // ---- the fertile days, graded ----------------------------------------------

  /// One violet ramp for the six days, used by the calendar's capsule and the
  /// Fertile window's bars, so a Peak day is the same colour on both.
  static Color fertileLevel(FertilityLevel level) => switch (level) {
        // Kept for revert (2026-10-17): B58DE3, D2B9F0, E8DBF7, F3F0F6.
        FertilityLevel.peak => const Color(0xFF7FD3CC),
        FertilityLevel.high => const Color(0xFFA9E2DD),
        FertilityLevel.medium => const Color(0xFFCFEFEB),
        FertilityLevel.low => const Color(0xFFEAF7F5),
      };

  // ---- a treatment round on the calendar --------------------------------------

  /// A round's soft bands. Warm greys, never a cycle colour: while a clinic is
  /// timing the cycle we draw no phases, and these must not look like one.
  static Color clinicBand(TtcRoundBand band) => switch (band) {
        TtcRoundBand.medicine => const Color(0xFFEFE9E1),
        TtcRoundBand.waitingForTest => const Color(0xFFE3DBD1),
      };

  // ---- the hero field behind a cycle page -----------------------------------

  /// The field's hue for the part of the cycle she is in, or the quiet one
  /// when there is no part to name (nothing logged, a clinic, no estimate).
  ///
  /// ⚠️ THE GREYS GET A NEAR-GREY FIELD. A violet page in the waiting days
  /// would say "fertile" in the one colour this palette keeps for it.
  //
  // ⚠️ EVERY PART HAS ITS OWN FIELD SINCE 2026-10-17. The user: "stop making
  // the hero section grey… the grey is not looking well… use good colours."
  // The quiet parts were the fertile hue at 0.22 chroma, which read as a
  // grey page for most of the month. Now each part wears its own family:
  // red in the period, lilac before the fertile days, teal in them, peach in
  // the wait, the same families as the ring and the month. Kept for revert:
  //   heroHue: period => periodHue, _ => fertileHue;
  //   heroChromaScale: period || fertileWindow => 1, _ => 0.22.
  static double heroHue(TtcPhase? phase) => switch (phase) {
        TtcPhase.period => periodHue,
        TtcPhase.beforeWindow => beforeHue,
        TtcPhase.fertileWindow => fertileHue,
        TtcPhase.afterWindow => waitingHue,
        null => beforeHue,
      };

  /// The lilac of [before], for a hero field.
  static const double beforeHue = 266;

  /// The peach of [waiting], for a hero field.
  // 8, not 24 (the device walk, 2026-10-17): the field leans each hue
  // about 34 degrees on, and 24 leant into olive. 8 leans into apricot.
  static const double waitingHue = 8;

  /// A multiplier on the field's usual chroma: every part is coloured now;
  /// the page with no part to name (nothing logged, a clinic) is softer.
  static double heroChromaScale(TtcPhase? phase) => phase == null ? 0.6 : 1;
}

/// A card on a cycle page: white, one hairline, no shadow.
///
/// ⚠️ REPLACES `TtcCard` ON THE CYCLE VIEWS (2026-09-27). `TtcCard` is the V1
/// card with a violet drop shadow; the base UI is hairlines, not shadows, and
/// the tools' own blocks already follow it.
class TtcCycleCard extends StatelessWidget {
  const TtcCycleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = Colors.white,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E2E5)),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: card,
    );
  }
}

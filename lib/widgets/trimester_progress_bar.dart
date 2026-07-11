// =============================================================================
//  TrimesterProgressBar
// -----------------------------------------------------------------------------
//  The app-wide replacement for the old circular progress ring + "%" readout.
//  A calm HORIZONTAL bar split into the three trimesters, each segment filling
//  proportionally as the pregnancy advances, with a "weeks / days to go" caption.
//  No percentages anywhere (a product rule) — progress is shown by the fill and
//  the remaining-time line only.
//
//  Two skins:
//    • onDark = true  -> sits on the purple hero gradient (white ink/track).
//    • onDark = false -> sits on a light surface (brand purple fill).
//
//  Feed it the raw pregnancy numbers so it stays decoupled from the controller:
//    TrimesterProgressBar(
//      week: pregnancy.currentWeek,
//      daysRemaining: pregnancy.daysRemaining,
//      lang: pregnancy.language,
//      onDark: true,
//    )
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_language.dart';
import '../theme/app_theme.dart';

class TrimesterProgressBar extends StatelessWidget {
  const TrimesterProgressBar({
    super.key,
    required this.week,
    required this.daysRemaining,
    required this.lang,
    this.onDark = false,
    this.showCaption = true,
    this.showLabels = true,
    this.onDarkDotBorder,
  });

  /// Current gestational week (clamped 1–40 for the bar's sake).
  final int week;

  /// Days remaining until the due date (0 when at/after term).
  final int daysRemaining;

  final AppLanguage lang;

  /// True on the purple hero gradient; false on a light surface.
  final bool onDark;

  /// Show the "Week X · N weeks to go" caption above the bar.
  final bool showCaption;

  /// Show the T1 / T2 / T3 labels under the bar.
  final bool showLabels;

  /// Ring around the "you are here" dot on the dark skin. Defaults to the brand
  /// purple; pass the host hero's own dark accent (e.g. Father Slate) to match.
  final Color? onDarkDotBorder;

  // Trimester spans, in completed days (280-day term).
  static const int _t1End = 91; // week 13
  static const int _t2End = 189; // week 27

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final currentDay = (280 - daysRemaining).clamp(1, 280);
    final currentTri = currentDay <= _t1End ? 1 : (currentDay <= _t2End ? 2 : 3);

    final weeksToGo = (40 - week).clamp(0, 40);
    final daysToGoInWeek = daysRemaining % 7;

    final Color ink = onDark ? Colors.white : AppTheme.primary900;
    final Color inkSoft =
        onDark ? Colors.white.withValues(alpha: 0.82) : AppTheme.neutral500;
    final Color track =
        onDark ? Colors.white.withValues(alpha: 0.22) : AppTheme.surfaceContainerHigh;
    final Color fill = onDark ? Colors.white : AppTheme.primary500;

    // Per-segment fill fraction (0..1) given the current day.
    double segFill(int startDay, int endDay) =>
        ((currentDay - startDay) / (endDay - startDay)).clamp(0.0, 1.0);

    Widget segment(int tri, int startDay, int endDay, int flex) {
      final frac = segFill(startDay, endDay);
      final active = tri == currentTri;
      return Expanded(
        flex: flex,
        child: LayoutBuilder(builder: (context, c) {
          return Stack(children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            // Filled portion of this trimester segment.
            FractionallySizedBox(
              widthFactor: frac,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // A soft dot marking "you are here" on the active segment.
            if (active && frac > 0 && frac < 1)
              Positioned(
                left: (c.maxWidth * frac).clamp(0.0, c.maxWidth) - 5,
                top: -1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: onDark
                            ? (onDarkDotBorder ?? AppTheme.primary700)
                            : Colors.white,
                        width: 2),
                  ),
                ),
              ),
          ]);
        }),
      );
    }

    Widget label(int tri, int flex) {
      final active = tri == currentTri;
      return Expanded(
        flex: flex,
        child: Text(
          s.trimesterShort(tri),
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 10.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? ink : inkSoft,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCaption) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                s.trimesterLabel(currentTri),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const Spacer(),
              Text(
                s.timeToGo(weeksToGo, daysToGoInWeek),
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: inkSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(children: [
          segment(1, 0, _t1End, 13),
          const SizedBox(width: 4),
          segment(2, _t1End, _t2End, 14),
          const SizedBox(width: 4),
          segment(3, _t2End, 280, 13),
        ]),
        if (showLabels) ...[
          const SizedBox(height: 6),
          Row(children: [
            label(1, 13),
            const SizedBox(width: 4),
            label(2, 14),
            const SizedBox(width: 4),
            label(3, 13),
          ]),
        ],
      ],
    );
  }
}

// =============================================================================
//  TrimesterChartCard - the "Trimester · Month · Week" overview
// -----------------------------------------------------------------------------
//  A calm reference card: three colour-coded trimester blocks, each split into
//  its months and the gestational weeks they cover, with the mother's CURRENT
//  week highlighted and her due date below.
//
//  Layout note: built from plain Containers + Wrap (no IntrinsicHeight / cross-
//  axis stretch). The earlier grid used IntrinsicHeight around an Expanded+Wrap,
//  which can't resolve its constraints and crashed layout - keep it simple here.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';

typedef _Month = ({int m, List<int> weeks});
typedef _Tri = ({int t, Color block, Color month, Color week, List<_Month> months});

const List<_Tri> _kChart = [
  (
    t: 1,
    block: Color(0xFFEFA23E),
    month: Color(0xFFFBE4CB),
    week: Color(0xFFFCEEDD),
    months: [
      (m: 1, weeks: [1, 2, 3, 4]),
      (m: 2, weeks: [5, 6, 7, 8]),
      (m: 3, weeks: [9, 10, 11, 12, 13]),
    ],
  ),
  (
    t: 2,
    block: Color(0xFF7DB369),
    month: Color(0xFFDCEAD0),
    week: Color(0xFFE9F2E1),
    months: [
      (m: 4, weeks: [14, 15, 16, 17]),
      (m: 5, weeks: [18, 19, 20, 21]),
      (m: 6, weeks: [22, 23, 24, 25, 26]),
    ],
  ),
  (
    t: 3,
    block: Color(0xFF6BA7D8),
    month: Color(0xFFD3E3F2),
    week: Color(0xFFE3EFF8),
    months: [
      (m: 7, weeks: [27, 28, 29, 30]),
      (m: 8, weeks: [31, 32, 33, 34, 35]),
      (m: 9, weeks: [36, 37, 38, 39, 40]),
    ],
  ),
];

class TrimesterChartCard extends StatelessWidget {
  const TrimesterChartCard({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final cw = controller.currentWeek;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F2D144C), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.tcTitle,
            style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary900)),
        const SizedBox(height: 12),
        for (final tri in _kChart) ...[
          _trimesterCard(s, tri, cw),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 2),
        Text(s.tcDueDate(s.formatLongDate(controller.dueDate)),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary800)),
      ]),
    );
  }

  Widget _trimesterCard(S s, _Tri tri, int cw) {
    final active = tri.months.any((mo) => mo.weeks.contains(cw));
    return Container(
      decoration: BoxDecoration(
        color: tri.week,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: active ? tri.block : tri.block.withValues(alpha: 0.25),
            width: active ? 1.6 : 1),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: tri.block, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('${s.tcTrimester} ${tri.t}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
        ]),
        const SizedBox(height: 8),
        for (final mo in tri.months)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 62,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text('${s.tcMonth} ${mo.m}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.neutral700)),
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final w in mo.weeks) _weekChip(w, cw, tri)],
                ),
              ),
            ]),
          ),
      ]),
    );
  }

  Widget _weekChip(int w, int cw, _Tri tri) {
    final here = w == cw;
    return Container(
      width: 30,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: here ? AppTheme.secondary500 : Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
            color: here ? AppTheme.secondary500 : tri.block.withValues(alpha: 0.30),
            width: here ? 0 : 1),
      ),
      child: Text('$w',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: here ? FontWeight.w800 : FontWeight.w600,
              color: here ? Colors.white : AppTheme.neutral700)),
    );
  }
}

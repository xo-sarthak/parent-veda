// =============================================================================
//  TrimesterChartCard — the "Trimester · Month · Week" overview grid
// -----------------------------------------------------------------------------
//  A calm reference chart (matching the provided design): three colour-coded
//  trimester blocks, each split into its months and the gestational weeks they
//  cover, with the mother's CURRENT week circled and her due date below.
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
      (m: 1, weeks: [0, 1, 2, 3, 4]),
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

const double _triW = 78;
const double _monthW = 58;
const Color _gridLine = Color(0xFFEAE6DF);

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
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: _gridLine)),
            child: Column(children: [
              _headerRow(s),
              for (final tri in _kChart) _trimesterBlock(tri, cw),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Text(s.tcDueDate(s.formatLongDate(controller.dueDate)),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary800)),
      ]),
    );
  }

  Widget _headerRow(S s) {
    Widget cell(String t, double? w) => Container(
          width: w,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFF1EDE6),
            border: Border(right: BorderSide(color: _gridLine)),
          ),
          child: Text(t,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neutral600)),
        );
    return Row(children: [
      cell(s.tcTrimester, _triW),
      cell(s.tcMonth, _monthW),
      Expanded(
          child: Container(
        height: 40,
        alignment: Alignment.center,
        color: const Color(0xFFF1EDE6),
        child: Text(s.tcWeek,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppTheme.neutral600)),
      )),
    ]);
  }

  Widget _trimesterBlock(_Tri tri, int cw) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          width: _triW,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tri.block,
            border: const Border(
                right: BorderSide(color: _gridLine),
                top: BorderSide(color: _gridLine)),
          ),
          child: Text('${tri.t}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
        Expanded(
          child: Column(children: [
            for (final mo in tri.months) _monthRow(tri, mo, cw),
          ]),
        ),
      ]),
    );
  }

  Widget _monthRow(_Tri tri, _Month mo, int cw) {
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        width: _monthW,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tri.month,
          border: const Border(
              right: BorderSide(color: _gridLine),
              top: BorderSide(color: _gridLine)),
        ),
        child: Text('${mo.m}',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutral700)),
      ),
      Expanded(
        child: Container(
          color: tri.week,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: tri.week,
            border: const Border(top: BorderSide(color: _gridLine)),
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [for (final w in mo.weeks) _weekCell(w, cw)],
          ),
        ),
      ),
    ]);
  }

  Widget _weekCell(int w, int cw) {
    final here = w == cw;
    return Container(
      width: 30,
      height: 28,
      alignment: Alignment.center,
      decoration: here
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.secondary500, width: 2),
            )
          : null,
      child: Text('$w',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: here ? FontWeight.w800 : FontWeight.w600,
              color: here ? AppTheme.secondary600 : AppTheme.neutral700)),
    );
  }
}

// =============================================================================
//  PvDayStrip — the seven-day strip every stage home opens with
// -----------------------------------------------------------------------------
//  Lifted from `_WeekStrip` / `_WeekDay` in ttc_home_v3.dart on 2026-09-21,
//  when the pregnancy home took the TTC fold (day strip → the stage's hero →
//  My daily insights → Start anywhere; docs/PREG-HOME-HERO-PLAN.md). The TTC
//  originals are commented out in that file, kept for revert, and TTC's
//  `_WeekStrip` is now a thin wrapper over this.
//
//  ⚠️ WHAT IS SHARED IS THE MECHANISM, NOT THE MARKS. The disc that slides to
//  the selection, the window anchored on today, the one-time centring, the
//  live-clock today marker — those are the same on every stage and were hard
//  won (the notes below are the TTC ones, kept because the bugs they record are
//  not TTC bugs). What a day WEARS under its number is the stage's business:
//  TTC draws its symptom faces, pregnancy a dot for a logged symptom. That is
//  the `markFor` slot, and it is the only thing a caller has to write.
//
//  ⚠️ TWO TONES. On TTC the strip sits on a tinted field: ink digits, an accent
//  disc (coral) with a white digit. On pregnancy it sits ON THE PHOTOGRAPH,
//  under the dark scrim: white digits, a white disc with an ink digit. Same
//  widget, `onPhoto` flips the palette — a second copy would drift the way the
//  section head did (see `_Head` in ttc_home_v3.dart).
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';

class PvDayStrip extends StatefulWidget {
  const PvDayStrip({
    super.key,
    required this.p,
    required this.selected,
    required this.today,
    required this.onSelect,
    required this.accent,
    this.onPhoto = false,
    this.keyPrefix = 'pv_day_',
    this.daysBack = 180,
    this.daysForward = 6,
    this.markFor,
  });

  final V2Palette p;
  final DateTime selected;

  /// The screen's single idea of today. Threaded down, never read from the
  /// clock here — see the TTC state's `_today` for why three widgets asking
  /// `DateTime.now()` for themselves can disagree.
  final DateTime today;

  final ValueChanged<DateTime> onSelect;

  /// The disc, and today's word and digits when the disc is elsewhere.
  final Color accent;

  /// On a photograph: white type, a white disc with ink digits.
  final bool onPhoto;

  /// A key per date, so a test can tap one — `'${keyPrefix}2026-9-21'`.
  /// Finding a day by its number does not work: the list spans months, so
  /// `29` is ambiguous the moment two months' worth is built.
  final String keyPrefix;

  /// ~26 weeks back by default. Long enough that nobody hits the end while
  /// browsing, short enough that the list is cheap items rather than an
  /// infinite builder whose offset has to be computed from an epoch.
  final int daysBack;

  /// Six ahead on TTC (the fertile tint arriving is the one useful forward
  /// look). Zero on pregnancy: her future weeks are the reveal, and a day
  /// that cannot be selected must not be drawn — a dead control is worse
  /// than no control.
  final int daysForward;

  /// What sits under a date, in an 18pt slot. Null: nothing.
  final Widget? Function(DateTime date, bool selected)? markFor;

  static const double slot = 46.0;
  static const double disc = 34.0;

  @override
  State<PvDayStrip> createState() => _PvDayStripState();
}

class _PvDayStripState extends State<PvDayStrip> {
  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final _sc = ScrollController();
  bool _centred = false;

  /// ⚠️ NOT `late final`. It was, and it was set from `DateTime.now()` in
  /// `initState` — so the window was anchored to whichever day the screen was
  /// first opened on and stayed there. After midnight the strip's last cell was
  /// a day short and its idea of today was a day behind the numbers.
  late DateTime _first =
      widget.today.subtract(Duration(days: widget.daysBack));

  @override
  void didUpdateWidget(PvDayStrip old) {
    super.didUpdateWidget(old);
    if (old.today != widget.today || old.daysBack != widget.daysBack) {
      // Re-anchor, and let it re-centre once: on the morning after, landing on
      // today is what she wants, and it is also the only moment where moving
      // the scroll position under her is not rude.
      setState(() {
        _first = widget.today.subtract(Duration(days: widget.daysBack));
        _centred = false;
      });
    }
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  /// Put the selected day on screen after the first layout.
  ///
  /// ⚠️ ONCE, NOT ON EVERY BUILD. `_centred` is the guard, and it is load
  /// bearing: re-centring on every build would yank the strip back under her
  /// thumb the instant she scrolled, because a scroll rebuilds nothing but a
  /// tap rebuilds everything. It is also why this cannot be
  /// `initialScrollOffset` — the viewport width is not known until layout, and
  /// centring needs it.
  void _centre(double viewport) {
    if (_centred || !_sc.hasClients) return;
    _centred = true;
    final index = widget.selected.difference(_first).inDays;
    final target =
        (index * PvDayStrip.slot) - (viewport / 2) + (PvDayStrip.slot / 2);
    _sc.jumpTo(target.clamp(0.0, _sc.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ THE LIVE CLOCK, NOT `widget.today`, FOR THE TODAY MARKER. The parent's
    // `today` decides what the page is ABOUT and anchors the window so the list
    // does not reshuffle under a scroll. Only "which of these is today" is
    // answered from the clock, every build, unconditionally — a strip that is
    // confidently wrong about which day it is, is worse than one that is
    // merely stale.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final count = widget.daysBack + widget.daysForward + 1;
    final discColor = widget.onPhoto ? Colors.white : widget.accent;

    return LayoutBuilder(builder: (context, box) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _centre(box.maxWidth));

      final selIndex = widget.selected.difference(_first).inDays.toDouble();

      return SizedBox(
        height: 84,
        child: Stack(children: [
          // ⚠️ THE DISC IS ONE WIDGET THAT MOVES, NOT A PROPERTY OF A CELL.
          // Drawn per-cell it can only ever appear and disappear — a cut, not a
          // move. Lifted out of the list and translated, the same pixels read
          // as one object travelling to the day she tapped.
          //
          // It sits UNDER the list, which is why the number still shows: the
          // cells paint no background, so the disc shows through and each
          // date's digits draw on top of it.
          //
          // It tracks two things at once: the `AnimatedBuilder` on the scroll
          // controller keeps it glued to its date while the strip is dragged
          // (instantly — a marker that lags a scroll looks broken); the
          // `TweenAnimationBuilder` eases only the change of SELECTION.
          Positioned(
            left: 0,
            top: 20,
            child: AnimatedBuilder(
              animation: _sc,
              builder: (context, _) => TweenAnimationBuilder<double>(
                tween: Tween<double>(end: selIndex),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (context, v, child) => Transform.translate(
                  offset: Offset(
                      v * PvDayStrip.slot -
                          (_sc.hasClients ? _sc.offset : 0) +
                          (PvDayStrip.slot - PvDayStrip.disc) / 2,
                      0),
                  child: child,
                ),
                child: Container(
                  width: PvDayStrip.disc,
                  height: PvDayStrip.disc,
                  decoration:
                      BoxDecoration(color: discColor, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          ListView.builder(
            controller: _sc,
            scrollDirection: Axis.horizontal,
            itemCount: count,
            padding: EdgeInsets.zero,
            itemBuilder: (context, i) {
              final date =
                  DateTime(_first.year, _first.month, _first.day + i);
              final selected = date == widget.selected;
              return _PvDay(
                key: ValueKey(
                    '${widget.keyPrefix}${date.year}-${date.month}-${date.day}'),
                date: date,
                isToday: date == today,
                isSelected: selected,
                isFuture: date.isAfter(today),
                letter: _dayLetters[(date.weekday - 1) % 7],
                p: widget.p,
                accent: widget.accent,
                onPhoto: widget.onPhoto,
                mark: widget.markFor?.call(date, selected),
                onTap: () => widget.onSelect(date),
              );
            },
          ),
        ]),
      );
    });
  }
}

/// One cell. It draws no background of its own — the disc lives in the strip.
///
/// ⚠️ WITH THE DISC FREE TO FOLLOW THE SELECTION, TODAY HAS NO FILL whenever
/// she is looking at another day, and "keep the today marked so that I know
/// what day is today" is the requirement. Paid twice: the word TODAY sits
/// above it in the accent instead of a weekday letter, and its digits stay in
/// the accent while every other unselected day is ink. Two marks, neither a
/// disc, so neither can be confused with the cursor.
class _PvDay extends StatelessWidget {
  const _PvDay({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isFuture,
    required this.letter,
    required this.p,
    required this.accent,
    required this.onPhoto,
    required this.mark,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isFuture;
  final String letter;
  final V2Palette p;
  final Color accent;
  final bool onPhoto;
  final Widget? mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The palette, by tone. On the photograph everything is white at three
    // strengths and the disc is white, so the selected digit goes to ink.
    final Color todayColor = onPhoto ? Colors.white : accent;
    final Color inkStrong = onPhoto ? Colors.white : p.ink1;
    final Color inkSoft =
        onPhoto ? Colors.white.withValues(alpha: 0.72) : p.ink3;
    final Color inkFuture =
        onPhoto ? Colors.white.withValues(alpha: 0.4) : p.ink3.withValues(alpha: 0.5);
    final Color onDisc = onPhoto ? p.ink1 : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: PvDayStrip.slot,
        child: Column(children: [
          // ⚠️ THE WORD, NOT JUST THE COLOUR. A weekday letter is the same
          // glyph on every seventh cell, so "T" over today carries nothing.
          // ⚠️ A FIXED 14 SO THE DISC KNOWS WHERE THE CIRCLE STARTS — the
          // disc is positioned from outside this cell, so its `top` is
          // arithmetic over this row's height plus the gap below it.
          SizedBox(
            height: 14,
            child: Text(isToday ? 'TODAY' : letter,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: pvManrope(
                    fontSize: isToday ? 8 : 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: isToday ? 0.4 : 0.6,
                    color: isToday
                        ? todayColor
                        : isFuture
                            ? inkFuture
                            : inkSoft)),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: PvDayStrip.disc,
            height: PvDayStrip.disc,
            child: Center(
              child: Text('${date.day}',
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w900
                          : FontWeight.w700,
                      color: isSelected
                          ? onDisc
                          : isToday
                              ? todayColor
                              : isFuture
                                  ? inkFuture
                                  : inkStrong)),
            ),
          ),
          const SizedBox(height: 4),
          // What she logged, in the stage's own hand. A fixed slot so the
          // row does not jump between a day with a mark and a day without.
          SizedBox(height: 18, child: mark),
        ]),
      ),
    );
  }
}

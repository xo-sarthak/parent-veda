// =============================================================================
//  Dose parts: the pieces Supplements and Medication share
// -----------------------------------------------------------------------------
//  Added 2026-09-27 (tool rebuild, night). The user walked build 13 and said
//  the tools were "old tools in new clothes": new hero, old insides. These two
//  were the clearest case. Supplements drew its rows as shadowed `TtcCard`s
//  with a purple tick and a coral eyebrow; Medication drew its own card and a
//  sheet on a different ground with a filled purple Save. Two neighbouring
//  tiles in Tools, doing the same job (a list of things you take, ticked each
//  day), looked and behaved like two apps.
//
//  So the job is built once, here, and both tools are laid out of it:
//
//    · `TtcDayStrip`     the last seven days, so a missed tick on Tuesday can
//                        be put right on Wednesday. Apple Health Medications
//                        puts the same strip above its log
//                        (mobbin.com/screens/19cc770b-a386-48a5-9d6b-7a46a8c98685);
//                        MyFitnessPal's Today does it with ticks
//                        (mobbin.com/screens/315b51d8-7d9a-4682-b24c-dd41b9a0e804).
//    · `TtcDoseRow`      one thing she takes: a round tick you can hit with a
//                        thumb, the name and dose, and a way into its page.
//                        Superpower's "Today's actions" is the shape: a box on
//                        the left for doing, a row with a chevron for opening
//                        (mobbin.com/screens/6ded6c90-7a86-4441-8536-510cef3e0c65).
//    · `TtcDoseHistory`  the last four weeks as days, tap a day to add or
//                        clear it. The store's rule stands: an awareness grid,
//                        never a percentage and never a streak.
//    · `TtcDoseSheet`    the add and change sheet. White, the tool's name as
//                        its eyebrow, one serif line, labelled fields and the
//                        stage's one button. Hims and Hers put the reminder
//                        times in the same calm sheet as the rest
//                        (mobbin.com/screens/164de70f-f4dd-4b24-88b0-394b5c4acc88).
//
//  ⚠️ HAIRLINES, NOT SHADOWS, and ink rather than the accent for a chosen or
//  done state: the rules written at the head of `ttc_tool_chrome.dart`. A
//  ticked dose is an ink circle for the same reason a chosen answer is an ink
//  block there.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_tool_chrome.dart';

const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Midnight of [d].
DateTime ttcDoseDay(DateTime d) => DateTime(d.year, d.month, d.day);

bool ttcDoseSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "Today", "Yesterday" or "Friday 26 Sep".
String ttcDoseDayName(DateTime d) {
  final today = ttcDoseDay(DateTime.now());
  final day = ttcDoseDay(d);
  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${_weekdayNames[day.weekday - 1]} ${day.day} ${_months[day.month - 1]}';
}

/// "Wed 1 Oct".
String ttcDoseShortDate(DateTime d) =>
    '${_weekdayNames[d.weekday - 1].substring(0, 3)} ${d.day} ${_months[d.month - 1]}';

/// "9:00 am", from minutes since midnight.
String ttcDoseTime(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  final suffix = h < 12 ? 'am' : 'pm';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $suffix';
}

// =============================================================================
//  The last seven days
// =============================================================================

/// Seven days ending today. The chosen day is ink; a small dot under a day
/// says something was ticked on it, and nothing says how much.
class TtcDayStrip extends StatelessWidget {
  const TtcDayStrip({
    super.key,
    required this.selected,
    required this.onPick,
    required this.anyTakenOn,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onPick;
  final bool Function(DateTime day) anyTakenOn;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final today = ttcDoseDay(DateTime.now());
    return Row(children: [
      for (var i = 6; i >= 0; i--)
        Expanded(
          child: Builder(builder: (context) {
            final day = today.subtract(Duration(days: i));
            final on = ttcDoseSameDay(day, selected);
            return Semantics(
              button: true,
              selected: on,
              label: ttcDoseDayName(day),
              child: GestureDetector(
                key: ValueKey('ttc_dose_day_$i'),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onPick(day);
                },
                behavior: HitTestBehavior.opaque,
                child: Column(children: [
                  Text(_weekdays[day.weekday - 1],
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink3)),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? ttcTitleInk : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: on ? ttcTitleInk : p.line, width: 1.4),
                    ),
                    child: Text('${day.day}',
                        style: pvManrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: on ? Colors.white : p.ink1)),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: anyTakenOn(day) ? p.ink2 : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ]),
              ),
            );
          }),
        ),
    ]);
  }
}

// =============================================================================
//  One thing she takes
// =============================================================================

/// A group of rows under one small heading, on one white surface with
/// hairlines between the rows. Never a stack of floating cards.
class TtcDoseGroup extends StatelessWidget {
  const TtcDoseGroup({super.key, this.label, required this.children});

  final String? label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label != null) ...[
        Text(label!.toUpperCase(),
            style: pvManrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: p.ink3)),
        const SizedBox(height: 8),
      ],
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Container(height: 1, color: p.line),
              ),
            children[i],
          ],
        ]),
      ),
    ]);
  }
}

/// The round tick. Ink when done, a hairline ring when not.
class TtcDoseTick extends StatelessWidget {
  const TtcDoseTick({super.key, required this.on, this.size = 28});

  final bool on;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? ttcTitleInk : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: on ? ttcTitleInk : p.ink3, width: 1.6),
      ),
      child: on
          ? Icon(Icons.check_rounded, size: size * 0.58, color: Colors.white)
          : null,
    );
  }
}

/// One row: the tick (when [onTick] is given), the name and what to take,
/// and the rest of the row opens its page.
///
/// ⚠️ TWO TARGETS, AND EACH SAYS WHAT IT DOES. The circle is 48 points of
/// thumb room and ticks; the words and the chevron open the page. Before,
/// Supplements ticked on a row tap and Medication opened on a row tap, so the
/// same gesture did opposite things one tile apart.
class TtcDoseRow extends StatelessWidget {
  const TtcDoseRow({
    super.key,
    required this.name,
    required this.onOpen,
    this.detail = '',
    this.note = '',
    this.taken = false,
    this.onTick,
  });

  final String name;
  final String detail;

  /// A third, quieter line: the reminder times, or where it went.
  final String note;
  final bool taken;
  final VoidCallback? onTick;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
        child: Row(children: [
          if (onTick != null)
            Semantics(
              button: true,
              checked: taken,
              label: taken ? '$name, taken. Tap to undo' : 'Mark $name taken',
              child: GestureDetector(
                key: ValueKey('ttc_dose_tick_$name'),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTick!();
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(child: TtcDoseTick(on: taken)),
                ),
              ),
            )
          else
            SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: Icon(Icons.history_rounded, size: 20, color: p.ink3),
              ),
            ),
          const SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: pvJakarta(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: p.ink1)),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(detail,
                          style: pvManrope(
                              fontSize: 12.5, height: 1.4, color: p.ink2)),
                    ],
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(note,
                          style: pvManrope(
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: p.ink3)),
                    ],
                  ]),
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
        ]),
      ),
    );
  }
}

/// A plain row with a leading icon, for "read about this" and the link to
/// the neighbouring list. Hairline, never a coloured link.
class TtcDoseLinkRow extends StatelessWidget {
  const TtcDoseLinkRow({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.eyebrow,
  });

  final IconData icon;
  final String text;
  final String? eyebrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Row(children: [
          Icon(icon, size: 19, color: p.ink2),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    Text(eyebrow!.toUpperCase(),
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: p.ink3)),
                    const SizedBox(height: 3),
                  ],
                  Text(text,
                      style: pvManrope(
                          fontSize: 13.5,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                ]),
          ),
          Icon(Icons.chevron_right_rounded, size: 19, color: p.ink3),
        ]),
      ),
    );
  }
}

/// The first-open invitation, in the tool's own look. Says what the list is
/// for and has its button right there.
class TtcDoseEmpty extends StatelessWidget {
  const TtcDoseEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle, border: Border.all(color: p.line)),
          child: Icon(icon, size: 21, color: p.ink1),
        ),
        const SizedBox(height: 13),
        Text(title,
            style: pvFraunces(
                fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 6),
        Text(body,
            style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
        const SizedBox(height: 16),
        TtcDoseInkButton(label: cta, onTap: onTap),
      ]),
    );
  }
}

/// The small ink pill: the base UI's commit, used where one action belongs to
/// a block ("Add your own", "Merge them").
class TtcDoseInkButton extends StatelessWidget {
  const TtcDoseInkButton(
      {super.key, required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Material(
        color: ttcTitleInk,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon ?? Icons.add_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(label,
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ]),
          ),
        ),
      );
}

/// The hero's "Add", the same pill Records wears top right.
class TtcDoseHeroAdd extends StatelessWidget {
  const TtcDoseHeroAdd({super.key, required this.onTap, this.label = 'Add'});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          key: const ValueKey('ttc_dose_hero_add'),
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ttcBorder),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, size: 15, color: ttcTitleInk),
              const SizedBox(width: 5),
              Text(label,
                  style: ttcBody(12, color: ttcTitleInk, w: FontWeight.w800)),
            ]),
          ),
        ),
      );
}

/// A small uppercase heading inside the sheet of a tool page.
Widget ttcDoseHeading(String text) {
  final p = V2PaletteStore.instance.current;
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text,
        style: pvJakarta(
            fontSize: 17, fontWeight: FontWeight.w700, color: p.ink1)),
  );
}

// =============================================================================
//  The detail page's two parts
// =============================================================================

/// Today's tick, as the big control on an item's own page.
class TtcDoseTodayButton extends StatelessWidget {
  const TtcDoseTodayButton(
      {super.key, required this.taken, required this.onTap});

  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Semantics(
      button: true,
      checked: taken,
      child: InkWell(
        key: const ValueKey('ttc_dose_today'),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          decoration: BoxDecoration(
            color: taken ? ttcTitleInk : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: taken ? ttcTitleInk : p.line),
          ),
          child: Row(children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: taken ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
                border: taken ? null : Border.all(color: p.ink3, width: 1.6),
              ),
              child: taken
                  ? const Icon(Icons.check_rounded,
                      size: 18, color: ttcTitleInk)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(taken ? 'Taken today' : 'Mark as taken today',
                        style: pvManrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: taken ? Colors.white : p.ink1)),
                    if (taken)
                      Text('Tap again to undo',
                          style: pvManrope(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8))),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// The last four weeks, Monday to Sunday, tap a day to add or clear it.
///
/// ⚠️ A RECORD SHE CAN CORRECT, NOT A SCORE. No count sits beside it and no
/// colour changes with how full it is. Days after today are drawn faint and
/// cannot be tapped: a dose can't be taken tomorrow.
class TtcDoseHistory extends StatelessWidget {
  const TtcDoseHistory({
    super.key,
    required this.takenOn,
    required this.onToggle,
    this.since,
  });

  final bool Function(DateTime day) takenOn;
  final ValueChanged<DateTime> onToggle;

  /// Days before this are drawn faint and cannot be tapped (the day it was
  /// added, for a list with a start). Null means every past day is open.
  final DateTime? since;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final today = ttcDoseDay(DateTime.now());
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final first = thisMonday.subtract(const Duration(days: 21));

    Widget cell(DateTime day) {
      final future = day.isAfter(today);
      final before = since != null && day.isBefore(ttcDoseDay(since!));
      final on = !future && takenOn(day);
      final isToday = day == today;
      return Expanded(
        child: GestureDetector(
          key: ValueKey('ttc_dose_hist_${day.month}_${day.day}'),
          onTap: future || before
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onToggle(day);
                },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Center(
              child: Semantics(
                button: !(future || before),
                checked: on,
                label: ttcDoseDayName(day),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? ttcTitleInk : Colors.transparent,
                    shape: BoxShape.circle,
                    border: on
                        ? null
                        : Border.all(
                            color: future || before
                                ? p.line.withValues(alpha: 0.5)
                                : isToday
                                    ? p.ink1
                                    : p.line,
                            width: isToday ? 1.6 : 1.2),
                  ),
                  child: Text('${day.day}',
                      style: pvManrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: on
                              ? Colors.white
                              : future || before
                                  ? p.ink3.withValues(alpha: 0.5)
                                  : p.ink1)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(children: [
        Row(children: [
          for (final w in _weekdays)
            Expanded(
              child: Center(
                child: Text(w,
                    style: pvManrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink3)),
              ),
            ),
        ]),
        const SizedBox(height: 4),
        for (var week = 0; week < 4; week++)
          Row(children: [
            for (var d = 0; d < 7; d++)
              cell(first.add(Duration(days: week * 7 + d))),
          ]),
        const SizedBox(height: 6),
        Row(children: [
          const SizedBox(width: 6),
          const TtcDoseTick(on: true, size: 14),
          const SizedBox(width: 6),
          Text('Taken',
              style: pvManrope(fontSize: 11.5, color: p.ink2)),
          const SizedBox(width: 14),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: p.ink1, width: 1.4)),
          ),
          const SizedBox(width: 6),
          Text('Today',
              style: pvManrope(fontSize: 11.5, color: p.ink2)),
        ]),
      ]),
    );
  }
}

// =============================================================================
//  The add and change sheet
// =============================================================================

/// Opens a tool sheet. One route name per sheet so tests and the Ask Veda
/// button can tell where she is.
Future<T?> showTtcDoseSheet<T>(BuildContext context,
        {required String routeName, required WidgetBuilder builder}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: RouteSettings(name: routeName),
      builder: builder,
    );

/// The sheet's frame: white, a handle, the tool's name as its eyebrow and one
/// serif line saying what the sheet does.
class TtcDoseSheet extends StatelessWidget {
  const TtcDoseSheet({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                          color: p.line,
                          borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(eyebrow.toUpperCase(),
                      style: pvManrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          color: p.ink2)),
                  const SizedBox(height: 6),
                  Text(title,
                      style: pvFraunces(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: p.ink1)),
                  const SizedBox(height: 18),
                  ...children,
                ]),
          ),
        ),
      ),
    );
  }
}

/// A labelled field. The label stays above the box, so a filled box still
/// says what it holds.
class TtcDoseField extends StatelessWidget {
  const TtcDoseField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '',
    this.lines = 1,
    this.autofocus = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final int lines;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: p.line),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ttcDoseLabel(label),
        TextField(
          controller: controller,
          autofocus: autofocus,
          maxLines: lines,
          minLines: 1,
          onChanged: onChanged,
          textCapitalization: TextCapitalization.sentences,
          style: pvManrope(
              fontSize: 14.5, fontWeight: FontWeight.w600, color: p.ink1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: pvManrope(fontSize: 14, color: p.ink3),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: p.ink1, width: 1.4),
            ),
          ),
        ),
      ]),
    );
  }
}

/// The small uppercase label above a field.
Widget ttcDoseLabel(String text) {
  final p = V2PaletteStore.instance.current;
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text.toUpperCase(),
        style: pvManrope(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: p.ink3)),
  );
}

/// Two answers, one chosen, as the tool's own blocks.
class TtcDoseWhose extends StatelessWidget {
  const TtcDoseWhose({super.key, required this.partner, required this.onPick});

  final bool partner;
  final ValueChanged<bool> onPick;

  @override
  Widget build(BuildContext context) => TtcToolOptions(
        p: V2PaletteStore.instance.current,
        items: [
          TtcToolOption(
              label: 'Yours', on: !partner, onTap: () => onPick(false)),
          TtcToolOption(
              label: "Your partner's", on: partner, onTap: () => onPick(true)),
        ],
      );
}

/// The quiet destructive line at the foot of an item's page.
class TtcDoseRemoveLine extends StatelessWidget {
  const TtcDoseRemoveLine(
      {super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
        child: TextButton.icon(
          key: const ValueKey('ttc_dose_remove'),
          onPressed: onTap,
          icon: const Icon(Icons.delete_outline_rounded,
              size: 17, color: Color(0xFFB42318)),
          label: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB42318))),
        ),
      );
}

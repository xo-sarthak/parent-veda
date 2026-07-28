// =============================================================================
//  TTC - Calendar
// -----------------------------------------------------------------------------
//  "The calendar philosophy remains unchanged. It becomes the TTC Command
//   Centre."                                            - TTC master, §2.9
//
//  Same architecture as the pregnancy Calendar: a month grid with coloured day
//  markers, a collapsible legend, and a panel for the selected day - merging
//  the cycle, the fertile window, journal entries, everything logged in the
//  trackers, and the milestones reached.
//
//  The fertile window is drawn from the SAME engine that drives Today's hero
//  and the Fertility Window tool, so the three can never disagree.
//
//  One deliberate restraint: the next expected period is shown as a soft
//  outline, not a solid marker, and is labelled "expected". A calendar that
//  draws a confident dot on a day her body has not agreed to is exactly the
//  quiet dishonesty this stage is built to avoid.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/family_timeline.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_trackers_data.dart';
import '../../ttc/ttc_treatment_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_timeline_screen.dart';

class TtcCalendarScreen extends StatefulWidget {
  const TtcCalendarScreen({super.key});

  @override
  State<TtcCalendarScreen> createState() => _TtcCalendarScreenState();
}

class _TtcCalendarScreenState extends State<TtcCalendarScreen> {
  late DateTime _month = _monthOf(DateTime.now());
  late DateTime _selected = _dayOf(DateTime.now());
  // Open by default. A first-time user met eight different markers with the
  // key folded away, which makes the calendar something to decode rather than
  // read. Once she knows them she can close it; the state is hers after that.
  bool _legendOpen = true;

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);
  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcStore.instance,
        TtcLogStore.instance,
        TtcJournalStore.instance,
        TtcAppointmentsStore.instance,
        TtcTreatmentStore.instance,
        FamilyTimeline.instance,
        TtcLang.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        return TtcPage(
          tab: 3,
          header: const TtcHeader(),
          children: [
            ttcSectionTitle(t.calendarTitle, eyebrow: t.tabCalendar),
            _MonthGrid(
              month: _month,
              selected: _selected,
              onSelect: (d) => setState(() => _selected = d),
              onMonth: (delta) => setState(() {
                _month = DateTime(_month.year, _month.month + delta);
              }),
              t: t,
            ),
            // A fertile run that crosses a month boundary used to vanish at the
            // edge of the grid: four faint circles trailing off the bottom row
            // and nothing saying the peak was in the next month.
            _BoundaryNote(month: _month, t: t),
            const SizedBox(height: 14),
            _Legend(
              open: _legendOpen,
              onToggle: () => setState(() => _legendOpen = !_legendOpen),
              behaviour: TtcStore.instance.behaviour,
              t: t,
            ),
            const SizedBox(height: 18),
            _DayPanel(day: _selected, t: t),
            const SizedBox(height: 18),
            _Upcoming(t: t),
            const SizedBox(height: 14),
            TtcCard(
              onTap: () => openTtcTimeline(context),
              child: Row(children: [
                const Icon(Icons.timeline_rounded, size: 19, color: ttcPurple),
                const SizedBox(width: 12),
                Expanded(child: Text(t.familyTimeline, style: ttcJakarta(15.5))),
                const Icon(Icons.arrow_forward_rounded,
                    size: 17, color: ttcMuted),
              ]),
            ),
          ],
        );
      },
    );
  }
}

// ---- what a given day holds -------------------------------------------------

/// Resolved once per day cell rather than recomputed by each widget that wants
/// a piece of it.
class TtcDayFacts {
  const TtcDayFacts({
    required this.isPeriodStart,
    required this.fertility,
    required this.isOvulation,
    required this.isExpectedPeriod,
    required this.loggedTrackers,
    required this.journalEntries,
    required this.timelineEvents,
    required this.appointments,
    this.treatment = const [],
  });

  final bool isPeriodStart;
  final FertilityLevel? fertility;
  final bool isOvulation;

  /// Where the next period is expected. Drawn as an outline, never a solid dot.
  final bool isExpectedPeriod;

  final List<String> loggedTrackers;
  final List<TtcJournalEntry> journalEntries;
  final List<TimelineEvent> timelineEvents;
  final List<TtcAppointment> appointments;

  /// Clinic milestones falling on this day - trigger, retrieval, transfer, beta.
  final List<String> treatment;

  bool get hasAnything =>
      isPeriodStart ||
      isOvulation ||
      (fertility != null && fertility != FertilityLevel.low) ||
      loggedTrackers.isNotEmpty ||
      journalEntries.isNotEmpty ||
      timelineEvents.isNotEmpty ||
      appointments.isNotEmpty ||
      treatment.isNotEmpty;
}

TtcDayFacts ttcFactsFor(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  final cycle = CycleStore.instance;
  final store = TtcStore.instance;
  const engine = TtcChapterEngine();

  final isStart = cycle.periodStarts.any((p) =>
      p.year == d.year && p.month == d.month && p.day == d.day);

  // Which cycle day this date falls on, relative to the most recent period
  // start on or before it - so past months read correctly too.
  DateTime? openedOn;
  for (final p in cycle.periodStarts) {
    if (!p.isAfter(d)) openedOn = p;
  }

  FertilityLevel? fertility;
  var isOvulation = false;
  var isExpected = false;

  if (openedOn != null) {
    final state = store.state(on: d);
    final cycleDay = d.difference(openedOn).inDays + 1;
    final ov = engine.estimatedOvulationDay(state);
    final len = engine.cycleLengthFor(state);
    fertility = engine.fertilityFor(state, cycleDay);
    isOvulation = ov != null && cycleDay == ov;
    // Only project forward from the CURRENT cycle - drawing an expected period
    // into a month that already happened would be nonsense.
    //
    // And never on a medicated cycle: progesterone support usually delays the
    // period, so an "expected" marker there is a date her body has not agreed
    // to and her clinic never mentioned.
    isExpected = store.behaviour.countsToPeriod &&
        openedOn == cycle.lastPeriodStart &&
        cycleDay == len + 1;
  }

  // The clinic's real dates, plotted like any other event.
  final treatment = <String>[
    for (final step in TtcTreatmentStep.values)
      if (_sameDay(TtcTreatmentStore.instance.cycle[step], d))
        step.label(TtcLang.instance.hinglish)
  ];

  final dayKey = TtcLogStore.dayKey(d);
  final logged = <String>[
    for (final tracker in ttcTrackers)
      if (TtcLogStore.instance.valuesOn(tracker.id, dayKey).isNotEmpty)
        tracker.id
  ];

  final journal = TtcJournalStore.instance.entries
      .where((e) =>
          e.date.year == d.year &&
          e.date.month == d.month &&
          e.date.day == d.day)
      .toList();

  final timeline = FamilyTimeline.instance.events
      .where((e) =>
          e.date.year == d.year &&
          e.date.month == d.month &&
          e.date.day == d.day)
      .toList();

  return TtcDayFacts(
    isPeriodStart: isStart,
    fertility: fertility,
    isOvulation: isOvulation,
    isExpectedPeriod: isExpected,
    loggedTrackers: logged,
    journalEntries: journal,
    timelineEvents: timeline,
    appointments: TtcAppointmentsStore.instance.on(d),
    treatment: treatment,
  );
}

bool _sameDay(DateTime? a, DateTime b) =>
    a != null && a.year == b.year && a.month == b.month && a.day == b.day;

// ---- the grid ---------------------------------------------------------------

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.onMonth,
    required this.t,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onMonth;
  final TtcS t;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Sunday-first, matching the pregnancy calendar.
    //
    // This was Monday-first "as Indian calendars are usually printed", which is
    // arguable either way - but two stages of one app disagreeing about where
    // the week starts is not. Pregnancy has real users; TTC moves.
    final leading = first.weekday % 7;
    final today = DateTime.now();

    return TtcCard(
      child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: () => onMonth(-1),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.chevron_left_rounded, size: 22, color: ttcSoft),
            ),
          ),
          Expanded(
            child: Text('${_monthNames[month.month - 1]} ${month.year}',
                textAlign: TextAlign.center, style: ttcJakarta(15.5)),
          ),
          GestureDetector(
            onTap: () => onMonth(1),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.chevron_right_rounded, size: 22, color: ttcSoft),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final d in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(
                child: Text(d,
                    textAlign: TextAlign.center,
                    style: ttcBody(10.5, color: ttcMuted, w: FontWeight.w800)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (var row = 0; row < ((leading + daysInMonth) / 7).ceil(); row++)
          // The fertile run is drawn as ONE capsule behind the row, not as a
          // tint on each day. Individually tinted circles were a hair off white
          // - the most important days of the month were the least visible thing
          // on the screen - and six separate marks never read as one stretch.
          // The pregnancy calendar already draws its birth window this way.
          Stack(children: [
            Positioned.fill(
              child: Row(children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: TtcFertileBand.isFertile(
                            _dateAt(month, row, col, leading, daysInMonth))
                        ? TtcFertileBand(
                            date:
                                _dateAt(month, row, col, leading, daysInMonth),
                            before: _dateAt(
                                month, row, col - 1, leading, daysInMonth),
                            after: _dateAt(
                                month, row, col + 1, leading, daysInMonth),
                            firstInRow: col == 0,
                            lastInRow: col == 6,
                          )
                        : const SizedBox(height: 42),
                  ),
              ]),
            ),
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: Builder(builder: (context) {
                      final dayNum = row * 7 + col - leading + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) {
                        return const SizedBox(height: 42);
                      }
                      final date = DateTime(month.year, month.month, dayNum);
                      return _DayCell(
                        date: date,
                        isToday: date.year == today.year &&
                            date.month == today.month &&
                            date.day == today.day,
                        isSelected: date == selected,
                        onTap: () => onSelect(date),
                      );
                    }),
                  ),
              ],
            ),
          ]),
      ]),
    );
  }
}

/// Says so when the fertile run does not fit inside the month on screen.
class _BoundaryNote extends StatelessWidget {
  const _BoundaryNote({required this.month, required this.t});

  final DateTime month;
  final TtcS t;

  static const _names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static bool isFertile(DateTime d) {
    final f = ttcFactsFor(d).fertility;
    return f != null && f != FertilityLevel.low;
  }

  @override
  Widget build(BuildContext context) {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstDay = DateTime(month.year, month.month, 1);

    // Only worth saying when the run is actually cut - a window sitting neatly
    // inside the month needs no explanation.
    final runsOn =
        isFertile(lastDay) && isFertile(lastDay.add(const Duration(days: 1)));
    final camefrom = isFertile(firstDay) &&
        isFertile(firstDay.subtract(const Duration(days: 1)));

    if (!runsOn && !camefrom) return const SizedBox(height: 14);

    final next = DateTime(month.year, month.month + 1);
    final prev = DateTime(month.year, month.month - 1);
    final text = runsOn
        ? t.continuesInto(_names[next.month - 1])
        : t.continuedFrom(_names[prev.month - 1]);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.east_rounded, size: 14, color: ttcCoral),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text, style: ttcBody(11.5, color: ttcSoft, h: 1.45))),
      ]),
    );
  }
}

/// The date at a grid position, or null outside the month.
DateTime? _dateAt(
    DateTime month, int row, int col, int leading, int daysInMonth) {
  final n = row * 7 + col - leading + 1;
  if (n < 1 || n > daysInMonth) return null;
  return DateTime(month.year, month.month, n);
}

/// One column's slice of the fertile capsule.
///
/// Rounds only where the run actually starts and ends, so a stretch of fertile
/// days reads as a single band rather than a row of separate pills - including
/// where it runs off the end of a week and picks up on the next line.
/// Public so a test can assert the band exists rather than inferring it from a
/// colour, which is how a "does the window render" test quietly stops testing
/// anything.
class TtcFertileBand extends StatelessWidget {
  const TtcFertileBand({
    super.key,
    required this.date,
    required this.before,
    required this.after,
    required this.firstInRow,
    required this.lastInRow,
  });

  final DateTime? date;
  final DateTime? before;
  final DateTime? after;
  final bool firstInRow;
  final bool lastInRow;

  /// Public so the grid can skip building a band that would draw nothing -
  /// an invisible widget in the tree is a widget a test can find and wrongly
  /// conclude something rendered.
  static bool isFertile(DateTime? d) {
    if (d == null) return false;
    final f = ttcFactsFor(d).fertility;
    return f != null && f != FertilityLevel.low;
  }

  @override
  Widget build(BuildContext context) {
    final openLeft = isFertile(before) && !firstInRow;
    final openRight = isFertile(after) && !lastInRow;
    const r = Radius.circular(999);

    return Center(
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          // Deliberately a shade you can actually see. The old per-day tint at
          // "medium" was indistinguishable from white.
          color: ttcFertilityTint(ttcFactsFor(date!).fertility!),
          borderRadius: BorderRadius.only(
            topLeft: openLeft ? Radius.zero : r,
            bottomLeft: openLeft ? Radius.zero : r,
            topRight: openRight ? Radius.zero : r,
            bottomRight: openRight ? Radius.zero : r,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final facts = ttcFactsFor(date);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: facts.isPeriodStart
                    ? ttcCoral
                    : isSelected
                        ? ttcPurple
                        : Colors.transparent,
                shape: BoxShape.circle,
                // The expected period is an OUTLINE, never a solid marker - it
                // is a projection, not a fact about her body.
                border: facts.isExpectedPeriod
                    ? Border.all(color: ttcCoral, width: 1.4)
                    : isToday && !isSelected
                        ? Border.all(color: ttcPurple, width: 1.4)
                        : null,
              ),
              child: Text('${date.day}',
                  style: ttcBody(12.5,
                      color: (facts.isPeriodStart || isSelected)
                          ? Colors.white
                          // Ovulation is marked by WEIGHT on the deepest part
                          // of the band, not by a separate dot. The dot was
                          // ttcBrown - the only brown in a pink and purple
                          // palette, which read as a bug on the single most
                          // important day of the cycle.
                          : facts.isOvulation
                              ? ttcCoral
                              : ttcInk,
                      w: (isToday || facts.isOvulation)
                          ? FontWeight.w900
                          : FontWeight.w600)),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (facts.loggedTrackers.isNotEmpty) _dot(ttcPurple),
                  if (facts.journalEntries.isNotEmpty) _dot(ttcMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

// ---- legend -----------------------------------------------------------------

class _Legend extends StatelessWidget {
  const _Legend({
    required this.open,
    required this.onToggle,
    required this.behaviour,
    required this.t,
  });

  final bool open;
  final VoidCallback onToggle;

  /// A legend must describe THIS calendar, not every calendar.
  ///
  /// It listed every marker unconditionally, so a couple on a clinic cycle -
  /// where the fertile window, the ovulation day and the expected period are
  /// all deliberately suppressed - read a key for three things their grid would
  /// never draw. Opening the legend by default is what made that visible.
  final TtcPathwayBehaviour behaviour;

  final TtcS t;

  @override
  Widget build(BuildContext context) {
    return TtcCard(
      onTap: onToggle,
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(t.calendarLegend,
                  style: ttcBody(13, color: ttcInk, w: FontWeight.w700))),
          Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: 19, color: ttcMuted),
        ]),
        if (open) ...[
          const SizedBox(height: 14),
          _row(ttcCoral, t.calendarPeriod, filled: true),
          if (behaviour.showsFertilityWindow) ...[
            _row(ttcFertilityTint(FertilityLevel.peak), t.calendarFertile,
                filled: true),
            // Ovulation is weight on the band, not a swatch - so the legend
            // says what to look for rather than showing a colour that no
            // longer exists.
            _row(ttcCoral, t.calendarOvulation, bold: true),
          ],
          // "Today" was missing entirely, while being the boldest ring drawn.
          _row(ttcPurple, t.calendarToday, outline: true),
          _row(ttcPurple, t.calendarLogged),
          if (behaviour.countsToPeriod)
            _row(ttcCoral, t.calendarNextPeriod, outline: true),
        ],
      ]),
    );
  }

  Widget _row(Color c, String label,
          {bool filled = false, bool outline = false, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          SizedBox(
            width: 16,
            height: 16,
            child: Center(
              child: bold
                  ? Text('14',
                      style: ttcBody(10, color: c, w: FontWeight.w900))
                  : Container(
                      width: filled ? 16 : 8,
                      height: filled ? 16 : 8,
                      decoration: BoxDecoration(
                        color: outline ? Colors.transparent : c,
                        shape: BoxShape.circle,
                        border:
                            outline ? Border.all(color: c, width: 1.4) : null,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(label, style: ttcBody(12.5))),
        ]),
      );
}

// ---- selected day -----------------------------------------------------------

class _DayPanel extends StatelessWidget {
  const _DayPanel({required this.day, required this.t});

  final DateTime day;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final facts = ttcFactsFor(day);
    final today = DateTime.now();
    final isToday = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;

    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isToday ? t.calendarToday : _fmt(day), style: ttcJakarta(16)),
        const SizedBox(height: 12),
        if (!facts.hasAnything)
          Text(t.calendarNothing, style: ttcBody(13.5))
        else ...[
          if (facts.isPeriodStart)
            _line(Icons.circle, ttcCoral, t.calendarPeriod),
          if (facts.isOvulation)
            _line(Icons.egg_outlined, ttcBrown, t.calendarOvulation),
          if (facts.fertility != null &&
              facts.fertility != FertilityLevel.low)
            _line(Icons.wb_twilight_rounded, ttcPurple,
                '${t.calendarFertile} · ${facts.fertility!.label(hi)}'),
          for (final id in facts.loggedTrackers)
            _line(Icons.check_circle_outline_rounded, ttcPurple,
                ttcTrackerById(id)?.title(hi) ?? id),
          for (final e in facts.journalEntries)
            _line(Icons.edit_outlined, ttcMuted,
                '${e.kind.label(hi)} · ${e.text}'),
          for (final step in facts.treatment)
            _line(Icons.local_hospital_outlined, ttcPurple, step),
          for (final a in facts.appointments)
            _line(Icons.event_note_outlined, ttcBrown,
                a.withWhom.isEmpty ? a.title : '${a.title} · ${a.withWhom}'),
          for (final e in facts.timelineEvents)
            _line(Icons.auto_awesome_rounded, ttcCoral, e.title(hi)),
        ],
      ]),
    );
  }

  Widget _line(IconData icon, Color color, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(13, color: ttcInk, h: 1.45)),
          ),
        ]),
      );

  static String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

// ---- upcoming ---------------------------------------------------------------

class _Upcoming extends StatelessWidget {
  const _Upcoming({required this.t});
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final store = TtcStore.instance;
    final today = store.today;

    // On a medicated cycle the countdown is to the BLOOD TEST, not a period.
    // Progesterone support usually delays the period, so counting to it
    // produces a "you are late" that means nothing and reads as hope - which is
    // the cruellest possible way for this card to be wrong.
    if (today.behaviour.countsToBeta) {
      final beta = TtcTreatmentStore.instance.cycle.betaTest;
      if (beta == null) return const SizedBox();
      final days = DateTime(beta.year, beta.month, beta.day)
          .difference(DateTime.now())
          .inDays;
      return TtcCard(
        color: ttcPanel,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ttcEyebrow(t.calendarUpcoming, color: ttcPurple),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.biotech_outlined, size: 15, color: ttcPurple),
            const SizedBox(width: 10),
            Expanded(child: Text(t.betaWaitTitle, style: ttcBody(13.5))),
            Text(t.betaWaitDays(days),
                style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w800)),
          ]),
          const SizedBox(height: 9),
          Text(t.betaWaitNote, style: ttcBody(11.5, h: 1.5)),
        ]),
      );
    }

    final last = CycleStore.instance.lastPeriodStart;
    if (last == null || today.cycleDay == null) return const SizedBox();

    final nextPeriod = last.add(Duration(days: today.cycleLength));
    final daysAway = nextPeriod.difference(DateTime.now()).inDays;

    return TtcCard(
      color: ttcPanel,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ttcEyebrow(t.calendarUpcoming, color: ttcPurple),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.circle_outlined, size: 15, color: ttcCoral),
          const SizedBox(width: 10),
          Expanded(child: Text(t.calendarNextPeriod, style: ttcBody(13.5))),
          // "In 6 days" rather than a countdown to a result. Never "6 days
          // until you find out".
          Text(
            daysAway <= 0
                ? (hi ? 'Kabhi bhi' : 'Any day now')
                : (hi ? '$daysAway din mein' : 'in $daysAway days'),
            style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w800),
          ),
        ]),
      ]),
    );
  }
}

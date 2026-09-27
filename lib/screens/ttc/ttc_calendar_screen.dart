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
//
//  ---------------------------------------------------------------------------
//  ⚠️ A TREATMENT ROUND ON THE CALENDAR (2026-09-26, docs/TTC-TREATMENT-FLOW.md
//  §3c, B5)
//  ---------------------------------------------------------------------------
//  * Her clinic's dates are named markers: a small ink dot under the day, and
//    the step's own name for her kind of round in the day panel. Scans too.
//  * Two soft bands, drawn like the fertile capsule in a cooler tint:
//    "Injection days" (first injection to trigger) and "Waiting for your
//    blood test" (transfer, IUI or trigger to the test). Only between dates
//    she entered (`ttcRoundBandOn`); a missing end draws no band.
//  * "Coming up" names the NEXT clinic date, not only the blood test, and the
//    blood test by its date, never counted down (the hero's rule).
//  * Past rounds keep their dates and bands, labelled "Past round".
//  * Natural marks never land on a round day: the resolver refuses a window,
//    an expected period and late there (`ttcDayContext` rules 2 and 2b), and
//    this file only draws what the resolver says.
//  Mobbin: Stardust's month grid with a multi-day stretch as one capsule
//  (https://mobbin.com/screens/3e4e004e-47a7-4343-a1d4-eba972fb4905) and
//  Fresha's "Upcoming" card, "In 7 days · Wed 19 Aug"
//  (https://mobbin.com/screens/95504603-982b-41db-81ab-e8b7d9216501).
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/family_timeline.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_home_situation.dart' show ttcDueDateIfConceivedOn;
import '../../ttc/ttc_day_context.dart';
import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_trackers_data.dart';
import '../../ttc/ttc_treatment_round.dart';
import '../../ttc/ttc_treatment_store.dart';
import 'ttc_common.dart';
import 'ttc_round_strings.dart';
import 'ttc_strings.dart';
import 'ttc_timeline_screen.dart';
import 'ttc_treatment_screen.dart' show openTtcTreatment;

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
              // A marker can be absent for TWO reasons and the legend only knew
              // one. It correctly hid the fertile rows on a clinic path, then
              // showed them anyway when the engine had refused to estimate from
              // an unreliable history - so the key advertised two colours the
              // grid never drew, on the one screen she would go looking for
              // them.
              hasEstimate: const TtcChapterEngine()
                      .estimatedOvulationDay(TtcStore.instance.state()) !=
                  null,
              // The round's own marks, only when there is a round to draw.
              roundKind: ttcCalendarRound()?.kind,
              hasRound: ttcCalendarRound() != null,
              t: t,
            ),
            const SizedBox(height: 18),
            _DayPanel(day: _selected, t: t),
            const SizedBox(height: 18),
            _Upcoming(t: t),
            const SizedBox(height: 14),
            // A way to the whole round from the calendar, whenever there is
            // one to see (2026-09-26, B5). Past rounds live there too.
            if (!TtcTreatmentStore.instance.cycle.isEmpty ||
                TtcTreatmentStore.instance.history.isNotEmpty) ...[
              TtcCard(
                key: const ValueKey('ttc_calendar_see_round'),
                onTap: () => openTtcTreatment(context),
                child: Row(children: [
                  const Icon(Icons.event_note_outlined,
                      size: 19, color: ttcTitleInk),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kTtcCalendarSeeRound, style: ttcJakarta(15.5)),
                          const SizedBox(height: 2),
                          Text(kTtcCalendarSeeRoundLine,
                              style: ttcBody(12, h: 1.4)),
                        ]),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 17, color: ttcMuted),
                ]),
              ),
              const SizedBox(height: 14),
            ],
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
    this.lookingBack = false,
    this.roundBand,
    this.roundKind,
  });

  final bool isPeriodStart;

  /// True when [fertility] and [isOvulation] describe an EARLIER cycle's
  /// window, worked out looking back from that cycle's own length
  /// (2026-09-26, `ttcDayContext` rule 3). The grid shades it like any
  /// window; the words beside it say "looking back" and carry no grade.
  final bool lookingBack;
  final FertilityLevel? fertility;
  final bool isOvulation;

  /// Where the next period is expected. Drawn as an outline, never a solid dot.
  final bool isExpectedPeriod;

  final List<String> loggedTrackers;
  final List<TtcJournalEntry> journalEntries;
  final List<TimelineEvent> timelineEvents;
  final List<TtcAppointment> appointments;

  /// Clinic milestones falling on this day - trigger, retrieval, transfer, beta.
  /// Named for her kind of round since 2026-09-26, scans included, and a
  /// past round's dates prefixed "Past round".
  final List<String> treatment;

  /// The round's soft band on this day, if any (`ttcRoundBandOn`), and the
  /// kind of the round it belongs to, for its name.
  final TtcRoundBand? roundBand;
  final TtcRoundKind? roundKind;

  /// True when her clinic gave a date for this day.
  bool get isClinicDate => treatment.isNotEmpty;

  bool get hasAnything =>
      isPeriodStart ||
      isOvulation ||
      (fertility != null && fertility != FertilityLevel.low) ||
      loggedTrackers.isNotEmpty ||
      journalEntries.isNotEmpty ||
      timelineEvents.isNotEmpty ||
      appointments.isNotEmpty ||
      treatment.isNotEmpty ||
      roundBand != null;
}

/// The round the calendar draws its legend for: the open one, else the last
/// closed. Null with no round at all.
TtcTreatmentCycle? ttcCalendarRound() {
  final t = TtcTreatmentStore.instance;
  if (!t.cycle.isEmpty) return t.cycle;
  return t.lastClosed;
}

/// Every clinic date on [d] (her open round first, then past rounds), named.
///
/// ⚠️ PAST ROUNDS STAY VISIBLE (§3c). A closed round moves to the history
/// and its dates are still facts about her; they are drawn with a "Past
/// round" prefix, never removed from the calendar.
List<String> ttcCalendarClinicLines(DateTime d) {
  final t = TtcTreatmentStore.instance;
  String name(TtcTreatmentStep? step, TtcRoundKind? kind) =>
      kind == null && step != null
          // A legacy round keeps the words it always had (and its Hindi).
          ? step.label(TtcLang.instance.hinglish)
          : ttcCalendarDateLabel(step, kind);
  List<String> of(TtcTreatmentCycle r, {String prefix = ''}) => [
        for (final step in TtcTreatmentStep.values)
          if (_sameDay(r[step], d)) '$prefix${name(step, r.kind)}',
        for (final s in r.scans)
          if (_sameDay(s, d)) '$prefix${name(null, r.kind)}',
      ];
  return [
    ...of(t.cycle),
    for (final h in t.history.reversed)
      ...of(h, prefix: '$kTtcCalendarPastRound · '),
  ];
}

/// The round band on [d] and the kind of its round: the open round first.
(TtcRoundBand, TtcRoundKind?)? ttcCalendarBandOn(DateTime d) {
  final t = TtcTreatmentStore.instance;
  for (final r in [t.cycle, ...t.history.reversed]) {
    final b = ttcRoundBandOn(r, d);
    if (b != null) return (b, r.kind);
  }
  return null;
}

TtcDayFacts ttcFactsFor(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  final cycle = CycleStore.instance;
  // Kept for revert, with the arithmetic below that used them:
  //   final store = TtcStore.instance;
  //   const engine = TtcChapterEngine();

  final isStart = cycle.periodStarts.any((p) =>
      p.year == d.year && p.month == d.month && p.day == d.day);

  // Which cycle day this date falls on, relative to the most recent period
  // start on or before it - so past months read correctly too. (Now
  // `ctx.cycleStart`; kept for revert.)
  //   DateTime? openedOn;
  //   for (final p in cycle.periodStarts) {
  //     if (!p.isAfter(d)) openedOn = p;
  //   }

  // ⚠️ AND EARLIER CYCLES ARE SHADED AGAIN, LATER THE SAME DAY — FROM THEIR
  // OWN LENGTH. The user's decision (2026-09-26): earlier cycles show their
  // fertile days, as competitor calendars do, worked out looking back from
  // that cycle's own length (never from this cycle's estimate, which is what
  // the first bullet below removed). The resolver does it once, so the hero
  // on that date names the same days the grid shades. `lookingBack` tells the
  // day panel to say so.
  //
  // ⚠️ THE CYCLE FACTS COME FROM `ttcDayContext` SINCE 2026-09-26 — the
  // same resolver the home's hero, cards and reads use. Two things changed on
  // screen, both disagreements with the hero:
  //
  //   * An EARLIER cycle is no longer shaded fertile. It was shaded with THIS
  //     cycle's estimate (and this cycle's LH strip, when there was one),
  //     while the hero says in words that we only work out fertile days for
  //     the cycle she is in.
  //   * "Period expected" needs the same estimate the window does. On a
  //     history the engine will not estimate from, the hero says "not enough
  //     logged" and the calendar no longer puts a date beside it.
  //
  // The block below is the previous arithmetic, kept for revert.
  final ctx = ttcDayContext(d);
  final FertilityLevel? fertility = ctx.fertility;
  final isOvulation = ctx.isOvulationDay;
  final isExpected = ctx.isExpectedPeriodDay;
  //   FertilityLevel? fertility;
  //   var isOvulation = false;
  //   var isExpected = false;
  // if (openedOn != null) {
  //   final state = store.state(on: d);
  //   final cycleDay = d.difference(openedOn).inDays + 1;
  //   final ov = engine.estimatedOvulationDay(state);
  //   final len = engine.cycleLengthFor(state);
  //   fertility = engine.fertilityFor(state, cycleDay);
  //   isOvulation = ov != null && cycleDay == ov;
  //   // Only project forward from the CURRENT cycle - drawing an expected period
  //   // into a month that already happened would be nonsense.
  //   //
  //   // And never on a medicated cycle: progesterone support usually delays the
  //   // period, so an "expected" marker there is a date her body has not agreed
  //   // to and her clinic never mentioned.
  //   isExpected = store.behaviour.countsToPeriod &&
  //       openedOn == cycle.lastPeriodStart &&
  //       cycleDay == len + 1;
  // }

  // The clinic's real dates, plotted like any other event. Since 2026-09-26
  // named for her kind of round, scans and past rounds included
  // (`ttcCalendarClinicLines`). Kept for revert:
  //   final treatment = <String>[
  //     for (final step in TtcTreatmentStep.values)
  //       if (_sameDay(TtcTreatmentStore.instance.cycle[step], d))
  //         step.label(TtcLang.instance.hinglish)
  //   ];
  final treatment = ttcCalendarClinicLines(d);
  final band = ttcCalendarBandOn(d);

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
    lookingBack: ctx.lookingBack,
    roundBand: band?.$1,
    roundKind: band?.$2,
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
                        // A round's soft band, the same capsule in a cooler
                        // tint (2026-09-26, B5). Never on a fertile day: the
                        // resolver refuses a window on a round's days.
                        : TtcRoundBandSlice.bandOf(_dateAt(
                                    month, row, col, leading, daysInMonth)) !=
                                null
                            ? TtcRoundBandSlice(
                                date: _dateAt(
                                    month, row, col, leading, daysInMonth),
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

/// One column's slice of a round's soft band, rounded where the stretch
/// starts and ends, like [TtcFertileBand]. Public so a test can find it.
class TtcRoundBandSlice extends StatelessWidget {
  const TtcRoundBandSlice({
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

  static TtcRoundBand? bandOf(DateTime? d) =>
      d == null ? null : ttcFactsFor(d).roundBand;

  /// The two tints: cool and quiet, never the fertile pink.
  static Color tintFor(TtcRoundBand b) => switch (b) {
        TtcRoundBand.medicine => const Color(0xFFE3E8F4),
        TtcRoundBand.waitingForTest => const Color(0xFFEDE8F5),
      };

  @override
  Widget build(BuildContext context) {
    final mine = bandOf(date);
    if (mine == null) return const SizedBox(height: 42);
    final openLeft = bandOf(before) == mine && !firstInRow;
    final openRight = bandOf(after) == mine && !lastInRow;
    const r = Radius.circular(999);
    return Center(
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: tintFor(mine),
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
                  // A date her clinic gave her (2026-09-26, B5).
                  if (facts.isClinicDate)
                    _dot(ttcTitleInk,
                        key: const ValueKey('ttc_cal_clinic_dot')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c, {Key? key}) => Container(
        key: key,
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
    required this.hasEstimate,
    required this.t,
    this.hasRound = false,
    this.roundKind,
  });

  /// A round exists (open or past): the key names its marker and bands.
  final bool hasRound;
  final TtcRoundKind? roundKind;

  final bool open;
  final VoidCallback onToggle;

  /// A legend must describe THIS calendar, not every calendar.
  ///
  /// It listed every marker unconditionally, so a couple on a clinic cycle -
  /// where the fertile window, the ovulation day and the expected period are
  /// all deliberately suppressed - read a key for three things their grid would
  /// never draw. Opening the legend by default is what made that visible.
  final TtcPathwayBehaviour behaviour;

  /// The OTHER reason those markers can be missing: the engine looked at her
  /// history, found a gap long enough to be a cycle nobody logged, and refused
  /// to estimate. The pathway is still `natural`, so `showsFertilityWindow`
  /// stays true and the key kept promising a shading the grid had not drawn.
  ///
  /// Suppressing a marker and advertising it are decided in different places,
  /// which is exactly how they came apart.
  final bool hasEstimate;

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
          if (behaviour.showsFertilityWindow && hasEstimate) ...[
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
          if (hasRound) ...[
            _row(ttcTitleInk, kTtcCalendarClinicDate),
            if (roundKind != TtcRoundKind.ovulationInduction &&
                roundKind != TtcRoundKind.fetMedicated &&
                roundKind != TtcRoundKind.fetNatural)
              _row(TtcRoundBandSlice.tintFor(TtcRoundBand.medicine),
                  ttcRoundBandLabel(TtcRoundBand.medicine, roundKind),
                  filled: true),
            _row(TtcRoundBandSlice.tintFor(TtcRoundBand.waitingForTest),
                ttcRoundBandLabel(TtcRoundBand.waitingForTest, roundKind),
                filled: true),
          ],
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

    // ---- two lines from the gap analysis (2026-09-26, P3) -----------------
    //
    // "Period expected" on the day it is expected, and on a fertile day of
    // this cycle, the due date a pregnancy from it would have. NATURAL CYCLES
    // ONLY: `isExpectedPeriod` is already off on a medicated cycle, and the due
    // line checks the same behaviour flag the window does. A clinic owns its
    // own dates; we do not put a date of ours next to theirs.
    //
    // ⚠️ A CONDITION, NEVER A HOPE AND NEVER A CHANCE. "If this cycle works"
    // is plain arithmetic (266 days from conception) on a day she chose to
    // look at. It promises nothing, and it says nothing about how likely.
    final dueLine = _dueLine(day, facts);
    final showSomething = facts.hasAnything || facts.isExpectedPeriod;

    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isToday ? t.calendarToday : _fmt(day), style: ttcJakarta(16)),
        const SizedBox(height: 12),
        if (!showSomething)
          Text(t.calendarNothing, style: ttcBody(13.5))
        else ...[
          if (facts.isPeriodStart)
            _line(Icons.circle, ttcCoral, t.calendarPeriod),
          if (facts.isExpectedPeriod)
            _line(Icons.circle_outlined, ttcCoral, kTtcCalendarPeriodExpected),
          // An earlier cycle's window says "looking back" and carries no
          // grade (2026-09-26); the current cycle's reads as before.
          if (facts.isOvulation)
            _line(
                Icons.egg_outlined,
                ttcBrown,
                facts.lookingBack
                    ? t.calendarOvulationLookingBack
                    : t.calendarOvulation),
          if (facts.fertility != null &&
              facts.fertility != FertilityLevel.low)
            _line(
                Icons.wb_twilight_rounded,
                ttcPurple,
                facts.lookingBack
                    ? t.calendarFertileLookingBack
                    : '${t.calendarFertile} · ${facts.fertility!.label(hi)}'),
          if (dueLine != null)
            _line(Icons.child_friendly_outlined, ttcPurple, dueLine),
          for (final id in facts.loggedTrackers)
            _line(Icons.check_circle_outline_rounded, ttcPurple,
                ttcTrackerById(id)?.title(hi) ?? id),
          for (final e in facts.journalEntries)
            _line(Icons.edit_outlined, ttcMuted,
                '${e.kind.label(hi)} · ${e.text}'),
          for (final step in facts.treatment)
            _line(Icons.local_hospital_outlined, ttcPurple, step),
          if (facts.roundBand case final b?)
            _line(Icons.linear_scale_rounded, ttcTitleInk,
                ttcRoundBandLabel(b, facts.roundKind)),
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

  /// The due-date line for a fertile day of this cycle, or null.
  static String? _dueLine(DateTime day, TtcDayFacts facts) =>
      ttcCalendarDueLine(day, facts);
}

/// "Period expected", on the day the next period is expected (natural cycles).
const String kTtcCalendarPeriodExpected = 'Period expected';

/// "If this cycle works, your due date would be around 12 Jun 2027" for a
/// fertile day of the CURRENT cycle on her own timing, else null.
///
/// Public so `test/ttc_home_gap_test.dart` can hold the natural-only rule
/// without pumping the calendar.
String? ttcCalendarDueLine(DateTime day, TtcDayFacts facts) {
  final store = TtcStore.instance;
  if (!store.behaviour.showsFertilityWindow) return null;
  if (store.today.ownership != TimingOwnership.parentveda) return null;
  final f = facts.fertility;
  if (f == null || f == FertilityLevel.low) return null;
  final last = CycleStore.instance.lastPeriodStart;
  if (last == null) return null;
  final d = DateTime(day.year, day.month, day.day);
  if (d.isBefore(DateTime(last.year, last.month, last.day))) return null;
  return 'If this cycle works, your due date would be around '
      '${_DayPanel._fmt(ttcDueDateIfConceivedOn(d))}';
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

    // ⚠️ A ROUND'S NEXT CLINIC DATE FIRST (2026-09-26, §3c, B5). While a
    // round is open and has a date today or ahead, "Coming up" names that
    // date, not only the blood test, and names the blood test by its DATE:
    // the old card counted down to it ("in 9 days"), against the hero's rule
    // that a test is never counted down. While the round is only planned,
    // her own cycle's next period follows it. See [_RoundUpcoming].
    final round = TtcTreatmentStore.instance.cycle;
    if (!round.isEmpty && !round.isClosed) {
      final nowD = DateTime.now();
      final todayD = DateTime(nowD.year, nowD.month, nowD.day);
      final next = ttcRoundNextAfter(
          round, todayD.subtract(const Duration(days: 1)));
      if (next != null) {
        return _RoundUpcoming(
          round: round,
          next: next,
          today: todayD,
          planned: !ttcTreatmentActive(round, todayD),
          t: t,
        );
      }
    }

    // On a medicated cycle the countdown is to the BLOOD TEST, not a period.
    // Progesterone support usually delays the period, so counting to it
    // produces a "you are late" that means nothing and reads as hope - which is
    // the cruellest possible way for this card to be wrong.
    //
    // 2026-09-26: reached now only with nothing ahead in the round (a legacy
    // blob, or a test already passed); the test is named by its date.
    if (today.behaviour.countsToBeta) {
      final beta = TtcTreatmentStore.instance.cycle.betaTest;
      if (beta == null) return const SizedBox();
      // From midnight, like every other count on the stage (2026-09-26).
      // Kept for revert: `.difference(DateTime.now())`, a day short most of
      // the day.
      final now = DateTime.now();
      final days = DateTime(beta.year, beta.month, beta.day)
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
      // A test already behind her has nothing to come up (2026-09-26).
      if (days < 0) return const SizedBox();
      return TtcCard(
        color: ttcPanel,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ttcEyebrow(t.calendarUpcoming, color: ttcPurple),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.biotech_outlined, size: 15, color: ttcPurple),
            const SizedBox(width: 10),
            Expanded(child: Text(t.betaWaitTitle, style: ttcBody(13.5))),
            // Kept for revert: Text(t.betaWaitDays(days), ...). A test is
            // named by its date, never counted down to.
            Text(ttcRoundDate(beta),
                style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w800)),
          ]),
          const SizedBox(height: 9),
          Text(t.betaWaitNote, style: ttcBody(11.5, h: 1.5)),
        ]),
      );
    }

    // ⚠️ THE RESOLVER'S DUE DATE, COUNTED FROM MIDNIGHT (2026-09-26,
    // consistency pass). This counted from `DateTime.now()`, which carries
    // the time of day, so `inDays` dropped a day before midnight: "in 3 days"
    // here under a hero saying "in 4 days", and "Any day now" the day before
    // the hero's "tomorrow". And it counted on a history the engine will not
    // estimate from. Kept for revert:
    //   final last = CycleStore.instance.lastPeriodStart;
    //   if (last == null || today.cycleDay == null) return const SizedBox();
    //   final nextPeriod = last.add(Duration(days: today.cycleLength));
    //   final daysAway = nextPeriod.difference(DateTime.now()).inDays;
    final ctx = ttcDayContext(DateTime.now());
    final nextPeriod = ctx.periodDueOn;
    if (nextPeriod == null || today.cycleDay == null) return const SizedBox();
    final daysAway = nextPeriod.difference(ctx.today).inDays;

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

/// "Coming up" while a round is open with a date today or ahead: the next
/// clinic date, the blood test by its date when it is not the next one, and,
/// while the round is only planned, her own next period too.
class _RoundUpcoming extends StatelessWidget {
  const _RoundUpcoming({
    required this.round,
    required this.next,
    required this.today,
    required this.planned,
    required this.t,
  });

  final TtcTreatmentCycle round;
  final (TtcTreatmentStep?, DateTime) next;
  final DateTime today;
  final bool planned;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final kind = round.kind;
    final (step, on) = next;
    final test = ttcRoundBloodTest(round);
    final testAhead = test != null &&
        !DateTime(test.year, test.month, test.day).isBefore(today) &&
        step != TtcTreatmentStep.betaTest &&
        step != TtcTreatmentStep.repeatBeta;
    final ownDue = planned ? ttcDayContext(today).periodDueOn : null;

    Widget row(IconData icon, Color c, String label, String when,
            {Key? key}) =>
        Padding(
          key: key,
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(children: [
            Icon(icon, size: 15, color: c),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: ttcBody(13.5))),
            const SizedBox(width: 8),
            Flexible(
              child: Text(when,
                  textAlign: TextAlign.right,
                  style:
                      ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w800)),
            ),
          ]),
        );

    return TtcCard(
      key: const ValueKey('ttc_calendar_round_upcoming'),
      color: ttcPanel,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ttcEyebrow(t.calendarUpcoming, color: ttcPurple),
        const SizedBox(height: 10),
        row(
          Icons.local_hospital_outlined,
          ttcTitleInk,
          ttcCalendarDateLabel(step, kind),
          ttcCalendarWhen(step, on, today),
          key: const ValueKey('ttc_calendar_next_clinic_date'),
        ),
        if (testAhead)
          row(Icons.biotech_outlined, ttcTitleInk,
              ttcStepLabel(TtcTreatmentStep.betaTest, kind), ttcRoundDate(test)),
        if (ownDue != null && ownDue.isAfter(today))
          row(Icons.circle_outlined, ttcCoral, t.calendarNextPeriod,
              'in ${ownDue.difference(today).inDays} days'),
        const SizedBox(height: 2),
        Text(planned ? kTtcCalendarRoundPlannedNote : kTtcCalendarRoundNote,
            style: ttcBody(11.5, h: 1.5)),
      ]),
    );
  }
}

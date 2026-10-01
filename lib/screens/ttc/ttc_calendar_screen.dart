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
// Kept for revert (2026-09-28, the user: no journal in trying to conceive).
// import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_trackers_data.dart';
import '../../ttc/ttc_treatment_round.dart';
import '../../ttc/ttc_treatment_store.dart';
import '../../theme/pv_fonts.dart';
import 'ttc_common.dart';
import 'ttc_cycle_companion.dart'
    show showTtcPeriodDateActions, showTtcPeriodLogSheet, ttcShortDate;
import 'ttc_cycle_palette.dart';
import 'ttc_appointments_screen.dart'
    show TtcApptEntry, openTtcAppointment;
import 'ttc_symptom_log_screen.dart' show TtcSymptomLogScreen;
// `logTtcPeriod` was the day card's period button until 2026-09-27; kept for
// revert: import 'ttc_today_screen.dart' show logTtcPeriod;
import 'ttc_round_strings.dart';
import 'ttc_strings.dart';
import 'ttc_timeline_screen.dart';
import 'ttc_treatment_screen.dart' show openTtcTreatment;

class TtcCalendarScreen extends StatefulWidget {
  const TtcCalendarScreen({super.key});

  @override
  State<TtcCalendarScreen> createState() => _TtcCalendarScreenState();
}

// ⚠️ ONE PALETTE AND HAIRLINE CARDS (2026-09-27, night). Every colour on this
// calendar now comes from `ttc_cycle_palette.dart` (rose = bleeding, violet =
// fertile days, ink = today, selected and logged), and every card is a
// `TtcCycleCard` (a hairline) in place of the V1 `TtcCard` shadow. Kept for
// revert: TtcCard( at the six sites; the old colours are noted at each one.
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
        // Kept for revert (2026-09-28): TtcJournalStore.instance,
        TtcAppointmentsStore.instance,
        TtcTreatmentStore.instance,
        FamilyTimeline.instance,
        TtcLang.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        return TtcPage(
          tab: 3,
          // ⚠️ A PAGE OF TODAY, NOT A TAB (2026-09-27): it opens from the
          // home's header, so it has a back arrow and a plain title, and a
          // "Today" chip that brings the month and the selection back. Kept
          // for revert: header: const TtcHeader(), then
          // ttcSectionTitle(t.calendarTitle, eyebrow: t.tabCalendar).
          header: _CalendarTop(
            onToday: () => setState(() {
              final n = DateTime.now();
              _month = DateTime(n.year, n.month);
              _selected = DateTime(n.year, n.month, n.day);
            }),
          ),
          children: [
            // What this calendar is showing her, first (tools pass,
            // 2026-09-27). See [_CalendarIntro].
            _CalendarIntro(
              hasEstimate: const TtcChapterEngine()
                      .estimatedOvulationDay(TtcStore.instance.state()) !=
                  null,
            ),
            const SizedBox(height: 18),
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
              TtcCycleCard(
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
            // A quiet link (2026-09-27): a full card for the family timeline
            // at the foot of a calendar read as a feature of the calendar.
            // Kept for revert: the TtcCard with the timeline icon and arrow.
            InkWell(
              onTap: () => openTtcTimeline(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(children: [
                  Text(t.familyTimeline,
                      style: ttcBody(13, color: ttcInk, w: FontWeight.w700)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: ttcMuted),
                ]),
              ),
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
    // Kept for revert (2026-09-28): required this.journalEntries,
    required this.timelineEvents,
    required this.appointments,
    this.treatment = const [],
    this.lookingBack = false,
    this.isBleedDay = false,
    this.roundBand,
    this.roundKind,
  });

  final bool isPeriodStart;

  /// A logged bleeding day after the first (2026-09-27, launch walk): the
  /// legend's "Period" promised the days, and only day one was marked while
  /// the Companion said "19 Sep to 23 Sep". Drawn lighter than day one.
  final bool isBleedDay;

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
  // Kept for revert (2026-09-28, the user: no journal in trying to conceive):
  // the day's journal entries. The store is commented out.
  // final List<TtcJournalEntry> journalEntries;
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
      // Kept for revert (2026-09-28): journalEntries.isNotEmpty ||
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
  // ⚠️ THE TRIGGER CARRIES ITS TIME (tools pass, 2026-09-27): it is the one
  // clinic date where the hour matters, and the calendar showed only its
  // name. Same "Trigger injection · 10:15pm" shape the round screens use.
  // Kept for revert: if (_sameDay(r[step], d)) '$prefix${name(step, r.kind)}',
  List<String> of(TtcTreatmentCycle r, {String prefix = ''}) => [
        for (final step in TtcTreatmentStep.values)
          if (_sameDay(r[step], d))
            step.needsTime
                ? '$prefix${name(step, r.kind)} · ${ttcRoundTime(r[step]!)}'
                : '$prefix${name(step, r.kind)}',
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

  // The bleeding days she logged for the period that began on or before [d]:
  // a known count, or "still on" through today.
  var isBleed = false;
  if (!isStart) {
    DateTime? began;
    for (final p in cycle.periodStarts) {
      if (!p.isAfter(d)) began = p;
    }
    if (began != null) {
      final into = d.difference(began).inDays;
      final bleed = cycle.bleedDaysFor(began);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (bleed == kBleedStillOn) {
        isBleed = began == cycle.lastPeriodStart && !d.isAfter(today) && into < 10;
      } else if (bleed != null) {
        isBleed = into < bleed;
      }
    }
  }

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

  // Kept for revert (2026-09-28, journal out of TTC): the day card listed the
  // journal's entries for the day. The journal left the stage, so its words
  // no longer surface here; they stay in the store.
  //   final journal = TtcJournalStore.instance.entries
  //       .where((e) =>
  //           e.date.year == d.year &&
  //           e.date.month == d.month &&
  //           e.date.day == d.day)
  //       .toList();
  // Kept for revert (2026-09-28): final journal = <TtcJournalEntry>[];

  final timeline = FamilyTimeline.instance.events
      .where((e) =>
          e.date.year == d.year &&
          e.date.month == d.month &&
          e.date.day == d.day)
      .toList();

  return TtcDayFacts(
    isPeriodStart: isStart,
    isBleedDay: isBleed,
    fertility: fertility,
    isOvulation: isOvulation,
    isExpectedPeriod: isExpected,
    loggedTrackers: logged,
    // Kept for revert (2026-09-28): journalEntries: journal,
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

    // ⚠️ NO CARD ROUND THE MONTH (2026-09-27): a grid boxed inside a
    // shadowed card inside a page was the dated look. The month sits on the
    // page, its name large and left, the arrows as two round buttons (Flo,
    // Fitbit). Kept for revert: TtcCard(child: Column([Row(chevron, centred
    // 15.5 title, chevron), SizedBox(14), ...])).
    Widget arrow(IconData icon, int delta, String label) => Semantics(
          button: true,
          label: label,
          child: InkWell(
            onTap: () => onMonth(delta),
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ttcBorder),
              ),
              child: Icon(icon, size: 20, color: ttcInk),
            ),
          ),
        );
    return Column(children: [
        Row(children: [
          Expanded(
            child: Text('${_monthNames[month.month - 1]} ${month.year}',
                style: pvFraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: ttcTitleInk)),
          ),
          arrow(Icons.chevron_left_rounded, -1, 'Previous month'),
          const SizedBox(width: 8),
          arrow(Icons.chevron_right_rounded, 1, 'Next month'),
        ]),
        const SizedBox(height: 18),
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
                    child: TtcFertileBand.shows(
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
                            : const SizedBox(height: _kCellHeight),
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
                        return const SizedBox(height: _kCellHeight);
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
      ]);
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
        // The arrow is about the fertile run, so it is violet (2026-09-27).
        // Kept for revert: color: ttcCoral.
        const Icon(Icons.east_rounded,
            size: 14, color: TtcCycleColours.fertile),
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

  /// Whether the band is DRAWN on [d] (2026-09-30): a fertile day that is
  /// not also a bleeding day. Period wins an overlap (rule 4 of the day
  /// resolver), and the band drawn under the pink circles read as one mess
  /// (the user: "the purple border… the days overlapping, going away from
  /// each other"). Kept for revert: `isFertile` alone.
  static bool shows(DateTime? d) {
    if (!isFertile(d)) return false;
    final f = ttcFactsFor(d!);
    return !(f.isPeriodStart || f.isBleedDay);
  }

  @override
  Widget build(BuildContext context) {
    final openLeft = shows(before) && !firstInRow;
    final openRight = shows(after) && !lastInRow;
    const r = Radius.circular(999);

    // ⚠️ THE BAND IS THE DAY CIRCLE'S HEIGHT, ON THE DAY CIRCLE'S LINE
    // (2026-09-30). It was 34 tall and centred in the 46 cell while the
    // circles are 30 and sit 2 from its top, so the band rode 6 points lower
    // than the numbers it shaded and was wider than the pink circles over it.
    // Kept for revert: `Center(child: Container(height: 34, ...))`.
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: _kBandTop),
      child: Container(
        height: _kBandHeight,
        decoration: BoxDecoration(
          // Deliberately a shade you can actually see. The old per-day tint at
          // "medium" was indistinguishable from white.
          // The one violet ramp, the Fertile window's own (2026-09-27): the
          // capsule was pink, the ring green and the window violet for the
          // same six days. Kept for revert:
          //   color: ttcFertilityTint(ttcFactsFor(date!).fertility!),
          color:
              TtcCycleColours.fertileLevel(ttcFactsFor(date!).fertility!),
          borderRadius: BorderRadius.only(
            topLeft: openLeft ? Radius.zero : r,
            bottomLeft: openLeft ? Radius.zero : r,
            topRight: openRight ? Radius.zero : r,
            bottomRight: openRight ? Radius.zero : r,
          ),
        ),
      ),
      ),
    );
  }
}

/// The band's line, from the day circle (30 tall, 2 from the cell's top).
const double _kBandTop = 2;
const double _kBandHeight = 30;

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

  /// The two tints: warm greys from the cycle palette, never a cycle colour
  /// (2026-09-27). Kept for revert: medicine 0xFFE3E8F4 (a blue) and
  /// waitingForTest 0xFFEDE8F5 (a lavender that read as fertile).
  static Color tintFor(TtcRoundBand b) => TtcCycleColours.clinicBand(b);

  @override
  Widget build(BuildContext context) {
    final mine = bandOf(date);
    if (mine == null) return const SizedBox(height: _kCellHeight);
    final openLeft = bandOf(before) == mine && !firstInRow;
    final openRight = bandOf(after) == mine && !lastInRow;
    const r = Radius.circular(999);
    // Same line as the fertile band (2026-09-30).
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: _kBandTop),
      child: Container(
        height: _kBandHeight,
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
        // 42 until 2026-09-27: four points taller so the expected period can
        // carry the word "Due" under its outline (tools pass). Kept for
        // revert: height: 42, and a 5pt dot row.
        height: _kCellHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              // ⚠️ FROM THE ONE PALETTE (2026-09-27). Every bleeding day is
              // the full rose (day two onwards was half-strength and read as
              // faded); the selected day and today are INK, the base UI's
              // pill colour, because violet now means fertile days only; a
              // selected period day keeps its rose and gains an ink ring.
              // Kept for revert: ttcCoral start, ttcCoral at 0.5 for bleed
              // days, ttcPurple for selected and today's outline, ttcCoral
              // for the ovulation numerals.
              decoration: BoxDecoration(
                color: facts.isPeriodStart || facts.isBleedDay
                    ? TtcCycleColours.period
                    : isSelected
                        ? TtcCycleColours.today
                        : Colors.transparent,
                shape: BoxShape.circle,
                // The expected period is an OUTLINE, never a solid marker - it
                // is a projection, not a fact about her body.
                border: facts.isExpectedPeriod
                    ? Border.all(color: TtcCycleColours.period, width: 1.6)
                    : isSelected && (facts.isPeriodStart || facts.isBleedDay)
                        ? Border.all(color: TtcCycleColours.today, width: 2)
                        : isToday && !isSelected
                            ? Border.all(
                                color: TtcCycleColours.today, width: 1.6)
                            : null,
              ),
              child: Text('${date.day}',
                  style: ttcBody(12.5,
                      color: (facts.isPeriodStart ||
                              facts.isBleedDay ||
                              isSelected)
                          ? Colors.white
                          // Ovulation is marked by WEIGHT on the deepest part
                          // of the band, not by a separate dot. The dot was
                          // ttcBrown - the only brown in a pink and purple
                          // palette, which read as a bug on the single most
                          // important day of the cycle.
                          : facts.isOvulation
                              ? TtcCycleColours.ovulation
                              : ttcInk,
                      w: (isToday || facts.isOvulation)
                          ? FontWeight.w900
                          : FontWeight.w600)),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 10,
              child: facts.isExpectedPeriod
                  // ⚠️ THE OUTLINE SAYS WHAT IT IS (tools pass, 2026-09-27).
                  // An outlined day alone was easy to miss and meant nothing
                  // until she found the key. The word is the key, on the day.
                  ? Text(kTtcCalendarDueMark,
                      key: const ValueKey('ttc_cal_due_mark'),
                      style: ttcBody(8.5,
                          color: TtcCycleColours.periodInk,
                          w: FontWeight.w800,
                          h: 1.1))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ⚠️ ONE DOT FOR "YOU LOGGED" (2026-09-27): a violet dot for
                  // a symptom and a grey one for a journal line, neither in
                  // the key. Both are "you logged something" now, in ink, and
                  // a clinic date is a hollow ink dot so the two never look
                  // alike. Kept for revert: _dot(ttcPurple) for trackers,
                  // _dot(ttcMuted) for journal, _dot(ttcTitleInk) for clinic.
                  // Kept for revert (2026-09-28, journal out of TTC):
                  //   || facts.journalEntries.isNotEmpty
                  if (facts.loggedTrackers.isNotEmpty)
                    _dot(TtcCycleColours.logged,
                        key: const ValueKey('ttc_cal_logged_dot')),
                  // A date her clinic gave her (2026-09-26, B5).
                  if (facts.isClinicDate)
                    _dot(TtcCycleColours.clinic,
                        hollow: true,
                        key: const ValueKey('ttc_cal_clinic_dot')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c, {Key? key, bool hollow = false}) => Container(
        key: key,
        width: hollow ? 5 : 4,
        height: hollow ? 5 : 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: hollow ? null : c,
          shape: BoxShape.circle,
          border: hollow ? Border.all(color: c, width: 1.2) : null,
        ),
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

  // ⚠️ A KEY, NOT A CARD (2026-09-27): "What the colours mean" was a
  // collapsible card of seven rows under the grid. The same marks now sit in
  // one wrapped line the eye can take in at once (Apple Health, Oura). The
  // rules for WHICH marks appear are unchanged. `open` and `onToggle` stay
  // for the callers; the key is always shown. Kept for revert: the TtcCard
  // with the title row, the chevron and `if (open)`.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 14, runSpacing: 4, children: [
        ...[
          const SizedBox.shrink(),
          // Every key from the one palette (2026-09-27). Kept for revert:
          // ttcCoral period / ovulation / next period, the pink
          // ttcFertilityTint(peak) for fertile days, ttcPurple for today and
          // logged, ttcTitleInk for a clinic date.
          _row(TtcCycleColours.period, t.calendarPeriod, filled: true),
          if (behaviour.showsFertilityWindow && hasEstimate) ...[
            _row(TtcCycleColours.fertileLevel(FertilityLevel.peak),
                t.calendarFertile,
                filled: true),
            // Ovulation is weight on the band, not a swatch - so the legend
            // says what to look for rather than showing a colour that no
            // longer exists.
            _row(TtcCycleColours.ovulation, t.calendarOvulation, bold: true),
          ],
          // "Today" was missing entirely, while being the boldest ring drawn.
          // The Today key is gone (2026-09-30, "very out of touch"): the ring
          // round today's number says it, and the key made a third row. Kept
          // for revert: _row(TtcCycleColours.today, t.calendarToday,
          // outline: true),
          _row(TtcCycleColours.logged, t.calendarLogged),
          if (behaviour.countsToPeriod)
            _row(TtcCycleColours.period, t.calendarNextPeriod, outline: true),
          if (hasRound) ...[
            _row(TtcCycleColours.clinic, kTtcCalendarClinicDate,
                outline: true),
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

  // Kept for revert: Padding(bottom: 10, Row(16px mark, 11, Expanded(label))).
  Widget _row(Color c, String label,
          {bool filled = false, bool outline = false, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
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
          const SizedBox(width: 7),
          // Flexible, so a long round label wraps inside the line instead of
          // pushing past the screen's edge at 360dp.
          Flexible(child: Text(label, style: ttcBody(12, color: ttcMuted))),
        ]),
      );
}

// ---- selected day -----------------------------------------------------------

// Unused since 2026-09-30 (milestones left the day card); kept for revert.
// ignore: unused_element
IconData _timelineIcon(TimelineKind kind) => switch (kind) {
      TimelineKind.milestone => Icons.flag_outlined,
      TimelineKind.medical => Icons.medical_services_outlined,
      TimelineKind.written => Icons.edit_outlined,
      TimelineKind.people => Icons.people_outline_rounded,
      TimelineKind.action => Icons.check_circle_outline_rounded,
    };

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

    // The day's own title, with its cycle day (Fitbit's "Today · cycle day 3
    // of 28"), and the two things she comes to a calendar to do at its foot
    // (Flo's "Edit period dates"). Kept for revert: the bare title
    // Text(isToday ? t.calendarToday : _fmt(day), style: ttcJakarta(16)).
    final cycleDay = ttcDayContext(day).cycleDay;
    final future = DateTime(day.year, day.month, day.day)
        .isAfter(DateTime(today.year, today.month, today.day));
    return TtcCycleCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Text(isToday ? t.calendarToday : _fmt(day),
                style: pvFraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ttcTitleInk)),
          ),
          if (cycleDay != null)
            Text('Cycle day $cycleDay',
                style: ttcBody(12.5, color: ttcMuted, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        if (!showSomething)
          Text(t.calendarNothing, style: ttcBody(13.5))
        else ...[
          // The day card's marks in the palette too (2026-09-27): rose for
          // bleeding, violet for fertile days, ink for everything else.
          // Kept for revert: ttcCoral, ttcBrown, ttcPurple as below.
          if (facts.isPeriodStart)
            _line(Icons.circle, TtcCycleColours.period, t.calendarPeriod),
          // A bleeding day after the first said nothing in the card.
          if (facts.isBleedDay && !facts.isPeriodStart)
            _line(Icons.circle, TtcCycleColours.period, kTtcCalendarBleedDay),
          if (facts.isExpectedPeriod)
            _line(Icons.circle_outlined, TtcCycleColours.period,
                kTtcCalendarPeriodExpected),
          // An earlier cycle's window says "looking back" and carries no
          // grade (2026-09-26); the current cycle's reads as before.
          if (facts.isOvulation)
            _line(
                Icons.egg_outlined,
                TtcCycleColours.ovulation,
                facts.lookingBack
                    ? t.calendarOvulationLookingBack
                    : t.calendarOvulation),
          if (facts.fertility != null &&
              facts.fertility != FertilityLevel.low)
            _line(
                Icons.wb_twilight_rounded,
                TtcCycleColours.fertile,
                facts.lookingBack
                    ? t.calendarFertileLookingBack
                    : '${t.calendarFertile} · ${facts.fertility!.label(hi)}'),
          if (dueLine != null)
            _line(Icons.child_friendly_outlined, ttcSoft, dueLine),
          // Kept for revert: ttcTrackerById(id)?.title(hi) ?? id.
          for (final id in facts.loggedTrackers)
            _line(Icons.check_circle_outline_rounded, TtcCycleColours.logged,
                ttcCalendarLoggedLine(id, hi)),
          // Kept for revert (2026-09-28, journal out of TTC):
          // for (final e in facts.journalEntries)
          //   _line(Icons.edit_outlined, ttcMuted,
          //       '${e.kind.label(hi)} · ${e.text}'),
          for (final step in facts.treatment)
            _line(Icons.local_hospital_outlined, TtcCycleColours.clinic, step),
          if (facts.roundBand case final b?)
            _line(Icons.linear_scale_rounded, ttcTitleInk,
                ttcRoundBandLabel(b, facts.roundKind)),
          // ⚠️ AN APPOINTMENT OPENS ITS OWN PAGE (2026-09-27). It was a line
          // with nowhere to go; the Appointments tool now has a page for one
          // visit (edit, remove, remind), and this is the same entry it
          // builds from her own list. Kept for revert: the line without
          // `onTap`.
          for (final a in facts.appointments)
            _line(
              Icons.event_note_outlined,
              ttcTitleInk,
              a.withWhom.isEmpty ? a.title : '${a.title} · ${a.withWhom}',
              key: ValueKey('ttc_cal_appt_${a.id}'),
              onTap: () => openTtcAppointment(
                context,
                TtcApptEntry(
                  own: a,
                  title: a.title,
                  startsUtc: a.startsUtc,
                  detail: a.withWhom,
                  fromParentVeda: false,
                ),
              ),
            ),
          // ⚠️ ONE ICON PER KIND, NOT ONE SPARKLE FOR ALL (2026-09-30, the
          // user: "icons of Ask Veda, all of them are same, makes no sense").
          // The sparkle is Ask Veda's own mark. Kept for revert:
          // _line(Icons.auto_awesome_rounded, ttcSoft, e.title(hi)).
          // ⚠️ NO APP MILESTONES ON A CALENDAR DAY (2026-09-30, the user, the
          // second time: "calendar is still not fixed"). "You decided to
          // start", "Started your supplements" and "Started keeping your
          // health records" are the app's own milestones, dated the day it
          // noticed them, so they piled under Today as three identical ticks
          // that say nothing about the day. The day card holds what happened
          // in HER cycle that day: a period, what she logged, a visit, a
          // clinic step. The milestones live on the Family Timeline, one tap
          // below. Kept for revert:
          // for (final e in facts.timelineEvents)
          //   _line(_timelineIcon(e.kind), ttcSoft, e.title(hi)),
        ],
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: _action(
              label: 'Log symptoms',
              icon: Icons.checklist_rounded,
              ink: true,
              enabled: !future,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'ttc/symptom_log'),
                  builder: (_) => TtcSymptomLogScreen(day: day))),
            ),
          ),
          const SizedBox(width: 10),
          // ⚠️ THE BUTTON DOES WHAT IT SAYS (tools pass, 2026-09-27). It read
          // "Edit period dates" and opened a bare date picker that could only
          // ADD a period, whatever day was tapped. Now: on a period's first
          // day it changes that period (the Companion's own sheet, which moves
          // the date and keeps what hangs off it); on any other past day it
          // logs a period starting that day, with the day already picked.
          // Kept for revert:
          //   label: 'Edit period dates', onTap: () => logTtcPeriod(context),
          // ⚠️ A PERIOD DAY OPENS THAT PERIOD, AND IT CAN BE REMOVED HERE
          // (2026-09-27). On the first day the button went straight to the
          // date sheet, so a wrong period could be moved but never removed
          // from the calendar; on day two to five it offered "Log a period",
          // which would have logged a second period inside the first. Now
          // any bleeding day opens the Companion's Change / Remove sheet for
          // the period it belongs to (Flo's "Edit period dates"). Kept for
          // revert: facts.isPeriodStart ? showTtcPeriodLogSheet(context,
          // correcting: day) : showTtcPeriodLogSheet(context, initial: day).
          Expanded(
            child: Builder(builder: (context) {
              final owner = ttcCalendarPeriodOwning(day);
              return _action(
                label: owner != null
                    ? kTtcCalendarChangePeriod
                    : kTtcCalendarLogPeriod,
                icon: Icons.water_drop_outlined,
                ink: false,
                enabled: !future,
                onTap: () => owner != null
                    ? showTtcPeriodDateActions(context, owner)
                    : showTtcPeriodLogSheet(context, initial: day),
              );
            }),
          ),
        ]),
      ]),
    );
  }

  Widget _action({
    required String label,
    required IconData icon,
    required bool ink,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final body = Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ink ? ttcTitleInk : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: ink ? null : Border.all(color: ttcBorder, width: 1.2),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: ink ? Colors.white : ttcInk),
        const SizedBox(width: 7),
        Flexible(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ttcBody(13,
                  color: ink ? Colors.white : ttcInk, w: FontWeight.w700)),
        ),
      ]),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: enabled ? body : Opacity(opacity: 0.42, child: body),
      ),
    );
  }

  /// One fact on the day. With [onTap] it opens what it names, and says so
  /// with a chevron and a 44pt row.
  Widget _line(IconData icon, Color color, String text,
      {Key? key, VoidCallback? onTap}) {
    final row = Padding(
      padding: EdgeInsets.only(bottom: onTap == null ? 11 : 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ttcBody(13,
                  color: ttcInk,
                  h: 1.45,
                  w: onTap == null ? FontWeight.w400 : FontWeight.w700)),
        ),
        if (onTap != null)
          const Icon(Icons.chevron_right_rounded, size: 18, color: ttcMuted),
      ]),
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Align(alignment: Alignment.centerLeft, child: row),
        ),
      ),
    );
  }

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

/// A logged bleeding day after the first, in the day card (2026-09-27).
const String kTtcCalendarBleedDay = 'Period day';

/// The period whose bleeding days include [day]: its start, or null.
///
/// ⚠️ READS THE SAME FACTS THE GRID DRAWS (`isPeriodStart`, `isBleedDay`), so
/// the button under a rose day always opens the period that made it rose.
DateTime? ttcCalendarPeriodOwning(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  final facts = ttcFactsFor(d);
  if (facts.isPeriodStart) return d;
  if (!facts.isBleedDay) return null;
  DateTime? began;
  for (final p in CycleStore.instance.periodStarts) {
    final pd = DateTime(p.year, p.month, p.day);
    if (!pd.isAfter(d) && (began == null || pd.isAfter(began))) began = pd;
  }
  return began;
}

/// A day cell's height: the date circle, and a line for dots or "Due".
const double _kCellHeight = 46;

/// The word under the outlined day in the grid (tools pass, 2026-09-27).
const String kTtcCalendarDueMark = 'Due';

// ---- the line above the grid (tools pass, 2026-09-27) ---------------------
//
// ⚠️ SAY WHAT THIS IS, FIRST. The calendar opened on a grid and a key and
// left her to work out what the marks meant, and with no period saved the grid
// was almost blank with no way to fill it (TTC-TOOLS-UX-NOTES, "Cycle
// calendar"). One sentence for the state she is in, and on the empty one the
// action that fills it (Flo's "Log your periods", mobbin 52e7c65f).

/// No period saved yet.
const String kTtcCalendarIntroEmpty =
    'Add the day your last period started. Then we can mark your period and '
    'your fertile days here.';
const String kTtcCalendarAddPeriod = 'Add my last period';

/// A natural cycle with fertile days to show.
const String kTtcCalendarIntro =
    'Filled circles are your period. The shaded band is your fertile days, '
    "when you're most likely to get pregnant. Tap a day to see it.";

/// A natural cycle where the engine will not estimate.
const String kTtcCalendarIntroNoEstimate =
    "Filled circles are your period. We can't mark your fertile days yet. "
    "They'll show here once your dates are enough to go on.";

/// A clinic is timing this cycle.
const String kTtcCalendarIntroClinic =
    "Your clinic is timing this cycle. Their dates replace our estimate, so we "
    "don't mark fertile days or your next period here.";
const String kTtcCalendarAddClinicDates = "Add your clinic's dates";

/// The day card's period button, by what it will do.
const String kTtcCalendarLogPeriod = 'Log a period';
// 'Change this period' was cut to "Change this pe…" beside Log symptoms
// (2026-09-30, the user's phone). Kept for revert: 'Change this period'.
const String kTtcCalendarChangePeriod = 'Edit period';

/// "You logged symptoms" in the day card. The tracker's own title named the
/// retired five-point screen ("Symptom Companion"), not what she did.
String ttcCalendarLoggedLine(String trackerId, bool hi) => switch (trackerId) {
      'symptoms' => 'You logged how the day went',
      'weight' => 'You logged your weight',
      _ => ttcTrackerById(trackerId)?.title(hi) ?? trackerId,
    };

/// What the calendar says first, above the grid (tools pass, 2026-09-27).
class _CalendarIntro extends StatelessWidget {
  const _CalendarIntro({required this.hasEstimate});

  final bool hasEstimate;

  @override
  Widget build(BuildContext context) {
    final empty = CycleStore.instance.periodStarts.isEmpty;
    final clinic = !TtcStore.instance.behaviour.showsFertilityWindow;
    final hasRound = ttcCalendarRound() != null;
    final text = empty
        ? kTtcCalendarIntroEmpty
        : clinic
            ? kTtcCalendarIntroClinic
            : hasEstimate
                ? kTtcCalendarIntro
                : kTtcCalendarIntroNoEstimate;

    // One action, only where it fills the gap the sentence names.
    final (String, IconData, VoidCallback)? action = empty
        ? (
            kTtcCalendarAddPeriod,
            Icons.add_rounded,
            () => showTtcPeriodLogSheet(context),
          )
        : clinic && !hasRound
            ? (
                kTtcCalendarAddClinicDates,
                Icons.event_note_outlined,
                () => openTtcTreatment(context),
              )
            : null;

    return Column(
      key: const ValueKey('ttc_calendar_intro'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: ttcBody(14, color: ttcInk, h: 1.5)),
        if (action != null) ...[
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: action.$1,
            excludeSemantics: true,
            child: InkWell(
              key: const ValueKey('ttc_calendar_intro_action'),
              onTap: action.$3,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: ttcTitleInk,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(action.$2, size: 17, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(action.$1,
                      style: ttcBody(13.5,
                          color: Colors.white, w: FontWeight.w700)),
                ]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

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
      return TtcCycleCard(
        // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ttcEyebrow(t.calendarUpcoming, color: ttcSoft),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.biotech_outlined, size: 15, color: ttcTitleInk),
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
    // ⚠️ THE FERTILE DAYS BELONG HERE TOO (2026-09-30, the user: the hero said
    // "your fertile days open tomorrow" and this card, one tap away, only
    // knew the next period). Only her own cycle's window, still ahead or
    // open now, from the same resolver the hero reads.
    final opens = ctx.windowOpensOn, closes = ctx.windowClosesOn;
    Widget? fertileRow;
    if (opens != null && closes != null && !closes.isBefore(ctx.today)) {
      final toOpen = opens.difference(ctx.today).inDays;
      final left = closes.difference(ctx.today).inDays + 1;
      fertileRow = Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          const Icon(Icons.circle,
              size: 15, color: TtcCycleColours.ovulation),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: t.calendarFertile, style: ttcBody(13.5)),
              TextSpan(
                  text: '  ${ttcShortDate(opens)} to ${ttcShortDate(closes)}',
                  style: ttcBody(12, color: ttcMuted)),
            ])),
          ),
          Text(
            toOpen > 0
                ? (toOpen == 1 ? 'tomorrow' : 'in $toOpen days')
                : (left <= 1 ? 'last day' : 'open, $left days left'),
            style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w800),
          ),
        ]),
      );
    }

    return TtcCycleCard(
      // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ttcEyebrow(t.calendarUpcoming, color: ttcSoft),
        const SizedBox(height: 10),
        ?fertileRow,
        Row(children: [
          const Icon(Icons.circle_outlined,
              size: 15, color: TtcCycleColours.period),
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

    return TtcCycleCard(
      key: const ValueKey('ttc_calendar_round_upcoming'),
      // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ttcEyebrow(t.calendarUpcoming, color: ttcSoft),
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
          row(Icons.circle_outlined, TtcCycleColours.period,
              t.calendarNextPeriod,
              'in ${ownDue.difference(today).inDays} days'),
        const SizedBox(height: 2),
        Text(planned ? kTtcCalendarRoundPlannedNote : kTtcCalendarRoundNote,
            style: ttcBody(11.5, h: 1.5)),
      ]),
    );
  }
}

/// The calendar's top: back, the title, and a way back to today
/// (2026-09-27). A page of Today, so no wordmark header.
class _CalendarTop extends StatelessWidget {
  const _CalendarTop({required this.onToday});
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) => Row(children: [
        Semantics(
          button: true,
          label: 'Back',
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.arrow_back_rounded, size: 22, color: ttcInk),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text('Calendar',
              style: pvFraunces(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: ttcTitleInk)),
        ),
        Semantics(
          button: true,
          label: 'Go to today',
          child: InkWell(
            onTap: onToday,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ttcBorder, width: 1.2),
              ),
              child: Text('Today',
                  style: ttcBody(13, color: ttcInk, w: FontWeight.w700)),
            ),
          ),
        ),
      ]);
}

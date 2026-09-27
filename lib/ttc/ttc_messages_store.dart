// =============================================================================
//  TtcMessagesStore - the app speaks first
// -----------------------------------------------------------------------------
//  The gap analysis ("Behind: Guided help", P1): Flo talks to her first; we sent
//  nothing except two IVF trigger reminders, and onboarding promised "Your
//  window this cycle, the morning it opens." with nothing behind it. This store
//  is what is behind it now.
//
//  FIVE MESSAGES, EACH SENT ONCE, AT ITS MOMENT:
//
//    windowOpens  the morning her fertile days start (natural cycles only)
//    periodCame   the evening of the day she logs a period
//    lateByOne    the day after her period was due, if none is logged
//    cycleReport  the morning after a new cycle starts
//    tryingLong   once, after 6 or 12 months of trying
//    treatment    while a clinic runs a round (2026-09-26, B6, below)
//
//  Each lands in the in-app Messages list AND, when she has allowed it, as a
//  phone notification. Each can be switched off on its own.
//
//  House pattern: singleton `ChangeNotifier`, private constructor, lazy load,
//  `shared_preferences`, a storage failure is never a crash.
//
//  ---------------------------------------------------------------------------
//  ⚠️ COMPUTED, NOT QUEUED. AND WHY THAT MATTERS
//  ---------------------------------------------------------------------------
//
//  The tempting design is an event queue: "she logged a period, so push a
//  message". That breaks the moment a date is corrected. Move a period by one
//  day and a queue has already sent the wrong window; delete it and the queue
//  still holds a "your period came" for a period that never happened.
//
//  So [refresh] recomputes the whole set from the stores every time anything
//  changes, the way `TtcStore.today` is recomputed rather than stored:
//
//    * a message whose moment has PASSED is delivered, and frozen. It is never
//      recomputed, re-sent or removed. That is what "sent once" means.
//    * a message whose moment is still AHEAD is pending, and pending messages
//      are thrown away and rebuilt on every refresh, together with their phone
//      notifications. Correcting a date therefore corrects the message.
//
//  Ids carry the fact they are about (`window:2026-09-20`), so a changed date
//  is a different message rather than a silently edited one.
//
//  The cost of recomputing: a refresh is not free, and it runs on every store
//  change. It is coalesced into one per microtask, and it is a handful of date
//  comparisons plus at most five notification calls. The gain is that there is
//  no state here that can drift from the cycle it describes.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE CLINICAL RULES, AND WHERE EACH IS HELD
//  ---------------------------------------------------------------------------
//
//  * windowOpens needs `TtcPathwayBehaviour.sendsOvulationReminders`, a flag
//    written for exactly this notification before it existed, AND a non-null
//    `ttcFertileWindowNow()`, which is null on every clinic cycle. Two gates,
//    because the engine taught us once that one gate gets moved and the other
//    does not (see the note in `ttc_fertile_window.dart`).
//  * lateByOne needs `countsToPeriod`, via `ttcTestAdvice`, and a real history:
//    two completed cycles that do not vary much. On a clinic cycle luteal
//    support delays the period, and "late" there means nothing.
//  * tryingLong never states a chance. It says what a first check involves.
//  * Nothing is sent once a positive test is recorded, or outside the TTC
//    stage.
//  * periodCame and cycleReport are OFF while a clinic owns the cycle
//    (2026-09-26, B6): on a treatment cycle a period after the test is
//    expected and "if you were hoping this month" is the wrong frame, and a
//    stimulated cycle's length means nothing. The first period after a round
//    gets a treatment-shaped message instead, and its report is not sent.
//
//  ---------------------------------------------------------------------------
//  ⚠️ TREATMENT MESSAGES (2026-09-26, docs/TTC-TREATMENT-FLOW.md §3d, B6)
//  ---------------------------------------------------------------------------
//
//  The same computed-not-queued rule, one switch ("Treatment reminders"),
//  built by [ttcTreatmentMessages] from her round's dates:
//
//    the evening before the baseline scan, each scan, egg collection or the
//    IUI, the transfer and the blood test; the evening before the first
//    injection, pointing to the Medication schedule for the daily reminder
//    (decision 4: no injection reminder of our own); trigger day, in the app
//    only, with the 34 to 36 hour note (the two phone alerts stay with the
//    treatment store, 918001 and 918002); the day after collection, rest and
//    the signs to call about; five days after the transfer (or IUI), the
//    middle of the wait; two days after the test with no result recorded, in
//    the app only; two days after "Not this time", in the app only, into
//    `ttc_read_tx_negative_after_treatment`.
//
//  Ids carry the date they are about (`treat:collection:2026-10-12`), so
//  moving a date moves the message. Several can be pending at once, so the
//  kind owns a block of phone ids, 918201 upwards ([kTtcTreatmentPhoneSlots]),
//  handed out soonest first on every refresh. Every date is her clinic's; a
//  message only reminds, explains or helps her prepare, never adds a step.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE STARTUP ORDER IS LOAD-BEARING
//  ---------------------------------------------------------------------------
//
//  `ReminderStore.init` calls `NotificationService.syncAll`, which calls the
//  plugin's `cancelAll()`. Anything scheduled before that runs is wiped. So
//  [init] must run AFTER `ReminderStore.instance.init()` has finished; see
//  `main.dart`. (The two trigger-shot reminders in `ttc_treatment_store.dart`
//  are wiped by the same call and are not re-armed on launch; that is a
//  separate defect, reported rather than fixed here.)
// =============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/life_stage_store.dart';
import '../services/notification_service.dart';
import 'cycle_store.dart';
import 'ttc_chapter.dart';
import 'ttc_fertile_window.dart';
import 'ttc_fertility_help_rules.dart';
import 'ttc_fertility_help_store.dart';
import 'ttc_period_due.dart';
import 'ttc_store.dart';
import 'ttc_treatment_store.dart';

/// The five messages. The NAME is persisted, so renaming one strands every
/// message already delivered under it.
enum TtcMessageKind {
  windowOpens,
  periodCame,
  lateByOne,
  cycleReport,
  tryingLong,

  /// While a clinic runs a round (2026-09-26, B6). One switch for all of
  /// them, "Treatment reminders".
  treatment,
}

/// Phone ids the treatment kind may use at once, from its base id (918201)
/// upwards. More pending than this and the furthest wait for a later refresh.
const int kTtcTreatmentPhoneSlots = 20;

extension TtcMessageKindInfo on TtcMessageKind {
  /// One fixed OS notification id per kind. There is never more than one
  /// pending message of a kind, so one id each is enough, and cancelling by
  /// id cannot touch the reminder, medication or trigger id spaces.
  int get notificationId => switch (this) {
        TtcMessageKind.windowOpens => 918101,
        TtcMessageKind.periodCame => 918102,
        TtcMessageKind.lateByOne => 918103,
        TtcMessageKind.cycleReport => 918104,
        TtcMessageKind.tryingLong => 918105,
        // The first of a block: see [kTtcTreatmentPhoneSlots].
        TtcMessageKind.treatment => 918201,
      };

  /// Every phone id this kind may hold.
  List<int> get phoneIds => this == TtcMessageKind.treatment
      ? [for (var i = 0; i < kTtcTreatmentPhoneSlots; i++) notificationId + i]
      : [notificationId];

  /// Where a tap goes, as surface ids for `ttc_surface_router.dart`, best
  /// first. The screen opens the first one that resolves.
  ///
  /// ⚠️ A LIST, BECAUSE ONE OF THEM MAY NOT EXIST YET. The Hard days read is
  /// being written in parallel with this store. Until it is registered in
  /// `ttc_reads_data.dart`, `ttc_read/ttc_read_period_came` resolves to null
  /// and the Mind & body door opens instead. When it lands, the read wins with
  /// no change here.
  List<String> get destinations => switch (this) {
        TtcMessageKind.windowOpens => const ['ttc_window'],
        TtcMessageKind.periodCame => const [
            'ttc_read/ttc_read_period_came',
            'ttc_door/ttc_mind_body',
          ],
        TtcMessageKind.lateByOne => const ['ttc_chat/should_test'],
        // The chat walks the cycle in plain words and ends on the full report.
        TtcMessageKind.cycleReport => const [
            'ttc_chat/cycle_report',
            'ttc_cycle_report',
          ],
        TtcMessageKind.tryingLong => const ['ttc_fertility_help'],
        // Each treatment message carries its own (`TtcMessage.to`); this is
        // the fallback, the round itself.
        TtcMessageKind.treatment => const ['ttc_treatment'],
      };

  /// The name on its on/off switch.
  String get label => switch (this) {
        TtcMessageKind.windowOpens => 'Your fertile window',
        TtcMessageKind.periodCame => 'When your period comes',
        TtcMessageKind.lateByOne => 'If your period is late',
        TtcMessageKind.cycleReport => 'Your cycle report',
        TtcMessageKind.tryingLong => 'A first check',
        TtcMessageKind.treatment => 'Treatment reminders',
      };

  /// When it arrives, said plainly. Used under the switch and in the empty
  /// state, which is this feature's advertisement.
  String get when => switch (this) {
        TtcMessageKind.windowOpens =>
          'The morning your fertile days start. Only when your own cycle sets '
              'the timing, not a clinic.',
        TtcMessageKind.periodCame =>
          'The evening you log a period. A few kind words and what it means.',
        TtcMessageKind.lateByOne =>
          "The day after your period was due, if you haven't logged it. With "
              'help on whether to test.',
        TtcMessageKind.cycleReport =>
          'The morning after a new cycle starts. A look back at the last one.',
        TtcMessageKind.tryingLong =>
          'Once, after six or twelve months of trying. What a first check with '
              'a doctor involves.',
        TtcMessageKind.treatment =>
          'While your clinic runs a round. The evening before each scan, '
              'procedure and blood test, and a few kind words in the wait.',
      };
}

/// One message, pending or delivered.
@immutable
class TtcMessage {
  const TtcMessage({
    required this.id,
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
    this.read = false,
    this.to,
    this.quiet = false,
  });

  /// `<kind>:<the fact it is about>`. Stable, persisted, never shown.
  final String id;
  final TtcMessageKind kind;

  /// Its moment. At or before now = delivered.
  final DateTime at;

  final String title;
  final String body;
  final bool read;

  /// Where a tap goes, best first, when this message has its own place
  /// (2026-09-26, the treatment messages). Null: the kind's `destinations`.
  final List<String>? to;

  /// In the app only, never to the phone (§3d: "test day + 2" and the
  /// follow-up after "Not this time").
  final bool quiet;

  /// The surfaces a tap tries, best first.
  List<String> get destinations => to ?? kind.destinations;

  bool deliveredBy(DateTime now) => !at.isAfter(now);

  TtcMessage copyWith({DateTime? at, bool? read}) => TtcMessage(
        id: id,
        kind: kind,
        at: at ?? this.at,
        title: title,
        body: body,
        read: read ?? this.read,
        to: to,
        quiet: quiet,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'at': at.toIso8601String(),
        'title': title,
        'body': body,
        'read': read,
        if (to != null) 'to': to,
        if (quiet) 'quiet': true,
      };

  static TtcMessage? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final kind =
        TtcMessageKind.values.where((k) => k.name == raw['kind']).firstOrNull;
    final at = DateTime.tryParse(raw['at']?.toString() ?? '');
    final id = raw['id']?.toString();
    if (kind == null || at == null || id == null) return null;
    return TtcMessage(
      id: id,
      kind: kind,
      at: at,
      title: raw['title']?.toString() ?? '',
      body: raw['body']?.toString() ?? '',
      read: raw['read'] == true,
      to: raw['to'] is List
          ? [for (final t in raw['to'] as List) t.toString()]
          : null,
      quiet: raw['quiet'] == true,
    );
  }
}

/// Everything the five rules read, gathered in one place.
///
/// ⚠️ A PLAIN VALUE SO THE RULES CAN BE TESTED WITHOUT THE STORES. The rules
/// are the clinically sensitive part; the gathering is plumbing.
@immutable
class TtcMessageFacts {
  const TtcMessageFacts({
    this.inTtcStage = true,
    this.pregnancyConfirmed = false,
    this.ownership = TimingOwnership.parentveda,
    this.sendsOvulationReminders = true,
    this.periodStarts = const [],
    this.cycleLengths = const [],
    this.usualLength,
    this.irregular = false,
    this.historyLooksOff = false,
    this.windowOpens,
    this.windowCloses,
    this.journeyStart,
    this.ageBand,
    this.cyclesVaryOrPcos = false,
    this.alreadyInCare = false,
    this.round,
    this.closedRound,
    this.lastCycleWasRound = false,
  });

  /// Read from the live stores.
  factory TtcMessageFacts.fromStores() {
    final store = TtcStore.instance;
    final cycle = CycleStore.instance;
    final today = store.today;
    const engine = TtcChapterEngine();
    final state = store.state();

    // ⚠️ THE WINDOW COMES FROM THE ONE PROJECTION, NEVER FROM ARITHMETIC HERE.
    // Null on a clinic cycle and whenever the engine refuses. Only the window
    // of the cycle she is in: a projected one is a guess built on a guess.
    final w = ttcFertileWindowNow();
    final current = w != null && w.cyclesAhead == 0;

    final help = TtcFertilityHelpStore.instance;
    final ctx = help.context;
    final pathway = help.answerFor('pathway');

    // The round (2026-09-26, B6). The cycle that ended at her latest period
    // was a round's when a clinic owned it: the same evidence rule every
    // surface reads (`TtcStore.ownershipOfCycle`).
    final treatment = TtcTreatmentStore.instance;
    final starts = [...cycle.periodStarts.map(_day)]..sort();
    final lastCycleWasRound = starts.length >= 2 &&
        store.ownershipOfCycle(starts[starts.length - 2],
                nextStart: starts.last) !=
            TimingOwnership.parentveda;

    return TtcMessageFacts(
      inTtcStage: LifeStageStore.instance.isTrying,
      pregnancyConfirmed: store.pregnancyConfirmed,
      ownership: store.ownership,
      sendsOvulationReminders: today.behaviour.sendsOvulationReminders,
      periodStarts: cycle.periodStarts,
      cycleLengths: cycle.cycleLengths,
      usualLength:
          cycle.cycleLengths.isEmpty ? null : engine.cycleLengthFor(state),
      irregular: engine.isIrregular(state),
      historyLooksOff: engine.hasUnreliableHistory(state),
      windowOpens: current ? w.opensOn : null,
      windowCloses: current ? w.closesOn : null,
      journeyStart: store.journeyStart,
      ageBand: ctx.ageBand,
      cyclesVaryOrPcos: ctx.cyclesIrregular || ctx.pcosPatternFound,
      alreadyInCare: pathway == 'current' || pathway == 'done',
      round: treatment.cycle.isEmpty ? null : treatment.cycle,
      closedRound: treatment.lastClosed,
      lastCycleWasRound: lastCycleWasRound,
    );
  }

  final bool inTtcStage;
  final bool pregnancyConfirmed;
  final TimingOwnership ownership;
  final bool sendsOvulationReminders;
  final List<DateTime> periodStarts;
  final List<int> cycleLengths;
  final int? usualLength;
  final bool irregular;
  final bool historyLooksOff;
  final DateTime? windowOpens;
  final DateTime? windowCloses;
  final DateTime? journeyStart;
  final FertilityAgeBand? ageBand;
  final bool cyclesVaryOrPcos;
  final bool alreadyInCare;

  /// Her open treatment round, or null (2026-09-26, B6).
  final TtcTreatmentCycle? round;

  /// The round she closed last, or null.
  final TtcTreatmentCycle? closedRound;

  /// True when the cycle that ended at her latest logged period was run by
  /// a clinic: that period is the first after a round.
  final bool lastCycleWasRound;

  /// Six months when she is 35 or over, or her cycles vary a lot or her PCOS
  /// check found the pattern. Twelve otherwise, including when we do not know
  /// her age: we only shorten the wait on something she has told us.
  int get monthsBeforeCheck =>
      (ageBand?.refersAtPresentation ?? false) || cyclesVaryOrPcos ? 6 : 12;
}

/// Whether her history is steady enough to call a period late at all: a usual
/// length, two completed cycles, not irregular, and no gap that looks like a
/// missed log. With less, "late" is a guess dressed as a fact.
bool ttcLateHistoryReliable(TtcMessageFacts f) =>
    f.usualLength != null &&
    f.cycleLengths.length >= 2 &&
    !f.irregular &&
    !f.historyLooksOff;

/// The test advice for [now] when it can be trusted, else null.
///
/// ⚠️ ONE ANSWER, READ BY TWO PLACES: the "late by a day" message below and
/// the home's "Time to test" line (`ttc_home_situation.dart`). Null on a
/// clinic cycle (luteal support delays the period, so "late" means nothing
/// there), with no period logged, and whenever [ttcLateHistoryReliable] says
/// the history cannot carry it. Any branch otherwise, so a caller decides for
/// itself how late is worth saying.
TtcTestAdvice? ttcReliableLateAdvice(TtcMessageFacts f, DateTime now) {
  if (!ttcLateHistoryReliable(f)) return null;
  final starts = [...f.periodStarts.map(_day)]..sort();
  if (starts.isEmpty) return null;
  final advice = ttcTestAdvice(
    ownership: f.ownership,
    today: _day(now),
    lastStart: starts.last,
    cycleLength: f.usualLength,
  );
  return advice.branch == TtcTestBranch.clinic ? null : advice;
}

/// Whether she has been trying long enough for a first check, by the one rule
/// the "trying for a while" message uses: [TtcMessageFacts.monthsBeforeCheck]
/// months from the day she started, on her own cycle (not a clinic path), and
/// not once she has told us she is already in someone's care. The home's
/// "it may be time for a check" card reads this too, so the two agree.
bool ttcTryingLongReached(TtcMessageFacts f, DateTime now,
    {bool ignoreCare = false}) {
  final began = f.journeyStart;
  if (began == null || f.pregnancyConfirmed) return false;
  if (!ignoreCare &&
      (f.alreadyInCare || f.ownership != TimingOwnership.parentveda)) {
    return false;
  }
  final at =
      DateTime(began.year, began.month + f.monthsBeforeCheck, began.day);
  return !_day(now).isBefore(at);
}

/// The messages the facts support at [now], each at its natural moment.
///
/// Moments may be in the past: the store decides what that means (deliver
/// now, quietly, or not at all if it was already sent). Every rule here also
/// decides how late is still worth saying, and leaves out anything past that.
List<TtcMessage> ttcMessageCandidates(TtcMessageFacts f, DateTime now) {
  if (!f.inTtcStage || f.pregnancyConfirmed) return const [];

  final today = _day(now);
  final out = <TtcMessage>[];
  final starts = [...f.periodStarts.map(_day)]..sort();
  final last = starts.isEmpty ? null : starts.last;

  // ---- 1. the window opens -------------------------------------------------
  final opens = f.windowOpens;
  final closes = f.windowCloses;
  if (f.sendsOvulationReminders &&
      f.ownership == TimingOwnership.parentveda &&
      opens != null &&
      closes != null &&
      !_day(opens).isBefore(today)) {
    out.add(TtcMessage(
      id: 'window:${_key(opens)}',
      kind: TtcMessageKind.windowOpens,
      at: _at(opens, 8),
      title: 'Your fertile window opens today',
      body: 'Going by your dates, your fertile days run from today to '
          "${ttcDayDate(closes)}. Sex every day or two in this time is plenty. "
          "It's an estimate, so give or take a day.",
    ));
  }

  // ---- 2. her period came --------------------------------------------------
  //
  // Only a NEW cycle after one we already knew about. The first period she
  // ever logs is usually typed in at onboarding, and "if you were hoping this
  // month" is the wrong thing to say to someone who has just arrived.
  //
  // ⚠️ NOT WHILE A CLINIC OWNS THE CYCLE (2026-09-26, §3d). And the first
  // period after a round gets words for that, not "if you were hoping this
  // month", with a way to the IVF door's "Between rounds".
  final clinicNow = f.ownership != TimingOwnership.parentveda;
  if (last != null &&
      starts.length >= 2 &&
      !clinicNow &&
      f.lastCycleWasRound &&
      !last.isBefore(today.subtract(const Duration(days: 1)))) {
    out.add(TtcMessage(
      id: 'period:${_key(last)}',
      kind: TtcMessageKind.periodCame,
      at: _at(today, 19),
      title: 'Your period came',
      body: 'Your first period since your round. Your home follows your own '
          'cycle again. Nothing about the next step has to be decided today.',
      to: const ['ttc_door/ttc_infertility', 'ttc_treatment'],
    ));
  } else if (last != null &&
      starts.length >= 2 &&
      !clinicNow &&
      !last.isBefore(today.subtract(const Duration(days: 1)))) {
    out.add(TtcMessage(
      id: 'period:${_key(last)}',
      kind: TtcMessageKind.periodCame,
      // The evening, not the moment she logs it. She is in the app when she
      // logs it; a banner over her own tap would be noise. A few hours later
      // it arrives as someone checking in.
      at: _at(today, 19),
      title: 'Your period came',
      body: "If you were hoping this month, that's hard. Here's what it does "
          "and doesn't mean, whenever you're ready.",
    ));
  }

  // ---- 3. a day past when it was due ---------------------------------------
  //
  // Needs a history worth leaning on: two completed cycles that agree with
  // each other. With less, "late" is a guess dressed as a fact.
  //
  // ⚠️ THE SAME CALL THE HOME MAKES. `ttcReliableLateAdvice` is shared with
  // the home's "Time to test" line (2026-09-26), so the message and the hero
  // can never name two different due dates for one period.
  final advice = ttcReliableLateAdvice(f, today);
  if (last != null && advice != null) {
    final due = advice.due;
    if (due != null) {
      final dayAfter = due.add(const Duration(days: 1));
      // Worth saying for a week. After that a missed log is more likely than
      // a late period, and the message would read as pressure.
      if (!today.isAfter(dayAfter.add(const Duration(days: 6)))) {
        out.add(TtcMessage(
          id: 'late:${_key(last)}',
          kind: TtcMessageKind.lateByOne,
          at: _at(dayAfter, 9),
          title: 'A test can give you an answer now',
          body: 'Your period was due around ${ttcDayDate(due)} and it '
              "isn't logged yet. If you'd like to know, a home test is "
              "reliable from now. We'll walk you through it.",
        ));
      }
    }
  }

  // ---- 4. the cycle report -------------------------------------------------
  // Not for a cycle a clinic ran, and not while one runs this cycle
  // (2026-09-26, §3d): a stimulated cycle's length means nothing.
  if (last != null &&
      starts.length >= 2 &&
      !clinicNow &&
      !f.lastCycleWasRound) {
    final prev = starts[starts.length - 2];
    final ran = last.difference(prev).inDays;
    final morning = last.add(const Duration(days: 1));
    if (!today.isAfter(last.add(const Duration(days: 7)))) {
      out.add(TtcMessage(
        id: 'report:${_key(prev)}',
        kind: TtcMessageKind.cycleReport,
        at: _at(morning, 9),
        title: 'Your cycle report is ready',
        body: ran >= CycleStore.minPlausibleCycleDays &&
                ran <= CycleStore.maxPlausibleCycleDays
            ? 'Your last cycle was $ran days long. Have a look back at it in '
                'plain words, whenever it suits you.'
            : 'Have a look back at your last cycle in plain words, whenever '
                'it suits you.',
      ));
    }
  }

  // ---- 5. trying for a while -----------------------------------------------
  //
  // Not on a clinic path and not once she has told us she is in someone's
  // care already: a first check she has had is not news.
  final began = f.journeyStart;
  if (began != null &&
      !f.alreadyInCare &&
      f.ownership == TimingOwnership.parentveda) {
    final months = f.monthsBeforeCheck;
    final at = DateTime(began.year, began.month + months, began.day, 10);
    out.add(TtcMessage(
      id: 'trying:$months',
      kind: TtcMessageKind.tryingLong,
      at: at,
      title: 'A first check, if you want one',
      body: months == 12
          ? "You've been trying for about a year. This is when doctors "
              'usually suggest a simple first check for you both. It '
              "doesn't mean anything is wrong. Here's what it involves."
          : "You've been trying for about six months. "
              '${(f.ageBand?.refersAtPresentation ?? false) ? 'At 35 and over' : 'When cycles are irregular'}'
              ', doctors usually suggest a first check around now, for you '
              "both. It doesn't mean anything is wrong. Here's what it "
              'involves.',
    ));
  }

  // ---- 6. a treatment round (2026-09-26, B6) -------------------------------
  out.addAll(ttcTreatmentMessages(f.round, f.closedRound, now));

  return out;
}

/// The treatment messages her round's dates support at [now] (§3d). Pure, so
/// a test can move a date and watch the message move.
///
/// Each "the evening before" message is worth saying until the day itself
/// arrives, and never after: a "Scan tomorrow" on the morning of the scan
/// would be wrong. A day-of message is worth saying that day only.
List<TtcMessage> ttcTreatmentMessages(
    TtcTreatmentCycle? open, TtcTreatmentCycle? closed, DateTime now) {
  final today = _day(now);
  final out = <TtcMessage>[];

  void add(String what, DateTime about, DateTime at, String title,
          String body, List<String> to, {bool quiet = false}) =>
      out.add(TtcMessage(
        id: 'treat:$what:${_key(about)}',
        kind: TtcMessageKind.treatment,
        at: at,
        title: title,
        body: body,
        to: to,
        quiet: quiet,
      ));

  void eveBefore(String what, DateTime? on, String title, String body,
      List<String> to) {
    if (on == null) return;
    final d = _day(on);
    if (!today.isBefore(d)) return;
    add(what, d, _at(d.subtract(const Duration(days: 1)), 19), title, body,
        to);
  }

  void onDay(String what, DateTime? about, DateTime? day, int hour,
      String title, String body, List<String> to, {bool quiet = false}) {
    if (about == null || day == null) return;
    final d = _day(day);
    if (today.isAfter(d)) return;
    add(what, _day(about), _at(d, hour), title, body, to, quiet: quiet);
  }

  if (open != null && !open.isEmpty && !open.isClosed) {
    final kind = open.kind;
    DateTime? at(TtcTreatmentStep s) => open[s];
    final iuiRound = kind == TtcRoundKind.iui;
    final tablets = kind == TtcRoundKind.ovulationInduction;
    final testWord = iuiRound || tablets ? 'pregnancy test' : 'blood test';

    eveBefore(
        'baseline',
        at(TtcTreatmentStep.baselineScan),
        'Your first scan is tomorrow',
        "It's usually quick. Your clinic will tell you if they want a blood "
            'test too.',
        const ['ttc_read/ttc_read_tx_baseline_scan', 'ttc_treatment']);

    final what = tablets ? 'tablet' : (iuiRound ? 'medicine' : 'injection');
    eveBefore(
        'stims',
        at(TtcTreatmentStep.stimStart),
        tablets
            ? 'Your tablets start tomorrow'
            : (iuiRound
                ? 'Your medicines start tomorrow'
                : 'Your injections start tomorrow'),
        'Add your $what time to your medication schedule, and '
            "we'll remind you each day.",
        const ['ttc_medication', 'ttc_treatment']);

    for (final scan in open.scans) {
      eveBefore(
          'scan',
          scan,
          'Scan tomorrow',
          'Most clinics see you early, so plan the morning if you can.',
          const ['ttc_treatment']);
    }

    // Trigger day, in the app only: the two phone alerts are the treatment
    // store's (918001, 918002), so this never rings a third time.
    final trig = at(TtcTreatmentStep.trigger);
    if (trig != null) {
      final h = trig.hour % 12 == 0 ? 12 : trig.hour % 12;
      final time =
          '$h:${trig.minute.toString().padLeft(2, '0')}${trig.hour < 12 ? 'am' : 'pm'}';
      final ivf = !iuiRound &&
          !tablets &&
          kind != TtcRoundKind.fetNatural;
      onDay(
          'trigger',
          trig,
          trig,
          7,
          trig.hour >= 17
              ? 'Trigger shot tonight at $time'
              : 'Trigger shot today at $time',
          ivf
              ? 'Your clinic set this time. Egg collection is timed from it, '
                  'about 34 to 36 hours later. If anything is unclear, call '
                  'them now.'
              : iuiRound
                  ? 'Your clinic set this time, and your IUI is timed from '
                      'it. If anything is unclear, call them now.'
                  : 'Your clinic set this time, and what comes next is timed '
                      'from it. If anything is unclear, call them now.',
          const ['ttc_read/ttc_read_tx_trigger_shot', 'ttc_treatment'],
          quiet: true);
    }

    final opu = iuiRound ? null : at(TtcTreatmentStep.retrieval);
    eveBefore(
        'collection',
        opu,
        'Egg collection tomorrow',
        'No food or drink after the time your clinic gave you. Bring someone '
            'to take you home.',
        const ['ttc_read/ttc_read_ivf_retrieval', 'ttc_treatment']);
    if (opu != null) {
      onDay(
          'rest',
          opu,
          _day(opu).add(const Duration(days: 1)),
          9,
          'Rest today',
          'Some cramping and bloating is common. If you feel very bloated, '
              'pass much less urine or find it hard to breathe, call your '
              'clinic.',
          const ['ttc_read/ttc_read_ivf_ohss', 'ttc_treatment']);
    }

    final iuiDay = at(TtcTreatmentStep.iui) ??
        (iuiRound ? at(TtcTreatmentStep.retrieval) : null);
    eveBefore(
        'iui',
        iuiDay,
        'IUI tomorrow',
        'Ask your clinic what time his sample is needed, and when to arrive.',
        const ['ttc_read/ttc_read_tx_iui_day', 'ttc_treatment']);

    final xfer = at(TtcTreatmentStep.transfer);
    eveBefore(
        'transfer',
        xfer,
        'Transfer tomorrow',
        'Take your medicines as usual. Check whether your clinic wants a full '
            'bladder.',
        const ['ttc_read/ttc_read_tx_transfer_day', 'ttc_treatment']);

    final waitFrom = xfer ?? iuiDay;
    if (waitFrom != null) {
      onDay(
          'middle',
          waitFrom,
          _day(waitFrom).add(const Duration(days: 5)),
          10,
          'The middle of the wait',
          "This is often the hardest stretch. Here's what helps, whenever you "
              'want it.',
          const [
            'ttc_read/ttc_read_tx_wait_after_treatment',
            'ttc_treatment',
          ]);
    }

    eveBefore(
        'beta',
        at(TtcTreatmentStep.betaTest),
        'Your $testWord is tomorrow',
        'Plan something gentle for after, whatever the day brings.',
        const ['ttc_read/ttc_read_tx_beta_test', 'ttc_treatment']);
    eveBefore(
        'repeat',
        at(TtcTreatmentStep.repeatBeta),
        'Your repeat blood test is tomorrow',
        'Plan something gentle for after, whatever the day brings.',
        const ['ttc_read/ttc_read_tx_beta_test', 'ttc_treatment']);

    // Two days after the latest test with no result recorded: in the app
    // only, and only while the round is still open.
    final test = at(TtcTreatmentStep.repeatBeta) ?? at(TtcTreatmentStep.betaTest);
    if (test != null) {
      final ask = _day(test).add(const Duration(days: 2));
      if (!today.isAfter(ask.add(const Duration(days: 7)))) {
        add(
            'ask_result',
            test,
            _at(ask, 9),
            "When you're ready",
            "Tell us how the test went, and we'll show you what comes next.",
            const ['ttc_treatment/result', 'ttc_treatment'],
            quiet: true);
      }
    }
  }

  // After "Not this time": two days later, in the app only.
  final closedOn = closed?.closedOn;
  if (closed != null &&
      closedOn != null &&
      closed.outcome == TtcRoundOutcome.negative) {
    final day = _day(closedOn).add(const Duration(days: 2));
    if (!today.isAfter(day.add(const Duration(days: 7)))) {
      add(
          'after_negative',
          closedOn,
          _at(day, 10),
          "When you're ready",
          'What happens after a negative test: the next few weeks, and the '
              'questions to take to your review.',
          const [
            'ttc_read/ttc_read_tx_negative_after_treatment',
            'ttc_door/ttc_infertility',
          ],
          quiet: true);
    }
  }
  return out;
}

/// Where the phone notifications go. An interface so tests can see what was
/// scheduled without a platform plugin.
abstract class TtcMessagePhone {
  Future<void> schedule(
      {required int id,
      required String title,
      required String body,
      required DateTime when});
  Future<void> cancel(int id);
}

class _OsPhone implements TtcMessagePhone {
  const _OsPhone();

  @override
  Future<void> schedule(
          {required int id,
          required String title,
          required String body,
          required DateTime when}) =>
      NotificationService.instance
          .scheduleOneOff(id: id, title: title, body: body, when: when);

  @override
  Future<void> cancel(int id) => NotificationService.instance.cancel(id);
}

class TtcMessagesStore extends ChangeNotifier with WidgetsBindingObserver {
  TtcMessagesStore._();
  static final TtcMessagesStore instance = TtcMessagesStore._();

  static const _kMessages = 'ttc_messages_v1';
  static const _kOff = 'ttc_messages_off';
  static const _kPhone = 'ttc_messages_phone';

  /// Delivered messages kept. Older ones fall off the end.
  static const int _keep = 60;

  final List<TtcMessage> _all = [];
  final Set<TtcMessageKind> _off = {};
  bool _phoneOn = true;
  bool _loaded = false;
  bool _listening = false;

  TtcMessagePhone _phone = const _OsPhone();

  @visibleForTesting
  set phone(TtcMessagePhone p) => _phone = p;

  bool get isLoaded => _loaded;

  /// Delivered messages, newest first. What the Messages screen lists.
  List<TtcMessage> delivered({DateTime? now}) {
    final t = now ?? DateTime.now();
    return _all.where((m) => m.deliveredBy(t)).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  /// Messages still ahead, soonest first. For tests and the screen's "coming
  /// up" line; never shown as a promise of a date.
  List<TtcMessage> pending({DateTime? now}) {
    final t = now ?? DateTime.now();
    return _all.where((m) => !m.deliveredBy(t)).toList()
      ..sort((a, b) => a.at.compareTo(b.at));
  }

  int get unreadCount => delivered().where((m) => !m.read).length;

  bool isOn(TtcMessageKind kind) => !_off.contains(kind);
  bool get phoneOn => _phoneOn;

  // ---- lifecycle ------------------------------------------------------------

  /// Load, start listening, and schedule. Call once at startup, AFTER
  /// `ReminderStore.instance.init()` has finished (see the header).
  Future<void> init() async {
    await _load();
    if (!_listening) {
      _listening = true;
      CycleStore.instance.addListener(_changed);
      TtcStore.instance.addListener(_changed);
      LifeStageStore.instance.addListener(_changed);
      TtcFertilityHelpStore.instance.addListener(_changed);
      // The round's dates drive the treatment messages (2026-09-26, B6).
      TtcTreatmentStore.instance.addListener(_changed);
      // Lazy-loaded store: without this her age answer is not known here.
      TtcFertilityHelpStore.instance.load().catchError((_) {});
      try {
        WidgetsBinding.instance.addObserver(this);
      } catch (_) {/* no binding in a pure test */}
    }
    await refresh();
  }

  /// A new day may have made a pending message due, or a window newly
  /// reachable. Coming back to the app is when that is noticed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _changed();
  }

  bool _queued = false;
  void _changed() {
    if (_queued) return;
    _queued = true;
    scheduleMicrotask(() {
      _queued = false;
      refresh();
    });
  }

  // ---- THE hook -------------------------------------------------------------

  Future<void>? _running;
  bool _again = false;

  /// Recompute every message and (re)schedule the phone notifications.
  ///
  /// Safe to call as often as you like: it is idempotent, and concurrent calls
  /// collapse into one more run after the current one.
  Future<void> refresh({DateTime? now}) async {
    if (_running != null) {
      _again = true;
      return _running;
    }
    final run = _refresh(now);
    _running = run;
    try {
      await run;
    } finally {
      _running = null;
    }
    if (_again) {
      _again = false;
      await refresh(now: now);
    }
  }

  Future<void> _refresh(DateTime? fixedNow) async {
    if (!_loaded) await _load();
    // Not before the stores know what they hold. An early refresh would see an
    // empty cycle, cancel everything, and reschedule a moment later.
    if (!CycleStore.instance.isLoaded ||
        !TtcStore.instance.isLoaded ||
        !LifeStageStore.instance.isLoaded ||
        !TtcTreatmentStore.instance.isLoaded) {
      return;
    }
    final now = fixedNow ?? DateTime.now();
    final facts = TtcMessageFacts.fromStores();
    final changed = apply(ttcMessageCandidates(facts, now), now);

    // ---- the phone ----------------------------------------------------------
    // Cancel every id and re-arm what is pending. A handful of calls, and no
    // chance of a stale notification surviving a corrected date. Treatment
    // messages take the kind's block of ids soonest first; a quiet message
    // never goes to the phone (2026-09-26, B6).
    for (final k in TtcMessageKind.values) {
      for (final id in k.phoneIds) {
        await _phone.cancel(id);
      }
    }
    if (_phoneOn) {
      var slot = 0;
      for (final m in pending(now: now)) {
        if (m.quiet) continue;
        int id = m.kind.notificationId;
        if (m.kind == TtcMessageKind.treatment) {
          if (slot >= kTtcTreatmentPhoneSlots) continue;
          id += slot++;
        }
        await _phone.schedule(
            id: id, title: m.title, body: m.body, when: m.at);
      }
    }
    if (changed) {
      await _persist();
      notifyListeners();
    }
  }

  /// Folds [candidates] into the list. Returns true when anything changed.
  ///
  /// Public for tests: it is the whole "sent once" rule and it is pure.
  @visibleForTesting
  bool apply(List<TtcMessage> candidates, DateTime now) {
    final before = jsonEncode([for (final m in _all) m.toJson()]);

    final delivered = _all.where((m) => m.deliveredBy(now)).toList();
    final pendingById = {
      for (final m in _all.where((m) => !m.deliveredBy(now))) m.id: m,
    };
    final sentIds = delivered.map((m) => m.id).toSet();
    final sentKinds = delivered.map((m) => m.kind).toSet();

    final next = <TtcMessage>[...delivered];
    for (final c in candidates) {
      if (!isOn(c.kind)) continue;
      if (sentIds.contains(c.id)) continue;
      // The first-check message is once in a lifetime, whichever threshold
      // sent it. A later age answer must not send it a second time.
      if (c.kind == TtcMessageKind.tryingLong &&
          sentKinds.contains(TtcMessageKind.tryingLong)) {
        continue;
      }
      final existing = pendingById[c.id];
      if (existing != null) {
        // Keep the moment it was first given. Otherwise the evening message
        // for a period logged yesterday would slide to this evening, and the
        // phone would ring twice for one period.
        next.add(TtcMessage(
            id: c.id, kind: c.kind, at: existing.at, title: c.title,
            body: c.body, to: c.to, quiet: c.quiet));
      } else if (c.deliveredBy(now)) {
        // Its moment has passed but it is still worth saying (the rule
        // decided that). Delivered now, in the app only: no phone
        // notification for something she can already see.
        next.add(c.copyWith(at: now));
      } else {
        next.add(c);
      }
    }

    next.sort((a, b) => b.at.compareTo(a.at));
    // Trim delivered history only; never a pending message.
    final keepDelivered = next.where((m) => m.deliveredBy(now)).take(_keep);
    final keepPending = next.where((m) => !m.deliveredBy(now));
    _all
      ..clear()
      ..addAll(keepPending)
      ..addAll(keepDelivered);

    return jsonEncode([for (final m in _all) m.toJson()]) != before;
  }

  // ---- her choices ----------------------------------------------------------

  void markRead(String id) {
    final i = _all.indexWhere((m) => m.id == id);
    if (i < 0 || _all[i].read) return;
    _all[i] = _all[i].copyWith(read: true);
    _persist();
    notifyListeners();
  }

  void markAllRead() {
    final now = DateTime.now();
    var any = false;
    for (var i = 0; i < _all.length; i++) {
      if (_all[i].deliveredBy(now) && !_all[i].read) {
        _all[i] = _all[i].copyWith(read: true);
        any = true;
      }
    }
    if (!any) return;
    _persist();
    notifyListeners();
  }

  /// Switching a kind off drops anything of it still pending, with its phone
  /// notification. What she already received stays in her list.
  Future<void> setOn(TtcMessageKind kind, bool on) async {
    if (isOn(kind) == on) return;
    on ? _off.remove(kind) : _off.add(kind);
    if (!on) {
      final now = DateTime.now();
      _all.removeWhere((m) => m.kind == kind && !m.deliveredBy(now));
    }
    await _persist();
    notifyListeners();
    await refresh();
  }

  /// Whether messages also go to the phone. The in-app list keeps working
  /// either way. Turning it on asks the OS, because the switch is the consent
  /// and the OS answer is its own.
  Future<void> setPhoneOn(bool on) async {
    if (_phoneOn == on) return;
    _phoneOn = on;
    await _persist();
    notifyListeners();
    if (on) {
      try {
        await NotificationService.instance.requestPermission();
      } catch (_) {/* the in-app list still works */}
    }
    await refresh();
  }

  @visibleForTesting
  void resetForTest() {
    _all.clear();
    _off.clear();
    _phoneOn = true;
    _loaded = true;
    notifyListeners();
  }

  // ---- persistence ----------------------------------------------------------

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_kMessages);
      if (raw != null) {
        final list = jsonDecode(raw);
        if (list is List) {
          _all
            ..clear()
            ..addAll(list.map(TtcMessage.fromJson).whereType<TtcMessage>());
        }
      }
      _off
        ..clear()
        ..addAll((p.getStringList(_kOff) ?? const <String>[])
            .map((n) =>
                TtcMessageKind.values.where((k) => k.name == n).firstOrNull)
            .whereType<TtcMessageKind>());
      _phoneOn = p.getBool(_kPhone) ?? true;
    } catch (_) {/* start empty; a storage failure is never a crash */}
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          _kMessages, jsonEncode([for (final m in _all) m.toJson()]));
      await p.setStringList(_kOff, [for (final k in _off) k.name]);
      await p.setBool(_kPhone, _phoneOn);
    } catch (_) {/* best-effort */}
  }
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _at(DateTime d, int hour) => DateTime(d.year, d.month, d.day, hour);

String _key(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

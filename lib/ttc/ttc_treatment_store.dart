// =============================================================================
//  TtcTreatmentStore - the dates her clinic gave her
// -----------------------------------------------------------------------------
//  The answer to a real problem: on IVF, IUI or ovulation induction, ParentVeda
//  cannot predict anything useful, because ovulation is triggered by an
//  injection at a time a clinic chose after watching follicles on a scan.
//
//  So we stopped competing with the clinic and started CARRYING what the clinic
//  said. These dates are facts on a printout in her bag, not estimates - which
//  makes them better than anything the calendar engine could ever have offered.
//
//  ---------------------------------------------------------------------------
//  "DERIVE, NEVER ASK" - and why this is allowed to ask
//
//  The product's rule is that a signal is either derived from data we already
//  hold or declared by her, never both, and that we only ask for what is
//  genuinely unknowable. A trigger-shot time is the purest example of
//  unknowable: no amount of cycle history can produce it, because a doctor
//  picked it. Same category as "do you have PCOS", which the personalisation
//  engine already asks.
//
//  ---------------------------------------------------------------------------
//  WHY THE TRIGGER CARRIES A TIME AND EVERYTHING ELSE DOES NOT
//
//  Clinics give a trigger instruction like "10:15pm exactly" and mean it -
//  retrieval is scheduled a fixed interval afterwards, so an hour's drift is
//  clinically significant. It is the one moment in this whole stage where the
//  app being precise actually matters, so it is the one field stored as a full
//  timestamp and the one that gets a notification.
//
//  ---------------------------------------------------------------------------
//  ⚠️ A ROUND, SINCE 2026-09-26 (docs/TTC-TREATMENT-FLOW.md, B1)
//
//  The five dates became a treatment ROUND: an app-generated id, a kind (IVF
//  fresh, freeze-all, frozen transfer medicated or natural, IUI, tablets with
//  scans, not sure), the optional steps real rounds have (pill cycle,
//  down-regulation, estrogen, baseline scan, monitoring scans, IUI apart from
//  egg collection, progesterone, repeat blood test, review appointment), how it
//  ended and when, and the rounds before it (`history`).
//
//  ⚠️ STILL ONE JSONB BLOB, NO MIGRATION. The `ttc_treatment` row keeps its
//  three columns (`user_id`, `cycle`, `updated_at`); everything new lives in
//  the blob it already had. An old five-step blob decodes exactly as before
//  (no kind = a "legacy" round, which keeps the old evidence rule in
//  `TtcStore.ownershipOfCycle`), and an older app reading a new blob skips the
//  step names it does not know rather than failing.
//
//  ⚠️ NOTHING CHANGES SILENTLY, AND NOTHING IS DELETED (the user's rule,
//  2026-09-26). Every change of mode is announced before or as it happens:
//  starting a round says from which date the home follows it; its first
//  treatment day shows a one-time "Your home now follows your round"; closing
//  says the own cycle returns with the next period; the day it does, one line
//  says so. Closing is confirmed first, moves the round to `history` (never
//  removes it), and can be undone for 7 days. A round is never closed on its
//  own: after 7 quiet days, or a return after 30 days away, the app ASKS
//  (`ttcTreatmentNeedsCheckIn`, `ttcTreatmentAskOnReturn`). The one-time flags
//  below are what make each announcement appear exactly once.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../services/remote/supabase_repo.dart';
import 'ttc_sync.dart';
import 'ttc_treatment_round.dart';

/// The milestones of one treatment cycle, in the order they happen.
///
/// ⚠️ THE NAMES ARE PERSISTED (the blob's `dates` keys). The first five are
/// the original shape and must never be renamed; the rest were added
/// 2026-09-26 and are all optional.
enum TtcTreatmentStep {
  stimStart,
  trigger,
  retrieval,
  transfer,
  betaTest,
  // ---- added 2026-09-26 (B1), all optional --------------------------------
  pillStart,
  downRegStart,
  estrogenStart,
  baselineScan,
  iui,
  progesteroneStart,
  repeatBeta,
  reviewAppointment,
}

/// The first five steps, the shape every older blob and test knows.
const List<TtcTreatmentStep> kTtcOriginalTreatmentSteps = [
  TtcTreatmentStep.stimStart,
  TtcTreatmentStep.trigger,
  TtcTreatmentStep.retrieval,
  TtcTreatmentStep.transfer,
  TtcTreatmentStep.betaTest,
];

extension TtcTreatmentStepCopy on TtcTreatmentStep {
  /// The step's generic name. A round names it for its own kind
  /// (`ttcStepLabel`); this stays for the calendar and the older screens.
  /// New steps are English only (CLAUDE.md, new work is English).
  String label(bool hi) {
    switch (this) {
      case TtcTreatmentStep.stimStart:
        return hi ? 'Stimulation shuru' : 'Stimulation starts';
      case TtcTreatmentStep.trigger:
        return hi ? 'Trigger injection' : 'Trigger injection';
      case TtcTreatmentStep.retrieval:
        return hi ? 'Egg retrieval / IUI' : 'Egg retrieval / IUI';
      case TtcTreatmentStep.transfer:
        return hi ? 'Transfer' : 'Transfer';
      case TtcTreatmentStep.betaTest:
        return hi ? 'Beta hCG blood test' : 'Beta hCG blood test';
      case TtcTreatmentStep.pillStart:
        return 'Pill cycle starts';
      case TtcTreatmentStep.downRegStart:
        return 'Down-regulation starts';
      case TtcTreatmentStep.estrogenStart:
        return 'Estrogen tablets start';
      case TtcTreatmentStep.baselineScan:
        return 'Baseline scan';
      case TtcTreatmentStep.iui:
        return 'IUI';
      case TtcTreatmentStep.progesteroneStart:
        return 'Progesterone starts';
      case TtcTreatmentStep.repeatBeta:
        return 'Repeat blood test';
      case TtcTreatmentStep.reviewAppointment:
        return 'Review appointment';
    }
  }

  /// The thing people actually forget. Short, practical, never clinical advice
  /// - each of these is something a clinic says out loud and nobody writes down.
  String note(bool hi) {
    switch (this) {
      case TtcTreatmentStep.stimStart:
        return hi
            ? 'Injections aksar roz ek hi samay par hoti hain. Pehla din note kar lein.'
            : 'Injections are usually at the same time each day. Write down which day is day one.';
      case TtcTreatmentStep.trigger:
        return hi
            ? 'Samay bilkul theek rakhein - retrieval iske baad ek tay ghante par hota hai.'
            : 'The time is exact. Your retrieval is booked a set number of hours after this.';
      case TtcTreatmentStep.retrieval:
        return hi
            ? 'Aam taur par sedation hoti hai. Aadhi raat se kuch na khaayein, aur koi saath aaye.'
            : "It's usually done under sedation. Don't eat anything after midnight, and bring someone with you.";
      case TtcTreatmentStep.transfer:
        return hi
            ? 'Kai clinics bharay hue bladder ke saath kehti hain. Unka nirdesh hi maanein.'
            : "Many clinics ask you to come with a full bladder. Follow your clinic's advice, not ours.";
      case TtcTreatmentStep.betaTest:
        return hi
            ? 'Yahi asli jawab hai. Ghar ka test isse pehle trigger ki wajah se galat aa sakta hai.'
            : 'This test gives you the real answer. A home test taken before it can be wrong because of the trigger injection.';
      case TtcTreatmentStep.pillStart:
        return 'Some clinics use a month of pills first, to time when the round starts.';
      case TtcTreatmentStep.downRegStart:
        return 'On a long plan, a daily injection quietens your cycle before stimulation.';
      case TtcTreatmentStep.estrogenStart:
        return 'Estrogen tablets build up the lining of your womb before a frozen transfer.';
      case TtcTreatmentStep.baselineScan:
        return 'Usually on day 2 or 3 of your period, to check your ovaries are quiet before medicines start.';
      case TtcTreatmentStep.iui:
        return 'It takes a few minutes. His sample is washed in the lab first, so ask what time it is needed.';
      case TtcTreatmentStep.progesteroneStart:
        return 'Progesterone supports the lining. Keep taking it until your clinic tells you to stop.';
      case TtcTreatmentStep.repeatBeta:
        return 'Some clinics repeat the blood test about 48 hours later.';
      case TtcTreatmentStep.reviewAppointment:
        return 'A time to go through the round with your doctor. Write your questions down before you go.';
    }
  }

  /// True for the one step stored with a time of day.
  bool get needsTime => this == TtcTreatmentStep.trigger;
}

/// What kind of round this is. Persisted by name.
enum TtcRoundKind {
  /// Tablets (letrozole or clomiphene) with follicle scans.
  ovulationInduction,
  iui,
  ivfFresh,
  ivfFreezeAll,
  fetMedicated,
  fetNatural,

  /// "Not sure yet": the IVF shape, every step optional.
  notSure,
}

/// How a round ended. Persisted by name.
enum TtcRoundOutcome {
  positive,

  /// "Not this time."
  negative,

  /// "Taking a break": closed, dates kept.
  paused,

  /// "It's over", from the check-in.
  ended,

  /// "The plan changed: it stopped early."
  stopped,
}

DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

class TtcTreatmentCycle {
  const TtcTreatmentCycle({
    required this.dates,
    this.clinic = '',
    this.triggerTaken = false,
    this.id = '',
    this.kind,
    this.scans = const [],
    this.embryoDay,
    this.outcome,
    this.closedOn,
    this.lastActivity,
    this.changedFrom,
  });

  /// Only the steps she filled in. A partial cycle is the normal case - most
  /// people know the next two dates and not the rest.
  final Map<TtcTreatmentStep, DateTime> dates;
  final String clinic;

  /// Ticked once the injection is actually done.
  ///
  /// This exists so the reminder can stop. A second alert at the exact minute
  /// is useful only if we do not know she has already done it - fire it anyway
  /// and a helpful nudge becomes a jolt of "did I miss it?" at the worst
  /// possible moment.
  final bool triggerTaken;

  // ---- the round (2026-09-26) ---------------------------------------------

  /// App-generated, so a local round and its cloud copy share one identity
  /// (CLAUDE.md). Empty on a legacy blob until the round is next touched.
  final String id;

  /// Null on a blob written before rounds existed: a LEGACY round, which keeps
  /// the evidence rule it always had (`TtcStore.ownershipOfCycle`).
  final TtcRoundKind? kind;

  /// Monitoring scans: follicle scans, lining scans. A list, because a round
  /// has as many as the clinic books. Date-only.
  final List<DateTime> scans;

  /// Day 3 or day 5, for a transfer. Kept for dating a pregnancy later (B8).
  final int? embryoDay;

  /// How it ended, and the day she said so. Null while the round is open.
  final TtcRoundOutcome? outcome;
  final DateTime? closedOn;

  /// The last day she added or changed anything in this round. Read by the
  /// 7-day check-in: "nothing new".
  final DateTime? lastActivity;

  /// The kind before "the plan changed" turned it into another (an IVF round
  /// that became an IUI, or a fresh round that froze all its embryos).
  final TtcRoundKind? changedFrom;

  bool get isEmpty => dates.isEmpty && scans.isEmpty;
  bool get isClosed => closedOn != null;

  /// Every date in the round, steps and scans alike, date-only.
  List<DateTime> get allDates =>
      [for (final d in dates.values) _dayOf(d), for (final s in scans) _dayOf(s)];

  DateTime? operator [](TtcTreatmentStep step) => dates[step];

  /// The next milestone still ahead, or null when the cycle is behind them.
  (TtcTreatmentStep, DateTime)? get next {
    final now = DateTime.now();
    (TtcTreatmentStep, DateTime)? best;
    for (final step in TtcTreatmentStep.values) {
      final at = dates[step];
      if (at == null || at.isBefore(now)) continue;
      if (best == null || at.isBefore(best.$2)) best = (step, at);
    }
    return best;
  }

  /// The date the two-week wait actually ends on a treatment cycle.
  ///
  /// NOT her next period: progesterone support usually delays it, so counting
  /// to a period produces a "you are late" that means nothing and reads as
  /// hope. The beta test is the real answer, on a date the clinic named.
  DateTime? get betaTest => dates[TtcTreatmentStep.betaTest];

  /// The steps dated inside one cycle: on or after [from] (the logged period
  /// start that opened it) and before [before] (the next start, or null for
  /// the cycle she is in). A null [from] (nothing logged) takes every date.
  ///
  /// ⚠️ THE EVIDENCE `TtcStore.ownershipOfCycle` READS (2026-09-26). A clinic
  /// owns a cycle's timing only when its dates fall inside that cycle, so a
  /// round she never cleared stops owning the cycle after it once she logs the
  /// next period, and a label with no dates owns nothing.
  Set<TtcTreatmentStep> stepsWithin(DateTime? from, DateTime? before) {
    final lo = from == null ? null : _dayOf(from);
    final hi = before == null ? null : _dayOf(before);
    return {
      for (final e in dates.entries)
        if ((lo == null || !_dayOf(e.value).isBefore(lo)) &&
            (hi == null || _dayOf(e.value).isBefore(hi)))
          e.key,
    };
  }

  /// True when any date of the round (a step or a scan) falls in the cycle
  /// from [from] to before [before].
  bool anyDateWithin(DateTime? from, DateTime? before) {
    final lo = from == null ? null : _dayOf(from);
    final hi = before == null ? null : _dayOf(before);
    return allDates.any((d) =>
        (lo == null || !d.isBefore(lo)) && (hi == null || d.isBefore(hi)));
  }

  TtcTreatmentCycle _copy({
    Map<TtcTreatmentStep, DateTime>? dates,
    String? clinic,
    bool? triggerTaken,
    String? id,
    TtcRoundKind? kind,
    List<DateTime>? scans,
    int? embryoDay,
    bool clearEmbryoDay = false,
    DateTime? lastActivity,
    TtcRoundKind? changedFrom,
  }) =>
      TtcTreatmentCycle(
        dates: dates ?? this.dates,
        clinic: clinic ?? this.clinic,
        triggerTaken: triggerTaken ?? this.triggerTaken,
        id: id ?? this.id,
        kind: kind ?? this.kind,
        scans: scans ?? this.scans,
        embryoDay: clearEmbryoDay ? null : (embryoDay ?? this.embryoDay),
        outcome: outcome,
        closedOn: closedOn,
        lastActivity: lastActivity ?? this.lastActivity,
        changedFrom: changedFrom ?? this.changedFrom,
      );

  TtcTreatmentCycle withDate(TtcTreatmentStep step, DateTime? at) {
    final next = Map<TtcTreatmentStep, DateTime>.from(dates);
    if (at == null) {
      next.remove(step);
    } else {
      next[step] = at;
    }
    // Moving the trigger to a new time un-ticks it: the clinic rescheduled, so
    // the injection she took is not the one now on the calendar.
    final stillTaken = step == TtcTreatmentStep.trigger
        ? (at != null && dates[step] == at && triggerTaken)
        : triggerTaken;
    return _copy(dates: next, triggerTaken: stillTaken);
  }

  TtcTreatmentCycle withClinic(String name) => _copy(clinic: name.trim());

  TtcTreatmentCycle withTriggerTaken(bool taken) =>
      _copy(triggerTaken: taken);

  // ---- round edits (2026-09-26) -------------------------------------------

  TtcTreatmentCycle withId(String id) => _copy(id: id);
  TtcTreatmentCycle withKind(TtcRoundKind kind, {TtcRoundKind? from}) =>
      _copy(kind: kind, changedFrom: from);
  TtcTreatmentCycle withActivity(DateTime at) =>
      _copy(lastActivity: _dayOf(at));
  TtcTreatmentCycle withEmbryoDay(int? day) =>
      day == null ? _copy(clearEmbryoDay: true) : _copy(embryoDay: day);

  TtcTreatmentCycle withScanAdded(DateTime day) {
    final d = _dayOf(day);
    if (scans.any((s) => _dayOf(s) == d)) return this;
    return _copy(scans: [...scans, d]..sort());
  }

  TtcTreatmentCycle withScanRemoved(DateTime day) {
    final d = _dayOf(day);
    return _copy(scans: [
      for (final s in scans)
        if (_dayOf(s) != d) s,
    ]);
  }

  /// This round, closed with [how] on [on]. Nothing else about it changes.
  TtcTreatmentCycle closed(TtcRoundOutcome how, DateTime on) =>
      TtcTreatmentCycle(
        dates: dates,
        clinic: clinic,
        triggerTaken: triggerTaken,
        id: id,
        kind: kind,
        scans: scans,
        embryoDay: embryoDay,
        outcome: how,
        closedOn: _dayOf(on),
        lastActivity: lastActivity,
        changedFrom: changedFrom,
      );

  /// This round, open again exactly as it was before it closed (the undo).
  TtcTreatmentCycle reopened() => TtcTreatmentCycle(
        dates: dates,
        clinic: clinic,
        triggerTaken: triggerTaken,
        id: id,
        kind: kind,
        scans: scans,
        embryoDay: embryoDay,
        lastActivity: lastActivity,
        changedFrom: changedFrom,
      );

  Map<String, Object?> toJson() => {
        // ---- the original shape: never renamed ----
        'clinic': clinic,
        'triggerTaken': triggerTaken,
        'dates': {
          for (final e in dates.entries) e.key.name: e.value.toIso8601String(),
        },
        // ---- the round (2026-09-26), all optional on read ----
        if (id.isNotEmpty) 'id': id,
        if (kind != null) 'kind': kind!.name,
        if (scans.isNotEmpty)
          'scans': [for (final s in scans) TtcSyncUtil.date(s)],
        if (embryoDay != null) 'embryoDay': embryoDay,
        if (outcome != null) 'outcome': outcome!.name,
        if (closedOn != null) 'closedOn': TtcSyncUtil.date(closedOn!),
        if (lastActivity != null)
          'lastActivity': TtcSyncUtil.date(lastActivity!),
        if (changedFrom != null) 'changedFrom': changedFrom!.name,
      };

  static TtcTreatmentCycle fromJson(Object? raw) {
    if (raw is! Map) return const TtcTreatmentCycle(dates: {});
    final out = <TtcTreatmentStep, DateTime>{};
    final map = raw['dates'];
    if (map is Map) {
      for (final e in map.entries) {
        final step = TtcTreatmentStep.values
            .where((s) => s.name == e.key)
            .firstOrNull;
        final at = DateTime.tryParse(e.value?.toString() ?? '');
        if (step != null && at != null) out[step] = at;
      }
    }
    T? byName<T extends Enum>(List<T> values, Object? name) =>
        values.where((v) => v.name == name).firstOrNull;
    final rawScans = raw['scans'];
    final embryo = raw['embryoDay'];
    return TtcTreatmentCycle(
      dates: out,
      clinic: (raw['clinic'] as String?) ?? '',
      triggerTaken: raw['triggerTaken'] == true,
      id: raw['id'] is String ? raw['id'] as String : '',
      kind: byName(TtcRoundKind.values, raw['kind']),
      scans: rawScans is List
          ? ([
              for (final s in rawScans) ?TtcSyncUtil.parseDate(s),
            ]..sort())
          : const [],
      embryoDay: embryo is int ? embryo : null,
      outcome: byName(TtcRoundOutcome.values, raw['outcome']),
      closedOn: TtcSyncUtil.parseDate(raw['closedOn']),
      lastActivity: TtcSyncUtil.parseDate(raw['lastActivity']),
      changedFrom: byName(TtcRoundKind.values, raw['changedFrom']),
    );
  }
}

/// The four-hours-before trigger reminder's body for a round of [kind]
/// (2026-09-26, §3d). Egg collection is timed 34 to 36 hours after the
/// trigger, so the IVF shapes say so; an IUI says it is timed from it; any
/// other round says only that the time is the clinic's.
String ttcTriggerPrepBody(TtcRoundKind? kind, DateTime at) {
  final time = TtcTreatmentStore._hhmm(at);
  return switch (kind) {
    TtcRoundKind.iui => 'Your clinic set this for $time, and your IUI is '
        'timed from it. If anything is unclear, call them now.',
    TtcRoundKind.ovulationInduction ||
    TtcRoundKind.fetNatural =>
      'Your clinic set this for $time. A good time to get the injection '
          'ready. If anything is unclear, call them now.',
    _ => 'Your clinic set this for $time. Egg collection is timed from it, '
        'about 34 to 36 hours later. If anything is unclear, call them now.',
  };
}

/// A new round id. App-generated, like every TTC row id.
String ttcNewRoundId([DateTime? now]) =>
    'ttcround_${(now ?? DateTime.now()).microsecondsSinceEpoch}';

class TtcTreatmentStore extends ChangeNotifier with TtcSyncedStore {
  TtcTreatmentStore._() {
    _load();
  }
  static final TtcTreatmentStore instance = TtcTreatmentStore._();

  static const _key = 'ttc_treatment';

  /// Her own one-time flags and the last day she opened the app. LOCAL ONLY
  /// and per person: the treatment row is couple-scoped, and his "seen"
  /// must never hide an announcement from her.
  static const _uiKey = 'ttc_treatment_ui';

  /// How long a closed round can be reopened exactly as it was.
  static const int undoDays = 7;

  /// How long "Ask me later" holds the check-in back: gently, not a nag.
  static const int checkInSnoozeDays = 3;

  /// Stable notification ids for the two trigger reminders. High and fixed so
  /// they cannot collide with the reminder / medication id spaces.
  ///
  /// Two, not one, because they do different jobs - see [_rescheduleTrigger].
  static const int triggerPrepNotificationId = 918001;
  static const int triggerNotificationId = 918002;

  TtcTreatmentCycle _cycle = const TtcTreatmentCycle(dates: {});
  List<TtcTreatmentCycle> _history = const [];
  bool _loaded = false;

  // ---- her own flags (local) -----------------------------------------------
  DateTime? _lastSeen;
  bool _askOnReturn = false;
  DateTime? _snoozedUntil;
  String? _announcedActive;
  String? _announcedReturn;

  bool get isLoaded => _loaded;

  /// The current round (open, or empty).
  TtcTreatmentCycle get cycle => _cycle;
  bool get hasDates => !_cycle.isEmpty;

  /// Rounds she has closed, oldest first. Never pruned.
  List<TtcTreatmentCycle> get history => List.unmodifiable(_history);

  /// The last round she closed, or null.
  TtcTreatmentCycle? get lastClosed => _history.isEmpty ? null : _history.last;



  void _touch({DateTime? now}) {
    final at = now ?? DateTime.now();
    if (_cycle.id.isEmpty && !_cycle.isEmpty) {
      _cycle = _cycle.withId(ttcNewRoundId(at));
    }
    _cycle = _cycle.withActivity(at);
  }

  void setDate(TtcTreatmentStep step, DateTime? at) {
    _cycle = _cycle.withDate(step, at);
    _touch();
    _changed(trigger: true);
  }

  void setClinic(String name) {
    _cycle = _cycle.withClinic(name);
    _persist();
    notifyListeners();
  }

  /// Ticked when the injection is done. Silences both reminders - the whole
  /// reason the tick exists.
  void setTriggerTaken(bool taken) {
    _cycle = _cycle.withTriggerTaken(taken);
    _persist();
    _rescheduleTrigger();
    notifyListeners();
  }

  void addScan(DateTime day) {
    _cycle = _cycle.withScanAdded(day);
    _touch();
    _changed();
  }

  void removeScan(DateTime day) {
    _cycle = _cycle.withScanRemoved(day);
    _touch();
    _changed();
  }

  void setEmbryoDay(int? day) {
    _cycle = _cycle.withEmbryoDay(day);
    _touch();
    _changed();
  }

  /// "The plan changed": the same round, another kind, every date kept.
  void changeKind(TtcRoundKind kind) {
    if (_cycle.kind == kind) return;
    _cycle = _cycle.withKind(kind, from: _cycle.kind);
    _touch();
    _changed();
  }

  /// Saves a new round from the start flow.
  ///
  /// A LEGACY round (dates, no kind) is adopted: its dates are kept and the
  /// kind is added. An open round of the new shape is closed first as
  /// "ended" and kept in history; the start flow says so before she saves.
  void startRound({
    required TtcRoundKind kind,
    Map<TtcTreatmentStep, DateTime> dates = const {},
    List<DateTime> scans = const [],
    String clinic = '',
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    if (_cycle.kind != null && !_cycle.isEmpty) {
      _history = [..._history, _cycle.closed(TtcRoundOutcome.ended, at)];
    }
    final keep = _cycle.kind == null ? _cycle : const TtcTreatmentCycle(dates: {});
    var round = TtcTreatmentCycle(
      dates: {...keep.dates, ...dates},
      clinic: clinic.trim().isEmpty ? keep.clinic : clinic.trim(),
      triggerTaken: keep.triggerTaken,
      id: ttcNewRoundId(at),
      kind: kind,
      scans: keep.scans,
    );
    for (final s in scans) {
      round = round.withScanAdded(s);
    }
    _cycle = round.withActivity(at);
    // She read "from <date>, your home follows your round" on the way in, so
    // a round that is already running has been announced.
    if (ttcTreatmentActive(_cycle, at)) _announcedActive = _cycle.id;
    _askOnReturn = false;
    _snoozedUntil = null;
    _changed(trigger: true, ui: true);
  }

  /// Closes the current round with [how]. It moves to [history]; nothing is
  /// deleted, and [undoClose] reopens it for [undoDays] days.
  void closeRound(TtcRoundOutcome how, {DateTime? now}) {
    if (_cycle.isEmpty) return;
    final at = now ?? DateTime.now();
    var round = _cycle;
    if (round.id.isEmpty) round = round.withId(ttcNewRoundId(at));
    _history = [..._history, round.closed(how, at)];
    _cycle = const TtcTreatmentCycle(dates: {});
    _askOnReturn = false;
    _snoozedUntil = null;
    _changed(trigger: true, ui: true);
  }

  /// True when the last close can still be undone on [now].
  bool canUndoClose({DateTime? now}) {
    final last = lastClosed;
    if (last == null || last.closedOn == null || !_cycle.isEmpty) return false;
    final days = _dayOf(now ?? DateTime.now()).difference(last.closedOn!).inDays;
    return days >= 0 && days <= undoDays;
  }

  /// Reopens the last closed round exactly as it was before it closed.
  bool undoClose({DateTime? now}) {
    if (!canUndoClose(now: now)) return false;
    _cycle = _history.last.reopened();
    _history = _history.sublist(0, _history.length - 1);
    _changed(trigger: true);
    return true;
  }

  // ---- the check-in (decision 3) -------------------------------------------

  /// Whether the home should ask "Is your round still going?" today: after 7
  /// quiet days with nothing ahead, or on her first return after 30 days
  /// away, and not while "Ask me later" holds.
  bool checkInDue({DateTime? now}) {
    final at = now ?? DateTime.now();
    if (_cycle.isEmpty || _cycle.isClosed) return false;
    final snooze = _snoozedUntil;
    if (snooze != null && _dayOf(at).isBefore(snooze)) return false;
    return _askOnReturn || ttcTreatmentNeedsCheckIn(_cycle, at);
  }

  /// True when she came back after 30 days or more and has not answered yet.
  bool get askOnReturnPending => _askOnReturn;

  /// "Still going: keep following my round."
  void stillGoing({DateTime? now}) {
    _touch(now: now);
    _askOnReturn = false;
    _snoozedUntil = null;
    _changed(ui: true);
  }

  /// "Ask me later": the check-in waits [checkInSnoozeDays] days.
  void snoozeCheckIn({DateTime? now}) {
    final at = _dayOf(now ?? DateTime.now());
    _snoozedUntil = at.add(const Duration(days: checkInSnoozeDays));
    _persistUi();
    notifyListeners();
  }

  /// Called when the app opens. Remembers the day, and flags a return after
  /// 30 days away while a round is open, so the home asks before anything is
  /// assumed. Safe to call more than once a day.
  void noteOpened({DateTime? now}) {
    final at = now ?? DateTime.now();
    if (!_cycle.isEmpty &&
        !_cycle.isClosed &&
        ttcTreatmentAskOnReturn(_cycle, at, _lastSeen)) {
      _askOnReturn = true;
    }
    _lastSeen = _dayOf(at);
    _persistUi();
    notifyListeners();
  }

  // ---- the one-time announcements ------------------------------------------

  /// "Your home now follows your round", once per round, on or after its
  /// first treatment day.
  bool activeAnnouncementDue({DateTime? now}) =>
      !_cycle.isEmpty &&
      _cycle.id.isNotEmpty &&
      _announcedActive != _cycle.id &&
      ttcTreatmentActive(_cycle, now ?? DateTime.now());

  void markActiveAnnounced() {
    _announcedActive = _cycle.id;
    _persistUi();
    notifyListeners();
  }

  /// "Your fertile days are back", once per closed round, the day her own
  /// cycle is followed again. [ownCycleAgain] is `TtcStore.ownership ==
  /// parentveda`, passed in so this store never reads that one.
  bool returnAnnouncementDue({required bool ownCycleAgain}) {
    final last = lastClosed;
    if (last == null || last.outcome == TtcRoundOutcome.positive) return false;
    if (!_cycle.isEmpty) return false;
    if (_announcedReturn == last.id) return false;
    return ownCycleAgain;
  }

  void markReturnAnnounced() {
    _announcedReturn = lastClosed?.id;
    _persistUi();
    notifyListeners();
  }

  /// Clearing the current round - "Remove these dates", for a round entered
  /// by mistake. Past rounds in [history] are untouched.
  void clearCycle() {
    _cycle = const TtcTreatmentCycle(dates: {});
    _persist();
    NotificationService.instance
      ..cancel(triggerPrepNotificationId)
      ..cancel(triggerNotificationId);
    notifyListeners();
  }

  void _changed({bool trigger = false, bool ui = false}) {
    _persist();
    if (ui) _persistUi();
    if (trigger) _rescheduleTrigger();
    notifyListeners();
  }

  /// The trigger is the one date worth interrupting someone for, and it is
  /// worth interrupting them TWICE, because the two reminders do different
  /// jobs:
  ///
  ///   four hours before  - be somewhere you can do this. Leave work, collect
  ///                        the injection, check whether it needs refrigerating,
  ///                        arrange the trip if someone has to give it.
  ///   fifteen minutes    - it is now. Timing matters because the clinic books
  ///                        retrieval off this exact moment.
  ///
  /// Neither fires once [TtcTreatmentCycle.triggerTaken] is ticked. The second
  /// one is only safe BECAUSE of that tick: an alert at the exact minute, to
  /// someone who has already done it, is pure alarm.
  ///
  /// The copy is deliberately actionable rather than urgent. "Time to take it"
  /// is a nudge; "don't miss this" is a threat, on the one evening of the cycle
  /// nobody needs one.
  Future<void> _rescheduleTrigger() async {
    final service = NotificationService.instance;
    await service.cancel(triggerPrepNotificationId);
    await service.cancel(triggerNotificationId);

    final at = _cycle[TtcTreatmentStep.trigger];
    if (at == null || _cycle.triggerTaken) return;

    // The 34 to 36 hour note (2026-09-26, §3d), on the rounds that end in egg
    // collection. Kept for revert, the one body for every round:
    //   'Your clinic set this for ${_hhmm(at)}. '
    //       'A good time to get the injection ready.'
    await service.scheduleOneOff(
      id: triggerPrepNotificationId,
      title: 'Trigger injection in 4 hours',
      body: ttcTriggerPrepBody(_cycle.kind, at),
      when: at.subtract(const Duration(hours: 4)),
    );
    await service.scheduleOneOff(
      id: triggerNotificationId,
      title: 'Time to take your trigger injection',
      body: 'Your clinic set this for ${_hhmm(at)}. '
          'If anything is unclear, call them now instead of guessing.',
      when: at.subtract(const Duration(minutes: 15)),
    );
  }

  static String _hhmm(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'am' : 'pm';
    return '$h:${d.minute.toString().padLeft(2, '0')}$ampm';
  }

  @visibleForTesting
  void resetForTest() {
    _cycle = const TtcTreatmentCycle(dates: {});
    _history = const [];
    _lastSeen = null;
    _askOnReturn = false;
    _snoozedUntil = null;
    _announcedActive = null;
    _announcedReturn = null;
    _loaded = true;
    notifyListeners();
  }

  /// Reloads from the device, as a restart would. Tests use it to prove a
  /// round survives the app being closed.
  @visibleForTesting
  Future<void> reloadForTest() async {
    _loaded = false;
    _cycle = const TtcTreatmentCycle(dates: {});
    _history = const [];
    await _load(sync: false);
  }

  // ---- cloud ----------------------------------------------------------------
  //  Couple-scoped: a treatment cycle is emphatically not one person's. He needs
  //  the retrieval date as much as she does.

  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared('ttc_treatment',
        orderBy: 'updated_at', ascending: false);
    if (rows.isEmpty) return;
    // One active cycle per couple; the newest row wins. This is settings-shaped
    // rather than log-shaped, so last-write-wins is right here.
    if (_cycle.isEmpty && _history.isEmpty) {
      _decodeBlob(rows.first['cycle']);
      _rescheduleTrigger();
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    await SupabaseRepo.upsertRow(
      'ttc_treatment',
      {
        'user_id': uid,
        // ⚠️ THE SAME THREE COLUMNS AS 0043. History rides inside the blob.
        'cycle': _blob(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  /// Re-arms the two trigger-shot reminders after the app starts.
  ///
  /// ⚠️ FOUND 2026-09-26 (TTC gap plan, messages work): `ReminderStore.init`
  /// ends in `NotificationService.syncAll`, which cancels EVERY pending
  /// notification on each launch, and nothing scheduled the trigger again, so
  /// a woman who reopened the app after setting her trigger time lost both
  /// reminders on the one evening timing is exact. `main.dart` calls this
  /// after that sync has finished. Safe to call more than once.
  ///
  /// Also notes the app opening, for the 30-days-away check-in.
  Future<void> rearmAfterStartup() async {
    await _load();
    noteOpened();
    await _rescheduleTrigger();
  }

  /// The blob: the current round's own JSON (the original shape at its top
  /// level) plus `history`.
  Map<String, Object?> _blob() => {
        ..._cycle.toJson(),
        if (_history.isNotEmpty)
          'history': [for (final r in _history) r.toJson()],
      };

  void _decodeBlob(Object? raw) {
    _cycle = TtcTreatmentCycle.fromJson(raw);
    final h = raw is Map ? raw['history'] : null;
    _history = h is List
        ? [
            for (final r in h)
              if (TtcTreatmentCycle.fromJson(r) case final c when !c.isEmpty) c,
          ]
        : const [];
  }

  Future<void> _load({bool sync = true}) async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw != null) _decodeBlob(jsonDecode(raw));
      final ui = p.getString(_uiKey);
      if (ui != null) {
        final m = jsonDecode(ui);
        if (m is Map) {
          _lastSeen = TtcSyncUtil.parseDate(m['lastSeen']);
          _askOnReturn = m['askOnReturn'] == true;
          _snoozedUntil = TtcSyncUtil.parseDate(m['snoozedUntil']);
          _announcedActive = m['announcedActive'] as String?;
          _announcedReturn = m['announcedReturn'] as String?;
        }
      }
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    if (sync) await syncFromCloud();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, jsonEncode(_blob()));
    } catch (_) {/* best-effort */}
  }

  Future<void> _persistUi() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          _uiKey,
          jsonEncode({
            if (_lastSeen != null) 'lastSeen': TtcSyncUtil.date(_lastSeen!),
            'askOnReturn': _askOnReturn,
            if (_snoozedUntil != null)
              'snoozedUntil': TtcSyncUtil.date(_snoozedUntil!),
            if (_announcedActive != null) 'announcedActive': _announcedActive,
            if (_announcedReturn != null) 'announcedReturn': _announcedReturn,
          }));
    } catch (_) {/* best-effort */}
  }
}

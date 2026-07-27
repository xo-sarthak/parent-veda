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
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../services/remote/supabase_repo.dart';
import 'ttc_sync.dart';

/// The milestones of one treatment cycle, in the order they happen.
enum TtcTreatmentStep { stimStart, trigger, retrieval, transfer, betaTest }

extension TtcTreatmentStepCopy on TtcTreatmentStep {
  String label(bool hi) {
    switch (this) {
      case TtcTreatmentStep.stimStart:
        return hi ? 'Stimulation shuru' : 'Stimulation starts';
      case TtcTreatmentStep.trigger:
        return hi ? 'Trigger shot' : 'Trigger shot';
      case TtcTreatmentStep.retrieval:
        return hi ? 'Egg retrieval / IUI' : 'Egg retrieval / IUI';
      case TtcTreatmentStep.transfer:
        return hi ? 'Transfer' : 'Transfer';
      case TtcTreatmentStep.betaTest:
        return hi ? 'Beta hCG blood test' : 'Beta hCG blood test';
    }
  }

  /// The thing people actually forget. Short, practical, never clinical advice
  /// - each of these is something a clinic says out loud and nobody writes down.
  String note(bool hi) {
    switch (this) {
      case TtcTreatmentStep.stimStart:
        return hi
            ? 'Injections aksar roz ek hi samay par hoti hain. Pehla din note kar lein.'
            : 'Injections are usually at the same time each day. Note which day is day one.';
      case TtcTreatmentStep.trigger:
        return hi
            ? 'Samay bilkul theek rakhein - retrieval iske baad ek tay ghante par hota hai.'
            : 'Timing is exact - retrieval is scheduled a set number of hours after this.';
      case TtcTreatmentStep.retrieval:
        return hi
            ? 'Aam taur par sedation hoti hai. Aadhi raat se kuch na khaayein, aur koi saath aaye.'
            : 'Usually under sedation. Nothing to eat from midnight, and bring someone with you.';
      case TtcTreatmentStep.transfer:
        return hi
            ? 'Kai clinics bharay hue bladder ke saath kehti hain. Unka nirdesh hi maanein.'
            : 'Many clinics ask you to come with a full bladder. Follow theirs, not ours.';
      case TtcTreatmentStep.betaTest:
        return hi
            ? 'Yahi asli jawab hai. Ghar ka test isse pehle trigger ki wajah se galat aa sakta hai.'
            : 'This is the real answer. A home test before it can read wrong because of the trigger.';
    }
  }

  /// True for the one step stored with a time of day.
  bool get needsTime => this == TtcTreatmentStep.trigger;
}

class TtcTreatmentCycle {
  const TtcTreatmentCycle({
    required this.dates,
    this.clinic = '',
    this.triggerTaken = false,
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

  bool get isEmpty => dates.isEmpty;

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
    return TtcTreatmentCycle(
        dates: next, clinic: clinic, triggerTaken: stillTaken);
  }

  TtcTreatmentCycle withClinic(String name) => TtcTreatmentCycle(
      dates: dates, clinic: name.trim(), triggerTaken: triggerTaken);

  TtcTreatmentCycle withTriggerTaken(bool taken) => TtcTreatmentCycle(
      dates: dates, clinic: clinic, triggerTaken: taken);

  Map<String, Object?> toJson() => {
        'clinic': clinic,
        'triggerTaken': triggerTaken,
        'dates': {
          for (final e in dates.entries) e.key.name: e.value.toIso8601String(),
        },
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
    return TtcTreatmentCycle(
      dates: out,
      clinic: (raw['clinic'] as String?) ?? '',
      triggerTaken: raw['triggerTaken'] == true,
    );
  }
}

class TtcTreatmentStore extends ChangeNotifier with TtcSyncedStore {
  TtcTreatmentStore._() {
    _load();
  }
  static final TtcTreatmentStore instance = TtcTreatmentStore._();

  static const _key = 'ttc_treatment';

  /// Stable notification ids for the two trigger reminders. High and fixed so
  /// they cannot collide with the reminder / medication id spaces.
  ///
  /// Two, not one, because they do different jobs - see [_rescheduleTrigger].
  static const int triggerPrepNotificationId = 918001;
  static const int triggerNotificationId = 918002;

  TtcTreatmentCycle _cycle = const TtcTreatmentCycle(dates: {});
  bool _loaded = false;

  bool get isLoaded => _loaded;
  TtcTreatmentCycle get cycle => _cycle;
  bool get hasDates => !_cycle.isEmpty;

  void setDate(TtcTreatmentStep step, DateTime? at) {
    _cycle = _cycle.withDate(step, at);
    _persist();
    _rescheduleTrigger();
    notifyListeners();
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

  /// Clearing the whole cycle - used when a round ends, so the next one starts
  /// clean rather than inheriting stale dates.
  void clearCycle() {
    _cycle = const TtcTreatmentCycle(dates: {});
    _persist();
    NotificationService.instance
      ..cancel(triggerPrepNotificationId)
      ..cancel(triggerNotificationId);
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

    await service.scheduleOneOff(
      id: triggerPrepNotificationId,
      title: 'Trigger shot in 4 hours',
      body: 'Your clinic set this for ${_hhmm(at)}. '
          'Good moment to get the injection ready.',
      when: at.subtract(const Duration(hours: 4)),
    );
    await service.scheduleOneOff(
      id: triggerNotificationId,
      title: 'Time to take your trigger shot',
      body: 'Your clinic set this for ${_hhmm(at)}. '
          'If anything is unclear, call them now rather than guessing.',
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
    _loaded = true;
    notifyListeners();
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
    if (_cycle.isEmpty) {
      _cycle = TtcTreatmentCycle.fromJson(rows.first['cycle']);
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
        'cycle': _cycle.toJson(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw != null) _cycle = TtcTreatmentCycle.fromJson(jsonDecode(raw));
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, jsonEncode(_cycle.toJson()));
    } catch (_) {/* best-effort */}
  }
}

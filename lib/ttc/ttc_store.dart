// =============================================================================
//  TtcStore - the journey-level facts of the Trying-to-Conceive stage
// -----------------------------------------------------------------------------
//  CycleStore holds the biology. This holds the JOURNEY: when it began, which
//  medical path the couple is on, whether a partner has joined, and whether a
//  positive test has been recorded.
//
//  It is also the one place screens ask "where are we today?". They call
//  `TtcStore.instance.today` and get a fully-resolved TtcToday - nobody
//  re-derives a cycle day, and no screen ever touches TtcChapterEngine
//  directly. That keeps the arithmetic in exactly one place, which is what
//  makes it safe to change later.
//
//  Listens to CycleStore so a period logged anywhere rebuilds every screen
//  bound to this store - the couple should never have to leave and come back
//  to see their own data.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/family_profile.dart' show FamilyProfileStore;
import '../services/life_stage_store.dart';
import '../services/remote/supabase_repo.dart';
import 'cycle_store.dart';
import 'ttc_chapter.dart';
import 'ttc_sync.dart';
import 'ttc_treatment_round.dart';
import 'ttc_treatment_store.dart';

class TtcStore extends ChangeNotifier with TtcSyncedStore {
  TtcStore._() {
    // A cycle change is a journey change: rebroadcast so a screen only has to
    // listen to one store.
    CycleStore.instance.addListener(notifyListeners);
    // And so is a clinic date: since 2026-09-26 the dates in the treatment
    // tracker decide who owns the timing ([ownership]), so entering or
    // clearing one must rebuild every screen bound to this store.
    TtcTreatmentStore.instance.addListener(notifyListeners);
    _load();
  }
  static final TtcStore instance = TtcStore._();

  static const _startKey = 'ttc_journey_start';
  static const _pathKey = 'ttc_path';
  static const _confirmedKey = 'ttc_pregnancy_confirmed';
  static const _partnerKey = 'ttc_partner_joined';
  static const _monitorsKey = 'ttc_clinic_monitors';
  static const _medicatedKey = 'ttc_medicated_cycle';
  static const _statedLengthKey = 'ttc_stated_cycle_length';

  static const _engine = TtcChapterEngine();

  DateTime? _journeyStart;
  TtcPath _path = TtcPath.natural;
  bool? _clinicMonitors;
  bool? _medicated;
  int? _statedLength;
  DateTime? _pregnancyConfirmedOn;
  bool _partnerJoined = false;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// When this couple began trying with us. Falls back to the day they declared
  /// the life stage, so a couple who never explicitly set a start date still
  /// has a real journey rather than a null one.
  ///
  /// ⚠️ THEN FROM HER OWN ANSWER, BEFORE THE DAY SHE ARRIVED (2026-09-27, found on
  /// the phone: You said "Trying · over a year" while Should I get help? filled
  /// in "Less than 6 months"). Onboarding V2 asks "How long have you been
  /// trying?" and saves only the profile answer; only the older TTC intro set a
  /// start date. So every "how long" in the stage counted from her install
  /// day, including the six-months-at-35 and one-year checks. The answer is
  /// read at its LOW end (a year, six months, three months, none), so nothing
  /// ever says she has tried longer than she told us. Kept for revert:
  ///   _journeyStart ?? LifeStageStore.instance.enteredAt;
  DateTime? get journeyStart =>
      _journeyStart ??
      ttcStartFromAnswer(FamilyProfileStore.instance.otherFor('ttc_duration'),
          LifeStageStore.instance.enteredAt) ??
      LifeStageStore.instance.enteredAt;

  /// Which medical pathway they are on. Never forced, always changeable.
  ///
  /// NOTE: this no longer decides behaviour on its own - see [pathway]. The
  /// same treatment behaves in opposite ways depending on whether a clinic is
  /// monitoring it, which is why the two questions below exist.
  TtcPath get path => _path;

  /// The pathway PLUS the two facts that decide who owns the timing.
  TtcCarePathway get pathway => TtcCarePathway(
        path: _path,
        clinicMonitors: _clinicMonitors,
        medicationControlsOvulation: _medicated,
      );

  /// THE fertility rule. Every surface that might show a date reads this.
  ///
  /// ⚠️ I TRIED TO WEAKEN THIS ON 2026-09-05 AND THE SUITE REFUSED, CORRECTLY.
  ///
  /// The change was `pathway.isAnswered ? pathway.ownership : parentveda` — on
  /// the argument that `path.defaultMedicated` is a guess from a LABEL, that
  /// `setPath` clears both answers so the guess always applies, and that one
  /// stray tap on "IVF" therefore switches the fertile window off permanently
  /// with no route back from the home screen. All of that is true.
  ///
  /// It also broke **36 tests**, and they were the right ones: `Inferable`'s
  /// default-deny in `journey_state_test`, the care-pathway rules, the cycle
  /// companion's refusal. Those are not incidental — they are the clinical
  /// spine described in CLAUDE.md, and a hero that reads better is not worth
  /// publishing an ovulation estimate into a medicated cycle.
  ///
  /// ⚠️ SO THE REAL PROBLEM IS NOT THIS RULE, IT IS THAT THE STATE IS A TRAP.
  /// Entering it takes one tap; leaving it means finding two questions on the
  /// treatment screen that nothing points at. The fix belongs at the door, not
  /// in the rule — see `docs/STILL-OPEN.md` §30.
  ///
  /// ⚠️ DECIDED 2026-09-26: THE EVIDENCE IS REAL CLINIC DATES. The user's
  /// decision, and the fix §30 was waiting for, made in the one place every
  /// surface already reads: a clinic owns the timing of the cycle she is in
  /// only when the treatment tracker holds a date her clinic gave her for it
  /// ([ownershipOfCycle], `ttcTimingOwnershipFromEvidence`). The label and
  /// her two answers still pick the tier once dates exist. With a label and no
  /// dates, the whole app treats the cycle as hers.
  ///
  /// This is not the 2026-09-05 weakening above. That kept the label as the
  /// evidence and simply ignored it until she answered; this keeps the rule
  /// exactly as strict (a clinic that owns the timing is never contradicted,
  /// on any surface) and changes only what proves a clinic owns it. The tests
  /// that assumed label-only ownership now enter a clinic date, with a note
  /// citing this decision. Kept for revert:
  ///   TimingOwnership get ownership => pathway.ownership;
  ///
  /// ⚠️ AND A ROUND RUNS IT FROM ITS FIRST TREATMENT DAY (2026-09-26,
  /// docs/TTC-TREATMENT-FLOW.md decision 1). A round with a kind (saved by the
  /// start flow) owns the cycle she is in from its first treatment date until
  /// she closes it (`ttcTreatmentActive`), whatever period she logs in
  /// between, and its kind and trigger pick the tier (`ttcRoundTier`,
  /// decision 2). Its dates for NEXT month do not hand this month over: a
  /// planned round leaves her on her own cycle. Once closed, it moves to the
  /// round history, whose dates still hold the cycle they fall in, so her
  /// fertile days come back with the next period she logs (decision 5). A
  /// legacy round (an older blob with no kind) keeps the evidence rule below
  /// unchanged. Kept for revert:
  ///   TimingOwnership get ownership =>
  ///       ownershipOfCycle(CycleStore.instance.lastPeriodStart);
  TimingOwnership get ownership {
    final round = TtcTreatmentStore.instance.cycle;
    final start = CycleStore.instance.lastPeriodStart;
    if (round.kind == null) return ownershipOfCycle(start);
    if (ttcTreatmentActive(round, DateTime.now())) return ttcRoundTier(round);
    return _ownershipOf(start, null, includeCurrent: false);
  }

  /// Who owns the timing of the cycle that began on [start] and ran until
  /// [nextStart] (null for the cycle she is in). The same evidence rule as
  /// [ownership], asked of any cycle, so an earlier cycle her clinic ran keeps
  /// its refusal when she looks back at it.
  ///
  /// ⚠️ EVERY ROUND COUNTS, THE CLOSED ONES TOO (2026-09-26). The current
  /// round and each round in her history answer for the cycles they ran in:
  /// a round with a kind by its tier (`ttcRoundTier`) wherever it ran
  /// (`ttcRoundRanDuring`), a legacy round by the evidence rule it always had.
  /// Only cycles a round ran in are held; earlier cycles before any round keep
  /// their look-back fertile days. Kept for revert, the one-round rule:
  ///   final steps =
  ///       TtcTreatmentStore.instance.cycle.stepsWithin(start, nextStart);
  ///   return ttcTimingOwnershipFromEvidence(
  ///     pathway: pathway,
  ///     hasClinicDates: steps.isNotEmpty,
  ///     medicationDated: steps.contains(TtcTreatmentStep.stimStart) ||
  ///         steps.contains(TtcTreatmentStep.trigger) ||
  ///         steps.contains(TtcTreatmentStep.transfer),
  ///   );
  TimingOwnership ownershipOfCycle(DateTime? start, {DateTime? nextStart}) =>
      _ownershipOf(start, nextStart, includeCurrent: true);

  TimingOwnership _ownershipOf(DateTime? start, DateTime? nextStart,
      {required bool includeCurrent}) {
    final t = TtcTreatmentStore.instance;
    final today = DateTime.now();
    var best = TimingOwnership.parentveda;
    for (final r in [if (includeCurrent) t.cycle, ...t.history]) {
      if (r.isEmpty) continue;
      final TimingOwnership own;
      if (r.kind != null) {
        if (!ttcRoundRanDuring(r, start, nextStart, today)) continue;
        own = ttcRoundTier(r);
      } else {
        final steps = r.stepsWithin(start, nextStart);
        own = ttcTimingOwnershipFromEvidence(
          pathway: pathway,
          hasClinicDates: steps.isNotEmpty,
          medicationDated: steps.contains(TtcTreatmentStep.stimStart) ||
              steps.contains(TtcTreatmentStep.trigger) ||
              steps.contains(TtcTreatmentStep.transfer),
        );
      }
      if (own == TimingOwnership.clinicControlled) return own;
      if (own == TimingOwnership.clinicGuided) best = own;
    }
    return best;
  }

  /// The usual cycle length she TOLD us (the "Should I test?" chat asks when
  /// it has nothing to count with). Read by the engine only until her first
  /// cycle completes; see `TtcJourneyState.statedCycleLength`. Null = never
  /// said, and the engine's 28 days applies.
  ///
  /// ⚠️ LOCAL ONLY. `ttc_journeys` has no column for it, and a field sent to
  /// a column that does not exist fails silently (CLAUDE.md, cloud writes are
  /// fire-and-forget). It stops mattering the day her first cycle completes,
  /// so a reinstall before then falls back to 28 days, which is the default
  /// the engine would use anyway.
  int? get statedCycleLength => _statedLength;

  TtcPathwayBehaviour get behaviour => TtcPathwayBehaviour(ownership);

  /// True when she has answered the two questions rather than us assuming from
  /// the pathway. Surfaces use it to invite an answer, never to withhold.
  bool get pathwayAnswered => pathway.isAnswered;

  /// Set once a positive test is recorded. Null while still trying.
  DateTime? get pregnancyConfirmedOn => _pregnancyConfirmedOn;
  bool get pregnancyConfirmed => _pregnancyConfirmedOn != null;

  /// Whether the partner has paired into this journey. TTC is a two-person
  /// experience, and several surfaces read differently once he is here.
  bool get partnerJoined => _partnerJoined;

  /// How long they have been trying, in whole days.
  int? get daysTrying {
    final s = journeyStart;
    if (s == null) return null;
    final d = DateTime.now().difference(DateTime(s.year, s.month, s.day)).inDays;
    return d < 0 ? 0 : d;
  }

  /// THE call every TTC screen makes. Chapter, cycle day, ovulation estimate,
  /// confidence and fertility level, resolved together and consistently.
  TtcToday get today => _engine.resolve(state());

  /// The chapter the PARTNER's account reports, read from their ttc_journeys
  /// row. This is the whole mechanism the privacy design rests on: he needs to
  /// know which chapter the couple is in, and he must never be able to read her
  /// cycle to work it out. She publishes the derived answer; he reads that.
  ///
  /// Null when unpaired, logged out, or before the first sync.
  TtcChapter? get partnerChapter => _partnerChapter;
  TtcChapter? _partnerChapter;

  /// What a screen should actually display. His app shows her chapter; hers
  /// shows her own.
  TtcChapter get displayChapter => _partnerChapter ?? today.chapter;

  /// The engine input. Exposed so tests (and the Journey Map, which needs to
  /// resolve other days) can reuse it with an injected date.
  TtcJourneyState state({DateTime? on}) => cycleStateFrom(
        cycle: CycleStore.instance,
        journeyStart: journeyStart,
        pregnancyConfirmed: pregnancyConfirmed,
        // The one fertility rule: who owns the timing. Since 2026-09-26, real
        // clinic dates for this cycle; the pathway and her two answers pick
        // the tier. Never the treatment name alone.
        ownership: ownership,
        today: on,
        statedCycleLength: _statedLength,
      );

  // ---- writes ---------------------------------------------------------------

  void setJourneyStart(DateTime day) {
    _journeyStart = DateTime(day.year, day.month, day.day);
    _persist();
    notifyListeners();
  }

  /// Changing the pathway CLEARS her two answers on purpose.
  ///
  /// They were about the old cycle - "yes my clinic scans me" is not
  /// transferable from an IUI round to trying naturally afterwards, and a stale
  /// yes would silently keep her fertility window switched off.
  void setPath(TtcPath path) {
    if (_path == path) return;
    _path = path;
    _clinicMonitors = null;
    _medicated = null;
    _persist();
    notifyListeners();
  }

  /// "Is your clinic tracking this cycle with scans or blood tests?"
  void setClinicMonitors(bool? value) {
    if (_clinicMonitors == value) return;
    _clinicMonitors = value;
    _persist();
    notifyListeners();
  }

  /// "Are you taking medication that controls WHEN you ovulate?"
  void setMedicationControlsOvulation(bool? value) {
    if (_medicated == value) return;
    _medicated = value;
    _persist();
    notifyListeners();
  }

  /// Records the usual cycle length she stated. Null clears it.
  void setStatedCycleLength(int? days) {
    if (_statedLength == days) return;
    _statedLength = days;
    _persist();
    notifyListeners();
  }

  void setPartnerJoined(bool joined) {
    if (_partnerJoined == joined) return;
    _partnerJoined = joined;
    _persist();
    notifyListeners();
  }

  /// Records a positive pregnancy test. This is the single most important write
  /// in the stage - Phase 7's Transition Engine hangs off it. Deliberately does
  /// NOT itself flip the life stage or touch pregnancy data: that hand-off is
  /// the Transition Engine's job, and splitting them keeps this store honest
  /// about only recording what the couple told us.
  void confirmPregnancy({DateTime? on}) {
    final d = on ?? DateTime.now();
    _pregnancyConfirmedOn = DateTime(d.year, d.month, d.day);
    _persist();
    notifyListeners();
  }

  /// Undo, because a test can be mis-tapped and this one matters too much to
  /// be one-way.
  void clearPregnancyConfirmation() {
    if (_pregnancyConfirmedOn == null) return;
    _pregnancyConfirmedOn = null;
    _persist();
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _journeyStart = null;
    _path = TtcPath.natural;
    _clinicMonitors = null;
    _medicated = null;
    _statedLength = null;
    _pregnancyConfirmedOn = null;
    _partnerJoined = false;
    _partnerChapter = null;
    _loaded = true;
    notifyListeners();
  }

  // ---- persistence ----------------------------------------------------------

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _journeyStart = DateTime.tryParse(p.getString(_startKey) ?? '');
      _pregnancyConfirmedOn =
          DateTime.tryParse(p.getString(_confirmedKey) ?? '');
      _partnerJoined = p.getBool(_partnerKey) ?? false;
      // Nullable on purpose: "not answered" is a real third state, distinct
      // from "answered no", and the pathway default fills in until she says.
      _clinicMonitors = p.getBool(_monitorsKey);
      _medicated = p.getBool(_medicatedKey);
      _statedLength = p.getInt(_statedLengthKey);
      final raw = p.getString(_pathKey);
      _path = TtcPath.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => TtcPath.natural,
      );
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  // ---- cloud ----------------------------------------------------------------
  //  ttc_journeys is COUPLE-SCOPED: both partners read both rows, and each may
  //  only write their own. It is also the one TTC table where last-write-wins
  //  is right - it holds a handful of settings, not a log.

  @override
  Future<void> pullFromCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    // fetchShared, not fetch: RLS returns my row AND my partner's.
    final rows = await SupabaseRepo.fetchShared(TtcTables.journeys,
        orderBy: 'updated_at');

    for (final row in rows) {
      if (row['user_id'] == uid) {
        _journeyStart = TtcSyncUtil.parseDate(row['journey_start']);
        _pregnancyConfirmedOn =
            TtcSyncUtil.parseDate(row['pregnancy_confirmed_on']);
        _partnerJoined = row['partner_joined'] == true;
        // Nullable in the column too - "not asked" must survive a round-trip.
        _clinicMonitors = row['clinic_monitors'] as bool?;
        _medicated = row['medication_controls'] as bool?;
        _path = TtcPath.values.firstWhere(
          (e) => e.name == row['path'],
          orElse: () => TtcPath.natural,
        );
      } else {
        // The partner's published chapter - the only thing we read from their
        // row, and the reason her cycle never has to be shared.
        _partnerChapter = TtcChapter.values
            .where((c) => c.name == row['current_chapter'])
            .firstOrNull;
      }
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    final start = _journeyStart ?? LifeStageStore.instance.enteredAt;
    await SupabaseRepo.upsertRow(
      TtcTables.journeys,
      {
        'user_id': uid,
        'journey_start': start == null ? null : TtcSyncUtil.date(start),
        'path': _path.name,
        'pregnancy_confirmed_on': _pregnancyConfirmedOn == null
            ? null
            : TtcSyncUtil.date(_pregnancyConfirmedOn!),
        'partner_joined': _partnerJoined,
        'clinic_monitors': _clinicMonitors,
        'medication_controls': _medicated,
        // Derived, but published so the partner can render it without reading
        // her cycle - the same reason current_chapter is on this row.
        'timing_ownership': ownership.id,
        // Publish the DERIVED chapter so the partner can render it without ever
        // reading a cycle date.
        'current_chapter': today.chapter.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = _journeyStart;
      if (s == null) {
        await p.remove(_startKey);
      } else {
        await p.setString(_startKey, s.toIso8601String());
      }
      final c = _pregnancyConfirmedOn;
      if (c == null) {
        await p.remove(_confirmedKey);
      } else {
        await p.setString(_confirmedKey, c.toIso8601String());
      }
      await p.setString(_pathKey, _path.name);
      await p.setBool(_partnerKey, _partnerJoined);
      // remove(), not setBool(false) - "not answered" must survive a restart.
      if (_clinicMonitors == null) {
        await p.remove(_monitorsKey);
      } else {
        await p.setBool(_monitorsKey, _clinicMonitors!);
      }
      if (_medicated == null) {
        await p.remove(_medicatedKey);
      } else {
        await p.setBool(_medicatedKey, _medicated!);
      }
      if (_statedLength == null) {
        await p.remove(_statedLengthKey);
      } else {
        await p.setInt(_statedLengthKey, _statedLength!);
      }
    } catch (_) {/* best-effort */}
  }
}

// TtcPathCopy moved to ttc_care_pathway.dart alongside the pathway itself.

/// The day she started trying, from her onboarding answer to "How long have you
/// been trying?" (ids `starting`, `months`, `six`, `year`), counted back from
/// the day she entered the stage. Each answer at its low end. Null when there is
/// no answer or no day to count from.
DateTime? ttcStartFromAnswer(String? answer, DateTime? answeredAround) {
  if (answeredAround == null) return null;
  final months = switch (answer) {
    'starting' => 0,
    'months' => 3,
    'six' => 6,
    'year' => 12,
    _ => null,
  };
  if (months == null) return null;
  final d = answeredAround.subtract(Duration(days: (months * 30.44).round()));
  return DateTime(d.year, d.month, d.day);
}

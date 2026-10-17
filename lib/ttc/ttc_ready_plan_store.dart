// =============================================================================
//  TtcReadyPlanStore — what the Ready-to-Try plan keeps, and nothing else
// -----------------------------------------------------------------------------
//  ⚠️ IT OWNS ONLY WHAT NO OTHER STORE HOLDS: the month they want to start
//  trying, her region, his answers and whether she wants the monthly note.
//  Every answer another store already owns is written THROUGH to that store
//  rather than kept here as a copy:
//
//    · her age band   → `TtcFertilityHelpStore` (every TTC tool shares it);
//    · how she eats   → `FamilyProfileStore.diet`, and the food tool's kitchen;
//    · folic acid     → the checklist's own `folate` item.
//
//  The answers object below still carries those three, because the plan is
//  built from one object and the form edits one object. But on load the
//  owners win: if she changed her diet in her profile last week, the plan
//  reads the profile, not what she told the plan a month ago. Same rule as
//  the truth hierarchy: one fact, one home.
//
//  ⚠️ SYNCED SINCE 2026-10-17 (Onboarding V3, migration 0102). One row per
//  person in `ttc_ready_plans`, couple-readable, own-row writes. A real table
//  and not the `user_state` blob, because his side needs to read her plan and
//  the blob has no partner read. Kept for revert, the old note:
//    LOCAL ONLY, FOR NOW. The plan is hers and lives on the phone. Cloud
//    sync would follow the checklist's `CloudSyncedStore` pattern [...]
//  Newer wins on `updated_at`, the time of the edit on the phone (not the
//  upload time), checked here on a pull and on the server by 0100's guard.
//  The monthly-note switch is NOT synced: it schedules notes on this phone.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/family_profile.dart';
import '../services/notification_service.dart';
import '../services/remote/supabase_repo.dart';
import 'ttc_fertility_help_store.dart';
import 'ttc_precheck_data.dart';
import 'ttc_precheck_rules.dart';
import 'ttc_precheck_store.dart';
import 'ttc_ready_plan.dart';
import 'ttc_sync.dart';

/// The food tool's saved kitchen. The same string as `kTtcFoodKitchenKey` in
/// `ttc_nutrition_screen.dart`, which a store in `lib/ttc` must not import;
/// `test/ttc_ready_plan_test.dart` holds the two equal.
const String kReadyKitchenPrefKey = 'ttc_food_kitchen_v1';

/// The cloud table (0102).
const String kReadyPlansTable = 'ttc_ready_plans';

class TtcReadyPlanStore extends ChangeNotifier with TtcSyncedStore {
  TtcReadyPlanStore._();
  static final TtcReadyPlanStore instance = TtcReadyPlanStore._();

  static const String _key = 'ttc_ready_plan_v1';

  ReadyPlanAnswers? _answers;
  DateTime? _madeAt;
  bool _notify = false;
  bool _loaded = false;

  /// When the answers last changed ON A PHONE. Null = never edited here.
  DateTime? _editedAt;
  void _edited() => _editedAt = DateTime.now();

  bool get isLoaded => _loaded;

  /// A copy of her saved answers, or null before she has made a plan.
  ReadyPlanAnswers? get answers => _answers?.copy();

  /// When she last asked to see her plan.
  DateTime? get madeAt => _madeAt;

  /// Whether the 1st-of-the-month note is on. Off until she turns it on.
  bool get notify => _notify;

  /// The month they want to start trying, if she has picked one.
  ///
  /// ⚠️ READ BY `TtcStore.journeyStart` ONCE THAT CHANGE LANDS (see the
  /// Ready-to-Try build plan): a couple who are planning must not start the
  /// "how long have you been trying" clock before they try.
  DateTime? get plannedStart {
    final a = _answers;
    if (a == null || a.alreadyTrying) return null;
    return a.target;
  }

  /// The plan for today, or null when there is none.
  ///
  /// ⚠️ NULL UNTIL SHE HAS ASKED FOR ONE (`madeAt`). A month set by the
  /// first-run flow is an answer, not a plan: the screen opens on the
  /// questions with that month filled in.
  ReadyPlan? planFor(DateTime now) {
    final a = _answers;
    if (a == null || _madeAt == null) return null;
    return buildReadyPlan(a, now: now);
  }

  /// She has said she is planning but has not made a plan yet: the home's
  /// "next step" offers one.
  bool get planOwed => _madeAt == null && plannedStart != null;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, Object?>;
        final saved =
            (j['answers'] as Map?)?.cast<String, Object?>() ?? const {};
        // An empty object is a cleared plan kept for its edit time.
        _answers = saved.isEmpty ? null : ReadyPlanAnswers.fromJson(saved);
        _madeAt = DateTime.tryParse(j['madeAt'] as String? ?? '');
        _notify = j['notify'] == true;
        _editedAt = DateTime.tryParse(j['editedAt'] as String? ?? '');
      }
    } catch (_) {
      /* local-first: no plan is a fine answer */
    }
    notifyListeners();
    await syncFromCloud();
  }

  // ---- cloud (0102) ---------------------------------------------------------

  @override
  Future<void> pullFromCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    final rows = await SupabaseRepo.fetchShared(kReadyPlansTable,
        orderBy: 'updated_at');
    for (final row in rows) {
      // Only her own row for now. The partner's row is what his plan card
      // will read (STILL-OPEN §92.0); nothing reads it yet, so nothing keeps it.
      if (row['user_id'] != uid) continue;
      final cloudAt = DateTime.tryParse('${row['updated_at']}');
      final local = _editedAt;
      if (cloudAt == null || (local != null && !cloudAt.isAfter(local))) continue;
      final raw = (row['answers'] as Map?)?.cast<String, Object?>() ?? const {};
      _answers = raw.isEmpty ? null : ReadyPlanAnswers.fromJson(raw);
      _madeAt = DateTime.tryParse('${row['made_at']}')?.toLocal();
      _editedAt = cloudAt.toLocal();
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    final at = _editedAt;
    // Nothing ever edited here: nothing of ours to send.
    if (uid == null || at == null) return;
    final a = _answers;
    final start = plannedStart;
    await SupabaseRepo.upsertRow(
      kReadyPlansTable,
      {
        'user_id': uid,
        'planned_start': start == null ? null : TtcSyncUtil.date(start),
        'already_trying': a?.alreadyTrying ?? false,
        // A cleared plan is an edit too: an empty object, so another phone
        // clears it as well instead of keeping the old one.
        'answers': a?.toJson() ?? const <String, Object?>{},
        'made_at': _madeAt?.toUtc().toIso8601String(),
        'updated_at': TtcSyncUtil.stamp(at),
      },
      onConflict: 'user_id',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  @override
  void resetLocal() {
    _answers = null;
    _madeAt = null;
    _notify = false;
    _editedAt = null;
  }

  /// Saves her answers and writes the shared ones through to their owners.
  Future<void> save(ReadyPlanAnswers a, {DateTime? now}) async {
    _answers = a.copy();
    _madeAt = now ?? DateTime.now();
    _edited();
    notifyListeners();
    await _persist();
    await _writeThrough(a);
    if (_notify) await _schedule();
  }

  /// The month they want to start trying, from the TTC first-run flow
  /// ("Not yet, we're getting ready"), before any plan exists.
  ///
  /// ⚠️ ONLY THE MONTH, NOT A PLAN. It sets the answer the plan's first
  /// question would ask, so the plan opens with it filled in, and it moves
  /// `TtcStore.journeyStart`. `madeAt` stays null: she has not asked for a
  /// plan yet, and the home offers her one.
  Future<void> setPlannedStart(DateTime? month) async {
    final a = _answers ?? ReadyPlanAnswers();
    a.target = month == null ? null : readyMonthOf(month);
    a.alreadyTrying = false;
    _answers = a;
    _edited();
    notifyListeners();
    await _persist();
    if (_notify) await _schedule();
  }

  /// His part, from his own onboarding (Onboarding V3, 2026-10-17): his age
  /// band and habits, the plan's own two questions for him.
  ///
  /// ⚠️ ANSWERS, NOT A PLAN, exactly like [setPlannedStart]: `madeAt` stays
  /// null, so the plan opens on its questions with his part filled in.
  Future<void> setHisAnswers({HisAge? age, Set<HisHabit>? habits}) async {
    final a = _answers ?? ReadyPlanAnswers();
    if (age != null) a.hisAge = age;
    if (habits != null) {
      a.hisHabits
        ..clear()
        ..addAll(habits);
      a.hisHabitsAnswered = true;
    }
    _answers = a;
    _edited();
    notifyListeners();
    await _persist();
  }

  /// "Clear my plan", with the old one handed back for Undo.
  Future<({ReadyPlanAnswers? answers, DateTime? madeAt, bool notify})>
  clear() async {
    final was = (answers: _answers, madeAt: _madeAt, notify: _notify);
    _answers = null;
    _madeAt = null;
    _notify = false;
    _edited();
    notifyListeners();
    await _persist();
    await _cancelNotes();
    return was;
  }

  Future<void> restore(
    ({ReadyPlanAnswers? answers, DateTime? madeAt, bool notify}) was,
  ) async {
    _answers = was.answers;
    _madeAt = was.madeAt;
    _notify = was.notify;
    _edited();
    notifyListeners();
    await _persist();
    if (_notify) await _schedule();
  }

  /// Turns the monthly note on or off.
  Future<void> setNotify(bool on) async {
    _notify = on;
    notifyListeners();
    await _persist();
    if (on) {
      await NotificationService.instance.requestPermission();
      await _schedule();
    } else {
      await _cancelNotes();
    }
  }

  /// The prefills: what the app already knows, as answers she can change.
  ///
  /// ⚠️ CONFIRMATIONS, NOT ASSUMPTIONS. Each one shows selected and
  /// changeable. A prefill she could not override would be a claim.
  ReadyPlanAnswers prefilled() {
    final a = answers ?? ReadyPlanAnswers();
    final profile = FamilyProfileStore.instance;

    a.age = TtcFertilityHelpStore.instance.ageBand ?? a.age;
    a.diet = readyDietFrom(profile.diet) ?? a.diet;

    if (!a.conditionsAnswered) {
      final known = {
        if (profile.hasPregCondition(PregCondition.pcos)) ReadyCondition.pcos,
        if (profile.hasPregCondition(PregCondition.thyroid))
          ReadyCondition.thyroid,
        if (profile.hasPregCondition(PregCondition.anemia))
          ReadyCondition.anaemia,
      };
      if (known.isNotEmpty) {
        a.conditions.addAll(known);
        a.conditionsAnswered = true;
      }
    }

    final c = PrecheckContext.gather();
    a.folic =
        switch (TtcPrecheckStore.instance.statusOf('folate', c)) {
          PrecheckStatus.done => ReadyFolic.yes,
          PrecheckStatus.needsAttention => ReadyFolic.notYet,
          PrecheckStatus.notSure => ReadyFolic.notSure,
          _ => null,
        } ??
        switch (profile.otherFor('ttc_folic')) {
          'yes' => ReadyFolic.yes,
          'no' => ReadyFolic.notYet,
          _ => null,
        } ??
        a.folic;
    return a;
  }

  Future<void> _writeThrough(ReadyPlanAnswers a) async {
    try {
      final age = a.age;
      if (age != null) await TtcFertilityHelpStore.instance.setAgeBand(age);

      final diet = a.diet;
      if (diet != null) {
        final pref = switch (diet) {
          ReadyDiet.veg => DietPreference.vegetarian,
          ReadyDiet.eggs => DietPreference.eggetarian,
          ReadyDiet.nonVeg => DietPreference.nonVegetarian,
          ReadyDiet.jain => DietPreference.jain,
        };
        // A vegan profile reads as vegetarian here; do not overwrite it with
        // the nearer answer the plan offered.
        if (FamilyProfileStore.instance.diet != DietPreference.vegan ||
            diet != ReadyDiet.veg) {
          FamilyProfileStore.instance.setDiet(pref);
        }
        final p = await SharedPreferences.getInstance();
        await p.setString(kReadyKitchenPrefKey, diet.kitchen.name);
      }

      final folic = a.folic;
      if (folic != null) {
        final want = switch (folic) {
          ReadyFolic.yes => PrecheckStatus.done,
          ReadyFolic.notYet => PrecheckStatus.needsAttention,
          ReadyFolic.notSure => PrecheckStatus.notSure,
        };
        final store = TtcPrecheckStore.instance;
        await store.load();
        if (store.statusOf('folate', PrecheckContext.gather()) != want) {
          await store.setStatus('folate', want);
        }
      }
    } catch (_) {
      /* best-effort: the plan itself is already saved */
    }
  }

  // ---- the monthly note -------------------------------------------------------
  //
  // ⚠️ ONE-OFFS, NOT A REPEATING ALARM. A repeat would carry on past her month
  // and into pregnancy. One note on the 1st of each month up to her month,
  // rescheduled whenever the plan changes, ends where the plan ends.

  static const int _maxNotes = 13;
  int _noteId(int i) => ('ttc_ready_plan#$i').hashCode & 0x7fffffff;

  Future<void> _schedule() async {
    await _cancelNotes();
    final target = plannedStart;
    if (target == null) return;
    final now = DateTime.now();
    for (var i = 1; i < _maxNotes; i++) {
      final first = DateTime(now.year, now.month + i, 1, 9);
      if (first.isAfter(DateTime(target.year, target.month, 1, 9))) break;
      final isTarget = first.year == target.year && first.month == target.month;
      await NotificationService.instance.scheduleOneOff(
        id: _noteId(i),
        title: isTarget ? 'Your month is here' : 'Your plan for this month',
        body: isTarget
            ? 'Open your Ready-to-Try plan for what still matters while you try.'
            : 'A few small things for ${readyMonthLabel(first)}. Open your '
                  'Ready-to-Try plan.',
        when: first,
      );
    }
  }

  Future<void> _cancelNotes() async {
    for (var i = 1; i < _maxNotes; i++) {
      await NotificationService.instance.cancel(_noteId(i));
    }
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      final a = _answers;
      // ⚠️ A CLEARED PLAN KEEPS ITS EDIT TIME, so the clear can win over an
      // older cloud copy. Before sync it simply removed the key (kept for
      // revert): if (a == null) { await p.remove(_key); return; }
      if (a == null && _editedAt == null) {
        await p.remove(_key);
        return;
      }
      await p.setString(
        _key,
        jsonEncode({
          'answers': a?.toJson() ?? const <String, Object?>{},
          'madeAt': _madeAt?.toIso8601String(),
          'notify': _notify,
          'editedAt': _editedAt?.toIso8601String(),
        }),
      );
    } catch (_) {
      /* best-effort */
    }
  }

  /// Testing only. Not `@visibleForTesting`: `TtcStore.resetForTest` calls
  /// it, the same shape every TTC store's reset has.
  void resetForTest() {
    _answers = null;
    _madeAt = null;
    _notify = false;
    _loaded = false;
  }
}

/// Her profile's diet as the plan's answer. Vegan reads as vegetarian, the
/// nearest plate the week of meals has.
ReadyDiet? readyDietFrom(DietPreference? d) => switch (d) {
  DietPreference.vegetarian || DietPreference.vegan => ReadyDiet.veg,
  DietPreference.eggetarian => ReadyDiet.eggs,
  DietPreference.nonVegetarian => ReadyDiet.nonVeg,
  DietPreference.jain => ReadyDiet.jain,
  null => null,
};

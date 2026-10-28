// =============================================================================
//  PregnancyEndedStore — "If your pregnancy has ended" (2026-09-29)
// -----------------------------------------------------------------------------
//  The pregnancy gap analysis's second most urgent finding: "If her pregnancy
//  ends, the app has no way to be told. It keeps showing her baby growing week
//  by week." What to Expect has "Report a Loss" in its top menu; Oura keeps a
//  quiet "My pregnancy ended" row in its pregnancy details. This is ours.
//
//  ONE BOOLEAN, LOCAL-FIRST, AND NOTHING IS DELETED.
//
//  When she confirms, the Today tab (hers, and his on the partner side) shows
//  the After a loss home instead of the baby home: no week, no size, no daily
//  tip. Her journal, bump photos, reports and saved items are untouched, and
//  the same row in You undoes it, because a mistaken tap on this of all
//  switches must cost nothing.
//
//  The trade-off, named: a flag rather than a stage. Making "after a loss" a
//  fourth life stage would give it its own tabs and state, and would also be
//  a second way to leave pregnancy that every stage-aware screen would need to
//  learn. A flag inside pregnancy costs two call sites (the two Today pages)
//  and cannot strand anyone in a stage nothing else knows about.
//
//  Cloud sync is owed (docs/STILL-OPEN.md): today it lives on this phone,
//  which is the safe failure (a new phone shows the pregnancy again, and the
//  row is one tap away).
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/pending_profile.dart';
import 'life_stage_store.dart';
import 'partner_side.dart';
import 'pregnancy_controller.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

// IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log, migration 0110). This
// lived only on her phone, so a new phone, or the same phone after a
// sign-out, went back to showing a baby growing week by week after a loss.
// It is now `profiles.pregnancy_ended_at` (null = not ended), written through
// PendingProfile.send (confirmed, kept and retried when it fails) and read
// back on every sync. 0009 lets a linked partner read her profile, so his
// app can respect it too.
class PregnancyEndedStore extends ChangeNotifier {
  PregnancyEndedStore._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final PregnancyEndedStore instance = PregnancyEndedStore._();

  static const String kColumn = 'pregnancy_ended_at';

  /// Set once this phone's answer has met the cloud's (step 13). Before that,
  /// a phone that already holds "ended" sends it up rather than taking the
  /// cloud's empty column, which would quietly undo what she told us.
  static const String kCloudKey = 'pregnancy_ended_cloud_v1';

  bool _registered = false;

  /// Reads her profile's answer and takes it, unless this phone holds a
  /// change still waiting to go up.
  Future<void> syncFromCloud() async {
    if (!_registered) {
      _registered = true;
      SyncRegistry.register(syncFromCloud);
    }
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final pending = await PendingProfile.load();
      if (pending != null && pending.containsKey(kColumn)) return;
      // ⚠️ ON HIS PAIRED PHONE, HER ROW (R2, 2026-10-25): it is her loss,
      // told on her phone. His Today swaps on it, and his phone never sends
      // the column (the seeding below is skipped). Kept for revert:
      //   final row = await SupabaseRepo.fetchMyProfile(kColumn);
      final read = await PartnerSide.readStageRow(kColumn);
      final row = read.row;
      if (row == null) return; // offline or unreadable: keep what we have
      final prefs = await SharedPreferences.getInstance();
      if (read.hers) {
        final at = row[kColumn] == null ? null : SupabaseRepo.parseDbTime(row[kColumn]);
        if ((at != null) == _ended && at == _endedAt) return;
        _ended = at != null;
        _endedAt = at;
        notifyListeners();
        await _persist();
        return;
      }
      final cloudAt = row[kColumn] == null
          ? null
          : SupabaseRepo.parseDbTime(row[kColumn]);
      if (!(prefs.getBool(kCloudKey) ?? false)) {
        if (_ended && cloudAt == null) {
          await PendingProfile.send(
              {kColumn: SupabaseRepo.dbTime(_endedAt ?? DateTime.now())});
          await prefs.setBool(kCloudKey, true);
          return;
        }
        await prefs.setBool(kCloudKey, true);
      }
      final ended = cloudAt != null;
      if (ended == _ended && cloudAt == _endedAt) return;
      _ended = ended;
      _endedAt = cloudAt;
      notifyListeners();
      await _persist();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kEndedKey, _ended);
      if (_ended && _endedAt != null) {
        await prefs.setString(kEndedAtKey, _endedAt!.toIso8601String());
      } else {
        await prefs.remove(kEndedAtKey);
      }
    } catch (_) {}
  }

  static const String kEndedKey = 'pregnancy_ended_v1';
  static const String kEndedAtKey = 'pregnancy_ended_at_v1';

  bool _loaded = false;
  bool _ended = false;
  DateTime? _endedAt;

  /// True once she has told ParentVeda her pregnancy has ended.
  ///
  /// ⚠️ SCOPED TO THE PREGNANCY IT ENDED (2026-10-24, STAGE-TRANSITIONS B1b).
  /// The flag is never cleared by a later pregnancy - the loss and its date
  /// stay recorded - but it only SPEAKS for the pregnancy it ended. After a
  /// loss, trying again and a new positive test, the pregnancy stage has a
  /// newer entry date than the loss, so this reads false and the new
  /// pregnancy's Today, messages and You row are hers again. Deriving it
  /// rather than clearing it means no move can forget to clear it, and the
  /// cloud rule (migration 0112, `pregnancy_ended_at < life_stage_at`) reads
  /// the same two facts. Outside pregnancy it reads as before.
  /// Kept for revert: `bool get ended => _ended;`
  bool get ended {
    if (!_ended) return false;
    final at = _endedAt;
    final stage = LifeStageStore.instance;
    final since = stage.enteredAt;
    if (at == null || since == null || stage.stage != LifeStage.pregnancy) {
      return true;
    }
    return !since.isAfter(at);
  }

  /// The raw answer, whichever pregnancy it was about: true once a loss has
  /// been reported and not undone. For history, never for what Today shows.
  bool get lossRecorded => _ended;

  /// True once [load] has run, so a reader can tell "not ended" from "not
  /// known yet" (the pregnancy messages wait for it, 2026-09-30).
  bool get isLoaded => _loaded;

  /// When she said so, for "take things slowly" copy; never shown as a count.
  DateTime? get endedAt => _endedAt;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _ended = prefs.getBool(kEndedKey) ?? false;
      final at = prefs.getString(kEndedAtKey);
      _endedAt = at == null ? null : DateTime.tryParse(at);
      notifyListeners();
    } catch (_) {
      // Storage failing must never show a loss she did not report.
    }
    await syncFromCloud();
  }

  Future<void> markEnded() => _set(true);

  /// "Go back to my pregnancy view": the undo, from the same You row.
  Future<void> undo() => _set(false);

  Future<void> _set(bool v) async {
    _ended = v;
    _endedAt = v ? DateTime.now() : null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kEndedKey, v);
      if (v) {
        await prefs.setString(kEndedAtKey, _endedAt!.toIso8601String());
      } else {
        await prefs.remove(kEndedAtKey);
      }
    } catch (_) {}
    // Kept, and retried on the next sync, when it cannot go up now.
    await PendingProfile.send(
        {kColumn: v ? SupabaseRepo.dbTime(_endedAt!) : null});
  }

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  void _resetForAccount() {
    resetForTest();
    notifyListeners();
  }

  /// Tests only.
  @visibleForTesting
  void resetForTest() {
    _loaded = false;
    _ended = false;
    _endedAt = null;
  }
}

/// The week the pregnancy ended, or null while it goes on (P2, 2026-10-28).
/// Worked out from the due date, the same way every week is, so the Journal
/// and Bump stop their week clocks at the same place.
int? pregnancyEndWeek(PregnancyController p) {
  final store = PregnancyEndedStore.instance;
  final at = store.ended ? store.endedAt : null;
  if (at == null) return null;
  final start =
      p.dueDate.subtract(const Duration(days: PregnancyController.termDays));
  return (at.difference(start).inDays ~/ 7 + 1).clamp(1, 42);
}

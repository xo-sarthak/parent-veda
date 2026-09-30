// =============================================================================
//  TtcLogStore - one store behind every TTC tracker
// -----------------------------------------------------------------------------
//  Symptoms, weight, sleep, mood, stress, lifestyle, movement and partner
//  health all write here. One store, one shape, one merge strategy - so a new
//  tracker is a data definition rather than a new store to keep in sync.
//
//  A value is keyed by (tracker, field, day). Re-logging the same field on the
//  same day OVERWRITES rather than appending, because these are observations of
//  a day, not a stream of events - and a parent correcting a mis-tap should not
//  end up with two contradictory rows for the same afternoon.
//
//  Deliberately absent: goals, targets, streaks, averages presented as scores,
//  and any concept of a "good" value. This store records. It does not grade.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';
import 'ttc_sync.dart';

class TtcLogValue {
  const TtcLogValue({
    required this.tracker,
    required this.field,
    required this.dayKey,
    required this.value,
    this.note,
  });

  final String tracker;
  final String field;

  /// "yyyy-mm-dd".
  final String dayKey;
  final double value;
  final String? note;

  DateTime get day => DateTime.parse(dayKey);

  String get key => '$tracker/$field/$dayKey';
}

// =============================================================================
//  ⚠️ THE HABIT MERGE — 2026-09-04
// -----------------------------------------------------------------------------
//  Sleep, movement, stress and lifestyle became one `habits` tracker. This
//  store keys every row `tracker/field/day`, so the merge is a rename of the
//  first third of the key — and without this map, every night of sleep anybody
//  has already logged would still be in the file and invisible in the app.
//
//  ⚠️ IT IS APPLIED ON READ, NOT AS A ONE-OFF REWRITE, AND THAT IS THE WHOLE
//  DESIGN. A migrate-once-on-upgrade flag looks tidier and is wrong here for
//  two reasons:
//
//    1. The cloud table keys on the tracker id too. A device that migrated
//       locally would pull `sleep/hours/...` back from Postgres on the next
//       sync and the old rows would reappear, permanently, on every device
//       that had ever synced.
//    2. A one-off migration runs once and can only be got wrong once. This
//       runs every time, is idempotent, and a device that skipped the upgrade
//       — restored from a backup, reinstalled, whatever — is handled by the
//       same code path rather than by a flag nobody will remember to check.
//
//  The cost is that the old ids survive in `shared_preferences` and in
//  Postgres. That is deliberate: nothing is destroyed, and a revert is
//  deleting this map rather than restoring from a backup nobody took.
//
//  ⚠️ FIELD IDS WERE UNIQUE ACROSS ALL FOUR, which is the only reason this is
//  safe. `hours`, `quality`, `minutes`, `kind`, `stress`, `caffeine`,
//  `alcohol`, `smoking`, `water` — no two collided, so no row can land on
//  another. If a future merge is proposed where two field ids DO collide, this
//  approach does not work and the fields have to be renamed first.
// =============================================================================

const Map<String, String> kTtcHabitMerge = {
  'sleep': 'habits',
  'exercise': 'habits',
  'stress': 'habits',
  'lifestyle': 'habits',
};

/// The tracker id a row belongs under today.
String ttcMergedTracker(String tracker) =>
    kTtcHabitMerge[tracker] ?? tracker;

class TtcLogStore extends ChangeNotifier with TtcSyncedStore {
  TtcLogStore._() {
    _load();
  }
  static final TtcLogStore instance = TtcLogStore._();

  static const _key = 'ttc_logs';

  /// "tracker/field/yyyy-mm-dd" → value.
  final Map<String, TtcLogValue> _values = {};
  bool _loaded = false;

  // ---- tombstones (launch sanity H12, 2026-09-28) ---------------------------
  //
  // ⚠️ A CLEARED VALUE CAME BACK AFTER A RESTART. The walk saw "Log sex" and
  // mood "Energetic" on the running home, then "Sex logged" and "Calm" after
  // a cold start. The home was not stale (it listens to this store, and every
  // write notifies). The save was: `clear` deleted locally and fired ONE
  // delete at the cloud, and the pull on the next start is a union
  // (`putIfAbsent`). So any clear whose delete did not land came straight
  // back: offline, a network hiccup (the delete is fire-and-forget), or the
  // commonest case, Undo a second after logging, when the debounced push
  // that carried the value was already in flight and its upsert landed after
  // the delete.
  //
  // The general fix in a local-first store with a union merge is a
  // TOMBSTONE: remember "this key was deleted here" until the cloud agrees.
  // A cleared key is kept here (persisted), the pull skips it and deletes it
  // again, and it is forgotten only once a pull no longer sees the row, at
  // least a minute after the clear, so an upsert still in flight cannot
  // outlive it. Logging the key again removes its tombstone. The cost: a few
  // bytes per cleared value until the next sync, and a second delete call
  // when the first did not stick.
  static const _clearedKey = 'ttc_logs_cleared';

  /// Cleared keys → when they were cleared (ms since epoch).
  final Map<String, int> _cleared = {};

  @visibleForTesting
  Set<String> get clearedKeysForTest => Set.unmodifiable(_cleared.keys);

  bool get isLoaded => _loaded;

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---- reads ----------------------------------------------------------------

  TtcLogValue? valueFor(String tracker, String field, {DateTime? on}) =>
      _values['$tracker/$field/${dayKey(on ?? DateTime.now())}'];

  /// Every value recorded for a field, oldest first.
  List<TtcLogValue> history(String tracker, String field) {
    final out = _values.values
        .where((v) => v.tracker == tracker && v.field == field)
        .toList()
      ..sort((a, b) => a.dayKey.compareTo(b.dayKey));
    return List.unmodifiable(out);
  }

  /// The most recent value for a field, whenever it was recorded.
  TtcLogValue? latest(String tracker, String field) {
    final h = history(tracker, field);
    return h.isEmpty ? null : h.last;
  }

  /// Days on which anything at all was logged for this tracker, newest first.
  List<String> daysLogged(String tracker) {
    final days = _values.values
        .where((v) => v.tracker == tracker)
        .map((v) => v.dayKey)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return List.unmodifiable(days);
  }

  /// All fields recorded for a tracker on one day.
  List<TtcLogValue> valuesOn(String tracker, String dayKey) {
    final out = _values.values
        .where((v) => v.tracker == tracker && v.dayKey == dayKey)
        .toList()
      ..sort((a, b) => a.field.compareTo(b.field));
    return List.unmodifiable(out);
  }

  /// The same values as [valuesOn], in the order she logged them: oldest
  /// first, the latest last.
  ///
  /// `_values` is an insertion-ordered map. A new log appends; a clear
  /// removes the key, so logging it again appends it anew; changing a value
  /// in place keeps its slot. [valuesOn] sorts by field for stable displays,
  /// which is exactly wrong for "what did she log last" (2026-09-28: the
  /// home's "You logged today" card stayed on "Calm", the alphabetically
  /// early mood, after newer logs).
  List<TtcLogValue> valuesOnInLogOrder(String tracker, String dayKey) =>
      List.unmodifiable(_values.values
          .where((v) => v.tracker == tracker && v.dayKey == dayKey));

  bool hasAnythingFor(String tracker) =>
      _values.values.any((v) => v.tracker == tracker);

  /// A plain average over the last [days] days - used only to describe, never
  /// to score. Null when there is nothing to describe.
  double? recentAverage(String tracker, String field, {int days = 14}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final vals = history(tracker, field)
        .where((v) => v.day.isAfter(cutoff))
        .map((v) => v.value)
        .toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  // ---- writes ---------------------------------------------------------------

  void log(String tracker, String field, double value,
      {DateTime? on, String? note}) {
    final k = dayKey(on ?? DateTime.now());
    // Logged again: no longer deleted (H12).
    _cleared.remove('$tracker/$field/$k');
    _values['$tracker/$field/$k'] = TtcLogValue(
      tracker: tracker,
      field: field,
      dayKey: k,
      value: value,
      note: note,
    );
    _persist();
    notifyListeners();
  }

  void clear(String tracker, String field, {DateTime? on}) {
    final day = dayKey(on ?? DateTime.now());
    final k = '$tracker/$field/$day';
    if (_values.remove(k) == null) return;
    // H12: remember the delete until a pull shows the cloud has it too.
    _cleared[k] = DateTime.now().millisecondsSinceEpoch;
    _persist();
    // Clearing must reach the cloud explicitly - a union pull would bring the
    // cleared value straight back.
    if (SupabaseRepo.isLoggedIn) {
      SupabaseRepo.deleteMatch(TtcTables.logs, {
        'user_id': SupabaseRepo.userId!,
        'tracker': tracker,
        'field': field,
        'logged_on': day,
      }).catchError((_) {});
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _values.clear();
    _cleared.clear();
    _loaded = true;
    notifyListeners();
  }

  // ---- persistence ----------------------------------------------------------

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      for (final row in p.getStringList(_key) ?? const <String>[]) {
        try {
          final m = jsonDecode(row);
          if (m is! Map) continue;
          final v = TtcLogValue(
            // ⚠️ REMAPPED ON THE WAY IN. A row saved under `sleep` before the
            // habit merge is read back under `habits`, so nothing anybody
            // logged disappears. See `kTtcHabitMerge`.
            tracker: ttcMergedTracker(m['t'] as String),
            field: m['f'] as String,
            dayKey: m['d'] as String,
            value: (m['v'] as num).toDouble(),
            note: m['n'] as String?,
          );
          // ⚠️ `putIfAbsent`, NOT `[]=`. Two old rows can now land on one key —
          // for instance a device that logged `sleep/hours` and later logged
          // `habits/hours` on the same day. First one in wins, and since the
          // list is read in save order that is the newer write.
          _values.putIfAbsent(v.key, () => v);
        } catch (_) {/* a corrupt row is dropped, not fatal */}
      }
      final raw = p.getString(_clearedKey);
      if (raw != null) {
        final m = jsonDecode(raw);
        if (m is Map) {
          for (final e in m.entries) {
            if (e.value is num) _cleared[e.key.toString()] = (e.value as num).toInt();
          }
        }
      }
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  // ---- cloud ----------------------------------------------------------------
  //  OWN-ROW: each partner logs their own body, including the partner-health
  //  tracker, which he fills in on his own account.
  //
  //  The composite primary key (user, tracker, field, day) does the merge work
  //  for us - re-logging the same field on the same day overwrites in Postgres
  //  exactly as it does in memory.

  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetch(TtcTables.logs,
        orderBy: 'logged_on', ascending: true);
    // H12: which tombstoned keys the cloud still holds.
    final stillThere = <String>{};
    for (final row in rows) {
      final tracker = row['tracker'];
      final field = row['field'];
      final day = row['logged_on']?.toString();
      final value = row['value'];
      if (tracker is! String || field is! String || day == null) continue;
      if (value is! num) continue;
      // ⚠️ AND ON THE WAY IN FROM POSTGRES, for the reason written on
      // `kTtcHabitMerge`: the cloud table keys on the tracker id too, so
      // without this every sync would re-introduce the pre-merge ids.
      final merged = ttcMergedTracker(tracker);
      final key = '$merged/$field/$day';
      // ⚠️ DELETED HERE, SO NOT BROUGHT BACK (H12): skip it and ask the cloud
      // to delete it again, under the tracker id the row actually carries.
      if (_cleared.containsKey(key)) {
        stillThere.add(key);
        final uid = SupabaseRepo.userId;
        if (uid != null) {
          SupabaseRepo.deleteMatch(TtcTables.logs, {
            'user_id': uid,
            'tracker': tracker,
            'field': field,
            'logged_on': day,
          }).catchError((_) {});
        }
        continue;
      }
      // Union: a value logged offline is kept rather than overwritten by an
      // older cloud row for the same day.
      _values.putIfAbsent(
        key,
        () => TtcLogValue(
          tracker: merged,
          field: field,
          dayKey: day,
          value: value.toDouble(),
          note: row['note'] as String?,
        ),
      );
    }
    // A tombstone the cloud no longer holds is done, once no upsert from
    // before the clear can still be in flight (a minute is ample).
    final settled = DateTime.now().millisecondsSinceEpoch - 60000;
    _cleared.removeWhere((k, at) => !stillThere.contains(k) && at < settled);
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    await TtcSyncUtil.upsertAll(
      TtcTables.logs,
      [
        for (final v in _values.values)
          {
            'user_id': uid,
            'tracker': v.tracker,
            'field': v.field,
            'logged_on': v.dayKey,
            'value': v.value,
            if (v.note != null) 'note': v.note,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }
      ],
      onConflict: 'user_id,tracker,field,logged_on',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
        _key,
        _values.values
            .map((v) => jsonEncode({
                  't': v.tracker,
                  'f': v.field,
                  'd': v.dayKey,
                  'v': v.value,
                  if (v.note != null) 'n': v.note,
                }))
            .toList(),
      );
      await p.setString(_clearedKey, jsonEncode(_cleared));
    } catch (_) {/* best-effort */}
  }
}

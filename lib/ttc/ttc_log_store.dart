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

class TtcLogStore extends ChangeNotifier with TtcSyncedStore {
  TtcLogStore._() {
    _load();
  }
  static final TtcLogStore instance = TtcLogStore._();

  static const _key = 'ttc_logs';

  /// "tracker/field/yyyy-mm-dd" → value.
  final Map<String, TtcLogValue> _values = {};
  bool _loaded = false;

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
            tracker: m['t'] as String,
            field: m['f'] as String,
            dayKey: m['d'] as String,
            value: (m['v'] as num).toDouble(),
            note: m['n'] as String?,
          );
          _values[v.key] = v;
        } catch (_) {/* a corrupt row is dropped, not fatal */}
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
    for (final row in rows) {
      final tracker = row['tracker'];
      final field = row['field'];
      final day = row['logged_on']?.toString();
      final value = row['value'];
      if (tracker is! String || field is! String || day == null) continue;
      if (value is! num) continue;
      final key = '$tracker/$field/$day';
      // Union: a value logged offline is kept rather than overwritten by an
      // older cloud row for the same day.
      _values.putIfAbsent(
        key,
        () => TtcLogValue(
          tracker: tracker,
          field: field,
          dayKey: day,
          value: value.toDouble(),
          note: row['note'] as String?,
        ),
      );
    }
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
    } catch (_) {/* best-effort */}
  }
}

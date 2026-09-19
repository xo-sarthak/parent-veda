// =============================================================================
//  Is it safe? — what she asked, what her doctor said, what we could not answer
// -----------------------------------------------------------------------------
//  2026-09-19, the Is it safe? door. Three facts, two homes:
//
//  1. RECENTS — the last twenty things she looked up, newest first. Yuka's
//     History tab, in a row of chips under the field. Hers alone.
//  2. MY DOCTOR SAID — for one item, her clinician's call ("OK for me",
//     "avoid for me"). Hers alone, and the truth hierarchy made visible:
//     when it exists the answer page prints her doctor's line ABOVE ours,
//     because a treating clinician outranks ParentVeda's general note
//     (lib/services/truth_hierarchy.dart). We never edit the verdict itself.
//  3. MISSES — a query nothing matched. Not hers to read back; it is the
//     content desk's to-do list, so it goes to a TABLE (`can_i_misses`,
//     migration 0086) that the desk can count across every user.
//
//  ⚠️ WHY 1 AND 2 ARE A BLOB AND 3 IS A TABLE. `CloudSyncedStore` writes one
//  JSON blob per store into `user_state`, keyed by user — the right shape
//  when only the owner ever reads it and it is small (a few hundred bytes
//  here). A table is the right shape when someone ELSE needs the rows: a
//  desk counting "what did 400 women type that we had no answer for" cannot
//  do that over a per-user blob. Same data, two readers, two homes. The
//  pattern is written up in docs/BACKEND-PATTERNS.md.
//
//  Local-first, as everywhere: prefs first, cloud after, a failure is silent.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';
import 'remote/supabase_repo.dart';

/// Her clinician's call on one item. `ok` and `avoid` are the two things a
/// doctor says at a visit; a third state is the absence of a record.
enum CanIDoctorSaid { ok, avoid }

class CanIActivityStore extends ChangeNotifier with CloudSyncedStore {
  CanIActivityStore._();
  static final CanIActivityStore instance = CanIActivityStore._();

  static const String _recentsKey = 'cani_recents_v1';
  static const String _doctorKey = 'cani_doctor_v1';
  static const int kMaxRecents = 20;

  /// The misses table and the columns the client writes. Pinned by
  /// test/can_i_door_test.dart against migration 0086 — a fire-and-forget
  /// write cannot report a column-name mismatch, so a test must.
  static const String missesTable = 'can_i_misses';
  static const List<String> missesColumns = ['id', 'user_id', 'query', 'source', 'product', 'created_at'];

  SharedPreferences? _prefs;
  final List<String> _recents = [];
  final Map<String, CanIDoctorSaid> _doctor = {};
  bool _loaded = false;

  List<String> get recents => List.unmodifiable(_recents);
  bool get hasRecents => _recents.isNotEmpty;
  CanIDoctorSaid? doctorSaid(String entryId) => _doctor[entryId];

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    _prefs = await SharedPreferences.getInstance();
    _recents
      ..clear()
      ..addAll(_prefs?.getStringList(_recentsKey) ?? const []);
    final raw = _prefs?.getString(_doctorKey);
    if (raw != null) _applyDoctor(jsonDecode(raw));
    notifyListeners();
    await syncStateFromCloud();
  }

  /// She opened an answer. Newest first, no duplicates, capped.
  void touch(String entryId) {
    _recents
      ..remove(entryId)
      ..insert(0, entryId);
    if (_recents.length > kMaxRecents) _recents.removeRange(kMaxRecents, _recents.length);
    persistLocalCache();
    notifyListeners();
  }

  void clearRecents() {
    _recents.clear();
    persistLocalCache();
    notifyListeners();
  }

  /// Record, change or clear (null) her doctor's call on one item.
  void setDoctorSaid(String entryId, CanIDoctorSaid? said) {
    if (said == null) {
      _doctor.remove(entryId);
    } else {
      _doctor[entryId] = said;
    }
    persistLocalCache();
    notifyListeners();
  }

  /// Nothing matched what she typed, scanned or photographed. Best-effort,
  /// app-generated id (so a retry is an idempotent merge, not a duplicate).
  /// [source] is 'typed' | 'barcode' | 'photo'; [product] is what the
  /// barcode or the model said the thing was, when it said anything.
  Future<void> logMiss(String query, {required String source, String? product}) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    final now = DateTime.now().toUtc();
    final id = '${uid}_${now.millisecondsSinceEpoch}';
    await SupabaseRepo.upsertRow(missesTable, {
      'id': id,
      'user_id': uid,
      'query': q,
      'source': source,
      'product': product,
      'created_at': now.toIso8601String(),
    }).catchError((_) {});
  }

  // ---- CloudSyncedStore -----------------------------------------------------

  @override
  String get cloudKey => 'can_i_activity';

  @override
  Object cloudData() => {
        'recents': _recents,
        'doctor': {for (final e in _doctor.entries) e.key: e.value.name},
      };

  @override
  void applyCloudData(Object data) {
    if (data is! Map) return;
    final r = data['recents'];
    if (r is List) {
      _recents
        ..clear()
        ..addAll(r.whereType<String>().take(kMaxRecents));
    }
    _applyDoctor(data['doctor']);
  }

  void _applyDoctor(Object? raw) {
    if (raw is! Map) return;
    _doctor.clear();
    for (final e in raw.entries) {
      final v = CanIDoctorSaid.values.where((x) => x.name == e.value).firstOrNull;
      if (v != null) _doctor[e.key.toString()] = v;
    }
  }

  @override
  Future<void> persistLocalCache() async {
    final p = _prefs ??= await SharedPreferences.getInstance();
    await p.setStringList(_recentsKey, _recents);
    await p.setString(_doctorKey,
        jsonEncode({for (final e in _doctor.entries) e.key: e.value.name}));
  }

  /// Tests only — a clean store without prefs.
  @visibleForTesting
  void resetForTest() {
    _recents.clear();
    _doctor.clear();
  }
}

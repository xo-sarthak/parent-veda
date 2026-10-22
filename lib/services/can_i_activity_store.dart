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

import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)
import 'remote/supabase_repo.dart';

/// Her clinician's call on one item. `ok` and `avoid` are the two things a
/// doctor says at a visit; a third state is the absence of a record.
enum CanIDoctorSaid { ok, avoid }

// In the cloud per item since step 13 (2026-10-22, sync log). It synced as one
// whole blob before, so a doctor's call saved on one phone could be erased by
// a look-up on the other. Items: `r|<entryId>` = when she last opened it (ms),
// ordered by that and trimmed to [kMaxRecents] on apply; `d|<entryId>` = her
// doctor's call (`ok` / `avoid`).
class CanIActivityStore extends ChangeNotifier with CloudMergedStore {
  CanIActivityStore._();
  static final CanIActivityStore instance = CanIActivityStore._();

  static const String _recentsKey = 'cani_recents_v1';
  static const String _doctorKey = 'cani_doctor_v1';
  static const String _recentsAtKey = 'cani_recents_at_v1';
  static const int kMaxRecents = 20;

  /// The misses table and the columns the client writes. Pinned by
  /// test/can_i_door_test.dart against migration 0086 — a fire-and-forget
  /// write cannot report a column-name mismatch, so a test must.
  static const String missesTable = 'can_i_misses';
  static const List<String> missesColumns = ['id', 'user_id', 'query', 'source', 'product', 'created_at'];

  SharedPreferences? _prefs;
  final List<String> _recents = [];

  /// entryId -> when she last opened it (ms). Step 13: the recency is the
  /// item's value, so two phones' look-ups interleave by time.
  final Map<String, int> _recentAt = {};
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
    final at = _prefs?.getString(_recentsAtKey);
    if (at != null) {
      try {
        final m = jsonDecode(at);
        if (m is Map) {
          for (final e in m.entries) {
            if (e.value is num) _recentAt[e.key.toString()] = (e.value as num).toInt();
          }
        }
      } catch (_) {/* times are filled in below */}
    }
    _fillRecentTimes();
    notifyListeners();
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  /// She opened an answer. Newest first, no duplicates, capped.
  void touch(String entryId) {
    _recents
      ..remove(entryId)
      ..insert(0, entryId);
    _recentAt[entryId] = DateTime.now().millisecondsSinceEpoch;
    if (_recents.length > kMaxRecents) _recents.removeRange(kMaxRecents, _recents.length);
    _recentAt.removeWhere((k, _) => !_recents.contains(k));
    persistLocalCache();
    notifyListeners();
  }

  void clearRecents() {
    _recents.clear();
    _recentAt.clear();
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

  // ---- CloudMergedStore (step 13) -------------------------------------------

  @override
  String get cloudKey => 'can_i_activity';

  // Kept for revert (step 13): the whole-blob mixin's empty state and blob.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String, Object?>{'recents': <String>[], 'doctor': <String, String>{}};
  //
  //   @override
  //   Object cloudData() => {
  //         'recents': _recents,
  //         'doctor': {for (final e in _doctor.entries) e.key: e.value.name},
  //       };

  @override
  String? get legacyBlobKey => cloudKey;

  /// The old whole blob, read once on a phone that holds nothing yet.
  @override
  void applyLegacyBlob(Object blob) {
    final data = blob;
    if (data is! Map) return;
    final r = data['recents'];
    if (r is List) {
      _recents
        ..clear()
        ..addAll(r.whereType<String>().take(kMaxRecents));
    }
    _applyDoctor(data['doctor']);
    _recentAt.clear();
    _fillRecentTimes();
  }

  /// Recents read from an old list carry no time. Give them small ones in
  /// list order: older than any real look-up, and stable once given.
  void _fillRecentTimes() {
    _recentAt.removeWhere((k, _) => !_recents.contains(k));
    for (var i = 0; i < _recents.length; i++) {
      _recentAt.putIfAbsent(_recents[i], () => _recents.length - i);
    }
  }

  @override
  Map<String, Object?> cloudItems() => {
        for (final id in _recents) 'r|$id': _recentAt[id] ?? 0,
        for (final e in _doctor.entries) 'd|${e.key}': e.value.name,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _recents.clear();
    _recentAt.clear();
    _doctor.clear();
    for (final e in items.entries) {
      final k = e.key;
      if (k.startsWith('r|') && k.length > 2) {
        final v = e.value;
        _recentAt[k.substring(2)] = v is num ? v.toInt() : 0;
      } else if (k.startsWith('d|') && k.length > 2) {
        final v = CanIDoctorSaid.values.where((x) => x.name == e.value).firstOrNull;
        if (v != null) _doctor[k.substring(2)] = v;
      }
    }
    final ordered = _recentAt.keys.toList()
      ..sort((a, b) => _recentAt[b]!.compareTo(_recentAt[a]!));
    _recents.addAll(ordered.take(kMaxRecents));
    _recentAt.removeWhere((k, _) => !_recents.contains(k));
    _loaded = true; // a later init must not read stale prefs over this
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
    await p.setString(_recentsAtKey, jsonEncode(_recentAt));
  }

  /// Tests only — a clean store without prefs.
  @visibleForTesting
  void resetForTest() {
    _recents.clear();
    _recentAt.clear();
    _doctor.clear();
  }
}

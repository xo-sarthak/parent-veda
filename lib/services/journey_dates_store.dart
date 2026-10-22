// =============================================================================
//  JourneyDatesStore - per-mother ACTUAL dates for subjective journey events
// -----------------------------------------------------------------------------
//  Bump, kicks, scans, birth etc. happen on different dates for everyone
//  (premature / postmature deliveries, scans scheduled at varying dates, …), so
//  a single computed date can't be "true" for all. This lets the mother edit
//  WHEN a milestone actually happened; the override is shown on the map trail +
//  in the milestone card.
//
//  NOTE: for now only the displayed DATE changes - the node keeps its default
//  POSITION on the trail (re-anchoring the trail to edited dates can come later).
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)

// Per-item since step 13 (2026-10-22, sync log). It synced as one whole blob,
// so two phones that each set a different milestone date erased each other's.
// One item per milestone id, value = the date as an ISO string; clearing a
// date removes the item, and the removal travels.
class JourneyDatesStore extends ChangeNotifier with CloudMergedStore {
  JourneyDatesStore._();
  static final JourneyDatesStore instance = JourneyDatesStore._();

  static const _key = 'journey_dates';
  final Map<String, DateTime> _dates = {}; // milestoneId -> actual date
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        (jsonDecode(raw) as Map<String, dynamic>).forEach((id, v) {
          final d = DateTime.tryParse(v as String);
          if (d != null) _dates[id] = d;
        });
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'journey_dates';
  @override
  String? get legacyBlobKey => cloudKey;

  // Kept for revert (step 13): applyCloudItems({}) is the empty state now.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String, Object?>{};
  //
  //   @override
  //   Object cloudData() => _dates.map((k, v) => MapEntry(k, v.toIso8601String()));

  @override
  void applyLegacyBlob(Object blob) {
    _dates.clear();
    (blob as Map).forEach((id, v) {
      final d = DateTime.tryParse(v.toString());
      if (d != null) _dates[id.toString()] = d;
    });
  }

  @override
  Map<String, Object?> cloudItems() =>
      {for (final e in _dates.entries) e.key: e.value.toIso8601String()};

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _dates.clear();
    items.forEach((id, v) {
      final d = DateTime.tryParse(v.toString());
      if (d != null) _dates[id] = d;
    });
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() => _persist();

  /// The mother's override date for [id], or null if she hasn't set one.
  DateTime? dateFor(String id) => _dates[id];

  /// Whether this milestone's date has been edited by the mother.
  bool isEdited(String id) => _dates.containsKey(id);

  void setDate(String id, DateTime date) {
    _dates[id] = DateTime(date.year, date.month, date.day);
    _persistNotify();
  }

  void clear(String id) {
    if (_dates.remove(id) != null) _persistNotify();
  }

  /// Testing: wipe ALL edited milestone dates (resets the map to its defaults).
  void clearAll() {
    if (_dates.isEmpty) return;
    _dates.clear();
    _persistNotify();
  }

  void _persistNotify() {
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_dates.map((k, v) => MapEntry(k, v.toIso8601String()))),
      );
    } catch (_) {/* best-effort */}
  }
}

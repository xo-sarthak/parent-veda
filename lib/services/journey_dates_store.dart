// =============================================================================
//  JourneyDatesStore — per-mother ACTUAL dates for subjective journey events
// -----------------------------------------------------------------------------
//  Bump, kicks, scans, birth etc. happen on different dates for everyone
//  (premature / postmature deliveries, scans scheduled at varying dates, …), so
//  a single computed date can't be "true" for all. This lets the mother edit
//  WHEN a milestone actually happened; the override is shown on the map trail +
//  in the milestone card.
//
//  NOTE: for now only the displayed DATE changes — the node keeps its default
//  POSITION on the trail (re-anchoring the trail to edited dates can come later).
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JourneyDatesStore extends ChangeNotifier {
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
  }

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

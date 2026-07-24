// =============================================================================
//  DoctorAvailability — the times a doctor is free to be booked
// -----------------------------------------------------------------------------
//  A simple weekly pattern: which weekdays, and which time-of-day windows. This
//  is what SHOULD generate the real bookable slots (replacing the app's invented
//  ones). For now it persists locally per expert; the backend piece writes it to
//  booking_slots so parents see the doctor's true availability.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A bookable window on a given weekday, e.g. Mon 17:00 for 50 min.
@immutable
class AvailWindow {
  const AvailWindow(this.weekday, this.hour, this.minute);
  final int weekday; // DateTime.monday..sunday
  final int hour;
  final int minute;

  String get key => '$weekday-$hour-$minute';
  Map<String, Object?> toMap() =>
      {'weekday': weekday, 'hour': hour, 'minute': minute};
  static AvailWindow fromMap(Map d) => AvailWindow(
        (d['weekday'] as num).toInt(),
        (d['hour'] as num).toInt(),
        (d['minute'] as num).toInt(),
      );
}

class DoctorAvailability extends ChangeNotifier {
  DoctorAvailability._();
  static final DoctorAvailability instance = DoctorAvailability._();

  // expertId -> set of window keys.
  final Map<String, Set<String>> _byExpert = {};
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('doctor_avail_v1');
      if (raw != null) {
        final map = jsonDecode(raw) as Map;
        for (final entry in map.entries) {
          _byExpert[entry.key] =
              (entry.value as List).map((e) => e.toString()).toSet();
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  Set<String> _keys(String expertId) => _byExpert[expertId] ??= {};

  bool isOn(String expertId, AvailWindow w) => _keys(expertId).contains(w.key);

  void toggle(String expertId, AvailWindow w) {
    final keys = _keys(expertId);
    if (!keys.add(w.key)) keys.remove(w.key);
    _save();
    notifyListeners();
  }

  /// Count of windows set for this expert.
  int count(String expertId) => _keys(expertId).length;

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {for (final e in _byExpert.entries) e.key: e.value.toList()};
      await prefs.setString('doctor_avail_v1', jsonEncode(map));
    } catch (_) {/* best-effort */}
  }
}

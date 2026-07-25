// =============================================================================
//  DoctorOnboardingStore — how far a doctor got through setup
// -----------------------------------------------------------------------------
//  Records which steps were SKIPPED, not what was entered. That is deliberate
//  for now: the onboarding screens exist so the flow can be walked and reviewed
//  in a testing build, and storing half-entered registration numbers and bank
//  details on a device would be collecting sensitive data we have nowhere
//  proper to put yet.
//
//  When this becomes real, the fields go to Supabase behind expert-only RLS and
//  the documents to Storage - and APPROVAL stays in the admin panel, never here.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorOnboardingStore extends ChangeNotifier {
  DoctorOnboardingStore._();
  static final DoctorOnboardingStore instance = DoctorOnboardingStore._();

  static const _key = 'doctor_onboarding_v1';

  /// expertId -> the step names they skipped.
  final Map<String, Set<String>> _skipped = {};
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final map = jsonDecode(raw) as Map;
        for (final e in map.entries) {
          _skipped['${e.key}'] =
              (e.value as List).map((x) => x.toString()).toSet();
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  Set<String> skippedFor(String expertId) => _skipped[expertId] ?? const {};

  bool hasSkippedAnything(String expertId) => skippedFor(expertId).isNotEmpty;

  void markSkipped(String expertId, String step) {
    if (expertId.isEmpty) return;
    (_skipped[expertId] ??= <String>{}).add(step);
    _persist();
    notifyListeners();
  }

  void clear(String expertId) {
    _skipped.remove(expertId);
    _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_skipped.map((k, v) => MapEntry(k, v.toList()))),
      );
    } catch (_) {/* in-memory stands */}
  }

  @visibleForTesting
  void resetAll() {
    _skipped.clear();
    _loaded = false;
    notifyListeners();
  }
}

// =============================================================================
//  DoctorScheduleStore — the doctor's schedule, held and persisted
// -----------------------------------------------------------------------------
//  Local-first, per expert, exactly like the rest of the app: edits land in
//  memory and on disk immediately so the Availability screen never waits on a
//  network, and the server is caught up separately (Phase 3, when these become
//  real booking_slots).
//
//  Keyed by expertId because one device may sign in as different doctors during
//  testing, and a schedule belongs to a person, not a phone.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';
import 'doctor_schedule.dart';

class DoctorScheduleStore extends ChangeNotifier {
  DoctorScheduleStore._();
  static final DoctorScheduleStore instance = DoctorScheduleStore._();

  static const _key = 'doctor_schedule_v1';

  final Map<String, DoctorSchedule> _byExpert = {};
  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final map = jsonDecode(raw) as Map;
        for (final e in map.entries) {
          _byExpert['${e.key}'] = DoctorSchedule.fromMap(e.value as Map);
        }
      }
    } catch (_) {/* start empty rather than block the screen */}
    _loaded = true;
    notifyListeners();
  }

  /// A doctor who has never set anything gets the starter week rather than a
  /// blank grid — the two-session clinic day most practices actually run. They
  /// can change everything; they just do not start from nothing.
  DoctorSchedule scheduleFor(String expertId) =>
      _byExpert[expertId] ?? DoctorSchedule.starter;

  bool hasSetUp(String expertId) => _byExpert.containsKey(expertId);

  void save(String expertId, DoctorSchedule schedule) {
    _byExpert[expertId] = schedule;
    _persist();
    _pushToServer(expertId, schedule);
    notifyListeners();
  }

  /// Push the whole schedule up (0033: one row per doctor). Fire-and-forget -
  /// the local copy is already saved, so a network hiccup costs nothing and the
  /// next save catches up.
  void _pushToServer(String expertId, DoctorSchedule schedule) {
    if (expertId.isEmpty || !SupabaseRepo.isLoggedIn) return;
    try {
      SupabaseRepo.upsertRow(
        'doctor_schedule',
        {
          'expert_id': expertId,
          'schedule': schedule.toMap(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'expert_id',
      );
    } catch (_) {/* local stands */}
  }

  /// Pull every doctor's schedule. The PARENT side needs this too - it is how a
  /// parent sees a doctor's real hours rather than invented ones - so this is
  /// not doctor-only code.
  Future<void> syncFromServer() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows = await SupabaseRepo.selectAll('doctor_schedule');
      for (final r in rows.whereType<Map>()) {
        final id = (r['expert_id'] ?? '').toString();
        final raw = r['schedule'];
        if (id.isEmpty || raw is! Map) continue;
        _byExpert[id] = DoctorSchedule.fromMap(raw);
      }
      if (rows.isNotEmpty) {
        _persist();
        notifyListeners();
      }
    } catch (_) {/* offline - local view still works */}
  }

  /// Slots a parent would actually be offered — the same function the parent
  /// side will call, so the preview cannot drift from reality.
  List<GeneratedSlot> preview(
    String expertId, {
    int days = 14,
    Set<DateTime> booked = const {},
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    return generateSlots(
      scheduleFor(expertId),
      from: clock,
      days: days,
      booked: booked,
      now: clock,
    );
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_byExpert.map((k, v) => MapEntry(k, v.toMap()))),
      );
    } catch (_) {/* the in-memory edit still stands */}
  }

  @visibleForTesting
  void resetAll() {
    _byExpert.clear();
    _loaded = false;
    notifyListeners();
  }
}

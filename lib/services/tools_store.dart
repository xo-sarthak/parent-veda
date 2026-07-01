// =============================================================================
//  ToolsStore
// -----------------------------------------------------------------------------
//  Local-only persistence (shared_preferences) for the ParentVeda Tools:
//    * Baby Movement Tracker  — movement timestamps
//    * Weight Tracker         — profile + weight entries
//    * Kegel Care             — progress + adaptive routine offsets + feedback
//    * Contraction Tracker    — sessions of timed contractions
//
//  ChangeNotifier so tool screens react. Mirrors the style of [DailyStore].
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/supabase_repo.dart';

// ---------------------------------------------------------------------------
//  Models
// ---------------------------------------------------------------------------

/// A single recorded weight entry.
@immutable
class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.dateIso,
    required this.timeIso,
    required this.week,
    required this.weight,
    this.notes = '',
  });

  final String id;

  /// Calendar date (yyyy-MM-dd) — used for grouping / "today" checks.
  final String dateIso;

  /// Full timestamp — used for ordering and showing the time of each entry, so
  /// multiple entries on the same day are kept (and shown) distinctly.
  final String timeIso;

  final int week;
  final double weight;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'timeIso': timeIso,
        'week': week,
        'weight': weight,
        'notes': notes,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> j) {
    final dateIso = (j['dateIso'] ?? '').toString();
    return WeightEntry(
      // Legacy entries had no id/timeIso — derive stable fallbacks.
      id: (j['id'] ?? 'w_${dateIso}_${j['weight']}').toString(),
      dateIso: dateIso,
      timeIso: (j['timeIso'] ?? dateIso).toString(),
      week: (j['week'] is int) ? j['week'] : int.tryParse('${j['week']}') ?? 0,
      weight: (j['weight'] is num)
          ? (j['weight'] as num).toDouble()
          : double.tryParse('${j['weight']}') ?? 0,
      notes: (j['notes'] ?? '').toString(),
    );
  }
}

/// One timed contraction inside a session.
@immutable
class Contraction {
  const Contraction({
    required this.startIso,
    required this.endIso,
    required this.durationSeconds,
    required this.intervalSeconds,
  });

  final String startIso;
  final String endIso;
  final int durationSeconds;

  /// Seconds since the START of the previous contraction (0 for the first).
  final int intervalSeconds;

  Map<String, dynamic> toJson() => {
        'startIso': startIso,
        'endIso': endIso,
        'durationSeconds': durationSeconds,
        'intervalSeconds': intervalSeconds,
      };

  factory Contraction.fromJson(Map<String, dynamic> j) => Contraction(
        startIso: (j['startIso'] ?? '').toString(),
        endIso: (j['endIso'] ?? '').toString(),
        durationSeconds: (j['durationSeconds'] is int)
            ? j['durationSeconds']
            : int.tryParse('${j['durationSeconds']}') ?? 0,
        intervalSeconds: (j['intervalSeconds'] is int)
            ? j['intervalSeconds']
            : int.tryParse('${j['intervalSeconds']}') ?? 0,
      );
}

/// A contraction-tracking session (one sitting).
@immutable
class ContractionSession {
  const ContractionSession({
    required this.id,
    required this.dateIso,
    required this.contractions,
    this.laborResponse,
  });

  final String id;
  final String dateIso;
  final List<Contraction> contractions;

  /// The mother's answer to the gentle "does this feel like labour?" prompt:
  /// 'yes' | 'no' | null (not asked / not answered).
  final String? laborResponse;

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'contractions': contractions.map((c) => c.toJson()).toList(),
        'laborResponse': laborResponse,
      };

  factory ContractionSession.fromJson(Map<String, dynamic> j) =>
      ContractionSession(
        id: (j['id'] ?? '').toString(),
        dateIso: (j['dateIso'] ?? '').toString(),
        contractions: ((j['contractions'] as List?) ?? [])
            .map((e) => Contraction.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        laborResponse: j['laborResponse']?.toString(),
      );
}

/// One Kegel session record.
@immutable
class KegelRecord {
  const KegelRecord({
    required this.dateIso,
    required this.holdSeconds,
    required this.relaxSeconds,
    required this.repetitions,
    required this.feedback,
  });

  final String dateIso;
  final int holdSeconds;
  final int relaxSeconds;
  final int repetitions;

  /// 'easy' | 'comfortable' | 'difficult'
  final String feedback;

  Map<String, dynamic> toJson() => {
        'dateIso': dateIso,
        'holdSeconds': holdSeconds,
        'relaxSeconds': relaxSeconds,
        'repetitions': repetitions,
        'feedback': feedback,
      };

  factory KegelRecord.fromJson(Map<String, dynamic> j) => KegelRecord(
        dateIso: (j['dateIso'] ?? '').toString(),
        holdSeconds: (j['holdSeconds'] is int) ? j['holdSeconds'] : 5,
        relaxSeconds: (j['relaxSeconds'] is int) ? j['relaxSeconds'] : 5,
        repetitions: (j['repetitions'] is int) ? j['repetitions'] : 10,
        feedback: (j['feedback'] ?? 'comfortable').toString(),
      );
}

/// A baby-movement tracking session (one sitting). Starts when the mother taps
/// "Start Session"; ends when she taps "End Session" or leaves the screen / the
/// app is backgrounded. While [endIso] is null the session is active.
class MovementSession {
  MovementSession({
    required this.id,
    required this.startIso,
    this.endIso,
    List<DateTime>? times,
  }) : times = times ?? [];

  final String id;
  final String startIso;
  String? endIso;
  final List<DateTime> times;

  bool get isActive => endIso == null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'startIso': startIso,
        'endIso': endIso,
        'times': times.map((d) => d.toIso8601String()).toList(),
      };

  factory MovementSession.fromJson(Map<String, dynamic> j) => MovementSession(
        id: (j['id'] ?? '').toString(),
        startIso: (j['startIso'] ?? '').toString(),
        endIso: j['endIso']?.toString(),
        times: ((j['times'] as List?) ?? [])
            .map((e) => DateTime.tryParse(e.toString()))
            .whereType<DateTime>()
            .toList(),
      );
}

/// One ended session, resolved for the History screen with its per-day ordinal.
typedef MovementSessionRecord = ({
  String id,
  DateTime start,
  DateTime end,
  List<DateTime> times,
  int dayIndex,
});

// ---------------------------------------------------------------------------
//  Store
// ---------------------------------------------------------------------------

class ToolsStore extends ChangeNotifier {
  ToolsStore._();
  static final ToolsStore instance = ToolsStore._();

  static const _movementKey = 'tool_movements'; // legacy [iso] — migrated
  static const _movementSessionsKey =
      'tool_movement_sessions'; // [MovementSession]
  static const _weightProfileKey = 'tool_weight_profile'; // {pre,height}
  static const _weightEntriesKey = 'tool_weight_entries'; // [WeightEntry]
  static const _kegelKey = 'tool_kegel'; // {progress + offsets}
  static const _kegelHistKey = 'tool_kegel_history'; // [KegelRecord]
  static const _contractionKey = 'tool_contractions'; // [ContractionSession]

  // Movement (session-based)
  final List<MovementSession> _movementSessions = [];

  // Weight
  double? _prePregnancyWeight;
  double? _heightCm;
  final List<WeightEntry> _weightEntries = [];

  // Kegel
  int _kegelSessions = 0;
  final List<String> _kegelThisWeek = []; // iso timestamps
  String? _kegelLast;
  int _kegelHoldAdjust = 0;
  int _kegelRepAdjust = 0;
  final List<KegelRecord> _kegelHistory = [];
  // Optional user-customized routine (overrides the recommended one until reset).
  int? _kegelCustomHold;
  int? _kegelCustomRelax;
  int? _kegelCustomReps;
  // Whether spoken hold/relax voice cues play during a session.
  bool _kegelVoiceOn = true;

  // Contraction
  final List<ContractionSession> _contractionSessions = [];

  bool _loaded = false;

  // ---- Movement getters -----------------------------------------------------

  /// The currently open session, if any (the one the mother started and has not
  /// yet ended).
  MovementSession? get activeMovementSession {
    for (final s in _movementSessions) {
      if (s.isActive) return s;
    }
    return null;
  }

  bool get hasActiveMovementSession => activeMovementSession != null;

  /// Timestamps logged in the active session (sorted, oldest first).
  List<DateTime> get currentSessionMovements {
    final s = activeMovementSession;
    if (s == null) return const [];
    return [...s.times]..sort();
  }

  int get currentSessionCount => activeMovementSession?.times.length ?? 0;

  /// Total movements logged today across all sessions (active or ended) — used
  /// by the Home quick-row "Kicks" tile.
  int get kicksToday {
    final today = _isoDate(DateTime.now());
    var n = 0;
    for (final s in _movementSessions) {
      for (final t in s.times) {
        if (_isoDate(t) == today) n++;
      }
    }
    return n;
  }

  /// Ended sessions (with at least one movement), newest first, each tagged with
  /// its ordinal within its calendar day (e.g. "Session 2" on 20 June).
  List<MovementSessionRecord> get movementSessionHistory {
    final ended = _movementSessions
        .where((s) => !s.isActive && s.times.isNotEmpty)
        .toList()
      ..sort((a, b) => a.startIso.compareTo(b.startIso)); // oldest first

    final perDay = <String, int>{};
    final recs = <MovementSessionRecord>[];
    for (final s in ended) {
      final start = DateTime.tryParse(s.startIso) ?? s.times.first;
      final end = DateTime.tryParse(s.endIso ?? '') ?? s.times.last;
      final key = _isoDate(start);
      final idx = (perDay[key] ?? 0) + 1;
      perDay[key] = idx;
      recs.add((
        id: s.id,
        start: start,
        end: end,
        times: [...s.times]..sort(),
        dayIndex: idx,
      ));
    }
    recs.sort((a, b) => b.start.compareTo(a.start)); // newest first
    return recs;
  }

  // ---- Weight getters -------------------------------------------------------

  // Height is optional — only the pre-pregnancy weight is required to start.
  bool get weightOnboarded => _prePregnancyWeight != null;
  double? get prePregnancyWeight => _prePregnancyWeight;
  double? get heightCm => _heightCm;

  /// Weight entries, newest first (by full timestamp, so same-day entries keep
  /// their order).
  List<WeightEntry> get weightEntries {
    final list = [..._weightEntries];
    list.sort((a, b) => b.timeIso.compareTo(a.timeIso));
    return list;
  }

  WeightEntry? get latestWeight =>
      weightEntries.isEmpty ? null : weightEntries.first;

  /// Recommended pregnancy weight-gain range (kg) from pre-pregnancy BMI.
  ({double min, double max})? get recommendedGain {
    final w = _prePregnancyWeight;
    final h = _heightCm;
    if (w == null || h == null || h <= 0) return null;
    final bmi = w / ((h / 100) * (h / 100));
    if (bmi < 18.5) return (min: 12.5, max: 18.0);
    if (bmi < 25) return (min: 11.5, max: 16.0);
    if (bmi < 30) return (min: 7.0, max: 11.5);
    return (min: 5.0, max: 9.0);
  }

  String? get bmiCategory {
    final w = _prePregnancyWeight;
    final h = _heightCm;
    if (w == null || h == null || h <= 0) return null;
    final bmi = w / ((h / 100) * (h / 100));
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normal';
    if (bmi < 30) return 'overweight';
    return 'high';
  }

  // ---- Kegel getters --------------------------------------------------------

  int get kegelSessions => _kegelSessions;
  String? get kegelLast => _kegelLast;
  int get kegelHoldAdjust => _kegelHoldAdjust;
  int get kegelRepAdjust => _kegelRepAdjust;
  List<KegelRecord> get kegelHistory {
    final list = [..._kegelHistory];
    list.sort((a, b) => b.dateIso.compareTo(a.dateIso));
    return list;
  }

  int get kegelCompletedThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _kegelThisWeek.where((iso) {
      final d = DateTime.tryParse(iso);
      return d != null && d.isAfter(weekAgo);
    }).length;
  }

  bool get hasCustomKegelRoutine =>
      _kegelCustomHold != null &&
      _kegelCustomRelax != null &&
      _kegelCustomReps != null;
  int? get kegelCustomHold => _kegelCustomHold;
  int? get kegelCustomRelax => _kegelCustomRelax;
  int? get kegelCustomReps => _kegelCustomReps;
  bool get kegelVoiceOn => _kegelVoiceOn;

  // ---- Contraction getters --------------------------------------------------

  List<ContractionSession> get contractionSessions {
    final list = [..._contractionSessions];
    list.sort((a, b) => b.dateIso.compareTo(a.dateIso));
    return list;
  }

  // ---- Load -----------------------------------------------------------------

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      final ms = prefs.getString(_movementSessionsKey);
      if (ms != null) {
        for (final e in (jsonDecode(ms) as List)) {
          _movementSessions
              .add(MovementSession.fromJson(Map<String, dynamic>.from(e)));
        }
      } else {
        // One-time migration: fold legacy flat timestamps into one ended session
        // per calendar day so existing history is preserved.
        final mv = prefs.getString(_movementKey);
        if (mv != null) {
          final byDate = <String, List<DateTime>>{};
          for (final e in (jsonDecode(mv) as List)) {
            final d = DateTime.tryParse(e.toString());
            if (d != null) byDate.putIfAbsent(_isoDate(d), () => []).add(d);
          }
          final keys = byDate.keys.toList()..sort();
          for (final k in keys) {
            final list = byDate[k]!..sort();
            _movementSessions.add(MovementSession(
              id: 'mig_$k',
              startIso: list.first.toIso8601String(),
              endIso: list.last.toIso8601String(),
              times: list,
            ));
          }
        }
      }
      // A session left open by a previous run (app killed) is closed now —
      // sessions never span app launches.
      _closeDanglingSessions();

      final wp = prefs.getString(_weightProfileKey);
      if (wp != null) {
        final m = jsonDecode(wp) as Map;
        _prePregnancyWeight = (m['pre'] as num?)?.toDouble();
        _heightCm = (m['height'] as num?)?.toDouble();
      }
      final we = prefs.getString(_weightEntriesKey);
      if (we != null) {
        for (final e in (jsonDecode(we) as List)) {
          _weightEntries.add(WeightEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }

      final kg = prefs.getString(_kegelKey);
      if (kg != null) {
        final m = jsonDecode(kg) as Map;
        _kegelSessions = (m['sessions'] as num?)?.toInt() ?? 0;
        _kegelLast = m['last']?.toString();
        _kegelHoldAdjust = (m['holdAdjust'] as num?)?.toInt() ?? 0;
        _kegelRepAdjust = (m['repAdjust'] as num?)?.toInt() ?? 0;
        _kegelCustomHold = (m['customHold'] as num?)?.toInt();
        _kegelCustomRelax = (m['customRelax'] as num?)?.toInt();
        _kegelCustomReps = (m['customReps'] as num?)?.toInt();
        _kegelVoiceOn = (m['voiceOn'] as bool?) ?? true;
        for (final e in ((m['thisWeek'] as List?) ?? [])) {
          _kegelThisWeek.add(e.toString());
        }
      }
      final kh = prefs.getString(_kegelHistKey);
      if (kh != null) {
        for (final e in (jsonDecode(kh) as List)) {
          _kegelHistory.add(KegelRecord.fromJson(Map<String, dynamic>.from(e)));
        }
      }

      final ct = prefs.getString(_contractionKey);
      if (ct != null) {
        for (final e in (jsonDecode(ct) as List)) {
          _contractionSessions
              .add(ContractionSession.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();

    // Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  // ===========================================================================
  //  Cloud sync (Supabase) — local-first. Five data kinds sync here; kegel
  //  *history* is deferred (no-id append-only log). camelCase <-> snake_case.
  // ===========================================================================

  Future<void> _syncFromCloud() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // weight_profile (single row per user)
      final wp = await SupabaseRepo.fetchOne('weight_profile');
      if (wp != null) {
        _prePregnancyWeight =
            (wp['pre'] as num?)?.toDouble() ?? _prePregnancyWeight;
        _heightCm = (wp['height'] as num?)?.toDouble() ?? _heightCm;
      } else if (_prePregnancyWeight != null) {
        await _cloudUpsertWeightProfile(); // push local profile up
      }

      // weight_entries (list, by id)
      final weRows = await SupabaseRepo.fetch('weight_entries');
      final weById = {
        for (final r in weRows) r['id'].toString(): _weightEntryFromRow(r)
      };
      for (final e in _weightEntries) {
        if (!weById.containsKey(e.id)) {
          weById[e.id] = e;
          await SupabaseRepo.insert('weight_entries', _weightEntryToRow(e));
        }
      }
      _weightEntries
        ..clear()
        ..addAll(weById.values);
      await _persist(_weightEntriesKey,
          jsonEncode(_weightEntries.map((e) => e.toJson()).toList()));

      // movement_sessions (list, by id — only ended sessions are pushed)
      final msRows = await SupabaseRepo.fetch('movement_sessions');
      final msById = {
        for (final r in msRows) r['id'].toString(): _movementFromRow(r)
      };
      final activeLocal = _movementSessions.where((s) => s.isActive).toList();
      for (final s in _movementSessions) {
        if (!s.isActive && s.times.isNotEmpty && !msById.containsKey(s.id)) {
          msById[s.id] = s;
          await SupabaseRepo.upsert('movement_sessions', _movementToRow(s),
              onConflict: 'id');
        }
      }
      _movementSessions
        ..clear()
        ..addAll(msById.values)
        ..addAll(activeLocal);
      await _persistMovementSessions();

      // kegel_state (single row per user)
      final ks = await SupabaseRepo.fetchOne('kegel_state');
      if (ks != null) {
        _kegelSessions = (ks['sessions'] as num?)?.toInt() ?? _kegelSessions;
        _kegelLast = ks['last']?.toString() ?? _kegelLast;
        _kegelHoldAdjust = (ks['hold_adjust'] as num?)?.toInt() ?? _kegelHoldAdjust;
        _kegelRepAdjust = (ks['rep_adjust'] as num?)?.toInt() ?? _kegelRepAdjust;
        _kegelCustomHold = (ks['custom_hold'] as num?)?.toInt();
        _kegelCustomRelax = (ks['custom_relax'] as num?)?.toInt();
        _kegelCustomReps = (ks['custom_reps'] as num?)?.toInt();
        _kegelVoiceOn = (ks['voice_on'] as bool?) ?? _kegelVoiceOn;
        _kegelThisWeek
          ..clear()
          ..addAll(((ks['this_week'] as List?) ?? []).map((e) => e.toString()));
      } else if (_kegelSessions > 0 || _kegelThisWeek.isNotEmpty) {
        await _cloudPushKegelState(); // push local state up
      }

      // contraction_sessions (list, by id)
      final ctRows = await SupabaseRepo.fetch('contraction_sessions');
      final ctById = {
        for (final r in ctRows) r['id'].toString(): _contractionFromRow(r)
      };
      for (final s in _contractionSessions) {
        if (!ctById.containsKey(s.id)) {
          ctById[s.id] = s;
          await SupabaseRepo.upsert('contraction_sessions', _contractionToRow(s),
              onConflict: 'id');
        }
      }
      _contractionSessions
        ..clear()
        ..addAll(ctById.values);
      await _persist(_contractionKey,
          jsonEncode(_contractionSessions.map((s) => s.toJson()).toList()));

      // kegel_history — append-only; synced as a whole blob in user_state,
      // merged with the cloud by dateIso (its natural key), then pushed back.
      final khCloud = await SupabaseRepo.loadState('tool_kegel_history');
      if (khCloud is List) {
        final byIso = <String, KegelRecord>{
          for (final e in _kegelHistory) e.dateIso: e,
        };
        for (final e in khCloud) {
          final r = KegelRecord.fromJson(Map<String, dynamic>.from(e));
          byIso[r.dateIso] = r;
        }
        _kegelHistory
          ..clear()
          ..addAll(byIso.values);
      }
      await SupabaseRepo.saveState('tool_kegel_history',
          _kegelHistory.map((e) => e.toJson()).toList());
      await _persist(_kegelHistKey,
          jsonEncode(_kegelHistory.map((e) => e.toJson()).toList()));

      notifyListeners();
    } catch (_) {/* offline — keep local */}
  }

  Future<void> _cloudUpsertWeightProfile() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.upsert('weight_profile',
          {'pre': _prePregnancyWeight, 'height': _heightCm},
          onConflict: 'user_id');
    } catch (_) {}
  }

  Future<void> _cloudPushKegelState() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.upsert(
          'kegel_state',
          {
            'sessions': _kegelSessions,
            'last': _kegelLast,
            'hold_adjust': _kegelHoldAdjust,
            'rep_adjust': _kegelRepAdjust,
            'custom_hold': _kegelCustomHold,
            'custom_relax': _kegelCustomRelax,
            'custom_reps': _kegelCustomReps,
            'voice_on': _kegelVoiceOn,
            'this_week': _kegelThisWeek,
          },
          onConflict: 'user_id');
    } catch (_) {}
  }

  // ---- row mappings ---------------------------------------------------------
  Map<String, dynamic> _weightEntryToRow(WeightEntry e) => {
        'id': e.id,
        'date_iso': e.dateIso.isEmpty ? null : e.dateIso,
        'time_iso': e.timeIso.isEmpty ? null : e.timeIso,
        'week': e.week,
        'weight': e.weight,
        'notes': e.notes,
      };

  WeightEntry _weightEntryFromRow(Map<String, dynamic> r) => WeightEntry(
        id: (r['id'] ?? '').toString(),
        dateIso: (r['date_iso'] ?? '').toString(),
        timeIso: (r['time_iso'] ?? '').toString(),
        week: (r['week'] as num?)?.toInt() ?? 0,
        weight: (r['weight'] as num?)?.toDouble() ?? 0,
        notes: (r['notes'] ?? '').toString(),
      );

  Map<String, dynamic> _movementToRow(MovementSession s) => {
        'id': s.id,
        'start_iso': s.startIso.isEmpty ? null : s.startIso,
        'end_iso': (s.endIso == null || s.endIso!.isEmpty) ? null : s.endIso,
        'times': s.times.map((d) => d.toIso8601String()).toList(),
      };

  MovementSession _movementFromRow(Map<String, dynamic> r) => MovementSession(
        id: (r['id'] ?? '').toString(),
        startIso: (r['start_iso'] ?? '').toString(),
        endIso: r['end_iso']?.toString(),
        times: ((r['times'] as List?) ?? [])
            .map((e) => DateTime.tryParse(e.toString()))
            .whereType<DateTime>()
            .toList(),
      );

  Map<String, dynamic> _contractionToRow(ContractionSession s) => {
        'id': s.id,
        'date_iso': s.dateIso.isEmpty ? null : s.dateIso,
        'contractions': s.contractions.map((c) => c.toJson()).toList(),
        'labor_response': s.laborResponse,
      };

  ContractionSession _contractionFromRow(Map<String, dynamic> r) =>
      ContractionSession(
        id: (r['id'] ?? '').toString(),
        dateIso: (r['date_iso'] ?? '').toString(),
        contractions: ((r['contractions'] as List?) ?? [])
            .map((e) => Contraction.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        laborResponse: r['labor_response']?.toString(),
      );

  // ---- Movement mutations ---------------------------------------------------

  /// Begin a new session (no-op if one is already active).
  Future<void> startMovementSession() async {
    if (hasActiveMovementSession) return;
    final now = DateTime.now();
    _movementSessions.add(MovementSession(
      id: 'ms_${now.microsecondsSinceEpoch}',
      startIso: now.toIso8601String(),
    ));
    notifyListeners();
    await _persistMovementSessions();
  }

  /// Log a movement into the active session (auto-starts one if needed).
  Future<void> logMovement() async {
    var session = activeMovementSession;
    if (session == null) {
      await startMovementSession();
      session = activeMovementSession;
    }
    session!.times.add(DateTime.now());
    notifyListeners();
    await _persistMovementSessions();
  }

  /// End the active session. Empty sessions (no movements) are discarded so
  /// history never fills with blanks.
  Future<void> endMovementSession() async {
    final s = activeMovementSession;
    if (s == null) return;
    final keep = s.times.isNotEmpty;
    if (keep) {
      s.endIso = DateTime.now().toIso8601String();
    } else {
      _movementSessions.remove(s);
    }
    notifyListeners();
    await _persistMovementSessions();
    // Only ended sessions (with movements) go to the cloud.
    if (keep && SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.upsert('movement_sessions', _movementToRow(s),
            onConflict: 'id');
      } catch (_) {}
    }
  }

  /// Close any session left active from a previous launch (no persistence note
  /// needed beyond the single save below).
  void _closeDanglingSessions() {
    var changed = false;
    _movementSessions.removeWhere((s) {
      if (s.isActive && s.times.isEmpty) {
        changed = true;
        return true;
      }
      return false;
    });
    for (final s in _movementSessions) {
      if (s.isActive) {
        s.endIso = s.times.last.toIso8601String();
        changed = true;
      }
    }
    if (changed) _persistMovementSessions();
  }

  Future<void> _persistMovementSessions() => _persist(_movementSessionsKey,
      jsonEncode(_movementSessions.map((s) => s.toJson()).toList()));

  // ---- Weight mutations -----------------------------------------------------

  Future<void> setWeightProfile(double preWeight, double? heightCm) async {
    _prePregnancyWeight = preWeight;
    _heightCm = heightCm;
    notifyListeners();
    await _persist(_weightProfileKey,
        jsonEncode({'pre': preWeight, 'height': heightCm}));
    await _cloudUpsertWeightProfile();
  }

  /// Add a weight entry. Multiple entries per day are allowed (and kept) — they
  /// are never overwritten.
  Future<void> addWeightEntry(WeightEntry entry) async {
    _weightEntries.add(entry);
    notifyListeners();
    await _persist(_weightEntriesKey,
        jsonEncode(_weightEntries.map((e) => e.toJson()).toList()));
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.insert('weight_entries', _weightEntryToRow(entry));
      } catch (_) {}
    }
  }

  /// Remove a single weight entry by id.
  Future<void> deleteWeightEntry(String id) async {
    _weightEntries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist(_weightEntriesKey,
        jsonEncode(_weightEntries.map((e) => e.toJson()).toList()));
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.delete('weight_entries', id);
      } catch (_) {}
    }
  }

  // ---- Kegel mutations ------------------------------------------------------

  Future<void> recordKegelSession({
    required int holdSeconds,
    required int relaxSeconds,
    required int repetitions,
    required String feedback,
  }) async {
    final now = DateTime.now();
    _kegelSessions += 1;
    _kegelLast = now.toIso8601String();
    _kegelThisWeek.add(now.toIso8601String());
    _kegelHistory.add(KegelRecord(
      dateIso: now.toIso8601String(),
      holdSeconds: holdSeconds,
      relaxSeconds: relaxSeconds,
      repetitions: repetitions,
      feedback: feedback,
    ));

    // Adaptive progression: nudge difficulty by feedback.
    if (feedback == 'easy') {
      if (_kegelHoldAdjust < 5) {
        _kegelHoldAdjust += 1;
      } else {
        _kegelRepAdjust += 2;
      }
    } else if (feedback == 'difficult') {
      if (_kegelHoldAdjust > -2) {
        _kegelHoldAdjust -= 1;
      } else {
        _kegelRepAdjust -= 2;
      }
    }

    notifyListeners();
    await _persistKegel();
    await _persist(_kegelHistKey,
        jsonEncode(_kegelHistory.map((e) => e.toJson()).toList()));
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.saveState('tool_kegel_history',
            _kegelHistory.map((e) => e.toJson()).toList());
      } catch (_) {}
    }
  }

  /// Set a custom routine override (used until cleared).
  Future<void> setKegelCustomRoutine({
    required int hold,
    required int relax,
    required int reps,
  }) async {
    _kegelCustomHold = hold;
    _kegelCustomRelax = relax;
    _kegelCustomReps = reps;
    notifyListeners();
    await _persistKegel();
  }

  /// Drop the custom routine and fall back to the recommended one.
  Future<void> clearKegelCustomRoutine() async {
    _kegelCustomHold = null;
    _kegelCustomRelax = null;
    _kegelCustomReps = null;
    notifyListeners();
    await _persistKegel();
  }

  Future<void> setKegelVoice(bool on) async {
    _kegelVoiceOn = on;
    notifyListeners();
    await _persistKegel();
  }

  Future<void> _persistKegel() async {
    await _persist(
        _kegelKey,
        jsonEncode({
          'sessions': _kegelSessions,
          'last': _kegelLast,
          'holdAdjust': _kegelHoldAdjust,
          'repAdjust': _kegelRepAdjust,
          'customHold': _kegelCustomHold,
          'customRelax': _kegelCustomRelax,
          'customReps': _kegelCustomReps,
          'voiceOn': _kegelVoiceOn,
          'thisWeek': _kegelThisWeek,
        }));
    await _cloudPushKegelState();
  }

  // ---- Contraction mutations ------------------------------------------------

  Future<void> saveContractionSession(ContractionSession session) async {
    _contractionSessions.removeWhere((s) => s.id == session.id);
    _contractionSessions.add(session);
    notifyListeners();
    await _persist(_contractionKey,
        jsonEncode(_contractionSessions.map((s) => s.toJson()).toList()));
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.upsert('contraction_sessions', _contractionToRow(session),
            onConflict: 'id');
      } catch (_) {}
    }
  }

  // ---- Helpers --------------------------------------------------------------

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _persist(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {/* best-effort */}
  }
}

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

// ---------------------------------------------------------------------------
//  Models
// ---------------------------------------------------------------------------

/// A single recorded weight entry.
@immutable
class WeightEntry {
  const WeightEntry({
    required this.dateIso,
    required this.week,
    required this.weight,
    this.notes = '',
  });

  final String dateIso;
  final int week;
  final double weight;
  final String notes;

  Map<String, dynamic> toJson() =>
      {'dateIso': dateIso, 'week': week, 'weight': weight, 'notes': notes};

  factory WeightEntry.fromJson(Map<String, dynamic> j) => WeightEntry(
        dateIso: (j['dateIso'] ?? '').toString(),
        week: (j['week'] is int) ? j['week'] : int.tryParse('${j['week']}') ?? 0,
        weight: (j['weight'] is num)
            ? (j['weight'] as num).toDouble()
            : double.tryParse('${j['weight']}') ?? 0,
        notes: (j['notes'] ?? '').toString(),
      );
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
  });

  final String id;
  final String dateIso;
  final List<Contraction> contractions;

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'contractions': contractions.map((c) => c.toJson()).toList(),
      };

  factory ContractionSession.fromJson(Map<String, dynamic> j) =>
      ContractionSession(
        id: (j['id'] ?? '').toString(),
        dateIso: (j['dateIso'] ?? '').toString(),
        contractions: ((j['contractions'] as List?) ?? [])
            .map((e) => Contraction.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
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

// ---------------------------------------------------------------------------
//  Store
// ---------------------------------------------------------------------------

class ToolsStore extends ChangeNotifier {
  ToolsStore._();
  static final ToolsStore instance = ToolsStore._();

  static const _movementKey = 'tool_movements'; // [iso]
  static const _weightProfileKey = 'tool_weight_profile'; // {pre,height}
  static const _weightEntriesKey = 'tool_weight_entries'; // [WeightEntry]
  static const _kegelKey = 'tool_kegel'; // {progress + offsets}
  static const _kegelHistKey = 'tool_kegel_history'; // [KegelRecord]
  static const _contractionKey = 'tool_contractions'; // [ContractionSession]

  // Movement
  final List<DateTime> _movements = [];

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

  // Contraction
  final List<ContractionSession> _contractionSessions = [];

  bool _loaded = false;

  // ---- Movement getters -----------------------------------------------------

  List<DateTime> get _today {
    final now = DateTime.now();
    return _movements
        .where((d) =>
            d.year == now.year && d.month == now.month && d.day == now.day)
        .toList()
      ..sort();
  }

  List<DateTime> get todayMovements => _today;
  bool get babyActiveToday => _today.isNotEmpty;

  /// Movement sessions grouped by calendar date (newest first), for History.
  List<({String dateIso, List<DateTime> times})> get movementHistory {
    final byDate = <String, List<DateTime>>{};
    for (final d in _movements) {
      final key = _isoDate(d);
      byDate.putIfAbsent(key, () => []).add(d);
    }
    final keys = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final k in keys) (dateIso: k, times: byDate[k]!..sort()),
    ];
  }

  // ---- Weight getters -------------------------------------------------------

  bool get weightOnboarded => _prePregnancyWeight != null && _heightCm != null;
  double? get prePregnancyWeight => _prePregnancyWeight;
  double? get heightCm => _heightCm;

  /// Weight entries, newest first.
  List<WeightEntry> get weightEntries {
    final list = [..._weightEntries];
    list.sort((a, b) => b.dateIso.compareTo(a.dateIso));
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

      final mv = prefs.getString(_movementKey);
      if (mv != null) {
        for (final e in (jsonDecode(mv) as List)) {
          final d = DateTime.tryParse(e.toString());
          if (d != null) _movements.add(d);
        }
      }

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
  }

  // ---- Movement mutations ---------------------------------------------------

  Future<void> logMovement() async {
    _movements.add(DateTime.now());
    notifyListeners();
    await _persist(_movementKey,
        jsonEncode(_movements.map((d) => d.toIso8601String()).toList()));
  }

  // ---- Weight mutations -----------------------------------------------------

  Future<void> setWeightProfile(double preWeight, double heightCm) async {
    _prePregnancyWeight = preWeight;
    _heightCm = heightCm;
    notifyListeners();
    await _persist(_weightProfileKey,
        jsonEncode({'pre': preWeight, 'height': heightCm}));
  }

  Future<void> addWeightEntry(WeightEntry entry) async {
    // Replace any entry already recorded for the same calendar date.
    _weightEntries.removeWhere((e) => e.dateIso == entry.dateIso);
    _weightEntries.add(entry);
    notifyListeners();
    await _persist(_weightEntriesKey,
        jsonEncode(_weightEntries.map((e) => e.toJson()).toList()));
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
  }

  Future<void> _persistKegel() async {
    await _persist(
        _kegelKey,
        jsonEncode({
          'sessions': _kegelSessions,
          'last': _kegelLast,
          'holdAdjust': _kegelHoldAdjust,
          'repAdjust': _kegelRepAdjust,
          'thisWeek': _kegelThisWeek,
        }));
  }

  // ---- Contraction mutations ------------------------------------------------

  Future<void> saveContractionSession(ContractionSession session) async {
    _contractionSessions.removeWhere((s) => s.id == session.id);
    _contractionSessions.add(session);
    notifyListeners();
    await _persist(_contractionKey,
        jsonEncode(_contractionSessions.map((s) => s.toJson()).toList()));
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

// =============================================================================
//  TtcRecordsStore + TtcAppointmentsStore
// -----------------------------------------------------------------------------
//  The last two pieces of care data: test results the couple has had, and the
//  appointments they have arranged themselves.
//
//  Both are COUPLE-SCOPED. A records folder that only held her results would
//  rebuild exactly the asymmetry this stage exists to correct - his semen
//  analysis belongs beside her AMH, in one place, with one date order.
//
//  A result value is stored as TEXT, not a number. Real Indian lab reports say
//  "12.4", "Normal", "<0.5" and "Grade II"; coercing that to a double would
//  lose most of them. The product never interprets a result anyway - it stores
//  what the report said and hands it to a doctor.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';
import 'ttc_sync.dart';

// =============================================================================
//  Records
// =============================================================================

class TtcRecord {
  const TtcRecord({
    required this.id,
    required this.label,
    required this.takenOn,
    this.testId,
    this.value = '',
    this.unit = '',
    this.note,
    this.forPartner = false,
  });

  /// App-generated, so the local row and its cloud copy share one identity.
  final String id;

  /// The test library entry this came from, if any. Null for anything typed in
  /// by hand - which must always be possible, because no library covers every
  /// test an Indian lab runs.
  final String? testId;

  final String label;
  final String value;
  final String unit;
  final DateTime takenOn;
  final String? note;
  final bool forPartner;

  String get display => unit.isEmpty ? value : '$value $unit';

  Map<String, Object?> toJson() => {
        'id': id,
        if (testId != null) 'test': testId,
        'label': label,
        'value': value,
        'unit': unit,
        'on': TtcSyncUtil.date(takenOn),
        if (note != null) 'note': note,
        'partner': forPartner,
      };

  static TtcRecord? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final label = raw['label'];
    final on = TtcSyncUtil.parseDate(raw['on']);
    if (id is! String || label is! String || on == null) return null;
    return TtcRecord(
      id: id,
      testId: raw['test'] as String?,
      label: label,
      value: (raw['value'] as String?) ?? '',
      unit: (raw['unit'] as String?) ?? '',
      takenOn: on,
      note: raw['note'] as String?,
      forPartner: raw['partner'] == true,
    );
  }
}

class TtcRecordsStore extends ChangeNotifier with TtcSyncedStore {
  TtcRecordsStore._() {
    _load();
  }
  static final TtcRecordsStore instance = TtcRecordsStore._();

  static const _key = 'ttc_records';

  final List<TtcRecord> _items = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Newest result first - how a folder of reports is actually read.
  List<TtcRecord> get records {
    final out = [..._items]..sort((a, b) => b.takenOn.compareTo(a.takenOn));
    return List.unmodifiable(out);
  }

  int get count => _items.length;

  List<TtcRecord> forPerson({required bool partner}) =>
      records.where((r) => r.forPartner == partner).toList();

  /// Every result recorded for one test, oldest first - so a repeat reads as a
  /// trend rather than as a contradiction.
  List<TtcRecord> historyFor(String testId) {
    final out = _items.where((r) => r.testId == testId).toList()
      ..sort((a, b) => a.takenOn.compareTo(b.takenOn));
    return List.unmodifiable(out);
  }

  TtcRecord add({
    required String label,
    required DateTime takenOn,
    String? testId,
    String value = '',
    String unit = '',
    String? note,
    bool forPartner = false,
  }) {
    final r = TtcRecord(
      id: 'ttcr_${DateTime.now().microsecondsSinceEpoch}',
      testId: testId,
      label: label.trim(),
      value: value.trim(),
      unit: unit.trim(),
      takenOn: DateTime(takenOn.year, takenOn.month, takenOn.day),
      note: note,
      forPartner: forPartner,
    );
    _items.add(r);
    _persist();
    notifyListeners();
    return r;
  }

  void remove(String id) {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    if (_items.length == before) return;
    _persist();
    if (SupabaseRepo.isLoggedIn) {
      SupabaseRepo.delete('ttc_records', id).catchError((_) {});
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _items.clear();
    _loaded = true;
    notifyListeners();
  }

  // ---- cloud ----------------------------------------------------------------

  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared('ttc_records',
        orderBy: 'taken_on', ascending: true);
    for (final row in rows) {
      final id = row['id'];
      final on = TtcSyncUtil.parseDate(row['taken_on']);
      if (id is! String || on == null || _items.any((e) => e.id == id)) continue;
      _items.add(TtcRecord(
        id: id,
        testId: row['test_id'] as String?,
        label: (row['label'] as String?) ?? '',
        value: (row['value'] as String?) ?? '',
        unit: (row['unit'] as String?) ?? '',
        takenOn: on,
        note: row['note'] as String?,
        forPartner: row['for_partner'] == true,
      ));
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    await TtcSyncUtil.upsertAll(
      'ttc_records',
      [
        for (final r in _items)
          {
            'id': r.id,
            'user_id': uid,
            if (r.testId != null) 'test_id': r.testId,
            'label': r.label,
            'value': r.value,
            'unit': r.unit,
            'taken_on': TtcSyncUtil.date(r.takenOn),
            if (r.note != null) 'note': r.note,
            'for_partner': r.forPartner,
          }
      ],
      onConflict: 'id',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _items
        ..clear()
        ..addAll((p.getStringList(_key) ?? const <String>[])
            .map((r) {
              try {
                return TtcRecord.fromJson(jsonDecode(r));
              } catch (_) {
                return null;
              }
            })
            .whereType<TtcRecord>());
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _key, _items.map((e) => jsonEncode(e.toJson())).toList());
    } catch (_) {/* best-effort */}
  }
}

// =============================================================================
//  Appointments
// =============================================================================

/// An appointment the couple arranged themselves.
///
/// Separate from the booking engine's `Booking`, deliberately: those are things
/// bought through ParentVeda, these are the clinic visits a couple books over
/// the phone. Both show on the Calendar; only these are theirs to edit.
class TtcAppointment {
  const TtcAppointment({
    required this.id,
    required this.title,
    required this.startsUtc,
    this.withWhom = '',
    this.note,
  });

  final String id;
  final String title;
  final String withWhom;

  /// Stored UTC, shown local - the engine's rule, kept here too.
  final DateTime startsUtc;
  final String? note;

  DateTime get startsLocal => startsUtc.toLocal();
  bool get isUpcoming => startsUtc.isAfter(DateTime.now().toUtc());

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'with': withWhom,
        'at': startsUtc.toIso8601String(),
        if (note != null) 'note': note,
      };

  static TtcAppointment? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final title = raw['title'];
    final at = DateTime.tryParse(raw['at']?.toString() ?? '');
    if (id is! String || title is! String || at == null) return null;
    return TtcAppointment(
      id: id,
      title: title,
      withWhom: (raw['with'] as String?) ?? '',
      startsUtc: at.toUtc(),
      note: raw['note'] as String?,
    );
  }
}

class TtcAppointmentsStore extends ChangeNotifier with TtcSyncedStore {
  TtcAppointmentsStore._() {
    _load();
  }
  static final TtcAppointmentsStore instance = TtcAppointmentsStore._();

  static const _key = 'ttc_appointments';

  final List<TtcAppointment> _items = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Soonest first - an appointments list is read forwards, not backwards.
  List<TtcAppointment> get all {
    final out = [..._items]..sort((a, b) => a.startsUtc.compareTo(b.startsUtc));
    return List.unmodifiable(out);
  }

  List<TtcAppointment> get upcoming =>
      all.where((a) => a.isUpcoming).toList();

  List<TtcAppointment> get past =>
      all.where((a) => !a.isUpcoming).toList().reversed.toList();

  List<TtcAppointment> on(DateTime day) => all
      .where((a) =>
          a.startsLocal.year == day.year &&
          a.startsLocal.month == day.month &&
          a.startsLocal.day == day.day)
      .toList();

  TtcAppointment add({
    required String title,
    required DateTime startsLocal,
    String withWhom = '',
    String? note,
  }) {
    final a = TtcAppointment(
      id: 'ttca_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      withWhom: withWhom.trim(),
      startsUtc: startsLocal.toUtc(),
      note: note,
    );
    _items.add(a);
    _persist();
    notifyListeners();
    return a;
  }

  void remove(String id) {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    if (_items.length == before) return;
    _persist();
    if (SupabaseRepo.isLoggedIn) {
      SupabaseRepo.delete('ttc_appointments', id).catchError((_) {});
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _items.clear();
    _loaded = true;
    notifyListeners();
  }

  // ---- cloud ----------------------------------------------------------------

  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared('ttc_appointments',
        orderBy: 'starts_utc', ascending: true);
    for (final row in rows) {
      final id = row['id'];
      final at = DateTime.tryParse(row['starts_utc']?.toString() ?? '');
      if (id is! String || at == null || _items.any((e) => e.id == id)) continue;
      _items.add(TtcAppointment(
        id: id,
        title: (row['title'] as String?) ?? '',
        withWhom: (row['with_whom'] as String?) ?? '',
        startsUtc: at.toUtc(),
        note: row['note'] as String?,
      ));
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    await TtcSyncUtil.upsertAll(
      'ttc_appointments',
      [
        for (final a in _items)
          {
            'id': a.id,
            'user_id': uid,
            'title': a.title,
            'with_whom': a.withWhom,
            'starts_utc': SupabaseRepo.dbTime(a.startsUtc),
            if (a.note != null) 'note': a.note,
          }
      ],
      onConflict: 'id',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _items
        ..clear()
        ..addAll((p.getStringList(_key) ?? const <String>[])
            .map((r) {
              try {
                return TtcAppointment.fromJson(jsonDecode(r));
              } catch (_) {
                return null;
              }
            })
            .whereType<TtcAppointment>());
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _key, _items.map((e) => jsonEncode(e.toJson())).toList());
    } catch (_) {/* best-effort */}
  }
}

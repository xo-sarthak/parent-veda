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

import '../services/notification_service.dart';
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
    this.attachments = const [],
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

  /// The actual document — a scan PDF, a photo of a printed report.
  ///
  /// Fertility results in India arrive on paper and as PDFs, so a text-only
  /// folder could hold a number she retyped and never the thing her clinic gave
  /// her. Each entry is whatever `StorageService` hands back: a local file path
  /// when signed out, a storage object path once uploaded. `resolve()` turns
  /// either back into a File, so the screen does not care which it is.
  ///
  /// **LOCAL-ONLY, and structurally so.** `toJson()` here is the
  /// `shared_preferences` cache; the cloud row is hand-built in `pushToCloud`,
  /// column by column. Adding a field to the model therefore cannot leak
  /// upward by accident — it reaches the database only when someone writes the
  /// column name out, which is the shape that makes this safe rather than
  /// lucky.
  ///
  /// Adding a column to `ttc_records` is a migration, and the decision for now
  /// is that TTC gains no new schema. So attachments do not travel to a second
  /// device — stated here rather than discovered later, because a silent
  /// half-sync is exactly the failure this codebase keeps having.
  ///
  /// Making them travel later is one nullable column and one line in
  /// `pushToCloud`.
  final List<String> attachments;

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
        // Cached on disk with the rest of the row. Never sent up - `pushToCloud`
        // names its columns explicitly and does not name this one.
        if (attachments.isNotEmpty) 'files': attachments,
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
      attachments: [
        for (final f in (raw['files'] as List?) ?? const []) f.toString(),
      ],
    );
  }

  /// ⚠️ ONLY THE FIELDS SOMETHING ACTUALLY EDITS. `value`/`unit` exist because
  /// a photo-first record can be completed later ("Type it"); `forPartner`
  /// because whose result it is can be corrected.
  ///
  /// ⚠️ LABEL, DATE, TEST AND NOTE JOINED ON 2026-09-27, and the reason is a
  /// defect the user hit on the phone: a result filed with the wrong date or
  /// the wrong name could only be lived with, never fixed, and "Change this
  /// result" is now a screen. The identity rule still holds where it matters:
  /// `id` is not here, so an edit is always the same row, and the cloud upsert
  /// by id makes it the same row there too. It is an explicit screen with a
  /// Save button that rewrites these fields, never a side effect.
  ///
  /// `clearTestId` because `testId` is nullable: a renamed result that no
  /// longer matches a library test must be able to drop its old test.
  TtcRecord copyWith({
    List<String>? attachments,
    String? value,
    String? unit,
    bool? forPartner,
    String? label,
    DateTime? takenOn,
    String? testId,
    bool clearTestId = false,
    String? note,
  }) =>
      TtcRecord(
        id: id,
        testId: clearTestId ? null : (testId ?? this.testId),
        label: label?.trim() ?? this.label,
        value: value ?? this.value,
        unit: unit ?? this.unit,
        takenOn: takenOn == null
            ? this.takenOn
            : DateTime(takenOn.year, takenOn.month, takenOn.day),
        note: note ?? this.note,
        forPartner: forPartner ?? this.forPartner,
        attachments: attachments ?? this.attachments,
      );
}

class TtcRecordsStore extends ChangeNotifier with TtcSyncedStore {
  TtcRecordsStore._() {
    _loading = _load();
  }
  static final TtcRecordsStore instance = TtcRecordsStore._();

  late final Future<void> _loading;

  /// Resolves once the cached rows are in memory.
  ///
  /// ⚠️ ADDED FOR A WRITE THAT CAN ARRIVE BEFORE THE FIRST READ — 2026-09-06.
  /// The store loads in its constructor, asynchronously, and `_load` does
  /// `_items..clear()..addAll(cached)`. A caller that constructs the instance
  /// and calls `add` in the same breath — "Read your semen report" saving a
  /// result is the first such caller — races it: the new row goes into
  /// `_items`, then the load completes and clears it, and the report the
  /// screen said it kept is gone. Awaiting this first is the fix. Screens
  /// that only read never needed it, because a listener rebuild follows the
  /// load's `notifyListeners`.
  Future<void> ensureLoaded() => _loading;

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
      id: 'ttcr_${_nextStamp()}',
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

  /// ⚠️ A CLOCK IS NOT AN ID GENERATOR ON ITS OWN (found 2026-09-27). Two
  /// adds inside one tick of the clock (Windows ticks coarser than a
  /// microsecond) got the SAME id, and every id-keyed operation then treated
  /// two results as one: remove took both, Undo put back one. So the stamp
  /// only ever moves forward. Same format as before, so nothing stored
  /// changes shape.
  static int _lastStamp = 0;
  static int _nextStamp() {
    final now = DateTime.now().microsecondsSinceEpoch;
    _lastStamp = now > _lastStamp ? now : _lastStamp + 1;
    return _lastStamp;
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

  /// Put back rows that were just removed, with their own ids: the Undo on
  /// "Result removed" (added 2026-09-27).
  ///
  /// ⚠️ WHY AN UNDO CAN WORK AFTER A CLOUD DELETE HAS ALREADY GONE OUT. The
  /// app generates the id, so the restored row is the same identity, not a
  /// copy. `remove` fired a delete for that id; `notifyListeners` here fires
  /// the mixin's debounced upsert-by-id, which writes the row back.
  ///
  /// The trade-off, named: two requests on one id are not ordered. If the
  /// delete were still in flight when the upsert landed, the delete would
  /// win. The debounce (700 ms) plus the seconds a person takes to read a
  /// snackbar and tap Undo make that window small, and the next sync pushes
  /// the local row again anyway, because local is the source of truth here.
  /// That second push is what makes it safe rather than lucky.
  void restore(Iterable<TtcRecord> rows) {
    var changed = false;
    for (final r in rows) {
      if (_items.any((e) => e.id == r.id)) continue;
      _items.add(r);
      changed = true;
    }
    if (!changed) return;
    _persist();
    notifyListeners();
  }

  /// Remove several rows at once: a whole test, every reading of it.
  void removeAll(Iterable<String> ids) {
    for (final id in [...ids]) {
      remove(id);
    }
  }

  /// Swap a record for an edited copy, keeping its id.
  ///
  /// Persists locally. It names no cloud call of its own, and it does not
  /// need one: `notifyListeners` is the `TtcSyncedStore` mixin's, which
  /// schedules the debounced upsert of every row by id. So a changed label,
  /// date or number travels; the attachment list does not, because
  /// `pushToCloud` names no column for it (see `attachments`).
  ///
  /// (Corrected 2026-09-27. This comment used to say "does NOT push", which
  /// was never true of the mixin, and mattered once edits of synced fields
  /// arrived.)
  void replace(TtcRecord updated) {
    final i = _items.indexWhere((e) => e.id == updated.id);
    if (i < 0) return;
    _items[i] = updated;
    _persist();
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
    this.remindEveningBefore = false,
  });

  final String id;
  final String title;
  final String withWhom;

  /// Stored UTC, shown local - the engine's rule, kept here too.
  final DateTime startsUtc;
  final String? note;

  /// A phone reminder at 7 pm the day before (added 2026-09-27).
  ///
  /// ⚠️ LOCAL ONLY, NOT A COLUMN, AND THAT IS THE RIGHT HOME FOR IT. A
  /// reminder is a fact about THIS phone: the OS notification lives here, and
  /// her partner's phone pulling the same appointment should not start ringing
  /// because she asked hers to. So it rides in the local JSON and never in
  /// `pushToCloud`. The cost: a reinstall forgets the switch, while the
  /// appointment itself comes back from the cloud. That is the cheap side.
  final bool remindEveningBefore;

  DateTime get startsLocal => startsUtc.toLocal();
  bool get isUpcoming => startsUtc.isAfter(DateTime.now().toUtc());

  /// When the evening-before reminder rings: 7 pm on the day before.
  DateTime get reminderAt {
    final d = startsLocal.subtract(const Duration(days: 1));
    return DateTime(d.year, d.month, d.day, 19);
  }

  TtcAppointment copyWith({
    String? title,
    String? withWhom,
    DateTime? startsLocal,
    bool? remindEveningBefore,
    // Added 2026-09-27 (tool rebuild): the notes box on the appointment
    // page. Null keeps the note; an empty string clears it, because a
    // cleared box has to be able to say "no note now".
    String? note,
  }) =>
      TtcAppointment(
        id: id,
        title: title?.trim() ?? this.title,
        withWhom: withWhom?.trim() ?? this.withWhom,
        startsUtc: startsLocal?.toUtc() ?? startsUtc,
        note: note == null
            ? this.note
            : (note.trim().isEmpty ? null : note.trim()),
        remindEveningBefore: remindEveningBefore ?? this.remindEveningBefore,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'with': withWhom,
        'at': startsUtc.toIso8601String(),
        if (note != null) 'note': note,
        if (remindEveningBefore) 'remind': true,
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
      remindEveningBefore: raw['remind'] == true,
    );
  }
}

/// The phone id for one appointment's evening-before reminder.
///
/// ⚠️ A HASH WE OWN, NOT `String.hashCode`. Dart does not promise that a
/// string hashes the same on the next launch, and this id has to find the same
/// notification tomorrow to cancel or move it. FNV-1a is five lines and never
/// changes. The block (0x3A000000 up) sits clear of the TTC messages (918201
/// up) and the medication alarms.
int ttcAppointmentReminderId(String appointmentId) {
  var h = 0x811c9dc5;
  for (final c in appointmentId.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return 0x3A000000 | (h & 0xFFFFF);
}

/// What the store needs from the phone, so a test can watch it.
typedef TtcApptSchedule = Future<void> Function(
    {required int id,
    required String title,
    required String body,
    required DateTime when});

class TtcAppointmentsStore extends ChangeNotifier with TtcSyncedStore {
  TtcAppointmentsStore._() {
    _loading = _load();
  }

  late final Future<void> _loading;
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
    bool remindEveningBefore = false,
  }) {
    final a = TtcAppointment(
      id: 'ttca_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      withWhom: withWhom.trim(),
      startsUtc: startsLocal.toUtc(),
      note: note,
      remindEveningBefore: remindEveningBefore,
    );
    _items.add(a);
    _persist();
    _arm(a);
    notifyListeners();
    return a;
  }

  /// Swap an appointment for an edited copy, keeping its id (added
  /// 2026-09-27: a moved scan used to mean delete and add again).
  ///
  /// The push rides on `notifyListeners`, like every change here: the synced
  /// mixin upserts the whole list by id, so an edit is the same write as an
  /// add. The reminder is cancelled and set again, because the date may have
  /// moved.
  void update(TtcAppointment updated) {
    final i = _items.indexWhere((e) => e.id == updated.id);
    if (i < 0) return;
    _items[i] = updated;
    _persist();
    _arm(updated);
    notifyListeners();
  }

  // ---- the evening-before reminder ------------------------------------------

  /// Swappable so a test can see what would be scheduled.
  @visibleForTesting
  static TtcApptSchedule schedulePhone = ({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) =>
      NotificationService.instance
          .scheduleOneOff(id: id, title: title, body: body, when: when);

  @visibleForTesting
  static Future<void> Function(int id) cancelPhone =
      (id) => NotificationService.instance.cancel(id);

  /// Cancels this appointment's reminder, then sets it again if she asked for
  /// one and the evening has not passed. Fire-and-forget: a phone that cannot
  /// schedule must never stop an appointment being saved.
  void _arm(TtcAppointment a) {
    final id = ttcAppointmentReminderId(a.id);
    cancelPhone(id).catchError((_) {});
    if (!a.remindEveningBefore) return;
    if (!a.reminderAt.isAfter(DateTime.now())) return;
    final l = a.startsLocal;
    final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
    final time = '$h:${l.minute.toString().padLeft(2, '0')}'
        '${l.hour < 12 ? 'am' : 'pm'}';
    schedulePhone(
      id: id,
      title: 'Tomorrow: ${a.title}',
      body: a.withWhom.isEmpty
          ? 'At $time.'
          : 'At $time, with ${a.withWhom}.',
      when: a.reminderAt,
    ).catchError((_) {});
  }

  /// Sets every upcoming reminder again after launch.
  ///
  /// ⚠️ MUST RUN AFTER `ReminderStore.init`, for the reason the TTC messages
  /// and the trigger injection already follow: `NotificationService.syncAll` calls
  /// `cancelAll()` on every launch and wipes anything scheduled before it.
  /// See `main.dart` and the head of `ttc_messages_store.dart`.
  Future<void> rearmAfterStartup() async {
    await _loading;
    for (final a in _items) {
      if (a.remindEveningBefore && a.isUpcoming) _arm(a);
    }
  }

  void remove(String id) {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    if (_items.length == before) return;
    cancelPhone(ttcAppointmentReminderId(id)).catchError((_) {});
    _persist();
    if (SupabaseRepo.isLoggedIn) {
      SupabaseRepo.delete('ttc_appointments', id).catchError((_) {});
    }
    notifyListeners();
  }

  /// Puts a removed appointment back, same id, for the Undo after a remove
  /// (added 2026-09-27, tool rebuild).
  ///
  /// ⚠️ THE SAME ID IS THE WHOLE TRICK. The cloud delete has already gone
  /// out; because the app owns row ids, putting the row back is an ordinary
  /// upsert by id on the next push, not a new appointment with a new
  /// identity. The reminder is armed again if it still has an evening to
  /// ring on.
  void restore(TtcAppointment a) {
    if (_items.any((e) => e.id == a.id)) return;
    _items.add(a);
    _persist();
    _arm(a);
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

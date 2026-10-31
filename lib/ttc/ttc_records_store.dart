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
import '../services/notification_link.dart';
import '../services/remote/storage_service.dart';
import '../services/remote/supabase_repo.dart';
// The evening-before reminder says how many questions a visit has
// (2026-09-28). The two stores import each other, which Dart allows; the
// questions store reads the visits' dates, this one reads the counts.
import 'ttc_doctor_questions_store.dart' show TtcDoctorQuestionsStore;
import 'ttc_row_merge.dart';
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
  /// ⚠️ SENT SINCE 2026-10-29 (T4 B3, migration 0127 `files`). It was
  /// local-only, and that made a sign-out a deletion: `LocalWipe` clears the
  /// prefs cache, the pull rebuilt each row with no files, and the photos sat
  /// in storage with nothing pointing at them. A cache is not a record. The
  /// column costs one migration and makes the cloud the record's memory. An
  /// older row with no `files` (null) keeps whatever this phone holds.
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
        // Cached on disk with the rest of the row, and sent up as the `files`
        // column since T4 B3 (`_cloudColumns`).
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

  /// Edit times, removals, owners and what is waiting to upload (0098).
  static const _bookKey = 'ttc_records_sync';
  final TtcRowBook _book = TtcRowBook();

  /// Scans of removed results, waiting to be deleted from storage (T4 W12,
  /// 2026-10-29). Remove said the record goes "with its photos", and nothing
  /// ever deleted the uploaded scan. A removal can be undone (the toast, or
  /// the other phone), so the files are not deleted at the tap: they wait
  /// here, id -> (when removed, the refs), and go once the removal is as old
  /// as the phone's own memory of it ([SyncRowBook.keepRemovals]). Only the
  /// phone that removed it sweeps, which is also the phone whose user owns
  /// the storage path.
  static const _sweepKey = 'ttc_records_file_sweep';
  final Map<String, ({int at, List<String> files})> _sweep = {};

  final List<TtcRecord> _items = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Results the cloud has not confirmed: the sign-out sheet and Settings
  /// read this through `SyncRegistry.hasPendingChanges`.
  @override
  bool get hasPendingPush => _book.dirty.isNotEmpty;

  @visibleForTesting
  TtcRowBook get bookForTest => _book;

  /// Newest result first - how a folder of reports is actually read.
  List<TtcRecord> get records {
    final out = [..._items]..sort((a, b) => b.takenOn.compareTo(a.takenOn));
    return List.unmodifiable(out);
  }

  int get count => _items.length;

  /// Whether this phone's account may change [id] (T4 Q2, 0127): a row made
  /// here (no owner noted) or one the cloud says is ours. Each partner
  /// changes only their own results; the other's are read-only, in the UI
  /// and in RLS.
  bool isMine(String id) {
    final owner = _book.owners[id];
    return owner == null || owner == SupabaseRepo.userId;
  }

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
    _book.touch(r.id);
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

  /// ⚠️ A SOFT DELETE SINCE 0098 (2026-10-17). The hard delete below was one
  /// call that could miss (offline, racing an upload), and the next pull then
  /// brought the result back. Now the removal is a row with a time, uploaded
  /// like any edit, so every phone takes it and an older copy cannot undo it.
  void remove(String id) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final gone = _items.removeAt(i);
    _book.remove(id, _cloudColumns(gone));
    if (gone.attachments.isNotEmpty) {
      _sweep[id] = (
        at: DateTime.now().toUtc().millisecondsSinceEpoch,
        files: gone.attachments,
      );
    }
    _persist();
    // Kept for revert (2026-10-17):
    //   if (SupabaseRepo.isLoggedIn) {
    //     SupabaseRepo.delete('ttc_records', id).catchError((_) {});
    //   }
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
  ///
  /// ⚠️ SUPERSEDED 2026-10-17 (0098): there is no delete request to race any
  /// more. The removal and the Undo are two changes to one row, each with a
  /// time, and the Undo is newer, so it wins on every phone.
  void restore(Iterable<TtcRecord> rows) {
    var changed = false;
    for (final r in rows) {
      if (_items.any((e) => e.id == r.id)) continue;
      _items.add(r);
      _book.touch(r.id);
      _sweep.remove(r.id);
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
  /// date or number travels, and since T4 B3 the attachment list does too
  /// (the `files` column, see `attachments`).
  ///
  /// (Corrected 2026-09-27. This comment used to say "does NOT push", which
  /// was never true of the mixin, and mattered once edits of synced fields
  /// arrived.)
  void replace(TtcRecord updated) {
    final i = _items.indexWhere((e) => e.id == updated.id);
    if (i < 0) return;
    _items[i] = updated;
    _book.touch(updated.id);
    _persist();
    notifyListeners();
  }

  /// A sign-out, or another account signing in (2026-10-17): this store forgets the person in memory; the cloud keeps it.
  @override
  void resetLocal() => resetForTest();

  @visibleForTesting
  void resetForTest() {
    _items.clear();
    _book.clear();
    _sweep.clear();
    _loaded = true;
    notifyListeners();
  }

  // ---- cloud ----------------------------------------------------------------

  /// The row's own columns, without the owner or the two times. Nulls are
  /// sent, not left out, so clearing a note on one phone clears it everywhere.
  static Map<String, dynamic> _cloudColumns(TtcRecord r) => {
        'test_id': r.testId,
        'label': r.label,
        'value': r.value,
        'unit': r.unit,
        'taken_on': TtcSyncUtil.date(r.takenOn),
        'note': r.note,
        'for_partner': r.forPartner,
        // T4 B3 (0127): the storage refs, so a sign-out or a second phone
        // keeps the scan. Always sent, an empty list included, so removing the
        // last photo on one phone removes it everywhere.
        'files': r.attachments,
      };

  // ⚠️ NEWER WINS, BOTH WAYS (2026-10-17, 0098). The union pull kept
  // whatever this phone had, so an edit made on the other phone never
  // arrived and a removal made there came back from here. Kept for revert
  // as `_pullUnionKept`.
  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared('ttc_records',
        orderBy: 'taken_on', ascending: true);
    applyCloudRows(rows);
    await _sweepFiles();
  }

  /// Deletes the scans of removals that are now final (W12). Best-effort,
  /// like every storage call: a miss is retried on the next pull.
  Future<void> _sweepFiles() async {
    if (_sweep.isEmpty) return;
    final due = ttcFilesDueForSweep(_sweep,
        liveIds: {for (final r in _items) r.id},
        nowMs: DateTime.now().toUtc().millisecondsSinceEpoch);
    if (due.drop.isEmpty) return;
    for (final ref in due.delete) {
      await StorageService.remove(ref);
    }
    due.drop.forEach(_sweep.remove);
    await _persist();
  }

  @visibleForTesting
  Map<String, ({int at, List<String> files})> get sweepForTest => _sweep;

  /// The merge, network-free so a test can hand it rows.
  @visibleForTesting
  void applyCloudRows(List<Map<String, dynamic>> rows) {
    for (final row in _book.merge(_items.map((e) => e.id), rows)) {
      final id = row['id'] as String;
      final i = _items.indexWhere((e) => e.id == id);
      if (_book.removed.containsKey(id)) {
        if (i >= 0) _items.removeAt(i);
        continue;
      }
      final on = TtcSyncUtil.parseDate(row['taken_on']);
      if (on == null) continue;
      final r = TtcRecord(
        id: id,
        testId: row['test_id'] as String?,
        label: (row['label'] as String?) ?? '',
        value: (row['value'] as String?) ?? '',
        unit: (row['unit'] as String?) ?? '',
        takenOn: on,
        note: row['note'] as String?,
        forPartner: row['for_partner'] == true,
        // The cloud carries them since T4 B3. A row from before 0127 has
        // null there: keep this phone's list, as before. Kept for revert:
        //   attachments: i >= 0 ? _items[i].attachments : const [],
        attachments: ttcFilesFromCloud(row['files']) ??
            (i >= 0 ? _items[i].attachments : const []),
      );
      if (i >= 0) {
        _items[i] = r;
      } else {
        _items.add(r);
      }
    }
  }

  // Kept for revert (2026-10-17): the union pull.
  // ignore: unused_element
  Future<void> _pullUnionKept() async {
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

  /// Uploads only what is waiting, each row confirmed (2026-10-17, 0098).
  ///
  /// ⚠️ THE OWNER GOES BACK UNCHANGED. The old push below wrote
  /// `user_id: <me>` on every row, the partner's included, so an upsert by id
  /// turned his result into hers. A row pulled from the cloud keeps the
  /// cloud's `user_id`; only a row made on this phone takes ours.
  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    for (final id in List.of(_book.dirty)) {
      final live = _items.where((e) => e.id == id).firstOrNull;
      final cols = live != null ? _cloudColumns(live) : _book.removedRows[id];
      if (cols == null) {
        _book.dirty.remove(id);
        continue;
      }
      // ⚠️ THE PARTNER'S ROW IS NOT OURS TO SEND (T4 Q2, 0127). Each partner
      // changes only their own results, and RLS refuses the rest, so a row
      // owned by the other account would wait here and retry for ever.
      final owner = _book.owners[id];
      if (owner != null && owner != uid) {
        _book.dirty.remove(id);
        continue;
      }
      final sent = _book.stamps[id] ??=
          DateTime.now().toUtc().millisecondsSinceEpoch;
      final t = _book.times(id);
      final ok = await TtcSyncUtil.upsertConfirmed(
        'ttc_records',
        {
          ...cols,
          'id': id,
          'user_id': _book.owners[id] ?? uid,
          'updated_at': t.updatedAt,
          'removed_at': live == null ? t.removedAt : null,
        },
        onConflict: 'id',
      );
      _book.confirmed(id, ok: ok, sent: sent);
    }
    await _persist();
  }

  // Kept for revert (2026-10-17): every row, every time, as ours.
  // ignore: unused_element
  Future<void> _pushAllKept() async {
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
      final book = p.getString(_bookKey);
      if (book != null) _book.loadJson(jsonDecode(book));
      final sweep = p.getString(_sweepKey);
      if (sweep != null) {
        final m = jsonDecode(sweep);
        if (m is Map) {
          for (final e in m.entries) {
            final v = e.value;
            if (v is Map && v['at'] is int && v['files'] is List) {
              _sweep[e.key.toString()] = (
                at: v['at'] as int,
                files: [for (final f in v['files'] as List) f.toString()],
              );
            }
          }
        }
      }
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
      await p.setString(_bookKey, jsonEncode(_book.toJson()));
      await p.setString(
          _sweepKey,
          jsonEncode({
            for (final e in _sweep.entries)
              e.key: {'at': e.value.at, 'files': e.value.files},
          }));
    } catch (_) {/* best-effort */}
  }
}

/// Which waiting scans to delete now (T4 W12), network-free so a test can
/// drive it. A removal older than [SyncRowBook.keepRemovals] is final: its
/// files go in `delete` and its id in `drop`. A removal that came back (the id
/// is live again, an Undo on either phone) is dropped with nothing deleted.
({Set<String> drop, List<String> delete}) ttcFilesDueForSweep(
  Map<String, ({int at, List<String> files})> sweep, {
  required Set<String> liveIds,
  required int nowMs,
}) {
  final cutoff = nowMs - SyncRowBook.keepRemovals.inMilliseconds;
  final drop = <String>{};
  final delete = <String>[];
  for (final e in sweep.entries) {
    if (liveIds.contains(e.key)) {
      drop.add(e.key);
    } else if (e.value.at < cutoff) {
      drop.add(e.key);
      delete.addAll(e.value.files);
    }
  }
  return (drop: drop, delete: delete);
}

// =============================================================================
//  Appointments
// =============================================================================

/// An appointment the couple arranged themselves.
///
/// Separate from the booking engine's `Booking`, deliberately: those are things
/// When a visit's reminder rings, and why (2026-10-01).
///
/// ⚠️ THE EVENING BEFORE IS ONLY RIGHT WHEN THERE IS AN EVENING BEFORE. The
/// reminder was fixed at 7 pm the day before. A visit booked for 10 am
/// tomorrow, at 10 pm tonight, had that moment already behind it, so `_arm`
/// quietly set nothing, while the screen still said "Your phone will remind
/// you at 7 pm the day before" (the user). A promise the app cannot keep and
/// does not retract is the worst version of the bug.
///
/// So it is a rule, worked out when she saves, and said on the screen:
///   · the evening before (7 pm the day before), when that is still ahead;
///   · otherwise 2 hours before the visit;
///   · otherwise 30 minutes before;
///   · otherwise none: the visit is too soon, and the app says so.
/// "Derive, never ask": she is not made to choose among three. The time it
/// settles on is stored with the visit (local only, like the switch itself),
/// so it does not move later: the evening reminder that has rung is not
/// followed by a "2 hours before" the next time the app opens.
enum TtcApptReminderKind {
  eveningBefore,
  twoHoursBefore,
  thirtyMinutesBefore,
  none,
}

({DateTime? at, TtcApptReminderKind kind}) ttcApptReminderPlan(
  DateTime startsLocal, {
  DateTime? now,
}) {
  final n = (now ?? DateTime.now()).add(const Duration(minutes: 1));
  final d = startsLocal.subtract(const Duration(days: 1));
  final evening = DateTime(d.year, d.month, d.day, 19);
  if (evening.isAfter(n)) {
    return (at: evening, kind: TtcApptReminderKind.eveningBefore);
  }
  final two = startsLocal.subtract(const Duration(hours: 2));
  if (two.isAfter(n)) {
    return (at: two, kind: TtcApptReminderKind.twoHoursBefore);
  }
  final thirty = startsLocal.subtract(const Duration(minutes: 30));
  if (thirty.isAfter(n)) {
    return (at: thirty, kind: TtcApptReminderKind.thirtyMinutesBefore);
  }
  return (at: null, kind: TtcApptReminderKind.none);
}

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
    this.remindAtUtc,
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

  /// When the reminder rings, as decided when she saved ([ttcApptReminderPlan]),
  /// stored with the visit and kept on this phone only. Null on a visit saved
  /// before 2026-10-01, which keeps its 7 pm the day before.
  final DateTime? remindAtUtc;

  DateTime get startsLocal => startsUtc.toLocal();
  bool get isUpcoming => startsUtc.isAfter(DateTime.now().toUtc());

  /// When the reminder rings: the time it settled on, or 7 pm the day before
  /// for a visit that was saved with the old fixed rule.
  DateTime get reminderAt {
    final stored = remindAtUtc;
    if (stored != null) return stored.toLocal();
    final d = startsLocal.subtract(const Duration(days: 1));
    return DateTime(d.year, d.month, d.day, 19);
  }

  /// Which of the rule's three times [reminderAt] is, from the two dates.
  TtcApptReminderKind get reminderKind {
    final r = reminderAt;
    final s = startsLocal;
    if (DateTime(r.year, r.month, r.day).isBefore(DateTime(s.year, s.month, s.day))) {
      return TtcApptReminderKind.eveningBefore;
    }
    return s.difference(r).inMinutes >= 90
        ? TtcApptReminderKind.twoHoursBefore
        : TtcApptReminderKind.thirtyMinutesBefore;
  }

  TtcAppointment copyWith({
    String? title,
    String? withWhom,
    DateTime? startsLocal,
    bool? remindEveningBefore,
    DateTime? remindAtUtc,
    bool clearRemindAt = false,
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
        remindAtUtc: clearRemindAt ? null : (remindAtUtc ?? this.remindAtUtc),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'with': withWhom,
        'at': startsUtc.toIso8601String(),
        if (note != null) 'note': note,
        if (remindEveningBefore) 'remind': true,
        if (remindEveningBefore && remindAtUtc != null)
          'remind_at': remindAtUtc!.toIso8601String(),
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
      remindAtUtc: DateTime.tryParse(raw['remind_at']?.toString() ?? '')?.toUtc(),
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
///
/// [payload] (6b leftover L4): what a tap opens, this appointment.
typedef TtcApptSchedule = Future<void> Function(
    {required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload});

class TtcAppointmentsStore extends ChangeNotifier with TtcSyncedStore {
  TtcAppointmentsStore._() {
    _loading = _load();
  }

  late final Future<void> _loading;
  static final TtcAppointmentsStore instance = TtcAppointmentsStore._();

  static const _key = 'ttc_appointments';

  /// Edit times, removals, owners and what is waiting to upload (0098).
  static const _bookKey = 'ttc_appointments_sync';
  final TtcRowBook _book = TtcRowBook();

  final List<TtcAppointment> _items = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  @override
  bool get hasPendingPush => _book.dirty.isNotEmpty;

  @visibleForTesting
  TtcRowBook get bookForTest => _book;

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
    // ⚠️ THE CLOCK IS NOT AN ID GENERATOR ON ITS OWN (2026-09-28, the same
    // fix the questions store carries). Two adds in one Windows clock tick
    // gave two visits one id, and a question pinned to one then sat on
    // both. Stepped past any id already taken.
    // Kept for revert: id: 'ttca_${DateTime.now().microsecondsSinceEpoch}',
    var n = DateTime.now().microsecondsSinceEpoch;
    while (_items.any((e) => e.id == 'ttca_$n')) {
      n++;
    }
    final a = _withReminderPlan(TtcAppointment(
      id: 'ttca_$n',
      title: title.trim(),
      withWhom: withWhom.trim(),
      startsUtc: startsLocal.toUtc(),
      note: note,
      remindEveningBefore: remindEveningBefore,
    ));
    _items.add(a);
    _book.touch(a.id);
    _persist();
    _arm(a);
    // A new visit can take unticked questions from the one after it.
    rearmReminders(except: a.id);
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
    final planned = _withReminderPlan(updated, before: _items[i]);
    _items[i] = planned;
    _book.touch(planned.id);
    _persist();
    _arm(planned);
    rearmReminders(except: planned.id);
    notifyListeners();
  }

  /// Settles WHEN the reminder rings and keeps it, or switches it off when
  /// the visit is too soon for one ([ttcApptReminderPlan]).
  ///
  /// A visit whose start and switch have not changed keeps the time it already
  /// settled on, so a reminder that has rung is never followed by a fresh one
  /// the next time the list is saved.
  TtcAppointment _withReminderPlan(TtcAppointment a, {TtcAppointment? before}) {
    if (!a.remindEveningBefore) {
      return a.remindAtUtc == null ? a : a.copyWith(clearRemindAt: true);
    }
    if (before != null &&
        before.remindEveningBefore &&
        before.remindAtUtc != null &&
        before.startsUtc == a.startsUtc) {
      return a.copyWith(remindAtUtc: before.remindAtUtc);
    }
    final plan = ttcApptReminderPlan(a.startsLocal);
    if (plan.at == null) {
      // Too soon for any reminder: the switch goes off, and the screen has
      // already said so before she saved.
      return a.copyWith(remindEveningBefore: false, clearRemindAt: true);
    }
    return a.copyWith(remindAtUtc: plan.at!.toUtc());
  }

  // ---- the evening-before reminder ------------------------------------------

  /// Swappable so a test can see what would be scheduled.
  @visibleForTesting
  static TtcApptSchedule schedulePhone = ({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) =>
      NotificationService.instance.scheduleOneOff(
          id: id, title: title, body: body, when: when, payload: payload);

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
    // Kept for revert (2026-09-28): the title and body were built inline
    // here; they now come from `reminderText`, which adds the questions.
    //   final l = a.startsLocal; ... title: 'Tomorrow: ${a.title}',
    //   body: a.withWhom.isEmpty ? 'At $time.' : 'At $time, with ${a.withWhom}.',
    //
    // ⚠️ COUNTED AS OF THE MOMENT IT RINGS, NOT NOW. A visit on Monday rolls
    // its unticked questions onto Wednesday's visit on Tuesday morning;
    // Wednesday's reminder rings on Tuesday evening, so it has to count them.
    // The questions store derives that from a clock, so it is asked for 7 pm
    // tomorrow rather than this minute.
    var questions = 0;
    try {
      questions = TtcDoctorQuestionsStore.instance
          .openCountFor(a.id, now: a.reminderAt);
    } catch (_) {/* a count must never stop a reminder */}
    final text = reminderText(a, questions: questions);
    schedulePhone(
      id: id,
      title: text.title,
      body: text.body,
      when: a.reminderAt,
      payload: NotificationLink(NotificationLink.ttcAppointment, a.id).payload, // 6b L4
    ).catchError((_) {});
  }

  /// What the evening-before reminder says. With questions saved for the
  /// visit it adds "· 2 questions to ask"; with none it is exactly what it
  /// said before (2026-09-28).
  static ({String title, String body}) reminderText(TtcAppointment a,
      {int questions = 0}) {
    final l = a.startsLocal;
    final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
    final time = '$h:${l.minute.toString().padLeft(2, '0')}'
        '${l.hour < 12 ? 'am' : 'pm'}';
    final where =
        a.withWhom.isEmpty ? 'At $time' : 'At $time, with ${a.withWhom}';
    // "Tomorrow" only when it rings the evening before; a same-day reminder
    // says "Today" (2026-10-01).
    final day = a.reminderKind == TtcApptReminderKind.eveningBefore
        ? 'Tomorrow'
        : 'Today';
    return (
      title: '$day: ${a.title}',
      body: questions <= 0
          ? '$where.'
          : '$where · $questions '
              '${questions == 1 ? 'question' : 'questions'} to ask.',
    );
  }

  /// Sets every coming reminder again, except [except]'s (the caller has
  /// just armed that one). Called when a question changes, because each
  /// reminder carries its visit's count, and when a visit is added, moved or
  /// removed, because unticked questions follow the order of the visits.
  void rearmReminders({String? except}) {
    for (final a in _items) {
      if (a.id == except) continue;
      if (a.remindEveningBefore && a.isUpcoming) _arm(a);
    }
  }

  /// Sets every upcoming reminder again after launch.
  ///
  /// ⚠️ MUST RUN AFTER `ReminderStore.init`, for the reason the TTC messages
  /// and the trigger injection already follow: `NotificationService.syncAll` calls
  /// `cancelAll()` on every launch and wipes anything scheduled before it.
  /// See `main.dart` and the head of `ttc_messages_store.dart`.
  Future<void> rearmAfterStartup() async {
    await _loading;
    // The reminders count each visit's questions (2026-09-28), so the local
    // list must be in first. Local only: this never waits on a network.
    try {
      await TtcDoctorQuestionsStore.instance.init();
    } catch (_) {/* armed without a count, never not armed */}
    for (final a in _items) {
      if (a.remindEveningBefore && a.isUpcoming) _arm(a);
    }
  }

  /// A soft delete since 0098 (2026-10-17), for the reason on
  /// `TtcRecordsStore.remove`.
  void remove(String id) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final gone = _items.removeAt(i);
    _book.remove(id, _cloudColumns(gone));
    // Its unticked questions roll to the next visit, whose count changes.
    rearmReminders();
    cancelPhone(ttcAppointmentReminderId(id)).catchError((_) {});
    _persist();
    // Kept for revert (2026-10-17):
    //   if (SupabaseRepo.isLoggedIn) {
    //     SupabaseRepo.delete('ttc_appointments', id).catchError((_) {});
    //   }
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
    _book.touch(a.id);
    _persist();
    _arm(a);
    rearmReminders(except: a.id);
    notifyListeners();
  }

  /// A sign-out, or another account signing in (2026-10-17): this store forgets the person in memory; the cloud keeps it.
  @override
  void resetLocal() => resetForTest();

  @visibleForTesting
  void resetForTest() {
    _items.clear();
    _book.clear();
    _loaded = true;
    notifyListeners();
  }

  // ---- cloud ----------------------------------------------------------------

  /// The row's own columns, without the owner or the two times.
  static Map<String, dynamic> _cloudColumns(TtcAppointment a) => {
        'title': a.title,
        'with_whom': a.withWhom,
        'starts_utc': SupabaseRepo.dbTime(a.startsUtc),
        'note': a.note,
      };

  // Newer wins, both ways (2026-10-17, 0098), as on the records.
  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared('ttc_appointments',
        orderBy: 'starts_utc', ascending: true);
    applyCloudRows(rows);
  }

  /// The merge, network-free so a test can hand it rows.
  ///
  /// The reminder is this phone's (see `remindEveningBefore`), so taking the
  /// cloud's copy keeps it. A visit the other phone moved has its reminder
  /// worked out again; one it removed has its reminder cancelled here.
  @visibleForTesting
  void applyCloudRows(List<Map<String, dynamic>> rows) {
    final taken = _book.merge(_items.map((e) => e.id), rows);
    for (final row in taken) {
      final id = row['id'] as String;
      final i = _items.indexWhere((e) => e.id == id);
      if (_book.removed.containsKey(id)) {
        if (i >= 0) {
          _items.removeAt(i);
          cancelPhone(ttcAppointmentReminderId(id)).catchError((_) {});
        }
        continue;
      }
      final at = DateTime.tryParse(row['starts_utc']?.toString() ?? '');
      if (at == null) continue;
      final before = i >= 0 ? _items[i] : null;
      final a = _withReminderPlan(
        TtcAppointment(
          id: id,
          title: (row['title'] as String?) ?? '',
          withWhom: (row['with_whom'] as String?) ?? '',
          startsUtc: at.toUtc(),
          note: row['note'] as String?,
          remindEveningBefore: before?.remindEveningBefore ?? false,
          remindAtUtc: before?.remindAtUtc,
        ),
        before: before,
      );
      if (i >= 0) {
        _items[i] = a;
      } else {
        _items.add(a);
      }
      _arm(a);
    }
    if (taken.isNotEmpty) rearmReminders();
  }

  // Kept for revert (2026-10-17): the union pull.
  // ignore: unused_element
  Future<void> _pullUnionKept() async {
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

  /// Only what is waiting, confirmed, owner unchanged (2026-10-17, 0098),
  /// as on the records.
  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    for (final id in List.of(_book.dirty)) {
      final live = _items.where((e) => e.id == id).firstOrNull;
      final cols = live != null ? _cloudColumns(live) : _book.removedRows[id];
      if (cols == null) {
        _book.dirty.remove(id);
        continue;
      }
      final sent = _book.stamps[id] ??=
          DateTime.now().toUtc().millisecondsSinceEpoch;
      final t = _book.times(id);
      final ok = await TtcSyncUtil.upsertConfirmed(
        'ttc_appointments',
        {
          ...cols,
          'id': id,
          'user_id': _book.owners[id] ?? uid,
          'updated_at': t.updatedAt,
          'removed_at': live == null ? t.removedAt : null,
        },
        onConflict: 'id',
      );
      _book.confirmed(id, ok: ok, sent: sent);
    }
    await _persist();
  }

  // Kept for revert (2026-10-17): every row, every time, as ours.
  // ignore: unused_element
  Future<void> _pushAllKept() async {
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
      final book = p.getString(_bookKey);
      if (book != null) _book.loadJson(jsonDecode(book));
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
      await p.setString(_bookKey, jsonEncode(_book.toJson()));
    } catch (_) {/* best-effort */}
  }
}

/// The `files` column of a `ttc_records` row (T4 B3). Null when the column is
/// null or missing (a row written before 0127), so the caller keeps its own
/// list; a list, empty included, when the cloud has spoken.
List<String>? ttcFilesFromCloud(Object? raw) {
  if (raw is! List) return null;
  return [for (final f in raw) if (f != null) f.toString()];
}

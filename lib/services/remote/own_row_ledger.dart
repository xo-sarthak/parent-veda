// =============================================================================
//  OwnRowLedger: newer-wins sync for ONE PERSON'S row tables
//  (2026-10-20, sync log step 8, migration 0106)
// -----------------------------------------------------------------------------
//  The Pregnancy tables (her calendar, bump photos, daily moods, reminders, ...)
//  are own-only: every policy is `auth.uid() = user_id`, and the partner can
//  neither read nor write them. So the rule is the one her cycle uses
//  (BACKEND-PATTERNS §16ii): the phone's edit time wins, a removal is a soft
//  delete that travels, and only rows the cloud has not confirmed go up.
//
//  This is [ChildLogLedger] (child_scoped_store.dart) without the child: no
//  "which child", no "whose row", every row upserted as us. One class for every
//  single-owner table, so the push loop is written once rather than per store.
//
//  KEYED TABLES. Some tables have no `id`: a mood is one row per `day`, a kept
//  affirmation one per `text`. [keyColumn] names the column; the book uses its
//  value (as a string) as the row's id, and the upsert conflicts on
//  `user_id,<keyColumn>`.
//
//  STATE TABLES ([hasRemovedAt] false). A row that is an answer, not a list
//  item ("felt movement today: not yet"), is never removed, only changed. It
//  sends no `removed_at`, and every key the book has stamped takes part in the
//  merge, so a change made here is never read as "absent, take the cloud's".
//
//  ONE-ROW TABLES ([OwnRowLedger.single], step 9, 0107). Her weight profile
//  and kegel routine are one row per person, keyed on `user_id` alone. The
//  book holds that row under the constant key [singleKey], the upsert
//  conflicts on `user_id`, and it is state (no `removed_at`).
// =============================================================================

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_repo.dart';
import 'sync_row_book.dart';

class OwnRowLedger {
  OwnRowLedger(
    this.table,
    this.prefsKey, {
    this.keyColumn = 'id',
    this.hasRemovedAt = true,
  }) : single = false;

  /// One row per person (weight profile, kegel routine): see the header.
  OwnRowLedger.single(this.table, this.prefsKey)
      : keyColumn = 'user_id',
        hasRemovedAt = false,
        single = true;

  /// The book key of a one-row table's only row.
  static const String singleKey = 'me';

  /// The cloud table, e.g. `calendar_personal_events`.
  final String table;

  /// Where the bookkeeping is cached, beside the store's own rows.
  final String prefsKey;

  /// The column that names a row: `id`, or `day` / `text` for keyed tables.
  final String keyColumn;

  /// False for a table whose rows are state (no `removed_at` column).
  final bool hasRemovedAt;

  /// True for a one-row table ([OwnRowLedger.single]).
  final bool single;

  final SyncRowBook book = SyncRowBook();

  /// key -> the row's columns at its last change, so a row the store no
  /// longer holds in its live list can still upload.
  final Map<String, Map<String, dynamic>> lastRows = {};

  bool _pushing = false;
  bool _again = false;

  /// Changes the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => book.dirty.isNotEmpty;

  /// The upsert's conflict target.
  String get onConflict => single
      ? 'user_id'
      : keyColumn == 'id'
          ? 'id'
          : 'user_id,$keyColumn';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (raw == null) return;
      final m = jsonDecode(raw);
      if (m is! Map) return;
      book.loadJson(m['book']);
      lastRows.clear();
      final l = m['lastRows'];
      if (l is Map) {
        for (final e in l.entries) {
          if (e.value is Map) {
            lastRows[e.key.toString()] =
                Map<String, dynamic>.from(e.value as Map);
          }
        }
      }
    } catch (_) {/* start with an empty book */}
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          prefsKey, jsonEncode({'book': book.toJson(), 'lastRows': lastRows}));
    } catch (_) {}
  }

  void clear() {
    book.clear();
    lastRows.clear();
  }

  /// A row was added or changed on this phone. [columns], when given, are
  /// kept so the row can upload even after the store lets go of it.
  void touch(String key, {Map<String, dynamic>? columns}) {
    if (key.isEmpty) return;
    book.touch(key);
    if (columns != null) lastRows[key] = columns;
    save();
  }

  /// A row was removed on this phone. [columns] are its columns as they were,
  /// so the removal still fills the table's NOT NULL columns.
  void remove(String key, Map<String, dynamic> columns) {
    if (key.isEmpty) return;
    book.remove(key, columns);
    lastRows.remove(key);
    save();
  }

  /// Pure: merges the cloud's [rows] against the keys the store holds live,
  /// newer wins per key. Returns the cloud rows the store must take, each with
  /// `id` set to its key: `removed_at` set means "remove it here", anything
  /// else "replace it with this". Newer local rows, and rows the cloud has
  /// never seen, are left waiting to upload.
  List<Map<String, dynamic>> apply({
    required Iterable<String> liveKeys,
    required List<Map<String, dynamic>> rows,
  }) {
    final cloud = <Map<String, dynamic>>[];
    for (final r in rows) {
      final key = single ? singleKey : r[keyColumn]?.toString();
      if (key == null || key.isEmpty) continue;
      cloud.add(keyColumn == 'id' ? r : {...r, 'id': key});
    }
    final live = <String>{
      for (final k in liveKeys)
        if (k.isNotEmpty) k,
      // A state row is never removed: every key changed here takes part.
      if (!hasRemovedAt) ...book.stamps.keys,
    };
    final taken = book.merge(live, cloud);
    for (final r in taken) {
      lastRows.remove(r['id']);
    }
    return taken;
  }

  /// Fetches this person's rows and [apply]s them.
  Future<List<Map<String, dynamic>>> pull({
    required Iterable<String> liveKeys,
    String? orderBy,
  }) async {
    // A one-row table has no created_at.
    final rows = await SupabaseRepo.fetch(table,
        orderBy: orderBy ?? (single ? 'updated_at' : 'created_at'));
    final taken = apply(liveKeys: liveKeys, rows: rows);
    await save();
    return taken;
  }

  /// Pure: what uploading [key] sends, from the rows the store holds now
  /// ([live], key -> columns), the row's last known columns, or its columns
  /// at removal. Null when there is nothing to send.
  Map<String, dynamic>? uploadFor(
    String key,
    Map<String, Map<String, dynamic>> live, {
    required String uid,
  }) {
    final cols = live[key] ?? lastRows[key] ?? book.removedRows[key];
    if (cols == null) return null;
    final t = book.times(key);
    return {
      ...cols,
      'user_id': uid,
      'updated_at': t.updatedAt,
      if (hasRemovedAt) 'removed_at': t.removedAt,
    };
  }

  /// Uploads every waiting row, one at a time. [live] gives the columns of
  /// the rows the store holds now (key -> columns, without `user_id` or the
  /// two times). A change made while it runs is picked up by a second pass.
  /// [onRemovalConfirmed] runs once the cloud has taken a removal: the place
  /// for a clean-up that must not happen earlier (a Storage file).
  Future<void> push(
    Map<String, Map<String, dynamic>> Function() live, {
    void Function(String key, Map<String, dynamic> columns)? onRemovalConfirmed,
  }) async {
    if (_pushing) {
      _again = true;
      return;
    }
    _pushing = true;
    try {
      do {
        _again = false;
        final uid = SupabaseRepo.userId;
        if (uid == null) return;
        final rows = live();
        for (final key in book.dirty.toList()) {
          final up = uploadFor(key, rows, uid: uid);
          if (up == null) continue;
          final sent = book.stamps[key];
          final gone = book.removed.containsKey(key)
              ? book.removedRows[key]
              : null;
          final ok = await SupabaseRepo.upsertRowConfirmed(table, up,
              onConflict: onConflict);
          book.confirmed(key, ok: ok, sent: sent);
          if (!book.dirty.contains(key)) {
            lastRows.remove(key);
            if (gone != null) onRemovalConfirmed?.call(key, gone);
          }
        }
        await save();
      } while (_again);
    } catch (_) {/* offline: still waiting, retried on the next sync */
    } finally {
      _pushing = false;
    }
  }
}

// =============================================================================
//  ChildSync - cloud sync helpers for the CHILD-SCOPED parenting tables
// -----------------------------------------------------------------------------
//  The sibling of CloudSyncedStore. That mixin serves the light "saved / liked /
//  preference" stores, which sync ONE blob per user into user_state and are
//  private to the person who set them. These helpers serve the other half: the
//  parenting stores whose rows are ABOUT A CHILD - health, growth, vaccinations,
//  feeds, sleeps, milestones, documents.
//
//  WHY THEY CAN'T USE CloudSyncedStore: user_state's RLS is own-only
//  (auth.uid() = user_id, all four policies in 0011). A feed log stored there
//  would be invisible to the other parent, silently breaking co-parenting. So
//  child data lives in real tables gated on public.my_child_ids() (0021), where
//  BOTH paired parents may read AND write the same rows.
//
//  Consequently `user_id` on these tables is ATTRIBUTION ("Dad logged this"),
//  never the access key - which is why every call below goes through the
//  co-parented SupabaseRepo variants (fetchByChild / upsert / deleteShared)
//  rather than the own-user ones the pregnancy side uses.
//
//  Same two non-negotiables as everywhere else: local-first (the caller loads
//  its prefs cache and notifies BEFORE any of this runs), and a cloud failure
//  is never a crash (every call is wrapped; offline degrades to local-only).
// =============================================================================

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_repo.dart';
import 'sync_row_book.dart';

// =============================================================================
//  ChildLogLedger: newer-wins sync for the child's LOG tables (2026-10-17, 0101)
// -----------------------------------------------------------------------------
//  Feeds, sleeps, nappies, pumping, tummy time and growth used [ChildSync.merge]
//  (a union) and [ChildSync.remove] (one hard delete). A union can never take
//  anything away, so a feed one parent deleted came back from the other
//  parent's phone; a hard delete fired offline was simply lost. Each of those
//  six stores now keeps one of these beside its rows: the same rule as the TTC
//  tables (BACKEND-PATTERNS §16ii), on the shared [SyncRowBook].
//
//  Two things are specific to child data:
//
//   · WHICH CHILD. A store's cache can hold rows of more than one child, but a
//     pull fetches one child's rows. The ledger remembers each row's child, so
//     a pull of child A neither re-uploads child B's rows under A nor reads B's
//     removals as "the cloud has never seen this".
//   · WHOSE ROW. `user_id` is attribution ("Dad logged this"). A row the
//     partner owns is sent as a plain UPDATE with no user_id, because an upsert
//     is checked against the INSERT policy (`auth.uid() = user_id`) even when
//     it ends up updating, and would be refused (0101's header).
// =============================================================================

class ChildLogLedger {
  ChildLogLedger(
    this.table,
    this.prefsKey, {
    this.keyColumn = 'id',
    this.ownerIsLastEditor = false,
    this.hasRemovedAt = true,
  });

  /// The cloud table, e.g. `pp_feed_logs`.
  final String table;

  /// Where the bookkeeping is cached, beside the store's own rows.
  final String prefsKey;

  /// The column that names a row within one child (2026-10-17, 0104). `id`
  /// for the id-keyed tables. A composite-key table names its own:
  /// `milestone_id`, `vaccine_id`, or `child_id` for the one-per-child
  /// emergency card. For those, the store speaks in keys and the book in
  /// `<child>|<key>`, so the same milestone of two children is two rows.
  final String keyColumn;

  /// The emergency card's UPDATE policy also pins `user_id` to the caller, so
  /// it can never be saved under the other parent's name: it is always
  /// upserted as us, and "owner" means "last editor".
  final bool ownerIsLastEditor;

  /// False for a table whose rows are state rather than list items
  /// (`pp_vaccine_doses`): it has no `removed_at` column, so none is sent.
  final bool hasRemovedAt;

  bool get _keyed => keyColumn != 'id';

  final SyncRowBook book = SyncRowBook();

  /// book id -> the child the row belongs to.
  final Map<String, String> childOf = {};

  /// Keyed tables only: book id -> the row's columns at its last change, so a
  /// row of a child that is not on screen can still upload.
  final Map<String, Map<String, dynamic>> lastRows = {};

  bool _pushing = false;
  bool _again = false;

  /// Changes the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => book.dirty.isNotEmpty;

  /// The book's id for [key] of [childId].
  String bookId(String childId, String key) => _keyed ? '$childId|$key' : key;

  /// Every key of [childId] this phone has changed and the book remembers.
  /// For a table whose rows are state (vaccine doses): a dose un-ticked here is
  /// in no local set any more, but it must still take part in the merge, or
  /// the cloud's older "done" would come back.
  Iterable<String> keysFor(String childId) => [
        for (final id in book.stamps.keys)
          if ((childOf[id] ?? '') == childId) keyOf(id),
      ];

  /// The store's key for a book id.
  String keyOf(String id) {
    if (!_keyed) return id;
    final i = id.indexOf('|');
    return i < 0 ? id : id.substring(i + 1);
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (raw == null) return;
      final m = jsonDecode(raw);
      if (m is! Map) return;
      book.loadJson(m['book']);
      childOf.clear();
      final c = m['childOf'];
      if (c is Map) {
        for (final e in c.entries) {
          childOf[e.key.toString()] = e.value.toString();
        }
      }
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
          prefsKey,
          jsonEncode({
            'book': book.toJson(),
            'childOf': childOf,
            if (_keyed) 'lastRows': lastRows,
          }));
    } catch (_) {}
  }

  void clear() {
    book.clear();
    childOf.clear();
    lastRows.clear();
  }

  /// A row was added or changed on this phone. Empty ids are seed content and
  /// never sync (BACKEND-PARENTING-BRIEF §5). A keyed table needs the child
  /// (no child yet means nothing to sync, as before) and the row's [columns].
  void touch(String id, String? childId, {Map<String, dynamic>? columns}) {
    if (id.isEmpty) return;
    if (_keyed && childId == null) return;
    final b = _keyed ? bookId(childId!, id) : id;
    book.touch(b);
    if (childId != null) childOf.putIfAbsent(b, () => childId);
    if (_keyed && columns != null) lastRows[b] = columns;
    save();
  }

  /// A row was removed on this phone. [columns] are its columns as they were,
  /// so the removal can still fill the table's NOT NULL columns.
  void remove(String id, Map<String, dynamic> columns, String? childId) {
    if (id.isEmpty) return;
    if (_keyed && childId == null) return;
    final b = _keyed ? bookId(childId!, id) : id;
    book.remove(b, columns);
    lastRows.remove(b);
    if (childId != null) childOf.putIfAbsent(b, () => childId);
    save();
  }

  /// Pure: merges [rows] (one child's cloud rows, removed ones included) into
  /// [local], newer wins per row, and returns the new list. Rows this phone
  /// holds that are newer, or that the cloud lacks, are left waiting to upload.
  /// [idOf] gives the store's key (the `id`, or the key column's value).
  List<T> apply<T>({
    required String childId,
    required List<T> local,
    required List<Map<String, dynamic>> rows,
    required String Function(T) idOf,
    required T Function(Map<String, dynamic>) fromRow,
  }) {
    final cloud = <Map<String, dynamic>>[];
    for (final r in rows) {
      final key = r[keyColumn]?.toString();
      if (key == null || key.isEmpty) continue;
      final b = bookId(childId, key);
      childOf[b] = childId;
      cloud.add(_keyed ? {...r, 'id': b} : r);
    }
    bool mine(String id) => (childOf[id] ?? childId) == childId;
    final taken = book.merge(
      [
        for (final item in local)
          if (idOf(item).isNotEmpty && mine(bookId(childId, idOf(item))))
            bookId(childId, idOf(item)),
      ],
      cloud,
      inScope: mine,
    );
    final byKey = <String, T>{for (final item in local) idOf(item): item};
    for (final r in taken) {
      final id = r['id'] as String;
      lastRows.remove(id);
      if (syncParseStamp(r['removed_at']) != null) {
        byKey.remove(keyOf(id));
      } else {
        byKey[keyOf(id)] = fromRow(r);
      }
    }
    return byKey.values.toList();
  }

  /// Fetches [childId]'s rows and [apply]s them.
  Future<List<T>> pull<T>({
    required String childId,
    required List<T> local,
    required String Function(T) idOf,
    required T Function(Map<String, dynamic>) fromRow,
    String orderBy = 'created_at',
  }) async {
    final rows =
        await SupabaseRepo.fetchByChild(table, childId, orderBy: orderBy);
    final merged = apply(
        childId: childId, local: local, rows: rows, idOf: idOf, fromRow: fromRow);
    await save();
    return merged;
  }

  /// Pure: what uploading book id [id] sends, from the rows held now ([live],
  /// by the store's key, for [fallbackChildId]'s rows) or the row's last
  /// known columns. Null when there is nothing to send yet (no columns, or no
  /// child to file it under).
  ///
  /// A row the partner owns goes as an UPDATE with no `id` or `user_id` in
  /// it, so "logged by" stays theirs; any other row is upserted as ours.
  ({bool asUpdate, Map<String, dynamic> row})? uploadFor(
    String id,
    Map<String, Map<String, dynamic>> live, {
    required String uid,
    String? fallbackChildId,
  }) {
    final child = childOf[id] ?? fallbackChildId;
    if (child == null) return null;
    final key = keyOf(id);
    final onScreen = !_keyed || child == fallbackChildId;
    final cols =
        (onScreen ? live[key] : null) ?? lastRows[id] ?? book.removedRows[id];
    if (cols == null) return null;
    final t = book.times(id);
    final row = <String, dynamic>{
      ...cols,
      if (_keyed) keyColumn: key,
      'child_id': child,
      'updated_at': t.updatedAt,
      if (hasRemovedAt) 'removed_at': t.removedAt,
    };
    final owner = book.owners[id];
    if (!ownerIsLastEditor && owner != null && owner != uid) {
      row
        ..remove('id')
        ..remove('user_id');
      return (asUpdate: true, row: row);
    }
    return (asUpdate: false, row: {...row, 'user_id': uid});
  }

  /// The upsert's conflict target.
  String get onConflict => !_keyed
      ? 'id'
      : keyColumn == 'child_id'
          ? 'child_id'
          : 'child_id,$keyColumn';

  /// Uploads every waiting row, one at a time. [live] gives the columns of
  /// the rows the store holds now (store key -> columns, without `child_id`,
  /// `user_id` or the two times). One upload runs at a time; a change made
  /// while it runs is picked up by a second pass.
  Future<void> push(
    Map<String, Map<String, dynamic>> Function() live, {
    String? fallbackChildId,
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
        for (final id in book.dirty.toList()) {
          final up = uploadFor(id, rows,
              uid: uid, fallbackChildId: fallbackChildId);
          if (up == null) continue;
          final sent = book.stamps[id];
          final bool ok;
          if (!up.asUpdate) {
            ok = await SupabaseRepo.upsertRowConfirmed(table, up.row,
                onConflict: onConflict);
          } else if (_keyed) {
            ok = await SupabaseRepo.updateChildRowConfirmed(table,
                up.row['child_id'] as String, keyColumn, keyOf(id), up.row);
          } else {
            ok = await SupabaseRepo.updateSharedConfirmed(table, id, up.row);
          }
          book.confirmed(id, ok: ok, sent: sent);
          if (!book.dirty.contains(id)) lastRows.remove(id);
        }
        await save();
      } while (_again);
    } catch (_) {/* offline: still waiting, retried on the next sync */
    } finally {
      _pushing = false;
    }
  }
}

class ChildSync {
  ChildSync._();

  /// Merge [local] with the child's cloud rows: adopt everything the cloud has,
  /// push up anything only this device has, and return the union.
  ///
  /// ⚠️ The six log stores moved to [ChildLogLedger] on 2026-10-17 (0101): a
  /// union cannot carry a removal. Documents, health, milestones and vaccines
  /// followed in step 6 (0104), so nothing live calls this now. Kept for revert.
  ///
  /// Rows whose id is EMPTY are seed/demo content and are never uploaded - the
  /// rule that keeps our fictional sample child out of real accounts
  /// (BACKEND-PARENTING-BRIEF §5).
  static Future<List<T>> merge<T>({
    required String table,
    required String childId,
    required List<T> local,
    required String Function(T) idOf,
    required Map<String, dynamic> Function(T) toRow,
    required T Function(Map<String, dynamic>) fromRow,
    String orderBy = 'created_at',
  }) async {
    final rows =
        await SupabaseRepo.fetchByChild(table, childId, orderBy: orderBy);
    final byId = {for (final r in rows) r['id'].toString(): fromRow(r)};
    for (final item in local) {
      final id = idOf(item);
      if (id.isEmpty || byId.containsKey(id)) continue;
      byId[id] = item;
      await SupabaseRepo.insert(table, {...toRow(item), 'child_id': childId});
    }
    return byId.values.toList();
  }

  /// Insert-or-update one row. No-op when logged out, seeded (empty id) or
  /// before a real child exists - all three mean "nothing to sync yet".
  static Future<void> push(
    String table,
    String? childId,
    String id,
    Map<String, dynamic> row,
  ) async {
    if (id.isEmpty || childId == null || !SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.upsert(table, {...row, 'child_id': childId},
          onConflict: 'id');
    } catch (_) {/* offline - reconciled on the next sync */}
  }

  /// Delete one row (co-parented: either parent may remove what the other
  /// logged).
  static Future<void> remove(String table, String id) async {
    if (id.isEmpty || !SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.deleteShared(table, id);
    } catch (_) {}
  }

  /// Upsert a row on a composite-key table - vaccine doses (child_id,
  /// vaccine_id) and milestone observations (child_id, milestone_id), where
  /// there is no single `id` column and recording is idempotent.
  static Future<void> pushKeyed(
    String table,
    String? childId,
    Map<String, dynamic> row, {
    required String onConflict,
  }) async {
    if (childId == null || !SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.upsert(table, {...row, 'child_id': childId},
          onConflict: onConflict);
    } catch (_) {}
  }

  /// Delete a row from a composite-key table, matched on [column] == [value]
  /// for this child.
  static Future<void> removeKeyed(
    String table,
    String? childId,
    String column,
    String value,
  ) async {
    if (childId == null || !SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.deleteChildRow(table, childId, column, value);
    } catch (_) {}
  }
}

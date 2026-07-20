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

import 'supabase_repo.dart';

class ChildSync {
  ChildSync._();

  /// Merge [local] with the child's cloud rows: adopt everything the cloud has,
  /// push up anything only this device has, and return the union.
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

import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared cloud data-access layer ("repository") for ParentVeda.
///
/// WHY THIS EXISTS:
/// Every store needs the same handful of Supabase operations — load my rows,
/// add a row, update a row, delete a row. Instead of copy-pasting those calls
/// into all ~25 stores, they ALL go through this one helper. Benefits:
///   * one place to change how syncing works (offline queue, retries, logging),
///   * every table is automatically filtered to the logged-in user, so the
///     "only see your own data" rule lives in ONE spot (no drift, no leaks),
///   * each store stays focused on its own logic instead of Supabase plumbing.
///
/// LOCAL-FIRST: these are the CLOUD half only. Each store keeps its existing
/// shared_preferences cache for instant, offline-capable reads, and uses these
/// methods to sync up/down. If nobody is logged in, reads return an empty list
/// and writes are skipped — so the app keeps working from its local cache.
///
/// All methods are scoped to the current user via `user_id`. (Row-Level
/// Security enforces the same thing on the server; this is the client-side
/// twin so we never even send a cross-user request.)
class SupabaseRepo {
  SupabaseRepo._(); // static-only; never instantiated.

  static SupabaseClient get _client => Supabase.instance.client;

  /// The current user's id, or null if not logged in.
  static String? get userId => _client.auth.currentUser?.id;

  /// True when someone is logged in (so cloud calls are possible).
  static bool get isLoggedIn => userId != null;

  /// Load ALL of the current user's rows from [table].
  /// Ordered by [orderBy] (defaults to created_at, newest first).
  /// Returns an empty list if logged out.
  static Future<List<Map<String, dynamic>>> fetch(
    String table, {
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    final uid = userId;
    if (uid == null) return [];
    final rows = await _client
        .from(table)
        .select()
        .eq('user_id', uid)
        .order(orderBy, ascending: ascending);
    return List<Map<String, dynamic>>.from(rows);
  }

  /// Fetch the current user's SINGLE row from [table] (for one-row-per-user
  /// tables like weight_profile / kegel_state). Returns null if none / logged out.
  static Future<Map<String, dynamic>?> fetchOne(String table) async {
    final uid = userId;
    if (uid == null) return null;
    final rows = await _client.from(table).select().eq('user_id', uid).limit(1);
    final list = List<Map<String, dynamic>>.from(rows);
    return list.isEmpty ? null : list.first;
  }

  /// Insert one row for the current user. `user_id` is attached automatically.
  /// Returns the saved row (including its generated id), or null if logged out.
  static Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final uid = userId;
    if (uid == null) return null;
    return _client
        .from(table)
        .insert({...data, 'user_id': uid})
        .select()
        .single();
  }

  /// Update the current user's row [id] in [table] with [changes].
  /// No-op if logged out. The user_id filter is a safety net on top of RLS.
  static Future<void> update(
    String table,
    String id,
    Map<String, dynamic> changes,
  ) async {
    final uid = userId;
    if (uid == null) return;
    await _client.from(table).update(changes).eq('id', id).eq('user_id', uid);
  }

  /// Delete the current user's row [id] from [table]. No-op if logged out.
  static Future<void> delete(String table, String id) async {
    final uid = userId;
    if (uid == null) return;
    await _client.from(table).delete().eq('id', id).eq('user_id', uid);
  }

  /// Delete the current user's rows in [table] where [column] == [value].
  /// For tables keyed by something other than `id` (e.g. completed_scans by
  /// scan_id, or all logs for a medication_id).
  static Future<void> deleteBy(String table, String column, Object value) async {
    final uid = userId;
    if (uid == null) return;
    await _client.from(table).delete().eq(column, value).eq('user_id', uid);
  }

  /// Delete ALL of the current user's rows in [table].
  static Future<void> clear(String table) async {
    final uid = userId;
    if (uid == null) return;
    await _client.from(table).delete().eq('user_id', uid);
  }

  /// Insert-or-update a SINGLE-row-per-user record (e.g. a settings/profile-like
  /// row), keyed by [onConflict] (defaults to user_id). Returns the saved row.
  static Future<Map<String, dynamic>?> upsert(
    String table,
    Map<String, dynamic> data, {
    String onConflict = 'user_id',
  }) async {
    final uid = userId;
    if (uid == null) return null;
    return _client
        .from(table)
        .upsert({...data, 'user_id': uid}, onConflict: onConflict)
        .select()
        .single();
  }
}

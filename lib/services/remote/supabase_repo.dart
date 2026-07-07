import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared cloud data-access layer ("repository") for ParentVeda.
///
/// WHY THIS EXISTS:
/// Every store needs the same handful of Supabase operations - load my rows,
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
/// and writes are skipped - so the app keeps working from its local cache.
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

  /// Fetch rows belonging to ANOTHER user (e.g. your paired partner) from
  /// [table]. RLS still applies - you only get rows the policies allow (own or
  /// partner). Used for the mother's merged journal view. [] if logged out.
  static Future<List<Map<String, dynamic>>> fetchByUser(
    String table,
    String otherUserId, {
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    if (userId == null) return [];
    final rows = await _client
        .from(table)
        .select()
        .eq('user_id', otherUserId)
        .order(orderBy, ascending: ascending);
    return List<Map<String, dynamic>>.from(rows);
  }

  /// The current user's paired partner id, or null (unpaired / logged out).
  /// Reads own profile row (allowed by RLS). Used to fetch the partner's data.
  static Future<String?> myPartnerId() async {
    final uid = userId;
    if (uid == null) return null;
    final row = await _client
        .from('profiles')
        .select('partner_id')
        .eq('id', uid)
        .maybeSingle();
    return row?['partner_id'] as String?;
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

  // === Generic per-user key/value store (user_state table) ===================
  // Used by the lightweight "saved / liked / preference" stores via the
  // CloudSyncedStore mixin. Each store syncs one JSON blob under its store_key.

  /// Load this user's saved blob for [storeKey], or null if none / logged out.
  /// The value is whatever was saved (a Map or List), decoded from jsonb.
  static Future<dynamic> loadState(String storeKey) async {
    final uid = userId;
    if (uid == null) return null;
    final row = await _client
        .from('user_state')
        .select('data')
        .eq('user_id', uid)
        .eq('store_key', storeKey)
        .maybeSingle();
    return row?['data'];
  }

  /// Save this user's blob for [storeKey] (upsert on user_id+store_key).
  /// No-op if logged out. [data] is any json-encodable structure (Map/List).
  static Future<void> saveState(String storeKey, Object data) async {
    final uid = userId;
    if (uid == null) return;
    await _client.from('user_state').upsert(
      {
        'user_id': uid,
        'store_key': storeKey,
        'data': data,
      },
      onConflict: 'user_id,store_key',
    );
  }

  // === Timestamp helpers (for timestamptz columns) ==========================
  // Store the true UTC instant and read it back in LOCAL time, so a timestamp
  // written on one device doesn't drift by the timezone offset when another
  // device (or Postgres) reads it back. Use for real DateTime <-> timestamptz.
  static String dbTime(DateTime d) => d.toUtc().toIso8601String();
  static DateTime parseDbTime(Object? v) =>
      DateTime.tryParse(v?.toString() ?? '')?.toLocal() ?? DateTime.now();

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

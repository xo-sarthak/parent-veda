import 'package:flutter/foundation.dart';
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
  ///
  /// Also null when Supabase has not been initialised at all. Touching
  /// `Supabase.instance` before `Supabase.initialize()` THROWS an assertion,
  /// and this getter is the gate every store checks before a cloud call - so
  /// without this guard an uninitialised backend turns "sync is unavailable"
  /// into a crash, breaking the rule that a cloud failure must always degrade
  /// to local-only. That happens in widget tests (which never initialise
  /// Supabase) and would happen in the app if `initialize` ever failed.
  static String? get userId {
    try {
      return _client.auth.currentUser?.id;
    } catch (_) {
      return null; // not initialised - behave exactly like "logged out"
    }
  }

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

  // === Co-parented reads/writes (the PARENTING side) =======================
  // The pregnancy methods above all pin `.eq('user_id', uid)`, because there a
  // row belongs to the parent who wrote it and the partner may only READ it.
  //
  // Parenting data is different: it belongs to the CHILD, and both paired
  // parents share the same screens for the same baby, so either may read AND
  // write it (see 0021_children.sql). `user_id` there means "who logged this",
  // not "who may touch this" — so the own-user filter would wrongly HIDE the
  // partner's rows. These variants drop that filter and let RLS do the scoping
  // server-side (own child or partner's child, via public.my_child_ids()).
  //
  // Use these ONLY for child-scoped tables. Everything on the pregnancy side —
  // and every user_state/KV store — keeps using the own-user methods above.

  /// Load every row of [table] this user may see (own + partner's), scoped by
  /// RLS rather than by a user_id filter. [] if logged out.
  static Future<List<Map<String, dynamic>>> fetchShared(
    String table, {
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    if (userId == null) return [];
    final rows =
        await _client.from(table).select().order(orderBy, ascending: ascending);
    return List<Map<String, dynamic>>.from(rows);
  }

  /// Load every row of [table] belonging to ONE child (own or partner's).
  /// The workhorse read for parenting features. [] if logged out.
  static Future<List<Map<String, dynamic>>> fetchByChild(
    String table,
    String childId, {
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    if (userId == null) return [];
    final rows = await _client
        .from(table)
        .select()
        .eq('child_id', childId)
        .order(orderBy, ascending: ascending);
    return List<Map<String, dynamic>>.from(rows);
  }

  /// Update row [id] in a co-parented [table] — NO user_id filter, so a parent
  /// can correct an entry their partner logged. RLS still blocks any row whose
  /// child isn't theirs. No-op if logged out.
  static Future<void> updateShared(
    String table,
    String id,
    Map<String, dynamic> changes,
  ) async {
    if (userId == null) return;
    await _client.from(table).update(changes).eq('id', id);
  }

  /// Delete row [id] from a co-parented [table] (see [updateShared]).
  static Future<void> deleteShared(String table, String id) async {
    if (userId == null) return;
    await _client.from(table).delete().eq('id', id);
  }

  /// Delete from a composite-key child table, matched on [column] == [value]
  /// for [childId]. For tables keyed by (child_id, something) rather than an
  /// `id` column - vaccine doses, milestone observations.
  static Future<void> deleteChildRow(
    String table,
    String childId,
    String column,
    Object value,
  ) async {
    if (userId == null) return;
    await _client
        .from(table)
        .delete()
        .eq('child_id', childId)
        .eq(column, value);
  }

  /// Fire-and-forget insert for a WRITE-ONLY table, with NO `user_id` attached
  /// and NO row read back. For the analytics sink (`profile_events`, 0028):
  ///   * the table has no user_id - it is keyed to an anonymous install_id;
  ///   * it must accept inserts while logged OUT (the anon role), so this does
  ///     not gate on `isLoggedIn` the way [insert] does;
  ///   * it never chains `.select()`, so the insert uses `return=minimal` and
  ///     doesn't try to read the new row back (which the insert-only RLS would
  ///     refuse anyway - see 0028).
  /// Returns immediately; the write happens in the background and every error,
  /// sync or async, is swallowed. Analytics must never block or break a session.
  static void fireEvent(String table, Map<String, dynamic> row) {
    try {
      _client.from(table).insert(row).then((_) {}, onError: (_) {});
    } catch (_) {/* Supabase not ready / offline - drop the event silently */}
  }

  /// Call a Postgres function and return its rows as a list.
  ///
  /// Used where the ANSWER must be computed server-side rather than assembled
  /// from raw rows the client is allowed to read - baby-name matches being the
  /// case in point: the votes themselves are private to each parent, and only
  /// the intersection is exposed (see 0027_pp_name_votes.sql). [] if logged out.
  static Future<List<dynamic>> callFunction(
    String fn, [
    Map<String, dynamic>? params,
  ]) async {
    if (userId == null) return [];
    final res = await _client.rpc(fn, params: params);
    return res is List ? res : (res == null ? [] : [res]);
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

  // ---- the profile row ------------------------------------------------------
  // `profiles` is keyed by `id`, not `user_id`, so the generic helpers above do
  // not fit it. These two exist so nothing outside this file has to know that.

  /// Read [columns] from the current user's profile row. Null if logged out or
  /// on any failure - callers treat that exactly like "not set".
  static Future<Map<String, dynamic>?> fetchMyProfile(String columns) async {
    final uid = userId;
    if (uid == null) return null;
    try {
      final row = await _client
          .from('profiles')
          .select(columns)
          .eq('id', uid)
          .maybeSingle();
      return row == null ? null : Map<String, dynamic>.from(row);
    } catch (_) {
      return null;
    }
  }

  /// Update columns on the current user's profile row. Best-effort.
  static Future<void> updateMyProfile(Map<String, dynamic> changes) async {
    final uid = userId;
    if (uid == null) return;
    try {
      await _client.from('profiles').update(changes).eq('id', uid);
    } catch (_) {/* offline - the local cache still holds the value */}
  }

  /// Update the current user's profile row and REPORT whether it landed.
  ///
  /// The sibling above is fire-and-forget, which is the right default here: a
  /// cloud write failing must never break a screen, and the local cache still
  /// holds the value. The cost of that default is that it cannot distinguish
  /// "wrote 1 row" from "RLS refused" from "offline" — all three return void.
  ///
  /// That is unacceptable when the CALLER IS ABOUT TO DISCARD ITS ONLY OTHER
  /// COPY. `PendingProfile.flush` holds onboarding answers — her due date among
  /// them — that exist nowhere else until this write succeeds; clearing them on
  /// a write that quietly failed would lose them for good.
  ///
  /// `.select()` is what makes the difference: it makes Postgres return the rows
  /// the update actually touched, so an empty list means the write matched
  /// nothing (wrong id, or a policy refused it) even though no error was raised.
  /// A silent zero-row update is the failure mode this repo has been bitten by
  /// before, and it is invisible without asking for the rows back.
  ///
  /// Returns false when logged out, on any error, or when 0 rows changed.
  static Future<bool> updateMyProfileConfirmed(
      Map<String, dynamic> changes) async {
    final uid = userId;
    if (uid == null) return false;
    try {
      final rows =
          await _client.from('profiles').update(changes).eq('id', uid).select();
      return rows.isNotEmpty;
    } catch (_) {
      return false; // caller keeps its copy and retries later
    }
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

  // ---- booking engine (0029) ------------------------------------------------

  /// Claim a seat atomically via the book_slot() function. Returns true if the
  /// seat was granted, false if it was refused (slot full / already booked) OR
  /// we are offline / logged out — the caller treats false as "not confirmed
  /// on the server" and, offline, falls back to a local optimistic booking.
  ///
  /// The booking id is minted by the caller so the local row and the server row
  /// share an identity.
  static Future<bool> bookSlot({
    required String bookingId,
    required String slotId,
    required String offeringId,
    required String expertId,
    required DateTime startsUtc,
    required int durationMin,
    required int capacity,
    required String stage,
    required String title,
    String? joinUrl,
  }) async {
    if (userId == null) return false;
    try {
      await _client.rpc('book_slot', params: {
        'p_booking_id': bookingId,
        'p_slot_id': slotId,
        'p_offering_id': offeringId,
        'p_expert_id': expertId,
        'p_starts_utc': startsUtc.toUtc().toIso8601String(),
        'p_duration_min': durationMin,
        'p_capacity': capacity,
        'p_stage': stage,
        'p_title': title,
        'p_join_url': joinUrl,
      });
      return true;
    } catch (_) {
      // A raise ('slot full' / 'already booked') or a network error both mean
      // "the server did not grant this seat".
      return false;
    }
  }

  // ---- raw table helpers (for tables NOT keyed by user_id) ------------------

  /// Select every row of a public-read table (no user_id filter) — for shared
  /// catalogue-style tables like doctor_availability. Empty on any failure.
  static Future<List<Map<String, dynamic>>> selectAll(String table) async {
    try {
      final rows = await _client.from(table).select();
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      return const [];
    }
  }

  /// Upsert a raw row (no user_id injected) into a table with its own key.
  /// RLS still gates the write. Best-effort.
  static Future<void> upsertRow(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) async {
    if (userId == null) return;
    try {
      await _client.from(table).upsert(data, onConflict: onConflict);
    } catch (_) {/* best-effort */}
  }

  /// Update rows matching every column in [filters]. The mirror of
  /// [deleteMatch], for a table whose natural key is not `id` — a sample claim
  /// is identified by (campaign_id, user_id), not by a serial nobody holds.
  /// RLS gates which rows are reachable.
  static Future<void> updateMatch(
    String table,
    Map<String, Object> filters,
    Map<String, dynamic> changes,
  ) async {
    if (userId == null) return;
    var q = _client.from(table).update(changes);
    filters.forEach((k, v) => q = q.eq(k, v));
    await q;
  }

  /// Delete rows matching every column in [filters] (no user_id). RLS gates it.
  static Future<void> deleteMatch(
    String table,
    Map<String, Object> filters,
  ) async {
    if (userId == null) return;
    try {
      await _client.from(table).delete().match(filters);
    } catch (_) {/* best-effort */}
  }

  /// Free a seat via cancel_booking(). Best-effort: a failure here is not worth
  /// blocking the UI over — the local cancel still stands, and the ledger is
  /// reconciled on the next server round-trip.
  static Future<void> cancelBooking(String bookingId) async {
    if (userId == null) return;
    try {
      await _client.rpc('cancel_booking', params: {'p_booking_id': bookingId});
    } catch (_) {/* best-effort */}
  }

  /// Invoke a Supabase EDGE function (Deno), used for the Razorpay order +
  /// signature-verify flow — the Key Secret lives in the function's env, never
  /// here. Returns the decoded JSON map, or null on any failure (offline, the
  /// function not deployed, an error status) so the caller can fall back to the
  /// no-charge preview instead of stranding the user.
  static Future<Map<String, dynamic>?> invokeEdge(
    String name,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client.functions.invoke(name, body: body);
      if (res.status >= 400) {
        // WHY THIS LOGS. Returning a bare null made every edge-function
        // failure identical: "keys not set", "not your session", "no such
        // booking" and a network timeout all reached the caller as null, and
        // every caller then showed one generic message for six causes. That
        // cost three rounds of guessing on the first LiveKit call.
        //
        // The body is the server's own refusal — it is not secret, it is the
        // explanation. Log it.
        debugPrint('[edge] $name -> ${res.status} ${res.data}');
        return null;
      }
      final data = res.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      debugPrint('[edge] $name -> 200 but not a map: ${res.data}');
      return null;
    } on FunctionException catch (e) {
      // Newer supabase_flutter THROWS on non-2xx rather than returning a
      // status, so the branch above never runs and the reason vanished into
      // the catch-all. Both paths now say the same thing.
      debugPrint('[edge] $name -> ${e.status} ${e.details ?? e.reasonPhrase}');
      return null;
    } catch (e) {
      debugPrint('[edge] $name threw: $e');
      return null;
    }
  }
}

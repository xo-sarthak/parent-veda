import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'sync_batch.dart';
export 'sync_batch.dart' show SyncSend;

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

  /// The signed-in email, for a checkout prefill. Same guard as [userId].
  static String? get userEmail {
    try {
      return _client.auth.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

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

  /// Rows of [table] where [column] equals [value], whoever wrote them — RLS
  /// decides what comes back (product_reviews: your own plus everyone's
  /// approved ones, 0119). Empty on any failure or when logged out.
  static Future<List<Map<String, dynamic>>> selectWhere(
    String table,
    String column,
    Object value, {
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    if (userId == null) return const [];
    try {
      final rows = await _client
          .from(table)
          .select()
          .eq(column, value)
          .order(orderBy, ascending: ascending);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[repo] select $table where $column failed: $e');
      return const [];
    }
  }

  /// Public catalogue rows of [table] where [column] equals [value], readable
  /// logged out (products, 0049: anyone may read published rows). Null when
  /// the server did not answer, so a caller keeps its cache instead of
  /// mistaking "offline" for "the sheet is empty".
  static Future<List<Map<String, dynamic>>?> selectPublicWhere(
    String table,
    String column,
    Object value,
  ) async {
    try {
      final rows = await _client.from(table).select().eq(column, value);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[repo] public select $table failed: $e');
      return null;
    }
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

  /// [updateShared], and whether the cloud took it (2026-10-17, 0101). For a
  /// row the PARTNER owns: an upsert would be refused, because Postgres checks
  /// the INSERT policy (`auth.uid() = user_id`) on every row an upsert
  /// proposes, even one that ends up updating. A plain UPDATE leaves user_id
  /// alone. A row 0100's guard skips as older still counts as taken.
  static Future<bool> updateSharedConfirmed(
    String table,
    String id,
    Map<String, dynamic> changes,
  ) async {
    if (userId == null) return false;
    try {
      await _client.from(table).update(changes).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[repo] update $table refused: $e');
      return false;
    }
  }

  /// [updateSharedConfirmed] for a composite-key child table (2026-10-17,
  /// 0104): the row is matched on `child_id` + [column] == [value] rather
  /// than an `id`. Milestone observations and vaccine doses.
  static Future<bool> updateChildRowConfirmed(
    String table,
    String childId,
    String column,
    Object value,
    Map<String, dynamic> changes,
  ) async {
    if (userId == null) return false;
    try {
      await _client
          .from(table)
          .update(changes)
          .eq('child_id', childId)
          .eq(column, value);
      return true;
    } catch (e) {
      debugPrint('[repo] update $table refused: $e');
      return false;
    }
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

  /// Link the current user with whoever owns [code] (`link_as_partner`,
  /// 0009, hardened in 0102). Either person may type the other's code.
  ///
  /// Returns null when linked, or the reason it was not, in words she can
  /// read: the server's own refusal ("That code is already linked with
  /// someone else") rather than a generic failure, because what she does next
  /// depends on which one it was (BACKEND-PATTERNS §15).
  static Future<String?> linkAsPartner(String code) async {
    if (userId == null) return 'Sign in first, then enter the code.';
    try {
      await _client.rpc('link_as_partner', params: {'code': code.trim()});
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (_) {
      return 'Linking failed. Check the code and try again.';
    }
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

  /// Read [columns] from [id]'s profile row: the paired partner's, which 0009's
  /// "view own or partner profile" policy allows and nothing else does. Null
  /// when logged out, unreadable or on any failure, the same contract as
  /// [fetchMyProfile] (STAGE-TRANSITIONS R2, 2026-10-25).
  static Future<Map<String, dynamic>?> fetchProfileOf(String id, String columns) async {
    if (userId == null) return null;
    try {
      final row = await _client
          .from('profiles')
          .select(columns)
          .eq('id', id)
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

  /// Her partner's blob for [storeKey], read-only. RLS decides which keys a
  /// partner may read (0118: `birth_plan` only); any other key comes back
  /// null, the same as a row that does not exist.
  static Future<dynamic> loadPartnerState(
      String partnerId, String storeKey) async {
    if (userId == null) return null;
    final row = await _client
        .from('user_state')
        .select('data')
        .eq('user_id', partnerId)
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

  /// Merge [items] (`{key: {v, t, d}}`) into this user's [storeKey] on the
  /// server, item by item, newer wins, in one locked statement
  /// (`pv_state_merge`, 0110), and return the whole merged map. Throws when
  /// logged out, offline or refused, so the caller keeps its items waiting.
  static Future<Map<String, dynamic>> mergeState(
      String storeKey, Map<String, dynamic> items) async {
    if (userId == null) throw StateError('not signed in');
    final res = await _client
        .rpc('pv_state_merge', params: {'p_key': storeKey, 'p_items': items});
    if (res is Map) return Map<String, dynamic>.from(res);
    return <String, dynamic>{};
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
    required String stage,
    // LA-32, CONTRACT (after 0128 gave these defaults, 2026-10-29). Each is
    // sent only when the server needs it, and a null leaves the key out
    // entirely (`'key': ?value`), so PostgREST matches the defaults:
    //   startsUtc     a consult's start (her pick), or the stub branch;
    //   the others    only the stub branch, for an offering the server
    //                 cannot price (live mode refuses those anyway).
    // Kept for revert: all five were `required` while 0126 declared them
    // without defaults and PostgREST could not resolve the call without them.
    String? expertId,
    DateTime? startsUtc,
    int? durationMin,
    int? capacity,
    String? title,
    String? joinUrl,
    // What the parent paid, recorded ON the booking (0084). The doctor's
    // ledger reads this and never the catalogue, so a later price change
    // cannot rewrite what a session was worth when it was booked.
    //
    // L2c: no longer sent by the app. 0126 records the SERVER's seat value
    // and reads this only in stub mode, for an offering it cannot price.
    // The five slot values above are still sent because book_slot declares
    // them without defaults, so PostgREST cannot resolve the call without
    // them; the server reads them only for a consult's start (her pick) and
    // the stub branch. Dropping them needs defaults first (expand/contract).
    int? priceMinor,
  }) async {
    if (userId == null) return false;
    try {
      await _client.rpc('book_slot', params: {
        'p_booking_id': bookingId,
        'p_slot_id': slotId,
        'p_offering_id': offeringId,
        'p_expert_id': ?expertId,
        'p_starts_utc': ?startsUtc?.toUtc().toIso8601String(),
        'p_duration_min': ?durationMin,
        'p_capacity': ?capacity,
        'p_stage': stage,
        'p_title': ?title,
        'p_join_url': ?joinUrl,
        'p_price_paise': ?priceMinor,
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
  ///
  /// [orderBy] is optional because most callers genuinely do not care. Where a
  /// caller reduces many rows to one — "the prescription for this booking" —
  /// it very much does: without an ORDER BY, Postgres may return the rows in
  /// any order it likes, and a last-write-wins loop over an unordered result
  /// picks an arbitrary winner. That is not a rare race, it is every read.
  static Future<List<Map<String, dynamic>>> selectAll(
    String table, {
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      final q = _client.from(table).select();
      final rows = orderBy == null
          ? await q
          : await q.order(orderBy, ascending: ascending);
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      return const [];
    }
  }

  /// [selectAll] that tells "the server said none" from "the server did not
  /// answer": null on any failure. For reads whose EMPTY result drives a
  /// nag the user cannot dismiss (0084's payout account), the difference is
  /// the whole point.
  static Future<List<Map<String, dynamic>>?> selectAllOrNull(String table) async {
    if (userId == null) return null;
    try {
      final rows = await _client.from(table).select();
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[repo] select $table failed: $e');
      return null;
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

  /// The loud twin of [upsertRow]: true only when the server accepted it.
  /// For the writes where "best-effort" is the wrong contract — a doctor's
  /// bank account (0084) must never LOOK saved when RLS refused it, because
  /// the failure would surface as a payout to nowhere months later.
  static Future<bool> upsertRowConfirmed(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) async {
    if (userId == null) return false;
    try {
      await _client.from(table).upsert(data, onConflict: onConflict);
      return true;
    } catch (e) {
      debugPrint('[repo] upsert $table refused: $e');
      return false;
    }
  }

  /// Many rows in ONE request (sync log step 11, 2026-10-21): a first sync
  /// used to send each row on its own, hundreds of round trips. Says WHY it
  /// failed, because the caller treats the two very differently:
  ///
  ///   · [SyncSend.refused] — the server answered no (a check, a policy). One
  ///     statement is all-or-nothing, so ONE bad row refuses the whole batch;
  ///     the caller retries that batch row by row to find it.
  ///   · [SyncSend.offline] — no answer at all. Retrying row by row would only
  ///     make a hundred more failing requests, so the caller stops the round.
  ///
  /// Every row must carry the same keys (PostgREST builds one column list
  /// from them); `SyncBatch` groups rows by key set before calling this.
  static Future<SyncSend> upsertRows(
    String table,
    List<Map<String, dynamic>> rows, {
    String? onConflict,
  }) async {
    if (userId == null) return SyncSend.offline;
    if (rows.isEmpty) return SyncSend.ok;
    try {
      await _client.from(table).upsert(rows, onConflict: onConflict);
      return SyncSend.ok;
    } on PostgrestException catch (e) {
      debugPrint('[repo] upsert ${rows.length} into $table refused: $e');
      return SyncSend.refused;
    } catch (e) {
      debugPrint('[repo] upsert ${rows.length} into $table unreachable: $e');
      return SyncSend.offline;
    }
  }

  /// Put bytes in a PUBLIC bucket and return the URL anyone can read. The
  /// caller chooses [path] under its own folder (RLS: the first segment must
  /// be the user id — 0013 for media, 0090 for expert-photos). Upsert, so a
  /// new file at the same path replaces the old; the `?v=` the caller appends
  /// is what makes a cache notice. Null when the server refused, and it says
  /// why in the log — a doctor's photo is one the user watches land.
  static Future<String?> uploadPublicFile(
    String bucket,
    String path,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    if (userId == null) return null;
    try {
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('[repo] upload $bucket/$path refused: $e');
      return null;
    }
  }

  /// Put bytes in a PRIVATE bucket (0122 community-media). Never upsert: a
  /// replace needs select + update rights the policy does not grant, and a
  /// path is written once. True when Storage accepted it.
  static Future<bool> uploadPrivateFile(
    String bucket,
    String path,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    if (userId == null) return false;
    try {
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );
      return true;
    } catch (e) {
      debugPrint('[repo] private upload $bucket/$path refused: $e');
      return false;
    }
  }

  /// Short-lived URLs for objects in a private bucket, by path. Storage only
  /// signs what its select policy lets this person read, so a path the
  /// server has not approved simply comes back missing. {} when logged out.
  static Future<Map<String, String>> signedUrls(
    String bucket,
    List<String> paths, {
    int expiresIn = 3600,
  }) async {
    if (userId == null || paths.isEmpty) return {};
    try {
      final res =
          await _client.storage.from(bucket).createSignedUrlsResult(paths, expiresIn);
      return {
        for (final r in res)
          if (r is SignedUrlSuccess && r.signedUrl.isNotEmpty) r.path: r.signedUrl,
      };
    } catch (e) {
      debugPrint('[repo] sign $bucket refused: $e');
      return {};
    }
  }

  /// A function whose answer is one jsonb value (an object or an array).
  /// Unlike [callFunction] this THROWS when the call fails, so a caller can
  /// tell "the server said no" (a value) from "we could not reach it" (an
  /// exception) — the community needs both: one is a toast with a reason,
  /// the other keeps the post queued on the phone. Null when logged out.
  static Future<dynamic> rpcJson(String fn, [Map<String, dynamic>? params]) async {
    if (userId == null) return null;
    return _client.rpc(fn, params: params);
  }

  /// Listen to a PRIVATE broadcast topic (0145, Community C3-1): the server
  /// says "something changed" and the caller re-reads through its usual
  /// RPC. The topic's SELECT policy on realtime.messages decides who may
  /// join; a refused join simply never fires [onSignal].
  ///
  /// Null when logged out or uninitialised, like every other cloud call
  /// here. A live connection is an extra, never a dependency: whatever
  /// fails, the caller's pull-to-refresh still works.
  static PvLiveListen? listenBroadcast(String topic, String event, void Function() onSignal) {
    if (userId == null) return null;
    try {
      final ch = _client.channel(topic, opts: const RealtimeChannelConfig(private: true));
      ch.onBroadcast(event: event, callback: (_) => onSignal()).subscribe();
      return PvLiveListen(() => _client.removeChannel(ch).catchError((_) => 'error'));
    } catch (_) {
      return null;
    }
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

  // Kept for revert (superseded 2026-10-30, 0135): best-effort, and the phone
  // cancelled locally whatever happened. A swallowed failure left her seeing
  // "cancelled" while the server still held the booking, and the merge never
  // put it back -- the one place a fire-and-forget write cost the truth.
  //
  // static Future<void> cancelBooking(String bookingId) async {
  //   if (userId == null) return;
  //   try {
  //     await _client.rpc('cancel_booking', params: {'p_booking_id': bookingId});
  //   } catch (_) {/* best-effort */}
  // }

  /// Cancel a booking through the server (0135 `cancel_booking`). NOT
  /// fire-and-forget, like [expertCancelBooking] below: the caller cancels
  /// locally only on `ok`, and says whether the credit came back from what
  /// the server answered, never from a guess.
  ///
  /// Returns the server's map: `ok`, `credit_returned`, `late`, `reason`,
  /// `window_hours`. Signed out: `{ok: true, local: true}` (nothing to ask).
  /// A server still on 0066 returns nothing; that is read as ok, its old
  /// behaviour. A network failure is `{ok: false, reason: 'network'}`.
  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    if (userId == null) return const {'ok': true, 'local': true};
    try {
      final res = await _client
          .rpc('cancel_booking', params: {'p_booking_id': bookingId});
      if (res is Map) return res.cast<String, dynamic>();
      return const {'ok': true};
    } catch (e) {
      debugPrint('[repo] cancel_booking failed: $e');
      return const {'ok': false, 'reason': 'network'};
    }
  }

  /// Move a booking in ONE server transaction (0135 `reschedule_booking`):
  /// the old seat is released and the new one claimed together, or neither.
  /// Same answer shape as [cancelBooking]; on `ok`, `booking` is the new row.
  static Future<Map<String, dynamic>> rescheduleBooking({
    required String bookingId,
    required String newBookingId,
    required String newSlotId,
    DateTime? startsUtc,
  }) async {
    if (userId == null) return const {'ok': false, 'reason': 'not_signed_in'};
    try {
      final res = await _client.rpc('reschedule_booking', params: {
        'p_booking_id': bookingId,
        'p_new_booking_id': newBookingId,
        'p_new_slot_id': newSlotId,
        if (startsUtc != null) 'p_starts_utc': startsUtc.toUtc().toIso8601String(),
      });
      if (res is Map) return res.cast<String, dynamic>();
      return const {'ok': false, 'reason': 'unknown'};
    } catch (e) {
      debugPrint('[repo] reschedule_booking failed: $e');
      return const {'ok': false, 'reason': 'network'};
    }
  }

  /// The cancel window in hours, from the one place it is set (0135
  /// `booking_terms`, reading `booking_policy`). Null when it cannot be read.
  static Future<int?> bookingTermsHours() async {
    if (userId == null) return null;
    try {
      final res = await _client.rpc('booking_terms');
      if (res is Map && res['credit_return_hours'] is num) {
        return (res['credit_return_hours'] as num).toInt();
      }
    } catch (_) {/* not run yet, or offline: the cached value stands */}
    return null;
  }

  /// The DOCTOR's cancel / no-show (0077). Returns the server's status code.
  ///
  /// Deliberately NOT fire-and-forget, unlike its neighbours. Everywhere else
  /// in this file a swallowed error costs a sync that the next refresh repairs.
  /// Here it would cost the truth of a sentence shown to a clinician —
  /// "Cancelled. The parent has their credit back." — about a mother who is
  /// still expecting them. So the outcome comes back and the caller decides
  /// what to say.
  ///
  /// 'error' rather than a throw: the caller's job is to pick a message, and a
  /// network failure and a refused write both mean "do not claim it worked".
  static Future<String> expertCancelBooking(
    String bookingId,
    String outcome,
  ) async {
    if (userId == null) return 'not_authenticated';
    try {
      final res = await _client.rpc('expert_cancel_booking', params: {
        'p_booking_id': bookingId,
        'p_outcome': outcome,
      });
      return res?.toString() ?? 'error';
    } catch (e) {
      debugPrint('[booking] expert_cancel_booking failed: $e');
      return 'error';
    }
  }

  // ---- consult attendance (0078) -------------------------------------------
  //
  // Fire-and-forget on purpose, unlike expertCancelBooking above, and the
  // difference is worth being explicit about: a lost attendance row costs
  // exactly the accuracy we had before the table existed, whereas a lost
  // cancellation costs a mother sitting in an empty room. Different stakes,
  // different error policy.

  /// Record that this user is in the room. Returns the session id to hand to
  /// [recordConsultLeave], or null if the server refused or was unreachable.
  static Future<String?> recordConsultJoin(
    String sessionId,
    String bookingId,
  ) async {
    if (userId == null) return null;
    try {
      final res = await _client.rpc('record_consult_join', params: {
        'p_id': sessionId,
        'p_booking_id': bookingId,
      });
      return res?.toString();
    } catch (e) {
      debugPrint('[consult] record_consult_join failed: $e');
      return null;
    }
  }

  static Future<void> recordConsultLeave(String sessionId) async {
    if (userId == null) return;
    try {
      await _client.rpc('record_consult_leave', params: {'p_id': sessionId});
    } catch (_) {/* best-effort; see above */}
  }

  // ---- live sessions and recordings (0128, L3) -------------------------------

  /// The waiting room's question (0128 `session_state`): has the host come,
  /// and has the session been closed as host-missed? Null when offline,
  /// signed out, or not her booking. Keys: status, cancel_reason, outcome,
  /// host_seen, starts_utc, paid_by, server_now.
  static Future<Map<String, dynamic>?> sessionState(String bookingId) async {
    if (userId == null) return null;
    try {
      final res = await _client
          .rpc('session_state', params: {'p_booking_id': bookingId});
      return res is Map ? Map<String, dynamic>.from(res) : null;
    } catch (e) {
      debugPrint('[live] session_state failed: $e');
      return null;
    }
  }

  /// Every session recording she may watch, with its state (0128
  /// `my_recordings`): id, slot_id, programme_id, title, status, duration_s.
  /// Never a playback id; that is only handed out signed.
  static Future<List<Map<String, dynamic>>> myRecordings() async {
    if (userId == null) return const [];
    try {
      final res = await _client.rpc('my_recordings');
      if (res is! List) return const [];
      return [for (final r in res) if (r is Map) Map<String, dynamic>.from(r)];
    } catch (e) {
      debugPrint('[live] my_recordings failed: $e');
      return const [];
    }
  }

  /// Ask the server to settle past bookings from attendance evidence.
  /// Returns how many it settled.
  static Future<int> settleMyBookings() async {
    if (userId == null) return 0;
    try {
      final res = await _client.rpc('settle_my_bookings');
      return (res as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('[booking] settle_my_bookings failed: $e');
      return 0;
    }
  }

  /// Invoke a Supabase EDGE function (Deno), used for the Razorpay order +
  /// signature-verify flow — the Key Secret lives in the function's env, never
  /// here. Returns the decoded JSON map, or null on any failure (offline, the
  /// function not deployed, an error status) so the caller can fall back to the
  /// no-charge preview instead of stranding the user.
  static Future<Map<String, dynamic>?> invokeEdge(
    String name,
    Map<String, dynamic> body,
  ) async =>
      (await invokeEdgeResult(name, body)).data;

  /// The same call, but keeping the REFUSAL instead of throwing it away.
  ///
  /// [invokeEdge] collapses every failure to null, which is right for the
  /// Razorpay callers — they have a no-charge preview to fall back to and no
  /// use for the reason. It is wrong for joining a call, where the server
  /// knows something the app cannot work out for itself: *why* the door is
  /// shut. "Your consultation opens at 4:50 PM" and "this session is not
  /// yours" are different sentences, and only the server can tell them apart.
  ///
  /// This is the same lesson as `0075`'s header, one layer up: when a call can
  /// fail for several reasons and you keep only its result, you have thrown
  /// away the diagnosis and kept the symptom. [invokeEdge] still exists and
  /// still behaves identically, so nothing that was happy with null changes.
  static Future<EdgeResult> invokeEdgeResult(
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
        return EdgeResult(status: res.status, data: _asMap(res.data));
      }
      final data = res.data;
      if (data is Map) {
        return EdgeResult(status: res.status, data: Map<String, dynamic>.from(data));
      }
      debugPrint('[edge] $name -> 200 but not a map: ${res.data}');
      return EdgeResult(status: res.status);
    } on FunctionException catch (e) {
      // Newer supabase_flutter THROWS on non-2xx rather than returning a
      // status, so the branch above never runs and the reason vanished into
      // the catch-all. Both paths now say the same thing.
      debugPrint('[edge] $name -> ${e.status} ${e.details ?? e.reasonPhrase}');
      return EdgeResult(status: e.status, data: _asMap(e.details));
    } catch (e) {
      debugPrint('[edge] $name threw: $e');
      // Status 0 is "we never reached the server" — offline, DNS, a dead
      // socket. Distinct from any status the server chose, which matters:
      // one is worth a Retry button, the others are not.
      return const EdgeResult(status: 0);
    }
  }

  /// The refusal bodies arrive as a Map on one path and a JSON string on the
  /// other, depending on which failure mode fired. Normalise once, here,
  /// rather than at every call site.
  static Map<String, dynamic>? _asMap(Object? raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        // Not JSON after all. The debugPrint above already carried it.
      }
    }
    return null;
  }
}

/// What an edge function actually answered: the HTTP status, and the decoded
/// body whether it succeeded or refused.
///
/// [status] is 0 when the request never reached the server at all.
@immutable
class EdgeResult {
  const EdgeResult({required this.status, this.data});

  final int status;
  final Map<String, dynamic>? data;

  bool get ok => status >= 200 && status < 300;
  bool get offline => status == 0;

  /// The server's own word for what went wrong, when it gave one.
  String? get reason => (data?['reason'] ?? data?['error'])?.toString();
}

/// A live subscription from [SupabaseRepo.listenBroadcast]. [close] leaves
/// the channel; calling it twice, or after a failure, is harmless.
class PvLiveListen {
  PvLiveListen(this._close);
  final void Function() _close;
  bool _closed = false;

  void close() {
    if (_closed) return;
    _closed = true;
    try {
      _close();
    } catch (_) {}
  }
}

// =============================================================================
//  TtcLogShareStore — "may my partner see this log?" (T5 Q1, 2026-10-29)
// -----------------------------------------------------------------------------
//  docs/preg-ttc-tool-plans/T5-body-checks.md, Wave 3; migration
//  `0131_ttc_log_shares.sql`.
//
//  The user's call (Q1): a couple trying together may see each other's
//  HABITS, as an accountability check. His `partner_health`, her `habits`.
//  Body and medical logs (symptoms, mood, weight, the PCOS check) stay
//  private, always. Each person decides for their OWN log, once, on a card
//  after their first save, and "Share" is the first answer. Changeable in You.
//
//  ⚠️ THE ANSWER LIVES IN THE DATABASE, NOT ONLY HERE, AND RLS ENFORCES IT.
//  A rule held only by the client is a rule any client can skip. 0131 adds a
//  second, read-only SELECT policy on `ttc_logs` that lets the partner read a
//  shared tracker's rows while this switch is on; Postgres ORs permissive
//  policies, so the old own-row policy is untouched. This store only writes
//  the switch. Turning it off revokes the read on the very next query, and
//  unpairing revokes it with no code at all (`my_partner_id()` goes null).
//
//  ⚠️ WHY NOT THE T1 USE-CONSENT STORE. That answers "may the APP use this";
//  this answers "may my PARTNER see this". Different people asking, different
//  revocations, different tables.
//
//  Shape: tracker -> true | false | (absent = not asked yet). Local-first in
//  shared_preferences, one row per tracker pushed fire-and-forget, newer
//  `updated_at` wins on a pull. It also reads the partner's two rows, so his
//  phone can say "She shares her habits with you" without asking her phone.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';
import 'ttc_sync.dart';
import 'ttc_trackers_data.dart' show kTtcShareableTrackers;

/// The table 0131 creates.
const String kTtcLogSharesTable = 'ttc_log_shares';

class TtcLogShareStore extends ChangeNotifier with TtcSyncedStore {
  TtcLogShareStore._() {
    _load();
  }
  static final TtcLogShareStore instance = TtcLogShareStore._();

  static const String _key = 'ttc_log_shares';

  /// Her (or his) own answers, by tracker.
  final Map<String, bool> _mine = {};

  /// When each answer was last set, for newer-wins.
  final Map<String, DateTime> _stamps = {};

  /// The partner's answers, read from the cloud. Never written here.
  final Map<String, bool> _partner = {};

  String? _partnerId;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// This phone's own answer for [tracker]: true, false, or null (not asked).
  bool? sharedFor(String tracker) => _mine[tracker];

  /// Whether the partner shares their [tracker] with this phone's account.
  bool partnerShares(String tracker) => _partner[tracker] == true;

  /// The linked partner's account id, or null (none linked, or offline).
  String? get partnerId => _partnerId;

  /// The share card waits until there is someone to share with.
  bool get hasPartner => _partnerId != null;

  /// Records this phone's answer for [tracker]. Only the two shareable
  /// trackers can be set; anything else is refused here AND by 0131's check
  /// constraint, so a bug cannot share her symptoms.
  void set(String tracker, bool shared, {DateTime? now}) {
    if (!kTtcShareableTrackers.contains(tracker)) return;
    _mine[tracker] = shared;
    _stamps[tracker] = (now ?? DateTime.now()).toUtc();
    _persist();
    notifyListeners();
  }

  // ---- local ------------------------------------------------------------------

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw != null) _decode(raw);
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  void _decode(String raw) {
    final m = jsonDecode(raw);
    if (m is! Map) return;
    final mine = m['mine'];
    if (mine is Map) {
      for (final e in mine.entries) {
        final v = e.value;
        if (v is Map && v['s'] is bool) {
          _mine[e.key.toString()] = v['s'] as bool;
          final t = DateTime.tryParse('${v['t']}');
          if (t != null) _stamps[e.key.toString()] = t;
        }
      }
    }
  }

  String _encode() => jsonEncode({
        'mine': {
          for (final e in _mine.entries)
            e.key: {
              's': e.value,
              't': _stamps[e.key]?.toIso8601String(),
            },
        },
      });

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, _encode());
    } catch (_) {/* best effort, like every TTC store */}
  }

  @override
  Future<void> persistLocalCache() => _persist();

  // ---- the cloud --------------------------------------------------------------

  /// The row for [tracker], in 0131's columns.
  static Map<String, dynamic> rowFor(
          String userId, String tracker, bool shared, DateTime at) =>
      {
        'user_id': userId,
        'tracker': tracker,
        'shared': shared,
        'updated_at': TtcSyncUtil.stamp(at),
      };

  @override
  Future<void> pullFromCloud() async {
    // ⚠️ `fetch` PINS THE OWN USER, and the table has no `created_at`, so the
    // order is named.
    final rows =
        await SupabaseRepo.fetch(kTtcLogSharesTable, orderBy: 'updated_at');
    applyOwnRows(rows);
    _partnerId = await SupabaseRepo.myPartnerId();
    _partner.clear();
    final pid = _partnerId;
    if (pid != null) {
      final theirs = await SupabaseRepo.fetchByUser(kTtcLogSharesTable, pid,
          orderBy: 'updated_at');
      applyPartnerRows(theirs);
    }
  }

  /// Merges this account's own rows: the newer answer wins.
  @visibleForTesting
  void applyOwnRows(List<Map<String, dynamic>> rows) {
    for (final r in rows) {
      final tracker = r['tracker'];
      final shared = r['shared'];
      if (tracker is! String || shared is! bool) continue;
      final at = DateTime.tryParse('${r['updated_at']}')?.toUtc();
      final local = _stamps[tracker];
      if (local != null && at != null && !at.isAfter(local)) continue;
      _mine[tracker] = shared;
      if (at != null) _stamps[tracker] = at;
    }
  }

  /// Takes the partner's rows. Read-only: nothing here is ever pushed.
  @visibleForTesting
  void applyPartnerRows(List<Map<String, dynamic>> rows) {
    for (final r in rows) {
      final tracker = r['tracker'];
      final shared = r['shared'];
      if (tracker is String && shared is bool) _partner[tracker] = shared;
    }
  }

  /// For a test playing the linked partner.
  @visibleForTesting
  void setPartnerForTest(String? id, Map<String, bool> shares) {
    _partnerId = id;
    _partner
      ..clear()
      ..addAll(shares);
    notifyListeners();
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    // Confirmed and remembered (no_silent_user_writes_test). It was a
    // fire-and-forget `SupabaseRepo.upsertRow` per tracker, kept for revert:
    //   await SupabaseRepo.upsertRow(kTtcLogSharesTable,
    //       rowFor(uid, e.key, e.value, _stamps[e.key] ?? DateTime.now()),
    //       onConflict: 'user_id,tracker');
    // ⚠️ A refused "stop sharing" is the case that matters: the phone shows
    // "off" while the database still lets her partner read the log, and
    // nothing would say so. The waiting mark keeps the sign-out sheet honest,
    // and the next sync re-sends every row, so this needs nothing else.
    await sendTracked(() async {
      var allTook = true;
      for (final e in _mine.entries) {
        final ok = await SupabaseRepo.upsertRowConfirmed(
            kTtcLogSharesTable,
            rowFor(uid, e.key, e.value, _stamps[e.key] ?? DateTime.now()),
            onConflict: 'user_id,tracker');
        if (!ok) allTook = false;
      }
      return allTook;
    });
  }

  @override
  String? get waitingKey => 'pv_waiting_ttc_log_shares';

  /// A sign-out, or another account signing in.
  @override
  void resetLocal() => resetForTest();

  @visibleForTesting
  void resetForTest() {
    _mine.clear();
    _stamps.clear();
    _partner.clear();
    _partnerId = null;
    _loaded = true;
    notifyListeners();
  }
}

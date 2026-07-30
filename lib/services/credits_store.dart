// =============================================================================
//  CreditsStore — how many consultations this parent may book, per the server.
// -----------------------------------------------------------------------------
//  The app's half of migration 0066.
//
//  WHAT CHANGED, AND WHY IT MATTERS. Until 0066 a consultation credit was a
//  number in SharedPreferences: BookingStore said "you have one", and
//  book_slot() checked whether the SLOT had room without ever asking whether
//  the person had a right to it. Anyone able to edit a JSON blob on their own
//  phone had unlimited free consultations. Survivable while credits came from
//  referrals; not survivable once an employer is paying for them.
//
//  Now the ledger is server-side and this class READS it. The distinction to
//  hold on to:
//
//      before   the phone decided, and told the server
//      after    the server decides, and the phone displays
//
//  So a modified client can still make this number say 99. It gains nothing:
//  book_slot() claims a real row or records the booking as unpaid, and no
//  amount of local editing produces a row in consult_credits.
//
//  Local-first still applies to the DISPLAY. A cached count is shown instantly
//  and refreshed after, because a parent on a train should see the benefit she
//  had yesterday rather than a spinner. Being briefly wrong about a number on a
//  screen is fine; being wrong about a right is not, and that is now somebody
//  else's job.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreditsStore extends ChangeNotifier {
  CreditsStore._();
  static final CreditsStore instance = CreditsStore._();

  static const _cacheKey = 'consult_credits_v1';

  int _available = 0;
  int _spent = 0;
  DateTime? _expiringNext;
  Map<String, int> _bySource = const {};
  bool _loaded = false;

  /// Consultations that can be booked right now.
  int get available => _available;

  /// Consultations already attached to a booking, ever.
  int get spent => _spent;

  /// When the next unspent credit lapses, if any.
  DateTime? get expiringNext => _expiringNext;

  /// Where they came from — `sponsor`, `referral`, `purchase`, `goodwill`.
  /// Used to say "provided by Acme" rather than a bare number, because a
  /// credit somebody's employer bought reads differently from one they earned.
  Map<String, int> get bySource => Map.unmodifiable(_bySource);

  int fromSource(String source) => _bySource[source] ?? 0;

  void ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  Future<void> refresh() => _fetch();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        _apply(jsonDecode(raw) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (_) {/* a corrupt cache is not worth surfacing */}
    await _fetch();
  }

  Future<void> _fetch() async {
    final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      return; // uninitialised backend behaves exactly like being logged out
    }

    if (client.auth.currentUser == null) {
      if (_available != 0 || _spent != 0) {
        _available = 0;
        _spent = 0;
        _bySource = const {};
        _expiringNext = null;
        notifyListeners();
      }
      return;
    }

    try {
      final res = await client.rpc('my_consult_credits');
      final map = (res as Map?)?.cast<String, dynamic>();
      if (map == null) return;
      _apply(map);
      notifyListeners();
      await _persist(map);
    } catch (_) {
      // Offline, or the migration has not run. Keep the cached number —
      // never tell someone their benefit disappeared because a request failed.
    }
  }

  void _apply(Map<String, dynamic> m) {
    int i(Object? v) =>
        v == null ? 0 : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
    _available = i(m['available']);
    _spent = i(m['spent']);
    _expiringNext = m['expiring_next'] == null
        ? null
        : DateTime.tryParse(m['expiring_next'].toString());
    final src = (m['by_source'] as Map?)?.cast<String, dynamic>() ?? const {};
    _bySource = {for (final e in src.entries) e.key: i(e.value)};
  }

  Future<void> _persist(Map<String, dynamic> m) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(m));
    } catch (_) {/* best effort */}
  }

  @visibleForTesting
  void setForTest({
    int available = 0,
    int spent = 0,
    DateTime? expiringNext,
    Map<String, int> bySource = const {},
  }) {
    _available = available;
    _spent = spent;
    _expiringNext = expiringNext;
    _bySource = bySource;
    _loaded = true;
    notifyListeners();
  }
}

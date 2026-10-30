// =============================================================================
//  PushConsent - her yes or no to offers, per stage, delivered to the server
// -----------------------------------------------------------------------------
//  Phase 6b, B2 (2026-10-30). docs/NOTIFICATIONS-6B-PLAN.md, "Consent".
//
//  Her answer already lives in each messages store and syncs inside
//  user_state. The server's sender (B3) needs it as a row it can filter on,
//  so every answer is ALSO written to push_consent through pv_push_consent.
//
//  ⚠️ A "NO" IS NEVER FIRE-AND-FORGET. Elsewhere a failed cloud write is
//  dropped (CLAUDE.md). A dropped opt-out would mean offers keep arriving
//  after she said no. So a "no" is written to this phone's disk FIRST, then
//  sent, and stays queued until the server answers. A "yes" is sent once: if
//  it fails she simply gets nothing yet, which is the safe direction. The
//  cost of losing a write decides how hard you try to deliver it.
//
//  THE QUEUE:
//    * one entry per (account, stage), the LATEST answer. A new answer
//      replaces a queued one; a "yes" clears a queued "no" for that stage.
//    * each entry carries when she decided. The server keeps the newest
//      decision (0140), so a "no" that lands hours late never overwrites a
//      "yes" she gave on another phone in between.
//    * each entry names its account and is sent only while that account is
//      signed in: after sign-out there is no session to prove whose it is.
//      The queue survives the sign-out wipe (LocalWipe.keep) and goes out
//      when she signs back in.
//    * retried on every app open, on sign-in, before sign-out, and in this
//      session after 30 s, 2 min, then every 10 min while anything is left.
// =============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'push_wire.dart';

class PushConsent {
  PushConsent._();
  static final PushConsent instance = PushConsent._();

  /// The queue's key. In LocalWipe.keep: it must outlive a sign-out.
  static const prefsKey = 'push_consent_outbox_v1';

  static const _retryAfter = [
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 10),
  ];

  Future<void>? _flushing;
  Timer? _retry;
  int _attempt = 0;

  /// She answered the offers question for [stage]. Returns once a "no" is
  /// safely on disk; the network part runs on its own.
  Future<void> record({
    required String stage,
    required bool granted,
    required String source,
    DateTime? at,
  }) async {
    final uid = PushWire.userId();
    if (uid == null) return; // logged out: no account to hold it
    final decided = at ?? DateTime.now();
    final key = '$uid|$stage';
    final queue = await _read();
    if (granted) {
      // Latest wins: a queued "no" for this stage is now out of date.
      if (queue.remove(key) != null) await _write(queue);
      unawaited(_sendYes(stage, source, decided));
      return;
    }
    queue[key] = {
      'uid': uid,
      'stage': stage,
      'granted': false,
      'source': source,
      'at': decided.toUtc().toIso8601String(),
    };
    try {
      await _write(queue);
    } catch (e) {
      // The disk refused. Still try the network now; only the retry is lost.
      debugPrint('[push] consent no not queued: $e');
    }
    unawaited(flush());
  }

  Future<void> _sendYes(String stage, String source, DateTime at) async {
    try {
      await PushWire.call(
        PushWire.consent,
        PushWire.consentParams(
            stage: stage, granted: true, source: source, decidedAt: at),
      );
    } catch (e) {
      debugPrint('[push] consent yes not sent (safe, she gets nothing yet): $e');
    }
  }

  /// Sends every queued answer that belongs to the signed-in account.
  /// Concurrent calls share one run.
  Future<void> flush() {
    return _flushing ??= _flush().whenComplete(() => _flushing = null);
  }

  Future<void> _flush() async {
    final uid = PushWire.userId();
    if (uid == null) return;
    final queue = await _read();
    final mine = queue.entries.where((e) => e.value['uid'] == uid).toList();
    if (mine.isEmpty) {
      _cancelRetry();
      return;
    }
    var failed = false;
    for (final e in mine) {
      final v = e.value;
      // The RPC writes as whoever is signed in NOW. An account switch during
      // this run must not send her answer into someone else's account.
      if (PushWire.userId() != v['uid']) continue;
      try {
        await PushWire.call(
          PushWire.consent,
          PushWire.consentParams(
            stage: v['stage'] as String,
            granted: v['granted'] == true,
            source: v['source'] as String,
            decidedAt: DateTime.parse(v['at'] as String),
          ),
        );
        // Any answer means the server holds her latest for this stage: this
        // one, or a newer one from another phone.
        final now = await _read();
        if (jsonEncode(now[e.key]) == jsonEncode(v)) {
          now.remove(e.key);
          await _write(now);
        }
      } catch (err) {
        failed = true;
        debugPrint('[push] consent no still queued: $err');
      }
    }
    failed ? _scheduleRetry() : _cancelRetry();
  }

  void _scheduleRetry() {
    _retry?.cancel();
    final wait = _retryAfter[_attempt.clamp(0, _retryAfter.length - 1)];
    _attempt++;
    _retry = Timer(wait, () => unawaited(flush()));
  }

  void _cancelRetry() {
    _retry?.cancel();
    _retry = null;
    _attempt = 0;
  }

  /// What is queued, for tests and the contract test.
  @visibleForTesting
  Future<Map<String, Map<String, dynamic>>> pending() => _read();

  /// Test seam: forget timers and in-flight runs.
  @visibleForTesting
  void debugReset() {
    _cancelRetry();
    _flushing = null;
  }

  Future<Map<String, Map<String, dynamic>>> _read() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(prefsKey);
      if (raw == null || raw.isEmpty) return {};
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in m.entries)
          if (e.value is Map) e.key: Map<String, dynamic>.from(e.value as Map),
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> _write(Map<String, Map<String, dynamic>> queue) async {
    final p = await SharedPreferences.getInstance();
    if (queue.isEmpty) {
      await p.remove(prefsKey);
    } else {
      await p.setString(prefsKey, jsonEncode(queue));
    }
  }
}

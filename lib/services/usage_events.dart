// =============================================================================
//  UsageEvents — engagement shape, and nothing about content.
// -----------------------------------------------------------------------------
//  The app's half of migration 0065. It answers questions ParentVeda needs for
//  itself — is anyone coming back, how long do they stay, which parts get
//  opened — and the sponsor dashboard reads totals on top of it.
//
//  THE ONE RULE: WHICH ROOM, NEVER WHAT WAS IN IT.
//
//  `surface` is a screen name from [surfaces] below, and there is deliberately
//  no parameter for an id, a query, or an answer. "She opened Ask Veda" is a
//  product metric. "She asked about bleeding at week 9" is a medical record,
//  and it must not be possible to send it — which is why the vocabulary is a
//  const list and [record] asserts against it rather than accepting a String
//  and trusting the caller.
//
//  There is no column for content on the server either. Both halves have to be
//  wrong for a leak, which is the point of saying it twice.
//
//  WRITE-ONLY. There is no read path here, because there is no read grant on
//  the table. Nothing in the app can pull this log back, including this class.
//
//  BATCHED AND FIRE-AND-FORGET. A session is 3–4 rows; sending each one
//  immediately would mean four requests to measure that somebody opened an app.
//  Events queue and flush on session end, on a size threshold, and on the next
//  launch if the app was killed. A failure is dropped silently — CLAUDE.md's
//  local-first rule cuts the other way here: analytics must never be the reason
//  a mother's screen stutters, and a lost row is worth nothing.
// =============================================================================

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Every surface that may be reported, and the whole list.
///
/// A CLOSED VOCABULARY, not a suggestion. An open one becomes the place
/// somebody puts an article slug six months from now, and by then the log has
/// content in it and nobody notices. Adding a surface is one line here and a
/// deliberate act; passing an unlisted one trips an assert in debug and is
/// dropped in release.
class UsageSurface {
  const UsageSurface._();

  // pregnancy
  static const home = 'home';
  static const weekly = 'weekly';
  static const calendar = 'calendar';
  static const journal = 'journal';
  static const tools = 'tools';
  static const garbh = 'garbh';
  static const prepare = 'prepare';
  static const community = 'community';
  static const askVeda = 'ask_veda';
  static const profile = 'profile';
  // parenting
  static const myChild = 'my_child';
  static const explore = 'explore';
  static const watch = 'watch';
  static const food = 'food';
  static const learn = 'learn';
  static const health = 'health';
  static const development = 'development';
  // ttc
  static const ttcToday = 'ttc_today';
  static const ttcCycle = 'ttc_cycle';
  static const ttcLearn = 'ttc_learn';
  // enterprise
  static const employerBenefits = 'employer_benefits';
  static const sponsorProgramme = 'sponsor_programme';

  static const all = <String>{
    home, weekly, calendar, journal, tools, garbh, prepare, community,
    askVeda, profile,
    myChild, explore, watch, food, learn, health, development,
    ttcToday, ttcCycle, ttcLearn,
    employerBenefits, sponsorProgramme,
  };
}

class UsageEvents {
  UsageEvents._();
  static final UsageEvents instance = UsageEvents._();

  static const _pendingKey = 'usage_events_pending_v1';

  /// Flush once the queue reaches this, so a long session does not hold
  /// everything in memory waiting for an end that may never arrive.
  static const _flushAt = 20;

  String? _sessionId;
  DateTime? _sessionStart;
  final List<Map<String, dynamic>> _queue = [];
  bool _enabled = true;

  /// Turn recording off entirely. Exists so there is one place to honour a
  /// future "do not measure me" preference — a setting that has to be wired
  /// through twelve call sites never gets wired.
  void setEnabled(bool value) => _enabled = value;

  bool get enabled => _enabled;

  @visibleForTesting
  List<Map<String, dynamic>> get pending => List.unmodifiable(_queue);

  // ---- session ---------------------------------------------------------------

  /// Begin a session. Safe to call more than once; the second call is ignored,
  /// because a resumed app is the same session and counting it twice would
  /// double every engagement number on Android.
  Future<void> startSession({String? stage}) async {
    if (!_enabled || _sessionId != null) return;
    _sessionId = _newId();
    _sessionStart = DateTime.now().toUtc();
    _push('session_start', stage: stage);
    // Anything left by a previous launch that was killed before it flushed.
    await _drainStored();
  }

  /// End it, recording how long it lasted.
  Future<void> endSession({String? stage}) async {
    if (!_enabled || _sessionId == null) return;
    final start = _sessionStart;
    final ms = start == null
        ? null
        : DateTime.now().toUtc().difference(start).inMilliseconds;
    _push('session_end', stage: stage, durationMs: ms);
    _sessionId = null;
    _sessionStart = null;
    await flush();
  }

  // ---- screens ---------------------------------------------------------------

  /// Record that a surface was opened.
  ///
  /// [surface] must be one of [UsageSurface.all]. Anything else is a bug in the
  /// caller and is dropped rather than sent — see the class header for why this
  /// is not a String parameter you can put anything in.
  void screen(String surface, {String? stage}) {
    if (!_enabled) return;
    assert(UsageSurface.all.contains(surface),
        'Unknown usage surface "$surface". Add it to UsageSurface — and if you '
        'are reaching for an id or a search term, stop: this log records which '
        'screen, never what was on it.');
    if (!UsageSurface.all.contains(surface)) return;
    if (_sessionId == null) return; // no session, nothing to attribute it to
    _push('screen_view', surface: surface, stage: stage);
  }

  // ---- plumbing --------------------------------------------------------------

  void _push(String event,
      {String? surface, String? stage, int? durationMs}) {
    _queue.add({
      'session_id': _sessionId,
      'event': event,
      'surface': ?surface,
      'stage': ?stage,
      'duration_ms': ?durationMs,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
    if (_queue.length >= _flushAt) flush();
  }

  /// Send what is queued. Never throws, never awaited by anything on a frame.
  Future<void> flush() async {
    if (_queue.isEmpty) return;

    final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      // Uninitialised backend behaves exactly like being logged out.
      _queue.clear();
      return;
    }

    final uid = client.auth.currentUser?.id;
    if (uid == null) {
      // Signed out. There is no anonymous case here on purpose (0065): an
      // event with no user answers nothing this table exists for, and
      // profile_events already covers pre-auth UX measurement.
      _queue.clear();
      return;
    }

    final rows = _queue
        .map((e) => {...e, 'user_id': uid})
        .toList(growable: false);
    _queue.clear();

    try {
      await client.from('usage_events').insert(rows);
    } catch (_) {
      // KEPT, not dropped — but only across a launch, and only up to a cap.
      // Analytics is worth a retry and is not worth unbounded disk.
      await _store(rows);
    }
  }

  Future<void> _store(List<Map<String, dynamic>> rows) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing =
          (jsonDecode(prefs.getString(_pendingKey) ?? '[]') as List)
              .cast<Map<String, dynamic>>();
      final merged = [...existing, ...rows];
      // A phone offline for a week must not accumulate a megabyte of
      // analytics. Newest kept: a recent session is worth more than a
      // fortnight-old one.
      final capped = merged.length <= 200
          ? merged
          : merged.sublist(merged.length - 200);
      await prefs.setString(_pendingKey, jsonEncode(capped));
    } catch (_) {/* best effort */}
  }

  Future<void> _drainStored() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingKey);
      if (raw == null) return;
      final rows = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      if (rows.isEmpty) return;
      await prefs.remove(_pendingKey);

      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;
      // Re-stamp the user: a queue written before sign-in belongs to whoever
      // is here now, and rows are only ever accepted for the caller anyway.
      await client
          .from('usage_events')
          .insert(rows.map((e) => {...e, 'user_id': uid}).toList());
    } catch (_) {/* dropped; a stale session is not worth a retry loop */}
  }

  static String _newId() {
    final r = Random();
    return List.generate(16, (_) => r.nextInt(16).toRadixString(16)).join();
  }

  @visibleForTesting
  void resetForTest() {
    _queue.clear();
    _sessionId = null;
    _sessionStart = null;
    _enabled = true;
  }
}

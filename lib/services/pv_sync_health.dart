// One calm word when the cloud cannot be reached (decided 2026-10-15).
//
// Cloud writes are fire-and-forget (`.catchError(...)`), because the app is
// local-first: the phone's copy is the truth this session and the next sync
// recovers a lost push. That is right for her data and wrong for her trust:
// she saves something on a train, nothing says the cloud missed it, and
// later her partner's phone does not show it. So the swallowed errors now
// report here, and the FIRST network failure of a session raises one gentle
// notice. After that, silence: a notice on every failed write would turn a
// tunnel into a stream of alarms.
//
// What it deliberately does NOT do:
//  · speak when logged out or when the backend never initialised. An
//    uninitialised backend must behave exactly like being logged out
//    (CLAUDE.md), and those writes never leave the phone anyway.
//  · speak for a non-network error (a schema mismatch, an RLS refusal). Those
//    are our bugs, not her connection, and "you're offline" would be a lie;
//    the contract tests are what catch them.
//  · persist the flag. It lives in memory, so if she is still offline on the
//    next launch she hears it once more.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../widgets/global_ask_fab.dart' show appNavigatorKey;
import '../widgets/pv_toast.dart';
import 'remote/supabase_repo.dart';

class PvSyncHealth {
  PvSyncHealth._();

  static bool _toldThisSession = false;

  /// The words, kept here so a test can find them.
  static const String offlineNote =
      "You're offline. Everything is saved on this phone and will sync when you're back.";

  /// Hand a swallowed cloud-write error here: `.catchError(PvSyncHealth.report)`.
  static void report(Object error, [StackTrace? _]) {
    if (_toldThisSession) return;
    if (!SupabaseRepo.isLoggedIn) return;
    if (!looksLikeNetwork(error)) return;
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    _toldThisSession = true;
    pvToast(ctx, offlineNote, kind: PvToastKind.gentle);
  }

  /// A connection problem, by the shape of the error. String checks rather
  /// than `dart:io` types, so this file has no platform import.
  static bool looksLikeNetwork(Object error) {
    if (error is TimeoutException) return true;
    final s = '$error';
    return s.contains('SocketException') ||
        s.contains('Failed host lookup') ||
        s.contains('ClientException') ||
        s.contains('Connection refused') ||
        s.contains('Connection reset') ||
        s.contains('Network is unreachable');
  }

  @visibleForTesting
  static void resetForTest() => _toldThisSession = false;
}

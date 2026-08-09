// =============================================================================
//  SessionWatch — keeps the local "you are logged in" flag honest.
// =============================================================================
//
//  THE BUG THIS EXISTS TO CLOSE
//  ----------------------------
//  The app decides at launch whether to show the auth flow by reading ONE local
//  boolean, `kAuthCompletedKey`, out of shared_preferences. That flag is set
//  when onboarding finishes and cleared when she taps sign out — and until now,
//  nothing else ever touched it.
//
//  So the flag records "she finished onboarding once", while what the app
//  actually needs to know is "there is a valid Supabase session right now".
//  Those agree most of the time, and when they diverge the failure is invisible:
//
//    * the refresh token expires, or is revoked (password changed elsewhere,
//      project keys rotated, session deleted from the dashboard)
//    * `SupabaseRepo.userId` becomes null
//    * every store's cloud read returns [] and every write is skipped —
//      because that is exactly what they are *supposed* to do when logged out
//    * local-first means she still sees all her cached data, instantly
//
//  Nothing crashes. Nothing is empty. Nothing is logged. She keeps writing
//  journal entries into a device that is no longer syncing them anywhere, and
//  finds out at reinstall — the one moment the cache is gone and the cloud is
//  the only copy.
//
//  This is worth understanding as a general shape, not just a bug: **a cache
//  that degrades silently is more dangerous than one that fails loudly.** The
//  local-first design is what makes ParentVeda feel instant, and the exact same
//  property is what hides a broken session. Anything cached needs a way to
//  answer "am I still authoritative?" — here, that answer is the session, and
//  this class is what keeps the two from drifting apart.
//
//  TWO HALVES, BECAUSE THERE ARE TWO WAYS TO DIVERGE
//  -------------------------------------------------
//    1. The session dies WHILE THE APP IS RUNNING  → this listener hears
//       `signedOut` and clears the flag.
//    2. The session dies WHILE THE APP IS CLOSED   → no event ever fires,
//       because nothing was listening. `splash_screen.dart` covers that by
//       checking for a real session at launch rather than trusting the flag.
//
//  Neither half is sufficient alone.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../screens/auth/auth_flow_screen.dart' show kAuthCompletedKey;

class SessionWatch {
  SessionWatch._(); // static-only.

  static StreamSubscription<AuthState>? _sub;

  /// Begin watching. Idempotent, and safe to call before/without Supabase
  /// being initialised — an uninitialised backend must behave exactly like
  /// being logged out, never like a crash.
  static void start() {
    if (_sub != null) return; // already watching
    try {
      _sub = Supabase.instance.client.auth.onAuthStateChange.listen(
        _onEvent,
        // A stream error here is an auth failure we could not parse — most
        // often a refresh that gave up. Treat it as a sign-out rather than
        // swallowing it, because the dangerous outcome is staying "logged in"
        // with no session, not being asked to log in once too often.
        onError: (Object e) {
          debugPrint('SessionWatch stream error: $e');
          _clearFlag();
        },
      );
    } catch (e) {
      // Supabase not initialised (widget tests, or a failed initialize()).
      debugPrint('SessionWatch not started: $e');
    }
  }

  static Future<void> _onEvent(AuthState state) async {
    switch (state.event) {
      case AuthChangeEvent.signedOut:
        // Covers BOTH an explicit sign-out and a refresh token that finally
        // gave up — supabase_flutter reports the second as a sign-out too,
        // which is the honest description: there is no session either way.
        await _clearFlag();
        break;
      default:
        // signedIn / initialSession / tokenRefreshed / userUpdated all mean the
        // session is healthy. We deliberately do NOT *set* the flag on signedIn:
        // a session is necessary to enter the app but not sufficient, because
        // onboarding may still be unfinished. Only the auth flow's own
        // completion may say "she is through".
        break;
    }
  }

  static Future<void> _clearFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kAuthCompletedKey, false);
    } catch (e) {
      debugPrint('SessionWatch could not clear the auth flag: $e');
    }
  }

  /// Stop watching. Only used by tests; the app watches for its whole life.
  @visibleForTesting
  static Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}

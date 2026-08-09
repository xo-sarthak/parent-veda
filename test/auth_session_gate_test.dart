// =============================================================================
//  The local "logged in" flag may never outlive the session it stands for.
// -----------------------------------------------------------------------------
//  These guard a failure that produces NO symptom on the device: a revoked
//  session leaves `kAuthCompletedKey` set, the app boots normally, and every
//  cloud read returns [] while every write is skipped — silently, because that
//  is correct behaviour for "logged out". Local-first then hides it completely,
//  since her cached data is all still there. She finds out at reinstall.
//
//  Nothing here can log in to a real Supabase, so these pin the two structural
//  guarantees instead: the degradation contract, and that the gate is actually
//  wired at both places it has to be.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/auth/session_watch.dart';
import 'package:parentveda/services/remote/supabase_repo.dart';

void main() {
  group('an uninitialised backend behaves exactly like being logged out', () {
    // Supabase is never initialised in widget tests. Touching
    // `Supabase.instance` before initialize() THROWS, so every one of these
    // would be a crash rather than a graceful degradation if the guards were
    // dropped. That is the whole reason SupabaseRepo.userId catches.

    test('userId is null rather than throwing', () {
      expect(SupabaseRepo.userId, isNull);
    });

    test('isLoggedIn is false rather than throwing', () {
      expect(SupabaseRepo.isLoggedIn, isFalse);
    });

    test('SessionWatch.start() is safe to call with no backend', () {
      // Must not throw. An app that cannot start its session watcher must still
      // start.
      expect(SessionWatch.start, returnsNormally);
    });

    test('SessionWatch.start() is idempotent', () {
      expect(SessionWatch.start, returnsNormally);
      expect(SessionWatch.start, returnsNormally);
    });
  });

  group('the gate is wired at both halves', () {
    // A session can die two ways, and each needs its own half:
    //   * while the app RUNS   → SessionWatch hears signedOut
    //   * while the app is SHUT → no event ever fires; splash must check
    // Neither is sufficient alone, so both are asserted against the source.
    // Test counts are not evidence that a feature is reachable.

    test('splash requires a real session, not just the local flag', () {
      final src = File('lib/screens/splash_screen.dart').readAsStringSync();
      expect(
        src.contains('kAuthCompletedKey'),
        isTrue,
        reason: 'splash still reads the onboarding flag',
      );
      expect(
        src.contains('SupabaseRepo.isLoggedIn'),
        isTrue,
        reason: 'splash must ALSO require a live session — the flag alone lets '
            'a revoked session boot a normal-looking app that never syncs',
      );
    });

    test('SessionWatch is actually started by the app', () {
      final src = File('lib/main.dart').readAsStringSync();
      expect(
        src.contains('SessionWatch.start()'),
        isTrue,
        reason: 'a watcher nobody starts is the unreachable-code failure this '
            'repo keeps hitting — grep the call site, not the test count',
      );
    });

    test('sign-out clears the flag, in every profile screen that offers it', () {
      // Three separate sign-out buttons exist. One that clears the session but
      // leaves the flag set would re-create the exact bug this closes.
      for (final path in const [
        'lib/screens/profile_screen.dart',
        'lib/screens/ttc/ttc_profile_screen.dart',
      ]) {
        final src = File(path).readAsStringSync();
        expect(src.contains('kAuthCompletedKey'), isTrue,
            reason: '$path signs out without clearing the local flag');
        expect(src.contains('SocialAuth.signOutGoogle'), isTrue,
            reason: '$path leaves Play Services holding the cached Google '
                'account, so the next tap silently re-enters it');
      }
    });
  });
}

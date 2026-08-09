// =============================================================================
//  Password recovery, and the onboarding answers that must survive it.
// -----------------------------------------------------------------------------
//  The forgot-password flow was pure navigation for a long time: "Send reset
//  code", "Verify" and "Reset password" each just moved to the next screen, so
//  a locked-out mother was congratulated on a reset that never happened. These
//  pin that it is real, and that the two adjacent things it is easy to break —
//  the father's pairing screen, and profile answers collected with no session —
//  stay correct.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/auth/pending_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _authSrc() =>
    File('lib/screens/auth/auth_flow_screen.dart').readAsStringSync();

void main() {
  group('the reset flow actually talks to Supabase', () {
    test('each step calls the API that step needs', () {
      final src = _authSrc();
      expect(src.contains('resetPasswordForEmail'), isTrue,
          reason: '"Send reset code" must send one');
      expect(src.contains('verifyOTP'), isTrue,
          reason: '"Verify" must verify the typed code');
      expect(src.contains('OtpType.recovery'), isTrue,
          reason: 'the code is a recovery token, not a signup or magic-link one');
      expect(src.contains('UserAttributes(password:'), isTrue,
          reason: '"Reset password" must actually set the new password');
    });

    test('no step is left as bare navigation', () {
      final src = _authSrc();
      for (final stub in const [
        "_primaryBtn('Send reset code', () => _go('otp'))",
        "_primaryBtn('Verify', () => _go('reset'))",
        "_primaryBtn('Reset password', () => _go('success'))",
      ]) {
        expect(src.contains(stub), isFalse,
            reason: 'this stub reports success while doing nothing: $stub');
      }
    });

    test('resend sends again rather than saying "coming soon"', () {
      final src = _authSrc();
      expect(src.contains("_soon('Resend')"), isFalse);
      expect(src.contains('_sendResetCode(resend: true)'), isTrue);
    });
  });

  group('the code field matches the code Supabase sends', () {
    // Six boxes for a six-digit token. A five-box field fails in the one place
    // nothing catches: she types the right code and is told it is wrong.
    test('the OTP field is six digits, everywhere it is described', () {
      final src = _authSrc();
      expect(src.contains('_otpLength = 6'), isTrue);
      expect(src.contains('6-digit code'), isTrue,
          reason: 'the copy must not still promise a 5-digit code');
      expect(src.contains('5-digit code'), isFalse);
    });

    test('the boxes and their focus chain are driven by that one constant', () {
      final src = _authSrc();
      // Hard-coded bounds are how the 5/6 mismatch survived: the length lived
      // in four places and only some of them moved.
      expect(src.contains('List.generate(_otpLength'), isTrue);
      expect(src.contains('i < _otpLength'), isTrue);
    });
  });

  group('the father pairing screen is a different screen and stays untouched',
      () {
    // Two code-entry screens exist and they are unrelated: this one links a
    // father to the mother's child, the other resets a password.
    test('pairing still uses its own single field and its own RPC', () {
      final src = _authSrc();
      expect(src.contains('link_as_partner'), isTrue,
          reason: 'the father pairing RPC must still be called');
      expect(src.contains('_code = TextEditingController()'), isTrue,
          reason: 'pairing keeps its own single free-text controller');
      expect(src.contains('_startPairing'), isTrue);
    });

    test('pairing does not route through password recovery', () {
      final src = _authSrc();
      final pairingIdx = src.indexOf('Future<void> _startPairing');
      expect(pairingIdx, greaterThan(-1));
      final body = src.substring(pairingIdx, pairingIdx + 900);
      expect(body.contains('verifyOTP'), isFalse);
      expect(body.contains('OtpType'), isFalse);
    });
  });

  group('onboarding answers survive having no session', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('nothing pending by default', () async {
      expect(await PendingProfile.load(), isNull);
    });

    test('what is saved is what comes back', () async {
      final fields = <String, dynamic>{
        'name': 'Aditi',
        'role': 'mother',
        'due_date': '2026-11-02',
        'wa_opt_in': true,
      };
      await PendingProfile.save(fields);

      final back = await PendingProfile.load();
      expect(back, isNotNull);
      expect(back!['name'], 'Aditi');
      expect(back['role'], 'mother');
      // The due date is the answer the whole pregnancy stage is built on — the
      // one thing that must not be lost to a missing session.
      expect(back['due_date'], '2026-11-02');
      expect(back['wa_opt_in'], isTrue);
    });

    test('clear really clears', () async {
      await PendingProfile.save({'name': 'Aditi'});
      await PendingProfile.clear();
      expect(await PendingProfile.load(), isNull);
    });

    test('flush is a no-op when logged out, and KEEPS what it is holding',
        () async {
      // Supabase is not initialised here, so this is the logged-out path.
      await PendingProfile.save({'name': 'Aditi', 'due_date': '2026-11-02'});

      expect(await PendingProfile.flush(), isFalse);

      // The critical assertion: a failed flush must not discard the only copy.
      // Clearing optimistically would lose her due date the first time RLS
      // refused or the network dropped.
      final still = await PendingProfile.load();
      expect(still, isNotNull);
      expect(still!['due_date'], '2026-11-02');
    });
  });

  group('the pending profile is wired, not merely written', () {
    test('onboarding stashes it when there is no session', () {
      final src = _authSrc();
      expect(src.contains('PendingProfile.save('), isTrue);
      // Matched on the toast CALL, not the phrase — the phrase also appears in
      // the comment explaining why it was removed, and a test that cannot tell
      // live code from a comment about live code is worse than no test.
      expect(
        src.contains('Not logged in - turn OFF'),
        isFalse,
        reason: 'that toast was a developer note shown to a mother, and the '
            'reason email confirmation had to stay off',
      );
    });

    test('every route that gains a session flushes it', () {
      final src = _authSrc();
      expect(src.contains('PendingProfile.flush()'), isTrue);
      // One shared routing path means password login, social sign-in and
      // password reset cannot disagree about what onboarding-complete means.
      expect(src.contains('_routeAfterSession()'), isTrue);
    });

    test('a signup with no session is told so, not dropped into the app', () {
      final src = _authSrc();
      expect(src.contains('_needsEmailConfirm'), isTrue);
      expect(src.contains("case 'confirm'"), isTrue,
          reason: 'the confirm-your-email screen must be reachable');
      expect(src.contains('_finishOnboarding'), isTrue);
    });
  });
}

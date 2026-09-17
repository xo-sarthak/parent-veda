// =============================================================================
//  Phone OTP: the agreements between SQL, the Edge Functions and Dart.
// -----------------------------------------------------------------------------
//  Nothing here sends an SMS. What CAN be pinned is every place three files
//  must agree and would drift silently if they did not: the outcome words,
//  where identity comes from, the deploy flag, the hash, and the fact that the
//  phone is written by SQL and never by the app.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/auth/phone_otp.dart';

String _read(String p) => File(p).readAsStringSync();
String _sql() => _read('supabase/migrations/0080_phone_otp.sql');
String _send() => _read('supabase/functions/phone-otp-send/index.ts');
String _verify() => _read('supabase/functions/phone-otp-verify/index.ts');
String _shared() => _read('supabase/functions/_shared/phone_otp.ts');

void main() {
  group('the phone is an attribute, not an identity', () {
    test('neither function touches Supabase auth beyond asking who is calling', () {
      for (final src in [_send(), _verify()]) {
        expect(src.contains('auth.getUser()'), isTrue,
            reason: 'identity must come from the JWT');
        expect(src.contains('signInWithOtp'), isFalse);
        expect(src.contains('verifyOTP'), isFalse,
            reason: 'Supabase phone auth would make the number a second login');
        expect(src.contains('auth.admin'), isFalse,
            reason: 'nothing here creates, links or deletes users');
      }
    });

    test('the profile is stamped by SQL, in the consume transaction, not by TS', () {
      expect(_sql().contains('phone_verified_at = now()'), isTrue);
      expect(_verify().contains("from('profiles')"), isFalse);
      expect(_verify().contains('.update('), isFalse,
          reason: 'two writers for one fact can disagree; SQL is the one');
      expect(_send().contains('phone_verified_at'), isFalse);
    });

    test('the Dart side never writes the phone itself after verifying', () {
      final src = _read('lib/services/auth/phone_otp.dart');
      expect(src.contains("from('profiles')"), isFalse);
      expect(src.contains('WhatsAppPrefs.write'), isFalse);
    });
  });

  group('the rules live in SQL, atomically', () {
    test('both limits and the attempt cap are in phone_otp_limits()', () {
      final sql = _sql();
      expect(sql.contains('phone_otp_limits()'), isTrue);
      expect(sql.contains("raise exception 'rate_limited:phone'"), isTrue);
      expect(sql.contains("raise exception 'rate_limited:user'"), isTrue);
      expect(sql.contains('for update'), isTrue,
          reason: 'consume must lock the row it is counting attempts on');
    });

    test('the Edge function does not re-implement a limit', () {
      final src = _send();
      expect(RegExp(r'count\s*[><]=?\s*\d').hasMatch(src), isFalse,
          reason: 'a limit checked in TS then inserted in SQL can race');
    });

    test('the OTP table is invisible to the app', () {
      final sql = _sql();
      expect(sql.contains('grant select, insert, update, delete on public.phone_otps to service_role'), isTrue);
      expect(RegExp(r'grant .* on public\.phone_otps to authenticated').hasMatch(sql), isFalse);
      expect(RegExp(r'create policy .* on public\.phone_otps').hasMatch(sql), isFalse,
          reason: 'RLS on with no policies = nobody but service_role');
      for (final fn in ['phone_otp_issue', 'phone_otp_consume', 'phone_otp_sent', 'phone_otp_prune']) {
        expect(sql.contains('public.$fn('), isTrue);
        expect(RegExp('revoke execute on function\\s+public\\.$fn\\(').hasMatch(sql), isTrue,
            reason: '$fn must be revoked from public');
      }
    });
  });

  group('three files agree on the vocabulary', () {
    test('every SQL outcome word has a Dart name, and nothing else does', () {
      final sql = _sql();
      const words = {
        'verified': PhoneOtpOutcome.verified,
        'wrong': PhoneOtpOutcome.wrong,
        'expired': PhoneOtpOutcome.expired,
        'too_many': PhoneOtpOutcome.tooMany,
        'none': PhoneOtpOutcome.none,
      };
      for (final e in words.entries) {
        expect(sql.contains("return '${e.key}'"), isTrue,
            reason: "SQL must be able to return '${e.key}'");
        expect(PhoneOtp.outcomeFromWord(e.key), e.value);
      }
      expect(PhoneOtp.outcomeFromWord('anything else'), PhoneOtpOutcome.failed);
      expect(PhoneOtp.outcomeFromWord(null), PhoneOtpOutcome.failed);
    });

    test('one hash, shared, salted by the user id', () {
      final shared = _shared();
      expect(shared.contains('`\${userId}:\${code}`'), isTrue);
      expect(_send().contains('from "../_shared/phone_otp.ts"'), isTrue);
      expect(_verify().contains('from "../_shared/phone_otp.ts"'), isTrue);
      expect(_verify().contains('phone-otp-send/index.ts'), isFalse,
          reason: 'importing a module that calls serve() starts a second server');
      expect(shared.contains('crypto.getRandomValues'), isTrue);
      expect(shared.contains('Math.random('), isFalse);
    });

    test('the code never appears in a response body', () {
      final src = _send();
      // The only json() that mentions the code would be a leak. `sent: true`
      // and the phone are fine; the digits are not.
      final responses = RegExp(r'return json\(\{[^}]*\}').allMatches(src).map((m) => m.group(0)!);
      // `code` as a JS value — `{ code }`, `code:`, `${code}` — not the word
      // inside an English error string.
      final asValue = RegExp(r'[{,]\s*code\s*[,:}]|\$\{code\}');
      for (final r in responses) {
        expect(asValue.hasMatch(r), isFalse, reason: 'leaked in: $r');
      }
    });
  });

  group('deploy notes keep JWT verification on', () {
    test('neither function is documented with --no-verify-jwt', () {
      expect(_send().contains('deploy phone-otp-send\n'), isTrue);
      expect(_send().contains('--no-verify-jwt'), isFalse);
      expect(_verify().contains('deploy phone-otp-verify\n'), isTrue);
      expect(_verify().contains('--no-verify-jwt'), isFalse);
    });

    test('the template contract (app hash on the last line) is written where the sender is', () {
      // The line that makes auto-fill work is set on MSG91, outside this repo.
      // If it is not documented next to the code that depends on it, the next
      // person changes the template copy and auto-fill dies silently.
      expect(_send().contains('{APP_HASH}'), isTrue);
      expect(_send().contains('<#>'), isTrue);
      expect(_send().contains('DLT'), isTrue);
    });
  });

  group('PhoneOtpController — the sheet\'s sequence without a sheet', () {
    PhoneOtpSend sent() => PhoneOtp.sendResultForTest(
        PhoneOtpSendStatus.sent, phone: '+919876543210', expiresIn: 300);

    test('idle → sending → sent, keeping the server\'s number', () async {
      final c = PhoneOtpController(
        send: (_) async => sent(),
        verify: (_, _) async => PhoneOtpOutcome.verified,
      );
      final steps = <PhoneOtpStep>[];
      c.addListener(() => steps.add(c.step));
      await c.requestCode('98765 43210');
      expect(steps, [PhoneOtpStep.sending, PhoneOtpStep.sent]);
      expect(c.phone, '+919876543210');
      expect(c.expiresAt, isNotNull);
    });

    test('each server word lands on its own step', () async {
      for (final e in {
        PhoneOtpOutcome.verified: PhoneOtpStep.verified,
        PhoneOtpOutcome.wrong: PhoneOtpStep.wrong,
        PhoneOtpOutcome.expired: PhoneOtpStep.expired,
        PhoneOtpOutcome.tooMany: PhoneOtpStep.tooMany,
        PhoneOtpOutcome.none: PhoneOtpStep.expired,
        PhoneOtpOutcome.invalidCode: PhoneOtpStep.sent,
        PhoneOtpOutcome.offline: PhoneOtpStep.offline,
      }.entries) {
        final c = PhoneOtpController(
          send: (_) async => sent(),
          verify: (_, _) async => e.key,
        );
        await c.requestCode('9876543210');
        await c.submitCode('123456');
        expect(c.step, e.value, reason: '${e.key}');
      }
    });

    test('a guess before a send is ignored, and a busy controller ignores re-entry', () async {
      var sends = 0;
      final c = PhoneOtpController(
        send: (_) async {
          sends++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return sent();
        },
        verify: (_, _) async => PhoneOtpOutcome.verified,
      );
      await c.submitCode('123456');
      expect(c.step, PhoneOtpStep.idle);
      final a = c.requestCode('9876543210');
      final b = c.requestCode('9876543210'); // while sending
      await Future.wait([a, b]);
      expect(sends, 1);
    });

    test('rate limited blocks resend until the server\'s wait is over', () async {
      final c = PhoneOtpController(
        send: (_) async => PhoneOtp.sendResultForTest(
            PhoneOtpSendStatus.rateLimited, retryAfter: 600),
        verify: (_, _) async => PhoneOtpOutcome.verified,
      );
      await c.requestCode('9876543210');
      expect(c.step, PhoneOtpStep.rateLimited);
      expect(c.canResend, isFalse);
      expect(c.retryAfterSeconds, 600);
    });
  });
}

// =============================================================================
//  PhoneOtp — verify a phone number as an ATTRIBUTE of the signed-in user
// -----------------------------------------------------------------------------
//  The app half of the `phone-otp-send` / `phone-otp-verify` Edge Functions
//  (migration 0080). Google is the identity; the phone is verified so
//  WhatsApp can be sent to it, and never becomes a way to sign in. That is
//  why nothing here touches `Supabase.auth` — a verified number is written
//  to `profiles.phone` + `profiles.phone_verified_at` by the server, in the
//  same transaction that consumed the code, and this side only asks.
//
//  THE TWO-TAP PATH (docs/ONBOARDING-AUDIT.md §4, "Reach"):
//    1. [hintNumber]   Play Services shows the SIM's number; she taps it.
//    2. [send]         the server issues a code and MSG91 carries it.
//    3. [listenForCode] SMS Retriever hands the SMS to the app; the six
//                      boxes fill themselves.
//    4. [verify]       the server checks it and stamps the profile.
//  Steps 1 and 3 are Android-only (the decided platform) and degrade to
//  "she types it" everywhere else, including the emulator, which has no SIM.
//
//  WHY OUTCOMES ARE WORDS, NOT A BOOL: "expired", "wrong" and "too many" each
//  need a different button (BACKEND-PATTERNS §15b). The server returns the
//  word; this file only names it in Dart.
//
//  THE PART THAT CANNOT BE TESTED FROM HERE: step 3 only works if the SMS
//  ends with this build's 11-character app hash, and that line lives on the
//  MSG91 template. [appSignature] prints the hash so it can be copied there.
//  Debug and release keystores produce DIFFERENT hashes; the template must
//  carry the release one, and a debug build will not auto-fill against it.
// =============================================================================

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:smart_auth/smart_auth.dart';

import '../remote/supabase_repo.dart';
import '../whatsapp_prefs.dart';

/// What happened when a code was requested.
enum PhoneOtpSendStatus { sent, rateLimited, invalidPhone, offline, failed }

class PhoneOtpSend {
  final PhoneOtpSendStatus status;

  /// The number the SERVER normalised and sent to — show this, not what she
  /// typed, so the sheet says "+91 98••• ••210" about the right number.
  final String? phone;
  final int expiresInSeconds;
  final int retryAfterSeconds;

  const PhoneOtpSend._(this.status,
      {this.phone, this.expiresInSeconds = 0, this.retryAfterSeconds = 0});

  bool get ok => status == PhoneOtpSendStatus.sent;
}

/// What the server said about a guess. The first five are the SQL words
/// verbatim (`phone_otp_consume`); the last three never reached SQL.
enum PhoneOtpOutcome {
  verified,
  wrong,
  expired,
  tooMany,
  none, // no code was ever issued for this number — send first
  invalidCode, // not six digits; did not count as an attempt
  offline,
  failed,
}

class PhoneOtp {
  PhoneOtp._(); // static-only.

  /// Ask the server to issue a code to [rawPhone]. Normalised locally only so
  /// the request is well-formed; the server normalises again and SQL holds
  /// the final rule. Never throws.
  static Future<PhoneOtpSend> send(String rawPhone) async {
    final phone = WhatsAppPrefs.normalizePhone(rawPhone);
    if (phone == null) return const PhoneOtpSend._(PhoneOtpSendStatus.invalidPhone);
    if (!SupabaseRepo.isLoggedIn) return const PhoneOtpSend._(PhoneOtpSendStatus.failed);

    final res = await SupabaseRepo.invokeEdgeResult('phone-otp-send', {'phone': phone});
    if (res.status == 0) return const PhoneOtpSend._(PhoneOtpSendStatus.offline);
    final data = res.data ?? const <String, dynamic>{};
    if (res.status == 429) {
      return PhoneOtpSend._(PhoneOtpSendStatus.rateLimited,
          retryAfterSeconds: _int(data['retry_after_seconds']));
    }
    if (res.status == 400) return const PhoneOtpSend._(PhoneOtpSendStatus.invalidPhone);
    if (res.status >= 400 || data['sent'] != true) {
      return const PhoneOtpSend._(PhoneOtpSendStatus.failed);
    }
    return PhoneOtpSend._(PhoneOtpSendStatus.sent,
        phone: data['phone'] as String? ?? phone,
        expiresInSeconds: _int(data['expires_in_seconds'], 300));
  }

  /// Check [code] against the latest code issued for [rawPhone]. On
  /// [PhoneOtpOutcome.verified] the profile is ALREADY stamped server-side;
  /// nothing more to write here. Never throws.
  static Future<PhoneOtpOutcome> verify(String rawPhone, String code) async {
    final phone = WhatsAppPrefs.normalizePhone(rawPhone);
    final digits = code.replaceAll(RegExp(r'\D'), '');
    if (phone == null || digits.length != 6) return PhoneOtpOutcome.invalidCode;
    if (!SupabaseRepo.isLoggedIn) return PhoneOtpOutcome.failed;

    final res = await SupabaseRepo.invokeEdgeResult(
        'phone-otp-verify', {'phone': phone, 'code': digits});
    if (res.status == 0) return PhoneOtpOutcome.offline;
    if (res.status == 400) return PhoneOtpOutcome.invalidCode;
    if (res.status >= 400) return PhoneOtpOutcome.failed;
    return outcomeFromWord(res.data?['outcome']);
  }

  /// A [PhoneOtpSend] for tests, which cannot reach the private constructor.
  @visibleForTesting
  static PhoneOtpSend sendResultForTest(PhoneOtpSendStatus status,
          {String? phone, int expiresIn = 0, int retryAfter = 0}) =>
      PhoneOtpSend._(status,
          phone: phone, expiresInSeconds: expiresIn, retryAfterSeconds: retryAfter);

  /// The SQL word → the Dart name. Public so the contract test can pin the
  /// vocabulary against the migration.
  @visibleForTesting
  static PhoneOtpOutcome outcomeFromWord(Object? word) => switch (word) {
        'verified' => PhoneOtpOutcome.verified,
        'wrong' => PhoneOtpOutcome.wrong,
        'expired' => PhoneOtpOutcome.expired,
        'too_many' => PhoneOtpOutcome.tooMany,
        'none' => PhoneOtpOutcome.none,
        _ => PhoneOtpOutcome.failed,
      };

  // ---- Android conveniences ------------------------------------------------
  // Each returns null rather than throwing when it cannot help: wrong
  // platform, no SIM, she dismissed the sheet, Play Services missing. The
  // typed field is always the fallback and the caller never has to know why.

  static bool get _android => !kIsWeb && Platform.isAndroid;

  /// The SIM's number from the Play Services hint sheet, or null.
  static Future<String?> hintNumber() async {
    if (!_android) return null;
    try {
      final r = await SmartAuth.instance.requestPhoneNumberHint();
      return r.hasData ? r.requireData : null;
    } catch (e) {
      debugPrint('[phone-otp] hint unavailable: $e');
      return null;
    }
  }

  /// Wait for the OTP SMS and return its six digits, or null. Resolves when
  /// an SMS carrying this build's hash arrives, or when the retriever times
  /// out (~5 minutes, Play Services' own limit). Call [stopListening] if the
  /// sheet is dismissed first.
  static Future<String?> listenForCode() async {
    if (!_android) return null;
    try {
      final r = await SmartAuth.instance.getSmsWithRetrieverApi();
      final code = r.hasData ? r.requireData.code : null;
      if (code == null || code.length != 6) return null;
      return code;
    } catch (e) {
      debugPrint('[phone-otp] retriever unavailable: $e');
      return null;
    }
  }

  static Future<void> stopListening() async {
    if (!_android) return;
    try {
      await SmartAuth.instance.removeSmsRetrieverApiListener();
    } catch (_) {/* nothing to stop */}
  }

  /// This build's 11-character app hash — the line the MSG91 template must
  /// end with. Debug-only helper: print it once, copy it to the template.
  static Future<String?> appSignature() async {
    if (!_android) return null;
    try {
      final r = await SmartAuth.instance.getAppSignature();
      return r.hasData ? r.requireData : null;
    } catch (_) {
      return null;
    }
  }

  static int _int(Object? v, [int fallback = 0]) =>
      v is int ? v : (v is num ? v.toInt() : fallback);
}

/// The sheet's state, kept out of the widget so the sequence can be tested
/// without a screen: idle → sending → sent → verifying → verified, with the
/// failures as their own states because each is a different sentence.
class PhoneOtpController extends ChangeNotifier {
  /// [send] and [verify] default to the real calls; tests pass fakes.
  PhoneOtpController({
    this.send = PhoneOtp.send,
    this.verify = PhoneOtp.verify,
  });

  final Future<PhoneOtpSend> Function(String) send;
  final Future<PhoneOtpOutcome> Function(String, String) verify;

  PhoneOtpStep step = PhoneOtpStep.idle;
  String? phone; // as the server normalised it
  DateTime? expiresAt;
  int retryAfterSeconds = 0;
  PhoneOtpOutcome? lastOutcome;

  bool get busy =>
      step == PhoneOtpStep.sending || step == PhoneOtpStep.verifying;

  /// Whether a fresh code can be requested — not while one is in flight, and
  /// not while the server has said to wait.
  bool get canResend =>
      !busy &&
      step != PhoneOtpStep.verified &&
      (step != PhoneOtpStep.rateLimited || retryAfterSeconds == 0);

  Future<void> requestCode(String rawPhone) async {
    if (busy) return;
    step = PhoneOtpStep.sending;
    notifyListeners();
    final r = await send(rawPhone);
    switch (r.status) {
      case PhoneOtpSendStatus.sent:
        phone = r.phone;
        expiresAt = DateTime.now().add(Duration(seconds: r.expiresInSeconds));
        step = PhoneOtpStep.sent;
      case PhoneOtpSendStatus.rateLimited:
        retryAfterSeconds = r.retryAfterSeconds;
        step = PhoneOtpStep.rateLimited;
      case PhoneOtpSendStatus.invalidPhone:
        step = PhoneOtpStep.invalidPhone;
      case PhoneOtpSendStatus.offline:
        step = PhoneOtpStep.offline;
      case PhoneOtpSendStatus.failed:
        step = PhoneOtpStep.failed;
    }
    notifyListeners();
  }

  Future<void> submitCode(String code) async {
    if (busy || phone == null) return;
    step = PhoneOtpStep.verifying;
    notifyListeners();
    final o = await verify(phone!, code);
    lastOutcome = o;
    step = switch (o) {
      PhoneOtpOutcome.verified => PhoneOtpStep.verified,
      PhoneOtpOutcome.wrong => PhoneOtpStep.wrong,
      PhoneOtpOutcome.expired => PhoneOtpStep.expired,
      PhoneOtpOutcome.tooMany => PhoneOtpStep.tooMany,
      PhoneOtpOutcome.none => PhoneOtpStep.expired, // send again is the fix
      PhoneOtpOutcome.invalidCode => PhoneOtpStep.sent, // keep the boxes
      PhoneOtpOutcome.offline => PhoneOtpStep.offline,
      PhoneOtpOutcome.failed => PhoneOtpStep.failed,
    };
    notifyListeners();
  }
}

enum PhoneOtpStep {
  idle,
  sending,
  sent, // boxes shown, listening
  verifying,
  verified,
  wrong, // boxes shown, try again
  expired, // boxes hidden, "send another"
  tooMany, // boxes hidden, "send another"
  rateLimited, // wait, then "send another"
  invalidPhone,
  offline,
  failed,
}

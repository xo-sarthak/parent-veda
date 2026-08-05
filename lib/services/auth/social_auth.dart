// =============================================================================
//  SocialAuth — Google / Apple / Facebook sign-in, on top of Supabase.
// -----------------------------------------------------------------------------
//  Everything ends in the SAME place as email+password: a Supabase session, so
//  `SupabaseRepo.userId` is non-null and all ~25 stores sync exactly as before.
//  Social login is a different DOOR into the same house — it must not become a
//  second identity system.
// =============================================================================
//
//  TWO FLOWS, NOT ONE — the thing worth understanding here
//  ------------------------------------------------------
//  These providers do not work the same way, and the difference leaks all the
//  way up into how the UI has to await them.
//
//  GOOGLE is a *native token* flow. Play Services draws the account picker
//  in-process, hands us a signed ID token, and we post that token to Supabase.
//  No browser, no redirect, no app switch. It is a plain `await` that returns
//  a session — request in, answer out.
//
//  FACEBOOK is a *browser redirect* flow. We can only ask the OS to open a
//  Custom Tab; the session is minted later, when Facebook bounces the user
//  through Supabase's /auth/v1/callback and Android deep-links the result back
//  into the app. `signInWithOAuth` therefore returns `true` meaning "the
//  browser opened" — NOT "the user signed in". Those are very different claims,
//  and treating the first as the second is the classic bug in this flow: the
//  app cheerfully advances to the home screen while the user is still looking
//  at a Facebook password prompt.
//
//  So for Facebook we launch, then *listen* — `onAuthStateChange` is the real
//  completion signal, because it is the only thing that fires on the path the
//  session actually travels. The timeout below exists because a user who backs
//  out of the Custom Tab generates no event at all: Android gives us no
//  "cancelled" callback for a browser the user simply dismissed, so silence is
//  ambiguous and only a clock can end the wait.
//
//  Both paths funnel into one `SocialAuthResult` so the screen does not have to
//  care which shape it just used.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth_config.dart';
import '../../localization/app_language.dart';

/// Which button the user tapped.
enum SocialProvider { google, apple, facebook }

/// The outcome of one sign-in attempt.
///
/// Cancellation is modelled separately from failure on purpose. A user who
/// backs out of the account picker has not hit an error and must not be shown
/// one — an apologetic red snackbar for "changed my mind" is noise. The screen
/// checks [cancelled] first and stays silent.
class SocialAuthResult {
  const SocialAuthResult._(this.ok, this.cancelled, this.message);

  const SocialAuthResult.success() : this._(true, false, null);
  const SocialAuthResult.cancelled() : this._(false, true, null);
  const SocialAuthResult.failed(String message) : this._(false, false, message);

  /// True when a Supabase session now exists.
  final bool ok;

  /// True when the user backed out. Not an error; show nothing.
  final bool cancelled;

  /// Why it failed, phrased for a mother rather than for a log file.
  final String? message;
}

class SocialAuth {
  SocialAuth._(); // static-only.

  /// GoogleSignIn.initialize() is one-shot per process. Calling it twice is not
  /// harmless — it throws — so the future is cached and awaited by every caller
  /// after the first. Storing the *future* rather than a bool also makes two
  /// rapid taps safe: the second await joins the first initialise instead of
  /// racing a second one.
  static Future<void>? _googleInit;

  static SupabaseClient get _sb => Supabase.instance.client;

  /// Sign in with [provider]. Returns once a Supabase session exists (or the
  /// attempt ended). Never throws — every failure path becomes a
  /// [SocialAuthResult] the screen can render.
  static Future<SocialAuthResult> signIn(SocialProvider provider) async {
    switch (provider) {
      case SocialProvider.google:
        return _google();
      case SocialProvider.facebook:
        return _facebook();
      case SocialProvider.apple:
        return _apple();
    }
  }

  // === Google: native ID-token flow ========================================

  static Future<SocialAuthResult> _google() async {
    if (!AuthConfig.googleReady) {
      return SocialAuthResult.failed(S.now.socialNotSetUp('Google'));
    }

    try {
      _googleInit ??= GoogleSignIn.instance.initialize(
        serverClientId: AuthConfig.googleWebClientId,
        // Blank on Android; only iOS needs its own client id. Passing an empty
        // string would be read as a real (wrong) id, so send null instead.
        clientId: AuthConfig.googleIosClientId.isEmpty
            ? null
            : AuthConfig.googleIosClientId,
      );
      await _googleInit;

      // Interactive picker. `authenticate()` is unsupported on web, where
      // Google requires its own rendered button — guard so a future web build
      // fails with a sentence instead of a platform exception.
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return SocialAuthResult.failed(S.now.socialNotSetUp('Google'));
      }

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      // No ID token means the audience/client-id pairing is wrong — almost
      // always a missing or mismatched serverClientId. Worth its own message,
      // because the generic one sends you hunting in the wrong place.
      if (idToken == null) {
        // Developer-facing detail stays in the log; she gets the plain sentence.
        debugPrint('Google returned no idToken — check googleWebClientId.');
        return SocialAuthResult.failed(S.now.socialSignInFailed('Google'));
      }

      // The access token is OPTIONAL for authentication — Supabase verifies the
      // ID token's signature and audience, and that alone establishes identity.
      // We ask for one anyway (it is what would let us call Google APIs later,
      // e.g. reading the profile photo) but never let its absence block the
      // sign-in: a failed *authorization* must not fail *authentication*.
      String? accessToken;
      try {
        final auth = await account.authorizationClient
            .authorizeScopes(const ['email', 'profile']);
        accessToken = auth.accessToken;
      } catch (e) {
        debugPrint('Google scope authorization skipped: $e');
      }

      await _sb.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return const SocialAuthResult.success();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const SocialAuthResult.cancelled();
      }
      debugPrint('GoogleSignInException: ${e.code} ${e.description}');
      // The overwhelmingly common cause in development is an Android OAuth
      // client whose SHA-1 does not match the keystore that signed this build
      // — which Google reports only as a generic failure, with no hint.
      return SocialAuthResult.failed(S.now.socialSignInFailed('Google'));
    } on AuthException catch (e) {
      // Supabase rejected the token (provider disabled, or `aud` not in its
      // allowed client-id list).
      return SocialAuthResult.failed(e.message);
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return SocialAuthResult.failed(S.now.socialSignInFailed('Google'));
    }
  }

  // === Facebook: browser redirect flow =====================================

  /// How long to wait for the deep link to come back before giving up. Long
  /// enough for a real login (password, maybe a 2FA prompt), short enough that
  /// a spinner is not left running forever after an abandoned Custom Tab.
  static const Duration _redirectTimeout = Duration(minutes: 3);

  static Future<SocialAuthResult> _facebook() async {
    if (!AuthConfig.facebookReady) {
      return SocialAuthResult.failed(S.now.socialNotSetUp('Facebook'));
    }
    return _oauthRedirect(OAuthProvider.facebook, 'Facebook');
  }

  static Future<SocialAuthResult> _apple() async {
    if (!AuthConfig.appleReady) {
      return SocialAuthResult.failed(S.now.socialAppleSoon);
    }
    return _oauthRedirect(OAuthProvider.apple, 'Apple');
  }

  /// Shared browser-redirect driver for every non-native provider.
  static Future<SocialAuthResult> _oauthRedirect(
    OAuthProvider provider,
    String label,
  ) async {
    // SUBSCRIBE BEFORE LAUNCHING. If we opened the browser first and attached
    // the listener after, a fast redirect (an already-logged-in Facebook app
    // can round-trip in well under a second) could deliver `signedIn` into the
    // gap and we would wait out the full timeout on a sign-in that had already
    // succeeded. Ordering, not luck, is what closes that race.
    final completer = Completer<SocialAuthResult>();
    late final StreamSubscription<AuthState> sub;

    sub = _sb.auth.onAuthStateChange.listen(
      (state) {
        if (state.event == AuthChangeEvent.signedIn && !completer.isCompleted) {
          completer.complete(const SocialAuthResult.success());
        }
      },
      onError: (Object e) {
        if (!completer.isCompleted) {
          debugPrint('$label OAuth stream error: $e');
          completer.complete(
              SocialAuthResult.failed(S.now.socialSignInFailed(label)));
        }
      },
    );

    try {
      final launched = await _sb.auth.signInWithOAuth(
        provider,
        redirectTo: AuthConfig.oauthRedirect,
        // externalApplication hands off to the real browser / Custom Tab rather
        // than an in-app webview. Both Google and Meta actively BLOCK embedded
        // webviews for login (they defeat the user's ability to verify the URL
        // bar, and break password managers), so an in-app webview here would be
        // refused by the provider, not merely frowned upon.
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!launched) {
        return SocialAuthResult.failed(S.now.socialCouldNotOpen);
      }

      return await completer.future.timeout(
        _redirectTimeout,
        // A timeout here means "we never heard back" — nearly always because
        // the user dismissed the browser. Reported as cancelled, not failed,
        // for the same reason as above: it is usually not an error.
        onTimeout: () => const SocialAuthResult.cancelled(),
      );
    } on AuthException catch (e) {
      return SocialAuthResult.failed(e.message);
    } catch (e) {
      debugPrint('$label OAuth error: $e');
      return SocialAuthResult.failed(S.now.socialSignInFailed(label));
    } finally {
      await sub.cancel();
    }
  }

  // === Sign-out ============================================================

  /// Clear the Google SDK's own cached account, alongside Supabase's session.
  ///
  /// WHY THIS IS SEPARATE: `supabase.auth.signOut()` only drops OUR session.
  /// Play Services keeps its own record of "this app uses this Google account",
  /// so the next tap on Google would silently re-sign-in the same person with
  /// no picker shown. On a shared phone that is a real problem — sign out then
  /// hand the phone over, and the next person lands straight back in the first
  /// person's account. Callers should invoke this alongside their existing
  /// `auth.signOut()`.
  static Future<void> signOutGoogle() async {
    if (_googleInit == null) return; // never initialised → nothing cached
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // Best-effort, exactly like the Supabase sign-out beside it: a user who
      // taps sign out must not stay signed in because a plugin call failed.
      debugPrint('Google signOut skipped: $e');
    }
  }
}

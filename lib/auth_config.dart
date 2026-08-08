/// Social sign-in settings for ParentVeda (Google / Apple / Facebook).
///
/// Sits beside [SupabaseConfig] and follows the same rule: everything in here
/// is a PUBLIC identifier, safe to commit and safe to ship inside the APK.
///
/// WHAT IS *NOT* HERE, AND MUST NEVER BE:
///   * the Google OAuth **client secret**
///   * the Facebook **App Secret**
/// Those are real secrets. They are pasted into the Supabase dashboard
/// (Authentication → Providers), where they live server-side. Supabase performs
/// the secret half of the OAuth exchange on our behalf, which is precisely why
/// the app never needs them. An App Secret shipped in an APK is extractable in
/// about a minute with `apktool`, and rotating it means shipping a new build.
///
/// WHY A CLIENT *ID* IS SAFE BUT A SECRET IS NOT: the id only names which app is
/// asking. The secret proves it. Google and Meta both assume the id is public —
/// it is literally in the redirect URL the browser shows the user.
class AuthConfig {
  AuthConfig._(); // static-only; never instantiated.

  // === Google ==============================================================
  //
  // Counter-intuitive but correct: Android native sign-in uses the **Web**
  // client id, not the Android one.
  //
  // The Android OAuth client (the one you register with the package name and
  // the SHA-1 fingerprint) is never named in code. Google Play Services finds
  // it by matching the calling app's signature at runtime. What it *returns*
  // is an ID token, and that token's `aud` (audience) claim is set to the
  // **serverClientId** we pass below — i.e. "this token is intended for that
  // backend". Supabase then verifies the token and checks `aud` against the
  // client id list configured on its Google provider.
  //
  // So the two ids do different jobs:
  //   * Android client id  → proves *this build* may ask Google at all
  //                          (never appears here; matched via SHA-1)
  //   * Web client id      → names *who the token is for* (Supabase)
  //
  // Get it from: Google Cloud console → APIs & Services → Credentials →
  // the OAuth 2.0 Client ID of type "Web application".
  static const String googleWebClientId =
      '957944807064-a7bm8iuitmb1rhv6iadar92vm55poa9p.apps.googleusercontent.com';

  /// iOS only. Left blank while we are Android-first; filled when the iOS
  /// OAuth client exists. Passed as `clientId` to GoogleSignIn.initialize.
  static const String googleIosClientId = '';

  // === OAuth redirect (Facebook, and Apple-on-Android later) ===============
  //
  // Google is a *native* flow — the account picker is drawn by Play Services,
  // no browser involved, so no redirect is needed. Facebook has no such native
  // path through Supabase, so it runs the classic browser redirect:
  //
  //   app → Custom Tab → facebook.com → Supabase /auth/v1/callback → THIS URL
  //
  // Android routes that last hop back into the app by matching the scheme
  // against an intent-filter (android/app/src/parent/AndroidManifest.xml).
  // supabase_flutter listens for the incoming link and completes the session.
  //
  // This exact string must ALSO be added to the Supabase dashboard under
  // Authentication → URL Configuration → Redirect URLs. Supabase refuses to
  // redirect anywhere not on that allow-list — that check is what stops an
  // attacker appending `?redirect_to=evil.com` and stealing the token.
  static const String oauthRedirectScheme = 'com.parentveda.app';
  static const String oauthRedirect = '$oauthRedirectScheme://login-callback/';

  // === Availability gates ==================================================
  //
  // Every provider is gated on its own config rather than assumed present. The
  // reason is the repo's standing rule that an unconfigured backend must behave
  // exactly like being logged out — never a crash. Without these, a fresh
  // clone with empty ids would throw deep inside the Google SDK on first tap,
  // which reads to a tester as "social login is broken" rather than
  // "social login is not set up yet".

  /// True once the Google client id has been filled in above.
  static bool get googleReady => googleWebClientId.isNotEmpty;

  /// Facebook needs no id in the app at all — the App ID and Secret live in the
  /// Supabase dashboard. The only app-side requirement is the deep link, which
  /// is compiled in. So this is a manual switch: flip it to true once the
  /// provider is enabled in the Supabase dashboard.
  static const bool facebookReady = false;

  /// Sign in with Apple needs a paid Apple Developer account ($99/yr, about
  /// ₹8,300/yr) for the Services ID and signing key. On Android it can only run
  /// as a browser redirect flow. Off until that account exists.
  static const bool appleReady = false;
}

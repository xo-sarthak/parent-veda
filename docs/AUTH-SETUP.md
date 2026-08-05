# Social sign-in — the console half

The Dart side is done and committed. **Nothing below happens in code** — it is
account and console work, and until it is finished each social button explains
itself rather than failing. That degradation is deliberate: an unconfigured
provider must behave like "not set up yet", never like a crash.

Status today: **Android only.** iOS and Sign in with Apple are deferred (see the
last section).

| Provider | Flow | Cost | State |
|---|---|---|---|
| Google | Native (Play Services → ID token) | Free | Code done, awaiting §1–§2 |
| Facebook | Browser redirect (Custom Tab) | Free | Code done, awaiting §3 |
| Apple | Browser redirect on Android | $99/yr (≈ ₹8,300/yr) | Deferred — no account |

---

## The one idea worth holding first

**Supabase is the only thing that ever talks to Google or Meta with a secret.**

The app holds public identifiers only. It collects a token or opens a browser,
and Supabase does the half that requires proving who we are. That is why
`lib/auth_config.dart` has no secret in it and never should: an App Secret
inside an APK is extractable in about a minute, and rotating it would mean
shipping a new build to every user.

---

## 1. Google Cloud console

You need **two** OAuth clients. They do different jobs and both must exist.

### 1a. The Web client — the one the code actually names

1. Google Cloud console → **APIs & Services → Credentials**
2. **Create Credentials → OAuth client ID → Application type: Web application**
3. Name it `ParentVeda Supabase`
4. Under **Authorised redirect URIs**, add exactly:
   ```
   https://csrabzuhxbschkeyohha.supabase.co/auth/v1/callback
   ```
5. Create → copy the **Client ID** (ends `.apps.googleusercontent.com`)
6. Paste it into `lib/auth_config.dart` → `googleWebClientId`
7. Also copy the **Client secret** — it goes into Supabase in §2, not into the app

### 1b. The Android client — the one that is never named in code

1. Same screen → **Create Credentials → OAuth client ID → Android**
2. **Package name:** `com.parentveda.app`
3. **SHA-1 certificate fingerprint** — your debug keystore, already read off this machine:
   ```
   E7:04:EF:8C:DC:C8:A4:F3:4B:B3:56:0F:BB:55:35:E8:74:27:B4:F2
   ```
4. Create. That is all — you never copy this id anywhere.

**Why nothing references it:** Play Services identifies the calling app by its
signing certificate at runtime, not by an id we pass. The Android client is what
grants *this build* permission to ask at all; the Web client id is what the
returned token is *addressed to* (its `aud` claim), which is how Supabase knows
the token was meant for us. Two different questions, two different clients.

> **The single most common failure.** A SHA-1 that does not match the keystore
> that signed the running build makes Google fail with a generic error and no
> hint. The fingerprint above is the **debug** one. Before any release build you
> must add a second Android OAuth client (same package name) with the **release**
> SHA-1 — and if you ship via Play Store App Signing, Google **re-signs your
> APK**, so the fingerprint that matters is the one in
> *Play Console → Setup → App signing*, not your local upload keystore. Adding
> only the local one is why "it works in debug, breaks in production" is the
> classic version of this bug.

### 1c. If Google asks you to configure a consent screen

Fill in app name, support email, and developer email. While in **Testing** mode
only accounts on the test-users list can sign in — add your own. Publishing is
only needed before real users arrive; the `email`/`profile` scopes we request are
non-sensitive, so no Google review is required.

---

## 2. Supabase — enable Google

1. Supabase dashboard → **Authentication → Providers → Google** → enable
2. **Client ID:** the Web client id from §1a
3. **Client Secret:** the Web client secret from §1a
4. In the **Authorized Client IDs** field, paste the Web client id **again**

Step 4 looks redundant and is not. It is the list Supabase checks the incoming
token's `aud` claim against on the *native* path, where there is no redirect and
no secret exchange — just a token arriving and needing to be believed. Skip it
and native Google sign-in fails while the browser flow would have worked.

Then, still in Supabase → **Authentication → URL Configuration → Redirect URLs**, add:
```
com.parentveda.app://login-callback/
```
Supabase refuses to redirect anywhere not on this allow-list — that check is what
stops someone appending their own `redirect_to` and walking off with a session.

**At this point Google sign-in works.** Run `flutter run --flavor parent` and test
before starting Facebook.

---

## 3. Meta / Facebook

1. developers.facebook.com → your app → **Add Product → Facebook Login → Settings**
2. **Valid OAuth Redirect URIs:**
   ```
   https://csrabzuhxbschkeyohha.supabase.co/auth/v1/callback
   ```
3. **Settings → Basic** → copy the **App ID** and **App Secret**
4. Supabase → **Authentication → Providers → Facebook** → enable, paste both
5. In `lib/auth_config.dart`, set `facebookReady = true`

No Facebook SDK is added to the app and no App ID lives in it — this runs entirely
through the browser redirect, which is why the only app-side requirement is the
deep link in `android/app/src/parent/AndroidManifest.xml`.

**Before real users:** Meta requires a privacy-policy URL and App Review of the
`public_profile` + `email` permissions to leave Development mode. In Development
mode only accounts with a role on the app (admin/developer/tester) can log in —
enough for your own testing, not enough to ship.

---

## 4. What is deliberately not done

**Sign in with Apple.** Needs the Apple Developer Program — **$99/yr (≈ ₹8,300/yr)**
— for the Services ID and signing key, plus a Mac to build iOS. The Apple button
is still shown and says so when tapped, rather than being hidden.

When you do get there, one rule to know in advance: **Apple's App Store
guidelines require offering Sign in with Apple if you offer Google or Facebook
login.** So the iOS build cannot ship with Google-only — Apple becomes mandatory
the moment iOS becomes real, and `appleReady` plus `googleIosClientId` are the
two switches waiting for it.

**Account linking across providers.** If someone signs up with Google
(`x@gmail.com`) and later taps Facebook with the same address, Supabase's
behaviour depends on the *Confirm email* and identity-linking settings on the
project. Worth deciding explicitly before launch, because the wrong answer
silently creates two accounts — two profiles, two sets of journal entries, and a
mother who thinks her data vanished. Not urgent while only Google is live.

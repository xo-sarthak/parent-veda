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

## 3. ~~Meta / Facebook~~ — NOT DOING THIS

**Decided 2026-08-09: Facebook login is not being built.** Not deferred — ruled
out. Reasoning is in §5. The runbook below is kept only so the decision can be
reversed knowingly rather than rediscovered; **do not work through it.**

<details>
<summary>Superseded runbook (do not follow)</summary>

### ~~Meta / Facebook~~

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

</details>

---

## 3b. Email templates — REQUIRED, or forgot-password silently breaks

The app sends a **6-digit code**, not a magic link, because a link has nowhere
to land when the product is an app (see `_sendResetCode` for the full reasoning).

Supabase's stock **Reset Password** template contains only
`{{ .ConfirmationURL }}`. Leave it that way and the mail arrives **with no code
in it** — the flow then fails at a step nothing in the app can detect, because
from our side everything succeeded.

**Authentication → Emails → Reset Password**, make sure the body includes:

```html
<h2>Reset your ParentVeda password</h2>
<p>Your code is:</p>
<p style="font-size:28px;font-weight:700;letter-spacing:4px">{{ .Token }}</p>
<p>It expires in an hour. If you didn't ask for this, ignore this email.</p>
```

`{{ .Token }}` is the six-digit code. Keep `{{ .ConfirmationURL }}` out — a link
beside a code just invites her to click the one that cannot work.

Do the same for **Confirm signup** if you enable email confirmation, though that
one legitimately stays a link: it is clicked in a browser, not typed into the app.

## 3c. Account deletion — one deploy, one web page

Google Play rejects apps that offer account creation without in-app deletion
**and** a web route. The in-app half is built (Profile → Delete account).

**Deploy the function:**

```bash
supabase functions deploy delete-account
```

**Do NOT add `--no-verify-jwt`.** Two other functions in this repo use that flag
legitimately; this one holds the `service_role` key, and an unsigned request must
never be able to reach it. No secrets to configure — `SUPABASE_URL`,
`SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically.

**The web route you still owe:** a page on `parentveda.in` explaining how to
request deletion — what gets deleted, how long it takes, and an email address to
write to. Play wants a URL reachable *without* installing the app. A static page
is enough; it does not have to perform the deletion itself.

## 4. The iOS + Apple round (planned, not started)

iOS **will** ship, so Apple is a scheduled round rather than a maybe.

**The rule that shapes the work:** Sign in with Apple must run on **Android too**,
even though Apple only requires it on iOS. If a mother signs up with Apple on an
iPhone and later opens the app on Android — new phone, or her partner's — Apple
is the *only* door to her account. Without the Android half she is locked out of
her own pregnancy data with no recovery path. So: **native on iOS, browser
redirect on Android.** That is what the redirect machinery already in
`SocialAuth._oauthRedirect` is for; today it has no live consumer.

Your side:

| Item | Cost |
|---|---|
| Apple Developer Program (Services ID + signing key) | **$99/yr (≈ ₹8,400/yr)** |
| A Mac, or a cloud macOS runner (Codemagic / GitHub Actions have free tiers) | — |
| Register `com.parentveda.app` as an App ID with Sign in with Apple enabled | — |
| Supabase → Providers → Apple: **Services ID**, **Team ID**, **Key ID**, `.p8` key | — |
| A *third* Google OAuth client, type **iOS** → goes in code as `googleIosClientId` | — |

Code side:

- `sign_in_with_apple` package; native on iOS, `_oauthRedirect` on Android
- `ios/Runner/Info.plist` — **no `CFBundleURLTypes` exist at all today**; needs the
  OAuth callback scheme and Google's reversed-client-id scheme
- `AuthConfig.appleReady = true` — the button then appears on both platforms
  automatically (see `_socialButtons` in `auth_flow_screen.dart`)

## 5. What is deliberately not done

**Facebook — ruled out, decided 2026-08-09.** Not parked, not "later": it is not
being built. The reasoning:

- **It adds almost no reach.** Every Android device in India is already signed
  into a Google account — that is a precondition of using the Play Store. Google
  login covers essentially the whole Android user base.
- **It costs real work**: Meta App Review before public launch (privacy policy,
  screencast, data-use questionnaire, periodic re-review), plus a data-deletion
  callback endpoint to host and maintain.
- **It adds an account-linking edge case** — the same email via Google and
  Facebook, i.e. the duplicate-account trap below.
- **Trust.** This app holds maternal health data. "Log in with Facebook" reads to
  some users as "Meta learns I am pregnant". Not what happens technically, but a
  strange perception cost for a door nobody needs.

`facebookReady` stays `false` and the button is not rendered. The few lines
behind that flag are kept rather than deleted — partly per the house rule, and
partly because they are not Facebook-specific: **the same browser-redirect path
is what Sign in with Apple will use on Android.** The flag is the only thing
that was ever Facebook.

**A better third door, if one is ever wanted: phone OTP.** India-first, no
password to forget, and MSG91 is already wired for WhatsApp — so the provider
relationship and the number-collection UX exist. It also overlaps with the
forgot-password work.

**Account linking across providers.** If someone signs up with Google
(`x@gmail.com`) and later taps Facebook with the same address, Supabase's
behaviour depends on the *Confirm email* and identity-linking settings on the
project. Worth deciding explicitly before launch, because the wrong answer
silently creates two accounts — two profiles, two sets of journal entries, and a
mother who thinks her data vanished. Not urgent while only Google is live.

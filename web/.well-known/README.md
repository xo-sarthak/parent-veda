# App Links — what to host on parentveda.in

`assetlinks.json` in this folder must be served at exactly:

    https://parentveda.in/.well-known/assetlinks.json

Requirements Android is strict about:

* served over **HTTPS** with a valid certificate,
* `Content-Type: application/json`,
* **no redirects** (not even http -> https on this path),
* HTTP 200.

Once it is live, Android verifies it on install and `parentveda.in/invite/<CODE>`
opens the app directly with no "open with" chooser. Until then the link still
works — it just shows the chooser, or opens the website.

## The fingerprint in the file

The one currently listed is the **DEBUG** keystore on this machine
(`~/.android/debug.keystore`), so App Links verify while testing on this
laptop's builds.

**Before release you must add the RELEASE fingerprint too.** The array takes
several, so keep both — otherwise links stop working the moment you ship a
Play-signed build:

    keytool -list -v -keystore <your-release.jks> -alias <your-alias>

If you use **Play App Signing** (most apps do), the fingerprint that matters is
the one Google shows under *Play Console -> Release -> Setup -> App signing ->
App signing key certificate*, NOT your upload key. Getting this wrong is the
usual reason App Links silently stop verifying after launch.

## Checking it

    adb shell pm verify-app-links --re-verify com.parentveda.app
    adb shell pm get-app-links com.parentveda.app

You want `verified` beside parentveda.in.

## iOS

Universal Links need a matching `apple-app-site-association` file (same folder,
no extension, JSON, no redirects) plus the Associated Domains capability in
Xcode. That needs the Apple Developer account and Team ID, so it is not written
here yet.

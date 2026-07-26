# `/care/<TOKEN>` — Care Partner landing page

**For:** whoever builds parentveda.in
**Status:** returns 404 today. Until it exists, no doctor's QR code works.

---

## 1. Why this page exists

A phone camera **cannot open an app that is not installed**. There is no way
around that on either platform.

So when a pregnant woman in a clinic waiting room points her camera at the QR
poster on the wall, the camera opens **a browser**. Every single scan, without
exception, lands on a web page before it lands anywhere else.

This is that page. It is the bridge between a poster on a wall and the app.

If it 404s, the scan does nothing, and the doctor who put the poster up never
gets credit for a single family. The entire Care Partner platform — attribution,
the parent's Care Circle, the doctor's impact dashboard, commission — hangs off
this one page working.

**The app side is already built and tested.** Nothing in the Flutter app needs to
change. This page is the only missing piece.

---

## 2. The URL

```
https://parentveda.in/care/<TOKEN>?ch=<CHANNEL>&cm=<CAMPAIGN>
```

| Part | Notes |
|---|---|
| `<TOKEN>` | **exactly 10 characters**, from `ABCDEFGHJKMNPQRSTUVWXYZ23456789` |
| `ch` | optional. Which surface the link was used on — see §5 |
| `cm` | optional. Campaign id |

The alphabet has **no I, L, O, 0 or 1** on purpose, so nobody mistypes a code
read off a printed poster. Treat the token as case-insensitive and uppercase it.

### Do not confuse this with `/invite/`

`/invite/<CODE>` already exists and is a **different system** — parent invites
parent, 7-character codes. `/care/` is doctor invites parent, 10-character
tokens. They must never resolve each other's links. The app enforces this and
has tests that fail if it ever stops.

---

## 3. What the page must do

Three kinds of visitor, three different jobs.

### 3a. Android, app not installed — **the critical path**

Redirect to the Play listing for `com.parentveda.app` with a `referrer`
parameter carrying the token:

```
https://play.google.com/store/apps/details
  ?id=com.parentveda.app
  &referrer=<URL-ENCODED STRING BELOW>
```

The string, before encoding:

```
utm_source=care&utm_medium=partner&utm_content=<TOKEN>&utm_term=<CH>&utm_campaign=<CM>
```

Omit `utm_term` / `utm_campaign` when `ch` / `cm` are absent.

Worked example — token `KM7QX2PDVR`, `?ch=qr`:

```
referrer=utm_source%3Dcare%26utm_medium%3Dpartner%26utm_content%3DKM7QX2PDVR%26utm_term%3Dqr
```

Google Play hands that string to the app on first launch (Play Install Referrer
API). It is the **only free mechanism** that carries an identifier through an
app-store install, and it is what the app already reads.

Two rules that are not negotiable:

* **`utm_source=care` is mandatory.** It is the *only* thing that tells a doctor
  token apart from a parent invite code. Never distinguish them by length — the
  day either length changes, the app silently starts crediting the wrong person
  and nothing errors anywhere.
* **`utm_term` must carry `ch` through.** Without it every scan is recorded as a
  QR, so a doctor's WhatsApp message gets counted as poster traffic and the
  channel analytics is quietly wrong rather than missing.

### 3b. App already installed

The link should open the app directly. That is an Android App Link and needs a
file this site does not yet serve:

```
https://parentveda.in/.well-known/assetlinks.json     (currently 404)
```

Content-Type must be `application/json`. It needs the **Play App Signing**
SHA-256 fingerprint, not a local debug one — ask before publishing it, we have
to pull it from the Play Console.

The app's manifest already declares `autoVerify` for `/care` and `/invite` on
`parentveda.in`, so this file is the only thing missing.

Do **not** try to detect whether the app is installed in JavaScript. Serve the
page normally; Android intercepts the URL before the browser sees it once
`assetlinks.json` is live.

### 3c. iOS, or desktop

Apple has no install-referrer equivalent — nothing can carry the token through
an App Store install. So:

* show the token on screen, clearly, in a large monospaced style
* tell her to enter it in the app when asked
* link to the App Store

This is the same fallback `/invite/` already uses. Manual entry is a permanent
part of the product on iOS, not a stopgap.

---

## 4. What the page should show

She scanned a code in a doctor's office and has no idea what she is about to
install. The page has one job before the redirect: **tell her who invited her.**

```
        [ doctor's photo ]

        INVITED BY
        Dr Meera Rao
        Obstetrician · Rainbow Hospital, Hyderabad

        ParentVeda is a calm, bilingual companion for
        pregnancy and the early days after.

        [ Get the app ]

        Your code: KM7QX2PDVR
```

### The one hard rule on wording

**Never** "Sponsored by", "Advertisement", "Promotion", "Promoted", or "Ad by".

This is a doctor recommending something to a patient, not an advert. The app
enforces this in three separate places (a fallback in the model, a DB CHECK
constraint, and the only component that renders a partner). The website is the
fourth place and there is nothing automatic protecting it — so it is on you.

Allowed labels come from the database (§5). Typical values: *Invited by*,
*Recommended by*, *Connected through*, *Your Care Partner*, *Supported by*.

---

## 5. Reading the doctor's details

Query Supabase directly from the page. Both tables are **public-read including
signed-out** — that RLS policy exists specifically so this page can name the
doctor before anyone has an account. Use the anon key.

**Step 1 — resolve the token to a partner**

```sql
select partner_id, campaign_id, channel, active, expires_at
from partner_referrals
where token = '<TOKEN UPPERCASED>' and active;
```

**Step 2 — read the partner**

```sql
select name, type, speciality, organisation, department, city,
       photo_url, logo_url, trust
from care_partners
where id = '<partner_id>' and deleted_at is null;
```

`trust` is JSON. Use `trust->>'primary'` as the label above the name; fall back
to `"Invited by"` when it is absent **or when it contains any banned word from
§4**. Fail closed — never render an unrecognised label.

For an organisation (hospital, clinic, lab, IVF centre) prefer `logo_url` and
square corners; for a person prefer `photo_url` and a circle. If neither exists,
draw initials — never a broken image.

**`ch` values** the app understands, for `utm_term`:
`qr` · `link` · `whatsapp` · `sms` · `email` · `nfc` · `poster` ·
`prescription` · `report` · `website` · `manual`

---

## 6. Failure cases

| Situation | What to do |
|---|---|
| Token not found, inactive, or expired | **Do not error.** Show a normal ParentVeda page and still send her to the store. A poster that has been on a wall for two years must not dead-end a real person — she just wants the app. |
| Supabase unreachable | Same. Render the generic page and redirect. The token still rides in the `referrer`, so attribution survives even when the page could not name the doctor. |
| Malformed token (wrong length/characters) | Generic page, no `referrer`. Do not pass junk through. |
| Bot / link preview crawler | Serve the page. Never auto-redirect on the server — WhatsApp and Slack previews would consume the redirect. Redirect from the client, or behind a button. |

The principle: **a broken poster should cost the doctor their credit, never cost
the parent the app.**

---

## 7. Definition of done

- [ ] `/care/<TOKEN>` returns 200 for any well-formed 10-character token
- [ ] Android redirect includes `referrer=` with `utm_source=care` and the token in `utm_content`
- [ ] `ch` from the query string is forwarded as `utm_term`
- [ ] The doctor's real name and photo render from `care_partners`
- [ ] No banned word can appear, whatever `trust` contains
- [ ] Unknown / expired / inactive token still reaches the store without an error page
- [ ] Token displayed on screen for manual entry (iOS)
- [ ] `/.well-known/assetlinks.json` served as `application/json` with the Play App Signing SHA-256

### Also needed, same contract, different page

When the app goes live on Play, **`/invite/<CODE>` needs the same treatment**.
It currently renders the code but has no store button and no `referrer`, so a
friend installing from a shared link arrives with nothing attached. Same
mechanism, different source value:

```
utm_source=invite&utm_medium=referral&utm_content=<7-CHAR CODE>
```

---

## 8. Answers to the build questions (2026-07-26)

### Token generation — the DATABASE mints them (`0040`)

This was a real defect on my side, now fixed. The app used to *derive* the token
it printed while the website *resolved* against `partner_referrals` — two
sources of truth, and a missing row produced exactly the silent failure you
described.

Now: tokens exist only as rows. `mint_partner_token(partner_id, channel,
campaign, expires_at)` generates a random 10-char token and inserts it.
`create_care_partner(...)` does both in one call, because forgetting the second
step *was* the bug. Both are `service_role` only — issuing a token is an
editorial act, and a doctor cannot issue their own.

The referral kit in the doctor app now reads the token from that table. **No
row → the kit says "no referral code has been issued yet" and prints nothing.**
A missing token is now visible instead of invisible.

### `care_partners.type` — the real list

```
doctor · hospital · clinic · diagnostic_lab · ivf_centre · nutritionist
lactation_consultant · psychologist · physiotherapist · corporate · insurance
```

**Organisations** (logo, square): `hospital`, `clinic`, `diagnostic_lab`,
`ivf_centre`, `corporate`, `insurance`. Everything else is a person (photo,
circle).

Note your current matching: `lab` and `ivf` are not real values — the actual
ones are `diagnostic_lab` and `ivf_centre`. `organisation` is not a type at all.

`type` is TEXT, not an enum, because new partner types must be addable without
an app release. So **an unknown type must not break the page** — fall back to
"person", which is what the app does.

### `trust` JSON — keys and labels

```json
{ "primary": "Invited by",
  "secondary": "Your care partner",
  "shortWelcome": "one line, shown on a card",
  "longWelcome": "a paragraph, shown once" }
```

Defaults when a key is missing: `primary` → `"Invited by"`,
`secondary` → `"Your care partner"`.

Your allowlist is **better than what I specified** — keep it. Add the two
defaults above if they are not already in it. `secondary` is worth rendering as
a small line under the name; `shortWelcome` in a quiet box below is a nice touch
and is what the app card does. `longWelcome` is app-only.

There is no fixed list of allowed labels in the app — it uses a blocklist and
fails closed to "Invited by". Since you enforce an allowlist, **tell me before
adding a new label** so both sides move together.

### Seed rows

`supabase/seed/care_partner_demo.sql`. Run it in the SQL editor (which runs as
service_role). It covers person-with-photo, organisation-with-logo,
no-image-initials, an **expired token**, an **inactive partner**, and one row
whose `trust.primary` is literally `"Sponsored by"` — that last one is the test
for your allowlist. `care_partners.trust` is a plain jsonb column with no CHECK
constraint, so the website is the only thing standing between that row and a
doctor's name under an advertising label.

The final `select` prints every token with a ready-made URL.

### Directus

Not set up at all yet — no collections, for any table. Adding a doctor today is
SQL: `select create_care_partner('cp_meera', 'Dr Meera Rao', 'doctor', ...)`.
Directus is deliberately deferred until the features settle; the requirement is
recorded in `docs/ADMIN-PANEL.md`.

### Unknown `ch` values — sanitise, do not reject

Your approach is right. The app parses `utm_term` against its enum and falls
back to `link` for anything it does not recognise — it never throws. So an
unknown channel is recorded as a generic link rather than lost, and the day we
add a channel the website does not need a deploy.

### `photo_url` / `logo_url`

Absolute `https://` URLs, and **treat them as untrusted** — always have an
initials fallback, never a broken image box. Hosting is undecided (Supabase
Storage is the likely answer); the demo seed uses public placeholder URLs.

### Package name

`com.parentveda.app` — final. Renamed from `com.example.parentveda`, which Play
rejects.

### Invite code format

**Exactly 7 characters** from `ABCDEFGHJKMNPQRSTUVWXYZ23456789` — the same
alphabet as care tokens, no I/L/O/0/1.

Your `4-12 A-Z0-9` is looser in both directions and will accept codes our
generator can never produce. Tighten it to 7 and this alphabet. (Length is the
only difference between the two systems' codes — which is exactly why
`utm_source` and not length must decide which system a referrer belongs to.)

### `assetlinks.json` and `APP_LIVE`

Both parked, both the right call. Send nothing until the app is uploaded — the
SHA-256 must come from Play App Signing, not a local keystore. And redirecting
to a 404 store listing would be worse than not redirecting.

---

## 9. Test tokens

Any 10 characters from the alphabet are well-formed, so the page can be built
and tested before a single real partner exists:

```
https://parentveda.in/care/KM7QX2PDVR          → generic page + store redirect
https://parentveda.in/care/KM7QX2PDVR?ch=whatsapp
https://parentveda.in/care/nope                → malformed, generic page
```

To test the named-doctor path, ask for a seeded row in `care_partners` +
`partner_referrals` — those tables have no write policy from the client, so the
row has to be inserted server-side.

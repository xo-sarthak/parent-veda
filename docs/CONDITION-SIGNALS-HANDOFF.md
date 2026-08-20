# Pregnancy condition signals × Ask Veda — handoff

**Written:** 2026-08-20
**For:** the terminal that owns `C:\Projects\parentveda-askveda`.
**App-side status:** built, analyzed clean, tests passing.
**Service-side status:** nothing done. **The app half is live but partly inert
until this lands** — see §3 for exactly which part.

---

## 0. The one-paragraph version

The app used to send Ask Veda five pregnancy conditions. It now sends up to
twelve. The seven new strings will start arriving in the `conditions` array of
the request body the moment a mother taps **"Add to my journey"** on one of
seven condition pages. **The service does not know them**, so today they arrive,
get logged as unrecognised, and change no answer.

Nothing breaks. That is the problem — this is the failure mode `CLAUDE.md`
already names: *"`timing_ownership` was sent for days and quietly discarded, so
the framing it existed to drive never ran."*

---

## 1. Before you propose an architecture

**Read `CLAUDE.md` at the repo root.** It states what this codebase actually
uses, and exists because incoming briefs keep assuming otherwise. The short
version:

> Flutter, **singleton `ChangeNotifier` stores**, **`Navigator` + named
> `RouteSettings`**, stage-first folders, `shared_preferences` local-first,
> Supabase through one repository class, no codegen.

Also relevant here: **behaviour rules live in versioned code, never in the
database or Directus.** Whatever you do with these strings, the mapping from a
condition to how an answer is framed is a rule, not content.

---

## 2. What changes on the wire

Nothing structural. `lib/services/veda_context.dart` has always sent:

```
conditions: [ "<label>", ... ]     // label.en, lower-cased
```

**The array is free text, not enum names.** That is why this is additive and why
no request-body version bump is needed — the shape is identical, the vocabulary
is wider.

### The five you already receive

```
gestational diabetes
low-lying placenta
anemia
thyroid
high blood pressure
```

(Plus `previous c-section` and `high-risk pregnancy`, which are asked in the
profile rather than declared from a condition page.)

### The seven that are new

| String on the wire | From condition page | Why it should change an answer |
|---|---|---|
| `pcos` | PCOS and pregnancy | Shifts nutrition and activity guidance; raises GDM watchfulness |
| `hyperemesis` | Hyperemesis | Rewrites **all** food and supplement advice — "eat small frequent meals" is not usable guidance for her |
| `icp / cholestasis` | ICP / cholestasis | Itching answers must route to LFT/bile acids, not to moisturiser. Delivery timing is clinician-owned |
| `iugr` | IUGR (baby growing slowly) | Growth, scan-frequency and movement-counting content becomes central |
| `rh negative` | Rh negative pregnancy | Anti-D timing; bleeding episodes carry a different instruction |
| `cervical incompetence` | Cervical incompetence | Activity, travel and exercise advice invert. Do not serve generic "stay active" content |
| `fibroids` | Fibroids in pregnancy | Pain episodes have a benign explanation worth naming before she panics |

⚠️ **`icp / cholestasis` contains a space-slash-space.** It is
`_same('ICP / cholestasis')` lower-cased. If your matcher tokenises on
punctuation, this is the one that will fail quietly.

⚠️ **These strings are the contract now.** They are `PregConditionX.label.en` in
`lib/services/family_profile.dart`, and that file's comment says so, but nothing
mechanically stops someone rewording a label. If you key on them, say so in a
comment there too — or key on a normalised form and accept both.

---

## 3. What is inert until you act

Precisely this: **a mother with any of the seven gets the same Ask Veda answer
she got before.** Everything else about the change is live and working —

- her tap is recorded,
- it reaches `FamilyProfileStore.pregConditions`,
- content ranking and `matchesSignal` already read that store,
- the string is already in the request body.

So this is not "a feature waiting to be switched on". It is a feature that works
everywhere except in the answer, which is the surface a mother is most likely to
judge it by.

---

## 4. What the service needs to do

1. **Recognise the seven strings** wherever the five are recognised today.
2. **Check corpus coverage.** Five of the seven have real clinical weight and
   thin coverage — hyperemesis, ICP, IUGR, cervical incompetence, Rh negative.
   If retrieval has nothing for them, recognising the string produces a
   confidently framed answer with no grounding, which is worse than ignoring it.
   **Ingest first, then recognise.**
3. **ICP needs a safety rule, not just content.** Itching in late pregnancy with
   no rash is the presenting symptom of a condition that is managed by delivery
   timing. If she declares ICP and asks about itching, the answer must not read
   as reassurance. The app already routes this way on its own itching page
   (`BsItchingScreen` → the ICP page); the answer should not contradict it.
4. **Cervical incompetence inverts generic advice.** Any "staying active in
   pregnancy" framing is wrong for her. This is the clearest case for a
   suppression rule rather than a boost.
5. **Log what you do not recognise** — you already do; please confirm these
   seven stop appearing in that log once done, since that is the only evidence
   available from this side.

---

## 5. What is deliberately NOT sent, and why you should not add it

`PregCondition` records **ongoing state, never an event.** The profile has no
expiry — nothing ever clears a value — so anything true for a season would be
true forever.

Refused on that ground: **ectopic, miscarriage** (losses — persisting either
would have the app addressing a woman about a pregnancy that ended),
**abruption, HELLP, vasa praevia** (acute, hospital-managed), **COVID, dengue,
UTI** (resolve), **breech** (a position; most babies turn), **polyhydramnios and
low amniotic fluid** (a measurement at a moment), **piles, varicose veins**
(symptoms, another bracket).

**Preeclampsia is parked, not refused.** It could map to `hypertension`, but
preeclampsia is raised BP *plus* proteinuria *plus* organ involvement, and
conflating them risks a subtly wrong answer on the most dangerous condition in
the library. It is on the clinical-review list. **Please do not map it
service-side either** — that would put the app and the service in disagreement
about her, with no way for either to know.

`test/conditions_personalisation_test.dart` fails the build if any of the above
gains a signal, so this list is enforced rather than merely written down.

---

## 6. If you want an expiring signal

That is the real fix for the refused list, and it is a two-repo change of its
own. The app would need a `{condition, declaredAt, expiresAt}` shape instead of
a `Set<PregCondition>`, and the service would need to treat an expired signal as
absent rather than as false. **Raise it before building it** — it changes the
persisted profile shape, which is the one thing in `FamilyProfileStore` that
cannot be changed silently.

---

## 7. Files to read on this side

| File | What it holds |
|---|---|
| `lib/services/family_profile.dart` | `PregCondition`, the labels that go over the wire, `isAskable`, and the state-vs-event rule |
| `lib/services/veda_context.dart` | Where `conditions` is built — line ~104 |
| `lib/data/conditions_data.dart` | The 27 condition pages and their `pregSignal` mapping |
| `test/conditions_personalisation_test.dart` | Every promise above, as assertions |

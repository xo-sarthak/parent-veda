---
name: parentveda-bilingual
description: >
  ParentVeda's two-language rules, kept as REFERENCE: English in Latin script,
  Hindi in Devanagari, and Hinglish (Hindi in Latin script) as a defect rather
  than a style. As of 2026-08-27 new copy is written in ENGLISH ONLY, so this
  is no longer a gate on ordinary work — do NOT load it just because a task
  touches user-facing strings. Load it only when the user explicitly asks for
  Hindi, when editing or auditing the Devanagari content that already ships, or
  when a question is specifically about script or localisation. Triggers on
  Hindi, Devanagari, Hinglish, translation, bilingual
  copy, localisation, the _t / _same / _en / _p helpers, LocalizedText,
  AppLanguage.hinglish, lang.isHindi, the hi-IN voice, the tool/hindi scanners,
  or any question about which script a word should take.
---

# ParentVeda is bilingual: English and Hindi

**English in Latin script. Hindi in Devanagari. Nothing else exists.**

There is no third option and no in-between. Specifically:

- **Hinglish — Hindi written in Latin script — is dead.** Dropped 2026-08-03,
  and as of 2026-08-12 removed from the entire Pregnancy stage. `Aapka sharir`,
  `Hafta 20`, `Samajh gaya` are not a style choice you may reach for; they are a
  defect. If you are writing Hindi, you are writing Devanagari.
- **Latin script inside a Hindi string is allowed only for words a mother reads
  in Latin anyway.** The line, stated precisely — a vaguer version of this rule
  ("clinical terms stay Latin") produced `Iron` and आयरन in the same file:
  * **Named compounds carrying a letter or number code stay Latin** — `Folate`,
    `Vitamin D`, `Omega-3`, `DHA`.
  * **Nutrients she says aloud go Devanagari** — **आयरन, कैल्शियम, प्रोटीन**.
    The content had already settled this: आयरन 41 uses vs `Iron` 9.
  * **Procedures and conditions named in English stay Latin** — `anomaly scan`,
    `NT scan`, `Braxton Hicks`, `gestational diabetes`.
  * **Brands** (`ParentVeda`, `WhatsApp`) and **named research terms introduced
    in quotes and then glossed** (`'co-regulation'`) stay Latin.
  * **Everything else, including everyday loanwords, takes Devanagari** —
    **स्क्रीन, फ़ोन, स्कैन, कॉर्टिसोल, प्लेसेंटा** — because the app narrates
    this text with the `hi-IN` voice, and that voice **cannot read Latin script
    at all**. Every Latin word is a word the narrator stumbles over.

  When this list and `tool/hindi/_HOUSE_RULES.md` disagree, **the shipped
  content is the tiebreaker**, not either document.
- **Where English still shows in the Hindi build, it is a debt, not a decision.**
  It means "Hindi owed", and it is expected to be translated. Mark it `_en(...)`
  so `grep -c '_en('` is the size of what is left. The only strings that are
  *finished* in English are the ones above, and those take **`_same(...)`**.
  Never `_t(x, x)` — an identical pair reads as completed work to every audit,
  which is how `can_i_data` was once reported done with 302 strings still
  English.

**The identifiers still say `hinglish`, and that is deliberate.**
`AppLanguage.hinglish` is the enum value and `_p`'s second parameter is named
`hinglish`. Grep for `hinglish`, not `hindi`. Prefer **`lang.isHindi`** in new
code — an alias for the same value that survives the coming rename. The enum
name is an IDENTITY: it is persisted in `shared_preferences` as the literal
string `hinglish`, so renaming it would strand every mother who has already
chosen Hindi. The user-facing label is a separate thing and already reads
**हिन्दी**.

**Only the Pregnancy stage is migrated.** TTC and Parenting still hold Hinglish
or no Hindi at all, on purpose. Do not "finish the job" there.

#### Finding Hinglish: it hides in shapes your grep does not know

Four scanners exist, and **each one declared the codebase clean while the next
found more**, because each knew only certain code shapes. Run all of them, and
assume a fifth shape exists:

| tool | shape it understands |
|---|---|
| `tool/hindi_audit.py` | `_t/_same/_en/LocalizedText` in `lib/data`, JSON `{en, hi}` bodies, and Dart outside `lib/data` |
| `tool/scan_live_hinglish.py` | `_t(en, hi)`, `LocalizedText(en:, hi:)` |
| `tool/scan_lang_ternaries.py` | any language condition as a ternary — **both polarities** (`isEnglish ? en : hi` vs `isHinglish ? hi : en`) and **both quote styles** |
| `tool/pairing_shapes.py` | separates "already paired in a shape the audit cannot parse" from genuinely bare |

The lessons behind that table, which cost real time:

- `_Word(0.0, 'Forming', 'बनना')` and `title:` beside `titleHi:` are *finished*
  translations in shapes no audit parsed — 348 strings reported as outstanding
  that were already done.
- A single-quote-only regex misses `"You're in week $week"`, because Dart
  switches to double quotes exactly when a string holds an apostrophe. The blind
  spot correlated with the warmest prose.
- **A phone found what four scanners missed.** Open the app and read the screen.

#### Two rules with teeth

⚠️ **The rule that this migration keeps breaking: `.en` is identity, `.now` is
display.** Once a field is `LocalizedText`, `.now` is the obvious suffix
everywhere and it is WRONG anywhere the value is persisted, compared, switched
on, used as a map key, or sent to an external system. Both sides are
`LocalizedText`, so the type system cannot tell them apart — it is a review
question. It has been got wrong eight times: a bookmark keyed on its own title,
`ragaTimeBadge` matching English hints, a `switch` dispatching to a game widget,
`SpiritualPrefsStore`, `toLabel == 'Postpartum'` (always false — that one is now
an analyzer *error*, see `analysis_options.yaml`), and a topic filter that
matched nothing in Hindi. None of them fail to compile; none fail a test; the
only symptom reaches the mother. `test/localized_identity_test.dart` guards the
store-key cases.

⚠️ **Dart placeholders are ASCII.** `$week` terminates at the first non-ASCII
character, so `$weekवें हफ़्ते` is `$week` + `वें` and is correct — Hindi ordinals
are built exactly this way. A validator written as `\$\w+` in Python matches
`$weekवें` as one placeholder, because Python's `\w` is Unicode-aware, and then
rejects correct Hindi. Use `tool/dart_placeholders.py`.

Three conventions worth knowing before writing a bilingual pair:

  | helper | means |
  |---|---|
  | `_t(en, hi)` | a real translation |
  | `_same(s)` | identical in both **by nature** — PCOS, IVF, a person's name |
  | `_en(s)` | **English for now, Hindi owed** — a greppable backlog |

  Never write `_t(x, x)`. An identical pair reads as finished work to anything
  counting pairs, which is how `can_i_data` was once reported done with 302
  strings still English.

- **`tool/hindi/_never_translate.tsv`** lists strings code *reads* rather than
  renders — `contains()` keywords, `stage:` values, RegExp sources, composed
  ids. They look exactly like copy. Add to it rather than rediscovering them.
- **A field that round-trips through JSON is not copy**, whatever it looks like.
  Community *posts* stay `String` for this reason: the same model carries what
  a mother typed herself, and there is no second language for that.

⚠️ When translating `_p(...)` strings, **the placeholders are the trap.** A
string that loses its `$n` or `$w` still compiles and still passes tests — it
just shows the mother the wrong number. Diff the placeholder set before and
after, and translate the plural branches (`n == 1 ? '1 entry' : '$n entries'`)
by hand.

The pre-migration Hinglish is kept verbatim in `lib/data/weekContent.hinglish.json`
— JSON cannot hold comments, so a sibling file is how *comment out, never delete*
applies to data.

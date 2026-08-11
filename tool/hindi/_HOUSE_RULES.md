# House rules for ParentVeda Hindi

The one brief every translation pass works from. If a rule here and a habit
disagree, the rule wins.

## The voice

Warm **spoken** Hindi in **Devanagari**. Not textbook Hindi, not news Hindi.
The register is a thoughtful older woman talking to a mother she likes —
unhurried, never lecturing, never clinical.

- **आप** for the mother, always. Never तू, never तुम.
- **Essence over literal.** The approved example: "what isn't in your hands"
  became **जो आपके हाथ में नहीं** — NOT जिस पर आपका पूरा नियंत्रण नहीं. If a
  literal rendering is stiff, the literal rendering is wrong.
- Prefer the everyday word to the Sanskritised one. **कोशिश** over प्रयास,
  **ज़रूरत** over आवश्यकता, **मुश्किल** over कठिन, **समझ** over बोध.
  Sanskrit is right for what is genuinely elevated (a शुभ thought, an affirmation);
  it is wrong for "your child is learning to sleep".
- Keep nuqta where speech has it — **ज़रूरी, ख़ुद, फ़र्क़, मुश्किल, क़रीब**.
- Contractions of speech are welcome: **हैं ना**, **बस**, **थोड़ा सा**.

## The baby has no gender

This content is read aloud to a mother who does not know, and must not be told,
her baby's sex. Beyond the law (PCPNDT), gendered copy simply excludes half the
readers.

- ❌ आपका बच्चा … देखता है / बनेगा  ← masculine agreement
- ✅ **आपका बच्चा … देखता है** is still masculine. Rewrite the sentence.
- Working strategies: plural agreement (**बच्चे देखते हैं**), the abstract
  (**बच्चों में यह आदत बनती है**), second person to the mother
  (**आप जो करती हैं, वही सीखा जाता है**), or a nominal construction
  (**सीखना नक़ल से होता है, कहने से नहीं**).
- The mother IS gendered — feminine agreement for her is correct and warm:
  **आप महसूस करती हैं**, **आपने देखा होगा**.

## What stays in Latin script

Judgement call, and the test is: **would she read this word off a bottle, a
prescription, or a report?** If yes, Latin.

- Latin: `Folate`, `Vitamin D`, `Omega-3`, `Iron`, `Calcium`, `anomaly scan`,
  `NT scan`, `Braxton Hicks`, `screen time`, brand and product names, and
  research terms she would meet in English (`serve and return`).
- Devanagari: everyday words — **पालक, दाल, नींद, थकान, दूध, खेल, कहानी**.
- A whole English phrase inside Hindi prose is usually a failure to translate.
  `Developmental research` → **बाल-विकास पर हुए शोध**. But keep a term Latin when
  the Hindi would be an invention nobody says.

## Mechanical parity — these break silently

A string that loses one of these still compiles, still passes tests, and shows
the mother something wrong.

1. **Placeholders.** `$n`, `$w`, `{name}`, `%s` — the same set must appear in
   the Hindi, spelled identically. Count them before and after.
2. **`\n`** — the TSV encodes newlines as a literal backslash-n. Keep every one,
   in the same place. It is a paragraph break on screen.
3. **Never a tab** inside a cell — it is the column separator.
4. **Numbers and units** carry over exactly: `20 minutes` → `20 मिनट`, not
   "बीस मिनट" and never a different number.
5. **One row in, one row out.** Same order, same count, same first column.

## Never

- Latin-script Hinglish. "Aapka bachcha" is the old house style, dropped
  2026-08-03, and it is what this pass exists to remove. It also breaks voice:
  the app asks the OS for the `hi-IN` voice, and a Hindi voice cannot read
  Roman script.
- A diagnosis, a promise, or a personalised probability.
- Contradicting a doctor. Where a clinician owns a decision we explain, remind
  or help her prepare — never recreate or reinterpret.
- Copying the English into the Hindi column to "fill" it. An identical pair
  reads as finished work to anything counting pairs. Leave it blank instead.

# Door 9: Early learning, the new copy (EL1, EL3 to EL6, EL8)

Written 2026-10-25. This goes into `pp_early_learning_content.dart` at build. The house rules are the section's own:
- Never a worksheet, and no target to hit.
- What's already in the house comes first. Buying is optional.
- English only. The one exception: Hindi rhyme lyrics in English letters (EL3, the user's call).
- No emoji.
- Developmental, legal and screen lines are REQUIRED_REVIEW, read by a developmental paediatrician or an early-years specialist. The admission rules are checked against current state notices before release.

---

## 1. "Help him talk", the first card for 1–3 years (EL1)
**Card:** "Help him talk" with "Five minutes a day that make the biggest difference".
**It opens `skills_language`.** That page's band tag moves to 1 year and up, and the page gains this step group at the top. REQUIRED_REVIEW.
- **Talk about what he's looking at:** "Ball. Red ball. You threw the red ball." Short, and about now.
- **Add one word:** if he says "car", you say "big car" or "car going".
- **Wait.** Count to five in your head after a question. Children need time to answer.
- **Any language is fine.** Speak the one you think and feel in. Two languages don't cause late talking.
- **Turn the TV off in the background.** Children hear far fewer words when a screen is on, even if nobody is watching it.

**Links:**
- "Speech by age, and when to check" → Development `dev_speech_by_age`
- "Two languages at home" → Development `dev_two_languages`

## 2. Rhymes, written out (EL3), replacing the empty `rhymes_collection`
Title: "Rhymes to say together". Format: CARDS. One card per rhyme: the words, the actions, and what it helps.

**Intro.** Rhymes are the easiest way to help a small child talk. The beat, the repetition and the actions make words stick. Sing them badly; he won't mind.

**English (traditional, out of copyright):**

| Rhyme | Actions | Helps with |
|---|---|---|
| Twinkle, twinkle, little star | open and close your hands | slow, clear sounds |
| Baa, baa, black sheep | hold up three fingers for "three bags full" | counting |
| Row, row, row your boat | sit face to face, hold hands and rock | rhythm, taking turns |
| Incy wincy spider | fingers climb up, then rain comes down | fine motor, a story arc |
| Head, shoulders, knees and toes | touch each one, getting faster | body words |
| Pat-a-cake | clap together, then roll and mark | coordination |

**Hindi, in English letters (traditional folk rhymes only):**
- **"Machli jal ki rani hai"**
  - Words: "Machli jal ki rani hai, jeevan uska paani hai. Haath lagao darr jaayegi, bahar nikalo mar jaayegi."
  - Meaning: the fish is queen of the water, and water is her life.
  - Actions: hands swim like a fish.
- **"Aloo kachaloo beta kahan gaye the"**
  - Words: "Aloo kachaloo beta kahan gaye the? Baingan ki tokri mein so rahe the. Baingan ne laat maari, ro rahe the. Mummy ne pyaar kiya, hans rahe the."
  - Meaning: little potato slept in the brinjal basket, cried when kicked, and laughed when Mummy cuddled him.
  - Actions: sleep, cry, then laugh faces.
- **"Hathi raja kahan chale"**
  - Words: "Hathi raja kahan chale? Soond hila kar kahan chale? Mere ghar bhi aao na, halwa puri khao na."
  - Meaning: where are you going, king elephant? Come to my house for halwa puri.
  - Actions: an arm swings like a trunk.
- **"Ek do teen chaar"**
  - Words: a counting rhyme, said with fingers.
  - It helps with numbers.
  - Check the exact folk words at build.

**Left out on purpose:** "Lakdi ki kaathi", "Nani teri morni" and "Chanda mama door ke". They're film songs, still under copyright.

**At build:**
- REQUIRED_REVIEW for the lyrics and that each rhyme is out of copyright.
- The audio row shows the S8a message below until recordings exist.

## 3. The story audio message (EL3, S8a)
A tap on "Listen to this story" shows: "This story is still being recorded. You can read it aloud now; it works even better in your voice."

## 4. New page: "What most children can do at 3, 4 and 5" (EL4)
Area: `early_skills` (Before letters and numbers). Bands: 2–3, 3–4 and 4–6. Format: CARDS. REQUIRED_REVIEW.

**Intro.** These are wide ranges, not a test. Children get to each one at their own pace, and being early or late on one doesn't predict school.

| | Around 3 | Around 4 | Around 5 |
|---|---|---|---|
| Talking | 3-word sentences; strangers understand some | tells a simple story; asks "why" a lot | talks clearly; uses "because" and "if" |
| Drawing | copies a circle; scribbles with control | draws a person with a head and a few parts | draws a person with a body; copies a triangle |
| Letters | enjoys books; may know a letter or two | may write a few letters, often his name's | may write his name; knows some letter sounds |
| Counting | counts 1 to 3 objects | counts about 10 | counts 10 or more; knows "more" and "less" |
| Colours | names a few | names most common colours | names colours and shapes |

**The line under it:** "Reading at 5 is not expected. Loving books is. Most children begin to read at 6 or 7."

**When to check:** if he's losing words or skills he had, or isn't speaking in sentences by 3, talk to your doctor. This is a doctor callout.

**Links:**
- "His milestones" → `pp_milestones`
- "Speech by age" → Development `dev_speech_by_age`

## 5. New page: "Nursery admission, step by step" (EL5)
Area: `school` (Starting school). Bands: 2–3, 3–4 and 4–6. Format: STEPS. REQUIRED_REVIEW (legal; state rules checked before release).
1. **Check the age cut-off for your state and board.** Many cities take nursery at 3 years by a set date, often 31 March. Class 1 is now usually 6 years. The rules change, so check the school's own notice.
2. **Know when forms open.** In many cities nursery forms open between October and January for the session starting in April.
3. **Keep these ready:**
   - his birth certificate
   - his Aadhaar, if he has one
   - your address proof
   - passport photos
   - his vaccination card, which some schools ask for

   Link: "Papers for your child" → the Papers door.
4. **Free seats in private schools (RTE).** Under the Right to Education Act, private unaided schools keep 25% of entry-class seats for children from economically weaker and disadvantaged families, free. Applications usually go through the state's online portal, by lottery.
5. **No test, no interview.** The RTE Act bars schools from screening children or parents for admission to these seats. Many states apply it to all nursery admissions. A school that "interviews" your 3-year-old is worth asking about.
6. **Anganwadi is free, and it counts.** Your local anganwadi runs free preschool, and nutrition and health checks, from age 3.

**Closing line:** "The right preschool is near home, kind, and full of play. You don't need the most famous one."

## 6. YouTube, cartoons and "learning apps", a new part of `hab_screens` (EL6)
REQUIRED_REVIEW. Ranges from WHO 2019.
- **Under 2:** no screen time, apart from video calls with family.
- **From 2 to 5:** up to an hour a day, and less is better.
- **"Learning" apps and videos:** small children learn words far better from a person than a screen, even a good one. Use them as a treat, not a teacher.
- **What makes screen time better:**
  - watch with him, and talk about it
  - the same few shows rather than endless autoplay
  - turn off autoplay on YouTube
  - YouTube Kids with a timer
- **Not at meals, and not in the hour before bed.**

**Links:**
- "How much is too much" → Behaviour `beh_screen_limits`
- "Ending it without a meltdown" → Behaviour `beh_screen_ending`

## 7. Thin stories, written out (EL8)
- **`st_bed_moon_follows`, "The moon that followed us home"**
  - New middle: the moon peeks between buildings at a red light and waits behind the temple tower, so the "walking home" repeats three times. Repetition is what a 2-year-old loves.
  - New ending line: "Goodnight, moon. Thank you for walking me home."
- **`st_pan_donkey_tiger_skin`, the donkey in the tiger's skin**
  - The story is told in full: the washerman's idea, the fields, the donkey's bray that gives it away.
  - The gentle idea is kept: "Being yourself is safer than pretending."
- **Titles:** "another deer's place" and "The king's cats" get their apostrophes. The old titles are commented out.

## 8. Tags and links (EL2, EL6)

| What | From | To |
|---|---|---|
| Panchatantra, world tales | 2 years | 3 years |
| Jataka, Birbal, Tenali | 2 or 3 years | 4 years |
| Bedtime tales | 1–4 years | 1–5 years |
| `school_choosing` | 3 years | 2 years |
| `skills_language` | effectively 2 years (area) | 1 year (the page lives in an area from 2, so the card in EL1 carries it) |
| `hab_bedtime` → Sleep | whole section | `bedtime_routine` |
| `school_first_day` → Behaviour | whole section | `separation` |
| School pages → Potty | none | `school_and_public` |
| `hab_sharing` ↔ Behaviour | none | `sharing` |
| `hab_truth` ↔ Behaviour | none | `beh_older_lying` |
| `hab_brushing` ↔ Health | none | `teeth_brushing` |

## Sources (REQUIRED_REVIEW at build)
- CDC "Learn the Signs. Act Early." milestones (2022), and IAP developmental guidance.
- WHO, "Guidelines on physical activity, sedentary behaviour and sleep for children under 5" (2019).
- Right of Children to Free and Compulsory Education Act, 2009: Section 12(1)(c) (25% seats) and Section 13 (no screening, no capitation fee).
- Ministry of Education guidance on Class 1 entry age (NEP 2020, age 6), and the state nursery admission notices.
- ICDS anganwadi preschool education (Ministry of Women and Child Development).
- Research on bilingual language development and on background TV and language exposure.

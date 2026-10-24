# Door 8: Behaviour, the plan

Written 2026-10-25. **Status: final. BH1 to BH8 answered yes by the user 2026-10-25.** The recommendations were then checked against what parents actually search (below), and BH1, BH5 and BH7 were adjusted to match. The new copy is in `08-behaviour-content.md`. Nothing in `lib/` changes until step 0 (S1 to S11) and the user's go.

## Context
**Where it lives.**
- The door: `lib/data/doors/pp_door_behaviour.dart`
- The content: `pp_behaviour_content.dart`, `pp_behaviour_bands.dart` and `pp_behaviour_more.dart`. That is 11 areas and 56 pages, warm and clear about where we stand (no hitting, warm and firm).

**Tabs:** Crying, the first year · Tantrums · He keeps doing this · Scared, shy or clingy · Calm and guidance.

**Ages:** 0–12m, 1–2y, 2–3y, 3–6y (`pp_age_bands.dart:125`).

**Kept on purpose:**
- no red-flag tab; the warnings sit on the page they belong to (26 doctor or safety callouts on 25 pages)
- the never-shake walk-through on "When the crying is too much"
- the "What to say" tool opens on his age

**What a parent meets today:**
1. **Nothing to do right now, first.**
   - Every age 1–6 opens on Tantrums.
   - A 4-year-old's parent starts on "the stubborn child". The pages for 3–6 (not listening, anger, lying) are on other tabs, further in.
   - There's no "right now" row on any tab.
2. **At 0–12 months, four tabs are locked** ("From 1 year"), and three of their names are cut off with dots. S9 opens them as "For later".
   - The door's own comment says these tabs are hidden, which is wrong (`:17`).
3. **The infant "What to say" card promises lines for the family** ("you are spoiling him", "let him cry"). None exist. A baby's parent gets one script, about throwing food.
   - "Read the whole thing" never appears in the tool, because the router doesn't pass `onOpenPage` (`pp_surface_router.dart:447`).
   - The empty search still says "browse by age above", but those age buttons are gone.
4. **Pages tagged wrong, missing or doubled:**
   - comfort objects and eating mud have no age
   - "Hitting, biting" says 3–6, but at that age it only shows under "Earlier"
   - "Everyday phrases that hurt" is written but has no way in (`:1313`)
   - at 3–6, "Listening and cooperation" shows twice
5. **Help:**
   - The closing "Talk to a child psychologist" lands on "Our first experts are joining".
   - Two consult cards open the full expert list, not the right specialist.
   - **There's no Tele-MANAS or parent-stress line anywhere**, though the door talks about shouting and hitting.
6. **Nothing linked:**
   - 0 books, though 8 matching parenting book summaries exist (Good Inside, No Drama Discipline, How to Talk…, Positive Discipline, No Bad Kids, Whole Brain Child, Punishment-Free Parenting, Tiny Humans Big Emotions).
   - 0 picture books to read with him, though the library has feelings, worry and new-sibling ones.
   - 0 courses, because no behaviour course exists.
   - 0 products, and the shop has none that fit (no feelings cards, no timers).
7. **Links that land in the wrong place:**
   - two "Sleep door" links open the sleep journey screen
   - the six links to "What to say" open the whole tool, never one script
   - signposts that exist but aren't linked: sibling jealousy (Family), speech flags (Development), autism signs (Special care), "When the anger is yours" (You, Maa `mind_rage`)
8. **India gaps:**
   - guests, weddings and festivals: 1 mention
   - the phone at mealtimes: 2 mentions
   - nothing for a parent after she has shouted
9. **Thin pages** (under about 700 characters): comfort object, nail-biting, fear of dogs, feelings check-in, eating mud, calm jar.
10. **Films:** 15 placeholders that don't respond to a tap, and no intro film.
11. **Names:** all five tab names fit two lines at the card width, including at a large text size (S11), so none needs a rename.

## What parents actually ask (the user, 2026-10-25: base the recommendations on what people want)
From `research/questions/ranked_parenting.csv` (3,470 parenting question clusters from Google and DuckDuckGo autocomplete, Parentune and Reddit), behaviour topics by search hits:

| Topic | Hits | Top questions | What it changed |
|---|---|---|---|
| Baby crying, colic | 654 | what gives babies colic; when does colic stop | **"colic" appears 0 times in Behaviour.** BH7 names it |
| Hitting, biting | 616 | how to deal with toddler hitting; is it normal for toddlers to hit | "He hits" is in the 1–2 and 2–3 rows (BH1) |
| Tantrums | 571 | how to handle; **when do they stop**; why | No page says when tantrums ease. BH7 adds it |
| Screens | 493 | how much screen time; how to limit it | The 3–6 tab order and the phone-at-meals part |
| "Normal behaviour at two" | 327 | what is normal behavior for a two year old | The Right now row and the first page at 2–3 |
| Speech, autism worry | 163 | why is my 3 year old not talking yet | The BH6 signposts |
| Not listening | 117 | why is my 4 year old not listening | 3–6 opens on He keeps doing this, with Not listening first |
| Separation, lying, siblings, fear | 26–36 each | — | Kept as they are |
| Guests, weddings, festivals | 15 | — | **Weak.** No new page; it goes in as a part of the public-tantrum page |
| Books | 0 | — | Nobody searches for them. BH5 is kept as a cheap extra on pages, never a row |

## BH1. Each age opens on what fits, with a "Right now" row first
**Tab order by age** (S1 tab order):

| Age | Order |
|---|---|
| 0–12 months | Crying, then the other four last, "For later. This usually starts from 1 year." |
| 1–2 years | Tantrums, Calm, Scared, He keeps |
| 2–3 years | Tantrums, He keeps, Calm, Scared |
| 3–6 years | He keeps doing this (not listening, anger, screens: the most-searched worries at this age), Calm and guidance, Tantrums, Scared |

**A "Right now" row, first on the opening tab.** It uses the approved shelf look, with nothing to tick:

| Age | Cards |
|---|---|
| 0–12 months | Colic, or normal crying? · Won't settle · When it's too much · You can't spoil him · What to say |
| 1–2 years | Tantrum steps · He hit someone · Cries when I leave · Two choices · What to say |
| 2–3 years | Tantrum steps · He hits · No to everything · Screens off · What to say |
| 3–6 years | Not listening · Anger · Screen limits · Calm corner · What to say |

## BH2. "What to say" keeps its promise
- **Four new scripts for the family, for 0–12 months:**
  - "You're spoiling him"
  - "Let him cry, it's good for his lungs"
  - "Your milk isn't enough, that's why he cries"
  - "Give him a little honey or gripe water"

  The honey script is a safety line: no honey before 1. It is REQUIRED_REVIEW.
- **"Read the whole thing" works:** the router passes `onOpenPage`, and the four scripts with no page get one.
- **The empty search says** "Nothing for that yet. Try 'hitting' or 'bedtime'."
- **The six page links open the exact script** (`pp_scripts/<id>`).

## BH3. Ages and loose pages tidied
- comfort objects and eating mud are tagged for 1 year and up.
- "Hitting, biting" goes back to 1–3. The 3–6 anger page links to it.
- "Everyday phrases that hurt" moves into Guiding without hitting, so it finally has a way in.
- The duplicate "Listening and cooperation" card goes. The commented-out copy is kept for revert.
- The door's comment is corrected (tabs say "For later", 11 areas), and so is DOOR-CONTENT-OWED (the Scared pages are written).

## BH4. Help next to the worry, and help for her
- **An expert card on He keeps doing this,** below the first row: "Nothing working? A child psychologist".
  - The experts aren't live yet, so a tap opens the existing "experts joining" page (S8e).
  - The closing card stays.
- **The two consult cards open the right specialist:** crying → paediatrician, siblings → child psychologist.
- **"When it's too much for you"** on "When the crying is too much" and "Why hitting doesn't do…":
  - "Free, any hour: Tele-MANAS, 14416"
  - a link to You, Maa's "When the anger is yours"
  - It's never stacked with that page's own warning (rule c). REQUIRED_REVIEW.

## BH5. Books next to the page they help
One per page, never on a page with a warning.

**For her, the book summaries we already have:**

| Page | Book |
|---|---|
| first_tantrums | No Bad Kids |
| beh_big_feelings | Good Inside |
| beh_consequences | No Drama Discipline |
| beh_not_listening | How to Talk So Kids Will Listen |
| beh_timeouts | Positive Discipline |
| beh_elders | Punishment-Free Parenting |
| beh_anger | The Whole-Brain Child |

**To read with him, picture books from the kids library:**

| Page | Picture books |
|---|---|
| beh_scared_everything | worry books |
| siblings | new-baby books |
| beh_name_the_feeling | feelings books |

**At build:** if no route opens one book summary by its id, add `pp_book/<id>` through the existing reader. Book summaries are free to read.

**Not linked, and owed instead:**
- no behaviour class exists, so I won't make one up
- the shop has no calm-down items, which goes to the shop list

## BH6. Links that land on the right page
- **Sleep:** "Sleep door" opens the Sleep door at the night-fears or settling page, not the journey screen.
- **New signposts:**

  | From | To |
  |---|---|
  | siblings | Family `fam_sibling_jealousy` |
  | beh_ziddi ("no words by two") | Development `dev_speech_flags` |
  | head-banging, eating mud | Special care `dev_autism_signs` |
  | screens pages | the other screen pages |

  All of these use M4 `pageId`.

## BH7. Content (copy in `08-behaviour-content.md`; clinical lines REQUIRED_REVIEW)
**New pages:**
- **"After you've shouted."**
  - repair in three lines
  - why one bad evening doesn't undo him
  - when to get help (links BH4)

**Additions:**
- **Colic is named** on `crying_normal`: what parents and doctors mean by it, the "rule of threes", and that it usually eases by 3 to 4 months. That page's title on cards becomes "Colic, or normal crying?".
- **When tantrums ease** on `first_tantrums`: they peak between about 18 months and 3 years and fade as words grow, mostly by 4 or 5.
- **Guests, weddings and festivals** go in as a part of `beh_tantrum_public` (weak search demand, so not a page of its own).
- "When everyone in the house has a phone" gets a part on the phone at mealtimes.
- The six thin pages are written out.

## BH8. Films
- The 15 slots stay, and the intro `behaviour/door_intro` is added.
- Until each film exists, a tap says "This film is still being made" (S8a).

## Taps that can't happen yet (S8)

| Target | What she sees |
|---|---|
| 15 films and the intro | "being made" |
| Child psychologist (card and closing) | the "experts joining" page |
| Tele-MANAS | shows the number to copy; a call link may do nothing on some phones |

## Build order (after step 0 with S9–S11, and your go)
1. Tags and loose pages
2. Tab order and the Right now row
3. The What to say fixes
4. Help and Tele-MANAS
5. Books
6. Links
7. Content
8. Films

**Reuse:**
- the D2 shelf
- the S1 tab order
- `PpDoorTab.expert`
- M4 `PpLink.pageId`
- `pvToast` and S8a–e
- `ScriptsLibraryScreen(onOpenPage:)`
- the Reading shelf's book reader and `kids_books_list.dart`

## Verification
- **`test/pp_behaviour_door_test.dart`:**
  - the opening tab and first card at each age
  - at 0–12m, the toddler tabs are open, last and "For later"
  - no page is unreachable
  - no duplicate card
  - no book on a page with a warning
- **Scripts:**
  - every script is reachable
  - infant scripts ≥ 5
  - `onOpenPage` is wired at the router (grep the call site)
- `door_names_fit_test`
- `pp_doors_first_view_test`
- `flutter analyze` on touched files
- phone walk only on your word

## Decisions
These questions stay here on purpose (the user, 2026-10-25). When a problem turns up later, check this table first: if an answer already covers it, the fix follows that answer, with no new round of questions.

| # | Question | We recommended, and why (what parents want) | Your answer |
|---|---|---|---|
| BH1 | Each age opens on what fits (4- and 5-year-olds on He keeps doing this), with a "Right now" row first | Yes. Crying, hitting, tantrums and screens are the four most-searched worries, and each one is now one tap from the door | **Yes** (2026-10-25) |
| BH2 | Write the family scripts the baby tab promises; make "read the whole thing" work | Yes. The card promises them now; parents ask how to tell a mother-in-law "you can't spoil a newborn" | **Yes** (2026-10-25) |
| BH3 | Fix wrong ages, the hidden page and the doubled card | Yes. These are bugs; they show the wrong pages at the wrong age | **Yes** (2026-10-25) |
| BH4 | Expert card on He keeps doing this; Tele-MANAS and "when the anger is yours" for her | Yes. "Nothing works" is the point where a parent needs a person; the free line costs nothing | **Yes** (2026-10-25) |
| BH5 | Link the book summaries and picture books we have, one per page | Yes, as a small extra. Nobody searches for books, so they sit at the foot of a page, never in a row | **Yes** (2026-10-25) |
| BH6 | Links land on the exact page; signposts to siblings, speech and autism signs | Yes. "Why is my 3 year old not talking yet" and autism worries are 163 searches | **Yes** (2026-10-25) |
| BH7 | Name colic, say when tantrums ease, "After you've shouted", phone at meals, fill thin pages; guests as a part of a page, not a page | Yes. Colic (654) and "when do tantrums stop" are top searches the door doesn't answer | **Yes** (2026-10-25) |
| BH8 | A door intro film | Yes | **Yes** (2026-10-25) |

The user, 2026-10-25: "I would say all yes, but what you recommend all yes? Just make sure your recommendation is based upon what people are actually wanting out of those sections and what will benefit them ... do keep those questions that you asked ... so that whenever we find an issue then maybe that would be covered in one of those questions answers so it can be fixed quickly."

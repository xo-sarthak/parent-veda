# Door 8: Behaviour, the plan

**Built elsewhere (2026-10-26):** BH2's tool side (the four family scripts, "Read the whole thing", the pages for the three scripts without one, the empty-search line, `pp_scripts/<id>` and the six page links) was built in the tools pass, `docs/pp-tool-plans/29-33-other.md`. This door's build does only the door-side work.

Written 2026-10-25. **Status: built 2026-10-26 (§12, As built).** **BH1 to BH8 answered yes by the user 2026-10-25.** The recommendations were then checked against what parents actually search (below), and BH1, BH5 and BH7 were adjusted to match. The new copy is in `08-behaviour-content.md`. Nothing in `lib/` changes until step 0 (S1 to S11) and the user's go.

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

## 12. As built (2026-10-26)
Held by `test/pp_behaviour_door_test.dart` ("door 8: the plan, held", 11 tests, and "door 8: on screen", 2; 26 in the file): the tab order for every band, the Right now cards for each band exactly (pages in band, What to say opening the tool), the row on the opening tab and nowhere else, the family scripts the baby's tab promises and every script link landing, the fixed ages and that no page sits outside its own area's ages, the psychologist row and each consult's specialist, Tele-MANAS from the one constant and never next to a page's warning, the nine book links exactly (one a page, none on a page with a warning, a typo opens nothing), every link landing on its page, the colic, tantrum, functions and phone-at-meals parts, the new page, the six thin pages past 700 characters, the dog-bite doctor line, the review marks, the fifteen film slots, and the first view at 4, 18, 30 and 48 months (the opening tab, the row, each card once, the tool not drawn twice). The parenting stage, 129 files, 1,383 tests, passes.

**BH2's tool side was built in the tools pass** (`docs/pp-tool-plans/29-33-other.md`, committed a224492): the four family scripts, "Read the whole thing", pages for the three scripts without one, the empty-search line, `pp_scripts/<id>` and the six page links. This build holds that the door's promise is kept (BH2 test) and does the door side.

**The shell, new for this door and open to every door:**
- `PpBehRightNowShelf` (`doors/pp_door_inline_tools.dart`), the fifth inline tool, on the same `_ShelfCard` as Tonight, Play today and the two Try this today rows. Its cards are data in the door file (`kPpBehRightNowCards`): a page by id, or a surface (What to say). `ppDoorInlinePageIds` returns the row's pages, so the Crying tab's rail does not draw the colic page twice.
- `ppDoorInlineSurfaceIds` and the door screen's `_onInlineRow`: a tool the inline row already opens is not drawn as a tool row on the same tab. What to say is the last Right now card and also a tool on Crying and Tantrums; the first view test caught the two cards a thumb apart. On the same tab for another age (no row), the tool row is back, and it never drops to a band block at the foot.
- The router: `pp_book/<shelf id>` opens one book summary in the Reading shelf's own reader (which hands a book to its companion), and an unknown id is null; `pp_books/Worry` and `pp_books/New sibling` name two essential titles from the kids list by its goal (`_bookPairForGoal`), in the Potty notice's words.

**A mechanism worth keeping.** `readArticleById` falls back to the first article for an id it does not know, which is right for the reader (it must always open something) and wrong for a link: `pp_book/book_the_whole_brain_child` would have opened an unrelated article with no error. The book's shelf id is `book_whole_brain` (a pregnancy-shelf id kept so saved progress carries over), and the route found it only because it checks `kBookDocsByShelfId` first and returns null otherwise, which the link gates fail on. The general point: a lookup that never fails is safe for a screen and unsafe for a link, so a route in front of it has to do the failing.

**A second one, about tags.** In this section an untagged page reads as every band. Comfort objects and eating mud were untagged, so a three-month-old's parent could reach a page that says "no soft toys in the cot under a year". "Hitting, biting" was tagged three to six inside an area that is one to three, so at three it showed only under "Earlier". The test now holds both directions for every page: tagged, and never outside its own area's ages.

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| BH4: "When it's too much for you" as a card on `crying_too_much` "after the steps" | A step of its step-through, after "Call someone before you go back in", two steps before never-shake; no "When the anger is yours" link there | The page is its one interactive block (an existing test: "a carousel or interactive page is only its block"). Next to the call it widens is where a parent at 2am needs it. The anger link is on `beh_no_hitting` and the new page |
| BH4: the two consult cards "open the right specialist" | Already true: the crying consult opens paediatricians and the siblings one child psychologists. Held by the BH4 test | Feeding's build fixed `ppPageAsRead` to read `PpConsult.surface` (01-feeding.md §12); the audit predates it |
| BH4: the closing card "stays" | It stays on every tab but He keeps doing this, where the psychologist row replaces it | The shell rule from Feeding D2: a tab with an expert row ends on the doctor sentence, so it never pitches twice |
| BH5: picture books "from the kids library" for worries, new baby and feelings | Worries and new baby; no feelings link | The list's one feelings-goal entry is a placeholder title ("Emotions Candidate Book 203"). Owed BHO3 |
| BH5: "if no route opens one book summary, add `pp_book/<id>`" | Added; seven books link | The Reading shelf had no single-book route |
| BH5: "never on a page with a warning" | Not on a page that is flagged, pinned or carries a safety callout. Four of the plan's pages carry an ordinary "When to ask" doctor line, and keep their book | The plan's own table puts books on them; a doctor line is on almost every page and is not a warning |
| BH6: "Sleep door opens the Sleep door at the night-fears or settling page" | Both infant links open `gentle_settling`; the fear-of-the-dark page already opened `night_fears` | The two links were on crying and settling pages |
| BH6: signposts | Also the stubborn page to `dev_speech_flags` | Its doctor line names "no words at all by around two" |
| BH7: functions as "a step group" | An article (the intro) and five steps, no heading on the steps | The intro is the reframe ("too much at once"), worth keeping |
| BH7: "After you've shouted", when to get help "See above" | Its own help line, with Tele-MANAS from the constant and a doctor or counsellor named | `pp_section_test`: a page with a doctor line names someone to go to |
| BH7: phone at meals links "Feeding's fussy-eating page" | `picky_battles`, "Mealtime battles" | The page that answers the fight at meals |
| BH7: dog bite "in a doctor callout" | A doctor callout titled "If any dog bites or scratches your child" | As written; the page had no doctor line before |
| BH3: "the duplicate Listening and cooperation card goes" | `beh_cooperation` commented out, kept for revert | As planned; the listening page is first on He keeps doing this from three |
| BH3: "Everyday phrases that hurt" into Guiding without hitting | A const of its own (`_wordsThatHurt`), on `_discipline`, assembled in the content file like `_olderChild`; tagged one to six | The page lives in the content file and `kBehDiscipline` is const in the bands file; the dissolved area still names it, for revert |
| BH1: "the other four last, For later" at 0 to 12 months | As planned; the shell (S9) does it | — |
| BH8: door intro `behaviour/door_intro` | Not slotted | S4: no chip until a film exists. Owed BHO1 |
| S11: "all five tab names fit" | "Scared, shy or clingy" is "Shy and clingy" (the old name commented out, kept for revert) | It took three lines at 1.3, found by SL9's measured check after this plan was written. The user's word, 2026-10-26; off `_kOwedShorterNames` |
| Verification: a Mobbin check | Not run | The row is the approved D2 shelf look, reused, as Sleep's was |

**Owed, not in this build:** the films (`DOOR-CONTENT-OWED` BH15, BHO1), the card paintings (BHO2), a feelings picture book in the list (BHO3), a books screen (BHO4), calm-down items on the shop (BHO5), a behaviour class (BHO6), a real child psychologist (BHO7); and a child psychologist's and a paediatrician's read of every `REQUIRED_REVIEW` line. **Owed to `BEFORE-LAUNCH.md`, not written there because the file holds another terminal's uncommitted line (migration 0116):** the clinical read of Behaviour's new and changed lines: the colic part (paediatrician, against Health's `tummy_colic`), when tantrums ease, the functions part, the phone at meals, "After you've shouted", Tele-MANAS on three pages (and its number, `kCrisisHelplineNumber`, REQUIRED_TO_CONFIRM), the dog-bite and rabies line, pica and iron, nail-biting and hair-pulling. The new page and the new parts reach Ask Veda through the incremental ingest, which the user runs.

**Fixed after review (2026-10-26, three things the door 8 review found):**
- **The book route could open the wrong book.** Its guard checked `kBookDocsByShelfId` (every book companion), while `readArticleById` searches `readCatalog`, which leaves out the pregnancy books, so `pp_book/book_expecting_better` passed the guard and opened the first article. The guard now reads `readCatalog`. The test checks the opened book's id for every parenting book and that a pregnancy book id opens nothing; it failed on the old guard. The general point: a guard has to check the same list the lookup reads, or it can pass while the lookup falls back. (This corrects the "mechanism worth keeping" above, which held only for ids that are no book at all.)
- **On "After you've shouted", the helpline sat inside the doctor box**, against BH4 rule c. It is its own "When it's too much for you" card now, as on `beh_no_hitting`. The test reads each callout on its own instead of the page's callout text joined, which is how it missed this.
- **A card with neither a page nor a surface would crash** the shelf (`pageId!`, `surfaceId!`). `PpBehRightNowCard` and Sleep's `PpSleepTonightCard`, which had the same trap, now assert one or the other.

# Door 9: Early learning, the plan

**Built elsewhere (2026-10-26):** EL7's tool side ("Toys and crayons", one toy shelf of the six kinds, the tiffin shelf and first shoes guide instead of "Bags, boxes, bottles and shoes", and "Picture books by age") was built in the tools pass, `docs/pp-tool-plans/29-33-other.md`. This door's build does only the door-side work.

Written 2026-10-25. **Status: final. EL1 to EL9 are all yes (the user, 2026-10-25).** The user's call: obvious recommendations need no question. I choose them, write the choice down here, and ask only what is genuinely the user's. The one real question was EL3's script for Hindi rhymes. The new copy is in `09-early-learning-content.md`. Nothing in `lib/` changes until step 0 (S1 to S11) and the user's go.

## Context
**Where it lives.**
- The door: `lib/data/doors/pp_door_early_learning.dart`
- The content: `pp_early_learning_content.dart`, the biggest section. It has 13 areas and 127 pages: 36 activities, 58 stories, 15 habits, plus early skills, Montessori and school.
- Its own five ages: 0–1, 1–2, 2–3, 3–4, 4–6.

**Tabs:** Do something today · Stories and rhymes · Good habits · Before letters and numbers · Starting school.

**Kept on purpose:**
- the activities lead (the door already starts with something to do)
- "Never a worksheet"
- no red-flag strip
- the shop sits after the free things

### What parents actually ask
From `research/questions/ranked_parenting.csv` (3,469 clusters, 17,548 hits):

| Topic | Hits | Top questions | What it means for this door |
|---|---|---|---|
| Talking, speech | 609 | how to help toddler with speech; when do toddlers talk | **The biggest need.** The door's language page is hidden until 2 and links to nothing |
| Screens | 493 | how much screen time; how to limit it | `hab_screens` doesn't link the screen-limits page. YouTube and learning apps get 0 mentions |
| "What age for preschool" | 81 | are 3 year olds in preschool; do 4 year olds go to school | Choosing a preschool only shows from 3, after playgroup has already started |
| "Should he be able to…" | ~100 | should 4/5 year olds read; write their name; know colours; count | No page answers "what most children can do at 3, 4, 5" |
| Admission, India | 11 | "register my newborn in advance for a school?" | 0 mentions of admission, interview, age cut-off or the RTE 25% seats |
| English or mother tongue | 9 | how to get my 2-year-old to speak English | The door's page exists but doesn't link Development's two-languages page |
| Activities, toys | 44–65 | — | Low. The door already serves this well |
| Stories, rhymes | ~6 | — | **Very low.** So no audio studio project now: honest messages, plus a rhymes page in words |

### What a parent meets today
1. **Activities lead at every age**, which is good. Talking, the top need, is not among the first cards for 1- to 3-year-olds.
2. **Stories show too young.** The collections open at 2, but most of the stories say 3½ to 5. Birbal and Tenali open at 3 but say 4–5. Bedtime tales vanish at 4, though one says "right up to four".
3. **Rhymes:** one empty "coming soon" card. There's no Hindi rhyme anywhere.
4. **73 taps that do nothing:** 58 "Listen to this story" rows and 15 films, all COMING SOON with no message.
5. **Help:**
   - The expert card is never drawn (S3).
   - Both experts are placeholders, so a tap lands on "Our first experts are joining".
   - Two cards called "masterclass" open experts, and no early learning class exists.
6. **Shop:** the tool opens the whole store unfiltered. The relevant stock is there: Montessori 22, crayons 14, language and literacy 13, play dough 13, craft kits 16, puzzles 43.
   - The tool's name, "Story books, crayons and activity boxes", is cut off.
   - "Where your baby is right now" runs to three lines, and says "baby" on a tab that opens at 2.
7. **Links that land on a whole screen:**
   - Sleep (bedtime)
   - Behaviour (first day at school)
   - Development ×2
   - Food

   Unlinked pages that exist: speech by age, two languages, screen limits, Potty's "school and public toilets".
8. **Overlaps with no link:** sharing, telling the truth, screens, brushing and bedtime all have twins in Behaviour, Health or Sleep.
9. **Thin pages:** the rhymes page (101 characters) and two stories (about 630).
10. **Small errors:**
    - two story titles lack an apostrophe ("another deer place", "The king cats")
    - three film ids use an old prefix
    - the door comment says 125 pages and twelve areas

## EL1. Talking first, where it's needed most
- For 1–3 years, the first card on "Do something today" is **"Help him talk"**. It opens the language page, which links Development's "Speech by age".
- The language page shows from 1 year (its tag says 1, but its area starts at 2).
- Tab order stays: Today is already the right first tab. Under S9, the later tabs open last as "For later".

## EL2. Stories at the age they're written for
- Each story collection opens at the age its stories say:
  - Panchatantra and world tales from 3
  - Jataka from 4
  - Birbal and Tenali from 4
- Bedtime tales run to 5.
- Under 3, the Stories tab shows "how to tell a story to a baby or toddler" and the bedtime tales.

## EL3. Rhymes and the story audio, honestly
- **The rhymes page is written in words:**
  - 10 well-known rhymes, English and Indian
  - the actions to do with each one
  - why rhymes help talking
- **Hindi rhymes are written in English letters** (the user, 2026-10-25), for example "Machli jal ki rani hai", each with one English line on what it means. Devanagari is not needed for now.
  - ⚠️ This is a deliberate, narrow exception to the CLAUDE.md rule against Hindi in Latin script. It covers rhyme lyrics only, nowhere else. The cost: the app's Hindi (`hi-IN`) voice can't read Latin letters, so these rhymes can't be read aloud by the phone's voice. That's acceptable while audio is owed anyway.
  - Only traditional folk rhymes. Film songs ("Lakdi ki kaathi", "Nani teri morni", "Chanda mama door ke" from *Vachan*) are under copyright and left out.
- **58 "Listen to this story" rows:** a tap says "This story is still being recorded. You can read it aloud now; it works even better in your voice." (S8a).
- Recording the stories and rhymes goes on the owed list. Demand is low, so it isn't now.

## EL4. "Should he be able to…?" and preschool age
- **New page:** "What most children can do at 3, 4 and 5". It covers drawing, letters, counting, colours, writing his name and talking, as wide ranges with no target.
  - It's on Before letters, and links the milestone tracker.
  - Its line: "Reading at 5 is not expected. Loving books is." REQUIRED_REVIEW.
- "Choosing a preschool or playgroup" shows from 2, before playgroup starts.

## EL5. Nursery admission in India (Starting school)
New page "Nursery admission, step by step". REQUIRED_REVIEW, with rules checked before release:
- the age cut-off, which varies by state and board, and how to check it
- when forms open
- documents: the birth certificate, Aadhaar, photos and address proof, linked to the Papers door
- RTE 25% free seats in private schools, and how to apply
- why no school may test or interview a small child (the RTE screening ban)
- anganwadi as a free option

## EL6. Screens, English and the twin pages linked
- `hab_screens` links Behaviour's "How much is too much".
- **New part:** YouTube, cartoons and "learning apps": what helps, what doesn't, and watching together. The top screen question gets an answer here.
- The language page links Development's "Two languages".
- **Twin pages link each other:**
  - sharing ↔ Behaviour sharing
  - truth ↔ Behaviour lying
  - brushing ↔ Health brushing
  - bedtime ↔ Sleep bedtime routine
- Whole-screen links go to the exact page:
  - bedtime → Sleep `bedtime_routine`
  - first day → Behaviour `separation`
  - Potty → `school_and_public`

## EL7. Help and things to buy
- **The two "masterclass" cards** are renamed "Talk to an early learning expert". No fake class.
  - Experts aren't live yet, so a tap opens "experts joining" (S8e).
  - A real early learning class goes on the owed list.
- **The shop tool** becomes "Toys and crayons" and opens the toy shop filtered to Montessori, crayons, language, play dough, craft and puzzles. It stays after the free things.
- **One item per activity page, where a thing really helps:**
  - play dough on the dough activity
  - crayons on prewriting
  - puzzles on the puzzle activity

  Never on a page that says you don't need to buy anything.
- **The tracker card** is renamed "His milestones".

## EL8. Small fixes and thin pages
- The two story titles get their apostrophes ("another deer's place", "The king's cats"). The old titles stay commented out.
- The three film ids are unified.
- The door comment is corrected (127 pages, 13 areas).
- The two thin stories are written out.

## EL9. Films
- The 15 slots stay, and the intro `early_learning/door_intro` is added.
- Until a film exists, a tap says "This film is still being made" (S8a).

## Taps that can't happen yet (S8)

| Target | What she sees |
|---|---|
| 15 films and the intro | "still being made" |
| 58 story audio rows | "still being recorded, read it aloud now" |
| Early learning expert | the "experts joining" page |

## Build order (after step 0 and your go)
1. Bands and tags
2. Help him talk card
3. Rhymes and audio messages
4. New pages
5. Links
6. Shop and names
7. Small fixes
8. Films

**Reuse:**
- `PpDoorTool.atEnd`
- the S1 tab order
- M4 `PpLink.pageId`
- `pvToast` and S8a/e
- the store's category filter in `products_discovery_screen.dart`

## Verification
- **`test/pp_early_learning_door_test.dart`:**
  - the first card at 1–3 is "Help him talk"
  - no story shows below its own stated age
  - every audio row and film has a tap message
  - the tool names fit two lines
- `pp_consult_filter_test`
- `pp_doors_sanity_test`
- `pp_tile_order_test`
- `door_names_fit_test`
- `flutter analyze` on touched files
- grep call sites

## Decisions
These stay here on purpose. When a problem turns up later, check this table first: if an answer covers it, the fix follows that answer, with no new round of questions.

| # | Decision | Why (what parents want) | Answer |
|---|---|---|---|
| EL1 | For 1–3, the first card is "Help him talk" | Speech is the top question parents ask (609) | **Yes**, chosen and recorded (2026-10-25) |
| EL2 | Stories open at the age they're written for | Today a 2-year-old gets stories meant for 4–5 | **Yes**, chosen and recorded (2026-10-25) |
| EL3 | Rhymes written out; honest message on story audio; recording later | Rhyme demand is low, but the page is empty | **Yes** (2026-10-25). The user on script: "it's not necessary to keep it Devanagari script... you can just provide it as a rhyme... written in English, but it's Hindi... for the time being" |
| EL4 | New "what most children can do at 3, 4, 5" page; choosing a preschool from 2 | "Should he be able to read or write his name" is asked often | **Yes**, chosen and recorded (2026-10-25) |
| EL5 | New nursery admission page (age cut-off, RTE seats, no interviews) | Indian parents ask, and nothing answers it | **Yes**, chosen and recorded (2026-10-25) |
| EL6 | Screens, English and twin pages linked to each other | Screens are the second-biggest worry | **Yes**, chosen and recorded (2026-10-25) |
| EL7 | Rename the fake "masterclass" cards; a toy-shop link filtered to the door; one item where it helps | The cards promise a class that doesn't exist. The user: "it's good to have the essentials" in the store | **Yes**, chosen and recorded (2026-10-25) |
| EL8 | Typos, ids, thin stories | Plain fixes | **Yes**, chosen and recorded (2026-10-25) |
| EL9 | A door intro film | Every door gets one | **Yes**, chosen and recorded (2026-10-25) |

The user, 2026-10-25: "all these are like the legitimate representations or recommendations so you can have them. You don't have to ask again and again. Just keep noting down what you are choosing."

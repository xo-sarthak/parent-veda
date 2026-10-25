# Tools 29-33: the Other family

## Context
This is the parenting tools pass (`docs/pp-tool-plans/00-MASTER.md`). You, Maa (25-28) is committed in 96eef2d and ab12297, and no migration is pending.

The user asked (2026-10-25) for the last family to be done the same way as the others:
- read-only audits
- a Mobbin pass per tool
- the backend done
- the plan approved in plan mode before building

**What the audits found:** three of the five tools are not what their names promise.
- **Product guide** opens the shop.
- **Story books and boxes** opens the whole Products tab, with no back button.
- **Baby names** promises "the ones you both love", but no live screen shows matches. Its chosen name "flows through ParentVeda", but nothing reads it.
- **What to say** and **Sleep Sounds** work, but leak:
  - a link to the article that never shows
  - 23 silent taps
  - a sleep timer that a stop quietly clears

**Status: BUILT 2026-10-26, committed `a224492`, see "As built" at the foot.**

**Door check.** No built door has fixed any of these yet. Three approved but unbuilt door decisions cover parts of them: Behaviour **BH2**, Sleep **SL4** and Early learning **EL7**. The user chose (2026-10-25) to **build those tool-side pieces now**. The door builds later do only the door-side work, and each door plan gets a line saying so.

| # | Tool | Surface | Screen |
|---|---|---|---|
| 29 | What to say | `pp_scripts` | `scripts_library_screen.dart`, `pp_scripts_data.dart` |
| 30 | Sleep Sounds | `pp_sleep_sounds` | `pp_sounds_screen.dart`, `pp_sounds_data.dart`, `lib/services/raga_audio_store.dart` |
| 31 | Baby names | `pp_names` | `baby_naming_home_screen.dart`, `name_journey_*_screen.dart`, `name_list_screen.dart`, `name_astro_screens.dart`, `pp_names_data.dart` (`NameMatchStore`). Shared with pregnancy (`ready/names`), so changes are additive |
| 32 | Product guide | `pp_product_guide` | today: `ProductGuideHubScreen`, which is the store facade (`product_guide_hub_screen.dart:302`). The real guides are `pp_buying_guides` → `PpBuyingGuidesScreen` |
| 33 | Story books and boxes | `pp_recos` | today: `ProductsDiscoveryScreen`, which is the whole store. Target: the toy shelf `PvShelfScreen` |

## Out of scope, said plainly
- **Pregnancy's product guide tile** (`tools_hub_screen.dart:615`) still opens the store facade, which has no on-screen back button. That is pregnancy's surface, so it is left as it is and recorded in STILL-OPEN.
- **The 23 unrecorded sounds and real lori.** Recording them is content work, already on the owed list (SL4). Only the honest message is built.
- **A potty buying guide.** `pp_product_guide/Potties` keeps its named toast; the guide stays on the owed list (Potty plan).
- **The retired `...Classic` guide screens and `ProductGuideVotes`** (`pg_votes` syncs with no live writer). They are left as they are, kept for revert, and recorded in STILL-OPEN.
- **Baby names in pregnancy.** A pregnancy has no child record to name, so the "use this name" prompt is Parenting-only. Naming a pregnancy waits on `pregnancies` (0114) gaining a name, and is recorded in STILL-OPEN.
- **Door-side BH2, SL4 and EL7 work** (door tabs, rows, the "Right now" row, the 3 new script pages' door placement) stays with the door builds.
- **Ask Veda.** Nothing here needs the service.

## Mobbin pass (2026-10-25)
| Tool | Reference | Adopt | Decline |
|---|---|---|---|
| What to say | Quo snippets, with search on top and title plus first line https://mobbin.com/screens/364e320e-efbe-4f5d-8951-66f46c79a783<br>Wispr Flow "phrase → expansion" https://mobbin.com/screens/adc1110c-6bd4-4bfe-873d-5f99e70fb5b7 | Search first; each card shows the moment and the first line. Search also reads hidden words (tantrum, bedtime) | Copy and share buttons (no share, by design) |
| Sleep Sounds | Insight Timer timer sheet: "When the timer ends, playback stops" https://mobbin.com/screens/3d07ca31-4aa3-4140-88a1-cc8b8b655186<br>Mindvalley 5m–30m chips https://mobbin.com/screens/449adc2b-ca83-4f92-a451-b517f0c27a99 | One line under the timer chips saying what happens; the timer counts from play; "All night" is a real choice | Dark full-bleed player art |
| Baby names | talabat swipe with the caption "Swipe right to add… to dismiss, swipe left" https://mobbin.com/screens/c9812978-5743-41ad-bbc5-117e71d3c928<br>Bumble "Liked You" as its own place https://mobbin.com/screens/3082e638-fdbf-4ce2-a2d4-52f9423b8cc9 | A one-line swipe caption on the first card only; "You both love" as its own section at the top of the shortlist | Match pop-ups and confetti |
| Product guide | Shop guide, with product cards inline in the written guide https://mobbin.com/screens/d6b6911c-b18a-4c4c-a513-3b4d1435d87d | The guides lead, with "Shop this" at the foot of each guide, never above the advice | Comparison paywall grids |
| Toys and crayons | Givingli chip row over a grid https://mobbin.com/screens/296ca4de-4414-48b8-a5eb-5e76ad54df74<br>Tripadvisor "Show 214 results" https://mobbin.com/screens/1c579185-bbc5-4326-a715-c35a414afdc2 | The six kinds as chips on one shelf, with his age first | A filter sheet; six chips need no sheet |

## Audit (three read-only audits, with the key claims checked against the code)
| Tool | Findings (summary) |
|---|---|
| **What to say** | **Wrong:**<br>- "Read the whole thing" never shows, because the router builds `ScriptsLibraryScreen()` with no `onOpenPage` (`pp_surface_router.dart:793`).<br>- The baby band promises family scripts but holds only `throwing_food`.<br>- Searching "tantrum" or "bedtime" finds nothing, though the Tools blurb sells tantrums.<br>- The empty line says "browse by age above", but those chips are gone (`:131`).<br>**Weak:**<br>- The back label says "Behaviour" from the Tools tab.<br>- Pronouns are hard-coded and mix He and She, with no `ppFillChild`.<br>- There is no `pp_scripts/<id>`.<br>- It is in `_owedShell`.<br>**Polish:**<br>- The band is read once, with no listener.<br>- The label reads "FOR YOUR BABY · 3 AND UP".<br>- A stale "saved items" comment.<br>**Good:** it opens on the child's band; nothing is stored; no blame copy (tested); fine in the father's view. |
| **Sleep Sounds** | **Wrong:**<br>- `stop()` clears the sleep timer (`raga_audio_store.dart:327` calls `_teardown()` with the default `keepSleepTimer:false`), so the next play runs all night.<br>- 23 of 24 rows are silent taps (`pp_sounds_screen.dart:293`).<br>- The tanpura, the only track that plays, is listed last.<br>- The library page's tanpura slot is an inert placeholder that toasts a false line.<br>- "Download the two or three you use" promises a feature that doesn't exist.<br>**Weak:**<br>- The timer counts from arrival, not from play.<br>- A null timer means both "not set" and "All night", so her "All night" is overridden.<br>- The safety line gives no distance and no "not in the cot"; the page says 2–3 ft.<br>- Blurbs promise rain and stories.<br>**Polish:**<br>- Three names for it.<br>- The tanpura is labelled "45 min" for a short loop.<br>- Material icons; in `_owedShell`.<br>**Good:** the asset is real and in pubspec; one shared player owns the timer; it loops and plays in the background; nothing stored, by design. |
| **Baby names** | **Broken:** partner matches work in the backend (0027 `pp_name_matches`, security definer, never says whose vote is whose), but only the retired V1 `NameMatchesScreen` reads them.<br>**Wrong:**<br>- "Both" copy appears in 3 places, but the shortlist holds only her own likes.<br>- The chosen screen promises the name "flows through" the child profile, journal and storybook, and nothing reads it. "Chapter One" opens a blank story.<br>- A heart can't be un-liked, which is a silent tap, and the shortlist has no remove.<br>- Undo in the deck leaves the like in place; pass never calls `skip()`; the deck restarts at 0 and shows names already voted on.<br>**Weak:**<br>- No framing for a child who already has a name.<br>- The astro tiles state "Ruling planet" and "Auspicious" as fact.<br>- An unknown name falls back to "Aarav".<br>- Four taps to the first like on every visit, and no toasts.<br>- The detail and astro pages are off the shell, with lavender and purple gradients.<br>- The flow test drives the retired screen.<br>- No contract test on `pp_name_votes`.<br>**Polish:**<br>- "2,031" should be 2,040.<br>- `mutual: true` left on 3 names.<br>- अनीता should be अनिता.<br>**Good:** nothing fabricated (tested); votes are per person, local-first and merged newest-wins; the crown is synced; sign-out is safe; the shortlist is shared with pregnancy; 15 Devanagari spot-checks are correct. |
| **Product guide** | **Wrong:**<br>- The Tools row ("what is worth buying, and what to skip") lands on the parenting storefront, which is the Products tab again.<br>- The real six "How to choose" guides (`pp_buying_guides`) are not in the Tools tab.<br>- The hub's "What do I actually need?" and Feeding's "Compare breast pumps" land on the store too. No pump guide exists.<br>**Weak:**<br>- `chrome: none` has no on-screen back.<br>- The car seat guide cites ECE but not India's AIS-072, and uses "less than an inch".<br>- `product_guide_test` pumps the retired Classic screen.<br>**Good:** seeded reviews are off; Amazon ratings are labelled; the honesty strip; "For you" by age; the wishlist is synced per person. |
| **Story books and boxes** | **Wrong:**<br>- The whole Products tab is pushed over a door, with no back button and the bottom bar lit (EL7, unbuilt).<br>- No "story box" or "activity box" is stocked.<br>- The `pp_books/Potty` toast says there are no picture books, but 285 are on the Reading shelf.<br>**Weak:**<br>- Picture books can't be reached from here.<br>- "Bags, boxes, bottles and shoes" opens the whole store, though a tiffin shelf and a shoes guide exist.<br>**Polish:** the C1 allow-list comment is wrong; the store rail uses real age while toys use corrected age.<br>**Good:** the stock is real (Montessori 22, crayons 14, language 13, play dough 13, craft 16, puzzles 43); `pp_toys` is age-first with S8 toasts. |

## Decisions
| # | Question | Recommended | User's answer |
|---|---|---|---|
| O1 | Build the tool-side pieces of BH2, SL4 and EL7 now? | Yes; the door builds do only door-side work | **Yes** (2026-10-25) |
| O2 | Baby names: what happens to the chosen name? | A one-tap confirm, "Use Aanya as <child>'s name?", only when the active child has no name yet; the over-promise is removed | **One-tap confirm** (2026-10-25) |
| O3 | Partner matches (chosen, obvious) | "You both love" at the top of the shortlist, read from `matches`. Empty: "Names you both like gather here once your partner likes some too." That line is honest whether or not she is paired. The "both" copy stays, because it is now true | Recorded |
| O4 | Product guide (chosen, obvious) | In Parenting, `pp_product_guide` opens the guides, not the store. Each guide ends in "Shop this". The hub's "What do I actually need?" becomes "Shop for his age" → `pp_products`. A 7th guide, **breast pumps**, keeps Feeding's "Compare breast pumps" promise | Recorded |
| O5 | EL7's filter (chosen, obvious) | The six kinds EL7 named, as chips on one toy shelf: an additive `subIds` on `PvShelfScreen`. `pp_recos` keeps its id (brackets use it) and is named "Toys and crayons" | Recorded |
| O6 | Baby names when the child is already named (chosen, obvious) | Kept at every age (a feature is never hidden). The home reads "Naming your next baby" once the active child has a name. One shortlist per person; the crown star clears when a new pregnancy starts | Recorded |
| O7 | Astrology tiles (chosen, obvious) | Kept, worded as custom: "Traditionally linked to…", "Families who follow this say…". The disclaimer moves to the top | Recorded |
| O8 | Consent (chosen, obvious) | No new `PpUseKind`. Scripts, sounds, guide and shop learn nothing. The name is written only on her own tap, which is itself the consent | Recorded |
| O9 | White noise safety (chosen, obvious) | The player says: speaker across the room, never in the cot, quieter than a running shower. The page's "2–3 ft" goes to the AAP-cited ~2 m. REQUIRED_REVIEW | Recorded |

## Build, in three waves (each ends green, backend closed)

### Wave 1: backend
- **Name votes (`NameMatchStore`, `pp_names_data.dart`):**
  - `unlike(name)` writes a `liked:false` vote, which is a tombstone, not a delete. The heart on the list and detail pages becomes a toggle, and the shortlist gets remove with Undo.
  - Pass calls `skip()`. Undo reverses the vote.
  - The deck leaves out names already voted on.
  - `babyNameByName` with an unknown name drops the row instead of showing Aarav.
  - `mutual: true` is commented out on the 3 names.
  - **Teaching point:** in a newest-wins merge, a deleted row loses to the other phone's old copy and comes back. A `liked:false` row with a newer `updated_at` wins. That entry goes into BACKEND-PATTERNS.
- **The chosen name to the child (O2):**
  - The shortlist's crown shows the confirm only when `ChildProfileStore` has a real child whose name is still the placeholder.
  - Yes calls `ChildProfileStore.update(name:)`, which already syncs.
  - The toast says what changed: "Aanya is now on her profile."
  - The crown clears when a new pregnancy starts (`stage_moves.dart` is another terminal's open file, so the crown is cleared by a listener in the names store instead).
- **Sleep timer (`raga_audio_store.dart`):**
  - `stop()` keeps her chosen length.
  - The countdown starts on play, not on arrival.
  - "All night" is its own value, separate from "not set", so arriving never overrides it.
  - It stays on this phone and is never synced (the same device-local pattern as the mood reminder, §16tt).
- **Toy shelf:** `PvShelfScreen` gains an optional `subIds` set; the default is unchanged. The `pp_recos` route → `PvShelfScreen(categoryId: kSheetToyCategoryId, subIds: {Montessori, Crayons, Language and Literacy, Play Dough, Craft Kits, Puzzles})`.
- **Product guide route (Parenting only):**
  - `pp_product_guide` → `PpBuyingGuidesScreen`.
  - `pp_buying_guides/<id>` opens one guide.
  - Pregnancy's `surface_router.dart` is untouched.
- **Tests:**
  - A `pp_name_votes` contract test (`user_id, name, liked, updated_at`).
  - Unlike round-trips as `liked:false` and merges over an older like.
  - The deck excludes voted names.
  - The timer survives stop, starts on play and keeps "All night".
  - The toy shelf with `subIds` shows only those kinds.
- **Docs:**
  - sync log step 22 and STILL-OPEN-BACKEND row 22 (unlike as a tombstone, the name to the child)
  - BACKEND-PATTERNS (the tombstone entry)
  - **No migration:** the columns exist and `liked` is already a bool.

### Wave 2: content and clinical (every changed line REQUIRED_REVIEW, in BEFORE-LAUNCH)
- **Scripts (BH2):**
  - The four family scripts for 0–12 months, from `08-behaviour-content.md` §1. The honey script says no honey before 1.
  - Pages for the 3 scripts with a null `pageId`.
  - Each script gets an additive `words` list (tantrum, meltdown, bedtime, sleep…) that search reads.
  - Situations go through `ppFillChild`, so the mixed He and She goes.
- **Sleep Sounds (SL4):**
  - The tanpura first, everywhere (data order, the library page).
  - The library is named "Lullabies and lori".
  - The O9 safety line, with "her breathing" made neutral.
  - "Download…" reworded to what is true.
  - The tanpura is labelled "Loops until the timer ends", not "45 min".
  - Blurbs promise only what plays, plus "more being recorded".
- **Baby names:**
  - O7 wording on the astro and numerology pages.
  - अनिता.
  - The Tools blurb count is worked out live (2,040).
- **Guides:**
  - A new "Breast pumps" guide: manual or electric, flange size, what to skip, no brands. A lactation consultant reviews it.
  - The car seat guide gets AIS-072 and "2.5 cm".
- **Shop copy:** `pp_books/Potty` toast → "Picture books for potty time are on the Reading shelf", with a pill to `pp_read`.

### Wave 3: each tool's UX (Mobbin above)
- **What to say:**
  - On `PregToolScaffold`, out of `_owedShell`. The shell's back replaces the "Behaviour" label.
  - It listens to `ChildProfileStore`.
  - The router passes `onOpenPage` (→ the reader).
  - `pp_scripts/<id>` opens on that script, and the six door page links use it.
  - The empty line: "Nothing for that yet. Try 'hitting' or 'bedtime'." (bedtime now finds something).
  - The age label reads right with no name.
- **Sleep Sounds:**
  - `PregToolScaffold` gains an optional `bottom:` slot, additive, with the default unchanged for pregnancy. The now-playing bar sits there, and it comes out of `_owedShell`.
  - The 23 other rows toast the SL4 line: "This lullaby is still being recorded. The tanpura plays now." The toast has a Play tanpura pill.
  - One line under the timer chips: "Stops by itself when the timer ends. All night keeps playing."
  - The library page's tanpura slot plays through `RagaAudioStore`.
  - Drawn marks; the title "Sleep Sounds".
- **Baby names:**
  - "You both love" (O3) on the shortlist.
  - After the first visit, the home goes straight to the deck: the quiz and primer are skipped and stay reachable from a row.
  - A one-line swipe caption on the first card.
  - Toasts on like ("Added to your shortlist", with Undo) and on crown.
  - "Naming your next baby" framing (O6).
  - "Chapter One" passes the name to `WriteStoryScreen` through an additive optional param.
  - The detail and astro pages move onto the shell: lavender and purple go, neutral grey and ink pills come in.
- **Product guide:**
  - The Tools row is "Product guide", with the blurb "How to choose a car seat, cot, pram, carrier and more." It opens the guides.
  - Each guide ends in "Shop this" → its stocked shelf, with an S8 toast where none is stocked.
  - The hub row is re-labelled (O4).
  - Feeding's "Compare breast pumps" → `pp_buying_guides/breast_pump`.
- **Toys and crayons (EL7):**
  - The door and content label is "Toys and crayons", and the link lands on the filtered shelf.
  - "Bags, boxes, bottles and shoes" → the tiffin shelf, plus the first shoes guide.
  - A separate "Picture books by age" → `pp_read`.
  - The C1 allow-list comment is corrected.

## Files (main)
- **Screens:**
  - `lib/screens/post_pregnancy/`: `scripts_library_screen.dart`, `pp_scripts_data.dart`, `pp_sounds_screen.dart`, `pp_sounds_data.dart`, `baby_naming_home_screen.dart`, `name_journey_feed_screen.dart`, `name_journey_shortlist_screen.dart`, `name_journey_detail_screen.dart`, `name_list_screen.dart`, `name_astro_screens.dart`, `pp_names_data.dart`, `pp_buying_guides.dart`, `pp_buying_guides_screen.dart`, `pp_surface_router.dart`, `pp_tools_tab.dart`
  - content links: `pp_behaviour_content.dart`, `pp_sleep_content.dart`, `pp_early_learning_content.dart`, `pp_feeding_content.dart`, `pp_content.dart` (the library slot)
  - `lib/data/doors/pp_door_early_learning.dart`, `pp_door_sleep.dart`, `lib/data/hubs/parenting_hubs.dart`
- **Shared, additive only:** `lib/screens/pregnancy/preg_tool_chrome.dart` (`bottom:`), `lib/screens/products/pv_shelf_screen.dart` (`subIds`), `lib/services/raga_audio_store.dart`, `journal_capture_screens.dart` (`WriteStoryScreen` name param).
- **Not touched (another terminal's open work):** `supabase_repo.dart`, `stage_moves.dart`, `family_profile.dart`, `life_stage_store.dart`, `STILL-OPEN.md` / `GLOBAL-CHANGES.md` until that work is committed. Their lines are held in the plan file as last time.
- **Tests:**
  - New: `test/pp_other_tools_test.dart` (backend: votes, timer, shelf filter, guide routes) and `test/pp_other_tools_ux_test.dart` (scripts search and links, sound toasts and order, names sections and toasts, guide landing, toys landing).
  - Updated: `pp_scripts_test`, `pp_tools_one_look_test` (`_owedShell` shrinks by 2), `pp_tools_tab_test`, `pp_sleep_door_test`, `pp_early_learning_door_test` (its `pp_recos` assertion), `post_pregnancy_names_flow_test` (moved onto the live feed), `product_guide_test` (the live path), `pp_name_list_look_test`.
- **Docs:**
  - `docs/pp-tool-plans/29-33-other.md` and README rows 29-33
  - a one-line note in `08-behaviour.md`, `07-sleep.md` and `09-early-learning.md` (tool-side pieces landed in the tools pass)
  - BACKEND-PATTERNS, the sync log, STILL-OPEN-BACKEND, BEFORE-LAUNCH, STILL-OPEN (held if it is still open elsewhere)

## Verification
- Run `git status` before edits; the files above that belong to other terminals are not touched.
- After each wave:
  - `flutter analyze` on the touched files
  - the new tests plus neighbours: scripts, behaviour door, sleep door, raga audio, names catalogue, list look, names flow, no-fabricated-data, children sync, sync guard, early learning door, what to buy, product guide, feeding door, potty door, tools tab, one look, door names fit, preg tools shell (the `bottom:` default), the pregnancy names door (`ready/names`), reader unification
- The tests hold:
  - The router passes `onOpenPage`, and `pp_scripts/<id>` opens that script.
  - "tantrum" and "bedtime" find scripts, and every baby-band script fits 0–12 months.
  - Every non-live sound toasts, the tanpura is first, and the timer survives stop.
  - Un-like round-trips, and matches show on the shortlist.
  - The name prompt shows only for a placeholder name and writes `name`.
  - No "Aarav" fallback, and the astro pages carry no "Ruling planet" or "Auspicious".
  - The Tools "Product guide" row lands on the guides, and every guide's "Shop this" lands or toasts.
  - `pp_recos` lands on the toy shelf with only the six kinds.
- **Wiring gate:** grep every caller of `unlike`, `onOpenPage` in the router, `subIds`, `bottom:` on the scaffold, `pp_buying_guides/`, `pp_scripts/`, and the name prompt.
- A phone walk only on the user's word. Git commands at the end, with explicit paths.

## As built (2026-10-26)
Built in four waves. The fourth exists because the Sleep door (door 7) was being built in another terminal when this started: it held `pp_sounds_*`, `pp_sleep_content.dart` and the router. Sleep Sounds and every router change waited until it was committed (f471dd4), then went in. That door built SL4's tool-side pieces itself (the tanpura first, the "still being recorded" toast, "Lullabies and lori"), so they are not repeated here.

**29 What to say.**
- On `PregToolScaffold` and out of `_owedShell`. The shell's back replaces the hard-coded "Behaviour".
- The band follows the active child.
- The label reads "FOR YOUR CHILD" past the first year when no name is set.
- **"Read the whole thing" works on every way in.** With no opener passed, the screen opens any section's page through `pp_page/<section>/<page>` (`ppOpenScriptPage`).
- **BH2:**
  - The four family scripts for under-ones: spoiling, let him cry, the milk, and honey or gripe water. Honey carries its safety line on the card.
  - The three scripts with no page now have one: `beh_tantrum_steps`, Feeding's `picky_battles` and Sleep's `bedtime_routine`.
  - `pp_scripts/<id>` opens on that script, and the six Behaviour page links use it.
  - The empty line: "Nothing for that yet. Try 'hitting' or 'bedtime'."
- **Search** reads a hidden `words` list per script ("tantrum", "bedtime" and others now find scripts).
- **Pronouns.** Situations are authored as "He" and filled by `ppFillChild`.

**30 Sleep Sounds.**
- On the shell, with the pause bar in the shell's new optional `bottom:` slot. The default is unchanged for pregnancy.
- Named "Sleep Sounds".
- **The timer** (`RagaAudioStore.armSleepTimer`):
  - Her choice survives a stop.
  - The countdown starts on play.
  - "All night" is its own choice.
  - A line under the chips says how it works.
  - Garbh's players are untouched.
- **The white-noise line** on the player and the library page: quieter than a running shower, about 2 metres, never in the cot (O9).
- **The library page:** the tanpura is a link that opens the player, not an inert slot.
- "Download…" lines say what is true: the sounds play from the app with no network.
- The tanpura says "Loops", not "45 min".

**31 Baby names.**
- **Votes:**
  - `unlike` writes a tombstone.
  - Pass records a skip.
  - Undo forgets the answer (`clearVote`).
  - The deck leaves out answered names.
- **The shortlist:**
  - "You both love" heads it, read from the database's matches.
  - Every row can be removed, with Undo.
  - An unknown name is dropped, never shown as Aarav.
- **The hearts** on the list and detail pages toggle, with a toast.
- **The chosen name (O2):** "Use Aanya as your baby's name?" shows only for a child on record with the placeholder name, and writes through `ChildProfileStore.update`. "Begin the story" opens with the title "The story behind Aanya".
- **The quiz** is asked once. Its answers are kept on this phone, and the home has "Change what you see".
- **The home** says "Naming your next baby" once a child has a name.
- **Astrology and numerology** are on the shell, worded as tradition, with the note first. The child-personality paragraph is not shown.
- **The detail page** is in ink and white.
- **Data fixes:** the count is live (2,040), the fake `mutual` flags are commented out, and अनिता is corrected.

**32 Product guide.**
- The Tools row and Parenting's `pp_product_guide` open the guides, titled "Product guide".
- **A seventh guide, breast pumps.** Feeding's "Compare breast pumps" lands on it through `pp_buying_guides/<key>`.
- **Every guide ends in "Shop this"** (the reader's `nextSteps`). A shelf with no stock answers with the router's line.
- **The car seat guide:** AIS-072 and 2.5 cm.
- **The hub row:** "What do I actually need?" became "Shop for this age", which opens the shop.

**33 Toys and crayons (EL7).**
- `pp_recos` keeps its id and opens one toy shelf of the six kinds. This needed an additive `subIds` and `title` on `PvShelfScreen`.
- The door and section labels say "Toys and crayons".
- A new section tool, "Picture books by age", opens `pp_read`.
- "Bags, boxes, bottles and shoes" became two links: the tiffin shelf and the first shoes guide.
- The potty books toast points at the Reading shelf.
- The C1 comment is corrected.

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| SL4's tool-side pieces in this pass (O1) | Built by the Sleep door in its own commit | It was building them in parallel; this pass did the rest of Sleep Sounds after it committed |
| Toasts on like in the swipe deck | Toasts on the list and detail hearts and on remove; the deck keeps its own feedback animation | A toast on every swipe is noise; a single tap needs the explanation |
| A swipe caption on the first card | Not added | The deck already shows an always-visible instruction and a hand demo |
| The crown clears when a new pregnancy starts | Not built (STILL-OPEN §102.10) | The pregnancy start lives in `stage_moves.dart`, another terminal's open file; the crown moves when she chooses another |
| The detail page onto the shell | Recoloured to ink and white instead | It has its own sticky action bar; the shell has no slot for it |
| A Play-tanpura pill on the not-yet toast | Already there from the Sleep door ("Play it") | — |
| `pp_scripts_test` "every page link is a Behaviour page" | Widened to "a page in some section" | Two script pages are in Feeding and Sleep by design (BH2's "closest page") |
| Sync log step 22, STILL-OPEN-BACKEND row 22 | Step 23 and row 23 | Another terminal's R2 work took step 22 first |

## Verified
- **New:**
  - `test/pp_other_tools_test.dart` (19): name votes, the deck, the shortlist and the name offer, tradition wording, the live count, the timer.
  - `test/pp_other_tools_ux_test.dart` (16): script search, scripts and links, Read the whole thing, the empty line, Sleep Sounds look and silent taps, script deep links (every `pp_scripts/<id>` in lib names a real script), guide routes and Shop this, the pump guide, AIS-072, Toys and crayons, the potty books toast.
- **Updated:** `post_pregnancy_names_flow_test` (the live deck), `pp_scripts_test`, `pp_tools_one_look_test` (`_owedShell` is now empty), `pp_sleep_door_test` (the library), `pp_buying_guides_test` (seven guides), `pp_tools_tab_test` (C1 comment).
- **Neighbours:** every `test/pp_*` plus product guide, raga audio, preg tools shell, garbh playback, reader unification, journal compose, smoke, sync guard, door names, the Ask Veda corpus, getting ready, kegel, TTC shell: 1,500+ green.
  - The one failure is `pp_feed_tool_test` "the screen: 24-hour count…". It logs a feed an hour ago and looks for it in today's list, so it fails between midnight and 1am (it ran at 00:34). That is a pre-existing clock flake, and nothing here touched it.
- **Analyze** is clean on every changed file.
- **Wiring gate:** `unlike`, `clearVote`, `ppToggleNameLike` (3 callers), `ppNameOfferFor`, `store.matches` on the live shortlist, `subIds`, the shell's `bottom:`, `armSleepTimer`, `pp_buying_guides/` (Feeding, Early learning), `pp_scripts/` (6 Behaviour links), `ppOpenScriptPage`, `initialTitle`, and `startAtQuiz` all have callers.

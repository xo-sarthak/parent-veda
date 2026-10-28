# P4: Pregnancy, birth prep

## Context
Pregnancy and TTC tools pass (`00-MASTER.md`), family P4, Terminal B. Audit read-only on 2026-10-28: three helpers read the code and the lead checked every Broken and Wrong claim at its file:line. Also carries the user's 10-28 after-loss rule (P3 D5) to the rest of Get ready.

| # | Tool | Surface | Screen and store |
|---|---|---|---|
| 1 | Hospital bag | `tools/hospital_bag` | `tools/ready_for_birth_screen.dart`; `HospitalBagV2Store`, `ReadyBirthContextStore` |
| 2 | Product checklist | `tools/product_checklist` | `tools/product_checklist_screen.dart`; `ProductChecklistStore` |
| 3 | Shopping list (food) | `nutrition/list`, door tile | `nutrition/door/shopping_list_screen.dart`; `NutritionDayStore` |
| 4 | Contraction timer | `tools/contractions` | `tools/contraction_tracker_screen.dart`; `ToolsStore` (`contraction_sessions`) |
| + | After a loss only | Birth plan, Baby names | `pregnancy/birth_plan_screen.dart`, `post_pregnancy/baby_naming_home_screen.dart` |

## Out of scope, said plainly
- **Door files go to Terminal A:** the Labour tile "What to pack for whoever comes with you" should open the partner section (we add `initialCategory` on the screen; A points the tile at it); the "Shop the list" blurb; the "Contraction Tracker" spelling on door tiles; an after-loss hero line on the Labour and Getting ready doors.
- **Matching bag and checklist items to the 410 live store products** belongs to the Store terminal (ASINs owed by the user). P4 only routes to the store and stops inventing products.
- **The Garbh Sanskar row after a loss** stays hidden (D2). It is in Keep, a practice for the baby, not her data.
- Birth plan and Baby names change only their after-loss state here; the rest of both stays as P2 left it.
- The dead `HospitalBagScreen` and `HospitalBagStore` stay (kept for revert); not touched.

## Findings (checked)
**Shopping list:** S1 Broken, no screen on its own way in loads the store (only `nutrition_door.dart:98`, `nutrition_today_body.dart:67`), so it reads empty; S2 Broken, `addToList` before the store loads writes an almost empty blob over `nutrition_day_v1` (`nutrition_day_store.dart:294, 497`, no loaded check), so water, ticks and the list go when logged out; S3 not on Tools (C1); S4 Ask Veda and global search send "shopping list" to the baby Product checklist; S5 silent clear and remove, no own item or single remove, door chrome, "Your list" vs "Your shopping list".

**Contraction timer:** C1 before 37 weeks "call now" needs 5+ contractions in a pattern (`:1758` after `:1733`); C2 waters and movements "not sure" never escalate, light bleeding only "reported" (`:1644-1647`); C3 no first vs later baby, `n >= 8` replaces the hour, no fever / previous caesarean / twins / GBS, no "follow your hospital"; C4 a running contraction lives in memory only; C5 no undo, delete or 5-second guard; C6 "Last hour" covers the whole session (`:1819`); C7 "Awaaz on karein" (Hinglish); C8 diagnostic labels, emoji toasts, screen sleeps, sub-screens off the tool look, silent end, "How are you feeling?" to the partner; C9 `date_iso` is a `date` column, so the time is cut (`0003:103`), no column contract.

**Hospital bag:** H1 "Labour started?" says "You have time." with no red flags, no 108, no call button (`app_language:4303`); H2 baby lotion vs NHS (`ready_for_birth_data.dart:128`); H3 season from today's month (`ready_birth_context_store.dart:45`); H4 invented "ParentVeda" picks and made-up retailer prices (`hospital_bag_catalog.dart:222-254`); H5 four names, delivery type does not rebuild, custom items cannot be deleted, silent saves, swaddle and cap notes, India documents missing.

**Product checklist:** P1 "Buy on Amazon" skips `openOutbound` (no tag, `:260`); P2 "Buy now" opens the preview checkout ("order placed", no payment); P3 progress counts ticked only, "Got" also holds bought (`:889` vs `:891`); P4 whole-blob sync, two phones overwrite; P5 no week order, "Newborn essentials" is two things for her, silent saves.

## Decisions
| # | Question | Recommended | User's answer (2026-10-28) |
|---|---|---|---|
| D1 | Made-up store products (H4, P2) | Use the live store from Store Track A (6c80dd86, 62250cba): a product the store knows opens its product page (honest price, tagged link, reviews); otherwise the store search on the item's name; otherwise a tagged Amazon search through `openOutbound`. The invented picks, made-up prices and the preview checkout are commented out in these two tools | **"go for the store the product hub was updated with"**; tell the user if an issue remains |
| D2 | Garbh Sanskar row after a loss | Stays hidden | **Your recommendation** |
| D3 | Where the food shopping list sits | Track, beside Weight and BP | **Yes, Track** |
| D4 | After a loss | Every Get ready tool stays, baby wording dropped, a calm note in each tool (the P3 D5 rule) | **User's 10-28 rule** |
| D5 | Clinical calls | NHS / RCOG / ACOG; numbers to BEFORE-LAUNCH | **"Make clinical calls to industry standard yourself"** |

Obvious calls, recorded: per-item checklist sync; one name per tool ("Hospital bag", "Contraction timer"); screen awake while timing; a running contraction kept on the phone and resumed if reopened within 2 hours; take back the last one and delete a session, with Undo; a 5-second minimum; the checklist stays out of the per-pregnancy archive (what she bought stays hers); first vs later baby derived from a child already on her profile, never asked.

## Clinical calls (each number on a BEFORE-LAUNCH clinician CHECK line)
- **Before 37 weeks:** a standing line on the timer, "Contractions before 37 weeks: call your maternity unit now. You don't need to wait for a pattern." The reading turns to "call now" at 4 in 20 minutes or 8 in 60 (ACOG's preterm threshold), whatever the pattern.
- **Not sure counts as yes** for waters and movements (NHS). Any bleeding before 37 weeks, or heavy at any week, means call. Waters green or brown: urgent.
- **Time to call:** first baby, about every 5 minutes, lasting about a minute, for an hour (ACOG 5-1-1), read from the last 60 minutes only; a later baby, call at about every 5 minutes without waiting the hour. Twins, a previous caesarean, GBS or a fever: call earlier, with a link to the Labour read. Every reading: "Your hospital may have told you something different. Follow them."
- **Labels:** no "Active labour likely". The levels speak in what to do ("This is the pattern hospitals ask you to call about").
- **Bag emergency page:** the red flags, a 108 call button, "call your hospital". 102 (free maternity ambulance) varies by state: BEFORE-LAUNCH.
- **Baby lotion** commented out; swaddle and cap get safe-sleep lines.

## Build, three waves, no stop between
1. **Correctness and safety:** S1, S2; C1-C6, C9; H1-H3; P1-P3; D1 store routing.
2. **After a loss and wording:** every `if (!_ended)` on Get ready comes out (kept as revert comments); `PregAfterLossNote` in the bag, timer, checklist, birth plan and (by a Pregnancy-only flag) names; baby wording drops in each; the birth plan summary ask stays hidden; `pvVedaToolStepsAside` loses Get ready; C7, C8, H5, P5, S5 wording and silent saves.
3. **Wiring and tests:** Shopping list row in Track; Ask Veda and search "shopping list" open the food list, "baby things" the checklist; per-item checklist sync; column contract for `contraction_sessions`; tests for the clinical rules, after a loss, reachability and store round-trips; `after_loss_tabs_test` flips; analyze and the stage tests green.

## As built (2026-10-28)
Built in three lanes by file, then joined: the copy of every after-loss note now comes from `preg_after_loss_note.dart`.

**Contraction timer** (`contraction_tracker_screen.dart`, `tools_store.dart`, `app_language.dart`)
- Before 37 weeks: a standing "call your maternity unit now" line; `pretermFrequencyMet` (4 in 20 minutes or 8 in 60, by start times) turns the reading to preterm whatever the pattern (C1).
- A new `callNow` level for waters yes or not sure, movements yes or not sure, light bleeding before 37 weeks; a waters-colour question; emergency only for heavy bleeding or constant severe pain (C2).
- Readings use the last 60 minutes (`contractionsInLastHour`); the `n >= 8` shortcut is commented out; a first baby needs 5-1-1 over an hour, a later baby (`ChildProfileStore.hasRealChild`, derived) needs 4 in the last hour with the pattern; "Your hospital may have told you something different. Follow them." on every reading; "Call earlier if…" opens the Labour read (C3). Titles say what to do, not what she has.
- The running session lives on the phone (`LiveContractionState`) and resumes within 2 hours, with "Picked up where you left off" (C4); a 5-second minimum, take back the last one and delete a session, both with Undo, soft deletes through the sync ledger (C5).
- The copied summary covers the real last hour or says "This session", with her week and symptoms (C6); `date_iso` sends the date part, history sorts by first start, a contract test pins the columns and the `date` type (C9).
- "Sound on / off" (C7); no emoji; awake while timing; "Saved to your history"; "How is she feeling?" in the partner's view; one name, "Contraction timer" (C8).
- After a loss: the note, "Track" eyebrow, no movement question, no labour readings ("Your timings are kept here"), the timer still works.

**Hospital bag** (`ready_for_birth_screen.dart`, `ready_for_birth_data.dart`, `hospital_bag_seed.dart`, `hospital_bag_catalog.dart`, `hospital_bag_v2_store.dart`, `ready_birth_context_store.dart`)
- "Labour started?": no "You have time"; call your hospital, six red flags, a Call 108 button (H1).
- Baby lotion out (an unpacked one leaves an existing bag, a packed one stays); swaddle and cap safety lines; four India documents added once to existing bags by `syncDefaults` (H2, H5).
- Season from the due month (H3). Invented picks and prices commented out; "Need one?" is "See it in the store" (H4, D1).
- "Hospital bag" everywhere; delivery type adds or removes only the caesarean items and keeps ticks; custom items rename and remove with Undo; every save speaks; `initialCategory: 'partner'` for A's door tile; "For her" in the partner's view.
- After a loss: the note; Baby, the week, days-to-due, "baby comes tonight", twins and hospital-provides step aside; "Going into hospital now?" with an after-loss red-flag page.

**Product checklist** (`product_checklist_screen.dart`, `product_checklist_store.dart`)
- Buy now, Add to cart and the cart bar commented out; "See it in the store" opens the product page (id known), else the store search, else a tagged Amazon search; custom links through `openOutbound` (P1, P2, D1).
- Both counts use `ownedCount` (P3). Per-item sync on `CloudMergedStore` with the old blob lifted once (P4). Every save speaks, deletes have Undo; "Newborn essentials" is honestly "Feeding and first weeks"; starters ordered by her week (P5).
- After a loss: the note; the feeding starter steps aside; her lists stay.

**Shopping list** (`shopping_list_screen.dart`, `nutrition_day_store.dart`)
- The screen loads the store; an edit before the load is held and replayed, never written over her data (S1, S2).
- On `PregToolScaffold`, "Your shopping list", add your own item, remove one line, Undo on every removal, ink pills (S5).
- A Tools row in Track; Ask Veda and search send "shopping list" and "grocery" here, "baby things" to the checklist (S3, S4, D3).

**After a loss, the rest of Get ready** (`tools_hub_screen.dart`, `pv_veda_links.dart`, `preg_after_loss_note.dart`, `birth_plan_screen.dart`, `baby_naming_home_screen.dart`, `name_journey_shortlist_screen.dart`)
- Every Get ready `if (!_ended)` is a revert comment; the rows carry after-loss lines; Garbh Sanskar stays hidden (D2). `pvVedaToolStepsAside` no longer covers Get ready.
- Birth plan: the note, "Your plan, as you left it.", the summary ask hidden. Baby names: the note behind `afterLossNote: true` (Pregnancy callers only); the "Begin her story" card steps aside after a loss outside Parenting.

**Tests:** `preg_birth_prep_test.dart` (18), `preg_birth_prep_bag_checklist_test.dart` (22), `preg_birth_prep_contractions_test.dart` (36), `preg_contraction_schema_contract_test.dart` (6); `after_loss_tabs_test.dart` flipped (Birth plan found after a loss); `preg_tools_shell_test.dart` reads the names flag. Docs: BACKEND-PATTERNS 16zze.

**Left, said plainly**
- **Store:** 12 of the 24 old seed products are `soldHere`, so their store page still shows seed prices and the in-app cart (preview checkout). Store terminal: map them to sheet products or ASINs, or mark them not sold here. Bag items carry no product id, so they always reach a search.
- The timer's history, summary and detail screens keep their own back and title; the move onto `PregToolScaffold` is owed (C1 row).
- A past birth not on her profile reads as a first baby (the slower rule).
- New safety lines show in English in the Hindi build (new work is English).
- Ask Veda sees the new shopping list entry and the renamed tools after the next corpus export and ingest (user).
- BEFORE-LAUNCH lines and the sync-log step are written as ready text (BEFORE-LAUNCH is held by the Community terminal; the sync files on the user's word).

**Hand-over to Terminal A:** `pv_door_router.dart:504` should pass `BabyNamingHomeScreen(afterLossNote: true)`; the Labour tile "What to pack for whoever comes with you" should open `ReadyForBirthScreen(initialCategory: 'partner')`; "Contraction Tracker" at `pv_door_labour.dart:305, 394`; the "Shop the list" blurb; after-loss hero lines on the Labour and Getting ready doors.

## Added on the user's word (2026-10-28): no invented products, the sheet is the source of truth
**Why the seed was still showing.** The store has three layers: the 47 hand-written demo products (24 Pregnancy, 23 Parenting; invented names, seed prices and reviews, 12 wired to the in-app "sold here" cart), the team's sheet shortlist (654, ids `pvs_`/`pvt_`), and the live rows (410; 349 land on sheet ids, 61 new books). The importer lays live rows over what exists by id, and the seed ids exist nowhere else, so no real link ever replaced them; the 2026-10-13 decision was "nothing removed". The user: "no need to have fake situations in the app... show whatever we have", and "consider the sheet the source of truth".

**As built**
- `buildPvCatalog` leaves the seed out unless `PV_SEED_PRODUCTS` (a demo build); `kPvRetiredSeedIds`, `pvSeedGenericName`. A retired id opens the "no longer listed" page; the cart drops retired lines with a toast saying why; an empty shelf says "Nothing on this shelf yet" instead of "Nothing matches those filters". The 10 TTC products (real brands, linked) stay. `store_catalogue_index.json` regenerated without the seed.
- **Coming soon** (`pv_coming_soon.dart`, ids `pvsoon_`): one card per essential the sheet lacks: Belly support band, Maternity wear (Pregnancy); White-noise machine, Sleep sack, Blackout curtains, Nappy rash cream, Baby wash, Weaning spoons and bowls, Baby-proofing, Baby first-aid kit, Stroller (Parenting). No brand, price, photo or link; an ink-outline "Coming soon" pill and "We're choosing the ones we'd recommend. Coming soon."; last on its shelf, off every For-you rail and the compare tray; `pvPlaceComingSoon` removes it as soon as a real product lands on its shelf. Deliberately none for feeding bottles and sterilisers (IMS Act) or baby lotion (NHS, first month).
- Product checklist: starters are named items ("Nursing bras", "Breast pump"…) that search the real store; a saved seed item shows its plain group name, keeping its tick, note and bought state; the "Add products" picker lists the live store.
- Readers routed off the seed: global search's product rows (now the live store), `ppProductRow`, Parenting Ask Veda, Parenting Veda, recipe and reco pages, the leap page, the home-B carousel, the Parenting compare and home products. Dead readers listed in the build notes, not edited.
- Tests: `store_no_seed_products_test.dart` (16); nine store and Parenting tests updated with the old expectation kept as a comment.

**Owed to the sheet (Store terminal / the team):** real products for the eleven Coming soon cards. Shelves with no real product today: maternity_wear, belly_band (Pregnancy); sleep, skincare, feeding, health_and_safety, on_the_move (Parenting). The Ask Veda service corpus may still hold seed products (service-side clean-up), and if `tool/export_content_seed.dart` was ever run the 23 Parenting seed rows are still in Supabase `products`.

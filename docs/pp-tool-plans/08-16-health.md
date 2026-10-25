# Tools 08-16: the Health family

## Context
This is part of the parenting tools pass (`docs/pp-tool-plans/00-MASTER.md`). Tools 01-07 are committed (b11b2ec, 953df86). The user: "start the health family do it well, try not to miss out on anything", "use mobbin wherever u can", plus the standing rule that a tool is only done when its backend works and syncs. On approval, this plan is copied to `docs/pp-tool-plans/08-16-health.md`.

Tools: Growth (`pp_growth`), Vaccines (`pp_vaccines`), Fever check (`pp_fever_check`), Is my baby OK? (`pp_baby_ok_check`), Something changed? (`pp_what_changed`), Health record (`pp_health_home`), Emergency card (`pp_emergency_card`), Before you see the doctor (`pp_doctor_visit`), Home remedies (`pp_nuskhe`).

## Mobbin pass (2026-10-25)
| Tool | Reference | Adopt | Decline |
|---|---|---|---|
| Growth | WHOOP expected-trend band https://mobbin.com/screens/188ae856-de7f-4d26-ada7-2cf8076619b1 ; Withings latest cards https://mobbin.com/screens/b942b2ea-6f01-4105-a011-35670244dbc0 ; Future "Most recent / vs previous" https://mobbin.com/screens/4d96c3e9-c7b8-4266-b086-ad92ec6c3c07 ; Alma entries list + add https://mobbin.com/screens/f28eba19-4f70-46e3-aa06-78501c448430 | The WHO range drawn as a band, with her line inside it (a range, not a target). A "vs last measurement" stat. Every entry editable in a list | Target weights; "kg down this week" praise |
| Vaccines | Clue "Not sure" on the dose date https://mobbin.com/screens/9715580e-d259-4478-8b41-86b5b3b6b570 ; Runna checked weeks https://mobbin.com/screens/9eb278de-d059-4726-b181-8ec7d161ba4c ; Oura "Last dose due" https://mobbin.com/screens/0ee3693e-7720-4f50-88c8-9b297f130409 | A "Not sure of the date" option when ticking a dose. Done/due as a tick timeline. A "Next due" line on top | — |
| Fever / Is my baby OK? / Something changed? | Amazon "When to seek medical attention" https://mobbin.com/screens/03923f9c-d4ca-4f22-8f3d-330e9b2c3ed6 | Steps first, then a fixed "When to call the doctor" list | Noom / Hers / Me+ risk % and severity labels (a personalised probability and a diagnosis: both forbidden by CLAUDE.md) |
| Emergency card | Apple Medical ID https://mobbin.com/screens/1479525a-75f2-4ccb-96be-16401790f39b ; Alan card + share https://mobbin.com/screens/c897178e-fdda-42d4-afe7-b7876aea0150 ; GoodRx call rows https://mobbin.com/screens/82401333-b866-4a60-870d-92895d265613 | Add/Edit on each field, "Updated <date>", a share button, call rows | — |
| Before you see the doctor | Zocdoc "How to prepare" https://mobbin.com/screens/10df4178-4470-47a9-bcfb-46a889b90455 ; Fitbit report preview then share https://mobbin.com/screens/8320e86e-b6cc-4873-8670-b75b8f064420 | A summary pre-filled from what the app knows, previewed, then shared as WhatsApp text (like The last 7 days) | A paid PDF report |
| Health record | CVS rows https://mobbin.com/screens/b1b9424e-b0c0-422a-a509-69e0cfc1e34e ; Google Health "No data" per category https://mobbin.com/screens/948430d4-5cfb-4065-b61f-d6deb95fbfb4 ; Bevel filter chips https://mobbin.com/screens/612cbdbc-bc45-4e57-942f-96f2b4741841 | Plain rows, each with a count or "Nothing yet, add one". Records filtered by chips. Never hidden | Biomarker grades |
| Home remedies | Bevel status pill per row https://mobbin.com/screens/835e4655-10f5-4469-8851-fa6c6c53f43d | One verdict pill per remedy (Helps / Harmless / Avoid), with age gates | Scores / ratings |

## Audit (three read-only audits, key claims checked against the code)
| Tool | Broken / Wrong (summary) |
|---|---|
| **Growth** | **Broken:** reads blend twins (`GrowthStore.all` unfiltered); `add()` writes the newest weight onto the active child's profile, so it can be the other twin's. **Wrong:** the screen doesn't redraw on a child switch; no range checks (3400 typed as kg → "above 97th centile"); no save toast, no edit, delete without undo; a silent `onTap: () {}` on history rows (`growth_journey_screen.dart:193`); "his curve" hard-coded for girls; no corrected age; percentile clamped to 5-95 while the copy says "below 3rd" |
| **Vaccines** | **Broken:** `_done/_reminders/_givenOn/_reminderAt` aren't child-keyed, so B shows A's ticks, and on resume A's doses upload as B's. **Wrong:** alarm id = `visitId.hashCode`, so twins' reminders collide. No toast on a schedule change; the door says "IAP" but UIP is offered; nudges only for the active child |
| **Emergency card** | **Broken:** one `_emergency` for the family; `_pullEmergency` labels the local card with the new child's id, so A's card can upload as B's; allergies/meds come from unfiltered lists; an empty name fails silently. **Wrong:** typed allergies/meds never show on the card; no toasts or undo; birth date and weight are free text, drifting from the profile and growth |
| **Fever check** | **Wrong:** a low reading over 3 months says "not a fever"; "Below 36.5" is last in the list; 112/108 isn't pinned; not on the shell. **Contradicts "Something changed?" › fever in 5 cases** (e.g. 2 months at 37.2: one says fine, one says urgent), and a test locks one of them in |
| **Is my baby OK?** | It's really a newborn feeding check (wet nappies, feeds, jaundice, weight), sold as "A symptom" and opened by the home "Check a symptom" button and a Recipes link at every age. It never reads age, and doesn't use `wet24h`/`countLast24h` |
| **Something changed?** | **Wrong:** asks "Roughly how old?" though the app knows; saves and syncs every result (even urgent fever) and shows it on home for 3 weeks without consent; diagnosis wording ("MOST LIKELY CAUSE", "an ear infection is likely"); no REQUIRED_REVIEW; the urgent result gives no number |
| **Health record** | **Broken:** `HealthStore` lists (meds, allergies, symptoms, reports, visits, questions) and `BabyDocumentsStore` blend children. **Wrong:** the Health guide invents history ("Last winter X caught a cough… forecast next week"); record deletes have no undo |
| **Before you see the doctor** | **Broken:** the share button Row overflows at 360dp (`health_doctor_visit_screen.dart:169`, label not Flexible). **Wrong:** old purple kit, not on the shell; promises "notes" it doesn't have; back label always "Health"; no visible disclaimer; misses the last 7 days and active changes; growth shown without the `growthEntered` guard |
| **Home remedies** | **Wrong:** a remedy with no warning is labelled **"Vaidya-approved"** (`pp_nuskhe_data.dart:105`), a false endorsement; the hing and mustard-oil+garlic rubs show green "gentle" for young babies; honey is shown to under-1 parents; no avoid list (ghutti, kajal, oil in ears/nose, gripe water); blurbs promise "helps / only comforts / not safe" verdicts the data doesn't have; Related/video taps are "Coming soon" with no next step |

## Decisions (user, 2026-10-25)
| # | Question | Recommended | User's answer |
|---|---|---|---|
| H1 | Fever check vs "Something changed?" › fever | One fever answer | **One fever answer** |
| H2 | "Is my baby OK?" | Rename, newborns only | **"shouldnt it be a whole symptom tool? tht cover child of all ages ... tht tools auto detects the baby from the known data in app"** → ONE symptom tool for every age (below) |
| H3 | "Something changed?" saving without asking | Ask once | **Ask once, like feeds** |
| H4 | Health record tiles | Keep as the records home, rows with live status | **Keep as the records home** |
| H5 | Remedies | Honest verdicts + avoid list | **Honest verdicts + avoid list** |
| H6 | Corrected age on growth to age 2 | Yes | **Yes** |
| H7 | Emergency card data | One source | **One source** |

## Build, in three waves (each wave ends green, with the backend closed)

### Wave 1: every health store follows the child (Broken → fixed; backend)
- `GrowthStore`: `all`/`chronological`/`isEmpty`/`hasHead`/length checks go through `_sync.belongsTo(x.id, _childId)`; `add()` writes to the profile only when the measurement is the active child's newest.
- `VaxStore`: state keyed `<childId>|<visitId>` (helper `_k(visit)`); getters read the active child's keys; `_rowsFor(child)` sends only that child's keys; alarm id from `'$childId|$visitId'.hashCode`; reminders armed for every child (not only the active one), each labelled with the child's name.
- `HealthStore`: list getters filtered by `belongsTo`; `_emergency` becomes `Map<String, EmergencyProfile>` by child id, with `emergency` returning the active child's; `_pullEmergency(child)` passes only that child's card. `BabyDocumentsStore`: same filter.
- Child switch: these stores listen to `ChildProfileStore` and re-pull the newly active child (`_syncFromCloud`) instead of waiting for app resume. Screens merge `ChildProfileStore` into their listenables.
- Backend: no migration (the tables are already child-scoped; only the phone-side state was not). Sync log step 16, STILL-OPEN-BACKEND row 16, BACKEND-PATTERNS §16mm "a single-value or set store per child: key the local state the way the table is keyed, and never label a local row with a child at pull time".
- Tests `test/pp_health_tools_test.dart`: two children for growth, vaccines (ticks + dates + alarm ids), the emergency card, allergies/meds, documents; plus pull-labelling (A's card not pushed as B's).

### Wave 2: one symptom tool, one fever answer, ask once (H1, H2, H3)
- **"Is my baby OK?" becomes the one symptom and change checker for every age**, built on the "Something changed?" engine (`what_changed_screen.dart`, `kWcConcerns`, 30 concerns in 9 areas). Tools tab: one row "Is my baby OK?" (`pp_baby_ok_check`). "Something changed?" is retired as a separate row, and `pp_what_changed` plus `pp_what_changed/<entry>` stay as router aliases into the same screen, so every door and link still lands (doors keep their labels; their rename goes to the doors pass).
- **It knows the baby:** the "Roughly how old?" questions are answered from the profile (corrected age where one exists) and skipped. Concerns gain `fromMonths`/`toMonths`, and the ones that fit the child's age are listed first; the rest sit under "Other ages", shown, not hidden. Name and pronoun come from the profile.
- **Newborn feeding signs move in** as Feeding concerns for 0-3 months (wet nappies, feeds, yellow skin, weight back to birth weight), using today's `PpBabyOkCheckScreen` checks and thresholds (REQUIRED_REVIEW kept). Feeds in 24 h and wet nappies in 24 h are pre-filled from `FeedingStore.countLast24h` / `NappyStore.wet24h` with "From your log, change if not right", **only if** feeds/nappies consent is yes (new `PpUseKind.nappies`); otherwise she answers. The old screen stays, commented "kept for revert".
- **Two concerns added: Vomiting and Cough or breathing**, written in the house format with conservative go-now signs from the shared `kPpGoNowSigns`, marked REQUIRED_REVIEW and added to BEFORE-LAUNCH's clinical review.
- **One fever answer (H1):** picking fever ("feels warm / fever") hands over to `PpFeverCheckScreen`, which becomes the only fever judge. The `low_fever` rules are commented out (kept for revert) and the test that locked the contradiction is updated. Fever check fixes: a low-reading branch over 3 months; "Below 36.5 °C" first; 112/108 pinned at the top; moves onto `PregToolScaffold` (off `_owedShell`); "seen today" vs coded "now" aligned. Answer-branch tests for every route.
- **Clinical wording:** "MOST LIKELY CAUSE" → "What it often is"; "is likely" → "can be"; the file header loses "diagnostic"; REQUIRED_REVIEW on every result; the urgent result names 112 / 108.
- **Ask once (H3):** `PpUseKind.changes` ("What you tell Is my baby OK?"). The ask card shows on the first result. A no means the check works but nothing is kept or shown on home. Existing saved changes stay. Relevance reads changes only with a yes.
- Home "Check a symptom" (`pp_age_page_parts.dart:284`) and the Recipes under-6-months row (`pp_recipes_screen.dart:676`) now land on the unified tool (Recipes lands on Feeding). Tools tab blurb: "Sleep, feeding, illness or mood: checked calmly, and when to call."

### Wave 3: each tool's own UX (Mobbin above)
- **Growth:** range checks (weight 0.3-40 kg, length 30-130 cm, head 25-60 cm) with a calm "That looks like grams, did you mean 3.4 kg?"; save toast; tap a row to edit; delete with undo; pronoun from the profile; full "~Nth percentile" and no clamp under a flag; corrected age to 24 months with a line saying so (H6); "vs last measurement" stat; the add sheet off the old kit.
- **Vaccines:** "Not sure of the date" when ticking (ticked, no date); toast on a schedule change; a "Next due" line on top; the door blurb says IAP or UIP.
- **Emergency card (H7):** allergies and medicines read from the child's health record, birth date from the profile, weight from the latest growth entry (editor fields for those become "Edit in the health record" links); an empty name shows a toast; save/delete toasts with undo; "Updated <date>"; Share; editor off the old kit.
- **Health record (H4):** tiles become rows with live status ("2 vaccines due", "Nothing yet, add one"); the Health guide's invented history and forecast lines are commented out; record deletes get undo.
- **Before you see the doctor:** overflow fixed (Flexible label); onto `PregToolScaffold` (off `_owedShell`); adds "The last 7 days" (`PpCareHistory`) and active changes (with the changes yes); a visible "not a diagnosis" line; symptoms sorted by date; undo on question delete; correct back label; Tools tab line "Questions and a summary to share"; "QUESTIONS TO ASK" hidden when empty.
- **Home remedies (H5):** `NuskheVerdict { helps, comfort, avoid }` on each remedy; avoid entries (ghutti/janam ghutti, kajal/surma, oil in ears or nose, gripe water, honey under 1); hing and the mustard-oil+garlic rub become caution, and the potli's burn warning shows in the list; honey/age-gated remedies show "Not for <name> yet" when the child is younger (shown, not hidden); "Vaidya-approved" → "Not yet reviewed by a doctor"; blurbs match the data; "Coming soon" taps toast with a next step (S8). All verdicts REQUIRED_REVIEW, and listed in BEFORE-LAUNCH.

## Files (main)
Stores: `pp_growth_data.dart`, `pp_vaccine_data.dart`, `pp_health_data.dart`, `pp_documents_data.dart`, `pp_what_changed_data.dart`, `pp_changes_store.dart`, `pp_nuskhe_data.dart`, `lib/services/pp_use_consent.dart`. Screens: `growth_journey_screen.dart`, `pp_vax_tracker_screen.dart`, `wallet_v2_screens.dart`, `health_emergency_screen.dart`, `pp_fever_check_screen.dart`, `what_changed_screen.dart`, `pp_baby_ok_check_screen.dart`, `health_home_screen.dart`, `health_guide_screen.dart`, `health_records_screen.dart`, `health_doctor_visit_screen.dart`, `nuskhe_screen.dart`, `remedy_detail_screen.dart`, `pp_tools_tab.dart`, `pp_surface_router.dart`, `pp_age_page_parts.dart`, `pp_recipes_screen.dart`, `pp_relevance.dart`. Tests: new `test/pp_health_tools_test.dart`, `test/pp_symptom_tool_test.dart`; updated `post_pregnancy_tools_flow_test.dart`, `pp_tools_one_look_test.dart` (`_owedShell` loses fever + doctor visit). Docs: `docs/pp-tool-plans/08-16-health.md`, README, BACKEND-PATTERNS §16mm, sync log step 16, STILL-OPEN-BACKEND row 16, BEFORE-LAUNCH (clinical review of the new concerns, fever thresholds, remedy verdicts).

## Verification
- After each wave: `flutter analyze` on the touched files, and the new tests plus the neighbouring suites (health door, wallet, emergency card, vaccine schedule, growth tools, what changed / wave8, tools tab, one look, relevance, care logs, sync guard, merge).
- Wiring gate: grep every route into the unified tool (Tools tab, doors, home sheet, Recipes, content PpLinks) and every `PpUseConsent.allows(` reader.
- A phone walk only on the user's word.

## Built (2026-10-25)
- **Wave 1 (every store follows the child)** landed through the other terminal's STAGE-TRANSITIONS B11 (`c70a791`, sync step 16, BACKEND-PATTERNS §16mm). That commit filters reads per child for growth, documents, health records, milestones and vaccines; keeps one emergency card per child; pulls every child; keeps twins' alarm ids apart; and redraws on a child switch. Checked against this plan's Wave 1 list: nothing is missing.
- **Wave 2 (one symptom tool, one fever answer, ask once)**
  - **"Is my baby OK?" is the one checker for every age.** It's built on the `kWcConcerns` engine with one Tools row (surface `pp_what_changed`). `pp_baby_ok_check` and `pp_what_changed` open it; the newborn check moved to `pp_newborn_feeding`.
  - **It knows the age:** `kWcAgeFit` puts concerns that fit first and the rest under "Other ages"; `kWcAgeAnswer` fills in the age questions; it uses corrected age (`devAgeInMonths`).
  - **Three new concerns:** Getting enough milk? (0-3 months, hands over to the newborn check), Vomiting, and A cough, all REQUIRED_REVIEW.
  - **Fever hands over to Fever check** (`kWcHandOff`). The old `low_fever` rules are kept for revert under another key, and the contradiction test was rewritten.
  - **Fever check:** now on the shell, with 112/108 pinned, a low-reading branch over 3 months, the low band first, bands that don't overlap, the headline matching its urgency, and pronouns from the child.
  - **Wording is never a diagnosis:** "What it often is", "See what it might be", "can be", and urgent results name 112 / 108.
  - **Ask once:** new consent kinds `changes` and `nappies`. `PpChangesStore.active()` returns nothing without a yes, which covers home and relevance in one place. The result shows the ask card; a no keeps nothing. The newborn check reads feed and nappy counts only after a yes, and only ever picks the reassuring answer.
  - **Routes now land right:** the home "When to call the doctor" sheet and the "Something changed?" row open the one tool; Recipes' under-6-months unwell row opens it on illness, tummy and feeding; First 40's links open the newborn check.
- **Wave 3 (each tool's UX)**
  - **Growth:** range checks with a grams hint, save toast, tap a row to edit (`GrowthStore.update`, keeps the id), delete with Undo, the girl's pronouns, "below 5th / above 95th" instead of a clamp, and corrected age to 24 months (`GrowthStore.ageFor`, used by the chart, the rows and every insight) with a line saying so; the add sheet is off the old kit.
  - **Vaccines:** "Not sure of the date", a schedule-change toast, and a "Next due" line.
  - **Emergency card:** one source (`walletDob/Weight/Allergies/Medicines` in `pp_wallet_data.dart`) for the card, the QR text, the editor and the shared text; the editor's four duplicate fields are commented out with a line explaining where they come from; an empty name shows a toast; save shows a toast, and delete shows Undo.
  - **Health record:** live status rows. The Health guide's invented history, forecast and doctor are commented out; record deletes have Undo.
  - **Before you see the doctor:** overflow fixed, on the shell, the last 7 days included, a visible not-a-diagnosis line, symptoms newest first, Undo on question delete, the Tools tab line "Questions and a summary to share".
  - **Home remedies:** `NuskheVerdict` pills on the remedy screens and the list screen; "Vaidya-approved" changed to "Not yet reviewed by a doctor"; hing and the garlic rub now caution; the potli burn warning shows in the list; five avoid entries and a "Not safe for babies" section; "Not for <name> yet" shown, not hidden; Coming soon taps say why and what to do next.

## Verified
- New: `test/pp_symptom_tool_test.dart` (12) and `test/pp_health_screens_tool_test.dart` (helper). Updated: `post_pregnancy_tools_flow_test` (the contradiction), `pp_what_changed_flow_look_test` (red flag on vomiting), `pp_wave8_test` (yes first), `pp_care_screens_test` (renamed check, yes first), `post_pregnancy_growth_tools_test` (the Log sleep button b11b2ec renamed: my earlier miss), `pp_tools_one_look_test` (fever and doctor visit off `_owedShell`).
- **44 suites, 665 tests pass.** Analyze is clean on every touched file.

## Found, not in this scope (recorded)
- `article_reader_screen.dart` says "Reviewed by our medical panel" three times, and no panel has reviewed anything: a false endorsement, like "Vaidya-approved". Added to BEFORE-LAUNCH.
- `kDefaultPanel` and two named BAMS panels still sit in `pp_nuskhe_data.dart`. They aren't shown (the byline is commented out), but they are names of reviewers who haven't reviewed. Remove them before the data is ever shown.
- Doors still say "Something has changed" / "Something suddenly different" for the same tool. That rename belongs to the doors pass.
- The emergency editor sheet still uses the old kit's colours (Polish).


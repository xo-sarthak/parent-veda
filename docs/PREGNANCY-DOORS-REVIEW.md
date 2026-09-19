# Pregnancy doors — the door-to-door review

Started 2026-09-18 evening. The user's brief, in his words: *"go door to
door and fix every screen… each and every click till the end, like a
recursive tree… analyse and fix, using the Mobbin MCP constantly."* Each
door is walked from the V3 home tile to every leaf, on the phone, release
build, and every tap is judged on three things — does it look like the base
UI (DESIGN-SYSTEM §4.0), does it answer (§4.0c), and does it say something
once (declutter: one home per fact, comment out the second).

**The rules that came out of the first door** (they apply to every door after
it, and they are in DESIGN-SYSTEM §4.0 now):

1. **No text on a tinted box.** Not a pink well for red flags, not a
   lavender panel for a callout, not a tinted row when a checklist item is
   ticked. A warning is a rule, a heading in the display face, the lines
   with one coral dot each (Flo's own form). A note is an icon and a grey
   line. The rounded tinted rectangle is gone from the vocabulary.
2. **One home per fact.** If a tool repeats what the tab above it says, the
   tool goes (commented, kept). If a library has its own search bar and the
   door has one, the library's goes and the door's index reaches its
   contents.
3. **A list is rows, not cards.** `PvDoorRow` is the compact row — neutral
   well, bold title, one grey line, chevron, hairline — the same object as a
   search result.
4. **Pickers are inline.** A date is a month grid inside the sheet, a time
   is a row of slots. No dialog on a sheet.
5. **The Prepare kit is ink.** `prepare_common.dart` keeps its names and
   loses its violet; fourteen screens follow.
6. **Spacing and separation, every screen.** The user (2026-09-19): "keep
   looking for random spacing issues… segregation and separation of
   sections and headings." On every walk: eyebrow → 6–8pt → content;
   between sections 18–26pt, never less than the gap inside one; a heading
   sits closer to what it heads than to what came before; a grid or list
   has no stray inset of its own (`padding: EdgeInsets.zero` on a nested
   GridView); the last thing on a page clears the floating Ask button.

---

## 1. Scans & tests — WALKED AND FIXED 2026-09-18/19

Tree: home tile → door (rail: My scans · Understand a scan · Understand a
result · My reports · Talk) → each tab's inline tool and section tiles →
each tile's screen.

| Where | Was | Now |
|---|---|---|
| Door hero | — | `PvSearchBar` under the blurb (§4.0e) |
| My scans · timeline | Up-next card + run (already redrawn) | "Add the date" opens **a sheet**: month grid inline, time slots, place; saves a real `Appointment` (type scan) the card, the run row, the read and the Calendar all read. "Edit the date" / Remove. The note field is white + hairline. |
| My scans · "What is next" section | tool `ScanNextScreen` — "the one you have done", "what follows", appointments — a screen deeper, smaller type, tinted callout | **Retired** (commented in `pv_door_scans.dart`). The timeline is what is next. |
| "Your appointments" → `ScansAppointmentsScreen` | the old roadmap with a heart, every scan listed again | **Unreachable from the door** (import commented; the sheet replaces it) |
| Understand a scan · the 9 scan reads | 4 short sections, "1 min" | + **"What the report will say"** (the scan's parameters as one data card — `ScanParametersView`) + **"How to read the result"** (interpretation + pointers). Long ranges take their own line. |
| My reports · "Your report, line by line" (`TestsScansReportsScreen`) | a separate violet library of the same parameters | **Retired** from the door and from the reads' next steps; parameters live in each read |
| Understand a result (`ReportScreen` embedded) | its own search bar; violet filter pills; card list with Fraunces titles and "Article" capsules; lavender empty-state box | no inner bar (the door's index has every finding **and every parameter**); ink pills that press; `PvDoorRow` compact rows; white empty box, ink link |
| Talk · "Call your doctor if" | pink well, radius 20, "See all of these" → `ScanUrgentScreen` repeating the seven lines | rule · display heading · coral dots · the "call, do not message" line as the foot; no link, no box (`seeAll: false`) |
| Talk · two sections of one tile each | | one section, "Before your appointment", two cards |
| Checklist (`PvChecklistScreen`) | bordered cards that fill with tint when ticked | hairline rows, ink box, bold when ticked |
| Consults (`ConsultationsScreen`) | violet icons, violet Book, lavender "after your 30-week scan" banner (wrong week) | Prepare kit inked; banner gone |
| Reader (all reads) | urgent callout in a lavender panel; violet bullet dots | rule + display heading + coral-dot list; ink dots |
| Theme | violet caret/handles/selection; lavender picker surface; violet Cancel/OK | ink `textSelectionTheme`, ink `datePickerTheme` / `timePickerTheme`, ink text buttons |

**The user's review round (2026-09-19), and what it changed:**

| He said | Done |
|---|---|
| Time-slot pill text not centred | fixed height, centred label |
| "Article" on the Ask Veda card is misleading | `PvNextKind.ask` — the chip says ASK VEDA; the look-up says TOOL |
| The decoder's header and the consult header are "not from the same app"; the checklist's hero header is the one to use | `PvDoorToolScaffold` on the decoder (standalone), consults, the report viewer and the edit screen — every leaf of a door wears the same hero |
| "A word on the report you do not know" reopens the same list — "repetitive and useless"; the list grows forever | tile retired; "More topics · 21" folds (open when a report chip is on), `AnimatedSize` |
| The locker's add looks like a tool; purple icons on the attach sheet; fonts differ sheet to sheet; the viewer's purple pill, pencil screen, PDF chrome | "+ Add a report" hairline row under the list; attach sheet in the display face with ink icons and presses; viewer and edit screen on the tool header, ink chips, plain note, file card white, PDF on the ground with no action bar; a toast when a report lands; trash off the row (delete lives in the viewer) |
| "Prepare" + EN·हिं at the top of consults | gone — the tool header's back circle |
| Search should be scoped to the door | it is — "In Scans & tests" is the default, Everywhere the toggle |

**The second review round (2026-09-19 afternoon):**

| He said | Done |
|---|---|
| The list is monotonous — the same icon on every scan; use pictures | every written row carries the read's photo (`pvDoorTileReadImageId` reaches `scan_<id>`, `finding_<id>`, `condition_<id>`); nine scan photos added; a scan read opens with its photo too. Findings and conditions still fall back to the format well until they get photos (owed) |
| "Before any scan" is at the bottom; relevant but not always | Bluesky/Shopify's "Getting started" strip: a slim "Before any scan · 3 to read first ›" row ABOVE the trimester lists with an ✕; dismissed once (`PvDoorStripStore`), it lives folded at the end (`PvDoorSection.strip`, `.folded`) |
| FAQ should open smoothly, "a tab should feel like a tab" | `AnimatedSize` on the answer, the + turns 45°, the tap hums |
| The locker will clutter; the articles under it sink; a report page wastes space; no time on files; the note looks empty; no way to add more files; the sheet line looks purple; the disabled Save is purple; no share/download | add row FIRST; rows under month headings; the newest five, then "All reports · N ›" → `ScanReportsAllScreen` (search, scan pills); the report page = details block (report date · added with time · scan) + a NOTE block that is never empty + a 3-across files grid (one file = one square) + Edit / Remove pills; Edit details gains "Add more files"; Share in both viewers' top bars (files are already in Supabase Storage when signed in — `resolve()` fetches them on another phone); the sheet line in `ppSoft`; disabled pills grey |
| Onboarding's due-date picker is the old Material dialog | `showPvDateSheet` (`lib/widgets/pv_date_sheet.dart`) — the inline month grid, shared with the scan timeline; onboarding eyebrows in ink, "Good to know" un-boxed, the reminders switch in ink |

**Round three (2026-09-19 evening):** "Before any scan" back to a plain
section at the end (the user: "it was better before"; `folded`/`strip`
stay on the model); the myth tile reaches its photo; photos on all 27
findings and 20 conditions (tone placeholders from the CC0 pool — a photo
per finding is a content job); contents, references and FAQ all unfold
with motion and hum; the locker's time in 12-hour; the "Next: today 6pm"
pill off the consult list; **the one doctor page** (STILL-OPEN §63.16).
**My reports — option A, chosen:** the tab is an entry — "+ Add a report"
and "Your reports · N" with the last-added line — and the list, search,
scan pills, month groups and add all live in `ScanReportsAllScreen`. The
two articles stay in view at any count. (B added the newest one on the
tab; C was the capped list. Mobbin: Superpower, Fi, Apple Health, Claude's
"1 file" pill — none puts records on a page about something else.) An
unnamed report is "Report · 19 Sep". The decoder's and Complications'
rows carry their photos (`PvDoorRow.imageUrl`). Reviews' stars are drawn
icons in ink. The Prepare confirm/success sheet is the base UI (shared by
every Prepare booking, so the course and masterclass tails pick it up).

**Round four — the foot.** The user: "so much white space at the bottom
of every scroll." Two causes, both in the door sheet: a full-viewport
minimum height (written for the old tinted field; the ground is white
now, so it bought nothing) and a 234pt foot inset (the FAB's RAISED
reserve, for the Today tab's dev pill). With the Ask Veda FAB off for
now (`FabState.kAskFabEnabled`, the user's call pending the FAB
discussion) the foot is 24pt on both door families. The one violet left
on the door — the Up-next eyebrow — is ink.

**Mobbin, this round:** Bluesky / Shopify (getting-started strip) · Fi / Apple Health (records under date headings, flat) · Superpower (the full records screen: search + filter) · Visible (a Note block with Edit inline) · Careem / Booking / Craft / Dropbox (files as a grid of squares) · GoodRx (specific list, then "Related · N").

**Mobbin, this door:** Flo "seek immediate medical help if" (the warning
form) · GoodRx / Apple Health / CVS (list rows) · Rodeo / Todoist / Alta /
Freenow (inline month grid) · Instacart / Agoda / Future Pro (time as
slots) · Withings / Reminders (checklist rows) · Zocdoc / Fresha / Alan
(specialist rows) · **Fi's document flow** (add pill under the list, a
completion toast, edit as a sheet, no delete on the row) · Docusign /
Superpower (the add as a hairline box; upload from the top).

**Still owed on this door:**
- The consult's booking flow below the list (`ConsultationDetailScreen` →
  `lib/booking/`) is shared with the doctors terminal — not touched.
- The locker's viewer/naming sheet (`ScanReportsBody`) not walked with a
  real report added.
- `ScanUrgentScreen`, `ScanNextScreen`, `ScansAppointmentsScreen`,
  `TestsScansReportsScreen` are alive by route for revert; delete after a
  release or two.
- The rail-vs-tiles choice for the other doors (this door has the rail).

## 2. Complications — WALKED AND FIXED 2026-09-19 (phone check owed: it dozed mid-walk)

Tree: home tile → door (tiles: Find a condition · When it comes up · Get
help now · Living with it · Talk) → 15 condition reads, 6 guides, the
checklist, consults.

| Where | Was | Now |
|---|---|---|
| Find a condition | a gate question ("has your doctor mentioned a condition, or do you just want to learn?"), then a lavender "Just exploring · change" pill, then a second search bar, then the list | the list. The gate is off (derive, never ask); the door's bar indexes every condition |
| Condition read · "Add to my journey" | shown only behind the "diagnosed" answer | on every page — and **adding asks first** (a sheet: "only if your doctor has said you have it… Ask Veda will answer with it in mind"). One tap cannot add; removing is one tap. The guard test moved from the door to the tap |
| When it comes up · three rails of "Article" cards | | **a list** — this is the new door-wide rule: a section whose tiles are all written draws as rows with the read's photo (or the format well); a mixed section keeps the rail. `_ArticleList`, `pvDoorTileIsWritten`. Mobbin: Equinox, Alan, Gentler Streak, Liven, Tonal list same-kind articles; Clue, Atoms rail mixed content |
| Get help now | five signs + "See all of these" → a screen with the same five | `seeAll: false` — every line already opens its condition |
| Living with it · "Keep track of it" | "Add a condition to my journey" (opened the Find list as a screen) · "Keep your reports for this" (opened the Scans locker) | **retired** — both are a tap away in their own homes |
| Talk | the seven-line pregnancy flag again (one tab after Get help now's five); two sections of one card | no second flag; one section, two cards |

**Mobbin, this door:** the article-list pass above.

**Still owed:** the phone walk of the built state (the device dozed);
the 15 condition reads not read one by one for thinness.

## 3. Is it safe? — next

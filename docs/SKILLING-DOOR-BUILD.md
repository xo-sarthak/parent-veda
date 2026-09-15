# Building a skilling door — the playbook

**Read this before building one of the twelve skill briefs.** Everything
here was settled while building the first, **Coding & AI literacy**, from
`ParentVeda_Coding_structure_v2.pdf` (11 Sep 2026), on 2026-09-14. It is
the sibling of `docs/PREGNANCY-DOOR-BUILD.md` and `docs/PP-SECTION-PATTERN.md`;
those are still right about what all three door engines share (the shell's
geometry, the wiring gate, "a feature is never hidden", comment-out-never-
delete), and this one does not repeat them.

**This file also holds the GENERIC open points of the skilling doors** — the
calls that apply to every door rather than to one. The user's instruction
(2026-09-14): door-specific points go to `STILL-OPEN.md` as a numbered
section; points generic to the doors of skilling live here, in §9. Content
owed goes to `DOOR-CONTENT-OWED.md`, under its Skilling heading.

---

## 0. What a skill door is, and how it differs from the other two

A pregnancy door is a landing over tiles the door file declares. A parenting
door is a shell over a section's areas. **A skill door is a shell over a
`SkDoorContent`** — a typed record with named slots (lesson sets, an activity
set per band, a cross-band set, a parent note, a course shelf, a product
shelf) — and its five tabs are the **brief's five child surfaces**, the same
five on every door:

| Tab kind (`SkTabKind`) | The brief's surface | What the screen draws |
|---|---|---|
| `today` | Today's thing to try | one rail, the day's activity pinned first |
| `activities` | Things to do | one rail per thinking skill, her band's activities |
| `lessons` | Unplugged / block / project lessons | one rail per lesson set in her band |
| `crossBand` | AI, explained for her age | the cross-band set, her band's cards |
| `keepsake` | What I've made and tried | a Keepsake card that opens the tracker |

The four **parent surfaces** — set up and consent, the course shelf, the
product shelf, the parent note — are not tabs. They live on one screen
(`SkGrownUpScreen`) behind the grown-up gate, reached from the closing card
under every tab. That is the brief's split ("the learning screens speak to
the child; everything around them sits behind the parent") made structural.

So a new door is **content, not engineering**: a `SkDoorContent` from four
data files, and an `SkDoor` that picks labels, icons, hues and a photo. The
door file cannot invent a sixth surface; `SkTabKind.pages` (a rail of named
pages) is the one escape hatch, for a brief that names a surface the five do
not cover. Use it only when a brief does.

**Three shell slots added by Communication (2026-09-15):**

* **A tab pinned to a band** — `SkDoorTab.bandId`. The Communication brief
  lists its three activity sets as three surfaces, so each is a card. A
  band ahead of hers is locked ("From 8 years"); a band behind hers drops.
  A tab with no `bandId` (Coding's shape) draws her band. Use it when a
  brief lists the bands as surfaces; do not use it to invent a ladder.
* **The voice keepsake** — `SkDoorContent.voiceKeepsake: true` puts a
  "Record it" row on every activity and routes `sk_voice/<door>` to
  `SkVoiceKeepsakeScreen` (her clips, then the words). On this phone only;
  see the file header for why the pregnancy recorder was not reused as-is.
* **The boundary note** — `SkDoorContent.boundaryNote`, a parent-facing
  page drawn as a card on the grown-up screen. For a brief that holds a
  clinical line ("if speech itself is the worry") rather than a consult.

### The two voices

Every skilling screen is one of two things, and the file says which:

* **Child-facing** (`SkContentPage` with `kidVoice: true`, `SkActivityScreen`,
  the door, the keepsake): body 17pt, targets ≥ 56 (`kSkTap`), a speaker at
  the top that reads the page through `BabyVoiceService` (the app's one TTS
  seam), no purchase, no external link and no settings without the grown-up
  gate.
* **Parent-facing** (`SkParentGateScreen`, `SkGrownUpScreen`, the parent note
  with `kidVoice: false`): the app's ordinary sizes and voice.

A block on a child page that is for the parent — the activity's
`theThinking`, an `SkGrownUpNote` — renders as a "For the grown-up" row and
opens behind the gate. Never inline.

---

## 1. Where your files go

| What | Where |
|---|---|
| The door (tabs, hero, closing) | `lib/data/doors/sk_door_<skill>.dart` + one line in `kSkDoors` (`sk_door_data.dart`) |
| Lessons and the cross-band set | `lib/data/skilling/skilling_<skill>_content.dart` |
| The activity set (the heart) | `lib/data/skilling/skilling_<skill>_activities.dart` |
| The course shelf | `lib/data/skilling/skilling_<skill>_course.dart` |
| The product shelf | `lib/data/skilling/skilling_<skill>_products.dart` |
| The assembled content | one `SkDoorContent` + one line in `kSkDoorContents` (`lib/screens/skilling/sk_content_registry.dart`) |
| The bracket's live cells | `lib/data/brackets/skilling_brackets.dart`, longhand, workbook text kept |
| The contract test | `test/sk_<skill>_door_test.dart` |
| The cross-door gate | `test/sk_doors_sanity_test.dart` (already walks every door in the lists) |

Shell files you do **not** edit per door: `lib/screens/skilling/doors/*`
(screen, carousel, chrome), `sk_content.dart` (blocks + renderer),
`sk_door_content.dart`, `sk_bands.dart`, `sk_child_store.dart`,
`sk_practice_store.dart`, `sk_grown_up_gate.dart`, `sk_parent_gate_screen.dart`,
`sk_grown_up_screen.dart`, `sk_keepsake_screen.dart`, `sk_surface_router.dart`.
If a brief needs the shell to change, that is a shell change, named as such.

---

## 2. The rules that are decided (do not re-ask)

From the Coding v2 brief and the user's calls of 2026-09-14:

1. **Bands are 6–8 / 8–11 / 11–14**, lower inclusive, upper exclusive, in
   years, one set for all doors (`kSkBands`). A door names its own rungs
   (`bandNames`) but never its own boundaries. **Floor 6:** under it, every
   child tab is locked "From 6 years" and the grown-up card stays open.
   **Over 14** reads the top band until a fourth exists.
2. **No age chip, tab or picker anywhere.** The hero says the band. The gate
   asks the date of birth once.
3. **The child record is skilling's own** (`SkChildStore`): name + date of
   birth, on the phone only, no cloud row. The gate pre-fills from the
   parenting child when she is 6 or over, so a transition types nothing.
4. **Consent verification is an interface with a stub** (`SkConsentVerifier`).
   The stub passes and is labelled a stub. No provider until legal review.
5. **The grown-up gate** is a sum in words; a parent may set a PIN and then
   the PIN is asked. Two misses close the sheet. Nothing is recorded.
6. **No scoring, anywhere, ever.** `SkPracticeStore` has no numeric public
   member; the sanity test scans the whole skilling tree for scoring
   vocabulary in code and fails on it. The keepsake shows Tried / Practised
   again / Made and a date. The compass lights a point when a door has been
   practised at all — a bool.
7. **Courses and products cannot promise a future.** `noOutcomeClaims` is
   true on the type; the sanity test scans every course and product string
   for the banned phrases. Enrol and buy are stub sheets (₹ and $) until a
   programme or a sourced item is real; the booking engine is not wired.
8. **The product shelf is skilling's own**, not `pp_products`. The shop
   engines are to be unified in one later pass; the shelf lists are that
   pass's input.
9. **The stage stays gated:** `skOpenDoor` returns false outside
   `kDebugMode`, so a release build's tile shows the plan sheet. The preview
   itself ships (with its PREVIEW pill, held by `skilling_doorway_test`).
10. **Placeholders only in a structure pass.** Titles like "Activity 3" and
    "Lesson 2", `comingSoon: true`, empty blocks, every id in the ledger.
    The task PDFs fill them verbatim in a later pass — **verbatim includes
    the tasks' Hinglish-friendly words** ("Silly, na?", "ulta"); the house
    rule against Latin-script Hinglish is for copy we write. One task-copy
    exception is allow-listed by id in the sanity test: an activity in which
    the CHILD builds a game that keeps its players' points may say "score".
11. **English only.** Kid voice, Hinglish-friendly, Devanagari if Hindi is
    ever asked for; never Latin-script Hinglish.

---

## 3. The recipe, per door

1. Read the structure PDF end to end, both halves. List every surface and
   its mark (BUILD NOW / REUSE / RESHAPE / HOLD / SINGLE-SOURCE). Anything
   the brief names that you cannot find: STOP and list it.
2. Batch the questions: the brief's own calls, plus anything two readings
   would build differently. Recommendation first. Do not build until
   answered.
3. Write the four data files. Six `SkSkillPurpose`s in the brief's words;
   twelve activity slots per band, two per skill (the task PDFs' rule);
   lesson sets tagged to bands; the cross-band set if the brief has one;
   courses one live + one recorded per level with placeholder prices in
   both currencies; products per band; the parent note with `kidVoice:
   false`.
4. Write `sk_door_<skill>.dart`: five tabs in the brief's order, a photo
   from `images.unsplash.com` that does not contradict the door's content,
   a closing card to the grown-up side (`sk_grown_up/<door>`) unless the
   brief un-holds a Consult.
5. Assemble the `SkDoorContent`, add it to `kSkDoorContents`, the door to
   `kSkDoors`.
6. Promote the bracket's cells longhand, keeping the workbook text; leave
   what the brief holds `notReady`.
7. Add the door's rows to `docs/DOOR-CONTENT-OWED.md` under Skilling, with
   every coming-soon id spelled out (the test greps for the id).
8. Write `test/sk_<skill>_door_test.dart` from the brief's map: tabs, kinds,
   the activity counts, the sets and bands, courses and products, the
   locked-band behaviour on screen, the ledger.
9. `flutter analyze` clean of new issues; the full suite green.
10. Append a numbered section to `docs/STILL-OPEN.md` (door-specific only),
    a checklist to `docs/SKILLING-DOORS-REVIEW.md`, and the row in its
    status table. Generic points come here, §9.
11. Give the `git add` list and a commit message in a file. Walk the door on
    the phone when given access; small follow-up commits for what it finds.

### When the task PDFs arrive for a door

A fill maps each activity into the existing `SkActivity` — `id` is the
slot's id, `comingSoon` flips to false, the eight fields fill verbatim. If a
task names a field the model does not have, STOP and list it (the Coding
8–11 task's **access rail** and the 11–14 task's **resume marker** are the
two known ones; see §9). Never a new screen, never a second activity model.

---

## 4. The shell, file by file

| File | What it is | Copied from |
|---|---|---|
| `doors/sk_door_screen.dart` | hero + selector + rails + closing + disclaimer | `pp_door_screen.dart`, rails redone per `SkTabKind` |
| `doors/sk_door_carousel.dart` | the 4a coverflow | `pp_door_carousel.dart`, value for value |
| `doors/sk_door_chrome.dart` | sheet, row, card, disclaimer | `pp_door_chrome.dart`; the disclaimer is skilling's |
| `sk_content.dart` | blocks + `SkPage` + `SkActivity` + the one renderer | `pp_content.dart`, closed to seven block types |
| `sk_door_content.dart` | `SkDoorContent`, sets, courses, products | new |
| `sk_bands.dart` | the three bands and the floor | `pp_age_bands.dart`, in years, no fallback under the floor |
| `sk_child_store.dart` | the consented minimum | new; reads `ChildProfileStore` for the hand-off |
| `sk_practice_store.dart` | the keepsake | the `devWordLabel` idea, made an API |
| `sk_consent_verifier.dart` | the seam | new |
| `sk_grown_up_gate.dart` | sum / PIN | new |
| `sk_parent_gate_screen.dart` | set up and consent | new |
| `sk_grown_up_screen.dart` | note, shelves, settings | new |
| `sk_keepsake_screen.dart` | the list | new |
| `sk_activity_screen.dart` | the heart | new |
| `sk_surface_router.dart` | every `sk_` surface | `pp_surface_router.dart`'s shape |

Neither the pregnancy engine nor the parenting shell is imported. Both were
open in other terminals as this was built; the seam is the same one
parenting took from pregnancy, for the same reason.

---

## 5. Surfaces

| Id | Opens |
|---|---|
| `sk_gate` | set up and consent |
| `sk_door/<door>[/<tab>]` | the door, optionally on a tab |
| `sk_today/<door>` · `sk_activities/<door>` · `sk_lessons/<door>` · `sk_cross/<door>` | the door on that tab |
| `sk_keepsake/<door>` | What I've made and tried |
| `sk_grown_up/<door>` · `sk_courses/<door>` · `sk_products/<door>` | the parent side (gated), on that shelf |
| `sk_page/<door>/<page>` | one page by id — **the cross-door window** |
| `sk_activity/<door>/<activity>` | one activity by id |

Single source across doors is `sk_page/<other door>/<page>` as a
`toolSurfaceId` on a page with no blocks, exactly as `pp_page/` works on
the parenting side. The sanity test holds that a window page carries no copy.

---

## 6. What the tests hold

* `sk_doors_sanity_test.dart` — every door has content and a bracket; every
  surface resolves; every link and pages-tab id lands; every band tag is a
  real band; every coming-soon slot is in the ledger; a window page has no
  copy; every live skilling cell is `sk_`-prefixed and resolves; **no
  scoring vocabulary in the skilling tree**; **no numeric member on the
  keepsake**; **no outcome claim on any shelf**; the tap target is 56.
* `sk_<skill>_door_test.dart` — the brief's map.
* `bracket_model_test.dart` — the skilling group now asserts the router,
  as its own comment said it would the day a cell went live.
* `skilling_doorway_test.dart` — unchanged: the preview ships with its pill.

---

## 7. What a phone walk should look at (per door)

The selector with five cards; the locked state at 5 and the open state at
7, 9 and 12; the speaker on a page; the three buttons on an activity and
the end line; the closing card's sum; the PIN path; the grown-up screen's
three shelves; withdraw consent and the return to the gate.

---

## 8. Things the shell deliberately does not do

* **No resume marker, no "3 of 12", no per-skill tally.** All are scores or
  child data. The keepsake's list is the whole memory.
* **No timer.** The task PDFs ban a timer used as competition; the only
  timer that is not a competition is one nobody sees.
* **No carousel, table, chart or interactive block.** No skill brief has
  asked. Add a block type when one does, in `sk_content.dart`, once.
* **No cloud row for the child.** Local-first is absolute everywhere; here
  it is also the privacy posture.

---

## 9. Generic open points — the doors of skilling

Points that apply to every skill door. Door-specific ones are in
`STILL-OPEN.md` by section; content owed is in `DOOR-CONTENT-OWED.md`.

- [x] **The 8–11 access rail** — built at the Coding fill (2026-09-14):
      `SkDoorContent.access` (a list of `SkAccessTool`, band-tagged), drawn
      as a "Free tools to set up" Grown-ups card leading the first rail of
      the activities tab, opening `sk_access/<door>` (`SkAccessScreen`),
      which asks the gate on open and lists the tools with links. Any door
      with tools to set up gets it by filling `access`.
- [ ] **The 11–14 resume marker.** Flagged at the fill, not built, as the
      task asks ("if not, flag it, do not build one silently"). It is
      per-child state — which step she reached — child data and a step
      count. `SkActivity.multiSession` marks the seven projects that span
      sittings ("More than one sitting" chip); a project she returns to
      reads the steps again. Say if a marker is wanted; it would be the
      keepsake's first non-word field.
- [ ] **Cross-links the fills name to doors that do not exist yet:** task
      2's activity 12 → the Stillness door's settle-breath ("point to it,
      do not rebuild it"); task 3's activity 6 → the Thinking door's "is
      this true" side; task 3's sharing posture → "the same private-showcase
      posture as the Making door". Logged in the review file's cross-door
      table; each becomes a `SkLink` when its door lands.
- [ ] **Fourteen and over.** Reads the top band. The brief says a fourth
      band "is easy to add later". When?
- [ ] **The brief's own example line contains a number** ("You practised
      three days, nice work"). The build held the user's rule — words only,
      no count of days. Say if a count of DAYS (not of things) is wanted;
      it would need a deliberate numeric member on the keepsake and the
      sanity test relaxed for it.
- [ ] **The regrouping suggestion for the five tabs** — see
      `SKILLING-DOORS-REVIEW.md`, Coding. The build follows the brief
      literally; the suggestion is there for after the walk.
- [ ] **A parenting-side Skilling entry point that is not the preview.**
      Today the door is reached preview → tile. When the stage ships, where
      does a parent with a nine-year-old land?
- [ ] **The PIN's hash is FNV-1a**, not cryptographic (no `crypto`
      dependency). A local child-lock, not a secret; flagged with consent for
      legal review.
- [ ] **Voice.** The read-aloud uses the device's English voice via
      `BabyVoiceService`. A recorded warm voice (the brief's "a warm voice")
      is a narration-manifest job like Garbh Sanskar's.
- [ ] **A cloud copy of her recordings** — only when a real consent adapter
      replaces the stub AND a parent consents to cloud storage as a separate
      line: a child-scoped bucket, RLS, a retention limit, a delete that
      removes the object. `BACKEND-PATTERNS.md` §16a; ledger SC9. Until
      then every clip stays on the phone and a phone change loses them —
      the correct behaviour for consented data.
- [ ] **The product-engine unification** (question 6): skilling's shelf is
      its own; the parenting shop is its own. One pass, later, with both
      lists as input.
- [ ] **The grown-up screen asks the gate on open, every time** — from the
      closing card and from a deep link alike, one question. A "remember
      for ten minutes" would be a convenience; say if wanted.

# Skilling doors — what needs the user's opinion

One list, per door, of the things built on a judgement call that the user
has not yet looked at or ruled on. Kept short so the review at the end is a
walk down this file, not a hunt through `STILL-OPEN.md` (door-specific
reasoning, by section number) or `SKILLING-DOOR-BUILD.md` (the shell, the
decided rules, and the points generic to every skill door — §9 there).
Content owed is `DOOR-CONTENT-OWED.md`, Skilling heading. Add to this file
as doors land; strike a line when it is decided.

Decided so far, for all doors (2026-09-14): the shell on every door; the
five tabs are the brief's five child surfaces in the brief's order; the
parent surfaces sit behind the grown-up gate on one screen, reached from
the closing card; bands 6–8 / 8–11 / 11–14 with a floor at 6 (under it,
every child tab locked, the grown-up side open); the child record is
skilling's own and pre-fills from the parenting child; the gate is a sum in
words or a parent-set PIN; the product shelf is skilling's own; enrol and
buy are stub sheets; the door stays behind `kDebugMode`; the preview ships.

## Where every tile stands

| Tile | Brief | Shape | Tasks (fills) | Commit | Walked on a phone | Contract |
|---|---|---|---|---|---|---|
| Coding | `ParentVeda_Coding_structure_v2.pdf` | door, 5 tabs + the shell | **3 of 3 filled** (36 activities) | 5f963a7 (door), 87dcd62 (fills + walk) | **yes** — 2026-09-14, at 8, 5 and 12 | `sk_coding_door_test` |
| Communication | `ParentVeda_Communication_structure.pdf` | door, 5 tabs (three band cards) | **3 of 3 filled** (6–8, 8–11 from the author's PDFs; **11–14 written by Claude Code**, with the other PDFs) | a86c5bf (frame), 0fa1193 (fills), e67da1b (walk), e34b39f (11–14) | **yes** — 2026-09-16, at 12 and 8, recorder end to end (11–14 fill not yet) | `sk_communication_door_test` |
| Confidence | `ParentVeda_Confidence_structure.pdf` | door, **6 cards** (three band cards + recorder + keepsake) | **3 of 3 filled** (36 activities) | 5eb85a4 (frame), 153b3a4 (walk), 6a78176 (fills + walk) | **yes** — 2026-09-17, at 8, frame and fills | `sk_confidence_door_test` |
| Creativity (Making) | `ParentVeda_Creativity_structure.pdf` | door, 5 tabs (three band cards + Prompts + Your portfolio, the showcase inside it) | none yet (no task PDFs) | 8834d6a | no | `sk_making_door_test` |
| Feelings | `ParentVeda_Feelings_structure.pdf` | door, **6 cards** (three band cards + Scenarios and prompts + Your journal + You practised) and the off-ramp bar on every screen | none yet — **content marked "care": clinical review before any fill** | 8c09f97 | no | `sk_feelings_door_test` |
| Focus | `ParentVeda_Focus_structure.pdf` | plan sheet | none yet | — | — | — |
| Maths | `ParentVeda_Maths_structure.pdf` | plan sheet | none yet | — | — | — |
| Memory | `ParentVeda_Memory_structure.pdf` | plan sheet | none yet | — | — | — |
| Reading | `ParentVeda_Reading_structure.pdf` | plan sheet | none yet | — | — | — |
| Stillness | `ParentVeda_Stillness_structure.pdf` | door, 5 tabs (three band cards + Sessions + the keepsake as "Quiet moments taken") | none yet (no task PDFs) | 266d1ab | no | `sk_stillness_door_test` |
| Thinking | `ParentVeda_Thinking_structure.pdf` | door, 5 tabs (three band cards + Lessons + the keepsake as "You kept thinking") | none yet (no task PDFs) | db71b51 | no | `sk_thinking_door_test` |
| Values | `ParentVeda_Values_structure.pdf` | plan sheet | none yet | — | — | — |

Across all of them: `test/sk_doors_sanity_test.dart` holds that every
door's content and bracket exist, every surface resolves, every link lands,
every band tag is real, every coming-soon slot is owed, every window page
carries no copy, every live skilling cell resolves through the skilling
router, no scoring vocabulary is in the skilling tree, the keepsake has no
numeric member, and no shelf string promises a future.

## Coding (§55)

**Hand-back, as the brief's OUTPUT asks (2026-09-14; fills 2026-09-15):**

- *Files changed:* the whole skilling shell (`lib/screens/skilling/*`,
  `lib/screens/skilling/doors/*`), `lib/data/doors/sk_door_data.dart` +
  `sk_door_coding.dart`, `lib/data/skilling/skilling_coding_*.dart`,
  `lib/data/brackets/skilling_brackets.dart` (Coding row live),
  `lib/widgets/global_ask_fab.dart` (hidden on `sk_` routes),
  `test/sk_coding_door_test.dart`, `test/sk_doors_sanity_test.dart`.
- *Layers left notReady as content:* lessons (12 + AI 6), courses (6),
  products (9), parent note — placeholders, ledger S1–S9. The 36
  activities were placeholders at the frame and are now filled from the
  three task PDFs.
- *Reused vs new:* new — the shell itself (this was the first door):
  gate, child record, learning surface, band scope, no-score keepsake,
  course and product shelves, router. Reused — `bracket_resolver`, the
  bracket model, `v3_skill_art`, the preview tile. The product shelf is
  skilling's own, not `pp_products` (your question 6).
- *Named but not found:* nothing named was missing; the consent-
  verification provider is an interface + stub flagged for legal review,
  as asked.

Built to the brief literally, on the user's call ("follow the brief
completely, I want to see how the brief does; then give your suggestions").
The suggestions are the last three lines.

- [ ] **Look:** Skilling → Coding → the selector. Five tabs in the brief's
      order: Today's thing to try · Things to do · Lessons · AI, explained ·
      What I've made and tried. Today is a rail of one card; the keepsake
      tab is a rail of one Keepsake card. Both are the brief's surfaces as
      surfaces. Fine on a phone, or too thin?
- [ ] **Look:** the closing card "For the grown-up" under every tab. It is
      the only way to courses, products, the note and settings. Right
      weight, or should the hero carry a small lock control too?
- [ ] **Look:** the hero photo — a spill of plastic building bricks
      (`photo-1587654780291`). No face, no screen, nothing that contradicts
      "no code yet". Keep, or find a child mid-activity?
- [ ] **Look:** "FOR MEERA · BLOCKS · 8 TO 11" on the hero. Three facts on
      one line; say if the years are noise once the rung name is there.
- [ ] **Look:** Things to do → six rails headed by the thinking skill
      ("Putting steps in order", "Seeing the pattern"…), two cards each.
      The skill names are mine, in the brief's words for the child. Say if
      the rail heading should be quieter than the skill it names.
- [ ] **Look:** an activity → the three buttons "I tried it · I did it
      again · I made something" and the end line. The three verbs are the
      brief's; the button labels are mine.
- [ ] The Today card is chosen by the day of the year (same all day,
      changes daily, never recorded). Since the fill it is a real activity
      every day. **Look:** Today's thing to try → the one card → the three
      buttons.
- [ ] **Look:** Things to do at 9 → "Free tools to set up" leads the first
      rail with a Grown-ups chip and opens the tools list behind the gate.
      Right place, or should it sit on the grown-up screen instead?
- [ ] **Look:** an 11–14 project → the chips "With a grown-up" / "More
      than one sitting" under the one-line. Labels are mine; the marks are
      the task's.
- [ ] The resume marker the 11–14 task asks about is flagged, not built
      (`SKILLING-DOOR-BUILD.md` §9). Want one?
- [ ] The parent note's built half draws the keepsake's words and, when an
      activity has one, its `theThinking` line. Say if the note should stay
      authored-only.
- [ ] The consent stub PASSES so the door can be walked; the settings screen
      says "Not verified yet (stub, pending legal review)". Say if a
      walk-through should instead refuse to open the door.
- [ ] The Explore drawer / pregnancy-home entries still say "preview" and
      "UI only, nothing behind the doors" — held by `skilling_doorway_test`.
      True in release; in a debug build Coding opens. Change the subtitle
      now, or on the day the stage un-gates?
- [x] **Walked on the phone, 2026-09-14** (Samsung S21 FE, Android 16), at
      8 (Blocks), 5 (the floor) and 12 (Projects). Fixed in the same pass:
      the Ask Veda FAB no longer floats over any skilling route (it opened
      an adult surface from a child screen and sat over the consent list,
      the end line and the locked panel); the activity's tool chip wraps
      instead of overflowing; settings gained "Change her date of birth";
      withdraw returns to the preview, not the pregnancy home; the gate
      drops the keyboard before the date picker; under the floor the
      shelves show the first rung, not every level. Seen and kept: the
      hero, the one-card Today tab, the six skill rails, the three
      buttons and the end line, the sum gate, the grown-up screen, the
      locked state.
- [ ] **Look, after the walk:** the door re-scopes live when the date of
      birth changes in settings — no restart. Fine, or should a band change
      say so somewhere?
- [ ] **Suggestion A (regroup):** Things to do (today's card pinned first,
      then the six skill rails) · Lessons · AI, explained · Made and tried ·
      **For the grown-up as a fifth, gated tab**. Five tabs always open, no
      one-card tabs, and the parent side is on the selector where a parent
      looks first.
- [ ] **Suggestion B (the ladder visible):** Things to do · Unplugged ·
      Blocks · Projects · AI, explained — a six-year-old sees Blocks locked
      "From 8 years", the brief's "climbing gently" made a picture. Cost: a
      twelve-year-old sees three tabs.
- [ ] **Suggestion C:** the Today card as a hero control ("Today: Be My
      Robot →") rather than a tab, once the fills land and it is a real
      activity.

## Communication (§56)

**Hand-back, as the brief's OUTPUT asks (2026-09-15; fills 2026-09-15 and
2026-09-17):**

- *Files changed:* `lib/data/doors/sk_door_communication.dart`,
  `lib/data/skilling/skilling_communication_*.dart`,
  `lib/screens/skilling/sk_voice_keepsake.dart` (new),
  `sk_door_content.dart` (`boundaryNote`, `voiceKeepsake`, `voiceTitle`,
  `voiceBlurb`, `voiceEmptyLine`), `sk_door_screen.dart` (band-pinned
  tabs), `skilling_brackets.dart` (row live),
  `test/sk_communication_door_test.dart`.
- *Layers left notReady as content:* lessons (27), courses (12),
  products (12), parent note, boundary note — placeholders, ledger
  SC4–SC8. The 36 activities are filled (two bands from the author's
  PDFs; 11–14 written by Claude Code, filed with the PDFs, owed a review).
- *Reused vs new:* new — the voice keepsake (skilling's own recorder, the
  `record`/`audioplayers` mechanism, on-device, no upload: your call 1a);
  band-pinned tabs; the boundary note slot. Reused — the whole Coding
  shell, the shared no-score keepsake.
- *Named but not found:* the brief names the pregnancy Garbh Sanskar
  recorder as the one to reuse; skilling got its own copy on your call
  (no cloud bucket for a child's voice). Reading, Feelings, Confidence
  cross-links — logged in the cross-door table.

Built to the brief literally on your calls of 2026-09-15 (1a 2A 3a 4a 5a).
Frame only; the two task PDFs (6–8, 8–11) fill it next.

- [ ] **Look:** Skilling → Expression → the selector at 6: `Say it out loud`
      open, `Tell it and explain it` locked "From 8 years", `Say what you
      think` locked "From 11 years", then Lessons and Your voice, saved. At
      12 the first two cards are gone and three remain. The brief's surface
      table made a picture — say if three cards at 12 reads too thin.
- [ ] **Look:** For the grown-up → settings → "Let her record her voice"
      (off by default, the tasks' rule) → then Tell it and explain it →
      Retell the Movie → "Say it in your voice · Record it" above the three
      buttons → the record sheet (big mic, listen back, keep it). Only the
      four storytelling activities offer it. The sheet's copy is mine.
- [ ] While recording is off, Your voice, saved shows "Recording is off. A
      grown-up can turn it on…" instead of a record button. Right, or hide
      the card until it is on?
- [x] **Walked on the phone, 2026-09-16** at 12 (three cards, two dropped)
      and 8 (Tell it and explain it open, Say what you think locked). The
      recorder end to end: switch on → Retell the Movie → Record it →
      mic permission → record → listen back → keep → listed → played →
      per-clip delete. Fixed in the same pass: one Keep showed as four
      rows (the store appended on load instead of merging by id — both
      stores fixed); the first-ever mic permission dialog closed the sheet
      (permission is now settled before the sheet opens); the hero back
      button at 56pt sat over the boy's face (38 on the hero, 44 on the
      content screens, left-aligned where it had centred); the child type
      sizes were "absurdly big" and are now the middle setting
      (`kSkTitleSize` 27 / 17 / 16 in `sk_content.dart`, one place).
- [ ] **Pronoun.** The keepsake reads "what *she* tried" for a child
      called Kabir. The skilling record has no sex field — the briefs
      write "her" throughout — and adding one is more data about the
      child. Options: keep "she" as the house voice; use "they"; or use
      the name twice. Say which.
- [ ] The Coding hero photo (bricks) and this one (a laughing boy who
      reads younger than 6) — both worth a second look together.
- [ ] **Look:** Your voice, saved → the clips, then "What you tried". The
      words list is the same keepsake as Coding's; here it sits under the
      recordings rather than on its own screen. Right, or two tabs?
- [ ] **Look:** the hero photo — a boy mid-laugh with an open book
      (`photo-1472162072942`). Keep, or a child clearly talking?
- [ ] The English course slot is titled "Speaking in English, too — Say it
      out loud" (per level). Say if "too" reads wrong.
- [ ] The boundary note sits on the grown-up screen under the parent note,
      as a coming-soon card. The brief made no call on placement.
- [ ] Recordings are on this phone only. A cloud copy waits on a real
      consent adapter and a separate consent line (ledger SC9). Agree?
- [ ] The tile still says "Expression" (the bracket's label) while the
      brief's door is "Communication & articulation" and the bracket's
      title says the same. Keep the short tile word?
- [ ] **Suggestion:** with three band cards on the selector, the parent
      side would fit better as the hero's small lock control than as a
      closing card below five rails; same as Coding's Suggestion A.

**The 11 to 14 fill (2026-09-17) — the copy is mine, read it**

- [ ] **This is the first activity copy written by Claude Code rather
      than received from the task author.** You asked for it ("write 11-14
      tasks then"). On your call it sits with the other task PDFs —
      `tasks/communication/ParentVeda Communication 11-14 activities prompt.pdf`, the editable `.md` beside it, the
      first page saying who wrote it and when — in Tasks 7 and 8's exact
      shape, so the task author can review and edit it like the rest. The
      Dart is generated from the `.md` (scratchpad `gen_cm_1114.py`) and
      was diffed against it by script, 12 of 12.
- [ ] **Read the twelve as twelve:** Explain the Hard Thing · Say It Once
      for the Group · Listen Past the First Answer · Say It Back Before You
      Answer · Describe It So They Could Draw It · Say What Happened,
      Exactly · Tell It So It Lands · Short Version, Long Version · Drop
      the Fillers · Write It to a Teacher · Point, Reason, Example · Hold a
      Real Back-and-Forth. Each steps up from its 8–11 twin, the way Tasks
      5 and 6 did for Confidence.
- [ ] Three calls I made that a task author might make differently:
      * **Two activities involve writing** (Write It to a Teacher; Say It
        Once for the Group is spoken but planned). The door is
        communication, not only speech, and a message to a teacher is the
        realest 11–14 register task there is — but the other bands are
        all spoken.
      * **Drop the Fillers** has a friend counting fillers out loud. That
        is play and the app counts nothing; the scan is happy. Say if a
        count of any kind is off-brief.
      * **Say What Happened, Exactly** teaches observed-versus-assumed
        (fair reporting). It is describing with a job; say if it drifts
        toward the Thinking door.
- [ ] `offersRecording` on the two storytelling ones, as in the other
      bands — six in thirty-six on this door now.
- [ ] Not walked after the fill; the band's rails are the same rails at a
      different age (12).

## Confidence (§100)

**Hand-back, as the brief's OUTPUT asks (2026-09-16; fills 2026-09-17):**

- *Files changed:* `lib/data/doors/sk_door_confidence.dart`,
  `lib/data/skilling/skilling_confidence_*.dart`, `sk_door_content.dart`
  (`coach`, `voiceSelfReview`), `sk_content.dart` (`SkBreath` block,
  `breathPageId`), `sk_activity_screen.dart` (the breath row),
  `sk_grown_up_screen.dart` (the coach row), `sk_surface_router.dart`
  (`sk_record/<door>`), `skilling_brackets.dart` (row live, the first
  live Consult), `test/sk_confidence_door_test.dart`.
- *Layers left notReady as content:* lessons (18), courses (6), products
  (9), parent note, boundary note, the coach — placeholders, ledger
  SF4–SF8, SF10. The 36 activities are filled from the three task PDFs.
- *Reused vs new:* new — the coach row (placeholder; booking engine is
  the named next pass), the self-review prompt, `sk_record`, the
  `SkBreath` block and `breathPageId`. Reused — the app's ONE breathing
  circle (`lib/widgets/breathing_circle.dart`), the voice keepsake built
  for Communication, the shared no-score keepsake.
- *Named but not found:* the tasks' "pregnancy recorder" (skilling's own
  is used, per the earlier call); the Thinking door's "question ideas,
  not elders" line (Thinking built since; its parent note); "the door's
  help line" for a child (no skilling door has one — generic point, build
  doc §9); Stillness and Feelings cross-links — logged.

Built to the brief literally on your calls of 2026-09-16 (1a 2a 3b 4a).
The three activity bands filled verbatim from Tasks 4, 5 and 6 of 36 on
2026-09-17 — every field diffed against the PDF text by script, 36 of 36
match. The fill's own list follows the frame's.

- [ ] **Look:** Skilling → Confidence → the selector: six cards. Use your
      voice · Stand up and say it · Give a real talk · Lessons · Hear
      yourself back · Your talks, saved. The brief listed six; the
      coverflow is drawn for five. Say if six reads crowded (Health and
      Development carry six on the parenting side and were kept).
- [ ] **Look:** Hear yourself back → (recording on) the sheet opens
      straight away → record → Listen back → the prompt "Notice one thing
      you did. Just for you — nothing is written down." Right tone? The
      words are mine.
- [ ] **Look:** Lessons → Stage exercises → Steady your nerves: the app's
      breathing circle (in 3, out 5) with two lines of mine under it. The
      one built lesson on the door; say if it should wait for the fill.
- [ ] **Look:** For the grown-up → under the classes, "A speaking coach,
      one to one" (₹799 / $10 placeholder) → the stub sheet. The row's
      words are mine. The booking-engine wiring waits on a real coach.
- [ ] The course titles ("With a coach, Use your voice" / "At her own
      pace, Use your voice") — say if "with a coach" oversells for a
      placeholder.
- [x] The hero photo — **swapped on the walk** (2026-09-17): the first
      pick's chalkboard read "if someone in your family has cancer", legible
      only at hero size. Now a classroom on the floor, hands up, one child
      standing at the front (`photo-1588075592446`). Keep?
- [x] **Walked on the phone, 2026-09-17** at 8: five of the six cards (Use
      your voice dropped), Hear yourself back opening straight onto the
      sheet, record → listen back → the "notice one thing" prompt → keep →
      one row, the breathing circle page, the boundary note, the classes
      and the coach row. Two fixes: the hero photo, and the voice screen's
      subtitle and empty line, which were Communication's words and are now
      a per-door slot ("The turns Kabir stood up and took…").
- [ ] The tile says "Confidence"; the brief's door is "Confidence & public
      speaking". Fine.
- [ ] **Suggestion:** on this door the recorder and the keepsake being two
      cards makes the walk to "record something" one tap shorter than on
      Communication. If it reads well, Communication could take the same
      shape (its brief listed one surface; yours to say).

**The fills (2026-09-17)**

- [ ] **Look:** Use your voice → Butterflies Breath → under the steps,
      "The breathing circle · Open the breathing circle" → the Steady your
      nerves page (the one circle). The same row on Your Calm-Down Routine
      (8–11) and The Big-Day Routine (11–14). The tasks said "(Uses the
      app's breathing circle.)"; this row is the wiring. The field is
      `breathPageId` — the one field the fill added; the tasks said STOP
      and list a missing field, and this is it.
- [ ] **Look:** (recording on) Loud and Proud Name, Show and Tell at Home,
      Your Own Way, Answer in Class, Two-Minute Talk, Read it Out Loud, Give
      the Real Talk → "Say it in your voice · Record it". Seven of
      thirty-six, the tasks' seven, and no others.
- [ ] **The recorder the tasks name is not the one used.** All three tasks
      say "reuse the app's EXISTING voice recorder (the pregnancy Garbh
      Sanskar / family-voice recorder)". Skilling has its own
      (`sk_voice_keepsake.dart`), built for Communication on your call of
      2026-09-15 (option a: own copy, same `record`/`audioplayers`
      mechanism, no upload). That is what the seven rows open. Nothing new
      was built; the task's assumption was overtaken by an earlier
      decision. Say if you want it otherwise.
- [ ] **Two things the tasks name that do not exist**, listed not built:
      * "the Thinking door's 'question ideas, not elders' line" — Speak Up
        to a Grown-Up's parent line cross-links to it. Thinking is not
        built; the window is in the cross-door table.
      * "the door's help line points to a trusted adult or professional" —
        After a Rough One's parent line. The door has the parent-facing
        boundary note card (SF8, unwritten) on the grown-up screen; there
        is no child-facing help line on any skilling door. Yours to say
        whether one should exist (a generic point, `SKILLING-DOOR-BUILD.md`
        §9).
- [ ] **Two lines to eyeball against the no-promise rule**, kept verbatim
      because the copy is the task's: Ask the Real Question step 4, "That
      is leadership, quietly." (present tense, about the act — not "future
      leader"); On the Call step 4, "That is a skill you will use your
      whole life." Both read as honest to me; say if either should go back
      to the task author.
- [ ] Hinglish kept verbatim where the tasks wrote it: "kachcha papad,
      pakka papad", "dadaji". The English-only rule is for copy we write;
      this is theirs.
- [ ] The scan allow-list grew by three ids for the word "points" —
      "three points" (the talk's) and "points to" (the verb). Reasons are
      written beside each in `sk_doors_sanity_test.dart`.
- [x] **Walked on the phone after the fill, 2026-09-17** at 8: the new
      hero, the filled Stand up and say it rails, Your Calm-Down Routine →
      the breath row → the one circle, Answer in Class → the record row →
      "I tried it" → the task's end line → TRIED on the card, Say What You
      Think with no record row and no breath row. One fix on the way in:
      the preview's note still said "Coding opens its door"; it now counts
      from `kSkDoors` ("Three of the twelve…").

## Thinking (§101)

**Hand-back, as the brief's OUTPUT asks (2026-09-17):**

- *Files changed:* `lib/data/doors/sk_door_thinking.dart` (new),
  `lib/data/skilling/skilling_thinking_{activities,content,course,
  products}.dart` (new), `lib/data/doors/sk_door_data.dart` (listed),
  `lib/screens/skilling/sk_content_registry.dart` (registered),
  `sk_door_content.dart` (`keepsakeTitle`), `sk_keepsake_screen.dart`
  (uses it), `lib/data/brackets/skilling_brackets.dart` (row live: six
  cells, Consult held), `test/sk_thinking_door_test.dart` (new).
- *Every layer left notReady as content:* activities (36), lessons (33:
  puzzles, why-chains, Is this true?, Just for fun), courses (4),
  products (9), parent note — placeholders, ledger ST1–ST8. No puzzle,
  activity, class or product copy written.
- *Reused vs new:* reused — the gate, the learning surface, the band
  scope, the shared no-score keepsake (as "You kept thinking"), the
  shelves, the router. New — one shell slot, `keepsakeTitle`, so the one
  keepsake can wear a door's name; nothing else.
- *The fake-spotting cross-link to Coding:* Coding's AI-literacy pages
  (`cd_ai_*`) exist as slots but are coming soon, so — as the prompt says
  for that case — this door leaves a cross-link slot (the "Is this true?"
  set's blurb names the Coding door), lists it (ST4, ST10, the cross-door
  table), and re-authors nothing; a test scans the file for AI-mechanism
  vocabulary.
- *Named but not found / not used:* `pp_products` — not used on purpose,
  skilling's own shelf holds (your Coding call, question 6). The no-score
  keepsake and AI literacy were both found. Maths does not exist; the
  puzzles set's blurb draws the line ("a number puzzle lives in Maths").

Built to the brief literally on your calls of 2026-09-17 (1a careful
framing · 2a spotting-fake as a headline strand · 3a a "Just for fun"
set). Frame only; no task PDFs exist for this door yet.

- [ ] **Look:** Skilling → Thinking → the selector: five cards. Ask lots
      of whys · Work out how it works · Think for yourself · Lessons · You
      kept thinking. The tab footers are the brief's band lines, word for
      word.
- [ ] **Look:** Lessons → four rails: Puzzles · Why-chains · Is this
      true? · Just for fun. The third is the spotting-fake strand, a
      headline set on your call (2a); its blurb names the Coding door as
      where "how the machine makes things up" lives. Say if the set's name
      should be the brief's "spotting fake" rather than the child's "Is
      this true?".
- [ ] **Look:** You kept thinking → the shared keepsake (same store, same
      screen) titled in this door's words. This is the brief's extras
      reshape: the certificate becomes a "you kept thinking" keepsake; the
      progress report is dropped; the rubric tracker is refused into it.
      One slot was added for it (`SkDoorContent.keepsakeTitle`).
- [ ] **Look:** For the grown-up → the parent note card carries the
      brief's own title, "How to raise a questioner without raising an
      arguer", coming soon. Under it the four classes (₹2499 / $30
      placeholders): reasoning per level, light debate for 11–14 only,
      because the brief puts debate in Think for yourself.
- [ ] **The careful framing (1a) is held in the frame's own words**: every
      footer and blurb says what she checks — a claim, a forward, an
      argument — and never who she argues with. A test scans the door's
      copy for "argue with", "defy", "question your parents/teacher/elders".
      The fills, when they come, are held to the same line.
- [ ] **The one defence, built once**: Thinking owns the reasoning ("is
      this true, who says so, how would I know"); Coding's AI literacy
      owns the mechanism. Coding's AI pages are themselves coming soon, so
      this door leaves the cross-link slot the brief's prompt asks for and
      lists it (ledger ST4, ST10). The page that links across is authored
      when both halves exist. Nothing AI-literacy was re-authored here (a
      test scans for it).
- [ ] The product shelf is skilling's own, as on every door, not
      `pp_products` (the brief's prompt names `pp_products`; your standing
      call from Coding question 6 holds until the engines unify).
- [ ] Consult held: "a reasoning or debate coach, rarely". No row.
- [ ] The hero photo — a child at a desk, head down, working something out
      on paper (`photo-1529390079861`). Keep?
- [ ] The tile says "Thinking"; the brief's door is "Critical thinking &
      first principles". Fine.
- [ ] Not walked on a phone yet.

## Stillness (§102)

**Hand-back, as the brief's OUTPUT asks (2026-09-17):**

- *Files changed:* `lib/data/doors/sk_door_stillness.dart` (new),
  `lib/data/skilling/skilling_stillness_{activities,content,course,
  products}.dart` (new), `lib/data/doors/sk_door_data.dart` (listed),
  `lib/screens/skilling/sk_content_registry.dart` (registered),
  `sk_door_content.dart` (`keepsakeInvite`), `sk_keepsake_screen.dart`
  (draws it), `lib/data/brackets/skilling_brackets.dart` (row live: six
  cells, Consult held), `test/sk_stillness_door_test.dart` (new).
- *Every layer left notReady as content:* practices (36), sessions (24:
  guided sits, gentle moving, resting), courses (3), products (9), parent
  note — placeholders, ledger SL1–SL8. No meditation script, session,
  activity or product copy written.
- *Reused vs adapted vs new — the engines called out:* **reused** — the
  breathing circle (`lib/widgets/breathing_circle.dart`, through the
  `SkBreath` block), the app's one audio player (`RagaAudioStore`,
  verified; wired the day a session exists), the `garbh` theme key, the
  shared no-score keepsake, the gate, the surface, the scope, the shelves.
  **Adapted** (marked on the cards, 2a) — the yoga in Garbh Sanskar → the
  gentle-moving sessions; the Kriya body-scan
  (`lib/data/kriya_relaxation_data.dart`) → the resting sessions. **New** —
  one shell slot, `keepsakeInvite` (one gentle line on the keepsake, no
  number, never a notification: the streak's replacement, 1a/3a); the
  guided sits are kid-native slots; `sl_settle`, the one built page (4a),
  is the circle with the brief's own words, the source the other doors
  borrow. No second engine of any kind (a test scans for it).
- *Named but not found / not used:* `pp_products` — not used on purpose,
  skilling's own shelf holds (your Coding call). The breathing circle,
  audio player, garbh theme and no-score keepsake were all found. Nothing
  to stop on.

Built to the brief literally on your calls of 2026-09-17 (1a refuse the
streak · 2a engines reused, sessions kid-authored · 3a one line on the
keepsake · 4a the settle breath built). Frame only; no task PDFs exist.

- [ ] **Look:** Skilling → Stillness → the selector: five cards. Breathe
      and wiggle · Sit and settle · Find your calm · Sessions · Quiet
      moments taken. The footers are the brief's band lines, word for word.
- [ ] **Look:** Sessions → three rails: Guided sits (the first card is
      Settle, the built one; the rest "Kid-native") · Gentle moving
      ("Adapted") · Resting ("Adapted"). The chip on each card is the call
      2a mark, so a later fill knows which is which. Say if the chip words
      should be plainer.
- [ ] **Look:** Sessions → Settle: the app's one circle, in 3 / out 5, and
      one line under it ("Nothing to get right"). This is the SOURCE page
      Focus, Feelings and Memory will reference; Confidence's Steady your
      nerves is the same circle with its own words. Two questions: should
      Confidence's page become a window onto this one (one page, one owner)
      or stay as its own words on the same circle? And is "Settle" the
      right title, or the brief's "Settling"?
- [ ] **Look:** Quiet moments taken → the shared keepsake under this name,
      with one purple line: "Want to sit again? Whenever you like. There is
      no chain to keep and no day to miss." The same words on an empty
      shelf and a full one; no number anywhere. This is the streak's
      replacement, your decision on the record (1a). Say if the line is
      too long or the wrong tone.
- [ ] **The three words on a practice.** The keepsake's buttons are the
      shell's — "I tried it · I did it again · I made something". On a
      breathing practice the third reads oddly. Options: leave (the words
      are the stage's one vocabulary); or let a door hide "I made
      something" (a shell slot). Yours.
- [ ] **Look:** For the grown-up → the parent note card, "How stillness
      helps, without over-selling it", coming soon; the three recorded
      series (₹699 / $8 placeholders); no coach (held).
- [ ] The hero photo — four children mid-leap in a misty grove
      (`photo-1502086223501`). It is "breathe and wiggle" more than
      "stillness"; the calm ones I could find were all adults. Say if you
      want a quieter frame and I will look again.
- [ ] Secular and inclusive: the frame's copy says "animal poses",
      "stretch", "a quiet minute" — no mantra, no deity, no ritual. The
      fills are held to the same line (a copy rule for later, per the
      brief).
- [ ] The tile says "Stillness"; the brief's door is "Meditation, yoga &
      mindfulness". Fine.
- [ ] Not walked on a phone (the device is the other terminal's until you
      say).

## Feelings (§103)

**Hand-back, as the brief's OUTPUT asks (2026-09-18):**

- *Files changed:* `lib/data/doors/sk_door_feelings.dart` (new),
  `lib/data/skilling/skilling_feelings_{activities,content,course,
  products}.dart` (new), `lib/screens/skilling/sk_safety.dart` (new — the
  off-ramp bar and sheet), `lib/screens/skilling/sk_journal.dart` (new —
  key store seam, AES-GCM cipher, store, screen),
  `lib/screens/skilling/sk_crisis_pathway.dart` (new — the stub),
  `sk_door_content.dart` (`journal`, `safety`, `SkSafety`, `SkHelpline`),
  `sk_surface_router.dart` (`sk_journal/<door>`; the journal store loads
  at door entry), the safety bar added to the door screen, the activity
  screen, the content page (child pages only), the keepsake and the voice
  keepsake, `sk_grown_up_screen.dart` (her journal: delete, never read;
  withdrawing consent forgets it), `lib/data/doors/sk_door_data.dart`,
  `sk_content_registry.dart`, `skilling_brackets.dart` (row live; extras
  `notApplicable` with the brief's reason), `pubspec.yaml` +
  `pubspec.lock` (`pointycastle` made a direct dependency; no version
  change), `test/sk_feelings_door_test.dart` (new),
  `test/sk_doors_sanity_test.dart` (the gated-link rule with its one
  exception), `test/bracket_model_test.dart` (the one refused skilling
  cell, named).
- *Every layer left notReady, and the two that need review before a line
  is written:* activities (36), scenarios (9) and journal prompts (9) —
  every card's chip says "Needs review", **content needs a child
  psychologist**; courses (3), products (9), parent note (also clinical).
  **The journal needs legal review** for its child-private default
  against DPDP's parental-consent rules, and its key custody moved to the
  platform keystore, before it ships. Nothing authored.
- *Reused vs newly created — the off-ramp and the journal called out:*
  **reused** — the gate, surface, scope, shared no-score keepsake (as "You
  practised"), the shelves, the router; **Stillness's calm practice**
  through a window page (`fe_calm` → `sk_page/skilling_stillness/
  sl_settle`), no breathing rebuilt; the voice keepsake's on-device
  machinery as the journal's shape. **New** — the **safety off-ramp**
  (`SkTalkToSomeoneBar`: a calm bar on every child screen of the door, a
  sheet with the trusted-adult line and tap-to-call; ungated on purpose,
  the one ungated link off a child screen, on the record; records
  nothing); the **private-journal scaffold** (`SkJournalStore`: on-device,
  AES-256-GCM per entry with a fresh nonce, an index that holds ids and
  dates and no text, one reader — her own page — no search, count,
  sentiment, export or sync; child-private; the parent deletes, never
  reads); the **crisis-pathway stub** (does nothing, reads nothing, not
  wired to the journal, and STOPS: what the experts decide is listed in
  the file); two shell slots (`journal`, `safety`).
- *Named but not found / not used:* `pp_products` — not used on purpose,
  skilling's own shelf holds. No existing journal mechanism was
  child-private and on-device (the pregnancy and father journals sync to
  Supabase), so the minimal scaffold the prompt allows was built and is
  listed (FE10). The no-score keepsake and Stillness's calm practice were
  found. Nothing else to stop on.

Built to the brief literally on your calls of 2026-09-18 (1a child-private
journal · 2a real helplines, flagged verify · 3a AES via `pointycastle` ·
4a the off-ramp bar on every child screen). Frame only; **nothing on this
door is authored until a child psychologist has reviewed it.**

- [ ] **Look:** Skilling → Feelings → the selector: six cards. Name what
      you feel · Handle the big feelings · Find your way through ·
      Scenarios and prompts · Your journal · You practised. The footers are
      the brief's band lines, word for word. And at the foot of the
      screen, on this door only, a calm bar: "Talk to someone · Always
      okay".
- [ ] **Look:** the bar → the sheet: "If something feels too big, tell a
      grown-up you trust…", then Childline · 1098 and Tele-MANAS · 14416
      with tap-to-call, then "Nothing you say here is written down". The
      words are mine; the numbers are real as of writing and **flagged
      VERIFY** — a lawyer and a clinician confirm both and the wording
      before ship, and a release build hides anything still flagged.
- [ ] **The ungated exception, on the record.** The helpline tap is the
      one link off a child screen that does not ask a grown-up first,
      because the child who needs it may be the child who cannot ask. A
      test holds that it is the only one, and that it is a phone call and
      never a web link. Say if you want it otherwise.
- [ ] **Look:** Your journal → "Yours. It stays on this phone, locked, and
      nobody reads it but you." → Write a page → Keep it → a dated row →
      open → "Tear this page out". The parent's side (For the grown-up →
      settings): "Her journal · Hers. On this phone, locked; you can delete
      it, not read it" and a "Delete her journal" action. **Legal review
      owed** on the child-private default (DPDP parental consent).
- [ ] **Key custody is the flagged gap.** The pages are AES-256-GCM
      encrypted, but the key sits in `shared_preferences` beside them —
      a lock with the key under the mat. The seam (`SkJournalKeyStore`)
      is built; the platform keystore implementation (`flutter_secure_
      storage` or equal) is owed before ship. A dependency call for you.
- [ ] **The crisis pathway is stopped**, as the brief asks. No scanning of
      her journal, ever, by anything; the stub does nothing and nothing
      calls it. What a child psychologist and a lawyer must decide is
      listed in `sk_crisis_pathway.dart`. Do not ask me to build it.
- [ ] **Look:** Scenarios and prompts → three rails: Scenarios to think
      through · Journal prompts (every card "Needs review") · When a
      feeling is big → the one card opens Stillness's Settle page — the
      first cross-door window in the stage, no copy of the breath here.
- [ ] **Look:** For the grown-up → the parent note card carries the
      brief's own title, "How to help a child with big feelings, and when
      to seek help" (coming soon, clinical); three recorded series (₹699 /
      $8 placeholders) whose blurbs say "not treatment"; no coach (held —
      "help is not an upsell here").
- [ ] The keepsake's three words on a feelings activity ("I made
      something") — the same question as Stillness raised. Yours.
- [ ] The hero photo — two girls in a field at golden hour, the older
      one's arm round the younger (`photo-1476234251651`). Keep?
- [ ] The tile says "Feelings"; the brief's door is "Emotional
      intelligence & resilience". Fine.
- [ ] Not walked on a phone (the device is the other terminal's).

## Making — Creativity & expression (§104)

**Hand-back, as the brief's OUTPUT asks (2026-09-18):**

- *Files changed:* `lib/data/doors/sk_door_making.dart` (new),
  `lib/data/skilling/skilling_making_{activities,content,course,
  products}.dart` (new), `lib/screens/skilling/sk_portfolio.dart` (new —
  the store, the add-a-photo sheet, the screen, the show mode),
  `sk_child_store.dart` (`photosAllowed`, off by default),
  `sk_door_content.dart` (`portfolio`), `sk_surface_router.dart`
  (`sk_portfolio/<door>`; the store loads at door entry),
  `sk_grown_up_screen.dart` (the photos switch, "Delete her photos",
  withdrawing consent forgets them), `lib/data/doors/sk_door_data.dart`,
  `sk_content_registry.dart`, `skilling_brackets.dart` (row live: six
  cells, Consult held), `test/sk_making_door_test.dart` (new).
- *Every layer left notReady as content:* activities (36), prompts (27:
  art, music, making), courses (6), products (12), parent note —
  placeholders, ledger MK1–MK4, MK6–MK8. No prompt, activity, class or
  product copy written.
- *Reused vs newly created — photo capture called out:* **reused** — the
  gate, surface, scope, the shared no-score keepsake (as "What I made",
  reached from inside the portfolio), the voice keepsake for the music
  she makes (`sk_voice/<door>`, reached from inside the portfolio), the
  shelves, the router; `image_picker`, already a dependency. **New** — the
  **photo capture**, the brief's one new capability: camera or gallery,
  the picked file copied out of the cache into documents (the
  `memory_photos` lesson), an index of ids, dates and captions, behind the
  parent's photos switch (off by default), parent-deletable, never
  analysed, and no "how good is this drawing" of any kind; the
  **portfolio screen** composing the three; the **show mode** — the
  showcase, private: a full-screen pager to hand to family in the room,
  nothing leaves the phone, no likes, no ranking, no featured wall (1a,
  3a); two shell slots (`photosAllowed`, `portfolio`).
- *Named but not found / not used:* `pp_products` — not used on purpose,
  skilling's own shelf holds. The brief's "existing keepsake/journal (from
  the pregnancy journal)" — the pregnancy journal syncs to Supabase and
  is the pregnancy stage's; skilling's own keepsakes are what the
  portfolio reuses (the standing call). The journal's "invite someone to
  see" pattern — found, and it is a link whose other half (the web page,
  the upload) is not in this repo; a dead link for a child's art would be
  worse than none, so the show mode replaces it (3a). Nothing else to
  stop on.

Built to the brief literally on your calls of 2026-09-18 (1a the showcase
private · 2a the least commercial door, kept so · 3a a show mode on this
phone · 4a photo capture, on-device, the voice posture). Frame only; no
task PDFs exist.

- [ ] **Look:** Skilling → Making → the selector: five cards. Just make
      it · Make it yours · Make something real · Prompts · Your portfolio.
      The footers are the brief's band lines, word for word.
- [ ] **Look:** Prompts → three rails: Art · Music · Making — the brief's
      "honour all three" — their blurbs naming rangoli, the kitchen shelf,
      a dupatta fort.
- [ ] **Look:** Your portfolio → (photos off) the note asking a grown-up
      to turn them on; the "Your recordings" and "What you tried and made"
      rows open the two reused keepsakes. (Photos on, from For the
      grown-up) → "Keep a photo of something you made" → camera or the
      phone → a caption in her words → a tile in the grid → tap it → "Take
      it out". Then **Show it** → a black screen, "Made by Kabir", a row of
      who-for chips (Papa · Mumma · Dadi …) → "For Dadi, made by Kabir",
      swipe through. Nothing else on that screen, on purpose.
- [ ] **The who-for names** are restated in skilling (`kSkShowingTo`)
      rather than imported from the pregnancy invite screen; the list is
      mine — say if it should be the invite's six exactly.
- [ ] **Look:** For the grown-up → "Let her keep photos of what she made"
      (off by default) with its line about faces and names; "Delete her
      photos"; the parent note card, "Why this is a real skill, in plain
      words"; six small classes (₹999 / $12 placeholders, an art and a
      music per level); no coach (held).
- [ ] The keepsake vocabulary on this door — "I made something" finally
      reads right here. The same three words everywhere; yours.
- [ ] The hero photo — a child's hands painting stones, markers
      everywhere, no face (`photo-1596464716127`). Keep?
- [ ] The tile says "Making"; the brief's door is "Creativity &
      expression" and the bracket id is `skilling_creativity`. Fine.
- [ ] Not walked on a phone yet.

## The stage ships (§105) — 2026-09-22

`skOpenDoor` lost its `kDebugMode` gate on your call: a release APK opens
every built door, so anyone you hand the build to can walk the whole
skilling side. The ways IN were already release-visible (onboarding's
"Skilling — 6 and up", the pregnancy home's door shelf, the parenting
Explore drawer) and `test/skilling_doorway_test.dart` guards them; the
doors themselves were the last gate.

- [x] The Feelings off-ramp shows its helplines in every build now.
      Hiding anything flagged `verify` was right while only a developer
      could reach the door; once it ships, it left a child who tapped
      "Talk to someone" with no number at all. `verify` is a ledger flag
      (FE11), not a display filter. **Still owed, and not optional before a
      public launch: a lawyer and a clinician confirm both numbers and the
      sheet's wording.**
- [ ] **What a stranger now sees, and you may want to say out loud when you
      share the APK:** seven doors of twelve open, five keep their plan
      sheet; of the seven, only Coding, Communication and Confidence have
      real activity copy — the rest are "Coming soon" cards by design;
      Thinking, Stillness, Feelings and Making have never been walked on a
      device.
- [ ] **The journal's key custody (FE10)** is now on strangers' phones: the
      AES key sits in `shared_preferences` beside the data. Fine for a
      preview build, not for a launch — the platform keystore is owed.
- [ ] The preview screen's banner no longer says "in a debug build"; it
      counts the open doors from `kSkDoors` and says most are still
      filling up. Read it once and tell me if it oversells.
- [ ] The Explore drawer still labels the entry "Skilling (preview)".
      Honest while five doors are plan sheets; say if it should drop the
      word now that the stage opens.

## Cross-door windows

`sk_page/<door>/<page>` as a `toolSurfaceId` on a page with no blocks —
the parenting `pp_page/` idea. None yet; the first will be Communication's
"reads a story in Reading, retells it here" and the Confidence /
Communication split the Communication brief names.

| From | Into | Page | Status |
|---|---|---|---|
| Coding · `cd_811_12` Stuck? Try, Save, Try | Stillness | the settle-breath ("point to it, do not rebuild it") | Stillness built 2026-09-17: the page is `sk_page/skilling_stillness/sl_settle`; the activity's link to it is a fill-time call |
| Coding · `cd_1114_06` Why AI Gets It Wrong | Thinking | the "is this true" reasoning side | Thinking built 2026-09-17; its "Is this true?" set is the other half. The linking page waits on Coding's AI pages (coming soon) and Thinking's strand fill — the one defence, authored once when both exist |
| Coding · `cd_1114_12` Share It and Make It Better | Making (Creativity) | the private, family-only showcase posture | **Making built 2026-09-18**: its Show it is exactly that posture — a show mode on this phone, no link, no upload. Coding's activity stays offline-to-family as written |
| Making | parenting Early Learning | "the parenting stage already has art, messy play and making for younger children. This door is school-age. Cross-link at the 6 to 8 edge, do not duplicate" | owed — a fill-time call for the 6 to 8 band; the parent side exists |
| Making · showing it | Confidence, Communication | "'Showing it' is not public speaking. Sharing a made thing here is a different act from standing up to speak (Confidence) or saying it clearly (Communication)" | both built; the window is a line in the showing-it fills, not a page |
| Communication | Confidence | the shared speaking practice — Confidence owns the nerve and the audience, Expression the clarity and the back-and-forth; the recorder is built once (`sk_voice_keepsake.dart`) | owed — Confidence not built; it windows into Communication's prompt sets when it lands |
| Communication | Reading | "a child reads a story there and retells it here" | owed — Reading not built |
| Communication | Feelings | "Feelings owns naming the emotion; Expression owns putting it into clear words" | Feelings built 2026-09-18; the window is a page when the Feelings fill exists |
| Confidence | Communication | the shared speaking practice — Confidence dares to say it, Communication says it clearly; one recorder (`sk_voice_keepsake.dart`), used by both | built as the shared recorder; the prompt-set window waits on Communication's lesson fill |
| Confidence · `cf_breath` | Stillness | the quick calming breath — "Confidence references that breath for the moment before you speak, it does not build its own" | Stillness built 2026-09-17: `sl_settle` is the same circle, same numbers (a test holds the pattern identical). Whether `cf_breath` becomes a window onto `sl_settle` or keeps its own words is on the Stillness review list |
| Stillness · `sl_settle` and the calming / resting sessions | Focus, Feelings, Memory | "Stillness is the source, others borrow from it. Focus borrows a settle-breath to apply to a task, Feelings borrows a calming practice to handle an emotion, Memory borrows study-calm" | the source exists; the borrowers do not. Each references `sk_page/skilling_stillness/…` when built, never its own breath |
| Stillness | Feelings | "Feelings owns naming and understanding an emotion; Stillness owns settling the body. Cross-link tightly, keep each in its own home" | **built 2026-09-18** — Feelings' `fe_calm` is a window onto `sk_page/skilling_stillness/sl_settle`, the first cross-door window in the stage; nothing rebuilt |
| Feelings | Communication | "Feelings owns naming and understanding the feeling; Communication owns putting it into clear words. Name it here, say it there" | Communication built; its right-word activities already keep off feelings; the page-level window waits on the Feelings fill (clinical review first) |
| Feelings | Values | "Values owns moral character (what is right); Feelings owns emotional intelligence (what you feel). Empathy and kindness sit on the border" | owed — Values not built; Reading others is the skill on this side |
| Feelings | parenting Behaviour | "Parenting Behaviour is parent-facing and younger; this door is kid-facing and school-age. Cross-link, do not duplicate, and single-source any scenario content that genuinely matches" | owed — a fill-time call, scenario by scenario, once the clinician has reviewed them |
| Memory, Focus | Feelings | "Feelings is where the anxiety threads come home. Exam stress from Memory, focus worry from Focus. Those doors point here for handling the feeling; this door owns it" | owed — neither built; each points at Handling the big ones and the off-ramp when it is |
| Confidence | Feelings | "naming and handling the fear is Feelings" | Feelings built 2026-09-18; Handling the big ones is the skill; the page waits on the fill |
| Confidence · `cf_1114_01` | Thinking | Speak Up to a Grown-Up "cross-links to the Thinking door's 'question ideas, not elders' line; keep the tone consistent across both" | Thinking built 2026-09-17 on the careful framing (1a); the line lives in its parent note `th_parent_note` (coming soon) — the page id goes here when that note is written |
| Thinking · `is_it_true` set | Coding · `ai` set | "Thinking owns the reasoning (is this true, who says so, how would I know); Coding's AI literacy owns the mechanism (how AI generates content, why it errs and is biased); the two cross-link into one defence built once" | the cross-link slot: the set's blurb names the Coding door; both halves coming soon; the linking page is authored once when they exist |
| Thinking · `puzzles` set | Maths | "A logic puzzle is Thinking, a number puzzle is Maths" | owed — Maths not built; the set's blurb says which is which |
| Thinking · `th_course_1114_debate` and `fun` set | Communication | "Communication owns saying your point clearly and persuasively, Thinking owns the reasoning behind it and steelmanning the other side" | Communication built; its Hold a Real Back-and-Forth (`cm_1114_12`) hands the reasoning to this door in its parent line; the window is a page when the debate fill exists |
| Thinking · breaking it down | Coding | "Both break a problem down, Coding as computational thinking to build something, Thinking as first principles to understand something" | owed — the move's fill names Coding's Break It Down activities when written |

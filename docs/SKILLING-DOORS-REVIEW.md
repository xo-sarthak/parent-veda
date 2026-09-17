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
| Communication | `ParentVeda_Communication_structure.pdf` | door, 5 tabs (three band cards) | **3 of 3 filled** (6–8, 8–11 from the author's PDFs; **11–14 written by Claude Code**, with the other PDFs) | a86c5bf (frame), 0fa1193 (fills), e67da1b (walk), 11–14 fill commit next | **yes** — 2026-09-16, at 12 and 8, recorder end to end (11–14 fill not yet) | `sk_communication_door_test` |
| Confidence | `ParentVeda_Confidence_structure.pdf` | door, **6 cards** (three band cards + recorder + keepsake) | **3 of 3 filled** (36 activities) | 5eb85a4 (frame), 153b3a4 (walk), 6a78176 (fills + walk) | **yes** — 2026-09-17, at 8, frame and fills | `sk_confidence_door_test` |
| Creativity | `ParentVeda_Creativity_structure.pdf` | plan sheet | none yet | — | — | — |
| Feelings | `ParentVeda_Feelings_structure.pdf` | plan sheet | none yet | — | — | — |
| Focus | `ParentVeda_Focus_structure.pdf` | plan sheet | none yet | — | — | — |
| Maths | `ParentVeda_Maths_structure.pdf` | plan sheet | none yet | — | — | — |
| Memory | `ParentVeda_Memory_structure.pdf` | plan sheet | none yet | — | — | — |
| Reading | `ParentVeda_Reading_structure.pdf` | plan sheet | none yet | — | — | — |
| Stillness | `ParentVeda_Stillness_structure.pdf` | plan sheet | none yet | — | — | — |
| Thinking | `ParentVeda_Thinking_structure.pdf` | plan sheet | none yet | — | — | — |
| Values | `ParentVeda_Values_structure.pdf` | plan sheet | none yet | — | — | — |

Across all of them: `test/sk_doors_sanity_test.dart` holds that every
door's content and bracket exist, every surface resolves, every link lands,
every band tag is real, every coming-soon slot is owed, every window page
carries no copy, every live skilling cell resolves through the skilling
router, no scoring vocabulary is in the skilling tree, the keepsake has no
numeric member, and no shelf string promises a future.

## Coding (§55)

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

## Cross-door windows

`sk_page/<door>/<page>` as a `toolSurfaceId` on a page with no blocks —
the parenting `pp_page/` idea. None yet; the first will be Communication's
"reads a story in Reading, retells it here" and the Confidence /
Communication split the Communication brief names.

| From | Into | Page | Status |
|---|---|---|---|
| Coding · `cd_811_12` Stuck? Try, Save, Try | Stillness | the settle-breath ("point to it, do not rebuild it") | owed — Stillness not built; the builder note was dropped from the parent line |
| Coding · `cd_1114_06` Why AI Gets It Wrong | Thinking | the "is this true" reasoning side | owed — Thinking not built; the parent line names it in prose |
| Coding · `cd_1114_12` Share It and Make It Better | Making (Creativity) | the private, family-only showcase posture | owed — no sharing feature exists on either door; sharing here is offline, to a family member |
| Communication | Confidence | the shared speaking practice — Confidence owns the nerve and the audience, Expression the clarity and the back-and-forth; the recorder is built once (`sk_voice_keepsake.dart`) | owed — Confidence not built; it windows into Communication's prompt sets when it lands |
| Communication | Reading | "a child reads a story there and retells it here" | owed — Reading not built |
| Communication | Feelings | "Feelings owns naming the emotion; Expression owns putting it into clear words" | owed — Feelings not built |
| Confidence | Communication | the shared speaking practice — Confidence dares to say it, Communication says it clearly; one recorder (`sk_voice_keepsake.dart`), used by both | built as the shared recorder; the prompt-set window waits on Communication's lesson fill |
| Confidence · `cf_breath` | Stillness | the quick calming breath — "Confidence references that breath for the moment before you speak, it does not build its own" | built as the app's one circle in an `SkBreath` block; the Stillness page it should link to does not exist yet |
| Confidence | Feelings | "naming and handling the fear is Feelings" | owed — Feelings not built |
| Confidence · `cf_1114_01` | Thinking | Speak Up to a Grown-Up "cross-links to the Thinking door's 'question ideas, not elders' line; keep the tone consistent across both" | owed — Thinking not built; when it is, the line's page id goes here |

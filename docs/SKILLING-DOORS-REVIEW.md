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
| Coding | `ParentVeda_Coding_structure_v2.pdf` | door, 5 tabs + the shell | 3 of 3 exist, not yet mapped | — | no | `sk_coding_door_test` |
| Communication | `ParentVeda_Communication_structure.pdf` | plan sheet | 2 of 3 exist | — | — | — |
| Confidence | `ParentVeda_Confidence_structure.pdf` | plan sheet | 3 of 3 exist | — | — | — |
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
      changes daily, never recorded). With every slot coming soon it is a
      coming-soon card today. Fine until the fill?
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

## Cross-door windows

`sk_page/<door>/<page>` as a `toolSurfaceId` on a page with no blocks —
the parenting `pp_page/` idea. None yet; the first will be Communication's
"reads a story in Reading, retells it here" and the Confidence /
Communication split the Communication brief names.

| From | Into | Page | Status |
|---|---|---|---|
| — | — | — | none yet |

# Parenting doors — what needs the user's opinion

One list, per door, of the things built on a judgement call that the user
has not yet looked at or ruled on. Kept short so the review at the end is a
walk down this file, not a hunt through `STILL-OPEN.md` (which holds the
reasoning behind each line, by section number). Add to it as doors land;
strike a line when it is decided.

Decided so far, for all doors (2026-09-13): the shell on every door; six
tabs stay where a brief asked for six; the closing is a card; locked tabs
rather than hidden ones; tools lead a rail unless a tool names the read it
follows.

## Sleep (§39)

- [ ] The 3am story is drawn on the dark ground; the other stories are not.
      Keep it dark, or one look for all stories?
- [ ] The 4-month regression page is banded to 3–6 months only. Widen to the
      newborn band (the brief's hint) or keep?
- [ ] "Her sleep suddenly got worse" is a rail of one page. Fine, or merge?
- [ ] `pp_sleep_check` (the old "is she sleeping enough" screen) still
      resolves in the router; nothing in Sleep points at it. Retire it?
- [ ] The hero photo (a close face and fist, position out of frame). Swap
      if a better free one turns up; most "sleeping baby" shots show a front.

## Feeding (§41)

- [ ] FD4: the allergen walk-through forgets on close. Build the persistence
      (a store + `pp_allergen_intros` table) or leave it a walk-through?
- [ ] Clinical read of the choking sequence and the formula-amounts chart.
- [ ] `PpChartBrowserScreen` (the old chooser for the food chart) is kept
      and routed only for Sleep's dead `pp_sleep_check`. Retire with it?
- [ ] Two pages the brief's map did not name are kept: "He only wants
      biscuits and chips" (`picky_sweet_packet`) and `bf_biting`. Keep?

## Health (§42)

- [ ] HL5: the paracetamol/ibuprofen mg-by-weight table is commented out
      pending sign-off. Restore with a weight calculator, or keep the
      read-the-bottle framing for good?
- [ ] The fever check tool still has its own age chooser (the age rule says
      derive). Drop it?
- [ ] Six tabs — seen on the phone, kept; say if it still feels crowded.
- [ ] The hero photo (CDC, a stethoscope check-up) has a dated look. Swap?

## Development (§47)

- [ ] DV2: two milestone datasets (`MilestoneStore` vs `DevArea` skills)
      joined by a hand map. Merge into one list (a data job), or leave?
- [ ] The Ask Veda FAB sits over the last lines of every story screen (all
      doors). Hide it on stories?

## Behaviour (§48)

- [ ] BH13: the crying-too-much story — eight screens of safety copy in a
      new medium. Wants a clinical read.
- [ ] The carousel ring wraps, so the last (locked) card is the left
      neighbour of the open first card. Leave the ring, or stop it wrapping
      when a door has locked tabs?

## Potty (§49)

- [ ] The Indian-toilet page's badge is VIDEO (it leads with the film); the
      other film-led pages keep ARTICLE as the brief lists them. Badge
      follows the film everywhere, or as the brief?

## Early Learning (§50)

- [ ] For a baby, three of five tabs are locked (habits from 1, before
      letters from 2, school from 3) — the content's own banding. If it
      reads as too much grey, `_habits`'s `_fromOne` is the tag to question.
- [ ] The activity picker (`pp_activities`) is not a tool on the door
      because the first rail is the set. Fine, or wanted as a card too?

## First 40 Days (§51)

- [ ] FF10: build the real day-by-day spine ("you are on day 12", today's
      card lit) or keep the four day-range pages? The brief's lean: build
      the light version. Real effort; parked for speed.
- [ ] The quick-check and Ask Veda tools are not Tool cards on the door
      (their pages open them). Fine, or wanted as cards too?
- [ ] The sticky-eye slide on the skin carousel is one line I wrote, not
      the brief's copy. Keep, or replace when the copy comes?
- [ ] The mother's ownership line: First 40 Days keeps the acute recovery,
      You keeps the longer arc. Confirm before You is built.

## Every door

- [ ] Copy for every coming-soon card: `DOOR-CONTENT-OWED.md` P1–P8.
- [ ] The films and audios in the same ledger; the 58 story recordings first.
- [ ] The hub configs (`parenting_hubs.dart`) still describe the old two-door
      homes; the V3 tile bypasses them. Retire, or leave for the older home?

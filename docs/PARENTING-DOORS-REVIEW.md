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
- [x] The mother's ownership line — decided with You: You, Maa is the one
      home; First 40 Days' acute pages are windows into it.

## You, Maa (§52)

- [ ] The frightening-thoughts route is pinned in the red-flag treatment,
      eyebrow "READ THIS ONE FIRST". Right weight for a mother in distress,
      or should it be an ordinary first card?
- [ ] Going back locks with "From 2 months"; the band is called "6 weeks to
      3 months". Fix the wording per band, or leave?
- [ ] YM6: the six healing-kitchen recipes are pages here; the brief wants
      them tagged postpartum in the shared recipe library too. Do it?
- [ ] The consolidation reached back into First 40 Days (three pages and two
      cards are windows now). Walk that door once more and confirm it still
      reads as her recovery woven in.

## Cross-section windows — where one door opens another's page

Every place a card or link on one door opens a page that lives on another
(`pp_page/<section>/<page>` in the router). One copy, opened from wherever
the question arises; back returns to the door she came from. Listed so the
review can decide, per line, whether the window is right or the door should
carry its own version (each is a one-line revert: the copy sits in a
comment under the card, or the link is simply removed).

| From | Card or link | Opens |
|---|---|---|
| Feeding | If he chokes (safety) | Health · If he chokes or can't breathe |
| Feeding | Mastitis red flag → link | You, Maa · Sore, rock hard breasts |
| Health | Constipation | Feeding · Solids and constipation |
| Health | Allergies | Feeding · Introducing allergens safely |
| Potty | Diaper-free time → rash pictures | Health · Which rash is this? |
| Potty | She is holding it in → depth | Health · Constipation |
| Potty | Regressions → leaps | Development · Is my baby going through a leap? |
| Behaviour | Listening and cooperation (Three to six) | Behaviour · He does not listen (canonical) |
| Early Learning | Sharing / Waiting / Kindness / Truth / Screens habits | Behaviour · the in-the-moment page for each |
| First 40 Days | When the crying will not stop | Behaviour · When the crying is too much (the dark story) |
| First 40 Days | Your bleeding · After a normal delivery · After a C-section | You, Maa · the three acute recovery pages |
| First 40 Days | Your breasts in the early weeks · When you can get pregnant again | You, Maa · Sore, rock hard breasts · Sex, contraception and the two of you |

Plus the shared tools by surface id (not pages): the What Changed checker
(Health, Development, Behaviour, Potty), the Growth journey (Feeding, Health,
First 40 Days), the milestone tracker (Development, Early Learning), the
nuskhe library (Health), the scripts tool (Behaviour), Sleep's films and
safe-sleep drawing (First 40 Days), Feeding's latch film (First 40 Days).

- [ ] Any of the windows above that should be a door's own copy instead?

## Every door

- [ ] Copy for every coming-soon card: `DOOR-CONTENT-OWED.md` P1–P9.
- [ ] The films and audios in the same ledger; the 58 story recordings first.
- [ ] The hub configs (`parenting_hubs.dart`) still describe the old two-door
      homes; the V3 tile bypasses them. Retire, or leave for the older home?

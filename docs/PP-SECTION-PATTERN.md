# Building a parenting section — the pattern

> **Read this before writing a section.** Eleven parenting section specs arrived at
> once and are being built in parallel. This file is what keeps them one product
> instead of eleven. If your spec and this file disagree about *mechanism*, this
> file wins; if they disagree about *content*, the spec wins.

---

## The one rule

**You write DATA. You do not write layout.**

A section is a `PpSection` holding `PpArea`s holding `PpPage`s holding `PpBlock`s.
There is exactly one renderer (`PpSectionScreen`, `PpContentPage`) and you do not
touch it. No `Scaffold`, no `Padding`, no `TextStyle`, no `SizedBox` in your file.

Why this is not negotiable: every spec mandates the same page formats
("chart-card, comparison table, step-list, cards, short article, flagged
callout... not as generic prose"). Eleven authors each building their own
step-list produces eleven step-lists that don't match. This repo already shipped
three different bottom navigation bars for exactly that reason, each fixed once by
a different pass, and it took a shared component to end it. The cheapest moment to
avoid it is now.

The payoff you get for free: fix the step-list's spacing once and every step-list
in the parenting app moves. And "does every article have a when-to-worry callout?"
becomes a test over data instead of a reading of eleven screens.

---

## The files you create

For section `<name>` (one of: sleep, feeding, health, development, behaviour,
potty, early_learning, first40, you_maa, buying, traditions):

```
lib/screens/post_pregnancy/pp_<name>_content.dart   <- the section data. Almost all your work.
lib/screens/post_pregnancy/<name>_section_screen.dart  <- ONLY if you need a bespoke tool screen
```

Do **not** create a landing screen, an area screen, or a page screen. Those exist.

Your data file ends with one public top-level getter:

```dart
final PpSection kPpSleepSection = PpSection(...);
```

---

## What you import

```dart
import 'pp_age_bands.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';
```

That's it for the framework. Import your own helpers if you split the file.

---

## A complete worked example

This is a real, valid section. Copy its shape.

```dart
// =============================================================================
//  Sleep — the section's content
// -----------------------------------------------------------------------------
//  Built from docs/../pp_specs/01-sleep.md. Seven areas plus three tools.
//
//  ⚠️ NO SLEEP TRAINING ANYWHERE. The spec is explicit and it is a market fact,
//  not a preference: "near-zero India demand for sleep training and Indian
//  families co-sleep by default with no decision-anxiety". So no cry-it-out, no
//  ferberizing, and safe sleep is harm-reduction rather than abstinence —
//  "never bed-share" gets ignored, "here is how to bed-share more safely" gets
//  used and keeps babies safer.
// =============================================================================

import 'pp_age_bands.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

final PpSection kPpSleepSection = PpSection(
  id: 'parenting_sleep',              // MUST match the hub's bracketId
  title: 'Sleep',
  intro: 'Helping your little one, and you, sleep better.',
  bandSet: kPpSleepBands,
  areas: [
    PpArea(
      id: 'how_much',
      title: 'How much sleep does she need?',   // HER QUESTION, not "Sleep data"
      blurb: 'What is normal at this age, and the honest range.',
      hue: 206,
      pages: [
        PpPage(
          id: 'sleep_newborn',
          title: 'Newborn sleep, 0 to 3 months',
          format: 'CHART-CARD',
          bands: ['nb'],                       // shows only in the newborn band
          blocks: [
            PpIntro('Newborns sleep a lot, in short bursts, around the clock. '
                'That is not a problem to fix.'),
            PpChartCard(
              title: '0 to 3 months',
              rows: [
                ('Total sleep in 24 hours', '14 to 17 hours'),
                ('Day naps', '4 to 5, of 30 min to 3 hours'),
                ('Longest night stretch', '2 to 4 hours'),
              ],
              note: 'Waking every 2 to 3 hours to feed is normal and expected.',
            ),
            PpWhenLine('From birth to about 3 months.'),
            PpIndiaNote('In a shared room this often means she settles faster, '
                'not slower. You do not need a separate nursery.'),
            PpLink('Check the range for your baby\'s age',
                surfaceId: 'pp_sleep_check',
                blurb: 'Enter an age, get the normal range.'),
          ],
        ),
      ],
    ),
    PpArea(
      id: 'night_waking',
      title: 'She keeps waking at night',
      blurb: 'Why it happens, and gentle ways to settle her.',
      hue: 268,
      pages: [
        PpPage(
          id: 'why_babies_wake',
          title: 'Why babies wake',
          format: 'CARDS',
          blocks: [
            PpIntro('Almost every night waking has an ordinary cause. '
                'Here are the common ones.'),
            PpCards([
              PpCard('Hunger', 'A small stomach empties fast. Feed and settle.'),
              PpCard('Needing contact',
                  'She is checking you are there. A hand on her chest often does it.'),
              PpCard('Teething',
                  'Usually a few unsettled nights, then it passes.'),
            ], hue: 268),
            PpCallout('Waking is not a habit you have created. '
                'It is how baby sleep is built.'),
            PpCallout(
              'See a doctor if there is pain, poor weight gain, pauses in '
              'breathing, or a sudden change with no clear cause.',
              kind: PpCalloutKind.doctor,
              title: 'When night waking needs a doctor',
            ),
            PpVideoSlot(
              title: 'Gentle settling, demonstrated',
              subtitle: 'Patting, shushing and contact settling, shown on a real baby.',
              minutes: '6 MIN',
              slotId: 'sleep/settling_demo',
            ),
            PpConsult(
              title: 'Gentle infant sleep consultation',
              whoFor: 'For nights that have stopped feeling manageable. '
                  'Gentle and co-sleeping friendly. Never sleep training.',
              surfaceId: 'pp_experts',
              role: 'sleep',
            ),
          ],
        ),
      ],
    ),
  ],
  tools: [
    PpSectionTool(
      label: 'Sleep needs by age',
      blurb: 'Enter her age, see the normal range.',
      surfaceId: 'pp_sleep_check',
    ),
  ],
);
```

---

## ⚠️ Constructor shapes — get these right, they are not guessable

Six sections were written in parallel and half of them guessed these wrong,
producing ~400 compile errors. **Every list-style block takes its list as the
FIRST POSITIONAL argument.** Everything else is named.

```dart
PpArticle(['para one', 'para two'], heading: 'Optional heading')
PpSteps([PpStep('Title', 'optional detail')], heading: 'Optional')
PpCards([PpCard('Title', 'the line')], heading: 'Optional', hue: 268)
PpScript([PpScriptLine(say: '...', notThis: '...', why: '...')], heading: 'Optional')
PpCallout('text', kind: PpCalloutKind.doctor, title: 'Optional')
PpChartCard(title: '...', rows: [('label', 'value')], note: '...')
PpTable(columns: ['a','b'], rows: [['1','2']], heading: '...')
PpLink('Label', surfaceId: 'pp_x', blurb: '...')      // pageId: for a sibling page
PpConsult(title: '...', whoFor: '...', surfaceId: 'pp_experts', role: '...')
PpVideoSlot(title: '...', slotId: 'yoursection/thing', minutes: '6 MIN')
PpAudioSlot(title: '...', slotId: 'yoursection/thing', category: '...')
PpIntro('...')  PpWhenLine('...')  PpIndiaNote('...')
```

**`PpStep`'s detail is positional**: `PpStep('Do the thing', 'why it matters')`.
Not `detail:`.

---

## The four callout kinds

| kind | means | must |
|---|---|---|
| `PpCalloutKind.key` (default) | the one key point on the page | |
| `PpCalloutKind.doctor` | something may be wrong; here is who can tell you | **the PAGE must name a person** — doctor, paediatrician, clinic, hospital, physio, nurse, therapist, or "call" |
| `PpCalloutKind.safety` | here is the rule and what to do instead | ends in an action, names nobody |
| `PpCalloutKind.myth` | a belief stated and corrected | |

Use `safety` for "do not bed-share if anyone has been drinking, put him in a cot
instead" — that is a complete instruction and naming a doctor would be padding.
Use `doctor` when she genuinely needs someone to look.

---

## Hard rules the tests enforce (they will fail your build)

- **Every page's first block is a `PpIntro`.**
- **No em dashes** in any string. Use a comma or a full stop.
- **Slot ids are globally unique.** Namespace them: `yoursection/thing`.
- **Every band tag must exist** in your section's band set, and **every band must
  have at least one area** with something in it.
- **Bands must not overlap or leave a gap**: band N's `toMonths` must equal band
  N+1's `fromMonths`, and the first band starts at 0.
- **Area titles must not contain** `module`, `tracker`, `content`, `articles`,
  `section`, `data`, `engine`, `library`.
- **No `lorem`, `TODO:`, `TBD`, `XXX`.**
- **No paragraph over 900 characters.**
- **No gamification phrases**: `day streak`, `keep your streak`, `badge`,
  `leaderboard`, `you missed a day`, `points for`.
- **`PpConsult.whoFor` must be a real sentence** (>20 chars).

Run `flutter test test/pp_section_test.dart` before you finish. It checks all of
the above across every section at once.

---

## Every block type, and when to use which

| Spec bracket | Block | Notes |
|---|---|---|
| the warm opening | `PpIntro` | 2 to 3 lines. Every page starts with one. |
| `[SHORT ARTICLE]` `[ARTICLE]` | `PpArticle` | **A list of paragraphs**, never one string with `\n\n`. |
| `[STEP-LIST]` | `PpSteps` | Ordered. Use only when order carries information. |
| `[CARDS]` | `PpCards` | Unordered set. "One card per cause", "what NOT to do". |
| `[COMPARISON TABLE]` | `PpTable` | Scrolls sideways inside itself. First column is the axis. |
| `[CHART-CARD]` | `PpChartCard` | Structured label/value rows a tool can read. |
| `[CALLOUT]` | `PpCallout()` | The one key point. |
| `[FLAGGED CALLOUT]` | `PpCallout(kind: doctor)` | See a doctor. Never buried, never alarm-red. |
| a myth corrected | `PpCallout(kind: myth)` | |
| `[SCRIPT BOX]` | `PpScript` | The exact words to say, paired with what not to say. |
| "when / how much / what age" | `PpWhenLine` | The mandatory practical line. |
| India-home adaptation | `PpIndiaNote` | Joint family, shared room, malish, lori, climate. |
| a video | `PpVideoSlot` | Renders at real 16:9. Always give a `slotId`. |
| an audio track | `PpAudioSlot` | Renders as a real track row. Always give a `slotId`. |
| soft link to a tool/page | `PpLink` | `surfaceId: null` renders honestly as SOON. |
| the paid offer | `PpConsult` | `whoFor` is required. |

---

## Rules every spec shares — apply all of them

1. **No em dashes anywhere in copy.** Use a comma, a full stop, or "and".
2. **Plain warm English, short sentences, no jargon.** Write like a person who has
   your back, not a textbook.
3. **Never diagnose.** Anything clinical routes calmly to a doctor via
   `PpCallout(kind: doctor)`.
4. **No gamification.** No streaks, no scores, no "you missed a day". A count is
   fine; a streak is not.
5. **India-first.** Malish, joint family, shared rooms, lori, Indian climate,
   Indian foods, no separate-nursery assumption.
6. **No filler.** "Do NOT write filler. Each page must be genuinely useful on its
   own. If a page would only exist to look complete, drop it." Nine real pages
   beat twenty thin ones, and a thin page is the thing the reviewer will find.
7. **Reading and tools are FREE.** Only human help is paid. Never gate an
   article, chart, tool or player.
8. **Real placeholder copy, never lorem.** Write the actual sentences. Only the
   video and audio *files* are missing.
9. **English only for now.** Plain `String`, not `LocalizedText`.
10. **Age-band everything that needs it.** Tag `PpPage.bands` / `PpArea.bands` so
    a parent of a 3-month-old never sees the tantrum library. Bands narrow what
    *leads*, never what *exists*.

---

## Naming: her question, not our mechanism

From the First 40 Days spec, and it applies to every section:

> Label everything by the MOTHER'S QUESTION or the thing she DOES, not by the
> mechanism. Never ship an engineer label like "activities", "tracker" or
> "module" as a user-facing name.

- ✅ "She keeps waking at night" · "What do I feed her now?" · "Is this normal?"
- ❌ "Night waking module" · "Feeding content" · "Behaviour articles"

Hinglish where it is the natural word: **jaapa, malish, jhula, lori, su-su,
nuskhe**. Those are what the word actually is, not a style choice.

---

## Reuse, don't rebuild

Several specs say a cell is LIVE, meaning the app already has it. **Link to it,
never rebuild it.** Use `PpLink(surfaceId: '...')` with a real id from
`lib/screens/post_pregnancy/pp_surface_router.dart`. Existing ids you will want:

`pp_sleep` `pp_feeding` `pp_food` `pp_growth` `pp_vaccines` `pp_what_changed`
`pp_health` `pp_development` `pp_milestones` `pp_activities` `pp_read` `pp_watch`
`pp_courses` `pp_products` `pp_product_guide` `pp_recos` `pp_experts`
`pp_find_help` `pp_yoga` `pp_nuskhe` `pp_names`

If you need a NEW surface (a tool that does not exist), pick an id, use it, and
**list it at the end of your report** so it gets added to the router. Do not edit
the router yourself — eleven agents editing one switch is a merge conflict.

---

## Do not

- Do not run git.
- Do not edit `pp_content.dart`, `pp_age_bands.dart`, `pp_section_screen.dart`,
  `pp_surface_router.dart`, `parenting_hubs.dart`, or any file outside your own
  section. If you need a change there, report it instead.
- Do not delete or rewrite an existing screen. If a spec says "I don't like the
  current section, rebuild", build the NEW section alongside and report which old
  screen it supersedes. Comment out, never delete, is the repo rule.
- Do not add a `LocalizedText`.
- Do not invent a new page format. If you genuinely need one, report it.

---

## When you are done

`flutter analyze <your files>` must be clean. Then report:

1. The file(s) you created and the public `PpSection` getter name.
2. Area count, page count, and block count.
3. Any NEW `surfaceId`s you referenced that need router entries.
4. Any existing screen your section supersedes.
5. Anything in the spec you could not build, and why. Be explicit — a silent gap
   is worse than a named one.
6. Anything clinical or factual that needs a human to confirm. Mark it clearly.

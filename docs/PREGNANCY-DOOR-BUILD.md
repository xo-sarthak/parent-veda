# Building a pregnancy door — the playbook

**Read this before building one of the eight pregnancy briefs.** Everything here
was settled while building the first, **Scans & tests**, from
`ParentVeda_Scans_and_tests_rebuild.pdf` (30 Aug 2026).

It is the sibling of `docs/TTC-DOOR-BUILD.md`. That file is still correct about
the things both stages share — the wiring gate, the clinical rules, the layout
traps, the article floor — and this one does not repeat them. **Read both.**

---

## 0. What a door is, and what it is not

A door is the **landing** of one focus area, rebuilt as one page with five
sub-tabs. It replaces the "What do you need?" menu an area used to open on.

**It does not replace anything below that menu.** On Scans & tests the timeline,
the nine scan pages, the report locker, the decoder and its twenty-seven
findings are the same screens with the same content, reached one tap earlier.
The brief says so four times, and it is the single most important constraint:
*this is a reorganisation of a front door, not a rewrite of a stage.*

If your brief marks something `reuse`, you may not rewrite its text or its
title. If it marks something `reslot`, you move where it is reached from and
nothing else.

---

## 1. Before you write anything

**List what already exists for this area and say what it is wired to.** This is
the step that pays for itself. On Scans & tests, walking the code first found:

* `kScanCost` and `kPcpndtLine` in `scan_extras.dart` — the raw material for two
  of the four "new" India guides, already researched and already shipping on
  every scan page
* `ReportFinding.questions` — three doctor questions on each of 27 findings,
  which is **not** the same thing as the appointment checklist and would have
  been the wrong reuse
* the duplicate the brief spotted, confirmed in the source: `ReportScreen`
  renders `kReportFindings` whole under "All topics", so the popular six appear
  under both headings

A brief that calls something NEW is describing what the author wants, not what
the repo has.

---

## 2. Where your files go

| What | Where |
|---|---|
| Your door page | `lib/data/doors/pv_door_<area>.dart` |
| Your articles | `lib/data/reads/pregnancy_reads_<area>.dart` |
| New tool data | `lib/data/<area>_<tool>_data.dart` |
| New tool state | `lib/services/<area>_<tool>_store.dart` |
| New tool screens | `lib/screens/brackets/<area>_<tool>_screen.dart` |
| Your tests | `test/pv_door_<area>_test.dart` |

**Shared, and the only lines you may touch in them:**

- `lib/data/doors/pv_door_data.dart` — one `import`, one entry in `kPvDoorPages`
- `lib/data/reads/pregnancy_reads.dart` — one `import`, one spread
- `lib/screens/doors/pv_door_router.dart` — one `case` per surface you add

Everything else is off limits. If you think you need to change
`pv_door_screen.dart`, `pv_door_carousel.dart` or `pv_reader_screen.dart`,
**stop and say so** — those are shared with the other seven briefs.

`test/pv_door_scans_test.dart` walks `kPvDoorPages`, so your door inherits every
reachability gate the moment you register it.

---

## 3. The structure is five sub-tabs, and the selector is a carousel

A door is a `PvDoorPage`: a hero, a list of `PvDoorGroup`s, and a list of
`PvDoorSection`s each naming its group.

**The selector is `PvDoorCarousel`** — design 4a, "Carousel · mist falloff":
five cards on one 3D track, the chosen one flat and forward, the rest receding
in three steps with a blur that grows with depth. It is a port of the control on
the TTC fertile-window door, and there are now **two copies of its geometry**. If
the design moves, both move.

**Why a carousel and not a row of tabs.** The objection that kept sub-tabs out of
this app for a long time is about *choosing blind*: a tab bar lights one word,
hides the rest, and tells you nothing about what is behind them. This is not
that. All five are on screen from the first frame, named, before anything is
chosen.

Two layouts, and your brief will tell you which each tab is:

* **`PvDoorLayout.rails`** — a heading and a horizontal scroll of cards. What the
  brief calls a card rail.
* **`PvDoorLayout.stack`** — full-width rows. What the brief calls a **tool
  screen**. A rail says "there is more sideways"; on a tab with a tool above it
  and two errands below, there is not.

**A tool tab renders its tool IN PLACE** via `PvDoorGroup.inlineSurfaceId`. A
card in front of a tool, inside a tab whose main content is that tool, is a door
in front of a door.

---

## 4. Rendering a shipped screen inside a tab

This is the one genuinely new piece of engineering, and it has two shapes.

**Extract a body.** `ScanTimelineScreen` and `ScanReportsScreen` became thin
`Scaffold` wrappers around `ScanTimelineBody` and `ScanReportsBody`. The
extraction is a **move** — same children, same order, same spacing — so the
screen still routes at the same id and still looks identical.

**Or add an `embedded` flag.** `ReportScreen`'s content is inseparable from its
filter state, so a body widget would either duplicate that state or wrap it. The
flag changes chrome only: no `Scaffold`, no app bar, no page padding.

Three rules that fall out, each of which has already cost time somewhere:

* **A body returns a `Column`, never a `ListView`.** A scrolling widget inside
  another scrolling widget is either unbounded or a nested scroll nobody can
  drive with a thumb. The door's own list does the scrolling.
* **The door must listen to the stores its inline tools read.** `PvDoorScreen`
  merges `ScansStore` and `ScanReportsStore` into its own `AnimatedBuilder`. A
  body's own listener cannot help it when its `Scaffold` is not on screen — miss
  this and the tool works perfectly on its own screen and looks frozen in the
  tab.
* **Never nest a `Scaffold`.** Second background, second safe area, unbounded
  height.

---

## 4a. Two condition libraries, and why both stay — DECIDED 2026-09-10

You will find the same subject written twice, and it is not a bug to clean up.

| | `kAllConditions` (`conditions_data.dart`) | `kReportFindings` (`report_findings_data.dart`) |
|---|---|---|
| Answers | "my doctor said I have X" | "my report says X" |
| Shape | 8 parts: what it is, how common in India, symptoms, call-now vs monitor, tests to confirm, management in India, baby impact, FAQ | 7 parts, reassurance-first: what it means, how common, what happens next, when it is discussed, questions to ask, things to remember, a fixed reassurance |
| Voice | management-led | reassurance-led |
| Owned by | Complications & conditions | Scans & tests (the decoder) |

Six subjects share an id outright — `anemia`, `breech`, `fibroids`, `high_bp`,
`preeclampsia`, `rh_negative`. Five more share a subject under different ids:
`gdm`/`gestational_diabetes`, `placenta_previa`/`low_lying_placenta`,
`low_amniotic_fluid`/`low_fluid`, `iugr`/`small_baby`,
`polyhydramnios`/`high_fluid`.

**The rule: one page per QUESTION, not one page per word.** A woman holding a
report that says "breech" at 11pm and a woman whose obstetrician has just told
her the baby is breech want different objects — the first wants to know whether
to panic, the second wants to know what happens now. Collapsing them would make
one of those two readers worse off, and it is not obvious which.

So when the Complications brief says *"never keep a second copy of a
condition"*, read it as **never a second copy of the same ANSWER**. Two answers
to two questions are two pages.

**In practice:**

- A door links to the library that matches the question its tab is asking.
- Complications does not own `nuchal_cord` or `low_lying_placenta` — neither
  exists in `kAllConditions` — so its "when it usually comes up" rail links to
  the findings library for those two. That is the rule working, not an
  exception to it.
- **Never copy an entry between the two files.** If a subject genuinely needs
  both voices, it gets an entry in each, written for its own question, and the
  pair is recorded in `test/pv_door_complications_test.dart`.

Do not re-litigate this per door. If it ever changes, it changes here first.

---

## 5. The formats

Seven, and adding an eighth is deliberate work: a value on `PvDoorFormat`, a
case in its `label`, a case in `pvDoorFormatIcon`, and a case in
`openPvDoorTile` — which the compiler will demand, because the tile hierarchy is
sealed and the switch is exhaustive.

| Chip | Tile | Opens |
|---|---|---|
| Tool | `PvDoorToolTile` | a surface |
| Article | `PvDoorScanTile` | a scan page in `kTestsScans` |
| Guide | `PvDoorGuideTile` | a `PvRead`, optionally at a heading |
| Read | `PvDoorReadTile` | a lookup surface, or nothing (coming soon) |
| Myth vs fact | `PvDoorMythTile` | a `PvRead` whose **first** section is the myth |
| Checklist | `PvDoorChecklistTile` | a surface |
| Talk | `PvDoorTalkTile` | the booking engine |

**The chip is a promise about what the tap does — including how long it is.**
That is why a myth tile's read must carry its `mythFact` in `sections.first`,
asserted by the wiring test: a chip promising a claim and a correction that
opens seven hundred words with the correction in section three is a chip that
lies.

**Coming soon is a state, not a format.** `PvDoorTile.comingSoon` draws the card
at full size with its real title and an honest chip, and makes it untappable. A
placeholder occupies the real geometry so nothing shifts the day the piece
lands.

---

## 6. Language

Your briefs are all written for the same audience and all carry the same rule.
It is worth stating mechanically because it is easy to half-apply:

> **A medical name survives only as a card TITLE, where it is the exact word
> printed on her report or her timeline** — she has to match the card to her
> paper. It always carries a plain one-line blurb. **Never a jargon word in a
> heading or a blurb we write.**

So "NT scan" stays, and reads *"Checks the baby's early growth and
development."* Not "nuchal translucency measurement", and not "the early growth
check" — the first is jargon and the second cannot be matched to her slip.

Where a brief gives a card line in quotes, **it is a contract.** Six of them are
asserted verbatim in `pv_door_scans_test.dart`.

New copy is English. See CLAUDE.md.

---

## 7. Ask Veda

Every brief says the same thing and it is the shortest section here.

**Do not add it as a card. Do not build an entry point. Do not change how it
looks.** It is already app-wide — the floating sparkle button and the "Still
worried? Ask Veda" prompt.

The only thing owed is that it receives the page's context when opened from a
content page, and **that already works**: `global_ask_fab.dart` reads the route
name. Which is why every push in `pv_door_router.dart` carries
`RouteSettings(name:)`, and why the surface ids are constants rather than
literals typed twice.

An anonymous route here does not fail, crash or log. The screen opens, looks
right, and the sparkle button quietly asks the wrong brain.

---

## 8. Red flags

`PvDoorGroup.pinnedRedFlag` renders above everything in its tab, never in an
accordion, in coral rather than scarlet — `danger` in this design system is for
destructive confirmation, and a red block shouts at somebody already
frightened.

Three rules:

* **It references the existing list, it does not retype it.**
  `kPregnancyUrgentFlag` derives its lines from `kScanUrgentSigns`. Typing them
  onto the door would put a clinical warning in two places, and the day one is
  updated they disagree — with the one on the landing being the one she reads
  first.
* **The list is shown whole or not at all.** A brief naming two signs in passing
  is giving examples, not an edit. Trimming would have dropped shoulder-tip
  pain, which is the classic sign of a ruptured ectopic and the entry a layout
  compromise drops first.
* **One tab, not the landing.** `scans_hub_v2.dart` removed the urgent strip
  from the old landing because *nobody discovers an emergency by scrolling*, and
  a records screen should not be alarming for the thousands of people who are
  fine. That argument is honoured by pinning the flag on Talk — which somebody
  opens because they are already thinking about reaching a person — and nowhere
  else on the door.

---

## 9. Retiring the old landing

**Comment out, never delete.** On Scans & tests, `ScansHubScreen`,
`scans_hub.dart`, `scans_hub_v2.dart` and `scans_hub_version.dart` all still
ship with their tests; the push in `home_v3_screen.dart` and its import are
commented with a note saying what they were. Restoring the toggle is
uncommenting six lines.

**Check the door before the hub registry** in `_openBracket`. An area with both
has a door because somebody decided the hub was the wrong shape for it, and
falling through would silently keep the shape that was replaced.

**Keep the route name.** `bracket/scans` is unchanged — see §7.

---

## 10. Finishing

- `flutter analyze` clean of **new** issues (count the baseline before you
  start; it was 24 on 2026-09-10)
- full suite green
- **do not run git.** Provide the commands with explicit file paths.
- Report: files changed, what was reused vs newly written, and **every tile with
  no content behind it yet** — named, not summarised.

---

## 11. Checklists are shared now — DECIDED 2026-09-10

Every brief has a "before your appointment" tab, so the second one generalised
the system rather than copying it.

| What | Where |
|---|---|
| The model + registry | `lib/data/checklists/pv_checklist.dart` |
| Your list | `lib/data/checklists/pv_checklist_<area>.dart` |
| The store (all lists) | `lib/services/pv_checklist_store.dart` |
| The screen (all lists) | `lib/screens/brackets/pv_checklist_screen.dart` |

Adding one is a data file, one entry in `kPvChecklists`, and one router case.
**Do not write a checklist screen.**

Three things to get right:

* **`PvChecklistItem.id` is an identity.** It is persisted. Reword the text
  freely; renaming an id empties somebody's list *silently* — the row comes back
  unticked and looks like it was never ticked.
* **`subject()` is what makes it hers.** It derives what the list is about from
  the area's own store — the next scan, the condition she added — so the heading
  reads "What to ask at your anomaly scan" rather than "…at your next scan".
  Returning null is a real answer and the list still works completely.
* **If your `subject()` reads a new store, add it to
  `pvChecklistSubjectStores`.** One line. Forget it and the heading goes stale
  in place, which looks like nothing.

**No counters.** No progress bar, no "4 of 18", no streak. A counter on a list
of things somebody is nervous enough to write down is a debt statement, and
every brief's DO NOT list ends with this.

---

## 12. Two flags on one door is legitimate

Complications pins two: the assembled same-day condition list on its safety tab,
and the stage's standing pregnancy list on Talk. They are different lists
answering different questions, and collapsing them would either put
condition-specific lines on a general warning or drop the general ones from a
safety tab.

**Where a brief asks for a red flag "assembled from existing content", assemble
it.** `same_day_signs_data.dart` is the worked example: each line names the
condition whose own CALL NOW section it came from, and
`pv_door_complications_test.dart` asserts that condition really says it. A
red-flag list typed fresh into a data file has had none of the clinical review
the pages passed, and it sits *above* all of them in the reader's attention.

`PvDoorFlagLine.conditionId` gives a line its own destination where it has one.
Null means the flag as a whole owns the destination — which is right for
symptoms of a pregnancy rather than of a named condition.

# Problem Hubs — what we have, what we're building, and the restructure

Response to the product reviewer's note on the **L1 + L2 Master** sheet.
**Nothing in this document has been implemented.** It is the audit and the plan.

---

## 1. The verdict on the review

**The core argument is right and we should adopt it.** *"Column B is the problem hub, D–J
are the ways of solving it, and the order changes per problem"* is a better model than
what the app does today — and it is the same conclusion the Scans & tests work reached
independently, which is a good sign rather than a coincidence.

Two things are already true in the codebase and worth knowing before planning:

- **The Scans hub is already built to this model** and can be looked at on a device. It
  leads with an emergency strip, then one situational card, then four *lifecycle* doors —
  not seven layer sections. The reviewer's "Timeline + interpretation" template exists.
- **"Products only where they genuinely help" is already a rule with teeth**, not an
  intention. The bracket table marks Products `notApplicable` on Scans, IVF and After a
  loss, and a test fails if a shopping row appears on any of them. The reviewer's
  instinct is already encoded and enforced.

### Three places I would push back

**(a) On Consult placement.** The review puts consult near the bottom, *unless* the
problem is clinical, in which case near the top. I think position is the wrong axis.
Consult should appear at the **moment of need**, which is usually neither: on Scans it is
not a section at all — it sits directly after a decoded report finding, which is the
exact moment a second opinion becomes the most useful thing on the page.

*"Talk to someone"* sitting in a list is furniture. It is there before she needs it, so
she scrolls past it, and by the time she needs it she has forgotten it exists.

**(b) On "the order should be algorithmic."** Agreed in spirit — and I would **not** build
an intent engine. The Scans smart card gets roughly 80% of this from three `if` statements
over state we already store: is a scan booked, what week is she, did she add a report
recently. **Ship the if-statements across all forty hubs first.** A real intent
classifier is a research project that would delay every hub behind it, to win the last
20%.

**(c) On "coming soon" everywhere.** The instinct is right and the naive version is
dangerous. See §5 — there is a rule that makes it safe, and we already have the data
model for it.

---

## 2. THE INVENTORY

### 2a. Video — the slot is built, the media plugs in

Video is a **first-class format in the plan and a deliberate build order**: the shell
comes first, the films arrive into it.

What already exists on the engineering side: the native player, the categories, the
collections and channels, the quick-versus-deep modes, the analytics, and **41 curated
video entries** across pregnancy and parenting — each with its title, duration, expert,
age or week window, "why this matters now" line, and its links across to the related
article, activity, recipe and product.

What that means for this restructure: **every hub's Learn layer should be built with its
video slot in place from day one.** The row, the thumbnail, the duration, the position in
the reading order — all of it laid out and rendering, so that publishing media is a data
change and nothing else. No layout work, no re-design, no re-wiring.

⚠️ **This is the clearest plug-and-play case in the whole plan, and the reason to build
the slots now rather than later.** A Learn section designed without video and retrofitted
with it means touching forty screens; a Learn section designed *around* it means touching
one data file.

**What is needed from the content side:** the media itself, per bracket. That is a
production schedule question rather than an engineering one, and the hubs do not wait on
it.

### 2b. Content, by format

| Format | What we have | Verdict |
|---|---|---|
| **Deep structured explainers** | `tests_scans_reports_data` 1,424 lines · `can_i_data` **199 entries** · `spiritual_reading_data` 1,978 lines · `report_findings_data` **12 findings**, each with what-it-means / how-common / what-next / questions-to-ask | **Very strong.** Our real asset |
| **Weekly serial content** | `weekContent.json` — **all 37 weeks (4–40)**, 11 sections each: baby, mother, nutrition, action plan, garbh sanskar, partner corner, reflection | **Very strong** |
| **FAQs** | `kFindings` FAQs · `pp_phase_faqs` | Good |
| **Short reads / articles** | Pregnancy **25** · Parenting **17** · TTC chapter content 563 lines | **Thin.** Each hub wants 3–5 |
| **Video** | 41 curated entries, slots to be built into every hub | Media in production |
| **Recipes** | Parenting **33** · pregnancy nutrition plans | Good on parenting only |
| **Community** | 88 seeded posts | Fine |

**The shape of our content is: deep on reference, thin on browsable.** We are excellent at
*"explain this properly"* and light on *"read three minutes / watch five"* — which is
exactly the layer the reviewer's Learn section calls for. Worth knowing, because it means
the Learn layer should **lead with our explainers** and treat short reads and video as
what sits alongside them, rather than the reverse.

### 2c. Tools, by stage

| Stage | Built | Named in the review, not yet built |
|---|---|---|
| **Pregnancy** | 16 tool screens — kick counter, weight, kegel, contraction timer, hospital bag ×2, medicine tracker, symptom companion, scans & appointments, due-date calculator, tests & reports, product checklist, garbh games | BP/sugar log · meal planner · mood check · birth-plan builder |
| **TTC** | Cycle tracker, ovulation, fertile window, calendar, daily log (symptoms, weight, sleep, mood, stress, lifestyle), tests, supplements, medication, records | **PCOS symptom checker** · "should I see a specialist?" checklist · pre-pregnancy checklist · BMI |
| **Parenting** | Sleep · feeding · growth · milestone journeys, feeding and sleep trackers, vaccination tracker, What Changed (29 concerns), health wallet | **Wake-window calculator** · sleep-plan generator · behaviour script library · development screener |
| **Skilling** | — | All of it: rubric trackers, record-and-review, drills, portfolio |

Roughly **twelve tools** across three stages, each small and each unlocking a hub's
primary action.

### 2d. Commerce, courses and people

| | Pregnancy | TTC | Parenting | Skilling |
|---|---|---|---|---|
| **Products** | 32, **with images** | 8 | 23, image field to add | — |
| **Courses / masterclasses** | 13 masterclasses + 4 cohorts | **13 priced offerings** | 15 | — |
| **Consults** | 9 specialists | named expert per offering | 6 experts | — |
| **Activities** | 23 garbh sanskar · yoga | daily ritual | 6 grow · 34 yoga · 22 nuskhe | — |

**TTC has the strongest paid layer in the product** — thirteen offerings with named
experts, matching the workbook's asks almost cell for cell. Pregnancy and parenting have
comparable inventory with mock slots.

---

## 3. What is needed, ranked by how much it blocks the restructure

1. **Short reads.** 42 across two stages; each hub wants 3–5. The most common gap.
2. **Video media**, per bracket — slots built now, films published into them (§2a).
3. **Skilling content.** 84 declared cells, none resolved yet — the whole stage.
4. **The twelve tools** named in §2c.
5. **Parenting product images** — an image field on the model plus the photography.
6. **Content tagging.** See §6 — the strategic one.

---

## 4. The restructure

### 4a. What changes

Today a bracket door opens `BracketScreen`: four to seven sections headed **Content ·
Activities · Tools · Products · Course · Consult · Extras**. Those are the workbook's
column names — our filing system, shown to the user.

After: a bracket door opens a **problem hub** whose sections are in *her* language and
whose order is set by the problem. The workbook's columns become the **inventory behind**
each hub, never its headings.

> **The user should never have to understand our content architecture in order to solve
> her problem.** She should only have to understand *"what am I dealing with"* and
> *"what do I want to do about it".*

### 4b. Six templates, not forty designs

The reviewer's six flow types map onto our forty brackets cleanly. Assigning each bracket
a template is the single decision that turns this from forty design jobs into six.

| Template | Order | Brackets |
|---|---|---|
| **Immediate answer** | Answer → Tool → Content → Consult | Is it safe? · Symptoms · Health & illness · Behaviour · Complications |
| **Tracker-led** | Tool → Interpretation → Content → Products | Fertile window · Scans & tests · Sleep · Feeding · Growth |
| **Learn & plan** | Content → Tool/Activity → Course → Consult | Nutrition · Labour prep · PCOS · IVF · Preconception health |
| **Practice-led** | Practice → Tracker → Content → Program | Garbh sanskar · Fitness & yoga · Mind-body prep · Stillness · skilling practice |
| **Decision / commerce** | Guide → Compare → Products | Buying guides · Belly & skin · Male fertility products |
| **Long-term development** | Understand → Practice → Track → Program | Milestones · Early learning · Potty training · the 12 skilling brackets |

Two brackets get bespoke treatment and should not be forced into a template:
**Trying again after loss** — one door, and it is a person — and **First 40 days**, which
is a guided day-by-day journey and effectively a small product of its own.

### 4c. The hub anatomy, shared

Every hub has the same skeleton whatever its template. Only the ORDER and the prominence
change:

```
  hero — the problem, in her words
  [ an urgent strip, only where the problem has red flags ]
  ONE situational card          ← from state we already store
  "What do you need?"           ← 2–4 entry points; the template decides which is first
  ── the layers, re-labelled and re-ordered ──
  Understand  (Content)    Do      (Activities)   Check  (Tools)
  Go deeper   (Course)     Things  (Products)     Talk   (Consult)
```

**One situational card, never a stack.** The moment it becomes three cards it is a feed,
and a feed is something she has to read rather than something that has already answered
her.

### 4d. Reused versus new

**Reused, rewired:** every existing tool screen, the whole content library, recipes,
products, courses, consults, community — and the bracket resolver, which stays the
permission chokepoint so a hand-designed hub can never show a layer its bracket refuses.

**New:** the hub screen, the twelve tools, and the placeholders.

### 4e. Depth: three levels, never four

```
L1  the door          the V3 grid
L2  the problem hub   this restructure
L3  the thing itself  a tool · an article · a scan page · a decoder term
```

At four levels she cannot remember the path she took, back becomes lossy, and the deep
screen stops being reachable any other way — which is how content gets built and never
seen. Every L3 stays reachable from elsewhere too: the weekly flow, search, Ask Veda. A
hub is *a* way in, never the only way in.

---

## 5. The placeholder rule

A thing that is planned should show its **shape**, so the flow is visible and publishing
it later is a data change. Done naively this is dangerous: forty brackets by seven layers
is 280 cells, and an app where every screen carries three "coming soon" tiles reads as
abandoned and teaches people to stop tapping.

**The rule that makes it safe — and the data model already encodes it:**

| Bracket state | What shows |
|---|---|
| `live` | the real thing |
| `notReady` | **the placeholder: right shape, right size, right position, "Coming soon"** |
| `notCore` | **nothing.** It lives on another surface; a placeholder here would be a lie |
| `notApplicable` | **nothing, ever.** The workbook refused it, with a reason |

That mapping turns the request into something the existing tests already police. Two
constraints I would add:

- **At most two placeholders visible per hub.** Beyond that they stop reading as *coming*
  and start reading as *broken*.
- **Never on an urgent or grief path** — not on After a loss, not on the scan red-flag
  screen. Someone frightened does not need to learn what we have not finished.

**Worked example — "Myths" under Conceiving, with the articles still to be written:** the
Understand section renders its real rows, plus one muted tile at the correct size reading
*"Myths about conception · Coming soon"*. When fifteen articles arrive, the tile becomes
a list and no layout changes.

**The same pattern is exactly how video should be built** (§2a): the row, thumbnail,
duration and position all laid out now, so publishing media touches one data file rather
than forty screens.

---

## 6. The one strategic decision

**§8 of the review — tagging every content asset against stage / problem / sub-problem /
age / intent / format — is the highest-leverage item in the note, and the most
expensive.**

Without it every hub is hand-wired: someone decides that *these five articles* belong on
*that* hub, and it drifts the day new content is added. With it, hubs populate themselves
and new content lands in the right place automatically — which is what makes the growing
library compound instead of needing maintenance.

The cost is real: it touches every content file we own. The honest sequencing:

> **Tag the two stages we are actually shipping — pregnancy and parenting, not all four —
> and only the four fields the hubs actually read: problem, sub-problem, intent, format.**

Stage and age we already derive. Expertise level nobody has asked for yet. Those three
can be added later without redoing the first pass.

---

## 7. What needs deciding before building

1. **Six screens, or one screen with a per-bracket order?** I recommend **one screen with
   a declared order per bracket** — forty configs rather than six codebases, and a bracket
   can then be reordered without a rewrite.
2. **Which stage first?** I recommend **finishing pregnancy's ten**: Scans is already
   built to the pattern, and pregnancy has the most content to prove it against.
3. **The Learn layer's default composition.** Given §2b, I would have it **lead with our
   explainers**, with short reads and video alongside — rather than a video-first layout
   that depends on the publishing schedule.
4. **Content tagging at the reduced scope in §6** — approve or not.
5. **The ₹ scan cost ranges** already written into `scan_extras.dart` need a review pass
   before launch. They are researched public ranges, not a rate card, and a wrong number
   is worse than none because it gets quoted at a counter.

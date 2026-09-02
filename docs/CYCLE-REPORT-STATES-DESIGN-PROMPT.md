# Cycle report — the four states that were never designed

For the Claude Design project. Paste from **The prompt** down.

---

## You did send a cycle report design, and it is built

`Cycle Report.dc.html` — three artboards, a dial, a calendar and a road. Two
ship behind a **Dial | Calendar** toggle, the road's timeline was lifted into
both, and the whole thing is live. So this is **not** a re-do.

What that design drew was **one state out of five**: a cycle with a period
logged, an estimate available, and four stretches to show. `TtcReportState` has
five, and the other four are still wearing the old screen's chrome — which is
why the report currently has two different looks depending on her data. That is
recorded as `docs/STILL-OPEN.md` §19.3 and it is the last thing owed on this
screen.

**Where to look:** TTC home → the daily rail → **Cycle report**. Also the
insight card on that home, and **See your cycle report** at the foot of the
symptom logger. And, since the Companion rebuild, **See this month in full**
inside the "This cycle" card.

---

## The four states, and why each exists

These are not error paths. Three of them are what a new user sees.

| State | When | What we may show |
|---|---|---|
| **Nothing logged** | no period ever recorded | an invitation; there is no data at all |
| **Thin** | a period is logged, an estimate exists, but almost nothing else | the picture and the stretches — but no findings, because there is nothing honest to say |
| **No estimate** | the engine refuses — a gap long enough to be an unlogged month, or too little history | her logged days, **no phase colours at all** |
| **Clinic-held** | a clinic is directing this cycle | her logged days, **no phase colours at all**, and it is a deferral not a shortage |

The last two are **refusals**, and the distinction between them matters more
than it looks:

* **No estimate** is "we cannot say". The data is not good enough, and saying so
  is more useful than a confident wrong answer. The app once printed *"ovulation
  around day 40"* off a 54-day gap that was really an unlogged month, and there
  is a test named after that defect.
* **Clinic-held** is "it is not ours to say". She may have months of perfect
  data; a doctor is directing the cycle, and we do not put a second estimate
  beside theirs. Framing this as a data problem would be wrong and slightly
  insulting.

Both must show her own logged days. **Refusing to interpret is not refusing to
show.**

---

## What already exists, so nothing is designed twice

Do not redesign these — they ship and they are approved:

* the **dial** and the **calendar**, with their toggle
* the **four-stop timeline** — connected dots, `20 – 24 Aug · 5 days · done`,
  the "YOU ARE HERE" pill, a slow breathing halo on the current stop
* the **cycle picker** — ◀ *Chosen cycle* ▶, to page back through months
* the **weight / temperature chart** — axis, unit, date ticks, phase bands,
  marker rows — shown whenever there are two or more readings
* the **findings** cards
* the **ⓘ disclaimer** in the header

Each state needs to say which of those it keeps, which it drops, and what
replaces what it drops.

---

## Copy that already exists and is reviewed

Reuse or improve these rather than inventing new ones. They are in
`ttc_strings.dart` and they have been through a clinical read:

* Nothing logged — **"This fills in as you log"**
* No estimate — **"Not enough to place the phases"**
* Clinic-held — **"Your clinic is running this cycle"**
* Thin — **"A start"**

---

## Rules that do not relax

Enforced by tests that scan source text, so a design leaning on any of these
cannot be built as drawn.

* **No personalised probability.** No "your chance this month", no score, no
  percentage, no match label.
* **No diagnosis**, and no red alarm states. Irregular cycles are common and are
  not a failing.
* **A refusal must not read as an error or as a gap.** No warning colour, no
  broken-state iconography, no empty rectangle where a chart would go.
* **Findings are a count or a position, never a cause.** "Cramping on four days,
  mostly in the waiting days" is allowed; "because", "suggests", "indicates" and
  "chance" are not — literally, there is a test scanning for those four words.
* **Silence is a valid output.** Below a week of logging the report says nothing
  rather than padding. A sentence that restates the chart above it is not a
  second piece of information.

## House style

Fraunces headings, Manrope body. Hue 288 for the field. Buttons are **white with
a hairline and an ink label** — no filled coloured bars. Hairlines, not shadows,
inside a sheet. Drawn marks, never emoji. Design at **360pt**.

---

# The prompt

*(paste this into the design project)*

---

Design the **four quiet states** of the ParentVeda cycle report. The main state
— a full cycle with a ring, a calendar and a four-stop timeline — is already
designed and built; do not redesign it. These four are the ones a real user hits
constantly and that were never drawn.

The report is a monthly read-back: it shows one cycle, the four stretches it
divides into, and anything she logged during it. Its audience is Indian women
trying to conceive, mostly reading English as a second or third language, often
anxious. One idea per sentence.

All four sit under the same header: a back arrow, the title **"Your cycle
report"**, an ⓘ, and a **◀ Chosen cycle ▶** picker for paging between months.

**Design these, at 390pt:**

**1 · Nothing logged.** No period has ever been recorded, so there is no cycle
to draw. This is what most people see first. It should make the first log feel
worth doing, and say what it will buy. Not a shrug, not an empty rectangle.

**2 · Thin.** A period is logged and the four stretches are known, so the
picture is there — but she has logged almost nothing else, so there are no
findings. Show what an unfinished month looks like without making it feel like
a failure or a nag. The honest message is closer to "a start" than "add more".

**3 · No estimate.** The engine has refused: one gap in her history is long
enough to be a month that was not logged rather than a cycle that long, so
estimating from it would produce dates we do not believe. **No phase colours
anywhere on this screen.** Her logged days still show, uncoloured. Design what a
month looks like with her data present and our interpretation withheld — and
make it read as a considered decision, not a broken chart.

**4 · Clinic-held.** A fertility clinic is directing this cycle. Same visual
refusal — her data, no phase colours — but a completely different reason, and
the copy must not blame her data. This is "a doctor is guiding you and we do not
put a second estimate beside theirs." If anything, this state should feel
*reassuring*.

Also show, for whichever state you think needs it most: **how the ⓘ disclaimer
behaves**, and whether any of these four should offer an action at the bottom
(log a period, open the Companion, prepare questions for a visit) or none.

**Hard rules — the design is rejected if it breaks one:**

* No score, no percentage, no "chance this month", no verdict or match label.
* No diagnosis, no alarm colours, no warning iconography on the refusals.
* States 3 and 4 must show **no phase colours at all** — that is the refusal,
  and it has to be structural rather than a caption saying to ignore the
  colours.
* Every clinical path ends at a real doctor.

**Style:** Fraunces headings, Manrope body. Calm, generous spacing, white cards
with hairlines rather than shadows. Buttons white with a hairline and an ink
label — no filled coloured bars. Line icons or drawn marks, never emoji. The
field behind the sheet is a soft violet-magenta, hue 288, kept quiet.

---

## When they come back

The four states are pure presentation — the engine already decides which one is
in play and already withholds the phases structurally, so there is no data work
behind any of them. It is one screen file and the copy is mostly written.

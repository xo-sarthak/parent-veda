# Cycle report — the three states that were never designed

For the Claude Design project. Paste from **The prompt** down; the rest is
context for you.

---

## Where this stands

You designed the cycle report and it is built — `Cycle Report.dc.html`, three
artboards, two of which ship behind a **Dial | Calendar** toggle with the road's
timeline lifted into both. **This is not a re-do.**

That design drew a cycle that *has* a period, an estimate and four stretches.
`TtcReportState` has five states. Two of the other four are now handled — `thin`
was a gating bug and gets the full new design; that leaves **three** still
wearing the old screen's chrome, which is why the report has two different looks
depending on your data.

| State | When | Today |
|---|---|---|
| **Ready** | period, estimate, findings | ✅ your design |
| **Thin** | period and estimate, almost nothing else logged | ✅ your design |
| **Nothing logged** | no period ever recorded | ❌ old chrome |
| **No estimate** | the engine refuses to guess | ❌ old chrome |
| **Clinic-held** | a clinic is directing this cycle | ❌ old chrome |

**Where to look:** TTC home → daily rail → **Cycle report**. Also from the
insight card, the foot of the symptom logger, and **See this month in full**
inside the Companion's "This cycle" card.

## ⚠️ Two of the three already have an approved treatment

The **Cycle Companion** — which you designed and signed off in the same
round — has both refusals built and shipping. Open it on a clinic pathway and
you get:

* an eyebrow naming the situation — *"Who is guiding this cycle"*
* a card: a Fraunces title, two plain paragraphs saying **why**, and one action
* her logged dates below it, untouched
* her rhythm numbers, still shown, because refusing to draw *this cycle* is no
  reason to stop stating her history
* the estimates line at the foot

**So the cheap, consistent answer is: the report wears that same shape**, and
the only genuinely new screen is *nothing logged*.

The prompt below asks for all three, but says this out loud — so the effort goes
where there is nothing yet, and the two refusals are only redrawn if you can
beat what already ships.

## The difference between the two refusals

This is the part most likely to be flattened into one screen, and it must not
be. Same visible result — no phase colours — completely different reasons.

* **No estimate — "we cannot say."** One gap in her history is long enough to be
  a month she did not log rather than a cycle that long. Averaging it in breaks
  the maths. This state exists because it already went wrong: the app printed
  **"ovulation around day 40"** on a real device off exactly that history, and
  there is a test named after the defect.
* **Clinic-held — "it is not ours to say."** She is on IVF or IUI and a clinic
  is scanning, timing and deciding. Her data may be perfect. Our calculation
  sits second from the bottom of what to trust, well below a treating clinician.

One says *your data is not good enough yet*. The other says *someone better
qualified is already doing this*. Getting them the wrong way round blames a
woman's logging for her clinic's involvement.

Both show her logged days. **Refusing to interpret is not refusing to show.**

## Copy that already exists and has had a clinical read

* Nothing logged — **"This fills in as you log"**
* No estimate — **"Not enough to place the phases"**
* Clinic-held — **"Your clinic is running this cycle"**

## What ships already — do not redesign

The dial and the calendar with their toggle; the four-stop timeline; the
◀ *Chosen cycle* ▶ picker; the weight and temperature chart; the findings cards;
the ⓘ disclaimer in the header.

---

# The prompt

*(paste this into the design project)*

---

Design the **three quiet states** of the ParentVeda cycle report. The main
state — a full cycle with a ring, a calendar and a four-stop timeline — is
already designed and built. Do not redesign it.

The report is a monthly read-back: one cycle, the four stretches it divides
into, and anything she logged during it. The audience is Indian women trying to
conceive, mostly reading English as a second or third language, often anxious.
One idea per sentence.

All three sit under the same header: a back arrow, **"Your cycle report"**, an
ⓘ, and a **◀ Chosen cycle ▶** picker for paging between months.

**1 · Nothing logged.** No period has ever been recorded, so there is no cycle
to draw. This is what most people see first and it is the only one of the three
with nothing to borrow from — **spend your time here.** It should make the first
log feel worth doing and say what it will buy. Not a shrug, not an empty frame.

**2 · No estimate.** The engine has refused: one gap in her history is long
enough to be a month that was not logged rather than a cycle that long, so
estimating from it would produce dates we do not believe. **No phase colours
anywhere.** Her logged days still show, uncoloured. It must read as a considered
decision, not a broken chart.

**3 · Clinic-held.** A fertility clinic is directing this cycle. Same visual
refusal, completely different reason, and the copy must not blame her data. This
is *"a doctor is guiding you and we do not put a second estimate beside
theirs."* If anything it should feel reassuring.

⚠️ **For 2 and 3, the Cycle Companion already has an approved treatment** —
eyebrow naming the situation, a card with a title, two plain paragraphs of why,
and one action; her dates and her rhythm still shown below. **Reuse that shape
unless you can clearly beat it.** If you reuse it, say so and move on; if you
redraw it, say what the report needs that the Companion did not.

Also show, for whichever state needs it most: how the **ⓘ disclaimer** behaves,
and whether any of the three should end on an action — log a period, open the
Companion, prepare questions for a visit — or on nothing.

**Hard rules. The design is rejected if it breaks one:**

* No score, no percentage, no "chance this month", no verdict or match label.
* No diagnosis, no alarm colours, no warning iconography on the refusals.
* States 2 and 3 show **no phase colours at all**. The refusal is structural,
  not a caption telling her to ignore the colours.
* Every clinical path ends at a real doctor.

**Style:** Fraunces headings, Manrope body. Calm, generous spacing, white cards
with hairlines rather than shadows. Buttons white with a hairline and an ink
label — no filled coloured bars. Line icons or drawn marks, never emoji. The
field behind the sheet is a soft violet-magenta, hue 288, kept quiet. Design at
360pt.

---

## When they come back

Pure presentation. The engine already decides which state is in play and already
withholds the phases structurally, so there is no data work behind any of it —
one screen file, and most of the copy is written.

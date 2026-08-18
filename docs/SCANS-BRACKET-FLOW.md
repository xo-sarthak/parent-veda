# Scans & tests — who arrives, and what the next screen should be

The reference design for a bracket's second screen. Scans & tests is the right one to
work out first: it is **the highest-volume bracket in the product** (anomaly scan
~135,000, ectopic ~74,000), and it is the only one where the demand data itself tells us
the answer.

---

## The number that decides the design

Two search terms dominate this bracket, and they are not two versions of one need:

| | volume | who is typing it | when |
|---|---|---|---|
| **anomaly scan** | ~135,000 | calm, prepared, planning | daytime, days ahead |
| **ectopic** | ~74,000 | frightened, possibly in pain | 2am |

**A single library serves the first and fails the second.** A woman who is bleeding does
not want a list of every scan in pregnancy; she wants to know whether to go to hospital.
If the same screen has to serve both, the emergency has to be *above* the library, not
inside it.

That one fact is most of the information architecture.

---

## Five people arrive at this door

Not demographics — **states**. The same woman is a different persona in different weeks,
which is exactly why the screen must not ask her to identify herself.

### 1. Meera — has a date in her hand
> *"Anomaly scan on Thursday. What actually happens?"*

Wants: how long it takes, whether to drink water and how much, whether her husband can
come in, what it costs, whether it hurts. **She is preparing, not worrying.** Highest
volume, lowest anxiety.

⚠️ **She will also ask whether they will tell her the sex, and in India they will not.**
Sex determination is illegal (PCPNDT Act) and the sonographer will refuse — sometimes
brusquely, sometimes with a sign on the wall. If we have not told her beforehand, she
reads the refusal as *something being hidden about her baby*. **Every scan page says this
once, calmly, before the day.** It is the single most India-specific thing on this
screen and no imported design will contain it.

### 2. Priya — has a paper in her hand
> *"It says 'echogenic intracardiac focus'. I googled it and now I cannot breathe."*

Has had the scan. Holding a report with eight words she does not know. **Has already
searched and frightened herself before opening our app** — that is the sequence, always.

Wants: what does THIS line mean, is it bad, do I call the doctor now or wait until
Tuesday. **Highest anxiety, highest value, and the moment we are most able to help** —
because we have `kReportFindings` and `kFindings`, and a lab report is a fixed vocabulary
of maybe forty terms.

### 3. Anjali — does not know what is coming
> *"How many scans will I even have? What do they cost?"*

Early, orienting. Wants the map: what, when, roughly how much, what is essential versus
what a clinic upsells. Often the most price-sensitive question in the product and nobody
answers it honestly.

### 4. The 2am one — something is wrong right now
> bleeding · sharp one-sided pain · shoulder-tip pain

**Not looking for a library. Needs triage.** Ectopic pregnancy is a surgical emergency
and 74,000 people a month are typing that word. She is not browsing.

### 5. Rahul — the logistics one, and often the partner
> *"Three scans, two labs, and the reports are in WhatsApp somewhere."*

Wants one place: what is booked, what is due, where the PDFs are. **This is the persona
the existing tools already serve** (`scans_appointments_screen`), and the one most likely
to be the husband — which matters, because the father app exists.

---

## So what is the next screen?

**Not a list of scans.** A content library serves Anjali well, Meera adequately, and
fails Priya, the 2am one and Rahul completely — three of five, including both extremes of
urgency.

The right second screen is a **triage by where she is in the lifecycle of a scan**,
because every question in this bracket is one of exactly four, and they are sequential:

```
        BEFORE            IMMINENT           AFTER            EMERGENCY
   "what's coming"   "one is booked"   "here's my report"   "something's wrong"
       Anjali             Meera              Priya             the 2am one
                                                              ── always on top ──
```

### The screen, top to bottom

**1. The red-flag strip — pinned, first, never dismissible.**
One line: *"Bleeding, one-sided pain, or pain in your shoulder tip?"* → opens the urgent
path. It sits above everything including the personalised card. It is small and calm, not
a red alarm — this product does not frighten people — but it is never scrolled past,
because the one persona who cannot wait is the one who will not scroll.

**2. One personalised card — the app answers before she asks.**
This is what makes the screen ours rather than a menu. We already know:

- `ScansStore` — what she has booked
- gestational week — what is due about now
- her uploaded reports — what she added recently

So the card reads *"Your anomaly scan is on Thursday — here is what happens"* or
*"Week 20. The anomaly scan is usually done about now, and you have nothing booked"* or
*"You added a report two days ago. Want help reading it?"*

⚠️ **One card, not a stack.** The moment it becomes three cards it is a feed, and a feed
is what she has to read rather than something that has already answered her.

**3. Four doors, in lifecycle order.**

| Door | Serves | Opens |
|---|---|---|
| **What's coming** | Anjali | the schedule — every scan by week, with real cost ranges |
| **Getting ready for one** | Meera | the day-of guide for the next/chosen scan |
| **Reading a report** | Priya | the decoder |
| **Every scan explained** | all | the library, `kTestsScans` |

**4. Then the existing rows** — the tracker, appointments, the consult — the bracket
screen's normal sections, unchanged.

### Why triage rather than the six-layer list we have now

The current bracket screen shows Content / Tools / Consult / Extras. Those are **our**
categories — they describe how we filed the material, not what she came for. Nobody has
ever thought *"I need the tools layer."* The lifecycle is what she is actually inside.

⚠️ **This does not replace the layer model** — the layers still decide what is *allowed*
to appear (the resolver is still the chokepoint, Products is still refused here). The
triage decides what is *shown first*. Filing and presentation are different jobs.

---

## Drill-down depth: three levels, and never four

```
L1  the door                     Scans & tests            ← the V3 grid
L2  the triage screen            "where are you with it"  ← this document
L3  the thing itself             one scan · the decoder · the tracker
```

**Four levels is where it breaks.** At depth four she cannot remember the path she took,
back becomes lossy, and the deep screen stops being reachable any other way — which is
how content gets built and never seen. If something needs a fourth level, it is a sign it
should have been reachable from L2 directly.

**Every L3 is also reachable from somewhere else** — the weekly flow, search, Ask Veda.
The bracket is *a* way in, never the only way in.

---

## L3, the reusable unit: one scan's page

The same template for all nine scans, so building the tenth is data, not design.

1. **What it is and why** — two sentences
2. **When** — the week window, and what it means if she is outside it
3. **On the day** — how long, full bladder or not, what to wear, who can come in,
   **real cost range in ₹**, whether the report is same-day
4. **What they cannot tell you** — the PCPNDT line. Once, calm, before she is surprised
5. **What the report might say** — the three or four terms this scan commonly produces,
   each linking into the decoder
6. **When to call before your next appointment** — the red flags specific to this scan

Points 3, 4 and 5 are the ones no competitor has. Point 4 is the one no imported design
will ever contain.

---

## L3, the crown jewel: the report decoder

This is the workbook's **Extras** cell for this bracket — *"Report / result explainer
(upload & understand)"* — and it is the most distinctive thing in the entire pregnancy
stage.

**Flow:** photograph or upload the report → we match the terms we recognise → each one
becomes a card in plain language.

Each term card:

- **What this line means** — plain, no hedging
- **Is this common?** — "about 1 in 20 scans" beats "sometimes"
- **What usually happens next** — the ordinary path, which is almost always "they look
  again at the next scan"
- **Does this need a call today?** — an explicit yes/no/only-if, because that is the
  actual question and every other page dodges it

And it ends by **generating the questions to ask** — three or four, phrased so she can
read them aloud in a six-minute appointment.

### The three rules this screen cannot break

1. **Never a diagnosis.** We explain the vocabulary; we do not tell her what is wrong.
   The distinction is *"this term means X"* versus *"you have X"*.
2. **Never contradict her clinician.** If the report says one thing and her doctor said
   another, **her doctor is right** — the truth hierarchy puts a treating clinician six
   places above our calculation, and the copy says so out loud.
3. **A term we do not recognise is said out loud.** "We do not have an explanation for
   this line" is a real answer. Silently showing only the terms we know makes an
   incomplete decode look complete, which is worse than admitting the gap.

---

## What this needs that we do not have

- **The triage screen itself** — new, and the deliverable
- **Cost ranges in ₹ per scan** — Anjali's question, and nobody answers it honestly.
  Needs real numbers, city-banded
- **The PCPNDT line**, written once and shown on every scan page
- **OCR or photograph handling** for the decoder. **The cheap first version is a search
  box**: she types the term she does not understand. Ships in a day, answers the same
  question, and tells us which terms actually get looked up before we spend anything on
  OCR

Everything else — the library, the findings, the schedule, the tracker, the consult —
already exists.

---

## Does this generalise to the other 39 brackets?

**The pattern does; the four doors do not.** The transferable rule is:

> **A bracket's second screen sorts by where she is in the problem, not by what kind of
> material we hold.**

- **Sleep** → *is it tonight, is it a phase, is it a pattern*
- **Complications** → *I have a diagnosis · I have a symptom · I am being screened*
- **After a loss** → **one door, and it is a person.** Triage would be obscene here.

So the *screen* is bracket-specific and the *principle* is shared — which means this is
a template, not a component. The generic six-layer screen stays as the fallback for
brackets nobody has designed a triage for yet, and each one graduates as it earns it.

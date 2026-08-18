# Scans & tests — the flow, screen by screen and tap by tap

Companion to `SCANS-BRACKET-FLOW.md` (which explains *why*). This one is *what*.

The workbook row this implements, verbatim:

| Layer | Cell | State |
|---|---|---|
| Demand | Giant (anomaly scan ~135,000; ectopic ~74,000) | — |
| **Content** | Every scan explained (dating, NT, anomaly, growth, doppler), what results mean, timing | **live** |
| Activities | Not core (rides week spine) | notCore |
| **Tools** | Scan/test schedule tracker, due-date calculator | **live** |
| Products | Not a fit | **notApplicable** |
| Course | Not standalone (module of childbirth prep) | notCore |
| **Consult** | Gynae second-opinion consult (paid) | **live** |
| **Extras** | Report / result explainer (upload & understand) | **live** |

Four live layers. The question is where each one *sits* in the flow.

---

## 1. What happens today

```
Pregnancy V3 home
   └─ tap "Scans & tests" tile
        └─ BracketScreen                    ← generic, same for all 40 brackets
             ├─ WHAT THIS ACTUALLY IS   (Content)  → row: "Tests & scans"
             ├─ WHAT YOU CAN TRACK      (Tools)    → rows: "Appointments", "Due date"
             ├─ WHEN THE REPORT COMES BACK (Extras) → row: "Reports"
             └─ TALK TO SOMEONE         (Consult)  → row: "Consults"
```

**Four sections, one row in each.** It works, and it is a filing cabinet — the headings
are the workbook's column names, which describe how *we* stored the material.

---

## 2. What I am proposing

**The four layers do not disappear. They stop being the four sections, and get
distributed to the moment each one is useful.**

```
Pregnancy V3 home
   │
   └─ tap "Scans & tests" tile
        │
        ▼
   ┌────────────────────────────────────────────────┐
   │  L2 · SCANS HUB           (new screen)         │
   ├────────────────────────────────────────────────┤
   │  ⚠ pinned strip: bleeding / one-sided pain?  → │──────────────┐
   │                                                │              │
   │  ┌──────────────────────────────────────────┐  │              │
   │  │ SMART CARD — one, chosen by app state    │  │              │
   │  │ "Anomaly scan · Thursday 3pm"            │  │──┐           │
   │  │ [What happens on the day →]              │  │  │           │
   │  └──────────────────────────────────────────┘  │  │           │
   │                                                │  │           │
   │  ┌─────────────┐  ┌─────────────┐              │  │           │
   │  │ What's      │  │ Getting     │              │  │           │
   │  │ coming      │  │ ready       │              │  │           │
   │  └──────┬──────┘  └──────┬──────┘              │  │           │
   │  ┌──────┴──────┐  ┌──────┴──────┐              │  │           │
   │  │ Reading a   │  │ Every scan  │              │  │           │
   │  │ report      │  │ explained   │              │  │           │
   │  └──────┬──────┘  └──────┬──────┘              │  │           │
   │         │                │                     │  │           │
   │  ── your scans ──────────────────────────────  │  │           │
   │  Appointments · Reports you've added · Due date│  │           │
   └─────────┼────────────────┼─────────────────────┘  │           │
             │                │                        │           │
    ┌────────┘                └────────┐               │           │
    ▼                                  ▼               ▼           ▼
 L3 DECODER                      L3 LIBRARY      L3 SCAN PAGE  L3 URGENT
```

Three levels. Never four.

---

## 3. Every screen, every tap

### L1 — Pregnancy V3 home *(exists)*
One tap: the **Scans & tests** tile → **L2**.

---

### L2 — the Scans hub *(NEW — this is the only new screen)*

Header: the drawn scan mark, the title, one line.

**① The red-flag strip — pinned, always first**

> *Bleeding, one-sided pain, or pain at the tip of your shoulder?* →

→ **L3 Urgent**. Small and calm, never a red alarm, never dismissible. Above the smart
card, because the one person who cannot wait is the one who will not scroll.

**② The smart card — exactly one, chosen by what the app already knows**

| If | The card says | Tapping it opens |
|---|---|---|
| a scan is booked within 7 days | "Anomaly scan · Thursday 3pm" | **L3 Scan page**, on-the-day section |
| week window is open, nothing booked | "Week 20 — the anomaly scan is usually done about now" | **L3 Scan page** |
| a report was added in the last 7 days | "You added a report on Tuesday. Want help reading it?" | **L3 Decoder** |
| none of the above | "Nine scans across the pregnancy. Here is the order." | **L3 Schedule** |

Reads `ScansStore`, gestational week, and the reports store — **all three already exist**.

**③ Four doors**

| Door | Opens | Workbook layer |
|---|---|---|
| **What's coming** | L3 Schedule | Tools |
| **Getting ready for one** | L3 Scan page | Content |
| **Reading a report** | L3 Decoder | **Extras** |
| **Every scan explained** | L3 Library | Content |

**④ "Your scans" — a quiet section, not a hero**

Three rows: `scans_appointments_screen` · reports you have added · `due_date_calculator_screen`.
Workbook layer: **Tools**. Quiet because it serves the one persona who already knows what
he wants (Rahul) and does not need persuading.

⚠️ **No Consult section here.** See §4.

---

### L3 Schedule — "What's coming" *(new view, existing data)*

Every scan by week, in order. Each row: name · week window · roughly what it costs ·
done / due / upcoming.

- tap a row → **L3 Scan page**
- tap "Add to my scans" → `scans_appointments_screen`

---

### L3 Scan page — one scan *(new template, existing content)*

The reusable unit. Same shape for all nine, so the tenth is data not design.

1. What it is and why
2. When — the week window
3. **On the day** — how long · full bladder or not · what to wear · who can come in ·
   **cost range in ₹** · same-day report or not
4. **What they cannot tell you** — the PCPNDT line, once, calm, before the day
5. **What the report might say** — 3–4 terms → each taps into **L3 Decoder**
6. **When to call before your next appointment** — this scan's red flags
7. → *"Want a second opinion on this scan?"* → **Consult**

Bottom actions: **Add to my scans** (Tools) · **I have the report** (→ Decoder).

---

### L3 Decoder — "Reading a report" *(new screen; content exists)*

The workbook's Extras cell. **Version 1 is a search box, not OCR** — she types the term
she does not understand. Ships fast, answers the same question, and tells us which terms
get looked up before we spend anything on image handling.

```
  [ search: type a word from your report ]
  Common ones:  Low-lying placenta · Breech · Cord around neck · AFI · EDD
        │
        ▼
   TERM CARD
     What this line means
     Is this common?            "about 1 in 20 scans"
     What usually happens next
     Does this need a call today?     yes / no / only if …
     ─────────────────────────────
     Questions to ask at your appointment      (3–4, generated)
     [ Ask Veda about this ]   [ Second opinion — ₹ ]   ← Consult
```

Powered by `kReportFindings` (630 lines) + `kFindings`.

**A term we do not recognise says so.** Silently showing only what we know makes an
incomplete decode look complete.

---

### L3 Library — "Every scan explained" *(exists — `tests_scans_reports_screen`)*
The full list. Every row → **L3 Scan page**. Unchanged.

---

### L3 Urgent — the red-flag path *(new, small)*
Three or four symptoms in plain words. Each: what it may mean · **what to do now** ·
call your doctor / go in today / go to emergency. No product, no course, no upsell.
Ends at a phone number, not a screen.

---

## 4. Where each workbook layer actually lives

**This is the part I explained badly last time.**

| Layer | Today | Proposed |
|---|---|---|
| **Content** | one section, one row | the Library door **and** every Scan page — it is the *substance*, not a section |
| **Tools** | one section, two rows | the smart card (booked/due) · "What's coming" · the quiet "Your scans" rows |
| **Extras** | one section, one row | **its own door** — it is the most distinctive thing here, not a footnote |
| **Consult** | one section, one row | **no section at all.** It appears at the end of a Scan page and at the end of a Decoder card |
| Products | refused | still refused, everywhere in this flow |
| Activities / Course | notCore | absent, as designed |

### Why Consult stops being a section

*"Talk to someone"* sitting in a list is furniture — it is there before she needs it, so
she scrolls past it, and by the time she does need it she has forgotten it exists.

The same offer **immediately after she reads "low-lying placenta, this usually resolves
by the third trimester"** is the most useful sentence on the page. Same row, same price,
same doctor — moved from a place where it is ignored to a moment where it is wanted.

⚠️ **This is placement, not a sales tactic.** The rule stays: no commerce inside the
frightening moment. Products is `notApplicable` on this bracket and remains so — a
second opinion from a named gynaecologist is care, not merchandise, and it never appears
on the Urgent path.

---

## 5. Three journeys, tap by tap

**Meera — scan on Thursday** *(2 taps to her answer)*
`Scans & tests` → smart card *"Anomaly scan · Thursday 3pm"* → **Scan page**, on-the-day.
Learns the bladder rule and the PCPNDT line before the appointment, not during it.

**Priya — holding a report** *(3 taps)*
`Scans & tests` → **Reading a report** → types "echogenic focus" → term card: what it
means, common, usually re-checked at the next scan, **no call needed today** → the three
questions to ask. Consult sits under it, when it is finally the right thing.

**The 2am one** *(1 tap)*
`Scans & tests` → red-flag strip → **Urgent**. Never sees a library, a product, or a
price.

---

## 6. What is new versus what exists

| | |
|---|---|
| **New** | L2 Scans hub · L3 Schedule view · L3 Scan page template · L3 Decoder · L3 Urgent |
| **Exists, reused** | `tests_scans_reports_screen` · `scans_appointments_screen` · `due_date_calculator_screen` · `kTestsScans` · `kReportFindings` · `kFindings` · `ScansStore` · the consult |
| **Content still owed** | ₹ cost ranges per scan (city-banded) · the PCPNDT line · the Urgent copy |

Roughly one screen of genuinely new UI (the hub), one new template (Scan page), and one
new feature (Decoder). Everything else is routing.

---

## 7. How the generic bracket screen and this coexist

`BracketScreen` stays as the **fallback for the other 39**. A bracket graduates to a
hand-designed hub when its volume earns one — Scans first, because it is the biggest.

The resolver stays the chokepoint either way: the hub may only show a layer
`canRender()` allows, so Products can never appear here no matter who designs the screen.

# ParentVeda — IVF / treatment-cycle review brief

**For:** a fertility specialist (REI), or an andrologist / IVF nurse coordinator
for the sections marked. Also usable as a research prompt.
**Written:** 2026-07-27
**Time needed:** ~30 minutes. Every question is yes/no or a short correction.

---

## How to use this

ParentVeda is a calm, India-first companion app for people trying to conceive.
It is **not** a fertility tracker and gives no medical advice — but it does show
information, and on treatment cycles it recently came close to contradicting a
clinic. We caught that and changed it. This brief asks you to check whether we
changed it to the *right* thing.

**Please answer only §3 and §4.** §1 and §2 are context so the questions make
sense. Where we are wrong, a one-line correction is enough — we do not need a
literature review, we need to know which of our assumptions do not hold.

Anything you flag becomes a code change, not a footnote.

---

## 1. What the app does for someone trying naturally

It estimates ovulation by counting **backwards** from her next expected period —
average cycle length minus 14 — on the basis that the luteal phase is the
stable half. It then shows a fertile window of **ovulation −5 to +1 days**,
graded (medium / high / peak) rather than flagged, on the basis that sperm
survive around five days and the oocyte around one.

It never says "you will ovulate on X". Every estimate carries a stated
confidence, and confidence is downgraded when cycles vary by more than 8 days.
A recorded LH surge or a basal temperature shift overrides the calendar.

**Q0 (sanity check): is any of the above wrong enough to matter?**

---

## 2. What we found, and what we changed

### The problem

We recorded which pathway a couple is on — trying naturally, ovulation
induction, IUI, IVF, frozen embryo transfer — from the very first version. But
the cycle tools never read it. So a woman **mid-IVF was shown the same
calendar fertility window as someone trying naturally**: "Peak — ovulation
around day 14", while her clinic had told her the trigger was Thursday and
retrieval Saturday.

We treated that as the most serious defect in the product, because everything
else in the app tells her to trust her doctor.

### The change

1. On any pathway other than "trying naturally", the app now **publishes no
   ovulation date and no fertility grade at all**. This is enforced in the
   calculation layer, so no screen can display one even by accident.
2. It stops asking her to log **LH strips** on those pathways.
3. Instead, she can enter **the dates her clinic gave her** — stimulation start,
   trigger shot, egg retrieval / IUI, transfer, beta hCG test. The app carries
   those and never alters them.
4. The **trigger shot** is the only date stored with a time, and the only one
   that generates a reminder (2 hours before).
5. The two-week wait now counts to the **beta hCG blood test**, not to her next
   period.

### Why (5) changed

Previously the app counted toward her next period and would eventually say it
was "late". We believed that on a supported luteal phase this is meaningless.
**That belief is question Q7 below** — if we are wrong, we have removed
something useful.

---

## 3. Clinical questions — please answer these

> **Update, 2026-07-27 — we changed this before you read it.** Q1 and Q2 below
> described treating ovulation induction and all FET exactly like IVF. We no
> longer do. Behaviour is now decided by **who owns the timing**, derived from
> two questions the patient answers: *is a clinic tracking this cycle with scans
> or bloods?* and *does medication decide when you ovulate?* Three tiers result:
> we predict, we defer but keep her logging, or we defer entirely.
>
> The questions are unchanged in substance — we still need to know whether that
> split is the right one and whether patients can answer it reliably.

### Q1. Ovulation induction — is the split right, and can she answer it?

Unmonitored letrozole with timed intercourse now **keeps** the fertile window.
Monitored letrozole with a trigger does not.

- Is that the right dividing line?
- **Is "is your clinic tracking this cycle with scans or blood tests?" something
  a patient reliably knows about herself?** This is the load-bearing question —
  if she cannot answer it accurately, the whole three-tier model rests on a
  guess she made.
- Does LH strip testing remain meaningful on clomid or letrozole? (We have read
  that clomiphene can itself elevate LH and produce false positives — is that
  significant in practice? We currently keep LH logging on in the middle tier.)

### Q2. Frozen embryo transfer — is our handling of natural-cycle FET right?

Natural-cycle FET now lands in the middle tier: we do **not** predict ovulation,
but we **do** keep her logging LH and temperature, on the reasoning that her own
surge is what the clinic is timing the transfer around.

- Is that reasoning correct?
- A medicated FET is treated as fully clinic-controlled — no prediction, no
  logging. Right?

### Q3. Trigger shot — is a 2-hour reminder right?

We remind 2 hours before, reasoning that she needs to be somewhere she can
administer it, with the injection to hand.

- Is 2 hours sensible, or should it be longer (needs collecting from a
  pharmacy / fridge) or shorter?
- **How much timing drift is clinically significant?** We tell users "timing is
  exact — retrieval is scheduled a set number of hours after this." Is that
  accurate, and is 30 minutes late a real problem or a non-event?
- Should we offer a second reminder at the exact time?

### Q4. Beta hCG and home tests

We tell users: *"A home test before this can read wrong because of the trigger
shot. The blood test is the real answer."*

- Is that correct?
- **Roughly how long does trigger hCG persist** and produce false positives? We
  have avoided giving a number. Should we say one (e.g. "up to ~10–14 days"), or
  is the variation too wide to be useful?
- Do patients also get **false negatives** from testing too early after a
  transfer? Should we warn about that too?

### Q5. Retrieval and transfer preparation notes

We show two practical notes, and both are guesses at a general case:

- Retrieval: *"Usually under sedation. Nothing to eat from midnight, and bring
  someone with you."*
- Transfer: *"Many clinics ask you to come with a full bladder. Follow theirs,
  not ours."*

- Are these safe as general statements in Indian practice, or variable enough
  that we should say nothing and defer entirely to the clinic?
- Is there something more important we have **left out** that patients routinely
  forget? (We are conscious we say nothing about the partner's sample on
  retrieval day.)

### Q6. OHSS

We list OHSS in the app's urgent-symptom routing: rapid bloating, breathlessness,
sharp weight gain — after or during a stimulated cycle.

- Is that symptom set right, and is anything important missing?
- **When is the risk window?** We currently do not state one.
- Is there a weight-gain or symptom threshold worth naming, or does naming one
  risk people waiting until they hit it?

### Q7. Does luteal support actually delay the period?

This underpins our decision to stop counting to her period on treatment cycles.

- Is it reliably true that progesterone support delays menses?
- Is it true enough that showing "your period is late" during a treatment cycle
  is genuinely misleading — or have we over-read it?

### Q8. Should we count down to retrieval and transfer at all?

We show "next milestone" prominently. The intent is practical (do not forget the
appointment).

- In your experience, does a visible countdown to retrieval or beta **help**
  patients, or does it concentrate anxiety on a date they are already fixated
  on?
- Would you rather we showed only the *next* item (current behaviour) or the
  whole timeline?

### Q9. Anything we should not be doing at all

Open question. Is there anything in §2 that you would tell us to remove
outright?

### Q10. Should the app ever show success probabilities?

Not currently shown anywhere, and we have now written a rule against it — but we
want it checked before it hardens.

**The rule we adopted:** never a probability attached to *this* family — no "your
chance this month", no "your IVF success rate", nothing computed from her
profile. Population statistics stay allowed where they reduce pressure rather
than set a target: *"most couples conceive within a year"*, *"a male factor is
involved in roughly forty to fifty per cent of cases."*

**What we want to know:** is the line in the right place? Take
*"most couples conceive within a year"*, read by someone at month eleven who has
a diagnosis she does not yet know about. Is that misleading to her — or does it
remain helpful as population context, provided it is clearly presented as
general information rather than a prediction about her?

### Q11. Pregnancy — once a dating scan exists, do we stop calculating?

Outside IVF, but the same shape of question, and it is the one that worries us
most in the next stage.

ParentVeda works out how far along a pregnancy is by counting from a last
period. A dating scan is more accurate, and the clinic owns the scan. So once a
scan has set the date:

- **(a)** should the app stop showing its own calculation entirely and use only
  the scan-derived date, or
- **(b)** show both, labelled, so she can see they differ, or
- **(c)** keep using ours unless the difference is large?

**We have built (a).** The Due Date Calculator already asks how she arrived at
the date — last period, conception, IVF transfer, ultrasound, or "my doctor told
me" — and now records which. Three of those five are the clinic's, and when one
of them is the source we do not offer a competing number. Where she used a last
period, the calculator says plainly that a scan date should replace it.

The reasoning we are asking you to check: *"my app says 9w2d, my doctor says
8w5d"* costs trust that being right afterwards does not buy back. Is there a
case where (b) or (c) would serve her better — for instance, a scan taken late
enough that it is no longer the better estimate?

---

## 4. Content review — the wider TTC library

Separate from IVF, the app contains authored educational content that has never
been read by a clinician. The clinically loaded items:

| Topic | Our current claim, in brief |
|---|---|
| **AMH** | "Counts eggs, not chances." A planning number for IVF response; poor predictor of natural conception; low AMH with regular cycles is not a verdict. |
| **FSH / LH** | Must be taken day 2–3; taken on the wrong day the result is not interpretable. |
| **TSH** | Many fertility specialists prefer TSH < 2.5 when trying, stricter than the general lab range — so a "normal" result may still be worth discussing. |
| **Semen analysis** | Male factor in ~40–50% of couples; abstain 2–5 days; results vary a lot between samples, so repeat after 2–3 months before concluding. |
| **HSG** | Between end of period and ovulation; uncomfortable, ask about pain relief; some evidence of a small conception rise in following months. |
| **Prolactin** | Morning, not after exercise / stress / breast exam; a single mildly high result is usually repeated before acting. |
| **When to seek help** | 1 year, or 6 months if over 35, or sooner with irregular/absent periods, known PCOS or endometriosis, previous pelvic surgery or infection, or a known male factor. |
| **Fertile window** | ~6 days; sperm survive ~5 days, egg ~1. |
| **CoQ10** | "Promising rather than proven", ask a doctor not a chemist. |
| **Folic acid** | 400mcg while trying; higher on advice with diabetes, epilepsy, high BMI or previous NTD pregnancy. |
| **Ectopic warning** | Positive test + one-sided pain / shoulder-tip pain / dizziness / bleeding = same-day care. |

**Q10: is anything in that table wrong, out of date, or dangerously simplified
for an Indian patient population?**

We would rather delete a claim than carry one you would not stand behind.

---

## 5. What we are deliberately not asking

So you can skip these: we are not asking whether the app should exist, whether
it should give advice (it does not), or about pricing. We are also not asking
you to review tone — that is our problem.

---

## 6. What happens to your answers

Each one becomes either a code change or a deletion, and this file is updated
with what you said and when. Nothing is added to the product on the strength of
an assumption once you have told us otherwise.

Contact for follow-up questions: the ParentVeda product team.

---

## 7. Statements pending your validation

**Read this section first if you read nothing else.**

This brief went through a product review on 2026-07-27 before reaching you. That
review was explicitly **not** clinical validation, and its author said so. Most
of what it changed made our copy *less* certain — "follow your clinic's fasting
instructions" replacing "nothing to eat from midnight", no numbers on trigger
timing, TSH targets no longer stated as universal, HSG no longer promising
improved fertility. Those are safe in the direction they move.

**Two changes go the other way** — they add a clinical statement we did not
previously make. Both are hedged, and both were judged protective. Neither is in
the product yet, and neither goes in until you confirm it:

| # | Proposed copy | Why it was proposed | Our concern |
|---|---|---|---|
| P1 | "The trigger injection may remain detectable for around 10–14 days, although this varies between individuals." | Without a number, "test too early and it may read wrong" does not tell her *how long* to wait — so she tests anyway and believes a false positive. | It is a specific window we have no basis to state. Is 10–14 days right, and is naming any number better than naming none? |
| P2 | OHSS risk window: roughly the trigger through 1–2 weeks after, and pregnancy can prolong or worsen it. | A symptom list without a window does not tell her when to stop watching. | Same concern. Also: does giving a window risk her dismissing symptoms that fall outside it? |

Also proposed and **not** implemented pending you: adding *severe abdominal
pain*, *reduced urine output* and *persistent vomiting* to the OHSS urgent list.
We are inclined to add these regardless — a longer list of reasons to call a
clinic errs the right way — but they are your call, not ours.

### Please challenge the rule, not only the wording

If a safer product boundary exists than the one we have drawn, we would rather
redesign the feature than refine the English. A note saying *"this whole
question is the wrong question"* is more useful to us than a corrected sentence,
and it will be acted on the same way.

That has already happened once in review, which is why the questions below now
read as they do.

### The two questions, as they now stand

They decide everything: whether we predict a fertile window, whether her own LH
and temperature readings still mean anything, and whether we count toward a
period or a beta test.

> **1. Is your fertility clinic deciding the important dates for this cycle?**
> *Scans or blood tests · a trigger injection · IUI timing · egg retrieval ·
> embryo transfer*
>
> **2. Has medication taken over WHEN ovulation or transfer happens — an
> injection that sets the hour, or a fully medicated schedule?**
> *If your own body still decides the day, answer no.*

Both were rewritten after a review pointed out that our earlier versions asked
about **clinical events** rather than the underlying question. "Is your clinic
tracking this with scans?" and "have you had a trigger injection?" are both
proxies — a natural-cycle FET has neither, and the clinic still owns the timing;
a fully medicated transfer has no trigger at all.

**What we need from you:**

- Does question 1 capture *clinic owns the timing* for every pathway you see,
  including ones we have not thought of?
- Does question 2 cleanly separate a monitored cycle where her body still
  ovulates on its own from one where medication decides? That distinction is
  what keeps LH strips meaningful for the first group.
- Is there a pathway where both answers are yes but our conclusion would still
  be wrong?

Unanswered means "not sure", and "not sure" is treated as the safer answer — we
withhold rather than predict.

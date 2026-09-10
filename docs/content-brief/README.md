# Content briefs — what the app needs made

Nine PDFs, but only **two cuts of the same data**. Nothing here is content. It
is the list of what content has to be made, where it goes in the app, and what
shape it takes.

Every number is **parsed from the app's source**, not counted by hand.

> **The PDFs and workbooks are not in the repo.** They are rendered output —
> 42 MB of it — and they are gitignored, so a fresh clone sees only this README
> and the CSVs. The generators *are* tracked. Run the commands under
> [Rebuilding](#rebuilding-after-the-app-changes) at the bottom and every file
> named below appears in this folder.

---

## Read these six — one per side of the app

This is the full view. Each brief is complete for its side: pictures, film and
sound, then writing, then everything else, all in one document.

| File | Side of the app |
|---|---|
| `TTC-CONTENT-BRIEF.pdf` | Trying to conceive |
| `PREGNANCY-CONTENT-BRIEF.pdf` | Pregnancy, her side |
| `FATHER-CONTENT-BRIEF.pdf` | Father mode |
| `PARENTING-CONTENT-BRIEF.pdf` | Parenting, 0 to 5 |
| `SKILLING-CONTENT-BRIEF.pdf` | Skilling — a design preview only |
| `SHARED-CONTENT-BRIEF.pdf` | Commerce, experts, community, legal, platform |

**How each brief is laid out**

* **01** — the warning, and how the counts work. Read it before spending.
* **02** — what kind of thing is needed and how much of it.
* **03** — which areas carry the most work.
* **04** — the priority list, and the questions the code could not answer.
* **05 to 07** — every line, grouped by area, with the tap path so someone can
  find each item in the running app.

## The other three are the same data, cut by type

Use these only for a whole-app number — "how many films does the entire
product need". All six stages appear inside each as numbered sections, so if
you have read the six briefs you have already seen everything in them.

| File | Contains |
|---|---|
| `CONTENT-NEEDS-1-IMAGES-VIDEO.pdf` | Every image, film and audio slot, all stages |
| `CONTENT-NEEDS-2-WRITTEN.pdf` | Every piece of writing, all stages |
| `CONTENT-NEEDS-3-OTHER.pdf` | Everything else, all stages |

---

## The three door sheets are a different thing entirely

| File | Doors |
|---|---|
| `TTC-DOOR-CONTENT.xlsx` | The 7 TTC doors |
| `PREGNANCY-DOOR-CONTENT.xlsx` | The 10 pregnancy doors |
| `PARENTING-DOOR-CONTENT.xlsx` | The 11 parenting doors |

**These are not parsed from the app.** Everything above is read out of the
source; these three are read out of the **rebuild briefs** — the per-door PDFs
that say what each door *should* hold. Where the two disagree, the brief wins:
it is the spec, the app is the current implementation.

So they answer a different question. The briefs above ask *what exists and
needs making*. These ask *what does this one door need commissioned*, at a
level someone can hand to a writer, a film crew or an illustrator without
reading a 130-page PDF first. Five sheets each: **Read me first**, **Written
content**, **Videos**, **Images**, **Other**, plus three judgement columns —
the pixel size to deliver, whether a written piece is medically critical, and
whether a film can be AI or needs a real expert on camera.

**Read the front sheet before the rows.** Each one opens with the finding that
changes how you spend:

* **TTC** is genuinely unbuilt — most rows are real writing work.
* **Pregnancy** is largely *already written*; the sheet exists mostly to stop
  a team paying to rewrite it.
* **Parenting** is the same shape as pregnancy on writing, but is badly short
  of **film and audio** — roughly 150 film slots and 58 story narrations,
  almost none made. It also carries two decisions only the user can make: the
  Health in-app paracetamol dosing page (**do not ship unchanged**) and the
  Development leap calendar's exact-week dates (**too precise to defend**).

Rebuild any of them with:

```
python tools/ttc_door_content_xlsx.py
python tools/preg_door_content_xlsx.py
python tools/parenting_door_content_xlsx.py
```

The data lives in the scripts as plain Python lists, keyed to the brief each
row came from, so a revised brief is an edit to one list rather than a re-parse.

---

## Three rules before commissioning anything

**1. Filter the "Ships?" column first.** Some items sit on screens the app no
longer opens — old versions kept in the code so a change could be reversed.
Parenting has 218 such items, shared has 22. Each is either dropped from the
brief or reinstated as a product decision *before* a rupee is spent.

**2. Do not rewrite what is already real.** Pregnancy holds roughly 380,000
words that are written, shipping and bilingual — the weekly spine and the
daily content. They are marked `real`. Sending them out to be rewritten would
pay to replace the best content in the product.

**3. Films must be self-hosted.** YouTube was tested to exhaustion and is
systemically blocked for this product. Budget hosting alongside production.

---

## Rebuilding after the app changes

The CSVs in `research/content-inventory/` are the source; the PDFs are only a
layout of them. Re-parse the app, then re-print:

```
python tools/inventory/emit_ttc.py
python tools/inventory/emit_preg.py
python tools/inventory/emit_rest.py          # father, shared, skilling
python tools/parenting_content_brief.py --all --pdf     # the six per-stage briefs
python tools/content_inventory.py research/content-inventory --pdf   # the three sheets
```

Parenting's CSVs came from a separate source-parsing pass and are not
regenerated by the emitters above; leave them in place unless that stage is
re-analysed.

Tap paths are built from the app's own tab labels and section headings, so a
renamed tab renames every row under it on the next run rather than leaving the
brief quietly describing a screen that no longer exists.

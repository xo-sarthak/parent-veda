# Guide format — a booklet, not an article

For the Claude Design project. Paste from **The prompt** down; the rest is
context for you.

---

## Where this stands

Every TTC door has two kinds of reading tile: **Article** and **Guide**. The chip
on the card differs, the promise differs — an article is read through, a guide
is *used* — and then both open the same screen: `PvReaderScreen`, the long-form
article reader with its cover, contents, progress bar and footnotes.

That is the defect. "What three months looks like" is a twelve-week plan and it
opens as an essay. "The words on the report, in plain English" is a glossary and
it opens as an essay. The chip says Guide; the screen says Article.

**Where to look:** TTC home → **His side** → *Improve his health* → "What three
months looks like". Also → *Test and results* → "The words on the report".

## What a Guide is, in this app

Eighteen Guide tiles exist across six doors. They fall into three shapes, and
the booklet has to hold all three without three designs:

| Shape | Example | What she does with it |
|---|---|---|
| **A plan** — sequential, dated | *What three months looks like* (day one, week 1, weeks 2–6, weeks 7–11, week 12) | Works through it over weeks. Comes back. Wants to know where she is. |
| **A reference** — lookup, no order | *The words on the report, in plain English*; *The carrier screening that matters in India* | Opens it holding a report. Reads two entries. Leaves. |
| **A promoted section** — one part of a longer article | After a loss's *Rh status and retained tissue*; Mind and body's *Fixing a bedtime you will actually keep* | Was promised one specific answer from a card. Lands on it. May read on. |

The third shape matters most for the build: those tiles open an existing
article **at a heading** (`atHeading`), single-source, never copied. The booklet
must be able to open at a page, not only at its cover.

## What the data already is — do not invent a second content model

A guide is a `PvRead`, the same object an article is. The screen gets:

* a **kicker** (the door), **title**, one-line **teaser**, a **scale-setter**
  paragraph, **author** and role
* **sections**, each with an optional heading and any of: paragraphs, bullets,
  a tip, a myth-vs-fact pair, a callout (note / reassure / urgent)
* **FAQs**
* one **when-to-see-someone** callout — required, always urgent tone
* an **evidence** line naming the bodies it comes from
* **read next** ids and **next steps** (a tool, a product, a course, a consult)

So a booklet page is a section. The cover is title + teaser + scale-setter. The
back cover is when-to-see-someone + evidence + next steps. Nothing has to be
authored twice, and the reader can fall back to the article screen for any read
that is not a guide.

## The design system

The kit on claude.ai/design is a React mirror of the Flutter app; the repo is
the source of truth. Reuse what is there: Fraunces for titles, Plus Jakarta and
Manrope for everything else; the door's own hue for the accent (His side is
teal, 186; IVF 268; Mind and body its own); the tool chrome's panel and card
tints; line icons only, no emoji; sentence case; calm — nothing on a clinical
screen goes red, the urgent callout is the coral tint that already exists.
Phone first, 360dp wide, light theme.

## Hard rules the format must not break

* **Structure is the same for everyone.** Personalisation changes content and
  order, never the shape of a screen.
* **The when-to-see-someone page is never skippable** and never inside a fold.
* **A plan's ticks are hers, local, and never a score.** No "60% complete",
  no streaks. A tick is a memory aid, not a grade.
* **English only.** No Hindi in this pass.
* **Nothing predicts.** A plan says what to do in which week; it never says
  what the result will be.

---

## The prompt

**Paste from here.**

---

Design a new reading format for the ParentVeda TTC stage: **the Guide, as a
booklet.** Today a Guide opens in the same long-form article reader as an
Article. A guide is a thing you *use* — a plan you work through over weeks, or
a reference you open holding a report — and the article screen (cover, scrolling
prose, contents, progress bar) is the wrong shape for that. Design the right
one.

### The metaphor

A small booklet. Pages, not a scroll. One section per page, paged sideways with
a thumb, a spine that shows where you are and lets you jump, a cover and a back
cover. It should feel like a leaflet a good clinic hands you — calm, short pages,
generous margins, nothing that has to be scrolled inside a page on a 360dp
phone. If a section is too long for one page, it gets two pages, not a scroll.

### What a booklet holds

The content model is fixed and is the same object an article uses. Design for
exactly this, nothing more:

* **Cover** — door kicker, title, one-line teaser, a scale-setting paragraph,
  author and role. The cover is where the door's accent hue lives most strongly.
* **Pages** — one per section. A section has an optional heading and any of:
  paragraphs, a bulleted list, a tip box, a myth-vs-fact pair, a callout in one
  of three tones (note, reassure, urgent).
* **Questions page** — the FAQs, at the end, before the back cover.
* **Back cover** — the "when to see someone" callout (always urgent tone, never
  skippable), the evidence line naming the bodies it comes from, and the next
  steps (a tool, a product, a course or a consult — each is one tappable row).
* **Spine** — a persistent contents strip: page marks with headings, the
  current page lit, tappable to jump. Where it lives is yours to decide (top
  edge, bottom edge, a pull-out); it must not eat the page.

### The three shapes one design must hold

1. **A plan.** Reference content: *What three months looks like* — the
   twelve-week male-fertility plan. Pages: Day one (book the repeat test), Week
   one (structural changes), Weeks two to six, Weeks seven to eleven, What to
   keep during the twelve weeks, Week twelve (the repeat, read together). Its
   bullets are things to do. Design a **tick** on each bullet of a plan page:
   hers, local, quiet. A ticked page shows it on the spine. There is **no
   percentage, no streak, no score** anywhere — a tick is a memory aid.
   Show the plan **mid-way** (week one ticked, week two open) as its own
   artboard, because coming back after three weeks is the normal case.
2. **A reference.** Reference content: *The words on the report, in plain
   English* — a glossary of semen-report terms, with one page per group of
   terms and a section that lists the four reference numbers. She opens it
   holding a report, reads two entries, leaves. Design the spine so a reference
   is **findable**: headings legible in the spine, a jump that lands on the
   term. No reading-order pressure, no "continue".
3. **A page opened from outside.** Some Guide cards on other doors open one
   section of a longer piece — *Rh status and retained tissue* opens the
   after-a-loss recovery piece at that heading. Design the booklet **opening at
   a page**, not its cover: the cover is one swipe back, the spine shows there is
   more, and nothing about the page says "you skipped something".

### Artboards

1. Cover — the twelve-week plan.
2. A plan page, untouched — Week one, four bullets with ticks.
3. The plan mid-way — spine showing Day one and Week one done, Weeks two to
   six open with one bullet ticked.
4. A reference page — the glossary, a group of terms, spine visible.
5. A page with furniture — one page that carries a myth-vs-fact pair and a
   reassure callout, so the components are designed once.
6. The questions page.
7. The back cover — when-to-see-someone, evidence, three next-step rows.
8. Opened from outside — the after-a-loss piece at "Rh status and retained
   tissue", cover one swipe back.
9. The spine, expanded — whatever the jump gesture opens.

### Design system

Use the existing ParentVeda V3 kit: Fraunces for titles, Plus Jakarta and
Manrope for text; the door's own hue for the accent (this plan is His side,
teal); the tool chrome's panel and card tints for boxes; line icons, no emoji;
sentence case. Calm throughout — nothing goes red; the urgent callout uses the
coral tint that already exists in the kit. Light theme, 360dp phone, and the
whole page must fit without an inner scroll.

### Rules

* The shape is the same for every reader. Personalisation never changes
  structure.
* The back cover is always reached; it is never inside a fold and never
  optional.
* Ticks are private and never summarised as a number.
* English only in this pass.
* A plan says what to do in which week and never what the result will be.

### When done

Give me the artboards named as above, the spine's rule for how many page marks
fit before it truncates, the tick's three states (unticked, ticked, ticked on
the spine), and a one-line note on anything in the content model you found no
good home for.

# Reading — the Mobbin audit, the decision, and the brief

**Written 2026-09-16.** The discussion the user asked to have once the pregnancy
doors were built (STILL-OPEN §38.5): *"I want to discuss a singular format to
view article/reads."* This is that discussion, done against shipped apps.
Second Mobbin audit; same recipe as `ONBOARDING-AUDIT.md`.

References in `research/mobbin/reader/` (gitignored; permanent links in §8).

---

## 1. What we have — six readers, four models

From `docs/SCREEN-UNIFICATION-AUDIT.md` §1.2, checked against the models today:

| Screen | Lines | Model | Has |
|---|---|---|---|
| `reader/pv_reader_screen.dart` | 1,087 | `PvRead` | kicker · title · teaser · **author + role** · hue · **sections (collapsible)** · **whenToSeeSomeone** · FAQs · **evidence** · hero video slot · related videos · **readNext** · nextSteps · progress · TOC · font · light/sepia/dark · myth-vs-fact |
| `read_reader_screen.dart` | 970 | `ReadItem` | title · type · **weekStart/End** · body (one block) · author/role · why · **book fields: rating, buyUrl, companion** · whyThisMatters · researchSimplified · myth/fact |
| `post_pregnancy/reading_reader_screen.dart` | 568 | `ReadArticle` | title · teaser · whyToday · **collection** · ageTag · minutes · author/role · sections · kind · evidence · **related activity / video / recipe / product / community** |
| `post_pregnancy/article_reader_screen.dart` | 320 | `Article` | title · category · age · readMin · author/role · featured — body only |
| `book_companion_screen.dart` | 890 | its own | a book, not an article |
| `father/father_reads_screen.dart` | 654 | father data | father-mode reads |

Every model has an author and a role. Three of four have sections. Two have
evidence. One has the clinical callout. The differences are **what surrounds
the body** — week-binding, collections, cross-links, book commerce — not the
body itself. That is what makes convergence possible.

Two chip words on the doors, "Read" and "Article", with `PvDoorFormat`'s own
comment holding them apart: *an article is read start to finish; a read is a
lookup she dips into with a word in her hand.* Held as an open question since
2026-09-11.

---

## 2. What shipped apps do

Fifteen reader screens read closely, from Flo, Matter, NYT, Blinkist,
Finimize, Zocdoc, GoHenry, Atoms, Superpower, Deepstash, Moonly, Pi, Apple
Books, Fable, Liven. Two questions asked of each: what is the *shape* of a
piece, and what does the app *do* at the end.

### 2.1 The finding that reframes the question: there are two objects, not one

**Flo has two reading formats and never confuses them.**

- **The article** (Insights tab): a title in display type, a **"Reviewed by
  Flo Medical Board, 100+ doctors and experts" byline with a badge**, a
  teaser, body in sections, a collapsible **References** block, a bookmark,
  and **"Up next"** at the foot. Long, referenced, read start to finish. This
  is the object every other health/finance app in the set also ships —
  Superpower ends on "Sources — Mayo Clinic", Finimize opens with a table of
  contents and "21 min read", Zocdoc has a byline and a drop cap.
- **The card** (Daily insights, opened from the home rail): full-bleed
  tinted ground, a **segmented progress bar** across the top, **one idea in
  three lines**, one illustration, a bookmark, swipe to the next card, and
  the last card is an action (*"Log your symptoms"*). No byline, no
  references, no scroll. Blinkist's "Shorts" (a key-takeaway card with a
  citation and thumbs), Deepstash's idea cards and Box Box Club's stat cards
  are the same object.

Nobody in the set has a third. And nobody distinguishes *intent* — "read
this through" versus "look this up" — at the chip. Flo's chips say the
**format**: `Video`, `Video Course`, `Article`. The distinction our
`PvDoorFormat` comment draws is real, but every app expresses it inside the
piece (a lookup piece opens with a glossary or a table of contents) rather
than as a different word on the tile.

### 2.2 The article, part by part — what is universal and what is not

| Part | Universal | Seen in some | Never seen |
|---|---|---|---|
| Top bar | close/back left; bookmark right | share; `Aa` (Blinkist, Matter, Liven); a thin **progress line** under the bar (Finimize, Liven, Deepstash) | a bottom tab bar inside the reader (Goodreads has one; it reads as a mistake) |
| Head | eyebrow · **display title** · teaser | read time (Matter "8 min", Finimize "21 min read"); table of contents for long pieces (Finimize) | engagement counts up top (HYPE's "1.7K" — declined) |
| Byline | **name + role** | a **"Reviewed by"** badge (Flo); avatar (Matter, NYT) | — |
| Hero | image or nothing | video slot; "Listen · 5:50 min" (NYT) | — |
| Body | sections with H2s, generous measure | bold lead-ins, pull quotes, a mid-article video (Headspace) | walls of text without heads |
| Callouts | — | Flo's inline "consult a doctor" line; Pi's list boxes | — |
| Foot | **References / Sources** (Flo, Superpower, GoHenry, Letterboxd) · **read next / related** (everyone) | "Key takeaways" (Blinkist); "Was this helpful? 👎👍" (GoHenry); "Share this article" (Atoms); a disclaimer block (Finimize) | comments in a health reader |
| Controls | — | `Aa` sheet: size · serif/sans · light/sepia/dark (Matter, Apple Books, Fable, Brave) | — |

### 2.3 The card, part by part

Segmented progress top · close top-right · **one idea, ≤3 short lines, in
display type** · one illustration or one tinted field · bookmark · **the
last card is a verb** ("Log your symptoms", "Read the article", "Mark as
finished"). Deepstash adds "Continue journey — 2 of 6 read". That's it. The
restraint is the format.

### 2.4 What we decline

Engagement counts and follow buttons (HYPE, Deepstash); a bottom tab bar
inside the reader; "AI-enhanced research" badges (Finimize); the Yubo/Pinterest
"swipe to explore" chrome that the card search also surfaced — a card is a
piece of content, not a feed.

---

## 3. The decision

### 3.1 One reader, one model, two formats

**One `PvRead` model, one `PvReaderScreen`, and every article in the app
opens in it.** The four models converge on `PvRead` — the richest, the one
that already has the clinical callout, references and read-next — with the
fields the others carry becoming *optional* fields on it:

| From | Field(s) | On `PvRead` as |
|---|---|---|
| `ReadItem` | `weekStart`, `weekEnd` | `weekRange?` — binds a piece to the weekly stack |
| `ReadArticle` | `collection`, `ageTag`, `whyToday` | `collection?`, `ageTag?`, `whyToday?` |
| `ReadArticle` | related activity / video / recipe / product / community | `related: PvReadLinks?` — one typed bag, rendered as rows at the foot |
| `Article` | category, age, featured | `kicker` (exists), `ageTag?`, `featured` |
| `ReadItem` | `whyThisMatters`, `researchSimplified` | sections with a fixed kind — they are H2s, not fields |
| `ReadItem` | rating, buyUrl, companion | **do not converge.** A book is not an article |

**Books leave the reader.** `ReadItem` with `type == book` is a product card —
rating, buy, companion — and its home is the Book Companion. The weekly
"reads" rail shows books and articles side by side; the *tile* differs by
format chip, the *tap* goes to different screens, and that is honest.

**The card is a second format, not a second reader** — and it is **not built
in this pass.** The audit found it, and it belongs to the home's daily rail
(V3 "only what changes", the three activities) rather than to the reading
problem. Recorded in §5 as owed, with the spec in §2.3, so the day the home
wants it the shape is already decided.

### 3.2 The reader, top to bottom

```
 ┌ close ─────────────────── bookmark  Aa ┐
 │ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ │  thin progress line, ink3 → action
 │                                        │
 │ EYEBROW · 5 min read                   │  Manrope 11/800 action
 │ The title, in Fraunces                 │  title1 27
 │ Teaser in ink2.                        │
 │ (●) Reviewed by Dr Meera Rao,          │  the byline row — name + role, a
 │     Obstetrician                       │  small verified mark; never an avatar
 │ [hero image | film slot]               │
 │                                        │
 │ H2 Section                             │  title3 20
 │ body, 17/1.55, measure ≤ 34em          │
 │ ┌ callout ─────────────────────┐       │  surfaceAlt well, one line of
 │ │ When to see someone …        │       │  action eyebrow
 │ └──────────────────────────────┘       │
 │ ▸ Long section (collapsed)             │
 │ Myth / Fact                            │
 │                                        │
 │ ▸ References                           │  collapsed by default
 │ Was this helpful?   [Not really] [Yes] │  two outlined pills, no thumbs
 │ Up next ──────────────────────────────  │  2 cards visible, then related
 │ [card] [card]                          │  activity / recipe / product rows
 └────────────────────────────────────────┘
```

Rules that came out of the table, each anchored to a reference:

1. **The byline is a "Reviewed by", not a "By".** Flo's medical-board badge
   is the single most trust-carrying element in the whole set, and every one
   of our models already holds a name and a role. Where the reviewer is one of
   the app's own experts (`lib/experts/`), link the name to their card.
2. **References are collapsed, present, and last** — Flo, Superpower, GoHenry.
   `evidence` renders there. A clinical piece without one is a defect.
3. **"When to see someone" is a callout inside the body, not a footer** — it
   is our clinical invariant made visible, and it ends with the disclaimer
   and the calm route to a doctor. `PvRead.whenToSeeSomeone` is already the
   field.
4. **"Was this helpful?" as two outlined pills, not thumbs** (GoHenry's shape,
   our design system's words). It feeds the recommendations engine's
   per-item "why". No counts shown back.
5. **Up next shows two cards** — the Flo Insights rail rule from the
   teardown, applied to the reader foot. Never a wall.
6. **The `Aa` sheet is one sheet**: size, light / sepia / dark. No font
   family choice — the design system has two families and they are not hers
   to swap. Matter and Apple Books offer more; ours is a calmer product.
7. **A thin progress line, not a bar with numbers.** Finimize/Liven. A
   percentage is a task; a line is a place.
8. **No share button in the bar.** It is in the overflow. Health content
   shared from an anxious moment is a decision she should make deliberately.

### 3.3 The chips — DECIDED: one word, "Article"

`PvDoorFormat.read` and `.article` collapse to one label. The distinction
they drew (start-to-finish vs. look-up) survives **inside the piece** — a
lookup piece opens with its glossary or FAQ section first and its TOC visible
— which is where every app in the set puts it. The enum value `read` stays
(it is persisted in door data; renaming it is a migration for nothing), its
label becomes `'Article'`, and the class doc records why. `guide`, `mythFact`
and `checklist` are different objects and keep their words.

---

## 4. What the build touches

- `lib/models/pv_read.dart` — optional fields as in §3.1; nothing existing
  changes shape. A `PvRead.fromReadArticle(...)` / `.fromArticle(...)` /
  `.fromReadItem(...)` adapter each, so the existing seed data is not rewritten
  — the data stays, the readers converge. Adapters are the "comment out,
  never delete" of models.
- `lib/screens/reader/pv_reader_screen.dart` — **the user's benchmark** ("How
  conception actually works", Fertile window door, TTC V3: *"I like it"*).
  It already has the progress hairline, TOC, text size, light/sepia/dark,
  the When-to-see-someone callout, the evidence note, related videos, Read
  next and a bookmark, and deliberately no Share. So the change is
  **five additions and nothing removed**:
  1. **Reviewed-by row** under the teaser — today author + role render
     plainly; add the small verified mark and the word "Reviewed by", and
     link the name to the expert card where it resolves (Flo's badge).
  2. **References, collapsed** — today `evidence` is one note; render it as
     a "▸ References" disclosure last in the body, with the note inside and
     the sources listed when a piece has them (Flo, Superpower).
  3. **"Was this helpful?"** — two outlined pills after References. New;
     writes one signal to the recommendations engine, shows no counts.
  4. **Related rows** — activity / recipe / product / community from
     `related`, as outlined rows with a line icon under Up next. New; this
     is what `ReadArticle` had and `PvRead` did not.
  5. **Read next as a two-card rail** — today it is stacked full-width rows;
     the teardown's rail rule (two visible, then scroll) applies here too.
  Nothing else on that screen changes. The sepia/dark palette note in the
  file header stands.
- `read_reader_screen.dart`, `reading_reader_screen.dart`,
  `article_reader_screen.dart`, `father_reads_screen.dart` — their call sites
  open `PvReaderScreen` via the adapter; the files stay, commented at the
  call site, kept for revert. Book taps route to the Book Companion.
- `PvDoorFormat.read.label` → `'Article'`; `test/` has a chip-label test to
  update, and STILL-OPEN §38.5 closes.
- **Reachability test**: every read model in the app opens `PvReaderScreen`
  — a source scan that no other reader screen is pushed anywhere.
- **Ask Veda**: nothing.

Cost: an afternoon of adapters and one screen's worth of polish; ~2,500 lines
retired behind comments. Risk: the week-binding (`weekRange`) must keep the
weekly stack's ordering — `test/` around `ReadItem` pins it today and should
pin `PvRead.weekRange` after.

---

## 5. Left open, on purpose

- **The card format** — spec in §2.3, owed to the home rail, not the reader.
- **Father reads** — converge last; father mode has its own chrome and the
  Slate look, and the reader must render inside it before the old screen goes.
- **Audio "Listen"** (NYT) — the Garbh Sanskar tracks exist; a read-aloud of
  an article does not. Not in scope.

---

## 6. The brief for Claude Design — paste from here

> **ParentVeda — the one reader.** Mobile, 390×844, ParentVeda design system
> (ground `#F5F3F6`, surface `#FFFFFF`, surfaceAlt `#EDEAF0`, line 8% black,
> ink1 `#201C24`, ink2 `#5B5464`, ink3 `#8B8494`, action `#6A30B6` for the
> eyebrow, the progress line and links; Fraunces 600 for the title and H2s,
> Manrope for everything else; shadow `#D0C8DC`). Line icons only. No filled
> buttons except none — the reader has no primary action.
>
> Draw **four artboards**:
> 1. **Top of article** — bar with close (left), bookmark and `Aa` (right), a
>    1.5px progress line beneath in action at ~20%. Eyebrow "PREGNANCY ·
>    5 MIN READ", title "Round ligament pain, explained" in Fraunces 27,
>    teaser in ink2, then the **Reviewed-by row**: a small verified mark, "Reviewed
>    by Dr Meera Rao · Obstetrician" in Manrope 13, then a 16:9 hero image
>    with radius 16. First H2 and two paragraphs at 17/1.55.
>    Reference: Flo's "What causes irregular cycles" top (the byline badge),
>    Matter (the read-time line).
> 2. **Mid-article** — a paragraph, then the **When to see someone** callout
>    in surfaceAlt with an action eyebrow and three short lines ending "…talk
>    to your doctor. This is guidance, not a diagnosis.", then a collapsed
>    section row "▸ What the research says", then a Myth / Fact pair as two
>    stacked cards. Reference: Pi (list well), Flo (inline consult line).
> 3. **Foot** — "▸ References" collapsed; "Was this helpful?" with two
>    outlined pills *Not really* / *Yes*; "Up next" eyebrow with two cards
>    visible (image, title, "4 min"); then two related rows: an activity and
>    a recipe, each an outlined row with a line icon. Reference: GoHenry
>    foot, Atoms "Similar articles", Flo "Up next".
> 4. **The `Aa` sheet** — bottom sheet: text size as a five-step segmented
>    control (A → A), theme as three tiles *Light* / *Sepia* / *Dark* with a
>    sample "Aa" in each. Nothing else. Reference: Apple Books (tiles),
>    Liven (restraint).
>
> Also draw the **Dark** variant of artboard 1 to prove the tokens hold.

---

## 7. What Mobbin taught this time

- Search *parts*, not screens: "reader display settings sheet", "end of
  article screen with related articles" each returned exactly the part.
- "Headspace reading an article" returned course screens — Headspace has no
  articles in the library. Check the app has the object before asking for it.
- The story-card query surfaced dating and photo apps; the format is shared
  with feeds, so name the content ("one idea per card") not the gesture.

---

## 8. Reference index — permanent links

| File(s) | App · what | Proves |
|---|---|---|
| `flo-insights-01..10` | [Flo · Insights](https://mobbin.com/flows/6ed37217-772e-4b9e-93b7-4fe0cddf0332) | the article: byline badge, References, Up next, two-card rails |
| `flo-daily-01..08` | [Flo · Daily insights](https://mobbin.com/flows/2001bb3f-6e5d-4f59-b3d4-975592ec91f7) | the card: segmented progress, one idea, last card is a verb |
| `flo-article-top` | [Flo screen](https://mobbin.com/screens/53cf6024-1d46-4421-bde8-9408fa6e54a0) | "Reviewed by Flo Medical Board" |
| `superpower-sources` | [Superpower](https://mobbin.com/screens/a004ea41-5a43-47ac-aeab-5abfe0136ac9) | Sources block last |
| `finimize-toc` | [Finimize](https://mobbin.com/screens/6aef933a-e3de-4ae3-bd63-c06cdb6e99af) | TOC + read time for long pieces |
| `zocdoc-article`, `nyt-article`, `matter-article`, `moonly-article`, `pi-article` | [Zocdoc](https://mobbin.com/screens/eaad2d5c-df66-4e9a-9f95-bf8b4c322241) · [NYT](https://mobbin.com/screens/0fb385af-382d-4ef4-b26f-64cf3bb0d0ca) · [Matter](https://mobbin.com/screens/15c1dbe9-1c20-4727-895a-1a2bfc7becf8) · [Moonly](https://mobbin.com/screens/c5a84f7f-5c5e-484e-a3d7-7e73abd25b47) · [Pi](https://mobbin.com/screens/47242fc8-a7ba-463e-8030-833579ab47f3) | the head: eyebrow, display title, byline, hero |
| `liven-progress`, `blinkist-toolbar` | [Liven](https://mobbin.com/screens/a076b72a-8be4-40bf-a36a-26b901429502) · [Blinkist](https://mobbin.com/screens/93e6cd0e-69f7-4f2c-ab34-32d9db33c752) | thin progress line; `Aa` in the bar |
| `matter-settings`, `applebooks-settings`, `fable-settings` | [Matter](https://mobbin.com/screens/c9f61846-1003-48cf-acc9-df7c8c970ddc) · [Apple Books](https://mobbin.com/screens/a83c87b2-ce0a-450a-a685-eef410d5628b) · [Fable](https://mobbin.com/screens/8ed9301b-98de-4652-8715-c364cd8d8cab) | the `Aa` sheet, and how much of it we leave out |
| `gohenry-end`, `atoms-end`, `blinkist-takeaways` | [GoHenry](https://mobbin.com/screens/1b6b43f6-cb67-47ab-b2b3-d2da9a2b9698) · [Atoms](https://mobbin.com/screens/b7560513-9a2b-4e18-94c7-d998bd449931) · [Blinkist](https://mobbin.com/screens/1f6f9b84-3a31-46d7-8af7-3ab7c5914b2a) | the foot: sources, helpful?, related, key takeaways |
| `deepstash-card` | [Deepstash](https://mobbin.com/screens/69ecf0b4-0237-43a7-97c5-f3f3df98168a) | "Continue journey 2 of 6" — the card set as a sequence |

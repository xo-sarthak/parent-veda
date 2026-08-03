# Ask Veda × Trying to Conceive — handoff

**Written:** 2026-07-27
**For:** the terminal that owns `C:\Projects\parentveda-askveda` **and** this app repo.
**Status of everything else in TTC:** built, wired, 1099 tests passing. Ask Veda
is the one deliberate hole.

Background on the stage itself: `docs/TTC-SPEC.md`. Source of truth for the
product: `docs/TTC-Master.pdf`.

---

## Before you propose an architecture

**Read `CLAUDE.md` at the repo root.** It states what this codebase actually
uses, and exists because incoming briefs keep assuming otherwise. The short
version:

> Flutter, **singleton `ChangeNotifier` stores**, **`Navigator` + named
> `RouteSettings`**, stage-first folders, `shared_preferences` local-first,
> Supabase through one repository class, no codegen.
>
> **Not** Riverpod, Provider or Bloc. **Not** GoRouter. **Not**
> `/lib/features/`. Behaviour rules live in versioned code, never in the
> database or Directus.

If a document you were handed assumes a different stack, the document is wrong —
please build against what is in the repo rather than correcting course later.

---

## 0. Read this first — there is a live bug, not just a gap

`lib/widgets/global_ask_fab.dart` decides which Ask Veda to open by checking
whether the **parenting** route is on the stack:

```dart
const String kParentingRootRoute = 'pp/my_child';
...
final parenting = FabState.instance.inParenting;   // true iff 'pp/my_child' is in the stack
nav.push(... builder: (_) => parenting
    ? const pp.AskVedaScreen()
    : preg.AskVedaScreen(controller: pregnancy));   // ← TTC falls in here
```

The TTC stage is anchored at route **`ttc/today`**, which the observer does not
know about. So **inside TTC the floating Ask Veda button opens the pregnancy
Ask Veda**, which then answers a trying-to-conceive question with pregnancy
framing and passes `week: p.currentWeek` — a week number that is meaningless for
a couple who are not pregnant.

That ships today. It is the highest-priority item here, and it is fixable in the
app alone without touching the service.

---

## 1. What exists already (do not rebuild these)

| Piece | Where |
|---|---|
| HTTP client | `lib/services/remote/ask_veda_service.dart` → `AskVedaService.ask()` |
| Response model | same file → `AskVedaResult`, `VedaFeedItem` |
| Backend URL + kill switch | `lib/ask_veda_config.dart` → `AskVedaConfig.baseUrl` / `.enabled` |
| Pregnancy screen | `lib/screens/tools/ask_veda_screen.dart` (`preg.AskVedaScreen`) |
| Parenting screen | `lib/screens/post_pregnancy/askveda_screen.dart` (`pp.AskVedaScreen`) |
| Global FAB + route observer | `lib/widgets/global_ask_fab.dart` |
| Shared result rendering | `lib/ask_veda/veda_result_view.dart`, `lib/ask_veda/veda_core.dart` |

The 7-section contract is unchanged and TTC needs no new sections.

Current wire body (`POST /ask`):

```json
{ "question": "...", "week": 12, "trimester": "...",
  "child_age_months": 4, "domain": null }
```

There is **no field that can express "trying to conceive"**. That is the gap.

---

## 2. App-side work

### 2.1 Fix the FAB routing — *blocking, do first*

Teach the observer about the TTC stack, the same way it knows the parenting one.
The TTC root route constant already exists as `ttcHomeRoute` in
`lib/screens/ttc/ttc_common.dart` (value `'ttc/today'`).

Three-way branch: TTC → pregnancy → parenting.

### 2.2 Build `TtcAskVedaScreen`

Suggested path `lib/screens/ttc/ttc_askveda_screen.dart`.

Copy the **structure** of the two existing screens — pinned white search pill,
stage-wise suggestion cards, the seven sections below, "connect to the internet"
state on a null result. Style it with the TTC design layer
(`lib/screens/ttc/ttc_common.dart`: `TtcCard`, `ttcJakarta`, `ttcBody`,
`ttcGutter`, `ttcPanel`), **not** the pregnancy purple constants, or it will read
as a different app.

Give the route `settings: RouteSettings(name: kAskVedaRoute)` so the FAB
suppresses itself over it, exactly like the other two.

**Suggestion cards** should come from the chapter the couple is in —
`TtcStore.instance.today.chapter`, then
`ttcChapterContent[chapter]!.askVeda(hinglish)` in
`lib/ttc/ttc_chapter_data.dart`. Three per chapter, already written in both
languages.

### 2.3 Wire the chapter suggestions

`lib/screens/ttc/ttc_chapter_screen.dart` → `_AskVedaCard` currently calls
`ttcSoon(context, 'Ask Veda')`. Point it at the new screen with the question
pre-filled. Search the file for the comment naming Phase 7 — it marks the spot.

### 2.4 Partner mode — a privacy decision, not just plumbing

`lib/screens/ttc/ttc_partner_screen.dart` has no Ask Veda entry yet. When you add
one, **his app must not send her cycle day**.

The whole TTC data model is built so he never reads her cycle: `ttc_cycles` is
own-row with no partner policy, and he sees only the derived chapter she
publishes to `ttc_journeys.current_chapter` (see `0041_ttc.sql` and
`TtcStore.displayChapter`). Sending her cycle day to the service from his device
would route around that on the client side.

**Rule: from his account send `chapter` only. Never `cycle_day`.**

---

## 3. Service-side work

### 3.1 New context fields — additive, and never a filter

The master document is explicit that stage is framing, not gating:

> "One mother, one journey — there is deliberately no domain gating. A
> postpartum mother can still ask about the anatomy scan and get a full answer,
> phrased in the past tense. Stage is context for framing, never a filter."

So these are extra fields on the same endpoint. Nothing is excluded because of
them.

Proposed additions to `POST /ask`:

```json
{
  "stage": "trying",
  "chapter": "theWaitingDays",
  "cycle_day": 22,
  "ttc_path": "natural",
  "months_trying": 9
}
```

* `stage` — `trying` | `pregnancy` | `parenting`. Persisted app-side in
  `profiles.life_stage` (added by `0041_ttc.sql`) and in `LifeStageStore`.
* `chapter` — one of `preparingTogether`, `knowingYourRhythm`, `tryingTogether`,
  `theWaitingDays`, `aNewBeginning`. Enum in `lib/ttc/ttc_chapter.dart`.
* `cycle_day` — **omit entirely from the partner's app** (§2.4).
* `ttc_path` — `natural` | `ovulationInduction` | `iui` | `ivf` |
  `frozenEmbryoTransfer` (`TtcPath`). Changes the register a lot: someone
  mid-IVF asking about a two-week wait means something different.
* `months_trying` — from `TtcStore.daysTrying`. The single most useful
  personalisation signal in this stage; "we have been trying two years" should
  never get the same answer as "we started last month".

Mirror these in `AskVedaService.ask()`.

### 3.2 Caching must bucket on TTC context

Caching is already stage-bucketed by trimester / child age. Add the TTC bucket —
otherwise a Chapter 1 couple and a Chapter 4 couple share a cached answer, and
the framing will be wrong for one of them.

Suggested key: `stage + chapter + ttc_path`. **Not** `cycle_day` — that would
give a 1-in-28 hit rate and defeat the cache.

### 3.3 Red-flag routing needs TTC phrases — *safety, do not skip*

Existing red-flag routing is pregnancy- and parenting-shaped. TTC has its own
emergencies, and one of them is genuinely time-critical:

* **Positive test + one-sided pain / shoulder-tip pain / dizziness / bleeding** →
  possible ectopic pregnancy. Same-day care. This is the single most important
  phrase set to add.
* Severe pelvic pain, or pain bad enough to interrupt the day.
* Heavy bleeding, or bleeding between periods.
* OHSS symptoms during or after an IVF cycle — rapid bloating, breathlessness,
  sharp weight gain.
* Periods that have stopped entirely.

The calm-routing rule holds: route to a doctor without alarm styling.

The app already writes this warning into chapter content
(`ttcChapterContent[TtcChapter.theWaitingDays]!.medical`), so the wording is
there to match against and to stay consistent with.

### 3.4 Corpus ingest — the actual bulk of the work

Precedent: the parenting side had nothing to ground on until the Dart offline
corpus was exported, taking the corpus from 19 chunks to 900+. TTC is in exactly
that position now — **the service currently has zero TTC content**, so today it
would answer every TTC question from the medical-authority web fallback.

All of this is written, bilingual, and structured for export:

| File | What it holds | Feed section |
|---|---|---|
| `lib/ttc/ttc_daily_data.dart` | 24 insights, 16 myths, 25 ritual items, 12 nutrition, 12 movement, 16 journal prompts | S4 content |
| `lib/ttc/ttc_chapter_data.dart` | 5 chapters × sections, action plans, medical guidance | S4 content |
| `lib/ttc/ttc_tests_data.dart` | 10 tests: what it measures, why, **when in the cycle**, Indian price, how to read it | S4 content |
| `lib/ttc/ttc_can_i_data.dart` | 12 "Can I…?" verdicts with why + Indian context | S4 content |
| `lib/ttc/ttc_products_data.dart` | 8 products with look-for **and watch-out** | S6 products |
| `lib/ttc/ttc_partner_data.dart` | 12 partner missions, 5 partner briefs | S4 content |
| `lib/ttc/ttc_prepare_data.dart` | 13 bookable offerings | S7 services |
| `lib/ttc/ttc_trackers_data.dart` | 8 trackers' "why this exists" copy | S4 content |

Two things to preserve when chunking:

1. **Both languages.** Every field has an `…En` / `…Hi` pair, and a question in
   the second language should retrieve the `…Hi` chunk.

   ⚠️ **That second language is mid-migration, so do not assume a script.**
   The house style moved from Hinglish-in-Latin to **Hindi in Devanagari** on
   2026-08-03, but only `weekContent.json` has actually moved. **Everything
   under `lib/ttc/` is still Latin-script Hinglish today.** Ingest whatever the
   export gives you rather than normalising to an assumed script, and expect
   TTC `…Hi` fields to switch to Devanagari in a later pass — at which point
   the embeddings for those chunks must be regenerated, because the vectors for
   "takleef" and "तकलीफ़" have nothing to do with each other.
2. **The honesty half.** For products, `watchOut` must be ingested with the same
   weight as `lookFor` — several entries exist mainly to talk a couple *out* of
   buying something, and dropping that half turns a research page into an advert.

Community stays **permanently excluded** as a source, TTC rooms included.

### 3.5 Doc id namespace + deep-linking

`VedaFeedItem.docId` is "the app's own id" and the app resolves it to a real
screen — `_openFeedItem` in `lib/screens/tools/ask_veda_screen.dart:773`
currently branches only on `kind`.

Pick a namespace when exporting so the TTC screen can deep-link rather than
falling back to the generic reader sheet. Suggested, matching the existing
`cani_` / `ppprod_` convention:

```
ttcinsight_<id>   ttcmyth_<id>     ttcchapter_<chapter>_<face>
ttctest_<id>      ttccani_<id>     ttcprod_<id>
ttcmission_<id>   ttcoffer_<id>
```

Then `_openFeedItem` in the TTC screen can route `ttctest_` → `TtcTestsScreen`,
`ttccani_` → `TtcCanIScreen`, `ttcprod_` → `TtcProductsScreen`, `ttcoffer_` →
`TtcOfferingScreen`, and so on. All those screens exist.

### 3.6 S7 services can be real

TTC offerings are already real `Offering`s in the booking engine, filed under
`ServiceStage.tryingToConceive` (see `lib/booking/booking_catalog.dart` →
`_fromTtc`). So the services section can point at something bookable rather than
a placeholder — ids in `lib/ttc/ttc_prepare_data.dart`, all prefixed
`ttc_consult_` / `ttc_course_` / etc.

---

## 4. Things that must not break

Carried from the product's standing rules — worth restating because they are
easy to erode from the service side:

1. **No domain gating.** A TTC user asking about labour gets a real answer.
2. **Grounded, not generative.** Only ParentVeda content or the medical-authority
   whitelist. Say "no answer" rather than improvise.
3. **Community is never a source.**
4. **Empty sections render "coming soon"**, never collapse.
5. **Every section key returns**, even when empty.
6. **Never a diagnosis.** Clinical surfaces route calmly to a doctor.
7. **A failure is a content gap**, logged and ranked by how often it is asked —
   the gap list is the editorial to-do list. TTC will generate a lot of these
   early; that is the flywheel working, not a fault.

---

## 5. Suggested order

1. **FAB routing fix** — stops a live wrong-stage answer. App only, ~30 min.
2. **`TtcAskVedaScreen`** with chapter suggestions, calling the existing service
   with no new fields. Works immediately against web fallback.
3. **Corpus ingest** — the biggest win. Turns fallback answers into grounded ones.
4. **Context fields** + cache bucketing, both sides.
5. **TTC red flags.** Could be moved to (1) if the service ships before the app.
6. **Doc id namespace + deep-linking.**
7. **Partner entry**, respecting §2.4.

Steps 1–2 are worth doing even if the service work waits: they remove the wrong
answer and give a real door.

---

## 6. Where to record decisions

`docs/TTC-SPEC.md` §7 lists Ask Veda as the deferred item;
`docs/STILL-OPEN.md` §9.1 says the same. Please update both as this lands so the
two files do not drift from reality.

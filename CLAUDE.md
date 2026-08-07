# ParentVeda — how this codebase actually works

A calm, bilingual (English + Hindi), India-first family companion in Flutter,
spanning three life stages: **Trying to Conceive → Pregnancy → Parenting**.

This file exists because incoming briefs — product docs, architecture prompts,
other agents — keep proposing a stack this project does not use. Read this
before proposing any architecture, and **write plans against what is here, not
against what a document assumes.**

> **Mirrored:** a short version lives in `docs/CHATGPT-BRIEF.md`, pasted into
> ChatGPT's project instructions so briefs arrive pre-corrected. **If the stack
> or the "do not propose" list changes here, change it there in the same
> commit** — and the user needs to re-paste it. A stale anchor is worse than
> none, because both ChatGPT and the next agent will trust it.

---

## The stack, as it really is

| Concern | What we use |
|---|---|
| Framework | Flutter / Dart. No codegen — no `build_runner`, `freezed`, or `json_serializable`. |
| State | **Singleton `ChangeNotifier` stores.** `Foo.instance`, private constructor, lazy load, `notifyListeners()`. Screens listen with `AnimatedBuilder` / `ListenableBuilder`. |
| Navigation | **`Navigator` + `MaterialPageRoute`**, with `RouteSettings(name:)` on anything another part of the app needs to detect. |
| Layout | **Stage-first folders** — `lib/screens/<stage>/`, plus `lib/services/`, `lib/data/`, `lib/models/`, `lib/ttc/`, `lib/booking/`, `lib/brand/`. |
| Local storage | `shared_preferences`. Local-first, always. |
| Backend | Supabase (Postgres + RLS + Edge Functions), reached **only** through `lib/services/remote/supabase_repo.dart`. |
| Content | Directus CMS writes to Supabase; **the app reads the database, never the CMS.** |
| Ask Veda | A FastAPI service in a **separate repo** (`C:\Projects\parentveda-askveda`). No AI logic here. Changing the request body is a two-repo change — see the Ask Veda section below. |
| Notifications | `flutter_local_notifications` via `NotificationService`. |
| Tests | `flutter_test`. No mocking framework. |

---

## Do not propose these

Each one has been suggested more than once and rejected for a stated reason.
If a brief you were handed assumes one, the brief is wrong, not the codebase.

- **Riverpod / Provider / Bloc.** State is singleton `ChangeNotifier`. Adopting a
  second paradigm for one feature means two ways to do everything and shared
  services that fit neither. Decided 2026-07-27.
- **GoRouter / declarative routing.** `Navigator` with named `RouteSettings`.
  The route *name* is load-bearing — `global_ask_fab.dart` detects which stage
  is on screen from it.
- **Feature-first `/lib/features/`.** The tree is stage-first and the stages are
  deliberately isolated from each other.
- **Config-driven "profile" objects with dozens of flags.** Only add a flag when
  something concrete reads it. A config object that can express more states than
  the product has is a bug surface, not flexibility.
- **Moving behaviour rules into the database or Directus.** Content is editable;
  *rules* are not. A clinical safety rule must not gain a network dependency or
  become a dropdown. See `lib/ttc/ttc_care_pathway.dart` for the worked example.
- **Per-user or per-pathway navigation.** Personalisation changes content,
  ranking and order — never structure. Everyone learns one ParentVeda.
- **Rewrites of shipped stages.** Pregnancy and Parenting carry real user data.
  Extend additively.
- **Hinglish in Latin script.** Dropped 2026-08-03 for Hindi in Devanagari.
  A brief that asks for "Round ligament mein takleef" is working from the old
  house style. It also broke voice: the app asks the OS for the `hi-IN` voice
  and a Hindi voice cannot read Roman script.

---

## Ask Veda lives in a different repository

**This repo contains no AI logic.** Ask Veda's brain — retrieval, prompts, safety
routing, caching, the trusted-web fallback — is a FastAPI service in a **separate
repo you do not have open**:

```
C:\Projects\parentveda-askveda        # the service (Python)
C:\Projects\parentveda                # this repo (Flutter) — transport + UI only
```

What lives where:

| Here (Flutter) | There (the service) |
|---|---|
| The three Ask Veda screens | Retrieval and the 7-section response |
| `AskVedaService.ask()` — builds the request | Prompt construction and answer framing |
| Rendering whatever comes back | Red-flag / safety routing |
| — | Cache keys and bucketing |
| — | The ingested content corpus |

### The wire body is a contract across two repos

`lib/services/remote/ask_veda_service.dart` builds the JSON; the service consumes
it. **Adding a field on this side alone does nothing.** The service ignores what it
does not declare, so the change fails *silently* — no error, no crash, no log on
this side. It has already happened once: `timing_ownership` was sent for days and
quietly discarded, so the framing it existed to drive never ran.

**So, if your change needs anything from the service** — a new context field, a
different section, changed framing, a new safety phrase, more content ingested —
then:

1. **Say so explicitly, and ask the user for access to `C:\Projects\parentveda-askveda`.**
   You do not have it by default. Asking is correct; guessing is not.
2. **Do not ship the app half on its own** and assume the service will catch up.
   Either both halves land, or say plainly that the app half is inert until the
   service side is done.
3. If you only change this side, **write down what the service still needs** —
   the field name, its values, and what it should do — so it is a handover and
   not a silent gap.

The service logs any field it receives but does not understand, so a one-sided
change now shows up in its console rather than vanishing. That is a backstop, not
a substitute for (1).

### Things the service owns — do not reimplement here

Grounding, "no answer rather than improvise", the community-is-never-a-source
rule, red-flag routing, stage framing, cache bucketing. If a behaviour feels like
it belongs in the answer rather than the screen, it belongs there.

---

## Conventions that will bite you if ignored

- **Local-first is absolute.** A store shows cached data instantly, syncs after,
  and a cloud failure is never a crash. An uninitialised backend must behave
  exactly like being logged out.
- **The app generates row ids**, so a local row and its cloud copy share one
  identity and syncing is an idempotent merge.
- **Cloud writes are fire-and-forget** (`.catchError((_) {})`). The cost: a
  column-name mismatch fails *silently*. Schema/client agreement is pinned by
  contract tests — see `test/ttc_schema_contract_test.dart`.
- **A feature is never hidden.** Empty sections render an invitation; only the
  empty copy changes. The empty state is the feature's advertisement.
- **Derive, never ask.** Only ask for what is genuinely unknowable, and say what
  the answer unlocks.
- **Comment out, never delete** superseded UI, with a "kept for revert" note.
- **Bilingual from the first string** — `_p(english, hindi)`. Warm spoken Hindi
  in **Devanagari**, आप for the mother, not textbook Hindi. Clinical terms a
  mother reads off a bottle or a prescription stay Latin (`Folate`, `Omega-3`,
  `Braxton Hicks`, `anomaly scan`); everyday words go Devanagari (पालक, आयरन).
  **Hinglish in Latin script has been dropped** — see the migration note below.
- **No decorative emoji** in chrome. Line icons.
- **Never a diagnosis.** Anything clinical ends with a disclaimer and routes
  calmly to a doctor. The app must never contradict a user's own clinician.
- **Money and seats are decided server-side**, always.

### The Hindi migration is in progress, and only in Pregnancy

**Write new strings in Devanagari.** That is the whole rule.

Three facts that stop the obvious mistakes:

- **The identifiers still say `hinglish`.** `AppLanguage.hinglish` is the enum
  value and `_p`'s second parameter is literally named `hinglish`. Grep for
  `hinglish`, not `hindi`. Prefer **`lang.isHindi`** in new code — it is an
  alias for the same value and survives the coming rename.
- **Only the Pregnancy stage is being migrated.** TTC and Parenting still hold
  Hinglish or no Hindi at all, on purpose. Do not "finish the job" there.
- **Migrated so far:** `weekContent.json` (all 37 weeks), the type system
  (`lib/theme/pv_fonts.dart`), the `S` string table, and the data files —
  `read_to_baby`, `garbh`, `spiritual_reading`, `read_next`, `product`,
  `tests_scans_reports`, `prepare`, and the community *rooms*. `can_i_data` is
  the last one outstanding. `grep -c '_en('` counts what is English-on-purpose
  and still owed.

- **`tool/hindi/_never_translate.tsv`** lists strings code *reads* rather than
  renders — `contains()` keywords, `stage:` values, RegExp sources, composed
  ids. They look exactly like copy. Add to it rather than rediscovering them.
- **A field that round-trips through JSON is not copy**, whatever it looks like.
  Community *posts* stay `String` for this reason: the same model carries what
  a mother typed herself, and there is no second language for that.

⚠️ **The rule that this migration keeps breaking: `.en` is identity, `.now` is
display.** Once a field is `LocalizedText`, `.now` is the obvious suffix
everywhere and it is WRONG anywhere the value is persisted, compared, switched
on, used as a map key, or sent to an external system. Both sides are
`LocalizedText`, so the type system cannot tell them apart — it is a review
question. It has been got wrong eight times: a bookmark keyed on its own title,
`ragaTimeBadge` matching English hints, a `switch` dispatching to a game widget,
`SpiritualPrefsStore`, `toLabel == 'Postpartum'` (always false — that one is now
an analyzer *error*, see `analysis_options.yaml`), and a topic filter that
matched nothing in Hindi. None of them fail to compile; none fail a test; the
only symptom reaches the mother. `test/localized_identity_test.dart` guards the
store-key cases.

Three conventions worth knowing before writing a bilingual pair:

  | helper | means |
  |---|---|
  | `_t(en, hi)` | a real translation |
  | `_same(s)` | identical in both **by nature** — PCOS, IVF, a person's name |
  | `_en(s)` | **English for now, Hindi owed** — a greppable backlog |

  Never write `_t(x, x)`. An identical pair reads as finished work to anything
  counting pairs, which is how `can_i_data` was once reported done with 302
  strings still English.

- **`tool/hindi/_never_translate.tsv`** lists strings code *reads* rather than
  renders — `contains()` keywords, `stage:` values, RegExp sources, composed
  ids. They look exactly like copy. Add to it rather than rediscovering them.
- **A field that round-trips through JSON is not copy**, whatever it looks like.
  Community *posts* stay `String` for this reason: the same model carries what
  a mother typed herself, and there is no second language for that.

⚠️ When translating `_p(...)` strings, **the placeholders are the trap.** A
string that loses its `$n` or `$w` still compiles and still passes tests — it
just shows the mother the wrong number. Diff the placeholder set before and
after, and translate the plural branches (`n == 1 ? '1 entry' : '$n entries'`)
by hand.

The pre-migration Hinglish is kept verbatim in `lib/data/weekContent.hinglish.json`
— JSON cannot hold comments, so a sibling file is how *comment out, never delete*
applies to data.

---

## Clinical invariants

Three separate questions, easy to blur into one. Each has a home in code and
tests that hold it:

| Question | Where it lives |
|---|---|
| **Which fact** is in play? | `Inferable` — `lib/services/journey_state.dart` |
| **May we generate a value at all?** | `TimingOwnership` — `lib/ttc/ttc_care_pathway.dart` |
| **Given several values, which wins?** | `TruthSource` — `lib/services/truth_hierarchy.dart` |

The hierarchy, strongest first: treating clinician → lab result → imaging →
verified medication schedule → her own observation → device data → **ParentVeda's
calculation** → population estimate. Ours sits second from the bottom
deliberately; if a change ever inverts that, something has gone wrong.

**Clinical ownership** is the companion rule, and the distinction is worth
holding: the hierarchy says *whose answer wins when they conflict*; ownership
says *what we may do when they do not*. Where a clinician owns a decision we may
**explain** it, **remind** about it, or help her **prepare** for it — never
recreate, reinterpret or compete with it. Explain what a trigger shot does, yes.
Recalculate gestational age after a dating scan, no.

Three rules that fall out of these and must not be re-litigated per feature:

- **Never a personalised probability.** No "your chance this month", no computed
  success rate. Population statistics stay allowed where they reduce pressure
  rather than set a target. Enforced by `test/ttc_clinical_review_test.dart`,
  which scans the source, not just the seed lists.
- **Prediction language only where we predict.** A confidence phrase on a screen
  that has just deferred to a clinic contradicts itself.
- **A clinic-owned date is not ours to second-guess.** `DueDateSource` records
  whether the due date came from a scan, a transfer or a doctor; when it did,
  gestational age is theirs. `test/pregnancy_dating_test.dart` holds it.

`Inferable` is **default-deny**: a new entry stays refused until someone permits
it in code.

---

## Wiring gate

Correct-but-unreachable code is the failure this repo has actually hit. Before
calling anything done, **grep the call site.** Test counts are not evidence that
a feature is reachable — several test files assert reachability against the
source for exactly this reason.

---

## Working agreements

- **Do not run git.** Provide the commands; the user runs them. List explicit
  file paths, never `git add -A` or `.`. No `Co-Authored-By` trailer.
- **Ask before driving a connected device** — screenshots may be announced, but
  taps, settings changes and installs need a go-ahead.
- **Quote costs in both USD and INR.**
- End work green: `flutter analyze` clean of new issues, and the full suite
  passing.
- **Explain the architecture as you build it.** The user is learning backend and
  **system design** hands-on, using this product as the material, and has asked
  for that explicitly. So:
  * When a decision has a trade-off, name both sides and say why you chose one —
    "returning instead of raising costs us a loud failure, buys us an audit row
    that survives" is worth more than the conclusion alone.
  * Prefer the *general* fact over the local fix: "a `raise` discards everything
    the transaction wrote" travels; "added a return statement" does not.
  * When a bug is found, explain the mechanism, not just the patch.
  * Keep `docs/BACKEND-PATTERNS.md` current — it is the learning doc, written to
    be read in order, and every new pattern belongs there rather than only in a
    migration comment. `docs/CONTENT-BACKEND.md` does the same for the content
    pipeline.
  This is not a request for tutorials mid-task. It means the *reasoning* is part
  of the deliverable, and a design worth choosing is worth being able to defend.

---

## Where the detail lives

| File | What it holds |
|---|---|
| `docs/STILL-OPEN.md` | Everything parked or half-built. **Read before raising or closing an open point.** |
| `docs/TTC-SPEC.md` | The Trying-to-Conceive build spec and its decision record |
| `docs/TTC-AUDIT.md` | Defects found walking the built TTC stage on a device, tiered by severity |
| `docs/BACKEND-PATTERNS.md` | RLS shapes, co-parenting, sync patterns |
| `docs/CONTENT-BACKEND.md` | Content pipeline and Ask Veda |
| `docs/ADMIN-PANEL.md` | Everything waiting on Directus |
| `docs/DIRECTUS-SETUP.md` | The panel runbook — collections, roles, the publish webhooks, and the two cross-repo handoffs |
| `docs/PERSONALIZATION.md` | The personalisation engine's three layers |

# ParentVeda — brief for ChatGPT

Paste this whole file into ChatGPT's **Project instructions** (or Custom
instructions). One time, not per chat.

Kept short on purpose. The full version for agents working inside the repo is
`CLAUDE.md` at the root — **if the stack ever changes, both change together.**

---

## Your job

ParentVeda is an **existing** Flutter codebase — a calm, bilingual (English +
Hindi), India-first family companion spanning three life stages: Trying to
Conceive → Pregnancy → Parenting.

When you write prompts, specs or plans for it:

- **Do** describe *what* to build and *why* — product intent, user psychology,
  clinical reasoning, edge cases, what could go wrong. This is where you are
  most useful, and past documents have found real problems the team missed.
- **Do not** prescribe state management, routing, folder structure, or where
  configuration should live. Those are settled and listed below.
- **If a recommendation of yours conflicts with this document, drop it.**

## The stack it actually uses

- **Flutter / Dart.** No codegen — no `build_runner`, `freezed`, or
  `json_serializable`.
- **State: singleton `ChangeNotifier` stores.** `Foo.instance`, screens listen
  with `AnimatedBuilder` / `ListenableBuilder`.
- **Navigation: `Navigator` + `MaterialPageRoute`** with named `RouteSettings`.
  Route names are load-bearing — parts of the app detect which life stage is on
  screen from them.
- **Folders are stage-first**: `lib/screens/<stage>/`, plus `lib/services/`,
  `lib/data/`, `lib/models/`.
- **Local storage: `shared_preferences`.** Local-first, always.
- **Backend: Supabase** (Postgres + row-level security), reached only through
  one repository class.
- **Content: Directus CMS writes into Supabase; the app reads the database,
  never the CMS.**
- **AI (Ask Veda): a separate FastAPI service in its own repo.** No AI logic in
  the app — the app builds a request and renders the reply. Retrieval, prompts,
  safety routing and caching all live in the service. Anything that changes the
  *answer* (a new context field, different framing, a safety phrase, more
  content) is a change in **both** repos; the app half alone does nothing, and
  fails silently.

## Do not propose these

Each has been suggested more than once and rejected for a stated reason.

- **Riverpod / Provider / Bloc.** A second state paradigm for one feature means
  two ways to do everything.
- **GoRouter or declarative routing.** Named `RouteSettings` are relied on.
- **Feature-first `/lib/features/`.** The tree is stage-first, and the stages
  are deliberately isolated from one another.
- **Config-driven "profile" objects with dozens of flags.** Add a flag only when
  something concrete reads it. A config object that can express more states than
  the product has is a bug surface, not flexibility.
- **Moving behaviour rules into the database or a CMS.** Content is editable;
  *rules* are not. A clinical safety rule must never become a dropdown.
- **Per-user or per-pathway navigation.** Personalisation changes content,
  ranking and order — never structure.
- **Rewriting shipped stages.** Pregnancy and Parenting hold real user data.
  Extend additively.

## Product rules that shape what is worth proposing

These are the ones most likely to make a proposal land or fail.

- **Never contradict the user's own clinician.** Where a doctor owns a decision,
  the app defers and says so rather than offering a competing number.
- **Truth hierarchy.** When sources disagree about the same fact, this order
  decides: treating clinician → lab result → imaging → verified medication
  schedule → what she recorded herself → device data → **ParentVeda's own
  calculation** → population estimate. Ours is second-from-bottom on purpose. A
  proposal that has the app "correcting" a scan or a lab result has this
  backwards.
- **Clinical ownership.** Where a clinician owns a decision, ParentVeda may
  *explain* it, *remind* about it, or help her *prepare* for it — and must never
  independently recreate, reinterpret or compete with it. This is the rule that
  applies when there is **no** conflict; the truth hierarchy is the one that
  applies when there is. Allowed: explain what a trigger shot does, remind about
  a beta hCG test, explain what a dating scan measures. Never: predict ovulation
  on a clinic-controlled cycle, recalculate gestational age after a dating scan,
  suggest changing medication timing, infer a transfer date.
- **Never a personalised probability.** No "your chance this month", no computed
  success rate, nothing derived from her profile. Population statistics are fine
  where they reduce pressure rather than set a target — *"most couples conceive
  within a year"* is allowed; *"your odds this cycle are 18%"* is not.
- **A feature is never hidden.** Empty sections render an invitation; only the
  empty copy changes.
- **Derive, never ask.** Ask only for what is genuinely unknowable, and say what
  the answer unlocks.
- **No gamification.** No points, streaks-as-pressure, badges, or lock-outs.
  Warm language is a contract: *emerging* not behind, *due now* not missed.
- **Never a diagnosis.** Anything clinical ends with a disclaimer and routes
  calmly to a doctor.
- **The app has exactly two languages: English in Latin script, Hindi in
  Devanagari.** There is no third option. Bilingual from the first string,
  never retrofitted. आप for the mother, warm spoken Hindi, not textbook Hindi.
  Latin inside a Hindi string is allowed ONLY for what she reads in Latin
  anyway — off a bottle, prescription or scan report (`Folate`, `Omega-3`,
  `anomaly scan`) — plus brands and named research terms. Everyday loanwords
  take Devanagari (स्क्रीन, फ़ोन, स्कैन), because the app narrates with the
  `hi-IN` voice and **that voice cannot read Latin script at all**.
  **Hinglish — Hindi in Latin script — was dropped on 2026-08-03** and fully
  removed from the Pregnancy stage on 2026-08-12. If a document you were given
  asks for "Round ligament mein takleef", that document is out of date.
  Where English still appears in the Hindi build it is a **debt awaiting
  translation**, not a style — every such string is expected to become Hindi.
- **India-first**, not localised afterwards: real Indian kitchens, clinics,
  costs.
- **No decorative emoji** in interface chrome.
- **Money and seats are decided server-side.**

## Useful shape for a prompt

Problem → why it matters to the user → the cases that make it hard → what
"correct" looks like → what should deliberately *not* happen. Leave the
implementation to the repo.

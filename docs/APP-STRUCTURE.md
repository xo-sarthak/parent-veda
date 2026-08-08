# The five tabs, and what Today leads with

Two rules, one page. The first says where a screen lives. The second says what
a parent sees first when she opens the app.

Both are **additive experiments**: nothing was moved, renamed or removed to
build them. The shipped Today is untouched and is still what everyone lands on.

---

## 1. The five tabs

The app has five mother tabs and they already existed. What was missing was a
statement of what each one is *for*:

| Tab | The question it answers |
|---|---|
| **Today** | What matters right now? |
| **Prepare** | What can I learn or buy? |
| **Tools** | What can I track or check? |
| **Community** | Am I normal, and who can I ask? |
| **Calendar** | What is coming up? |
| **Profile** *(from the Today avatar, not a tab)* | Where is my own stuff? |

If a surface does not answer its tab's question, it is in the wrong tab.

That list lives in **`lib/services/app_structure.dart`** as data, with
`homeFor(surfaceId)` answering "which tab does this belong under" for any
surface.

### Why a file rather than a convention

Every hub currently owns its own list — the parenting Tools hub hardcodes
fourteen rows, the Explore drawer thirty-nine. Nothing stops one surface
appearing in two of them, and nothing tells you where a *new* surface should go.

That is how an app comes to feel like everything is happening everywhere. Not
from one bad decision, but from forty small ones taken without a rule to check
against.

### What it deliberately does not do yet

**It does not rewire the existing hubs.** They keep their hardcoded lists, and
`app_structure.dart` is currently read only by the focus-ordered Today.

Worth naming rather than hiding: until the hubs read from it, this file is a
*description* of the structure, not a *mechanism* enforcing it. The trade-off
was deliberate — rewiring live hubs means editing shipped screens, and this pass
was scoped to adding alongside rather than changing what exists. The mechanism
half is one `homeFor()` call per hub away whenever that becomes right, and
`test/landing_focus_test.dart` is what makes that step safe: it already asserts
no surface is declared twice and that every destination owns something.

---

## 2. The landing focus

**`lib/services/landing_focus.dart`** decides which block Today leads with.
Two inputs, in this precedence:

1. **What she chose**, if she chose.
2. Otherwise, **what her phase implies**.

### Defaults by phase

| Phase | Leads with | Why |
|---|---|---|
| Trying to conceive | `bodyAndMind` | The cycle and her own head are the whole question |
| Pregnancy | `weeklyGrowth` | The week is the thing she came for |
| Parenting, under 4 months | `problemLed` | Sleep and feeding *are* the day |
| Parenting, 4 months and over | `activityLed` | The questions turn outward |

The cutover is one named constant, `kProblemToActivityMonths`, so moving it is
one edit and one test rather than a hunt. Four months is a convention, not a
finding, and a baby does not read it.

**An unknown baby age reads as newborn.** Showing sleep and feeding to the
parent of a one-year-old is a mild mismatch; showing activities to someone who
has not slept is worse. When you must be wrong, be wrong in the kinder
direction.

### Her override

*"What are you here for?"* — a sheet, reachable from the Focus pill on Today.
Three or four options per phase, in her words: **Watch baby grow · Track my body
· Prepare for birth · Just keep me calm.**

Clearing the choice is a first-class option ("no strong feeling — decide for
me"), because a question you can only ever answer is a trap that adds state.

---

## ⚠️ The constraint that matters more than the feature

**The focus changes card order on Today. Nothing else.**

Not the tabs. Not the navigation. Not which screens exist. Not what any other
tab shows. Everyone gets the same ParentVeda and reaches the same things by the
same routes; only the top of one list differs.

This is the CLAUDE.md rule, not a style preference:

> Personalisation changes content, ranking and order — never structure.
> Everyone learns one ParentVeda.

A focus that hid a tab, moved a screen, or unlocked something would be a
different product per user. Then no two mothers could help each other, no
screenshot in the community would match anybody else's, and no support answer
would be true twice. That is a product failure long before it is a code one, and
it arrives one reasonable-looking commit at a time — which is why
`test/landing_focus_test.dart` asserts that every surface keeps its home under
every focus.

---

## How it is wired

```
main_scaffold.dart
  └── TodayHomeScreen          the wrapper, with a Classic | Focus pill
        ├── HomeScreenB        the shipped Today, constructed as-is
        └── HomeFocusScreen    the experiment
```

**Classic is the default**, and the toggle is **session-only**. An experiment
that opts everyone in by default is not an experiment, it is a release — and a
persisted toggle means a reviewer opens the app days later still in an
experimental home and reports its bugs as the product's.

`LandingFocus` *is* persisted, because that is a parent's real preference about
her own app rather than a reviewer's temporary lens.

### Why the focus screen uses the real cards

`GrowModule`, `TodaysVideoCard`, `DailyReadsHomeCard`, `LaunchSpotlight` and
`InviteNudgeCard` are constructed here, not reimplemented. The Grow experiment
learned this the hard way: a version built from copies drifts the moment anyone
touches the original, and then the comparison is against something that never
shipped.

The cards that are *private* to `home_screen_b` — the hero, Garbh, journal,
medicines, products — cannot be reused without editing it, and editing it is
what this experiment exists to avoid. Those appear in the **"also" row** as
routes into the tab that owns them. Which is the demotion the brief asked for
anyway, so the constraint and the design happen to agree.

### Reverting

Delete `today_home_screen.dart` and restore one line in `main_scaffold.dart`.
The line is already there, commented, next to its replacement.

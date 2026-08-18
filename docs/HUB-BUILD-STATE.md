# The forty hubs — what was built, and what is owed

Built 2026-08-17 from `PARENTVEDA_40_HUB_DOORS_REVISED.xlsx`.
Contract: `docs/HUB-BUILD-SPEC.md`. Origin of the door test:
`docs/SCANS-HUB-RECONCILIATION.md`.

---

## 1. What exists now

| Stage | Hubs | Doors | Hub screens | Open directly |
|---|---|---|---|---|
| Pregnancy | 10 | 16 | 5 | 5 |
| Parenting | 11 | 17 | 7 | 4 |
| TTC | 7 | 12 | 5 | 2 |
| **Total** | **28** | **45** | **17** | **11** |

Skilling's 12 are deliberately absent — see §4.

**One renderer, twenty-eight configs.** `ProblemHubScreen` is unchanged; every
hub is data. Adding hub twenty-nine is a config, not a screen.

### Files

| File | Holds |
|---|---|
| `lib/data/hubs/hub_registry.dart` | the lookup, and the hub-screen-vs-direct decision |
| `lib/data/hubs/pregnancy_hubs.dart` | 9 hubs (Scans is separate) |
| `lib/data/hubs/scans_hub.dart` / `scans_hub_v2.dart` | the only hub with a V1/V2 toggle |
| `lib/data/hubs/parenting_hubs.dart` | 11 hubs |
| `lib/data/hubs/ttc_hubs.dart` | 7 hubs |
| `lib/screens/brackets/hub/hub_owed_screen.dart` | where a door goes when its content is not built |

---

## 2. ⚠️ The one-door rule is a ROUTING rule, not a style rule

Eleven of the 28 hubs have a single door whose label only restates the tile:
*Symptoms & discomforts* → *"I have a symptom"*. Those **never render a hub
screen**. The tile opens the destination directly, because a screen showing one
heading and one button is a tap of pure tax.

The test is **redundancy, not arithmetic**. A hub screen earns its place only
when it has something to disambiguate. A count-based rule ("1 door = no hub")
gets the same answer today and will eventually delete a hub screen that was
doing real work.

The single door is still written as a full config — that is where its
destination, promise and mark are declared. Skipping the screen must not mean
skipping the thinking.

---

## 3. ⚠️ Doors whose content does not exist yet

Twelve doors point at `HubOwedScreen`: a real screen that names what will be
there, what it will do for her, and — where one genuinely exists — the nearest
thing that helps today.

The three wrong answers it avoids: hiding the door (breaks *a feature is never
hidden*), opening nothing (teaches her taps do nothing), and opening the nearest
vaguely-related screen (looks like an answer, wastes her time, and she blames
herself for not finding it).

| Stage | Door | What is owed |
|---|---|---|
| TTC | Improve my chances this cycle | Timing + habits. ⚠️ **Never a computed probability.** |
| TTC | Understand my PCOS | A PCOS explainer |
| TTC | Should I seek fertility help? | The by-age guidance thresholds |
| TTC | Get ready before trying | Preconception checklist |
| TTC | Understand recovery & trying again | ⚠️ **No "meanwhile" link, deliberately** — after a loss, being handed a cycle tracker instead of what she asked for is worse than an honest wait |
| Parenting | Is my child ready? · Start & manage potty training | Nothing exists for potty at all |
| Parenting | Prepare for school | School-readiness content |
| Parenting | Follow my First 40 Days | Only a masterclass exists today |
| Parenting | Get help with a recovery concern | No mother-facing tool exists |
| Pregnancy | Check how I am feeling · Help me feel better | No mood surface exists; falls back to reads |

---

## 4. Skilling — one picker, and the gate stays shut

**Decision: one Skilling hub with a skill picker, not twelve hubs.** All 12
areas came out with one door each, every one the same sentence with a different
noun — that is one problem with twelve topics, not twelve problems.

That screen already exists (`skilling_preview_screen.dart`) and is already built
as one picker over twelve areas, which is the chosen structure.

⚠️ **It stays behind `kDebugMode`, and that was not laziness.** Two prior
decisions say so in the code:

- `LifeStage.skilling` — *"NOT a selectable stage — a fourth VALUE, not a fourth
  destination."*
- `explore_drawer.dart` — *"DEBUG-ONLY, AND IT MUST STAY THAT WAY UNTIL SKILLING
  HAS CONTENT... Shipping it to a parent would be twelve promises the app cannot
  keep."*

All 84 skilling bracket cells are still `notReady`. Shipping twelve doors onto
twelve empty rooms is exactly the filler this whole restructure removed. It
becomes reachable the day there is content — a one-line change.

---

## 5. Consult — where it is a door, and where it is not

**Two hubs only**, because seeking the expert IS the arriving reason there:

- **Infertility & IVF** → "Speak to a fertility specialist"
- **Pregnancy mental health** → "Talk to someone"

⚠️ **Both are gated on real provider supply.** The booking engine is real; the
seed list is five specialists with mock slots. A consult door that opens on an
empty calendar is worse than no door — *being ignored after paying* is complaint
#4 in our own competitor review corpus.

Everywhere else consult is a single quiet offer at the foot of the hub
(`HubConfig.closing`), and on several hubs it is **absent entirely** — nobody
books a gynaecologist because papaya was on the list.

---

## 6. Two bugs this pass found in existing tests

Both were passing for the wrong reason, which is worse than failing.

1. **`every surface a door names is declared in app_structure`** — `app_structure`
   is the *pregnancy* tab set and has no opinion about `pp_` or `ttc_` ids. The
   test was green only because no parenting or TTC hub existed yet; adding them
   would have failed every one of their doors for the wrong reason. It now asks
   the router of the stage the surface belongs to.
2. **The door-count range** asserted 2–8, which would have rejected all eleven
   one-door hubs. It now asserts 1–8, with a separate test that a one-door hub
   still declares a real destination and a real promise — so "1" cannot become
   an excuse to skip the thinking.

---

## 7. Known debt

- **Hindi: 76 hub strings owed.** Every hub string is `_en(...)` and the test
  prints the count on every run, so it cannot quietly become permanent. V1 of
  Scans stays fully translated with no exemption.
- **The doors are reasoned, not evidenced.** All 45 come from judgement. We hold
  35,000+ critical competitor reviews and search-volume data and have not checked
  the doors against them. Worth doing before the content is commissioned.
- **`HubTemplate` is barely constrained.** Several hubs could defensibly carry
  two or three of the eight values and no test holds them.
- **Journeys are not authored.** Only four exist (in the Excel). The other 41
  doors open a destination but do not yet walk a journey with layered
  content/tools/consult at the right steps.

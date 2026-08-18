# Hub build spec — how to write a `HubConfig`

Read this before writing any hub. It is the contract; deviating from it breaks
either the build or a rule that has already cost this project real time.

Source of truth for WHICH doors exist:
`PARENTVEDA_40_HUB_DOORS_REVISED.xlsx`. Do not invent or remove a door.

---

## 1. The shape

```dart
final HubConfig kMyHub = HubConfig(
  bracketId: 'pregnancy_nutrition',      // must match a Bracket.id exactly
  template: HubTemplate.trackerLed,      // or .immediateAnswer / .practiceLed
  coreQuestion: 'What should I be eating, and is this concern a problem?',
  hero: _en('Eating well, without the panic.'),
  heroSupport: _en('What to eat, and what to do when something is flagged.'),
  needsTitle: _en('What do you need?'),
  needs: [ HubNeed(...), ... ],
  closing: HubClosing(...),              // optional — see §5
);
```

`_en(...)` = English now, Hindi owed. **Every string is `_en`.** Never write
Hindi, never write `_t(x, x)`.

### The 8 template values (there are no others)

`immediateAnswer · trackerLed · learnAndPlan · practiceLed · decisionCommerce ·
longTermDevelopment · afterALoss · firstFortyDays`

**A worked example of every rule below is `lib/data/hubs/pregnancy_hubs.dart`.**
Read it first; it is nine hubs covering one-door, two-door, three-door,
consult-as-door, consult-at-the-foot and no-consult-at-all.

## 2. Doors

```dart
HubNeed(
  label: _en('What should I eat?'),      // ≤ 4 words where possible
  blurb: _en('...'),                     // MUST be > 20 chars — the promise
  mark: IntentMark.plate,                // unique WITHIN this hub
  hue: 104,                              // unique WITHIN this hub
  action: kActSomething,                 // OR surfaceId: 'nutrition'
)
```

- **`label` names an outcome, never a content type.** Banned words: content,
  tools, products, courses, consults, activities, extras, masterclass,
  articles, videos. A test fails the build if one appears.
- **`blurb` is the promise** — one line on why it is worth her time. A door with
  a title and no reason is a link.
- **`mark` and `hue` must both be unique inside the hub.** Across hubs, reuse
  freely and by meaning: "log a reading" should look the same everywhere.
- **Exactly one of `action` or `surfaceId`.** `surfaceId` must be a real id in
  that stage's router (see §4).

## 3. ⚠️ One door means the hub screen is NEVER SHOWN

A hub with a single door is legal and means: **the tile opens that door's
destination directly.** `hub_registry.dart` does the dispatch. Write the config
anyway — it is where the door's destination is declared.

Do not pad a one-door hub to two to "make it a proper hub". That is the exact
filler this rebuild removed.

## 4. Surface ids — the real routing vocabulary

Use ONLY ids that exist in the stage's router. Anything else silently opens
nothing.

**Pregnancy** (`lib/services/surface_router.dart`):
`tests_scans · appointments · due_date · reports · can_i · symptoms · movement ·
weight · kegel · contractions · hospital_bag · medication · product_guide ·
garbh_daily · consults · cohorts · birthing_classes · nutrition · masterclasses ·
shop · yoga · daily_reads`

**TTC** (`lib/screens/ttc/ttc_surface_router.dart`):
`ttc_cycle · ttc_ovulation · ttc_window · ttc_calendar · ttc_chapter · ttc_can_i ·
ttc_tests · ttc_nutrition · ttc_supplements · ttc_treatment · ttc_records ·
ttc_medication · ttc_appointments · ttc_ritual · ttc_journal · ttc_partner ·
ttc_prepare · ttc_community · ttc_care_circle · ttc_products`

**Parenting** (`lib/screens/post_pregnancy/pp_surface_router.dart`):
`pp_sleep · pp_feeding · pp_food · pp_growth · pp_vaccines · pp_what_changed ·
pp_health · pp_development · pp_milestones · pp_activities · pp_read · pp_watch ·
pp_courses · pp_products · pp_product_guide · pp_recos · pp_experts ·
pp_find_help · pp_yoga · pp_nuskhe · pp_names`

If no id fits a door, use an `action` constant and say so in a comment — the
integrator wires it.

## 5. The closing offer — consult

```dart
closing: HubClosing(
  label: _en('Talk to a doctor'),
  blurb: _en('Book a 1:1 and ask about your own case.'),
  action: kActConsult,
),
```

- **Only on hubs with 2+ doors.** A one-door hub has no screen to put it on.
- **Not a door**, except on the two hubs where the Excel says consult IS the
  arriving reason (Infertility & IVF, Pregnancy mental health).
- **Omit it entirely where booking makes no sense.** "Can I eat papaya" must not
  offer a gynaecologist. If in doubt, leave it out — an unnecessary consult
  offer makes the app feel like it wants something.

## 6. ⚠️ Integrate what already exists, where it genuinely helps

The app already has: videos, articles/reads, courses, masterclasses, cohorts,
yoga, birthing classes, 1:1 consults, products/shop, product guides, trackers,
calculators, community rooms, find-help.

**Use them where the journey genuinely calls for one, and nowhere else.**

- A product belongs where a real product need has been established — a BP
  monitor under "track my readings", not a shelf on a landing page.
- A course belongs after the immediate question is answered, offered once.
- Community belongs where other parents' experience is the answer, not as a
  default tab.
- ⚠️ **Never add one because we have one.** That is the filler this exists to
  stop. Equally: **never omit one that genuinely helps** just to look minimal —
  under-using a real capability is the opposite failure and just as bad.

## 7. Rules that will fail the build or a test

- No Hindi. `_en` everywhere.
- No inventory words in labels.
- `blurb.en` longer than 20 characters.
- Unique mark + hue within a hub.
- `bracketId` matches a real bracket.
- Never a personalised probability, never a diagnosis. Anything clinical routes
  calmly to a doctor.
- No commerce anywhere near Infertility & IVF or a loss journey.

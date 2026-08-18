# ParentVeda — full inventory dump

**Purpose:** a complete register of what is in the app today, structured so it can be
reconciled line by line against the **L1 + L2 Master** sheet.

> **existing = untouched, mapped into the flow · missing = explicitly listed as new**

**Generated from the codebase**, not written from memory — Parts B and C are extracted
programmatically, so counts are exact and nothing is omitted by oversight.

Codebase at time of dump: **653 Dart files · 258,508 lines · 104 stores.**

---

## How to read this

| Part | What it is | Use it for |
|---|---|---|
| **A** | Asset register — every content collection with exact counts | "what do we own" |
| **B** | **All 280 bracket × layer cells** with state and resolver | **the reconciliation surface** |
| **C** | Surface-id → screen map | "what does *live* actually open" |
| **D** | Screens, tools and stores, enumerated | "what UI already exists" |
| **E** | Known gaps, stated plainly | the "new" column |

**Part B is the one to reconcile against.** It is the workbook, as the code currently
implements it: 40 brackets × 7 layers, each cell carrying a state and — where live — the
exact surface it opens.

### The four states

| State | Means | Renders |
|---|---|---|
| `LIVE` | ships today; the resolver is named | the real thing |
| `notReady` | real and planned, not built | placeholder (see the placeholder rule) |
| `notCore` | real, but lives on another surface | nothing here |
| `notApplicable` | the workbook refused it, with a reason | nothing, ever |

### Totals across all 280 cells

| | count | share |
|---|---|---|
| **LIVE** | **91** | 32.5% |
| `notReady` | 129 | 46.1% |
| `notCore` | 21 | 7.5% |
| `notApplicable` | 39 | 13.9% |

⚠️ **84 of the 129 `notReady` are the whole of Skilling** (12 brackets × 7 layers, none
built). Excluding Skilling, the built stages run **91 live of 196 = 46%**.

---

# PART A — Asset register

Exact entry counts, extracted from source.

## A1 · Pregnancy content

| Collection | Count | File |
|---|---|---|
| Weekly content — **weeks 4–40, all 37**, 11 sections each | 37 | `lib/data/weekContent.json` |
| "Can I…?" safety entries | **193** | `can_i_data.dart` |
| Report findings (what-it-means / how-common / what-next / questions) | **27** | `report_findings_data.dart` |
| Tests & scans, full explainers | 9 | `tests_scans_reports_data.dart` |
| Findings / conditions, full explainers | 10 | `tests_scans_reports_data.dart` |
| Scan interpretation guides | 6 | `scan_guide_data.dart` |
| Scan cost ranges (₹) · urgent signs | 9 · 14 | `scan_extras.dart` |
| Symptoms | 17 | `symptom_data.dart` |
| Journey milestones | 36 | `journey_milestones.dart` |
| Reads / articles | **25** | `read_next_data.dart` |
| Week articles | 6 | `week_articles_data.dart` |
| Read-to-baby pieces | 48 | `read_to_baby_data.dart` |
| Spiritual traditions | 7 (1,978 lines) | `spiritual_reading_data.dart` |
| Hospital bag catalogue · seed · why-pack | 35 · 43 · 145 | `hospital_bag_*.dart`, `ready_for_birth_data.dart` |
| Ask Veda showcase · suggestions | 5 · 4 | `veda_showcase.dart`, `veda_suggestions.dart` |

**Garbh Sanskar:** 10 Shravan audio · 8 Vichara stories · 5 Kriya practices · 16 Samvad
prompts (6/5/5 by trimester) · 4 puzzles.

## A2 · Pregnancy commerce, courses, people

| | Count | File |
|---|---|---|
| Products (**with images**) | 24 in 8 categories | `product_data.dart` |
| Masterclasses | 4 | `prepare_data.dart` |
| Cohorts | 4 | `prepare_data.dart` |
| Specialists | 5 | `prepare_data.dart` |
| Yoga sessions | 21 | `prepare_data.dart` |
| Birthing classes | 6 | `prepare_data.dart` |
| Prep programmes · topics | 3 · 15 | `prepare_data.dart` |
| Nutrition plans + option axes | 3 + 12 | `prepare_data.dart` |

## A3 · TTC

| Collection | Count | File |
|---|---|---|
| Daily insights | **24** | `ttc_daily_data.dart` |
| Myths | **16** | `ttc_daily_data.dart` |
| Nutrition entries | 12 | `ttc_daily_data.dart` |
| Movements | 12 | `ttc_daily_data.dart` |
| Journal prompts | 16 | `ttc_daily_data.dart` |
| Chapter content | 5 chapters (563 lines) | `ttc_chapter_data.dart` |
| "Can I…?" | 12 | `ttc_can_i_data.dart` |
| Medical tests | 10 | `ttc_tests_data.dart` |
| Trackers | 8 | `ttc_trackers_data.dart` |
| Milestones | 11 | `ttc_milestones.dart` |
| Partner missions | 12 | `ttc_partner_data.dart` |
| **Paid offerings, priced, named experts** | **13** | `ttc_prepare_data.dart` |
| Products | 8 | `ttc_products_data.dart` |
| Suggested supplements | 7 | `ttc_supplements_store.dart` |

## A4 · Parenting

| Collection | Count | File |
|---|---|---|
| Age phases | **20** | `pp_phases_data.dart` |
| Leaps | 10 | `pp_leaps_data.dart` |
| "What changed?" concerns | **29** | `pp_what_changed_data.dart` |
| Recommendation items · collections | **70** · 10 | `pp_reco_data.dart` |
| Food recipes · nutrition focuses | 28 · 5 | `pp_food_data.dart` |
| Recipes (V1) | 21 | `pp_recipes_data.dart` |
| Nutrition stages | 5 | `pp_nutrition_data.dart` |
| Development areas · activities | 8 · 8 | `pp_development_data.dart` |
| Extra grow activities | **39** | `pp_grow_activities.dart` |
| Milestones · domains | 18 · 6 | `pp_milestones_data.dart` |
| Yoga classes · categories | 27 · 7 | `pp_yoga_data.dart` |
| Nuskhe remedies · categories | 22 · 6 | `pp_nuskhe_data.dart` |
| Vaccines · visits | 12 · 10 | `pp_vaccine_data.dart` |
| Health timeline / meds / reports / prescriptions | 9 / 3 / 2 / 1 | `pp_health_data.dart` |
| Reading articles · collections | **10** · 7 | `pp_reading_data.dart` |
| Articles (V1) | 6 | `pp_articles_data.dart` |
| **Videos · podcasts · collections** | **21 · 5 · 5** | `pp_watch_data.dart` |
| Learning programmes | 15 | `pp_learning_data.dart` |
| Courses (V1) | 4 | `pp_courses_data.dart` |
| Products · categories · guides | 23 · 6 · 18 | `pp_products_data.dart` |
| Compare guides | 6 | `pp_products_data.dart` |
| Deals | 23 | `pp_deals_data.dart` |
| Experts · find-help needs | 6 · 7 | `pp_experts_data.dart` |
| Baby names · collections · vibes | 21 · 8 · 8 | `pp_names_data.dart`, `pp_names_v2_data.dart` |
| Daily tips | 14 | `pp_daily_tips.dart` |
| Journeys | 2 | `pp_journeys_data.dart` |

## A5 · Shared

| | Count |
|---|---|
| Communities (pregnancy / TTC / parenting) | 12 / 12 / 14 |
| Seed posts | 18 / 10 / 22 |
| Brand campaigns · brands | 18 · 7 |
| Launch promos | 4 |

## A6 · Skilling

**Nothing.** 12 brackets declared, 84 cells, zero content, zero tools, zero screens beyond
the design preview.

---

# PART B — The 280 cells

Generated from `lib/data/brackets/*.dart`. This is the reconciliation surface.

Format: `layer  STATE  → surfaces` (live) or `layer  state  workbook reason` (not live).

<!-- BEGIN GENERATED -->
<!-- see APP-INVENTORY-CELLS.md -->
<!-- END GENERATED -->

**The full 280-cell listing is in the companion file `APP-INVENTORY-CELLS.md`** — it is
370 lines and kept separate so this document stays readable. It is the file to
reconcile against.

---

# PART C — What "LIVE" actually opens

Every surface id a live cell can name, and the screen it pushes. **If an id is not in
this table, no bracket may claim it is live** — that is enforced by
`test/bracket_model_test.dart`.

## Pregnancy — `lib/services/surface_router.dart`

| id | screen |
|---|---|
| `tests_scans` | TestsScansReportsScreen |
| `appointments` | ScansAppointmentsScreen |
| `due_date` | DueDateCalculatorScreen |
| `reports` | ReportScreen |
| `can_i` | CanIScreen |
| `symptoms` | SymptomCompanionScreen |
| `movement` | BabyMovementScreen |
| `weight` | WeightTrackerScreen |
| `kegel` | KegelCareScreen |
| `contractions` | ContractionTrackerScreen |
| `hospital_bag` | ReadyForBirthScreen |
| `medication` | MedicineTrackerScreen |
| `product_guide` | ProductGuideHubScreen |
| `garbh_daily` | GarbhScreen |
| `consults` | ConsultationsScreen |
| `cohorts` | CohortsScreen |
| `birthing_classes` | BirthingClassesScreen |
| `nutrition` | NutritionScreen |
| `masterclasses` | MasterclassesScreen |
| `shop` | ProductsScreen |
| `yoga` | YogaHomeScreen |
| `daily_reads` | ReadNextScreen |

## TTC — `lib/screens/ttc/ttc_surface_router.dart`

| id | screen |
|---|---|
| `ttc_cycle` | TtcCycleScreen |
| `ttc_ovulation` | TtcOvulationScreen |
| `ttc_window` | TtcFertilityWindowScreen |
| `ttc_calendar` | TtcCalendarScreen |
| `ttc_chapter` | TtcChapterScreen |
| `ttc_can_i` | TtcCanIScreen |
| `ttc_tests` | TtcTestsScreen |
| `ttc_nutrition` | TtcNutritionScreen |
| `ttc_supplements` | TtcSupplementsScreen |
| `ttc_treatment` | TtcTreatmentScreen |
| `ttc_records` | TtcRecordsScreen |
| `ttc_medication` | TtcMedicationScreen |
| `ttc_appointments` | TtcAppointmentsScreen |
| `ttc_ritual` | TtcRitualScreen |
| `ttc_journal` | TtcJournalScreen |
| `ttc_partner` | TtcPartnerTodayScreen |
| `ttc_prepare` | TtcPrepareScreen |
| `ttc_community` | TtcCommunityScreen |
| `ttc_care_circle` | TtcCareCircleScreen |
| `ttc_products` | TtcProductsScreen |

## Parenting — `lib/screens/post_pregnancy/pp_surface_router.dart`

| id | screen |
|---|---|
| `pp_sleep` | SleepJourneyScreen |
| `pp_feeding` | FeedingJourneyScreen |
| `pp_food` | FoodHomeScreen |
| `pp_growth` | GrowthJourneyScreen |
| `pp_vaccines` | VaxTrackerScreen |
| `pp_what_changed` | WhatChangedScreen |
| `pp_health` | WhatChangedScreen |
| `pp_development` | DevelopmentHomeScreen |
| `pp_milestones` | MilestoneJourneyScreen |
| `pp_activities` | DevelopmentHomeScreen |
| `pp_read` | ReadingHomeScreen |
| `pp_watch` | WatchHomeScreen |
| `pp_courses` | LearningHomeScreen |
| `pp_products` | ProductsDiscoveryScreen |
| `pp_product_guide` | ProductGuideHubScreen |
| `pp_recos` | ProductsDiscoveryScreen |
| `pp_experts` | ProviderResultsScreen |
| `pp_find_help` | ProblemSolverScreen |
| `pp_yoga` | YogaHomeScreen |
| `pp_nuskhe` | NuskheScreen |
| `pp_names` | BabyNamingHomeScreen |

**Skilling has no router.** Nothing to open.

---

# PART D — Screens, tools and stores

## D1 · Pregnancy tools — 16 screens

`baby_movement` (kick counter) · `contraction_tracker` · `due_date_calculator` ·
`garbh_games` · `hospital_bag` + `hospital_bag_v2` · `kegel_care` · `medicine_tracker` ·
`product_checklist` · `ready_for_birth` · `scans_appointments` · `spiritual_reading` ·
`symptom_companion` · `tests_scans_reports` · `weight_tracker` · `ask_veda`

## D2 · Pregnancy screens — 43

`home_screen` · `home_screen_b` · `home_focus_screen` · `home_v3_screen` ·
`today_home_screen` · `week_flow_screen` · `weekly_card_stack_screen` ·
`week5_full_flow_screen` · `week6_preview_screen` · `calendar_screen` ·
`journey_map_screen` · `journey_booklet_screen` · `garbh_screen` · `community_screen` ·
`community_profile_screen` · `can_i_screen` · `report_screen` · `read_next_screen` ·
`read_reader_screen` · `book_companion_screen` · `watch_learn_screen` · `products_screen` ·
`cart_screen` · `journal_screen` · `journal_writer_screen` · `bump_book_screen` ·
`bump_journey_screen` · `dear_baby_vault_screen` · `my_baby_screen` · `profile_screen` ·
`pregnancy_profile_screen` · `profile_analytics_screen` · `saved_hub_screen` ·
`reminders_screen` · `tools_hub_screen` · `tools_screen` · `home_detail_screens` ·
`global_search` · `main_scaffold` · `splash_screen` · `father_home_screen` ·
`brand_showcase_screen` · `photo_viewer_screen`

## D3 · TTC — 34 screens

Today · chapter · cycle (cycle/ovulation/fertile-window) · calendar · tracker · tests ·
nutrition · supplements · medication · records · attachments · appointments · ritual ·
journal · insight · timeline · journey map · partner · care circle · community · products ·
prepare · profile · can-I · treatment · transition · Ask Veda · V3 home · version toggle ·
surface router · common · strings · today parts · tools

## D4 · Parenting — 194 files

Grouped: **Home & child** (my_child, pp_home_v3, phase_map, phase_detail, snapshot,
child_profile, multichild, leap_calendar, leap_definition, wonder_week) ·
**Journeys & trackers** (sleep, feeding, growth, milestone, vax_tracker, vax_timeline,
feeding_tracker, sleep_tracker) · **Health** (health_home, records, timeline, growth,
doctor_visit, emergency, guide, prescription, wallet ×3) ·
**Development** (development_home, area, activity, checkin, map, dev_stage, grow ×3) ·
**Food** (food_home, category, recipe, mealplan, builder, shopping, saved, nutrition,
recipes ×3, sick_days) · **Learn** (reading_home, collection, library, reader,
article_reader, article_archive, read_explore, learning_home, learning_detail, courses ×4,
masterclasses ×2, cohort ×2, book_detail) · **Watch** (home, category, channel,
collection, library, player, quicklearn, shorts) · **Commerce** (products_discovery,
category, subcategory, detail, compare, reco ×6, deals, investments) ·
**People** (community ×5, experts, provider ×3, problem_solver, find_help, care_circle) ·
**Names** (naming_home, finder, list, detail, matches, swipe, journey ×3, astro) ·
**Other** (nuskhe, remedy ×2, astrology, journal, journeys, yoga ×3, baby_documents,
family_profile, family_intelligence_onboarding, explore_drawer, tools_hub, my_bookings)

## D5 · Stores — 104 `ChangeNotifier` singletons

AppNav · BabyDocumentsStore · BabyVoiceService · BirthClubStore · BookCompanionStore ·
BookingStore · BoughtStore · BrandStudio · BrandStudioStore · BumpStore · CalendarStore ·
CanIStore · CareConfig · CarePartnerStore · CarePresenceStore · CartStore ·
ChildProfileStore · CommunityStore · CreditsStore · CycleStore · DailyStore ·
DailyTipStore · DevStore · DoctorAvailability · DoctorOnboardingStore · DoctorRoster ·
DoctorScheduleStore · DoctorSession · EntitlementStore · ExpertFollowStore · FabState ·
FamilyProfileStore · FamilyTimeline · FatherContentController · FatherJournalStore ·
FatherPreview · FeedingStore · FoodStore · GarbhStore · GrowStore · GrowVersionStore ·
GrowthStore · HealthStore · HomeContentController · HospitalBagStore ·
HospitalBagV2Store · JournalStore · JourneyDatesStore · JourneyStore · LandingFocus ·
LifeStageStore · MedicineStore · MemoriesStore · MemoryStore · MilestoneStore ·
NameMatchStore · NameVersionStore · NarrationService · PartnerDashboardStore ·
PpCompareStore · PpHomeVersionStore · PpTrackerStore · PregnancyController ·
PrepareStore · PrescriptionStore · ProductChecklistStore · ProductGuideVotes ·
ProductStore · ProfileAnalytics · ReadDoneStore · ReadNextStore · ReadReaderPrefs ·
ReadToBabySavedStore · ReadToBabyStore · ReadingStore · ReadyBirthContextStore ·
RecoStore · ReferralStore · ReminderStore · ScansStore · SleepStore ·
SpiritualPrefsStore · SponsorAdminStore · SymptomStore · TodayVersionStore · ToolsStore ·
TtcAppointmentsStore · TtcHomeVersionStore · TtcJournalStore · TtcLang · TtcLogStore ·
TtcPartnerMode · TtcReadStore · TtcRecordsStore · TtcRitualStore · TtcStore ·
TtcSupplementsStore · TtcTreatmentStore · V2BlockArtMode · V2PaletteStore · VaxStore ·
VideoStore · WalletVersionStore · WatchStore · YogaStore

## D6 · Infrastructure already built

Supabase repo layer · local-first sync (`CloudSyncedStore`) · notifications ·
booking engine (entitlement → slots) · Brand Studio (4 archetypes, campaigns, disclosure) ·
doctor app flavour · enterprise/sponsor capability engine · referral engine ·
personalisation (`FamilyProfileStore`) · narration (hi-IN TTS) · Ask Veda transport
(service in a separate repo) · the bracket model + resolver + three surface routers.

---

# PART E — Known gaps, stated plainly

The "new" column. Everything here is **absent**, not partial.

## E1 · Content

| Gap | Detail |
|---|---|
| **Short reads** | 25 pregnancy + 10 parenting. Each hub wants 3–5 |
| **Video media** | 26 curated entries (21 videos, 5 podcasts) with full metadata; media to be published into the existing player. Slots to be built into every hub so it is a data change |
| **Skilling, entirely** | 84 cells, no content |
| Mental health content (pregnancy) | scattered in weekly JSON, no owned file |
| Belly & skin content | products exist, content essentially does not |
| Myths (pregnancy) | TTC has 16; pregnancy has none as a set |

## E2 · Tools named in the review, not built

**Pregnancy:** BP/sugar log · meal planner · mood check · birth-plan builder
**TTC:** PCOS symptom checker · "should I see a specialist?" checklist · pre-pregnancy
checklist · BMI
**Parenting:** wake-window calculator · sleep-plan generator · behaviour script library ·
development screener
**Skilling:** all of it — rubric trackers, record-and-review, drills, portfolio

## E3 · Commerce & supply

| Gap | Detail |
|---|---|
| Parenting product images | no image field on `PpProduct` |
| Consult supply (pregnancy) | 5 specialists, mock slots |
| Consult supply (parenting) | 6 experts, mock slots |
| Nutrition supplement SKUs | asked for by the workbook, not seeded |
| Garbh Sanskar hero course | recorded media not produced |

## E4 · Structural

| Gap | Detail |
|---|---|
| **Problem hubs** | 39 of 40 brackets still open the generic layer-ordered screen. Scans & tests is the only one built to the new model |
| **Content tagging** | no problem / sub-problem / intent / format tags on any asset — the blocker on hubs auto-populating |
| Placeholder component | does not exist yet |
| Skilling routing | no surface list, no router |

---

## Reconciliation checklist

1. Read **`APP-INVENTORY-CELLS.md`** — all 280 cells.
2. `LIVE` → **existing**. Cross-reference Part C for the screen; map it into the hub's
   new order. Do not rebuild.
3. `notReady` → **new**. Everything here needs building or content; the reason string is
   the workbook's own wording of what it should be.
4. `notCore` → **existing elsewhere**. Do not build, do not placeholder — link if useful.
5. `notApplicable` → **refused**. Not new work, not a gap. Never render.
6. Anything in Part E that has no matching cell is genuinely new scope.

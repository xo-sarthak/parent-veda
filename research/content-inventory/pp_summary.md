# Parenting stage - content-needs inventory (2026-09-06)

Scope: `lib/screens/post_pregnancy/**` (226 files, ~125k lines) plus parenting hubs/brackets/journeys in `lib/data/`. Counts come from parsing the Dart source.

## Totals

- **pp_images.csv**: 565 rows, 959 slots - video 324, illustration 298, infographic 81, product-image 70, avatar 54, photo 43, icon-art 32, video-thumbnail 29, food-image 28. State: 845 drawn placeholders, 97 not rendered, 15 Unsplash (Journal V2 demo + V3 read covers), 1 blank, **1 real asset** (pv-mark.png). No real video or audio file exists; one dev MP4 stands in for every Watch video.
- **pp_written.csv**: 1,022 rows, 1,692 items, ~257k words present - 1,001 placeholder, 20 coming-soon, **1 real**. The ten door sections alone: 514 pages, ~189k words, 165 REQUIRED_REVIEW markers.
- **pp_other.csv**: 528 rows, 717 units - 128 audio files, 98 recommendation entries, 61 coming-soon markers, 54 expert profiles, 49 consult CTAs, 48 activities, 39 data sources, 23 deals.

## Ten biggest asks

1. **324 videos**: 132 section explainers, 26 Watch videos/podcasts, 47 activity demos, 34 dev-stage clips, 20 phase explainers, 17 course lessons, 13 recorded yoga classes, 28 recipe cook-alongs (slot sits on a retired screen), 6 remedy demos.
2. **Clinical sign-off** on the door sections (You Maa 50 markers, Health 50, Traditions 25, First 40 23, Feeding 17), vaccines, What Changed, the four checkers, sleep/feeding charts.
3. **128 audio files**: 58 narrated stories, 25 sleep audio slots, 24 sound-player tracks, 21 name pronunciations.
4. **54 real experts** (12 explicitly seeded) with photos, credentials, fees; remove invented testimonials and registration numbers.
5. **Photography**: 86 area covers (9:16), 23 products (hero + gallery), 28 recipes, 22 remedies, 70 recommendations, 23 deals.
6. **Reads**: 10 articles are ~250-word stubs with fictional bylines; 17 course lessons have no body.
7. **Development past 12 months**: 18 milestones and 4 brain topics cover only year one.
8. **Catalogue depth**: 21 names (18 without stories), 26 videos, 14 daily tips, 16 FAQs.
9. **Paid supply**: 15 courses/masterclasses, 27 yoga classes, 31 consult profiles - all seeded, payment stubbed.
10. **Source citations**: vaccine schedule, growth reference (0-12 months only), milestone ranges, chart numbers.

## Version ambiguities

- Home: `MyChildScreen(home:true)` ships; the V3 grid is session-only, and the ten door sections are reachable only through V3 or surface ids.
- Health defaults to **V2** Health Wallet; Brain defaults to V1; Baby Naming to V2 (V1 toggle commented out, so V1 = old (retired)).
- Read, Recommendations, Courses: new Explore screens coexist with still-reachable old ones (`both/shared`). FoodHome, old vaccination, old trackers, old home: retired.
- Guided journeys only via Brand Studio; the 7 hub JourneyConfigs never fire.
- `DailyTipPopup` has no call site; `JournalScreen` (V1) and `pp_faq_data` wiring unconfirmed (`unsure`).

Out of scope, noted only: Memories, Product Guide, Brand Studio, Skilling preview.

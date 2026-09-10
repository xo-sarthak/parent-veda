# Parenting content-needs inventory — shared spec for every part-writer

READ-ONLY on the repo: never edit anything under lib/ or test/. Write ONLY your three part files
into: C:/Users/sarth/AppData/Local/Temp/claude/C--Projects-parentveda/939c16b8-39bc-4e2a-91d1-9315784b7c5b/scratchpad/inventory/parts/
named <GROUP>_images.csv, <GROUP>_written.csv, <GROUP>_other.csv (GROUP given in your task).
Generate the CSVs with a Python script using the csv module (UTF-8, header row, proper quoting). Put the script in the parts/ folder too (fine to keep).

PURPOSE: the founder will commission real images, videos, written content and other assets from their team.
They need to know EXACTLY how many of each thing are needed, for what purpose, where it appears (tap path),
what size/shape, what child age it targets, and which are already real. Most content today is AI placeholder.
COUNT with grep/python, do not estimate. Where a list is long (>150 items) list by group with counts and 3 example
titles; otherwise list every item as its own row (one row per item is preferred for anything commissionable:
each article/read, each video, each recipe, each product, each activity, each name story, each remedy...). It is
fine for a part file to have hundreds of rows.

## Columns (exact header, exact order)
images:  stage,area,tap_path,item,kind,count,size_or_aspect,placeholder_now,version,source_file,notes
  kind ∈ photo | illustration | icon-art | carousel-card | infographic | video-thumbnail | video | product-image | avatar | food-image | activity-image
  size_or_aspect: from code (e.g. "16:9", "120x120 px", "full-width 180 px tall"); "unknown" if unconstrained.
  placeholder_now ∈ unsplash-url | drawn-placeholder | blank | real-asset | none-rendered
    drawn-placeholder = a painted/coloured block, icon, PvVideoPlaceholder, PvReadPlaceholder, PpProductImage cover block, diagonal stripes, emoji tile, gradient hero etc.
    none-rendered = the data model has an image/thumbnail field but nothing draws it, or the slot exists only in a comment/spec.
  Include VIDEOS as rows (kind=video): count, duration, quick/deep mode, channel/shorts, whether a real MP4/HLS URL exists.
written: stage,area,tap_path,content_type,title_or_id,purpose,audience_age,current_words,count,status,version,source_file,notes
  content_type e.g. article | read | lesson | tip | faq | leap-definition | milestone | vaccine-learn-why | vaccine-after-care | concern | recipe | activity | script | name-story | remedy | section-page | hero-copy | product-why | expert-bio | course-description | sound/lullaby lyric etc.
  audience_age e.g. "0–3 months", "leap 5", "1–2 years", "all parenting", "mother (postpartum)".
  current_words approximate (python word count of the body strings), count = how many items this row represents.
  status ∈ placeholder | real | coming-soon.   "real" ONLY if there is evidence it was written/checked by a human (a REVIEWED marker, a source citation, a named author) — otherwise placeholder. Mark REQUIRED_REVIEW / clinical-review markers in notes.
other:   stage,area,tap_path,placeholder_type,item,count,what_is_needed_from_us,current_state,version,source_file
  placeholder_type e.g. activity | audio/rhyme/lullaby | expert profile | paid offering (course/masterclass/consult/yoga) | product/recommendation entry | brand/sponsor | deal | community room | community post/seed | reminder/notification template | data source (vaccine schedule, growth charts) | coming-soon feature | tracker/tool | external link | legal/disclaimer | etc.

stage is always "parenting".
area = the feature area (e.g. "Watch", "Health > Vaccination", "Door: Sleep").

## tap_path conventions (write them so a non-engineer can follow them on the phone)
Root = "Parenting home (My Child tab)". The parenting app has a bottom nav: My Child | Brain | Tools | Community | Products.
The hamburger opens the Explore drawer with rows: Personalize, Watch, Health, Recipes, Recommendations, Read, Courses & Masterclasses,
Yoga & Classes, My Bookings, Invite a friend, Your Care Circle, Memories, Find help, Dadi/Nani Nuskhe, Investments & Savings,
Astrology & Numerology, My Journal V2, Launches, Brand Studio, Skilling (preview), Due date, Track ovulation.
The home also has a session-only "Current | V3" pill: V3 = bracket-grid home (pp_home_v3.dart) whose doors are defined in
lib/data/hubs/parenting_hubs.dart + lib/data/brackets/parenting_brackets.dart and resolve through pp_surface_router.dart
(surface ids like pp_watch, pp_section/parenting_sleep, pp_section/parenting_sleep/<areaId>).
Examples: "My Child tab > Explore drawer > Watch > Today's video"; "V3 home > Sleep door > area 'Newborn sleep' > read #3";
"Tools tab > Vaccination > vaccine detail > Learn why". If you are unsure of the exact path, give the best path and say "(path unsure)".

## version conventions
version ∈ old | new | both/shared | unsure | old (retired)
- Known V1/V2 pairs in parenting: Baby Naming V1 (Finder) vs V2 (Naming Journey, default); RecipesScreen/FoodHomeScreen (Food Companion is retired, RecipesScreen is the unified live one, RecipesExploreScreen is the newest redesign); HealthGuideScreen (old) vs Health ecosystem (HealthHomeScreen; WalletHomeScreen has V1/V2/V3 wrapper); VaccinationScreen (old) vs VaxTracker (new); old Growth/Feeding/Sleep tools vs the four Journey tools (Growth/Feeding/Sleep/Milestone Journey); MyChildScreen(home:true) = "Current" home vs PpHomeV3 = V3; GrowHomeScreen has V1/V2/V3 (Brain); old ReadingHomeScreen vs ReadExploreScreen; RecommendationsScreen vs RecoExploreScreen; LearningHomeScreen vs CoursesExploreScreen; the ten "door" sections (pp_*_content.dart) are NEW rebuilds; JournalScreen (old) vs journal_v2 (new).
- Anything commented out / "kept for revert" and no longer reachable = "old (retired)". Say "unsure" rather than guessing.
- Reachability: grep the call site (Explore drawer, bottom nav, surface router, hubs). Note in notes if a screen is unreachable.

## What to capture
IMAGES: every hero image, illustration slot, carousel card, door tile art, thumbnail, product image, avatar, food image, activity image,
infographic/chart, video (with duration + mode), and note which are already real assets (assets/ files, real URLs) vs drawn placeholders.
Look for: PvVideoPlaceholder, PvReadPlaceholder, PpProductImage, _StripePainter/diagonal stripes, Image.network, Image.asset, imageUrl/thumbnail/cover fields,
emoji or Icon used as stand-in art, gradient hero blocks, "PHOTO SOON"/"coming soon" marks, unsplash.
WRITTEN: every article/read/lesson/tip/faq/definition/copy block that a content team would write, with approximate word counts and age target;
count sub-items (e.g. "12 reads in area X"). Note REQUIRED_REVIEW / clinical review markers.
OTHER: activities, audio (lullabies, white noise, rhymes), expert profiles, paid offerings, products/recos, brands/sponsors, deals, community rooms & seed posts,
reminder templates, data sources (vaccine schedule, WHO growth charts), coming-soon markers, external links (Amazon/FirstCry), trackers.

Finish by replying with: your row counts per file, the 3–5 biggest asks in your area, and any version ambiguities you could not resolve.

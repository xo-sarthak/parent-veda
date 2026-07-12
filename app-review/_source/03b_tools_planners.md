## Screen: My Hospital Bag - V1 (`tools/hospital_bag_screen.dart`)

**Status:** Live (this is the default, wired-in Hospital Bag). `HospitalBagScreen` is the real entry point registered in the Tools tab. It hosts a small floating "Classic | New" switcher: "Classic" shows this V1 experience, "New" shows the V2 redesign. The chosen version is saved in `SharedPreferences` under key `hb_use_v2` and defaults to `false`, so a first-time tester lands on V1. Both versions are wired and reachable; V2 is opt-in behind the toggle (see the next screen). Within V1, the older three-tab UI (Bag / Planner / Shopping) is commented out under an `OLD_BAG_UI_DISABLED` block and replaced by the simpler "My Bag" flow described here.

**Reached from:** Tools tab -> "Hospital Bag" tile. Also opened by Ask Veda when a query resolves to the hospital-bag tool.

**Purpose:** A warm, personalised preparation experience (not a rigid checklist) for the third trimester. A short onboarding builds a smart default bag; the mother then decides where to get each item and packs it over time.

**Sections & UI:**
- **Version pill (overlay):** A pill floating at the bottom center with two segments, "Classic" and "New", present in both versions. Tapping switches the whole screen between V1 and V2.
- **Onboarding (first open only):** Step 0 is a welcome page (backpack graphic, title, subtext, "Start building" button). Step 1 asks delivery type via three radio tiles: Unsure, Vaginal birth, C-section. "Build my bag" generates the starter bag (`generateDefaultBag`) tailored to the delivery type.
- **My Bag home (`_MyBagScreen`):** App bar titled "My bag" with a share icon and an overflow menu ("Remind me" / "Reminder off"). A hero card shows a hand-painted filling-bag graphic, a "filling up" or "ready" message, percent packed, days to due date, and a progress bar (packed / total). An "Add items" button sits below.
- **Item groups:** Items are grouped by where she will get them: "Buy from ParentVeda" (`buyVeda`), "Buy elsewhere" (`buyElse`), "Already have" (`have`), and "Still deciding" (`needed`). Each group shows an icon, label, and count.
- **Item card:** Emoji, item name, an expand affordance, and action pills. For "buy elsewhere" items the chosen store (and a link glyph) shows under the name.
- **Empty state:** A backpack graphic with encouraging copy when the bag has no items.

**Features & interactions:**
- **Choose a source (per item):** Tapping a card opens a bottom sheet: "Buy from ParentVeda", "Buy elsewhere", "I already have this", or "Remove". "Buy elsewhere" opens a second sheet with store chips (Amazon, Flipkart, FirstCry, Other) and an optional link field.
- **Buy pill:** For sellable ParentVeda items not yet purchased, a coral "Buy" pill shows the price and opens a mock single-item Buy Now checkout (`showSingleBuyNow`). This is a simulated checkout, not a real payment.
- **To buy / Bought toggle:** Marks a buyable item as purchased.
- **Pack / Packed toggle:** One tap marks an item packed, fires a light haptic and a rotating cheer snackbar.
- **All packed celebration:** When every item is packed, a full-screen keepsake screen ("Baby's bag is ready") appears with a share button and a dated message.
- **Add items screen:** A search field, a "Mums also packed" suggestion strip (from `suggestedEssentials`), and expandable category sections (Labour, After delivery, Baby, Partner, Documents, Comfort). Tapping a row adds or removes it from the bag with a selection haptic.
- **Reminder:** The overflow "Remind me" creates a daily 6:00 PM reminder (id `bag_prep`) via `ReminderStore`; selecting it again removes it.
- **Share:** Builds a plain-text summary of what is still to buy plus a packed count and opens the OS share sheet.

**Data:** `HospitalBagStore` (V1 store, local + cloud-synced). Item model `BagItem` with `BagItemStatus` (needed, have, buyVeda, buyElse, skip) plus `packed`, `purchased`, `selectedProductId`, `store`, `link`, `price`, `isCustom`, `notes`. `DeliveryType` (unsure, vaginal, csection). Starter items from `data/hospital_bag_seed.dart` (`generateDefaultBag`); catalogue, products, and helpers (`bagBestProduct`, `bagIsSellable`, `bagCatalogByCategory`, `suggestedEssentials`) from `data/hospital_bag_catalog.dart`. Purchases mirror `BoughtStore`. Version flag in `SharedPreferences` (`hb_use_v2`).

## Screen: My Hospital Bag - V2 redesign (`tools/hospital_bag_v2_screen.dart`)

**Status:** Live but opt-in. `HospitalBagV2Screen` renders only when the "Classic | New" pill is set to "New" (flag `hb_use_v2 = true`). It uses its own separate store and persistence keys, so V1 and V2 hold independent data and can be compared side by side. It is not the default and not commented out.

**Reached from:** Tools tab -> "Hospital Bag" -> tap the "New" segment of the floating version pill.

**Purpose:** A from-scratch, calmer redesign where the mother never sees internal "states". Every item moves along one plain-language journey: "Needs your decision" -> "Planning to buy" -> "Ready at home" -> "Packed", plus a gentle "Maybe later" set. Commerce stays hidden until she asks for help choosing.

**Sections & UI:**
- **Onboarding (first open only):** A single gentle screen with a luggage graphic, title, subtext, one delivery-type question (chips: Vaginal, C-section, Unsure), and a "Start" button that generates the smart bag.
- **Home:** App bar with a summary (receipt) icon and a share icon. A hero card shows a "building" or "ready" headline, days to go, and two animated progress bars: "Shopping" (how much is acquired) and "Packing" (how much is packed). A packing nudge card appears once shopping progress passes 75 percent and not everything is packed.
- **Needs your attention:** A short list (up to 6) of items not yet packed, ordered decision-first. Ready-at-home items show a one-tap pack toggle; others show a chevron.
- **Categories:** Tiles for Labour, After delivery, Baby, Partner, Documents, Comfort, Custom, each with a packed / total count.
- **Category screen:** "Add my own" button, item rows showing name, current journey stage (icon + label), any selected product, and any chosen store. A collapsible "Maybe later" section at the bottom lets her restore skipped items.
- **Product Experience screen:** The only commerce path. Opens when she taps "Help me choose one". Shows a ParentVeda "pick" hero card (badge, price, choose / buy actions), a "why we recommend" list, an optional "things to consider" list, a buying guide, a reviews block, and a compare list of alternatives (ParentVeda or affiliate).
- **Shopping summary:** Totals for ParentVeda spend, external spend, and combined total, then sections: From ParentVeda, Buy elsewhere, Waiting to buy, Ready at home, Packed.

**Features & interactions:**
- **Item action sheet (always five options):** "Help me choose one" (opens the Product Experience), "I have one at home", "Buy elsewhere" (store chips or "Skip for now"), "Maybe later" (moves to the gentle later set), "I do not need this", plus "Remove" for custom items only.
- **Pack toggle:** One satisfying tap flips Ready-at-home to Packed and back, no dialog.
- **Mark bought:** For a "buy elsewhere" item, a single "Mark bought" button advances it to Ready-at-home.
- **Add my own:** A sheet to add a custom item (name + optional notes) to a category.
- **Choose / Buy on ParentVeda:** Selecting a product records the choice; "Buy on ParentVeda" opens the same mock Buy Now checkout. Affiliate alternatives record a "buy elsewhere" store and link instead.
- **Auto-advance:** When a chosen ParentVeda product is later marked bought (via `BoughtStore`), the item auto-advances to Ready-at-home.
- **Share:** Text summary grouping items to buy, items to pack, and any missing documents.

**Data:** `HospitalBagV2Store` (separate keys `hb2v2_items` / `hb2v2_meta`, cloud key `hb2`, cloud-synced). Reuses V1's `BagItem` model; the journey stage is computed by `bagStageOf` (`BagStage`: needsDecision, planningToBuy, readyAtHome, packed, maybeLater). Products via `bagProductsFor` / `BagProduct`; store list `kBagStores`. Buying guide and reviews blocks are tastefully placeholdered (no real data yet, "coming soon" copy).

## Screen: Product Checklist (`tools/product_checklist_screen.dart`)

**Status:** Live. Note a naming mismatch to flag for the reviewer: the current live implementation is a two-state "got / not got" checklist builder, not a three-state "approved / rejected / partial" review workflow. The approved/rejected/partial concept exists in project planning notes as a parked revamp and is not what this screen currently does.

**Reached from:** Tools tab -> "Product Checklist" tile. The helper `showAddToChecklistSheet` is also invoked from product detail pages to add a single product into a list.

**Purpose:** Lets the mother turn ParentVeda's product catalogue into her own named checklists, tag each item with a custom "when / for" note, and tick items off as she gets them. Curated starter lists give a head start.

**Sections & UI:**
- **Home:** Intro text; a "Your lists" header with a "+ New" button; existing checklist cards; then a "Curated starters" section with three ready-made lists.
- **Checklist card:** List icon, name, a "N items, M got" summary, a progress bar, and an overflow menu (Delete). Swipe left also deletes (with confirm).
- **Curated starters:** Three cards (Newborn essentials, Bump comfort, Skin & body). Tapping one opens a preview sheet listing its products with notes and an "Adopt" button that copies it into an editable list.
- **Checklist detail:** A progress bar with "got of total", an "Add products" button, and the item rows. A sticky bottom bar offers "Save list" and "Add remaining to cart". Overflow menu offers Rename and Delete.
- **Item row:** A checkbox (or a locked green check if the product was bought through the app's checkout), emoji, name (struck through when owned), a tag (Bought / Affiliate / Custom), an editable "when / for" note with a clock icon, price, and an overflow menu.
- **Add products screen:** Search field, an "Add your own" button, and the catalogue browsed by category. Each product row has an Add / Added toggle. A bottom bar offers "Save list" and "Add to cart".

**Features & interactions:**
- **Create / rename / delete lists;** delete asks for confirmation.
- **Add / remove catalogue products;** tapping a product row in the picker toggles membership.
- **Add your own product:** A sheet capturing name, link, price, and note for products not in the catalogue.
- **Tick off with prompt:** Ticking a not-yet-got item first asks "Already got this?" (Yes marks it owned with no cart action). Un-ticking simply clears it.
- **Edit the "when / for" note** inline per item.
- **Cart actions:** "Add remaining to cart" and per-item "Add to cart" / "Buy now" add only catalogue, non-affiliate, un-got, not-already-bought items to the shared products cart. Affiliate items offer "Open on Amazon"; custom items with a link offer "Open link". Checkout is the app's mock flow.
- **Tap an item** to open its product detail (catalogue) or its external link (custom).

**Data:** `ProductChecklistStore` (local, cloud key `product_checklists`, cloud-synced). Models `ProductChecklist` and `ChecklistItem` (catalogue items resolve via `productById`; custom items carry their own name/link/price). Curated starters are `kCuratedChecklists` built from real product ids. Cart via `CartStore` (`kProductsCartId`); ownership via `BoughtStore`.

## Screen: Reminders (`reminders_screen.dart`)

**Status:** Live and fully wired to the OS notification layer. Important platform nuance for testers: the Dart layer (`NotificationService`, backed by `flutter_local_notifications` plus timezone) is fully implemented for both Android and iOS, and `ReminderStore` schedules / cancels notifications on every change. Android is fully configured at the platform level (`AndroidManifest.xml` declares `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, and `USE_EXACT_ALARM`). iOS platform config is still incomplete: `AppDelegate.swift` is the default Flutter delegate with no `UNUserNotificationCenter` delegate and `Info.plist` has no notification or background-mode keys, so notifications may not fire reliably on iOS yet. The in-code header comments ("wired once flutter_local_notifications is installed") are stale; the plugin is installed and used.

**Reached from:** Tools tab -> "Reminders" tile. The hospital-bag "Remind me" action and other features create reminders through the same store.

**Purpose:** The mother creates gentle local nudges (Kegel session, prenatal vitamin, read to baby, water, or anything custom) at a time and repeat cadence she chooses; each becomes a scheduled OS notification.

**Sections & UI:**
- **App bar test buttons:** "Send a test notification now" and "Schedule a test for about 1 minute from now" (both request permission first and show a confirmation snackbar). These are diagnostics for verifying notifications on a device.
- **Info banner:** A short "what this does" note.
- **Reminder cards:** Each shows a category icon, title, a human-readable "how often plus when" summary, and an enable / disable switch. Tapping a card opens the editor.
- **Empty state:** A bell graphic with guidance when no reminders exist.
- **Quick ideas:** One-tap preset chips: Kegel (9:00), Vitamin (9:00), Read to baby (20:00), Water (12:00), Calm (7:30).
- **Add button:** A floating "Add" button opens the create editor.

**Features & interactions:**
- **Simple editor** (bottom sheet): Title field, time picker, repeat chips (Once / Daily / Weekly). Weekly reveals a weekday chooser. Save asks for notification permission on commit; editing an existing reminder also offers Delete.
- **Medication editor** (richer, used when a card is a medication reminder): A frequency dropdown (Once, Twice, Thrice a day, Weekly, Fortnightly, Monthly, Custom days), one time picker per daily occurrence, a weekday chooser (weekly / fortnightly), a multi-weekday chooser (custom), a day-of-month dropdown (monthly), and an optional note.
- **Toggle** enables or disables a reminder, which schedules or cancels its notification.
- **Preset chips** open the editor pre-filled with the preset's title, category, and time.

**Data:** `ReminderStore` (local via `SharedPreferences`, cloud-synced to a `reminders` table). Model `Reminder` with `ReminderRepeat` (once, daily, weekly, fortnightly, monthly, customDays), multi-time support (`times`), `dayOfMonth`, `weekdays`, `category`, and `enabled`. Scheduling handled by `NotificationService` (exact-alarm scheduling, per-occurrence ids, monthly / weekday matching).

## Screen: Can I? (`can_i_screen.dart`)

**Status:** Live.

**Reached from:** Tools tab -> "Can I?" tile.

**Purpose:** A fast, calm safety lookup that settles everyday "is this okay during pregnancy?" worries. One question resolves to one clear verdict with a short answer, the reasoning, trimester notes, Indian context, and related questions. Educational general guidance, never a diagnosis.

**Sections & UI:**
- **Home:** Title, subtitle, a tappable search bar (opens a search delegate over the entry library), a "Popular" chip row, and a "Browse" 2-by-2 grid by category (Eat, Drink, Take, Do) with per-category counts. A bookmark icon in the app bar opens saved questions. A disclaimer sits at the bottom.
- **Category screen:** An alphabetical list of entry rows (verdict-coloured icon, name, verdict label).
- **Answer screen:** A large verdict hero card colour-coded by verdict (Safe green, In moderation amber, Depends orange, Best avoided red, Ask your doctor purple) with the short answer; a "Why?" section; "Trimester notes" (first / second / third, with the mother's current trimester highlighted by a "Now" badge); an "Indian context" card; "Related questions" rows; an "Ask Veda" handoff card; a bookmark toggle; and a disclaimer.
- **Saved screen:** The mother's bookmarked questions, or an empty state.

**Features & interactions:**
- **Search** filters the entry library (`canISearch`) and opens the matched answer.
- **Popular chips and category tiles** jump straight to an answer or a category list.
- **Bookmark toggle** saves or unsaves an entry (persisted).
- **Related question rows** navigate to other answers.
- **Ask Veda handoff** opens `AskVedaScreen` pre-filled with the current question, so the offline engine answers it immediately.

**Data:** `data/can_i_data.dart` holds a large curated library (on the order of 190 `CanIEntry` records). Model `CanIEntry` (`CanIVerdict`: safe, moderation, depends, avoid, askDoctor; `CanICategory`: eat, drink, take, doActivity; short, why, optional t1/t2/t3, optional Indian context, related ids, aliases). Saved ids persist via `CanIStore`. Content is English-first (`LocalizedText`, Hindi mirrors English today).

## Screen: Understanding Your Report (`report_screen.dart`)

**Status:** Live.

**Reached from:** Tools tab -> "Understanding Your Report" tile.

**Purpose:** A calm, reassurance-first library that helps a worried mother understand a scan or test finding. It answers "what does this mean?" first, follows the same fixed sections for every finding, and never gives a verdict, diagnosis, or prediction.

**Sections & UI:**
- **Home:** Title, subtitle, a tappable search bar, a "Popular" topics list, and an "All topics" list sorted alphabetically. Each row shows a document icon, the finding name, and an optional medical alternate name.
- **Article screen (seven fixed sections):**
  - What does this mean (always first).
  - How common is it.
  - What usually happens next (rendered in an emphasised teal card, the most important section).
  - When is it usually discussed (a week-range chip, shown only if present).
  - Questions to ask your doctor (a list, if present).
  - Things to remember (a green-check list, if present).
  - A fixed ParentVeda reassurance card (identical for every article).
  - An "Ask Veda" handoff card below the sections.

**Features & interactions:**
- **Search** filters findings (`reportSearch`) and opens the matched article.
- **Popular and all-topic rows** open an article.
- **Ask Veda handoff** opens `AskVedaScreen` pre-filled with the finding name.
- There is no saving, no verdict, and no user input; it is a read-only explainer.

**Data:** `data/report_findings_data.dart` holds the curated findings (27 `ReportFinding` records) plus a popular subset; scan explainer content in `data/scan_guide_data.dart`. Model `ReportFinding` (name, optional altName, whatItMeans, howCommon, whatNext, optional weekFrom/weekTo, questions, remember, aliases). The reassurance message is a fixed app string, not per-finding. English-first (`LocalizedText`).

## Screen: Ask Veda (`tools/ask_veda_screen.dart`)

**Status:** Live. It is a fully offline answer experience (no live LLM, no network). Voice playback and expert booking / calling are placeholders that show a "coming soon" snackbar. This file is the pregnancy-side Ask Veda; a separate parenting-side Ask Veda exists under `screens/post_pregnancy/` and is out of scope here.

**Reached from:** Tools tab -> "Ask Veda" tile; the "Ask Veda" handoff cards on Can I? and Understanding Your Report answers (which pass the question as `initialQuery` and auto-run it); the Garbh Sanskar screen; and global search. In the pregnancy app it is not a persistent floating button (the persistent Ask Veda floating button is a parenting-side feature).

**Purpose:** A search-to-structured-result companion. The mother types (or dictates) a question and gets a fixed 7-section answer assembled entirely from ParentVeda's own content and her local data.

**Sections & UI:**
- **Top bar:** ParentVeda logo mark, the "Ask Veda" wordmark, and a profile avatar (opens Profile).
- **Search pill (pinned at top):** In the initial view it is an editable field with a hint, a mic dictation button (real speech-to-text into the field), and a submit button. After a question is asked it shows the query text with a clear button and a mic button to ask again.
- **Initial view:** Stage-wise suggestion cards (`kVedaSuggestions`). Active sections show four question chips; inactive sections show three chips plus a "Soon" tag. A shuffle button re-rolls the suggestions. Tapping any chip runs that question.
- **Result view (the fixed structured page):** Rendered below the pinned pill. Sections in order:
  - S1 Veda Answer: a hero card with a week / trimester context chip, an urgent red banner when flagged, a speaker button (voice is "coming soon"), and a themed illustration.
  - S2 What this means for you: the curated explanation plus a personalised line drawn from her own logged symptoms and medications (when relevant).
  - S3 Recommended actions: a list of next-step rows with contextual icons (call, track, read, and so on). These are guidance, not navigation.
  - S4 More information: ParentVeda content cards typed by kind (Weekly Journey, Tool, Video, Article) that route to the matching tool, the weekly journey, the calendar, or the reading hub.
  - S5 Community insights: a social-proof card that opens the community page. Community is never used to form the answer itself.
  - S6 Products: horizontal product cards; tapping opens the product (or the products page).
  - S7 Services: expert rows with "Book" / "Call" buttons (both show "coming soon").
  - A closing disclaimer.
- **Honest fallback:** When nothing scores above the relevance threshold, it shows a plain, honest "I do not have a confident answer yet" card plus the disclaimer, rather than surfacing noise.

**Features & interactions:**
- **Ask by text or voice;** submit re-renders the result and scrolls to the top.
- **Clear** returns to the suggestion view.
- **Tap suggestion chips** to run canned questions.
- **Tap result content, products, or community** to navigate to the corresponding screen; retrieval reference reads (Can I, symptoms, tips, garbh) open in a bottom sheet since they have no standalone screen.
- **`initialQuery`** (from a handoff) is answered automatically on open.

**Data:** Rendered from `VedaResult` produced by `vedaAnswer` (`services/veda_answer.dart`). Curated showcase entries `data/veda_showcase.dart`; suggestion sections `data/veda_suggestions.dart`; product matching against `data/product_data.dart`. The offline engine itself is documented next.

## Screen: Ask Veda - Answer Engine (`ask_veda/veda_core.dart`)

**Status:** Live, offline, on-device. No LLM and no network. It performs grounded retrieval (it surfaces the most relevant content the app already has, with its source) rather than generating text. It is also designed as the retrieval layer a real LLM backend could plug into later.

**Reached from:** Not a screen. It is the shared "brain" behind every Ask Veda answer, called by `services/veda_answer.dart` and fed by `services/veda_index.dart`. This section explains how a typed question becomes the 7-section result the tester sees.

**Purpose:** One app-neutral search core shared by both the pregnancy and parenting sides. It knows nothing about pregnancy or parenting; it only holds tagged content and scores a question against it, scoped by tag. Each side is a thin adapter that builds its own tagged content and asks the core to rank a query.

**How the engine works:**
- **Tagged documents.** Every piece of content becomes a `VedaDoc` stamped with a `VedaDomain` (pregnancy, parenting, or universal) and a `VedaKind` (canI, symptom, weekBaby, weekMother, product, read, trimesterTip, spiritual, readToBaby, garbh, bodyChange, tool, community, scan, plus parenting kinds). Titles, keywords, and body are tokenised into word sets on construction.
- **Scoring.** For a query, tokens are matched with weights: a title hit counts far more than a keyword hit, which counts more than a body hit. There are strong boosts when the whole query appears in the title or equals the title. Ubiquitous words ("pregnancy", "baby", "week", "mother") are heavily down-weighted and never count as a specific match, and a document must land at least one specific (non-generic) word to score at all. This is what stops loosely related cards from appearing.
- **Domain scoping.** A predicate keeps a pregnancy question from ever seeing parenting documents and vice versa; universal content is shared. `vedaScore` returns best-first hits above a relevance threshold, or empty when there is no real match (so the UI can honestly say "I do not have that").
- **Pregnancy corpus and adapter (`services/veda_index.dart`).** Builds and caches the pregnancy corpus from Can I? entries, symptoms, products, reads and weekly written articles, scan and test guides, trimester tips, spiritual reading, read-to-baby pieces, Garbh Sanskar (Vichara, Shravan, Kriya, Samvad, Sacred Insights), the mother's weekly body changes, tool descriptions, verified-expert community posts, and the loaded weeks' baby and mother content. Faith content (spiritual reading, read-to-baby) is gated to only the traditions the mother has explicitly chosen. Community is excluded when forming the answer.
- **Answer assembly (`services/veda_answer.dart`).** First it tries `matchShowcase`: if the query contains a keyword of one of the five hand-authored showcase entries (longest, most specific keyword wins), it returns that fully authored 7-section page. Otherwise it runs `vedaSearch` (community excluded), takes the top hit as the answer (preserving the rich Can I? and Symptom formatting when one of those wins), fills S4 with the next best typed content, pulls any matched products into S6, and adds a community social-proof line into S5 only. If nothing clears the threshold it returns a gentle "no match".
- **Personalisation (`services/veda_context.dart`).** `VedaContext.gather` reads the mother's local data (current week and trimester, the symptoms she has logged and roughly which week, and her active medications) and produces a short warm sentence woven into S2 "What this means for you" (bilingual English and Hindi). When real login and profiles land, only this gather step changes.
- **Shared answer model.** The core defines `VedaAnswerView` (the fixed seven-section result) and `VedaContentRef` (a typed content card carrying a human type label plus routing kind), so both sides produce the identical structure and the UI omits any empty section.

**Data:** Corpus assembled from most of the pregnancy content data files (see the adapter list above). Curated showcase `data/veda_showcase.dart` (five entries). Local personalisation from `SymptomStore` and `MedicineStore` via `PregnancyController`.

### Sub-component: Shared Veda Result UI (`ask_veda/veda_result_view.dart`)

**Status:** Live but not used by the pregnancy Ask Veda screen. `VedaResultView` is the single app-neutral widget that renders a `VedaAnswerView` (the fixed seven sections) driven purely by data, a `VedaViewTheme` palette, and routing callbacks. Testers should note that the pregnancy Ask Veda screen renders its own inline, more decorated version of the same seven sections; `VedaResultView` is the shared renderer used by the parenting side so both apps share one interface. It is included here because it defines the canonical section layout.

**Sections rendered:** S1 Veda answer (hero panel, optional "worth checking with a doctor" urgent chip), S2 What this means for you, S3 Recommended actions (tappable rows), S4 From ParentVeda (typed content cards with a per-kind icon and a chevron), S5 Community insight (social proof), S6 Products, S7 Services, then a disclaimer. Empty sections are omitted. Typography is Fraunces (headings) plus Manrope (body). Each app passes its own colours and its own tap-routing callbacks, since routing needs that app's navigator.

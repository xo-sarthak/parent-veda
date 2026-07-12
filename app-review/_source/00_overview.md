# Overview & Navigation
_ParentVeda Pregnancy App - Feature & Screen Reference_

## Overview

ParentVeda is a calm, bilingual (English + Hindi/Hinglish) Flutter companion app for expecting Indian parents. The pregnancy app runs almost entirely offline against bundled JSON content, with a Supabase backend used only for authentication, the user profile (name, role, due date), partner pairing, and best-effort cloud sync of saved data. On launch the app shows a **Splash** screen, then a one-time **Auth flow** (gated by a local `auth_completed` flag in shared preferences); after that first completion, later launches skip straight into the app. Signed-in mothers land on the **MainScaffold**, a five-tab shell with a floating pill tab bar: **Today** (the daily "Daily Moment" home), **Prepare** (paid commerce sections), **Tools** (the tools hub), **Calendar**, and **Community**. The **Profile** screen is not a tab; it is reached from the circular avatar in the top-right of the Today tab (which also holds a Saved bookmark icon and a global Search icon).

The whole app is driven by the mother's **due date**, held by `PregnancyController`. It derives the current gestational week and day (clamped to weeks 4-40); when no real due date is set, it uses a placeholder that opens the app at **week 20 ("halfway there")**. A saved due date (from the Due Date Calculator tool, from local prefs, or from the cloud profile) persists across restarts and moves the whole app to the real week. There are two testing affordances left in the build: a **Reset to Week 20** button in Profile, and a **Mom | Dad** switch (`FatherPreview`) that previews the separate **Father Mode** experience (a "Slate" blue-grey skin with its own Today / Journey / Reads / Read / Journal tabs). In the shipped product the father instead reaches his mode by entering the mother's pairing code during auth; the Mom | Dad pill is a dev-only tool to be removed before launch.

Where the big feature areas live: the **weekly journey / week-on-week card stack** and **Pregnancy Journey Map** sit under Tools (and the weekly stack is the Journey destination in father mode); **Garbh Sanskar** (five daily rituals) and daily rituals live off the Today home; the **Tools tab** hosts Baby Movement, Weight, Kegel, Contraction, Can I?, Symptoms, Scans, Due Date Calculator, Hospital Bag, Reports, Ask Veda and more; **My Journal**, **My Bump Journey**, **Dear Baby** vault and **Saved** hub live under Profile; **Prepare** houses the paid commerce sections (Masterclasses, Consults, Cohorts, Yoga, Birthing Classes); and **Community** is the social feed. (Everything under `lib/screens/post_pregnancy/` is a separate parenting app and is out of scope here.)

Screens covered in this document:
- App entry (`main.dart`)
- Splash (`splash_screen.dart`)
- Auth flow (`auth_flow_screen.dart`)
- Main scaffold / 5-tab shell (`main_scaffold.dart`)
- Profile (`profile_screen.dart`)
- Global search (`global_search.dart`)
- Saved hub (`saved_hub_screen.dart`)

## Screen: App Entry (`main.dart`)

**Status:** Live - the real app entry point (`main()`), always executed on launch.
**Reached from:** The OS launches this; it is the root of everything.
**Purpose:** Boot the app: initialise the backend, construct the shared content controllers, warm up every persistence store, and hand off to the Splash screen.

**Sections & UI:**
- No UI of its own. `main()` builds `ParentVedaApp`, a `MaterialApp` titled "ParentVeda" with the debug banner off.
- Theme is fixed to **light mode** (`themeMode: ThemeMode.light`) using `AppTheme.light` (a soft lavender-white "Nurturing Wisdom" palette; primary purple `#6A30B6`, coral secondary `#FF5A79`). A dark theme exists but is not used.
- `home:` is `SplashScreen`, passed the three controllers.

**Features & interactions:**
- Before `runApp`, it calls `Supabase.initialize(...)` with `SupabaseConfig.url` / `publishableKey`, so the backend is ready before any screen loads.
- Constructs and `load()`s three content controllers: `PregnancyController` (the week-on-week card stack + due-date logic + language toggle), `HomeContentController` (mother "Daily Moment" content), and `FatherContentController` (father "Daily Moment" content).
- Initialises ~30 singleton stores in `initState` (each loads persisted local data), including: `BabyVoiceService`, `SizeViewPref`, `MemoryStore`, `DailyStore`, `ToolsStore`, `HospitalBagStore`, `CanIStore`, `GarbhStore`, `CommunityStore`, `ExpertFollowStore`, `ProductStore`, `ProductChecklistStore`, `CartStore`, `BoughtStore`, `ReadNextStore`, `JournalStore`, `FatherJournalStore`, `CalendarStore`, `BumpStore`, `MedicineStore`, `VideoStore`, `SymptomStore`, `ScansStore`, `ReminderStore`, `ReadToBabyStore`, `ReadToBabySavedStore`, `JourneyDatesStore`. These back nearly every feature in the app.
- No taps here; it is pure setup. A tester will not see this screen, but a failure here (e.g. no Supabase connection) would surface as a stalled splash or missing data downstream.

**Data:** `SupabaseConfig` (backend URL/key), `AppTheme` (theme), and all the store singletons noted above (local persistence via shared preferences / local files). Content loads from bundled JSON assets via the controllers.

## Screen: Splash (`splash_screen.dart`)

**Status:** Live - the first visible screen ("Warm Nest" Direction B look).
**Reached from:** Shown immediately by `main.dart` on every launch.
**Purpose:** A brief branded launch screen that decides where to send the user (into the app, or into the one-time auth flow) while content keeps loading in the background.

**Sections & UI:**
- Full-screen soft lavender-to-blush diagonal gradient with two blurred glowing "blobs" (lavender top-left, purple bottom-right).
- Centred, gently fading-and-scaling logo: the transparent ParentVeda mark (`assets/brand/pv-mark-transparent.png`) above an italic tagline "Your trusted parenting companion" (Fraunces font).
- A small footer line near the bottom: "Your calm companion" (localised via `s.splashFooter`, English + Hindi).

**Features & interactions:**
- Not interactive. An animation runs (~900 ms fade/scale) and a **2.2-second timer** then calls `_goHome()` which cross-fades to the next screen (~450 ms fade route transition).
- **Launch/auth gating:** `_goHome` reads `kAuthCompletedKey` (`auth_completed`) and `kUserRoleKey` (`user_role`) from shared preferences. If already authed, it routes straight to `MainScaffold` (mother) or `MainScaffold(isFather: true)` (father) based on the saved role. If not authed, it pushes `AuthFlowScreen`.
- On auth completion (the `onDone` callback), it writes `auth_completed = true` and the chosen role, calls `pregnancy.loadProfileFromCloud()` (to show the real name instead of the "Priya"/"Dad" placeholders), triggers `SyncRegistry.resyncAll()` to re-pull cloud data, then routes to the mother or father `MainScaffold`.
- **Testing note:** the line that would apply the auth-picked due date (`setDueDate`) is intentionally commented out ("PINNED TO WEEK 20"), so completing auth does not by itself move the app off week 20; a real due date still comes from the cloud profile or the Due Date Calculator.

**Data:** `SharedPreferences` (`auth_completed`, `user_role`), `PregnancyController` / `HomeContentController` / `FatherContentController` (passed through), `SyncRegistry` (cloud resync), `AppTheme` colours, `S` localized strings.

## Screen: Auth Flow (`auth_flow_screen.dart`)

**Status:** Live, but partly stubbed. Auth (sign-up, log-in, partner pairing, profile save) uses **real Supabase**; the forgot-password / OTP / reset path and all social logins are **UI-only mocks** ("coming soon"). Shown only until the local `auth_completed` flag is set.
**Reached from:** Pushed by Splash on first launch (or when Profile's "Sign out" replays it).
**Purpose:** Onboard the user - create or log into a Supabase account, choose role (mother or father), capture the mother's stage + due date, or let a father pair in with the mother's code - then hand a due date + role back to the caller.

**Sections & UI:**
- A "Soft solid" design: radial purple-to-near-white wash, glass cards, floating coloured dots, Plus Jakarta Sans type, ParentVeda mark. A back button appears on all sub-screens except welcome/pairing/paired. Screens animate in with a fade + slide.
- **Welcome:** logo, a "Loved by 50,000+ parents" social-proof chip, headline "Care that grows with your family.", feature pills (Track / Learn / Community), and a glass card with "Create account", "Log in", and social buttons.
- **Sign up:** full name, email, password fields; "Continue"; Terms & Privacy note.
- **Log in:** email, password; "Forgot password?" link; "Log in"; social row.
- **Role:** two cards - "I'm the mother" (purple, to Profile) and "I'm the father" (teal, to Pair Code).
- **Profile (mother):** stage selector (Trying / Pregnant / New parent), a tappable due-date field, a "Don't know it? Calculate your due date" link (opens a bottom sheet reusing the Due Date Calculator's math: LMP / conception / IVF / ultrasound methods), "Finish setup", and "Skip for now".
- **Pair Code (father):** an uppercase pairing-code field, a gated "Continue" (needs 4+ characters), and "Contact support".
- **Pairing / Paired:** a loading spinner, then a heart badge, partner/you legend, and "Continue".
- **Forgot / OTP / Reset / Success:** email entry; a 5-box OTP with auto-advancing focus; new-password fields; and a success screen ("You're all set!") with "Get started".

**Features & interactions:**
- **Sign up** (`_submitSignup`): validates name/email/6+char password, calls `auth.signUp`; a SQL trigger creates the matching `profiles` row; on success advances to Role.
- **Profile save** (`_saveProfile`): `.update()`s the user's `profiles` row with name, `role: 'mother'`, and the picked due date (date-only), then goes to Success. Warns if there is no session (e.g. "Confirm email" is on).
- **Log in** (`_submitLogin`): `signInWithPassword`, reads the profile, and routes by saved role + due date without re-asking.
- **Father finish** (`_finishFather`): marks the account `role: 'father'`, clears its unused pairing code, and enters as father.
- **Pairing** (`_startPairing`): calls the `link_as_partner` Supabase RPC with the code to link both profiles; on error returns to Pair Code with the message.
- **Success "Get started"** fires `onDone(pickedDue, isFather=false)`; the caller (Splash/Profile) then enters the app.
- **Stubs:** social login buttons, "Resend code", "Contact support", and the entire forgot/OTP/reset sequence just navigate or show "coming soon" snackbars - no real password reset happens.
- Exposes the constants `kAuthCompletedKey` and `kUserRoleKey` used app-wide for launch gating.

**Data:** Supabase `auth` + `profiles` table (name, role, due_date, pairing_code, partner_id) and the `link_as_partner` RPC; `SharedPreferences` flags; the Due Date Calculator's `ddcComputeEdd` math for the calculate sheet. Auth UI copy here is English only.

## Screen: Main Scaffold / 5-Tab Shell (`main_scaffold.dart`)

**Status:** Live - the primary app shell after auth. This is the real structure; note the file's top comment ("Today / Journey / Sanskar / Read / Community") is **stale** - the actual mother tabs built in code are Today / Prepare / Tools / Calendar / Community.
**Reached from:** Splash (or Profile sign-out) routes here once authed; every in-app tab lives inside it.
**Purpose:** Host the five destinations behind a floating pill tab bar, and switch the entire shell between the mother experience and the father (Slate) experience.

**Sections & UI:**
- An `IndexedStack` of the five pages (so tab state is preserved) with a floating `PvTabBar` pill anchored at the bottom centre.
- **Mother tabs:** Today (`HomeScreenB` - the Daily Moment home), Prepare (`PrepareHubScreen` - paid commerce), Tools (`ToolsHubScreen`), Calendar (`CalendarScreen`), Community (`CommunityScreen`). Icons: home, school, widgets, calendar, groups. Labels are bilingual (`s.tabToday` etc.: Today/Aaj, Prepare/Taiyari, Tools, Calendar, Community).
- **Father (Slate) tabs:** Today (`FatherDailyScreen`), Journey (`WeeklyCardStackScreen`), Reads (`FatherReadsScreen`), Read (`FatherReadAloudScreen`), Journal (`FatherJournalScreen`). The nav pill takes the father's blue-grey (`#2E5266`) accent.
- On the **Today tab only**, a small **Mom | Dad** pill floats at the bottom-right (above the tab bar), plus (from the Today home itself) the Saved, Search, and Profile-avatar icons in the header.

**Features & interactions:**
- **Tab switching** goes through the shared `AppNav` singleton (`AppNav.instance.go(i)`), so any screen can request a tab change (e.g. a Home "View week" jumps to Journey). On each nav change it stops the baby-voice audio and, when moving to the Journey tab, snaps the week stack to the current week.
- **Mom | Dad switch** toggles `FatherPreview.instance.on`; the whole shell rebuilds into father or mother mode. This is a **testing-only** dev affordance meant to be removed before launch.
- **Father routing:** a genuinely paired father arrives with `isFather: true`, which sets `FatherPreview.on = true` in `initState` so the same shell renders the Slate father skin (nav, weekly stack, week pop-ups all switch). Both entry points (dev toggle and real pairing) share one code path.
- Profile is deliberately **not** a tab; it is reached from the Today avatar (see Profile screen).

**Data:** `AppNav` (tab index), `FatherPreview` (mode flag), `PregnancyController` (drives week + language), `HomeContentController` / `FatherContentController` (daily content), `BabyVoiceService` (audio stop), `PvTabBar` widget, `AppTheme`, `S` strings.

## Screen: Profile (`profile_screen.dart`)

**Status:** Live. Reached as a pushed page (not a tab). Includes two clearly-labelled **testing** controls (Reset to Week 20; the sign-out that replays auth).
**Reached from:** The circular gradient **avatar** in the top-right of the Today tab (`HomeScreenB`). Also referenced from Global Search and elsewhere.
**Purpose:** The user's account hub: profile header, partner invite/pairing, entry points to her personal memory vaults, the language toggle, and testing/sign-out controls.

**Sections & UI:**
- **Header:** a circular initial avatar (first letter of the name, or a flower glyph), the name, and a subtitle. For a mother: "Week X of 40 · Trimester N" (from the controller); for a father: "Partner account".
- **Mother view** shows, as tappable cards: an **Invite your partner** card (only if a pairing code exists) with the code plus Share / Copy; **My Journal** (`JournalScreen`, shows entry count); **My Bump Journey** (`BumpJourneyScreen`, photo count); **Dear Baby** memory vault (`DearBabyVaultScreen`, talk-entry count); and **Saved** (`SavedHubScreen`, combined saved count).
- **Father view** hides all mother-only vaults and shows a single "Partner account" note ("Her journal, bump journey and memories live in her account").
- **Language card:** a segmented Hinglish | English toggle.
- **Testing controls:** an outlined "Reset to Week 20 · testing" button and a "Sign out" button.
- A footer "More coming soon" line.

**Features & interactions:**
- Vault cards navigate to their respective screens; each shows a live count via `AnimatedBuilder` on its store (`JournalStore`, `BumpStore`, `DailyStore`, and the merged `VideoStore` + `ReadNextStore` + `ReadToBabySavedStore`).
- **Invite partner:** loads the mother's `pairing_code` from the `profiles` table; "Share" opens the OS share sheet with an invite message + code; "Copy" copies the code and shows a snackbar. The card hides itself while loading or if no code exists.
- **Language toggle** calls `controller.setLanguage(...)`, switching the entire app between Hinglish and English immediately.
- **Reset to Week 20 (testing):** clears the saved due date + pregnancy-map data (`controller.resetForTesting()`, `JourneyDatesStore.clearAll()`, `ScansStore.clearAllForTesting()`), snaps back to the week-20 placeholder, returns to Today, and shows a confirmation snackbar.
- **Sign out:** calls Supabase `auth.signOut()`, clears the local `auth_completed` flag, and pushes the auth flow again over the app; completing it re-sets the flag, reloads the cloud profile, resyncs stores, and returns to the mother or father shell. (The re-login due date is also pinned - `setDueDate` is commented out.)

**Data:** Supabase `profiles` (name via controller, `pairing_code`); `PregnancyController` (name, week, language); stores `JournalStore` / `BumpStore` / `DailyStore` / `VideoStore` / `ReadNextStore` / `ReadToBabySavedStore` (counts); `JourneyDatesStore`, `ScansStore`, `SyncRegistry`; `FatherPreview`; `SharedPreferences`; `share_plus`. UI strings bilingual via `S`.

## Screen: Global Search (`global_search.dart`)

**Status:** Live. Purely local search (no backend) using Flutter's `showSearch` / `SearchDelegate`.
**Reached from:** The **search icon** in the Today tab header (`showGlobalSearch(context, controller)`).
**Purpose:** One search box for the whole app - it finds tools/sections, products, reads, "Can I?" food answers, and symptoms, and jumps straight to the matching screen.

**Sections & UI:**
- A standard search app bar (back arrow, a clear "X" action when there is a query) with a localised hint. Results and live suggestions render the same list.
- Results are grouped under uppercase headers: **Tools & sections**, **Products**, **Reads**, **Can I?**, **Symptoms** (only non-empty groups show). Each row has a leading icon or emoji, a title, and (for products/reads/foods) a subtitle.
- An empty query shows a centred search hint; a query with no matches shows a "no results" state.

**Features & interactions:**
- **Tools & sections:** matches an internal destination list against the query label or synonym keys, and tapping opens that screen directly. Destinations include the Journey Map, Products, Product Checklist, Bump Journey, Journal, Garbh Sanskar, Spiritual Reading, Can I?, Symptoms Companion, Ask Veda, Baby Movement, Hospital Bag, Scans & Appointments, Due Date Calculator, Medicine Tracker, Reports, Calendar, and Community (up to 8 shown).
- **Products** (up to 6) open the product detail screen; **Reads** (up to 6) open the read item screen; **Can I?** foods (up to 5) open the Can I? screen; **Symptoms** (up to 5) open the Symptoms Companion. Each tap closes search and pushes the target.
- Searches run over the current-language text (foods/symptoms match localised names, ids, aliases, and keywords).

**Data:** Local data files `can_i_data.dart`, `product_data.dart`, `read_next_data.dart`, `symptom_data.dart` (with `productSearch` / `readSearch` helpers); models `CanIEntry`, `Symptom`, `ReadItem`; `PregnancyController` for language. All content is bilingual (English + Hindi); group headers/hints come from `S`.

## Screen: Saved Hub (`saved_hub_screen.dart`)

**Status:** Live. Read-only aggregation of the mother's bookmarks.
**Reached from:** Profile -> **Saved** card. (Also surfaced via the Saved icon in the Today header.)
**Purpose:** Collect everything she has bookmarked - Read-to-baby pieces, Daily reads, and Videos - newest-saved first, each with its save date, plus a light "discover more" prompt.

**Sections & UI:**
- An app bar titled "Saved".
- Up to three grouped sections, each hidden when empty: **Saved read-to-baby**, **Saved reads**, and **Watch & Learn** (saved videos). Each item is a card tile with a leading icon/emoji, title, subtitle (tag or category · duration), and the save date.
- A **discover more** row of two outlined buttons: "Watch & Learn" and "Read more".
- A friendly empty state (bookmark icon + message + the discover buttons) when nothing is saved.

**Features & interactions:**
- Rebuilds live via `AnimatedBuilder` merging `VideoStore`, `ReadNextStore`, and `ReadToBabySavedStore`.
- **Read-to-baby** tiles open a simple in-file reader (`_SavedRtbReadScreen`) showing the piece's title and body.
- **Reads** tiles open the full `ReadItemScreen`; **Video** tiles open `WatchLearnScreen`.
- Items are ordered newest-saved first (`savedIdsRecent()` / `recent()`), and each tile shows its save date via `s.formatShortDate`.
- Discover buttons push the Watch & Learn and Read Next screens.

**Data:** `ReadToBabySavedStore` (saved read-to-baby pieces + timestamps), `ReadNextStore` (saved read ids + `savedAt`), `VideoStore` (saved video ids + `savedAt`); `readById` from `read_next_data.dart` and `kVideos` for lookup; models `ReadItem`, `PvVideo`, `SavedRtbPiece`. Video titles are bilingual; section labels come from `S`.

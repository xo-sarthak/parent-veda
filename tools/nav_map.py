#!/usr/bin/env python3
# =============================================================================
#  nav_map.py -- the bottom navigation pill, end to end, as a printable map
# -----------------------------------------------------------------------------
#  WHY THIS EXISTS
#
#  The bottom pill is the one component on every screen of every stage, and it
#  is SIX different bars: pregnancy-mother, pregnancy-father, TTC V1, TTC V3,
#  parenting, and the doctor app. Reviewing "the navigation" by opening the app
#  means flipping two version toggles and a Mom|Dad switch to see all of them,
#  and nobody does that in one sitting -- which is exactly how V3 shipped with
#  four of five tabs unreachable, and how seven Prepare categories lost their
#  only entrance for an hour.
#
#  So the tab sets, their destinations and the mechanics behind them are written
#  down here in one structure, and the document is rendered from it. The
#  commentary -- what a reviewer should look AT -- is hand-written, because that
#  is the part a person is needed for.
#
#  ⚠️ THIS IS A HAND-MAINTAINED MAP, NOT A PARSER. `section_doc.py` parses Dart
#  because the parenting section files are pure data; navigation is control
#  flow (popUntil predicates, route-name translation, an IndexedStack) and
#  parsing it would be a Dart interpreter. Every entry below names its
#  file:symbol so a claim can be checked against the source in one jump.
#
#  ⚠️ FONTS ARE CACHED, NOT COMMITTED -- reuses door_map.fonts_css().
#
#  Usage:
#     python tools/nav_map.py            # HTML only
#     python tools/nav_map.py --pdf
# =============================================================================

import html
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import door_map as DM                                        # noqa: E402

ROOT = DM.ROOT
DOCS = DM.DOCS
E = html.escape


# =============================================================================
#  THE SIX BARS
# -----------------------------------------------------------------------------
#  Each bar:  id, name, who, accent class, where the bar is built, how a tap
#             moves you, and its tabs.
#  Each tab:  index, label, icon, the screen it lands on, file, route name,
#             a "what this is" line, the blocks on it, and where each block
#             leads (one further level where it is a real destination).
# =============================================================================

def T(label, icon, screen, file, route, lands, blocks=(), goes=(), notes=()):
    return dict(label=label, icon=icon, screen=screen, file=file, route=route,
                lands=lands, blocks=list(blocks), goes=list(goes),
                notes=list(notes))


# ---- 1. PREGNANCY, MOTHER ---------------------------------------------------

PREG_MOTHER = dict(
    id='preg-mother',
    name='Pregnancy — mother',
    who='Every mother-account user. The default shell of the app.',
    cls='preg',
    built_in='lib/screens/main_scaffold.dart → PvTabBar → PvNavBar',
    mechanic=(
        'An <b>IndexedStack</b>. All five pages are built once and stay alive; a tap changes '
        '<code>AppNav.instance.index</code> and nothing is pushed or popped. So scroll position, '
        'form state and controllers survive tab switches, the hardware back button does '
        '<i>not</i> step between tabs, and there is no "back to Today" — Today is always '
        'underneath. A tap also records one <code>UsageEvents.screen()</code>, keyed by '
        'position rather than by label so a language switch cannot split one surface into two.'),
    tabs=[
        T('Today', 'home', 'TodayHomeScreen (wrapper)',
          'lib/screens/today_home_screen.dart',
          '— (IndexedStack slot 0)',
          'A wrapper, not a screen. It decides which of three Todays is on screen — '
          '<b>Classic</b> (the shipped home, <code>home_screen_b.dart</code>), <b>Focus</b>, or '
          '<b>V3</b> — from a session-only <code>TodayVersionStore</code> that always starts on '
          'Classic. The Classic&nbsp;|&nbsp;V3 pill floats top-right on the page itself.',
          blocks=[
              ('Brand header', 'Mark + wordmark, then three round icons: <b>Saved hub</b>, '
               '<b>global search</b>, and the <b>avatar</b>. There is no Profile tab in this '
               'design — the avatar is the only way to Profile.'),
              ('Three stage doorways', 'Parenting (pushes route <code>pp/my_child</code>), '
               'Trying-to-Conceive (pushes <code>ttc/today</code>), and Skilling (preview, '
               'UI only). These are how you leave this bottom bar for another one.'),
              ('Weekly Snapshot', 'The hero: week, day, a one-line brief for the week, '
               'trimester progress, and “View week ›”.'),
              ('Today’s parenting tip', 'GrowModule — the featured editorial read of the day.'),
              ('Today’s Journey', 'The daily stack: Today’s Video, Daily Garbh Sanskar, '
               'My Journal, medication &amp; supplements, Daily Reads, and a product carousel.'),
              ('Commerce, at the foot', 'Launch Spotlight and the invite nudge. Both render '
               'nothing when nothing is live, which is most mornings.'),
          ],
          goes=[
              ('Avatar', 'ProfileScreen — language, journal, Dear Baby, products, the stage switch'),
              ('Bookmark icon', 'SavedHubScreen'),
              ('Search icon', 'Global search sheet'),
              ('Parenting doorway', 'PpHomeScreen (route <code>pp/my_child</code>) — <b>swaps you onto the parenting bar</b>'),
              ('TTC doorway', 'TtcHomeScreen (route <code>ttc/today</code>) — <b>swaps you onto the TTC bar</b>'),
              ('Skilling doorway', 'SkillingPreviewScreen — twelve doors, none of them live'),
              ('“View week ›”', 'WeeklyCardStackScreen'),
              ('Today’s Video', 'The video player'),
              ('Garbh card', 'GarbhScreen — the four live pillars'),
              ('Journal card', 'JournalScreen'),
              ('Medication card', 'MedicineTrackerScreen'),
          ],
          notes=['The version pill is testing chrome and is session-only on purpose — an '
                 'experiment that persists is a release.']),

        T('Prepare', 'school', 'PrepareHubScreen',
          'lib/screens/prepare/prepare_hub_screen.dart',
          '— (IndexedStack slot 1)',
          'The paid / guided layer. A hero, a recommended rail of two programmes, then '
          'exactly four category rows.',
          blocks=[
              ('Recommended rail', 'Two featured programmes from the unified catalogue — a '
               'masterclass and a cohort — each opening ProgramDetailScreen.'),
              ('Courses &amp; Cohorts', 'The unified V2 screen. Masterclasses and cohort '
               'programmes were folded in here; their old standalone tiles are commented out.'),
              ('Birthing Classes', 'Kept as-is.'),
              ('Yoga', 'Opens the <i>same</i> cult.fit-style screen the parenting side uses, '
               'filtered to pregnancy categories. One UI, two tabs.'),
              ('Nutrition', 'A funnel: assessment → plans → trailer → consult → plan.'),
              ('Sponsorship strip', 'PresentedBy — renders only when live sessions are '
               'sponsored. A brand funds the room; it does not choose the answers.'),
          ],
          goes=[
              ('Courses &amp; Cohorts', 'CoursesCohortsScreen → ProgramDetailScreen → booking'),
              ('Birthing Classes', 'BirthingClassesScreen'),
              ('Yoga', 'YogaHomeScreen (shared with parenting)'),
              ('Nutrition', 'NutritionScreen'),
              ('Any programme card', 'ProgramDetailScreen → the shared booking engine (lib/booking/)'),
          ]),

        T('Tools', 'widgets', 'ToolsHubScreen',
          'lib/screens/tools_hub_screen.dart',
          '— (IndexedStack slot 2)',
          'The toolbox. A Journey Map hero, a progressive-profiling strip, then a two-column '
          'grid of roughly twenty tiles, re-ordered live by what she said she wants help with.',
          blocks=[
              ('Journey Map hero', 'Full-width gradient card → JourneyMapScreen.'),
              ('Priorities strip', 'Progressive profiling, asked exactly where the answer pays '
               'off: her pick re-sorts the grid immediately below.'),
              ('The grid', 'A <b>stable sort that returns every tile</b> — tools matching a '
               'chosen priority move to the front, nothing is hidden or removed. Level-3 '
               'personalisation: content and order, never structure.'),
              ('Support note', 'A closing reassurance panel.'),
          ],
          goes=[
              ('Garbh Sanskar', 'GarbhScreen'), ('Spiritual reading', 'SpiritualReadingScreen'),
              ('Baby Movement', 'BabyMovementScreen'), ('Bump journey', 'BumpJourneyScreen'),
              ('My Journal', 'JournalScreen'), ('Read next', 'ReadNextScreen'),
              ('Weight', 'WeightTrackerScreen'), ('Kegel &amp; care', 'KegelCareScreen'),
              ('Contractions', 'ContractionTrackerScreen'),
              ('Hospital bag', 'ReadyForBirthScreen (the redesign; the old bag screen is kept for revert)'),
              ('Product checklist', 'ProductChecklistScreen'),
              ('Product Guide', 'ProductGuideHubScreen'),
              ('Launches', 'LaunchHubScreen — the Launch Hub’s <b>only</b> front door'),
              ('Brand Studio', 'BrandShowcaseScreen — the guided tour of all 15 brand products'),
              ('Medication', 'MedicineTrackerScreen'), ('Reminders', 'RemindersScreen'),
              ('Tests, Scans &amp; Reports', 'TestsScansReportsScreen — absorbed both “Understanding your report” and “Scans &amp; care”'),
              ('Can I…?', 'CanIScreen'), ('Symptom companion', 'SymptomCompanionScreen'),
              ('Due date calculator', 'DueDateCalculatorScreen (badges when the saved date may be stale)'),
              ('Ask Veda', 'AskVedaScreen (the tools-tab copy)'),
              ('Father’s Journal', 'FatherJournalScreen'),
              ('Brand Studio (debug) · Care Partner (debug)', 'Debug builds only'),
          ]),

        T('Calendar', 'calendar_today', 'CalendarScreen',
          'lib/screens/calendar_screen.dart',
          '— (IndexedStack slot 3)',
          'The command centre. A progress card, category filter chips, search, and a '
          'three-way segmented control. <b>It opens on tab 1, the grid — not the timeline.</b>',
          blocks=[
              ('Progress card', 'Where she is, quietly.'),
              ('Filter chips', 'One choke point feeding all three views. ParentVeda’s own '
               'recommendations are excluded from every one of them.'),
              ('Timeline (seg 0)', 'Everything that has happened and is coming, as a rail.'),
              ('Calendar grid (seg 1, default)', 'Month grid with coloured day markers and a '
               'collapsible legend. Tapping a date scrolls to that day’s detail panel.'),
              ('Upcoming (seg 2)', 'Milestones, appointments, tests and scans only.'),
              ('Day sheet', 'Opened from a day. Carries the day’s events and up to three '
               'actions.'),
          ],
          goes=[
              ('Day sheet → “Open week”', 'Selects that week, then WeeklyCardStackScreen'),
              ('Day sheet → “Open journal”', 'JournalScreen'),
              ('Day sheet → Delete', 'Only on a personal, non-system event'),
              ('Add event', 'A bottom sheet with mic dictation'),
          ]),

        T('Community', 'groups', 'CommunityScreen',
          'lib/screens/community_screen.dart',
          '— (IndexedStack slot 4)',
          'The social layer over the shared CommunityStore. Utility icons scroll with the '
          'page rather than sitting in a bar.',
          blocks=[
              ('Utility row', 'Doctor test-mode toggle · bookmarks · my activity · search.'),
              ('Your communities', 'Rooms she has joined. <b>Always renders</b> — an empty '
               'state, never a missing section.'),
              ('Recommended communities', 'Rooms she has not joined. Same rule.'),
              ('Feed tabs', 'For you / Following, then the feed.'),
              ('Experts-only chip', 'Narrows the feed to posts by verified experts. Available '
               'to every viewer.'),
              ('Verify-triage chip', 'Doctor mode only — posts awaiting endorsement.'),
              ('Compose FAB', 'Floats clear of the pill via a lifted end-float location.'),
          ],
          goes=[
              ('A community card', 'CommunityDetailScreen'),
              ('A post', 'Post detail — comments, related discussions, suggested communities'),
              ('Bookmark icon', 'MyBookmarksScreen'), ('Person icon', 'MyActivityScreen'),
              ('Search icon', 'A search delegate over rooms and posts'),
              ('An expert name', 'CommunityProfileScreen'),
          ]),
    ],
)


# ---- 2. PREGNANCY, FATHER (Dad mode) ----------------------------------------

PREG_FATHER = dict(
    id='preg-father',
    name='Pregnancy — father (Dad mode)',
    who='A paired father, and any mother previewing him with the testing Mom&nbsp;|&nbsp;Dad pill '
        '(bottom-right, Today tab, Classic only).',
    cls='dad',
    built_in='lib/screens/main_scaffold.dart — same PvTabBar, <code>father: true</code>',
    mechanic=(
        '<b>The same shell, the same IndexedStack, the same five slots.</b> Only the pages, the '
        'labels and the accent change — Slate instead of violet. Tabs 0 and 1 (Today, Journey) '
        'are shared ideas rendered in his voice; tabs 2–4 become his own sections. '
        '<code>FatherPreview.instance.on</code> is the single switch, set in '
        '<code>initState</code> for a paired father.'),
    tabs=[
        T('Today', 'home', 'FatherDailyScreen (embedded)',
          'lib/screens/father/father_daily_screen.dart', '— (slot 0)',
          'His daily space, in the Slate palette — “grounded, warm, getting ready to meet my '
          'baby”. Its own palette, not AppTheme.',
          blocks=[('Daily cards', 'His day, with the scans &amp; appointments due-now card '
                   'below the read-to-baby block.')]),
        T('Journey', 'explore', 'WeeklyCardStackScreen',
          'lib/screens/weekly_card_stack_screen.dart', '— (slot 1)',
          'The same weekly card stack the mother gets: seven swipeable cards for the active '
          'week, a week strip with future weeks locked.',
          notes=['Switching to this tab snaps the stack to the <i>current</i> week — '
                 '<code>_onNav</code> calls <code>selectWeek(currentWeek)</code> on every '
                 'change to slot 1.']),
        T('Reads', 'menu_book', 'FatherReadsScreen',
          'lib/screens/father/father_reads_screen.dart', '— (slot 2)',
          'His library, grouped as Articles · Research Summaries · Book Summaries.',
          goes=[('Any read', 'The Slate “Learn V2” reader — progress bar, table of contents, '
                 'font size, reading modes, Why-This-Matters / Research-Simplified / '
                 'Myth-vs-Fact blocks')]),
        T('Read', 'auto_stories', 'FatherReadAloudScreen',
          'lib/screens/father/father_read_aloud_screen.dart', '— (slot 3)',
          'Read to baby. The same four tabs as the mother’s Samvad: Affirmations &amp; '
          'Blessings · Stories &amp; Fables · Mantras &amp; Lullabies · Spiritual Reading.',
          notes=['He <b>cannot customise</b>. Spiritual Reading mirrors whatever the mother '
                 'chose, read-only. Only Affirmations &amp; Blessings draws from a distinct '
                 'father slice.']),
        T('Journal', 'edit', 'FatherJournalScreen (embedded)',
          'lib/screens/father/father_journal_screen.dart', '— (slot 4)',
          'A deliberately smaller cousin of My Journal: four quick actions and a newest-first '
          'feed.',
          blocks=[('Quick actions', 'Write a memory · Note for baby · Add photo · Record voice.')],
          notes=['Stores into a <b>separate</b> FatherJournalStore, but reuses the mother’s '
                 'compose sheets through their <code>onAdd</code> hook.']),
    ],
)


# ---- 3. TTC V1 --------------------------------------------------------------

TTC_V1 = dict(
    id='ttc-v1',
    name='Trying to Conceive — V1',
    who='Anyone in the TTC stage with the home version left on V1. The version pill lives in '
        'TTC Profile.',
    cls='ttc',
    built_in='lib/screens/ttc/ttc_common.dart → TtcBottomNav → PvNavBar, floated by TtcPage',
    mechanic=(
        'Not an IndexedStack — a <b>pop-then-push</b>. <code>openTtcTab</code> runs '
        '<code>popUntil(isFirst || name == "ttc/today")</code> and then pushes the target as a '
        'named route. So Today is always at the bottom of the stack, every other tab is one '
        'route above it, and hardware-back from any tab returns to Today. Each tab screen is '
        'rebuilt on entry — nothing is kept warm.'),
    tabs=[
        T('Today', 'home', 'TtcTodayScreen (via TtcHomeScreen)',
          'lib/screens/ttc/ttc_today_screen.dart', 'ttc/today',
          'The stage home. <code>TtcHomeScreen</code> is the gate in front of it: it holds the '
          'first-run intro flow and the V1/V3 switch, and a paired partner is diverted here to '
          '<code>TtcPartnerTodayScreen</code> instead.',
          blocks=[
              ('TtcHeader', 'Mark + wordmark, and the avatar → TTC Profile. On every TTC screen.'),
              ('Chapter hero', 'The chapter name in Fraunces, its tagline, a “day N of M” line, '
               'a days-trying chip, an ⓘ that explains the chapter, and “Journey map ›”.'),
              ('Rhythm card', 'Where she is in the cycle.'),
              ('Today’s Journey', 'One insight <b>card</b> (the only real article), then four '
               '<b>rows</b> — the myth, today’s nutrition, today’s movement, today’s pick. '
               'Rows because a row is a line you scan and a card is a small article you have '
               'to read.'),
              ('Ritual card', 'Keeps its card: per-item checkboxes, a count and a streak. You '
               '<i>do</i> this from Today rather than opening a screen.'),
              ('Journal card', 'Four shortcut circles.'),
              ('Record a test', 'The one door out of the stage. Understated, never a prompt.'),
              ('Disclaimer', 'Every tool carries it, so the busiest screen does too.'),
          ],
          goes=[
              ('Avatar', 'TtcProfileScreen — language, sign-out, the V1|V3 pill, the Her|Him pill'),
              ('Chapter ⓘ', 'A sheet: what the chapter means, what moves you on, worth doing'),
              ('“Journey map ›”', 'TtcJourneyMapScreen (<code>ttc/map</code>)'),
              ('Insight card', 'TtcInsightScreen'),
              ('The four rows', 'Each opens the same content in a sheet'),
              ('Ritual card', 'TtcRitualScreen'), ('Journal card', 'TtcJournalScreen'),
              ('Record a test', 'The positive-test flow → the pregnancy shell'),
          ]),
        T('Prepare', 'school', 'TtcPrepareScreen',
          'lib/screens/ttc/ttc_prepare_screen.dart', 'ttc/prepare',
          'The commerce surface, unfiltered: <b>all nine categories</b> with their offerings, '
          'running on the shared booking engine.',
          blocks=[
              ('The nine categories', 'Expert consultations · Courses · Fertility yoga · '
               'Nutrition · Mental wellness · Medical assessments · Partner workshops · '
               'IVF support · Lifestyle programmes.'),
              ('Offering cards', 'Title, price, body, a “for both of you” chip where it is a '
               'couple offering, session count, and “owned” once an entitlement exists.'),
              ('Payment note', 'Says on screen that payment is stubbed.'),
          ],
          goes=[('Any offering', 'Detail → buy (grants the entitlement) → slot picking → '
                 'My Bookings, the same history a birthing class lands in eight months later')]),
        T('Tools', 'widgets', 'TtcToolsScreen',
          'lib/screens/ttc/ttc_tools_screen.dart', 'ttc/tools',
          'Twenty-two tiles in four groups. The hub is the <b>index</b>; a journey step is the '
          'recommendation. Both must exist — a woman told she might have PCOS opens Tools and '
          'searches for the word.',
          blocks=[
              ('Your body', 'Cycle Companion · Ovulation Companion · Fertility Window · '
               'Symptom Companion · Weight · Sleep · PCOS symptom check · Weight and fertility '
               '(BMI) · See a specialist?'),
              ('Both of you', 'Partner Health · Mood · Stress · Lifestyle · Journal.'),
              ('Care and medicines', 'Supplements · Medication · Medical Tests · Vaccinations · '
               'Records &amp; reports · Appointments.'),
              ('Plan and learn', 'Movement · Nutrition Planner · Journey Map · Can I…? · '
               'Pre-pregnancy checklist · Worth knowing about.'),
          ],
          goes=[
              ('Cycle Companion', 'TtcCycleScreen (<code>ttc/cycle</code>)'),
              ('Fertility Window', 'TtcFertilityWindowScreen (<code>ttc/window</code>)'),
              ('Symptom / Weight / Sleep / Mood / Stress / Lifestyle / Movement / Partner Health',
               'The shared tracker screen, opened on that metric'),
              ('PCOS symptom check', 'The PCOS surface'),
              ('Weight and fertility', 'TtcBmiScreen — deliberately <i>not</i> the Weight '
               'tracker beside it: one logs a series, the other reads one number against South '
               'Asian cut-offs'),
              ('Supplements / Medication / Tests / Vaccinations / Records / Appointments',
               'Their own screens; several show a live count under the tile'),
              ('Journey Map', 'TtcJourneyMapScreen'), ('Can I…?', 'TtcCanIScreen'),
              ('Pre-pregnancy checklist', 'TtcPrecheckScreen'),
              ('Worth knowing about', 'TtcProductsScreen — research first, buy second'),
          ]),
        T('Calendar', 'calendar_today', 'TtcCalendarScreen',
          'lib/screens/ttc/ttc_calendar_screen.dart', 'ttc/calendar',
          'The TTC command centre. Same architecture as the pregnancy calendar: a month grid '
          'with coloured markers, a collapsible legend, and a panel for the selected day.',
          blocks=[('The day panel', 'Merges the cycle, the fertile window, journal entries, '
                   'everything logged in the trackers, and milestones reached.'),
                  ('Expected period', 'Drawn as a <b>soft outline, labelled “expected”</b> — '
                   'never a solid marker on a day her body has not agreed to.')],
          notes=['The fertile window comes from the same engine as Today’s hero and the '
                 'Fertility Window tool, so the three cannot disagree.']),
        T('Community', 'groups', 'TtcCommunityScreen',
          'lib/screens/ttc/ttc_community_screen.dart', 'ttc/community',
          'The shared social layer again — <code>CommunityStore</code> keyed by id, so a room '
          'joined here is still joined in the parenting feed two years later.',
          blocks=[('Loss &amp; Recovery room', 'A product that only holds hope is not honest '
                   'about this stage.'),
                  ('Ordering', 'Rooms by what the couple joined; the feed chronological within '
                   'that. Nothing here is ranked by popularity.')],
          goes=[('Care circle', 'TtcCareCircleScreen')]),
    ],
)


# ---- 4. TTC V3 --------------------------------------------------------------

TTC_V3 = dict(
    id='ttc-v3',
    name='Trying to Conceive — V3',
    who='Anyone whose <code>TtcHomeVersionStore</code> is on V3. This is the design the stage '
        'is moving to; V1 is the revert path, not the other arm of a live experiment.',
    cls='ttc',
    built_in='same TtcBottomNav, <code>v3</code> resolved from the store',
    mechanic=(
        'Same pop-then-push over <code>ttc/today</code>. Two things are different and both '
        'have bitten before:<br><br>'
        '<b>1. The tab set is chosen by the store, not by the caller.</b> '
        '<code>TtcBottomNav.v3</code> used to be a <code>bool</code> defaulting to false, and '
        'only two screens passed it — so every screen reached through <code>TtcPage</code> drew '
        'V1’s five tabs under a V3 app. It is nullable now, and null means “ask the store”. '
        '<i>A default that is wrong for most callers is not a default, it is a trap.</i><br><br>'
        '<b>2. The active index is translated by route name.</b> <code>TtcPage(tab: 3)</code> '
        'means Calendar in V1 and “Talk to expert” in V3, so reusing the index would highlight '
        'a tab the screen has nothing to do with. <code>ttcV3ActiveFor</code> maps the route; '
        'anything unrecognised lands on <b>More</b>, which is the truth rather than a fallback.'),
    tabs=[
        T('Today', 'home', 'TtcHomeV3',
          'lib/screens/ttc/ttc_home_v3.dart', 'ttc/today',
          'A photographic hero field the page slides over, then a sheet of sections. The big '
          'fact is <b>where she is</b>, never a probability, never a countdown, and never a '
          '“chapter N of 5” — chapters 2–4 come round with every cycle.',
          blocks=[
              ('Cycle header', 'Replaced the chapter hero. Leads on the week and the window, '
               'with the chapter as a chip above them. Carries avatar, date strip and a '
               'calendar icon.'),
              ('My daily insights', 'Titled with the <b>selected date</b>, not the word '
               '“Today” — a heading saying “Today” over cards computed for last Tuesday is a '
               'screen lying about its own contents.'),
              ('Start anywhere', 'The bracket door grid, four columns, one per TTC bracket.'),
              ('Garbhadhana Samskara', 'The pre-conception practice — the ritual card in full, '
               'with checkboxes and a streak. <b>Not</b> Garbh Sanskar, which is the pregnancy '
               'feature and a different thing.'),
              ('Recommended for you', 'A product rail. Shows category and price, never a '
               'benefit — a supplement rail on a fertility home is one careless subtitle away '
               'from being a claim.'),
              ('Recommended reads', 'The chapter card, then Me / Us / What’s next tabs hung off '
               'it, then a rail into the reads library.'),
              ('Your journal', 'Pregnancy’s widget verbatim, with four quick actions.'),
              ('Talk to experts', 'The section that <b>ends</b> the page — deliberately not the '
               'products rail. The last thing she reads is that there is a person, not a price.'),
              ('The door out', 'The positive-test door, plus the disclaimer.'),
          ],
          goes=[
              ('Avatar', 'TtcProfileScreen'), ('Chapter chip', 'TtcJourneyMapScreen'),
              ('Cycle-day line', 'The cycle companion (<code>ttc_cycle</code>)'),
              ('Calendar icon', 'TtcCalendarScreen'),
              ('A door in the grid', 'That bracket’s problem hub / journey'),
              ('Chapter card', 'The chapter reader, default tab'),
              ('Me / Us / What’s next', 'The chapter reader on that tab — the card alone could '
               'only reach “Me”'),
              ('Read rail', 'PvReaderScreen for that piece'),
              ('Journal quick actions', 'Journal · Journal · Calendar · Partner'),
              ('“Fertility experts”', 'TtcPrepareScreen, unscoped'),
          ]),
        T('Courses', 'school', 'TtcPrepareScreen(onlyCategory: "courses")',
          'lib/screens/ttc/ttc_prepare_screen.dart', 'ttc/courses',
          'Prepare, scoped to one category.',
          notes=['<b>Scoping is the fix, not a limitation.</b> Unscoped, Courses and Talk-to-'
                 'expert opened the identical nine-category screen and both labels lied about '
                 'where they went.']),
        T('Tools', 'widgets', 'TtcToolsScreen',
          'lib/screens/ttc/ttc_tools_screen.dart', 'ttc/tools',
          'Identical to V1’s Tools — same twenty-two tiles, same four groups.',
          notes=['Tabs 0 and 2 keep V1’s icons deliberately: Today and Tools mean the same '
                 'thing in both versions, so flipping the pill should not make her re-find them.']),
        T('Talk to expert', 'chat_bubble', 'TtcPrepareScreen(onlyCategory: "consults")',
          'lib/screens/ttc/ttc_prepare_screen.dart', 'ttc/consults',
          'Prepare, scoped to expert consultations.',
          goes=[('An offering', 'Buy → the calendar case of the booking engine → a real slot')]),
        T('More', 'more_horiz', 'TtcMoreScreen',
          'lib/screens/ttc/ttc_more_screen.dart', 'ttc/more',
          '<b>Not a junk drawer — the other half of a deliberate trade.</b> V3 dropped two tabs '
          'and narrowed a third, and the trade only holds if this screen is complete.',
          blocks=[
              ('Your cycle', 'Calendar · Cycle companion · Fertility window.'),
              ('Community', 'Community · My journal · Profile.'),
              ('Prepare', 'One row into the <b>unfiltered</b> nine-category Prepare screen.'),
          ],
          goes=[('Calendar', 'TtcCalendarScreen'), ('Cycle companion', 'the cycle surface'),
                ('Fertility window', 'TtcFertilityWindowScreen'),
                ('Community', 'TtcCommunityScreen'), ('My journal', 'TtcJournalScreen'),
                ('Profile', 'TtcProfileScreen'),
                ('Everything else', 'TtcPrepareScreen, all nine categories')],
          notes=['⚠️ The seven Prepare categories without a tab — yoga, nutrition, mental '
                 'wellness, assessments, partner workshops, IVF support, lifestyle — are '
                 'reachable through <b>this one row and nowhere else</b>. Scoping it would '
                 'delete six of them. Caught by asking “where did yoga go?”, not by a test.',
                 'The parity test (<code>ttc_home_v3_parity_test</code>) covers the two '
                 '<i>homes</i>, not the nav. This screen is what keeps V3 complete.']),
    ],
)


# ---- 5. TTC PARTNER ---------------------------------------------------------

TTC_PARTNER = dict(
    id='ttc-partner',
    name='Trying to Conceive — the partner (Him)',
    who='A paired partner, and anyone flipping the dev-only Her&nbsp;|&nbsp;Him pill in TTC Profile.',
    cls='dad',
    built_in='same TtcBottomNav, <code>slate: true</code>',
    mechanic=(
        '<b>The same five destinations, his colours.</b> Deliberately not a reduced tab set: '
        'per-user navigation is forbidden — personalisation changes content, ranking and order, '
        'never structure — and the pregnancy father shell follows the same rule. One scaffold, '
        'his content inside it. The stage branches at <code>TtcTodayScreen</code> rather than at '
        'the doorway, so both halves of the couple share one route and one back-stack.'),
    tabs=[
        T('Today', 'home', 'TtcPartnerTodayScreen',
          'lib/screens/ttc/ttc_partner_screen.dart', 'ttc/today',
          'Structurally identical to hers — same card shell, same gutter — in Slate.',
          blocks=[('Section order', '<b>mission → supporting her → your half of this → learn → '
                   'journal.</b> Not hers with the labels swapped: “your half of this” sits '
                   'above the reading and the journal on purpose. A partner screen where his '
                   'own body appears last has quietly decided this is her project.')],
          notes=['The partner door <b>never sends cycle_day</b> to Ask Veda.',
                 'His header gained the profile door late — before that a paired partner had no '
                 'way to switch language and no way to sign out, on any screen. One header with '
                 'a palette flag, rather than two headers; two headers is how it went missing.']),
        T('Prepare / Tools / Calendar / Community', '—', 'the same four screens',
          '—', '—',
          'Unchanged destinations in the Slate palette.'),
    ],
)


# ---- 6. PARENTING -----------------------------------------------------------

PARENTING = dict(
    id='parenting',
    name='Parenting (post-pregnancy)',
    who='Reached through the parenting doorway on the pregnancy Today, or by the stage switch.',
    cls='parent',
    built_in='lib/screens/post_pregnancy/pp_common.dart → PpBottomNav → PvNavBar',
    mechanic=(
        'Pop-then-push, like TTC: <code>openPpTab</code> does '
        '<code>popUntil(isFirst || name == "pp/my_child")</code> then pushes. Tab 0 <i>is</i> '
        'the popUntil — nothing is pushed, you simply arrive back at the home however deep you '
        'were. The bar is positioned inside each page’s Stack rather than by a shell, so every '
        'tab screen mounts its own <code>PpBottomNav(active: n)</code>.'),
    tabs=[
        T('My Child', 'child_care', 'PpHomeScreen → MyChildScreen(home: true) or PpHomeV3',
          'lib/screens/post_pregnancy/my_child_screen.dart', 'pp/my_child',
          'The parenting home, built around the child’s current developmental <b>leap</b>. '
          '<code>PpHomeVersionStore</code> chooses between the shipped screen (V1, the default) '
          'and PpHomeV3.',
          blocks=[
              ('Header', 'Mark + wordmark, then <b>bookmark</b>, <b>search</b>, <b>profile</b> '
               'and the <b>hamburger</b> — which opens the Explore drawer, the largest single '
               'destination in the app (see overleaf).'),
              ('Leap hero', 'Photo, name, age, the phase number/name/tagline and the '
               'storm→sun leap progress. The photo and name open the child switcher.'),
              ('Leap video', 'Comes from the phase’s Watch category, so there is no '
               '“this phase has no video” case.'),
              ('Leap description', 'Expandable.'),
              ('Child snapshot', 'The domain rows.'),
              ('Journal', 'The keepsake journal’s door.'),
              ('Watch &amp; Learn rails', 'Videos then reads for the leap.'),
              ('Products for this phase', 'Mixed across the leap’s milestones and domains.'),
              ('FAQs', 'Top three questions for the age, rotating on each app open.'),
              ('Looking ahead', 'One line about the next leap.'),
              ('Brand slots', 'Premiere on open (rarely), Launch Spotlight, invite nudge — '
               'each renders nothing unless something is genuinely live.'),
          ],
          goes=[
              ('Hamburger', '<b>ExploreDrawer</b> — ~25 sections; the full list is its own page below'),
              ('Bookmark', 'PpSavedHubScreen'), ('Search', 'RecoSearchScreen'),
              ('Profile', 'FamilyProfileScreen'),
              ('Photo / name', 'MultiChildSheet — the child switcher'),
              ('Leap hero', 'LeapDefinitionScreen'),
              ('Phase block', 'PhaseDetailScreen / PhaseMapScreen'),
              ('A snapshot domain row', 'DevelopmentAreaScreen → DevStageDetailScreen'),
              ('Journal', 'JournalHomeScreen (V2 storybook)'),
              ('A video', 'WatchPlayerScreen · a rail header → WatchCategoryScreen'),
              ('A read', 'ReadingReaderScreen · a collection → ReadingCollectionScreen'),
              ('A product', 'RecoDetailScreen'),
              ('“Ask Veda anything else”', 'The parenting Ask Veda — <b>this and the FAB are its '
               'only doors now</b>, since it lost its tab'),
          ]),
        T('Brain', 'emoji_objects', 'GrowHomeScreen',
          'lib/screens/post_pregnancy/grow_home_screen.dart', '—',
          'A wrapper over <b>three</b> versions of the same feature, chosen by a floating pill: '
          'V1 is <code>DevelopmentHomeScreen</code> constructed exactly as Explore used to '
          'construct it, plus GrowV2Home and GrowV3Home.',
          blocks=[('V1 — Development home', 'Today’s Focus · the birth-to-five Development Map · '
                   'the eight development areas, each its own journey · today’s activities '
                   '(filtered by the child’s age, falling back to the full list rather than '
                   'showing nothing) · a Brain Development window · Looking Ahead · a gentle '
                   'check-in.')],
          goes=[('Today’s Focus', 'DevelopmentActivityScreen'),
                ('Development Map', 'DevelopmentMapScreen'),
                ('An area', 'DevelopmentAreaScreen'),
                ('“See all activities”', 'DevelopmentAllActivitiesScreen'),
                ('Check-in', 'DevelopmentCheckinScreen')],
          notes=['<b>This tab used to be Ask Veda.</b> The parenting review took Ask Veda out '
                 'of the bar and moved Skill Development in, renamed “Brain”. Ask Veda is not '
                 'gone — it is on the My Child page and on the Ask FAB — but it no longer has a '
                 'permanent slot. The old line is kept commented in <code>openPpTab</code>.',
                 '“Brain” rather than “Brain Development”: five tabs share the width evenly and '
                 'a two-word label truncates on a small phone. The screen is titled in full.',
                 '⚠️ Three versions behind one row is a design question deferred to a runtime '
                 'switch — logged in <code>STILL-OPEN.md</code> §5.9.']),
        T('Tools', 'widgets', 'ToolsHubScreen (parenting)',
          'lib/screens/post_pregnancy/tools_hub_screen.dart', '—',
          'An editorial header and one list of everyday trackers with live status lines.',
          blocks=[('Everyday trackers', 'What Changed? · Growth journey · Product Guide · '
                   'Vaccination schedule · Baby names · Feeding journey · Sleep journey.')],
          goes=[('What Changed?', 'WhatChangedScreen — a searchable 30-concern library'),
                ('Growth journey', 'GrowthJourneyScreen'),
                ('Product Guide', 'ProductGuideHubScreen — <b>Compare now lives inside it</b>, '
                 'as a row at the top: you compare while choosing, not from a toolbox two taps away'),
                ('Vaccination schedule', 'VaxTrackerScreen — the redesign; the old '
                 'VaccinationScreen is kept for revert'),
                ('Baby names', 'BabyNamingHomeScreen — the V1|V2 front door'),
                ('Feeding journey', 'FeedingJourneyScreen'),
                ('Sleep journey', 'SleepJourneyScreen')],
          notes=['Four rows were deliberately removed and are commented in place: His Leap '
                 'Window (the leap already leads the home), Development journey (already in the '
                 'hero and the milestone section), Launches and Brand Studio (moved to Explore '
                 '— Tools is for what you use <i>on</i> your child), and Compare (moved into '
                 'the Product Guide). <i>A third door to the same place made Tools look like it '
                 'was padding.</i>']),
        T('Community', 'groups', 'CommunityScreen (parenting)',
          'lib/screens/post_pregnancy/community_screen.dart', '—',
          'A faithful parenting replica of the pre-birth community on the <b>same</b> '
          'CommunityStore and models — only the content differs.',
          blocks=[('Same structure', 'Your communities · Recommended communities · a For-you / '
                   'Following pill · post cards with polls, photos, like/comment/repost/save/'
                   'share · post detail with comments, related and suggested · a full composer · '
                   'doctor test-mode, “needs verification” triage and endorse-by-commenting · '
                   'my activity · my bookmarks · a search delegate.')],
          notes=['The pregnancy feed is untouched: every list here is computed from parenting '
                 'data plus the store’s per-id state.']),
        T('Products', 'shopping_bag', 'ProductsDiscoveryScreen',
          'lib/screens/post_pregnancy/products_discovery_screen.dart', '—',
          '“Research first. Buy when you’re sure.” A search bar, a marketplace-style Filters '
          '+ Sort bar, and four discovery entry points.',
          blocks=[('Four entry points', 'Concern · Age-stage · Category · Compare.'),
                  ('Filters', 'A <b>button</b> opening a full sheet, not inline toggles — plus '
                   'brand, price band, rating band and sort.'),
                  ('Two modes', 'With no filter set it shows the browse-by-category list; once '
                   'anything is set it becomes a ranked results grid.')],
          goes=[('A category', 'ProductsCategoryScreen → ProductsSubcategoryScreen'),
                ('“Compare any two”', 'ProductsCompareScreen'),
                ('A product', 'ProductDetailScreen')]),
    ],
)


# ---- 7. DOCTOR --------------------------------------------------------------

DOCTOR = dict(
    id='doctor',
    name='ParentVeda+ — the doctor app',
    who='Shown by the app root instead of MainScaffold whenever '
        '<code>DoctorSession.active</code> is true. A separate app that happens to live in the '
        'same binary.',
    cls='doc',
    built_in='lib/screens/doctor/doctor_scaffold.dart — <b>its own bar</b>',
    mechanic=(
        '⚠️ <b>This is the one bar that is not the pill.</b> It is a hairline-topped white '
        '<code>bottomNavigationBar</code>, 62pt, with filled/outlined icon pairs — not '
        '<code>PvNavBar</code>, not floating, not rounded. It switches with a plain '
        '<code>setState</code> over five bodies, so like pregnancy there is no push and no back '
        'between tabs. It is deliberately calm and clinical: a work tool, not the warm parent '
        'experience.<br><br>'
        'The shell also keeps the roster fresh three ways — on app resume, on a 90-second poll '
        '(for the phone left open on a desk, which never resumes because it never left), and by '
        'pull-to-refresh. Prescriptions ride along, because every screen decides what to say '
        'about a past consult from <code>PrescriptionStore.hasFor()</code>.'),
    tabs=[
        T('Home', 'dashboard', 'DoctorHomeScreen', 'lib/screens/doctor/doctor_home_screen.dart', '—',
          'The dashboard: who they are, the calls waiting today, the sessions they run, and a '
          'way into availability.'),
        T('Appointments', 'event_note', 'DoctorAppointmentsScreen',
          'lib/screens/doctor/doctor_appointments_screen.dart', '—',
          'The practice in one list, in the three buckets a clinic day actually has.',
          blocks=[('Today', 'What is happening now, in order, with Join.'),
                  ('Upcoming', 'Everything after today.'),
                  ('Past', 'Done — and what still needs a prescription written.')]),
        T('Availability', 'schedule', 'DoctorScheduleScreen',
          'lib/screens/doctor/doctor_schedule_screen.dart', '—',
          'One screen for the ordinary case, progressive disclosure for the exceptions. A '
          'doctor whose week is “Mon–Sat, morning and evening clinic” is done in under a minute '
          'and never sees a per-day editor.',
          notes=['Replaced a 7×6 grid of six hardcoded times, in which a doctor working '
                 '10:30–13:00 could not describe their own day.']),
        T('Impact', 'insights', 'DoctorImpactTab', 'lib/screens/doctor/doctor_impact_tab.dart', '—',
          'The Partner Journey Dashboard, with Earnings <b>inside</b> it rather than beside it.',
          notes=['The ordering is the point: a doctor opening this tab sees how many families '
                 'they have helped, and has to <i>choose</i> to look at the money. The two sets '
                 'of numbers are deliberately not merged.']),
        T('Profile', 'person', 'DoctorProfileScreen',
          'lib/screens/doctor/doctor_profile_screen.dart', '—',
          'What the doctor manages about themselves, and the way out of doctor mode back to the '
          'parent app.'),
    ],
)

BARS = [PREG_MOTHER, PREG_FATHER, TTC_V1, TTC_V3, TTC_PARTNER, PARENTING, DOCTOR]


# =============================================================================
#  THE EXPLORE DRAWER — one tap from parenting tab 0, and larger than most tabs
# =============================================================================

EXPLORE = [
    ('Personalize ParentVeda experience', 'FamilyProfileScreen', 'Tune what you see, for your family.'),
    ('Watch', 'WatchHomeScreen', 'Expert videos, chosen for his stage.'),
    ('Health', 'HealthHomeScreen', 'The living health companion — vaccination folded in as a summary.'),
    ('Recipes', 'RecipesExploreScreen', 'Curated by age — browse by meal, not by filter.'),
    ('Recommendations', 'RecoExploreScreen', 'Expert-curated books, toys, activities.'),
    ('Read', 'ReadExploreScreen', 'Vetted reads, by topic and by type.'),
    ('Courses &amp; Masterclasses', 'CoursesExploreScreen', 'Expert-led, vetted for your stage.'),
    ('Yoga &amp; Classes', 'YogaHomeScreen', 'Live &amp; recorded, every stage.'),
    ('My Bookings', 'MyBookingsScreen', 'Classes and sessions, one place.'),
    ('Invite a friend', 'InviteFriendsScreen', 'You both get a free consultation.'),
    ('Your Care Circle', 'CareCircleScreen', 'The people supporting you.'),
    ('Memories', 'MemoriesHomeScreen', 'Cards for the moments that matter.'),
    ('Find help', 'ProblemSolverScreen', 'Vetted local services.'),
    ('Dadi/Nani Nuskhe', 'NuskheScreen', 'Home remedies, safely.'),
    ('Investments &amp; Savings', 'InvestmentsScreen', 'Plan ahead.'),
    ('Astrology &amp; Numerology', 'AstrologyScreen', 'Optional cosmic notes.'),
    ('My Journal V2', 'JournalWelcomeScreen', 'A keepsake storybook.'),
    ('Launches', 'LaunchHubScreen', 'The Launch Hub’s one parenting front door.'),
    ('Brand Studio', 'BrandShowcaseScreen', 'All 15 brand products, walked end to end.'),
    ('Skilling (preview)', 'SkillingPreviewScreen', 'The fourth stage — UI only, nothing behind the doors.'),
    ('Brand Studio (debug)', 'BrandPreviewScreen', 'Debug builds only.'),
]


# =============================================================================
#  THE COMMENTARY — what a reviewer should look at
# =============================================================================

FINDINGS = [
    ('The same five words mean two different things',
     'high',
     '“Prepare” in pregnancy is four category rows: Courses &amp; Cohorts, Birthing Classes, '
     'Yoga, Nutrition. “Prepare” in TTC V1 is nine categories of paid offerings. “Tools” in '
     'pregnancy is a 20-tile grid sorted by stated priorities; “Tools” in TTC is 22 tiles in '
     'four named groups; “Tools” in parenting is seven tracker rows. A woman crossing '
     'TTC → pregnancy → parenting meets the same five labels three times and has to relearn '
     'what is behind two of them. Worth deciding whether that is intended.'),

    ('Three different navigation mechanics under one visual component',
     'high',
     'Pregnancy is an IndexedStack (state survives, back does not step between tabs). TTC and '
     'parenting are pop-then-push (state is rebuilt every entry, back always returns to tab 0). '
     'The doctor app is a setState over five bodies in a completely different bar. The pill '
     '<i>looks</i> identical in the first three, so the difference is invisible until '
     'something depends on it — a half-typed post, a scroll position, an in-progress log.'),

    ('Ask Veda has no permanent home on the parenting side',
     'medium',
     'It lost its tab to Brain Development and now lives on the My Child page and the floating '
     'FAB. The FAB is present, so nothing is unreachable — but the stage that most invites a '
     'question is the one where asking is not on the bar.'),

    ('Every V3 nav change costs an entrance somewhere',
     'high',
     'V3 dropped Calendar and Community and split Prepare; <code>TtcMoreScreen</code> is the '
     'entire compensation, and seven Prepare categories hang off <b>one row</b> in it. The '
     'parity test covers the two homes, not the bars. If a tab is ever added to V3, whatever it '
     'displaces needs an entrance before the change lands — that is the direction that breaks.'),

    ('Eight version toggles, four of them reachable from a bottom tab',
     'medium',
     'Today (Classic|Focus|V3), PP Home (Current|V3), TTC Home (V1|V3), Grow (V1|V2|V3) — plus '
     'Health Wallet, Scans Hub, Shravan and Baby Naming deeper in. Each is a design question '
     'deferred to a runtime switch, and none of them is actually answered: the user still gets '
     'whichever we defaulted to. See <code>docs/FLOW-INVENTORY.md</code>.'),

    ('Testing chrome is still on the bar’s doorstep',
     'low',
     'The Mom&nbsp;|&nbsp;Dad pill floats bottom-right on pregnancy Today (Classic only), the '
     'Classic&nbsp;|&nbsp;V3 pill floats top-right, and the doctor-mode toggle sits in the '
     'community utility row. All three ship in release builds today. They are listed here so '
     'the pre-launch sweep has a list.'),

    ('Nothing floats at a hardcoded offset any more — check new work against that',
     'low',
     'Every floating control used to sit at <code>bottom: 96</code>, which cleared the bar on a '
     'gesture-nav phone and was swallowed by it on a three-button one. <code>pvNavClearance()</code> '
     'is the answer, and it reads <code>viewPadding</code> rather than <code>padding</code> '
     'because an ancestor SafeArea collapses the latter to zero. Anything new in the bottom '
     'strip should use it. (The Mom|Dad pill is a deliberate exception — it was never the '
     'control that got swallowed.)'),
]

RULES = [
    ('Nothing moves when you switch tabs',
     'Every tab is icon-above-label, always, active or not. Two of the three bars used to turn '
     'the active tab into a horizontal pill, so selecting a tab re-flowed the row and the other '
     'four labels slid sideways. The transition is now a colour crossfade and nothing else — '
     'there is no geometry left to animate.'),
    ('No container behind the active tab',
     'Not because Material 3’s pill is bad design, but for two reasons of our own: our labels '
     'are always visible, so the label already says which tab she is on and colour says it '
     'again — a container is a redundant third signal. And <code>action</code> is the only '
     'saturated colour this app spends; a filled violet shape parked on every screen at all '
     'times spends that meaning down to nothing.'),
    ('The inactive label must be readable',
     'It was <code>neutral400</code> — 2.73:1 against the app ground, when WCAG AA asks 4.5:1. '
     'The most-seen text in the entire app was at well under half the required contrast. It is '
     '<code>neutral600</code> now: 5.28:1.'),
    ('Two changes mark the active tab — colour <i>and</i> weight',
     'Never one alone.'),
    ('Labels never hide, never wrap, never go below 11px',
     'And every tab is <code>Expanded</code>, so the row shares its width evenly and cannot '
     'overflow however large the user’s text scale is. A five-tab bar that overflows at 1.3× is '
     'a crash for exactly the person who set it.'),
    ('The bar floats on a tinted shadow',
     'Distinct from the page without a hard border.'),
]


# =============================================================================
#  RENDER
# =============================================================================

STYLE = """
@page { size: A4 portrait; margin: 15mm 13mm 16mm; }
:root{
  --ink:#201c24; --body:#3d3747; --mute:#6f6878; --faint:#9a93a6;
  --line:#e2dde8; --hair:#eeeaf2; --paper:#faf8fb;
  --pv:#6a30b6; --pv-soft:#f3eefa;
  --preg:#6a30b6; --preg-soft:#f3eefa;
  --ttc:#3e6da6;  --ttc-soft:#eef3fa;
  --parent:#9a6a12; --parent-soft:#fbf5e8;
  --dad:#2e5266;  --dad-soft:#eef3f6;
  --doc:#1c6b52;  --doc-soft:#eef7f3;
  --flag:#b3123c; --flag-soft:#fdf0f3;
}
*{box-sizing:border-box}
body{margin:0; color:var(--body); background:#fff;
  font-family:Manrope,-apple-system,"Segoe UI",sans-serif;
  font-size:9.1pt; line-height:1.52;
  -webkit-print-color-adjust:exact; print-color-adjust:exact;}
h1,h2,h3{font-family:Fraunces,Georgia,serif; color:var(--ink); margin:0; font-weight:600}
h1{font-size:31pt; line-height:1.04; letter-spacing:-1pt}
h2{font-size:18pt; line-height:1.1; letter-spacing:-.45pt}
h3{font-size:12.5pt; line-height:1.18; letter-spacing:-.25pt}
h4{font-family:Manrope; font-size:9.6pt; font-weight:800; color:var(--ink); margin:0; letter-spacing:-.1pt}
p{margin:0}
code{font-family:"IBM Plex Mono",Consolas,monospace; font-size:.88em; color:var(--pv);
     background:var(--pv-soft); padding:.5pt 2.5pt; border-radius:2pt}
b{color:var(--ink)}
.break{page-break-before:always}
.keep{page-break-inside:avoid; break-inside:avoid}
.rule{height:1px; background:var(--line); margin:10pt 0}

/* cover */
.cover{height:243mm; display:flex; flex-direction:column; justify-content:center}
.cover .kicker{font-size:8pt; font-weight:800; letter-spacing:2.2pt; text-transform:uppercase; color:var(--pv); margin-bottom:14pt}
.cover h1{margin-bottom:13pt}
.cover .lede{font-size:11.5pt; line-height:1.5; max-width:136mm}
.cover .meta{margin-top:26pt; font-size:8pt; color:var(--mute); line-height:1.9}
.cover .meta b{color:var(--ink)}
.coverstat{display:flex; gap:16pt; margin-top:24pt; flex-wrap:wrap}
.coverstat div{border-left:2px solid var(--pv); padding-left:9pt}
.coverstat .n{font-family:Fraunces,serif; font-size:19pt; color:var(--ink); line-height:1}
.coverstat .l{font-size:7.2pt; text-transform:uppercase; letter-spacing:1pt; color:var(--mute); margin-top:3pt}

.eyebrow{font-size:7pt; font-weight:800; letter-spacing:1.4pt; text-transform:uppercase;
         color:var(--mute); margin:0 0 5pt}

/* the bar strip */
.bar{display:flex; gap:0; border:1px solid var(--line); border-radius:9pt;
     overflow:hidden; margin:10pt 0 0; background:#fff}
.bar div{flex:1; text-align:center; padding:8pt 3pt; border-right:1px solid var(--hair);
         font-size:8pt; font-weight:700; color:var(--mute)}
.bar div:last-child{border-right:none}
.bar div .i{display:block; font-size:6.6pt; letter-spacing:.8pt; text-transform:uppercase;
            color:var(--faint); font-weight:800; margin-bottom:2.5pt}
.bar div.on{color:#fff}

/* section chrome, tinted per stage */
.sec{border-left:3px solid var(--pv); padding-left:11pt; margin-bottom:4pt}
.who{font-size:8.6pt; color:var(--mute); margin-top:6pt}
.mech{background:var(--pv-soft); border-radius:8pt; padding:10pt 12pt; margin-top:11pt; font-size:8.6pt}
.mech .h{font-size:7pt; font-weight:800; letter-spacing:1.2pt; text-transform:uppercase;
         color:var(--pv); margin-bottom:5pt}

/* a tab */
.tab{border:1px solid var(--line); border-radius:10pt; padding:11pt 13pt; margin-top:11pt; background:#fff}
.tab .top{display:flex; align-items:baseline; gap:8pt; margin-bottom:2pt}
.tab .idx{font-family:"IBM Plex Mono",monospace; font-size:8pt; font-weight:700;
          color:#fff; background:var(--pv); border-radius:3pt; padding:1pt 5pt}
.tab .nm{font-family:Fraunces,serif; font-size:13pt; color:var(--ink)}
.tab .cls{font-family:"IBM Plex Mono",monospace; font-size:7.6pt; color:var(--mute)}
.tab .src{font-family:"IBM Plex Mono",monospace; font-size:7.1pt; color:var(--faint); margin-top:1pt}
.tab .lands{margin-top:7pt; font-size:8.9pt}
.sub{font-size:7pt; font-weight:800; letter-spacing:1.2pt; text-transform:uppercase;
     color:var(--faint); margin:10pt 0 5pt}
.blocks div{padding:3.5pt 0; border-top:1px solid var(--hair); font-size:8.5pt}
.blocks div:first-child{border-top:none}
.blocks b{color:var(--ink)}
.goes{display:table; width:100%; border-collapse:collapse}
.goes .r{display:table-row}
.goes .a,.goes .b{display:table-cell; padding:3pt 0; border-top:1px solid var(--hair);
                  font-size:8.4pt; vertical-align:top}
.goes .a{width:36%; padding-right:9pt; color:var(--ink); font-weight:700}
.goes .b{color:var(--body)}
.goes .a:before{content:"› "; color:var(--faint); font-weight:400}
.note{background:var(--paper); border-left:2px solid var(--faint); padding:6pt 9pt;
      margin-top:6pt; font-size:8.2pt; color:var(--body)}

/* explore list */
.exp{display:table; width:100%; border-collapse:collapse}
.exp .r{display:table-row}
.exp .a,.exp .b,.exp .c{display:table-cell; padding:3.2pt 0; border-top:1px solid var(--hair);
                        font-size:8.3pt; vertical-align:top}
.exp .a{width:30%; font-weight:700; color:var(--ink); padding-right:8pt}
.exp .b{width:28%; font-family:"IBM Plex Mono",monospace; font-size:7.3pt;
        color:var(--pv); padding-right:8pt}

/* findings */
.find{border-left:3px solid var(--flag); background:var(--flag-soft);
      border-radius:0 8pt 8pt 0; padding:9pt 12pt; margin-top:10pt}
.find.med{border-left-color:#8a6410; background:#fdf7e9}
.find.low{border-left-color:var(--faint); background:var(--paper)}
.find h4{margin-bottom:4pt}
.find .sev{font-size:6.6pt; font-weight:800; letter-spacing:1.1pt; text-transform:uppercase;
           color:var(--flag); margin-bottom:3pt}
.find.med .sev{color:#8a6410} .find.low .sev{color:var(--mute)}

/* rules list */
.rules div{padding:6pt 0; border-top:1px solid var(--hair); font-size:8.6pt}
.rules div:first-child{border-top:none}

.toc{display:table; width:100%; margin-top:14pt}
.toc .r{display:table-row}
.toc .a,.toc .b{display:table-cell; padding:4pt 0; border-top:1px solid var(--hair); font-size:8.8pt}
.toc .a{width:34%; font-weight:800; color:var(--ink)}
"""

ACCENTS = {'preg': '#6a30b6', 'ttc': '#3e6da6', 'parent': '#9a6a12',
           'dad': '#2e5266', 'doc': '#1c6b52'}
SOFTS = {'preg': '#f3eefa', 'ttc': '#eef3fa', 'parent': '#fbf5e8',
         'dad': '#eef3f6', 'doc': '#eef7f3'}


def bar_strip(bar):
    """The pill itself, drawn as a five-cell strip, tab 0 highlighted."""
    a = ACCENTS[bar['cls']]
    cells = []
    for i, t in enumerate(bar['tabs']):
        on = ' class="on" style="background:%s"' % a if i == 0 else ''
        cells.append('<div%s><span class="i">%d</span>%s</div>' % (on, i, t['label']))
    return '<div class="bar">%s</div>' % ''.join(cells)


def tab_html(bar, i, t):
    a = ACCENTS[bar['cls']]
    out = ['<div class="tab keep">']
    out.append('<div class="top">'
               '<span class="idx" style="background:%s">%d</span>'
               '<span class="nm">%s</span>'
               '<span class="cls">%s</span></div>' % (a, i, t['label'], t['screen']))
    if t['file'] != '—':
        out.append('<div class="src">%s%s</div>'
                   % (t['file'],
                      '  ·  route ' + t['route'] if t['route'] not in ('—',) else ''))
    out.append('<p class="lands">%s</p>' % t['lands'])
    if t['blocks']:
        out.append('<div class="sub">What is on it</div><div class="blocks">')
        for name, desc in t['blocks']:
            out.append('<div><b>%s</b> — %s</div>' % (name, desc))
        out.append('</div>')
    if t['goes']:
        out.append('<div class="sub">Where it goes from here</div><div class="goes">')
        for src, dst in t['goes']:
            out.append('<div class="r"><div class="a">%s</div><div class="b">%s</div></div>'
                       % (src, dst))
        out.append('</div>')
    for n in t['notes']:
        out.append('<div class="note">%s</div>' % n)
    out.append('</div>')
    return ''.join(out)


def bar_html(bar, first=False):
    a, s = ACCENTS[bar['cls']], SOFTS[bar['cls']]
    out = ['<section class="%s">' % ('' if first else 'break')]
    out.append('<div class="sec" style="border-left-color:%s">'
               '<p class="eyebrow" style="color:%s">The bar</p>'
               '<h2>%s</h2>'
               '<p class="who">%s</p></div>' % (a, a, bar['name'], bar['who']))
    out.append(bar_strip(bar))
    out.append('<div class="mech" style="background:%s">'
               '<div class="h" style="color:%s">How a tap moves you</div>%s'
               '<div style="margin-top:7pt;font-size:7.6pt;color:var(--mute)">'
               'Built in <code>%s</code></div></div>'
               % (s, a, bar['mechanic'], bar['built_in']))
    for i, t in enumerate(bar['tabs']):
        out.append(tab_html(bar, i, t))
    out.append('</section>')
    return ''.join(out)


def cover():
    n_bars = len(BARS)
    n_tabs = sum(len(b['tabs']) for b in BARS)
    return (
        '<section class="cover">'
        '<p class="kicker">ParentVeda &middot; navigation review</p>'
        '<h1>The bottom<br>navigation pill,<br>end to end.</h1>'
        '<p class="lede">Every tab on every bar, what it lands on, what is on that screen, '
        'and where each thing goes next — for all three life stages, both partner views, and '
        'the doctor app. Written so a review can be done without opening the app and flipping '
        'four toggles to see all seven.</p>'
        '<div class="coverstat">'
        '<div><div class="n">%d</div><div class="l">Distinct bars</div></div>'
        '<div><div class="n">%d</div><div class="l">Tab entries</div></div>'
        '<div><div class="n">3</div><div class="l">Navigation mechanics</div></div>'
        '<div><div class="n">1</div><div class="l">Shared component</div></div>'
        '</div>'
        '<div class="meta">'
        '<b>Source of truth</b> &nbsp;the repo, not a design file. Every claim names its '
        'file.<br>'
        '<b>Component</b> &nbsp;<code>lib/widgets/pv_nav_bar.dart</code> — PvNavBar, '
        'and the three thin adapters over it<br>'
        '<b>Generated by</b> &nbsp;<code>tools/nav_map.py</code> — regenerate rather than '
        'edit the HTML<br>'
        '<b>Companions</b> &nbsp;docs/APP-FLOW-MAP.pdf (the whole app) · '
        'docs/FLOW-INVENTORY.md (what to design next)'
        '</div></section>' % (n_bars, n_tabs))


def toc():
    rows = []
    for b in BARS:
        rows.append('<div class="r"><div class="a">%s</div>'
                    '<div class="b">%s</div></div>'
                    % (b['name'], ' · '.join(t['label'] for t in b['tabs'])))
    rows.append('<div class="r"><div class="a">Appendix — the Explore drawer</div>'
                '<div class="b">One tap from parenting tab 0, and larger than most tabs</div></div>')
    rows.append('<div class="r"><div class="a">What to look at</div>'
                '<div class="b">Seven things a reviewer should decide on</div></div>')
    return ('<section class="break"><p class="eyebrow">Contents</p>'
            '<h2>Seven bars, and the rules they all obey</h2>'
            '<div class="toc">%s</div>'
            '<div class="sub" style="margin-top:22pt">The rules PvNavBar enforces</div>'
            '<p style="font-size:8.6pt;margin-bottom:8pt">The app had <b>three</b> bottom bars '
            'and each had been fixed once, by a different pass, so each had a different half of '
            'the same fix. A component on every screen of every stage cannot be three '
            'components. They now delegate to one, and differ only in their tabs and their '
            'accent.</p>'
            '<div class="rules">%s</div>'
            '</section>'
            % (''.join(rows),
               ''.join('<div><b>%s.</b> %s</div>' % (h, d) for h, d in RULES)))


def explore_page():
    rows = ''.join('<div class="r"><div class="a">%s</div><div class="b">%s</div>'
                   '<div class="c">%s</div></div>' % r for r in EXPLORE)
    return ('<section class="break"><p class="eyebrow">Appendix</p>'
            '<h2>The Explore drawer</h2>'
            '<p style="margin-top:8pt;font-size:8.9pt">Not a tab, but reachable in one tap from '
            'the hamburger on parenting tab&nbsp;0 — and larger than any tab on any bar. It is '
            'where the parenting stage keeps everything that does not fit five hero slots, and '
            'it is the reason the parenting bar can be five tabs wide without losing features. '
            'Any review of “what can I reach from the pill” has to include it.</p>'
            '<div class="exp" style="margin-top:12pt">%s</div>'
            '<div class="note">Rows commented out rather than deleted, per the repo rule: '
            'My Child (it is the home now), Guided journeys, His journey, Skill Development '
            '(promoted to the <b>Brain</b> tab), Health Guide, Food, the old Recipes and '
            'Recommendations screens, Masterclasses, Cohort Courses, Guides &amp; Tools, '
            'Courses. Each is one uncommented line from coming back.</div>'
            '</section>' % rows)


def findings_page():
    out = ['<section class="break"><p class="eyebrow">Commentary</p>'
           '<h2>What a review should decide on</h2>'
           '<p style="margin-top:8pt;font-size:8.9pt">Everything above is what the app does. '
           'This page is judgement — the seven things worth an argument, written so they can be '
           'agreed or dismissed rather than rediscovered.</p>']
    for title, sev, body in FINDINGS:
        cls = {'high': '', 'medium': ' med', 'low': ' low'}[sev]
        out.append('<div class="find%s keep"><div class="sev">%s</div>'
                   '<h4>%s</h4><p style="margin-top:4pt">%s</p></div>'
                   % (cls, sev, title, body))
    out.append('</section>')
    return ''.join(out)


def build():
    body = ''.join([cover(), toc()]
                   + [bar_html(b) for b in BARS]
                   + [explore_page(), findings_page()])
    out = os.path.join(DOCS, 'BOTTOM-NAV-MAP.html')
    with open(out, 'w', encoding='utf-8') as f:
        f.write('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
                '<title>ParentVeda &mdash; the bottom navigation pill, end to end</title>\n'
                '<style>\n%s\n</style>\n<style>\n%s\n</style>\n</head>\n<body>\n%s\n</body>\n</html>\n'
                % (DM.fonts_css(), STYLE, body))
    return out


def to_pdf(html_path):
    chrome = next((c for c in DM.CHROME_CANDIDATES if os.path.exists(c)), None)
    if not chrome:
        print('  (no Chrome found; HTML only)')
        return None
    pdf = html_path[:-5] + '.pdf'
    subprocess.run([chrome, '--headless=new', '--disable-gpu', '--no-pdf-header-footer',
                    '--virtual-time-budget=20000', '--print-to-pdf=' + pdf,
                    'file:///' + html_path.replace('\\', '/')],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=300)
    return pdf if os.path.exists(pdf) else None


if __name__ == '__main__':
    path = build()
    print('%-34s %7.0f KB' % (os.path.basename(path), os.path.getsize(path) / 1024))
    if '--pdf' in sys.argv:
        pdf = to_pdf(path)
        if pdf:
            print('%-34s %7.0f KB' % (os.path.basename(pdf), os.path.getsize(pdf) / 1024))

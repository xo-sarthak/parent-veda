// =============================================================================
//  Scans & tests — the door
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Scans_and_tests_rebuild.pdf`, 30 Aug 2026. First of
//  the eight pregnancy briefs, and the first pregnancy area to take the
//  five-sub-tab shape the TTC doors use.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THIS REPLACES, AND WHAT IT DOES NOT
//  ---------------------------------------------------------------------------
//
//  The bracket used to open `ScansHubScreen` — a landing reading "Your scans,
//  in one place" over a "What do you need?" list, behind a V1 | V2 pill. V1 was
//  six doors off the reconciliation Excel's six journey steps; V2 was three.
//
//  Both are COMMENTED OUT, not deleted, and `scans_hub_screen.dart`,
//  `scans_hub.dart` and `scans_hub_v2.dart` all still ship. The brief's own
//  instruction — "Remove the three-card landing list; its destinations become
//  tabs" — is about the LANDING, and that is what has gone: the three cards
//  were a menu asking a question she had already answered by tapping the
//  bracket.
//
//  ⚠️ NOTHING BELOW THE LANDING WAS REBUILT. The timeline, the nine scan pages,
//  the locker, the decoder and its twenty-seven findings are the same screens
//  with the same content, reached one tap earlier. The brief says so four
//  times, and it is the single most important constraint on this build: this is
//  a reorganisation of a front door, not a rewrite of a stage.
//
//  ---------------------------------------------------------------------------
//  ⚠️ ASK VEDA IS NOT A CARD HERE, AND THAT IS DELIBERATE
//  ---------------------------------------------------------------------------
//
//  It already exists app-wide — the floating sparkle button and the "Still
//  worried? Ask Veda" prompt at the foot of content pages. The brief is
//  explicit: do not add it as a card, do not build a second entry point, do not
//  change how it looks.
//
//  ⚠️ SO THERE IS NO ASK VEDA TILE ON THIS DOOR, AND THE CONTEXT IS PASSED ONE
//  LEVEL IN — WHICH IS WHERE THE BRIEF ASKS FOR IT. Its words: *"when it is
//  opened from a scan page or a result page, it receives that page's context."*
//  A door is neither of those; it is a landing.
//
//  ⚠️ AND THE FAB CANNOT CARRY THAT CONTEXT. An earlier note here claimed the
//  route name was enough. It is not: `FabRouteObserver` reads route names only
//  to pick WHICH STAGE'S Ask Veda opens — TTC, parenting or pregnancy — and
//  carries no payload. The result half already worked
//  (`ReportArticleScreen._askVeda` passes the finding); the scan half did not
//  exist and was added on `scan_detail_screen.dart`.
//
//  The route names below still matter, for the stage routing and for the
//  suppression list. They are simply not the whole mechanism.
//
//  ---------------------------------------------------------------------------
//  ⚠️ FIVE TABS, AND THE FIRST IS THE DEFAULT
//  ---------------------------------------------------------------------------
//
//    1. My scans          the timeline, and what is next          [tool screen]
//    2. Understand a scan  before you go                          [card rails]
//    3. Understand a result after the report                [search + rails]
//    4. My reports         the locker                             [tool screen]
//    5. Talk               a pinned red flag, then people         [card rails]
//
//  The hues are the app's own and are not invented for this door. 206 is the
//  scans bracket's clinical blue and belongs to My scans; 26, 42 and 344 are
//  `V2BlockHues` values already in use elsewhere in the stage; 160 is the green
//  the cycle report gives a stretch of days, and it is on Talk because it is
//  the one tab that is about a person rather than a document.
// =============================================================================

import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import 'package:flutter/material.dart' show Icons;

import 'pv_door_data.dart';

/// Surfaces this door opens. Resolved by `pv_door_router.dart`.
///
/// ⚠️ CONSTANTS, NOT LITERALS, BECAUSE THESE ARE IDENTITIES. Each one becomes
/// a route NAME, and `global_ask_fab.dart` reads route names to decide which
/// Ask Veda opens. A second copy of the string is a second place for it to
/// drift, and the drift would be invisible — the screen still opens, the FAB
/// just asks the wrong brain.
const String kScansSurfaceTimeline = 'scans/timeline';
const String kScansSurfaceNext = 'scans/next';
const String kScansSurfaceReports = 'scans/reports';
const String kScansSurfaceDecoder = 'scans/decoder';
const String kScansSurfaceParameters = 'scans/parameters';
const String kScansSurfaceUrgent = 'scans/urgent';
const String kScansSurfaceQuestions = 'scans/questions';
const String kScansSurfaceConsult = 'consults';

/// Tab ids. Also constants, for the same reason — a section names its group by
/// string and a typo makes the section render in no tab at all, which looks
/// like nothing.
const String kScansTabMine = 'mine';
const String kScansTabScan = 'scan';
const String kScansTabResult = 'result';
const String kScansTabReports = 'reports';
const String kScansTabTalk = 'talk';

final PvDoorPage kScansDoor = PvDoorPage(
  bracketId: 'pregnancy_scans_tests',

  // ⚠️ THE HUB'S OWN LINE, KEPT VERBATIM. The brief says "Keep the hero 'Your
  // scans, in one place.'" — it is the best copy this area has and it belongs
  // to it. The eyebrow above it is `bracket.label`, so "Scans & tests" is
  // still on screen and the tile she tapped still names where she landed.
  heroTitle: 'Your scans, in one place.',
  heroBlurb: 'What is coming, what you have already had, and what the report '
      'says.',

  // ⚠️ THE PHOTOGRAPH IS BACK, AND THE PROCESS THAT PUT IT THERE IS THE POINT.
  //
  // The first id here was a stock placeholder chosen from a description. On the
  // phone it turned out to be a Western clinic with "UROLOGIC ONCOLOGY BRANCH"
  // legible on the doctor's badge — over the words "Your scans, in one place",
  // on an Indian pregnancy app. It survived `flutter analyze`, the whole suite
  // and a render test, because none of those look at pixels.
  //
  // ⚠️ SO THE RULE IS NOT "NO PHOTOGRAPHS". IT IS "LOOK AT IT FIRST." A drawn
  // placeholder announces itself; a real photograph of the wrong thing does
  // not — it reads as a considered choice at a glance. A photographic
  // placeholder is the one kind of placeholder that can ship a lie, and the
  // only defence is downloading the file and opening it before wiring the URL.
  // Every hero on every pregnancy door was chosen that way on 2026-09-10:
  // fetched, viewed, and two candidates rejected for exactly the fault above.
  //
  // ⚠️ AND THE SUBJECTS ARE CHOSEN TO CARRY NO INSTITUTION. Hands, a bump, a
  // report, a plate — never a building, a badge, a wall poster or a uniform.
  // A photograph with signage in it is a photograph of somebody else's
  // hospital, and there is no crop that makes that ours.
  //
  // This one: a woman holding her scan printout against her bump. It is the
  // exact object this door is about, and there is nothing in the frame that
  // belongs to a country.
  heroImageUrl:
      'https://images.unsplash.com/photo-1654931800911-7a9cfb3b7c17?w=900&h=700&fit=crop',

  // ⚠️ THE TIMELINE'S FULL FOOTER, VERBATIM. The brief says keep that line;
  // the door keeps it here, under every tab, and the embedded timeline no
  // longer draws its own — two copies a centimetre apart was the fault.
  closingLine: 'Not every pregnancy needs every test on this list, and your '
      'doctor may add one that is not here. This is the usual run, not a '
      'rule.',

  groups: [
    // -------------------------------------------------------------------------
    //  1. My scans — the timeline, inline
    // -------------------------------------------------------------------------
    //  ⚠️ THE TIMELINE IS THE TAB, NOT A CARD THAT OPENS THE TAB. The brief
    //  calls this "a tool screen, not a rail", and a card in front of a tool
    //  inside a tab whose whole content is that tool is a door in front of a
    //  door.
    PvDoorGroup(
      id: kScansTabMine,
      label: 'My scans',
      mark: IntentMark.timelineRail,
      icon: Icons.timeline_rounded,
      hue: 206,
      inlineSurfaceId: kScansSurfaceTimeline,
      inlineLabel: 'Your timeline',
      layout: PvDoorLayout.stack,
    ),

    PvDoorGroup(
      id: kScansTabScan,
      label: 'Understand a scan',
      mark: IntentMark.scanFan,
      icon: Icons.menu_book_outlined,
      hue: 26,
    ),

    // -------------------------------------------------------------------------
    //  3. Understand a result — the decoder, inline, then two cards
    // -------------------------------------------------------------------------
    //  ⚠️ BOTH AN INLINE TOOL AND SECTIONS, which is the one tab that needs
    //  both. The brief calls it "search + card rails": the search bar, the
    //  report-type chips and the topic lists are the shipped decoder rendered
    //  in place, and the two cards under them are a rail.
    PvDoorGroup(
      id: kScansTabResult,
      label: 'Understand a result',
      mark: IntentMark.reportPage,
      icon: Icons.description_outlined,
      hue: 344,
      inlineSurfaceId: kScansSurfaceDecoder,
    ),

    PvDoorGroup(
      id: kScansTabReports,
      label: 'My reports',
      mark: IntentMark.chartLog,
      icon: Icons.folder_open_rounded,
      hue: 42,
      inlineSurfaceId: kScansSurfaceReports,
      inlineLabel: 'Your locker',
      layout: PvDoorLayout.stack,
    ),

    // -------------------------------------------------------------------------
    //  5. Talk — the pinned flag, then people
    // -------------------------------------------------------------------------
    //  ⚠️ THE FLAG IS PINNED ABOVE THE RAILS AND NEVER IN AN ACCORDION. The
    //  brief: "Do not bury it." A rail is a browse surface, and a woman
    //  scanning cards for the one that matches her situation has already been
    //  asked to make a choice — this should not wait for one.
    //
    //  ⚠️ AND IT IS ON THIS TAB RATHER THAN ON THE LANDING, WHICH REVERSES V2.
    //  `scans_hub_v2.dart` removed the urgent strip entirely, on the argument
    //  that "nobody discovers an emergency by scrolling" — a records screen
    //  should not be alarming for the thousands of people who are fine.
    //
    //  That argument was about a strip at the TOP OF A LANDING, which every
    //  visitor met before anything else. This is one tab of five, named Talk,
    //  which someone opens because they are already thinking about reaching a
    //  person. The flag is the first thing there because that is the context
    //  in which it is useful, and it is nowhere else on the door — so the
    //  woman who came to check when her next scan is never meets it.
    PvDoorGroup(
      id: kScansTabTalk,
      label: 'Talk',
      mark: IntentMark.askDoctor,
      icon: Icons.chat_bubble_outline_rounded,
      hue: 160,
      pinnedRedFlag: kPregnancyUrgentFlag,
    ),
  ],

  sections: [
    // =========================================================================
    //  SUB-TAB 1 · My scans
    // =========================================================================
    // ⚠️ RETIRED 2026-09-18 — the door walk. The timeline above this section
    // already says what is next and when: the Up-next card names the scan,
    // its window, her date; the run below it ticks what is done. The tool
    // this opened (`ScanNextScreen`: "the one you have done", "what follows",
    // the appointments screen) said the same things a screen deeper, in a
    // smaller font, under a tinted callout. The user: "I don't want to stay
    // on it… what did I even go through so many clicks to read." One place
    // for one fact. `ScanNextScreen` and `kScansSurfaceNext` stay for revert.
    //
    // PvDoorSection(
    //   group: kScansTabMine,
    //   heading: 'What is next',
    //   tiles: [
    //     PvDoorToolTile(
    //       title: 'What is next, and when',
    //       blurb: 'Opens the page for the scan you have coming up.',
    //       surfaceId: kScansSurfaceNext,
    //     ),
    //   ],
    // ),

    // =========================================================================
    //  SUB-TAB 2 · Understand a scan — before you go
    // -------------------------------------------------------------------------
    //  ⚠️ EVERY ONE OF THESE NINE IS REUSE. They open the scan pages the stage
    //  already ships — video, what it is, what it checks, what happens, how to
    //  prepare, the red flags, the parameter table, the disclaimer. Not one
    //  word of that content is rewritten here.
    //
    //  ⚠️ THE TITLES ARE THE MEDICAL NAMES AND THE BLURBS ARE NOT. That is the
    //  brief's central language rule and it cuts both ways: "NT scan" stays,
    //  because that is what is printed on her slip and she has to match the
    //  card to her paper — and the line under it says what it actually does,
    //  in words she would use. Six of the nine blurbs are given verbatim in
    //  the brief; the three that are not are written to the same pattern.
    // =========================================================================
    PvDoorSection(
      group: kScansTabScan,
      heading: 'First three months',
      tiles: [
        PvDoorEntryTile(
          title: 'Blood tests',
          blurb: 'The first set of blood tests, and what each one is for.',
          library: PvDoorLibrary.scan,
          entryId: 'blood_tests',
          meta: 'Weeks 6–10',
        ),
        PvDoorEntryTile(
          title: 'Dating scan',
          blurb: 'Confirms how many weeks you are, and your due date.',
          library: PvDoorLibrary.scan,
          entryId: 'dating_scan',
          meta: 'Weeks 6–9',
        ),
        PvDoorEntryTile(
          title: 'NT scan',
          blurb: "Checks the baby's early growth and development.",
          library: PvDoorLibrary.scan,
          entryId: 'nt_scan',
          meta: 'Weeks 11–13',
        ),
        PvDoorEntryTile(
          title: 'NIPT',
          blurb: 'A blood test that checks for some conditions early.',
          library: PvDoorLibrary.scan,
          entryId: 'nipt',
          meta: 'Weeks 10–14',
        ),
      ],
    ),

    PvDoorSection(
      group: kScansTabScan,
      heading: 'Middle three months',
      tiles: [
        PvDoorEntryTile(
          title: 'Anomaly scan',
          blurb: 'The detailed scan that checks the baby from head to toe.',
          library: PvDoorLibrary.scan,
          entryId: 'anomaly_scan',
          meta: 'Weeks 18–22',
        ),
        PvDoorEntryTile(
          title: 'Sugar test (OGTT)',
          blurb: 'Checks for pregnancy diabetes.',
          library: PvDoorLibrary.scan,
          entryId: 'ogtt',
          meta: 'Weeks 24–28',
        ),
      ],
    ),

    PvDoorSection(
      group: kScansTabScan,
      heading: 'Last three months',
      tiles: [
        PvDoorEntryTile(
          title: 'Growth scan',
          blurb: 'Checks how the baby is growing, and how much fluid there is.',
          library: PvDoorLibrary.scan,
          entryId: 'growth_scan',
          meta: 'Weeks 28–36',
        ),
        PvDoorEntryTile(
          title: 'Doppler scan',
          blurb: 'Checks the blood flow to the baby.',
          library: PvDoorLibrary.scan,
          entryId: 'doppler',
          meta: 'Weeks 30–40',
        ),
        PvDoorEntryTile(
          title: 'Group B Strep',
          blurb: 'A swab that checks for a common bacteria before birth.',
          library: PvDoorLibrary.scan,
          entryId: 'gbs',
          meta: 'Weeks 35–37',
        ),
      ],
    ),

    PvDoorSection(
      group: kScansTabScan,
      heading: 'Before any scan',
      tiles: [
        // ⚠️ REUSE, AND IT HAS NO CONTENT BEHIND IT YET. `content_slots.dart`
        // declares this piece for this bracket and nothing has been written.
        // The brief marks it COMING SOON rather than dropping it, which is
        // right: the card holds its place at full size, so nothing on the rail
        // moves the day the piece lands.
        PvDoorReadTile.comingSoon(
          title: 'What the scan person can and cannot tell you',
          blurb: 'Why they go quiet, and who gives you the result.',
        ),
        PvDoorGuideTile(
          title: 'Why nobody will tell you the sex',
          blurb: 'It is the law, not the clinic being unkind.',
          readId: 'preg_scan_read_sex_law',
        ),
        PvDoorGuideTile(
          title: 'What scans cost in India',
          blurb: 'Real ranges, and why the same scan costs more across town.',
          readId: 'preg_scan_read_costs',
        ),
        PvDoorMythTile(
          title: 'Do I need every scan on the list?',
          blurb: 'The timeline is the usual run, not a rule.',
          readId: 'preg_scan_read_every_scan',
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 3 · Understand a result — after the report
    // =========================================================================
    PvDoorSection(
      group: kScansTabResult,
      heading: 'When a word does not make sense',
      tiles: [
        // ⚠️ IT OPENS THE DECODER'S SEARCH, NOT THE DECODER. The decoder is
        // already on screen above this card — its chips and its topic lists
        // are the tab. A card that opened the same screen again would be a
        // link to where she is standing.
        //
        // The brief marks this "[Read] reuse", and the thing being reused is
        // the shipped `_ReportSearchDelegate`: type a word, get the topic.
        // ⚠️ RETIRED 2026-09-19 — the user's review: this card opened the
        // decoder as its own screen — the same Popular / More topics list
        // the tab above it already IS. "Repetitive and useless." The read
        // beside it stays. Kept for revert:
        // PvDoorReadTile(
        //   title: 'A word on the report you do not know',
        //   blurb: 'Look it up, see what it may mean, and what to ask.',
        //   surfaceId: kScansSurfaceDecoder,
        // ),
        PvDoorGuideTile(
          title: 'Reading a report without panicking',
          blurb: 'One reading is one moment, not a verdict.',
          readId: 'preg_scan_read_calm',
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 4 · My reports
    // -------------------------------------------------------------------------
    //  ⚠️ "Add a report" IS NOT A CARD HERE. The brief lists it as a [Tool],
    //  and the locker rendered above already carries its own add button — a
    //  card whose tap does what the button six points above it does is the
    //  door-in-front-of-a-door again. The locker IS "Add a report".
    //
    //  ⚠️ "Your report, line by line" IS RESLOTTED, NOT REBUILT. It is the same
    //  parameter table the scan pages open, reached from here as well. Single
    //  source, shown twice, never copied — the brief says so in two separate
    //  places and it is the one rule on this tab with teeth.
    // =========================================================================
    PvDoorSection(
      group: kScansTabReports,
      heading: 'Make sense of what is in there',
      tiles: [
        // ⚠️ RETIRED 2026-09-18 — the door walk. Every scan's own read now
        // carries "What the report will say" (its parameters, usual range,
        // low/high) and "How to read the result" — `pvReadFromScan`. The
        // old tool (`TestsScansReportsScreen`) listed the same parameters
        // on a separate violet page, one library deep. One home per fact.
        // The tile, the surface id and the screen stay for revert.
        //
        // PvDoorToolTile(
        //   title: 'Your report, line by line',
        //   blurb: 'Every reading, the usual range, and what it means when '
        //       'yours sits outside it.',
        //   surfaceId: kScansSurfaceParameters,
        // ),
        PvDoorGuideTile(
          title: 'What to keep, and why',
          blurb: 'The six pieces of paper that matter later.',
          readId: 'preg_scan_read_keep',
        ),
        PvDoorGuideTile(
          title: 'Take it to your appointment',
          blurb: 'What to carry, and how to use ten minutes well.',
          readId: 'preg_scan_read_take_along',
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 5 · Talk
    // =========================================================================
    // One section, two cards (2026-09-18): two headings over one card each
    // read as two shelves with nothing on them. "Before your appointment"
    // is what both cards are for.
    PvDoorSection(
      group: kScansTabTalk,
      heading: 'Before your appointment',
      tiles: [
        PvDoorChecklistTile(
          title: 'What to ask at your next scan',
          blurb: 'Tick what matters to you, and take the list in with you.',
          surfaceId: kScansSurfaceQuestions,
        ),
        PvDoorTalkTile(
          title: 'Have a doctor go through it with you',
          blurb: 'Book a 1:1 with a gynaecologist and ask about your report.',
          surfaceId: kScansSurfaceConsult,
        ),
      ],
    ),
  ],
);

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
//  change how it looks. The only thing owed is that when it is opened from a
//  scan page or a result page it receives that page's context, which
//  `global_ask_fab.dart` already does by reading the route name — which is why
//  every surface below is opened with `RouteSettings(name:)` set.
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

  // ⚠️ A PLACEHOLDER PHOTOGRAPH, TO BE SWAPPED. Same shape the TTC doors use.
  // The V3 field and the bracket mark render behind it, so a dead connection
  // gives the hero this area has always had rather than a grey box — local-
  // first is absolute.
  heroImageUrl:
      'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=900&h=700&fit=crop',

  closingLine: 'Not every pregnancy needs every test. This is the usual run, '
      'not a rule.',

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
      icon: Icons.timeline_rounded,
      hue: 206,
      inlineSurfaceId: kScansSurfaceTimeline,
      inlineLabel: 'Your timeline',
      layout: PvDoorLayout.stack,
    ),

    PvDoorGroup(
      id: kScansTabScan,
      label: 'Understand a scan',
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
      icon: Icons.description_outlined,
      hue: 344,
      inlineSurfaceId: kScansSurfaceDecoder,
    ),

    PvDoorGroup(
      id: kScansTabReports,
      label: 'My reports',
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
      icon: Icons.chat_bubble_outline_rounded,
      hue: 160,
      pinnedRedFlag: kPregnancyUrgentFlag,
    ),
  ],

  sections: [
    // =========================================================================
    //  SUB-TAB 1 · My scans
    // =========================================================================
    PvDoorSection(
      group: kScansTabMine,
      heading: 'What is next',
      tiles: [
        PvDoorToolTile(
          title: 'What is next, and when',
          blurb: 'Opens the page for the scan you have coming up.',
          surfaceId: kScansSurfaceNext,
        ),
      ],
    ),

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
        PvDoorScanTile(
          title: 'Blood tests',
          blurb: 'The first set of blood tests, and what each one is for.',
          scanId: 'blood_tests',
        ),
        PvDoorScanTile(
          title: 'Dating scan',
          blurb: 'Confirms how many weeks you are, and your due date.',
          scanId: 'dating_scan',
        ),
        PvDoorScanTile(
          title: 'NT scan',
          blurb: "Checks the baby's early growth and development.",
          scanId: 'nt_scan',
        ),
        PvDoorScanTile(
          title: 'NIPT',
          blurb: 'A blood test that checks for some conditions early.',
          scanId: 'nipt',
        ),
      ],
    ),

    PvDoorSection(
      group: kScansTabScan,
      heading: 'Middle three months',
      tiles: [
        PvDoorScanTile(
          title: 'Anomaly scan',
          blurb: 'The detailed scan that checks the baby from head to toe.',
          scanId: 'anomaly_scan',
        ),
        PvDoorScanTile(
          title: 'Sugar test (OGTT)',
          blurb: 'Checks for pregnancy diabetes.',
          scanId: 'ogtt',
        ),
      ],
    ),

    PvDoorSection(
      group: kScansTabScan,
      heading: 'Last three months',
      tiles: [
        PvDoorScanTile(
          title: 'Growth scan',
          blurb: 'Checks how the baby is growing, and how much fluid there is.',
          scanId: 'growth_scan',
        ),
        PvDoorScanTile(
          title: 'Doppler scan',
          blurb: 'Checks the blood flow to the baby.',
          scanId: 'doppler',
        ),
        PvDoorScanTile(
          title: 'Group B Strep',
          blurb: 'A swab that checks for a common bacteria before birth.',
          scanId: 'gbs',
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
        PvDoorReadTile(
          title: 'A word on the report you do not know',
          blurb: 'Look it up, see what it may mean, and what to ask.',
          surfaceId: kScansSurfaceDecoder,
        ),
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
        PvDoorToolTile(
          title: 'Your report, line by line',
          blurb: 'Every reading, the usual range, and what it means when '
              'yours sits outside it.',
          surfaceId: kScansSurfaceParameters,
        ),
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
    PvDoorSection(
      group: kScansTabTalk,
      heading: 'Talk to someone',
      tiles: [
        PvDoorTalkTile(
          title: 'Have a doctor go through it with you',
          blurb: 'Book a 1:1 with a gynaecologist and ask about your report.',
          surfaceId: kScansSurfaceConsult,
        ),
      ],
    ),

    PvDoorSection(
      group: kScansTabTalk,
      heading: 'Before your appointment',
      tiles: [
        PvDoorChecklistTile(
          title: 'What to ask at your next scan',
          blurb: 'Tick what matters to you, and take the list in with you.',
          surfaceId: kScansSurfaceQuestions,
        ),
      ],
    ),
  ],
);

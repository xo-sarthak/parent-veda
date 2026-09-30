// =============================================================================
//  Complications & conditions — the door
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Complications_rebuild_clean.pdf`, 30 Aug 2026. Second
//  of the eight pregnancy briefs.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE LANGUAGE RULE IS STRICTER HERE THAN ANYWHERE ELSE IN THE APP
//  ---------------------------------------------------------------------------
//
//  The brief states it exactly: *"A medical name appears ONLY as the title of a
//  condition page, because that is what a user matches to their doctor's words.
//  Directly under that title sits one plain line saying what it is. Every OTHER
//  heading, label, section name and card we write has no jargon at all. In a
//  browse list, the plain line leads and the medical name follows in brackets,
//  not the other way round."*
//
//  So every card title below reads "Pregnancy sugar goes high (gestational
//  diabetes)" and never the reverse. The page it opens is still titled
//  "Gestational diabetes", which is where a name belongs — that is the word on
//  her prescription. `ConditionEntry.plainLine` is the line under it, and
//  `test/pv_door_complications_test.dart` holds every one of them.
//
//  ⚠️ THIS IS THE ONE PLACE A DOOR TITLE MAY CARRY A MEDICAL WORD AT ALL, and
//  only in brackets, and only second.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SINGLE SOURCE, READ CORRECTLY
//  ---------------------------------------------------------------------------
//
//  The brief: *"this area OWNS every condition. Other areas link to these
//  pages. Never keep a second copy of a condition anywhere."*
//
//  Taken literally that collides with a fact of the codebase: `kAllConditions`
//  and `kReportFindings` both exist, ~11 subjects appear in both, and two cards
//  this brief names by hand — "Cord looped around the neck" and "Placenta
//  sitting low" — exist ONLY as findings.
//
//  The rule as applied, decided 2026-09-10 and written up in
//  `docs/PREGNANCY-DOOR-BUILD.md` §4a: **one page per QUESTION, not one page
//  per word.** `kAllConditions` answers "my doctor said I have X";
//  `kReportFindings` answers "my report says X". Two questions, two pages, and
//  never a second copy of the same ANSWER.
//
//  So Sub-tab 2 links across for those two, using `PvDoorFindingTile`. Copying
//  the entries between the files is the one thing §4a forbids outright.
//
//  ---------------------------------------------------------------------------
//  ⚠️ FIVE TABS, AND THE FIRST IS THE DEFAULT
//  ---------------------------------------------------------------------------
//
//    1. Find a condition      search, chip, most common     [search screen]
//    2. When it usually comes up  browse without the name   [card rails]
//    3. Get help now          the safety tab                [pinned + rails]
//    4. Living with it        the day to day                [card rails]
//    5. Talk                  a pinned flag, then people    [card rails]
//
//  186 is the bracket's own teal. The other four hues are `V2BlockHues` values
//  already in use elsewhere in the stage; 344 is on "Get help now" because it
//  is the closest thing the grid has to an alarm without being a red.
// =============================================================================

import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import 'package:flutter/material.dart' show Icons;

import 'pv_door_data.dart';

/// Surfaces this door opens. Constants because each becomes a route NAME, and
/// `global_ask_fab.dart` reads route names.
const String kCondSurfaceFind = 'conditions/find';
const String kCondSurfaceSameDay = 'conditions/same_day';
const String kCondSurfaceJourney = 'conditions/journey';
const String kCondSurfaceQuestions = 'conditions/questions';
const String kCondSurfaceUrgent = 'scans/urgent';
const String kCondSurfaceConsult = 'consults';

/// ⚠️ IT POINTS AT THE SCANS DOOR'S LOCKER, ON PURPOSE. The brief's own words
/// for the card: *"'Keep your reports for this' links to My reports in Scans
/// (single source)."* One locker, reached from two doors — which is the same
/// rule as the conditions themselves, pointing the other way.
const String kCondSurfaceReports = 'scans/reports';

const String kCondTabFind = 'find';
const String kCondTabWhen = 'when';
const String kCondTabHelp = 'help';
const String kCondTabLiving = 'living';

/// The After a loss door, from Living with it (2026-09-29, pregnancy gap
/// analysis, "Give miscarriage and stillbirth a proper home").
const String kCondSurfaceAfterLoss = 'conditions/after_loss';

/// The blood pressure and sugar log (2026-09-30, gap analysis P2): her numbers, next to
/// the door that explains them.
const String kCondSurfaceReadings = 'conditions/readings';
const String kCondTabTalk = 'talk';

final PvDoorPage kComplicationsDoor = PvDoorPage(
  bracketId: 'pregnancy_complications',

  heroTitle: 'What your doctor is managing.',
  // Rewritten 2026-09-29 to docs/PREG-VOICE.md.
  heroBlurb: 'Every condition in plain words: what it is, what happens next, '
      'and when to call.',

  // ⚠️ THE QUIETEST PHOTOGRAPH OF THE FIVE, ON PURPOSE. This is the door about
  // things that can go wrong, and the picture at the top of it is doing tone
  // before it does subject. A clinical scene here — a cuff, a machine, a
  // uniform — would put a woman who came in worried in front of a picture of
  // being ill.
  //
  // So: hands resting on a bump in window light, black and white, nobody's
  // face, nothing in the frame that belongs to a hospital. Chosen by looking
  // at it; two candidates for this slot were rejected first, one a US clinic
  // with a wall poster and a lab brand legible in it. See
  // `pv_door_scans.dart` for why that is the failure that matters.
  heroImageUrl:
      'https://images.unsplash.com/photo-1704388159994-98f3889483e8?w=900&h=700&fit=crop',

  // ⚠️ THE FRAME LINE FROM THE CONDITION PAGES, AT THE FOOT OF THE DOOR. Every
  // condition page opens with "This helps you understand what your doctor is
  // managing. It does not replace them." The brief says that line stays
  // untouched, and a door that leads to twenty-seven of those pages should say
  // the same thing before she gets there.
  closingLine: 'This helps you understand what your doctor is managing. It '
      'does not replace them.',

  groups: [
    // -------------------------------------------------------------------------
    //  1. Find a condition — the search screen, inline
    // -------------------------------------------------------------------------
    //  ⚠️ THE SEARCH SCREEN IS THE TAB, NOT A CARD THAT OPENS IT. The brief
    //  calls it "a search screen, NOT a rail", and the search bar, the "My
    //  doctor told me" chip and the Most-common list ARE that tab.
    //
    //  ⚠️ AND THE TWO-WAY DOOR COMES WITH IT. `_DoorGate` asks whether this
    //  visit is diagnosed-real or curiosity, and the answer changes what the
    //  area offers. Rendering the browse without it would let the door bypass a
    //  question the screen exists to ask.
    PvDoorGroup(
      id: kCondTabFind,
      label: 'Find a condition',
      mark: IntentMark.scanFan,
      icon: Icons.search_rounded,
      hue: 186,
      inlineSurfaceId: kCondSurfaceFind,
      inlineLabel: 'Search',
      layout: PvDoorLayout.stack,
    ),

    PvDoorGroup(
      id: kCondTabWhen,
      label: 'When it comes up',
      mark: IntentMark.calendarDay,
      icon: Icons.calendar_month_outlined,
      hue: 26,
      note: 'Nobody gets all of these, and most pregnancies get none. This is '
          "when each one tends to show up. It isn't a list to expect.",
    ),

    // -------------------------------------------------------------------------
    //  3. Get help now — the safety tab
    // -------------------------------------------------------------------------
    //  ⚠️ THE PINNED FLAG HERE IS THE ASSEMBLED ONE, NOT THE SCANS LIST. See
    //  `same_day_signs_data.dart`: five plain lines, each drawn from a
    //  condition's own CALL NOW section, each opening that page. The brief is
    //  emphatic that it is assembled and never authored.
    PvDoorGroup(
      id: kCondTabHelp,
      label: 'Get help now',
      mark: IntentMark.nextStep,
      icon: Icons.emergency_outlined,
      hue: 344,
      pinnedRedFlag: kSameDayFlag,
    ),

    PvDoorGroup(
      id: kCondTabLiving,
      label: 'Living with it',
      mark: IntentMark.moodArc,
      icon: Icons.wb_sunny_outlined,
      hue: 42,
    ),

    // -------------------------------------------------------------------------
    //  5. Talk
    // -------------------------------------------------------------------------
    //  ⚠️ THE GENERAL PREGNANCY FLAG, WHICH IS THE ONE THE BRIEF MEANS BY
    //  "When to call your doctor" [Red flag] reuse. Get-help-now carries the
    //  assembled condition list; this carries the stage's standing one, which
    //  is the same object the Scans door pins. Two flags on one door, and they
    //  are not the same list — one is about conditions, one is about pregnancy.
    PvDoorGroup(
      id: kCondTabTalk,
      label: 'Talk',
      mark: IntentMark.askDoctor,
      icon: Icons.chat_bubble_outline_rounded,
      hue: 160,
      // No second flag (2026-09-19): "Get help now" is this door's warning,
      // one tab over; the scans list repeated here read as the same thing
      // twice. Kept for revert: pinnedRedFlag: kPregnancyUrgentFlag,
    ),
  ],

  sections: [
    // =========================================================================
    //  SUB-TAB 1 · Find a condition
    // -------------------------------------------------------------------------
    //  No cards. The brief lists three things for this tab and all three —
    //  search, the chip, the Most-common list — are the inline screen. Adding a
    //  card beside them would be a fourth thing the brief did not ask for.
    // =========================================================================

    // =========================================================================
    //  SUB-TAB 2 · When it usually comes up
    // -------------------------------------------------------------------------
    //  ⚠️ LINKS, NOT COPIES. Every tile here opens a page that already exists;
    //  the brief says "group by linking" and the DO NOT list repeats it.
    // =========================================================================
    // ⚠️ THE WEEK WINDOW ON EVERY TILE — 2026-09-19, for symmetry with Scans
    // & tests, whose cards carry "Weeks 11–13". This tab is the one place
    // the library is read by TIME ("what could come up at week 24?"), which
    // Find a condition (by commonness) does not answer — so it earns the
    // second listing only if it says when. The windows are the usual ones
    // the reads state; a doctor's own timing wins.
    PvDoorSection(
      group: kCondTabWhen,
      heading: 'Early months',
      tiles: [
        PvDoorEntryTile(
          title: 'Pregnancy in the wrong place (ectopic)',
          blurb: "Rare and urgent, and treatable when it's caught early.",
          library: PvDoorLibrary.condition,
          entryId: 'ectopic',
          meta: 'Weeks 5 to 10',
        ),
        PvDoorEntryTile(
          title: 'Severe vomiting (hyperemesis)',
          blurb: 'Much worse than ordinary morning sickness, and treatable.',
          library: PvDoorLibrary.condition,
          entryId: 'hyperemesis',
          meta: 'Weeks 6 to 16',
        ),
        PvDoorEntryTile(
          title: 'Thyroid gland off (thyroid in pregnancy)',
          blurb: 'Common in India, and fixed with a daily tablet.',
          library: PvDoorLibrary.condition,
          entryId: 'thyroid',
          meta: 'First booking bloods',
        ),
        PvDoorEntryTile(
          title: 'Low blood, low iron (anemia)',
          blurb: 'The most common finding in an Indian pregnancy.',
          library: PvDoorLibrary.condition,
          entryId: 'anemia',
          meta: 'Any time · checked at 8 and 28 weeks',
        ),
      ],
    ),

    PvDoorSection(
      group: kCondTabWhen,
      heading: 'Middle months',
      tiles: [
        PvDoorEntryTile(
          title: 'Pregnancy sugar goes high (gestational diabetes)',
          blurb: 'Usually no symptoms at all, which is why everyone is tested.',
          library: PvDoorLibrary.condition,
          entryId: 'gdm',
          meta: 'Weeks 24 to 28 (OGTT)',
        ),
        // ⚠️ THE FINDINGS LIBRARY, AND IT IS THE RULE WORKING. There is no
        // low-lying placenta in `kAllConditions` — the nearest entry is
        // `placenta_previa`, which is the more serious version and a different
        // page. Linking to the finding is honest; copying it here is what §4a
        // forbids.
        PvDoorEntryTile(
          title: 'Placenta sitting low (low-lying placenta)',
          blurb: 'Common at the mid-pregnancy scan, and it usually moves up.',
          library: PvDoorLibrary.finding,
          entryId: 'low_lying_placenta',
          meta: 'Weeks 18 to 22 (anomaly scan)',
        ),
        PvDoorEntryTile(
          title: 'PCOS in pregnancy',
          blurb: 'Something you had before, watched a little more closely now.',
          library: PvDoorLibrary.condition,
          entryId: 'pcos',
          meta: 'Watched from the start',
        ),
      ],
    ),

    PvDoorSection(
      group: kCondTabWhen,
      heading: 'Later months',
      tiles: [
        PvDoorEntryTile(
          title: 'Blood pressure needs watching (high BP)',
          blurb: 'Mostly managed with closer check-ups, sometimes a tablet.',
          library: PvDoorLibrary.condition,
          entryId: 'high_bp',
          meta: 'After week 20',
        ),
        PvDoorEntryTile(
          title: 'Baby lying feet-down (breech)',
          blurb: "Common until late on, and there's time for your baby to turn.",
          library: PvDoorLibrary.condition,
          entryId: 'breech',
          meta: 'Weeks 32 to 36',
        ),
        PvDoorEntryTile(
          title: 'Less water around the baby (low fluid)',
          blurb: 'Found on a scan, and watched with more scans.',
          library: PvDoorLibrary.condition,
          entryId: 'low_amniotic_fluid',
          meta: 'Weeks 28 to 40',
        ),
        // ⚠️ FINDINGS AGAIN, and the brief names this card by hand. Cord around
        // the neck exists only as something a report says — no condition page
        // was ever written for it, and one written now would be a second copy
        // of an answer that already exists.
        PvDoorEntryTile(
          title: 'Cord looped around the neck (cord around neck)',
          blurb: 'Very common, and usually not a problem at all.',
          library: PvDoorLibrary.finding,
          entryId: 'nuchal_cord',
          meta: 'Later scans',
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 3 · Get help now
    // =========================================================================
    PvDoorSection(
      group: kCondTabHelp,
      heading: 'Know these three',
      tiles: [
        PvDoorGuideTile(
          title: 'When blood pressure gets dangerous',
          blurb: 'The signs that mean today, not your next appointment.',
          readId: 'preg_cond_read_bp_dangerous',
        ),
        PvDoorGuideTile(
          title: 'Bleeding in pregnancy',
          blurb: "What's usually fine, what isn't, and why you call either "
              'way.',
          readId: 'preg_cond_read_bleeding',
        ),
        PvDoorGuideTile(
          title: 'When the baby moves less',
          blurb: "Don't wait, and don't count first.",
          readId: 'preg_cond_read_less_movement',
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 4 · Living with it
    // =========================================================================
    PvDoorSection(
      group: kCondTabLiving,
      heading: 'The day to day',
      tiles: [
        PvDoorGuideTile(
          title: 'Handling pregnancy sugar in India',
          blurb: 'Rice, roti and festivals: what shifts the numbers.',
          readId: 'preg_cond_read_sugar_india',
        ),
        PvDoorGuideTile(
          title: 'The daily thyroid tablet',
          blurb: 'When to take it, and what stops it working.',
          readId: 'preg_cond_read_thyroid_tablet',
        ),
        PvDoorGuideTile(
          title: 'Iron, from food and tablets',
          blurb: 'Why they upset your stomach, and what helps them work.',
          readId: 'preg_cond_read_iron',
        ),
      ],
    ),

    // Added 2026-09-29 (pregnancy gap analysis, Complications › Living with
    // it, P2 and P3): being told "high risk", being told to rest, and a first
    // page for a disability or long-term illness. Three reads, one rail.
    PvDoorSection(
      group: kCondTabLiving,
      heading: 'When you need extra care',
      tiles: [
        PvDoorGuideTile(
          title: "Told you're high risk?",
          blurb: 'What the label means, and what changes in your care.',
          readId: 'preg_cond_read_high_risk',
        ),
        PvDoorGuideTile(
          title: 'Told to rest',
          blurb: 'What rest usually means, and how to keep moving safely.',
          readId: 'preg_cond_read_bed_rest',
        ),
        PvDoorGuideTile(
          title: 'With a disability or long-term illness',
          blurb: 'Care that fits you, from appointments to the birth.',
          readId: 'preg_cond_read_disability',
        ),
      ],
    ),

    // The readings log (gap analysis, P2): "her readings live next to the door
    // that explains them". One screen; the Tools list opens the same one.
    PvDoorSection(
      group: kCondTabLiving,
      heading: 'Keep your numbers',
      tiles: [
        PvDoorToolTile(
          title: 'Blood pressure and sugar log',
          blurb: 'Note each reading your doctor asked you to check, and take '
              'them to your next visit.',
          surfaceId: kCondSurfaceReadings,
        ),
      ],
    ),

    // The facts stay on the condition pages; everything after a loss lives
    // in its own door (gap analysis, P1). Last on the tab, and quiet.
    PvDoorSection(
      group: kCondTabLiving,
      heading: 'If your pregnancy has ended',
      tiles: [
        PvDoorToolTile(
          title: 'After a loss',
          blurb: 'Your body, what happened, support for you both, and '
              'trying again when you are ready.',
          surfaceId: kCondSurfaceAfterLoss,
        ),
      ],
    ),

    // ⚠️ RETIRED 2026-09-19 — the door walk. "Add a condition to my journey"
    // opened the Find tab as a screen (the same list, one deeper); "Keep
    // your reports for this" opened the Scans locker. Both are a tap away
    // in their own homes, and "Add to my journey" is on every condition
    // page now. One home per fact. Kept for revert:
    // PvDoorSection(
    //   group: kCondTabLiving,
    //   heading: 'Keep track of it',
    //   tiles: [
    //     PvDoorToolTile(
    //       title: 'Add a condition to my journey',
    //       blurb: 'Put it on your own list, so it is the first thing here next '
    //           'time.',
    //       surfaceId: kCondSurfaceJourney,
    //     ),
    //     // ⚠️ ONE LOCKER, TWO DOORS. The brief's own instruction: link to My
    //     // reports in Scans, single source. A second locker here would be two
    //     // places a report could be and one place she would look.
    //     PvDoorToolTile(
    //       title: 'Keep your reports for this',
    //       blurb: 'Your report locker, in Scans & tests. A photo is enough.',
    //       surfaceId: kCondSurfaceReports,
    //     ),
    //   ],
    // ),
    // 
    // // =========================================================================
    // //  SUB-TAB 5 · Talk

    // =========================================================================
    // One section, two cards (2026-09-19) — as on Scans & tests.
    PvDoorSection(
      group: kCondTabTalk,
      heading: 'Before your appointment',
      tiles: [
        PvDoorChecklistTile(
          title: 'What to ask about your condition',
          blurb: 'Tick what matters to you, and take the list in with you.',
          surfaceId: kCondSurfaceQuestions,
        ),
        PvDoorTalkTile(
          title: 'Have a doctor explain your condition',
          blurb: 'Book a 1:1 with a gynaecologist and go through it together.',
          surfaceId: kCondSurfaceConsult,
        ),
      ],
    ),
  ],
);

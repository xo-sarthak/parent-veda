// =============================================================================
//  Your first weeks: the door
// -----------------------------------------------------------------------------
//  Built 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Your first weeks", P2: *"Our doors assume she
//  is further along."* Our weekly reads started with morning sickness and the
//  first scan; nothing met a woman on the day of a positive test. The
//  analysis asks for what to change today, the first doctor's visit, early
//  worries (spotting, cramps, no symptoms) and telling people.
//
//  Same shape as the other pregnancy doors (`pv_door_scans.dart` is the
//  benchmark; `pv_door_move.dart` is the nearest model): a hero, tabs, rails
//  of cards, a closing line.
//
//  ---------------------------------------------------------------------------
//  ⚠️ FOUR TABS, IN THE ORDER SHE LIVES THEM
//  ---------------------------------------------------------------------------
//
//    1. Just found out    what to do this week, the first trimester, due date
//    2. Your first visit  choosing care, the visit, questions, IVF or a loss
//    3. Early worries     spotting, cramps, no symptoms, sickness, a faint
//                         line, anxiety; the hospital signs pinned on top
//    4. Telling people    when, family, an older child, work
//
//  ⚠️ THE FIRST VISIT IS NOT WRITTEN TWICE. Scans & tests already owns "Your
//  first antenatal visit, and the ones after" (`preg_scan_read_first_visit`).
//  The tile here opens THAT read; this door's own reads go around it (the
//  questions to ask, the first visit after IVF or a loss). The same goes for
//  the hCG read, morning sickness, the first trimester, the PCPNDT read, the
//  next-pregnancy read from After a loss, and two reads written in parallel
//  the same day: telling your boss (Work & money) and telling an older child
//  (Getting ready). One read, many doors.
//
//  ⚠️ THE EARLY WORRIES FLAG IS TYPED HERE, NOT BORROWED. The shared
//  `kPregnancyUrgentFlag` is written for the whole pregnancy (waters, baby's
//  movements, pre-eclampsia) and its footer carries an em dash this door's
//  voice test forbids. These lines are the early-pregnancy subset the
//  Complications pages on ectopic and miscarriage give as call-now signs:
//  heavy bleeding, one-sided pain, shoulder-tip pain, fainting, fever.
//
//  ⚠️ ONE NEW SURFACE, OWED BY THE LEAD. `kFirstSurfaceDueDate` should open
//  the shipped `DueDateCalculatorScreen` (as `surface_router.dart`'s
//  'due_date' does). The two Mind surfaces already resolve.
//
//  Hues are the app's own: 200 is this bracket's (pregnancy_brackets.dart);
//  42, 344 and 268 are `V2BlockHues` values used across the stage.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import '../reads/read_images.dart' show readImageFor;
import 'pv_door_data.dart';
import 'pv_door_mind.dart' show kMindSurfaceHelplines, mindSurfaceOffer;

/// The due date calculator (`DueDateCalculatorScreen`). A route name, so a
/// constant: see `pv_door_scans.dart`.
const String kFirstSurfaceDueDate = 'first_weeks/due_date';

/// Tab ids. Constants for the reason `pv_door_scans.dart` gives: a typo in a
/// section's group renders it in no tab at all.
const String kFirstTabFoundOut = 'found_out';
const String kFirstTabVisit = 'first_visit';
const String kFirstTabWorries = 'worries';
const String kFirstTabTelling = 'telling';

/// The Early worries tab's pinned card.
///
/// ⚠️ SHOWN WHOLE. See `PvDoorRedFlag`: a red-flag list is never trimmed for
/// layout, and shoulder-tip pain is the line a woman would otherwise ignore.
const PvDoorRedFlag kFirstWeeksFlag = PvDoorRedFlag(
  title: 'Go to hospital straight away if',
  lines: [
    PvDoorFlagLine("You're bleeding heavily: soaking a pad in an hour or "
        'less, or passing clots.'),
    PvDoorFlagLine("You have sharp pain low down on one side, or severe pain "
        "in your tummy that doesn't ease."),
    PvDoorFlagLine('You have pain at the tip of your shoulder, with tummy '
        'pain or feeling faint.'),
    PvDoorFlagLine('You feel faint or dizzy, or you pass out.'),
    PvDoorFlagLine('You have a fever of 38°C or more with pain or bleeding.'),
  ],
  footer: "For a fever on its own, any spotting, or vomiting that stops you "
      "keeping fluids down, call your doctor today. If you can't get to "
      'hospital safely, call 108.',
  surfaceId: kCondSurfaceUrgent,
  // Every sign is on the card. The urgent screen covers later pregnancy too,
  // so it is not linked from here.
  seeAll: false,
);

final PvDoorPage kFirstWeeksDoor = PvDoorPage(
  bracketId: 'pregnancy_first_weeks',

  heroTitle: 'Your first weeks, one step at a time.',
  heroBlurb: 'What to do first, your first visit, the early worries, and when '
      'to tell people.',

  // ⚠️ NOT LOOKED AT BY THE AUTHOR OF THIS FILE, AND SAID SO, as the Move
  // door says of its own: the image hosts were unreachable from the session
  // that built this door. It is the photograph "Understanding the first
  // trimester" already ships (CC0, StockSnap, Djordje Popovic, chosen by eye
  // for that read and mirrored to our R2 bucket), so it has been seen for
  // this subject, but not in a hero crop. No other door wears it. Look at it
  // on a phone before release and swap the id if the crop shows a baby or
  // anything the rule in `pv_door_scans.dart` forbids.
  heroImageUrl: readImageFor('preg_week_read_first_trimester'),

  closingLine: "If something feels wrong, call your doctor. It's never too "
      'early to ask. ParentVeda explains and reminds. Your doctor decides.',

  groups: [
    PvDoorGroup(
      id: kFirstTabFoundOut,
      label: 'Just found out',
      mark: IntentMark.calendarDay,
      icon: Icons.wb_sunny_outlined,
      hue: 200,
    ),
    PvDoorGroup(
      id: kFirstTabVisit,
      label: 'Your first visit',
      mark: IntentMark.askDoctor,
      icon: Icons.medical_services_outlined,
      hue: 42,
    ),
    PvDoorGroup(
      id: kFirstTabWorries,
      label: 'Early worries',
      mark: IntentMark.bodyMark,
      icon: Icons.health_and_safety_outlined,
      hue: 344,
      pinnedRedFlag: kFirstWeeksFlag,
    ),
    PvDoorGroup(
      id: kFirstTabTelling,
      label: 'Telling people',
      mark: IntentMark.cuppedHands,
      icon: Icons.people_outline_rounded,
      hue: 268,
      note: "There's no right time to tell anyone. It's your news, and you "
          'choose when to share it.',
    ),
  ],

  sections: [
    // =========================================================================
    //  TAB 1 · Just found out
    // =========================================================================
    PvDoorSection(
      group: kFirstTabFoundOut,
      heading: 'Start here',
      tiles: [
        PvDoorGuideTile(
          title: "You're pregnant: what to do this week",
          blurb: 'Folic acid, what to stop, your medicines, and registering '
              'your pregnancy.',
          readId: 'preg_first_read_this_week',
        ),
        PvDoorGuideTile(
          title: 'What can wait',
          blurb: "The things you don't need to sort out yet.",
          readId: 'preg_first_read_this_week',
          atHeading: 'What can wait?',
        ),
        PvDoorGuideTile(
          title: 'Understanding the first trimester',
          blurb: "What's happening in you, and what you'll probably feel.",
          readId: 'preg_week_read_first_trimester',
          meta: 'Weeks 1 to 13',
        ),
      ],
    ),
    PvDoorSection(
      group: kFirstTabFoundOut,
      heading: 'Your due date',
      tiles: [
        PvDoorGuideTile(
          title: 'Working out your due date',
          blurb: 'How it is counted, and why a scan date comes first.',
          readId: 'preg_first_read_due_date',
        ),
        PvDoorToolTile(
          title: 'Due date calculator',
          blurb: 'From your last period, a scan, an IVF transfer or your '
              "doctor's date.",
          surfaceId: kFirstSurfaceDueDate,
        ),
      ],
    ),

    // =========================================================================
    //  TAB 2 · Your first visit
    // =========================================================================
    PvDoorSection(
      group: kFirstTabVisit,
      heading: 'Before you go',
      tiles: [
        PvDoorGuideTile(
          title: 'Choosing a doctor and a hospital',
          blurb: 'Government or private, what to ask, and how far is too far.',
          readId: 'preg_first_read_choosing_care',
        ),
        // Scans & tests owns the visit itself. One read, two doors.
        PvDoorGuideTile(
          title: 'Your first antenatal visit',
          blurb: "What's checked, what to carry, and how often you'll be "
              'seen.',
          readId: 'preg_scan_read_first_visit',
          meta: 'Weeks 8 to 12',
        ),
        PvDoorGuideTile(
          title: 'Questions to ask at your first visit',
          blurb: "What you'll be asked, why they test your urine, and what "
              'to ask back.',
          readId: 'preg_first_read_visit_questions',
        ),
        PvDoorGuideTile(
          title: 'hCG and your early blood tests',
          blurb: 'What the first blood tests check, and why hCG is repeated.',
          readId: 'preg_scan_read_early_bloods',
        ),
      ],
    ),
    PvDoorSection(
      group: kFirstTabVisit,
      heading: 'After IVF or a loss',
      tiles: [
        PvDoorGuideTile(
          title: 'Your first visit after IVF or a loss',
          blurb: 'Moving on from the IVF clinic, your medicines, and what to '
              'tell your doctor.',
          readId: 'preg_first_read_ivf_or_loss',
        ),
        PvDoorGuideTile(
          title: 'Your care in a pregnancy after a loss',
          blurb: 'Telling your doctor early, and the extra checks you can ask '
              'for.',
          readId: 'preg_loss_read_next_pregnancy_care',
        ),
        PvDoorEntryTile(
          title: 'After IVF, and finding it hard',
          blurb: "When you're expected to feel only grateful.",
          library: PvDoorLibrary.mindRead,
          entryId: 'after_ivf_allowed_hard',
        ),
        PvDoorEntryTile(
          title: 'Pregnant again after a loss',
          blurb: 'When joy and fear arrive together.',
          library: PvDoorLibrary.mindRead,
          entryId: 'pregnant_after_loss',
        ),
      ],
    ),

    // =========================================================================
    //  TAB 3 · Early worries
    // =========================================================================
    PvDoorSection(
      group: kFirstTabWorries,
      heading: 'Bleeding and pain',
      tiles: [
        PvDoorGuideTile(
          title: 'Spotting in early pregnancy',
          blurb: "Why it happens, what to do now, and when it can't wait.",
          readId: 'preg_first_read_spotting',
        ),
        PvDoorGuideTile(
          title: 'Cramps and twinges',
          blurb: 'The usual kind, what eases them, and the pain to act on.',
          readId: 'preg_first_read_cramps',
        ),
        PvDoorEntryTile(
          title: 'Pregnancy in the wrong place (ectopic)',
          blurb: "Rare and urgent, and treatable when it's caught early.",
          library: PvDoorLibrary.condition,
          entryId: 'ectopic',
          meta: 'Weeks 5 to 10',
        ),
      ],
    ),
    PvDoorSection(
      group: kFirstTabWorries,
      heading: 'How you feel',
      tiles: [
        PvDoorGuideTile(
          title: "When you don't feel pregnant",
          blurb: 'Few symptoms, symptoms that come and go, and what they '
              "can't tell you.",
          readId: 'preg_first_read_no_symptoms',
        ),
        PvDoorGuideTile(
          title: 'Managing morning sickness',
          blurb: 'What helps, what makes it worse, and when it eases.',
          readId: 'preg_week_read_managing_nausea',
        ),
        PvDoorGuideTile(
          title: 'When sickness is too much',
          blurb: 'The signs of severe sickness, and the treatment that helps.',
          readId: 'preg_first_read_sickness_too_much',
        ),
        PvDoorEntryTile(
          title: 'Severe vomiting (hyperemesis)',
          blurb: 'The medical page: the signs, and how it is managed.',
          library: PvDoorLibrary.condition,
          entryId: 'hyperemesis',
        ),
      ],
    ),
    PvDoorSection(
      group: kFirstTabWorries,
      heading: 'Tests and numbers',
      tiles: [
        PvDoorGuideTile(
          title: 'A faint line, or a low hCG number',
          blurb: 'What a pale line means, and why one number says so little.',
          readId: 'preg_first_read_faint_line',
        ),
        PvDoorGuideTile(
          title: 'hCG and your early blood tests',
          blurb: 'Why your doctor repeats it after two days.',
          readId: 'preg_scan_read_early_bloods',
        ),
      ],
    ),
    PvDoorSection(
      group: kFirstTabWorries,
      heading: 'When worry takes over',
      tiles: [
        PvDoorGuideTile(
          title: 'Anxious in the first weeks',
          blurb: 'Why the early weeks feel so tense, and what helps.',
          readId: 'preg_first_read_anxiety',
        ),
        PvDoorEntryTile(
          title: 'Fear of miscarriage',
          blurb: 'Living with the fear, week by week.',
          library: PvDoorLibrary.mindRead,
          entryId: 'fear_miscarriage',
        ),
        PvDoorEntryTile(
          title: 'Health anxiety and over-Googling',
          blurb: 'When searching for answers makes it worse.',
          library: PvDoorLibrary.mindRead,
          entryId: 'health_anxiety_googling',
        ),
        PvDoorTalkTile(
          title: 'Talk to a counsellor',
          blurb: 'Someone trained in pregnancy worries. Anonymous, and at your '
              'pace.',
          surfaceId: mindSurfaceOffer('perinatal_counselling'),
        ),
        PvDoorToolTile(
          title: 'Helpline numbers',
          blurb: 'Free mental health and emergency numbers for India, any '
              'hour.',
          surfaceId: kMindSurfaceHelplines,
        ),
      ],
    ),

    // =========================================================================
    //  TAB 4 · Telling people
    // =========================================================================
    PvDoorSection(
      group: kFirstTabTelling,
      heading: 'When to tell',
      tiles: [
        PvDoorGuideTile(
          title: 'When to tell people',
          blurb: 'The 12-week custom, reasons to tell sooner, and keeping it '
              'quiet for now.',
          readId: 'preg_first_read_when_to_tell',
        ),
        PvDoorEntryTile(
          title: 'The secret months, carried alone',
          blurb: "The feelings of the weeks before anyone knows.",
          library: PvDoorLibrary.mindRead,
          entryId: 'secret_months',
        ),
      ],
    ),
    PvDoorSection(
      group: kFirstTabTelling,
      heading: 'Family',
      tiles: [
        PvDoorGuideTile(
          title: 'Telling your family',
          blurb: 'Who hears first, the flood of advice, and the "boy or girl" '
              'question.',
          readId: 'preg_first_read_telling_family',
        ),
        // Getting ready owns this read. One read, two doors.
        PvDoorGuideTile(
          title: 'Telling an older child',
          blurb: 'When to tell them, simple words, and keeping their world '
              'steady.',
          readId: 'preg_ready_read_older_child',
        ),
        PvDoorGuideTile(
          title: 'Why nobody will tell you the sex',
          blurb: 'What the law says, and answering family who ask.',
          readId: 'preg_scan_read_sex_law',
        ),
        PvDoorEntryTile(
          title: "When the baby's gender becomes everyone's business",
          blurb: 'Coping with the guesses and the pressure.',
          library: PvDoorLibrary.mindRead,
          entryId: 'gender_everyones_business',
        ),
      ],
    ),
    PvDoorSection(
      group: kFirstTabTelling,
      heading: 'Work',
      tiles: [
        // Work & money owns this read, and the leave and rights reads behind
        // it. One read, two doors.
        PvDoorGuideTile(
          title: 'Telling your boss',
          blurb: 'When to tell, what to say, and what to ask HR.',
          readId: 'preg_work_read_telling_your_boss',
        ),
      ],
    ),
  ],
);

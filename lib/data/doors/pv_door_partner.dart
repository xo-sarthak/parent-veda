// =============================================================================
//  For partners (pregnancy) — the door for his side
// -----------------------------------------------------------------------------
//  Added 2026-09-30 from the pregnancy gap analysis, "Partner (his side)" and
//  "Behind · Partner": *"A clear week by week guide for him, reachable from his
//  home, is one of the most asked for pieces for fathers"*, plus the pieces the
//  PDF lists under "Partner › His side": the first days after the news, things a
//  partner can do each trimester, seven tips for a first-time dad, helping with
//  feeding, pregnancy symptoms for partners and his own feelings, and light
//  couple questions.
//
//  Same shape as the other pregnancy doors (Twins is the template): a hero,
//  tabs, rails of guide cards, a closing line. The skeleton and the words are
//  the work here; the look is the shared door look and his Slate skin is a later
//  pass (the user, 2026-09-30: "designing part can be handled later").
//
//  ⚠️ NOT A HOME TILE. The mother's home has ten tiles and one of them opening
//  "for him" would be a tile for someone else. The door opens from HIS side: the
//  Learn tab of the partner bar, and `kPartnerSurfaceDoor` for anything else.
//
//  ⚠️ NOTHING NEW CLINICALLY. The labour tab links the labour reads that already
//  exist (signs of labour, when to go in, stages, C-section, induction, the
//  first hour, and "What your partner should do"); this door adds no medical
//  claim of its own. The new reads (`pregnancy_reads_partner.dart`) are about
//  what a partner can DO and how HE is, and defer to her doctor.
//
//  ⚠️ WHAT HE SEES OF HER IS UNCHANGED. He sees her week and her calendar if she
//  shares them, never her symptoms, weight, journal or records. Nothing here
//  reads any of that.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../services/life_stage_store.dart';
import '../reads/pregnancy_reads_weekly_a.dart' show kPregWeekReadPrefix;
import 'pv_door_data.dart';

const String kPartnerTabWeek = 'week';
const String kPartnerTabSupport = 'support';
const String kPartnerTabBirth = 'birth';
const String kPartnerTabYou = 'you';
const String kPartnerTabReady = 'ready';

/// The partner guide, week by week (a screen, not a read: it is drawn from the
/// partner corner already written for every week).
const String kPartnerSurfaceWeekGuide = 'partner/week_guide';

/// Opens this door from the partner bar's Learn tab and from anywhere else.
const String kPartnerSurfaceDoor = 'pregnancy/partner';

/// The read ids this door owns, in `pregnancy_reads_partner.dart`.
const String kPartnerReadFirstDays = 'preg_partner_read_first_days';
const String kPartnerReadEachTrimester = 'preg_partner_read_each_trimester';
const String kPartnerReadFirstTimeDad = 'preg_partner_read_first_time_dad';
const String kPartnerReadFeeding = 'preg_partner_read_feeding';
const String kPartnerReadSympathy = 'preg_partner_read_sympathy';
const String kPartnerReadFeelings = 'preg_partner_read_your_feelings';
const String kPartnerReadCoupleQuestions = 'preg_partner_read_couple_questions';
const String kPartnerReadAfterLoss = 'preg_partner_read_after_loss_partner';

/// The existing read the PDF calls "How your partner can support you now".
const String kPartnerReadSupportNow = '${kPregWeekReadPrefix}partner_support';

// =============================================================================
//  The bracket
// =============================================================================

/// ⚠️ ENGLISH ON BOTH SIDES, BY POLICY (CLAUDE.md, 2026-08-27). Every layer is
/// declared, as `pregnancy_brackets.dart` does.
const Bracket kPregPartnerBracket = Bracket(
  id: 'pregnancy_partner',
  stage: LifeStage.pregnancy,
  theme: 'partner',
  hue: 205,
  label: LocalizedText(en: 'For partners', hi: 'For partners'),
  title: LocalizedText(en: 'For partners', hi: 'For partners'),
  blurb: LocalizedText(
      en: 'Your week, how to support her, the birth, and how you are doing.',
      hi: 'Your week, how to support her, the birth, and how you are doing.'),
  layers: {
    BracketLayer.content: BracketLayerSpec(
        state: LayerState.notCore,
        reason: 'Served by the For partners door (pv_door_partner.dart)'),
    BracketLayer.activities:
        BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
    BracketLayer.tools: BracketLayerSpec(
        state: LayerState.notCore,
        reason: 'The contraction timer, the bag and the checklist ride the door'),
    BracketLayer.products: BracketLayerSpec(
        state: LayerState.notCore, reason: 'Rides the shared product checklist'),
    BracketLayer.course:
        BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
    BracketLayer.consult:
        BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
    BracketLayer.extras: BracketLayerSpec(
        state: LayerState.notCore, reason: 'The signs to call about ride the Labour tab'),
  },
);

// =============================================================================
//  The door
// =============================================================================

final PvDoorPage kPartnerDoor = PvDoorPage(
  bracketId: 'pregnancy_partner',
  heroTitle: 'Your part in this pregnancy.',
  heroBlurb: 'What to do each week, how to be there for her, the birth, and '
      'looking after yourself too.',
  closingLine: 'ParentVeda explains and reminds. Her doctor decides, and her '
      'doctor knows her. If anything feels wrong, call them or go in.',
  groups: [
    PvDoorGroup(
      id: kPartnerTabWeek,
      label: 'Your week',
      mark: IntentMark.calendarDay,
      icon: Icons.calendar_today_outlined,
      hue: 205,
    ),
    PvDoorGroup(
      id: kPartnerTabSupport,
      label: 'Supporting her',
      mark: IntentMark.cuppedHands,
      icon: Icons.favorite_border_rounded,
      hue: 344,
    ),
    PvDoorGroup(
      id: kPartnerTabBirth,
      label: 'Labour and birth',
      mark: IntentMark.timelineRail,
      icon: Icons.child_friendly_outlined,
      hue: 26,
    ),
    PvDoorGroup(
      id: kPartnerTabYou,
      label: 'You, too',
      mark: IntentMark.moodArc,
      icon: Icons.self_improvement_rounded,
      hue: 160,
    ),
    PvDoorGroup(
      id: kPartnerTabReady,
      label: 'Before the baby',
      mark: IntentMark.bagMark,
      icon: Icons.home_outlined,
      hue: 268,
    ),
  ],
  sections: [
    // =========================================================================
    //  Your week
    // =========================================================================
    PvDoorSection(
      group: kPartnerTabWeek,
      heading: 'Week by week',
      tiles: [
        PvDoorToolTile(
          title: 'Your week, week by week',
          blurb: 'What she may feel, what you can do, and one thing to do, for '
              'every week from 4 to 40.',
          surfaceId: kPartnerSurfaceWeekGuide,
        ),
      ],
    ),
    PvDoorSection(
      group: kPartnerTabWeek,
      heading: 'Start here',
      tiles: [
        PvDoorGuideTile(
          title: 'The first days after the news',
          blurb: 'How to be there, what to ask, and what to keep quiet about '
              'until she says.',
          readId: kPartnerReadFirstDays,
        ),
        PvDoorGuideTile(
          title: 'Things you can do, trimester by trimester',
          blurb: 'A short, doable list for each part of the pregnancy.',
          readId: kPartnerReadEachTrimester,
        ),
      ],
    ),

    // =========================================================================
    //  Supporting her
    // =========================================================================
    PvDoorSection(
      group: kPartnerTabSupport,
      heading: 'Day to day',
      tiles: [
        PvDoorGuideTile(
          title: 'How you can support her now',
          blurb: 'Not "be supportive": a list of small things that help.',
          readId: kPartnerReadSupportNow,
        ),
        PvDoorGuideTile(
          title: 'Helping with feeding, before and after the birth',
          blurb: 'What to learn now, and the jobs you can take on at night.',
          readId: kPartnerReadFeeding,
        ),
      ],
    ),
    PvDoorSection(
      group: kPartnerTabSupport,
      heading: 'Time together',
      tiles: [
        PvDoorGuideTile(
          title: 'Questions to ask each other',
          blurb: 'Twelve light questions, one a week, and no right answers.',
          readId: kPartnerReadCoupleQuestions,
        ),
      ],
    ),

    // =========================================================================
    //  Labour and birth
    // =========================================================================
    PvDoorSection(
      group: kPartnerTabBirth,
      heading: 'On the day',
      tiles: [
        PvDoorGuideTile(
          title: 'What your partner should do',
          blurb: 'The practical jobs, in order, for someone who has never done '
              'this either.',
          readId: 'preg_labour_read_partner',
        ),
        PvDoorGuideTile(
          title: 'When to go to the hospital',
          blurb: 'What you are watching for, and when to call.',
          readId: 'preg_labour_read_when_to_go',
        ),
        PvDoorToolTile(
          title: 'Contraction timer',
          blurb: 'Time them for her, and see when to go in.',
          surfaceId: kLabourSurfaceTimer,
        ),
      ],
    ),
    PvDoorSection(
      group: kPartnerTabBirth,
      heading: 'What may happen',
      tiles: [
        PvDoorGuideTile(
          title: 'The stages of labour',
          blurb: 'What each stage is, and how long it usually takes.',
          readId: 'preg_labour_read_stages',
        ),
        PvDoorGuideTile(
          title: 'If it becomes a C-section',
          blurb: 'What changes, what does not, and where you will be.',
          readId: 'preg_labour_read_c_section',
        ),
        PvDoorGuideTile(
          title: 'Induction, and going past the due date',
          blurb: 'Why doctors offer it, and what happens.',
          readId: 'preg_labour_read_induction',
        ),
        PvDoorGuideTile(
          title: 'The first hour after the birth',
          blurb: 'Skin to skin, the first feed, and what is happening in the '
              'room.',
          readId: 'preg_labour_read_first_hour',
        ),
      ],
    ),

    // =========================================================================
    //  You, too
    // =========================================================================
    PvDoorSection(
      group: kPartnerTabYou,
      heading: 'How you are',
      tiles: [
        PvDoorGuideTile(
          title: 'Can you have pregnancy symptoms too?',
          blurb: 'Tiredness, nausea, sleeplessness: common, and nothing to be '
              'embarrassed about.',
          readId: kPartnerReadSympathy,
        ),
        PvDoorGuideTile(
          title: 'Your own feelings',
          blurb: 'Worry, money, feeling left out: what to do with them, and '
              'who to talk to.',
          readId: kPartnerReadFeelings,
        ),
      ],
    ),
    PvDoorSection(
      group: kPartnerTabYou,
      heading: 'If the pregnancy ends',
      tiles: [
        PvDoorGuideTile(
          title: 'How to be there for her',
          blurb: 'After a miscarriage or a stillbirth: what to say, what to '
              'take off her, and looking after yourself.',
          readId: kPartnerReadAfterLoss,
        ),
      ],
    ),

    // =========================================================================
    //  Before the baby
    // =========================================================================
    PvDoorSection(
      group: kPartnerTabReady,
      heading: 'Get ready',
      tiles: [
        PvDoorGuideTile(
          title: 'Seven things to do before the baby comes',
          blurb: 'The hospital, the folder, who helps at home, and your leave.',
          readId: kPartnerReadFirstTimeDad,
        ),
        PvDoorToolTile(
          title: 'The hospital bag',
          blurb: 'What to pack for her, the baby and you.',
          surfaceId: kLabourSurfaceBag,
        ),
        PvDoorToolTile(
          title: 'What you really need for the baby',
          blurb: 'A checklist, so you buy what is needed and nothing more.',
          surfaceId: kReadySurfaceStore,
        ),
      ],
    ),
  ],
);

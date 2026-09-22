// =============================================================================
//  The Symptoms door — how she feels today, and what it means
// -----------------------------------------------------------------------------
//  2026-09-22, docs/SYMPTOMS-DOOR-PLAN.md, built in the door language after
//  the Mobbin round (MOBBIN-DISCOVERY §18). Five tabs, like every door:
//
//    Today            the check-in — a tool. Round drawn-mark tiles of the
//                     symptoms she is likeliest to be feeling this week, one
//                     tap logs, the next tap sets how strong, the week strip
//                     over it (PvDayStrip, the home's). Under the grid: what
//                     helps for what she logged today, the evening reminder.
//    Is this normal?  the ten questions, in her words, each wearing its
//                     verdict — a "now" row ends in the phone.
//    By symptom       the library, by where she feels it (six areas).
//    Your week        the log — a grid of the last seven days, the pattern
//                     line, and "Send my week" to her doctor.
//    Talk             the pinned five ("call now"), a consult, Ask Veda.
//
//  ⚠️ THE OLD COMPANION (`SymptomCompanionScreen`) STAYS. Its store is this
//  door's store; its twelve symptoms are in the library; its detail page is a
//  read now. The Tools hub still lists it; the door is the front.
//
//  ⚠️ WHAT SHE LOGS IS HER OBSERVATION (`TruthSource`). Nothing here derives
//  a risk from the log; the pattern line counts days, and that is all it
//  says. The "now" rows route to a call, never to a read first.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import '../reads/read_images.dart' show readImageFor;
import '../symptoms/symptom_library.dart';
import 'pv_door_data.dart';

const String kSymptomsBracketId = 'pregnancy_symptoms';

const String kSymSurfaceToday = 'symptoms/today';
const String kSymSurfaceWeek = 'symptoms/week';
const String kSymSurfaceSend = 'symptoms/send';
const String kSymSurfaceUrgent = 'symptoms/urgent';
const String kSymSurfaceNormal = 'symptoms/normal';
const String kSymSurfaceCalling = 'symptoms/calling';

const String kSymTabToday = 'today';
const String kSymTabNormal = 'normal';
const String kSymTabLibrary = 'library';
const String kSymTabWeek = 'week';
const String kSymTabTalk = 'talk';

/// The pinned flag: the five questions whose answer is "call now", in the
/// words she would use. `seeAll: false` — the door's Is this normal? tab
/// carries the full answers, one tap away.
final PvDoorRedFlag kSymptomsUrgentFlag = PvDoorRedFlag(
  title: 'Call now, at any hour, if',
  lines: const [
    PvDoorFlagLine('You are bleeding, even lightly'),
    PvDoorFlagLine('The baby is moving less than usual'),
    PvDoorFlagLine('You are leaking fluid, or had a gush'),
    PvDoorFlagLine('Regular or painful tightenings before 37 weeks'),
    PvDoorFlagLine(
      'A severe headache with vision changes, or sudden swelling of the face and hands',
    ),
  ],
  surfaceId: kSymSurfaceUrgent,
  footer:
      'Your obstetrician, the labour ward, or the nearest hospital with a '
      'maternity unit. Call, do not message. If you cannot reach anyone and it '
      'is bad, go in.',
  seeAll: false,
);

String _first(String s) {
  final i = s.indexOf('. ');
  return i < 0 ? s : s.substring(0, i + 1);
}

final PvDoorPage kSymptomsDoor = PvDoorPage(
  bracketId: kSymptomsBracketId,
  heroTitle: 'How are you feeling today?',
  heroBlurb:
      'Tap what you feel, see what helps, and know exactly when to '
      'call — for every ache of pregnancy.',
  // Owed: a photograph of its own. The back-pain read's (a woman in a
  // doorway, a hand on her belly, warm light) carries the door until then.
  heroImageUrl: readImageFor('preg_week_read_back_pain'),
  groups: [
    PvDoorGroup(
      id: kSymTabToday,
      label: 'Today',
      icon: Icons.check_circle_outline_rounded,
      mark: IntentMark.checkMark,
      hue: 26,
      inlineSurfaceId: kSymSurfaceToday,
      inlineLabel: 'Your check-in',
    ),
    // ⚠️ A TOOL, NOT A LIST OF READS. The ten rows wear their verdict and a
    // "now" row carries the phone; a read row cannot dial. The questions
    // reach the door's search through `_symptomLibraries`.
    PvDoorGroup(
      id: kSymTabNormal,
      label: 'Is this normal?',
      icon: Icons.help_outline_rounded,
      mark: IntentMark.questionMark,
      hue: 344,
      inlineSurfaceId: kSymSurfaceNormal,
      inlineLabel: '10 questions',
    ),
    PvDoorGroup(
      id: kSymTabLibrary,
      label: 'By symptom',
      icon: Icons.accessibility_new_rounded,
      mark: IntentMark.bodyMark,
      hue: 206,
    ),
    PvDoorGroup(
      id: kSymTabWeek,
      label: 'Your week',
      icon: Icons.calendar_view_week_outlined,
      mark: IntentMark.chartLog,
      hue: 160,
      inlineSurfaceId: kSymSurfaceWeek,
      inlineLabel: 'Seven days, at a glance',
    ),
    PvDoorGroup(
      id: kSymTabTalk,
      label: 'Talk',
      icon: Icons.chat_bubble_outline_rounded,
      mark: IntentMark.askDoctor,
      hue: 268,
      pinnedRedFlag: kSymptomsUrgentFlag,
      note:
          'General guidance for an ordinary pregnancy, never a diagnosis. '
          'Your own doctor\'s word wins over anything here.',
    ),
  ],
  sections: [
    // ---- Today ----------------------------------------------------------------
    // ⚠️ NO SECTION. The check-in IS the tab, and everything that was under it
    // is somewhere else already: "Your week" and "Is this normal?" are tabs one
    // swipe away, and "Send my week" belongs with the week it sends. Three
    // copies of Send (Today, Your week, Talk) is what the door actually shipped
    // on 2026-09-22 — the user, walking it: *"that's also repeating"*.
    //
    // The general shape, worth keeping: a tile that opens a surface another tab
    // already owns is not navigation, it is a second copy of that tab. One job
    // per tab, and each surface has exactly one home.

    // ---- Is this normal? -------------------------------------------------------
    // ⚠️ THE TOOL DRAWS THE TEN. Under it stood "The five to call about", which
    // opened `SymptomsNormalScreen` — the SAME TEN ROWS the tab was already
    // showing. The user, walking it (2026-09-22): *"you have listed a lot of
    // things under 'is this normal?', then under 'if it is one of these, call —
    // do not read' you have listed the same ones"*. He is right, and on this
    // tab of all tabs it is worse than untidy: a safety list that appears twice
    // teaches her to skim it.
    //
    // So the tab now says each thing once: the five live on Talk as the pinned
    // flag (one home), the ten are the answers, and the section under them is
    // the thing neither covers — what to actually SAY when she rings.
    PvDoorSection(
      group: kSymTabNormal,
      heading: 'When you do call',
      tiles: [
        PvDoorToolTile(
          title: 'What to say when you call',
          blurb:
              'The six things they will ask, in order, so you are not composing them at 2 am.',
          surfaceId: kSymSurfaceCalling,
        ),
      ],
    ),

    // ---- By symptom ---------------------------------------------------------------
    for (final area in SymptomArea.values)
      PvDoorSection(
        group: kSymTabLibrary,
        heading: area.label,
        tiles: [
          for (final s in symptomsInArea(area))
            PvDoorEntryTile(
              title: s.name.en,
              blurb: _first(s.commonness.en),
              library: PvDoorLibrary.symptom,
              entryId: s.id,
              // "matli", "chakkar", "jalan" — the words she types.
              keywords: s.keywords,
            ),
        ],
      ),

    // ---- Your week ------------------------------------------------------------------
    PvDoorSection(
      group: kSymTabWeek,
      heading: 'Take it to your doctor',
      tiles: [
        PvDoorToolTile(
          title: 'Send my week',
          blurb:
              'A short note of the seven days — what, how often, how strong — to share before a visit.',
          surfaceId: kSymSurfaceSend,
        ),
      ],
    ),

    // ---- Talk -------------------------------------------------------------------------
    PvDoorSection(
      group: kSymTabTalk,
      heading: 'Someone to ask',
      tiles: [
        PvDoorTalkTile(
          title: 'Have a doctor go through it with you',
          blurb:
              'Book a 1:1 with a gynaecologist. Send your week from the Your week tab and bring it with you.',
          surfaceId:
              kScansSurfaceConsult, // 'consults' — the one consult sheet every door books through
        ),
        // Kept for revert — Send lives on Your week now, once:
        // PvDoorToolTile(
        //   title: 'Send my week first',
        //   blurb: 'The note of the seven days, ready to paste into a message.',
        //   surfaceId: kSymSurfaceSend,
        // ),
      ],
    ),
  ],
);

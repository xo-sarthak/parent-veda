// =============================================================================
//  After a loss (pregnancy) — the door
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), P1, "the second most urgent chapter": *"If her pregnancy
//  ends, nothing in the app can be told, and it keeps showing her baby
//  growing week by week."* The PDF's shape for the section: Your body
//  (bleeding, recovery, when to call), Understand (miscarriage, ectopic,
//  stillbirth, ending a pregnancy for medical reasons), Support (grief, his
//  grief, telling family, counselling and the helplines), Trying again.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NOT A HOME TILE, SO NOT A BRACKET FROM `kPregnancyBrackets`
//  ---------------------------------------------------------------------------
//
//  That list feeds the home grid, and a tile reading "After a loss" on every
//  pregnant woman's home is the wrong object in the wrong room. The door is
//  reached from the "My pregnancy ended" screen (You › Details) and from the
//  Complications pages on miscarriage and stillbirth. It carries its own
//  `Bracket` below only because `PvDoorScreen` needs one for its eyebrow and
//  hue.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE SAME THREE DEPARTURES AS THE TTC AFTER A LOSS DOOR
//  ---------------------------------------------------------------------------
//
//  (`lib/ttc/focus/ttc_focus_after_loss.dart` explains them at length.)
//  1. "Your body" is the default tab. Days after a loss the first need is
//     physical reassurance and the hospital red flag, not causes.
//  2. No tracker, no countdown, no self-check, no product. The only tool is
//     the stage switch on Trying again, which she chooses.
//  3. Your body and Support pin a red flag above their rails. Heavy bleeding
//     and thoughts of self-harm do not wait for her to pick a card.
//
//  ⚠️ NO BABY PHOTOGRAPH, NO BUMP. `heroImageUrl` is null, so the hero draws
//  the V3 field and the bracket's mark. See the report for the one mark line
//  the lead adds in `v3_bracket_art.dart`.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../services/life_stage_store.dart';
import 'pv_door_data.dart';
import 'pv_door_mind.dart'
    show kMindSurfaceCrisis, kMindSurfaceHelplines, mindSurfaceOffer;

const String kAfterLossTabBody = 'body';
const String kAfterLossTabUnderstand = 'understand';
const String kAfterLossTabSupport = 'support';
const String kAfterLossTabAgain = 'again';

/// ⚠️ A ROUTE NAME, owed by the lead: it asks her to confirm, then moves
/// ParentVeda to the trying-to-conceive stage. Nothing she saved is lost.
const String kAfterLossSurfaceTryAgain = 'after_loss/try_again';

// =============================================================================
//  The bracket
// =============================================================================

/// ⚠️ ENGLISH ON BOTH SIDES, BY POLICY (CLAUDE.md, 2026-08-27).
///
/// ⚠️ EVERY LAYER DECLARED, as `pregnancy_brackets.dart` does, because an
/// omitted layer inherits someone's assumption and the assumption is "live".
/// Products is `notApplicable` for the reason the bracket model gives in its
/// own words: a shopping prompt beside a clinical grief.
const Bracket kPregAfterLossBracket = Bracket(
  id: 'pregnancy_after_loss',
  stage: LifeStage.pregnancy,
  theme: 'loss',
  // A quiet blue-violet, away from every alarm hue on the grid.
  hue: 250,
  label: LocalizedText(en: 'After a loss', hi: 'After a loss'),
  title: LocalizedText(en: 'After a loss', hi: 'After a loss'),
  blurb: LocalizedText(
      en: 'Care for your body and your heart after a pregnancy ends.',
      hi: 'Care for your body and your heart after a pregnancy ends.'),
  layers: {
    BracketLayer.content: BracketLayerSpec(
        state: LayerState.notCore,
        reason: 'Served by the After a loss door (pv_door_after_loss.dart)'),
    BracketLayer.activities:
        BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
    BracketLayer.tools: BracketLayerSpec(
        state: LayerState.notApplicable,
        reason: 'Not a fit (no tracker, no countdown)'),
    BracketLayer.products: BracketLayerSpec(
        state: LayerState.notApplicable,
        reason: 'Not a fit (never commerce beside a loss)'),
    BracketLayer.course:
        BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
    BracketLayer.consult: BracketLayerSpec.live(['consults']),
    BracketLayer.extras: BracketLayerSpec(
        state: LayerState.notCore,
        reason: 'Helplines ride the Support tab of the door'),
  },
);

// =============================================================================
//  "My pregnancy ended" — the words for the lead's screens
// -----------------------------------------------------------------------------
//  `lib/screens/pregnancy/preg_ended_screen.dart` reads these. Plain Strings
//  (or lists and a map of them), English only, PREG-VOICE. The What to Expect
//  flow the gap analysis quotes told us what to cover; none of its sentences
//  are used.
// =============================================================================

/// The quiet row under You › Details.
const String kPregEndedRowTitle = 'If your pregnancy has ended';
const String kPregEndedRowSub =
    "Let ParentVeda know, and we'll change what you see.";

/// The confirm screen, before she confirms.
const String kPregEndedTitle = "We're so sorry.";
const List<String> kPregEndedBody = [
  "You don't have to explain anything, and you don't have to do this now.",
  "If you confirm, the weekly baby updates, the daily tip and the week "
      "reminders will stop. Your partner's side will stop showing the week "
      "too. In their place you'll find a quiet page with help for your body "
      "and your heart.",
  "Nothing you saved is deleted. Your notes, photos, reports and bookmarks "
      "stay just as they are, and you can undo this at any time from this "
      "same place.",
];
const String kPregEndedConfirm = 'Yes, update ParentVeda';
const String kPregEndedCancel = 'Not now';

/// The same screen, opened again after she has confirmed.
const String kPregEndedUndoTitle = 'Go back to your pregnancy view?';
const List<String> kPregEndedUndoBody = [
  "You told ParentVeda your pregnancy had ended. If that was a mistake, or "
      "you'd like the weekly view back, you can have it again now.",
  "The weekly updates, the daily tip and the week reminders will start "
      "again, and your partner's side will show the week too. Nothing you "
      "saved has changed.",
];
const String kPregEndedUndoConfirm = 'Go back to my pregnancy view';
const String kPregEndedUndoCancel = 'Stay as it is';

/// Her Today tab after confirming, above four rows that open the door's tabs.
const String kPregEndedHomeTitle = "We're here when you need us.";
const String kPregEndedDone =
    "The weekly updates and reminders have stopped. Below is help for your "
    "body, words for what happened, and people to lean on, whenever you want "
    "them. If you'd like to talk to someone now, Tele-MANAS answers free on "
    "14416, day and night.";

/// One short line under each tab name on that page, keyed by tab id.
const Map<String, String> kPregEndedTabLines = {
  kAfterLossTabBody: 'Bleeding, recovery, and when to call a doctor.',
  kAfterLossTabUnderstand: 'What happened, in plain words.',
  kAfterLossTabSupport: 'Grief, telling family, and someone to talk to.',
  kAfterLossTabAgain: "Only when you're ready. There's no timetable.",
};

/// The same Today page as her partner sees it, on his side.
const String kPregEndedPartnerTitle = "We're so sorry for your loss.";
const String kPregEndedPartnerBody =
    "It was your baby too. The weekly updates have stopped. On the Support "
    "tab there's a read written for you, 'For her partner: your grief too', "
    "with ways to help her in the first weeks and to look after yourself. "
    "Tele-MANAS on 14416 is there for you as well, free, at any hour.";

/// A small link at the foot of her Today page.
const String kPregEndedUndoLink = 'Go back to my pregnancy view';

// =============================================================================
//  The door
// =============================================================================

final PvDoorPage kAfterLossDoor = PvDoorPage(
  bracketId: 'pregnancy_after_loss',
  heroTitle: "We're so sorry. This is a place to take things slowly.",
  heroBlurb: 'Help for your body, words for what happened, and people to lean '
      'on, whenever you want them.',
  // ⚠️ NULL ON PURPOSE. No baby, no bump, no stock photo chosen without being
  // seen. The drawn mark is the fallback and it is calm.
  heroImageUrl: null,
  closingLine: 'Take what helps and leave the rest. If something feels wrong '
      'in your body or your mind, please call your doctor, or Tele-MANAS on '
      '14416.',

  groups: [
    // -------------------------------------------------------------------------
    //  1. Your body — the default, with the hospital flag pinned
    // -------------------------------------------------------------------------
    //  ⚠️ THE LINES AGREE WITH THE CONDITION PAGE, NOT A NEW LIST. The
    //  "Miscarriage / pregnancy loss" page's call-now lines (a pad in an hour
    //  or less, severe pain, fever or a bad smell, dizziness or fainting),
    //  plus the ectopic signs the ectopic page names. Typed here rather than
    //  derived because that page's lines are written for a pregnancy that may
    //  still be going on, and these are for after.
    PvDoorGroup(
      id: kAfterLossTabBody,
      label: 'Your body',
      mark: IntentMark.bodyMark,
      icon: Icons.spa_outlined,
      hue: 206,
      pinnedRedFlag: PvDoorRedFlag(
        title: 'Go to hospital straight away if',
        lines: [
          PvDoorFlagLine("You're soaking through a pad in an hour or less."),
          PvDoorFlagLine("You have severe pain that pain relief doesn't ease."),
          PvDoorFlagLine('You have a fever, or bleeding that smells bad.'),
          PvDoorFlagLine('You feel faint or dizzy, or have pain at the tip of '
              'your shoulder.'),
          PvDoorFlagLine('You have chest pain or sudden breathlessness.'),
        ],
        footer: "If you can't get there safely, call 108 for an ambulance. You "
            "never need to be sure before you go.",
        surfaceId: kCondSurfaceUrgent,
        // Every sign is on the card; the urgent screen is about a pregnancy
        // still going on, so it is not linked from here.
        seeAll: false,
      ),
    ),

    // -------------------------------------------------------------------------
    //  2. Understand
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kAfterLossTabUnderstand,
      label: 'Understand',
      mark: IntentMark.reportPage,
      icon: Icons.menu_book_outlined,
      hue: 250,
    ),

    // -------------------------------------------------------------------------
    //  3. Support — the self-harm routing pinned
    // -------------------------------------------------------------------------
    //  Each line carries its own urgency, because the four are not equally
    //  urgent and a single title would round them all up or all down.
    PvDoorGroup(
      id: kAfterLossTabSupport,
      label: 'Support',
      mark: IntentMark.cuppedHands,
      icon: Icons.people_outline_rounded,
      hue: 288,
      pinnedRedFlag: PvDoorRedFlag(
        title: 'When to reach out',
        lines: [
          PvDoorFlagLine('Any thought of harming yourself: call Tele-MANAS on '
              "14416 now, or 112 if you're in danger."),
          PvDoorFlagLine("Feeling you can't keep yourself safe: call 112, and "
              'tell someone near you.'),
          PvDoorFlagLine('Low, numb or hopeless for more than two weeks: tell '
              'your doctor this week.'),
          PvDoorFlagLine("Unable to sleep or eat for days: tell your doctor "
              'this week.'),
        ],
        footer: 'Tele-MANAS is free, open day and night, in English and many '
            'Indian languages.',
        surfaceId: kMindSurfaceCrisis,
      ),
    ),

    // -------------------------------------------------------------------------
    //  4. Trying again
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kAfterLossTabAgain,
      label: 'Trying again',
      mark: IntentMark.nextStep,
      icon: Icons.wb_twilight_outlined,
      hue: 160,
      note: "Only when you're ready. There's no timetable here, and not "
          "trying again is a choice too.",
    ),
  ],

  sections: [
    // =========================================================================
    //  Your body
    // =========================================================================
    PvDoorSection(
      group: kAfterLossTabBody,
      heading: 'The first days',
      tiles: [
        PvDoorGuideTile(
          title: 'Your body after a miscarriage',
          blurb: 'Bleeding, pain, pads, and looking after yourself this week.',
          readId: 'preg_loss_read_body_after_miscarriage',
        ),
        PvDoorGuideTile(
          title: 'When to go to hospital after a loss',
          blurb: 'The signs that mean going in straight away, and the ones '
              'that mean calling today.',
          readId: 'preg_loss_read_when_hospital',
        ),
      ],
    ),
    PvDoorSection(
      group: kAfterLossTabBody,
      heading: 'After a later loss',
      tiles: [
        PvDoorGuideTile(
          title: 'Recovering after a later loss or stillbirth',
          blurb: 'Bleeding, milk coming in, stitches, and the checks ahead.',
          readId: 'preg_loss_read_later_loss_recovery',
        ),
      ],
    ),
    PvDoorSection(
      group: kAfterLossTabBody,
      heading: 'The weeks after',
      tiles: [
        PvDoorGuideTile(
          title: 'Your periods and your body in the weeks after',
          blurb: 'When your period comes back, sex, contraception, and '
              'getting your strength back.',
          readId: 'preg_loss_read_periods_after',
        ),
      ],
    ),

    // =========================================================================
    //  Understand
    // =========================================================================
    PvDoorSection(
      group: kAfterLossTabUnderstand,
      heading: 'What happened',
      tiles: [
        PvDoorGuideTile(
          title: "Miscarriage, and why it wasn't your fault",
          blurb: "Why it happens, what doesn't cause it, and the words on "
              'your papers.',
          readId: 'preg_loss_read_miscarriage',
        ),
        PvDoorGuideTile(
          title: 'Ectopic pregnancy: the signs, and the treatments',
          blurb: 'Why it could never continue, and what each treatment '
              'involves.',
          readId: 'preg_loss_read_ectopic',
        ),
        PvDoorGuideTile(
          title: 'When your baby dies before birth (stillbirth)',
          blurb: 'What happens next, time with your baby, and what tests can '
              'answer.',
          readId: 'preg_loss_read_stillbirth',
        ),
        PvDoorGuideTile(
          title: 'Ending a pregnancy for medical reasons',
          blurb: 'What the law in India allows, what happens, and the grief '
              'after.',
          readId: 'preg_loss_read_tfmr',
        ),
      ],
    ),
    PvDoorSection(
      group: kAfterLossTabUnderstand,
      heading: 'Looking for answers',
      tiles: [
        PvDoorGuideTile(
          title: 'More than one loss: when to ask about tests',
          blurb: 'What doctors check, what large studies show, and what to '
              'ask.',
          readId: 'preg_loss_read_tests_after',
        ),
      ],
    ),
    // ⚠️ THE CONDITION PAGES KEEP THE FACTS. The gap analysis: "Keep the
    // condition page for the facts, and link it to the new section." This is
    // the link back the other way, so the facts are never typed twice.
    PvDoorSection(
      group: kAfterLossTabUnderstand,
      heading: 'The medical pages',
      tiles: [
        PvDoorEntryTile(
          title: 'Miscarriage / pregnancy loss',
          blurb: 'The medical page: the signs, the tests, and how it is '
              'managed.',
          library: PvDoorLibrary.condition,
          entryId: 'miscarriage',
        ),
        PvDoorEntryTile(
          title: 'Ectopic pregnancy',
          blurb: 'The medical page: what it is, and when it needs a hospital.',
          library: PvDoorLibrary.condition,
          entryId: 'ectopic',
        ),
      ],
    ),

    // =========================================================================
    //  Support
    // =========================================================================
    PvDoorSection(
      group: kAfterLossTabSupport,
      heading: 'How you feel',
      tiles: [
        PvDoorGuideTile(
          title: 'Grief has no timetable',
          blurb: 'What grief can feel like, why it comes in waves, and what '
              'helps.',
          readId: 'preg_loss_read_grief',
        ),
        PvDoorGuideTile(
          title: 'Anniversaries, due dates and hard days',
          blurb: 'Why some days hit harder, and ways to get through them.',
          readId: 'preg_loss_read_hard_days',
        ),
      ],
    ),
    PvDoorSection(
      group: kAfterLossTabSupport,
      heading: 'The people around you',
      tiles: [
        PvDoorGuideTile(
          title: 'For her partner: your grief too',
          blurb: 'How to help her, and why his own grief matters as well.',
          readId: 'preg_loss_read_his_grief',
        ),
        PvDoorGuideTile(
          title: 'Telling family, and what people will say',
          blurb: 'Short words to use, and someone to tell others for you.',
          readId: 'preg_loss_read_telling_family',
        ),
      ],
    ),
    PvDoorSection(
      group: kAfterLossTabSupport,
      heading: 'Someone to talk to',
      tiles: [
        PvDoorGuideTile(
          title: 'Finding someone to talk to',
          blurb: 'Who can help, when to reach out, and the free helpline.',
          readId: 'preg_loss_read_someone_to_talk',
        ),
        // The same counsellor offer Mind & mood's Talk tab opens. A person,
        // not a product; the price is on its own screen.
        PvDoorTalkTile(
          title: 'Talk to a counsellor',
          blurb: 'Someone trained in pregnancy and loss. Anonymous, and at '
              'your pace.',
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
    PvDoorSection(
      group: kAfterLossTabSupport,
      heading: 'Work and leave',
      tiles: [
        PvDoorGuideTile(
          title: 'Going back to work, and the leave you may have',
          blurb: 'What Indian law may give you, and how to ask for it.',
          readId: 'preg_loss_read_work_leave',
        ),
      ],
    ),

    // =========================================================================
    //  Trying again
    // =========================================================================
    PvDoorSection(
      group: kAfterLossTabAgain,
      heading: "When you're ready",
      tiles: [
        PvDoorGuideTile(
          title: 'When is it okay to try again?',
          blurb: 'What your body needs, and what your heart needs.',
          readId: 'preg_loss_read_trying_again',
        ),
        PvDoorToolTile(
          title: "When you're ready to try again",
          blurb: 'Moves ParentVeda to the trying-to-conceive side, whenever '
              'you choose. Nothing is lost.',
          surfaceId: kAfterLossSurfaceTryAgain,
        ),
      ],
    ),
    PvDoorSection(
      group: kAfterLossTabAgain,
      heading: "If you're pregnant again",
      tiles: [
        PvDoorGuideTile(
          title: 'Your care in the next pregnancy',
          blurb: 'Telling your doctor early, and the extra checks you can ask '
              'for.',
          readId: 'preg_loss_read_next_pregnancy_care',
        ),
        // Mind & mood owns the feelings of a next pregnancy; linked, not
        // copied.
        PvDoorEntryTile(
          title: 'Pregnant again after a loss',
          blurb: 'When joy and fear arrive together.',
          library: PvDoorLibrary.mindRead,
          entryId: 'pregnant_after_loss',
        ),
      ],
    ),
  ],
);

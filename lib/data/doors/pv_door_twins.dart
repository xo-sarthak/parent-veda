// =============================================================================
//  Twins and more (pregnancy) — the door
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Twins and more", P3: *"Carrying twins: types of
//  twins, extra scans, weight and food, how twins are delivered, getting
//  ready for two."* What would be different after: *"A mother of twins finds
//  her own pregnancy in the app."* Before this, a twin pregnancy had one
//  report word ("Twin Pregnancy"), one diet guide and nothing else.
//
//  Same shape as the other pregnancy doors (`pv_door_scans.dart` is the
//  benchmark): a hero, tabs, rails of guide cards, a closing line.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NOT A HOME TILE, SO NOT A BRACKET FROM `kPregnancyBrackets`
//  ---------------------------------------------------------------------------
//
//  The same reasoning as `pv_door_after_loss.dart`. That list feeds the home
//  grid, and a "Twins and more" tile on every pregnant woman's home is for a
//  few women and in everyone's way. The door is reached from wherever her
//  pregnancy is known to be a twin one (the "Twin Pregnancy" report word, the
//  twins diet guide, and the twins switch the lead owes). It carries its own
//  `Bracket` below only because `PvDoorScreen` needs one for its eyebrow and
//  hue.
//
//  ---------------------------------------------------------------------------
//  ⚠️ FOUR TABS
//  ---------------------------------------------------------------------------
//
//    1. Carrying twins      finding out, the kinds of twins, families, food
//    2. Your care           the extra scans, what's more common, the signs
//    3. The birth           how and when twins are born
//    4. Getting ready for two   feeding two, the home, help, the bag
//
//  "Your care" pins the red flag. A twin pregnancy has more signs worth a
//  call than a single one, and early labour does not wait for her to pick a
//  card.
//
//  ⚠️ NO NEW TOOL. The one tool card is the shipped hospital bag
//  (`kLabourSurfaceBag`), whose own screen already has a twins switch. The
//  "I'm having twins" switch in her details, which onboarding promises ("You
//  can say so later"), is a screen the lead owes; see the report.
//
//  ⚠️ NEVER A PERSONAL CHANCE, NEVER THE BABIES' SEX. Population facts only,
//  and nothing that touches learning the sex of either baby (PCPNDT Act).
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../services/life_stage_store.dart';
import '../reads/read_images.dart' show readImageFor;
import 'pv_door_data.dart';

/// Tab ids. Constants for the reason `pv_door_scans.dart` gives: a typo in a
/// section's group renders it in no tab at all.
const String kTwinsTabCarrying = 'carrying';
const String kTwinsTabCare = 'care';
const String kTwinsTabBirth = 'birth';
const String kTwinsTabTwo = 'two';

// =============================================================================
//  The bracket
// =============================================================================

/// ⚠️ ENGLISH ON BOTH SIDES, BY POLICY (CLAUDE.md, 2026-08-27).
///
/// ⚠️ EVERY LAYER DECLARED, as `pregnancy_brackets.dart` does, because an
/// omitted layer inherits someone's assumption and the assumption is "live".
const Bracket kPregTwinsBracket = Bracket(
  id: 'pregnancy_twins',
  stage: LifeStage.pregnancy,
  theme: 'twins',
  // A warm rose, between the home grid's 288 violet and 344 pink, and away
  // from every alarm hue.
  hue: 322,
  label: LocalizedText(en: 'Twins and more', hi: 'Twins and more'),
  title: LocalizedText(en: 'Twins and more', hi: 'Twins and more'),
  blurb: LocalizedText(
      en: 'Carrying twins: your care, the birth, and getting ready for two.',
      hi: 'Carrying twins: your care, the birth, and getting ready for two.'),
  layers: {
    BracketLayer.content: BracketLayerSpec(
        state: LayerState.notCore,
        reason: 'Served by the Twins and more door (pv_door_twins.dart)'),
    BracketLayer.activities:
        BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
    BracketLayer.tools: BracketLayerSpec(
        state: LayerState.notCore,
        reason: 'The hospital bag (with its twins switch) rides the door'),
    BracketLayer.products: BracketLayerSpec(
        state: LayerState.notCore,
        reason: 'Twin gear rides the shared product checklist'),
    BracketLayer.course:
        BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
    BracketLayer.consult: BracketLayerSpec.live(['consults']),
    BracketLayer.extras: BracketLayerSpec(
        state: LayerState.notCore,
        reason: 'The signs to call about ride the Your care tab'),
  },
);

// =============================================================================
//  The door
// =============================================================================

/// Opens this door from Scans & tests and Labour prep (2026-09-29): it is
/// not a home tile, because it is for a few mothers.
const String kTwinsSurfaceDoor = 'pregnancy/twins';

final PvDoorPage kTwinsDoor = PvDoorPage(
  bracketId: 'pregnancy_twins',
  heroTitle: 'Two babies, one pregnancy.',
  heroBlurb: 'What carrying twins means for your care, the birth, and the '
      'months after, in plain words.',
  // ⚠️ NOT LOOKED AT BY THE AUTHOR OF THIS FILE, AND SAID SO (the same note
  // `pv_door_move.dart` carries: the image hosts were unreachable from this
  // session). It is the photograph the "Twin Pregnancy" report word already
  // ships, chosen by eye for that page (CC0, StockSnap, Freestocks.org), and
  // no other door wears it. The lead should look at it before release.
  heroImageUrl: readImageFor('finding_twin_pregnancy'),
  closingLine: 'ParentVeda explains and reminds. Your doctor decides, and '
      'your doctor knows your twins. If anything feels wrong, call them.',

  groups: [
    // -------------------------------------------------------------------------
    //  1. Carrying twins
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kTwinsTabCarrying,
      label: 'Carrying twins',
      mark: IntentMark.bodyMark,
      icon: Icons.favorite_border_rounded,
      hue: 322,
    ),

    // -------------------------------------------------------------------------
    //  2. Your care, with the signs pinned
    // -------------------------------------------------------------------------
    //  ⚠️ THE LINES AGREE WITH THE CONDITION PAGES, NOT A NEW LIST. Early
    //  labour from "Preterm labour", the headache and vision lines from
    //  "Preeclampsia", movements from the scan reads. The last line is the
    //  one sign of twin-to-twin transfusion a mother can notice herself.
    //  Each line carries its own urgency, because they are not all equal.
    PvDoorGroup(
      id: kTwinsTabCare,
      label: 'Your care',
      mark: IntentMark.scanFan,
      icon: Icons.monitor_heart_outlined,
      hue: 206,
      pinnedRedFlag: PvDoorRedFlag(
        title: 'With twins, call or go in if',
        lines: [
          PvDoorFlagLine('Any bleeding from the vagina: go to hospital '
              'straight away.'),
          PvDoorFlagLine('Regular tightenings, period-like pain or pressure '
              'low down before 37 weeks: call your doctor or go in the same '
              'day.',
              conditionId: 'preterm_labour'),
          PvDoorFlagLine('Fluid leaking or gushing from the vagina: call your '
              'doctor or go in the same day.'),
          PvDoorFlagLine('A severe headache with blurred vision or flashing '
              'lights, pain under your ribs, or sudden swelling of your face '
              'or hands: go to hospital.',
              conditionId: 'preeclampsia'),
          PvDoorFlagLine('Your babies moving less than usual: call your '
              "hospital straight away. Don't wait until tomorrow."),
          PvDoorFlagLine('Your bump growing much bigger quickly, feeling very '
              'tight, or new breathlessness: call your doctor today.'),
        ],
        footer: "If you can't get there safely, call 108 for an ambulance. You "
            'never need to be sure before you call.',
        surfaceId: kCondSurfaceUrgent,
      ),
    ),

    // -------------------------------------------------------------------------
    //  3. The birth
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kTwinsTabBirth,
      label: 'The birth',
      mark: IntentMark.calendarDay,
      icon: Icons.child_friendly_outlined,
      hue: 26,
    ),

    // -------------------------------------------------------------------------
    //  4. Getting ready for two
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kTwinsTabTwo,
      label: 'Getting ready for two',
      mark: IntentMark.bagMark,
      icon: Icons.home_outlined,
      hue: 160,
    ),
  ],

  sections: [
    // =========================================================================
    //  Carrying twins
    // =========================================================================
    PvDoorSection(
      group: kTwinsTabCarrying,
      heading: 'Finding out',
      tiles: [
        PvDoorGuideTile(
          title: "Finding out it's twins",
          blurb: 'How twins are found, the feelings that come with the news, '
              'and what changes now.',
          readId: 'preg_twins_read_finding_out',
        ),
        // The report word she may already have, linked, not copied.
        PvDoorEntryTile(
          title: 'Twin pregnancy on your scan report',
          blurb: 'What the words on your report mean, and what to ask.',
          library: PvDoorLibrary.finding,
          entryId: 'twin_pregnancy',
        ),
      ],
    ),
    PvDoorSection(
      group: kTwinsTabCarrying,
      heading: 'Understanding twins',
      tiles: [
        PvDoorGuideTile(
          title: 'Identical, non-identical, and the placenta',
          blurb: 'The kinds of twins in plain words, and why the early scan '
              'counts the placentas.',
          readId: 'preg_twins_read_types',
        ),
        PvDoorGuideTile(
          title: 'Do twins run in families?',
          blurb: "What makes twins more common, and what's only a story.",
          readId: 'preg_twins_read_families',
        ),
      ],
    ),
    PvDoorSection(
      group: kTwinsTabCarrying,
      heading: 'Your body with twins',
      tiles: [
        PvDoorGuideTile(
          title: 'Food, weight and tiredness with twins',
          blurb: 'Eating for three without forcing it, iron, and getting '
              'enough rest.',
          readId: 'preg_twins_read_food',
        ),
        // Nutrition owns the diet guide; linked, not restated.
        PvDoorEntryTile(
          title: 'Eating well with twins',
          blurb: 'The nutrition guide: meals, protein and iron for a twin '
              'pregnancy.',
          library: PvDoorLibrary.dietCondition,
          entryId: 'twins',
        ),
      ],
    ),

    // =========================================================================
    //  Your care
    // =========================================================================
    PvDoorSection(
      group: kTwinsTabCare,
      heading: 'Your scans and check-ups',
      tiles: [
        PvDoorGuideTile(
          title: 'Extra scans and check-ups with twins',
          blurb: 'Why you have more of them, how often, and what they look '
              'for.',
          readId: 'preg_twins_read_scans',
        ),
        PvDoorGuideTile(
          title: 'Twins sharing a placenta, and TTTS',
          blurb: 'What twin-to-twin transfusion is, and how the scans watch '
              'for it.',
          readId: 'preg_twins_read_scans',
          atHeading: 'What is TTTS?',
        ),
      ],
    ),
    PvDoorSection(
      group: kTwinsTabCare,
      heading: 'Staying well',
      tiles: [
        PvDoorGuideTile(
          title: "What's more common with twins, and when to call",
          blurb: 'The things doctors watch for, said calmly, and the signs '
              'that need a call.',
          readId: 'preg_twins_read_watch',
        ),
        PvDoorGuideTile(
          title: 'Feeling two babies move',
          blurb: "Why it's hard to tell who's who, and what to do if movements "
              'change.',
          readId: 'preg_twins_read_watch',
          atHeading: 'How do I keep track of two babies moving?',
        ),
      ],
    ),
    // ⚠️ THE CONDITION PAGES KEEP THE FACTS. Linked so the facts are never
    // typed twice.
    PvDoorSection(
      group: kTwinsTabCare,
      heading: 'The medical pages',
      tiles: [
        PvDoorEntryTile(
          title: 'Preeclampsia',
          blurb: 'The medical page: the signs, the checks, and the care.',
          library: PvDoorLibrary.condition,
          entryId: 'preeclampsia',
        ),
        PvDoorEntryTile(
          title: 'Preterm labour',
          blurb: 'The medical page: the signs of early labour, and what '
              'helps.',
          library: PvDoorLibrary.condition,
          entryId: 'preterm_labour',
        ),
      ],
    ),

    // =========================================================================
    //  The birth
    // =========================================================================
    PvDoorSection(
      group: kTwinsTabBirth,
      heading: 'How twins are born',
      tiles: [
        PvDoorGuideTile(
          title: 'How twins are born',
          blurb: 'Normal birth or caesarean, how the babies lie, and who '
              'decides.',
          readId: 'preg_twins_read_birth',
        ),
        PvDoorGuideTile(
          title: 'When are twins born?',
          blurb: 'What full term means for twins, and why the date is often '
              'earlier.',
          readId: 'preg_twins_read_birth',
          atHeading: 'When will my twins be born?',
        ),
        PvDoorGuideTile(
          title: 'The day itself, and the newborn unit',
          blurb: 'Who will be in the room, and why some twins spend time in '
              'the NICU.',
          readId: 'preg_twins_read_birth',
          atHeading: 'What happens on the day?',
        ),
      ],
    ),

    // =========================================================================
    //  Getting ready for two
    // =========================================================================
    PvDoorSection(
      group: kTwinsTabTwo,
      heading: 'Feeding two',
      tiles: [
        PvDoorGuideTile(
          title: 'Feeding twins',
          blurb: 'Breastfeeding two, feeding together or one at a time, and '
              'getting help.',
          readId: 'preg_twins_read_feeding',
        ),
      ],
    ),
    PvDoorSection(
      group: kTwinsTabTwo,
      heading: 'The home and the help',
      tiles: [
        PvDoorGuideTile(
          title: 'Getting ready for two',
          blurb: 'What you need two of, what you can share, and planning '
              'help at home.',
          readId: 'preg_twins_read_ready',
        ),
        // The shipped bag tool, whose own screen has a twins switch.
        PvDoorToolTile(
          title: 'Your hospital bag, for twins',
          blurb: "Switch on 'Expecting twins' and the list adds what two "
              'babies need.',
          surfaceId: kLabourSurfaceBag,
        ),
      ],
    ),
  ],
);

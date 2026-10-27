// =============================================================================
//  The Health door — the largest area, on seven tabs
// -----------------------------------------------------------------------------
//  The content is `kPpHealthSection` (`pp_health_content.dart`), rebuilt to
//  `ParentVeda_Health_rebuild.pdf`. The one parenting door with more than
//  five tabs, on the brief's own call ("Health is the biggest area in the app
//  and splits into six clean jobs. Forcing five would jam two unlike things
//  together"); Medicines became the seventh on 2026-10-07. The selector is
//  drawn for five; the rest ride the ring. (This header said "six" until
//  door 2's build, 2026-10-25.)
//
//  ⚠️ WHAT THE TABS ARE. Tab 1 is the default and the search: "tell me what
//  you're seeing". Tab 2 is the panic tab, one tap from anywhere via the
//  pinned jump on Tab 1. The other five are the calm jobs: papers and first
//  checks, shots, growth, medicines, prevention, ordered by his age.
//
//  ⚠️ THE MERGES SHOW AS ABSENCES. "Not sure what is wrong" is hidden — it
//  IS the What Changed flow, which leads Tab 1 as a tool. The vaccination
//  schedule chart, the create-your-emergency-card page and the records page
//  are `linkedOnly`: their tools lead their tabs instead, and a page that
//  opened the same tool from the rail would be the same thing twice.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../../screens/post_pregnancy/pp_vaccine_data.dart' show ppVaccineDueLine;
import 'pp_door_data.dart';

//  ⚠️ DOOR 2 OF THE DOOR-BY-DOOR PASS (built 2026-10-25, from
//  `docs/pp-door-plans/02-health.md`). What changed, and why:
//
//    · SOMETHING'S WRONG OPENS AT EVERY AGE, GET HELP NOW IS ALWAYS SECOND
//      (§2a). A sick child is why most parents open Health. The calm tabs
//      after them follow his age.
//    · A FIRST RAIL FOR HIS AGE (H2, `ageRail`). The illness rails are by
//      body part; a 3-week-old's four pages were on four of them.
//    · AN EXPERT ON EVERY TAB BUT GET HELP NOW (§3b), after the first rail,
//      and on Something's wrong with the safety line, because it shares the
//      tab with the emergency row.
//    · GET HELP NOW ENDS ON THE FIRST-AID CLASS, NEVER A CONSULT (H3).
//    · VACCINES SAYS "DUE IN 5 DAYS" ON ITS CARD (H1).
//    · TOOLS HAVE AGES: no home remedy for a baby under three months.

/// The paediatrician, on every calm tab.
const String _kPaed = 'pp_experts/Pediatrician';

final PpDoor kPpHealthDoor = PpDoor(
  sectionId: 'parenting_health',
  // CDC, Unsplash. A check-up: the baby upright on the table, a
  // stethoscope, an adult's hand on him. Calm, and nothing on it a page in
  // this door argues with. It has a dated look; swap the URL if a better
  // free one turns up (plus.unsplash.com photos are premium and unusable).
  heroImageUrl:
      'https://images.unsplash.com/photo-1632052999447-e542d08d4f7d?w=900&h=700&fit=crop',
  hiddenAreaIds: const ['not_sure'],
  // Plan §2a, row by row. Something's wrong and Get help now lead every age,
  // an explicit exception to "open on the most pages".
  tabOrder: const {
    'hb_nb': ['wrong', 'help', 'records', 'shots', 'growing', 'medicines', 'well'],
    'hb_infant': ['wrong', 'help', 'shots', 'growing', 'medicines', 'well', 'records'],
    'hb_toddler': ['wrong', 'help', 'medicines', 'well', 'shots', 'growing', 'records'],
    'hb_child': ['wrong', 'help', 'well', 'medicines', 'growing', 'shots', 'records'],
  },
  tabs: const [
    PpDoorTab(
      id: 'wrong',
      label: 'Something\'s wrong',
      icon: Icons.thermostat_outlined,
      hue: 28,
      areaIds: ['fever', 'cough_cold', 'tummy', 'skin', 'other_illness'],
      jumpToTabId: 'help',
      jumpTitle: 'Is this an emergency?',
      // H2 (look approved 2026-10-24, v4): the emergency row on top, this
      // rail next, the paediatrician row after it, never stacked.
      ageRail: {
        'hb_nb': PpAgeRail('In the first three months', [
          'fever_under_3m', 'ill_jaundice', 'skin_newborn', 'tummy_colic',
          'cold_blocked_nose', 'ill_thrush',
        ]),
        'hb_infant': PpAgeRail('Common at 3 to 12 months', [
          'ill_teething_fever', 'cold_common', 'tummy_diarrhoea',
          'skin_nappy_rash', 'skin_eczema', 'ill_ear', 'ill_febrile_seizure',
        ]),
        'hb_toddler': PpAgeRail('The creche years', [
          'cold_common', 'skin_hfmd', 'tummy_diarrhoea', 'tummy_vomiting',
          'ill_ear', 'cough_breathing', 'ill_eyes',
        ]),
        'hb_child': PpAgeRail('Common at 3 to 5 years', [
          'ill_throat', 'cold_common', 'tummy_constipation', 'ill_ear',
          'skin_chickenpox', 'ill_worms',
        ]),
      },
      expert: PpDoorClosing(
        label: 'Talk to a paediatrician today',
        blurb: 'Not an emergency, but not right? 1:1, on video.',
        surfaceId: _kPaed,
        note: 'Not for an emergency. For that, Get help now.',
      ),
      tools: [
        PpDoorTool(
          label: 'Fever check',
          blurb: 'His age and his temperature, and a straight answer: see a '
              'doctor now, today, or watch at home.',
          surfaceId: 'pp_fever_check',
          icon: Icons.thermostat_outlined,
        ),
        // ⚠️ MERGED. "This IS the library's 'Not sure what is wrong'. One
        // flow, not a tool and a duplicate library entry."
        PpDoorTool(
          label: 'Something suddenly different',
          blurb: 'Start from what changed and find the likely cause.',
          surfaceId: 'pp_what_changed',
          icon: Icons.change_circle_outlined,
        ),
        // "What to tell the doctor" is part of a sick-day visit (§2c). The
        // same tool leads Records.
        PpDoorTool(
          label: 'Before you see the doctor',
          blurb: 'A visit summary pulled from his record, the questions to '
              'ask, and a share to the paediatrician.',
          surfaceId: 'pp_doctor_visit',
          icon: Icons.medical_services_outlined,
          atEnd: true,
        ),
      ],
    ),
    // No expert row and no consult on this tab (§2g, §3a): an emergency goes
    // to 112 or a hospital, never to a video call. It ends on the first-aid
    // class instead (H3), after the footer.
    PpDoorTab(
      id: 'help',
      label: 'Get help now',
      icon: Icons.emergency_outlined,
      hue: 12,
      areaIds: ['emergency'],
      redFlagPageId: 'health_go_now',
      tools: [
        PpDoorTool(
          label: 'Emergency card, ready to show',
          blurb: 'Blood group, allergies, weight and the two numbers to call. '
              'One tap, offline.',
          surfaceId: 'pp_emergency_card',
          icon: Icons.badge_outlined,
        ),
      ],
      footer: 'If your child seems wrong to you and a screen says otherwise, believe '
          'yourself.',
      closing: PpDoorClosing(
        label: 'Learn it on a calm day: baby first aid and CPR',
        blurb: 'Choking, burns, falls and fits, with a mannequin. Live, 2 hours.',
        surfaceId: 'pp_class/Baby first aid and CPR',
      ),
    ),
    PpDoorTab(
      id: 'shots',
      label: 'Vaccines',
      icon: Icons.vaccines_outlined,
      hue: 206,
      areaIds: ['vaccines'],
      dueLine: ppVaccineDueLine,
      expert: PpDoorClosing(
        label: 'Ask a paediatrician',
        blurb: 'A missed or delayed dose? 1:1, on video.',
        surfaceId: _kPaed,
      ),
      tools: [
        PpDoorTool(
          label: 'Vaccines, and what is due next',
          blurb: 'What is done, what is due, an alarm, and a doctor-ready '
              'record. The IAP schedule.',
          surfaceId: 'pp_vaccines',
          icon: Icons.vaccines_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'growing',
      label: 'Growing well',
      icon: Icons.show_chart_outlined,
      hue: 152,
      areaIds: ['growth', 'long_term'],
      expert: PpDoorClosing(
        label: 'Talk to a paediatrician',
        blurb: 'Worried about his weight or height? 1:1, on video.',
        surfaceId: _kPaed,
      ),
      tools: [
        // The same Growth journey as Feeding. Single source; it owns the
        // percentile reads.
        PpDoorTool(
          label: 'Weight, height and head size',
          blurb: 'His own curve, no charts to read yourself, and the reads '
              'that go with it.',
          surfaceId: 'pp_growth',
          icon: Icons.show_chart_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'well',
      // §2b: shorter on the card, same meaning. Kept for revert:
      // label: 'Keeping your child well',
      label: 'Keeping well',
      icon: Icons.spa_outlined,
      hue: 96,
      areaIds: ['prevention', 'teeth_eyes_ears'],
      // The child dermatologist is the one specialist live today; teeth,
      // eyes and ears point at owed ones from their pages (§3d, S8b).
      expert: PpDoorClosing(
        label: 'Talk to a child skin doctor',
        blurb: 'Teeth, eyes, skin: the right specialist. 1:1, on video.',
        surfaceId: 'pp_experts/Child derma',
      ),
      tools: [
        // The single source every per-illness remedy card opens, filtered.
        PpDoorTool(
          label: 'Home remedies, marked honestly',
          // Matches what the remedy data holds (2026-10-07): an age and the
          // cautions, not a helps / comforts / unsafe verdict, which no remedy
          // carries yet. Kept for revert: 'Every nuskha, marked helps, only
          // comforts, or unsafe, with when not to use it.'
          blurb: 'Gentle home remedies by age, with the cautions, and when to '
              'see a doctor instead.',
          surfaceId: 'pp_nuskhe',
          icon: Icons.eco_outlined,
          // No home remedy is right for a baby under three months (§2c).
          bands: ['hb_infant', 'hb_toddler', 'hb_child'],
        ),
      ],
    ),
    // Medicines, a tab of its own (gap analysis P2, 2026-10-07).
    PpDoorTab(
      id: 'medicines',
      label: 'Medicines, safely',
      icon: Icons.medication_outlined,
      hue: 206,
      areaIds: ['medicines'],
      expert: PpDoorClosing(
        label: 'Ask a paediatrician before you give it',
        blurb: 'Unsure about a medicine? 1:1, on video.',
        surfaceId: _kPaed,
      ),
      footer: 'Never a dose from us. The dose comes from your doctor or the '
          'label, by weight.',
    ),
    PpDoorTab(
      id: 'records',
      // §2b: it holds the newborn checks, and the old label hid them. Kept
      // for revert: label: 'Records and the visit',
      label: 'Records and first checks',
      icon: Icons.folder_open_outlined,
      hue: 268,
      areaIds: ['records', 'newborn_checks'],
      expert: PpDoorClosing(
        // Unisex, the user's word (2026-10-27). Kept for revert:
        // label: 'Book his next check-up',
        label: 'Book the next check-up',
        blurb: 'A paediatrician, 1:1, on video.',
        surfaceId: _kPaed,
      ),
      tools: [
        // The dashboard: status tiles, upcoming, the health timeline, and
        // his papers and ID documents. One tool, as the brief asks.
        PpDoorTool(
          label: 'Health record and papers',
          blurb: 'The living record: visits, vaccinations, illnesses, '
              'prescriptions and documents in one place.',
          surfaceId: 'pp_health_home',
          icon: Icons.folder_open_outlined,
        ),
        // The same card twice (Get help now has it), and the dashboard above
        // links it (§2c). Kept for revert:
        // PpDoorTool(
        //   label: 'Emergency card',
        //   blurb: 'Create it once, show it in one tap.',
        //   surfaceId: 'pp_emergency_card',
        //   icon: Icons.badge_outlined,
        // ),
        PpDoorTool(
          label: 'Before you see the doctor',
          blurb: 'A visit summary pulled from his record, the questions to '
              'ask, and a share to the paediatrician.',
          surfaceId: 'pp_doctor_visit',
          icon: Icons.medical_services_outlined,
        ),
      ],
    ),
  ],
  closing: const PpDoorClosing(
    label: 'Talk to a paediatrician',
    blurb: 'For the worry that does not look like an emergency but does not '
        'feel fine either.',
    surfaceId: 'pp_experts/Pediatrician',
  ),
);

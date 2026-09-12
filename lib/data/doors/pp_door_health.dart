// =============================================================================
//  The Health door — the largest area, on six tabs
// -----------------------------------------------------------------------------
//  The content is `kPpHealthSection` (`pp_health_content.dart`), rebuilt to
//  `ParentVeda_Health_rebuild.pdf`. This is the one parenting door with SIX
//  tabs, on the brief's own call ("Health is the biggest area in the app and
//  splits into six clean jobs. Forcing five would jam two unlike things
//  together") — and on the user's, to see six on a phone before deciding.
//  The selector is drawn for five; the sixth rides the ring. If five is the
//  answer, the merge the brief names is Growing well into Keeping him well.
//
//  ⚠️ WHAT THE TABS ARE. Tab 1 is the default and the search: "tell me what
//  you're seeing". Tab 2 is the panic tab, one tap from anywhere via the
//  pinned jump on Tab 1. The other four are the calm jobs: shots, growth,
//  prevention, papers.
//
//  ⚠️ THE MERGES SHOW AS ABSENCES. "Not sure what is wrong" is hidden — it
//  IS the What Changed flow, which leads Tab 1 as a tool. The vaccination
//  schedule chart, the create-your-emergency-card page and the records page
//  are `linkedOnly`: their tools lead their tabs instead, and a page that
//  opened the same tool from the rail would be the same thing twice.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_door_data.dart';

final PpDoor kPpHealthDoor = PpDoor(
  sectionId: 'parenting_health',
  // CDC, Unsplash. A check-up: the baby upright on the table, a
  // stethoscope, an adult's hand on him. Calm, and nothing on it a page in
  // this door argues with. It has a dated look; swap the URL if a better
  // free one turns up (plus.unsplash.com photos are premium and unusable).
  heroImageUrl:
      'https://images.unsplash.com/photo-1632052999447-e542d08d4f7d?w=900&h=700&fit=crop',
  hiddenAreaIds: const ['not_sure'],
  tabs: const [
    PpDoorTab(
      id: 'wrong',
      label: 'Something\'s wrong',
      icon: Icons.thermostat_outlined,
      hue: 28,
      areaIds: ['fever', 'cough_cold', 'tummy', 'skin', 'other_illness'],
      jumpToTabId: 'help',
      jumpTitle: 'Is this an emergency?',
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
      ],
    ),
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
      footer: 'If he seems wrong to you and a screen says otherwise, believe '
          'yourself.',
    ),
    PpDoorTab(
      id: 'shots',
      label: 'His shots',
      icon: Icons.vaccines_outlined,
      hue: 206,
      areaIds: ['vaccines'],
      tools: [
        PpDoorTool(
          label: 'His shots, and what is due next',
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
      areaIds: ['growth'],
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
      label: 'Keeping him well',
      icon: Icons.spa_outlined,
      hue: 96,
      areaIds: ['prevention'],
      tools: [
        // The single source every per-illness remedy card opens, filtered.
        PpDoorTool(
          label: 'Home remedies, marked honestly',
          blurb: 'Every nuskha, marked helps, only comforts, or unsafe, with '
              'when not to use it.',
          surfaceId: 'pp_nuskhe',
          icon: Icons.eco_outlined,
        ),
      ],
    ),
    PpDoorTab(
      id: 'records',
      label: 'His records and the visit',
      icon: Icons.folder_open_outlined,
      hue: 268,
      areaIds: ['records'],
      tools: [
        // The dashboard: status tiles, upcoming, the health timeline, and
        // his papers and ID documents. One tool, as the brief asks.
        PpDoorTool(
          label: 'His health record, and his papers',
          blurb: 'The living record: visits, vaccinations, illnesses, '
              'prescriptions and documents in one place.',
          surfaceId: 'pp_health_home',
          icon: Icons.folder_open_outlined,
        ),
        PpDoorTool(
          label: 'Emergency card',
          blurb: 'Create it once, show it in one tap.',
          surfaceId: 'pp_emergency_card',
          icon: Icons.badge_outlined,
        ),
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

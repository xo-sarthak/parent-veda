// =============================================================================
//  Which parenting experts are real — and the page for the ones who are not
// -----------------------------------------------------------------------------
//  Parenting gap analysis, Behind · Trust (P1, 2026-10-07): "A medical council
//  number and a named hospital on a person who does not exist is the most
//  serious item in this report." The bundled parenting roster in
//  pp_experts_data.dart (Dr. Neha Sharma with "DMC Reg. 51872" at a named Saket
//  hospital, Dr. Ananya Rao, the twelve find-help placeholders) is fiction;
//  community_data.dart says so in as many words.
//
//  ⚠️ REAL MEANS PUBLISHED IN THE PANEL. A doctor added in Directus arrives as
//  an `expert_profiles` row through ExpertStore and is shown as normal; a
//  published row with a bundled id supersedes the bundled stub (the
//  `mergedExperts()` rule), so it becomes real too. Nothing here needs editing
//  the day the first real expert joins.
//
//  ⚠️ PARENTING'S ROSTER ONLY. `kExperts` also carries the pregnancy and
//  movement rosters (one registry, see its comment); those belong to their own
//  stages' passes and are left exactly as they are.
// =============================================================================

import 'package:flutter/material.dart';

import '../../experts/pregnancy_experts.dart';
import '../../experts/yoga_experts.dart';
import '../../services/expert_store.dart';
import '../../services/programme_store.dart';
import 'pp_experts_data.dart';
import 'pp_learning_data.dart' show kLearningPrograms;
import 'pp_opening_soon.dart';

/// The ids of the bundled parenting roster: everything in `kExperts` that is
/// not the pregnancy or movement roster appended to it.
Set<String> get kPpBundledExpertIds {
  final others = {
    for (final e in kPregnancyExperts) e.id,
    for (final e in kYogaExperts) e.id,
  };
  return {for (final e in kExperts) if (!others.contains(e.id)) e.id};
}

/// True for a parenting expert who exists only in the bundled seed, so must not
/// be shown to a parent as bookable, registered or practising anywhere.
bool ppExpertIsPlaceholder(Expert e) {
  if (!kPpBundledExpertIds.contains(e.id)) return false;
  // `all` IS the bundled seed until the panel has served rows, so only rows
  // that came from the backend count as published.
  final store = ExpertStore.instance;
  return !(store.isServingBackendContent && store.all.any((x) => x.id == e.id));
}

/// The page a parent sees instead of a placeholder's profile, booking or list.
Widget ppExpertsOpeningSoon() => const PpOpeningSoonScreen(
      key: ValueKey('pp_experts_opening_soon'),
      id: 'experts',
      title: 'Our first experts are joining',
      intro: "We're adding paediatricians, lactation consultants and child psychologists "
          "we have checked ourselves. Booking opens with them.",
      points: [
        (Icons.verified_user_outlined, 'Every expert’s registration is checked by us before they appear here.'),
        (Icons.videocam_outlined, 'Private video consults, booked and held inside ParentVeda.'),
        (Icons.local_hospital_outlined, 'Worried right now? Your own doctor or the nearest hospital comes first.'),
      ],
    );

// -----------------------------------------------------------------------------
//  Courses, masterclasses and cohorts
// -----------------------------------------------------------------------------
//  The same rule for programmes: the 15 bundled parenting programmes
//  (pp_learning_data.dart) carry fixed ratings, "N parents", seat counts and
//  past live dates, and no lesson has been filmed (gap analysis P1, Behind ·
//  Trust: "Show each programme as Opening soon. Tell me when it opens."). A
//  programme published in the panel (ProgrammeStore) is real and sells as
//  normal, including one that supersedes a bundled id.

/// True for a bundled parenting programme that the panel has not published.
bool ppProgramIsPlaceholder(String id) {
  if (!kLearningPrograms.any((p) => p.id == id)) return false;
  final store = ProgrammeStore.instance;
  return !(store.isServingBackendContent && store.all.any((p) => p.id == id));
}

/// The page a parent sees instead of a placeholder programme's sales page.
Widget ppProgramOpeningSoon(String title, String id) => PpOpeningSoonScreen(
      key: const ValueKey('pp_program_opening_soon'),
      id: 'course:$id',
      title: title,
      intro: "We're still making this, so it isn't on sale yet. Tell us you'd like it "
          "and we'll let you know here when it opens.",
      points: const [
        (Icons.play_circle_outline_rounded, 'Short lessons, filmed with doctors and parents in Indian homes.'),
        (Icons.schedule_outlined, 'Watch at your own pace, or join live when there is a live version.'),
        (Icons.how_to_reg_outlined, 'Your interest helps us decide which one to make first.'),
      ],
    );

// =============================================================================
//  DoctorDirectory — one list of doctors across BOTH stages
// -----------------------------------------------------------------------------
//  Doctors live in two different catalogue models: parenting experts (kExperts,
//  with consult timings) and pregnancy specialists (kSpecialists). The doctor
//  app should not care which — a doctor is a doctor. This unifies them into one
//  [DoctorInfo] shape so the picker lists both, the dashboard resolves either,
//  and the roster (which already keys off the shared expertId) just works.
//
//  Each carries a [stage] so the doctor app can show a Pregnancy | Parenting
//  toggle and so the picker can group them by side.
// =============================================================================

import '../data/prepare_data.dart';
import '../services/expert_store.dart';

enum DoctorStage { pregnancy, parenting }

class DoctorInfo {
  const DoctorInfo({
    required this.id,
    required this.name,
    required this.credential,
    required this.category,
    required this.blurb,
    required this.rating,
    required this.stage,
  });

  final String id;
  final String name;
  final String credential;
  final String category;
  final String blurb;
  final String rating;
  final DoctorStage stage;
}

/// Every doctor a person could log in as — parenting experts (those who take
/// consults) and pregnancy specialists.
///
/// ⚠️ THIS USED TO FILTER ON `timings`, and it silently excluded every doctor
/// onboarded through the admin panel. The compiled catalogue carries a
/// human-written "Mon–Sat, 10–1" string, so the filter looked like a harmless
/// "does this expert publish hours?" test. But `expert_profiles` has no
/// `timings` column ON PURPOSE — DIRECTUS-SETUP §4c states it, because real
/// availability comes from `doctor_schedule`, not from prose. So a server
/// expert arrived with an empty string, failed the filter, and vanished from
/// the directory that resolves their own name.
///
/// The rule that replaces it: a doctor belongs here if they exist. Whether
/// they are BOOKABLE is a different question, answered by `takes_consults` and
/// by their schedule — not by whether someone typed an opening-hours sentence.
List<DoctorInfo> allDoctors() => [
      for (final e in mergedExperts())
        DoctorInfo(
          id: e.id,
          name: e.name,
          credential: e.credential,
          category: e.category,
          blurb: e.blurb,
          rating: e.rating,
          stage: DoctorStage.parenting,
        ),
      for (final s in kSpecialists)
        DoctorInfo(
          id: s.id,
          name: s.name.now,
          credential: s.cred.now,
          category: s.role.now,
          blurb: s.about.now,
          rating: s.rating,
          stage: DoctorStage.pregnancy,
        ),
    ];

List<DoctorInfo> doctorsForStage(DoctorStage stage) =>
    allDoctors().where((d) => d.stage == stage).toList();

/// Resolve a doctor by id from either catalogue, or null if there is no such
/// doctor.
///
/// ⚠️ THIS USED TO RETURN `allDoctors().first` when the id was unknown, so the
/// dashboard "always had someone to render". That someone was a REAL OTHER
/// DOCTOR. A newly onboarded expert signing into ParentVeda+ for the first time
/// would be greeted by a stranger's name, credential and blurb — no error, no
/// crash, nothing in a log. Two screens already carried comments warning about
/// the trap; neither could fix it, because the fallback was inside here.
///
/// Null is the honest answer, and it forces every caller to decide what an
/// unknown expert looks like. "Always render something" is only a kindness
/// when the something is true.
DoctorInfo? doctorInfoById(String id) {
  for (final d in allDoctors()) {
    if (d.id == id) return d;
  }
  return null;
}

/// Which stage an expert works in. Defaults to parenting for an unknown id —
/// this one genuinely is a display default (it picks a tab), not an identity.
DoctorStage stageOf(String id) =>
    doctorInfoById(id)?.stage ?? DoctorStage.parenting;

/// The first doctor of a stage — used by the testing stage toggle to jump to a
/// representative doctor on the other side.
DoctorInfo? firstDoctorOf(DoctorStage stage) {
  final list = doctorsForStage(stage);
  return list.isEmpty ? null : list.first;
}

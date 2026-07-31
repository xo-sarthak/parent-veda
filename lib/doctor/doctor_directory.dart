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
List<DoctorInfo> allDoctors() => [
      for (final e in mergedExperts().where((e) => e.timings.trim().isNotEmpty))
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
          name: s.name,
          credential: s.cred,
          category: s.role,
          blurb: s.about,
          rating: s.rating,
          stage: DoctorStage.pregnancy,
        ),
    ];

List<DoctorInfo> doctorsForStage(DoctorStage stage) =>
    allDoctors().where((d) => d.stage == stage).toList();

/// Resolve a doctor by id from either catalogue. Falls back to the first doctor
/// so the dashboard always has someone to render.
DoctorInfo doctorInfoById(String id) {
  for (final d in allDoctors()) {
    if (d.id == id) return d;
  }
  return allDoctors().first;
}

DoctorStage stageOf(String id) => doctorInfoById(id).stage;

/// The first doctor of a stage — used by the testing stage toggle to jump to a
/// representative doctor on the other side.
DoctorInfo? firstDoctorOf(DoctorStage stage) {
  final list = doctorsForStage(stage);
  return list.isEmpty ? null : list.first;
}

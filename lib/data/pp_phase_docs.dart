// =============================================================================
//  My Child phase docs — the user's phase-wise content, the source of truth
// -----------------------------------------------------------------------------
//  2026-10-13. The user's "My Child phase-wise content" docs, PH001–PH015, one
//  per age phase 1–15 of `kPhasesAuthored` (pp_phases_data.dart; matched by
//  age: PH001 is 0–4 weeks, PH015 is 16–18 months). Each holds three things:
//
//    · the phase page — Hero → Living Through This Phase → Child Snapshot →
//      When to Contact Your Doctor;
//    · a milestone page per snapshot domain;
//    · the activity set.
//
//  The user, 2026-10-13: "follow the document as the source of truth". Where a
//  phase has a doc, the screens draw the doc; the older AAP draft text stays
//  in pp_phases_data.dart for what the docs do not cover (the India note,
//  feeding and sleep numbers, growth ranges, sources) and for phases 16–20.
//
//  ⚠️ GENERATED. `lib/data/pp_phase_docs/phase_NN.dart` and `index.dart` are
//  written by `tools/phase_pages/docx_to_dart.py` from the docx files. Fix a
//  sentence in the doc and re-run; a hand edit is lost on the next run.
//
//  The docs say "your baby" and "they"; `ppFillChild` leaves both alone.
//  Every doc carries "Needs paediatric panel sign-off": shipped with its
//  doctor lines on the user's word, review owed (STILL-OPEN §85).
// =============================================================================

import 'pp_phase_docs/index.dart';
export 'pp_phase_docs/index.dart' show kPpPhaseDocList;

/// The docs' five snapshot domains, in the docs' fixed order.
enum PpDocDomain { brain, physical, language, emotional, nutrition }

extension PpDocDomainX on PpDocDomain {
  String get label => switch (this) {
        PpDocDomain.brain => 'Brain',
        PpDocDomain.physical => 'Physical',
        PpDocDomain.language => 'Language',
        PpDocDomain.emotional => 'Emotional',
        PpDocDomain.nutrition => 'Nutrition',
      };
}

/// A "Living Through This Phase" card: a title, its paragraph, and its tips.
class PpLivingCard {
  const PpLivingCard(this.title, this.body, this.tips);
  final String title;
  final String body;
  final List<String> tips;
}

/// One Child Snapshot card.
class PpSnapshot {
  const PpSnapshot(this.domain, this.title, this.line);
  final PpDocDomain domain;
  final String title;
  final String line;
}

/// A milestone page, one per snapshot domain.
class PpMilestonePage {
  const PpMilestonePage({
    required this.domain,
    required this.title,
    required this.typicalAge,
    required this.summary,
    required this.whatIsIt,
    required this.whyItMatters,
    required this.insight,
    required this.ways,
    required this.activities,
    required this.relatedTopics,
    required this.doctor,
  });
  final PpDocDomain domain;
  final String title;
  final String typicalAge;

  /// The one-line summary.
  final String summary;
  final String whatIsIt;
  final String whyItMatters;

  /// "ParentVeda Insight".
  final String insight;

  /// "Ways to Support".
  final List<String> ways;

  /// The activity titles the page names (each one of [PpPhaseDoc.activities]).
  final List<String> activities;
  final List<String> relatedTopics;

  /// "When to Contact Your Doctor".
  final List<String> doctor;
}

/// An activity from the phase's activity set.
class PpPhaseActivity {
  const PpPhaseActivity({
    required this.title,
    required this.domain,
    required this.intro,
    required this.builds,
    required this.why,
    required this.need,
    required this.steps,
    required this.remember,
    required this.safe,
    required this.variations,
    required this.linked,
  });
  final String title;
  final PpDocDomain domain;
  final String intro;

  /// "What It Builds".
  final List<String> builds;

  /// "Why ParentVeda Recommends It".
  final String why;

  /// "What You'll Need".
  final List<String> need;

  /// "How To Do It".
  final List<String> steps;

  /// "Things to Remember".
  final List<String> remember;

  /// "Keep It Safe".
  final List<String> safe;
  final String variations;

  /// "Linked Milestones", by title.
  final List<String> linked;
}

/// One phase's doc.
class PpPhaseDoc {
  const PpPhaseDoc({
    required this.phase,
    required this.code,
    required this.name,
    required this.hero,
    required this.living,
    required this.snapshot,
    required this.doctor,
    required this.milestones,
    required this.activities,
  });

  /// The app phase number, 1–15.
  final int phase;

  /// "PH001".
  final String code;

  /// "The Settling In".
  final String name;

  /// The hero, paragraph by paragraph.
  final List<String> hero;
  final List<PpLivingCard> living;

  /// Exactly five, in [PpDocDomain] order.
  final List<PpSnapshot> snapshot;

  /// "When to Contact Your Doctor" on the phase page.
  final List<String> doctor;

  /// One per snapshot domain, in the same order.
  final List<PpMilestonePage> milestones;
  final List<PpPhaseActivity> activities;

  PpMilestonePage? milestoneFor(PpDocDomain d) {
    for (final m in milestones) {
      if (m.domain == d) return m;
    }
    return null;
  }
}

/// Every phase with a doc, by phase number.
final Map<int, PpPhaseDoc> kPpPhaseDocs = {
  for (final d in kPpPhaseDocList) d.phase: d,
};

/// The doc for app phase [phase], or null when none covers it yet.
PpPhaseDoc? ppPhaseDocFor(int phase) => kPpPhaseDocs[phase];

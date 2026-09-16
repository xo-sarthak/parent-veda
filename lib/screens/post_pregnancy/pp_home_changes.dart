// =============================================================================
//  pp_home_changes — "How your baby is doing", derived from the phase
// -----------------------------------------------------------------------------
//  The V3 home design (2026-09-16) asks the "How {name} is doing" section to
//  show ONLY what is actually changing at this age, under the existing
//  category labels — a handful of cards, not a grid of every developmental
//  area. "If a 2–2.5-year-old has only a few meaningful changes happening,
//  show those few."
//
//  ⚠️ NOTHING IS WRITTEN HERE. The cards are DERIVED from `AgePhase.milestones`
//  in pp_phases_data.dart — the AAP/CDC 75% milestones, three to six per
//  phase, each already tagged with the domain it belongs to. That list is the
//  honest answer to "what is changing now": it is per-phase by construction,
//  it is the clinical framework the app already stands on, and a phase with
//  few milestones yields few cards without any rule saying so.
//
//  One card per DOMAIN that has a milestone this phase (Brain, Physical,
//  Language, Emotional, Self-care — the snapshot's existing labels), the first
//  milestone as the title and the rest as "also". A domain with nothing
//  changing at this age simply does not appear.
//
//  WHY NOT `kDevAreas`. The snapshot this replaces read `DevArea.stage` and
//  `DevArea.word` — but those are fixed at roughly a four-month-old ("Musical
//  babble", "Cause & effect") and do not move with the child. Showing them to
//  a parent of a two-year-old as "what is changing" would be wrong in the
//  specific way this section exists to avoid.
//
//  The detail sheet (video → text → more) is assembled the same way: the
//  domain's video category, the milestones as the written explanation with
//  the phase's own reassurance line, and "more" from the phase's reads, an
//  age-suitable activity in the domain, and the Development door. Every
//  piece is something that already ships; this file only points at it.
// =============================================================================

import 'pp_development_data.dart';
import 'pp_grow_data.dart';
import 'pp_phases_data.dart';
import 'pp_reading_data.dart';
import 'pp_watch_data.dart';

/// One card in "How {name} is doing" — a domain, and what is changing in it
/// this phase.
class PhaseChange {
  const PhaseChange({
    required this.domain,
    required this.phase,
    required this.milestones,
  });

  final PhaseDomain domain;
  final AgePhase phase;

  /// This domain's milestones for this phase, in the phase's own order.
  /// Never empty — a domain with none does not become a card.
  final List<PhaseMilestone> milestones;

  /// The card's title: the first milestone, as written.
  String get title => milestones.first.text;

  /// The chip. The snapshot's existing category words, so the section keeps
  /// the labels a parent has already learned.
  String get category => switch (domain) {
        PhaseDomain.cognitive => 'Brain',
        PhaseDomain.motor => 'Physical',
        PhaseDomain.language => 'Language',
        PhaseDomain.social => 'Emotional',
        PhaseDomain.adaptive => 'Self-care',
      };

  /// The chip's hue on the controlled-pastel wheel — the same hue the
  /// matching door tile and development area already use.
  double get hue => switch (domain) {
        PhaseDomain.cognitive => 268,
        PhaseDomain.motor => 42,
        PhaseDomain.language => 344,
        PhaseDomain.social => 285,
        PhaseDomain.adaptive => 150,
      };

  /// The one line under the title. When the domain has more than one
  /// milestone this phase, the others; otherwise what the milestone MEANS —
  /// the AAP 75% threshold, said plainly, which is the only claim the data
  /// actually makes.
  String get notice {
    if (milestones.length > 1) {
      final rest = milestones.skip(1).map((m) => _lower(m.text)).join(', and ');
      return 'Also: $rest.';
    }
    return 'Most children can do this by the end of ${phase.ageLabel}.';
  }

  /// The development areas this domain maps onto, for the activity and video
  /// lookups. The first is the primary.
  List<String> get areaIds => switch (domain) {
        PhaseDomain.cognitive => const ['cognitive'],
        PhaseDomain.motor => const ['gross_motor', 'fine_motor'],
        PhaseDomain.language => const ['language'],
        PhaseDomain.social => const ['emotional', 'social'],
        PhaseDomain.adaptive => const ['selfcare'],
      };

  /// The sheet's video: the domain's category first, the phase's video as the
  /// fallback, and null only when the catalogue has neither. A card must not
  /// promise a video it cannot play, so the sheet omits the player when this
  /// is null rather than drawing an empty cover.
  WatchVideo? get video {
    final byArea = watchByCategory(watchCategoryForArea(areaIds.first));
    if (byArea.isNotEmpty) return byArea.first;
    if (phase.videoId != null) {
      final hit = kWatchVideos.where((v) => v.id == phase.videoId);
      if (hit.isNotEmpty) return hit.first;
    }
    final byPhase = watchByCategory(watchCategoryForPhase(phase));
    return byPhase.isEmpty ? null : byPhase.first;
  }

  /// The written explanation, in order: what this domain is doing this
  /// phase, then the phase's own "should I be worried?" line. Every phase
  /// has one, and it is the sentence a parent most needs after a list of
  /// things her child "should" be doing.
  ///
  /// ⚠️ THE MILESTONE IS QUOTED, NOT CONJUGATED. The texts are written
  /// third-person singular ("Calms when held"), and the first cut spliced
  /// them after "most children" — "most children calms when held" was on
  /// the phone. So the milestone stands as its own sentence and the claim
  /// about most children follows it, with "this" or "these" doing the
  /// pointing.
  List<String> paragraphs() => [
        if (milestones.length == 1)
          '${milestones.first.text}. Most children can do this by the end of '
              '${phase.ageLabel}. It is one of the things changing in '
              '${_lower(phase.name)}, and it arrives on its own timetable.'
        else
          '${milestones.map((m) => m.text).join('. ')}. Most children can do '
              'these by the end of ${phase.ageLabel}. They are the '
              '${category.toLowerCase()} changes of ${_lower(phase.name)}, '
              'and they arrive on their own timetable.',
        phase.reassurance,
      ];

  /// A read for "More on this": the phase's own articles first, then the
  /// domain's collection. Null when neither has one.
  ReadArticle? get read {
    for (final id in phase.articleIds) {
      final hit = readCatalog.where((a) => a.id == id);
      if (hit.isNotEmpty) return hit.first;
    }
    final coll = articlesInCollection(readCollectionForArea(areaIds.first));
    return coll.isEmpty ? null : coll.first;
  }

  /// An age-suitable activity in this domain, or null.
  DevActivity? activityFor(int ageMonths) {
    final pool = growActivitiesForAge(ageMonths).where((a) => areaIds.contains(a.areaId));
    // Exact fit first; the widened band only if the domain has nothing at
    // this exact age. Same rule as the home's activity store.
    for (final a in pool) {
      if (growSuitsAge(a, ageMonths)) return a;
    }
    return pool.isEmpty ? null : pool.first;
  }
}

String _lower(String s) =>
    s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

/// The cards for [phase], one per domain that has a milestone, in the order
/// the domains first appear in the phase's own list. Empty only for a phase
/// with no milestones, which the seed data does not contain — and the home
/// renders an invitation rather than a blank in that case.
List<PhaseChange> phaseChangesFor(AgePhase phase) {
  final order = <PhaseDomain>[];
  final by = <PhaseDomain, List<PhaseMilestone>>{};
  for (final m in phase.milestones) {
    if (!by.containsKey(m.domain)) order.add(m.domain);
    (by[m.domain] ??= []).add(m);
  }
  return [
    for (final d in order)
      PhaseChange(domain: d, phase: phase, milestones: by[d]!),
  ];
}

/// "Three things are changing this month." — the line under the section
/// title. Counts cards, in words up to ten, and reads the phase's own unit.
String phaseChangesLine(List<PhaseChange> changes, AgePhase phase) {
  const words = [
    'No', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
    'Nine', 'Ten',
  ];
  final n = changes.length;
  final count = n < words.length ? words[n] : '$n';
  final thing = n == 1 ? 'thing is' : 'things are';
  return '$count $thing changing at ${phase.ageLabel}.';
}

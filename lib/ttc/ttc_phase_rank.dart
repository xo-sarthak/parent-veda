// =============================================================================
//  ttc_phase_rank.dart - a TTC door opens on where she is today
// =============================================================================
//
// Global pass item 13 (2026-10-23), the TTC twin of `pregRelevanceOrder`
// (lib/data/doors/preg_band.dart). Before this a woman in her two-week wait
// opened Conceiving on "When should we have sex?", and the only things that
// moved a TTC door were her age (ttc_age_rank.dart) and a running IVF round.
//
// Two moves, both decided by the user:
//   1. The door OPENS on the tab tagged for her moment (`ttcDoorOpeningGroup`).
//      Tab order never changes; a door opened on a named tab keeps it.
//   2. Inside a tab, sections tagged for her moment come first, and inside a
//      section the reads the home's read rail picks for her phase
//      (`kTtcPhaseReadIds`) come first.
//
// ⚠️ A PERMUTATION, ALWAYS. Same rule as the age order: nothing is hidden or
// added, untagged content keeps its order. Ranking, never structure.
//
// ⚠️ UNKNOWN MOVES NOTHING. `TtcDayPhase.any` (no period logged, or a cycle a
// clinic is timing) is the TTC week-20 placeholder: no moment, no movement.
//
// ⚠️ A CLINIC'S ROUND WINS OVER OUR CYCLE ESTIMATE. While a clinic owns the
// cycle, the door ranks by the round's step and never by a phase ParentVeda
// calculated (CLAUDE.md, clinical ownership and the truth hierarchy).
//
// ⚠️ IT ORDERS, IT DOES NOT ADVISE. Lifting "When to test" says nothing about
// her chances; no probability language anywhere near this.

// TtcDayPhase and TtcRoundPhase come through ttc_focus_data's exports.
import 'ttc_focus_data.dart';
import 'ttc_home_situation.dart' show ttcHomePhaseOn, ttcHomeRoundPhaseOn;
import 'ttc_phase_reads.dart' show kTtcPhaseReadIds;

/// Where she is today, as far as a door needs to know. At most one of the two
/// is set: a clinic's round step, or else her own cycle phase. Both null is
/// "unknown", and nothing moves.
class TtcDoorMoment {
  const TtcDoorMoment({this.day, this.round})
    : assert(day == null || round == null);

  /// Nothing known: every door keeps its written order.
  static const none = TtcDoorMoment();

  /// Her cycle phase. Never [TtcDayPhase.any]; that is null here.
  final TtcDayPhase? day;

  /// The clinic round's step, while a clinic owns the cycle.
  final TtcRoundPhase? round;

  bool get isKnown => day != null || round != null;
}

/// Her moment on [now], from the same two readings the TTC home uses, so the
/// door and the home can never disagree about where she is.
TtcDoorMoment ttcDoorMomentNow([DateTime? now]) {
  final day = now ?? DateTime.now();
  final round = ttcHomeRoundPhaseOn(day);
  if (round != null) return TtcDoorMoment(round: round);
  final phase = ttcHomePhaseOn(day);
  return phase == TtcDayPhase.any
      ? TtcDoorMoment.none
      : TtcDoorMoment(day: phase);
}

bool _fits(Set<TtcDayPhase> phases, Set<TtcRoundPhase> steps, TtcDoorMoment m) {
  if (m.round != null) return steps.contains(m.round);
  if (m.day != null) return phases.contains(m.day);
  return false;
}

/// The id of the first tab tagged for her moment, or null to open as before
/// (on the first tab). The caller lets a named `initialGroup` win over this.
String? ttcDoorOpeningGroup(List<TtcFocusGroup> groups, TtcDoorMoment moment) {
  if (!moment.isKnown) return null;
  for (final g in groups) {
    if (_fits(g.phases, g.steps, moment)) return g.id;
  }
  return null;
}

/// A stable sort that lifts the items [fits] says are hers to the front.
List<T> _lift<T>(List<T> items, bool Function(T) fits) {
  if (items.length < 2) return items;
  final lifted = <T>[], rest = <T>[];
  for (final x in items) {
    (fits(x) ? lifted : rest).add(x);
  }
  if (lifted.isEmpty || rest.isEmpty) return items;
  return [...lifted, ...rest];
}

/// The read a tile opens, where it opens one.
String? _readIdOf(TtcTile t) => switch (t) {
  TtcArticleTile(:final readId) => readId,
  TtcGuideTile(:final readId) => readId,
  _ => null,
};

/// A tab's sections for her moment: sections tagged for it first, and inside
/// each section the reads her phase's read list names first. Apply it AFTER
/// the age order, so today's moment outranks her age band.
List<TtcFocusSection> ttcPhaseOrderSections(
  List<TtcFocusSection> sections,
  TtcDoorMoment moment,
) {
  if (!moment.isKnown) return sections;
  // Reads are tagged by cycle phase only (the home's own table). A round
  // step lifts sections, never single reads.
  final reads = moment.day == null
      ? const <String>[]
      : kTtcPhaseReadIds[moment.day] ?? const <String>[];
  final inner = reads.isEmpty
      ? sections
      : [
          for (final s in sections)
            s.withTiles(_lift(s.tiles, (t) => reads.contains(_readIdOf(t)))),
        ];
  return _lift(inner, (s) => _fits(s.phases, s.steps, moment));
}

// =============================================================================
//  Truth hierarchy - when two sources disagree, which one wins
// -----------------------------------------------------------------------------
//  A permanent editorial and engineering rule. Whenever more than one source
//  offers an answer to the SAME question, the higher-ranked source wins, and
//  ParentVeda's own calculation is near the bottom on purpose.
//
//  ---------------------------------------------------------------------------
//  WHY THIS IS SEPARATE FROM THE OTHER TWO RULES
//
//  Three different questions, easy to confuse:
//
//    Inferable        WHICH FACT is in question (fertility timing, gestational
//                     age, growth, development)
//    TimingOwnership  MAY WE GENERATE a value at all
//    TruthSource      GIVEN several values, WHICH ONE WINS
//
//  They compose. Ownership can permit a calculation and the hierarchy can still
//  demote it the moment a lab result arrives.
//
//  ---------------------------------------------------------------------------
//  WHAT IT REPLACES
//
//  Rules written one at a time, each correct, none aware of the others:
//
//    * a positive LH strip overrides the calendar estimate  (TtcChapterEngine)
//    * a temperature shift overrides the calendar estimate  (TtcChapterEngine)
//    * clinic treatment dates override anything we compute  (TtcTreatmentStore)
//    * a dating scan should override a last-period estimate (not yet built)
//
//  Every one of those is this hierarchy. Naming it means the next case is
//  answered by consulting a rule rather than by someone noticing.
//
//  ---------------------------------------------------------------------------
//  NOT A DATA STORE
//
//  Pure comparison. It holds nothing, fetches nothing and decides nothing about
//  what a screen renders - it only says which of several claims to believe.
// =============================================================================

import 'journey_state.dart' show Inferable;

/// Where an answer came from, ranked. Lower [rank] wins.
///
/// The order is the product's editorial position, not a technical one, and it
/// is deliberately unflattering to ourselves: a population estimate is the
/// weakest thing we can say and our own arithmetic is only one step above it.
enum TruthSource {
  /// What the treating clinician actually told this family. Beats everything,
  /// including a lab result we might read differently.
  treatingClinician,

  /// A laboratory result - beta hCG, AMH, TSH, semen analysis.
  laboratoryResult,

  /// Ultrasound or other imaging. A dating scan lives here, which is why it
  /// outranks any gestational age we calculate.
  imaging,

  /// A medication schedule confirmed against a prescription or a clinic
  /// instruction - NOT something typed in from memory, which is a user
  /// observation.
  verifiedMedication,

  /// What she recorded herself: an LH strip, a temperature, a symptom, the day
  /// her period began.
  ///
  /// Above device data on purpose. She knows the context a sensor cannot - that
  /// she slept badly, was unwell, or took the reading late.
  userObservation,

  /// A wearable, a connected thermometer, a phone sensor.
  deviceData,

  /// Anything ParentVeda worked out: a fertile window, an estimated ovulation
  /// day, a projected period.
  parentvedaDerived,

  /// "Most couples conceive within a year." True of a population, never a
  /// statement about this family - the weakest claim we can make.
  populationEstimate,
}

extension TruthSourceRank on TruthSource {
  /// 1 is the most authoritative.
  int get rank => index + 1;

  bool outranks(TruthSource other) => rank < other.rank;

  /// True when ParentVeda must step aside rather than show its own answer
  /// beside a stronger one.
  bool get beatsOurCalculation => outranks(TruthSource.parentvedaDerived);

  String label(bool hi) {
    switch (this) {
      case TruthSource.treatingClinician:
        return hi ? 'Aapke doctor ne bataya' : 'From your doctor';
      case TruthSource.laboratoryResult:
        return hi ? 'Lab report se' : 'From a lab result';
      case TruthSource.imaging:
        return hi ? 'Scan se' : 'From a scan';
      case TruthSource.verifiedMedication:
        return hi ? 'Aapke prescription se' : 'From your prescription';
      case TruthSource.userObservation:
        return hi ? 'Aapne khud record kiya' : 'You recorded this';
      case TruthSource.deviceData:
        return hi ? 'Aapke device se' : 'From your device';
      case TruthSource.parentvedaDerived:
        return hi ? 'ParentVeda ka andaaza' : 'ParentVeda estimate';
      case TruthSource.populationEstimate:
        return hi ? 'Aam jaankari' : 'General information';
    }
  }
}

/// One answer, from one source, about one fact.
class TruthClaim<T> {
  const TruthClaim({
    required this.about,
    required this.source,
    required this.value,
    required this.recordedAt,
  });

  /// WHICH fact this is about. Two claims only compete when this matches -
  /// otherwise they are answering different questions and neither wins.
  final Inferable about;

  final TruthSource source;
  final T value;

  /// Used only to break a tie between two claims of equal rank.
  final DateTime recordedAt;

  bool get isOurs => source == TruthSource.parentvedaDerived;
}

class TruthHierarchy {
  const TruthHierarchy._();

  /// The claim to believe, or null if there are none.
  ///
  /// Highest-ranked source wins. Two claims of the SAME rank are broken by
  /// recency - a repeat blood test supersedes last month's, rather than the
  /// order they happen to be in a list.
  static TruthClaim<T>? resolve<T>(Iterable<TruthClaim<T>> claims) {
    TruthClaim<T>? best;
    for (final c in claims) {
      if (best == null) {
        best = c;
        continue;
      }
      if (c.source.outranks(best.source)) {
        best = c;
      } else if (c.source == best.source &&
          c.recordedAt.isAfter(best.recordedAt)) {
        best = c;
      }
    }
    return best;
  }

  /// The claim to believe about ONE fact, ignoring claims about others.
  static TruthClaim<T>? resolveFor<T>(
    Inferable about,
    Iterable<TruthClaim<T>> claims,
  ) =>
      resolve(claims.where((c) => c.about == about));

  /// True when a stronger source than ours exists for this fact, so our own
  /// calculation must not be shown as if it were an equal second opinion.
  ///
  /// This is the question a screen should ask before rendering a derived
  /// number next to something a clinic said.
  static bool weMustDefer<T>(
    Inferable about,
    Iterable<TruthClaim<T>> claims,
  ) {
    final winner = resolveFor(about, claims);
    return winner != null && !winner.isOurs;
  }

  /// Everything that lost, strongest first. For a surface that shows history -
  /// a superseded result is worth keeping visible, it is just not the answer.
  static List<TruthClaim<T>> superseded<T>(
    Inferable about,
    Iterable<TruthClaim<T>> claims,
  ) {
    final relevant = claims.where((c) => c.about == about).toList()
      ..sort((a, b) {
        final byRank = a.source.rank.compareTo(b.source.rank);
        return byRank != 0 ? byRank : b.recordedAt.compareTo(a.recordedAt);
      });
    return relevant.length <= 1 ? const [] : relevant.sublist(1);
  }
}

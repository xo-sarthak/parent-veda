// =============================================================================
//  The relevance brain: Parenting ordered by where the child is (2026-10-21)
// -----------------------------------------------------------------------------
//  The user: everything should reorder by the child's situation, the way TTC
//  reorders around IVF or IUI. Before this, Parenting ranked in four separate
//  places (ppTileOrder, ppRankRecipes, an unused orderByPriority, recoBoosts
//  whose weights were thrown away) and the doors did the opposite of ranking:
//  they HID every age band but the child's. Approved as an Artifact first
//  (claude.ai/artifact/Hgfy82qx2TLA4S7MVeZE1S).
//
//  Two pieces:
//    * PpSituation  - one snapshot of what the app already knows. Nothing here
//                     is asked; every field is derived from a store.
//    * ppRelevanceOrder - a stable, scored sort. LOWER SCORE FIRST.
//
//  ⚠️ IT NEVER DROPS AN ITEM. The output is a permutation of the input, always.
//  That is the "a feature is never hidden" rule applied to content: a parent of
//  a premature baby still finds the ordinary pages, they just come second.
//  test/pp_relevance_test.dart holds it.
//
//  ⚠️ IT ORDERS, IT DOES NOT DECIDE. A born-early baby's solids page moves up
//  because the page explains that timing is counted from the due date and her
//  doctor decides it. The brain never changes the band shown or sets a date;
//  that stays with the clinician (CLAUDE.md, clinical ownership).
// =============================================================================

import '../../services/family_profile.dart';
import '../../services/pv_read_store.dart';
import 'pp_child_profile.dart';
import 'pp_feeding_data.dart';

/// A situation the brain can lift content for. Each has the words that mark a
/// page as being about it, and the few words shown on a card that moved.
enum PpSignal {
  bornEarly('Born early', ['born early', 'premature', 'preterm', 'corrected age', 'nicu']),
  cSection('After a C-section', ['c-section', 'caesarean', 'cesarean']),
  formula('On formula', ['formula', 'bottle']),
  breastfeeding('Breastfeeding', ['breast', 'latch', 'nipple', 'milk supply', 'pumping']),
  twins('For twins', ['twin']);

  const PpSignal(this.why, this.words);

  /// The few words a moved card shows ("On formula").
  final String why;

  /// Lower-case phrases that mark a page as being about this situation.
  final List<String> words;

  bool matches(String text) {
    final t = text.toLowerCase();
    return words.any(t.contains);
  }
}

/// One snapshot of the child's situation. Built once per screen build, so a
/// whole rail is ordered against the same facts.
class PpSituation {
  const PpSituation({
    required this.ageMonths,
    required this.daysOld,
    this.signals = const {},
    this.father = false,
  });

  /// Everything the app knows right now. Corrected age is NOT used to move a
  /// child between bands: bands follow the age the doors already use, and the
  /// born-early signal lifts the pages that explain corrected age instead.
  factory PpSituation.now() {
    final child = ChildProfileStore.instance;
    final fam = FamilyProfileStore.instance;
    final feedings = fam.feedings.isNotEmpty ? fam.feedings : {?fam.feeding};
    final todayMethod = FeedingStore.instance.methodToday.toLowerCase();
    final signals = <PpSignal>{
      if (fam.premature || fam.nicu || child.correctionWeeks != null) PpSignal.bornEarly,
      // Recovery matters for the first three months, not for a toddler's mother.
      if (fam.birthMode == BirthMode.cSection && child.ageInDays < 90) PpSignal.cSection,
      if (feedings.contains(FeedingMethod.formula) ||
          feedings.contains(FeedingMethod.mixed) ||
          todayMethod.startsWith('bottle'))
        PpSignal.formula,
      if (feedings.contains(FeedingMethod.breastfeeding) ||
          feedings.contains(FeedingMethod.expressed) ||
          feedings.contains(FeedingMethod.mixed) ||
          todayMethod.startsWith('breast'))
        PpSignal.breastfeeding,
      if (fam.multiple) PpSignal.twins,
    };
    return PpSituation(
      ageMonths: child.ageInMonths,
      daysOld: child.ageInDays,
      signals: signals,
      father: fam.role == CareRole.father,
    );
  }

  final int ageMonths;
  final int daysOld;
  final Set<PpSignal> signals;
  final bool father;

  /// The first of her signals this text is about, or null.
  PpSignal? signalFor(String text) {
    for (final s in PpSignal.values) {
      if (signals.contains(s) && s.matches(text)) return s;
    }
    return null;
  }
}

/// How far a band is from the child's own: the first term of every score.
enum PpBandDistance {
  now(0),
  next(100),
  earlier(200),
  further(300);

  const PpBandDistance(this.score);
  final int score;
}

/// A signal match lifts an item by this much (lower is earlier).
const int kPpSignalLift = 30;

/// Saved items come a little earlier.
const int kPpSavedLift = 5;

/// Already finished reads sink below the ones she has not read.
const int kPpFinishedSink = 30;

/// Orders [items] for this child. Stable: equal scores keep their input order,
/// so the writers' order survives wherever the brain has nothing to say.
///
/// [text] is what the item is about (its title, plus a summary if it has one).
/// [band] says how far its age band is from the child's; omit it when the list
/// is already one band. [readId] lets a finished read sink; [saved] lifts.
List<T> ppRelevanceOrder<T>(
  List<T> items, {
  required PpSituation situation,
  required String Function(T) text,
  PpBandDistance Function(T)? band,
  String? Function(T)? readId,
  bool Function(T)? saved,
}) {
  int score(T it) {
    var s = band?.call(it).score ?? 0;
    if (situation.signalFor(text(it)) != null) s -= kPpSignalLift;
    if (saved?.call(it) ?? false) s -= kPpSavedLift;
    final rid = readId?.call(it);
    if (rid != null && PvReadStore.instance.isFinished(rid)) s += kPpFinishedSink;
    return s;
  }

  final indexed = [for (var i = 0; i < items.length; i++) (i, score(items[i]), items[i])];
  indexed.sort((a, b) => a.$2 != b.$2 ? a.$2.compareTo(b.$2) : a.$1.compareTo(b.$1));
  return [for (final e in indexed) e.$3];
}

/// The few words a card shows when the brain moved it ("On formula"), so the
/// app explains itself. Null when nothing about her situation moved it.
String? ppRelevanceWhy(PpSituation situation, String text) => situation.signalFor(text)?.why;

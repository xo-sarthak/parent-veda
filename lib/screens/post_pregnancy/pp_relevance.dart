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
import '../../services/pp_use_consent.dart';
import '../../services/pv_read_store.dart';
import 'pp_changes_store.dart';
import 'pp_child_profile.dart';
import 'pp_feeding_data.dart';
import 'pp_what_changed_data.dart' show WcTone;

/// A situation the brain can lift content for. Each has the words that mark a
/// page as being about it, and the few words shown on a card that moved.
enum PpSignal {
  bornEarly('Born early', ['born early', 'premature', 'preterm', 'corrected age', 'nicu']),
  cSection('After a C-section', ['c-section', 'caesarean', 'cesarean']),
  formula('On formula', ['formula', 'bottle']),
  breastfeeding('Breastfeeding', ['breast', 'latch', 'nipple', 'milk supply', 'pumping']),
  twins('For twins', ['twin']),
  // Door 3 (You, Maa, 2026-10-25), from her pregnancy record: the after-GDM
  // and after-BP pages lead for the mothers who had them, in the first year.
  sugarInPregnancy('After sugar in pregnancy', ['sugar in pregnancy']),
  bpInPregnancy('After high BP in pregnancy', ['high bp in pregnancy']);

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
    this.changes = const [],
  });

  /// Everything the app knows right now. Corrected age is NOT used to move a
  /// child between bands: bands follow the age the doors already use, and the
  /// born-early signal lifts the pages that explain corrected age instead.
  factory PpSituation.now() {
    final child = ChildProfileStore.instance;
    final fam = FamilyProfileStore.instance;
    final feedings = fam.feedings.isNotEmpty ? fam.feedings : {?fam.feeding};
    // ⚠️ THE FEED LOG, ONLY WITH HER YES (tools pass 01, F4, 2026-10-25).
    // Was `methodToday.startsWith('bottle')`, so a bottle of her own expressed
    // milk raised the formula signal and lifted formula pages for a
    // breastfeeding mother; and the log was used without asking. Now formula
    // means a formula bottle, breast milk counts at the breast or expressed,
    // and neither is read unless she said yes. Onboarding answers are untouched:
    // she gave those for exactly this.
    // Kept for revert: final todayMethod = FeedingStore.instance.methodToday.toLowerCase();
    final feeds = FeedingStore.instance;
    final useLog = PpUseConsent.instance.allows(PpUseKind.feeds);
    final signals = <PpSignal>{
      if (fam.premature || fam.nicu || child.correctionWeeks != null) PpSignal.bornEarly,
      // Recovery matters for the first three months, not for a toddler's mother.
      if (fam.birthMode == BirthMode.cSection && child.ageInDays < 90) PpSignal.cSection,
      if (feedings.contains(FeedingMethod.formula) ||
          feedings.contains(FeedingMethod.mixed) ||
          (useLog && feeds.formulaLast24h))
        PpSignal.formula,
      if (feedings.contains(FeedingMethod.breastfeeding) ||
          feedings.contains(FeedingMethod.expressed) ||
          feedings.contains(FeedingMethod.mixed) ||
          (useLog && feeds.breastMilkLast24h))
        PpSignal.breastfeeding,
      if (fam.multiple) PpSignal.twins,
      if (fam.hasPregCondition(PregCondition.gestationalDiabetes) &&
          child.ageInMonths < 12)
        PpSignal.sugarInPregnancy,
      if (fam.hasPregCondition(PregCondition.hypertension) &&
          child.ageInMonths < 12)
        PpSignal.bpInPregnancy,
    };
    return PpSituation(
      ageMonths: child.ageInMonths,
      daysOld: child.ageInDays,
      signals: signals,
      father: fam.role == CareRole.father,
      // What she told us in "Something changed?" (2026-10-23, Wave 8).
      changes: PpChangesStore.instance.active(),
    );
  }

  final int ageMonths;
  final int daysOld;
  final Set<PpSignal> signals;
  final bool father;

  /// What she told us in "Something changed?" and has not cleared, newest
  /// first. Active for three weeks (pp_changes_store.dart).
  final List<PpChange> changes;

  /// The newest change this text is about, or null. With [commerce], an urgent
  /// change matches nothing: a worry that needs a doctor never puts a product
  /// first.
  PpChange? changeFor(String text, {bool commerce = false}) {
    for (final c in changes) {
      if (commerce && c.tone == WcTone.urgent) continue;
      if (c.matches(text)) return c;
    }
    return null;
  }

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

/// Something she told us lifts a little more than a standing signal: it is
/// what is on her mind this week (2026-10-23, Wave 8).
const int kPpChangeLift = 40;

/// Saved items come a little earlier.
const int kPpSavedLift = 5;

/// Already finished reads sink below the ones she has not read.
const int kPpFinishedSink = 30;

/// ⚠️ A WARNING LIST NEVER SINKS (step 0 · S10, the user on First 40 FD2,
/// 2026-10-24: "Yes, always first"). A red-flag page she has read is still
/// the first card, ahead of anything a signal lifts: "Go now" is not a read
/// she finishes. Far below any other score, so these lead in their own order.
const int kPpAlwaysFirst = -100000;

/// ⚠️ A PAGE WRITTEN FOR HER AGE LEADS AN UNTAGGED ONE (Health plan H-M2,
/// 2026-10-25, every door). An untagged page is for every band, so it tied
/// with a page tagged for hers and the file order decided: "A fever under
/// three months" sat third on the Fever rail for a newborn. Smaller than any
/// signal lift, so what she told us still wins.
const int kPpForHerAgeLift = 10;

/// Orders [items] for this child. Stable: equal scores keep their input order,
/// so the writers' order survives wherever the brain has nothing to say.
///
/// [alwaysFirst] marks the red-flag items that lead whatever else is true (S10).
///
/// [forHerAge] marks the items written for her age in particular
/// ([kPpForHerAgeLift]).
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
  bool Function(T)? alwaysFirst,
  bool Function(T)? forHerAge,
  bool commerce = false,
}) {
  int score(T it) {
    if (alwaysFirst?.call(it) ?? false) return kPpAlwaysFirst;
    var s = band?.call(it).score ?? 0;
    if (forHerAge?.call(it) ?? false) s -= kPpForHerAgeLift;
    if (situation.signalFor(text(it)) != null) s -= kPpSignalLift;
    if (situation.changeFor(text(it), commerce: commerce) != null) s -= kPpChangeLift;
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
// String? ppRelevanceWhy(PpSituation situation, String text) => situation.signalFor(text)?.why; // kept for revert (Wave 8)
String? ppRelevanceWhy(PpSituation situation, String text) =>
    situation.changeFor(text)?.why ?? situation.signalFor(text)?.why;

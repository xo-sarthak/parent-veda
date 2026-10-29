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
import '../../services/pregnancy_controller.dart' show DueDateSource;
import '../../services/pregnancy_records.dart' show PregnancyRecords;
import '../../ttc/ttc_care_pathway.dart' show TtcPath;
import '../../ttc/ttc_store.dart' show TtcStore;
import 'pp_changes_store.dart';
import 'pp_child_profile.dart';
import 'pp_feeding_data.dart';
import 'pp_what_changed_data.dart' show WcTone;

/// A situation the brain can lift content for. Each has the words that mark a
/// page as being about it, the few words shown on a card that moved, and,
/// since final review item 12 (2026-10-28), the pages and tabs it lifts by id.
///
/// ⚠️ WORDS FOR BREADTH, IDS FOR THE PAGES THAT MUST MOVE (item 12). Matching
/// only on title words cost nothing to keep up, but it missed pages whose
/// title says it another way ("Bringing home a small or early baby" is not
/// "born early"). An id list is exact and a test can hold it; its price is
/// that a new page joins it by hand. Both are kept: a page moves if either
/// says so.
enum PpSignal {
  bornEarly(
    'Born early',
    ['born early', 'premature', 'preterm', 'corrected age', 'nicu'],
    because: 'your baby was born early',
    pageIds: {
      'sc_nicu',
      'sc_preemie_home',
      'f40_small_or_early',
      'dev_born_early',
      'bf_exclusive_pumping',
    },
    leadTabs: {'parenting_special_care': 'early'},
  ),
  cSection(
    'After a C-section',
    ['c-section', 'caesarean', 'cesarean'],
    pageIds: {
      'body_csection_early',
      'body_scar_care',
      'body_core_recovery',
      'move_after_csection',
      'f40_after_csection',
    },
    // No tab lead (nor for the sugar, BP, loss and treatment signals): You,
    // Maa opens on How are you today? and First 40 on Day by day, by design
    // (S1). Their rails still lift these pages.
  ),
  formula('On formula', ['formula', 'bottle']),
  breastfeeding('Breastfeeding', ['breast', 'latch', 'nipple', 'milk supply', 'pumping']),
  twins(
    'For twins',
    ['twin'],
    because: 'you have twins',
    pageIds: {
      'sc_twins_breastfeeding',
      'sc_twins_pumping',
      'sc_twins_daily_life',
      'twins_adopted_second',
    },
    leadTabs: {'parenting_special_care': 'twins'},
  ),
  // Door 3 (You, Maa, 2026-10-25), from her pregnancy record: the after-GDM
  // and after-BP pages lead for the mothers who had them, in the first year.
  sugarInPregnancy(
    'After sugar in pregnancy',
    ['sugar in pregnancy'],
    pageIds: {'body_after_gdm'},
  ),
  bpInPregnancy(
    'After high BP in pregnancy',
    ['high bp in pregnancy'],
    pageIds: {'body_after_bp', 'body_red_flags'},
  ),
  // From her pregnancy record (2026-10-26, STILL-OPEN §61.1): she added a
  // pregnancy, so this child is about to be an older sibling and the pages
  // about a new brother or sister lead. Never "new baby": newborn pages say it.
  babyOnTheWay('A baby on the way', [
    'sibling',
    'second baby',
    'older child',
    'big brother',
    'big sister',
    'baby on the way',
  ]),
  // ---- her own history (final review item 12, 2026-10-28) ------------------
  // A pregnancy lost before this child: the rainbow-baby mother. From her
  // pregnancy record or her own "be gentle about a loss" answer. Lifts only;
  // no celebration page is pushed down (out of scope, said in the plan).
  afterLoss(
    'After a loss',
    ['after a loss'],
    pageIds: {
      'mind_after_loss',
      'mind_anxiety',
      'mind_love_but_not_okay',
      'mind_birth_trauma',
      'mind_getting_help',
    },
  ),
  // This child came after fertility treatment: from the pregnancy dated by an
  // IVF transfer, or her TTC treatment path.
  afterTreatment(
    'After treatment',
    ['years of trying'],
    pageIds: {'mind_after_trying', 'mind_identity', 'mind_anxiety'},
  ),
  // A newborn with an older brother or sister at home.
  twoAtHome(
    'With two at home',
    ['with two'],
    because: 'you have two at home',
    pageIds: {'fam_first_weeks_two', 'fam_sibling_jealousy', 'siblings'},
    leadTabs: {'parenting_family': 'second'},
  ),
  // A delay, hearing or vision answer in the family profile.
  extraSupport(
    'Extra support',
    [],
    because: 'of what you noted in the family profile',
    pageIds: {
      'sc_late_bloomer',
      'sc_not_talking',
      'sc_hearing',
      'sc_therapies',
      'sc_help_india',
      'sc_parent_wellbeing',
    },
    leadTabs: {'parenting_special_care': 'more'},
  );

  const PpSignal(
    this.why,
    this.words, {
    this.because,
    this.pageIds = const {},
    this.leadTabs = const {},
  });

  /// The few words a moved card shows ("On formula").
  final String why;

  /// Lower-case phrases that mark a page as being about this situation.
  final List<String> words;

  /// The end of "First here, because ..." over a tab this signal moved to the
  /// front. Null for a signal that leads no tab.
  final String? because;

  /// Pages about this situation, matched by id as well as by [words].
  final Set<String> pageIds;

  /// Door section id -> the tab this signal puts first in that door. Order
  /// only: the tab already exists and stays; it just opens first.
  final Map<String, String> leadTabs;

  bool matches(String text, [Iterable<String> ids = const []]) {
    if (ids.any(pageIds.contains)) return true;
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
      if (child.hasRealChild && PregnancyRecords.instance.current != null)
        PpSignal.babyOnTheWay,
      // Item 12: her own history. Each is derived; nothing here is asked.
      if (child.ageInMonths < 24 &&
          (fam.gentleAboutLoss ||
              PregnancyRecords.instance.lossBefore(child.activeChildId)))
        PpSignal.afterLoss,
      if (child.ageInMonths < 12 && _afterTreatment(child.activeChildId))
        PpSignal.afterTreatment,
      if (child.ageInMonths < 6 && _olderChildAtHome(child)) PpSignal.twoAtHome,
      if (fam.hasCondition(HealthCondition.devDelay) ||
          fam.hasCondition(HealthCondition.hearing) ||
          fam.hasCondition(HealthCondition.vision))
        PpSignal.extraSupport,
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

  /// This child's pregnancy was dated from an IVF transfer, or her TTC path
  /// was a treatment. Defensive: a store that never loaded is "no".
  static bool _afterTreatment(String? childId) {
    try {
      if (PregnancyRecords.instance.dueDateSourceFor(childId) ==
          DueDateSource.ivfTransfer.name) {
        return true;
      }
      return TtcStore.instance.path != TtcPath.natural;
    } catch (_) {
      return false;
    }
  }

  /// The child on screen is the youngest, and an older one was born before
  /// (twins share a birthday, so they are not "two at home" here).
  static bool _olderChildAtHome(ChildProfileStore child) {
    final kids = child.children;
    if (kids.length < 2) return false;
    final dob = child.active.dob;
    return kids.every((c) => !c.dob.isAfter(dob)) &&
        kids.any((c) => c.dob.isBefore(dob.subtract(const Duration(days: 1))));
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

  /// The first of her signals this text (or one of these page [ids]) is
  /// about, or null.
  PpSignal? signalFor(String text, [Iterable<String> ids = const []]) {
    for (final s in PpSignal.values) {
      if (signals.contains(s) && s.matches(text, ids)) return s;
    }
    return null;
  }

  /// The first of her signals that puts a tab of this door first, as
  /// (signal, tab id), or null (item 12).
  (PpSignal, String)? leadTabFor(String sectionId) {
    for (final s in PpSignal.values) {
      final tab = s.leadTabs[sectionId];
      if (tab != null && signals.contains(s)) return (s, tab);
    }
    return null;
  }
}

/// What Ask Veda is told about the child (PP 6, 2026-10-29).
///
/// IDS, NEVER PROSE, and never the child's name. The service caches answers
/// and shares them between families: a name in the context could come back in
/// another family's cached answer, and free text would give every family its
/// own cache entry. So this is a closed vocabulary, mirrored on the service
/// (`app/prompt.py` FAMILY_SIGNALS / CHILD_CONDITIONS, test_child_context.py),
/// which drops any id it does not know. `FamilyProfileStore.aiContext()`
/// (the prose summary, with the name) stays unused for this reason.
class PpAskVedaContext {
  const PpAskVedaContext({
    required this.ageMonths,
    this.correctedMonths,
    this.signals = const [],
    this.conditions = const [],
  });

  /// Birthday age: vaccines and growth charts follow it.
  final int ageMonths;

  /// Age from the due date, for a baby born before 37 weeks and under 24
  /// months (the 2026-10-26 decision); null otherwise. Development, play,
  /// sleep and feeding stages follow it.
  final int? correctedMonths;

  final List<String> signals;

  /// `HealthCondition` names (identity, never a label).
  final List<String> conditions;
}

/// Builds [PpAskVedaContext] from the stores, on the clock [now].
///
/// Not `PpSituation.signals` copied across, for two reasons:
///  * after_loss comes ONLY from a loss she recorded (`PregnancyRecords`).
///    Her onboarding "be gentle" answer raises the home's signal but stays in
///    the app (the user, 2026-10-17), exactly as `previous_loss` does.
///  * Conditions are stored per FAMILY, not per child, so with two children
///    "eczema" may be the older child's while she asks about the baby. They
///    go only while one child is saved (the user, 2026-10-29; per-child
///    conditions are an open item). The home's extra-support signal is left
///    out here for the same reason: it is derived from those conditions.
/// Her baby on the way is not repeated: `family_stage` already says so.
PpAskVedaContext ppAskVedaContext({DateTime? now}) {
  final at = now ?? DateTime.now();
  final child = ChildProfileStore.instance;
  final fam = FamilyProfileStore.instance;
  // Same arithmetic as ChildProfileStore.ageInWeeks / devAgeInMonths, on the
  // given clock rather than the device's.
  final days = at.difference(child.active.dob).inDays;
  final weeks = days > 0 ? days / 7.0 : 0.0;
  final months = (weeks / 4.345).floor();
  final bornWeeks = fam.bornWeeks;
  final correction = (bornWeeks != null && bornWeeks < 37 && months < 24)
      ? 40 - bornWeeks
      : null;
  final corrected = correction == null
      ? null
      : (weeks - correction <= 0 ? 0 : ((weeks - correction) / 4.345).floor());

  // The feed log only with her yes, as PpSituation reads it.
  final feedings = fam.feedings.isNotEmpty ? fam.feedings : {?fam.feeding};
  final feeds = FeedingStore.instance;
  final useLog = PpUseConsent.instance.allows(PpUseKind.feeds);
  final id = child.activeChildId;
  final signals = <String>[
    if (fam.premature || fam.nicu || correction != null) 'born_early',
    if (fam.birthMode == BirthMode.cSection && days < 90) 'c_section',
    if (feedings.contains(FeedingMethod.formula) ||
        feedings.contains(FeedingMethod.mixed) ||
        (useLog && feeds.formulaLast24h))
      'formula',
    if (feedings.contains(FeedingMethod.breastfeeding) ||
        feedings.contains(FeedingMethod.expressed) ||
        feedings.contains(FeedingMethod.mixed) ||
        (useLog && feeds.breastMilkLast24h))
      'breastfeeding',
    if (fam.multiple) 'twins',
    if (months < 12 && PpSituation._afterTreatment(id)) 'after_treatment',
    if (months < 6 && PpSituation._olderChildAtHome(child)) 'two_at_home',
    if (months < 24 && PregnancyRecords.instance.lossBefore(id)) 'after_loss',
  ];
  // PP 21 (2026-10-29): the conditions are the ACTIVE child's (per-child
  // buckets since B1, the child's own row since 0129), the same child whose
  // age goes beside them, so two children no longer silence them. Kept for
  // revert (step 3c, when they were taken to be the family's):
  //   final conditions = child.children.length <= 1
  //       ? ([for (final c in fam.conditions) c.name]..sort())
  //       : const <String>[];
  final conditions = [for (final c in fam.conditions) c.name]..sort();
  return PpAskVedaContext(
    ageMonths: months,
    correctedMonths: corrected,
    signals: signals,
    conditions: conditions,
  );
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
/// [ids] are the page ids it carries, matched against each signal's
/// [PpSignal.pageIds] (item 12).
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
  Iterable<String> Function(T)? ids,
  bool commerce = false,
}) {
  int score(T it) {
    if (alwaysFirst?.call(it) ?? false) return kPpAlwaysFirst;
    var s = band?.call(it).score ?? 0;
    if (forHerAge?.call(it) ?? false) s -= kPpForHerAgeLift;
    if (situation.signalFor(text(it), ids?.call(it) ?? const []) != null) {
      s -= kPpSignalLift;
    }
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
// String? ppRelevanceWhy(PpSituation situation, String text) =>
//     situation.changeFor(text)?.why ?? situation.signalFor(text)?.why; // kept for revert (item 12)
String? ppRelevanceWhy(PpSituation situation, String text, [String? id]) =>
    situation.changeFor(text)?.why ??
    situation.signalFor(text, [?id])?.why;

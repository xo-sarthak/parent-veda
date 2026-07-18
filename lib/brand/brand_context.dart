// =============================================================================
//  BrandContext capture — flattening the parent into targeting signals
// -----------------------------------------------------------------------------
//  Reads the Personalization Engine and the child profile, and produces the
//  immutable snapshot the resolver targets against.
//
//  Targeting READS the profile. It never gates navigation, hides a feature, or
//  renames a section — the Personalization Engine's guardrail
//  (services/family_profile.dart:7-11) applies here unchanged.
// =============================================================================

import '../screens/post_pregnancy/pp_child_profile.dart';
import '../services/family_profile.dart';
import 'brand_models.dart';

/// Build a [BrandContext] from live app state.
///
/// [pregnancyWeek] must be passed in by the caller: PregnancyController is
/// deliberately not a singleton (it is constructed in main.dart and handed
/// down), so this cannot reach it. Null simply means "no week constraint can
/// match", which fails closed.
BrandContext captureBrandContext({
  required BrandStage stage,
  int? pregnancyWeek,
  DateTime? now,
}) {
  final signals = <String>{};
  int? ageMonths;

  // Every read is defensive: a store that has not loaded yet, or throws under
  // the test harness, must degrade to "no signals" — never to a crash, and
  // never to showing a campaign we could not verify the audience for.
  try {
    final fp = FamilyProfileStore.instance;
    for (final c in fp.conditions) {
      signals.add(c.name);
    }
    for (final p in fp.priorities) {
      signals.add(p.name);
    }
    final feeding = fp.feeding;
    if (feeding != null) signals.add(feeding.name);
    final sleep = fp.sleep;
    if (sleep != null) signals.add(sleep.name);
  } catch (_) {/* no signals */}

  try {
    final child = ChildProfileStore.instance;
    // Only trust an age we actually know. The store hands back a seeded
    // placeholder child until a real one is saved; targeting an age band off a
    // placeholder would show campaigns to the wrong families.
    if (child.hasRealChild) ageMonths = child.ageInMonths;
  } catch (_) {/* unknown age */}

  return BrandContext(
    stage: stage,
    now: now ?? DateTime.now(),
    pregnancyWeek: pregnancyWeek,
    childAgeMonths: ageMonths,
    signals: signals,
  );
}

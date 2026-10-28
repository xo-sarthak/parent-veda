// =============================================================================
//  The offers a pregnancy message may make, and only the ones that exist
//  (2026-10-28, docs/NOTIFICATIONS-PLAN.md, Phase 6a)
// -----------------------------------------------------------------------------
//  The user's rule: a message never points at something we do not have. "We
//  cannot notify about a course when we don't have a live course." So each
//  offer here is READ from a live store, and an empty answer means silence,
//  never "coming soon". The day a course is published in the admin panel, the
//  message starts on its own, with no release.
//
//  What counts as real:
//    * a class: a programme PUBLISHED IN THE PANEL (`ProgrammeStore`), never a
//      bundled one; the bundled list is seed content to show the shape;
//    * a product: a Store product whose "have it by" week is within
//      [kPvDueSoonWeeks] of hers, the same closeness the home rail ranks by;
//    * an expert: a consult whose expert was PUBLISHED IN THE PANEL
//      (`ExpertStore`). The booking engine already refuses to sell a bundled
//      expert ("fiction", 2026-10-07); a message must not advertise one.
//
//  ⚠️ A SERVICE IMPORTING A SCREEN FILE, ON PURPOSE. `PvLearnCatalog` lives in
//  screens/ because two of its adapters hold route closures. It is the one
//  place every learnable thing has one shape, and a second copy here would
//  drift. The same trade the TTC messages store makes for its tap opener.
// =============================================================================

import '../models/pv_product.dart' show PvProduct;
import '../data/learn/pv_learn_view.dart' show PvLearnKind;
import '../screens/learn/pv_learn_catalog.dart' show PvLearnCatalog;
import 'expert_store.dart';
import 'life_stage_store.dart';
import 'programme_store.dart';
import 'pv_catalog_store.dart';

/// One thing a message can offer. [ref] says what a tap opens:
/// `product:<id>` or `learn:<offering view id>`.
class PregOffer {
  const PregOffer({required this.ref, required this.title, required this.body});
  final String ref;
  final String title;
  final String body;
}

/// Everything real that fits week [week], best first: a class, then a
/// product, then an expert. Empty when nothing exists, and on any failure:
/// local-first, a store that is not ready is no offer, never a crash.
List<PregOffer> pregOffersForWeek(int week) {
  final out = <PregOffer>[];

  try {
    final published = {for (final p in ProgrammeStore.instance.all) p.id};
    for (final v in PvLearnCatalog.instance.all(stage: LifeStage.pregnancy)) {
      if (v.kind == PvLearnKind.consult || !published.contains(v.id)) continue;
      out.add(PregOffer(
          ref: 'learn:${v.id}',
          title: 'A class for week $week: ${v.title}',
          body: v.subtitle.isNotEmpty ? v.subtitle : 'See what it covers and when it runs.'));
      break;
    }
  } catch (_) {/* no class */}

  try {
    final store = PvCatalogStore.instance;
    PvProduct? pick;
    for (final p in store.forStage(LifeStage.pregnancy)) {
      if (p.reviewOnly || p.weekFrom == null) continue;
      if (pvWeekTier(p, week) == 0) {
        pick = p;
        break;
      }
    }
    if (pick != null) {
      out.add(PregOffer(
          ref: 'product:${pick.id}',
          title: 'For this week: ${pick.name}',
          body: 'Good to have by week ${pick.weekFrom}. See what mothers pick, in the Store.'));
    }
  } catch (_) {/* no product */}

  try {
    final published = {for (final e in ExpertStore.instance.all) e.id};
    for (final v in PvLearnCatalog.instance
        .all(stage: LifeStage.pregnancy, kind: PvLearnKind.consult)) {
      final id = v.expert.expert?.id ?? v.expert.id;
      if (!published.contains(id)) continue;
      out.add(PregOffer(
          ref: 'learn:${v.id}',
          title: 'Talk to ${v.expert.name}',
          body: '${v.expert.role}. A call you book in the app. Your doctor stays your doctor.'));
      break;
    }
  } catch (_) {/* no expert */}

  return out;
}

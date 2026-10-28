// =============================================================================
//  The offers a TTC message may make, and only the ones that exist
//  (2026-10-28, docs/NOTIFICATIONS-PLAN.md, Phase 6a)
// -----------------------------------------------------------------------------
//  The same rule as Pregnancy's (`lib/services/preg_message_offers.dart`): an
//  offer is read from a live store, and nothing found means no message. Two
//  moments in a cycle, each with what it needs most first:
//
//    before her window   ovulation tests, then a class, then an expert
//    before it is due    pregnancy tests, then a class, then an expert
//
//  A class or an expert counts only when it was published in the admin panel.
//  A test kit only when the Store has one for this stage.
// =============================================================================

import '../data/learn/pv_learn_view.dart' show PvLearnKind;
import '../screens/learn/pv_learn_catalog.dart' show PvLearnCatalog;
import '../services/expert_store.dart';
import '../services/life_stage_store.dart';
import '../services/programme_store.dart';
import '../services/pv_catalog_store.dart';

/// One thing a TTC message can offer. [to] is what a tap opens:
/// `product/<id>` or `learn/<offering view id>` (the messages screen opens
/// both; the surface router does not know them).
class TtcOffer {
  const TtcOffer({required this.to, required this.title, required this.body});
  final String to;
  final String title;
  final String body;
}

/// When in the cycle an offer is made.
enum TtcOfferMoment { beforeWindow, beforeDue }

/// Everything real for [moment], best first. Empty on any failure.
List<TtcOffer> ttcOffersFor(TtcOfferMoment moment) {
  final out = <TtcOffer>[];
  final kitWords = moment == TtcOfferMoment.beforeWindow
      ? const ['ovulation', 'lh test']
      : const ['pregnancy test'];
  try {
    for (final p in PvCatalogStore.instance.forStage(LifeStage.tryingToConceive)) {
      if (p.reviewOnly) continue;
      final name = p.name.toLowerCase();
      if (!kitWords.any(name.contains)) continue;
      out.add(TtcOffer(
        to: 'product/${p.id}',
        title: moment == TtcOfferMoment.beforeWindow
            ? 'Ovulation tests, before your window'
            : 'For when you want to test',
        body: moment == TtcOfferMoment.beforeWindow
            ? 'Your window opens in a few days. ${p.name}, in the Store.'
            : 'A home test is reliable from the day your period is due. ${p.name}, in the Store.',
      ));
      break;
    }
  } catch (_) {/* no kit */}

  try {
    final published = {for (final p in ProgrammeStore.instance.all) p.id};
    for (final v in PvLearnCatalog.instance.all(stage: LifeStage.tryingToConceive)) {
      if (v.kind == PvLearnKind.consult || !published.contains(v.id)) continue;
      out.add(TtcOffer(
          to: 'learn/${v.id}',
          title: 'A class for you: ${v.title}',
          body: v.subtitle.isNotEmpty ? v.subtitle : 'See what it covers and when it runs.'));
      break;
    }
  } catch (_) {/* no class */}

  try {
    final published = {for (final e in ExpertStore.instance.all) e.id};
    for (final v in PvLearnCatalog.instance
        .all(stage: LifeStage.tryingToConceive, kind: PvLearnKind.consult)) {
      final id = v.expert.expert?.id ?? v.expert.id;
      if (!published.contains(id)) continue;
      out.add(TtcOffer(
          to: 'learn/${v.id}',
          title: 'Talk to ${v.expert.name}',
          body: '${v.expert.role}. A call you book in the app.'));
      break;
    }
  } catch (_) {/* no expert */}

  return out;
}

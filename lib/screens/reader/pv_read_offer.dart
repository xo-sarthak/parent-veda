// =============================================================================
//  pv_read_offer.dart - one calm link from a read to a service of ours
// =============================================================================
//
// The user (walk 2026-10-20): "In articles, whenever possible, provide the
// option to relevant services that we have ... a course, a masterclass, a
// consultation ... it can be in between as well ... pitch it in the right
// way, in a normal way." Every read opens in `PvReaderScreen`, so one rule
// here reaches all three stages.
//
// ⚠️ RELEVANT OR NOTHING. The match is by shared topic words between the read
// (title, kicker, teaser) and the offering (title, subtitle). No shared topic,
// no card: a pitch that does not fit the page is worse than none ("cakes, not
// pizza": every item fits its screen). Never on a loss or an urgent read.
//
// ⚠️ ONE PER READ, MID-PAGE. After the second section, so it reads as part of
// the page and not as an ad at the end. The read's own "What you can do with
// this" steps are untouched.
//
// Rules in code, not in the CMS (CLAUDE.md: behaviour rules are not content).
// The catalogue is `PvLearnCatalog`, the same one Learn and More show, so a
// price or a title is never typed twice.

import 'package:flutter/material.dart';

import '../../data/learn/pv_learn_view.dart';
import '../../models/pv_read.dart';
import '../../services/life_stage_store.dart' show LifeStage;
import '../../theme/pv_fonts.dart';
import '../learn/pv_learn_catalog.dart';
import '../learn/pv_offering_screen.dart' show pvOpenOffering;

/// Topic words a read and an offering can share. Lower case, whole words.
const List<String> kPvOfferTopics = [
  'pcos', 'ivf', 'iui', 'sperm', 'semen', 'thyroid', 'fertility',
  'food', 'nutrition', 'diet', 'eat', 'eating', 'weight',
  'yoga', 'exercise', 'fitness', 'move', 'breath', 'breathing',
  'stress', 'anxiety', 'mind', 'mood', 'sleep',
  'labour', 'birth', 'delivery', 'breastfeeding', 'feeding', 'lactation',
  'garbh', 'sanskar', 'newborn', 'baby', 'toddler', 'behaviour', 'potty',
  'development', 'speech', 'solids', 'weaning', 'partner', 'father',
];

/// Never pitch on these.
const List<String> _kQuiet = [
  'loss', 'miscarriage', 'stillbirth', 'grief', 'ectopic', 'emergency',
  'bleeding', 'urgent',
];

Set<String> _words(String s) => {
      for (final w in s.toLowerCase().split(RegExp(r'[^a-z]+')))
        if (w.isNotEmpty) w,
    };

LifeStage? _stageOf(PvRead r) {
  if (r.id.startsWith('ttc_')) return LifeStage.tryingToConceive;
  if (r.id.startsWith('preg_')) return LifeStage.pregnancy;
  if (r.id.startsWith('pp_')) return LifeStage.parenting;
  return null;
}

/// The one offering that fits [r], or null.
PvOfferingView? pvReadOfferFor(PvRead r, {List<PvOfferingView>? catalog}) {
  final stage = _stageOf(r);
  if (stage == null) return null;
  final read = _words('${r.title.en} ${r.kicker.en} ${r.teaser.en}');
  if (read.any(_kQuiet.contains)) return null;
  if (r.sections.any((s) => s.callout?.tone == PvCalloutTone.urgent)) {
    return null;
  }
  final topics = read.where(kPvOfferTopics.contains).toSet();
  if (topics.isEmpty) return null;
  List<PvOfferingView> all;
  try {
    all = catalog ?? PvLearnCatalog.instance.all(stage: stage);
  } catch (_) {
    return null; // local-first: a catalogue that is not ready is no card
  }
  PvOfferingView? best;
  var bestScore = 0;
  for (final v in all) {
    final hit = _words('${v.title} ${v.subtitle}').intersection(topics).length;
    if (hit > bestScore) {
      best = v;
      bestScore = hit;
    }
  }
  return best;
}

/// The card: quiet, one line of why, the price, a chevron.
class PvReadOfferCard extends StatelessWidget {
  const PvReadOfferCard({super.key, required this.offering});
  final PvOfferingView offering;

  String get _lead => switch (offering.kind) {
        PvLearnKind.consult => 'Want an expert to look at this with you?',
        PvLearnKind.course => 'Want to go deeper?',
        PvLearnKind.masterclass => 'Want to learn this live?',
        PvLearnKind.cohort => 'Want to do this with others?',
        PvLearnKind.classPack => 'Want to practise this with a teacher?',
      };

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF2F2C30);
    return Material(
      color: const Color(0xFFF3F3F4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: ValueKey('pv_read_offer_${offering.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => pvOpenOffering(context, offering),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_lead,
                        style: pvManrope(
                            fontSize: 12.5,
                            color: const Color(0xFF69636C),
                            height: 1.35)),
                    const SizedBox(height: 3),
                    Text(offering.title,
                        style: pvManrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: ink,
                            height: 1.3)),
                    const SizedBox(height: 2),
                    Text(offering.priceLabel,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: ink)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: ink),
          ]),
        ),
      ),
    );
  }
}

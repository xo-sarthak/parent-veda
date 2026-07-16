// =============================================================================
//  RecoCollectionScreen - a single smart collection, in full
// -----------------------------------------------------------------------------
//  A curated theme (Books About Emotions, Sensory Play, Rainy Day Activities...)
//  as a calm vertical list. Header carries the collection's own title, subtitle
//  and icon; each row opens the full recommendation detail page.
// =============================================================================

import 'package:flutter/material.dart';

import '../../brand/brand_models.dart';
import '../../brand/presented_by.dart';
import 'pp_common.dart';
import 'pp_reco_data.dart';
import 'reco_common.dart';
import 'reco_detail_screen.dart';

class RecoCollectionScreen extends StatelessWidget {
  const RecoCollectionScreen({super.key, required this.collection});
  final RecoCollection collection;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(BuildContext context, RecoItem it) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RecoDetailScreen(item: it)),
      );

  @override
  Widget build(BuildContext context) {
    final items = collection.items;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Recommendations')),
            const SizedBox(height: 18),
            _pad(Row(children: [
              Icon(collection.icon, size: 18, color: ppPurple),
              const SizedBox(width: 8),
              ppEyebrow('Collection', color: ppPurple),
            ])),
            const SizedBox(height: 10),
            _pad(Text(collection.title, style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 8),
            _pad(Text(collection.subtitle, style: ppBody(14, h: 1.55))),
            const SizedBox(height: 10),
            _pad(Text(
              items.isEmpty
                  ? 'This collection is being curated.'
                  : '${items.length} ${items.length == 1 ? 'pick' : 'picks'} in this collection',
              style: ppBody(12.5, color: ppPurple, w: FontWeight.w700),
            )),
            // Renders nothing unless this exact collection is sponsored. A
            // brand can fund a curated theme existing; ParentVeda still chooses
            // every pick in it, and the picks are unchanged either way.
            _pad(PresentedBy(
              slot: BrandSlot.sponsoredCollection,
              stage: BrandStage.parenting,
              placementKey: collection.id,
              padding: const EdgeInsets.only(top: 12),
            )),
            const SizedBox(height: 22),
            if (items.isEmpty)
              _pad(_recoCollectionEmpty())
            else
              _pad(Column(children: [
                for (final r in items) RecoRow(item: r, onTap: () => _open(context, r)),
              ])),
          ],
        ),
      ),
    );
  }
}

Widget _recoCollectionEmpty() => Container(
      padding: const EdgeInsets.symmetric(vertical: 44),
      alignment: Alignment.center,
      child: Column(children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: const Icon(Icons.collections_bookmark_outlined, size: 24, color: ppPurple),
        ),
        const SizedBox(height: 16),
        Text('Coming together soon', textAlign: TextAlign.center, style: ppJakarta(16)),
        const SizedBox(height: 8),
        Text('We are still gathering the right picks for this collection.',
            textAlign: TextAlign.center, style: ppBody(13, color: ppMuted, h: 1.5)),
      ]),
    );

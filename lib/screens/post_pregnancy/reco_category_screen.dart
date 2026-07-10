// =============================================================================
//  RecoCategoryScreen - one recommendation category, age-ranked
// -----------------------------------------------------------------------------
//  A calm vertical list of the picks in a single category (Books, Toys, ...),
//  already sorted by the engine for this child's age + stage. Reached from the
//  Recommendations home's category chips. Every row opens the full detail page.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reco_data.dart';
import 'reco_common.dart';
import 'reco_detail_screen.dart';

class RecoCategoryScreen extends StatelessWidget {
  const RecoCategoryScreen({super.key, required this.category});
  final String category;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(BuildContext context, RecoItem it) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RecoDetailScreen(item: it)),
      );

  @override
  Widget build(BuildContext context) {
    final items = topForCategory(category);
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
              Icon(recoCatIcon(category), size: 18, color: ppPurple),
              const SizedBox(width: 8),
              ppEyebrow('Recommendations', color: ppPurple),
            ])),
            const SizedBox(height: 10),
            _pad(Text(category, style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 8),
            _pad(Text(
              items.isEmpty
                  ? 'Fresh picks for this are on the way.'
                  : '${items.length} ${items.length == 1 ? 'pick' : 'picks'}, tuned to his stage',
              style: ppBody(13.5, h: 1.5),
            )),
            const SizedBox(height: 22),
            if (items.isEmpty)
              _pad(_recoCategoryEmpty())
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

Widget _recoCategoryEmpty() => Container(
      padding: const EdgeInsets.symmetric(vertical: 44),
      alignment: Alignment.center,
      child: Column(children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome_outlined, size: 26, color: ppPurple),
        ),
        const SizedBox(height: 16),
        Text('Nothing here just yet', textAlign: TextAlign.center, style: ppJakarta(16)),
        const SizedBox(height: 8),
        Text('We are still curating picks for this stage. Do check back soon.',
            textAlign: TextAlign.center, style: ppBody(13, color: ppMuted, h: 1.5)),
      ]),
    );

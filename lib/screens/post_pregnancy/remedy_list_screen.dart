// =============================================================================
//  RemedyListScreen - one situation's remedies (parenting · S19·list)
// -----------------------------------------------------------------------------
//  A calm vertical list of every validated nuskha for a single situation (Cold &
//  cough, Fever, ...). Reached from the Nuskhe landing's "By situation" grid.
//  Each row shows the age gate (green "Vaidya-approved" or a coral caution) and
//  opens the full, data-driven remedy detail. Isolated to the post_pregnancy
//  module.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_nuskhe_data.dart';
import 'remedy_detail_screen.dart';

class RemedyListScreen extends StatelessWidget {
  const RemedyListScreen({super.key, required this.category});
  final String category;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(BuildContext context, Remedy r) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => RemedyDetailScreen(remedy: r)));

  @override
  Widget build(BuildContext context) {
    final items = remediesByCategory(category);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Nuskhe')),
            const SizedBox(height: 18),
            _pad(Row(children: [
              Icon(nuskheCategoryIcon(category), size: 18, color: ppPurple),
              const SizedBox(width: 8),
              ppEyebrow('Home remedies', color: ppPurple),
            ])),
            const SizedBox(height: 10),
            _pad(Text(category, style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 8),
            _pad(Text(
              items.isEmpty
                  ? 'Fresh nuskhe for this are on the way.'
                  : '${items.length} ${items.length == 1 ? 'remedy' : 'remedies'}, each reviewed and safely age-gated',
              style: ppBody(13.5, h: 1.5),
            )),
            const SizedBox(height: 22),
            if (items.isEmpty)
              _pad(_empty())
            else
              _pad(Column(children: [
                for (int i = 0; i < items.length; i++)
                  RemedyRow(remedy: items[i], top: i == 0, bottom: true, onTap: () => _open(context, items[i])),
              ])),
          ],
        ),
      ),
    );
  }
}

/// A shared remedy row (thumb · title + age pill/meta · →). Reused by the list
/// screen and the landing's search results / popular section.
class RemedyRow extends StatelessWidget {
  const RemedyRow({
    super.key,
    required this.remedy,
    required this.onTap,
    this.top = false,
    this.bottom = false,
  });
  final Remedy remedy;
  final VoidCallback onTap;
  final bool top;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    final caution = remedy.isCaution;
    final pillFg = caution ? ppCoral : ppBrown;
    final pillBg = caution ? ppCoralTint : ppPanel;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFECE5F2))),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              const PpStriped(height: 56),
              Positioned.fill(child: Center(child: Icon(remedy.icon, size: 22, color: ppPurple))),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(remedy.name,
                  style: ppBody(15, color: ppInk, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(caution ? Icons.warning_amber_rounded : Icons.check_rounded, size: 11, color: pillFg),
                    const SizedBox(width: 4),
                    Text(remedy.pillLabel, style: ppBody(10, color: pillFg, w: FontWeight.w700)),
                  ]),
                ),
                Text(remedy.rowMeta, style: ppBody(12, color: ppMuted)),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );
  }
}

Widget _empty() => Container(
      padding: const EdgeInsets.symmetric(vertical: 44),
      alignment: Alignment.center,
      child: Column(children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: const Icon(Icons.eco_outlined, size: 26, color: ppPurple),
        ),
        const SizedBox(height: 16),
        Text('Nothing here just yet', textAlign: TextAlign.center, style: ppJakarta(16)),
        const SizedBox(height: 8),
        Text('Our panel is still reviewing nuskhe for this one. Do check back soon.',
            textAlign: TextAlign.center, style: ppBody(13, color: ppMuted, h: 1.5)),
      ]),
    );

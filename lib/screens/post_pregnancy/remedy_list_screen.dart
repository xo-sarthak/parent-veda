// =============================================================================
//  RemedyListScreen - one situation's remedies (parenting · S19·list)
// -----------------------------------------------------------------------------
//  A calm vertical list of every validated nuskha for a single situation (Cold &
//  cough, Fever, ...). Reached from the Nuskhe landing's "By situation" grid.
//  Each row shows the age gate (green "Vaidya-approved" or a coral caution) and
//  opens the full, data-driven remedy detail. Isolated to the post_pregnancy
//  module.
//
//  ON THE ONE PARENTVEDA LOOK (2026-10-07). The page wears the shared tool
//  shell (`PregToolScaffold`) and matches the redrawn Nuskhe landing
//  (nuskhe_screen.dart): the "not medical advice, a doctor comes first" line
//  first, then the remedies as `PvListRow`s in one `PvRowGroup`, each with one
//  verdict dot (`canIVerdictColor`) and one word under the name.
//  Mobbin: Yuka's additives list, a name, a sub-line and a dot with its word
//  on the right (mobbin.com/screens/5e756797-34ea-465d-814c-c139ce62a34f).
//  The dot is derived only from the data (`Remedy.isCaution`); it never
//  invents a verdict. Dropped from the new build, per the parenting trust
//  rules: "each reviewed", which no real review stands behind yet. The old
//  build is kept below, and `RemedyRow` stays (the landing's old build uses it).
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/can_i_entry.dart' show CanIVerdict;
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../can_i/can_i_widgets.dart' show canIVerdictColor;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../v2/v2_palette.dart';
import 'pp_common.dart';
import 'pp_nuskhe_data.dart';
import 'remedy_detail_screen.dart';

class RemedyListScreen extends StatelessWidget {
  const RemedyListScreen({super.key, required this.category});
  final String category;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(BuildContext context, Remedy r) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => RemedyDetailScreen(remedy: r)));

  /// The situation's drawn mark, by meaning, as on the Nuskhe landing. An
  /// unknown situation keeps its Material icon in the well.
  static IntentMark? _situationMark(String name) => switch (name) {
        'Cold & cough' => IntentMark.noseMark,
        'Fever' => IntentMark.thermoMark,
        'Stomach & colic' => IntentMark.tummyMark,
        'Teething' => IntentMark.toothMark,
        'Sleep issues' => IntentMark.sleepMark,
        'Skin issues' => IntentMark.skinMark,
        _ => null,
      };

  /// The dot and the word for a remedy, from the data alone.
  static (CanIVerdict, String) _verdict(Remedy r) => r.isCaution
      ? (CanIVerdict.moderation, '${r.ageWarning}, read the cautions')
      : (CanIVerdict.safe, 'Gentle, ${r.age}');

  Widget _dot(V2Palette p, CanIVerdict v) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: canIVerdictColor(v, p), shape: BoxShape.circle),
      );

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final items = remediesByCategory(category);
    final mark = _situationMark(category);

    return PregToolScaffold(
      hue: 140,
      eyebrow: 'Home remedies',
      mark: mark ?? IntentMark.lampMark,
      title: category,
      intro: items.isEmpty
          ? 'Fresh nuskhe for this are on the way.'
          : '${items.length} ${items.length == 1 ? 'remedy' : 'remedies'}, each with the age it suits and when not to use it.',
      children: [
        // The safety line comes first, before any remedy.
        pregToolPad(Container(
          key: const ValueKey('remedy_list_safety'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.local_hospital_outlined, size: 20, color: p.ink1),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This is supportive home care, not medical advice. When you see a red flag, a doctor comes first.',
                style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.5, color: p.ink1),
              ),
            ),
          ]),
        )),
        const SizedBox(height: 14),
        // The key to the dots, so the colour is never the only carrier.
        pregToolPad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final (v, word) in const [
            (CanIVerdict.safe, 'Gentle at the age shown'),
            (CanIVerdict.moderation, 'Age-gated, read the cautions'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                _dot(p, v),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(word, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink2)),
                ),
              ]),
            ),
        ])),
        const SizedBox(height: 18),
        if (items.isEmpty)
          // Never hidden: the empty state says what is coming.
          pregToolPad(Container(
            key: const ValueKey('remedy_list_empty'),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nothing here just yet',
                  style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
              const SizedBox(height: 6),
              Text('Nuskhe for this one are still being written. Do check back soon.',
                  style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
            ]),
          ))
        else
          pregToolPad(PvRowGroup(p: p, children: [
            for (final r in items) _row(context, p, r, mark),
          ])),
        const SizedBox(height: 18),
        pregToolPad(Text(
            'A guide, not a diagnosis. If your baby seems unwell, or a remedy lists a red flag you are seeing, '
            'call your paediatrician.',
            style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2))),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _row(BuildContext context, V2Palette p, Remedy r, IntentMark? mark) {
    final (v, word) = _verdict(r);
    return PvListRow(
      key: ValueKey('remedy_row_${r.id}'),
      p: p,
      leading: PvMarkWell(p: p, hue: 140, size: 40, mark: mark, icon: r.icon),
      title: r.name,
      line: r.oneLine,
      meta: word,
      trailing: _dot(p, v),
      onTap: () => _open(context, r),
    );
  }

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
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

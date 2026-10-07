// =============================================================================
//  NuskheScreen - Dadi / Nani ke Nuskhe · home remedies (parenting · S19)
// -----------------------------------------------------------------------------
//  Traditional grandmother home-remedies, each validated by an ayurvedic panel
//  + an MBBS paediatrician. Now DATA-DRIVEN off pp_nuskhe_data: a trust +
//  not-medical-advice banner, a real search that filters remedies by name /
//  situation, a browse-by-situation grid (real per-category counts, each opening
//  that situation's list) and a "Popular this monsoon" shelf of real remedies.
//  Reached from the Explore drawer. Cards and remedies open the remedy detail.
//
//  ON THE ONE PARENTVEDA LOOK (2026-10-07). The page now wears the shared tool
//  shell (`PregToolScaffold`): the field, the round back, the drawn mark, one
//  serif title. Situations and remedies are `PvListRow`s in a `PvRowGroup`.
//  Mobbin: Yuka's ingredient list, a name with one coloured dot and one word
//  under it (mobbin.com/screens/71fe4ea7-b315-4533-97c2-290aea20388e). The
//  dot is pregnancy's verdict colour (`canIVerdictColor`), as on the Maa
//  "Can I?" rows, so one colour means one thing in every stage:
//    green  (CanIVerdict.safe)       gentle at the age the remedy names;
//    amber  (CanIVerdict.moderation) age-gated, read the cautions first.
//  ⚠️ The data carries no "helps / only comforts / unsafe" verdict yet (the
//  Health door's blurb promises one, pp_door_health.dart). The dot is derived
//  only from what the data holds (`Remedy.isCaution`); it never invents a
//  verdict. The "not medical advice, a doctor comes first" line stays at the
//  top. Kept out of the new build, per the parenting trust rules: the "panel
//  of 5 ayurvedic practitioners" count and the "reviewed and signed off" claims,
//  which no real review stands behind yet. The old build is kept below.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/can_i_entry.dart' show CanIVerdict;
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../can_i/can_i_widgets.dart' show canIVerdictColor;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../v2/v2_palette.dart';
import 'pp_care_parts.dart' show ppCareHeading;
import 'pp_common.dart';
import 'pp_nuskhe_data.dart';
import 'pp_section_extras.dart';
import 'remedy_detail_screen.dart';
import 'remedy_list_screen.dart';

class NuskheScreen extends StatefulWidget {
  const NuskheScreen({super.key});

  @override
  State<NuskheScreen> createState() => _NuskheScreenState();
}

class _NuskheScreenState extends State<NuskheScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _openList(BuildContext context, String category) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => RemedyListScreen(category: category)));

  void _openRemedy(BuildContext context, Remedy r) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => RemedyDetailScreen(remedy: r)));

  /// The situation's drawn mark, by meaning (a nose for a cold, a thermometer
  /// for fever). An unknown situation keeps its Material icon in the well.
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

  Widget _remedyRow(BuildContext context, V2Palette p, Remedy r) {
    final (v, word) = _verdict(r);
    return PvListRow(
      key: ValueKey('nuskhe_row_${r.id}'),
      p: p,
      leading: PvMarkWell(
          p: p, hue: 140, size: 40, mark: _situationMark(r.category), icon: r.icon),
      title: r.name,
      line: r.oneLine,
      meta: word,
      trailing: _dot(p, v),
      onTap: () => _openRemedy(context, r),
    );
  }

  Widget _eyebrow(V2Palette p, String text) => Text(text.toUpperCase(),
      style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action));

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final searching = _query.trim().isNotEmpty;
    final results = searching ? searchRemedies(_query) : const <Remedy>[];

    return PregToolScaffold(
      hue: 140,
      eyebrow: 'Home remedies from the elders', // was 'Dadi and Nani ke nuskhe' (2026-10-07)
      mark: IntentMark.lampMark,
      title: 'Home remedies, safely.',
      intro: 'The remedies your grandmother swore by, each with clear notes on when not to use them.',
      children: [
        // The safety line comes first, before any remedy.
        pregToolPad(Container(
          key: const ValueKey('nuskhe_safety'),
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
        pregToolPad(TextField(
          key: const ValueKey('nuskhe_search'),
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
          decoration: InputDecoration(
            hintText: "What's troubling your little one?",
            hintStyle: pvManrope(fontSize: 15, color: p.ink3),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: p.ink3),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.ink1)),
          ),
        )),
        const SizedBox(height: 14),
        // The key to the dots, always on screen, so the colour is never the
        // only carrier of the meaning.
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
                  child: Text(word,
                      style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink2)),
                ),
              ]),
            ),
        ])),
        if (searching) ...[
          const SizedBox(height: 22),
          pregToolPad(_eyebrow(
              p,
              results.isEmpty
                  ? 'No remedies match "${_query.trim()}"'
                  : '${results.length} ${results.length == 1 ? 'remedy' : 'remedies'} for "${_query.trim()}"')),
          const SizedBox(height: 8),
          if (results.isEmpty)
            pregToolPad(Text('Try a situation like "cold", "colic", "teething" or "sleep".',
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
          else
            pregToolPad(PvRowGroup(p: p, children: [
              for (final r in results) _remedyRow(context, p, r),
            ])),
        ] else ...[
          const SizedBox(height: 26),
          pregToolPad(ppCareHeading('By situation')),
          const SizedBox(height: 8),
          pregToolPad(PvRowGroup(p: p, children: [
            for (final c in kNuskheCategories)
              PvListRow(
                key: ValueKey('nuskhe_cat_${c.name}'),
                p: p,
                leading: PvMarkWell(p: p, hue: 140, size: 40, mark: _situationMark(c.name), icon: c.icon),
                title: c.name,
                meta: '${remedyCount(c.name)} ${remedyCount(c.name) == 1 ? 'remedy' : 'remedies'}',
                onTap: () => _openList(context, c.name),
              ),
          ])),
          const SizedBox(height: 26),
          pregToolPad(ppCareHeading('Popular this monsoon')),
          const SizedBox(height: 8),
          pregToolPad(PvRowGroup(p: p, children: [
            for (final r in popularRemedies) _remedyRow(context, p, r),
          ])),
          const SizedBox(height: 18),
          pregToolPad(Text(
              'A guide, not a diagnosis. If your baby seems unwell, or a remedy lists a red flag you are seeing, '
              'call your paediatrician.',
              style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2))),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    final results = searching ? searchRemedies(_query) : const <Remedy>[];

    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            children: [
              _pad(ppBack(context, 'Explore')),

              // header
              const SizedBox(height: 22),
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('दादी–नानी के नुस्खे', style: ppBody(11, color: ppBrown, w: FontWeight.w700)),
                const SizedBox(height: 10),
                Text('Home remedies, safely.', style: ppFraunces(32, h: 1.12)),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(
                        text:
                            'The remedies your grandmother swore by - each one reviewed and signed off by qualified ayurvedic doctors, with clear notes on when '),
                    TextSpan(text: 'not', style: ppBody(15).copyWith(fontStyle: FontStyle.italic, color: ppBrown)),
                    const TextSpan(text: ' to use them.'),
                  ]),
                  style: ppBody(15),
                ),
              ])),

              // validation + not-medical-advice trust banner
              const SizedBox(height: 20),
              _pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.verified_user_outlined, size: 20, color: ppPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: 'Every nuskha is validated by a panel of '),
                          TextSpan(
                              text: '5 ayurvedic practitioners',
                              style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                          const TextSpan(text: ' + an MBBS paediatrician for safety.'),
                        ]),
                        style: ppBody(13, color: ppInk, h: 1.5),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: ppBrown),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is supportive home care, not medical advice. When you see a red flag, a doctor comes first.',
                        style: ppBody(12.5, color: ppSoft, h: 1.5),
                      ),
                    ),
                  ]),
                ]),
              )),

              // real search
              const SizedBox(height: 16),
              _pad(ppSearchField(
                controller: _search,
                hint: "What's troubling your little one?",
                onChanged: (v) => setState(() => _query = v),
              )),

              // --- SEARCH RESULTS (replace browse while searching) ------------
              if (searching) ...[
                const SizedBox(height: 22),
                _pad(Text(
                  results.isEmpty
                      ? 'No nuskhe match "${_query.trim()}"'
                      : '${results.length} ${results.length == 1 ? 'remedy' : 'remedies'} for "${_query.trim()}"',
                  style: ppJakarta(16),
                )),
                const SizedBox(height: 8),
                if (results.isEmpty)
                  _pad(Text('Try a situation like "cold", "colic", "teething" or "sleep".',
                      style: ppBody(13, color: ppMuted, h: 1.5)))
                else
                  _pad(Column(children: [
                    for (int i = 0; i < results.length; i++)
                      RemedyRow(
                          remedy: results[i],
                          top: i == 0,
                          bottom: true,
                          onTap: () => _openRemedy(context, results[i])),
                  ])),
              ]

              // --- BROWSE (when not searching) --------------------------------
              else ...[
                // by situation
                const SizedBox(height: 28),
                _pad(Text('By situation', style: ppJakarta(18))),
                const SizedBox(height: 14),
                for (int i = 0; i < kNuskheCategories.length; i += 2) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _cat(context, kNuskheCategories[i])),
                    const SizedBox(width: 12),
                    Expanded(
                        child: i + 1 < kNuskheCategories.length
                            ? _cat(context, kNuskheCategories[i + 1])
                            : const SizedBox()),
                  ])),
                ],

                // popular this monsoon
                const SizedBox(height: 28),
                _pad(Text('Popular this monsoon', style: ppJakarta(16))),
                const SizedBox(height: 12),
                for (int i = 0; i < popularRemedies.length; i++)
                  _pad(RemedyRow(
                      remedy: popularRemedies[i],
                      top: true,
                      bottom: i == popularRemedies.length - 1,
                      onTap: () => _openRemedy(context, popularRemedies[i]))),

                const SizedBox(height: 22),
                _pad(Text(
                    'No WhatsApp forwards here - only nuskhe reviewed and signed off by qualified ayurvedic practitioners.',
                    textAlign: TextAlign.center,
                    style: ppBody(12, color: ppMuted, h: 1.55))),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  Widget _cat(BuildContext context, NuskheCategory c) {
    final count = remedyCount(c.name);
    return GestureDetector(
      onTap: () => _openList(context, c.name),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: ppBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
            child: Icon(c.icon, size: 19, color: ppPurple),
          ),
          const SizedBox(height: 12),
          Text(c.name, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text('$count ${count == 1 ? 'remedy' : 'remedies'}', style: ppBody(12, color: ppMuted)),
        ]),
      ),
    );
  }
}

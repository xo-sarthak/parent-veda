// =============================================================================
//  NuskheScreen - Dadi / Nani ke Nuskhe · home remedies (parenting · S19)
// -----------------------------------------------------------------------------
//  Traditional grandmother home-remedies, each validated by an ayurvedic panel
//  + an MBBS paediatrician. Now DATA-DRIVEN off pp_nuskhe_data: a trust +
//  not-medical-advice banner, a real search that filters remedies by name /
//  situation, a browse-by-situation grid (real per-category counts, each opening
//  that situation's list) and a "Popular this monsoon" shelf of real remedies.
//  Reached from the Explore drawer. Cards and remedies open the remedy detail.
// =============================================================================

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
        const PpAskVedaFab(),
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

// =============================================================================
//  ProblemSolverScreen - Find the right help (parenting · Explore entry)
// -----------------------------------------------------------------------------
//  The find-help landing: a working search across every vetted expert, and a
//  "Browse by need" list of the seven care needs. Each need opens the ranked,
//  filterable results; a search hit opens that expert's profile. Reached from
//  the Explore drawer.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'pp_section_extras.dart';
import 'provider_profile_screen.dart';
import 'provider_results_screen.dart';

class ProblemSolverScreen extends StatefulWidget {
  const ProblemSolverScreen({super.key});

  @override
  State<ProblemSolverScreen> createState() => _ProblemSolverScreenState();
}

class _ProblemSolverScreenState extends State<ProblemSolverScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  List<Expert> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return kFindHelpExperts.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          e.blurb.toLowerCase().contains(q) ||
          e.credential.toLowerCase().contains(q);
    }).toList();
  }

  void _openNeed(FindHelpNeed need) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ProviderResultsScreen(need: need)),
      );

  void _openProfile(Expert e) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ProviderProfileScreen(expert: e)),
      );

  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    final matches = _matches;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 96),
            children: [
              _pad(ppBack(context, 'Explore')),

              const SizedBox(height: 22),
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Vetted experts'),
                const SizedBox(height: 10),
                Text('Find the right help', style: ppFraunces(32, h: 1.12)),
                const SizedBox(height: 12),
                Text(
                    'Paediatricians, therapists, lactation and more - each expert is vetted by ParentVeda. Search a name or a concern, or browse by need.',
                    style: ppBody(15)),
              ])),

              // working search
              const SizedBox(height: 20),
              _pad(ppSearchField(
                controller: _search,
                hint: 'Search experts - e.g. lactation, speech, skin',
                onChanged: (v) => setState(() => _query = v),
              )),

              if (searching) ...[
                const SizedBox(height: 20),
                _pad(Text(matches.isEmpty ? 'No experts match "$_query"' : '${matches.length} matching experts',
                    style: ppJakarta(16))),
                const SizedBox(height: 6),
                if (matches.isEmpty)
                  _pad(Text('Try a need like "pediatrician", "speech" or "skin".', style: ppBody(13)))
                else
                  for (var i = 0; i < matches.length; i++)
                    _pad(_expertRow(matches[i], top: i == 0, bottom: i == matches.length - 1)),
              ] else ...[
                // browse by need
                const SizedBox(height: 28),
                _pad(Text('Browse by need', style: ppJakarta(18))),
                const SizedBox(height: 4),
                _pad(Text('Vetted specialists for each stage of the early years.', style: ppBody(13))),
                const SizedBox(height: 12),
                for (var i = 0; i < kFindHelpNeeds.length; i++)
                  _pad(_needRow(kFindHelpNeeds[i], top: i == 0, bottom: i == kFindHelpNeeds.length - 1)),

                const SizedBox(height: 22),
                _pad(Text(
                    'Every expert is vetted by ParentVeda from credentials, experience and real parent reviews. Booking is mock for now - no payment is taken.',
                    textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
              ],
            ],
          ),
        ]),
      ),
    );
  }

  Widget _needRow(FindHelpNeed need, {bool top = false, bool bottom = false}) {
    final count = expertsForNeed(need.category).length;
    return GestureDetector(
      onTap: () => _openNeed(need),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(13)),
            child: Icon(need.icon, size: 20, color: ppPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(need.label, style: ppBody(15, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('$count vetted ${count == 1 ? 'expert' : 'experts'}', style: ppBody(12)),
            ]),
          ),
          const SizedBox(width: 10),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );
  }

  Widget _expertRow(Expert e, {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => _openProfile(e),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
            clipBehavior: Clip.antiAlias,
            child: const PpStriped(height: 54, colorA: ppBorder, colorB: ppStripeB),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.name, style: ppBody(15, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(e.category.isNotEmpty ? e.category : e.credential,
                  style: ppBody(12), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Row(children: [
                Text('★ ${e.ratingValue.toStringAsFixed(1)}', style: ppBody(12, color: ppCoral, w: FontWeight.w700)),
                const SizedBox(width: 8),
                Flexible(
                    child: Text('₹${e.priceValue} · consult',
                        style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
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

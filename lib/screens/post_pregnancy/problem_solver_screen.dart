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
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;

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

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  Find help on the shell every TTC and pregnancy tool wears, with the ask-a-
  //  doctor mark: the search as the same pill What changed uses, the needs and
  //  the matches as PvRowGroup lists under caps eyebrows. Same search, same
  //  results and profile screens. `_buildBeforeShell` is the page before, kept
  //  for revert.
  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    final matches = _matches;
    final p = pvStorePalette;
    Widget eyebrow(String t) => pregToolPad(Text(t.toUpperCase(),
        style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action)));
    return PregToolScaffold(
      hue: 206,
      eyebrow: 'Vetted experts',
      mark: IntentMark.askDoctor,
      title: 'Find the right help',
      intro:
          'Paediatricians, therapists, lactation and more - each expert is vetted by ParentVeda. Search a name or a concern, or browse by need.',
      children: [
        pregToolPad(TextField(
          key: const ValueKey('find_help_search'),
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          textInputAction: TextInputAction.search,
          style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
          decoration: InputDecoration(
            hintText: 'lactation, speech, skin...',
            hintStyle: pvManrope(fontSize: 15, color: p.ink3),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: p.ink3),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: Icon(Icons.close_rounded, size: 18, color: p.ink3),
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.ink1)),
          ),
        )),
        if (searching) ...[
          const SizedBox(height: 22),
          if (matches.isEmpty)
            pregToolPad(Text('No experts match "$_query". Try a need like "pediatrician", "speech" or "skin".',
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
          else ...[
            eyebrow('${matches.length} matching ${matches.length == 1 ? 'expert' : 'experts'}'),
            const SizedBox(height: 6),
            pregToolPad(PvRowGroup(p: p, children: [
              for (final e in matches)
                PvListRow(
                  key: ValueKey('find_help_expert_${e.name}'),
                  p: p,
                  leading: PvMarkWell(p: p, hue: 206, size: 40, icon: Icons.person_outline_rounded),
                  title: e.name,
                  line: e.category.isNotEmpty ? e.category : e.credential,
                  meta: '\u2605 ${e.ratingValue.toStringAsFixed(1)} · \u20b9${e.priceValue} · consult',
                  onTap: () => _openProfile(e),
                ),
            ])),
          ],
        ] else ...[
          const SizedBox(height: 24),
          eyebrow('Browse by need'),
          const SizedBox(height: 4),
          pregToolPad(Text('Vetted specialists for each stage of the early years.',
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2))),
          const SizedBox(height: 10),
          pregToolPad(PvRowGroup(p: p, children: [
            for (final need in kFindHelpNeeds)
              PvListRow(
                key: ValueKey('find_help_need_${need.category}'),
                p: p,
                leading: PvMarkWell(p: p, hue: 206, size: 40, icon: need.icon),
                title: need.label,
                line: () {
                  final count = expertsForNeed(need.category).length;
                  return '$count vetted ${count == 1 ? 'expert' : 'experts'}';
                }(),
                onTap: () => _openNeed(need),
              ),
          ])),
          const SizedBox(height: 22),
          pregToolPad(Text(
              'Every expert is vetted by ParentVeda from credentials, experience and real parent reviews. Booking is mock for now - no payment is taken.',
              style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink3))),
        ],
      ],
    );
  }

  // Kept for revert (2026-10-07): the page before the shared shell.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
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

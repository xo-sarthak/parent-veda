// =============================================================================
//  RecoSearchScreen - natural search across every recommendation
// -----------------------------------------------------------------------------
//  A calm search field over the whole reco engine. Empty state offers a few
//  gentle example queries; a live search shows matching picks as rows, with a
//  soft "no matches" state. Every result opens the full detail page.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reco_data.dart';
import 'pp_section_extras.dart';
import 'reco_common.dart';
import 'reco_detail_screen.dart';

class RecoSearchScreen extends StatefulWidget {
  const RecoSearchScreen({super.key});

  @override
  State<RecoSearchScreen> createState() => _RecoSearchScreenState();
}

class _RecoSearchScreenState extends State<RecoSearchScreen> {
  final TextEditingController _ctl = TextEditingController();
  String _query = '';

  static const List<String> _examples = [
    'Rainy day activities',
    'Books about emotions',
    'Travel',
    'Sensory play',
    'First birthday',
  ];

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _setQuery(String q) => setState(() => _query = q);

  void _runExample(String q) {
    _ctl.text = q;
    _ctl.selection = TextSelection.fromPosition(TextPosition(offset: q.length));
    _setQuery(q);
  }

  void _open(RecoItem it) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RecoDetailScreen(item: it)),
      );

  @override
  Widget build(BuildContext context) {
    final q = _query.trim();
    final results = q.isEmpty ? const <RecoItem>[] : recoSearch(q);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppBack(context, 'Recommendations'),
              const SizedBox(height: 18),
              ppEyebrow('Discover', color: ppPurple),
              const SizedBox(height: 10),
              Text('Search recommendations', style: ppFraunces(28, h: 1.12)),
              const SizedBox(height: 16),
              ppSearchField(
                controller: _ctl,
                hint: 'Try "sensory play" or "books about emotions"',
                onChanged: _setQuery,
              ),
              const SizedBox(height: 18),
            ]),
          ),
          Expanded(child: _content(q, results)),
        ]),
      ),
    );
  }

  Widget _content(String q, List<RecoItem> results) {
    if (q.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          ppEyebrow('Try one of these', color: ppMuted),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: [for (final e in _examples) _chip(e)]),
        ],
      );
    }
    if (results.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [_emptyState(q)],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      children: [
        Text('${results.length} ${results.length == 1 ? 'match' : 'matches'}',
            style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
        const SizedBox(height: 14),
        for (final r in results) RecoRow(item: r, onTap: () => _open(r)),
      ],
    );
  }

  Widget _chip(String label) => GestureDetector(
        onTap: () => _runExample(label),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ppHair),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.search_rounded, size: 14, color: ppPurple),
            const SizedBox(width: 7),
            Flexible(child: Text(label, style: ppBody(13, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      );

  Widget _emptyState(String q) => Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded, size: 26, color: ppPurple),
          ),
          const SizedBox(height: 16),
          Text('No matches for "$q"',
              textAlign: TextAlign.center, style: ppJakarta(16), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text('Try a broader word - a category, an age, or a theme like "sensory" or "sleep".',
              textAlign: TextAlign.center, style: ppBody(13, color: ppMuted, h: 1.5)),
        ]),
      );
}

// =============================================================================
//  NameListScreen - the no-swipe way to browse names (accessibility + choice)
// -----------------------------------------------------------------------------
//  The destination for "Just show me names": a calm, scrollable list parents can
//  browse and search without any gesture. Each name can be opened (full story),
//  liked (into the shared shortlist) with a large, labelled tap target, and the
//  shortlist / compare is one tap away. Nothing here requires swiping.
// =============================================================================

import 'package:flutter/material.dart';

import 'name_journey_detail_screen.dart';
import 'name_journey_shortlist_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';
import 'pp_section_extras.dart';

class NameListScreen extends StatefulWidget {
  const NameListScreen({super.key});

  @override
  State<NameListScreen> createState() => _NameListScreenState();
}

class _NameListScreenState extends State<NameListScreen> {
  final TextEditingController _searchCtl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  List<BabyName> get _results {
    if (_q.trim().isEmpty) return kBabyNames;
    final q = _q.toLowerCase();
    return kBabyNames.where((n) => '${n.name} ${n.meaningShort} ${n.script} ${n.feel} ${n.origin}'.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: NameMatchStore.instance,
          builder: (context, _) {
            final results = _results;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Baby Names')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Browse names', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Take your time', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('Scroll, search and tap any name to read its story or add it to your shortlist. No swiping needed.', style: ppBody(14, h: 1.55))),

                const SizedBox(height: 16),
                _pad(ppSearchField(
                  controller: _searchCtl,
                  hint: 'Search names, meanings, origins…',
                  onChanged: (v) => setState(() => _q = v),
                )),

                const SizedBox(height: 14),
                _pad(AnimatedBuilder(
                  animation: NameMatchStore.instance,
                  builder: (context, _) => GestureDetector(
                    onTap: () => _push(const NameJourneyShortlistScreen()),
                    behavior: HitTestBehavior.opaque,
                    child: Row(children: [
                      const Icon(Icons.favorite, size: 15, color: ppPurple),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${NameMatchStore.instance.likedCount} in your shortlist', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 10),
                      Text('View & compare →', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                )),

                const SizedBox(height: 16),
                if (results.isEmpty)
                  _pad(_empty())
                else
                  _pad(Column(children: [for (final n in results) _row(n)])),
              ],
            );
          },
        ),
      ),
      const PpAskVedaFab(),
      ]),
    );
  }

  Widget _empty() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Text('No names match that yet. Try a different word, or clear the search to see them all.', style: ppBody(13.5, color: ppMuted, h: 1.5)),
      );

  Widget _row(BabyName n) {
    final liked = NameMatchStore.instance.isLiked(n.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _push(NameJourneyDetailScreen(name: n.name)),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(n.name, style: ppFraunces(20, h: 1.05), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(n.script, style: ppFraunces(15, color: ppPurple), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 4),
                Text(n.meaningShort, style: ppBody(13, h: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
        ),
        // large, labelled like target - no gesture required
        GestureDetector(
          onTap: () => NameMatchStore.instance.like(n.name),
          behavior: HitTestBehavior.opaque,
          child: Semantics(
            button: true,
            label: liked ? '${n.name} is in your shortlist' : 'Add ${n.name} to shortlist',
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: liked ? ppPurple : ppPanel, shape: BoxShape.circle),
                child: Icon(liked ? Icons.favorite : Icons.favorite_border, size: 19, color: liked ? Colors.white : ppPurple),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
      ]),
    );
  }
}

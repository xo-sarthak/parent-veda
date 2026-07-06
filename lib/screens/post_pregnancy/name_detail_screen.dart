// =============================================================================
//  NameDetailScreen — Baby Name Finder · name detail (parenting · S27·detail)
// -----------------------------------------------------------------------------
//  The full story of one name: meaning, origin/syllables/numerology, the
//  ParentVeda perspective, similar names, and a "Learn" cross-link. The heart
//  adds it to your shared list. Faithful build of Claude Design "post pregnancy -
//  content.dc.html" · S27·detail. Backed by pp_names_data so every field is real.
// =============================================================================

import 'package:flutter/material.dart';

import 'article_archive_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';

class NameDetailScreen extends StatefulWidget {
  const NameDetailScreen({super.key, this.name = 'Aarav'});

  final String name;

  @override
  State<NameDetailScreen> createState() => _NameDetailScreenState();
}

class _NameDetailScreenState extends State<NameDetailScreen> {
  final NameMatchStore _store = NameMatchStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _toggleLike(BabyName n) {
    _store.like(n.name);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${n.name} added to your list'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = babyNameByName(widget.name);
    final liked = _store.isLiked(n.name);
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 60, bottom: 40),
          children: [
            // top bar: back + heart
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, size: 17, color: ppInk),
                ),
              ),
              GestureDetector(
                onTap: () => _toggleLike(n),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: ppCoralTint, shape: BoxShape.circle),
                  child: Icon(liked ? Icons.favorite : Icons.favorite_border, size: 16, color: ppCoral),
                ),
              ),
            ])),

            // name hero
            const SizedBox(height: 24),
            Center(child: Text(n.name, style: ppFraunces(50, h: 1.0))),
            const SizedBox(height: 6),
            Center(child: Text(n.script, style: ppFraunces(24, color: ppPurple, h: 1.1))),
            const SizedBox(height: 14),
            Center(
              child: GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pronunciation audio — coming soon'), behavior: SnackBarBehavior.floating),
                ),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.play_arrow_rounded, size: 16, color: ppPurple),
                    const SizedBox(width: 8),
                    Text(n.pron, style: ppBody(13, color: ppInk, w: FontWeight.w600)),
                  ]),
                ),
              ),
            ),

            // popularity trend
            const SizedBox(height: 12),
            Center(child: _popPill(n.popularity)),

            // meaning
            const SizedBox(height: 24),
            _pad(Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Meaning', color: ppPurple, spacing: 0.8),
                const SizedBox(height: 8),
                Text('“${n.meaningFull}”', style: ppFraunces(19, h: 1.4)),
              ]),
            )),

            // famous / mythological reference
            const SizedBox(height: 20),
            _pad(Align(alignment: Alignment.centerLeft, child: Text('Famous & lore', style: ppJakarta(15)))),
            const SizedBox(height: 8),
            _pad(Text(n.famous, style: ppBody(14, h: 1.65))),

            // facts grid
            const SizedBox(height: 20),
            _pad(Row(children: [
              _fact(n.origin, 'origin'),
              const SizedBox(width: 10),
              _fact('${n.syllables}', 'syllables'),
              const SizedBox(width: 10),
              _fact('${n.numerology}', 'numerology'),
            ])),

            // nakshatra fit — offered as tradition
            const SizedBox(height: 14),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: ppBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.nights_stay_outlined, size: 16, color: ppPurple),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ppEyebrow('Nakshatra fit', color: ppPurple, spacing: 0.8),
                    const SizedBox(height: 6),
                    Text(n.nakshatra, style: ppBody(13, color: ppInk, h: 1.5)),
                    const SizedBox(height: 4),
                    Text('Offered as tradition, if it matters to you — not a claim.', style: ppBody(11, color: ppMuted, h: 1.4)),
                  ]),
                ),
              ]),
            )),

            // perspective
            const SizedBox(height: 20),
            _pad(Align(alignment: Alignment.centerLeft, child: Text('The ParentVeda perspective', style: ppJakarta(15)))),
            const SizedBox(height: 8),
            _pad(Text(n.perspective, style: ppBody(14, h: 1.65))),

            _pad(ppSectionDivider()),

            // similar
            _pad(Align(alignment: Alignment.centerLeft, child: Text('Similar names', style: ppJakarta(15)))),
            const SizedBox(height: 12),
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: n.similar.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _similarCard(n.similar[i]),
              ),
            ),

            // learn
            const SizedBox(height: 22),
            _pad(GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ArticleArchiveScreen())),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair), bottom: BorderSide(color: ppHair))),
                child: Row(children: [
                  Container(
                    width: 66,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                    child: Text('Learn', style: ppBody(10, color: ppPurple, w: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Nakshatra-based naming, explained', style: ppBody(14, color: ppInk))),
                  const SizedBox(width: 10),
                  const Text('→', style: TextStyle(color: ppMuted)),
                ]),
              ),
            )),

            const SizedBox(height: 20),
            _pad(Text('Meaning verified by our language reviewers. Numerology (Chaldean) offered as tradition, not a claim.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),

        // top fade
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _popPill(String tier) {
    final trending = tier.toLowerCase() == 'trending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: trending ? ppCoralTint : ppPanel, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(trending ? Icons.trending_up_rounded : Icons.workspace_premium_outlined, size: 13, color: trending ? ppCoral : ppPurple),
        const SizedBox(width: 6),
        Text(tier, style: ppBody(11, color: trending ? ppCoral : ppPurple, w: FontWeight.w700)),
      ]),
    );
  }

  Widget _fact(String big, String small) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
          child: Column(children: [
            Text(big, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: ppJakarta(14)),
            const SizedBox(height: 2),
            Text(small, style: ppBody(10, color: ppMuted)),
          ]),
        ),
      );

  Widget _similarCard((String, String) s) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NameDetailScreen(name: s.$1))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(s.$1, style: ppFraunces(20, h: 1.0)),
            const SizedBox(height: 2),
            Text(s.$2, style: ppBody(11, color: ppMuted)),
          ]),
        ),
      );
}

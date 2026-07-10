// =============================================================================
//  RecoLibraryScreen - everything the parent has kept, in one calm place
// -----------------------------------------------------------------------------
//  Three quiet sections, each hiding when empty: "Continue exploring" (a rail of
//  recently-opened picks), "Saved" (hearted picks) and "Your lists" (named
//  wishlists, each opening an inline list view). A warm empty state when there
//  is nothing yet. Reads live from the RecoStore.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reco_data.dart';
import 'reco_common.dart';
import 'reco_detail_screen.dart';

class RecoLibraryScreen extends StatelessWidget {
  const RecoLibraryScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(BuildContext context, RecoItem it) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RecoDetailScreen(item: it)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: RecoStore.instance,
          builder: (context, _) {
            final store = RecoStore.instance;
            final continueEx = store.continueExploring;
            final saved = store.saved;
            final lists = store.listNames;
            final nothing = continueEx.isEmpty && saved.isEmpty && lists.isEmpty;

            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Recommendations')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Your library', color: ppPurple)),
                const SizedBox(height: 10),
                _pad(Text('Saved & explored', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 8),
                _pad(Text('Everything you have kept for him, gathered in one calm place.',
                    style: ppBody(13.5, h: 1.5))),
                const SizedBox(height: 24),

                if (nothing) _pad(_recoLibraryEmpty()),

                // ---- Continue exploring (rail) ----
                if (continueEx.isNotEmpty) ...[
                  _pad(_sectionHead('Continue exploring', 'Pick up where you left off')),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 266,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: continueEx.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (_, i) => RecoRailCard(item: continueEx[i], onTap: () => _open(context, continueEx[i])),
                    ),
                  ),
                  const SizedBox(height: 26),
                ],

                // ---- Saved ----
                if (saved.isNotEmpty) ...[
                  _pad(_sectionHead('Saved', '${saved.length} ${saved.length == 1 ? 'pick' : 'picks'} you have hearted')),
                  const SizedBox(height: 14),
                  _pad(Column(children: [
                    for (final r in saved) RecoRow(item: r, onTap: () => _open(context, r)),
                  ])),
                  const SizedBox(height: 12),
                ],

                // ---- Your lists ----
                if (lists.isNotEmpty) ...[
                  _pad(_sectionHead('Your lists', 'Wishlists to revisit and share')),
                  const SizedBox(height: 14),
                  _pad(Column(children: [
                    for (final name in lists) _listRow(context, name, store.listCount(name)),
                  ])),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionHead(String title, String sub) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: ppJakarta(18)),
        const SizedBox(height: 4),
        Text(sub, style: ppBody(12.5, color: ppMuted)),
      ]);

  Widget _listRow(BuildContext context, String name, int count) => GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => RecoListScreen(name: name)),
        ),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ppHair),
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.bookmark_border_rounded, size: 19, color: ppPurple),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: ppBody(14.5, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(count == 0 ? 'Empty for now' : '$count ${count == 1 ? 'item' : 'items'}',
                    style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

// -----------------------------------------------------------------------------
//  RecoListScreen - one named wishlist, in full (opened from the library).
// -----------------------------------------------------------------------------
class RecoListScreen extends StatelessWidget {
  const RecoListScreen({super.key, required this.name});
  final String name;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(BuildContext context, RecoItem it) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RecoDetailScreen(item: it)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: RecoStore.instance,
          builder: (context, _) {
            final items = RecoStore.instance.listItems(name).map(recoById).toList();
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Library')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Your list', color: ppPurple)),
                const SizedBox(height: 10),
                _pad(Text(name, style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 8),
                _pad(Text(
                  items.isEmpty
                      ? 'Nothing here yet - add picks with "Add to list".'
                      : '${items.length} ${items.length == 1 ? 'pick' : 'picks'} saved to this list',
                  style: ppBody(13.5, h: 1.5),
                )),
                const SizedBox(height: 22),
                if (items.isEmpty)
                  _pad(_recoListEmpty())
                else
                  _pad(Column(children: [
                    for (final r in items) RecoRow(item: r, onTap: () => _open(context, r)),
                  ])),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _recoLibraryEmpty() => Container(
      padding: const EdgeInsets.symmetric(vertical: 44),
      alignment: Alignment.center,
      child: Column(children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: const Icon(Icons.favorite_border, size: 24, color: ppPurple),
        ),
        const SizedBox(height: 16),
        Text('Your library is waiting', textAlign: TextAlign.center, style: ppJakarta(16)),
        const SizedBox(height: 8),
        Text('Save a pick with the heart, or add it to a list, and it will gather here for you.',
            textAlign: TextAlign.center, style: ppBody(13, color: ppMuted, h: 1.5)),
      ]),
    );

Widget _recoListEmpty() => Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: const Icon(Icons.playlist_add_rounded, size: 26, color: ppPurple),
        ),
        const SizedBox(height: 16),
        Text('This list is empty', textAlign: TextAlign.center, style: ppJakarta(16)),
        const SizedBox(height: 8),
        Text('Open any recommendation and tap "Add to list" to start filling it.',
            textAlign: TextAlign.center, style: ppBody(13, color: ppMuted, h: 1.5)),
      ]),
    );

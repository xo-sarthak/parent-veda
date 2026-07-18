// =============================================================================
//  RecoLibraryScreen - everything the parent has kept, in one calm place
// -----------------------------------------------------------------------------
//  Three quiet sections: "Continue exploring" (a rail of recently-opened picks),
//  "Saved" (hearted picks) and "Your lists" (named wishlists, each opening an
//  inline list view). None of them hide when empty - each renders its header, a
//  warm note, and a way through to browse - so wishlists and saving stay
//  discoverable to someone who has never used them. Reads live from RecoStore.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reco_data.dart';
import 'pp_tools_kit.dart';
import 'reco_common.dart';
import 'reco_detail_screen.dart';
import 'recommendations_screen.dart';

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
            // final nothing = continueEx.isEmpty && saved.isEmpty && lists.isEmpty;

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

                // NOTE: the whole-screen "nothing here" card is retired - all
                // three sections now render their own header, note and way
                // through, which teaches what the library is for far better
                // than one generic message did. Kept commented for revert.
                // if (nothing) _pad(_recoLibraryEmpty()),

                // ---- Continue exploring (rail) ----
                // When there is nothing to continue, the section still renders -
                // but as an invitation to start exploring rather than a dead
                // "nothing here". An empty state has to offer the way in.
                if (continueEx.isEmpty) ...[
                  _pad(_sectionHead('Continue exploring', 'Start somewhere and pick it up later')),
                  const SizedBox(height: 14),
                  _pad(ppEmptyCard(Icons.explore_outlined,
                      'Nothing in progress yet. Browse recommendations and anything you open will wait for you here.')),
                  const SizedBox(height: 12),
                  _pad(_exploreCta(context)),
                  const SizedBox(height: 26),
                ],
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

                // ---- Saved (always renders) ----
                _pad(_sectionHead('Saved', saved.isEmpty ? 'Picks you heart are kept here' : '${saved.length} ${saved.length == 1 ? 'pick' : 'picks'} you have hearted')),
                const SizedBox(height: 14),
                if (saved.isEmpty) ...[
                  _pad(ppEmptyCard(Icons.favorite_border_rounded,
                      'Nothing saved yet. Tap the heart on any recommendation and it will wait for you here.')),
                  const SizedBox(height: 12),
                  _pad(_exploreCta(context)),
                ] else
                  _pad(Column(children: [
                    for (final r in saved) RecoRow(item: r, onTap: () => _open(context, r)),
                  ])),
                const SizedBox(height: 12),

                // ---- Your lists (always renders) ----
                _pad(_sectionHead('Your lists', 'Wishlists to revisit and share')),
                const SizedBox(height: 14),
                if (lists.isEmpty) ...[
                  _pad(ppEmptyCard(Icons.playlist_add_rounded,
                      'No lists yet. Group saved picks into a wishlist to revisit later or share with family.')),
                  const SizedBox(height: 12),
                  _pad(_exploreCta(context)),
                ] else
                  _pad(Column(children: [
                    for (final name in lists) _listRow(context, name, store.listCount(name)),
                  ])),
              ],
            );
          },
        ),
      ),
    );
  }

  // The way OUT of an empty section. An empty state that only describes itself
  // is dead space; this gives her somewhere to go from every one of them.
  Widget _exploreCta(BuildContext context) => GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const RecommendationsScreen()),
        ),
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Text('Browse recommendations',
              style: ppBody(13.5, color: ppPurple, w: FontWeight.w700)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_rounded, size: 15, color: ppPurple),
        ]),
      );

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

// RETIRED with the whole-screen empty branch above. Kept for revert.
// ignore: unused_element
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

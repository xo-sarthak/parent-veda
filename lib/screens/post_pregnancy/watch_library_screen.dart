// =============================================================================
//  WatchLibraryScreen - "Watch later" / your library
// -----------------------------------------------------------------------------
//  Continue watching, Saved, Recently watched and Collections in one calm place.
//  (Downloads/offline is a stubbed future row.) Reflects the WatchStore live.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_watch_data.dart';
import 'watch_collection_screen.dart';
import 'watch_common.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class WatchLibraryScreen extends StatelessWidget {
  const WatchLibraryScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(BuildContext context, WatchVideo v) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: WatchStore.instance,
          builder: (context, _) {
            final store = WatchStore.instance;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Watch')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Your library', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Watch later', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 22),

                _section(context, 'Continue watching', store.continueWatching, withProgress: true),
                _section(context, 'Saved', store.saved),
                _section(context, 'Recently watched', store.recentlyWatched),

                _pad(watchSectionHeader('Collections')),
                const SizedBox(height: 14),
                _pad(Column(children: [
                  for (final c in kWatchCollections) _collectionRow(context, c),
                ])),

                const SizedBox(height: 8),
                _pad(GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offline downloads coming soon'), behavior: SnackBarBehavior.floating),
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Row(children: [
                    const Icon(Icons.download_outlined, size: 18, color: ppPurple),
                    const SizedBox(width: 10),
                    Text('Downloaded - offline viewing', style: ppBody(13.5, color: ppInk, w: FontWeight.w600)),
                    const Spacer(),
                    Text('Soon', style: ppBody(11, color: ppMuted, w: FontWeight.w700)),
                  ]),
                )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<WatchVideo> vids, {bool withProgress = false}) {
    if (vids.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(watchSectionHeader(title)),
      const SizedBox(height: 14),
      SizedBox(
        height: 210,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: vids.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) => WatchRailCard(
            video: vids[i],
            onTap: () => _open(context, vids[i]),
            progress: withProgress ? WatchStore.instance.progressOf(vids[i].id) : null,
          ),
        ),
      ),
      const SizedBox(height: 26),
    ]);
  }

  Widget _collectionRow(BuildContext context, WatchCollection c) {
    final mins = c.videoIds.map(watchVideoById).fold<int>(0, (a, v) => a + v.seconds) ~/ 60;
    final prog = WatchStore.instance.collectionProgress(c);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WatchCollectionScreen(collection: c))),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          SizedBox(width: 96, child: WatchThumb(seed: c.seed, height: 60, showPlay: false, progress: prog > 0 ? prog : null)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: ppJakarta(14), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text('${c.videoIds.length} videos · ~$mins min', style: ppBody(12, color: ppMuted)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );
  }
}

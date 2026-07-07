// =============================================================================
//  WatchCollectionScreen - a curated learning collection (a path with an end)
// -----------------------------------------------------------------------------
//  Not a playlist - a short, finishable path: cover, count, estimated time,
//  progress, then the ordered videos with completed ticks. Reached from the Watch
//  home's Expert Collections rail.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_watch_data.dart';
import 'watch_common.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class WatchCollectionScreen extends StatelessWidget {
  const WatchCollectionScreen({super.key, required this.collection});
  final WatchCollection collection;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(BuildContext context, WatchVideo v) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v)),
      );

  @override
  Widget build(BuildContext context) {
    final vids = collection.videoIds.map(watchVideoById).toList();
    final mins = vids.fold<int>(0, (a, v) => a + v.seconds) ~/ 60;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: WatchStore.instance,
          builder: (context, _) {
            final prog = WatchStore.instance.collectionProgress(collection);
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Watch')),
                const SizedBox(height: 16),
                _pad(WatchThumb(seed: collection.seed, height: 180, showPlay: false, progress: prog > 0 ? prog : null)),
                const SizedBox(height: 16),
                _pad(ppEyebrow('Collection', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text(collection.title, style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 8),
                _pad(Text(collection.subtitle, style: ppBody(14, h: 1.55))),
                const SizedBox(height: 12),
                _pad(Text('${vids.length} videos · ~$mins min · ${prog >= 1 ? 'completed' : prog > 0 ? '${(prog * 100).round()}% done' : 'not started'}',
                    style: ppBody(12.5, color: ppPurple, w: FontWeight.w700))),
                const SizedBox(height: 22),
                for (int i = 0; i < vids.length; i++) _pad(_row(context, i + 1, vids[i])),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(BuildContext context, int n, WatchVideo v) {
    final done = WatchStore.instance.progressOf(v.id) >= 0.9;
    final p = WatchStore.instance.progressOf(v.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _open(context, v),
        behavior: HitTestBehavior.opaque,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(top: 28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? ppPurple : Colors.transparent,
              shape: BoxShape.circle,
              border: done ? null : Border.all(color: ppBorder, width: 1.5),
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text('$n', style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 120, child: WatchThumb(seed: v.seed, height: 78, duration: v.durationLabel, quick: v.quick, progress: p > 0.02 && p < 0.98 ? p : null)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v.title, style: ppJakarta(14).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  watchMeta(v),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

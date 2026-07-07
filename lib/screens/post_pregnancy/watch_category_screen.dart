// =============================================================================
//  WatchCategoryScreen — a single category's learning feed
// -----------------------------------------------------------------------------
//  A calm vertical feed of the videos in one category (e.g. Sleep). Large cards,
//  learning metadata only. Reached from the Watch home's category chips.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_watch_data.dart';
import 'watch_common.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class WatchCategoryScreen extends StatelessWidget {
  const WatchCategoryScreen({super.key, required this.category});
  final String category;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(BuildContext context, WatchVideo v) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v)),
      );

  @override
  Widget build(BuildContext context) {
    final vids = watchByCategory(category);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Watch')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Category', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text(category, style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 6),
            _pad(Text('${vids.length} expert ${vids.length == 1 ? 'video' : 'videos'} for this stage', style: ppBody(13))),
            const SizedBox(height: 22),
            if (vids.isEmpty)
              _pad(Text('New videos for this topic are on the way.', style: ppBody(14, color: ppMuted)))
            else
              _pad(Column(children: [
                for (final v in vids)
                  WatchListCard(
                    video: v,
                    onTap: () => _open(context, v),
                    progress: () {
                      final p = WatchStore.instance.progressOf(v.id);
                      return p > 0.02 && p < 0.98 ? p : null;
                    }(),
                  ),
              ])),
          ],
        ),
      ),
    );
  }
}

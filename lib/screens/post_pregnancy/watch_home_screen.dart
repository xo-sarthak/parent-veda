// =============================================================================
//  WatchHomeScreen - ParentVeda Watch home ("what should I watch today?")
// -----------------------------------------------------------------------------
//  The daily habit. One carefully-chosen Today's Video, Continue Watching,
//  personalised picks, category feeds and expert collections - all learning-first
//  (topic · age · expert · duration, never likes/views). A Quick Learn / Deep
//  Learn toggle switches the hero + picks between 30–90s clips and 5–30 min
//  sessions, sharing the same catalog, progress and collections. Reached from the
//  Explore drawer. Pushed screen (back button, no bottom nav).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_watch_data.dart';
import 'watch_category_screen.dart';
import 'watch_collection_screen.dart';
import 'watch_common.dart';
import 'watch_library_screen.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class WatchHomeScreen extends StatefulWidget {
  const WatchHomeScreen({super.key});

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {
  bool _quick = false; // false = Deep Learn, true = Quick Learn

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  void _open(WatchVideo v) => v.quick ? _push(QuickLearnScreen(startId: v.id)) : _push(WatchPlayerScreen(video: v));

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
            final continues = store.continueWatching;
            final picks = (_quick ? quickVideos : deepVideos);
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Explore')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('ParentVeda Watch', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Learn something today', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 6),
                _pad(Text('Five minutes here should make you a better parent today - not just pass the time.',
                    style: ppBody(14, h: 1.5))),

                const SizedBox(height: 18),
                _pad(_modeToggle()),

                const SizedBox(height: 26),
                _pad(watchSectionHeader('Today for Aarav')),
                const SizedBox(height: 14),
                _pad(_todaysHero()),

                if (continues.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  _pad(watchSectionHeader('Continue watching')),
                  const SizedBox(height: 14),
                  _rail(continues, (v) => store.progressOf(v.id)),
                ],

                const SizedBox(height: 30),
                _pad(watchSectionHeader(_quick ? 'Quick lessons for you' : 'Chosen for you')),
                const SizedBox(height: 4),
                _pad(Text('Picked for his age and where he is right now - never random.', style: ppBody(12.5, color: ppMuted))),
                const SizedBox(height: 16),
                _pad(Column(children: [
                  for (final v in picks.take(5)) WatchListCard(video: v, onTap: () => _open(v), progress: store.progressOf(v.id) > 0.02 && store.progressOf(v.id) < 0.98 ? store.progressOf(v.id) : null),
                ])),

                const SizedBox(height: 14),
                _pad(watchSectionHeader('Explore by topic')),
                const SizedBox(height: 14),
                _pad(_categories()),

                const SizedBox(height: 30),
                _pad(watchSectionHeader('Expert collections')),
                const SizedBox(height: 4),
                _pad(Text('Short, finishable learning paths - not endless playlists.', style: ppBody(12.5, color: ppMuted))),
                const SizedBox(height: 16),
                _collectionsRail(),

                const SizedBox(height: 30),
                _pad(_libraryLink()),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- mode toggle --------------------------------------------------------
  Widget _modeToggle() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          _seg('Deep Learn', '5–30 min', !_quick, () => setState(() => _quick = false)),
          _seg('Quick Learn', '30–90 sec', _quick, () => setState(() => _quick = true)),
        ]),
      );

  Widget _seg(String label, String sub, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: on ? const [BoxShadow(color: Color(0x146A30B6), blurRadius: 10, offset: Offset(0, 3))] : null,
            ),
            child: Column(children: [
              Text(label, style: ppBody(13, color: on ? ppPurple : ppSoft, w: FontWeight.w700)),
              const SizedBox(height: 1),
              Text(sub, style: ppBody(10, color: on ? ppMuted : ppMuted)),
            ]),
          ),
        ),
      );

  // ---- today's hero -------------------------------------------------------
  Widget _todaysHero() {
    final v = todaysVideo(quick: _quick);
    return GestureDetector(
      onTap: () => _open(v),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: ppHair), boxShadow: ppCardShadow),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          WatchThumb(seed: v.seed, height: 196, radius: 0, duration: v.durationLabel, quick: v.quick),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Flexible(child: ppEyebrow('Why this matters today', color: ppPurple, spacing: 1.0)),
              ]),
              const SizedBox(height: 12),
              Text(v.title, style: ppFraunces(21, h: 1.2)),
              const SizedBox(height: 8),
              Text(v.why, style: ppBody(13.5, h: 1.55)),
              const SizedBox(height: 12),
              watchMeta(v, color: ppSoft),
              const SizedBox(height: 16),
              Row(children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Flexible(child: Text('Watch now', style: ppBody(13, color: Colors.white, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  // ---- rails --------------------------------------------------------------
  Widget _rail(List<WatchVideo> vids, double Function(WatchVideo) progress) => SizedBox(
        height: 210,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: vids.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) => WatchRailCard(video: vids[i], onTap: () => _open(vids[i]), progress: progress(vids[i])),
        ),
      );

  Widget _categories() => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in kWatchCategories)
            GestureDetector(
              onTap: () => _push(WatchCategoryScreen(category: c.$1)),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: ppHair)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(c.$2, size: 15, color: ppPurple),
                  const SizedBox(width: 7),
                  Text(c.$1, style: ppBody(12.5, color: ppInk, w: FontWeight.w600)),
                ]),
              ),
            ),
        ],
      );

  Widget _collectionsRail() {
    final cols = expertCollections();
    return SizedBox(
        height: 216,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: cols.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) {
            final c = cols[i];
            final mins = c.videoIds.map(watchVideoById).fold<int>(0, (a, v) => a + v.seconds) ~/ 60;
            final prog = WatchStore.instance.collectionProgress(c);
            return GestureDetector(
              onTap: () => _push(WatchCollectionScreen(collection: c)),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 200,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  WatchThumb(seed: c.seed, height: 116, showPlay: false, progress: prog > 0 ? prog : null),
                  const SizedBox(height: 10),
                  Text(c.title, style: ppJakarta(14.5).copyWith(height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${c.videoIds.length} videos · ~$mins min', style: ppBody(11.5, color: ppMuted)),
                  const SizedBox(height: 4),
                  Text(prog >= 1 ? 'Completed' : prog > 0 ? '${(prog * 100).round()}% done' : 'Not started',
                      style: ppBody(11, color: prog > 0 ? ppPurple : ppMuted, w: FontWeight.w700)),
                ]),
              ),
            );
          },
        ),
      );
  }

  Widget _libraryLink() => GestureDetector(
        onTap: () => _push(const WatchLibraryScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            const Icon(Icons.bookmark_outline_rounded, size: 20, color: ppPurple),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your library', style: ppJakarta(15)),
                const SizedBox(height: 2),
                Text('Saved, continue watching & collections', style: ppBody(12)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

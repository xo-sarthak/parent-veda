// =============================================================================
//  WatchShortsScreen - YouTube-Shorts-style infinite vertical feed
// -----------------------------------------------------------------------------
//  A pure, endless vertical swipe over the Quick clips - it LOOPS the set forever
//  (no "that's enough" stop card, no channel interstitials), unlike the finite,
//  deliberately-ending Quick Learn mode. Learning-first all the same: Save (not
//  like), no view/like counts, expert-led, and the caption links straight to the
//  expert's channel. Reached from the "Shorts" toggle on the Watch home. Mock
//  playback surface (video on hold) - infinite scroll uses a paginating
//  PageView.builder, never a repeating animation.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_watch_data.dart';
import 'watch_channel_screen.dart';

class WatchShortsScreen extends StatefulWidget {
  const WatchShortsScreen({super.key, this.startId});
  final String? startId;

  @override
  State<WatchShortsScreen> createState() => _WatchShortsScreenState();
}

class _WatchShortsScreenState extends State<WatchShortsScreen> {
  final List<WatchVideo> _vids = quickVideos;
  late final PageController _pc;
  late final int _base; // a large multiple of length, so we can also swipe "up"

  static const Color _dark = Color(0xFF2A1F3D);

  @override
  void initState() {
    super.initState();
    final len = _vids.isEmpty ? 1 : _vids.length;
    final start = widget.startId == null ? 0 : _vids.indexWhere((v) => v.id == widget.startId);
    final startIndex = start < 0 ? 0 : start;
    // Sit deep in the middle so both directions feel endless; keep the modulo
    // aligned to startIndex so the requested short opens first.
    _base = len * 1000;
    _pc = PageController(initialPage: _base + startIndex);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _soon(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  WatchVideo _at(int page) => _vids[page % _vids.length];

  @override
  Widget build(BuildContext context) {
    if (_vids.isEmpty) {
      return const Scaffold(backgroundColor: _dark, body: SizedBox.shrink());
    }
    return Scaffold(
      backgroundColor: _dark,
      body: Stack(children: [
        PageView.builder(
          controller: _pc,
          scrollDirection: Axis.vertical,
          // No itemCount = endless; PageView.builder stays lazy (no animation loop).
          onPageChanged: (i) => WatchStore.instance.setProgress(_at(i).id, 0.5),
          itemBuilder: (_, i) => _clip(_at(i)),
        ),
        // top bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text('Shorts', style: ppFraunces(20, color: Colors.white)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _clip(WatchVideo v) {
    return AnimatedBuilder(
      animation: WatchStore.instance,
      builder: (context, _) {
        final store = WatchStore.instance;
        final saved = store.isSaved(v.id);
        final subscribed = store.isSubscribed(v.expertId);
        return Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ppPurple.withValues(alpha: 0.65), _dark],
                ),
              ),
            ),
          ),
          const Center(child: Icon(Icons.play_arrow_rounded, size: 64, color: Colors.white38)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 340,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC2A1F3D)]),
              ),
            ),
          ),
          // right actions
          Positioned(
            right: 12,
            bottom: 170,
            child: Column(children: [
              _action(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, saved ? 'Saved' : 'Save', () => store.toggleSave(v.id)),
              const SizedBox(height: 20),
              _action(Icons.ios_share_rounded, 'Share', () => _soon('Sharing coming soon')),
              const SizedBox(height: 20),
              _action(Icons.auto_awesome_outlined, 'Ask Veda', () => openPpTab(context, 1)),
              const SizedBox(height: 20),
              _action(Icons.more_horiz_rounded, 'More', () => _soon('More options coming soon')),
            ]),
          ),
          // caption
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 78, 40),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
                  child: Text('${v.category}  ·  ${v.ageTag}  ·  ${v.durationLabel}',
                      style: ppBody(10.5, color: Colors.white, w: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                Text(v.title, style: ppFraunces(22, color: Colors.white, h: 1.2)),
                const SizedBox(height: 8),
                Text(v.why, style: ppBody(13.5, color: Colors.white.withValues(alpha: 0.9), h: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _push(WatchChannelScreen(expertId: v.expertId)),
                      behavior: HitTestBehavior.opaque,
                      child: Row(children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                          clipBehavior: Clip.antiAlias,
                          child: const PpStriped(height: 34),
                        ),
                        const SizedBox(width: 10),
                        Flexible(child: Text(v.expert.name, style: ppBody(13, color: Colors.white, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => store.toggleSubscribe(v.expertId),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: subscribed ? Colors.transparent : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: subscribed ? Border.all(color: Colors.white54) : null,
                      ),
                      child: Text(subscribed ? 'Subscribed' : 'Subscribe',
                          style: ppBody(12, color: subscribed ? Colors.white : ppPurple, w: FontWeight.w800)),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ]);
      },
    );
  }

  Widget _action(IconData i, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle),
            child: Icon(i, size: 22, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(label, style: ppBody(10, color: Colors.white, w: FontWeight.w600)),
        ]),
      );
}

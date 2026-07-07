// =============================================================================
//  QuickLearnScreen - Quick Learn vertical mode (30–90s expert clips)
// -----------------------------------------------------------------------------
//  Borrows the vertical-swipe INTERACTION (learn while rocking the baby), never
//  the clutter: learning metadata only, expert-led, Save (not like), no
//  view/like/follow counts. Deliberately FINITE - after the curated set it ends
//  on a calm "that's enough for now" card instead of scrolling forever. Shares
//  the same catalog, save + progress store as Deep Learn.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_watch_data.dart';
import 'provider_profile_screen.dart';

class QuickLearnScreen extends StatefulWidget {
  const QuickLearnScreen({super.key, this.startId});
  final String? startId;

  @override
  State<QuickLearnScreen> createState() => _QuickLearnScreenState();
}

class _QuickLearnScreenState extends State<QuickLearnScreen> {
  late final PageController _pc;
  final List<WatchVideo> _vids = quickVideos;
  int _page = 0;

  static const Color _dark = Color(0xFF2A1F3D);

  @override
  void initState() {
    super.initState();
    final start = widget.startId == null ? 0 : _vids.indexWhere((v) => v.id == widget.startId);
    _page = start < 0 ? 0 : start;
    _pc = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _soon(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: Stack(children: [
        PageView.builder(
          controller: _pc,
          scrollDirection: Axis.vertical,
          itemCount: _vids.length + 1, // +1 = the calm stop card
          onPageChanged: (i) {
            setState(() => _page = i);
            if (i < _vids.length) WatchStore.instance.setProgress(_vids[i].id, 0.5);
          },
          itemBuilder: (_, i) => i < _vids.length ? _clip(_vids[i]) : _stopCard(),
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
              Text('Quick Learn', style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
              const Spacer(),
              if (_page < _vids.length)
                Text('${_page + 1} / ${_vids.length}', style: ppBody(12, color: Colors.white.withValues(alpha: 0.7), w: FontWeight.w600)),
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
        final saved = WatchStore.instance.isSaved(v.id);
        return Stack(children: [
          // "video" surface
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
          // bottom gradient scrim
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC2A1F3D)]),
              ),
            ),
          ),
          // right actions
          Positioned(
            right: 12,
            bottom: 150,
            child: Column(children: [
              _action(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, saved ? 'Saved' : 'Save', () => WatchStore.instance.toggleSave(v.id)),
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
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _push(ProviderProfileScreen(expert: v.expert)),
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
              ]),
            ),
          ),
        ]);
      },
    );
  }

  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

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

  Widget _stopCard() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.spa_outlined, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text("That's enough for now", textAlign: TextAlign.center, style: ppFraunces(24, color: Colors.white, h: 1.2)),
            const SizedBox(height: 12),
            Text('You learned something real today. Close the app, and go be with your baby - that’s the point.',
                textAlign: TextAlign.center, style: ppBody(14, color: Colors.white.withValues(alpha: 0.85), h: 1.6)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                child: Text('Done', style: ppBody(13.5, color: ppPurple, w: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      );
}

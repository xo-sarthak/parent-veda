// =============================================================================
//  WatchPlayerScreen — Deep Learn video player (the signature experience)
// -----------------------------------------------------------------------------
//  A premium, calm player. Learning-only actions (Save · Share · Ask Veda ·
//  More) — never likes/comments/followers. Below the video, instead of a comment
//  feed, a curated "Learn next" CHAIN that walks the parent onward through the
//  ParentVeda ecosystem (Activity → Article → Product → Recipe → Community → Ask
//  Veda → Quiz), plus the expert (Follow, not Subscribe). No autoplay-to-nowhere.
//  Mock playback surface (no real video engine yet); progress is remembered.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_watch_data.dart';
import 'provider_profile_screen.dart';
import 'watch_common.dart';
import 'watch_quicklearn_screen.dart';

class WatchPlayerScreen extends StatefulWidget {
  const WatchPlayerScreen({super.key, required this.video});
  final WatchVideo video;

  @override
  State<WatchPlayerScreen> createState() => _WatchPlayerScreenState();
}

class _WatchPlayerScreenState extends State<WatchPlayerScreen> {
  bool _playing = false;

  WatchVideo get v => widget.video;

  @override
  void initState() {
    super.initState();
    // Register the video as being watched (continue-watching + recent), without
    // clobbering real progress if the parent resumed partway.
    final store = WatchStore.instance;
    if (store.progressOf(v.id) < 0.02) store.setProgress(v.id, 0.06);
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));
  void _soon(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            _videoSurface(),
            const SizedBox(height: 16),
            _pad(_actions()),
            const SizedBox(height: 18),
            _pad(Text(v.title, style: ppFraunces(23, h: 1.2))),
            const SizedBox(height: 8),
            _pad(watchMeta(v, color: ppSoft)),
            const SizedBox(height: 16),
            _pad(_expertRow()),
            const SizedBox(height: 18),
            _pad(Text(v.why, style: ppBody(14.5, color: ppInk, h: 1.6))),
            const SizedBox(height: 8),
            _pad(ppSectionDivider()),
            _pad(_learnNext()),
          ],
        ),
      ),
    );
  }

  // ---- mock video surface -------------------------------------------------
  Widget _videoSurface() => AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                  const Color(0xFF3A2A55),
                  ppPurple.withValues(alpha: 0.85),
                ]),
              ),
            ),
          ),
          // top bar
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(children: [
              _round(Icons.arrow_back, () => Navigator.of(context).maybePop()),
              const Spacer(),
              _round(Icons.picture_in_picture_alt_outlined, () => _soon('Picture-in-picture coming soon')),
              const SizedBox(width: 8),
              _round(Icons.fullscreen_rounded, () => _soon('Full screen coming soon')),
            ]),
          ),
          // centre play/pause
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _playing = !_playing),
              child: Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: ppPurple, size: 34),
              ),
            ),
          ),
          // bottom control bar
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Row(children: [
              Text(_fmt((WatchStore.instance.progressOf(v.id) * v.seconds).round()),
                  style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(999)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: WatchStore.instance.progressOf(v.id).clamp(0.02, 1.0),
                    child: Container(decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(999))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(_fmt(v.seconds), style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
              const SizedBox(width: 10),
              GestureDetector(onTap: () => _soon('Captions coming soon'), child: const Icon(Icons.closed_caption_off_rounded, size: 18, color: Colors.white)),
              const SizedBox(width: 10),
              GestureDetector(
                  onTap: () => _soon('Playback speed coming soon'),
                  child: Text('1x', style: ppBody(12, color: Colors.white, w: FontWeight.w700))),
            ]),
          ),
        ]),
      );

  Widget _round(IconData i, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28), shape: BoxShape.circle),
          child: Icon(i, size: 18, color: Colors.white),
        ),
      );

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  // ---- actions (learning-only) --------------------------------------------
  Widget _actions() => AnimatedBuilder(
        animation: WatchStore.instance,
        builder: (context, _) {
          final saved = WatchStore.instance.isSaved(v.id);
          return Row(children: [
            _action(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, saved ? 'Saved' : 'Save',
                () => WatchStore.instance.toggleSave(v.id),
                on: saved),
            _action(Icons.ios_share_rounded, 'Share', () => _soon('Sharing coming soon')),
            _action(Icons.auto_awesome_outlined, 'Ask Veda', () => openPpTab(context, 1)),
            _action(Icons.more_horiz_rounded, 'More', _openMore),
          ]);
        },
      );

  Widget _action(IconData i, String label, VoidCallback onTap, {bool on = false}) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: on ? ppPurple.withValues(alpha: 0.12) : ppPanel, borderRadius: BorderRadius.circular(14)),
              child: Icon(i, size: 21, color: ppPurple),
            ),
            const SizedBox(height: 7),
            Text(label, style: ppBody(11, color: ppSoft, w: FontWeight.w600)),
          ]),
        ),
      );

  void _openMore() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 12),
            _moreRow(ctx, Icons.download_outlined, 'Download for offline'),
            _moreRow(ctx, Icons.watch_later_outlined, 'Watch later'),
            _moreRow(ctx, Icons.speed_rounded, 'Playback speed'),
            _moreRow(ctx, Icons.not_interested_rounded, 'Not relevant for us'),
          ]),
        ),
      ),
    );
  }

  Widget _moreRow(BuildContext ctx, IconData i, String label) => GestureDetector(
        onTap: () {
          Navigator.of(ctx).pop();
          _soon('$label — coming soon');
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(children: [
            Icon(i, size: 20, color: ppPurple),
            const SizedBox(width: 14),
            Text(label, style: ppBody(14.5, color: ppInk, w: FontWeight.w600)),
          ]),
        ),
      );

  // ---- expert -------------------------------------------------------------
  Widget _expertRow() => AnimatedBuilder(
        animation: WatchStore.instance,
        builder: (context, _) {
          final e = v.expert;
          final following = WatchStore.instance.isFollowing(e.id);
          return Row(children: [
            GestureDetector(
              onTap: () => _push(ProviderProfileScreen(expert: e)),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                clipBehavior: Clip.antiAlias,
                child: const PpStriped(height: 50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _push(ProviderProfileScreen(expert: e)),
                behavior: HitTestBehavior.opaque,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.name, style: ppJakarta(14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(e.credential, style: ppBody(12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => WatchStore.instance.toggleFollow(e.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: following ? Colors.transparent : ppPurple,
                  borderRadius: BorderRadius.circular(999),
                  border: following ? Border.all(color: ppBorder) : null,
                ),
                child: Text(following ? 'Following' : 'Follow',
                    style: ppBody(12.5, color: following ? ppSoft : Colors.white, w: FontWeight.w700)),
              ),
            ),
          ]);
        },
      );

  // ---- Learn next (videos only — keep the learning thread going) -----------
  void _openVideo(WatchVideo nv) {
    if (nv.quick) {
      _push(QuickLearnScreen(startId: nv.id));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => WatchPlayerScreen(video: nv)));
    }
  }

  Widget _learnNext() {
    final next = learnNextVideos(v);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ppEyebrow('Learn next', color: ppPurple, spacing: 1.0),
      const SizedBox(height: 6),
      Text('Keep the thread going — more short lessons on this, one after another.', style: ppBody(13, color: ppSoft)),
      const SizedBox(height: 16),
      for (int i = 0; i < next.length; i++)
        _step(Icons.play_circle_outline, next[i].category, next[i].title, () => _openVideo(next[i]), last: i == next.length - 1),
    ]);
  }

  Widget _step(IconData icon, String type, String title, VoidCallback? onTap, {bool last = false}) {
    final future = onTap == null;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 34,
          child: Column(children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: future ? ppPanel : ppPurple.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, size: 17, color: future ? ppMuted : ppPurple),
            ),
            if (!last) Expanded(child: Container(width: 2, color: ppHair)),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(type.toUpperCase(), style: ppBody(9.5, color: future ? ppMuted : ppPurple, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                      if (future) ...[
                        const SizedBox(width: 6),
                        Text('SOON', style: ppBody(8.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.5)),
                      ],
                    ]),
                    const SizedBox(height: 3),
                    Text(title, style: ppBody(14, color: future ? ppMuted : ppInk, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                ),
                if (!future) const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

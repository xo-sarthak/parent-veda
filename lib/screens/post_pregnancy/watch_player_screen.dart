// =============================================================================
//  WatchPlayerScreen - Deep Learn video player (the signature experience)
// -----------------------------------------------------------------------------
//  A premium, calm player. Learning-only actions (Save · Share · Ask Veda ·
//  More) - never likes/comments/followers. Below the video, instead of a comment
//  feed, a curated "Learn next" CHAIN that walks the parent onward through the
//  ParentVeda ecosystem (Activity → Article → Product → Recipe → Community → Ask
//  Veda → Quiz), plus the expert (Follow, not Subscribe). No autoplay-to-nowhere.
//  Mock playback surface (no real video engine yet); progress is remembered.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_watch_data.dart';
import 'provider_profile_screen.dart';
import 'video/pv_video_player.dart';
import 'watch_common.dart';
import 'watch_quicklearn_screen.dart';

class WatchPlayerScreen extends StatefulWidget {
  const WatchPlayerScreen({super.key, required this.video});
  final WatchVideo video;

  @override
  State<WatchPlayerScreen> createState() => _WatchPlayerScreenState();
}

class _WatchPlayerScreenState extends State<WatchPlayerScreen> {
  // Preserves the single video player when we swap the whole layout for
  // fullscreen, so playback never restarts.
  final GlobalKey _playerKey = GlobalKey();
  bool _fullscreen = false;

  WatchVideo get v => widget.video;

  @override
  void initState() {
    super.initState();
    // Register the video as being watched (continue-watching + recent), without
    // clobbering real progress if the parent resumed partway. Deferred to after
    // the first frame: setProgress() notifies WatchStore, and doing that during
    // initState/build would rebuild the store's listeners mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final store = WatchStore.instance;
      if (store.progressOf(v.id) < 0.02) store.setProgress(v.id, 0.06);
    });
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));
  void _soon(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  Widget _player() {
    return PvVideoPlayer(
      key: _playerKey,
      video: v,
      onFullscreenChanged: (fs) => setState(() => _fullscreen = fs),
      onNext: _openNextLesson,
    );
  }

  void _openNextLesson() {
    final next = learnNextVideos(v);
    if (next.isNotEmpty) _openVideo(next.first);
  }

  @override
  Widget build(BuildContext context) {
    // Fullscreen: give the same player the entire screen (GlobalKey preserves it).
    if (_fullscreen) {
      return Scaffold(backgroundColor: Colors.black, body: _player());
    }
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            _player(),
            const SizedBox(height: 16),
            _pad(_actions()),
            const SizedBox(height: 18),
            _pad(Text(v.title, style: ppFraunces(23, h: 1.2))),
            const SizedBox(height: 8),
            _pad(watchMeta(v, color: ppSoft)),
            const SizedBox(height: 16),
            _pad(_expertRow()),
            const SizedBox(height: 18),
            _pad(Text(ppFill(v.why), style: ppBody(14.5, color: ppInk, h: 1.6))),
            const SizedBox(height: 8),
            _pad(ppSectionDivider()),
            _pad(_learnNext()),
          ],
        ),
      ),
    );
  }

  // ---- actions (learning-only) --------------------------------------------
  Widget _actions() => AnimatedBuilder(
        animation: WatchStore.instance,
        builder: (context, _) {
          final saved = WatchStore.instance.isSaved(v.id);
          return Row(children: [
            _action(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, saved ? 'Saved' : 'Save',
                () => WatchStore.instance.toggleSave(v.id),
                on: saved),
            _action(Icons.playlist_add_rounded, 'Add', _openAddToCollection),
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
          _soon('$label - coming soon');
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

  // ---- add to collection --------------------------------------------------
  // A calm bottom sheet: tick a collection to add/remove this video, or open a
  // small field to name a new one (which is created with this video already in).
  // AnimatedBuilder keeps the ticks live; StatefulBuilder toggles the name field.
  void _openAddToCollection() {
    final nameCtrl = TextEditingController();
    var creating = false;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
              child: AnimatedBuilder(
                animation: WatchStore.instance,
                builder: (context, _) {
                  final store = WatchStore.instance;
                  return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
                    const SizedBox(height: 16),
                    Text('Add to collection', style: ppJakarta(18)),
                    const SizedBox(height: 4),
                    Text(v.title, style: ppBody(12.5, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    for (final c in store.userCollections) _collectionToggleRow(c),
                    const SizedBox(height: 4),
                    if (creating)
                      _createField(nameCtrl, () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        final made = store.createCollection(name);
                        store.addToCollection(made.id, v.id);
                        nameCtrl.clear();
                        setSheet(() => creating = false);
                      })
                    else
                      _createRow(() => setSheet(() => creating = true)),
                  ]);
                },
              ),
            ),
          ),
        ),
      ),
    ).whenComplete(nameCtrl.dispose);
  }

  Widget _collectionToggleRow(UserWatchCollection c) {
    final inIt = WatchStore.instance.collectionContains(c.id, v.id);
    final count = c.videoIds.length;
    return GestureDetector(
      onTap: () => inIt
          ? WatchStore.instance.removeFromCollection(c.id, v.id)
          : WatchStore.instance.addToCollection(c.id, v.id),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.video_library_outlined, size: 19, color: ppPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: ppBody(14.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(count == 1 ? '1 video' : '$count videos', style: ppBody(12, color: ppMuted)),
            ]),
          ),
          const SizedBox(width: 10),
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: inIt ? ppPurple : Colors.transparent,
              shape: BoxShape.circle,
              border: inIt ? null : Border.all(color: ppBorder, width: 1.5),
            ),
            child: inIt ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }

  Widget _createRow(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppBorder)),
              child: const Icon(Icons.add_rounded, size: 20, color: ppPurple),
            ),
            const SizedBox(width: 14),
            Text('Create new collection', style: ppBody(14.5, color: ppPurple, w: FontWeight.w700)),
          ]),
        ),
      );

  Widget _createField(TextEditingController c, VoidCallback onCreate) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: c,
                autofocus: true,
                style: ppBody(14, color: ppInk),
                cursorColor: ppPurple,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onCreate(),
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  hintText: 'Name your collection',
                  hintStyle: ppBody(14, color: ppMuted),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onCreate,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(12)),
              child: Text('Create', style: ppBody(13.5, color: Colors.white, w: FontWeight.w700)),
            ),
          ),
        ]),
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

  // ---- Learn next (videos only - keep the learning thread going) -----------
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
      Text('Keep the thread going - more short lessons on this, one after another.', style: ppBody(13, color: ppSoft)),
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

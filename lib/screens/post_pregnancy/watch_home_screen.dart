// =============================================================================
//  WatchHomeScreen - ParentVeda Watch home (YouTube-style, learning-first)
// -----------------------------------------------------------------------------
//  The daily habit, now with a YouTube-shaped surface: search + a horizontal row
//  of topic FILTERS at the top (plus a Shorts entry), one carefully-chosen
//  Today's Video, Continue Watching, Expert Collections, and then an INFINITE
//  learning feed that loops the catalog with "channel to explore" interstitials
//  woven in (videos only). A Quick / Deep toggle switches hero + feed between
//  30–90s clips and 5–30 min sessions over the same catalog, progress and saves.
//  Still learning-first throughout (topic · age · expert · duration, never
//  likes/views). Reached from the Explore drawer. Pushed screen (back, no nav).
// =============================================================================

import 'package:flutter/material.dart';
import 'pp_child_profile.dart';

import 'pp_channels_data.dart';
import 'pp_common.dart';
import 'pp_section_extras.dart';
import 'pp_experts_data.dart';
import 'pp_watch_data.dart';
import 'watch_channel_screen.dart';
import 'watch_collection_screen.dart';
import 'watch_common.dart';
import 'watch_library_screen.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';
import 'watch_shorts_screen.dart';

class WatchHomeScreen extends StatefulWidget {
  const WatchHomeScreen({super.key});

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {
  bool _quick = false; // false = Deep Learn, true = Quick Learn
  String _topic = 'All'; // active topic filter (a category name, or 'All')

  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';

  // Feed cadence: this many video cards, then one "channel to explore" card.
  static const int _feedGroup = 4;

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  void _open(WatchVideo v) => v.quick ? _push(QuickLearnScreen(startId: v.id)) : _push(WatchPlayerScreen(video: v));

  double? _liveProgress(String id) {
    final p = WatchStore.instance.progressOf(id);
    return p > 0.02 && p < 0.98 ? p : null;
  }

  // ---- the feed's base list (respecting mode + topic filter) ---------------
  List<WatchVideo> _picksBase() {
    final mode = _quick ? quickVideos : deepVideos;
    if (_topic == 'All') return mode;
    final filtered = mode.where((v) => v.category == _topic).toList();
    if (filtered.isNotEmpty) return filtered;
    final anyMode = kWatchVideos.where((v) => v.category == _topic && !v.isPodcast).toList();
    return anyMode.isNotEmpty ? anyMode : mode;
  }

  String _picksTitle() => _topic != 'All' ? _topic : (_quick ? 'Quick lessons for you' : 'Chosen for you');
  String _picksSubtitle() => _topic != 'All'
      ? 'Expert ${_quick ? 'shorts' : 'videos'} on ${_topic.toLowerCase()} - keep scrolling for more.'
      : 'Picked for his age and where he is right now - the feed keeps going.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: WatchStore.instance,
            builder: (context, _) {
              final store = WatchStore.instance;
              if (_query.trim().isNotEmpty) return _searchListView(store);
              return _feedListView(store);
            },
          ),
        ),
      ]),
    );
  }

  // ---- infinite feed ------------------------------------------------------
  Widget _feedListView(WatchStore store) {
    final header = _header(store);
    final base = _picksBase();
    final channels = allWatchChannels();
    final interstitialsOn = !_quick && channels.isNotEmpty;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 48),
      // No itemCount = an endless, lazily-built feed (YouTube-style). It loops the
      // catalog; ListView.builder only builds what's on screen, so it's cheap and
      // never spins an animation.
      itemBuilder: (context, index) {
        if (index < header.length) return header[index];
        final j = index - header.length;

        // QUICK LEARN reads as shorts, so it looks like shorts: two per row,
        // portrait thumbnails, the description underneath. A 30-second clip in
        // a full-width landscape row was claiming the space of a lesson.
        if (_quick) {
          final a = base[(j * 2) % base.length];
          final b = base[(j * 2 + 1) % base.length];
          return _pad(Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _shortCard(a)),
              const SizedBox(width: 12),
              Expanded(child: _shortCard(b)),
            ]),
          ));
        }

        if (interstitialsOn) {
          const period = _feedGroup + 1; // group of videos + 1 channel card
          if (j % period == period - 1) {
            final k = (j ~/ period) % channels.length;
            return _pad(_channelInterstitial(channels[k]));
          }
          final videoIndex = (j ~/ period) * _feedGroup + (j % period);
          return _pad(_feedCard(base[videoIndex % base.length]));
        }
        return _pad(_feedCard(base[j % base.length]));
      },
    );
  }

  /// One short in the 2-up grid: a tall thumbnail, title, then who it is from.
  Widget _shortCard(WatchVideo v) => GestureDetector(
        onTap: () => _open(v),
        behavior: HitTestBehavior.opaque,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 9 / 14,
            child: WatchThumb(seed: v.seed, height: 999, showPlay: true, progress: _liveProgress(v.id)),
          ),
          const SizedBox(height: 8),
          Text(v.title, style: ppJakarta(13).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('${v.expert.name} · ${v.seconds}s',
              style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  Widget _feedCard(WatchVideo v) => WatchListCard(video: v, onTap: () => _open(v), progress: _liveProgress(v.id));

  List<Widget> _header(WatchStore store) {
    final continues = store.continueWatching;
    final h = <Widget>[
      _pad(ppBack(context, 'Explore')),
      const SizedBox(height: 16),
      _pad(ppEyebrow('ParentVeda Watch', color: ppPurple)),
      const SizedBox(height: 8),
      _pad(Text('Learn something today', style: ppFraunces(30, h: 1.1))),
      const SizedBox(height: 6),
      _pad(Text('Five minutes here should make you a better parent today - not just pass the time.',
          style: ppBody(14, h: 1.5))),
      const SizedBox(height: 16),
      _pad(ppSearchField(
        controller: _searchCtl,
        hint: 'Search videos…',
        onChanged: (v) => setState(() => _query = v),
      )),
      const SizedBox(height: 14),
      _topicFilterRow(),
      const SizedBox(height: 18),
      _pad(_modeToggle()),
    ];

    // A TOPIC IS SELECTED: the page becomes that topic. Previously picking
    // "Nutrition" left the hero, Continue watching and Expert collections
    // exactly as they were and only changed a list far below the fold - so
    // from the user's seat, tapping a filter did nothing. Now the generic
    // browse sections stand down and the filtered results lead. Clearing the
    // filter brings everything straight back; nothing is lost, only deferred.
    if (_topic != 'All') {
      h.addAll([
        const SizedBox(height: 22),
        _pad(Row(children: [
          Expanded(child: watchSectionHeader(_picksTitle())),
          GestureDetector(
            onTap: () => setState(() => _topic = 'All'),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              Text('Clear', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
              const SizedBox(width: 3),
              const Icon(Icons.close_rounded, size: 15, color: ppPurple),
            ]),
          ),
        ])),
        const SizedBox(height: 4),
        _pad(Text(_picksSubtitle(), style: ppBody(12.5, color: ppMuted))),
        const SizedBox(height: 16),
      ]);
      return h;
    }

    h.addAll([
      const SizedBox(height: 26),
      _pad(watchSectionHeader('Today for ${ChildProfileStore.instance.name}')),
      const SizedBox(height: 14),
      _pad(_todaysHero()),
    ]);

    if (continues.isNotEmpty) {
      h.addAll([
        const SizedBox(height: 30),
        _pad(watchSectionHeader('Continue watching')),
        const SizedBox(height: 14),
        _rail(continues, (v) => store.progressOf(v.id)),
      ]);
    }

    h.addAll([
      const SizedBox(height: 30),
      _pad(watchSectionHeader('Expert collections')),
      const SizedBox(height: 4),
      _pad(Text('Short, finishable learning paths - not endless playlists.', style: ppBody(12.5, color: ppMuted))),
      const SizedBox(height: 16),
      _collectionsRail(),
      const SizedBox(height: 28),
      _pad(_libraryLink()),
      const SizedBox(height: 30),
      _pad(watchSectionHeader(_picksTitle())),
      const SizedBox(height: 4),
      _pad(Text(_picksSubtitle(), style: ppBody(12.5, color: ppMuted))),
      const SizedBox(height: 16),
    ]);
    return h;
  }

  // ---- search results (title/topic contains query) ------------------------
  Widget _searchListView(WatchStore store) {
    final q = _query.trim().toLowerCase();
    final items = kWatchAll
        .where((v) => v.title.toLowerCase().contains(q) || v.topic.toLowerCase().contains(q))
        .toList();
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 40),
      children: [
        _pad(ppBack(context, 'Explore')),
        const SizedBox(height: 16),
        _pad(ppEyebrow('ParentVeda Watch', color: ppPurple)),
        const SizedBox(height: 8),
        _pad(Text('Learn something today', style: ppFraunces(30, h: 1.1))),
        const SizedBox(height: 16),
        _pad(ppSearchField(
          controller: _searchCtl,
          hint: 'Search videos…',
          onChanged: (v) => setState(() => _query = v),
        )),
        const SizedBox(height: 24),
        _pad(watchSectionHeader('Search results')),
        const SizedBox(height: 14),
        if (items.isEmpty)
          _pad(Text('No matches for "$_query" - try another word.', style: ppBody(13, color: ppMuted)))
        else
          _pad(Column(children: [
            for (final v in items) _feedCard(v),
          ])),
      ],
    );
  }

  // ---- top topic filters (YouTube-style chips) ----------------------------
  Widget _topicFilterRow() {
    final items = <Widget>[
      _filterChip('All', null, selected: _topic == 'All', onTap: () => setState(() => _topic = 'All')),
      _filterChip('Shorts', Icons.bolt_rounded, selected: false, accent: true, onTap: () => _push(const WatchShortsScreen())),
      for (final c in kWatchCategories)
        _filterChip(c.$1, c.$2, selected: _topic == c.$1, onTap: () => setState(() => _topic = c.$1)),
    ];
    // A single horizontal strip meant scrolling sideways through a dozen
    // categories to find one - and whatever sat past the fold was effectively
    // invisible. Wrapping to two or three short lines shows the whole set at
    // once, which is the only way to scan it.
    return _pad(Wrap(spacing: 9, runSpacing: 9, children: items));
  }

  Widget _filterChip(String label, IconData? icon, {required bool selected, required VoidCallback onTap, bool accent = false}) {
    final Color bg = selected ? ppPurple : Colors.white;
    final Color fg = selected ? Colors.white : (accent ? ppPurple : ppInk);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? ppPurple : (accent ? ppPurple.withValues(alpha: 0.4) : ppHair)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label, style: ppBody(12.5, color: fg, w: FontWeight.w700)),
        ]),
      ),
    );
  }

  // ---- channel interstitial (promotes a channel + Subscribe) --------------
  Widget _channelInterstitial(WatchChannel channel) {
    final e = channel.expert;
    final subscribed = WatchStore.instance.isSubscribed(e.id);
    return GestureDetector(
      onTap: () => _push(WatchChannelScreen(expertId: e.id)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.subscriptions_outlined, size: 15, color: ppPurple),
            const SizedBox(width: 7),
            Flexible(child: ppEyebrow('Channel to explore', color: ppPurple, spacing: 1.0)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
              clipBehavior: Clip.antiAlias,
              child: const PpStriped(height: 52, colorA: ppBorder, colorB: ppStripeB),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.name, style: ppJakarta(14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(channel.statsLine, style: ppBody(12, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => WatchStore.instance.toggleSubscribe(e.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                decoration: BoxDecoration(
                  color: subscribed ? Colors.transparent : ppPurple,
                  borderRadius: BorderRadius.circular(999),
                  border: subscribed ? Border.all(color: ppBorder) : null,
                ),
                child: Text(subscribed ? 'Subscribed' : 'Subscribe',
                    style: ppBody(12, color: subscribed ? ppSoft : Colors.white, w: FontWeight.w800)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ---- mode toggle --------------------------------------------------------
  Widget _modeToggle() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          // Quick sits LEFT, Deep RIGHT: shortest-first reads as the natural
          // order, and it was the wrong way round.
          _seg('Quick Learn', '30–90 sec', _quick, () => setState(() => _quick = true)),
          _seg('Deep Learn', '5–30 min', !_quick, () => setState(() => _quick = false)),
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
              Text(sub, style: ppBody(10, color: ppMuted)),
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
              Text(ppFill(v.why), style: ppBody(13.5, h: 1.55)),
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

  /// The doctor behind a collection, in enough depth to decide whether to
  /// trust them. Credentials are only worth showing if you can check them.
  void _openExpert(Expert e) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: ppBg,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Text(e.name, style: ppFraunces(24, h: 1.15)),
              const SizedBox(height: 5),
              Text(e.credential, style: ppBody(13.5, color: ppPurple, w: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(e.backLabel, style: ppBody(12.5, color: ppMuted)),
              const SizedBox(height: 14),
              Row(children: [
                const Icon(Icons.star_rounded, size: 15, color: Color(0xFFC98A2B)),
                const SizedBox(width: 4),
                Text(e.rating.toString(), style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                const SizedBox(width: 6),
                Flexible(child: Text('from ${e.reviewsCount} parents', style: ppBody(12.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 16),
              Text(e.whyHeading, style: ppJakarta(15)),
              const SizedBox(height: 7),
              Text(ppFill(e.why), style: ppBody(13.5, color: ppInk, h: 1.6)),
              if (e.reviews.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text('What parents say', style: ppJakarta(15)),
                const SizedBox(height: 9),
                for (final r in e.reviews.take(2))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.$3, style: ppBody(12.5, color: ppInk, h: 1.5)),
                        const SizedBox(height: 6),
                        Text('${r.$1} · ${r.$2}', style: ppBody(11.5, color: ppMuted)),
                      ]),
                    ),
                  ),
              ],
            ]),
          ),
        ),
      );

  Widget _collectionsRail() {
    final cols = expertCollections();
    return SizedBox(
      height: 268,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: cols.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final c = cols[i];
          final mins = c.videoIds.map(watchVideoById).fold<int>(0, (a, v) => a + v.seconds) ~/ 60;
          final prog = WatchStore.instance.collectionProgress(c);
          // The expert behind the collection = whoever teaches its first video.
          final lead = c.videoIds.isEmpty ? null : watchVideoById(c.videoIds.first).expert;
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
                const SizedBox(height: 5),
                // Who it is from, and what other parents made of it. A learning
                // path is worth trusting on the strength of the person teaching
                // it - the "i" opens their background rather than making you
                // take "paediatrician" on faith.
                if (lead != null)
                  GestureDetector(
                    onTap: () => _openExpert(lead),
                    behavior: HitTestBehavior.opaque,
                    child: Row(children: [
                      Flexible(
                        child: Text(lead.name,
                            style: ppBody(11.5, color: ppInk, w: FontWeight.w700),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.info_outline_rounded, size: 12, color: ppPurple),
                    ]),
                  ),
                const SizedBox(height: 3),
                if (lead != null)
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 12, color: Color(0xFFC98A2B)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text('${lead.rating} · ${lead.reviewsCount} parents',
                          style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                const SizedBox(height: 3),
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

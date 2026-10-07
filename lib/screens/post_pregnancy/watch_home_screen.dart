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

import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_chrome.dart' show PregSectionHeading, pregGroupLabelStyle, pregPageTitleStyle;
import '../pregnancy/preg_tool_chrome.dart' show pregToolPad;
import '../products/pv_store_chrome.dart' show PvChip, PvCommit, kPvInk, kPvLine, kPvStar, pvStorePalette;
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_phases_data.dart' show ppFillChild;

import 'pp_channels_data.dart';
import 'pp_common.dart';
import 'pp_expert_link.dart';
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

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  Pregnancy's Watch library (WatchLearnScreen) is the model: white ground,
  //  an app bar carrying only the back arrow, the serif page title, ONE
  //  section heading (PregSectionHeading), white cards on the hairline with
  //  the thumbnail on top, ink chips, an ink "Watch now". Same catalogue,
  //  filters, modes, endless feed and destinations.
  //
  //  The search results and the feed are ONE lazy list whose first rows (title,
  //  intro, search) are the same in both, so typing the first letter no longer
  //  swaps the list out from under the field (it was two ListViews, and the
  //  field lost focus when the page switched between them).
  //  `_buildBeforeShell` is the page before, kept for revert.
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink1,
      ),
      body: AnimatedBuilder(
        animation: WatchStore.instance,
        builder: (context, _) {
          final store = WatchStore.instance;
          final top = <Widget>[
            pregToolPad(Semantics(header: true, child: Text('Learn something today', style: pregPageTitleStyle()))),
            const SizedBox(height: 8),
            pregToolPad(Text('Five minutes here should make you a better parent today - not just pass the time.',
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2))),
            const SizedBox(height: 16),
            pregToolPad(_searchShell(p)),
          ];
          if (_query.trim().isNotEmpty) {
            final rows = [...top, ..._searchShellRows(p)];
            return ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: kAskFabReserve),
              itemCount: rows.length,
              itemBuilder: (_, i) => rows[i],
            );
          }
          final header = [...top, ..._headerShell(p, store)];
          return _feedShell(header);
        },
      ),
    );
  }

  Widget _searchShell(V2Palette p) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line),
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 19, color: p.ink2),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtl,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              style: pvManrope(fontSize: 15, color: p.ink1),
              cursorColor: p.ink1,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search videos',
                hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchCtl.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear the search',
              onPressed: () => setState(() {
                _searchCtl.clear();
                _query = '';
              }),
              icon: Icon(Icons.close_rounded, size: 18, color: p.ink2),
              visualDensity: VisualDensity.compact,
            )
          else
            const SizedBox(width: 14),
        ]),
      );

  List<Widget> _searchShellRows(V2Palette p) {
    final q = _query.trim().toLowerCase();
    final items = kWatchAll
        .where((v) => v.title.toLowerCase().contains(q) || v.topic.toLowerCase().contains(q))
        .toList();
    return [
      const SizedBox(height: 26),
      pregToolPad(const PregSectionHeading('Search results')),
      const SizedBox(height: 12),
      if (items.isEmpty)
        pregToolPad(Text('No matches for "$_query" - try another word.', style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
      else
        for (final v in items) pregToolPad(_feedCard(v)),
    ];
  }

  // The endless feed, as before: lazily built, looping the catalogue, with a
  // channel to explore after every few videos in Deep Learn.
  Widget _feedShell(List<Widget> header) {
    final p = pvStorePalette;
    final base = _picksBase();
    final channels = allWatchChannels();
    final interstitialsOn = !_quick && channels.isNotEmpty;
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: kAskFabReserve),
      itemBuilder: (context, index) {
        if (index < header.length) return header[index];
        final j = index - header.length;
        if (_quick) {
          final a = base[(j * 2) % base.length];
          final b = base[(j * 2 + 1) % base.length];
          return pregToolPad(Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _shortCardShell(p, a)),
              const SizedBox(width: 12),
              Expanded(child: _shortCardShell(p, b)),
            ]),
          ));
        }
        if (interstitialsOn) {
          const period = _feedGroup + 1;
          if (j % period == period - 1) {
            final k = (j ~/ period) % channels.length;
            return pregToolPad(_channelShell(p, channels[k]));
          }
          final videoIndex = (j ~/ period) * _feedGroup + (j % period);
          return pregToolPad(_feedCard(base[videoIndex % base.length]));
        }
        return pregToolPad(_feedCard(base[j % base.length]));
      },
    );
  }

  Widget _shortCardShell(V2Palette p, WatchVideo v) => InkWell(
        onTap: () => _open(v),
        borderRadius: BorderRadius.circular(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 9 / 14,
            child: WatchThumb(seed: v.seed, height: 999, showPlay: true, progress: _liveProgress(v.id)),
          ),
          const SizedBox(height: 8),
          Text(v.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
          const SizedBox(height: 4),
          PpExpertName(v.expert, suffix: ' · ${v.seconds}s',
              style: pvManrope(fontSize: 11, color: p.ink3), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  List<Widget> _headerShell(V2Palette p, WatchStore store) {
    final continues = store.continueWatching;
    final h = <Widget>[
      const SizedBox(height: 14),
      // Wrapped, not a sideways strip: the whole set is scannable at once.
      pregToolPad(Wrap(spacing: 6, runSpacing: 8, children: [
        PvChip(label: 'All', selected: _topic == 'All', onTap: () => setState(() => _topic = 'All')),
        PvChip(
          key: const ValueKey('pp_watch_shorts'),
          label: 'Shorts',
          leading: Icons.bolt_rounded,
          selected: false,
          onTap: () => _push(const WatchShortsScreen()),
        ),
        for (final c in kWatchCategories)
          PvChip(label: c.$1, leading: c.$2, selected: _topic == c.$1, onTap: () => setState(() => _topic = c.$1)),
      ])),
      const SizedBox(height: 18),
      pregToolPad(_modeShell(p)),
    ];

    // A topic is selected: the page becomes that topic (see the page before).
    if (_topic != 'All') {
      h.addAll([
        const SizedBox(height: 24),
        pregToolPad(PregSectionHeading(_picksTitle(), lead: ppFillChild(_picksSubtitle()), link: 'Clear', onLink: () => setState(() => _topic = 'All'))),
        const SizedBox(height: 14),
      ]);
      return h;
    }

    h.addAll([
      const SizedBox(height: 26),
      pregToolPad(PregSectionHeading('Today for ${ChildProfileStore.instance.nameMid}')),
      const SizedBox(height: 12),
      pregToolPad(_heroShell(p)),
    ]);

    if (continues.isNotEmpty) {
      h.addAll([
        const SizedBox(height: 26),
        pregToolPad(const PregSectionHeading('Continue watching')),
        const SizedBox(height: 12),
        _railShell(p, continues),
      ]);
    }

    h.addAll([
      const SizedBox(height: 26),
      pregToolPad(const PregSectionHeading('Expert collections', lead: 'Short, finishable learning paths - not endless playlists.')),
      const SizedBox(height: 12),
      _collectionsShell(p),
      const SizedBox(height: 26),
      pregToolPad(PvRowGroup(p: p, children: [
        PvListRow(
          key: const ValueKey('pp_watch_library'),
          p: p,
          leading: PvMarkWell(p: p, hue: 206, size: 40, icon: Icons.bookmark_outline_rounded),
          title: 'Your library',
          line: 'Saved, continue watching & collections',
          onTap: () => _push(const WatchLibraryScreen()),
        ),
      ])),
      const SizedBox(height: 28),
      pregToolPad(PregSectionHeading(_picksTitle(), lead: ppFillChild(_picksSubtitle()))),
      const SizedBox(height: 14),
    ]);
    return h;
  }

  /// Quick | Deep: a hairline track with the chosen side in ink.
  Widget _modeShell(V2Palette p) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line),
        ),
        child: Row(children: [
          _segShell(p, 'Quick Learn', '30–90 sec', _quick, () => setState(() => _quick = true)),
          _segShell(p, 'Deep Learn', '5–30 min', !_quick, () => setState(() => _quick = false)),
        ]),
      );

  Widget _segShell(V2Palette p, String label, String sub, bool on, VoidCallback onTap) => Expanded(
        child: Semantics(
          button: true,
          selected: on,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                color: on ? kPvInk : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Column(children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: on ? Colors.white : p.ink1)),
                const SizedBox(height: 1),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 10.5, color: on ? Colors.white70 : p.ink3)),
              ]),
            ),
          ),
        ),
      );

  Widget _heroShell(V2Palette p) {
    final v = todaysVideo(quick: _quick);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: p.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const ValueKey('pp_watch_today'),
        onTap: () => _open(v),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          WatchThumb(seed: v.seed, height: 188, radius: 0, duration: v.durationLabel, quick: v.quick),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('WHY THIS MATTERS TODAY', style: pregGroupLabelStyle()),
              const SizedBox(height: 10),
              Text(v.title, style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
              const SizedBox(height: 8),
              Text(ppFill(v.why), style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
              const SizedBox(height: 12),
              watchMeta(v, color: p.ink3),
              const SizedBox(height: 16),
              PvCommit(label: 'Watch now', icon: Icons.play_arrow_rounded, onTap: () => _open(v)),
            ]),
          ),
        ]),
      ),
    );
  }

  /// A rail of pregnancy's Watch card: white, the hairline, the thumbnail on top.
  Widget _railShell(V2Palette p, List<WatchVideo> vids) {
    final s = MediaQuery.textScalerOf(context);
    final height = (116 + 10 + s.scale(13.5) * 1.6 * 2 + 3 + s.scale(11.5) * 1.6 + 12 + 10).ceilToDouble();
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: vids.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final v = vids[i];
          return _cardShell(
            p,
            onTap: () => _open(v),
            thumb: WatchThumb(seed: v.seed, height: 116, radius: 0, duration: v.durationLabel, progress: WatchStore.instance.progressOf(v.id), quick: v.quick),
            lines: [
              Text(v.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.3, color: p.ink1)),
              const SizedBox(height: 3),
              watchMeta(v, color: p.ink3),
            ],
          );
        },
      ),
    );
  }

  Widget _cardShell(V2Palette p, {required VoidCallback onTap, required Widget thumb, required List<Widget> lines}) => SizedBox(
        width: 220,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: kPvLine)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              thumb,
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: lines),
              ),
            ]),
          ),
        ),
      );

  Widget _collectionsShell(V2Palette p) {
    final cols = expertCollections();
    final s = MediaQuery.textScalerOf(context);
    final height = (116 + 10 + s.scale(14) * 1.6 + 4 + s.scale(11.5) * 1.6 + 5 + 30 + 3 + s.scale(11) * 1.6 + 3 + s.scale(11) * 1.6 + 12 + 14)
        .ceilToDouble();
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: cols.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = cols[i];
          final mins = c.videoIds.map(watchVideoById).fold<int>(0, (a, v) => a + v.seconds) ~/ 60;
          final prog = WatchStore.instance.collectionProgress(c);
          // The expert behind the collection = whoever teaches its first video.
          final lead = c.videoIds.isEmpty ? null : watchVideoById(c.videoIds.first).expert;
          return _cardShell(
            p,
            onTap: () => _push(WatchCollectionScreen(collection: c)),
            thumb: WatchThumb(seed: c.seed, height: 116, radius: 0, showPlay: false, progress: prog > 0 ? prog : null),
            lines: [
              Text(c.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3, color: p.ink1)),
              const SizedBox(height: 4),
              Text('${c.videoIds.length} videos · ~$mins min', style: pvManrope(fontSize: 11.5, color: p.ink3)),
              const SizedBox(height: 5),
              // Who it is from: the "i" opens their background, so a credential
              // is something she can check, not take on faith.
              if (lead != null)
                Semantics(
                  button: true,
                  label: 'About ${lead.name}',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => _openExpert(lead),
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 30,
                      child: Row(children: [
                        Flexible(
                          child: Text(c.title == lead.name ? lead.credential : lead.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink1)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.info_outline_rounded, size: 14, color: kPvInk),
                      ]),
                    ),
                  ),
                )
              else
                const SizedBox(height: 30),
              const SizedBox(height: 3),
              Row(children: [
                if (lead != null) ...[
                  const Icon(Icons.star_rounded, size: 12, color: kPvStar),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text('${lead.rating} · ${lead.reviewsCount}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: pvManrope(fontSize: 11, color: p.ink3)),
                  ),
                ],
              ]),
              const SizedBox(height: 3),
              Text(prog >= 1 ? 'Completed' : prog > 0 ? '${(prog * 100).round()}% done' : 'Not started',
                  style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, color: prog > 0 ? p.ink1 : p.ink3)),
            ],
          );
        },
      ),
    );
  }

  /// A channel to explore, between videos: white, the hairline, Subscribe in ink.
  Widget _channelShell(V2Palette p, WatchChannel channel) {
    final e = channel.expert;
    final subscribed = WatchStore.instance.isSubscribed(e.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: p.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _push(WatchChannelScreen(expertId: e.id)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CHANNEL TO EXPLORE', style: pregGroupLabelStyle()),
              const SizedBox(height: 12),
              Row(children: [
                ClipOval(child: PvMarkWell(p: p, hue: 206, size: 44, icon: Icons.person_outline_rounded)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    PpExpertName(e, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(channel.statsLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: pvManrope(fontSize: 12, color: p.ink3)),
                  ]),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => WatchStore.instance.toggleSubscribe(e.id),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: subscribed ? Colors.white : kPvInk,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: subscribed ? p.line : kPvInk),
                    ),
                    child: Text(subscribed ? 'Subscribed' : 'Subscribe',
                        style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, color: subscribed ? p.ink2 : Colors.white)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
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
      padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
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
          PpExpertName(v.expert, suffix: ' · ${v.seconds}s',
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
      _pad(watchSectionHeader('Today for ${ChildProfileStore.instance.nameMid}')),
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
      padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
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
        // NO `alignment:` HERE, and that is the whole fix.
        //
        // A Container with a non-null alignment wraps its child in an Align,
        // and an Align with no widthFactor fills the width it is offered. Wrap
        // offers each child the FULL row width, so every chip became
        // full-width and Wrap could fit exactly one per line - fifteen
        // stacked bars that pushed every video about a thousand pixels down
        // the page. The Row below is already mainAxisSize.min, so removing the
        // alignment lets the chip size to its label, which is what Wrap needs
        // to do its job. Vertical padding replaces the height the Align used
        // to give it.
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                PpExpertName(e, style: ppJakarta(14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
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
        // White ground (2026-10-07, the one ParentVeda look). Kept for revert:
        // backgroundColor: ppBg.
        backgroundColor: pvStorePalette.ground,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              PpExpertName(e, style: ppFraunces(24, h: 1.15), underline: false),
              const SizedBox(height: 5),
              // Ink, not violet (2026-10-07). Kept for revert: color: ppPurple.
              Text(e.credential, style: ppBody(13.5, color: kPvInk, w: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(e.backLabel, style: ppBody(12.5, color: ppMuted)),
              const SizedBox(height: 14),
              Row(children: [
                const Icon(Icons.star_rounded, size: 15, color: ppAccentAmber),
                const SizedBox(width: 4),
                Text(e.rating.toString(), style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                const SizedBox(width: 6),
                Flexible(child: Text('from ${e.reviewsCount}', style: ppBody(12.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                        child: Text(
                            c.title == lead.name ? lead.credential : lead.name,
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
                    const Icon(Icons.star_rounded, size: 12, color: ppAccentAmber),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text('${lead.rating} · ${lead.reviewsCount}',
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

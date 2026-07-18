// =============================================================================
//  ReadingHomeScreen - ParentVeda "READ" (the Reading Experience home)
// -----------------------------------------------------------------------------
//  Answers "what should I read today to be a more confident parent?" - one
//  carefully-chosen Today's Read (not ten), Continue Reading, a few personalised
//  picks, and a browsable Collections section. A calm, magazine-like start, never
//  a feed. The Collections section carries a TWO-LEVEL filter: pick a Collection
//  (topic), then narrow by content Type (Articles / Book Summaries / Research).
//  A prominent search bar sits above it all. Reached from the Explore drawer
//  ("READ"). Pushed screen.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reading_data.dart';
import 'pp_section_extras.dart';
import 'reading_collection_screen.dart';
import 'reading_common.dart';
import 'reading_library_screen.dart';
import 'reading_reader_screen.dart';

class ReadingHomeScreen extends StatefulWidget {
  const ReadingHomeScreen({super.key});

  @override
  State<ReadingHomeScreen> createState() => _ReadingHomeScreenState();
}

class _ReadingHomeScreenState extends State<ReadingHomeScreen> {
  // Two-level Collections filter: level 1 = collection (topic), level 2 = type.
  // null = "All" at either level.
  String? _collectionFilter;
  ReadKind? _typeFilter;

  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';

  bool get _filtering => _collectionFilter != null || _typeFilter != null;

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));
  void _open(ReadArticle a) => _push(ReadingReaderScreen(article: a));

  // ---- search results (title contains query) ------------------------------
  List<Widget> _searchView(ReadingStore store) {
    final q = _query.trim().toLowerCase();
    final items = kReadArticles.where((a) => a.title.toLowerCase().contains(q)).toList();
    return [
      const SizedBox(height: 22),
      _pad(readSectionHeader('Search results')),
      const SizedBox(height: 14),
      if (items.isEmpty)
        _pad(Text('No matches for "$_query" - try another word.', style: ppBody(13, color: ppMuted)))
      else
        _pad(Column(children: [
          for (final a in items)
            ReadListCard(
              article: a,
              onTap: () => _open(a),
              progress: store.isInProgress(a.id) ? store.progressOf(a.id) : null,
            ),
        ])),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: ReadingStore.instance,
          builder: (context, _) {
            final store = ReadingStore.instance;
            final continues = store.continueReading;
            final today = todaysRead();
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Explore')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('ParentVeda READ', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('What to read today', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 6),
                _pad(Text('One good read, chosen for where you and Aarav are right now - not a feed to scroll.', style: ppBody(14, h: 1.5))),

                const SizedBox(height: 16),
                _pad(ppSearchField(
                  controller: _searchCtl,
                  hint: 'Search reads…',
                  onChanged: (v) => setState(() => _query = v),
                )),

                if (_query.trim().isNotEmpty)
                  ..._searchView(store)
                else
                  ..._browse(context, store, continues, today),
              ],
            );
          },
        ),
      ),
      const PpAskVedaFab(),
      ]),
    );
  }

  // ---- browse (editorial default + the Collections section) ---------------
  List<Widget> _browse(BuildContext context, ReadingStore store, List<ReadArticle> continues, ReadArticle today) {
    return [
      // The calm editorial start is only shown when the reader hasn't filtered -
      // once they narrow by collection/type, we focus on the results instead.
      if (!_filtering) ..._editorial(context, store, continues, today),

      const SizedBox(height: 30),
      ..._collectionsSection(context, store),

      const SizedBox(height: 30),
      _pad(_savedLink()),
    ];
  }

  List<Widget> _editorial(BuildContext context, ReadingStore store, List<ReadArticle> continues, ReadArticle today) {
    return [
      const SizedBox(height: 22),
      _pad(_todayHero(today)),

      if (continues.isNotEmpty) ...[
        const SizedBox(height: 30),
        _pad(readSectionHeader('Continue reading')),
        const SizedBox(height: 14),
        SizedBox(
          height: 252,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: continues.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _continueCard(continues[i]),
          ),
        ),
      ],

      const SizedBox(height: 30),
      _pad(readSectionHeader('Chosen for you')),
      const SizedBox(height: 4),
      _pad(Text('For his age and your recent reads - never random.', style: ppBody(12.5, color: ppMuted))),
      const SizedBox(height: 16),
      _pad(Column(children: [
        for (final a in forYou().take(5))
          ReadListCard(article: a, onTap: () => _open(a), progress: store.isInProgress(a.id) ? store.progressOf(a.id) : null),
      ])),
      // Five picks is a taster, not a library. This is the way through to the
      // rest rather than leaving it looking like all there is.
      const SizedBox(height: 6),
      _pad(GestureDetector(
        onTap: () => setState(() {
          _collectionFilter = null;
          _typeFilter = null;
        }),
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Text('Explore more reads', style: ppBody(13.5, color: ppPurple, w: FontWeight.w700)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
        ]),
      )),
    ];
  }

  // ---- Collections section (two-level filter) -----------------------------
  List<Widget> _collectionsSection(BuildContext context, ReadingStore store) {
    final results = filteredReads(collectionId: _collectionFilter, kind: _typeFilter);
    return [
      _pad(readSectionHeader('Collections')),
      const SizedBox(height: 4),
      _pad(Text(
        _filtering
            ? '${results.length} ${results.length == 1 ? 'read' : 'reads'} · ${_activeLabel()}'
            : 'Browse by topic, then narrow by type.',
        style: ppBody(12.5, color: _filtering ? ppPurple : ppMuted, w: _filtering ? FontWeight.w700 : FontWeight.w400),
      )),

      const SizedBox(height: 14),
      _collectionChips(),
      const SizedBox(height: 10),
      _typeChips(),

      const SizedBox(height: 18),
      if (!_filtering)
        // No filter yet: the minimalistic collection cards to browse into.
        _collectionCards(context)
      else
        ..._resultsList(store),
    ];
  }

  String _activeLabel() {
    final c = _collectionFilter != null ? readCollectionById(_collectionFilter!).title : 'All topics';
    final k = _typeFilter != null ? readKindLabel(_typeFilter!) : 'All types';
    return '$c · $k';
  }

  // level 1 - collection (topic)
  Widget _collectionChips() {
    final options = <(String, String?)>[
      ('All', null),
      for (final c in kReadCollections) (c.title, c.id),
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final on = _collectionFilter == options[i].$2;
          return _chip(options[i].$1, on, () => setState(() => _collectionFilter = options[i].$2));
        },
      ),
    );
  }

  // level 2 - content type
  Widget _typeChips() {
    const options = <(String, ReadKind?)>[
      ('All', null),
      ('Articles', ReadKind.article),
      ('Book Summaries', ReadKind.bookSummary),
      ('Research', ReadKind.research),
    ];
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final on = _typeFilter == options[i].$2;
          return _chip(options[i].$1, on, () => setState(() => _typeFilter = options[i].$2), subtle: true);
        },
      ),
    );
  }

  Widget _chip(String label, bool on, VoidCallback onTap, {bool subtle = false}) {
    final Color bg = on ? ppPurple : Colors.white;
    final Color fg = on ? Colors.white : (subtle ? ppSoft : ppInk);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: subtle ? 13 : 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? ppPurple : ppHair),
        ),
        child: Text(label, style: ppBody(subtle ? 12 : 12.5, color: fg, w: FontWeight.w700)),
      ),
    );
  }

  // no-filter default: the collection cards (tap opens the full collection path)
  Widget _collectionCards(BuildContext context) => SizedBox(
        height: 188,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: kReadCollections.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) {
            final c = kReadCollections[i];
            final mins = c.articleIds.map(readArticleById).fold<int>(0, (a, x) => a + x.minutes);
            final prog = ReadingStore.instance.collectionProgress(c);
            return GestureDetector(
              onTap: () => _push(ReadingCollectionScreen(collection: c)),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 208,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)), child: Icon(c.icon, size: 20, color: ppPurple)),
                  const Spacer(),
                  Text(c.title, style: ppJakarta(15).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text('${c.articleIds.length} reads · ~$mins min', style: ppBody(11.5, color: ppMuted)),
                  const SizedBox(height: 3),
                  Text(prog >= 1 ? 'Completed' : prog > 0 ? '${(prog * 100).round()}% done' : 'Start', style: ppBody(11, color: prog > 0 ? ppPurple : ppMuted, w: FontWeight.w700)),
                ]),
              ),
            );
          },
        ),
      );

  // filtered: the narrowed list + (when a whole collection is picked) a link in.
  List<Widget> _resultsList(ReadingStore store) {
    final results = filteredReads(collectionId: _collectionFilter, kind: _typeFilter);
    return [
      if (results.isEmpty)
        _pad(Text('No reads here yet - try another type or topic.', style: ppBody(13, color: ppMuted)))
      // NO TYPE CHOSEN: group by type rather than pouring everything into one
      // undifferentiated list. Articles, then book summaries, then research -
      // each with its own heading and a few entries, so "All" is browsable
      // rather than a wall. Vertical throughout: horizontal rails are wrong
      // for reading, where you scan down a list of titles.
      else if (_typeFilter == null) ...[
        for (final kind in ReadKind.values)
          if (results.where((a) => a.kind == kind).isNotEmpty) ...[
            _pad(Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: Text(readKindLabel(kind).toUpperCase(),
                  style: ppBody(10, color: ppPurple, w: FontWeight.w800).copyWith(letterSpacing: 0.8)),
            )),
            _pad(Column(children: [
              for (final a in results.where((a) => a.kind == kind).take(4))
                ReadListCard(
                  article: a,
                  onTap: () => _open(a),
                  progress: store.isInProgress(a.id) ? store.progressOf(a.id) : null,
                ),
            ])),
            if (results.where((a) => a.kind == kind).length > 4)
              _pad(GestureDetector(
                onTap: () => setState(() => _typeFilter = kind),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(children: [
                    Text('View more ${readKindLabel(kind).toLowerCase()}',
                        style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
                  ]),
                ),
              ))
            else
              const SizedBox(height: 12),
          ],
      ]
      else
        _pad(Column(children: [
          for (final a in results)
            ReadListCard(
              article: a,
              onTap: () => _open(a),
              progress: store.isInProgress(a.id) ? store.progressOf(a.id) : null,
            ),
        ])),
      if (_collectionFilter != null) ...[
        const SizedBox(height: 4),
        _pad(GestureDetector(
          onTap: () => _push(ReadingCollectionScreen(collection: readCollectionById(_collectionFilter!))),
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            Text('Open the full ${readCollectionById(_collectionFilter!).title} path', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
          ]),
        )),
      ],
    ];
  }

  Widget _todayHero(ReadArticle a) => GestureDetector(
        onTap: () => _open(a),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: ppHair), boxShadow: ppCardShadow),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ReadCover(seed: a.seed, height: 188, radius: 0),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  ppEyebrow('Today’s read', color: ppPurple, spacing: 1.0),
                  const Spacer(),
                  Text('${a.minutes} min read', style: ppBody(11.5, color: ppMuted, w: FontWeight.w600)),
                ]),
                const SizedBox(height: 12),
                Text(a.title, style: ppFraunces(23, h: 1.2)),
                const SizedBox(height: 8),
                Text(a.teaser, style: ppBody(14, h: 1.5)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.wb_sunny_outlined, size: 16, color: ppPurple),
                    const SizedBox(width: 10),
                    Expanded(child: Text(a.whyToday, style: ppBody(12.5, color: ppInk, h: 1.5))),
                  ]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Start reading', style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
                    const SizedBox(width: 7),
                    const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      );

  Widget _continueCard(ReadArticle a) {
    final p = ReadingStore.instance.progressOf(a.id);
    return GestureDetector(
      onTap: () => _open(a),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 220,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ReadCover(seed: a.seed, height: 130, progress: p),
          const SizedBox(height: 10),
          Text(a.title, style: ppJakarta(14).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text('${(p * 100).round()}% · tap to continue', style: ppBody(11.5, color: ppPurple, w: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _savedLink() => GestureDetector(
        onTap: () => _push(const ReadingLibraryScreen()),
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
                Text('Saved reads, in-progress & completed', style: ppBody(12)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

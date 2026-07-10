// =============================================================================
//  ReadingHomeScreen - ParentVeda "Learn" (the Reading Experience home)
// -----------------------------------------------------------------------------
//  Answers "what should I learn today to be a more confident parent?" - one
//  carefully-chosen Today's Read (not ten), Continue Reading, a few personalised
//  picks, and learning collections. A calm, magazine-like start, never a feed.
//  A filter row (All / Articles / Book Summaries / Research Summaries) narrows the
//  library to one kind. Reached from the Explore drawer ("Learn"). Pushed screen.
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
  // null = All; otherwise only that kind is shown.
  ReadKind? _filter;

  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';

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
                _pad(ppEyebrow('ParentVeda Learn', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('What to learn today', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 6),
                _pad(Text('One good read, chosen for where you and Aarav are right now - not a feed to scroll.', style: ppBody(14, h: 1.5))),

                const SizedBox(height: 16),
                _pad(ppSearchField(
                  controller: _searchCtl,
                  hint: 'Search articles…',
                  onChanged: (v) => setState(() => _query = v),
                )),

                if (_query.trim().isNotEmpty)
                  ..._searchView(store)
                else ...[
                  const SizedBox(height: 20),
                  _filterRow(),
                  if (_filter != null)
                    ..._filteredView()
                  else
                    ..._fullView(context, store, continues, today),
                ],
              ],
            );
          },
        ),
      ),
      const PpAskVedaFab(),
      ]),
    );
  }

  // ---- filter row ---------------------------------------------------------
  Widget _filterRow() {
    const options = <(String, ReadKind?)>[
      ('All', null),
      ('Articles', ReadKind.article),
      ('Book Summaries', ReadKind.bookSummary),
      ('Research Summaries', ReadKind.research),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final on = _filter == options[i].$2;
          return GestureDetector(
            onTap: () => setState(() => _filter = options[i].$2),
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: on ? ppPurple : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: on ? ppPurple : ppHair),
              ),
              child: Text(options[i].$1, style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
            ),
          );
        },
      ),
    );
  }

  // ---- filtered view (one kind only) --------------------------------------
  List<Widget> _filteredView() {
    final items = articlesOfKind(_filter!);
    return [
      const SizedBox(height: 22),
      _pad(readSectionHeader(readKindLabel(_filter!))),
      const SizedBox(height: 14),
      if (items.isEmpty)
        _pad(Text('Nothing here yet - check back soon.', style: ppBody(13, color: ppMuted)))
      else
        _pad(Column(children: [
          for (final a in items)
            ReadListCard(
              article: a,
              onTap: () => _open(a),
              progress: ReadingStore.instance.isInProgress(a.id) ? ReadingStore.instance.progressOf(a.id) : null,
            ),
        ])),
      const SizedBox(height: 30),
      _pad(_savedLink()),
    ];
  }

  // ---- full view (All) ----------------------------------------------------
  List<Widget> _fullView(BuildContext context, ReadingStore store, List<ReadArticle> continues, ReadArticle today) {
    return [
      const SizedBox(height: 22),
      _pad(_todayHero(today)),

      if (continues.isNotEmpty) ...[
        const SizedBox(height: 30),
        _pad(readSectionHeader('Continue reading')),
        const SizedBox(height: 14),
        SizedBox(
          height: 214,
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

      const SizedBox(height: 14),
      _pad(readSectionHeader('Learning collections')),
      const SizedBox(height: 4),
      _pad(Text('Short, finishable paths through a topic.', style: ppBody(12.5, color: ppMuted))),
      const SizedBox(height: 16),
      _collections(context),

      const SizedBox(height: 30),
      _pad(_savedLink()),
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

  Widget _collections(BuildContext context) => SizedBox(
        height: 150,
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

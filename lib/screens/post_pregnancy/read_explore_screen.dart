// =============================================================================
//  Read — the redesigned home. Filters at the top, topics as playlists.
// -----------------------------------------------------------------------------
//  Built to the Read brief, on the same kit as the Recipes and Recommendations
//  redesigns, because the brief asked for exactly that: "so all three sections
//  feel like part of one cohesive Explore experience".
//
//  Page order, as specified:
//      expert banner -> search -> TOPIC filters -> CONTENT TYPE filters
//      -> Chosen for you -> Explore by topic (playlists) -> Your library
//
//  WHAT THE BRIEF REMOVED, and it was explicit about all three:
//      Today's Read       gone
//      Continue Reading   gone
//      Collections        gone as a section — the collections themselves BECOME
//                         the topic playlists, which is the same data doing a
//                         better job rather than content being thrown away.
//
//  THE FILTERS ARE THE EXISTING ONES, MOVED. The brief is emphatic: "Do NOT
//  create new filters. Do NOT rename filters. Do NOT remove filters. Keep the
//  existing filtering logic exactly as it works today. Only their position
//  changes." So the topic row is kReadCollections and the type row is
//  ReadKind — both read straight from the data that already drove them.
//
//  AND THEY COMPOSE, per the brief's own example: choosing "Articles" narrows
//  Chosen For You AND every playlist, and a playlist opened afterwards still
//  respects it.
//
//  THE OLD SCREEN IS UNTOUCHED. reading_home_screen.dart still exists; the
//  Explore row that opened it is commented in place beside the new one.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_explore_kit.dart';
import 'pp_reading_data.dart';
import 'reading_library_screen.dart';
import 'reading_reader_screen.dart';

/// The content-type row. "All" plus the three kinds that exist — nothing
/// invented, nothing renamed.
const List<String> _kTypeLabels = [
  'All',
  'Articles',
  'Book Summaries',
  'Research Summaries',
];

ReadKind? _kindFor(String label) => switch (label) {
      'Articles' => ReadKind.article,
      'Book Summaries' => ReadKind.bookSummary,
      'Research Summaries' => ReadKind.research,
      _ => null,
    };

class ReadExploreScreen extends StatefulWidget {
  const ReadExploreScreen({super.key});

  @override
  State<ReadExploreScreen> createState() => _ReadExploreScreenState();
}

class _ReadExploreScreenState extends State<ReadExploreScreen> {
  final _search = TextEditingController();
  String _q = '';
  String _topic = 'All';
  String _type = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _push(Widget s) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  /// The two filter rows, applied together.
  ///
  /// Shared by Chosen For You and by every playlist, so "if the user selects
  /// Articles, then Chosen For You only shows Articles" holds without each
  /// section re-deriving it — which is how two sections end up disagreeing
  /// about what a filter means.
  List<ReadArticle> _filtered(Iterable<ReadArticle> from) {
    final kind = _kindFor(_type);
    return from.where((a) {
      if (kind != null && a.kind != kind) return false;
      if (_topic != 'All' && a.collection != _topicId(_topic)) return false;
      return true;
    }).toList();
  }

  String _topicId(String title) => kReadCollections
      .firstWhere((c) => c.title == title, orElse: () => kReadCollections.first)
      .id;

  List<ReadArticle> get _results {
    final t = _q.trim().toLowerCase();
    if (t.isEmpty) return const [];
    return _filtered(kReadArticles).where((a) {
      return a.title.toLowerCase().contains(t) ||
          a.teaser.toLowerCase().contains(t) ||
          a.whyToday.toLowerCase().contains(t) ||
          a.author.toLowerCase().contains(t);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final searching = _q.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ppBack(context, 'Explore'),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text('Read', style: ppFraunces(31, h: 1.05)),
            ),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: ExpertCuratedBanner(
                text: 'Every article, book summary and research piece here has '
                    'been vetted by experts and chosen for your child’s current '
                    'age and stage.',
                icon: Icons.verified_outlined,
                accent: ppPurple,
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ExploreSearchBar(
                controller: _search,
                hint: 'Search articles, summaries or research…',
                onChanged: (v) => setState(() => _q = v),
              ),
            ),

            // ---- the existing filters, moved to the top ------------------
            const SizedBox(height: 14),
            ExploreFilterChips(
              labels: ['All', for (final c in kReadCollections) c.title],
              selected: _topic,
              onSelect: (v) => setState(() => _topic = v),
            ),
            const SizedBox(height: 9),
            ExploreFilterChips(
              labels: _kTypeLabels,
              selected: _type,
              onSelect: (v) => setState(() => _type = v),
            ),

            const SizedBox(height: 22),
            if (searching) ..._searchResults() else ..._sections(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---- sections ------------------------------------------------------------

  List<Widget> _sections() {
    final chosen = _filtered(kReadArticles);
    final out = <Widget>[];

    // 1. Chosen for you — still MULTI-item, per the brief: "Do NOT convert it
    //    into a single featured article."
    out.add(ExploreSectionHeader(
      title: 'Chosen for you',
      subtitle: 'For this age, this stage, and what you have been reading.',
      seeMoreLabel: 'View all',
      onSeeMore: chosen.isEmpty
          ? null
          : () => _push(ReadListingScreen(
                title: 'Chosen for you',
                articles: chosen,
              )),
    ));
    out.add(const SizedBox(height: 12));
    if (chosen.isEmpty) {
      out.add(ExploreEmpty(
        title: 'Nothing matches those filters',
        subtitle:
            'Try a different topic or content type — everything else is still '
            'here.',
        icon: Icons.filter_alt_off_outlined,
        cta: 'Clear filters',
        onCta: () => setState(() {
          _topic = 'All';
          _type = 'All';
        }),
      ));
    } else {
      // 4–6, per the brief.
      out.add(ExploreRail(
        height: 196,
        itemWidth: 168,
        children: [for (final a in chosen.take(6)) _card(a)],
      ));
    }

    // 2. Explore by topic — the playlists.
    out
      ..add(const SizedBox(height: 28))
      ..add(ExploreSectionHeader(
        title: 'Explore by topic',
        subtitle: 'Every topic, as its own reading list.',
        seeMoreLabel: 'See all',
        onSeeMore: () => _push(const AllPlaylistsScreen()),
      ))
      ..add(const SizedBox(height: 12))
      ..add(ExploreRail(
        height: 168,
        itemWidth: 216,
        children: [
          for (final c in kReadCollections) _playlistCard(c),
        ],
      ));

    // 3. Your library, unchanged and last, per the brief.
    out
      ..add(const SizedBox(height: 28))
      ..add(ExploreSectionHeader(title: 'Your library'))
      ..add(const SizedBox(height: 12))
      ..add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: _libraryRow(),
      ));
    return out;
  }

  /// A topic as a playlist card: icon, name, count, description, the way in.
  Widget _playlistCard(ReadCollection c) {
    // The count respects the content-type filter, so a card cannot promise
    // twelve reads and open onto two.
    final n = _filtered(articlesInCollection(c.id)).length;
    return GestureDetector(
      onTap: () => _push(TopicPlaylistScreen(collection: c, type: _type)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppPurple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(c.icon, size: 19, color: ppPurple),
          ),
          const SizedBox(height: 11),
          Text(c.title,
              style: ppJakarta(14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text('$n read${n == 1 ? '' : 's'}',
              style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
          const SizedBox(height: 5),
          Expanded(
            child: Text(c.subtitle,
                style: ppBody(11.5, color: ppMuted, h: 1.35),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          Row(children: [
            Text('Explore playlist',
                style: ppBody(11.5, color: ppPurple, w: FontWeight.w800)),
            const SizedBox(width: 3),
            const Icon(Icons.arrow_forward_rounded, size: 13, color: ppPurple),
          ]),
        ]),
      ),
    );
  }

  Widget _libraryRow() => GestureDetector(
        onTap: () => _push(const ReadingLibraryScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const Icon(Icons.bookmark_border_rounded, size: 20, color: ppPurple),
            const SizedBox(width: 13),
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your library', style: ppJakarta(14)),
                const SizedBox(height: 3),
                Text('Saved, in progress and finished.',
                    style: ppBody(11.5, color: ppMuted)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  Widget _card(ReadArticle a) => ReadRailCard(
        article: a,
        onTap: () => _push(ReadingReaderScreen(article: a)),
      );

  // ---- search --------------------------------------------------------------

  List<Widget> _searchResults() {
    final results = _results;
    if (results.isEmpty) {
      return [
        ExploreEmpty(
          title: 'Nothing found',
          subtitle: 'Try another search, or clear the filters above.',
          cta: 'Clear search',
          onCta: () {
            _search.clear();
            setState(() => _q = '');
            FocusScope.of(context).unfocus();
          },
        ),
      ];
    }
    return [
      ExploreSectionHeader(
        title: '${results.length} read${results.length == 1 ? '' : 's'}',
        subtitle: 'Matching “${_q.trim()}”',
      ),
      const SizedBox(height: 12),
      for (final a in results)
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
          child: ReadResultRow(
            article: a,
            onTap: () => _push(ReadingReaderScreen(article: a)),
          ),
        ),
    ];
  }
}

// =============================================================================
//  Shared cards
// =============================================================================

class ReadRailCard extends StatelessWidget {
  const ReadRailCard({super.key, required this.article, required this.onTap});

  final ReadArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ExploreThumb(
            icon: Icons.auto_stories_outlined,
            accent: ppPurple,
            height: 96,
            topLeft: ExploreBadge(label: readKindLabel(article.kind)),
            topRight: ListenableBuilder(
              listenable: ReadingStore.instance,
              builder: (_, _) => ExploreBookmark(
                saved: ReadingStore.instance.isSaved(article.id),
                onTap: () => ReadingStore.instance.toggleSave(article.id),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(article.title,
              style: ppJakarta(13).copyWith(height: 1.25),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(article.teaser,
              style: ppBody(11, color: ppMuted, h: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text('${article.minutes} min · ${article.author}',
              style: ppBody(10.5, color: ppMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

class ReadResultRow extends StatelessWidget {
  const ReadResultRow({super.key, required this.article, required this.onTap});

  final ReadArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ppBorder),
          ),
          child: Row(children: [
            SizedBox(
              width: 60,
              child: ExploreThumb(
                icon: Icons.auto_stories_outlined,
                accent: ppPurple,
                height: 60,
                radius: 12,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(article.title,
                    style: ppJakarta(13.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                    '${readKindLabel(article.kind)} · ${article.minutes} min',
                    style: ppBody(11, color: ppMuted)),
              ]),
            ),
            ListenableBuilder(
              listenable: ReadingStore.instance,
              builder: (_, _) => ExploreBookmark(
                saved: ReadingStore.instance.isSaved(article.id),
                onTap: () => ReadingStore.instance.toggleSave(article.id),
              ),
            ),
          ]),
        ),
      );
}

// =============================================================================
//  A topic playlist
// -----------------------------------------------------------------------------
//  The brief wants a topic's content grouped BY KIND inside it — sleep
//  articles, then sleep books, then sleep research — rather than one flat list.
//  That is what makes it a playlist rather than a filtered page.
// =============================================================================

class TopicPlaylistScreen extends StatefulWidget {
  const TopicPlaylistScreen({
    super.key,
    required this.collection,
    required this.type,
  });

  final ReadCollection collection;

  /// Inherited from the home, per the brief: "Every playlist, when opened,
  /// defaults to showing only Articles" if that is what was selected.
  final String type;

  @override
  State<TopicPlaylistScreen> createState() => _TopicPlaylistScreenState();
}

class _TopicPlaylistScreenState extends State<TopicPlaylistScreen> {
  late String _type = widget.type;

  @override
  Widget build(BuildContext context) {
    final all = articlesInCollection(widget.collection.id);
    final kind = _kindFor(_type);
    final items =
        kind == null ? all : all.where((a) => a.kind == kind).toList();

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ppBack(context, 'Read'),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ppPurple.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.collection.icon, size: 22, color: ppPurple),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(widget.collection.title,
                      style: ppFraunces(26, h: 1.08)),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(widget.collection.subtitle,
                  style: ppBody(13.5, h: 1.55)),
            ),
            const SizedBox(height: 16),
            ExploreFilterChips(
              labels: _kTypeLabels,
              selected: _type,
              onSelect: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              ExploreEmpty(
                title: 'Nothing of that kind here yet',
                subtitle:
                    'This playlist has no ${_type.toLowerCase()} at the moment. '
                    'Everything else in it is one tap away.',
                icon: Icons.library_books_outlined,
                cta: 'Show everything',
                onCta: () => setState(() => _type = 'All'),
              )
            else
              // Grouped by kind, which is what makes this a playlist rather
              // than a filtered list.
              ..._grouped(items),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  List<Widget> _grouped(List<ReadArticle> items) {
    final out = <Widget>[];
    for (final k in ReadKind.values) {
      final of = items.where((a) => a.kind == k).toList();
      if (of.isEmpty) continue;
      out
        ..add(ExploreSectionHeader(title: readKindLabel(k)))
        ..add(const SizedBox(height: 12));
      for (final a in of) {
        out.add(Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
          child: ReadResultRow(
            article: a,
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => ReadingReaderScreen(article: a))),
          ),
        ));
      }
      out.add(const SizedBox(height: 16));
    }
    return out;
  }
}

/// Every playlist, for the "See all".
class AllPlaylistsScreen extends StatelessWidget {
  const AllPlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ppBg,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ppBack(context, 'Read'),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text('Every topic', style: ppFraunces(28, h: 1.05)),
              ),
              const SizedBox(height: 20),
              for (final c in kReadCollections)
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) =>
                                TopicPlaylistScreen(collection: c, type: 'All'))),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ppBorder),
                      ),
                      child: Row(children: [
                        Icon(c.icon, size: 20, color: ppPurple),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.title, style: ppJakarta(14)),
                                const SizedBox(height: 3),
                                Text(c.subtitle,
                                    style: ppBody(11.5, color: ppMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ]),
                        ),
                        Text('${articlesInCollection(c.id).length}',
                            style: ppBody(12, color: ppMuted)),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded,
                            size: 20, color: ppMuted),
                      ]),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
}

/// A plain list of reads — the "View all" behind Chosen for you.
class ReadListingScreen extends StatelessWidget {
  const ReadListingScreen({
    super.key,
    required this.title,
    required this.articles,
  });

  final String title;
  final List<ReadArticle> articles;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ppBg,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ppBack(context, 'Read'),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(title, style: ppFraunces(28, h: 1.05)),
              ),
              const SizedBox(height: 20),
              for (final a in articles)
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: ReadResultRow(
                    article: a,
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => ReadingReaderScreen(article: a))),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
}

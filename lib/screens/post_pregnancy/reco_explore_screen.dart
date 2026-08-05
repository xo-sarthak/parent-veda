// =============================================================================
//  Recommendations — the redesigned home. A concierge, not a shop.
// -----------------------------------------------------------------------------
//  Built to the Recommendations brief, on the same kit as the Recipes redesign
//  because the brief asked for exactly that: "the Recommendations screen should
//  feel like its sibling — using the same layout philosophy".
//
//  Page order, as specified:
//      expert banner -> search -> STICKY section-navigation chips
//      -> Recommended For You -> twelve category sections, each with See more
//
//  THE ONE THING THAT IS NOT A FILTER. The brief is emphatic: "These are NOT
//  filters. These are section navigation shortcuts." So tapping a chip SCROLLS
//  to that section and the active chip follows the scroll — it never hides
//  anything. That distinction is why pp_explore_kit has two chip widgets
//  instead of one with a flag: a parent who taps "Toys" expecting a filter and
//  gets a scroll has been mildly lied to, and a shared widget makes that easy
//  to ship by accident.
//
//  THE OLD SCREEN IS UNTOUCHED. recommendations_screen.dart still exists; the
//  Explore row that opened it is commented in place beside the new one.
//
//  SEARCH HIDES EVERYTHING, per the brief — one unified result list with a
//  category badge on each row, rather than twelve filtered rails.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart' show kAskFabReserve;

import 'pp_common.dart';
import 'pp_explore_kit.dart';
import 'pp_reco_data.dart';
import 'reco_detail_screen.dart';

// =============================================================================
//  The twelve sections, in the brief's order
// =============================================================================

class RecoSection {
  const RecoSection(this.title, this.category, this.icon, this.accent);

  final String title;

  /// The value in RecoItem.category. Kept separate from [title] because the
  /// brief renames two of them for display ("Outdoor Activities", "Travel
  /// Destinations") and the data must not be renamed to match a label.
  final String category;
  final IconData icon;
  final Color accent;

  List<RecoItem> get items =>
      kReco.where((r) => r.category == category).toList();
}

const Color _cWarm = ppAccentAmber;
const Color _cGreen = ppAccentGreen;
const Color _cBlue = ppAccentBlue;

const List<RecoSection> kRecoSections = [
  RecoSection('Books', 'Books', Icons.menu_book_outlined, ppPurple),
  RecoSection('Activities', 'Activities', Icons.extension_outlined, _cWarm),
  RecoSection('Toys', 'Toys', Icons.toys_outlined, _cGreen),
  RecoSection('Videos', 'Videos', Icons.play_circle_outline, _cBlue),
  RecoSection('Music', 'Music', Icons.music_note_outlined, ppCoral),
  RecoSection('Outdoor activities', 'Outdoor', Icons.park_outlined, _cGreen),
  RecoSection('Experiences', 'Experiences', Icons.auto_awesome_outlined, ppPurple),
  RecoSection('Products', 'Products', Icons.shopping_bag_outlined, _cWarm),
  RecoSection('Events', 'Events', Icons.celebration_outlined, ppCoral),
  RecoSection('Travel destinations', 'Travel', Icons.flight_takeoff_outlined, _cBlue),
  RecoSection('Restaurants', 'Restaurants', Icons.restaurant_outlined, _cWarm),
  RecoSection('Birthday ideas', 'Birthday Ideas', Icons.cake_outlined, ppCoral),
];

// =============================================================================
//  The screen
// =============================================================================

class RecoExploreScreen extends StatefulWidget {
  const RecoExploreScreen({super.key});

  @override
  State<RecoExploreScreen> createState() => _RecoExploreScreenState();
}

class _RecoExploreScreenState extends State<RecoExploreScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  String _q = '';
  int _active = 0;

  late final List<ExploreNavTarget> _targets = [
    for (final s in kRecoSections)
      ExploreNavTarget(label: s.title.split(' ').first, icon: s.icon),
  ];
  late final ExploreScrollSpy _spy =
      ExploreScrollSpy(controller: _scroll, targets: _targets);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  /// "active chip automatically changes while user scrolls".
  ///
  /// Suppressed while a chip-tap animation is running — otherwise the jump
  /// fires this on every frame and the chip flickers through every section it
  /// passes on the way.
  void _onScroll() {
    if (_spy.isJumping) return;
    final i = _spy.activeIndex();
    if (i != _active && mounted) setState(() => _active = i);
  }

  void _push(Widget s) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  List<RecoItem> get _results {
    final t = _q.trim().toLowerCase();
    if (t.isEmpty) return const [];
    return kReco
        .where((r) =>
            r.title.toLowerCase().contains(t) ||
            r.summary.toLowerCase().contains(t) ||
            r.category.toLowerCase().contains(t) ||
            (r.subtype ?? '').toLowerCase().contains(t) ||
            r.tags.any((x) => x.toLowerCase().contains(t)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final searching = _q.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: RecoStore.instance,
          builder: (context, _) => CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(child: _head()),
              // THE STICKY CHIPS. A SliverPersistentHeader rather than a
              // pinned widget above the list, because the brief wants them to
              // stay put while everything else scrolls under them — and only a
              // sliver can do that inside one scroll view.
              if (!searching)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _ChipsHeader(
                    child: ExploreNavChips(
                      targets: _targets,
                      activeIndex: _active,
                      onTap: (i) async {
                        setState(() => _active = i);
                        await _spy.jumpTo(i);
                      },
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildListDelegate(
                  searching ? _searchResults() : _sections(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 34)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _head() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ppBack(context, 'Explore'),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child:
                Text('ParentVeda Recommendations', style: ppFraunces(29, h: 1.08)),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: ExpertCuratedBanner(
              text: 'Every recommendation is carefully curated by child '
                  'development experts and personalised for your child’s age, '
                  'developmental stage and interests.',
              accent: ppPurple,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ExploreSearchBar(
              controller: _search,
              hint: 'Search books, toys, activities, products…',
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          const SizedBox(height: 6),
        ],
      );

  // ---- sections ------------------------------------------------------------

  List<Widget> _sections() {
    final out = <Widget>[
      const SizedBox(height: 14),
      // "Before all categories show a personalized section."
      ExploreSectionHeader(
        title: 'Recommended for you',
        subtitle: 'Chosen for this age and stage, across every kind of thing.',
      ),
      const SizedBox(height: 12),
      ExploreRail(
        height: 214,
        itemWidth: 158,
        children: [
          for (final r in recommendedToday(count: 8)) _card(r, showCategory: true),
        ],
      ),
      const SizedBox(height: 28),
    ];

    for (var i = 0; i < kRecoSections.length; i++) {
      final s = kRecoSections[i];
      final items = s.items;
      if (items.isEmpty) continue;
      out
        ..add(ExploreSectionHeader(
          title: s.title,
          anchorKey: _targets[i].key,
          onSeeMore: () => _push(RecoCategoryScreen(section: s)),
        ))
        ..add(const SizedBox(height: 12))
        ..add(ExploreRail(
          height: 214,
          itemWidth: 158,
          children: [for (final r in items.take(6)) _card(r)],
        ))
        ..add(const SizedBox(height: 26));
    }
    return out;
  }

  RecoSection _sectionFor(RecoItem r) => kRecoSections.firstWhere(
        (s) => s.category == r.category,
        orElse: () => kRecoSections.first,
      );

  Widget _card(RecoItem r, {bool showCategory = false}) {
    final s = _sectionFor(r);
    final saved = RecoStore.instance.isSaved(r.id);
    return GestureDetector(
      onTap: () => _push(RecoDetailScreen(item: r)),
      behavior: HitTestBehavior.opaque,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ExploreThumb(
          icon: s.icon,
          accent: s.accent,
          height: 112,
          topRight: ExploreBookmark(
            saved: saved,
            onTap: () => RecoStore.instance.toggleSave(r.id),
          ),
          topLeft: r.pvRating >= 4.8
              ? const ExploreBadge(
                  label: 'Expert pick', color: ppPurple, ink: Colors.white)
              : null,
        ),
        const SizedBox(height: 9),
        Text(r.title,
            style: ppJakarta(13).copyWith(height: 1.25),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(r.summary,
            style: ppBody(11, color: ppMuted, h: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Row(children: [
          if (showCategory) ...[
            Text(s.title.split(' ').first,
                style: ppBody(10.5, color: s.accent, w: FontWeight.w800)),
            Text(' · ', style: ppBody(10.5, color: ppMuted)),
          ],
          Expanded(
            child: Text(_ageLabel(r),
                style: ppBody(10.5, color: ppMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          // A star, not a heart: this number is a RATING, and a filled heart
          // reads as "saved" or "liked". Amber matches Watch, Products and
          // the Product Guide - one mark for one meaning.
          const Icon(Icons.star_rounded, size: 12, color: ppAccentAmber),
          const SizedBox(width: 3),
          Text(r.pvRating.toStringAsFixed(1),
              style: ppBody(10.5, color: ppSoft, w: FontWeight.w700)),
        ]),
      ]),
    );
  }

  /// "6m–3 yrs" rather than "6–36 months" — months read as a bigger number
  /// than they are, and the cards are already dense.
  static String _ageLabel(RecoItem r) {
    String one(int m) => m < 12 ? '${m}m' : '${(m / 12).floor()}y';
    return '${one(r.ageMin)}–${one(r.ageMax)}';
  }

  // ---- search --------------------------------------------------------------

  List<Widget> _searchResults() {
    final results = _results;
    if (results.isEmpty) {
      return [
        const SizedBox(height: 20),
        ExploreEmpty(
          title: 'Nothing found',
          subtitle: 'Try another search, or browse another category.',
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
      const SizedBox(height: 16),
      ExploreSectionHeader(
        title: '${results.length} result${results.length == 1 ? '' : 's'}',
        subtitle: 'Across every category',
      ),
      const SizedBox(height: 12),
      for (final r in results)
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
          child: RecoResultRow(
            item: r,
            section: _sectionFor(r),
            onTap: () => _push(RecoDetailScreen(item: r)),
          ),
        ),
    ];
  }
}

/// The pinned chips row.
class _ChipsHeader extends SliverPersistentHeaderDelegate {
  _ChipsHeader({required this.child});
  final Widget child;

  @override
  double get minExtent => 74;
  @override
  double get maxExtent => 74;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  bool shouldRebuild(covariant _ChipsHeader old) => old.child != child;
}

/// A recommendation as a full-width row, with its category badge — the brief
/// asks for category badges on search results specifically, because a unified
/// list is otherwise a pile of unrelated things.
class RecoResultRow extends StatelessWidget {
  const RecoResultRow({
    super.key,
    required this.item,
    required this.section,
    required this.onTap,
  });

  final RecoItem item;
  final RecoSection section;
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
              width: 62,
              child: ExploreThumb(
                icon: section.icon,
                accent: section.accent,
                height: 62,
                radius: 12,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title,
                    style: ppJakarta(13.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(item.summary,
                    style: ppBody(11.5, color: ppMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: section.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(section.title,
                        style: ppBody(10,
                            color: section.accent, w: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  if (item.price != null)
                    Text(item.price!, style: ppBody(11, color: ppSoft)),
                ]),
              ]),
            ),
            ListenableBuilder(
              listenable: RecoStore.instance,
              builder: (_, _) => ExploreBookmark(
                saved: RecoStore.instance.isSaved(item.id),
                onTap: () => RecoStore.instance.toggleSave(item.id),
              ),
            ),
          ]),
        ),
      );
}

// =============================================================================
//  "See more" — one category
// =============================================================================

class RecoCategoryScreen extends StatefulWidget {
  const RecoCategoryScreen({super.key, required this.section});
  final RecoSection section;

  @override
  State<RecoCategoryScreen> createState() => _RecoCategoryScreenState();
}

class _RecoCategoryScreenState extends State<RecoCategoryScreen> {
  final _search = TextEditingController();
  String _q = '';
  String _sort = 'Recommended';
  bool _grid = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<RecoItem> get _items {
    var list = widget.section.items;
    final t = _q.trim().toLowerCase();
    if (t.isNotEmpty) {
      list = list
          .where((r) =>
              r.title.toLowerCase().contains(t) ||
              r.summary.toLowerCase().contains(t) ||
              r.tags.any((x) => x.toLowerCase().contains(t)))
          .toList();
    }
    switch (_sort) {
      case 'Youngest first':
        list.sort((a, b) => a.ageMin.compareTo(b.ageMin));
      case 'Top rated':
        list.sort((a, b) => b.pvRating.compareTo(a.pvRating));
      default:
        list.sort((a, b) => a.seed.compareTo(b.seed));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: RecoStore.instance,
          builder: (context, _) => ListView(
            padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ppBack(context, 'Recommendations'),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(children: [
                  Expanded(
                    child: Text(widget.section.title,
                        style: ppFraunces(28, h: 1.05)),
                  ),
                  // Grid / list toggle, per the brief.
                  GestureDetector(
                    onTap: () => setState(() => _grid = !_grid),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ppBorder),
                      ),
                      child: Icon(
                          _grid
                              ? Icons.view_agenda_outlined
                              : Icons.grid_view_rounded,
                          size: 18,
                          color: ppPurple),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ExploreSearchBar(
                  controller: _search,
                  hint: 'Search ${widget.section.title.toLowerCase()}…',
                  onChanged: (v) => setState(() => _q = v),
                ),
              ),
              const SizedBox(height: 14),
              ExploreFilterChips(
                labels: const ['Recommended', 'Youngest first', 'Top rated'],
                selected: _sort,
                onSelect: (v) => setState(() => _sort = v),
              ),
              const SizedBox(height: 20),
              if (items.isEmpty)
                ExploreEmpty(
                  title: 'Nothing found',
                  subtitle:
                      'Try another search, or browse another category.',
                  cta: 'Clear',
                  onCta: () {
                    _search.clear();
                    setState(() => _q = '');
                  },
                )
              else if (_grid)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    children: [
                      for (final r in items)
                        SizedBox(
                          width:
                              (MediaQuery.of(context).size.width - 44 - 12) / 2,
                          child: _gridCard(r),
                        ),
                    ],
                  ),
                )
              else
                for (final r in items)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                    child: RecoResultRow(
                      item: r,
                      section: widget.section,
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) => RecoDetailScreen(item: r))),
                    ),
                  ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridCard(RecoItem r) => GestureDetector(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => RecoDetailScreen(item: r))),
        behavior: HitTestBehavior.opaque,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ExploreThumb(
            icon: widget.section.icon,
            accent: widget.section.accent,
            height: 120,
            topRight: ExploreBookmark(
              saved: RecoStore.instance.isSaved(r.id),
              onTap: () => RecoStore.instance.toggleSave(r.id),
            ),
          ),
          const SizedBox(height: 9),
          Text(r.title,
              style: ppJakarta(13).copyWith(height: 1.25),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(r.summary,
              style: ppBody(11, color: ppMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

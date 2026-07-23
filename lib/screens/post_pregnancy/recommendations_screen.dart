// =============================================================================
//  RecommendationsScreen - ParentVeda's intelligent discovery engine (home)
// -----------------------------------------------------------------------------
//  NOT a feed, NOT a catalogue. A curated engine that answers "what is genuinely
//  worth my time for my child today?". A small, high-relevance hero, ParentVeda
//  Originals rails (Growing This Month · Weekend With Your Child · Before They
//  Grow Out Of It · Hidden Indian Gems · Community Loves), Continue Exploring,
//  Smart Collections and a calm category browse - every pick explains WHY it is
//  here. Personalised live from the child's age + current leap and from what the
//  parent has saved/watched/read. Reached from the Explore drawer.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_phases_data.dart';
import 'pp_reco_data.dart';
import 'reco_category_screen.dart';
import 'reco_collection_screen.dart';
import 'reco_common.dart';
import 'reco_detail_screen.dart';
import 'reco_library_screen.dart';
import 'reco_search_screen.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));
  void _open(BuildContext c, RecoItem it) => _push(c, RecoDetailScreen(item: it));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: RecoStore.instance,
            builder: (context, _) {
              final child = ChildProfileStore.instance;
              final ctx = RecoContext.build();
              final today = recommendedToday(count: 7);
              final cont = RecoStore.instance.continueExploring;

              return ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 96),
                children: [
                  _pad(Row(children: [
                    Expanded(child: ppBack(context, 'Explore')),
                    _iconBtn(Icons.search_rounded, () => _push(context, const RecoSearchScreen())),
                    const SizedBox(width: 6),
                    _iconBtn(Icons.bookmark_border_rounded, () => _push(context, const RecoLibraryScreen())),
                  ])),

                  const SizedBox(height: 18),
                  _pad(ppEyebrow('ParentVeda Recommendations', color: ppPurple)),
                  const SizedBox(height: 8),
                  _pad(Text('Chosen for ${child.name}', style: ppFraunces(31, h: 1.1))),
                  const SizedBox(height: 8),
                  _pad(Text('Not a catalogue - a handful of trusted, personalised picks. We researched everything, so you don\'t have to.', style: ppBody(14, h: 1.55))),

                  // live context
                  const SizedBox(height: 14),
                  _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                    _ctxPill(Icons.cake_outlined, '${child.ageInMonths} months'),
                    _ctxPill(Icons.auto_awesome, currentPhase(child).name),
                  ])),

                  // HERO - recommended today
                  const SizedBox(height: 26),
                  _pad(_sectionHead(Icons.star_rounded, 'Recommended for ${child.name} today', sub: 'A few things worth your time - and why each one is here.', onMore: () => _openAll(context, 'Recommended today', today))),
                  const SizedBox(height: 14),
                  _rail(context, today, ctx: ctx, width: 226),

                  // continue exploring
                  if (cont.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    _pad(_sectionHead(Icons.history_rounded, 'Continue exploring', onMore: () => _push(context, const RecoLibraryScreen()))),
                    const SizedBox(height: 14),
                    _rail(context, cont),
                  ],

                  // ParentVeda Originals
                  const SizedBox(height: 30),
                  _pad(_sectionHead(Icons.eco_outlined, 'Growing this month', sub: 'What ${child.ageInMonths}-month-olds are learning right now.', onMore: () => _openAll(context, 'Growing this month', growingThisMonth()))),
                  const SizedBox(height: 14),
                  _rail(context, growingThisMonth(), ctx: ctx),

                  const SizedBox(height: 30),
                  _pad(_sectionHead(Icons.weekend_outlined, 'Weekend with your child', sub: 'Books, activities and outings for the two days ahead.', onMore: () => _openAll(context, 'Weekend with your child', weekendPicks()))),
                  const SizedBox(height: 14),
                  _rail(context, weekendPicks()),

                  const SizedBox(height: 30),
                  _pad(_sectionHead(Icons.hourglass_bottom_rounded, 'Before they grow out of it', sub: 'Especially lovely now - the window won\'t stay open long.')),
                  const SizedBox(height: 14),
                  _rail(context, beforeTheyGrowOut(), ctx: ctx),

                  const SizedBox(height: 30),
                  _pad(_sectionHead(Icons.temple_hindu_outlined, 'Hidden Indian gems', sub: 'Thoughtful, homegrown discovery.', onMore: () => _openAll(context, 'Hidden Indian gems', hiddenIndianGems()))),
                  const SizedBox(height: 14),
                  _rail(context, hiddenIndianGems()),

                  const SizedBox(height: 30),
                  _pad(_sectionHead(Icons.favorite_border, 'ParentVeda community loves', sub: 'Most-saved by parents - age-weighted, never a popularity contest.', onMore: () => _openAll(context, 'Community loves', communityLoves()))),
                  const SizedBox(height: 14),
                  _rail(context, communityLoves()),

                  // smart collections
                  const SizedBox(height: 30),
                  _pad(_sectionHead(Icons.collections_bookmark_outlined, 'Smart collections', sub: 'Curated sets, not endless browsing.')),
                  const SizedBox(height: 14),
                  _collectionsRail(context),

                  // browse categories
                  const SizedBox(height: 30),
                  _pad(_sectionHead(Icons.grid_view_rounded, 'Browse by category')),
                  const SizedBox(height: 14),
                  _pad(Wrap(spacing: 9, runSpacing: 9, children: [
                    for (final c in kRecoCategories) _catChip(context, c.$1, c.$2),
                  ])),

                  const SizedBox(height: 24),
                  _pad(Text('Every recommendation is curated by ParentVeda editors and tuned to ${child.name} - balanced, evidence-first, never sponsored.',
                      textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: ppHair)),
          child: Icon(icon, size: 20, color: ppInk),
        ),
      );

  Widget _ctxPill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: ppPurple),
          const SizedBox(width: 6),
          Text(label, style: ppBody(12, color: ppInk, w: FontWeight.w700)),
        ]),
      );

  //  Every rail gets a way through to the whole set. A horizontal rail showing
  //  six of forty items, with no exit, quietly tells a parent that six is all
  //  there is.
  /// The whole set behind a rail, as a plain vertical list. Deliberately not a
  /// new browsing experience - just the same picks, all of them, scrollable.
  void _openAll(BuildContext context, String title, List<RecoItem> items) =>
      _push(context, _RecoAllScreen(title: title, items: items));

  Widget _sectionHead(IconData icon, String title, {String? sub, VoidCallback? onMore}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: ppPurple),
          const SizedBox(width: 9),
          Expanded(child: Text(title, style: ppJakarta(17), maxLines: 2, overflow: TextOverflow.ellipsis)),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                Text('View more', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 17, color: ppPurple),
              ]),
            ),
        ]),
        if (sub != null) ...[
          const SizedBox(height: 5),
          Text(sub, style: ppBody(12.5, color: ppMuted, h: 1.4)),
        ],
      ]);

  Widget _rail(BuildContext context, List<RecoItem> items, {RecoContext? ctx, double width = 214}) {
    if (items.isEmpty) {
      return _pad(Text('More coming soon for this stage.', style: ppBody(13, color: ppMuted)));
    }
    return SizedBox(
      height: 292,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => RecoRailCard(
          item: items[i],
          width: width,
          reason: ctx != null ? recoReason(items[i], ctx) : null,
          onTap: () => _open(context, items[i]),
        ),
      ),
    );
  }

  Widget _collectionsRail(BuildContext context) => SizedBox(
        height: 128,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: kRecoCollections.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final c = kRecoCollections[i];
            return GestureDetector(
              onTap: () => _push(context, RecoCollectionScreen(collection: c)),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 190,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFE6D8F1)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(c.icon, size: 22, color: ppPurple),
                  const Spacer(),
                  Text(c.title, style: ppJakarta(14).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('${c.items.length} picks', style: ppBody(11, color: ppSoft, w: FontWeight.w700)),
                ]),
              ),
            );
          },
        ),
      );

  Widget _catChip(BuildContext context, String name, IconData icon) => GestureDetector(
        onTap: () => _push(context, RecoCategoryScreen(category: name)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: ppHair)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 15, color: ppPurple),
            const SizedBox(width: 7),
            Text(name, style: ppBody(12.5, color: ppInk, w: FontWeight.w600)),
          ]),
        ),
      );
}

/// Every item behind a rail, in one vertical list.
class _RecoAllScreen extends StatelessWidget {
  const _RecoAllScreen({required this.title, required this.items});
  final String title;
  final List<RecoItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: ppBack(context, 'Recommendations')),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(title, style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('${items.length} ${items.length == 1 ? 'pick' : 'picks'}', style: ppBody(12.5, color: ppMuted)),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                for (final r in items)
                  RecoRow(
                    item: r,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => RecoDetailScreen(item: r)),
                    ),
                  ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

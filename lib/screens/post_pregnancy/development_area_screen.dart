// =============================================================================
//  DevelopmentAreaScreen - one area's story (description → skills → go deeper)
// -----------------------------------------------------------------------------
//  Opened from a Child-Snapshot tile (Brain / Physical / Language / Emotional)
//  and from Development. Structure:
//    • a real 2-3 paragraph description of the area,
//    • its skills as clickable boxes (each opens the skill in full),
//    • "Go deeper" = three rails, always: Watch, Learn and Explore products,
//      each a horizontal scroll with a "View more" that opens the matching
//      screen filtered to THIS area.
//  (Nutrition keeps its own Food home - it is not one of these area screens.)
// =============================================================================

import 'package:flutter/material.dart';

import 'dev_stage_detail_screen.dart';
import 'development_activity_screen.dart';
// devWordPill retired with the confusing "Growing" tag. Kept for revert.
// import 'development_common.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'pp_products_data.dart';
import 'pp_reading_data.dart';
import 'pp_watch_data.dart';
import 'product_detail_screen.dart';
import 'products_category_screen.dart';
import 'reading_collection_screen.dart';
import 'reading_reader_screen.dart';
import 'watch_category_screen.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class DevelopmentAreaScreen extends StatelessWidget {
  const DevelopmentAreaScreen({super.key, required this.area});
  final DevArea area;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  Color get _a => area.accent;

  @override
  Widget build(BuildContext context) {
    final videos = watchByCategory(watchCategoryForArea(area.id));
    final collectionId = readCollectionForArea(area.id);
    final reads = articlesInCollection(collectionId);
    final productCat = productCategoryForArea(area.id);
    final products = kPpProducts.where((p) => p.category == productCat).toList();
    final activities = activitiesForArea(area.id);

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            // The back title used to read "Development", so tapping Brain landed you on
            // a page headed with a word you did not tap. It now names what you opened.
            _pad(ppBack(context, area.name)),
            const SizedBox(height: 16),
            _pad(Row(children: [
              Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: _a.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)), child: Icon(area.icon, size: 24, color: _a)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(area.name, style: ppFraunces(24, h: 1.1)),
                const SizedBox(height: 4),
                // Was a "Growing" pill next to the stage name, which read as two
              // competing labels - it was unclear whether "Growing" was a tag,
              // a toggle, or a different thing from "Cause & effect". One plain
              // line instead, saying what is actually happening right now.
              Text('This week: ${area.stage}',
                  style: ppBody(12.5, color: _a, w: FontWeight.w700),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ])),
            ])),

            // description (2–3 paragraphs)
            const SizedBox(height: 18),
            for (final p in area.description) ...[
              _pad(Text(p, style: ppBody(14.5, color: ppInk, h: 1.65))),
              const SizedBox(height: 12),
            ],

            // brain window
            const SizedBox(height: 6),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _a.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.psychology_outlined, size: 17, color: _a),
                const SizedBox(width: 11),
                Expanded(child: Text(area.brainNote, style: ppBody(13, color: ppInk, h: 1.55))),
              ]),
            )),

            // skills as clickable boxes
            const SizedBox(height: 26),
            _pad(Text('${area.name} skills timeline', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('Mastered, practising now, and what is coming - tap any skill to understand it and how to help.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(Column(children: [
              for (final s in area.journey) _skillBox(context, s),
            ])),

            // go deeper - three rails
            _pad(ppSectionDivider()),
            _pad(Text('Go deeper', style: ppJakarta(18))),

            // Activities lead "Go deeper": watching and reading are useful, but
            // the thing a parent can DO with the baby this afternoon is what
            // actually moves a skill along.
            const SizedBox(height: 18),
            _railHeader(context, 'Try together', null),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              _pad(_emptyRail('Activities for this area are on the way.'))
            else
              _activityRail(context, activities),

            const SizedBox(height: 24),
            _railHeader(context, 'Watch', videos.isEmpty ? null : () => _push(context, WatchCategoryScreen(category: watchCategoryForArea(area.id)))),
            const SizedBox(height: 12),
            if (videos.isEmpty) _pad(_emptyRail('Videos for this area are on the way.')) else _watchRail(context, videos),

            const SizedBox(height: 24),
            _railHeader(context, 'Learn', reads.isEmpty ? null : () => _push(context, ReadingCollectionScreen(collection: readCollectionById(collectionId)))),
            const SizedBox(height: 12),
            if (reads.isEmpty) _pad(_emptyRail('Reads for this area are on the way.')) else _readRail(context, reads),

            const SizedBox(height: 24),
            _railHeader(context, 'Explore products', products.isEmpty ? null : () => _push(context, ProductsCategoryScreen(category: productCat))),
            const SizedBox(height: 12),
            if (products.isEmpty) _pad(_emptyRail('Product picks for this area are on the way.')) else _productRail(context, products),
          ],
        ),
      ),
    );
  }

  // ---- skill box ----------------------------------------------------------
  Widget _skillBox(BuildContext context, DevStage s) {
    // Colour carries the timeline, so the path is readable at a glance without
    // reading a word: settled green behind him, warm amber for what he is
    // working on now, muted for what has not arrived yet.
    const done = Color(0xFF3E7A52);
    const doneBg = Color(0xFFEDF5EE);
    const nowInk = Color(0xFF9A6B12);
    const nowBg = Color(0xFFFDF4E3);
    final (label, color, bg, border) = switch (s.status) {
      'mastered' => ('Mastered', done, doneBg, done.withValues(alpha: 0.28)),
      'current' => ('Practising now', nowInk, nowBg, nowInk.withValues(alpha: 0.42)),
      'next' => ('Coming next', ppSoft, Colors.white, ppHair),
      _ => ('Further ahead', ppMuted, Colors.white, ppHair),
    };
    return GestureDetector(
      onTap: () => _push(context, DevStageDetailScreen(area: area, stage: s, kindLabel: 'Skill')),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: s.status == 'current' ? 1.4 : 1),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(s.name, style: ppJakarta(15, color: s.status == 'future' ? ppMuted : ppInk), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                Text(label.toUpperCase(), style: ppBody(9, color: color, w: FontWeight.w800).copyWith(letterSpacing: 0.5)),
              ]),
              const SizedBox(height: 5),
              Text(s.meaning, style: ppBody(13, color: s.status == 'future' ? ppMuted : ppInk, h: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );
  }

  // ---- rails --------------------------------------------------------------
  Widget _railHeader(BuildContext context, String title, VoidCallback? onViewMore) => _pad(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: ppJakarta(16)),
          if (onViewMore != null)
            GestureDetector(
              onTap: onViewMore,
              behavior: HitTestBehavior.opaque,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('View more', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_forward, size: 14, color: ppPurple),
              ]),
            ),
        ],
      ));

  Widget _emptyRail(String msg) => Text(msg, style: ppBody(13, color: ppMuted));

  Widget _railThumb(IconData icon, {String? badge}) => Container(
        height: 96,
        decoration: BoxDecoration(color: _a.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.center,
        child: Stack(children: [
          Center(child: Icon(icon, size: 30, color: _a)),
          if (badge != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
                child: Text(badge, style: ppBody(9.5, color: Colors.white, w: FontWeight.w700)),
              ),
            ),
        ]),
      );

  Widget _watchRail(BuildContext context, List<WatchVideo> videos) => SizedBox(
        height: 176,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: videos.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final v = videos[i];
            return GestureDetector(
              onTap: () => _push(context, v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v)),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 178,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _railThumb(Icons.play_circle_outline, badge: v.durationLabel),
                  const SizedBox(height: 9),
                  Text(v.title, style: ppJakarta(13.5).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(v.expert.name, style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            );
          },
        ),
      );

  Widget _readRail(BuildContext context, List<ReadArticle> reads) => SizedBox(
        height: 176,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: reads.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final a = reads[i];
            return GestureDetector(
              onTap: () => _push(context, ReadingReaderScreen(article: a)),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 178,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _railThumb(Icons.menu_book_outlined, badge: '${a.minutes} min'),
                  const SizedBox(height: 9),
                  Text(a.title, style: ppJakarta(13.5).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(a.author, style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            );
          },
        ),
      );

  Widget _activityRail(BuildContext context, List<DevActivity> items) => SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final a = items[i];
            return GestureDetector(
              onTap: () => _push(context, DevelopmentActivityScreen(activity: a)),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 168,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _railThumb(Icons.toys_outlined, badge: '${a.minutes} min'),
                  const SizedBox(height: 8),
                  Text(a.title, style: ppJakarta(13.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Expanded(
                    child: Text(a.benefit, style: ppBody(11.5, color: ppSoft, h: 1.35), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),
            );
          },
        ),
      );

  Widget _productRail(BuildContext context, List<PpProduct> products) => SizedBox(
        height: 176,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final p = products[i];
            return GestureDetector(
              onTap: () => _push(context, ProductDetailScreen(product: p)),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 178,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _railThumb(Icons.shopping_bag_outlined),
                  const SizedBox(height: 9),
                  Text(p.name, style: ppJakarta(13.5).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('${p.brand} · ★ ${p.rating}', style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            );
          },
        ),
      );
}

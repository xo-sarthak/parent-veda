// =============================================================================
//  LeapDefinitionScreen - one developmental leap, in full
// -----------------------------------------------------------------------------
//  The single detailed page for any leap (Wonder Weeks). Reused by: the My Child
//  header ("read the full description"), the "Looking ahead → next leap" line,
//  and every entry in the Leap Calendar. Shows the leap's window (as real dates
//  from the child's DOB), what he's working on, the sunny side, the full sectioned
//  description, and cross-links (video, reads, products). Honest, warm, no jargon.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_leaps_data.dart';
import 'pp_products_data.dart';
import 'pp_reading_data.dart';
import 'pp_watch_data.dart';
import 'product_detail_screen.dart';
import 'reading_reader_screen.dart';
import 'watch_player_screen.dart';

const List<String> _kMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String _fmt(DateTime d) => '${d.day} ${_kMonths[d.month - 1]}';

class LeapDefinitionScreen extends StatelessWidget {
  const LeapDefinitionScreen({super.key, required this.leap});
  final Leap leap;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  Color get _a => leap.accent;

  @override
  Widget build(BuildContext context) {
    final child = ChildProfileStore.instance;
    final isCurrent = currentLeap(child).number == leap.number;
    final start = leap.startDate(child.dob);
    final end = leap.endDate(child.dob);

    final articles = leap.articleIds.map(readArticleById).toList();
    final products = leap.productIds.map(productById).toList();
    final video = leap.videoId != null ? watchVideoById(leap.videoId!) : null;

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 44),
          children: [
            // hero
            Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 26),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_a, Color.lerp(_a, Colors.black, 0.32)!]),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, size: 16, color: Colors.white)),
                  ),
                  if (isCurrent)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('LIVE NOW', style: ppBody(10, color: Colors.white, w: FontWeight.w700).copyWith(letterSpacing: 1.0)),
                    ]),
                ]),
                const SizedBox(height: 22),
                Text(leap.character.toUpperCase(), style: ppBody(11, color: Colors.white.withValues(alpha: 0.85), w: FontWeight.w700).copyWith(letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text(leap.label, style: ppFraunces(40, color: Colors.white, h: 1.0)),
                const SizedBox(height: 6),
                Text(leap.name, style: ppBody(16, color: Colors.white.withValues(alpha: 0.92))),
                const SizedBox(height: 16),
                Row(children: [
                  const Icon(Icons.event_outlined, size: 15, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(child: Text('${_fmt(start)} – ${_fmt(end)}  ·  ${leap.monthsLabel}', style: ppBody(12.5, color: Colors.white.withValues(alpha: 0.92), w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ]),
            ),

            const SizedBox(height: 22),
            _pad(Text(leap.tagline, style: ppFraunces(20, h: 1.3))),
            const SizedBox(height: 12),
            _pad(Text(leap.summary, style: ppBody(14.5, color: ppInk, h: 1.6))),

            // what he's working on
            const SizedBox(height: 24),
            _pad(Text("What he's working on", style: ppJakarta(17))),
            const SizedBox(height: 12),
            _pad(Column(children: [
              for (final w in leap.workingOn)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.auto_awesome_outlined, size: 18, color: _a),
                    const SizedBox(width: 13),
                    Expanded(child: Text(w, style: ppBody(14, color: ppInk, w: FontWeight.w600, h: 1.4))),
                  ]),
                ),
            ])),

            // sunny side
            const SizedBox(height: 12),
            _pad(Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF6E6), Color(0xFFF6EED9)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.wb_sunny_rounded, size: 16, color: ppBrown),
                  const SizedBox(width: 8),
                  ppEyebrow('On the sunny side', color: ppBrown, spacing: 0.8),
                ]),
                const SizedBox(height: 8),
                Text(leap.sunnySide, style: ppBody(14, color: ppInk, h: 1.6)),
              ]),
            )),

            // full description
            for (final s in leap.sections) ...[
              const SizedBox(height: 24),
              _pad(Text(s.heading, style: ppJakarta(17))),
              const SizedBox(height: 10),
              for (final p in s.paragraphs) ...[
                _pad(Text(p, style: ppBody(14.5, color: ppInk, h: 1.65))),
                const SizedBox(height: 12),
              ],
            ],

            // leap video
            if (video != null) ...[
              _pad(ppSectionDivider()),
              _pad(Text('Watch', style: ppJakarta(17))),
              const SizedBox(height: 12),
              _pad(GestureDetector(
                onTap: () => _push(context, WatchPlayerScreen(video: video)),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
                  child: Row(children: [
                    Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: _a.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.play_arrow_rounded, size: 22, color: _a)),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(video.title, style: ppBody(14, color: ppInk, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${video.durationLabel} · ${video.expert.name}', style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                    const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
                  ]),
                ),
              )),
            ],

            // reads
            if (articles.isNotEmpty) ...[
              const SizedBox(height: 22),
              _pad(Text('Read more', style: ppJakarta(17))),
              const SizedBox(height: 12),
              for (final a in articles)
                _pad(GestureDetector(
                  onTap: () => _push(context, ReadingReaderScreen(article: a)),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
                    child: Row(children: [
                      Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.menu_book_outlined, size: 20, color: ppPurple)),
                      const SizedBox(width: 13),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.title, style: ppBody(14, color: ppInk, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${a.minutes} min read', style: ppBody(12, color: ppMuted)),
                      ])),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
                    ]),
                  ),
                )),
            ],

            // products
            if (products.isNotEmpty) ...[
              const SizedBox(height: 22),
              _pad(Text('Might help', style: ppJakarta(17))),
              const SizedBox(height: 12),
              for (final p in products)
                _pad(GestureDetector(
                  onTap: () => _push(context, ProductDetailScreen(product: p)),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
                    child: Row(children: [
                      Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.shopping_bag_outlined, size: 20, color: ppPurple)),
                      const SizedBox(width: 13),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, style: ppBody(14, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${p.brand} · ${p.category}', style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ])),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
                    ]),
                  ),
                )),
            ],

            const SizedBox(height: 22),
            _pad(Text("Based on the Wonder Weeks framework, tuned for Indian homes. Every baby's timing varies by a week or two.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }
}

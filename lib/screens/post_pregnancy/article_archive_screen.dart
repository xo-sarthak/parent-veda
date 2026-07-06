// =============================================================================
//  ArticleArchiveScreen — Articles · browsable archive (parenting · S20·archive)
// -----------------------------------------------------------------------------
//  "Everything we've written, to browse at your pace." A search bar, topic +
//  age-band filters, an Article-of-the-day feature and a list. An SEO / casual-
//  browse surface — never promoted on the home. Reached from the Explore drawer;
//  opens the reader. Faithful build of Claude Design · S20·archive.
// =============================================================================

import 'package:flutter/material.dart';

import 'article_reader_screen.dart';
import 'pp_articles_data.dart';
import 'pp_common.dart';

class ArticleArchiveScreen extends StatefulWidget {
  const ArticleArchiveScreen({super.key});

  @override
  State<ArticleArchiveScreen> createState() => _ArticleArchiveScreenState();
}

class _ArticleArchiveScreenState extends State<ArticleArchiveScreen> {
  String _topic = 'All';
  String _age = '3–6 mo';

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _open(Article a) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ArticleReaderScreen(article: a)));

  @override
  Widget build(BuildContext context) {
    final list = filterArticles(topic: _topic, age: _age);
    final feats = list.where((a) => a.featured).toList();
    final featured = feats.isNotEmpty ? feats.first : null;
    final rows = featured != null ? list.where((a) => a.id != featured.id).toList() : list;

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Explore')),

            const SizedBox(height: 20),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Articles', style: ppJakarta(24)),
              const SizedBox(height: 4),
              Text("Everything we've written, to browse at your pace.", style: ppBody(13)),
            ])),

            // search
            const SizedBox(height: 18),
            _pad(GestureDetector(
              onTap: _soon,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppLine)),
                child: Row(children: [
                  const Icon(Icons.search_rounded, size: 17, color: ppMuted),
                  const SizedBox(width: 11),
                  Text('Search articles', style: ppBody(14, color: ppMuted)),
                ]),
              ),
            )),

            // topic chips
            const SizedBox(height: 16),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [for (final t in kArticleTopics) _topicChip(t)],
              ),
            ),
            // age chips
            const SizedBox(height: 9),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [for (final ag in kArticleAges) _ageChip(ag)],
              ),
            ),

            const SizedBox(height: 22),
            if (list.isEmpty)
              _pad(Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                child: Text('No articles for this filter yet — try another topic or age.',
                    textAlign: TextAlign.center, style: ppBody(13, color: ppMuted)),
              ))
            else ...[
              if (featured != null) ...[
                _pad(ppEyebrow('Article of the day', spacing: 1.0)),
                const SizedBox(height: 12),
                _pad(_featured(featured)),
              ],
              for (int i = 0; i < rows.length; i++)
                _pad(_row(rows[i], top: featured != null || i > 0, bottom: i == rows.length - 1)),
            ],

            const SizedBox(height: 22),
            _pad(Text("This archive exists for browsing and search — it's never surfaced on the home screen. Articles reach you where they're relevant.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _topicChip(String t) {
    final on = _topic == t;
    return GestureDetector(
      onTap: () => setState(() => _topic = t),
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: ppBody(12, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  Widget _ageChip(String ag) {
    final on = _age == ag;
    return GestureDetector(
      onTap: () => setState(() => _age = ag),
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: on ? const Color(0xFFECE5F2) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: on ? null : Border.all(color: ppLine),
        ),
        child: Text(ag, style: ppBody(12, color: on ? ppPurple : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  Widget _featured(Article a) => GestureDetector(
        onTap: () => _open(a),
        behavior: HitTestBehavior.opaque,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PpStriped(height: 150, radius: 18, border: true),
          const SizedBox(height: 12),
          _catLine(a),
          const SizedBox(height: 6),
          Text(a.title, style: ppJakarta(18).copyWith(height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text('${a.author} · ${a.readMin} min read', style: ppBody(13)),
          const SizedBox(height: 18),
        ]),
      );

  Widget _row(Article a, {bool top = false, bool bottom = false}) => GestureDetector(
        onTap: () => _open(a),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
            ),
          ),
          child: Row(children: [
            const PpStriped(height: 64, width: 76, radius: 14, border: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _catLine(a),
                const SizedBox(height: 4),
                Text(a.title, style: ppJakarta(15).copyWith(height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${a.readMin} min read', style: ppBody(12, color: ppMuted)),
              ]),
            ),
          ]),
        ),
      );

  Widget _catLine(Article a) => Row(children: [
        Text(a.category.toUpperCase(),
            style: ppBody(10, color: a.categoryColor, w: FontWeight.w700).copyWith(letterSpacing: 0.5)),
        const SizedBox(width: 7),
        Text('· ${a.age}', style: ppBody(11, color: ppMuted)),
      ]);
}

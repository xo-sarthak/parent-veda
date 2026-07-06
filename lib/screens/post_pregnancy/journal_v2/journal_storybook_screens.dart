// =============================================================================
//  My Journal V2 — the Storybook (the hero)
// -----------------------------------------------------------------------------
//  A single book's page (cover + chapters) and an immersive paper reader: title
//  page, contents, chapter dividers, photo/text spreads, a timeline page and an
//  end page — warm heirloom paper, elegant serif type, no green. Reader controls
//  (Previous · Contents · Next) with a live page counter. (Phase 2 adds page-curl,
//  full-screen, monthly covers and the contents/bookmarks nav sheet.)
// =============================================================================

import 'package:flutter/material.dart';

import 'jv2_common.dart';
import 'jv2_data.dart';

// ---- Storybook (a single book's landing page) -------------------------------
class StorybookScreen extends StatelessWidget {
  const StorybookScreen({super.key, this.book = jvOurStory});
  final JvStorybook book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 40),
        children: [
          jvPad(jvTopBar(context, title: book.title)),
          const SizedBox(height: 26),
          Center(child: JvBookCover(width: 150, height: 200, title: book.title.toUpperCase(), since: jvBornSince)),
          const SizedBox(height: 22),
          Center(child: Text('$jvBornSince · ${book.detail} · ${jvChapters.length} chapters', style: ppBody(12, color: ppMuted))),
          const SizedBox(height: 20),
          jvPad(jvButton('Continue reading', () => _openReader(context, 0), trailing: Icons.auto_stories_outlined)),
          const SizedBox(height: 26),
          jvPad(Text('Chapters', style: ppJakarta(15, color: ppMuted))),
          const SizedBox(height: 4),
          for (var i = 0; i < jvChapters.length; i++) jvPad(_chapterRow(context, jvChapters[i], i)),
        ],
      ),
    );
  }

  Widget _chapterRow(BuildContext context, JvChapter c, int i) => GestureDetector(
        onTap: () => _openReader(context, i),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ppHair))),
          child: Row(children: [
            JvPhoto(seed: c.seed, height: 46, width: 46, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (c.label != null) Text(c.label!.toUpperCase(), style: ppBody(9, color: jvSepia, w: FontWeight.w700).copyWith(letterSpacing: 1)),
                Text(c.title, style: ppJakarta(15)),
              ]),
            ),
            Text('p.${c.page}', style: ppBody(12, color: ppMuted)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
          ]),
        ),
      );

  void _openReader(BuildContext context, int chapterIndex) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => StorybookReaderScreen(startPage: jvChapterPages[chapterIndex.clamp(0, jvChapterPages.length - 1)])));
}

// ---- the immersive reader ---------------------------------------------------
// jvChapters[i] → the reader page it opens at (Contents nav + chapter taps).
const List<int> jvChapterPages = [0, 2, 7, 8, 9, 10, 11];

class StorybookReaderScreen extends StatefulWidget {
  const StorybookReaderScreen({super.key, this.startPage = 0});
  final int startPage;

  @override
  State<StorybookReaderScreen> createState() => _StorybookReaderScreenState();
}

class _StorybookReaderScreenState extends State<StorybookReaderScreen> {
  late final PageController _ctrl;
  late int _page;
  bool _immersive = false; // tap a page to hide the chrome and read full-screen
  final Set<int> _bookmarks = {};

  // (chapter label in the bar, page) — varied templates per spec, no repeats.
  late final List<(String, Widget)> _pages = [
    ('Our Story', _titlePage()),
    ('Contents', _contentsPage()),
    ('Chapter One', _chapterPage('Chapter One', 'Tiny Beginnings', 'The smallest feet leave the biggest footprints.')),
    ('Tiny Beginnings', _spread(jvMemories[2], photoTop: true)),
    ('Tiny Beginnings', _fullBleed(3, 'First steps in the sand', 'You chased every wave and did not want to leave.', '5 May 2025')),
    ('Tiny Beginnings', _spread(jvMemories[4], photoTop: false)),
    ('A month to remember', _monthlyPage()),
    ('Chapter Two', _chapterPage('Chapter Two', 'Growing Together', 'Every ordinary day with you becomes a page worth keeping.')),
    ('Growing Together', _collagePage()),
    ('Growing Together', _fullBleed(1, 'You and Bruno', 'Best friends, forever.', '12 July 2025')),
    ('Growing Together', _quotePage()),
    ('Timeline', _timelinePage()),
    ('The End', _endPage()),
  ];

  @override
  void initState() {
    super.initState();
    _page = widget.startPage.clamp(0, _pages.length - 1);
    _ctrl = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _go(int i) {
    final t = i.clamp(0, _pages.length - 1);
    _ctrl.animateToPage(t, duration: const Duration(milliseconds: 420), curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarked = _bookmarks.contains(_page);
    return Scaffold(
      backgroundColor: const Color(0xFFEDE4D3), // the "table" the book rests on
      body: SafeArea(
        child: Stack(children: [
          // pages — tap toggles immersive full-screen reading
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _immersive = !_immersive),
              behavior: HitTestBehavior.opaque,
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _turn(i, _paper(_pages[i].$2)),
              ),
            ),
          ),
          // top chrome
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: _immersive,
              child: AnimatedOpacity(
                opacity: _immersive ? 0 : 1,
                duration: const Duration(milliseconds: 220),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  color: const Color(0xFFEDE4D3),
                  child: Row(children: [
                    GestureDetector(onTap: () => Navigator.of(context).maybePop(), behavior: HitTestBehavior.opaque, child: const Icon(Icons.arrow_back, size: 22, color: ppInk)),
                    Expanded(child: Text(_pages[_page].$1, textAlign: TextAlign.center, style: ppJakarta(14, color: ppInk), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    GestureDetector(
                      onTap: () => setState(() => bookmarked ? _bookmarks.remove(_page) : _bookmarks.add(_page)),
                      behavior: HitTestBehavior.opaque,
                      child: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 22, color: bookmarked ? ppCoral : ppInk),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          // bottom chrome
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: _immersive,
              child: AnimatedOpacity(
                opacity: _immersive ? 0 : 1,
                duration: const Duration(milliseconds: 220),
                child: Container(
                  color: const Color(0xFFEDE4D3),
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${_page + 1} / ${_pages.length}', style: ppBody(12, color: ppSoft, w: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        _ctrlBtn(Icons.chevron_left_rounded, 'Previous', () => _go(_page - 1)),
                        _ctrlBtn(Icons.menu_book_outlined, 'Contents', _openNav),
                        _ctrlBtn(Icons.chevron_right_rounded, 'Next', () => _go(_page + 1)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // page-turn depth: a page tilts around its inner edge as it moves (calm).
  Widget _turn(int i, Widget child) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          double v = (_page - i).toDouble();
          if (_ctrl.hasClients && _ctrl.position.haveDimensions && _ctrl.page != null) v = _ctrl.page! - i;
          v = v.clamp(-1.0, 1.0);
          return Transform(
            alignment: v <= 0 ? Alignment.centerRight : Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(v * 0.30),
            child: Opacity(opacity: (1 - v.abs() * 0.35).clamp(0.0, 1.0), child: child),
          );
        },
      );

  // ---- contents / bookmarks navigation sheet --------------------------------
  void _openNav() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        int tab = 0;
        return StatefulBuilder(builder: (ctx, setSheet) {
          void jump(int idx) {
            Navigator.of(ctx).pop();
            _go(idx);
          }

          final marks = _bookmarks.toList()..sort();
          return SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
                  child: Row(children: [
                    _navTab('Contents', tab == 0, () => setSheet(() => tab = 0)),
                    const SizedBox(width: 22),
                    _navTab('Bookmarks', tab == 1, () => setSheet(() => tab = 1)),
                  ]),
                ),
                const Divider(height: 1, color: ppHair),
                Flexible(
                  child: tab == 0
                      ? ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          children: [for (var i = 0; i < jvChapters.length; i++) _navRow(jvChapters[i].seed, jvChapters[i].label, jvChapters[i].title, jvChapters[i].page, () => jump(jvChapterPages[i]))],
                        )
                      : marks.isEmpty
                          ? Padding(padding: const EdgeInsets.all(40), child: Center(child: Text('Tap the bookmark on any page to save your place.', textAlign: TextAlign.center, style: ppBody(13, color: ppMuted, h: 1.5))))
                          : ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              children: [for (final idx in marks) _navRow(idx % 6, 'Bookmark', _pages[idx].$1, idx + 1, () => jump(idx))],
                            ),
                ),
              ]),
            ),
          );
        });
      },
    );
  }

  Widget _navTab(String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(children: [
          Text(label, style: ppBody(14, color: on ? ppInk : ppMuted, w: on ? FontWeight.w700 : FontWeight.w500)),
          const SizedBox(height: 6),
          Container(height: 2, width: 26, color: on ? ppPurple : Colors.transparent),
        ]),
      );

  Widget _navRow(int seed, String? label, String title, int page, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ppHair))),
          child: Row(children: [
            JvPhoto(seed: seed, height: 40, width: 40, radius: 10),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (label != null) Text(label.toUpperCase(), style: ppBody(9, color: jvSepia, w: FontWeight.w700).copyWith(letterSpacing: 0.8)),
                Text(title, style: ppJakarta(14), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            Text('p.$page', style: ppBody(12, color: ppMuted)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
          ]),
        ),
      );

  Widget _ctrlBtn(IconData icon, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: jvPaper, shape: BoxShape.circle, border: Border.all(color: jvPaperLine)),
            child: Icon(icon, size: 22, color: ppInk),
          ),
          const SizedBox(height: 5),
          Text(label, style: ppBody(10, color: ppSoft, w: FontWeight.w600)),
        ]),
      );

  // ---- paper wrapper (fills the screen in immersive mode) -------------------
  Widget _paper(Widget child) => AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        margin: _immersive ? EdgeInsets.zero : const EdgeInsets.fromLTRB(14, 6, 14, 10),
        decoration: BoxDecoration(
          color: jvPaper,
          borderRadius: BorderRadius.circular(_immersive ? 0 : 10),
          border: _immersive ? null : Border.all(color: jvPaperEdge),
          boxShadow: _immersive ? null : const [BoxShadow(color: Color(0x33000000), blurRadius: 20, spreadRadius: -6, offset: Offset(0, 10))],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );

  // ---- page templates -------------------------------------------------------
  Widget _titlePage() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('OUR STORY', textAlign: TextAlign.center, style: ppFraunces(34, h: 1.1)),
            const SizedBox(height: 12),
            Text(jvChildUpper, style: ppBody(15, color: jvSepia, w: FontWeight.w700).copyWith(letterSpacing: 4)),
            const SizedBox(height: 18),
            Container(width: 44, height: 1, color: jvGold),
            const SizedBox(height: 18),
            Icon(Icons.spa_outlined, size: 22, color: jvGold),
            const SizedBox(height: 18),
            Text(jvBornSince, style: ppBody(12, color: ppMuted)),
          ]),
        ),
      );

  Widget _contentsPage() => Padding(
        padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Contents', style: ppFraunces(30, h: 1.1)),
          const SizedBox(height: 20),
          for (final c in jvChapters)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Text(c.title, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
                Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: const DottedLeader())),
                Text('${c.page}', style: ppBody(13, color: jvSepia, w: FontWeight.w700)),
              ]),
            ),
        ]),
      );

  Widget _chapterPage(String label, String title, String quote) => Center(
        child: Padding(
          padding: const EdgeInsets.all(34),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(label.toUpperCase(), style: ppBody(11, color: jvSepia, w: FontWeight.w700).copyWith(letterSpacing: 2)),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: ppFraunces(30, h: 1.15)),
            const SizedBox(height: 20),
            Icon(Icons.spa_outlined, size: 18, color: jvGold),
            const SizedBox(height: 20),
            Text('"$quote"', textAlign: TextAlign.center, style: ppFraunces(15, color: ppSoft, h: 1.6).copyWith(fontStyle: FontStyle.italic)),
          ]),
        ),
      );

  Widget _spread(JvMemory m, {required bool photoTop}) {
    final photo = JvPhoto(seed: m.seed, radius: 4);
    final text = Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(m.title, style: ppFraunces(24, h: 1.2)),
        const SizedBox(height: 10),
        Text(m.body, style: ppBody(14, color: ppInk, h: 1.7)),
        const SizedBox(height: 14),
        Text('${m.date} · ${m.age}', style: ppBody(11, color: jvSepia, w: FontWeight.w700)),
      ]),
    );
    return Column(children: photoTop
        ? [Expanded(flex: 5, child: SizedBox(width: double.infinity, child: photo)), Expanded(flex: 4, child: text)]
        : [Expanded(flex: 4, child: text), Expanded(flex: 5, child: SizedBox(width: double.infinity, child: photo))]);
  }

  Widget _timelinePage() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 34, 30, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('A Timeline of\nBeautiful Moments', textAlign: TextAlign.center, style: ppFraunces(24, h: 1.25)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(children: [
              for (final ms in jvMilestones.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 9, height: 9, margin: const EdgeInsets.only(top: 5), decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ms.title, style: ppJakarta(15)),
                        const SizedBox(height: 2),
                        Text(ms.date, style: ppBody(12, color: jvSepia)),
                      ]),
                    ),
                  ]),
                ),
            ]),
          ),
        ]),
      );

  Widget _endPage() => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Every ending is the beginning of another beautiful chapter.',
                textAlign: TextAlign.center, style: ppFraunces(22, h: 1.4)),
            const SizedBox(height: 24),
            const Icon(Icons.favorite, size: 20, color: ppCoral),
            const SizedBox(height: 24),
            Text('Thank you for letting us be part of yours.', textAlign: TextAlign.center, style: ppBody(13, color: ppMuted, h: 1.6)),
          ]),
        ),
      );

  // full-bleed photo page with an overlaid caption (immersive-friendly)
  Widget _fullBleed(int seed, String title, String subtitle, String date) => JvPhoto(
        seed: seed,
        dim: true,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 34),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppFraunces(30, color: Colors.white, h: 1.1)),
              const SizedBox(height: 8),
              Text(subtitle, style: ppBody(15, color: Colors.white70, w: FontWeight.w600)),
              const SizedBox(height: 10),
              Text(date, style: ppBody(12, color: Colors.white60)),
            ]),
          ),
        ),
      );

  // auto-generated monthly cover page
  Widget _monthlyPage() => Padding(
        padding: const EdgeInsets.fromLTRB(28, 34, 28, 24),
        child: Column(children: [
          Text(jvMonthlyTitle, textAlign: TextAlign.center, style: ppFraunces(30, h: 1.1)),
          const SizedBox(height: 4),
          Text('A month to remember', style: ppBody(13, color: jvSepia)),
          const SizedBox(height: 20),
          const JvPhoto(seed: 4, height: 92, width: double.infinity, radius: 14),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(children: [
              for (final it in jvMonthlyItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.favorite_border, size: 15, color: ppCoral),
                    const SizedBox(width: 12),
                    Expanded(child: Text(it, style: ppBody(14, color: ppInk, h: 1.5))),
                  ]),
                ),
            ]),
          ),
          Text('18 memories this month', style: ppBody(12, color: ppMuted)),
        ]),
      );

  // a collage page
  Widget _collagePage() => Padding(
        padding: const EdgeInsets.fromLTRB(26, 34, 26, 26),
        child: Column(children: [
          Text('So many little moments', textAlign: TextAlign.center, style: ppFraunces(24, h: 1.2)),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: [for (final s in [2, 3, 4, 5]) JvPhoto(seed: s, radius: 10)],
            ),
          ),
          const SizedBox(height: 14),
          Text('…all at once.', style: ppFraunces(15, color: ppSoft, h: 1.4).copyWith(fontStyle: FontStyle.italic)),
        ]),
      );

  // a quote page
  Widget _quotePage() => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.format_quote_rounded, size: 30, color: jvGold),
            const SizedBox(height: 18),
            Text('The days are long, but the years are short.', textAlign: TextAlign.center, style: ppFraunces(24, h: 1.45).copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            Container(width: 42, height: 1, color: jvGold),
          ]),
        ),
      );
}

/// A dotted leader line for the contents page.
class DottedLeader extends StatelessWidget {
  const DottedLeader({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(height: 1, child: CustomPaint(painter: _DotsPainter(), size: const Size(double.infinity, 1)));
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = jvPaperEdge;
    for (double x = 0; x < size.width; x += 5) {
      canvas.drawCircle(Offset(x, size.height / 2), 0.8, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

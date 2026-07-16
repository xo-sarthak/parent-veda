// =============================================================================
//  Book Companion — the reading experience (Apple Books / Headspace / Medium)
// -----------------------------------------------------------------------------
//  A dedicated screen, deliberately NOT the generic article reader: sticky
//  section navigation, reading progress and a hero are the shape of a book, not
//  of an article, and cramming them into read_reader_screen would have made
//  both worse. Books with a companion route here; everything else is untouched.
//
//  The content hierarchy is fixed by the writing Bible and is not ours to
//  change. Everything below is about readability, discoverability and calm.
//
//  Visual hierarchy is the whole game here — four deliberately different card
//  types, so a reader always knows what kind of thing they are looking at:
//    · editorial  (Core Philosophy)  — the emotional centre, large type
//    · accordion  (Ideas, Chapters)  — light, quiet, content-led
//    · ParentVeda (the Take)         — our own voice, the one tinted card
//    · quote      (Memorable lines)  — centred, oversized quote mark
//
//  Colour is spent on the hero, the Take, the active nav chip and buttons.
//  Nowhere else. An accordion header is never a strong colour: the earlier
//  design used solid purple bars and they shouted over the writing.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/read_item.dart';
import '../services/book_companion_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/read_next_store.dart';
import '../theme/app_theme.dart';

// ---- palette (light-only, matching the app) ---------------------------------
const _bg = Color(0xFFFBF9FE);
const _ink = Color(0xFF2F2C30);
const _soft = Color(0xFF69636C);
const _muted = Color(0xFFA99CBB);
const _line = Color(0xFFE7E2EC);
const _panel = Color(0xFFF4EFF9);

/// Reading never runs edge to edge on a wide screen: past ~65 characters the
/// eye loses the line. Phones are unaffected; tablets stop being unreadable.
const double _maxReadWidth = 620;

class BookCompanionScreen extends StatefulWidget {
  const BookCompanionScreen({super.key, required this.item, required this.controller});

  final ReadItem item;
  final PregnancyController controller;

  @override
  State<BookCompanionScreen> createState() => _BookCompanionScreenState();
}

class _Section {
  const _Section(this.id, this.label);
  final String id;
  final String label;
}

class _BookCompanionScreenState extends State<BookCompanionScreen> {
  final ScrollController _sc = ScrollController();
  final Map<String, GlobalKey> _keys = {};

  /// Suppresses scroll-spy while a chip-tap animation is in flight, so the
  /// highlight does not skip through every section on the way.
  bool _jumping = false;
  String _active = 'overview';

  ReadItem get a => widget.item;
  BookCompanion get c => a.companion!;
  BookCompanionStore get _store => BookCompanionStore.instance;

  late final List<_Section> _sections = [
    const _Section('overview', 'Overview'),
    if (c.ideas.isNotEmpty) const _Section('ideas', 'Ideas'),
    if (c.chapters.isNotEmpty) const _Section('chapters', 'Chapters'),
    if (c.perspective.isNotEmpty) const _Section('take', 'ParentVeda Take'),
    if (c.quotes.isNotEmpty) const _Section('quotes', 'Quotes'),
  ];

  @override
  void initState() {
    super.initState();
    _store.ensureLoaded();
    for (final s in _sections) {
      _keys[s.id] = GlobalKey();
    }
    _sc.addListener(_spy);
  }

  @override
  void dispose() {
    _sc.removeListener(_spy);
    _sc.dispose();
    super.dispose();
  }

  /// Scroll-spy: the active chip is the last section whose top has passed under
  /// the sticky bar. Cheap, and it reads correctly when a long section fills
  /// the viewport.
  void _spy() {
    if (_jumping) return;
    String active = _sections.first.id;
    for (final s in _sections) {
      final ctx = _keys[s.id]?.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy <= 160) active = s.id;
    }
    if (active != _active) setState(() => _active = active);
  }

  Future<void> _jump(String id) async {
    final ctx = _keys[id]?.currentContext;
    if (ctx == null) return;
    setState(() {
      _jumping = true;
      _active = id;
    });
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
    if (mounted) setState(() => _jumping = false);
  }

  Widget _anchor(String id) => SizedBox(key: _keys[id], height: 0, width: double.infinity);

  Widget _read(Widget child) => Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: _maxReadWidth), child: child),
      );

  Widget _pad(Widget child) =>
      _read(Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: child));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) => CustomScrollView(
          controller: _sc,
          slivers: [
            SliverToBoxAdapter(child: _hero()),
            SliverPersistentHeader(pinned: true, delegate: _NavBarDelegate(child: _navBar())),
            SliverToBoxAdapter(child: _body()),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  //  Hero — answers "what is this book?" before a single decision is asked
  // ===========================================================================
  Widget _hero() {
    final saved = ReadNextStore.instance.isSaved(a.id);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3ECFA), _bg],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: _ink),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _cover(),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  a.title,
                  style: GoogleFonts.fraunces(
                    fontSize: 25,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 7),
                Text(a.author, style: GoogleFonts.manrope(fontSize: 13.5, color: _soft, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.schedule_rounded, size: 13, color: _muted),
                  const SizedBox(width: 5),
                  Text(a.readingTime, style: GoogleFonts.manrope(fontSize: 12, color: _muted, fontWeight: FontWeight.w700)),
                ]),
              ]),
            ),
          ]),
          const SizedBox(height: 22),
          if (c.recommendedFor.isNotEmpty) ...[
            _label('RECOMMENDED FOR'),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: [for (final r in c.recommendedFor) _chip(r)]),
            const SizedBox(height: 16),
          ],
          if (c.themes.isNotEmpty) ...[
            _label('THEMES'),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: [for (final t in c.themes) _chip(t, quiet: true)]),
            const SizedBox(height: 20),
          ],
          Row(children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _jump(_sections.length > 1 ? _sections[1].id : 'overview'),
                child: Text(
                  'Read summary',
                  style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 44dp minimum — a save button you have to aim at is a broken one.
            SizedBox(
              width: 52,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: _line, width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  ReadNextStore.instance.toggleSave(a.id);
                  setState(() {});
                },
                child: Icon(
                  saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 20,
                  color: saved ? AppTheme.primary : _soft,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _progress(),
          const SizedBox(height: 18),
        ])),
      ),
    );
  }

  /// A stand-in cover until real art exists. Deliberately typographic rather
  /// than a stock photo — an honest placeholder beats a fake jacket.
  Widget _cover() => Container(
        width: 92,
        height: 132,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A30B6), Color(0xFF4A1F84)],
          ),
          boxShadow: const [BoxShadow(color: Color(0x336A30B6), blurRadius: 18, offset: Offset(0, 8))],
        ),
        padding: const EdgeInsets.all(11),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 22, height: 2, color: Colors.white.withValues(alpha: 0.55)),
          const Spacer(),
          Text(
            a.title,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.fraunces(fontSize: 11.5, height: 1.2, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ]),
      );

  /// Reading progress. "Explored", never "completed": opening an idea is the
  /// whole interaction, and there is nothing here to finish.
  Widget _progress() {
    final ideas = _store.ideasExplored(a.id);
    final chapters = _store.chaptersExplored(a.id);
    return Row(children: [
      _meter('Ideas', ideas, c.ideas.length),
      const SizedBox(width: 22),
      _meter('Chapters', chapters, c.chapters.length),
    ]);
  }

  Widget _meter(String label, int done, int total) {
    if (total == 0) return const SizedBox.shrink();
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: GoogleFonts.manrope(fontSize: 11, color: _soft, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('$done / $total',
              style: GoogleFonts.manrope(fontSize: 11, color: _muted, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: total == 0 ? 0 : done / total),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 4,
              backgroundColor: _line,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ),
      ]),
    );
  }

  // ===========================================================================
  //  Sticky section navigation
  // ===========================================================================
  Widget _navBar() => Container(
        color: _bg,
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            height: 44,
            child: ListView(
              key: const ValueKey('companion-nav'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final s in _sections)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _navChip(s),
                  ),
              ],
            ),
          ),
          Container(height: 1, color: _line),
        ]),
      );

  Widget _navChip(_Section s) {
    final on = _active == s.id;
    return GestureDetector(
      key: ValueKey('navchip-${s.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _jump(s.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: on ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? AppTheme.primary : _line),
        ),
        child: Text(
          s.label,
          style: GoogleFonts.manrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: on ? Colors.white : _soft,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  //  Body
  // ===========================================================================
  Widget _body() => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 60),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _anchor('overview'),
          if (c.about.isNotEmpty) ...[
            _pad(_sectionTitle('What this book is about')),
            const SizedBox(height: 12),
            // Light on purpose: no card, no border. One editorial paragraph.
            _pad(Text(c.about, style: _bodyStyle())),
            const SizedBox(height: 30),
          ],
          if (c.authorIntro.isNotEmpty) ...[
            _pad(_author()),
            const SizedBox(height: 30),
          ],
          if (c.philosophy.isNotEmpty) ...[
            _pad(_philosophy()),
            const SizedBox(height: 34),
          ],
          if (c.ideas.isNotEmpty) ...[
            _anchor('ideas'),
            _pad(_sectionTitle('The most important ideas')),
            const SizedBox(height: 6),
            _pad(Text('Tap any idea to open it.', style: _subStyle())),
            const SizedBox(height: 16),
            for (var i = 0; i < c.ideas.length; i++) _pad(_IdeaCard(
                  key: ValueKey('idea$i'),
                  index: i,
                  idea: c.ideas[i],
                  opened: _store.ideaOpened(a.id, i),
                  onOpen: () => _store.markIdea(a.id, i),
                )),
            const SizedBox(height: 34),
          ],
          if (c.chapters.isNotEmpty) ...[
            _anchor('chapters'),
            _pad(_sectionTitle('Chapter by chapter')),
            const SizedBox(height: 6),
            _pad(Text('Tap a chapter for its key points.', style: _subStyle())),
            const SizedBox(height: 16),
            for (var i = 0; i < c.chapters.length; i++) _pad(_ChapterCard(
                  key: ValueKey('chapter$i'),
                  index: i,
                  chapter: c.chapters[i],
                  opened: _store.chapterOpened(a.id, i),
                  onOpen: () => _store.markChapter(a.id, i),
                )),
            const SizedBox(height: 34),
          ],
          if (c.perspective.isNotEmpty) ...[
            _anchor('take'),
            _pad(_take()),
            const SizedBox(height: 34),
          ],
          if (c.quotes.isNotEmpty) ...[
            _anchor('quotes'),
            _pad(_sectionTitle('Memorable lines')),
            const SizedBox(height: 18),
            for (final q in c.quotes) _pad(_quote(q)),
          ],
        ]),
      );

  Widget _sectionTitle(String s) => Text(
        s,
        style: GoogleFonts.fraunces(
          fontSize: 24,
          height: 1.15,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary900,
          letterSpacing: -0.4,
        ),
      );

  TextStyle _bodyStyle() =>
      GoogleFonts.manrope(fontSize: 16, height: 1.75, color: _ink, letterSpacing: 0.1);

  TextStyle _subStyle() => GoogleFonts.manrope(fontSize: 13, height: 1.5, color: _muted);

  Widget _label(String s) => Text(
        s,
        style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: _muted),
      );

  Widget _chip(String s, {bool quiet = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: quiet ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _line),
        ),
        child: Text(
          s,
          style: GoogleFonts.manrope(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: quiet ? _soft : AppTheme.primary,
          ),
        ),
      );

  // ---- About the author: one line, then chips. Never a biography. -----------
  Widget _author() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('ABOUT THE AUTHOR'),
        const SizedBox(height: 10),
        Text(c.authorIntro, style: GoogleFonts.manrope(fontSize: 14, height: 1.6, color: _soft)),
        if (c.otherBooks.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final b in c.otherBooks) _bookChip(b)]),
        ],
      ]);

  Widget _bookChip(String title) => ConstrainedBox(
        // A long title ("What to Expect Before You're Expecting") must not
        // push the chip past the Wrap's width at large text sizes.
        constraints: const BoxConstraints(maxWidth: 240),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _line),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.menu_book_rounded, size: 12, color: _muted),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(fontSize: 11.5, fontWeight: FontWeight.w600, color: _ink),
              ),
            ),
          ]),
        ),
      );

  // ---- Core philosophy: the emotional centre of the page --------------------
  Widget _philosophy() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('CORE PHILOSOPHY'),
          const SizedBox(height: 14),
          // Large type, generous height. This is the one paragraph a reader
          // should remember if they read nothing else.
          Text(
            c.philosophy,
            style: GoogleFonts.fraunces(
              fontSize: 19,
              height: 1.58,
              fontWeight: FontWeight.w400,
              color: AppTheme.primary900,
              letterSpacing: -0.2,
            ),
          ),
        ]),
      );

  // ---- ParentVeda's Take: our own voice, the one tinted card ---------------
  Widget _take() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7F1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3FA56A).withValues(alpha: 0.22)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF3FA56A)),
            const SizedBox(width: 8),
            Text(
              "PARENTVEDA'S TAKE",
              style: GoogleFonts.manrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: const Color(0xFF2E7D53),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Text(
            c.perspective,
            style: GoogleFonts.fraunces(fontSize: 16, height: 1.65, color: _ink),
          ),
        ]),
      );

  // ---- Quotes: centred, oversized quote mark -------------------------------
  Widget _quote(String q) {
    // The trailing "(On choosing a provider…)" is context, not the quote. Split
    // it out so the line itself can be the thing that carries the card.
    final m = RegExp(r'^(.*?)\s*\((On [^)]*)\)\s*$', dotAll: true).firstMatch(q);
    final line = (m?.group(1) ?? q).trim();
    final context = m?.group(2)?.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(children: [
        Text(
          '“',
          style: GoogleFonts.fraunces(fontSize: 62, height: 1.1, color: AppTheme.primary.withValues(alpha: 0.22)),
        ),
        Text(
          line.replaceAll('"', ''),
          textAlign: TextAlign.center,
          style: GoogleFonts.fraunces(
            fontSize: 18,
            height: 1.5,
            fontStyle: FontStyle.italic,
            color: _ink,
          ),
        ),
        if (context != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(999)),
            child: Text(
              context,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 11, color: _soft, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ]),
    );
  }
}

// =============================================================================
//  Sticky nav delegate
// =============================================================================
class _NavBarDelegate extends SliverPersistentHeaderDelegate {
  _NavBarDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 53;
  @override
  double get maxExtent => 53;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _NavBarDelegate old) => old.child != child;
}

// =============================================================================
//  Accordion cards — light, quiet, content-led.
// -----------------------------------------------------------------------------
//  No coloured header, no heavy fill. The number and chevron carry the
//  affordance; the writing carries the page.
// =============================================================================
class _IdeaCard extends StatefulWidget {
  const _IdeaCard({super.key, required this.index, required this.idea, required this.opened, required this.onOpen});
  final int index;
  final BookKeyIdea idea;
  final bool opened;
  final VoidCallback onOpen;

  @override
  State<_IdeaCard> createState() => _IdeaCardState();
}

class _IdeaCardState extends State<_IdeaCard> {
  bool _open = false;

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) widget.onOpen();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _open ? AppTheme.primary.withValues(alpha: 0.3) : _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                '${widget.index + 1}',
                style: GoogleFonts.fraunces(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: widget.opened ? AppTheme.primary : _muted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.idea.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 240),
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: _muted),
              ),
            ]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // The paragraph is dominant; the pointers are supplementary.
              Text(
                widget.idea.body,
                style: GoogleFonts.manrope(fontSize: 14.5, height: 1.72, color: _ink),
              ),
              if (widget.idea.pointers.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(height: 1, color: _line),
                const SizedBox(height: 16),
                for (final p in widget.idea.pointers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: _muted, shape: BoxShape.circle)),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(p, style: GoogleFonts.manrope(fontSize: 13, height: 1.55, color: _soft)),
                      ),
                    ]),
                  ),
              ],
            ]),
          )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }
}

class _ChapterCard extends StatefulWidget {
  const _ChapterCard({super.key, required this.index, required this.chapter, required this.opened, required this.onOpen});
  final int index;
  final BookChapter chapter;
  final bool opened;
  final VoidCallback onOpen;

  @override
  State<_ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<_ChapterCard> {
  bool _open = false;

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) widget.onOpen();
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.chapter;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _open ? AppTheme.primary.withValues(alpha: 0.3) : _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(
                    ch.title,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14.5, height: 1.3, fontWeight: FontWeight.w700, color: _ink),
                  ),
                ),
                const SizedBox(width: 10),
                if (widget.opened && !_open)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.primary),
                  ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 240),
                  child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: _muted),
                ),
              ]),
              // The teaser never fully summarises the chapter — it is a hook.
              if (!_open) ...[
                const SizedBox(height: 7),
                Text(
                  ch.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 13, height: 1.5, color: _muted),
                ),
              ],
            ]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ch.summary, style: GoogleFonts.manrope(fontSize: 14.5, height: 1.72, color: _ink)),
              if (ch.keyPoints.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(height: 1, color: _line),
                const SizedBox(height: 16),
                Text(
                  'KEY POINTS COVERED',
                  style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: _muted),
                ),
                const SizedBox(height: 14),
                for (final g in ch.keyPoints) ...[
                  if (g.label.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Text(
                        g.label,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w800, color: _ink),
                      ),
                    ),
                  ],
                  for (final p in g.points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: _muted, shape: BoxShape.circle)),
                        ),
                        const SizedBox(width: 11),
                        Expanded(child: Text(p, style: GoogleFonts.manrope(fontSize: 13.5, height: 1.6, color: _soft))),
                      ]),
                    ),
                  const SizedBox(height: 6),
                ],
              ],
            ]),
          )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }
}

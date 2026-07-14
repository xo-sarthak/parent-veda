// =============================================================================
//  ReadReaderScreen - the pregnancy "Learn V2" premium reader
// -----------------------------------------------------------------------------
//  Long-form reading, done with care (Kindle/Medium sensibility), mirroring the
//  post-pregnancy Learn V2 reader (reading_reader_screen.dart) but adapted to the
//  mother/purple theme and the pregnancy ReadItem model. It carries:
//    - a scroll PROGRESS bar,
//    - a TABLE OF CONTENTS (jumps to a block),
//    - a FONT-SIZE control + LIGHT / SEPIA / DARK reading modes,
//    - the two signature blocks: "WHY THIS MATTERS" and "RESEARCH SIMPLIFIED"
//      (plus an optional MYTH vs FACT card),
//    - bookmark + mark-as-read (wired to the same stores as the old reader, so
//      completion still ticks the Home daily-reads state),
//    - a "Read next" chain onward into more pregnancy reads.
//  Pregnancy content only. Self-contained; font/mode prefs live in a small local
//  singleton so they persist across opens within a session.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/read_next_data.dart';
import '../localization/app_language.dart';
import '../models/read_item.dart';
import '../services/pregnancy_controller.dart';
import '../services/read_done_store.dart';
import '../services/read_next_store.dart';

// ---- reader preferences (session-scoped, mirrors PP ReadingStore font/mode) --
enum ReadReaderMode { light, sepia, dark }

class ReadReaderPrefs extends ChangeNotifier {
  ReadReaderPrefs._();
  static final ReadReaderPrefs instance = ReadReaderPrefs._();

  double _fontScale = 1.0;
  ReadReaderMode _mode = ReadReaderMode.light;

  double get fontScale => _fontScale;
  void setFontScale(double v) {
    _fontScale = v.clamp(0.85, 1.35);
    notifyListeners();
  }

  ReadReaderMode get mode => _mode;
  void setMode(ReadReaderMode m) {
    _mode = m;
    notifyListeners();
  }
}

// ---- reading theme (purple-adapted light / sepia / dark) --------------------
class _RTheme {
  const _RTheme(this.bg, this.ink, this.soft, this.panel, this.rule, this.accent);
  final Color bg, ink, soft, panel, rule, accent;
}

const Color _progressColor = Color(0xFFEF6F8E); // coral, matches save heart

class ReadReaderScreen extends StatefulWidget {
  const ReadReaderScreen({super.key, required this.item, required this.controller});
  final ReadItem item;
  final PregnancyController controller;

  @override
  State<ReadReaderScreen> createState() => _ReadReaderScreenState();
}

class _ReadReaderScreenState extends State<ReadReaderScreen> {
  final ScrollController _sc = ScrollController();
  final Map<String, GlobalKey> _keys = {};
  double _progress = 0;

  ReadItem get a => widget.item;
  AppLanguage get _lang => widget.controller.language;
  ReadReaderPrefs get _prefs => ReadReaderPrefs.instance;

  @override
  void initState() {
    super.initState();
    ReadDoneStore.instance.ensureLoaded();
    _sc.addListener(_onScroll);
  }

  @override
  void dispose() {
    _sc.removeListener(_onScroll);
    _sc.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _sc.position.maxScrollExtent;
    final p = max <= 0 ? 1.0 : (_sc.offset / max).clamp(0.0, 1.0);
    if ((p - _progress).abs() > 0.004) setState(() => _progress = p);
  }

  _RTheme get _t {
    switch (_prefs.mode) {
      case ReadReaderMode.sepia:
        return const _RTheme(Color(0xFFF4ECD8), Color(0xFF423A2A), Color(0xFF6E6250),
            Color(0xFFEDE3CB), Color(0xFFE1D6BD), Color(0xFF7A4CC0));
      case ReadReaderMode.dark:
        return const _RTheme(Color(0xFF171320), Color(0xFFE9E5EF), Color(0xFFA9A2B5),
            Color(0xFF241F2E), Color(0xFF322B3D), Color(0xFFB794F6));
      case ReadReaderMode.light:
        return const _RTheme(Color(0xFFFBF9FE), Color(0xFF2A2530), Color(0xFF69636C),
            Color(0xFFF3EEF7), Color(0xFFE4E2E5), Color(0xFF6A30B6));
    }
  }

  double get _fs => _prefs.fontScale;

  TextStyle _bodyStyle(_RTheme t) =>
      GoogleFonts.manrope(fontSize: 16.5 * _fs, height: 1.72, color: t.ink, letterSpacing: 0.1);

  // Inline bilingual helper (app_language.dart is off-limits for edits).
  String _tr(String en, String hin) => _lang == AppLanguage.hinglish ? hin : en;

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _soon(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  // The blocks present on this read (for the table of contents), in order.
  List<(String, String)> _tocEntries() {
    final out = <(String, String)>[];
    if (a.hasCompanion) {
      final c = a.companion!;
      if (c.about.isNotEmpty) out.add(('about', _tr('About the book', 'Book ke baare mein')));
      if (c.philosophy.isNotEmpty) out.add(('philosophy', _tr('Core philosophy', 'Mool vichaar')));
      if (c.ideas.isNotEmpty) out.add(('ideas', _tr('Key ideas', 'Zaroori ideas')));
      if (c.perspective.isNotEmpty) out.add(('perspective', _tr('ParentVeda perspective', 'ParentVeda ka nazariya')));
      if (c.chapters.isNotEmpty) out.add(('chapters', _tr('Chapter by chapter', 'Chapter dar chapter')));
      if (c.quotes.isNotEmpty) out.add(('quotes', _tr('Memorable lines', 'Yaadgaar baatein')));
      return out;
    }
    out.add(('read',
        a.type == ReadType.book ? _tr('Why we recommend it', 'Kyun recommend karte hain') : _tr('The read', 'Padhein')));
    if (a.hasWhyThisMatters) out.add(('why', _tr('Why this matters', 'Yeh kyun zaroori hai')));
    if (a.hasResearchSimplified) out.add(('research', _tr('Research simplified', 'Research aasan bhaasha mein')));
    if (a.hasMythFact) out.add(('myth', _tr('Myth vs Fact', 'Myth vs Fact')));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [ReadReaderPrefs.instance, ReadNextStore.instance, ReadDoneStore.instance]),
      builder: (context, _) {
        final t = _t;
        final s = S(_lang);
        return Scaffold(
          backgroundColor: t.bg,
          body: Column(children: [
            SafeArea(bottom: false, child: _topBar(t)),
            // progress bar
            SizedBox(
              height: 2.5,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                    widthFactor: _progress.clamp(0.0, 1.0),
                    child: Container(color: _progressColor)),
              ),
            ),
            Expanded(
              child: ListView(
                controller: _sc,
                padding: const EdgeInsets.only(top: 8, bottom: 48),
                children: _content(t, s),
              ),
            ),
          ]),
        );
      },
    );
  }

  List<Widget> _content(_RTheme t, S s) {
    final isBook = a.type == ReadType.book;
    final bodyText = a.body.trim().isNotEmpty ? a.body : a.why;
    return [
      _pad(Text(a.category.toUpperCase(),
          style: GoogleFonts.manrope(
              fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: t.accent))),
      const SizedBox(height: 12),
      _pad(Text(a.title,
          style: GoogleFonts.fraunces(
              fontSize: 30 * _fs, height: 1.15, fontWeight: FontWeight.w600, color: t.ink))),
      const SizedBox(height: 14),
      _pad(_byline(t)),
      const SizedBox(height: 18),
      _pad(_cover(t)),
      const SizedBox(height: 22),
      // "Why this matters now" - the signature week-timing hook (existing reason).
      _pad(_whyNow(t, s)),
      const SizedBox(height: 22),
      if (a.type == ReadType.expert && a.author.isNotEmpty) ...[
        _pad(Text('${s.rnRecommendedBy} ${a.author} · ${a.authorRole}',
            style: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w700, color: t.accent))),
        const SizedBox(height: 16),
      ],
      // A rich book companion renders its own sections; everything else uses the
      // generic body + signature blocks.
      if (a.hasCompanion)
        ..._companionSections(t)
      else ...[
        // Main body.
        _anchor('read'),
        for (final para in bodyText.split('\n\n'))
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _pad(Text(para.trim(), style: _bodyStyle(t))),
          ),
        // Book meta (rating) sits under the recommendation text.
        if (isBook && a.hasRating) ...[
          const SizedBox(height: 2),
          _pad(_ratingRow(t)),
          const SizedBox(height: 8),
        ],
        // ---- signature blocks -----------------------------------------------
        if (a.hasWhyThisMatters) ...[
          const SizedBox(height: 4),
          _anchor('why'),
          _pad(_infoBlock(t,
              icon: Icons.favorite_border_rounded,
              title: _tr('Why this matters', 'Yeh kyun zaroori hai'),
              body: a.whyThisMatters,
              tint: t.accent)),
          const SizedBox(height: 20),
        ],
        if (a.hasResearchSimplified) ...[
          _anchor('research'),
          _pad(_infoBlock(t,
              icon: Icons.science_outlined,
              title: _tr('Research simplified', 'Research aasan bhaasha mein'),
              body: a.researchSimplified,
              tint: const Color(0xFF3FA56A))),
          const SizedBox(height: 20),
        ],
        if (a.hasMythFact) ...[
          _anchor('myth'),
          _pad(_mythFact(t)),
          const SizedBox(height: 20),
        ],
      ],
      const SizedBox(height: 6),
      _pad(_actions(t, s)),
      const SizedBox(height: 28),
      _pad(Divider(color: t.rule, height: 1)),
      const SizedBox(height: 22),
      _pad(_readNext(t)),
      const SizedBox(height: 20),
    ];
  }

  // A zero-height anchor so the TOC can scroll to a block.
  Widget _anchor(String id) =>
      SizedBox(key: _keys.putIfAbsent(id, () => GlobalKey()), height: 0);

  // ---- top bar --------------------------------------------------------------
  Widget _topBar(_RTheme t) {
    final saved = ReadNextStore.instance.isSaved(a.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Row(children: [
        _iconBtn(t, Icons.arrow_back_rounded, () => Navigator.of(context).maybePop()),
        const Spacer(),
        if (_tocEntries().length > 1) _iconBtn(t, Icons.toc_rounded, () => _openToc(t)),
        _iconBtn(t, Icons.text_fields_rounded, () => _openSettings(t)),
        _iconBtn(t, saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            () => ReadNextStore.instance.toggleSave(a.id),
            color: saved ? _progressColor : null),
        _iconBtn(t, Icons.ios_share_rounded, () => _soon(_tr('Sharing coming soon', 'Sharing jald aa raha hai'))),
      ]),
    );
  }

  Widget _iconBtn(_RTheme t, IconData i, VoidCallback onTap, {Color? color}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(padding: const EdgeInsets.all(9), child: Icon(i, size: 21, color: color ?? t.ink)),
      );

  Widget _byline(_RTheme t) {
    final has = a.author.isNotEmpty;
    final label = has ? a.author : a.category;
    final initial = (label.replaceAll('Dr. ', '').trim().isNotEmpty
            ? label.replaceAll('Dr. ', '').trim()[0]
            : 'P')
        .toUpperCase();
    return Row(children: [
      Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: t.panel, shape: BoxShape.circle),
        child: Text(initial,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w700, color: t.accent)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text.rich(
          TextSpan(children: [
            TextSpan(text: label, style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
            if (has && a.authorRole.isNotEmpty)
              TextSpan(text: '  ·  ${a.authorRole}', style: TextStyle(color: t.soft)),
          ]),
          style: GoogleFonts.manrope(fontSize: 12.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Text(a.readingTime,
          style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: t.soft)),
    ]);
  }

  // A calm editorial cover placeholder (theme-tinted band + soft icon).
  Widget _cover(_RTheme t) => ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 176,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [t.accent.withValues(alpha: 0.16), t.panel],
            ),
            border: Border.all(color: t.rule),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.auto_stories_outlined, size: 44, color: t.accent.withValues(alpha: 0.7)),
        ),
      );

  Widget _whyNow(_RTheme t, S s) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFE6A817).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE6A817).withValues(alpha: 0.24)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.lightbulb_rounded, size: 15, color: Color(0xFF9A7A14)),
            const SizedBox(width: 7),
            Text(s.rnWhyNow.toUpperCase(),
                style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: const Color(0xFF9A7A14))),
          ]),
          const SizedBox(height: 8),
          Text(a.reason,
              style: GoogleFonts.manrope(fontSize: 14.5 * _fs, height: 1.55, color: t.ink)),
        ]),
      );

  Widget _ratingRow(_RTheme t) => Row(children: [
        const Icon(Icons.star_rounded, size: 17, color: Color(0xFFE6A817)),
        const SizedBox(width: 4),
        Text(a.rating.toStringAsFixed(1),
            style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w800, color: t.ink)),
        const SizedBox(width: 6),
        Text('(${a.ratingCount >= 1000 ? '${(a.ratingCount / 1000).toStringAsFixed(1)}k' : a.ratingCount} ratings)',
            style: GoogleFonts.manrope(fontSize: 12, color: t.soft)),
      ]);

  // A distinct, styled section block (used for Why This Matters / Research).
  Widget _infoBlock(_RTheme t,
          {required IconData icon,
          required String title,
          required String body,
          required Color tint}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tint.withValues(alpha: 0.24)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 17, color: tint),
            const SizedBox(width: 9),
            Text(title.toUpperCase(),
                style: GoogleFonts.manrope(
                    fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: tint)),
          ]),
          const SizedBox(height: 11),
          Text(body,
              style: GoogleFonts.manrope(fontSize: 14.5 * _fs, height: 1.65, color: t.ink)),
        ]),
      );

  Widget _mythFact(_RTheme t) => Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: t.rule)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(15),
            color: _progressColor.withValues(alpha: 0.09),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_tr('MYTH', 'MYTH'),
                  style: GoogleFonts.manrope(
                      fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: _progressColor)),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(a.myth,
                      style: GoogleFonts.manrope(
                          fontSize: 14 * _fs, height: 1.55, color: t.ink, fontStyle: FontStyle.italic))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            color: t.accent.withValues(alpha: 0.07),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_tr('FACT', 'FACT'),
                  style: GoogleFonts.manrope(
                      fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: t.accent)),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(a.fact,
                      style: GoogleFonts.manrope(
                          fontSize: 14 * _fs, height: 1.6, color: t.ink, fontWeight: FontWeight.w600))),
            ]),
          ),
        ]),
      );

  // ---- book companion (About / Philosophy / Ideas / Perspective / Chapters) -
  List<Widget> _companionSections(_RTheme t) {
    final c = a.companion!;
    return [
      if (c.recommendedFor.isNotEmpty || c.themes.isNotEmpty) ...[
        _pad(_companionMeta(t, c)),
        const SizedBox(height: 20),
      ],
      if (a.hasRating) ...[_pad(_ratingRow(t)), const SizedBox(height: 18)],
      if (c.about.isNotEmpty) ...[
        _anchor('about'),
        _pad(_secTitle(t, _tr('What this book is about', 'Yeh book kis baare mein hai'))),
        const SizedBox(height: 10),
        _pad(Text(c.about, style: _bodyStyle(t))),
        const SizedBox(height: 22),
      ],
      if (c.philosophy.isNotEmpty) ...[
        _anchor('philosophy'),
        _pad(_infoBlock(t, icon: Icons.auto_awesome_outlined, title: _tr('Core philosophy', 'Mool vichaar'), body: c.philosophy, tint: t.accent)),
        const SizedBox(height: 22),
      ],
      if (c.ideas.isNotEmpty) ...[
        _anchor('ideas'),
        _pad(_secTitle(t, _tr('The most important ideas', 'Sabse zaroori ideas'))),
        const SizedBox(height: 14),
        for (final idea in c.ideas) _pad(_ideaCard(t, idea)),
        const SizedBox(height: 6),
      ],
      if (c.perspective.isNotEmpty) ...[
        _anchor('perspective'),
        _pad(_infoBlock(t, icon: Icons.verified_outlined, title: _tr('ParentVeda perspective', 'ParentVeda ka nazariya'), body: c.perspective, tint: const Color(0xFF3FA56A))),
        const SizedBox(height: 22),
      ],
      if (c.chapters.isNotEmpty) ...[
        _anchor('chapters'),
        _pad(_secTitle(t, _tr('Chapter by chapter', 'Chapter dar chapter'))),
        const SizedBox(height: 12),
        for (final ch in c.chapters) _pad(_chapterRow(t, ch.$1, ch.$2)),
        const SizedBox(height: 10),
      ],
      if (c.quotes.isNotEmpty) ...[
        _anchor('quotes'),
        _pad(_secTitle(t, _tr('Memorable lines', 'Yaadgaar baatein'))),
        const SizedBox(height: 12),
        for (final q in c.quotes) _pad(_quoteCard(t, q)),
      ],
    ];
  }

  Widget _secTitle(_RTheme t, String text) => Text(text,
      style: GoogleFonts.fraunces(fontSize: 22 * _fs, height: 1.15, fontWeight: FontWeight.w600, color: t.ink));

  Widget _companionMeta(_RTheme t, BookCompanion c) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(15)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (c.recommendedFor.isNotEmpty) ...[
            Text(_tr('BEST FOR', 'KISKE LIYE'), style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: t.soft)),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: [for (final r in c.recommendedFor) _metaChip(t, r, t.accent)]),
          ],
          if (c.recommendedFor.isNotEmpty && c.themes.isNotEmpty) const SizedBox(height: 14),
          if (c.themes.isNotEmpty) ...[
            Text(_tr('THEMES', 'VISHAY'), style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: t.soft)),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: [for (final th in c.themes) _metaChip(t, th, t.soft)]),
          ],
        ]),
      );

  Widget _metaChip(_RTheme t, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(999), border: Border.all(color: t.rule)),
        child: Text(label, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      );

  Widget _ideaCard(_RTheme t, BookKeyIdea idea) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.rule)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(idea.title, style: GoogleFonts.plusJakartaSans(fontSize: 16 * _fs, fontWeight: FontWeight.w700, color: t.ink, height: 1.2)),
          const SizedBox(height: 12),
          _ideaPart(t, _tr('What it means', 'Iska matlab'), idea.means),
          const SizedBox(height: 10),
          _ideaPart(t, _tr('Why it matters', 'Yeh kyun zaroori hai'), idea.matters),
          if (idea.inRealLife.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_tr('IN REAL LIFE', 'ASAL ZINDAGI MEIN'), style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: t.accent)),
            const SizedBox(height: 6),
            for (final b in idea.inRealLife)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(top: 7), child: Container(width: 5, height: 5, decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle))),
                  const SizedBox(width: 9),
                  Expanded(child: Text(b, style: GoogleFonts.manrope(fontSize: 13.5 * _fs, height: 1.5, color: t.ink))),
                ]),
              ),
          ],
        ]),
      );

  Widget _ideaPart(_RTheme t, String label, String body) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: t.soft)),
        const SizedBox(height: 3),
        Text(body, style: GoogleFonts.manrope(fontSize: 13.5 * _fs, height: 1.55, color: t.ink)),
      ]);

  Widget _chapterRow(_RTheme t, String title, String summary) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14.5 * _fs, fontWeight: FontWeight.w700, color: t.ink)),
          const SizedBox(height: 5),
          Text(summary, style: GoogleFonts.manrope(fontSize: 13.5 * _fs, height: 1.55, color: t.soft)),
        ]),
      );

  Widget _quoteCard(_RTheme t, String q) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: t.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: t.accent, width: 3)),
        ),
        child: Text(q, style: GoogleFonts.fraunces(fontSize: 15 * _fs, height: 1.5, fontStyle: FontStyle.italic, color: t.ink)),
      );

  // ---- actions: mark reading / mark done (same stores as the old reader) ----
  Widget _actions(_RTheme t, S s) {
    final status = ReadNextStore.instance.statusOf(a.id);
    final done = ReadDoneStore.instance.isDone(a.id);
    return Row(children: [
      if (!done) ...[
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: status == 'reading' ? const Color(0xFFE6A817) : t.soft,
              side: BorderSide(
                  color: status == 'reading' ? const Color(0xFFE6A817) : t.rule, width: 1.4),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            onPressed: () => ReadNextStore.instance.setStatus(a.id, 'reading'),
            child: Text(status == 'reading' ? s.rnReadingBadge : s.rnMarkReading),
          ),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: done ? const Color(0xFF3FA56A) : t.accent,
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          // Marking complete ticks the Home daily-reads checkbox too (same
          // ReadDoneStore) and clears any "reading" status.
          onPressed: () {
            ReadDoneStore.instance.toggle(a.id);
            if (ReadDoneStore.instance.isDone(a.id)) {
              ReadNextStore.instance.setStatus(a.id, 'completed');
            } else {
              ReadNextStore.instance.clearStatus(a.id);
            }
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(done ? Icons.check_circle_rounded : Icons.check_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(done ? s.rnCompletedBadge : s.rnMarkDone,
                style: GoogleFonts.manrope(
                    fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
        ),
      ),
    ]);
  }

  // ---- read next chain ------------------------------------------------------
  List<ReadItem> _readNextItems({int limit = 4}) {
    final week = widget.controller.currentWeek;
    final seen = <String>{a.id};
    final out = <ReadItem>[];
    void add(Iterable<ReadItem> items) {
      for (final it in items) {
        if (out.length >= limit) return;
        if (it.type == ReadType.book) continue;
        if (seen.add(it.id)) out.add(it);
      }
    }

    // Same category first, then this week's picks, then any relevant read.
    add(kReadItems.where((r) => r.category == a.category));
    add(recommendedForWeek(week));
    add(kReadItems);
    return out.take(limit).toList();
  }

  Widget _readNext(_RTheme t) {
    final next = _readNextItems();
    if (next.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_tr('Read next', 'Aage padhein'),
          style: GoogleFonts.fraunces(fontSize: 20 * _fs, fontWeight: FontWeight.w600, color: t.ink)),
      const SizedBox(height: 4),
      Text(_tr('Keep reading - more on this, one after another.', 'Padhte rahein - isi par aur.'),
          style: GoogleFonts.manrope(fontSize: 12.5, color: t.soft)),
      const SizedBox(height: 16),
      for (final na in next)
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
              builder: (_) => ReadReaderScreen(item: na, controller: widget.controller))),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(11)),
                child: Icon(Icons.menu_book_outlined, size: 18, color: t.accent),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${na.category.toUpperCase()} · ${na.readingTime.toUpperCase()}',
                      style: GoogleFonts.manrope(
                          fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: t.soft)),
                  const SizedBox(height: 3),
                  Text(na.title,
                      style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w600, color: t.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: t.soft),
            ]),
          ),
        ),
    ]);
  }

  // ---- table of contents ----------------------------------------------------
  void _openToc(_RTheme t) {
    final entries = _tocEntries();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
                child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(color: t.rule, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Text(_tr('In this read', 'Is read mein'),
                style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600, color: t.ink)),
            const SizedBox(height: 12),
            for (final e in entries)
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  final c = _keys[e.$1]?.currentContext;
                  if (c != null) {
                    Scrollable.ensureVisible(c,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        alignment: 0.05);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Text(e.$2,
                      style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: t.ink)),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  // ---- reading settings (font + mode) --------------------------------------
  void _openSettings(_RTheme t) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                  child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(color: t.rule, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 16),
              Text(_tr('Reading', 'Reading'),
                  style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600, color: t.ink)),
              const SizedBox(height: 18),
              Row(children: [
                Text('A', style: GoogleFonts.fraunces(fontSize: 15, color: t.soft)),
                const SizedBox(width: 10),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                        activeTrackColor: t.accent,
                        thumbColor: t.accent,
                        inactiveTrackColor: t.rule,
                        overlayColor: t.accent.withValues(alpha: 0.12)),
                    child: Slider(
                      value: _prefs.fontScale,
                      min: 0.85,
                      max: 1.35,
                      divisions: 5,
                      onChanged: (v) {
                        _prefs.setFontScale(v);
                        setSheet(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('A', style: GoogleFonts.fraunces(fontSize: 26, color: t.soft)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _modeChip(t, _tr('Light', 'Light'), ReadReaderMode.light, setSheet),
                const SizedBox(width: 10),
                _modeChip(t, _tr('Sepia', 'Sepia'), ReadReaderMode.sepia, setSheet),
                const SizedBox(width: 10),
                _modeChip(t, _tr('Dark', 'Dark'), ReadReaderMode.dark, setSheet),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _modeChip(_RTheme t, String label, ReadReaderMode m, void Function(void Function()) setSheet) {
    final on = _prefs.mode == m;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _prefs.setMode(m);
          setSheet(() {});
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? _t.accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: on ? _t.accent : t.rule),
          ),
          child: Text(label,
              style: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w700, color: on ? _t.accent : t.soft)),
        ),
      ),
    );
  }
}

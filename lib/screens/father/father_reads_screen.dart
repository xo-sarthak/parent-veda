// =============================================================================
//  FatherReadsScreen - the father's "Reads" tab (Slate)
// -----------------------------------------------------------------------------
//  A tab in the unified father shell (mirrors the mother's nav structure, in the
//  father palette/fonts). Lists the father reads grouped as Articles · Research
//  Summaries · Book Summaries, plus a way into the Stories, Fables & Mythology
//  tales. Each read opens the premium Slate "Learn V2" reader (reading-progress
//  bar, table of contents, font size, reading modes, and the Why-This-Matters +
//  Research-Simplified + Myth-vs-Fact blocks) - the father twin of the mother's
//  read_reader_screen. Embedded as a tab -> no back button, bottom padding
//  clears the floating pill.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/father/father_read_data.dart';
import '../../models/read_item.dart';
import '../../theme/father_skin.dart';
import 'father_stories_screen.dart';

class FatherReadsScreen extends StatelessWidget {
  const FatherReadsScreen({super.key});

  TextStyle _body(double s,
          {FontWeight w = FontWeight.w400, Color c = kFInk, double h = 1.5}) =>
      GoogleFonts.plusJakartaSans(fontSize: s, fontWeight: w, color: c, height: h);
  TextStyle _eyebrow(Color c) => GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w700, color: c, letterSpacing: 1.4);

  @override
  Widget build(BuildContext context) {
    final research = fatherReadsByType(ReadType.research);
    final books = fatherReadsByType(ReadType.book);
    return Container(
      color: kFBg,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          children: [
            Text('FOR YOU, DAD', style: _eyebrow(kFMuted)),
            const SizedBox(height: 4),
            Text('Reads', style: fatherSerif(26, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Short reads about her, the baby, and how to show up.',
                style: _body(13, c: kFMuted)),
            const SizedBox(height: 16),
            // Tales entry - the Stories, Fables & Mythology collection.
            _talesCard(context),
            const SizedBox(height: 18),
            // ---- Articles ----
            Text('ARTICLES', style: _eyebrow(kFAccent)),
            const SizedBox(height: 10),
            for (final r in kFatherArticles) _readCard(context, r),
            // ---- Research Summaries ----
            if (research.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('RESEARCH SUMMARIES', style: _eyebrow(kFAccent)),
              const SizedBox(height: 10),
              for (final r in research) _readCard(context, r),
            ],
            // ---- Book Summaries ----
            if (books.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('BOOK SUMMARIES', style: _eyebrow(kFAccent)),
              const SizedBox(height: 10),
              for (final r in books) _bookCard(context, r),
            ],
          ],
        ),
      ),
    );
  }

  Widget _talesCard(BuildContext context) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const FatherStoriesScreen())),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kFAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: kFAccent2, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.history_edu_rounded,
                  color: kFCream, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stories, Fables & Mythology',
                        style: fatherSerif(17, color: kFCream)),
                    const SizedBox(height: 3),
                    Text('Tales to read aloud to the bump',
                        style: _body(12.5,
                            c: kFCream.withValues(alpha: 0.85))),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded,
                color: kFCream.withValues(alpha: 0.9)),
          ]),
        ),
      );

  Widget _readCard(BuildContext context, ReadItem r) => GestureDetector(
        onTap: () => _openReader(context, r),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kFCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kFLine),
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: kFAccentSoft, borderRadius: BorderRadius.circular(14)),
              child: Text(r.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title,
                        style: fatherSerif(16, weight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Text('${r.readingTime} · ${r.category}',
                        style: _body(12, c: kFMuted)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: kFMuted),
          ]),
        ),
      );

  // Book summaries get a rating line + "Read summary" and "Buy Book" actions.
  Widget _bookCard(BuildContext context, ReadItem r) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kFCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kFLine),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: kFAccentSoft, borderRadius: BorderRadius.circular(14)),
              child: Text(r.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title,
                        style: fatherSerif(16, weight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: kFAccent2),
                      const SizedBox(width: 3),
                      Text(r.rating.toStringAsFixed(1),
                          style: _body(12, c: kFMuted, w: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(r.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _body(12, c: kFMuted)),
                      ),
                    ]),
                  ]),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _miniBtn(Icons.menu_book_rounded, 'Read summary',
                filled: false, () => _openReader(context, r)),
            const SizedBox(width: 8),
            _miniBtn(Icons.shopping_bag_rounded, 'Buy Book',
                filled: true, () => _openBuy(context, r)),
          ]),
        ]),
      );

  Widget _miniBtn(IconData icon, String label, VoidCallback onTap,
          {bool filled = false}) =>
      Material(
        color: filled ? kFAccent : kFAccentSoft,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 15, color: filled ? kFCream : kFAccent),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: filled ? kFCream : kFAccent)),
            ]),
          ),
        ),
      );

  void _openReader(BuildContext context, ReadItem r) =>
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _FatherReadReader(read: r)));

  Future<void> _openBuy(BuildContext context, ReadItem r) async {
    final query = Uri.encodeComponent('${r.title} ${r.author} book buy'.trim());
    final url = r.buyUrl.trim().isNotEmpty
        ? r.buyUrl.trim()
        : 'https://www.google.com/search?q=$query';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(r.title)));
    }
  }
}

// ---------------------------------------------------------------------------
//  Session-scoped reader prefs (font scale + reading mode). Kept in-memory so
//  the choice sticks across opens without touching a store.
// ---------------------------------------------------------------------------
enum _ReadMode { cream, sepia, dark }

class _FatherReaderPrefs {
  static double fontScale = 1.0;
  static _ReadMode mode = _ReadMode.cream;
}

class _ModePalette {
  const _ModePalette(this.bg, this.ink, this.muted, this.card, this.line);
  final Color bg, ink, muted, card, line;
}

_ModePalette _paletteFor(_ReadMode m) {
  switch (m) {
    case _ReadMode.sepia:
      return const _ModePalette(Color(0xFFF3E9D6), Color(0xFF4A3B28),
          Color(0xFF8A7A63), Color(0xFFEFE3CC), Color(0xFFE3D5BB));
    case _ReadMode.dark:
      return const _ModePalette(Color(0xFF22333B), Color(0xFFEDE6DA),
          Color(0xFFA7B4B9), Color(0xFF2C3E47), Color(0xFF3A4C55));
    case _ReadMode.cream:
      return const _ModePalette(kFBg, kFInk, kFMuted, kFCard, kFLine);
  }
}

// ---------------------------------------------------------------------------
//  The premium Slate reader for a single father read.
// ---------------------------------------------------------------------------
class _FatherReadReader extends StatefulWidget {
  const _FatherReadReader({required this.read});
  final ReadItem read;

  @override
  State<_FatherReadReader> createState() => _FatherReadReaderState();
}

class _FatherReadReaderState extends State<_FatherReadReader> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _kArticle = GlobalKey();
  final GlobalKey _kWhy = GlobalKey();
  final GlobalKey _kResearch = GlobalKey();
  final GlobalKey _kMyth = GlobalKey();
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final p = max <= 0 ? 0.0 : (_scroll.offset / max).clamp(0.0, 1.0);
    if ((p - _progress).abs() > 0.005) setState(() => _progress = p);
  }

  double get _fs => _FatherReaderPrefs.fontScale;

  List<({String label, GlobalKey key})> get _toc {
    final r = widget.read;
    return [
      (label: 'The read', key: _kArticle),
      if (r.hasWhyThisMatters) (label: 'Why this matters', key: _kWhy),
      if (r.hasResearchSimplified)
        (label: 'Research simplified', key: _kResearch),
      if (r.hasMythFact) (label: 'Myth vs fact', key: _kMyth),
    ];
  }

  void _jumpTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.read;
    final pal = _paletteFor(_FatherReaderPrefs.mode);
    final paras = r.body.split('\n\n');
    return Scaffold(
      backgroundColor: pal.bg,
      appBar: AppBar(
        backgroundColor: pal.bg,
        elevation: 0,
        foregroundColor: pal.ink,
        title: Text(r.category,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: pal.muted)),
        actions: [
          if (_toc.length > 1)
            IconButton(
                tooltip: 'Contents',
                icon: const Icon(Icons.list_rounded),
                onPressed: _showToc),
          IconButton(
              tooltip: 'Reading settings',
              icon: const Icon(Icons.text_fields_rounded),
              onPressed: _showSettings),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 3,
            backgroundColor: pal.line,
            valueColor: const AlwaysStoppedAnimation(kFAccent2),
          ),
        ),
      ),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 48),
        children: [
          Text(r.title,
              key: _kArticle,
              style: fatherSerif(27 * _fs, weight: FontWeight.w600)
                  .copyWith(color: pal.ink)),
          const SizedBox(height: 9),
          Text('${r.readingTime} · ${r.category}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5 * _fs,
                  fontWeight: FontWeight.w500,
                  color: pal.muted)),
          const SizedBox(height: 18),
          for (final para in paras) ...[
            Text(para,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5 * _fs,
                    height: 1.62,
                    color: pal.ink.withValues(alpha: 0.9))),
            const SizedBox(height: 16),
          ],
          if (r.hasWhyThisMatters)
            _block(pal, _kWhy, 'Why This Matters', r.whyThisMatters,
                Icons.favorite_rounded),
          if (r.hasResearchSimplified)
            _block(pal, _kResearch, 'Research Simplified', r.researchSimplified,
                Icons.science_rounded),
          if (r.hasMythFact) _mythFact(pal, r),
        ],
      ),
    );
  }

  Widget _block(_ModePalette pal, GlobalKey key, String title, String body,
          IconData icon) =>
      Container(
        key: key,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: pal.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: pal.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 17, color: kFAccent),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14 * _fs,
                    fontWeight: FontWeight.w800,
                    color: pal.ink)),
          ]),
          const SizedBox(height: 10),
          Text(body,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5 * _fs,
                  height: 1.6,
                  color: pal.ink.withValues(alpha: 0.9))),
        ]),
      );

  Widget _mythFact(_ModePalette pal, ReadItem r) => Container(
        key: _kMyth,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: pal.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: pal.line),
        ),
        child: Column(children: [
          _mfRow(pal, 'MYTH', r.myth, kFMuted, Icons.close_rounded),
          Divider(height: 1, color: pal.line),
          _mfRow(pal, 'FACT', r.fact, kFAccent, Icons.check_rounded),
        ]),
      );

  Widget _mfRow(_ModePalette pal, String tag, String text, Color accent,
          IconData icon) =>
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(icon, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tag,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11 * _fs,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: accent)),
                  const SizedBox(height: 4),
                  Text(text,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14 * _fs,
                          height: 1.5,
                          color: pal.ink.withValues(alpha: 0.9))),
                ]),
          ),
        ]),
      );

  void _showToc() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _paletteFor(_FatherReaderPrefs.mode).bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        final pal = _paletteFor(_FatherReaderPrefs.mode);
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 14),
            Text('Contents',
                style: fatherSerif(18).copyWith(color: pal.ink)),
            const SizedBox(height: 8),
            for (final t in _toc)
              ListTile(
                title: Text(t.label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, color: pal.ink)),
                trailing: Icon(Icons.arrow_forward_rounded,
                    size: 18, color: pal.muted),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _jumpTo(t.key);
                },
              ),
            const SizedBox(height: 8),
          ]),
        );
      },
    );
  }

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _paletteFor(_FatherReaderPrefs.mode).bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final pal = _paletteFor(_FatherReaderPrefs.mode);
          Widget modeChip(String label, _ReadMode m) {
            final active = _FatherReaderPrefs.mode == m;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setSheet(() => _FatherReaderPrefs.mode = m);
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? kFAccent : pal.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: active ? kFAccent : pal.line),
                  ),
                  child: Text(label,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: active ? kFCream : pal.ink)),
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Reading', style: fatherSerif(18).copyWith(color: pal.ink)),
                const SizedBox(height: 16),
                Row(children: [
                  Text('A', style: TextStyle(fontSize: 14, color: pal.muted)),
                  Expanded(
                    child: Slider(
                      value: _FatherReaderPrefs.fontScale,
                      min: 0.85,
                      max: 1.35,
                      divisions: 10,
                      activeColor: kFAccent,
                      onChanged: (v) {
                        setSheet(() => _FatherReaderPrefs.fontScale = v);
                        setState(() {});
                      },
                    ),
                  ),
                  Text('A', style: TextStyle(fontSize: 22, color: pal.ink)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  modeChip('Cream', _ReadMode.cream),
                  modeChip('Sepia', _ReadMode.sepia),
                  modeChip('Dark', _ReadMode.dark),
                ]),
              ]),
            ),
          );
        });
      },
    );
  }
}

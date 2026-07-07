// =============================================================================
//  ReadingReaderScreen — the premium article reader (the centerpiece)
// -----------------------------------------------------------------------------
//  Long-form reading, done with care (Kindle/Medium sensibility): a scroll
//  progress bar, a table of contents, adjustable font size, light/sepia/dark
//  reading modes, bookmark + share, inline expandable ParentVeda Tips and
//  Myth-vs-Fact cards, an evidence note, and a "Read next" chain onward into the
//  ecosystem. Resumes where you left off; remembers your progress.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pp_common.dart';
import 'pp_reading_data.dart';
import 'reading_common.dart';

class _RTheme {
  const _RTheme(this.bg, this.ink, this.soft, this.panel, this.rule, this.accent);
  final Color bg, ink, soft, panel, rule, accent;
}

class ReadingReaderScreen extends StatefulWidget {
  const ReadingReaderScreen({super.key, required this.article});
  final ReadArticle article;

  @override
  State<ReadingReaderScreen> createState() => _ReadingReaderScreenState();
}

class _ReadingReaderScreenState extends State<ReadingReaderScreen> {
  final ScrollController _sc = ScrollController();
  final Map<int, GlobalKey> _keys = {};
  final Set<int> _expandedTips = {};
  double _progress = 0;

  ReadArticle get a => widget.article;
  ReadingStore get _store => ReadingStore.instance;

  @override
  void initState() {
    super.initState();
    _sc.addListener(_onScroll);
    // Resume where the parent left off.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = _store.progressOf(a.id);
      if (p > 0.02 && p < 0.95 && _sc.hasClients) {
        _sc.jumpTo(p * _sc.position.maxScrollExtent);
      }
    });
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
    _store.setProgress(a.id, p);
  }

  _RTheme get _t {
    switch (_store.mode) {
      case ReadMode.sepia:
        return const _RTheme(Color(0xFFF4ECD8), Color(0xFF423A2A), Color(0xFF6E6250), Color(0xFFEDE3CB), Color(0xFFE1D6BD), Color(0xFF7A4CC0));
      case ReadMode.dark:
        return const _RTheme(Color(0xFF17151C), Color(0xFFE9E5EF), Color(0xFFA9A2B5), Color(0xFF232029), Color(0xFF2E2A35), Color(0xFFB794F6));
      case ReadMode.light:
        return const _RTheme(ppBg, ppInk, ppSoft, ppPanel, ppHair, ppPurple);
    }
  }

  double get _fs => _store.fontScale;

  TextStyle _bodyStyle(_RTheme t) => GoogleFonts.fraunces(fontSize: 17.5 * _fs, height: 1.75, color: t.ink, letterSpacing: 0.1);
  TextStyle _headingStyle(_RTheme t) => GoogleFonts.fraunces(fontSize: 21 * _fs, height: 1.25, fontWeight: FontWeight.w600, color: t.ink);

  String _initial() {
    final n = a.author.replaceAll('Dr. ', '').trim();
    return (n.isNotEmpty ? n[0] : 'P').toUpperCase();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _soon(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    final t = _t;
    return Scaffold(
      backgroundColor: t.bg,
      body: Column(children: [
        SafeArea(bottom: false, child: _topBar(t)),
        // progress bar
        SizedBox(
          height: 2.5,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(widthFactor: _progress.clamp(0.0, 1.0), child: Container(color: ppCoral)),
          ),
        ),
        Expanded(
          child: ListView(
            controller: _sc,
            padding: const EdgeInsets.only(top: 8, bottom: 48),
            children: [
              _pad(Text(readCollectionById(a.collection).title.toUpperCase(), style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: t.accent))),
              const SizedBox(height: 12),
              _pad(Text(a.title, style: GoogleFonts.fraunces(fontSize: 30 * _fs, height: 1.15, fontWeight: FontWeight.w600, color: t.ink))),
              const SizedBox(height: 12),
              _pad(Text(a.teaser, style: GoogleFonts.fraunces(fontSize: 17 * _fs, height: 1.5, fontStyle: FontStyle.italic, color: t.soft))),
              const SizedBox(height: 16),
              _pad(_byline(t)),
              const SizedBox(height: 18),
              _pad(ReadCoverBar(seed: a.seed, height: 200)),
              const SizedBox(height: 24),
              for (int i = 0; i < a.sections.length; i++) _section(t, i, a.sections[i]),
              if (a.evidence != null) ...[const SizedBox(height: 8), _pad(_evidence(t))],
              const SizedBox(height: 24),
              _pad(_completeButton(t)),
              const SizedBox(height: 28),
              _pad(Divider(color: t.rule, height: 1)),
              const SizedBox(height: 22),
              _pad(_readNext(t)),
            ],
          ),
        ),
      ]),
    );
  }

  // ---- top bar ------------------------------------------------------------
  Widget _topBar(_RTheme t) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        child: Row(children: [
          _iconBtn(t, Icons.arrow_back, () => Navigator.of(context).maybePop()),
          const Spacer(),
          if (a.toc.length > 1) _iconBtn(t, Icons.toc_rounded, () => _openToc(t)),
          _iconBtn(t, Icons.text_fields_rounded, () => _openSettings(t)),
          _iconBtn(t, _store.isSaved(a.id) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, () => setState(() => _store.toggleSave(a.id))),
          _iconBtn(t, Icons.ios_share_rounded, () => _soon('Sharing coming soon')),
        ]),
      );

  Widget _iconBtn(_RTheme t, IconData i, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(padding: const EdgeInsets.all(9), child: Icon(i, size: 21, color: t.ink)),
      );

  Widget _byline(_RTheme t) => Row(children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: t.panel, shape: BoxShape.circle),
          child: Text(_initial(), style: ppJakarta(14, color: t.accent)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: a.author, style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
              TextSpan(text: '  ·  ${a.authorRole}', style: TextStyle(color: t.soft)),
            ]),
            style: GoogleFonts.manrope(fontSize: 12.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text('${a.minutes} min', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: t.soft)),
      ]);

  // ---- a section ----------------------------------------------------------
  Widget _section(_RTheme t, int index, ReadSection s) {
    final children = <Widget>[];
    if (s.heading != null) {
      final key = _keys.putIfAbsent(index, () => GlobalKey());
      children.add(Padding(
        key: key,
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: _pad(Text(s.heading!, style: _headingStyle(t))),
      ));
    }
    for (final p in s.paragraphs) {
      children.add(Padding(padding: const EdgeInsets.only(bottom: 18), child: _pad(Text(p, style: _bodyStyle(t)))));
    }
    if (s.image) {
      children.add(Padding(padding: const EdgeInsets.only(bottom: 20), child: _pad(ReadCoverBar(seed: a.seed + index + 3, height: 170))));
    }
    if (s.tip != null) children.add(Padding(padding: const EdgeInsets.only(bottom: 20), child: _pad(_tipCard(t, index, s.tip!))));
    if (s.mythFact != null) children.add(Padding(padding: const EdgeInsets.only(bottom: 20), child: _pad(_mythFact(t, s.mythFact!))));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  // ---- expandable ParentVeda tip -----------------------------------------
  Widget _tipCard(_RTheme t, int index, ReadTip tip) {
    final open = _expandedTips.contains(index);
    return GestureDetector(
      onTap: () => setState(() => open ? _expandedTips.remove(index) : _expandedTips.add(index)),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: t.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: t.accent.withValues(alpha: 0.25))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.lightbulb_outline_rounded, size: 17, color: t.accent),
            const SizedBox(width: 9),
            Expanded(child: Text('ParentVeda tip · ${tip.title}', style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: t.ink))),
            Icon(open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 20, color: t.soft),
          ]),
          if (open) ...[
            const SizedBox(height: 10),
            Text(tip.body, style: GoogleFonts.manrope(fontSize: 14, height: 1.6, color: t.ink)),
          ],
        ]),
      ),
    );
  }

  // ---- myth vs fact -------------------------------------------------------
  Widget _mythFact(_RTheme t, MythFact mf) => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: t.rule)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(15),
            color: ppCoral.withValues(alpha: 0.08),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MYTH', style: GoogleFonts.manrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: ppCoral)),
              const SizedBox(width: 12),
              Expanded(child: Text(mf.myth, style: GoogleFonts.manrope(fontSize: 14, height: 1.55, color: t.ink, fontStyle: FontStyle.italic))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            color: t.accent.withValues(alpha: 0.07),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('FACT', style: GoogleFonts.manrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: t.accent)),
              const SizedBox(width: 15),
              Expanded(child: Text(mf.fact, style: GoogleFonts.manrope(fontSize: 14, height: 1.6, color: t.ink, fontWeight: FontWeight.w600))),
            ]),
          ),
        ]),
      );

  Widget _evidence(_RTheme t) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(14)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.verified_outlined, size: 16, color: t.soft),
          const SizedBox(width: 10),
          Expanded(child: Text('The evidence: ${a.evidence}', style: GoogleFonts.manrope(fontSize: 12.5, height: 1.5, color: t.soft))),
        ]),
      );

  Widget _completeButton(_RTheme t) {
    final done = _store.isCompleted(a.id);
    return GestureDetector(
      onTap: () => setState(() => _store.setProgress(a.id, 1.0)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: done ? t.accent.withValues(alpha: 0.12) : t.accent, borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(done ? Icons.check_circle_rounded : Icons.check_rounded, size: 18, color: done ? t.accent : Colors.white),
          const SizedBox(width: 8),
          Text(done ? 'Read — nicely done' : 'Mark as read', style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: done ? t.accent : Colors.white)),
        ]),
      ),
    );
  }

  // ---- read next (articles only — keep reading) ---------------------------
  Widget _readNext(_RTheme t) {
    final next = readNextArticles(a);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Read next', style: GoogleFonts.fraunces(fontSize: 20 * _fs, fontWeight: FontWeight.w600, color: t.ink)),
      const SizedBox(height: 4),
      Text('Keep reading — more on this, one after another.', style: GoogleFonts.manrope(fontSize: 12.5, color: t.soft)),
      const SizedBox(height: 16),
      for (final na in next)
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => ReadingReaderScreen(article: na))),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(11)), child: Icon(Icons.menu_book_outlined, size: 18, color: t.accent)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${readKindLabel(na.kind).toUpperCase()} · ${na.minutes} MIN', style: GoogleFonts.manrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: t.soft)),
                  const SizedBox(height: 3),
                  Text(na.title, style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w600, color: t.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: t.soft),
            ]),
          ),
        ),
    ]);
  }

  // ---- table of contents --------------------------------------------------
  void _openToc(_RTheme t) {
    final entries = <(int, String)>[];
    for (int i = 0; i < a.sections.length; i++) {
      if (a.sections[i].heading != null) entries.add((i, a.sections[i].heading!));
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: t.rule, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Text('In this read', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600, color: t.ink)),
            const SizedBox(height: 12),
            for (final e in entries)
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  final key = _keys[e.$1];
                  final c = key?.currentContext;
                  if (c != null) Scrollable.ensureVisible(c, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic, alignment: 0.05);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Text(e.$2, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: t.ink)),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  // ---- reading settings (font + mode) ------------------------------------
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
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: t.rule, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 16),
              Text('Reading', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600, color: t.ink)),
              const SizedBox(height: 18),
              // font size
              Row(children: [
                Text('A', style: GoogleFonts.fraunces(fontSize: 15, color: t.soft)),
                const SizedBox(width: 10),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(activeTrackColor: t.accent, thumbColor: t.accent, inactiveTrackColor: t.rule, overlayColor: t.accent.withValues(alpha: 0.12)),
                    child: Slider(
                      value: _store.fontScale,
                      min: 0.85,
                      max: 1.35,
                      divisions: 5,
                      onChanged: (v) {
                        _store.setFontScale(v);
                        setSheet(() {});
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('A', style: GoogleFonts.fraunces(fontSize: 26, color: t.soft)),
              ]),
              const SizedBox(height: 16),
              // mode
              Row(children: [
                _modeChip(t, 'Light', ReadMode.light, setSheet),
                const SizedBox(width: 10),
                _modeChip(t, 'Sepia', ReadMode.sepia, setSheet),
                const SizedBox(width: 10),
                _modeChip(t, 'Dark', ReadMode.dark, setSheet),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _modeChip(_RTheme t, String label, ReadMode m, void Function(void Function()) setSheet) {
    final on = _store.mode == m;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _store.setMode(m);
          setSheet(() {});
          setState(() {});
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
          child: Text(label, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: on ? _t.accent : t.soft)),
        ),
      ),
    );
  }
}

/// A cover band inside the reader (theme-agnostic warm placeholder).
class ReadCoverBar extends StatelessWidget {
  const ReadCoverBar({super.key, required this.seed, required this.height});
  final int seed;
  final double height;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ReadCover(seed: seed, height: height),
      );
}

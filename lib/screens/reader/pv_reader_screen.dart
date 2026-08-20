// =============================================================================
//  PvReaderScreen — the fifth reader, and the one meant to survive
// -----------------------------------------------------------------------------
//  Feature set from `reading_reader_screen.dart` (parenting), design language
//  from `bs_article_screen.dart` (V3). The teardown that produced that split is
//  written out at the head of `lib/models/pv_read.dart`; the short version is
//  that no existing reader had both, and four half-readers is three too many.
//
//  What it carries, and which of the four each came from:
//
//    scroll progress · table of contents · font scale · light/sepia/dark ·
//    bookmark · resume-where-you-left-off · expandable tips · myth-vs-fact ·
//    an evidence note                                     ← the parenting premium reader
//    `V2PaletteStore` · `pv_fonts` · `PvVideoPlaceholder` ·
//    products and tools through `SolutionCard`            ← the belly & skin renderer
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE THINGS IT DELIBERATELY DOES NOT DO
//  ---------------------------------------------------------------------------
//
//  · **No `_soon()` snackbars.** Both parenting readers answer Share with a
//    floating "Sharing coming soon". A control that exists and apologises is
//    worse than one that is absent: it spends top-bar width, invites a tap, and
//    pays it back with a toast. Share returns when it shares.
//
//  · **No silent fallback article.** `ArticleReaderScreen` does
//    `article ?? kArticles.firstWhere((e) => e.id == 'sleepcycles')`, so a
//    routing mistake renders a sleep piece under whatever title was tapped and
//    nothing anywhere reports a fault. This screen takes a non-null `PvRead`;
//    resolution failures are the router's to answer, and it answers with null.
//
//  · **No arithmetic video placement.** The parenting reader drops its one
//    video at `(sections.length - 1) ~/ 2` — the middle of the list, whatever
//    the middle happens to be about. Here the video hangs off the SECTION it
//    belongs to (`PvReadSection.videoSlot`), so it lands where it is relevant
//    and a read with nothing to show simply has none.
//
//  ⚠️ THE LIGHT THEME READS `V2PaletteStore`; SEPIA AND DARK DO NOT.
//  Light is the app's own surface and must move when the palette moves — that
//  is precisely what the parenting reader gave up by baking `ppBg` into its
//  light case, and why it cannot be used outside parenting. Sepia and dark are
//  reading surfaces rather than app surfaces: they are fixed by what is
//  comfortable to read at length, and a palette experiment must not be able to
//  make dark mode unreadable at 2am.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../models/pv_video_slot.dart';
import '../../services/pv_read_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_placeholders.dart';
import '../brackets/hub/hub_solution_cards.dart';
import '../v2/v2_palette.dart';

/// The six colours a reading surface needs. Deliberately a small, closed set —
/// a reading mode is not a theme and must not grow into one.
class _Skin {
  const _Skin(this.bg, this.ink, this.soft, this.panel, this.rule, this.accent);
  final Color bg, ink, soft, panel, rule, accent;
}

/// Resolves the id in a `videoSlot` to a real entry. Injected rather than
/// imported so this screen stays free of any one stage's data files — TTC hands
/// it `ttcVideoBySlot`, and parenting will hand it its own.
typedef PvVideoResolver = PvVideoSlot? Function(String slotId);

/// Opens another read by id, or a surface by id. Both injected, same reason.
typedef PvReadOpener = void Function(BuildContext context, String readId);
typedef PvSurfaceOpener = void Function(BuildContext context, String surfaceId);

class PvReaderScreen extends StatefulWidget {
  const PvReaderScreen({
    super.key,
    required this.read,
    required this.lang,
    this.resolveVideo,
    this.openRead,
    this.openSurface,
    this.openAction,
    this.readTitle,
  });

  final PvRead read;

  /// ⚠️ PASSED IN, NEVER READ FROM A GLOBAL. TTC's language flag is `TtcLang`,
  /// pregnancy's is `AppLanguage` on the controller, and reading the wrong one
  /// renders Devanagari inside a Hinglish shell. The caller knows which stage it
  /// is in; this screen does not and must not guess.
  final AppLanguage lang;

  final PvVideoResolver? resolveVideo;
  final PvReadOpener? openRead;
  final PvSurfaceOpener? openSurface;
  final void Function(BuildContext context, String action)? openAction;

  /// Title for a read-next card, by id. Injected so the reader never has to
  /// hold a stage's whole library to render one link.
  ///
  /// ⚠️ RETURNS NULLABLE, and `_readNext` renders nothing for a null. An id in
  /// `readNext` that no longer resolves is a content mistake — an article
  /// renamed or not yet written — and the honest response is to drop the link
  /// rather than print an empty card under a "Read next" heading.
  final LocalizedText? Function(String readId)? readTitle;

  @override
  State<PvReaderScreen> createState() => _PvReaderScreenState();
}

class _PvReaderScreenState extends State<PvReaderScreen> {
  final ScrollController _sc = ScrollController();

  /// One key per heading, so the contents sheet can scroll to it.
  final Map<int, GlobalKey> _headingKeys = {};

  /// Which folded sections she has opened, and which FAQ answers are showing.
  ///
  /// ⚠️ SESSION-SCOPED ON PURPOSE, not persisted like progress and bookmarks.
  /// Which boxes were open last Tuesday is not a preference — restoring it
  /// would mean an article that looks different every time she opens it for
  /// reasons she cannot see or control.
  final Set<int> _openSections = {};
  final Set<int> _openFaqs = {};

  bool _tocOpen = false;
  double _progress = 0;

  PvRead get a => widget.read;
  AppLanguage get _lang => widget.lang;
  PvReadStore get _store => PvReadStore.instance;

  @override
  void initState() {
    super.initState();
    _sc.addListener(_onScroll);
    _store.load();

    // Resume where she left off — but only from a position that is genuinely
    // mid-read. Jumping her to 3% is worse than starting at the top, and
    // jumping her to 97% of a piece she finished is worse still.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_sc.hasClients) return;
      final p = _store.progressOf(a.id);
      if (p > 0.05 && p < 0.92) {
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
    if (!_sc.hasClients) return;
    final max = _sc.position.maxScrollExtent;
    final p = max <= 0 ? 1.0 : (_sc.offset / max).clamp(0.0, 1.0);
    // Repaint the hairline only when it would actually move a pixel. Without
    // the epsilon this is a setState on every scroll frame.
    if ((p - _progress).abs() > 0.004) setState(() => _progress = p);
    _store.setProgress(a.id, p);
  }

  // ---- the reading surface -------------------------------------------------

  _Skin _skin(V2Palette p) {
    switch (_store.mode) {
      case PvReadMode.light:
        // The only mode that moves with the app.
        return _Skin(p.ground, p.ink1, p.ink2, p.surfaceAlt, p.line, p.action);
      case PvReadMode.sepia:
        return const _Skin(
          Color(0xFFF4ECD8),
          Color(0xFF423A2A),
          Color(0xFF6E6250),
          Color(0xFFEDE3CB),
          Color(0xFFE1D6BD),
          Color(0xFF7A4CC0),
        );
      case PvReadMode.dark:
        return const _Skin(
          Color(0xFF17151C),
          Color(0xFFE9E5EF),
          Color(0xFFA9A2B5),
          Color(0xFF232029),
          Color(0xFF2E2A35),
          Color(0xFFB794F6),
        );
    }
  }

  double get _fs => _store.fontScale;

  TextStyle _body(_Skin s) => pvFraunces(
      fontSize: 17.5 * _fs, height: 1.78, color: s.ink, letterSpacing: 0.05);

  TextStyle _heading(_Skin s) => pvFraunces(
      fontSize: 21 * _fs,
      height: 1.28,
      fontWeight: FontWeight.w600,
      color: s.ink);

  TextStyle _meta(_Skin s, {Color? color}) => pvManrope(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
      color: color ?? s.soft);

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: c);

  /// Scroll to section [i], opening it first if it is folded shut.
  ///
  /// ⚠️ THE OPEN COMES FIRST, AND THAT IS THE WHOLE BUG THIS AVOIDS. Jumping to
  /// a collapsed section lands her on a one-line closed box — she picked a
  /// heading out of the contents and arrived at a door. Both the inline
  /// contents strip and the top-bar sheet route through here so neither can
  /// forget.
  void _jumpTo(int i) {
    final sec = a.sections[i];
    if (sec.collapsible && !_openSections.contains(i)) {
      setState(() => _openSections.add(i));
    }
    // One frame, so a section that has just expanded is laid out at its full
    // height before we measure where to scroll to.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _headingKeys[i]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic);
      } else if (_sc.hasClients) {
        // Null when the heading is far enough down that it has never been
        // built. Scroll proportionally rather than doing nothing.
        _sc.animateTo(_sc.position.maxScrollExtent * (i / a.sections.length),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_store, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final s = _skin(p);

        return Scaffold(
          backgroundColor: s.bg,
          body: Column(children: [
            SafeArea(bottom: false, child: _topBar(s)),
            // The progress hairline. 2.5dp, directly under the controls, so it
            // reads as belonging to the page rather than to the system chrome.
            SizedBox(
              height: 2.5,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _progress.clamp(0.0, 1.0),
                  child: ColoredBox(color: s.accent),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: _sc,
                padding: const EdgeInsets.only(top: 10, bottom: 56),
                children: [
                  // ---- THE MASTHEAD ----------------------------------------
                  //
                  // ⚠️ EDITORIAL, NOT DECORATED. No tinted panel, no gradient,
                  // no coloured card behind the title. The only colour above
                  // the fold is the kicker and a hairline; everything else is
                  // type on the page's own ground, which is what every
                  // publication that expects to be read at length does.
                  //
                  // The rules above and below the byline are doing real work —
                  // they separate "what this is" from "who says so" from "the
                  // argument", which on a clinical page is the distinction that
                  // decides whether she trusts it.
                  _pad(Text(a.kicker.of(_lang).toUpperCase(),
                      style: _meta(s, color: s.accent))),
                  const SizedBox(height: 14),
                  _pad(Text(a.title.of(_lang),
                      style: pvFraunces(
                          fontSize: 32 * _fs,
                          height: 1.12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: s.ink))),
                  const SizedBox(height: 14),
                  // ⚠️ NOT ITALIC. A 17pt italic serif standfirst looks
                  // handsome in a mockup and is measurably harder to read on a
                  // phone at this length — the parenting reader sets its teaser
                  // in italic and it is the first thing that has to be
                  // re-read. Roman, one step down in colour, does the same job.
                  _pad(Text(a.teaser.of(_lang),
                      style: pvFraunces(
                          fontSize: 17.5 * _fs,
                          height: 1.55,
                          color: s.soft))),
                  const SizedBox(height: 22),
                  _pad(Divider(color: s.rule, height: 1)),
                  const SizedBox(height: 13),
                  _pad(_byline(s)),
                  const SizedBox(height: 13),
                  _pad(Divider(color: s.rule, height: 1)),
                  const SizedBox(height: 26),

                  // ---- THE LEDE --------------------------------------------
                  //
                  // ⚠️ FIRST, NOT LAST, AND THIS IS THE WHOLE POINT OF THE
                  // FIELD. The conditions page learned it the expensive way:
                  // put the definition first and the reassurance at the
                  // bottom, and the reassurance is read by nobody, because
                  // frightened people do not scroll. "How worried should I be"
                  // is the question she arrived with. Answer it, then explain.
                  _pad(_lede(s)),
                  const SizedBox(height: 28),

                  if (a.heroVideoSlot != null) ...[
                    _pad(_video(s, a.heroVideoSlot!)),
                    const SizedBox(height: 28),
                  ],

                  if (a.toc.length > 2) ...[
                    _pad(_contents(s)),
                    const SizedBox(height: 26),
                  ],

                  for (var i = 0; i < a.sections.length; i++)
                    _section(s, i, a.sections[i]),

                  if (a.faqs.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _pad(Text(
                        _t('Questions people actually ask',
                            'Sawaal jo log sach mein poochhte hain'),
                        style: _heading(s))),
                    const SizedBox(height: 6),
                    // ⚠️ AN ACCORDION, NOT A WALL. Five questions with their
                    // answers open is the single longest block on the page and
                    // the least likely to be read in order — she has one
                    // question, not five. Closed, the whole FAQ is five
                    // scannable lines.
                    for (var i = 0; i < a.faqs.length; i++)
                      _pad(_faq(s, i, a.faqs[i])),
                    const SizedBox(height: 18),
                  ],

                  // ---- WHEN TO SEE SOMEONE ---------------------------------
                  //
                  // Required on the model, so it cannot be the thing that got
                  // left off. CLAUDE.md: anything clinical ends by routing
                  // calmly to a doctor, and never contradicts her own.
                  _pad(_callout(s, a.whenToSeeSomeone)),
                  const SizedBox(height: 24),

                  if (a.evidence != null) ...[
                    _pad(_evidence(s)),
                    const SizedBox(height: 24),
                  ],

                  if (a.nextSteps.isNotEmpty) ...[
                    _pad(Text(_t('What you can do with this', 'Ab iska kya karein'),
                        style: _heading(s))),
                    const SizedBox(height: 12),
                    for (final n in a.nextSteps) _pad(_nextStep(s, n)),
                    const SizedBox(height: 14),
                  ],

                  if (a.relatedVideoSlots.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _pad(Text(_t('Watch on this', 'Ispar dekhein'),
                        style: _heading(s))),
                    const SizedBox(height: 12),
                    for (final v in a.relatedVideoSlots) ...[
                      _pad(_video(s, v)),
                      const SizedBox(height: 12),
                    ],
                  ],

                  if (a.readNext.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _pad(Divider(color: s.rule, height: 1)),
                    const SizedBox(height: 22),
                    _pad(Text(_t('Read next', 'Aage padhein'),
                        style: _heading(s))),
                    const SizedBox(height: 12),
                    for (final id in a.readNext) _pad(_readNext(s, id)),
                  ],
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  /// TTC still writes Hinglish in Latin script; pregnancy is Devanagari. This
  /// screen carries only chrome strings, and it picks by the language it was
  /// handed rather than by a store. See CLAUDE.md on why the enum is still
  /// called `hinglish`.
  String _t(String en, String hi) => _lang.isEnglish ? en : hi;

  // ---- top bar -------------------------------------------------------------

  Widget _topBar(_Skin s) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Row(children: [
          _iconBtn(s, Icons.arrow_back_rounded,
              () => Navigator.of(context).maybePop()),
          const Spacer(),
          // ⚠️ Only when there is something to navigate. A contents button on a
          // three-heading piece opens a sheet that is shorter than the scroll
          // it saves.
          if (a.toc.length > 2)
            _iconBtn(s, Icons.toc_rounded, () => _openToc(s)),
          _iconBtn(s, Icons.text_fields_rounded, () => _openSettings(s)),
          _iconBtn(
              s,
              _store.isSaved(a.id)
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              () => _store.toggleSave(a.id)),
          // NO SHARE BUTTON. See the head of this file — it goes in when it
          // shares, not before.
        ]),
      );

  Widget _iconBtn(_Skin s, IconData i, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(i, size: 21, color: s.ink)),
      );

  /// ⚠️ NO AVATAR. The circle held a generic person glyph, which is a picture
  /// of nobody — it added 34dp and a shape without adding a fact. On a clinical
  /// page the credential IS the identity, so the credential gets the space.
  Widget _byline(_Skin s) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.author.of(_lang),
                      style: pvJakarta(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: s.ink)),
                  const SizedBox(height: 3),
                  Text(a.authorRole.of(_lang),
                      style:
                          pvManrope(fontSize: 12, height: 1.4, color: s.soft)),
                ]),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text('${a.minutes} ${_t('MIN READ', 'MIN')}',
                style: _meta(s)),
          ),
        ],
      );

  /// The scale-setter, as a lede rather than as a card.
  ///
  /// ⚠️ WAS A FILLED PASTEL PANEL WITH AN ICON. On a hub that treatment is
  /// right; at the head of an article it is the loudest object on the page and
  /// it lands on the one sentence that most needs to read as considered rather
  /// than as a callout. A rule and a size change say "this matters" without
  /// shouting, which is how print has done it for two hundred years.
  Widget _lede(_Skin s) => Container(
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: s.accent, width: 2)),
        ),
        child: Text(a.scaleSetter.of(_lang),
            style: pvFraunces(
                fontSize: 19 * _fs,
                height: 1.58,
                fontWeight: FontWeight.w500,
                color: s.ink)),
      );

  /// "In this read" — closed by default.
  ///
  /// ⚠️ CLOSED, BECAUSE THE POINT IS TO SHORTEN THE PAGE. Seven headings open
  /// is 200dp of list before the first paragraph, which makes the article feel
  /// longer, not shorter — the opposite of why it is here. Closed it is one
  /// line that says how much there is and lets her jump.
  Widget _contents(_Skin s) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: s.rule),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _tocOpen = !_tocOpen),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 12, 13),
            child: Row(children: [
              Expanded(
                child: Text(
                    '${_t('IN THIS READ', 'IS READ MEIN')}  ·  '
                    '${a.toc.length} ${_t('SECTIONS', 'HISSE')}',
                    style: _meta(s)),
              ),
              Icon(
                  _tocOpen
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 20,
                  color: s.soft),
            ]),
          ),
        ),
        if (_tocOpen)
          for (var i = 0; i < a.sections.length; i++)
            if (a.sections[i].heading != null)
              GestureDetector(
                onTap: () => _jumpTo(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
                  decoration:
                      BoxDecoration(border: Border(top: BorderSide(color: s.rule))),
                  child: Text(a.sections[i].heading!.of(_lang),
                      style: pvManrope(
                          fontSize: 14, height: 1.4, color: s.ink)),
                ),
              ),
      ]),
    );
  }

  // ---- a section -----------------------------------------------------------

  Widget _section(_Skin s, int index, PvReadSection sec) {
    // ---- THE FOLDED FORM ----------------------------------------------------
    //
    // ⚠️ HEADING PLUS SUMMARY, NEVER HEADING ALONE. A closed box showing only
    // "The supplements you will be sold" is a door with no label — she has to
    // open it to discover whether she wanted it, which spends the tap the fold
    // was supposed to save. `PvRead.assertShape()` refuses a collapsible
    // section with no summary for exactly this reason.
    if (sec.collapsible && !_openSections.contains(index)) {
      final key = _headingKeys.putIfAbsent(index, () => GlobalKey());
      return Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: 14),
        child: _pad(GestureDetector(
          onTap: () => setState(() => _openSections.add(index)),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 12, 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: s.rule),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sec.heading!.of(_lang),
                          style: pvFraunces(
                              fontSize: 17.5 * _fs,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              color: s.ink)),
                      const SizedBox(height: 6),
                      Text(sec.summary!.of(_lang),
                          style: pvManrope(
                              fontSize: 13.5 * _fs,
                              height: 1.55,
                              color: s.soft)),
                    ]),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child:
                    Icon(Icons.add_rounded, size: 20, color: s.soft),
              ),
            ]),
          ),
        )),
      );
    }

    final kids = <Widget>[];

    if (sec.heading != null) {
      final key = _headingKeys.putIfAbsent(index, () => GlobalKey());
      kids.add(Padding(
        key: key,
        padding: const EdgeInsets.only(top: 14, bottom: 14),
        child: _pad(Row(children: [
          Expanded(child: Text(sec.heading!.of(_lang), style: _heading(s))),
          // A section that folded can fold again. One that never folds gets no
          // control, rather than a disabled one.
          if (sec.collapsible)
            GestureDetector(
              onTap: () => setState(() => _openSections.remove(index)),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.remove_rounded, size: 20, color: s.soft),
              ),
            ),
        ])),
      ));
    }

    for (final para in sec.paragraphs) {
      kids.add(Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: _pad(Text(para.of(_lang), style: _body(s))),
      ));
    }

    for (final b in sec.bullets) {
      kids.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: EdgeInsets.only(top: 10 * _fs),
            width: 5,
            height: 5,
            decoration:
                BoxDecoration(color: s.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(b.of(_lang),
                  style: _body(s).copyWith(fontSize: 16.5 * _fs, height: 1.62))),
        ])),
      ));
    }

    if (sec.callout != null) {
      kids.add(Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _pad(_callout(s, sec.callout!))));
    }
    if (sec.tip != null) {
      kids.add(Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _pad(_tip(s, sec.tip!))));
    }
    if (sec.mythFact != null) {
      kids.add(Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _pad(_mythFact(s, sec.mythFact!))));
    }
    if (sec.videoSlot != null) {
      kids.add(Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: _pad(_video(s, sec.videoSlot!))));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: kids);
  }

  // ---- the furniture -------------------------------------------------------

  Widget _callout(_Skin s, PvCallout c) {
    final (Color bar, IconData icon) = switch (c.tone) {
      PvCalloutTone.note => (s.accent, Icons.info_outline_rounded),
      PvCalloutTone.reassure =>
        (const Color(0xFF3F9E7C), Icons.favorite_border_rounded),
      // ⚠️ Amber, never red. A red box on a fertility page reads as an alarm
      // about her, and this box is about a symptom.
      PvCalloutTone.urgent =>
        (const Color(0xFFC98A25), Icons.phone_in_talk_outlined),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
      decoration: BoxDecoration(
        color: s.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: bar, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 17, color: bar),
          const SizedBox(width: 8),
          Expanded(
            child: Text(c.title.of(_lang),
                style: pvJakarta(
                    fontSize: 14.5 * _fs,
                    fontWeight: FontWeight.w700,
                    color: s.ink)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(c.body.of(_lang),
            style: pvManrope(fontSize: 14 * _fs, height: 1.62, color: s.soft)),
      ]),
    );
  }

  /// An open aside, not a dropdown.
  ///
  /// ⚠️ THIS WAS COLLAPSED AND IT WAS THE WRONG CALL. The reasoning was sound —
  /// an always-open tip box every few paragraphs turns a read into a leaflet —
  /// but the fix broke something worse. Walked on a device, "Why the order you
  /// eat things in matters" appeared mid-argument as a closed bar with a
  /// lightbulb, and the reviewer's reaction was the correct one: *"this
  /// randomly pops up in between. I don't understand. In the flow."*
  ///
  /// A closed box states a TITLE with no context and no visible relationship to
  /// the paragraph above it. It is not obviously an aside, not obviously
  /// optional, and not obviously connected — so it reads as an interruption
  /// whose purpose is unexplained, which is exactly what a random dropdown is.
  ///
  /// Open, labelled and set against a rule, it is instantly legible as what it
  /// is: a practical note attached to the argument beside it. The three lines it
  /// costs are bought back by the folded reference sections and the FAQ
  /// accordion, which fold things she genuinely may not want — a tip placed
  /// deliberately next to the paragraph it belongs to is not one of those.
  Widget _tip(_Skin s, PvReadTip tip) => Container(
        padding: const EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: s.rule, width: 3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_t('IN PRACTICE', 'AMAL MEIN'), style: _meta(s)),
          const SizedBox(height: 7),
          Text(tip.title.of(_lang),
              style: pvJakarta(
                  fontSize: 14.5 * _fs,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: s.ink)),
          const SizedBox(height: 7),
          Text(tip.body.of(_lang),
              style:
                  pvManrope(fontSize: 14 * _fs, height: 1.68, color: s.soft)),
        ]),
      );

  /// ⚠️ NO TICK, NO CROSS, NO RED AND GREEN.
  ///
  /// The first build put the myth behind a red ✗ in a circle and the fact
  /// behind a green ✓, which the reviewer called childish and gimmicky, and
  /// which is worse than a style problem on this particular surface: a red
  /// cross beside a sentence she may well believe reads as marking HER wrong.
  /// A woman who has been told to lie down for twenty minutes afterwards was
  /// told it by her mother.
  ///
  /// So it is set as an editorial correction instead — the claim in the quieter
  /// ink, a rule, then what is actually true in the darker ink. The typography
  /// carries the judgment and nothing scolds. Same two facts, no scorekeeping.
  Widget _mythFact(_Skin s, PvMythFact m) => Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: s.rule),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_t('COMMONLY BELIEVED', 'AAM TAUR PAR MAANA JAATA HAI'),
              style: _meta(s)),
          const SizedBox(height: 8),
          Text(m.myth.of(_lang),
              style: pvFraunces(
                  fontSize: 16 * _fs,
                  height: 1.55,
                  fontStyle: FontStyle.italic,
                  color: s.soft)),
          const SizedBox(height: 14),
          Divider(height: 1, color: s.rule),
          const SizedBox(height: 14),
          Text(_t('WHAT IS ACTUALLY TRUE', 'SACH KYA HAI'),
              style: _meta(s, color: s.accent)),
          const SizedBox(height: 8),
          Text(m.fact.of(_lang),
              style: pvManrope(
                  fontSize: 14.5 * _fs, height: 1.68, color: s.ink)),
        ]),
      );

  Widget _faq(_Skin s, int index, PvReadFaq f) {
    final open = _openFaqs.contains(index);
    return Container(
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: s.rule))),
      child: GestureDetector(
        onTap: () => setState(
            () => open ? _openFaqs.remove(index) : _openFaqs.add(index)),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(f.question.of(_lang),
                    style: pvJakarta(
                        fontSize: 15 * _fs,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                        color: s.ink)),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(open ? Icons.remove_rounded : Icons.add_rounded,
                    size: 19, color: s.soft),
              ),
            ]),
            if (open) ...[
              const SizedBox(height: 10),
              Text(f.answer.of(_lang),
                  style: pvManrope(
                      fontSize: 14.5 * _fs, height: 1.72, color: s.soft)),
            ],
          ]),
        ),
      ),
    );
  }

  /// ⚠️ VISIBLE, NOT A FOOTNOTE. An unsourced claim in a fertility article is
  /// indistinguishable from the content this product exists to replace, so the
  /// sourcing is set at reading size and given its own rule above it.
  Widget _evidence(_Skin s) => Container(
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: s.rule),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.verified_outlined, size: 16, color: s.soft),
            const SizedBox(width: 8),
            Text(_t('WHERE THIS COMES FROM', 'YE KAHAN SE AAYA'),
                style: _meta(s)),
          ]),
          const SizedBox(height: 9),
          Text(a.evidence!.of(_lang),
              style: pvManrope(fontSize: 13 * _fs, height: 1.65, color: s.soft)),
        ]),
      );

  // ---- video ---------------------------------------------------------------

  /// ⚠️ ONE CALL SITE FOR BOTH STATES, and the model's `url` decides which.
  ///
  /// A film with no file renders as `PvVideoPlaceholder` — real 16:9 geometry,
  /// real title, real duration, a quiet coming-soon, and NOT tappable. A film
  /// with a file gets an identical-looking card that opens. Same geometry both
  /// ways, so the page can be judged today and nothing shifts when files land.
  Widget _video(_Skin s, String slot) {
    final v = widget.resolveVideo?.call(slot);
    if (v == null) {
      // A slot with no entry is a wiring mistake, not a design state. Render
      // nothing rather than an empty box — and the shape test catches it.
      return const SizedBox.shrink();
    }
    return PvVideoPlaceholder(
      title: v.title.of(_lang),
      subtitle: v.why.of(_lang),
      duration: v.durationLabel,
      hue: v.hue,
      slotId: v.id,
      // ⚠️ FLAT INSIDE A READ. The diagonal gradient is right on a hub, where a
      // thumbnail competes with tiles for attention. At the head of an article
      // it is the loudest object on a page that is trying to read as editorial.
      // Same component, restrained skin — not a fifth bespoke video block.
      flat: true,
      onTap: v.isLive
          ? () => widget.openSurface?.call(context, 'video/${v.id}')
          : null,
    );
  }

  // ---- the foot ------------------------------------------------------------

  Widget _nextStep(_Skin s, PvReadNextStep n) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SolutionCard(
          type: switch (n.kind) {
            PvNextKind.read => SolutionType.read,
            PvNextKind.watch => SolutionType.watch,
            PvNextKind.tool => SolutionType.tool,
            PvNextKind.activity => SolutionType.activity,
            PvNextKind.product => SolutionType.product,
            PvNextKind.course => SolutionType.course,
            PvNextKind.consult => SolutionType.consult,
          },
          title: n.title,
          value: n.value,
          p: V2PaletteStore.instance.current,
          lang: _lang,
          onTap: () {
            if (n.action != null) {
              widget.openAction?.call(context, n.action!);
            } else if (n.surfaceId != null) {
              widget.openSurface?.call(context, n.surfaceId!);
            }
          },
        ),
      );

  Widget _readNext(_Skin s, String id) {
    final title = widget.readTitle?.call(id);
    if (title == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => widget.openRead?.call(context, id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 13, 15),
          decoration: BoxDecoration(
            color: s.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: s.rule),
          ),
          child: Row(children: [
            Expanded(
              child: Text(title.of(_lang),
                  style: pvFraunces(
                      fontSize: 16 * _fs,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: s.ink)),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 18, color: s.soft),
          ]),
        ),
      ),
    );
  }

  // ---- the two sheets ------------------------------------------------------

  void _openToc(_Skin s) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: s.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
            child: Text(_t('In this read', 'Is read mein'), style: _meta(s)),
          ),
          for (var i = 0; i < a.sections.length; i++)
            if (a.sections[i].heading != null)
              ListTile(
                title: Text(a.sections[i].heading!.of(_lang),
                    style: pvManrope(
                        fontSize: 15, height: 1.4, color: s.ink)),
                onTap: () {
                  Navigator.of(context).pop();
                  _jumpTo(i);
                },
              ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _openSettings(_Skin s) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: s.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final live = _skin(V2PaletteStore.instance.current);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_t('Text size', 'Text ka size'),
                        style: _meta(live))),
                const SizedBox(height: 6),
                Row(children: [
                  Text('A', style: pvFraunces(fontSize: 14, color: live.soft)),
                  Expanded(
                    child: Slider(
                      value: _store.fontScale,
                      min: 0.85,
                      max: 1.4,
                      divisions: 11,
                      activeColor: live.accent,
                      onChanged: _store.setFontScale,
                    ),
                  ),
                  Text('A', style: pvFraunces(fontSize: 22, color: live.ink)),
                ]),
                const SizedBox(height: 14),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_t('Reading mode', 'Padhne ka mode'),
                        style: _meta(live))),
                const SizedBox(height: 12),
                Row(children: [
                  for (final m in PvReadMode.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _modeChip(live, m),
                      ),
                    ),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _modeChip(_Skin s, PvReadMode m) {
    final on = _store.mode == m;
    final swatch = switch (m) {
      PvReadMode.light => const Color(0xFFFFFFFF),
      PvReadMode.sepia => const Color(0xFFF4ECD8),
      PvReadMode.dark => const Color(0xFF17151C),
    };
    final label = switch (m) {
      PvReadMode.light => _t('Light', 'Light'),
      PvReadMode.sepia => _t('Sepia', 'Sepia'),
      PvReadMode.dark => _t('Dark', 'Dark'),
    };
    return GestureDetector(
      onTap: () => _store.setMode(m),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: s.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: on ? s.accent : s.rule, width: on ? 1.6 : 1),
        ),
        child: Column(children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border: Border.all(color: s.rule)),
          ),
          const SizedBox(height: 7),
          Text(label,
              style: pvManrope(
                  fontSize: 12,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                  color: on ? s.accent : s.soft)),
        ]),
      ),
    );
  }
}

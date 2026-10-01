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

import '../../widgets/global_ask_fab.dart';

import '../../data/reads/read_images.dart';
import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../models/pv_video_slot.dart';
import '../../services/pv_read_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_placeholders.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_solution_cards.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart' show V3BracketArt, bracketMarkFor;
import '../../data/brackets/ttc_brackets.dart' show kTtcBrackets;

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
    this.hero,
    this.openAtHeading,
    this.resolveRead,
    this.customBlock,
    this.onReadToEnd,
  });

  final PvRead read;

  /// An optional picture above the masthead.
  ///
  /// ⚠️ A WIDGET, NOT A URL, AND THAT KEEPS THE READER STAGE-NEUTRAL. This
  /// screen renders pregnancy, parenting and TTC; if it took an image URL it
  /// would own the fallback behaviour, the sizing and the licence question for
  /// all three. Taking a widget means the caller decides what a hero IS — TTC
  /// hands it a photograph that degrades to drawn art — and the reader only
  /// decides where it goes.
  ///
  /// ⚠️ NULL EVERYWHERE ELSE, so pregnancy and parenting render exactly the
  /// masthead they always have. Same data-not-flag move as the hub's film.
  final Widget? hero;

  /// Open scrolled to the section whose heading matches this, exactly.
  ///
  /// ⚠️ THE MECHANISM BEHIND "PROMOTE", AND WITHOUT IT PROMOTION IS A LIE.
  ///
  /// The After-a-loss rebuild asks for six cards that "reference a section
  /// inside one of the two existing articles — single source, shown twice,
  /// never copied". Built with `readId` alone, all six open the same article at
  /// the top, and a woman who tapped "Rh status and retained tissue" is left
  /// scrolling a two-thousand-word piece looking for the paragraph she was
  /// promised. That is worse than a copy, because it looks like it worked.
  ///
  /// Matching on the heading TEXT rather than an index is deliberate: an index
  /// silently points at the wrong section the day somebody inserts a paragraph,
  /// and a wrong section is unnoticeable in review. A heading that no longer
  /// exists simply opens at the top, which is the safe failure — and
  /// `ttc_after_loss_test.dart` asserts every anchor still resolves, so it does
  /// not fail silently either.
  final String? openAtHeading;

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

  /// The whole read behind a Read next id, when the stage can hand it over —
  /// its teaser and picture make the card the same tile as the tools above it
  /// (the user, 2026-09-17: "the read next… can be the way it's above for the
  /// tools"). Falls back to [readTitle] when absent, so nothing that only
  /// passes titles breaks.
  final PvRead? Function(String readId)? resolveRead;

  /// Renders a section's `custom` block — see `PvReadSection.custom`. The
  /// stage that wrote the block hands the widget back; the reader only
  /// decides where it goes. A section with a custom block and no renderer
  /// draws nothing for it, which the parenting adapter's test guards.
  final Widget Function(BuildContext context, Object block)? customBlock;

  /// Fired once, the first time she scrolls past nine-tenths of the piece.
  ///
  /// ⚠️ DERIVED, NEVER ASKED — 2026-09-18. Two of the retired readers ended
  /// with a filled "Mark as read" / "Mark as done" button; the user on the
  /// phone: "makes no sense to be there… doesn't change anything… again a
  /// clutter." The one thing those buttons did that mattered — ticking the
  /// home's daily-reads box — now happens because she read it, which is the
  /// only honest signal anyway. The stage that keeps the record passes this.
  final VoidCallback? onReadToEnd;

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

  /// The section a card opened this read at, shown as a pill until she heads
  /// back up (2026-09-30), or null.
  String? _openedAt;
  bool _reachedEnd = false;

  /// "▸ References" — collapsed by default (READER-AUDIT §3.2 rule 2). Session
  /// scoped like the sections: which disclosures were open is not a
  /// preference.
  bool _refsOpen = false;

  PvRead get a => widget.read;
  AppLanguage get _lang => widget.lang;
  PvReadStore get _store => PvReadStore.instance;

  @override
  void initState() {
    super.initState();
    _sc.addListener(_onScroll);
    _store.load();

    // ⚠️ RESUME IS OFF. AN ARTICLE ALWAYS OPENS AT THE TOP.
    //
    // This restored her last position on any read she was between 5% and 92%
    // through, and the reasoning below still holds in the abstract — jumping
    // someone to 3% is worse than the top, and to 97% worse still.
    //
    // What it did in practice is what got it removed: reported as "it starts
    // from the center, which makes no sense". And that is the real cost of
    // resume on SHORT content. On a 2,500-word piece, coming back to where you
    // stopped is a kindness. On a 700-word piece with a picture at the top, it
    // means the reader never sees the header, cannot tell whether they opened
    // the right article, and has to scroll UP to orient — which nobody does,
    // because scrolling up looks like leaving.
    //
    // If it comes back it should be conditional on length, and it should show
    // a "jump to where you were" control rather than moving her silently.
    // Silent repositioning is the part that reads as a bug.
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!mounted || !_sc.hasClients) return;
    //   final p = _store.progressOf(a.id);
    //   if (p > 0.05 && p < 0.92) {
    //     _sc.jumpTo(p * _sc.position.maxScrollExtent);
    //   }
    // });

    // ⚠️ AND THIS IS NOT RESUME. The note above is about restoring a position
    // she left — silent, invisible, and reported as a bug. This is the
    // opposite: she tapped a card that named a section, and arriving at that
    // section is the thing she asked for. It only ever fires when a caller
    // passed a heading.
    final heading = widget.openAtHeading;
    if (heading == null) return;
    final i = a.sections.indexWhere((s) => s.heading?.en == heading);
    if (i < 0) return; // A heading that no longer exists opens at the top.
    // ⚠️ SAID, NOT SILENT (2026-09-30, the user: articles "navigate to a
    // random position inside them"). The jump was right (the card asked a
    // question this section answers) but invisible, so it read as a bug. A
    // pill now says where she was taken and offers the top.
    _openedAt = heading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _jumpTo(i);
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
    // Back near the top: the "opened at" pill has done its job.
    if (_openedAt != null && _sc.offset < 60) setState(() => _openedAt = null);
    _store.setProgress(a.id, p);
    if (!_reachedEnd && p >= 0.9) {
      _reachedEnd = true;
      widget.onReadToEnd?.call();
    }
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
              child: Stack(children: [
              ListView(
                controller: _sc,
                // The FAB's reserve only while the FAB exists (kAskFabEnabled,
                // 2026-09-19) — with it off this was a blank band under Read
                // next on every read.
                padding: const EdgeInsets.only(
                    top: 10, bottom: (FabState.kAskFabEnabled ? kAskFabReserve : 0) + 24),
                children: [
                  // ---- THE PICTURE, WHERE THERE IS ONE ---------------------
                  //
                  // ⚠️ 132pt, FULL BLEED, AND THE TITLE IS *NOT* ON IT.
                  //
                  // The first version was 210pt with the title reversed out
                  // over a scrim. That looks handsome in a mockup and costs
                  // more than it earns on a phone: at 210 the picture plus the
                  // byline filled the first screen, so the reader arrived at an
                  // article and could not see a word of the article. Type over
                  // a photograph also has to survive whatever the photograph
                  // does, which means a scrim, which means dimming the picture
                  // to protect two lines of text.
                  //
                  // 132 with the title beneath solves both: the photo is
                  // decoration and behaves like it, the title is type on a page
                  // and is set as such, and the body starts on screen one. That
                  // last point is the whole test of an article header.
                  //
                  // ⚠️ EDGE TO EDGE, not inset with a radius. An inset picture
                  // reads as a card ABOUT the article; a full-bleed one reads
                  // as the top of it.
                  // ⚠️ ALWAYS, SINCE 2026-09-17 — "I need an image on top."
                  // The caller's `hero` when it passes one (TTC's drawn art
                  // that a photo upgrades), else the read's own picture, else
                  // the tinted band with the article mark — the same frame in
                  // every case, so every article has the same head whether or
                  // not its picture has been chosen yet (`_defaultHero`).
                  SizedBox(
                    height: 132,
                    width: double.infinity,
                    // Half-speed parallax, clamped so an overscroll bounce
                    // cannot drag the image out of its frame. Scoped to this
                    // subtree, so a 2,000-word article is not relaying out on
                    // every frame of a scroll.
                    child: ClipRect(
                      child: AnimatedBuilder(
                        animation: _sc,
                        builder: (context, child) {
                          final off = _sc.hasClients ? _sc.offset : 0.0;
                          return Transform.translate(
                              offset: Offset(0, (off * 0.4).clamp(0.0, 132.0)),
                              child: child);
                        },
                        child: widget.hero ?? _defaultHero(s),
                      ),
                    ),
                  ),
                  // The photograph's credit — a CC BY picture is only free
                  // with its author named, and every publication prints one.
                  // Tiny, grey, under the frame; absent when there is no
                  // photograph or the picture carries no licence to honour.
                  if (_photoCredit case final credit?) ...[
                    const SizedBox(height: 6),
                    _pad(Text('Photo · $credit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 9.5,
                            letterSpacing: 0.2,
                            color: s.soft.withValues(alpha: 0.8)))),
                    const SizedBox(height: 8),
                  ] else
                    const SizedBox(height: 14),

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
                  // ⚠️ THE KICKER IS COMMENTED OUT, NOT DELETED.
                  //
                  // "FERTILE WINDOW" in purple caps sat above the title of
                  // every article in the stage, and the objection to it was
                  // exactly right: an article is not owned by the section it
                  // was opened from. The same piece is reachable from the
                  // checklist, from a journey step, from search and from
                  // another article's read-next — and on every one of those the
                  // kicker named a place the reader had not been.
                  //
                  // It also cost a full line of the most valuable space on the
                  // screen to say something the reader already knew.
                  //
                  // Kept because a kicker is right where a piece really does
                  // belong to one series, which is how the parenting stage uses
                  // it. `PvRead.kicker` stays on the model for that reason.
                  //
                  // _pad(Text(a.kicker.of(_lang).toUpperCase(),
                  //     style: _meta(s, color: s.accent))),
                  // const SizedBox(height: 14),
                  // ⚠️ 24, NOT 32, WHERE THERE IS A PICTURE ABOVE IT. A
                  // 32pt title under a 132pt photo pushes the byline off the
                  // fold and undoes the reason the photo was shortened.
                  // One geometry — every article has a picture frame now, so
                  // the 32/17.5 no-picture sizes retired with it (2026-09-17).
                  _pad(Text(a.title.of(_lang),
                      style: pvFraunces(
                          fontSize: 24 * _fs,
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
                          fontSize: 14.5 * _fs,
                          height: 1.5,
                          color: s.soft))),
                  const SizedBox(height: 14),
                  _pad(_byline(s)),
                  const SizedBox(height: 14),
                  _pad(Divider(color: s.rule, height: 1)),
                  const SizedBox(height: 16),

                  // ---- THE LEDE --------------------------------------------
                  //
                  // ⚠️ FIRST, NOT LAST, AND THIS IS THE WHOLE POINT OF THE
                  // FIELD. The conditions page learned it the expensive way:
                  // put the definition first and the reassurance at the
                  // bottom, and the reassurance is read by nobody, because
                  // frightened people do not scroll. "How worried should I be"
                  // is the question she arrived with. Answer it, then explain.
                  // A piece with no scale-setter — a chart page that opens on
                  // its chart — draws no empty rule (2026-09-18).
                  // ---- THE SHORT ANSWER ------------------------------------
                  //
                  // Before the lede, because it is the answer and the lede is
                  // the scale. Absent on reads that have not written one.
                  if ((a.shortAnswer?.of(_lang).trim() ?? '').isNotEmpty) ...[
                    _pad(_shortAnswer(s)),
                    const SizedBox(height: 22),
                  ],

                  // ⚠️ ONE "ANSWER FIRST" BLOCK, NOT TWO (review R2,
                  // 2026-09-26). With a short answer above, the lede is the
                  // first paragraph under it, without its own rule, so the
                  // page does not open on two different treatments of the
                  // same idea.
                  // ⚠️ AND NOT AT ALL UNDER A SHORT ANSWER (the user,
                  // 2026-09-27): the lede restated the short answer in other
                  // words, so she read the point twice before the article
                  // began (three times with the standfirst). The short answer
                  // is the one "answer first" block; a read without one keeps
                  // its lede. Kept for revert: the lede drawn unruled here.
                  if (a.scaleSetter.of(_lang).trim().isNotEmpty &&
                      (a.shortAnswer?.of(_lang).trim() ?? '').isEmpty) ...[
                    _pad(_lede(s, ruled: true)),
                    const SizedBox(height: 28),
                  ],

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

                  // ---- REFERENCES, collapsed, then "was this helpful?" ----
                  //
                  // References are present and last (Flo, Superpower, GoHenry)
                  // but folded: the sources are for the reader who wants to
                  // check, not a block every reader scrolls past. The helpful
                  // question comes straight after the piece has finished
                  // making its case and before the app starts suggesting
                  // things — GoHenry's placement, our design system's pills.
                  if (a.evidence != null) ...[
                    _pad(_references(s)),
                    const SizedBox(height: 18),
                  ],
                  _pad(_helpful(s)),
                  const SizedBox(height: 26),

                  if (a.nextSteps.isNotEmpty) ...[
                    _pad(Text(_t('What you can do with this', 'Ab iska kya karein'),
                        style: _heading(s))),
                    const SizedBox(height: 12),
                    _pad(_nextStepGrid(s, a.nextSteps)),
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
                    // A rail, two cards visible, never a wall — the Flo
                    // teardown's rule for Insights, applied to the foot of a
                    // read. Kept for revert (the stacked rows):
                    // for (final id in a.readNext) _pad(_readNext(s, id)),
                    _readNextRail(s),
                  ],
                ],
              ),
              // "Opened at …" (2026-09-30): where a card took her, and the top.
              if (_openedAt case final h?)
                Positioned(
                  top: 10,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Material(
                      key: const ValueKey('pv_reader_opened_at'),
                      color: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.black26,
                      shape: const StadiumBorder(),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: () {
                          setState(() => _openedAt = null);
                          if (_sc.hasClients) {
                            _sc.animateTo(0,
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Flexible(
                              child: Text(
                                'Opened at: $h',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pvManrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: s.soft),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_upward_rounded,
                                size: 14, color: s.ink),
                            const SizedBox(width: 3),
                            Text('Top',
                                style: pvManrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: s.ink)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
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

  /// The picture frame when the caller passes no `hero`: the read's own
  /// photograph, or — until one is chosen — the article's type-tinted band
  /// with the mark cropped by the edge, the same device as the tiles at the
  /// foot. A photo that fails to load falls back to the band, so the frame
  /// never renders empty.
  /// The credit to print under the frame, or null when the frame holds the
  /// caller's own hero, no photograph, or a picture without a licence line.
  String? get _photoCredit {
    if (widget.hero != null) return null;
    if (readImageFor(a.id, own: a.imageUrl) == null) return null;
    return kReadImageCredits[a.id];
  }

  Widget _defaultHero(_Skin s) {
    final p = V2PaletteStore.instance.current;
    // ⚠️ A TRYING-TO-CONCEIVE READ WEARS ITS DOOR (2026-09-27, the user: the
    // grey band with a white book looked like a placeholder, which it was).
    // Until a photograph is chosen, the frame is the door's own tint with the
    // door's drawn mark, the same mark the home grid and the door show. Only
    // reads whose kicker is a TTC door; every other read keeps the band below.
    final door = [
      for (final b in kTtcBrackets)
        if (b.label.en == a.kicker.en) b
    ].firstOrNull;
    final doorMark = door == null ? null : bracketMarkFor(door.id);
    if (door != null && doorMark != null) {
      final tint = v2BlockTint(door.hue, p);
      final url = readImageFor(a.id, own: a.imageUrl);
      final art = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tint,
              HSLColor.fromColor(tint).withLightness(0.80).toColor(),
            ],
          ),
        ),
        child: Stack(children: [
          Positioned(
            right: 18,
            top: 10,
            bottom: 10,
            child: AspectRatio(
              aspectRatio: 1,
              child: V3BracketArt(mark: doorMark, tint: tint),
            ),
          ),
        ]),
      );
      if (url == null || url.isEmpty) return art;
      return Image.network(url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => art,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : art);
    }
    final band = ColoredBox(
      color: v2BlockTint(SolutionType.read.hue, p),
      child: Stack(children: [
        Positioned(
          right: -18,
          bottom: -22,
          child: Icon(SolutionType.read.icon,
              size: 132, color: Colors.white.withValues(alpha: 0.42)),
        ),
      ]),
    );
    // The read's own picture, else the table's (read_images.dart).
    final url = readImageFor(a.id, own: a.imageUrl);
    if (url == null || url.isEmpty) return band;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => band,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : band,
    );
  }

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
              // The title travels with the bookmark — see `toggleSave`.
              () => _store.toggleSave(a.id, title: a.title.en, subtitle: a.kicker.en)),
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
  /// Avatar, name, and everything else on one line.
  ///
  /// ⚠️ ONE META LINE, NOT THREE STACKED FACTS. This was a name, a role on its
  /// own line, and a "6 MIN READ" pushed out to the right margin — three
  /// separate things competing above the fold, and the read time so far from
  /// the name it read as a section label.
  ///
  /// Role, review date and read time are all the same KIND of information:
  /// reasons to trust this and know what it costs you. Collapsed into one
  /// muted line they take one row instead of three and read as a single
  /// credential.
  ///
  /// ⚠️ INITIALS, NOT A PHOTOGRAPH. There are no author photographs in this
  /// product and inventing an avatar image pipeline for a byline is not the
  /// job. Initials in a tinted circle is the convention every publication with
  /// this problem already uses, and it degrades to nothing if a name is ever
  /// missing.
  Widget _byline(_Skin s) {
    final name = a.author.of(_lang);
    final initials = name
        .replaceAll(RegExp(r'^(Dr\.?|Prof\.?)\s+', caseSensitive: false), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    // ⚠️ "REVIEWED BY", NOT "BY" — and the verified mark sits on the PERSON.
    // From the reader audit (docs/READER-AUDIT.md §3.2 rule 1): Flo's medical-
    // board badge was the single most trust-carrying element in fifteen
    // readers, and every one of our models already holds a name and a role.
    // The mark used to sit on the evidence block at the foot, where it said
    // "this text was checked"; here it says "this person checked it", which
    // is the claim she actually wants made. The blue is the learned glyph —
    // see the note that travelled with it from the old evidence block.
    final verified = s.bg.computeLuminance() < 0.4
        ? const Color(0xFF52A9F5)
        : const Color(0xFF1668C1);
    return Row(children: [
      Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: s.accent.withValues(alpha: 0.16), shape: BoxShape.circle),
        child: Text(initials,
            style: pvManrope(
                fontSize: 11.5, fontWeight: FontWeight.w800, color: s.accent)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.reviewed ? _t('REVIEWED BY', 'JAANCH KI') : _t('BY', 'LEKHAK'),
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: s.soft)),
              const SizedBox(height: 2),
              Row(children: [
                Flexible(
                  child: Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: s.ink)),
                ),
                if (a.reviewed) ...[
                  const SizedBox(width: 5),
                  Icon(Icons.verified_rounded, size: 14, color: verified),
                ],
              ]),
              const SizedBox(height: 1),
              // \u26A0\uFE0F NO READING TIME ON A PIECE READ IN SECONDS (the user,
              // 2026-09-28: a daily tip is "way less" than the minutes it
              // claimed). `minutes` rounds up and never goes below one, so a
              // sixty-word tip wore a read time beside articles ten times its
              // length. Under 200 words (a minute at the rate `minutes` uses)
              // the role line stands alone. Kept for revert: the role and the
              // minutes always.
              Text(
                  a.wordCount +
                              (a.shortAnswer?.en ?? '')
                                  .split(RegExp(r'\s+'))
                                  .length <
                          200
                      ? a.authorRole.of(_lang)
                      : '${a.authorRole.of(_lang)} \u00B7 '
                          '${a.minutes} ${_t('min', 'min')}',
                  maxLines: 2,
                  style: pvManrope(fontSize: 11, height: 1.35, color: s.soft)),
            ]),
      ),
    ]);
  }

  /// "The short answer": the eyebrow, then two or three sentences set a size
  /// up, BETWEEN TWO HAIRLINES, the reader's own aside form.
  ///
  /// ⚠️ NOT A TINTED BOX (review R1, 2026-09-26). It was a paragraph on an
  /// `accent @ 8%` rounded rectangle, which is exactly the "lavender panel for
  /// a callout" DESIGN-SYSTEM §4.0 addendum 1 banned. The hairlines and the
  /// weight say "this is the answer" without a fill. Mobbin: Gentler Streak's
  /// bold lede as the short answer, no box (GS-LEDE,
  /// https://mobbin.com/screens/d2190af3-708e-414c-aac4-cae0effcde8b); Clue's
  /// "Top things to know" under the byline, no box (CLUE-TOP,
  /// https://mobbin.com/screens/8aa23c54-85d1-4da6-acf6-53d62ded4628).
  /// Blinkist's tinted key takeaways (BLINK-KT) is the counter-example.
  ///
  /// ⚠️ THE EYEBROW IS ENGLISH ONLY (R3). It carried `'SEEDHA JAWAB'`, a new
  /// Hindi string in Latin script, which CLAUDE.md dropped ("Hinglish in
  /// Latin script") and new work is English. Kept for revert:
  ///   Container(padding: 16/14/16/16, decoration: BoxDecoration(
  ///     color: s.accent.withValues(alpha: 0.08),
  ///     borderRadius: BorderRadius.circular(14)), child: ...
  ///   Text(_t('THE SHORT ANSWER', 'SEEDHA JAWAB'), style: _meta(s))
  Widget _shortAnswer(_Skin s) => Container(
        key: const ValueKey('pv_reader_short_answer'),
        width: double.infinity,
        // ⚠️ NO HAIRLINES (the user, 2026-09-27: "two lines above the short
        // answer, for what reason?"). The byline's rule sits just above, so
        // the top hairline made two stacked lines, and the bottom one a third.
        // The eyebrow and the weight carry "this is the answer"; space does
        // the separating. Kept for revert: vertical 14 padding and
        // Border(top: s.rule, bottom: s.rule).
        padding: const EdgeInsets.only(top: 2, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('THE SHORT ANSWER', style: _meta(s)),
            const SizedBox(height: 8),
            Text(a.shortAnswer!.of(_lang),
                style: pvManrope(
                    fontSize: 15.5 * _fs,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                    color: s.ink)),
          ],
        ),
      );

  /// The scale-setter, as a lede rather than as a card.
  ///
  /// ⚠️ WAS A FILLED PASTEL PANEL WITH AN ICON. On a hub that treatment is
  /// right; at the head of an article it is the loudest object on the page and
  /// it lands on the one sentence that most needs to read as considered rather
  /// than as a callout. A rule and a size change say "this matters" without
  /// shouting, which is how print has done it for two hundred years.
  ///
  /// [ruled] is false under a short answer (R2): the same words and face, no
  /// rule, so there is one "answer first" treatment on the page.
  Widget _lede(_Skin s, {bool ruled = true}) => Container(
        padding: EdgeInsets.only(left: ruled ? 16 : 0),
        decoration: BoxDecoration(
          border: ruled
              ? Border(left: BorderSide(color: s.accent, width: 2))
              : null,
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
          onTap: () {
            pvCommitFeedback();
            setState(() => _tocOpen = !_tocOpen);
          },
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
              AnimatedRotation(
                turns: _tocOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Icon(Icons.expand_more_rounded, size: 20, color: s.soft),
              ),
            ]),
          ),
        ),
        // Unfolds (2026-09-19) rather than appearing.
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(children: [
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
                // Ink, not the accent (2026-09-18) — a violet dot beside a
                // coral one read as two systems. Kept for revert: s.accent.
                BoxDecoration(color: s.ink, shape: BoxShape.circle),
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
    if (sec.custom case final block?) {
      if (widget.customBlock case final render?) {
        kids.add(Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _pad(render(context, block))));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: kids);
  }

  // ---- the furniture -------------------------------------------------------

  /// An aside set between rules, not a coloured box.
  ///
  /// ⚠️ THE BOX WAS THE PROBLEM, NOT THE COLOUR — and the objection said so
  /// precisely: *"initially if you look in the article reader that we have, it
  /// looks very clean and minimalistic... and suddenly these things come and it
  /// just ruins it. Now this is not an issue with it being purple. It's an
  /// issue with the structure."*
  ///
  /// That is exactly right, and it is worth naming the mechanism because the
  /// instinct that produced it is a common one. This was a filled panel with a
  /// 3px coloured bar down its left edge and a 16pt corner radius — three
  /// separate devices, all saying "this is a different KIND of thing". On a
  /// page whose entire visual argument is quiet type on a plain ground, a
  /// filled rounded rectangle is the loudest object present. It does not read
  /// as emphasis; it reads as a component from a different app that landed
  /// mid-paragraph. The left bar makes it worse by adding a vertical the page
  /// has nowhere else, so it looks pinned on rather than set in.
  ///
  /// A magazine solves this with rules and space, which is what the reader
  /// already uses around the byline. So: a hairline above, the note, a hairline
  /// below. No fill, no radius, no border. The aside is separated by the same
  /// device the rest of the page is separated by, so it belongs to it.
  ///
  /// ⚠️ TONE SURVIVES AS AN ICON AND A RULE WEIGHT. It still has to be possible
  /// to tell "worth knowing" from "call someone" at a glance — an urgent
  /// callout that looks identical to a note is a safety problem, not a style
  /// one. Urgent gets a heavier top rule in its own colour; the others get the
  /// page's own hairline. One signal, no container.
  Widget _callout(_Skin s, PvCallout c) {
    // ⚠️ NO COLOUR ON A CLINICAL CALLOUT — 2026-09-17, the base-UI rule
    // (DESIGN-SYSTEM §4.0) applied to the one place the reader still spent
    // it. The amber rule and tinted icon read as "gimmicky and random" on the
    // phone, and the user was right: colour was doing a container's job.
    // The safety distinction the old note insisted on — urgent must be told
    // apart from a note at a glance — is kept, and kept in FORM: the urgent
    // callout is the one callout that sits in a well (panel, radius 16, ink
    // icon); note and reassure sit inline between hairlines. One signal,
    // no colour. Kept for revert: amber 0xFFC98A25 / green 0xFF3F9E7C tones.
    final icon = switch (c.tone) {
      PvCalloutTone.note => Icons.info_outline_rounded,
      PvCalloutTone.reassure => Icons.favorite_border_rounded,
      PvCalloutTone.urgent => Icons.phone_in_talk_outlined,
    };
    final urgent = c.tone == PvCalloutTone.urgent;

    final body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: s.ink),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(c.title.of(_lang),
              style: pvManrope(
                  fontSize: 14.5 * _fs,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: s.ink)),
        ),
      ]),
      const SizedBox(height: 7),
      Text(c.body.of(_lang),
          style: pvManrope(fontSize: 14 * _fs, height: 1.62, color: s.soft)),
    ]);

    // ⚠️ NO PANEL — 2026-09-18, the door walk. The urgent callout sat in a
    // tinted well (radius 16) and the user's words were "a big blob thrown
    // at the screen". Flo's "seek immediate medical help if" is the form
    // now: an ink rule, the heading in the display face, the body's bullet
    // lines as a list with one coral dot each, the rest in grey. The dot is
    // the only colour and it is the one signal that says "call". Kept for
    // revert: Container(color: s.panel, radius 16, border: s.rule).
    if (urgent) {
      final lines = c.body.of(_lang).split('\n');
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 1.5, color: s.ink),
        const SizedBox(height: 14),
        Text(c.title.of(_lang),
            style: pvFraunces(
                fontSize: 20 * _fs,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.3,
                color: s.ink)),
        const SizedBox(height: 8),
        for (final line in lines)
          if (line.trim().isEmpty)
            const SizedBox(height: 6)
          else if (line.trimLeft().startsWith('• '))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: EdgeInsets.only(top: 8 * _fs, right: 11),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFF5A79), shape: BoxShape.circle),
                  ),
                ),
                Expanded(
                  child: Text(line.trimLeft().substring(2),
                      style: pvManrope(
                          fontSize: 14 * _fs, height: 1.5, color: s.ink)),
                ),
              ]),
            )
          else
            Text(line,
                style: pvManrope(
                    fontSize: 14 * _fs, height: 1.62, color: s.soft)),
        const SizedBox(height: 14),
        Container(height: 1, color: s.rule),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 1, color: s.rule),
      const SizedBox(height: 13),
      body,
      const SizedBox(height: 14),
      Container(height: 1, color: s.rule),
    ]);
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
        onTap: () {
          pvCommitFeedback();
          setState(() => open ? _openFaqs.remove(index) : _openFaqs.add(index));
        },
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
                child: AnimatedRotation(
                  turns: open ? 0.125 : 0, // + turns into ×… read as "close"
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(Icons.add_rounded, size: 19, color: s.soft),
                ),
              ),
            ]),
            // The answer unfolds (2026-09-19) — the user: "a tab should feel
            // like a tab, not a static hard situation". Height animates;
            // the glyph turns from + to − rather than swapping.
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(f.answer.of(_lang),
                          style: pvManrope(
                              fontSize: 14.5 * _fs, height: 1.72, color: s.soft)),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ]),
        ),
      ),
    );
  }

  /// ⚠️ VISIBLE, NOT A FOOTNOTE. An unsourced claim in a fertility article is
  /// indistinguishable from the content this product exists to replace, so the
  /// sourcing is set at reading size and given its own rule above it.
  // Kept for revert — replaced by [_references] on 2026-09-16; the badge and
  // its rationale moved to [_byline].
  // ignore: unused_element
  Widget _evidence(_Skin s) => Container(
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: s.rule),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // ⚠️ THE FILLED BADGE, IN BLUE, BECAUSE THAT GLYPH IS ALREADY
            // LEARNED. Asked for directly: *"make it dark blue like the way we
            // have on Instagram or something, so that it lets the user
            // understand that hey, it's a verified situation."*
            //
            // Which is the right instinct and worth stating as a rule: a
            // convention every user already carries in from another app is
            // worth more than a house style nobody has learned yet. Outlined
            // and grey, this was a decorative tick that read as a bullet. The
            // filled blue mark says "checked by someone" before a word of the
            // label is read — and this block is the one place on the page where
            // that claim is literally true.
            //
            // The blue lifts on a dark ground so it stays a badge rather than
            // a smudge; the same hue at the same value would disappear against
            // #17151C.
            Icon(Icons.verified_rounded,
                size: 16,
                color: s.bg.computeLuminance() < 0.4
                    ? const Color(0xFF52A9F5)
                    : const Color(0xFF1668C1)),
            const SizedBox(width: 8),
            Text(_t('WHERE THIS COMES FROM', 'YE KAHAN SE AAYA'),
                style: _meta(s)),
          ]),
          const SizedBox(height: 9),
          Text(a.evidence!.of(_lang),
              style: pvManrope(fontSize: 13 * _fs, height: 1.65, color: s.soft)),
        ]),
      );

  /// "▸ References" — the evidence note behind a disclosure. The verified mark
  /// moved up to the byline (see [_byline]); what is left here is the
  /// sources, which is exactly what a reader who taps this wants.
  ///
  /// Kept for revert: [_evidence], the always-open block with the badge.
  Widget _references(_Skin s) {
    // ⚠️ A MATERIAL WITH A CLIP, NOT A CONTAINER WITH ONE. Ink is painted on
    // the nearest Material ancestor, so a Container's clip never touched the
    // ripple and the rounded row lit up as a sharp rectangle (seen on the
    // phone, 2026-09-17). A Material that clips to its own rounded shape clips
    // its ink as well.
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: s.rule),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        InkWell(
          onTap: () {
            pvCommitFeedback();
            setState(() => _refsOpen = !_refsOpen);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 13, 13),
            child: Row(children: [
              Expanded(
                child: Text(_t('REFERENCES', 'SANDARBH'), style: _meta(s)),
              ),
              AnimatedRotation(
                turns: _refsOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(Icons.expand_more_rounded, size: 20, color: s.soft),
              ),
            ]),
          ),
        ),
        // Unfolds (2026-09-19): a cross-fade at a fixed size jumped.
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _refsOpen
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  child: Text(a.evidence!.of(_lang),
                      style: pvManrope(
                          fontSize: 13 * _fs, height: 1.65, color: s.soft)),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }

  /// "Was this helpful?" — two outlined pills (DESIGN-SYSTEM §4.3), no thumbs,
  /// no counts shown back. Answering replaces the pills with one quiet line so
  /// the question is asked once per article, not on every open. The answer is
  /// a per-item signal for the recommendations engine (PvReadStore.helpfulOf).
  Widget _helpful(_Skin s) {
    final answer = _store.helpfulOf(a.id);
    if (answer != null) {
      return Text(
        answer
            ? _t('Thanks — noted as helpful.', 'Shukriya — helpful mark kiya.')
            : _t('Thanks — we will keep working on this one.',
                'Shukriya — is par aur kaam karenge.'),
        style: pvManrope(fontSize: 12.5, height: 1.4, color: s.soft),
      );
    }
    Widget pill(String label, bool value) => InkWell(
          onTap: () {
            pvCommitFeedback();
            _store.setHelpful(a.id, value);
          },
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: s.rule, width: 1.2),
            ),
            child: Text(label,
                style: pvManrope(
                    fontSize: 13, fontWeight: FontWeight.w700, color: s.ink)),
          ),
        );
    return Row(children: [
      Expanded(
        child: Text(_t('Was this helpful?', 'Kya ye kaam aaya?'),
            style: pvManrope(
                fontSize: 13.5, fontWeight: FontWeight.w700, color: s.ink)),
      ),
      pill(_t('Not really', 'Nahi'), false),
      const SizedBox(width: 8),
      pill(_t('Yes', 'Haan'), true),
    ]);
  }

  /// Read next as a horizontal rail, two cards visible. Each card: the read's
  /// tinted cover (its hue), the title, and the read time when the resolver
  /// hands one back. Ids that no longer resolve render nothing — the same
  /// rule as [_readNext].
  Widget _readNextRail(_Skin s) {
    // Title from either seam; teaser and picture only when the stage hands
    // the whole read over.
    (LocalizedText, LocalizedText?, String?)? resolve(String id) {
      final r = widget.resolveRead?.call(id);
      if (r != null) return (r.title, r.teaser, readImageFor(r.id, own: r.imageUrl));
      final t = widget.readTitle?.call(id);
      return t == null ? null : (t, null, null);
    }

    final items = [
      for (final id in a.readNext)
        if (resolve(id) case final r?) (id, r),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    // ⚠️ THE SAME TILE AS "WHAT YOU CAN DO WITH THIS" — 2026-09-17. The rail
    // had its own quieter card (panel, hairline, a small icon well), and the
    // user asked for the tool tiles' treatment instead: one tile family at the
    // foot of an article, not two. The 2026-09-16 card is in git for revert.
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final (id, (title, teaser, image)) = items[i];
          final width = (MediaQuery.of(context).size.width - 44 - 10) / 2;
          return SizedBox(
            width: width,
            child: _tile(
              type: SolutionType.read,
              title: title.of(_lang),
              value: teaser?.of(_lang),
              imageUrl: image,
              onTap: () => widget.openRead?.call(context, id),
            ),
          );
        },
      ),
    );
  }

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
      // A relevant still until the film exists (2026-09-29); null for every
      // film without a line in `kPvFilmStills`, which draws as before.
      still: pvFilmStillFor(v.id),
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

  /// The things to do with this article, as blocks rather than as list rows.
  ///
  /// ⚠️ THIS DROPPED `SolutionCard`, AND THE REASON IS THE ICON WELL. Asked for
  /// directly - *"the representation of these two tools, do it in the same way
  /// that is happening on the initial doors... that representation of that
  /// thumbnail"* - and the specific thing being reacted to was the 52pt rounded
  /// square holding the icon, filled with a vertical two-stop gradient. A
  /// gradient is a texture, and a texture inside a page made entirely of flat
  /// type and hairlines is the one element that looks like it came from
  /// somewhere else.
  ///
  /// ⚠️ THE SHARED COMPONENT IS UNTOUCHED. `SolutionCard` still renders exactly
  /// as it did on every hub in Pregnancy and Parenting, where it is correct - a
  /// dense list of many options wants a compact row with a strong left anchor.
  /// The change is that the READER no longer uses it. Editing the shared card
  /// to satisfy one surface would have moved the gradient complaint to three
  /// screens nobody was looking at, which is the trade this repo has made
  /// before and paid for.
  ///
  /// ⚠️ AND THE ONE-LINE REASON SURVIVES ONTO THE FACE. The focus-page tile
  /// drops its blurb because tapping it opens a sheet that shows it. Here
  /// tapping opens the tool directly, so a dropped reason is a reason nobody
  /// ever reads - and `SolutionCard`'s own contract says a card with a title
  /// and no reason is just a link. It is set small and muted under the title.
  ///
  /// Two across, because two is what makes a pair read as a SET rather than as
  /// two unrelated buttons stacked. A third wraps to the next row and sits
  /// half-width, which looks deliberate; a full-width third would not.
  Widget _nextStepGrid(_Skin s, List<PvReadNextStep> steps) {
    const gap = 10.0;
    final rows = <Widget>[];
    for (var i = 0; i < steps.length; i += 2) {
      final pair = steps.skip(i).take(2).toList();
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: i + 2 < steps.length ? gap : 0),
        // ⚠️ NO `CrossAxisAlignment.stretch` HERE — IT CRASHES. `stretch` tells
        // each child to take the Row's full cross-axis extent, which means the
        // Row must first KNOW its own height. Inside a `Column` inside a
        // `ListView` the height is unbounded, so the Row hands its children
        // `h=Infinity` and layout throws `BoxConstraints forces an infinite
        // height`, taking the whole article down with it.
        //
        // The fix is not `IntrinsicHeight` — the tiles already declare
        // `_nextStep`'s own fixed height, so they are equal without being told
        // to be, and the default `start` alignment is correct. Reaching for
        // `stretch` was solving a problem that did not exist and creating one
        // that did.
        child: Row(children: [
          for (var j = 0; j < pair.length; j++) ...[
            if (j > 0) const SizedBox(width: gap),
            Expanded(child: _nextStep(s, pair[j])),
          ],
          // Keeps a lone trailing tile half-width instead of letting it stretch
          // into a shape no other tile on the page has.
          if (pair.length == 1) ...[
            const SizedBox(width: gap),
            const Expanded(child: SizedBox.shrink()),
          ],
        ]),
      ));
    }
    return Column(children: rows);
  }

  Widget _nextStep(_Skin s, PvReadNextStep n) {
    final type = switch (n.kind) {
      PvNextKind.read => SolutionType.read,
      PvNextKind.watch => SolutionType.watch,
      PvNextKind.tool => SolutionType.tool,
      PvNextKind.activity => SolutionType.activity,
      PvNextKind.product => SolutionType.product,
      PvNextKind.course => SolutionType.course,
      PvNextKind.consult => SolutionType.consult,
      PvNextKind.ask => SolutionType.consult,
    };

    return _tile(
      type: type,
      // An Ask Veda step says so on its chip (2026-09-19).
      chip: n.kind == PvNextKind.ask ? 'ASK VEDA' : null,
      icon: n.kind == PvNextKind.ask ? Icons.auto_awesome_outlined : null,
      title: n.title.of(_lang),
      value: n.value.of(_lang),
      onTap: () {
        if (n.action != null) {
          widget.openAction?.call(context, n.action!);
        } else if (n.surfaceId != null) {
          widget.openSurface?.call(context, n.surfaceId!);
        }
      },
    );
  }

  /// The one tile at the foot of an article — a next step, a read next. The
  /// type's well tint, its chip, the mark cropped by the edge as the picture,
  /// or a photograph filling the block where the piece has one.
  Widget _tile({
    required SolutionType type,
    required String title,
    String? value,
    String? imageUrl,
    String? chip,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(type.hue % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();
    final photo = imageUrl != null && imageUrl.isNotEmpty;

    return PvPress(
        child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 172,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          // ⚠️ THE MARK IS THE PICTURE, cropped by the block's own edge rather
          // than sitting in a well of its own. Same device as the focus rail:
          // it fills the space an illustration will eventually take, at an
          // alpha low enough that the title never has to fight it. Where the
          // piece HAS a picture, the picture fills the block and a scrim
          // rises under the type — the door rail's own treatment.
          if (photo)
            Positioned.fill(
              child: Image.network(imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink()),
            )
          else
            Positioned(
              right: -22,
              bottom: -14,
              child: Icon(icon ?? type.icon,
                  size: 108, color: Colors.white.withValues(alpha: 0.42)),
            ),
          if (photo)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.86),
                    ],
                    stops: const [0.30, 0.72],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon ?? type.icon, size: 10, color: deep),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(chip ?? type.chip(_lang),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: deep)),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  Text(title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.22,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                  if (value case final v?) ...[
                    const SizedBox(height: 5),
                    Text(v,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 10.5,
                            height: 1.32,
                            color: p.ink2.withValues(alpha: 0.9))),
                  ],
                ]),
          ),
        ]),
      ),
    ));
  }

  // Kept for revert — the stacked rows; [_readNextRail] replaced it 2026-09-16.
  // ignore: unused_element
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

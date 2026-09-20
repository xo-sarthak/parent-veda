// =============================================================================
//  PvSearchScreen — one search over everything the doors hold
// -----------------------------------------------------------------------------
//  Built 2026-09-18 from a Mobbin pass (BASE-UI-DECISIONS §2.9). The shape
//  every content app converges on — Flo, Bloom, CVS Health, Apple Health,
//  Yazio, GoodRx: the field at the TOP with the keyboard already up, and
//  under it, before she types, two honest lists: what she looked for last
//  and a few places to start. As she types, rows replace them, each row a
//  thing that opens.
//
//  ⚠️ THERE IS NO CONTENT MODEL FOR SEARCH. The doors already hold every
//  piece as a `PvDoorTile` with a title, a plain-English blurb and the
//  surface it opens; the index is those tiles, read once, and a result opens
//  through `openPvDoorTile` — the same router the door uses — so a search
//  hit and a door tap can never land on different screens. A door itself is
//  a hit too ("nutrition" opens Nutrition). Nothing is typed twice.
//
//  ⚠️ A MISS IS NEVER A DEAD END. The last row under any result list, and
//  the only row under none, is "Ask Veda about …", which opens Ask Veda with
//  the words she typed. Search finds what is written; Ask Veda answers what
//  is not. That row is why this screen has no purple button of its own —
//  and why the floating Ask button is suppressed on this route.
//
//  Scope: opened from a door it searches that door first, with "Everywhere"
//  one tap away; opened from the home it searches the stage.
//
//  No violet anywhere — fill, ring, caret, selection all ink or neutral
//  (`app_theme.dart`, 2026-09-18). The user's words: "especially when
//  tapped, the grossness doubles."
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_data.dart';
import '../../models/bracket.dart';
import '../../services/bracket_resolver.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/pv_search_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskVedaRoute;
import '../../widgets/pv_feedback.dart';
import '../doors/pv_door_router.dart';
import '../../data/nutrition_data.dart' show kRecipes;
import '../../data/report_findings_data.dart';
import '../nutrition/door/recipe_cook_screen.dart' show openRecipe;
import '../../data/tests_scans_reports_data.dart';
import '../brackets/scan_detail_screen.dart';
import '../doors/pv_door_screen.dart';
import '../report_screen.dart' show ReportArticleScreen;
import '../tools/ask_veda_screen.dart';
import '../v2/v2_palette.dart';

const String kPvSearchRoute = 'search';
const Key kPvSearchFieldKey = ValueKey('pv-search-field');
Key pvSearchHitKey(int i) => ValueKey('pv-search-hit-$i');
const Key kPvSearchAskKey = ValueKey('pv-search-ask');

/// Push the search screen. From a door pass its page; from the home pass
/// nothing and the whole stage is searched.
void openPvSearch(BuildContext context, PregnancyController pregnancy,
    {PvDoorPage? door, String? query}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPvSearchRoute),
    builder: (_) => PvSearchScreen(pregnancy: pregnancy, door: door, query: query),
  ));
}

/// The index scoped to one door: its tiles and its inline libraries, not
/// the door itself. What a door's own live field searches (pv_live_search).
List<PvSearchHit> pvSearchIndexOf(PvDoorPage door) => [
      for (final h in pvSearchIndex())
        if (h.page == door && (h.tile != null || h.open != null)) h
    ];

/// Open a hit the way the search screen does — the door's router for a
/// tile, the hit's own opener for a library entry, the door for a door —
/// and remember the words that found it.
void openPvSearchHit(BuildContext context, PvSearchHit h, PregnancyController pregnancy, {String? query}) {
  pvCommitFeedback();
  if (query != null && query.trim().isNotEmpty) PvSearchStore.instance.remember(query);
  if (h.tile case final t?) {
    openPvDoorTile(context, t, pregnancy);
    return;
  }
  if (h.open case final open?) {
    open(context, pregnancy);
    return;
  }
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'bracket/scans'),
    builder: (_) => PvDoorScreen(page: h.page, bracket: h.bracket, pregnancy: pregnancy),
  ));
}

// -----------------------------------------------------------------------------
//  The index
// -----------------------------------------------------------------------------

/// One searchable thing: a tile on a door, or a door itself.
class PvSearchHit {
  PvSearchHit._({
    required this.title,
    required this.blurb,
    required this.meta,
    required this.icon,
    required this.page,
    required this.bracket,
    this.tile,
    this.open,
  });

  /// For a hit that is not a tile — a report finding, a report parameter —
  /// how it opens. Null means "the tile" or "the door".
  final void Function(BuildContext, PregnancyController)? open;

  final String title;
  final String blurb;

  /// "Scans & tests · Understand a scan" — where the tap lands.
  final String meta;
  final IconData icon;
  final PvDoorPage page;
  final Bracket bracket;

  /// Null for a door hit, and for a library hit (see [open]).
  final PvDoorTile? tile;

  String get _haystack => '$title $blurb $meta'.toLowerCase();

  /// The words of the haystack, for prefix matching.
  late final List<String> _words = _haystack.split(_kSplit);
}

final RegExp _kSplit = RegExp(r'[^a-z0-9]+');

/// A query word matches when it STARTS a word — "nt" finds "NT scan", not
/// "appointment" and "placenta" (seen on the phone, 2026-09-18). Typing is
/// left to right; what she has typed so far is the start of a word.
bool _matches(List<String> words, String q) =>
    words.any((w) => w.startsWith(q));

List<PvSearchHit>? _stageIndex;

/// Every tile on every pregnancy door, plus the doors, plus the libraries a
/// door holds inline (the report findings and the report parameters on
/// Scans & tests), built once.
///
/// ⚠️ THE LIBRARIES ARE HERE BECAUSE THEIR OWN SEARCH BARS ARE GONE. The
/// decoder tab had a bar of its own and the parameters had a page of their
/// own (2026-09-18, the door walk); one bar per door means this index has
/// to reach what those reached. A finding opens its read; a parameter opens
/// the scan whose report it is on.
List<PvSearchHit> pvSearchIndex() => _stageIndex ??= [
      for (final page in kPvDoorPages)
        if (bracketById(page.bracketId) case final b?) ...[
          ..._indexOf(page, b),
          if (page.bracketId == 'pregnancy_scans_tests') ..._scansLibraries(page, b),
          if (page.bracketId == 'pregnancy_nutrition') ..._nutritionLibraries(page, b),
        ],
    ];

List<PvSearchHit> _scansLibraries(PvDoorPage page, Bracket b) {
  final door = b.label.now;
  return [
    for (final f in kReportFindings)
      PvSearchHit._(
        title: f.name.now,
        blurb: f.whatItMeans.now,
        meta: '$door · Understand a result',
        icon: Icons.find_in_page_outlined,
        page: page,
        bracket: b,
        open: (context, c) => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'scans/finding'),
          builder: (_) => ReportArticleScreen(finding: f, controller: c),
        )),
      ),
    for (final scan in kTestsScans)
      for (final r in scan.parameters)
        PvSearchHit._(
          title: r.name.now,
          blurb: r.measures.now,
          meta: '$door · On the ${scan.name.now} report',
          icon: Icons.table_rows_outlined,
          page: page,
          bracket: b,
          open: (context, c) => Navigator.of(context).push(MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'scans/detail'),
            builder: (_) => ScanDetailScreen(scan: scan, pregnancy: c),
          )),
        ),
  ];
}

/// The recipes stopped being tiles on 2026-09-20 (the Recipes tab is the
/// grid, `RecipesGridBody`), and the door's live field found "ragi" nowhere
/// on the phone. The library is reached here instead: a recipe opens its
/// cook screen, the same one the grid opens.
List<PvSearchHit> _nutritionLibraries(PvDoorPage page, Bracket b) {
  final door = b.label.now;
  return [
    for (final r in kRecipes)
      PvSearchHit._(
        title: r.name.en,
        blurb: r.whyNow.en,
        meta: '$door · Recipes',
        icon: Icons.soup_kitchen_outlined,
        page: page,
        bracket: b,
        open: (context, c) => openRecipe(context, r, c),
      ),
  ];
}

List<PvSearchHit> _indexOf(PvDoorPage page, Bracket b) {
  final door = b.label.now;
  return [
    PvSearchHit._(
      title: door,
      blurb: page.heroBlurb,
      meta: 'A door on your home',
      icon: Icons.grid_view_rounded,
      page: page,
      bracket: b,
    ),
    for (final g in page.groups)
      for (final s in page.sectionsOf(g.id))
        for (final t in s.tiles)
          // A coming-soon card opens nothing, and a launcher card only
          // switches a tab of its own door — neither is a place to land.
          if (!t.comingSoon && pvDoorTabTarget(t) == null)
            PvSearchHit._(
              title: t.title,
              blurb: t.blurb,
              meta: '$door · ${g.label}',
              icon: pvDoorFormatIcon(t.format),
              page: page,
              bracket: b,
              tile: t,
            ),
  ];
}

/// Rank: every word of the query must appear; a title that starts with the
/// query outranks one that contains it, which outranks a blurb match.
List<PvSearchHit> pvSearch(String query, List<PvSearchHit> index) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final words = q.split(RegExp(r'\s+'));
  final scored = <(int, int, PvSearchHit)>[];
  for (var i = 0; i < index.length; i++) {
    final h = index[i];
    if (!words.every((w) => _matches(h._words, w))) continue;
    final t = h.title.toLowerCase();
    final rank = t.startsWith(q)
        ? 0
        : t.contains(q)
            ? 1
            : words.every(t.contains)
                ? 2
                : 3;
    scored.add((rank, i, h));
  }
  scored.sort((a, b) {
    final r = a.$1.compareTo(b.$1);
    return r != 0 ? r : a.$2.compareTo(b.$2);
  });
  return [for (final s in scored) s.$3];
}

// -----------------------------------------------------------------------------
//  The screen
// -----------------------------------------------------------------------------

class PvSearchScreen extends StatefulWidget {
  const PvSearchScreen({super.key, required this.pregnancy, this.door, this.query});

  final PregnancyController pregnancy;

  /// The door this was opened from, if any — searched first.
  final PvDoorPage? door;

  /// Words already typed — a door's live field handing over to
  /// "Search everywhere".
  final String? query;

  @override
  State<PvSearchScreen> createState() => _PvSearchScreenState();
}

class _PvSearchScreenState extends State<PvSearchScreen> {
  final _ctl = TextEditingController();
  final _focus = FocusNode();
  late bool _here = widget.door != null;

  @override
  void initState() {
    super.initState();
    PvSearchStore.instance.init();
    _ctl.addListener(() => setState(() {}));
    if (widget.query case final q? when q.trim().isNotEmpty) {
      _ctl.text = q;
      _ctl.selection = TextSelection.collapsed(offset: q.length);
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _doorLabel =>
      widget.door == null ? '' : (bracketById(widget.door!.bracketId)?.label.now ?? '');

  List<PvSearchHit> get _index {
    final all = pvSearchIndex();
    if (!_here || widget.door == null) return all;
    return [
      for (final h in all)
        if (h.page == widget.door && (h.tile != null || h.open != null)) h
    ];
  }

  void _run(String q) {
    _ctl.text = q;
    _ctl.selection = TextSelection.collapsed(offset: q.length);
    _focus.requestFocus();
  }

  void _open(PvSearchHit h) => openPvSearchHit(context, h, widget.pregnancy, query: _ctl.text);

  void _ask() {
    pvCommitFeedback();
    final q = _ctl.text.trim();
    PvSearchStore.instance.remember(q);
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: kAskVedaRoute),
      builder: (_) =>
          AskVedaScreen(controller: widget.pregnancy, initialQuery: q),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final q = _ctl.text.trim();
    final hits = q.isEmpty ? const <PvSearchHit>[] : pvSearch(q, _index);
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: Column(children: [
          _field(p),
          if (widget.door != null) _scope(p),
          Expanded(
            child: q.isEmpty
                ? _start(p)
                : ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 40),
                    children: [
                      if (hits.isEmpty) _miss(p, q),
                      for (var i = 0; i < hits.length && i < 40; i++)
                        _row(p, hits[i], i),
                      if (hits.isNotEmpty) const SizedBox(height: 8),
                      _askRow(p, q),
                    ],
                  ),
          ),
        ]),
      ),
    );
  }

  // ---- the field ----------------------------------------------------------

  Widget _field(V2Palette p) {
    final hint = widget.door != null && _here
        ? 'Search $_doorLabel'
        : 'Search scans, symptoms, foods, anything';
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 18, 6),
      child: Row(children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_rounded, color: p.ink1),
          tooltip: 'Back',
        ),
        const SizedBox(width: 2),
        Expanded(
          child: TextField(
            key: kPvSearchFieldKey,
            controller: _ctl,
            focusNode: _focus,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              if (hits(q: _ctl.text).isEmpty && _ctl.text.trim().isNotEmpty) {
                _ask();
              }
            },
            style: pvManrope(
                fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: pvManrope(
                  fontSize: 14.5, fontWeight: FontWeight.w500, color: p.ink3),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: Icon(Icons.search_rounded, size: 21, color: p.ink3),
              suffixIcon: _ctl.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => _run(''),
                      icon: Icon(Icons.close_rounded, size: 19, color: p.ink2),
                      tooltip: 'Clear',
                    ),
              filled: true,
              fillColor: p.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: p.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: p.ink1, width: 1.2),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  List<PvSearchHit> hits({required String q}) => pvSearch(q, _index);

  // ---- scope: this door, or everywhere ------------------------------------

  Widget _scope(V2Palette p) {
    Widget chip(String label, bool on, VoidCallback onTap) => PvPress(
          child: Material(
            color: on ? p.ink1 : p.surface,
            shape: StadiumBorder(
                side: BorderSide(color: on ? p.ink1 : p.line)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: on ? null : () {
                pvCommitFeedback();
                onTap();
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(label,
                    style: pvManrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: on ? Colors.white : p.ink1)),
              ),
            ),
          ),
        );
    // Scrolls rather than wraps: "In Garbh Sanskar" plus "Everywhere" is
    // wider than a narrow phone, and a chip on a second line reads as a
    // different control.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
      child: Row(children: [
        chip('In $_doorLabel', _here, () => setState(() => _here = true)),
        const SizedBox(width: 8),
        chip('Everywhere', !_here, () => setState(() => _here = false)),
      ]),
    );
  }

  // ---- before she types: recent, and places to start ----------------------

  Widget _start(V2Palette p) {
    return AnimatedBuilder(
      animation: PvSearchStore.instance,
      builder: (context, _) {
        final recent = PvSearchStore.instance.recent;
        // Places to start are the door's tabs, or the stage's doors —
        // derived, never a hand-typed "popular" list.
        final starts = widget.door != null && _here
            ? [for (final g in widget.door!.groups) g.label]
            : [
                for (final page in kPvDoorPages)
                  if (bracketById(page.bracketId) case final b?) b.label.now
              ];
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
          children: [
            if (recent.isNotEmpty) ...[
              Row(children: [
                Expanded(child: _eyebrow(p, 'Recent')),
                TextButton(
                  onPressed: PvSearchStore.instance.clear,
                  style: TextButton.styleFrom(
                      foregroundColor: p.ink2,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('Clear',
                      style: pvManrope(
                          fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
              ]),
              for (final r in recent)
                _plainRow(p, Icons.history_rounded, r, () => _run(r)),
              const SizedBox(height: 18),
            ],
            _eyebrow(p, 'Start with'),
            for (final s in starts)
              _plainRow(p, Icons.search_rounded, s, () => _run(s)),
          ],
        );
      },
    );
  }

  Widget _eyebrow(V2Palette p, String s) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(s.toUpperCase(),
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: p.ink3)),
      );

  Widget _plainRow(V2Palette p, IconData icon, String s, VoidCallback onTap) =>
      PvPress(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(children: [
              Icon(icon, size: 20, color: p.ink3),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: p.ink1)),
              ),
              Icon(Icons.north_west_rounded, size: 16, color: p.ink3),
            ]),
          ),
        ),
      );

  // ---- a result -----------------------------------------------------------

  Widget _row(V2Palette p, PvSearchHit h, int i) =>
      PvSearchHitRow(key: pvSearchHitKey(i), p: p, hit: h, onTap: () => _open(h));

  // ---- nothing here, and the way on ----------------------------------------

  Widget _miss(V2Palette p, String q) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nothing written about "$q"${_here && widget.door != null ? ' in $_doorLabel' : ' yet'}.',
              style: pvManrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: p.ink1)),
          if (_here && widget.door != null) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => setState(() => _here = false),
              child: const Text('Search everywhere'),
            ),
          ],
        ]),
      );

  Widget _askRow(V2Palette p, String q) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
        child: PvPress(
          key: kPvSearchAskKey,
          child: Material(
            color: p.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: p.line)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _ask,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                child: Row(children: [
                  Icon(Icons.auto_awesome_outlined, size: 20, color: p.ink1),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ask Veda about "$q"',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: p.ink1)),
                          const SizedBox(height: 2),
                          Text('An answer from everything ParentVeda knows',
                              style: pvManrope(
                                  fontSize: 12.5, color: p.ink2)),
                        ]),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
                ]),
              ),
            ),
          ),
        ),
      );
}

/// One result: the icon in a well, the title, the blurb, where it lands.
/// The search screen's row and the door's live field draw the same one.
class PvSearchHitRow extends StatelessWidget {
  const PvSearchHitRow({super.key, required this.p, required this.hit, required this.onTap});
  final V2Palette p;
  final PvSearchHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = hit;
    final well = Color.alphaBlend(p.ink1.withValues(alpha: 0.06), p.surface);
    return PvPress(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: well, borderRadius: BorderRadius.circular(12)),
              child: Icon(h.icon, size: 20, color: p.ink2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: p.ink1)),
                  const SizedBox(height: 2),
                  Text(h.blurb,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 12.5, height: 1.35, color: p.ink2)),
                  const SizedBox(height: 3),
                  Text(h.meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: p.ink3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ),
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
//  Parenting search — one box for every door, every tool, every food
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P1 ("Search the parenting stage", Behind · Home &
//  daily, 2026-10-02): both What to Expect and theAsianparent open with a
//  search box (theAsianparent with eight result tabs), and ours searched the
//  pregnancy doors only. "With 564 pages in 10 doors, a parent who wants
//  'teething' has to know it lives in Health › Something's wrong."
//
//  WHAT IT SEARCHES, all on the phone, no network: every live page in every
//  parenting section (title, subtitle, then the words), every tool on every
//  door, and every food "Can my baby eat this?" answers (a food hit opens the
//  check with her words already in the box). A door's own search field passes
//  `sectionId` and gets that door's pages first.
//
//  RANKING (from the fork's 2026-10-02 search, CognihabRepo/parent-veda-fork
//  a79a9a4, rewritten here): every word she types must appear somewhere, so
//  "fever teething" finds the page about both, not every page that mentions
//  either; a title hit outranks a subtitle hit outranks a body hit; tools get a
//  small lift. No fuzzy matching: a misspelling finds nothing, and the empty
//  state says so and offers Ask Veda, never a blank.
//
//  ⚠️ THE LOOK IS THE SHARED SEARCH'S, NOT A NEW ONE. Pregnancy's
//  `PvSearchScreen` and `PvSearchHitRow` (lib/screens/search/pv_search_screen
//  .dart) are typed on pregnancy doors and its controller, so they cannot take
//  a parenting page; the row below is that row's geometry exactly (40 well,
//  title 15/w700, blurb 12.5, meta 11, chevron), and the screen is that
//  screen's order (field on top, recents, places to start, rows, a way on).
//  Recents are the shared `PvSearchStore`: one person, one history.
//  Mobbin: GoodRx, Yazio and Apple Health for recents on an empty search; Flo,
//  Bloom and CVS for "places to start" (the references the shared search
//  cites).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pp_door_data.dart';
import '../../services/bracket_resolver.dart';
import '../../services/pv_search_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../doors/pv_live_search.dart' show PvLiveSearchWayOn, pvLiveSearchRecallHeading;
import '../v2/v2_palette.dart';
import 'askveda_screen.dart';
import 'pp_baby_food_check_screen.dart';
import 'pp_content.dart';
import 'pp_section_registry.dart';
import 'pp_section_screen.dart';
import 'pp_surface_router.dart';

/// What a hit is, which decides its icon and how it opens.
enum PpSearchKind { page, tool, food }

/// One thing search can find.
class PpSearchHit {
  const PpSearchHit({
    required this.kind,
    required this.title,
    required this.blurb,
    required this.meta,
    required this.score,
    this.sectionId,
    this.pageId,
    this.surfaceId,
    this.food,
  });

  final PpSearchKind kind;
  final String title;
  final String blurb;

  /// Where it lives: "Health · Something's wrong", "Tool · Feeding".
  final String meta;
  final int score;
  final String? sectionId;
  final String? pageId;
  final String? surfaceId;

  /// For a food hit: the food's name, put in the check's box.
  final String? food;

  IconData get icon => switch (kind) {
        PpSearchKind.page => Icons.article_outlined,
        PpSearchKind.tool => Icons.handyman_outlined,
        PpSearchKind.food => Icons.restaurant_outlined,
      };

  PpSearchHit withScore(int s) => PpSearchHit(
        kind: kind,
        title: title,
        blurb: blurb,
        meta: meta,
        score: s,
        sectionId: sectionId,
        pageId: pageId,
        surfaceId: surfaceId,
        food: food,
      );
}

class _Doc {
  _Doc(this.hit, this.title, this.sub, this.body);
  final PpSearchHit hit;
  final String title;
  final String sub;
  final String body;
}

List<_Doc>? _index;

String _blockText(PpBlock b) => switch (b) {
      PpIntro x => x.text,
      PpArticle x => [x.heading ?? '', ...x.paragraphs].join(' '),
      PpSteps x => [x.heading ?? '', for (final s in x.steps) '${s.title} ${s.detail}'].join(' '),
      PpCards x => [x.heading ?? '', for (final c in x.cards) '${c.title} ${c.line}'].join(' '),
      PpCallout x => '${x.title ?? ''} ${x.text}',
      _ => '',
    };

/// The door's name as the home tile says it, else the section's title.
String _doorName(PpSection s) => bracketById(s.id)?.label.now ?? s.title;

List<_Doc> _build() {
  final out = <_Doc>[];
  for (final s in kPpSections) {
    final door = _doorName(s);
    for (final a in s.areas) {
      for (final p in a.pages) {
        if (p.comingSoon) continue;
        final body = p.blocks.map(_blockText).join(' ');
        final firstLine = p.subtitle ??
            (body.length > 120 ? '${body.substring(0, 117).trimRight()}…' : body);
        out.add(_Doc(
          PpSearchHit(
            kind: p.toolSurfaceId != null ? PpSearchKind.tool : PpSearchKind.page,
            title: p.title,
            blurb: firstLine,
            meta: '$door · ${a.title}',
            score: 0,
            sectionId: s.id,
            pageId: p.id,
            surfaceId: p.toolSurfaceId,
          ),
          p.title.toLowerCase(),
          (p.subtitle ?? '').toLowerCase(),
          body.toLowerCase(),
        ));
      }
    }
  }
  final seenTools = <String>{};
  for (final d in kPpDoors) {
    final section = ppSectionFor(d.sectionId);
    for (final t in d.tabs) {
      for (final tool in t.tools) {
        if (!seenTools.add(tool.surfaceId)) continue;
        out.add(_Doc(
          PpSearchHit(
            kind: PpSearchKind.tool,
            title: tool.label,
            blurb: tool.blurb,
            meta: 'Tool · ${section == null ? t.label : _doorName(section)}',
            score: 0,
            sectionId: d.sectionId,
            surfaceId: tool.surfaceId,
          ),
          tool.label.toLowerCase(),
          tool.blurb.toLowerCase(),
          '',
        ));
      }
    }
  }
  for (final (name, aliases) in ppBabyFoodEntries()) {
    out.add(_Doc(
      PpSearchHit(
        kind: PpSearchKind.food,
        title: name,
        blurb: 'When your baby can have it, and how to serve it',
        meta: 'Can my baby eat this?',
        score: 0,
        food: name,
      ),
      name.toLowerCase(),
      aliases.join(' ').toLowerCase(),
      '',
    ));
  }
  return out;
}

/// The search itself, apart from any screen so a test can call it. A door's
/// own field passes [sectionId]: that door's hits come first.
List<PpSearchHit> ppSearch(String query, {String? sectionId, int limit = 60}) {
  final words = query.toLowerCase().split(RegExp(r'\s+')).where((w) => w.length >= 2).toList();
  if (words.isEmpty) return const [];
  final hits = <PpSearchHit>[];
  for (final d in _index ??= _build()) {
    var score = 0;
    var all = true;
    for (final w in words) {
      if (d.title.contains(w)) {
        score += 10;
      } else if (d.sub.contains(w)) {
        score += 5;
      } else if (d.body.contains(w)) {
        score += 1;
      } else {
        all = false;
        break;
      }
    }
    if (!all) continue;
    if (d.hit.kind == PpSearchKind.tool) score += 3;
    if (sectionId != null && d.hit.sectionId == sectionId) score += 20;
    hits.add(d.hit.withScore(score));
  }
  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits.take(limit).toList();
}

/// Opens a surface the way every parenting screen does, by its route name.
void ppOpenSurface(BuildContext context, String surfaceId) {
  final screen = ppScreenForSurface(surfaceId);
  if (screen == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: surfaceId),
    builder: (_) => screen,
  ));
}

/// Opens a hit, and remembers what she typed when it led somewhere.
/// ⚠️ NOT USED: superseded by the hand-matched kPpTipLinks (pp_tip_links.dart),
/// because even word-overlap matching made wrong links. Kept for reference.
///
/// The door page a tip leads to (gap analysis P2, 2026-10-07: "one tip per
/// week ... linked to a door page").
///
/// ⚠️ A WRONG LINK IS WORSE THAN NONE. Plain search matched "Coo back" to
/// "Cooking once" and "Name everything" to a SIDS page. So candidates come
/// from search, but a page is only chosen by the WHOLE words its title shares
/// with the tip: two shared words, or one longer word from the tip's own
/// title. Below that, the tip shows no link.
PpSearchHit? ppTipHit(String title, String body) {
  const stop = {
    'your', 'with', 'this', 'that', 'from', 'they', 'them', 'their', 'have', 'when', 'what', 'will',
    'every', 'about', 'into', 'more', 'than', 'just', 'only', 'even', 'each', 'does', 'over', 'after',
    'before', 'there', 'where', 'which', 'while', 'baby', 'babies', 'child', 'children', 'make', 'help',
  };
  Set<String> words(String t) => {
        for (final w in t.toLowerCase().split(RegExp(r'[^a-z]+')))
          if (w.length >= 4 && !stop.contains(w)) w.endsWith('s') && w.length > 4 ? w.substring(0, w.length - 1) : w,
      };
  final inTitle = words(title);
  final inTip = {...inTitle, ...words(body)};
  final candidates = <String, PpSearchHit>{};
  for (final q in inTip) {
    for (final h in ppSearch(q)) {
      if (h.kind == PpSearchKind.page) candidates.putIfAbsent(h.title, () => h);
    }
  }
  PpSearchHit? best;
  var bestScore = 0;
  for (final h in candidates.values) {
    final shared = words(h.title).intersection(inTip);
    final strong = shared.any((w) => inTitle.contains(w) && w.length >= 5);
    final score = shared.length * 2 + (strong ? 1 : 0);
    if ((shared.length >= 2 || strong) && score > bestScore) {
      best = h;
      bestScore = score;
    }
  }
  return best;
}

void openPpSearchHit(BuildContext context, PpSearchHit h, {String? query}) {
  if (query != null) PvSearchStore.instance.remember(query);
  switch (h.kind) {
    case PpSearchKind.food:
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp_baby_food_check'),
        builder: (_) => PpBabyFoodCheckScreen(initialQuery: h.food),
      ));
    case PpSearchKind.tool when h.pageId == null:
      ppOpenSurface(context, h.surfaceId!);
    case _:
      final section = ppSectionFor(h.sectionId!);
      final page = section?.pageById(h.pageId!);
      if (section == null || page == null) return;
      ppOpenPage(context, section, page, onSurface: ppOpenSurface);
  }
}

/// Opens the whole-stage search, optionally with her words already in it.
void openPpSearch(BuildContext context, {String? query}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'pp_search'),
    builder: (_) => PpSearchScreen(query: query),
  ));
}

/// Opens parenting Ask Veda with a question.
void openPpAskVeda(BuildContext context, String q) {
  PvSearchStore.instance.remember(q);
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'pp/askveda'),
    builder: (_) => AskVedaScreen(initialQuery: q),
  ));
}

Key ppSearchHitKey(int i) => ValueKey('pp_search_hit_$i');

/// One result: the shared search row's geometry, typed on a parenting hit.
class PpSearchHitRow extends StatelessWidget {
  const PpSearchHitRow({super.key, required this.p, required this.hit, required this.onTap});
  final V2Palette p;
  final PpSearchHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(color: well, borderRadius: BorderRadius.circular(12)),
              child: Icon(hit.icon, size: 20, color: p.ink2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(hit.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
                if (hit.blurb.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(hit.blurb,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 12.5, height: 1.35, color: p.ink2)),
                ],
                const SizedBox(height: 3),
                Text(hit.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 11, fontWeight: FontWeight.w600, color: p.ink3)),
              ]),
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

/// Places to start, before she types: the worries parents bring most, in the
/// words they type (the gap analysis's own example first).
const List<String> kPpSearchStarts = [
  'teething', 'fever', 'colic', 'sleep regression', 'starting solids', 'tantrums',
  'vaccines', 'constipation', 'nappy rash', 'jaundice', 'potty', 'back to work',
];

class PpSearchScreen extends StatefulWidget {
  const PpSearchScreen({super.key, this.query});
  final String? query;

  @override
  State<PpSearchScreen> createState() => _PpSearchScreenState();
}

class _PpSearchScreenState extends State<PpSearchScreen> {
  late final TextEditingController _ctl = TextEditingController(text: widget.query ?? '');
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    PvSearchStore.instance.init();
    _ctl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _put(String q) {
    _ctl.text = q;
    _ctl.selection = TextSelection.collapsed(offset: q.length);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final q = _ctl.text.trim();
    final hits = ppSearch(q);
    Widget pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: c);
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 18, 6),
            child: Row(children: [
              IconButton(
                key: const ValueKey('pp_search_back'),
                tooltip: 'Back',
                icon: Icon(Icons.arrow_back_rounded, color: p.ink1),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: TextField(
                  key: const ValueKey('pp_search_field'),
                  controller: _ctl,
                  focusNode: _focus,
                  autofocus: widget.query == null,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (v) {
                    final s = v.trim();
                    if (s.isEmpty) return;
                    final h = ppSearch(s);
                    if (h.isNotEmpty) {
                      openPpSearchHit(context, h.first, query: s);
                    } else {
                      openPpAskVeda(context, s);
                    }
                  },
                  style: pvManrope(fontSize: 16, color: p.ink1),
                  decoration: InputDecoration(
                    hintText: 'Search sleep, rashes, food, anything',
                    hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                    filled: true,
                    fillColor: p.surface,
                    prefixIcon: Icon(Icons.search_rounded, color: p.ink2),
                    suffixIcon: q.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            icon: Icon(Icons.close_rounded, color: p.ink2),
                            onPressed: () => _ctl.clear(),
                          ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.ink1)),
                  ),
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: PvSearchStore.instance,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.only(bottom: 120),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: q.length < 2
                    ? [
                        if (PvSearchStore.instance.recent.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          pvLiveSearchRecallHeading(p, 'Recent', onClear: PvSearchStore.instance.clear),
                          const SizedBox(height: 4),
                          for (final r in PvSearchStore.instance.recent)
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                              leading: Icon(Icons.history_rounded, color: p.ink3),
                              title: Text(r, style: pvManrope(fontSize: 15, color: p.ink1)),
                              onTap: () => _put(r),
                            ),
                        ],
                        const SizedBox(height: 18),
                        pad(Text('Places to start',
                            style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1))),
                        const SizedBox(height: 12),
                        pad(Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final s in kPpSearchStarts)
                            ActionChip(
                              key: ValueKey('pp_search_start_$s'),
                              label: Text(s, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w600, color: p.ink1)),
                              backgroundColor: p.surface,
                              side: BorderSide(color: p.line),
                              shape: const StadiumBorder(),
                              onPressed: () => _put(s),
                            ),
                        ])),
                      ]
                    : [
                        const SizedBox(height: 16),
                        pad(Text(hits.isEmpty ? 'Nothing by that name yet' : 'In ParentVeda',
                            style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1))),
                        if (hits.isEmpty) ...[
                          const SizedBox(height: 6),
                          pad(Text('Check the spelling, try a shorter word, or ask Veda in your own words.',
                              style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2))),
                        ],
                        const SizedBox(height: 6),
                        for (var i = 0; i < hits.length; i++)
                          PpSearchHitRow(
                            key: ppSearchHitKey(i),
                            p: p,
                            hit: hits[i],
                            onTap: () {
                              _focus.unfocus();
                              openPpSearchHit(context, hits[i], query: q);
                            },
                          ),
                        const SizedBox(height: 14),
                        pad(PvLiveSearchWayOn(
                          p: p,
                          icon: Icons.auto_awesome_outlined,
                          title: 'Ask Veda about "$q"',
                          line: 'In your own words, with your child\'s age in mind.',
                          onTap: () {
                            pvCommitFeedback();
                            openPpAskVeda(context, q);
                          },
                        )),
                      ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

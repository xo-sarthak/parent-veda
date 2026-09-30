// =============================================================================
//  SavedScreen — everything she has saved, anywhere in the app, in one place
// -----------------------------------------------------------------------------
//  Replaces two hubs (the pregnancy SavedHubScreen and the parenting
//  PpSavedHubScreen — both kept, commented at their call sites) that each read
//  three of ten saved-sets. This one reads SavedStore, which is the only place
//  a bookmark lives now (docs/FAMILY-MODEL.md §5), so a video she saved while
//  pregnant is here after the baby is born, in the same list, without a code
//  path that has to remember to include it.
//
//  THE SHAPE, from the Mobbin audit of saved screens (Withings, NYT, Pocket,
//  Mindvalley): "All" first, one chip per kind with a count, newest first, and
//  a stage row that appears only when she has saved from more than one stage.
//  Under "All" the kinds are grouped with a header each — and EVERY kind's
//  header always renders, an empty one carrying the line that says where that
//  kind of thing gets saved. A feature is never hidden for being empty.
//
//  EVERY ROW OPENS THE THING ITSELF. [SavedItemOpener] is the single map from a
//  kind to a screen; the rule that has bitten this repo most — a tap that
//  lands somewhere random — is closed here by having exactly one answer per
//  kind, and a "No longer available" row for an id no catalogue resolves,
//  rather than a guess at a near match.
//
//  Language: new copy is English (CLAUDE.md). The V3 palette tokens via
//  V2PaletteStore, as every V3 screen does.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/can_i_data.dart';
import '../models/can_i_entry.dart';
import '../models/community_models.dart';
// import '../models/product_models.dart'; // kept for revert
import '../models/read_item.dart';
// import '../data/product_data.dart'; // kept for revert
import '../data/read_next_data.dart';
import '../data/reads/pregnancy_reads.dart';
import '../models/pv_video.dart';
import '../services/community_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/read_to_baby_saved_store.dart';
import '../services/saved_store.dart';
import '../theme/pv_fonts.dart';
import '../ttc/ttc_reads_data.dart';
import '../ttc/ttc_lookup_reads.dart'
    show
        kTtcTestReadPrefix,
        kTtcCanIReadPrefix,
        openTtcTestRead,
        openTtcCanIRead;
import '../ttc/ttc_tests_data.dart' show ttcTestById;
import '../ttc/ttc_can_i_data.dart' show ttcCanIById;
import '../ttc/ttc_daily_data.dart' show TtcInsight, ttcAllInsights;
import '../ttc/ttc_treatment_content.dart' show kTtcTreatmentInsights;
import '../ttc/ttc_insight_read.dart' show kTtcInsightReadPrefix, openTtcInsight;
import 'can_i_screen.dart' show openCanIAnswer;
import 'community_screen.dart' show PostDetailScreen;
import 'doors/pv_door_router.dart' show openPvDoorRead, pvDoorEntryForReadId, pvDoorEntryTitle, pvDoorEntryScreen;
import 'garbh_screen.dart' show SamvadScreen;
import 'post_pregnancy/pp_daily_tips.dart';
import 'post_pregnancy/pp_reading_data.dart';
import 'post_pregnancy/pp_saved_hub_screen.dart' show SavedTipScreen;
import 'post_pregnancy/pp_watch_data.dart';
import 'post_pregnancy/reading_reader_screen.dart';
import 'post_pregnancy/watch_player_screen.dart';
import 'post_pregnancy/watch_quicklearn_screen.dart';
// import 'products_screen.dart' show ProductDetailScreen; // kept for revert
import '../models/pv_product.dart';
import '../services/pv_catalog_store.dart';
import 'products/pv_product_screen.dart';
import 'products/pv_store_chrome.dart' show kPvProductRoutePrefix;
import 'read_next_screen.dart' show ReadItemScreen;
import 'saved_hub_screen.dart' show SavedRtbReadScreen;
import 'ttc/ttc_surface_router.dart' show openTtcSurface, kTtcReadPrefix;
import 'v2/v2_palette.dart';
import 'watch_learn_screen.dart';
import '../data/cravings_data.dart' show kCravingItems, CravingItem;
import '../data/reads/nutrition_reads.dart' show kCravingReadPrefix;
import '../data/reads/can_i_read.dart' show kCanIReadPrefix;
import '../data/nutrition_data.dart' show kRecipes, Recipe;
import 'nutrition/craving_detail_screen.dart' show CravingDetailScreen;
import 'nutrition/door/recipe_cook_screen.dart' show RecipeCookScreen;
import 'can_i/can_i_answer.dart' show openCanIAnswerById;
import 'ttc/doors/ttc_tab_art.dart' show TtcTabArt, TtcTabMark;

/// What a kind is called, and where it is saved from — the words on the chip
/// and in the empty line. Display only; the identity is [SavedKind.id].
class _KindCopy {
  const _KindCopy(this.kind, this.label, this.icon, this.emptyLine);
  final SavedKind kind;
  final String label;
  final IconData icon;
  final String emptyLine;
}

const List<_KindCopy> _kinds = [
  _KindCopy(SavedKind.article, 'Articles', Icons.article_outlined,
      'Tap the bookmark on any article to keep it here.'),
  _KindCopy(SavedKind.video, 'Videos', Icons.play_circle_outline_rounded,
      'Save a film from Watch and it lands here.'),
  _KindCopy(SavedKind.recipe, 'Recipes', Icons.restaurant_outlined,
      'Recipes you save from Food appear here.'),
  _KindCopy(SavedKind.product, 'Products', Icons.shopping_bag_outlined,
      'The heart on a product keeps it here.'),
  _KindCopy(SavedKind.question, 'Questions', Icons.help_outline_rounded,
      'Answers you save from Can I? appear here.'),
  _KindCopy(SavedKind.readToBaby, 'Read to baby', Icons.menu_book_outlined,
      'Pieces you save from Samvad appear here.'),
  _KindCopy(SavedKind.tip, 'Tips', Icons.lightbulb_outline_rounded,
      'Keep a daily tip and it stays here.'),
  _KindCopy(SavedKind.post, 'Community', Icons.forum_outlined,
      'Posts you save from Community appear here.'),
  _KindCopy(SavedKind.activity, 'Activities', Icons.extension_outlined,
      'Activities you save appear here.'),
  _KindCopy(SavedKind.tool, 'Tools', Icons.handyman_outlined,
      'Tools you save appear here.'),
];

_KindCopy _copyFor(SavedKind k) => _kinds.firstWhere((c) => c.kind == k);

/// What trying to conceive saves (2026-09-30, the user: "articles, videos,
/// recipes, products").
const Set<SavedKind> kTtcSavedKinds = {
  SavedKind.article,
  SavedKind.video,
  SavedKind.recipe,
  SavedKind.product,
};

TtcTabMark _savedMark(SavedKind k) => switch (k) {
      SavedKind.video => TtcTabMark.sunrise,
      SavedKind.recipe => TtcTabMark.bowl,
      SavedKind.product => TtcTabMark.jarLeaf,
      _ => TtcTabMark.openBook,
    };

double _savedHue(SavedKind k) => switch (k) {
      SavedKind.video => 344,
      SavedKind.recipe => 42,
      SavedKind.product => 104,
      _ => 206,
    };

String _stageLabel(String id) => switch (id) {
      'trying' => 'Trying',
      'pregnancy' => 'Pregnancy',
      'parenting' => 'Parenting',
      'skilling' => 'Skilling',
      _ => id,
    };

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key, this.stage});

  /// ⚠️ ONE STAGE'S SAVED (2026-09-30, the user on the trying-to-conceive
  /// profile: pregnancy items "make no sense, pregnancy is in the future";
  /// keep "articles, videos, recipes, products"; the purple bookmarks and old
  /// icons are outdated). 'trying' shows that stage's saves only, the four
  /// kinds that belong to it, no stage chips, ink instead of purple and our
  /// drawn marks. Null keeps every stage, as the other homes open it.
  final String? stage;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  SavedKind? _kind; // null = All
  String? _stage; // null = every stage

  /// At a hundred saves the chips are not enough (Pocket, Withings and NYT
  /// all put a search box above theirs). Hidden until she asks for it, so the
  /// common case — a dozen saves — is not led by an empty field.
  bool _searching = false;
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  /// The rows a view shows: store rows, narrowed by the query when there is
  /// one. Matches title, snapshot subtitle and the live title, so a legacy
  /// row with an empty snapshot is still found by what it is called now.
  List<SavedItem> _filtered(List<SavedItem> rows) {
    final q = _query.text.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return [
      for (final r in rows)
        if (r.title.toLowerCase().contains(q) ||
            (r.subtitle ?? '').toLowerCase().contains(q) ||
            (SavedItemOpener.resolveTitle(r) ?? '').toLowerCase().contains(q))
          r
    ];
  }

  @override
  void initState() {
    super.initState();
    SavedStore.instance.load();
    _stage = widget.stage;
  }

  bool get _trying => widget.stage == 'trying';

  /// The kinds this screen offers. On trying to conceive, the four that stage
  /// saves; the rest (questions, read to baby, tips, community, activities,
  /// tools) belong to other stages and are left out here, not deleted.
  List<_KindCopy> get _shown => _trying
      ? [
          for (final c in _kinds)
            if (kTtcSavedKinds.contains(c.kind)) c,
        ]
      : _kinds;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([SavedStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final store = SavedStore.instance;
        final stages = store.stagesPresent;
        // A stage that no longer has items (she unsaved them all) drops its chip.
        // Not on one stage's screen: that stage is the whole point of it.
        if (!_trying && _stage != null && !stages.contains(_stage)) {
          _stage = null;
        }
        final all = [
          for (final i in store.items(stage: _stage))
            if (!_trying || kTtcSavedKinds.contains(i.kind)) i,
        ];
        final total = all.length;

        return Scaffold(
          backgroundColor: p.ground,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.arrow_back_rounded, color: p.ink1),
                    ),
                    const SizedBox(width: 2),
                    Text('Saved',
                        style: pvFraunces(
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.6,
                            color: p.ink1)),
                    const Spacer(),
                    Text(total == 1 ? '1 item' : '$total items',
                        style: pvManrope(fontSize: 12.5, color: p.ink3)),
                    IconButton(
                      tooltip: 'Search saved',
                      onPressed: () => setState(() {
                        _searching = !_searching;
                        if (!_searching) _query.clear();
                      }),
                      icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded,
                          color: p.ink2),
                    ),
                  ]),
                ),
              ),
              if (_searching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
                    child: TextField(
                      controller: _query,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      style: pvManrope(fontSize: 14.5, color: p.ink1),
                      decoration: InputDecoration(
                        hintText: 'Search what you saved',
                        hintStyle: pvManrope(fontSize: 14.5, color: p.ink3),
                        isDense: true,
                        filled: true,
                        fillColor: p.surface,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: p.line, width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: p.line, width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: p.ink2.withValues(alpha: 0.5), width: 1.2),
                        ),
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: _kindChips(p, store)),
              if (!_trying && stages.length > 1)
                SliverToBoxAdapter(child: _stageChips(p, stages)),
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
              if (_kind == null)
                ..._allGrouped(p, store)
              else
                _oneKind(p, _filtered(store.items(kind: _kind, stage: _stage)), _copyFor(_kind!)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ]),
          ),
        );
      },
    );
  }

  // ---- chips -----------------------------------------------------------------

  Widget _kindChips(V2Palette p, SavedStore store) {
    // "All" first; then only the kinds she has something in, with counts. An
    // empty kind is not a chip — its invitation lives in the All view instead,
    // where every kind's header always renders.
    final present = [
      for (final c in _shown)
        if (_countOf(store, c.kind) > 0) c
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(children: [
        _chip(p, 'All', _kind == null, () => setState(() => _kind = null)),
        for (final c in present) ...[
          const SizedBox(width: 8),
          _chip(p, '${c.label} · ${_countOf(store, c.kind)}', _kind == c.kind,
              () => setState(() => _kind = c.kind)),
        ],
      ]),
    );
  }

  /// A kind's count on this screen: the stage's own when it is one stage's.
  int _countOf(SavedStore store, SavedKind k) =>
      _trying ? store.items(kind: k, stage: _stage).length : store.count(k);

  Widget _stageChips(V2Palette p, Set<String> stages) {
    const order = ['trying', 'pregnancy', 'parenting', 'skilling'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(children: [
        Text('FROM',
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: p.ink3)),
        const SizedBox(width: 10),
        _chip(p, 'Every stage', _stage == null, () => setState(() => _stage = null),
            small: true),
        for (final s in order)
          if (stages.contains(s)) ...[
            const SizedBox(width: 8),
            _chip(p, _stageLabel(s), _stage == s, () => setState(() => _stage = s),
                small: true),
          ],
      ]),
    );
  }

  /// The one button (DESIGN-SYSTEM §4.3): outlined pill; the selected state
  /// fills with surfaceAlt and inks up, never with the action colour.
  Widget _chip(V2Palette p, String label, bool on, VoidCallback onTap,
      {bool small = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: small ? 32 : 38,
        padding: EdgeInsets.symmetric(horizontal: small ? 12 : 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? p.surfaceAlt : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? p.ink2.withValues(alpha: 0.35) : p.line, width: 1.2),
        ),
        child: Text(label,
            style: pvManrope(
                fontSize: small ? 12 : 13.5,
                fontWeight: FontWeight.w700,
                color: on ? p.ink1 : p.ink2)),
      ),
    );
  }

  // ---- lists -----------------------------------------------------------------

  List<Widget> _allGrouped(V2Palette p, SavedStore store) {
    final out = <Widget>[];
    final searching = _query.text.trim().isNotEmpty;
    for (final c in _shown) {
      final items = _filtered(store.items(kind: c.kind, stage: _stage));
      // While searching, only kinds with a hit render — the invitation lines
      // are about where to save, not about the query.
      if (searching && items.isEmpty) continue;
      // The two kinds nothing saves into yet render their header only when
      // they have rows — an invitation to a place that does not exist would
      // be the chip lying about what the tap gives.
      if (items.isEmpty &&
          (c.kind == SavedKind.activity || c.kind == SavedKind.tool)) {
        continue;
      }
      out.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
          child: Row(children: [
            Text(c.label.toUpperCase(),
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    // Ink, not the purple action colour (2026-09-30).
                    // Kept for revert: p.action.withValues(alpha: 0.85)
                    color: p.ink2)),
            const SizedBox(width: 8),
            if (items.isNotEmpty)
              Text('${items.length}',
                  style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
          ]),
        ),
      ));
      if (items.isEmpty) {
        out.add(SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(c.emptyLine, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink3)),
          ),
        ));
      } else {
        // Two visible, then "See all N" — the rail rule from the Flo teardown,
        // applied vertically: the All view is a summary, never a wall.
        final shown = items.take(3).toList();
        out.add(_rows(p, shown, c));
        if (items.length > 3) {
          out.add(SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _chip(p, 'See all ${items.length}', false,
                    () => setState(() => _kind = c.kind),
                    small: true),
              ),
            ),
          ));
        }
      }
    }
    return out;
  }

  Widget _oneKind(V2Palette p, List<SavedItem> items, _KindCopy c) {
    if (items.isEmpty) {
      final searching = _query.text.trim().isNotEmpty;
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Text(searching ? 'Nothing saved matches that.' : c.emptyLine,
              style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink3)),
        ),
      );
    }
    return _rows(p, items, c);
  }

  Widget _rows(V2Palette p, List<SavedItem> items, _KindCopy c) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, i) =>
          _SavedRow(item: items[i], copy: c, p: p, drawn: _trying),
    );
  }
}

class _SavedRow extends StatelessWidget {
  const _SavedRow(
      {required this.item,
      required this.copy,
      required this.p,
      this.drawn = false});
  final SavedItem item;
  final _KindCopy copy;
  final V2Palette p;

  /// Our drawn mark for the kind instead of the grey icon square (the
  /// trying-to-conceive screen, 2026-09-30: a row you tap to go somewhere
  /// wears a drawn mark).
  final bool drawn;

  @override
  Widget build(BuildContext context) {
    final resolved = SavedItemOpener.resolveTitle(item);
    // "Gone" is about the CONTENT (no catalogue knows the id any more);
    // "available" is about whether a tap can open it right now (which also
    // needs the pregnancy controller for pregnancy-side kinds). A row that is
    // merely un-openable in a preview is not told it is gone.
    final gone = resolved == null && item.kind != SavedKind.readToBaby;
    final title = resolved ?? (item.title.isEmpty ? 'Saved item' : item.title);
    final available = !gone && SavedItemOpener.canOpen(item);
    final sub = <String>[
      if (item.subtitle != null && item.subtitle!.isNotEmpty) item.subtitle!,
      if (item.stage != null) _stageLabel(item.stage!),
      _when(item.savedAt),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: InkWell(
        onTap: available ? () => SavedItemOpener.open(context, item) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.line, width: 1),
          ),
          child: Row(children: [
            if (drawn)
              SizedBox(
                width: 40,
                height: 40,
                child: TtcTabArt(
                  mark: _savedMark(copy.kind),
                  tint: v2BlockTint(_savedHue(copy.kind), p),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(11)),
                child: Icon(copy.icon, size: 20, color: gone ? p.ink3 : p.ink2),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvFraunces(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        height: 1.25,
                        color: gone ? p.ink3 : p.ink1)),
                const SizedBox(height: 4),
                Text(gone ? 'No longer available · ${_when(item.savedAt)}' : sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12, color: p.ink3)),
                if (gone)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(copy.label,
                        style: pvManrope(fontSize: 11.5, color: p.ink3)),
                  ),
              ]),
            ),
            IconButton(
              tooltip: available ? 'Remove from saved' : 'Remove',
              onPressed: () => SavedStore.instance.unsave(item.kind, item.itemId),
              // The one black, not the purple action colour (2026-09-30).
              // Kept for revert: color: gone ? p.ink3 : p.action
              icon: Icon(Icons.bookmark_rounded, color: gone ? p.ink3 : p.ink1, size: 22),
            ),
          ]),
        ),
      ),
    );
  }

  static String _when(DateTime t) {
    final d = DateTime.now().toUtc().difference(t.toUtc()).inDays;
    if (d <= 0) return 'Today';
    if (d == 1) return 'Yesterday';
    if (d < 7) return '$d days ago';
    if (d < 30) return '${(d / 7).floor()} wk ago';
    return '${t.day}/${t.month}/${t.year}';
  }
}

// =============================================================================
//  SavedItemOpener — the ONE map from "a saved thing" to "the screen it is"
// -----------------------------------------------------------------------------
//  Each kind resolves its id against the catalogue(s) that own it and opens
//  the same screen the original surface would have. Where two catalogues share
//  a kind (`article`, `video`), the id decides — ids are namespaced and the
//  wiring tests keep them from colliding. An id no catalogue knows is
//  "No longer available": the row stays, with its snapshot title and a Remove,
//  and never opens a near match.
//
//  Screens that need the pregnancy controller take it from
//  `PregnancyController.current`; when that is null (tests, previews) the row
//  is shown but does not open.
// =============================================================================
class SavedItemOpener {
  SavedItemOpener._();

  /// The live title for the row, or null when nothing resolves the id.
  static String? resolveTitle(SavedItem it) {
    final id = it.itemId;
    switch (it.kind) {
      case SavedKind.article:
        return ttcReadById(id)?.title.en ??
            pregnancyReadById(id)?.title.en ??
            _readItem(id)?.title.en ??
            _readArticle(id)?.title ??
            // A read a door built from its own data (2026-09-23).
            switch (pvDoorEntryForReadId(id)) {
              final e? => pvDoorEntryTitle(e.library, e.id),
              null => _craving(id)?.name.en,
            };
      case SavedKind.video:
        return _pvVideo(id)?.title.en ?? _watchVideo(id)?.title;
      case SavedKind.product:
        return _pvProduct(id)?.name;
      case SavedKind.question:
        return _canI(id)?.name.en;
      case SavedKind.readToBaby:
        return ReadToBabySavedStore.instance.cached(id)?.title;
      case SavedKind.tip:
        return dailyTipById(id)?.title;
      case SavedKind.post:
        return _post(id)?.text;
      case SavedKind.recipe:
        return _recipe(id)?.name.en;
      case SavedKind.activity:
      case SavedKind.tool:
        return null;
    }
  }

  static bool canOpen(SavedItem it) {
    final c = PregnancyController.current;
    final id = it.itemId;
    switch (it.kind) {
      case SavedKind.article:
        if (ttcReadById(id) != null) return true;
        if (pregnancyReadById(id) != null || _readItem(id) != null) return c != null;
        if (_readArticle(id) != null) return true;
        // Door-built reads, cravings and Is-it-safe answers (2026-09-23).
        if (pvDoorEntryForReadId(id) != null) return c != null;
        if (_craving(id) != null) return c != null;
        if (id.startsWith(kCanIReadPrefix)) return c != null;
        return false;
      case SavedKind.video:
        if (_watchVideo(id) != null) return true;
        return _pvVideo(id) != null && c != null;
      case SavedKind.product:
        // Any stage's product opens — the unified catalogue, no controller needed.
        return _pvProduct(id) != null;
      case SavedKind.question:
        return _canI(id) != null && c != null;
      case SavedKind.readToBaby:
        // Opens with the cached body; a fresh device without it still opens
        // to Samvad, where the piece lives.
        return c != null;
      case SavedKind.tip:
        return dailyTipById(id) != null;
      case SavedKind.post:
        return _post(id) != null && c != null;
      // ⚠️ A SAVED RECIPE HAD NO WAY BACK (2026-09-23). The recipe card's
      // heart has saved `SavedKind.recipe` since e9d8ac8, and this said
      // false — every saved recipe was a row that could not be opened.
      case SavedKind.recipe:
        return _recipe(id) != null && c != null;
      case SavedKind.activity:
      case SavedKind.tool:
        return false;
    }
  }

  static void open(BuildContext context, SavedItem it) {
    final c = PregnancyController.current;
    final id = it.itemId;
    void push(Widget w, {String? name}) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => w, settings: RouteSettings(name: name)));

    switch (it.kind) {
      case SavedKind.article:
        // ⚠️ THE TTC LOOK-UPS AND DAILY CARDS OPEN TOO (2026-09-28). The reader
        // saves a test as `ttc_test_<id>`, a Can I answer as `ttc_cani_<id>`
        // and a daily card as `ttc_insight_<id>`, and none of them resolved
        // here: the bookmark saved and the row did nothing, the wiring gate's
        // own failure. Each opens the way the stage opens it.
        if (id.startsWith(kTtcTestReadPrefix)) {
          final t = ttcTestById(id.substring(kTtcTestReadPrefix.length));
          if (t != null) openTtcTestRead(context, t);
          return;
        }
        if (id.startsWith(kTtcCanIReadPrefix)) {
          final e = ttcCanIById(id.substring(kTtcCanIReadPrefix.length));
          if (e != null) openTtcCanIRead(context, e);
          return;
        }
        if (id.startsWith(kTtcInsightReadPrefix)) {
          final i = _ttcInsight(id.substring(kTtcInsightReadPrefix.length));
          if (i != null) openTtcInsight(context, i);
          return;
        }
        if (ttcReadById(id) != null) {
          openTtcSurface(context, kTtcReadPrefix + id);
        } else if (pregnancyReadById(id) != null && c != null) {
          openPvDoorRead(context, id, c);
        } else if (_readItem(id) != null && c != null) {
          push(ReadItemScreen(item: _readItem(id)!, controller: c), name: 'read/$id');
        } else if (_readArticle(id) != null) {
          push(ReadingReaderScreen(article: _readArticle(id)!), name: 'pp/read/$id');
        } else if (c != null) {
          // A door-built read opens through its door's own entry opener.
          if (pvDoorEntryForReadId(id) case final e?) {
            final w = pvDoorEntryScreen(e.library, e.id, c);
            if (w != null) push(w, name: 'saved/read/$id');
          } else if (_craving(id) case final item?) {
            push(CravingDetailScreen(item: item, pregnancy: c), name: 'saved/craving/$id');
          } else if (id.startsWith(kCanIReadPrefix)) {
            openCanIAnswerById(context, id.substring(kCanIReadPrefix.length), c);
          }
        }
      case SavedKind.video:
        final w = _watchVideo(id);
        if (w != null) {
          push(w.quick ? QuickLearnScreen(startId: w.id) : WatchPlayerScreen(video: w),
              name: 'pp/watch/$id');
        } else if (_pvVideo(id) != null && c != null) {
          push(WatchLearnScreen(controller: c), name: 'watch');
        }
      case SavedKind.product:
        // Was `ProductDetailScreen(product: _product(id)!, controller: c)` on
        // the pregnancy catalogue only — a saved parenting or TTC product
        // showed "no longer available". The unified page opens all three.
        if (_pvProduct(id) != null) {
          push(PvProductScreen(productId: id), name: '$kPvProductRoutePrefix$id');
        }
      case SavedKind.question:
        if (_canI(id) != null && c != null) openCanIAnswer(context, _canI(id)!, c);
      case SavedKind.readToBaby:
        final piece = ReadToBabySavedStore.instance.cached(id);
        if (piece != null && c != null) {
          push(SavedRtbReadScreen(controller: c, piece: piece), name: 'saved/rtb/$id');
        } else if (c != null) {
          // No body on this device: the title is all we have. Samvad is where
          // the piece lives, so open it there.
          push(SamvadScreen(controller: c), name: 'garbh/samvad');
        }
      case SavedKind.tip:
        final t = dailyTipById(id);
        if (t != null) push(SavedTipScreen(tip: t), name: 'saved/tip/$id');
      case SavedKind.post:
        if (_post(id) != null && c != null) {
          push(PostDetailScreen(post: _post(id)!, controller: c), name: 'post/$id');
        }
      case SavedKind.recipe:
        if (_recipe(id) case final r? when c != null) {
          push(RecipeCookScreen(recipe: r, pregnancy: c), name: 'saved/recipe/$id');
        }
      case SavedKind.activity:
      case SavedKind.tool:
        break;
    }
  }

  // ---- catalogue lookups, each null for an unknown id --------------------------
  static TtcInsight? _ttcInsight(String bare) {
    for (final i in [
      ...ttcAllInsights,
      for (final set in kTtcTreatmentInsights.values) ...set,
    ]) {
      if (i.id == bare) return i;
    }
    return null;
  }

  static Recipe? _recipe(String id) {
    for (final r in kRecipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  static CravingItem? _craving(String id) {
    if (!id.startsWith(kCravingReadPrefix)) return null;
    final bare = id.substring(kCravingReadPrefix.length);
    for (final c in kCravingItems) {
      if (c.id == bare) return c;
    }
    return null;
  }

  static ReadItem? _readItem(String id) {
    for (final r in kReadItems) {
      if (r.id == id) return r;
    }
    return null;
  }

  static ReadArticle? _readArticle(String id) {
    for (final a in readCatalog) {
      if (a.id == id) return a;
    }
    return null;
  }

  static PvVideo? _pvVideo(String id) {
    for (final v in kVideos) {
      if (v.id == id) return v;
    }
    return null;
  }

  static WatchVideo? _watchVideo(String id) {
    for (final v in kWatchAll) {
      if (v.id == id) return v;
    }
    return null;
  }

  static PvProduct? _pvProduct(String id) => PvCatalogStore.instance.byId(id);

  /* kept for revert — the pregnancy-only lookup
  static Product? _product(String id) {
    for (final p in kProducts) {
      if (p.id == id) return p;
    }
    return null;
  }
  */

  static CanIEntry? _canI(String id) {
    for (final e in kCanIEntries) {
      if (e.id == id) return e;
    }
    return null;
  }

  static CommunityPost? _post(String id) {
    for (final p in CommunityStore.instance.allPosts) {
      if (p.id == id) return p;
    }
    return null;
  }
}

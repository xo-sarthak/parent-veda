// =============================================================================
//  Pregnancy — the Learn tab: every read on every door, in one place
// -----------------------------------------------------------------------------
//  Built 2026-09-29 for the structure pass, when the pregnancy bar became
//  Today · Learn · Products · Tools · More to match trying to conceive (the
//  user: "replace Calendar with Learn, and refer to the TTC bar for
//  symmetry"). Before this, pregnancy had no library: a woman who remembered
//  reading about the NT scan had to remember which door it was behind.
//
//  ⚠️ THE TTC LEARN TAB'S SHAPE, SECTION FOR SECTION, AND NOTHING ELSE OF IT.
//  The user's screenshot and `ttc_learn_screen.dart` set the headings and the
//  order; the content is pregnancy's own:
//
//    search              the stage-wide index every door searches
//                        (`pvSearchIndex`), so a hit here opens exactly where
//                        it does inside its door
//    explore by topic    one tile per door, in its drawn mark
//    your reading        reads she has started, then reads she saved
//    start here          "Pregnancy 101", a short ordered course
//    films               the week's films, the same shelf the home shows
//                        (kept, not hidden: the user, 2026-09-29)
//    reads from the door each door's written pieces, the door's own tabs as
//                        chips (the library mirrors the doors; it does not
//                        invent a second set of topics)
//    courses             the stage's programmes; the ones with no lesson made
//                        say "Opening soon" with no price (gap analysis P1)
//    common questions    answered from the reads' own FAQs
//
//  ⚠️ DERIVED, NOT LISTED BY HAND. Shelves walk `kPvDoorPages`, so a read added
//  to any door appears here with no change to this file, and a new door gets a
//  shelf and a topic tile. `test/preg_learn_more_test.dart` asserts that every
//  door has a tile and every written door piece is on a shelf.
//
//  ⚠️ ONE READER, ONE OPENER. Every row opens through `openPvDoorTile`, the
//  function the doors themselves call, so a read opens in `PvReaderScreen` and
//  a scan page opens on its scan page, from here as from its door.
//
//  Mobbin: Oura's Pregnancy Insights resources (rows with a photo, a title,
//  one line and minutes,
//  https://mobbin.com/screens/732c6f66-9fcf-4753-afb7-8262638a6eb5), and the
//  Flo Insights topic row the TTC tab was built from (FLO-INSIGHTS,
//  https://mobbin.com/screens/3fba06c7-b554-46cd-9487-ae5e74721a32).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/brackets/pregnancy_brackets.dart';
import '../../data/doors/pv_door_after_loss.dart';
import '../../data/doors/pv_door_data.dart';
import '../../data/doors/pv_door_twins.dart';
import '../../services/ready_birth_context_store.dart';
import 'preg_twins.dart' show pregExpectingTwins;
import '../../data/learn/pv_learn_view.dart';
import '../../data/prepare_data.dart' show kPrepOpeningSoon;
import '../../data/reads/pregnancy_reads.dart' show pregnancyReadById;
import '../../models/bracket.dart';
import '../../models/pv_read.dart';
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/pv_read_store.dart';
import '../../services/pv_search_store.dart';
import '../../services/saved_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve, kAskVedaRoute;
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../can_i_screen.dart';
import '../doors/pv_door_router.dart';
import '../doors/pv_door_screen.dart';
import '../doors/pv_list_row.dart';
import '../doors/pv_live_search.dart';
import '../learn/pv_learn_catalog.dart';
import '../learn/pv_offering_screen.dart' show pvOpenOffering;
import '../products/pv_store_chrome.dart'
    show PvRoundIcon, PvSectionHead, PvChip, kPvInk, kPvLine, pvStorePalette, pvSnack;
import '../saved_screen.dart';
import '../search/pv_search_screen.dart';
import '../tools/ask_veda_screen.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';
import '../v2/v3_film_screen.dart';
import '../v2/v3_week_film.dart';
import 'preg_ended_screen.dart' show openAfterLossDoor;
import 'preg_chrome.dart';

/// The Learn tab's route name, for anything that needs to detect it.
const String kPregLearnRoute = 'pregnancy/learn';

/// "Is it safe?" has no door page; it opens the answers screen (the user's
/// allowed exception to the door format).
const String kPregIsItSafeBracketId = 'pregnancy_is_it_safe';

// =============================================================================
//  The data, derived
// =============================================================================

/// One door on the Learn tab: its bracket, its page (null for Is it safe?),
/// and its written pieces.
class PregLearnTopic {
  const PregLearnTopic(this.bracket, this.page, this.pieces);
  final Bracket bracket;
  final PvDoorPage? page;
  final List<PregLearnPiece> pieces;
}

/// A written piece on a door, with the door tab it sits under.
class PregLearnPiece {
  const PregLearnPiece(this.tile, this.groupId);
  final PvDoorTile tile;
  final String groupId;

  /// The read behind it, when it is a `PvRead` (for progress and saving).
  String? get readId => switch (tile) {
        PvDoorGuideTile(:final readId) => readId,
        PvDoorMythTile(:final readId) => readId,
        _ => null,
      };
}

/// Written formats: what a reader opens, not a tool, a film or a checklist.
const Set<PvDoorFormat> _kWritten = {
  PvDoorFormat.article,
  PvDoorFormat.guide,
  PvDoorFormat.read,
  PvDoorFormat.mythFact,
};

/// True when a door tile is a written piece she can open today.
bool pregLearnIsWritten(PvDoorTile t) =>
    !t.comingSoon && _kWritten.contains(t.format);

/// Every door's written pieces, once each, in the door's own order.
List<PregLearnPiece> pregLearnPiecesOf(PvDoorPage page) {
  final seen = <String>{};
  final out = <PregLearnPiece>[];
  for (final g in page.groups) {
    for (final s in page.sectionsOf(g.id)) {
      for (final t in s.tiles) {
        if (!pregLearnIsWritten(t)) continue;
        final key = switch (t) {
          PvDoorGuideTile(:final readId) => 'r:$readId',
          PvDoorMythTile(:final readId) => 'r:$readId',
          PvDoorEntryTile(:final library, :final entryId) => '${library.name}:$entryId',
          PvDoorReadTile(:final surfaceId) => 's:$surfaceId',
          _ => 't:${t.title}',
        };
        if (seen.add(key)) out.add(PregLearnPiece(t, g.id));
      }
    }
  }
  return out;
}

/// Every door, the home's tiles first (in the home's order), then the two
/// doors reached from inside others (After a loss, Twins).
List<PregLearnTopic> pregLearnTopics() {
  final out = <PregLearnTopic>[];
  final brackets = [...kPregnancyBrackets, kPregTwinsBracket, kPregAfterLossBracket];
  for (final b in brackets) {
    final page = b.id == kPregAfterLossBracket.id
        ? kAfterLossDoor
        : b.id == kPregTwinsBracket.id
            ? kTwinsDoor
            : pvDoorPageFor(b.id);
    if (page == null && b.id != kPregIsItSafeBracketId) continue;
    out.add(PregLearnTopic(b, page, page == null ? const [] : pregLearnPiecesOf(page)));
  }
  return out;
}

/// "Pregnancy 101": the reads to begin with, in order, from the first test to
/// the signs of labour. Ids, not copies, so each one is the door's own read.
const List<String> kPregLearnStartIds = [
  'preg_first_read_this_week',
  'preg_first_read_due_date',
  'preg_scan_read_first_visit',
  'preg_diet_read_add_now',
  'preg_week_read_managing_nausea',
  'preg_cond_read_less_movement',
  'preg_labour_read_signs_near',
];

List<PvRead> pregLearnStartHere() =>
    [for (final id in kPregLearnStartIds) ?pregnancyReadById(id)];

/// Short answers: the first question of each Pregnancy 101 read.
List<(PvReadFaq, PvRead)> pregLearnFaqs() => [
      for (final r in pregLearnStartHere())
        if (r.faqs.isNotEmpty) (r.faqs.first, r),
    ];

/// What the recall list offers before she has searched anything.
const List<String> _kPopular = [
  'Spotting',
  'Is papaya safe',
  'NT scan',
  'Sugar test',
  'Baby moving less',
  'Signs of labour',
];

// =============================================================================
//  The screen
// =============================================================================

class PregLearnScreen extends StatefulWidget {
  const PregLearnScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<PregLearnScreen> createState() => _PregLearnScreenState();
}

class _PregLearnScreenState extends State<PregLearnScreen> {
  final PvLiveSearch _search = PvLiveSearch();

  /// Per shelf: which door tab is chosen (null = All), and whether it is open.
  final Map<String, String?> _tab = {};
  final Set<String> _expanded = {};
  final Set<int> _openFaq = {};

  late final List<PregLearnTopic> _baseTopics = pregLearnTopics();

  /// Twins and more leads once she has said she is carrying more than one
  /// (2026-09-30, gap analysis P2). Ranking only: every topic is still here, once.
  // Kept for revert: `late final _topics = pregLearnTopics();`
  List<PregLearnTopic> get _topics => pregExpectingTwins
      ? [
          for (final t in _baseTopics)
            if (t.bracket.id == kPregTwinsBracket.id) t,
          for (final t in _baseTopics)
            if (t.bracket.id != kPregTwinsBracket.id) t,
        ]
      : _baseTopics;
  late final List<PvRead> _start = pregLearnStartHere();
  late final List<(PvReadFaq, PvRead)> _faqs = pregLearnFaqs();
  late final List<PvOfferingView> _courses = _loadCourses();

  PregnancyController get _c => widget.pregnancy;

  static List<PvOfferingView> _loadCourses() {
    try {
      return PvLearnCatalog.instance
          .all(stage: LifeStage.pregnancy)
          .where((v) => v.kind != PvLearnKind.consult)
          .toList();
    } catch (_) {
      // Local-first: the catalogue merging late is never a crash here.
      return const [];
    }
  }

  @override
  void initState() {
    super.initState();
    PvReadStore.instance.load();
    SavedStore.instance.load();
    PvSearchStore.instance.init();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ---- opening things ---------------------------------------------------------

  void _openDoor(Bracket b, {String? tab}) {
    pvCommitFeedback();
    if (b.id == kPregAfterLossBracket.id) {
      openAfterLossDoor(context, _c, tab: tab);
      return;
    }
    if (b.id == kPregIsItSafeBracketId) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'can_i'),
        builder: (_) => CanIScreen(controller: _c),
      ));
      return;
    }
    final page = b.id == kPregTwinsBracket.id ? kTwinsDoor : pvDoorPageFor(b.id);
    if (page == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'bracket/${b.id}'),
      builder: (_) => PvDoorScreen(page: page, bracket: b, pregnancy: _c, initialGroup: tab),
    ));
  }

  void _openPiece(PvDoorTile t) {
    pvCommitFeedback();
    openPvDoorTile(context, t, _c);
  }

  void _openRead(PvRead r) {
    pvCommitFeedback();
    openPvDoorRead(context, r.id, _c);
  }

  void _openSaved() => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const SavedScreen(),
        settings: const RouteSettings(name: 'saved'),
      ));

  void _askVeda(String q) {
    PvSearchStore.instance.remember(q);
    _search.focus.unfocus();
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: kAskVedaRoute),
      builder: (_) => AskVedaScreen(controller: _c, initialQuery: q),
    ));
  }

  void _openCourse(PvOfferingView v) {
    pvCommitFeedback();
    if (kPrepOpeningSoon.contains(v.id)) {
      showPregOpeningSoon(context, v.title, id: v.id);
    } else {
      pvOpenOffering(context, v);
    }
  }

  // ---- build --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _search,
        _c,
        SavedStore.instance,
        PvReadStore.instance,
        PvSearchStore.instance,
        // Twins and more leads when she says so (preg_twins.dart).
        ReadyBirthContextStore.instance,
      ]),
      builder: (context, _) {
        final p = pvStorePalette;
        return PvLiveSearchScope(
          search: _search,
          child: Container(
            color: p.ground,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                  0, MediaQuery.of(context).padding.top + 12, 0, kAskFabReserve + 40),
              children: [
                _header(p),
                const SizedBox(height: 14),
                _pad(PvLiveSearchField(
                  search: _search,
                  p: p,
                  hint: 'Search reads, scans and questions',
                  onSubmitted: (q) => PvSearchStore.instance.remember(q),
                )),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: pvLiveSearchSheetMin(context, _search)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _search.searching
                        ? _results(p)
                        : _search.recalling
                            ? _recall(p)
                            : _page(p),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const double _g = 18;

  Widget _pad(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: _g), child: child);

  Widget _header(V2Palette p) => _pad(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text('Learn',
                  style: pvFraunces(
                      fontSize: 30, fontWeight: FontWeight.w500, height: 1.1, color: p.ink1)),
            ),
            PvRoundIcon(icon: Icons.bookmark_border_rounded, onTap: _openSaved, size: 42),
          ]),
          const SizedBox(height: 6),
          PvLiveSearchWords(
            search: _search,
            child: Text("Everything we've written about pregnancy, in one place.",
                style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
          ),
        ],
      ));

  List<Widget> _page(V2Palette p) => [
        const SizedBox(height: 22),
        _topicRow(p),
        _yourReading(p),
        _startHere(p),
        _films(p),
        for (final t in _topics)
          if (t.pieces.isNotEmpty) _shelf(p, t),
        _coursesRail(p),
        _questions(p),
        const SizedBox(height: 26),
        _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, size: 16, color: p.ink3),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
                "Everything here explains. None of it is a diagnosis, and your own doctor's word comes first.",
                style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
          ),
        ])),
      ];

  Widget _head(String eyebrow, String title,
          {String? action, VoidCallback? onAction, String? lead}) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(_g, 30, _g, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PvSectionHead(eyebrow: eyebrow, title: title, action: action, onAction: onAction),
          if (lead != null) ...[
            const SizedBox(height: 6),
            Text(lead, style: pvManrope(fontSize: 13, height: 1.45, color: pvStorePalette.ink2)),
          ],
        ]),
      );

  // ---- explore by topic ---------------------------------------------------------

  Widget _topicRow(V2Palette p) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // One ParentVeda (2026-09-30): the one serif heading, not a violet
        // caps eyebrow. Kept for revert: _pad(_eyebrow(p, 'Explore by topic')),
        _pad(const PregSectionHeading('Explore by topic')),
        const SizedBox(height: 10),
        // 120, not TTC's 108: at 108 the label and its count overflow the
        // tile by a few points once text runs larger (a larger system text
        // size, or the test font).
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: _g),
            itemCount: _topics.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final t = _topics[i];
              final n = t.pieces.length;
              return PregLearnTopicTile(
                key: ValueKey('preg_learn_topic_${t.bracket.id}'),
                label: t.bracket.label.en,
                meta: t.page == null
                    ? 'Quick answers'
                    : n == 1
                        ? '1 read'
                        : '$n reads',
                hue: t.bracket.hue,
                mark: bracketMarkFor(t.bracket.id),
                onTap: () => _openDoor(t.bracket),
              );
            },
          ),
        ),
      ]);

  // ---- your reading -------------------------------------------------------------

  Widget _yourReading(V2Palette p) {
    final store = PvReadStore.instance;
    final ids = <String>{
      for (final t in _topics)
        for (final x in t.pieces) ?x.readId,
    };
    final reads = [for (final id in ids) ?pregnancyReadById(id)];
    final going = [for (final r in reads) if (store.isStarted(r.id) && !store.isFinished(r.id)) r];
    final saved = [for (final r in reads) if (store.isSaved(r.id)) r];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head('Your reading', going.isNotEmpty ? 'Pick up where you left off' : 'Saved for later',
          action: 'All saved', onAction: _openSaved),
      const SizedBox(height: 12),
      if (going.isNotEmpty)
        _pad(PvRowGroup(p: p, children: [
          for (final r in going.take(3))
            _readRow(p, r, meta: '${r.minutes} min read'),
        ])),
      if (going.isNotEmpty && saved.isNotEmpty) const SizedBox(height: 10),
      if (saved.isNotEmpty)
        _pad(PvRowGroup(p: p, children: [
          for (final r in saved.take(3))
            _readRow(p, r,
                meta: '${r.minutes} min read',
                trailing: Icon(Icons.bookmark_rounded, size: 18, color: p.ink3)),
        ])),
      // A feature is never hidden: with nothing started or saved, the row is
      // the invitation, and says what saving does.
      if (going.isEmpty && saved.isEmpty)
        _pad(Row(children: [
          Icon(Icons.bookmark_border_rounded, size: 20, color: p.ink2),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Tap the bookmark on any read and it waits for you here.',
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
          ),
        ])),
    ]);
  }

  Widget _readRow(V2Palette p, PvRead r, {required String meta, Widget? trailing}) => PvListRow(
        p: p,
        leading: PvMarkWell(
            p: p, hue: r.hue, photo: readImageForRead(r), mark: IntentMark.pageMark),
        title: r.title.en,
        line: r.teaser.en,
        meta: meta,
        trailing: trailing,
        onTap: () => _openRead(r),
      );

  // ---- start here ---------------------------------------------------------------

  Widget _startHere(V2Palette p) {
    if (_start.isEmpty) return const SizedBox.shrink();
    final store = PvReadStore.instance;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head('Start here', 'Pregnancy 101',
          lead: 'Short reads for the months ahead, in order if you like. Each one makes the next easier.'),
      const SizedBox(height: 12),
      _pad(PvRowGroup(p: p, children: [
        for (var i = 0; i < _start.length; i++)
          PvListRow(
            p: p,
            leading: _StepMark(n: i + 1, done: store.isFinished(_start[i].id)),
            title: _start[i].title.en,
            meta: store.isFinished(_start[i].id)
                ? 'Read · ${_start[i].minutes} min read'
                : '${_start[i].minutes} min read',
            onTap: () => _openRead(_start[i]),
          ),
      ])),
    ]);
  }

  // ---- films --------------------------------------------------------------------

  /// The week's films, the shelf the home shows, as its rows. Kept visible on
  /// the user's word (2026-09-29: "don't hide them for now").
  Widget _films(V2Palette p) {
    final week = _c.currentWeek;
    final films = v3ShelfVideosFor(week, take: 2);
    if (films.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head('Films', 'Films for week $week'),
      const SizedBox(height: 4),
      _pad(Column(children: [
        for (final v in films) ...[
          V3VideoRow(
              video: v,
              p: p,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: RouteSettings(name: 'pregnancy/film/${v.id}'),
                  builder: (_) => V3FilmScreen(video: v, week: week, pregnancy: _c)))),
          if (v != films.last) Divider(height: 1, thickness: 1, color: p.line),
        ],
      ])),
    ]);
  }

  // ---- one door's shelf -----------------------------------------------------------

  Widget _shelf(V2Palette p, PregLearnTopic t) {
    final page = t.page!;
    final key = t.bracket.id;
    final tabs = [
      for (final g in page.groups)
        if (t.pieces.any((x) => x.groupId == g.id)) g,
    ];
    final chosen = _tab[key];
    final pieces = chosen == null ? t.pieces : [for (final x in t.pieces) if (x.groupId == chosen) x];
    final open = _expanded.contains(key);
    const fold = 4;
    final shown = open ? pieces : pieces.take(fold).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head('Reads from the door', t.bracket.label.en,
          // Names what it opens (one ParentVeda). Was 'Open'.
          action: 'Open the door', onAction: () => _openDoor(t.bracket, tab: chosen)),
      if (tabs.length > 1) ...[
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: _g),
            children: [
              PvChip(label: 'All', selected: chosen == null, onTap: () => setState(() => _tab[key] = null)),
              for (final g in tabs) ...[
                const SizedBox(width: 6),
                PvChip(
                  label: g.label,
                  selected: chosen == g.id,
                  onTap: () => setState(() => _tab[key] = g.id),
                ),
              ],
            ],
          ),
        ),
      ],
      const SizedBox(height: 12),
      _pad(PvRowGroup(p: p, children: [
        for (final x in shown)
          PvListRow(
            key: ValueKey('preg_learn_piece_${key}_${x.tile.title}'),
            p: p,
            leading: PvMarkWell(
                p: p,
                hue: t.bracket.hue,
                photo: pvDoorTilePhoto(x.tile),
                bracket: bracketMarkFor(t.bracket.id),
                mark: bracketMarkFor(t.bracket.id) == null ? IntentMark.pageMark : null),
            title: x.tile.title,
            line: x.tile.blurb,
            meta: x.tile.meta,
            onTap: () => _openPiece(x.tile),
          ),
      ])),
      if (pieces.length > fold)
        _pad(Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => open ? _expanded.remove(key) : _expanded.add(key)),
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8), foregroundColor: p.ink1),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(open ? 'Show fewer' : 'Show all ${pieces.length}',
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
              const SizedBox(width: 4),
              Icon(open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 18, color: p.ink1),
            ]),
          ),
        )),
    ]);
  }

  // ---- courses ------------------------------------------------------------------

  Widget _coursesRail(V2Palette p) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _head('Courses and programmes', 'Go deeper, with someone who knows'),
        const SizedBox(height: 12),
        if (_courses.isEmpty)
          _pad(Text('Courses, classes and small groups will appear here as they open.',
              style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)))
        else
          SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: _g),
              itemCount: _courses.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => PregCourseCard(
                view: _courses[i],
                openingSoon: kPrepOpeningSoon.contains(_courses[i].id),
                onTap: () => _openCourse(_courses[i]),
              ),
            ),
          ),
      ]);

  // ---- common questions -----------------------------------------------------------

  Widget _questions(V2Palette p) {
    if (_faqs.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _head('Common questions', 'Short answers'),
      const SizedBox(height: 8),
      for (var i = 0; i < _faqs.length; i++)
        _pad(_FaqItem(
          question: _faqs[i].$1.question.en,
          answer: _faqs[i].$1.answer.en,
          from: 'From: ${_faqs[i].$2.title.en}',
          open: _openFaq.contains(i),
          last: i == _faqs.length - 1,
          onToggle: () =>
              setState(() => _openFaq.contains(i) ? _openFaq.remove(i) : _openFaq.add(i)),
          onOpenRead: () => _openRead(_faqs[i].$2),
        )),
    ]);
  }

  // ---- search: recall and results ---------------------------------------------------

  List<Widget> _recall(V2Palette p) {
    final recent = PvSearchStore.instance.recent;
    Widget row(IconData icon, String q) => PvPress(
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              _search.run(q);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _g, vertical: 12),
              child: Row(children: [
                Icon(icon, size: 20, color: p.ink2),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(q,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 15, fontWeight: FontWeight.w600, color: p.ink1)),
                ),
                Icon(Icons.north_west_rounded, size: 16, color: p.ink3),
              ]),
            ),
          ),
        );
    return [
      if (recent.isNotEmpty) ...[
        const SizedBox(height: 22),
        pvLiveSearchRecallHeading(p, 'Recent', onClear: PvSearchStore.instance.clear),
        const SizedBox(height: 6),
        for (final r in recent) row(Icons.history_rounded, r),
      ],
      const SizedBox(height: 22),
      pvLiveSearchRecallHeading(p, 'People often look for'),
      const SizedBox(height: 6),
      for (final q in _kPopular) row(Icons.search_rounded, q),
    ];
  }

  /// The stage-wide index and matcher every door uses, so "NT" typed here and
  /// in Scans & tests finds the same things and opens them the same way.
  List<Widget> _results(V2Palette p) {
    final q = _search.query;
    final hits = pvSearch(q, pvSearchIndex());
    return [
      const SizedBox(height: 14),
      if (hits.isEmpty)
        _pad(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Nothing here matches that yet. Try a shorter word, or ask Veda.',
              style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
        )),
      for (var i = 0; i < hits.length && i < 24; i++)
        PvSearchHitRow(
          key: pvSearchHitKey(i),
          p: p,
          hit: hits[i],
          onTap: () {
            _search.focus.unfocus();
            openPvSearchHit(context, hits[i], _c, query: q);
          },
        ),
      const SizedBox(height: 12),
      _pad(PvLiveSearchWayOn(
        p: p,
        icon: Icons.auto_awesome_outlined,
        title: 'Ask Veda about "$q"',
        line: 'An answer from what we have written',
        onTap: () => _askVeda(q),
      )),
    ];
  }
}

/// A read's photo: the read-image table first, then the read's own.
String? readImageForRead(PvRead r) => pvDoorTilePhoto(
    PvDoorGuideTile(title: r.title.en, blurb: r.teaser.en, readId: r.id)) ?? r.imageUrl;

// =============================================================================
//  "Opening soon" — a course with no lesson made yet
// =============================================================================

/// The gap analysis's P1, "Do not sell courses that do not exist yet": no
/// price, no Buy, and "Tell me when it opens" collects interest instead.
///
/// ⚠️ INTEREST IS REMEMBERED ON THIS PHONE ONLY, for now. Counting it across
/// everyone ("we learn which course to make first") needs a table; that is
/// written down in docs/STILL-OPEN.md rather than half-built here.
/// Where "Tell me when it opens" is kept: the course ids she asked about.
const String kPregCourseInterestKey = 'preg_course_interest_v1';

Future<void> _rememberInterest(String id) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(kPregCourseInterestKey) ?? const <String>[];
    if (!ids.contains(id)) await prefs.setStringList(kPregCourseInterestKey, [...ids, id]);
  } catch (_) {
    // Local-first: a storage failure is never a crash, and costs one tap.
  }
}

void showPregOpeningSoon(BuildContext context, String title, {String? id}) {
  final p = pvStorePalette;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Opening soon',
              style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.ink2)),
          const SizedBox(height: 8),
          Text(title,
              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w500, height: 1.2, color: p.ink1)),
          const SizedBox(height: 10),
          Text(
              "We're still making this course, so it isn't on sale. Tell us you'd like it and "
              "we'll let you know here when it opens.",
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: kPvInk, shape: const StadiumBorder()),
              onPressed: () {
                pvCommitFeedback();
                if (id != null) _rememberInterest(id);
                Navigator.of(ctx).pop();
                pvSnack(context, "Noted. We'll tell you when it opens.");
              },
              child: Text('Tell me when it opens',
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ]),
      ),
    ),
  );
}

// =============================================================================
//  The pieces (the TTC Learn tab's, drawn the same way)
// =============================================================================

class PregLearnTopicTile extends StatelessWidget {
  const PregLearnTopicTile({
    super.key,
    required this.label,
    required this.meta,
    required this.hue,
    required this.mark,
    required this.onTap,
  });
  final String label;
  final String meta;
  final double hue;
  final BracketMark? mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final tint = v2BlockTint(hue, p);
    return PvPress(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), side: const BorderSide(color: kPvLine)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 124,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(mark == null ? 8 : 4),
                  child: mark == null
                      ? HubIntentArt(mark: IntentMark.pageMark, tint: tint)
                      : V3BracketArt(mark: mark!, tint: tint),
                ),
                const Spacer(),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
                const SizedBox(height: 2),
                Text(meta, style: pvManrope(fontSize: 11.5, color: p.ink3)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// A programme on a rail. A course with no lesson made says "Opening soon"
/// where the price would be.
class PregCourseCard extends StatelessWidget {
  const PregCourseCard({
    super.key,
    required this.view,
    required this.onTap,
    this.openingSoon = false,
  });
  final PvOfferingView view;
  final VoidCallback onTap;
  final bool openingSoon;

  static String _kind(PvLearnKind k) => switch (k) {
        PvLearnKind.course => 'Course',
        PvLearnKind.masterclass => 'Masterclass',
        PvLearnKind.cohort => 'Group programme',
        PvLearnKind.consult => 'Consultation',
        PvLearnKind.classPack => 'Classes',
      };

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final tint = v2BlockTint(view.hue, p);
    final cover = Container(
      color: tint,
      alignment: Alignment.center,
      child: Icon(Icons.school_outlined, size: 28, color: p.ink2),
    );
    final meta = [
      _kind(view.kind),
      if (openingSoon) 'Opening soon' else ...[
        if (view.lessons.isNotEmpty) '${view.lessons.length} lessons',
        view.priceLabel,
      ],
    ].join(' · ');
    return PvPress(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 220,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: view.cover == null
                    ? cover
                    : Image.network(view.cover!, fit: BoxFit.cover, errorBuilder: (_, _, _) => cover),
              ),
            ),
            const SizedBox(height: 10),
            Text(view.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3, color: p.ink1)),
            const SizedBox(height: 3),
            Text(meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
          ]),
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
    required this.from,
    required this.open,
    required this.last,
    required this.onToggle,
    required this.onOpenRead,
  });
  final String question;
  final String answer;
  final String from;
  final bool open;
  final bool last;
  final VoidCallback onToggle;
  final VoidCallback onOpenRead;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Container(
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: kPvLine)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PvPress(
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text(question,
                      style: pvManrope(
                          fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.35, color: p.ink1)),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: p.ink2),
                ),
              ]),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(answer, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: onOpenRead,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Flexible(
                            child: Text(from,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 15, color: p.ink1),
                        ]),
                      ),
                    ),
                  ]),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }
}

/// The numbered circle of a Pregnancy 101 step, ticked once read.
class _StepMark extends StatelessWidget {
  const _StepMark({required this.n, required this.done});
  final int n;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return SizedBox(
      width: 40,
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? p.ink1 : Colors.white,
            border: Border.all(color: done ? p.ink1 : p.ink3, width: 1.3),
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text('$n',
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
        ),
      ),
    );
  }
}

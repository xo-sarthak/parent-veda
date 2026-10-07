// =============================================================================
//  YogaHomeScreen - ParentVeda Yoga & Classes home (cult.fit-style)
// -----------------------------------------------------------------------------
//  An image-led marketplace of yoga & wellbeing classes for the whole journey -
//  prenatal, postnatal, post-IVF, breathing/Lamaze, meditation and core recovery.
//  A top Live / Recorded toggle, and under Live a 1:1 / Group toggle, resolve to
//  three effective modes. Below the toggles, cult.fit-style category sections:
//  each a header + a horizontal scroll of large "image" cards (title overlaid +
//  an EXPLORE pill), filtered to the selected mode. A search bar spans all modes.
//  Reached from the Explore drawer. Pushed screen (back link, no bottom nav).
//
//  ON THE ONE PARENTVEDA LOOK (2026-10-07). The page wears the shared tool
//  shell (`PregToolScaffold`), the same field, round back and drawn mark as
//  every TTC and pregnancy tool, so the pregnancy Prepare tab (which opens this
//  same screen, filtered) and parenting's Explore get one page. The two mode
//  toggles are `PvChip`s; each category is a rail of white hairline cards.
//  Mobbin: Open's Discover, a small-caps rail header and under each picture
//  just the title, then "30 min - teacher" (mobbin.com/screens/a9149d6b-362f-
//  4673-bc79-c52e2cec9dcf). Adopted: the title-then-duration-and-teacher card,
//  the save mark on the picture. Kept out, per the parenting trust rules: the
//  star rating the old cards showed (`cls.rating`), which no real review
//  stands behind. The teacher's name still opens her profile
//  (`yogaInstructorLine`). The old build is kept below for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show HubIntentArt, IntentMark;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvChip;
import '../v2/v2_palette.dart';
import 'pp_care_parts.dart' show ppCareHeading;
import 'pp_common.dart';
import 'pp_section_extras.dart';
import 'pp_yoga_data.dart';
import 'yoga_class_screen.dart';
import 'yoga_common.dart';

class YogaHomeScreen extends StatefulWidget {
  const YogaHomeScreen({
    super.key,
    this.categoryFilter,
    this.backLabel = 'Explore',
    this.eyebrow = 'ParentVeda Yoga',
    this.heroTitle = 'Yoga & parenting classes',
    this.intro =
        'Expert-led classes for every stage - pregnancy, recovery, IVF, breath and calm. Live with a teacher, or on your own time.',
  });

  /// If set, only these category ids are shown — how the SAME cult.fit screen
  /// serves the pregnancy Prepare tab (prenatal/breathing/…) and the parenting
  /// Explore tab (everything). Null = show all (the parenting default, kept
  /// exactly as it was).
  final Set<String>? categoryFilter;
  final String backLabel;
  final String eyebrow;
  final String heroTitle;
  final String intro;

  @override
  State<YogaHomeScreen> createState() => _YogaHomeScreenState();
}

/// The pregnancy Prepare tab uses this SAME screen, limited to the categories a
/// pregnant mother wants — the content is already tagged, so it is a filter, not
/// a new screen.
const Set<String> kPregnancyYogaCategories = {
  'prenatal',
  'breathing',
  'meditation',
  'yoga',
};

class _YogaHomeScreenState extends State<YogaHomeScreen> {
  bool _live = true; // Live vs Recorded (top toggle)
  bool _group = true; // within Live: Group vs 1:1

  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';

  YogaMode get _mode => !_live
      ? YogaMode.recorded
      : (_group ? YogaMode.liveGroup : YogaMode.liveOneToOne);

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _open(YogaClass c) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => YogaClassScreen(cls: c)));

  /// Each category's drawn mark, by meaning.
  static IntentMark _catMark(String id) => switch (id) {
        'prenatal' => IntentMark.kickMark,
        'postnatal' => IntentMark.cuppedHands,
        'postivf' => IntentMark.improveMark,
        'breathing' => IntentMark.windMark,
        'meditation' => IntentMark.moonMark,
        'core' => IntentMark.spineMark,
        _ => IntentMark.lotusMark,
      };

  static double _catHue(String id) => switch (id) {
        'prenatal' => 330,
        'postnatal' => 20,
        'postivf' => 150,
        'breathing' => 200,
        'meditation' => 250,
        'core' => 40,
        _ => 280,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: YogaStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final searching = _query.trim().isNotEmpty;
        return PregToolScaffold(
          hue: 280,
          eyebrow: widget.eyebrow,
          mark: IntentMark.lotusMark,
          title: widget.heroTitle,
          intro: widget.intro,
          children: [
            pregToolPad(TextField(
              key: const ValueKey('yoga_search'),
              controller: _searchCtl,
              onChanged: (v) => setState(() => _query = v),
              style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
              decoration: InputDecoration(
                hintText: 'Search classes, teachers…',
                hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: p.ink3),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.ink1)),
              ),
            )),
            if (searching)
              ..._searchViewShell(p)
            else ...[
              const SizedBox(height: 14),
              // Live / Recorded, then (under Live) Group / 1:1. Same three modes.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(children: [
                  KeyedSubtree(
                    key: const ValueKey('yoga_mode_live'),
                    child: PvChip(label: 'Live', selected: _live, onTap: () => setState(() => _live = true)),
                  ),
                  const SizedBox(width: 8),
                  KeyedSubtree(
                    key: const ValueKey('yoga_mode_recorded'),
                    child:
                        PvChip(label: 'Recorded', selected: !_live, onTap: () => setState(() => _live = false)),
                  ),
                  if (_live) ...[
                    Container(
                        width: 1,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: p.line),
                    KeyedSubtree(
                      key: const ValueKey('yoga_mode_group'),
                      child: PvChip(label: 'Group', selected: _group, onTap: () => setState(() => _group = true)),
                    ),
                    const SizedBox(width: 8),
                    KeyedSubtree(
                      key: const ValueKey('yoga_mode_1to1'),
                      child: PvChip(label: '1:1', selected: !_group, onTap: () => setState(() => _group = false)),
                    ),
                  ],
                ]),
              ),
              ..._categoryRails(p),
              const SizedBox(height: 24),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _searchViewShell(V2Palette p) {
    final items = yogaSearch(_query).where((c) => _allowed(c.category)).toList();
    return [
      const SizedBox(height: 22),
      pregToolPad(ppCareHeading('Search results')),
      const SizedBox(height: 8),
      if (items.isEmpty)
        pregToolPad(Text('No classes match "${_query.trim()}". Try a stage or a teacher.',
            style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
      else
        pregToolPad(PvRowGroup(p: p, children: [
          for (final c in items)
            _ClassRow(
              key: ValueKey('yoga_row_${c.id}'),
              p: p,
              cls: c,
              hue: _catHue(c.category),
              mark: _catMark(c.category),
              onTap: () => _open(c),
            ),
        ])),
    ];
  }

  List<Widget> _categoryRails(V2Palette p) {
    final cats = yogaCategoriesWithClasses(_mode).where((c) => _allowed(c.id)).toList();
    final store = YogaStore.instance;
    if (cats.isEmpty) {
      return [
        const SizedBox(height: 24),
        pregToolPad(Text(
            _live
                ? 'No ${_group ? 'group' : '1:1'} classes here yet. Try ${_group ? '1:1' : 'Group'}, or Recorded.'
                : 'No recorded classes here yet. Try Live.',
            style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2))),
      ];
    }
    final scale = MediaQuery.textScalerOf(context);
    return [
      for (final cat in cats) ...[
        const SizedBox(height: 26),
        pregToolPad(ppCareHeading(cat.title)),
        const SizedBox(height: 4),
        pregToolPad(Text(cat.subtitle, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2))),
        const SizedBox(height: 12),
        SizedBox(
          height: _ClassCard.railHeight(scale),
          child: ListView.separated(
            key: ValueKey('yoga_rail_${cat.id}'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: yogaClassesIn(cat.id, _mode).length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final c = yogaClassesIn(cat.id, _mode)[i];
              return _ClassCard(
                key: ValueKey('yoga_card_${c.id}'),
                p: p,
                cls: c,
                hue: _catHue(cat.id),
                mark: _catMark(cat.id),
                saved: store.isSaved(c.id),
                onSave: () => store.toggleSave(c.id),
                onTap: () => _open(c),
              );
            },
          ),
        ),
      ],
    ];
  }

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: YogaStore.instance,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 40),
                children: [
                  _pad(ppBack(context, widget.backLabel)),
                  const SizedBox(height: 18),
                  _pad(ppEyebrow(widget.eyebrow, color: ppPurple)),
                  const SizedBox(height: 8),
                  _pad(Text(widget.heroTitle, style: ppFraunces(30, h: 1.1))),
                  const SizedBox(height: 6),
                  _pad(Text(widget.intro, style: ppBody(14, h: 1.5))),

                  const SizedBox(height: 16),
                  _pad(ppSearchField(
                    controller: _searchCtl,
                    hint: 'Search classes, teachers…',
                    onChanged: (v) => setState(() => _query = v),
                  )),

                  if (_query.trim().isNotEmpty)
                    ..._searchView()
                  else ...[
                    const SizedBox(height: 18),
                    _pad(_liveRecordedToggle()),
                    if (_live) ...[
                      const SizedBox(height: 12),
                      _pad(_groupOneToOneToggle()),
                    ],
                    const SizedBox(height: 8),
                    ..._categorySections(),
                  ],
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  // ---- search results (mode-agnostic) -------------------------------------
  List<Widget> _searchView() {
    final items =
        yogaSearch(_query).where((c) => _allowed(c.category)).toList();
    return [
      const SizedBox(height: 26),
      _pad(Text('Search results', style: ppJakarta(18))),
      const SizedBox(height: 14),
      if (items.isEmpty)
        _pad(Text('No classes match "${_query.trim()}" - try a stage or a teacher.',
            style: ppBody(13, color: ppMuted)))
      else
        _pad(Column(children: [
          for (final c in items) YogaListCard(cls: c, onTap: () => _open(c)),
        ])),
    ];
  }

  // ---- cult.fit-style category sections -----------------------------------
  // Honour the stage filter: on the pregnancy side only pregnancy-relevant
  // categories are shown; parenting (no filter) shows all, unchanged.
  bool _allowed(String catId) =>
      widget.categoryFilter == null || widget.categoryFilter!.contains(catId);

  List<Widget> _categorySections() {
    final cats =
        yogaCategoriesWithClasses(_mode).where((c) => _allowed(c.id)).toList();
    final store = YogaStore.instance;
    if (cats.isEmpty) {
      return [
        const SizedBox(height: 40),
        _pad(Text('No classes here yet - check another mode.', style: ppBody(13, color: ppMuted))),
      ];
    }
    final out = <Widget>[];
    for (final cat in cats) {
      final classes = yogaClassesIn(cat.id, _mode);
      out.addAll([
        const SizedBox(height: 26),
        _pad(yogaSectionHeader(cat)),
        const SizedBox(height: 14),
        SizedBox(
          height: 268,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: classes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final c = classes[i];
              return YogaBigCard(
                cls: c,
                onTap: () => _open(c),
                saved: store.isSaved(c.id),
                onSave: () => store.toggleSave(c.id),
              );
            },
          ),
        ),
      ]);
    }
    return out;
  }

  // ---- toggles ------------------------------------------------------------
  // The two mode toggles. REBUILT 21 Jul: was two stacked rows of TWO-LINE
  // segments (label + caption) whose highlight cross-faded in place — tall, and
  // the selection did not visibly move. Now each is a single-line sliding
  // segmented control: half the height (the captions moved into the intro copy
  // above), and one white pill that GLIDES left/right on tap. Same two choices,
  // far less vertical space, and a transition you can follow.
  Widget _liveRecordedToggle() => _slideToggle(
        left: 'Live',
        right: 'Recorded',
        leftOn: _live,
        onLeft: () => setState(() => _live = true),
        onRight: () => setState(() => _live = false),
      );

  Widget _groupOneToOneToggle() => _slideToggle(
        left: 'Group',
        right: '1:1',
        leftOn: _group,
        onLeft: () => setState(() => _group = true),
        onRight: () => setState(() => _group = false),
      );

  /// A two-option pill toggle whose white highlight slides between the halves.
  Widget _slideToggle({
    required String left,
    required String right,
    required bool leftOn,
    required VoidCallback onLeft,
    required VoidCallback onRight,
  }) =>
      Container(
        height: 42,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Stack(children: [
          // The gliding highlight — half-width, animated to the chosen side.
          AnimatedAlign(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: leftOn ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(color: Color(0x146A30B6), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
              ),
            ),
          ),
          Row(children: [
            _segLabel(left, leftOn, onLeft),
            _segLabel(right, !leftOn, onRight),
          ]),
        ]),
      );

  Widget _segLabel(String label, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              style: ppBody(13, color: on ? ppPurple : ppSoft, w: FontWeight.w700),
              child: Text(label),
            ),
          ),
        ),
      );
}

// =============================================================================
//  The class card and row on the shared look (2026-10-07)
// =============================================================================

/// The meta line under a class: "45 min · Teacher", the teacher's NAME
/// tappable (it opens her profile, as on the old cards).
Widget _classMeta(V2Palette p, YogaClass cls) => yogaInstructorLine(cls,
    prefix: '${cls.durationLabel} · ',
    style: pvManrope(fontSize: 12, height: 1.3, fontWeight: FontWeight.w600, color: p.ink2));

/// A drawn picture: the category's mark on its own soft tint, as the doors'
/// shelf cards draw one (no photo exists for a class yet).
Widget _classPicture(double hue, IntentMark mark) => ColoredBox(
      color: HSLColor.fromAHSL(1, hue % 360, 0.52, 0.9).toColor(),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          heightFactor: 0.5,
          child: HubIntentArt(mark: mark, tint: HSLColor.fromAHSL(1, hue % 360, 0.6, 0.8).toColor()),
        ),
      ),
    );

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    super.key,
    required this.p,
    required this.cls,
    required this.hue,
    required this.mark,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  final V2Palette p;
  final YogaClass cls;
  final double hue;
  final IntentMark mark;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onTap;

  static const double width = 168;
  static const double pictureHeight = 128;

  /// Tall enough for the picture, two title lines and the meta line at any
  /// text scale, so a rail never clips its last line.
  static double railHeight(TextScaler s) =>
      (pictureHeight + 8 + s.scale(14) * 1.25 * 2 + 4 + s.scale(12) * 1.3 + 6).ceilToDouble();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: width,
            height: pictureHeight,
            child: Stack(fit: StackFit.expand, children: [
              PvPress(
                child: InkWell(onTap: onTap, child: _classPicture(hue, mark)),
              ),
              if (cls.mode == YogaMode.recorded)
                const IgnorePointer(
                  child: Center(child: Icon(Icons.play_circle_outline_rounded, size: 34, color: Colors.white)),
                ),
              // What kind of class, top left: one white pill, ink words.
              Positioned(
                left: 7,
                top: 7,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration:
                        BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: Text(cls.modeLabel,
                        textScaler: TextScaler.noScaling,
                        style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, color: p.ink1)),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Semantics(
                  button: true,
                  label: saved ? 'Remove from saved' : 'Save class',
                  child: InkWell(
                    key: ValueKey('yoga_save_${cls.id}'),
                    onTap: onSave,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 16, color: p.ink1),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(cls.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
        ),
        const SizedBox(height: 4),
        _classMeta(p, cls),
      ]),
    );
  }
}

/// A class as a list row (search results): the mark, the title, the mode, and
/// "45 min · Teacher" with the teacher's name tappable.
class _ClassRow extends StatelessWidget {
  const _ClassRow({
    super.key,
    required this.p,
    required this.cls,
    required this.hue,
    required this.mark,
    required this.onTap,
  });

  final V2Palette p;
  final YogaClass cls;
  final double hue;
  final IntentMark mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              PvMarkWell(p: p, hue: hue, size: 40, mark: mark),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(cls.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
                  const SizedBox(height: 3),
                  _classMeta(p, cls),
                  const SizedBox(height: 3),
                  Text('${cls.modeLabel} · ${cls.categoryInfo.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 11, fontWeight: FontWeight.w600, color: p.ink3)),
                ]),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ]),
          ),
        ),
      );
}

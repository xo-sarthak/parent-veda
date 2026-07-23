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
// =============================================================================

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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

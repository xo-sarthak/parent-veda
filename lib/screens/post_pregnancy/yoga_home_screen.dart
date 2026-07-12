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
  const YogaHomeScreen({super.key});

  @override
  State<YogaHomeScreen> createState() => _YogaHomeScreenState();
}

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
                  _pad(ppBack(context, 'Explore')),
                  const SizedBox(height: 18),
                  _pad(ppEyebrow('ParentVeda Yoga', color: ppPurple)),
                  const SizedBox(height: 8),
                  _pad(Text('Yoga & parenting classes', style: ppFraunces(30, h: 1.1))),
                  const SizedBox(height: 6),
                  _pad(Text('Expert-led classes for every stage - pregnancy, recovery, IVF, breath and calm. Live with a teacher, or on your own time.',
                      style: ppBody(14, h: 1.5))),

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
        const PpAskVedaFab(),
      ]),
    );
  }

  // ---- search results (mode-agnostic) -------------------------------------
  List<Widget> _searchView() {
    final items = yogaSearch(_query);
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
  List<Widget> _categorySections() {
    final cats = yogaCategoriesWithClasses(_mode);
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
  Widget _liveRecordedToggle() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          _seg('Live', 'with a teacher', _live, () => setState(() => _live = true)),
          _seg('Recorded', 'on your own time', !_live, () => setState(() => _live = false)),
        ]),
      );

  Widget _groupOneToOneToggle() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          _seg('Group', 'join a class', _group, () => setState(() => _group = true)),
          _seg('1:1', 'private session', !_group, () => setState(() => _group = false)),
        ]),
      );

  Widget _seg(String label, String sub, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: on ? const [BoxShadow(color: Color(0x146A30B6), blurRadius: 10, offset: Offset(0, 3))] : null,
            ),
            child: Column(children: [
              Text(label, style: ppBody(13, color: on ? ppPurple : ppSoft, w: FontWeight.w700)),
              const SizedBox(height: 1),
              Text(sub, style: ppBody(10, color: ppMuted)),
            ]),
          ),
        ),
      );
}

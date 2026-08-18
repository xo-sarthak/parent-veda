// =============================================================================
//  Mind & Mood - home shell (four tabs)
// -----------------------------------------------------------------------------
//  The most emotionally sensitive section in the app. This file only owns the
//  shell: header, the four-tab pill row, and which tab is showing. Every tab
//  is its own file (mm_feel_tab.dart / mm_understand_tab.dart /
//  mm_track_tab.dart / mm_talk_tab.dart), and the crisis path
//  (mm_crisis_path.dart) is reachable from inside every one of them - never
//  rebuilt here, never gated behind this shell.
//
//  ⚠️ INTEGRATOR NOTE: call `mindMoodHomeScreen(controller: controller)` from
//  wherever this section is opened (the Tools hub is the obvious home, next
//  to the other `PregnancyController`-scoped tools - see
//  `lib/screens/tools_hub_screen.dart` for the existing
//  `() => open(() => XScreen(controller: controller))` pattern). This file
//  does not add that entry itself - CLAUDE.md scopes this build to the files
//  under `lib/screens/mind_mood/` and `lib/data/mind_mood_data.dart` only.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/mind_mood_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'mm_feel_tab.dart';
import 'mm_talk_tab.dart';
import 'mm_track_tab.dart';
import 'mm_understand_tab.dart';

/// The integrator's entry point. A thin factory rather than exposing the
/// widget class directly, so the call site reads as an action
/// ("open Mind & Mood") rather than a type.
Widget mindMoodHomeScreen({required PregnancyController controller}) =>
    MindMoodHomeScreen(controller: controller);

enum _MmTab { feel, understand, track, talk }

extension on _MmTab {
  String get label => switch (this) {
        _MmTab.feel => 'Feel',
        _MmTab.understand => 'Understand',
        _MmTab.track => 'Track',
        _MmTab.talk => 'Talk',
      };

  IconData get icon => switch (this) {
        _MmTab.feel => Icons.self_improvement_rounded,
        _MmTab.understand => Icons.menu_book_outlined,
        _MmTab.track => Icons.timeline_rounded,
        _MmTab.talk => Icons.chat_bubble_outline_rounded,
      };
}

class MindMoodHomeScreen extends StatefulWidget {
  const MindMoodHomeScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<MindMoodHomeScreen> createState() => _MindMoodHomeScreenState();
}

class _MindMoodHomeScreenState extends State<MindMoodHomeScreen> {
  _MmTab _tab = _MmTab.feel;

  @override
  void initState() {
    super.initState();
    // Local-first: the store loads its cache in the background. Nothing on
    // this screen blocks on it - Feel and Understand render immediately, and
    // Track's mood/journal lists simply fill in once loaded.
    MindMoodStore.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 20, 0),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.arrow_back_rounded, color: p.ink2),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mind & Mood',
                        style: pvFraunces(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                            color: p.ink1)),
                    Text('A calm place for how you are actually feeling.',
                        style: pvManrope(fontSize: 11.5, color: p.ink3)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                for (final t in _MmTab.values) ...[
                  Expanded(child: _TabPill(
                    tab: t,
                    selected: t == _tab,
                    p: p,
                    onTap: () => setState(() => _tab = t),
                  )),
                  if (t != _MmTab.values.last) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: _tab.index,
              children: [
                const MmFeelTab(),
                const MmUnderstandTab(),
                const MmTrackTab(),
                MmTalkTab(controller: widget.controller),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill(
      {required this.tab, required this.selected, required this.p, required this.onTap});
  final _MmTab tab;
  final bool selected;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? p.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? p.ink1.withValues(alpha: 0.18) : p.line),
          ),
          child: Column(children: [
            Icon(tab.icon, size: 17, color: selected ? p.ink1 : p.ink3),
            const SizedBox(height: 3),
            Text(tab.label,
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? p.ink1 : p.ink3)),
          ]),
        ),
      ),
    );
  }
}

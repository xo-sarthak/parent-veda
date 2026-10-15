// =============================================================================
//  Baby Naming Journey (V2) - Shortlist -> Compare -> Chosen -> Story
// -----------------------------------------------------------------------------
//  The closing arc of the journey:
//   • NameJourneyShortlistScreen - "Names We Both Love" (auto from matches).
//   • NameCompareScreen - a calm side-by-side (meaning, origin, say-it, length,
//     popularity, feel, numerology, nakshatra). We help parents SEE the
//     differences; we never recommend one.
//   • NameChosenScreen - "You've chosen Aarav" -> "A beautiful name deserves a
//     beautiful story" -> Begin the story, which opens the Journal to write
//     "The Story Behind My Name" as Chapter One.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_chrome.dart' show PregNote;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit, kPvInk, pvStorePalette;
import '../v2/v2_palette.dart';
import 'journal_v2/journal_capture_screens.dart';
import 'name_journey_detail_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';
import 'pp_names_v2_data.dart';
import '../../widgets/pv_feedback.dart' show PvPress;

class NameJourneyShortlistScreen extends StatelessWidget {
  const NameJourneyShortlistScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  The naming tool's shell (the front door, BabyNamingHomeScreen, wears it):
  //  the field, the round back, the serif title, then the names as unboxed rows
  //  and one ink button to compare. The journey ribbon stays in the page
  //  before, `_buildBeforeShell`, kept for revert.
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return AnimatedBuilder(
      animation: NameMatchStore.instance,
      builder: (context, _) {
        final store = NameMatchStore.instance;
        final names = store.liked.map(babyNameByName).toList();
        return PregToolScaffold(
          hue: 268,
          eyebrow: 'Names you love',
          title: 'Your shortlist',
          intro: 'Every name you swiped right on gathers here - no manual saving. Compare them, then choose.',
          children: [
            if (names.isEmpty)
              pregToolPad(Column(
                key: const ValueKey('pp_shortlist_empty'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nothing here yet', style: pvManrope(fontSize: 16, fontWeight: FontWeight.w700, color: p.ink1)),
                  const SizedBox(height: 6),
                  Text('Head back and swipe a few names you love - the ones you like will appear here.',
                      style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                ],
              ))
            else ...[
              pregToolPad(PvRowGroup(p: p, children: [
                for (final n in names)
                  PvListRow(
                    key: ValueKey('pp_shortlist_row_${n.name}'),
                    p: p,
                    leading: nameLetterWell(p, n),
                    title: n.name,
                    line: n.meaningShort,
                    meta: n.script,
                    onTap: () => _push(context, NameJourneyDetailScreen(name: n.name)),
                    // The crowned name keeps its star, in ink.
                    trailing: n.name == store.crowned
                        ? Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.star_rounded, size: 16, color: kPvInk, semanticLabel: 'Your chosen name'),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
                          ])
                        : null,
                  ),
              ])),
              if (names.length >= 2) ...[
                const SizedBox(height: 22),
                pregToolPad(PvCommit(
                  key: const ValueKey('pp_shortlist_compare'),
                  label: 'Compare these names',
                  icon: Icons.compare_arrows_rounded,
                  onTap: () => _push(context, const NameCompareScreen()),
                )),
              ],
            ],
          ],
        );
      },
    );
  }

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: NameMatchStore.instance,
          builder: (context, _) {
            final store = NameMatchStore.instance;
            final names = store.liked.map(babyNameByName).toList();
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Baby Names')),
                const SizedBox(height: 14),
                nameJourneyRibbon(active: 3),
                const SizedBox(height: 22),
                _pad(ppEyebrow('Names you love', color: ppPurple)),
                const SizedBox(height: 10),
                _pad(Text('Your shortlist', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('Every name you swiped right on gathers here - no manual saving. Compare them, then choose.', style: ppBody(14, h: 1.55))),

                const SizedBox(height: 22),
                if (names.isEmpty)
                  _pad(_empty())
                else ...[
                  _pad(Column(children: [for (final n in names) _nameRow(context, n, crowned: n.name == store.crowned)])),
                  const SizedBox(height: 18),
                  if (names.length >= 2)
                    _pad(PvPress(child: GestureDetector(
                      onTap: () => _push(context, const NameCompareScreen()),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: ppInk, borderRadius: BorderRadius.circular(15)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.compare_arrows_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Compare these names', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                        ]),
                      ),
                    ))),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _empty() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          const Icon(Icons.favorite_border, size: 28, color: ppPurple),
          const SizedBox(height: 12),
          Text('Nothing here yet', style: ppJakarta(16)),
          const SizedBox(height: 6),
          Text('Head back and swipe a few names you love - the ones you like will appear here.', textAlign: TextAlign.center, style: ppBody(13, h: 1.5)),
        ]),
      );

  Widget _nameRow(BuildContext context, BabyName n, {required bool crowned}) => PvPress(child: GestureDetector(
        onTap: () => _push(context, NameJourneyDetailScreen(name: n.name)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: crowned ? ppPurple : ppHair, width: crowned ? 1.5 : 1),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(n.name, style: ppFraunces(22, h: 1.05)),
                  const SizedBox(width: 8),
                  Text(n.script, style: ppFraunces(16, color: ppPurple)),
                  if (crowned) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, size: 16, color: ppCoral),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(n.meaningShort, style: ppBody(13, h: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      ));
}

/// A name row's well: its first letter in the naming tool's tint (hue 268, the
/// front door's), a contact list's well rather than one icon repeated on every
/// row. Shared by the shortlist and the browse list (2026-10-07).
Widget nameLetterWell(V2Palette p, BabyName n) => Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: v2BlockTint(268, p), borderRadius: BorderRadius.circular(12)),
      child: ExcludeSemantics(
        child: Text(n.name.isEmpty ? '' : n.name.characters.first.toUpperCase(),
            textScaler: TextScaler.noScaling,
            style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
      ),
    );

// =============================================================================
//  NameCompareScreen - a calm side-by-side (never a recommendation)
// =============================================================================
class NameCompareScreen extends StatelessWidget {
  const NameCompareScreen({super.key});

  static const double _labelW = 92;
  static const double _colW = 150;
  static const double _rowH = 74;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  The naming tool's shell; the decision note as a quiet line, not a lilac
  //  block; the table on white with the page hairline. Rows grow with the text
  //  size so three lines of meaning never spill. `_buildBeforeShell` is the
  //  page before, kept for revert.
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final names = NameMatchStore.instance.liked.map(babyNameByName).take(6).toList();
    final scaler = MediaQuery.textScalerOf(context);
    final rowH = (scaler.scale(12) * 1.35 * 3 + 20).clamp(_rowH, 160.0);
    final headH = (scaler.scale(20) * 1.1 + 18).clamp(44.0, 80.0);
    return PregToolScaffold(
      hue: 268,
      variant: 3,
      eyebrow: 'Compare',
      title: 'See them side by side',
      children: [
        pregToolPad(PregNote(decisionCompare(names), icon: Icons.auto_awesome_outlined)),
        const SizedBox(height: 20),
        if (names.length < 2)
          pregToolPad(Text('Add at least two names to your shortlist to compare them.',
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
        else
          pregToolPad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: headH),
              for (final d in _dims)
                SizedBox(
                  width: _labelW,
                  height: rowH,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(d.$1.toUpperCase(),
                        maxLines: 2,
                        style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: p.ink3)),
                  ),
                ),
            ]),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final n in names)
                    Container(
                      width: _colW,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: p.line),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(
                          height: headH,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(n.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
                            ),
                          ),
                        ),
                        for (final d in _dims)
                          Container(
                            width: _colW,
                            height: rowH,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(border: Border(top: BorderSide(color: p.line))),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(d.$2(n),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: pvManrope(fontSize: 12, height: 1.35, color: p.ink1)),
                            ),
                          ),
                      ]),
                    ),
                ]),
              ),
            ),
          ])),
      ],
    );
  }

  static final List<(String, String Function(BabyName))> _dims = [
    ('Meaning', (n) => n.meaningShort),
    ('Origin', (n) => n.origin),
    ('Say it', (n) => n.pron),
    ('Length', (n) => '${n.syllables} syllables'),
    ('Popularity', (n) => n.popularity),
    ('Feel', (n) => n.feel),
    ('Numerology', (n) => '${n.numerology}'),
    ('Nakshatra', (n) => n.nakshatra),
  ];

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    final names = NameMatchStore.instance.liked.map(babyNameByName).take(6).toList();
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Shortlist')),
            const SizedBox(height: 14),
            nameJourneyRibbon(active: 4),
            const SizedBox(height: 22),
            _pad(ppEyebrow('Compare', color: ppPurple)),
            const SizedBox(height: 10),
            _pad(Text('See them side by side', style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 8),
            _pad(Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(15)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.auto_awesome, size: 15, color: ppPurple),
                const SizedBox(width: 10),
                Expanded(child: Text(decisionCompare(names), style: ppBody(12.5, h: 1.5))),
              ]),
            )),
            const SizedBox(height: 20),
            if (names.length < 2)
              _pad(Text('Add at least two names to your shortlist to compare them.', style: ppBody(13, color: ppMuted)))
            else
              _table(names),
          ],
        ),
      ),
    );
  }

  Widget _table(List<BabyName> names) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // fixed dimension labels
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 44), // aligns with the name header row
            for (final d in _dims)
              SizedBox(
                width: _labelW,
                height: _rowH,
                child: Align(alignment: Alignment.centerLeft, child: Text(d.$1.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.5))),
              ),
          ]),
          // scrollable name columns
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final n in names)
                  Container(
                    width: _colW,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                        height: 44,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(alignment: Alignment.centerLeft, child: Text(n.name, style: ppFraunces(20, h: 1.0), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ),
                      ),
                      for (final d in _dims)
                        Container(
                          width: _colW,
                          height: _rowH,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(d.$2(n), style: ppBody(12, color: ppInk, h: 1.35), maxLines: 3, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                    ]),
                  ),
              ]),
            ),
          ),
        ]),
      );
}

// =============================================================================
//  NameChosenScreen - the final selection, flowing into the Journal
// =============================================================================
class NameChosenScreen extends StatelessWidget {
  const NameChosenScreen({super.key, required this.name});
  final String name;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  The naming tool's shell with the name as the page title; the invitation
  //  to write its story on a white card with the hairline and one ink button.
  //  `_buildBeforeShell` is the page before, kept for revert.
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final n = babyNameByName(name);
    return PregToolScaffold(
      hue: 268,
      variant: 4,
      eyebrow: "You've chosen",
      title: n.name,
      intro: '“${n.meaningFull}”',
      children: [
        pregToolPad(Text(n.script, style: pvFraunces(fontSize: 26, fontWeight: FontWeight.w600, color: p.ink3))),
        const SizedBox(height: 20),
        pregToolPad(Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('A beautiful name deserves a beautiful story.',
                style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3, color: p.ink1)),
            const SizedBox(height: 8),
            Text('Write why you chose ${n.name} - what it means to your family, who suggested it, the memory behind it. It becomes Chapter One of ${n.name}\'s journal.',
                style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
            const SizedBox(height: 16),
            PvCommit(
              key: const ValueKey('pp_name_chosen_story'),
              label: "Begin ${n.name}'s story",
              icon: Icons.edit_note_rounded,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WriteStoryScreen())),
            ),
          ]),
        )),
        const SizedBox(height: 16),
        pregToolPad(PregNote(
          '${n.name} will gently flow through ParentVeda - Child Profile, Journal, Storybook and Namkaran - so you never enter it again.',
          icon: Icons.check_circle_outline_rounded,
        )),
      ],
    );
  }

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    final n = babyNameByName(name);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Back')),
            const SizedBox(height: 14),
            nameJourneyRibbon(active: 5),
            const SizedBox(height: 30),
            _pad(Center(child: Column(children: [
              const Icon(Icons.favorite, size: 30, color: ppCoral),
              const SizedBox(height: 16),
              Text("You've chosen", style: ppBody(14, color: ppSoft, w: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(n.name, textAlign: TextAlign.center, style: ppFraunces(52, h: 1.0)),
              const SizedBox(height: 4),
              Text(n.script, style: ppFraunces(26, color: ppPurple)),
              const SizedBox(height: 12),
              Text('“${n.meaningFull}”', textAlign: TextAlign.center, style: ppFraunces(17, h: 1.45)),
            ]))),

            const SizedBox(height: 30),
            _pad(Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFE6D8F1)]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('A beautiful name deserves a beautiful story.', style: ppFraunces(20, h: 1.3)),
                const SizedBox(height: 8),
                Text('Write why you chose ${n.name} - what it means to your family, who suggested it, the memory behind it. It becomes Chapter One of ${n.name}\'s journal.', style: ppBody(13.5, h: 1.6)),
                const SizedBox(height: 18),
                PvPress(child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WriteStoryScreen())),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.edit_note_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Flexible(child: Text("Begin ${n.name}'s story", maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(14, color: Colors.white, w: FontWeight.w700))),
                    ]),
                  ),
                )),
              ]),
            )),

            const SizedBox(height: 16),
            _pad(Row(children: [
              const Icon(Icons.check_circle_outline_rounded, size: 16, color: ppPurple),
              const SizedBox(width: 10),
              Expanded(child: Text('${n.name} will gently flow through ParentVeda - Child Profile, Journal, Storybook and Namkaran - so you never enter it again.', style: ppBody(12.5, color: ppSoft, h: 1.5))),
            ])),
          ],
        ),
      ),
    );
  }
}

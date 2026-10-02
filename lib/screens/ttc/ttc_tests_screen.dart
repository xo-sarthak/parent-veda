// =============================================================================
//  TTC - the medical test library
// -----------------------------------------------------------------------------
//  Answers the question a couple actually has standing in a diagnostic centre:
//  is this test worth doing, what will it tell us, and what do we do with the
//  number that comes back?
//
//  His tests are listed BESIDE hers rather than in a footnote. That ordering is
//  the point of the screen: a male factor is involved in roughly half of
//  couples who struggle, and in most Indian clinics the woman is investigated
//  first through tests that are slower, costlier and more invasive.
//
//  Every entry carries WHEN in the cycle it must be taken, because getting that
//  wrong is the most common reason a fertility test has to be repeated - and a
//  repeated test is a wasted month as well as wasted money.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT AS A LIST AND A PAGE (tool rebuild, 2026-09-27, night)
//  ---------------------------------------------------------------------------
//  The user on build 13: "old tools in new clothes". Inside the new shell this
//  was still the V1 page: shadowed `TtcCard`s, a price, a brown "when" line and
//  a violet "Read more" on every card, and the detail grew the card in place
//  so the list jumped. Now, the way the look-up apps do it (Yuka "Additives",
//  https://mobbin.com/screens/5e756797-34ea-465d-814c-c139ce62a34f; Superpower
//  "Vitamin D", https://mobbin.com/screens/c5491ab9-d410-4863-a6ae-23c8601eb021;
//  DoorDash help search, https://mobbin.com/screens/a768d9ac-8235-4bd8-89b6-81eb2a7bc677):
//
//    · A search field first, because the commonest way in is a list from her
//      doctor ("AMH, TSH, prolactin"). It reads name, what and why, in both
//      languages, and searches her tests and his together.
//    · Her tests under three plain headings in the order people meet them;
//      his under his own, with his next step (the semen report reader) as a
//      row, not a footnote card.
//    · Each row: the name, what it checks, and WHEN, with a clock. The when
//      stays on the row because it is the fact that costs a month.
//    · A tap opens the test in the one reader (`openTtcTestRead`): when, why,
//      what the result means, "Add my result" right there, the cost, then the
//      next tests. The price left the list: it read like a shop.
//    · At the foot: her saved results, and Ask Veda when a name is not here.
//  Stored keys: none; the library is read-only and "Add my result" writes
//  through Records exactly as before.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_lookup_reads.dart' show openTtcTestRead;
import '../../ttc/ttc_tests_data.dart';
import '../doors/pv_list_row.dart' show PvRowGroup;
import '../v2/v2_palette.dart';
import 'ttc_askveda_screen.dart' show openTtcAskVeda;
import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
import 'ttc_lookup_parts.dart';
import 'ttc_records_screen.dart' show openTtcRecords;
import 'ttc_semen_report_screen.dart' show openTtcSemenReport;
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';

/// Her tests in the order people usually meet them (tools pass, 2026-09-27):
/// the everyday blood tests a first visit orders, then the hormone tests and
/// the scan, and the tube test last because it comes later, if at all. Only
/// the ORDER on this screen; the data file keeps its own order. An id not in
/// this list keeps its place after these.
const List<String> kTtcTestsHerOrder = [
  'tsh', 'vitd', 'b12', 'hba1c', 'prolactin',
  'fsh_lh', 'amh', 'ultrasound', 'hsg',
];

/// The headings her list sits under, in [kTtcTestsHerOrder]'s order
/// (2026-09-27, night). Plain names for kinds of test, not a claim about
/// which ones she needs. An id missing here falls under the first heading, so
/// a new test is never dropped from the page.
const List<(String, List<String>)> kTtcTestsHerGroups = [
  ('Everyday blood tests', ['tsh', 'vitd', 'b12', 'hba1c', 'prolactin']),
  ('Hormones and the scan', ['fsh_lh', 'amh', 'ultrasound']),
  ('The tube test', ['hsg']),
];

String ttcTestGroupOf(String id) {
  for (final (name, ids) in kTtcTestsHerGroups) {
    if (ids.contains(id)) return name;
  }
  return kTtcTestsHerGroups.first.$1;
}

List<TtcTest> ttcTestsInOrder({required bool him}) {
  final list = ttcTestsFor(him: him);
  if (him) return list;
  // Named `placeOf`, not "rank": that word is an identity-bearing call to
  // test/localized_identity_test.dart's scanner, which read a record field
  // passed to it as an interpolated key.
  int placeOf(TtcTest t) {
    final i = kTtcTestsHerOrder.indexOf(t.id);
    return i < 0 ? kTtcTestsHerOrder.length : i;
  }

  final indexed = [for (var i = 0; i < list.length; i++) (i, list[i])];
  indexed.sort((a, b) {
    final r = placeOf(a.$2).compareTo(placeOf(b.$2));
    return r != 0 ? r : a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
}

/// Search over a test's name, what it checks and why, in both languages.
bool ttcTestMatches(TtcTest t, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return [
    t.name,
    t.whatEn,
    t.whatHi,
    t.whyEn,
    t.whyHi,
  ].any((s) => s.toLowerCase().contains(q));
}

/// ⚠️ THE ROW SAYS WHEN IN FOUR WORDS, THE PAGE SAYS IT IN FULL (2026-10-01,
/// the user: the list "looks so cluttered and text heavy"). Each row used to
/// carry the whole "what it checks" sentence AND the whole "when to have it"
/// sentence under the name, two to four lines a test. The WHEN is the fact that
/// costs a month if it is wrong, so it stays on the row, short and strong with
/// its clock; the full sentence, with its reason, is the first thing on the
/// test's own page. Mobbin pass: Lloyds' toolkit (a bold title over one grey
/// line in one grouped card), Lifesum's insight rows (a name, one word of
/// state), MacroFactor's food rows (a name and one short fact).
const Map<String, String> kTtcTestWhenShort = {
  'tsh': 'Any day',
  'amh': 'Any day',
  'fsh_lh': 'Day 2 or 3 of your cycle',
  'semen': 'After 2 to 5 days without ejaculating',
  'vitd': 'Any day',
  'b12': 'Any day',
  'hba1c': 'Any day',
  'ultrasound': 'Early in your cycle',
  'hsg': 'After your period, before ovulation',
  'prolactin': 'In the morning',
};

/// The short "when" for a row: the label above, or the test's first sentence
/// (cut at a full stop) for a test added later without one.
String ttcTestWhenShort(TtcTest test, bool hi) {
  if (!hi) {
    final short = kTtcTestWhenShort[test.id];
    if (short != null) return short;
  }
  final full = test.when(hi).trim();
  final m = RegExp(r'^(.+?[.!?])(\s|$)').firstMatch(full);
  return m?.group(1) ?? full;
}

class TtcTestsScreen extends StatefulWidget {
  const TtcTestsScreen({super.key, this.focusId});

  /// A test to open on, from an Ask Veda pointer (`ttctest_amh` → `amh`).
  /// The library renders whole underneath, and the test opens on top of it,
  /// so Back lands on the full list rather than a list narrowed to one.
  final String? focusId;

  @override
  State<TtcTestsScreen> createState() => _TtcTestsScreenState();
}

class _TtcTestsScreenState extends State<TtcTestsScreen> {
  bool _him = false;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    final focus = widget.focusId;
    if (focus == null) return;
    final test = ttcTestById(focus);
    // An unknown id degrades to the plain library.
    if (test == null) return;
    // A pointer at one of HIS tests flips the switch, so Back lands on the
    // list the test belongs to.
    _him = test.forHim;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) openTtcTestRead(context, test);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final p = V2PaletteStore.instance.current;
        final q = _search.text.trim();

        Widget row(TtcTest test, {bool sayWhose = false}) => TtcLookupRow(
              key: ValueKey('ttc_test_row_${test.id}'),
              title: test.name,
              onTap: () => openTtcTestRead(context, test),
              lines: [
                // One line of what it checks, not two (the full sentence is on
                // the test's page). Kept for revert: `maxLines: 2` default.
                ttcLookupLine(test.what(hi), maxLines: 1),
                // The WHEN, short, with its clock. Kept for revert:
                // `ttcLookupLine(test.when(hi), icon: schedule, strong: true)`,
                // the whole sentence.
                ttcLookupLine(ttcTestWhenShort(test, hi),
                    maxLines: 1, icon: Icons.schedule_rounded, strong: true),
                if (sayWhose && test.forHim)
                  ttcLookupLine(t.testForHim, maxLines: 1),
              ],
            );

        final children = <Widget>[];
        if (q.isNotEmpty) {
          // Her tests and his together: a name on the doctor's list is a
          // name, whoever it is for.
          final hits = [
            ...ttcTestsInOrder(him: false),
            ...ttcTestsInOrder(him: true),
          ].where((x) => ttcTestMatches(x, q)).toList();
          if (hits.isEmpty) {
            children.addAll([
              const SizedBox(height: 18),
              // Kept for revert (2026-09-28): 'No test called "$q" here yet.'
              Text('No test called "$q" in this list yet.',
                  style: ttcLookupTitle(p)),
              const SizedBox(height: 6),
              Text(
                  'Ask Veda can explain it. Your doctor or the lab can tell '
                  'you why it was asked for.',
                  style: ttcLookupBody(p)),
              const SizedBox(height: 8),
              PvRowGroup(p: p, children: [
                TtcLookupActionRow(
                  key: const ValueKey('ttc_tests_ask_veda'),
                  icon: Icons.auto_awesome_outlined,
                  label: 'Ask Veda: "$q"',
                  hue: kIvfHue,
                  onTap: () => openTtcAskVeda(context, initialQuery: q),
                ),
              ]),
            ]);
          } else {
            children.addAll([
              TtcLookupHeading(
                  hits.length == 1 ? '1 test' : '${hits.length} tests'),
              PvRowGroup(p: p, children: [
                for (final x in hits) row(x, sayWhose: true),
              ]),
            ]);
          }
        } else if (!_him) {
          final hers = ttcTestsInOrder(him: false);
          for (final (group, _) in kTtcTestsHerGroups) {
            final inGroup =
                hers.where((x) => ttcTestGroupOf(x.id) == group).toList();
            if (inGroup.isEmpty) continue;
            children.addAll([
              TtcLookupHeading(group),
              PvRowGroup(p: p, children: [for (final x in inGroup) row(x)]),
            ]);
          }
        } else {
          children.addAll([
            const TtcLookupHeading('His test'),
            PvRowGroup(p: p, children: [
              for (final x in ttcTestsInOrder(him: true)) row(x),
            ]),
            // ⚠️ HIS TAB HOLDS ONE TEST, SO IT SAYS WHERE THE REST IS
            // (tools pass, 2026-09-27). Now a row like every other way on.
            const TtcLookupHeading('Got his report?'),
            PvRowGroup(p: p, children: [
              TtcLookupActionRow(
                key: const ValueKey('ttc_tests_semen_reader'),
                icon: Icons.description_outlined,
                label: 'Read a semen analysis report',
                line: 'We go through it with you, line by line.',
                hue: kIvfHue,
                onTap: () => openTtcSemenReport(context),
              ),
            ]),
          ]);
        }

        return TtcToolScaffold(
          // Care and medicines' hue in Tools, the same as Medication.
          hue: kIvfHue,
          // The tool's mark over the eyebrow (2026-09-29, ttc_tool_marks.dart).
          toolId: 'tests',
          // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
          // tile's name, word for word ("Medical Tests" is the Hindi
          // build's tile); the title is the tile's own line.
          eyebrow: hi ? t.medicalTests : 'Medical tests',
          title: 'What each test tells you.',
          // What she can do here, in one line (2026-09-27, night). Kept for
          // revert: 'What each fertility test checks, when to have it and
          // roughly what it costs. If your doctor gave you a list, find each
          // name below and tap it to read more.'
          intro: hi
              ? t.testsIntro
              : 'What each fertility test checks and when to have it. '
                  "Search a name from your doctor's list, or tap a test to "
                  'read more and add your result.',
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                TtcLookupSearchField(
                  controller: _search,
                  hint: 'Search a test, like AMH or thyroid',
                  onChanged: (_) => setState(() {}),
                ),
                if (q.isEmpty) ...[
                  const SizedBox(height: 14),
                  // Two equal choices, not a tab and a footnote.
                  TtcLookupTwoWay(
                    left: t.testForHer,
                    right: t.testForHim,
                    rightOn: _him,
                    onPick: (him) => setState(() => _him = him),
                  ),
                ],
                ...children,

                // Where her own results live, one tap from the library.
                const TtcLookupHeading('Your results'),
                PvRowGroup(p: p, children: [
                  TtcLookupActionRow(
                    key: const ValueKey('ttc_tests_my_results'),
                    icon: Icons.folder_open_outlined,
                    label: 'See my results',
                    line: 'Every result you have added, and a way to add one.',
                    hue: kIvfHue,
                    onTap: () => openTtcRecords(context, resultsOnly: true),
                  ),
                ]),
                const SizedBox(height: 22),
                TtcLookupNote(hi
                    ? 'Ye jaankari hai, salaah nahi. Kaunsa test kab karwana hai, ye aapke doctor ke saath tay hota hai. Prices sirf andaaza hain aur jagah ke hisaab se badalte hain.'
                    : 'This is information, not advice. Which tests to have, '
                        'and when, is for you and your doctor to decide.'),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }
}

// =============================================================================
//  Kept for revert (2026-09-27, night): the state and the in-place card as
//  they were before the tool rebuild, when a tap grew the card in the list.
// =============================================================================
// class _TtcTestsScreenState extends State<TtcTestsScreen> {
//   bool _him = false;
//   final _focusKey = GlobalKey();
//
//   @override
//   void initState() {
//     super.initState();
//     final focus = widget.focusId;
//     if (focus == null) return;
//     // A pointer at one of HIS tests has to flip the segment, or the card it is
//     // scrolling to is not on screen at all.
//     final test = ttcTestById(focus);
//     if (test != null) _him = test.forHim;
//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocus());
//   }
//
//   void _scrollToFocus() {
//     final ctx = _focusKey.currentContext;
//     if (ctx == null) return;
//     Scrollable.ensureVisible(ctx,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeOut,
//         alignment: 0.1);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: TtcLang.instance,
//       builder: (context, _) {
//         final t = TtcS.current();
//         // Kept for revert (2026-09-27): final tests = ttcTestsFor(him: _him);
//         final tests = ttcTestsInOrder(him: _him);
//         // ⚠️ ONE SHELL FOR EVERY TOOL (2026-09-27). Tiles in the same Tools
//         // hub opened in two different shells: most wore `TtcToolScaffold`
//         // (hero field, serif title, white sheet) and this one a plain page
//         // with a back bar. Only the shell changed: the tile's name is the
//         // hero title, the what-this-is line is the hero intro, and the
//         // her/him switch leads the sheet. Kept for revert (2026-09-27):
//         // return Scaffold(
//         //   backgroundColor: ttcBg,
//         //   body: SafeArea(
//         //     child: ListView(
//         //       padding: const EdgeInsets.fromLTRB(
//         //           ttcGutter, 8, ttcGutter, ttcBottomInset),
//         //       children: [
//         //         TtcBackBar(title: t.medicalTests),
//         //         const SizedBox(height: 16),
//         //         Text(<the intro below>, style: ttcBody(14, h: 1.6)),
//         //         const SizedBox(height: 18),
//         return TtcToolScaffold(
//           // Care and medicines' hue in Tools, the same as Medication.
//           hue: kIvfHue,
//           // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
//           // tile's name, word for word ("Medical Tests" is the Hindi
//           // build's tile); the title is the tile's own line.
//           eyebrow: t.hinglish ? t.medicalTests : 'Medical tests',
//           title: 'What each test tells you.',
//           // ⚠️ SAY WHAT THIS IS, AND WHAT A TAP DOES (tools pass,
//           // 2026-09-27). Kept for revert: t.testsIntro in both languages.
//           intro: t.hinglish
//               ? t.testsIntro
//               : 'What each fertility test checks, when to have it '
//                   'and roughly what it costs. If your doctor gave '
//                   'you a list, find each name below and tap it to '
//                   'read more.',
//           children: [
//             ttcToolPad(Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 22),
//
//                 // Two segments, equal weight. Not a tab and a footnote.
//                 Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                       color: ttcPanel,
//                       borderRadius: BorderRadius.circular(999)),
//                   child: Row(children: [
//                     _seg(t.testForHer, !_him, () => setState(() => _him = false)),
//                     _seg(t.testForHim, _him, () => setState(() => _him = true)),
//                   ]),
//                 ),
//                 const SizedBox(height: 18),
//
//                 for (final test in tests) ...[
//                   _TestCard(
//                     key: test.id == widget.focusId ? _focusKey : null,
//                     test: test,
//                     t: t,
//                     startOpen: test.id == widget.focusId,
//                   ),
//                   const SizedBox(height: 11),
//                 ],
//
//                 // ⚠️ HIS TAB HOLDS ONE TEST, SO IT SAYS WHERE THE REST IS
//                 // (tools pass, 2026-09-27). The switch looked like half the
//                 // library was his and then showed one card. The next step for
//                 // him is reading his own report, and that tool exists.
//                 if (_him) ...[
//                   TtcCard(
//                     color: ttcPanel,
//                     onTap: () => openTtcSemenReport(context),
//                     child: Row(children: [
//                       Expanded(
//                         child: Text(
//                             'Got a semen analysis report? We can go through '
//                             'it with you, line by line.',
//                             style: ttcBody(13.5,
//                                 color: ttcTitleInk, h: 1.5)),
//                       ),
//                       const SizedBox(width: 8),
//                       const Icon(Icons.chevron_right_rounded,
//                           size: 20, color: ttcPurple),
//                     ]),
//                   ),
//                   const SizedBox(height: 11),
//                 ],
//
//                 const SizedBox(height: 8),
//                 Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Icon(Icons.info_outline_rounded,
//                       size: 15, color: ttcMuted),
//                   const SizedBox(width: 9),
//                   Expanded(
//                     child: Text(
//                       t.hinglish
//                           ? 'Ye jaankari hai, salaah nahi. Kaunsa test kab karwana hai, ye aapke doctor ke saath tay hota hai. Prices sirf andaaza hain aur jagah ke hisaab se badalte hain.'
//                           : 'This is information, not advice. Which tests to have, and when, is for you and your doctor to decide. Prices are a rough guide and vary by city and lab.',
//                       style: ttcBody(11.5, color: ttcMuted, h: 1.5),
//                     ),
//                   ),
//                 ]),
//                 const SizedBox(height: 26),
//               ],
//             )),
//           ],
//           // Kept for revert (2026-09-27): the old page's closing.
//           //     ],
//           //   ),
//           // ),
//         );
//       },
//     );
//   }
//
//   Widget _seg(String label, bool on, VoidCallback onTap) => Expanded(
//         child: GestureDetector(
//           onTap: onTap,
//           behavior: HitTestBehavior.opaque,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             alignment: Alignment.center,
//             padding: const EdgeInsets.symmetric(vertical: 11),
//             decoration: BoxDecoration(
//               color: on ? Colors.white : Colors.transparent,
//               borderRadius: BorderRadius.circular(999),
//               boxShadow: on ? ttcCardShadow : null,
//             ),
//             child: Text(label,
//                 style: ttcBody(13,
//                     color: on ? ttcTitleInk : ttcSoft, w: FontWeight.w800)),
//           ),
//         ),
//       );
// }
//
// class _TestCard extends StatefulWidget {
//   const _TestCard({
//     super.key,
//     required this.test,
//     required this.t,
//     this.startOpen = false,
//   });
//
//   final TtcTest test;
//   final TtcS t;
//
//   /// True when Ask Veda pointed at this one - it opens expanded, so the answer
//   /// lands on the detail rather than on a closed row.
//   final bool startOpen;
//
//   @override
//   State<_TestCard> createState() => _TestCardState();
// }
//
// class _TestCardState extends State<_TestCard> {
//   late bool _open = widget.startOpen;
//
//   @override
//   Widget build(BuildContext context) {
//     final t = widget.t;
//     final hi = t.hinglish;
//     final test = widget.test;
//     return TtcCard(
//       onTap: () => setState(() => _open = !_open),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // ⚠️ THE PRICE IS A QUIET LINE, NOT A CHIP (tools pass, 2026-09-27).
//         // A coloured chip in the corner was the loudest thing on the card
//         // after the name, and it made a list of medical tests read like a
//         // shop. Kept for revert:
//         // Row(children: [
//         //   Expanded(child: Text(test.name, style: ttcJakarta(16))),
//         //   Container(
//         //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         //     decoration: BoxDecoration(
//         //         color: ttcPanel, borderRadius: BorderRadius.circular(999)),
//         //     child: Text(test.cost(hi),
//         //         style: ttcBody(11, color: ttcPurple, w: FontWeight.w800)),
//         //   ),
//         // ]),
//         Text(test.name, style: ttcJakarta(16)),
//         const SizedBox(height: 9),
//         // The answer in ten seconds, above the fold. Depth below.
//         Text(test.what(hi), style: ttcBody(13.5, h: 1.55)),
//         const SizedBox(height: 6),
//         Text('${hi ? t.testCost : 'Usually costs'} ${test.cost(hi)}',
//             style: ttcBody(12, color: ttcMuted, w: FontWeight.w600)),
//
//         // WHEN in the cycle, on the collapsed card.
//         //
//         // This was highlighted, correctly, but only after expanding - and it is
//         // the one fact that costs a whole month when it is wrong. FSH and LH
//         // read on the wrong day are not a slightly worse result; they are a
//         // repeat test next cycle.
//         if (!_open) ...[
//           const SizedBox(height: 9),
//           Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Icon(Icons.schedule_rounded, size: 13, color: ttcBrown),
//             const SizedBox(width: 7),
//             Expanded(
//               child: Text(test.when(hi),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: ttcBody(11.5, color: ttcBrown, h: 1.4)),
//             ),
//           ]),
//         ],
//
//         if (_open) ...[
//           const SizedBox(height: 16),
//           _row(t.testWhy, test.why(hi)),
//           const SizedBox(height: 14),
//           // Highlighted, because getting this wrong wastes a month as well as
//           // the money.
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(13),
//             decoration: BoxDecoration(
//               color: ttcCautionCard,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     const Icon(Icons.schedule_rounded,
//                         size: 14, color: ttcBrown),
//                     const SizedBox(width: 7),
//                     Text(t.testWhen.toUpperCase(),
//                         style: ttcBody(9.5,
//                             color: ttcBrown, w: FontWeight.w800)),
//                   ]),
//                   const SizedBox(height: 7),
//                   Text(test.when(hi),
//                       style: ttcBody(13, color: ttcBrown, h: 1.5)),
//                 ]),
//           ),
//           const SizedBox(height: 14),
//           _row(t.testReading, test.reading(hi)),
//           const SizedBox(height: 14),
//           // ⚠️ READING TURNS INTO DOING (tools pass, 2026-09-27). A woman
//           // holding an AMH report had to find Records herself. This opens it
//           // with this test already chosen, so the result files under the
//           // right name and groups with any earlier one.
//           GestureDetector(
//             key: ValueKey('ttc_test_add_${test.id}'),
//             onTap: () => openTtcRecords(context, addTestId: test.id),
//             behavior: HitTestBehavior.opaque,
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(999),
//                 border: Border.all(color: ttcLine),
//               ),
//               child: Text('Add my result',
//                   style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w800)),
//             ),
//           ),
//         ],
//
//         const SizedBox(height: 12),
//         Row(children: [
//           Text(_open ? t.testLess : t.testMore,
//               style: ttcBody(12.5, color: ttcPurple, w: FontWeight.w800)),
//           const SizedBox(width: 5),
//           Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
//               size: 17, color: ttcPurple),
//         ]),
//       ]),
//     );
//   }
//
//   Widget _row(String label, String body) => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label.toUpperCase(),
//               style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
//           const SizedBox(height: 6),
//           Text(body, style: ttcBody(13.5, color: ttcInk, h: 1.6)),
//         ],
//       );
// }

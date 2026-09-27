// =============================================================================
//  TTC - "Can I...?"
// -----------------------------------------------------------------------------
//  The fastest way to settle an everyday worry. Same shape as the pregnancy
//  version: a verdict, the short answer, why, and the Indian-context line.
//
//  The colour language is deliberately NOT a traffic light. A red "avoid" chip
//  next to papaya would teach a couple to feel afraid of a fruit, and this
//  stage is already carrying more anxiety than it needs. Intensity carries the
//  meaning instead - which also means the verdict survives a greyscale
//  screenshot and a colour-blind eye.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT AS A LIST AND A PAGE (tool rebuild, 2026-09-27, night)
//  ---------------------------------------------------------------------------
//  "Old tools in new clothes": inside the shell this was still twelve shadowed
//  `TtcCard`s, each with a tinted verdict pill, a violet "Read more", and a
//  detail that grew the card in place. Now (Yuka "Additives",
//  https://mobbin.com/screens/5e756797-34ea-465d-814c-c139ce62a34f; DoorDash
//  help, https://mobbin.com/screens/a768d9ac-8235-4bd8-89b6-81eb2a7bc677; Beli
//  FAQ, https://mobbin.com/screens/69d9b3a0-71c2-4418-a4ef-1c371f6c1848):
//
//    · Search first, reading the whole answer (the why and the India line).
//    · Three headings; under each, unboxed rows: the question, then the
//      verdict as a drawn mark and a WORD (never a colour), then the one-line
//      answer. Scanning the column of verdicts answers most worries without a
//      tap.
//    · "Yes, with a limit" (was "In moderation", which meant a number on chai
//      and a habit on hot baths) always carries its limit beside it, a number
//      where there is one. See `TtcVerdictCopy` and `TtcCanI.limit`.
//    · A tap opens the answer in the one reader (`openTtcCanIRead`), the way
//      pregnancy's "Is it safe?" opens: verdict, short answer, why, the India
//      line, Ask Veda, then the rest of its group.
//    · "Not here?" at the foot of every list, not only an empty search, so the
//      way to ask is always one tap away.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_can_i_data.dart';
import '../../ttc/ttc_lookup_reads.dart' show openTtcCanIRead;
import '../doors/pv_list_row.dart' show PvRowGroup;
import '../v2/v2_palette.dart';
import 'ttc_askveda_screen.dart' show openTtcAskVeda;
import 'ttc_lookup_parts.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';

void openTtcCanI(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcCanIScreen(),
    settings: const RouteSettings(name: 'ttc/can_i'),
  ));
}

/// The three short headings the answers sit under (tools pass, 2026-09-27),
/// so she can scan without searching. Ids are the data file's; an id missing
/// here falls into "Body and habits", so a new entry is never dropped.
const List<(String, List<String>)> kTtcCanIGroups = [
  ('Food and drink', ['chai', 'alcohol', 'papaya']),
  (
    'Body and habits',
    [
      'smoking',
      'exercise',
      'hot_bath',
      'hair_dye',
      'travel',
      'sex_frequency',
    ]
  ),
  ('Medicines and tests', ['painkillers', 'xray', 'ayurvedic']),
];

/// Which heading [id] sits under.
String ttcCanIGroupOf(String id) {
  for (final (name, ids) in kTtcCanIGroups) {
    if (ids.contains(id)) return name;
  }
  return 'Body and habits';
}

/// ⚠️ SEARCH READS THE WHOLE ANSWER, IN BOTH LANGUAGES (tools pass,
/// 2026-09-27). It used to look at the question and the short answer only,
/// so "henna", "cola", "sauna" or "yoga" found nothing although the answer
/// named them in its "why" or its India line.
bool ttcCanIMatches(TtcCanI e, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return [
    for (final hi in const [false, true]) ...[
      e.question(hi),
      e.short(hi),
      e.why(hi),
      e.indian(hi),
    ],
  ].any((text) => text.toLowerCase().contains(q));
}

class TtcCanIScreen extends StatefulWidget {
  const TtcCanIScreen({super.key, this.focusId});

  /// An entry to open on, from an Ask Veda pointer (`ttccani_papaya` →
  /// `papaya`). The library renders whole underneath and the answer opens on
  /// top of it - deliberately, because the neighbouring answers are often the
  /// ones she actually needed, and Back lands on all of them.
  final String? focusId;

  @override
  State<TtcCanIScreen> createState() => _TtcCanIScreenState();
}

class _TtcCanIScreenState extends State<TtcCanIScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    final focus = widget.focusId;
    if (focus == null) return;
    final item = ttcCanIById(focus);
    if (item == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) openTtcCanIRead(context, item);
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
        final typed = _search.text.trim();
        // Kept for revert: the filter matched `question(hi)` and `short(hi)`.
        final results = typed.isEmpty
            ? ttcCanI
            : ttcCanI.where((e) => ttcCanIMatches(e, typed)).toList();

        Widget row(TtcCanI item) => TtcLookupRow(
              key: ValueKey('ttc_can_i_row_${item.id}'),
              title: item.question(hi),
              onTap: () => openTtcCanIRead(context, item),
              lines: [
                ttcVerdictLine(item, hi),
                ttcLookupLine(item.short(hi)),
              ],
            );

        return TtcToolScaffold(
          // Plan and learn's hue in Tools.
          hue: 104,
          // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
          // tile's name, word for word; the title is the tile's own line.
          eyebrow: t.canITitle,
          title: 'Quick answers to everyday worries.',
          // Kept for revert: "While you're trying, the honest answer to most
          // of these is yes." alone.
          intro: hi
              ? t.canIIntro
              : "While you're trying, the honest answer to most of these "
                  'is yes. Search, or tap a question to see why.',
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                TtcLookupSearchField(
                  controller: _search,
                  hint: t.canISearch,
                  onChanged: (_) => setState(() {}),
                ),

                // ⚠️ THE EMPTY STATE HAS A WAY ON (tools pass, 2026-09-27).
                // It promised "tell us, so we can add it" with nothing to tap.
                // It hands her words to Ask Veda, which answers from the
                // reviewed reads.
                if (results.isEmpty) ...[
                  const SizedBox(height: 22),
                  Text(t.canINoneTitle, style: ttcLookupTitle(p)),
                  const SizedBox(height: 6),
                  Text(
                      hi
                          ? t.canINoneBody
                          : 'Ask Veda can answer it from our reviewed reads. '
                              "If it's worrying you, ask your doctor too.",
                      style: ttcLookupBody(p)),
                  const SizedBox(height: 10),
                  PvRowGroup(p: p, children: [
                    TtcLookupActionRow(
                      key: const ValueKey('ttc_can_i_ask_veda'),
                      icon: Icons.auto_awesome_outlined,
                      label: 'Ask Veda: "$typed"',
                      onTap: () =>
                          openTtcAskVeda(context, initialQuery: typed),
                    ),
                  ]),
                ] else ...[
                  // Under three headings, in the data's own order within
                  // each. Kept for revert: one flat list of `results`.
                  for (final (group, _) in kTtcCanIGroups)
                    if (results.any((e) => ttcCanIGroupOf(e.id) == group)) ...[
                      TtcLookupHeading(group),
                      PvRowGroup(p: p, children: [
                        for (final item in results
                            .where((e) => ttcCanIGroupOf(e.id) == group))
                          row(item),
                      ]),
                    ],
                  // The way to ask is always here, not only when a search
                  // comes back empty.
                  const TtcLookupHeading('Not here?'),
                  PvRowGroup(p: p, children: [
                    TtcLookupActionRow(
                      key: const ValueKey('ttc_can_i_ask_veda_foot'),
                      icon: Icons.auto_awesome_outlined,
                      label: 'Ask Veda your own question',
                      line: 'It answers from our reviewed reads.',
                      onTap: () => openTtcAskVeda(context,
                          initialQuery: typed.isEmpty ? null : typed),
                    ),
                  ]),
                ],

                const SizedBox(height: 22),
                TtcLookupNote(t.canIDisclaimer),
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
//  Kept for revert (2026-09-27, night): the build and the in-place card as
//  they were before the tool rebuild, when a tap grew the card in the list.
// =============================================================================
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: TtcLang.instance,
//       builder: (context, _) {
//         final t = TtcS.current();
//         final hi = t.hinglish;
//         final q = _search.text.trim().toLowerCase();
//         // Kept for revert: the filter matched `question(hi)` and `short(hi)`.
//         final results = q.isEmpty
//             ? ttcCanI
//             : ttcCanI.where((e) => ttcCanIMatches(e, q)).toList();
//
//         // ⚠️ ONE SHELL FOR EVERY TOOL (2026-09-27). Tiles in the same Tools
//         // hub opened in two different shells: most wore `TtcToolScaffold`
//         // (hero field, serif title, white sheet) and this one a plain page
//         // with a back bar. Only the shell changed: the tile's name is the
//         // hero title, the intro is the hero line, and the search field
//         // leads the sheet. Kept for revert (2026-09-27):
//         // return Scaffold(
//         //   backgroundColor: ttcBg,
//         //   body: SafeArea(
//         //     child: ListView(
//         //       padding: const EdgeInsets.fromLTRB(
//         //           ttcGutter, 8, ttcGutter, ttcBottomInset),
//         //       children: [
//         //         TtcBackBar(title: t.canITitle),
//         //         const SizedBox(height: 16),
//         //         Text(t.canIIntro, style: ttcBody(13.5, h: 1.6)),
//         //         const SizedBox(height: 16),
//         return TtcToolScaffold(
//           // Plan and learn's hue in Tools.
//           hue: 104,
//           // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
//           // tile's name, word for word; the title is the tile's own line,
//           // so the intro drops the sentence that repeated it. Kept for
//           // revert: intro: t.canIIntro in both builds.
//           eyebrow: t.canITitle,
//           title: 'Quick answers to everyday worries.',
//           intro: hi
//               ? t.canIIntro
//               : "While you're trying, the honest answer to most of these "
//                   'is yes.',
//           children: [
//             ttcToolPad(Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 22),
//
//                 TextField(
//                   controller: _search,
//                   onChanged: (_) => setState(() {}),
//                   style: ttcBody(14.5, color: ttcInk),
//                   decoration: InputDecoration(
//                     hintText: t.canISearch,
//                     hintStyle: ttcBody(14, color: ttcMuted),
//                     prefixIcon: const Icon(Icons.search_rounded,
//                         size: 20, color: ttcMuted),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(999),
//                       borderSide: const BorderSide(color: ttcBorder),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(999),
//                       borderSide: const BorderSide(color: ttcBorder),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(999),
//                       borderSide: const BorderSide(color: ttcPurple, width: 1.4),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//
//                 // ⚠️ THE EMPTY STATE HAS A WAY ON (tools pass, 2026-09-27).
//                 // It promised "tell us, so we can add it" with nothing to tap.
//                 // It now hands her words to Ask Veda, which answers from the
//                 // reviewed reads. Kept for revert: the TtcEmpty below had no
//                 // cta and no onTap, and its body was `t.canINoneBody`.
//                 if (results.isEmpty)
//                   TtcEmpty(
//                     key: const ValueKey('ttc_can_i_ask_veda'),
//                     icon: Icons.search_off_rounded,
//                     title: t.canINoneTitle,
//                     body: hi
//                         ? t.canINoneBody
//                         : 'Ask Veda can answer it from our reviewed reads. If '
//                             "it's worrying you, ask your doctor too.",
//                     cta: 'Ask Veda: "${_search.text.trim()}"',
//                     onTap: () => openTtcAskVeda(context,
//                         initialQuery: _search.text.trim()),
//                   )
//                 else
//                   // Under three headings, in the data's own order within each.
//                   // Kept for revert: one flat list of `results`.
//                   for (final (group, _) in kTtcCanIGroups)
//                     if (results.any((e) => ttcCanIGroupOf(e.id) == group)) ...[
//                       Padding(
//                         padding: const EdgeInsets.only(top: 6, bottom: 10),
//                         child: Text(group.toUpperCase(),
//                             style: ttcBody(10.5,
//                                 color: ttcMuted, w: FontWeight.w800)),
//                       ),
//                       for (final item in results
//                           .where((e) => ttcCanIGroupOf(e.id) == group)) ...[
//                         _CanICard(
//                           key: item.id == widget.focusId ? _focusKey : null,
//                           item: item,
//                           t: t,
//                           startOpen: item.id == widget.focusId,
//                         ),
//                         const SizedBox(height: 11),
//                       ],
//                     ],
//
//                 const SizedBox(height: 14),
//                 Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Icon(Icons.info_outline_rounded,
//                       size: 15, color: ttcMuted),
//                   const SizedBox(width: 9),
//                   Expanded(
//                     child: Text(t.canIDisclaimer,
//                         style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
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
// }
//
// class _CanICard extends StatefulWidget {
//   const _CanICard({
//     super.key,
//     required this.item,
//     required this.t,
//     this.startOpen = false,
//   });
//
//   final TtcCanI item;
//   final TtcS t;
//
//   /// True when Ask Veda pointed here - it opens on the reasoning, not the chip.
//   final bool startOpen;
//
//   @override
//   State<_CanICard> createState() => _CanICardState();
// }
//
// class _CanICardState extends State<_CanICard> {
//   late bool _open = widget.startOpen;
//
//   @override
//   Widget build(BuildContext context) {
//     final t = widget.t;
//     final hi = t.hinglish;
//     final item = widget.item;
//
//     return TtcCard(
//       onTap: () => setState(() => _open = !_open),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Expanded(child: Text(item.question(hi), style: ttcJakarta(15.5))),
//           if (item.forPartner) ...[
//             const SizedBox(width: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//               decoration: BoxDecoration(
//                   color: ttcCoralTint,
//                   borderRadius: BorderRadius.circular(999)),
//               child: Text(t.forPartnerTag,
//                   style: ttcBody(10, color: ttcCoral, w: FontWeight.w800)),
//             ),
//           ],
//         ]),
//         const SizedBox(height: 11),
//
//         // The verdict, in the calm colour language - never a traffic light.
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//           decoration: BoxDecoration(
//             color: _tint(item.verdict),
//             borderRadius: BorderRadius.circular(999),
//           ),
//           child: Text(item.verdict.label(hi),
//               style: ttcBody(12, color: _ink(item.verdict), w: FontWeight.w800)),
//         ),
//         const SizedBox(height: 11),
//
//         // The answer in ten seconds, above the fold.
//         Text(item.short(hi),
//             style: ttcBody(14, color: ttcInk, w: FontWeight.w600, h: 1.55)),
//
//         if (_open) ...[
//           const SizedBox(height: 14),
//           Text(item.why(hi), style: ttcBody(13.5, h: 1.65)),
//           const SizedBox(height: 14),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(13),
//             decoration: BoxDecoration(
//               color: ttcCautionCard,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Icon(Icons.emoji_objects_outlined,
//                   size: 15, color: ttcBrown),
//               const SizedBox(width: 9),
//               Expanded(
//                 child: Text(item.indian(hi),
//                     style: ttcBody(12.5,
//                         color: ttcBrown, h: 1.55, w: FontWeight.w600)),
//               ),
//             ]),
//           ),
//         ],
//
//         const SizedBox(height: 11),
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
//   // A single warm family, graded by intensity. No green, no red - a "better
//   // not" and a "yes" should differ in weight, not in alarm.
//   Color _tint(TtcVerdict v) {
//     switch (v) {
//       case TtcVerdict.safe:
//         return ttcPanel;
//       case TtcVerdict.moderate:
//         return const Color(0xFFF6ECFA);
//       case TtcVerdict.askDoctor:
//         return ttcCautionCard;
//       case TtcVerdict.avoid:
//         return ttcCoralTint;
//     }
//   }
//
//   Color _ink(TtcVerdict v) {
//     switch (v) {
//       case TtcVerdict.safe:
//         return ttcSoft;
//       case TtcVerdict.moderate:
//         return ttcPurple;
//       case TtcVerdict.askDoctor:
//         return ttcBrown;
//       case TtcVerdict.avoid:
//         return ttcCoral;
//     }
//   }
// }

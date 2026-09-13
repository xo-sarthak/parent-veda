// =============================================================================
//  ScriptsLibraryScreen - "What to say when…"
// -----------------------------------------------------------------------------
//  ⚠️ THE ONLY SCREEN IN THE PARENTING APP DESIGNED TO BE USED WHILE THE THING
//  IS HAPPENING, and every decision here follows from that.
//
//  A parent opens this in a supermarket aisle with a child on the floor. She is
//  not going to read. So:
//    * search is at the top and focused-ready, because she knows the word
//    * the words come first on every card, before any explanation
//    * "say this" is large and high contrast; the reasoning is small and grey
//    * her child's own age band leads, and the rest stay browsable
//
//  ⚠️ NOTHING HERE IS TAPPABLE-TO-A-DEAD-END. Each entry links to the article
//  it came from, so the tool is a door into the section rather than a leaf.
//
//  ⚠️ NO COPY BUTTON, NO SHARE. It was tempting and it is wrong: these are
//  sentences to say out loud in the next ten seconds, not text to send
//  somewhere. A share control would also turn a private moment into a thing
//  that gets forwarded to a family group, which is precisely the pressure the
//  behaviour section exists to relieve.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_scripts_data.dart';
import 'pp_tools_kit.dart';

class ScriptsLibraryScreen extends StatefulWidget {
  const ScriptsLibraryScreen({super.key, this.onOpenPage});

  /// Opens the article a script belongs to. Null when the tool is reached from
  /// somewhere that cannot resolve section pages — the link then simply does
  /// not render, rather than rendering and doing nothing.
  final void Function(BuildContext, String pageId)? onOpenPage;

  @override
  State<ScriptsLibraryScreen> createState() => _ScriptsLibraryScreenState();
}

class _ScriptsLibraryScreenState extends State<ScriptsLibraryScreen> {
  final _search = TextEditingController();
  String _query = '';
  String? _band;

  @override
  void initState() {
    super.initState();
    // ⚠️ HIS BAND LEADS, AND IS NOT A LOCK. Derived from the profile so nothing
    // is asked; the "All ages" chip is always there because an older cousin, a
    // younger sibling, or simple curiosity are all real reasons to look
    // outside the band.
    _band = _bandForAge(ChildProfileStore.instance.ageInMonths);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static String _bandForAge(int months) {
    if (months < 12) return 'infant';
    if (months < 24) return 'toddler_1';
    if (months < 36) return 'toddler_2';
    return 'preschool';
  }

  static const _bandLabels = <String, String>{
    'infant': 'Under 1',
    'toddler_1': '1 to 2',
    'toddler_2': '2 to 3',
    'preschool': '3 and up',
  };

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    // Search deliberately ignores the band filter: if she is typing a word, she
    // knows what she is looking for better than his birthday does.
    final results = searching
        ? ppScriptSearch(_query)
        : (_band == null ? kPpScripts : ppScriptsForBand(_band!));

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 44),
          children: [
            _pad(ppBack(context, 'Behaviour')),
            const SizedBox(height: 20),
            _pad(ppEyebrow('The words', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('What to say when…', style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 8),
            _pad(Text(
                'Find the moment, get the sentence. The reasoning is '
                'underneath for when you have time — it is not the point right '
                'now.',
                style: ppBody(13.5, h: 1.55))),

            const SizedBox(height: 18),
            _pad(_searchBar()),

            // ⚠️ THE AGE CHIPS CAME OFF (Behaviour brief, 2026-09-13): "kill
            // the age chips, scope to his age." His band leads and is not
            // chosen; search still ignores it, because a typed word knows
            // better than his birthday. Kept below for revert.
            // if (!searching) ...[
            //   const SizedBox(height: 14),
            //   _pad(_bandRow()),
            // ],
            if (!searching && _band != null) ...[
              const SizedBox(height: 12),
              _pad(Text(
                  'FOR ${ChildProfileStore.instance.nameMid.toUpperCase()}  ·  ${_bandLabels[_band]!.toUpperCase()}',
                  style: ppBody(10.5, color: ppMuted, w: FontWeight.w800)
                      .copyWith(letterSpacing: 1.1))),
            ],

            const SizedBox(height: 20),
            if (results.isEmpty)
              _pad(ppEmptyCard(Icons.search_off_rounded,
                  'Nothing matches that yet. Try a plainer word — "hitting", '
                  '"park", "food" — or browse by age above.'))
            else
              _pad(Column(children: [for (final s in results) _card(s)])),

            // "Show every age" retired with the chips. Kept for revert.
            // if (!searching && _band != null) ...[
            //   const SizedBox(height: 8),
            //   _pad(GestureDetector(
            //     onTap: () => setState(() => _band = null),
            //     behavior: HitTestBehavior.opaque,
            //     child: Text('Show every age',
            //         style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
            //   )),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _searchBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppHair),
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 19, color: ppMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              style: ppBody(14, color: ppInk),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: 'hitting, park, phone, food…',
                hintStyle: ppBody(14, color: ppMuted),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() {
                _search.clear();
                _query = '';
              }),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close_rounded, size: 17, color: ppMuted),
              ),
            ),
        ]),
      );

  // ignore: unused_element
  Widget _bandRow() => SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          children: [
            for (final entry in _bandLabels.entries)
              GestureDetector(
                onTap: () => setState(() => _band = entry.key),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _band == entry.key ? ppPurple : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: _band == entry.key ? ppPurple : ppHair),
                  ),
                  // The label follows the ground — the same fix as the sleep
                  // timer, which shipped once as dark text on violet.
                  child: Text(entry.value,
                      style: ppBody(12.5,
                          color: _band == entry.key ? Colors.white : ppInk,
                          w: FontWeight.w700)),
                ),
              ),
          ],
        ),
      );

  Widget _card(PpScript s) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppHair),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.situation, style: ppJakarta(15.5)),
          const SizedBox(height: 13),

          // SAY THIS — the reason the screen exists, so it gets the weight.
          Text('SAY THIS',
              style: ppBody(9.5, color: ppPurple, w: FontWeight.w800)),
          const SizedBox(height: 7),
          for (final line in s.sayThis) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 5,
                height: 5,
                decoration:
                    const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(line,
                      style: ppBody(14.5, color: ppInk, h: 1.5, w: FontWeight.w600))),
            ]),
            const SizedBox(height: 7),
          ],

          const SizedBox(height: 8),
          // ⚠️ "NOT THIS" IS SMALLER AND GREY, NOT RED. Every line in it is
          // something a loving parent says; setting it in an alarm colour would
          // turn a useful contrast into an accusation.
          Text('RATHER THAN',
              style: ppBody(9.5, color: ppMuted, w: FontWeight.w800)),
          const SizedBox(height: 6),
          for (final line in s.notThis)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line,
                  style: ppBody(13, color: ppSoft, h: 1.45)),
            ),

          const SizedBox(height: 12),
          Container(height: 1, color: ppHair),
          const SizedBox(height: 11),
          Text(s.principle, style: ppBody(12.5, color: ppMuted, h: 1.55)),

          if (s.pageId != null && widget.onOpenPage != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => widget.onOpenPage!(context, s.pageId!),
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                Text('Read the whole thing',
                    style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                const SizedBox(width: 5),
                const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: ppPurple),
              ]),
            ),
          ],
        ]),
      );
}

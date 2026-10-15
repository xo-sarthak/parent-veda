// =============================================================================
//  WhatChangedScreen - Tools · "What Changed?" diagnostic (parenting · S22a v2)
// -----------------------------------------------------------------------------
//  A ParentVeda original: something suddenly different with the baby? The hub
//  lets a parent SEARCH a library of concerns (or pick from "Most common"),
//  then walks a short, concern-specific set of gentle questions and lands on a
//  likely cause + what-to-do, with a cross-app rail of what helps. The library
//  lives in pp_what_changed_data.dart; add concerns there and they appear here.
//  A guided starting point, never a diagnosis (the doctor disclaimer stays).
// =============================================================================

import 'package:flutter/material.dart';

import 'community_screen.dart';
import 'phase_map_screen.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_what_changed_data.dart';
import 'problem_solver_screen.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvChoiceTile, PvQuestionProgress, PvPress;
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit, kPvInk, pvStorePalette;
import '../v2/v2_palette.dart' show V2Palette;
import 'pp_care_parts.dart' show ppCareHeading;

/// Replace `{baby}` with the child's first name (fallback: "your baby").
String _fill(String s) {
  final name = ChildProfileStore.instance.name.trim();
  return s.replaceAll('{baby}', name.isEmpty ? 'your baby' : name);
}

// =============================================================================
//  Hub — search + most common + browse by area
// =============================================================================
/// The shared tool shell for What changed (2026-10-07). False draws the old page.
const bool kPpWhatChangedShell = true;

class WhatChangedScreen extends StatefulWidget {
  const WhatChangedScreen(
      {super.key, this.initialQuery, this.initialCategories});

  /// Pre-filters the library to what she actually tapped.
  ///
  /// ⚠️ THIS EXISTS BECAUSE THREE HUB DOORS LAND HERE — "Help my child sleep",
  /// "Solve a feeding problem" and "Handle a behaviour". Without it, all three
  /// dropped her into the same unfiltered list of thirty concerns and asked her
  /// to search for the thing she had just tapped a button about.
  ///
  /// That is the "opens something adjacent and hopes" failure: it looks like an
  /// answer, wastes her time, and she blames herself for not finding it. The
  /// app already knows what she asked — it should not ask her again.
  final String? initialQuery;

  /// Categories to open filtered to, when a text match would not do the job.
  ///
  /// ⚠️ ADDED AFTER A REAL FAILURE. "Handle a behaviour" passed the word
  /// "behaviour" and matched only two concerns — because tantrums, clinginess
  /// and separation upset are filed under the category "Mood", and none of
  /// their keywords contain the word "behaviour" either.
  ///
  /// So the pre-filter LOOKED like it worked and quietly hid most of what the
  /// door had just promised her. A category list says what we mean instead of
  /// hoping a word happens to match a taxonomy nobody checked.
  final List<String>? initialCategories;

  @override
  State<WhatChangedScreen> createState() => _WhatChangedScreenState();
}

class _WhatChangedScreenState extends State<WhatChangedScreen> {
  late final TextEditingController _search =
      TextEditingController(text: widget.initialQuery ?? '');
  late String _query = widget.initialQuery ?? '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(WcConcern c) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WcFlowScreen(concern: c)));

  @override
  Widget build(BuildContext context) {
    // A category filter beats a text match here: the concern taxonomy does not
    // line up with the words a door uses, and a near-miss silently hides most
    // of what the door promised.
    final cats = widget.initialCategories;
    final scoped = cats == null
        ? null
        : kWcConcerns
            .where((c) => cats.any(
                (x) => c.category.toLowerCase() == x.toLowerCase()))
            .toList();

    final searching = _query.trim().isNotEmpty;
    final results = searching
        ? wcSearch(_query)
        : (scoped ?? const <WcConcern>[]);

    // The shell every TTC and pregnancy tool wears (2026-10-07): search as a
    // pill, concerns as PvListRow groups under the caps eyebrow, as the Tools
    // tab draws them. `_buildBeforeShell` below is the page before.
    if (kPpWhatChangedShell) return _shell(results, searching);
    return _buildBeforeShell(results, searching);
  }

  Widget _shell(List<WcConcern> results, bool searching) {
    final p = pvStorePalette;
    Widget eyebrow(String t) => pregToolPad(Text(t.toUpperCase(),
        style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action)));
    Widget row(WcConcern c) => PvListRow(
          key: ValueKey('wc_row_${c.id}'),
          p: p,
          leading: PvMarkWell(p: p, hue: 285, size: 40, icon: c.icon),
          title: _fill(c.label),
          line: c.category,
          onTap: () => _open(c),
        );
    final common = wcCommon;
    return PregToolScaffold(
      hue: 285,
      eyebrow: 'Development',
      mark: IntentMark.nextStep,
      title: 'Something changed?',
      intro: _fill('Tell us what you are noticing about {baby}, and we will walk through the likely cause together.'),
      children: [
        pregToolPad(TextField(
          key: const ValueKey('wc_search'),
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
          decoration: InputDecoration(
            hintText: 'waking, rash, not eating...',
            hintStyle: pvManrope(fontSize: 15, color: p.ink3),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: p.ink3),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.ink1)),
          ),
        )),
        const SizedBox(height: 8),
        if (searching) ...[
          const SizedBox(height: 16),
          if (results.isEmpty)
            pregToolPad(Text('No match for "$_query" yet. Try a word like waking, rash or not eating.',
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
          else ...[
            eyebrow('${results.length} match${results.length == 1 ? '' : 'es'}'),
            const SizedBox(height: 6),
            pregToolPad(PvRowGroup(p: p, children: [for (final c in results) row(c)])),
          ],
        ] else ...[
          if (common.isNotEmpty) ...[
            const SizedBox(height: 20),
            eyebrow('Most common'),
            const SizedBox(height: 6),
            pregToolPad(PvRowGroup(p: p, children: [for (final c in common) row(c)])),
          ],
          for (final cat in wcCategories) ...[
            const SizedBox(height: 24),
            eyebrow(cat),
            const SizedBox(height: 6),
            pregToolPad(PvRowGroup(p: p, children: [
              for (final c in kWcConcerns.where((c) => c.category == cat)) row(c),
            ])),
          ],
        ],
        const SizedBox(height: 22),
        pregToolPad(Text('A guided starting point, not a diagnosis. If something worries you, check with a doctor.',
            style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink3))),
      ],
    );
  }

  // Kept for revert (2026-10-07): the page before the shared shell.
  Widget _buildBeforeShell(List<WcConcern> results, bool searching) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 44),
          children: [
            // header
            _pad(Row(children: [
              PvPress(child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, size: 16, color: ppInk),
                ),
              )),
              Expanded(child: Center(child: ppEyebrow('What Changed?', color: ppMuted, spacing: 1.4))),
              const SizedBox(width: 34),
            ])),

            const SizedBox(height: 22),
            _pad(Text.rich(TextSpan(children: [
              const TextSpan(text: 'Something suddenly '),
              TextSpan(text: 'different?', style: ppFraunces(30, color: ppPurple, h: 1.2)),
            ]), style: ppFraunces(30, h: 1.2))),
            const SizedBox(height: 10),
            _pad(Text(
                _fill('Tell us what you\'re noticing about {baby}, and we\'ll walk through the likely cause together.'),
                style: ppBody(14.5, color: ppSoft, h: 1.55))),

            // search
            const SizedBox(height: 20),
            _pad(_searchBar()),

            const SizedBox(height: 22),
            if (searching) ..._searchResults(results) else ..._browse(),

            const SizedBox(height: 22),
            _pad(Text('A guided starting point, not a diagnosis. If something worries you, always check with a doctor.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppHair),
          boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 20, spreadRadius: -16, offset: Offset(0, 8))],
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 20, color: ppMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              style: ppBody(15, color: ppInk),
              cursorColor: ppPurple,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search a concern — sleep, rash, feeding…',
                hintStyle: ppBody(14.5, color: ppMuted),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _search.clear();
                setState(() => _query = '');
                FocusScope.of(context).unfocus();
              },
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close_rounded, size: 18, color: ppMuted),
              ),
            ),
        ]),
      );

  List<Widget> _searchResults(List<WcConcern> results) {
    if (results.isEmpty) {
      return [
        _pad(Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            const Icon(Icons.search_off_rounded, size: 26, color: ppMuted),
            const SizedBox(height: 10),
            Text('No match for “$_query” yet.', textAlign: TextAlign.center, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Try a symptom like “waking”, “rash”, or “not eating”.',
                textAlign: TextAlign.center, style: ppBody(12.5, color: ppMuted, h: 1.5)),
          ]),
        )),
      ];
    }
    return [
      _pad(ppEyebrow('${results.length} match${results.length == 1 ? '' : 'es'}', color: ppPurple, spacing: 1.0)),
      const SizedBox(height: 12),
      for (final c in results) _pad(_concernRow(c)),
    ];
  }

  List<Widget> _browse() {
    final common = wcCommon;
    return [
      if (common.isNotEmpty) ...[
        _pad(ppEyebrow('Most common', color: ppPurple, spacing: 1.0)),
        const SizedBox(height: 12),
        for (final c in common) _pad(_concernRow(c)),
        const SizedBox(height: 8),
      ],
      _pad(Row(children: [
        Expanded(child: Text('Browse by area', style: ppJakarta(16))),
        Text('${kWcConcerns.length} concerns', style: ppBody(12, color: ppMuted)),
      ])),
      const SizedBox(height: 6),
      _pad(Text('Everything we can help you think through, grouped.', style: ppBody(12.5, color: ppMuted))),
      const SizedBox(height: 14),
      for (final cat in wcCategories) ..._categoryBlock(cat),
    ];
  }

  List<Widget> _categoryBlock(String cat) {
    final items = kWcConcerns.where((c) => c.category == cat).toList();
    return [
      _pad(Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
          child: Text(cat, style: ppBody(11.5, color: ppPurple, w: FontWeight.w700)),
        ),
      ])),
      const SizedBox(height: 10),
      for (final c in items) _pad(_concernRow(c)),
      const SizedBox(height: 14),
    ];
  }

  Widget _concernRow(WcConcern c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PvPress(child: GestureDetector(
          onTap: () => _open(c),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ppHair),
              boxShadow: const [BoxShadow(color: Color(0x146A30B6), blurRadius: 18, spreadRadius: -16, offset: Offset(0, 8))],
            ),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
                child: Icon(c.icon, size: 19, color: ppPurple),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_fill(c.label), style: ppJakarta(14.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(c.category, style: ppBody(11.5, color: ppMuted)),
                ]),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFC7BBD6)),
            ]),
          ),
        )),
      );
}

// =============================================================================
//  Flow — journey stepper + result for a single concern
// =============================================================================
class WcFlowScreen extends StatefulWidget {
  const WcFlowScreen({super.key, required this.concern});
  final WcConcern concern;

  @override
  State<WcFlowScreen> createState() => _WcFlowScreenState();
}

class _WcFlowScreenState extends State<WcFlowScreen> {
  int _step = 0;
  bool _showResult = false;
  late final List<int?> _answers =
      List<int?>.filled(widget.concern.questions.length, null);

  List<WcQuestion> get _steps => widget.concern.questions;
  int get _count => _steps.length;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  void _reset() => setState(() {
        _showResult = false;
        _step = 0;
        for (int i = 0; i < _answers.length; i++) {
          _answers[i] = null;
        }
      });

  void _advance() => setState(() {
        if (_step < _count - 1) {
          _step++;
        } else {
          _showResult = true;
        }
      });

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  The flow on the shell every TTC and pregnancy tool wears, the same field
  //  and hue as the What changed list above it: the concern as the serif title,
  //  the steps as an ink rail, options as white hairline cards, one ink button
  //  in the flow (not floating, so it never sits over the last option), and the
  //  result as one white card. The tone (urgent / worth checking / likely) keeps
  //  its own colour on the label and the card's edge: a red-flag result must not
  //  read like a benign one. The not-a-diagnosis line and the route to a doctor
  //  are unchanged. `_buildBeforeShell` is the page before, kept for revert.
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: 285,
      variant: 3,
      eyebrow: "You're looking into",
      title: _fill(widget.concern.quote),
      action: _showResult
          ? Semantics(
              button: true,
              label: 'Start again',
              child: InkWell(
                key: const ValueKey('wc_flow_reset'),
                onTap: _reset,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: p.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999)),
                  child: Text('Reset', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: kPvInk)),
                ),
              ),
            )
          : null,
      children: [
        pregToolPad(_shellJourney(p)),
        if (_showResult) ..._shellResult(context, p) else ..._shellQuestion(p),
        const SizedBox(height: 22),
        pregToolPad(Text('A guided starting point, not a diagnosis. If something worries you, always check with a doctor.',
            style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink3))),
      ],
    );
  }

  Widget _shellJourney(V2Palette p) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (int i = 0; i < _count; i++) ...[
          if (i > 0)
            Container(
              width: 12,
              height: 2,
              margin: const EdgeInsets.only(top: 16),
              color: (_showResult || i <= _step) ? kPvInk : p.line,
            ),
          Expanded(
            child: Builder(builder: (_) {
              final done = _showResult || i < _step;
              final current = !_showResult && i == _step;
              return Column(children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? kPvInk : Colors.white,
                    border: done ? null : Border.all(color: current ? kPvInk : p.line, width: current ? 1.6 : 1),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                      : Icon(_steps[i].icon, size: 15, color: current ? kPvInk : p.ink3),
                ),
                const SizedBox(height: 6),
                Text(_steps[i].category,
                    style: pvManrope(
                        fontSize: 10,
                        fontWeight: current || done ? FontWeight.w800 : FontWeight.w600,
                        color: current || done ? p.ink1 : p.ink3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ]);
            }),
          ),
        ],
      ]);

  List<Widget> _shellQuestion(V2Palette p) {
    final s = _steps[_step];
    final answered = _answers[_step] != null;
    return [
      const SizedBox(height: 26),
      // One progress line for every question flow (2026-10-10). Kept for
      // revert: the violet "QUESTION 2 OF 5 · SLEEP" eyebrow with no line —
      //   pregToolPad(Text('QUESTION ${_step + 1} OF $_count · ${s.category.toUpperCase()}',
      //       style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action))),
      pregToolPad(PvQuestionProgress(
        done: _step + 1,
        total: _count,
        startLabel: s.category,
        goingLabel: s.category,
        count: true,
      )),
      const SizedBox(height: 8),
      pregToolPad(ppCareHeading(_fill(s.prompt))),
      const SizedBox(height: 16),
      for (int i = 0; i < s.options.length; i++) pregToolPad(_shellOption(p, i, _fill(s.options[i]))),
      const SizedBox(height: 10),
      pregToolPad(PvCommit(
        key: const ValueKey('wc_flow_next'),
        label: _step < _count - 1 ? 'Continue' : 'See the likely cause',
        onTap: answered ? _advance : null,
      )),
    ];
  }

  // The shared answer row (2026-10-10, one MCQ look app-wide): see
  // `PvChoiceTile` in lib/widgets/pv_feedback.dart.
  Widget _shellOption(V2Palette p, int i, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PvChoiceTile(
          label: label,
          selected: _answers[_step] == i,
          onTap: () => setState(() => _answers[_step] = i),
        ),
      );

  // Kept for revert (2026-10-10): the radio-on-the-left row.
  // ignore: unused_element
  Widget _shellOptionBefore(V2Palette p, int i, String label) {
    final sel = _answers[_step] == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() => _answers[_step] = i),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sel ? kPvInk : p.line, width: sel ? 1.6 : 1),
            ),
            child: Row(children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? kPvInk : Colors.transparent,
                  border: Border.all(color: sel ? kPvInk : p.ink3, width: 1.5),
                ),
                child: sel ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                  child: Text(label,
                      style: pvManrope(
                          fontSize: 14.5, height: 1.4, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: p.ink1))),
            ]),
          ),
        ),
      ),
    );
  }

  List<Widget> _shellResult(BuildContext context, V2Palette p) {
    // The diagnosis depends on the parent's answers (red flags route to urgent
    // results); the concern's own result is the benign fallback.
    final r = wcResultFor(widget.concern, _answers);
    final urgent = r.tone == WcTone.urgent;
    final caution = r.tone == WcTone.caution;
    final tone = urgent ? const Color(0xFFB3261E) : (caution ? const Color(0xFF8A5300) : p.action);
    final label = urgent ? 'SEE A DOCTOR NOW' : (caution ? 'WORTH GETTING CHECKED' : 'MOST LIKELY CAUSE');
    final labelIcon = urgent
        ? Icons.warning_amber_rounded
        : (caution ? Icons.info_outline_rounded : Icons.lightbulb_outline_rounded);
    final body = pvManrope(fontSize: 14, height: 1.55, color: p.ink1);
    Widget row(String key, IntentMark mark, double hue, String title, String line, Widget screen) => PvListRow(
          key: ValueKey(key),
          p: p,
          leading: PvMarkWell(p: p, hue: hue, size: 40, mark: mark),
          title: title,
          line: line,
          onTap: () => _push(context, screen),
        );
    return [
      const SizedBox(height: 26),
      pregToolPad(Container(
        key: const ValueKey('wc_flow_result'),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: urgent ? tone : p.line, width: urgent ? 1.6 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(labelIcon, size: 15, color: tone),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: tone)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(_fill(r.cause),
              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
          const SizedBox(height: 8),
          Text(_fill(r.explanation), style: body),
          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Container(height: 1, color: p.line)),
          Text('What to try', style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
          const SizedBox(height: 10),
          for (int i = 0; i < r.todos.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: kPvInk, shape: BoxShape.circle),
                  child: Text('${i + 1}',
                      style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_fill(r.todos[i]), style: body)),
              ]),
            ),
        ]),
      )),

      // escalation: the route to a doctor, unchanged in target and words.
      const SizedBox(height: 16),
      pregToolPad(PvRowGroup(p: p, children: [
        row('wc_flow_escalate', IntentMark.askDoctor, 350,
            urgent ? _fill('Get {baby} seen now') : 'Still worried?',
            urgent ? 'Find a paediatrician or urgent care' : 'Talk to a paediatrician near you',
            const ProblemSolverScreen()),
      ])),

      // cross-app: what helps, gathered from across ParentVeda.
      const SizedBox(height: 26),
      pregToolPad(ppCareHeading('Everything that helps, gathered')),
      const SizedBox(height: 4),
      pregToolPad(Text('Pulled from across ParentVeda, for exactly this.',
          style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2))),
      const SizedBox(height: 12),
      pregToolPad(PvRowGroup(p: p, children: [
        row('wc_flow_phase', IntentMark.timelineRail, 285, _fill('Where {baby} is right now'), 'The phase map',
            const PhaseMapScreen()),
        row('wc_flow_community', IntentMark.cuppedHands, 20, 'Parents going through this too', 'Community',
            const CommunityScreen()),
        row('wc_flow_expert', IntentMark.askDoctor, 206, 'Talk it through with a paediatrician', 'Ask an expert',
            const ProblemSolverScreen()),
      ])),
    ];
  }

  // Kept for revert (2026-10-07): the page before the shared shell.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: EdgeInsets.only(top: 12, bottom: _showResult ? 40 : 108),
            children: [
              // header
              _pad(Row(children: [
                PvPress(child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, size: 16, color: ppInk),
                  ),
                )),
                Expanded(child: Center(child: ppEyebrow('What Changed?', color: ppMuted, spacing: 1.4))),
                if (_showResult)
                  PvPress(child: GestureDetector(
                    onTap: () => setState(() {
                      _showResult = false;
                      _step = 0;
                      for (int i = 0; i < _answers.length; i++) {
                        _answers[i] = null;
                      }
                    }),
                    child: Text('Reset', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
                  ))
                else
                  const SizedBox(width: 34),
              ])),

              // concern
              const SizedBox(height: 22),
              _pad(ppEyebrow("You're looking into", color: ppPurple, spacing: 1.2)),
              const SizedBox(height: 12),
              _pad(Text(_fill(widget.concern.quote), style: ppFraunces(26, h: 1.3))),

              // journey stepper
              const SizedBox(height: 26),
              _pad(_journey()),

              if (_showResult) ..._result(context) else ..._question(context),

              const SizedBox(height: 22),
              _pad(Text('A guided starting point, not a diagnosis. If something worries you, always check with a doctor.',
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          if (!_showResult)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg], stops: [0, 0.26]),
                ),
                child: GestureDetector(
                  onTap: _answers[_step] == null
                      ? null
                      : () => setState(() {
                            if (_step < _count - 1) {
                              _step++;
                            } else {
                              _showResult = true;
                            }
                          }),
                  child: Opacity(
                    opacity: _answers[_step] == null ? 0.4 : 1,
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))]),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(_step < _count - 1 ? 'Continue' : 'See the likely cause', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Text('→', style: TextStyle(color: Colors.white)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  // ---- journey stepper ---------------------------------------------------
  Widget _journey() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (int i = 0; i < _count; i++) ...[
          if (i > 0) _line(i),
          _node(i),
        ],
      ]);

  Widget _node(int i) {
    final done = _showResult || i < _step;
    final current = !_showResult && i == _step;
    return Expanded(
      child: Column(children: [
        Container(
          width: current ? 38 : 34,
          height: current ? 38 : 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? ppPurple : (current ? Colors.white : const Color(0xFFF0EBF5)),
            border: current ? Border.all(color: ppPurple, width: 2) : null,
            boxShadow: current ? const [BoxShadow(color: Color(0x806A30B6), blurRadius: 16, spreadRadius: -6, offset: Offset(0, 6))] : null,
          ),
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Icon(_steps[i].icon, size: current ? 16 : 14, color: current ? ppPurple : ppMuted),
        ),
        const SizedBox(height: 6),
        Text(_steps[i].category,
            style: ppBody(9, color: current || done ? ppInk : ppMuted, w: current || done ? FontWeight.w700 : FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _line(int i) {
    final done = _showResult || i <= _step;
    return Container(
      width: 12,
      height: 2,
      margin: const EdgeInsets.only(top: 16),
      color: done ? ppPurple : const Color(0xFFEAE4F0),
    );
  }

  // ---- question ----------------------------------------------------------
  List<Widget> _question(BuildContext context) {
    final s = _steps[_step];
    return [
      const SizedBox(height: 30),
      _pad(Text('Question ${_step + 1} of $_count · ${s.category}', style: ppBody(12, color: ppMuted, w: FontWeight.w600))),
      const SizedBox(height: 10),
      _pad(Text(_fill(s.prompt), style: ppFraunces(24, h: 1.25))),
      const SizedBox(height: 22),
      for (int i = 0; i < s.options.length; i++) _pad(_option(i, _fill(s.options[i]))),
    ];
  }

  Widget _option(int i, String label) {
    final sel = _answers[_step] == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: PvPress(child: GestureDetector(
        onTap: () => setState(() => _answers[_step] = i),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFFF6F0FA) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sel ? ppPurple : const Color(0xFFEFEAF2), width: sel ? 2 : 1),
            boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 16, spreadRadius: -12, offset: Offset(0, 8))],
          ),
          child: Row(children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? ppPurple : Colors.transparent,
                border: Border.all(color: sel ? ppPurple : const Color(0xFFD8C8EA), width: 2),
              ),
              child: sel ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(label, style: ppBody(15, color: ppInk, w: sel ? FontWeight.w700 : FontWeight.w400))),
          ]),
        ),
      )),
    );
  }

  // ---- result ------------------------------------------------------------
  List<Widget> _result(BuildContext context) {
    // The diagnosis now depends on the parent's answers (red flags route to
    // urgent results); the concern's own result is the benign fallback.
    final r = wcResultFor(widget.concern, _answers);
    final urgent = r.tone == WcTone.urgent;
    final caution = r.tone == WcTone.caution;
    final accent = urgent
        ? const Color(0xFFC6295A)
        : (caution ? const Color(0xFFB26A00) : ppCoral);
    final tint = urgent
        ? const Color(0xFFFDECEF)
        : (caution ? const Color(0xFFFBF1E2) : ppCoralTint);
    final cardEnd = urgent
        ? const Color(0xFFFDECEF)
        : (caution ? const Color(0xFFFBF3E8) : const Color(0xFFF6F0FA));
    final badge = urgent
        ? 'SEE A DOCTOR NOW'
        : (caution ? 'WORTH GETTING CHECKED' : 'MOST LIKELY CAUSE');
    final badgeIcon = urgent
        ? Icons.warning_amber_rounded
        : (caution ? Icons.info_outline_rounded : Icons.auto_awesome);
    return [
      const SizedBox(height: 28),
      _pad(Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: (urgent ? const Color(0xFFC6295A) : ppPurple).withValues(alpha: 0.32), blurRadius: 40, spreadRadius: -20, offset: const Offset(0, 18))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, cardEnd])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(badgeIcon, size: 12, color: accent),
                  const SizedBox(width: 6),
                  Text(badge, style: ppBody(10, color: accent, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
                ]),
              ),
              const SizedBox(height: 14),
              Text(_fill(r.cause), style: ppFraunces(24, h: 1.15)),
              const SizedBox(height: 10),
              Text(_fill(r.explanation), style: ppBody(14, h: 1.6)),
              const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: SizedBox(height: 1, child: ColoredBox(color: Color(0xFFEAE1F2)))),
              ppEyebrow('What to try', color: ppPurple, spacing: 0.8),
              const SizedBox(height: 12),
              for (int i = 0; i < r.todos.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _todo('${i + 1}', _fill(r.todos[i])),
              ],
            ]),
          ),
        ),
      )),

      // cross-app rail
      const SizedBox(height: 28),
      _pad(Text('Everything that helps, gathered', style: ppJakarta(15))),
      const SizedBox(height: 4),
      _pad(Text('Pulled from across ParentVeda, for exactly this.', style: ppBody(12, color: ppMuted))),
      const SizedBox(height: 14),
      SizedBox(
        height: 146,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            _railCard(context, Icons.timeline_rounded, 'His phase',
                _fill('Where {baby} is right now'), _lav,
                dark: true, onTap: () => _push(context, const PhaseMapScreen())),
            _railCard(context, Icons.forum_outlined, 'Community', 'Parents going through this too', ppPurple,
                onTap: () => _push(context, const CommunityScreen())),
            _railCard(context, Icons.medical_services_outlined, 'Ask an expert', 'Talk it through with a paediatrician', ppCoral,
                onTap: () => _push(context, const ProblemSolverScreen())),
          ],
        ),
      ),

      // escalation
      const SizedBox(height: 16),
      _pad(PvPress(child: GestureDetector(
        onTap: () => _push(context, const ProblemSolverScreen()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            const Icon(Icons.medical_services_outlined, size: 20, color: Color(0xFFC6295A)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(urgent ? _fill('Get {baby} seen now') : 'Still worried?', style: ppJakarta(14)),
                const SizedBox(height: 1),
                Text(urgent ? 'Find a paediatrician or urgent care' : 'Talk to a paediatrician near you', style: ppBody(12, color: const Color(0xFFC6295A))),
              ]),
            ),
            const Text('→', style: TextStyle(color: Color(0xFFC6295A))),
          ]),
        ),
      ))),
    ];
  }

  Widget _todo(String n, String t) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Color(0xFFEDE6F5), shape: BoxShape.circle),
          child: Text(n, style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
        ),
        const SizedBox(width: 11),
        Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
      ]);

  static const Color _lav = Color(0xFFB79BDD);

  Widget _railCard(BuildContext context, IconData icon, String tag, String title, Color tagColor, {bool dark = false, required VoidCallback onTap}) => PvPress(child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 150,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? ppInk : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: dark ? null : Border.all(color: const Color(0xFFEFEAF2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 20, color: dark ? Colors.white : ppPurple),
            const SizedBox(height: 10),
            Text(tag.toUpperCase(), style: ppBody(10, color: tagColor, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
            const SizedBox(height: 4),
            Text(title, style: ppJakarta(14, color: dark ? Colors.white : ppInk, w: FontWeight.w600).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ));
}

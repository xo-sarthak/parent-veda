// =============================================================================
//  RemedyDetailScreen - Nuskha · remedy detail (parenting · S19·detail)
// -----------------------------------------------------------------------------
//  A single validated home remedy, now fully DATA-DRIVEN off a [Remedy]: what it
//  is, quick facts, what you'll need, how to make it, when to use it, and - the
//  differentiator - a clear "when NOT to use, see a doctor instead" safety block,
//  the reviewing panel, related shop/read links and a labelled sponsored slot.
//  When the remedy carries a demo (massage/preparation), a striped video slot is
//  shown too. Layout is the faithful Claude Design "post pregnancy - content"
//  · S19·detail; the content is populated live from pp_nuskhe_data. Reached from
//  Nuskhe (landing search / popular rows) and the per-situation list.
//
//  Keeps a zero-arg constructor (nullable Remedy? → fallbackRemedy) so the smoke
//  test's `const RemedyDetailScreen()` still builds.
//
//  ON THE ONE PARENTVEDA LOOK (2026-10-07). The page wears the shared tool
//  shell (`PregToolScaffold`): the field, the round back, the drawn mark of
//  the situation, the remedy's name as the one serif title, and "For <the
//  situation>" as the eyebrow so she never loses what she opened it for. The
//  quick facts are `PpCareStats`, as on a recipe. Every safety section stays:
//  the age-gate line (pregnancy's amber verdict dot), "When NOT to use, see a
//  doctor instead" with its red flags and the paediatrician link, ingredients,
//  steps, when to use, and the honest "Written by our team ... Not yet
//  reviewed by a doctor" block, unchanged (key 'remedy_written_by').
//  Mobbin: Lifesum's recipe instructions, numbered steps on small grey discs
//  inside one white card (mobbin.com/screens/53bf5e52-aa94-47eb-bc76-690e8236afd9).
//  Dropped from the new build, per the parenting trust rules (no claim a real
//  review does not stand behind): the "Validated by ParentVeda's ayurvedic
//  panel" badge and "checked for safety" in the footer. The named-reviewer
//  panel stays commented out. The old build is kept below.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/can_i_entry.dart' show CanIVerdict;
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../can_i/can_i_widgets.dart' show canIVerdictColor;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../v2/v2_palette.dart';
import 'pp_care_parts.dart' show PpCareStats, ppCareHeading;
import 'pp_common.dart';
import 'pp_nuskhe_data.dart';
import 'problem_solver_screen.dart';

class RemedyDetailScreen extends StatelessWidget {
  const RemedyDetailScreen({super.key, this.remedy});

  /// Nullable so the test's zero-arg `const RemedyDetailScreen()` compiles; a
  /// null remedy falls back to the signature ajwain-potli remedy.
  final Remedy? remedy;

  static const Color _red = Color(0xFFC6295A);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  Widget _div() => _pad(const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: SizedBox(height: 1, child: ColoredBox(color: ppLine)),
      ));

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  /// The situation's drawn mark, as on the Nuskhe landing and the list.
  static IntentMark _situationMark(String name) => switch (name) {
        'Cold & cough' => IntentMark.noseMark,
        'Fever' => IntentMark.thermoMark,
        'Stomach & colic' => IntentMark.tummyMark,
        'Teething' => IntentMark.toothMark,
        'Sleep issues' => IntentMark.sleepMark,
        'Skin issues' => IntentMark.skinMark,
        _ => IntentMark.lampMark,
      };

  BoxDecoration _card(V2Palette p) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      );

  Widget _dot(Color c, {double size = 9}) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  TextStyle _body(V2Palette p) => pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1);

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final r = remedy ?? fallbackRemedy;
    final red = canIVerdictColor(CanIVerdict.avoid, p);

    return PregToolScaffold(
      hue: 140,
      eyebrow: 'For ${r.category}',
      mark: _situationMark(r.category),
      title: r.name,
      intro: r.oneLine,
      children: [
        // The age gate, before anything else, when the remedy carries one.
        if (r.isCaution) ...[
          pregToolPad(Container(
            key: const ValueKey('remedy_age_gate'),
            padding: const EdgeInsets.all(14),
            decoration: _card(p),
            child: Row(children: [
              _dot(canIVerdictColor(CanIVerdict.moderation, p)),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${r.ageWarning}. Read the cautions below first.',
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.45, color: p.ink1)),
              ),
            ]),
          )),
          const SizedBox(height: 16),
        ],
        pregToolPad(Text(r.description, style: _body(p))),
        const SizedBox(height: 18),
        pregToolPad(PpCareStats([
          (r.age, 'age'),
          (r.frequency, 'frequency'),
          (r.prepTime, 'to make'),
        ])),

        // optional demo video (massage / preparation), a seam for a player
        if (r.hasVideo) ...[
          const SizedBox(height: 26),
          pregToolPad(ppCareHeading('Watch how')),
          const SizedBox(height: 10),
          pregToolPad(Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _soon(context),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(r.videoNote ?? 'A short demo of this remedy',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.4, color: p.ink1)),
                  ),
                ]),
              ),
            ),
          )),
        ],

        // ingredients
        const SizedBox(height: 26),
        pregToolPad(ppCareHeading("You'll need")),
        const SizedBox(height: 10),
        pregToolPad(Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          decoration: _card(p),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final it in r.ingredients)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(top: 8), child: _dot(p.ink3, size: 6)),
                  const SizedBox(width: 11),
                  Expanded(child: Text(it, style: _body(p))),
                ]),
              ),
          ]),
        )),

        // preparation
        const SizedBox(height: 26),
        pregToolPad(ppCareHeading('How to make it')),
        const SizedBox(height: 10),
        pregToolPad(Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          decoration: _card(p),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (int i = 0; i < r.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.ground, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, color: p.ink1)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r.steps[i], style: _body(p))),
                ]),
              ),
          ]),
        )),

        // when to use
        const SizedBox(height: 26),
        pregToolPad(ppCareHeading('When to use it')),
        const SizedBox(height: 10),
        pregToolPad(Text(r.whenToUse, style: _body(p))),

        // when NOT to use (the differentiator): white, a red hairline, the
        // red flags and the way to a doctor.
        const SizedBox(height: 22),
        pregToolPad(Container(
          key: const ValueKey('remedy_red_flags'),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: red, width: 1.4),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: red),
              const SizedBox(width: 10),
              Expanded(
                child: Text('When NOT to use - see a doctor instead',
                    style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1)),
              ),
            ]),
            const SizedBox(height: 12),
            for (final f in r.redFlags)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(top: 3), child: Icon(Icons.close_rounded, size: 16, color: red)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f, style: _body(p))),
                ]),
              ),
            const SizedBox(height: 6),
            InkWell(
              key: const ValueKey('remedy_find_doctor'),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => const ProblemSolverScreen())),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('Find a paediatrician near you →',
                    style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)
                        .copyWith(decoration: TextDecoration.underline)),
              ),
            ),
          ]),
        )),

        // The honest line, unchanged (2026-10-07): no named reviewer we
        // cannot stand behind. The old "Reviewed & signed off by" panel stays
        // commented out in `_buildBeforeShell`.
        const SizedBox(height: 22),
        pregToolPad(Container(
          key: const ValueKey('remedy_written_by'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ppHair),
          ),
          child: Text(
              'Written by our team from published guidance. Not yet reviewed by a doctor. '
              'If your child is unwell, your paediatrician comes first.',
              style: ppBody(13, color: ppInk, h: 1.5)),
        )),

        // related (only when the remedy carries links)
        if (r.related.isNotEmpty) ...[
          const SizedBox(height: 26),
          pregToolPad(ppCareHeading('Related')),
          const SizedBox(height: 8),
          pregToolPad(PvRowGroup(p: p, children: [
            for (final l in r.related)
              PvListRow(
                p: p,
                leading: PvMarkWell(p: p, hue: 140, size: 40, icon: Icons.menu_book_outlined),
                title: l.title,
                meta: l.tag,
                onTap: () => _soon(context),
              ),
          ])),
        ],

        // sponsored (only when the remedy carries a sponsor), always labelled
        if (r.sponsor != null) ...[
          const SizedBox(height: 22),
          pregToolPad(Container(
            padding: const EdgeInsets.all(16),
            decoration: _card(p),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SPONSORED',
                  style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.ink3)),
              const SizedBox(height: 10),
              Text(r.sponsor!.title,
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3, color: p.ink1)),
              const SizedBox(height: 3),
              Text(r.sponsor!.subtitle, style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2)),
            ]),
          )),
        ],

        const SizedBox(height: 22),
        pregToolPad(Text(
            'Traditional wisdom, not medical advice. A nuskha is never a substitute for a doctor when the red flags above appear.',
            style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2))),
        const SizedBox(height: 24),
      ],
    );
  }

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    final r = remedy ?? fallbackRemedy;

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            // breadcrumb
            _pad(Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Text('Nuskhe', style: ppBody(12, color: ppPurple, w: FontWeight.w600)),
              ),
              const SizedBox(width: 6),
              const Text('›', style: TextStyle(color: Color(0xFFC7BBD6))),
              const SizedBox(width: 6),
              Flexible(
                  child: Text(r.category,
                      style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ])),

            // hero
            const SizedBox(height: 16),
            _pad(ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 200,
                child: Stack(children: [
                  const PpStriped(height: 200, radius: 22, border: true),
                  Positioned.fill(child: Center(child: Icon(r.icon, size: 46, color: ppPurple))),
                ]),
              ),
            )),

            // badge + title
            const SizedBox(height: 18),
            _pad(Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check, size: 13, color: ppBrown),
                  const SizedBox(width: 6),
                  Flexible(
                      child: Text("Validated by ParentVeda's ayurvedic panel",
                          style: ppBody(11, color: ppBrown, w: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                ]),
              ),
            )),
            const SizedBox(height: 12),
            // Which concern this remedy is FOR, right beside its name. Scroll a
            // little way into a nuskha and it is easy to lose track of what you
            // opened it for in the first place.
            _pad(Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                child: Text('For ${r.category}',
                    style: ppBody(11, color: ppPurple, w: FontWeight.w700),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ])),
            const SizedBox(height: 9),
            _pad(Text(r.name, style: ppFraunces(29, h: 1.15))),

            // age-gate caution (only when the remedy is age-restricted)
            if (r.isCaution) ...[
              const SizedBox(height: 12),
              _pad(Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.warning_amber_rounded, size: 13, color: ppCoral),
                    const SizedBox(width: 6),
                    Flexible(
                        child: Text(r.ageWarning!,
                            style: ppBody(11, color: ppCoral, w: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              )),
            ],

            const SizedBox(height: 10),
            _pad(Text(r.description, style: ppBody(14, h: 1.6))),

            // quick facts
            const SizedBox(height: 18),
            _pad(Row(children: [
              _fact(r.age, 'age'),
              const SizedBox(width: 10),
              _fact(r.frequency, 'frequency'),
              const SizedBox(width: 10),
              _fact(r.prepTime, 'to make'),
            ])),

            // optional demo video (massage / preparation) - striped placeholder
            if (r.hasVideo) ...[
              _div(),
              _pad(Text('Watch how', style: ppJakarta(16))),
              const SizedBox(height: 12),
              _pad(_VideoSlot(note: r.videoNote ?? 'A short demo of this remedy', onTap: () => _soon(context))),
            ],

            _div(),

            // ingredients
            _pad(Text("You'll need", style: ppJakarta(16))),
            const SizedBox(height: 12),
            _pad(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final it in r.ingredients) _bullet(it)],
            )),

            _div(),

            // preparation
            _pad(Text('How to make it', style: ppJakarta(16))),
            const SizedBox(height: 6),
            _pad(Column(children: [
              for (int i = 0; i < r.steps.length; i++)
                _step((i + 1).toString().padLeft(2, '0'), r.steps[i], top: true, bottom: i == r.steps.length - 1),
            ])),

            _div(),

            // when to use
            _pad(Text('When to use it', style: ppJakarta(16))),
            const SizedBox(height: 10),
            _pad(Text(r.whenToUse, style: ppBody(14, color: ppInk, h: 1.6))),

            // when NOT to use (the differentiator)
            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: ppCoralTint,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD9E1))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: _red),
                  const SizedBox(width: 8),
                  Flexible(
                      child: Text('When NOT to use - see a doctor instead',
                          style: ppJakarta(15, color: _red), maxLines: 2)),
                ]),
                const SizedBox(height: 12),
                for (final f in r.redFlags) _dont(f),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => const ProblemSolverScreen())),
                  child: Text('Find a paediatrician near you →', style: ppBody(13, color: _red, w: FontWeight.w700)),
                ),
              ]),
            )),

            _div(),

            // ⚠️ NO NAMED REVIEWER WE CANNOT STAND BEHIND (2026-10-07, the
            // parenting trust rules: no made-up reviewers). Every remedy showed
            // "Reviewed & signed off by" one of three named BAMS doctors with
            // avatars, and nothing records that they reviewed anything. The
            // honest line until a real reviewer signs off. The old panel, kept
            // for revert:
            // // reviewed by
            // _pad(Container(
            // padding: const EdgeInsets.all(20),
            // decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
            // child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ppEyebrow('Reviewed & signed off by', color: ppPurple, spacing: 0.8),
            // const SizedBox(height: 12),
            // Row(children: [
            // SizedBox(
            // width: 58,
            // height: 34,
            // child: Stack(children: [
            // _avatar(0),
            // _avatar(12),
            // _avatar(24),
            // ]),
            // ),
            // const SizedBox(width: 12),
            // Expanded(
            // child: Text.rich(
            // TextSpan(children: [
            // TextSpan(text: r.reviewer.lead, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            // TextSpan(text: r.reviewer.note),
            // ]),
            // style: ppBody(13, color: ppInk, h: 1.5)),
            // ),
            // ]),
            // ]),
            // )),
            _pad(Container(
              key: const ValueKey('remedy_written_by'),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ppHair),
              ),
              child: Text(
                  'Written by our team from published guidance. Not yet reviewed by a doctor. '
                  'If your child is unwell, your paediatrician comes first.',
                  style: ppBody(13, color: ppInk, h: 1.5)),
            )),

            // related (only when the remedy carries links)
            if (r.related.isNotEmpty) ...[
              _div(),
              _pad(Text('Related', style: ppJakarta(16))),
              const SizedBox(height: 14),
              for (int i = 0; i < r.related.length; i++)
                _pad(_related(context, r.related[i].tag, r.related[i].title,
                    top: true, bottom: i == r.related.length - 1)),
            ],

            // sponsored (only when the remedy carries a sponsor)
            if (r.sponsor != null) ...[
              const SizedBox(height: 22),
              _pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFECE5F2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow('Sponsored', color: ppMuted, spacing: 0.8),
                  const SizedBox(height: 12),
                  Row(children: [
                    const PpStriped(height: 52, width: 52, radius: 16, border: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.sponsor!.title, style: ppJakarta(15).copyWith(height: 1.25)),
                        const SizedBox(height: 3),
                        Text(r.sponsor!.subtitle, style: ppBody(12)),
                      ]),
                    ),
                  ]),
                ]),
              )),
            ],

            const SizedBox(height: 22),
            _pad(Text(
                'Traditional wisdom, checked for safety - not medical advice. A nuskha is never a substitute for a doctor when the red flags above appear.',
                textAlign: TextAlign.center,
                style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _fact(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(value, style: ppJakarta(14), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: ppBody(11, color: ppMuted)),
          ]),
        ),
      );

  Widget _bullet(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: ppBrown, shape: BoxShape.circle),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );

  Widget _step(String n, String text, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n, style: ppBody(14, color: ppBrown, w: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );

  Widget _dont(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.close_rounded, size: 15, color: ppCoral),
          const SizedBox(width: 10),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );

  // Kept for revert with the reviewer panel (2026-10-07).
  // ignore: unused_element
  Widget _avatar(double left) => Positioned(
        left: left,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppPanel, width: 2)),
          clipBehavior: Clip.antiAlias,
          child: const PpStriped(height: 38, colorA: ppBorder, colorB: ppStripeB),
        ),
      );

  Widget _related(BuildContext context, String tag, String title, {bool top = false, bool bottom = false}) =>
      GestureDetector(
        onTap: () => _soon(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
            ),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
              child: Text(tag, style: ppBody(10, color: ppPurple, w: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: ppBody(14, color: ppInk, h: 1.4))),
            const SizedBox(width: 8),
            const Text('→', style: TextStyle(color: ppMuted)),
          ]),
        ),
      );
}

/// A demo-video seam: a striped placeholder with a play button. VIDEO ON HOLD -
/// this is the single clean call-site; wire a real player here later.
class _VideoSlot extends StatelessWidget {
  const _VideoSlot({required this.note, required this.onTap});
  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 168,
            child: Stack(children: [
              const PpStriped(height: 168, radius: 20, border: true),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x226A30B6), blurRadius: 18, offset: Offset(0, 8))],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, size: 30, color: ppPurple),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Text(note,
                    style: ppBody(12, color: ppInk, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
        ),
      );
}

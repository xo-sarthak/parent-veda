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
// =============================================================================

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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

            // reviewed by
            _pad(Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Reviewed & signed off by', color: ppPurple, spacing: 0.8),
                const SizedBox(height: 12),
                Row(children: [
                  SizedBox(
                    width: 58,
                    height: 34,
                    child: Stack(children: [
                      _avatar(0),
                      _avatar(12),
                      _avatar(24),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: r.reviewer.lead, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                          TextSpan(text: r.reviewer.note),
                        ]),
                        style: ppBody(13, color: ppInk, h: 1.5)),
                  ),
                ]),
              ]),
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

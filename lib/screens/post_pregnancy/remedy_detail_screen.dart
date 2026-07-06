// =============================================================================
//  RemedyDetailScreen — Nuskha · remedy detail (parenting · S19·detail)
// -----------------------------------------------------------------------------
//  A single validated home remedy: what it is, quick facts, what you'll need,
//  how to make it, when to use it, and — the differentiator — a clear "when NOT
//  to use, see a doctor instead" safety block, the reviewing panel, related
//  shop/read links and a labelled sponsored slot. Faithful build of Claude
//  Design "post pregnancy - content.dc.html" · S19·detail. Reached from Nuskhe.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'problem_solver_screen.dart';

class RemedyDetailScreen extends StatelessWidget {
  const RemedyDetailScreen({super.key, this.category = 'Cold & cough'});
  final String category;

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
              Flexible(child: Text(category, style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ])),

            // hero
            const SizedBox(height: 16),
            _pad(ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: const SizedBox(
                height: 200,
                child: Stack(children: [
                  PpStriped(height: 200, radius: 22, border: true),
                  Positioned.fill(child: Center(child: Icon(Icons.eco_outlined, size: 46, color: ppPurple))),
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
                          style: ppBody(11, color: ppBrown, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ),
            )),
            const SizedBox(height: 12),
            _pad(Text('Ajwain potli for a blocked nose', style: ppFraunces(29, h: 1.15))),
            const SizedBox(height: 10),
            _pad(Text(
                'A warm carom-seed compress that eases congestion and helps a stuffy baby breathe and feed. Preventive and soothing — never applied to skin directly.',
                style: ppBody(14, h: 1.6))),

            // quick facts
            const SizedBox(height: 18),
            _pad(Row(children: [
              _fact('0+ mo', 'age'),
              const SizedBox(width: 10),
              _fact('2×/day', 'frequency'),
              const SizedBox(width: 10),
              _fact('5 min', 'to make'),
            ])),

            _div(),

            // ingredients
            _pad(Text("You'll need", style: ppJakarta(16))),
            const SizedBox(height: 12),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _bullet('2 tbsp ajwain (carom seeds)'),
              _bullet('A clean, soft muslin cloth'),
              _bullet('A flat tawa to dry-roast'),
            ])),

            _div(),

            // preparation
            _pad(Text('How to make it', style: ppJakarta(16))),
            const SizedBox(height: 6),
            _pad(Column(children: [
              _step('01', 'Dry-roast the ajwain on a tawa until fragrant, 1–2 minutes.', top: true),
              _step('02', 'Tie it into the muslin cloth to make a small potli.', top: true),
              _step('03', "Test on your own wrist first, then rest it near (not on) baby's chest and feet.",
                  top: true, bottom: true),
            ])),

            _div(),

            // when to use
            _pad(Text('When to use it', style: ppJakarta(16))),
            const SizedBox(height: 10),
            _pad(Text(
                'At the first signs of a stuffy nose or mild cold, especially before naps and feeds when congestion makes it hardest for baby to settle.',
                style: ppBody(14, color: ppInk, h: 1.6))),

            // when NOT to use (the differentiator)
            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: ppCoralTint, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFD9E1))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: _red),
                  const SizedBox(width: 8),
                  Flexible(child: Text('When NOT to use — see a doctor instead', style: ppJakarta(15, color: _red), maxLines: 2)),
                ]),
                const SizedBox(height: 12),
                _dont('Fever above 100.4°F (38°C) in a baby under 3 months.'),
                _dont('Fast, laboured, or wheezy breathing.'),
                _dont('Never place the hot potli directly on skin — warm only.'),
                _dont('Cold lasting beyond 5 days, or a baby refusing feeds.'),
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
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: 'Dr. Kamala Iyer (BAMS)', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                      const TextSpan(text: ' & 4 practitioners, cross-checked by an MBBS paediatrician.'),
                    ]), style: ppBody(13, color: ppInk, h: 1.5)),
                  ),
                ]),
              ]),
            )),

            _div(),

            // related
            _pad(Text('Related', style: ppJakarta(16))),
            const SizedBox(height: 14),
            _pad(_related(context, 'Shop', 'Buy organic ajwain — 24 Mantra', top: true)),
            _pad(_related(context, 'Read', 'Baby colds: what actually helps', top: true, bottom: true)),

            // sponsored
            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE5F2))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Sponsored', color: ppMuted, spacing: 0.8),
                const SizedBox(height: 12),
                Row(children: [
                  const PpStriped(height: 52, width: 52, radius: 16, border: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Organic India · whole-seed ajwain', style: ppJakarta(15).copyWith(height: 1.25)),
                      const SizedBox(height: 3),
                      Text('Single-origin, lab-tested purity.', style: ppBody(12)),
                    ]),
                  ),
                ]),
              ]),
            )),

            const SizedBox(height: 22),
            _pad(Text('Traditional wisdom, checked for safety. A nuskha is never a substitute for a doctor when the red flags above appear.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
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

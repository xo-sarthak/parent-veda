// =============================================================================
//  CourseFunnelScreen - Courses · full page (parenting)
// -----------------------------------------------------------------------------
//  The sales/detail page for the flagship documentary course (The Complete
//  Parenting Guide). Unlike a masterclass or cohort, a course is a big evergreen
//  curriculum - so this page leads with "what you'll learn" and a Udemy-style
//  expandable syllabus (stages → modules), then how it's made, reviews, a
//  guarantee row, an FAQ, and a sticky "Get the course" bar. Net-new page (no
//  Claude Design frame). Reached from Courses → the flagship.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class CourseFunnelScreen extends StatefulWidget {
  const CourseFunnelScreen({super.key});

  @override
  State<CourseFunnelScreen> createState() => _CourseFunnelScreenState();
}

class _CourseFunnelScreenState extends State<CourseFunnelScreen> {
  final Set<String> _openSections = {'46'}; // current stage expanded
  int _openFaq = 0;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  static const List<String> _learn = [
    "Read your baby's development, stage by stage",
    'Handle sleep, feeding and fussiness with real confidence',
    'Tell a normal phase from a genuine red flag',
    'Build language, play and secure attachment early',
    'Prepare for each milestone before it arrives',
  ];

  // (id, stage, modules-count/duration, isNow, [module rows: (title, meta, locked)])
  static const List<(String, String, String, bool, List<(String, String, bool)>)> _sections = [
    ('03', 'Pregnancy & newborn · 0–3 months', '18 modules · 3h 20m', false, []),
    ('46', '4–6 months', '22 modules · 4h 05m', true, [
      ('The 4-month brain', '18 min · playing now', false),
      ('Surviving the sleep regression', '22 min', false),
      ('Reaching, rolling and first grasps', '15 min', false),
      ('First solids - a preview', 'Unlocks at 6 months · open anyway', true),
    ]),
    ('612', '6–12 months', '24 modules · 4h 40m', false, []),
    ('12', 'Toddler · 1–2 years', '20 modules · 3h 30m', false, []),
    ('25', 'Preschool · 2–5 years', '30 modules · 5h 10m', false, []),
    ('512', 'Big kid · 5–12 years', '40 modules · 7h 20m', false, []),
  ];

  static const List<List<String>> _faqs = [
    ['Is it self-paced?', 'Completely. Watch on your schedule - the course remembers exactly where you left off.'],
    ["What does 'stage-personalised' mean?", "You see the modules for your child's age first; earlier and later stages are always one tap away."],
    ['Do I keep it forever?', 'Yes - one payment, lifetime access. It keeps growing as your child does, at no extra cost.'],
    ['Can I get a refund?', "There's a 7-day money-back guarantee, no questions asked."],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 120),
            children: [
              _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ppBack(context, 'Courses'),
                ppLangToggle(),
              ])),

              // hero
              const SizedBox(height: 18),
              _pad(GestureDetector(
                onTap: () => _soon(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(children: [
                    const PpStriped(height: 200, radius: 22, border: true),
                    const Positioned.fill(child: Center(child: _PlayDisc(56))),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                        child: Text('Preview the course', style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              )),

              // badges + title
              const SizedBox(height: 20),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999)),
                  child: Text('Flagship', style: ppBody(11, color: Colors.white, w: FontWeight.w700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFEAF6EF), borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_rounded, size: 12, color: Color(0xFF1F8A5B)),
                    const SizedBox(width: 5),
                    Text('Expert-vetted', style: ppBody(11, color: const Color(0xFF1F8A5B), w: FontWeight.w700)),
                  ]),
                ),
              ])),
              const SizedBox(height: 12),
              _pad(Text('The Complete Parenting Guide', style: ppFraunces(30, h: 1.14))),
              const SizedBox(height: 10),
              _pad(Text(
                  'Pregnancy through age 12 - every stage, taught properly, once. A documentary-style course that unlocks as your child grows and stays yours for life.',
                  style: ppBody(15))),

              // quick facts
              const SizedBox(height: 20),
              _pad(Row(children: [
                _fact('140+', 'modules'),
                const SizedBox(width: 10),
                _fact('Stage', 'personalised'),
                const SizedBox(width: 10),
                _fact('∞', 'lifetime access'),
              ])),

              // what you'll learn
              const SizedBox(height: 28),
              _pad(Text("What you'll learn", style: ppJakarta(18))),
              const SizedBox(height: 12),
              _pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
                child: Column(children: [
                  for (int i = 0; i < _learn.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == _learn.length - 1 ? 0 : 11),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.check_rounded, size: 18, color: ppPurple),
                        const SizedBox(width: 11),
                        Expanded(child: Text(_learn[i], style: ppBody(14, color: ppInk, h: 1.45))),
                      ]),
                    ),
                ]),
              )),

              // curriculum
              const SizedBox(height: 28),
              _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Course content', style: ppJakarta(18)),
                Text('6 stages · 140+ modules', style: ppBody(12, color: ppMuted)),
              ])),
              const SizedBox(height: 12),
              _pad(Column(children: [for (final s in _sections) _section(context, s)])),

              // how it's made
              const SizedBox(height: 26),
              _pad(Text("How it's made", style: ppJakarta(18))),
              const SizedBox(height: 12),
              _pad(Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.movie_outlined, size: 18, color: ppPurple),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                        "Told through ParentVeda's own animated guides - scripted from research and approved by paediatricians & child psychologists before anything reaches you.",
                        style: ppBody(13, color: ppInk, h: 1.5)),
                  ),
                ]),
              )),

              // reviews
              const SizedBox(height: 26),
              _pad(Row(children: [
                Text('★ 4.9', style: ppBody(15, color: ppCoral, w: FontWeight.w700)),
                const SizedBox(width: 8),
                Text('1,240 parents', style: ppBody(13, color: ppMuted)),
              ])),
              const SizedBox(height: 12),
              _pad(Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE5F2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('★★★★★', style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('“The only parenting content I actually kept coming back to. It grows with my daughter - I open it at every new stage.”',
                      style: ppBody(15, color: ppInk, h: 1.55)),
                  const SizedBox(height: 10),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'Ritika S. ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                    TextSpan(text: '· mother of a 2-year-old', style: ppBody(13, color: ppMuted)),
                  ])),
                ]),
              )),

              // guarantee
              const SizedBox(height: 28),
              _pad(ppEyebrow('The ParentVeda promise', color: ppBrown, spacing: 0.8)),
              const SizedBox(height: 16),
              _pad(ppGuaranteeRow()),

              // faq
              const SizedBox(height: 30),
              _pad(Text('Common questions', style: ppJakarta(18))),
              const SizedBox(height: 6),
              _pad(Column(children: [
                for (int i = 0; i < _faqs.length; i++) _faq(i, _faqs[i][0], _faqs[i][1]),
              ])),

              const SizedBox(height: 22),
              _pad(Text('One course, the whole journey. You only see what fits your child now - everything else waits, one tap away.',
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          Positioned(left: 0, right: 0, bottom: 0, child: _ctaBar(context)),
        ]),
      ),
    );
  }

  Widget _fact(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: ppBody(11, color: ppMuted)),
          ]),
        ),
      );

  Widget _section(BuildContext context, (String, String, String, bool, List<(String, String, bool)>) s) {
    final open = _openSections.contains(s.$1);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: ppBorder)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => open ? _openSections.remove(s.$1) : _openSections.add(s.$1)),
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(s.$2, style: ppBody(15, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (s.$4) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(999)),
                        child: Text('Now', style: ppBody(9, color: ppCoral, w: FontWeight.w700)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(s.$3, style: ppBody(12, color: ppMuted)),
                ]),
              ),
              const SizedBox(width: 10),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 160),
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: ppMuted),
              ),
            ]),
          ),
        ),
        if (open && s.$5.isNotEmpty)
          Container(
            color: ppBg,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(children: [for (final m in s.$5) _module(context, m)]),
          ),
      ]),
    );
  }

  Widget _module(BuildContext context, (String, String, bool) m) => GestureDetector(
        onTap: () => _soon(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(m.$3 ? Icons.lock_outline_rounded : Icons.play_arrow_rounded, size: 16, color: m.$3 ? ppMuted : ppPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.$1, style: ppBody(13, color: ppInk, w: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(m.$2, style: ppBody(11, color: ppMuted)),
              ]),
            ),
          ]),
        ),
      );

  Widget _faq(int i, String q, String a) {
    final open = _openFaq == i;
    return GestureDetector(
      onTap: () => setState(() => _openFaq = open ? -1 : i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(q, style: ppBody(14, color: ppInk, w: FontWeight.w700))),
            const SizedBox(width: 10),
            Icon(open ? Icons.remove : Icons.add, size: 18, color: ppMuted),
          ]),
          if (open) ...[const SizedBox(height: 8), Text(a, style: ppBody(13, h: 1.55))],
        ]),
      ),
    );
  }

  Widget _ctaBar(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg], stops: [0, 0.22]),
        ),
        child: Row(children: [
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('₹4,999', style: ppBody(16, color: ppInk, w: FontWeight.w700)),
            Text('free on ParentVeda+', style: ppBody(11, color: ppPurple, w: FontWeight.w600)),
          ]),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                child: Text('Get the course', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
              ),
            ),
          ),
        ]),
      );
}

class _PlayDisc extends StatelessWidget {
  const _PlayDisc(this.size);
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
        child: Icon(Icons.play_arrow_rounded, color: ppPurple, size: size * 0.5),
      );
}

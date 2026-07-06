// =============================================================================
//  WhatChangedScreen — Tools · "What Changed?" diagnostic (parenting · S22a v2)
// -----------------------------------------------------------------------------
//  A ParentVeda original: something suddenly different with the baby? A guided
//  5-step questionnaire (Diet · Sleep · Home · Illness · Mood), shown as an
//  elegant "journey", lands on a likely cause + what-to-do, then a cross-app
//  rail of everything that helps. Functional build of Claude Design "post
//  pregnancy - content.dc.html" · S22a v2 (premium); the intervening questions
//  are ParentVeda-authored. Reached from the Tools hub.
// =============================================================================

import 'package:flutter/material.dart';

import 'article_reader_screen.dart';
import 'pp_common.dart';
import 'problem_solver_screen.dart';
import 'product_detail_screen.dart';
import 'remedy_detail_screen.dart';
import 'wonder_week_screen.dart';

class WhatChangedScreen extends StatefulWidget {
  const WhatChangedScreen({super.key});

  @override
  State<WhatChangedScreen> createState() => _WhatChangedScreenState();
}

class _WhatChangedScreenState extends State<WhatChangedScreen> {
  int _step = 0;
  bool _showResult = false;
  final List<int?> _answers = List<int?>.filled(5, null);

  static const List<(String, IconData, String, List<String>)> _steps = [
    ('Diet', Icons.restaurant_outlined, 'Any recent change to feeds or new foods?', ['Yes — a new food or formula', 'Weaning or dropping a feed', "No, feeding's the same"]),
    ('Sleep', Icons.bedtime_outlined, 'Has his sleep routine or schedule shifted?', ['Yes — travel or a new routine', 'Naps got shorter or longer', "No, the routine's the same"]),
    ('Home', Icons.home_outlined, 'Anything different at home lately?', ['Yes — travel, guests, or a move', 'A room or temperature change', "No, nothing's changed"]),
    ('Illness', Icons.medical_services_outlined, 'Any recent signs of a cold, fever, or teething?', ['Yes — a runny nose or cough', 'Drooling, hands in mouth', 'No — he seems physically well']),
    ('Mood', Icons.favorite_border, 'More clingy, fussy, or seeking you out?', ['Yes — much clingier than usual', 'A bit, on and off', "No, he's his usual self"]),
  ];

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
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
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, size: 16, color: ppInk),
                  ),
                ),
                Expanded(child: Center(child: ppEyebrow('What Changed?', color: ppMuted, spacing: 1.4))),
                if (_showResult)
                  GestureDetector(
                    onTap: () => setState(() {
                      _showResult = false;
                      _step = 0;
                      for (int i = 0; i < _answers.length; i++) {
                        _answers[i] = null;
                      }
                    }),
                    child: Text('Reset', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
                  )
                else
                  const SizedBox(width: 34),
              ])),

              // concern
              const SizedBox(height: 22),
              _pad(ppEyebrow("You're looking into", color: ppPurple, spacing: 1.2)),
              const SizedBox(height: 12),
              _pad(Text.rich(TextSpan(children: [
                const TextSpan(text: '“Aarav suddenly wakes every '),
                TextSpan(text: '2 hours', style: ppFraunces(27, color: ppPurple, h: 1.28)),
                const TextSpan(text: ' at night.”'),
              ]), style: ppFraunces(27, h: 1.28))),

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
                            if (_step < 4) {
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
                        Text(_step < 4 ? 'Continue' : "See Aarav's answer", style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
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
        for (int i = 0; i < _steps.length; i++) ...[
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
              : Icon(_steps[i].$2, size: current ? 16 : 14, color: current ? ppPurple : ppMuted),
        ),
        const SizedBox(height: 6),
        Text(_steps[i].$1,
            style: ppBody(9, color: current || done ? ppInk : ppMuted, w: current || done ? FontWeight.w700 : FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _line(int i) {
    final done = _showResult || i <= _step; // segment before node i is "reached" if we've passed i-1
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
      _pad(Text('Question ${_step + 1} of 5 · ${s.$1}', style: ppBody(12, color: ppMuted, w: FontWeight.w600))),
      const SizedBox(height: 10),
      _pad(Text(s.$3, style: ppFraunces(25, h: 1.25))),
      const SizedBox(height: 22),
      for (int i = 0; i < s.$4.length; i++) _pad(_option(i, s.$4[i])),
    ];
  }

  Widget _option(int i, String label) {
    final sel = _answers[_step] == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: GestureDetector(
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
      ),
    );
  }

  // ---- result ------------------------------------------------------------
  List<Widget> _result(BuildContext context) => [
        const SizedBox(height: 28),
        _pad(Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x736A30B6), blurRadius: 40, spreadRadius: -20, offset: Offset(0, 18))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Color(0xFFF6F0FA)])),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_awesome, size: 12, color: ppCoral),
                    const SizedBox(width: 6),
                    Text('MOST LIKELY CAUSE', style: ppBody(10, color: ppCoral, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
                  ]),
                ),
                const SizedBox(height: 14),
                Text('The 4-month sleep regression', style: ppFraunces(24, h: 1.15)),
                const SizedBox(height: 10),
                Text('Sleep and development shifted together, with no physical cause — the classic Leap 4 pattern.',
                    style: ppBody(14, h: 1.6)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: SizedBox(height: 1, child: ColoredBox(color: Color(0xFFEAE1F2)))),
                ppEyebrow('What to do tonight', color: ppPurple, spacing: 0.8),
                const SizedBox(height: 12),
                _todo('1', 'Hold a steady wind-down; put down drowsy but awake.'),
                const SizedBox(height: 10),
                _todo('2', "Practise rolling in the daytime, so it's rehearsed by night."),
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
          height: 134,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _railCard(context, Icons.brightness_4_outlined, 'Wonder Week', "Aarav's Leap 4 window", _lav, dark: true, onTap: () => _push(context, const WonderWeekScreen())),
              _railCard(context, Icons.eco_outlined, 'Nuskha', 'Nutmeg for restful sleep', ppBrown, onTap: () => _push(context, const RemedyDetailScreen())),
              _railCard(context, Icons.menu_book_outlined, 'Article', 'Why sleep cycles change at 4 months', ppPurple, onTap: () => _push(context, const ArticleReaderScreen())),
              _railCard(context, Icons.volume_up_outlined, 'Product', 'White-noise soother', ppPurple, onTap: () => _push(context, const ProductDetailScreen())),
            ],
          ),
        ),

        // escalation
        const SizedBox(height: 16),
        _pad(GestureDetector(
          onTap: () => _push(context, const ProblemSolverScreen()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              const Icon(Icons.medical_services_outlined, size: 20, color: Color(0xFFC6295A)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Still worried?', style: ppJakarta(14)),
                  const SizedBox(height: 1),
                  Text('Talk to a paediatrician near you', style: ppBody(12, color: const Color(0xFFC6295A))),
                ]),
              ),
              const Text('→', style: TextStyle(color: Color(0xFFC6295A))),
            ]),
          ),
        )),
      ];

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

  Widget _railCard(BuildContext context, IconData icon, String tag, String title, Color tagColor, {bool dark = false, required VoidCallback onTap}) => GestureDetector(
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
      );
}

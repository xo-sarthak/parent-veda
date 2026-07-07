// =============================================================================
//  InvestmentsScreen - Investments & Savings · goal-led (parenting · S21)
// -----------------------------------------------------------------------------
//  A goal-led savings surface: set a target for Aarav's future and the card
//  computes the monthly SIP needed; browse vetted ways to get there, a
//  learn-as-you-go strip, how-it-works, and the mandatory not-an-advisor
//  disclaimers. Faithful build of Claude Design "post pregnancy - commerce.dc.html"
//  · S21. Reached from the Explore drawer. ParentVeda never touches your money.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pp_common.dart';

const Color _lav = Color(0xFFB79BDD);
const Color _dividerDark = Color(0xFF45414A);
const Color _importantBg = Color(0xFFF0EBF5);

// goal fill options
const List<(String, int)> _amounts = [
  ('₹40 lakh', 4000000),
  ('₹75 lakh', 7500000),
  ('₹1 crore', 10000000),
  ('₹25 lakh', 2500000),
];
const List<(String, int)> _horizons = [
  ('17 years', 17),
  ('21 years', 21),
  ('10 years', 10),
  ('5 years', 5),
];

// (rail label, icon, purpose phrase used in the sentence)
const List<(String, IconData, String)> _goals = [
  ('Education', Icons.school_outlined, 'higher education'),
  ('Marriage', Icons.diamond_outlined, 'marriage'),
  ('Emergency fund', Icons.shield_outlined, 'a safety net'),
  ('First home', Icons.home_outlined, 'a first home'),
];

// (icon, title, desc, risk pill, risk color, extra note)
const List<(IconData, String, String, String, Color, String?)> _ways = [
  (Icons.trending_up_rounded, 'Monthly SIP in mutual funds', 'Grows with the market over the long run.', 'Higher growth · higher risk', ppBrown, null),
  (Icons.local_florist_outlined, 'Sukanya Samriddhi Yojana', "Govt-backed, for a daughter's future.", 'Very safe · fixed rate', ppPurple, 'girls only'),
  (Icons.paid_outlined, 'Digital gold', 'A familiar hedge, in small amounts.', 'Moderate · flexible', ppBrown, null),
  (Icons.school_outlined, 'Education-specific plans', 'Instruments built around a study goal.', 'Goal-locked', ppPurple, null),
];

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  int _amount = 0;
  int _horizon = 0;
  int _goal = 0;

  final GlobalKey _waysKey = GlobalKey();

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );

  // Required monthly contribution for the target (ordinary-annuity FV at an
  // assumed 11% p.a.), rounded to the nearest ₹100. Illustration only.
  int _monthly() {
    final target = _amounts[_amount].$2.toDouble();
    final years = _horizons[_horizon].$2;
    const i = 0.11 / 12;
    final n = years * 12;
    final factor = (math.pow(1 + i, n) - 1) / i;
    final p = target / factor;
    return (p / 100).round() * 100;
  }

  String _inr(int n) {
    var s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 40),
        children: [
          _pad(ppBack(context, 'Explore')),

          const SizedBox(height: 22),
          _pad(ppEyebrow('Plan ahead for Aarav', color: ppBrown, spacing: 1.4)),
          const SizedBox(height: 10),
          _pad(Text('Start small, for a big day.', style: ppFraunces(32, h: 1.12))),
          const SizedBox(height: 12),
          _pad(Text(
              "Set a goal for Aarav's future and we'll explain the ways to get there - in plain language, with vetted partners. You stay in control of every rupee.",
              style: ppBody(15))),

          // goal-led entry (dark card)
          const SizedBox(height: 22),
          _pad(_goalCard()),

          // goal rail
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _goals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (_, i) => _goalChip(i),
            ),
          ),

          // ways to get there
          const SizedBox(height: 28),
          _pad(Container(key: _waysKey, alignment: Alignment.centerLeft, child: Text('Ways to get there', style: ppJakarta(18)))),
          const SizedBox(height: 6),
          _pad(Text('Each vetted by ParentVeda for legitimacy. Tap to learn how it works.', style: ppBody(12))),
          const SizedBox(height: 8),
          _pad(Column(children: [
            for (var i = 0; i < _ways.length; i++) _wayRow(_ways[i], last: i == _ways.length - 1),
          ])),

          // learn as you go
          const SizedBox(height: 24),
          _pad(_learnCard()),

          // how it works
          const SizedBox(height: 22),
          _pad(Row(children: [
            _howTile(Icons.gps_fixed, 'Set a goal'),
            const SizedBox(width: 12),
            _howTile(Icons.menu_book_outlined, 'Understand options'),
            const SizedBox(width: 12),
            _howTile(Icons.link_rounded, 'Invest via partner'),
          ])),
          const SizedBox(height: 12),
          _pad(Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Execution happens on a vetted partner platform - ', style: ppBody(12, h: 1.55)),
              TextSpan(text: 'they', style: ppBody(12, color: ppInk, w: FontWeight.w700, h: 1.55)),
              TextSpan(text: ' handle KYC and your money. ParentVeda never touches it.', style: ppBody(12, h: 1.55)),
            ]),
            textAlign: TextAlign.center,
          )),

          // important disclaimer
          const SizedBox(height: 22),
          _pad(Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(color: _importantBg, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow('Important', color: ppSoft, spacing: 0.6),
              const SizedBox(height: 7),
              Text.rich(TextSpan(children: [
                TextSpan(text: 'ParentVeda is ', style: ppBody(12, h: 1.6)),
                TextSpan(text: 'not a SEBI-registered investment advisor', style: ppBody(12, color: ppInk, w: FontWeight.w700, h: 1.6)),
                TextSpan(
                    text: ' and does not provide financial advice. We curate and explain options for your awareness only; every decision is yours. Investments carry risk, including possible loss of capital. Please consult a qualified advisor before investing.',
                    style: ppBody(12, h: 1.6)),
              ])),
            ]),
          )),

          const SizedBox(height: 18),
          _pad(Text('We earn a referral fee from partner platforms - it never changes your returns or your cost.',
              textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
        ],
      ),
    );
  }

  // ---- goal card -------------------------------------------------------------
  Widget _goalCard() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: ppInk, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Set a goal'.toUpperCase(), style: ppBody(10, color: _lav, w: FontWeight.w700).copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 14),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              Text('I want ', style: ppFraunces(20, color: Colors.white, h: 1.5)),
              _fill(_amounts[_amount].$1, () => setState(() => _amount = (_amount + 1) % _amounts.length)),
              Text(" for Aarav's ", style: ppFraunces(20, color: Colors.white, h: 1.5)),
              _fill(_goals[_goal].$3, () => setState(() => _goal = (_goal + 1) % _goals.length)),
              Text(' in ', style: ppFraunces(20, color: Colors.white, h: 1.5)),
              _fill(_horizons[_horizon].$1, () => setState(() => _horizon = (_horizon + 1) % _horizons.length)),
              Text('.', style: ppFraunces(20, color: Colors.white, h: 1.5)),
            ],
          ),
          Container(margin: const EdgeInsets.only(top: 20), height: 1, color: _dividerDark),
          const SizedBox(height: 18),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('You\'d set aside about', style: ppBody(11, color: ppMuted)),
                const SizedBox(height: 2),
                Text.rich(TextSpan(children: [
                  TextSpan(text: '₹${_inr(_monthly())}', style: ppJakarta(22, color: Colors.white)),
                  TextSpan(text: '/mo', style: ppBody(13, color: _lav, w: FontWeight.w600)),
                ])),
              ]),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                final ctx = _waysKey.currentContext;
                if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeOut, alignment: 0.1);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                child: Text('See ways', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text('An illustration at an assumed 11% p.a., not a guarantee or a recommendation.',
              style: ppBody(10, color: const Color(0xFF79747F), h: 1.5)),
        ]),
      );

  Widget _fill(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ppPurple, width: 2))),
          padding: const EdgeInsets.only(bottom: 1),
          child: Text(label, style: ppFraunces(20, color: Colors.white, w: FontWeight.w500, h: 1.5)),
        ),
      );

  Widget _goalChip(int i) {
    final on = i == _goal;
    return GestureDetector(
      onTap: () => setState(() => _goal = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_goals[i].$2, size: 14, color: on ? Colors.white : ppSoft),
          const SizedBox(width: 6),
          Text(_goals[i].$1, style: ppBody(12, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
        ]),
      ),
    );
  }

  // ---- ways rows -------------------------------------------------------------
  Widget _wayRow((IconData, String, String, String, Color, String?) w, {required bool last}) {
    final (icon, title, desc, pill, pillColor, note) = w;
    return GestureDetector(
      onTap: () => _soon('$title - how it works, coming soon'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            top: const BorderSide(color: ppHair),
            bottom: last ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 20, color: ppPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppJakarta(15)),
              const SizedBox(height: 2),
              Text(desc, style: ppBody(12)),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                  child: Text(pill, style: ppBody(10, color: pillColor, w: FontWeight.w700)),
                ),
                if (note != null) ...[
                  const SizedBox(width: 8),
                  Text(note, style: ppBody(10, color: ppMuted)),
                ],
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );
  }

  // ---- learn strip -----------------------------------------------------------
  Widget _learnCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Learn as you go', style: ppJakarta(16)),
            Text('2 of 6 done', style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Text('Two-minute lessons that explain each option in plain language - no jargon.', style: ppBody(13)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: 0.33, minHeight: 6, backgroundColor: ppPanelDiv, color: ppPurple),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _soon('Lesson: What is an SIP, really? - coming soon'),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, size: 15, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('What is an SIP, really?', style: ppBody(14, color: ppInk, w: FontWeight.w600)),
                    const SizedBox(height: 1),
                    Text('2 min · next up', style: ppBody(12, color: ppMuted)),
                  ]),
                ),
                const SizedBox(width: 10),
                Text('+10 XP', style: ppBody(11, color: ppBrown, w: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      );

  Widget _howTile(IconData icon, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: ppLine)),
          child: Column(children: [
            Icon(icon, size: 20, color: ppPurple),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: ppBody(12, color: ppInk, w: FontWeight.w700, h: 1.25)),
          ]),
        ),
      );
}

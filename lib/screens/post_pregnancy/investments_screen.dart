// =============================================================================
//  InvestmentsScreen - Investments & Savings · goal-led (parenting · S21)
// -----------------------------------------------------------------------------
//  A goal-led savings surface: set a target for Aarav's future and the card
//  computes the monthly SIP needed; browse vetted ways to get there, a
//  learn-as-you-go strip, how-it-works, and the mandatory not-an-advisor
//  disclaimers. Faithful build of Claude Design "post pregnancy - commerce.dc.html"
//  · S21. Reached from the Explore drawer. ParentVeda never touches your money.
//
//  ON THE ONE PARENTVEDA LOOK (2026-10-07). The screen now wears the shared
//  tool shell (`PregToolScaffold`): the tinted field, the round back, a drawn
//  mark, eyebrow, serif title, one intro sentence, the white sheet. The dark
//  purple goal card became a white hairline card with three chip rows
//  (amount, goal, years) and the monthly figure under them; the ways to get
//  there are `PvListRow`s; every disclaimer is kept, word for word.
//
//  ⚠️ LEFT OUT OF THE NEW BUILD, ON PURPOSE: the "2 of 6 done" count, the
//  one-third progress bar and "+10 XP" on the learn card. Nothing tracked
//  lessons; those were made-up numbers (the parenting trust rules). The old
//  build below still has them, for revert only.
//
//  Mobbin: Lloyds "Add a savings goal" — target, then a row of year chips,
//  then "You'll need to save" as a plain result card, one ink button
//  https://mobbin.com/screens/313689d0-ee4f-4117-9942-0ef1006f55a3
//  Taken: chips instead of tap-to-cycle words (every option visible, one tap
//  each), the result as a quiet card under the inputs. Plum's "Capital at
//  risk. Returns not guaranteed." in plain text under the options is the
//  model for the disclaimer staying readable, not small print.
// =============================================================================

import 'dart:math' as math;
import 'pp_child_profile.dart';

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvChip, PvCommit, kPvLine, pvStorePalette;
import 'pp_care_parts.dart' show ppCareHeading;
import 'pp_common.dart';
import '../../widgets/pv_feedback.dart' show PvPress;

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

  // ---- the one-ParentVeda build (2026-10-07) --------------------------------

  /// The hue of the field and the wells: a warm gold, saving for later.
  static const double _hue = 42;

  /// A drawn mark per way, by meaning; null keeps the way's own line icon.
  static const List<IntentMark?> _wayMarks = [
    IntentMark.improveMark, // a monthly SIP: improving slowly
    IntentMark.cuppedHands, // Sukanya Samriddhi: held safe
    null, // digital gold: no drawn mark for gold, its line icon stays
    IntentMark.schoolMark, // education plans
  ];

  Widget _eyebrowV2(String t) => Text(t.toUpperCase(),
      style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: pvStorePalette.action));

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final name = ChildProfileStore.instance.nameMid;
    return PregToolScaffold(
      hue: _hue,
      mark: IntentMark.improveMark,
      eyebrow: 'Plan ahead for $name',
      title: 'Start small, for a big day.',
      intro:
          "Set a goal for $name's future and we'll explain the ways to get there - in plain language, with vetted partners. You stay in control of every rupee.",
      children: [
        pregToolPad(_goalCardV2()),

        const SizedBox(height: 28),
        pregToolPad(Container(key: _waysKey, alignment: Alignment.centerLeft, child: ppCareHeading('Ways to get there'))),
        const SizedBox(height: 6),
        pregToolPad(Text('Each vetted by ParentVeda for legitimacy. Tap to learn how it works.',
            style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2))),
        const SizedBox(height: 10),
        pregToolPad(PvRowGroup(p: p, children: [
          for (var i = 0; i < _ways.length; i++) _wayRowV2(i),
        ])),

        const SizedBox(height: 26),
        pregToolPad(_learnCardV2()),

        const SizedBox(height: 26),
        pregToolPad(ppCareHeading('How it works')),
        const SizedBox(height: 12),
        pregToolPad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _howTileV2(1, 'Set a goal'),
          const SizedBox(width: 10),
          _howTileV2(2, 'Understand options'),
          const SizedBox(width: 10),
          _howTileV2(3, 'Invest via partner'),
        ])),
        const SizedBox(height: 12),
        pregToolPad(Text.rich(
          TextSpan(children: [
            TextSpan(text: 'Execution happens on a vetted partner platform - ', style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2)),
            TextSpan(text: 'they', style: pvManrope(fontSize: 12.5, height: 1.55, fontWeight: FontWeight.w700, color: p.ink1)),
            TextSpan(text: ' handle KYC and your money. ParentVeda never touches it.', style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2)),
          ]),
        )),

        // The disclaimer: a white hairline card, readable, never small print.
        const SizedBox(height: 22),
        pregToolPad(Container(
          key: const ValueKey('investments_disclaimer'),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPvLine),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _eyebrowV2('Important'),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              TextSpan(text: 'ParentVeda is ', style: pvManrope(fontSize: 12.5, height: 1.6, color: p.ink2)),
              TextSpan(
                  text: 'not a SEBI-registered investment advisor',
                  style: pvManrope(fontSize: 12.5, height: 1.6, fontWeight: FontWeight.w700, color: p.ink1)),
              TextSpan(
                  text:
                      ' and does not provide financial advice. We curate and explain options for your awareness only; every decision is yours. Investments carry risk, including possible loss of capital. Please consult a qualified advisor before investing.',
                  style: pvManrope(fontSize: 12.5, height: 1.6, color: p.ink2)),
            ])),
          ]),
        )),

        const SizedBox(height: 16),
        pregToolPad(Text('We earn a referral fee from partner platforms - it never changes your returns or your cost.',
            style: pvManrope(fontSize: 12, height: 1.55, color: p.ink3))),
        const SizedBox(height: 8),
      ],
    );
  }

  /// The goal: three rows of chips, then the monthly figure. Same three
  /// indices the old fill-in-the-blank sentence cycled through.
  Widget _goalCardV2() {
    final p = pvStorePalette;
    Widget row(String label, List<Widget> chips) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _eyebrowV2(label),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ]);
    return Container(
      key: const ValueKey('investments_goal_card'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPvLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Set a goal', style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
        const SizedBox(height: 14),
        row('How much', [
          for (var i = 0; i < _amounts.length; i++)
            PvChip(label: _amounts[i].$1, selected: i == _amount, onTap: () => setState(() => _amount = i)),
        ]),
        const SizedBox(height: 14),
        row('For', [
          for (var i = 0; i < _goals.length; i++)
            PvChip(
                label: _goals[i].$1,
                leading: _goals[i].$2,
                selected: i == _goal,
                onTap: () => setState(() => _goal = i)),
        ]),
        const SizedBox(height: 14),
        row('In', [
          for (var i = 0; i < _horizons.length; i++)
            PvChip(label: _horizons[i].$1, selected: i == _horizon, onTap: () => setState(() => _horizon = i)),
        ]),
        const SizedBox(height: 16),
        Divider(height: 1, thickness: 1, color: p.line),
        const SizedBox(height: 14),
        Text(
            "${_amounts[_amount].$1} for ${ChildProfileStore.instance.nameMid}'s ${_goals[_goal].$3} in ${_horizons[_horizon].$1}",
            style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
        const SizedBox(height: 4),
        Text("You'd set aside about", style: pvManrope(fontSize: 12, color: p.ink3)),
        const SizedBox(height: 2),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: '₹${_inr(_monthly())}',
              style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w600, color: p.ink1)),
          TextSpan(text: '/mo', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
        ])),
        const SizedBox(height: 8),
        Text('An illustration at an assumed 11% p.a., not a guarantee or a recommendation.',
            style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3)),
        const SizedBox(height: 14),
        PvCommit(
          label: 'See ways',
          onTap: () {
            final ctx = _waysKey.currentContext;
            if (ctx != null) {
              Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeOut, alignment: 0.1);
            }
          },
        ),
      ]),
    );
  }

  Widget _wayRowV2(int i) {
    final p = pvStorePalette;
    final (icon, title, desc, pill, _, note) = _ways[i];
    return PvListRow(
      p: p,
      leading: PvMarkWell(p: p, hue: _hue, size: 40, mark: _wayMarks[i], icon: icon),
      title: title,
      line: desc,
      lineMaxLines: 2,
      meta: note == null ? pill : '$pill · $note',
      onTap: () => _soon('$title - how it works, coming soon'),
    );
  }

  /// The lessons strip, without the made-up progress (see the header).
  Widget _learnCardV2() {
    final p = pvStorePalette;
    return Container(
      key: const ValueKey('investments_learn_card'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPvLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Learn as you go', style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 6),
        Text('Two-minute lessons that explain each option in plain language - no jargon.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
        const SizedBox(height: 6),
        PvListRow(
          p: p,
          leading: PvMarkWell(p: p, hue: _hue, size: 40, mark: IntentMark.playMark),
          title: 'What is an SIP, really?',
          line: '2 min',
          onTap: () => _soon('Lesson: What is an SIP, really? - coming soon'),
        ),
      ]),
    );
  }

  Widget _howTileV2(int n, String label) {
    final p = pvStorePalette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPvLine),
        ),
        child: Column(children: [
          Text('$n', style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
        ]),
      ),
    );
  }

  // ---- the purple build, before the one-ParentVeda look ---------------------
  // Kept for revert (2026-10-07). It still carries "2 of 6 done" and "+10 XP",
  // which the new build leaves out.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 40),
        children: [
          _pad(ppBack(context, 'Explore')),

          const SizedBox(height: 22),
          _pad(ppEyebrow('Plan ahead for ${ChildProfileStore.instance.nameMid}', color: ppBrown, spacing: 1.4)),
          const SizedBox(height: 10),
          _pad(Text('Start small, for a big day.', style: ppFraunces(32, h: 1.12))),
          const SizedBox(height: 12),
          _pad(Text(
              "Set a goal for ${ChildProfileStore.instance.nameMid}'s future and we'll explain the ways to get there - in plain language, with vetted partners. You stay in control of every rupee.",
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
              Text(" for ${ChildProfileStore.instance.nameMid}'s ", style: ppFraunces(20, color: Colors.white, h: 1.5)),
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
            PvPress(child: GestureDetector(
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
            )),
          ]),
          const SizedBox(height: 12),
          Text('An illustration at an assumed 11% p.a., not a guarantee or a recommendation.',
              style: ppBody(10, color: const Color(0xFF79747F), h: 1.5)),
        ]),
      );

  Widget _fill(String label, VoidCallback onTap) => PvPress(child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ppPurple, width: 2))),
          padding: const EdgeInsets.only(bottom: 1),
          child: Text(label, style: ppFraunces(20, color: Colors.white, w: FontWeight.w500, h: 1.5)),
        ),
      ));

  Widget _goalChip(int i) {
    final on = i == _goal;
    return PvPress(child: GestureDetector(
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
    ));
  }

  // ---- ways rows -------------------------------------------------------------
  Widget _wayRow((IconData, String, String, String, Color, String?) w, {required bool last}) {
    final (icon, title, desc, pill, pillColor, note) = w;
    return PvPress(child: GestureDetector(
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
    ));
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
          PvPress(child: GestureDetector(
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
          )),
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

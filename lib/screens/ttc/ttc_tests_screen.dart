// =============================================================================
//  TTC - the medical test library
// -----------------------------------------------------------------------------
//  Answers the question a couple actually has standing in a diagnostic centre:
//  is this test worth doing, what will it tell us, and what do we do with the
//  number that comes back?
//
//  His tests are listed BESIDE hers rather than in a footnote. That ordering is
//  the point of the screen: a male factor is involved in roughly half of
//  couples who struggle, and in most Indian clinics the woman is investigated
//  first through tests that are slower, costlier and more invasive.
//
//  Every entry carries WHEN in the cycle it must be taken, because getting that
//  wrong is the most common reason a fertility test has to be repeated - and a
//  repeated test is a wasted month as well as wasted money.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_tests_data.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

class TtcTestsScreen extends StatefulWidget {
  const TtcTestsScreen({super.key, this.focusId});

  /// A test to open on, from an Ask Veda pointer (`ttctest_amh` → `amh`).
  /// The library still renders whole - the focused card is expanded and
  /// scrolled to, rather than the others being filtered away.
  final String? focusId;

  @override
  State<TtcTestsScreen> createState() => _TtcTestsScreenState();
}

class _TtcTestsScreenState extends State<TtcTestsScreen> {
  bool _him = false;
  final _focusKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final focus = widget.focusId;
    if (focus == null) return;
    // A pointer at one of HIS tests has to flip the segment, or the card it is
    // scrolling to is not on screen at all.
    final test = ttcTestById(focus);
    if (test != null) _him = test.forHim;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocus());
  }

  void _scrollToFocus() {
    final ctx = _focusKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        alignment: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final tests = ttcTestsFor(him: _him);
        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.medicalTests),
                const SizedBox(height: 16),
                Text(t.testsIntro, style: ttcBody(14, h: 1.6)),
                const SizedBox(height: 18),

                // Two segments, equal weight. Not a tab and a footnote.
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: ttcPanel,
                      borderRadius: BorderRadius.circular(999)),
                  child: Row(children: [
                    _seg(t.testForHer, !_him, () => setState(() => _him = false)),
                    _seg(t.testForHim, _him, () => setState(() => _him = true)),
                  ]),
                ),
                const SizedBox(height: 18),

                for (final test in tests) ...[
                  _TestCard(
                    key: test.id == widget.focusId ? _focusKey : null,
                    test: test,
                    t: t,
                    startOpen: test.id == widget.focusId,
                  ),
                  const SizedBox(height: 11),
                ],

                const SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      t.hinglish
                          ? 'Ye jaankari hai, salaah nahi. Kaunsa test kab karwana hai, ye aapke doctor ke saath tay hota hai. Prices sirf andaaza hain aur jagah ke hisaab se badalte hain.'
                          : 'This is information, not advice. Which tests to do and when belongs with your doctor. Prices are indicative and vary by city and lab.',
                      style: ttcBody(11.5, color: ttcMuted, h: 1.5),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _seg(String label, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: on ? ttcCardShadow : null,
            ),
            child: Text(label,
                style: ttcBody(13,
                    color: on ? ttcTitleInk : ttcSoft, w: FontWeight.w800)),
          ),
        ),
      );
}

class _TestCard extends StatefulWidget {
  const _TestCard({
    super.key,
    required this.test,
    required this.t,
    this.startOpen = false,
  });

  final TtcTest test;
  final TtcS t;

  /// True when Ask Veda pointed at this one - it opens expanded, so the answer
  /// lands on the detail rather than on a closed row.
  final bool startOpen;

  @override
  State<_TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<_TestCard> {
  late bool _open = widget.startOpen;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final hi = t.hinglish;
    final test = widget.test;
    return TtcCard(
      onTap: () => setState(() => _open = !_open),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(test.name, style: ttcJakarta(16))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: ttcPanel, borderRadius: BorderRadius.circular(999)),
            child: Text(test.cost(hi),
                style: ttcBody(11, color: ttcPurple, w: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 9),
        // The answer in ten seconds, above the fold. Depth below.
        Text(test.what(hi), style: ttcBody(13.5, h: 1.55)),

        // WHEN in the cycle, on the collapsed card.
        //
        // This was highlighted, correctly, but only after expanding - and it is
        // the one fact that costs a whole month when it is wrong. FSH and LH
        // read on the wrong day are not a slightly worse result; they are a
        // repeat test next cycle.
        if (!_open) ...[
          const SizedBox(height: 9),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.schedule_rounded, size: 13, color: ttcBrown),
            const SizedBox(width: 7),
            Expanded(
              child: Text(test.when(hi),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ttcBody(11.5, color: ttcBrown, h: 1.4)),
            ),
          ]),
        ],

        if (_open) ...[
          const SizedBox(height: 16),
          _row(t.testWhy, test.why(hi)),
          const SizedBox(height: 14),
          // Highlighted, because getting this wrong wastes a month as well as
          // the money.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF6EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: ttcBrown),
                    const SizedBox(width: 7),
                    Text(t.testWhen.toUpperCase(),
                        style: ttcBody(9.5,
                            color: ttcBrown, w: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 7),
                  Text(test.when(hi),
                      style: ttcBody(13, color: ttcBrown, h: 1.5)),
                ]),
          ),
          const SizedBox(height: 14),
          _row(t.testReading, test.reading(hi)),
        ],

        const SizedBox(height: 12),
        Row(children: [
          Text(_open ? t.testLess : t.testMore,
              style: ttcBody(12.5, color: ttcPurple, w: FontWeight.w800)),
          const SizedBox(width: 5),
          Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: 17, color: ttcPurple),
        ]),
      ]),
    );
  }

  Widget _row(String label, String body) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body, style: ttcBody(13.5, color: ttcInk, h: 1.6)),
        ],
      );
}

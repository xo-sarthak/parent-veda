// =============================================================================
//  Talk tab - crisis entry, Ask Veda, the self-check screener, and the ONLY
//  paid layer in Mind & Mood
// -----------------------------------------------------------------------------
//  ⚠️ PAID IS SCOPED TO EXACTLY TWO PLACES IN THE WHOLE SECTION: the three
//  cards at the bottom of this file, and the footer of a "more than a mood"
//  article (mm_article_screen.dart, which calls `showCounsellingBookingSheet`
//  below rather than re-implementing the sheet). Nowhere else in Mind & Mood
//  imports anything from this file's paid layer.
//
//  ⚠️ BOOKING IS A PLACEHOLDER SCHEDULING HOOK. Two taps - "Book" then
//  "Request this" - produce a warm confirmation and nothing is actually
//  scheduled. Wiring to the real booking engine (`lib/booking/`) is future
//  work; building a second, parallel payment/entitlement path in a first
//  pass on the app's most sensitive section was the wrong risk to take.
//
//  ⚠️ THE SELF-CHECK SCREENER NEVER SHOWS A NUMBER. `mmScreenerGuidance`
//  returns a sentence, not a score - see mind_mood_data.dart.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/mind_mood_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../tools/ask_veda_screen.dart';
import '../v2/v2_palette.dart';
import 'mm_crisis_path.dart';

class MmTalkTab extends StatelessWidget {
  const MmTalkTab({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
      children: [
        _CrisisEntryCard(p: p),
        const SizedBox(height: 22),
        _AskVedaCard(p: p, controller: controller),
        const SizedBox(height: 22),
        _ScreenerCard(p: p),
        const SizedBox(height: 30),
        Text('The only paid part of Mind & Mood',
            style: pvFraunces(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: p.ink1)),
        const SizedBox(height: 4),
        Text(
            'Everything else in this section is, and stays, free.',
            style: pvManrope(fontSize: 12.5, color: p.ink3)),
        const SizedBox(height: 14),
        for (final o in kMmTalkOfferings) ...[
          _OfferingCard(offering: o, p: p),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// =============================================================================
//  Crisis entry - always visible, free
// =============================================================================

class _CrisisEntryCard extends StatelessWidget {
  const _CrisisEntryCard({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final calm = const Color(0xFF3E7A6B);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => openCrisisPath(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: calm.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: calm.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(Icons.phone_in_talk_outlined, color: calm, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Talk to someone right now',
                      style: pvFraunces(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  const SizedBox(height: 2),
                  Text('Real, immediate human help. Always here.',
                      style: pvManrope(fontSize: 11.5, color: p.ink2)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: calm),
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
//  Ask Veda - free, gentle "is this normal" questions
// =============================================================================

class _AskVedaCard extends StatelessWidget {
  const _AskVedaCard({required this.p, required this.controller});
  final V2Palette p;
  final PregnancyController controller;

  static const List<String> _suggested = [
    'Is it normal to cry for no reason in pregnancy?',
    'Why do I feel scared about labour even though everything is fine?',
    'Is it normal to feel disconnected from the pregnancy?',
  ];

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(268, p);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: tint, borderRadius: BorderRadius.circular(11)),
            child: Icon(Icons.auto_awesome_rounded, size: 18, color: p.ink1),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text('Ask a gentle question',
                style: pvFraunces(
                    fontSize: 15.5, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(
            'For "is this normal" questions. Anything serious, it will '
            'point you to a real person, not answer alone.',
            style: pvManrope(fontSize: 12, height: 1.45, color: p.ink2)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'mind_mood_ask_veda'),
                builder: (_) => AskVedaScreen(
                    controller: controller, initialQuery: _suggested.first),
              )),
              style: OutlinedButton.styleFrom(
                  foregroundColor: p.ink1,
                  side: BorderSide(color: p.line),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(vertical: 11)),
              child: const Text('Ask Veda'),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () => openCrisisPath(context),
            child: Text('or talk to someone now',
                style: pvManrope(fontSize: 11.5, color: p.ink3)),
          ),
        ]),
      ]),
    );
  }
}

// =============================================================================
//  Self-check screener
// =============================================================================

class _ScreenerCard extends StatelessWidget {
  const _ScreenerCard({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'mind_mood_screener'),
          builder: (_) => const _MmScreenerScreen(),
        )),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Icon(Icons.checklist_rtl_rounded, size: 22, color: p.ink2),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A gentle check-in',
                      style: pvFraunces(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  const SizedBox(height: 2),
                  Text('A few soft questions. No score, ever shown to you.',
                      style: pvManrope(fontSize: 11.5, color: p.ink2)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

class _MmScreenerScreen extends StatefulWidget {
  const _MmScreenerScreen();
  @override
  State<_MmScreenerScreen> createState() => _MmScreenerScreenState();
}

class _MmScreenerScreenState extends State<_MmScreenerScreen> {
  int _index = 0;
  int _total = 0;
  bool _done = false;

  void _answer(MmScreenerQuestion q, MmScreenerOption opt) {
    if (q.isSafetyQuestion && opt.severity >= 3) {
      openCrisisPath(context);
      return;
    }
    _total += opt.severity;
    if (_index >= kMmScreenerQuestions.length - 1) {
      setState(() => _done = true);
    } else {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
          child: Column(children: [
            Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.close_rounded, color: p.ink3),
              ),
              const Spacer(),
              if (!_done)
                Text('${_index + 1} / ${kMmScreenerQuestions.length}',
                    style: pvManrope(fontSize: 11.5, color: p.ink3)),
            ]),
            Expanded(
              child: Center(
                child: _done
                    ? _ScreenerResult(total: _total, p: p)
                    : _ScreenerQuestionView(
                        key: ValueKey(_index),
                        question: kMmScreenerQuestions[_index],
                        p: p,
                        onAnswer: (opt) => _answer(kMmScreenerQuestions[_index], opt),
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ScreenerQuestionView extends StatelessWidget {
  const _ScreenerQuestionView(
      {super.key, required this.question, required this.p, required this.onAnswer});
  final MmScreenerQuestion question;
  final V2Palette p;
  final ValueChanged<MmScreenerOption> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(question.prompt.now,
          textAlign: TextAlign.center,
          style: pvFraunces(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: p.ink1)),
      const SizedBox(height: 26),
      for (final opt in question.options) ...[
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => onAnswer(opt),
            style: OutlinedButton.styleFrom(
                foregroundColor: p.ink1,
                side: BorderSide(color: p.line),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(vertical: 13)),
            child: Text(opt.label.now),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ]);
  }
}

class _ScreenerResult extends StatelessWidget {
  const _ScreenerResult({required this.total, required this.p});
  final int total;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.spa_outlined, size: 40, color: p.ink2),
      const SizedBox(height: 18),
      Text(mmScreenerGuidance(total).now,
          textAlign: TextAlign.center,
          style: pvManrope(fontSize: 14.5, height: 1.6, color: p.ink1)),
      const SizedBox(height: 24),
      if (total > 4)
        SizedBox(
          width: 240,
          child: FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: p.surface,
                foregroundColor: p.ink1,
                side: BorderSide(color: p.ink1.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(vertical: 13)),
            onPressed: () => showCounsellingBookingSheet(context),
            child: const Text('Talk to a counsellor'),
          ),
        ),
      const SizedBox(height: 10),
      TextButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: Text('Done',
            style: pvManrope(fontSize: 13, color: p.ink3)),
      ),
    ]);
  }
}

// =============================================================================
//  Paid offerings + the placeholder 2-tap booking hook
// =============================================================================

class _OfferingCard extends StatelessWidget {
  const _OfferingCard({required this.offering, required this.p});
  final MmTalkOffering offering;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(186, p); // SolutionType.consult's hue
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 19, color: p.ink1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(offering.title.now,
                style: pvFraunces(
                    fontSize: 16, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
        ]),
        if (offering.anonymous) ...[
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.visibility_off_outlined, size: 14, color: p.ink3),
            const SizedBox(width: 6),
            Text('Always anonymous. We never share your name.',
                style: pvManrope(
                    fontSize: 11, fontWeight: FontWeight.w700, color: p.ink3)),
          ]),
        ],
        const SizedBox(height: 10),
        Text('Who this is for',
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: p.ink3)),
        const SizedBox(height: 3),
        Text(offering.whoFor.now,
            style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
        const SizedBox(height: 8),
        Text(offering.description.now,
            style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
        const SizedBox(height: 14),
        Row(children: [
          Text('\$${offering.priceUsd.toStringAsFixed(0)}',
              style: pvManrope(
                  fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1)),
          Text(' · ₹${offering.priceInr.toStringAsFixed(0)}',
              style: pvManrope(
                  fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
          Text(' ${offering.priceUnit.now}',
              style: pvManrope(fontSize: 11.5, color: p.ink3)),
          const Spacer(),
          OutlinedButton(
            onPressed: () => _showBookingSheet(context, offering),
            style: OutlinedButton.styleFrom(
                foregroundColor: p.ink1,
                side: BorderSide(color: p.line),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9)),
            child: const Text('Book'),
          ),
        ]),
      ]),
    );
  }
}

/// Reused by the Track nudge and the "more than a mood" article footer, so
/// the counselling offering always opens the exact same sheet.
void showCounsellingBookingSheet(BuildContext context) {
  final offering =
      kMmTalkOfferings.firstWhere((o) => o.id == 'perinatal_counselling');
  _showBookingSheet(context, offering);
}

/// Tap 1: this sheet, showing what she is booking. Tap 2: "Request this"
/// below, which shows a warm confirmation.
///
/// ⚠️ PLACEHOLDER SCHEDULING HOOK. Nothing is actually scheduled or charged
/// - wire this to `lib/booking/` (BookingStore/BookingCatalog) when this
/// section is ready for real payment + entitlement flow.
void _showBookingSheet(BuildContext context, MmTalkOffering offering) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _BookingSheet(offering: offering),
  );
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({required this.offering});
  final MmTalkOffering offering;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      padding: EdgeInsets.fromLTRB(
          22, 22, 22, 22 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: p.ground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: p.line, borderRadius: BorderRadius.circular(999)),
        ),
        const SizedBox(height: 18),
        if (!_requested) ...[
          Text(widget.offering.title.now,
              style: pvFraunces(
                  fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 8),
          if (widget.offering.anonymous)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.visibility_off_outlined, size: 14, color: p.ink3),
                const SizedBox(width: 6),
                Text('Always anonymous',
                    style: pvManrope(
                        fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
              ]),
            ),
          Text(widget.offering.description.now,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: p.surface,
                  foregroundColor: p.ink1,
                  side: BorderSide(color: p.ink1.withValues(alpha: 0.25)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => setState(() => _requested = true),
              child: const Text('Request this'),
            ),
          ),
        ] else ...[
          Icon(Icons.check_circle_outline_rounded, size: 36, color: p.ink2),
          const SizedBox(height: 14),
          Text('Request sent',
              style: pvFraunces(
                  fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 8),
          Text(
              'We will reach out to set a time that works for you. This '
              'stays anonymous throughout.',
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text('Close',
                style: pvManrope(fontSize: 13, color: p.ink3)),
          ),
        ],
      ]),
    );
  }
}

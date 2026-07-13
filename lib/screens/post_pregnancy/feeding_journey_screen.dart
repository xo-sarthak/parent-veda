// =============================================================================
//  FeedingJourneyScreen - "Feeding Journey" tool (parenting · Tools)
// -----------------------------------------------------------------------------
//  The Feeding Tracker rebuilt from the Claude Design prompt: not a log, a
//  journey. A calm Hero snapshot (last feed · gentle next-feed estimate · today's
//  count · method · a one-line insight), a <10-second Quick Log that adapts to
//  Breast / Bottle / Solids, a growth-aware insight card, today's feeds as a soft
//  timeline, plain-language patterns, and "Learn while you track" reads. Reads
//  FeedingStore and rebuilds on change. Purely reassuring - observations, never
//  diagnoses. Replaces the older FeedingTrackerScreen (kept for revert).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_feeding_data.dart';
import 'pp_tools_kit.dart';

class FeedingJourneyScreen extends StatefulWidget {
  const FeedingJourneyScreen({super.key});

  @override
  State<FeedingJourneyScreen> createState() => _FeedingJourneyScreenState();
}

class _FeedingJourneyScreenState extends State<FeedingJourneyScreen> {
  final _store = FeedingStore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            final today = _store.todays;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 48),
              children: [
                ...ppToolHeader(
                  context,
                  title: 'Feeding journey',
                  subtitle: 'Not a log to fill — a rhythm you can see, and understand.',
                ),
                const SizedBox(height: 20),
                ppToolPad(_hero()),
                const SizedBox(height: 14),
                ppToolPad(ppLogButton('Log a feed', _openLogSheet)),
                const SizedBox(height: 18),
                ppToolPad(ppInsightCard(_store.growthAwareInsight, tag: 'Growth-aware')),

                const SizedBox(height: 26),
                ppToolPad(ppSectionHead("Today's feeds", trailing: today.isEmpty ? null : '${today.length} logged')),
                const SizedBox(height: 14),
                if (today.isEmpty)
                  ppToolPad(ppEmptyCard(Icons.local_drink_outlined,
                      'No feeds logged today yet. A couple of taps whenever you like keeps the rhythm — never a chore.'))
                else
                  ppToolPad(Column(children: [for (final f in today) _feedRow(f)])),

                const SizedBox(height: 28),
                ppToolPad(_patterns()),

                const SizedBox(height: 28),
                ppToolPad(ppLearnBlock(context, const [
                  'How do I know my baby is getting enough milk?',
                  'What is cluster feeding, and is it normal?',
                  'How do I recognise early hunger cues?',
                  'When and how do I start solids?',
                ])),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- hero ---------------------------------------------------------------
  Widget _hero() {
    final last = _store.last;
    final next = _store.nextExpected;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, ppStripeB]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ppHair),
        boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 30, spreadRadius: -20, offset: Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_store.countToday}', style: ppFraunces(38, color: ppPurple, h: 1.0)),
              const SizedBox(height: 2),
              Text(_store.countToday == 1 ? 'feed today' : 'feeds today', style: ppBody(12.5, color: ppSoft, w: FontWeight.w600)),
            ]),
          ),
          Container(width: 1, height: 48, color: ppHair),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.schedule_rounded, size: 15, color: ppPurple),
                const SizedBox(width: 6),
                Flexible(child: Text('Last feed', style: ppBody(11.5, color: ppMuted, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 6),
              Text(last == null ? 'none yet' : ppRelative(last.time), style: ppJakarta(17)),
              const SizedBox(height: 2),
              Text(last == null ? 'log the first below' : _detail(last), style: ppBody(12, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Container(height: 1, color: ppHair),
        const SizedBox(height: 14),
        Row(children: [
          _miniStat(Icons.restaurant_outlined, 'Method', _store.methodToday),
          const SizedBox(width: 14),
          _miniStat(Icons.hourglass_bottom_rounded, 'Next feed (est.)', next == null ? '—' : '~${ppClock(next)}'),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.favorite_border_rounded, size: 15, color: ppPurple),
            const SizedBox(width: 9),
            Expanded(child: Text(_store.quickInsight, style: ppBody(12.5, color: ppInk, h: 1.5))),
          ]),
        ),
      ]),
    );
  }

  Widget _miniStat(IconData icon, String label, String value) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 14, color: ppMuted),
            const SizedBox(width: 5),
            Flexible(child: Text(label, style: ppBody(11, color: ppMuted, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 4),
          Text(value, style: ppJakarta(14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  // ---- feed row -----------------------------------------------------------
  Widget _feedRow(FeedLog f) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _tint(f.kind), borderRadius: BorderRadius.circular(12)),
            child: Icon(_icon(f.kind), size: 19, color: ppInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_kindLabel(f.kind), style: ppJakarta(14.5)),
                const SizedBox(width: 8),
                Text(ppClock(f.time), style: ppBody(11.5, color: ppMuted)),
              ]),
              const SizedBox(height: 3),
              Text(_detail(f), style: ppBody(12.5, color: ppSoft, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => ppConfirmRemove(context, 'Remove this feed?', () => _store.remove(f.id)),
            behavior: HitTestBehavior.opaque,
            child: const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.delete_outline_rounded, size: 20, color: ppMuted)),
          ),
        ]),
      );

  Widget _patterns() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.insights_outlined, size: 16, color: ppPurple),
            const SizedBox(width: 8),
            Expanded(child: Text('What the pattern shows', style: ppJakarta(15))),
          ]),
          const SizedBox(height: 12),
          for (final p in _store.patterns) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(margin: const EdgeInsets.only(top: 7), width: 5, height: 5, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(p, style: ppBody(13, color: ppInk, h: 1.55))),
            ]),
            const SizedBox(height: 10),
          ],
        ]),
      );

  // ---- log sheet ----------------------------------------------------------
  void _openLogSheet() {
    FeedKind kind = FeedKind.breast;
    FeedSideX side = FeedSideX.left;
    BottleMilk milk = BottleMilk.expressed;
    SolidTake take = SolidTake.ate;
    final duration = TextEditingController();
    final amount = TextEditingController();
    final food = TextEditingController();
    final note = TextEditingController();

    ppLogSheet(
      context,
      title: 'Log a feed',
      saveLabel: 'Save feed',
      body: (setSheet) => [
        ppFieldLabel('How was this feed?'),
        Row(children: [
          ppChoiceChip('Breast', kind == FeedKind.breast, () => setSheet(() => kind = FeedKind.breast), icon: Icons.child_care_outlined),
          const SizedBox(width: 8),
          ppChoiceChip('Bottle', kind == FeedKind.bottle, () => setSheet(() => kind = FeedKind.bottle), icon: Icons.local_drink_outlined),
          const SizedBox(width: 8),
          ppChoiceChip('Solids', kind == FeedKind.solid, () => setSheet(() => kind = FeedKind.solid), icon: Icons.restaurant_outlined),
        ]),
        const SizedBox(height: 16),

        if (kind == FeedKind.breast) ...[
          ppFieldLabel('Side'),
          Row(children: [
            ppChoiceChip('Left', side == FeedSideX.left, () => setSheet(() => side = FeedSideX.left)),
            const SizedBox(width: 8),
            ppChoiceChip('Right', side == FeedSideX.right, () => setSheet(() => side = FeedSideX.right)),
            const SizedBox(width: 8),
            ppChoiceChip('Both', side == FeedSideX.both, () => setSheet(() => side = FeedSideX.both)),
          ]),
          const SizedBox(height: 12),
          ppToolTextField(duration, 'Duration (minutes, optional)', number: true),
        ] else if (kind == FeedKind.bottle) ...[
          ppFieldLabel('What was in the bottle?'),
          Row(children: [
            ppChoiceChip('Expressed', milk == BottleMilk.expressed, () => setSheet(() => milk = BottleMilk.expressed)),
            const SizedBox(width: 8),
            ppChoiceChip('Formula', milk == BottleMilk.formula, () => setSheet(() => milk = BottleMilk.formula)),
            const SizedBox(width: 8),
            ppChoiceChip('Other', milk == BottleMilk.other, () => setSheet(() => milk = BottleMilk.other)),
          ]),
          const SizedBox(height: 12),
          ppToolTextField(amount, 'Amount (ml, optional)', number: true),
        ] else ...[
          ppToolTextField(food, 'What did they try?'),
          ppFieldLabel('How did it go?'),
          Row(children: [
            ppChoiceChip('Ate well', take == SolidTake.ate, () => setSheet(() => take = SolidTake.ate)),
            const SizedBox(width: 8),
            ppChoiceChip('Tasted', take == SolidTake.tasted, () => setSheet(() => take = SolidTake.tasted)),
            const SizedBox(width: 8),
            ppChoiceChip('Not today', take == SolidTake.refused, () => setSheet(() => take = SolidTake.refused)),
          ]),
          const SizedBox(height: 12),
        ],
        ppToolTextField(note, 'Note (optional)', maxLines: 2),
      ],
      onSave: () {
        _store.log(
          time: DateTime.now(),
          kind: kind,
          side: kind == FeedKind.breast ? side : null,
          durationMin: kind == FeedKind.breast ? int.tryParse(duration.text.trim()) : null,
          milk: kind == FeedKind.bottle ? milk : null,
          amountMl: kind == FeedKind.bottle ? int.tryParse(amount.text.trim()) : null,
          food: kind == FeedKind.solid ? (food.text.trim().isEmpty ? 'Solid food' : food.text.trim()) : null,
          take: kind == FeedKind.solid ? take : null,
          note: note.text.trim().isEmpty ? null : note.text.trim(),
        );
      },
    );
  }

  // ---- formatting ---------------------------------------------------------
  String _kindLabel(FeedKind k) => switch (k) {
        FeedKind.breast => 'Breast',
        FeedKind.bottle => 'Bottle',
        FeedKind.solid => 'Solids',
      };

  IconData _icon(FeedKind k) => switch (k) {
        FeedKind.breast => Icons.child_care_outlined,
        FeedKind.bottle => Icons.local_drink_outlined,
        FeedKind.solid => Icons.restaurant_outlined,
      };

  Color _tint(FeedKind k) => switch (k) {
        FeedKind.breast => const Color(0xFFEDEAF7),
        FeedKind.bottle => const Color(0xFFEAF4EE),
        FeedKind.solid => const Color(0xFFFBEAF0),
      };

  String _detail(FeedLog f) {
    String base;
    switch (f.kind) {
      case FeedKind.breast:
        final parts = <String>[
          if (f.side != null) switch (f.side!) { FeedSideX.left => 'Left', FeedSideX.right => 'Right', FeedSideX.both => 'Both sides' },
          if (f.durationMin != null) '${f.durationMin} min',
        ];
        base = parts.isEmpty ? 'Breastfeed' : parts.join(' · ');
      case FeedKind.bottle:
        final parts = <String>[
          if (f.milk != null) switch (f.milk!) { BottleMilk.expressed => 'Expressed', BottleMilk.formula => 'Formula', BottleMilk.other => 'Milk' },
          if (f.amountMl != null) '${f.amountMl} ml',
        ];
        base = parts.isEmpty ? 'Bottle' : parts.join(' · ');
      case FeedKind.solid:
        final take = f.take == null
            ? null
            : switch (f.take!) { SolidTake.ate => 'Ate well', SolidTake.tasted => 'Tasted', SolidTake.refused => 'Not today' };
        base = [if (f.food != null) f.food!, ?take].join(' · ');
        if (base.isEmpty) base = 'Solid food';
    }
    return f.note != null ? '$base · ${f.note}' : base;
  }
}

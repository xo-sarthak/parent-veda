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

import '../../care_partner/care_visibility.dart';
import '../care_partner/care_partner_slot.dart';

import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit, PvSecondary;
import '../ttc/ttc_tool_marks.dart';
import '../v2/v2_palette.dart';
import 'pp_breast_timer_screen.dart';
import 'pp_care_history_screen.dart';
import 'pp_care_log_data.dart';
import 'pp_care_parts.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_feeding_data.dart';
import 'pp_nappy_screen.dart';
import 'pp_pump_screen.dart';
import 'pp_search.dart' show openPpAskVeda;
import 'pp_tools_kit.dart';

/// ⚠️ THE SHARED TOOL SHELL (2026-10-07, parenting gap pass). The journey was
/// drawn in the 2026-08 parenting kit (a purple number on a gradient card, a
/// lavender panel behind a sentence): a different app one tap from the door.
/// It now wears `PregToolScaffold` like every pregnancy and trying-to-conceive
/// tool, with the care logs' parts (pp_care_parts.dart), and gains what the gap
/// analysis asked of it (P1, Behind · Logging): a time row so a missed feed can
/// be put in later, Pump as a fourth choice (left and right ml), "Last side:
/// Left, 1h 40m ago" and which side to start on, and a way to the timer,
/// nappies, pumping and the week. `false` draws the 2026-08 page
/// (`_buildBeforeShell`), kept for revert.
const bool kPpFeedingJourneyShell = true;

class FeedingJourneyScreen extends StatefulWidget {
  const FeedingJourneyScreen({super.key});

  @override
  State<FeedingJourneyScreen> createState() => _FeedingJourneyScreenState();
}

class _FeedingJourneyScreenState extends State<FeedingJourneyScreen> {
  final _store = FeedingStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
    PumpStore.instance.init();
  }

  @override
  Widget build(BuildContext context) => kPpFeedingJourneyShell ? _buildShell(context) : _buildBeforeShell(context);

  Widget _buildShell(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, ChildProfileStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final today = _store.todays;
        final last = _store.last;
        final next = _store.nextExpected;
        final side = ppNextBreastSide();
        final lastSide = ppLastSideLine();
        final tint = HSLColor.fromAHSL(1, 206, 0.52, 0.9).toColor();
        Widget go(String key, String title, String line, TtcToolMark mark, Widget screen, String route) =>
            pregToolPad(PvListRow(
              key: ValueKey(key),
              p: p,
              leading: TtcMarkLeading(tool: mark, tint: tint, size: 40),
              title: title,
              line: line,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: RouteSettings(name: route),
                builder: (_) => screen,
              )),
            ));
        return PregToolScaffold(
          hue: 206,
          eyebrow: 'Feeding',
          mark: IntentMark.feedMark,
          title: 'Feeding journey',
          intro: 'A rhythm you can see, not a log to fill. A couple of taps whenever you like.',
          children: [
            pregToolPad(PpCareStats([
              ('${_store.countToday}', _store.countToday == 1 ? 'feed today' : 'feeds today'),
              (last == null ? 'None yet' : ppCareAgo(last.time), 'last feed'),
              (next == null ? 'Not yet' : '~${ppCareClock(next)}', 'next feed, roughly'),
            ])),
            if (side != null || lastSide != null) ...[
              const SizedBox(height: 14),
              if (side != null)
                pregToolPad(Text(side.suggestion,
                    key: const ValueKey('pp_feed_next_side'),
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, height: 1.4, color: p.ink1))),
              if (lastSide != null)
                pregToolPad(Text(lastSide,
                    key: const ValueKey('pp_feed_last_side'),
                    style: pvManrope(fontSize: 13.5, color: p.ink2))),
            ],
            const SizedBox(height: 18),
            pregToolPad(PvCommit(key: const ValueKey('pp_feed_log'), label: 'Log a feed', onTap: _openLogSheet)),
            const SizedBox(height: 10),
            pregToolPad(PvSecondary(
              key: const ValueKey('pp_feed_timer_open'),
              label: 'Start the breastfeed timer',
              icon: Icons.timer_outlined,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'pp_feed_timer'),
                builder: (_) => const PpBreastTimerScreen(),
              )),
            )),
            const SizedBox(height: 18),
            pregToolPad(Text(_store.growthAwareInsight, style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1))),
            // If a lactation consultant introduced this family to ParentVeda,
            // this is where she belongs. Renders nothing otherwise.
            pregToolPad(const CarePartnerSlot(
              surface: CareSurface.topic,
              topic: CareTopic.breastfeeding,
              stage: 'parenting',
              padding: EdgeInsets.only(top: 14),
            )),
            const SizedBox(height: 26),
            pregToolPad(ppCareHeading("Today's feeds")),
            const SizedBox(height: 6),
            if (today.isEmpty)
              pregToolPad(Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No feeds logged today yet. A couple of taps whenever you like keeps the rhythm.',
                    key: const ValueKey('pp_feed_empty'),
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
              ))
            else
              for (final f in today)
                pregToolPad(PpCareEntryRow(
                  key: ValueKey('pp_feed_row_${f.id}'),
                  title: _kindLabel(f.kind),
                  when: f.time,
                  detail: _detail(f),
                  onRemove: () {
                    _store.remove(f.id);
                    ppCareSaved(context, 'Feed removed.', undo: () => _store.add(f));
                  },
                )),
            const SizedBox(height: 26),
            pregToolPad(ppCareHeading('What the pattern shows')),
            const SizedBox(height: 10),
            for (final line in _store.patterns)
              pregToolPad(Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(line, style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1)),
              )),
            const SizedBox(height: 22),
            pregToolPad(ppCareHeading('Also keep track of')),
            const SizedBox(height: 8),
            go('pp_feed_go_nappies', 'Nappies', 'Wet and dirty, one tap each', TtcToolMark.records,
                const PpNappyScreen(), 'pp_nappies'),
            go('pp_feed_go_pump', 'Pumping', 'Left and right, in ml', TtcToolMark.nutrition, const PpPumpScreen(),
                'pp_pump'),
            go('pp_feed_go_history', 'The last 7 days', 'Day by day, and a summary for your doctor',
                TtcToolMark.cycleReport, const PpCareHistoryScreen(), 'pp_care_history'),
            const SizedBox(height: 22),
            pregToolPad(ppCareHeading('Questions parents ask')),
            const SizedBox(height: 4),
            for (final q in const [
              'How do I know my baby is getting enough milk?',
              'What is cluster feeding, and is it normal?',
              'How do I recognise early hunger cues?',
              'When and how do I start solids?',
            ])
              pregToolPad(PpCareQuestionRow(question: q, onTap: () => openPpAskVeda(context, q))),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  /// The 2026-08 page, kept for revert (`kPpFeedingJourneyShell = false`).
  Widget _buildBeforeShell(BuildContext context) {
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

                // If a lactation consultant introduced this family to
                // ParentVeda, this is where she belongs. Renders nothing
                // otherwise.
                ppToolPad(const CarePartnerSlot(
                  surface: CareSurface.topic,
                  topic: CareTopic.breastfeeding,
                  stage: 'parenting',
                  padding: EdgeInsets.only(top: 14),
                )),

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
  void _openLogSheet() => kPpFeedingJourneyShell ? _openShellSheet() : _openClassicSheet();

  /// The shared sheet (pp_care_parts.dart): When first (defaults to now, can
  /// be changed), then the kind, then what the kind needs. "Pump" saves to
  /// the pump log, not the feed log: it is milk expressed, not a feed given.
  void _openShellSheet() {
    var when = DateTime.now();
    String kind = 'breast';
    FeedSideX side = ppNextBreastSide()?.lastSide == FeedSideX.left ? FeedSideX.right : FeedSideX.left;
    BottleMilk milk = BottleMilk.expressed;
    SolidTake take = SolidTake.ate;
    int? minutes;
    var amount = 0;
    var left = 0;
    var right = 0;
    final food = TextEditingController();
    showPpCareSheet(
      context,
      title: 'Log a feed',
      saveLabel: 'Save feed',
      body: (setSheet) {
        Widget stepper(String label, int value, String k, ValueChanged<int> on) {
          final p = V2PaletteStore.instance.current;
          return Row(children: [
            SizedBox(width: 72, child: Text(label, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1))),
            IconButton.outlined(
                key: ValueKey('pp_feed_${k}_minus'),
                tooltip: 'Take away 10 ml',
                onPressed: () => on((value - 10).clamp(0, 500)),
                icon: Icon(Icons.remove_rounded, color: p.ink1)),
            Expanded(
                child: Center(
                    child: Text('$value ml', style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w600, color: p.ink1)))),
            IconButton.outlined(
                key: ValueKey('pp_feed_${k}_plus'),
                tooltip: 'Add 10 ml',
                onPressed: () => on((value + 10).clamp(0, 500)),
                icon: Icon(Icons.add_rounded, color: p.ink1)),
          ]);
        }

        return [
          ppCareLabel('When'),
          PpWhenRow(when: when, onChanged: (t) => setSheet(() => when = t)),
          const SizedBox(height: 16),
          ppCareLabel('How was this feed?'),
          ppCareChoices<String>(
            values: const ['breast', 'bottle', 'solids', 'pump'],
            selected: kind,
            label: (k) => switch (k) { 'breast' => 'Breast', 'bottle' => 'Bottle', 'solids' => 'Solids', _ => 'Pump' },
            keyPrefix: 'pp_feed_kind',
            onPick: (k) => setSheet(() => kind = k ?? kind),
          ),
          const SizedBox(height: 16),
          if (kind == 'breast') ...[
            ppCareLabel('Side'),
            ppCareChoices<FeedSideX>(
              values: FeedSideX.values,
              selected: side,
              label: (x) => switch (x) { FeedSideX.left => 'Left', FeedSideX.right => 'Right', FeedSideX.both => 'Both' },
              keyPrefix: 'pp_feed_side',
              onPick: (x) => setSheet(() => side = x ?? side),
            ),
            const SizedBox(height: 16),
            ppCareLabel('How long, if you know'),
            ppCareChoices<int>(
              values: const [5, 10, 15, 20, 30],
              selected: minutes,
              label: (m) => '$m min',
              allowNone: true,
              keyPrefix: 'pp_feed_min',
              onPick: (m) => setSheet(() => minutes = m),
            ),
          ] else if (kind == 'bottle') ...[
            ppCareLabel('What was in the bottle?'),
            ppCareChoices<BottleMilk>(
              values: BottleMilk.values,
              selected: milk,
              label: (m) => switch (m) { BottleMilk.expressed => 'Expressed', BottleMilk.formula => 'Formula', BottleMilk.other => 'Other' },
              keyPrefix: 'pp_feed_milk',
              onPick: (m) => setSheet(() => milk = m ?? milk),
            ),
            const SizedBox(height: 16),
            stepper('Amount', amount, 'amount', (v) => setSheet(() => amount = v)),
          ] else if (kind == 'solids') ...[
            ppCareLabel('What did they try?'),
            TextField(
              key: const ValueKey('pp_feed_food'),
              controller: food,
              decoration: const InputDecoration(hintText: 'Khichdi, mashed banana...', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ppCareLabel('How did it go?'),
            ppCareChoices<SolidTake>(
              values: SolidTake.values,
              selected: take,
              label: (t) => switch (t) { SolidTake.ate => 'Ate well', SolidTake.tasted => 'Tasted', SolidTake.refused => 'Not today' },
              keyPrefix: 'pp_feed_take',
              onPick: (t) => setSheet(() => take = t ?? take),
            ),
          ] else ...[
            stepper('Left', left, 'left', (v) => setSheet(() => left = v)),
            const SizedBox(height: 10),
            stepper('Right', right, 'right', (v) => setSheet(() => right = v)),
            const SizedBox(height: 8),
            Text('Saved to your pumping log, so whoever gives the bottle knows what there is.',
                style: pvManrope(fontSize: 13, height: 1.45, color: V2PaletteStore.instance.current.ink2)),
          ],
        ];
      },
      onSave: () {
        if (kind == 'pump') {
          if (left == 0 && right == 0) {
            ppCareSaved(context, 'Nothing saved: add how much from at least one side.');
            return;
          }
          PumpStore.instance.log(time: when, leftMl: left == 0 ? null : left, rightMl: right == 0 ? null : right);
          ppCareSaved(context, 'Pumping saved: ${left + right} ml, ${ppCareWhen(when).toLowerCase()}.');
          return;
        }
        final k = switch (kind) { 'bottle' => FeedKind.bottle, 'solids' => FeedKind.solid, _ => FeedKind.breast };
        _store.log(
          time: when,
          kind: k,
          side: k == FeedKind.breast ? side : null,
          durationMin: k == FeedKind.breast ? minutes : null,
          milk: k == FeedKind.bottle ? milk : null,
          amountMl: k == FeedKind.bottle && amount > 0 ? amount : null,
          food: k == FeedKind.solid ? (food.text.trim().isEmpty ? 'Solid food' : food.text.trim()) : null,
          take: k == FeedKind.solid ? take : null,
        );
        ppCareSaved(context, '${_kindLabel(k)} feed saved, ${ppCareWhen(when).toLowerCase()}.');
      },
    );
  }

  /// The 2026-08 sheet, kept for revert.
  void _openClassicSheet() {
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

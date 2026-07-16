// =============================================================================
//  SleepJourneyScreen - "Sleep Journey" tool (parenting · Tools)
// -----------------------------------------------------------------------------
//  The Sleep Tracker rebuilt from the Claude Design prompt: understand sleep, not
//  chase it. A calm Hero (today's total · last stretch · night/day split · current
//  wake window · one-line insight), a <10-second Quick Log (two time pickers +
//  optional kind & note), a context-aware insight, an "Age context" ranges card,
//  Smart Correlations to notice, a soft timeline and "Learn while you track"
//  reads. No "good/poor sleep" labels anywhere. Reads SleepStore and rebuilds on
//  change. Replaces the older SleepTrackerScreen (kept for revert).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import '../../brand/brand_models.dart';
import '../../brand/presented_by.dart';
import 'pp_common.dart';
import 'pp_sleep_data.dart';
import 'pp_tools_kit.dart';

class SleepJourneyScreen extends StatefulWidget {
  const SleepJourneyScreen({super.key});

  @override
  State<SleepJourneyScreen> createState() => _SleepJourneyScreenState();
}

class _SleepJourneyScreenState extends State<SleepJourneyScreen> {
  final _store = SleepStore.instance;

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
                  title: 'Sleep journey',
                  subtitle: 'A picture of rest — patterns to understand, not a target to hit.',
                ),
                // Renders nothing unless this exact tool is sponsored. The
                // sponsor gets a line; the tool stays entirely ours.
                ppToolPad(const PresentedBy(
                  slot: BrandSlot.sponsoredTool,
                  stage: BrandStage.parenting,
                  placementKey: 'sleep_journey',
                  padding: EdgeInsets.only(top: 10),
                )),
                const SizedBox(height: 20),
                ppToolPad(_hero()),
                const SizedBox(height: 14),
                ppToolPad(ppLogButton('Log sleep', _openLogSheet, icon: Icons.bedtime_outlined)),
                const SizedBox(height: 18),
                ppToolPad(ppInsightCard(_store.contextInsight, tag: 'In context')),

                const SizedBox(height: 26),
                ppToolPad(ppSectionHead("Today's sleep", trailing: today.isEmpty ? null : '${today.length} logged')),
                const SizedBox(height: 14),
                if (today.isEmpty)
                  ppToolPad(ppEmptyCard(Icons.bedtime_outlined,
                      'No sleep logged today yet. Add a nap or last night whenever it suits — even a rough note helps.'))
                else
                  ppToolPad(Column(children: [for (final s in today) _sleepRow(s)])),

                const SizedBox(height: 28),
                ppToolPad(_ageContext()),

                const SizedBox(height: 20),
                ppToolPad(_correlations()),

                const SizedBox(height: 24),
                ppToolPad(_patterns()),

                const SizedBox(height: 28),
                ppToolPad(ppLearnBlock(context, const [
                  'Why do babies wake through the night?',
                  'What is the 4-month sleep regression?',
                  'How do wake windows change with age?',
                  'What are safe sleep guidelines?',
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
    final wake = _store.currentWakeMinutes;
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
              Text(_store.totalMinutesToday == 0 ? '0m' : ppDur(_store.totalMinutesToday), style: ppFraunces(34, color: ppPurple, h: 1.0)),
              const SizedBox(height: 3),
              Text('slept today', style: ppBody(12.5, color: ppSoft, w: FontWeight.w600)),
            ]),
          ),
          Container(width: 1, height: 48, color: ppHair),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.nightlight_round, size: 14, color: ppPurple),
                const SizedBox(width: 6),
                Flexible(child: Text('Last stretch', style: ppBody(11.5, color: ppMuted, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 6),
              Text(last == null ? 'none yet' : ppDur(last.minutes), style: ppJakarta(17)),
              const SizedBox(height: 2),
              Text(last == null ? 'log the first below' : 'ended ${ppRelative(last.end)}', style: ppBody(12, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Container(height: 1, color: ppHair),
        const SizedBox(height: 14),
        Row(children: [
          _miniStat(Icons.dark_mode_outlined, 'Night', _store.nightMinutesToday == 0 ? '—' : ppDur(_store.nightMinutesToday)),
          const SizedBox(width: 12),
          _miniStat(Icons.wb_sunny_outlined, 'Naps', _store.napCountToday == 0 ? '—' : '${_store.napCountToday} · ${ppDur(_store.dayMinutesToday)}'),
          const SizedBox(width: 12),
          _miniStat(Icons.visibility_outlined, 'Awake for', wake == null ? '—' : ppDur(wake)),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.favorite_border_rounded, size: 15, color: ppPurple),
            const SizedBox(width: 9),
            Expanded(child: Text(_store.todaysInsight, style: ppBody(12.5, color: ppInk, h: 1.5))),
          ]),
        ),
      ]),
    );
  }

  Widget _miniStat(IconData icon, String label, String value) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 13, color: ppMuted),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: ppBody(10.5, color: ppMuted, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 4),
          Text(value, style: ppJakarta(13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  // ---- sleep row ----------------------------------------------------------
  Widget _sleepRow(SleepLog s) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: s.isNight ? const Color(0xFFEDEAF7) : const Color(0xFFFBF4E7), borderRadius: BorderRadius.circular(12)),
            child: Icon(s.isNight ? Icons.dark_mode_outlined : _kindIcon(s.kind), size: 19, color: ppInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(ppDur(s.minutes), style: ppJakarta(14.5)),
                const SizedBox(width: 8),
                Flexible(child: Text('${ppClock(s.start)} – ${ppClock(s.end)}', style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 3),
              Text(_detail(s), style: ppBody(12.5, color: ppSoft, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => ppConfirmRemove(context, 'Remove this sleep?', () => _store.remove(s.id)),
            behavior: HitTestBehavior.opaque,
            child: const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.delete_outline_rounded, size: 20, color: ppMuted)),
          ),
        ]),
      );

  // ---- age context --------------------------------------------------------
  Widget _ageContext() {
    final c = _store.ageContext;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.child_care_outlined, size: 16, color: ppPurple),
          const SizedBox(width: 8),
          Expanded(child: Text('Typical for ${ChildProfileStore.instance.ageLabel}', style: ppJakarta(15))),
        ]),
        const SizedBox(height: 4),
        Text('Ranges, never targets — every baby sits somewhere on them.', style: ppBody(12, color: ppMuted)),
        const SizedBox(height: 14),
        Row(children: [
          _ctxStat('Total / day', c.totalLabel),
          _ctxStat('Naps', c.napsLabel),
          _ctxStat('Wake window', c.wakeLabel),
        ]),
        const SizedBox(height: 14),
        Text(c.blurb, style: ppBody(13, color: ppInk, h: 1.55)),
      ]),
    );
  }

  Widget _ctxStat(String label, String value) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: ppFraunces(19, color: ppPurple)),
          const SizedBox(height: 3),
          Text(label, style: ppBody(11, color: ppMuted, w: FontWeight.w600)),
        ]),
      );

  Widget _correlations() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ppStripeB, Color(0xFFF0E9F7)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ppBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.hub_outlined, size: 16, color: ppPurple),
            const SizedBox(width: 8),
            Expanded(child: Text('Patterns worth noticing', style: ppJakarta(15))),
          ]),
          const SizedBox(height: 4),
          Text('Things some families observe — never a cause, just a nudge to watch.', style: ppBody(12, color: ppSoft)),
          const SizedBox(height: 12),
          for (final c in _store.correlations) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 1),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                child: Text(c.$1, style: ppBody(10.5, color: ppPurple, w: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(c.$2, style: ppBody(12.5, color: ppInk, h: 1.5)),
            const SizedBox(height: 12),
          ],
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
    final now = TimeOfDay.now();
    TimeOfDay start = _minus(now, 90);
    TimeOfDay end = now;
    SleepKind kind = SleepKind.nap;
    final note = TextEditingController();

    ppLogSheet(
      context,
      title: 'Log sleep',
      saveLabel: 'Save sleep',
      body: (setSheet) => [
        Row(children: [
          Expanded(child: ppTimeField('Fell asleep', start, () async {
            final t = await showTimePicker(context: context, initialTime: start);
            if (t != null) setSheet(() => start = t);
          })),
          const SizedBox(width: 12),
          Expanded(child: ppTimeField('Woke up', end, () async {
            final t = await showTimePicker(context: context, initialTime: end);
            if (t != null) setSheet(() => end = t);
          })),
        ]),
        const SizedBox(height: 8),
        Text('That is ${ppDur(_spanMinutes(start, end))} of rest.', style: ppBody(12, color: ppMuted)),
        const SizedBox(height: 16),
        ppFieldLabel('Kind (optional)'),
        Row(children: [
          ppChoiceChip('Night', kind == SleepKind.night, () => setSheet(() => kind = SleepKind.night)),
          const SizedBox(width: 8),
          ppChoiceChip('Nap', kind == SleepKind.nap, () => setSheet(() => kind = SleepKind.nap)),
          const SizedBox(width: 8),
          ppChoiceChip('Contact', kind == SleepKind.contact, () => setSheet(() => kind = SleepKind.contact)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          ppChoiceChip('Car', kind == SleepKind.car, () => setSheet(() => kind = SleepKind.car)),
          const SizedBox(width: 8),
          ppChoiceChip('Stroller', kind == SleepKind.stroller, () => setSheet(() => kind = SleepKind.stroller)),
          const SizedBox(width: 8),
          const Spacer(),
        ]),
        const SizedBox(height: 16),
        ppToolTextField(note, 'Note (optional)', maxLines: 2),
      ],
      onSave: () {
        final now = DateTime.now();
        DateTime at(TimeOfDay t) => DateTime(now.year, now.month, now.day, t.hour, t.minute);
        var s = at(start);
        var e = at(end);
        if (e.isBefore(s)) e = e.add(const Duration(days: 1)); // crossed midnight
        _store.log(start: s, end: e, kind: kind, note: note.text.trim().isEmpty ? null : note.text.trim());
      },
    );
  }

  // ---- formatting ---------------------------------------------------------
  IconData _kindIcon(SleepKind k) => switch (k) {
        SleepKind.night => Icons.dark_mode_outlined,
        SleepKind.nap => Icons.wb_sunny_outlined,
        SleepKind.contact => Icons.favorite_border_rounded,
        SleepKind.car => Icons.directions_car_outlined,
        SleepKind.stroller => Icons.stroller_outlined,
      };

  String _kindLabel(SleepKind k) => switch (k) {
        SleepKind.night => 'Night sleep',
        SleepKind.nap => 'Nap',
        SleepKind.contact => 'Contact nap',
        SleepKind.car => 'Car nap',
        SleepKind.stroller => 'Stroller nap',
      };

  String _detail(SleepLog s) {
    final parts = <String>[_kindLabel(s.kind), if (s.note != null) s.note!];
    return parts.join(' · ');
  }

  int _spanMinutes(TimeOfDay a, TimeOfDay b) {
    var mins = (b.hour * 60 + b.minute) - (a.hour * 60 + a.minute);
    if (mins < 0) mins += 24 * 60;
    return mins;
  }

  TimeOfDay _minus(TimeOfDay t, int minutes) {
    var total = t.hour * 60 + t.minute - minutes;
    total %= 24 * 60;
    if (total < 0) total += 24 * 60;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }
}

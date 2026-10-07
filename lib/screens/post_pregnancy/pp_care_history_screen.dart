// =============================================================================
//  PpCareHistoryScreen — the last seven days, and a summary for the doctor
//  (surface pp_care_history), 2026-10-07
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P1 (Behind · Logging): "Everything she logged
//  yesterday is invisible to her, though it is saved. Add 'Last 7 days' under
//  each log: feeds per day, total sleep per day, wet nappies per day, as a
//  simple bar row. Add 'Share with doctor' that sends a 7 day text summary."
//
//  The day buckets and the summary text are the fork's (`PpCareHistory`,
//  f3e0a27): averages are over the days that have anything logged, so a
//  forgotten day does not read as a hungry one. This screen is new, on the
//  shared tool shell.
//
//  Mobbin: Google Health's "Total energy burned" week (the average large,
//  "per day (avg)", the week of bars, then the days as rows)
//  https://mobbin.com/screens/87da4565-88e3-4345-9001-744c9dafab89; the share
//  sheet is the phone's own, the text plain so it reads in WhatsApp.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit;
import '../v2/v2_palette.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import 'pp_care_log_data.dart';
import 'pp_care_parts.dart';
import 'pp_child_profile.dart';
import 'pp_feeding_data.dart';
import 'pp_sleep_data.dart';

enum PpCareMetric { feeds, sleep, nappies, pump }

String ppCareMetricLabel(PpCareMetric m) => switch (m) {
      PpCareMetric.feeds => 'Feeds',
      PpCareMetric.sleep => 'Sleep',
      PpCareMetric.nappies => 'Wet nappies',
      PpCareMetric.pump => 'Pumping',
    };

class PpCareHistoryScreen extends StatefulWidget {
  const PpCareHistoryScreen({super.key, this.initial = PpCareMetric.feeds});
  final PpCareMetric initial;

  @override
  State<PpCareHistoryScreen> createState() => _PpCareHistoryScreenState();
}

class _PpCareHistoryScreenState extends State<PpCareHistoryScreen> {
  late PpCareMetric _m = widget.initial;

  @override
  void initState() {
    super.initState();
    FeedingStore.instance.init();
    SleepStore.instance.init();
    NappyStore.instance.init();
    PumpStore.instance.init();
  }

  int _value(PpCareDay d) => switch (_m) {
        PpCareMetric.feeds => d.feeds,
        PpCareMetric.sleep => d.sleepMin,
        PpCareMetric.nappies => d.wet,
        PpCareMetric.pump => d.pumpedMl,
      };

  String _fmt(int v) => switch (_m) {
        PpCareMetric.sleep => v < 60 ? '${v}m' : '${v ~/ 60}h${v % 60 == 0 ? '' : ' ${v % 60}m'}',
        _ => '$v',
      };

  String get _unit => switch (_m) {
        PpCareMetric.feeds => 'feeds',
        PpCareMetric.sleep => 'of sleep',
        PpCareMetric.nappies => 'wet',
        PpCareMetric.pump => 'ml',
      };

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _share(List<PpCareDay> days) async {
    pvCommitFeedback();
    final c = ChildProfileStore.instance;
    final text = PpCareHistory.doctorSummary(days, childName: c.name, ageLabel: c.ageLabel);
    try {
      await Share.share(text, subject: '${c.name}: the last 7 days');
    } catch (_) {
      if (mounted) ppCareSaved(context, 'Could not open sharing on this phone.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        FeedingStore.instance,
        SleepStore.instance,
        NappyStore.instance,
        PumpStore.instance,
        ChildProfileStore.instance,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final days = PpCareHistory.days(7); // newest first
        final oldestFirst = [for (final d in days.reversed) _value(d)];
        final anything = days.any((d) => !d.isEmpty);
        return PregToolScaffold(
          hue: 206,
          eyebrow: 'Your logs',
          mark: IntentMark.chartLog,
          title: 'The last 7 days',
          intro: 'Feeds, sleep, nappies and pumping, day by day, and a summary to send your doctor.',
          children: [
            pregToolPad(ppCareChoices<PpCareMetric>(
              values: PpCareMetric.values,
              selected: _m,
              label: ppCareMetricLabel,
              keyPrefix: 'pp_history_metric',
              onPick: (m) => setState(() => _m = m ?? _m),
            )),
            const SizedBox(height: 20),
            pregToolPad(PpWeekBars(values: oldestFirst, unit: _unit, format: _fmt)),
            const SizedBox(height: 24),
            pregToolPad(ppCareHeading('Day by day')),
            const SizedBox(height: 4),
            for (final d in days)
              pregToolPad(Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
                child: Row(children: [
                  Expanded(
                    child: Text('${_days[d.date.weekday - 1]}, ${d.date.day} ${_months[d.date.month - 1]}',
                        style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w600, color: p.ink1)),
                  ),
                  Text(_value(d) == 0 ? 'Nothing logged' : '${_fmt(_value(d))} $_unit',
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: _value(d) == 0 ? FontWeight.w500 : FontWeight.w700,
                          color: _value(d) == 0 ? p.ink3 : p.ink1)),
                ]),
              )),
            const SizedBox(height: 24),
            pregToolPad(PvCommit(
              key: const ValueKey('pp_history_share'),
              label: 'Share with your doctor',
              icon: Icons.ios_share_rounded,
              onTap: anything ? () => _share(days) : null,
            )),
            const SizedBox(height: 8),
            pregToolPad(Text(
              anything
                  ? 'A plain summary of the 7 days, averaged over the days you logged. You choose who it goes to.'
                  : 'Once you log a few feeds, naps or nappies, you can send your doctor a summary from here.',
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
            )),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

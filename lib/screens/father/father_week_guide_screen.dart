// =============================================================================
//  His week, week by week — the partner guide (2026-09-30)
// -----------------------------------------------------------------------------
//  From the pregnancy gap analysis, "Partner (his side)": *"We already write a
//  partner line for every week, but it only shows in his week stack. A clear
//  week by week guide for him, reachable from his home, is one of the most asked
//  for pieces for fathers"* (What to Expect: "Week by Week Pregnancy Advice for
//  Expecting Dads and Partners", first / second / third trimester).
//
//  ⚠️ NO NEW WRITING. Every line here is `WeekContent.partner`, written for each
//  of weeks 4 to 40 in weekContent.json: what she may feel, what he can do, one
//  mission, and a message to share. This screen is the page those lines never
//  had: grouped by trimester, this week's row open, every row shareable.
//
//  ⚠️ WHAT HE SEES OF HER IS NOT CHANGED. The lines are about the WEEK, never
//  about her own symptoms, weight or notes, which he never sees.
//
//  The skeleton and the words are the work; the look is the shared tool shell
//  and his Slate skin is a later pass.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/preg_week_extras.dart' show pregTrimesterFor;
import '../../models/week_content.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_chrome.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

/// Opens the guide. A named route, like every other surface.
void openFatherWeekGuide(BuildContext context, PregnancyController c) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'partner/week_guide'),
    builder: (_) => FatherWeekGuideScreen(controller: c),
  ));
}

/// The weeks that have partner lines, grouped by trimester, in order.
List<(String, List<WeekContent>)> fatherGuideGroups(List<WeekContent> weeks) {
  final out = <(String, List<WeekContent>)>[];
  for (final w in weeks) {
    if (w.partner.whatYouCanDo.en.trim().isEmpty && w.partner.oneMission.en.trim().isEmpty) continue;
    final t = pregTrimesterFor(w.week);
    if (out.isEmpty || out.last.$1 != t) out.add((t, []));
    out.last.$2.add(w);
  }
  return out;
}

class FatherWeekGuideScreen extends StatefulWidget {
  const FatherWeekGuideScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<FatherWeekGuideScreen> createState() => _FatherWeekGuideScreenState();
}

class _FatherWeekGuideScreenState extends State<FatherWeekGuideScreen> {
  late int _open = widget.controller.currentWeek;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final groups = fatherGuideGroups(c.weeks);
    return PregToolScaffold(
      hue: 205,
      eyebrow: 'For partners',
      title: 'Your week, week by week',
      intro: 'What she may feel, what you can do, and one thing to do, for every week. '
          'This week is open.',
      mark: IntentMark.calendarDay,
      children: [
        for (final g in groups) ...[
          pregToolPad(PregSectionHeading(g.$1)),
          const SizedBox(height: 10),
          pregToolPad(PregRowCard(children: [
            for (final w in g.$2) _WeekRow(
              week: w,
              isNow: w.week == c.currentWeek,
              open: _open == w.week,
              onTap: () => setState(() => _open = _open == w.week ? -1 : w.week),
            ),
          ])),
          const SizedBox(height: 24),
        ],
        if (groups.isEmpty)
          pregToolPad(const PregNote('The weekly lines are still loading. Try again in a moment.')),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.week, required this.isNow, required this.open, required this.onTap});
  final WeekContent week;
  final bool isNow;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final pc = week.partner;
    final mission = pc.oneMission.en.trim();
    return InkWell(
      key: ValueKey('partner_week_${week.week}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(isNow ? 'Week ${week.week}  ·  this week' : 'Week ${week.week}',
                  style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
            ),
            Icon(open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: p.ink3),
          ]),
          if (mission.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(mission, style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
          ],
          if (open) ...[
            const SizedBox(height: 12),
            _Block(label: 'WHAT SHE MAY FEEL', text: pc.whatSheMayFeel.en),
            _Block(label: 'WHAT YOU CAN DO', text: pc.whatYouCanDo.en),
            if (pc.shareMessage.en.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              OutlinedButton.icon(
                key: ValueKey('partner_week_share_${week.week}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPvInk,
                  side: const BorderSide(color: kPvLine),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Share.share(pc.shareMessage.en.trim()),
                icon: const Icon(Icons.ios_share_rounded, size: 16),
                label: Text('Share this week', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: kPvInk)),
              ),
            ],
          ],
        ]),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.label, required this.text});
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
        const SizedBox(height: 4),
        Text(text.trim(), style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1)),
      ]),
    );
  }
}

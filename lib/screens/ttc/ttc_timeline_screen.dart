// =============================================================================
//  Family Timeline
// -----------------------------------------------------------------------------
//  One continuous life story - the feature the master document names as the one
//  it thinks is missing (p.117).
//
//  The design rule that makes it work: it is grouped by YEAR, not by stage.
//  Grouping by stage would draw exactly the boundary the whole product exists
//  to remove - "here is your TTC section, here is your pregnancy section". A
//  family does not experience their life in product modules. The stage is a
//  small tag on each row, nothing more.
//
//  It lives in the TTC module today because TTC is the first stage to write to
//  it, but FamilyTimeline itself belongs to no stage - pregnancy and parenting
//  backfill into the same log later without this screen changing.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/family_timeline.dart';
import '../../services/life_stage_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

void openTtcTimeline(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcTimelineScreen(),
    settings: const RouteSettings(name: 'ttc/timeline'),
  ));
}

class TtcTimelineScreen extends StatelessWidget {
  const TtcTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([FamilyTimeline.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final events = FamilyTimeline.instance.events;

        // Grouped by year. A life story reads in years, not in modules.
        final byYear = <int, List<TimelineEvent>>{};
        for (final e in events) {
          byYear.putIfAbsent(e.date.year, () => []).add(e);
        }
        final years = byYear.keys.toList()..sort();

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.familyTimeline),
                const SizedBox(height: 16),
                Text(t.familyTimelineIntro, style: ttcBody(13.5, h: 1.6)),
                const SizedBox(height: 20),

                if (events.isEmpty)
                  TtcEmpty(
                    icon: Icons.timeline_rounded,
                    title: t.timelineEmptyTitle,
                    body: t.timelineEmptyBody,
                  )
                else
                  for (final year in years) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 4),
                      child: Text('$year',
                          style: ttcFraunces(24,
                              w: FontWeight.w600, color: ttcTitleInk)),
                    ),
                    for (final e in byYear[year]!) ...[
                      _EventRow(event: e, t: t),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 14),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.t});

  final TimelineEvent event;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final detail = event.detail(hi);
    return TtcCard(
      padding: const EdgeInsets.all(15),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ttcPanel, shape: BoxShape.circle),
          child: Icon(_icon(event.kind), size: 16, color: ttcPurple),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(event.title(hi), style: ttcJakarta(14.5))),
              Text(_fmt(event.date),
                  style: ttcBody(11, color: ttcMuted, w: FontWeight.w700)),
            ]),
            if (detail != null) ...[
              const SizedBox(height: 5),
              Text(detail, style: ttcBody(12.5, h: 1.5)),
            ],
            const SizedBox(height: 7),
            // The stage is a small tag, never a section heading.
            Text(event.stage.label(hi).toUpperCase(),
                style: ttcBody(9, color: ttcMuted, w: FontWeight.w800)),
          ]),
        ),
      ]),
    );
  }

  IconData _icon(TimelineKind kind) {
    switch (kind) {
      case TimelineKind.milestone:
        return Icons.auto_awesome_rounded;
      case TimelineKind.medical:
        return Icons.medical_services_outlined;
      case TimelineKind.written:
        return Icons.edit_outlined;
      case TimelineKind.people:
        return Icons.people_outline_rounded;
      case TimelineKind.action:
        return Icons.check_circle_outline_rounded;
    }
  }

  static String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }
}

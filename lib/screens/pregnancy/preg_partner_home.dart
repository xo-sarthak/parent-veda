// =============================================================================
//  preg_partner_home.dart — his side of the pregnancy home (2026-10-13)
// =============================================================================
//
//  HIS SIDE IS HER HOME WITH LESS ON IT, AND ONE BLOCK OF HIS OWN — the same
//  shape as trying to conceive (`ttc_partner_home.dart`, 2026-10-10: "it
//  should not look like a different application").
//
//  What the research said (Mobbin + the competitor walks, 2026-10-13):
//    * Flo for Partners: a view-only copy of her day, insights about her,
//      nothing he can log and nothing private. In pregnancy mode Flo still
//      pitches trying to conceive.
//    * What to Expect: no partner mode, a "Partners" topic, week-by-week advice
//      for dads, his part in labour.
//    * Our own pairing promise: he never sees her symptoms, weight, journal or
//      records.
//
//  So on her home he keeps the week, the baby, the doors, the film, the reads,
//  the products and the experts; her logging and records are hidden there
//  (`him` in home_v3_screen.dart). What he gets instead is this block: his
//  part this week, how she may be feeling and what he can do, the scans coming
//  up (view-only), talking to the baby, his own journal and the partner guide.
//  Everything here comes from data the old Slate Today already read
//  (`father_daily_screen.dart`, kept for revert), so no new claim is made.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_partner.dart' show kPartnerSurfaceDoor;
import '../../data/scan_schedule.dart' show scansDueAt;
import '../../services/pregnancy_controller.dart';
import '../../services/scans_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../doors/pv_door_router.dart' show openPvDoorSurface;
import '../father/father_journal_screen.dart';
import '../father/father_read_aloud_screen.dart';
import '../father/father_week_guide_screen.dart' show openFatherWeekGuide;
import '../preg_daily_insights.dart' show PregInsight;
import '../v2/v2_palette.dart';

/// The insight cards about the week and the baby: his rail. Anything she
/// logs (symptoms, "how are you today", food she ate, a move she did) and the
/// "can I" cards about her own body stay hers.
bool pregInsightForHim(PregInsight c) =>
    c.id == 'scan' ||
    c.id == 'forming' ||
    c.id == 'size' ||
    c.id.startsWith('scan_window_') ||
    c.id.startsWith('myth_') ||
    c.id.startsWith('read_');

List<PregInsight> pregRailForHim(List<PregInsight> all) =>
    [for (final c in all) if (pregInsightForHim(c)) c];

class PregPartnerHomeBlock extends StatelessWidget {
  const PregPartnerHomeBlock({
    super.key,
    required this.p,
    required this.pregnancy,
  });

  final V2Palette p;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final week = pregnancy.currentWeek;
    final w = pregnancy.weekData(week);
    final corner = w?.partner;
    final mission = corner?.oneMission.en.trim() ?? '';
    final feel = corner?.whatSheMayFeel.en.trim() ?? '';
    final canDo = corner?.whatYouCanDo.en.trim() ?? '';

    final items = <Widget>[
      _Ruled(
        p: p,
        key: const ValueKey('preg_partner_mission'),
        eyebrow: 'Your part this week',
        title: mission.isEmpty
            ? 'Week $week: be there, and ask how she is.'
            : mission,
        link: ('Every week, for you',
            () => openFatherWeekGuide(context, pregnancy)),
      ),
      if (feel.isNotEmpty || canDo.isNotEmpty)
        _Ruled(
          p: p,
          key: const ValueKey('preg_partner_support'),
          eyebrow: 'How she may be feeling',
          body: feel.isEmpty ? null : feel,
          second: canDo.isEmpty ? null : ('What you can do', canDo),
        ),
      _ScansAhead(p: p, week: week),
      _Ruled(
        p: p,
        key: const ValueKey('preg_partner_talk'),
        eyebrow: 'Talk to your baby',
        title: 'Your voice is one of the sounds the baby comes to know.',
        body: 'A short read for tonight, chosen for this week.',
        link: ('Read aloud',
            () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'father/read_aloud'),
                builder: (_) => FatherReadAloudScreen(controller: pregnancy)))),
      ),
      _Ruled(
        p: p,
        key: const ValueKey('preg_partner_journal'),
        eyebrow: 'Your journal',
        title: 'A line for yourself, about this week.',
        body: "It's yours. She won't see it unless you share it.",
        link: ('Open your journal',
            () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'father/journal'),
                builder: (_) => FatherJournalScreen(controller: pregnancy)))),
      ),
      _Ruled(
        p: p,
        key: const ValueKey('preg_partner_guide'),
        eyebrow: 'The partner guide',
        body: 'What to expect, how to help in labour, and the first weeks '
            'at home.',
        link: ('Open the guide',
            () => openPvDoorSurface(context, kPartnerSurfaceDoor, pregnancy)),
      ),
    ];

    return Column(
      key: const ValueKey('preg_partner_block'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FOR YOU',
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: p.ink3)),
        const SizedBox(height: 4),
        Text('Your part this week',
            style: pvFraunces(fontSize: 22, color: p.ink1)),
        const SizedBox(height: 16),
        for (var i = 0; i < items.length; i++) ...[
          items[i],
          if (i < items.length - 1) const SizedBox(height: 22),
        ],
      ],
    );
  }
}

/// The scans and appointments coming up, view-only: he can see what is next
/// and when, never edit her record.
class _ScansAhead extends StatelessWidget {
  const _ScansAhead({required this.p, required this.week});
  final V2Palette p;
  final int week;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: ScansStore.instance,
        builder: (context, _) {
          final due = scansDueAt(week)
              .where((m) => !ScansStore.instance.isCompleted(m.id))
              .map((m) => m.title.en)
              .toList();
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final appts = ScansStore.instance.appointments
              .where((a) => !a.date.isBefore(today))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
            'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          final lines = [
            for (final t in due) '$t, due around now',
            for (final a in appts.take(3))
              '${a.title}, ${a.date.day} ${months[a.date.month - 1]}',
          ];
          return _Ruled(
            p: p,
            key: const ValueKey('preg_partner_scans'),
            eyebrow: 'Scans coming up',
            title: lines.isEmpty ? 'Nothing due right now.' : null,
            body: lines.isEmpty
                ? 'When a scan or a visit is near, it shows here, so you can '
                    'plan to be there.'
                : lines.join('\n'),
          );
        },
      );
}

class _Ruled extends StatelessWidget {
  const _Ruled({
    super.key,
    required this.p,
    required this.eyebrow,
    this.title,
    this.body,
    this.second,
    this.link,
  });
  final V2Palette p;
  final String eyebrow;
  final String? title;
  final String? body;
  final (String, String)? second;
  final (String, VoidCallback)? link;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 2, 0, 2),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: p.ink1, width: 1.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow.toUpperCase(),
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: p.ink2)),
        if (title != null) ...[
          const SizedBox(height: 6),
          Text(title!,
              style: pvFraunces(fontSize: 19, height: 1.25, color: p.ink1)),
        ],
        if (body != null && body!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(body!,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        ],
        if (second case (final label, final text)) ...[
          const SizedBox(height: 12),
          Text(label,
              style: pvFraunces(fontSize: 17, height: 1.25, color: p.ink1)),
          const SizedBox(height: 6),
          Text(text,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        ],
        if (link case (final label, final onTap)) ...[
          const SizedBox(height: 10),
          PvPress(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(label,
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink1)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16, color: p.ink1),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

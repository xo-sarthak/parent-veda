// =============================================================================
//  HealthHomeScreen - ParentVeda Health (a living health companion)
// -----------------------------------------------------------------------------
//  One continuous, calm flow (no tabs, no folders): a Health Snapshot, the
//  Health Timeline (the backbone), Growth, a Vaccination SUMMARY that opens the
//  existing tracker, Medical History, AI-style insights, the Doctor Visit
//  Companion and the Emergency Card. Answers "how is my child's health today,
//  and what do I need to know?". Reached from the Explore drawer. Vaccination is
//  an existing module - integrated here, never redesigned.
// =============================================================================

import 'package:flutter/material.dart';

import 'baby_documents_screen.dart';
import 'health_doctor_visit_screen.dart';
import 'health_emergency_screen.dart';
// Old light growth screen retired in favour of the new Growth Journey tool
// (kept for revert). import 'health_growth_screen.dart';
import 'growth_journey_screen.dart';
import 'health_guide_screen.dart';
import 'health_records_screen.dart';
import 'health_timeline_screen.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_growth_data.dart';
import 'pp_health_data.dart';
import 'pp_vaccine_data.dart';
import 'vax_tracker_screen.dart';
// Redesigned tracker (vax_tracker_screen) is the live entry now; the old
// VaccinationScreen is kept for revert.
// import 'vaccination_screen.dart';

class HealthHomeScreen extends StatelessWidget {
  const HealthHomeScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  static Color statusColor(String s) => s == 'good' ? ppPurple : s == 'watch' ? ppCoral : ppMuted;

  @override
  Widget build(BuildContext context) {
    // Timeline now read inside _bucketedTimeline. Kept for revert.
    // final timeline = healthTimelineSorted();
    // 'latest' retired - the preview is bucketed now. Kept for revert.
    // final latest = timeline.where((e) => !e.upcoming).take(3).toList();
    final growth = GrowthStore.instance;
    final child = ChildProfileStore.instance;
    final current = growth.latest;
    return Scaffold(
      backgroundColor: ppBg,
      floatingActionButton: GestureDetector(
        onTap: () => openPpTab(context, 1),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 22, spreadRadius: -6, offset: Offset(0, 10))]),
          child: const Icon(Icons.auto_awesome, size: 24, color: Colors.white),
        ),
      ),
      // Listens to HealthStore so the moment she enters a measurement or marks a
      // dose, the not-yet-entered states swap for the real thing.
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          // Merged: the page now reads growth, vaccinations and the child
          // profile too, so a measurement logged or a dose marked anywhere
          // swaps the not-yet-entered states here immediately.
          animation: Listenable.merge([
            HealthStore.instance,
            GrowthStore.instance,
            VaxStore.instance,
            ChildProfileStore.instance,
          ]),
          builder: (context, _) => ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Explore')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('ParentVeda Health', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('${child.name}’s health', style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 6),
            _pad(Text('Not a folder of reports - the living story of ${child.their} health, understood.', style: ppBody(14, h: 1.5))),

            // 1 - snapshot, now compact. It was a 2x2 grid of tiles plus an
            // upcoming strip, which spent most of a screen saying "fine".
            const SizedBox(height: 20),
            _pad(_snapshot(context)),

            // 2 - TOOLS. Four things a parent DOES here, in one row at the top,
            // instead of three full-width CTAs scattered down the page. ID &
            // documents, the visit companion, the emergency card and the health
            // guide are all the same kind of thing - a tool - and now look it.
            const SizedBox(height: 16),
            _toolsRow(context),

            // 3 - timeline preview, BUCKETED. Mixed rows read as noise ("4-month
            // well-baby check, 14-week vaccination, mild cold") - the full
            // timeline already separates doctor visits from vaccinations from
            // illness, and this now matches it.
            const SizedBox(height: 30),
            _pad(_sectionHeader('Health timeline', 'Full timeline →', () => _push(context, const HealthTimelineScreen()))),
            const SizedBox(height: 6),
            _pad(Text('Grouped the way you would look for it - visits, vaccinations, illness.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(_bucketedTimeline(context)),

            // 3 - growth. Two states: what she has entered, or an invitation to
            // enter it. The section NEVER disappears - a parent who has logged
            // nothing must still learn growth can be tracked here.
            const SizedBox(height: 22),
            _pad(_sectionHeader('Growth', 'Details →', () => _push(context, const GrowthJourneyScreen()))),
            const SizedBox(height: 14),
            if (HealthStore.instance.growthEntered && current != null)
              _pad(_growthCard(context, current))
            else
              _pad(_notEnteredYet(
                context,
                Icons.show_chart_rounded,
                'No measurements yet',
                'Add ${child.their} weight, height and head and we will place them on the curve for you - no charts to read yourself.',
                'Add measurements',
                () => _push(context, const GrowthJourneyScreen()),
              )),

            // 4 - vaccination summary (existing module), same two states
            const SizedBox(height: 30),
            _pad(_sectionHeader('Vaccinations')),
            const SizedBox(height: 14),
            if (HealthStore.instance.vaxEntered)
              _pad(_vaxCard(context))
            else
              _pad(_notEnteredYet(
                context,
                Icons.vaccines_outlined,
                'Nothing marked yet',
                'Mark the doses ${child.they} has had and we will keep the schedule, flag what is due, and remind you before it is.',
                'Open the tracker',
                () => _push(context, const VaxTrackerScreen()),
              )),

            // 5 - what we ASK HER to enter. Renamed from "Medical history",
            // which described a folder; this is a request. Baby documents left
            // for the tools row above - it is a tool, not a thing to log.
            const SizedBox(height: 30),
            _pad(_sectionHeader('Add & view records')),
            const SizedBox(height: 4),
            _pad(Text('The more you log, the more ${child.their} health story can tell you.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(_history(context)),

            // 6 - "What we noticed" LAST, and only when there is genuinely
            // something to say. An insights card that always fires has nothing
            // to be trusted with.
            const SizedBox(height: 30),
            _pad(_insights(context)),
          ],
          ),
        ),
      ),
    );
  }

  // ---- tools row ----------------------------------------------------------
  //  Four icons, one horizontal row, right under the snapshot. These were three
  //  full-width CTAs strung down the page plus a text link at the very bottom -
  //  all the same KIND of thing, none of them looking like it.
  Widget _toolsRow(BuildContext context) {
    final tools = <(IconData, String, Color, VoidCallback)>[
      (Icons.badge_outlined, 'ID &\ndocuments', ppPurple, () => _push(context, const BabyDocumentsScreen())),
      (Icons.summarize_outlined, 'Doctor visit\ncompanion', ppPurple, () => _push(context, const HealthDoctorVisitScreen())),
      (Icons.emergency_outlined, 'Emergency\ncard', ppCoral, () => _push(context, const HealthEmergencyScreen())),
      (Icons.menu_book_outlined, 'Health\nguide', const Color(0xFF3E9A8C), () => _push(context, const HealthGuideScreen())),
    ];
    return _pad(Row(children: [
      for (final t in tools) ...[
        if (t != tools.first) const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: t.$4,
            behavior: HitTestBehavior.opaque,
            child: Column(children: [
              Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: t.$3.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(16)),
                child: Icon(t.$1, size: 22, color: t.$3),
              ),
              const SizedBox(height: 7),
              Text(t.$2,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ppBody(10.5, color: ppInk, w: FontWeight.w700, h: 1.25)),
            ]),
          ),
        ),
      ],
    ]));
  }

  // ---- bucketed timeline --------------------------------------------------
  //  Doctor visits, vaccinations and illness kept apart, each showing its most
  //  recent entry, so the preview matches how the full timeline is organised.
  Widget _bucketedTimeline(BuildContext context) {
    final all = healthTimelineSorted().where((e) => !e.upcoming).toList();
    final buckets = <(String, List<HealthEventType>)>[
      ('Doctor visits', [HealthEventType.doctorVisit, HealthEventType.assessment]),
      ('Vaccinations', [HealthEventType.vaccination]),
      ('Illness & symptoms', [HealthEventType.illness, HealthEventType.allergy]),
    ];
    return Column(children: [
      for (final b in buckets) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(children: [
            Text(b.$1.toUpperCase(),
                style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.7)),
          ]),
        ),
        // Empty buckets still show their heading and an invitation - a parent
        // who has logged no illness should still learn she can.
        if (all.where((e) => b.$2.contains(e.type)).isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
              child: Text('Nothing logged yet.', style: ppBody(12.5, color: ppMuted)),
            ),
          )
        else
          for (final e in all.where((e) => b.$2.contains(e.type)).take(2))
            _timelineRow(context, e),
        const SizedBox(height: 6),
      ],
    ]);
  }

  // ---- snapshot -----------------------------------------------------------
  Widget _snapshot(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: ppHair), boxShadow: ppCardShadow),
        child: Column(children: [
          // One row of four, not a 2x2 grid. This block used to spend most of a
          // screen to say "fine". Tapping explains where each verdict comes
          // from - "overall good" is worthless if a parent cannot see what it
          // is reading, and worse than worthless if she assumes we know more
          // than we do.
          GestureDetector(
            onTap: () => _explainSnapshot(context),
            behavior: HitTestBehavior.opaque,
            child: Column(children: [
              Row(children: [
                for (int i = 0; i < _snapshotStats().length && i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _statTile(_snapshotStats()[i])),
                ],
              ]),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.info_outline_rounded, size: 13, color: ppPurple),
                const SizedBox(width: 5),
                Expanded(
                  child: Text('How we work this out',
                      style: ppBody(11.5, color: ppPurple, w: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.event_outlined, size: 16, color: ppPurple),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('UPCOMING', style: ppBody(9, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                  const SizedBox(height: 2),
                  // Was the const 'PCV dose 3 · due 22 Jul' - a date from our
                  // demo child. Now the real next visit, or nothing pending.
                  Text(_upcoming(), style: ppBody(12.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]),
          ),
        ]),
      );

  /// Where each verdict comes from, and — just as importantly — what it does
  /// NOT know. A parent who reads "overall good" and assumes we have seen a
  /// doctor's report has been misled by our own summary.
  void _explainSnapshot(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: ppBg,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Text('How we work this out', style: ppFraunces(23, h: 1.15)),
              const SizedBox(height: 10),
              Text('Each line reads only what you have entered in ParentVeda. Nothing here comes from a clinic, and none of it is a medical assessment.',
                  style: ppBody(13.5, color: ppInk, h: 1.6)),
              const SizedBox(height: 18),
              for (final row in const [
                ('Overall', 'A plain roll-up of the three below. It says "good" when none of them need attention — never that a doctor has checked him.'),
                ('Growth', 'Your logged weight, height and head measurements, placed against the WHO reference band for his age.'),
                ('Vaccinations', 'The national schedule for his age, against the doses you have marked done.'),
                ('Allergies', 'Only what you have recorded yourself. An empty list means nothing has been entered, not that none exist.'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(row.$1.toUpperCase(),
                        style: ppBody(9.5, color: ppPurple, w: FontWeight.w800).copyWith(letterSpacing: 0.7)),
                    const SizedBox(height: 4),
                    Text(row.$2, style: ppBody(13, color: ppInk, h: 1.55)),
                  ]),
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.favorite_border, size: 16, color: ppCoral),
                  const SizedBox(width: 10),
                  Expanded(child: Text('If anything here worries you, your paediatrician is the right call — not this page.',
                      style: ppBody(12.5, color: ppInk, h: 1.5))),
                ]),
              ),
            ]),
          ),
        ),
      );

  /// The next thing actually coming up, from the real schedule.
  String _upcoming() {
    final vax = VaxStore.instance;
    final next = vax.dueVisit ?? vax.nextVisit;
    if (next == null) return 'Nothing scheduled right now';
    return '${next.lead.shortName} · ${next.ageLabel}';
  }

  /// The four snapshot tiles, DERIVED from what she has actually recorded.
  ///
  /// These were the const kHealthSnapshot: "Overall: Healthy", "Growth: On
  /// track", "Vaccinations: Up to date", "Allergies: None recorded" - four
  /// confident verdicts about a child we knew nothing about. A parent who had
  /// entered nothing was still told her baby was healthy and up to date. Now an
  /// unknown reads as "Not recorded", which is both true and an invitation.
  List<HealthStat> _snapshotStats() {
    final health = HealthStore.instance;
    final growth = GrowthStore.instance;
    final vax = VaxStore.instance;

    final hasGrowth = growth.latest != null;
    final dosesDone = kVaxVisits.where((v) => vax.statusOf(v) == VaxStatus.done).length;
    final due = vax.dueVisit;

    return [
      // "Overall" is only meaningful once there is something to summarise.
      HealthStat('Overall', health.hasAnyEntry ? 'On track' : 'Not recorded',
          health.hasAnyEntry ? 'good' : 'neutral'),
      HealthStat('Growth', hasGrowth ? 'On track' : 'Not recorded',
          hasGrowth ? 'good' : 'neutral'),
      HealthStat(
          'Vaccinations',
          dosesDone == 0
              ? 'Not recorded'
              : (due == null ? 'Up to date' : 'One due'),
          dosesDone == 0 ? 'neutral' : (due == null ? 'good' : 'watch')),
      // "None recorded" is honest either way here - but say it plainly.
      HealthStat('Allergies',
          health.allergies.isEmpty ? 'None recorded' : '${health.allergies.length} recorded',
          'neutral'),
    ];
  }

  Widget _statTile(HealthStat s) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: ppBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.label.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 7),
          Row(children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor(s.status), shape: BoxShape.circle)),
            const SizedBox(width: 7),
            Expanded(child: Text(s.value, style: ppJakarta(11.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ]),
      );

  // ---- timeline row -------------------------------------------------------
  Widget _timelineRow(BuildContext context, HealthEvent e) => GestureDetector(
        onTap: () => _push(context, const HealthTimelineScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: Icon(healthEventIcon(e.type), size: 18, color: ppPurple)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(e.title, style: ppJakarta(14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Text(e.date, style: ppBody(10.5, color: ppMuted)),
                ]),
                const SizedBox(height: 3),
                Text(e.summary, style: ppBody(12.5, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ]),
        ),
      );

  // ---- growth -------------------------------------------------------------
  /// Her own latest measurement. Was `kGrowth.last` + `kGrowthInterpretation`,
  /// a const row of figures and a sentence naming Aarav - shown to everyone.
  Widget _growthCard(BuildContext context, GrowthMeasurement g) {
    final store = GrowthStore.instance;
    final child = ChildProfileStore.instance;
    final pct = store.latestPercentilePhrase(GrowthMetric.weight);
    return GestureDetector(
      onTap: () => _push(context, const GrowthJourneyScreen()),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _measure('Weight', '${_trim(g.weightKg)} kg')),
            Expanded(child: _measure('Length', '${_trim(g.heightCm)} cm')),
            Expanded(child: _measure('Head', g.headCm == null ? '—' : '${_trim(g.headCm!)} cm')),
            Expanded(child: _measure('Centile', pct ?? '—')),
          ]),
          const SizedBox(height: 14),
          Text(child.growthNote, style: ppBody(13, h: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Widget _measure(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.4), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(value, style: ppJakarta(14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]);

  // ---- vaccination summary ------------------------------------------------
  /// The not-yet-entered state for a health section. An invitation, never a
  /// hidden section: a parent who has logged nothing must still learn the
  /// feature exists. See docs/PERSONALIZATION.md section 3.
  Widget _notEnteredYet(BuildContext context, IconData icon, String title,
          String body, String cta, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ppHair),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, size: 17, color: ppPurple),
              const SizedBox(width: 9),
              Expanded(child: Text(title, style: ppJakarta(15))),
            ]),
            const SizedBox(height: 8),
            Text(body, style: ppBody(13, color: ppSoft, h: 1.55)),
            const SizedBox(height: 12),
            Row(children: [
              Text(cta, style: ppBody(13, color: ppPurple, w: FontWeight.w800)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 15, color: ppPurple),
            ]),
          ]),
        ),
      );

  Widget _vaxPointer(IconData icon, Color color, String text) => Row(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 9),
        Expanded(child: Text(text, style: ppBody(12.5, color: ppInk), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]);

  /// Reads what SHE has marked. The status line, the "7 of 8" count and the
  /// "next up" date were all consts - so a parent who had marked one dose was
  /// still told she was "Up to date", with a next-due date from our demo data.
  Widget _vaxCard(BuildContext context) {
    final vax = VaxStore.instance;
    final done = kVaxVisits.where((v) => vax.statusOf(v) == VaxStatus.done).length;
    final due = vax.dueVisit;
    final next = due ?? vax.nextVisit;
    // "Up to date" only when nothing is actually waiting.
    final upToDate = due == null;
    final headline = upToDate ? 'Up to date' : 'One is due now';
    final tint = upToDate ? const Color(0xFF3E7A52) : const Color(0xFFC98A2B);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // The headline looks like one: a tick block, not a bullet in a list.
        // What is done and what is next then read as two plain pointers.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: upToDate ? const Color(0xFFEDF5EE) : const Color(0xFFFBF3E6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tint.withValues(alpha: 0.28)),
          ),
          child: Row(children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Icon(upToDate ? Icons.check_rounded : Icons.schedule_rounded,
                  size: 16, color: Colors.white),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(headline,
                  style: ppJakarta(15).copyWith(
                      color: upToDate ? const Color(0xFF2F5C3E) : const Color(0xFF7A5518)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        _vaxPointer(Icons.check_circle_outline_rounded, const Color(0xFF3E7A52),
            '$done of ${kVaxVisits.length} visits marked done'),
        if (next != null) ...[
          const SizedBox(height: 7),
          _vaxPointer(Icons.schedule_rounded, const Color(0xFFC98A2B),
              'Next up: ${next.lead.shortName} · ${next.ageLabel}'),
        ],
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _push(context, const VaxTrackerScreen()),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(child: Text('Open Vaccination Tracker', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
              ]),
            ),
          ),
        ]),
    );
  }

  // ---- medical history ----------------------------------------------------
  Widget _history(BuildContext context) {
    final rows = <(IconData, String, VoidCallback)>[
      (Icons.medical_services_outlined, 'Doctor visits', () => _push(context, const HealthRecordsScreen(category: 'visits'))),
      (Icons.medication_outlined, 'Medications', () => _push(context, const HealthRecordsScreen(category: 'medications'))),
      (Icons.receipt_long_outlined, 'Prescriptions', () => _push(context, const HealthRecordsScreen(category: 'prescriptions'))),
      (Icons.description_outlined, 'Reports', () => _push(context, const HealthRecordsScreen(category: 'reports'))),
      (Icons.healing_outlined, 'Symptoms', () => _push(context, const HealthRecordsScreen(category: 'symptoms'))),
      (Icons.shield_outlined, 'Allergies', () => _push(context, const HealthRecordsScreen(category: 'allergies'))),
      // Baby documents moved OUT - it lives in the tools row now. It is
      // something you keep, not something you log alongside symptoms.
      // (Icons.folder_outlined, 'Baby documents', () => _push(context, const BabyDocumentsScreen())),
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (int i = 0; i < rows.length; i++)
          GestureDetector(
            onTap: rows[i].$3,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(border: Border(bottom: i == rows.length - 1 ? BorderSide.none : const BorderSide(color: ppHair))),
              child: Row(children: [
                Icon(rows[i].$1, size: 19, color: ppPurple),
                const SizedBox(width: 14),
                Expanded(child: Text(rows[i].$2, style: ppBody(14.5, color: ppInk, w: FontWeight.w600))),
                const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
              ]),
            ),
          ),
      ]),
    );
  }

  // ---- AI insights --------------------------------------------------------
  /// DYNAMIC: it only appears when there is genuinely something to say. A
  /// "what we noticed" card that fires whether or not anything was noticed
  /// teaches a parent to stop reading it — which costs us the one moment it
  /// might actually matter.
  Widget _insights(BuildContext context) {
    // Nothing of HERS to notice yet means we have nothing to say - and saying
    // it anyway, from seed data, would be inventing an observation.
    if (!HealthStore.instance.hasAnyEntry) return const SizedBox.shrink();
    // HIDDEN ENTIRELY until the insights are derived. kHealthInsights is a
    // const list of observations about our demo child ("growing steadily",
    // "settled well after the 14-week vaccines"). Gating on hasAnyEntry stopped
    // it firing for a parent who had entered nothing, but the moment she
    // entered ANYTHING she was shown conclusions drawn from somebody else's
    // baby - dressed as "What we notice". A real engine replaces this; until
    // then saying nothing is the honest option.
    if (_derivedInsights().isEmpty) return const SizedBox.shrink();
    return _insightsCard(context);
  }

  /// Observations we can actually stand behind, derived from her records.
  /// Empty until there is a real insight engine - deliberately.
  List<String> _derivedInsights() => const [];

  Widget _insightsCard(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFF6ECEF)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome, size: 16, color: ppPurple),
            const SizedBox(width: 8),
            ppEyebrow('What we notice', color: ppPurple, spacing: 1.0),
          ]),
          const SizedBox(height: 12),
          for (final s in _derivedInsights())
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(margin: const EdgeInsets.only(top: 7), width: 5, height: 5, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)),
                const SizedBox(width: 11),
                Expanded(child: Text(s, style: ppBody(13, color: ppInk, h: 1.5))),
              ]),
            ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => openPpTab(context, 1),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              Flexible(child: Text('Explore this with AskVeda', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 14, color: ppPurple),
            ]),
          ),
          const SizedBox(height: 8),
          Text('Patterns from your records - general understanding, never a diagnosis.', style: ppBody(11, color: ppMuted, h: 1.5)),
        ]),
      );

  // ---- CTAs ---------------------------------------------------------------
  // RETIRED - these became the tools row. Kept for revert.
  // ignore: unused_element
  Widget _bigCta(BuildContext context, IconData icon, Color accent, String title, String sub, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
          child: Row(children: [
            Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 21, color: accent)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ppJakarta(15)),
                const SizedBox(height: 2),
                Text(sub, style: ppBody(12, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  // RETIRED - the health guide is now the fourth tool. Kept for revert.
  // ignore: unused_element
  Widget _healthGuideLink(BuildContext context) => GestureDetector(
        onTap: () => _push(context, const HealthGuideScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.menu_book_outlined, size: 19, color: ppPurple),
            const SizedBox(width: 13),
            Expanded(child: Text('Health Guide - what helped last time & telehealth', style: ppBody(13.5, color: ppInk, w: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  // ---- shared -------------------------------------------------------------
  Widget _sectionHeader(String title, [String? action, VoidCallback? onAction]) => Row(children: [
        Expanded(child: Text(title, style: ppJakarta(18))),
        if (action != null) GestureDetector(onTap: onAction, behavior: HitTestBehavior.opaque, child: Text(action, style: ppBody(12, color: ppPurple, w: FontWeight.w700))),
      ]);
}

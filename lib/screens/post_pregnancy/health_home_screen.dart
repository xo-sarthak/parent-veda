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
import 'pp_common.dart';
import 'pp_health_data.dart';
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
    final timeline = healthTimelineSorted();
    final latest = timeline.where((e) => !e.upcoming).take(3).toList();
    final current = kGrowth.last;
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
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Explore')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('ParentVeda Health', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('Aarav’s health', style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 6),
            _pad(Text('Not a folder of reports - the living story of his health, understood.', style: ppBody(14, h: 1.5))),

            // 1 - snapshot
            const SizedBox(height: 22),
            _pad(_snapshot()),

            // ID & documents - kept high so a parent immediately sees where to
            // add the birth certificate, Aadhaar and other papers.
            const SizedBox(height: 12),
            _pad(_bigCta(context, Icons.badge_outlined, ppPurple, 'ID & documents', 'Birth certificate, Aadhaar & more - add and keep them in one calm place.', () => _push(context, const BabyDocumentsScreen()))),

            // 2 - timeline preview
            const SizedBox(height: 30),
            _pad(_sectionHeader('Health timeline', 'Full timeline →', () => _push(context, const HealthTimelineScreen()))),
            const SizedBox(height: 6),
            _pad(Text('Everything that’s happened, as a story - not folders to dig through.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(Column(children: [for (final e in latest) _timelineRow(context, e)])),

            // 3 - growth
            const SizedBox(height: 22),
            _pad(_sectionHeader('Growth', 'Details →', () => _push(context, const GrowthJourneyScreen()))),
            const SizedBox(height: 14),
            _pad(_growthCard(context, current)),

            // 4 - vaccination summary (existing module)
            const SizedBox(height: 30),
            _pad(_sectionHeader('Vaccinations')),
            const SizedBox(height: 14),
            _pad(_vaxCard(context)),

            // 5 - medical history
            const SizedBox(height: 30),
            _pad(_sectionHeader('Medical history')),
            const SizedBox(height: 4),
            _pad(Text('Organised for you - never a pile of PDFs.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(_history(context)),

            // 6 - AI insights
            const SizedBox(height: 30),
            _pad(_insights(context)),

            // Doctor Visit Companion + Emergency
            const SizedBox(height: 24),
            _pad(_bigCta(context, Icons.summarize_outlined, ppPurple, 'Doctor Visit Companion', 'Generate a ready-to-share summary before your next appointment.', () => _push(context, const HealthDoctorVisitScreen()))),
            const SizedBox(height: 12),
            _pad(_bigCta(context, Icons.emergency_outlined, ppCoral, 'Emergency Card', 'Blood group, allergies, contacts - ready offline, in seconds.', () => _push(context, const HealthEmergencyScreen()))),
            const SizedBox(height: 12),
            _pad(_healthGuideLink(context)),
          ],
        ),
      ),
    );
  }

  // ---- snapshot -----------------------------------------------------------
  Widget _snapshot() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: ppHair), boxShadow: ppCardShadow),
        child: Column(children: [
          Row(children: [
            for (int i = 0; i < 2; i++) ...[if (i > 0) const SizedBox(width: 12), Expanded(child: _statTile(kHealthSnapshot[i]))],
          ]),
          const SizedBox(height: 12),
          Row(children: [
            for (int i = 2; i < 4; i++) ...[if (i > 2) const SizedBox(width: 12), Expanded(child: _statTile(kHealthSnapshot[i]))],
          ]),
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
                  Text(kUpcomingHealth, style: ppBody(12.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]),
          ),
        ]),
      );

  Widget _statTile(HealthStat s) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: ppBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.label.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 7),
          Row(children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor(s.status), shape: BoxShape.circle)),
            const SizedBox(width: 7),
            Expanded(child: Text(s.value, style: ppJakarta(13.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
  Widget _growthCard(BuildContext context, GrowthPoint g) => GestureDetector(
        onTap: () => _push(context, const GrowthJourneyScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: _measure('Weight', '${g.weightKg} kg')),
              Expanded(child: _measure('Length', '${g.heightCm.toInt()} cm')),
              Expanded(child: _measure('Head', '${g.headCm.toInt()} cm')),
              Expanded(child: _measure('Centile', '${g.weightPct}th')),
            ]),
            const SizedBox(height: 14),
            Text(kGrowthInterpretation, style: ppBody(13, h: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  Widget _measure(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.4), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(value, style: ppJakarta(14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]);

  // ---- vaccination summary ------------------------------------------------
  Widget _vaxCard(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.vaccines_outlined, size: 20, color: ppPurple)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Text(kVaxStatus, style: ppJakarta(15)),
                ]),
                const SizedBox(height: 3),
                Text('$kVaxCompleted of $kVaxTotalDue milestones done · next: $kVaxNext', style: ppBody(12.5), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ]),
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

  // ---- medical history ----------------------------------------------------
  Widget _history(BuildContext context) {
    final rows = <(IconData, String, VoidCallback)>[
      (Icons.medical_services_outlined, 'Doctor visits', () => _push(context, const HealthRecordsScreen(category: 'visits'))),
      (Icons.medication_outlined, 'Medications', () => _push(context, const HealthRecordsScreen(category: 'medications'))),
      (Icons.receipt_long_outlined, 'Prescriptions', () => _push(context, const HealthRecordsScreen(category: 'prescriptions'))),
      (Icons.description_outlined, 'Reports', () => _push(context, const HealthRecordsScreen(category: 'reports'))),
      (Icons.healing_outlined, 'Symptoms', () => _push(context, const HealthRecordsScreen(category: 'symptoms'))),
      (Icons.shield_outlined, 'Allergies', () => _push(context, const HealthRecordsScreen(category: 'allergies'))),
      (Icons.folder_outlined, 'Baby documents', () => _push(context, const BabyDocumentsScreen())),
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
  Widget _insights(BuildContext context) => Container(
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
          for (final s in kHealthInsights)
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

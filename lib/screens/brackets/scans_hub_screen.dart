// =============================================================================
//  ScansHubScreen — Scans & tests, built to the Problem Hub spec
// -----------------------------------------------------------------------------
//  PARENTVEDA-PROBLEM-HUB-SPEC.md, PART A §1. Tracker-led / interpretation-led.
//
//  ⚠️ THIS FILE IS THIN ON PURPOSE. Everything that is *about Scans* lives in
//  `lib/data/hubs/scans_hub.dart`; everything that is *about hubs* lives in
//  `hub/problem_hub_screen.dart`. What remains here is the join: this stage's
//  router, and the one situational card only this bracket knows how to build.
//
//  That split is the answer to "build Scans now, iterate, then do the rest".
//  Iterating means editing the config. Starting hub #2 means adding a config —
//  not another screen.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE URGENT PATH IS KEPT, AND IS NOT IN THE SPEC'S §1 ENTRY
//  ---------------------------------------------------------------------------
//  §2 permits an urgent strip "only where red flags matter". Ectopic pregnancy
//  is ~74,000 searches a month and is a surgical emergency, so it matters here
//  more than anywhere else in the product.
//
//  It does not replace the spec's fourth entry point — "Know when to ask my
//  doctor" is a calm question asked in daylight; the strip is for someone who
//  is bleeding now and will not read four options first. Both route to the same
//  screen; two doors for two states of mind.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/hubs/scans_hub.dart';
import '../../data/hubs/scans_hub_v2.dart';
import '../../data/scan_schedule.dart';
import '../../data/tests_scans_reports_data.dart';
import '../../models/bracket.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scan_reports_store.dart';
import '../../services/scans_store.dart';
import '../../services/surface_router.dart';
import '../v2/v2_palette.dart';
import 'hub/problem_hub_screen.dart';
import '../prepare/consultations_screen.dart';
import '../report_screen.dart';
import 'scan_detail_screen.dart';
import 'scan_next_screen.dart';
import 'scan_reports_screen.dart';
import 'scan_schedule_screen.dart';
import 'scan_timeline_screen.dart';
import 'scan_urgent_screen.dart';
import 'scans_hub_version.dart';

/// The bracket this screen replaces the generic one for.
const String kScansBracketId = 'pregnancy_scans_tests';

class ScansHubScreen extends StatelessWidget {
  const ScansHubScreen(
      {super.key, required this.bracket, required this.pregnancy});

  final Bracket bracket;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: ScansHubVersionStore.instance,
        builder: (context, _) {
          final v2 =
              ScansHubVersionStore.instance.version == ScansHubVersion.v2;

          // ⚠️ ONE RENDERER, TWO CONFIGS. The versions differ in data, not in
          // code — which is what makes the comparison mean anything. If V2
          // needed its own screen the toggle would be comparing two
          // implementations rather than two ideas.
          return Stack(
            children: [
              ProblemHubScreen(
                config: v2 ? kScansHubV2 : kScansHub,
                bracket: bracket,
                lang: pregnancy.language,
                listenTo: Listenable.merge([
                  ScansStore.instance,
                  ScanReportsStore.instance,
                  V2PaletteStore.instance,
                ]),
                onSurface: _openSurface,
                onAction: _handleAction,
              ),
              const Positioned(
                right: 18,
                bottom: 26,
                child: ScansVersionPill(),
              ),
            ],
          );
        },
      );

  /// ⚠️ THROUGH THE STAGE'S OWN ROUTER, always. The hub renderer never imports
  /// a screen — that is what lets one renderer serve three stages whose routers
  /// are deliberately three separate files.
  void _openSurface(BuildContext context, String id) {
    final screen = screenForSurface(id, pregnancy, pregnancy.language);
    if (screen == null) return; // null is a real answer; see the router
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: id),
      builder: (_) => screen,
    ));
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case kActUrgent:
        _push(context, const ScanUrgentScreen(), 'scans/urgent');
      case kActSchedule:
        _push(context, ScanScheduleScreen(pregnancy: pregnancy),
            'scans/schedule');
      case kActNextScan:
        final scan = _nextScan();
        _push(
            context,
            scan == null
                ? ScanScheduleScreen(pregnancy: pregnancy)
                : ScanDetailScreen(scan: scan, pregnancy: pregnancy),
            'scans/detail');

      // ---- Excel journey step 1 -------------------------------------------
      case kActTimeline:
        _push(context, ScanTimelineScreen(pregnancy: pregnancy),
            'scans/timeline');

      // ---- Excel journey step 5 -------------------------------------------
      case kActWhatNext:
        _push(context, ScanNextScreen(pregnancy: pregnancy), 'scans/next');

      // ---- V2 · three doors and one closing offer -------------------------
      case kV2ActMyScans:
        _push(context, ScanTimelineScreen(pregnancy: pregnancy),
            'scans/timeline');

      case kV2ActMyReports:
        _push(context, ScanReportsScreen(pregnancy: pregnancy),
            'scans/reports');

      case kV2ActUnderstand:
        _push(context, ReportScreen(controller: pregnancy), 'scans/decoder');

      case kV2ActConsult:
        // ⚠️ The existing booking engine, configured — never a new appointment
        // feature. Prompt §7.
        _push(context, ConsultationsScreen(lang: pregnancy.language),
            'consults');
    }
  }

  void _push(BuildContext context, Widget s, String name) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: name), builder: (_) => s));

  /// The scan she is most likely asking about: the one booked soonest, else the
  /// one due around this week. Null when neither — the caller opens the
  /// schedule rather than guessing.
  TestScanInfo? _nextScan() {
    final store = ScansStore.instance;
    for (final a in store.appointments) {
      final d = DateTime.tryParse(a.dateIso);
      if (d == null) continue;
      final days = d.difference(DateTime.now()).inDays;
      if (days >= -1 && days <= 30) {
        final m = matchScan(a.title);
        if (m != null) return m;
      }
    }
    for (final m in scansDueAt(pregnancy.currentWeek)) {
      if (store.isCompleted(m.id)) continue;
      final s = matchScan(m.title.en);
      if (s != null) return s;
    }
    return null;
  }
}

/// Best-effort match from an appointment or milestone title to a library entry.
///
/// ⚠️ NULL IS A REAL ANSWER and every caller handles it by opening the schedule.
/// A wrong scan page is worse than a list — the same reason the surface router
/// returns null rather than guessing.
TestScanInfo? matchScan(String title) {
  final t = title.toLowerCase();
  for (final s in kTestsScans) {
    if (t.contains(s.name.en.toLowerCase())) return s;
    for (final a in s.aliases) {
      if (t.contains(a.en.toLowerCase())) return s;
    }
  }
  const phrasings = <String, String>{
    'anomaly': 'anomaly_scan',
    'level 2': 'anomaly_scan',
    'tiffa': 'anomaly_scan',
    'nuchal': 'nt_scan',
    'dating': 'dating_scan',
    'viability': 'dating_scan',
    'growth': 'growth_scan',
    'doppler': 'doppler',
    'glucose': 'ogtt',
    'ogtt': 'ogtt',
  };
  for (final e in phrasings.entries) {
    if (t.contains(e.key)) {
      for (final s in kTestsScans) {
        if (s.id == e.value) return s;
      }
    }
  }
  return null;
}

// ⚠️ THE SITUATIONAL CARD HAS BEEN REMOVED — FINAL SPEC §2.3.
//
// It showed "your anomaly scan is on Thursday" / "nine scans across the
// pregnancy" above the doors. The spec deletes it, and the reasoning is right:
// a generic informational card interrupts the task she opened the hub to do.
// She tapped Scans & tests to get somewhere; the first thing on the screen
// should not be about something else.
//
// The information itself is not lost — "what is coming and what it costs" is
// exactly what the "Understand my next scan" door opens, which is where it
// helps rather than where it interrupts.
//
// A contextual card may come back for a specific hub if it directly serves the
// current problem and the intent flow genuinely cannot carry it. It does not
// come back as a default.

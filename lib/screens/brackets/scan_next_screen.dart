// =============================================================================
//  ScanNextScreen — "What happens next?"
// -----------------------------------------------------------------------------
//  Journey step 5 of the Scans & tests hub, per
//  PARENTVEDA_FINAL_40_HUB_236_JOURNEY_RECONCILIATION.xlsx:
//
//    Journey step 5 · What happens next?
//    What happens next : Post-scan guidance → next test/appointment if known
//    Solution type     : Content + Tool
//    Content / D       : After-scan guidance
//    Tools / F         : appointments / due_date
//
//  This is the step that closes the journey. Prompt §4: "Every journey should
//  feel complete." Without it the hub ends at "here is your report", which is
//  where the actual question starts.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT ANSWERS ONE QUESTION AND HANDS OVER. §15 forbids repeating what an
//  earlier step already said, so this screen does NOT re-explain the scan (step
//  2 did) and does NOT decode the report (step 4 does). It says: that one is
//  behind you, here is what usually follows, here is what is due next, and here
//  is the way to a person if you need one.
//
//  ⚠️ NO NEW CONTENT SYSTEM — §5. Everything below is `TestScanInfo` and the
//  scan run, both of which already ship. What is new is only the sequencing.
//
//  ⚠️ ENGLISH ONLY FOR NOW. `_en(...)` = English now, Hindi owed (CLAUDE.md).
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/tests_scans_reports_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scans_store.dart';
import '../../theme/pv_fonts.dart';
import '../report_screen.dart';
import '../tools/scans_appointments_screen.dart';
import '../v2/v2_palette.dart';
import 'hub/hub_solution_cards.dart';
import 'scan_detail_screen.dart';
import 'scan_timeline_screen.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

class ScanNextScreen extends StatefulWidget {
  const ScanNextScreen({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  State<ScanNextScreen> createState() => _ScanNextScreenState();
}

class _ScanNextScreenState extends State<ScanNextScreen> {
  // ---------------------------------------------------------------------------
  //  ⚠️ A PREVIEW CONTROL, AND IT CANNOT REACH A MOTHER
  // ---------------------------------------------------------------------------
  //  This screen only has anything to say once a scan is behind her. At week 40
  //  with nothing marked done it correctly shows the invitation, which makes the
  //  interesting half of the screen impossible to look at during a review.
  //
  //  So: a toggle that pretends it is week 20 with the anomaly scan just done —
  //  the single most common real state this screen will ever be in.
  //
  //  It is wrapped in `kDebugMode`, so it is compiled out of any release build
  //  rather than merely hidden. A hidden-in-release control is one flag away
  //  from shipping; a compiled-out one is not there at all.
  //
  //  It changes NOTHING about the data. It substitutes a week and a completed
  //  scan for the two lookups below and leaves every store untouched — nothing
  //  is written, so leaving the toggle on cannot corrupt her real record.
  bool _preview = false;

  PregnancyController get pregnancy => widget.pregnancy;

  @override
  Widget build(BuildContext context) {
    final lang = S.current;

    return AnimatedBuilder(
      animation:
          Listenable.merge([ScansStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final store = ScansStore.instance;
        final week = _preview ? 20 : pregnancy.currentWeek;

        final last =
            _preview ? _scanById('anomaly_scan') : _mostRecentDone(store);
        final next = _preview
            ? _scanById('ogtt')
            : _nextDue(store, week);

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(_en('What happens next').of(lang),
                style: pvManrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: p.ink1)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
            children: [
              // ---- What is behind her --------------------------------------
              if (last != null) ...[
                _Eyebrow('THE ONE YOU HAVE DONE', p, lang),
                const SizedBox(height: 10),
                Text(last.name.of(lang),
                    style: pvFraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: p.ink1)),
                const SizedBox(height: 10),
                Text(last.interpretation.of(lang),
                    style: pvManrope(
                        fontSize: 14, height: 1.55, color: p.ink2)),
                if (last.interpretPointers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  for (final line in last.interpretPointers) ...[
                    _Pointer(line.of(lang), p),
                    const SizedBox(height: 8),
                  ],
                ],
                const SizedBox(height: 28),
              ] else ...[
                // ⚠️ NOT AN ERROR STATE. A mother can arrive here before any
                // scan is marked done — the door is always open, so the screen
                // says what it will hold rather than looking broken.
                _Eyebrow('ONCE A SCAN IS DONE', p, lang),
                const SizedBox(height: 10),
                Text(_en('This is where the result goes.').of(lang),
                    style: pvFraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: p.ink1)),
                const SizedBox(height: 10),
                Text(
                    _en('Mark a scan as done on your timeline and this page '
                            'will tell you what that result usually means, and '
                            'what is due after it.')
                        .of(lang),
                    style: pvManrope(
                        fontSize: 14, height: 1.55, color: p.ink2)),
                const SizedBox(height: 20),
                SolutionCard(
                  type: SolutionType.tool,
                  title: _en('Open your timeline'),
                  value: _en('Mark what you have already had done.'),
                  p: p,
                  lang: lang,
                  onTap: () => _push(
                      context,
                      ScanTimelineScreen(pregnancy: pregnancy),
                      'scans/timeline'),
                ),
                const SizedBox(height: 28),
              ],

              // ---- What is ahead -------------------------------------------
              _Eyebrow('WHAT IS DUE AFTER IT', p, lang),
              const SizedBox(height: 12),
              if (next != null) ...[
                SolutionCard(
                  type: SolutionType.tool,
                  title: next.name,
                  value: next.when,
                  p: p,
                  lang: lang,
                  onTap: () => _push(
                      context,
                      ScanDetailScreen(scan: next, pregnancy: pregnancy),
                      'scans/detail'),
                ),
                const SizedBox(height: 10),
              ] else ...[
                Text(
                    _en('Nothing else is scheduled on the usual run from here. '
                            'Your doctor may still add one.')
                        .of(lang),
                    style: pvManrope(
                        fontSize: 14, height: 1.55, color: p.ink2)),
                const SizedBox(height: 14),
              ],
              SolutionCard(
                type: SolutionType.tool,
                title: _en('Your appointments'),
                value: _en('What is booked, and what to carry.'),
                p: p,
                lang: lang,
                onTap: () => _push(
                    context,
                    ScansAppointmentsScreen(controller: pregnancy),
                    'appointments'),
              ),
              const SizedBox(height: 28),

              // ---- If the report raised something --------------------------
              _Eyebrow('IF SOMETHING ON THE REPORT WORRIED YOU', p, lang),
              const SizedBox(height: 12),
              SolutionCard(
                type: SolutionType.read,
                title: _en('Look up a line on your report'),
                value: _en('What it means, and what to ask about it.'),
                p: p,
                lang: lang,
                onTap: () => _push(
                    context, ReportScreen(controller: pregnancy),
                    'scans/decoder'),
              ),
              const SizedBox(height: 22),

              // ⚠️ The floor, and it is not negotiable. Anything clinical ends
              // by routing calmly to a doctor — never a reading of her result.
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                    _en('This is general information about what usually '
                            'follows a scan. It is not a reading of your '
                            'report. Your doctor has seen your scan and you '
                            'have not been given a diagnosis here — if a '
                            'result is worrying you, ask them.')
                        .of(lang),
                    style: pvManrope(
                        fontSize: 12.5, height: 1.5, color: p.ink3)),
              ),

              // ---- PREVIEW ONLY — compiled out of release --------------------
              if (kDebugMode) ...[
                const SizedBox(height: 28),
                _PreviewToggle(
                  preview: _preview,
                  realWeek: pregnancy.currentWeek,
                  p: p,
                  onChanged: (v) => setState(() => _preview = v),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _push(BuildContext context, Widget s, String name) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: name), builder: (_) => s));

  /// The scan she most recently marked done — the one this page is about.
  ///
  /// Null is a real answer and the caller renders the invitation instead.
  TestScanInfo? _mostRecentDone(ScansStore store) {
    CompletedScanRef? best;
    for (final c in store.completed) {
      final d = DateTime.tryParse(c.dateIso);
      if (d == null) continue;
      if (best == null || d.isAfter(best.when)) {
        best = CompletedScanRef(c.scanId, d);
      }
    }
    if (best == null) return null;
    for (final s in kTestsScans) {
      if (s.id == best.id) return s;
    }
    return null;
  }

  /// The next one on the run she has not done yet.
  TestScanInfo? _nextDue(ScansStore store, int week) {
    for (final (id, from, _) in kScanRun) {
      if (store.isCompleted(id)) continue;
      if (from < week - 2) continue; // well behind her — not "next"
      for (final s in kTestsScans) {
        if (s.id == id) return s;
      }
    }
    return null;
  }
}

/// A completed scan reduced to what the "most recent" comparison needs.
class CompletedScanRef {
  const CompletedScanRef(this.id, this.when);
  final String id;
  final DateTime when;
}

TestScanInfo? _scanById(String id) {
  for (final s in kTestsScans) {
    if (s.id == id) return s;
  }
  return null;
}

/// ⚠️ DEBUG ONLY. Two segments, in the shape of the app's other comparison
/// controls (the palette bar, the Classic/New toggle) rather than a switch —
/// so it reads as "which state am I looking at", not as a setting she owns.
class _PreviewToggle extends StatelessWidget {
  const _PreviewToggle({
    required this.preview,
    required this.realWeek,
    required this.p,
    required this.onChanged,
  });

  final bool preview;
  final int realWeek;
  final V2Palette p;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PREVIEW · NOT IN RELEASE',
              style: pvManrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(children: [
              _seg('Your week ($realWeek)', !preview, () => onChanged(false)),
              _seg('Week 20, scan just done', preview, () => onChanged(true)),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
              preview
                  ? 'Showing the anomaly scan as just completed, with the '
                      'glucose test next. Nothing has been saved.'
                  : 'Showing your real week and whatever you have marked done.',
              style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3)),
        ],
      );

  Widget _seg(String label, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? p.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                    color: on ? p.ink1 : p.ink3)),
          ),
        ),
      );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text, this.p, this.lang);
  final String text;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Text(_en(text).of(lang),
      style: pvManrope(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: p.action));
}

class _Pointer extends StatelessWidget {
  const _Pointer(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 5,
            height: 5,
            decoration:
                BoxDecoration(color: p.ink3, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: pvManrope(
                      fontSize: 13.5, height: 1.5, color: p.ink2))),
        ],
      );
}

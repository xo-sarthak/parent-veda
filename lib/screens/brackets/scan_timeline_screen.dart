// =============================================================================
//  ScanTimelineScreen — "See my timeline"
// -----------------------------------------------------------------------------
//  Journey step 1 of the Scans & tests hub, per
//  PARENTVEDA_FINAL_40_HUB_236_JOURNEY_RECONCILIATION.xlsx:
//
//    Journey step 1 · See my timeline
//    What happens next : Upcoming test/scan → due date/appointment context
//    Solution type     : Tool  ·  Tools / F : appointments / due_date
//
//  ---------------------------------------------------------------------------
//  ⚠️ ENGLISH ONLY FOR NOW — every string here is `_en(...)`, which per CLAUDE.md
//  means "English for now, Hindi owed" and is a greppable backlog rather than a
//  claim of completion. Never `_t(x, x)`: an identical pair reads as finished
//  work to every audit, which is how a data file was once reported done with 302
//  strings still English.
//  ---------------------------------------------------------------------------
//
//  ⚠️ WHY THIS IS NOT ScanScheduleScreen, WHICH ALREADY EXISTS
//
//  It nearly is, and the difference is the whole point of the step. The schedule
//  screen answers "what tests exist and what do they cost" — a table about
//  pregnancy in general. This step asks "where am I on the run of them", which
//  is a question about HER, and the Excel says so: the step's tools are
//  `appointments` AND `due_date`, not the scan library.
//
//  So this is the same nine scans read against three things the schedule screen
//  never looks at: her current week, her booked dates, and what she has already
//  done. NO NEW ENGINE, NO NEW DATA — prompt §11. The only new thing is the
//  arrangement, which is what the reconciliation calls orchestration.
//
//  ⚠️ THE DUE DATE IS SHOWN, NEVER RECALCULATED. `DueDateSource` records whether
//  it came from a scan, a transfer or a doctor; where it did, gestational age is
//  the clinic's. We print it and attribute it; we do not derive a second
//  opinion. See CLAUDE.md "Clinical invariants".
// =============================================================================

import 'package:flutter/material.dart';

// Kept for revert: this supplied kScanCost, whose two uses are commented out.
// ignore: unused_import
import '../../data/scan_extras.dart';
import '../../data/tests_scans_reports_data.dart';
import '../../localization/app_language.dart';
import '../../models/scan_appointment.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scans_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'scan_detail_screen.dart';

/// English for now, Hindi owed. `grep -c '_en('` is the size of what is left.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The nine, in the order they happen, with the week window each sits in.
///
/// ⚠️ The clinical order is a fact about pregnancy, not something to derive —
/// three of these share a trimester, so a `TrimesterTag` sort gets it wrong.
const List<(String, int, int)> kScanRun = [
  ('blood_tests', 6, 10),
  ('dating_scan', 6, 9),
  ('nt_scan', 11, 13),
  ('nipt', 10, 14),
  ('anomaly_scan', 18, 22),
  ('ogtt', 24, 28),
  ('growth_scan', 28, 36),
  ('doppler', 30, 40),
  ('gbs', 35, 37),
];

/// Where a row sits relative to her.
enum _Where { done, now, ahead, passed }

class ScanTimelineScreen extends StatelessWidget {
  const ScanTimelineScreen({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final lang = S.current;

    return AnimatedBuilder(
      animation:
          Listenable.merge([ScansStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final store = ScansStore.instance;
        final week = pregnancy.currentWeek;

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(_en('Your timeline').of(lang),
                style: pvManrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: p.ink1)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
            children: [
              _WhereYouAre(pregnancy: pregnancy, p: p, lang: lang),
              const SizedBox(height: 22),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.line),
                ),
                child: Column(children: [
                  for (final (id, from, to) in kScanRun) ...[
                    _TimelineRow(
                      scan: _byId(id),
                      from: from,
                      to: to,
                      where: _placeOf(id, from, to, week, store),
                      booked: _bookedFor(id, store),
                      p: p,
                      lang: lang,
                      pregnancy: pregnancy,
                    ),
                    if (id != kScanRun.last.$1)
                      Divider(
                          height: 1, thickness: 1, color: p.line, indent: 58),
                  ],
                ]),
              ),
              const SizedBox(height: 18),
              Text(
                  _en('Not every pregnancy needs every test on this list, and '
                          'your doctor may add one that is not here. This is '
                          'the usual run, not a rule.')
                      .of(lang),
                  style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3)),
            ],
          ),
        );
      },
    );
  }

  /// ⚠️ `done` beats everything. A scan she has marked complete is complete even
  /// if her week says it is still ahead — her record outranks our arithmetic,
  /// which is the truth hierarchy in one line.
  _Where _placeOf(String id, int from, int to, int week, ScansStore store) {
    if (store.isCompleted(id)) return _Where.done;
    if (week >= from && week <= to) return _Where.now;
    if (week < from) return _Where.ahead;
    return _Where.passed;
  }

  /// Her booked appointment for this scan, when she has one.
  Appointment? _bookedFor(String id, ScansStore store) {
    final scan = _byId(id);
    if (scan == null) return null;
    for (final a in store.appointments) {
      final t = a.title.toLowerCase();
      if (t.contains(scan.name.en.toLowerCase())) return a;
      for (final alias in scan.aliases) {
        if (t.contains(alias.en.toLowerCase())) return a;
      }
    }
    return null;
  }
}

TestScanInfo? _byId(String id) {
  for (final s in kTestsScans) {
    if (s.id == id) return s;
  }
  return null;
}

// -----------------------------------------------------------------------------
//  The header — her week and her due date, attributed
// -----------------------------------------------------------------------------

class _WhereYouAre extends StatelessWidget {
  const _WhereYouAre(
      {required this.pregnancy, required this.p, required this.lang});

  final PregnancyController pregnancy;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final week = pregnancy.currentWeek;
    // Kept for revert - the due-date line is commented out below:
    //   final due = pregnancy.dueDate;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_en('WHERE YOU ARE').of(lang),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.action)),
          const SizedBox(height: 8),
          Text(_en('Week $week').of(lang),
              style: pvFraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: p.ink1)),
          const SizedBox(height: 6),
          // ⚠️ THE DUE-DATE LINE IS OFF, KEPT FOR REVERT.
          //
          // It read "Due 12 Aug, from the date you entered" under the week
          // number. Removed per review: the week number above it already tells
          // her where she is, and restating the source of the date turns a
          // simple orientation line into a caveat about our own arithmetic.
          //
          // The clinical rule it was serving still holds and is not lost — the
          // due date is shown and attributed on the Due Date tool, which is
          // where its provenance belongs.
          //
          // Text(
          //     _en(pregnancy.dueDateFromClinic
          //             ? 'Due ${_d(due)}, the date your clinic gave you.'
          //             : 'Due ${_d(due)}, from the date you entered.')
          //         .of(lang),
          //     style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
        ],
      ),
    );
  }

  // Orphaned by the commented-out due-date line, kept on purpose: the
  // revert needs a block that still compiles.
  // ignore: unused_element
  static String _d(DateTime d) => '${d.day} ${_kMonths[d.month - 1]} ${d.year}';
}

const List<String> _kMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

// -----------------------------------------------------------------------------
//  One station on the rail
// -----------------------------------------------------------------------------

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.scan,
    required this.from,
    required this.to,
    required this.where,
    required this.booked,
    required this.p,
    required this.lang,
    required this.pregnancy,
  });

  final TestScanInfo? scan;
  final int from;
  final int to;
  final _Where where;
  final Appointment? booked;
  final V2Palette p;
  final AppLanguage lang;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final s = scan;
    if (s == null) return const SizedBox.shrink();

    final isNow = where == _Where.now;
    final isDone = where == _Where.done;
    // Kept for revert - the price line is commented out below:
    //   final cost = kScanCost[s.id];
    final b = booked;

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'scans/detail'),
        builder: (_) => ScanDetailScreen(scan: s, pregnancy: pregnancy),
      )),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Station(where: where, p: p),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name.of(lang),
                      style: pvFraunces(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: isDone ? p.ink3 : p.ink1)),
                  const SizedBox(height: 3),
                  Text(_en('Week $from–$to').of(lang),
                      style: pvManrope(fontSize: 12, color: p.ink3)),
                  // Her own booking outranks the window — if she has a date,
                  // that is the answer to "when", not the range.
                  if (b != null) ...[
                    const SizedBox(height: 6),
                    Text(
                        _en('Booked ${_short(b.dateIso)}'
                                '${b.time.isEmpty ? '' : ' · ${b.time}'}')
                            .of(lang),
                        style: pvManrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: p.action)),
                  ],
                  // ⚠️ PRICES ARE OFF ON THIS SCREEN, KEPT FOR REVERT.
                  //
                  // Removed per review. A rupee range beside every scan turns a
                  // medical timeline into a bill, and the cost question is
                  // better answered where she has actually asked it — inside a
                  // scan's own page, in context.
                  //
                  // if (cost != null && !isDone) ...[
                  //   const SizedBox(height: 6),
                  //   Text('₹${cost.low} – ₹${cost.high}',
                  //       style: pvManrope(fontSize: 12, color: p.ink3)),
                  // ],
                ],
              ),
            ),
            if (isNow)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: p.action.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(_en('NOW').of(lang),
                    style: pvManrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: p.action)),
              ),
          ],
        ),
      ),
    );
  }

  static String _short(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day} ${_kMonths[d.month - 1]}';
  }
}

/// The dot on the rail. Filled = done, ringed = now, hollow = ahead.
class _Station extends StatelessWidget {
  const _Station({required this.where, required this.p});

  final _Where where;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final done = where == _Where.done;
    final now = where == _Where.now;

    return SizedBox(
      width: 28,
      child: Column(
        children: [
          const SizedBox(height: 3),
          Container(
            width: now ? 18 : 14,
            height: now ? 18 : 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? p.action : Colors.transparent,
              border: Border.all(
                color: done || now ? p.action : p.ink3.withValues(alpha: 0.45),
                width: now ? 3 : 2,
              ),
            ),
            child: done ? Icon(Icons.check, size: 9, color: p.onAction) : null,
          ),
        ],
      ),
    );
  }
}

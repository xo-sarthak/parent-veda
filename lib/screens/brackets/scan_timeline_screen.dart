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
///
/// ⚠️ FOUR STATES, AND `next` IS THE ONE THAT DID NOT EXIST BEFORE.
///
/// The old enum had `now` — "her week falls inside this scan's window" — which
/// is a fact about the CALENDAR, not about her. It could mark two rows at once
/// (three windows overlap around week 28), and it marked nothing at all in the
/// gaps between windows, which is where a mother most wants to know what is
/// coming. Review: "the scan expected just next should show an animation."
///
/// So `next` is computed once for the whole list rather than per row — exactly
/// one scan can be next, and which one depends on the rows above it. See
/// `_nextId`.
///
///   · done     — she has marked it complete
///   · next     — the one she is heading for (animated)
///   · upcoming — after that, not yet due
///   · passed   — not marked done and its window has gone by
enum _Where { done, next, upcoming, passed }

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

        // ⚠️ COMPUTED ONCE, FOR THE WHOLE LIST. "Next" is the only state here
        // that a row cannot work out on its own — it depends on every row above
        // it — which is why it is not inside `_placeOf`.
        final nextId = _nextId(week, store);

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
              const SizedBox(height: 14),
              _Legend(p: p, lang: lang),
              const SizedBox(height: 18),
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
                      where: _placeOf(id, from, to, week, store, nextId),
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
  _Where _placeOf(
      String id, int from, int to, int week, ScansStore store, String? nextId) {
    if (store.isCompleted(id)) return _Where.done;
    if (id == nextId) return _Where.next;
    if (to < week) return _Where.passed;
    return _Where.upcoming;
  }

  /// The one scan she is heading for, or null when every scan is done.
  ///
  /// ⚠️ THE RULE, AND THE TWO IT BEATS.
  ///
  /// Next is the first scan she has not marked done **whose window has not
  /// already gone by** — read in clinical order, which `kScanRun` already
  /// holds. Two simpler rules were wrong:
  ///
  ///   · "first not-done" alone points at a scan from ten weeks ago the moment
  ///     she forgets to log one. The timeline would then spend the rest of the
  ///     pregnancy animating a row she has walked past, and the one thing on
  ///     the screen that is supposed to say *go here next* would be pointing
  ///     backwards.
  ///   · "the one whose window contains this week" marks two rows at once —
  ///     `growth_scan` (28–36) and `doppler` (30–40) overlap for eight weeks —
  ///     and marks none at all in the gaps, which is exactly when she is asking.
  ///
  /// The fallback matters too: if every remaining scan's window has passed,
  /// the earliest unfinished one is still the honest answer to "what next",
  /// so it is returned rather than leaving the list with nothing marked.
  String? _nextId(int week, ScansStore store) {
    String? fallback;
    for (final (id, _, to) in kScanRun) {
      if (store.isCompleted(id)) continue;
      fallback ??= id;
      if (to >= week) return id;
    }
    return fallback;
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

    final isNext = where == _Where.next;
    final isDone = where == _Where.done;
    // Kept for revert - the price line is commented out below:
    //   final cost = kScanCost[s.id];
    final b = booked;

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'scans/detail'),
        builder: (_) => ScanDetailScreen(scan: s, pregnancy: pregnancy),
      )),
      // ⚠️ THE NEXT ROW IS TINTED, NOT JUST BADGED. A badge alone reads as a
      // label on an otherwise identical row; the wash is what makes the row
      // itself look different when the page is scanned rather than read.
      child: Container(
        color: isNext ? p.action.withValues(alpha: 0.05) : null,
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
                          // Next is the heaviest thing in the list; done is the
                          // lightest. Weight carries the state for anyone who
                          // cannot separate the dot colours.
                          fontWeight:
                              isNext ? FontWeight.w700 : FontWeight.w600,
                          height: 1.25,
                          color: isDone ? p.ink3 : p.ink1)),
                  const SizedBox(height: 3),
                  Text(_en('Week $from–$to').of(lang),
                      style: pvManrope(fontSize: 12, color: p.ink3)),
                  // ⚠️ THE PASSED STATE SAYS "not marked", NEVER "missed".
                  //
                  // We do not know that she skipped it — we know only that
                  // nothing was logged, and those are different facts. "Missed
                  // your NT scan" is a small accusation built on a gap in our
                  // own record, and it would be wrong for every mother who had
                  // the scan and never opened this screen. The neutral wording
                  // is also the true one.
                  if (where == _Where.passed) ...[
                    const SizedBox(height: 5),
                    Text(_en('Not marked as done').of(lang),
                        style: pvManrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink3)),
                  ],
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
            // ⚠️ ONLY TWO STATES CARRY A CHIP, ON PURPOSE.
            //
            // "Upcoming" is the default and the majority of the list — chipping
            // it would put a badge on almost every row and leave the two that
            // matter with nothing to stand out against. Absence is the third
            // state, and the legend above says so out loud rather than leaving
            // her to infer it.
            if (isNext || isDone)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isNext
                      ? p.action
                      : p.action.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                    (isNext ? _en('NEXT UP') : _en('DONE')).of(lang),
                    style: pvManrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: isNext ? p.onAction : p.action)),
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

/// The dot on the rail.
///
///   · done     — filled, with a tick
///   · next     — filled, with a slow halo pinging out of it
///   · upcoming — hollow, quiet outline
///   · passed   — hollow, dashed-looking (a lighter outline), quiet
///
/// ⚠️ THE ANIMATION IS A HALO, NOT A BLINK — and the review asked for exactly
/// that distinction ("not blink, but like some animation"). A blink is an alarm:
/// it appears and disappears, so the eye is pulled back every cycle and the row
/// reads as a warning. A halo expanding out of a dot that never leaves is an
/// *arrow* — it says "here", stays legible if you look away, and settles into
/// the page rather than fighting it. That is the whole difference between
/// pointing at the next scan and worrying her about it.
class _Station extends StatefulWidget {
  const _Station({required this.where, required this.p});

  final _Where where;
  final V2Palette p;

  @override
  State<_Station> createState() => _StationState();
}

class _StationState extends State<_Station>
    with SingleTickerProviderStateMixin {
  /// ⚠️ CREATED FOR EVERY ROW, DRIVEN ONLY FOR THE NEXT ONE.
  ///
  /// A controller cannot be conditionally created — `initState` runs before we
  /// know whether a later rebuild will make this row the next one — so it is
  /// always constructed and only ever *repeated* while the row is next. An idle
  /// `AnimationController` schedules no frames, so the eight rows that are not
  /// next cost nothing to run.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _Station old) {
    super.didUpdateWidget(old);
    if (old.where != widget.where) _sync();
  }

  /// ⚠️ REDUCED MOTION IS HONOURED, AND THE MEANING SURVIVES IT.
  ///
  /// With animations disabled the halo is drawn at rest rather than dropped —
  /// so the ring is still there, still marks the row, and the state is still
  /// readable. An accessibility setting must never cost her the information;
  /// it only costs the movement.
  void _sync() {
    final wants = widget.where == _Where.next &&
        !MediaQuery.disableAnimationsOf(context);
    if (wants && !_c.isAnimating) {
      _c.repeat();
    } else if (!wants && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final done = widget.where == _Where.done;
    final next = widget.where == _Where.next;
    final passed = widget.where == _Where.passed;

    final dot = Container(
      width: next ? 18 : 14,
      height: next ? 18 : 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done || next ? p.action : Colors.transparent,
        border: Border.all(
          color: done || next
              ? p.action
              : p.ink3.withValues(alpha: passed ? 0.28 : 0.45),
          width: 2,
        ),
      ),
      child: done ? Icon(Icons.check, size: 9, color: p.onAction) : null,
    );

    return SizedBox(
      width: 28,
      child: Column(
        children: [
          const SizedBox(height: 3),
          if (!next)
            dot
          else
            // The halo needs room to expand into, and the rail is only 28
            // wide — so the ping is drawn in a fixed 28×28 box with the dot
            // centred in it, which keeps every row's text starting at the
            // same x whether or not it is the next one.
            SizedBox(
              width: 28,
              height: 28,
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, child) {
                  final t = Curves.easeOut.transform(_c.value);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Two rings, half a cycle apart, so the rail reads as a
                      // steady pulse rather than one ring and a long gap.
                      _ring(p, t),
                      _ring(p, (t + 0.5) % 1.0),
                      child!,
                    ],
                  );
                },
                child: dot,
              ),
            ),
        ],
      ),
    );
  }

  /// One expanding, fading ring. [t] runs 0 → 1 across its life.
  Widget _ring(V2Palette p, double t) {
    final size = 18.0 + (10.0 * t);
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: p.action.withValues(alpha: 0.45 * (1 - t)),
            width: 2,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  The legend — what the three treatments mean, said rather than implied
// -----------------------------------------------------------------------------

/// ⚠️ WHY A LEGEND AND NOT JUST BETTER DOTS.
///
/// The review's ask was that the timeline be "intuitive — what we are trying to
/// tell". Visual state is only intuitive once you have been told the key: a
/// filled dot and a hollow dot are obviously *different*, but which one means
/// done is a guess until something says so. Three words each, once, at the top
/// removes the guess for the whole page — and it costs one line of height
/// against nine rows of ambiguity.
class _Legend extends StatelessWidget {
  const _Legend({required this.p, required this.lang});

  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Row(children: [
        _item(
            _Dot(filled: true, tick: true, p: p), _en('Done').of(lang)),
        const SizedBox(width: 16),
        _item(_Dot(filled: true, haloed: true, p: p), _en('Next').of(lang)),
        const SizedBox(width: 16),
        _item(_Dot(p: p), _en('Later').of(lang)),
      ]);

  Widget _item(Widget dot, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: 6),
          Text(label,
              style: pvManrope(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: p.ink3)),
        ],
      );
}

/// A static miniature of a station dot, for the legend only.
class _Dot extends StatelessWidget {
  const _Dot(
      {this.filled = false, this.tick = false, this.haloed = false, required this.p});

  final bool filled;
  final bool tick;
  final bool haloed;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final core = Container(
      width: 11,
      height: 11,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? p.action : Colors.transparent,
        border: Border.all(
            color: filled ? p.action : p.ink3.withValues(alpha: 0.45),
            width: 1.6),
      ),
      child: tick ? Icon(Icons.check, size: 7, color: p.onAction) : null,
    );
    if (!haloed) return SizedBox(width: 16, height: 16, child: Center(child: core));
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(alignment: Alignment.center, children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: p.action.withValues(alpha: 0.35), width: 1.4),
          ),
        ),
        core,
      ]),
    );
  }
}

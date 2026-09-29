// =============================================================================
//  "My cycle report" - her last cycle, walked through in plain words
// -----------------------------------------------------------------------------
//  The cycle report screen shows a month as a picture. This says the same
//  month as sentences, a few at a time, for anyone who would rather be told
//  than shown. It reads the SAME builders the report screen reads
//  (`ttcBuildCycleReport`, `ttcCyclePhaseSpans`, `ttcCycleLengthNote`), so the
//  two cannot tell her different things about one cycle.
//
//  ⚠️ THE NO-VERDICT RULE, CARRIED OVER FROM `ttc_cycle_report.dart`. Every
//  line is a date, a count or a position. Never a cause, never a projection,
//  never a chance. The one next step is either "Nothing here needs action" or
//  a specific, calm "worth showing a doctor if this keeps happening" with the
//  fact that earned it, using the same thresholds the rest of the stage uses
//  (shorter than 21 or longer than 35 days; bleeding for more than 7).
//
//  ⚠️ PHASES ARE REFUSED ON THE SAME TERMS AS THE REPORT. On a clinic-run cycle
//  or one the engine will not estimate, the chat says so and names no fertile
//  days. The report's own state decides; this file does not re-derive it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../ttc/cycle_store.dart';
import '../../../ttc/ttc_cycle_report.dart';
import '../../../ttc/ttc_period_due.dart';
import 'ttc_chat.dart';

/// What the chat says about one cycle, gathered before it speaks.
class TtcCycleReportFacts {
  const TtcCycleReportFacts({
    this.start,
    this.ranDays,
    this.bleedDays,
    this.state = TtcReportState.noPeriod,
    this.fertileFrom,
    this.fertileTo,
    this.lengthNote,
    this.loggedDays = 0,
    this.findings = const [],
  });

  /// The last COMPLETED cycle when there is one, else the one she is in.
  factory TtcCycleReportFacts.fromStores() {
    final cycle = CycleStore.instance;
    final starts = cycle.periodStarts;
    if (starts.isEmpty) return const TtcCycleReportFacts();
    final index = starts.length >= 2 ? 1 : 0;
    final report = ttcBuildCycleReport(index: index);
    final start = report.start;
    if (start == null) return const TtcCycleReportFacts();
    final spans = ttcCyclePhaseSpans(index: index);
    final fertile =
        spans.where((s) => s.phase == TtcPhase.fertileWindow).firstOrNull;
    return TtcCycleReportFacts(
      start: start,
      ranDays: cycle.cycleFrom(start)?.days,
      bleedDays: cycle.bleedDaysFor(start),
      state: report.state,
      fertileFrom: fertile?.firstDay,
      fertileTo: fertile?.lastDay,
      // Describes the most recent COMPLETED cycle, so only when that is the
      // one being walked through.
      lengthNote: index == 1 ? ttcCycleLengthNote() : null,
      loggedDays: report.loggedCount,
      findings: report.findings,
    );
  }

  final DateTime? start;

  /// How long it ran. Null while it is still going.
  final int? ranDays;

  /// What she recorded: a count, [kBleedStillOn], or null for not answered.
  final int? bleedDays;

  final TtcReportState state;
  final DateTime? fertileFrom;
  final DateTime? fertileTo;
  final TtcFinding? lengthNote;
  final int loggedDays;
  final List<TtcFinding> findings;
}

class TtcCycleReportChat extends TtcChatScript {
  TtcCycleReportChat({TtcCycleReportFacts? facts})
      : facts = facts ?? TtcCycleReportFacts.fromStores();

  final TtcCycleReportFacts facts;

  @override
  String get title => 'My cycle report';

  @override
  TtcChatStep start() {
    if (facts.start == null) {
      return const TtcChatStep(
        [
          'We need at least one logged period to look back at a cycle.',
          'Once you log one, this is where it comes together.',
        ],
        [
          TtcChatChoice('Log a period', open: ['ttc_cycle']),
          TtcChatChoice('Done', done: true),
        ],
      );
    }
    return TtcChatStep(
      [
        facts.ranDays == null
            ? "Here's your cycle so far, in plain words."
            : "Here's your last cycle, in plain words.",
      ],
      [TtcChatChoice('Show me', next: walk)],
    );
  }

  TtcChatStep walk() {
    final f = facts;
    final start = f.start!;
    final ran = f.ranDays;
    final bleed = f.bleedDays;
    final note = f.lengthNote;
    return TtcChatStep(
      [
        if (ran == null)
          "It started on ${ttcDayDate(start)} and it's still going."
        else
          'It started on ${ttcDayDate(start)} and ran ${ttcDays(ran)}.',
        if (bleed != null && bleed != kBleedStillOn && bleed > 0)
          'Your period lasted ${ttcDays(bleed)}.',
        if (note != null)
          '${note.headline}. ${note.detail}'
        else if (ran != null)
          "Once you've logged three cycles, we can compare each one with your "
              'usual.',
        ...switch (f.state) {
          TtcReportState.clinicHeld => const [
              "Your clinic was running this cycle, so we don't mark fertile "
                  'days on it. Everything you logged is still here.',
            ],
          TtcReportState.noEstimate || TtcReportState.noPeriod => const [
              "There weren't enough dates to mark your fertile days on this "
                  'one.',
            ],
          TtcReportState.thin || TtcReportState.ready => [
              if (f.fertileFrom != null && f.fertileTo != null)
                'Going by your dates, your fertile days were around '
                    '${ttcShortDay(f.fertileFrom!)} to '
                    '${ttcShortDay(f.fertileTo!)}.',
            ],
        },
        if (f.loggedDays == 0)
          "You didn't log how you felt this cycle, and that's fine."
        else
          'You logged how you felt on ${ttcDays(f.loggedDays)}.',
        for (final finding in f.findings.take(3))
          '${finding.headline}: ${finding.detail}',
      ],
      [
        // Kept for revert (2026-09-28, explicit labels): 'What should I do with this?'
        TtcChatChoice('What should I do with this report?', next: nextStep),
        const TtcChatChoice('See the full report', open: ['ttc_cycle_report']),
      ],
    );
  }

  /// The things in this cycle worth showing a doctor if they keep happening.
  /// Facts she logged, compared with fixed thresholds. Empty is the normal
  /// answer.
  List<String> get worthShowing {
    final out = <String>[];
    final ran = facts.ranDays;
    if (ran != null && ran < 21) out.add('a cycle shorter than 21 days');
    if (ran != null && ran > 35) out.add('a cycle longer than 35 days');
    final bleed = facts.bleedDays;
    if (bleed != null && bleed > 7) {
      out.add('a period that lasts more than 7 days');
    }
    return out;
  }

  TtcChatStep nextStep() {
    final flags = worthShowing;
    return TtcChatStep(
      [
        if (flags.isEmpty)
          'Nothing here needs action.'
        else
          'Worth showing a doctor if this keeps happening: '
              '${flags.join(', and ')}.',
        "This describes what you logged. It isn't a diagnosis.",
      ],
      const [
        TtcChatChoice('See the full report', open: ['ttc_cycle_report']),
        TtcChatChoice('Done', done: true),
      ],
    );
  }
}

/// The screen, for the router.
class TtcCycleReportChatScreen extends StatelessWidget {
  const TtcCycleReportChatScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      TtcChatScreen(script: TtcCycleReportChat());
}

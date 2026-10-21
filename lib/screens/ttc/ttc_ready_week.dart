// =============================================================================
//  ttc_ready_week.dart - "Your week", the help cards, and the plan as a PDF
// =============================================================================
//
// The approved prototype (2026-10-21) for the Ready-to-Try plan, in widgets.
// The habits come from her answers (`readyHabitsFor`); what she changes on
// top of them lives in `TtcReadyHabitsStore`.
//
// Mobbin (MOBBIN-DISCOVERY): Ahead "make it stick" (a time per habit),
// Mindvalley "Set your time", Lifesum per-habit reminders. Declined: streaks
// and badges, which put pressure on a stage that already carries enough.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../ttc/ttc_prepare_data.dart' show ttcOfferingById;
import '../../ttc/ttc_ready_habits_store.dart';
import '../../ttc/ttc_ready_plan.dart';
import '../../widgets/pv_feedback.dart' show PvPress, pvCommitFeedback;
import '../products/pv_store_chrome.dart' show pvSnack;
import 'ttc_common.dart';
import 'ttc_prepare_screen.dart' show TtcOfferingScreen;
import 'ttc_surface_router.dart';

String ttcReadyTime(int minutes) {
  final h = minutes ~/ 60, m = minutes % 60;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'am' : 'pm'}';
}

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// ---------------------------------------------------------------------------
//  Your week
// ---------------------------------------------------------------------------

class TtcReadyWeek extends StatefulWidget {
  const TtcReadyWeek({super.key, required this.habits});
  final List<ReadyHabit> habits;

  @override
  State<TtcReadyWeek> createState() => _TtcReadyWeekState();
}

class _TtcReadyWeekState extends State<TtcReadyWeek> {
  final _store = TtcReadyHabitsStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  Future<void> _pickTime(ReadyHabit h) async {
    final m = _store.minutesFor(h);
    final t = await showTimePicker(
      context: context,
      helpText: 'When suits you for "${h.title}"?',
      initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
    );
    if (t == null || !mounted) return;
    final before = m;
    await _store.setMinutes(h, t.hour * 60 + t.minute);
    if (!mounted) return;
    pvSnack(context, '${h.title}: ${ttcReadyTime(t.hour * 60 + t.minute)}.',
        icon: Icons.check_rounded,
        lift: 24,
        action: 'Undo',
        onAction: () => _store.setMinutes(h, before));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _store,
        builder: (context, _) => Column(
          key: const ValueKey('ttc_ready_week'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
                'Small things, at times that suit you. Busy day? Each one has a '
                'smaller version that still counts.',
                style: ttcBody(13, h: 1.5)),
            // Said, not done silently (2026-10-21): the day her month came,
            // the store stopped the getting-ready reminders once.
            if (_store.retired) ...[
              const SizedBox(height: 8),
              Text(
                  'Your month is here, so the getting-ready reminders have '
                  'stopped. Folic acid keeps going. Turn any back on below.',
                  key: const ValueKey('ttc_ready_week_retired'),
                  style: ttcBody(13, h: 1.5)),
            ],
            const SizedBox(height: 12),
            for (final h in widget.habits) ...[
              _HabitRow(
                habit: h,
                store: _store,
                onTime: () => _pickTime(h),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            _SwitchRow(
              key: const ValueKey('ttc_ready_week_note'),
              title: 'Your week ahead',
              sub: 'A note on Sunday evenings, 7 pm',
              on: _store.weekly,
              onChanged: (on) async {
                await _store.setWeekly(on);
                if (!context.mounted) return;
                pvSnack(
                    context,
                    on
                        ? 'Weekly note on. The first comes on Sunday at 7 pm.'
                        : 'Weekly note off.',
                    lift: 24,
                    action: 'Undo',
                    onAction: () => _store.setWeekly(!on));
              },
            ),
          ],
        ),
      );
}

class _HabitRow extends StatelessWidget {
  const _HabitRow(
      {required this.habit, required this.store, required this.onTime});
  final ReadyHabit habit;
  final TtcReadyHabitsStore store;
  final VoidCallback onTime;

  @override
  Widget build(BuildContext context) {
    final small = store.smaller(habit);
    final skipped = store.skippedToday(habit);
    final time = ttcReadyTime(store.minutesFor(habit));
    return Opacity(
      opacity: skipped ? 0.55 : 1,
      child: Container(
        key: ValueKey('ttc_ready_habit_${habit.id}'),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ttcBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: GestureDetector(
                onTap: habit.surfaceId == null
                    ? null
                    : () => openTtcSurface(context, habit.surfaceId!),
                child: Text(small ? habit.minimum : habit.title,
                    style: ttcBody(14.5,
                        color: ttcTitleInk, w: FontWeight.w800, h: 1.3)),
              ),
            ),
            const SizedBox(width: 8),
            PvPress(
              child: GestureDetector(
                key: ValueKey('ttc_ready_habit_time_${habit.id}'),
                onTap: onTime,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: ttcBorder)),
                  // Weight 600, not 800 (the user, 2026-10-21: "time needn't
                  // be this bold").
                  child: Text(
                      habit.weekday == null
                          ? time
                          : '${_days[habit.weekday! - 1]} · $time',
                      style: ttcBody(12,
                          color: ttcTitleInk, w: FontWeight.w600)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
              skipped
                  ? 'Skipped today. That is fine.'
                  : (small ? 'The smaller version, for now.' : habit.minimum),
              style: ttcBody(12.5, h: 1.4)),
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 2,
              children: [
            TextButton(
              key: ValueKey('ttc_ready_habit_small_${habit.id}'),
              onPressed: () {
                pvCommitFeedback();
                store.toggleSmaller(habit);
              },
              child: Text(small ? 'Back to the full one' : 'Make it smaller',
                  style: ttcBody(12.5,
                      color: ttcTitleInk, w: FontWeight.w700)),
            ),
            TextButton(
              key: ValueKey('ttc_ready_habit_skip_${habit.id}'),
              onPressed: () {
                pvCommitFeedback();
                store.toggleSkip(habit);
              },
              child: Text(skipped ? 'Undo skip' : 'Skip today',
                  style: ttcBody(12.5,
                      color: ttcTitleInk, w: FontWeight.w700)),
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Remind me', style: ttcBody(12)),
            Switch.adaptive(
              key: ValueKey('ttc_ready_habit_remind_${habit.id}'),
              value: store.reminds(habit),
              onChanged: (on) async {
                await store.setRemind(habit, on);
                if (!context.mounted) return;
                pvSnack(
                    context,
                    on
                        ? 'Reminder on: ${habit.title}, $time.'
                        : 'Reminder off: ${habit.title}.',
                    lift: 24,
                    action: 'Undo',
                    onAction: () => store.setRemind(habit, !on));
              },
            ),
            ]),
          ]),
        ]),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(
      {super.key,
      required this.title,
      required this.sub,
      required this.on,
      required this.onChanged});
  final String title;
  final String sub;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w800)),
            Text(sub, style: ttcBody(12.5)),
          ]),
        ),
        Switch.adaptive(value: on, onChanged: onChanged),
      ]);
}

// ---------------------------------------------------------------------------
//  Help with this
// ---------------------------------------------------------------------------

/// At most two calm cards into our own offerings, chosen by her answers.
/// An id that is not in the catalogue draws nothing (and the test fails).
class TtcReadyHelpCards extends StatelessWidget {
  const TtcReadyHelpCards({super.key, required this.pitches});
  final List<ReadyPitch> pitches;

  @override
  Widget build(BuildContext context) {
    final shown = [
      for (final p in pitches)
        if (ttcOfferingById(p.offeringId) case final o?) (p, o),
    ];
    if (shown.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const ValueKey('ttc_ready_help'),
      children: [
        for (final (p, o) in shown) ...[
          PvPress(
            child: GestureDetector(
              key: ValueKey('ttc_ready_help_${o.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: RouteSettings(name: 'ttc/offering/${o.id}'),
                builder: (_) => TtcOfferingScreen(offering: o),
              )),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: BoxDecoration(
                    color: ttcPanel, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.title(false),
                              style: ttcBody(14,
                                  color: ttcTitleInk, w: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('${p.why} ${o.priceLabelIn(false)}',
                              style: ttcBody(12.5, h: 1.4)),
                        ]),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: ttcTitleInk),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  The plan as a PDF
// ---------------------------------------------------------------------------

/// Builds the plan as one A4 page and opens the share sheet (WhatsApp, save,
/// print). Fonts load over the network and fall back to Helvetica, the same
/// guard the care poster uses; the plan is English, so Latin faces suffice.
Future<void> shareTtcReadyPlanPdf(BuildContext context, ReadyPlan plan) async {
  pvCommitFeedback();
  try {
    final bytes = await buildTtcReadyPlanPdf(plan);
    await Printing.sharePdf(bytes: bytes, filename: 'ParentVeda-ready-to-try-plan.pdf');
  } catch (_) {
    if (context.mounted) {
      pvSnack(context, "Couldn't make the PDF just now. Try again in a moment.",
          lift: 24);
    }
  }
}

Future<Uint8List> buildTtcReadyPlanPdf(ReadyPlan plan) async {
  Future<pw.Font> font(Future<pw.Font> Function() load) async {
    try {
      return await load();
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  final serif = await font(PdfGoogleFonts.frauncesSemiBold);
  final sans = await font(PdfGoogleFonts.manropeRegular);
  final bold = await font(PdfGoogleFonts.manropeExtraBold);
  final store = TtcReadyHabitsStore.instance;
  const ink = PdfColor.fromInt(0xFF2F2C30);
  const soft = PdfColor.fromInt(0xFF69636C);

  pw.Widget h(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pw.Text(t, style: pw.TextStyle(font: bold, fontSize: 13, color: ink)));
  pw.Widget line(String t, {String? sub}) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('•  $t', style: pw.TextStyle(font: sans, fontSize: 11, color: ink)),
          if (sub != null)
            pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12),
                child: pw.Text(sub,
                    style: pw.TextStyle(font: sans, fontSize: 9.5, color: soft))),
        ]),
      );

  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    build: (_) => [
      pw.Text('Your Ready-to-Try plan',
          style: pw.TextStyle(font: serif, fontSize: 24, color: ink)),
      pw.Text(
          'Trying from ${readyMonthLabel(plan.target)}. From your answers in ParentVeda. '
          "It isn't medical clearance, and your doctor has the final word.",
          style: pw.TextStyle(font: sans, fontSize: 10, color: soft)),
      if (plan.habits.isNotEmpty) h('Your week'),
      for (final x in plan.habits)
        line(
            '${store.smaller(x) ? x.minimum : x.title} · '
            '${x.weekday == null ? '' : '${_days[x.weekday! - 1]} '}${ttcReadyTime(store.minutesFor(x))}',
            sub: store.smaller(x) ? null : x.minimum),
      h(plan.arrived ? 'While you try' : 'This month'),
      for (final s in plan.thisMonth) line(s.title, sub: s.why),
      h('Month by month'),
      for (final m in plan.months)
        line(
            '${readyMonthLabel(m.month)}${m.isTarget ? ' · you start trying' : ''}',
            sub: m.steps.isEmpty ? null : m.steps.map((s) => s.title).join(' · ')),
      h('Tests to ask your doctor about'),
      for (final t in plan.tests) line(t.name, sub: t.why),
      h('His part'),
      for (final l in plan.hisLines) line(l),
      pw.SizedBox(height: 16),
      pw.Text('General information, not medical advice.',
          style: pw.TextStyle(font: sans, fontSize: 9, color: soft)),
    ],
  ));
  return doc.save();
}

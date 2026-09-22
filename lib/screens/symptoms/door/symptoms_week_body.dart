// =============================================================================
//  Symptoms — the Your week tab's tool: seven days at a glance
// -----------------------------------------------------------------------------
//  Clue's period rows (Mobbin §18): a row per symptom, a column per day,
//  a dot whose size is the strength. Under it the pattern line — the one
//  sentence her doctor wants ("Nausea on 5 of the last 7 days") — and the
//  way to send the week.
//
//  ⚠️ NOTHING IS COMPUTED ABOUT HER. The grid is what she logged; the line
//  counts days. No trend arrow, no "getting worse", no score — the
//  clinical rules (CLAUDE.md) and the reason the door says "your
//  observation" and not "your data".
//
//  ⚠️ EMPTY IS AN INVITATION, NOT A BLANK (a feature is never hidden): a
//  week with nothing logged shows the seven day columns, the sentence that
//  says what will appear, and the tap to Today.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/symptoms/symptom_library.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../services/symptom_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import 'symptoms_today_body.dart' show openSymptomRead;
import 'symptoms_widgets.dart';

const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class SymptomsWeekBody extends StatelessWidget {
  const SymptomsWeekBody({super.key, required this.pregnancy, this.onSend, this.showHeading = true});
  final PregnancyController pregnancy;

  /// Off when a scaffold already carries the title (the pushed page).
  final bool showHeading;

  /// The "Send my week" tap; null draws the row without it (the send screen
  /// itself hosts this body).
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([V2PaletteStore.instance, SymptomStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final store = SymptomStore.instance;
          final today = DateTime.now();
          final days = SymptomStore.weekEnding(today);
          final rows = store.weekCounts(today);
          final daysLogged = store.daysLoggedInWeek(today);

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (showHeading) ...[
              pvDoorPad(symptomsHeading(p, 'Your week',
                  sub: rows.isEmpty
                      ? 'Nothing logged in the last seven days. Tap what you feel on Today and it shows up here, day by day.'
                      : '$daysLogged of 7 days logged. A dot is a day; a bigger dot, a stronger day.')),
              const SizedBox(height: 16),
            ] else ...[
              pvDoorPad(Text(
                  rows.isEmpty
                      ? 'Nothing logged in the last seven days yet.'
                      : '$daysLogged of 7 days logged. A dot is a day; a bigger dot, a stronger day.',
                  style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2))),
              const SizedBox(height: 14),
            ],

            // ---- the grid --------------------------------------------------------
            pvDoorPad(_WeekGrid(p: p, days: days, rows: rows, today: today, store: store,
                onOpen: (id) {
                  final s = symptomById(id);
                  if (s != null) openSymptomRead(context, s, pregnancy);
                })),

            // ---- the pattern line ------------------------------------------------
            if (rows.isNotEmpty) ...[
              const SizedBox(height: 18),
              pvDoorPad(Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('THE PATTERN',
                      style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
                  const SizedBox(height: 4),
                  Text(symptomPatternLine(rows), style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1)),
                ]),
              )),
            ],
            if (onSend != null) ...[
              const SizedBox(height: 16),
              pvDoorPad(SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: rows.isEmpty
                      ? null
                      : () {
                          pvCommitFeedback();
                          onSend!();
                        },
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Send my week'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              )),
            ],
            const SizedBox(height: 8),
          ]);
        },
      );
}

/// "Nausea on 5 of the last 7 days; heartburn on 2." Counts, nothing more.
String symptomPatternLine(List<({String symptomId, int days})> rows) {
  String name(String id) => symptomById(id)?.name.en ?? id;
  if (rows.isEmpty) return '';
  final first = rows.first;
  final parts = <String>['${name(first.symptomId)} on ${first.days} of the last 7 days'];
  for (final r in rows.skip(1).take(2)) {
    parts.add('${name(r.symptomId).toLowerCase()} on ${r.days}');
  }
  final more = rows.length - 3;
  return '${parts.join('; ')}${more > 0 ? '; and $more more' : ''}.';
}

/// The note she sends — plain text, the way a message reads.
String symptomWeekNote(PregnancyController c) {
  final store = SymptomStore.instance;
  final today = DateTime.now();
  final days = SymptomStore.weekEnding(today);
  final rows = store.weekCounts(today);
  String d(DateTime x) => '${x.day} ${_months[x.month - 1]}';
  final b = StringBuffer();
  b.writeln('Symptoms, ${d(days.first)} to ${d(days.last)} (week ${c.currentWeek} of pregnancy)');
  b.writeln();
  if (rows.isEmpty) {
    b.writeln('Nothing logged this week.');
  }
  for (final r in rows) {
    final name = symptomById(r.symptomId)?.name.en ?? r.symptomId;
    final sev = <String, int>{};
    for (final day in days) {
      final s = store.severityOn(day, r.symptomId);
      if (s != null) sev[s] = (sev[s] ?? 0) + 1;
    }
    final detail = [
      for (final k in ['strong', 'moderate', 'mild'])
        if (sev[k] != null) '${severityLabel(k).toLowerCase()} ×${sev[k]}',
    ].join(', ');
    b.writeln('• $name — ${r.days} day${r.days == 1 ? '' : 's'}${detail.isEmpty ? '' : ' ($detail)'}');
  }
  b.writeln();
  b.writeln('Logged day by day in ParentVeda. My observation, not a diagnosis.');
  return b.toString();
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

Future<void> shareSymptomWeek(BuildContext context, PregnancyController c) async {
  final note = symptomWeekNote(c);
  await Share.share(note, subject: 'My symptoms this week');
}

Future<void> copySymptomWeek(BuildContext context, PregnancyController c) async {
  await Clipboard.setData(ClipboardData(text: symptomWeekNote(c)));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied. Paste it into a message to your doctor.')));
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({
    required this.p,
    required this.days,
    required this.rows,
    required this.today,
    required this.store,
    required this.onOpen,
  });
  final V2Palette p;
  final List<DateTime> days;
  final List<({String symptomId, int days})> rows;
  final DateTime today;
  final SymptomStore store;
  final void Function(String id) onOpen;

  @override
  Widget build(BuildContext context) {
    const nameW = 108.0;
    final shown = rows.take(8).toList();
    return Column(children: [
      // The day letters, today bold.
      Row(children: [
        const SizedBox(width: nameW),
        for (final d in days)
          Expanded(
            child: Center(
              child: Text(
                  DateTime(d.year, d.month, d.day) == DateTime(today.year, today.month, today.day)
                      ? 'TODAY'
                      : _dayLetters[d.weekday - 1],
                  style: pvManrope(
                      fontSize: DateTime(d.year, d.month, d.day) == DateTime(today.year, today.month, today.day) ? 7.5 : 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: p.ink3)),
            ),
          ),
      ]),
      const SizedBox(height: 8),
      if (shown.isEmpty)
        // Seven empty columns, so the shape is there before the first log.
        Row(children: [
          const SizedBox(width: nameW),
          for (final _ in days)
            Expanded(
              child: Center(
                child: Container(
                    width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.line))),
              ),
            ),
        ])
      else
        for (var i = 0; i < shown.length; i++)
          Builder(builder: (context) {
            final r = shown[i];
            final s = symptomById(r.symptomId);
            final area = s == null ? SymptomArea.body : symptomArea(s);
            final deep = HSLColor.fromColor(symptomAreaTint(p, area)).withSaturation(0.45).withLightness(0.42).toColor();
            return InkWell(
              onTap: () {
                pvCommitFeedback();
                onOpen(r.symptomId);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(border: i == shown.length - 1 ? null : Border(bottom: BorderSide(color: p.line))),
                child: Row(children: [
                  SizedBox(
                    width: nameW,
                    child: Row(children: [
                      SizedBox(width: 18, height: 18, child: s == null ? symptomAreaMark(p, area) : symptomGlyph(p, s, size: 18)),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(s?.name.en ?? r.symptomId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink1)),
                      ),
                    ]),
                  ),
                  for (final d in days)
                    Expanded(
                      child: Center(
                        child: Builder(builder: (context) {
                          final sev = store.severityOn(d, r.symptomId);
                          final size = switch (sev) { 'strong' => 16.0, 'moderate' => 12.0, 'mild' => 8.0, _ => 0.0 };
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: size == 0 ? 6 : size,
                            height: size == 0 ? 6 : size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: size == 0 ? Colors.transparent : deep,
                              border: size == 0 ? Border.all(color: p.line) : null,
                            ),
                          );
                        }),
                      ),
                    ),
                ]),
              ),
            );
          }),
    ]);
  }
}

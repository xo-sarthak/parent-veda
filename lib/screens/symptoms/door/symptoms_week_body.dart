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
//
//  ⚠️ NO TINTED CARD ANYWHERE ON THIS TAB (2026-09-22). "The pattern" used to
//  sit in a lavender rounded rectangle, and the user's read on the phone was
//  *"the whole purple background thing with a rectangle soft edges is
//  happening"* — the same note he has made about every tinted panel dropped
//  into a white page. A tinted box says "this is a different KIND of thing".
//  The pattern line is not a different kind of thing: it is the grid, said in
//  words. So it sits under a hairline rule, in ink, like a caption.
//
//  The grid's own geometry changed with it: the day columns carry the DATE
//  under the letter (a week she can point at, which is the whole promise of
//  taking it to a doctor), today is an ink disc — the day strip's own
//  language, already on the Today tab — and a row's dots sit on a hairline
//  track so a sparse week still reads as seven days rather than as three
//  dots adrift on white.
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
  const SymptomsWeekBody({
    super.key,
    required this.pregnancy,
    this.onSend,
    this.showHeading = true,
  });
  final PregnancyController pregnancy;

  /// Off when a scaffold already carries the title (the pushed page).
  final bool showHeading;

  /// The "Send my week" tap; null draws the row without it (the send screen
  /// itself hosts this body).
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      V2PaletteStore.instance,
      SymptomStore.instance,
    ]),
    builder: (context, _) {
      final p = V2PaletteStore.instance.current;
      final store = SymptomStore.instance;
      final today = DateTime.now();
      final days = SymptomStore.weekEnding(today);
      final rows = store.weekCounts(today);
      final daysLogged = store.daysLoggedInWeek(today);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeading) ...[
            pvDoorPad(
              symptomsHeading(
                p,
                'Your week',
                sub: rows.isEmpty
                    ? 'Nothing logged in the last seven days. Tap what you feel on Today, and it shows up here day by day.'
                    : '$daysLogged of 7 days logged. Each dot is a day, and a bigger dot means a stronger day.',
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            pvDoorPad(
              Text(
                rows.isEmpty
                    ? 'Nothing logged in the last seven days yet.'
                    : '$daysLogged of 7 days logged. Each dot is a day, and a bigger dot means a stronger day.',
                style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ---- the grid --------------------------------------------------------
          pvDoorPad(
            _WeekGrid(
              p: p,
              days: days,
              rows: rows,
              today: today,
              store: store,
              onOpen: (id) {
                final s = symptomById(id);
                if (s != null) openSymptomRead(context, s, pregnancy);
              },
            ),
          ),

          // ---- the pattern line ------------------------------------------------
          // A caption under a rule, not a card. See the note at the head.
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 20),
            pvDoorPad(Container(height: 1, color: p.line)),
            const SizedBox(height: 12),
            pvDoorPad(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE PATTERN',
                    style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: p.ink3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    symptomPatternLine(rows),
                    style: pvManrope(
                      fontSize: 14.5,
                      height: 1.5,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Just a count of the days you logged it. It doesn\'t read anything into them.',
                    style: pvManrope(
                      fontSize: 11.5,
                      height: 1.45,
                      color: p.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Kept for revert — the pattern in a tinted card:
          // Container(padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          //   decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(14)), ...)
          if (onSend != null) ...[
            const SizedBox(height: 16),
            pvDoorPad(
              SizedBox(
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
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      );
    },
  );
}

/// "Nausea on 5 of the last 7 days; heartburn on 2." Counts, nothing more.
String symptomPatternLine(List<({String symptomId, int days})> rows) {
  String name(String id) => symptomById(id)?.name.en ?? id;
  if (rows.isEmpty) return '';
  final first = rows.first;
  final parts = <String>[
    '${name(first.symptomId)} on ${first.days} of the last 7 days',
  ];
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
  b.writeln(
    'Symptoms, ${d(days.first)} to ${d(days.last)} (week ${c.currentWeek} of pregnancy)',
  );
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
    b.writeln(
      '• $name: ${r.days} day${r.days == 1 ? '' : 's'}${detail.isEmpty ? '' : ' ($detail)'}',
    );
  }
  b.writeln();
  b.writeln(
    'Logged day by day in ParentVeda. My observation, not a diagnosis.',
  );
  return b.toString();
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

Future<void> shareSymptomWeek(
  BuildContext context,
  PregnancyController c,
) async {
  final note = symptomWeekNote(c);
  await Share.share(note, subject: 'My symptoms this week');
}

Future<void> copySymptomWeek(
  BuildContext context,
  PregnancyController c,
) async {
  await Clipboard.setData(ClipboardData(text: symptomWeekNote(c)));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Copied. Paste it into a message to your doctor.'),
    ),
  );
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

  bool _isToday(DateTime d) =>
      DateTime(d.year, d.month, d.day) ==
      DateTime(today.year, today.month, today.day);

  @override
  Widget build(BuildContext context) {
    const nameW = 104.0;
    final shown = rows.take(8).toList();
    return Column(
      children: [
        // ---- the days: letter over date, today as an ink disc ------------------
        Row(
          children: [
            const SizedBox(width: nameW),
            for (final d in days)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _dayLetters[d.weekday - 1],
                      style: pvManrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: _isToday(d) ? p.ink1 : p.ink3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isToday(d) ? p.ink1 : Colors.transparent,
                      ),
                      child: Text(
                        '${d.day}',
                        style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _isToday(d) ? p.ground : p.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (shown.isEmpty)
          // Seven empty places on a track, so the shape is there before the
          // first log — the invitation, not a blank.
          _TrackRow(p: p, nameW: nameW, days: days, child: null)
        else
          for (var i = 0; i < shown.length; i++)
            Builder(
              builder: (context) {
                final r = shown[i];
                final s = symptomById(r.symptomId);
                final area = s == null ? SymptomArea.body : symptomArea(s);
                final deep = symptomAreaInk(p, area);
                return InkWell(
                  onTap: () {
                    pvCommitFeedback();
                    onOpen(r.symptomId);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        SizedBox(
                          width: nameW,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: s == null
                                    ? symptomAreaMark(p, area)
                                    : symptomLineMark(s, size: 20, ink: deep),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s?.name.en ?? r.symptomId,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: pvManrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    color: p.ink1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final d in days)
                          Expanded(
                            child: Center(
                              child: Builder(
                                builder: (context) {
                                  final sev = store.severityOn(d, r.symptomId);
                                  final size = switch (sev) {
                                    'strong' => 17.0,
                                    'moderate' => 13.0,
                                    'mild' => 9.0,
                                    _ => 0.0,
                                  };
                                  return SizedBox(
                                    height: 22,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // ⚠️ A DASH PER DAY, NOT A RULE ACROSS THE WEEK.
                                        // Full-width segments abut into one continuous
                                        // line, and the row then reads as a timeline with
                                        // dots adrift on it instead of as seven days, six
                                        // of which are empty.
                                        Container(
                                          width: 16,
                                          height: 3,
                                          color: p.line,
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          width: size,
                                          height: size,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: deep,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        const SizedBox(height: 4),
        // The key, so three sizes of dot mean something without being tapped.
        // ⚠️ A WRAP, NOT A ROW: three dots and three words overflow a 360dp
        // screen once the labels are measured in a wide font, and a key is
        // exactly the kind of thing that may take two lines.
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final (size, label) in [
                (9.0, 'mild'),
                (13.0, 'moderate'),
                (17.0, 'strong'),
              ])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.ink3.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: pvManrope(fontSize: 10.5, color: p.ink3),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The seven empty places, before anything is logged.
class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.p,
    required this.nameW,
    required this.days,
    this.child,
  });
  final V2Palette p;
  final double nameW;
  final List<DateTime> days;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(width: nameW, child: child),
      for (final _ in days)
        Expanded(
          child: Center(child: Container(width: 16, height: 3, color: p.line)),
        ),
    ],
  );
}

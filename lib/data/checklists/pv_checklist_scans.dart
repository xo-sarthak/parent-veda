// =============================================================================
//  What to ask at your next scan
// -----------------------------------------------------------------------------
//  The Scans door's "before your appointment" checklist. Moved here VERBATIM
//  from `scan_questions_data.dart` when the checklist system was generalised at
//  its second caller — same ids and same wording, so nothing anybody had
//  already ticked was stranded.
//
//  ⚠️ THE APP ALREADY HAS QUESTION LISTS AND THEY ARE A DIFFERENT THING.
//  `ReportFinding.questions` gives three questions per finding — "has the
//  placenta moved since my last scan?" — and those are excellent AFTER a report
//  names something. They are reused where they belong, on the finding pages.
//  This list is for BEFORE, when nothing has been found yet and the question is
//  what to ask about an appointment she has not had.
//
//  ⚠️ ORDERED BY THE VISIT, NOT BY IMPORTANCE. She reads this in a corridor
//  with minutes to spare, so a list that runs before / during / after / next
//  can be skimmed against where she is. Ranking instead would put the question
//  she needs at the desk somewhere in the middle.
// =============================================================================

import '../../services/pregnancy_controller.dart';
import '../../services/scans_store.dart';
import '../tests_scans_reports_data.dart';
import '../../screens/brackets/scan_timeline_screen.dart' show kScanRun;
import 'pv_checklist.dart';

/// The scan she is heading for, as a plain name, or null.
///
/// ⚠️ HER BOOKED APPOINTMENT FIRST, THE SCHEDULE SECOND. The timeline's own
/// "NEXT UP" answers a different question — which row is due next in clinical
/// order — and a woman opening a checklist called "your next scan" means the
/// one she has a DATE for. Two questions that usually have the same answer;
/// merging them would make one screen quietly start answering the other's.
String? _nextScanName(PregnancyController _) {
  final store = ScansStore.instance;

  final booked = <(DateTime, TestScanInfo)>[];
  for (final a in store.appointments) {
    final d = DateTime.tryParse(a.dateIso);
    if (d == null) continue;
    if (d.difference(DateTime.now()).inDays < -1) continue;
    final m = _match(a.title);
    if (m != null) booked.add((d, m));
  }
  if (booked.isNotEmpty) {
    booked.sort((x, y) => x.$1.compareTo(y.$1));
    // ⚠️ `.en`, NOT `.now`. This string is composed into a title and into a
    // shared message; `.now` is display and is wrong wherever a value leaves
    // the widget that drew it. CLAUDE.md names this trap directly.
    return booked.first.$2.name.en;
  }

  for (final (id, _, _) in kScanRun) {
    if (store.isCompleted(id)) continue;
    for (final s in kTestsScans) {
      if (s.id == id) return s.name.en;
    }
  }
  return null;
}

TestScanInfo? _match(String title) {
  final t = title.toLowerCase();
  for (final s in kTestsScans) {
    if (t.contains(s.name.en.toLowerCase())) return s;
    for (final a in s.aliases) {
      if (a.en.isNotEmpty && t.contains(a.en.toLowerCase())) return s;
    }
  }
  return null;
}

final PvChecklist kScanQuestionsChecklist = PvChecklist(
  id: 'scan_questions',
  eyebrow: 'Before your appointment',
  title: 'What to ask at your next scan',
  intro: 'Tick what matters to you, and take the list in with you. Nothing '
      'here is a test — they are questions your doctor is used to answering.',
  shareHeader: 'What to ask at my next scan',
  subject: _nextScanName,
  subjectTitle: (s) => 'What to ask at your $s',
  subjectIntro: (s) => 'Tick what matters to you and take the list in with '
      'you. These are questions your doctor is used to answering about the $s.',
  groups: [
  PvChecklistGroup('Before the day', [
    PvChecklistItem('prep_fast',
        'Do I need to fast, or drink water before I come?'),
    PvChecklistItem('prep_how_long', 'How long will it take?'),
    PvChecklistItem('prep_bring',
        'What should I bring — old reports, my card, anything else?'),
    PvChecklistItem('prep_partner', 'Can someone come in with me?'),
    PvChecklistItem('prep_cost',
        'What will it cost, and is the report included in that?'),
  ]),

  PvChecklistGroup('About this scan', [
    PvChecklistItem('scan_what_for', 'What are you looking for in this one?'),
    PvChecklistItem('scan_why_now', 'Why is it done at this week and not another?'),
    PvChecklistItem('scan_needed',
        'Is this one you are asking for, or one that is available?'),
    PvChecklistItem('scan_repeat',
        'How likely is it that I will need to come back for a repeat?'),
  ]),

  PvChecklistGroup('When I get the report', [
    PvChecklistItem('rep_when', 'When will the report be ready, and who gives it '
        'to me?'),
    PvChecklistItem('rep_explain', 'Who will explain it — you, or someone here?'),
    PvChecklistItem('rep_normal',
        'What would count as an ordinary result for this scan?'),
    PvChecklistItem('rep_copy',
        'Can I have a copy of the report and the films to keep?'),
  ]),

  PvChecklistGroup('What happens next', [
    PvChecklistItem('next_change',
        'Would anything in this result change my delivery plan?'),
    PvChecklistItem('next_when', 'When do I see you again, and what is next after '
        'this?'),
    // ⚠️ THE ONE QUESTION EVERY DOCTOR HAS AN ANSWER TO AND FEW SAY OUT LOUD.
    // Every clinician carries a threshold for "call me before your next
    // appointment". Asking for it is the single highest-value line on this
    // list, which is why it is last — the last thing read is the thing
    // remembered walking out.
    PvChecklistItem('next_call',
        'What would make you want me to call before the next visit?'),
  ]),
  ],
);

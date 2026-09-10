// =============================================================================
//  What to ask at your next scan — the checklist
// -----------------------------------------------------------------------------
//  Sub-tab 5's one new card. The brief: "[Checklist] NEW, shareable."
//
//  ⚠️ IT NAMES HER NEXT SCAN, AND THAT IS THE WHOLE DIFFERENCE BETWEEN THIS AND
//  A LIST OF QUESTIONS. The same twenty lines under a heading reading "What to
//  ask at your next scan" is a leaflet; under "Your anomaly scan, weeks 18–22"
//  it is hers. The next scan is worked out from the timeline she already keeps
//  — nothing is asked for, which is CLAUDE.md's derive-never-ask rule in the
//  place it is cheapest to honour.
//
//  When there is no next scan — everything ticked off, or a fresh install with
//  no due date — the heading falls back and the list still works. An empty
//  state here is not a special case; it is the same screen with one line less.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT NEVER SCORES, RANKS OR CONGRATULATES
//  ---------------------------------------------------------------------------
//
//  No progress bar, no "4 of 18", no streak. A counter on a list of things you
//  are nervous enough to write down is a debt statement — the same reason the
//  door playbook forbids "3 of 8" on a health questionnaire and the reason the
//  brief's DO NOT list ends with "do not add a streak or gamification".
//
//  The count that IS shown is on the share button, and it is there because it
//  is the one place a number is useful: it says how long the message you are
//  about to send will be.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SHARE IS A TEXT MESSAGE, NOT A DOCUMENT
//  ---------------------------------------------------------------------------
//
//  `Share.share` with plain text, through the OS sheet — so it lands in
//  WhatsApp, which is where it will actually go. A PDF would look more finished
//  and would be worse: she wants to paste this into a chat with her husband or
//  her mother, or read it off her own screen in a corridor, and a downloaded
//  file does neither.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/scan_questions_data.dart';
import '../../data/tests_scans_reports_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scan_questions_store.dart';
import '../../services/scans_store.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_chrome.dart';
import '../v2/v2_palette.dart';
import 'scan_timeline_screen.dart' show kScanRun;

/// The scans bracket's hue.
const double _hue = 206;

class ScanQuestionsScreen extends StatefulWidget {
  const ScanQuestionsScreen({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  State<ScanQuestionsScreen> createState() => _ScanQuestionsScreenState();
}

class _ScanQuestionsScreenState extends State<ScanQuestionsScreen> {
  @override
  void initState() {
    super.initState();
    ScanQuestionsStore.instance.init();
  }

  /// The scan she is heading for, by name, or null.
  ///
  /// ⚠️ THE SAME RULE THE TIMELINE USES, AND IT IS DELIBERATELY NOT SHARED AS
  /// CODE. The timeline's `_nextId` decides which row is marked NEXT and reads
  /// the scan run in clinical order; this reads her booked appointments first,
  /// because a woman opening a checklist called "your next scan" means the one
  /// she has a date for, not the one the schedule says is due.
  ///
  /// Two different questions that usually have the same answer. Merging them
  /// would mean one of the two screens quietly starts answering the other's.
  (String, String)? _nextScan() {
    final store = ScansStore.instance;

    // 1. Something she has actually booked, soonest first.
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
      final s = booked.first.$2;
      return (s.name.en, _weeksFor(s.id));
    }

    // 2. Otherwise the first scan in the run she has not marked done.
    for (final (id, from, to) in kScanRun) {
      if (store.isCompleted(id)) continue;
      for (final s in kTestsScans) {
        if (s.id == id) return (s.name.en, 'weeks $from–$to');
      }
    }
    return null;
  }

  String _weeksFor(String id) {
    for (final (rid, from, to) in kScanRun) {
      if (rid == id) return 'weeks $from–$to';
    }
    return '';
  }

  TestScanInfo? _match(String title) {
    final t = title.toLowerCase();
    for (final s in kTestsScans) {
      if (t.contains(s.name.en.toLowerCase())) return s;
      for (final a in s.aliases) {
        if (t.contains(a.en.toLowerCase())) return a.en.isEmpty ? null : s;
      }
    }
    return null;
  }

  Future<void> _share() async {
    final store = ScanQuestionsStore.instance;
    final next = _nextScan();

    // ⚠️ TICKED ONLY, AND THE ORDER IS THE PAGE'S. Sharing the whole list would
    // be sharing a leaflet; sharing them in tick order would arrive as whatever
    // sequence she happened to tap. Reading the page's own order back means the
    // message looks like the screen.
    final lines = <String>[];
    for (final g in kScanQuestions) {
      final picked =
          g.questions.where((q) => store.isTicked(q.id)).toList();
      if (picked.isEmpty) continue;
      lines.add('');
      lines.add(g.heading);
      for (final q in picked) {
        lines.add('• ${q.text}');
      }
    }
    if (lines.isEmpty) return;

    final header = next == null
        ? 'What to ask at my next scan'
        : 'What to ask at my ${next.$1} (${next.$2})';

    await Share.share('$header\n${lines.join('\n')}');
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          ScanQuestionsStore.instance,
          ScansStore.instance,
          V2PaletteStore.instance,
        ]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final store = ScanQuestionsStore.instance;
          final next = _nextScan();

          return PvDoorToolScaffold(
            hue: _hue,
            eyebrow: 'Before your appointment',
            title: next == null
                ? 'What to ask at your next scan'
                : 'What to ask at your ${next.$1}',
            intro: next == null
                ? 'Tick what matters to you, and take the list in with you. '
                    'Nothing here is a test — they are questions your doctor '
                    'is used to answering.'
                : 'Coming up around ${next.$2}. Tick what matters to you and '
                    'take the list in with you — these are questions your '
                    'doctor is used to answering.',
            action: store.count == 0 ? null : _ShareBar(p: p, count: store.count, onTap: _share),
            children: [
              for (final g in kScanQuestions) ...[
                pvDoorPad(Text(g.heading,
                    style: pvFraunces(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: -0.4,
                        color: p.ink1))),
                const SizedBox(height: 11),
                for (final q in g.questions) ...[
                  pvDoorPad(_QuestionRow(
                    question: q,
                    ticked: store.isTicked(q.id),
                    p: p,
                    onTap: () => store.toggle(q.id),
                  )),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 20),
              ],

              // ⚠️ THE INVITATION, NOT A BLANK. Nothing ticked means the share
              // bar is not there, and a screen whose only action has silently
              // vanished reads as broken. One line says where it went.
              if (store.count == 0)
                pvDoorPad(Text(
                    'Tick a few and a share button appears, so you can send '
                    'the list to yourself or to whoever is coming with you.',
                    style: pvManrope(
                        fontSize: 12.5, height: 1.55, color: p.ink3))),
              if (store.count > 0)
                pvDoorPad(GestureDetector(
                  onTap: store.clear,
                  behavior: HitTestBehavior.opaque,
                  child: Text('Clear all',
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink3)),
                )),
              const SizedBox(height: 22),
              pvDoorPad(PvDoorDisclaimer(p: p)),
              // Clearance for the pinned share bar, so the last row is
              // reachable rather than sitting under it.
              if (store.count > 0) const SizedBox(height: 64),
            ],
          );
        },
      );
}

/// One question. A tick, and the words.
///
/// ⚠️ THE WHOLE ROW IS THE TARGET, NOT THE BOX. A 22pt checkbox is under every
/// touch minimum, and a list where the words are inert teaches that the words
/// are not the thing — on a screen whose entire content is sentences.
class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.question,
    required this.ticked,
    required this.p,
    required this.onTap,
  });

  final ScanQuestion question;
  final bool ticked;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(_hue, p);
    return Semantics(
      checked: ticked,
      button: true,
      label: question.text,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            // ⚠️ A TICKED ROW GOES TINTED, NOT GREYED OUT. Greying says "done
            // with, ignore" — which is the opposite of what a ticked question
            // means here. It is the one she is definitely asking.
            color: ticked ? tint : p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ticked ? Colors.transparent : p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ticked ? p.ink1 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: ticked ? null : Border.all(color: p.line, width: 1.5),
              ),
              child: ticked
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(question.text,
                  style: pvManrope(
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: ticked ? FontWeight.w700 : FontWeight.w500,
                      color: p.ink1)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// The pinned share bar. Appears once something is ticked.
class _ShareBar extends StatelessWidget {
  const _ShareBar(
      {required this.p, required this.count, required this.onTap});

  final V2Palette p;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(
            kPvDoorGutter, 12, kPvDoorGutter,
            12 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: p.ground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.action,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ios_share_rounded, size: 17, color: p.onAction),
                const SizedBox(width: 9),
                Text(
                    count == 1
                        ? 'Share 1 question'
                        : 'Share $count questions',
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: p.onAction)),
              ],
            ),
          ),
        ),
      );
}

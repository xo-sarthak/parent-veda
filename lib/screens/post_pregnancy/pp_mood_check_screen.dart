// =============================================================================
//  You, Maa — a two-question check-in for her own mood (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P2 (You, Maa door): "Add a two-question check-in (low mood,
//  loss of interest) with the crisis path pinned, never a score."
//
//  ⚠️ DISAGREEMENT, LOGGED: the door's earlier brief said "no tools, no scored
//  mood tracker; the triage is the front door". The gap analysis wins (the
//  user's rule), and keeps that brief's spirit: there is NO score, NOTHING is
//  saved, and the triage keeps its place pinned above the door's rails.
//
//  THE TWO QUESTIONS are the standard two-question screen for low mood used by
//  midwives and GPs, in plain words. (This said "the Whooley questions"; those
//  ask about the past month. The two-week window here is the PHQ-2's, which is
//  what the questions actually are. Corrected 2026-10-25.)
//
//  ⚠️ AND TWO ABOUT WORRY (tools 25-28, D1, the user 2026-10-25: "Yes, add
//  them"). Worry after a birth is about as common as low mood and was never
//  asked. The GAD-2's two questions, plain words, same two weeks. Still one
//  rule: any yes says "talk to someone"; never a score, never a name.
//  REQUIRED_REVIEW (perinatal counsellor): the wording of all four questions
//  and of each answer.
//
//  AFTER A YES, SOMEWHERE TO GO (2026-10-25, after Me+'s "Ask for help"
//  above "Retake test", mobbin.com/screens/130988c9-87a4-43dd-a606-f056970ef0ac).
//  The result was words only. Now: one row to someone to talk to (the router
//  answers "joining soon" with Tele-MANAS first while the counsellors are
//  placeholders), and the pages that fit what she said (after Calm's
//  "Recommended for you").
//
//  "REMIND ME IN TWO WEEKS" (D2, opt-in). The reminder keeps only its date,
//  on this phone, never synced: a reminder belongs to the phone it rings on,
//  and a co-parent's phone must never ask her this. Her answers are still
//  never kept anywhere.
//
//  WHAT IT DOES WITH THE ANSWERS: one "yes" is enough to say "talk to your
//  doctor, you do not have to wait". It never names a condition and never
//  shows a number. The crisis path (Tele-MANAS 14416, 112) is pinned at the
//  top whatever she answers, because the frightening thoughts are not one of
//  the two questions and must never wait behind them.
//
//  NOTHING IS STORED, on purpose: no local row, no cloud row. A mood answer is
//  the most private thing in the app, and a record of it helps no one here.
//
//  Mobbin: the question large, two full-width answer cards with a line under
//  each, after Fresha (mobbin.com/screens/b7008fdd-a89a-4c70-9abe-1815b7dda8bf)
//  and Ro (mobbin.com/screens/8805b5d2-91aa-4032-93fb-4631e6f0c324).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/father_preview.dart';
import '../../services/notification_service.dart';
import '../../services/notification_link.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_toast.dart';
import '../pregnancy/preg_chrome.dart' show PregOfferRow, PregRowCard;
import 'pp_surface_router.dart' show ppPushSurface;
import '../../widgets/pv_feedback.dart' show PvChoiceTile;
import '../brackets/hub/hub_intent_art.dart' show HubIntentArt, IntentMark;
// import '../mind_mood/mm_crisis_path.dart' show MmCrisisPathScreen; // kept for revert
import 'pp_crisis_path_screen.dart' show PpCrisisPathScreen;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvSecondary, kPvInk, pvStorePalette;

const List<(String, String)> kPpMoodQuestions = [
  ('Over the last two weeks, have you often felt down, low or hopeless?',
      'Most days, for much of the day.'),
  ('Over the last two weeks, have you often had little interest or joy in things you usually enjoy?',
      'Things that used to lift you, and now do not.'),
  // The worry pair (D1, 2026-10-25), from [kPpMoodWorryFrom].
  ('Over the last two weeks, have you often felt nervous, anxious or on edge?',
      'A racing mind, a tight chest, or worry that is hard to switch off.'),
  ('Over the last two weeks, have you often not been able to stop or control worrying?',
      'Even when the baby is fine, the worry keeps coming back.'),
];

/// The first worry question's index; the ones before it are about low mood.
const int kPpMoodWorryFrom = 2;

/// The one reminder's notification id. Replaced, never stacked.
const int kPpMoodReminderId = 920101;

/// Where the reminder's date lives: on this phone only, never synced.
const String kPpMoodRemindAtKey = 'pp_mood_remind_at';

/// What one or more "yes" means. Never a condition, never a number.
const String kPpMoodTalkLine =
    'Thank you for being honest. It is worth talking to your doctor about how you have been feeling. '
    'You do not have to wait for your next check-up, and you do not have to be sure first. '
    'This is common after a baby, and it gets better with help.';

const String kPpMoodOkLine =
    'Thank you for checking in. If that changes, even a little, come back any time. '
    'Rest and help with the baby matter for you too.';

class PpMoodCheckScreen extends StatefulWidget {
  const PpMoodCheckScreen({super.key});

  @override
  State<PpMoodCheckScreen> createState() => _PpMoodCheckScreenState();
}

class _PpMoodCheckScreenState extends State<PpMoodCheckScreen> {
  final List<bool?> _answers = List<bool?>.filled(kPpMoodQuestions.length, null);

  bool get _done => !_answers.contains(null);
  bool get _anyYes => _answers.contains(true);
  bool get _lowYes => _answers.take(kPpMoodWorryFrom).contains(true);
  bool get _worryYes => _answers.skip(kPpMoodWorryFrom).contains(true);

  /// When "Remind me in two weeks" will ask; null when it is not set.
  DateTime? _remindAt;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final at = DateTime.tryParse(prefs.getString(kPpMoodRemindAtKey) ?? '');
      if (!mounted) return;
      setState(() =>
          _remindAt = at != null && at.isAfter(DateTime.now()) ? at : null);
    } catch (_) {}
  }

  Future<void> _setReminder() async {
    final now = DateTime.now();
    final at = DateTime(now.year, now.month, now.day + 14, 10);
    setState(() => _remindAt = at);
    pvToast(context, "We'll ask again on ${_day(at)}",
        kind: PvToastKind.done, action: 'Undo', onAction: _cancelReminder);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPpMoodRemindAtKey, at.toIso8601String());
    } catch (_) {}
    // The words say nothing about her answers: a lock screen is not private.
    await NotificationService.instance.scheduleOneOff(
      id: kPpMoodReminderId,
      title: 'How have you been?',
      body: 'Two minutes, just for you.',
      when: at,
      payload: const NotificationLink(NotificationLink.moodCheck, '').payload, // 6b L4
    );
  }

  Future<void> _cancelReminder() async {
    if (mounted) setState(() => _remindAt = null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kPpMoodRemindAtKey);
    } catch (_) {}
    await NotificationService.instance.cancel(kPpMoodReminderId);
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];
  static String _day(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  void _page(String id) =>
      ppPushSurface(context, 'pp_page/parenting_maternal/$id');

  // ⚠️ ONE CRISIS SCREEN FOR HER (door 3, §5, 2026-10-25). This opened the
  // pregnancy `MmCrisisPathScreen` under a pregnancy route name, while every
  // crisis link on her door opens `PpCrisisPathScreen` through the router.
  // Two screens for one emergency drift. The pregnancy screen is untouched.
  // Was, kept for revert:
  // void _crisis() => Navigator.of(context).push(MaterialPageRoute<void>(
  //       settings: const RouteSettings(name: 'mind/crisis'),
  //       builder: (_) => const MmCrisisPathScreen(),
  //     ));
  void _crisis() => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp_crisis_path'),
        builder: (_) => const PpCrisisPathScreen(),
      ));

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: 288,
      // In the father's view the questions are his (2026-10-25). Kept for
      // revert: 'You, the mother' for everyone.
      eyebrow: FatherPreview.instance.on ? 'For you' : 'You, the mother', // was 'You, Maa' (English only, 2026-10-07)
      mark: IntentMark.moodArc,
      title: 'How have you been?',
      // Was "Two questions about the last two weeks." (D1, 2026-10-25).
      intro: 'Four questions about the last two weeks. No score, and nothing is saved.',
      children: [
        // ---- pinned: the crisis path, whatever she answers ----
        pregToolPad(Material(
          key: const ValueKey('pp_mood_crisis'),
          color: const Color(0xFFFFF1F0),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _crisis,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // A drawn mark, not a Material icon (2026-10-25). Kept for
                // revert: Icon(Icons.call_outlined, size: 20, color: p.ink1),
                SizedBox(
                  width: 22,
                  height: 22,
                  child: HubIntentArt(mark: IntentMark.phoneMark, tint: p.ink1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'If you have thoughts of harming yourself or your baby, call Tele-MANAS on 14416, '
                    'free, day and night, or 112. Tap here for the numbers.',
                    style: pvManrope(fontSize: 13.5, height: 1.5, fontWeight: FontWeight.w600, color: p.ink1),
                  ),
                ),
              ]),
            ),
          ),
        )),
        const SizedBox(height: 22),
        for (var i = 0; i < kPpMoodQuestions.length; i++) ...[
          pregToolPad(Text(kPpMoodQuestions[i].$1,
              style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3, color: p.ink1))),
          const SizedBox(height: 4),
          pregToolPad(Text(kPpMoodQuestions[i].$2, style: pvManrope(fontSize: 13, color: p.ink3))),
          const SizedBox(height: 10),
          pregToolPad(_answer(i, true, 'Yes', 'More often than not')),
          const SizedBox(height: 8),
          pregToolPad(_answer(i, false, 'No', 'Not really')),
          const SizedBox(height: 22),
        ],
        if (_done) ...[
          pregToolPad(Container(
            key: ValueKey(_anyYes ? 'pp_mood_talk' : 'pp_mood_ok'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: Text(_anyYes ? kPpMoodTalkLine : kPpMoodOkLine,
                style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1)),
          )),
          if (_anyYes) ...[
            const SizedBox(height: 14),
            // Somewhere to go, first (Me+'s "Ask for help").
            pregToolPad(PregRowCard(children: [
              PregOfferRow(
                key: const ValueKey('pp_mood_help'),
                mark: IntentMark.cuppedHands,
                hue: 10,
                title: 'Find someone to talk to',
                line: 'A counsellor or your doctor. Tele-MANAS 14416 is free, any hour.',
                onTap: () =>
                    ppPushSurface(context, 'pp_experts/Maternal mental health'),
              ),
            ])),
            const SizedBox(height: 14),
            // The pages that fit what she said (Calm's "Recommended for you").
            pregToolPad(PregRowCard(children: [
              PregOfferRow(
                key: const ValueKey('pp_mood_read_help'),
                mark: IntentMark.bookMark,
                hue: 288,
                title: 'Getting help, step by step',
                line: 'Who to tell, what to say, and what happens next',
                onTap: () => _page('mind_getting_help'),
              ),
              if (_lowYes)
                PregOfferRow(
                  key: const ValueKey('pp_mood_read_low'),
                  mark: IntentMark.bookMark,
                  hue: 288,
                  title: 'Baby blues, or something more?',
                  line: 'How to tell them apart, and why it matters',
                  onTap: () => _page('mind_blues_vs_ppd'),
                ),
              if (_worryYes)
                PregOfferRow(
                  key: const ValueKey('pp_mood_read_worry'),
                  mark: IntentMark.bookMark,
                  hue: 288,
                  title: 'When worry will not switch off',
                  line: 'Anxiety after a birth, and what helps',
                  onTap: () => _page('mind_anxiety'),
                ),
              if (FatherPreview.instance.on)
                PregOfferRow(
                  key: const ValueKey('pp_mood_read_partner'),
                  mark: IntentMark.bookMark,
                  hue: 288,
                  title: 'When the father is low too',
                  line: 'It happens to fathers as well, and it helps to say so',
                  onTap: () => _page('people_partner_low'),
                ),
            ])),
          ],
          const SizedBox(height: 14),
          // "Remind me in two weeks" (D2): only a date, on this phone.
          if (_remindAt == null)
            pregToolPad(PvSecondary(
              key: const ValueKey('pp_mood_remind'),
              label: 'Remind me in two weeks',
              onTap: _setReminder,
            ))
          else
            pregToolPad(Row(children: [
              Expanded(
                child: Text("We'll ask again on ${_day(_remindAt!)}.",
                    key: const ValueKey('pp_mood_remind_set'),
                    style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
              ),
              TextButton(
                key: const ValueKey('pp_mood_remind_cancel'),
                onPressed: () {
                  _cancelReminder();
                  pvToast(context, 'Reminder cancelled', kind: PvToastKind.done);
                },
                child: Text('Cancel',
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
            ])),
          const SizedBox(height: 10),
          pregToolPad(PvSecondary(
            label: 'Start again',
            onTap: () => setState(() => _answers.fillRange(0, _answers.length, null)),
          )),
        ],
      ],
    );
  }

  // The shared answer row (2026-10-10, one MCQ look app-wide): see
  // `PvChoiceTile` in lib/widgets/pv_feedback.dart. Was an ink slab when
  // chosen; now the ink edge and tick every question flow uses. Same key.
  Widget _answer(int q, bool value, String title, String line) =>
      PvChoiceTile(
        key: ValueKey('pp_mood_q${q}_${value ? 'yes' : 'no'}'),
        label: title,
        subtitle: line,
        selected: _answers[q] == value,
        onTap: () => setState(() => _answers[q] = value),
      );

  // Kept for revert (2026-10-10): the ink-filled answer.
  // ignore: unused_element
  Widget _answerBefore(int q, bool value, String title, String line) {
    final p = pvStorePalette;
    final on = _answers[q] == value;
    return Material(
      key: ValueKey('pp_mood_q${q}_${value ? 'yes' : 'no'}'),
      color: on ? kPvInk : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: on ? kPvInk : p.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _answers[q] = value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: on ? Colors.white : p.ink1)),
            const SizedBox(height: 2),
            Text(line, style: pvManrope(fontSize: 12.5, color: on ? Colors.white70 : p.ink3)),
          ]),
        ),
      ),
    );
  }
}

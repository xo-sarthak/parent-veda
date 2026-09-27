// =============================================================================
//  "My period came" - a scripted chat
// -----------------------------------------------------------------------------
//  Kind first, then what it means, then the practical part (is day 1 logged?),
//  then something that might help, then a next step. In that order because
//  that is the order a friend would do it in: nobody wants the logging
//  question before anyone has said they are sorry.
//
//  ⚠️ IT LOGS ONLY WHEN SHE TAPS. A period start is a real write that moves
//  every date in the stage, so the chat asks, and the chip is her answer. It
//  never logs on its own because she opened it.
//
//  ⚠️ ONE LINE OF FEELING, THEN HELP (TTC-VOICE rule 5). The script does not
//  dwell. The Hard days read is there for when she wants more.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../ttc/cycle_store.dart';
import '../../../ttc/ttc_chapter.dart';
import '../../../ttc/ttc_period_due.dart';
import '../../../ttc/ttc_store.dart';
import 'ttc_chat.dart';

/// The Hard days read, best first, ending on the Mind & body door that already
/// ships. Shared with the "Your period came" message's destination.
const List<String> kTtcHardDaysRead = [
  'ttc_read/ttc_read_period_came',
  'ttc_read/ttc_read_trying_takes_over',
  'ttc_door/ttc_mind_body',
];

class TtcPeriodCameChat extends TtcChatScript {
  TtcPeriodCameChat({
    DateTime? today,
    DateTime? lastStart,
    TimingOwnership? ownership,
    void Function(DateTime day)? logPeriod,
  })  : today = _day(today ?? DateTime.now()),
        lastStart = lastStart ?? CycleStore.instance.lastPeriodStart,
        ownership = ownership ?? TtcStore.instance.ownership,
        logPeriod = logPeriod ?? CycleStore.instance.logPeriodStart;

  final DateTime today;
  final DateTime? lastStart;
  final TimingOwnership ownership;
  final void Function(DateTime day) logPeriod;

  bool get _natural => ownership == TimingOwnership.parentveda;

  /// Already logged for today or yesterday, so the chat does not ask again.
  bool get alreadyLogged {
    final s = lastStart;
    if (s == null) return false;
    return !_day(s).isBefore(today.subtract(const Duration(days: 1)));
  }

  @override
  String get title => 'My period came';

  @override
  TtcChatStep start() => TtcChatStep(
        const [
          'Your period came.',
          "If you were hoping this month, that's hard. It's okay to feel low "
              'about it.',
        ],
        [
          TtcChatChoice('What does it mean?', next: meaning),
          TtcChatChoice("I'd rather not talk now", next: notNow),
        ],
      );

  TtcChatStep meaning() => TtcChatStep(
        [
          'It means a new cycle has started. The first day of real bleeding, '
              'not spotting, counts as day 1.',
          if (_natural)
            "It doesn't mean something is wrong. Most couples take several "
                'months, and each cycle is a fresh start.'
          else
            "It doesn't mean something is wrong with you. Many clinics ask you "
                "to call on day 1 or 2 of your period, so they can plan what's "
                'next.',
          if (alreadyLogged)
            "It's logged for ${ttcDayDate(lastStart!)}."
          else
            'Shall we log it?',
        ],
        alreadyLogged
            ? support().choices
            : [
                TtcChatChoice('Yes, it started today',
                    next: () => logged(today)),
                TtcChatChoice('It started yesterday',
                    next: () =>
                        logged(today.subtract(const Duration(days: 1)))),
                TtcChatChoice('Not now', next: support),
              ],
      );

  TtcChatStep logged(DateTime day) {
    logPeriod(day);
    return TtcChatStep(
      ['Done. Day 1 is ${ttcDayDate(day)}.', ...support().say],
      support().choices,
    );
  }

  TtcChatStep support() => TtcChatStep(
        const ['Would anything help right now?'],
        [
          const TtcChatChoice('A read for hard days', open: kTtcHardDaysRead),
          const TtcChatChoice('Something calming', open: ['ttc_mind_today']),
          if (_natural)
            const TtcChatChoice('My next fertile window', open: ['ttc_window'])
          else
            const TtcChatChoice('My clinic dates', open: ['ttc_treatment']),
          const TtcChatChoice("I'm okay, thanks", done: true),
        ],
      );

  TtcChatStep notNow() => TtcChatStep(
        [
          "That's okay. We're here whenever you want us.",
          if (!alreadyLogged)
            'When you feel like it, you can log it from your cycle.',
        ],
        [
          if (!alreadyLogged)
            const TtcChatChoice('Log it now', open: ['ttc_cycle']),
          const TtcChatChoice('Done', done: true),
        ],
      );
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// The screen, for the router.
class TtcPeriodCameChatScreen extends StatelessWidget {
  const TtcPeriodCameChatScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      TtcChatScreen(script: TtcPeriodCameChat());
}

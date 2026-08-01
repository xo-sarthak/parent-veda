// =============================================================================
//  Due date · Track ovulation — the two doors OUT of the parenting stage.
// -----------------------------------------------------------------------------
//  From the parenting review: "Due date and ovulation" came out of Tools and
//  became two separate features in the Explore menu, and each one asks a
//  question before it does anything:
//
//     Due date        -> "are you pregnant?"  -> the pregnancy side
//     Track ovulation -> "are you trying?"    -> the trying-to-conceive side
//
//  WHY THE QUESTION IS NOT SKIPPABLE, and why it is worded carefully.
//
//  These rows sit in a PARENTING app, in front of someone who already has a
//  child. Tapping "Due date" is not proof of anything — it is as likely to be
//  curiosity, or a partner looking, or a mis-tap. Moving a family into the
//  pregnancy stage on a tap would change what the whole app says to them, and
//  the app must never announce a pregnancy that has not been confirmed.
//
//  It also has to be askable of someone for whom the answer is painful. A
//  parent who has been trying for two years, or who has lost a pregnancy, will
//  open this. So the question is short, the "not yet" answer is a real option
//  rather than a dismissal, and nothing is set as a consequence of merely
//  looking.
//
//  DERIVE, NEVER ASK is the house rule — but this is precisely the case the
//  rule carves out: whether a family is trying for another baby is genuinely
//  unknowable from anything they have told us, and the answer unlocks a
//  different stage of the app. So it is asked once, plainly, with what it
//  unlocks stated.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

/// Which door was opened. The copy differs; the shape does not.
enum NextBabyIntent { dueDate, ovulation }

class NextBabyScreen extends StatelessWidget {
  const NextBabyScreen({super.key, required this.intent});

  final NextBabyIntent intent;

  bool get _isDue => intent == NextBabyIntent.dueDate;

  String get _title => _isDue ? 'Due date' : 'Track ovulation';

  String get _question =>
      _isDue ? 'Are you pregnant?' : 'Are you trying to conceive?';

  String get _blurb => _isDue
      ? 'ParentVeda has a whole pregnancy side — week by week, scans, '
          'appointments, the lot. If you are expecting, this is the way in.'
      : 'ParentVeda has a trying-to-conceive side — your cycle, the fertile '
          'window, tests worth doing and what they mean.';

  String get _yes => _isDue ? 'Yes, I am pregnant' : 'Yes, we are trying';

  String get _no => _isDue ? 'Not right now' : 'Not right now';

  IconData get _icon =>
      _isDue ? Icons.calendar_month_outlined : Icons.egg_outlined;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ppBack(context, 'Explore'),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ppPurple.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(_icon, size: 26, color: ppPurple),
                ),
                const SizedBox(height: 20),
                Text(_title, style: ppFraunces(30, h: 1.05)),
                const SizedBox(height: 10),
                Text(_question, style: ppJakarta(18)),
                const SizedBox(height: 10),
                Text(_blurb, style: ppBody(14, h: 1.6)),

                const SizedBox(height: 26),
                _primary(context),
                const SizedBox(height: 10),
                _secondary(context),

                const SizedBox(height: 24),
                _note(),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primary(BuildContext context) => GestureDetector(
        onTap: () => _showComingSoon(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ppPurple,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(_yes,
              style: ppBody(14, color: Colors.white, w: FontWeight.w800)),
        ),
      );

  Widget _secondary(BuildContext context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(_no, style: ppJakarta(14, color: ppPurple)),
        ),
      );

  /// The switch itself is not built yet, and saying so is better than a button
  /// that appears to do something.
  ///
  /// Moving a family between stages is not navigation — the stage decides what
  /// every screen in the app says, which store is loaded and what the home page
  /// even is. It needs a real handover (see STILL-OPEN), so this states the
  /// position honestly rather than pushing a screen that would show a
  /// pregnancy home with a toddler's data behind it.
  void _showComingSoon(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: ppBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
                color: ppBorder, borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(height: 22),
          Text(
              _isDue
                  ? 'Congratulations — and one moment'
                  : 'Good luck — and one moment',
              style: ppJakarta(17)),
          const SizedBox(height: 12),
          Text(
              _isDue
                  ? 'Moving you across to the pregnancy side is coming very '
                      'soon. It is more than opening a screen — it changes what '
                      'every page of ParentVeda says, so we would rather build '
                      'it properly than half-open the door.\n\nYour parenting '
                      'side stays exactly as it is either way. Nothing you have '
                      'saved goes anywhere.'
                  : 'Moving you across to the trying-to-conceive side is coming '
                      'very soon. It changes what every page of ParentVeda '
                      'says, so we would rather build it properly than '
                      'half-open the door.\n\nYour parenting side stays exactly '
                      'as it is either way. Nothing you have saved goes '
                      'anywhere.',
              style: ppBody(13.5, h: 1.65)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ppPurple,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Got it',
                  style: ppBody(13.5, color: Colors.white, w: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _note() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
            _isDue
                ? 'Nothing changes just because you looked. We will not tell '
                    'anyone, show a countdown, or alter a single screen until '
                    'you say yes.'
                : 'Nothing changes just because you looked. This stays between '
                    'you and the app.',
            style: ppBody(12.5, h: 1.6)),
      );
}

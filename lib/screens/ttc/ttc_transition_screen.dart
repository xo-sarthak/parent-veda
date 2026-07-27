// =============================================================================
//  TTC → Pregnancy - the transition
// -----------------------------------------------------------------------------
//  The one screen a couple sees when a positive test is recorded. It exists for
//  a single reason: to prove the promise rather than assert it.
//
//  So it does not say "everything is safe". It shows counts read back from the
//  stores - eleven journal entries, four moments in your story, two supplements
//  - because a number is checkable and a reassurance is not.
//
//  It is also the only place in the product where the word "congratulations"
//  deliberately does not appear. Plenty of couples reach this screen carrying a
//  previous loss, and the right note here is quiet certainty, not confetti.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_transition.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

/// Asks first, then transitions. Returns true if the couple went through.
Future<bool> recordPositiveTest(BuildContext context) async {
  final t = TtcS.current();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(t.transitionConfirmTitle, style: ttcJakarta(17)),
      content: Text(t.transitionConfirmBody, style: ttcBody(13.5, h: 1.55)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(t.transitionNotYet,
              style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(t.transitionYes,
              style: ttcBody(13, color: ttcPurple, w: FontWeight.w800)),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  const engine = TtcTransitionEngine();
  final result = await engine.confirmPregnancy();
  if (!context.mounted) return true;

  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => TtcTransitionScreen(result: result),
    settings: const RouteSettings(name: 'ttc/transition'),
  ));
  return true;
}

class TtcTransitionScreen extends StatelessWidget {
  const TtcTransitionScreen({super.key, required this.result});

  final TtcTransitionResult result;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 24, ttcGutter, 40),
              children: [
                // Quiet certainty, not confetti. Plenty of couples arrive here
                // carrying a previous loss.
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ttcCardRadius),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [ttcPurple, Color(0xFF8B4FD0), ttcCoral],
                      stops: [0.0, 0.55, 1.0],
                    ),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.transitionTitle,
                            style: ttcFraunces(30,
                                w: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 12),
                        Text(t.transitionSubtitle,
                            style: ttcBody(14,
                                color: Colors.white.withValues(alpha: 0.95),
                                h: 1.6)),
                      ]),
                ),
                const SizedBox(height: 20),

                // ---- where she is --------------------------------------
                TtcCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.transitionWeeks(result.weeksPregnant),
                            style: ttcJakarta(18)),
                        const SizedBox(height: 10),
                        Text(t.transitionWhyWeeks, style: ttcBody(13, h: 1.6)),
                        const SizedBox(height: 16),
                        ttcDivider(),
                        const SizedBox(height: 14),
                        Text(t.transitionDueDate.toUpperCase(),
                            style: ttcBody(9.5,
                                color: ttcMuted, w: FontWeight.w800)),
                        const SizedBox(height: 5),
                        Text(_fmt(result.dueDate),
                            style: ttcFraunces(24,
                                w: FontWeight.w600, color: ttcTitleInk)),
                        // Said plainly when we had to guess, rather than
                        // presenting an assumption as a date.
                        if (!result.dueDateWasDerived) ...[
                          const SizedBox(height: 10),
                          Text(t.transitionDueDateGuess,
                              style: ttcBody(12, color: ttcBrown, h: 1.5)),
                        ],
                      ]),
                ),
                const SizedBox(height: 20),

                // ---- what carried over ---------------------------------
                //  Counts, not claims.
                ttcSectionTitle(t.transitionCarried),
                TtcCard(
                  child: Column(children: [
                    if (result.journalEntries > 0)
                      _carried(Icons.edit_outlined,
                          t.transitionJournal(result.journalEntries)),
                    if (result.timelineEvents > 0)
                      _carried(Icons.timeline_rounded,
                          t.transitionStory(result.timelineEvents)),
                    if (result.supplements > 0)
                      _carried(Icons.medication_outlined,
                          t.transitionSupplements(result.supplements)),
                    if (result.cyclesLogged > 0)
                      _carried(Icons.favorite_outline_rounded,
                          t.transitionCycles(result.cyclesLogged)),
                    if (result.partnerJoined)
                      _carried(Icons.people_outline_rounded,
                          t.transitionPartner),
                  ]),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => ttcSoon(context, t.transitionNext),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        color: ttcPurple,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(t.transitionNext,
                        style: ttcBody(14.5,
                            color: Colors.white, w: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 14),

                // Undo, in plain sight. A stage change you cannot reverse
                // would be the cruellest bug in this product.
                Center(
                  child: GestureDetector(
                    onTap: () => _undo(context),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(t.transitionUndo,
                          style: ttcBody(12.5,
                              color: ttcMuted, w: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _carried(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: Row(children: [
          Icon(icon, size: 17, color: ttcPurple),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: ttcBody(13.5, color: ttcInk, w: FontWeight.w600))),
          const Icon(Icons.check_rounded, size: 16, color: ttcPurple),
        ]),
      );

  Future<void> _undo(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final t = TtcS.current();
    await const TtcTransitionEngine().undo();
    messenger.showSnackBar(SnackBar(
      content: Text(t.transitionUndone),
      behavior: SnackBarBehavior.floating,
    ));
    navigator.maybePop();
  }

  static String _fmt(DateTime d) {
    const m = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

/// The entry point on Today. Always present - a couple can test at any point in
/// the cycle, and hiding this outside the waiting days would mean the one thing
/// they most want to tell us is missing on the day they want to tell us.
class TtcRecordTestCard extends StatelessWidget {
  const TtcRecordTestCard({super.key, required this.t});

  final TtcS t;

  @override
  Widget build(BuildContext context) {
    // Deliberately understated: no gradient, no celebration styling. This is a
    // door, not a prompt, and it must never read as "why haven't you tested?".
    return TtcCard(
      onTap: () => recordPositiveTest(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        const Icon(Icons.auto_awesome_outlined, size: 18, color: ttcMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.transitionRecord,
                style: ttcBody(13.5, color: ttcInk, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(t.transitionRecordBody, style: ttcBody(11.5)),
          ]),
        ),
      ]),
    );
  }
}

/// Convenience so screens can preview the due date without transitioning.
DateTime? ttcPreviewDueDate() {
  final lmp = CycleStore.instance.lastPeriodStart;
  return lmp == null ? null : TtcTransitionEngine.dueDateFrom(lmp);
}

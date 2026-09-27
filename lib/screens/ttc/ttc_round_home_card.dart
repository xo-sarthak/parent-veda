// =============================================================================
//  The home's round card: one notice at a time, each said once
// -----------------------------------------------------------------------------
//  Added 2026-09-26 for docs/TTC-TREATMENT-FLOW.md (§2b, §2d, B3, B4) and the
//  user's rule of the same day: NOTHING CHANGES SILENTLY. The home has one
//  slot for the round, and it shows, strongest first, one at a time:
//
//    1. the check-in, when it is due (7 quiet days, or back after 30 days);
//    2. "Your home now follows your round", once, on its first treatment day,
//       with "What changed";
//    3. "When you're ready, tell us how the test went", from test day;
//    4. "Your fertile days are back", once, the day her own cycle returns;
//    5. a round closed in the last 7 days, with Undo;
//    6. "Add your clinic's dates", for a treatment label with no dates (the
//       resolver pass's decision: the obvious way in).
//
//  The one-time flags live in the store (`markActiveAnnounced`,
//  `markReturnAnnounced`), local to her, so each notice appears exactly once
//  and never for her partner's "seen".
//
//  Mobbin: Apple Health's dismissible info banner with its own action link
//  (https://mobbin.com/flows/61a17fd3-3918-40b6-bfcb-6b12927d5244), in this
//  app's own system: a white card with a hairline, ink pills, Newsreader and
//  Manrope, a line icon.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_care_pathway.dart' show TimingOwnership, TtcPath;
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_treatment_round.dart';
import '../../ttc/ttc_treatment_store.dart';
import 'ttc_common.dart';
import 'ttc_round_strings.dart';
import 'ttc_treatment_round_screens.dart';
import 'ttc_treatment_screen.dart' show openTtcTreatment;

/// Which notice the home's round slot shows.
enum TtcRoundNotice { checkIn, active, result, fertileBack, closed, invite }

/// The notice the home shows now, or null. Pure over the stores, so a test
/// can walk it without pumping the home.
TtcRoundNotice? ttcRoundNoticeNow({DateTime? now}) {
  final at = now ?? DateTime.now();
  final t = TtcTreatmentStore.instance;
  if (t.checkInDue(now: at)) return TtcRoundNotice.checkIn;
  if (t.activeAnnouncementDue(now: at)) return TtcRoundNotice.active;
  if (!t.cycle.isEmpty &&
      t.cycle.kind != null &&
      ttcTreatmentPhase(t.cycle, at) == TtcRoundPhase.testDay) {
    return TtcRoundNotice.result;
  }
  final own = TtcStore.instance.ownership == TimingOwnership.parentveda;
  if (t.returnAnnouncementDue(ownCycleAgain: own)) {
    return TtcRoundNotice.fertileBack;
  }
  if (t.canUndoClose(now: at)) return TtcRoundNotice.closed;
  if (TtcStore.instance.path != TtcPath.natural && t.cycle.isEmpty && own) {
    return TtcRoundNotice.invite;
  }
  return null;
}

/// The check-in as a card, for the home and the treatment screen.
class TtcRoundCheckInCard extends StatelessWidget {
  const TtcRoundCheckInCard({super.key, required this.onAnswer});
  final VoidCallback onAnswer;

  @override
  Widget build(BuildContext context) => TtcRoundNoticeCard(
        key: const ValueKey('ttc_round_notice_checkIn'),
        icon: Icons.help_outline_rounded,
        title: kTtcCheckInCardTitle,
        body: TtcTreatmentStore.instance.askOnReturnPending
            ? kTtcCheckInReturnBody
            : kTtcCheckInBody,
        primary: (kTtcCheckInCardCta, onAnswer),
        secondary: (
          kTtcCheckInLater,
          () => TtcTreatmentStore.instance.snoozeCheckIn(),
        ),
      );
}

/// The home's slot. Renders nothing when no notice applies.
class TtcRoundHomeCard extends StatelessWidget {
  const TtcRoundHomeCard({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        // Its own listener, so "Got it" and Undo take effect wherever the
        // card sits, not only under a screen that happens to rebuild.
        listenable: Listenable.merge(
            [TtcTreatmentStore.instance, TtcStore.instance]),
        builder: (context, _) => _card(context),
      );

  Widget _card(BuildContext context) {
    final t = TtcTreatmentStore.instance;
    switch (ttcRoundNoticeNow()) {
      case null:
        return const SizedBox.shrink();
      case TtcRoundNotice.checkIn:
        return TtcRoundCheckInCard(
            onAnswer: () => showTtcCheckInSheet(context));
      case TtcRoundNotice.active:
        return TtcRoundNoticeCard(
          key: const ValueKey('ttc_round_notice_active'),
          icon: Icons.event_available_outlined,
          title: kTtcActiveTitle,
          body: kTtcActiveBody,
          primary: (kTtcActiveGotIt, t.markActiveAnnounced),
          secondary: (kTtcActiveWhatChanged, () => _whatChanged(context)),
        );
      case TtcRoundNotice.result:
        return TtcRoundNoticeCard(
          key: const ValueKey('ttc_round_notice_result'),
          icon: Icons.biotech_outlined,
          title: kTtcResultCardTitle,
          body: kTtcResultBody,
          primary: (kTtcRoundTellResult, () => openTtcTreatmentResult(context)),
        );
      case TtcRoundNotice.fertileBack:
        return TtcRoundNoticeCard(
          key: const ValueKey('ttc_round_notice_fertileBack'),
          icon: Icons.wb_twilight_rounded,
          title: kTtcReturnTitle,
          body: kTtcReturnBody,
          primary: (kTtcActiveGotIt, t.markReturnAnnounced),
        );
      case TtcRoundNotice.closed:
        final how = t.lastClosed?.outcome ?? TtcRoundOutcome.ended;
        return TtcRoundNoticeCard(
          key: const ValueKey('ttc_round_notice_closed'),
          icon: Icons.check_circle_outline_rounded,
          title: 'Round closed',
          // Once her own cycle is back, say so rather than "when you log".
          body: how != TtcRoundOutcome.positive &&
                  TtcStore.instance.ownership == TimingOwnership.parentveda
              ? kTtcClosedOwnCycleBack
              : ttcClosedLine(how),
          // A positive round leads to Pregnancy, dated by the clinic
          // (2026-09-26, B8); Undo stays one tap away. Kept for revert: Undo
          // then See your round, for every outcome.
          primary: how == TtcRoundOutcome.positive &&
                  !TtcStore.instance.pregnancyConfirmed
              ? (kTtcPanelDatePregnancy, () => openTtcRoundPregnancy(context))
              : (kTtcRoundUndoCta, () => t.undoClose()),
          secondary: how == TtcRoundOutcome.positive &&
                  !TtcStore.instance.pregnancyConfirmed
              ? (kTtcRoundUndoCta, () => t.undoClose())
              : (kTtcSeeRound, () => openTtcTreatment(context)),
        );
      case TtcRoundNotice.invite:
        return TtcRoundNoticeCard(
          key: const ValueKey('ttc_round_notice_invite'),
          icon: Icons.event_note_outlined,
          title: kTtcInviteTitle,
          body: kTtcInviteBody,
          primary: (kTtcRoundStartCta, () => openTtcTreatmentStart(context)),
        );
    }
  }
}

Future<void> _whatChanged(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      routeSettings: const RouteSettings(name: 'ttc/treatment/what_changed'),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kTtcActiveWhatChanged,
                    style: pvFraunces(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: ttcTitleInk)),
                const SizedBox(height: 12),
                for (final line in kTtcActiveChanges) ...[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(Icons.check_rounded,
                          size: 16, color: ttcTitleInk),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(line,
                          style: pvManrope(
                              fontSize: 13.5, height: 1.5, color: ttcTitleInk)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                TtcRoundButton(
                  key: const ValueKey('ttc_what_changed_got_it'),
                  label: kTtcActiveGotIt,
                  onTap: () {
                    TtcTreatmentStore.instance.markActiveAnnounced();
                    Navigator.of(ctx).pop();
                  },
                ),
              ]),
        ),
      ),
    );

/// A white card with a hairline: a line icon, a title, one or two lines, and
/// one or two ink pills that say what they do.
class TtcRoundNoticeCard extends StatelessWidget {
  const TtcRoundNoticeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.primary,
    this.secondary,
  });

  final IconData icon;
  final String title, body;
  final (String, VoidCallback) primary;
  final (String, VoidCallback)? secondary;

  @override
  Widget build(BuildContext context) {
    Widget pill(String label, VoidCallback onTap, {required bool ink}) =>
        Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: Material(
            color: ink ? ttcTitleInk : Colors.white,
            shape: StadiumBorder(
                side: ink
                    ? BorderSide.none
                    : const BorderSide(color: ttcLine, width: 1.4)),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(label,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: ink ? Colors.white : ttcTitleInk)),
              ),
            ),
          ),
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ttcLine, width: 1.2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 20, color: ttcTitleInk),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: pvFraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: ttcTitleInk)),
          ),
        ]),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(body,
              style: pvManrope(fontSize: 13, height: 1.5, color: ttcSoft)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            pill(primary.$1, primary.$2, ink: true),
            if (secondary case final s?) pill(s.$1, s.$2, ink: false),
          ]),
        ),
      ]),
    );
  }
}

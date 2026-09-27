// =============================================================================
//  The TTC home's gap-analysis pieces - 2026-09-26
// -----------------------------------------------------------------------------
//  The TTC gap analysis ("Behind: Home & daily", "Behind: Guided help",
//  "Behind: Settings") asked the home to speak to where she is: "Time to test"
//  when a test can answer, a kind line on the day a period comes, a messages
//  entry with an unread dot, a calm card when it may be time for a check, and
//  a way into "Trying to conceive 101" for someone new.
//
//  The widgets live here rather than inside `ttc_home_v3.dart` (5,000 lines
//  of reasoning already) so each piece can be read, and tested, on its own.
//  Every decision they show comes from `lib/ttc/ttc_home_situation.dart`;
//  these only choose words and shapes.
//
//  House rules held here: the words follow `docs/TTC-VOICE.md` (warm, plain,
//  no dashes, no exclamation marks, no emoji); line icons only; a destination
//  is a surface id through the router, never a screen built here; nothing is
//  hidden that is a feature, and the two cards that do step aside (the check
//  card after "Not now", the course card after two steps) are invitations
//  that have done their job, not features.
//
//  ⚠️ THE REVIEW PASS, 2026-09-26 (reviewer MR, mobbin_review.md §4):
//    H2  the late-day button says what it opens, "Should I test?", at 48pt,
//        with a press and a haptic. It is the hero's one primary (Flo's late
//        day: one line and ONE pill, FLO-LATE,
//        https://mobbin.com/screens/f92aea87-388d-42b6-b3b0-fb36b9b71a84).
//    H6  the envelope's hit area is 44 (the 38 disc is unchanged) and its dot
//        is `ttcCoral`, not a literal.
//    H7  the check card is drawn as a tip (a left rule, eyebrow, title, body,
//        two links), because a card is for an object and this is a sentence
//        (§4.0 addendum). Clue's unboxed "Top things to know" (CLUE-TOP,
//        https://mobbin.com/screens/8aa23c54-85d1-4da6-acf6-53d62ded4628).
//    H8  the 101 card has ONE tap target and radius 16; "All steps" is its own
//        row under it, not a button nested inside a button.
//    H9  the period-came heart is ink, not violet (the link stays violet).
//    H10 "Talk it through" is the house notice, `pvSnack`: a white lifted
//        card with an ink pill, which always times out.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../../ttc/ttc_home_prefs.dart';
import '../../ttc/ttc_period_due.dart' show ttcDays;
import '../../ttc/ttc_reads_data.dart' show ttcReadById;
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcCoral;
import 'ttc_surface_router.dart';

// =============================================================================
//  The words
// =============================================================================

/// The big line when her period is late on her own cycle.
const String kTtcTimeToTest = 'Time to test';

/// The small line under it.
String ttcTimeToTestBody(int daysLate) =>
    'Your period is ${ttcDays(daysLate)} later than usual. '
    'A home test is reliable from today.';

/// The button under the hero on a late day (H2): it says what it opens.
const String kTtcLateButton = 'Should I test?';

/// Kept for revert: the label that promised a how-to and opened the chat.
const String kTtcHowToTest = 'How to take a test';

/// The kind line on the first day of a new period.
const String kTtcPeriodCameLine =
    "Your period came. If you were hoping this month, that's hard.";

/// The link under it, to the "Your period came" read.
const String kTtcPeriodCameLink = "What it does and doesn't mean";
const String kTtcPeriodCameReadId = 'ttc_read_period_came';

/// The envelope's name for screen readers.
const String kTtcMessagesLabel = 'Messages';

/// The waiting-days card on the daily rail.
const String kTtcShouldTestEyebrow = 'The waiting days';
const String kTtcShouldTestValue = 'Should I test?';
const String kTtcShouldTestCaption = "We'll work it out together";

/// Under the recommended reads.
const String kTtcSeeEverything = 'See everything';

/// The two one-tap buttons beside "Check symptoms".
const String kTtcQuickSex = 'Sex';
const String kTtcQuickTest = 'Test';

/// Where "Test" opens the logger: the ovulation test card, which sits directly
/// above the pregnancy test card, so both choices are in view together.
const String kTtcTestGroupToOpen = 'ovulation_test';

/// The check card.
String ttcCheckTitle(int months) => months <= 6
    ? "It's been about six months"
    : "It's been about a year";

String ttcCheckBody(int months) => months <= 6
    ? 'At 35 and over, or when cycles vary a lot, this is the point where '
        'guidelines suggest a simple check for both of you. Most causes are '
        'findable, and many are easy to treat.'
    : "That's the point where guidelines suggest a simple check for both of "
        'you. Most causes are findable, and many are easy to treat.';

const String kTtcCheckWhat = 'What a first check involves';
const String kTtcCheckNotNow = 'Not now';
const String kTtcCheckReadId = 'ttc_read_ivf_workup';

/// The check card's eyebrow (H7).
const String kTtcCheckEyebrow = 'For both of you';

/// The course card for someone new.
const String kTtc101Eyebrow = 'New here?';
const String kTtc101Title = 'Start with Trying to conceive 101';
const String kTtc101AllSteps = 'All steps';

/// After a period is logged.
const String kTtcPeriodLoggedNote =
    'Your period is logged. If this month was hard, we can talk it through.';
const String kTtcTalkItThrough = 'Talk it through';

// =============================================================================
//  Opening things
// =============================================================================

/// The first surface of [ids] that resolves, or null. A read still being
/// written resolves to null, and the next best place opens instead.
String? ttcFirstSurface(List<String> ids) {
  for (final id in ids) {
    if (ttcScreenForSurface(id) != null) return id;
  }
  return null;
}

void _open(BuildContext context, List<String> ids) {
  final id = ttcFirstSurface(ids);
  if (id != null) openTtcSurface(context, id);
}

// =============================================================================
//  The hero's note: a button on a late day, a kind line on period day 1
// =============================================================================

/// "Should I test?", under the hero when she is late: the one way into the
/// chat on a late day (H1, H2). The filled ink stays because it is the
/// hero's single primary. Kept for revert: the label [kTtcHowToTest], an
/// `InkWell` with no press, 11pt vertical padding (about 40pt tall).
class TtcHowToTestButton extends StatelessWidget {
  const TtcHowToTestButton({super.key, required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: kTtcLateButton,
        child: PvPress(
          child: Material(
            color: p.ink1,
            shape: const StadiumBorder(),
            child: InkWell(
              key: const ValueKey('ttc_home_how_to_test'),
              customBorder: const StadiumBorder(),
              onTap: () {
                pvCommitFeedback();
                _open(context, const ['ttc_chat/should_test']);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.chat_bubble_outline_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(kTtcLateButton,
                        style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

/// The kind line on the first day of a new period, with a way to the read.
class TtcPeriodCameLine extends StatelessWidget {
  const TtcPeriodCameLine({super.key, required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) => InkWell(
        key: const ValueKey('ttc_home_period_came'),
        onTap: () => _open(context, const [
          '$kTtcReadPrefix$kTtcPeriodCameReadId',
          'ttc_chat/period_came',
        ]),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            color: p.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            // H9: ink, not violet. Was color: p.action.
            Icon(Icons.favorite_border_rounded, size: 18, color: p.ink2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kTtcPeriodCameLine,
                        style: pvManrope(
                            fontSize: 13, height: 1.4, color: p.ink1)),
                    const SizedBox(height: 3),
                    Text(kTtcPeriodCameLink,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: p.action)),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
          ]),
        ),
      );
}

// =============================================================================
//  The envelope
// =============================================================================

/// The messages entry in the header: a line envelope, and a dot when
/// something is unread. Never a number: a count of unread messages is a small
/// pressure on a screen that is meant to take pressure away.
class TtcMessagesButton extends StatelessWidget {
  const TtcMessagesButton(
      {super.key, required this.p, required this.unread, required this.onTap});

  final V2Palette p;
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: unread > 0 ? '$kTtcMessagesLabel, new' : kTtcMessagesLabel,
        // H6: a 44pt target around the 38pt disc.
        child: InkWell(
          key: const ValueKey('ttc_home_messages'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: SizedBox(
            width: 38,
            height: 38,
            child: Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.surface.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: p.line),
                ),
                child: Icon(Icons.mail_outline_rounded, size: 18, color: p.ink2),
              ),
              if (unread > 0)
                Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    key: const ValueKey('ttc_home_messages_dot'),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: ttcCoral,
                      shape: BoxShape.circle,
                      border: Border.all(color: p.surface, width: 1.5),
                    ),
                  ),
                ),
            ]),
          ),
            ),
          ),
        ),
      );
}

// =============================================================================
//  The check card
// =============================================================================

/// "It's been about a year": one calm note, two ways on. Never a diagnosis
/// and never a chance: it says what guidelines suggest and what a check is.
///
/// ⚠️ A TIP, NOT A CARD (H7). It was a white card with a violet icon holding
/// a paragraph; a card is for an object, and this is a sentence with two ways
/// on. So it takes the tip's form: a left rule, the eyebrow, the title, the
/// body, the two links, on the page. Kept for revert: a `Container` with
/// `p.surface`, radius 20, a hairline, and `medical_information_outlined` in
/// `p.action` beside the title.
class TtcCheckCard extends StatelessWidget {
  const TtcCheckCard({super.key, required this.p, required this.months});

  final V2Palette p;
  final int months;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('ttc_home_check_card'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 2, 0, 0),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: p.ink1, width: 1.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(kTtcCheckEyebrow.toUpperCase(),
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: p.action)),
          const SizedBox(height: 6),
          Text(ttcCheckTitle(months),
              style: pvFraunces(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  letterSpacing: -0.3,
                  color: p.ink1)),
          const SizedBox(height: 6),
          Text(ttcCheckBody(months),
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 4),
          Wrap(spacing: 4, runSpacing: 0, children: [
            TextButton(
              key: const ValueKey('ttc_home_check_what'),
              onPressed: () {
                pvCommitFeedback();
                _open(context, const [
                  '$kTtcReadPrefix$kTtcCheckReadId',
                  'ttc_fertility_help',
                ]);
              },
              style: TextButton.styleFrom(
                  foregroundColor: p.action,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 0)),
              child: Text(kTtcCheckWhat,
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: p.action)),
            ),
            TextButton(
              key: const ValueKey('ttc_home_check_not_now'),
              onPressed: TtcHomePrefs.instance.dismissCheck,
              style: TextButton.styleFrom(
                  foregroundColor: p.ink2,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 10)),
              child: Text(kTtcCheckNotNow,
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink2)),
            ),
          ]),
        ]),
      );
}

// =============================================================================
//  The course card
// =============================================================================

/// "New here? Start with Trying to conceive 101", with the next step named.
/// No count and no progress bar: it steps aside once she has opened two.
class Ttc101Card extends StatelessWidget {
  const Ttc101Card({super.key, required this.p, required this.onAllSteps});

  final V2Palette p;
  final VoidCallback onAllSteps;

  @override
  Widget build(BuildContext context) {
    final prefs = TtcHomePrefs.instance;
    String? nextId;
    for (final id in kTtc101ReadIds) {
      if (ttcReadById(id) == null) continue;
      nextId ??= id;
      if (!prefs.opened(id)) {
        nextId = id;
        break;
      }
    }
    final next = nextId == null ? null : ttcReadById(nextId);

    // H8: ONE tap target at radius 16, with a press; "All steps" is a row
    // of its own under the card rather than a button inside it. Kept for
    // revert: an `InkWell` card at radius 20 with the "All steps"
    // `TextButton` nested inside, and a 10.5 eyebrow.
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PvPress(
        child: Material(
          color: p.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: p.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const ValueKey('ttc_home_101_card'),
            onTap: () {
              pvCommitFeedback();
              if (next == null) {
                onAllSteps();
                return;
              }
              prefs.markOpened(next.id);
              openTtcSurface(context, '$kTtcReadPrefix${next.id}');
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kTtc101Eyebrow.toUpperCase(),
                        style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: p.action)),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(
                        child: Text(kTtc101Title,
                            style: pvFraunces(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                letterSpacing: -0.3,
                                color: p.ink1)),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 20, color: p.ink3),
                    ]),
                    if (next != null) ...[
                      const SizedBox(height: 4),
                      Text('Next: ${next.title.en}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 13, height: 1.4, color: p.ink2)),
                    ],
                  ]),
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          key: const ValueKey('ttc_home_101_all'),
          onPressed: onAllSteps,
          style: TextButton.styleFrom(
              foregroundColor: p.action,
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 8)),
          child: Text(kTtc101AllSteps,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: p.action)),
        ),
      ),
    ]);
  }
}

// =============================================================================
//  After a period is logged
// =============================================================================

/// "Talk it through", offered once a new period is logged.
///
/// ⚠️ THE NAVIGATOR AND MESSENGER ARE PASSED IN, NOT A CONTEXT. The cycle
/// companion's log sheet pops itself before this shows, so its context is
/// gone by the time she taps; the states outlive it.
///
/// [start] and [starts] decide whether to offer at all: only for a period
/// that started today or yesterday, and never for the very first one she
/// logs (the same rule as the "period came" message).
void showTtcPeriodCameNudge({
  required NavigatorState navigator,
  required ScaffoldMessengerState messenger,
  required DateTime start,
  required List<DateTime> starts,
  DateTime? now,
}) {
  if (!ttcShouldOfferPeriodTalk(start: start, starts: starts, now: now)) {
    return;
  }
  // H10: the house notice (a white lifted card, an ink pill, and a timeout
  // that always fires), from the navigator's context, which outlives the
  // log sheet that called this. The messenger stays in the signature so no
  // caller changes. Kept for revert: a dark grey `SnackBar` (0xFF2F2C30) with
  // a lavender `SnackBarAction`, floating 86pt up, `persist: false`, 7s.
  pvSnack(
    navigator.context,
    kTtcPeriodLoggedNote,
    action: kTtcTalkItThrough,
    onAction: () {
      final screen = ttcScreenForSurface('ttc_chat/period_came');
      if (screen == null) return;
      navigator.push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc_chat/period_came'),
        builder: (_) => screen,
      ));
    },
  );
}

/// Whether a just-logged [start] earns the "Talk it through" offer.
bool ttcShouldOfferPeriodTalk({
  required DateTime start,
  required List<DateTime> starts,
  DateTime? now,
}) {
  DateTime d(DateTime x) => DateTime(x.year, x.month, x.day);
  final all = [...starts.map(d)]..sort();
  if (all.length < 2 || all.last != d(start)) return false;
  final today = d(now ?? DateTime.now());
  return !d(start).isBefore(today.subtract(const Duration(days: 1)));
}

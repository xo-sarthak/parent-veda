// =============================================================================
//  A treatment round, on screen: start, plan, result, check-in, plan changed
// -----------------------------------------------------------------------------
//  Built 2026-09-26 for docs/TTC-TREATMENT-FLOW.md (B3). The round's model and
//  rules are in `lib/ttc/ttc_treatment_store.dart` and
//  `lib/ttc/ttc_treatment_round.dart`; the words in `ttc_round_strings.dart`.
//
//  Routes (load-bearing: `global_ask_fab.dart` reads route names):
//    ttc/treatment         the treatment screen (`ttc_treatment_screen.dart`)
//    ttc/treatment/start   the start flow, three short screens
//    ttc/treatment/result  "How did the test go?"
//    ttc/treatment/check_in, ttc/treatment/plan_changed   the two sheets
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE USER'S RULE FOR EVERYTHING HERE (2026-09-26): NOTHING CHANGES
//  SILENTLY, AND NOTHING IS AMBIGUOUS
//  ---------------------------------------------------------------------------
//  * Every choice says exactly what it does, in its own label ("Paused: stop
//    following it for now, keep my dates"), two to three to a sheet.
//  * Anything that changes the mode or closes a round is confirmed first by a
//    dialog that restates the consequence, then confirmed after with a card
//    that offers Undo. Closing is reversible for 7 days; nothing is deleted.
//  * The start flow's last screen says, before anything is saved, from which
//    date the home will follow the round and what pauses.
//  * Dates are checked, never refused: a date out of order with another step,
//    or far from today, asks her to check it against her clinic's plan.
//  * Date-only keys everywhere but the trigger (which keeps its minute), 360dp
//    without overflow (long labels wrap, rows never clip), Semantics on every
//    control, and nothing heavy in build.
//
//  ---------------------------------------------------------------------------
//  Mobbin references (2026-09-26), borrowed shapes only, never their words:
//    * Apple Health "Adding a medication": one question per screen, then a
//      "Review details" screen before saving ("Starts Today")
//      https://mobbin.com/flows/e0ab1cce-e452-4b0b-a7d7-521168695e75
//      and its dismissible info banner with an action link, for the home's
//      one-time announcements
//      https://mobbin.com/flows/61a17fd3-3918-40b6-bfcb-6b12927d5244
//    * Bumble "Your report": a vertical timeline, done steps ticked with a date
//      eyebrow, the steps ahead as hollow circles. The model for "Here's how
//      your round usually goes"
//      https://mobbin.com/screens/09426d05-9e3c-4a74-b206-da7d04e07ba4
//    * Luma scanner options and Jomo "Start blocking": a sheet of options,
//      each a bold name and one line saying what it does. The check-in, the
//      result and "the plan changed"
//      https://mobbin.com/screens/6a894c30-4039-4fef-b440-0e537b4ea7d4
//      https://mobbin.com/screens/bb3bf810-f3b1-4bd6-9ae7-6821b20a0e67
//    * Bumble "Delete your date details?" and Lloyds "Before you delete": a
//      question, the consequence in one plain line, then the action and a way
//      to keep it
//      https://mobbin.com/screens/6c423120-f512-489a-abe2-8bebce1c5b49
//      https://mobbin.com/screens/be1d4ab6-56a2-4b73-b38a-d3adff4a5cef
//    * Shop "We'll show you less like this / Undo": the undo in place, right
//      after the action
//      https://mobbin.com/screens/26edeaa3-1454-4c37-948a-bd6c8eb364ba
//  Rendered in this app's own system: white ground, ink pills, Newsreader and
//  Manrope (`pv_fonts.dart`), line icons, the TTC tool shell.
//
//  ---------------------------------------------------------------------------
//  Added 2026-09-26 (B7, B8):
//    * `TtcIvfRoundPanel`, the top of the IVF & IUI door: "Your round" while
//      one is open, "Between rounds" after one closes, "Positive test" with
//      the way to Pregnancy, and "Starting treatment?" when there is none.
//      Mobbin: Fresha's upcoming appointment card, a step and its date over
//      two pills (https://mobbin.com/screens/95504603-982b-41db-81ab-e8b7d9216501)
//      and Zocdoc's "Up next" (https://mobbin.com/screens/14e7f095-1b94-4e03-96e3-1b3fec5c9aa5).
//    * `TtcRoundPregnancyScreen` (route ttc/treatment/to_pregnancy): the
//      announcement BEFORE she moves to Pregnancy, with the due date and what
//      it counts from, two or three labelled choices, then a confirmation
//      that restates the consequence. The transition screen after it keeps
//      its Undo. Mobbin: Oura's "Let's calculate your due date" with "I
//      already know my due date" as the second way
//      (https://mobbin.com/screens/84f36267-4d1f-4d10-81fc-029d97cabeff) and
//      Monzo's switch-date statement, the date and what happens, before Next
//      (https://mobbin.com/screens/935b3645-e19d-4ee8-a32e-d104ab6526ec).
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/pregnancy_controller.dart' show DueDateSource;
import '../../theme/pv_fonts.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_reads_data.dart' show ttcReadById;
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_transition.dart';
import '../../ttc/ttc_treatment_round.dart';
import '../../ttc/ttc_treatment_store.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import 'ttc_common.dart';
import 'ttc_focus_screen.dart' show openTtcArticle;
import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
import 'ttc_round_strings.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_transition_screen.dart' show TtcTransitionScreen;
import 'ttc_treatment_screen.dart' show TtcTreatmentScreen, openTtcTreatment;

// =============================================================================
//  Openers
// =============================================================================

void openTtcTreatmentStart(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const TtcTreatmentStartScreen(),
      settings: const RouteSettings(name: 'ttc/treatment/start'),
    ),
  );
}

/// The announcement before moving to Pregnancy after a positive test (B8).
void openTtcRoundPregnancy(BuildContext context, {bool replace = false}) {
  final route = MaterialPageRoute<void>(
    builder: (_) => const TtcRoundPregnancyScreen(),
    settings: const RouteSettings(name: 'ttc/treatment/to_pregnancy'),
  );
  final nav = Navigator.of(context);
  replace ? nav.pushReplacement(route) : nav.push(route);
}

void openTtcTreatmentResult(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const TtcTreatmentResultScreen(),
      settings: const RouteSettings(name: 'ttc/treatment/result'),
    ),
  );
}

// =============================================================================
//  Small shared pieces
// =============================================================================

/// A full-width pill: ink when primary, a hairline outline when not.
class TtcRoundButton extends StatelessWidget {
  const TtcRoundButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      // excludeSemantics drops the child's tap action, so the node
      // carries it (accessibility sweep, TTC launch walk, 2026-09-27).
      onTap: onTap,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Material(
          color: primary ? ttcTitleInk : Colors.white,
          shape: StadiumBorder(
            side: primary
                ? BorderSide.none
                : const BorderSide(color: ttcLine, width: 1.5),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: primary ? Colors.white : ttcTitleInk,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One labelled choice: a bold name and one line saying exactly what it does.
///
/// ⚠️ TWO JOBS, TWO LOOKS (2026-09-29, the user on build 19: "I cannot
/// unselect them if I have selected them; I have to go back"). Most of these
/// are ACTIONS in a sheet (a tap does the thing and the sheet closes), and a
/// chevron says so. On the start flow's first screen they are ANSWERS to a
/// question, and a chevron there read as "this opens something", while the
/// chosen one could not be un-chosen. [choice] draws the answer look every
/// single-choice list on Mobbin uses: a hollow ring on every option and a
/// filled one on the chosen, so both states are visible before a tap (Public,
/// https://mobbin.com/screens/6e2ff81b-c125-46c3-a145-334e153c4384; Meetup,
/// https://mobbin.com/screens/7ea17c2e-b540-4734-9de8-63f40f88ec01; Cash App,
/// https://mobbin.com/screens/cd83927e-b861-4bd7-a311-79525f04e39f). A second
/// tap on the chosen one clears it, which the caller does; this only says so
/// to a screen reader.
class TtcRoundOption extends StatelessWidget {
  const TtcRoundOption({
    super.key,
    required this.title,
    required this.line,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.choice = false,
  });

  final String title;
  final String line;
  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;

  /// An answer to a single-choice question rather than an action: a ring on
  /// every option, filled on the chosen one, and tapping the chosen one again
  /// clears it.
  final bool choice;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: choice,
      hint: choice && selected ? 'Tap again to clear this answer' : null,
      label: '$title. $line',
      // excludeSemantics drops the child's tap action, so the node
      // carries it (accessibility sweep, TTC launch walk, 2026-09-27).
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? ttcTitleInk : ttcLine,
            width: selected ? 1.8 : 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: ttcTitleInk),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ttcTitleInk,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        line,
                        style: pvManrope(
                          fontSize: 12.5,
                          height: 1.4,
                          color: ttcSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // An answer wears a ring either way; an action keeps its
                // chevron (see the class note). Kept for revert: the Icon
                // below alone, a chevron until chosen.
                if (choice)
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 22,
                    color: selected ? ttcInk : ttcMuted,
                  )
                else
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.chevron_right_rounded,
                    size: 20,
                    color: selected ? ttcTitleInk : ttcMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _gap(double h) => SizedBox(height: h);

/// A white date picker, the stage's own (see `logTtcPeriod`).
Widget _whitePicker(BuildContext context, Widget? child) => Theme(
  data: Theme.of(context).copyWith(
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: Colors.white,
      headerForegroundColor: ttcTitleInk,
      dayForegroundColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.disabled)) {
          return ttcMuted.withValues(alpha: 0.55);
        }
        return s.contains(WidgetState.selected) ? Colors.white : ttcInk;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? ttcTitleInk : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  ),
  child: child!,
);

/// Picks a date for [step] of [round] (null [step]: a scan), with the time
/// for the trigger, and asks her to check a date that looks out of order or
/// far away. Returns null when she backs out. Never refuses a date: her
/// clinic's plan wins.
Future<DateTime?> ttcPickRoundDate(
  BuildContext context, {
  required TtcTreatmentCycle round,
  required TtcTreatmentStep? step,
  String? help,
}) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final first = today.subtract(const Duration(days: 365));
  final last = today.add(const Duration(days: 400));
  var initial = step == null ? today : (round[step] ?? today);
  if (initial.isBefore(first)) initial = first;
  if (initial.isAfter(last)) initial = today;
  final day = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first,
    lastDate: last,
    helpText: help,
    fieldHintText: 'dd/mm/yyyy',
    builder: _whitePicker,
  );
  if (day == null || !context.mounted) return null;
  var value = DateTime(day.year, day.month, day.day);
  if (step != null && step.needsTime) {
    // ⚠️ A CLOSED TIME PICKER NEVER INVENTS A TIME (tools pass, 2026-09-27).
    // This used to save `time?.hour ?? 21`, so closing the clock saved 9:00pm
    // without a word and armed reminders for 5:00pm and 8:45pm on the one
    // evening the hour is exact. Kept for revert:
    //   final time = await showTimePicker(..., helpText: 'What time exactly?');
    //   value = DateTime(day.year, day.month, day.day,
    //       time?.hour ?? 21, time?.minute ?? 0);
    final timed = await ttcPickTriggerTime(context, day, prev: round[step]);
    if (timed == null || !context.mounted) return null;
    value = timed;
  }
  // A scan has no order to check, only distance, which the review step shares.
  final problem = ttcTreatmentDateProblem(
    round,
    step ?? TtcTreatmentStep.reviewAppointment,
    value,
  );
  if (problem == null) return value;
  final ok = await showDialog<bool>(
    context: context,
    routeSettings: const RouteSettings(name: 'ttc/treatment/date_check'),
    builder: (ctx) => _ConfirmDialog(
      title: kTtcDateCheckTitle,
      body: ttcDateProblemText(problem, round.kind),
      yes: kTtcDateUseIt,
      no: kTtcDatePickAgain,
    ),
  );
  if (!context.mounted) return null;
  if (ok == true) return value;
  if (ok == false) {
    return ttcPickRoundDate(context, round: round, step: step, help: help);
  }
  return null;
}

/// The trigger injection's time on [day], asked until she gives one or says
/// not to save.
///
/// ⚠️ WHY THE ENTRY IS CANCELLED RATHER THAN KEPT WITHOUT A TIME. The round
/// stores one `DateTime` per step and the reminders are armed from it, so a
/// date with no time would have to be stored as midnight, which arms an 8:00pm
/// reminder the night before. A "time not set" state would need a new saved
/// field in the store and every reader of it (calendar, home, reminders). So
/// a dismissed clock asks once, in words, and then either reopens the clock or
/// saves nothing and says so. Trade-off: one extra dialog for a mis-tap; what
/// it buys is that no reminder ever fires at a time she did not choose.
Future<DateTime?> ttcPickTriggerTime(
  BuildContext context,
  DateTime day, {
  DateTime? prev,
}) async {
  while (true) {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(prev ?? DateTime(0, 1, 1, 21, 0)),
      helpText: kTtcTriggerTimeHelp,
    );
    if (!context.mounted) return null;
    if (time != null) {
      return DateTime(day.year, day.month, day.day, time.hour, time.minute);
    }
    final again = await showDialog<bool>(
      context: context,
      routeSettings: const RouteSettings(name: 'ttc/treatment/trigger_time'),
      builder: (_) => _ConfirmDialog(
        title: kTtcTriggerNoTimeTitle,
        body: prev == null ? kTtcTriggerNoTimeBody : kTtcTriggerNoTimeKeepBody,
        yes: kTtcTriggerNoTimeAdd,
        no: prev == null ? kTtcTriggerNoTimeSkip : kTtcTriggerNoTimeKeep,
      ),
    );
    if (!context.mounted) return null;
    if (again == true) continue;
    pvSnack(
      context,
      prev == null ? kTtcTriggerNotSaved : kTtcTriggerUnchanged,
      lift: 24,
    );
    return null;
  }
}

/// The trigger's time picker and its "no time" check (tools pass, 2026-09-27).
const String kTtcTriggerTimeHelp = 'What time is your trigger injection?';
const String kTtcTriggerNoTimeTitle = 'Add the time too?';
const String kTtcTriggerNoTimeBody =
    'Your clinic gives the trigger injection an exact time. Your reminders go '
    "off 4 hours and 15 minutes before it, so we won't save the date without "
    'the time.';
const String kTtcTriggerNoTimeKeepBody =
    'Your clinic gives the trigger injection an exact time, and your reminders '
    'are set from it. Without a new time, your trigger stays as it was.';
const String kTtcTriggerNoTimeAdd = 'Add the time';
// Kept for revert (2026-09-28, explicit labels): "Don't save it"
const String kTtcTriggerNoTimeSkip = "Don't save the date";
// Kept for revert (2026-09-28, explicit labels): 'Keep it as it was'
const String kTtcTriggerNoTimeKeep = 'Keep the trigger as it was';
const String kTtcTriggerNotSaved =
    'Trigger date not saved. Add it when you have the time.';
const String kTtcTriggerUnchanged = 'Your trigger time is unchanged.';

/// "Date removed", with Undo that puts [was] back (tools pass, 2026-09-27).
/// A date copied off a clinic printout is precious, and the remove link sits
/// right beside the one she taps to change it.
void ttcRoundDateRemoved(
  BuildContext context,
  String label,
  VoidCallback undo,
) {
  pvSnack(
    context,
    '$label removed.',
    icon: Icons.check_rounded,
    lift: 24,
    action: kTtcRoundUndoCta,
    onAction: undo,
  );
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.yes,
    required this.no,
  });

  final String title, body, yes, no;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: pvFraunces(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: ttcTitleInk,
              ),
            ),
            _gap(10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: ttcSoft),
            ),
            _gap(18),
            TtcRoundButton(
              key: const ValueKey('ttc_round_confirm_yes'),
              label: yes,
              onTap: () => Navigator.of(context).pop(true),
            ),
            _gap(8),
            TtcRoundButton(
              key: const ValueKey('ttc_round_confirm_no'),
              label: no,
              primary: false,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

/// The round's own confirm, for the treatment screen too (2026-09-27, the
/// tool rebuild): "Remove these dates" asked in an old grey `AlertDialog`
/// with a violet button, a second look on the same screen as this one.
Future<bool> ttcRoundConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String yes,
  required String no,
  String route = 'ttc/treatment/confirm',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    routeSettings: RouteSettings(name: route),
    builder: (_) => _ConfirmDialog(title: title, body: body, yes: yes, no: no),
  );
  return ok == true;
}

/// Asks, restating the consequence, then closes the round with [how] and
/// shows the closed card with Undo. Returns true when it closed.
Future<bool> ttcConfirmCloseRound(
  BuildContext context,
  TtcRoundOutcome how,
) async {
  final (title, body, yes) = ttcConfirmClose(how);
  final ok = await showDialog<bool>(
    context: context,
    routeSettings: const RouteSettings(name: 'ttc/treatment/confirm_close'),
    builder: (_) =>
        _ConfirmDialog(title: title, body: body, yes: yes, no: kTtcConfirmKeep),
  );
  if (ok != true || !context.mounted) return false;
  final store = TtcTreatmentStore.instance;
  store.closeRound(how);
  pvSnack(
    context,
    ttcClosedLine(how),
    icon: Icons.check_rounded,
    lift: 24,
    action: kTtcRoundUndoCta,
    onAction: store.undoClose,
  );
  return true;
}

// =============================================================================
//  The start flow: kind, first date(s), what we'll show
// =============================================================================

class TtcTreatmentStartScreen extends StatefulWidget {
  const TtcTreatmentStartScreen({super.key});

  @override
  State<TtcTreatmentStartScreen> createState() =>
      _TtcTreatmentStartScreenState();
}

class _TtcTreatmentStartScreenState extends State<TtcTreatmentStartScreen> {
  int _page = 0;
  TtcRoundKind? _kind;
  final Map<TtcTreatmentStep, DateTime> _dates = {};
  final List<DateTime> _scans = [];
  final TextEditingController _clinic = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = TtcTreatmentStore.instance.cycle;
    // A legacy round is adopted: its kind is asked, its dates are kept.
    // The next round is usually at the same clinic, so an open or just
    // closed round's name is offered too (2026-09-27, the tool rebuild).
    // Kept for revert: `if (c.kind == null && c.clinic.isNotEmpty) ...`.
    final last = TtcTreatmentStore.instance.lastClosed;
    if (c.clinic.isNotEmpty) {
      _clinic.text = c.clinic;
    } else if (last != null && last.clinic.isNotEmpty) {
      _clinic.text = last.clinic;
    }
  }

  @override
  void dispose() {
    _clinic.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  //  ⚠️ HER ANSWERS ARE NEVER THROWN AWAY BY A TAP (2026-09-29, build 19)
  // ---------------------------------------------------------------------------
  //  Choosing another kind used to CLEAR every date she had added, so
  //  IVF → IUI → back to IVF lost the baseline scan she had typed off her
  //  clinic's sheet, and "I'll add the dates later" cleared them too. Now the
  //  dates are one pool for the whole flow, keyed by step, and only the rows
  //  of the kind she ends on are shown, checked and saved ([_kindDates],
  //  [_kindScans]). Trade-off: a date for a step the chosen kind does not
  //  open with sits unseen in memory until she leaves the screen, and is never
  //  saved. What it buys: going back, changing her mind and coming back again
  //  keeps every answer, which is what a back step is supposed to promise.
  //  Kept for revert: `_draft` and `_save` read `_dates` and `_scans` whole.

  /// The dates she added for a step the chosen kind opens with.
  Map<TtcTreatmentStep, DateTime> get _kindDates {
    final k = _kind;
    if (k == null) return const {};
    return {
      for (final r in ttcRoundOpeningRows(k))
        if (r.step case final s? when _dates[s] != null) s: _dates[s]!,
    };
  }

  /// Her first scan, when the chosen kind opens with a scan.
  List<DateTime> get _kindScans {
    final k = _kind;
    if (k == null) return const [];
    return ttcRoundOpeningRows(k).any((r) => r.step == null)
        ? _scans
        : const [];
  }

  bool get _hasKindDates => _kindDates.isNotEmpty || _kindScans.isNotEmpty;

  /// A tap on a kind: chooses it, or clears it when it is already chosen.
  /// Nothing she added is dropped either way (see the note above).
  void _tapKind(TtcRoundKind k) => setState(() {
    _kind = _kind == k ? null : k;
  });

  /// What the round will look like if she saves now, for the statement.
  TtcTreatmentCycle get _draft {
    final c = TtcTreatmentStore.instance.cycle;
    final keep = c.kind == null ? c : const TtcTreatmentCycle(dates: {});
    var r = TtcTreatmentCycle(
      // Kept for revert (2026-09-29): dates: {...keep.dates, ..._dates},
      dates: {...keep.dates, ..._kindDates},
      kind: _kind,
      scans: keep.scans,
    );
    // Kept for revert (2026-09-29): for (final s in _scans) {
    for (final s in _kindScans) {
      r = r.withScanAdded(s);
    }
    return r;
  }

  Future<void> _pick(TtcRoundRow row) async {
    final picked = await ttcPickRoundDate(
      context,
      round: _draft,
      step: row.step,
      help: row.step == null
          ? ttcScanLabel(_kind)
          : ttcStepLabel(row.step!, _kind),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (row.step == null) {
        _scans
          ..clear()
          ..add(DateTime(picked.year, picked.month, picked.day));
      } else {
        _dates[row.step!] = picked;
      }
    });
  }

  void _save() {
    final kind = _kind;
    if (kind == null) return;
    TtcStore.instance.setPath(ttcPathForKind(kind));
    TtcTreatmentStore.instance.startRound(
      kind: kind,
      // Only the chosen kind's dates (2026-09-29, see `_kindDates`). Kept for
      // revert: dates: Map.of(_dates), scans: List.of(_scans),
      dates: Map.of(_kindDates),
      scans: List.of(_kindScans),
      clinic: _clinic.text,
    );
    // Straight on to the plan: "Here's how your round usually goes".
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const TtcTreatmentScreen(),
        settings: const RouteSettings(name: 'ttc/treatment'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = TtcTreatmentStore.instance;
    if (!store.isLoaded) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: ttcTitleInk)),
      );
    }
    final (title, intro) = switch (_page) {
      0 => (kTtcStartKindTitle, kTtcStartKindBody),
      1 => (kTtcStartDateTitle, kTtcStartDateBody),
      _ => (kTtcStartReviewTitle, null),
    };
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _page > 0) setState(() => _page--);
      },
      child: TtcToolScaffold(
        key: ValueKey('ttc_start_page_$_page'),
        hue: kIvfHue,
        variant: 1 + _page,
        // An X on the first screen, an arrow after it (2026-09-29, the user:
        // "multi-step flows should be getting a back arrow"). The arrow pops,
        // and the PopScope above turns that pop into one step back, so the
        // button and the phone's back gesture are one path.
        leading: _page == 0 ? TtcToolLeading.close : TtcToolLeading.back,
        eyebrow: 'Start a round · ${_page + 1} of 3',
        title: title,
        intro: intro,
        children: [
          _gap(22),
          ...switch (_page) {
            0 => _kindPage(store),
            1 => _datePage(),
            _ => _reviewPage(),
          },
          _gap(28),
        ],
      ),
    );
  }

  List<Widget> _kindPage(TtcTreatmentStore store) {
    final c = store.cycle;
    return [
      if (!c.isEmpty && c.kind == null) ...[
        ttcToolPad(_Note(kTtcStartKeepsLegacy)),
        _gap(14),
      ] else if (!c.isEmpty && !c.isClosed) ...[
        ttcToolPad(_Note(kTtcStartClosesCurrent)),
        _gap(14),
      ],
      for (final k in const [
        TtcRoundKind.ivfFresh,
        TtcRoundKind.ivfFreezeAll,
        TtcRoundKind.fetMedicated,
        TtcRoundKind.fetNatural,
        TtcRoundKind.iui,
        TtcRoundKind.ovulationInduction,
        TtcRoundKind.notSure,
      ]) ...[
        ttcToolPad(
          TtcRoundOption(
            key: ValueKey('ttc_start_kind_${k.name}'),
            title: ttcRoundKindName(k),
            line: ttcRoundKindNote(k),
            selected: _kind == k,
            choice: true,
            // Tapping the chosen kind again clears it, in place (2026-09-29).
            // Kept for revert:
            //   onTap: () => setState(() {
            //     if (_kind != k) { _dates.clear(); _scans.clear(); }
            //     _kind = k;
            //   }),
            onTap: () => _tapKind(k),
          ),
        ),
        _gap(10),
      ],
      // Says how to undo a choice, once there is one to undo.
      if (_kind != null)
        ttcToolPad(
          Text(
            kTtcStartKindClearHint,
            key: const ValueKey('ttc_start_kind_clear_hint'),
            style: pvManrope(fontSize: 12.5, height: 1.4, color: ttcSoft),
          ),
        ),
      _gap(10),
      ttcToolPad(
        TtcRoundButton(
          key: const ValueKey('ttc_start_next'),
          // Kept for revert (2026-09-28): label: 'Continue',
          label: 'Next: add your dates',
          onTap: _kind == null ? null : () => setState(() => _page = 1),
        ),
      ),
      // A greyed button says nothing on its own: why it waits, in words.
      if (_kind == null) ...[
        _gap(8),
        ttcToolPad(
          Text(
            kTtcStartKindNeeded,
            key: const ValueKey('ttc_start_next_why'),
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 12.5, height: 1.4, color: ttcSoft),
          ),
        ),
      ],
    ];
  }

  List<Widget> _datePage() {
    final kind = _kind!;
    final rows = ttcRoundOpeningRows(kind);
    return [
      for (final row in rows) ...[
        ttcToolPad(
          TtcRoundDateRow(
            key: ValueKey('ttc_start_date_${row.step?.name ?? 'scan'}'),
            label: row.step == null
                ? 'First ${ttcScanLabel(kind).toLowerCase()}'
                : ttcStepLabel(row.step!, kind),
            line: ttcRowLine(row, kind),
            value: row.step == null
                ? (_scans.isEmpty ? null : _scans.first)
                : _dates[row.step!],
            withTime: row.step?.needsTime ?? false,
            onTap: () => _pick(row),
            // Undo after a clear (tools pass, 2026-09-27). Kept for revert: the
            // clear was the setState below with no snack.
            onClear: () {
              final wasScans = List.of(_scans);
              final was = row.step == null ? null : _dates[row.step!];
              setState(() {
                if (row.step == null) {
                  _scans.clear();
                } else {
                  _dates.remove(row.step);
                }
              });
              ttcRoundDateRemoved(
                context,
                row.step == null
                    ? ttcScanLabel(kind)
                    : ttcStepLabel(row.step!, kind),
                () {
                  if (!mounted) return;
                  setState(() {
                    if (row.step == null) {
                      _scans
                        ..clear()
                        ..addAll(wasScans);
                    } else if (was != null) {
                      _dates[row.step!] = was;
                    }
                  });
                },
              );
            },
          ),
        ),
        _gap(10),
      ],
      _gap(14),
      ttcToolPad(
        TtcRoundButton(
          key: const ValueKey('ttc_start_next'),
          // Kept for revert (2026-09-28): label: 'Continue',
          label: 'Next: see your plan',
          // Kept for revert (2026-09-29): _dates.isEmpty && _scans.isEmpty
          onTap: !_hasKindDates ? null : () => setState(() => _page = 2),
        ),
      ),
      // ⚠️ "LATER" NO LONGER WIPES WHAT SHE ADDED (2026-09-29). It cleared
      // every date and moved on, so a tap on it after adding a date, or a
      // step back from the next screen and on again, lost the date. It shows
      // only while there is no date, when it is the one way on, and it says
      // why Next waits. With a date added, Next is the way on and each date
      // has its own remove. Kept for revert: the button always shown, with
      //   onTap: () => setState(() { _dates.clear(); _scans.clear(); _page = 2; }),
      if (!_hasKindDates) ...[
        _gap(8),
        ttcToolPad(
          TtcRoundButton(
            key: const ValueKey('ttc_start_later'),
            label: kTtcStartLater,
            primary: false,
            onTap: () => setState(() => _page = 2),
          ),
        ),
        _gap(8),
        ttcToolPad(
          Text(
            kTtcStartDateNeeded,
            key: const ValueKey('ttc_start_next_why'),
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 12.5, height: 1.4, color: ttcSoft),
          ),
        ),
      ],
      // ⚠️ A BACK STEP THAT SAYS WHERE IT GOES (2026-09-29). The only way to
      // the first screen was the shell's round X, which reads as "close the
      // whole thing"; she had to trust it would step back and keep her
      // answers. It does (the PopScope above), and this says so in words.
      //
      // Kept for revert (2026-09-29): superseded by the round back arrow the
      // shell now draws from step two on. With both, the page had two backs,
      // one at the top and one at the foot, and the worded one said nothing
      // the arrow and the "2 of 3" in the eyebrow do not.
      // _gap(6),
      // Center(
      //   child: TextButton(
      //     key: const ValueKey('ttc_start_back'),
      //     onPressed: () => setState(() => _page = 0),
      //     child: Text(
      //       kTtcStartBackToKind,
      //       style: pvManrope(
      //         fontSize: 13.5,
      //         fontWeight: FontWeight.w800,
      //         color: ttcInk,
      //       ),
      //     ),
      //   ),
      // ),
    ];
  }

  List<Widget> _reviewPage() {
    final draft = _draft;
    final first = ttcFirstTreatmentDate(draft);
    final now = DateTime.now();
    final c = TtcTreatmentStore.instance.cycle;
    return [
      ttcToolPad(
        Container(
          key: const ValueKey('ttc_start_statement'),
          padding: const EdgeInsets.all(18),
          // White with a hairline, the round's object card (2026-09-27, the
          // tool rebuild). Kept for revert: color: ttcPanel, no border.
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ttcLine, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.event_available_outlined,
                    size: 18,
                    color: ttcTitleInk,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ttcRoundKindName(_kind!),
                      style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: ttcTitleInk,
                      ),
                    ),
                  ),
                ],
              ),
              _gap(10),
              Text(
                ttcStartWhatChanges(first, now),
                style: pvManrope(
                  fontSize: 15,
                  height: 1.5,
                  color: ttcTitleInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _gap(10),
              Text(
                kTtcStartUndoLine,
                style: pvManrope(fontSize: 12.5, height: 1.45, color: ttcSoft),
              ),
              if (!c.isEmpty && !c.isClosed && c.kind != null) ...[
                _gap(8),
                Text(
                  kTtcStartClosesCurrent,
                  style: pvManrope(
                    fontSize: 12.5,
                    height: 1.45,
                    color: ttcSoft,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      _gap(18),
      ttcToolPad(
        Text(
          kTtcStartClinicLabel,
          style: pvManrope(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: ttcTitleInk,
          ),
        ),
      ),
      _gap(8),
      ttcToolPad(
        TextField(
          key: const ValueKey('ttc_start_clinic'),
          controller: _clinic,
          textCapitalization: TextCapitalization.words,
          // Rebuilds so the clear button shows and hides with the text.
          onChanged: (_) => setState(() {}),
          style: pvManrope(fontSize: 14.5, color: ttcTitleInk),
          decoration: InputDecoration(
            // The name is filled in from her last round, so it gets a one-tap
            // clear like every other answer here (2026-09-29). Before, the
            // only way to remove it was the keyboard, a letter at a time.
            suffixIcon: _clinic.text.isEmpty
                ? null
                : IconButton(
                    key: const ValueKey('ttc_start_clinic_clear'),
                    tooltip: 'Clear the clinic name',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: ttcMuted,
                    ),
                    onPressed: () => setState(_clinic.clear),
                  ),
            hintText: 'Clinic name',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: ttcLine),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: ttcLine),
            ),
          ),
        ),
      ),
      _gap(8),
      ttcToolPad(
        Text(
          kTtcStartPartnerLine,
          style: pvManrope(fontSize: 12.5, height: 1.4, color: ttcSoft),
        ),
      ),
      _gap(22),
      ttcToolPad(
        TtcRoundButton(
          key: const ValueKey('ttc_start_save'),
          label: first == null ? kTtcStartOkayNoDate : kTtcStartOkay,
          onTap: _save,
        ),
      ),
      _gap(8),
      ttcToolPad(
        TtcRoundButton(
          key: const ValueKey('ttc_start_change_date'),
          label: first == null ? kTtcStartAddDate : kTtcStartChangeDate,
          primary: false,
          onTap: () => setState(() => _page = 1),
        ),
      ),
    ];
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.info_outline_rounded, size: 16, color: ttcSoft),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: pvManrope(fontSize: 12.5, height: 1.45, color: ttcSoft),
        ),
      ),
    ],
  );
}

/// One date to add in the start flow, and (since 2026-09-27) a legacy
/// round's date on the treatment screen, which had its own older row.
class TtcRoundDateRow extends StatelessWidget {
  const TtcRoundDateRow({
    super.key,
    required this.label,
    required this.line,
    required this.value,
    required this.onTap,
    required this.onClear,
    this.withTime = false,
    this.clearKey,
    this.below,
  });

  final String label, line;
  final DateTime? value;
  final bool withTime;
  final VoidCallback onTap, onClear;

  /// For tests: the key on the remove button.
  final Key? clearKey;

  /// Under the date, inside the row: the trigger's "taken" tick.
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    final v = value;
    final shown = v == null
        ? 'Add date'
        : withTime
        ? '${ttcRoundDate(v)} · ${ttcRoundTime(v)}'
        : ttcRoundDate(v);
    return Semantics(
      button: true,
      label: '$label. $shown',
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: ttcLine, width: 1.2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: ttcTitleInk,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: ttcTitleInk,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        line,
                        style: pvManrope(
                          fontSize: 12,
                          height: 1.4,
                          color: ttcSoft,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        shown,
                        style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: v == null ? ttcMuted : ttcTitleInk,
                        ),
                      ),
                      if (below case final b?) ...[
                        const SizedBox(height: 8),
                        b,
                      ],
                    ],
                  ),
                ),
                if (v != null)
                  IconButton(
                    key: clearKey,
                    tooltip: 'Remove this date',
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: ttcMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  "Here's how your round usually goes": the dated timeline
// =============================================================================

class TtcRoundTimeline extends StatelessWidget {
  const TtcRoundTimeline({
    super.key,
    required this.round,
    this.today,
    this.readOnly = false,
  });

  final TtcTreatmentCycle round;

  /// For tests; the app passes nothing.
  final DateTime? today;

  /// A closed round, shown to look back at (2026-09-27, the tool rebuild):
  /// only the steps that have a date, and nothing to tap but "Read about it".
  /// Every edit on this timeline writes to the OPEN round, so a past round's
  /// rows must not offer one.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final now = today ?? DateTime.now();
    final t = DateTime(now.year, now.month, now.day);
    final kind = round.kind;
    final rows = [
      for (final r in ttcRoundRows(kind))
        if (!readOnly ||
            (r.scans ? round.scans.isNotEmpty : round[r.step!] != null))
          r,
    ];
    final phase = ttcTreatmentPhase(round, t);
    return Column(
      key: const ValueKey('ttc_round_timeline'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < rows.length; i++)
          _TimelineRow(
            row: rows[i],
            round: round,
            today: t,
            last: i == rows.length - 1,
            readOnly: readOnly,
          ),
        if (phase == TtcRoundPhase.planned || phase.isRunning) ...[_gap(4)],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.row,
    required this.round,
    required this.today,
    required this.last,
    this.readOnly = false,
  });

  final bool readOnly;

  final TtcRoundRow row;
  final TtcTreatmentCycle round;
  final DateTime today;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final kind = round.kind;
    final step = row.step;
    final dates = row.scans
        ? [for (final s in round.scans) DateTime(s.year, s.month, s.day)]
        : [?round[step!]];
    DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
    final done =
        dates.isNotEmpty && dates.every((d) => dayOf(d).isBefore(today));
    final isToday = dates.any((d) => dayOf(d) == today);
    final label = row.scans
        ? ttcScansRowLabel(kind)
        : ttcStepLabel(step!, kind);
    final readId = ttcRowReadIds(
      row,
      kind,
    ).where((id) => ttcReadById(id) != null).firstOrNull;

    String dateText() {
      if (dates.isEmpty) return kTtcRoundClinicWillTell;
      // A count in the eyebrow; each scan is its own chip below, which can
      // be changed or removed (2026-09-27, the tool rebuild). Kept for
      // revert: `return dates.map(ttcRoundDate).join(', ');`.
      if (row.scans) {
        return dates.length == 1 ? '1 scan' : '${dates.length} scans';
      }
      final d = dates.first;
      final base = isToday ? 'Today, ${ttcRoundDate(d)}' : ttcRoundDate(d);
      return step!.needsTime ? '$base · ${ttcRoundTime(d)}' : base;
    }

    final markerColor = isToday
        ? ttcTitleInk
        : done
        ? ttcTitleInk
        : Colors.white;

    return Semantics(
      label: '$label. ${dateText()}.',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- the rail: a disc per step, a hairline between -------------
            SizedBox(
              width: 30,
              child: Column(
                children: [
                  _gap(4),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dates.isEmpty ? ttcLine : ttcTitleInk,
                        width: 1.6,
                      ),
                    ),
                    child: done
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : isToday
                        ? const Icon(Icons.circle, size: 8, color: Colors.white)
                        : null,
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: ttcLine,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ---- the step --------------------------------------------------
            Expanded(
              child: InkWell(
                key: ValueKey('ttc_round_row_${step?.name ?? 'scans'}'),
                borderRadius: BorderRadius.circular(14),
                onTap: readOnly ? null : () => _edit(context),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18, top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText().toUpperCase(),
                        style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: dates.isEmpty ? ttcMuted : ttcTitleInk,
                        ),
                      ),
                      _gap(3),
                      Text(
                        label,
                        style: pvManrope(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: ttcTitleInk,
                        ),
                      ),
                      _gap(3),
                      Text(
                        ttcRowLine(row, kind),
                        style: pvManrope(
                          fontSize: 12.5,
                          height: 1.45,
                          color: ttcSoft,
                        ),
                      ),
                      if (row.scans && dates.isNotEmpty) ...[
                        _gap(8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final d in dates)
                              _ScanChip(day: d, kind: kind, readOnly: readOnly),
                          ],
                        ),
                      ],
                      if (!readOnly &&
                          step == TtcTreatmentStep.trigger &&
                          dates.isNotEmpty) ...[
                        _gap(8),
                        TtcRoundTakenTick(taken: round.triggerTaken),
                      ],
                      if (!readOnly &&
                          step == TtcTreatmentStep.transfer &&
                          dates.isNotEmpty) ...[
                        _gap(8),
                        _EmbryoDay(value: round.embryoDay),
                      ],
                      Wrap(
                        spacing: 14,
                        runSpacing: 2,
                        children: [
                          if (!readOnly)
                            _Link(
                              key: ValueKey(
                                'ttc_round_edit_${step?.name ?? 'scans'}',
                              ),
                              label: row.scans
                                  ? (dates.isEmpty
                                        ? 'Add a scan'
                                        : kTtcRoundAddScan)
                                  : (dates.isEmpty
                                        ? 'Add date'
                                        : 'Change date'),
                              onTap: () => _edit(context),
                            ),
                          // Removing now offers Undo (tools pass, 2026-09-27).
                          // Kept for revert: the two onTaps called
                          // `setDate(step!, null)` and `removeScan(dates.last)`
                          // with no way back.
                          if (!readOnly && !row.scans && dates.isNotEmpty)
                            _Link(
                              key: ValueKey('ttc_round_remove_${step!.name}'),
                              label: 'Remove',
                              onTap: () {
                                final store = TtcTreatmentStore.instance;
                                final was = round[step];
                                final taken = round.triggerTaken;
                                store.setDate(step, null);
                                ttcRoundDateRemoved(context, label, () {
                                  store.setDate(step, was);
                                  // Undo puts the tick back too, so a trigger
                                  // she already took does not re-arm reminders.
                                  if (step == TtcTreatmentStep.trigger &&
                                      taken) {
                                    store.setTriggerTaken(true);
                                  }
                                });
                              },
                            ),
                          // Kept for revert (2026-09-27, the tool rebuild): one
                          // link removed only the LAST scan, so a wrong date
                          // in the middle could not be taken out. Each scan is
                          // a chip now with its own change and remove.
                          // if (row.scans && dates.isNotEmpty)
                          //   _Link(
                          //     label: 'Remove last scan',
                          //     onTap: () {
                          //       final store = TtcTreatmentStore.instance;
                          //       final was = dates.last;
                          //       store.removeScan(dates.last);
                          //       ttcRoundDateRemoved(context,
                          //           ttcScanLabel(kind), () => store.addScan(was));
                          //     },
                          //   ),
                          if (readId != null)
                            _Link(
                              // Kept for revert (2026-09-28): 'Read about it',
                              label: 'Read about this step',
                              onTap: () =>
                                  openTtcArticle(context, readId, hue: kIvfHue),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final picked = await ttcPickRoundDate(
      context,
      round: round,
      step: row.step,
      help: row.step == null
          ? ttcScanLabel(round.kind)
          : ttcStepLabel(row.step!, round.kind),
    );
    if (picked == null) return;
    final store = TtcTreatmentStore.instance;
    if (row.step == null) {
      store.addScan(picked);
    } else {
      store.setDate(row.step!, picked);
    }
  }
}

class _Link extends StatelessWidget {
  const _Link({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: pvManrope(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: ttcTitleInk,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
  );
}

/// One scan's date. A tap offers "Change date" and "Remove" (with Undo),
/// the shape of an event's action sheet (LinkedIn's event menu,
/// https://mobbin.com/screens/415244fa-a70c-4334-972d-508b3b18151c).
class _ScanChip extends StatelessWidget {
  const _ScanChip({
    required this.day,
    required this.kind,
    required this.readOnly,
  });

  final DateTime day;
  final TtcRoundKind? kind;
  final bool readOnly;

  Future<void> _open(BuildContext context) async {
    final store = TtcTreatmentStore.instance;
    final label = ttcScanLabel(kind);
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      routeSettings: const RouteSettings(name: 'ttc/treatment/scan'),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => _SheetBody(
        title: label,
        body: ttcRoundDate(day),
        options: const [
          (
            'change',
            'Change date',
            'Pick the right day for this scan.',
            Icons.edit_calendar_outlined,
          ),
          (
            'remove',
            'Remove this scan',
            'You can undo this straight after.',
            Icons.delete_outline_rounded,
          ),
        ],
        // Kept for revert (2026-09-28): 'Keep it'
        links: const [('cancel', 'Keep the scan')],
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 'change':
        final picked = await ttcPickRoundDate(
          context,
          round: store.cycle,
          step: null,
          help: label,
        );
        if (picked == null) return;
        store.removeScan(day);
        store.addScan(picked);
      case 'remove':
        store.removeScan(day);
        ttcRoundDateRemoved(context, label, () => store.addScan(day));
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = ttcRoundDate(day);
    return Semantics(
      button: !readOnly,
      label: '${ttcScanLabel(kind)}, $text',
      excludeSemantics: true,
      onTap: readOnly ? null : () => _open(context),
      child: InkWell(
        key: ValueKey('ttc_round_scan_${day.toIso8601String()}'),
        onTap: readOnly ? null : () => _open(context),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcLine, width: 1.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: ttcTitleInk,
                ),
              ),
              if (!readOnly) ...[
                const SizedBox(width: 6),
                const Icon(Icons.edit_outlined, size: 13, color: ttcSoft),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The tick that silences the trigger reminders (see the screen's own note).
/// Public since 2026-09-27 so a legacy round's trigger row wears this one
/// rather than the older violet box.
class TtcRoundTakenTick extends StatelessWidget {
  const TtcRoundTakenTick({super.key, required this.taken});
  final bool taken;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: taken,
    // Kept for revert (2026-09-28): 'Taken it? Tick here'
    label: taken ? 'Trigger taken. Reminders off.' : 'Trigger taken? Tap to tick',
    child: GestureDetector(
      onTap: () => TtcTreatmentStore.instance.setTriggerTaken(!taken),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            taken
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            size: 18,
            color: ttcTitleInk,
          ),
          const SizedBox(width: 6),
          // Flexible since the label names the trigger (2026-09-28): the
          // longer words wrap in the narrow timeline column at 360dp.
          Flexible(
            child: Text(
              taken ? 'Taken · reminders off' : 'Trigger taken? Tap to tick',
              style: pvManrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ttcSoft,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Day 3 or day 5: asked on the transfer row, kept for dating a pregnancy.
class _EmbryoDay extends StatelessWidget {
  const _EmbryoDay({required this.value});
  final int? value;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(kTtcRoundEmbryoQ, style: pvManrope(fontSize: 12, color: ttcSoft)),
      for (final d in const [3, 5])
        TtcToolPill(
          key: ValueKey('ttc_round_embryo_$d'),
          label: 'Day $d',
          on: value == d,
          hue: kIvfHue,
          onTap: () =>
              TtcTreatmentStore.instance.setEmbryoDay(value == d ? null : d),
        ),
    ],
  );
}

// =============================================================================
//  The check-in sheet: the same sheet for 7 quiet days and a 30-day return
// =============================================================================

/// Opens the check-in. Answers: Still going, Paused, It's over; plus "Add the
/// next date" and "Ask me later". Nothing closes without a confirmation.
Future<void> showTtcCheckInSheet(BuildContext context) async {
  final store = TtcTreatmentStore.instance;
  final returning = store.askOnReturnPending;
  final choice = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    routeSettings: const RouteSettings(name: 'ttc/treatment/check_in'),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (ctx) => _SheetBody(
      title: kTtcCheckInTitle,
      body: returning ? kTtcCheckInReturnBody : kTtcCheckInBody,
      options: const [
        (
          'still',
          kTtcCheckInStill,
          kTtcCheckInStillLine,
          Icons.play_circle_outline_rounded,
        ),
        (
          'paused',
          kTtcCheckInPaused,
          kTtcCheckInPausedLine,
          Icons.pause_circle_outline_rounded,
        ),
        (
          'over',
          kTtcCheckInOver,
          kTtcCheckInOverLine,
          Icons.check_circle_outline_rounded,
        ),
      ],
      links: const [('add', kTtcCheckInAddDate), ('later', kTtcCheckInLater)],
    ),
  );
  if (!context.mounted) return;
  switch (choice) {
    case 'still':
      store.stillGoing();
      pvSnack(
        context,
        "We'll keep following your round.",
        icon: Icons.check_rounded,
        lift: 24,
      );
    case 'paused':
      await ttcConfirmCloseRound(context, TtcRoundOutcome.paused);
    case 'over':
      await ttcConfirmCloseRound(context, TtcRoundOutcome.ended);
    case 'add':
      store.stillGoing();
      openTtcTreatment(context);
    case 'later':
      store.snoozeCheckIn();
    default:
      break; // dismissed: nothing changes, the card stays
  }
}

/// A sheet of two to three labelled options, then quiet links.
class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.title,
    required this.body,
    required this.options,
    this.links = const [],
  });

  final String title, body;
  final List<(String, String, String, IconData)> options;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: ttcLine,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            _gap(16),
            Text(
              title,
              style: pvFraunces(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: ttcTitleInk,
              ),
            ),
            _gap(8),
            Text(
              body,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: ttcSoft),
            ),
            _gap(16),
            for (final (id, name, line, icon) in options) ...[
              TtcRoundOption(
                key: ValueKey('ttc_sheet_$id'),
                title: name,
                line: line,
                icon: icon,
                onTap: () => Navigator.of(context).pop(id),
              ),
              _gap(10),
            ],
            for (final (id, label) in links)
              Center(
                child: TextButton(
                  key: ValueKey('ttc_sheet_$id'),
                  onPressed: () => Navigator.of(context).pop(id),
                  child: Text(
                    label,
                    style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: ttcTitleInk,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  "The plan changed"
// =============================================================================

Future<void> showTtcPlanChangedSheet(BuildContext context) async {
  final store = TtcTreatmentStore.instance;
  final kind = store.cycle.kind;
  final ivf = kind == TtcRoundKind.ivfFresh || kind == TtcRoundKind.notSure;
  final canIui =
      kind != TtcRoundKind.iui &&
      kind != TtcRoundKind.fetMedicated &&
      kind != TtcRoundKind.fetNatural;
  final choice = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    routeSettings: const RouteSettings(name: 'ttc/treatment/plan_changed'),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) => _SheetBody(
      title: kTtcPlanTitle,
      body: kTtcPlanBody,
      options: [
        (
          'stopped',
          kTtcPlanStopped,
          kTtcPlanStoppedLine,
          Icons.stop_circle_outlined,
        ),
        if (canIui)
          ('iui', kTtcPlanIui, kTtcPlanIuiLine, Icons.swap_horiz_rounded),
        if (ivf)
          ('freeze', kTtcPlanFreeze, kTtcPlanFreezeLine, Icons.ac_unit_rounded),
        // A mis-tap on the first screen of the start flow had no fix short
        // of starting again, which closes the round (2026-09-27, the tool
        // rebuild). The same confirmed, undoable kind change as "It became
        // an IUI", for any kind.
        ('kind', kTtcPlanWrongKind, kTtcPlanWrongKindLine, Icons.edit_outlined),
      ],
      links: const [('cancel', 'Nothing changed')],
    ),
  );
  if (!context.mounted) return;
  switch (choice) {
    case 'stopped':
      await ttcConfirmCloseRound(context, TtcRoundOutcome.stopped);
    case 'iui':
      await _confirmKind(context, TtcRoundKind.iui);
    case 'freeze':
      await _confirmKind(context, TtcRoundKind.ivfFreezeAll);
    case 'kind':
      await ttcPickRoundKind(context);
    default:
      break;
  }
}

const String kTtcPlanWrongKind = 'I picked the wrong treatment';
const String kTtcPlanWrongKindLine =
    'Choose the right one. Every date you added stays.';

/// Every kind but the one she has, as a sheet, then the kind's confirm.
/// The treatment screen offers it directly on a round with no dates yet.
Future<void> ttcPickRoundKind(BuildContext context) async {
  final now = TtcTreatmentStore.instance.cycle.kind;
  final kinds = [
    for (final k in const [
      TtcRoundKind.ivfFresh,
      TtcRoundKind.ivfFreezeAll,
      TtcRoundKind.fetMedicated,
      TtcRoundKind.fetNatural,
      TtcRoundKind.iui,
      TtcRoundKind.ovulationInduction,
      TtcRoundKind.notSure,
    ])
      if (k != now) k,
  ];
  final picked = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    routeSettings: const RouteSettings(name: 'ttc/treatment/pick_kind'),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: _SheetBody(
        title: kTtcStartKindTitle,
        body: now == null
            ? kTtcStartKindBody
            : 'Now: ${ttcRoundKindName(now)}.',
        options: [
          for (final k in kinds)
            (
              k.name,
              ttcRoundKindName(k),
              ttcRoundKindNote(k),
              Icons.circle_outlined,
            ),
        ],
        // Kept for revert (2026-09-28): 'Keep it as it is'
        links: const [('cancel', 'Keep the same treatment')],
      ),
    ),
  );
  if (picked == null || picked == 'cancel' || !context.mounted) return;
  final kind = TtcRoundKind.values.firstWhere((k) => k.name == picked);
  await _confirmKind(context, kind);
}

Future<void> _confirmKind(BuildContext context, TtcRoundKind kind) async {
  final store = TtcTreatmentStore.instance;
  final before = store.cycle.kind;
  // The path is put back by Undo too (2026-09-27, the tool rebuild): Undo
  // restored the kind and left the path on the new one, so the calendar
  // and the home kept following a treatment she had just taken back.
  final beforePath = TtcStore.instance.path;
  final (title, body, yes) = ttcConfirmKind(kind);
  final ok = await showDialog<bool>(
    context: context,
    routeSettings: const RouteSettings(name: 'ttc/treatment/confirm_kind'),
    builder: (_) =>
        _ConfirmDialog(title: title, body: body, yes: yes, no: kTtcConfirmKeep),
  );
  if (ok != true || !context.mounted) return;
  store.changeKind(kind);
  if (kind != TtcRoundKind.ivfFreezeAll) {
    TtcStore.instance.setPath(ttcPathForKind(kind));
  }
  pvSnack(
    context,
    'Your round now follows the ${ttcRoundKindName(kind)} steps.',
    icon: Icons.check_rounded,
    lift: 24,
    action: kTtcRoundUndoCta,
    // Kept for revert: onAction: ... () => store.changeKind(before));
    onAction: before == null
        ? null
        : () {
            store.changeKind(before);
            TtcStore.instance.setPath(beforePath);
          },
  );
}

// =============================================================================
//  The result
// =============================================================================

class TtcTreatmentResultScreen extends StatelessWidget {
  const TtcTreatmentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TtcTreatmentStore.instance,
      builder: (context, _) {
        final store = TtcTreatmentStore.instance;
        if (!store.isLoaded) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: ttcTitleInk)),
          );
        }
        final open = !store.cycle.isEmpty;
        return TtcToolScaffold(
          hue: kIvfHue,
          variant: 3,
          eyebrow: 'Your round',
          title: kTtcResultTitle,
          intro: kTtcResultBody,
          children: [
            _gap(22),
            if (!open) ...[
              ttcToolPad(
                _Note(
                  "There's no round open right now, so there's "
                  'nothing to record.',
                ),
              ),
              _gap(16),
              ttcToolPad(
                TtcRoundButton(
                  label: kTtcSeeRound,
                  onTap: () => openTtcTreatment(context),
                ),
              ),
            ] else ...[
              ttcToolPad(
                TtcRoundOption(
                  key: const ValueKey('ttc_result_positive'),
                  title: kTtcResultPositive,
                  line: kTtcResultPositiveLine,
                  icon: Icons.favorite_border_rounded,
                  onTap: () async {
                    // Straight on to how the pregnancy is dated, which asks
                    // before anything moves (2026-09-26, B8). Kept for revert:
                    //   final nav = Navigator.of(context);
                    //   if (await ttcConfirmCloseRound(...)) nav.maybePop();
                    if (await ttcConfirmCloseRound(
                          context,
                          TtcRoundOutcome.positive,
                        ) &&
                        context.mounted) {
                      openTtcRoundPregnancy(context, replace: true);
                    }
                  },
                ),
              ),
              _gap(10),
              ttcToolPad(
                TtcRoundOption(
                  key: const ValueKey('ttc_result_negative'),
                  title: kTtcResultNegative,
                  line: kTtcResultNegativeLine,
                  icon: Icons.circle_outlined,
                  onTap: () async {
                    final nav = Navigator.of(context);
                    if (await ttcConfirmCloseRound(
                      context,
                      TtcRoundOutcome.negative,
                    )) {
                      nav.maybePop();
                    }
                  },
                ),
              ),
              _gap(10),
              ttcToolPad(
                TtcRoundOption(
                  key: const ValueKey('ttc_result_repeat'),
                  title: kTtcResultRepeat,
                  line: kTtcResultRepeatLine,
                  icon: Icons.event_repeat_outlined,
                  onTap: () async {
                    final at = await ttcPickRoundDate(
                      context,
                      round: store.cycle,
                      step: TtcTreatmentStep.repeatBeta,
                      help: 'Date of the next test',
                    );
                    if (at == null || !context.mounted) return;
                    store.setDate(TtcTreatmentStep.repeatBeta, at);
                    pvSnack(
                      context,
                      'Next test added for ${ttcRoundDate(at)}. The round stays open.',
                      icon: Icons.check_rounded,
                      lift: 24,
                    );
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
              _gap(14),
              Center(
                child: TextButton(
                  key: const ValueKey('ttc_result_later'),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    kTtcResultLater,
                    style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: ttcTitleInk,
                    ),
                  ),
                ),
              ),
            ],
            _gap(28),
          ],
        );
      },
    );
  }
}

// =============================================================================
//  The "Starting treatment?" card: the IVF door and the treatment screen
// =============================================================================

class TtcStartTreatmentCard extends StatelessWidget {
  const TtcStartTreatmentCard({super.key, this.onTap});

  /// Null opens the start flow directly.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$kTtcRoundStartCardTitle $kTtcRoundStartCardBody',
      // excludeSemantics drops the child's tap action, so the node
      // carries it (accessibility sweep, TTC launch walk, 2026-09-27).
      onTap: onTap ?? () => openTtcTreatmentStart(context),
      excludeSemantics: true,
      // White with a hairline (2026-09-27, the tool rebuild), like the IVF
      // door's round panel beside it. Kept for revert: color: ttcPanel and
      // no border.
      child: Material(
        key: const ValueKey('ttc_start_treatment_card'),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: ttcLine, width: 1.2),
        ),
        // ⚠️ ONE COMPACT ROW (2026-09-30, the user on the IVF door: "this
        // whole card, this whole section seems too big… bad space
        // optimization"). The icon, a 19pt title, the sentence and a big
        // "Start my round" pill shared one row, so the words were squeezed
        // into a narrow column four lines tall. Now the words get the width,
        // the title is the door's card size, and the way on is a small ink
        // arrow; the whole card is the tap, as before, and its label still
        // names what it opens. Kept for revert, the tall row:
        // child: InkWell(
        //   borderRadius: BorderRadius.circular(22),
        //   onTap: onTap ?? () => openTtcTreatmentStart(context),
        //   child: Padding(
        //     padding: const EdgeInsets.all(18),
        //     child: Row(
        //       children: [
        //         const Icon(
        //           Icons.event_note_outlined,
        //           size: 24,
        //           color: ttcTitleInk,
        //         ),
        //         const SizedBox(width: 14),
        //         Expanded(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 kTtcRoundStartCardTitle,
        //                 style: pvFraunces(
        //                   fontSize: 19,
        //                   fontWeight: FontWeight.w600,
        //                   color: ttcTitleInk,
        //                 ),
        //               ),
        //               const SizedBox(height: 4),
        //               Text(
        //                 kTtcRoundStartCardBody,
        //                 style: pvManrope(
        //                   fontSize: 13,
        //                   height: 1.45,
        //                   color: ttcSoft,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         const SizedBox(width: 8),
        //         // ⚠️ THE PILL GIVES WAY AT A LARGE TEXT SIZE (2026-09-29, the
        //         // door overflow test at 360pt and 1.5): it overflowed the row
        //         // by 63. Flexible with one ellipsised line; at the normal size
        //         // the pill is as before. Kept for revert: the Container bare
        //         // and its Text without maxLines.
        //         Flexible(
        //           child: Container(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 14,
        //               vertical: 9,
        //             ),
        //             decoration: const ShapeDecoration(
        //               color: ttcTitleInk,
        //               shape: StadiumBorder(),
        //             ),
        //             child: Text(
        //               kTtcRoundStartCta,
        //               maxLines: 1,
        //               overflow: TextOverflow.ellipsis,
        //               style: pvManrope(
        //                 fontSize: 13,
        //                 fontWeight: FontWeight.w800,
        //                 color: Colors.white,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap ?? () => openTtcTreatmentStart(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
            child: Row(
              children: [
                const Icon(
                  Icons.event_note_outlined,
                  size: 22,
                  color: ttcTitleInk,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kTtcRoundStartCardTitle,
                        style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: ttcTitleInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kTtcRoundStartCardBody,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                          fontSize: 12.5,
                          height: 1.35,
                          color: ttcSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: ttcTitleInk,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  The IVF & IUI door's top panel (B7, §3f)
// =============================================================================

/// Which panel the IVF door leads with.
enum TtcIvfPanel { start, round, between, positive }

/// How long after a round closes the door leads with "Between rounds" (or
/// "Positive test") before it offers "Starting treatment?" again.
const int kTtcBetweenRoundsPanelDays = 90;

/// The panel the IVF door shows now. Pure over the stores, for the test.
TtcIvfPanel ttcIvfPanelNow({DateTime? now}) {
  final t = TtcTreatmentStore.instance;
  final c = t.cycle;
  if (!c.isEmpty || c.kind != null) return TtcIvfPanel.round;
  final last = t.lastClosed;
  final on = last?.closedOn;
  if (last != null && on != null) {
    final at = now ?? DateTime.now();
    final days = DateTime(at.year, at.month, at.day).difference(on).inDays;
    if (days >= 0 && days <= kTtcBetweenRoundsPanelDays) {
      if (last.outcome == TtcRoundOutcome.positive) {
        return TtcStore.instance.pregnancyConfirmed
            ? TtcIvfPanel.start
            : TtcIvfPanel.positive;
      }
      return TtcIvfPanel.between;
    }
  }
  return TtcIvfPanel.start;
}

/// True while a round is open and planned or running (S1 to S9): the IVF
/// door moves "Going through it" and "Track" first (§3f, order only).
bool ttcIvfRoundLeads({DateTime? now}) {
  final c = TtcTreatmentStore.instance.cycle;
  if (c.isEmpty || c.isClosed) return false;
  final p = ttcTreatmentPhase(c, now ?? DateTime.now());
  return p == TtcRoundPhase.planned || p.isRunning;
}

/// The panel. [onStart] opens the start flow (the door passes its surface).
class TtcIvfRoundPanel extends StatelessWidget {
  const TtcIvfRoundPanel({super.key, this.onStart, this.onRead});

  final VoidCallback? onStart;

  /// Opens a read by id (the door passes its own opener and hue).
  final void Function(String readId)? onRead;

  @override
  Widget build(BuildContext context) {
    final t = TtcTreatmentStore.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (ttcIvfPanelNow(now: now)) {
      case TtcIvfPanel.start:
        return TtcStartTreatmentCard(onTap: onStart);
      case TtcIvfPanel.round:
        final r = t.cycle;
        final kind = r.kind;
        if (r.isEmpty) {
          return _Panel(
            key: const ValueKey('ttc_ivf_panel_round'),
            eyebrow: '$kTtcPanelRoundEyebrow · ${ttcRoundKindShort(kind)}',
            title: kTtcPanelNoDatesTitle,
            line: kTtcPanelNoDatesLine,
            primary: (kTtcPanelSeePlan, () => openTtcTreatment(context)),
          );
        }
        final phase = ttcTreatmentPhase(r, today);
        final count = ttcRoundDayCount(r, phase, today);
        final next = ttcRoundNextAfter(r, today);
        final title = count == null || count.$1 <= 0
            ? ttcRoundPhaseName(phase, kind)
            : '${ttcRoundPhaseName(phase, kind)} · day ${count.$1}';
        return _Panel(
          key: const ValueKey('ttc_ivf_panel_round'),
          eyebrow: '$kTtcPanelRoundEyebrow · ${ttcRoundKindShort(kind)}',
          title: title,
          line: next == null
              ? kTtcPanelNoNext
              : ttcPanelNextLine(next.$1, next.$2, today, kind),
          primary: (kTtcPanelSeePlan, () => openTtcTreatment(context)),
          secondary: phase == TtcRoundPhase.testDay
              ? (kTtcRoundTellResult, () => openTtcTreatmentResult(context))
              : (kTtcPanelUpdateDates, () => openTtcTreatment(context)),
        );
      case TtcIvfPanel.between:
        final negative = t.lastClosed?.outcome == TtcRoundOutcome.negative;
        return _Panel(
          key: const ValueKey('ttc_ivf_panel_between'),
          eyebrow: kTtcPanelRoundEyebrow,
          title: kTtcPanelBetweenTitle,
          line: kTtcPanelBetweenLine,
          reads: [
            if (negative) 'ttc_read_tx_negative_after_treatment',
            'ttc_read_tx_review_appointment',
            'ttc_read_month_after_month',
          ],
          onRead: onRead,
          primary: (
            kTtcPanelStartNext,
            onStart ?? () => openTtcTreatmentStart(context),
          ),
        );
      case TtcIvfPanel.positive:
        return _Panel(
          key: const ValueKey('ttc_ivf_panel_positive'),
          eyebrow: kTtcPanelRoundEyebrow,
          title: kTtcPanelPositiveTitle,
          line: kTtcResultPositiveNext,
          reads: const ['ttc_read_tx_beta_test'],
          onRead: onRead,
          primary: (
            kTtcPanelDatePregnancy,
            () => openTtcRoundPregnancy(context),
          ),
        );
    }
  }
}

/// A white object card with a hairline: an eyebrow, a title in the display
/// face, one line, optional read rows, and one or two pills that say what
/// they do. Not a tinted panel (DESIGN-SYSTEM §4.0 addendum 1).
class _Panel extends StatelessWidget {
  const _Panel({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.line,
    required this.primary,
    this.secondary,
    this.reads = const [],
    this.onRead,
  });

  final String eyebrow, title, line;
  final (String, VoidCallback) primary;
  final (String, VoidCallback)? secondary;
  final List<String> reads;
  final void Function(String readId)? onRead;

  @override
  Widget build(BuildContext context) {
    Widget pill(String label, VoidCallback onTap, bool ink) => Semantics(
      button: true,
      label: label,
      // excludeSemantics drops the child's tap action, so the node
      // carries it (accessibility sweep, TTC launch walk, 2026-09-27).
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: ink ? ttcTitleInk : Colors.white,
        shape: StadiumBorder(
          side: ink
              ? BorderSide.none
              : const BorderSide(color: ttcLine, width: 1.4),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Text(
                label,
                style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ink ? Colors.white : ttcTitleInk,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final live = [
      for (final id in reads)
        if (ttcReadById(id) case final r?) (id, r.title.en),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ttcLine, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: pvManrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: ttcSoft,
            ),
          ),
          _gap(6),
          Text(
            title,
            style: pvFraunces(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: ttcTitleInk,
            ),
          ),
          _gap(6),
          Text(
            line,
            style: pvManrope(fontSize: 13.5, height: 1.5, color: ttcSoft),
          ),
          if (live.isNotEmpty) ...[
            _gap(8),
            for (final (id, t) in live)
              Semantics(
                button: true,
                label: t,
                // excludeSemantics drops the child's tap action, so the node
                // carries it (accessibility sweep, TTC launch walk, 2026-09-27).
                onTap: onRead == null ? null : () => onRead!(id),
                excludeSemantics: true,
                child: InkWell(
                  key: ValueKey('ttc_ivf_panel_read_$id'),
                  onTap: onRead == null ? null : () => onRead!(id),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: ttcLine)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 17,
                          color: ttcTitleInk,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t,
                            style: pvManrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: ttcTitleInk,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: ttcMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          _gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              pill(primary.$1, primary.$2, true),
              if (secondary case final s?) pill(s.$1, s.$2, false),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Positive, then Pregnancy dated by the clinic (B8)
// =============================================================================

/// "12 Jun 2027", for a due date.
String ttcDueDateText(DateTime d) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

/// The round a positive test is dated from: the open one, else the last
/// closed one when it closed as positive.
TtcTreatmentCycle? ttcRoundForPregnancy() {
  final t = TtcTreatmentStore.instance;
  if (!t.cycle.isEmpty) return t.cycle;
  final last = t.lastClosed;
  return last?.outcome == TtcRoundOutcome.positive ? last : null;
}

/// The option's name for a ready dating, and the line under it.
(String, String) ttcDatingOption(TtcRoundDating d, TtcRoundKind? kind) {
  final due = 'Due ${ttcDueDateText(d.due!)}.';
  return switch (d.fromStep) {
    TtcTreatmentStep.transfer => (
      // Kept for revert (2026-09-28): 'Date it from my transfer' (and
      // the same 'Date it from my …' below).
      'Date my pregnancy from my transfer',
      '$due Your transfer on ${ttcRoundDate(d.from!)}, a day '
          '${d.embryoDay} embryo, the way clinics date it.',
    ),
    TtcTreatmentStep.iui => (
      'Date my pregnancy from my IUI',
      '$due From your IUI on ${ttcRoundDate(d.from!)}. A dating scan may '
          'update it.',
    ),
    TtcTreatmentStep.trigger => (
      'Date my pregnancy from my trigger day',
      '$due From your trigger on ${ttcRoundDate(d.from!)}. A dating scan '
          'may update it.',
    ),
    _ => (
      'Date my pregnancy from my last period',
      '$due From your period on ${ttcRoundDate(d.from!)}. A dating scan '
          'may update it.',
    ),
  };
}

class TtcRoundPregnancyScreen extends StatefulWidget {
  const TtcRoundPregnancyScreen({super.key});

  @override
  State<TtcRoundPregnancyScreen> createState() =>
      _TtcRoundPregnancyScreenState();
}

class _TtcRoundPregnancyScreenState extends State<TtcRoundPregnancyScreen> {
  int? _embryo;
  bool _busy = false;

  Future<void> _move(DateTime due, DueDateSource source, String basis) async {
    final ok = await showDialog<bool>(
      context: context,
      routeSettings: const RouteSettings(
        name: 'ttc/treatment/confirm_pregnancy',
      ),
      builder: (_) => _ConfirmDialog(
        title: 'Move to Pregnancy?',
        body:
            'Your home becomes the pregnancy home, with a due date of '
            '${ttcDueDateText(due)} ($basis). Your round and everything you '
            'logged stay. You can undo this on the next screen.',
        yes: kTtcToPregConfirmYes,
        no: kTtcToPregConfirmNo,
      ),
    );
    if (ok != true || !mounted || _busy) return;
    setState(() => _busy = true);
    final store = TtcTreatmentStore.instance;
    // Came here from "I got a positive test" with the round still open: it
    // closes as positive, kept in her history like any closed round.
    if (!store.cycle.isEmpty) store.closeRound(TtcRoundOutcome.positive);
    final result = await const TtcTransitionEngine().confirmPregnancy(
      dueDate: due,
      source: source,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TtcTransitionScreen(result: result),
        settings: const RouteSettings(name: 'ttc/transition'),
      ),
    );
  }

  Future<void> _clinicDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 245)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 300)),
      helpText: 'The due date your clinic gave you',
      fieldHintText: 'dd/mm/yyyy',
      builder: _whitePicker,
    );
    if (day == null || !mounted) return;
    await _move(
      DateTime(day.year, day.month, day.day),
      DueDateSource.clinician,
      'the date your clinic gave you',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TtcTreatmentStore.instance,
      builder: (context, _) {
        final store = TtcTreatmentStore.instance;
        if (!store.isLoaded) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: ttcTitleInk)),
          );
        }
        final round = ttcRoundForPregnancy();
        final dating = round == null
            ? null
            : ttcRoundDating(
                round,
                lastPeriod: CycleStore.instance.lastPeriodStart,
                embryoDay: _embryo,
              );
        final open = !store.cycle.isEmpty;
        return TtcToolScaffold(
          hue: kIvfHue,
          variant: 3,
          eyebrow: 'Your round',
          title: kTtcToPregTitle,
          intro: kTtcToPregIntro,
          children: [
            _gap(22),
            // ⚠️ THE QUESTION STAYS WHILE SHE HAS ANSWERED IT HERE (2026-09-29).
            // It showed only while the answer was missing, so picking Day 3
            // hid it on the spot, and a mis-tap could not be changed or
            // cleared on this screen. Now her own answer keeps it on screen,
            // and a second tap on the chosen day clears it. Kept for revert:
            //   if (dating?.need == TtcRoundDatingNeed.embryoDay) ...[
            if (dating?.need == TtcRoundDatingNeed.embryoDay ||
                _embryo != null) ...[
              ttcToolPad(
                Text(
                  kTtcToPregEmbryoQ,
                  style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ttcTitleInk,
                  ),
                ),
              ),
              _gap(10),
              ttcToolPad(
                Wrap(
                  spacing: 8,
                  children: [
                    for (final d in const [3, 5])
                      TtcToolPill(
                        key: ValueKey('ttc_to_preg_embryo_$d'),
                        label: 'Day $d',
                        on: _embryo == d,
                        hue: kIvfHue,
                        // A second tap clears it (2026-09-29). Kept for
                        // revert: `_embryo = d` and `setEmbryoDay(d)`.
                        onTap: () {
                          final next = _embryo == d ? null : d;
                          setState(() => _embryo = next);
                          if (open) store.setEmbryoDay(next);
                        },
                      ),
                  ],
                ),
              ),
              _gap(18),
            ],
            if (dating?.need == TtcRoundDatingNeed.ready) ...[
              ttcToolPad(
                Builder(
                  builder: (_) {
                    final (name, line) = ttcDatingOption(dating!, round!.kind);
                    return TtcRoundOption(
                      key: const ValueKey('ttc_to_preg_from_round'),
                      title: name,
                      line: line,
                      icon: Icons.event_available_outlined,
                      onTap: () => _move(
                        dating.due!,
                        dating.source!,
                        // Kept for revert: name.replaceFirst('Date it ', '')
                        name
                            .replaceFirst('Date my pregnancy ', '')
                            .replaceFirst('my ', 'your '),
                      ),
                    );
                  },
                ),
              ),
              _gap(10),
            ],
            if (dating == null || dating.need == TtcRoundDatingNeed.noDate) ...[
              ttcToolPad(_Note(kTtcToPregNoDate)),
              _gap(12),
              if (open && ttcRoundDatesFromTransfer(round?.kind)) ...[
                ttcToolPad(
                  TtcRoundOption(
                    key: const ValueKey('ttc_to_preg_add_transfer'),
                    title: kTtcToPregAddTransfer,
                    line: 'Then we date your pregnancy from it.',
                    icon: Icons.edit_calendar_outlined,
                    onTap: () async {
                      final at = await ttcPickRoundDate(
                        context,
                        round: store.cycle,
                        step: TtcTreatmentStep.transfer,
                        help: 'Your transfer date',
                      );
                      if (at != null) {
                        store.setDate(TtcTreatmentStep.transfer, at);
                      }
                    },
                  ),
                ),
                _gap(10),
              ],
            ],
            ttcToolPad(
              TtcRoundOption(
                key: const ValueKey('ttc_to_preg_clinic_date'),
                title: kTtcToPregClinic,
                line: kTtcToPregClinicLine,
                icon: Icons.local_hospital_outlined,
                onTap: _clinicDate,
              ),
            ),
            _gap(14),
            Center(
              child: TextButton(
                key: const ValueKey('ttc_to_preg_not_now'),
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  kTtcToPregNotNow,
                  style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: ttcTitleInk,
                  ),
                ),
              ),
            ),
            ttcToolPad(
              Text(
                kTtcToPregNotNowLine,
                textAlign: TextAlign.center,
                style: pvManrope(fontSize: 12.5, height: 1.45, color: ttcSoft),
              ),
            ),
            _gap(28),
          ],
        );
      },
    );
  }
}

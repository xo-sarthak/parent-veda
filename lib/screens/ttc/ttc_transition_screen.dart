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

import '../../memories/memory_models.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_transition.dart';
import '../../ttc/ttc_treatment_store.dart' show TtcTreatmentStep;
import '../memories/memory_personalize_screen.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_treatment_round_screens.dart'
    show
        ttcRoundForPregnancy,
        openTtcRoundPregnancy,
        ttcDueDateText,
        TtcRoundOption;
import '../../services/pregnancy_controller.dart' show DueDateSource;
import '../../theme/pv_fonts.dart';
import 'ttc_tool_chrome.dart';

/// Asks first, then transitions. Returns true if the couple went through.
///
/// ⚠️ AFTER TREATMENT, THE CLINIC DATES IT (2026-09-26, B8). With a round
/// open, or one just closed as positive, a positive test goes to
/// `TtcRoundPregnancyScreen`, which dates the pregnancy from the transfer
/// and the embryo's day (or her clinic's own date) and says so before
/// anything moves. Counting from her last period after IVF would be our
/// arithmetic competing with the clinic's. A legacy round with no transfer
/// date keeps the flow below. Returns false there: that screen reports its
/// own outcome.
Future<bool> recordPositiveTest(BuildContext context) async {
  final round = ttcRoundForPregnancy();
  if (round != null &&
      (round.kind != null || round[TtcTreatmentStep.transfer] != null)) {
    openTtcRoundPregnancy(context);
    return false;
  }
  // ⚠️ A PAGE, NOT A GREY DIALOG (launch sanity H19, 2026-09-28). The
  // biggest moment in the stage was a plain Material dialog, and with no
  // round logged it could only date the pregnancy from her last period,
  // with no way to say the test followed a clinic transfer. The page asks
  // whether a clinic guided this cycle, dates it the way the clinic does
  // when one did (the DueDateSource rule), says the date and its basis
  // before anything moves, and keeps the undo on the screen after. The
  // dialog below is kept for revert and no longer reached.
  if (!context.mounted) return false;
  final moved = await Navigator.of(context).push<bool>(MaterialPageRoute<bool>(
    builder: (_) => const TtcPositiveTestScreen(),
    settings: const RouteSettings(name: 'ttc/positive_test'),
  ));
  return moved == true;
}

/// The old confirm dialog, kept for revert (H19, 2026-09-28).
// ignore: unused_element
Future<bool> _recordPositiveTestDialog(BuildContext context) async {
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
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 24, ttcGutter, ttcBottomInset),
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
                      colors: [ttcPurple, ttcPurpleDeep],
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

                // The single most important tap in the product, and until now
                // it showed a "coming soon" toast - the stage had already
                // flipped underneath her, so the app knew she was pregnant and
                // still refused to show her the pregnancy. See
                // `leaveTtcForPregnancy` for why this is a stack replacement.
                GestureDetector(
                  onTap: () => _toPregnancy(context),
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
                const SizedBox(height: 12),

                // A keepsake, offered ONCE, here, and nowhere else in the stage.
                //
                // §3.3 asked where share cards should be reachable from. The
                // answer for TTC is not "everywhere the other stages have them"
                // - it is exactly one place, and choosing that carefully is the
                // whole design.
                //
                // `MemoryType` is {expecting, welcomeBaby}, and TTC needs no
                // third: this stage's final moment IS the expecting
                // announcement. The card that already exists is the right card.
                //
                // WHY NOT THE OTHER TEN MILESTONES. `ttc_milestones.dart` has
                // eleven - first cycle logged, ovulation learned, tests done,
                // lifestyle tracked. A shareable graphic for "cycle 6 logged"
                // would be grotesque, and more to the point most people trying
                // to conceive are deliberately private about it. Offering a
                // card at every milestone would turn a private year into
                // something with a publish button on it.
                //
                // OFFERED, never prompted. Secondary styling, below the primary
                // action, and it does not appear on the way IN to this screen -
                // only after she has already decided to go on. Plenty of people
                // reach a positive test carrying a previous loss and will not
                // want to announce anything for weeks. This waits to be found.
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MemoryPersonalizeScreen(
                            type: MemoryType.expecting),
                        settings:
                            const RouteSettings(name: 'ttc/memory'),
                      ),
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.auto_awesome_outlined,
                            size: 16, color: ttcPurple),
                        const SizedBox(width: 8),
                        // Flexible (2026-09-26): at 360dp the line ran 58pt
                        // past the edge. Found walking the B8 flow in a test.
                        Flexible(
                          child: Text(t.transitionMakeCard,
                              textAlign: TextAlign.center,
                              style: ttcBody(13,
                                  color: ttcPurple, w: FontWeight.w700)),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

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

  /// Into the pregnancy shell. The stage was already flipped by the engine
  /// before this screen was pushed, so there is nothing to write here - this is
  /// purely the app catching up with a decision it has already recorded.
  ///
  /// If no shell is registered we say so rather than doing nothing. She has not
  /// lost anything either way: the due date, the stage and both timeline entries
  /// are on disk, so reopening the app lands her in pregnancy regardless.
  void _toPregnancy(BuildContext context) {
    final t = TtcS.current();
    final messenger = ScaffoldMessenger.of(context);
    if (leaveTtcForPregnancy(Navigator.of(context))) return;
    messenger.showSnackBar(SnackBar(
      content: Text(t.stageSetReopen),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
    ));
  }

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

// =============================================================================
//  A positive test — the page (launch sanity H19, 2026-09-28)
// -----------------------------------------------------------------------------
//  One question before anything moves: did a clinic guide this cycle? The
//  answer decides who dates the pregnancy. On her own (or after an IUI or
//  ovulation tablets) it is her last period, which is ours to count. After a
//  transfer it is the transfer and the embryo's day, the clinic's way
//  (`DueDateSource.ivfTransfer`, clinic-owned, never recounted). A date her
//  clinic told her is theirs (`DueDateSource.clinician`). Every option says
//  its date and its basis in words, a confirm names it again, and the
//  transition screen keeps its Undo. Shaped like the round's own "Moving to
//  Pregnancy" page, so the two ways in read as one flow.
//
//  ⚠️ NO "CONGRATULATIONS", ON PURPOSE. The walk row suggested one; this
//  file's own rule stands (quiet certainty, not confetti: plenty of couples
//  arrive here carrying a previous loss).
// =============================================================================

/// What she said about this cycle.
enum TtcPositivePath { own, transfer }

/// The due date after a transfer, the clinic's way: transfer + (266 − embryo
/// day). The same arithmetic as `ttcRoundDating`, for a transfer she tells us
/// here without having logged a round.
DateTime ttcDueFromTransfer(DateTime transfer, int embryoDay) =>
    DateTime(transfer.year, transfer.month, transfer.day)
        .add(Duration(days: 266 - embryoDay));

class TtcPositiveTestScreen extends StatefulWidget {
  const TtcPositiveTestScreen({super.key});

  @override
  State<TtcPositiveTestScreen> createState() => _TtcPositiveTestScreenState();
}

class _TtcPositiveTestScreenState extends State<TtcPositiveTestScreen> {
  TtcPositivePath? _path;
  DateTime? _transfer;
  int? _embryo;
  bool _busy = false;

  static const double _hue = 152;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  Widget _picker(BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            headerBackgroundColor: Colors.white,
            headerForegroundColor: ttcTitleInk,
            dayBackgroundColor: WidgetStateProperty.resolveWith((s) =>
                s.contains(WidgetState.selected)
                    ? ttcTitleInk
                    : Colors.transparent),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
        ),
        child: child!,
      );

  Future<void> _move(
      DateTime? due, DueDateSource? source, String basis) async {
    final shown = due ??
        TtcTransitionEngine.dueDateFrom(CycleStore.instance.lastPeriodStart ??
            _day(DateTime.now()).subtract(const Duration(days: 28)));
    final ok = await showDialog<bool>(
      context: context,
      routeSettings: const RouteSettings(name: 'ttc/positive_test/confirm'),
      builder: (ctx) => AlertDialog(
        key: const ValueKey('ttc_positive_confirm'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Move to Pregnancy?',
            style: ttcFraunces(19, w: FontWeight.w600, color: ttcTitleInk)),
        content: Text(
            'Your home becomes the pregnancy home, with a due date of '
            '${ttcDueDateText(shown)} ($basis). Everything you wrote here '
            'comes with you. You can undo this on the next screen.',
            style: ttcBody(13.5, h: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Not yet',
                style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
          ),
          TextButton(
            key: const ValueKey('ttc_positive_confirm_yes'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Move to Pregnancy',
                style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted || _busy) return;
    setState(() => _busy = true);
    final result = await const TtcTransitionEngine()
        .confirmPregnancy(dueDate: due, source: source);
    if (!mounted) return;
    // `result: true` so `recordPositiveTest` reports that she went through.
    await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => TtcTransitionScreen(result: result),
          settings: const RouteSettings(name: 'ttc/transition'),
        ),
        result: true);
  }

  Future<void> _pickTransfer() async {
    final today = _day(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: _transfer ?? today.subtract(const Duration(days: 10)),
      firstDate: today.subtract(const Duration(days: 120)),
      lastDate: today,
      helpText: 'Your transfer date',
      fieldHintText: 'dd/mm/yyyy',
      builder: _picker,
    );
    if (d != null && mounted) setState(() => _transfer = _day(d));
  }

  Future<void> _clinicDate() async {
    final today = _day(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 245)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 300)),
      helpText: 'The due date your clinic gave you',
      fieldHintText: 'dd/mm/yyyy',
      builder: _picker,
    );
    if (d == null || !mounted) return;
    await _move(
        _day(d), DueDateSource.clinician, 'the date your clinic gave you');
  }

  @override
  Widget build(BuildContext context) {
    final lmp = CycleStore.instance.lastPeriodStart;
    final ownLine = lmp != null
        ? 'Dated from your last period, ${ttcDueDateText(lmp)}: due '
            '${ttcDueDateText(TtcTransitionEngine.dueDateFrom(lmp))}. The same '
            'after an IUI or ovulation tablets. A dating scan may update it.'
        : 'No period is logged, so we count about four weeks back from today. '
            'Your first scan will correct it.';
    final transferDue = _transfer != null && _embryo != null
        ? ttcDueFromTransfer(_transfer!, _embryo!)
        : null;

    Widget label(String text) => ttcToolPad(Text(text,
        style: pvManrope(
            fontSize: 14, fontWeight: FontWeight.w700, color: ttcTitleInk)));

    return TtcToolScaffold(
      hue: _hue,
      variant: 3,
      eyebrow: 'A positive test',
      title: 'Before anything changes',
      intro: 'Your home will become the pregnancy home. Everything you wrote '
          'here comes with you, and you can undo the move on the next screen. '
          'First, one question, so the dates are right.',
      children: [
        const SizedBox(height: 22),
        label('Was this cycle guided by a clinic?'),
        const SizedBox(height: 12),
        ttcToolPad(TtcRoundOption(
          key: const ValueKey('ttc_positive_own'),
          title: 'No, we were trying on our own',
          line: ownLine,
          icon: Icons.favorite_border_rounded,
          selected: _path == TtcPositivePath.own,
          onTap: () {
            setState(() => _path = TtcPositivePath.own);
            _move(null, null,
                lmp != null ? 'from your last period' : 'about four weeks');
          },
        )),
        const SizedBox(height: 10),
        ttcToolPad(TtcRoundOption(
          key: const ValueKey('ttc_positive_transfer'),
          title: 'Yes, after a transfer (IVF or frozen)',
          line: "Your clinic dates it from the transfer and the embryo's "
              'day. We use their way.',
          icon: Icons.local_hospital_outlined,
          selected: _path == TtcPositivePath.transfer,
          onTap: () => setState(() => _path = TtcPositivePath.transfer),
        )),
        if (_path == TtcPositivePath.transfer) ...[
          const SizedBox(height: 16),
          ttcToolPad(TtcRoundOption(
            key: const ValueKey('ttc_positive_transfer_date'),
            title: _transfer == null
                ? 'Add your transfer date'
                : 'Transfer on ${ttcDueDateText(_transfer!)}',
            line: _transfer == null
                ? 'The day the embryo was put back.'
                : 'Tap to change it.',
            icon: Icons.edit_calendar_outlined,
            onTap: _pickTransfer,
          )),
          const SizedBox(height: 14),
          label('Which day was the embryo when it was transferred?'),
          const SizedBox(height: 10),
          ttcToolPad(Wrap(spacing: 8, children: [
            for (final d in const [3, 5])
              TtcToolPill(
                key: ValueKey('ttc_positive_embryo_$d'),
                label: 'Day $d',
                on: _embryo == d,
                hue: _hue,
                onTap: () => setState(() => _embryo = d),
              ),
          ])),
          if (transferDue != null) ...[
            const SizedBox(height: 14),
            ttcToolPad(TtcRoundOption(
              key: const ValueKey('ttc_positive_from_transfer'),
              title: 'Date it from my transfer',
              line: 'Due ${ttcDueDateText(transferDue)}. Your transfer on '
                  '${ttcDueDateText(_transfer!)}, a day $_embryo embryo, the '
                  'way clinics date it.',
              icon: Icons.event_available_outlined,
              onTap: () => _move(
                  transferDue, DueDateSource.ivfTransfer, 'from your transfer'),
            )),
          ],
        ],
        const SizedBox(height: 10),
        ttcToolPad(TtcRoundOption(
          key: const ValueKey('ttc_positive_clinic_date'),
          title: 'My clinic gave me a due date',
          line: "Enter the date they told you. We'll use theirs.",
          icon: Icons.event_note_outlined,
          onTap: _clinicDate,
        )),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            key: const ValueKey('ttc_positive_not_now'),
            onPressed: () => Navigator.of(context).maybePop(false),
            child: Text('Not yet',
                style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: ttcTitleInk)),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

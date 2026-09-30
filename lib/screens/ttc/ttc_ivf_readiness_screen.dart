// =============================================================================
//  "Should I get help?" — the flow, and the read it ends on
// -----------------------------------------------------------------------------
//  The logic and every rule about what this may say live in
//  `lib/ttc/ttc_ivf_readiness.dart`. Read that header first — particularly the
//  note on why this tool hinges on 35 while the engine hinges on 36.
//
//  ⚠️ CHROME COMES FROM `ttc_tool_chrome.dart`, NOT FROM HERE. Five doors are
//  being rebuilt and every one wires tools; the hero field, the sheet, the
//  numbered question card, the pills and the notes card are shared so five tools
//  cannot end up looking like four different apps. If this screen needs a shape
//  the chrome does not have, add it there rather than inventing a local one.
//
//  ⚠️ ONE SCROLL, NOT A WIZARD. Same call as the PCOS self-read: a stepper hides
//  how much is left, which is what makes a health questionnaire feel like an
//  interrogation. Six short cards, visibly finite, answerable in any order and
//  abandonable without losing anything.
//
//  ⚠️ HER ANSWERS ARE KEPT, AND COME BACK (tool rebuild, 2026-09-27). The six
//  answers used to live only in this screen's state: `writeThrough` saved what
//  the shipped store can hold and the form forgot the rest, so the next visit
//  showed blank questions and seeing her read again meant answering again.
//  They are kept whole in `TtcSelfCheckStore` when she asks for her read, and
//  the next visit opens with a "Your last check" card (the date, "See my
//  answer", "Clear my answers" with Undo) over the questions, filled in.
//  Nothing about who is told to see a doctor, or when, changed: the same
//  answers go into the same `ivfBuildReadiness`.
//
//  Also in this pass: "Pick as many as apply" is now drawn as blocks with
//  ticks (the PCOS hair picker's control, Hers' "Have you ever experienced any
//  of these" list on Mobbin), where it was a ragged wrap of pills with no mark
//  saying several can be chosen; the "What we already know" box under the
//  questions folded into the two notes it explained; the read says "Change my
//  answers"; the notes page copies to the clipboard.
//
//  Mobbin: Hers "Complete treatment questionnaires"
//  https://mobbin.com/flows/60448996-a8dd-4632-9b46-4ab745af1a4e (multi-select
//  with ticks, "none of these" last); Lifesum life score
//  https://mobbin.com/flows/376a68ad-85c8-4071-a09d-bbfe73ce7cf0 (last result
//  on the way in, "Retake the test"); Equinox+ results "Retake"
//  https://mobbin.com/screens/be7ba465-da7b-4941-9054-8e709fb6e45e . Gap
//  analysis: Flo's Symptom Checker "Trying to get pregnant for a year or more
//  · Present · Updated Aug 29 · Review conditions".
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_fertility_help_rules.dart';
import '../../ttc/ttc_fertility_help_store.dart';
import '../../ttc/ttc_ivf_readiness.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_selfcheck_store.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_surface_router.dart';
import 'ttc_tool_chrome.dart';

/// IVF & IUI is 206 on the controlled wheel — a tool opened from that door
/// keeps the door's colour.
///
/// It is also the Tools tab's "Care and medicines" colour
/// (`kTtcToolHueCare`, ttc_tool_hues.dart), the group this check sits in
/// since launch sanity T6 (2026-09-28), so door and Tools agree.
const double kIvfHue = 206;

/// ⚠️ ONE NAME FOR THIS TOOL, EVERYWHERE (launch sanity D18, 2026-09-28).
/// The walk found three on one path: the door card "Should I seek fertility
/// help?", this screen's eyebrow "SEE A SPECIALIST?" and its title "Is it
/// worth talking to someone yet?". The door card's name is the one the stage
/// already uses most (the Taking a while and IVF doors, the journey step,
/// the hub data and the surface list), so the Tools row and this screen take
/// it word for word, and the title below says what the screen does instead
/// of being a fourth name.
const String kTtcFertilityHelpName = 'Should I seek fertility help?';

class TtcIvfReadinessScreen extends StatefulWidget {
  const TtcIvfReadinessScreen({super.key});

  @override
  State<TtcIvfReadinessScreen> createState() => _TtcIvfReadinessScreenState();
}

class _TtcIvfReadinessScreenState extends State<TtcIvfReadinessScreen> {
  // Not final since 2026-09-27: her saved answers replace it when they load.
  // Kept for revert: final _a = IvfReadinessAnswers();
  var _a = IvfReadinessAnswers();

  TtcSelfCheckStore get _saved => TtcSelfCheckStore.instance;

  /// ⚠️ READ FROM THE SHIPPED STORE, NOT REBUILT. `FertilityHelpContext`
  /// already assembles how long she has been trying (`TtcStore`), her cycle
  /// spread (`CycleStore`) and what her PCOS check found. Asking any of that
  /// again would make this the fourth questionnaire in a stage that has three.
  late final FertilityHelpContext _ctx = TtcFertilityHelpStore.instance.context;

  @override
  void initState() {
    super.initState();
    _prefill();
    _saved.load().then((_) {
      if (!mounted) return;
      setState(_restore);
    });
    // Q5's note reads Records (D18, 2026-09-28); redraw once it has loaded.
    TtcRecordsStore.instance.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  /// Her saved answers, over the prefills.
  ///
  /// ⚠️ HER ANSWER WINS, WITH TWO EXCEPTIONS THAT ARE BOTH ABOUT TIME. Her age
  /// is the one saved answer every tool shares (`ctx.ageBand`), so the newest
  /// is used; and "how long have you been trying" moves on its own, so if her
  /// logs now put her in a later band than the one she saved, the later band
  /// shows. Either way the chip stays changeable. A stale "6 to 12 months"
  /// must not hold back the twelve-month rule once she has passed it.
  void _restore() {
    final s = _saved.ivfAnswers;
    if (s == null) return;
    final derivedTrying = _a.trying;
    s.age = _a.age ?? s.age;
    if (s.trying == null ||
        (derivedTrying != null && derivedTrying.index > s.trying!.index)) {
      s.trying = derivedTrying;
    }
    s.cycles ??= _a.cycles;
    _a = s;
  }

  void _see() {
    // ⚠️ SAVED ON THE WAY THROUGH, NOT ON THE WAY IN. Writing each answer as
    // it is tapped would record a half-finished questionnaire and set
    // `hasCompleted` on somebody who abandoned it. The moment she asks what it
    // means is the moment she has finished.
    //
    // Fire-and-forget: the push must not wait on shared_preferences, and a
    // failed local write is not a reason to withhold her result.
    _a.writeThrough(TtcFertilityHelpStore.instance);
    _saved.saveIvf(_a);
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc/ivf_readiness_result'),
      builder: (_) =>
          TtcIvfReadinessResultScreen(result: ivfBuildReadiness(_a, _ctx)),
    ));
  }

  /// "Clear my answers": back to what the app can fill in, with Undo.
  Future<void> _clear() async {
    final was = await _saved.clearIvf();
    if (!mounted) return;
    setState(() {
      _a = IvfReadinessAnswers();
      _prefill();
    });
    pvSnack(context, 'Your answers are cleared.',
        action: 'Undo',
        lift: 24,
        onAction: () async {
          await _saved.restoreIvf(was);
          if (mounted) setState(_restore);
        });
  }

  /// What the app can fill in from her logs and her saved age.
  void _prefill() {
    // ⚠️ TWO PREFILLS, AND BOTH ARE CONFIRMATIONS RATHER THAN ASSUMPTIONS. The
    // chips are selected and changeable: a prefill she cannot override is a
    // claim, not a convenience — and on a screen that routes to a specialist,
    // a wrong claim she never saw is the worst outcome available.
    _a.cycles = ivfSuggestedCycles(_ctx);
    _a.trying = _tryingFromLogs();
    // ⚠️ A THIRD PREFILL: HER AGE, IF SHE HAS GIVEN IT ANYWHERE (2026-09-26,
    // consistency pass). The help tool, the "Trying after 35" read and this
    // flow all write the one saved answer, and this was the only one of the
    // three that asked again from blank, so the same woman could be "38 to
    // 40" on the IVF door's tab order and unanswered here. Selected and
    // changeable, like the two above.
    _a.age = _ctx.ageBand;
  }

  /// How long she has been trying, from `TtcStore`, mapped onto the bands.
  ///
  /// ⚠️ THE BANDS ROUND DOWN AT EVERY EDGE, deliberately. Someone at 11.9
  /// months lands in "6 to 12", not "more than a year", because rounding up
  /// would fire the twelve-month rule on someone who has not reached it. Where
  /// this tool is unsure it leans toward the conversation — but it does not
  /// invent a month she has not lived.
  IvfTrying? _tryingFromLogs() {
    final m = _ctx.monthsTrying;
    if (m == null) return null;
    if (m >= 24) return IvfTrying.overTwoYears;
    if (m >= 12) return IvfTrying.overAYear;
    if (m >= 6) return IvfTrying.sixToTwelve;
    return IvfTrying.underSix;
  }

  /// His latest semen test in Records, if there is one: the semen report
  /// tool saves it under the `semen` test, and a hand-typed row names it.
  TtcRecord? get _semenRecord {
    for (final r in TtcRecordsStore.instance.records) {
      if (r.testId == 'semen' || r.label.toLowerCase().contains('semen')) {
        return r;
      }
    }
    return null;
  }

  String? _semenRecordNote() {
    final r = _semenRecord;
    if (r == null) return null;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = r.takenOn;
    return 'Your records hold his semen test from ${d.day} '
        '${months[d.month - 1]} ${d.year}. Pick what his doctor said '
        'about it.';
  }

  void _set(VoidCallback f) => setState(f);

  int get _answered => [
        _a.age,
        _a.trying,
        _a.cycles,
        _a.conditionsChecked ? true : null,
        _a.semen,
        _a.check,
      ].where((v) => v != null).length;

  @override
  Widget build(BuildContext context) {
    // Only the "What we already know" box read this; kept for revert:
    // final derived = _ctx.monthsTrying != null || _ctx.hasEnoughCycleData;

    return TtcToolScaffold(
      hue: kIvfHue,
      // The tool's mark over the eyebrow (2026-09-29, ttc_tool_marks.dart).
      toolId: 'fertility_help',
      // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the Tools tile's name, word for
      // word. Kept for revert: eyebrow: 'Should I get help?',
      // D18 (2026-09-28): the one name, and a title that describes rather
      // than renames. Kept for revert (2026-09-28):
      //   eyebrow: 'See a specialist?',
      //   title: 'Is it worth talking\nto someone yet?',
      eyebrow: kTtcFertilityHelpName,
      title: 'Six questions,\nthen a plain answer.',
      // ⚠️ THE SKIP IS SAID UP FRONT (tools pass, 2026-09-27). A few of these
      // are personal (a miscarriage, his test), and "you can leave any blank"
      // used to sit under the button, after she had met them. Kept for
      // revert: "Six short questions. There's no score and no verdict. This
      // only tells you whether it's worth talking to someone. Only a
      // specialist can tell you more."
      intro: "Six short questions to see if it's time to talk to a fertility "
          "doctor. A few are personal. Skip any you'd rather not answer. "
          "There's no score and no verdict.",
      children: [
        const SizedBox(height: 22),

        // ⚠️ HER LAST CHECK, FIRST (2026-09-27). See the file header.
        if (_saved.ivfAt case final at?) ...[
          ttcToolPad(TtcToolLastCheck(
            key: const ValueKey('ttc_ivf_last'),
            at: at,
            line: 'Your answers are filled in below. Change anything '
                "that's different, then see your answer again.",
            seeLabel: 'See my answer',
            onSee: _see,
            againLabel: 'Clear my answers',
            onAgain: _clear,
          )),
          const SizedBox(height: 18),
        ],

        ttcToolPad(TtcToolProgress(done: _answered, total: 6)),
        const SizedBox(height: 18),

        ttcToolPad(TtcToolQuestion(
          n: 1,
          hue: kIvfHue,
          title: 'How old are you?',
          // ⚠️ WHY WE ASK, SAID PLAINLY. Age is the most personal question here
          // and the one most likely to feel like being judged. Saying what it
          // is for, in the same breath, is the difference between a question
          // and an interrogation.
          // D18 (2026-09-28): says where a prefilled age came from. Her age
          // is one saved answer shared by this check, the IVF door and the
          // "Trying after 35" read (`TtcFertilityHelpStore.ageBand`).
          note: '${_ctx.ageBand != null && _a.age == _ctx.ageBand ? 'Filled in from your earlier answer. ' : ''}'
              "Your age only changes how soon it's worth talking to "
              'someone. Nothing else here depends on it.',
          child: TtcToolChoice<FertilityAgeBand>(
            value: _a.age,
            hue: kIvfHue,
            options: {
              for (final v in FertilityAgeBand.values) v: v.label.en
            },
            onTap: (v) => _set(() => _a.age = v),
          ),
        )),

        ttcToolPad(TtcToolQuestion(
          n: 2,
          hue: kIvfHue,
          title: 'How long have you been trying?',
          note: _tryingFromLogs() == null
              ? null
              : "Filled in from what you've logged. Change it if that looks "
                  'wrong.',
          child: TtcToolChoice<IvfTrying>(
            value: _a.trying,
            hue: kIvfHue,
            options: {for (final v in IvfTrying.values) v: v.label},
            onTap: (v) => _set(() => _a.trying = v),
          ),
        )),

        ttcToolPad(TtcToolQuestion(
          n: 3,
          hue: kIvfHue,
          title: 'What are your cycles like?',
          // The logged range moved here from the "What we already know" box
          // under the questions (2026-09-27), next to the answer it explains.
          // Kept for revert: 'Filled in from your logged dates. Change it if
          // that looks wrong.'
          // D18 (2026-09-28): with one cycle logged it says what the app
          // has and why that is not yet a pattern, rather than asking as if
          // it knew nothing. Two or more still fill the answer in.
          note: ivfSuggestedCycles(_ctx) != null
              ? 'Filled in from your ${_ctx.cyclesLogged} logged cycles, '
                  '${_ctx.cycleShortest} to ${_ctx.cycleLongest} days long. '
                  'Change it if that looks wrong.'
              : _ctx.cyclesLogged == 1
                  ? 'You have one cycle logged so far, '
                      '${_ctx.cycleShortest} days long. One cycle cannot '
                      "show a pattern yet, so this one is yours to answer."
                  : null,
          child: TtcToolChoice<IvfCycles>(
            value: _a.cycles,
            hue: kIvfHue,
            options: {for (final v in IvfCycles.values) v: v.label},
            onTap: (v) => _set(() => _a.cycles = v),
          ),
        )),

        ttcToolPad(TtcToolQuestion(
          n: 4,
          hue: kIvfHue,
          title: 'Has a doctor already told you about any of these?',
          // Kept for revert: 'Tap anything that applies.' It was easy to miss
          // that more than one can be picked (tools pass, 2026-09-27).
          note: "Pick as many as apply. Skip it if you'd rather not say.",
          child: _Conditions(
            selected: _a.conditions,
            checked: _a.conditionsChecked,
            unsure: _a.conditionsUnsure,
            onToggle: (id) => _set(() {
              _a.conditionsChecked = true;
              _a.conditionsUnsure = false;
              _a.conditions.contains(id)
                  ? _a.conditions.remove(id)
                  : _a.conditions.add(id);
            }),
            // ⚠️ "NONE" AND "NOT SURE" TAP OFF AGAIN (2026-09-27), like every
            // other answer in the stage's tools: a ticked block that cannot be
            // unticked breaks the promise the tick makes. Tapped while already
            // the answer, each clears the question. Kept for revert: both
            // always set `conditionsChecked = true`.
            onNone: () => _set(() {
              final wasNone = _a.conditionsChecked &&
                  !_a.conditionsUnsure &&
                  _a.conditions.isEmpty;
              _a.conditionsChecked = !wasNone;
              _a.conditionsUnsure = false;
              _a.conditions.clear();
            }),
            onUnsure: () => _set(() {
              final wasUnsure = _a.conditionsUnsure;
              _a.conditionsChecked = !wasUnsure;
              _a.conditionsUnsure = !wasUnsure;
              _a.conditions.clear();
            }),
          ),
        )),

        ttcToolPad(TtcToolQuestion(
          n: 5,
          hue: kIvfHue,
          // Kept for revert: 'Has he had a semen test?' (tools pass,
          // 2026-09-27: names who, in one read).
          title: 'Has your partner had a semen test?',
          // ⚠️ THIS QUESTION IS THE ONE THE SHIPPED FLOW DID NOT ASK, and it is
          // about half the answer. A tool that investigates only her is a tool
          // that can send a couple down a year of the wrong road.
          // D18 (2026-09-28): when Records holds his test, say so and ask
          // only what the app cannot know (what his doctor made of it). The
          // app never rates a semen report (ttc_semen_reading.dart: no
          // verdict), so it does not pick "normal" or "an issue" for her.
          // Kept for revert: the "His side is part of the picture" line on
          // its own.
          note: _semenRecordNote() ??
              'His side is part of the picture in about half of all cases. '
                  'The test is quick and not expensive.',
          child: TtcToolChoice<IvfSemen>(
            value: _a.semen,
            hue: kIvfHue,
            options: {for (final v in IvfSemen.values) v: v.label},
            onTap: (v) => _set(() => _a.semen = v),
          ),
        )),

        ttcToolPad(TtcToolQuestion(
          n: 6,
          hue: kIvfHue,
          title: 'Have you had a fertility check before?',
          child: TtcToolChoice<IvfCheck>(
            value: _a.check,
            hue: kIvfHue,
            options: {for (final v in IvfCheck.values) v: v.label},
            onTap: (v) => _set(() => _a.check = v),
          ),
        )),

        const SizedBox(height: 6),
        // ⚠️ COMMENTED OUT 2026-09-27 (tool rebuild, simplicity): under the
        // questions it explained two prefills after she had met them, and each
        // of those questions already says "Filled in from…" (Q3 now with the
        // logged range). The PCOS check dropped its twin the same day. Kept for
        // revert, with its history:
        // ⚠️ MOVED BELOW THE QUESTIONS ON 2026-09-03, ON REQUEST. It used to
        // open the screen, and opening a six-question tool with a paragraph
        // about what the app already knows delays the first question for
        // everybody in order to explain two pre-selected chips.
        //
        // Nothing is lost by the move: questions 2 and 3 each carry their own
        // "Filled in from your journey — change it if that looks wrong" note,
        // which is where that explanation actually belongs. Down here the block
        // does the other job it was always doing — showing her that the answers
        // she gave sit on top of a history the app kept, rather than in a void.
        // if (derived) ...[
        //   ttcToolPad(_FromYourLogs(ctx: _ctx)),
        //   const SizedBox(height: 20),
        // ],
        const SizedBox(height: 8),

        ttcToolPad(TtcToolPrimary(
          key: const ValueKey('ttc_ivf_see'),
          // Says what she gets. Kept for revert: 'See what this means'.
          label: "See if it's time to talk to someone",
          // The write-through, the save and the push are `_see` now
          // (2026-09-27), shared with the last-check card.
          onTap: _see,
        )),
        const SizedBox(height: 14),
        ttcToolPad(Builder(builder: (context) {
          final p = V2PaletteStore.instance.current;
          // The skip moved up into the intro (2026-09-27). Kept for revert:
          // "You can leave any of these blank. When it's unsure, ..."
          return Text(
              "When it's unsure, this check leans towards talking to someone, "
              'not away from it. Your answers are kept for next time.',
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3));
        })),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// What the app already knows, shown before the first question.
// Unreached since 2026-09-27 (see the note where it rendered); kept for revert.
// ignore: unused_element
class _FromYourLogs extends StatelessWidget {
  const _FromYourLogs({required this.ctx});

  final FertilityHelpContext ctx;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final lines = <String>[
      if (ctx.tryingLabel != null)
        'You\'ve been trying for ${ctx.tryingLabel!.en}.',
      if (ctx.hasEnoughCycleData)
        'You\'ve logged ${ctx.cyclesLogged} cycles, lasting '
            '${ctx.cycleShortest} to ${ctx.cycleLongest} days.',
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: v2BlockTint(kIvfHue, p),
        borderRadius: BorderRadius.circular(ttcCardRadius),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('WHAT WE ALREADY KNOW',
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: p.ink2)),
        const SizedBox(height: 8),
        for (final l in lines) ...[
          Text(l,
              style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink1)),
          const SizedBox(height: 4),
        ],
      ]),
    );
  }
}

/// Multi-select conditions, plus explicit "none" and "not sure".
///
/// ⚠️ "NOT SURE" IS A DISTINCT ANSWER FROM "NONE", and conflating them is the
/// mistake that would matter most on this screen. "None of these" is
/// information; "not sure" is the absence of it — and the routing treats the
/// second as a reason to lean toward the conversation. One chip for each.
class _Conditions extends StatelessWidget {
  const _Conditions({
    required this.selected,
    required this.checked,
    required this.unsure,
    required this.onToggle,
    required this.onNone,
    required this.onUnsure,
  });

  final Set<String> selected;
  final bool checked;
  final bool unsure;
  final ValueChanged<String> onToggle;
  final VoidCallback onNone;
  final VoidCallback onUnsure;

  // ⚠️ BLOCKS WITH TICKS, NOT A WRAP OF PILLS (tool rebuild, 2026-09-27). The
  // one question here that takes several answers looked exactly like the five
  // that take one, and "Pick as many as apply" was the only sign. The tool
  // chrome's own rule: a tick is the promise that more than one may be chosen,
  // and this is the question that keeps it (the PCOS hair picker is the
  // other). The wrap also left the ragged right edge the shared control was
  // built to remove. Mobbin: Hers "Have you ever experienced any of these
  // symptoms?" (ticks, "No, I have not…" last).
  // Kept for revert: a Wrap(spacing: 8, runSpacing: 8) of TtcToolPill, one
  // per condition, then 'None of these' and 'Not sure'.
  @override
  Widget build(BuildContext context) => TtcToolOptions(
        p: V2PaletteStore.instance.current,
        hue: kIvfHue,
        items: [
          for (final c in kIvfKnownConditions)
            TtcToolOption(
                label: c.label,
                on: selected.contains(c.id),
                onTap: () => onToggle(c.id),
                tick: true),
          TtcToolOption(
              label: 'None of these',
              on: checked && !unsure && selected.isEmpty,
              onTap: onNone,
              tick: true),
          TtcToolOption(
              label: 'Not sure',
              on: unsure,
              onTap: onUnsure,
              tick: true),
        ],
      );
}

// -----------------------------------------------------------------------------
//  The read
// -----------------------------------------------------------------------------

class TtcIvfReadinessResultScreen extends StatelessWidget {
  const TtcIvfReadinessResultScreen({super.key, required this.result});

  final IvfReadinessResult result;

  @override
  Widget build(BuildContext context) {
    final push = result.verdict.pushesToSpecialist;

    return TtcToolScaffold(
      hue: kIvfHue,
      variant: 3,
      // Step two of the check: back to her answers, not an X (2026-09-29).
      leading: TtcToolLeading.back,
      // One tool, one name (2026-09-27). Kept for revert: 'Your answer'.
      // D18 (2026-09-28). Kept for revert: eyebrow: 'See a specialist?',
      eyebrow: kTtcFertilityHelpName,
      // ⚠️ THE TITLE DESCRIBES WHAT SHE IS HOLDING, NOT WHAT SHE IS. This is
      // where a "you may be infertile" would go on a worse version of this
      // screen, and it is the first place the eye lands.
      // Kept for revert (2026-09-28): 'What this adds up to.'
      title: 'What your answers add up to.',
      intro: "No score and no label. Just where you are, and what's worth "
          'doing about it.',
      children: [
        const SizedBox(height: 24),

        ttcToolPad(const TtcToolBlockHead(
            label: 'Where you are', hue: 206)),
        const SizedBox(height: 10),
        ttcToolPad(TtcToolBlock(text: result.where, hue: 206)),

        const SizedBox(height: 26),
        ttcToolPad(const TtcToolBlockHead(
            // Kept for revert (2026-09-28): 'What this means for timing'
            label: 'What your answers mean for timing', hue: 42)),
        const SizedBox(height: 10),
        // The one line from the routing rules. Outlined on every branch that
        // pushes toward a specialist — the whole escalation vocabulary.
        ttcToolPad(TtcToolBlock(
            text: result.timing, hue: 42, outlined: push)),

        const SizedBox(height: 26),
        ttcToolPad(const TtcToolBlockHead(
            label: 'What to do next', hue: 160)),
        const SizedBox(height: 10),
        ttcToolPad(TtcToolBlock(text: result.openDoor, hue: 160)),

        const SizedBox(height: 18),

        // ⚠️ THE MAIN ACTION FLIPS WITH THE VERDICT, and that is the point of
        // the whole tool. Told to keep trying, the useful next screen is the
        // fertile window — because the honest advice is "use this cycle well",
        // not "come back and read about IVF". Told a conversation is worth
        // having, the specialist is the main action and everything else is
        // secondary.
        // ⚠️ THE FREE STEP LEADS, THE PAID ONE FOLLOWS (tools pass,
        // 2026-09-27). The notes are hers whoever she sees, her own doctor
        // included; a consult is one way to use them. Kept for revert: the
        // specialist was the primary pill and the notes the secondary.
        if (push) ...[
          ttcToolPad(TtcToolPrimary(
            label: 'What to take with you',
            onTap: () => _openNotes(context, result),
          )),
          const SizedBox(height: 10),
          ttcToolPad(TtcToolSecondary(
            label: 'Book a fertility specialist',
            onTap: () => _openConsults(context),
          )),
        ] else ...[
          ttcToolPad(TtcToolPrimary(
            // Change 5 (2026-09-28): the button names where it lands.
            // Kept for revert: 'Make the most of this cycle'.
            label: 'See your fertile window',
            onTap: () => openTtcSurface(context, 'ttc_window'),
          )),
          const SizedBox(height: 10),
          // ⚠️ QUIET, BUT PRESENT. The spec asks for the door to stay open on
          // the reassuring branch too: someone told to keep trying who still
          // wants to talk to a person must not have to redo the questionnaire
          // to find the button.
          ttcToolPad(TtcToolSecondary(
            label: 'Book a chat anyway',
            onTap: () => _openConsults(context),
          )),
        ],

        // ⚠️ THE WAY BACK TO HER ANSWERS, SAID (2026-09-27). The close
        // button did it, but "close" reads as leaving the tool.
        const SizedBox(height: 6),
        Center(
          child: TextButton(
            key: const ValueKey('ttc_ivf_change'),
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text('Change my answers',
                style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: V2PaletteStore.instance.current.ink2)),
          ),
        ),

        const SizedBox(height: 16),
        ttcToolPad(const TtcToolPrivacyLine()),
        const SizedBox(height: 26),
      ],
    );
  }
}

/// ⚠️ THE SAME NAME AS THE PCOS ONE, AND THAT IS THE POINT — 2026-09-03.
///
/// These two screens do one job: turn what she just answered into four or six
/// lines she can screenshot and hold up. They were called "What to take to your
/// doctor" and "What to bring to that conversation", which is two names for one
/// thing — and a person who meets both learns the app has two features here
/// when it has one.
///
/// **"What to take with you"** is the wording both now use, and it is neither
/// of the originals on purpose. "To your doctor" presumes she has one, which is
/// exactly what the IVF readiness tool exists to establish she may not; "that
/// conversation" is an abstraction, and the thing she is actually doing is
/// taking a page into a room.
///
/// Both screens also now render the SAME card — `TtcToolNotesCard` — rather
/// than two copies of it. See the note in `ttc_pcos_stand_screen.dart`.
class TtcIvfNotesScreen extends StatelessWidget {
  const TtcIvfNotesScreen({super.key, required this.result});

  final IvfReadinessResult result;

  @override
  Widget build(BuildContext context) => TtcToolScaffold(
        hue: kIvfHue,
        variant: 4,
        // Step three: back to the answer it came from (2026-09-29).
        leading: TtcToolLeading.back,
        // One tool, one name (2026-09-27). Kept for revert:
        // eyebrow: 'Appointment notes',
        // D18 (2026-09-28). Kept for revert: eyebrow: 'See a specialist?',
        eyebrow: kTtcFertilityHelpName,
        title: 'What to take\nwith you.',
        // Copy is offered now (2026-09-27). Kept for revert: "Take a
        // screenshot, or read it out. It's six lines, all from your answers."
        intro: 'Copy them into a message, take a screenshot, or read them '
            "out. It's six lines, all from your answers.",
        children: [
          const SizedBox(height: 24),
          ttcToolPad(TtcToolNotesCard(
              rows: result.checklist, disclaimer: kIvfChecklistDisclaimer)),
          const SizedBox(height: 18),
          ttcToolPad(TtcToolCopyNotes(
              // D18 (2026-09-28). Kept for revert: 'My notes: see a specialist?'
              heading: 'My notes: should I seek fertility help?',
              rows: result.checklist,
              disclaimer: kIvfChecklistDisclaimer)),
          const SizedBox(height: 10),
          // Secondary, not primary (2026-09-27): the page is her notes, and
          // the paid step is one option for using them.
          ttcToolPad(TtcToolSecondary(
            label: 'Book a fertility specialist',
            onTap: () => _openConsults(context),
          )),
          const SizedBox(height: 22),
          ttcToolPad(const TtcToolPrivacyLine()),
          const SizedBox(height: 26),
        ],
      );
}

void _openNotes(BuildContext context, IvfReadinessResult r) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc/ivf_notes'),
      builder: (_) => TtcIvfNotesScreen(result: r),
    ));

/// ⚠️ NOT `openTtcSurface('ttc_consults')` — there is no such surface, and the
/// router returns null for an unknown id, so the button would do nothing
/// silently. Consults are a Prepare category; this is the same push the V3 nav's
/// own consult tab makes.
void _openConsults(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc/consults'),
      builder: (_) => const TtcPrepareScreen(onlyCategory: 'consults'),
    ));

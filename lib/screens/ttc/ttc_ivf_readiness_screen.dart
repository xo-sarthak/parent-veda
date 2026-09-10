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
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_fertility_help_rules.dart';
import '../../ttc/ttc_fertility_help_store.dart';
import '../../ttc/ttc_ivf_readiness.dart';
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_surface_router.dart';
import 'ttc_tool_chrome.dart';

/// IVF & IUI is 206 on the controlled wheel — a tool opened from that door
/// keeps the door's colour.
const double kIvfHue = 206;

class TtcIvfReadinessScreen extends StatefulWidget {
  const TtcIvfReadinessScreen({super.key});

  @override
  State<TtcIvfReadinessScreen> createState() => _TtcIvfReadinessScreenState();
}

class _TtcIvfReadinessScreenState extends State<TtcIvfReadinessScreen> {
  final _a = IvfReadinessAnswers();

  /// ⚠️ READ FROM THE SHIPPED STORE, NOT REBUILT. `FertilityHelpContext`
  /// already assembles how long she has been trying (`TtcStore`), her cycle
  /// spread (`CycleStore`) and what her PCOS check found. Asking any of that
  /// again would make this the fourth questionnaire in a stage that has three.
  late final FertilityHelpContext _ctx = TtcFertilityHelpStore.instance.context;

  @override
  void initState() {
    super.initState();
    // ⚠️ TWO PREFILLS, AND BOTH ARE CONFIRMATIONS RATHER THAN ASSUMPTIONS. The
    // chips are selected and changeable: a prefill she cannot override is a
    // claim, not a convenience — and on a screen that routes to a specialist,
    // a wrong claim she never saw is the worst outcome available.
    _a.cycles = ivfSuggestedCycles(_ctx);
    _a.trying = _tryingFromLogs();
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
    final derived = _ctx.monthsTrying != null || _ctx.hasEnoughCycleData;

    return TtcToolScaffold(
      hue: kIvfHue,
      eyebrow: 'Should I get help?',
      title: 'Is it worth talking\nto someone yet?',
      intro: 'Six short questions. No score and no verdict — this only says '
          'whether a conversation is worth having, and a specialist is the '
          'only one who can say more.',
      children: [
        const SizedBox(height: 22),

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
          note: 'Age changes how soon a conversation is useful, and nothing '
              'else on this screen.',
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
              : 'Filled in from your journey. Change it if that looks wrong.',
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
          note: ivfSuggestedCycles(_ctx) == null
              ? null
              : 'Filled in from your logged dates. Change it if that looks '
                  'wrong.',
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
          title: 'Has anything already been mentioned to you?',
          note: 'Tap anything that applies.',
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
            onNone: () => _set(() {
              _a.conditionsChecked = true;
              _a.conditionsUnsure = false;
              _a.conditions.clear();
            }),
            onUnsure: () => _set(() {
              _a.conditionsChecked = true;
              _a.conditionsUnsure = true;
              _a.conditions.clear();
            }),
          ),
        )),

        ttcToolPad(TtcToolQuestion(
          n: 5,
          hue: kIvfHue,
          title: 'Has he had a semen test?',
          // ⚠️ THIS QUESTION IS THE ONE THE SHIPPED FLOW DID NOT ASK, and it is
          // about half the answer. A tool that investigates only her is a tool
          // that can send a couple down a year of the wrong road.
          note: 'Male factor is about half of all cases. The test is quick and '
              'inexpensive.',
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
        if (derived) ...[
          ttcToolPad(_FromYourLogs(ctx: _ctx)),
          const SizedBox(height: 20),
        ],

        ttcToolPad(TtcToolPrimary(
          label: 'See what this means',
          // ⚠️ SAVED ON THE WAY THROUGH, NOT ON THE WAY IN. Writing each answer
          // as it is tapped would record a half-finished questionnaire and set
          // `hasCompleted` on somebody who abandoned it. The moment she asks
          // what it means is the moment she has finished.
          //
          // Fire-and-forget: the push must not wait on shared_preferences, and
          // a failed local write is not a reason to withhold her result. Same
          // trade the rest of this stage makes.
          onTap: () {
            _a.writeThrough(TtcFertilityHelpStore.instance);
            Navigator.of(context).push(MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'ttc/ivf_readiness_result'),
              builder: (_) => TtcIvfReadinessResultScreen(
                  result: ivfBuildReadiness(_a, _ctx)),
            ));
          },
        )),
        const SizedBox(height: 14),
        ttcToolPad(Builder(builder: (context) {
          final p = V2PaletteStore.instance.current;
          return Text(
              'You can leave any of these blank. Where this is unsure, it '
              'points you toward a conversation rather than away from one.',
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3));
        })),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// What the app already knows, shown before the first question.
class _FromYourLogs extends StatelessWidget {
  const _FromYourLogs({required this.ctx});

  final FertilityHelpContext ctx;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final lines = <String>[
      if (ctx.tryingLabel != null)
        'You have been trying ${ctx.tryingLabel!.en}.',
      if (ctx.hasEnoughCycleData)
        'You have ${ctx.cyclesLogged} logged cycles, running '
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
        Text('WHAT WE ALREADY HAVE',
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

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in kIvfKnownConditions)
            TtcToolPill(
                label: c.label,
                on: selected.contains(c.id),
                onTap: () => onToggle(c.id),
                hue: kIvfHue),
          TtcToolPill(
              label: 'None of these',
              on: checked && !unsure && selected.isEmpty,
              onTap: onNone,
              hue: kIvfHue),
          TtcToolPill(
              label: 'Not sure',
              on: unsure,
              onTap: onUnsure,
              hue: kIvfHue),
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
      eyebrow: 'Your read',
      // ⚠️ THE TITLE DESCRIBES WHAT SHE IS HOLDING, NOT WHAT SHE IS. This is
      // where a "you may be infertile" would go on a worse version of this
      // screen, and it is the first place the eye lands.
      title: 'What this adds up to.',
      intro: 'No score, no label. One read of where you are, and what is worth '
          'doing about it.',
      children: [
        const SizedBox(height: 24),

        ttcToolPad(const TtcToolBlockHead(
            label: 'Where you are', hue: 206)),
        const SizedBox(height: 10),
        ttcToolPad(TtcToolBlock(text: result.where, hue: 206)),

        const SizedBox(height: 26),
        ttcToolPad(const TtcToolBlockHead(
            label: 'What this means for timing', hue: 42)),
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
        if (push) ...[
          ttcToolPad(TtcToolPrimary(
            label: 'Speak to a fertility specialist',
            onTap: () => _openConsults(context),
          )),
          const SizedBox(height: 10),
          ttcToolPad(TtcToolSecondary(
            label: 'What to take with you',
            onTap: () => _openNotes(context, result),
          )),
        ] else ...[
          ttcToolPad(TtcToolPrimary(
            label: 'Make the most of this cycle',
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

        const SizedBox(height: 22),
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
        eyebrow: 'Appointment notes',
        title: 'What to take\nwith you.',
        intro: 'Screenshot this, or read it out. Six lines, all of them yours.',
        children: [
          const SizedBox(height: 24),
          ttcToolPad(TtcToolNotesCard(
              rows: result.checklist, disclaimer: kIvfChecklistDisclaimer)),
          const SizedBox(height: 18),
          ttcToolPad(TtcToolPrimary(
            label: 'Speak to a fertility specialist',
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

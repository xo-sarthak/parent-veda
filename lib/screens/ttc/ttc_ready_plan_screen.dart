// =============================================================================
//  Ready-to-Try plan — the questions, and the plan they make
// -----------------------------------------------------------------------------
//  The logic lives in `lib/ttc/ttc_ready_plan.dart`; read its header first for
//  what this plan may and may not say. This file only draws it.
//
//  ⚠️ ONE ROUTE, TWO MODES. Questions when there is no plan yet (or she asks
//  to change her answers), the plan when there is one. Two screens would give
//  the tool two route names, and `global_ask_fab.dart` reads the route name to
//  decide which Ask Veda opens; one surface id, `ttc_ready_plan`, means one
//  answer to "where is she".
//
//  ⚠️ ONE SCROLL, NOT A WIZARD. The house rule for every TTC questionnaire
//  (`ttc_ivf_readiness_screen.dart`, the PCOS self-read): a stepper hides how
//  much is left, which is what makes a health questionnaire feel like an
//  interrogation. Mobbin's plan quizzes (Noom, Lifesum, Liven) go one
//  question per screen; we keep their parts (the progress line, the "what this
//  changes" note under a question, ticks only where several answers fit) and
//  our own shape.
//
//  ⚠️ SHE NEVER WAITS FOR HIM. His two questions sit at the end, are optional,
//  and "Add his part" on the plan brings them back any time. Until he answers,
//  his section is the general version and says so.
//
//  Mobbin, what was taken and what was refused:
//    · Lifesum "Plan test", one question per card with a numbered chip:
//      https://mobbin.com/flows/b162aad4-2314-42c2-9f18-e674d62fb299
//    · Liven, the "You're not alone" note under an answer:
//      https://mobbin.com/flows/5695ec7e-a531-4d04-8381-746e3591db36
//    · Clue, conditions with "Prefer not to share":
//      https://mobbin.com/screens/fd05d512-979f-4011-bb15-0d66425a1cf8
//    · Strava, a goal date with "we'll add a countdown":
//      https://mobbin.com/screens/12ccfe2f-906e-475d-82d8-ac515c6eaadd
//    · Rocket Money results, grouped cards that each go somewhere:
//      https://mobbin.com/screens/a5d153d6-fb60-4e2c-a1ab-814d20b19d85
//    · Crypto.com event timeline, ticked stations down a line:
//      https://mobbin.com/screens/9babb181-0234-4bdb-b14c-97e740529921
//    · REFUSED: Noom's and Flo's "Creating your plan… 29%" loader (the plan
//      is computed instantly; a fake wait is theatre), Liven's signed
//      commitment and logo wall, and Noom's expiring-plan timer.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_fertility_help_rules.dart'
    show FertilityAgeBand, FertilityAgeBandCopy;
import '../../ttc/ttc_fertility_help_store.dart';
import '../../ttc/ttc_meal_week_data.dart';
import '../../ttc/ttc_precheck_data.dart';
import '../../ttc/ttc_precheck_rules.dart';
import '../../ttc/ttc_precheck_store.dart';
import '../../ttc/ttc_ready_plan.dart';
import '../../ttc/ttc_ready_plan_regions.dart';
import '../../ttc/ttc_ready_plan_store.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'doors/ttc_tab_art.dart' show TtcTabMark;
import 'ttc_common.dart';
import 'ttc_precheck_parts.dart';
import 'ttc_precheck_summary.dart';
import 'ttc_surface_router.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_tool_hues.dart';
import 'ttc_tool_marks.dart';

/// One tool, one name: the door tile, the eyebrow and the notes all say this.
const String kReadyPlanName = 'Your Ready-to-Try plan';

/// Getting ready's colour, and the Tools group "Plan and check".
const double _hue = kTtcToolHuePlan;

class TtcReadyPlanScreen extends StatefulWidget {
  const TtcReadyPlanScreen({super.key});

  @override
  State<TtcReadyPlanScreen> createState() => _TtcReadyPlanScreenState();
}

class _TtcReadyPlanScreenState extends State<TtcReadyPlanScreen> {
  TtcReadyPlanStore get _store => TtcReadyPlanStore.instance;

  bool _ready = false;
  bool _editing = true;
  ReadyPlanAnswers _a = ReadyPlanAnswers();

  final GlobalKey _hisKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.wait([
      _store.load(),
      TtcPrecheckStore.instance.load(),
      TtcFertilityHelpStore.instance.load(),
    ]).then((_) {
      if (!mounted) return;
      setState(() {
        _ready = true;
        _editing = _store.planFor(DateTime.now()) == null;
        _a = _store.prefilled();
      });
    });
  }

  void _set(VoidCallback f) => setState(f);

  /// "Change my answers", or "Add his part" (which lands on his questions).
  void _edit({bool his = false}) {
    setState(() {
      _a = _store.prefilled();
      _editing = true;
    });
    if (!his) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _hisKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.05,
        );
      }
    });
  }

  Future<void> _see() async {
    if (_a.alreadyTrying) {
      // Remembered, so the question comes back answered; then the checklist,
      // which is the better fit for someone already trying.
      await _store.save(_a);
      if (!mounted) return;
      final screen = ttcScreenForSurface('ttc_precheck');
      if (screen == null) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc_precheck'),
          builder: (_) => screen,
        ),
      );
      return;
    }
    if (_a.target == null) {
      pvSnack(context, 'Pick a month first. Any month is fine.', lift: 24);
      return;
    }
    await _store.save(_a);
    if (!mounted) return;
    setState(() => _editing = false);
    // ⚠️ THE SAVE SAYS WHAT IT CHANGED (the app explains itself): her age,
    // diet and folic acid answer were written to the tools that own them.
    pvSnack(
      context,
      'Plan saved. Your answers also updated your checklist and food ideas.',
      lift: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _store,
        TtcPrecheckStore.instance,
        V2PaletteStore.instance,
      ]),
      builder: (context, _) {
        if (!_ready) {
          return const TtcToolScaffold(
            hue: _hue,
            eyebrow: kReadyPlanName,
            title: '',
            children: [SizedBox(height: 200)],
          );
        }
        final plan = _store.planFor(DateTime.now());
        // Editing over an existing plan: Back returns to the plan, not out of
        // the tool. One path for the button, the gesture and the swipe.
        return PopScope(
          canPop: !(_editing && plan != null),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) setState(() => _editing = false);
          },
          child: _editing || plan == null ? _intake(plan != null) : _plan(plan),
        );
      },
    );
  }

  // ===========================================================================
  //  The questions
  // ===========================================================================

  int get _answered => [
    _a.target ?? (_a.alreadyTrying ? true : null),
    _a.age,
    _a.diet,
    _a.region,
    _a.conditionsAnswered ? true : null,
    _a.folic,
  ].where((v) => v != null).length;

  Widget _intake(bool hasPlan) {
    final p = V2PaletteStore.instance.current;
    final now = DateTime.now();
    final months = [
      for (var i = 0; i < 9; i++) DateTime(now.year, now.month + i),
    ];
    final t = _a.target;
    if (t != null && !months.any((m) => readyMonthsBetween(m, t) == 0)) {
      months.add(readyMonthOf(t));
    }
    final ageFilled =
        TtcFertilityHelpStore.instance.ageBand != null &&
        _a.age == TtcFertilityHelpStore.instance.ageBand;

    // ⚠️ A KEY PER MODE: without it the plan reused the questions' scroll
    // position and opened halfway down, under the button she had just tapped.
    return TtcToolScaffold(
      key: const ValueKey('ttc_ready_plan_intake'),
      hue: _hue,
      toolId: 'precheck',
      leading: hasPlan ? TtcToolLeading.back : TtcToolLeading.close,
      eyebrow: kReadyPlanName,
      title: 'A few questions,\nthen your plan.',
      intro:
          'Six short questions for you, and two for him if he is with '
          'you. Skip anything. There is no score, and nothing here decides '
          'anything for you.',
      children: [
        const SizedBox(height: 22),
        ttcToolPad(TtcToolProgress(done: _answered, total: 6)),
        const SizedBox(height: 18),

        ttcToolPad(
          TtcToolQuestion(
            n: 1,
            hue: _hue,
            title: 'Which month do you want to start trying?',
            note: _a.alreadyTrying
                ? 'Then your checklist and cycle tools fit better than a plan. '
                      'The button below opens the checklist.'
                // Says where a filled-in month came from: the first-run
                // flow's "Not yet, we're getting ready" (2026-10-17).
                : '${_store.madeAt == null && _store.plannedStart != null && _a.target == _store.plannedStart ? 'Filled in from when you said you would start. ' : ''}'
                      'Your plan counts the months up to it. About three months '
                      'ahead gives folic acid and a check-up time, but any month '
                      'is fine.',
            child: Column(
              children: [
                TtcToolOptions(
                  p: p,
                  hue: _hue,
                  items: [
                    for (final m in months)
                      TtcToolOption(
                        label: readyMonthsBetween(now, m) == 0
                            ? 'This month'
                            : readyMonthShort(m),
                        on:
                            !_a.alreadyTrying &&
                            t != null &&
                            readyMonthsBetween(m, t) == 0,
                        onTap: () => _set(() {
                          final same =
                              t != null && readyMonthsBetween(m, t) == 0;
                          _a.target = same ? null : m;
                          _a.alreadyTrying = false;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TtcToolOptions(
                  p: p,
                  hue: _hue,
                  items: [
                    TtcToolOption(
                      label: "We're already trying",
                      on: _a.alreadyTrying,
                      onTap: () => _set(() {
                        _a.alreadyTrying = !_a.alreadyTrying;
                        if (_a.alreadyTrying) _a.target = null;
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        ttcToolPad(
          TtcToolQuestion(
            n: 2,
            hue: _hue,
            title: 'How old are you?',
            note:
                '${ageFilled ? 'Filled in from your earlier answer. ' : ''}'
                'It changes one line of your plan: when it is worth asking for '
                'help if trying takes a while.',
            child: TtcToolChoice<FertilityAgeBand>(
              value: _a.age,
              hue: _hue,
              options: {for (final v in FertilityAgeBand.values) v: v.label.en},
              onTap: (v) => _set(() => _a.age = v),
            ),
          ),
        ),

        ttcToolPad(
          TtcToolQuestion(
            n: 3,
            hue: _hue,
            title: 'How do you eat?',
            note:
                'This picks your week of meals and which tests lead your '
                'list.',
            child: TtcToolChoice<ReadyDiet>(
              value: _a.diet,
              hue: _hue,
              options: {for (final v in ReadyDiet.values) v: v.label},
              onTap: (v) => _set(() => _a.diet = v),
            ),
          ),
        ),

        ttcToolPad(
          TtcToolQuestion(
            n: 4,
            hue: _hue,
            title: 'Which kitchen is home?',
            note: 'Your plan uses foods you already cook.',
            child: TtcToolChoice<ReadyRegion>(
              value: _a.region,
              hue: _hue,
              options: {for (final v in ReadyRegion.values) v: v.label},
              onTap: (v) => _set(() => _a.region = v),
            ),
          ),
        ),

        ttcToolPad(
          TtcToolQuestion(
            n: 5,
            hue: _hue,
            title: 'Has a doctor told you about any of these?',
            note:
                "Pick as many as apply. Skip it if you'd rather not say. You "
                'can change it any time.',
            child: TtcToolOptions(
              p: p,
              hue: _hue,
              items: [
                for (final c in ReadyCondition.values)
                  TtcToolOption(
                    label: c.label,
                    tick: true,
                    on: _a.conditions.contains(c),
                    onTap: () => _set(() {
                      _a.conditionsAnswered = true;
                      _a.conditionsUnsure = false;
                      _a.conditions.contains(c)
                          ? _a.conditions.remove(c)
                          : _a.conditions.add(c);
                    }),
                  ),
                TtcToolOption(
                  label: 'None of these conditions',
                  tick: true,
                  on:
                      _a.conditionsAnswered &&
                      !_a.conditionsUnsure &&
                      _a.conditions.isEmpty,
                  onTap: () => _set(() {
                    final wasNone =
                        _a.conditionsAnswered &&
                        !_a.conditionsUnsure &&
                        _a.conditions.isEmpty;
                    _a.conditionsAnswered = !wasNone;
                    _a.conditionsUnsure = false;
                    _a.conditions.clear();
                  }),
                ),
                TtcToolOption(
                  label: 'Not sure',
                  tick: true,
                  on: _a.conditionsUnsure,
                  onTap: () => _set(() {
                    final was = _a.conditionsUnsure;
                    _a.conditionsAnswered = !was;
                    _a.conditionsUnsure = !was;
                    _a.conditions.clear();
                  }),
                ),
              ],
            ),
          ),
        ),

        ttcToolPad(
          TtcToolQuestion(
            n: 6,
            hue: _hue,
            title: 'Are you taking folic acid?',
            note: 'Your answer also ticks folic acid on your checklist.',
            child: TtcToolChoice<ReadyFolic>(
              value: _a.folic,
              hue: _hue,
              options: {for (final v in ReadyFolic.values) v: v.label},
              onTap: (v) => _set(() => _a.folic = v),
            ),
          ),
        ),

        // ---- his part ------------------------------------------------------
        const SizedBox(height: 10),
        ttcToolPad(
          KeyedSubtree(
            key: _hisKey,
            child: const TtcToolBlockHead(
              label: "His part, if he's with you",
              hue: _hue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ttcToolPad(
          Text(
            "Hand him the phone, or come back to it later. Your plan doesn't "
            'wait for it.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
          ),
        ),
        const SizedBox(height: 14),
        ttcToolPad(
          TtcToolQuestion(
            n: 7,
            hue: _hue,
            title: 'How old is he?',
            child: TtcToolChoice<HisAge>(
              value: _a.hisAge,
              hue: _hue,
              options: {for (final v in HisAge.values) v: v.label},
              onTap: (v) => _set(() => _a.hisAge = v),
            ),
          ),
        ),
        ttcToolPad(
          TtcToolQuestion(
            n: 8,
            hue: _hue,
            title: 'Does he use tobacco, drink or take medicines?',
            note:
                'Pick as many as apply. These are the three with evidence '
                'behind them.',
            child: TtcToolOptions(
              p: p,
              hue: _hue,
              items: [
                for (final h in HisHabit.values)
                  TtcToolOption(
                    label: h.label,
                    tick: true,
                    on: _a.hisHabits.contains(h),
                    onTap: () => _set(() {
                      _a.hisHabitsAnswered = true;
                      _a.hisHabits.contains(h)
                          ? _a.hisHabits.remove(h)
                          : _a.hisHabits.add(h);
                    }),
                  ),
                TtcToolOption(
                  label: 'None for him',
                  tick: true,
                  on: _a.hisHabitsAnswered && _a.hisHabits.isEmpty,
                  onTap: () => _set(() {
                    final wasNone =
                        _a.hisHabitsAnswered && _a.hisHabits.isEmpty;
                    _a.hisHabitsAnswered = !wasNone;
                    _a.hisHabits.clear();
                  }),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),
        ttcToolPad(
          TtcToolPrimary(
            key: const ValueKey('ttc_ready_plan_see'),
            label: _a.alreadyTrying ? 'Open the checklist' : 'See our plan',
            onTap: _see,
          ),
        ),
        const SizedBox(height: 14),
        ttcToolPad(const TtcToolPrivacyLine()),
        const SizedBox(height: 26),
      ],
    );
  }

  // ===========================================================================
  //  The plan
  // ===========================================================================

  Widget _plan(ReadyPlan plan) {
    final p = V2PaletteStore.instance.current;
    final c = PrecheckContext.gather();
    final store = TtcPrecheckStore.instance;
    final arrived = plan.arrived;

    Widget head(String label) =>
        ttcToolPad(TtcToolBlockHead(label: label, hue: _hue));
    Widget body(String text) => ttcToolPad(
      Text(text, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
    );

    return TtcToolScaffold(
      key: const ValueKey('ttc_ready_plan_plan'),
      hue: _hue,
      variant: 3,
      toolId: 'precheck',
      eyebrow: kReadyPlanName,
      // ⚠️ THE MONTH FIRST, THE COUNT SECOND AND SMALLER (STILL-OPEN, the
      // next-milestone card): leading with a countdown makes the months
      // something to endure; leading with the month makes it a date she has.
      title: arrived
          ? 'Your month is here.'
          : 'Trying from\n${readyMonthLabel(plan.target)}.',
      intro: arrived
          // ⚠️ SAYS THE CLOCK STARTED (tell her before anything changes):
          // `TtcStore.journeyStart` counts from this month now, so the app's
          // "how long you've been trying" begins here, and she can change it.
          ? 'You planned to start in ${readyMonthLabel(plan.target)}, so the '
                "app counts your trying time from the 1st of that month. What "
                "still matters while you try is below. This isn't medical "
                'clearance, and your doctor has the final word.'
          : "That's ${readyCountLabel(plan.monthsAway)}. A plan for the "
                "months before, from your answers. It isn't medical "
                'clearance, and your doctor has the final word.',
      children: [
        const SizedBox(height: 24),

        for (final n in plan.notes) ...[
          ttcToolPad(TtcToolBlock(text: n, hue: _hue)),
          const SizedBox(height: 14),
        ],

        // ---- this month ----------------------------------------------------
        head(arrived ? 'While you try' : 'This month'),
        const SizedBox(height: 6),
        for (final s in plan.thisMonth)
          ttcToolPad(
            _StepRow(
              step: s,
              status: store.statusOf(s.precheckId, c),
              onTick: () => _toggle(s, store.statusOf(s.precheckId, c)),
              onOpen: _opener(s),
            ),
          ),

        // ---- tests ---------------------------------------------------------
        const SizedBox(height: 26),
        head('Tests to ask your doctor about'),
        const SizedBox(height: 6),
        body(
          'Worth asking about. Your doctor decides which ones apply to you.',
        ),
        const SizedBox(height: 8),
        for (final t in plan.tests)
          ttcToolPad(
            _TestRow(
              test: t,
              onTap: () => openTtcSurface(
                context,
                t.testId != null ? 'ttc_tests' : '$kTtcReadPrefix${t.readId}',
              ),
            ),
          ),
        ttcToolPad(
          PrecheckGoRow(
            label: 'The full test library',
            toolMark: TtcToolMark.tests,
            hue: kTtcToolHueCare,
            onTap: () => openTtcSurface(context, 'ttc_tests'),
          ),
        ),

        // ---- folic acid ----------------------------------------------------
        const SizedBox(height: 26),
        head('Folic acid'),
        const SizedBox(height: 10),
        ttcToolPad(TtcToolBlock(text: plan.folicLine, hue: _hue)),
        const SizedBox(height: 6),
        ttcToolPad(
          PrecheckGoRow(
            label: 'Your supplements',
            toolMark: TtcToolMark.supplements,
            hue: kTtcToolHueCare,
            onTap: () => openTtcSurface(context, 'ttc_supplements'),
          ),
        ),

        // ---- kitchen -------------------------------------------------------
        const SizedBox(height: 26),
        head('Your kitchen'),
        const SizedBox(height: 8),
        ..._kitchen(plan, p),

        // ---- month by month ------------------------------------------------
        if (plan.months.length > 1) ...[
          const SizedBox(height: 26),
          head('Month by month'),
          const SizedBox(height: 12),
          ttcToolPad(
            _Timeline(plan: plan, statusOf: (id) => store.statusOf(id, c)),
          ),
        ],

        // ---- his part ------------------------------------------------------
        const SizedBox(height: 26),
        head('His part'),
        const SizedBox(height: 8),
        if (!plan.hisPersonal) ...[
          body("He hasn't added his answers, so this is the general version."),
          const SizedBox(height: 8),
        ],
        for (final l in plan.hisLines) ...[
          ttcToolPad(_Bullet(text: l)),
          const SizedBox(height: 6),
        ],
        const SizedBox(height: 8),
        ttcToolPad(
          TtcToolSecondary(
            label: plan.hisPersonal ? 'Change his answers' : 'Add his part',
            onTap: () => _edit(his: true),
          ),
        ),

        // ---- take it with you ----------------------------------------------
        const SizedBox(height: 26),
        head('Take your plan to your doctor'),
        const SizedBox(height: 6),
        body(
          'Your checklist turns what you have ticked into notes and '
          'questions for an appointment.',
        ),
        const SizedBox(height: 12),
        ttcToolPad(
          TtcToolPrimary(
            key: const ValueKey('ttc_ready_plan_notes'),
            label: 'Notes for my doctor',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'ttc_precheck/summary'),
                builder: (_) => const TtcPrecheckSummaryScreen(),
              ),
            ),
          ),
        ),

        // ---- the monthly note ----------------------------------------------
        if (!arrived) ...[
          const SizedBox(height: 26),
          head('A note each month'),
          const SizedBox(height: 6),
          body(
            'One note on the 1st of each month, until your month. Off '
            'unless you turn it on.',
          ),
          const SizedBox(height: 10),
          ttcToolPad(
            TtcToolOptions(
              p: p,
              hue: _hue,
              items: [
                TtcToolOption(
                  label: 'Remind me on the 1st of each month',
                  tick: true,
                  on: _store.notify,
                  onTap: () {
                    final on = !_store.notify;
                    _store.setNotify(on);
                    pvSnack(
                      context,
                      on
                          ? 'Monthly note on. The first comes on the 1st.'
                          : 'Monthly note off.',
                      lift: 24,
                    );
                  },
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),
        Center(
          child: TextButton(
            key: const ValueKey('ttc_ready_plan_change'),
            onPressed: _edit,
            child: Text(
              'Change my answers',
              style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: p.ink2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ttcToolPad(const TtcToolPrivacyLine()),
        const SizedBox(height: 10),
        ttcToolPad(
          Text(
            'This plan is general guidance from your answers. It is not a '
            "diagnosis or medical clearance, and your own doctor's advice "
            'comes first.',
            style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3),
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
  }

  List<Widget> _kitchen(ReadyPlan plan, V2Palette p) {
    final kitchen = plan.kitchen;
    final region = plan.region;
    // ⚠️ NEVER HIDDEN (CLAUDE.md): without the two answers the section says
    // what it would show and how to get it.
    if (kitchen == null || region == null) {
      return [
        ttcToolPad(
          Text(
            'Tell us how you eat and which kitchen is home, and this shows '
            'foods you already cook and a day of meals.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
          ),
        ),
        const SizedBox(height: 8),
        ttcToolPad(
          TtcToolSecondary(
            label: 'Add how you eat and your kitchen',
            onTap: _edit,
          ),
        ),
      ];
    }
    final k = kReadyKitchens[region]!;
    final foods = readyFoodsFor(
      region,
      vegetarian: kitchen != TtcKitchen.nonVeg,
      eggless: kitchen.eggless,
      jain: kitchen == TtcKitchen.jain,
    );
    final day = DateTime.now().weekday; // Monday is plan day 1.
    final meals = [
      for (final m in kTtcPlanMeals)
        if (m.day == day) m,
    ]..sort((a, b) => a.slot.index.compareTo(b.slot.index));

    TextStyle small({bool strong = false}) => pvManrope(
      fontSize: 13,
      height: 1.5,
      fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
      color: strong ? p.ink1 : p.ink2,
    );

    return [
      ttcToolPad(
        Text(
          '${kitchen.label} · ${region.label}',
          style: pvManrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: p.ink2,
          ),
        ),
      ),
      const SizedBox(height: 6),
      ttcToolPad(Text(k.line, style: small(strong: true))),
      const SizedBox(height: 12),
      ttcToolPad(const PrecheckLabel('FOODS YOU ALREADY COOK')),
      const SizedBox(height: 6),
      for (final f in foods) ...[
        ttcToolPad(_Bullet(text: '${f.name}: ${f.gives}.')),
        const SizedBox(height: 4),
      ],
      const SizedBox(height: 10),
      ttcToolPad(const PrecheckLabel('SMALL SWAPS')),
      const SizedBox(height: 6),
      for (final s in [
        ...k.swaps,
        if (kitchen == TtcKitchen.jain) kTtcJainSwaps.first,
        if (kitchen == TtcKitchen.nonVeg) kTtcNonVegNote,
      ]) ...[ttcToolPad(_Bullet(text: s)), const SizedBox(height: 4)],
      if (meals.isNotEmpty) ...[
        const SizedBox(height: 10),
        ttcToolPad(const PrecheckLabel("TODAY'S MEALS FROM YOUR WEEK")),
        const SizedBox(height: 6),
        for (final m in meals) ...[
          ttcToolPad(_Bullet(text: '${m.slot.label}: ${m.dishFor(kitchen)}')),
          const SizedBox(height: 4),
        ],
      ],
      const SizedBox(height: 6),
      ttcToolPad(
        PrecheckGoRow(
          label: 'See the whole week of meals',
          tabMark: TtcTabMark.bowl,
          hue: _hue,
          onTap: () => openTtcSurface(context, 'ttc_nutrition'),
        ),
      ),
    ];
  }

  VoidCallback? _opener(ReadyStep s) {
    final id =
        s.surfaceId ?? (s.readId == null ? null : '$kTtcReadPrefix${s.readId}');
    return id == null ? null : () => openTtcSurface(context, id);
  }

  /// One tap marks it done; a second takes it off, with Undo. The checklist's
  /// own behaviour, on the checklist's own item.
  void _toggle(ReadyStep s, PrecheckStatus was) {
    final store = TtcPrecheckStore.instance;
    if (was != PrecheckStatus.done) {
      store.setStatus(s.precheckId, PrecheckStatus.done);
      return;
    }
    final before = store.entryFor(s.precheckId);
    store.setStatus(s.precheckId, PrecheckStatus.untouched);
    pvSnack(
      context,
      '${s.title}: taken off done.',
      action: 'Undo',
      lift: 24,
      onAction: () => store.restore(s.precheckId, before),
    );
  }
}

// -----------------------------------------------------------------------------
//  Parts
// -----------------------------------------------------------------------------

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.status,
    required this.onTick,
    required this.onOpen,
  });

  final ReadyStep step;
  final PrecheckStatus status;
  final VoidCallback onTick;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final done = status == PrecheckStatus.done;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrecheckTick(status: status, title: step.title, onTap: onTick),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: pvJakarta(
                              fontSize: 15,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              color: done ? p.ink2 : p.ink1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.why,
                            style: pvManrope(
                              fontSize: 12.5,
                              height: 1.45,
                              color: p.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onOpen != null) ...[
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: ttcTitleInk,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestRow extends StatelessWidget {
  const _TestRow({required this.test, required this.onTap});

  final ReadyTest test;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.line)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        test.name,
                        style: pvJakarta(
                          fontSize: 14.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: p.ink1,
                        ),
                      ),
                      if (test.forBoth) const PrecheckTag('For both of you'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    test.why,
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.45,
                      color: p.ink2,
                    ),
                  ),
                  if (test.emphasis case final e?) ...[
                    const SizedBox(height: 4),
                    Text(
                      e,
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                        color: p.ink1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: ttcTitleInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 10),
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: ttcTitleInk,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1),
          ),
        ),
      ],
    );
  }
}

/// The months down a line, each with its steps and their ticks.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.plan, required this.statusOf});

  final ReadyPlan plan;
  final PrecheckStatus Function(String id) statusOf;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final months = plan.months;
    return Column(
      children: [
        for (var i = 0; i < months.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 22,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: i == 0 ? ttcTitleInk : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: ttcTitleInk, width: 1.8),
                        ),
                      ),
                      if (i < months.length - 1)
                        Expanded(child: Container(width: 1.5, color: p.line)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          months[i].isTarget
                              ? '${readyMonthLabel(months[i].month)} · you start trying'
                              : i == 0
                              ? '${readyMonthLabel(months[i].month)} · now'
                              : readyMonthLabel(months[i].month),
                          style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                        if (months[i].isTarget) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Keep taking folic acid, and use your fertile '
                            'window.',
                            style: pvManrope(
                              fontSize: 12.5,
                              height: 1.45,
                              color: p.ink2,
                            ),
                          ),
                        ],
                        for (final s in months[i].steps) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                statusOf(s.precheckId) == PrecheckStatus.done
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 15,
                                color: ttcTitleInk,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.title,
                                  style: pvManrope(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: p.ink2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

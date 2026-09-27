// =============================================================================
//  "See a specialist?" — entry, context snapshot, the few questions, the answer
// -----------------------------------------------------------------------------
//  V3 language throughout, matching the reader, the vaccination surface, the
//  PCOS checker, the checklist and the BMI tool.
//
//  ⚠️ THE JOURNEY'S OWN PRINCIPLE GOVERNS THIS SCREEN: "this journey ends when
//  she knows, not when she has booked." So the result is ordered
//
//      the answer → why → what it does not mean → her next step
//      ─────────────────────────────────────────────────────────
//      and only then, below a rule, the consultation
//
//  and the ₹899 consult sits under a divider, described as a conversation, with
//  no urgency of any kind. Putting it above the fold would make this a funnel
//  with a quiz on the front, which is what thirty sections of the brief exist
//  to prevent.
//
//  ⚠️ NO COMMERCE BEYOND THAT ONE CARD. `kTtcInfertility` marks products
//  `notApplicable` with the plainest reason in the bracket table — "Not a fit
//  (clinical)". No product row, no supplement, no kit.
//
//  ⚠️ AND NO NUMBER ANYWHERE. No percentage, no score, no gauge. See the head
//  of `ttc_fertility_help_rules.dart`.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_fertility_help_rules.dart';
import '../../ttc/ttc_fertility_help_store.dart';
import '../v2/v2_palette.dart';
import 'ttc_fertility_help_summary.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';

/// IVF & IUI is 206 on the wheel.
const double kFertilityHelpHue = 206;

class TtcFertilityHelpScreen extends StatefulWidget {
  const TtcFertilityHelpScreen({super.key});

  @override
  State<TtcFertilityHelpScreen> createState() => _TtcFertilityHelpScreenState();
}

enum _Stage { intro, questions, result }

class _TtcFertilityHelpScreenState extends State<TtcFertilityHelpScreen> {
  _Stage _stage = _Stage.intro;
  int _q = 0;

  TtcFertilityHelpStore get _store => TtcFertilityHelpStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(
          [_store, V2PaletteStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hi = TtcLang.instance.hinglish;
        final lang = hi ? AppLanguage.hinglish : AppLanguage.english;
        String t(String en, String hin) => hi ? hin : en;

        return Scaffold(
          backgroundColor: p.ground,
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              _bar(p, t),
              Expanded(
                child: switch (_stage) {
                  _Stage.intro => _intro(p, lang, t),
                  _Stage.questions => _questions(p, lang, t),
                  _Stage.result => _result(p, lang, t),
                },
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _bar(V2Palette p, String Function(String, String) t) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 16, 6),
        child: Row(children: [
          GestureDetector(
            onTap: _back,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_rounded, size: 21, color: p.ink1),
            ),
          ),
          Expanded(
            child: Text(t('IVF & IUI', 'IVF aur IUI'),
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.ink3)),
          ),
        ]),
      );

  void _back() {
    switch (_stage) {
      case _Stage.intro:
        Navigator.of(context).maybePop();
      case _Stage.questions:
        if (_q == 0) {
          setState(() => _stage = _Stage.intro);
        } else {
          setState(() => _q -= 1);
        }
      case _Stage.result:
        setState(() => _stage = _Stage.intro);
    }
  }

  // ---------------------------------------------------------------------------
  //  Intro + context snapshot
  // ---------------------------------------------------------------------------

  Widget _intro(
      V2Palette p, AppLanguage lang, String Function(String, String) t) {
    final c = _store.context;
    final known = _knownRows(t, c);
    final missing = _store.missingQuestionIds.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, kAskFabReserve + 24),
      children: [
        Text(
            t('Is it time to see a fertility specialist?',
                'Kya ab fertility specialist se milne ka waqt hai?'),
            style: pvFraunces(
                fontSize: 29,
                height: 1.18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: p.ink1)),
        const SizedBox(height: 14),
        Text(
            t(
                "You don't have to guess. We'll look at where you are and a "
                    'few things that affect fertility. Then we\'ll tell you '
                    "whether it's fine to keep trying for now, or worth talking "
                    'to someone.',
                'Andaaza lagane ki zaroorat nahi. Hum dekhenge ki aap kahan '
                    'hain aur kuch fertility baatein, aur batayenge ki abhi '
                    'koshish jaari rakhna theek hai ya kisi se milna behtar.'),
            style: pvFraunces(fontSize: 16.5, height: 1.58, color: p.ink2)),
        const SizedBox(height: 18),

        // ---- THE DISCLAIMER, BEFORE SHE STARTS ----------------------------
        //
        // It used to sit at the foot, below both buttons, with a shorter
        // paraphrase of itself up here. Two problems, one fix.
        //
        // The first is order: a limit stated after the button is a limit
        // stated after the decision. She reads down, taps "Check my
        // readiness", and never returns to the last paragraph.
        //
        // The second is a collision worth understanding, because it will
        // recur. `kAskFabReserve` at the bottom of a scroll view reserves
        // room so the LAST row is not stranded under the floating Ask Veda
        // button. That works only when the content is tall enough to scroll.
        // On a short page the content simply ends wherever it ends — which on
        // this screen was inside the FAB's band, with the safety sentence
        // half-covered. Padding cannot push up what was never pushed down.
        // The reliable answer on a short page is to not put anything that
        // must be read in the bottom-right corner at all.
        Text(kFertilityHelpDisclaimer.of(lang),
            style: pvManrope(fontSize: 13, height: 1.6, color: p.ink3)),
        const SizedBox(height: 24),

        // ---- WHAT WE ALREADY KNOW -----------------------------------------
        //
        // ⚠️ §6 AND §8 — THE HARD REQUIREMENT. Showing this before asking
        // anything is what stops the tool being a fourth questionnaire. If the
        // app knows nothing yet it shows nothing, because an empty "here is
        // what we know" box is worse than no box.
        if (known.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
            decoration: BoxDecoration(
              color: v2BlockTint(kFertilityHelpHue, p),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t("HERE'S WHAT WE ALREADY KNOW", 'JO HUM PEHLE SE JAANTE HAIN'),
                      style: pvManrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: const Color(0xFF23303A))),
                  const SizedBox(height: 12),
                  for (final r in known) ...[
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 74,
                            child: Text(r.$1,
                                style: pvManrope(
                                    fontSize: 12.5,
                                    color: const Color(0xFF44555F))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(r.$2,
                                style: pvManrope(
                                    fontSize: 14,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2B33))),
                          ),
                        ]),
                    const SizedBox(height: 9),
                  ],
                  const SizedBox(height: 3),
                  Text(
                      missing == 0
                          ? t("That's everything we need.",
                              'Bas itna hi chahiye tha.')
                          : t(
                              'We only need $missing more '
                                  '${missing == 1 ? 'detail' : 'details'}.',
                              'Bas $missing aur baatein poochhni hain.'),
                      style: pvManrope(
                          fontSize: 13.5,
                          height: 1.5,
                          color: const Color(0xFF44555F))),
                ]),
          ),
          const SizedBox(height: 24),
        ],

        _Button(
            p: p,
            label: t('Check my readiness', 'Meri sthiti dekhein'),
            onTap: () => setState(() {
                  _q = 0;
                  _stage = _store.missingQuestionIds.isEmpty
                      ? _Stage.result
                      : _Stage.questions;
                })),
        const SizedBox(height: 12),

        // ---- §19: SHE MAY ALREADY KNOW SHE WANTS HELP ---------------------
        //
        // ⚠️ NOT BURIED BEHIND THE QUIZ. Someone who has already decided must
        // not be made to answer eight questions to reach a summary — making
        // her walk the tool because the product wants a result is the tool
        // serving itself.
        _Button(
            p: p,
            filled: false,
            label: t('I already want to talk to someone',
                'Main pehle se hi kisi se baat karna chahti hoon'),
            onTap: _openSummary),
      ],
    );
  }

  List<(String, String)> _knownRows(
      String Function(String, String) t, FertilityHelpContext c) {
    final out = <(String, String)>[];
    final trying = c.tryingLabel;
    if (trying != null) {
      out.add((t('Trying', 'Koshish'), trying.en));
    }
    if (c.hasEnoughCycleData) {
      out.add((
        t('Cycles', 'Cycles'),
        c.cyclesIrregular
            ? t('${c.cycleShortest} to ${c.cycleLongest} days, varies',
                '${c.cycleShortest}–${c.cycleLongest} din — badalta hua')
            : t('${c.cyclesLogged} logged, fairly steady',
                '${c.cyclesLogged} log kiye, kaafi sthir')
      ));
    }
    if (c.pcosCheckDone) {
      out.add((
        t('PCOS check', 'PCOS check'),
        c.pcosPatternFound
            ? t('Found things worth talking about',
                'Kuch patterns mile jinpar baat karni chahiye')
            : t('No strong pattern', 'Koi mazboot pattern nahi')
      ));
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  //  The few questions
  // ---------------------------------------------------------------------------

  Widget _questions(
      V2Palette p, AppLanguage lang, String Function(String, String) t) {
    final missing = _store.missingQuestionIds;
    if (missing.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => mounted ? setState(() => _stage = _Stage.result) : null);
      return const SizedBox.shrink();
    }
    final i = _q.clamp(0, missing.length - 1);
    final id = missing[i];
    final q = _questionFor(id, t);

    return Column(children: [
      SizedBox(
        height: 2,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: ((i + 1) / missing.length).clamp(0.05, 1.0),
            child: ColoredBox(color: p.action),
          ),
        ),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, kAskFabReserve + 24),
          children: [
            Text('${i + 1} / ${missing.length}',
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: p.ink3)),
            const SizedBox(height: 14),
            Text(q.prompt,
                style: pvFraunces(
                    fontSize: 24,
                    height: 1.28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: p.ink1)),
            if (q.note != null) ...[
              const SizedBox(height: 12),
              Text(q.note!,
                  style:
                      pvManrope(fontSize: 13.5, height: 1.6, color: p.ink3)),
            ],
            const SizedBox(height: 24),
            if (q.multi)
              ...[
                for (final o in q.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Option(
                      p: p,
                      label: o.$2,
                      selected: o.$1 == 'none'
                          ? (_store.answerFor('conditions') ?? '')
                              .contains('none')
                          : _store.selectedConditions.contains(o.$1),
                      onTap: () => _store.toggleCondition(o.$1),
                    ),
                  ),
                const SizedBox(height: 14),
                _Button(
                    p: p,
                    label: t('Continue', 'Aage badhein'),
                    onTap: () {
                      if (_store.answerFor('conditions') == null) {
                        _store.answer('conditions', 'none');
                      }
                      _advance();
                    }),
              ]
            else
              for (final o in q.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _Option(
                    p: p,
                    label: o.$2,
                    selected: _store.answerFor(id) == o.$1,
                    onTap: () async {
                      await _store.answer(id, o.$1);
                      _advance();
                    },
                  ),
                ),
          ],
        ),
      ),
    ]);
  }

  void _advance() {
    if (!mounted) return;
    // ⚠️ RE-READ THE MISSING LIST AFTER EVERY ANSWER. Saying "currently in
    // care" removes every remaining question, and marching on through them
    // would be the tool ignoring what she just said.
    final missing = _store.missingQuestionIds;
    if (_q + 1 >= missing.length) {
      _store.complete();
      setState(() => _stage = _Stage.result);
      return;
    }
    setState(() => _q += 1);
  }

  ({String prompt, String? note, bool multi, List<(String, String)> options})
      _questionFor(String id, String Function(String, String) t) {
    switch (id) {
      case 'age':
        return (
          prompt: t('How old are you?', 'Aapki umar kya hai?'),
          note: t(
              "Age only changes when it's worth being seen. It isn't a "
                  'judgement about you.',
              'Umar se ye badalta hai ki guidance kab milne ko kehti hai, aapke '
                  'baare mein kya kehti hai wo nahi.'),
          multi: false,
          options: [
            for (final b in FertilityAgeBand.values) (b.name, b.label.en),
          ]
        );
      case 'pathway':
        return (
          prompt: t('Have you had a fertility check-up?',
              'Kya aapki fertility evaluation hui hai?'),
          note: null,
          multi: false,
          options: [
            ('no', t('No', 'Nahi')),
            ('done', t('Yes, in the past', 'Haan, pehle hui thi')),
            ('current', t("I'm having one right now", 'Abhi chal rahi hai')),
          ]
        );
      case 'conditions':
        return (
          prompt: t(
              'Has a doctor told you about anything that can affect fertility?',
              'Kya doctor ne aisi koi cheez batayi hai jo fertility par asar '
                  'daal sakti hai?'),
          note: t('Choose any that apply.', 'Jo laagu ho, chun lein.'),
          multi: true,
          options: [
            for (final c in kFertilityConditions) (c.id, c.label),
            ('none', t('No, none of these', 'Nahi, inmein se koi nahi')),
          ]
        );
      case 'miscarriages':
        return (
          prompt: t('Have you had a miscarriage?',
              'Kya aapka miscarriage hua hai?'),
          note: null,
          multi: false,
          options: [
            ('0', t('No', 'Nahi')),
            ('1', t('Once', 'Ek baar')),
            ('2', t('Twice or more', 'Do ya usse zyada baar')),
          ]
        );
      case 'pain':
        return (
          prompt: t('Are your periods very painful or very heavy, or is sex '
              'painful?', 'Kya aapke periods bahut dardnaak ya bahut zyada '
              'hote hain, ya sex mein dard hota hai?'),
          note: null,
          multi: false,
          options: [
            ('no', t('No', 'Nahi')),
            ('yes', t('Yes', 'Haan')),
          ]
        );
      case 'pelvic':
        return (
          prompt: t(
              'Have you had surgery in your pelvis, a burst appendix, or a '
                  'pelvic infection?',
              'Kya aapki pelvic surgery, appendix phatna, ya pelvic infection '
                  'hua hai?'),
          note: null,
          multi: false,
          options: [
            ('no', t('No', 'Nahi')),
            ('yes', t('Yes', 'Haan')),
          ]
        );
      case 'partner':
        return (
          prompt: t('Is there a known concern on his side?',
              'Kya unki taraf koi baat pata hai?'),
          note: t(
              'Like a semen test that came back abnormal, or anything a doctor '
                  'has raised.',
              'Semen analysis theek na aana, ya doctor ne kuch kaha ho.'),
          multi: false,
          options: [
            ('no', t('No', 'Nahi')),
            ('yes', t('Yes', 'Haan')),
            ('unsure', t('Not sure', 'Pata nahi')),
          ]
        );
      default: // cancer
        return (
          prompt: t(
              'Is either of you about to start cancer treatment?',
              'Kya aap dono mein se kisi ka cancer treatment shuru hone wala '
                  'hai?'),
          note: t(
              'We ask because fertility preservation (saving eggs or sperm) '
                  'has to happen before treatment starts.',
              'Isliye poochh rahe hain kyunki fertility preservation treatment '
                  'se pehle karni hoti hai.'),
          multi: false,
          options: [
            ('no', t('No', 'Nahi')),
            ('yes', t('Yes', 'Haan')),
          ]
        );
    }
  }

  // ---------------------------------------------------------------------------
  //  The answer
  // ---------------------------------------------------------------------------

  Widget _result(
      V2Palette p, AppLanguage lang, String Function(String, String) t) {
    final r = _store.result;
    final inCare = r.state == FertilityHelpState.alreadyInCare;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, kAskFabReserve + 24),
      children: [
        // 1. THE ANSWER
        Text(r.headline.of(lang),
            style: pvFraunces(
                fontSize: 27,
                height: 1.2,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: p.ink1)),
        const SizedBox(height: 12),
        Text(r.body.of(lang),
            style: pvManrope(fontSize: 15, height: 1.7, color: p.ink2)),

        // 2. WHY — her own facts, at most three
        if (r.reasons.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(t('WHY WE SAY THIS', 'HUM YAHAN KAISE PAHUNCHE'),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3)),
          const SizedBox(height: 12),
          for (final reason in r.reasons)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 5,
                  height: 5,
                  decoration:
                      BoxDecoration(color: p.action, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(reason.text.of(lang),
                      style: pvManrope(
                          fontSize: 14.5, height: 1.65, color: p.ink1)),
                ),
              ]),
            ),
        ],

        // 3. WHAT THIS DOES NOT MEAN
        if (r.notMeaning.en.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t("What this doesn't mean", 'Iska matlab ye nahi hai'),
                      style: pvJakarta(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                  const SizedBox(height: 9),
                  Text(r.notMeaning.of(lang),
                      style: pvManrope(
                          fontSize: 14, height: 1.68, color: p.ink2)),
                ]),
          ),
        ],

        // 4. HER NEXT STEP
        const SizedBox(height: 26),
        Text(t('Your next step', 'Aapka agla kadam'),
            style: pvFraunces(
                fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 10),
        Text(r.nextStep.of(lang),
            style: pvManrope(fontSize: 15, height: 1.7, color: p.ink2)),
        const SizedBox(height: 16),

        _Button(
          p: p,
          label: inCare
              ? t('Prepare for your next appointment',
                  'Agli appointment ki taiyaari')
              : t('Get ready for a fertility appointment',
                  'Fertility consultation ki taiyaari'),
          onTap: _openSummary,
        ),

        if (r.state == FertilityHelpState.keepTrying) ...[
          const SizedBox(height: 10),
          _Link(
              p: p,
              label: t('Keep tracking your cycles',
                  'Apne cycles track karti rahein'),
              onTap: () => _open('ttc_cycle')),
        ],

        // ---- THE ARTICLE, NOT A COPY OF IT --------------------------------
        const SizedBox(height: 10),
        _Link(
            p: p,
            label: t('Read: when to get help with fertility',
                'Padhein: fertility madad kab lein'),
            onTap: () => _open('ttc_read/ttc_read_when_to_seek_help')),

        // ---- THE PATTERN BREAK ---------------------------------------------
        const SizedBox(height: 30),
        Text(kFertilityHelpPatternBreak.of(lang),
            style: pvFraunces(
                fontSize: 17.5,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: p.ink2)),

        // ---- AND ONLY THEN, BELOW A RULE, THE CONSULTATION ----------------
        //
        // ⚠️ THE PLACEMENT IS THE PRODUCT DECISION. Below the answer, below
        // the reasons, below her next step, below the article, under a
        // divider, with no urgency and no price framing beyond the plain fact
        // of it. The journey ends when she knows; this is here for the woman
        // who has already decided she wants a person.
        const SizedBox(height: 30),
        Divider(color: p.line, height: 1),
        const SizedBox(height: 20),
        Text(t('Would you rather talk to someone?',
                'Kisi se baat karna chahengi?'),
            style: pvJakarta(
                fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
        const SizedBox(height: 8),
        Text(
            t(
                'A fertility specialist, on video, at a time you pick. '
                    '₹899 for a session.',
                'Fertility specialist, video par, aapke chune waqt par. '
                    'Ek session ₹899.'),
            style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink2)),
        const SizedBox(height: 12),
        _Link(
            p: p,
            label: t('Learn about the consultation',
                'Consultation ke baare mein jaanein'),
            onTap: () => _open('ttc_prepare')),

        const SizedBox(height: 26),
        _Button(
            p: p,
            filled: false,
            label: t('Start again', 'Phir se shuru karein'),
            onTap: () async {
              await _store.reset();
              if (mounted) setState(() => _stage = _Stage.intro);
            }),
        const SizedBox(height: 20),
        Text(kFertilityHelpDisclaimer.of(lang),
            style: pvManrope(fontSize: 12, height: 1.6, color: p.ink3)),
      ],
    );
  }

  void _open(String surfaceId) {
    final screen = ttcScreenForSurface(surfaceId);
    if (screen == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: surfaceId),
      builder: (_) => screen,
    ));
  }

  void _openSummary() => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc_fertility_help/summary'),
        builder: (_) => const TtcFertilityHelpSummaryScreen(),
      ));
}

// -----------------------------------------------------------------------------

class _Option extends StatelessWidget {
  const _Option(
      {required this.p,
      required this.label,
      required this.selected,
      required this.onTap});

  final V2Palette p;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? p.action.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? p.action : p.line, width: selected ? 1.5 : 1),
          ),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: pvManrope(
                      fontSize: 15.5,
                      height: 1.4,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? p.action : p.ink1)),
            ),
            if (selected) Icon(Icons.check_rounded, size: 19, color: p.action),
          ]),
        ),
      );
}

class _Link extends StatelessWidget {
  const _Link({required this.p, required this.label, required this.onTap});
  final V2Palette p;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink1)),
            ),
            Icon(Icons.arrow_forward_rounded, size: 17, color: p.ink3),
          ]),
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button(
      {required this.p,
      required this.label,
      required this.onTap,
      this.filled = true});

  final V2Palette p;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? p.action : null,
            borderRadius: BorderRadius.circular(999),
            border: filled ? null : Border.all(color: p.line),
          ),
          child: Text(label,
              style: pvJakarta(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : p.ink1)),
        ),
      );
}

/// Shared with the summary screen.
class FertilityHelpButton extends StatelessWidget {
  const FertilityHelpButton(
      {super.key,
      required this.p,
      required this.label,
      required this.onTap,
      this.filled = true});

  final V2Palette p;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) =>
      _Button(p: p, label: label, onTap: onTap, filled: filled);
}

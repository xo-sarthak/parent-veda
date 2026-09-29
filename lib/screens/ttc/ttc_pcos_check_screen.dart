// =============================================================================
//  PCOS Symptom Checker — the flow
// -----------------------------------------------------------------------------
//  Intro → one question per screen → result. V3 design language throughout:
//  `V2PaletteStore` for colour, `pv_fonts` for type, hairlines rather than
//  shadows, flat tint rather than gradient — matching `PvReaderScreen` and
//  `TtcVaccinesScreen` so a tool opened from a read looks like it belongs to
//  the read.
//
//  ⚠️ NOT A QUESTIONNAIRE, AND THE LAYOUT IS THE ARGUMENT.
//
//  A fifteen-question form on one page reads as a medical intake and is
//  abandoned. One question per screen, large targets, a quiet progress
//  hairline, and an expandable "why we ask" on anything that could feel
//  intrusive — which, on a page asking about facial hair, is most of them.
//
//  ⚠️ NO SCORE ANYWHERE. No percentage, no meter, no red/amber/green. The
//  result renders three coarse dials and prose. See `ttc_pcos_check_rules.dart`
//  for why a number here would be a personalised probability with a medical hat
//  on, which CLAUDE.md forbids outright.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_chapter.dart' show kTtcIrregularSpreadDays;
import '../../ttc/ttc_pcos_check_data.dart';
import '../../ttc/ttc_pcos_check_store.dart';
import '../v2/v2_palette.dart';
import 'ttc_pcos_check_result.dart';
import 'ttc_strings.dart';
import 'ttc_common.dart' show ttcTitleInk;

/// PCOS is 288 on the controlled wheel — a tool opened from that door keeps
/// the door's colour.
const double kPcosHue = 288;

class TtcPcosCheckScreen extends StatefulWidget {
  const TtcPcosCheckScreen({super.key});

  @override
  State<TtcPcosCheckScreen> createState() => _TtcPcosCheckScreenState();
}

class _TtcPcosCheckScreenState extends State<TtcPcosCheckScreen> {
  /// Null while the intro is showing.
  int? _index;
  bool _whyOpen = false;

  TtcPcosCheckStore get _store => TtcPcosCheckStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load().then((_) {
      if (!mounted) return;
      // ⚠️ PREFILL BEFORE THE FIRST FRAME OF THE FLOW, not on the intro's
      // build — the intro needs to be able to SAY what it filled in, which
      // means the filling has to have happened.
      _store.prefill();
      setState(() {});
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
            child: _index == null
                ? _Intro(
                    p: p,
                    t: t,
                    store: _store,
                    onStart: _start,
                    onBack: () => Navigator.of(context).maybePop(),
                  )
                : _question(p, lang, t),
          ),
        );
      },
    );
  }

  void _start() {
    final visible = _store.visibleQuestions;
    final next = _store.nextUnanswered;
    setState(() {
      _whyOpen = false;
      _index = next == null ? 0 : visible.indexOf(next);
    });
  }

  // ---------------------------------------------------------------------------

  Widget _question(V2Palette p, AppLanguage lang, String Function(String, String) t) {
    final visible = _store.visibleQuestions;
    final i = _index!.clamp(0, visible.length - 1);
    final q = visible[i];
    final chosen = _store.answerFor(q.id);
    final derived = _store.sourceOf(q.id) == PcosAnswerSource.derived;

    return Column(children: [
      // ---- chrome ----------------------------------------------------------
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
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
            child: Text(q.section.title.of(lang).toUpperCase(),
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.ink3)),
          ),
          Text('${i + 1} / ${visible.length}',
              style: pvManrope(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
        ]),
      ),
      // A hairline, not a percentage. Progress through a flow is not a score.
      SizedBox(
        height: 2,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: ((i + 1) / visible.length).clamp(0.02, 1.0),
            child: ColoredBox(color: p.action),
          ),
        ),
      ),

      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, kAskFabReserve + 24),
          children: [
            Text(q.prompt.of(lang),
                style: pvFraunces(
                    fontSize: 24,
                    height: 1.28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: p.ink1)),

            if (q.whyWeAsk != null) ...[
              const SizedBox(height: 14),
              _WhyWeAsk(
                p: p,
                open: _whyOpen,
                text: q.whyWeAsk!.of(lang),
                label: t('Why we ask', 'Ye kyun poochh rahe hain'),
                onTap: () => setState(() => _whyOpen = !_whyOpen),
              ),
            ],

            // ⚠️ THE PROVENANCE BANNER. A prefilled answer must announce
            // itself — silently pre-selecting an option she never chose, on a
            // health question, would be putting words in her mouth.
            if (derived && chosen != null) ...[
              const SizedBox(height: 16),
              _DerivedNote(p: p, t: t, store: _store, lang: lang),
            ],

            const SizedBox(height: 22),
            for (final o in q.options) ...[
              _OptionTile(
                p: p,
                label: o.label.of(lang),
                selected: chosen == o.id,
                onTap: () => _choose(q, o),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    ]);
  }

  Future<void> _choose(PcosCheckerQuestion q, PcosCheckerOption o) async {
    await _store.answer(q.id, o.id);
    if (!mounted) return;

    // ⚠️ A SAFETY ANSWER ENDS THE FLOW IMMEDIATELY. Not at the end, not after
    // the section — now. Continuing to ask about acne after someone reports
    // sudden one-sided pain is the failure this branch exists to prevent.
    if (q.domain == PcosDomain.safety && o.weight >= 3) {
      _finish();
      return;
    }
    _next();
  }

  void _next() {
    final visible = _store.visibleQuestions;
    final i = _index!;
    if (i + 1 >= visible.length) {
      _finish();
      return;
    }
    setState(() {
      _whyOpen = false;
      _index = i + 1;
    });
  }

  void _back() {
    final i = _index!;
    if (i == 0) {
      setState(() => _index = null);
      return;
    }
    setState(() {
      _whyOpen = false;
      _index = i - 1;
    });
  }

  Future<void> _finish() async {
    await _store.complete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc_pcos_check/result'),
      builder: (_) => const TtcPcosCheckResultScreen(),
    ));
  }
}

// -----------------------------------------------------------------------------
//  Intro
// -----------------------------------------------------------------------------

class _Intro extends StatelessWidget {
  const _Intro({
    required this.p,
    required this.t,
    required this.store,
    required this.onStart,
    required this.onBack,
  });

  final V2Palette p;
  final String Function(String, String) t;
  final TtcPcosCheckStore store;
  final VoidCallback onStart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final facts = store.cycleFacts;
    final resuming = store.hasStarted && !store.hasCompleted;

    return Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: onBack,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Icon(Icons.arrow_back_rounded, size: 21, color: p.ink1),
          ),
        ),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, kAskFabReserve + 24),
          children: [
            Text(t('PCOS', 'PCOS'),
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.action)),
            const SizedBox(height: 14),
            Text(
                t('Could your cycle be telling you something?',
                    'Kya aapka cycle kuch keh raha hai?'),
                style: pvFraunces(
                    fontSize: 30,
                    height: 1.16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: p.ink1)),
            const SizedBox(height: 14),
            Text(
                t(
                    'PCOS affects ovulation, periods and hormones, and it looks '
                        'different in almost everyone. This check looks at your '
                        'cycle and the signs that sometimes go with it, so you '
                        "know what's worth raising with a doctor.",
                    'PCOS ovulation, periods aur hormones par asar daalta hai, '
                        'aur har kisi mein alag dikhta hai. Ye aapke cycle aur '
                        'un patterns ko dekhta hai jo kabhi-kabhi saath chalte '
                        'hain, taaki pata ho ki doctor se kya kehna hai.'),
                style: pvFraunces(
                    fontSize: 16.5, height: 1.58, color: p.ink2)),
            const SizedBox(height: 22),

            // ---- WHAT WE ALREADY KNOW ---------------------------------------
            //
            // ⚠️ THE WHOLE ARGUMENT FOR THIS TOOL EXISTING INSIDE PARENTVEDA
            // RATHER THAN ON A WEBSITE. She has already logged her cycles; the
            // check should open by telling her what they say, not by asking.
            if (facts != null) ...[
              _CycleFactsCard(p: p, t: t, facts: facts),
              const SizedBox(height: 22),
            ],

            _Reassure(
              p: p,
              t: t,
              lines: [
                t('It takes two to three minutes.',
                    'Do se teen minute lagenge.'),
                t('Nothing here diagnoses PCOS.',
                    'Yahan kuch bhi PCOS ka diagnosis nahi karta.'),
                t('Your answers stay on your phone.',
                    'Aapke jawab aapke phone par hi rehte hain.'),
              ],
            ),
            const SizedBox(height: 26),

            _PrimaryButton(
              p: p,
              label: resuming
                  ? t('Continue your check', 'Apna check jaari rakhein')
                  : t('Check my pattern', 'Mera pattern dekhein'),
              onTap: onStart,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                  t(
                      'Your answers only shape this result. It is not a '
                          'diagnosis.',
                      'Jawab sirf is result ko aapke hisaab se banane ke liye '
                          'hain. Ye diagnosis nahi hai.'),
                  textAlign: TextAlign.center,
                  style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3)),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _CycleFactsCard extends StatelessWidget {
  const _CycleFactsCard(
      {required this.p, required this.t, required this.facts});

  final V2Palette p;
  final String Function(String, String) t;
  final PcosCycleFacts facts;

  @override
  Widget build(BuildContext context) {
    // The one definition of irregular (2026-09-26). Was `facts.spread > 7`.
    final varied = facts.spread > kTtcIrregularSpreadDays;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: v2BlockTint(kPcosHue, p),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            t("FROM THE CYCLES YOU'VE LOGGED",
                'JO CYCLES AAPNE LOG KIYE HAIN'),
            style: pvManrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: const Color(0xFF3E2E48))),
        const SizedBox(height: 9),
        Text(
            varied
                ? t(
                    'Your ${facts.count} cycles have run from ${facts.shortest} '
                        'to ${facts.longest} days.',
                    'Aapke ${facts.count} cycles ${facts.shortest} se '
                        '${facts.longest} din tak rahe hain.')
                : t(
                    'Your ${facts.count} cycles have been fairly steady, around '
                        '${facts.median} days.',
                    'Aapke ${facts.count} cycles kaafi sthir rahe hain, lagbhag '
                        '${facts.median} din.'),
            style: pvFraunces(
                fontSize: 17.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C2135))),
        const SizedBox(height: 8),
        Text(
            t(
                "We've filled in the cycle questions from this, so you only "
                    "answer what we don't already know. You can change any of "
                    'it.',
                'Cycle ke sawaal humne isi se bhar diye hain, taaki aapko sirf '
                    'wahi batana pade jo hum nahi jaante. Aap kuch bhi badal '
                    'sakti hain.'),
            style: pvManrope(
                fontSize: 13.5, height: 1.6, color: const Color(0xFF493C55))),
      ]),
    );
  }
}

class _DerivedNote extends StatelessWidget {
  const _DerivedNote(
      {required this.p,
      required this.t,
      required this.store,
      required this.lang});

  final V2Palette p;
  final String Function(String, String) t;
  final TtcPcosCheckStore store;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.line),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.auto_awesome_outlined, size: 15, color: ttcTitleInk),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
                t(
                    "We filled this in from the cycles you've logged. Change "
                        "it if it doesn't match how things feel to you.",
                    'Ye humne aapke logged cycles se bhara hai. Agar aisa nahi '
                        'lagta toh badal dein.'),
                style:
                    pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
          ),
        ]),
      );
}

// -----------------------------------------------------------------------------
//  Small shared pieces
// -----------------------------------------------------------------------------

class _OptionTile extends StatelessWidget {
  const _OptionTile(
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
          // 56dp minimum — a health question answered on a phone in bed needs
          // a target you cannot miss.
          constraints: const BoxConstraints(minHeight: 56),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            // A chosen row is an ink edge and an ink tick; the row does not
            // fill (DESIGN-SYSTEM §4.0, 2026-09-29). Kept for revert:
            //   color: selected ? p.action.withValues(alpha: 0.08) : null,
            color: null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? ttcTitleInk : p.line, width: selected ? 1.5 : 1),
          ),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: pvManrope(
                      fontSize: 15.5,
                      height: 1.4,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? ttcTitleInk : p.ink1)),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 19, color: ttcTitleInk),
          ]),
        ),
      );
}

class _WhyWeAsk extends StatelessWidget {
  const _WhyWeAsk(
      {required this.p,
      required this.open,
      required this.text,
      required this.label,
      required this.onTap});

  final V2Palette p;
  final bool open;
  final String text;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label,
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: ttcTitleInk)),
              const SizedBox(width: 4),
              Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 17, color: ttcTitleInk),
            ]),
          ),
          if (open) ...[
            const SizedBox(height: 9),
            Text(text,
                style:
                    pvManrope(fontSize: 13.5, height: 1.62, color: p.ink2)),
          ],
        ],
      );
}

class _Reassure extends StatelessWidget {
  const _Reassure({required this.p, required this.t, required this.lines});

  final V2Palette p;
  final String Function(String, String) t;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(children: [
                Icon(Icons.check_rounded, size: 15, color: p.ink3),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l,
                      style: pvManrope(
                          fontSize: 13.5, height: 1.45, color: p.ink2)),
                ),
              ]),
            ),
        ],
      );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(
      {required this.p, required this.label, required this.onTap});

  final V2Palette p;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ttcTitleInk,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: pvJakarta(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      );
}

/// Shared with the result screen.
class PcosPrimaryButton extends StatelessWidget {
  const PcosPrimaryButton(
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? ttcTitleInk : null,
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

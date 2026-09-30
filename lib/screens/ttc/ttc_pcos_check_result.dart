// =============================================================================
//  PCOS Symptom Checker — the result, and the doctor summary
// -----------------------------------------------------------------------------
//  ⚠️ THIS SCREEN IS THE ONE MOST LIKELY TO BE GOT WRONG, AND THE WAY IT GOES
//  WRONG IS BY LOOKING LIKE A RESULT.
//
//  Everything a symptom checker instinctively reaches for is banned here: a
//  percentage, a risk meter, a red/amber/green band, a "PCOS score", a disease
//  badge. Each of those turns a description of what she typed into a verdict
//  about her body — and the app cannot see her ovaries or her bloods, so it has
//  no verdict to give.
//
//  What it renders instead: three coarse dials describing what she reported,
//  prose about what that may mean, and a concrete next step. She should leave
//  understanding her own pattern, not feeling scored for a disease.
//
//  ⚠️ THE DISCLAIMER IS ON EVERY PATH, INCLUDING THE REASSURING ONE. A woman
//  who gets "no strong pattern" needs to know that is not a clean bill of
//  health more than the woman who gets "worth discussing" does — the first is
//  the result that could stop someone seeking help.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_pcos_check_data.dart';
import '../../ttc/ttc_pcos_check_rules.dart';
import '../../ttc/ttc_pcos_check_store.dart';
import '../v2/v2_palette.dart';
import 'ttc_pcos_check_screen.dart' show PcosPrimaryButton, kPcosHue;
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';
import 'ttc_common.dart' show ttcTitleInk, TtcSectionHeading;

class TtcPcosCheckResultScreen extends StatelessWidget {
  const TtcPcosCheckResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TtcPcosCheckStore.instance;

    return ListenableBuilder(
      listenable:
          Listenable.merge([store, V2PaletteStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hi = TtcLang.instance.hinglish;
        final lang = hi ? AppLanguage.hinglish : AppLanguage.english;
        String t(String en, String hin) => hi ? hin : en;

        final r = store.result;

        return Scaffold(
          backgroundColor: p.ground,
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 21, color: p.ink1),
                    ),
                  ),
                  Expanded(
                    child: Text(t('YOUR PATTERN', 'AAPKA PATTERN'),
                        style: pvManrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: p.ink3)),
                  ),
                ]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, kAskFabReserve + 24),
                  children: r.stopped
                      ? _stoppedBody(context, p, lang, t, r)
                      : _patternBody(context, p, lang, t, r, store),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  //  Stopped — red flag or possible pregnancy
  // ---------------------------------------------------------------------------
  //
  // ⚠️ NO DIALS, NO PATTERN, NO "NEXT STEPS" RAIL. Nothing on this path may
  // look like a result, because there is no result — the engine refused to
  // compute one. Offering "track your cycle" under an urgent-care message would
  // be the app talking over the thing it just said mattered.
  List<Widget> _stoppedBody(BuildContext context, V2Palette p, AppLanguage lang,
      String Function(String, String) t, PcosInterpretation r) {
    final urgent = r.stop == PcosStop.urgent;
    return [
      Container(
        padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
        decoration: BoxDecoration(
          // Kept for revert (2026-09-29, no tinted slab behind text): color: p.surfaceAlt,
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          // The coloured left rule (amber / green) is gone — BASE-UI §4.0:
          // urgency is told by the well and the words, never by a tint. Kept
          // for revert: amber 0xFFC98A25 / green 0xFF3F9E7C, width 3.
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(urgent ? Icons.phone_in_talk_outlined : Icons.spa_outlined,
              size: 20, color: p.ink2),
          const SizedBox(height: 12),
          Text(r.headline.of(lang),
              style: pvFraunces(
                  fontSize: 22,
                  height: 1.28,
                  fontWeight: FontWeight.w600,
                  color: p.ink1)),
          const SizedBox(height: 11),
          Text(r.body.of(lang),
              style: pvManrope(fontSize: 15, height: 1.68, color: p.ink2)),
        ]),
      ),
      const SizedBox(height: 24),
      if (urgent)
        PcosPrimaryButton(
          p: p,
          label: t('Talk to a doctor now', 'Abhi doctor se baat karein'),
          onTap: () => _open(context, 'ttc_prepare'),
        )
      else
        PcosPrimaryButton(
          p: p,
          label: t('Read about testing', 'Test ke baare mein padhein'),
          onTap: () => _open(context, 'ttc_read/ttc_read_pcos_cycle'),
        ),
      const SizedBox(height: 22),
      _Disclaimer(p: p, lang: lang),
    ];
  }

  // ---------------------------------------------------------------------------
  //  The pattern
  // ---------------------------------------------------------------------------

  List<Widget> _patternBody(
      BuildContext context,
      V2Palette p,
      AppLanguage lang,
      String Function(String, String) t,
      PcosInterpretation r,
      TtcPcosCheckStore store) {
    return [
      Text(r.headline.of(lang),
          style: pvFraunces(
              fontSize: 27,
              height: 1.2,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: p.ink1)),
      const SizedBox(height: 20),

      // ---- THREE DIALS, NO NUMBERS ------------------------------------------
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Column(children: [
          _Dial(
            p: p,
            label: t('Cycle pattern', 'Cycle ka pattern'),
            strength: r.patternFor(PcosDomain.cycle).strength,
            words: [
              t('Regular', 'Niyamit'),
              t('Variable', 'Badalta hua'),
              t('Irregular', 'Anisch it'),
            ],
          ),
          _Dial(
            p: p,
            label: t('Ovulation signs', 'Ovulation ke sanket'),
            strength: r.patternFor(PcosDomain.ovulation).strength,
            words: [
              t('Clear', 'Saaf'),
              t('Unclear', 'Saaf nahi'),
              t('Possibly irregular', 'Shayad anisch it'),
            ],
          ),
          _Dial(
            p: p,
            label: t('Other symptoms', 'Anya lakshan'),
            strength: r.patternFor(PcosDomain.androgen).strength,
            words: [
              t('Few', 'Kam'),
              t('Some', 'Kuch'),
              t('Several', 'Kai'),
            ],
          ),
        ]),
      ),
      const SizedBox(height: 24),

      // Kept for revert (2026-09-28): 'What this may mean'
      // Kept for revert (2026-09-29, one heading style): the same Text with
      // style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)
      TtcSectionHeading(
          t('What your answers may mean', 'Iska matlab kya ho sakta hai')),
      const SizedBox(height: 11),
      Text(r.body.of(lang),
          style: pvManrope(fontSize: 15, height: 1.7, color: p.ink2)),
      for (final line in pcosDetailLines(r)) ...[
        const SizedBox(height: 14),
        Text(line.of(lang),
            style: pvManrope(fontSize: 15, height: 1.7, color: p.ink2)),
      ],

      if (r.confidenceNote != null) ...[
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(r.confidenceNote!.of(lang),
              style: pvManrope(fontSize: 13.5, height: 1.62, color: p.ink2)),
        ),
      ],

      const SizedBox(height: 28),
      // Kept for revert (2026-09-29, one heading style): the same Text with
      // style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)
      TtcSectionHeading(t('What you can do next', 'Ab aap kya kar sakti hain')),
      const SizedBox(height: 14),

      // ⚠️ THE DOCTOR SUMMARY IS FIRST WHEN THERE IS SOMETHING TO DISCUSS, and
      // the cycle tracker is first when there is not. The most useful next step
      // genuinely differs by level, and putting a booking prompt at the top of
      // a reassuring result would be selling.
      if (r.level == PcosLevel.discuss || r.level == PcosLevel.soon) ...[
        _NextCard(
          p: p,
          title: t('Make my doctor summary', 'Doctor summary banayein'),
          body: t(
              'Everything you just told us, in the order a doctor asks for it, '
                  'with the questions worth asking.',
              'Jo abhi aapne bataya, usi kram mein jismein doctor poochhte hain '
                  '— aur poochhne layak sawaal bhi.'),
          onTap: () => _openSummary(context),
          primary: true,
        ),
        const SizedBox(height: 10),
      ],
      _NextCard(
        p: p,
        title: t('Track your cycles', 'Apne cycles track karein'),
        body: t(
            'Three months of dates tells a doctor more than any '
                "questionnaire. It's the most useful thing to bring to an "
                'appointment.',
            'Teen mahine ki tareekhein kisi bhi sawaal-jawaab se zyada batati '
                'hain, aur appointment par le jaane ke liye sabse kaam ki cheez '
                'hain.'),
        onTap: () => _open(context, 'ttc_cycle'),
      ),
      const SizedBox(height: 10),
      _NextCard(
        p: p,
        title: t('Read about PCOS', 'PCOS ke baare mein padhein'),
        body: t(
            'What PCOS is, how common it is, and what can really change '
                'it.',
            'Pattern asal mein kya hai, kitna aam hai, aur ise sach mein kya '
                'badalta hai.'),
        onTap: () => _open(context, 'ttc_read/ttc_read_pcos_cycle'),
      ),
      if (r.level != PcosLevel.discuss && r.level != PcosLevel.soon) ...[
        const SizedBox(height: 10),
        _NextCard(
          p: p,
          title: t('Make my doctor summary', 'Doctor summary banayein'),
          body: t('Good to have anyway, for whenever you next see a doctor.',
              'Waise bhi kaam aayegi, jab bhi agli baar kisi se milein.'),
          onTap: () => _openSummary(context),
        ),
      ],

      const SizedBox(height: 26),
      PcosPrimaryButton(
        p: p,
        filled: false,
        // Kept for revert (2026-09-28): 'Start again'
        label: t('Start the check again', 'Phir se shuru karein'),
        onTap: () async {
          await store.reset();
          if (context.mounted) Navigator.of(context).maybePop();
        },
      ),
      const SizedBox(height: 22),
      _Disclaimer(p: p, lang: lang),
    ];
  }

  void _open(BuildContext context, String surfaceId) {
    final screen = ttcScreenForSurface(surfaceId);
    if (screen == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: surfaceId),
      builder: (_) => screen,
    ));
  }

  void _openSummary(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc_pcos_check/summary'),
        builder: (_) => const TtcPcosDoctorSummaryScreen(),
      ));
}

// -----------------------------------------------------------------------------
//  One dial
// -----------------------------------------------------------------------------

/// Three dots and a word.
///
/// ⚠️ NOT A BAR, NOT A GAUGE, AND NOT COLOUR-CODED RED TO GREEN. A filled gauge
/// implies a measured quantity on a scale, and this is a coarse reading of what
/// she typed. Three dots say "roughly here, out of three" and cannot be
/// misread as a score.
class _Dial extends StatelessWidget {
  const _Dial(
      {required this.p,
      required this.label,
      required this.strength,
      required this.words});

  final V2Palette p;
  final String label;
  final PcosStrength strength;
  final List<String> words;

  @override
  Widget build(BuildContext context) {
    final i = switch (strength) {
      PcosStrength.quiet => 0,
      PcosStrength.some => 1,
      PcosStrength.marked => 2,
    };
    final tint = v2BlockTint(kPcosHue, p);
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.36)
        .withLightness(0.44)
        .toColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style: pvManrope(fontSize: 14, color: p.ink2)),
        ),
        Row(
          children: [
            for (var d = 0; d < 3; d++)
              Container(
                margin: const EdgeInsets.only(left: 5),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: d <= i ? ink : p.line,
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 108,
          child: Text(words[i],
              textAlign: TextAlign.right,
              style: pvManrope(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
        ),
      ]),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard(
      {required this.p,
      required this.title,
      required this.body,
      required this.onTap,
      this.primary = false});

  final V2Palette p;
  final String title;
  final String body;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 13, 15),
          decoration: BoxDecoration(
            color: primary ? v2BlockTint(kPcosHue, p) : null,
            borderRadius: BorderRadius.circular(16),
            border: primary ? null : Border.all(color: p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: pvJakarta(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color:
                                primary ? const Color(0xFF2C2135) : p.ink1)),
                    const SizedBox(height: 5),
                    Text(body,
                        style: pvManrope(
                            fontSize: 13,
                            height: 1.55,
                            color:
                                primary ? const Color(0xFF493C55) : p.ink2)),
                  ]),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 17, color: primary ? const Color(0xFF493C55) : p.ink3),
            ),
          ]),
        ),
      );
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.p, required this.lang});
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Text(
      kPcosResultDisclaimer.of(lang),
      style: pvManrope(fontSize: 12, height: 1.62, color: p.ink3));
}

// =============================================================================
//  The doctor summary
// =============================================================================
//  ⚠️ THE MOST USEFUL SCREEN IN THE FEATURE, and the one that justifies the
//  three minutes she spent.
//
//  What she gets wrong at an appointment is not honesty, it is ORDER — a doctor
//  asks cycle length, then regularity, then longest gap, then symptoms, and a
//  patient answering from memory gives them in the order they come to mind. A
//  summary in the clinical order turns a rambling five minutes into a clear
//  one, and the questions at the foot turn a passive appointment into one where
//  she can push.
//
//  ⚠️ IT CONTAINS NO INTERPRETATION. Only what she told us, and the questions
//  worth asking. Handing a doctor our reading of her symptoms would be the app
//  practising medicine at the exact moment a real clinician is in the room.
// =============================================================================

class TtcPcosDoctorSummaryScreen extends StatelessWidget {
  const TtcPcosDoctorSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TtcPcosCheckStore.instance;

    return ListenableBuilder(
      listenable:
          Listenable.merge([store, V2PaletteStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hi = TtcLang.instance.hinglish;
        final lang = hi ? AppLanguage.hinglish : AppLanguage.english;
        String t(String en, String hin) => hi ? hin : en;

        final rows = buildPcosDoctorSummary(store, lang);
        final facts = store.cycleFacts;

        return Scaffold(
          backgroundColor: p.ground,
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 21, color: p.ink1),
                    ),
                  ),
                  Expanded(
                    child: Text(
                        t('FOR YOUR APPOINTMENT', 'APPOINTMENT KE LIYE'),
                        style: pvManrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: p.ink3)),
                  ),
                  GestureDetector(
                    onTap: () => _copy(context, store, lang, t),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child:
                          Icon(Icons.copy_rounded, size: 19, color: p.ink2),
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, kAskFabReserve + 24),
                  children: [
                    Text(t('Your summary', 'Aapka summary'),
                        style: pvFraunces(
                            fontSize: 27,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: p.ink1)),
                    const SizedBox(height: 11),
                    Text(
                        t(
                            'Everything you told us, in the order a doctor '
                                'usually asks for it. Read it from your phone, '
                                'or copy it into a message.',
                            'Jo aapne bataya, usi kram mein jismein doctor aam '
                                'taur par poochhte hain. Phone se padh lein, ya '
                                'copy karke message mein daal dein.'),
                        style: pvManrope(
                            fontSize: 14.5, height: 1.62, color: p.ink2)),

                    if (facts != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                        decoration: BoxDecoration(
                          color: v2BlockTint(kPcosHue, p),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  t('FROM YOUR LOG, NOT FROM MEMORY',
                                      'NAAPA HUA, YAAD KIYA HUA NAHI'),
                                  style: pvManrope(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.1,
                                      color: const Color(0xFF3E2E48))),
                              const SizedBox(height: 8),
                              Text(
                                  t(
                                      '${facts.count} cycles logged, from '
                                          '${facts.shortest} to ${facts.longest} '
                                          'days. Usually about ${facts.median}.',
                                      '${facts.count} cycles log kiye, '
                                          '${facts.shortest} se ${facts.longest} '
                                          'din. Aam taur par: lagbhag '
                                          '${facts.median}.'),
                                  style: pvManrope(
                                      fontSize: 14.5,
                                      height: 1.55,
                                      color: const Color(0xFF2C2135))),
                            ]),
                      ),
                    ],

                    const SizedBox(height: 24),
                    for (final r in rows) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 130,
                                child: Text(r.label,
                                    style: pvManrope(
                                        fontSize: 12.5,
                                        height: 1.45,
                                        color: p.ink3)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(r.value,
                                    style: pvManrope(
                                        fontSize: 14.5,
                                        height: 1.5,
                                        fontWeight: FontWeight.w600,
                                        color: p.ink1)),
                              ),
                            ]),
                      ),
                    ],

                    const SizedBox(height: 14),
                    Divider(color: p.line, height: 1),
                    const SizedBox(height: 22),
                    // Kept for revert (2026-09-29, one heading style): the
                    // same Text with style: pvFraunces(fontSize: 19,
                    //     fontWeight: FontWeight.w600, color: p.ink1)
                    TtcSectionHeading(
                        t('Questions worth asking', 'Poochhne layak sawaal')),
                    const SizedBox(height: 12),
                    for (final q in kPcosDoctorQuestions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: ttcTitleInk, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(q.of(lang),
                                    style: pvManrope(
                                        fontSize: 14.5,
                                        height: 1.58,
                                        color: p.ink1)),
                              ),
                            ]),
                      ),

                    const SizedBox(height: 24),
                    PcosPrimaryButton(
                      p: p,
                      label: t('Copy summary', 'Summary copy karein'),
                      onTap: () => _copy(context, store, lang, t),
                    ),
                    const SizedBox(height: 22),
                    _Disclaimer(p: p, lang: lang),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _copy(BuildContext context, TtcPcosCheckStore store, AppLanguage lang,
      String Function(String, String) t) {
    final rows = buildPcosDoctorSummary(store, lang);
    final facts = store.cycleFacts;
    final buf = StringBuffer();
    if (facts != null) {
      buf.writeln('Cycles logged: ${facts.count}, '
          '${facts.shortest} to ${facts.longest} days (usually about '
          '${facts.median})');
    }
    for (final r in rows) {
      buf.writeln('${r.label}: ${r.value}');
    }
    buf.writeln();
    buf.writeln('My questions:');
    for (final q in kPcosDoctorQuestions) {
      buf.writeln('- ${q.of(lang)}');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(t('Summary copied. Paste it into a message or your notes.',
          'Summary copy ho gayi')),
    ));
  }
}

/// One line of the summary.
class PcosDoctorSummaryRow {
  const PcosDoctorSummaryRow(this.label, this.value);
  final String label;
  final String value;
}

/// Builds the summary from her answers.
///
/// ⚠️ ONLY THINGS SHE ANSWERED, AND ONLY QUESTIONS THAT DECLARED A
/// `summaryLabel`. A summary that pads with "not answered" rows wastes the
/// doctor's attention on absences, which is the opposite of what it is for.
List<PcosDoctorSummaryRow> buildPcosDoctorSummary(
    TtcPcosCheckStore store, AppLanguage lang) {
  final out = <PcosDoctorSummaryRow>[];
  for (final q in kPcosQuestions) {
    final label = q.summaryLabel;
    if (label == null) continue;
    final chosen = store.answerFor(q.id);
    if (chosen == null) continue;
    final opt = q.options.where((o) => o.id == chosen);
    if (opt.isEmpty || opt.first.unknown) continue;
    out.add(PcosDoctorSummaryRow(label.of(lang), opt.first.label.of(lang)));
  }
  return out;
}

/// ⚠️ QUESTIONS, NOT REQUESTS FOR TREATMENT. Every one is something a patient
/// may reasonably ask; none asks for a named drug. Nothing in this feature may
/// suggest letrozole, clomiphene or metformin — that is the clinician's, and a
/// patient arriving having been told to ask for a drug is a worse consultation,
/// not a better one.
final List<LocalizedText> kPcosDoctorQuestions = [
  LocalizedText(
      en: "Could my cycle pattern mean I'm not ovulating regularly?",
      hi: 'Kya mere cycle ka pattern ye bata raha hai ki ovulation niyamit nahi '
          'ho raha?'),
  LocalizedText(
      en: "Is there a way to check whether I'm ovulating?",
      hi: 'Kya ye check karne ka koi tareeka hai ki ovulation ho raha hai ya '
          'nahi?'),
  LocalizedText(
      en: 'Should I be checked for PCOS, or for another hormone cause?',
      hi: 'Kya mujhe PCOS ya kisi aur hormonal wajah ke liye jaanch karwani '
          'chahiye?'),
  LocalizedText(
      en: 'Could thyroid or prolactin explain any of this?',
      hi: 'Kya thyroid ya prolactin isme se kuch samjha sakte hain?'),
  LocalizedText(
      en: "We've been trying a while now. Is it time to look further?",
      hi: 'Hum jitne samay se koshish kar rahe hain, kya ab aage dekhna chahiye?'),
];

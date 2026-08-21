// =============================================================================
//  "See a specialist?" — the fertility snapshot she takes with her
// -----------------------------------------------------------------------------
//  ⚠️ WHAT SHE TOLD US, AND WHAT SHE LOGGED. NOTHING WE CONCLUDED.
//
//  No readiness state, no rule output, no "ParentVeda suggests". Handing a
//  specialist our reading of her situation would be the app practising medicine
//  at the exact moment a real clinician is in the room — and a doctor reading
//  "the app thinks you need an evaluation" learns nothing except that she used
//  an app.
//
//  What a doctor can use is the raw material she cannot reconstruct from
//  memory: how long, what her cycles actually did, what she has been told
//  before. That is what this is.
//
//  ⚠️ REACHABLE WITHOUT FINISHING THE CHECK — §19. Someone who has already
//  decided she wants help must not be made to answer eight questions to reach
//  a summary. It builds from whatever is available.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_fertility_help_rules.dart';
import '../../ttc/ttc_fertility_help_store.dart';
import '../v2/v2_palette.dart';
import 'ttc_fertility_help_screen.dart' show FertilityHelpButton;
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';

class TtcFertilityHelpSummaryScreen extends StatelessWidget {
  const TtcFertilityHelpSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TtcFertilityHelpStore.instance;

    return ListenableBuilder(
      listenable:
          Listenable.merge([store, V2PaletteStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hi = TtcLang.instance.hinglish;
        final lang = hi ? AppLanguage.hinglish : AppLanguage.english;
        String t(String en, String hin) => hi ? hin : en;

        final c = store.context;
        final rows = buildFertilitySnapshot(c, lang);
        final questions = fertilityQuestionsFor(c, lang);

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
                    onTap: () => _copy(context, c, lang, t),
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
                    Text(t('Your fertility snapshot', 'Aapka fertility snapshot'),
                        style: pvFraunces(
                            fontSize: 27,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: p.ink1)),
                    const SizedBox(height: 11),
                    Text(
                        t(
                            'What you have told us and what you have logged, in '
                                'the order a doctor asks for it. Read it off '
                                'your phone or copy it into a message.',
                            'Jo aapne bataya aur jo log kiya, usi kram mein '
                                'jismein doctor poochhte hain. Phone se padh '
                                'lein ya copy karke bhej dein.'),
                        style: pvManrope(
                            fontSize: 14.5, height: 1.62, color: p.ink2)),
                    const SizedBox(height: 24),

                    if (rows.isEmpty)
                      Text(
                          t(
                              'There is nothing recorded yet. Logging a few '
                                  'cycles is the single most useful thing to '
                                  'bring to a first appointment.',
                              'Abhi kuch darj nahi hai. Kuch cycles log karna '
                                  'pehli appointment ke liye sabse kaam ki cheez '
                                  'hai.'),
                          style: pvManrope(
                              fontSize: 14.5, height: 1.65, color: p.ink2))
                    else
                      for (final r in rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 122,
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

                    const SizedBox(height: 12),
                    Divider(color: p.line, height: 1),
                    const SizedBox(height: 22),
                    Text(t('Questions to take with you',
                        'Saath le jaane layak sawaal'),
                        style: pvFraunces(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                    const SizedBox(height: 12),
                    for (final q in questions)
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
                                    color: p.action, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(q,
                                    style: pvManrope(
                                        fontSize: 14.5,
                                        height: 1.6,
                                        color: p.ink1)),
                              ),
                            ]),
                      ),

                    const SizedBox(height: 24),
                    FertilityHelpButton(
                        p: p,
                        label: t('Copy this', 'Ise copy karein'),
                        onTap: () => _copy(context, c, lang, t)),
                    const SizedBox(height: 10),
                    FertilityHelpButton(
                        p: p,
                        filled: false,
                        label: t('Bring your reports too',
                            'Apni reports bhi le jaayein'),
                        onTap: () {
                          final s = ttcScreenForSurface('ttc_records');
                          if (s == null) return;
                          Navigator.of(context).push(MaterialPageRoute<void>(
                            settings:
                                const RouteSettings(name: 'ttc_records'),
                            builder: (_) => s,
                          ));
                        }),
                    const SizedBox(height: 22),
                    Text(kFertilityHelpDisclaimer.of(lang),
                        style: pvManrope(
                            fontSize: 12, height: 1.6, color: p.ink3)),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _copy(BuildContext context, FertilityHelpContext c, AppLanguage lang,
      String Function(String, String) t) {
    final buf = StringBuffer()
      ..writeln('MY FERTILITY SNAPSHOT')
      ..writeln();
    for (final r in buildFertilitySnapshot(c, lang)) {
      buf.writeln('${r.label}: ${r.value}');
    }
    buf
      ..writeln()
      ..writeln('Questions:');
    for (final q in fertilityQuestionsFor(c, lang)) {
      buf.writeln('- $q');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(t('Snapshot copied', 'Snapshot copy ho gaya')),
    ));
  }
}

@immutable
class FertilitySnapshotRow {
  const FertilitySnapshotRow(this.label, this.value);
  final String label;
  final String value;
}

/// ⚠️ ONLY WHAT IS KNOWN. No "not recorded" rows — a summary padded with
/// absences spends a doctor's attention on what is missing, which is the
/// opposite of what it is for.
List<FertilitySnapshotRow> buildFertilitySnapshot(
    FertilityHelpContext c, AppLanguage lang) {
  final out = <FertilitySnapshotRow>[];

  final trying = c.tryingLabel;
  if (trying != null) out.add(FertilitySnapshotRow('Trying for', trying.en));
  if (c.ageBand != null) {
    out.add(FertilitySnapshotRow('Age', c.ageBand!.label.en));
  }
  if (c.hasEnoughCycleData) {
    out.add(FertilitySnapshotRow(
        'Cycle pattern',
        '${c.cyclesLogged} logged, '
            '${c.cycleShortest}–${c.cycleLongest} days'));
  }
  if (c.pcosCheckDone) {
    // ⚠️ A SUMMARY OF THE CHECK, NEVER A DIAGNOSIS. The PCOS tool's own
    // disclaimer stands, and this must not quietly promote its output into
    // something firmer than the tool itself claims.
    out.add(FertilitySnapshotRow(
        'PCOS check',
        c.pcosPatternFound
            ? 'App check showed patterns worth discussing (not a diagnosis)'
            : 'App check showed no strong pattern (not a rule-out)'));
  }
  if (c.knownConditions.isNotEmpty) {
    final names = [
      for (final k in kFertilityConditions)
        if (c.knownConditions.contains(k.id)) k.label,
    ];
    out.add(FertilitySnapshotRow('Told about', names.join(', ')));
  }
  if (c.priorMiscarriages > 0) {
    out.add(FertilitySnapshotRow('Miscarriages',
        c.priorMiscarriages >= 2 ? 'Two or more' : 'One'));
  }
  if (c.painfulOrHeavyPeriods) {
    out.add(const FertilitySnapshotRow(
        'Periods', 'Very painful or very heavy, or pain during sex'));
  }
  if (c.pelvicSurgeryOrInfection) {
    out.add(const FertilitySnapshotRow(
        'Pelvic history', 'Previous surgery or infection'));
  }
  if (c.partnerConcern) {
    out.add(const FertilitySnapshotRow('Partner', 'A known concern'));
  }
  if (c.pathway == FertilityCarePathway.evaluated) {
    out.add(const FertilitySnapshotRow('Evaluation', 'Had one previously'));
  } else if (c.pathway == FertilityCarePathway.currentlyInCare) {
    out.add(const FertilitySnapshotRow('Evaluation', 'Currently under care'));
  }
  return out;
}

/// Three to five questions, chosen from her own situation.
///
/// ⚠️ QUESTIONS, NOT REQUESTS FOR TESTS OR TREATMENT. §20 — nothing here asks
/// for a named investigation or a drug. A patient arriving having been told by
/// an app to ask for a specific test is a worse consultation, not a better one.
List<String> fertilityQuestionsFor(FertilityHelpContext c, AppLanguage lang) {
  final out = <String>[];

  final trying = c.tryingLabel;
  if (trying != null) {
    out.add('We have been trying ${trying.en}. Would you recommend an '
        'evaluation at this point?');
  }
  if (c.cyclesIrregular) {
    out.add('My cycles have ranged from ${c.cycleShortest} to '
        '${c.cycleLongest} days. Could that suggest ovulation is not '
        'happening predictably?');
  }
  if (c.pcosPatternFound) {
    out.add('An app check suggested some patterns that can occur with PCOS. '
        'Is that worth looking into properly?');
  }
  out.add('Should both of us be evaluated, or just me?');
  if (c.knownConditions.isNotEmpty || c.priorMiscarriages > 0) {
    out.add('Given my history, is there anything you would want to '
        'investigate first?');
  }
  if (out.length < 4) {
    out.add('Is there anything in my history that changes what you would '
        'suggest?');
  }
  return out.take(5).toList();
}

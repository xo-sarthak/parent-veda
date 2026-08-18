// =============================================================================
//  ScanUrgentScreen — the 2am path
// -----------------------------------------------------------------------------
//  ⚠️ ~74,000 PEOPLE A MONTH SEARCH "ECTOPIC". This screen exists for them.
//
//  It is the shortest screen in the product and the most constrained. Rules, all
//  of them load-bearing:
//
//    · NO PRODUCT, NO COURSE, NO CONSULT UPSELL. Not one. A frightened woman at
//      2am is the single worst moment in the entire product to put a price in
//      front of, and doing it once would cost more trust than the paid layer
//      could ever earn back. Products is `notApplicable` on this bracket and
//      this screen is the reason the refusal has teeth.
//
//    · IT ENDS AT A PHONE, NOT A SCREEN. Every other page in the app ends at
//      more app. This one ends at a human being. If the last thing she does here
//      is tap deeper into ParentVeda, the screen has failed.
//
//    · NO DIAGNOSIS AND NO REASSURANCE. Both are dangerous here. "This is
//      probably nothing" is the sentence that keeps someone at home with a
//      ruptured ectopic; "this could be an ectopic" is a diagnosis we are not
//      allowed and not qualified to make. So every line says what to DO.
//
//    · CALM TYPOGRAPHY, NOT AN ALARM. She is already frightened. A red screen
//      with warning triangles adds panic to fear and makes the instructions
//      harder to read, which is the opposite of the job.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/scan_extras.dart';
import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';

class ScanUrgentScreen extends StatelessWidget {
  const ScanUrgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final lang = S.current;

    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: p.ink1,
        title: Text(
            const LocalizedText(
                    en: 'If something feels wrong', hi: 'अगर कुछ ठीक न लगे')
                .of(lang),
            style: pvJakarta(
                fontSize: 16, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
        children: [
          Text(
              const LocalizedText(
                      en: 'Any one of these is a reason to call your doctor '
                          'today — not to wait for your next appointment, and '
                          'not to read further here first.',
                      hi: 'इनमें से कोई भी एक बात आज ही डॉक्टर को फ़ोन करने की '
                          'वजह है — अगली appointment का इंतज़ार मत कीजिए, और '
                          'पहले यहाँ आगे पढ़ने की भी ज़रूरत नहीं।')
                  .of(lang),
              style: pvManrope(fontSize: 15, height: 1.55, color: p.ink1)),
          const SizedBox(height: 22),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: Column(children: [
              for (final sign in kScanUrgentSigns) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(top: 7, right: 12),
                          decoration: BoxDecoration(
                              color: p.action, shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Text(sign.of(lang),
                              style: pvManrope(
                                  fontSize: 14.5,
                                  height: 1.45,
                                  color: p.ink1)),
                        ),
                      ]),
                ),
                if (sign != kScanUrgentSigns.last)
                  Divider(height: 1, thickness: 1, color: p.line, indent: 35),
              ],
            ]),
          ),
          const SizedBox(height: 24),
          // ⚠️ THE SCREEN ENDS HERE, AT A PERSON.
          //
          // No "read more", no related articles, no Ask Veda. The instruction
          // is to stop using the app.
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      const LocalizedText(
                              en: 'Call, do not message',
                              hi: 'फ़ोन कीजिए, message नहीं')
                          .of(lang),
                      style: pvFraunces(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: p.ink1)),
                  const SizedBox(height: 8),
                  Text(
                      const LocalizedText(
                              en: 'Your obstetrician, the labour ward, or the '
                                  'nearest hospital with a maternity unit. If '
                                  'you cannot reach anyone and the pain or '
                                  'bleeding is bad, go in. Nobody will mind '
                                  'you coming and being sent home.',
                              hi: 'अपनी gynae को, labour ward को, या नज़दीकी '
                                  'ऐसे अस्पताल को जहाँ maternity है। अगर किसी '
                                  'से बात न हो पा रही हो और दर्द या ख़ून ज़्यादा '
                                  'है, तो चली जाइए। जाकर वापस भेज दिए जाने में '
                                  'किसी को कोई परेशानी नहीं होती।')
                          .of(lang),
                      style: pvManrope(
                          fontSize: 14, height: 1.55, color: p.ink2)),
                ]),
          ),
          const SizedBox(height: 18),
          Text(
              const LocalizedText(
                      en: 'ParentVeda cannot tell you what is happening. This '
                          'list exists only so you know which things are worth '
                          'a call.',
                      hi: 'ParentVeda यह नहीं बता सकता कि हो क्या रहा है। यह '
                          'सूची सिर्फ़ इसलिए है कि आपको पता रहे कि किन बातों पर '
                          'फ़ोन करना बनता है।')
                  .of(lang),
              style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
        ],
      ),
    );
  }
}

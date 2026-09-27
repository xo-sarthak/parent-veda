// =============================================================================
//  BMI — intro, input, result
// -----------------------------------------------------------------------------
//  V3 language: `V2PaletteStore`, `pv_fonts`, hairlines not shadows, flat tint
//  not gradient — matching the reader, the vaccination surface, the PCOS
//  checker and the checklist.
//
//  ⚠️ THE SCALE IS NOT A DANGER METER. No red zone, no warning triangle, no
//  needle swinging into a bad region. It is a plain track with four labelled
//  segments and a marker showing where a number sits — location, not verdict.
//  A gauge that turns red is the single easiest way to make this screen the
//  thing the brief spent thirty sections refusing to build.
//
//  ⚠️ AND NOTHING SAYS "YOU ARE". Bands describe where a number falls. The
//  difference between "your BMI is above the standard range" and "you are
//  overweight" is the whole tone of this feature.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_bmi_rules.dart';
import '../../ttc/ttc_bmi_store.dart';
import '../../ttc/ttc_chapter.dart' show kTtcIrregularSpreadDays;
import '../../ttc/ttc_pcos_check_rules.dart';
import '../../ttc/ttc_pcos_check_store.dart';
import '../v2/v2_palette.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';

/// Getting ready is 104 — the tool keeps its door's colour.
const double kBmiHue = 104;

class TtcBmiScreen extends StatefulWidget {
  const TtcBmiScreen({super.key});

  @override
  State<TtcBmiScreen> createState() => _TtcBmiScreenState();
}

enum _Stage { intro, input, result }

class _TtcBmiScreenState extends State<TtcBmiScreen> {
  _Stage _stage = _Stage.intro;

  final _height = TextEditingController();
  final _feet = TextEditingController();
  final _inches = TextEditingController();
  final _weight = TextEditingController();

  BmiCalculation? _calc;
  BmiInputError _error = BmiInputError.none;
  bool _showLimitations = false;

  TtcBmiStore get _store => TtcBmiStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load().then((_) {
      if (!mounted) return;
      // ⚠️ PRE-FILL FROM HER SAVED MEASUREMENTS. §4 and §31 — she should not
      // type her height twice in the same app.
      final last = _store.latest;
      if (last != null) {
        _height.text = (last.metres * 100).toStringAsFixed(0);
        final totalIn = last.metres / 0.0254;
        _feet.text = (totalIn ~/ 12).toString();
        _inches.text = (totalIn % 12).toStringAsFixed(0);
        _weight.text = _store.weightUnit == BmiWeightUnit.kg
            ? last.kilograms.toStringAsFixed(1)
            : (last.kilograms / 0.45359237).toStringAsFixed(1);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _height.dispose();
    _feet.dispose();
    _inches.dispose();
    _weight.dispose();
    super.dispose();
  }

  BmiContext get _context {
    final pcos = TtcPcosCheckStore.instance;
    final r = pcos.hasCompleted ? pcos.result : null;
    final cycles = CycleStore.instance.cycleLengths;
    final spread = cycles.isEmpty
        ? 0
        : cycles.reduce((a, b) => a > b ? a : b) -
            cycles.reduce((a, b) => a < b ? a : b);
    return BmiContext(
      hasPcosPattern: r != null &&
          !r.stopped &&
          (r.level == PcosLevel.discuss || r.level == PcosLevel.soon),
      // The one definition of irregular (2026-09-26). Was `spread > 7`.
      irregularCycles:
          cycles.length >= 2 && spread > kTtcIrregularSpreadDays,
      previousKg: _store.latest?.kilograms,
    );
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
                  _Stage.intro => _intro(p, t),
                  _Stage.input => _input(p, lang, t),
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
            child: Text(t('BMI', 'BMI'),
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
      case _Stage.input:
        setState(() => _stage = _Stage.intro);
      case _Stage.result:
        setState(() => _stage = _Stage.input);
    }
  }

  // ---------------------------------------------------------------------------

  Widget _intro(V2Palette p, String Function(String, String) t) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, kAskFabReserve + 24),
        children: [
          Text(t("Let's put one number in context.",
              'Ek number ko sahi sandarbh mein rakhte hain.'),
              style: pvFraunces(
                  fontSize: 29,
                  height: 1.18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: p.ink1)),
          const SizedBox(height: 14),
          Text(
              t(
                  'BMI is one measure worked out from your height and weight. '
                      "It can be a useful place to start. It doesn't tell the "
                      'whole story about your health, your fertility, or '
                      "whether you're ready for pregnancy.",
                  'BMI aapki height aur weight se nikla ek saada maap hai. Ye '
                      'shuruaat ke liye kaam ka hai, aur ye aapki sehat, '
                      'fertility ya pregnancy ki taiyaari ki poori kahani nahi '
                      'batata.'),
              style: pvFraunces(fontSize: 16.5, height: 1.58, color: p.ink2)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
            decoration: BoxDecoration(
              color: v2BlockTint(kBmiHue, p),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
                t('Your BMI is information, not a judgement.',
                    'Aapka BMI ek jaankari hai, faisla nahi.'),
                style: pvFraunces(
                    fontSize: 17.5,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF23301F))),
          ),
          const SizedBox(height: 24),
          _Button(
              p: p,
              label: t('Calculate my BMI', 'Mera BMI nikaalein'),
              onTap: () => setState(() => _stage = _Stage.input)),
          const SizedBox(height: 16),
          Text(kBmiDisclaimer.en,
              style: pvManrope(fontSize: 12, height: 1.6, color: p.ink3)),
        ],
      );

  // ---------------------------------------------------------------------------

  Widget _input(
      V2Palette p, AppLanguage lang, String Function(String, String) t) {
    final metric = _store.heightUnit == BmiHeightUnit.cm;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, kAskFabReserve + 24),
      children: [
        if (_store.hasSavedMeasurements) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              Icon(Icons.history_rounded, size: 16, color: p.action),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    t("We've used your saved measurements. Change anything "
                        "that's different now.",
                        'Aapke save kiye maap istemaal ho rahe hain. Jo badla '
                            'ho use badal dein.'),
                    style: pvManrope(
                        fontSize: 12.5, height: 1.5, color: p.ink2)),
              ),
            ]),
          ),
          const SizedBox(height: 22),
        ],

        Text(t('Height', 'Height'),
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: p.ink3)),
        const SizedBox(height: 10),
        Row(children: [
          if (metric)
            Expanded(child: _field(p, _height, 'cm'))
          else ...[
            Expanded(child: _field(p, _feet, 'ft')),
            const SizedBox(width: 10),
            Expanded(child: _field(p, _inches, 'in')),
          ],
          const SizedBox(width: 10),
          _UnitToggle(
            p: p,
            left: 'cm',
            right: 'ft/in',
            leftOn: metric,
            onTap: (l) => _store.setUnits(
                height: l ? BmiHeightUnit.cm : BmiHeightUnit.ftIn),
          ),
        ]),
        const SizedBox(height: 22),

        Text(t('Weight', 'Weight'),
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: p.ink3)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _field(p, _weight,
                  _store.weightUnit == BmiWeightUnit.kg ? 'kg' : 'lb')),
          const SizedBox(width: 10),
          _UnitToggle(
            p: p,
            left: 'kg',
            right: 'lb',
            leftOn: _store.weightUnit == BmiWeightUnit.kg,
            onTap: (l) => _store.setUnits(
                weight: l ? BmiWeightUnit.kg : BmiWeightUnit.lb),
          ),
        ]),

        if (_error != BmiInputError.none) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, size: 16, color: p.ink2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(bmiErrorCopy(_error).of(lang),
                    style: pvManrope(
                        fontSize: 13, height: 1.55, color: p.ink2)),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 26),
        _Button(
            p: p,
            label: t('See my result', 'Mera result dekhein'),
            onTap: _submit),
      ],
    );
  }

  Widget _field(V2Palette p, TextEditingController c, String suffix) =>
      TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        style: pvJakarta(fontSize: 17, fontWeight: FontWeight.w600,
            color: p.ink1),
        decoration: InputDecoration(
          suffixText: suffix,
          suffixStyle: pvManrope(fontSize: 14, color: p.ink3),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: p.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: p.action, width: 1.5),
          ),
        ),
      );

  void _submit() {
    final input = BmiInput(
      heightUnit: _store.heightUnit,
      weightUnit: _store.weightUnit,
      cm: double.tryParse(_height.text),
      feet: int.tryParse(_feet.text),
      inches: double.tryParse(_inches.text),
      kg: _store.weightUnit == BmiWeightUnit.kg
          ? double.tryParse(_weight.text)
          : null,
      lb: _store.weightUnit == BmiWeightUnit.lb
          ? double.tryParse(_weight.text)
          : null,
    );
    final err = validateBmiInput(input);
    if (err != BmiInputError.none) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _error = BmiInputError.none;
      _calc = calculateBmi(input);
      _stage = _Stage.result;
    });
  }

  // ---------------------------------------------------------------------------

  Widget _result(
      V2Palette p, AppLanguage lang, String Function(String, String) t) {
    final calc = _calc;
    if (calc == null) return const SizedBox.shrink();

    final ctx = _context;
    final r = interpretBmi(calc, ctx);
    // ⚠️ SOUTH ASIAN IS THE PRIMARY READING. See the head of the rules file.
    final primary = categoriseBmi(calc.bmi, kBmiPrimaryStandard);
    final secondary = categoriseBmi(calc.bmi, kBmiSecondaryStandard);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, kAskFabReserve + 24),
      children: [
        Text(t('Your BMI', 'Aapka BMI'),
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: p.ink3)),
        const SizedBox(height: 10),
        Text(calc.display,
            style: pvFraunces(
                fontSize: 54,
                height: 1.0,
                fontWeight: FontWeight.w600,
                letterSpacing: -2,
                color: p.ink1)),
        const SizedBox(height: 10),
        Text(primary.label.of(lang),
            style: pvFraunces(
                fontSize: 20,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: p.ink1)),
        const SizedBox(height: 4),
        Text(
            t('using the South Asian cut-offs',
                'South Asian thresholds ke hisaab se'),
            style: pvManrope(fontSize: 13, color: p.ink3)),

        const SizedBox(height: 22),
        _Scale(p: p, bmi: calc.bmi),
        const SizedBox(height: 22),

        // ---- THE SECOND READING ---------------------------------------------
        Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                t('YOU MAY SEE THIS DESCRIBED DIFFERENTLY',
                    'AAPKO YE ALAG BATAYA JA SAKTA HAI'),
                style: pvManrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.ink3)),
            const SizedBox(height: 9),
            Text(
                t(
                    'Using the international cut-offs, ${calc.display} is '
                        '"${secondary.label.en.toLowerCase()}".',
                    'International thresholds ke hisaab se, ${calc.display} '
                        '"${secondary.label.en.toLowerCase()}" hai.'),
                style: pvManrope(
                    fontSize: 14, height: 1.6, color: p.ink1)),
            const SizedBox(height: 9),
            Text(kBmiStandardsExplainer.of(lang),
                style: pvManrope(
                    fontSize: 13, height: 1.62, color: p.ink2)),
          ]),
        ),

        const SizedBox(height: 26),
        Text(t('What this means', 'Iska matlab kya hai'),
            style: pvFraunces(
                fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 10),
        Text(r.body.of(lang),
            style: pvManrope(fontSize: 15, height: 1.7, color: p.ink2)),

        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                t('What does this mean before pregnancy?',
                    'Pregnancy se pehle iska kya matlab?'),
                style: pvJakarta(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink1)),
            const SizedBox(height: 9),
            Text(r.preconception.of(lang),
                style: pvManrope(fontSize: 14, height: 1.68, color: p.ink2)),
          ]),
        ),

        if (r.contextNote != null) ...[
          const SizedBox(height: 14),
          Text(r.contextNote!.of(lang),
              style: pvManrope(fontSize: 14, height: 1.65, color: p.ink2)),
        ],

        if (r.changeNote != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.line),
            ),
            child: Text(r.changeNote!.of(lang),
                style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink2)),
          ),
        ],

        // ---- THE EDITORIAL BEAT ---------------------------------------------
        const SizedBox(height: 28),
        Text(kBmiNotTheWholeStory.of(lang),
            style: pvFraunces(
                fontSize: 17.5,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: p.ink2)),
        const SizedBox(height: 24),

        // ---- LIMITATIONS ----------------------------------------------------
        GestureDetector(
          onTap: () => setState(() => _showLimitations = !_showLimitations),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 13, 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                          t("Why BMI isn't the whole story",
                              'BMI poori kahani kyun nahi hai'),
                          style: pvJakarta(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                    ),
                    Icon(
                        _showLimitations
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20,
                        color: p.ink3),
                  ]),
                  if (_showLimitations) ...[
                    const SizedBox(height: 12),
                    Text(t('BMI does not measure:', 'BMI ye nahi naapta:'),
                        style: pvManrope(fontSize: 13, color: p.ink3)),
                    const SizedBox(height: 8),
                    for (final l in kBmiLimitations)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 7),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: p.ink3, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(l.of(lang),
                                    style: pvManrope(
                                        fontSize: 13.5,
                                        height: 1.55,
                                        color: p.ink2)),
                              ),
                            ]),
                      ),
                    const SizedBox(height: 6),
                    Text(
                        t(
                            "That's why a doctor never uses BMI on its own to "
                                'decide if someone is healthy or ready for '
                                'pregnancy.',
                            'Isiliye doctor akele BMI se ye tay nahi karte ki '
                                'koi sehatmand hai ya pregnancy ke liye taiyaar.'),
                        style: pvManrope(
                            fontSize: 13.5, height: 1.6, color: p.ink2)),
                  ],
                ]),
          ),
        ),

        const SizedBox(height: 26),
        Text(t('What next?', 'Ab kya?'),
            style: pvFraunces(
                fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 12),
        _Next(
            p: p,
            title: _store.onChecklist
                ? t('Added to your checklist', 'Checklist mein jud gaya')
                : t('Add this to my checklist', 'Isse meri checklist mein jodein'),
            body: t(
                'Saved with your before-pregnancy checklist as a measurement. '
                    "It won't mark any medical item as done.",
                'Aapke pre-pregnancy snapshot ke saath, ek maap ki tarah — kisi '
                    'poore ho chuke medical kaam ki tarah nahi.'),
            onTap: () => _store.setOnChecklist(true)),
        const SizedBox(height: 10),
        _Next(
            p: p,
            title: t('Eating well before pregnancy',
                'Pregnancy se pehle ka khaana'),
            body: t('Built around what an Indian kitchen already cooks.',
                'Jo Indian kitchen mein pehle se banta hai, usi par bana.'),
            onTap: () => _open('ttc_nutrition')),
        const SizedBox(height: 10),
        _Next(
            p: p,
            title: t('The three months before', 'Pehle ke teen mahine'),
            body: t('Why these months matter, and how much weight really does.',
                'Ye window kyun, aur weight sach mein kitna maayne rakhta hai.'),
            onTap: () => _open('ttc_read/ttc_read_three_months_before')),

        const SizedBox(height: 24),
        _Button(
            p: p,
            label: t('Save this measurement', 'Ye maap save karein'),
            onTap: () async {
              await _store.save(calc);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(t('Measurement saved.', 'Save ho gaya')),
              ));
            }),
        const SizedBox(height: 10),
        _Button(
            p: p,
            filled: false,
            label: t('Edit measurements', 'Maap badlein'),
            onTap: () => setState(() => _stage = _Stage.input)),

        const SizedBox(height: 22),
        Text(kBmiDisclaimer.of(lang),
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
}

// -----------------------------------------------------------------------------
//  The scale
// -----------------------------------------------------------------------------

/// ⚠️ A LOCATION, NOT A RISK METER.
///
/// One neutral track, four segments in one hue at different weights, and a
/// marker. No red, no amber, no gradient from safe to dangerous. The moment a
/// segment turns red this stops being "here is where a number sits" and becomes
/// "here is how bad you are", which is what thirty sections of the brief exist
/// to prevent.
class _Scale extends StatelessWidget {
  const _Scale({required this.p, required this.bmi});
  final V2Palette p;
  final double bmi;

  @override
  Widget build(BuildContext context) {
    // Segments by the SOUTH ASIAN cuts, plotted on a 15–35 track.
    const lo = 15.0, hi = 35.0;
    double frac(double v) => ((v - lo) / (hi - lo)).clamp(0.0, 1.0);

    final tint = v2BlockTint(kBmiHue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.30)
        .withLightness(0.62)
        .toColor();

    final stops = <(double, double, Color)>[
      (frac(lo), frac(kBmiUnderCut), tint),
      (frac(kBmiUnderCut), frac(kBmiOverCutSouthAsian), deep),
      (frac(kBmiOverCutSouthAsian), frac(kBmiObeseCutSouthAsian), tint),
      (frac(kBmiObeseCutSouthAsian), 1.0, deep),
    ];

    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 34,
          child: Stack(children: [
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Row(
                  children: [
                    for (final s in stops)
                      Expanded(
                        flex: (((s.$2 - s.$1) * 1000).round()).clamp(1, 100000),
                        child: Container(height: 8, color: s.$3),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: (frac(bmi) * w - 9).clamp(0.0, w - 18),
              top: 7,
              child: Container(
                width: 18,
                height: 22,
                decoration: BoxDecoration(
                  color: p.ink1,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.ground, width: 3),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _tick(p, '15')),
          Expanded(child: _tick(p, '18.5')),
          Expanded(child: _tick(p, '23')),
          Expanded(child: _tick(p, '25')),
          Expanded(child: _tick(p, '35')),
        ]),
      ]);
    });
  }

  Widget _tick(V2Palette p, String s) => Text(s,
      textAlign: TextAlign.center,
      style: pvManrope(fontSize: 10.5, color: p.ink3));
}

// -----------------------------------------------------------------------------

class _UnitToggle extends StatelessWidget {
  const _UnitToggle(
      {required this.p,
      required this.left,
      required this.right,
      required this.leftOn,
      required this.onTap});

  final V2Palette p;
  final String left;
  final String right;
  final bool leftOn;
  final void Function(bool isLeft) onTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _seg(left, leftOn, () => onTap(true)),
          _seg(right, !leftOn, () => onTap(false)),
        ]),
      );

  Widget _seg(String label, bool on, VoidCallback tap) => GestureDetector(
        onTap: tap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minWidth: 46, minHeight: 44),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: on ? p.action : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : p.ink2)),
        ),
      );
}

class _Next extends StatelessWidget {
  const _Next(
      {required this.p,
      required this.title,
      required this.body,
      required this.onTap});

  final V2Palette p;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 13, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
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
                            color: p.ink1)),
                    const SizedBox(height: 5),
                    Text(body,
                        style: pvManrope(
                            fontSize: 13, height: 1.55, color: p.ink2)),
                  ]),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 17, color: p.ink3),
            ),
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

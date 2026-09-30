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
//
//  ---------------------------------------------------------------------------
//  ⚠️ HER MEASUREMENTS ARE A RECORD SHE CAN SEE (tool rebuild, 2026-09-27)
//  ---------------------------------------------------------------------------
//
//  The history was saved and never shown. She could not look at a past
//  result, could not see what a saved number was worked out from, and could
//  not remove a wrong one (a weight in pounds saved as kilograms stayed and fed
//  the change note for good). Now:
//
//  · The tool opens on the fields, with a "Your last check" card over them
//    when she has saved one (the same card the PCOS and specialist checks
//    open with), whose "See my result" opens that saved result.
//  · Every result says what it was worked out from ("From 160 cm and
//    55.0 kg") and, for a saved one, when.
//  · "Your saved measurements" lists every entry, newest first. Tap one to
//    see it; the cross removes it, with Undo.
//  · The change note compares with the entry BEFORE the one on screen. It
//    used to compare with the latest saved, so the moment she tapped Save the
//    new entry became "the last one" and the note compared the number with
//    itself and vanished.
//
//  Mobbin: Alma weight "All entries" (dated rows under the current value,
//  "Add new weight entry"),
//  https://mobbin.com/screens/d5d1920d-5970-4437-92d8-e9097400bac1 ;
//  MyFitnessPal Measurements "Entries",
//  https://mobbin.com/screens/3415f72a-4f7c-4011-8984-62dd27a54826 ; Tempo
//  dated report with "Start a new scan",
//  https://mobbin.com/screens/6d7a03a8-17eb-4144-8015-4a42b705e3ad . Gap
//  analysis: "Weight before pregnancy, said kindly" and the South Asian BMI
//  tool are ours already; the gap is keeping and showing what she saved.
// =============================================================================

import 'package:flutter/material.dart';

// Kept for revert (2026-09-27): only the old stage lists' bottom padding read
// `kAskFabReserve`; `TtcToolScaffold`'s sheet clears the reserve itself.
// import '../../widgets/global_ask_fab.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_bmi_rules.dart';
import '../../ttc/ttc_bmi_store.dart';
import '../../ttc/ttc_chapter.dart' show kTtcIrregularSpreadDays;
import '../../ttc/ttc_pcos_check_rules.dart';
import '../../ttc/ttc_pcos_check_store.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_tool_hues.dart';
import '../../ttc/ttc_cycle_report.dart' show kTtcWeightTracker, kTtcWeightField;
import '../../ttc/ttc_log_store.dart';
import 'ttc_common.dart' show ttcTitleInk, TtcSectionHeading;

/// ⚠️ T6 (launch sanity, 2026-09-28): the tool wears its Tools group's
/// colour, "Your body" (see ttc_tool_hues.dart). Kept for revert (2026-09-28):
/// "Getting ready is 104 — the tool keeps its door's colour."
/// const double kBmiHue = 104;
const double kBmiHue = kTtcToolHueBody;

class TtcBmiScreen extends StatefulWidget {
  const TtcBmiScreen({super.key});

  @override
  State<TtcBmiScreen> createState() => _TtcBmiScreenState();
}

enum _Stage { intro, input, result }

class _TtcBmiScreenState extends State<TtcBmiScreen> {
  // ⚠️ OPENS ON THE TWO FIELDS (tools pass, 2026-09-27). The intro screen was
  // a tap before the only two things that matter; its framing is now one
  // line above the fields. `_intro` stays below, unreached. Kept for revert:
  // `_Stage _stage = _Stage.intro;`
  _Stage _stage = _Stage.input;

  /// The calculation she saved from this result, so "Save" becomes "Saved"
  /// and a second tap cannot save the same measurement twice.
  BmiCalculation? _savedCalc;

  /// The saved entry the result is showing, if it is one. Drives the "Saved
  /// on" line, the highlight in the list and what the change note compares
  /// with.
  BmiHistoryEntry? _shownEntry;
  bool _showStandards = false;

  final _height = TextEditingController();
  final _feet = TextEditingController();
  final _inches = TextEditingController();
  final _weight = TextEditingController();

  BmiCalculation? _calc;
  BmiInputError _error = BmiInputError.none;
  bool _showLimitations = false;

  TtcBmiStore get _store => TtcBmiStore.instance;

  /// Where each prefilled field came from, said under its label
  /// (launch sanity T2, 2026-09-28). Null once she types over it.
  String? _heightFrom;
  String? _weightFrom;
  String _heightFilled = '';
  String _weightFilled = '';

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
      _prefillFromWhatWeHold();
      setState(() {});
    });
    // The Weight log loads on its own; if it lands after this screen, fill
    // from it then (once).
    if (!TtcLogStore.instance.isLoaded) {
      TtcLogStore.instance.addListener(_onLogLoaded);
    }
    _height.addListener(_typedOver);
    _feet.addListener(_typedOver);
    _inches.addListener(_typedOver);
    _weight.addListener(_typedOver);
  }

  void _onLogLoaded() {
    if (!TtcLogStore.instance.isLoaded) return;
    TtcLogStore.instance.removeListener(_onLogLoaded);
    if (!mounted || _weightFrom != null) return;
    setState(_prefillFromWhatWeHold);
  }

  /// ⚠️ DERIVE, NEVER ASK (launch sanity T2, 2026-09-28). The walk found both
  /// boxes empty although she had logged a weight in the Weight tool. Height
  /// is the one she gave last time (kept even when she did not save the
  /// result, see `TtcBmiStore.heightMetres`); weight is her latest Weight log
  /// when it is as new as her last saved measurement or newer. Each says
  /// where it came from and stays a plain editable field.
  void _prefillFromWhatWeHold() {
    final m = _store.heightMetres;
    if (m != null) {
      _height.text = (m * 100).toStringAsFixed(0);
      final totalIn = m / 0.0254;
      _feet.text = (totalIn ~/ 12).toString();
      _inches.text = (totalIn % 12).toStringAsFixed(0);
      _heightFrom = 'Saved from last time. Change it if it is wrong.';
      _heightFilled = _heightKey;
    }
    final logged =
        TtcLogStore.instance.latest(kTtcWeightTracker, kTtcWeightField);
    final last = _store.latest;
    if (logged != null &&
        (last == null || !logged.day.isBefore(_dayOnly(last.at)))) {
      final kg = logged.value;
      _weight.text = _store.weightUnit == BmiWeightUnit.kg
          ? kg.toStringAsFixed(1)
          : (kg / 0.45359237).toStringAsFixed(1);
      _weightFrom = 'From your Weight log, ${ttcToolDate(logged.day)}. '
          'Change it if it is different now.';
      _weightFilled = _weight.text;
    } else if (last != null) {
      _weightFrom = 'From your last saved measurement. Change it if it is '
          'different now.';
      _weightFilled = _weight.text;
    }
  }

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String get _heightKey => '${_height.text}|${_feet.text}|${_inches.text}';

  /// The "from your log" line goes once she types a different number.
  void _typedOver() {
    var changed = false;
    if (_heightFrom != null && _heightKey != _heightFilled) {
      _heightFrom = null;
      changed = true;
    }
    if (_weightFrom != null && _weight.text != _weightFilled) {
      _weightFrom = null;
      changed = true;
    }
    if (changed && mounted) setState(() {});
  }

  @override
  void dispose() {
    TtcLogStore.instance.removeListener(_onLogLoaded);
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
      // ⚠️ THE ENTRY BEFORE THE ONE ON SCREEN (2026-09-27). Was
      // `_store.latest?.kilograms`, which after Save is the number on screen
      // itself, so the note compared a measurement with itself and vanished.
      previousKg: _previousKg,
    );
  }

  double? get _previousKg {
    final shown = _shownEntry;
    if (shown == null) return _store.latest?.kilograms;
    final h = _store.history;
    final i = h.indexOf(shown);
    return i > 0 ? h[i - 1].kilograms : null;
  }

  /// Open a saved measurement's result.
  void _openEntry(BmiHistoryEntry e) {
    final calc =
        BmiCalculation(bmi: e.bmi, metres: e.metres, kilograms: e.kilograms);
    setState(() {
      _calc = calc;
      _savedCalc = calc;
      _shownEntry = e;
      _showStandards = false;
      _showLimitations = false;
      _stage = _Stage.result;
    });
  }

  /// Remove one saved measurement, with Undo.
  void _remove(BmiHistoryEntry e) {
    _store.removeEntry(e);
    if (identical(_shownEntry, e)) {
      // The number stays on screen, now unsaved, so Save offers itself again.
      setState(() {
        _shownEntry = null;
        _savedCalc = null;
      });
    }
    pvSnack(context, 'Measurement from ${ttcToolDate(e.at)} removed.',
        action: 'Undo', lift: 24, onAction: () => _store.restoreEntry(e));
  }

  String _weightText(double kg) => _store.weightUnit == BmiWeightUnit.kg
      ? '${kg.toStringAsFixed(1)} kg'
      : '${(kg / 0.45359237).toStringAsFixed(1)} lb';

  String _heightText(double m) {
    if (_store.heightUnit == BmiHeightUnit.cm) {
      return '${(m * 100).toStringAsFixed(0)} cm';
    }
    final totalIn = (m / 0.0254).round();
    return "${totalIn ~/ 12} ft ${totalIn % 12} in";
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

        // ⚠️ ONE SHELL FOR EVERY TOOL (2026-09-27). This was a white page
        // under a "BMI" crumb with bright purple filled segments and
        // buttons, beside tools that all wear `TtcToolScaffold`. "ParentVeda
        // is one app... we cannot be having same things represented as
        // different." Only the shell and chrome changed: the eyebrow is the
        // Tools tile's name, the input's title and one line are the hero,
        // and each stage's blocks sit in the sheet unchanged. The close
        // button leaves the tool like every other tool; "Edit measurements"
        // on the result is the way back to the fields.
        // Kept for revert (2026-09-27):
        // return Scaffold(
        //   backgroundColor: p.ground,
        //   body: SafeArea(
        //     bottom: false,
        //     child: Column(children: [
        //       _bar(p, t),
        //       Expanded(
        //         child: switch (_stage) {
        //           _Stage.intro => _intro(p, t),
        //           _Stage.input => _input(p, lang, t),
        //           _Stage.result => _result(p, lang, t),
        //         },
        //       ),
        //     ]),
        //   ),
        // );
        return TtcToolScaffold(
          // A fresh page per stage, so the result opens at its top rather
          // than at the fields' scroll offset.
          // And a fresh page per result (2026-09-27), so tapping a saved
          // entry at the foot of the list opens its result at the top.
          // Kept for revert: key: ValueKey(_stage),
          key: ValueKey((_stage, identityHashCode(_calc))),
          hue: kBmiHue,
          // ⚠️ ONE TOOL, ONE NAME: the Tools tile's name, word for word.
          // T1/T2 (2026-09-28): BMI is folded into the Weight tool (its page
          // carries the BMI row that opens this), and the separate "Weight
          // and fertility" tile is gone, so the eyebrow is Weight's.
          // Kept for revert (2026-09-28):
          // eyebrow: t('Weight and fertility', 'Wazan aur fertility'),
          eyebrow: t('Weight', 'Wazan'),
          title: _stage == _Stage.result
              ? 'Where your number sits.'
              : 'Work out your BMI.',
          // What this is, first: the intro screen folded into one line
          // (2026-09-27). The result has already been framed by it.
          intro: _stage == _Stage.result
              ? null
              : 'BMI is one number worked out from your height and weight. '
                  "It's information, not a judgement.",
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                ...switch (_stage) {
                  _Stage.intro => _intro(p, t),
                  _Stage.input => _input(p, lang, t),
                  _Stage.result => _result(p, lang, t),
                },
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }

  // Kept for revert (2026-09-27): the old back bar and its "BMI" crumb, and
  // the back that stepped result -> fields. `TtcToolScaffold`'s close
  // button replaces both; "Edit measurements" steps back to the fields.
  // Widget _bar(V2Palette p, String Function(String, String) t) => Padding(
  //       padding: const EdgeInsets.fromLTRB(8, 4, 16, 6),
  //       child: Row(children: [
  //         GestureDetector(
  //           onTap: _back,
  //           behavior: HitTestBehavior.opaque,
  //           child: Padding(
  //             padding: const EdgeInsets.all(10),
  //             child: Icon(Icons.arrow_back_rounded, size: 21, color: p.ink1),
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(t('BMI', 'BMI'),
  //               style: pvManrope(
  //                   fontSize: 10.5,
  //                   fontWeight: FontWeight.w800,
  //                   letterSpacing: 1.1,
  //                   color: p.ink3)),
  //         ),
  //       ]),
  //     );
  //
  // void _back() {
  //   switch (_stage) {
  //     case _Stage.intro:
  //       Navigator.of(context).maybePop();
  //     // Kept for revert: `setState(() => _stage = _Stage.intro);`
  //     case _Stage.input:
  //       Navigator.of(context).maybePop();
  //     case _Stage.result:
  //       setState(() => _stage = _Stage.input);
  //   }
  // }

  // ---------------------------------------------------------------------------

  // The stages hand their blocks to the tool sheet now (2026-09-27), so each
  // returns a list rather than its own ListView. Kept for revert:
  // Widget _intro(...) => ListView(
  //       padding: const EdgeInsets.fromLTRB(20, 8, 20, kAskFabReserve + 24),
  //       children: [
  List<Widget> _intro(V2Palette p, String Function(String, String) t) =>
      <Widget>[
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
        ];
  // Kept for revert (2026-09-27): the ListView's closing `],\n );`.

  // ---------------------------------------------------------------------------

  List<Widget> _input(
      V2Palette p, AppLanguage lang, String Function(String, String) t) {
    final metric = _store.heightUnit == BmiHeightUnit.cm;
    // Kept for revert (2026-09-27): the stage's own ListView, and its title
    // and line, which are the tool hero's title and intro now.
    // return ListView(
    //   padding: const EdgeInsets.fromLTRB(20, 8, 20, kAskFabReserve + 24),
    //   children: [
    //     Text('Work out your BMI.',
    //         style: pvFraunces(
    //             fontSize: 27,
    //             height: 1.18,
    //             fontWeight: FontWeight.w600,
    //             letterSpacing: -0.4,
    //             color: p.ink1)),
    //     const SizedBox(height: 10),
    //     Text(
    //         'BMI is one number worked out from your height and weight. '
    //         "It's information, not a judgement.",
    //         style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
    //     const SizedBox(height: 22),
    final last = _store.latest;
    return <Widget>[
        // ⚠️ HER LAST CHECK, FIRST (2026-09-27): the card the PCOS and
        // specialist checks open with too. It replaces the note below, which
        // said her measurements were used and gave no way to see the result.
        if (last != null) ...[
          TtcToolLastCheck(
            key: const ValueKey('ttc_bmi_last'),
            at: last.at,
            line: 'Your BMI was ${last.bmi.toStringAsFixed(1)}: '
                '${categoriseBmi(last.bmi, kBmiPrimaryStandard).label.en.toLowerCase()}. '
                'Your measurements are filled in below if you want to work '
                'out a new one.',
            seeLabel: 'See my result',
            onSee: () => _openEntry(last),
          ),
          const SizedBox(height: 22),
        ],
        // Kept for revert (2026-09-27): the "we've used your saved
        // measurements" note. Its condition is now false so it never shows.
        if (_store.hasSavedMeasurements && last == null) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              Icon(Icons.history_rounded, size: 16, color: ttcTitleInk),
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
        if (_heightFrom case final from?) ...[
          const SizedBox(height: 4),
          _FromLine(
              key: const ValueKey('ttc_bmi_height_from'), p: p, text: from),
        ],
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
        if (_weightFrom case final from?) ...[
          const SizedBox(height: 4),
          _FromLine(
              key: const ValueKey('ttc_bmi_weight_from'), p: p, text: from),
        ],
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
              // Kept for revert (2026-09-29, no tinted slab behind text): color: p.surfaceAlt,
              color: p.surface, border: Border.fromBorderSide(BorderSide(color: p.line)),
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
    ];
    // Kept for revert (2026-09-27): the ListView's closing `],\n );`.
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
            borderSide: BorderSide(color: ttcTitleInk, width: 1.5),
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
    // T2 (2026-09-28): her height, kept for next time whether or not she
    // saves this result.
    final worked = calculateBmi(input);
    if (worked != null) _store.rememberHeight(worked.metres);
    setState(() {
      _error = BmiInputError.none;
      _calc = worked;
      // A new number is not a saved one until she saves it.
      _shownEntry = null;
      _stage = _Stage.result;
    });
  }

  // ---------------------------------------------------------------------------

  List<Widget> _result(
      V2Palette p, AppLanguage lang, String Function(String, String) t) {
    final calc = _calc;
    // Kept for revert (2026-09-27): `return const SizedBox.shrink();`
    if (calc == null) return const <Widget>[];

    final ctx = _context;
    final r = interpretBmi(calc, ctx);
    // ⚠️ SOUTH ASIAN IS THE PRIMARY READING. See the head of the rules file.
    final primary = categoriseBmi(calc.bmi, kBmiPrimaryStandard);
    final secondary = categoriseBmi(calc.bmi, kBmiSecondaryStandard);

    // Kept for revert (2026-09-27):
    // return ListView(
    //   padding: const EdgeInsets.fromLTRB(20, 8, 20, kAskFabReserve + 24),
    //   children: [
    return <Widget>[
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
            lang == AppLanguage.hinglish
                ? 'South Asian thresholds ke hisaab se'
                // Glossed 2026-09-27. Kept for revert:
                // 'using the South Asian cut-offs'
                : 'using the ranges doctors use for South Asian women',
            style: pvManrope(fontSize: 13, color: p.ink3)),
        // ⚠️ WHAT THE NUMBER WAS WORKED OUT FROM (2026-09-27). A number
        // says what it counts; a saved one also says when.
        const SizedBox(height: 4),
        Text(
            key: const ValueKey('ttc_bmi_from'),
            '${_shownEntry == null ? '' : 'Saved ${ttcToolDate(_shownEntry!.at)}. '}'
            'From ${_heightText(calc.metres)} and ${_weightText(calc.kilograms)}.',
            style: pvManrope(fontSize: 13, color: p.ink3)),

        const SizedBox(height: 22),
        _Scale(p: p, bmi: calc.bmi),
        const SizedBox(height: 20),

        // ⚠️ SAVE SITS UNDER THE NUMBER (tools pass, 2026-09-27). It was the
        // last button on a ten-block page, so she could leave without saving,
        // and "Add this to my checklist" was a second, separate save. One tap
        // now keeps it in her history and on her checklist, and says so.
        _Button(
            key: const ValueKey('ttc_bmi_save'),
            p: p,
            filled: !identical(_savedCalc, calc),
            label: identical(_savedCalc, calc)
                ? 'Saved to your history and checklist'
                : 'Save this measurement',
            onTap: () async {
              if (identical(_savedCalc, calc)) return;
              setState(() => _savedCalc = calc);
              await _store.save(calc);
              // The entry just made is the one on screen now, so the change
              // note keeps comparing with the one before it (2026-09-27).
              if (mounted) setState(() => _shownEntry = _store.latest);
              await _store.setOnChecklist(true);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(t('Measurement saved.', 'Save ho gaya')),
              ));
            }),
        const SizedBox(height: 6),
        Text("Saving won't mark any medical item on your checklist as done.",
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3)),

        const SizedBox(height: 26),
        // Kept for revert (2026-09-28): 'What this means'
        // Kept for revert (2026-09-29, one heading style): the same Text with
        // style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)
        TtcSectionHeading(t('What your BMI means', 'Iska matlab kya hai')),
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
                // Kept for revert (2026-09-28): 'What does this mean
                // before pregnancy?'
                t('What does your BMI mean before pregnancy?',
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

        // ---- THE SECOND READING, folded (2026-09-27) ------------------------
        // It was an open box ABOVE "What this means", with three guideline
        // names in one sentence. It is now a fold named for the question she
        // would have. The words inside are unchanged.
        const SizedBox(height: 24),
        _Fold(
          key: const ValueKey('ttc_bmi_standards_fold'),
          p: p,
          title: 'Why might a lab say something different?',
          open: _showStandards,
          onTap: () => setState(() => _showStandards = !_showStandards),
          children: [
            Text(
                t(
                    'Using the international cut-offs, ${calc.display} is '
                        '"${secondary.label.en.toLowerCase()}".',
                    'International thresholds ke hisaab se, ${calc.display} '
                        '"${secondary.label.en.toLowerCase()}" hai.'),
                style: pvManrope(fontSize: 14, height: 1.6, color: p.ink1)),
            const SizedBox(height: 9),
            Text(kBmiStandardsExplainer.of(lang),
                style: pvManrope(fontSize: 13, height: 1.62, color: p.ink2)),
          ],
        ),

        // ---- LIMITATIONS, with the "not the whole story" line inside --------
        // The editorial paragraph used to stand on its own above a fold
        // titled "Why BMI isn't the whole story", saying the same thing
        // twice. It now opens the fold (2026-09-27).
        const SizedBox(height: 10),
        _Fold(
          p: p,
          title: t("Why BMI isn't the whole story",
              'BMI poori kahani kyun nahi hai'),
          open: _showLimitations,
          onTap: () => setState(() => _showLimitations = !_showLimitations),
          children: [
            Text(kBmiNotTheWholeStory.of(lang),
                style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink2)),
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
                                fontSize: 13.5, height: 1.55, color: p.ink2)),
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
                style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink2)),
          ],
        ),

        const SizedBox(height: 26),
        // Kept for revert (2026-09-29, one heading style): the same Text with
        // style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)
        TtcSectionHeading(t('What next?', 'Ab kya?')),
        const SizedBox(height: 12),
        // "Add this to my checklist" is folded into Save above (2026-09-27).
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
        // Named for what it does (2026-09-27): it opens the fields for a new
        // number, and a saved one stays saved. Kept for revert:
        // t('Edit measurements', 'Maap badlein').
        _Button(
            p: p,
            filled: false,
            label: t('Work out a new BMI', 'Maap badlein'),
            onTap: () => setState(() => _stage = _Stage.input)),

        // ---- HER SAVED MEASUREMENTS (2026-09-27) ----------------------------
        // Alma's "All entries" / MyFitnessPal's "Entries": dated rows, newest
        // first. Tap to see one, the cross removes it with Undo.
        if (_store.hasSavedMeasurements) ...[
          const SizedBox(height: 30),
          // Kept for revert (2026-09-29, one heading style): the same Text with
          // style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)
          const TtcSectionHeading('Your saved measurements'),
          const SizedBox(height: 4),
          Text('Tap one to see it. The cross removes it.',
              style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            child: Column(children: [
              for (final (i, e) in _store.history.reversed.indexed)
                _EntryRow(
                  key: ValueKey('ttc_bmi_entry_$i'),
                  p: p,
                  first: i == 0,
                  on: identical(e, _shownEntry),
                  date: ttcToolDate(e.at),
                  bmi: e.bmi.toStringAsFixed(1),
                  weight: _weightText(e.kilograms),
                  onTap: () => _openEntry(e),
                  onRemove: () => _remove(e),
                ),
            ]),
          ),
        ],

        // ⚠️ KEPT FOR REVERT (tools pass, 2026-09-27): the result as it was,
        // ten blocks in this order: subtitle, scale, the open "YOU MAY SEE
        // THIS DESCRIBED DIFFERENTLY" box, What this means, before pregnancy,
        // context and change notes, the stand-alone "not the whole story"
        // paragraph, the limitations fold, three next-step cards (the first
        // "Add this to my checklist", a second save), then Save and Edit.
        //         Text(
        //             t('using the South Asian cut-offs',
        //                 'South Asian thresholds ke hisaab se'),
        //             style: pvManrope(fontSize: 13, color: p.ink3)),
        //
        //         const SizedBox(height: 22),
        //         _Scale(p: p, bmi: calc.bmi),
        //         const SizedBox(height: 22),
        //
        //         // ---- THE SECOND READING ---------------------------------------------
        //         Container(
        //           padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
        //           decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(16),
        //             border: Border.all(color: p.line),
        //           ),
        //           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //             Text(
        //                 t('YOU MAY SEE THIS DESCRIBED DIFFERENTLY',
        //                     'AAPKO YE ALAG BATAYA JA SAKTA HAI'),
        //                 style: pvManrope(
        //                     fontSize: 10,
        //                     fontWeight: FontWeight.w800,
        //                     letterSpacing: 1.1,
        //                     color: p.ink3)),
        //             const SizedBox(height: 9),
        //             Text(
        //                 t(
        //                     'Using the international cut-offs, ${calc.display} is '
        //                         '"${secondary.label.en.toLowerCase()}".',
        //                     'International thresholds ke hisaab se, ${calc.display} '
        //                         '"${secondary.label.en.toLowerCase()}" hai.'),
        //                 style: pvManrope(
        //                     fontSize: 14, height: 1.6, color: p.ink1)),
        //             const SizedBox(height: 9),
        //             Text(kBmiStandardsExplainer.of(lang),
        //                 style: pvManrope(
        //                     fontSize: 13, height: 1.62, color: p.ink2)),
        //           ]),
        //         ),
        //
        //         const SizedBox(height: 26),
        //         Text(t('What this means', 'Iska matlab kya hai'),
        //             style: pvFraunces(
        //                 fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
        //         const SizedBox(height: 10),
        //         Text(r.body.of(lang),
        //             style: pvManrope(fontSize: 15, height: 1.7, color: p.ink2)),
        //
        //         const SizedBox(height: 22),
        //         Container(
        //           padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        //           decoration: BoxDecoration(
        //             color: p.surfaceAlt,
        //             borderRadius: BorderRadius.circular(16),
        //           ),
        //           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //             Text(
        //                 t('What does this mean before pregnancy?',
        //                     'Pregnancy se pehle iska kya matlab?'),
        //                 style: pvJakarta(
        //                     fontSize: 14.5,
        //                     fontWeight: FontWeight.w700,
        //                     color: p.ink1)),
        //             const SizedBox(height: 9),
        //             Text(r.preconception.of(lang),
        //                 style: pvManrope(fontSize: 14, height: 1.68, color: p.ink2)),
        //           ]),
        //         ),
        //
        //         if (r.contextNote != null) ...[
        //           const SizedBox(height: 14),
        //           Text(r.contextNote!.of(lang),
        //               style: pvManrope(fontSize: 14, height: 1.65, color: p.ink2)),
        //         ],
        //
        //         if (r.changeNote != null) ...[
        //           const SizedBox(height: 14),
        //           Container(
        //             padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(14),
        //               border: Border.all(color: p.line),
        //             ),
        //             child: Text(r.changeNote!.of(lang),
        //                 style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink2)),
        //           ),
        //         ],
        //
        //         // ---- THE EDITORIAL BEAT ---------------------------------------------
        //         const SizedBox(height: 28),
        //         Text(kBmiNotTheWholeStory.of(lang),
        //             style: pvFraunces(
        //                 fontSize: 17.5,
        //                 height: 1.6,
        //                 fontWeight: FontWeight.w500,
        //                 color: p.ink2)),
        //         const SizedBox(height: 24),
        //
        //         // ---- LIMITATIONS ----------------------------------------------------
        //         GestureDetector(
        //           onTap: () => setState(() => _showLimitations = !_showLimitations),
        //           behavior: HitTestBehavior.opaque,
        //           child: Container(
        //             padding: const EdgeInsets.fromLTRB(15, 14, 13, 15),
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(16),
        //               border: Border.all(color: p.line),
        //             ),
        //             child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Row(children: [
        //                     Expanded(
        //                       child: Text(
        //                           t("Why BMI isn't the whole story",
        //                               'BMI poori kahani kyun nahi hai'),
        //                           style: pvJakarta(
        //                               fontSize: 14.5,
        //                               fontWeight: FontWeight.w700,
        //                               color: p.ink1)),
        //                     ),
        //                     Icon(
        //                         _showLimitations
        //                             ? Icons.expand_less_rounded
        //                             : Icons.expand_more_rounded,
        //                         size: 20,
        //                         color: p.ink3),
        //                   ]),
        //                   if (_showLimitations) ...[
        //                     const SizedBox(height: 12),
        //                     Text(t('BMI does not measure:', 'BMI ye nahi naapta:'),
        //                         style: pvManrope(fontSize: 13, color: p.ink3)),
        //                     const SizedBox(height: 8),
        //                     for (final l in kBmiLimitations)
        //                       Padding(
        //                         padding: const EdgeInsets.only(bottom: 7),
        //                         child: Row(
        //                             crossAxisAlignment: CrossAxisAlignment.start,
        //                             children: [
        //                               Container(
        //                                 margin: const EdgeInsets.only(top: 7),
        //                                 width: 4,
        //                                 height: 4,
        //                                 decoration: BoxDecoration(
        //                                     color: p.ink3, shape: BoxShape.circle),
        //                               ),
        //                               const SizedBox(width: 10),
        //                               Expanded(
        //                                 child: Text(l.of(lang),
        //                                     style: pvManrope(
        //                                         fontSize: 13.5,
        //                                         height: 1.55,
        //                                         color: p.ink2)),
        //                               ),
        //                             ]),
        //                       ),
        //                     const SizedBox(height: 6),
        //                     Text(
        //                         t(
        //                             "That's why a doctor never uses BMI on its own to "
        //                                 'decide if someone is healthy or ready for '
        //                                 'pregnancy.',
        //                             'Isiliye doctor akele BMI se ye tay nahi karte ki '
        //                                 'koi sehatmand hai ya pregnancy ke liye taiyaar.'),
        //                         style: pvManrope(
        //                             fontSize: 13.5, height: 1.6, color: p.ink2)),
        //                   ],
        //                 ]),
        //           ),
        //         ),
        //
        //         const SizedBox(height: 26),
        //         Text(t('What next?', 'Ab kya?'),
        //             style: pvFraunces(
        //                 fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
        //         const SizedBox(height: 12),
        //         _Next(
        //             p: p,
        //             title: _store.onChecklist
        //                 ? t('Added to your checklist', 'Checklist mein jud gaya')
        //                 : t('Add this to my checklist', 'Isse meri checklist mein jodein'),
        //             body: t(
        //                 'Saved with your before-pregnancy checklist as a measurement. '
        //                     "It won't mark any medical item as done.",
        //                 'Aapke pre-pregnancy snapshot ke saath, ek maap ki tarah — kisi '
        //                     'poore ho chuke medical kaam ki tarah nahi.'),
        //             onTap: () => _store.setOnChecklist(true)),
        //         const SizedBox(height: 10),
        //         _Next(
        //             p: p,
        //             title: t('Eating well before pregnancy',
        //                 'Pregnancy se pehle ka khaana'),
        //             body: t('Built around what an Indian kitchen already cooks.',
        //                 'Jo Indian kitchen mein pehle se banta hai, usi par bana.'),
        //             onTap: () => _open('ttc_nutrition')),
        //         const SizedBox(height: 10),
        //         _Next(
        //             p: p,
        //             title: t('The three months before', 'Pehle ke teen mahine'),
        //             body: t('Why these months matter, and how much weight really does.',
        //                 'Ye window kyun, aur weight sach mein kitna maayne rakhta hai.'),
        //             onTap: () => _open('ttc_read/ttc_read_three_months_before')),
        //
        //         const SizedBox(height: 24),
        //         _Button(
        //             p: p,
        //             label: t('Save this measurement', 'Ye maap save karein'),
        //             onTap: () async {
        //               await _store.save(calc);
        //               if (!mounted) return;
        //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //                 behavior: SnackBarBehavior.floating,
        //                 content: Text(t('Measurement saved.', 'Save ho gaya')),
        //               ));
        //             }),
        //         const SizedBox(height: 10),
        //         _Button(
        //             p: p,
        //             filled: false,
        //             label: t('Edit measurements', 'Maap badlein'),
        //             onTap: () => setState(() => _stage = _Stage.input)),
        const SizedBox(height: 22),
        Text(kBmiDisclaimer.of(lang),
            style: pvManrope(fontSize: 12, height: 1.6, color: p.ink3)),
    ];
    // Kept for revert (2026-09-27): the ListView's closing `],\n );`.
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
    final here = categoriseBmi(bmi, kBmiPrimaryStandard).band;

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
                  color: ttcTitleInk,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.ground, width: 3),
                ),
              ),
            ),
          ]),
        ),
        // ⚠️ THE NUMBERS SIT WHERE THEY ARE ON THE TRACK, AND THE BANDS ARE
        // NAMED (tools pass, 2026-09-27). The five ticks were spread evenly,
        // so "23" and "25" sat far from their places and nothing said what a
        // segment meant. Kept for revert: a Row of five Expanded `_tick`s,
        // '15', '18.5', '23', '25', '35'.
        const SizedBox(height: 4),
        SizedBox(
          height: 16,
          child: Stack(clipBehavior: Clip.none, children: [
            for (final v in const [
              kBmiUnderCut,
              kBmiOverCutSouthAsian,
              kBmiObeseCutSouthAsian,
            ])
              Positioned(
                left: (frac(v) * w - 15).clamp(0.0, w - 30),
                width: 30,
                child: _tick(p, v == v.roundToDouble()
                    ? v.toStringAsFixed(0)
                    : v.toString()),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        for (final (band, range) in const [
          (BmiBand.under, 'Under 18.5'),
          (BmiBand.healthy, '18.5 to 22.9'),
          (BmiBand.over, '23 to 24.9'),
          (BmiBand.obese, '25 and over'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(children: [
              SizedBox(
                width: 86,
                child: Text(range,
                    style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: band == here
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: band == here ? p.ink1 : p.ink3)),
              ),
              Expanded(
                child: Text(
                    BmiCategory(band: band, standard: kBmiPrimaryStandard)
                        .label
                        .en,
                    style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: band == here
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: band == here ? p.ink1 : p.ink3)),
              ),
            ]),
          ),
      ]);
    });
  }

  Widget _tick(V2Palette p, String s) => Text(s,
      textAlign: TextAlign.center,
      style: pvManrope(fontSize: 10.5, color: p.ink3));
}

// -----------------------------------------------------------------------------

/// A labelled fold: a title row with a chevron, and its children when open.
/// The limitations box's shape, shared by the two folds (2026-09-27).
class _Fold extends StatelessWidget {
  const _Fold({
    super.key,
    required this.p,
    required this.title,
    required this.open,
    required this.onTap,
    required this.children,
  });

  final V2Palette p;
  final String title;
  final bool open;
  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        expanded: open,
        child: GestureDetector(
          onTap: onTap,
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
                      child: Text(title,
                          style: pvJakarta(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                    ),
                    Icon(
                        open
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20,
                        color: p.ink3),
                  ]),
                  if (open) ...[
                    const SizedBox(height: 12),
                    ...children,
                  ],
                ]),
          ),
        ),
      );
}

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

  // ⚠️ THE TOOL CHROME'S OWN PILLS (2026-09-27): white with a hairline at
  // rest, ink when chosen, the same on every tool. The chosen segment was a
  // bright purple fill (`p.action`), the retired accent-as-surface look.
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        TtcToolPill(
            label: left,
            on: leftOn,
            onTap: () => onTap(true),
            hue: kBmiHue),
        const SizedBox(width: 6),
        TtcToolPill(
            label: right,
            on: !leftOn,
            onTap: () => onTap(false),
            hue: kBmiHue),
      ]);

  // Kept for revert (2026-09-27): the purple segmented toggle.
  // @override
  // Widget build(BuildContext context) => Container(
  //       padding: const EdgeInsets.all(3),
  //       decoration: BoxDecoration(
  //         color: p.surfaceAlt,
  //         borderRadius: BorderRadius.circular(999),
  //       ),
  //       child: Row(mainAxisSize: MainAxisSize.min, children: [
  //         _seg(left, leftOn, () => onTap(true)),
  //         _seg(right, !leftOn, () => onTap(false)),
  //       ]),
  //     );

  // ignore: unused_element
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

/// One saved measurement: date, BMI, weight, and a cross to remove it.
class _EntryRow extends StatelessWidget {
  const _EntryRow({
    super.key,
    required this.p,
    required this.first,
    required this.on,
    required this.date,
    required this.bmi,
    required this.weight,
    required this.onTap,
    required this.onRemove,
  });

  final V2Palette p;
  final bool first;

  /// The one on screen above.
  final bool on;
  final String date;
  final String bmi;
  final String weight;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 6, 4, 6),
          decoration: BoxDecoration(
            border: first ? null : Border(top: BorderSide(color: p.line)),
          ),
          child: Row(children: [
            SizedBox(
              width: 88,
              child: Text(date,
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                      color: p.ink2)),
            ),
            Expanded(
              child: Text('BMI $bmi · $weight',
                  style: pvJakarta(
                      fontSize: 14.5,
                      fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                      color: p.ink1)),
            ),
            Semantics(
              button: true,
              label: 'Remove the measurement from $date',
              child: IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.close_rounded, size: 18, color: p.ink3),
              ),
            ),
          ]),
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
      {super.key,
      required this.p,
      required this.label,
      required this.onTap,
      this.filled = true});

  final V2Palette p;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  // ⚠️ THE TOOL CHROME'S OWN BUTTONS (2026-09-27): `TtcToolPrimary` and
  // `TtcToolSecondary`, white with a hairline, as on every other tool. The
  // filled button was bright purple (`p.action`), the one treatment the
  // stage retired. Save still says "Saved..." once tapped, which is what
  // told her it had worked; the fill was never the message.
  @override
  Widget build(BuildContext context) => filled
      ? TtcToolPrimary(label: label, onTap: onTap)
      : TtcToolSecondary(label: label, onTap: onTap);

  // Kept for revert (2026-09-27): the purple filled button.
  // ignore: unused_element
  Widget _oldBuild(BuildContext context) => GestureDetector(
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


/// "From your Weight log, change it": where a prefilled number came from
/// (launch sanity T2, 2026-09-28).
class _FromLine extends StatelessWidget {
  const _FromLine({super.key, required this.p, required this.text});
  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.history_rounded, size: 13, color: p.ink3),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
          ),
        ],
      );
}

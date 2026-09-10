// =============================================================================
//  "Read your semen report" — the screen
// -----------------------------------------------------------------------------
//  **Where to look:** TTC → His side → *Test and results* → "Read your semen
//  report". Surface id `ttc_semen_report`.
//
//  The logic is in `ttc_semen_reading.dart` and the numbers are in
//  `ttc_semen_limits.dart`. This file is inputs and paint, and it deliberately
//  decides nothing — every sentence it shows comes back from
//  `ttcReadSemenReport`, so the safety rules cannot be softened by editing a
//  widget.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT IS SHAPED LIKE "WHERE DO I STAND", NOT LIKE A CALCULATOR
//  ---------------------------------------------------------------------------
//
//  The brief calls it "the His side answer to the PCOS 'Where do I stand'
//  tool", so it reuses that tool's chrome: `TtcToolScaffold`, numbered
//  questions, option blocks, and a single primary at the foot. A man typing
//  four numbers into a form and getting a coloured result back is a calculator,
//  and a calculator implies a calculation with a right answer.
//
//  ⚠️ AND NOTHING ON THIS SCREEN GOES RED. Not the below-the-line lines, not
//  the red-flag route. The strongest colour it uses is the door's own teal.
//  A man reading his own report at midnight does not need the app to raise its
//  voice — and a red number would say "verdict" more loudly than any sentence
//  could say "not a verdict".
//
//  ---------------------------------------------------------------------------
//  ⚠️ BROUGHT BACK TO THE BRIEF ON 2026-09-06 — four things this screen said
//  and did not do
//  ---------------------------------------------------------------------------
//
//  · **Volume** was in the logic and not on the form — a field with a writer
//    and no reader, which is the "correct but unreachable" failure this repo
//    keeps hitting. It is asked now, optional, and reported without a line.
//  · **Abstinence** was five buckets; the brief says "in days". A number now.
//  · **"Keep his reports with yours"** opened the folder and saved nothing.
//    It writes a `TtcRecord` on his side of the folder, then opens it.
//  · **"Have the report read properly"** opened the consults shelf; the brief
//    says "opens the andrologist consult". It opens that offering.
//  · And the usual-range path now carries the brief's pointer to the
//    couple-level readiness read in the IVF and IUI area.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../v2/v2_palette.dart';
import '../../services/bracket_resolver.dart' show bracketById;
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_focus_data.dart' show ttcFocusPageFor;
import '../../ttc/ttc_prepare_data.dart'
    show kTtcOfferingAndrologist, ttcOfferingById;
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_semen_limits.dart';
import '../../ttc/ttc_semen_reading.dart';
import 'ttc_common.dart';
import 'ttc_focus_screen.dart' show TtcFocusScreen;
import 'ttc_prepare_screen.dart';
import 'ttc_surface_router.dart';
import 'ttc_tool_chrome.dart';

/// His side's accent — the bracket's own 186.
const double kHisSideHue = 186;

/// The IVF and IUI door's hue, for the one card on this screen that opens it.
const double _kIvfHue = 268;

/// The bracket the gateway opens. Its first tab is "Is it time to get help?",
/// which is where the couple-level readiness read lives.
const String _kIvfBracket = 'ttc_infertility';

void openTtcSemenReport(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc_semen_report'),
      builder: (_) => const TtcSemenReportScreen(),
    ));

class TtcSemenReportScreen extends StatefulWidget {
  const TtcSemenReportScreen({super.key});

  @override
  State<TtcSemenReportScreen> createState() => _TtcSemenReportScreenState();
}

class _TtcSemenReportScreenState extends State<TtcSemenReportScreen> {
  TtcSemenEntry _e = const TtcSemenEntry();
  bool _read = false;

  /// Question 1 as he answered it: null until he taps, then yes or no.
  ///
  /// ⚠️ ITS OWN FIELD, BECAUSE THE ENTRY CANNOT HOLD "NOT ANSWERED". The
  /// entry's `noSpermFound` is a plain bool, false by default, so the first
  /// build drew "No" as chosen only once a number had been typed and otherwise
  /// drew nothing — and tapping "No" set false to false, which looked like the
  /// tap had failed: *"I cannot click on the option No."* A question with a
  /// default answer is not a question. Three states, and the third is "he has
  /// not said".
  bool? _noSperm;

  /// "Not on my report" for volume — also three states, same reason.
  bool _volumeUnknown = false;

  /// The record this reading was saved as, so a second tap opens the folder
  /// rather than writing a duplicate.
  String? _keptId;

  void _set(TtcSemenEntry next) => setState(() {
        _e = next;
        // ⚠️ EDITING A NUMBER CLOSES THE READING. Leaving an old reading on
        // screen under a changed input is how somebody acts on a sentence that
        // no longer describes what they typed.
        _read = false;
        // And a changed entry is a different report, so a save of the old
        // one no longer stands for it.
        _keptId = null;
      });

  void _put(String id, double? v) {
    final next = Map<String, double>.from(_e.values);
    if (v == null) {
      next.remove(id);
    } else {
      next[id] = v;
    }
    _set(_e.copyWith(values: next));
  }

  /// "Keep his reports with yours" — writes the result, then opens the folder.
  ///
  /// ⚠️ ONE RECORD PER READING. `_keptId` is cleared whenever an input changes,
  /// so a corrected number saves again and an unchanged one does not.
  Future<void> _keep() async {
    final store = TtcRecordsStore.instance;
    // See `ensureLoaded` — a write that lands before the cache is read gets
    // cleared by the read.
    await store.ensureLoaded();
    if (!mounted) return;
    if (_keptId == null) {
      final r = store.add(
        label: 'Semen analysis',
        takenOn: DateTime.now(),
        testId: 'semen',
        value: ttcSemenRecordValue(_e),
        note: ttcSemenRecordNote(_e),
        forPartner: true,
      );
      // ⚠️ setState, NOT A BARE ASSIGNMENT. The button's label reads
      // `_keptId` — "Kept with your reports — open the folder" — and an
      // assignment without a rebuild left it saying "Keep" over a report
      // that was already kept. The test caught it; the user would have
      // tapped twice and trusted the app less.
      setState(() => _keptId = r.id);
    }
    openTtcSurface(context, 'ttc_records');
  }

  @override
  Widget build(BuildContext context) {
    if (_read) {
      return _Result(
        reading: ttcReadSemenReport(_e),
        kept: _keptId != null,
        onKeep: _keep,
        onEdit: () => setState(() => _read = false),
      );
    }

    // Question numbers shift when the four numbers are hidden.
    final base = _e.noSpermFound ? 1 : 1 + kTtcSemenLimits.length;

    return TtcToolScaffold(
      hue: kHisSideHue,
      eyebrow: 'His side',
      title: 'Read your\nsemen report.',
      intro: 'Type in what the report says and it will be explained in plain '
          'English. It will not tell you whether you are fertile — nothing '
          'can from one sheet of paper — and every answer ends with somebody '
          'to take it to.',
      children: [
        ttcToolPad(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),

            // ⚠️ THE AZOOSPERMIA QUESTION IS FIRST, NOT BURIED AT THE END.
            // A man whose report found no sperm should not have to type four
            // numbers he does not have before the tool says anything useful to
            // him — and every one of those fields would be blank, which reads
            // as failure on top of the worst sentence in andrology.
            TtcToolQuestion(
              n: 1,
              hue: kHisSideHue,
              title: 'Does the report say no sperm were found?',
              note: 'Sometimes written as azoospermia.',
              child: TtcToolChoice<bool>(
                value: _noSperm,
                hue: kHisSideHue,
                options: const {false: 'No', true: 'Yes'},
                onTap: (v) {
                  _noSperm = v;
                  _set(_e.copyWith(noSpermFound: v ?? false));
                },
              ),
            ),

            if (!_e.noSpermFound) ...[
              for (var i = 0; i < kTtcSemenLimits.length; i++)
                _NumberQuestion(
                  n: i + 2,
                  title: kTtcSemenLimits[i].name,
                  note: kTtcSemenLimits[i].plain,
                  unit: kTtcSemenLimits[i].unit,
                  value: _e.values[kTtcSemenLimits[i].id],
                  onChanged: (v) => _put(kTtcSemenLimits[i].id, v),
                ),
            ],

            // ⚠️ VOLUME IS ASKED AND NEVER COMPARED. It is on the report, it is
            // worth keeping with the result, and it is not one of the four
            // numbers with a reference line — see `kTtcSemenLimits`.
            //
            // ⚠️ AND IT SAYS WHERE THE NUMBER COMES FROM. The first note read
            // "how much semen there was", which invited the reasonable
            // objection: *"who can measure the volume at home?"* Nobody — the
            // lab does, and prints it. The note says so, and "Not on my
            // report" is a real answer rather than a blank he has to decide
            // about.
            _NumberQuestion(
              n: base + 1,
              title: 'Volume',
              note: 'Printed on the report — the lab measures it, you do not. '
                  'Optional, and it is reported here, not scored.',
              unit: 'ml',
              value: _volumeUnknown ? null : _e.volumeMl,
              enabled: !_volumeUnknown,
              unknownLabel: 'Not on my report',
              unknown: _volumeUnknown,
              onUnknown: (u) {
                _volumeUnknown = u;
                _set(_e.copyWith(clearVolume: true));
              },
              onChanged: (v) => _set(v == null
                  ? _e.copyWith(clearVolume: true)
                  : _e.copyWith(volumeMl: v)),
            ),

            TtcToolQuestion(
              n: base + 2,
              hue: kHisSideHue,
              title: 'Was this the first test, or a repeat?',
              child: TtcToolChoice<bool>(
                value: _e.isRepeat,
                hue: kHisSideHue,
                options: const {false: 'First test', true: 'A repeat'},
                onTap: (v) => _set(_e.copyWith(isRepeat: v ?? false)),
              ),
            ),

            // ⚠️ A NUMBER OF DAYS, NOT A BUCKET. Five ranges used to stand in
            // for this, and "under 2" was stored as 1 — so the note on the
            // result could say "produced after 1 day" about a sample produced
            // after twelve hours. He knows the number; he types it.
            _NumberQuestion(
              n: base + 3,
              title: 'Days since the last ejaculation',
              note: 'The standard window is $kTtcAbstinenceMinDays to '
                  '$kTtcAbstinenceMaxDays days. Leave it blank if you are not '
                  'sure.',
              unit: 'days',
              whole: true,
              value: _e.abstinenceDays?.toDouble(),
              onChanged: (v) => _set(v == null
                  ? _e.copyWith(clearAbstinence: true)
                  : _e.copyWith(abstinenceDays: v.round())),
            ),

            TtcToolQuestion(
              n: base + 4,
              hue: kHisSideHue,
              title: 'Any of these?',
              note: 'Tap anything that applies. Nothing here is common, and '
                  'each one is a reason to see somebody before arranging '
                  'another sample.',
              // ⚠️ TICKS, BECAUSE MORE THAN ONE CAN BE TRUE. `TtcToolOptions`
              // draws a checkbox only when a question can hold several
              // answers, which this one can — and drawing four single-choice
              // blocks would imply he must pick the worst of them.
              child: TtcToolOptions(
                hue: kHisSideHue,
                p: V2PaletteStore.instance.current,
                items: [
                  for (final f in kTtcSemenRedFlags)
                    TtcToolOption(
                      label: f.label,
                      tick: true,
                      on: _e.redFlags.contains(f.id),
                      onTap: () {
                        final next = Set<String>.from(_e.redFlags);
                        next.contains(f.id)
                            ? next.remove(f.id)
                            : next.add(f.id);
                        _set(_e.copyWith(redFlags: next));
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            TtcToolPrimary(
              label: 'Read it back to me',
              onTap: () => setState(() => _read = true),
            ),
            const SizedBox(height: 14),
            const TtcToolPrivacyLine(),
            const SizedBox(height: 26),
          ],
        )),
      ],
    );
  }

}

/// A number, typed. Not a stepper — a report has a printed value and he is
/// copying it across, not choosing one.
///
/// ⚠️ THE FIELD WEARS THE SAME CLOTHES AS THE OPTION BLOCKS — white, a
/// hairline, ink when it holds a value. It used to be a grey panel beside
/// grey option blocks, and the page had two greys and no white; with the
/// blocks now white-and-hairline, a grey field would be the odd one out.
class _NumberQuestion extends StatefulWidget {
  const _NumberQuestion({
    required this.n,
    required this.title,
    required this.note,
    required this.unit,
    required this.value,
    required this.onChanged,
    this.whole = false,
    this.enabled = true,
    this.unknownLabel,
    this.unknown = false,
    this.onUnknown,
  });

  final int n;
  final String title;
  final String note;
  final String unit;
  final double? value;
  final ValueChanged<double?> onChanged;

  /// Digits only — for a count of days.
  final bool whole;

  final bool enabled;

  /// When set, a toggle beside the field — "Not on my report" — that clears
  /// and disables it. An honest third answer for a number he may not have.
  final String? unknownLabel;
  final bool unknown;
  final ValueChanged<bool>? onUnknown;

  @override
  State<_NumberQuestion> createState() => _NumberQuestionState();
}

class _NumberQuestionState extends State<_NumberQuestion> {
  late final _c = TextEditingController(
      text: widget.value == null
          ? ''
          : widget.whole
              ? '${widget.value!.round()}'
              : '${widget.value}');

  @override
  void didUpdateWidget(covariant _NumberQuestion old) {
    super.didUpdateWidget(old);
    // "Not on my report" clears the field; the controller has to follow or
    // the cleared value stays on screen.
    if (widget.value == null && old.value != null) _c.clear();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final has = _c.text.trim().isNotEmpty && widget.enabled;
    return TtcToolQuestion(
      n: widget.n,
      hue: kHisSideHue,
      title: widget.title,
      note: widget.note,
      child: Row(children: [
        SizedBox(
          width: 108,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: widget.enabled ? 1 : 0.45,
            child: TextField(
              controller: _c,
              enabled: widget.enabled,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: !widget.whole),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(widget.whole ? r'[0-9]' : r'[0-9.]')),
              ],
              onChanged: (s) {
                setState(() {});
                widget.onChanged(
                    s.trim().isEmpty ? null : double.tryParse(s));
              },
              style: ttcBody(15, color: ttcTitleInk, w: FontWeight.w800),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                hintText: '—',
                hintStyle: ttcBody(15, color: ttcMuted),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: has ? ttcTitleInk : ttcLine, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: ttcTitleInk, width: 1.5),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: ttcLine, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(widget.unit, style: ttcBody(13, color: ttcSoft, h: 1.4)),
        ),
        if (widget.unknownLabel case final label?)
          TtcToolPill(
            label: label,
            on: widget.unknown,
            hue: kHisSideHue,
            onTap: () => widget.onUnknown?.call(!widget.unknown),
          ),
      ]),
    );
  }
}

// =============================================================================
//  The reading
// =============================================================================

class _Result extends StatelessWidget {
  const _Result({
    required this.reading,
    required this.kept,
    required this.onKeep,
    required this.onEdit,
  });

  final TtcSemenReading reading;
  final bool kept;
  final VoidCallback onKeep;
  final VoidCallback onEdit;

  /// "Have the report read properly" — the andrologist, by offering.
  ///
  /// Falls back to the consults shelf only if the offering is ever removed
  /// from the catalogue, so the button never opens nothing.
  void _openAndrologist(BuildContext context) {
    final offering = ttcOfferingById(kTtcOfferingAndrologist);
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(
          name: offering == null
              ? 'ttc/consults'
              : 'ttc/offering/$kTtcOfferingAndrologist'),
      builder: (_) => offering == null
          ? const TtcPrepareScreen(onlyCategory: 'consults')
          : TtcOfferingScreen(offering: offering),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return TtcToolScaffold(
      hue: kHisSideHue,
      variant: 3,
      eyebrow: 'Your report',
      title: reading.headline,
      intro: reading.body,
      children: [
        ttcToolPad(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),

            if (reading.extra != null) ...[
              TtcCard(
                color: ttcPanel,
                child: Text(reading.extra!,
                    style: ttcBody(13.5, color: ttcTitleInk, h: 1.6)),
              ),
              const SizedBox(height: 18),
            ],

            if (reading.abstinenceNote != null) ...[
              TtcCard(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: ttcMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(reading.abstinenceNote!,
                            style: ttcBody(13, h: 1.55)),
                      ),
                    ]),
              ),
              const SizedBox(height: 18),
            ],

            // ---- the numbers, one line each --------------------------------
            if (reading.entered.isNotEmpty ||
                reading.volumeSentence != null) ...[
              ttcSectionTitle('What the report says'),
              if (reading.entered.isNotEmpty)
                for (final l in reading.lines) ...[
                  _LineCard(line: l),
                  const SizedBox(height: 10),
                ],
              if (reading.volumeSentence case final v?) ...[
                TtcCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Volume', style: ttcJakarta(14.5)),
                        const SizedBox(height: 8),
                        Text(v, style: ttcBody(13.5, h: 1.55)),
                      ]),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),
              // ⚠️ THE FRAMING TRAVELS WITH THE NUMBERS, ALWAYS. Without it,
              // four lines against four thresholds is a scorecard.
              Text(kTtcSemenNotAPassMark,
                  style: ttcBody(12.5, color: ttcSoft, h: 1.55)),
              const SizedBox(height: 6),
              Text(kTtcSemenLimitsSource,
                  style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
              const SizedBox(height: 24),
            ],

            // ---- the brief's pointer, on the usual-range path only ---------
            if (reading.coupleReadiness) ...[
              const _IvfGateway(),
              const SizedBox(height: 24),
            ],

            // ---- the two actions every path ends with ----------------------
            ttcSectionTitle('What to do with this'),
            TtcToolPrimary(
              label: 'Have the report read properly',
              onTap: () => _openAndrologist(context),
            ),
            const SizedBox(height: 10),
            TtcToolSecondary(
              label: kept
                  ? 'Kept with your reports — open the folder'
                  : 'Keep his reports with yours',
              onTap: onKeep,
            ),
            const SizedBox(height: 10),
            TtcToolSecondary(label: 'Change something', onTap: onEdit),

            const SizedBox(height: 22),
            // ⚠️ THE LAST WORD ON EVERY PATH. Not a legal line — the actual
            // limit of what this screen did, said plainly.
            Text(
                'This explains numbers against a published reference. It is '
                'not a diagnosis and it cannot tell you whether you will '
                'conceive. An andrologist reads these values together, and in '
                'the context of everything else about you.',
                style: ttcBody(12, color: ttcMuted, h: 1.6)),
            const SizedBox(height: 30),
          ],
        )),
      ],
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({required this.line});
  final TtcSemenLine line;

  @override
  Widget build(BuildContext context) {
    if (!line.entered) {
      return TtcCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(line.limit.name,
              style: ttcBody(13.5, color: ttcMuted, w: FontWeight.w700)),
          const SizedBox(height: 5),
          Text('Not entered. Nothing has been guessed for it.',
              style: ttcBody(12.5, color: ttcMuted, h: 1.45)),
        ]),
      );
    }

    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(line.limit.name, style: ttcJakarta(14.5))),
          // ⚠️ A WORD, NOT A COLOUR. "Below the line" in plain ink says the
          // same thing as a red chip and does not shout it.
          Text(line.below ? 'Below the line' : 'In the usual range',
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: line.below ? ttcTitleInk : ttcSoft)),
        ]),
        const SizedBox(height: 8),
        Text(line.sentence, style: ttcBody(13.5, h: 1.55)),
        if (line.limit.note != null) ...[
          const SizedBox(height: 8),
          Text(line.limit.note!, style: ttcBody(12.5, color: ttcSoft, h: 1.5)),
        ],
        if (line.below) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: ttcPanel, borderRadius: BorderRadius.circular(14)),
            child: Text(kTtcSemenBelowLineNote,
                style: ttcBody(12.5, color: ttcTitleInk, h: 1.5)),
          ),
        ],
      ]),
    );
  }
}

// =============================================================================
//  The gateway to the IVF and IUI door
// -----------------------------------------------------------------------------
//  The brief, on the usual-range path: *"If trying has taken a while, point
//  to the couple-level readiness in the IVF and IUI area."*
//
//  ⚠️ ONE CARD, IN THAT DOOR'S OWN COLOUR, AND NOTHING ELSE CHANGES. A normal
//  result is the one place this tool says "your side is not the explanation",
//  and the honest next thought is about the two of them. So the card is
//  quiet — a hairline in the IVF hue, its eyebrow, one title, one line, a
//  chevron — and it opens that door rather than summarising it here. The
//  readiness read is the first thing on the door's first tab.
//
//  It opens the DOOR, not the readiness tool directly, on purpose: the tool
//  asks six questions including two about him, and a man arriving from his
//  own normal result should see the room it lives in before he is asked
//  them.
// =============================================================================

class _IvfGateway extends StatelessWidget {
  const _IvfGateway();

  void _open(BuildContext context) {
    // Same wiring gate as `openTtcFocusTile`: an unknown bracket opens nothing.
    final page = ttcFocusPageFor(_kIvfBracket);
    final bracket = bracketById(_kIvfBracket);
    if (page == null || bracket == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc/focus/$_kIvfBracket'),
      builder: (_) => TtcFocusScreen(page: page, bracket: bracket),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ink = HSLColor.fromAHSL(1, _kIvfHue, 0.34, 0.36).toColor();
    final line = HSLColor.fromAHSL(1, _kIvfHue, 0.40, 0.72).toColor();
    final tint = HSLColor.fromAHSL(1, _kIvfHue, 0.45, 0.965).toColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: line.withValues(alpha: 0.55)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IVF AND IUI',
                        style: pvManrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: ink)),
                    const SizedBox(height: 6),
                    Text('When trying has taken a while',
                        style: ttcJakarta(15.5)),
                    const SizedBox(height: 4),
                    Text(
                        'A normal result on his side moves the question to '
                        'the two of you. The readiness read there is six '
                        'questions — never a score.',
                        style: ttcBody(12.5, color: ttcSoft, h: 1.5)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, size: 20, color: ink),
            ],
          ),
        ),
      ),
    );
  }
}

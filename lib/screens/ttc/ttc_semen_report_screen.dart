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
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE TOOL REBUILD, 2026-09-27 — what a saved report could not do
//  ---------------------------------------------------------------------------
//
//  The user: "The last report added… 6 September, no sperm found. Now I cannot
//  delete it." Two causes, one on each side of the save:
//
//  · **The date was never asked.** `_keep` filed every report under the day
//    it was typed in (`DateTime.now()`), so a report from March saved in
//    September read as September's, and sorted as the "latest" semen analysis
//    over any real later one. The form now asks "Date on the report" (today
//    unless changed, past dates only), and the save uses it.
//  · **Once kept, it could not be reached to change or remove.** That half
//    lives in Records: every result's page now has Edit and Remove
//    (`ttc_records_v2.dart`, `ttc_record_edit_screen.dart`). Here, a kept
//    report that has since been removed from Records no longer claims to be
//    kept, so "Keep" works again instead of opening a folder without it.
//  · The result's cards were V1 shadowed cards (`TtcCard`); they are the
//    tool's white-and-hairline blocks now, the same as Records.
//
//  Mobbin, 2026-09-27: Noom's result sheet (the value, one plain paragraph,
//  one clear button, https://mobbin.com/screens/1f2f8877-44b0-49b8-a833-9615bb596c9a)
//  and Zocdoc's "What you can do after your visit" rows
//  (https://mobbin.com/screens/51f39cd3-2442-40e5-97ca-0fb69840d0ab) back the
//  order already chosen: next steps under the headline, numbers after.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../v2/v2_palette.dart';
// import '../../services/bracket_resolver.dart' show bracketById; // kept for revert: the old IVF gateway push (2026-09-26)
import '../../theme/pv_fonts.dart';
// import '../../ttc/ttc_focus_data.dart' show ttcFocusPageFor; // kept for revert: the old IVF gateway push (2026-09-26)
import '../../ttc/ttc_prepare_data.dart'
    show kTtcOfferingAndrologist, ttcOfferingById;
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_semen_limits.dart';
import '../../ttc/ttc_semen_reading.dart';
import 'ttc_common.dart';
import 'ttc_record_edit_screen.dart' show TtcRecordDateField;
import 'ttc_records_v2.dart' show TtcRecordPanel;
// import 'ttc_focus_screen.dart' show TtcFocusScreen; // kept for revert: the old IVF gateway push (2026-09-26)
import 'doors/ttc_door_screen.dart' show openTtcDoor;
import '../products/pv_store_chrome.dart' show pvSnack;
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

  /// The date printed on the report, which is the date the record is filed
  /// under. Today until he changes it. See the header: this used to be
  /// `DateTime.now()` at the moment of saving, never asked.
  DateTime _takenOn = DateTime.now();

  /// Kept, and still in Records. A report he has since removed from Records
  /// is not "kept" any more, so the button offers to keep it again.
  bool get _isKept =>
      _keptId != null &&
      TtcRecordsStore.instance.records.any((r) => r.id == _keptId);

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
    if (!_isKept) {
      final r = store.add(
        label: 'Semen analysis',
        // The report's own date (2026-09-27). Kept for revert:
        // takenOn: DateTime.now(),
        takenOn: _takenOn,
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
      // Said at the moment it happens (tools pass, 2026-09-27): the folder
      // used to just open on top, so nothing said the tap had worked.
      pvSnack(context, 'Saved to your reports.',
          icon: Icons.check_rounded, lift: 24);
    }
    openTtcSurface(context, 'ttc_records');
  }

  @override
  Widget build(BuildContext context) {
    if (_read) {
      Widget result(BuildContext context) => _Result(
            reading: ttcReadSemenReport(_e),
            kept: _isKept,
            onKeep: _keep,
            onEdit: () => setState(() => _read = false),
          );
      // Listens to Records once something is kept, so removing the saved
      // report there turns "Kept" back into "Keep" here when he comes back
      // (2026-09-27).
      //
      // ⚠️ ONLY ONCE KEPT, AND THE REASON IS WHERE A SINGLETON IS BORN.
      // Touching `TtcRecordsStore.instance` builds the store, and its
      // constructor starts an async load in whatever zone it is built in.
      // Listening from the first frame built it during the reading, before
      // any save, and under a test's fake clock that load never finished,
      // so a later "Keep" waited for ever. A store should be first touched
      // by the code that needs it; here that is `_keep`.
      if (_keptId == null) return result(context);
      return ListenableBuilder(
        listenable: TtcRecordsStore.instance,
        builder: (context, _) => result(context),
      );
    }

    // Question numbers shift when the four numbers are hidden.
    final base = _e.noSpermFound ? 1 : 1 + kTtcSemenLimits.length;

    return TtcToolScaffold(
      hue: kHisSideHue,
      eyebrow: 'His side',
      title: 'Read your\nsemen report.',
      // Shorter, and says what to do first (2026-09-27). Kept for revert:
      // "Type in what the report says and we'll explain it in plain English.
      // It won't tell you whether you're fertile, because nothing can from
      // one sheet of paper. Every answer ends with someone you can take it to."
      intro: 'Copy the numbers from the lab report and we\'ll explain each '
          "one in plain words. One report can't tell you whether you're "
          'fertile, so every answer ends with someone you can take it to.',
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
              // Says what to do if unsure (2026-09-27). Kept for revert:
              // 'Sometimes written as azoospermia.'
              note: "Sometimes written as azoospermia. If you're not sure, "
                  'choose No and type in the numbers.',
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

            // ⚠️ TWO SHORT PARTS, ONE SCROLL (tools pass, 2026-09-27): the
            // four numbers that matter, then a few details, each under its
            // own heading, so he can see what counts and how long it is.
            //
            // ⚠️ EACH NUMBER SAYS WHAT HIS LAB MAY CALL IT, AND CHECKS ITS
            // UNIT. Labs print these in different words and units, and a
            // total count typed as a per-ml number is the likeliest way to a
            // wrong line. Presentation only: the WHO reference values in
            // `ttc_semen_limits.dart` are untouched. Kept for revert: each
            // question's note was `kTtcSemenLimits[i].plain` alone.
            if (!_e.noSpermFound) ...[
              const SizedBox(height: 6),
              ttcSectionTitle('The four main numbers'),
              for (var i = 0; i < kTtcSemenLimits.length; i++)
                _NumberQuestion(
                  key: ValueKey('ttc_semen_q_${kTtcSemenLimits[i].id}'),
                  n: i + 2,
                  title: kTtcSemenLimits[i].name,
                  note: kTtcSemenLimits[i].plain,
                  labNames: kTtcSemenLabNames[kTtcSemenLimits[i].id],
                  check: ttcSemenUnitCheck(kTtcSemenLimits[i].id, _e.values),
                  unit: kTtcSemenLimits[i].unit,
                  value: _e.values[kTtcSemenLimits[i].id],
                  onChanged: (v) => _put(kTtcSemenLimits[i].id, v),
                ),
            ],
            const SizedBox(height: 6),
            ttcSectionTitle('A few details'),

            // ⚠️ ASKED, BECAUSE IT IS THE DATE THE REPORT IS FILED UNDER
            // (2026-09-27). It was never asked, and a saved report took the
            // day it was typed in. Past dates only.
            TtcToolQuestion(
              n: base + 1,
              hue: kHisSideHue,
              title: 'Date on the report',
              note: 'The day the lab tested the sample. It is the date your '
                  'reports will show.',
              child: TtcRecordDateField(
                fieldKey: const ValueKey('ttc_semen_date'),
                taken: _takenOn,
                onPick: (d) => setState(() {
                  _takenOn = d;
                  // A different date is a different save.
                  _keptId = null;
                }),
              ),
            ),

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
              n: base + 2,
              title: 'Volume',
              note: "It's printed on the report, because the lab measures it, "
                  "not you. This one is optional. It's shown here, not "
                  'scored.',
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
              n: base + 3,
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
              n: base + 4,
              title: 'Days since the last ejaculation',
              note: 'The standard window is $kTtcAbstinenceMinDays to '
                  '$kTtcAbstinenceMaxDays days. Leave it blank if you\'re not '
                  'sure.',
              unit: 'days',
              whole: true,
              value: _e.abstinenceDays?.toDouble(),
              onChanged: (v) => _set(v == null
                  ? _e.copyWith(clearAbstinence: true)
                  : _e.copyWith(abstinenceDays: v.round())),
            ),

            TtcToolQuestion(
              n: base + 5,
              hue: kHisSideHue,
              title: 'Any of these?',
              note: 'Tap anything that applies. None of these is common, and '
                  'each one is a reason to see someone before arranging '
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
    super.key,
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
    this.labNames,
    this.check,
  });

  final int n;
  final String title;
  final String note;

  /// "On your report it may say ...": the other names labs print it under.
  final String? labNames;

  /// A gentle "check this" line when the number looks like the wrong unit.
  final String? check;
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
      note: widget.labNames == null
          ? widget.note
          : '${widget.note} ${widget.labNames}',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
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
                  // No dash placeholder (2026-09-27): it read like a value
                  // already filled in. Kept for revert: hintText: '—'.
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
          // Flexible (2026-09-27): at phone width the pill beside a wide
          // field overflowed the row.
          if (widget.unknownLabel case final label?)
            Flexible(
              child: TtcToolPill(
                label: label,
                on: widget.unknown,
                hue: kHisSideHue,
                onTap: () => widget.onUnknown?.call(!widget.unknown),
              ),
            ),
        ]),
        if (widget.check case final c?) ...[
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: ttcSoft),
            const SizedBox(width: 8),
            Expanded(
              child: Text(c,
                  key: const ValueKey('ttc_semen_unit_check'),
                  style: ttcBody(12.5, color: ttcTitleInk, h: 1.5)),
            ),
          ]),
        ],
      ]),
    );
  }
}

/// What labs may call each of the four numbers, so he can match his report's
/// words to ours (tools pass, 2026-09-27). Names only; no value changes.
const Map<String, String> kTtcSemenLabNames = {
  'concentration': 'Your report may call it sperm count or sperm '
      'concentration, per ml.',
  'total_motility': 'Your report may call it motility or total motility '
      "(PR + NP). If it lists grades, it's a + b + c added together.",
  'progressive_motility': 'Your report may call it progressive motility, '
      "PR, or rapid and slow progressive. If it lists grades, it's a + b.",
  'morphology': 'Your report may call it normal forms, normal morphology or '
      'Kruger (strict).',
};

/// A gentle "check this" when a typed number looks like the wrong unit.
/// Never blocks and never changes a value: it only asks him to look again.
String? ttcSemenUnitCheck(String id, Map<String, double> values) {
  final v = values[id];
  if (v == null) return null;
  final percent = id != 'concentration';
  if (percent && v > 100) {
    return "A share can't be more than 100 per cent. Check this number "
        'on your report.';
  }
  if (id == 'concentration' && v > 150) {
    return 'Just checking: is this the per ml number? Some reports also '
        'print a total for the whole sample, which is much bigger.';
  }
  if (id == 'progressive_motility') {
    final total = values['total_motility'];
    if (total != null && v > total) {
      return "Progressive motility is part of total motility, so it's "
          "usually the smaller number. Check the two aren't swapped.";
    }
  }
  return null;
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
              // Kept for revert (2026-09-27): a shadowed V1 TtcCard in grey.
              TtcRecordPanel(
                child: Text(reading.extra!,
                    style: ttcBody(13.5, color: ttcTitleInk, h: 1.6)),
              ),
              const SizedBox(height: 18),
            ],

            if (reading.abstinenceNote != null) ...[
              TtcRecordPanel(
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

            // ---- what to do, FIRST (tools pass, 2026-09-27) -----------------
            // It sat under every number card, at the very bottom. The next
            // step is what he most needs, so it comes straight after the
            // headline. The free step leads; the paid consult leads only when
            // the reading itself says to see someone first (no sperm found,
            // or a warning sign). Kept for revert: this section came after
            // the numbers and the gateway, with the consult always primary
            // and the save labelled 'Keep his reports with yours'.
            ttcSectionTitle('What to do with this'),
            if (reading.route == TtcSemenRoute.urgent ||
                reading.route == TtcSemenRoute.azoospermia) ...[
              TtcToolPrimary(
                label: 'Have the report read properly',
                onTap: () => _openAndrologist(context),
              ),
              const SizedBox(height: 10),
              TtcToolSecondary(
                label: kept
                    ? 'Kept with your reports. Open the folder'
                    : 'Keep this with your reports',
                onTap: onKeep,
              ),
            ] else ...[
              TtcToolPrimary(
                label: kept
                    ? 'Kept with your reports. Open the folder'
                    : 'Keep this with your reports',
                onTap: onKeep,
              ),
              const SizedBox(height: 10),
              TtcToolSecondary(
                label: 'Have the report read properly',
                onTap: () => _openAndrologist(context),
              ),
            ],
            const SizedBox(height: 10),
            TtcToolSecondary(label: 'Change an answer', onTap: onEdit),
            const SizedBox(height: 24),

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
                TtcRecordPanel(
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
            // Moved above the numbers (2026-09-27); kept for revert:
            // ttcSectionTitle('What to do with this'),
            // TtcToolPrimary(label: 'Have the report read properly', ...),
            // TtcToolSecondary(label: kept ? 'Kept with your reports. Open
            //     the folder' : 'Keep his reports with yours', ...),
            // TtcToolSecondary(label: 'Change something', onTap: onEdit),

            const SizedBox(height: 22),
            // ⚠️ THE LAST WORD ON EVERY PATH. Not a legal line — the actual
            // limit of what this screen did, said plainly.
            Text(
                'This explains numbers against a published reference. It '
                "isn't a diagnosis, and it can't tell you whether you'll "
                'conceive. An andrologist reads these values together, along '
                'with everything else about you.',
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
      return TtcRecordPanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(line.limit.name,
              style: ttcBody(13.5, color: ttcMuted, w: FontWeight.w700)),
          const SizedBox(height: 5),
          Text("Not entered, so we haven't guessed a number for it.",
              style: ttcBody(12.5, color: ttcMuted, h: 1.45)),
        ]),
      );
    }

    return TtcRecordPanel(
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
    // The one door opener (2026-09-26): the new door, same route name, same
    // wiring gate (an unknown bracket opens nothing). The old push, kept for
    // revert:
    //
    // final page = ttcFocusPageFor(_kIvfBracket);
    // final bracket = bracketById(_kIvfBracket);
    // if (page == null || bracket == null) return;
    // Navigator.of(context).push(MaterialPageRoute<void>(
    //   settings: const RouteSettings(name: 'ttc/focus/$_kIvfBracket'),
    //   builder: (_) => TtcFocusScreen(page: page, bracket: bracket),
    // ));
    openTtcDoor(context, _kIvfBracket);
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
                        'A normal result on his side turns the question to '
                        'the two of you. The readiness check there asks six '
                        'questions and never gives a score.',
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

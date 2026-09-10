// =============================================================================
//  Keep your reports together — rebuilt from the "TTC Records" design project
// -----------------------------------------------------------------------------
//  Options 1a, 1d, 1e, 1f, 1g and 1h. 1b (a date spine) and 1c (a dot chart)
//  were drawn and not taken; both notes below say why, because both were close.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE ONE RULE THAT OVERRIDES EVERY OTHER DECISION HERE
//  ---------------------------------------------------------------------------
//
//  **Nothing on this screen interprets a value.** No normal range, no high or
//  low, no red, no green, no "this looks fine". The app files results; the
//  clinician reads them. A trend of her own three readings with the dates is a
//  description and is allowed; the same three with a shaded band behind them is
//  a second opinion from a phone.
//
//  It is the strictest rule in this part of the product because it is the
//  easiest one to break by being helpful. Every colour choice below is
//  deliberately neutral for that reason — the hue is chrome, never a verdict.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY GROUPED BY TEST AND NOT BY DATE (1a over 1b)
//  ---------------------------------------------------------------------------
//
//  The screen this replaces was a flat, date-ordered list, and it could not
//  answer any of the three questions somebody walking into an appointment
//  actually has: has this changed, what is missing, and which of these is his.
//
//  Grouping answers all three at once. The direction sits on the row before
//  anything is tapped; a coverage block can name what has not been added,
//  because the rows are the same shape as the library's list; and ownership
//  becomes a property of the row rather than a filter above it.
//
//  1b kept the date spine, and its argument is real — she remembers "the tests
//  before the last cycle" rather than "my AMH readings". If recency turns out
//  to matter more than direction, that is the design to go back to.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY A READING STACK AND NOT A CHART (1d over 1c)
//  ---------------------------------------------------------------------------
//
//  Not aesthetics — data shape. This library holds a thyroid panel with a photo
//  and no typed number, an HSG whose result is a sentence, and a semen analysis
//  that is three values in one result. A dot chart renders none of them, so it
//  would be a view that works for the tests which happen to be single numbers
//  and breaks on the rest.
//
//  The stack holds all of it, survives two readings, and is the safer side of
//  the interpretation rule as a bonus rather than as its reason.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_records_grouping.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_tests_data.dart';
import '../../localization/app_language.dart';
import '../../services/remote/storage_service.dart';
import '../../services/ttc_records_pdf.dart';
import 'ttc_attachments.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';

/// The clinical blue-grey this area wears.
const double kTtcRecordsHue = 206;

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String ttcRecordDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}';

/// ⚠️ "YOU" AND "PARTNER", NOT INITIALS. The design draws an avatar with two
/// letters in it — Aarti, Rohan — and this app stores no names for either
/// person. A circle containing "Y" is worse than no circle, so ownership is a
/// small word instead. If names are ever collected, this is the one place to
/// change.
String ttcWhose(bool forPartner) => forPartner ? 'Partner' : 'You';

// =============================================================================
//  1a — the main screen
// =============================================================================

class TtcRecordsBody extends StatelessWidget {
  const TtcRecordsBody({
    super.key,
    required this.onlyPartner,
    this.resultsOnly = false,
  });

  /// null shows everyone, true only his, false only hers.
  final bool? onlyPartner;

  /// The Reports tile's narrowing — library results only. Kept from the screen
  /// this replaces; two tiles have always opened one folder.
  final bool resultsOnly;

  @override
  Widget build(BuildContext context) {
    final all = ttcGroupedRecords(resultsOnly: resultsOnly);
    final groups = onlyPartner == null
        ? all
        : all.where((g) => g.forPartner == onlyPartner).toList();
    final coverage = ttcRecordCoverage();

    if (all.isEmpty) return const TtcRecordsEmpty();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ttcSectionTitle("What you've had done"),
        for (final g in groups) ...[
          _GroupRow(group: g),
          const SizedBox(height: 10),
        ],
        if (groups.isEmpty) ...[
          TtcCard(
            child: Text(
                'Nothing filed under ${ttcWhose(onlyPartner!).toLowerCase()} '
                'yet.',
                style: ttcBody(13.5, h: 1.5)),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 18),
        _Coverage(coverage: coverage),
      ],
    );
  }
}

/// One test, with every reading behind it.
class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});
  final TtcRecordGroup group;

  @override
  Widget build(BuildContext context) {
    final latest = group.latest;
    final value = ttcRecordValue(latest);
    final typed = value.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(ttcCardRadius),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/record'),
        builder: (_) => group.repeated
            ? TtcRecordTrendScreen(groupKey: group.key)
            : TtcRecordDetailScreen(recordId: latest.id),
      )),
      child: TtcCard(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(group.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ttcJakarta(15)),
                    ),
                    if (group.repeated) ...[
                      const SizedBox(width: 8),
                      _Pill(text: '${group.count} readings'),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  if (typed)
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: value,
                          style: ttcBody(14,
                              color: ttcTitleInk, w: FontWeight.w800)),
                      TextSpan(
                          text: ' · ${ttcRecordDate(latest.takenOn)}',
                          style: ttcBody(13, color: ttcSoft)),
                    ]))
                  else
                    // ⚠️ A RECORD WITH NO NUMBER IS A REAL RECORD, NOT A
                    // BROKEN ONE. Photo-first adding means some rows will only
                    // ever be a photograph, and the row has to hold that
                    // without looking like a failure — so it says what it has
                    // and offers the one thing that would complete it.
                    Row(children: [
                      Expanded(
                        child: Text(
                            '${ttcRecordDate(latest.takenOn)} · photo saved, '
                            'number not typed',
                            style: ttcBody(13, color: ttcSoft, h: 1.4)),
                      ),
                      // The one thing that would complete this row, offered on
                      // the row rather than two taps away.
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => showTtcTypeValue(context, latest),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('Type it',
                              style: ttcBody(12.5,
                                  color: ttcTitleInk, w: FontWeight.w800)),
                        ),
                      ),
                    ]),
                  const SizedBox(height: 5),
                  Row(children: [
                    Text(ttcWhose(group.forPartner),
                        style: ttcBody(12, color: ttcMuted,
                            w: FontWeight.w700)),
                    if (group.repeated &&
                        ttcRecordValue(group.oldest).isNotEmpty) ...[
                      Text(' · first was ${ttcRecordValue(group.oldest)}, '
                          '${_months[group.oldest.takenOn.month - 1]} '
                          '${group.oldest.takenOn.year}',
                          style: ttcBody(12, color: ttcMuted)),
                    ] else if (latest.note != null &&
                        latest.note!.trim().isNotEmpty) ...[
                      Text(' · with a note',
                          style: ttcBody(12, color: ttcMuted)),
                    ] else if (latest.attachments.isNotEmpty) ...[
                      // The row says the report itself is in here, because
                      // that is the thing she is actually looking for in a
                      // waiting room - not the number, the paper.
                      Text(
                          ' · ${latest.attachments.length} '
                          '${latest.attachments.length == 1 ? 'photo' : 'photos'}',
                          style: ttcBody(12, color: ttcMuted)),
                    ],
                  ]),
                ]),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: ttcPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(text,
            style: ttcBody(10.5, color: ttcSoft, w: FontWeight.w800)),
      );
}

/// What a first check usually covers, against what she has filed.
class _Coverage extends StatelessWidget {
  const _Coverage({required this.coverage});
  final TtcCoverage coverage;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ttcSectionTitle('What a first check usually covers'),
          TtcCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⚠️ "NOT ADDED", NEVER "MISSING". "Missing" says her workup
                  // is incomplete, which is a judgement about the clinician
                  // looking after her. "Not added" says this app does not have
                  // it — a fact about her filing, which is the only thing this
                  // screen is entitled to know.
                  Text(
                      'These are the tests a fertility check usually includes. '
                      'You have ${coverage.added.length} of '
                      '${coverage.total} saved here.',
                      style: ttcBody(13, h: 1.5)),
                  const SizedBox(height: 14),
                  for (final t in coverage.added) ...[
                    _CoverRow(name: t.name, added: true),
                    const SizedBox(height: 9),
                  ],
                  for (final t in coverage.notAdded) ...[
                    _CoverRow(name: t.name, added: false),
                    const SizedBox(height: 9),
                  ],
                  const SizedBox(height: 4),
                  Text(
                      'Not having one saved here does not mean you have not '
                      'had it. Your clinic decides which of these you need.',
                      style: ttcBody(12, color: ttcMuted, h: 1.5)),
                ]),
          ),
        ],
      );
}

class _CoverRow extends StatelessWidget {
  const _CoverRow({required this.name, required this.added});
  final String name;
  final bool added;

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ⚠️ A DOT, NOT A TICK AND A CROSS. A cross is a failure mark, and
        // nothing here has failed — half these tests are ones her clinic may
        // never order.
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 6, right: 11),
          decoration: BoxDecoration(
            color: added ? ttcTitleInk : Colors.transparent,
            shape: BoxShape.circle,
            border: added ? null : Border.all(color: ttcBorder, width: 1.4),
          ),
        ),
        Expanded(
          child: Text(added ? name : '$name — not added',
              style: ttcBody(13,
                  color: added ? ttcTitleInk : ttcMuted,
                  w: added ? FontWeight.w700 : FontWeight.w600)),
        ),
      ]);
}

// =============================================================================
//  1g — empty
// =============================================================================

class TtcRecordsEmpty extends StatelessWidget {
  const TtcRecordsEmpty({super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TtcCard(
            child: Column(children: [
              Text('Start with the paper in your hand.',
                  textAlign: TextAlign.center,
                  style: ttcFraunces(19,
                      w: FontWeight.w600, color: ttcTitleInk, h: 1.25)),
              const SizedBox(height: 9),
              // ⚠️ THIS LINE PROMISES ONLY WHAT THE SCREEN DOES, and it was
              // rewritten on 2026-09-03 because the first version did not.
              //
              // It read: "One photograph today, and in a year this screen
              // answers the questions a consultation opens with." Two things
              // wrong with it, and the second one cost something. It says the
              // SCREEN answers — this screen answers nothing, it holds things
              // so a person can. And "in a year" is a strange promise to
              // somebody whose consultation is next Tuesday.
              //
              // The cost: it read as upload-and-get-insights, and the first
              // person to see it asked whether the app could extract values
              // from a photograph. It cannot, and copy that makes somebody ask
              // "wait, can it do that?" has failed regardless of how it scans.
              Text(
                  'Photograph it now, and it is on your phone when a doctor '
                  'asks — with the date, and next to whatever came before it.',
                  textAlign: TextAlign.center,
                  style: ttcBody(13.5, h: 1.55)),
              const SizedBox(height: 18),
              // ⚠️ THE CAMERA IS THE PRIMARY ACTION, not a form. The fastest
              // first entry is a photograph of the sheet she is already
              // holding; asking her to type a number first is asking her to
              // read a lab report standing up.
              TtcRecordsAction(
                  label: 'Photograph a report',
                  onTap: () => showTtcRecordAdd(context)),
              const SizedBox(height: 10),
              TtcRecordsAction(
                  label: 'Type a number instead',
                  muted: true,
                  onTap: () => showTtcRecordAdd(context, typing: true)),
            ]),
          ),
          const SizedBox(height: 26),
          ttcSectionTitle('What this becomes'),
          const _Becomes(
            title: 'The same test, twice',
            body: 'A second AMH sits with the first, so the direction it moved '
                'is on the row rather than in your memory.',
          ),
          const SizedBox(height: 10),
          const _Becomes(
            title: 'His results and yours',
            body: 'Every result carries whose it is, so a semen analysis is as '
                'findable as an AMH.',
          ),
          const SizedBox(height: 10),
          const _Becomes(
            title: 'The sheet itself, on the phone',
            body: 'In the waiting room you hold up the report rather than '
                'describing it.',
          ),
        ],
      );
}

class _Becomes extends StatelessWidget {
  const _Becomes({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
        decoration: BoxDecoration(
            color: ttcPanel, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ttcJakarta(14)),
          const SizedBox(height: 4),
          Text(body, style: ttcBody(12.5, h: 1.5)),
        ]),
      );
}

/// The stage's one button.
class TtcRecordsAction extends StatelessWidget {
  const TtcRecordsAction({
    super.key,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: muted ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcLine),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: ttcBody(13.5,
                  color: muted ? ttcSoft : ttcTitleInk, w: FontWeight.w800)),
        ),
      );
}

// =============================================================================
//  1d — one test over time
// =============================================================================

/// Every reading of one test, newest at the top, with the gap between them
/// named in months.
///
/// ⚠️ NO CHART, AND THE REASON IS THE DATA RATHER THAN THE RULE. A dot plot
/// renders a single number and nothing else. This library holds a thyroid panel
/// with a photo and no typed number, an HSG whose result is a sentence, and a
/// semen analysis that is three values in one result — a chart would work for
/// the tests that happen to be single numbers and break on the rest.
///
/// A stack holds all of them. It also survives a test with two readings, which
/// a trend line does not really.
class TtcRecordTrendScreen extends StatelessWidget {
  const TtcRecordTrendScreen({super.key, required this.groupKey});

  final String groupKey;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TtcRecordsStore.instance,
        builder: (context, _) {
          final group = ttcGroupedRecords()
              .where((g) => g.key == groupKey)
              .firstOrNull;
          if (group == null) return const _Gone();

          final oldest = group.oldest;
          final latest = group.latest;
          final span = ttcReadingChange(latest, oldest);

          return TtcToolScaffold(
            hue: kTtcRecordsHue,
            variant: 2,
            eyebrow: ttcWhose(group.forPartner),
            title: '${group.label}, ${_times(group.count)}',
            intro: '${_months[oldest.takenOn.month - 1]} '
                '${oldest.takenOn.year} to '
                '${_months[latest.takenOn.month - 1]} '
                '${latest.takenOn.year}'
                '${latest.unit.trim().isEmpty ? '' : ' · all values in '
                    '${latest.unit.trim()}'}',
            children: [
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  for (var i = 0; i < group.readings.length; i++) ...[
                    _Reading(
                      record: group.readings[i],
                      previous: i + 1 < group.readings.length
                          ? group.readings[i + 1]
                          : null,
                      isLatest: i == 0,
                      isFirst: i == group.readings.length - 1,
                    ),
                  ],
                  if (span != null && group.repeated) ...[
                    const SizedBox(height: 8),
                    // ⚠️ ARITHMETIC ON HER OWN TWO NUMBERS, IN HER OWN UNITS.
                    // "0.9 lower over 17 months" describes what she recorded.
                    // Anything comparing it to a population would be a second
                    // opinion, and this screen does not give one.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                      decoration: BoxDecoration(
                          color: ttcPanel,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BETWEEN THE FIRST AND THE LATEST',
                                style: pvManrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: ttcMuted)),
                            const SizedBox(height: 5),
                            Text(
                                '$span${latest.unit.trim().isEmpty ? '' : ' '
                                    '${latest.unit.trim()}'}, '
                                '${ttcReadingGap(latest.takenOn, oldest.takenOn)
                                    .replaceAll(' later', ' apart')}',
                                style: ttcFraunces(17,
                                    w: FontWeight.w600, color: ttcTitleInk)),
                          ]),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                      'These are your own readings, in the order you saved '
                      'them. What they mean is a question for your clinic.',
                      style: ttcBody(12.5, color: ttcMuted, h: 1.5)),
                  const SizedBox(height: 10),
                ],
              )),
            ],
          );
        },
      );

  static String _times(int n) => switch (n) {
        2 => 'twice',
        3 => 'three times',
        4 => 'four times',
        _ => '$n times',
      };
}

class _Reading extends StatelessWidget {
  const _Reading({
    required this.record,
    required this.previous,
    required this.isLatest,
    required this.isFirst,
  });

  final TtcRecord record;
  final TtcRecord? previous;
  final bool isLatest;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final value = ttcRecordValue(record);
    final change =
        previous == null ? null : ttcReadingChange(record, previous!);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc/record'),
          builder: (_) => TtcRecordDetailScreen(recordId: record.id),
        )),
        child: TtcCard(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLatest || isFirst) ...[
                  Text(isLatest ? 'LATEST' : 'FIRST READING',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: ttcMuted)),
                  const SizedBox(height: 6),
                ],
                if (value.isNotEmpty)
                  Text(value,
                      style: ttcFraunces(26,
                          w: FontWeight.w600, color: ttcTitleInk))
                else
                  Text('Photo only, number not typed',
                      style: ttcBody(14, color: ttcSoft, w: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(ttcRecordDate(record.takenOn),
                    style: ttcBody(12.5, color: ttcMuted)),
                if (record.note != null && record.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(record.note!.trim(), style: ttcBody(13, h: 1.5)),
                ],
                if (record.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.attach_file_rounded, size: 14, color: ttcMuted),
                    const SizedBox(width: 6),
                    Text('Report photo attached',
                        style: ttcBody(12, color: ttcMuted)),
                  ]),
                ],
              ]),
        ),
      ),
      // ⚠️ THE GAP IS NAMED, WHICH IS WHAT REPLACES AN AXIS. "9 months later ·
      // 0.4 lower" tells you the direction and the distance without plotting
      // anything, so it works identically for a number, a sentence and a
      // reading nobody typed.
      if (previous != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(children: [
            Container(width: 2, height: 18, color: ttcBorder),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  '${ttcReadingGap(record.takenOn, previous!.takenOn)}'
                  '${change == null ? '' : ' · $change'}',
                  style: ttcBody(12.5, color: ttcSoft, w: FontWeight.w700)),
            ),
          ]),
        ),
    ]);
  }
}

class _Gone extends StatelessWidget {
  const _Gone();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ttcBg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text('This record has been removed.',
                  style: ttcBody(14, h: 1.5)),
            ),
          ),
        ),
      );
}

// =============================================================================
//  1e — one result in full, and the report held up
// =============================================================================

class TtcRecordDetailScreen extends StatelessWidget {
  const TtcRecordDetailScreen({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TtcRecordsStore.instance,
        builder: (context, _) {
          final r = TtcRecordsStore.instance.records
              .where((e) => e.id == recordId)
              .firstOrNull;
          if (r == null) return const _Gone();
          final value = ttcRecordValue(r);
          final test = r.testId == null ? null : ttcTestById(r.testId!);

          return TtcToolScaffold(
            hue: kTtcRecordsHue,
            variant: 3,
            eyebrow: ttcWhose(r.forPartner),
            title: r.label,
            intro: ttcRecordDate(r.takenOn),
            children: [
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  ttcSectionTitle('Result as printed'),
                  TtcCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ⚠️ "AS PRINTED" IS THE PROMISE OF THIS SCREEN. What
                          // is shown is what the report said, unchanged and
                          // un-annotated. No range beside it, no word about
                          // whether it is high.
                          if (value.isNotEmpty)
                            Text(value,
                                style: ttcFraunces(28,
                                    w: FontWeight.w600, color: ttcTitleInk))
                          else ...[
                            Text('Number not typed',
                                style: ttcBody(15,
                                    color: ttcSoft, w: FontWeight.w700)),
                            const SizedBox(height: 12),
                            TtcRecordsAction(
                                label: 'Type the number',
                                onTap: () => showTtcTypeValue(context, r)),
                          ],
                          const SizedBox(height: 12),
                          ttcDivider(),
                          const SizedBox(height: 12),
                          _Fact(label: 'Date', value: ttcRecordDate(r.takenOn)),
                          if (r.note != null && r.note!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ttcDivider(),
                            const SizedBox(height: 12),
                            // ⚠️ A CLINICIAN'S WORDS ARE HELD VERBATIM AND
                            // ATTRIBUTED, NEVER RE-READ. Where a doctor has
                            // interpreted a result, the app carries the
                            // sentence and stops. Summarising it would put a
                            // phone between her and the person treating her.
                            Text('WHAT WAS WRITTEN',
                                style: pvManrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: ttcMuted)),
                            const SizedBox(height: 6),
                            Text(r.note!.trim(),
                                style: ttcBody(14, h: 1.6, color: ttcInk)),
                            const SizedBox(height: 6),
                            Text('Saved from the report, '
                                '${ttcRecordDate(r.takenOn)}',
                                style: ttcBody(11.5, color: ttcMuted)),
                          ],
                        ]),
                  ),
                  // ⚠️ CARRIED OVER FROM THE CARD THIS REPLACES, DELIBERATELY.
                  // The old screen printed the library's plain-language note
                  // beside every library result so a number never sat alone,
                  // and dropping it in a redesign would have been a silent
                  // regression rather than a decision. It moved from the list
                  // row to here because a list of fifteen paragraphs is not
                  // read; one paragraph on the result she opened is.
                  //
                  // It explains what the test measures. It says nothing about
                  // *her* number — that is the line this whole area does not
                  // cross.
                  if (test != null) ...[
                    const SizedBox(height: 24),
                    ttcSectionTitle('What this test measures'),
                    TtcCard(
                      child: Text(test.reading(TtcS.current().hinglish),
                          style: ttcBody(13.5, h: 1.6, color: ttcTitleInk)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ttcSectionTitle('The report itself'),
                  if (r.attachments.isEmpty)
                    TtcCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No photo saved for this one.',
                                style: ttcBody(13.5, h: 1.5)),
                            const SizedBox(height: 14),
                            TtcRecordsAction(
                                label: 'Add a photo of the report',
                                onTap: () => _attach(context, r)),
                          ]),
                    )
                  else
                    for (var i = 0; i < r.attachments.length; i++) ...[
                      _Sheet(
                        path: r.attachments[i],
                        caption: '${r.label} · ${ttcRecordDate(r.takenOn)} · '
                            '${i + 1} of ${r.attachments.length}',
                      ),
                      const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 10),
                ],
              )),
            ],
          );
        },
      );

  Future<void> _attach(BuildContext context, TtcRecord r) async {
    final added = await showTtcAttachmentPicker(context, TtcS.current());
    if (added.isEmpty) return;
    TtcRecordsStore.instance
        .replace(r.copyWith(attachments: [...r.attachments, ...added]));
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: ttcMuted)),
        const SizedBox(height: 4),
        Text(value, style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w700)),
      ]);
}

/// The saved sheet, tappable into the viewer.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.path, required this.caption});
  final String path;
  final String caption;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc/record_sheet'),
          builder: (_) => TtcSheetViewer(path: path, caption: caption),
        )),
        child: TtcCard(
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ttcPanel, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.description_outlined,
                  size: 22, color: ttcTitleInk),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Photo of the lab sheet', style: ttcJakarta(14)),
                    const SizedBox(height: 3),
                    Text('Tap to open full screen',
                        style: ttcBody(12.5, color: ttcMuted)),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
          ]),
        ),
      );
}

/// The report, full screen, built for being held up to somebody else.
///
/// ⚠️ EVERY CHOICE HERE IS ABOUT ONE MOMENT: a phone turned round and handed
/// across a desk. So it is full-bleed on black rather than a card on a page,
/// it says out loud that the phone can be turned sideways because a lab sheet
/// is wider than it is tall, and the caption stays on screen so the person
/// receiving it knows what they are looking at without being told.
///
/// ⚠️ THE BRIGHTNESS LINE IS A PROMISE THIS APP CANNOT KEEP YET. The design
/// raises screen brightness on open. Doing that needs a platform channel and a
/// permission on some devices, so the label is NOT shown — a screen claiming to
/// have brightened itself when it has not is worse than one that says nothing.
/// Recorded in `docs/STILL-OPEN.md`.
class TtcSheetViewer extends StatelessWidget {
  const TtcSheetViewer({super.key, required this.path, required this.caption});

  final String path;
  final String caption;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(child: _Resolved(ref: path)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(Icons.close_rounded,
                            size: 20, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(caption,
                      textAlign: TextAlign.center,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                      'Pinch to zoom. Turn the phone sideways to fill the '
                      'screen.',
                      textAlign: TextAlign.center,
                      style: pvManrope(
                          fontSize: 11.5,
                          height: 1.4,
                          color: Colors.white.withValues(alpha: 0.7))),
                ]),
              ),
            ),
          ),
        ]),
      );
}

/// The saved file, fetched through the storage layer.
///
/// ⚠️ THE APP HAS NEVER DISPLAYED AN ATTACHMENT BEFORE. Until now a saved
/// report was a chip with a filename on it, so nothing in the codebase turned a
/// stored ref into a picture. `StorageService.resolve` already does the hard
/// half — it handles both a storage object path and a legacy absolute local
/// path, and downloads and caches on demand — which is why this is a
/// `FutureBuilder` and not an `Image.file`.
///
/// ⚠️ A PDF IS NOT SHOWN, AND SAYS SO. Rendering one needs a package this repo
/// does not carry. A blank black screen where a report should be is the worst
/// possible outcome in a waiting room, so the file is named honestly instead.
class _Resolved extends StatefulWidget {
  const _Resolved({required this.ref});
  final String ref;

  @override
  State<_Resolved> createState() => _ResolvedState();
}

class _ResolvedState extends State<_Resolved> {
  late final Future<File?> _file = StorageService.resolve(widget.ref);

  @override
  Widget build(BuildContext context) {
    if (widget.ref.toLowerCase().endsWith('.pdf')) {
      return _Unshown(
          label: _basename(widget.ref),
          body: 'This report is a PDF. Open it from your files to show it.');
    }
    return FutureBuilder<File?>(
      future: _file,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          );
        }
        final f = snap.data;
        if (f == null) {
          return const _Unshown(
              label: 'Report not available',
              body: 'It may still be uploading, or it was saved on another '
                  'device.');
        }
        return Image.file(f, fit: BoxFit.contain);
      },
    );
  }
}

/// The file's own name, whichever slash the platform used.
///
/// ⚠️ NOT A REGEX. `RegExp('[/\\]')` reads correctly and is a syntax error: the
/// backslash escapes the closing bracket, so the character class never ends.
/// It is the kind of bug that survives review because the line looks obviously
/// right — two separate `lastIndexOf` calls are duller and cannot be wrong.
String _basename(String ref) {
  var out = ref;
  for (final sep in const ['/', '\\']) {
    final i = out.lastIndexOf(sep);
    if (i >= 0) out = out.substring(i + 1);
  }
  return out;
}

class _Unshown extends StatelessWidget {
  const _Unshown({required this.label, required this.body});
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(34),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.description_outlined, size: 34, color: Colors.white54),
          const SizedBox(height: 14),
          Text(label,
              textAlign: TextAlign.center,
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 7),
          Text(body,
              textAlign: TextAlign.center,
              style: pvManrope(
                  fontSize: 12.5, height: 1.5, color: Colors.white70)),
        ]),
      );
}

// =============================================================================
//  1f — adding a result, photo first
// =============================================================================

/// ⚠️ THE CAMERA OPENS FIRST AND EVERYTHING ELSE IS OPTIONAL.
///
/// She is standing up holding a lab sheet with a dozen values on it. Capture is
/// one tap and cannot be got wrong; finding the right number among the twelve
/// and typing it accurately is the slow, error-prone part — and it can be done
/// later, sitting down, or never.
///
/// So the photograph IS the record. The only required field is the date, and
/// the date is prefilled with today.
///
/// ⚠️ AND "WHOSE RESULT" IS NEVER ASKED. It used to be a toggle in this sheet
/// AND a filter on the list — two places to think about the same thing. A semen
/// analysis is filed to the partner by the test itself; everything else follows
/// the last thing she filed, correctable on one quiet line at the bottom.
Future<void> showTtcRecordAdd(BuildContext context, {bool typing = false}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSheet(startTyping: typing),
    );

class _AddSheet extends StatefulWidget {
  const _AddSheet({required this.startTyping});
  final bool startTyping;

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _label = TextEditingController();
  final _value = TextEditingController();
  final _unit = TextEditingController();

  List<String> _shots = [];
  DateTime _taken = DateTime.now();
  bool? _partner;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Straight to the camera unless she chose to type.
    if (!widget.startTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _value.dispose();
    _unit.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final picked = await showTtcAttachmentPicker(context, TtcS.current());
    if (picked.isEmpty || !mounted) return;
    setState(() => _busy = true);
    final refs = <String>[];
    for (final p in picked) {
      refs.add(await StorageService.upload(p, 'ttc_record'));
    }
    if (!mounted) return;
    setState(() {
      _shots = [..._shots, ...refs];
      _busy = false;
    });
  }

  /// ⚠️ THE TEST DECIDES WHOSE IT IS, WHERE THE TEST CAN. A semen analysis is
  /// never hers. Everything else follows what she filed last, which is right
  /// far more often than a toggle nobody reads.
  bool get _whose {
    if (_partner != null) return _partner!;
    final label = _label.text.trim().toLowerCase();
    final test = ttcTests.where((t) => t.name.toLowerCase().startsWith(label));
    if (label.isNotEmpty && test.isNotEmpty) return test.first.forHim;
    final last = TtcRecordsStore.instance.records;
    return last.isEmpty ? false : last.first.forPartner;
  }

  bool get _canSave => _shots.isNotEmpty || _label.text.trim().isNotEmpty;

  void _save() {
    final label = _label.text.trim();
    final match = ttcTests
        .where((t) => t.name.toLowerCase().startsWith(label.toLowerCase()));
    final rec = TtcRecordsStore.instance.add(
      label: label.isEmpty ? 'Report' : label,
      takenOn: _taken,
      testId: label.isEmpty || match.isEmpty ? null : match.first.id,
      value: _value.text.trim(),
      unit: _unit.text.trim(),
      forPartner: _whose,
    );
    if (_shots.isNotEmpty) {
      TtcRecordsStore.instance.replace(rec.copyWith(attachments: _shots));
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final saved = _shots.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                          color: ttcBorder,
                          borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('ADD A RESULT',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: ttcMuted)),
                  const SizedBox(height: 8),
                  Text(
                      saved
                          ? 'Photo saved.'
                          : 'Fit the whole sheet in the frame.',
                      style: ttcFraunces(22,
                          w: FontWeight.w600, color: ttcTitleInk, h: 1.2)),
                  const SizedBox(height: 6),
                  Text(
                      saved
                          ? 'Everything below is optional. You can come back '
                              'to it.'
                          : 'You can type the number in later.',
                      style: ttcBody(13, h: 1.45)),
                  const SizedBox(height: 18),

                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                          child: SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))),
                    )
                  else if (saved)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: ttcPanel,
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 18, color: ttcTitleInk),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              '${_shots.length} '
                              '${_shots.length == 1 ? 'photo' : 'photos'} '
                              'attached',
                              style: ttcBody(13,
                                  color: ttcTitleInk, w: FontWeight.w700)),
                        ),
                        GestureDetector(
                          onTap: _capture,
                          behavior: HitTestBehavior.opaque,
                          child: Text('Add another',
                              style: ttcBody(12.5,
                                  color: ttcSoft, w: FontWeight.w800)),
                        ),
                      ]),
                    )
                  else
                    TtcRecordsAction(
                        label: 'Open the camera', onTap: _capture),

                  const SizedBox(height: 20),
                  _Field(label: 'What test was it', controller: _label),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      flex: 3,
                      child: _Field(
                          label: 'The number',
                          controller: _value,
                          keyboard: const TextInputType.numberWithOptions(
                              decimal: true)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _Field(label: 'Unit', controller: _unit),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _DateField(
                    taken: _taken,
                    onPick: (d) => setState(() => _taken = d),
                  ),

                  const SizedBox(height: 14),
                  // ⚠️ ONE QUIET LINE, NOT A TOGGLE. It states what the app has
                  // worked out and offers the other answer. A control asking
                  // her to classify every result is a question she has to
                  // answer fifteen times to correct twice.
                  Row(children: [
                    Expanded(
                      child: Text('Filing under ${ttcWhose(_whose)}',
                          style: ttcBody(12.5, color: ttcSoft)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _partner = !_whose),
                      behavior: HitTestBehavior.opaque,
                      child: Text('${ttcWhose(!_whose)} instead',
                          style: ttcBody(12.5,
                              color: ttcTitleInk, w: FontWeight.w800)),
                    ),
                  ]),

                  const SizedBox(height: 20),
                  TtcRecordsAction(
                      label: 'Save this result',
                      onTap: _canSave ? _save : () {}),
                  const SizedBox(height: 10),
                  Center(
                    child: Text('This is a record, not a verdict.',
                        style: ttcBody(12, color: ttcMuted)),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: ttcMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: ttcPanel,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ]);
}

class _DateField extends StatelessWidget {
  const _DateField({required this.taken, required this.onPick});

  final DateTime taken;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DATE ON THE REPORT',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcMuted)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: taken,
                firstDate: DateTime(2015),
                // ⚠️ NO FUTURE DATES. A report cannot have been printed
                // tomorrow, and a future date would sort to the top of every
                // group and become the "latest" reading for ever.
                lastDate: DateTime.now(),
              );
              if (picked != null) onPick(picked);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                  color: ttcPanel, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Expanded(
                  child: Text(ttcRecordDate(taken),
                      style: ttcBody(14,
                          color: ttcTitleInk, w: FontWeight.w700)),
                ),
                Icon(Icons.calendar_today_outlined, size: 15, color: ttcMuted),
              ]),
            ),
          ),
        ],
      );
}

// =============================================================================
//  1h — into the appointment
// =============================================================================

/// ⚠️ A SHEET, NOT A SCREEN, AND THAT WAS THE CALL. The waiting-room moment is
/// real, but a separate "appointment mode" destination risks becoming a second
/// app. PCOS already has this shape — "What to take to your doctor" is a small
/// shareable summary rather than a place you go — and one pattern for one job
/// is worth more than a better version of two.
///
/// ⚠️ TYPE IS ONE TIER UP THROUGHOUT, because it gets read at arm's length by
/// somebody else. And it ends on what is NOT here, which is the line that stops
/// a summary being mistaken for the whole file.
Future<void> showTtcRecordsForAppointment(
  BuildContext context, {
  TtcAppointment? appointment,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentSheet(appointment: appointment),
    );

class _AppointmentSheet extends StatefulWidget {
  const _AppointmentSheet({this.appointment});

  /// The appointment this was opened for, where there is one. It names the
  /// sheet rather than changing it — the six most recent results are the six
  /// most recent results whoever is about to read them.
  final TtcAppointment? appointment;

  @override
  State<_AppointmentSheet> createState() => _AppointmentSheetState();
}

class _AppointmentSheetState extends State<_AppointmentSheet> {
  bool _busy = false;

  TtcAppointment? get appointment => widget.appointment;

  /// ⚠️ THE SHEET SHOWS SIX; THE PDF CARRIES EVERYTHING. Not an inconsistency —
  /// the two are read by different people in different rooms. See the head of
  /// `ttc_records_pdf.dart` for why a medical summary must not quietly stop at
  /// six.
  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await TtcRecordsPdf.build(
        // ⚠️ TTC KEEPS ITS OWN LANGUAGE FLAG. `TtcLang` is a bool, the PDF
        // font loader takes `AppLanguage`, and the two have never met. The
        // conversion belongs here rather than in the PDF, which should not
        // know that one stage models language differently from the rest.
        lang: TtcLang.instance.hinglish
            ? AppLanguage.hinglish
            : AppLanguage.english,
        forAppointment: appointment?.title,
      );
      if (!mounted) return;
      if (bytes == null) {
        // Fonts did not load. Say what happened rather than hand over a
        // document that may print as empty boxes.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Could not prepare the file — it needs a connection the first '
              'time. Your records are safe either way.',
              style: ttcBody(13, color: Colors.white)),
        ));
        return;
      }
      await TtcRecordsPdf.present(bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _eyebrow() {
    final a = appointment;
    if (a == null) return 'TO TAKE IN';
    final d = a.startsLocal;
    final now = DateTime.now();
    final today = d.year == now.year && d.month == now.month && d.day == now.day;
    return today ? 'FOR TODAY' : 'FOR ${ttcRecordDate(d).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final groups = ttcGroupedRecords().take(6).toList();
    final coverage = ttcRecordCoverage();

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                        color: ttcBorder,
                        borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                    child: Text(_eyebrow(),
                        style: pvManrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: ttcMuted)),
                  ),
                  // ⚠️ THE ONE PLACE THIS SHEET CAN LEAVE THE PHONE. It sits
                  // here rather than on the records screen because sharing is
                  // the handover moment, and the handover moment is what this
                  // sheet is. A share control on the folder itself would invite
                  // it at every other moment too.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _share,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (_busy)
                        const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(strokeWidth: 1.8))
                      else
                        Icon(Icons.ios_share_rounded,
                            size: 15, color: ttcTitleInk),
                      const SizedBox(width: 6),
                      Text(_busy ? 'Preparing' : 'Share as PDF',
                          style: ttcBody(12.5,
                              color: ttcTitleInk, w: FontWeight.w800)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 7),
                if (appointment != null) ...[
                  Text(appointment!.title,
                      style: ttcBody(14.5,
                          color: ttcTitleInk, w: FontWeight.w800)),
                  const SizedBox(height: 7),
                ],
                Text('The most recent, yours and theirs, in date order.',
                    style: ttcFraunces(21,
                        w: FontWeight.w600, color: ttcTitleInk, h: 1.25)),
                const SizedBox(height: 20),
                for (final g in groups) ...[
                  _Line(group: g),
                  const SizedBox(height: 16),
                ],
                if (coverage.notAdded.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ttcDivider(),
                  const SizedBox(height: 14),
                  Text('NOT IN HERE',
                      style: pvManrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: ttcMuted)),
                  const SizedBox(height: 6),
                  Text(
                      coverage.notAdded.map((t) => t.name).join(', '),
                      style: ttcBody(14, h: 1.5, color: ttcSoft)),
                ],
                const SizedBox(height: 18),
                Text(
                    'Photos of each report are one tap from every row on the '
                    'previous screen.',
                    style: ttcBody(12.5, color: ttcMuted, h: 1.5)),
              ]),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.group});
  final TtcRecordGroup group;

  @override
  Widget build(BuildContext context) {
    final latest = group.latest;
    final value = ttcRecordValue(latest);
    final before = group.repeated ? ttcRecordValue(group.oldest) : '';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value.isEmpty ? group.label : '${group.label}  $value',
          style: ttcBody(16.5, color: ttcTitleInk, w: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(
          '${ttcRecordDate(latest.takenOn)}'
          '${before.isEmpty ? '' : ' · was $before in '
              '${_months[group.oldest.takenOn.month - 1]} '
              '${group.oldest.takenOn.year}'}'
          '${latest.note != null && latest.note!.trim().isNotEmpty
              ? ' · note saved'
              : ''}',
          style: ttcBody(13.5, color: ttcSoft, h: 1.4)),
    ]);
  }
}

// =============================================================================
//  Completing a photo-only record — "Type it"
// -----------------------------------------------------------------------------
//  ⚠️ THE OTHER HALF OF PHOTO-FIRST ADDING. Letting her save a photograph and
//  nothing else is only kind if there is a way back to finish it later. Without
//  this the fastest path to filing a result also permanently produces a row
//  that can never show a value or join a trend, and "optional" quietly becomes
//  "unavailable".
//
//  It edits the value and the unit and nothing else. The label, the date and
//  whose it is were decided when it was filed; a two-field sheet that can
//  silently rewrite four things is how records drift.
// =============================================================================

Future<void> showTtcTypeValue(BuildContext context, TtcRecord record) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TypeSheet(record: record),
    );

class _TypeSheet extends StatefulWidget {
  const _TypeSheet({required this.record});
  final TtcRecord record;

  @override
  State<_TypeSheet> createState() => _TypeSheetState();
}

class _TypeSheetState extends State<_TypeSheet> {
  late final _value = TextEditingController(text: widget.record.value);
  late final _unit = TextEditingController(text: widget.record.unit);

  @override
  void dispose() {
    _value.dispose();
    _unit.dispose();
    super.dispose();
  }

  void _save() {
    TtcRecordsStore.instance.replace(widget.record.copyWith(
      value: _value.text.trim(),
      unit: _unit.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                            color: ttcBorder,
                            borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(widget.record.label.toUpperCase(),
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: ttcMuted)),
                    const SizedBox(height: 8),
                    Text('What does the report say?',
                        style: ttcFraunces(22,
                            w: FontWeight.w600, color: ttcTitleInk, h: 1.2)),
                    const SizedBox(height: 6),
                    Text(
                        'Copy the number across exactly as it is printed. '
                        '${ttcRecordDate(widget.record.takenOn)}.',
                        style: ttcBody(13, h: 1.45)),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(
                        flex: 3,
                        child: _Field(
                            label: 'The number',
                            controller: _value,
                            keyboard: const TextInputType.numberWithOptions(
                                decimal: true)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _Field(label: 'Unit', controller: _unit),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    TtcRecordsAction(label: 'Save it', onTap: _save),
                    const SizedBox(height: 10),
                    Center(
                      child: Text('The photo stays either way.',
                          style: ttcBody(12, color: ttcMuted)),
                    ),
                  ]),
            ),
          ),
        ),
      );
}

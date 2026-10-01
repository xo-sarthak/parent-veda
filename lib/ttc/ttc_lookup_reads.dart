// =============================================================================
//  A medical test, and a "Can I...?" answer, as reads
// -----------------------------------------------------------------------------
//  Added 2026-09-27, night, in the tool rebuild. Both look-ups used to open
//  their detail by growing a card in place inside the list: the list she was
//  scanning jumped, "Read more" sat under every card in violet, and the detail
//  had no room for a way on (add my result, ask, read the next one).
//
//  ⚠️ ONE READER. CLAUDE.md: every piece of writing opens in `PvReaderScreen`
//  as a `PvRead`, look-ups included, and pregnancy's "Is it safe?" answer
//  already does (`lib/data/reads/can_i_read.dart`, 2026-09-19). So a test and
//  an answer open the same way as every other read in the app, from an
//  adapter, with no seed data moved: `ttcTests` and `ttcCanI` stay exactly as
//  they are and this file turns one into a read at the moment it is opened
//  (STILL-OPEN §60.1, the `fromX()` adapter shape).
//
//  What the page says, in what order, and why (Mobbin: Superpower "Vitamin D",
//  https://mobbin.com/screens/c5491ab9-d410-4863-a6ae-23c8601eb021, headed
//  "What is X? / Why is X important?"; Oportun "Is my money...",
//  https://mobbin.com/screens/a42f206c-f6c2-42aa-a5fa-873fa3e744f9, "The short
//  answer is yes" first; Wise, related articles at the foot,
//  https://mobbin.com/screens/058ba929-8b19-4f91-afc2-f2820c2f0ef4; and the gap
//  analysis's "headings written as her questions"):
//
//    A test:   what it checks (the standfirst) · When should I have it? ·
//              Why is it done? · What does my result mean? · [Add my result]
//              · What does it cost? · the doctor's-call note · Read next:
//              the next tests in the order people meet them.
//    Can I:    the verdict and its limit (the standfirst) · the short answer
//              · Why is that the answer? · In an Indian home · the doctor's-
//              call note · Ask Veda · Read next: the rest of its group.
//
//  ⚠️ WHEN COMES FIRST ON A TEST. It is the one fact that costs a month when
//  it is wrong (FSH and LH on the wrong day are a repeat test next cycle), so
//  it is the first heading, and it is on the list row too.
//
//  ⚠️ NOT "REVIEWED BY". The byline is the ParentVeda team without the
//  verified mark (`reviewed: false`), the rule the daily insights follow: no
//  named clinician has signed these seeds off.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/pv_read.dart';
import '../screens/reader/pv_reader_screen.dart';
import '../screens/ttc/ttc_askveda_screen.dart' show openTtcAskVeda;
import '../screens/ttc/ttc_can_i_screen.dart' show ttcCanIGroupOf;
import '../screens/ttc/ttc_read_blocks_view.dart' show ttcReadCustomBlock;
import '../screens/ttc/ttc_records_screen.dart' show openTtcRecords;
import '../screens/ttc/ttc_semen_report_screen.dart' show openTtcSemenReport;
import '../screens/ttc/ttc_strings.dart';
import '../screens/ttc/ttc_surface_router.dart' show openTtcSurface;
import '../screens/ttc/ttc_tests_screen.dart' show ttcTestsInOrder;
import '../screens/ttc/ttc_tool_chrome.dart';
import '../theme/pv_fonts.dart';
import '../screens/v2/v2_palette.dart';
import 'ttc_can_i_data.dart';
import 'ttc_can_i_recent_store.dart';
import 'ttc_tests_data.dart';

const String kTtcTestReadPrefix = 'ttc_test_';
const String kTtcCanIReadPrefix = 'ttc_cani_';

/// The action a read's "Ask Veda" step carries: `ask:` and her words.
const String kTtcAskActionPrefix = 'ask:';

LocalizedText _en(String en) => LocalizedText(en: en, hi: en);

AppLanguage get _lang =>
    TtcLang.instance.hinglish ? AppLanguage.hinglish : AppLanguage.english;

// ---- a medical test -------------------------------------------------------

/// Carried in a test read's sections; drawn by [ttcLookupCustomBlock] as the
/// "Add my result" button, right under what the result means.
class TtcTestActionBlock {
  const TtcTestActionBlock(this.test);
  final TtcTest test;
}

PvRead ttcTestAsRead(TtcTest test) {
  final order = ttcTestsInOrder(him: test.forHim);
  final at = order.indexWhere((t) => t.id == test.id);
  final next = <String>[
    for (var k = 1; k <= 2 && k < order.length; k++)
      kTtcTestReadPrefix + order[(at + k) % order.length].id,
  ];
  return PvRead(
    id: kTtcTestReadPrefix + test.id,
    kicker: _en('Medical tests'),
    title: _en(test.name),
    teaser: LocalizedText(en: test.whatEn, hi: test.whatHi),
    // No lede: the standfirst is the one-line "what it checks", and the
    // first heading is the timing. A lede here said the "why" twice.
    scaleSetter: _en(''),
    author: _en('ParentVeda team'),
    authorRole: _en('Test library'),
    reviewed: false,
    hue: 206,
    sections: [
      PvReadSection(
        heading: _en('When should I have it?'),
        paragraphs: [LocalizedText(en: test.whenEn, hi: test.whenHi)],
      ),
      PvReadSection(
        heading: _en('Why is it done?'),
        paragraphs: [LocalizedText(en: test.whyEn, hi: test.whyHi)],
      ),
      PvReadSection(
        heading: _en('What does my result mean?'),
        paragraphs: [LocalizedText(en: test.readingEn, hi: test.readingHi)],
      ),
      PvReadSection(custom: TtcTestActionBlock(test)),
      PvReadSection(
        heading: _en('What does it cost?'),
        paragraphs: [
          LocalizedText(
              en: 'Usually ${test.costEn}. Prices are a rough guide and '
                  'vary by city and lab.',
              hi: '${const TtcS(true).testCost} ${test.costHi}. Prices sirf '
                  'andaaza hain aur jagah ke hisaab se badalte hain.'),
        ],
      ),
    ],
    whenToSeeSomeone: const PvCallout(
      tone: PvCalloutTone.note,
      title: LocalizedText(
          en: 'Information, not advice',
          hi: 'Jaankari hai, salaah nahi'),
      body: LocalizedText(
          en: 'Which tests to have, and when, is for you and your doctor to '
              'decide.',
          hi: 'Kaunsa test kab karwana hai, ye aapke doctor ke saath tay hota '
              'hai.'),
    ),
    faqs: const [],
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.ask,
        title: _en('Ask Veda'),
        value: _en('A question about this test, in your own words.'),
        action: '$kTtcAskActionPrefix${test.name}: ',
      ),
    ],
    readNext: next,
  );
}

PvRead? ttcTestReadById(String id) {
  final bare = id.startsWith(kTtcTestReadPrefix)
      ? id.substring(kTtcTestReadPrefix.length)
      : id;
  final t = ttcTestById(bare);
  return t == null ? null : ttcTestAsRead(t);
}

// ---- a "Can I...?" answer -------------------------------------------------

PvRead ttcCanIAsRead(TtcCanI item) {
  final group = ttcCanIGroupOf(item.id);
  final peers = [
    for (final e in ttcCanI)
      if (e.id != item.id && ttcCanIGroupOf(e.id) == group) e,
  ];
  String verdict(bool hi) {
    final limit = item.limit(hi);
    return limit == null
        ? '${item.verdict.label(hi)}.'
        : '${item.verdict.label(hi)}: $limit.';
  }

  return PvRead(
    id: kTtcCanIReadPrefix + item.id,
    kicker: LocalizedText(
        en: const TtcS(false).canITitle, hi: const TtcS(true).canITitle),
    title: LocalizedText(en: item.question(false), hi: item.question(true)),
    // The verdict IS the standfirst: the word, and its limit where it has
    // one, before a single sentence of reasoning.
    teaser: LocalizedText(en: verdict(false), hi: verdict(true)),
    shortAnswer: LocalizedText(en: item.short(false), hi: item.short(true)),
    scaleSetter: _en(''),
    author: _en('ParentVeda team'),
    authorRole: LocalizedText(
        en: const TtcS(false).canITitle, hi: const TtcS(true).canITitle),
    reviewed: false,
    hue: 104,
    sections: [
      PvReadSection(
        heading: _en('Why is that the answer?'),
        paragraphs: [LocalizedText(en: item.why(false), hi: item.why(true))],
      ),
      PvReadSection(
        tip: PvReadTip(
          title: _en('In an Indian home'),
          body: LocalizedText(en: item.indian(false), hi: item.indian(true)),
        ),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.note,
      title: _en('A general answer, not advice about you'),
      body: LocalizedText(
          en: const TtcS(false).canIDisclaimer,
          hi: const TtcS(true).canIDisclaimer),
    ),
    faqs: const [],
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.ask,
        title: _en('Ask Veda'),
        value: _en('Still unsure? Ask in your own words.'),
        action: '$kTtcAskActionPrefix${item.questionEn}',
      ),
    ],
    readNext: [
      for (final e in peers.take(3)) kTtcCanIReadPrefix + e.id,
    ],
  );
}

PvRead? ttcCanIReadById(String id) {
  final bare = id.startsWith(kTtcCanIReadPrefix)
      ? id.substring(kTtcCanIReadPrefix.length)
      : id;
  final e = ttcCanIById(bare);
  return e == null ? null : ttcCanIAsRead(e);
}

// ---- opening them ---------------------------------------------------------

PvRead? _lookupReadById(String id) =>
    ttcTestReadById(id) ?? ttcCanIReadById(id);

void _openAction(BuildContext context, String action) {
  if (action.startsWith(kTtcAskActionPrefix)) {
    openTtcAskVeda(context,
        initialQuery: action.substring(kTtcAskActionPrefix.length));
  }
}

void _openLookupRead(BuildContext context, PvRead read, String route) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: route),
    builder: (_) => PvReaderScreen(
      read: read,
      lang: _lang,
      resolveRead: _lookupReadById,
      readTitle: (id) => _lookupReadById(id)?.title,
      openRead: (ctx, id) {
        if (id.startsWith(kTtcTestReadPrefix)) {
          if (ttcTestById(id.substring(kTtcTestReadPrefix.length))
              case final t?) {
            openTtcTestRead(ctx, t);
          }
        } else if (id.startsWith(kTtcCanIReadPrefix)) {
          if (ttcCanIById(id.substring(kTtcCanIReadPrefix.length))
              case final e?) {
            openTtcCanIRead(ctx, e);
          }
        }
      },
      openSurface: openTtcSurface,
      openAction: _openAction,
      customBlock: ttcLookupCustomBlock,
    ),
  ));
}

/// Open one test in the reader. Every test tap in the stage comes here.
void openTtcTestRead(BuildContext context, TtcTest test) =>
    _openLookupRead(context, ttcTestAsRead(test), 'ttc/test/${test.id}');

/// Open one "Can I...?" answer in the reader.
///
/// Every way in (the list, recently checked, an Ask Veda pointer, a read-next
/// link) counts as checked, so "Recently checked" on the tool is true to what
/// she opened (2026-09-29). Kept for revert: the arrow body alone.
void openTtcCanIRead(BuildContext context, TtcCanI item) {
  TtcCanIRecentStore.instance.touch(item.id);
  _openLookupRead(context, ttcCanIAsRead(item), 'ttc/can_i/${item.id}');
}

/// Draws this file's blocks, and hands every other block to the stage's
/// shared renderer, so a read opened here draws the same as anywhere else.
Widget ttcLookupCustomBlock(BuildContext context, Object block) =>
    switch (block) {
      TtcTestActionBlock(:final test) => _TestActions(test: test),
      _ => ttcReadCustomBlock(context, block),
    };

/// "Add my result", under what the result means. Reading turns into doing:
/// Records opens on the add page with this test already chosen, so the
/// result files under the right name and groups with any earlier one.
class _TestActions extends StatelessWidget {
  const _TestActions({required this.test});

  final TtcTest test;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          test.forHim
              ? 'Got a semen analysis report? Keep it with your records, or '
                  'go through it line by line.'
              : 'Had this test? Keep the result with your records, next to '
                  'any earlier one.',
          style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
      const SizedBox(height: 12),
      KeyedSubtree(
        key: ValueKey('ttc_test_add_${test.id}'),
        child: TtcToolPrimary(
          label: 'Add my result',
          onTap: () => openTtcRecords(context, addTestId: test.id),
        ),
      ),
      if (test.id == 'semen') ...[
        const SizedBox(height: 10),
        KeyedSubtree(
          key: const ValueKey('ttc_test_semen_reader'),
          child: TtcToolSecondary(
            label: 'Read my report, line by line',
            onTap: () => openTtcSemenReport(context),
          ),
        ),
      ],
    ]);
  }
}

// =============================================================================
//  Tests, Scans & Reports  -  Section 16 (merged feature)
// -----------------------------------------------------------------------------
//  Merges the old "Understanding Your Report" + "Scans & Care" into ONE calm,
//  browsable library. Two sections behind a segmented toggle:
//    1. Tests & Scans          - the common pregnancy tests/scans, each with
//                                What it is / Why / When / Preparation /
//                                Procedure / Understanding Your Report /
//                                Medical Disclaimer.
//    2. Findings & Conditions  - common findings, each with What is it / Why /
//                                Symptoms / Diagnosis / Implications /
//                                Management / When to contact / FAQ / Disclaimer.
//
//  Top filter chips (All / Trimester 1 / 2 / 3 / Any Time) apply to whichever
//  library is showing. Appointments have been REMOVED from this tool - they live
//  in the Calendar (out of scope here). List → detail UX; every detail page ends
//  with a reusable Medical Disclaimer.
//
//  Content: lib/data/tests_scans_reports_data.dart.
//
//  ⚠️ ONE PARENTVEDA (2026-09-30, the pregnancy restyle, after main's TTC
//  records and test library). The page is the TTC tool's shape in pregnancy's
//  pieces (`preg_chrome.dart`): the app bar carries only the back arrow and
//  the serif page title sits on the page; the library is ONE white card of
//  rows with drawn marks (a scan's fan, a report's page, a body for a
//  finding) and hairlines between them, in the Tools tab's "Track" hue, so
//  the row and the tile that opened it read as one place. The teal accent,
//  the soft shadows, the gradient header and the amber blocks behind text are
//  gone: selected chips and the toggle are the one ink, a section is a white
//  card with the hairline, and the disclaimer is a quiet note on the page.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/tests_scans_reports_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
// Kept for revert alongside the commented-out `pregHealthStrip` call below.
// import '../../widgets/profile_ask_strip.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../pregnancy/preg_chrome.dart';
import '../products/pv_store_chrome.dart' show PvChip, kPvInk, kPvLine, pvStorePalette;

// Kept for revert (2026-09-30): the teal accent and the soft card shadow.
// const Color _accent = Color(0xFF2E9C8E); // calm teal (matches Scans / Journal)
// const List<BoxShadow> _soft = [
//   BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
// ];

/// The Tools tab's "Track" hue (`tools_hub_screen.dart`), where this tool's
/// tile sits: the row's mark wears the same tint as the tile that opened it.
const double _kHue = 206;

/// The scans among the nine, drawn as the ultrasound fan; the rest are tests
/// read off a report, drawn as the page.
const Set<String> _kScanIds = {
  'dating_scan',
  'nt_scan',
  'anomaly_scan',
  'growth_scan',
  'doppler',
};

IntentMark _markForTest(TestScanInfo t) =>
    _kScanIds.contains(t.id) ? IntentMark.scanFan : IntentMark.reportPage;

// ===========================================================================
//  Home (library)
// ===========================================================================

class TestsScansReportsScreen extends StatefulWidget {
  const TestsScansReportsScreen({
    super.key,
    required this.controller,
    this.openParameters = false,
    this.testsOnly = false,
    this.title,
    this.intro,
  });

  final PregnancyController controller;

  /// Open a chosen scan with its parameter table already expanded.
  ///
  /// ⚠️ THIS IS THE "Your report, line by line" RESLOT, AND IT IS WHY THE TOOL
  /// STAYED SINGLE-SOURCE. The Scans door's My-reports tab needs that parameter
  /// table, and reaching it needs a scan to be chosen first — which this screen
  /// already asks, with filters, in the app's own language.
  ///
  /// The alternative was a second picker built inside the door. It would have
  /// been a second list of the same nine scans, drifting the day one is added,
  /// to answer a question this screen answers already.
  ///
  /// ⚠️ DEFAULT FALSE, SO EVERY EXISTING CALLER IS UNCHANGED. `tests_scans`
  /// still opens the library exactly as it did.
  final bool openParameters;

  /// Hide the Findings & Conditions half.
  ///
  /// ⚠️ ONLY WHERE THE QUESTION IS "which report are you holding". A finding is
  /// not a report and cannot be one — offering "Breech Position" in answer to
  /// that question sends her to a page about a diagnosis when she is holding a
  /// piece of paper. Everywhere else both halves stay, because the library IS
  /// both halves.
  final bool testsOnly;

  /// Override the app-bar title and the line under it.
  ///
  /// ⚠️ NULL EVERYWHERE BUT THE RESLOT. A screen reached as "Your report, line
  /// by line" that heads itself "Tests, Scans & Reports" reads as having landed
  /// somewhere else — the single most disorienting thing a navigation can do,
  /// and the exact mismatch `TtcFocusPage` deleted its own title field over.
  final String? title;
  final String? intro;

  @override
  State<TestsScansReportsScreen> createState() =>
      _TestsScansReportsScreenState();
}

class _TestsScansReportsScreenState extends State<TestsScansReportsScreen> {
  int _section = 0; // 0 Tests & Scans · 1 Findings & Conditions
  TrimesterTag? _filter; // null = All

  PregnancyController get p => widget.controller;

  @override
  Widget build(BuildContext context) {
    final s = S(p.language);
    final pal = pvStorePalette;
    return Scaffold(
      backgroundColor: pal.ground,
      // The back arrow only; the title is the page's own, in the serif, below
      // (the TTC tool's shape). Kept for revert: the title in the app bar,
      //   title: Text(widget.title ?? s.tsrTitle, style: pvJakarta(
      //       fontWeight: FontWeight.w700, color: AppTheme.neutral900)),
      appBar: _pregToolAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          // The natural home for "what has your doctor said". Asks once, ever.
          // ⚠️ OFF, KEPT FOR REVERT — the review said "at all".
          //
          // Full quote: "In Symptoms it was showing 'Has your doctor mentioned
          // any of the following' — when I selected no, it stopped showing. We
          // don't want this 'Has your doctor mentioned any of the following'
          // section at all."
          //
          // ⚠️ IT WAS FIRST READ AS "REMOVE IT FROM SYMPTOMS", AND THAT READING
          // WOULD HAVE CHANGED NOTHING SHE EXPERIENCES. `ProfileAskStrip` is
          // ONE-SHOT APP-WIDE: once she answers or dismisses it anywhere, it
          // never appears again. So a mother who opened the weight tracker
          // before Symptoms would still meet the question, and the only effect
          // of a partial removal is which screen she happens to meet it on.
          //
          // ⚠️ THE GENERAL LESSON: **a one-shot prompt has no per-screen
          // meaning.** Reasoning about it screen by screen — "it is relevant
          // here, less so there" — quietly assumes she sees it on each, and
          // she does not. Deciding where a global thing belongs is deciding
          // whether it exists.
          //
          // pregHealthStrip(p.language, 'tests_scans_reports'),
          Semantics(
            header: true,
            child: Text(widget.title ?? s.tsrTitle, style: pregPageTitleStyle()),
          ),
          const SizedBox(height: 8),
          Text(
            widget.intro ??
                'The tests, scans and findings you may meet in pregnancy: what '
                    'each one means, and how to read your report.',
            style: pvManrope(fontSize: 14, height: 1.45, color: pal.ink2),
          ),
          const SizedBox(height: 20),
          // ⚠️ THE TOGGLE GOES WHEN THERE IS NOTHING TO TOGGLE TO. A two-tab
          // control with one live tab is a control that lies about having a
          // choice behind it.
          if (!widget.testsOnly) ...[
            _sectionToggle(),
            const SizedBox(height: 14),
          ],
          _filterChips(),
          const SizedBox(height: 16),
          // One white card of rows (the TTC library's list). Kept for revert:
          // each entry was its own shadowed `_LibraryCard`, 10 apart.
          PregRowCard(
            empty: S.now.uiNothingFilterYet,
            children: widget.testsOnly || _section == 0
                ? _testsList()
                : _findingsList(),
          ),
        ],
      ),
    );
  }

  // --- Section toggle --------------------------------------------------------
  // The chosen half is the one ink with white words, on a white track with the
  // hairline. Kept for revert: the teal fill on a shadowed white track.
  Widget _sectionToggle() {
    final pal = pvStorePalette;
    final tabs = ['Tests & Scans', 'Findings & Conditions'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPvLine),
      ),
      child: Row(children: [
        for (int i = 0; i < tabs.length; i++)
          Expanded(
            child: Semantics(
              button: true,
              selected: _section == i,
              child: GestureDetector(
                onTap: () => setState(() => _section = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _section == i ? kPvInk : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(tabs[i],
                      textAlign: TextAlign.center,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _section == i ? Colors.white : pal.ink2)),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  // --- Filter chips ----------------------------------------------------------
  // The store's hairline chip, ink when chosen. Kept for revert: a hand-drawn
  // pill with the teal fill.
  Widget _filterChips() {
    final options = <(String, TrimesterTag?)>[
      ('All', null),
      ('Trimester 1', TrimesterTag.t1),
      ('Trimester 2', TrimesterTag.t2),
      ('Trimester 3', TrimesterTag.t3),
      ('Any Time', TrimesterTag.anytime),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, tag) = options[i];
          return PvChip(
            label: label,
            selected: _filter == tag,
            onTap: () => setState(() => _filter = tag),
          );
        },
      ),
    );
  }

  // --- Lists -----------------------------------------------------------------
  // Empty lists return nothing: the card says `uiNothingFilterYet` itself (a
  // feature is never hidden). Kept for revert: `if (items.isEmpty) return
  // [_empty()];` with `_empty()` a centred grey line.
  List<Widget> _testsList() {
    final items = testsScansByTag(_filter);
    return [
      for (final t in items)
        _LibraryRow(
          mark: _markForTest(t),
          title: t.name.now,
          subtitle: t.altName?.now,
          badge: t.tag.badge.now,
          // ⚠️ THE SAME SCREEN EITHER WAY — only the section it lands on
          // changes. This is what keeps "Your report, line by line" one tool
          // shown in two places rather than two copies of one table.
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(
                  name: widget.openParameters
                      ? 'scans/parameters'
                      : 'scans/library/detail'),
              builder: (_) => TestScanDetailScreen(
                  info: t,
                  controller: p,
                  openParameters: widget.openParameters))),
        ),
    ];
  }

  List<Widget> _findingsList() {
    final items = findingsByTag(_filter);
    return [
      for (final f in items)
        _LibraryRow(
          mark: IntentMark.bodyMark,
          title: f.name.now,
          subtitle: f.altName?.now,
          badge: f.tag.badge.now,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  FindingDetailScreen(info: f, controller: p))),
        ),
    ];
  }
}

/// The app bar of a pushed pregnancy tool page: the page's ground, the back
/// arrow in ink, no title (the page draws its own, in the serif).
PreferredSizeWidget _pregToolAppBar() {
  final pal = pvStorePalette;
  return AppBar(
    backgroundColor: pal.ground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    foregroundColor: pal.ink1,
  );
}

/// A small tag: the trimester a test or finding belongs to. A tint is allowed
/// here, and only here: it is a tag, not a block behind text.
class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final pal = pvStorePalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: pal.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: pvManrope(
              fontSize: 11, fontWeight: FontWeight.w800, color: pal.ink2)),
    );
  }
}

/// One entry in the library: a drawn mark in the Track hue, the name, its
/// other name, the trimester tag, a chevron. Laid out on `PregOfferRow`'s
/// grid (14 + 44 + 14) so `PregRowCard`'s hairlines start past the mark.
///
/// Kept for revert (2026-09-30): `_LibraryCard`, a shadowed white card per
/// entry with a teal-tinted line icon (`Icons.biotech_rounded` /
/// `Icons.description_outlined`) and a teal `_Badge` pill.
class _LibraryRow extends StatelessWidget {
  const _LibraryRow({
    required this.mark,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });
  final IntentMark mark;
  final String title;
  final String? subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = pvStorePalette;
    final sub = subtitle?.trim() ?? '';
    return Semantics(
      button: true,
      container: true,
      label: [title, if (sub.isNotEmpty) sub, badge].join('. '),
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(children: [
            PvMarkWell(p: pal, hue: _kHue, size: 44, mark: mark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: pvManrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: pal.ink1)),
                    if (sub.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(sub,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 12.5, height: 1.35, color: pal.ink3)),
                      ),
                    const SizedBox(height: 6),
                    _Tag(badge),
                  ]),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 20, color: pal.ink3),
          ]),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Test / Scan detail
// ===========================================================================

class TestScanDetailScreen extends StatelessWidget {
  const TestScanDetailScreen(
      {super.key,
      required this.info,
      required this.controller,
      this.openParameters = false});
  final TestScanInfo info;
  final PregnancyController controller;

  /// ⚠️ WHICH ARRIVAL THIS IS.
  ///
  /// False (the default, from the Tools tab, before a scan): the five
  /// preparation sections are what she wants, so "What is it" is open.
  /// True (from "Every reading on the report, explained", after a scan): the
  /// parameter table is open and the rest are collapsed.
  ///
  /// One screen, two arrivals, and the arrival decides what is already open.
  final bool openParameters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pvStorePalette.ground,
      // ⚠️ THE NAME IS SAID ONCE (2026-09-30). The app bar used to carry it
      // and the header card below said it again, a centimetre apart. The app
      // bar is the back arrow only now, and the page title is the one name,
      // on both arrivals. Kept for revert:
      //   title: Text(info.name.now, style: pvJakarta(
      //       fontWeight: FontWeight.w700, color: AppTheme.neutral900)),
      appBar: _pregToolAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          _DetailTitle(
            title: info.name.now,
            // The other name and the tag were the header card's; on the
            // parameters arrival that card did not render, so neither do they.
            subtitle: openParameters ? null : info.altName?.now,
            badge: openParameters ? null : info.tag.badge.now,
          ),
          const SizedBox(height: 18),
          // ⚠️ WHEN SHE ARRIVES HERE TO READ A REPORT, THE PAGE STARTS AT THE
          // PARAMETERS AND NOTHING SITS ABOVE THEM.
          //
          // Review, second pass: "this section should only start from
          // understanding your report parameters. Everything written above it
          // should be removed."
          //
          // The first pass read that as *collapse* the five preparation
          // sections, which was too timid and the review came back. Collapsed
          // is not removed: she still arrives to a screen whose first five
          // rows are about a day that has already happened, and has to scroll
          // past all of them — and past a header restating a scan name the app
          // bar is already showing — to reach the paper in her hand. So on
          // this arrival they do not render at all.
          //
          // ⚠️ THEY ARE NOT DELETED, AND THAT IS THE POINT OF THE FLAG. Someone
          // arriving from the Tools tab BEFORE a scan wants exactly those five
          // — what it is, why, when, how to prepare, what happens — so the
          // default arrival is untouched. One screen, two arrivals, and the
          // arrival decides what exists rather than merely what is open.
          if (!openParameters) ...[
            // Kept for revert (2026-09-30): the gradient header card, now
            // `_DetailTitle` above.
            //   _DetailHeader(icon: Icons.biotech_rounded, title: info.name.now,
            //       subtitle: info.altName?.now, badge: info.tag.badge.now),
            //   const SizedBox(height: 16),
            _ExpandableSection(
                title: S.now.uiWhat,
                body: info.whatItIs.now,
                initiallyOpen: true),
            _ExpandableSection(title: S.now.uiWhySDone, body: info.why.now),
            _ExpandableSection(title: S.now.uiWhen, body: info.when.now),
            _ExpandableSection(
                title: S.now.uiPreparation, body: info.preparation.now),
            _ExpandableSection(
                title: S.now.uiProcedure, body: info.procedure.now),
          ],
          // Renamed per the review, from 'Understanding Your Report'. It never
          // explained the report — it explained each PARAMETER on it, one at a
          // time, which is a different and narrower thing. The title now says
          // which of the two it is, and the section below is the one that does
          // the other job.
          _ExpandableSection(
            title: S.now.uiUnderstandingReportParameters,
            body: info.understandingReport.now,
            initiallyOpen: openParameters,
            children: [
              for (final param in info.parameters) _ParameterCard(param),
            ],
          ),
          // THE CLOSING READ, asked for by the review: a parent finishes the
          // parameter list knowing what nine numbers mean and still not knowing
          // what the report SAYS. This is the cumulative summary — normal
          // means this, abnormal can point at that, here is what throws it off,
          // and your doctor is who interprets it.
          if (info.interpretation.en.isNotEmpty)
            _ExpandableSection(
              title: S.now.uiHowDoIInterpret,
              body: info.interpretation.now,
              children: [
                for (final pointer in info.interpretPointers)
                  _InterpretPointer(pointer.now),
              ],
            ),
          const SizedBox(height: 8),
          MedicalDisclaimerCard(text: info.disclaimer.now),
        ],
      ),
    );
  }
}

/// One pointer under "How do I interpret the test results?".
///
/// A plain bullet on purpose. The parameter cards above are dense by
/// necessity; this section is the one a worried parent reads first, and it
/// should be skimmable in ten seconds.
class _InterpretPointer extends StatelessWidget {
  const _InterpretPointer(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final pal = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 7),
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: pal.ink3, shape: BoxShape.circle),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(text,
              style: pvManrope(fontSize: 13.5, height: 1.55, color: pal.ink2)),
        ),
      ]),
    );
  }
}

/// One report parameter, fully explained (measures / why / range / low / high).
///
/// Inside its section's white card it is a block under a hairline, not a card
/// in a card. Kept for revert (2026-09-30): a bordered white box per
/// parameter, 10 apart, the name in teal.
class _ParameterCard extends StatelessWidget {
  const _ParameterCard(this.param);
  final ReportParameter param;

  @override
  Widget build(BuildContext context) {
    final pal = pvStorePalette;
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kPvLine)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(param.name.now,
            style: pvManrope(
                fontSize: 14.5, fontWeight: FontWeight.w800, color: pal.ink1)),
        const SizedBox(height: 8),
        _kv('What it measures', param.measures.now),
        _kv('Why it\'s important', param.whyImportant.now),
        if (param.typicalRange != null)
          _kv('Typical pregnancy range', param.typicalRange!.now),
        if (param.ifLow != null) _kv('If it\'s low', param.ifLow!.now),
        if (param.ifHigh != null) _kv('If it\'s high', param.ifHigh!.now),
        if (param.note != null) _kv('Good to know', param.note!.now),
      ]),
    );
  }

  Widget _kv(String k, String v) {
    final pal = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k,
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: pal.ink3)),
        const SizedBox(height: 2),
        Text(v, style: pvManrope(fontSize: 13.5, height: 1.5, color: pal.ink1)),
      ]),
    );
  }
}

// ===========================================================================
//  Finding / Condition detail
// ===========================================================================

class FindingDetailScreen extends StatelessWidget {
  const FindingDetailScreen(
      {super.key, required this.info, required this.controller});
  final FindingInfo info;
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pvStorePalette.ground,
      // The name is said once, on the page. Kept for revert:
      //   title: Text(info.name.now, style: pvJakarta(
      //       fontWeight: FontWeight.w700, color: AppTheme.neutral900)),
      appBar: _pregToolAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          // Kept for revert (2026-09-30): the gradient header card,
          //   _DetailHeader(icon: Icons.description_outlined, title:
          //       info.name.now, subtitle: info.altName?.now,
          //       badge: info.tag.badge.now),
          _DetailTitle(
              title: info.name.now,
              subtitle: info.altName?.now,
              badge: info.tag.badge.now),
          const SizedBox(height: 18),
          _ExpandableSection(
              title: S.now.uiWhat2,
              body: info.whatIsIt.now,
              initiallyOpen: true),
          _ExpandableSection(
              title: S.now.uiWhyDoesHappen, body: info.whyHappens.now),
          _ExpandableSection(
              title: S.now.uiSymptoms,
              bullets: [for (final b in info.symptoms) b.now]),
          _ExpandableSection(title: S.now.uiDiagnosis, body: info.diagnosis.now),
          _ExpandableSection(
              title: S.now.uiPregnancyImplications, body: info.implications.now),
          _ExpandableSection(title: S.now.uiManagement, body: info.management.now),
          _ExpandableSection(
              title: S.now.uiWhenContactDoctor,
              bullets: [for (final b in info.whenToContact) b.now],
              highlight: true),
          if (info.faqs.isNotEmpty)
            _ExpandableSection(
              title: S.now.uiFaq,
              children: [for (final f in info.faqs) _FaqCard(f)],
            ),
          const SizedBox(height: 8),
          MedicalDisclaimerCard(text: info.disclaimer.now),
        ],
      ),
    );
  }
}

/// One question and its answer, a block under a hairline inside the FAQ card.
/// Kept for revert (2026-09-30): a bordered white box per question.
class _FaqCard extends StatelessWidget {
  const _FaqCard(this.faq);
  final Faq faq;
  @override
  Widget build(BuildContext context) {
    final pal = pvStorePalette;
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kPvLine)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(faq.q.now,
            style: pvManrope(
                fontSize: 13.5, fontWeight: FontWeight.w800, color: pal.ink1)),
        const SizedBox(height: 5),
        Text(faq.a.now,
            style: pvManrope(fontSize: 13.5, height: 1.5, color: pal.ink2)),
      ]),
    );
  }
}

// ===========================================================================
//  Shared building blocks
// ===========================================================================

/// The detail page's title: the name in the serif, the other name under it,
/// and the trimester tag. Replaces `_DetailHeader`'s gradient card (a tint
/// behind text) and the app-bar title it repeated.
class _DetailTitle extends StatelessWidget {
  const _DetailTitle({required this.title, this.subtitle, this.badge});
  final String title;
  final String? subtitle;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final pal = pvStorePalette;
    final sub = subtitle?.trim() ?? '';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Semantics(header: true, child: Text(title, style: pregPageTitleStyle())),
      if (sub.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(sub, style: pvManrope(fontSize: 14, height: 1.4, color: pal.ink2)),
      ],
      if (badge != null) ...[
        const SizedBox(height: 10),
        _Tag(badge!),
      ],
    ]);
  }
}

// Kept for revert (2026-09-30): `_DetailHeader`, a card with a teal-to-white
// gradient, a 48-pt teal icon well, the name in Jakarta 18 / w800, the other
// name and a teal `_Badge`. Now `_DetailTitle` on the page.

/// A collapsible section block. Supports a body paragraph, a bullet list, and/or
/// arbitrary child widgets (used for parameter cards and FAQ cards).
///
/// A white card with the page hairline (`PregCard`'s surface). The "when to
/// contact" section keeps its bell, and nothing else: it used to sit on an
/// amber block with amber words, a tint behind text.
class _ExpandableSection extends StatefulWidget {
  const _ExpandableSection({
    required this.title,
    this.body,
    this.bullets,
    this.children,
    this.initiallyOpen = false,
    this.highlight = false,
  });
  final String title;
  final String? body;
  final List<String>? bullets;
  final List<Widget>? children;
  final bool initiallyOpen;
  final bool highlight; // the bell (e.g. "when to contact")

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final pal = pvStorePalette;
    // Kept for revert (2026-09-30): the amber block for `highlight`,
    //   color: widget.highlight ? const Color(0xFFFFF6E9) : AppTheme.surface,
    //   border: widget.highlight ? const Color(0x33D9822B) : outlineVariant,
    // with the title and chevron in amber (0xFFB36B12) or teal.
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPvLine),
      ),
      child: Column(children: [
        Semantics(
          button: true,
          expanded: _open,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
              child: Row(children: [
                if (widget.highlight) ...[
                  Icon(Icons.notifications_active_outlined,
                      size: 18, color: pal.ink1),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(widget.title,
                      style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: pal.ink1)),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: pal.ink2),
                ),
              ]),
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.body != null && widget.body!.trim().isNotEmpty)
                    Text(widget.body!,
                        style: pvManrope(
                            fontSize: 13.5, height: 1.55, color: pal.ink1)),
                  if (widget.bullets != null)
                    for (final b in widget.bullets!)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6, right: 8),
                                child: Icon(Icons.circle, size: 5, color: pal.ink3),
                              ),
                              Expanded(
                                child: Text(b,
                                    style: pvManrope(
                                        fontSize: 13.5,
                                        height: 1.5,
                                        color: pal.ink1)),
                              ),
                            ]),
                      ),
                  if (widget.children != null) ...widget.children!,
                ]),
          ),
      ]),
    );
  }
}

/// Reusable medical disclaimer - shown on EVERY detail page.
///
/// A quiet note on the page (`PregNote`'s shape, with its title kept): a line
/// icon, the title in ink, the words in grey. Kept for revert (2026-09-30): an
/// amber block (0xFFFFF6E9, border 0x33D9822B) with the title and icon in
/// amber, text on a tint.
class MedicalDisclaimerCard extends StatelessWidget {
  // `text` defaults to null rather than to a resolved string: a const
  // default cannot read the current language, and resolving it once at
  // construction would freeze the disclaimer in whatever language was
  // live when the widget was built.
  const MedicalDisclaimerCard({super.key, this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    final pal = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.health_and_safety_outlined, size: 18, color: pal.ink3),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.now.uiMedicalDisclaimer,
                    style: pvManrope(
                        fontSize: 13, fontWeight: FontWeight.w700, color: pal.ink1)),
                const SizedBox(height: 3),
                Text(text ?? kMedicalDisclaimer.now,
                    style: pvManrope(fontSize: 12.5, height: 1.5, color: pal.ink2)),
              ]),
        ),
      ]),
    );
  }
}

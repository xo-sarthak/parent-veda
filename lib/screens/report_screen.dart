// =============================================================================
//  Understanding Your Report™  - Tools tab feature
// -----------------------------------------------------------------------------
//  A calm, searchable library that helps a worried mother understand a scan or
//  test finding. Reassurance-first: every article answers "What does this mean?"
//  before anything else, follows the same 7 sections, and ends with a fixed
//  reassurance message + an Ask Veda handoff. No verdicts, no diagnosis, no
//  predictions - just clear, balanced explanations.
//
//  Content: lib/data/report_findings_data.dart (curated seed).
// =============================================================================

import 'package:flutter/material.dart';

import '../data/report_findings_data.dart';
import '../localization/app_language.dart';
import '../models/report_finding.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/pv_feedback.dart';
import '../widgets/pv_placeholders.dart';
import 'brackets/hub/hub_solution_cards.dart' show SolutionMeta, SolutionType;
import 'doors/pv_door_chrome.dart' show PvDoorRow, PvDoorToolScaffold, pvDoorPad;
import 'tools/ask_veda_screen.dart';
import 'v2/v2_palette.dart';
import '../data/reads/read_adapters.dart';
import '../data/reads/read_images.dart';
import '../models/pv_read.dart';
import 'reader/pv_reader_screen.dart';

const Color _calm = Color(0xFF18A39B); // teal - calm, non-alarming accent
const Color _reassure = Color(0xFF3FA56A); // soft green - "things to remember"

void _openArticle(BuildContext context, ReportFinding f, PregnancyController c) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ReportArticleScreen(finding: f, controller: c),
  ));
}

// ===========================================================================
//  Home
// ===========================================================================

/// ⚠️ THE FILTERABLE REPORTS, AND WHY THIS LIST IS SHORT.
///
/// Nine reports, not nineteen. `tests_scans_reports_data.dart` holds both the
/// tests a mother HAS (dating scan, NT, NIPT, anomaly, OGTT, growth, Doppler,
/// GBS, bloods) and the conditions those tests FIND (`low_lying_placenta`,
/// `gdm`, `iugr`…). Only the first group belongs here: the filter answers "which
/// report am I holding", and a condition is not a report. Offering `gdm` as a
/// filter alongside `ogtt` would ask her to filter by the answer in order to
/// find the answer.
const List<(String, String, String)> _kReportFilters = [
  ('anomaly_scan', 'Anomaly scan', 'Anomaly scan'),
  ('growth_scan', 'Growth scan', 'Growth scan'),
  ('dating_scan', 'Dating scan', 'Dating scan'),
  ('nt_scan', 'NT scan', 'NT scan'),
  ('nipt', 'NIPT', 'NIPT'),
  ('ogtt', 'Sugar test (OGTT)', 'शुगर टेस्ट (OGTT)'),
  ('blood_tests', 'Blood tests', 'Blood tests'),
  ('doppler', 'Doppler', 'Doppler'),
  ('gbs', 'GBS swab', 'GBS swab'),
];

/// Whether [id] is one of the nine reports this screen can filter by.
///
/// ⚠️ EXPORTED SO CALL SITES CAN ASK BEFORE THEY PROMISE. A caller that hands
/// over an id this screen does not know would silently get the unfiltered
/// library — the failure would look exactly like the bug the filter exists to
/// fix, and nothing would report it.
bool canFilterReport(String id) =>
    _kReportFilters.any((f) => f.$1 == id);

class ReportScreen extends StatefulWidget {
  const ReportScreen(
      {super.key,
      required this.controller,
      this.initialReport,
      this.embedded = false});

  final PregnancyController controller;

  /// Rendered inside another page rather than as a screen of its own.
  ///
  /// ⚠️ A FLAG ON THE EXISTING SCREEN RATHER THAN A SECOND WIDGET, and this is
  /// the one place in this build where that was the right call. The timeline
  /// and the locker split cleanly into a body, because their content is a list
  /// of children. This screen's content is inseparable from its state — the
  /// picked filters, the search delegate, the intersection — so a body widget
  /// would either duplicate that state or become a second stateful class
  /// wrapping the first.
  ///
  /// What the flag actually changes is small and is only chrome: no `Scaffold`,
  /// no app bar, no page padding, and the intro line drops because the door's
  /// hero has already said what this is. Every filter, every topic and every
  /// tap is identical, which is what keeps this a rendering flag rather than a
  /// second mode.
  final bool embedded;

  /// ⚠️ THE REPORT SHE ARRIVED FROM, PRE-SELECTED.
  ///
  /// Review: "when we click on a word on your report you do not recognise, it
  /// should land with the pre-applied filter on whatever scan we are coming
  /// from."
  ///
  /// This is the same rule `ConsultationsScreen.onlyRole` already holds one
  /// screen over, and it is worth stating as a rule rather than as two
  /// features: **where the app already knows the answer to a filter's
  /// question, it must not ask.** She tapped that card from inside the dating
  /// scan; "which report are you holding?" is a question we watched her answer
  /// thirty seconds ago, and asking it again reads as the app not remembering
  /// what it just did.
  ///
  /// ⚠️ AND IT IS A FILTER, NOT A MODE. Every other report stays one tap away
  /// and "All" is still there — the pre-selection saves her a tap, it never
  /// takes a choice off the screen. That is the same personalisation line the
  /// rest of the app holds: order and emphasis may change, structure may not.
  ///
  /// An id this screen cannot filter by (a condition rather than a report, or
  /// a scan with no topics tagged to it) is ignored and she sees everything —
  /// see `initState`.
  final String? initialReport;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  /// Whether the folded "More topics" list is open (unfiltered only).
  bool _moreOpen = false;

  PregnancyController get controller => widget.controller;

  /// ⚠️ A SET, BECAUSE THE REQUIREMENT SAYS "MULTIPLE FILTERS".
  ///
  /// Selected reports, and empty means everything — not "nothing". That default
  /// is the whole reason this can be additive rather than a mandatory first
  /// choice: a mother who has not been asked anything sees the full library, so
  /// the filter helps whoever wants it and blocks nobody. The repo rule it
  /// follows is `a feature is never hidden` — filtering narrows what is shown,
  /// it never gates the screen behind a selection.
  final Set<String> _picked = {};

  @override
  void initState() {
    super.initState();
    // ⚠️ SEEDED, THEN OWNED BY HER. This runs once; every tap afterwards is
    // hers, including clearing it. `initialReport` is where she started, not a
    // state the screen keeps forcing her back into — which is why it is read
    // here rather than in `build`.
    final id = widget.initialReport;
    if (id != null && canFilterReport(id)) _picked.add(id);
  }

  /// ⚠️ INTERSECTION, NOT EQUALITY — and OR across the picked reports.
  ///
  /// A topic shows if it is tagged to ANY selected report. Two readings were
  /// possible and the other one is wrong: AND (topics tagged to *all* selected
  /// reports) would mean picking two reports shows fewer topics than picking
  /// either alone, and usually zero — so the second tap would look broken. She
  /// is asking "what can appear on any of these", not "what appears on all".
  List<ReportFinding> _apply(List<ReportFinding> src) {
    if (_picked.isEmpty) return src;
    return src
        .where((f) => f.tests.any(_picked.contains))
        .toList(growable: false);
  }

  Future<void> _search(BuildContext context, AppLanguage lang) async {
    final picked = await showSearch<ReportFinding?>(
      context: context,
      delegate: _ReportSearchDelegate(lang),
    );
    if (picked != null && context.mounted) _openArticle(context, picked, controller);
  }

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final popular = _apply(
        kReportPopular.map(reportById).whereType<ReportFinding>().toList());

    // ⚠️ THE POPULAR SIX ARE REMOVED FROM "ALL TOPICS", AND THAT IS A FIX.
    //
    // `all` was every finding, sorted — including the six directly above it —
    // so breech, cord around neck, low-lying placenta, pregnancy diabetes,
    // preeclampsia and low fluid each appeared twice on one screen, a few
    // hundred points apart. Reported from a walk-through of the built door.
    //
    // It is worth naming why it survived review for so long: neither list is
    // wrong on its own. "Popular topics" is correct, "All topics" is literally
    // correct, and the duplication only exists in the space between two
    // headings that are each accurate. A list that means "all" and a list that
    // means "some of these" cannot both be complete AND disjoint, and the
    // reader's expectation is the second one — she reads the page top to
    // bottom and expects the second heading to continue rather than restart.
    //
    // ⚠️ ONLY WHILE UNFILTERED. With a report chip on, "Popular topics" is
    // itself filtered and may be empty or nearly so, and subtracting a
    // near-empty list from the one below it would hide topics for no reason
    // she could see. The heading also changes to "Topics on these reports" in
    // that state, which no longer promises completeness.
    final hidePopular = _picked.isEmpty;
    final all = _apply([...kReportFindings]
      ..sort((a, b) => a.name.of(lang).compareTo(b.name.of(lang))))
        .where((f) => !hidePopular || !kReportPopular.contains(f.id))
        .toList(growable: false);

    final body = <Widget>[
          if (!embedded) ...[
            Text(s.rSubtitle,
                style: text.bodyLarge
                    ?.copyWith(color: AppTheme.neutral600, height: 1.4)),
            const SizedBox(height: 18),
          ],
          // ⚠️ NOT WHEN EMBEDDED — 2026-09-18. The door carries its own
          // search bar under the hero, and it indexes these findings
          // (`pvSearchIndex`); two bars a screen apart was "a conflicting
          // search bar situation" (the user). The standalone screen keeps
          // this one.
          if (!embedded)
            _SearchBar(hint: s.rSearchHint, onTap: () => _search(context, lang)),

          // ---- THE REPORT FILTER --------------------------------------------
          const SizedBox(height: 18),
          Text(
              lang.isEnglish
                  ? 'Which report are you holding?'
                  : 'आपके हाथ में कौन सी रिपोर्ट है?',
              style: text.labelLarge
                  ?.copyWith(color: AppTheme.neutral600, height: 1.4)),
          const SizedBox(height: 10),
          // Horizontally scrolling chips rather than a wrapped block: nine of
          // them wrap to three rows on a 360dp phone, which pushes the actual
          // topics below the fold on the screen whose job is to show topics.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(children: [
              // "All" is a chip, not the absence of chips. Deselecting the last
              // filter is otherwise an action with no affordance — she can get
              // into a filtered state and has to guess her way out.
              _FilterChip(
                label: lang.isEnglish ? 'All' : 'सभी',
                selected: _picked.isEmpty,
                onTap: () => setState(_picked.clear),
              ),
              for (final (id, en, hi) in _kReportFilters) ...[
                const SizedBox(width: 8),
                _FilterChip(
                  label: lang.isEnglish ? en : hi,
                  selected: _picked.contains(id),
                  onTap: () => setState(() {
                    if (!_picked.remove(id)) _picked.add(id);
                  }),
                ),
              ],
            ]),
          ),

          // ⚠️ AN EMPTY RESULT EXPLAINS ITSELF AND OFFERS THE WAY OUT.
          //
          // Two filters can legitimately intersect to nothing — GBS swab plus
          // Dating scan share no topic — and a blank screen there reads as a
          // broken app rather than as an answer. The repo's own rule: an empty
          // section renders an invitation, and only the copy changes.
          if (_picked.isNotEmpty && popular.isEmpty && all.isEmpty) ...[
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              // White + hairline, not the lavender well (2026-09-18).
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    lang.isEnglish
                        ? 'No topics here match those reports yet.'
                        : 'इन रिपोर्टों में साथ में पढ़ा जाने वाला कोई विषय नहीं है।',
                    style: text.bodyMedium?.copyWith(height: 1.5)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(_picked.clear),
                  child: Text(
                      lang.isEnglish ? 'Show everything' : 'सब कुछ दिखाएँ',
                      style: text.labelLarge?.copyWith(
                          color: AppTheme.neutral900, // was primary600
                          fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ],

          if (popular.isNotEmpty) const SizedBox(height: 26),
          if (popular.isNotEmpty)
            Text(s.rPopularTitle,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          if (popular.isNotEmpty) const SizedBox(height: 12),
          for (final f in popular)
            _TopicRow(
              finding: f,
              lang: lang,
              onTap: () => _openArticle(context, f, controller),
            ),
          if (all.isNotEmpty) const SizedBox(height: 18),
          // ⚠️ "MORE TOPICS" FOLDS — 2026-09-19. Twenty-one rows under six
          // popular ones is a scroll that grows every time a finding is
          // added, and the section under it (the door's own tiles) sinks
          // with it (the user's review). Closed by default while
          // unfiltered: the heading carries the count and a chevron, one
          // tap opens it. With a report chip on, the whole point is the
          // list, so it is open.
          if (all.isNotEmpty && _picked.isEmpty)
            PvPress(
              child: InkWell(
                onTap: () {
                  pvCommitFeedback();
                  setState(() => _moreOpen = !_moreOpen);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                          lang.isEnglish
                              ? 'More topics  ·  ${all.length}'
                              : 'और विषय  ·  ${all.length}',
                          style: text.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    AnimatedRotation(
                      turns: _moreOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.expand_more_rounded,
                          color: AppTheme.neutral600),
                    ),
                  ]),
                ),
              ),
            )
          else if (all.isNotEmpty)
            Text(
                // The heading has to stop saying "All topics" once a filter is
                // on, or the screen contradicts itself in its own heading.
                //
                // ⚠️ AND IT SAYS "More topics" WHILE UNFILTERED, BECAUSE IT NO
                // LONGER SHOWS ALL OF THEM. Removing the popular six from this
                // list without changing the heading would leave a heading that
                // promises everything above a list missing six entries — which
                // is the same class of untruth as the duplication it replaced,
                // pointing the other way.
                _picked.isEmpty
                    ? (lang.isEnglish ? 'More topics' : 'और विषय')
                    : (lang.isEnglish
                        ? 'Topics on these reports'
                        : 'इन रिपोर्टों के विषय'),
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          if (all.isNotEmpty) const SizedBox(height: 12),
          // The fold opens like a drawer, not a jump.
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(children: [
              if (_picked.isNotEmpty || _moreOpen)
                for (final f in all)
                  _TopicRow(
                    finding: f,
                    lang: lang,
                    onTap: () => _openArticle(context, f, controller),
                  ),
            ]),
          ),
    ];

    // ⚠️ EMBEDDED RETURNS A COLUMN, NOT A LIST. A scrolling widget inside
    // another scrolling widget is either unbounded or a nested scroll nobody
    // can drive with a thumb. The door's own `ListView` does the scrolling.
    if (embedded) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: body);
    }

    // The door tool header (2026-09-19): every leaf of a door wears the
    // same hero — back circle at the gutter, eyebrow, the title in the
    // display face, one line — the one the checklist has and the user
    // asked to see everywhere. Was an AppBar titled in a different face.
    return PvDoorToolScaffold(
      hue: 206,
      eyebrow: 'Scans & tests',
      title: s.rTitle,
      intro: s.rSubtitle,
      children: [
        for (final w in body.skip(2)) pvDoorPad(w),
      ],
    );
  }

  bool get embedded => widget.embedded;
}

/// One report filter. Selected state is colour + weight, matching `PvNavBar`'s
/// rule — the chip never changes size, so the row does not re-flow under her
/// finger as she taps along it.
class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PvPress(
        child: GestureDetector(
      onTap: () {
        pvCommitFeedback();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        // Ink, not violet (2026-09-18, DESIGN-SYSTEM §4.0: selection is
        // ink). Kept for revert: AppTheme.primary600 fill and border.
        decoration: BoxDecoration(
          color: selected ? AppTheme.neutral900 : AppTheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: selected ? AppTheme.neutral900 : AppTheme.outlineVariant,
              width: 1.2),
        ),
        child: Text(label,
            style: text.labelLarge?.copyWith(
              // ⚠️ NOT `neutral400` HERE. Unselected chip text is real text and
              // has to clear AA; `neutral400` is 2.73:1 and is documented in
              // `app_theme.dart` as never carrying text.
              color: selected ? Colors.white : AppTheme.neutral600,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            )),
      ),
    ));
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.hint, required this.onTap});
  final String hint;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary900.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, color: AppTheme.neutral500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyLarge?.copyWith(color: AppTheme.neutral500)),
          ),
        ]),
      ),
    );
  }
}

/// A topic / search-result row: name + optional alt name + chevron.
/// The one-line version of a finding, for a row.
///
/// ⚠️ `whatItMeans` WITH ITS OPENING STRIPPED, NOT `altName`. The alt name is
/// the medical alias — "Placenta Previa" under "Low-Lying Placenta" — which is
/// the word on her report and belongs on the page, not on the row. The row's
/// job is "is this one mine?", and the first sentence of what-it-means answers
/// that in plain words. Every entry opens "This means …" / "इसका मतलब है कि …",
/// so the prefix is dropped and the sentence stands on its own.
String _plainLine(ReportFinding f, AppLanguage lang) {
  var t = f.whatItMeans.of(lang).trim();
  for (final p in const ['This means that ', 'This means ', 'इसका मतलब है कि ']) {
    if (t.startsWith(p)) {
      t = t.substring(p.length);
      break;
    }
  }
  final stop = RegExp(r'[.।]').firstMatch(t);
  if (stop != null) t = t.substring(0, stop.end);
  return t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
}

/// One finding, in the door's row language.
///
/// ⚠️ THIS SCREEN PREDATES V2 AND STILL DRAWS MOST OF ITSELF WITH `AppTheme`.
/// Its rows, though, render inline on the Scans door's third tab, where every
/// other row is a `PvDoorRow` — and the old teal-square row beside them read
/// as a screen from an older version of the app. Seen on a phone, 2026-09-11.
/// The row takes the live palette; the rest of this screen is left as it is,
/// because bringing a whole pre-V2 screen up to the design language is a
/// different job from making its rows match the door they sit in.
class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.finding, required this.lang, required this.onTap});
  final ReportFinding finding;
  final AppLanguage lang;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => PvDoorRow(
        p: V2PaletteStore.instance.current,
        hue: SolutionType.read.hue,
        icon: Icons.article_outlined,
        chip: 'Article',
        title: finding.name.of(lang),
        blurb: _plainLine(finding, lang),
        imageUrl: readImageFor('finding_${finding.id}'),
        onTap: onTap,
      );
}

// ===========================================================================
//  Article (the 7 sections)
// ===========================================================================

class ReportArticleScreen extends StatelessWidget {
  const ReportArticleScreen({super.key, required this.finding, required this.controller});
  final ReportFinding finding;
  final PregnancyController controller;

  void _askVeda(BuildContext context, S s) {
    // Ask Veda is live - open it pre-filled with this finding (it has the data).
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AskVedaScreen(
          controller: controller,
          initialQuery: finding.name.of(controller.language)),
    ));
  }

  // ⚠️ THE ARTICLE FORMAT, 2026-09-17 — this screen now hands its model to
  // the one reader through `read_adapters.dart` (STILL-OPEN §60.1, §60.6),
  // so every caller — door, home, Saved, search — gets the one format and
  // nothing that constructs this screen has to change. The previous body is
  // `buildClassic` below, kept for revert and opened by nothing;
  // test/reader_unification_test.dart holds that.
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    return PvReaderScreen(
      read: pvReadFromFinding(finding, steps: [
        // "Still worried? Ask Veda" — pre-filled with this finding, as before.
        PvReadNextStep(
          kind: PvNextKind.read,
          title: LocalizedText(en: s.rAskTitle, hi: s.rAskTitle),
          value: LocalizedText(en: s.rAskBody, hi: s.rAskBody),
          action: 'finding_askveda',
        ),
      ]),
      lang: controller.language,
      openAction: (context, action) {
        if (action == 'finding_askveda') _askVeda(context, s);
      },
    );
  }

  /// The previous body, kept for revert. See `build`.
  Widget buildClassic(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(finding.name.of(lang))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          if (finding.altName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(finding.altName!.of(lang),
                  style: text.titleMedium?.copyWith(color: AppTheme.neutral500)),
            ),

          // ---- THE EXPLAINER, BEFORE THE WORDS -------------------------
          //
          // ⚠️ EVERY FINDING PAGE OPENS ON A FILM. Review: "Understanding Your
          // Report — each of it when it opens should basically show a video at
          // the top."
          //
          // It is the same call already made on `ScanDetailScreen`, and for a
          // stronger reason here. This screen is reached with a printout in her
          // hand and a word on it she has just looked up — which is the moment
          // in the whole product when someone is least able to read seven
          // sections of prose and most able to watch someone explain the thing
          // once. The text below is what she reads if she would rather read.
          //
          // ⚠️ A REAL PLACEHOLDER, NOT A ROW OF TEXT — 16:9, thumbnail, play
          // control, the title set in the type it will use, and a COMING SOON
          // mark so it is honest about not existing yet. See pv_placeholders
          // for why a text stand-in makes a page impossible to judge.
          PvVideoPlaceholder(
            title: '${finding.name.en}, explained',
            subtitle: 'What this means on your report, what usually happens '
                'next, and what to ask.',
            duration: '4 MIN',
            hue: 168,
            slotId: 'report_finding_${finding.id}',
          ),
          const SizedBox(height: 22),

          // §1 - What does this mean? (always first)
          _Section(title: s.rSecMeans, body: finding.whatItMeans.of(lang)),

          // §2 - How common is it?
          _Section(title: s.rSecCommon, body: finding.howCommon.of(lang)),

          // §3 - What usually happens next? (the most important - gently emphasised)
          _EmphasisSection(title: s.rSecNext, body: finding.whatNext.of(lang)),

          // §4 - When is it usually discussed?
          if (finding.hasWhen) ...[
            const SizedBox(height: 22),
            _SectionTitle(s.rSecWhen),
            const SizedBox(height: 10),
            _WhenChip(
              label: s.rTypicallyAround,
              value: s.rWeekRange(finding.weekFrom, finding.weekTo),
            ),
          ],

          // §5 - Questions to ask your doctor
          if (finding.questions.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle(s.rSecQuestions),
            const SizedBox(height: 12),
            for (final q in finding.questions)
              _QuestionRow(text: q.of(lang)),
          ],

          // §6 - Things to remember
          if (finding.remember.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle(s.rSecRemember),
            const SizedBox(height: 12),
            for (final r in finding.remember)
              _RememberRow(text: r.of(lang)),
          ],

          // §7 - Reassurance message (mandatory, fixed)
          const SizedBox(height: 24),
          _ReassuranceCard(text: s.rReassurance),

          // Ask Veda handoff
          const SizedBox(height: 18),
          _AskVedaCard(
            title: s.rAskTitle,
            body: s.rAskBody,
            cta: s.rAskCta,
            onTap: () => _askVeda(context, s),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w800));
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionTitle(title),
        const SizedBox(height: 8),
        Text(body, style: text.bodyLarge?.copyWith(height: 1.55)),
      ]),
    );
  }
}

class _EmphasisSection extends StatelessWidget {
  const _EmphasisSection({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: _calm.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _calm.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.navigation_rounded, size: 18, color: _calm),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800, color: _calm)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(body, style: text.bodyLarge?.copyWith(height: 1.55)),
        ]),
      ),
    );
  }
}

class _WhenChip extends StatelessWidget {
  const _WhenChip({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
      ),
      child: Row(children: [
        const Icon(Icons.event_rounded, size: 18, color: AppTheme.neutral500),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
        ),
        Text(value,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primary500.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.help_outline_rounded, size: 14, color: AppTheme.primary500),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: t.bodyLarge?.copyWith(height: 1.45)),
        ),
      ]),
    );
  }
}

class _RememberRow extends StatelessWidget {
  const _RememberRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_rounded, size: 18, color: _reassure),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: t.bodyLarge?.copyWith(height: 1.45)),
        ),
      ]),
    );
  }
}

class _ReassuranceCard extends StatelessWidget {
  const _ReassuranceCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _reassure.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _reassure.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.favorite_rounded, size: 18, color: _reassure),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: t.bodyLarge?.copyWith(height: 1.5, color: AppTheme.neutral800)),
        ),
      ]),
    );
  }
}

class _AskVedaCard extends StatelessWidget {
  const _AskVedaCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary500.withValues(alpha: 0.10),
            AppTheme.secondary500.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_rounded, size: 18, color: AppTheme.primary500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(body, style: text.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.4)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary500,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
            label: Text(cta, style: text.labelLarge?.copyWith(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// ===========================================================================
//  Search
// ===========================================================================

class _ReportSearchDelegate extends SearchDelegate<ReportFinding?> {
  _ReportSearchDelegate(this.lang);
  final AppLanguage lang;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final s = S(lang);
    if (query.trim().isEmpty) return const SizedBox.shrink();
    final matches = reportSearch(query);
    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Text(s.canINoResults,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.neutral500)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _TopicRow(
        finding: matches[i],
        lang: lang,
        onTap: () => close(context, matches[i]),
      ),
    );
  }
}

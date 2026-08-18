// =============================================================================
//  ScanDetailScreen — "Understand my scan", the focused journey
// -----------------------------------------------------------------------------
//  PARENTVEDA-SCANS-TESTS-UPDATED-UX-TEMPLATE.md §9.1. Pattern B — a focused
//  journey, because this job naturally contains several connected questions.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE HEADINGS ARE HER QUESTIONS. THAT IS THE WHOLE REDESIGN.
//  ---------------------------------------------------------------------------
//
//  This screen previously had grouped sections — "Before you go", "While you
//  are here" — each holding two or three cards. That is still inventory UX in
//  friendlier clothes: the groups existed because we had things to put in them,
//  not because she asked anything.
//
//  §14 is explicit about the difference:
//
//      Good                          Bad
//      Your next scan                CONTENT   [10 articles]
//      What happens during it?       TOOLS     [4 tools]
//      Your appointment              PRODUCTS  [12 products]
//      How should I prepare?         CONSULT   [6 experts]
//
//  So every heading below is a question she is actually asking, and under each
//  is the ONE thing that answers it. Where nothing answers it, the question is
//  not asked.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT I REMOVED, AND WHY EACH WENT — §13's four questions
//  ---------------------------------------------------------------------------
//
//    · The due-date CALCULATOR card. §13 Q1: does it help the current intent?
//      She came to understand a scan. It is a good tool on a screen about
//      dates and clutter on this one, and it stays reachable everywhere else.
//
//    · The two-button row (Add to my scans / I have the report). Two competing
//      actions at the midpoint, before she had finished reading.
//
//    · The report-term chip grid. Six chips is a category menu for a question
//      she has not asked yet — she is preparing FOR a scan, not decoding a
//      report she does not have.
//
//    · The "While you are here" group. §21: if removing a card loses nothing
//      for the current job, remove it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT STAYED, AND WHY IT EARNS ITS PLACE
//  ---------------------------------------------------------------------------
//
//    · The PCPNDT line. She will ask about the baby's sex, the sonographer will
//      refuse, and if we have not warned her she reads that refusal as
//      something being hidden about her baby.
//    · The cost. Nobody in this market answers it, and it is the second thing
//      she asks after "what time".
//    · The red flags — the safety floor, and short.
//    · Consult LAST, as §17's moment of need: "still unsure?"
// =============================================================================

import 'package:flutter/material.dart';
import '../../widgets/pv_placeholders.dart';

import '../../data/read_next_data.dart';
import '../../data/content_slots.dart';
import '../../data/scan_extras.dart';
import '../../data/tests_scans_reports_data.dart';
import '../../localization/app_language.dart';
import '../../models/read_item.dart';
import '../../models/scan_appointment.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scans_store.dart';
import '../../theme/pv_fonts.dart';
import '../prepare/consultations_screen.dart';
// Kept for revert: the in-page article slot was replaced by
// PvReadPlaceholder until real reads are attached.
// import '../read_reader_screen.dart';
import '../report_screen.dart';
import '../tools/scans_appointments_screen.dart';
import '../tools/tests_scans_reports_screen.dart';
import '../v2/v2_palette.dart';
import 'hub/hub_solution_cards.dart';

class ScanDetailScreen extends StatelessWidget {
  const ScanDetailScreen(
      {super.key, required this.scan, required this.pregnancy});

  final TestScanInfo scan;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final lang = pregnancy.language;

    return AnimatedBuilder(
      animation: ScansStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        // Kept for revert — the cost line is commented out below:
        //   final cost = kScanCost[scan.id];
        final flags = kScanRedFlags[scan.id] ?? const <LocalizedText>[];
        // Kept for revert — the read row is commented out below:
        //   final read = _read();
        final appt = _appointment();

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(scan.name.of(lang),
                style: pvJakarta(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: p.ink1)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 44),
            children: [
              // ---- THE EXPLAINER, FIRST ------------------------------------
              //
              // ⚠️ THE VIDEO MOVED FROM THE MIDDLE OF THE PAGE TO THE TOP, and
              // its job changed with the position. Per review: "at the top
              // should be a video which will explain that particular scan, and
              // what happens in it and what it means and how to interpret the
              // results, so whatever is written on this page will be summarised
              // in the video."
              //
              // So it is no longer a card supporting the "what happens during
              // it" question — it is the whole page in six minutes, for someone
              // who would rather watch than read. The copy below is what she
              // reads if she wants the detail.
              //
              // ⚠️ AND IT IS A REAL PLACEHOLDER, not a row of text. 16:9,
              // thumbnail, play control, the title set in the type it will use —
              // so the page can be judged now and only the file is missing.
              // See pv_placeholders.dart for why that matters.
              PvVideoPlaceholder(
                title: '${scan.name.en}, explained',
                subtitle: 'What it checks, what happens on the day, and how to '
                    'read the report.',
                duration: '6 MIN',
                hue: 206,
                slotId: 'scan_explainer_${scan.id}',
              ),
              const SizedBox(height: 26),

              // ---- STEP 2 · the immediate questions -------------------------
              _Q(const LocalizedText(
                  en: 'What is this scan?', hi: 'यह scan क्या है?'), p, lang),
              _A(scan.whatItIs.of(lang), p),
              const SizedBox(height: 26),

              _Q(
                  const LocalizedText(
                      en: 'What is it checking?',
                      hi: 'यह किस चीज़ की जाँच करता है?'),
                  p,
                  lang),
              _A(scan.why.of(lang), p),
              const SizedBox(height: 26),

              _Q(
                  const LocalizedText(
                      en: 'What happens during it?', hi: 'इसमें होता क्या है?'),
                  p,
                  lang),
              _A(scan.procedure.of(lang), p),

              // §7.2 — the shell ships whether or not the film has. ONE card
              // per format, under the question it answers, never in a "videos"
              // rail.
              //
              // ⚠️ THESE COME FROM THE SLOT TABLE NOW, NOT FROM A TITLE MATCH.
              // The old `_video()` looked for a `kVideos` entry whose TITLE
              // happened to contain the scan's name — which is the missing-tag
              // problem the reconciliation names, wearing a disguise: it can
              // only ever find content that was named to be found, it silently
              // returns nothing when a title is reworded, and it cannot promise
              // a video that does not exist yet. `content_slots.dart` states
              // the tag outright, so filling one is a URL and a thumbnail.
              // ⚠️ VIDEO SLOTS ARE FILTERED OUT HERE — the explainer is at the
              // top of the page now, and the same film offered twice on one
              // screen reads as a bug rather than as generosity.
              for (final slot
                  in _slots().where((x) => x.format != ContentFormat.video)) ...[
                const SizedBox(height: 12),
                SolutionCard(
                  type: SolutionType.read,
                  title: slot.title,
                  value: slot.value,
                  meta: slot.duration == null
                      ? null
                      : LocalizedText(en: slot.duration!, hi: slot.duration!),
                  p: p,
                  lang: lang,
                  comingSoon: !slot.isFilled,
                ),
              ],
              const SizedBox(height: 26),

              // ---- STEP 3 · preparation -------------------------------------
              _Q(
                  const LocalizedText(
                      en: 'How should I prepare?', hi: 'तैयारी कैसे करूँ?'),
                  p,
                  lang),
              _A(scan.preparation.of(lang), p),
              // ⚠️ BOTH FACT BLOCKS ARE OFF HERE, KEPT FOR REVERT.
              //
              // The cost went per review — prices are coming off these screens
              // for now. `kScanCost` is untouched and still ships, so restoring
              // it is uncommenting.
              //
              // ⚠️ THE PCPNDT LINE IS THE ONE I WOULD RAISE. Review said
              // "remove what they cannot tell you". It is off as asked, and the
              // reason it existed is worth keeping on the record: she WILL ask
              // about the baby's sex, the sonographer will refuse by law, and if
              // nobody warned her she reads that refusal as something being
              // hidden about her baby. The line is not decoration; it is the
              // thing that stops a legal refusal feeling like concealment. Ask
              // me and I will put it back somewhere less prominent rather than
              // nowhere.
              //
              // if (cost != null) ...[
              //   const SizedBox(height: 12),
              //   _Fact(
              //       label: const LocalizedText(
              //           en: 'What it usually costs', hi: 'आम तौर पर ख़र्च'),
              //       value: '₹${cost.low} – ₹${cost.high}',
              //       p: p, lang: lang),
              // ],
              // _Fact(
              //     label: const LocalizedText(
              //         en: 'What they cannot tell you',
              //         hi: 'वे क्या नहीं बता सकते'),
              //     value: kPcpndtLine.of(lang), p: p, lang: lang),
              const SizedBox(height: 26),

              // ---- Her actual appointment, only when there is one -----------
              //
              // ⚠️ CONTEXTUAL, NOT ALWAYS-ON. §9.1 lists "Your appointment" as
              // a step; §13 Q4 asks whether showing it now adds value. With
              // nothing booked it is an empty card about a thing that does not
              // exist, so it does not render at all.
              if (appt != null) ...[
                _Q(
                    const LocalizedText(
                        en: 'Your appointment', hi: 'आपका appointment'),
                    p,
                    lang),
                SolutionCard(
                  type: SolutionType.tool,
                  title: LocalizedText(en: appt.title, hi: appt.title),
                  value:
                      LocalizedText(en: _apptLine(appt), hi: _apptLine(appt)),
                  meta: const LocalizedText(en: 'BOOKED', hi: 'बुक'),
                  p: p,
                  lang: lang,
                  onTap: () => _push(
                      context,
                      ScansAppointmentsScreen(controller: pregnancy),
                      'appointments'),
                ),
                const SizedBox(height: 26),
              ],

              // ---- EVERY READING ON THE REPORT, EXPLAINED -------------------
              //
              // ⚠️ REPLACES "After the scan", AND IT IS DELIBERATELY THE
              // LOUDEST THING BELOW THE FOLD.
              //
              // Review: "remove the after the scan section, replace it with
              // Every reading on the report explained, and make it prominent,
              // not like the small line it sits at now."
              //
              // That is the right call and the reason is worth stating: the
              // moment a mother most needs this app is with a printout in her
              // hand that she cannot read. Everything above this block is
              // preparation for a day; this block is the day after.
              //
              // So it gets a full card with its own heading rather than a row in
              // a list, and it lands on the parameter table with the section
              // already open — see TestsScansReportsScreen.
              _Q(
                  const LocalizedText(
                      en: 'Every reading on the report, explained',
                      hi: 'रिपोर्ट की हर reading, समझाई गई'),
                  p,
                  lang),
              SolutionCard(
                type: SolutionType.tool,
                title: const LocalizedText(
                    en: 'Your report, line by line',
                    hi: 'आपकी रिपोर्ट, लाइन दर लाइन'),
                value: const LocalizedText(
                    en: 'Every parameter, what the usual range is, and what it '
                        'means when yours sits outside it.',
                    hi: 'हर parameter, आम range क्या है, और आपका उससे बाहर हो '
                        'तो उसका मतलब क्या है।'),
                p: p,
                lang: lang,
                onTap: () => _push(
                    context,
                    TestScanDetailScreen(
                        info: scan,
                        controller: pregnancy,
                        openParameters: true),
                    'scans/parameters'),
              ),
              const SizedBox(height: 10),
              SolutionCard(
                type: SolutionType.read,
                title: const LocalizedText(
                    en: 'A word on the report you do not recognise?',
                    hi: 'रिपोर्ट का कोई शब्द समझ न आए?'),
                value: const LocalizedText(
                    en: 'Look it up, see what it may mean, and what to ask.',
                    hi: 'ढूँढिए, मतलब समझिए, और जानिए क्या पूछना है।'),
                p: p,
                lang: lang,
                onTap: () => _push(context,
                    ReportScreen(controller: pregnancy), 'scans/decoder'),
              ),
              const SizedBox(height: 26),

              // ---- The safety floor ------------------------------------------
              if (flags.isNotEmpty) ...[
                _Q(
                    const LocalizedText(
                        en: 'Call before your next appointment if',
                        hi: 'अगली appointment से पहले फ़ोन कीजिए अगर'),
                    p,
                    lang),
                for (final f in flags) ...[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 11),
                      decoration:
                          BoxDecoration(color: p.ink3, shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(f.of(lang),
                          style: pvManrope(
                              fontSize: 14, height: 1.5, color: p.ink2)),
                    ),
                  ]),
                  const SizedBox(height: 9),
                ],
                const SizedBox(height: 18),
              ],

              // ---- §17 · consult, at the moment of need ----------------------
              //
              // "Still unsure?" IS the moment. Not a footer, and not a section
              // sitting there before she needs it — this is the question she is
              // actually asking by the time she has read everything above.
              _Q(
                  const LocalizedText(
                      en: 'Still unsure about something?',
                      hi: 'फिर भी कुछ साफ़ नहीं?'),
                  p,
                  lang),
              SolutionCard(
                type: SolutionType.consult,
                title: const LocalizedText(
                    en: 'Have a gynaecologist go through it with you',
                    hi: 'किसी gynaecologist से साथ में देखिए'),
                value: const LocalizedText(
                    en: 'They tell you what the scan does and does not say.',
                    hi: 'वे बताती हैं कि scan क्या कहता है और क्या नहीं।'),
                p: p,
                lang: lang,
                onTap: () =>
                    _push(context, ConsultationsScreen(lang: lang), 'consults'),
              ),
              const SizedBox(height: 26),

              // The reference page — quiet, at the very bottom. Two pages, two
              // jobs: this one is practical and read before the day; that one
              // is the parameter-by-parameter reference, read afterwards with
              // the paper in her hand.
              Material(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _push(
                      context,
                      TestScanDetailScreen(info: scan, controller: pregnancy),
                      'scans/reference'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                            const LocalizedText(
                                    en: 'Every reading on the report, explained',
                                    hi: 'रिपोर्ट की हर reading, समझाई हुई')
                                .of(lang),
                            style: pvManrope(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                color: p.ink1)),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 19, color: p.ink3),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(scan.disclaimer.of(lang),
                  style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3)),
            ],
          ),
        );
      },
    );
  }

  void _push(BuildContext context, Widget s, String name) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: name), builder: (_) => s));

  String _apptLine(Appointment a) {
    final d = DateTime.tryParse(a.dateIso);
    return [
      if (d != null) '${d.day}/${d.month}',
      if (a.time.isNotEmpty) a.time,
      if (a.location.isNotEmpty) a.location,
    ].join('  ·  ');
  }

  /// Her booked appointment for THIS scan, if there is one.
  Appointment? _appointment() {
    final keys = _keys();
    for (final a in ScansStore.instance.appointments) {
      final t = a.title.toLowerCase();
      if (keys.any((k) => t.contains(k))) return a;
    }
    return null;
  }

  /// ⚠️ ONE video and ONE read, never a rail. §8 — someone who wants to
  /// understand a scan does not need five articles and three videos on one
  /// screen. The library is one tap away at the foot for anyone who wants more.
  ///
  /// So this caps at two: the best video slot and the best article slot for
  /// THIS scan, most specific first (`slotsFor` sorts topic-specific above
  /// general, and filled above promised).
  List<ContentSlot> _slots() {
    final out = <ContentSlot>[];
    for (final format in [ContentFormat.video, ContentFormat.article]) {
      final matches = slotsFor(kScansHubBracketId, kStepUnderstandScan,
          topic: scan.id, format: format);
      if (matches.isNotEmpty) out.add(matches.first);
    }
    return out;
  }

  // Orphaned by the commented-out read row, kept on purpose. When real articles
  // are attached to scans this is the matcher that finds them again.
  // ignore: unused_element
  ReadItem? _read() {
    for (final r in kReadItems) {
      final t = r.title.en.toLowerCase();
      if (_keys().any((k) => t.contains(k))) return r;
    }
    return null;
  }

  /// Matched on the scan's own name and aliases rather than a hand-kept list —
  /// a hand list is a second copy of a fact the content already states, and
  /// second copies drift the first time something is renamed.
  List<String> _keys() => [
        scan.name.en.toLowerCase(),
        ...scan.aliases.map((a) => a.en.toLowerCase()),
      ].where((k) => k.length > 3).toList();
}

// -----------------------------------------------------------------------------

/// A user question, as a heading.
class _Q extends StatelessWidget {
  const _Q(this.text, this.p, this.lang);
  final LocalizedText text;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text.of(lang),
            style: pvFraunces(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.22,
                letterSpacing: -0.45,
                color: p.ink1)),
      );
}

/// Its answer, in prose.
class _A extends StatelessWidget {
  const _A(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Text(text,
      style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2));
}

/// A short labelled fact — the cost, the PCPNDT line.
///
/// Quieter than a card on purpose: it is something to READ, not somewhere to
/// go, and giving it a chevron would promise a screen that does not exist.
// ⚠️ ORPHANED BY A COMMENTED-OUT CALL SITE, KEPT ON PURPOSE.
// The repo rule is comment out, never delete: the revert has to bring
// back a block that still compiles, which it will not if its helper was
// tidied away in the meantime.
// ignore: unused_element
class _Fact extends StatelessWidget {
  const _Fact(
      {required this.label,
      required this.value,
      required this.p,
      required this.lang});

  final LocalizedText label;
  final String value;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.of(lang).toUpperCase(),
              style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3)),
          const SizedBox(height: 5),
          Text(value,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        ]),
      );
}

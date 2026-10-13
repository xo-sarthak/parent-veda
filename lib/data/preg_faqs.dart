// =============================================================================
//  Pregnancy FAQs — the user's Ask Veda FAQ Library, the source of truth
// -----------------------------------------------------------------------------
//  2026-10-13. 365 questions across Months 1–8, from the Drive folder
//  "Pregnancy FAQs", generated into `lib/data/preg_faqs/` by
//  `tools/preg_faqs/docx_to_dart.py`. Fix the doc and re-run; never hand-edit.
//
//  WHAT THEY ARE FOR (the user, 2026-10-13)
//    · ASK VEDA'S KNOWLEDGE, NOT ITS ANSWERS. Each live FAQ is exported as a
//      document (`pvask_<id>`, `lib/ask_veda/pv_veda_corpus.dart`). The AI
//      reads it as fact and writes every answer fresh for where she is: "if
//      the mother is in week 20, the answer needs to be personalized for her…
//      I don't want those templated answers that are same for everyone."
//    · A PAGE IN THE ONE READER. A "More information" card on an answer opens
//      the FAQ in `PvReaderScreen` (`openPregFaq`), as every written piece does.
//    · ASK VEDA'S SUGGESTED QUESTIONS come from her month (`pregFaqSuggestions`).
//
//  ⚠️ HELD FAQS. 39 carry "Clinical review: Yes" in the doc, most of them
//  "holds for Ishaan's sign-off" (bleeding, labour, delivery mode, reduced
//  movements, results). They are generated but never shown, suggested or sent
//  to Ask Veda until their id is added to [kPregFaqSignedOff]. One line each,
//  so the sign-off is a deliberate act and leaves a record in the diff.
//
//  English only (CLAUDE.md, 2026-08-27).
// =============================================================================

import '../localization/app_language.dart';
import '../models/pv_read.dart';
import 'preg_faqs/index.dart';

export 'preg_faqs/index.dart' show kPregFaqMonths;

/// The doc's section labels, in its own order.
enum PregFaqSection { direct, why, whyMatters, forYou, doctor, perspective, takeaways }

/// One block of an FAQ: a section, an optional sub-heading the doc wrote
/// inside it ("Can Have"), and its paragraphs and bullets.
class PregFaqPart {
  const PregFaqPart(this.section, this.heading, this.paragraphs, this.bullets);
  final PregFaqSection section;
  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;
}

class PregFaq {
  const PregFaq({
    required this.id,
    required this.number,
    required this.month,
    required this.question,
    required this.category,
    required this.applicability,
    required this.canI,
    required this.sensitivity,
    required this.parts,
    required this.related,
    this.held = false,
    this.heldNote = '',
  });

  /// The doc's own id, e.g. `PREG-GEN-001`. Stable: it names the Ask Veda
  /// document and the reader page.
  final String id;
  final int number;
  final int month;
  final String question;
  final String category;

  /// "Month 1 (weeks 1 to 4)", "All trimesters", "Month 7 onward".
  final String applicability;
  final String canI;
  final String sensitivity;
  final List<PregFaqPart> parts;

  /// Related FAQ ids, resolved from the doc's titles by the converter.
  final List<String> related;

  /// "Clinical review: Yes" in the doc. See [kPregFaqSignedOff].
  final bool held;
  final String heldNote;

  bool get isLive => !held || kPregFaqSignedOff.contains(id);

  Iterable<PregFaqPart> of(PregFaqSection s) => parts.where((p) => p.section == s);

  String text(PregFaqSection s) =>
      [for (final p in of(s)) ...p.paragraphs].join('\n\n');
}

/// One month the library has sent, with the weeks it covers.
class PregFaqMonth {
  const PregFaqMonth(this.month, this.fromWeek, this.toWeek, this.faqs);
  final int month;
  final int fromWeek;
  final int toWeek;
  final List<PregFaq> faqs;
}

/// ⚠️ THE CLINICAL SIGN-OFF. A held FAQ goes live only when its id is here.
/// Add one id per line, with the date and who signed it off.
const Set<String> kPregFaqSignedOff = {};

/// Every FAQ, live or held, in the doc's order.
final List<PregFaq> kPregFaqsAll = [for (final m in kPregFaqMonths) ...m.faqs];

/// The FAQs that may be shown, suggested or sent to Ask Veda.
final List<PregFaq> kPregFaqsLive = [for (final f in kPregFaqsAll) if (f.isLive) f];

final Map<String, PregFaq> _byId = {for (final f in kPregFaqsAll) f.id: f};

/// A live FAQ by its id, or null (unknown, or held).
PregFaq? pregFaqById(String id) {
  final f = _byId[id];
  return f != null && f.isLive ? f : null;
}

/// The month whose weeks hold [week]. Week 36 onward is in no month sent yet,
/// and reads Month 8, the last one (STILL-OPEN §88).
PregFaqMonth? pregFaqMonthForWeek(int? week) {
  if (week == null || week < 1 || kPregFaqMonths.isEmpty) return null;
  for (final m in kPregFaqMonths) {
    if (week >= m.fromWeek && week <= m.toWeek) return m;
  }
  return week > kPregFaqMonths.last.toWeek ? kPregFaqMonths.last : null;
}

/// Her month's live questions, for Ask Veda's suggestions. Empty when her
/// week is unknown, so the screen keeps its own authored list.
List<String> pregFaqSuggestions(int? week) {
  final m = pregFaqMonthForWeek(week);
  if (m == null) return const [];
  return [for (final f in m.faqs) if (f.isLive) f.question];
}

// ---- the reader ------------------------------------------------------------------

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

String _label(PregFaqSection s) => switch (s) {
      PregFaqSection.direct => '',
      PregFaqSection.why => 'Why this happens',
      PregFaqSection.whyMatters => 'Why it matters',
      PregFaqSection.forYou => 'What this means for you',
      PregFaqSection.doctor => 'When to speak to your doctor',
      PregFaqSection.perspective => 'A thought from ParentVeda',
      PregFaqSection.takeaways => 'Quick takeaways',
    };

/// The FAQ as a page in the one reader (CLAUDE.md "One reader").
///
/// The doc's order, with two moves the reader's shape asks for: the Direct
/// Answer is the boxed short answer, and the doctor section is the read's
/// required `whenToSeeSomeone`, so it renders as the calm closing well rather
/// than a paragraph. A sub-heading the doc wrote ("Can Have") becomes its own
/// section, so its bullets stay under it. No "Reviewed by": `reviewed: false`,
/// because no clinician has reviewed the library yet.
PvRead pregFaqRead(PregFaq f) {
  final sections = <PvReadSection>[];
  PregFaqSection? last;
  for (final p in f.parts) {
    if (p.section == PregFaqSection.direct || p.section == PregFaqSection.doctor) continue;
    final heading = p.heading.isNotEmpty
        ? p.heading
        : (p.section != last ? _label(p.section) : '');
    sections.add(PvReadSection(
      heading: heading.isEmpty ? null : _same(heading),
      paragraphs: [for (final t in p.paragraphs) _same(t)],
      bullets: [for (final t in p.bullets) _same(t)],
    ));
    last = p.section;
  }
  final direct = f.text(PregFaqSection.direct);
  final doctor = [
    for (final p in f.of(PregFaqSection.doctor)) ...[...p.paragraphs, ...p.bullets]
  ].join('\n\n');
  // The reader always draws a teaser; this one says which stretch of
  // pregnancy the answer was written for, so a mother at week 30 reading a
  // Month 1 question knows why it speaks of early weeks.
  final m = kPregFaqMonths.where((m) => m.month == f.month);
  final teaser = m.isEmpty
      ? 'Written for month ${f.month} of pregnancy.'
      : 'Written for month ${f.month} of pregnancy, weeks ${m.first.fromWeek} to ${m.first.toWeek}.';
  return PvRead(
    id: 'pvask_${f.id}',
    kicker: _same('Month ${f.month} · ${f.category}'),
    title: _same(f.question),
    teaser: _same(teaser),
    scaleSetter: _same(''),
    shortAnswer: direct.isEmpty ? null : _same(direct),
    author: const LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial'),
    authorRole: const LocalizedText(en: 'Questions in pregnancy', hi: 'Questions in pregnancy'),
    // The pregnancy reads' rose, so a question opened from Ask Veda sits in
    // the same family as the reads beside it.
    hue: 344,
    sections: sections,
    // The doc's own doctor section, in the closing well every hand-written
    // pregnancy read uses for its doctor line (`assertShape` asks reads for
    // the urgent tone there). The words are the doc's, calm as written.
    whenToSeeSomeone: doctor.isEmpty
        ? kPvShortPieceCallout
        : PvCallout(
            tone: PvCalloutTone.urgent,
            title: _same('When to speak to your doctor'),
            body: _same(doctor),
          ),
    faqs: const [],
    readNext: [for (final id in f.related) if (pregFaqById(id) != null) 'pvask_$id'],
    reviewed: false,
  );
}

/// The page behind a reader id (`pvask_<FAQ id>`), for a Read next rail.
PvRead? pregFaqReadById(String readId) {
  if (!readId.startsWith('pvask_')) return null;
  final f = pregFaqById(readId.substring('pvask_'.length));
  return f == null ? null : pregFaqRead(f);
}

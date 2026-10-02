// =============================================================================
//  The pregnancy corpus: what Ask Veda knows about the pregnancy side of the
//  app (2026-10-02)
// -----------------------------------------------------------------------------
//  Built here and written to JSON by `tool/export_pregnancy_corpus.dart`, then
//  imported by the service (`ingest/import_corpus.py`) and embedded
//  (`ingest/ingest.py`). Kept in lib/ rather than in the tool so a test can run
//  it: the claims that matter (every id resolves, nothing unmade is pointed to,
//  no clinical line is dropped) are about the OUTPUT, and a tool that only runs
//  by hand is a tool nobody checks.
//
//  WHAT IT HOLDS, and why each is its own kind (ids: `pv_veda_links.dart`):
//    pvread   every long read, its sections in the order the reader shows them,
//             each heading kept beside its words so a chunk that lands on one
//             section still says what it is about
//    pvfaq    each read's questions, one small document each: a question matches
//             a question far better than it matches an 800-character chunk of an
//             article, whose meaning is the average of its neighbours'
//    pvdoor   each door as a whole, and each of its cards that is not a read
//    pvtool   each tool on the Tools list
//
//  ⚠️ THE CLINICAL HALF IS EXPORTED WITH THE SAME WEIGHT AS THE REST. A read's
//  "when to see someone" and its evidence line are in the body; a door tab's
//  pinned warning signs are in the door's document. Dropping them would turn a
//  "call your doctor if" page into a reassurance page.
//
//  ⚠️ NOTHING THAT CANNOT BE OPENED IS POINTED TO. A card marked "coming soon"
//  is not a document (`pvVedaTileIsDocument`): the answer would send her to a
//  card that does nothing.
//
//  ENGLISH ONLY, by the current rule (new work is English unless Hindi is asked
//  for). The older pregnancy corpus keeps its own Hindi twins untouched.
// =============================================================================

import '../data/doors/pv_door_data.dart';
import '../data/reads/pregnancy_reads.dart' show kPregnancyReads;
import '../localization/app_language.dart';
import '../models/pv_read.dart';
import '../services/bracket_resolver.dart' show bracketById;
import 'pv_veda_links.dart';

/// The corpus domain: the same one the older pregnancy documents use, so a
/// pregnancy question (scoped to this domain by the service) finds both.
const String kPvVedaDomain = 'pregnancy';

const String kPvVedaSourceLabel = 'Pregnancy';

String _join(Iterable<String?> parts, {String sep = '\n\n'}) =>
    parts.where((s) => s != null && s.trim().isNotEmpty).map((s) => s!.trim()).join(sep);

String _l(LocalizedText? t) => t?.en ?? '';

/// A read's whole text, in the order the reader shows it.
String pvVedaReadBody(PvRead r) => _join([
      _l(r.shortAnswer),
      _l(r.scaleSetter),
      _l(r.teaser),
      for (final s in r.sections)
        // A custom block (a drawing, a calculator) has no words to embed.
        if (s.custom == null)
          _join([
            _l(s.heading),
            _l(s.summary),
            ...s.paragraphs.map(_l),
            _join(s.bullets.map((b) => '- ${_l(b)}'), sep: '\n'),
            if (s.tip != null) _join([_l(s.tip!.title), _l(s.tip!.body)]),
            if (s.mythFact != null)
              _join(['Myth: ${_l(s.mythFact!.myth)}', 'Fact: ${_l(s.mythFact!.fact)}']),
            if (s.callout != null) _join([_l(s.callout!.title), _l(s.callout!.body)]),
          ]),
      // Each FAQ is its own document (below), so it is not repeated here.
      _join([_l(r.whenToSeeSomeone.title), _l(r.whenToSeeSomeone.body)]),
      _l(r.evidence),
    ]);

Map<String, dynamic> _doc({
  required String docId,
  required String kind,
  required String title,
  required String body,
  List<String> keywords = const [],
}) =>
    <String, dynamic>{
      'doc_id': docId,
      'kind': kind,
      'domain': kPvVedaDomain,
      'source_label': kPvVedaSourceLabel,
      'title': title.trim(),
      'body': body.trim(),
      'title_hi': null,
      'body_hi': null,
      'keywords': [for (final k in keywords) if (k.trim().isNotEmpty) k.trim()],
    };

/// Everything, as the service's import expects it (`veda_corpus.json` shape).
List<Map<String, dynamic>> buildPregnancyVedaCorpus() {
  final s = S(AppLanguage.english);
  final out = <Map<String, dynamic>>[];

  // ---- reads and their questions ------------------------------------------------
  final seenReads = <String>{};
  for (final r in kPregnancyReads) {
    if (!seenReads.add(r.id)) continue; // an id is a document once
    out.add(_doc(
      docId: pvVedaReadId(r.id),
      kind: 'pvread',
      title: r.title.en,
      body: pvVedaReadBody(r),
      keywords: [r.kicker.en],
    ));
    for (var i = 0; i < r.faqs.length; i++) {
      final q = r.faqs[i];
      out.add(_doc(
        docId: pvVedaFaqId(r.id, i),
        kind: 'pvfaq',
        title: q.question.en,
        // The question leads the body: only the body is embedded. The read's
        // title rides along so an answer can say where it came from.
        body: _join([
          'Q: ${q.question.en}\nA: ${q.answer.en}',
          'From the read: ${r.title.en}',
        ]),
        keywords: [r.kicker.en],
      ));
    }
  }

  // ---- doors ------------------------------------------------------------------------
  for (final page in kPvDoorPages) {
    final bracket = bracketById(page.bracketId);
    final doorName = bracket?.label.en ?? page.heroTitle;
    String tabLabel(String? groupId) {
      for (final g in page.groups) {
        if (g.id == groupId) return g.label;
      }
      return '';
    }

    out.add(_doc(
      docId: pvVedaDoorId(page.bracketId),
      kind: 'pvdoor',
      title: doorName,
      body: _join([
        page.heroTitle,
        page.heroBlurb,
        'In the app: $doorName. Tabs: ${page.groups.map((g) => g.label).join(', ')}.',
        for (final g in page.groups) ...[
          if (g.note != null) '${g.label}: ${g.note}',
          if (g.pinnedRedFlag case final f?)
            _join([
              '${g.label}: ${f.title}',
              ...f.lines.map((l) => '- ${l.text}'),
              if (f.footer != null) f.footer,
            ], sep: '\n'),
        ],
        page.closingLine,
      ]),
    ));

    final seen = <String>{};
    for (final section in page.sections) {
      for (final t in section.tiles) {
        if (!pvVedaTileIsDocument(t)) continue;
        final slug = pvTileSlug(t.title);
        if (!seen.add(slug)) continue;
        out.add(_doc(
          docId: pvVedaDoorId(page.bracketId, t),
          kind: 'pvdoor',
          title: t.title,
          body: _join([
            t.blurb,
            if (t.meta != null) t.meta,
            'Find it in the app: $doorName, ${tabLabel(section.group)}'
                '${section.heading.isEmpty ? '' : ', ${section.heading}'}.',
          ]),
          keywords: t.keywords,
        ));
      }
    }
  }

  // ---- tools ----------------------------------------------------------------------------
  for (final t in kPvVedaTools) {
    final title = t.title(s);
    out.add(_doc(
      docId: pvVedaToolId(t.id),
      kind: 'pvtool',
      title: title,
      body: _join([t.line, 'Find it in the app: Tools, $title.']),
      keywords: t.keywords,
    ));
  }

  // Never a document with no words, and never the same id twice.
  final ids = <String>{};
  return [
    for (final d in out)
      if ((d['title'] as String).isNotEmpty &&
          (d['body'] as String).isNotEmpty &&
          ids.add(d['doc_id'] as String))
        d,
  ];
}

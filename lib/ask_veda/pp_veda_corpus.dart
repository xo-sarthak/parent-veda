// =============================================================================
//  The parenting corpus: what Ask Veda knows about the parenting side of the
//  app, and the way back into it (2026-10-10)
// -----------------------------------------------------------------------------
//  The pregnancy pattern (`pv_veda_corpus.dart` + `pv_veda_links.dart`), for
//  parenting. Written to JSON by `tool/export_parenting_corpus.dart`, imported
//  by the service (`ingest/import_corpus.py`) and embedded (`ingest/ingest.py`).
//
//  WHY THIS EXISTS. The older parenting export (`parenting_veda.dart`, through
//  `export_veda_corpus.dart`) sends seed lists only: an article as its TITLE,
//  recipes, products, experts. Every door page the parenting pass wrote
//  (hundreds of `PpPage`s across fourteen doors, their red flags, their
//  scripts and tables) never reached the service, so Ask Veda answered a
//  parenting question without the app's own words and could not point to them.
//
//  WHAT IT HOLDS (ids below):
//    ppvpage   every door page, all of its blocks as words, in reading order.
//              A table keeps its column names beside each value and a script
//              keeps "say this / not this / why", so a chunk that lands mid-
//              block still says what it is.
//    ppvdoor   each door as a whole: its tabs, their notes and footers
//    ppvtool   each tool a door shows above its rails
//    ppvguide  each "How to choose" buying guide
//
//  ⚠️ THE CLINICAL HALF IS EXPORTED WITH THE SAME WEIGHT AS THE REST. A page's
//  doctor callouts and when-lines are in its body, labelled. Dropping them
//  would turn a "call your doctor if" page into a reassurance page.
//
//  ⚠️ ONE PREFIX FOR THIS FILE, AND IT IS NOT `pp`. The older parenting ids are
//  `know_`, `ppart_`, `pprec_`, `ppprod_`, `ppexp_`, all in the same domain. The
//  import is run with `--prune-prefix ppv`; a prefix of `pp` would delete every
//  older document because this export does not contain them.
//
//  ⚠️ THE IDS AND THE RESOLVER LIVE IN ONE FILE ON PURPOSE: two halves of one
//  contract, and an id that resolves to nothing fails silently (a text sheet).
//  `test/pp_veda_corpus_test.dart` round-trips every exported id.
//
//  ENGLISH ONLY, by the current rule. Pages keep their authored "he/his"; the
//  service writes its own answer and the card opens the real page, which fills
//  the child's name and pronouns itself.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/doors/pp_door_data.dart';
import '../data/reads/pp_buying_guides.dart';
import '../models/pv_read.dart';
import '../screens/post_pregnancy/pp_content.dart';
import '../screens/post_pregnancy/pp_search.dart' show ppOpenSurface;
import '../screens/post_pregnancy/pp_section_registry.dart';
import '../screens/post_pregnancy/pp_section_screen.dart';
import '../screens/post_pregnancy/pp_surface_router.dart' show ppScreenForSurface;
import '../screens/reader/pv_reader_screen.dart';
import '../services/bracket_resolver.dart' show bracketById;
import '../theme/pv_fonts.dart' show PvType;
import 'pv_veda_corpus.dart' show pvVedaReadBody;

const String kPpVedaDomain = 'parenting';
const String kPpVedaSourceLabel = 'Parenting';

/// Every id this file makes starts with this. See the header.
const String kPpVedaPrefix = 'ppv';
const String _page = 'ppvpage_';
const String _door = 'ppvdoor_';
const String _tool = 'ppvtool_';
const String _guide = 'ppvguide_';

/// Section and page ids both contain `_`, so the two are joined by `__`.
String ppVedaPageId(String sectionId, String pageId) => '$_page${sectionId}__$pageId';
String ppVedaDoorId(String sectionId) => '$_door$sectionId';
String ppVedaToolId(String surfaceId) => '$_tool$surfaceId';
String ppVedaGuideId(String readId) => '$_guide$readId';

String _join(Iterable<String?> parts, {String sep = '\n\n'}) =>
    parts.where((s) => s != null && s.trim().isNotEmpty).map((s) => s!.trim()).join(sep);

String _lines(Iterable<String?> xs) => _join(xs, sep: '\n');

/// One block as words. Film and audio slots, links and pictures without
/// labels carry nothing to ground an answer on.
String ppVedaBlockText(PpBlock b) => switch (b) {
      PpIntro x => x.text,
      PpArticle x => _join([x.heading, ...x.paragraphs]),
      PpSteps x => _lines([
          x.heading,
          for (final (i, s) in x.steps.indexed) '${i + 1}. ${_join([s.title, s.detail], sep: ': ')}',
        ]),
      PpCards x => _lines([x.heading, for (final c in x.cards) '- ${_join([c.title, c.line], sep: ': ')}']),
      PpTable x => _lines([
          x.heading,
          for (final r in x.rows)
            '- ${[
              for (var i = 0; i < r.length; i++)
                i < x.columns.length && x.columns[i].trim().isNotEmpty ? '${x.columns[i]}: ${r[i]}' : r[i],
            ].join('; ')}',
        ]),
      PpChartCard x => _lines([
          _join([x.title, x.subtitle], sep: ': '),
          for (final (k, v) in x.rows) '- $k: $v',
          x.note,
        ]),
      PpCallout x => _join([
          x.title ??
              switch (x.kind) {
                PpCalloutKind.key => 'Worth remembering',
                PpCalloutKind.doctor => 'Worth raising with a doctor',
                PpCalloutKind.myth => 'A common belief, checked',
                PpCalloutKind.safety => 'For safety',
              },
          x.text,
        ], sep: ': '),
      PpScript x => _lines([
          x.heading,
          for (final l in x.lines)
            _join([
              'Say: ${l.say}',
              if (l.notThis != null) 'Not: ${l.notThis}',
              if (l.why != null) 'Why: ${l.why}',
            ], sep: ' | '),
        ]),
      PpWhenLine x => 'When to see a doctor: ${x.text}',
      PpIndiaNote x => 'In an Indian home: ${x.text}',
      PpConsult x => 'Someone to talk to: ${_join([x.title, x.whoFor], sep: ', ')}',
      PpCarousel x => _lines([
          _join([x.coverTitle, x.coverBlurb], sep: ': '),
          for (final c in x.cards) '- ${c.myth ? 'Myth: ' : ''}${_join([c.title, c.body], sep: ': ')}',
        ]),
      PpInteractive x => _lines([
          _join([x.title, x.blurb], sep: ': '),
          for (final i in x.items) '- ${_join([i.title, i.detail], sep: ': ')}',
          x.closing,
        ]),
      PpAnimation x => _join([x.title, x.caption], sep: ': '),
      PpIllustration x => _lines([
          _join([x.title, x.caption], sep: ': '),
          for (final l in x.labels) '- ${_join([l.title, l.detail], sep: ': ')}',
        ]),
      _ => '',
    };

String _doorName(PpSection s) => bracketById(s.id)?.label.en ?? s.title;

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
      'domain': kPpVedaDomain,
      'source_label': kPpVedaSourceLabel,
      'title': title.trim(),
      'body': body.trim(),
      'title_hi': null,
      'body_hi': null,
      'keywords': {for (final k in keywords) if (k.trim().isNotEmpty) k.trim()}.toList(),
    };

/// Everything, as the service's import expects it (`veda_corpus.json` shape).
List<Map<String, dynamic>> buildParentingVedaCorpus() {
  final out = <Map<String, dynamic>>[];

  // ---- door pages ---------------------------------------------------------------
  for (final s in kPpSections) {
    final door = _doorName(s);
    for (final a in s.areas) {
      for (final p in a.pages) {
        if (p.comingSoon) continue;
        out.add(_doc(
          docId: ppVedaPageId(s.id, p.id),
          kind: 'ppvpage',
          title: p.title,
          body: _join([
            p.subtitle,
            ...p.orderedBlocks.map(ppVedaBlockText),
            if (p.bands.isNotEmpty) 'Age: ${p.bands.join(', ')}.',
            'Find it in the app: $door, ${a.title}.',
          ]),
          keywords: [door, a.title, ?p.format, ...p.bands],
        ));
      }
    }
  }

  // ---- doors and their tools --------------------------------------------------------
  final seenTools = <String>{};
  for (final d in kPpDoors) {
    final s = ppSectionFor(d.sectionId);
    if (s == null) continue;
    final door = _doorName(s);
    out.add(_doc(
      docId: ppVedaDoorId(d.sectionId),
      kind: 'ppvdoor',
      title: door,
      body: _join([
        s.subtitle,
        s.intro,
        'In the app: $door. Tabs: ${d.tabs.map((t) => t.label).join(', ')}.',
        for (final t in d.tabs) ...[
          if (t.note != null) '${t.label}: ${t.note}',
          if (t.footer != null) '${t.label}: ${t.footer}',
        ],
        if (d.closing case final c?) 'Someone to talk to: ${c.label}. ${c.blurb}',
      ]),
    ));
    for (final t in d.tabs) {
      for (final tool in t.tools) {
        if (!seenTools.add(tool.surfaceId)) continue;
        out.add(_doc(
          docId: ppVedaToolId(tool.surfaceId),
          kind: 'ppvtool',
          title: tool.label,
          body: _join([tool.blurb, 'Find it in the app: $door, ${t.label}, ${tool.label}.']),
          keywords: [door, tool.chip],
        ));
      }
    }
  }

  // ---- buying guides ----------------------------------------------------------------
  for (final r in kPpBuyingGuides) {
    out.add(_doc(
      docId: ppVedaGuideId(r.id),
      kind: 'ppvguide',
      title: r.title.en,
      body: _join([pvVedaReadBody(r), 'Find it in the app: How to choose.']),
      keywords: ['buying guide', r.kicker.en],
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

/// What an exported id points to, without opening it — so a test can check
/// every id resolves. Null when the id is not this file's or names nothing.
Object? ppVedaTarget(String docId) {
  if (docId.startsWith(_page)) {
    final rest = docId.substring(_page.length);
    final cut = rest.indexOf('__');
    if (cut <= 0) return null;
    final s = ppSectionFor(rest.substring(0, cut));
    final p = s?.pageById(rest.substring(cut + 2));
    return (s == null || p == null) ? null : (s, p);
  }
  if (docId.startsWith(_door)) return ppDoorFor(docId.substring(_door.length));
  if (docId.startsWith(_tool)) {
    final id = docId.substring(_tool.length);
    // A surface the router cannot build is not a place to send her.
    return id.isEmpty || ppScreenForSurface(id) == null ? null : id;
  }
  if (docId.startsWith(_guide)) return ppBuyingGuideById(docId.substring(_guide.length));
  return null;
}

/// Opens the real thing behind an Ask Veda card. False when the id is not one
/// of this file's, so the caller keeps its own handling.
bool openPpVedaDoc(BuildContext context, String? docId) {
  final t = docId == null ? null : ppVedaTarget(docId);
  switch (t) {
    case (PpSection s, PpPage p):
      ppOpenPage(context, s, p, onSurface: ppOpenSurface);
    case PpDoor d:
      ppOpenSurface(context, 'pp_section/${d.sectionId}');
    case String surfaceId:
      ppOpenSurface(context, surfaceId);
    case PvRead r:
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'pp_buying_guide/${r.id}'),
        builder: (_) => PvReaderScreen(read: r, lang: PvType.lang),
      ));
    default:
      return false;
  }
  return true;
}

// =============================================================================
//  vedaAnswer - offline "answer from the whole app"
// -----------------------------------------------------------------------------
//  No LLM backend: Ask Veda now searches the ENTIRE app's content (via
//  VedaIndex) - Can I?, symptoms, the weekly baby/mother content, products,
//  reads, trimester tips, spiritual reading, read-to-baby, garbh sanskar, body
//  changes, tools and community insights - picks the best match for the answer,
//  and lists the next best matches as "From your ParentVeda" source cards. The
//  rich Can-I (verdict/why/trimester) and Symptom (why/tips/doctor) formatting
//  is preserved when one of those is the top match. Anything below the relevance
//  threshold gets a gentle "I don't have that yet" so the experience stays honest.
// =============================================================================

import '../data/can_i_data.dart';
import '../data/symptom_data.dart';
import '../data/veda_showcase.dart';
import '../localization/app_language.dart';
import '../models/can_i_entry.dart';
import '../models/symptom.dart';
import 'pregnancy_controller.dart';
import 'veda_context.dart';
import 'veda_index.dart';

/// A supporting result card ("From your ParentVeda").
class VedaSource {
  const VedaSource({
    required this.kind,
    required this.sourceLabel,
    required this.title,
    required this.snippet,
    required this.body,
  });
  final VedaKind kind;
  final String sourceLabel;
  final String title;
  final String snippet;
  final String body;
}

// VedaContentRef + VedaAnswerView (the shared 7-section answer model) now live
// in the app-neutral core (ask_veda/veda_core.dart) so both sides produce the
// same structure; they're visible here via veda_index's re-export of the core.

/// The structured answer. When [showcase] is non-null the UI renders the fixed
/// 7-section page from it; otherwise it renders the same 7 sections from [view].
/// [personalLine] is the mother-specific sentence to weave into "What this means
/// for you" (used by the showcase path; the retrieval [view] already bakes it in).
class VedaResult {
  const VedaResult({
    required this.answer,
    required this.sources,
    this.showcase,
    this.view,
    this.personalLine,
  });
  final String answer;
  final List<VedaSource> sources;
  final VedaShowcase? showcase;
  final VedaAnswerView? view;
  final String? personalLine;
}

/// A curated showcase entry whose keyword appears in [query] (longest, most
/// specific keyword wins). These match BEFORE the general retrieval so the 5
/// hand-authored questions always render the full structured page.
VedaShowcase? matchShowcase(String query) {
  final q = query.toLowerCase();
  VedaShowcase? best;
  var bestLen = 0;
  for (final e in kVedaShowcase) {
    for (final k in e.keywords) {
      if (k.length >= 3 && k.length > bestLen && q.contains(k)) {
        best = e;
        bestLen = k.length;
      }
    }
  }
  return best;
}

/// Best-effort grounded answer for [query] from our own content.
VedaResult vedaAnswer(String query, PregnancyController p) {
  final s = S(p.language);
  final lang = p.language;
  final ctx = VedaContext.gather(p);

  // Curated structured showcase answers take priority over retrieval. The
  // personal line (symptom/medication only - the showcase already states the
  // week) is woven into "What this means for you" by the UI.
  final show = matchShowcase(query);
  if (show != null) {
    return VedaResult(
      answer: show.answer.of(lang),
      sources: const [],
      showcase: show,
      personalLine: ctx.personalLine(query, lang, includeWeekLead: false),
    );
  }

  // Retrieval forms the answer from VETTED content only - community is EXCLUDED
  // (it's opinion; it can only appear as social proof in Section 5).
  final hits = vedaSearch(query, p, limit: 8, includeCommunity: false);
  if (hits.isEmpty) {
    return VedaResult(answer: s.vedaNoMatch, sources: const []);
  }

  final top = hits.first.doc;
  String answer;
  // Preserve the rich Can-I / Symptom answers when they win (no trailing
  // disclaimer - the result page shows its own at the bottom).
  if (top.kind == VedaKind.canI && top.id.startsWith('cani_')) {
    final e = _canIById(top.id.substring('cani_'.length));
    answer = e != null
        ? _formatCanI(e, s, lang, p, disclaimer: false)
        : _formatDoc(top, s, disclaimer: false);
  } else if (top.kind == VedaKind.symptom && top.id.startsWith('sym_')) {
    final x = _symptomById(top.id.substring('sym_'.length));
    answer = x != null
        ? _formatSymptom(x, s, lang, disclaimer: false)
        : _formatDoc(top, s, disclaimer: false);
  } else {
    answer = _formatDoc(top, s, disclaimer: false);
  }

  // S4 - ParentVeda content (typed). Products are pulled out to S6.
  final content = <VedaContentRef>[
    for (final h in hits.skip(1))
      if (h.doc.kind != VedaKind.product)
        VedaContentRef(
          kind: h.doc.kind,
          typeLabel: _typeLabel(h.doc.kind, s),
          title: h.doc.title,
          snippet: h.doc.snippet,
          body: h.doc.body,
          docId: h.doc.id,
        ),
  ].take(5).toList();

  // S6 - products (only if any product matched).
  final products = <String>[
    for (final h in hits)
      if (h.doc.kind == VedaKind.product) h.doc.title,
  ].take(4).toList();

  // S5 - community insight (social proof only; never sourced into the answer).
  final commHits = vedaCommunityMatches(query, p, limit: 3);
  final community =
      commHits.isEmpty ? null : s.vedaCommunitySocial(commHits.length);

  final view = VedaAnswerView(
    urgent: top.kind == VedaKind.symptom && _topIsUrgent(top),
    answer: answer,
    meaning: ctx.personalLine(query, lang) ?? s.vedaMeansDefault,
    actions: [s.vedaActionExplore, s.vedaActionTrack, s.vedaActionDoctor],
    content: content,
    community: community,
    products: products,
  );

  // Keep answer + sources populated for any back-compat caller; the UI uses view.
  final sources = <VedaSource>[
    for (final h in hits.skip(1).take(5))
      VedaSource(
        kind: h.doc.kind,
        sourceLabel: h.doc.sourceLabel,
        title: h.doc.title,
        snippet: h.doc.snippet,
        body: h.doc.body,
      ),
  ];
  return VedaResult(answer: answer, sources: sources, view: view);
}

/// Whether the top symptom doc is flagged urgent (→ red banner on the result).
bool _topIsUrgent(VedaDoc top) {
  if (!top.id.startsWith('sym_')) return false;
  final x = _symptomById(top.id.substring('sym_'.length));
  return x?.urgent ?? false;
}

/// Human content-TYPE label per kind (Section 4 eyebrow) - replaces the raw
/// "Can I?"/"Week 12" source labels the old fallback showed.
String _typeLabel(VedaKind k, S s) {
  switch (k) {
    case VedaKind.canI:
      return s.vedaTypeCanI;
    case VedaKind.symptom:
      return s.vedaTypeSymptom;
    case VedaKind.weekBaby:
    case VedaKind.weekMother:
      return s.vedaTypeWeekly;
    case VedaKind.read:
      return s.vedaTypeRead;
    case VedaKind.trimesterTip:
      return s.vedaTypeTip;
    case VedaKind.spiritual:
      return s.vedaTypeReflection;
    case VedaKind.readToBaby:
      return s.vedaTypeReadBaby;
    case VedaKind.garbh:
      return s.vedaTypeGarbh;
    case VedaKind.bodyChange:
      return s.vedaTypeBody;
    case VedaKind.tool:
      return s.vedaTypeTool;
    case VedaKind.product:
      return s.vedaTypeProduct;
    case VedaKind.community:
      return s.vedaTypeCommunity;
    case VedaKind.scan:
      return s.vedaTypeScan;
    // Parenting-side kinds never reach the pregnancy answer path (queries are
    // domain-scoped), but the switch stays exhaustive:
    case VedaKind.recipe:
      return s.vedaTypeRead;
    case VedaKind.expert:
      return s.vedaTypeCommunity;
    case VedaKind.activity:
    case VedaKind.health:
      return s.vedaTypeRead;
  }
}

/// Back-compat: just the answer text, for any caller that wants a plain String.
String vedaAnswerText(String query, PregnancyController p) =>
    vedaAnswer(query, p).answer;

CanIEntry? _canIById(String id) {
  for (final e in kCanIEntries) {
    if (e.id == id) return e;
  }
  return null;
}

Symptom? _symptomById(String id) {
  for (final x in kSymptoms) {
    if (x.id == id) return x;
  }
  return null;
}

// A generic doc → warm answer (title + body, optional disclaimer).
String _formatDoc(VedaDoc d, S s, {bool disclaimer = true}) {
  final b = StringBuffer()
    ..writeln(d.title)
    ..writeln()
    ..write(d.body.trim());
  if (disclaimer) {
    b
      ..writeln()
      ..writeln()
      ..write(s.vedaDisclaimer);
  }
  return b.toString().trim();
}

String _formatCanI(CanIEntry e, S s, AppLanguage lang, PregnancyController p,
    {bool disclaimer = true}) {
  final tri = p.currentWeek <= 13 ? 1 : (p.currentWeek <= 27 ? 2 : 3);
  final triNote = tri == 1 ? e.t1 : (tri == 2 ? e.t2 : e.t3);
  final b = StringBuffer()
    ..writeln('${e.name.of(lang)} - ${_verdict(s, e.verdict)}')
    ..writeln()
    ..writeln(e.short.of(lang));
  final why = e.why.of(lang).trim();
  if (why.isNotEmpty) {
    b
      ..writeln()
      ..writeln(why);
  }
  final note = triNote?.of(lang).trim() ?? '';
  if (note.isNotEmpty) {
    b
      ..writeln()
      ..writeln(note);
  }
  if (disclaimer) {
    b
      ..writeln()
      ..write(s.vedaDisclaimer);
  }
  return b.toString().trim();
}

String _verdict(S s, CanIVerdict v) {
  switch (v) {
    case CanIVerdict.safe:
      return s.vedaVerdictSafe;
    case CanIVerdict.moderation:
      return s.vedaVerdictModeration;
    case CanIVerdict.depends:
      return s.vedaVerdictDepends;
    case CanIVerdict.avoid:
      return s.vedaVerdictAvoid;
    case CanIVerdict.askDoctor:
      return s.vedaVerdictAskDoctor;
  }
}

String _formatSymptom(Symptom x, S s, AppLanguage lang,
    {bool disclaimer = true}) {
  final b = StringBuffer()
    ..writeln(x.name.of(lang))
    ..writeln()
    ..writeln(x.why.of(lang));
  if (x.tips.isNotEmpty) {
    b
      ..writeln()
      ..writeln('${s.symWhatHelps}:');
    for (final t in x.tips) {
      b.writeln('• ${t.of(lang)}');
    }
  }
  final doc = x.doctorGuidance.of(lang).trim();
  if (doc.isNotEmpty) {
    b
      ..writeln()
      ..writeln('${s.symWhenDoctor}: $doc');
  }
  if (disclaimer) {
    b
      ..writeln()
      ..write(s.vedaDisclaimer);
  }
  return b.toString().trim();
}

// NOTE: the old narrow `_bestCanI` / `_bestSymptom` longest-term matchers were
// replaced by the whole-app `vedaSearch` (veda_index.dart), which ranks Can-I &
// symptoms alongside every other source. Kept here (commented) for reference:
//
// CanIEntry? _bestCanI(String q, AppLanguage lang) { ... longest term in q ... }
// Symptom? _bestSymptom(String q, AppLanguage lang) { ... longest term in q ... }

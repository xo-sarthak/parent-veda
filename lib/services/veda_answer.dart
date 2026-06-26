// =============================================================================
//  vedaAnswer — offline "answer from the whole app"
// -----------------------------------------------------------------------------
//  No LLM backend: Ask Veda now searches the ENTIRE app's content (via
//  VedaIndex) — Can I?, symptoms, the weekly baby/mother content, products,
//  reads, trimester tips, spiritual reading, read-to-baby, garbh sanskar, body
//  changes, tools and community insights — picks the best match for the answer,
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

/// The structured answer: a warm primary answer + supporting source cards.
/// When [showcase] is non-null, the UI renders the full fixed 7-section result
/// page (Veda Answer → what it means → next actions → ParentVeda content →
/// community → products → services) instead of the plain answer + source cards.
class VedaResult {
  const VedaResult(
      {required this.answer, required this.sources, this.showcase});
  final String answer;
  final List<VedaSource> sources;
  final VedaShowcase? showcase;
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

  // Curated structured showcase answers take priority over retrieval.
  final show = matchShowcase(query);
  if (show != null) {
    return VedaResult(
        answer: show.answer.of(lang), sources: const [], showcase: show);
  }

  final hits = vedaSearch(query, p, limit: 7);
  if (hits.isEmpty) {
    return VedaResult(answer: s.vedaNoMatch, sources: const []);
  }

  final top = hits.first.doc;
  String answer;
  // Preserve the rich Can-I / Symptom answers when they win.
  if (top.kind == VedaKind.canI && top.id.startsWith('cani_')) {
    final e = _canIById(top.id.substring('cani_'.length));
    answer = e != null ? _formatCanI(e, s, lang, p) : _formatDoc(top, s);
  } else if (top.kind == VedaKind.symptom && top.id.startsWith('sym_')) {
    final x = _symptomById(top.id.substring('sym_'.length));
    answer = x != null ? _formatSymptom(x, s, lang) : _formatDoc(top, s);
  } else {
    answer = _formatDoc(top, s);
  }

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
  return VedaResult(answer: answer, sources: sources);
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

// A generic doc → warm answer (title + body + disclaimer).
String _formatDoc(VedaDoc d, S s) {
  final b = StringBuffer()
    ..writeln(d.title)
    ..writeln()
    ..writeln(d.body.trim())
    ..writeln()
    ..write(s.vedaDisclaimer);
  return b.toString().trim();
}

String _formatCanI(CanIEntry e, S s, AppLanguage lang, PregnancyController p) {
  final tri = p.currentWeek <= 13 ? 1 : (p.currentWeek <= 27 ? 2 : 3);
  final triNote = tri == 1 ? e.t1 : (tri == 2 ? e.t2 : e.t3);
  final b = StringBuffer()
    ..writeln('${e.name.of(lang)} — ${_verdict(s, e.verdict)}')
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
  b
    ..writeln()
    ..write(s.vedaDisclaimer);
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

String _formatSymptom(Symptom x, S s, AppLanguage lang) {
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
  b
    ..writeln()
    ..write(s.vedaDisclaimer);
  return b.toString().trim();
}

// NOTE: the old narrow `_bestCanI` / `_bestSymptom` longest-term matchers were
// replaced by the whole-app `vedaSearch` (veda_index.dart), which ranks Can-I &
// symptoms alongside every other source. Kept here (commented) for reference:
//
// CanIEntry? _bestCanI(String q, AppLanguage lang) { ... longest term in q ... }
// Symptom? _bestSymptom(String q, AppLanguage lang) { ... longest term in q ... }

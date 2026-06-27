// =============================================================================
//  VedaIndex — offline "whole-app" retrieval corpus for Ask Veda
// -----------------------------------------------------------------------------
//  Builds a searchable index over EVERY content source we ship — Can I?,
//  symptoms, the weekly baby/mother content, products, reads, trimester tips,
//  spiritual reading, read-to-baby, garbh sanskar, body changes, the tools, and
//  community insights — then scores a question against all of it. Purely
//  on-device: no LLM, no network. This is grounded RETRIEVAL — we surface the
//  most relevant things we already have (with their source), we don't generate.
//  It also doubles as the retrieval layer an AI backend could plug into later.
// =============================================================================

import '../data/body_changes.dart';
import '../data/can_i_data.dart';
import '../data/community_data.dart';
import '../data/garbh_data.dart';
import '../data/product_data.dart';
import '../data/read_next_data.dart';
import '../data/read_to_baby_data.dart';
import '../data/spiritual_reading_data.dart';
import '../data/symptom_data.dart';
import '../data/trimester_tips.dart';
import 'pregnancy_controller.dart';
import 'read_to_baby_store.dart';

/// Every content family the index can surface.
enum VedaKind {
  canI,
  symptom,
  weekBaby,
  weekMother,
  product,
  read,
  trimesterTip,
  spiritual,
  readToBaby,
  garbh,
  bodyChange,
  tool,
  community,
}

// A small stop-word set so common words don't create noise.
const Set<String> _kStop = {
  'the', 'a', 'an', 'is', 'am', 'are', 'was', 'were', 'be', 'been', 'being',
  'i', 'my', 'me', 'mine', 'we', 'our', 'you', 'your', 'it', 'its', 'this',
  'that', 'these', 'those', 'to', 'of', 'in', 'on', 'for', 'and', 'or', 'but',
  'can', 'could', 'do', 'does', 'did', 'what', 'how', 'when', 'where', 'why',
  'who', 'should', 'would', 'will', 'at', 'as', 'if', 'with', 'about', 'from',
  'into', 'than', 'then', 'too', 'any', 'some', 'have', 'has', 'had', 'get',
  'getting', 'during', 'while', 'okay', 'tell', 'know', 'need',
};

// Ubiquitous pregnancy-context words: they appear in almost every doc, so on
// their own they must NOT drive a match (they're heavily down-weighted and never
// count as a "specific" hit). This keeps "More information" topically relevant —
// e.g. "papaya in pregnancy" no longer surfaces "Sex during pregnancy" just
// because both contain the word "pregnancy".
const Set<String> _kGeneric = {
  'pregnancy', 'pregnant', 'pregnancies', 'baby', 'babies', 'week', 'weeks',
  'trimester', 'mom', 'mum', 'mother', 'mothers', 'maternal', 'womb',
};

// Keep tokens of 3+ chars, plus numbers (so "week 20" / "20 weeks" can pin the
// exact week), dropping stop-words.
List<String> _tokens(String s) => s
    .toLowerCase()
    .split(RegExp(r'[^a-z0-9]+'))
    .where((t) =>
        (t.length >= 3 || int.tryParse(t) != null) && !_kStop.contains(t))
    .toList();

/// One searchable unit of app content.
class VedaDoc {
  VedaDoc({
    required this.id,
    required this.kind,
    required this.sourceLabel,
    required this.title,
    required this.body,
    this.keywords = const [],
  })  : titleLower = title.toLowerCase(),
        _titleTokens = _tokens(title).toSet(),
        _keywordTokens = _tokens(keywords.join(' ')).toSet(),
        _bodyTokens = _tokens(body).toSet();

  final String id;
  final VedaKind kind;
  final String sourceLabel; // e.g. "Can I?", "Week 20 · Baby", "Islam · …"
  final String title;
  final String body;
  final List<String> keywords;

  final String titleLower;
  final Set<String> _titleTokens;
  final Set<String> _keywordTokens;
  final Set<String> _bodyTokens;

  String get snippet {
    final b = body.trim().replaceAll(RegExp(r'\s+'), ' ');
    return b.length <= 130 ? b : '${b.substring(0, 130).trimRight()}…';
  }

  /// Weighted overlap: title hit >> keyword hit >> body hit, with a strong
  /// boost when the whole query appears in the title, and a small reward for
  /// queries whose several distinct words all land somewhere.
  double score(List<String> qTokens, String qLower) {
    double s = 0;
    var matched = 0; // counts only SPECIFIC (non-generic) token hits
    for (final t in qTokens) {
      final generic = _kGeneric.contains(t);
      var hit = false;
      if (_titleTokens.contains(t)) {
        s += generic ? 1.5 : 6;
        hit = true;
      }
      if (_keywordTokens.contains(t)) {
        s += generic ? 1.0 : 4;
        hit = true;
      }
      if (_bodyTokens.contains(t)) {
        s += generic ? 0.0 : 1.5;
        hit = true;
      }
      if (hit && !generic) matched++;
    }
    // Require at least one SPECIFIC word to land. A doc that only shares
    // ubiquitous words ("pregnancy", "baby", "week") with the query isn't a real
    // match — this is what stops irrelevant "More information" cards.
    if (matched == 0) return 0;
    if (qLower.length >= 3 && titleLower.contains(qLower)) s += 8;
    if (titleLower == qLower) s += 8;
    if (matched >= 2) s += matched * 1.5;
    return s;
  }
}

class VedaHit {
  const VedaHit(this.doc, this.score);
  final VedaDoc doc;
  final double score;
}

// One-line descriptions of the app's tools (so "where do I count kicks" works).
const List<(String, String, String)> _kTools = [
  (
    'kick',
    'Baby Kick Counter',
    "Count and time your baby's movements and kicks — find it in the Tools tab."
  ),
  (
    'contraction',
    'Contraction Timer',
    'Time your contractions — how long they last and how far apart — in the Tools tab.'
  ),
  (
    'kegel',
    'Kegel Exercises',
    'Guided pelvic-floor (kegel) sessions to prepare your body, in the Tools tab.'
  ),
  (
    'weight',
    'Weight Tracker',
    'Log your pregnancy weight gain over the weeks, in the Tools tab.'
  ),
  (
    'checklist',
    'Product Checklist',
    'Build your own shopping checklists of baby and pregnancy products, in the Tools tab.'
  ),
  (
    'bump',
    'Bump Journey',
    'Capture a weekly bump photo journey to watch your belly grow, in the Tools tab.'
  ),
  (
    'journal',
    'My Journal',
    'Save memories, photos and voice notes through your whole pregnancy.'
  ),
  (
    'spiritual',
    'Spiritual Reading',
    'Gentle, neutral reflections across faith traditions, in the Tools tab.'
  ),
  (
    'hospitalbag',
    'Hospital Bag',
    'A ready checklist of what to pack for the hospital, in the Tools tab.'
  ),
  (
    'calendar',
    'Calendar',
    'Keep your appointments, scans and notes together on a calendar.'
  ),
  (
    'readnext',
    'Library',
    'Stage-aware articles, books and research picks chosen for your week.'
  ),
];

/// Builds + caches the corpus. Rebuilt when the language or the number of
/// loaded weeks changes (so weekly docs appear once content is ready).
class VedaIndex {
  static List<VedaDoc>? _cache;
  static String _key = '';

  static List<VedaDoc> corpus(PregnancyController p) {
    final lang = p.language;
    final key = '${lang.toString()}_${p.availableWeeks.length}';
    if (_cache != null && _key == key) return _cache!;

    final docs = <VedaDoc>[];

    // --- Can I? ---
    for (final e in kCanIEntries) {
      docs.add(VedaDoc(
        id: 'cani_${e.id}',
        kind: VedaKind.canI,
        sourceLabel: 'Can I?',
        title: e.name.of(lang),
        body: '${e.short.of(lang)} ${e.why.of(lang)}',
        keywords: [e.id.replaceAll('_', ' '), ...e.aliases],
      ));
    }

    // --- Symptoms ---
    for (final x in kSymptoms) {
      docs.add(VedaDoc(
        id: 'sym_${x.id}',
        kind: VedaKind.symptom,
        sourceLabel: 'Symptom',
        title: x.name.of(lang),
        body: '${x.why.of(lang)} ${x.tips.map((t) => t.of(lang)).join(' ')}',
        keywords: x.keywords,
      ));
    }

    // --- Products ---
    for (final pr in kProducts) {
      docs.add(VedaDoc(
        id: 'prod_${pr.id}',
        kind: VedaKind.product,
        sourceLabel: 'Product',
        title: pr.name,
        body: '${pr.summary} For ${pr.bestFor}. ${pr.why.join('. ')}',
        keywords: [pr.categoryId.replaceAll('_', ' ')],
      ));
    }

    // --- Reads (articles / books / research / expert) ---
    for (final r in kReadItems) {
      docs.add(VedaDoc(
        id: 'read_${r.id}',
        kind: VedaKind.read,
        sourceLabel: r.category.isEmpty ? 'Read' : r.category,
        title: r.title,
        body: r.body.isNotEmpty ? r.body : r.reason,
        keywords: [r.category],
      ));
    }

    // --- Trimester tips ---
    kTrimesterTipsV2.forEach((tri, tips) {
      for (var i = 0; i < tips.length; i++) {
        docs.add(VedaDoc(
          id: 'tip_${tri}_$i',
          kind: VedaKind.trimesterTip,
          sourceLabel: 'Trimester tip',
          title: tips[i].title.of(lang),
          body: tips[i].body.of(lang),
        ));
      }
    });

    // --- Spiritual reading ---
    for (final trad in kSpiritualTraditions) {
      for (var si = 0; si < trad.sections.length; si++) {
        final sec = trad.sections[si];
        for (var ri = 0; ri < sec.reads.length; ri++) {
          docs.add(VedaDoc(
            id: 'spir_${trad.id}_${si}_$ri',
            kind: VedaKind.spiritual,
            sourceLabel: '${trad.name} · ${sec.title}',
            title: sec.reads[ri].title,
            body: sec.reads[ri].body,
            keywords: [trad.name, sec.title],
          ));
        }
      }
    }

    // --- Read to your baby ---
    for (var i = 0; i < kReadAloudPieces.length; i++) {
      docs.add(VedaDoc(
        id: 'rtb_$i',
        kind: VedaKind.readToBaby,
        sourceLabel: 'Read to your baby',
        title: kReadAloudPieces[i].title,
        body: kReadAloudPieces[i].body,
        keywords: [kReadAloudPieces[i].category],
      ));
    }

    // --- Garbh Sanskar (reflective reads + listening) ---
    for (final g in kVichara) {
      docs.add(VedaDoc(
        id: 'garbh_${g.id}',
        kind: VedaKind.garbh,
        sourceLabel: 'Garbh Sanskar',
        title: g.title,
        body: '${g.blurb} ${g.body}',
        keywords: [g.theme],
      ));
    }
    for (final a in kShravan) {
      docs.add(VedaDoc(
        id: 'shravan_${a.id}',
        kind: VedaKind.garbh,
        sourceLabel: 'Garbh Sanskar · Listening',
        title: a.title,
        body: a.subtitle,
        keywords: const ['raga', 'music', 'listening', 'calm', 'relax'],
      ));
    }

    // --- Mother's body changes (week-tagged) ---
    kBodyChanges.forEach((wk, changes) {
      for (var i = 0; i < changes.length; i++) {
        docs.add(VedaDoc(
          id: 'body_${wk}_$i',
          kind: VedaKind.bodyChange,
          sourceLabel: 'Week $wk · Body',
          title: changes[i].label.of(lang),
          body: changes[i].detail.of(lang),
          keywords: ['week $wk', 'body'],
        ));
      }
    });

    // --- Tools ---
    for (final t in _kTools) {
      docs.add(VedaDoc(
        id: 'tool_${t.$1}',
        kind: VedaKind.tool,
        sourceLabel: 'Tool',
        title: t.$2,
        body: t.$3,
        keywords: const ['tool', 'tools tab'],
      ));
    }

    // --- Community insights (verified experts only) ---
    for (var i = 0; i < kSeedPosts.length; i++) {
      final post = kSeedPosts[i];
      if (post.cred.isEmpty) continue;
      docs.add(VedaDoc(
        id: 'comm_$i',
        kind: VedaKind.community,
        sourceLabel: 'Community · ${post.cred}',
        title: '${post.author} · ${post.cred}',
        body: post.text,
        keywords: post.topics,
      ));
    }

    // --- Weekly baby + mother content (from the loaded weeks) ---
    for (final wk in p.availableWeeks) {
      final w = p.weekData(wk);
      if (w == null) continue;
      final snap = w.snapshot;
      final dev = w.development;
      final mom = w.mom;
      final babyBody = [
        dev.whatImDoing.of(lang),
        snap.reveal.of(lang),
        snap.milestone.of(lang),
        if (dev.funFact != null) dev.funFact!.of(lang),
      ].where((x) => x.trim().isNotEmpty).join(' ');
      docs.add(VedaDoc(
        id: 'wkbaby_$wk',
        kind: VedaKind.weekBaby,
        sourceLabel: 'Week $wk · Baby',
        title: 'Your baby at week $wk',
        body: babyBody,
        keywords: ['week $wk', '$wk weeks', 'baby'],
      ));
      final momBody = [
        mom.physicalChanges.of(lang),
        mom.emotionalState.of(lang),
        mom.selfCareTip.of(lang),
        mom.reassurance.of(lang),
      ].where((x) => x.trim().isNotEmpty).join(' ');
      docs.add(VedaDoc(
        id: 'wkmom_$wk',
        kind: VedaKind.weekMother,
        sourceLabel: 'Week $wk · You',
        title: 'You at week $wk',
        body: momBody,
        keywords: ['week $wk', '$wk weeks', 'mother', 'you'],
      ));
    }

    _cache = docs;
    _key = key;
    return docs;
  }
}

/// Rank the whole-app corpus against [query]. Best-first hits above a relevance
/// threshold; empty for junk / no real match (so we can say "I don't have that"
/// honestly instead of surfacing noise).
List<VedaHit> vedaSearch(String query, PregnancyController p,
    {int limit = 6, bool includeCommunity = true}) {
  final qTokens = _tokens(query);
  if (qTokens.isEmpty) return const [];
  final qLower = query.toLowerCase().trim();
  // Religion guardrail: faith content (spiritual reading + read-to-baby) is
  // surfaced ONLY for traditions the mother has explicitly chosen in her
  // Read-to-baby customization — we never push a religion she hasn't opted into.
  final religions = ReadToBabyStore.instance.religions;
  final hits = <VedaHit>[];
  for (final d in VedaIndex.corpus(p)) {
    // Community posts are opinions — never a source for the actual answer.
    if (!includeCommunity && d.kind == VedaKind.community) continue;
    if (!_religionAllowed(d, religions)) continue;
    final sc = d.score(qTokens, qLower);
    if (sc >= 4.0) hits.add(VedaHit(d, sc));
  }
  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits.length <= limit ? hits : hits.sublist(0, limit);
}

/// Top COMMUNITY matches for [query] — used ONLY for the social-proof
/// "Community insights" section (Section 5). These are never used to form the
/// actual answer (Sections 1–4); they're someone's opinion, not guidance.
List<VedaHit> vedaCommunityMatches(String query, PregnancyController p,
    {int limit = 3}) {
  final qTokens = _tokens(query);
  if (qTokens.isEmpty) return const [];
  final qLower = query.toLowerCase().trim();
  final hits = <VedaHit>[];
  for (final d in VedaIndex.corpus(p)) {
    if (d.kind != VedaKind.community) continue;
    final sc = d.score(qTokens, qLower);
    if (sc >= 4.0) hits.add(VedaHit(d, sc));
  }
  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits.length <= limit ? hits : hits.sublist(0, limit);
}

/// Whether a (possibly faith-specific) doc may be shown given the mother's
/// selected [religions]. Spiritual reads are gated to her chosen tradition(s);
/// read-to-baby (customized by faith) only appears once she's opted into at
/// least one. Everything else is always allowed.
bool _religionAllowed(VedaDoc d, Set<String> religions) {
  switch (d.kind) {
    case VedaKind.spiritual:
      final tradId = _spiritualTradId(d.id);
      return tradId != null && religions.contains(tradId);
    case VedaKind.readToBaby:
      return religions.isNotEmpty;
    default:
      return true;
  }
}

/// Tradition id embedded in a spiritual doc id (`spir_<tradId>_<si>_<ri>`).
String? _spiritualTradId(String id) {
  if (!id.startsWith('spir_')) return null;
  final parts = id.split('_'); // [spir, <tradId…>, si, ri]
  if (parts.length < 4) return null;
  return parts.sublist(1, parts.length - 2).join('_');
}

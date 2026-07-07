// =============================================================================
//  VedaIndex - the PREGNANCY corpus + adapter for the Ask Veda engine
// -----------------------------------------------------------------------------
//  Builds the pregnancy side's searchable content - Can I?, symptoms, weekly
//  baby/mother content, products, reads, weekly articles, scan guides, trimester
//  tips, spiritual reading, read-to-baby, garbh sanskar, body changes, tools and
//  community insights - each stamped `domain: pregnancy`, then hands it to the
//  app-neutral core (`ask_veda/veda_core.dart`) to rank. This file is the
//  pregnancy ADAPTER: the content and the faith-gating rules live here; the
//  matching lives in the core, so the parenting side reuses the exact same engine
//  with its own corpus. Re-exports the core so existing importers keep their
//  VedaKind / VedaDoc without changing their imports.
//  Purely on-device: no LLM, no network - grounded retrieval, not generation.
// =============================================================================

import '../ask_veda/veda_core.dart';
import '../data/body_changes.dart';
import '../data/can_i_data.dart';
import '../data/community_data.dart';
import '../data/garbh_data.dart';
import '../data/product_data.dart';
import '../data/read_next_data.dart';
import '../data/read_to_baby_data.dart';
import '../data/scan_guide_data.dart';
import '../data/spiritual_reading_data.dart';
import '../data/symptom_data.dart';
import '../data/trimester_tips.dart';
import '../data/week_articles_data.dart';
import '../models/garbh_content.dart';
import 'pregnancy_controller.dart';
import 'read_to_baby_store.dart';

// Re-export the neutral core so existing importers of this file keep seeing
// VedaKind / VedaDoc / VedaHit / VedaDomain / vedaScore without new imports.
export '../ask_veda/veda_core.dart';

// Human titles for the scan guides (keyed by the medical milestone id in
// kScanGuides). Kept here so the index doesn't depend on the journey-map data.
const Map<String, String> _kScanTitles = {
  'm_ultrasound': 'Dating / first ultrasound scan',
  'm_nt': 'NT scan (nuchal translucency)',
  'm_anomaly': 'Anomaly scan (20-week scan)',
  'm_glucose': 'Glucose screening (GTT)',
  'm_growth': 'Growth scan',
  'm_gbs': 'Group B Strep (GBS) swab',
};

// One-line descriptions of the app's tools (so "where do I count kicks" works).
const List<(String, String, String)> _kTools = [
  (
    'kick',
    'Baby Kick Counter',
    "Count and time your baby's movements and kicks - find it in the Tools tab."
  ),
  (
    'contraction',
    'Contraction Timer',
    'Time your contractions - how long they last and how far apart - in the Tools tab.'
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

/// Builds + caches the pregnancy corpus (all `domain: pregnancy`). Rebuilt when
/// the language or the number of loaded weeks changes (so weekly docs appear
/// once content is ready).
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

    // --- Weekly written articles ("This week's reads") ---
    // Full-length written pieces, searchable regardless of the mother's current
    // week. De-duplicated by title (some articles repeat across weeks).
    final seenArticles = <String>{};
    for (var i = 0; i < kWeekArticles.length; i++) {
      final a = kWeekArticles[i];
      if (!seenArticles.add(a.title)) continue;
      docs.add(VedaDoc(
        id: 'wkarticle_$i',
        kind: VedaKind.read,
        sourceLabel: 'Weekly read',
        title: a.title,
        body: a.body,
        keywords: ['week ${a.week}', 'article', 'read'],
      ));
    }

    // --- Scan & test guides (what the scan is + how to read the report) ---
    kScanGuides.forEach((id, g) {
      final terms = g.interpret
          .map((r) => '${r.term.of(lang)} - ${r.meaning.of(lang)}')
          .join(' ');
      docs.add(VedaDoc(
        id: 'scan_$id',
        kind: VedaKind.scan,
        sourceLabel: 'Scan guide',
        title: _kScanTitles[id] ?? 'Scan guide',
        body: '${g.whatIs.of(lang)} $terms',
        keywords: const [
          'scan', 'ultrasound', 'test', 'report', 'result', 'screening', 'pregnancy scan',
        ],
      ));
    });

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
    // Kriya - breath & grounding practices (answers "breathing exercise to calm
    // down / relax / ease anxiety").
    for (final k in kKriya) {
      docs.add(VedaDoc(
        id: 'kriya_${k.id}',
        kind: VedaKind.garbh,
        sourceLabel: 'Garbh Sanskar · Breath',
        title: k.title,
        body: '${k.blurb}. ${k.phases.map((ph) => ph.label).join(', ')}.',
        keywords: const [
          'kriya', 'breath', 'breathing', 'pranayama', 'calm', 'relax',
          'anxiety', 'stress', 'grounding', 'panic',
        ],
      ));
    }
    // Samvad - womb-connection speaking cards, one doc per trimester set
    // (affirmations / read-aloud scripts / visualizations).
    const samvadSets = <(String, String, List<GarbhPrompt>)>[
      ('samvad_t1', 'Speaking to your baby - affirmations', kSamvadT1),
      ('samvad_t2', 'Speaking to your baby - read-aloud scripts', kSamvadT2),
      ('samvad_t3', 'Speaking to your baby - visualizations', kSamvadT3),
    ];
    for (final set in samvadSets) {
      docs.add(VedaDoc(
        id: set.$1,
        kind: VedaKind.garbh,
        sourceLabel: 'Garbh Sanskar · Samvad',
        title: set.$2,
        body: set.$3.map((pr) => pr.text).join(' '),
        keywords: const [
          'samvad', 'bonding', 'talk to baby', 'speak', 'read aloud',
          'affirmation', 'connection', 'womb',
        ],
      ));
    }
    // Vichara - Sacred Insights (short reflective verses).
    final insights = garbhAllInsights();
    for (var i = 0; i < insights.length; i++) {
      docs.add(VedaDoc(
        id: 'insight_$i',
        kind: VedaKind.garbh,
        sourceLabel: 'Garbh Sanskar · Insight',
        title: insights[i].sloka,
        body: '${insights[i].meaning} ${insights[i].lesson}',
        keywords: const ['insight', 'calm', 'mindful', 'peace', 'reflection', 'wisdom'],
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

/// Rank the pregnancy corpus against [query] via the shared engine - best-first
/// hits above the relevance threshold; empty for junk / no real match (so we can
/// say "I don't have that" honestly instead of surfacing noise). Scoped to the
/// pregnancy domain (+ universal), with community excluded from the answer when
/// [includeCommunity] is false and faith content gated to the mother's choices.
List<VedaHit> vedaSearch(String query, PregnancyController p,
    {int limit = 6, bool includeCommunity = true}) {
  // Religion guardrail: faith content (spiritual reading + read-to-baby) is
  // surfaced ONLY for traditions the mother has explicitly chosen in her
  // Read-to-baby customization - we never push a religion she hasn't opted into.
  final religions = ReadToBabyStore.instance.religions;
  return vedaScore(
    query,
    VedaIndex.corpus(p),
    limit: limit,
    where: (d) =>
        vedaInDomain(d, VedaDomain.pregnancy) &&
        (includeCommunity || d.kind != VedaKind.community) &&
        _religionAllowed(d, religions),
  );
}

/// Top COMMUNITY matches for [query] - used ONLY for the social-proof
/// "Community insights" section (Section 5). These are never used to form the
/// actual answer (Sections 1–4); they're someone's opinion, not guidance.
List<VedaHit> vedaCommunityMatches(String query, PregnancyController p,
    {int limit = 3}) {
  return vedaScore(
    query,
    VedaIndex.corpus(p),
    limit: limit,
    where: (d) => d.kind == VedaKind.community && vedaInDomain(d, VedaDomain.pregnancy),
  );
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

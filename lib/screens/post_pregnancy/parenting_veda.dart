// =============================================================================
//  ParentingVeda - the PARENTING corpus + adapter for the shared Ask Veda engine
// -----------------------------------------------------------------------------
//  The post-pregnancy side's feed into the ONE Ask Veda brain. It builds the
//  parenting content as VedaDocs, each stamped `domain: parenting`, then hands
//  them to the app-neutral core (`ask_veda/veda_core.dart`) - the exact same
//  matcher the pregnancy side uses. A parenting question is scoped to the
//  parenting tag, so it's answered from parenting content (never pregnancy).
//
//  Content sources (plug-and-play - add more the same way, all tagged parenting):
//    • a compact hand-authored knowledge set (sleep, feeding, development,
//      health) so the common questions get a real answer;
//    • the parenting Articles, Recipes, Products and Experts data already shipped.
//
//  Imports ONLY the neutral core + parenting data - nothing from the pregnancy
//  app - so the two products stay isolated while sharing one engine.
//  Offline, no LLM: grounded retrieval, not generation.
// =============================================================================

import '../../ask_veda/veda_core.dart';
import 'pp_articles_data.dart';
import 'pp_experts_data.dart';
import 'pp_products_data.dart';
import 'pp_recipes_data.dart';

// A parenting VedaDoc is just a core VedaDoc stamped with the parenting tag.
VedaDoc _pdoc({
  required String id,
  required VedaKind kind,
  required String sourceLabel,
  required String title,
  required String body,
  List<String> keywords = const [],
}) =>
    VedaDoc(
      id: id,
      kind: kind,
      sourceLabel: sourceLabel,
      title: title,
      body: body,
      keywords: keywords,
      domain: VedaDomain.parenting,
    );

// ---------------------------------------------------------------------------
//  Hand-authored parenting knowledge - the "here's a real answer" layer, so a
//  question like "he wakes every 2 hours at night" lands on guidance, not just a
//  card title. Original, warm, and always with the "call your paediatrician"
//  safety net baked into the guidance. Scenario voice: Aarav at four months.
// ---------------------------------------------------------------------------
const List<(String, VedaKind, String, String, List<String>)> _kKnowledge = [
  (
    'sleep_regression',
    VedaKind.health,
    'The 4-month sleep regression',
    "If your baby was sleeping in long stretches and has suddenly started waking every couple of hours, this is almost always the 4-month sleep regression - a normal, temporary part of development (it lines up with the four-month sleep change). His sleep is maturing into adult-like cycles with lighter phases he briefly surfaces from. It usually settles in 2–6 weeks. Hold a calm, consistent wind-down, offer a chance to resettle before rushing in, and keep nights boring and dark. It's a sign of development, not a step back. If the waking comes with fever, poor feeding or seems like pain, check with your paediatrician.",
    ['sleep', 'regression', 'waking', 'wakes', 'night', 'nights', '4 month', 'four month', 'leap', 'nap', 'settle', 'resettle'],
  ),
  (
    // REWRITTEN 20 Jul. This used to teach the Wonder Weeks framework as fact -
    // "your baby may be in a developmental leap", "Leap 4 opens up the world of
    // events". We moved the app off that framework because it failed
    // replication, so Ask Veda cannot go on teaching it. The honest answer keeps
    // the one insight that IS supported (fussy patches often precede a new
    // skill) and drops the fixed-week structure and the branded labels. The
    // 'wonder week' keywords stay so a parent who asks in those words still
    // gets an answer - just an accurate one.
    'fussy_before_skills',
    VedaKind.health,
    'Fussy patches before a new skill',
    "Fussy, clingy, feeding and sleeping all over the place for no obvious reason? Babies often do have a difficult few days shortly before a new skill shows up - it is one of the more reliable patterns parents notice, and it passes. What is NOT reliable is the idea that this happens in every baby at fixed weeks. You may have seen 'Wonder Weeks' leap charts with exact week numbers; researchers have repeatedly failed to reproduce those, including the original author's own PhD student. So treat a fussy stretch as real, and the calendar as noise. Extra closeness, patience and slow narrated play help him through. Fussiness with fever, poor feeding or unusual listlessness is a different thing - call your paediatrician.",
    ['leap', 'leaps', 'wonder week', 'wonder weeks', 'fussy', 'clingy', 'development', 'developmental', 'milestone', 'brain', 'regression'],
  ),
  (
    'tummy_time',
    VedaKind.activity,
    'Tummy time, made easy',
    "Tummy time builds the neck, shoulder and core strength your baby needs to roll, sit and eventually crawl. Aim for short, frequent sessions through the day rather than one long one - a few minutes at a time, building up as he tolerates it. Get down at his eye level, use a mirror or a favourite toy, and stop before he's upset so it stays a happy game. Chest-to-chest on you counts too on the grumpy days.",
    ['tummy time', 'tummy', 'rolling', 'roll', 'neck', 'strength', 'motor', 'play', 'floor', 'crawl'],
  ),
  (
    'starting_solids',
    VedaKind.health,
    'Starting solids: when and how',
    "Most babies are ready for solids at around 6 months - when he can sit with support, holds his head steady, shows interest in food and has lost the reflex that pushes food out. Start with single, soft foods (mashed dal, well-cooked veg, banana, ragi) and introduce one new food at a time so you can spot any reaction. Milk (breast or formula) is still his main nutrition through the first year; solids at this stage are about learning to eat. Never rush or force - follow his cues, and check with your paediatrician before starting.",
    ['solids', 'weaning', 'first food', 'first foods', 'feeding', 'eat', 'eating', '6 months', 'six months', 'purée', 'puree', 'porridge'],
  ),
  (
    'teething',
    VedaKind.health,
    'Teething, soothed',
    "Drooling, chewing everything, sore gums and extra fussiness often mean a tooth is on the way (first teeth commonly appear from around 6 months, but it varies a lot). Offer a clean chilled - not frozen - teething ring, a cool clean cloth to gnaw, or gentle gum rubbing with a clean finger. High fever, diarrhoea or being genuinely unwell is NOT caused by teething - treat those as illness and speak to your doctor.",
    ['teething', 'teeth', 'tooth', 'gums', 'drooling', 'chewing', 'biting', 'sore'],
  ),
  (
    'fever_when_to_worry',
    VedaKind.health,
    'Fever: what to watch for',
    "For a baby, a temperature of 38°C (100.4°F) or above is a fever. Keep him comfortable and hydrated (more frequent feeds), dress him lightly, and use paracetamol only at the dose your paediatrician advises for his weight. Seek medical help promptly for: any fever under 3 months of age, a fever that's very high or won't come down, a rash that doesn't fade under a glass, breathing difficulty, a fit, unusual drowsiness, refusing feeds, or your own gut feeling that something is wrong. When in doubt, always call your doctor.",
    ['fever', 'temperature', 'high temperature', 'hot', 'sick', 'unwell', 'paracetamol', 'ill', 'illness'],
  ),
  (
    'four_month_vaccines',
    VedaKind.health,
    'The 4-month vaccines',
    "Around 4 months your baby is due his next set of routine immunisations (a booster round after the 6- and 10-week doses in the Indian schedule, typically the 14-week visit). Mild fever, fussiness or a sore leg for a day or two afterwards is common and normal - extra cuddles, feeds and the dose of paracetamol your doctor advises usually cover it. Bring his vaccination card. Your paediatrician will confirm exactly which vaccines are due for him.",
    ['vaccine', 'vaccines', 'vaccination', 'immunisation', 'immunization', 'shots', 'jab', '14 week', 'booster', 'pcv'],
  ),
  (
    'talking_reading',
    VedaKind.activity,
    'Talking and reading to your baby',
    "Your baby is learning language long before he can speak. Narrate your day - 'now we're pouring the water' - sing, and pause as if for his reply; those back-and-forth 'conversations' build his ear for language. Board books with big high-contrast pictures are perfect now: he's learning voices, rhythm and closeness more than any story. A few minutes, often, is plenty.",
    ['talk', 'talking', 'language', 'read', 'reading', 'books', 'speech', 'babble', 'cooing', 'sing', 'singing'],
  ),
];

// ---------------------------------------------------------------------------
//  Corpus - built once and cached (parenting data is all const).
// ---------------------------------------------------------------------------
List<VedaDoc>? _cache;

List<VedaDoc> parentingCorpus() {
  if (_cache != null) return _cache!;
  final docs = <VedaDoc>[];

  // --- Hand-authored knowledge ---
  for (final k in _kKnowledge) {
    docs.add(_pdoc(
      id: 'know_${k.$1}',
      kind: k.$2,
      sourceLabel: 'ParentVeda guide',
      title: k.$3,
      body: k.$4,
      keywords: k.$5,
    ));
  }

  // --- Articles ---
  for (final a in kArticles) {
    docs.add(_pdoc(
      id: 'ppart_${a.id}',
      kind: VedaKind.read,
      sourceLabel: a.category,
      title: a.title,
      body: '${a.title}. A ${a.category.toLowerCase()} read for ${a.age}.',
      keywords: [a.category, a.age, 'article'],
    ));
  }

  // --- Recipes ---
  for (final r in kRecipes) {
    docs.add(_pdoc(
      id: 'pprec_${r.id}',
      kind: VedaKind.recipe,
      sourceLabel: r.situation == null ? 'Recipe' : 'Sick-day recipe',
      title: r.title,
      body: '${r.description} ${r.subtitle}. ${r.meal}.',
      keywords: [
        r.category, r.meal, if (r.veg) 'veg' else 'non-veg',
        if (r.situation != null) r.situation!, 'recipe', 'food', 'meal',
      ],
    ));
  }

  // --- Products ---
  for (final pr in kPpProducts) {
    docs.add(_pdoc(
      id: 'ppprod_${pr.id}',
      kind: VedaKind.product,
      sourceLabel: 'Product',
      title: pr.name,
      body: '${pr.summary.isEmpty ? pr.name : pr.summary} ${pr.category} · ${pr.sub}. ${pr.pros.join('. ')}',
      keywords: [pr.category, pr.sub, pr.brand],
    ));
  }

  // --- Experts ---
  for (final e in kExperts) {
    docs.add(_pdoc(
      id: 'ppexp_${e.id}',
      kind: VedaKind.expert,
      sourceLabel: 'Expert',
      title: '${e.name} · ${e.credential}',
      body: '${e.why} ${e.tags.join(', ')}.',
      keywords: e.tags,
    ));
  }

  _cache = docs;
  return docs;
}

// ---------------------------------------------------------------------------
//  Search + answer (mirrors the pregnancy adapter, scoped to the parenting tag).
// ---------------------------------------------------------------------------

/// Rank the parenting corpus against [query] via the shared engine, scoped to
/// the parenting domain (+ universal).
List<VedaHit> parentingVedaSearch(String query,
        {int limit = 8, bool includeCommunity = true}) =>
    vedaScore(
      query,
      parentingCorpus(),
      limit: limit,
      where: (d) =>
          vedaInDomain(d, VedaDomain.parenting) &&
          (includeCommunity || d.kind != VedaKind.community),
    );

String _typeLabel(VedaKind k) {
  switch (k) {
    case VedaKind.recipe:
      return 'Recipe';
    case VedaKind.expert:
      return 'Expert';
    case VedaKind.activity:
      return 'Activity';
    case VedaKind.health:
      return 'Health';
    case VedaKind.product:
      return 'Product';
    case VedaKind.read:
      return 'Read';
    default:
      return 'ParentVeda';
  }
}

String _formatDoc(VedaDoc d) => '${d.title}\n\n${d.body.trim()}';

/// The unified 7-section answer for the parenting side. Sections 1–4 come only
/// from parenting content; products fall out to S6. Returns a "no match yet"
/// view (honest) when nothing clears the relevance bar.
VedaAnswerView parentingVedaAnswer(String query) {
  final hits = parentingVedaSearch(query, limit: 8, includeCommunity: false);
  if (hits.isEmpty) {
    return const VedaAnswerView(
      answer:
          "I don't have a confident answer for that yet. Try rephrasing, explore My Child, or ask a ParentVeda expert - and for anything medical, your paediatrician is the right call.",
      meaning: '',
      actions: [
        'Explore My Child',
        'Ask a ParentVeda expert',
        'When in doubt, call your paediatrician',
      ],
      content: [],
    );
  }

  final top = hits.first.doc;

  final content = <VedaContentRef>[
    for (final h in hits.skip(1))
      if (h.doc.kind != VedaKind.product)
        VedaContentRef(
          kind: h.doc.kind,
          typeLabel: _typeLabel(h.doc.kind),
          title: h.doc.title,
          snippet: h.doc.snippet,
          body: h.doc.body,
          docId: h.doc.id,
        ),
  ].take(5).toList();

  final products = <String>[
    for (final h in hits)
      if (h.doc.kind == VedaKind.product) h.doc.title,
  ].take(4).toList();

  return VedaAnswerView(
    answer: _formatDoc(top),
    meaning:
        "This is general guidance for your child's stage - every baby is different. For anything that worries you, your paediatrician knows your child best.",
    actions: const [
      'Explore in My Child',
      'Save to My Journal',
      'When in doubt, call your paediatrician',
    ],
    content: content,
    products: products,
  );
}

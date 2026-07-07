// =============================================================================
//  Ask Veda — app-neutral search core (the single engine, no app dependencies)
// -----------------------------------------------------------------------------
//  This folder is the ONE Ask Veda brain for the whole product. It knows nothing
//  about pregnancy or parenting — it only knows how to hold tagged content and
//  score a question against it. Each side of the app (pregnancy, post-pregnancy)
//  is a thin adapter that:
//    1. builds its own content as VedaDocs, each stamped with its `domain` tag,
//    2. asks this core to rank a query, scoped to that domain (+ universal).
//
//  So a question carries the tag of where it came from, every doc carries the
//  tag of what it's for, and the engine answers "in the direction of the tag".
//  Adding content later = add more tagged VedaDocs to that side's corpus. That's
//  the whole contract — plug in data, the knowledge improves.
//
//  Purely on-device: no LLM, no network. Grounded RETRIEVAL — we surface the most
//  relevant things we already have (with their source), we don't generate. It
//  also doubles as the retrieval layer an AI backend can plug into later.
//
//  IMPORTANT: keep this file free of any `import` that points at app code
//  (screens, controllers, data). That independence is the whole point.
// =============================================================================

/// Which side of the app a doc belongs to — and which a question is scoped to.
/// `universal` content is shared by both sides (general wellness, breathing…).
enum VedaDomain { pregnancy, parenting, universal }

/// The shared content-type vocabulary. Both products contribute kinds here; how
/// a kind is LABELLED / COLOURED / ICONED and where tapping it ROUTES lives with
/// the app that renders the result (routing needs an app's Navigator + screens),
/// so this enum stays a plain, neutral vocabulary.
enum VedaKind {
  // pregnancy vocabulary
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
  scan,
  // parenting vocabulary
  recipe,
  expert,
  activity,
  health,
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

// Ubiquitous context words: they appear in almost every doc, so on their own
// they must NOT drive a match (heavily down-weighted, never a "specific" hit).
// This keeps "More information" topically relevant — e.g. "papaya in pregnancy"
// no longer surfaces "Sex during pregnancy" just because both say "pregnancy".
const Set<String> _kGeneric = {
  'pregnancy', 'pregnant', 'pregnancies', 'baby', 'babies', 'week', 'weeks',
  'trimester', 'mom', 'mum', 'mother', 'mothers', 'maternal', 'womb',
  'child', 'children', 'kid', 'toddler', 'parenting', 'parent',
};

// Keep tokens of 3+ chars, plus numbers (so "week 20" / "20 weeks" can pin the
// exact week), dropping stop-words.
List<String> _tokens(String s) => s
    .toLowerCase()
    .split(RegExp(r'[^a-z0-9]+'))
    .where((t) =>
        (t.length >= 3 || int.tryParse(t) != null) && !_kStop.contains(t))
    .toList();

/// One searchable unit of app content, tagged with the [domain] it belongs to.
class VedaDoc {
  VedaDoc({
    required this.id,
    required this.kind,
    required this.sourceLabel,
    required this.title,
    required this.body,
    this.keywords = const [],
    // Defaults to pregnancy (the incumbent corpus) purely to keep existing
    // call-sites terse; the parenting adapter passes `domain: VedaDomain.parenting`.
    this.domain = VedaDomain.pregnancy,
  })  : titleLower = title.toLowerCase(),
        _titleTokens = _tokens(title).toSet(),
        _keywordTokens = _tokens(keywords.join(' ')).toSet(),
        _bodyTokens = _tokens(body).toSet();

  final String id;
  final VedaKind kind;
  final VedaDomain domain;
  final String sourceLabel; // e.g. "Can I?", "Week 20 · Baby", "Scan guide"
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

/// True when [doc] is servable to a question scoped to [domain] — its own domain
/// or `universal` (shared) content. The one rule that makes the tag "point" the
/// engine: a pregnancy question never sees parenting docs, and vice-versa.
bool vedaInDomain(VedaDoc doc, VedaDomain domain) =>
    doc.domain == domain || doc.domain == VedaDomain.universal;

/// Rank [corpus] against [query], best-first, above a relevance [threshold]
/// (empty for junk / no real match, so callers can honestly say "I don't have
/// that" instead of surfacing noise). The [where] predicate is how a caller
/// scopes the search — by domain, by kind, by faith-gating, or any combination —
/// keeping this core free of app-specific rules.
List<VedaHit> vedaScore(
  String query,
  Iterable<VedaDoc> corpus, {
  int limit = 6,
  double threshold = 4.0,
  bool Function(VedaDoc doc)? where,
}) {
  final qTokens = _tokens(query);
  if (qTokens.isEmpty) return const [];
  final qLower = query.toLowerCase().trim();
  final hits = <VedaHit>[];
  for (final d in corpus) {
    if (where != null && !where(d)) continue;
    final sc = d.score(qTokens, qLower);
    if (sc >= threshold) hits.add(VedaHit(d, sc));
  }
  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits.length <= limit ? hits : hits.sublist(0, limit);
}

// ===========================================================================
//  The shared ANSWER model — the fixed 7-section result, identical for both
//  sides of the app. Each adapter (pregnancy / parenting) fills this in from its
//  own corpus + context; the shared result UI renders it. Empty sections are
//  omitted by the UI. Sections 1–4 are formed only from vetted content (never
//  community); community feeds Section 5 (social proof) only.
// ===========================================================================

/// One typed content card for Section 4 ("ParentVeda content"). Carries a human
/// TYPE label ("Weekly journey", "Read", "Recipe"…) — what the user asked for —
/// while tap-routing uses [kind]. [docId] lets a caller resolve the exact doc.
class VedaContentRef {
  const VedaContentRef({
    required this.kind,
    required this.typeLabel,
    required this.title,
    required this.snippet,
    required this.body,
    this.docId,
  });
  final VedaKind kind;
  final String typeLabel;
  final String title;
  final String snippet;
  final String body;
  final String? docId;
}

/// The unified fixed-format answer. The UI renders the SAME seven sections for
/// every query (showcase or retrieval), omitting any empty section.
class VedaAnswerView {
  const VedaAnswerView({
    this.urgent = false,
    required this.answer, // S1 · Veda answer
    required this.meaning, // S2 · what this means for you
    required this.actions, // S3 · recommended actions
    required this.content, // S4 · ParentVeda content
    this.community, // S5 · community insight (social proof)
    this.products = const [], // S6 · products
    this.services = const [], // S7 · services
  });
  final bool urgent;
  final String answer;
  final String meaning;
  final List<String> actions;
  final List<VedaContentRef> content;
  final String? community;
  final List<String> products;
  final List<String> services;
}

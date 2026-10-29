// =============================================================================
//  AskVedaService — calls the AskVeda RAG backend (POST /ask).
// -----------------------------------------------------------------------------
//  Returns the FULL 7-section feed (answer + meaning + actions + pointer
//  sections). Graceful: on ANY problem (server down, no network, timeout, bad
//  response) it returns null, and the screen shows a "connect to the internet"
//  state instead of the retired offline answer.
// =============================================================================

import '../life_stage_store.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../ask_veda_config.dart';
import '../profile_analytics.dart';

/// One pointer card in a section — enough to display AND deep-link it.
class VedaFeedItem {
  const VedaFeedItem({
    required this.docId,
    required this.kind,
    required this.title,
    this.sourceTable,
    this.sourceId,
    this.url,
    this.snippet,
    this.body,
  });

  final String docId; // the app's own id (e.g. cani_papaya, ppprod_stroller)
  final String? kind; // read | product | expert | video | canI | …
  final String title;
  final String? sourceTable; // veda_knowledge | articles | content_posts
  final String? sourceId;
  final String? url;
  final String? snippet;
  final String? body; // full text for content items (reader shows this)

  static VedaFeedItem fromJson(Map<String, dynamic> j) => VedaFeedItem(
        docId: (j['doc_id'] ?? j['source_id'] ?? '').toString(),
        kind: j['kind'] as String?,
        title: (j['title'] ?? '') as String,
        sourceTable: j['source_table'] as String?,
        sourceId: j['source_id'] as String?,
        url: j['url'] as String?,
        snippet: j['snippet'] as String?,
        body: j['body'] as String?,
      );
}

/// The full response — the 7-section feed for one question.
class AskVedaResult {
  const AskVedaResult({
    required this.answer,
    required this.meaning,
    required this.actions,
    required this.content,
    required this.videos,
    required this.products,
    required this.services,
    required this.source,
    required this.cacheHit,
    this.usedContext = const [],
  });

  final String answer; // S1
  final String meaning; // S2
  final List<String> actions; // S3
  final List<VedaFeedItem> content; // S4 (More information)
  final List<VedaFeedItem> videos; // S4 (Videos sub-section)
  final List<VedaFeedItem> products; // S6
  final List<VedaFeedItem> services; // S7

  /// llm | cache:exact | cache:semantic | red_flag | web | low_confidence | …
  final String source;
  final bool cacheHit;

  /// The child's context the service SAYS it wrote this answer with
  /// ('corrected_age' and the ids of [AskVedaService.ask]'s familySignals and
  /// childConditions; PP 6, 2026-10-29). The screen's "Answered with what you
  /// told us" line reads this, not what was sent, so a service that has not
  /// been redeployed never makes the app claim something it did not do.
  final List<String> usedContext;

  /// A real, useful answer (grounded / cached / web / safety) — worth showing.
  /// A low-confidence / limit response is not.
  bool get isConfident =>
      source == 'llm' ||
      source.startsWith('cache') ||
      source == 'web' ||
      source == 'red_flag';

  static List<VedaFeedItem> _items(dynamic list) => (list as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(VedaFeedItem.fromJson)
      .toList();
}

/// The parenting side's `family_stage` (F8, 2026-10-25): her own stage when
/// it is not parenting, else null. A pregnancy that has ended is not one she
/// is in, so it sends nothing. Pure, for the tests.
String? askVedaFamilyStage(LifeStage? stage, bool pregnancyEnded) => switch (stage) {
      LifeStage.pregnancy => pregnancyEnded ? null : 'pregnancy',
      LifeStage.tryingToConceive => 'trying',
      _ => null,
    };

class AskVedaService {
  AskVedaService._();

  /// Ask a question. Returns the full feed, or null on any failure.
  ///
  /// The stage fields are CONTEXT (right tense + cache bucket), never a filter —
  /// one mother, one journey; she can ask about any stage.
  static Future<AskVedaResult?> ask(
    String question, {
    int? week,
    String? trimester,
    int? childAgeMonths,
    // --- trying to conceive (all framing-only, never a filter) ---
    String? stage, // trying | pregnancy | parenting
    String? chapter, // preparingTogether … aNewBeginning
    /// PRIVACY: her cycle day must NEVER be sent from the PARTNER's account.
    /// The data model deliberately keeps ttc_cycles own-row so he cannot read
    /// her cycle; sending it from his device would route around that rule on
    /// the client side. From his account pass [chapter] only.
    int? cycleDay,

    /// What placed her fertile days this cycle (T2, 2026-10-29): 'lh' (a
    /// positive ovulation test) or 'temperature' (a sustained rise); null for
    /// her period dates. A closed id, read by the service's
    /// `WINDOW_SOURCES` (app/prompt.py) for the framing and the cache key.
    /// Same privacy rule as [cycleDay]: never from the partner's account.
    String? windowSource,
    String? ttcPath, // natural | ovulationInduction | iui | ivf | …

    /// WHO owns the timing of this cycle: parentveda | clinic_guided |
    /// clinic_controlled. More decisive than [ttcPath] and the field the
    /// service should branch its framing on — the same treatment behaves in
    /// opposite ways depending on whether a clinic is monitoring it, so
    /// "she is on IVF" is a weaker signal than "her clinic owns the timing".
    ///
    /// Still framing, never a filter: she can ask anything from any pathway.
    String? timingOwnership,

    /// Where a clinic round stands today: a `TtcRoundPhase` name (waiting,
    /// testDay, result, …). Decides whether the service tells the model she is
    /// not pregnant, does not know yet, or has just had a positive test. Send
    /// it only while a clinic owns the cycle, and NEVER from the partner's
    /// account (same rule as [cycleDay]).
    String? treatmentStep,

    /// What she has already covered in the Pre-pregnancy checklist, and what
    /// she has flagged to ask a doctor about: `{covered: [item ids], flagged:
    /// [item ids]}`. IDS ONLY, never her notes or any free text. Framing
    /// only: so an answer does not tell her to start what she already has
    /// started, and can say a flagged item is worth raising with her doctor.
    /// Her own device only, NEVER the partner's (the checklist is hers).
    ///
    /// ⚠️ TWO-REPO FIELD (2026-10-01). Sending it alone does nothing: the
    /// service must declare `ttc_checklist` and use it. See
    /// `docs/ASKVEDA-CHECKLIST-HANDOVER.md` for the field's shape and what the
    /// service should do. Until then this half is inert (the service logs the
    /// unknown field).
    Map<String, List<String>>? ttcChecklist,
    int? monthsTrying,
    /// 'en' | 'hi' — which language's content cards to show (bilingual content
    /// is stored as an English doc plus a Hinglish twin).
    String? lang,
    String? domain, // optional retrieval hint; normally left null (no gating)
    String? userKey,

    /// She has told the app her pregnancy has ended (STAGE-TRANSITIONS R3,
    /// 2026-10-25). Send it INSTEAD of [week]: the service then frames the
    /// answer with no weeks, no baby growing and no birth to get ready for,
    /// and keeps its cache entries apart. Two-repo field, landed in both
    /// (parentveda-askveda `pregnancy_ended`, tests/test_family_and_loss.py).
    bool? pregnancyEnded,

    /// On the parenting side, HER OWN stage when it is not parenting:
    /// 'pregnancy' (pregnant again) or 'trying' (trying for another baby).
    /// The child's age alone made the service say "she is no longer
    /// pregnant" (STAGE-TRANSITIONS F8, 2026-10-25). Two-repo field, landed in
    /// both (`family_stage`).
    String? familyStage,

    /// She is pregnant again, or trying again, after a pregnancy loss she
    /// RECORDED here (`PregnancyRecords`, STILL-OPEN §61.1, 2026-10-26). The
    /// service keeps her week or cycle note and adds gentle framing (no
    /// congratulations, room for worry, never a probability), with cache
    /// entries of its own. ⚠️ Never from her onboarding "gentle" answer: that
    /// stays in the app (the user, 2026-10-17). Two-repo field, landed in both
    /// (parentveda-askveda `previous_loss`, tests/test_previous_loss.py).
    bool? previousLoss,

    /// PARENTING, the child's context (PP 6, 2026-10-29). The age by the due
    /// date for a baby born early, sent NEXT TO [childAgeMonths] (the birthday
    /// age, which vaccines follow); then closed lists of ids, never prose and
    /// never a name (see `PpAskVedaContext`). Two-repo fields, landed in both
    /// (parentveda-askveda `child_age_corrected_months`, `family_signals`,
    /// `child_conditions`, tests/test_child_context.py). Inert until the
    /// service is redeployed; the old one logs them as ignored.
    int? childAgeCorrectedMonths,
    List<String>? familySignals,
    List<String>? childConditions,
  }) async {
    if (!AskVedaConfig.enabled) return null;
    final q = question.trim();
    if (q.isEmpty) return null;
    // Who is asking (2026-10-08). No screen passes a key, so every phone used
    // to arrive as the service's shared fallback 'dev-user', and the 20 a day
    // limit was 20 a day for EVERYONE together. The persisted install id is
    // random, names no one, and is already what analytics counts per mother.
    // Spoofable, yes: a determined caller can change it. The global spend cap
    // on the service is the backstop for that, not this.
    final installId = ProfileAnalytics.instance.installId;
    final key = userKey ?? (installId == 'pending' ? null : 'install:$installId');

    try {
      final res = await http
          .post(
            Uri.parse('${AskVedaConfig.baseUrl}/ask'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              if (key != null) 'X-User-Key': key,
            },
            body: jsonEncode(<String, dynamic>{
              'question': q,
              if (week != null) 'week': week,
              if (trimester != null) 'trimester': trimester,
              if (childAgeMonths != null) 'child_age_months': childAgeMonths,
              if (stage != null) 'stage': stage,
              if (chapter != null) 'chapter': chapter,
              if (cycleDay != null) 'cycle_day': cycleDay,
              'window_source': ?windowSource,
              if (ttcPath != null) 'ttc_path': ttcPath,
              if (timingOwnership != null) 'timing_ownership': timingOwnership,
              if (treatmentStep != null) 'treatment_step': treatmentStep,
              if (ttcChecklist != null) 'ttc_checklist': ttcChecklist,
              if (monthsTrying != null) 'months_trying': monthsTrying,
              if (lang != null) 'lang': lang,
              if (domain != null) 'domain': domain,
              if (pregnancyEnded == true) 'pregnancy_ended': true,
              'family_stage': ?familyStage,
              if (previousLoss == true) 'previous_loss': true,
              'child_age_corrected_months': ?childAgeCorrectedMonths,
              if (familySignals != null && familySignals.isNotEmpty)
                'family_signals': familySignals,
              if (childConditions != null && childConditions.isNotEmpty)
                'child_conditions': childConditions,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode != 200) return null;
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final answer = (map['answer'] as String?)?.trim();
      if (answer == null || answer.isEmpty) return null;

      return AskVedaResult(
        answer: answer,
        meaning: (map['meaning'] as String?)?.trim() ?? '',
        actions: (map['actions'] as List? ?? const [])
            .map((e) => e.toString())
            .where((s) => s.trim().isNotEmpty)
            .toList(),
        content: AskVedaResult._items(map['content']),
        videos: AskVedaResult._items(map['videos']),
        products: AskVedaResult._items(map['products']),
        services: AskVedaResult._items(map['services']),
        source: (map['source'] as String?) ?? 'unknown',
        cacheHit: (map['cache_hit'] as bool?) ?? false,
        usedContext: [
          for (final e in (map['used_context'] as List? ?? const []))
            e.toString(),
        ],
      );
    } catch (_) {
      // Network off, server down, timeout, malformed body → screen shows offline state.
      return null;
    }
  }
}

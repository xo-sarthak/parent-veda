// =============================================================================
//  AskVedaService — calls the AskVeda RAG backend (POST /ask).
// -----------------------------------------------------------------------------
//  Returns the FULL 7-section feed (answer + meaning + actions + pointer
//  sections). Graceful: on ANY problem (server down, no network, timeout, bad
//  response) it returns null, and the screen shows a "connect to the internet"
//  state instead of the retired offline answer.
// =============================================================================

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../ask_veda_config.dart';

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
    String? domain, // optional retrieval hint; normally left null (no gating)
    String? userKey,
  }) async {
    if (!AskVedaConfig.enabled) return null;
    final q = question.trim();
    if (q.isEmpty) return null;

    try {
      final res = await http
          .post(
            Uri.parse('${AskVedaConfig.baseUrl}/ask'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              if (userKey != null) 'X-User-Key': userKey,
            },
            body: jsonEncode(<String, dynamic>{
              'question': q,
              if (week != null) 'week': week,
              if (trimester != null) 'trimester': trimester,
              if (childAgeMonths != null) 'child_age_months': childAgeMonths,
              if (domain != null) 'domain': domain,
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
      );
    } catch (_) {
      // Network off, server down, timeout, malformed body → screen shows offline state.
      return null;
    }
  }
}

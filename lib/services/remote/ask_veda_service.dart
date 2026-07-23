// =============================================================================
//  AskVedaService — calls the AskVeda RAG backend (POST /ask).
// -----------------------------------------------------------------------------
//  Local-first + graceful, matching the SupabaseRepo convention in this folder:
//  every call is guarded and, on ANY problem (server down, no network, timeout,
//  bad response), returns null so the caller falls back to the offline engine.
//  The app therefore never breaks because of this service — it only gets a
//  grounded answer when the backend is reachable and confident.
// =============================================================================

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../ask_veda_config.dart';

/// One answer from the AskVeda backend.
class AskVedaResult {
  const AskVedaResult({required this.answer, required this.source, required this.cacheHit});

  final String answer;

  /// How the backend produced it: llm | cache:exact | cache:semantic | red_flag |
  /// low_confidence | rate_limited | spend_capped. The caller uses this to decide
  /// whether it's worth showing (e.g. don't replace a good offline answer with a
  /// "low_confidence" decline).
  final String source;
  final bool cacheHit;

  /// True when this is a real, useful answer worth showing in place of the
  /// offline one: a grounded generation, a cache hit, or a safety (red-flag)
  /// routing. A "low_confidence"/limit response is NOT worth swapping in.
  bool get isConfident =>
      source == 'llm' || source.startsWith('cache') || source == 'red_flag';
}

class AskVedaService {
  AskVedaService._();

  /// Ask a question. Returns null on any failure (→ caller keeps the offline answer).
  /// Ask a question.
  ///
  /// The stage fields (`week` / `trimester` / `childAgeMonths`) are CONTEXT, not a
  /// filter: the backend uses them to frame the answer in the right tense (and to
  /// bucket its cache). One mother, one continuous journey — she can ask about any
  /// stage and still get an answer, phrased for where she is today.
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
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) return null;
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final answer = (map['answer'] as String?)?.trim();
      if (answer == null || answer.isEmpty) return null;

      return AskVedaResult(
        answer: answer,
        source: (map['source'] as String?) ?? 'unknown',
        cacheHit: (map['cache_hit'] as bool?) ?? false,
      );
    } catch (_) {
      // Network off, server down, timeout, malformed body → fall back to offline.
      return null;
    }
  }
}

// =============================================================================
//  SupabaseProfileSink - sends progressive-profiling analytics to Supabase
// -----------------------------------------------------------------------------
//  The real implementation of ProfileAnalyticsSink. It lives HERE, in the
//  remote layer, rather than in profile_analytics.dart, on purpose: the
//  analytics engine must not know or care what backend it feeds. Swapping this
//  for a Segment/BigQuery sink later touches this file and one wiring line, and
//  nothing else.
//
//  Wiring (main.dart, once at startup, covers BOTH sides of the app):
//      ProfileAnalytics.instance.setSink(SupabaseProfileSink());
//
//  Contract this must honour (there is a test for it): analytics may NEVER
//  break a mother's session. record() is fire-and-forget and cannot throw -
//  SupabaseRepo.fireEvent swallows every error, sync or async.
// =============================================================================

import '../profile_analytics.dart';
import 'supabase_repo.dart';

class SupabaseProfileSink implements ProfileAnalyticsSink {
  const SupabaseProfileSink();

  static const String _table = 'profile_events';

  @override
  void record(
    ProfileAnalyticsRecord record, {
    required String sessionId,
    required String installId,
  }) {
    // toMap already emits the column names profile_events uses (0028), so this
    // is a straight insert - no mapping layer, exactly as the spec intended.
    final row = record.toMap(sessionId: sessionId, installId: installId);

    // Drop `meta`: the table has no such column, and more to the point `meta`
    // is a free-form map, whereas this table stores enum labels only - keeping
    // it out is what guarantees no free text can leak in (PERSONALIZATION s10).
    row.remove('meta');

    SupabaseRepo.fireEvent(_table, row);
  }
}

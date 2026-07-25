// =============================================================================
//  SupabaseMemorySink - sends Memories funnel events to Supabase
// -----------------------------------------------------------------------------
//  Writes into the EXISTING analytics table, profile_events (migration 0028).
//  No new table, no new migration, no second vendor: that table was built as a
//  dumb, insert-only, anonymous event log, and its `event` column is explicitly
//  open-ended ("stripShown | stripAnswered | completenessSnapshot | ..."), so a
//  second feature's funnel belongs there rather than in a table of its own.
//
//  Rows are tagged `surface = 'memories'` and every event name is prefixed
//  `memory`, so Memories events can never be mistaken for - or pollute the rates
//  derived from - the progressive-profiling events that share the table.
//
//  Anonymous by design, inherited from 0028: install_id + session_id, NO
//  user_id. install_id is a random per-install id, so "how many parents made a
//  card" is answerable without the client ever sending an identity.
//
//  Same contract as SupabaseProfileSink: fire-and-forget, cannot throw.
//  SupabaseRepo.fireEvent swallows every error, sync or async.
// =============================================================================

import '../../memories/memory_analytics.dart';
import '../profile_analytics.dart';
import 'supabase_repo.dart';

class SupabaseMemorySink implements MemoryAnalyticsSink {
  const SupabaseMemorySink();

  static const String _table = 'profile_events';
  static const String _surface = 'memories';

  @override
  void record(MemoryAnalyticsRecord record) {
    // install/session ids are owned by ProfileAnalytics - one identity story for
    // the whole app rather than a second one just for this feature. Events fired
    // before its init() resolves carry installId 'pending', which is accurate.
    final ids = ProfileAnalytics.instance;

    SupabaseRepo.fireEvent(_table, {
      'install_id': ids.installId,
      'session_id': ids.sessionId,
      // 'memoryStarted', 'memoryTemplateSelected', ...
      'event': 'memory${_capitalise(record.event.name)}',
      // The milestone, where the event has one (started / photoAdded).
      'field': record.type,
      // The template, where the event has one. `destination` is a single fixed
      // label today, so nothing is lost by preferring the template id - the far
      // more useful signal (which of the 16 templates parents actually pick).
      'value': record.templateId ?? record.destination,
      'surface': _surface,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  static String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

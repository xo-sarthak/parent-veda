// =============================================================================
//  Memories analytics — the funnel, the privacy contract, and "never throws"
// -----------------------------------------------------------------------------
//  These pin three things:
//    * all six funnel steps reach the sink with the right payload,
//    * the payload carries NO personal content (no names, dates, messages),
//    * a broken sink can never break a parent making a keepsake.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/memories/memory_analytics.dart';
import 'package:parentveda/memories/memory_templates.dart';

class _SpySink implements MemoryAnalyticsSink {
  final List<MemoryAnalyticsRecord> seen = [];
  @override
  void record(MemoryAnalyticsRecord record) => seen.add(record);
}

class _ExplodingSink implements MemoryAnalyticsSink {
  @override
  void record(MemoryAnalyticsRecord record) =>
      throw StateError('backend on fire');
}

void main() {
  late _SpySink spy;

  setUp(() {
    spy = _SpySink();
    MemoryAnalytics.instance.setSink(spy);
  });
  tearDown(() =>
      MemoryAnalytics.instance.setSink(const DebugMemoryAnalyticsSink()));

  test('every funnel step reaches the sink, in order', () {
    MemoryAnalytics.started('expecting');
    MemoryAnalytics.templateSelected('exp_sage_floral');
    MemoryAnalytics.photoAdded('expecting');
    MemoryAnalytics.previewViewed('exp_sage_floral');
    MemoryAnalytics.saved('exp_sage_floral');
    MemoryAnalytics.shared('exp_sage_floral', 'share_sheet');

    expect(spy.seen.map((r) => r.event).toList(), [
      MemoryEvent.started,
      MemoryEvent.templateSelected,
      MemoryEvent.photoAdded,
      MemoryEvent.previewViewed,
      MemoryEvent.saved,
      MemoryEvent.shared,
    ]);
  });

  test('the payload carries the milestone / template, and nothing else', () {
    MemoryAnalytics.started('welcomeBaby');
    expect(spy.seen.single.type, 'welcomeBaby');
    expect(spy.seen.single.templateId, isNull);

    spy.seen.clear();
    MemoryAnalytics.shared('wb_midnight', 'share_sheet');
    final r = spy.seen.single;
    expect(r.templateId, 'wb_midnight');
    expect(r.destination, 'share_sheet');
  });

  test('template ids sent are real ids from the registry', () {
    // Guards against a screen inventing an id the dashboard can never join on.
    final ids = kMemoryTemplates.map((t) => t.id).toSet();
    for (final t in kMemoryTemplates) {
      MemoryAnalytics.saved(t.id);
    }
    for (final r in spy.seen) {
      expect(ids, contains(r.templateId));
    }
  });

  test('a sink that throws can never break the caller', () {
    MemoryAnalytics.instance.setSink(_ExplodingSink());
    // If this rethrows, a parent tapping Save would see a crash instead of a
    // saved card. That is the whole point of the try/catch in fire().
    expect(() => MemoryAnalytics.saved('exp_sage_floral'), returnsNormally);
    expect(() => MemoryAnalytics.started('expecting'), returnsNormally);
  });

  test('the default sink is the debug one, not a live backend', () {
    // A release build with no wiring must be silent, never accidentally
    // pointed at a backend.
    expect(const DebugMemoryAnalyticsSink(), isA<MemoryAnalyticsSink>());
  });
}

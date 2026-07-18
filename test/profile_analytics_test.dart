// =============================================================================
//  Profile analytics — can the data actually answer the questions we ask of it?
// -----------------------------------------------------------------------------
//  These tests are written against the SIX METRICS in the product prompt, not
//  against the implementation. Each one asks: given this event stream, could a
//  human compute the metric? That is the only thing that makes analytics worth
//  carrying — a stream nobody can compute anything from is just noise on disk.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/profile_analytics.dart';

void main() {
  final a = ProfileAnalytics.instance;

  setUp(a.clearRecent);

  group('the record carries what every metric needs', () {
    test('every event is stamped, in UTC', () {
      final r = ProfileAnalyticsRecord(event: ProfileEvent.stripShown);
      expect(r.at.isUtc, isTrue,
          reason: 'a tester in another timezone would corrupt any ordering');
    });

    test('the human-readable clock is local, for reading the stream by eye', () {
      final r = ProfileAnalyticsRecord(
          event: ProfileEvent.stripShown,
          at: DateTime.utc(2026, 1, 1, 9, 5, 3));
      expect(r.clock, matches(r'^\d\d:\d\d:\d\d$'));
    });

    test('a session id groups one sitting, an install id spans launches', () {
      expect(a.sessionId, isNotEmpty);
      expect(a.installId, isNotEmpty);
      // Without BOTH, a completion rate cannot be counted per mother rather
      // than per view — the difference between a number and a guess.
      expect(a.sessionId, isNot(a.installId));
    });

    test('ids are random, never a hardware identifier', () {
      // 12 hex chars. If this ever starts looking like an ANDROID_ID or an
      // IMEI, that is a privacy regression, not a refactor.
      expect(a.sessionId, matches(r'^[a-f0-9]{12}$'));
    });

    test('the wire format carries ids and an ISO timestamp', () {
      final m = ProfileAnalyticsRecord(
        event: ProfileEvent.stripAnswered,
        field: 'diet',
        value: 'Jain',
        surface: 'tools_hub',
      ).toMap(sessionId: 'sess', installId: 'inst');
      expect(m['event'], 'stripAnswered');
      expect(m['session_id'], 'sess');
      expect(m['install_id'], 'inst');
      expect(m['at'], isA<String>());
      expect(m['surface'], 'tools_hub');
    });
  });

  group('the six metrics are computable', () {
    test('SKIP RATE — an explicit dismissal is distinguishable', () {
      a.stripShown('pregHealth', 'tools_hub');
      a.stripDismissed('pregHealth', 'tools_hub');
      expect(a.recent.any((e) => e.contains('stripDismissed')), isTrue);
    });

    test('COMPLETION RATE — answers carry the value chosen', () {
      a.stripAnswered('diet', 'tools_hub', 'Jain');
      expect(a.recent.first, contains('stripAnswered'));
      expect(a.recent.first, contains('Jain'));
    });

    test('ABANDONMENT — leaving without acting is its own event', () {
      a.stripAbandoned('pregHealth', 'weight_tracker');
      expect(a.recent.first, contains('stripAbandoned'));
      // Previously this was indistinguishable from the strip never rendering.
      expect(a.recent.first, contains('weight_tracker'));
    });

    test('COMPLETENESS OVER TIME — snapshots carry a percent', () {
      a.completeness(40);
      expect(a.recent.first, contains('40%'));
    });

    test('MOST-UPDATED FIELDS — field changes are recorded', () {
      a.fieldUpdated('diet', 'vegetarian');
      expect(a.recent.first, contains('fieldUpdated'));
      expect(a.recent.first, contains('diet'));
    });

    test('BAD PLACEMENT vs BAD QUESTION — same field, two surfaces', () {
      a.stripShown('pregHealth', 'symptom_companion');
      a.stripShown('pregHealth', 'weight_tracker');
      expect(a.recent.any((e) => e.contains('symptom_companion')), isTrue);
      expect(a.recent.any((e) => e.contains('weight_tracker')), isTrue);
    });
  });

  group('the counts stay honest', () {
    test('a completed multi-select is done, not a skip', () {
      a.stripDismissed('pregPriorities', 'tools_hub', afterPicking: true);
      expect(a.recent.first, contains('stripDone'));
      expect(a.recent.first, isNot(contains('stripDismissed')),
          reason: 'counting a finished multi-select as a skip would corrupt '
              'the skip rate');
    });

    test('newest first, and the buffer is bounded', () {
      for (var i = 0; i < 250; i++) {
        a.stripShown('f$i', 'surface');
      }
      expect(a.recent.length, lessThanOrEqualTo(200));
      expect(a.recent.first, contains('f249'));
    });

    test('clearing empties the buffer', () {
      a.stripShown('pregHealth', 'tools_hub');
      expect(a.recent, isNotEmpty);
      a.clearRecent();
      expect(a.recent, isEmpty);
    });
  });

  // Last: it permanently swaps the sink on the singleton.
  test('a throwing sink never breaks a session', () {
    a.setSink(_ThrowingSink());
    expect(() => a.stripShown('pregHealth', 'tools_hub'), returnsNormally,
        reason: 'analytics must never cost a mother her session');
  });
}

class _ThrowingSink implements ProfileAnalyticsSink {
  @override
  void record(ProfileAnalyticsRecord record,
          {required String sessionId, required String installId}) =>
      throw StateError('boom');
}

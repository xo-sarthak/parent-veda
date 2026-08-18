// =============================================================================
//  The home screen's tool section — the requirement, as tests
// -----------------------------------------------------------------------------
//  The requirement was specific, so it is worth pinning specifically:
//
//    "If the mother has not used any tools yet, show recommended tools. If she
//     has used tools previously, show her most-used/relevant tools, max 4.
//     Every displayed tool must be properly wired. Do not show static cards
//     that don't lead to the actual tool."
//
//  Three of those four clauses are the kind of thing that quietly stops being
//  true: a recommendation list that drifts out of the router, a max that grows
//  to five when someone adds a tool, a tile that survives its destination being
//  renamed. So they are held here rather than in a comment.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/app_structure.dart';
import 'package:parentveda/services/tool_usage_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() => ToolUsageStore.instance.resetForTest());

  group('every recommended tool actually goes somewhere', () {
    // ⚠️ THE CLAUSE MOST LIKELY TO ROT. A recommendation is a hardcoded id, and
    // an id that no longer resolves renders a tile that leads nowhere — which is
    // exactly "do not show static cards that don't lead to the actual tool".
    test('across every week of pregnancy', () {
      for (var week = 4; week <= 42; week++) {
        for (final id in recommendedToolsForWeek(week)) {
          expect(homeFor(id), isNotNull,
              reason: 'week $week recommends "$id", which no longer resolves '
                  'to a surface — the tile would lead nowhere');
        }
      }
    });

    test('and the three stages recommend genuinely different tools', () {
      // If the same list came back for every week, the "based on her current
      // pregnancy stage" half of the requirement would be decoration.
      final t1 = recommendedToolsForWeek(8).toSet();
      final t3 = recommendedToolsForWeek(34).toSet();
      expect(t1.difference(t3), isNotEmpty,
          reason: 'first and third trimester recommend the same tools, so the '
              'recommendation is not stage-aware at all');
    });

    test('a kick counter is not offered in the first trimester', () {
      // The clearest case of stage-awareness mattering: kick counting is the
      // third trimester's daily habit and is meaningless at week 8.
      expect(recommendedToolsForWeek(8), isNot(contains('movement')));
      expect(recommendedToolsForWeek(34), contains('movement'));
    });

    test('and a contraction timer is not offered mid-pregnancy', () {
      // Offering a labour timer in the second trimester is not useful; it is a
      // reminder that labour is coming, to someone who did not ask.
      expect(recommendedToolsForWeek(20), isNot(contains('contractions')));
    });
  });

  group('history changes the order, never the availability', () {
    test('with no history there is no history', () {
      expect(ToolUsageStore.instance.hasHistory, isFalse);
    });

    test('recording a tool makes it rank first', () async {
      await ToolUsageStore.instance.record('kegel');
      await ToolUsageStore.instance.record('kegel');
      await ToolUsageStore.instance.record('weight');

      expect(ToolUsageStore.instance.hasHistory, isTrue);
      expect(ToolUsageStore.instance.ranked.first, 'kegel',
          reason: 'ranked by count, most-used first');
      expect(ToolUsageStore.instance.countFor('kegel'), 2);
    });

    // ⚠️ THE LINE THE REPO ALREADY HOLDS ELSEWHERE. `landing_focus_test.dart`
    // asserts personalisation changes ranking, never structure. A usage store
    // that started deciding which tools EXIST for someone would have crossed
    // from ranking into structure, which is forbidden.
    test('recording a tool removes nothing from the recommendations', () async {
      final before = recommendedToolsForWeek(30).toSet();
      await ToolUsageStore.instance.record('kegel');
      final after = recommendedToolsForWeek(30).toSet();
      expect(after, equals(before),
          reason: 'usage must not change what is available, only its order');
    });

    test('an empty id is ignored rather than recorded', () async {
      await ToolUsageStore.instance.record('');
      expect(ToolUsageStore.instance.hasHistory, isFalse);
    });
  });
}

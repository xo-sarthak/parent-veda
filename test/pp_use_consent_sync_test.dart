// =============================================================================
//  "Ask once" answers sync (tools pass T0, 2026-10-25, the user's word)
// -----------------------------------------------------------------------------
//  PpUseConsent rides the step-13 per-item merge. This plays the server the
//  way test/cloud_merged_store_test.dart does: her yes lands on the server as
//  one item under `pp_use_consent:items`, and what the server holds comes
//  back as her answer, so a new phone does not ask her again.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/pp_use_consent.dart';
import 'package:parentveda/services/remote/cloud_merged_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Map<String, dynamic>> server;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    server = {};
    CloudMergeIo.isLoggedIn = () => true;
    CloudMergeIo.nowMs = () => 1000000;
    CloudMergeIo.loadLegacy = (k) async => null;
    CloudMergeIo.merge = (key, items) async {
      server[key] = MergedItems.merge(server[key] ?? {}, items, nowMs: 1000000);
      return Map<String, dynamic>.from(server[key]!);
    };
  });
  tearDown(CloudMergeIo.restore);

  test('her answer goes up as one item per kind, and comes back down', () async {
    final c = PpUseConsent.instance;
    await c.init();
    c.set(PpUseKind.feeds, true);
    await Future<void>.delayed(Duration.zero);
    final items = server['pp_use_consent:items'];
    expect(items, isNotNull, reason: 'merged under the store key');
    expect(items!['feeds']!['v'], 'yes');

    // What another phone would apply after its merge.
    c.applyCloudItems({'feeds': 'no'});
    expect(c.answerFor(PpUseKind.feeds), PpUseAnswer.no);
    c.applyCloudItems({});
    expect(c.unasked(PpUseKind.feeds), isTrue, reason: 'no item means never asked');
  });
}

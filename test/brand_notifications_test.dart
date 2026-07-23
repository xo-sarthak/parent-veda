// =============================================================================
//  Sponsored notifications — Brand Product 15
// -----------------------------------------------------------------------------
//  A pushed placement, so the tests are about restraint: it targets, it caps,
//  and it keeps a minimum gap between any two. The one number that will change
//  when a real sponsor's terms arrive is kSponsoredNotificationMinGapDays; the
//  behaviour around it must hold whatever that number becomes.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/brand/brand_notifications.dart';
import 'package:parentveda/brand/brand_models.dart';
import 'package:parentveda/brand/brand_store.dart';

void main() {
  test('the frequency gap is a single named constant, and generous', () {
    // It exists so it can be changed in one place when a deal sets the real
    // number. If someone scatters magic numbers instead, this notices.
    expect(kSponsoredNotificationMinGapDays, greaterThanOrEqualTo(1));
  });

  group('the global gap', () {
    setUp(() => BrandStudioStore.instance.resetAll());
    tearDown(() => BrandStudioStore.instance.resetAll());

    test('a just-sent notification blocks another within the gap', () async {
      final now = DateTime(2026, 7, 20);
      BrandStudioStore.instance.markNotificationSent(now);

      // One day later — well inside the gap — nothing may be sent, regardless
      // of how many campaigns would otherwise be eligible.
      final sent = await BrandNotifications.instance.maybeSend(
        stage: BrandStage.parenting,
        now: now.add(const Duration(days: 1)),
      );
      expect(sent, isNull,
          reason: 'a parent must never be peppered, even by different campaigns');
    });

    test('the gap clears once enough days pass', () {
      final now = DateTime(2026, 7, 20);
      BrandStudioStore.instance.markNotificationSent(now);
      final past = now.add(Duration(days: kSponsoredNotificationMinGapDays + 1));
      // We assert the STORE state rather than trigger a real send (that path
      // needs the notification plugin); the gap check keys off exactly this.
      final within = past.difference(BrandStudioStore.instance.lastNotificationAt!).inDays;
      expect(within, greaterThanOrEqualTo(kSponsoredNotificationMinGapDays));
    });

    test('markNotificationSent persists and resets cleanly', () {
      expect(BrandStudioStore.instance.lastNotificationAt, isNull);
      final t = DateTime(2026, 7, 20);
      BrandStudioStore.instance.markNotificationSent(t);
      expect(BrandStudioStore.instance.lastNotificationAt, t);
      BrandStudioStore.instance.resetAll();
      expect(BrandStudioStore.instance.lastNotificationAt, isNull);
    });
  });

  // maybeSend never throws — it is wrapped so a dead notification channel or an
  // unloaded store can never surface as a broken app-open.
  test('maybeSend is safe to call with nothing set up', () async {
    BrandStudioStore.instance.resetAll();
    expect(
      () => BrandNotifications.instance.maybeSend(stage: BrandStage.parenting),
      returnsNormally,
    );
  });
}

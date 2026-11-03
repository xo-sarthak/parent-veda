// Pee Safe demo, item 8: notifications that lead to a sale. Each resolves only
// on its own audience, "send now" skips the gap and cap only in demo mode, and
// each tap is wired to its real screen (checked against the source).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_campaigns.dart';
import 'package:parentveda/brand/brand_models.dart';
import 'package:parentveda/brand/brand_notifications.dart';
import 'package:parentveda/brand/brand_store.dart';
import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_brand.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_notifications.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_reads.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reco_data.dart';

BrandCampaign _byId(String id) => kBrandCampaigns.firstWhere((c) => c.id == id);

BrandCampaign? _resolve(BrandContext ctx) =>
    BrandStudio.instance.resolve(BrandSlot.sponsoredNotification, ctx);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 11, 2);

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    BrandStudio.instance.allowInTests = true;
    BrandStudio.instance.enabled = true;
    BrandStudio.instance.resetCampaigns();
    BrandStudioStore.instance.resetAll();
  });

  tearDown(() {
    BrandStudioStore.instance.resetAll();
    BrandStudio.instance.allowInTests = false;
  });

  test('three campaigns, own ids, plain titles, disclosed, doctor last', () {
    expect(kPeeSafeNotificationIds.toSet().length, 3);
    for (final id in kPeeSafeNotificationIds) {
      final c = _byId(id);
      expect(c.slot, BrandSlot.sponsoredNotification);
      expect(c.brand.id, kPeeSafe.id);
      expect(c.maxImpressions, 1);
      // No emoji anywhere in a brand notification's title or line.
      final emoji = RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true);
      expect(emoji.hasMatch(c.creative.headline + c.creative.subline), isFalse, reason: id);
    }
    expect(_byId(kPeeSafeNotifPeriId).creative.subline, endsWith('see your doctor.'));
  });

  test('each notification resolves on its own audience, and only there', () {
    final week36 = BrandContext(stage: BrandStage.pregnancy, now: now, pregnancyWeek: 36);
    final week30 = BrandContext(stage: BrandStage.pregnancy, now: now, pregnancyWeek: 30);
    final newborn = BrandContext(stage: BrandStage.parenting, now: now, childAgeMonths: 0);
    final sixMonths = BrandContext(stage: BrandStage.parenting, now: now, childAgeMonths: 6);

    expect(_resolve(week36)?.id, kPeeSafeNotifBagId);
    expect(_resolve(newborn)?.id, kPeeSafeNotifPeriId);
    expect(_resolve(sixMonths)?.id, kPeeSafeNotifTravelId);
    // Outside every audience: nothing.
    expect(_resolve(week30), isNull);
    // And none of them reaches another's parent.
    expect(BrandStudio.instance.isEligible(_byId(kPeeSafeNotifBagId), newborn), isFalse);
    expect(BrandStudio.instance.isEligible(_byId(kPeeSafeNotifPeriId), sixMonths), isFalse);
    expect(BrandStudio.instance.isEligible(_byId(kPeeSafeNotifTravelId), week36), isFalse);
  });

  test('"send now" skips the gap and the cap only in demo mode', () async {
    final store = BrandStudioStore.instance;
    store.markNotificationSent(now); // the gap is fresh
    for (final id in kPeeSafeNotificationIds) {
      store.recordImpression(id); // and every cap is spent
    }

    // Outside demo mode: refused, and the ordinary path is held by the gap.
    expect(BrandStudio.instance.demoMode, isFalse);
    for (final id in kPeeSafeNotificationIds) {
      expect(BrandNotifications.instance.demoSendable(id, now: now), isNull, reason: id);
      expect(await BrandNotifications.instance.sendNow(id), isNull, reason: id);
    }
    expect(
        await BrandNotifications.instance.maybeSend(
            stage: BrandStage.pregnancy, pregnancyWeek: 36, now: now),
        isNull);

    // Demo mode on: each is sendable despite the gap and the spent cap.
    BrandStudio.instance.demoMode = true;
    for (final id in kPeeSafeNotificationIds) {
      expect(BrandNotifications.instance.demoSendable(id, now: now)?.id, id);
    }
    // Only notification campaigns: a non-notification id is refused.
    expect(BrandNotifications.instance.demoSendable(kPeeSafePremiereId, now: now), isNull);
  });

  test('each tap reaches its screen (source + targets exist)', () {
    final opener = File('lib/screens/notification_opener.dart').readAsStringSync();
    expect(opener, contains('openPeeSafeNotification(context, link.id)'));

    final router = File('lib/brand/pee_safe/pee_safe_notifications.dart').readAsStringSync();
    expect(router, contains('case kPeeSafeNotifBagId'));
    expect(router, contains('ReadyForBirthScreen(controller: preg)')); // the live bag (2026-11-03)
    expect(router, contains('case kPeeSafeNotifPeriId'));
    expect(router, contains('openPeeSafeRead(context, kPeeSafeNotifPeriReadId)'));
    expect(router, contains('case kPeeSafeNotifTravelId'));
    expect(router, contains("PvShelfScreen(categoryId: 'on_the_move')")); // the live store (2026-11-03)

    // The targets are real: the read and the reco item exist.
    expect(peeSafeReadById(kPeeSafeNotifPeriReadId), isNotNull);
    expect(kReco.any((r) => r.id == kPeeSafeTravelKey), isTrue);

    // The week reaches the resolver from the pregnancy shell, and the Showcase
    // can send on demand.
    final shell = File('lib/screens/main_scaffold.dart').readAsStringSync().replaceAll('\r\n', '\n');
    expect(shell, contains('pregnancyWeek: widget.pregnancy.currentWeek,\n        );'));
    final showcase = File('lib/screens/brand_showcase_screen.dart').readAsStringSync();
    expect(showcase, contains('BrandNotifications.instance.sendNow(id)'));
  });
}

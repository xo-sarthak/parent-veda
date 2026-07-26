// =============================================================================
//  Referral rewards -> spendable consultation credits
// -----------------------------------------------------------------------------
//  This is the money path. A bug here does not look like a bug - it looks like
//  free consultations - so the tests are written around the ways it could
//  overpay rather than the happy case.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/booking_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final store = BookingStore.instance;

  Offering consult() => BookingCatalog.instance
      .offerings()
      .firstWhere((o) => o.kind == OfferingKind.consult);

  Offering classPack() => BookingCatalog.instance
      .offerings()
      .firstWhere((o) => o.kind == OfferingKind.classPack);

  test('a granted reward becomes a spendable credit on ANY consult', () {
    store.grantFloatingCredit(sourceId: 'r1', title: '1 free consultation');
    final ent = store.activeEntitlementFor(consult().id);
    expect(ent, isNotNull, reason: 'the gift must be spendable');
    expect(ent!.offeringId, kAnyConsultOffering);
    expect(ent.creditsLeft, 1);
  });

  test('the same reward granted twice yields ONE credit, not two', () {
    final a = store.grantFloatingCredit(sourceId: 'dup', title: 'gift');
    final b = store.grantFloatingCredit(sourceId: 'dup', title: 'gift');
    expect(a.id, b.id, reason: 'the id is derived from the reward row id');
    final all = store.entitlements().where((e) => e.id == a.id).toList();
    expect(all.length, 1);
    expect(all.single.creditsTotal, 1);
  });

  test('syncing ten times still grants once — the sync-farm attack', () {
    for (var i = 0; i < 10; i++) {
      store.grantFloatingCredit(sourceId: 'sync', title: 'gift');
    }
    final mine =
        store.entitlements().where((e) => e.id == 'ent_gift_sync').toList();
    expect(mine.length, 1);
    expect(mine.single.creditsLeft, 1);
  });

  test('two DIFFERENT rewards each grant their own credit', () {
    store.grantFloatingCredit(sourceId: 'a1', title: 'gift');
    store.grantFloatingCredit(sourceId: 'a2', title: 'gift');
    final gifts = store
        .entitlements()
        .where((e) => e.offeringId == kAnyConsultOffering && e.canBook)
        .toList();
    expect(gifts.length, greaterThanOrEqualTo(2));
  });

  test('a floating consult credit cannot be spent on a group class', () {
    store.grantFloatingCredit(sourceId: 'r_class', title: 'gift');
    // A class pack is not a consult; the gift must not unlock it.
    final ent = store.activeEntitlementFor(classPack().id);
    expect(ent, isNull,
        reason: 'a free CONSULTATION must not pay for a yoga class');
  });

  test('an unknown offering id never resolves a gift', () {
    store.grantFloatingCredit(sourceId: 'r_unknown', title: 'gift');
    expect(store.activeEntitlementFor('off_does_not_exist'), isNull);
  });

  test('a bought credit is preferred over the gift, leaving the gift intact',
      () {
    final o = consult();
    store.grantFloatingCredit(sourceId: 'keep_me', title: 'gift');
    store.purchase(o);
    final ent = store.activeEntitlementFor(o.id);
    expect(ent!.offeringId, o.id,
        reason: 'spend what she paid for before the gift she was given');
  });

  test('an expired gift is not spendable', () {
    store.grantFloatingCredit(
      sourceId: 'old',
      title: 'gift',
      validFor: const Duration(days: 1),
      at: DateTime.now().toUtc().subtract(const Duration(days: 10)),
    );
    final gifts = store.entitlements().where((e) => e.id == 'ent_gift_old');
    expect(gifts.single.canBook, isFalse);
  });
}

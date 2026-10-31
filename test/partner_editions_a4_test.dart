// Partner Editions A4: a partner offer comes off the price at checkout,
// decided on the server (0149). The phone's half: the quote it reads, the
// struck price only when the server says so, the "Apply offer" list and her
// pick, "Auto-applied" only now that the server path exists, and the wiring
// gate at all three checkout sites.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/offer_quote.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/entitlement_store.dart';
import 'package:parentveda/services/partner_offer_store.dart';
import 'package:parentveda/services/remote/sync_registry.dart';
import 'package:parentveda/widgets/partner_exclusive_rail.dart';
import 'package:parentveda/widgets/partner_offer_checkout.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _src(String path) => File(path).readAsStringSync();

/// Source with whole-line comments removed, so "kept for revert" notes do
/// not count as live code.
String _live(String path) => _src(
  path,
).split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

const _off = 'off_back_to_work';

Map<String, dynamic> _quoteJson({List<Map<String, dynamic>>? offers}) => {
  'known': true,
  'offering_id': _off,
  'list_paise': 50000,
  'offers':
      offers ??
      [
        {
          'code': 'NW100',
          'kind': 'flat',
          'value': 10000,
          'label': 'the back-to-work masterclass',
          'ends_at': null,
          'audience': 'sponsor',
          'saving_paise': 10000,
          'price_paise': 40000,
        },
        {
          'code': 'NW15',
          'kind': 'percent',
          'value': 15,
          'label': 'any masterclass',
          'ends_at': '2026-11-30T18:29:59Z',
          'audience': 'sponsor',
          'saving_paise': 7500,
          'price_paise': 42500,
        },
      ],
  'best_code': 'NW100',
  'best_price_paise': 40000,
};

Future<void> _pumpAt(WidgetTester t, Widget child, {double scale = 1}) async {
  t.view.physicalSize = const Size(360, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(360, 800),
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    ),
  );
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() {
    OfferQuoteStore.instance.debugReset();
    EntitlementStore.instance.setForTest();
    PartnerOfferStore.instance.debugSet(const []);
  });

  group('the quote, as 0149 returns it', () {
    test('parses best first; a row with nothing off is dropped', () {
      final q = OfferQuote.fromJson(
        _quoteJson(
          offers: [
            ..._quoteJson()['offers'] as List<Map<String, dynamic>>,
            {'code': 'ZERO', 'saving_paise': 0, 'price_paise': 50000},
            {'code': 'FREE', 'saving_paise': 50000, 'price_paise': 0},
          ],
        ),
      )!;
      expect(q.listMinor, 50000);
      expect(q.offers.map((o) => o.code), ['NW100', 'NW15']);
      expect(q.bestCode, 'NW100');
      expect(q.offers.first.off, '₹100 off');
      expect(q.offers.last.off, '15% off');
    });

    test('not for her, or unknown, is no quote at all', () {
      expect(OfferQuote.fromJson({'known': false}), isNull);
      expect(OfferQuote.fromJson(null), isNull);
      expect(OfferQuote.fromJson('nonsense'), isNull);
    });

    test('her pick applies if listed, else the best', () {
      final q = OfferQuote.fromJson(_quoteJson())!;
      expect(q.applied(null)!.code, 'NW100');
      expect(q.applied('NW15')!.code, 'NW15');
      expect(q.applied('SOMEONE_ELSES')!.code, 'NW100');
      expect(
        OfferQuote.fromJson(_quoteJson(offers: []))!.applied(null),
        isNull,
      );
    });

    test('rupees: Indian grouping, paise only when there are some', () {
      expect(offerRupees(149900), '₹1,499');
      expect(offerRupees(42500), '₹425');
      expect(offerRupees(7499), '₹74.99');
      expect(offerRupees(1234567800), '₹1,23,45,678');
    });
  });

  group('the store', () {
    test('the pay price follows her pick; no quote, no price', () {
      final s = OfferQuoteStore.instance;
      expect(s.payMinorFor(_off), isNull);
      s.debugSet(OfferQuote.fromJson(_quoteJson())!);
      expect(s.payMinorFor(_off), 40000);
      s.pick(_off, 'NW15');
      expect(s.pickFor(_off), 'NW15');
      expect(s.payMinorFor(_off), 42500);
      expect(partnerOfferPayLabel(_off, '₹500'), '₹425');
      expect(partnerOfferPayLabel('off_other', '₹500'), '₹500');
    });

    test('the sync reset clears any chosen code and every quote', () {
      final s = OfferQuoteStore.instance;
      s.debugSet(OfferQuote.fromJson(_quoteJson())!);
      s.pick(_off, 'NW15');
      SyncRegistry.resetAll();
      expect(s.pickFor(_off), isNull);
      expect(s.quoteFor(_off), isNull);
    });

    test('memory only, registered for the account reset', () {
      final code = _src('lib/booking/offer_quote.dart');
      expect(code, contains('SyncRegistry.registerReset(_resetForAccount)'));
      expect(code, isNot(contains('SharedPreferences')));
      expect(code, contains("'my_offer_quote'"));
    });
  });

  group('the receipt', () {
    Purchase row(int? list, int? disc) => Purchase.fromRow({
      'id': 'pur_1',
      'offering_id': _off,
      'amount_paise': (list ?? 50000) - (disc ?? 0),
      'paid_at': '2026-10-31T10:00:00Z',
      'list_paise': list,
      'discount_paise': disc,
    });

    test('a percent offer reads as a percent, a flat one in rupees', () {
      expect(row(50000, 7500).offerLine, '15% off');
      // 15% of 49,999 paise floors to 7,499, as the server computes it.
      expect(row(49999, 7499).offerLine, '15% off');
      expect(row(49900, 10000).offerLine, '₹100 off');
    });

    test('an old receipt, or one with nothing off, says nothing', () {
      expect(row(null, null).offerLine, isNull);
      expect(row(50000, 0).offerLine, isNull);
      expect(row(null, null).hadOffer, isFalse);
    });
  });

  group('on the checkout sheet', () {
    testWidgets('no quote: no room, nothing struck', (t) async {
      await _pumpAt(t, const PartnerOfferCheckout(offeringId: _off));
      expect(
        find.byKey(const ValueKey('partner_offer_checkout')),
        findsNothing,
      );
      expect(find.text('Apply offer'), findsNothing);
    });

    testWidgets('a quote with no offer: no room either', (t) async {
      OfferQuoteStore.instance.debugSet(
        OfferQuote.fromJson(_quoteJson(offers: []))!,
      );
      await _pumpAt(t, const PartnerOfferCheckout(offeringId: _off));
      expect(
        find.byKey(const ValueKey('partner_offer_checkout')),
        findsNothing,
      );
    });

    for (final scale in [1.0, 1.5]) {
      testWidgets('struck price, the price she pays, the applied line, '
          'at 360pt ${scale}x', (t) async {
        OfferQuoteStore.instance.debugSet(OfferQuote.fromJson(_quoteJson())!);
        await _pumpAt(
          t,
          const PartnerOfferCheckout(offeringId: _off),
          scale: scale,
        );
        expect(t.takeException(), isNull);
        final list = t.widget<Text>(
          find.byKey(const ValueKey('partner_offer_list_price')),
        );
        expect(list.data, '₹500');
        expect(list.style!.decoration, TextDecoration.lineThrough);
        expect(find.text('₹400'), findsOneWidget);
        expect(
          find.text(
            'Partner offer applied · ₹100 off the back-to-work masterclass',
          ),
          findsOneWidget,
        );
        expect(find.text('2 offers'), findsOneWidget);
      });

      testWidgets('Apply offer lists hers, best marked; a pick applies, '
          'at ${scale}x', (t) async {
        OfferQuoteStore.instance.debugSet(OfferQuote.fromJson(_quoteJson())!);
        await _pumpAt(
          t,
          const PartnerOfferCheckout(offeringId: _off),
          scale: scale,
        );
        await t.tap(find.byKey(const ValueKey('partner_offer_apply')));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(
          find.byKey(const ValueKey('partner_offer_option_NW100')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('partner_offer_option_NW15')),
          findsOneWidget,
        );
        expect(find.text('Best'), findsOneWidget);
        await t.tap(find.byKey(const ValueKey('partner_offer_option_NW15')));
        await t.pumpAndSettle();
        expect(OfferQuoteStore.instance.pickFor(_off), 'NW15');
        expect(find.text('₹425'), findsOneWidget);
        expect(
          find.text('Partner offer applied · 15% off any masterclass'),
          findsOneWidget,
        );
      });
    }
  });

  group('the words follow the server', () {
    testWidgets('the rail card says Auto-applied', (t) async {
      EntitlementStore.instance.setForTest(
        sponsor: const SponsorInfo(id: 's1', name: 'Northwind Systems'),
      );
      PartnerOfferStore.instance.debugSet(const [
        PartnerOffer(
          code: 'NW15',
          kind: 'percent',
          value: 15,
          audience: 'sponsor',
          audienceId: 's1',
          label: 'any masterclass',
        ),
      ]);
      await _pumpAt(
        t,
        PartnerExclusiveRail(
          p: V2PaletteStore.instance.current,
          head: (e, h) => Column(children: [Text(e), Text(h)]),
        ),
        scale: 1.5,
      );
      expect(t.takeException(), isNull);
      expect(find.text('Auto-applied · No end date'), findsOneWidget);
    });

    test('"Auto-applied" only with the server function that makes it true', () {
      final m = _src('supabase/migrations/0149_partner_offer_checkout.sql');
      expect(m, contains('create or replace function public.my_offer_quote('));
      expect(
        _live('lib/booking/offer_quote.dart'),
        contains("'my_offer_quote'"),
      );
      expect(
        _live('lib/widgets/partner_exclusive_rail.dart'),
        contains('Auto-applied'),
      );
      expect(
        _live('lib/screens/care_partner/care_welcome_sheet.dart'),
        contains('Applied automatically at checkout'),
      );
    });

    test('Benefits no longer says checkout does not take offers', () {
      final code = _live(
        'lib/screens/enterprise/employer_benefits_screen.dart',
      );
      expect(code, isNot(contains('Checkout does not take offers yet')));
      expect(code, contains('Applied automatically at checkout'));
    });
  });

  group('0149, on the source', () {
    final m = _src('supabase/migrations/0149_partner_offer_checkout.sql');

    test('the quote takes no user; the rule is closed', () {
      expect(
        m,
        contains(
          'create or replace function public.my_offer_quote(p_offering_id text)',
        ),
      );
      expect(
        m,
        contains(
          'grant execute on function public.my_offer_quote(text) to authenticated;',
        ),
      );
      expect(
        m,
        contains(
          'revoke all on function public._offers_for(uuid, text) from public, anon, authenticated;',
        ),
      );
      expect(
        m,
        isNot(contains('grant execute on function public._offers_for')),
      );
    });

    test('quote, order and stub ask the one rule', () {
      expect(
        'public._offers_for('.allMatches(m).length,
        greaterThanOrEqualTo(3),
      );
      expect(
        m,
        contains(
          'drop function if exists public.open_payment_order(uuid, text, text, int, int);',
        ),
      );
      expect(
        m,
        contains('drop function if exists public.record_stub_purchase(text);'),
      );
      // price_offering itself stays unchanged (decision 1).
      expect(m, isNot(contains('function public.price_offering(')));
    });

    test('a use counts in the receipt insert; the expert is unchanged', () {
      expect(m, contains('set redeemed = redeemed + 1'));
      expect(m, isNot(contains('function public.book_slot(')));
      expect(
        m,
        isNot(contains('function public.expert_earning_from_booking(')),
      );
      expect(
        m,
        contains("check (kind <> 'percent' or value between 1 and 99)"),
      );
    });

    test('the Edge Function passes the pick and nothing else new', () {
      final fn = _src('supabase/functions/razorpay-create-order/index.ts');
      expect(fn, contains('p_coupon_code:'));
      expect(fn, contains('couponCode'));
    });

    test('the verify script exists and rolls back', () {
      final v = _src('supabase/seed/verify_partner_offer_checkout.sql');
      expect(v, contains('PARTNER OFFER CHECKOUT VERIFICATION (0149)'));
      expect(v, contains('quote = charge'));
    });
  });

  group('wiring gate', () {
    test(
      'all three checkout sites show the offer and price from the quote',
      () {
        for (final path in [
          'lib/screens/learn/pv_learn_flow.dart',
          'lib/screens/post_pregnancy/booking_sheet.dart',
          'lib/screens/ttc/ttc_prepare_screen.dart',
        ]) {
          final code = _live(path);
          expect(code, contains('PartnerOfferCheckout('), reason: path);
          expect(code, contains('partnerOfferPayLabel('), reason: path);
          expect(code, contains('PaymentService.instance'), reason: path);
        }
      },
    );

    test('her pick reaches the order and the stub', () {
      final pay = _live('lib/booking/payment_service.dart');
      expect(pay, contains("'couponCode': ?couponCode"));
      expect(pay, contains('OfferQuoteStore.instance.pickFor(offering.id)'));
      final store = _live('lib/booking/booking_store.dart');
      expect(store, contains("'p_coupon_code': ?couponCode"));
    });

    test('a receipt with a discount says so', () {
      final code = _live('lib/screens/learn/pv_my_learning_screen.dart');
      expect(code, contains('x.offerLine'));
      expect(code, contains("'Partner offer'"));
    });
  });
}

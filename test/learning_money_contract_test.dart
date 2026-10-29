// =============================================================================
//  L2b money contract — LA-4..LA-15, LA-28 (docs/LEARNING-ARCHITECTURE.md §5)
// -----------------------------------------------------------------------------
//  Like learning_security_contract_test, this reads the LAST definition of each
//  function across the whole migration set, with comment lines stripped, so a
//  later `create or replace` that drops a guard fails here rather than on a
//  parent's phone.
//
//  Four groups:
//    * the seed: the server's prices are the bundled catalogue's prices (L.1);
//    * book_slot and checkout read only server values (LA-4, LA-6, LA-8);
//    * shop orders and the view (LA-13, LA-15);
//    * LA-28: no function is "revoked" from PUBLIC alone.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_learning_data.dart';

List<File> _migrations() => Directory('supabase/migrations')
    .listSync()
    .whereType<File>()
    .where((f) => f.path.endsWith('.sql'))
    .toList()
  ..sort((a, b) => a.path.compareTo(b.path));

String _code(String sql) => sql
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('--'))
    .join('\n');

String _all() => _migrations().map((f) => _code(f.readAsStringSync())).join('\n');

/// The body of the last `create or replace <kind> public.<name>` in the set.
({String file, String body}) _last(String name, {String kind = 'function'}) {
  final head = 'create or replace $kind public.$name';
  String? file;
  String? body;
  for (final f in _migrations()) {
    final code = _code(f.readAsStringSync());
    final at = code.lastIndexOf(head);
    if (at < 0) continue;
    if (kind == 'function') {
      final open = code.indexOf(r'$$', at);
      final close = code.indexOf(r'$$', open + 2);
      body = code.substring(at, close);
    } else {
      body = code.substring(at, code.indexOf(';', at));
    }
    file = f.uri.pathSegments.last;
  }
  if (body == null) fail('no definition of public.$name');
  return (file: file!, body: body);
}

/// The seeded programmes: offering_id -> price_paise, from 0126's VALUES.
Map<String, int> _seed() {
  final sql = File('supabase/migrations/0126_learning_money_and_schedule.sql')
      .readAsStringSync();
  final row = RegExp(r"^\s*\('([^']+)', '([^']+)', '([a-z_]+)', '[a-z]+', '(?:[^']|'')*', (\d+),",
      multiLine: true);
  return {for (final m in row.allMatches(sql)) m.group(2)!: int.parse(m.group(4)!)};
}

int _paise(String label) {
  final m = RegExp(r'[\d,]+').firstMatch(label);
  return m == null ? 0 : int.parse(m.group(0)!.replaceAll(',', '')) * 100;
}

void main() {
  group('L.1 · the server price is the catalogue price', () {
    final seed = _seed();

    test('every bundled offering that is not a consult is seeded at its price', () {
      final sold = BookingCatalog.instance
          .offerings()
          .where((o) => o.kind != OfferingKind.consult)
          .toList();
      expect(sold, isNotEmpty);
      for (final o in sold) {
        expect(seed.containsKey(o.id), isTrue,
            reason: '${o.id} is sold in the app but has no server price (LA-4)');
        expect(seed[o.id], o.priceMinor,
            reason: '${o.id}: the app shows ${o.priceMinor} paise, the server charges '
                '${seed[o.id]}. A price change needs a migration as well as the Dart.');
      }
    });

    test('recorded courses are seeded under the ids L2c will sell them with', () {
      for (final p in kLearningPrograms.where((p) => p.kind == LearningKind.recordedCourse)) {
        expect(seed['off_${p.id}'], _paise(p.price), reason: p.id);
      }
      for (final p in kPrepPrograms.where((p) => p.kind == PrepKind.course)) {
        expect(seed['off_pg_${p.id}'], _paise(p.price), reason: p.id);
      }
    });

    test('the seed is hidden from the app\'s merge, so no card is replaced', () {
      final v = _last('programmes_published', kind: 'view');
      expect(v.body, contains("p.display_source = 'server'"), reason: v.file);
    });
  });

  group('LA-4 / LA-6 / LA-8 · server values only', () {
    test('book_slot prices from price_offering and refuses unpaid in live mode', () {
      final d = _last('book_slot');
      expect(d.body, contains('public.price_offering(p_offering_id)'), reason: d.file);
      expect(d.body, contains("raise exception 'payment required'"), reason: d.file);
      expect(d.body, contains("raise exception 'unknown slot'"), reason: d.file);
      expect(d.body, contains("raise exception 'slot does not belong to this offering'"));
      // The phone's price is read in exactly one place: the stub branch.
      final logic = d.body.substring(d.body.indexOf(r'$$'));
      expect(RegExp(r'p_price_paise').allMatches(logic).length, 1);
      expect(logic, contains("when v_mode = 'stub' then p_price_paise"));
      // The booking's times are the stored slot's.
      expect(logic, contains('v_slot.starts_utc, v_slot.duration_min'));
    });

    test('create-order prices on the server and knows the caller', () {
      final src = File('supabase/functions/razorpay-create-order/index.ts').readAsStringSync();
      expect(src, contains('auth.getUser()'));
      expect(src, contains('"open_payment_order"'));
      expect(src, contains('amount: po.amount_paise'));
      expect(src, isNot(contains('amount: chargeMinor')),
          reason: 'the client amount must never be what Razorpay charges directly');
      expect(src, isNot(contains('deploy razorpay-create-order --no-verify-jwt')));
    });

    test('verify checks the caller owns the order and writes the receipt', () {
      final src = File('supabase/functions/razorpay-verify-payment/index.ts').readAsStringSync();
      expect(src, contains('auth.getUser()'));
      expect(src, contains('po.user_id !== user.id'));
      expect(src, contains('"record_course_purchase"'));
      expect(src, isNot(contains('deploy razorpay-verify-payment --no-verify-jwt')));
    });

    test('the webhook hashes the raw body before parsing it', () {
      final src = File('supabase/functions/razorpay-webhook/index.ts').readAsStringSync();
      final hash = src.indexOf('hmacSha256Hex(WEBHOOK_SECRET, raw)');
      final parse = src.indexOf('JSON.parse(raw)');
      expect(hash, greaterThan(0));
      expect(parse, greaterThan(hash));
      expect(src, contains('x-razorpay-event-id'));
      expect(src, contains('"record_refund"'));
    });

    test('receipts and open orders are written only by the server', () {
      final all = _all();
      for (final f in ['open_payment_order', 'record_course_purchase', 'record_refund']) {
        expect(all, isNot(contains(RegExp('grant execute on function public\\.$f\\([^)]*\\) to [a-z_, ]*authenticated'))),
            reason: '$f must be service_role only');
      }
      expect(all, isNot(contains(RegExp(r'grant [a-z, ]*(insert|update)[a-z, ]* on public\.(course_purchases|payment_orders) to authenticated'))));
    });

    test('live mode honours only live receipts', () {
      expect(_last('has_course_access').body, contains("cp.mode = 'live'"));
      expect(_last('book_slot').body, contains("c.source <> 'stub_purchase'"));
    });
  });

  group('LA-13 / LA-15 · shop orders and every host', () {
    test('a client cannot mark an order paid without a verified payment', () {
      final g = _last('orders_guard_paid');
      expect(g.body, isNot(contains('security definer')),
          reason: 'current_user must be the caller, so the guard sees "authenticated"');
      expect(g.body, contains("new.status := 'placed'"));
      expect(_all(), contains('create unique index if not exists orders_payment_id_key'));
    });

    test('the view lists every host and calls no internal function', () {
      final v = _last('programmes_published', kind: 'view');
      expect(v.body, contains('as hosts'));
      // A view runs its FUNCTIONS with the viewer's execute rights.
      expect(v.body, isNot(contains('_programme_lead_host(')));
    });
  });

  group('a rewrite starts from the LAST definition', () {
    // 0126 first copied publish_programme from 0054 when 0055 had already
    // changed it to return jsonb. Postgres refuses `create or replace` with a
    // new return type, and the copy would also have undone 0055's fix. A
    // changed return type is the cheapest visible sign of a stale copy.
    test('create or replace never changes a function\'s return type', () {
      final head = RegExp(
          r'create or replace function public\.(\w+)\s*\((.*?)\)\s*returns\s+(setof\s+[\w.]+|[\w.]+)',
          dotAll: true);
      final seen = <String, ({String file, String type})>{};
      for (final f in _migrations()) {
        final code = _code(f.readAsStringSync());
        final name = f.uri.pathSegments.last;
        for (final m in head.allMatches(code)) {
          final fn = m.group(1)!;
          final type = m.group(3)!.toLowerCase();
          final before = seen[fn];
          final dropped = RegExp('drop function if exists public\\.$fn\\b')
              .hasMatch(code.substring(0, m.start));
          if (before != null && !dropped) {
            expect(type, before.type,
                reason: '$name redefines public.$fn returning $type, but ${before.file} '
                    'returns ${before.type}. Start from the last definition.');
          }
          seen[fn] = (file: name, type: type);
        }
      }
    });
  });

  group('LA-28 · revoked from PUBLIC is not revoked', () {
    test('every function revoked from public is also closed to anon and authenticated', () {
      final all = _all().replaceAll(RegExp(r'\s+'), ' ');
      final barePublic = RegExp(
          r'revoke (?:all|execute)(?: on function)? public\.(\w+)\s*\([^)]*\) from public;');
      final sweep = RegExp(r"p\.proname = any \(array\[(.*?)\]\)").firstMatch(all);
      expect(sweep, isNotNull, reason: '0126 sweep missing');
      final swept = RegExp(r"'(\w+)'").allMatches(sweep!.group(1)!).map((m) => m.group(1)).toSet();
      for (final m in barePublic.allMatches(all)) {
        final name = m.group(1)!;
        final closedLater = RegExp('revoke (?:all|execute) on function public\\.$name\\s*\\([^)]*\\) from public, anon, authenticated')
            .hasMatch(all);
        final meantForUsers = RegExp('grant (?:all|execute) on function public\\.$name\\s*\\([^)]*\\) to [a-z_, ]*authenticated')
            .hasMatch(all);
        expect(swept.contains(name) || closedLater || meantForUsers, isTrue,
            reason: 'public.$name is revoked from PUBLIC only. On Supabase, anon and '
                'authenticated hold their own EXECUTE grant: write '
                '"from public, anon, authenticated".');
      }
    });
  });
}

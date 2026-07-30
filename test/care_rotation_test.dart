// Retiring a code that is printed on a wall.
//
// A referral token is not a database row — it is ink on paper in a waiting
// room. The moment it stops resolving, every physical copy becomes a dead end
// for a patient standing in front of it. These tests hold the three properties
// that follow from that, all of them in SQL.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final sql = File('supabase/migrations/0069_token_rotation.sql')
      .readAsStringSync();
  final s0068 = File('supabase/migrations/0068_partner_accounts.sql')
      .readAsStringSync();

  group('rotation keeps history rather than rewriting it', () {
    test('the old token is retired, never deleted', () {
      final start = sql.indexOf('function public.rotate_partner_token(');
      expect(start, greaterThan(-1));
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      expect(body.contains('update public.partner_referrals'), isTrue);
      expect(body.toLowerCase().contains('delete from public.partner_referrals'),
          isFalse,
          reason: 'attribution records the token it used — deleting a row '
              'would orphan the families it brought');
    });

    test('a replacement is minted in the same call', () {
      final start = sql.indexOf('function public.rotate_partner_token(');
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      expect(body.contains('mint_partner_token'), isTrue,
          reason: 'retiring without minting leaves a partner with no code, '
              'and their kit reading "not set up yet"');
    });

    test('a reason is required', () {
      final start = sql.indexOf('function public.rotate_partner_token(');
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      expect(body.contains("coalesce(trim(p_reason), '') = ''"), isTrue);
      expect(body.contains('raise exception'), isTrue,
          reason: 'a code that stops working has to be explainable a year on');
    });

    test('there is a grace window, so a scan-then-install gap still binds', () {
      final start = sql.indexOf('function public.rotate_partner_token(');
      final sig = sql.substring(start, start + 400);
      expect(sig.contains('p_grace_days  int default 30'), isTrue,
          reason: 'retiring instantly refuses a patient who scanned the old '
              'poster ten minutes ago, and refuses her with "expired" — which '
              'reads as the doctor being wrong');
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      expect(body.contains('make_interval(days =>'), isTrue);
    });

    test('rotation writes nothing to a family timeline', () {
      final start = sql.indexOf('function public.rotate_partner_token(');
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      expect(body.contains('insert into public.parent_timeline'), isFalse,
          reason: 'our paperwork does not belong in a mother history, and it '
              'would inflate "active families" on the partner dashboard');
    });

    test('a partner cannot rotate their own code', () {
      expect(
          sql.contains('revoke execute on function\n'
              '  public.rotate_partner_token(text, text, int) from public;'),
          isTrue,
          reason: 'a partner could otherwise invalidate posters ParentVeda '
              'paid to print');
    });
  });

  group('the current token is decided by the server', () {
    test('my_partner_token excludes retired and expired rows', () {
      final start = sql.indexOf('function public.my_partner_token(');
      expect(start, greaterThan(-1));
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      // `active` alone is not enough: a retired token stays active through its
      // grace window, which is exactly what the old client-side sort got wrong.
      expect(body.contains('pr.retired_at is null'), isTrue);
      expect(body.contains('pr.expires_at is null or pr.expires_at > now()'),
          isTrue);
      expect(body.contains('limit 1'), isTrue);
      expect(body.contains('caller_owns_partner'), isTrue);
    });

    test('the app no longer picks the token itself', () {
      final dart =
          File('lib/care_partner/partner_dashboard_store.dart').readAsStringSync();
      expect(dart.contains("callFunction('my_partner_token')"), isTrue);
      expect(dart.contains("selectAll('partner_referrals')"), isFalse,
          reason: 'sorting partner_referrals client-side and taking the newest '
              'active row picks a retired-with-grace token');
    });
  });

  group('history is answerable', () {
    test('partner_token_history marks exactly one row current, and says why '
        'the others are not', () {
      final start = sql.indexOf('function public.partner_token_history(');
      expect(start, greaterThan(-1));
      final sig = sql.substring(start, sql.indexOf('language sql', start));
      for (final col in ['is_current', 'retired_at', 'retired_reason']) {
        expect(sig.contains(col), isTrue, reason: '$col is missing');
      }
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      expect(body.contains('caller_owns_partner'), isTrue);
    });

    test('and carries no family data', () {
      final start = sql.indexOf('function public.partner_token_history(');
      final sig = sql.substring(start, sql.indexOf('language sql', start));
      expect(sig.contains('user_id'), isFalse);
    });
  });

  test('every partner-facing function in both migrations authorises the same '
      'way', () {
    // One rule, one place. Three copies of an authorisation check is three
    // chances to fix two of them.
    for (final entry in {
      '0068': [s0068, 'partner_impact', 'partner_earnings', 'partner_funnel'],
      '0069': [sql, 'partner_token_history', 'my_partner_token'],
    }.entries) {
      final src = entry.value.first as String;
      for (final fn in entry.value.skip(1).cast<String>()) {
        final start = src.indexOf('function public.$fn(');
        expect(start, greaterThan(-1), reason: '$fn missing from ${entry.key}');
        final body = src.substring(start, src.indexOf(r'$$;', start));
        expect(body.contains('caller_owns_partner'), isTrue,
            reason: '$fn authorises its own way');
      }
    }
  });
}

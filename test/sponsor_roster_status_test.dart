// =============================================================================
//  The roster has three statuses, not two (Partners P2)
// -----------------------------------------------------------------------------
//  SponsorMemberRow was written against 0060's roster (members only), where
//  "not active" meant "removed". 0061 added everyone on the list who has not
//  started, and the in-app HR screen kept splitting on `!isActive`, so the
//  follow-up list showed as Removed. The store is shared with the Partners
//  app, so the fix and this test cover both.
//
//  Also holds: 0138's server-side refusal of removing yourself, and the HR
//  screen no longer claiming time in the app is not measured (wrong since
//  0065).
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/sponsor_admin_store.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

String _live(String path) => _read(
  path,
).split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

/// The newest definition of a SQL function, comments stripped.
String _lastSql(String name) {
  final files =
      Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  String? body;
  for (final f in files) {
    final code = _read(
      f.path,
    ).split('\n').where((l) => !l.trimLeft().startsWith('--')).join('\n');
    final at = code.lastIndexOf('create or replace function public.$name(');
    if (at < 0) continue;
    final open = code.indexOf(r'$$', at);
    body = code.substring(at, code.indexOf(r'$$', open + 2));
  }
  if (body == null) fail('no definition of public.$name');
  return body;
}

void main() {
  group('SponsorMemberRow reads all three statuses', () {
    SponsorMemberRow row(Map<String, dynamic> m) =>
        SponsorMemberRow.fromMap({'work_email': 'a@acme.com', ...m});

    test('not_activated is not removed', () {
      final r = row({'status': 'not_activated', 'full_name': 'Asha Rao'});
      expect(r.isNotActivated, isTrue);
      expect(r.isRemoved, isFalse);
      expect(r.isActive, isFalse);
      expect(r.displayName, 'Asha Rao');
    });

    test('active and removed are what they say', () {
      expect(row({'status': 'active'}).isActive, isTrue);
      expect(row({'status': 'removed'}).isRemoved, isTrue);
    });

    test(
      'an unknown or missing status claims nothing: it reads as not started',
      () {
        expect(row({'status': 'paused'}).isNotActivated, isTrue);
        expect(row({}).isNotActivated, isTrue);
      },
    );

    test('no name falls back to the email; a blank name is no name', () {
      expect(row({'status': 'active'}).displayName, 'a@acme.com');
      expect(row({'full_name': '  '}).fullName, isNull);
    });
  });

  group('the in-app HR screen', () {
    const path = 'lib/screens/enterprise/sponsor_dashboard_screen.dart';

    test('splits the roster on the three getters, never on !isActive', () {
      final live = _live(path);
      expect(live, isNot(contains('!r.isActive')));
      expect(live, contains('r.isNotActivated'));
      expect(live, contains('r.isRemoved'));
      expect(live, contains("'Not activated yet'"));
    });

    test('no longer says time in the app is not measured (0065 does)', () {
      expect(
        _live(path),
        isNot(contains('we do not measure that last one at all')),
      );
    });
  });

  group('0138 · an admin cannot remove themselves', () {
    test('the newest sponsor_remove_member refuses the caller by uid', () {
      final body = _lastSql('sponsor_remove_member');
      final guard = body.indexOf('v_uid = auth.uid()');
      expect(guard, greaterThan(0));
      expect(body, contains("'cannot_remove_self'"));
      // Refuses BEFORE it removes, and refuses rather than raising.
      expect(guard, lessThan(body.indexOf('public.remove_sponsor_member(')));
      expect(body, isNot(contains('raise exception')));
      expect(body, contains('security definer'));
      expect(body, contains("set search_path = ''"));
    });
  });
}

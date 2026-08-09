// =============================================================================
//  Deleting an account: the properties that must not quietly change.
// -----------------------------------------------------------------------------
//  None of this can be exercised end-to-end from a unit test — it ends in an
//  irreversible server call. What CAN be pinned is the shape, and the shape is
//  where the dangerous mistakes live: which key does the deleting, whose id
//  gets deleted, and what order the two halves run in.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/auth/delete_account.dart';
import 'package:parentveda/services/auth/local_wipe.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _fn() =>
    File('supabase/functions/delete-account/index.ts').readAsStringSync();

void main() {
  group('the edge function deletes the caller, and only the caller', () {
    test('the id comes from the verified token, never the request body', () {
      final src = _fn();
      expect(src.contains('auth.getUser()'), isTrue,
          reason: 'identity must be established from the JWT');
      expect(src.contains('admin.auth.admin.deleteUser(user.id)'), isTrue,
          reason: 'it must delete the id the token proved');

      // The failure this guards is catastrophic and easy to introduce: read an
      // id out of the posted JSON and this endpoint — which holds a key that
      // bypasses RLS entirely — will delete anybody's account on request.
      expect(src.contains('req.json()'), isFalse,
          reason: 'this function must not read the request body at all');
    });

    test('two clients, each with the least power its job needs', () {
      final src = _fn();
      expect(src.contains('SUPABASE_ANON_KEY'), isTrue,
          reason: 'the "who is this?" client must be the anon one');
      expect(src.contains('SUPABASE_SERVICE_ROLE_KEY'), isTrue,
          reason: 'only the delete uses the privileged key');
    });

    test('it refuses an unauthenticated caller', () {
      final src = _fn();
      expect(src.contains('missing authorization'), isTrue);
      expect(src.contains('not signed in'), isTrue);
    });

    test('the deploy note does not disable JWT verification', () {
      // --no-verify-jwt on a function holding the service_role key would let an
      // unsigned request reach it. Two other functions in this repo legitimately
      // use that flag, so the wrong line is easy to copy across.
      final src = _fn();
      expect(src.contains('deploy delete-account\n'), isTrue);
      expect(src.contains('delete-account --no-verify-jwt'), isFalse);
    });
  });

  group('the app half cleans up in the recoverable order', () {
    test('the server is called before anything local is cleared', () {
      final src =
          File('lib/services/auth/delete_account.dart').readAsStringSync();
      final serverCall = src.indexOf("invokeEdge('delete-account'");
      final localWipe = src.indexOf('LocalWipe.run()');
      final signOut = src.indexOf('auth.signOut()');

      expect(serverCall, greaterThan(-1));
      expect(localWipe, greaterThan(-1));
      expect(signOut, greaterThan(-1));

      // Wiping the device first would feel faster and fail worse: if the server
      // call then failed, her account would still exist, on a phone that had
      // forgotten it — locked out of an account she asked to delete and could
      // no longer reach to retry.
      expect(serverCall, lessThan(localWipe),
          reason: 'local state must not be cleared before the server confirms');
      expect(serverCall, lessThan(signOut),
          reason: 'signing out first would remove the token the function needs '
              'to identify her');
      // And sign out before the wipe, so the stores stop believing they have a
      // cloud to talk to before their caches disappear underneath them.
      expect(signOut, lessThan(localWipe));
    });

    test('an unconfirmed deletion reports failure rather than pretending', () {
      final src =
          File('lib/services/auth/delete_account.dart').readAsStringSync();
      expect(src.contains("res['deleted'] != true"), isTrue,
          reason: 'a null or unexpected response must not count as success');
    });
  });

  group('deletion leaves nothing behind on the device', () {
    // The bug: local caches survived deletion, and cloud_synced_store seeds a
    // NEW account from local when the cloud has no data — so the next person to
    // sign up on that phone inherited the deleted user's journal.
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('account data is cleared', () async {
      SharedPreferences.setMockInitialValues({
        'journal_entries': '[{"text":"first kick"}]',
        'weight_log': '[72.4]',
        'auth_completed': true,
        'pending_profile_json': '{"name":"Priya"}',
      });

      await LocalWipe.run();

      final prefs = await SharedPreferences.getInstance();
      for (final key in const [
        'journal_entries',
        'weight_log',
        'auth_completed',
        'pending_profile_json',
      ]) {
        expect(prefs.get(key), isNull, reason: '$key survived a deletion');
      }
    });

    test('the chosen language survives, because it describes the phone', () async {
      SharedPreferences.setMockInitialValues({
        PregnancyController.kLanguageKey: 'hinglish',
        'journal_entries': '[{"text":"first kick"}]',
      });

      await LocalWipe.run();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PregnancyController.kLanguageKey), 'hinglish',
          reason: 'someone who reads Hindi still reads Hindi afterwards');
      expect(prefs.get('journal_entries'), isNull);
    });

    test('the allowlist is deliberately tiny', () {
      // Everything not named is treated as account data. If this grows, each
      // addition needs to be a thing about the DEVICE, not about her.
      expect(LocalWipe.keep.length, lessThanOrEqualTo(3),
          reason: 'an allowlist that grows quietly is how data survives a '
              'deletion — every entry must be justified');
      expect(LocalWipe.keep, contains(PregnancyController.kLanguageKey));
    });

    test('deletion runs the wipe, and closes the app afterwards', () {
      final del =
          File('lib/services/auth/delete_account.dart').readAsStringSync();
      expect(del.contains('LocalWipe.run()'), isTrue);

      // Clearing storage does not empty the singletons already in memory; they
      // would re-persist on the next write and seed a new account. Ending the
      // process is the only version that cannot be got wrong.
      final profile =
          File('lib/screens/profile_screen.dart').readAsStringSync();
      expect(profile.contains('SystemNavigator.pop()'), isTrue,
          reason: 'without a restart the in-memory stores recreate the bug');
    });
  });

  group('the confirmation keyword is an identifier, not copy', () {
    test('it is a plain constant, not a localized string', () {
      // The repo has been bitten eight times by a value that looks like copy,
      // gets translated, and silently stops matching. A translated keyword here
      // means the confirm button never enables in Hindi.
      expect(kDeleteAccountKeyword, 'DELETE');

      final strings =
          File('lib/localization/app_language.dart').readAsStringSync();
      expect(strings.contains('deleteAccountKeyword'), isFalse,
          reason: 'the compared word must not live in the string table');
    });

    test('the profile screen compares against that constant', () {
      final src = File('lib/screens/profile_screen.dart').readAsStringSync();
      expect(src.contains('kDeleteAccountKeyword'), isTrue);
      expect(src.contains('DeleteAccount.run()'), isTrue,
          reason: 'the button must reach the real deletion — grep the call '
              'site, not the test count');
    });
  });
}

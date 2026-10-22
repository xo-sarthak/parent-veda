// =============================================================================
//  Every store that syncs can forget the person (2026-10-17)
// -----------------------------------------------------------------------------
//  Signing out used to leave the last person's data in every singleton store,
//  and the next account to sign in on the phone uploaded it into its own
//  account. A sign-out (and a different account signing in) now wipes the
//  cache and runs every store's reset (`SyncRegistry.resetAll`, from
//  `LocalOwner.wipeThisPhone`). These hold the parts a compiler cannot:
//
//    * the two sync mixins make a reset REQUIRED, so the compiler covers
//      their stores; a store that registers its sync by hand must register a
//      reset by hand too, and this scan makes sure it did;
//    * sign-out and account deletion both run the wipe;
//    * the owner check runs before the app starts and before every resync.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/profile/pv_account_actions.dart';
import 'package:parentveda/services/auth/local_owner.dart';
import 'package:parentveda/services/remote/sync_registry.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a store that registers a sync by hand registers a reset', () {
    const mixins = {
      'lib/ttc/ttc_sync.dart',
      'lib/services/remote/cloud_synced_store.dart',
    };
    final missing = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final path = f.path.replaceAll('\\', '/');
      if (mixins.contains(path)) continue;
      final src = _read(f.path);
      // Re-arming alarms after a sync holds no data of its own, so it needs
      // no reset (medicine_store, reminder_store).
      final syncs = 'SyncRegistry.register('.allMatches(src).length -
          'SyncRegistry.register(rearmNotifications)'.allMatches(src).length;
      if (syncs == 0) continue;
      final resets = 'SyncRegistry.registerReset('.allMatches(src).length;
      if (resets < syncs) missing.add('$path ($syncs syncs, $resets resets)');
    }
    expect(missing, isEmpty,
        reason: 'these stores sync but cannot forget the person on sign-out, '
            "so the next account would upload this one's data:\n"
            '${missing.join('\n')}');
  });

  // ---- phone-only stores (sync log step 12, 2026-10-21) --------------------
  //
  // A store that never syncs still holds the last person in memory after a
  // sign-out: prefs are wiped, the singleton was not, so her data stayed on
  // screen and the next write put it back on disk for the next account. Every
  // singleton that reads prefs now registers a reset, syncs through a mixin or
  // ledger that carries one, or is named here with the reason it holds
  // nothing about the person.
  const deviceSettings = <String, String>{
    // Device and cache: nothing in them is about the person.
    'lib/referral/install_referrer.dart':
        'device: "has this install been checked", once per install',
    'lib/services/baby_voice_service.dart':
        'device: voice mute switches for this phone',
    'lib/services/preg_size_set_store.dart':
        'device: which comparison set (fruit, kitchen, sweets) is drawn',
    'lib/services/profile_analytics.dart':
        'device: an anonymous install id for question analytics',
    'lib/services/pv_door_strip_store.dart':
        'device: which "start here" hint strips were dismissed',
    'lib/services/usage_events.dart':
        'device: a queue of screen-level usage events, no content',
    'lib/ttc/ttc_cue_sounds.dart': 'device: practice cue sounds on or off',
    'lib/screens/v2/v2_block_art.dart':
        'device: door marks drawn as vectors or images',
    // Another terminal, or the main session, is editing these.
    'lib/screens/ttc/ttc_strings.dart':
        'deferred: another terminal is editing it; reset owed, '
            'STILL-OPEN-BACKEND §4',
    'lib/widgets/global_ask_fab.dart':
        'deferred: another terminal is editing it; reset owed, '
            'STILL-OPEN-BACKEND §4',
    'lib/services/notification_service.dart':
        'device: holds no person; every wipe cancels what it scheduled '
            '(LocalOwner.wipeThisPhone -> cancelAllScheduled, step 12)',
    // The doctor app signs out its own way.
    'lib/doctor/doctor_availability.dart':
        'doctor app: its own sign-out, a separate pass',
    'lib/doctor/doctor_ledger.dart':
        'doctor app: its own sign-out, a separate pass',
    'lib/doctor/doctor_onboarding_store.dart':
        'doctor app: its own sign-out, a separate pass',
    'lib/doctor/doctor_schedule_store.dart':
        'doctor app: its own sign-out, a separate pass',
    'lib/doctor/doctor_session.dart':
        'doctor app: its own sign-out, a separate pass',
    'lib/doctor/doctor_updates.dart':
        'doctor app: its own sign-out, a separate pass',
  };

  test('a singleton that reads prefs forgets the person on sign-out', () {
    final singleton = RegExp(r'static final (\w+(<[^>]*>)? )?instance\b');
    const covered = [
      'SyncRegistry.registerReset(',
      'with TtcSyncedStore',
      'CloudSyncedStore',
      'CloudMergedStore',
      'OwnRowLedger(',
      'ChildLogLedger(',
      'SyncRowBook',
    ];
    final missing = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final path = f.path.replaceAll('\\', '/');
      if (deviceSettings.containsKey(path)) continue;
      final src = _read(f.path);
      if (!singleton.hasMatch(src)) continue;
      if (!src.contains('SharedPreferences.getInstance')) continue;
      if (covered.any(src.contains)) continue;
      missing.add(path);
    }
    expect(missing, isEmpty,
        reason: 'these singletons keep the last person in memory after a '
            'sign-out. Register a reset (SyncRegistry.registerReset), or, if '
            'the file holds only device settings, add it to deviceSettings '
            'with the reason:\n${missing.join('\n')}');
  });

  test('every file the phone-only allowlist names still exists', () {
    final gone = [
      for (final p in deviceSettings.keys)
        if (!File(p).existsSync()) p,
    ];
    expect(gone, isEmpty,
        reason: 'remove these from deviceSettings:\n${gone.join('\n')}');
  });

  test('both sync mixins require a reset', () {
    expect(_read('lib/ttc/ttc_sync.dart'), contains('void resetLocal();'));
    expect(_read('lib/services/remote/cloud_synced_store.dart'),
        contains('Object get cloudEmptyData;'));
  });

  test('sign-out and account deletion wipe this phone', () {
    expect(_read('lib/screens/profile/pv_account_actions.dart'),
        contains('await LocalOwner.wipeThisPhone();'));
    expect(_read('lib/services/auth/delete_account.dart'),
        contains('await LocalOwner.wipeThisPhone();'));
    // One way out: the old profile button goes through the shared flow.
    expect(_read('lib/screens/profile_screen.dart'),
        contains('onPressed: () => pvSignOut(context),'));
  });

  test('the owner check runs at launch and before every resync', () {
    expect(_read('lib/main.dart'), contains('await LocalOwner.ensureCurrent();'));
    expect(_read('lib/services/remote/sync_registry.dart'),
        contains('await LocalOwner.ensureCurrent();'));
  });

  test('the sign-out sheet says what happens to her data', () {
    expect(kPvSignOutBody, contains('removes your data from this phone'));
    expect(kPvSignOutBody, contains('stays saved in your account'));
    expect(kPvSignOutPending, contains("haven't reached your account"));
    // Skilling stays on the phone by decision (step 13), so the sheet says so.
    expect(kPvSignOutSkilling, contains('kept only on this phone'));
  });

  test("the Skilling keys the sheet checks are the stores' own", () {
    const files = {
      'sk_journal': 'lib/screens/skilling/sk_journal.dart',
      'sk_portfolio': 'lib/screens/skilling/sk_portfolio.dart',
      'sk_voice': 'lib/screens/skilling/sk_voice_keepsake.dart',
      'sk_practice': 'lib/screens/skilling/sk_practice_store.dart',
    };
    expect(kPvSkillingKeys.toSet(), files.keys.toSet());
    for (final e in files.entries) {
      expect(_read(e.value), contains("_key = '${e.key}'"),
          reason: '${e.value} no longer keeps its records under ${e.key}, so '
              'the sign-out sheet would stop warning about them');
    }
  });

  group('the registry', () {
    test('resets run once each, and one that throws does not stop the rest',
        () {
      var a = 0, b = 0;
      void ra() => a++;
      void boom() => throw StateError('x');
      void rb() => b++;
      SyncRegistry.registerReset(ra);
      SyncRegistry.registerReset(ra); // deduped
      SyncRegistry.registerReset(boom);
      SyncRegistry.registerReset(rb);
      SyncRegistry.resetAll();
      expect(a, 1);
      expect(b, 1);
    });

    test('pending changes are reported from any store', () {
      var pending = false;
      bool check() => pending;
      SyncRegistry.registerPending(check);
      expect(SyncRegistry.hasPendingChanges, isFalse);
      pending = true;
      expect(SyncRegistry.hasPendingChanges, isTrue);
      pending = false;
    });

    test('a resume pulls at most once a minute', () async {
      final t0 = DateTime(2026, 10, 17, 10);
      // Logged out in tests: resyncAll is harmless, the throttle is the point.
      await SyncRegistry.resyncOnResume(now: t0);
      await SyncRegistry.resyncOnResume(now: t0.add(const Duration(seconds: 30)));
      await SyncRegistry.resyncOnResume(now: t0.add(const Duration(minutes: 2)));
    });
  });

  group('the owner', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('logged out, nothing is claimed or wiped', () async {
      expect(await LocalOwner.ensureCurrent(), isFalse);
      expect(await LocalOwner.read(), isNull);
    });

    test('a wipe clears the owner with the rest of the cache', () async {
      SharedPreferences.setMockInitialValues(
          {LocalOwner.kKey: 'someone', 'ttc_period_starts': <String>['x']});
      await LocalOwner.wipeThisPhone();
      final p = await SharedPreferences.getInstance();
      expect(p.getString(LocalOwner.kKey), isNull);
      expect(p.getStringList('ttc_period_starts'), isNull);
    });
  });
}

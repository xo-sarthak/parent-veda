// =============================================================================
//  Blob stores: a change made offline is not replaced by the cloud's older
//  blob (2026-10-17, STILL-OPEN-BACKEND §2, sync log step 3)
// -----------------------------------------------------------------------------
//  Before: the push on every change was fire-and-forget, nothing remembered a
//  failure, and the next sync took the cloud's blob ("cloud wins"), so the
//  change was gone. Now a change is marked waiting (on disk), only a confirmed
//  upload of the newest state clears it, and a sync that finds it waiting
//  uploads first instead of taking the cloud's blob.
//
//  A tiny fake store and `CloudBlobIo` stand in for Supabase.
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/remote/cloud_synced_store.dart';
import 'package:parentveda/services/remote/sync_registry.dart';

class _Notes extends ChangeNotifier with CloudSyncedStore {
  _Notes(this.key);
  final String key;
  List<String> items = [];

  void add(String s) {
    items = [...items, s];
    notifyListeners();
  }

  @override
  String get cloudKey => key;
  @override
  Object cloudData() => {'items': items};
  @override
  void applyCloudData(Object data) {
    items = [for (final e in ((data as Map)['items'] as List)) e.toString()];
  }

  @override
  Object get cloudEmptyData => {'items': <String>[]};
  @override
  Future<void> persistLocalCache() async {}
}

/// A cloud with one blob per key, which can go offline.
class _Cloud {
  final Map<String, Object> blobs = {};
  bool offline = false;
  int saves = 0;
  Completer<void>? hold;

  void install() {
    CloudBlobIo.isLoggedIn = () => true;
    CloudBlobIo.load = (k) async {
      if (offline) throw Exception('offline');
      return blobs[k];
    };
    CloudBlobIo.save = (k, data) async {
      if (offline) throw Exception('offline');
      final h = hold;
      if (h != null) await h.future;
      saves++;
      blobs[k] = data;
    };
  }
}

/// Lets the fire-and-forget upload and the disk write finish.
Future<void> _settle() => Future<void>.delayed(Duration.zero)
    .then((_) => Future<void>.delayed(Duration.zero));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Cloud cloud;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cloud = _Cloud()..install();
  });
  tearDown(CloudBlobIo.restore);

  test('nothing waiting: the cloud blob still wins, as before', () async {
    cloud.blobs['k1'] = {'items': ['from the other phone']};
    final s = _Notes('k1')..items = ['stale local'];
    await s.syncStateFromCloud();
    expect(s.items, ['from the other phone']);
    expect(s.cloudChangeWaiting, isFalse);
  });

  test('an offline change survives the next sync and uploads first', () async {
    cloud.blobs['k2'] = {'items': ['a']};
    final s = _Notes('k2');
    await s.syncStateFromCloud();
    cloud.offline = true;
    s.add('b'); // made offline: the upload fails
    await _settle();
    expect(s.cloudChangeWaiting, isTrue);
    expect(SyncRegistry.hasPendingChanges, isTrue,
        reason: 'the sign-out sheet must see it');

    cloud.offline = false; // back online: resume runs the sync
    await s.syncStateFromCloud();
    expect(s.items, ['a', 'b'], reason: 'not replaced by the older blob');
    expect(cloud.blobs['k2'], {'items': ['a', 'b']});
    expect(s.cloudChangeWaiting, isFalse);
  });

  test('the waiting mark survives the app being closed', () async {
    cloud.blobs['k3'] = {'items': ['a']};
    final first = _Notes('k3');
    await first.syncStateFromCloud();
    cloud.offline = true;
    first.add('b');
    await _settle();

    // A new launch: the same store key, the local cache holds ['a', 'b'].
    cloud.offline = false;
    final relaunched = _Notes('k3')..items = ['a', 'b'];
    await relaunched.syncStateFromCloud();
    expect(relaunched.items, ['a', 'b']);
    expect(cloud.blobs['k3'], {'items': ['a', 'b']});
  });

  test('a change during an upload is uploaded too, newest last', () async {
    final s = _Notes('k4');
    await s.syncStateFromCloud();
    cloud.hold = Completer<void>();
    s.add('one'); // upload 1 starts and waits
    await _settle();
    s.add('two'); // arrives mid-upload: folded into one more upload
    cloud.hold!.complete();
    cloud.hold = null;
    await _settle();
    await _settle();
    expect(cloud.blobs['k4'], {'items': ['one', 'two']});
    expect(s.cloudChangeWaiting, isFalse);
  });

  test('a sign-out reset leaves nothing waiting', () async {
    final s = _Notes('k5');
    await s.syncStateFromCloud();
    cloud.offline = true;
    s.add('b');
    await _settle();
    expect(s.cloudChangeWaiting, isTrue);
    SyncRegistry.resetAll();
    expect(s.cloudChangeWaiting, isFalse);
    expect(s.items, isEmpty);
  });
}

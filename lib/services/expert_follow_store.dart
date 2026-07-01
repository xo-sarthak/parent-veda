// =============================================================================
//  ExpertFollowStore — who the user follows (EXPERTS ONLY)
// -----------------------------------------------------------------------------
//  Twitter-style following, limited to verified experts (regular members can't
//  be followed yet). A followed expert's posts show up in the "Following" feed,
//  and the ⋯ menu / profile "Follow" button toggle this. Persisted locally.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';

class ExpertFollowStore extends ChangeNotifier with CloudSyncedStore {
  ExpertFollowStore._();
  static final ExpertFollowStore instance = ExpertFollowStore._();

  static const _key = 'followed_experts';

  SharedPreferences? _prefs;
  final Set<String> _followed = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _followed
      ..clear()
      ..addAll(_prefs!.getStringList(_key) ?? const []);
    notifyListeners();
    await syncStateFromCloud();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'followed_experts';
  @override
  Object cloudData() => _followed.toList();
  @override
  void applyCloudData(Object data) => _followed
    ..clear()
    ..addAll((data as List).map((e) => e.toString()));
  @override
  Future<void> persistLocalCache() async {
    await _prefs?.setStringList(_key, _followed.toList());
  }

  /// Follow keys are the expert's display name (stable for the seed data).
  bool isFollowing(String expert) => _followed.contains(expert);
  int get count => _followed.length;
  List<String> get followed => _followed.toList();

  void toggleFollow(String expert) {
    if (!_followed.remove(expert)) _followed.add(expert);
    _prefs?.setStringList(_key, _followed.toList());
    notifyListeners();
  }
}

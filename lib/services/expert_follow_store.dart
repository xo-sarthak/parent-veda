// =============================================================================
//  ExpertFollowStore - who the user follows (experts AND members)
// -----------------------------------------------------------------------------
//  Twitter-style following. Originally experts-only; now ANY author (expert or
//  regular member) can be followed - a followed name is a followed name, keyed
//  by the author's display name. A followed author's posts show up in the
//  "Following" feed, and the ⋯ menu / profile "Follow" button toggle this.
//  Persisted locally. The member aliases below are additive and simply delegate
//  to the same underlying set, so existing expert-follow call sites are
//  unchanged.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)

// In the cloud per item since step 13 (2026-10-22, sync log). It synced as one
// whole blob before, so a follow on one phone and an unfollow on another
// overwrote each other. Items: one per followed name, value true.
class ExpertFollowStore extends ChangeNotifier with CloudMergedStore {
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
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  // --- cloud sync ------------------------------------------------------------
  @override
  String get cloudKey => 'followed_experts';
  // Kept for revert (step 13): the whole-blob mixin's empty state and blob.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String>[];
  //
  //   @override
  //   Object cloudData() => _followed.toList();

  @override
  String? get legacyBlobKey => cloudKey;

  /// The old whole blob, read once on a phone that holds nothing yet.
  @override
  void applyLegacyBlob(Object blob) => _followed
    ..clear()
    ..addAll((blob as List).map((e) => e.toString()));

  @override
  Map<String, Object?> cloudItems() => {for (final f in _followed) f: true};

  @override
  void applyCloudItems(Map<String, Object?> items) => _followed
    ..clear()
    ..addAll(items.keys);
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

  // --- general member follow (additive) --------------------------------------
  //  Members are stored in the SAME set as experts (a followed name is a
  //  followed name). These aliases exist for call-site clarity; they don't
  //  change any existing expert-follow behaviour or the "Following" feed.
  bool isFollowingMember(String member) => _followed.contains(member);
  void toggleFollowMember(String member) => toggleFollow(member);
}

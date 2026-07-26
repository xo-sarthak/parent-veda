// =============================================================================
//  BirthClubStore — making the milestone ladder actually GRANT something
// -----------------------------------------------------------------------------
//  The 1 / 3 / 5 ladder used to be presentational: it drew a tick beside a
//  milestone and nothing happened. A progress bar that unlocks nothing is worse
//  than no progress bar, because it makes a promise the app then breaks.
//
//  Each rung now does a real thing:
//     1 invite  -> she JOINS the club room for her due month (CommunityStore)
//     3 invites -> the club's expert Q&A is open to her
//     5 invites -> a founding-member badge is recorded against that club
//
//  Unlocks are permanent and idempotent, keyed by (club, rung). Two properties
//  that matter:
//    * PERMANENT - a mother who reaches 3 and then has an invite blocked for
//      fraud does not lose her Q&A. Clawing back something already given is a
//      worse failure than the occasional over-grant.
//    * IDEMPOTENT - evaluate() runs on every screen build; it must be safe to
//      call a thousand times.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/community_data.dart';
import '../services/community_store.dart';
import 'referral_analytics.dart';

/// The community room a birth club maps to.
///
/// This used to invent its own id space ('birthclub_2026-10'), which existed
/// nowhere in the community list - so joining it recorded her as a member of a
/// room that never rendered. It now resolves to the REAL cohort room id the
/// community data already uses ('oct2026'), derived for any month.
String birthClubRoomId(String clubKey) {
  final parts = clubKey.split('-');
  if (parts.length != 2) return '';
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (year == null || month == null) return '';
  return birthClubCommunityId(year, month);
}

class BirthClubStore extends ChangeNotifier {
  BirthClubStore._();
  static final BirthClubStore instance = BirthClubStore._();

  static const _key = 'birth_club_v1';

  /// Keys of the form `clubKey:rung` for every unlock already granted.
  final Set<String> _unlocked = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _unlocked.addAll(
            (jsonDecode(raw) as List).map((e) => e.toString()));
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  static String _k(String club, int rung) => '$club:$rung';

  bool hasUnlocked(String club, int rung) => _unlocked.contains(_k(club, rung));

  bool get hasAnyUnlock => _unlocked.isNotEmpty;

  /// True once she has reached the 3-invite rung for [club].
  bool qaOpen(String club) => hasUnlocked(club, 3);

  /// True once she has reached the 5-invite rung for [club].
  bool isFoundingMember(String club) => hasUnlocked(club, 5);

  /// Grant everything [joined] now entitles her to, and return the rungs newly
  /// crossed this call — which is what a celebration should be shown for.
  ///
  /// Safe to call on every build: already-granted rungs are skipped.
  List<int> evaluate({
    required String club,
    required int joined,
    List<int> rungs = const [1, 3, 5],
  }) {
    if (club.isEmpty) return const [];
    final newly = <int>[];
    for (final rung in rungs) {
      if (joined < rung) continue;
      if (hasUnlocked(club, rung)) continue;
      _unlocked.add(_k(club, rung));
      _grant(club, rung);
      newly.add(rung);
    }
    if (newly.isNotEmpty) {
      _persist();
      notifyListeners();
    }
    return newly;
  }

  /// The actual thing each rung hands over.
  void _grant(String club, int rung) {
    switch (rung) {
      case 1:
        // Put her IN the room rather than just showing her a badge for it.
        final room = birthClubRoomId(club);
        if (room.isEmpty) break; // a malformed club key joins nothing
        if (!CommunityStore.instance.isJoined(room)) {
          CommunityStore.instance.toggleJoin(room);
        }
        ReferralAnalytics.birthClubJoined();
      case 3:
      case 5:
        // Recorded by the unlock itself; qaOpen / isFoundingMember read it.
        break;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_unlocked.toList()));
    } catch (_) {/* in-memory stands */}
  }

  @visibleForTesting
  void resetAll() {
    _unlocked.clear();
    _loaded = false;
    notifyListeners();
  }
}

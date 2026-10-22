// =============================================================================
//  What she has chosen to see in the TTC stage
// -----------------------------------------------------------------------------
//  Added 2026-09-26 from the TTC gap analysis ("Behind — Settings", P2): many
//  Indian phones are shared with family, and Flo lets a woman switch off sex
//  content. One switch, "Hide sex and intimacy content": when on, the Sex and
//  closeness tab, its reads in Learn and any intimacy daily card are left out.
//  Timing information is never hidden, because it is not the private part and
//  hiding it would take away the tool she came for.
//
//  Local-first like every TTC preference: shared_preferences, instant, no
//  network. A structure never changes because of it (CLAUDE.md: personalisation
//  changes content, never navigation), only which pieces are listed.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/cloud_merged_store.dart';
// import '../services/remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

// ⚠️ IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log). It was phone-only, so
// a sign-out or a new phone showed the intimacy content she had hidden, and
// offered the switch a second time. Items: `hide_intimate` and
// `intimate_offered`, one bool each.
class TtcContentPrefs extends ChangeNotifier with CloudMergedStore {
  TtcContentPrefs._();
  // Kept for revert (step 13): the reset now comes from the mixin.
  //   TtcContentPrefs._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
  static final TtcContentPrefs instance = TtcContentPrefs._();

  static const String _kHideIntimate = 'ttc_hide_intimate';

  /// Whether the switch has been offered once on the Sex and closeness tab
  /// (2026-09-27). The offer is made one time only, and never again whatever
  /// she answered: asking twice would be a nag.
  static const String _kIntimateOffered = 'ttc_hide_intimate_offered';

  bool _loaded = false;
  bool _hideIntimate = false;
  bool _intimateOffered = false;

  /// True once the one-time offer has been shown.
  bool get intimateOffered => _intimateOffered;

  /// Records that the offer was shown, before she answers it, so closing
  /// the sheet any way at all still counts as asked.
  Future<void> markIntimateOffered() async {
    if (_intimateOffered) return;
    _intimateOffered = true;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kIntimateOffered, true);
    } catch (_) {/* best effort */}
  }

  /// Whether sex and intimacy content is hidden. False until she chooses.
  bool get hideIntimate => _hideIntimate;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _hideIntimate = p.getBool(_kHideIntimate) ?? false;
      _intimateOffered = p.getBool(_kIntimateOffered) ?? false;
    } catch (_) {/* keep the default */}
    _loaded = true;
    notifyListeners();
    await syncMergedFromCloud();
  }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'ttc_content_prefs';

  @override
  Map<String, Object?> cloudItems() => {
        'hide_intimate': _hideIntimate,
        'intimate_offered': _intimateOffered,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _hideIntimate = items['hide_intimate'] == true;
    _intimateOffered = items['intimate_offered'] == true;
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kHideIntimate, _hideIntimate);
      await p.setBool(_kIntimateOffered, _intimateOffered);
    } catch (_) {/* best effort */}
  }

  Future<void> setHideIntimate(bool v) async {
    if (v == _hideIntimate) return;
    _hideIntimate = v;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kHideIntimate, v);
    } catch (_) {/* best effort; the in-memory choice still holds */}
  }

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   void _resetForAccount() {
  //     resetForTest();
  //     notifyListeners();
  //   }

  @visibleForTesting
  void resetForTest() {
    _loaded = false;
    _hideIntimate = false;
    _intimateOffered = false;
  }
}

/// The bracket group id that the switch hides (Fertile window › Sex and
/// closeness). One place, so the door and Learn cannot disagree.
const String kTtcIntimateGroupId = 'sex';

/// Daily insight ids the switch hides on the home (added 2026-09-26 with the
/// phase cards). Only the card about closeness in the window: "every day or
/// two is enough" is timing, and timing is never hidden.
const Set<String> kTtcIntimateInsightIds = {
  'window_closeness',
};

/// Read ids the switch hides wherever reads are listed (Learn, rails).
const Set<String> kTtcIntimateReadIds = {
  'ttc_read_sex_homework',
  'ttc_read_low_desire',
  'ttc_read_pain_vaginismus',
  'ttc_read_lubricants',
  'ttc_read_sex_after_window',
  'ttc_read_keeping_close',
  'ttc_read_his_side_pressure',
};

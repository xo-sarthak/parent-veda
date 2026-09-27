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

class TtcContentPrefs extends ChangeNotifier {
  TtcContentPrefs._();
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

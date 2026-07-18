// =============================================================================
//  Profile analytics — are our QUESTIONS any good?
// -----------------------------------------------------------------------------
//  Mirrors the proven BrandAnalytics / PvVideoAnalytics sink pattern: the app
//  emits FACTS, a sink decides what to do with them. Swapping in Supabase later
//  is one line (ProfileAnalytics.instance.setSink(...)) and touches no call site.
//
//  WHAT THIS MEASURES: the questions, NOT the mother. Completion, skip and
//  abandonment tell us whether a strip is well-worded and well-placed. If 70%
//  answer the conditions strip on the Symptom Companion but 85% ignore the
//  IDENTICAL strip on the Weight Tracker, the question is fine and the placement
//  is wrong — a bug that is invisible without measurement.
//
//  THE HARD CONSTRAINT (Product Bible): analytics improve onboarding and
//  personalization ONLY. They are NEVER used to pressure a mother into
//  completing her profile. A low completion rate means fix the question; it
//  never means ask her again, badge her, or gate a feature behind finishing.
//  That is why a dismissed strip is marked asked and never returns — the data
//  can tell us the question failed, while she is never asked twice.
//
//  IDENTITY IS ANONYMOUS AND RANDOM. Two ids, deliberately separate:
//    * sessionId — regenerated every launch. Groups events within one sitting.
//    * installId — persisted. Lets a completion rate be computed PER MOTHER
//      rather than per view, which is the difference between a trustworthy
//      number and a meaningless one.
//  Both are random. We never read a hardware identifier (ANDROID_ID, IMEI and
//  friends) even though device_info_plus is already in the pubspec: a random id
//  answers every question these metrics ask, and nothing we would have to
//  defend later. A reinstall simply looks like a new anonymous row, which is
//  correct behaviour rather than a bug to work around.
//
//  ALWAYS ON, and nothing leaves the device until a real sink is attached. The
//  in-memory buffer resets each launch by design; the viewer in Profile exists
//  so this is observable rather than a black box.
// =============================================================================

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProfileEvent {
  /// A strip was rendered. The honest denominator for completion and skip.
  ///
  /// CAVEAT, stated plainly because it biases every rate computed from it: this
  /// fires when the strip is built into the tree, which is not quite the same
  /// as her eyes reaching it. All current placements sit near the top of their
  /// screen so the two mostly coincide — but completion rates derived from this
  /// run slightly optimistic. Real scroll visibility needs a VisibilityDetector;
  /// revisit if the numbers ever look strange.
  stripShown,

  /// She picked at least one option.
  stripAnswered,

  /// She hit "Not now" without answering. An explicit skip.
  stripDismissed,

  /// She opened a multi-select strip, picked something, then closed it.
  /// Counting this as a skip would corrupt the skip rate.
  stripDone,

  /// She left the screen having neither answered nor dismissed. The most
  /// useful signal we have that a question was not worth her time — and
  /// previously indistinguishable from the strip never appearing at all.
  stripAbandoned,

  /// A field changed anywhere: a strip, the profile screen, or any future
  /// consumer. Fired from the STORE, not from the UI, so it cannot be forgotten.
  fieldUpdated,

  /// The full profile screen was opened.
  profileOpened,

  /// Completeness at a moment in time. Only meaningful because events carry a
  /// timestamp and an installId — "40% complete" alone says nothing.
  completenessSnapshot,
}

@immutable
class ProfileAnalyticsRecord {
  ProfileAnalyticsRecord({
    required this.event,
    this.field,
    this.value,
    this.percent,
    this.surface,
    this.meta = const {},
    DateTime? at,
  }) : at = at ?? DateTime.now().toUtc();

  final ProfileEvent event;

  /// Which profile field this concerns (ProfileField.name), where relevant.
  final String? field;

  /// The answer she gave, where relevant. Enum labels only — this engine has no
  /// free text to leak.
  final String? value;

  /// Profile completeness 0..100, for snapshots.
  final int? percent;

  /// WHERE the strip was shown ('symptom_companion', 'tools_hub', ...). This is
  /// the field that turns "the question failed" into "the placement failed".
  final String? surface;

  /// UTC. A tester in another timezone would otherwise corrupt any ordering.
  final DateTime at;

  final Map<String, Object?> meta;

  /// Local time, for the human reading the viewer. A stream you cannot read by
  /// eye is useless for the thing the viewer is actually for.
  String get clock {
    final l = at.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.hour)}:${two(l.minute)}:${two(l.second)}';
  }

  @override
  String toString() => '$clock ${event.name}'
      '${field != null ? ' field=$field' : ''}'
      '${value != null ? ' value=$value' : ''}'
      '${surface != null ? ' at=$surface' : ''}'
      '${percent != null ? ' $percent%' : ''}'
      '${meta.isEmpty ? '' : ' $meta'}';

  /// What a real sink would send. Ids are attached by [ProfileAnalytics] rather
  /// than the record itself, so a call site never has to think about them.
  Map<String, Object?> toMap({String? sessionId, String? installId}) => {
        'event': event.name,
        'field': field,
        'value': value,
        'percent': percent,
        'surface': surface,
        'at': at.toIso8601String(),
        'session_id': sessionId,
        'install_id': installId,
        if (meta.isNotEmpty) 'meta': meta,
      };
}

abstract class ProfileAnalyticsSink {
  void record(ProfileAnalyticsRecord record,
      {required String sessionId, required String installId});
}

/// Default sink: prints in debug, and keeps recent events in memory so the
/// in-app viewer can show that this is actually working. Inert until a real
/// sink is attached — nothing leaves the device.
class DebugProfileAnalyticsSink implements ProfileAnalyticsSink {
  DebugProfileAnalyticsSink();

  static const int _cap = 200;
  final List<String> _recent = [];

  List<String> get recent => List.unmodifiable(_recent.reversed);

  void clear() => _recent.clear();

  @override
  void record(ProfileAnalyticsRecord record,
      {required String sessionId, required String installId}) {
    _recent.add(record.toString());
    if (_recent.length > _cap) _recent.removeAt(0);
    if (kDebugMode) debugPrint('Profile[$sessionId] $record');
  }
}

class ProfileAnalytics extends ChangeNotifier {
  ProfileAnalytics._();
  static final ProfileAnalytics instance = ProfileAnalytics._();

  static const _installKey = 'profile_analytics_install_id';

  final DebugProfileAnalyticsSink _debugSink = DebugProfileAnalyticsSink();
  ProfileAnalyticsSink? _sink;

  /// New every launch. Groups a sitting without identifying anyone.
  final String sessionId = _randomId();

  String _installId = 'pending';
  bool _loaded = false;

  String get installId => _installId;

  /// The recent-events buffer the in-app viewer reads. Resets each launch by
  /// design — it exists for observability, not storage.
  List<String> get recent => _debugSink.recent;

  /// Swap in a Supabase/Segment sink at startup.
  void setSink(ProfileAnalyticsSink sink) => _sink = sink;

  static String _randomId() {
    final r = Random();
    const chars = 'abcdef0123456789';
    return List.generate(12, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      var id = prefs.getString(_installKey);
      if (id == null || id.isEmpty) {
        id = _randomId();
        await prefs.setString(_installKey, id);
      }
      _installId = id;
    } catch (_) {
      // Still usable this session; it just will not join across launches.
      _installId = sessionId;
    }
    _loaded = true;
    notifyListeners();
  }

  void clearRecent() {
    _debugSink.clear();
    notifyListeners();
  }

  void fire(ProfileAnalyticsRecord record) {
    try {
      (_sink ?? _debugSink)
          .record(record, sessionId: sessionId, installId: _installId);
      notifyListeners(); // so an open viewer updates live
    } catch (_) {
      // Analytics must never break a mother's session.
    }
  }

  // ---- convenience, so call sites stay one line ---------------------------

  void stripShown(String field, String surface) => fire(ProfileAnalyticsRecord(
      event: ProfileEvent.stripShown, field: field, surface: surface));

  void stripAnswered(String field, String surface, String value) =>
      fire(ProfileAnalyticsRecord(
          event: ProfileEvent.stripAnswered,
          field: field,
          surface: surface,
          value: value));

  void stripDismissed(String field, String surface,
          {bool afterPicking = false}) =>
      fire(ProfileAnalyticsRecord(
          event: afterPicking
              ? ProfileEvent.stripDone
              : ProfileEvent.stripDismissed,
          field: field,
          surface: surface));

  void stripAbandoned(String field, String surface) =>
      fire(ProfileAnalyticsRecord(
          event: ProfileEvent.stripAbandoned, field: field, surface: surface));

  void fieldUpdated(String field, String? value,
          {String surface = 'profile'}) =>
      fire(ProfileAnalyticsRecord(
          event: ProfileEvent.fieldUpdated,
          field: field,
          value: value,
          surface: surface));

  void profileOpened(int percent) => fire(ProfileAnalyticsRecord(
      event: ProfileEvent.profileOpened, percent: percent));

  void completeness(int percent) => fire(ProfileAnalyticsRecord(
      event: ProfileEvent.completenessSnapshot, percent: percent));
}

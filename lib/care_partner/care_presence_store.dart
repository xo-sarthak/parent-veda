// =============================================================================
//  CarePresenceStore — what this parent has already seen, and dismissed
// -----------------------------------------------------------------------------
//  CareVisibilityRule offers `frequency` and `dismissible`. Neither means
//  anything without somewhere to remember that a card was shown on Tuesday, or
//  that she swiped it away. Before this existed both settings round-tripped
//  through the admin panel and changed nothing — an admin could set a partner
//  to "once" and watch them appear every single day.
//
//  LOCAL ONLY, on purpose. "I have seen this card" is not a fact about her
//  family that belongs on a server, it costs a round trip on every render, and
//  the worst case for losing it — a card reappears after a reinstall — is
//  something she will not notice. Contrast the attribution itself, which is
//  server-owned precisely because it must survive a reinstall.
//
//  Keyed by partner + surface + topic, so dismissing a doctor beside a
//  vaccination article does not also remove them from the feeding page. She
//  said "not here", not "never again".
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'care_visibility.dart';

class CarePresenceStore extends ChangeNotifier {
  CarePresenceStore._();
  static final CarePresenceStore instance = CarePresenceStore._();

  static const _key = 'care_presence_v1';

  final Map<String, DateTime> _lastShown = {};
  final Set<String> _dismissed = {};
  bool _loaded = false;

  static String keyFor(String partnerId, CareSurface surface, String? topic) =>
      '$partnerId|${surface.name}|${topic ?? ''}';

  DateTime? lastShown(String partnerId, CareSurface surface, String? topic) =>
      _lastShown[keyFor(partnerId, surface, topic)];

  bool isDismissed(String partnerId, CareSurface surface, String? topic) =>
      _dismissed.contains(keyFor(partnerId, surface, topic));

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final d = jsonDecode(raw) as Map;
        (d['shown'] as Map?)?.forEach((k, v) {
          final t = DateTime.tryParse('$v');
          if (t != null) _lastShown['$k'] = t;
        });
        for (final k in (d['dismissed'] as List?) ?? const []) {
          _dismissed.add('$k');
        }
      }
    } catch (_) {/* start empty; a forgotten impression is harmless */}
    _loaded = true;
    notifyListeners();
  }

  void markShown(String partnerId, CareSurface surface, String? topic,
      {DateTime? at}) {
    _lastShown[keyFor(partnerId, surface, topic)] = at ?? DateTime.now();
    _persist();
    // Deliberately NOT notifying: a rebuild here would re-run the visibility
    // check that just decided to show the card, and the freshly-written
    // timestamp would immediately hide it again.
  }

  void dismiss(String partnerId, CareSurface surface, String? topic) {
    _dismissed.add(keyFor(partnerId, surface, topic));
    _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'shown': _lastShown
              .map((k, v) => MapEntry(k, v.toIso8601String())),
          'dismissed': _dismissed.toList(),
        }),
      );
    } catch (_) {/* best effort */}
  }

  @visibleForTesting
  void resetAll() {
    _lastShown.clear();
    _dismissed.clear();
    _loaded = false;
  }
}

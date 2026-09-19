// =============================================================================
//  SkChildStore — the one record the skilling stage keeps about a child
// -----------------------------------------------------------------------------
//  ⚠️ WHY A SEPARATE STORE, AND NOT `ChildProfileStore`.
//
//  `ChildProfileStore` is the parenting child: a date of birth seeded at age
//  zero, a name whose fallback is "your baby", a weight, a head circumference,
//  and a cloud row in `public.children` shared with a co-parent. A family can
//  have a four-month-old there and a nine-year-old here at the same time, and
//  the nine-year-old's record has to be the CONSENTED MINIMUM the brief
//  names: a name to speak to her by, and an age to scope the door. Nothing
//  else, and — deliberately — no cloud copy. The brief's line is "the child
//  steps into the learning space, which asks nothing of her data", and the
//  law it cites forbids profiling a child. A record that never leaves the
//  phone cannot be profiled by us. Decided 2026-09-14 (question 2).
//
//  ⚠️ BUT A TRANSITION TYPES NOTHING TWICE. The user's addition: a child who
//  grew up inside the parenting stage should not be asked her age again. So
//  [suggestion] offers the parenting child when she is at or over the floor,
//  and the gate pre-fills from it; the parent still consents. A parent whose
//  first use of the app is a skilling-age child is asked, once.
//
//  ⚠️ THE PIN IS A CONVENIENCE, NOT A SECRET. The grown-up gate is a sum in
//  words by default; a parent may set a four-digit PIN instead (question 5,
//  both options). It is stored salted and hashed with FNV-1a, which is not a
//  cryptographic hash — this app has no `crypto` dependency and a local
//  child-lock is not the place to add one. The threat is a child reading
//  prefs, not an attacker. Flagged for the same legal review as consent.
//
//  Local-first is absolute: `shared_preferences`, loaded lazily, and every
//  write is fire-and-forget.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../post_pregnancy/pp_child_profile.dart';
import 'sk_bands.dart';
import 'sk_consent_verifier.dart';

/// What the parenting stage already knows, offered to the gate so she is
/// not asked twice. Null when there is no parenting child at or over the
/// floor.
class SkChildSuggestion {
  const SkChildSuggestion({required this.name, required this.dob});
  final String name;
  final DateTime dob;
}

class SkChildStore extends ChangeNotifier {
  SkChildStore._();
  static final SkChildStore instance = SkChildStore._();

  static const _key = 'sk_child';

  String? _name;
  DateTime? _dob;
  DateTime? _consentedAt;
  SkVerification _verification = SkVerification.none;
  String? _pinHash;
  String? _pinSalt;
  bool _voiceAllowed = false;
  bool _photosAllowed = false;
  bool _loaded = false;

  /// ⚠️ OFF BY DEFAULT. The Communication tasks on recording a child's
  /// voice: "Optional, off by default, only with parent setup and consent.
  /// On-device only, minimal retention, parent-deletable." The gate's
  /// consent covers the record; this switch is the parent's separate yes
  /// to recording, flipped on the grown-up screen. Until it is on, no
  /// child screen shows a record row and the keepsake screen invites the
  /// parent to turn it on.
  bool get voiceAllowed => _voiceAllowed;

  void setVoiceAllowed(bool on) {
    _voiceAllowed = on;
    _save();
    notifyListeners();
  }

  /// ⚠️ OFF BY DEFAULT, THE SAME POSTURE AS VOICE. The Making brief on
  /// saved work: "a photo of a child's art can show her face or name;
  /// treat saved work like the voice keepsake … gated behind explicit
  /// parent consent … on-device where possible, minimal retention, parent
  /// can delete. NEVER analyse, grade, judge or profile the saved work."
  /// The parent's separate yes to keeping photos (2026-09-18).
  bool get photosAllowed => _photosAllowed;

  void setPhotosAllowed(bool on) {
    _photosAllowed = on;
    _save();
    notifyListeners();
  }

  /// The name the learning screens say. Never a "your baby" fallback: a
  /// skilling child is six or more and has a name or the screens use "you".
  String get name => (_name ?? '').trim();
  String get nameOrYou => name.isEmpty ? 'you' : name;

  DateTime? get dob => _dob;

  /// Whole years, or null before the gate has run.
  int? get ageYears {
    final d = _dob;
    if (d == null) return null;
    final now = DateTime.now();
    var y = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) y--;
    return y < 0 ? 0 : y;
  }

  /// Her band, or null under the floor or before the gate.
  SkBand? get band {
    final y = ageYears;
    return y == null ? null : skBandFor(y);
  }

  /// True under the floor — the "all child tabs locked" state.
  bool get underFloor => ageYears != null && ageYears! < kSkAgeFloor;

  /// The lawful front door has been passed.
  bool get consented => _consentedAt != null && _dob != null;
  DateTime? get consentedAt => _consentedAt;
  SkVerification get verification => _verification;

  bool get hasPin => _pinHash != null && _pinSalt != null;

  // ---- the parenting hand-off ----------------------------------------------

  /// The parenting child, if she is old enough for this stage. Read, never
  /// written: the parenting record stays the parenting record.
  SkChildSuggestion? get suggestion {
    final s = ChildProfileStore.instance;
    if (!s.hasRealChild) return null;
    for (final c in s.children) {
      final years = _yearsSince(c.dob);
      if (years >= kSkAgeFloor) {
        return SkChildSuggestion(
            name: c.name == Child.placeholder ? '' : c.name, dob: c.dob);
      }
    }
    return null;
  }

  static int _yearsSince(DateTime d) {
    final now = DateTime.now();
    var y = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) y--;
    return y < 0 ? 0 : y;
  }

  // ---- writes ---------------------------------------------------------------

  /// The gate's one write: name, date of birth, consent, and what the
  /// verifier said. Setting a PIN is separate and optional.
  void consent({
    required String name,
    required DateTime dob,
    required SkVerification verification,
  }) {
    _name = name.trim();
    _dob = DateTime(dob.year, dob.month, dob.day);
    _consentedAt = DateTime.now();
    _verification = verification;
    _save();
    notifyListeners();
  }

  /// Change the child without re-consenting — the settings screen's edit.
  void update({String? name, DateTime? dob}) {
    if (name != null) _name = name.trim();
    if (dob != null) _dob = DateTime(dob.year, dob.month, dob.day);
    _save();
    notifyListeners();
  }

  void setPin(String? pin) {
    if (pin == null || pin.isEmpty) {
      _pinHash = null;
      _pinSalt = null;
    } else {
      _pinSalt = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
      _pinHash = _hash(pin, _pinSalt!);
    }
    _save();
    notifyListeners();
  }

  bool checkPin(String pin) =>
      hasPin && _hash(pin, _pinSalt!) == _pinHash;

  /// Withdraw consent: the record is gone, and the door goes back to the
  /// gate. The parent's right under the law the brief cites, one tap.
  void forget() {
    _name = null;
    _dob = null;
    _consentedAt = null;
    _verification = SkVerification.none;
    _pinHash = null;
    _pinSalt = null;
    _voiceAllowed = false;
    _photosAllowed = false;
    _save();
    notifyListeners();
  }

  /// Test-only: set an age directly.
  @visibleForTesting
  void debugSetAgeYears(int years, {String name = 'Aarav'}) {
    final now = DateTime.now();
    _name = name;
    _dob = DateTime(now.year - years, now.month, now.day)
        .subtract(const Duration(days: 3));
    _consentedAt ??= now;
    _verification = SkVerification.stub;
    _loaded = true;
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    forget();
    _loaded = true;
  }

  // ---- persistence ----------------------------------------------------------

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      _name = j['name'] as String?;
      _dob = DateTime.tryParse((j['dob'] ?? '') as String);
      _consentedAt = DateTime.tryParse((j['consentedAt'] ?? '') as String);
      _verification = SkVerification.values.firstWhere(
          (v) => v.name == j['verification'],
          orElse: () => SkVerification.none);
      _pinHash = j['pinHash'] as String?;
      _pinSalt = j['pinSalt'] as String?;
      _voiceAllowed = j['voiceAllowed'] == true;
      _photosAllowed = j['photosAllowed'] == true;
    } catch (_) {
      // A corrupt record reads as no record. The gate asks again.
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_dob == null && _name == null) {
        await prefs.remove(_key);
        return;
      }
      await prefs.setString(
          _key,
          jsonEncode({
            'name': _name,
            'dob': _dob?.toIso8601String(),
            'consentedAt': _consentedAt?.toIso8601String(),
            'verification': _verification.name,
            'pinHash': _pinHash,
            'pinSalt': _pinSalt,
            'voiceAllowed': _voiceAllowed,
            'photosAllowed': _photosAllowed,
          }));
    } catch (_) {}
  }

  /// FNV-1a, 64-bit, over salt + pin. See the header for why this is enough.
  static String _hash(String pin, String salt) {
    // Dart's int is a 64-bit two's-complement word on the VM, so the multiply
    // wraps on its own; the hex literal above 2^63 reads as its wrapped value.
    var h = 0xcbf29ce484222325;
    for (final c in utf8.encode('$salt:$pin')) {
      h ^= c;
      h = h * 0x100000001b3;
    }
    return h.toUnsigned(63).toRadixString(16);
  }
}

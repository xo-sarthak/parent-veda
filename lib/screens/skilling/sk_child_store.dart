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

//  ⚠️ ONE SPACE PER CHILD (STAGE-TRANSITIONS F5, 2026-10-25): see the note
//  on [SkChildStore]. Still phone-only: nothing here reaches the cloud.
//
//  Local-first is absolute: `shared_preferences`, loaded lazily, and every

//  write is fire-and-forget.

// =============================================================================



import 'dart:convert';



import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';



import '../../services/remote/sync_registry.dart';

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



/// One child's learning-space record: the consented minimum (a name and a
/// date of birth), when and how a grown-up said yes, and the grown-up's two
/// separate yeses for this child's recordings.
class _SkChild {
  _SkChild({
    this.name,
    this.dob,
    this.consentedAt,
    this.verification = SkVerification.none,
    this.voiceAllowed = false,
    this.photosAllowed = false,
  });

  String? name;
  DateTime? dob;
  DateTime? consentedAt;
  SkVerification verification;
  bool voiceAllowed;
  bool photosAllowed;

  bool get consented => consentedAt != null && dob != null;

  Map<String, dynamic> toJson() => {
        'name': name,
        'dob': dob?.toIso8601String(),
        'consentedAt': consentedAt?.toIso8601String(),
        'verification': verification.name,
        'voiceAllowed': voiceAllowed,
        'photosAllowed': photosAllowed,
      };

  static _SkChild fromJson(Map<String, dynamic> j) => _SkChild(
        name: j['name'] as String?,
        dob: DateTime.tryParse((j['dob'] ?? '') as String),
        consentedAt: DateTime.tryParse((j['consentedAt'] ?? '') as String),
        verification: SkVerification.values.firstWhere(
            (v) => v.name == j['verification'],
            orElse: () => SkVerification.none),
        voiceAllowed: j['voiceAllowed'] == true,
        photosAllowed: j['photosAllowed'] == true,
      );
}

/// ⚠️ ONE SPACE PER CHILD, ONE OF THEM OPEN (STAGE-TRANSITIONS F5,
/// 2026-10-25). This store held one child, so a second child of six or more
/// walked into the first one's space: her name, her practice, her photos and
/// her private journal. Now it keeps a record per child, keyed by the
/// parenting child's id, and one of them is OPEN. Every getter below answers
/// for the open child, so the screens that only show "the child in this
/// space" did not change. Only the places that decide which child is open
/// (the family switch, the turning-six card, the gate, the per-child page)
/// call `open` or ask `...For(id)`.
///
/// ⚠️ THE OLD SINGLE RECORD IS ADOPTED, NOT GUESSED. Before this there was
/// exactly one space, so everything in it is one child's. It loads under
/// [kLegacyId] and moves to the parenting child with the same date of birth
/// (and name, when two share a birthday) as soon as that child is known
/// ([legacyOwner]). The practice, voice, photo and journal entries written
/// before this carry no child, and read as the legacy owner's
/// ([ownerOf]). Adopting an orphan is safe only when its owner is provable;
/// here it is (BACKEND-PATTERNS 16qq/16pp).
///
/// The PIN stays one per phone: it is the grown-up's lock, not the child's.
class SkChildStore extends ChangeNotifier {
  SkChildStore._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final SkChildStore instance = SkChildStore._();

  static const _key = 'sk_child';

  /// The id the one pre-F5 record (and a record no parenting child matches)
  /// lives under. The same id the family switch already used for it.
  static const String kLegacyId = 'skilling';

  final Map<String, _SkChild> _children = {};
  String? _openId;
  String? _legacyOwner;
  String? _pinHash;
  String? _pinSalt;
  bool _loaded = false;

  // Kept for revert (F5): the one record's fields.
  //   String? _name; DateTime? _dob; DateTime? _consentedAt;
  //   SkVerification _verification = SkVerification.none;
  //   bool _voiceAllowed = false; bool _photosAllowed = false;

  // ---- which child ------------------------------------------------------------

  /// The child whose space is open: the one last opened, else the first who
  /// has a yes, else any record, else null (no space yet).
  ///
  /// ⚠️ AN OPENED CHILD STAYS OPEN EVEN WITH NO SPACE YET. Falling back to
  /// "the first child with a yes" there would show her brother's space on
  /// her page; with no record, every getter reads empty and the gate asks.
  String? get openId {
    _tryAdopt();
    if (_openId != null) return _openId;
    for (final e in _children.entries) {
      if (e.value.consented) return e.key;
    }
    return _children.isEmpty ? null : _children.keys.first;
  }

  _SkChild? get _cur {
    final id = openId;
    return id == null ? null : _children[id];
  }

  /// Open [childId]'s space. Every getter, and every store that reads the
  /// open child, answers for this child from now on.
  void open(String childId) {
    _tryAdopt();
    if (_openId == childId) return;
    _openId = childId;
    _save();
    notifyListeners();
  }

  /// The child the pre-F5 space belonged to, once known; else [kLegacyId].
  String get legacyOwner => _legacyOwner ?? kLegacyId;

  /// Whose an entry is. An entry written before F5 carries no child and is
  /// the legacy owner's (the one space there was).
  String ownerOf(String? taggedChild) => taggedChild ?? legacyOwner;

  /// Is [taggedChild]'s entry the open child's? The keepsake stores read
  /// through this, so a child only ever sees her own.
  ///
  /// With no child open (no space yet), the one-space id stands in, as
  /// before F5: what is written then is untagged, and reads back.
  bool isOpen(String? taggedChild) =>
      ownerOf(taggedChild) == (openId ?? kLegacyId);

  bool consentedFor(String childId) {
    _tryAdopt();
    return _children[childId]?.consented ?? false;
  }

  /// Every child who has a space with a grown-up's yes.
  Set<String> get consentedIds {
    _tryAdopt();
    return {
      for (final e in _children.entries)
        if (e.value.consented) e.key,
    };
  }

  String nameFor(String childId) => (_children[childId]?.name ?? '').trim();

  DateTime? dobFor(String childId) {
    _tryAdopt();
    return _children[childId]?.dob;
  }

  int? ageYearsFor(String childId) {
    final d = _children[childId]?.dob;
    return d == null ? null : _yearsSince(d);
  }

  /// A record no parenting child matches (a family that joined at the
  /// learning space before onboarding added the parenting child): the family
  /// switch shows it as its own row. '' when there is none.
  String get unmatchedName {
    _tryAdopt();
    return nameFor(kLegacyId);
  }

  /// The pre-F5 record finds its child: the parenting child with its date of
  /// birth (and name, if two share a birthday). Runs whenever a reader asks,
  /// because the parenting store may load after this one.
  void _tryAdopt() {
    final legacy = _children[kLegacyId];
    if (legacy == null || legacy.dob == null) return;
    final kids = ChildProfileStore.instance;
    if (!kids.hasRealChild) return;
    final d = legacy.dob!;
    final same = [
      for (final c in kids.children)
        if (c.dob.year == d.year && c.dob.month == d.month && c.dob.day == d.day) c,
    ];
    Child? match;
    if (same.length == 1) {
      match = same.single;
    } else if (same.length > 1) {
      final n = (legacy.name ?? '').trim().toLowerCase();
      final named = same.where((c) => c.name.trim().toLowerCase() == n).toList();
      if (named.length == 1) match = named.single;
    }
    if (match == null || _children.containsKey(match.id)) return;
    _children
      ..remove(kLegacyId)
      ..[match.id] = legacy;
    _legacyOwner = match.id;
    if (_openId == kLegacyId || _openId == null) _openId = match.id;
    _save();
  }

  // ---- the open child (the screens read these) ------------------------------

  /// ⚠️ OFF BY DEFAULT. The Communication tasks on recording a child's
  /// voice: "Optional, off by default, only with parent setup and consent.
  /// On-device only, minimal retention, parent-deletable." The gate's
  /// consent covers the record; this switch is the parent's separate yes
  /// to recording, flipped on the grown-up screen. Until it is on, no
  /// child screen shows a record row and the keepsake screen invites the
  /// parent to turn it on. Per child since F5.
  bool get voiceAllowed => _cur?.voiceAllowed ?? false;

  void setVoiceAllowed(bool on) {
    final c = _cur;
    if (c == null) return;
    c.voiceAllowed = on;
    _save();
    notifyListeners();
  }

  /// ⚠️ OFF BY DEFAULT, THE SAME POSTURE AS VOICE. The Making brief on
  /// saved work: "a photo of a child's art can show her face or name;
  /// treat saved work like the voice keepsake … gated behind explicit
  /// parent consent … on-device where possible, minimal retention, parent
  /// can delete. NEVER analyse, grade, judge or profile the saved work."
  /// The parent's separate yes to keeping photos (2026-09-18). Per child.
  bool get photosAllowed => _cur?.photosAllowed ?? false;

  void setPhotosAllowed(bool on) {
    final c = _cur;
    if (c == null) return;
    c.photosAllowed = on;
    _save();
    notifyListeners();
  }

  /// The name the learning screens say. Never a "your baby" fallback: a
  /// skilling child is six or more and has a name or the screens use "you".
  String get name => (_cur?.name ?? '').trim();
  String get nameOrYou => name.isEmpty ? 'you' : name;

  DateTime? get dob => _cur?.dob;

  /// Whole years, or null before the gate has run.
  int? get ageYears {
    final d = dob;
    return d == null ? null : _yearsSince(d);
  }

  /// Her band, or null under the floor or before the gate.
  SkBand? get band {
    final y = ageYears;
    return y == null ? null : skBandFor(y);
  }

  /// True under the floor — the "all child tabs locked" state.
  bool get underFloor => ageYears != null && ageYears! < kSkAgeFloor;

  /// The lawful front door has been passed, for the open child.
  bool get consented => _cur?.consented ?? false;
  DateTime? get consentedAt => _cur?.consentedAt;
  SkVerification get verification => _cur?.verification ?? SkVerification.none;

  bool get hasPin => _pinHash != null && _pinSalt != null;

  // ---- the parenting hand-off ----------------------------------------------

  /// [c], if she is old enough for this stage: what the gate pre-fills. The
  /// child whose card was tapped, never "the first child of six" (F5: with two
  /// children of six or more, the gate filled in the elder for the younger).
  SkChildSuggestion? suggestionFor(Child c) {
    if (_yearsSince(c.dob) < kSkAgeFloor) return null;
    return SkChildSuggestion(name: c.name == Child.placeholder ? '' : c.name, dob: c.dob);
  }

  /// The parenting child, if she is old enough for this stage. Read, never
  /// written: the parenting record stays the parenting record. The active
  /// child first (F5), else the first child of six or more, as before.
  SkChildSuggestion? get suggestion {
    final s = ChildProfileStore.instance;
    if (!s.hasRealChild) return null;
    final active = suggestionFor(s.active);
    if (active != null) return active;
    for (final c in s.children) {
      final sug = suggestionFor(c);
      if (sug != null) return sug;
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

  String _target(String? childId) => childId ?? openId ?? kLegacyId;

  /// The gate's one write: name, date of birth, consent, and what the
  /// verifier said, for [childId] (else the open child). That child's space
  /// becomes the open one. Setting a PIN is separate and optional.
  void consent({
    required String name,
    required DateTime dob,
    required SkVerification verification,
    String? childId,
  }) {
    final id = _target(childId);
    final c = _children.putIfAbsent(id, _SkChild.new);
    c
      ..name = name.trim()
      ..dob = DateTime(dob.year, dob.month, dob.day)
      ..consentedAt = DateTime.now()
      ..verification = verification;
    _openId = id;
    _save();
    notifyListeners();
  }

  /// Change the child without re-consenting — the settings screen's edit,
  /// and onboarding's first write ([childId]: the parenting child it added).
  void update({String? name, DateTime? dob, String? childId}) {
    final id = _target(childId);
    final c = _children.putIfAbsent(id, _SkChild.new);
    if (name != null) c.name = name.trim();
    if (dob != null) c.dob = DateTime(dob.year, dob.month, dob.day);
    _openId ??= id;
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

  /// Withdraw consent for the OPEN child: her record is gone, and her door
  /// goes back to the gate. The parent's right under the law the brief
  /// cites, one tap. Since F5 the other children's spaces stay; the PIN goes
  /// only with the last space. The caller removes her entries from the
  /// keepsake stores first (`forgetChild`).
  void forget() {
    final id = openId;
    if (id != null) _children.remove(id);
    if (id == _legacyOwner) _legacyOwner = null;
    _openId = null;
    if (_children.isEmpty) {
      _pinHash = null;
      _pinSalt = null;
    }
    _save();
    notifyListeners();
  }

  /// Every space, the PIN with them.
  void forgetAll() {
    _children.clear();
    _openId = null;
    _legacyOwner = null;
    _pinHash = null;
    _pinSalt = null;
    _save();
    notifyListeners();
  }

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  // forget() also writes prefs, so this one touches memory only.
  void _resetForAccount() {
    _children.clear();
    _openId = null;
    _legacyOwner = null;
    _pinHash = null;
    _pinSalt = null;
    _loaded = false;
    notifyListeners();
  }

  /// Test-only: set an age directly, for [childId] (else the open child, else
  /// the legacy id), and open that child.
  @visibleForTesting
  void debugSetAgeYears(int years, {String name = 'Aarav', String? childId}) {
    final now = DateTime.now();
    final id = childId ?? _openId ?? kLegacyId;
    final c = _children.putIfAbsent(id, _SkChild.new);
    c
      ..name = name
      ..dob = DateTime(now.year - years, now.month, now.day)
          .subtract(const Duration(days: 3))
      ..consentedAt ??= now
      ..verification = SkVerification.stub;
    _openId = id;
    _loaded = true;
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    forgetAll();
    _loaded = true;
  }

  // ---- persistence ----------------------------------------------------------

  /// v2 (F5): `{v: 2, open, legacyOwner, pinHash, pinSalt, children: {id:
  /// {...}}}`. v1 was one child's fields at the top level; it still loads,
  /// as the legacy record, and the next save writes v2.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      _pinHash = j['pinHash'] as String?;
      _pinSalt = j['pinSalt'] as String?;
      if (j['v'] == 2) {
        final kids = (j['children'] as Map?) ?? const {};
        for (final e in kids.entries) {
          _children[e.key as String] =
              _SkChild.fromJson(Map<String, dynamic>.from(e.value as Map));
        }
        _openId = j['open'] as String?;
        _legacyOwner = j['legacyOwner'] as String?;
      } else {
        // v1: the one space there was.
        _children[kLegacyId] = _SkChild.fromJson(j);
      }
      _tryAdopt();
    } catch (_) {
      // A corrupt record reads as no record. The gate asks again.
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_children.isEmpty && _pinHash == null) {
        await prefs.remove(_key);
        return;
      }
      await prefs.setString(
          _key,
          jsonEncode({
            'v': 2,
            'open': _openId,
            'legacyOwner': _legacyOwner,
            'pinHash': _pinHash,
            'pinSalt': _pinSalt,
            'children': {
              for (final e in _children.entries) e.key: e.value.toJson(),
            },
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

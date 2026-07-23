// =============================================================================
//  ChildProfileStore - the child's editable identity + growth
// -----------------------------------------------------------------------------
//  Holds who the child is (name, sex, date of birth) and the latest growth
//  measurements. It powers the My Child header, the inline growth edit, and -
//  via age-in-weeks - which developmental leap is current. A tiny WHO-style
//  reference table gives the "expected for his age" figures shown alongside the
//  child's own.
//
//  THE PARENTING KEYSTONE: every other parenting feature keys its rows to a
//  child_id from here, so this store loads first and everything else follows.
//
//  MULTIPLE CHILDREN: the store keeps a LIST and an active child. The old flat
//  API (name / isBoy / dob / weightKg / ...) is preserved as getters onto the
//  ACTIVE child, so all ~31 existing read sites keep working untouched - the
//  multi-child support sits underneath them. (The child-switcher UI is still
//  "Coming soon"; the data layer no longer is.)
//
//  CO-PARENTED: a child row is shared by BOTH paired parents - one row per baby,
//  not one per parent - and either may edit it. See 0021_children.sql.
//
//  LOCAL-FIRST: shared_preferences is the source for instant/offline reads;
//  Supabase syncs on top. Logged out, everything below still works.
//
//  SEEDED DEFAULT: with no saved child the store shows a seeded placeholder
//  (Aarav) that is deliberately NEVER written to the database - otherwise every
//  new account would be born with a fake baby. It becomes a real, persisted
//  child the moment a parent saves real details. Same rule the pregnancy side
//  uses for the week-20 no-due-date default.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';

/// Expected 50th-centile figures for a given age, used as a gentle reference
/// (never a pass/fail). Values approximate the WHO boy standards.
class GrowthRef {
  const GrowthRef(this.weightKg, this.heightCm, this.headCm);
  final double weightKg;
  final double heightCm;
  final double headCm;
}

const Map<int, GrowthRef> _boyRef = {
  0: GrowthRef(3.3, 49.9, 34.5),
  1: GrowthRef(4.5, 54.7, 37.3),
  2: GrowthRef(5.6, 58.4, 39.1),
  3: GrowthRef(6.4, 61.4, 40.5),
  4: GrowthRef(7.0, 63.9, 41.6),
  5: GrowthRef(7.5, 65.9, 42.6),
  6: GrowthRef(7.9, 67.6, 43.3),
  7: GrowthRef(8.3, 69.2, 44.0),
  8: GrowthRef(8.6, 70.6, 44.5),
  9: GrowthRef(8.9, 72.0, 45.0),
  10: GrowthRef(9.2, 73.3, 45.4),
  11: GrowthRef(9.4, 74.5, 45.8),
  12: GrowthRef(9.6, 75.7, 46.1),
};

const Map<int, GrowthRef> _girlRef = {
  0: GrowthRef(3.2, 49.1, 33.9),
  1: GrowthRef(4.2, 53.7, 36.5),
  2: GrowthRef(5.1, 57.1, 38.3),
  3: GrowthRef(5.8, 59.8, 39.5),
  4: GrowthRef(6.4, 62.1, 40.6),
  5: GrowthRef(6.9, 64.0, 41.5),
  6: GrowthRef(7.3, 65.7, 42.2),
  7: GrowthRef(7.6, 67.3, 42.8),
  8: GrowthRef(7.9, 68.7, 43.4),
  9: GrowthRef(8.2, 70.1, 43.8),
  10: GrowthRef(8.5, 71.5, 44.2),
  11: GrowthRef(8.7, 72.8, 44.6),
  12: GrowthRef(8.9, 74.0, 44.9),
};

GrowthRef expectedGrowth(int months, {bool boy = true}) {
  final m = months.clamp(0, 12);
  final table = boy ? _boyRef : _girlRef;
  return table[m] ?? table[12]!;
}

/// One child. `id` is client-generated so the local row and the cloud row share
/// an id (the house rule - makes sync a plain id-keyed merge).
class Child {
  Child({
    required this.id,
    required this.name,
    required this.isBoy,
    required this.dob,
    required this.weightKg,
    required this.heightCm,
    required this.headCm,
  });

  final String id;
  String name;
  bool isBoy;
  DateTime dob;
  double weightKg;
  double heightCm;
  double headCm;

  Child copyWith({String? id}) => Child(
        id: id ?? this.id,
        name: name,
        isBoy: isBoy,
        dob: dob,
        weightKg: weightKg,
        heightCm: heightCm,
        headCm: headCm,
      );

  /// 'YYYY-MM-DD' for the `dob date` column (and the local cache).
  static String _dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isBoy': isBoy,
        'dob': _dateKey(dob),
        'weightKg': weightKg,
        'heightCm': heightCm,
        'headCm': headCm,
      };

  factory Child.fromJson(Map<String, dynamic> j) => Child(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        isBoy: j['isBoy'] != false,
        dob: DateTime.tryParse((j['dob'] ?? '').toString()) ?? DateTime.now(),
        weightKg: (j['weightKg'] as num?)?.toDouble() ?? 0,
        heightCm: (j['heightCm'] as num?)?.toDouble() ?? 0,
        headCm: (j['headCm'] as num?)?.toDouble() ?? 0,
      );

  // camelCase model <-> snake_case columns. `user_id` is NOT here: on insert
  // SupabaseRepo attaches it (it records WHO created the child, not who may
  // touch it - access runs through public.my_child_ids()).
  Map<String, dynamic> toRow() => {
        'id': id,
        'name': name,
        'is_boy': isBoy,
        'dob': _dateKey(dob),
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'head_cm': headCm,
      };

  factory Child.fromRow(Map<String, dynamic> r) => Child(
        id: (r['id'] ?? '').toString(),
        name: (r['name'] ?? '').toString(),
        isBoy: r['is_boy'] != false,
        dob: DateTime.tryParse((r['dob'] ?? '').toString()) ?? DateTime.now(),
        weightKg: (r['weight_kg'] as num?)?.toDouble() ?? 0,
        heightCm: (r['height_cm'] as num?)?.toDouble() ?? 0,
        headCm: (r['head_cm'] as num?)?.toDouble() ?? 0,
      );
}

class ChildProfileStore extends ChangeNotifier {
  ChildProfileStore._();
  static final ChildProfileStore instance = ChildProfileStore._();

  static const _childrenKey = 'pp_children';
  static const _activeKey = 'pp_active_child';

  final List<Child> _children = [];
  String? _activeId;
  bool _loaded = false;

  /// The placeholder shown before any real child is saved. Never persisted -
  /// note the empty id, which is what marks it as "not a real child yet".
  /// The placeholder shown before a parent has saved her child.
  ///
  /// It carries a name and a date of birth ONLY so the app has an age to work
  /// from and does not open as a blank shell - those are replaced the moment she
  /// saves real details.
  ///
  /// The MEASUREMENTS are deliberately 0 = "not recorded". They used to be
  /// 6.4 kg / 63 cm / 41 cm, so every parent opened My Child to find a weight
  /// and height already filled in for a baby that was not hers. A measurement
  /// is a fact about one specific child: it can only come from the parent (or
  /// from a growth measurement she logs), never from us.
  ///
  /// The DATE OF BIRTH is today, i.e. age zero, for exactly the same reason.
  /// It used to be `now - 120 days`, which invented a four-month-old: My Child
  /// opened claiming "3 months", sat the journey bar a twentieth of the way
  /// along, and served phase content for a baby whose birthday nobody had
  /// entered. An age is a fact about one specific child, no different from a
  /// weight - the measurements were fixed for this reason and the date of birth
  /// was missed. At zero the journey starts at the beginning, which is the
  /// honest position for a child we know nothing about yet.
  static final Child _seed = Child(
    id: '',
    name: 'Your baby',
    isBoy: true,
    dob: DateTime.now(),
    weightKg: 0,
    heightCm: 0,
    headCm: 0,
  );

  /// True when [v] is a real recorded measurement rather than "not recorded".
  static bool hasValue(double v) => v > 0;

  // --- multi-child -----------------------------------------------------------

  /// Every saved child (empty until a parent saves real details).
  List<Child> get children => List.unmodifiable(_children);

  /// True once a real child exists - i.e. we're no longer on the seeded default.
  bool get hasRealChild => _children.isNotEmpty;

  /// The child every flat getter below reads from. Falls back to the seed.
  Child get active {
    if (_children.isEmpty) return _seed;
    for (final c in _children) {
      if (c.id == _activeId) return c;
    }
    return _children.first;
  }

  /// The active child's id, or null while on the seeded default. This is the
  /// `child_id` every other parenting store keys its rows to.
  String? get activeChildId => _children.isEmpty ? null : active.id;

  /// Test-only: drop back to the seeded placeholder. The store is a singleton,
  /// so a test that saves a child leaks it into everything that runs after -
  /// including a 6.4 kg weight, since logging growth also writes the child's
  /// latest figures. Synchronous and local-only on purpose.
  @visibleForTesting
  void resetForTest() {
    _children.clear();
    _activeId = null;
    notifyListeners();
  }

  Future<void> switchTo(String childId) async {
    if (!_children.any((c) => c.id == childId)) return;
    _activeId = childId;
    notifyListeners();
    await _persist();
  }

  /// Set the active child's date of birth WITHOUT persisting — tests only.
  ///
  /// [update] is the real path, but it awaits SharedPreferences, which never
  /// answers under flutter_test: a test that called it simply hung until the
  /// ten-minute timeout. Tests that need a child of a given age (milestones and
  /// recommendations are both age-filtered) state it through here instead of
  /// leaning on whatever the placeholder happens to claim — which is how two of
  /// them ended up silently depending on an invented four-month-old.
  @visibleForTesting
  void debugSetDob(DateTime dob) {
    final promoting = _children.isEmpty;
    final c = promoting ? _seed.copyWith(id: 'child_test') : active;
    c.dob = dob;
    if (promoting) {
      _children.add(c);
      _activeId = c.id;
    }
    notifyListeners();
  }

  /// Add a second/third child and make them active.
  Future<Child> addChild({
    required String name,
    required bool isBoy,
    required DateTime dob,
    double weightKg = 0,
    double heightCm = 0,
    double headCm = 0,
  }) async {
    final c = Child(
      id: 'child_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      isBoy: isBoy,
      dob: dob,
      weightKg: weightKg,
      heightCm: heightCm,
      headCm: headCm,
    );
    _children.add(c);
    _activeId = c.id;
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.insert('children', c.toRow());
      } catch (_) {/* offline - pushed up on next sync */}
    }
    return c;
  }

  Future<void> deleteChild(String childId) async {
    _children.removeWhere((c) => c.id == childId);
    if (_activeId == childId) _activeId = _children.isEmpty ? null : _children.first.id;
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        // Co-parented: deleteShared, so either parent can remove the child.
        await SupabaseRepo.deleteShared('children', childId);
      } catch (_) {}
    }
  }

  // --- load + sync -----------------------------------------------------------

  Future<void> init() async {
    if (_loaded) return;
    // 1) Local cache first (instant, offline-capable).
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_childrenKey);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _children.add(Child.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      _activeId = prefs.getString(_activeKey);
    } catch (_) {/* start on the seeded default */}
    _loaded = true;
    notifyListeners();

    // 2) Then the cloud (no-op when logged out).
    await _syncFromCloud();
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // fetchShared, NOT fetch: a co-parented read. This returns MY children
      // AND my partner's - which is how the second parent to sign in adopts the
      // baby the first parent already created, rather than making a duplicate.
      final rows = await SupabaseRepo.fetchShared(
        'children',
        orderBy: 'created_at',
        ascending: true,
      );
      final byId = {for (final r in rows) r['id'].toString(): Child.fromRow(r)};

      // Push up any child saved locally while logged out / offline.
      for (final c in _children) {
        if (!byId.containsKey(c.id)) {
          byId[c.id] = c;
          await SupabaseRepo.insert('children', c.toRow());
        }
      }

      _children
        ..clear()
        ..addAll(byId.values);
      if (!_children.any((c) => c.id == _activeId)) {
        _activeId = _children.isEmpty ? null : _children.first.id;
      }
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  // ⚠️ FLAGGED (see BACKEND-PLAN "parenting flags"): if a parent saves a real
  // child BEFORE pairing, and their partner has already saved one for the same
  // baby, pairing leaves TWO child rows for one baby. We deliberately do NOT
  // auto-merge - two rows might genuinely be twins, and guessing wrong would
  // silently fuse two babies' records. Needs a product decision (+ the child
  // switcher UI) so a parent can resolve it themselves.

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _childrenKey, jsonEncode(_children.map((e) => e.toJson()).toList()));
      final a = _activeId;
      if (a == null) {
        await prefs.remove(_activeKey);
      } else {
        await prefs.setString(_activeKey, a);
      }
    } catch (_) {}
  }

  // --- the flat API the screens already use (reads the ACTIVE child) ---------

  String get name => active.name;
  bool get isBoy => active.isBoy;
  DateTime get dob => active.dob;
  double get weightKg => active.weightKg;
  double get heightCm => active.heightCm;
  double get headCm => active.headCm;

  // If the device clock puts the child in the future (bad clock / demo machine),
  // fall back to ~4 months so the app still shows a sensible, seeded stage.
  /// Age straight from the date of birth. NO FALLBACK, deliberately.
  ///
  /// This used to read `return w >= 1 ? w : 18;` — any child under a week old
  /// was reported as eighteen weeks. That did not just affect the placeholder:
  /// a mother entering her three-day-old's real birthday was told he was four
  /// months, and served four-month phases, milestones and growth expectations.
  /// The newborns, where getting it right matters most, were the ones it broke.
  ///
  /// A newborn is zero weeks old. That is a real answer, and the app has a
  /// fourth-trimester phase built precisely for it.
  double get ageInWeeks {
    final w = DateTime.now().difference(dob).inDays / 7.0;
    return w > 0 ? w : 0;
  }

  int get ageInDays => (ageInWeeks * 7).round();
  int get ageInMonths => (ageInWeeks / 4.345).floor();

  /// "4 months 1 week" / "6 weeks" — a warm, human age label.
  String get ageLabel {
    final months = ageInMonths;
    if (months < 1) {
      final w = ageInWeeks.floor();
      return '$w ${w == 1 ? 'week' : 'weeks'}';
    }
    final remWeeks = (ageInWeeks - months * 4.345).floor();
    final mLabel = '$months ${months == 1 ? 'month' : 'months'}';
    if (remWeeks <= 0) return mLabel;
    return '$mLabel $remWeeks ${remWeeks == 1 ? 'week' : 'weeks'}';
  }

  GrowthRef get expected => expectedGrowth(ageInMonths, boy: isBoy);

  // ---- pronouns ------------------------------------------------------------
  //  Copy across the parenting app hardcoded "his"/"he" (and in places the name
  //  "Aarav"), so a parent of a daughter read about somebody else's son. These
  //  follow the ACTIVE child, and switching children switches the copy.

  /// "he" / "she"
  String get they => isBoy ? 'he' : 'she';

  /// "his" / "her" - possessive determiner ("his own curve").
  String get their => isBoy ? 'his' : 'her';

  /// "him" / "her" - object pronoun ("hold him").
  String get them => isBoy ? 'him' : 'her';

  /// Sentence-initial "He" / "She".
  String get theyCap => isBoy ? 'He' : 'She';

  /// A one-line, non-judgemental read on where the child sits vs the reference.
  String get growthNote =>
      '$name is growing along $their own steady curve. The figures below sit close to the typical range for $their age — nothing here needs attention.';

  /// Edit the active child. Unchanged signature + call sites - it just persists
  /// now (returns a Future the existing fire-and-forget callers can ignore).
  ///
  /// If we're still on the seeded default, saving here is what PROMOTES it into
  /// a real child: it gets a real id, gets written locally, and is inserted in
  /// the cloud. That's the line between "app showing a placeholder" and "this
  /// family has a baby on record".
  Future<void> update({
    String? name,
    bool? isBoy,
    DateTime? dob,
    double? weightKg,
    double? heightCm,
    double? headCm,
  }) async {
    final promoting = _children.isEmpty;
    // Promote the seed (via copyWith, so the shared _seed itself is never
    // mutated - it must stay pristine for the next logged-out/fresh account).
    final c = promoting
        ? _seed.copyWith(id: 'child_${DateTime.now().microsecondsSinceEpoch}')
        : active;

    if (name != null && name.trim().isNotEmpty) c.name = name.trim();
    if (isBoy != null) c.isBoy = isBoy;
    if (dob != null) c.dob = dob;
    if (weightKg != null) c.weightKg = weightKg;
    if (heightCm != null) c.heightCm = heightCm;
    if (headCm != null) c.headCm = headCm;

    if (promoting) {
      _children.add(c);
      _activeId = c.id;
    }
    notifyListeners();
    await _persist();

    if (SupabaseRepo.isLoggedIn) {
      try {
        if (promoting) {
          await SupabaseRepo.insert('children', c.toRow());
        } else {
          // updateShared: co-parented, so either parent may edit the child.
          await SupabaseRepo.updateShared('children', c.id, c.toRow());
        }
      } catch (_) {/* offline - reconciled on the next sync */}
    }
  }
}

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

import 'pp_who_growth_lms.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/supabase_repo.dart';
import '../../care_partner/care_journey.dart';
import '../../services/remote/sync_registry.dart';
import '../../services/remote/sync_row_book.dart';
import '../../services/family_profile.dart';

/// Expected 50th-centile figures for a given age, used as a gentle reference
/// (never a pass/fail). Values approximate the WHO boy standards.
class GrowthRef {
  const GrowthRef(this.weightKg, this.heightCm, this.headCm);
  final double weightKg;
  final double heightCm;
  final double headCm;
}

// ⚠️ REPLACED 2026-10-02 by the WHO tables in pp_who_growth_lms.dart, which
// run to five years (these stopped at 12 months and clamped every older
// child to a one-year-old). Kept for revert:
// const Map<int, GrowthRef> _boyRef = {
//   0: GrowthRef(3.3, 49.9, 34.5),
//   1: GrowthRef(4.5, 54.7, 37.3),
//   2: GrowthRef(5.6, 58.4, 39.1),
//   3: GrowthRef(6.4, 61.4, 40.5),
//   4: GrowthRef(7.0, 63.9, 41.6),
//   5: GrowthRef(7.5, 65.9, 42.6),
//   6: GrowthRef(7.9, 67.6, 43.3),
//   7: GrowthRef(8.3, 69.2, 44.0),
//   8: GrowthRef(8.6, 70.6, 44.5),
//   9: GrowthRef(8.9, 72.0, 45.0),
//   10: GrowthRef(9.2, 73.3, 45.4),
//   11: GrowthRef(9.4, 74.5, 45.8),
//   12: GrowthRef(9.6, 75.7, 46.1),
// };
//
// const Map<int, GrowthRef> _girlRef = {
//   0: GrowthRef(3.2, 49.1, 33.9),
//   1: GrowthRef(4.2, 53.7, 36.5),
//   2: GrowthRef(5.1, 57.1, 38.3),
//   3: GrowthRef(5.8, 59.8, 39.5),
//   4: GrowthRef(6.4, 62.1, 40.6),
//   5: GrowthRef(6.9, 64.0, 41.5),
//   6: GrowthRef(7.3, 65.7, 42.2),
//   7: GrowthRef(7.6, 67.3, 42.8),
//   8: GrowthRef(7.9, 68.7, 43.4),
//   9: GrowthRef(8.2, 70.1, 43.8),
//   10: GrowthRef(8.5, 71.5, 44.2),
//   11: GrowthRef(8.7, 72.8, 44.6),
//   12: GrowthRef(8.9, 74.0, 44.9),
// };
//
// GrowthRef expectedGrowth(int months, {bool boy = true}) {
//   final m = months.clamp(0, 12);
//   final table = boy ? _boyRef : _girlRef;
//   return table[m] ?? table[12]!;
// }

GrowthRef expectedGrowth(int months, {bool boy = true}) {
  final a = months.clamp(0, kWhoMaxMonths).toDouble();
  return GrowthRef(
    _round1(whoLms(WhoIndicator.weight, boy, a).$2),
    _round1(whoLms(WhoIndicator.length, boy, a).$2),
    _round1(whoLms(WhoIndicator.head, boy, a).$2),
  );
}

double _round1(double v) => (v * 10).round() / 10;

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
    this.birthWeightKg = 0,
    this.sexGiven = true,
    this.birthMode,
    this.bornWeeks,
  });

  /// How the baby was born, as a `BirthMode` name (normal, cSection, assisted,
  /// notSaid), or null if never said. Onboarding V3, 2026-10-17.
  ///
  /// A plain String rather than the enum because the enum lives in the family
  /// profile, which already imports this file. The family profile stays the
  /// reader on the phone that asked; this copy is how the OTHER parent's phone
  /// learns it (`children.birth_mode`, 0102).
  String? birthMode;

  /// Weeks of pregnancy at birth when born early, else null (0102).
  int? bornWeeks;

  final String id;
  String name;
  bool isBoy;

  /// False when the parent skipped "Boy or girl". Then [isBoy] is only a
  /// stand-in (the cloud column is `not null`), and nothing may call the child
  /// "he" or "she": the pronoun getters on [ChildProfileStore] use the name or
  /// "your baby" instead. Gap analysis P1 (2026-10-02): a skipped answer used
  /// to be saved as a boy, and every page then said "him".
  ///
  /// Local only until the user runs the migration that adds `sex_given` to
  /// public.children; see [kChildSexGivenColumn].
  bool sexGiven;
  DateTime dob;
  double weightKg;
  double heightCm;
  double headCm;

  /// What they weighed AT BIRTH, in kg. 0 = not recorded.
  ///
  /// Kept apart from [weightKg], which is the latest measurement. They are
  /// different facts and conflating them would quietly rewrite history every
  /// time a parent updated the current weight.
  double birthWeightKg;

  /// The placeholder used until a parent saves a real child.
  ///
  /// It reads correctly at the START of a sentence and as a standalone title -
  /// "Your baby", the header on My Child. It reads WRONG anywhere else, and
  /// almost every use is anywhere else: "How Your baby is doing", "Help Your
  /// baby grow", "for Your baby's higher education". A capital letter in the
  /// middle of a sentence is the single most common way a template gives away
  /// that it is a template.
  static const placeholder = 'Your baby';

  /// The name as it should appear INSIDE a sentence.
  ///
  /// A real name is a proper noun and keeps its capital: "How Aarav is doing".
  /// The placeholder is not a name at all, so it lowercases: "How your baby is
  /// doing". One getter rather than a lowercase() at every call site, because
  /// lowercasing a real name would be worse than the bug it fixed.
  String get nameMid => name == placeholder ? 'your baby' : name;

  Child copyWith({String? id}) => Child(
        id: id ?? this.id,
        name: name,
        isBoy: isBoy,
        dob: dob,
        weightKg: weightKg,
        heightCm: heightCm,
        headCm: headCm,
        birthWeightKg: birthWeightKg,
        sexGiven: sexGiven,
        birthMode: birthMode,
        bornWeeks: bornWeeks,
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
        'birthWeightKg': birthWeightKg,
        'sexGiven': sexGiven,
        'birthMode': birthMode,
        'bornWeeks': bornWeeks,
      };

  factory Child.fromJson(Map<String, dynamic> j) => Child(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        isBoy: j['isBoy'] != false,
        dob: DateTime.tryParse((j['dob'] ?? '').toString()) ?? DateTime.now(),
        weightKg: (j['weightKg'] as num?)?.toDouble() ?? 0,
        heightCm: (j['heightCm'] as num?)?.toDouble() ?? 0,
        headCm: (j['headCm'] as num?)?.toDouble() ?? 0,
        birthWeightKg: (j['birthWeightKg'] as num?)?.toDouble() ?? 0,
        sexGiven: j['sexGiven'] != false,
        birthMode: j['birthMode'] as String?,
        bornWeeks: (j['bornWeeks'] as num?)?.toInt(),
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
        // Only once the column exists: PostgREST rejects a row naming an
        // unknown column, and a rejected fire-and-forget write is silent.
        if (kChildSexGivenColumn) 'sex_given': sexGiven,
        if (kChildBirthColumns) 'birth_mode': birthMode,
        if (kChildBirthColumns) 'born_weeks': bornWeeks,
      };

  factory Child.fromRow(Map<String, dynamic> r) => Child(
        id: (r['id'] ?? '').toString(),
        name: (r['name'] ?? '').toString(),
        isBoy: r['is_boy'] != false,
        dob: DateTime.tryParse((r['dob'] ?? '').toString()) ?? DateTime.now(),
        weightKg: (r['weight_kg'] as num?)?.toDouble() ?? 0,
        heightCm: (r['height_cm'] as num?)?.toDouble() ?? 0,
        headCm: (r['head_cm'] as num?)?.toDouble() ?? 0,
        // Reads the column if it is there, tolerates it not being there. The
        // migration adding birth_weight_kg to public.children has not been
        // written yet (STILL-OPEN), and a client that crashed on a missing
        // column would take the whole child list down with it.
        birthWeightKg: (r['birth_weight_kg'] as num?)?.toDouble() ?? 0,
        // Missing column (migration not run) reads as "given", and the sync
        // below then keeps the phone's own answer rather than this default.
        sexGiven: r['sex_given'] != false,
        birthMode: r['birth_mode'] as String?,
        bornWeeks: (r['born_weeks'] as num?)?.toInt(),
      );
}

/// Flip to true once `supabase/migrations/0102_onboarding_v3.sql` has been
/// run on the live database. Until then birth mode and born-early weeks stay
/// on this phone (the child's local copy and the family profile).
/// Run on the live database 2026-10-17 (the user).
const bool kChildBirthColumns = true;

/// Flip to true once `supabase/migrations/0093_children_sex_given.sql` has
/// been run. Until then `sex_given` is kept on this phone only.
/// Run and verified on the live database 2026-10-16.
const bool kChildSexGivenColumn = true;

// -----------------------------------------------------------------------------
//  Sync, newer wins (2026-10-20, sync log step 7, migration 0105)
// -----------------------------------------------------------------------------
//  Whole row, latest edit wins (the user's decision). Two things are special
//  about this table:
//
//   · It is the ACCESS ROOT. Every pp_* policy asks public.my_child_ids(),
//     which reads children.user_id. So a removal is a soft delete (the row
//     stays, and with it both parents' access to the records), and the push
//     NEVER sends user_id for a child the other parent created: it goes as a
//     plain UPDATE, because an upsert is checked against the INSERT policy
//     (auth.uid() = user_id) and would be refused.
//
//   · The growth figures are a MIRROR of the growth log, which syncs on its
//     own. They do not move the clock ([ChildProfileStore.setMeasures]), and
//     a cloud row taken here keeps this phone's figures. Otherwise a weight
//     logged on a phone that had not pulled yet would undo the other parent's
//     rename.
//
//  The two functions below are pure, so the rule is tested without a network
//  (`test/pp_children_sync_test.dart`).

/// Pure: merges the cloud's `children` [rows] into this phone's [live] and
/// [removed] children, newer wins per child. Returns the new two lists. Rows
/// this phone holds that are newer, or that the cloud has never seen, are
/// left in [book]'s waiting set for the next upload.
({List<Child> live, List<Child> removed}) childrenMerge({
  required SyncRowBook book,
  required List<Child> live,
  required List<Child> removed,
  required List<Map<String, dynamic>> rows,
}) {
  final known = <String, Child>{
    for (final c in removed) c.id: c,
    for (final c in live) c.id: c,
  };
  final liveById = <String, Child>{for (final c in live) c.id: c};
  final removedById = <String, Child>{for (final c in removed) c.id: c};
  final taken = book.merge(
    [for (final c in live) if (c.id.isNotEmpty) c.id],
    rows,
  );
  for (final r in taken) {
    final id = r['id'] as String;
    final c = Child.fromRow(r);
    final mine = known[id];
    if (mine != null) {
      // A cloud row without `sex_given` (an older app wrote it) must not turn
      // a child whose sex was not given back into a boy; the same for the
      // birth columns (0102) while they are empty.
      if (!r.containsKey('sex_given')) c.sexGiven = mine.sexGiven;
      c.birthMode ??= mine.birthMode;
      c.bornWeeks ??= mine.bornWeeks;
      // The growth figures are this phone's own, worked out from the growth
      // log: never taken from another phone's row.
      c
        ..weightKg = mine.weightKg
        ..heightCm = mine.heightCm
        ..headCm = mine.headCm;
      if (c.birthWeightKg == 0) c.birthWeightKg = mine.birthWeightKg;
    }
    if (syncParseStamp(r['removed_at']) != null) {
      liveById.remove(id);
      removedById[id] = c;
    } else {
      removedById.remove(id);
      liveById[id] = c;
    }
  }
  return (live: liveById.values.toList(), removed: removedById.values.toList());
}

/// Pure: what uploading child [id] sends, or null when there is nothing to
/// send. [child] is the child as this phone holds it (live or removed).
///
/// A child the other parent created goes as an UPDATE with no `id` or
/// `user_id`, so the owner, and with it who can reach the child's records,
/// never moves. Any other child is upserted as ours.
({bool asUpdate, Map<String, dynamic> row})? childUploadFor(
  SyncRowBook book,
  String id,
  Child? child, {
  required String uid,
}) {
  final cols = child?.toRow() ?? book.removedRows[id];
  if (cols == null) return null;
  final t = book.times(id);
  final row = <String, dynamic>{
    ...cols,
    'updated_at': t.updatedAt,
    'removed_at': t.removedAt,
  };
  final owner = book.owners[id];
  if (owner != null && owner != uid) {
    row
      ..remove('id')
      ..remove('user_id');
    return (asUpdate: true, row: row);
  }
  return (asUpdate: false, row: {...row, 'user_id': uid});
}

class ChildProfileStore extends ChangeNotifier {
  ChildProfileStore._();
  static final ChildProfileStore instance = ChildProfileStore._();

  static const _childrenKey = 'pp_children';
  static const _activeKey = 'pp_active_child';

  /// Children a parent removed, kept so they can be restored (2026-10-20).
  static const _removedKey = 'pp_children_removed';

  /// The sync bookkeeping beside the children (step 7, 0105).
  static const _bookKey = 'pp_children_sync';

  final List<Child> _children = [];
  String? _activeId;
  bool _loaded = false;

  /// Removed children: hidden everywhere, their records kept, restorable.
  final List<Child> _removed = [];

  final SyncRowBook _book = SyncRowBook();
  bool _pushing = false;
  bool _again = false;

  /// Children a parent removed, newest removal first. The You screen lists
  /// them so either parent can bring one back.
  List<Child> get removedChildren {
    final out = List.of(_removed);
    int at(Child c) => _book.removed[c.id] ?? 0;
    out.sort((a, b) => at(b).compareTo(at(a)));
    return List.unmodifiable(out);
  }

  /// Changes the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => _book.dirty.isNotEmpty;

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
    name: Child.placeholder,
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

  /// Every saved child's id (B11, 2026-10-25): a sync pulls each of them,
  /// not only the one on screen.
  List<String> get childIds => [for (final c in _children) c.id];

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
      // A baby joined the family. Counted (never named) on the referring
      // doctor's impact dashboard.
      CareJourney.childBorn();
    }
    notifyListeners();
  }

  // ⚠️ TWO CHILDREN, ONE ID (found 2026-10-25, tools pass). The id was the
  // clock alone, `child_<microseconds>`, and two children added back to back
  // (twins at onboarding, or a test) can land on the same tick on a phone
  // whose clock is coarse: then both are one child to every store, and each
  // twin's logs, answers and milestones merge. A counter after the clock, as
  // the feed ids have (`feed_<micros>_<n>`), keeps them apart. Ids already
  // saved keep their shape: nothing reads the id's parts.
  static int _childSeq = 0;
  static String _newChildId() => 'child_${DateTime.now().microsecondsSinceEpoch}_${_childSeq++}';

  /// Add a second/third child and make them active.
  Future<Child> addChild({
    required String name,
    required bool isBoy,
    required DateTime dob,
    bool sexGiven = true,
    double weightKg = 0,
    double heightCm = 0,
    double headCm = 0,
    double birthWeightKg = 0,
    String? birthMode,
    int? bornWeeks,
  }) async {
    final c = Child(
      id: _newChildId(), // was 'child_${DateTime.now().microsecondsSinceEpoch}'
      name: name.trim(),
      isBoy: isBoy,
      dob: dob,
      weightKg: weightKg,
      heightCm: heightCm,
      headCm: headCm,
      birthWeightKg: birthWeightKg,
      sexGiven: sexGiven,
      birthMode: birthMode,
      bornWeeks: bornWeeks,
    );
    _children.add(c);
    _activeId = c.id;
    _book.touch(c.id);
    notifyListeners();
    await _persist();
    // Kept for revert (step 7, 2026-10-20): a one-shot insert, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.insert('children', c.toRow());
    //   } catch (_) {/* offline - pushed up on next sync */}
    // }
    await _pushWaiting();
    return c;
  }

  /// Removes a child: a SOFT delete (the user, 2026-10-20). The child is
  /// hidden on both parents' phones and stays gone, and every record about
  /// them is kept, so [restoreChild] brings everything back.
  Future<void> deleteChild(String childId) async {
    final i = _children.indexWhere((c) => c.id == childId);
    if (i < 0) return;
    final c = _children.removeAt(i);
    _removed
      ..removeWhere((x) => x.id == childId)
      ..add(c);
    _book.remove(childId, c.toRow());
    if (_activeId == childId) _activeId = _children.isEmpty ? null : _children.first.id;
    notifyListeners();
    await _persist();
    // Kept for revert (step 7, 2026-10-20). A hard delete took the id out of
    // public.my_child_ids(), so the child's records became unreadable to both
    // parents, and the other phone inserted the child again.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     // Co-parented: deleteShared, so either parent can remove the child.
    //     await SupabaseRepo.deleteShared('children', childId);
    //   } catch (_) {}
    // }
    await _pushWaiting();
  }

  /// Brings a removed child back, with every record, on both phones. The
  /// restore is a newer edit than the removal, so it wins everywhere.
  Future<void> restoreChild(String childId) async {
    final i = _removed.indexWhere((c) => c.id == childId);
    if (i < 0) return;
    final c = _removed.removeAt(i);
    _children.add(c);
    _activeId = c.id;
    _book.touch(childId);
    notifyListeners();
    await _persist();
    await _pushWaiting();
  }

  /// The growth figures, from the growth log. They change the child on this
  /// phone and go up with the row, but they do NOT move the sync clock: they
  /// mirror the growth log (which syncs on its own), and a weight logged on a
  /// phone that has not pulled yet must not undo the other parent's rename.
  /// The server's guard lets an equal stamp through and skips an older one.
  Future<void> setMeasures({
    required double weightKg,
    required double heightCm,
    required double headCm,
  }) async {
    if (_children.isEmpty) {
      // No child yet: the first figures promote the placeholder, as before.
      await update(weightKg: weightKg, heightCm: heightCm, headCm: headCm);
      return;
    }
    final c = active
      ..weightKg = weightKg
      ..heightCm = heightCm
      ..headCm = headCm;
    if (_book.stamps.containsKey(c.id)) _book.dirty.add(c.id);
    notifyListeners();
    await _persist();
    await _pushWaiting();
  }

  /// Uploads every waiting child, one at a time. A change made while it runs
  /// is picked up by a second pass.
  Future<void> _pushWaiting() async {
    if (_pushing) {
      _again = true;
      return;
    }
    _pushing = true;
    try {
      do {
        _again = false;
        final uid = SupabaseRepo.userId;
        if (uid == null) return;
        final held = {for (final c in [..._removed, ..._children]) c.id: c};
        for (final id in _book.dirty.toList()) {
          final up = childUploadFor(_book, id, held[id], uid: uid);
          if (up == null) continue;
          final sent = _book.stamps[id];
          final ok = up.asUpdate
              ? await SupabaseRepo.updateSharedConfirmed('children', id, up.row)
              : await SupabaseRepo.upsertRowConfirmed('children', up.row,
                  onConflict: 'id');
          _book.confirmed(id, ok: ok, sent: sent);
        }
        await _persist();
      } while (_again);
    } finally {
      _pushing = false;
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
      final gone = prefs.getString(_removedKey);
      if (gone != null) {
        for (final e in (jsonDecode(gone) as List)) {
          _removed.add(Child.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      final book = prefs.getString(_bookKey);
      if (book != null) _book.loadJson(jsonDecode(book));
    } catch (_) {/* start on the seeded default */}
    SyncRegistry.registerPending(() => hasPending);
    _loaded = true;
    notifyListeners();

    // 2) Then the cloud (no-op when logged out).
    await _syncFromCloud();
  }

  /// A sign-out, or another account signing in (2026-10-17): this store
  /// forgets the person in memory; the cloud keeps it.
  void _resetLocal() {
    _children.clear();
    _removed.clear();
    _book.clear();
    _activeId = null;
    notifyListeners();
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
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
      // Newer wins per child, removals included (step 7, 0105). The cloud
      // order (oldest first) is kept for the children the phone takes.
      final merged = childrenMerge(
          book: _book, live: _children, removed: _removed, rows: rows);
      final order = [for (final r in rows) r['id'].toString()];
      int rank(Child c) {
        final i = order.indexOf(c.id);
        return i < 0 ? order.length : i;
      }

      _children
        ..clear()
        ..addAll(merged.live..sort((a, b) => rank(a).compareTo(rank(b))));
      _removed
        ..clear()
        ..addAll(merged.removed);
      if (!_children.any((c) => c.id == _activeId)) {
        _activeId = _children.isEmpty ? null : _children.first.id;
      }
      await _persist();
      notifyListeners();
      await _pushWaiting();
    } catch (_) {/* offline - keep local */}
  }

  // Kept for revert (step 7, 2026-10-20): the cloud copy won whole, so an
  // offline edit was lost, and a child this phone held but the cloud did not
  // was inserted again, even one the other parent had removed.
  // ignore: unused_element
  Future<void> _syncFromCloudOld() async {
    try {
      final rows = await SupabaseRepo.fetchShared(
        'children',
        orderBy: 'created_at',
        ascending: true,
      );
      final byId = {for (final r in rows) r['id'].toString(): Child.fromRow(r)};
      // A cloud row without `sex_given` (column not there yet) must not turn a
      // child whose sex was not given back into a boy.
      for (final r in rows) {
        if (r.containsKey('sex_given')) continue;
        final id = r['id'].toString();
        for (final c in _children) {
          if (c.id == id) byId[id]!.sexGiven = c.sexGiven;
        }
      }
      // Same for the birth columns (0102): a cloud row without them, or with
      // them still empty, keeps what this phone knows.
      for (final c in _children) {
        final cloud = byId[c.id];
        if (cloud == null) continue;
        cloud.birthMode ??= c.birthMode;
        cloud.bornWeeks ??= c.bornWeeks;
      }

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
      await prefs.setString(
          _removedKey, jsonEncode(_removed.map((e) => e.toJson()).toList()));
      await prefs.setString(_bookKey, jsonEncode(_book.toJson()));
    } catch (_) {}
  }

  // --- the flat API the screens already use (reads the ACTIVE child) ---------

  String get name => active.name;

  /// The active child's name as it should read INSIDE a sentence — see
  /// [Child.nameMid]. Most screens reach the name through this flat API rather
  /// than through [active], so it has to exist on both or half the app keeps
  /// the bug.
  String get nameMid => active.nameMid;

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

  /// ⚠️ HER CLOCK, NOT THE SELECTED CHILD'S (You, Maa plan M2, 2026-10-25).
  /// Weeks since her most recent birth: the youngest child's age. A mother
  /// of a 3-year-old and a 3-week-old is three weeks postpartum whichever
  /// child is on screen, and her recovery pages must not jump to "3 years
  /// on" when she taps the older one. Twins share a birthday, so the min is
  /// the same either way. With no saved child, the active (seeded) one.
  double get youngestAgeInWeeks {
    if (_children.isEmpty) return ageInWeeks;
    final latest = _children
        .map((c) => c.dob)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final w = DateTime.now().difference(latest).inDays / 7.0;
    return w > 0 ? w : 0;
  }

  // ---- corrected age (2026-10-07) -----------------------------------------
  //  Gap analysis P2 (Behind · Onboarding): "We tell parents to use corrected
  //  age and then show every page by the birthday." For a baby born early with
  //  the weeks known (onboarding), development is read by CORRECTED age to 24
  //  months: the phase, the month note and the milestones. Vaccines, the
  //  messages' birthdays and the WHO growth points stay on the birthday, as
  //  paediatricians do.

  /// Weeks to take off, while it still applies (under 24 months, born early
  /// with the weeks known). Null otherwise.
  int? get correctionWeeks {
    final w = FamilyProfileStore.instance.bornWeeks;
    if (w == null || w >= 37 || ageInMonths >= 24) return null;
    return 40 - w;
  }

  /// Age for development: corrected when [correctionWeeks] applies.
  int get devAgeInMonths {
    final c = correctionWeeks;
    if (c == null) return ageInMonths;
    final weeks = ageInWeeks - c;
    return weeks <= 0 ? 0 : (weeks / 4.345).floor();
  }

  /// "8 months (6 months corrected)", or the plain label.
  String get ageLabelWithCorrection =>
      correctionWeeks == null ? ageLabel : '$ageLabel ($devAgeInMonths months corrected)';

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

  //  When the sex was not given (Child.sexGiven false) each one falls back to
  //  the name, or "your baby" while there is no name, so a sentence still
  //  reads: "Hold Meera close", "your baby's own curve".

  /// Whether a he/she may be used at all.
  bool get sexGiven => active.sexGiven;

  /// "he" / "she" / the name
  String get they => !sexGiven ? active.nameMid : (isBoy ? 'he' : 'she');

  /// "his" / "her" / "Meera's" - possessive determiner ("his own curve").
  String get their => !sexGiven ? "${active.nameMid}'s" : (isBoy ? 'his' : 'her');

  /// "him" / "her" / the name - object pronoun ("hold him").
  String get them => !sexGiven ? active.nameMid : (isBoy ? 'him' : 'her');

  /// Sentence-initial "He" / "She" / the name.
  String get theyCap => !sexGiven ? _cap(active.nameMid) : (isBoy ? 'He' : 'She');

  /// Sentence-initial "His" / "Her" / "Meera's".
  String get theirCap => _cap(their);

  /// "Boy", "Girl" or "Not given", for detail rows.
  String get sexLabel => !sexGiven ? 'Not given' : (isBoy ? 'Boy' : 'Girl');

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
    bool? sexGiven,
    DateTime? dob,
    double? weightKg,
    double? heightCm,
    double? headCm,
  }) async {
    final promoting = _children.isEmpty;
    // Promote the seed (via copyWith, so the shared _seed itself is never
    // mutated - it must stay pristine for the next logged-out/fresh account).
    final c = promoting
        ? _seed.copyWith(id: _newChildId()) // was 'child_${DateTime.now().microsecondsSinceEpoch}'
        : active;

    if (name != null && name.trim().isNotEmpty) c.name = name.trim();
    if (isBoy != null) {
      c.isBoy = isBoy;
      c.sexGiven = sexGiven ?? true;
    } else if (sexGiven != null) {
      c.sexGiven = sexGiven;
    }
    if (dob != null) c.dob = dob;
    if (weightKg != null) c.weightKg = weightKg;
    if (heightCm != null) c.heightCm = heightCm;
    if (headCm != null) c.headCm = headCm;

    if (promoting) {
      _children.add(c);
      _activeId = c.id;
    }
    _book.touch(c.id);
    notifyListeners();
    await _persist();

    // Kept for revert (step 7, 2026-10-20): one-shot writes, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     if (promoting) {
    //       await SupabaseRepo.insert('children', c.toRow());
    //     } else {
    //       // updateShared: co-parented, so either parent may edit the child.
    //       await SupabaseRepo.updateShared('children', c.id, c.toRow());
    //     }
    //   } catch (_) {/* offline - reconciled on the next sync */}
    // }
    await _pushWaiting();
  }
}

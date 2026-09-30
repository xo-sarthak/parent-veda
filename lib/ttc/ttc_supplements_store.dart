// =============================================================================
//  TtcSupplementsStore - what they actually take, and whether they took it
// -----------------------------------------------------------------------------
//  Deliberately a RECORD, not a compliance system. The pregnancy app's
//  medication tracker set the rule this follows: a "nourishment companion",
//  never shaming and never gamified - a weekday awareness grid rather than a
//  compliance score.
//
//  So there is no adherence percentage anywhere in this file, and there must
//  never be one. A woman who forgets her folic acid on Tuesday does not need an
//  app to tell her she is at 71%.
//
//  Both partners' supplements live here, because male fertility is half the
//  picture and CoQ10 and zinc are as much his as folic acid is hers.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';
// Moved (2026-09-28, journal out of TTC): was ttc_journal_store.dart.
import 'ttc_author.dart';
import 'ttc_sync.dart';

class TtcSupplement {
  const TtcSupplement({
    required this.id,
    required this.name,
    required this.dose,
    this.author = TtcAuthor.me,
  });

  /// App-generated so a local row and its cloud copy share one identity.
  final String id;
  final String name;
  final String dose;
  final TtcAuthor author;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'dose': dose,
        'author': author.name,
      };

  static TtcSupplement? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    if (id is! String || name is! String) return null;
    return TtcSupplement(
      id: id,
      name: name,
      dose: (raw['dose'] as String?) ?? '',
      author: TtcAuthor.values.where((e) => e.name == raw['author']).firstOrNull ??
          TtcAuthor.me,
    );
  }
}

/// The ones commonly taken while trying, offered as one-tap adds so nobody has
/// to type "Methylcobalamin". Offering them is NOT recommending them - the
/// screen says so, and the dose field is left for a doctor to fill in.
class TtcSuggestedSupplement {
  const TtcSuggestedSupplement({
    required this.name,
    required this.dose,
    required this.noteEn,
    required this.noteHi,
    this.forPartner = false,
  });

  final String name;
  final String dose;
  final String noteEn;
  final String noteHi;
  final bool forPartner;

  String note(bool hi) => hi ? noteHi : noteEn;
}

const List<TtcSuggestedSupplement> ttcSuggestedSupplements = [
  TtcSuggestedSupplement(
    name: 'Folic acid',
    dose: '400 mcg daily',
    noteEn:
        'The one with the strongest evidence. You need it before conception, not after. The neural tube, which becomes the baby\'s brain and spine, closes in the first four weeks.',
    noteHi:
        'Iske peeche sabse mazboot saboot hai. Conception se pehle chahiye, baad mein nahi - neural tube pehle chaar hafton mein band ho jaata hai.',
  ),
  TtcSuggestedSupplement(
    name: 'Vitamin D',
    dose: 'As advised',
    noteEn:
        'Most Indian adults are low. Test before you start taking it. The dose depends on how low you are, and only a test can tell you that.',
    noteHi:
        'Zyadatar Indian adults mein kami hai. Lene se pehle test karwayein - dose is par nirbhar hai ki kami kitni hai, jo sirf test bata sakta hai.',
  ),
  TtcSuggestedSupplement(
    name: 'Vitamin B12',
    dose: 'As advised',
    noteEn:
        "A pure vegetarian diet almost always needs this. It's one of the few cases where food alone isn't enough.",
    noteHi:
        'Shuddh shakahari khaane mein ye lagbhag hamesha chahiye. Un gine-chune jagahon mein se ek jahan khana sach mein kaafi nahi hai.',
  ),
  TtcSuggestedSupplement(
    name: 'Iron',
    dose: 'As advised',
    noteEn:
        "It's common to be low, and that's linked to tiredness and irregular ovulation. Take it an hour apart from chai or coffee, which stop your body absorbing it.",
    noteHi:
        'Iski kami aam hai, aur ye thakaan aur irregular ovulation se judi hai. Chai ya coffee se ek ghanta door rakhein - wo sokhne se rokte hain.',
  ),
  TtcSuggestedSupplement(
    name: 'Omega-3',
    dose: 'As advised',
    noteEn:
        'Helps hormone production in both of you. Ground flaxseed works too. Whole seeds pass straight through.',
    noteHi:
        'Dono mein hormone banne ko support karta hai. Pisi alsi bhi chalti hai - sabut beej seedhe nikal jaate hain.',
  ),
  TtcSuggestedSupplement(
    name: 'CoQ10',
    dose: 'As advised',
    noteEn:
        "Studied for egg and sperm quality, especially over thirty-five. It looks promising but isn't proven. Ask a doctor, not a chemist.",
    noteHi:
        'Egg aur sperm quality ke liye study hua hai, khaaskar pentiis ke baad. Ummeed jagata hai, sabit nahi hua - chemist se nahi, doctor se poochhein.',
  ),
  // ⚠️ A SECOND CoQ10 ENTRY, FRAMED FOR HIM, AND NOT A DUPLICATE.
  //
  // `forPartner` is a bool, so an item belongs to one list or the other — and
  // the entry above never reached his, which meant the suggested list for him
  // held exactly one item while the workbook asks for "male fertility
  // supplements". The framing genuinely differs too: for her it is egg quality
  // over thirty-five, for him it is sperm parameters. Same molecule, different
  // reason to consider it, so two honest entries beat one hedged one.
  TtcSuggestedSupplement(
    name: 'CoQ10',
    dose: 'As advised',
    forPartner: true,
    noteEn:
        'Some evidence it helps sperm count and movement, more so when a '
        'result is already low. It does far less than stopping tobacco. The '
        'evidence for antioxidant supplements in male infertility is weak, '
        'though not absent.',
    noteHi:
        'Sperm count aur motility ke liye kuch saboot hai, khaaskar jab result '
        'pehle se kam ho. Tambaku chhodne se bahut kam faayda - aur male '
        'infertility mein antioxidant supplements ka saboot kamzor hai, na ki '
        'nahi hai.',
  ),
  TtcSuggestedSupplement(
    name: 'Zinc',
    dose: 'As advised',
    forPartner: true,
    noteEn:
        'Plays a direct part in making sperm and testosterone. A handful of roasted chana does more than most supplements sold for it.',
    noteHi:
        'Seedhe sperm banne aur testosterone se juda. Ek mutthi bhuna chana, iske liye beche jaane wale zyadatar supplements se zyada karta hai.',
  ),
];

class TtcSupplementsStore extends ChangeNotifier with TtcSyncedStore {
  TtcSupplementsStore._() {
    _load();
  }
  static final TtcSupplementsStore instance = TtcSupplementsStore._();

  static const _listKey = 'ttc_supplements';
  static const _takenKey = 'ttc_supplements_taken';

  final List<TtcSupplement> _items = [];

  /// "supplementId|yyyy-mm-dd" for every dose marked taken.
  final Set<String> _taken = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<TtcSupplement> get items => List.unmodifiable(_items);

  List<TtcSupplement> forAuthor(TtcAuthor author) =>
      _items.where((e) => e.author == author).toList();

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool isTaken(String id, {DateTime? on}) =>
      _taken.contains('$id|${_dayKey(on ?? DateTime.now())}');

  /// How many of today's doses are ticked. Shown as "2 of 4", never as a
  /// percentage and never coloured by how close to 100 it is.
  int takenToday({DateTime? on}) =>
      _items.where((e) => isTaken(e.id, on: on)).length;

  TtcSupplement add(String name,
      {String dose = '', TtcAuthor author = TtcAuthor.me}) {
    // ⚠️ ONE ROW PER SUPPLEMENT, PER PERSON (launch walk, 2026-09-27): the
    // list showed "Folic acid" twice, from the chip and from typing it. The
    // same name for the same person returns the row she already has.
    final key = name.trim().toLowerCase();
    for (final e in _items) {
      if (e.author == author && e.name.trim().toLowerCase() == key) return e;
    }
    final item = TtcSupplement(
      id: 'ttcs_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      dose: dose.trim(),
      author: author,
    );
    _items.add(item);
    _persist();
    notifyListeners();
    return item;
  }

  /// Change a supplement's name or dose, keeping its id and so every day she
  /// ticked it (added 2026-09-27: doses were saved as "As advised" and could
  /// never be corrected to what her doctor actually said).
  ///
  /// The push rides on `notifyListeners`, like every change here: the synced
  /// mixin upserts the whole list by id, so an edit is the same write as an
  /// add. Returns false when the new name would clash with another of that
  /// person's rows, so the caller can say so rather than make a duplicate.
  bool update(String id, {String? name, String? dose}) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return false;
    final old = _items[i];
    final newName = (name ?? old.name).trim();
    if (newName.isEmpty) return false;
    final key = newName.toLowerCase();
    final clash = _items.any((e) =>
        e.id != id &&
        e.author == old.author &&
        e.name.trim().toLowerCase() == key);
    if (clash) return false;
    _items[i] = TtcSupplement(
      id: old.id,
      name: newName,
      dose: (dose ?? old.dose).trim(),
      author: old.author,
    );
    _persist();
    notifyListeners();
    return true;
  }

  /// True when this person already has a supplement by this name.
  bool has(String name, TtcAuthor author) {
    final key = name.trim().toLowerCase();
    return _items
        .any((e) => e.author == author && e.name.trim().toLowerCase() == key);
  }

  /// True when anything on the list was ticked on [on]: the dot under a day
  /// in the week strip. A yes or no, never a count (added 2026-09-27).
  bool anyTakenOn(DateTime on) {
    final day = _dayKey(on);
    return _items.any((e) => _taken.contains('${e.id}|$day'));
  }

  // ---- duplicates -----------------------------------------------------------
  //  ⚠️ ADDED 2026-09-27 (tool rebuild). `add` has refused a second row of the
  //  same name for the same person since the launch walk, but lists saved
  //  BEFORE that fix still hold two "Folic acid" rows, each with its own
  //  ticks. Deleting one silently would lose the days ticked on it, and a
  //  sync would bring it back anyway. So the screen shows the pair and asks,
  //  and this merges on her say-so: the ticks move, the extra row goes.

  static String _nameKey(String name) => name.trim().toLowerCase();

  /// Rows that share a name with another row of the same person, grouped,
  /// oldest first in each group (the list keeps the order they were added).
  List<List<TtcSupplement>> duplicates() {
    final groups = <String, List<TtcSupplement>>{};
    for (final e in _items) {
      groups.putIfAbsent('${e.author.name}|${_nameKey(e.name)}', () => []).add(e);
    }
    return groups.values.where((g) => g.length > 1).toList();
  }

  /// The dose a merge keeps: the first one that says something real, so a
  /// row saved as "As advised" never overwrites "400 mcg daily".
  static String mergedDose(List<TtcSupplement> group) {
    for (final e in group) {
      final d = e.dose.trim();
      if (d.isNotEmpty && d.toLowerCase() != 'as advised') return d;
    }
    for (final e in group) {
      if (e.dose.trim().isNotEmpty) return e.dose.trim();
    }
    return '';
  }

  /// Folds every row in [group] into its first: each day ticked on any of
  /// them becomes a tick on the one that stays, and the rest are removed.
  /// Returns the row that stayed, or null when there was nothing to merge.
  ///
  /// Cloud: the removed rows are deleted (their tick rows cascade), and the
  /// moved ticks go up with the next push, which upserts every tick by
  /// (supplement, day). The order does not matter: the delete never touches
  /// the kept row's ticks.
  TtcSupplement? merge(List<TtcSupplement> group) {
    if (group.length < 2) return null;
    final keepIndex = _items.indexWhere((e) => e.id == group.first.id);
    if (keepIndex < 0) return null;
    final keep = _items[keepIndex];
    final dropIds = [
      for (final e in group.skip(1))
        if (e.author == keep.author && _items.any((x) => x.id == e.id)) e.id
    ];
    if (dropIds.isEmpty) return null;
    for (final id in dropIds) {
      final moved = _taken
          .where((k) => k.startsWith('$id|'))
          .map((k) => '${keep.id}|${k.substring(id.length + 1)}')
          .toList();
      _taken
        ..removeWhere((k) => k.startsWith('$id|'))
        ..addAll(moved);
    }
    _items.removeWhere((e) => dropIds.contains(e.id));
    final kept = TtcSupplement(
      id: keep.id,
      name: keep.name,
      dose: mergedDose(group),
      author: keep.author,
    );
    _items[_items.indexWhere((e) => e.id == keep.id)] = kept;
    _persist();
    if (SupabaseRepo.isLoggedIn) {
      for (final id in dropIds) {
        SupabaseRepo.delete(TtcTables.supplements, id).catchError((_) {});
      }
    }
    notifyListeners();
    return kept;
  }

  /// The row with this id, or null once it has been removed or merged away.
  TtcSupplement? byId(String id) =>
      _items.where((e) => e.id == id).firstOrNull;

  /// Adds a row exactly as given, bypassing the one-name-per-person check.
  /// Tests only: it is how a list saved before that check is reproduced.
  @visibleForTesting
  void addRawForTest(TtcSupplement s) {
    _items.add(s);
    notifyListeners();
  }

  void remove(String id) {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    if (_items.length == before) return;
    _taken.removeWhere((k) => k.startsWith('$id|'));
    _persist();
    // Removing has to reach the cloud - the union pull would restore it. The
    // taken rows cascade from the supplement's delete.
    if (SupabaseRepo.isLoggedIn) {
      SupabaseRepo.delete(TtcTables.supplements, id).catchError((_) {});
    }
    notifyListeners();
  }

  void toggleTaken(String id, {DateTime? on}) {
    final day = _dayKey(on ?? DateTime.now());
    final k = '$id|$day';
    final removed = _taken.remove(k);
    if (!removed) _taken.add(k);
    _persist();
    if (removed && SupabaseRepo.isLoggedIn) {
      SupabaseRepo.deleteMatch(TtcTables.supplementTaken, {
        'supplement_id': id,
        'taken_on': day,
      }).catchError((_) {});
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _items.clear();
    _taken.clear();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _items
        ..clear()
        ..addAll((p.getStringList(_listKey) ?? const <String>[])
            .map((r) {
              try {
                return TtcSupplement.fromJson(jsonDecode(r));
              } catch (_) {
                return null;
              }
            })
            .whereType<TtcSupplement>());
      _taken
        ..clear()
        ..addAll(p.getStringList(_takenKey) ?? const []);
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  // ---- cloud ----------------------------------------------------------------
  //  COUPLE-SCOPED: both lists live on one screen because zinc and CoQ10 are
  //  his in the same way folic acid is hers.

  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared(TtcTables.supplements,
        orderBy: 'created_at', ascending: true);
    for (final row in rows) {
      final id = row['id'];
      if (id is! String || _items.any((e) => e.id == id)) continue;
      _items.add(TtcSupplement(
        id: id,
        name: (row['name'] as String?) ?? '',
        dose: (row['dose'] as String?) ?? '',
        author:
            row['for_partner'] == true ? TtcAuthor.partner : TtcAuthor.me,
      ));
    }

    final taken = await SupabaseRepo.fetchShared(TtcTables.supplementTaken,
        orderBy: 'taken_on', ascending: true);
    for (final row in taken) {
      final id = row['supplement_id'];
      final day = row['taken_on']?.toString();
      if (id is! String || day == null) continue;
      _taken.add('$id|$day');
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    await TtcSyncUtil.upsertAll(
      TtcTables.supplements,
      [
        for (final s in _items)
          {
            'id': s.id,
            'user_id': uid,
            'for_partner': s.author == TtcAuthor.partner,
            'name': s.name,
            'dose': s.dose,
          }
      ],
      onConflict: 'id',
    );

    // A tick is (supplement, day). The composite key does the merge.
    final rows = <Map<String, dynamic>>[];
    for (final key in _taken) {
      final i = key.lastIndexOf('|');
      if (i <= 0) continue;
      rows.add({
        'user_id': uid,
        'supplement_id': key.substring(0, i),
        'taken_on': key.substring(i + 1),
      });
    }
    await TtcSyncUtil.upsertAll(TtcTables.supplementTaken, rows,
        onConflict: 'supplement_id,taken_on');
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _listKey, _items.map((e) => jsonEncode(e.toJson())).toList());
      await p.setStringList(_takenKey, _taken.toList());
    } catch (_) {/* best-effort */}
  }
}

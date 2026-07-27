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
import 'ttc_journal_store.dart' show TtcAuthor;
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
        'The one with the strongest evidence. Needed before conception, not after - the neural tube closes in the first four weeks.',
    noteHi:
        'Iske peeche sabse mazboot saboot hai. Conception se pehle chahiye, baad mein nahi - neural tube pehle chaar hafton mein band ho jaata hai.',
  ),
  TtcSuggestedSupplement(
    name: 'Vitamin D',
    dose: 'As advised',
    noteEn:
        'Most Indian adults are low. Test before supplementing - the dose depends on how low you are, which only a test can say.',
    noteHi:
        'Zyadatar Indian adults mein kami hai. Lene se pehle test karwayein - dose is par nirbhar hai ki kami kitni hai, jo sirf test bata sakta hai.',
  ),
  TtcSuggestedSupplement(
    name: 'Vitamin B12',
    dose: 'As advised',
    noteEn:
        'A pure vegetarian diet almost always needs this. One of the few places where food genuinely is not enough.',
    noteHi:
        'Shuddh shakahari khaane mein ye lagbhag hamesha chahiye. Un gine-chune jagahon mein se ek jahan khana sach mein kaafi nahi hai.',
  ),
  TtcSuggestedSupplement(
    name: 'Iron',
    dose: 'As advised',
    noteEn:
        'Common to be low, and linked to tiredness and irregular ovulation. Keep it an hour away from chai or coffee, which block absorption.',
    noteHi:
        'Iski kami aam hai, aur ye thakaan aur irregular ovulation se judi hai. Chai ya coffee se ek ghanta door rakhein - wo sokhne se rokte hain.',
  ),
  TtcSuggestedSupplement(
    name: 'Omega-3',
    dose: 'As advised',
    noteEn:
        'Supports hormone production in both of you. Ground flaxseed works too - whole seeds pass straight through.',
    noteHi:
        'Dono mein hormone banne ko support karta hai. Pisi alsi bhi chalti hai - sabut beej seedhe nikal jaate hain.',
  ),
  TtcSuggestedSupplement(
    name: 'CoQ10',
    dose: 'As advised',
    noteEn:
        'Studied for egg and sperm quality, particularly over thirty-five. Promising rather than proven - ask a doctor, not a chemist.',
    noteHi:
        'Egg aur sperm quality ke liye study hua hai, khaaskar pentiis ke baad. Ummeed jagata hai, sabit nahi hua - chemist se nahi, doctor se poochhein.',
  ),
  TtcSuggestedSupplement(
    name: 'Zinc',
    dose: 'As advised',
    forPartner: true,
    noteEn:
        'Directly involved in sperm production and testosterone. A fistful of roasted chana does more than most supplements sold for it.',
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

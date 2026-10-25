// =============================================================================
//  Garbh Sanskar rebuild - the data the new spec needs
// -----------------------------------------------------------------------------
//  Three things live here, and one naming decision runs through all of them.
//
//  ⚠️ THE SPEC SAYS "WOMB ALBUM". THE APP SAYS "MY JOURNAL". User's call, and
//  it is the better name for a reason worth writing down: the app already has
//  a journal, and a second keepsake surface beside it would leave a mother
//  with two places her memories might be and no way to guess which. One place
//  everything lands, including what her family records, is the whole promise.
//  Every identifier here says `journal` so the code and the screen agree.
//
//  ---------------------------------------------------------------------------
//  1. THE WEEK REASON LINE
//  ---------------------------------------------------------------------------
//  ⚠️ TIED TO FETAL DEVELOPMENT, NEVER TO ENCOURAGEMENT, and that distinction
//  is the entire point of the field. "You are doing so well" is true in any
//  week, which means it is a reason to do the practice on no particular day.
//  "Your baby's hearing is forming this week" is only true now, and it is what
//  makes today non-substitutable.
//
//  ⚠️ AND IT MUST NOT OVERCLAIM. The spec is explicit: say what is genuinely
//  evidenced for the baby and nothing more. So these lines say what is
//  DEVELOPING, which is established embryology, and never that a practice
//  improves it. A line reading "playing ragas now raises IQ" would be the
//  misinformation this product exists against.
//
//  ---------------------------------------------------------------------------
//  2. MY RITUAL
//  ---------------------------------------------------------------------------
//  Multi-faith and multi-select by construction. See `kGarbhRituals`.
//
//  ---------------------------------------------------------------------------
//  3. THE JOURNAL ENTRY MODEL
//  ---------------------------------------------------------------------------
//  One growing artifact. Nothing in this section is consumed and discarded.
//
//  ⚠️ ENGLISH ONLY FOR NOW where new copy was written; existing bilingual
//  content is carried through unchanged.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';
import '../services/remote/cloud_merged_store.dart';
import '../services/pregnancy_records.dart';
import '../services/remote/own_row_ledger.dart';
import '../services/remote/storage_service.dart';
import '../services/remote/supabase_repo.dart';
import '../services/remote/sync_registry.dart';
import '../services/remote/sync_row_book.dart';

LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  1 · Why today matters, keyed to what is actually developing
// -----------------------------------------------------------------------------

/// What is forming this week, and therefore why today is not interchangeable
/// with any other day.
///
/// ⚠️ BANDED, NOT PER-WEEK, AND THAT IS HONEST RATHER THAN LAZY. Development
/// does not happen on week boundaries; hearing does not switch on at 07:00 on
/// the first day of week 18. Forty individually-worded lines would imply a
/// precision that embryology does not have, and would invite someone to write
/// filler for the weeks where nothing headline happens.
class GarbhWeekReason {
  const GarbhWeekReason(this.fromWeek, this.toWeek, this.line);
  final int fromWeek;
  final int toWeek;

  /// One sentence. Always about the baby, never about her effort.
  final LocalizedText line;
}

const List<GarbhWeekReason> kGarbhWeekReasons = [
  GarbhWeekReason(1, 8, LocalizedText(
      en: 'The brain and spinal cord are taking shape this month, faster than '
          'at any other point in the pregnancy.',
      hi: 'इस महीने दिमाग़ और रीढ़ बन रहे हैं, पूरे गर्भकाल में सबसे तेज़ गति से।')),
  GarbhWeekReason(9, 13, LocalizedText(
      en: 'Your baby has started moving, long before you can feel it. The '
          'nerve pathways for touch are forming now.',
      hi: 'आपका शिशु हिलना-डुलना शुरू कर चुका है, आपको महसूस होने से बहुत पहले। '
          'छूने की नसें अभी बन रही हैं।')),
  GarbhWeekReason(14, 17, LocalizedText(
      en: "The inner ear is forming. Your baby can't hear yet, but the part "
          'that will hear you is being built this month.',
      hi: 'भीतरी कान बन रहा है। आवाज़ अभी सुनाई नहीं देती, लेकिन जो हिस्सा आपको '
          'सुनेगा वह इसी महीने बन रहा है।')),
  GarbhWeekReason(18, 22, LocalizedText(
      en: 'Hearing is switching on. Around now your baby begins to pick up '
          'sound from outside, and your voice is the closest and clearest one.',
      hi: 'सुनना शुरू हो रहा है। इन्हीं दिनों शिशु बाहर की आवाज़ें पकड़ने लगता है, '
          'और आपकी आवाज़ सबसे पास और सबसे साफ़ है।')),
  GarbhWeekReason(23, 27, LocalizedText(
      en: 'Your baby is responding to sound now, sometimes with a kick. What '
          'is heard often becomes familiar.',
      hi: 'अब शिशु आवाज़ पर प्रतिक्रिया देता है, कभी एक लात से भी। जो बार-बार '
          'सुनाई देता है, वह जाना-पहचाना हो जाता है।')),
  GarbhWeekReason(28, 32, LocalizedText(
      en: 'Sleep and wake cycles are settling in, and your baby can now tell '
          'your voice from other sounds.',
      hi: 'सोने-जागने का चक्र बैठ रहा है, और शिशु अब आपकी आवाज़ को दूसरी आवाज़ों '
          'से अलग पहचान सकता है।')),
  GarbhWeekReason(33, 40, LocalizedText(
      en: 'Your baby is learning the rhythm of your voice, the one sound that '
          'will already be familiar on the day you meet.',
      hi: 'शिशु आपकी आवाज़ की लय सीख रहा है — वही एक आवाज़ जो मिलने के दिन उसे '
          'पहले से जानी-पहचानी लगेगी।')),
];

LocalizedText garbhWeekReason(int week) {
  for (final r in kGarbhWeekReasons) {
    if (week >= r.fromWeek && week <= r.toWeek) return r.line;
  }
  return kGarbhWeekReasons.last.line;
}

// -----------------------------------------------------------------------------
//  2 · My ritual
// -----------------------------------------------------------------------------

/// One thing she already does, or wants to start.
class GarbhRitual {
  const GarbhRitual({
    required this.id,
    required this.name,
    required this.blurb,
    this.hasCounter = false,
    this.planWeeks = 0,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText blurb;

  /// Japa needs a tap counter rather than a done/not-done row.
  final bool hasCounter;

  /// ⚠️ NON-ZERO MAKES THIS A COMPLETION ARC RATHER THAN A HABIT, and the
  /// difference matters more than it looks. A daily habit has no end, so it
  /// can only ever be broken. A 40-week plan has a finish line that lands the
  /// week before her due date, so every day moves a bar that is visibly going
  /// somewhere. The spec calls this the strongest item here and it is right.
  final int planWeeks;

  bool get isPlan => planWeeks > 0;
}

/// ⚠️ MULTI-FAITH BY CONSTRUCTION, NOT BY DISCLAIMER.
///
/// The list is deliberately not ordered by how common each practice is in
/// India, because an ordering by majority makes every woman below the fold
/// feel like an afterthought on a screen about her own faith. Hindu, Muslim,
/// Christian and secular options are interleaved, and "five minutes of
/// silence" is in the same list rather than in an "other" bucket.
final List<GarbhRitual> kGarbhRituals = [
  GarbhRitual(
    id: 'gita_40',
    name: _t('Gita paath, 40-week plan', 'गीता पाठ, 40 हफ़्ते की योजना'),
    blurb: _en('A little each day, finishing the week before your due date.'),
    planWeeks: 40,
  ),
  GarbhRitual(
    id: 'quran',
    name: _t('A Quran passage', 'क़ुरआन का एक अंश'),
    blurb: _en('A short daily reading.'),
  ),
  GarbhRitual(
    id: 'silence',
    name: _t('Five minutes of silence', 'पाँच मिनट का मौन'),
    blurb: _en('No words and no screen, for five minutes.'),
  ),
  GarbhRitual(
    id: 'japa',
    name: _t('Japa', 'जप'),
    blurb: _en("With a counter, so you don't have to keep count."),
    hasCounter: true,
  ),
  GarbhRitual(
    id: 'bible',
    name: _t('A Bible passage', 'बाइबल का एक अंश'),
    blurb: _en('A short daily reading.'),
  ),
  GarbhRitual(
    id: 'hanuman_chalisa',
    name: _t('Hanuman Chalisa', 'हनुमान चालीसा'),
    blurb: _en('Daily.'),
  ),
  GarbhRitual(
    id: 'pravachan',
    name: _t('Daily pravachan', 'रोज़ का प्रवचन'),
    blurb: _en('Listen to a short discourse.'),
  ),
  GarbhRitual(
    id: 'sundarkand',
    name: _t('Sundarkand', 'सुंदरकांड'),
    blurb: _en('Daily.'),
  ),
];

GarbhRitual? garbhRitualById(String id) {
  for (final r in kGarbhRituals) {
    if (r.id == id) return r;
  }
  return null;
}

// -----------------------------------------------------------------------------
//  3 · My Journal - the growing artifact
// -----------------------------------------------------------------------------

/// What kind of thing landed in the journal.
///
/// ⚠️ `familyVoice` EXISTS BEFORE THE FLOW THAT CREATES IT. The web recorder
/// that produces these is a separate property and a server, neither of which
/// this repo owns - but the album has to be able to HOLD one, group it by
/// week, and carry the relationship label, or the day that flow ships it
/// arrives with nowhere to land. Declaring the shape now is the cheap half.
enum GarbhEntryKind { myVoice, familyVoice, heard, letter, photo }

extension GarbhEntryKindMeta on GarbhEntryKind {
  LocalizedText get label => switch (this) {
        GarbhEntryKind.myVoice => _en('Your voice'),
        GarbhEntryKind.familyVoice => _en('Family'),
        GarbhEntryKind.heard => _en('What your baby heard'),
        GarbhEntryKind.letter => _en('A letter'),
        GarbhEntryKind.photo => _en('Photo'),
      };
}

/// One thing she made, kept forever.
class GarbhJournalEntry {
  const GarbhJournalEntry({
    required this.id,
    required this.kind,
    required this.week,
    required this.tsMs,
    required this.title,
    this.seconds = 0,
    this.path,
    this.text,
    this.relationship,
    this.ref,
  });

  final String id;
  final GarbhEntryKind kind;

  /// ⚠️ THE WEEK IS STAMPED AT CREATION, NOT DERIVED ON READ. Deriving it
  /// would mean every entry silently re-dates itself as the pregnancy moves
  /// on, and an album grouped by week would reshuffle every time she opened
  /// it. What she recorded in week 22 stays in week 22 forever, including
  /// after the birth when there is no current week at all.
  final int week;

  final int tsMs;
  final LocalizedText title;

  /// Audio length, where there is audio. Feeds the header's running total.
  final int seconds;

  final String? path;
  final String? text;

  /// The label SHE chose for whoever recorded it, kept with the recording
  /// rather than derived from a sender identity, because "Dadi" is her word
  /// and it is what her album should say.
  final String? relationship;

  /// The audio's Storage reference once uploaded (step 13); null until then.
  /// [path] stays this phone's own file.
  final String? ref;

  GarbhJournalEntry withAudio({String? path, String? ref}) => GarbhJournalEntry(
        id: id,
        kind: kind,
        week: week,
        tsMs: tsMs,
        title: title,
        seconds: seconds,
        path: path ?? this.path,
        text: text,
        relationship: relationship,
        ref: ref ?? this.ref,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'week': week,
        'ts': tsMs,
        'title': title.en,
        'titleHi': title.hi,
        'seconds': seconds,
        'path': path,
        'text': text,
        'rel': relationship,
        'ref': ref,
      };

  factory GarbhJournalEntry.fromJson(Map<String, dynamic> j) =>
      GarbhJournalEntry(
        id: (j['id'] ?? '').toString(),
        kind: GarbhEntryKind.values.firstWhere(
            (k) => k.name == j['kind'],
            orElse: () => GarbhEntryKind.myVoice),
        week: (j['week'] as num?)?.toInt() ?? 0,
        tsMs: (j['ts'] as num?)?.toInt() ?? 0,
        title: LocalizedText(
            en: (j['title'] ?? '').toString(),
            hi: (j['titleHi'] ?? j['title'] ?? '').toString()),
        seconds: (j['seconds'] as num?)?.toInt() ?? 0,
        path: j['path']?.toString(),
        text: j['text']?.toString(),
        relationship: j['rel']?.toString(),
        ref: j['ref']?.toString(),
      );
}

/// The journal, and the ritual selections that sit beside it.
///
/// ⚠️ LOCAL-FIRST AND FIRE-AND-FORGET, like every other store here. An album
/// that fails to save because the network is down would be the worst possible
/// failure in this section: she has just recorded her voice for her child.
///
/// IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log, migration 0110). The
/// album lived only on this phone, so a sign-out or a new phone lost every
/// recording. Two shapes, by what each thing is:
///   * the entries are RECORDS she makes one by one: rows in
///     `garbh_journal_entries` (OwnRowLedger, soft delete, newer wins), the
///     audio in Storage (`media/<uid>/garbh/...`) referenced by `ref`;
///   * the rituals, pins, the "asked" mark and today's japa are ITEMS in a
///     per-item merged store (CloudMergedStore): `ritual|<id>`, `pin|<id>`,
///     `asked`, `japa`.
class GarbhJournalStore extends ChangeNotifier
    with CloudMergedStore
    implements PregnancyScopedStore {
  GarbhJournalStore._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final GarbhJournalStore instance = GarbhJournalStore._();

  // ---- the entries: rows (step 13) -------------------------------------------

  final OwnRowLedger _rows = OwnRowLedger(
      'garbh_journal_entries', 'garbh_journal_sync',
      keyColumn: 'key');

  /// Entries the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPendingEntries => _rows.hasPending;

  Map<String, dynamic> _toRow(GarbhJournalEntry e) =>
      {'key': e.id, 'data': e.toJson()};

  Map<String, Map<String, dynamic>> _liveRows() =>
      {for (final e in _entries) e.id: _toRow(e)};

  bool _rowsRegistered = false;

  /// Push waiting entries (audio first), then take the cloud's newer ones.
  Future<void> syncEntries() async {
    if (!_rowsRegistered) {
      _rowsRegistered = true;
      SyncRegistry.register(syncEntries);
      SyncRegistry.registerPending(() => _rows.hasPending);
    }
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      await _uploadAudio();
      await _rows.push(_liveRows, onRemovalConfirmed: (_, cols) {
        final data = cols['data'];
        final ref = data is Map ? data['ref']?.toString() : null;
        if (ref != null && ref.isNotEmpty) StorageService.remove(ref);
      });
      final taken = await _rows.pull(liveKeys: _entries.map((e) => e.id));
      if (taken.isEmpty) return;
      final byId = {for (final e in _entries) e.id: e};
      for (final r in taken) {
        final id = r['id'].toString();
        if (syncParseStamp(r['removed_at']) != null) {
          byId.remove(id);
          continue;
        }
        final data = r['data'];
        if (data is! Map) continue;
        var e = GarbhJournalEntry.fromJson(
            {...data.cast<String, dynamic>(), 'id': id});
        final ref = e.ref;
        final path = e.path;
        if (ref != null &&
            ref.isNotEmpty &&
            (path == null || !File(path).existsSync())) {
          final f = await StorageService.resolve(ref);
          if (f != null) e = e.withAudio(path: f.path);
        }
        byId[id] = e;
      }
      _entries
        ..clear()
        ..addAll(byId.values);
      await _saveEntries();
      notifyListeners();
    } catch (_) {/* offline - keep local, still waiting */}
  }

  /// A recording still only on this phone goes to Storage, and its row is
  /// marked changed so it carries the reference.
  Future<void> _uploadAudio() async {
    var changed = false;
    for (var i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      final path = e.path;
      if (e.ref != null || path == null || path.isEmpty) continue;
      if (!File(path).existsSync()) continue;
      final ref = await StorageService.upload(path, 'garbh');
      if (ref == path) continue; // offline or not set up: next time
      _entries[i] = e.withAudio(ref: ref);
      _rows.touch(e.id);
      changed = true;
    }
    if (changed) await _saveEntries();
  }

  // ---- the selections: items (step 13) ---------------------------------------

  @override
  String get cloudKey => 'garbh_journal';

  @override
  Map<String, Object?> cloudItems() => {
        for (final id in _rituals) 'ritual|$id': true,
        for (final id in _pinned) 'pin|$id': true,
        if (_asked) 'asked': true,
        if (_japaDate.isNotEmpty) 'japa': {'count': _japa, 'date': _japaDate},
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _rituals.clear();
    _pinned.clear();
    _asked = false;
    _japa = 0;
    _japaDate = '';
    for (final e in items.entries) {
      final k = e.key;
      if (k.startsWith('ritual|')) {
        _rituals.add(k.substring(7));
      } else if (k.startsWith('pin|')) {
        _pinned.add(k.substring(4));
      } else if (k == 'asked') {
        _asked = e.value == true;
      } else if (k == 'japa' && e.value is Map) {
        final m = e.value as Map;
        _japa = (m['count'] as num?)?.toInt() ?? 0;
        _japaDate = (m['date'] ?? '').toString();
      }
    }
  }

  @override
  Future<void> persistLocalCache() async {
    await _saveRituals();
    await _savePinned();
    await _saveJapa();
  }

  static const _entriesKey = 'garbh_journal_v1';
  static const _ritualsKey = 'garbh_rituals_v1';
  static const _ritualAskedKey = 'garbh_rituals_asked_v1';
  static const _pinnedKey = 'garbh_pinned_v1';
  static const _japaKey = 'garbh_japa_v1';
  static const _japaDateKey = 'garbh_japa_date_v1';

  final List<GarbhJournalEntry> _entries = [];
  final Set<String> _rituals = {};
  bool _asked = false;
  bool _loaded = false;

  final Set<String> _pinned = {};

  int _japa = 0;
  String _japaDate = '';

  /// ⚠️ THIS PREGNANCY'S RECORDINGS (R1, 2026-10-25). An entry's week is
  /// stamped at creation, and every pregnancy has a week 22: without this a
  /// second pregnancy's album opened on the first's voices. An entry belongs
  /// to the pregnancy whose window holds the moment it was made. Her rituals
  /// and pins are her practice, not a pregnancy's, and carry on.
  static DateTime _at(GarbhJournalEntry e) =>
      DateTime.fromMillisecondsSinceEpoch(e.tsMs);

  List<GarbhJournalEntry> get _mine =>
      [for (final e in _entries) if (PregnancyRecords.instance.inCurrent(_at(e))) e];

  /// [w]'s entries, newest first (the "Kept for you" page).
  List<GarbhJournalEntry> entriesIn(PregnancyWindow w) =>
      [for (final e in _entries) if (w.holds(_at(e))) e]
        ..sort((a, b) => b.tsMs.compareTo(a.tsMs));

  @override
  int countIn(PregnancyWindow w) => entriesIn(w).length;

  /// Each the way [remove] does, audio file included.
  @override
  Future<int> removeIn(PregnancyWindow w) async {
    final ids = [for (final e in entriesIn(w)) e.id];
    for (final id in ids) {
      await remove(id);
    }
    return ids.length;
  }

  /// Newest first.
  List<GarbhJournalEntry> get entries {
    // final l = [..._entries]..sort((a, b) => b.tsMs.compareTo(a.tsMs)); // kept for revert
    final l = _mine..sort((a, b) => b.tsMs.compareTo(a.tsMs));
    return List.unmodifiable(l);
  }

  bool get isEmpty => _mine.isEmpty;

  /// Grouped by the week they were made in, newest week first.
  Map<int, List<GarbhJournalEntry>> get byWeek {
    final m = <int, List<GarbhJournalEntry>>{};
    for (final e in entries) {
      m.putIfAbsent(e.week, () => []).add(e);
    }
    final keys = m.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in keys) k: m[k]!};
  }

  /// ⚠️ THE HEADER NUMBER, AND IT COUNTS HER VOICE ONLY.
  ///
  /// Total minutes across everything would be a bigger number and a worse one:
  /// it would be mostly ragas, and a mother reading "4 hours of your voice"
  /// when most of it is a music track has been flattered rather than told
  /// something. Family recordings are counted separately for the same reason.
  int get myVoiceSeconds => _mine
      .where((e) => e.kind == GarbhEntryKind.myVoice)
      .fold(0, (a, e) => a + e.seconds);

  int get myVoiceCount =>
      _mine.where((e) => e.kind == GarbhEntryKind.myVoice).length;

  int get familyCount =>
      _mine.where((e) => e.kind == GarbhEntryKind.familyVoice).length;

  /// What she added this week, for the strip on the daily card.
  List<GarbhJournalEntry> thisWeek(int week) =>
      entries.where((e) => e.week == week).toList(growable: false);

  Set<String> get rituals => Set.unmodifiable(_rituals);
  bool hasRitual(String id) => _rituals.contains(id);

  /// Whether the "what do you already do?" question has been answered once.
  bool get ritualsAsked => _asked;

  // ---- what she chose for her own daily ---------------------------------

  /// ⚠️ "ADD TO MY DAILY" IS A PIN, NOT A REPLACEMENT.
  ///
  /// The library items she pins are OFFERED first when the daily pick is made;
  /// they do not overwrite the rotation. The distinction matters because the
  /// rotation is what makes the practice a practice - a mother who pins one
  /// affirmation and then sees only that affirmation for four months has been
  /// handed a way to make the section boring, dressed up as personalisation.
  ///
  /// So: pinned items come first, the rotation continues underneath, and
  /// nothing she pins can be lost.
  Set<String> get pinned => Set.unmodifiable(_pinned);
  bool isPinned(String id) => _pinned.contains(id);

  void togglePinned(String id) {
    if (!_pinned.remove(id)) _pinned.add(id);
    notifyListeners();
    _savePinned();
  }

  Future<void> _savePinned() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_pinnedKey, _pinned.toList());
    } catch (_) {/* local-first, best effort */}
  }

  // ---- japa -------------------------------------------------------------

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Today's count. Resets on a new day.
  ///
  /// ⚠️ IT RESETS, AND IT DOES NOT ACCUMULATE FOREVER. A japa count is a thing
  /// she does today; a lifetime total turns a practice into a score, which is
  /// the one thing this whole section refuses to do. The reset is read at
  /// access rather than written by a timer, so it is right after the app has
  /// been closed overnight.
  int get japaToday {
    if (_japaDate != _ymd(DateTime.now())) return 0;
    return _japa;
  }

  void japaIncrement() {
    final today = _ymd(DateTime.now());
    if (_japaDate != today) {
      _japaDate = today;
      _japa = 0;
    }
    _japa++;
    notifyListeners();
    _saveJapa();
  }

  void japaReset() {
    _japa = 0;
    _japaDate = _ymd(DateTime.now());
    notifyListeners();
    _saveJapa();
  }

  /// Test seam: write a count under an arbitrary date, so a test can express
  /// "there was a count yesterday" without waiting a day or faking a clock.
  @visibleForTesting
  void japaSetForTest({required int count, required String ymd}) {
    _japa = count;
    _japaDate = ymd;
    notifyListeners();
  }

  Future<void> _saveJapa() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_japaKey, _japa);
      await p.setString(_japaDateKey, _japaDate);
    } catch (_) {/* local-first, best effort */}
  }

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      _rituals.addAll(p.getStringList(_ritualsKey) ?? const []);
      _asked = p.getBool(_ritualAskedKey) ?? false;
      _pinned.addAll(p.getStringList(_pinnedKey) ?? const []);
      _japa = p.getInt(_japaKey) ?? 0;
      _japaDate = p.getString(_japaDateKey) ?? '';
      final raw = p.getString(_entriesKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw);
        if (list is List) {
          _entries.addAll(list.whereType<Map>().map(
              (m) => GarbhJournalEntry.fromJson(m.cast<String, dynamic>())));
        }
      }
      notifyListeners();
    } catch (_) {
      // A corrupt blob must not take the album with it - she still gets an
      // empty one she can add to, which beats a crash on the screen whose
      // whole promise is "your things are safe here".
    }
    await _rows.load();
    await syncMergedFromCloud();
    await syncEntries();
  }

  Future<void> add(GarbhJournalEntry e) async {
    _entries.add(e);
    _rows.touch(e.id);
    notifyListeners();
    await _saveEntries();
    syncEntries();
  }

  Future<void> remove(String id) async {
    for (final e in _entries.where((e) => e.id == id).toList()) {
      _rows.remove(id, _toRow(e));
    }
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _saveEntries();
    syncEntries();
  }

  void toggleRitual(String id) {
    if (!_rituals.remove(id)) _rituals.add(id);
    notifyListeners();
    _saveRituals();
  }

  void markRitualsAsked() {
    if (_asked) return;
    _asked = true;
    notifyListeners();
    _saveRituals();
  }

  Future<void> _saveEntries() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          _entriesKey, jsonEncode(_entries.map((e) => e.toJson()).toList()));
    } catch (_) {/* local-first, best effort */}
  }

  Future<void> _saveRituals() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_ritualsKey, _rituals.toList());
      await p.setBool(_ritualAskedKey, _asked);
    } catch (_) {/* local-first, best effort */}
  }

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  void _resetForAccount() {
    resetForTest();
    _rows
      ..clear()
      ..save();
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _entries.clear();
    _rituals.clear();
    _asked = false;
    _loaded = false;
    _pinned.clear();
    _japa = 0;
    _japaDate = '';
  }
}

// -----------------------------------------------------------------------------
//  The Gita plan's arithmetic
// -----------------------------------------------------------------------------

/// How far through the 40-week plan she is, and when it finishes.
///
/// ⚠️ THE FINISH LANDS THE WEEK BEFORE HER DUE DATE, NOT ON IT. A plan that
/// completes on the due date completes on a day she is quite likely to be in
/// labour, or to have delivered a week earlier. Finishing early means the arc
/// closes while she is still there to see it close.
({double progress, int weeksLeft, int finishWeek}) gitaPlanProgress(
    int currentWeek) {
  const finishWeek = 39;
  final done = currentWeek.clamp(0, finishWeek);
  return (
    progress: finishWeek == 0 ? 0 : done / finishWeek,
    weeksLeft: (finishWeek - done).clamp(0, finishWeek),
    finishWeek: finishWeek,
  );
}

// =============================================================================
//  TtcDoctorQuestionsStore - the questions she saves for her doctor
// -----------------------------------------------------------------------------
//  A feature of the Appointments page, and nothing else's. (Read, since
//  2026-09-28, by the home's visit-day card, the doctor's note and the
//  evening-before reminder; written only from Appointments.)
//
//  ⚠️ WHY THIS IS ITS OWN STORE AND ITS OWN TABLE (2026-09-28)
//
//  Until today a question for the doctor was a journal entry of kind
//  `question`, written through the journal's writer and kept in the journal's
//  store and cloud table. It worked, and it was coupled: when the user took
//  the journal out of Trying to Conceive ("we don't need the journal
//  section... question for your doctor stays on appointments... it has to do
//  nothing with journal now on"), switching off the journal would also have
//  switched off every question she had saved. A feature that borrows another
//  feature's table dies with it. See docs/BACKEND-PATTERNS.md, section 16r.
//
//  THE HOUSE PATTERN, unchanged:
//   · a singleton `ChangeNotifier`, loaded at app start by `main.dart`
//     through [TtcDoctorQuestionsStore.init] (2026-09-28; it was lazy, first
//     touched by the Appointments page);
//   · local-first: `shared_preferences` under its own key, shown at once,
//     synced after; a cloud failure is never a crash;
//   · app-generated ids, so a local row and its cloud copy are one identity
//     and every push is an idempotent upsert;
//   · fire-and-forget writes through `SupabaseRepo` only.
//
//  A DELETE IS DATA (16q): removing a question does not drop the row, it
//  stamps `removedAt` and bumps `updatedAt`, and the push sends that like any
//  edit. Undo clears the stamp, which is again just an edit. The merge is
//  "newer `updated_at` wins", so a removal can never be resurrected by an
//  upsert that was already in flight, and nothing needs a second tombstone
//  list beside the rows.
//
//  THE ONE-TIME MOVE: on its first load on a phone, the store copies the
//  question-kind entries still sitting in the old journal cache
//  ('ttc_journal' in shared_preferences) into itself, same ids, words and
//  dates, and then sets [kMigratedFlag] so it never runs again. The old key is
//  read, never written or cleared: the journal is commented out, not wiped.
//  The cloud half of the same move is a backfill in
//  supabase/migrations/0092_ttc_doctor_questions.sql, keyed by the same ids,
//  so the two meet as one row.
//
//  COUPLE-SCOPED READ, OWN-ROW WRITE (docs/FAMILY-MODEL.md: the person owns
//  what she writes; the partner may read, never write). Her partner's
//  questions arrive from the cloud as [TtcAuthor.partner] and are shown, but
//  only their author can change or remove them, and a push only ever sends
//  this person's own rows.
//
//  ---------------------------------------------------------------------------
//  ⚠️ A QUESTION BELONGS TO A VISIT, AND IS TICKED WHEN ASKED (2026-09-28)
//  ---------------------------------------------------------------------------
//  Until today every question showed on every coming visit until she deleted
//  it, so a question answered in March was still "to take" in May. Neither
//  Flo nor What to Expect keeps such a list; both help her arrive prepared.
//  The user approved this shape:
//
//   · TWO STORED FACTS. `appointmentId`: the visit she chose (null means
//     "whichever visit comes next"); `askedAt`: when she ticked it as asked
//     (null means still to ask). Both are columns in 0092.
//   · ONE DERIVED FACT: which visit an unticked question is on TODAY. A
//     question stays on its chosen visit through that visit's day; from the
//     next morning it is on the next visit whose day has not passed. Nothing
//     writes that move down. [visitFor] works it out from the appointment
//     dates every time it is asked, with a `now` a caller can set (the
//     evening-before reminder asks "as of 7 pm tomorrow").
//
//  WHY DERIVE THE ROLL-FORWARD RATHER THAN STORE IT: a stored move would be a
//  write that nobody made. It would need a job to run at midnight (a phone
//  has no reliable one), it would have to be redone when a visit is moved or
//  deleted or undeleted, and her partner's phone would have to agree with
//  hers about when it happened. A derived answer has none of those: move a
//  scan to next week and her questions follow it; delete it and they are on
//  the next visit; Undo the delete and they are back, because the stored
//  fact (the visit she chose) never changed. See docs/BACKEND-PATTERNS.md
//  §16r. What IS stored is only what she decided: "Keep for the next visit"
//  clears the chosen visit, and "Done" ticks.
// =============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../booking/booking_models.dart';
import '../booking/booking_store.dart';
import '../services/remote/supabase_repo.dart';
import 'ttc_author.dart';
import 'ttc_records_store.dart' show TtcAppointmentsStore;
import 'ttc_sync.dart';

export 'ttc_author.dart' show TtcAuthor;

/// One visit a question can belong to: a clinic visit the couple added, or a
/// consult booked in ParentVeda. The questions only need its id and its time.
@immutable
class TtcVisitRef {
  const TtcVisitRef({
    required this.id,
    required this.title,
    required this.startsUtc,
  });

  /// A `TtcAppointment` id, or [ttcBookingVisitId] for a booking.
  final String id;
  final String title;
  final DateTime startsUtc;

  DateTime get startsLocal => startsUtc.toLocal();
}

/// The visit id a ParentVeda booking goes by. Prefixed so it can never be
/// read as one of the couple's own appointment ids.
String ttcBookingVisitId(String bookingId) => 'booking:$bookingId';

/// One question for the doctor.
@immutable
class TtcDoctorQuestion {
  const TtcDoctorQuestion({
    required this.id,
    required this.text,
    required this.writtenAt,
    required this.updatedAt,
    this.author = TtcAuthor.me,
    this.removedAt,
    this.appointmentId,
    this.askedAt,
  });

  /// App-generated (`ttcq_<micros>`), or the old journal id for a question
  /// that was moved across, so the two copies stay one identity.
  final String id;
  final String text;

  /// When she first wrote it. Never moves.
  final DateTime writtenAt;

  /// Moves on every change, a removal and an undo included. The merge clock.
  final DateTime updatedAt;
  final TtcAuthor author;

  /// Set when she removed it. The row is kept, so the removal syncs.
  final DateTime? removedAt;

  /// The visit she chose for it (2026-09-28). Null: whichever visit comes
  /// next. Never rewritten by a roll-forward; see [TtcDoctorQuestionsStore.visitFor].
  final String? appointmentId;

  /// When she ticked it as asked. Null: still to ask.
  final DateTime? askedAt;

  bool get isRemoved => removedAt != null;
  bool get isMine => author == TtcAuthor.me;
  bool get isAsked => askedAt != null;

  TtcDoctorQuestion copyWith({
    String? text,
    DateTime? updatedAt,
    DateTime? removedAt,
    bool clearRemoved = false,
    String? appointmentId,
    bool clearAppointment = false,
    DateTime? askedAt,
    bool clearAsked = false,
  }) =>
      TtcDoctorQuestion(
        id: id,
        text: text ?? this.text,
        writtenAt: writtenAt,
        updatedAt: updatedAt ?? this.updatedAt,
        author: author,
        removedAt: clearRemoved ? null : (removedAt ?? this.removedAt),
        appointmentId: clearAppointment
            ? null
            : (appointmentId ?? this.appointmentId),
        askedAt: clearAsked ? null : (askedAt ?? this.askedAt),
      );

  // JSON, not a delimiter: a question is free text and may hold any
  // character a keyboard produces.
  String encode() => jsonEncode({
        'id': id,
        'text': text,
        'written': writtenAt.toIso8601String(),
        'updated': updatedAt.toIso8601String(),
        'author': author.name,
        if (removedAt != null) 'removed': removedAt!.toIso8601String(),
        if (appointmentId != null) 'visit': appointmentId,
        if (askedAt != null) 'asked': askedAt!.toIso8601String(),
      });

  static TtcDoctorQuestion? decode(String raw) {
    try {
      final m = jsonDecode(raw);
      if (m is! Map) return null;
      final id = m['id'];
      final written = DateTime.tryParse('${m['written']}');
      if (id is! String || written == null) return null;
      final removed = m['removed'];
      final visit = m['visit'];
      final asked = m['asked'];
      return TtcDoctorQuestion(
        appointmentId: visit is String && visit.isNotEmpty ? visit : null,
        askedAt: asked is String ? DateTime.tryParse(asked) : null,
        id: id,
        text: (m['text'] as String?) ?? '',
        writtenAt: written,
        updatedAt: DateTime.tryParse('${m['updated']}') ?? written,
        author:
            TtcAuthor.values.where((e) => e.name == m['author']).firstOrNull ??
                TtcAuthor.me,
        removedAt: removed is String ? DateTime.tryParse(removed) : null,
      );
    } catch (_) {
      // A corrupt row is dropped, never allowed to take the list down.
      return null;
    }
  }
}

class TtcDoctorQuestionsStore extends ChangeNotifier with TtcSyncedStore {
  TtcDoctorQuestionsStore._() {
    _load();
  }
  static final TtcDoctorQuestionsStore instance = TtcDoctorQuestionsStore._();

  /// Loaded at app start from `main.dart` (2026-09-28), no longer only when
  /// the Appointments page first touches it: the home's visit-day card, the
  /// doctor's note and the evening-before reminder all read it now, and a
  /// reminder armed before the list had loaded would say "no questions".
  ///
  /// Completes when the LOCAL list is in (cheap: one `shared_preferences`
  /// read, plus the one-time move on the very first run). It does not wait
  /// for the cloud, because what waits on it (the reminder re-arm at launch)
  /// must not wait on a network.
  Future<void> init() => _localReady.future;
  Completer<void> _localReady = Completer<void>();

  /// Table name. Pinned by test/ttc_schema_contract_test.dart.
  static const table = TtcTables.doctorQuestions;

  static const _key = 'ttc_doctor_questions';

  /// Set once the old journal's questions have been copied across.
  static const kMigratedFlag = 'ttc_doctor_questions_from_journal_v1';

  /// The old journal's cache key. Read once, never written.
  static const kOldJournalKey = 'ttc_journal';

  final List<TtcDoctorQuestion> _rows = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// The questions on the list, newest first (the order the journal showed
  /// them in, so nothing moves on her screen). Removed ones are not here.
  List<TtcDoctorQuestion> get questions {
    final out = _rows.where((q) => !q.isRemoved).toList()
      ..sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
    return List.unmodifiable(out);
  }

  int get count => _rows.where((q) => !q.isRemoved).length;

  TtcDoctorQuestion? byId(String id) {
    for (final q in _rows) {
      if (q.id == id && !q.isRemoved) return q;
    }
    return null;
  }

  // ---- visits ---------------------------------------------------------------

  /// Where the visits come from. Swappable so a test can set exact dates;
  /// by default the couple's own appointments and the TTC consults booked in
  /// ParentVeda (not cancelled), the same two sources the Appointments page
  /// merges.
  @visibleForTesting
  static List<TtcVisitRef> Function() visitsSource = _defaultVisits;

  static List<TtcVisitRef> _defaultVisits() => [
        for (final a in TtcAppointmentsStore.instance.all)
          TtcVisitRef(id: a.id, title: a.title, startsUtc: a.startsUtc),
        for (final b in BookingStore.instance
            .bookings(stage: ServiceStage.tryingToConceive)
            .where((b) => b.status != BookingStatus.cancelled))
          TtcVisitRef(
              id: ttcBookingVisitId(b.id),
              title: b.title,
              startsUtc: b.startsUtc),
      ];

  /// Every visit, soonest first.
  List<TtcVisitRef> get visits =>
      [...visitsSource()]..sort((a, b) => a.startsUtc.compareTo(b.startsUtc));

  TtcVisitRef? visitById(String? id) {
    if (id == null) return null;
    for (final v in visitsSource()) {
      if (v.id == id) return v;
    }
    return null;
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// True once the visit's own day is over. A visit keeps its questions (and
  /// their ticks) for the whole of its day, because she may tick them in the
  /// car park or that evening.
  static bool dayPassed(TtcVisitRef v, DateTime now) =>
      _day(v.startsLocal).isBefore(_day(now));

  /// The first visit that has not started yet: where a new question goes
  /// unless she picks another, and the visit the doctor's note prepares for.
  TtcVisitRef? nextVisit({DateTime? now}) {
    final n = (now ?? DateTime.now()).toUtc();
    for (final v in visits) {
      if (v.startsUtc.isAfter(n)) return v;
    }
    return null;
  }

  /// The visit an UNTICKED question is on as of [now]. Null when no visit
  /// is coming: it waits for the next one she adds.
  ///
  /// ⚠️ DERIVED, NEVER STORED (see the header): her chosen visit while its
  /// day lasts, otherwise the first visit whose day has not passed. So a
  /// deleted visit, a visit moved into the past and a visit that simply
  /// happened all send its unticked questions forward, by the same rule.
  String? visitFor(TtcDoctorQuestion q, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final all = visits;
    final chosen = q.appointmentId == null
        ? null
        : all.where((v) => v.id == q.appointmentId).firstOrNull;
    if (chosen != null && !dayPassed(chosen, n)) return chosen.id;
    for (final v in all) {
      if (!dayPassed(v, n)) return v.id;
    }
    return null;
  }

  /// The unticked questions on [visitId] as of [now], hers first, then oldest
  /// first (the order she thought of them in).
  List<TtcDoctorQuestion> openFor(String visitId, {DateTime? now}) =>
      _ordered([
        for (final q in _rows)
          if (!q.isRemoved && !q.isAsked && visitFor(q, now: now) == visitId)
            q,
      ]);

  int openCountFor(String visitId, {DateTime? now}) =>
      openFor(visitId, now: now).length;

  /// Ticked questions, under the visit they were ticked at.
  List<TtcDoctorQuestion> askedAt(String visitId) => _ordered([
        for (final q in _rows)
          if (!q.isRemoved && q.isAsked && q.appointmentId == visitId) q,
      ]);

  /// Unticked questions with no visit coming: "for the next visit".
  List<TtcDoctorQuestion> waitingForAVisit({DateTime? now}) => _ordered([
        for (final q in _rows)
          if (!q.isRemoved && !q.isAsked && visitFor(q, now: now) == null) q,
      ]);

  /// Every unticked question, soonest visit first, then the ones waiting.
  List<TtcDoctorQuestion> openAll({DateTime? now}) {
    final order = {for (final (i, v) in visits.indexed) v.id: i};
    final open = [
      for (final q in _rows)
        if (!q.isRemoved && !q.isAsked) q,
    ];
    int rank(TtcDoctorQuestion q) =>
        order[visitFor(q, now: now)] ?? order.length;
    open.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : a.writtenAt.compareTo(b.writtenAt);
    });
    return List.unmodifiable(open);
  }

  /// HER unticked questions still pinned to [visitId] after its day passed:
  /// the ones "Did you get your answers?" asks about. They are already on
  /// the next visit (derived); this is what lets the past visit say so once
  /// and offer "Done". Her partner's are his to answer on his phone.
  List<TtcDoctorQuestion> notTickedAfter(String visitId, {DateTime? now}) {
    final v = visitById(visitId);
    if (v == null || !dayPassed(v, now ?? DateTime.now())) return const [];
    return _ordered([
      for (final q in _rows)
        if (q.isMine &&
            !q.isRemoved &&
            !q.isAsked &&
            q.appointmentId == visitId)
          q,
    ]);
  }

  /// The most recent visit that has started and still has her unticked
  /// questions on it or pinned to it: the one quiet "Did you get your
  /// answers?" line on the Appointments list. Null when there is none.
  TtcVisitRef? visitToFollowUp({DateTime? now}) {
    final n = now ?? DateTime.now();
    for (final v in visits.reversed) {
      if (v.startsUtc.isAfter(n.toUtc())) continue;
      final open = dayPassed(v, n)
          ? notTickedAfter(v.id, now: n)
          : openFor(v.id, now: n).where((q) => q.isMine);
      if (open.isNotEmpty) return v;
    }
    return null;
  }

  /// Hers first, then oldest first.
  static List<TtcDoctorQuestion> _ordered(List<TtcDoctorQuestion> l) {
    l.sort((a, b) {
      if (a.isMine != b.isMine) return a.isMine ? -1 : 1;
      return a.writtenAt.compareTo(b.writtenAt);
    });
    return List.unmodifiable(l);
  }

  /// Whether any question on the list is her partner's. Rows carry a
  /// "Yours" / "His" label only then: labelling every row "Yours" when
  /// nobody else writes any would be a word with nothing to tell apart.
  bool get hasPartnerQuestions =>
      _rows.any((q) => !q.isMine && !q.isRemoved);

  // ---- writes ---------------------------------------------------------------

  /// Saves a new question. Empty words are refused (returns null).
  ///
  /// The visit (2026-09-28): [visitId] when given; otherwise her next visit
  /// that has not started, which is the approved default; [forNextVisit]
  /// leaves it unpinned ("whichever visit comes next"). With no visit
  /// coming, it is unpinned either way.
  TtcDoctorQuestion? add(String text,
      {DateTime? now, String? visitId, bool forNextVisit = false}) {
    final words = text.trim();
    if (words.isEmpty) return null;
    final at = now ?? DateTime.now();
    // ⚠️ THE CLOCK IS NOT AN ID GENERATOR ON ITS OWN. Two adds inside one
    // clock tick (Windows ticks coarsely; a test adds three in a row) gave
    // two questions one id, and removing one removed the other. So the
    // time is only the starting point, stepped past any id already taken.
    var n = at.microsecondsSinceEpoch;
    while (_rows.any((q) => q.id == 'ttcq_$n')) {
      n++;
    }
    final q = TtcDoctorQuestion(
      id: 'ttcq_$n',
      text: words,
      writtenAt: at,
      updatedAt: at,
      appointmentId:
          forNextVisit ? null : (visitId ?? nextVisit(now: at)?.id),
    );
    _rows.add(q);
    _changed();
    return q;
  }

  /// One of her questions, open for writing: not his, not removed.
  int _mine(String id) {
    final i = _rows.indexWhere((q) => q.id == id);
    if (i < 0 || !_rows[i].isMine || _rows[i].isRemoved) return -1;
    return i;
  }

  /// Moves one of her questions to [visitId], or unpins it (null:
  /// "whichever visit comes next"). Returns whether anything changed.
  bool moveTo(String id, String? visitId) {
    final i = _mine(id);
    if (i < 0 || _rows[i].appointmentId == visitId) return false;
    _rows[i] = _rows[i].copyWith(
        appointmentId: visitId,
        clearAppointment: visitId == null,
        updatedAt: DateTime.now());
    _changed();
    return true;
  }

  /// Ticks one of her questions as asked at [visitId]. Returns the question
  /// as it was, for the Undo ([revert]), or null when there was nothing of
  /// hers to tick.
  ///
  /// The visit is written with the tick, so the question folds under the
  /// visit it was asked at even if it had rolled there from another.
  TtcDoctorQuestion? ask(String id, {required String visitId, DateTime? now}) {
    final i = _mine(id);
    if (i < 0 || _rows[i].isAsked) return null;
    final old = _rows[i];
    final at = now ?? DateTime.now();
    _rows[i] = old.copyWith(
        askedAt: at, appointmentId: visitId, updatedAt: DateTime.now());
    _changed();
    return old;
  }

  /// Takes the tick off one of her questions. It goes back on the visit it
  /// was ticked at, or forward from there if that visit's day has passed.
  bool unask(String id) {
    final i = _mine(id);
    if (i < 0 || !_rows[i].isAsked) return false;
    _rows[i] = _rows[i].copyWith(clearAsked: true, updatedAt: DateTime.now());
    _changed();
    return true;
  }

  /// "Done" under "Did you get your answers?": ticks every one of her
  /// questions still pinned to [visitId] as asked there. Returns them as
  /// they were, for the Undo.
  List<TtcDoctorQuestion> doneAt(String visitId, {DateTime? now}) {
    final before = notTickedAfter(visitId, now: now);
    if (before.isEmpty) return const [];
    final at = now ?? DateTime.now();
    for (final q in before) {
      final i = _rows.indexWhere((r) => r.id == q.id);
      _rows[i] = q.copyWith(askedAt: at, updatedAt: DateTime.now());
    }
    _changed();
    return before;
  }

  /// "Keep for the next visit": her questions still pinned to [visitId]
  /// stop naming it, so they simply belong to whichever visit comes next.
  /// This writes what she decided, not the roll-forward, which had already
  /// happened (derived) before she answered. Returns them for the Undo.
  List<TtcDoctorQuestion> keepForNextVisit(String visitId, {DateTime? now}) {
    final before = notTickedAfter(visitId, now: now);
    if (before.isEmpty) return const [];
    for (final q in before) {
      final i = _rows.indexWhere((r) => r.id == q.id);
      _rows[i] =
          q.copyWith(clearAppointment: true, updatedAt: DateTime.now());
    }
    _changed();
    return before;
  }

  /// The Undo after [ask], [doneAt], [keepForNextVisit] or [moveTo]: puts
  /// each question's visit and tick back as they were, with a fresh clock so
  /// the undo wins every merge.
  void revert(Iterable<TtcDoctorQuestion> before) {
    var changed = false;
    for (final old in before) {
      final i = _mine(old.id);
      if (i < 0) continue;
      _rows[i] = _rows[i].copyWith(
        appointmentId: old.appointmentId,
        clearAppointment: old.appointmentId == null,
        askedAt: old.askedAt,
        clearAsked: old.askedAt == null,
        updatedAt: DateTime.now(),
      );
      changed = true;
    }
    if (changed) _changed();
  }

  /// Changes the words of one of HER questions. Refuses a partner's question,
  /// an empty edit and an edit that changes nothing. Returns whether it saved.
  bool update(String id, String text) {
    final i = _rows.indexWhere((q) => q.id == id);
    if (i < 0) return false;
    final old = _rows[i];
    final words = text.trim();
    if (!old.isMine || old.isRemoved || words.isEmpty || words == old.text) {
      return false;
    }
    _rows[i] = old.copyWith(text: words, updatedAt: DateTime.now());
    _changed();
    return true;
  }

  /// Takes one of her questions off the list. Returns it for the Undo, or
  /// null when there was nothing of hers to remove.
  ///
  /// A soft delete: the row stays with `removedAt` set, so the removal is an
  /// ordinary upsert and a newer clock than any push already in flight.
  TtcDoctorQuestion? remove(String id) {
    final i = _rows.indexWhere((q) => q.id == id);
    if (i < 0) return null;
    final old = _rows[i];
    if (!old.isMine || old.isRemoved) return null;
    final now = DateTime.now();
    _rows[i] = old.copyWith(removedAt: now, updatedAt: now);
    _changed();
    return old;
  }

  /// The Undo after [remove]: the same id comes back, with a fresh clock so
  /// it beats the removal everywhere.
  void restore(String id) {
    final i = _rows.indexWhere((q) => q.id == id);
    if (i < 0 || !_rows[i].isRemoved) return;
    _rows[i] =
        _rows[i].copyWith(clearRemoved: true, updatedAt: DateTime.now());
    _changed();
  }

  void _changed() {
    _persist();
    notifyListeners();
    _rearmVisitReminders();
  }

  /// The evening-before reminder says how many questions a visit has
  /// ("· 2 questions to ask"), so any change here re-arms them. Cheap: a
  /// handful of visits, each a cancel and a schedule on the phone.
  void _rearmVisitReminders() {
    try {
      TtcAppointmentsStore.instance.rearmReminders();
    } catch (_) {/* a reminder must never stop a question being saved */}
  }

  @visibleForTesting
  void resetForTest() {
    _rows.clear();
    _loaded = true;
    if (!_localReady.isCompleted) _localReady.complete();
    notifyListeners();
  }

  /// Forgets the in-memory list and loads again from `shared_preferences`,
  /// the way a cold start does. For the persistence and migration tests.
  @visibleForTesting
  Future<void> reloadForTest() async {
    _rows.clear();
    _loaded = false;
    _localReady = Completer<void>();
    await _load();
  }

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _rows
        ..clear()
        ..addAll((p.getStringList(_key) ?? const <String>[])
            .map(TtcDoctorQuestion.decode)
            .whereType<TtcDoctorQuestion>());
      if (await migrateFromJournal(p)) await _persist();
    } catch (_) {/* keep what loaded */}
    _loaded = true;
    if (!_localReady.isCompleted) _localReady.complete();
    notifyListeners();
    await syncFromCloud();
    // Her partner's questions may have just arrived, which changes a
    // visit's count. Harmless if it runs before the launch re-arm: that
    // re-arm runs after the wipe and counts again.
    if (SupabaseRepo.isLoggedIn) _rearmVisitReminders();
  }

  /// The one-time move of her old questions out of the journal's cache.
  ///
  /// Runs only while [kMigratedFlag] is unset, and skips any id already here,
  /// so running it twice (or a flag lost with a reinstall that kept the cache)
  /// can never make a second copy. Returns whether anything was added.
  ///
  /// The old entries are decoded here rather than through the journal's own
  /// model, because the journal's code is commented out: this reads the JSON
  /// the journal wrote (`id`, `date`, `kind`, `author`, `text`) and nothing
  /// else.
  @visibleForTesting
  Future<bool> migrateFromJournal(SharedPreferences p) async {
    if (p.getBool(kMigratedFlag) ?? false) return false;
    var added = false;
    for (final raw in p.getStringList(kOldJournalKey) ?? const <String>[]) {
      try {
        final m = jsonDecode(raw);
        if (m is! Map || m['kind'] != 'question') continue;
        final id = m['id'];
        final date = DateTime.tryParse('${m['date']}');
        final text = ((m['text'] as String?) ?? '').trim();
        if (id is! String || date == null || text.isEmpty) continue;
        if (_rows.any((q) => q.id == id)) continue;
        _rows.add(TtcDoctorQuestion(
          id: id,
          text: text,
          writtenAt: date,
          updatedAt: date,
          author: m['author'] == TtcAuthor.partner.name
              ? TtcAuthor.partner
              : TtcAuthor.me,
        ));
        added = true;
      } catch (_) {/* one bad entry never stops the rest */}
    }
    await p.setBool(kMigratedFlag, true);
    return added;
  }

  // ---- cloud ----------------------------------------------------------------
  //  Couple-scoped read (`fetchShared`, RLS decides), own-row write. The merge
  //  is by id and newer `updated_at` wins, removals included.

  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared(table,
        orderBy: 'written_at', ascending: true);
    final me = SupabaseRepo.userId;
    for (final row in rows) {
      final id = row['id'];
      if (id is! String) continue;
      final cloud = TtcDoctorQuestion(
        id: id,
        text: (row['body'] as String?) ?? '',
        writtenAt: SupabaseRepo.parseDbTime(row['written_at']),
        updatedAt: SupabaseRepo.parseDbTime(row['updated_at']),
        // Whose question it is comes from the row's owner, not a flag the
        // writing phone chose.
        author: row['user_id'] == me ? TtcAuthor.me : TtcAuthor.partner,
        removedAt: row['removed_at'] == null
            ? null
            : SupabaseRepo.parseDbTime(row['removed_at']),
        // 0092 (2026-09-28): the visit and the tick travel with the row, so
        // her partner sees which visit she means and what is already asked.
        appointmentId: row['appointment_id'] as String?,
        askedAt: row['asked_at'] == null
            ? null
            : SupabaseRepo.parseDbTime(row['asked_at']),
      );
      final i = _rows.indexWhere((q) => q.id == id);
      if (i < 0) {
        _rows.add(cloud);
      } else if (cloud.updatedAt.isAfter(_rows[i].updatedAt)) {
        _rows[i] = cloud;
      }
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    await TtcSyncUtil.upsertAll(
      table,
      [
        // Only her own rows. Her partner's are his to write, and the table's
        // policy refuses a row whose owner is not the writer anyway.
        for (final q in _rows.where((q) => q.isMine))
          {
            'id': q.id,
            'user_id': uid,
            'body': q.text,
            'written_at': SupabaseRepo.dbTime(q.writtenAt),
            'updated_at': SupabaseRepo.dbTime(q.updatedAt),
            // Always sent, null included: an Undo has to clear the stamp in
            // the cloud too, and a key left out would leave it set.
            'removed_at':
                q.removedAt == null ? null : SupabaseRepo.dbTime(q.removedAt!),
            // Both always sent, null included, for the same reason: an
            // untick or "Keep for the next visit" clears them.
            'appointment_id': q.appointmentId,
            'asked_at':
                q.askedAt == null ? null : SupabaseRepo.dbTime(q.askedAt!),
          }
      ],
      onConflict: 'id',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_key, _rows.map((q) => q.encode()).toList());
    } catch (_) {/* best-effort */}
  }
}

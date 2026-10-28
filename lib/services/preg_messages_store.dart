// =============================================================================
//  PregMessagesStore — the app speaks first, in pregnancy (2026-09-30)
// -----------------------------------------------------------------------------
//  The pregnancy gap analysis, P1 "The app speaks first, at the right
//  moments": in pregnancy the app never started a conversation, although
//  onboarding previews a weekly message to ask for notification permission.
//  What to Expect sends "Oh baby! You're in Week 8"; Flo sends daily insights.
//  The dates of pregnancy are fixed and known, which makes this the easiest
//  caring feature there is: the app remembers the calendar for her, the way a
//  good nurse would.
//
//  SEVEN KINDS, EACH OFF-ABLE (Reminders › From ParentVeda), EACH OPENING THE
//  PAGE IT NAMES (`preg_messages_screen.dart`):
//
//    newWeek      the morning each week starts   "Week 21 starts today"
//    ntScan       week 11   the NT scan window (11 to 13 weeks)
//    anomalyScan  week 18   the anomaly scan window (18 to 22 weeks)
//    tdap         week 27   the Tdap vaccine, as her doctor advises
//    movements    week 28   get to know the baby's movements
//    hospitalBag  week 34   pack the bag
//    babyArrived  week 37   "Has your baby arrived?", gently
//
//  FOUR MORE, 2026-10-28 (relevance Batch 7, PREGNANCY-GAP 11). Weeks 4 to 10
//  said nothing but "a new week", in the weeks with the most to arrange, and
//  the sugar test and the growth scan were never mentioned:
//
//    firstVisit   week 6    the first antenatal visit (6 to 10 weeks)
//    datingScan   week 7    the dating scan (6 to 9 weeks), NOT when a scan,
//                           a doctor or an IVF transfer already gave the date
//    glucoseTest  week 24   the sugar test (24 to 28 weeks)
//    growthScan   week 32   a growth scan, if her doctor has advised one
//
//  The weeks are the Scans door's own (`pv_door_scans.dart` tile metas), so a
//  message and the page it opens can never name two windows.
//
//  Every clinical line reminds, explains or helps her prepare; none adds a
//  step her doctor did not (CLAUDE.md, clinical ownership). The scan and
//  vaccine lines say "usually" and "ask your doctor", never "you need".
//
//  ---------------------------------------------------------------------------
//  ⚠️ COMPUTED, NOT QUEUED — the TTC pattern (docs/BACKEND-PATTERNS.md §16m)
//  ---------------------------------------------------------------------------
//
//  `refresh()` rebuilds every candidate from her due date. A message whose
//  moment has passed is DELIVERED and frozen: kept in the inbox, never re-sent.
//  A message still ahead is PENDING and rebuilt on every refresh, with its phone
//  notification.
//
//  ONE DIFFERENCE FROM TTC, ON PURPOSE. TTC's ids carry the date they are about
//  (`window:2026-09-20`) and a pending message keeps the moment it was first
//  given. Here the id is the week or the moment itself (`week:21`, `tdap`), and
//  a pending message always takes the time today's due date gives it. Why:
//  the thing she corrects in pregnancy is the due date, and after a dating scan
//  every upcoming message should move with it, while one already delivered
//  must not arrive a second time just because its date changed. A date in the
//  id would do the opposite of both.
//
//  WHO GETS THEM: only in the pregnancy stage, only with a due date she has
//  set (never the week-20 placeholder), never after she has told us the
//  pregnancy has ended (and anything pending is dropped the moment she does),
//  and never on the partner's side: these are about her body and her
//  appointments, and his messages are the father-mode pass.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE STARTUP ORDER IS LOAD-BEARING (same trap as TTC)
//  ---------------------------------------------------------------------------
//
//  `ReminderStore.init` ends in `NotificationService.syncAll`, which cancels
//  EVERY pending notification. So [init] runs in the chain in `main.dart`,
//  after `ReminderStore.instance.init()`. Its phone ids are a block of its own
//  (919101 upwards) and a refresh cancels only those.
// =============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'father_preview.dart';
import 'life_stage_store.dart';
import 'notification_service.dart';
import 'pregnancy_controller.dart';
import 'pregnancy_ended_store.dart';
import 'remote/cloud_merged_store.dart';
// import 'remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

/// The seven kinds. The NAME is persisted: renaming one strands every message
/// already delivered under it.
///
/// Listed in the order they arrive, because the Messages screen lists its
/// switches in this order. The order is not persisted; only the name is.
enum PregMessageKind {
  newWeek,
  firstVisit,
  datingScan,
  ntScan,
  anomalyScan,
  glucoseTest,
  tdap,
  movements,
  growthScan,
  hospitalBag,
  babyArrived,
}

/// How many upcoming weeks are armed on the phone at once. If she does not
/// open the app for a month, the next four still arrive; the fifth is armed
/// the next time she does.
const int kPregWeekPhoneSlots = 4;

extension PregMessageKindInfo on PregMessageKind {
  /// The first OS notification id of the kind. Only [newWeek] holds more than
  /// one ([kPregWeekPhoneSlots]); the rest hold one each.
  int get notificationId => switch (this) {
        PregMessageKind.newWeek => 919101,
        PregMessageKind.ntScan => 919111,
        PregMessageKind.anomalyScan => 919112,
        PregMessageKind.tdap => 919113,
        PregMessageKind.movements => 919114,
        PregMessageKind.hospitalBag => 919115,
        PregMessageKind.babyArrived => 919116,
        PregMessageKind.firstVisit => 919117,
        PregMessageKind.datingScan => 919118,
        PregMessageKind.glucoseTest => 919119,
        PregMessageKind.growthScan => 919120,
      };

  List<int> get phoneIds => this == PregMessageKind.newWeek
      ? [for (var i = 0; i < kPregWeekPhoneSlots; i++) notificationId + i]
      : [notificationId];

  /// The switch's name in Reminders.
  String get label => switch (this) {
        PregMessageKind.newWeek => 'Your new week',
        PregMessageKind.firstVisit => 'Your first visit',
        PregMessageKind.datingScan => 'The dating scan',
        PregMessageKind.glucoseTest => 'The sugar test',
        PregMessageKind.growthScan => 'A growth scan',
        PregMessageKind.ntScan => 'NT scan window',
        PregMessageKind.anomalyScan => 'Anomaly scan window',
        PregMessageKind.tdap => 'Tdap vaccine',
        PregMessageKind.movements => "Your baby's movements",
        PregMessageKind.hospitalBag => 'Packing the hospital bag',
        PregMessageKind.babyArrived => 'Has your baby arrived?',
      };

  /// One line under the switch: when it comes.
  String get when => switch (this) {
        PregMessageKind.newWeek => 'The morning each new week starts',
        PregMessageKind.firstVisit => 'At 6 weeks',
        PregMessageKind.datingScan =>
          'At 7 weeks, unless a scan or your doctor gave your due date',
        PregMessageKind.glucoseTest => 'At 24 weeks',
        PregMessageKind.growthScan => 'At 32 weeks, if your doctor advises one',
        PregMessageKind.ntScan => 'At 11 weeks',
        PregMessageKind.anomalyScan => 'At 18 weeks',
        PregMessageKind.tdap => 'At 27 weeks',
        PregMessageKind.movements => 'At 28 weeks',
        PregMessageKind.hospitalBag => 'At 34 weeks',
        PregMessageKind.babyArrived => 'At 37 weeks',
      };
}

class PregMessage {
  const PregMessage({
    required this.id,
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
    this.week,
    this.read = false,
  });

  /// `week:<n>` or the moment's name. Stable, persisted, never shown.
  final String id;
  final PregMessageKind kind;

  /// When it arrives (or arrived).
  final DateTime at;
  final String title;
  final String body;

  /// The week a new-week message is about.
  final int? week;
  final bool read;

  bool deliveredBy(DateTime now) => !at.isAfter(now);

  PregMessage copyWith({DateTime? at, bool? read}) => PregMessage(
      id: id,
      kind: kind,
      at: at ?? this.at,
      title: title,
      body: body,
      week: week,
      read: read ?? this.read);

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'at': at.toIso8601String(),
        'title': title,
        'body': body,
        if (week != null) 'week': week,
        'read': read,
      };

  static PregMessage? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final kind = PregMessageKind.values.where((k) => k.name == raw['kind']).firstOrNull;
    final at = DateTime.tryParse('${raw['at']}');
    final id = raw['id'];
    if (kind == null || at == null || id is! String) return null;
    return PregMessage(
      id: id,
      kind: kind,
      at: at,
      title: '${raw['title'] ?? ''}',
      body: '${raw['body'] ?? ''}',
      week: raw['week'] is int ? raw['week'] as int : null,
      read: raw['read'] == true,
    );
  }
}

/// What the messages are computed from. Plain values, so the rules are pure
/// and a test can build any pregnancy it likes.
class PregMessageFacts {
  const PregMessageFacts({
    required this.dueDate,
    required this.dueDateSet,
    this.ended = false,
    this.inPregnancy = true,
    this.partner = false,
    this.pregnancyStart,
    this.dueDateFromClinic = false,
  });

  final DateTime dueDate;
  final bool dueDateSet;
  final bool ended;
  final bool inPregnancy;
  final bool partner;

  /// The day THIS pregnancy began in the app (the pregnancy stage's entry
  /// date), or null when unknown. Messages delivered before it belong to an
  /// earlier pregnancy (STAGE-TRANSITIONS B5, 2026-10-24).
  final DateTime? pregnancyStart;

  /// True when a scan, her doctor or an IVF transfer gave the due date
  /// (`DueDateSource.clinicOwned`). The dating scan's job is already done,
  /// and a message suggesting one would second-guess her clinic.
  final bool dueDateFromClinic;

  static PregMessageFacts? fromStores() {
    final c = PregnancyController.current;
    if (c == null) return null;
    final stage = LifeStageStore.instance.stage;
    return PregMessageFacts(
      dueDate: c.dueDate,
      dueDateSet: c.isDueDateSet,
      ended: PregnancyEndedStore.instance.ended,
      // Null is the app before a stage was ever chosen, whose shell is
      // pregnancy's.
      inPregnancy: stage == null || stage == LifeStage.pregnancy,
      partner: FatherPreview.instance.on,
      pregnancyStart: stage == LifeStage.pregnancy
          ? LifeStageStore.instance.enteredAt
          : null,
      dueDateFromClinic: c.dueDateFromClinic,
    );
  }

  bool get speaks => dueDateSet && !ended && inPregnancy && !partner;
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// The day week [w] starts, counted the controller's way (`currentWeek` is
/// 40 minus whole weeks to the due date, so week w begins 7 × (40 − w) + 6
/// days before it).
DateTime pregWeekStart(DateTime due, int w) =>
    _day(due).subtract(Duration(days: 7 * (40 - w) + 6));

/// The week she is in on [now], unclamped, the controller's arithmetic.
int pregWeekOn(DateTime due, DateTime now) =>
    40 - (_day(due).difference(_day(now)).inDays / 7).floor();

/// Every message her dates call for, from this week on.
///
/// A moment is only offered while it can still help: the first visit up to
/// week 10, the dating scan up to 9, the NT line up to 13, the anomaly line up
/// to 22, the sugar test up to 28, Tdap up to 36, the growth scan up to 36,
/// the bag up to 38. A moment
/// that has passed but is still inside its window is delivered at once, in the
/// app only (see [PregMessagesStore.apply]).
List<PregMessage> pregMessageCandidates(PregMessageFacts f, DateTime now) {
  if (!f.speaks) return const [];
  final w0 = pregWeekOn(f.dueDate, now);
  if (w0 > 42) return const [];
  final out = <PregMessage>[];

  // ---- the new week, 9 in the morning --------------------------------------
  for (var w = w0 < 4 ? 4 : w0; w <= w0 + kPregWeekPhoneSlots && w <= 42; w++) {
    final s = pregWeekStart(f.dueDate, w);
    out.add(PregMessage(
      id: 'week:$w',
      kind: PregMessageKind.newWeek,
      at: DateTime(s.year, s.month, s.day, 9),
      week: w,
      title: 'Week $w starts today',
      body: w >= 41
          ? "You're past your due date, which is common. See what this week holds, and when to call."
          : "What's new for your baby this week, and what may change for you.",
    ));
  }

  // ---- the moments, 10 in the morning on the week's second day ------------
  void moment(PregMessageKind k, int week, int lastUseful, String title, String body) {
    if (w0 > lastUseful) return;
    final s = pregWeekStart(f.dueDate, week).add(const Duration(days: 1));
    out.add(PregMessage(
      id: k.name,
      kind: k,
      at: DateTime(s.year, s.month, s.day, 10),
      title: title,
      body: body,
    ));
  }

  moment(PregMessageKind.firstVisit, 6, 10, 'Your first antenatal visit',
      'Most first visits are between 6 and 10 weeks, with a few blood tests and a check of your dates. Here is what usually happens, and what to ask.');
  // Not when her clinic already dated the pregnancy (2026-10-28, the user's
  // call): the scan has done its job, and its date is theirs.
  if (!f.dueDateFromClinic) {
    moment(PregMessageKind.datingScan, 7, 9, 'The dating scan',
        'An early scan, usually between 6 and 9 weeks, confirms how many weeks you are. If it gives you a new due date, you can change yours in the app.');
  }
  moment(PregMessageKind.ntScan, 11, 13, 'The NT scan window',
      'The NT scan is usually done between 11 and 13 weeks. Ask your doctor if it is right for you.');
  moment(PregMessageKind.anomalyScan, 18, 22, 'The anomaly scan window',
      'The anomaly scan is usually done between 18 and 22 weeks. If it is not booked yet, ask at your next visit.');
  moment(PregMessageKind.glucoseTest, 24, 28, 'The sugar test',
      'The sugar test (OGTT) is usually done between 24 and 28 weeks. Some clinics test earlier too. Ask yours when, and whether to come fasting.');
  moment(PregMessageKind.tdap, 27, 36, 'The Tdap vaccine',
      'Your doctor may offer the Tdap vaccine from now. It helps protect your baby from whooping cough. Ask at your next visit.');
  moment(PregMessageKind.movements, 28, 42, "Your baby's movements",
      "From now, get to know your baby's pattern of movements. If they slow down or change, call your doctor the same day.");
  // "If advised", as the app's own growth scan card says: not every clinic
  // books one, and the message must not add a step her doctor did not.
  moment(PregMessageKind.growthScan, 32, 36, 'A growth scan, if advised',
      'If your doctor has suggested a growth scan, it is often done around now. Here is what it checks, and what the numbers mean.');
  moment(PregMessageKind.hospitalBag, 34, 38, 'Time to pack the bag',
      'A good week to pack the hospital bag, so it is ready and you can stop thinking about it.');
  moment(PregMessageKind.babyArrived, 37, 42, 'Has your baby arrived?',
      "Whenever your baby comes, tell us when you're ready and ParentVeda will move with you to the first weeks at home.");

  return out;
}

/// Where the phone notifications go. An interface so tests can see what was
/// scheduled without a platform plugin.
abstract class PregMessagePhone {
  Future<void> schedule(
      {required int id, required String title, required String body, required DateTime when});
  Future<void> cancel(int id);
}

class _OsPhone implements PregMessagePhone {
  const _OsPhone();

  @override
  Future<void> schedule(
          {required int id, required String title, required String body, required DateTime when}) =>
      NotificationService.instance.scheduleOneOff(id: id, title: title, body: body, when: when);

  @override
  Future<void> cancel(int id) => NotificationService.instance.cancel(id);
}

// ⚠️ IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log). It was phone-only, so a
// sign-out or a new phone emptied the inbox, lost every read mark and turned
// her switches back on. Items: `msg|<id>` per DELIVERED message (value = its
// JSON, read flag included), `off|<kind>` (true) per kind she switched off,
// and `phone` (bool). Pending messages are not items: each phone recomputes
// them, and re-arms its alarms after a merge.
class PregMessagesStore extends ChangeNotifier
    with WidgetsBindingObserver, CloudMergedStore {
  PregMessagesStore._();
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   PregMessagesStore._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
  static final PregMessagesStore instance = PregMessagesStore._();

  static const _kMessages = 'preg_messages_v1';
  static const _kOff = 'preg_messages_off';
  static const _kPhone = 'preg_messages_phone';

  /// Delivered messages kept. A whole pregnancy is about 45.
  static const int _keep = 80;

  final List<PregMessage> _all = [];
  final Set<PregMessageKind> _off = {};
  bool _phoneOn = true;
  bool _loaded = false;
  bool _listening = false;

  PregMessagePhone _phone = const _OsPhone();

  @visibleForTesting
  set phone(PregMessagePhone p) => _phone = p;

  /// Opens a tapped message. Set by the messages screen's file at startup
  /// (the store must not import a screen); null in tests.
  static void Function(PregMessage? m)? phoneTapOpener;

  bool get isLoaded => _loaded;

  /// Delivered messages, newest first. What the inbox lists.
  List<PregMessage> delivered({DateTime? now}) {
    final t = now ?? DateTime.now();
    return _all.where((m) => m.deliveredBy(t)).toList()..sort((a, b) => b.at.compareTo(a.at));
  }

  /// Messages still ahead, soonest first.
  List<PregMessage> pending({DateTime? now}) {
    final t = now ?? DateTime.now();
    return _all.where((m) => !m.deliveredBy(t)).toList()..sort((a, b) => a.at.compareTo(b.at));
  }

  int get unreadCount => delivered().where((m) => !m.read).length;

  bool isOn(PregMessageKind kind) => !_off.contains(kind);
  bool get phoneOn => _phoneOn;

  // ---- lifecycle ------------------------------------------------------------

  /// Load, listen, schedule. Once at startup, AFTER `ReminderStore.init`.
  Future<void> init() async {
    await _load();
    // Before the first refresh, so a message already delivered (and read) on
    // another phone is known here and not delivered a second time.
    await syncMergedFromCloud();
    if (!_listening) {
      _listening = true;
      PregnancyController.current?.addListener(_changed);
      LifeStageStore.instance.addListener(_changed);
      PregnancyEndedStore.instance.addListener(_changed);
      FatherPreview.instance.addListener(_changed);
      try {
        WidgetsBinding.instance.addObserver(this);
      } catch (_) {/* no binding in a pure test */}
      NotificationService.instance.addTapListener(handlePhoneTap);
    }
    await refresh();
  }

  /// The message a phone notification [id] was for: the newest delivered one
  /// of its kind. Null when the id is not ours.
  PregMessage? messageForPhoneId(int id, {DateTime? now}) {
    final kind = PregMessageKind.values.where((k) => k.phoneIds.contains(id)).firstOrNull;
    if (kind == null) return null;
    final arrived = delivered(now: now).where((m) => m.kind == kind);
    return arrived.isEmpty ? null : arrived.first;
  }

  /// The [NotificationService] tap listener. Claims only our own ids.
  bool handlePhoneTap(int id) {
    if (!PregMessageKind.values.any((k) => k.phoneIds.contains(id))) return false;
    final m = messageForPhoneId(id);
    if (m != null) markRead(m.id);
    phoneTapOpener?.call(m);
    return true;
  }

  /// A new day may have made a message due. Coming back is when that is seen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _changed();
  }

  bool _queued = false;
  void _changed() {
    if (_queued) return;
    _queued = true;
    scheduleMicrotask(() {
      _queued = false;
      refresh();
    });
  }

  Future<void>? _running;
  bool _again = false;

  /// Recompute every message and re-arm the phone. Idempotent; concurrent
  /// calls collapse into one more run.
  Future<void> refresh({DateTime? now, PregMessageFacts? facts}) async {
    if (_running != null) {
      _again = true;
      return _running;
    }
    final run = _refresh(now, facts);
    _running = run;
    try {
      await run;
    } finally {
      _running = null;
    }
    if (_again) {
      _again = false;
      await refresh(now: now, facts: facts);
    }
  }

  Future<void> _refresh(DateTime? fixedNow, PregMessageFacts? fixedFacts) async {
    if (!_loaded) await _load();
    // Not before the stores know what they hold: an early refresh would read
    // "no due date" and drop everything pending, then rebuild it a moment
    // later.
    final c = PregnancyController.current;
    if (fixedFacts == null &&
        (c == null ||
            c.isLoading ||
            !LifeStageStore.instance.isLoaded ||
            !PregnancyEndedStore.instance.isLoaded)) {
      return;
    }
    final facts = fixedFacts ?? PregMessageFacts.fromStores();
    if (facts == null) return;
    final now = fixedNow ?? DateTime.now();
    final changed = apply(pregMessageCandidates(facts, now), now,
        since: facts.pregnancyStart);

    // ---- the phone: cancel our ids only, re-arm what is pending -------------
    for (final k in PregMessageKind.values) {
      for (final id in k.phoneIds) {
        await _phone.cancel(id);
      }
    }
    if (_phoneOn) {
      var slot = 0;
      for (final m in pending(now: now)) {
        var id = m.kind.notificationId;
        if (m.kind == PregMessageKind.newWeek) {
          if (slot >= kPregWeekPhoneSlots) continue;
          id += slot++;
        }
        await _phone.schedule(id: id, title: m.title, body: m.body, when: m.at);
      }
    }
    if (changed) {
      await _persist();
      notifyListeners();
    }
  }

  /// Folds [candidates] into the list. Returns true when anything changed.
  /// Public for tests: it is the whole "sent once, and moves with the date"
  /// rule, and it is pure.
  ///
  ///  * delivered messages stay, frozen;
  ///  * a candidate whose id was already delivered is dropped (sent once, even
  ///    if a corrected due date moved its moment);
  ///  * everything pending is REPLACED by the candidates, so its time follows
  ///    today's due date, and a pending message with no candidate (her
  ///    pregnancy ended, a switch went off) simply goes;
  ///  * a candidate whose moment has passed is delivered now, in the app only:
  ///    no phone notification for something she can already see. Only the
  ///    newest such new-week message is kept, so a first launch at week 20
  ///    does not fill the inbox with weeks she has lived through.
  @visibleForTesting
  ///  * [since] (B5, 2026-10-24): "sent once" means once PER PREGNANCY. A
  ///    message delivered before this pregnancy began was a different
  ///    pregnancy's `week:12`; it stays in her inbox, but no longer stops this
  ///    pregnancy's week 12. Null (unknown start) keeps the old rule.
  bool apply(List<PregMessage> candidates, DateTime now, {DateTime? since}) {
    final before = jsonEncode([for (final m in _all) m.toJson()]);
    final delivered = _all.where((m) => m.deliveredBy(now)).toList();
    // Kept for revert: `final sent = delivered.map((m) => m.id).toSet();`
    final sent = delivered
        .where((m) => since == null || !m.at.isBefore(since))
        .map((m) => m.id)
        .toSet();

    final late = <PregMessage>[];
    final next = <PregMessage>[...delivered];
    for (final c in candidates) {
      if (!isOn(c.kind) || sent.contains(c.id)) continue;
      if (c.deliveredBy(now)) {
        late.add(c);
      } else {
        next.add(c);
      }
    }
    // Late ones: every moment, but only the latest week.
    final lateWeeks = late.where((m) => m.kind == PregMessageKind.newWeek).toList()
      ..sort((a, b) => (b.week ?? 0).compareTo(a.week ?? 0));
    for (final m in late) {
      if (m.kind == PregMessageKind.newWeek && m != lateWeeks.first) continue;
      next.add(m.copyWith(at: now));
    }

    next.sort((a, b) => b.at.compareTo(a.at));
    // One message per id, the newest (B5): an earlier pregnancy's `week:12`
    // gives way to this pregnancy's, since ids key the phone, the read state
    // and the cloud row (`msg|<id>`).
    final seen = <String>{};
    next.retainWhere((m) => seen.add(m.id));
    final keepDelivered = next.where((m) => m.deliveredBy(now)).take(_keep);
    final keepPending = next.where((m) => !m.deliveredBy(now));
    _all
      ..clear()
      ..addAll(keepPending)
      ..addAll(keepDelivered);
    return jsonEncode([for (final m in _all) m.toJson()]) != before;
  }

  // ---- her choices ----------------------------------------------------------

  void markRead(String id) {
    final i = _all.indexWhere((m) => m.id == id);
    if (i < 0 || _all[i].read) return;
    _all[i] = _all[i].copyWith(read: true);
    _persist();
    notifyListeners();
  }

  void markAllRead() {
    final now = DateTime.now();
    var any = false;
    for (var i = 0; i < _all.length; i++) {
      if (_all[i].deliveredBy(now) && !_all[i].read) {
        _all[i] = _all[i].copyWith(read: true);
        any = true;
      }
    }
    if (!any) return;
    _persist();
    notifyListeners();
  }

  /// A kind switched off drops what of it is pending, with its phone
  /// notification. What she already received stays.
  Future<void> setOn(PregMessageKind kind, bool on) async {
    if (isOn(kind) == on) return;
    on ? _off.remove(kind) : _off.add(kind);
    if (!on) {
      final now = DateTime.now();
      _all.removeWhere((m) => m.kind == kind && !m.deliveredBy(now));
    }
    await _persist();
    notifyListeners();
    await refresh();
  }

  /// Whether messages also go to the phone. The inbox works either way.
  Future<void> setPhoneOn(bool on) async {
    if (_phoneOn == on) return;
    _phoneOn = on;
    await _persist();
    notifyListeners();
    if (on) {
      try {
        await NotificationService.instance.requestPermission();
      } catch (_) {/* the inbox still works */}
    }
    await refresh();
  }

  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  //   // are wiped, the singleton was not.
  //   // Memory only; the listeners it added stay, so the next person's facts
  //   // refill it.
  //   void _resetForAccount() {
  //     _all.clear();
  //     _off.clear();
  //     _phoneOn = true;
  //     _loaded = false;
  //     notifyListeners();
  //   }

  @visibleForTesting
  void resetForTest() {
    _all.clear();
    _off.clear();
    _phoneOn = true;
    _loaded = true;
    notifyListeners();
  }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'preg_messages';

  @override
  Map<String, Object?> cloudItems() {
    final now = DateTime.now();
    return {
      for (final m in _all)
        if (m.deliveredBy(now)) 'msg|${m.id}': m.toJson(),
      for (final k in _off) 'off|${k.name}': true,
      'phone': _phoneOn,
    };
  }

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _all.clear();
    _off.clear();
    _phoneOn = true;
    for (final e in items.entries) {
      final k = e.key;
      if (k.startsWith('msg|')) {
        final m = PregMessage.fromJson(e.value);
        if (m != null) _all.add(m);
      } else if (k.startsWith('off|')) {
        final kind = PregMessageKind.values
            .where((x) => x.name == k.substring(4))
            .firstOrNull;
        if (kind != null) _off.add(kind);
      } else if (k == 'phone') {
        _phoneOn = e.value != false;
      }
    }
    _all.sort((a, b) => b.at.compareTo(a.at));
    _loaded = true;
    // Pending messages and the phone's alarms follow from this state: rebuild
    // them, unawaited. Not on a sign-out (no items), which must not arm any.
    if (items.isNotEmpty) _changed();
  }

  @override
  Future<void> persistLocalCache() => _persist();

  // ---- persistence ----------------------------------------------------------

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_kMessages);
      if (raw != null) {
        final list = jsonDecode(raw);
        if (list is List) {
          _all
            ..clear()
            ..addAll(list.map(PregMessage.fromJson).whereType<PregMessage>());
        }
      }
      _off
        ..clear()
        ..addAll((p.getStringList(_kOff) ?? const <String>[])
            .map((n) => PregMessageKind.values.where((k) => k.name == n).firstOrNull)
            .whereType<PregMessageKind>());
      _phoneOn = p.getBool(_kPhone) ?? true;
    } catch (_) {/* start empty; a storage failure is never a crash */}
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kMessages, jsonEncode([for (final m in _all) m.toJson()]));
      await p.setStringList(_kOff, [for (final k in _off) k.name]);
      await p.setBool(_kPhone, _phoneOn);
    } catch (_) {/* best-effort */}
  }
}

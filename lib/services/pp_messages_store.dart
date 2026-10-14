// =============================================================================
//  PpMessagesStore — the app speaks first, in parenting (2026-10-07)
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P1 (Behind · Messages): "We ask for notification
//  permission by promising a message we never send ... She picks reminder
//  topics and nothing ever arrives ... The most important reminder in the first
//  two years is opt-in per visit, and wrong." The fix, kind by kind, each tied
//  to the topic she picks in her family profile (`NotifyTopic`):
//
//    age        Weekly journey  "Meera is 3 weeks old today" (weekly to 8
//                               weeks), "Meera is 5 months today" (monthly to
//                               3 years), then every three months to 6 years:
//                               the age page has a note for each of these.
//    vaccine    Vaccinations    3 days before each visit still to come, on
//                               THIS child's dates (VaxStore), 10 am.
//    milestones Milestones      when a new phase starts: the skills that often
//                               come in now, 6 pm the same day.
//    activity   Activities      one thing to try each Monday, from the month
//                               note or the phase's play line.
//
//  Feeding and Sleep stay off, as the gap analysis says, until she sets a time
//  herself (the feed and sleep logs are hers to open). With no topic chosen at
//  all, age, vaccines and milestones are on: onboarding promised the monthly
//  message, and the gap analysis wants vaccine reminders on by default "with
//  one switch to turn them off". Every kind has its own switch.
//
//  ⚠️ THE SAME MACHINE AS PREGNANCY (`PregMessagesStore`, BACKEND-PATTERNS
//  §16s): computed, not queued. `refresh()` rebuilds every candidate from the
//  child's date of birth and the vaccine record; a message whose moment has
//  passed is DELIVERED and frozen (kept, never re-sent); one still ahead is
//  PENDING and re-armed every refresh, so a corrected birth date moves it. Ids
//  are the moment itself (`age:m5`, `vax:mo9`, `phase:12`), never a date, so
//  "the same message" survives a correction and a delivered one never repeats.
//
//  WHO GETS THEM: parenting stage, a real child (never the placeholder), not
//  the partner's side (his are the father pass). Phone ids are a block of their
//  own (929101 upwards); a refresh cancels only those. Init runs AFTER
//  `ReminderStore.init` (whose syncAll cancels every pending notification),
//  the same startup trap pregnancy documents.
// =============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pp_phase_docs.dart' show ppPhaseDocFor;
import '../screens/post_pregnancy/pp_child_profile.dart';
import '../screens/post_pregnancy/pp_month_notes.dart';
import '../screens/post_pregnancy/pp_phases_data.dart';
import '../screens/post_pregnancy/pp_vaccine_data.dart';
import 'family_profile.dart';
import 'father_preview.dart';
import 'life_stage_store.dart';
import 'notification_service.dart';

/// The kinds. The NAME is persisted.
enum PpMessageKind { age, vaccine, milestones, activity }

/// Upcoming messages armed on the phone at once, per kind.
const int kPpPhoneSlots = 4;

extension PpMessageKindInfo on PpMessageKind {
  int get notificationId => switch (this) {
        PpMessageKind.age => 929101,
        PpMessageKind.vaccine => 929111,
        PpMessageKind.milestones => 929121,
        PpMessageKind.activity => 929131,
      };

  List<int> get phoneIds => [for (var i = 0; i < kPpPhoneSlots; i++) notificationId + i];

  /// The topic in her family profile that turns this kind on.
  NotifyTopic get topic => switch (this) {
        PpMessageKind.age => NotifyTopic.weekly,
        PpMessageKind.vaccine => NotifyTopic.vaccinations,
        PpMessageKind.milestones => NotifyTopic.milestones,
        PpMessageKind.activity => NotifyTopic.activities,
      };

  /// On when she has chosen no topic at all.
  bool get onByDefault => this != PpMessageKind.activity;

  String get label => switch (this) {
        PpMessageKind.age => 'A new week or month',
        PpMessageKind.vaccine => 'Vaccines coming up',
        PpMessageKind.milestones => 'A new stage',
        PpMessageKind.activity => 'One thing to try each week',
      };

  String get when => switch (this) {
        PpMessageKind.age => 'Each week to 8 weeks, then each month',
        PpMessageKind.vaccine => '3 days before each visit',
        PpMessageKind.milestones => 'When a new stage starts',
        PpMessageKind.activity => 'Monday mornings',
      };
}

class PpMessage {
  const PpMessage({
    required this.id,
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
    this.read = false,
  });

  final String id;
  final PpMessageKind kind;
  final DateTime at;
  final String title;
  final String body;
  final bool read;

  bool deliveredBy(DateTime now) => !at.isAfter(now);

  PpMessage copyWith({DateTime? at, bool? read}) =>
      PpMessage(id: id, kind: kind, at: at ?? this.at, title: title, body: body, read: read ?? this.read);

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'at': at.toIso8601String(),
        'title': title,
        'body': body,
        'read': read,
      };

  static PpMessage? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final kind = PpMessageKind.values.where((k) => k.name == raw['kind']).firstOrNull;
    final at = DateTime.tryParse('${raw['at']}');
    final id = raw['id'];
    if (kind == null || at == null || id is! String) return null;
    return PpMessage(
        id: id, kind: kind, at: at, title: '${raw['title'] ?? ''}', body: '${raw['body'] ?? ''}', read: raw['read'] == true);
  }
}

/// A visit still to come, as the messages need it.
typedef PpVaxFact = ({String id, String label, DateTime date, List<String> shortNames});

/// What the messages are computed from. Plain values, so the rules are pure.
class PpMessageFacts {
  const PpMessageFacts({
    required this.dob,
    required this.name,
    required this.realChild,
    this.inParenting = true,
    this.partner = false,
    this.visits = const [],
  });

  final DateTime dob;

  /// As it reads mid-sentence: "Meera" or "your baby".
  final String name;
  final bool realChild;
  final bool inParenting;
  final bool partner;
  final List<PpVaxFact> visits;

  bool get speaks => realChild && inParenting && !partner;

  static PpMessageFacts fromStores() {
    final c = ChildProfileStore.instance;
    final vax = VaxStore.instance;
    return PpMessageFacts(
      dob: c.dob,
      name: c.nameMid,
      realChild: c.hasRealChild,
      inParenting: LifeStageStore.instance.stage == LifeStage.parenting,
      partner: FatherPreview.instance.on,
      visits: [
        for (final v in kVaxVisits)
          if (vax.statusOf(v) != VaxStatus.done && !vax.isOptionalVisit(v))
            (
              id: v.id,
              label: v.ageLabel,
              date: c.dob.add(Duration(days: v.ageDays)),
              shortNames: [for (final id in v.vaccineIds) vaccineById(id).shortName],
            ),
      ],
    );
  }
}

DateTime _at(DateTime d, int hour) => DateTime(d.year, d.month, d.day, hour);

/// [dob] plus [months] calendar months, the day clamped to the month's length
/// (a child born on 31 January is "1 month" on 28 or 29 February).
DateTime ppAddMonths(DateTime dob, int months) {
  final y = dob.year + (dob.month - 1 + months) ~/ 12;
  final m = (dob.month - 1 + months) % 12 + 1;
  final last = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, dob.day > last ? last : dob.day);
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Every message this child's dates call for, near now: the moments from a
/// little before today (so one just missed can still be delivered in the app)
/// to the next few of each kind.
List<PpMessage> ppMessageCandidates(PpMessageFacts f, DateTime now) {
  if (!f.speaks) return const [];
  final out = <PpMessage>[];
  final who = _cap(f.name);
  final today = DateTime(now.year, now.month, now.day);
  bool near(DateTime d) => !d.isBefore(today.subtract(const Duration(days: 3)));

  // ---- age: weekly to 8 weeks, monthly to 36, then every three to 72 --------
  var ageCount = 0;
  void age(String id, DateTime day, String title, String body) {
    if (!near(day) || ageCount >= kPpPhoneSlots + 1) return;
    ageCount++;
    out.add(PpMessage(id: id, kind: PpMessageKind.age, at: _at(day, 9), title: title, body: body));
  }

  for (var w = 1; w <= 8; w++) {
    age('age:w$w', f.dob.add(Duration(days: 7 * w)), '$who is $w ${w == 1 ? 'week' : 'weeks'} old today',
        'A small look at this week: what is new, and what helps.');
  }
  for (var m = 2; m <= 72; m++) {
    if (m > 36 && m % 3 != 0) continue;
    final y = m ~/ 12, r = m % 12;
    final label = m < 24
        ? '$m months'
        : r == 0
            ? '$y years'
            : '$y years $r months';
    final note = ppMonthNoteFor(m);
    age('age:m$m', ppAddMonths(f.dob, m), '$who is $label today',
        note == null ? 'Here is what is changing this month.' : 'This month: ${note.tryThis}');
  }

  // ---- vaccines: 3 days before each visit still to come --------------------
  final upcoming = f.visits.where((v) => !v.date.isBefore(today)).toList()..sort((a, b) => a.date.compareTo(b.date));
  for (final v in upcoming.take(kPpPhoneSlots)) {
    final day = v.date.subtract(const Duration(days: 3));
    out.add(PpMessage(
      id: 'vax:${v.id}',
      kind: PpMessageKind.vaccine,
      at: _at(day.isBefore(today) ? today : day, 10),
      title: 'The ${v.label} vaccines are coming up',
      body: '${v.shortNames.join(', ')} are due around ${v.date.day}/${v.date.month}. '
          'Book the visit, and follow your paediatrician on the exact timing.',
    ));
  }

  // ---- milestones: when a new phase starts ---------------------------------
  var phaseCount = 0;
  for (final p in kPhasesAuthored) {
    if (p.startMonth < 1) continue;
    final day = ppAddMonths(f.dob, p.startMonth.floor());
    if (!near(day) || phaseCount >= 2) continue;
    phaseCount++;
    out.add(PpMessage(
      id: 'phase:${p.number}',
      kind: PpMessageKind.milestones,
      at: _at(day, 18),
      // The phase doc's name where there is one (2026-10-13). Was ${p.name}.
      title: 'A new stage: ${ppPhaseWithDoc(p).name}',
      body: 'The skills that often start around now, and how to help, without a scoreboard.',
    ));
  }

  // ---- activity: Monday mornings --------------------------------------------
  final monday = today.add(Duration(days: (DateTime.monday - today.weekday) % 7));
  for (var i = 0; i < kPpPhoneSlots; i++) {
    final day = monday.add(Duration(days: 7 * i));
    final months = (day.difference(f.dob).inDays / 30.44).floor();
    final note = ppMonthNoteFor(months);
    final idx = phaseIndexForMonths(months.toDouble());
    // The phase doc's first activity, not the authored "Play" section: the
    // docs are the only phase text (2026-10-14). Kept for revert:
    // final play = kPhasesAuthored[idx].sections.where((s) => s.heading.toLowerCase().startsWith('play')).firstOrNull;
    // final line = note?.tryThis ?? play?.paragraphs.first;
    final docTry = ppPhaseDocFor(kPhasesAuthored[idx].number)?.activities.firstOrNull;
    final line = note?.tryThis ?? (docTry == null ? null : '${docTry.title}: ${docTry.intro}');
    if (line == null) continue;
    final week = '${day.year}-${day.month}-${day.day}';
    out.add(PpMessage(
      id: 'act:$week',
      kind: PpMessageKind.activity,
      at: _at(day, 10),
      title: 'Something to try this week',
      body: ppFillChild(line),
    ));
  }
  return out;
}

abstract class PpMessagePhone {
  Future<void> schedule({required int id, required String title, required String body, required DateTime when});
  Future<void> cancel(int id);
}

class _OsPhone implements PpMessagePhone {
  const _OsPhone();
  @override
  Future<void> schedule({required int id, required String title, required String body, required DateTime when}) =>
      NotificationService.instance.scheduleOneOff(id: id, title: title, body: body, when: when);
  @override
  Future<void> cancel(int id) => NotificationService.instance.cancel(id);
}

class PpMessagesStore extends ChangeNotifier with WidgetsBindingObserver {
  PpMessagesStore._();
  static final PpMessagesStore instance = PpMessagesStore._();

  static const _kMessages = 'pp_messages_v1';
  static const _kOff = 'pp_messages_off';
  static const _kOn = 'pp_messages_on';
  static const _kPhone = 'pp_messages_phone';
  static const int _keep = 120;

  final List<PpMessage> _all = [];

  /// Her own switches. A kind she turned on or off here wins over the topic
  /// list in the family profile.
  final Set<PpMessageKind> _off = {};
  final Set<PpMessageKind> _on = {};
  bool _phoneOn = true;
  bool _loaded = false;
  bool _listening = false;
  PpMessagePhone _phone = const _OsPhone();

  @visibleForTesting
  set phone(PpMessagePhone p) => _phone = p;

  /// Opens a tapped message. Set at startup by the app (the store must not
  /// import a screen); null in tests.
  static void Function(PpMessage? m)? phoneTapOpener;

  bool get isLoaded => _loaded;

  List<PpMessage> delivered({DateTime? now}) {
    final t = now ?? DateTime.now();
    return _all.where((m) => m.deliveredBy(t)).toList()..sort((a, b) => b.at.compareTo(a.at));
  }

  List<PpMessage> pending({DateTime? now}) {
    final t = now ?? DateTime.now();
    return _all.where((m) => !m.deliveredBy(t)).toList()..sort((a, b) => a.at.compareTo(b.at));
  }

  int get unreadCount => delivered().where((m) => !m.read).length;

  /// On: her own switch first; else the topics she chose; else the default.
  bool isOn(PpMessageKind k) {
    if (_off.contains(k)) return false;
    if (_on.contains(k)) return true;
    final topics = FamilyProfileStore.instance.notify;
    return topics.isEmpty ? k.onByDefault : topics.contains(k.topic);
  }

  bool get phoneOn => _phoneOn;

  Future<void> init() async {
    await _load();
    if (!_listening) {
      _listening = true;
      ChildProfileStore.instance.addListener(_changed);
      LifeStageStore.instance.addListener(_changed);
      FatherPreview.instance.addListener(_changed);
      VaxStore.instance.addListener(_changed);
      FamilyProfileStore.instance.addListener(_changed);
      try {
        WidgetsBinding.instance.addObserver(this);
      } catch (_) {/* no binding in a pure test */}
      NotificationService.instance.addTapListener(handlePhoneTap);
    }
    await refresh();
  }

  PpMessage? messageForPhoneId(int id, {DateTime? now}) {
    final kind = PpMessageKind.values.where((k) => k.phoneIds.contains(id)).firstOrNull;
    if (kind == null) return null;
    final arrived = delivered(now: now).where((m) => m.kind == kind);
    return arrived.isEmpty ? null : arrived.first;
  }

  bool handlePhoneTap(int id) {
    if (!PpMessageKind.values.any((k) => k.phoneIds.contains(id))) return false;
    final m = messageForPhoneId(id);
    if (m != null) markRead(m.id);
    phoneTapOpener?.call(m);
    return true;
  }

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

  Future<void> refresh({DateTime? now, PpMessageFacts? facts}) async {
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

  Future<void> _refresh(DateTime? fixedNow, PpMessageFacts? fixedFacts) async {
    if (!_loaded) await _load();
    if (fixedFacts == null && !LifeStageStore.instance.isLoaded) return;
    final facts = fixedFacts ?? PpMessageFacts.fromStores();
    final now = fixedNow ?? DateTime.now();
    final changed = apply(ppMessageCandidates(facts, now), now);
    for (final k in PpMessageKind.values) {
      for (final id in k.phoneIds) {
        await _phone.cancel(id);
      }
    }
    if (_phoneOn) {
      final slots = <PpMessageKind, int>{};
      for (final m in pending(now: now)) {
        final n = slots[m.kind] ?? 0;
        if (n >= kPpPhoneSlots) continue;
        slots[m.kind] = n + 1;
        await _phone.schedule(id: m.kind.notificationId + n, title: m.title, body: m.body, when: m.at);
      }
    }
    if (changed) {
      await _persist();
      notifyListeners();
    }
  }

  /// Folds [candidates] in: delivered stay frozen; a delivered id is never
  /// sent again; pending is replaced (so it follows a corrected date); a
  /// candidate already past is delivered now, in the app only, and only the
  /// newest past one of each kind (a first launch at 14 months does not fill
  /// the inbox with months she has lived through).
  @visibleForTesting
  bool apply(List<PpMessage> candidates, DateTime now) {
    final before = jsonEncode([for (final m in _all) m.toJson()]);
    final delivered = _all.where((m) => m.deliveredBy(now)).toList();
    final sent = delivered.map((m) => m.id).toSet();
    final late = <PpMessage>[];
    final next = <PpMessage>[...delivered];
    for (final c in candidates) {
      if (!isOn(c.kind) || sent.contains(c.id)) continue;
      c.deliveredBy(now) ? late.add(c) : next.add(c);
    }
    final newestLate = <PpMessageKind, PpMessage>{};
    for (final m in late) {
      final have = newestLate[m.kind];
      if (have == null || m.at.isAfter(have.at)) newestLate[m.kind] = m;
    }
    for (final m in newestLate.values) {
      next.add(m.copyWith(at: now));
    }
    next.sort((a, b) => b.at.compareTo(a.at));
    final keepDelivered = next.where((m) => m.deliveredBy(now)).take(_keep);
    final keepPending = next.where((m) => !m.deliveredBy(now));
    _all
      ..clear()
      ..addAll(keepPending)
      ..addAll(keepDelivered);
    return jsonEncode([for (final m in _all) m.toJson()]) != before;
  }

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

  Future<void> setOn(PpMessageKind kind, bool on) async {
    if (isOn(kind) == on) return;
    if (on) {
      _off.remove(kind);
      _on.add(kind);
    } else {
      _on.remove(kind);
      _off.add(kind);
      final now = DateTime.now();
      _all.removeWhere((m) => m.kind == kind && !m.deliveredBy(now));
    }
    await _persist();
    notifyListeners();
    await refresh();
  }

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

  @visibleForTesting
  void resetForTest() {
    _all.clear();
    _off.clear();
    _on.clear();
    _phoneOn = true;
    _loaded = true;
    notifyListeners();
  }

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
            ..addAll(list.map(PpMessage.fromJson).whereType<PpMessage>());
        }
      }
      PpMessageKind? kind(String n) => PpMessageKind.values.where((k) => k.name == n).firstOrNull;
      _off
        ..clear()
        ..addAll((p.getStringList(_kOff) ?? const <String>[]).map(kind).whereType<PpMessageKind>());
      _on
        ..clear()
        ..addAll((p.getStringList(_kOn) ?? const <String>[]).map(kind).whereType<PpMessageKind>());
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
      await p.setStringList(_kOn, [for (final k in _on) k.name]);
      await p.setBool(_kPhone, _phoneOn);
    } catch (_) {/* best-effort */}
  }
}

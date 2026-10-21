// =============================================================================
//  ttc_ready_habits_store.dart - her choices on "Your week" (2026-10-21)
// =============================================================================
//
// The habits themselves come from her answers (`readyHabitsFor` in
// ttc_ready_plan.dart). This keeps only what she changed on top of them: her
// own time for a habit, a reminder on or off, "make it smaller", and today's
// skip. Kept apart from `TtcReadyPlanStore` so the answers' sync contract
// (table `ttc_ready_plans`) does not change in this pass; these choices sync
// with the plan once its couple sync is built (STILL-OPEN §92).
//
// ⚠️ REMINDERS ARE OPT-IN AND SAID OUT LOUD. Nothing schedules until she
// turns a reminder on, and each switch announces what it did, with Undo, on
// the screen. Times are hers: the suggestion is a starting point (the user:
// "someone might only get time to go to the gym late at night").
//
// ⚠️ THE PLAN ENDS WHERE HER MONTH BEGINS (2026-10-21). The reminders repeat
// daily or weekly, so on their own they would carry on into trying and into
// pregnancy. [applyFor] stops them once, the day the plan is over: her month
// has come (or she tapped "We've started trying"), or she is not in TTC any
// more. Folic acid keeps going, because it matters just as much while she
// tries. After that one stop, a reminder she turns back on stays on.
//
// ⚠️ RE-ARMED AFTER EVERY LAUNCH. `ReminderStore.init` ends in
// `NotificationService.syncAll`, which cancels every pending notification;
// [rearmAfterStartup] runs after it in main.dart, like the TTC appointments.
//
// ⚠️ NO STREAKS. A skipped day is stored only so the row can say "Skipped
// today" until midnight. Nothing counts misses and nothing nags about them.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/life_stage_store.dart';
import 'ttc_ready_plan.dart';
import 'ttc_ready_plan_store.dart';

/// Whether her getting-ready plan is over on [now]: she is in another stage,
/// she is already trying, or her month has come.
bool readyPlanEnded(ReadyPlanAnswers? a, LifeStage? stage, DateTime now) {
  if (stage != null && stage != LifeStage.tryingToConceive) return true;
  if (a == null) return false;
  if (a.alreadyTrying) return true;
  final t = a.target;
  if (t == null) return false;
  return DateTime(t.year, t.month).compareTo(DateTime(now.year, now.month)) <=
      0;
}

class TtcReadyHabitsStore extends ChangeNotifier {
  TtcReadyHabitsStore._();
  static final TtcReadyHabitsStore instance = TtcReadyHabitsStore._();

  static const String _key = 'ttc_ready_habits_v1';

  final Map<String, int> _minutes = {};
  final Set<String> _remind = {};
  final Set<String> _smaller = {};
  final Map<String, String> _skipped = {}; // habit id -> day key
  bool _weekly = false;
  bool _loaded = false;
  String? _retiredFor; // the plan this store already stopped, once

  /// True once the plan's reminders were stopped for her month.
  bool get retired => _retiredFor != null;

  bool get weekly => _weekly;
  int minutesFor(ReadyHabit h) => _minutes[h.id] ?? h.minutes;
  bool reminds(ReadyHabit h) => _remind.contains(h.id);
  bool smaller(ReadyHabit h) => _smaller.contains(h.id);
  bool skippedToday(ReadyHabit h) => _skipped[h.id] == _today();

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      _minutes
        ..clear()
        ..addAll({
          for (final e in ((j['minutes'] as Map?) ?? const {}).entries)
            e.key as String: (e.value as num).toInt(),
        });
      _remind
        ..clear()
        ..addAll([for (final x in (j['remind'] as List?) ?? const []) '$x']);
      _smaller
        ..clear()
        ..addAll([for (final x in (j['smaller'] as List?) ?? const []) '$x']);
      _skipped
        ..clear()
        ..addAll({
          for (final e in ((j['skipped'] as Map?) ?? const {}).entries)
            e.key as String: '${e.value}',
        });
      _weekly = j['weekly'] == true;
      _retiredFor = j['retiredFor'] as String?;
      notifyListeners();
    } catch (_) {
      /* local-first: a bad cache is an empty one */
    }
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
        _key,
        jsonEncode({
          'minutes': _minutes,
          'remind': _remind.toList(),
          'smaller': _smaller.toList(),
          'skipped': _skipped,
          'weekly': _weekly,
          'retiredFor': _retiredFor,
        }),
      );
    } catch (_) {}
  }

  // ---- writes ---------------------------------------------------------------

  Future<void> setMinutes(ReadyHabit h, int minutes) async {
    _minutes[h.id] = minutes;
    notifyListeners();
    await _persist();
    if (reminds(h)) await _schedule(h);
  }

  Future<void> setRemind(ReadyHabit h, bool on) async {
    on ? _remind.add(h.id) : _remind.remove(h.id);
    notifyListeners();
    await _persist();
    if (on) {
      await NotificationService.instance.requestPermission();
      await _schedule(h);
    } else {
      await NotificationService.instance.cancelReminder(reminderFor(h));
    }
  }

  void toggleSmaller(ReadyHabit h) {
    _smaller.contains(h.id) ? _smaller.remove(h.id) : _smaller.add(h.id);
    notifyListeners();
    _persist();
  }

  void toggleSkip(ReadyHabit h) {
    skippedToday(h) ? _skipped.remove(h.id) : _skipped[h.id] = _today();
    notifyListeners();
    _persist();
  }

  Future<void> setWeekly(bool on) async {
    _weekly = on;
    notifyListeners();
    await _persist();
    if (on) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.schedule(weeklyReminder);
    } else {
      await NotificationService.instance.cancelReminder(weeklyReminder);
    }
  }

  /// Turns every plan reminder off: her plan was cleared, or her month came.
  Future<void> cancelAll(List<ReadyHabit> habits) async {
    for (final h in habits) {
      await NotificationService.instance.cancelReminder(reminderFor(h));
    }
    await NotificationService.instance.cancelReminder(weeklyReminder);
  }

  /// After launch, once `ReminderStore.init` has wiped the OS queue: stop
  /// the plan if it is over, then set again every reminder that is on. Keeps
  /// listening, so a stage switch or "We've started trying" stops it too.
  Future<void> rearmAfterStartup() async {
    await load();
    final plan = TtcReadyPlanStore.instance;
    await plan.load();
    if (!_listening) {
      _listening = true;
      plan.addListener(_changed);
      LifeStageStore.instance.addListener(_changed);
    }
    await applyFor(
      plan.answers,
      LifeStageStore.instance.stage,
      DateTime.now(),
      arm: true,
    );
  }

  bool _listening = false;
  void _changed() => applyFor(
    TtcReadyPlanStore.instance.answers,
    LifeStageStore.instance.stage,
    DateTime.now(),
  );

  /// Stops the plan once when it is over (folic acid stays), and with [arm]
  /// sets every reminder still on.
  Future<void> applyFor(
    ReadyPlanAnswers? a,
    LifeStage? stage,
    DateTime now, {
    bool arm = false,
  }) async {
    final habits = a == null ? const <ReadyHabit>[] : readyHabitsFor(a);
    if (readyPlanEnded(a, stage, now)) {
      final key = '${stage?.name}|${a?.alreadyTrying}|${a?.target}';
      if (_retiredFor != key) {
        _retiredFor = key;
        for (final h in habits) {
          if (h.id == 'folic' && stage == LifeStage.tryingToConceive) continue;
          if (_remind.remove(h.id)) {
            await NotificationService.instance.cancelReminder(reminderFor(h));
          }
        }
        if (_weekly) {
          _weekly = false;
          await NotificationService.instance.cancelReminder(weeklyReminder);
        }
        notifyListeners();
        await _persist();
      }
    } else if (_retiredFor != null) {
      _retiredFor = null; // a new month ahead: a new plan, stoppable again
      notifyListeners();
      await _persist();
    }
    if (!arm) return;
    for (final h in habits) {
      if (reminds(h)) await _schedule(h);
    }
    if (_weekly) await NotificationService.instance.schedule(weeklyReminder);
  }

  Future<void> _schedule(ReadyHabit h) =>
      NotificationService.instance.schedule(reminderFor(h));

  /// The reminder for [h], at her time. Ids are stable, so turning it off
  /// cancels exactly what was scheduled.
  Reminder reminderFor(ReadyHabit h) {
    final m = minutesFor(h);
    return Reminder(
      id: 'ttc_plan_${h.id}',
      title: h.title,
      body: smaller(h) ? h.minimum : 'From your Ready-to-Try plan.',
      hour: m ~/ 60,
      minute: m % 60,
      repeat: h.weekday == null ? ReminderRepeat.daily : ReminderRepeat.weekly,
      weekday: h.weekday ?? DateTime.monday,
      category: 'ttc_plan',
    );
  }

  /// Sunday evening: what is on this week (the user, 2026-10-21: "plan to be
  /// sent reminded each week").
  static const Reminder weeklyReminder = Reminder(
    id: 'ttc_plan_week',
    title: 'Your week ahead',
    body: 'Five small things this week. Open your Ready-to-Try plan.',
    hour: 19,
    minute: 0,
    repeat: ReminderRepeat.weekly,
    weekday: DateTime.sunday,
    category: 'ttc_plan',
  );

  @visibleForTesting
  void resetForTest() {
    _minutes.clear();
    _remind.clear();
    _smaller.clear();
    _skipped.clear();
    _weekly = false;
    _retiredFor = null;
    _loaded = true;
  }
}

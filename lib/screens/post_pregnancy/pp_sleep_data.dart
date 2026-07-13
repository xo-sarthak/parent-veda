// =============================================================================
//  ParentVeda Sleep Journey - data model, store & interpretive voice
// -----------------------------------------------------------------------------
//  The Sleep Tracker rebuilt from the Claude Design prompt as a "Sleep Journey":
//  it interprets rest in context (age, leaps, feeding) rather than chasing hours.
//  One in-memory ChangeNotifier singleton (SleepStore) holds the stretches and
//  derives the hero snapshot (total · night · day · current wake window), age
//  context ranges, gentle observations and smart correlations. No "good/poor"
//  judgement anywhere. Prototype-shaped: seeded, no persistence/backend. Uses the
//  child's age from ChildProfileStore; nothing here touches the pregnancy app.
// =============================================================================

import 'package:flutter/foundation.dart';

import 'pp_child_profile.dart';

/// The kind of sleep. Night vs Nap drive the hero split; the rest are optional
/// colour a parent can add but never has to.
enum SleepKind { night, nap, contact, car, stroller }

class SleepLog {
  SleepLog({
    required this.id,
    required this.start,
    required this.end,
    this.kind = SleepKind.nap,
    this.note,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final SleepKind kind;
  final String? note;

  int get minutes {
    final m = end.difference(start).inMinutes;
    return m < 0 ? 0 : m;
  }

  bool get isNight => kind == SleepKind.night;
}

/// A gentle, age-appropriate range - presented as ranges, never targets.
class SleepAgeContext {
  const SleepAgeContext(this.totalLabel, this.napsLabel, this.wakeLabel, this.blurb);
  final String totalLabel;
  final String napsLabel;
  final String wakeLabel;
  final String blurb;
}

class SleepStore extends ChangeNotifier {
  SleepStore._() {
    _seed();
  }
  static final SleepStore instance = SleepStore._();

  final List<SleepLog> _logs = [];
  int _seq = 0;
  String _id() => 'sleep_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  // ---- reads --------------------------------------------------------------
  List<SleepLog> get all {
    final list = [..._logs]..sort((a, b) => b.start.compareTo(a.start));
    return List.unmodifiable(list);
  }

  List<SleepLog> get todays => List.unmodifiable(all.where((s) => _isToday(s.start)));

  SleepLog? get last => all.isEmpty ? null : all.first;

  int get totalMinutesToday => todays.fold(0, (sum, s) => sum + s.minutes);
  int get nightMinutesToday => todays.where((s) => s.isNight).fold(0, (sum, s) => sum + s.minutes);
  int get dayMinutesToday => todays.where((s) => !s.isNight).fold(0, (sum, s) => sum + s.minutes);
  int get napCountToday => todays.where((s) => !s.isNight).length;

  /// Minutes since the last stretch ended (a gentle "awake for" read). Null if
  /// nothing logged.
  int? get currentWakeMinutes {
    if (last == null) return null;
    final m = DateTime.now().difference(last!.end).inMinutes;
    return m < 0 ? 0 : m;
  }

  String get name => ChildProfileStore.instance.name;

  // ---- interpretation (observational, never diagnostic) -------------------
  String get todaysInsight {
    final n = todays.length;
    if (n == 0) return 'A new day of rest to notice. Log a nap or last night whenever it suits.';
    final total = totalMinutesToday;
    final ctx = ageContext;
    if (napCountToday >= 4) {
      return 'Lots of short stretches today. Frequent naps are typical around this stage and smooth out with time.';
    }
    if (total > 0) {
      return "That's a settled picture so far — ${_hm(total)} of rest, spread across ${_plural(n, 'stretch', 'stretches')}. ${ctx.blurb}";
    }
    return ctx.blurb;
  }

  /// AI-style insight that reads sleep alongside age, leaps and recent changes.
  String get contextInsight {
    final m = ChildProfileStore.instance.ageInMonths;
    if (m >= 3 && m <= 5) {
      return 'Around $m months, many babies hit the "4-month" shift — sleep reorganises and waking can briefly increase. It settles as the new pattern beds in.';
    }
    if (m < 3) {
      return 'In these early months, day and night are still blending. Longer night stretches appear gradually — there is nothing to fix, only to notice.';
    }
    if (m >= 6 && m <= 9) {
      return 'Naps often consolidate around now, and a developmental leap or a new tooth can ripple through sleep for a few days before it steadies again.';
    }
    return 'Sleep naturally shifts with leaps, teeth and the odd off day. A single rough night rarely means a new pattern — the trend is what matters.';
  }

  /// Age-appropriate ranges for the "Age context" card.
  SleepAgeContext get ageContext {
    final m = ChildProfileStore.instance.ageInMonths;
    if (m < 1) {
      return const SleepAgeContext('14–17h', 'many short', '45–60 min',
          'Newborn sleep is scattered across the whole day — that is exactly as it should be.');
    }
    if (m < 4) {
      return const SleepAgeContext('14–16h', '4–5 naps', '60–90 min',
          'Day and night are still sorting themselves out — longer night stretches come with time.');
    }
    if (m < 7) {
      return const SleepAgeContext('12–15h', '3–4 naps', '1.5–2.5h',
          'Naps begin to find a shape, though days still vary widely and that is normal.');
    }
    if (m < 10) {
      return const SleepAgeContext('12–15h', '2–3 naps', '2–3h',
          'Many babies settle toward two naps around now, at their own pace.');
    }
    return const SleepAgeContext('12–15h', '2 naps', '3–4h',
        'Longer wake windows and two naps are common by the end of the first year.');
  }

  /// Plain-language pattern observations.
  List<String> get patterns {
    final out = <String>[];
    if (nightMinutesToday > 0) out.add('Night rest so far: ${_hm(nightMinutesToday)}. Night sleep tends to lengthen gently over the first year.');
    if (napCountToday > 0) out.add('${_plural(napCountToday, 'nap', 'naps')} today, ${_hm(dayMinutesToday)} of daytime rest.');
    out.add('Wake windows naturally stretch as $name grows — shorter ones now are not a problem to solve.');
    out.add('The trend across days tells you more than any single night.');
    return out;
  }

  /// The dimensions the Smart Correlations card invites parents to notice.
  List<(String, String)> get correlations => const [
        ('Sleep + Feeding', 'A cluster-feeding evening can mean a longer first stretch after.'),
        ('Sleep + Growth', 'Growth spurts sometimes bring extra waking for a few nights.'),
        ('Sleep + Leaps', 'Developmental leaps can unsettle sleep, then it re-steadies.'),
        ('Sleep + Vaccinations', 'A vaccine day can shorten naps briefly — usually back to normal within a day or two.'),
      ];

  // ---- writes -------------------------------------------------------------
  void add(SleepLog e) {
    _logs.add(e);
    notifyListeners();
  }

  void log({required DateTime start, required DateTime end, SleepKind kind = SleepKind.nap, String? note}) {
    add(SleepLog(id: _id(), start: start, end: end, kind: kind, note: note));
  }

  void remove(String id) {
    _logs.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ---- helpers ------------------------------------------------------------
  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  static String _hm(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static String _plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';

  void _seed() {
    final now = DateTime.now();
    _logs.addAll([
      SleepLog(id: _id(), start: now.subtract(const Duration(hours: 3, minutes: 20)), end: now.subtract(const Duration(hours: 1, minutes: 45)), kind: SleepKind.nap, note: 'Settled quickly'),
      SleepLog(id: _id(), start: now.subtract(const Duration(hours: 7)), end: now.subtract(const Duration(hours: 5, minutes: 30)), kind: SleepKind.nap),
      SleepLog(id: _id(), start: now.subtract(const Duration(hours: 15)), end: now.subtract(const Duration(hours: 9)), kind: SleepKind.night, note: 'Woke once, back down easily'),
    ]);
  }
}

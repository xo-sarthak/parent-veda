// =============================================================================
//  PregnancyController
// -----------------------------------------------------------------------------
//  Single source of truth for the Week-on-Week Card Stack:
//    * loads + parses the weekly content from the JSON asset
//    * derives the CURRENT gestational week from a (placeholder) due date
//    * decides which weeks are unlocked (now or past) vs locked (future)
//    * holds the English / Hinglish language toggle
//
//  It is a plain ChangeNotifier so the UI can listen without any extra
//  state-management package.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../localization/app_language.dart';
import '../models/week_content.dart';

class PregnancyController extends ChangeNotifier {
  PregnancyController({DateTime? dueDate, DateTime? now})
      : _now = now ?? DateTime.now(),
        _dueDate = dueDate ?? _placeholderDueDate(now ?? DateTime.now());

  static const String _assetPath = 'lib/data/weekContent.json';

  /// Persisted real due date once the mother uses the Due Date Calculator.
  static const String _dueDateKey = 'pregnancy_due_date';

  /// Content runs from week 4 to week 40.
  static const int firstContentWeek = 4;
  static const int lastContentWeek = 40;

  /// A full term is measured as 40 weeks from the due date.
  static const int _termWeeks = 40;

  // --- mutable state ---------------------------------------------------------
  final DateTime _now;
  DateTime _dueDate;

  /// True once the mother has a REAL due date (set via the Due Date Calculator
  /// and/or restored from prefs). While false we're showing the week-20
  /// placeholder, so the calculator opens on its input form rather than a saved
  /// roadmap.
  bool _dueDateIsSet = false;

  AppLanguage _language = AppLanguage.english;

  List<WeekContent> _weeks = const [];
  bool _isLoading = true;
  Object? _error;

  // Real profile names loaded from Supabase (fall back to placeholders).
  String? _myName; // the logged-in user's own name
  String? _myRole; // 'mother' | 'father'
  String? _partnerName; // the paired partner's name (if paired)

  /// When true, every week is viewable (used so the full journey — including
  /// the week-40 celebration — can be reached and reviewed).
  bool unlockAllWeeks = true;

  /// Week currently being viewed in the stack (defaults to the current week).
  int? _selectedWeek;

  // --- public getters --------------------------------------------------------
  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool get hasError => _error != null;

  AppLanguage get language => _language;
  DateTime get dueDate => _dueDate;

  /// Whether the mother has set her real due date (vs the week-20 placeholder).
  bool get isDueDateSet => _dueDateIsSet;

  /// The mother's name — the logged-in user's own name in mother mode, or the
  /// paired mother's name in father mode. Falls back to a placeholder.
  String get motherName =>
      (_myRole == 'mother' ? _myName : _partnerName) ?? 'Priya';

  /// The father's name — the logged-in user's own name in father mode, or the
  /// paired father's name in mother mode. Falls back to a placeholder.
  String get fatherName =>
      (_myRole == 'father' ? _myName : _partnerName) ?? 'Dad';

  List<WeekContent> get weeks => List.unmodifiable(_weeks);

  /// The mother's current gestational week, clamped to available content.
  int get currentWeek {
    final raw = _termWeeks - (_dueDate.difference(_dateOnly(_now)).inDays / 7).floor();
    return raw.clamp(firstContentWeek, lastContentWeek);
  }

  /// Total length of a full-term pregnancy in days (40 weeks).
  static const int termDays = _termWeeks * 7; // 280

  /// The mother's current day of pregnancy (1–280), derived from the due date.
  int get currentDay {
    final raw = termDays - daysToDueDate;
    return raw.clamp(1, termDays);
  }

  /// The week the user is presently viewing in the stack.
  int get selectedWeek => _selectedWeek ?? currentWeek;

  // --- journey-map progress helpers -----------------------------------------
  //  Derived purely from [currentDay] / [termDays] so the Journey map and the
  //  Home screen always agree on "how far along".

  /// Days of pregnancy completed so far (1–280). Alias for [currentDay].
  int get daysCompleted => currentDay;

  /// Days of pregnancy still remaining (0–279).
  int get daysRemaining => (termDays - currentDay).clamp(0, termDays);

  /// Day within the current gestational week (1–7), e.g. "Day 3".
  int get dayOfWeek => ((currentDay - 1) % 7) + 1;

  /// Overall journey progress as a fraction (0.0–1.0).
  double get progress => (currentDay / termDays).clamp(0.0, 1.0);

  /// Overall journey progress as a whole percentage (0–100).
  int get progressPercent => (progress * 100).round();

  /// All week numbers we have content for, ascending.
  List<int> get availableWeeks => _weeks.map((w) => w.week).toList();

  /// With [unlockAllWeeks] on, nothing is locked. Otherwise future weeks lock.
  bool isLocked(int week) => unlockAllWeeks ? false : week > currentWeek;

  /// Convenience: the data for the currently-selected week (null while loading
  /// or if the week is missing from the dataset).
  WeekContent? get selectedWeekData => weekData(selectedWeek);

  WeekContent? weekData(int week) {
    for (final w in _weeks) {
      if (w.week == week) return w;
    }
    return null;
  }

  /// Calendar date range (start..end) for a given pregnancy week, derived from
  /// the due date (week 40 sits at the due date).
  ({DateTime start, DateTime end}) weekDates(int week) {
    final start = _dateOnly(_dueDate)
        .subtract(Duration(days: (lastContentWeek - week) * 7));
    return (start: start, end: start.add(const Duration(days: 6)));
  }

  /// Calendar date for a pregnancy [day] (1–280, where day 280 = the due date),
  /// derived from the due date. Mirrors [weekDates] (for day = week*7 this
  /// equals `weekDates(week).start`). Used by the Journey map's milestone dates.
  DateTime dateForDay(int day) =>
      _dateOnly(_dueDate).subtract(Duration(days: termDays - day));

  /// Days remaining until the due date (never negative).
  int get daysToDueDate {
    final d = _dueDate.difference(_dateOnly(_now)).inDays;
    return d < 0 ? 0 : d;
  }

  /// Days the mother is PAST her due date (0 if not overdue). Lets the journey
  /// map cater to overdue pregnancies ("baby comes when ready") without changing
  /// the trail — currentWeek/currentDay still clamp at 40 / 280.
  int get daysPastDue {
    final d = _dateOnly(_now).difference(_dateOnly(_dueDate)).inDays;
    return d > 0 ? d : 0;
  }

  bool get isOverdue => daysPastDue > 0;

  // --- actions ---------------------------------------------------------------

  /// Load + parse the bundled content. Safe to call once at startup.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('weekContent.json must be a JSON array');
      }
      final parsed = <WeekContent>[];
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          parsed.add(WeekContent.fromJson(entry));
        } else if (entry is Map) {
          parsed.add(WeekContent.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
      parsed.sort((a, b) => a.week.compareTo(b.week));
      _weeks = parsed;
      // PINNED TO WEEK 20 (testing): ignore any saved/auth due date so the app
      // ALWAYS opens on the week-20 flow, whether or not you log in. _dueDate
      // stays at the week-20 placeholder. RE-ENABLE this block (and the auth
      // setDueDate calls in splash_screen.dart / profile_screen.dart) to restore
      // the mother's real saved due date.
      // try {
      //   final prefs = await SharedPreferences.getInstance();
      //   final saved = prefs.getString(_dueDateKey);
      //   final d = saved == null ? null : DateTime.tryParse(saved);
      //   if (d != null) {
      //     _dueDate = _dateOnly(d);
      //     _dueDateIsSet = true;
      //   }
      // } catch (_) {/* keep the placeholder */}
      _selectedWeek ??= currentWeek;
      // Load the real profile name(s) from Supabase (if signed in).
      await loadProfileFromCloud();
    } catch (e) {
      _error = e;
      _weeks = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the logged-in user's profile name + role (and the paired partner's
  /// name, readable via the pairing RLS) so the UI shows real names instead of
  /// the placeholders. No-op if signed out; keeps placeholders on any error.
  Future<void> loadProfileFromCloud() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;
      final me = await client
          .from('profiles')
          .select('name, role, partner_id')
          .eq('id', uid)
          .maybeSingle();
      if (me == null) return;
      final myName = (me['name'] as String?)?.trim();
      _myName = (myName != null && myName.isNotEmpty) ? myName : null;
      _myRole = me['role'] as String?;
      final partnerId = me['partner_id'] as String?;
      if (partnerId != null) {
        final partner = await client
            .from('profiles')
            .select('name')
            .eq('id', partnerId)
            .maybeSingle();
        final pn = (partner?['name'] as String?)?.trim();
        _partnerName = (pn != null && pn.isNotEmpty) ? pn : null;
      }
      notifyListeners();
    } catch (_) {/* keep placeholders */}
  }

  void toggleLanguage() {
    _language =
        _language.isEnglish ? AppLanguage.hinglish : AppLanguage.english;
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }

  /// Move the viewer to [week] (clamped to the available content range).
  void selectWeek(int week) {
    final clamped = week.clamp(firstContentWeek, lastContentWeek);
    if (_selectedWeek == clamped) return;
    _selectedWeek = clamped;
    notifyListeners();
  }

  /// Test / preview hook: pretend the due date is something else so we can
  /// demo locked + unlocked weeks on an emulator.
  void overrideDueDate(DateTime dueDate) {
    _dueDate = dueDate;
    _selectedWeek = currentWeek;
    notifyListeners();
  }

  /// Persisted due date set from the Due Date Calculator — drives the whole app
  /// (current week/day everywhere). Survives restarts.
  Future<void> setDueDate(DateTime dueDate) async {
    _dueDate = _dateOnly(dueDate);
    _dueDateIsSet = true;
    _selectedWeek = currentWeek;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dueDateKey, _dueDate.toIso8601String());
    } catch (_) {/* best-effort */}
  }

  /// Testing helper — clear any saved due date and snap back to the week-20
  /// placeholder, so the app + pregnancy map present a fresh "halfway" state.
  Future<void> resetForTesting() async {
    _dueDate = _placeholderDueDate(_now);
    _dueDateIsSet = false;
    _selectedWeek = currentWeek;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dueDateKey);
    } catch (_) {/* best-effort */}
  }

  // --- helpers ---------------------------------------------------------------

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Placeholder due date so the demo opens mid-journey (~week 20 — "halfway
  /// there"), giving a healthy mix of unlocked past weeks and locked future
  /// weeks while matching the Home Screen daily-moment prototype.
  static DateTime _placeholderDueDate(DateTime now) {
    const demoCurrentWeek = 20;
    final weeksRemaining = _termWeeks - demoCurrentWeek; // 16 weeks out
    return _dateOnly(now).add(Duration(days: weeksRemaining * 7));
  }
}

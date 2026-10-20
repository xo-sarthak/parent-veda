// =============================================================================
//  CalendarStore - personal events + the assembled "My Calendar" event list
// -----------------------------------------------------------------------------
//  PERSONAL events (baby shower, family function, custom reminders…) are added
//  by the mother and persisted. [allEvents] then merges them with SYSTEM events
//  derived from existing data so nothing is logged twice:
//    * milestones / medical / ParentVeda unlocks  ← kJourneyMilestones
//    * journal + health events                    ← JournalStore + ToolsStore
//  Each event gets a status (completed / current / upcoming).
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/journey_milestones.dart';
import '../data/prepare_data.dart';
import '../localization/app_language.dart';
import '../models/calendar_event.dart';
import '../models/journey_node.dart';
import 'journal_store.dart';
import 'prepare_store.dart';
import 'pregnancy_controller.dart';
import 'remote/own_row_ledger.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_row_book.dart';
import 'remote/sync_registry.dart';
import 'scans_store.dart';
import 'tools_store.dart';

class CalendarStore extends ChangeNotifier {
  CalendarStore._();
  static final CalendarStore instance = CalendarStore._();

  static const _key = 'calendar_personal_events';

  final List<CalendarEvent> _personal = [];
  bool _loaded = false;

  /// Newer-wins sync for her notes (2026-10-20, sync log step 8, 0106).
  final OwnRowLedger _sync =
      OwnRowLedger('calendar_personal_events', 'calendar_personal_events_sync');

  /// Notes the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => _sync.hasPending;

  Map<String, Map<String, dynamic>> _live() =>
      {for (final e in _personal) e.id: e.toJson()};

  Future<void> _pushWaiting() => _sync.push(_live);

  Future<void> init() async {
    if (_loaded) return;
    // 1) Local cache first.
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _personal.add(
              CalendarEvent.personalFromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    await _sync.load();
    SyncRegistry.registerPending(() => hasPending);
    _loaded = true;
    notifyListeners();

    // 2) Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  // Same recipe as symptom_store - but no translator needed here, since the
  // field names already match the column names. We reuse the model's toJson /
  // personalFromJson directly.
  /// A sign-out, or another account signing in (2026-10-17): this store
  /// forgets the person in memory; the cloud keeps it.
  void _resetLocal() {
    _personal.clear();
    _sync
      ..clear()
      ..save();
    notifyListeners();
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      // Newer wins per note, removals included (step 8, 0106).
      final taken = await _sync.pull(
          liveKeys: _personal.map((e) => e.id), orderBy: 'date');
      final byId = {for (final e in _personal) e.id: e};
      for (final r in taken) {
        final id = r['id'] as String;
        if (syncParseStamp(r['removed_at']) != null) {
          byId.remove(id);
        } else {
          byId[id] = CalendarEvent.personalFromJson(r);
        }
      }
      _personal
        ..clear()
        ..addAll(byId.values);
      await _persist();
      notifyListeners();
      await _pushWaiting();
    } catch (_) {/* offline - keep local */}
  }

  // Kept for revert (step 8, 2026-10-20): the cloud won per id and any note
  // only this phone held was inserted again, so a deleted note came back.
  // ignore: unused_element
  Future<void> _syncFromCloudOld() async {
    try {
      final rows = await SupabaseRepo.fetch('calendar_personal_events',
          orderBy: 'date');
      final byId = {
        for (final r in rows) r['id'].toString(): CalendarEvent.personalFromJson(r)
      };
      for (final e in _personal) {
        if (!byId.containsKey(e.id)) {
          byId[e.id] = e; // keep local-only...
          await SupabaseRepo.insert('calendar_personal_events', e.toJson()); // ...and push up
        }
      }
      _personal
        ..clear()
        ..addAll(byId.values);
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> addPersonal(
      {required String title, String description = '', required DateTime date}) async {
    final ev = CalendarEvent(
      id: 'pe_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: description,
      category: CalEventCategory.personal,
      date: date,
      isSystemGenerated: false,
    );
    _personal.add(ev);
    _sync.touch(ev.id);
    notifyListeners();
    await _persist();
    // Kept for revert (step 8): a one-shot insert, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.insert('calendar_personal_events', ev.toJson());
    //   } catch (_) {/* offline - syncs up on next init */}
    // }
    await _pushWaiting();
  }

  /// Change one of her notes in place (the calendar's Edit, 2026-10-17). Same
  /// id, so the cloud write is an update of the row it already has.
  Future<void> updatePersonal(String id,
      {required String title, String description = '', required DateTime date}) async {
    final i = _personal.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final ev = CalendarEvent(
      id: id,
      title: title,
      description: description,
      category: CalEventCategory.personal,
      date: date,
      isSystemGenerated: false,
    );
    _personal[i] = ev;
    _sync.touch(id);
    notifyListeners();
    await _persist();
    // Kept for revert (step 8): a one-shot update, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     final row = ev.toJson()..remove('id');
    //     await SupabaseRepo.update('calendar_personal_events', id, row);
    //   } catch (_) {/* offline - best-effort */}
    // }
    await _pushWaiting();
  }

  /// Her notes, as stored (the hub assembles its own day items from these).
  List<CalendarEvent> get personal => List.unmodifiable(_personal);

  /// A soft delete (step 8, 0106): the removal travels to her other phones
  /// and an older copy can't bring the note back.
  Future<void> deletePersonal(String id) async {
    final i = _personal.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final gone = _personal.removeAt(i);
    _sync.remove(id, gone.toJson());
    notifyListeners();
    await _persist();
    // Kept for revert (step 8): a one-shot hard delete, lost offline.
    // if (SupabaseRepo.isLoggedIn) {
    //   try {
    //     await SupabaseRepo.delete('calendar_personal_events', id);
    //   } catch (_) {/* offline - best-effort */}
    // }
    await _pushWaiting();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_personal.map((e) => e.toJson()).toList()));
    } catch (_) {/* best-effort */}
  }

  // ---- assembly --------------------------------------------------------------

  CalEventStatus _weekStatus(int week, int currentWeek) {
    if (week < currentWeek) return CalEventStatus.completed;
    if (week == currentWeek) return CalEventStatus.current;
    return CalEventStatus.upcoming;
  }

  CalEventStatus _dateStatus(DateTime d, DateTime today) {
    final day = DateTime(d.year, d.month, d.day);
    if (day.isBefore(today)) return CalEventStatus.completed;
    if (day.isAtSameMomentAs(today)) return CalEventStatus.current;
    return CalEventStatus.upcoming;
  }

  List<CalendarEvent> allEvents(PregnancyController p) {
    final lang = p.language;
    final s = S(lang);
    final currentWeek = p.currentWeek;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <CalendarEvent>[];

    // --- System milestones / medical / ParentVeda (from the shared library) ---
    for (final m in kJourneyMilestones) {
      final CalEventCategory? cat = switch (m.type) {
        JourneyNodeType.achievement => CalEventCategory.milestone,
        JourneyNodeType.medical => CalEventCategory.medical,
        JourneyNodeType.feature => CalEventCategory.parentveda,
        JourneyNodeType.pvJourney => CalEventCategory.parentveda,
        _ => null, // babyDev, mother, week - live in the Journal, not here
      };
      if (cat == null) continue;
      final date = p.dueDate.subtract(
          Duration(days: (PregnancyController.termDays - m.posDay).round()));
      var desc = '';
      for (final sec in m.sections) {
        final b = sec.body.of(lang).trim();
        if (b.isNotEmpty) {
          desc = b;
          break;
        }
      }
      out.add(CalendarEvent(
        id: 'cm_${m.id}',
        title: '${m.emoji} ${m.title.of(lang)}',
        description: desc,
        category: cat,
        date: date,
        weekNumber: m.anchorWeek,
        status: _weekStatus(m.anchorWeek, currentWeek),
        weekRef: m.ctaWeek,
      ));
    }

    // --- Journal events (the mother's memories / notes / photos) --------------
    for (final e in JournalStore.instance.manualEntries) {
      out.add(CalendarEvent(
        id: 'cj_${e.id}',
        title: e.title,
        description: e.description,
        category: CalEventCategory.journal,
        date: e.date,
        weekNumber: e.weekNumber,
        status: _dateStatus(e.date, today),
        isSystemGenerated: false,
        opensJournal: true,
      ));
    }

    // --- Health logs (weight + kicks) as journal events ----------------------
    final t = ToolsStore.instance;
    for (final w in t.weightEntries) {
      final d = DateTime.tryParse(w.timeIso) ??
          DateTime.tryParse(w.dateIso) ??
          p.dueDate;
      out.add(CalendarEvent(
        id: 'cw_${w.id}',
        title: s.jrWeightLogged,
        description: '${w.weight.toStringAsFixed(1)} ${s.kgUnit}',
        category: CalEventCategory.journal,
        date: d,
        weekNumber: w.week,
        status: _dateStatus(d, today),
        opensJournal: true,
      ));
    }
    for (final ms in t.movementSessionHistory) {
      out.add(CalendarEvent(
        id: 'ck_${ms.id}',
        title: s.jrKickSession,
        description: s.jrMovementsCount(ms.times.length),
        category: CalEventCategory.journal,
        date: ms.start,
        status: _dateStatus(ms.start, today),
        opensJournal: true,
      ));
    }

    // --- Personal events (mother-added) --------------------------------------
    for (final e in _personal) {
      out.add(CalendarEvent(
        id: e.id,
        title: e.title,
        description: e.description,
        category: CalEventCategory.personal,
        date: e.date,
        status: _dateStatus(e.date, today),
        isSystemGenerated: false,
      ));
    }

    // --- Programs (ENROLLED Prepare programs) → "Program" lane ---------------
    //  Enrolled cohorts, 1:1 consultations (incl. nutrition) and the birthing
    //  course, sourced from PrepareStore's booked ids and cross-referenced with
    //  the Prepare catalogs (kCohorts / kSpecialists).
    //
    //  TODO(programs): PrepareStore persists only the enrolled *id*, not a real
    //    schedule DateTime - so each program event is anchored to `today` (the
    //    enrolment is active "now") and its human schedule label rides in the
    //    description. When the commerce/backend stores a real start/session date
    //    per booking, use that here instead of `today`. Prenatal Yoga has no
    //    enrolment hook yet, so it contributes nothing until one exists.
    final prep = PrepareStore.instance;
    for (final c in kCohorts) {
      if (!prep.isBooked(c.id)) continue;
      final desc = (c.start != null && c.start!.en.trim().isNotEmpty)
          ? '${c.duration.now} · ${c.start!.now}'
          : c.duration.now;
      out.add(CalendarEvent(
        id: 'cp_${c.id}',
        title: c.name.now,
        description: desc,
        category: CalEventCategory.program,
        date: today,
        status: CalEventStatus.current,
        isSystemGenerated: false,
      ));
    }
    for (final sp in kSpecialists) {
      if (!prep.isBooked(sp.id)) continue;
      out.add(CalendarEvent(
        id: 'cp_${sp.id}',
        title: '${sp.role} · ${sp.name}',
        description: '30-min video consultation',
        category: CalEventCategory.program,
        date: today,
        status: CalEventStatus.current,
        isSystemGenerated: false,
      ));
    }
    // The birthing course is a single-id enrolment (see BirthingClassesScreen).
    if (prep.isBooked('course_birthing')) {
      out.add(CalendarEvent(
        id: 'cp_course_birthing',
        title: S.now.uiCompleteBirthingCourse,
        description: '6 classes · self-paced + monthly live Q&A',
        category: CalEventCategory.program,
        date: today,
        status: CalEventStatus.current,
        isSystemGenerated: false,
      ));
    }

    // --- Appointments (from Scans & Appointments) → "Appointment" lane -------
    for (final appt in ScansStore.instance.appointments) {
      final sub = [appt.time, appt.location, appt.doctor]
          .where((x) => x.trim().isNotEmpty)
          .join(' · ');
      out.add(CalendarEvent(
        id: 'ca_${appt.id}',
        title: appt.title,
        description: sub,
        category: CalEventCategory.appointment,
        date: appt.date,
        status: _dateStatus(appt.date, today),
        isSystemGenerated: false,
      ));
    }

    out.sort((a, b) => a.date.compareTo(b.date)); // ascending: past → future
    return out;
  }
}

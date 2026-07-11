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
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';
import 'scans_store.dart';
import 'tools_store.dart';

class CalendarStore extends ChangeNotifier {
  CalendarStore._();
  static final CalendarStore instance = CalendarStore._();

  static const _key = 'calendar_personal_events';

  final List<CalendarEvent> _personal = [];
  bool _loaded = false;

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
    _loaded = true;
    notifyListeners();

    // 2) Then sync with the cloud (no-op if logged out).
    await _syncFromCloud();
  }

  // Same recipe as symptom_store - but no translator needed here, since the
  // field names already match the column names. We reuse the model's toJson /
  // personalFromJson directly.
  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    if (!SupabaseRepo.isLoggedIn) return;
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
    notifyListeners();
    await _persist();
    // Push to the cloud (best-effort).
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.insert('calendar_personal_events', ev.toJson());
      } catch (_) {/* offline - syncs up on next init */}
    }
  }

  Future<void> deletePersonal(String id) async {
    _personal.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
    // Delete from the cloud too (NEW vs symptom).
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.delete('calendar_personal_events', id);
      } catch (_) {/* offline - best-effort */}
    }
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
      final desc = (c.start != null && c.start!.trim().isNotEmpty)
          ? '${c.duration} · ${c.start}'
          : c.duration;
      out.add(CalendarEvent(
        id: 'cp_${c.id}',
        title: c.name,
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
        title: 'Complete Birthing Course',
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

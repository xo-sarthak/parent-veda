// =============================================================================
//  ParentVeda Health - content model, seed data + store
// -----------------------------------------------------------------------------
//  A living health COMPANION (not an EMR, not a document store): the child's
//  health as a calm, understandable story. Backs the Health Snapshot, the Health
//  Timeline (the backbone), Growth, a Vaccination SUMMARY (the tracker itself is
//  a separate existing module), Medical History, AI-style insights, the Doctor
//  Visit Companion and the Emergency Card. Seeded for Aarav (born 8 Mar 2026,
//  ~4 months). Static prototype - a real Health Intelligence engine slots in
//  later. Nothing here depends on the pregnancy app.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';
import 'pp_attachments.dart';
import 'pp_child_profile.dart';
// Cyclic with pp_vaccine_data (which imports this file) - fine in Dart, and it
// keeps the timeline honest: doses she marked are part of her health story.
import 'pp_vaccine_data.dart';

enum HealthEventType { doctorVisit, vaccination, illness, medication, growthCheck, labTest, allergy, note, emergency, assessment }

/// One event on the health timeline. `sortKey` orders newest-first (higher =
/// more recent); `upcoming` marks a future/expected event.
class HealthEvent {
  const HealthEvent({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.summary,
    required this.sortKey,
    this.doctor,
    this.notes,
    this.attachments = 0,
    this.upcoming = false,
  });
  final String id;
  final HealthEventType type;
  final String date; // display, e.g. "12 Jun 2026"
  final String title;
  final String summary;
  final int sortKey;
  final String? doctor;
  final String? notes;
  final int attachments;
  final bool upcoming;
}

class GrowthPoint {
  const GrowthPoint(this.ageLabel, this.weightKg, this.heightCm, this.headCm, this.weightPct);
  final String ageLabel;
  final double weightKg;
  final double heightCm;
  final double headCm;
  final int weightPct;
}

/// ---------------------------------------------------------------------------
///  SEED vs REAL: the empty-id rule
/// ---------------------------------------------------------------------------
///  The health models below ship as demo content (Aarav's medications,
///  allergies, reports). Those seed rows leave [id] EMPTY; anything a parent
///  actually enters gets a real client-generated id.
///
///  That one bit does two jobs: it gives sync the stable id it needs to merge
///  rows, AND it keeps our fiction out of real accounts — only rows with a real
///  id are ever written to Supabase. Without it, every account would inherit a
///  fictional four-month-old's medical history. See BACKEND-PARENTING-BRIEF §5.
/// ---------------------------------------------------------------------------
class Medication {
  const Medication({
    this.id = '',
    required this.name,
    required this.reason,
    required this.doctor,
    required this.dosage,
    required this.duration,
    required this.completed,
    required this.date,
    this.frequency = '',
    this.reminderOn = false,
    this.reminderHour,
    this.reminderMinute,
    this.reminderId,
  });
  /// Empty for seeded demo rows; a real id once a parent enters one.
  final String id;
  final String name;
  final String reason;
  final String doctor;
  final String dosage;
  final String duration;
  final bool completed;
  final String date;

  // ---- richer scheduling (mirrors the pregnancy-side medicine feature) ----
  /// How often, in plain words (e.g. "Twice daily", "Every morning").
  final String frequency;

  /// A gentle local reminder to give the medicine. When on, [reminderHour] /
  /// [reminderMinute] hold the time and [reminderId] is the OS notification id
  /// used to (re)schedule and cancel it.
  final bool reminderOn;
  final int? reminderHour;
  final int? reminderMinute;
  final int? reminderId;

  /// A copy carrying [newId] — how a parent-entered row graduates from the
  /// empty seed id to a real, syncable one.
  Medication withId(String newId) => Medication(
        id: newId,
        name: name,
        reason: reason,
        doctor: doctor,
        dosage: dosage,
        duration: duration,
        completed: completed,
        date: date,
        frequency: frequency,
        reminderOn: reminderOn,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
        reminderId: reminderId,
      );
}

enum AllergyStatus { known, suspected, resolved }

class Allergy {
  const Allergy(this.name, this.status, this.severity, this.note, {this.id = ''});
  /// Empty for seeded demo rows (see the empty-id rule above).
  final String id;
  final String name;
  final AllergyStatus status;
  final String severity;
  final String note;

  Allergy withId(String newId) => Allergy(name, status, severity, note, id: newId);
}

class ReportValue {
  const ReportValue(this.label, this.value, this.flag); // flag: 'normal'|'high'|'low'
  final String label;
  final String value;
  final String flag;
}

class MedicalReport {
  const MedicalReport({this.id = '', required this.name, required this.date, required this.summary, this.doctor, this.values = const [], this.attachments = const []});
  /// Empty for seeded demo rows (see the empty-id rule above).
  final String id;
  final String name;
  final String date;
  final String summary;
  final String? doctor;
  final List<ReportValue> values;
  final List<Attachment> attachments; // scanned images / PDFs of the report

  MedicalReport withId(String newId) => MedicalReport(
        id: newId,
        name: name,
        date: date,
        summary: summary,
        doctor: doctor,
        values: values,
        attachments: attachments,
      );
}

/// A prescription the child was given - the paper (or photo/PDF) plus the who,
/// when and any notes. Simpler than a Medication: it's the record of the script,
/// not a schedule to track.
class Prescription {
  const Prescription({
    required this.id,
    required this.name,
    required this.doctor,
    required this.date,
    this.notes = '',
    this.attachments = const [],
  });
  final String id;
  final String name;
  final String doctor;
  final String date;
  final String notes;
  final List<Attachment> attachments;

  Prescription withId(String newId) => Prescription(
        id: newId,
        name: name,
        doctor: doctor,
        date: date,
        notes: notes,
        attachments: attachments,
      );
}

class SymptomEntry {
  const SymptomEntry(this.name, this.date, this.note, {this.id = ''});
  /// Empty for seeded demo rows (see the empty-id rule above).
  final String id;
  final String name;
  final String date;
  final String note;

  SymptomEntry withId(String newId) => SymptomEntry(name, date, note, id: newId);
}

typedef EmergencyContact = ({String name, String relation, String phone});

class EmergencyProfile {
  const EmergencyProfile({required this.name, required this.dob, required this.weight, required this.bloodGroup, required this.allergies, required this.pediatrician, required this.contacts, required this.medications});
  final String name;
  final String dob;
  final String weight;
  final String bloodGroup;
  final String allergies;
  final String pediatrician;
  final List<EmergencyContact> contacts;
  final String medications;
}

// ---- snapshot ---------------------------------------------------------------
class HealthStat {
  const HealthStat(this.label, this.value, this.status); // status: 'good'|'watch'|'neutral'
  final String label;
  final String value;
  final String status;
}

const List<HealthStat> kHealthSnapshot = [
  HealthStat('Overall', 'Healthy', 'good'),
  HealthStat('Growth', 'On track', 'good'),
  HealthStat('Vaccinations', 'Up to date', 'good'),
  HealthStat('Allergies', 'None recorded', 'neutral'),
];

const String kUpcomingHealth = 'PCV dose 3 · due 22 Jul (in ~2 weeks)';
const String kLastVisit = '12 Jun 2026 · 4-month check, all well';

// ---- vaccination summary (the tracker itself is a separate module) ----------
const String kVaxStatus = 'Up to date';
const String kVaxNext = 'PCV dose 3 · 22 Jul';
const int kVaxCompleted = 7;
const int kVaxTotalDue = 8;

// ---- timeline ---------------------------------------------------------------
const List<HealthEvent> kHealthTimeline = [
  HealthEvent(id: 'e_up', type: HealthEventType.vaccination, date: '22 Jul 2026', title: 'PCV dose 3 due', summary: 'Third pneumococcal dose - free at a govt centre.', sortKey: 200, upcoming: true),
  HealthEvent(id: 'e1', type: HealthEventType.doctorVisit, date: '12 Jun 2026', title: '4-month well-baby check', summary: 'Weight 6.4 kg (50th), length 63 cm. Development on track. Solids discussed for ~6 months.', doctor: 'Dr. Neha Sharma', notes: 'Reassured about the 4-month sleep regression.', attachments: 1, sortKey: 150),
  HealthEvent(id: 'e2', type: HealthEventType.vaccination, date: '14 Jun 2026', title: '14-week vaccines', summary: 'DTP-3, IPV-3, Hep-B, Hib, Rota, PCV-2 given. Mild fever after, settled in a day.', doctor: 'Dr. Neha Sharma', sortKey: 148),
  HealthEvent(id: 'e3', type: HealthEventType.illness, date: '2 Jun 2026', title: 'Mild cold', summary: 'Runny nose and light congestion for 3 days. No fever. Managed with saline drops.', sortKey: 120),
  HealthEvent(id: 'e4', type: HealthEventType.growthCheck, date: '17 May 2026', title: 'Growth check (10 weeks)', summary: 'Weight 5.4 kg, length 58 cm - following his own curve nicely.', doctor: 'Dr. Neha Sharma', sortKey: 100),
  HealthEvent(id: 'e5', type: HealthEventType.vaccination, date: '17 May 2026', title: '10-week vaccines', summary: 'DTP-2, IPV-2, Hib, Rota, PCV-1 given. Well tolerated.', sortKey: 98),
  HealthEvent(id: 'e6', type: HealthEventType.vaccination, date: '19 Apr 2026', title: '6-week vaccines', summary: 'First set - DTP-1, IPV-1, Hep-B, Hib, Rota, PCV. Slight fussiness after.', sortKey: 60),
  HealthEvent(id: 'e7', type: HealthEventType.labTest, date: '10 Mar 2026', title: 'Newborn screening', summary: 'Routine heel-prick metabolic screen - all results normal.', attachments: 1, sortKey: 20),
  HealthEvent(id: 'e8', type: HealthEventType.assessment, date: '8 Mar 2026', title: 'Born - healthy', summary: '3.2 kg, 49 cm. APGAR 9/10. Birth vaccines (BCG, OPV-0, Hep-B) given.', doctor: 'Dr. Kavita Menon', sortKey: 0),
];

// ---- growth -----------------------------------------------------------------
const List<GrowthPoint> kGrowth = [
  GrowthPoint('Birth', 3.2, 49, 35, 49),
  GrowthPoint('6 wk', 4.3, 54, 38, 51),
  GrowthPoint('10 wk', 5.4, 58, 40, 50),
  GrowthPoint('4 mo', 6.4, 63, 41, 50),
];
const String kGrowthInterpretation = '{child} is growing steadily and following his own healthy curve - weight, length and head size are all tracking together, which is exactly what we like to see.';

// ---- medical history --------------------------------------------------------
const List<Medication> kMedications = [
  Medication(name: 'Saline nasal drops', reason: 'Mild cold / congestion', doctor: 'Dr. Neha Sharma', dosage: '2 drops each nostril, as needed', duration: '3 days', completed: true, date: 'Jun 2026'),
  Medication(name: 'Paracetamol (Crocin)', reason: 'Fever after 14-week vaccines', doctor: 'Dr. Neha Sharma', dosage: 'Weight-based, only if needed', duration: '1 day', completed: true, date: 'Jun 2026'),
  Medication(name: 'Vitamin D drops', reason: 'Routine supplementation', doctor: 'Dr. Neha Sharma', dosage: '400 IU daily', duration: 'Ongoing', completed: false, date: 'Since Mar 2026'),
];

const List<Allergy> kAllergies = [
  // Empty of "known" on purpose - shows the reassuring empty state.
];

const List<SymptomEntry> kSymptoms = [
  SymptomEntry('Cold', '2 Jun 2026', 'Runny nose, 3 days, no fever.'),
  SymptomEntry('Low-grade fever', '14 Jun 2026', 'After vaccines, settled in a day.'),
];

const List<MedicalReport> kReports = [
  MedicalReport(name: 'Newborn metabolic screen', date: '10 Mar 2026', doctor: 'Dr. Kavita Menon', summary: 'All screened conditions normal - nothing to follow up.', values: [
    ReportValue('TSH (thyroid)', 'Normal', 'normal'),
    ReportValue('G6PD', 'Normal', 'normal'),
    ReportValue('Hearing (OAE)', 'Pass', 'normal'),
  ]),
  MedicalReport(name: '4-month growth summary', date: '12 Jun 2026', doctor: 'Dr. Neha Sharma', summary: 'Weight and length both around the 50th centile, tracking steadily.', values: [
    ReportValue('Weight', '6.4 kg (50th)', 'normal'),
    ReportValue('Length', '63 cm (48th)', 'normal'),
    ReportValue('Head circumference', '41 cm (52nd)', 'normal'),
  ]),
];

const List<Prescription> kPrescriptions = [
  Prescription(
    id: 'rx_seed',
    name: 'Post-vaccine care',
    doctor: 'Dr. Neha Sharma',
    date: '14 Jun 2026',
    notes: 'Paracetamol (weight-based) only if fever crosses 38°C. Extra feeds, light clothing, plenty of rest.',
  ),
];

// ---- AI-style insights (reassuring patterns, never diagnosis) ---------------
const List<String> kHealthInsights = [
  '{child} has grown steadily along his own curve for four months - weight, length and head size all tracking together.',
  'All vaccinations are up to date. The next, PCV dose 3, is due around 22 July.',
  'No allergies have been recorded so far.',
  'His only illnesses have been a mild seasonal cold and brief post-vaccine fever - both common and self-limiting.',
];

// ---- emergency profile ------------------------------------------------------
const EmergencyProfile kEmergency = EmergencyProfile(
  name: '{child}',
  dob: '8 March 2026',
  weight: '6.4 kg',
  bloodGroup: 'B+ (from records)',
  allergies: 'None recorded',
  pediatrician: 'Dr. Neha Sharma · +91 98•• ••• •••',
  medications: 'Vitamin D drops (routine)',
  contacts: [
    (name: 'Priya (Mother)', relation: 'Parent', phone: '+91 98•• ••• •••'),
    (name: 'Rohan (Father)', relation: 'Parent', phone: '+91 99•• ••• •••'),
  ],
);

// ---- doctor-visit companion -------------------------------------------------
const List<String> kSeedDoctorQuestions = [
  'Is his weight gain on track for his age?',
  'When exactly should we start solids, and with what?',
  'Anything to watch for after the next vaccines?',
];

// ---- lookups ----------------------------------------------------------------
IconData healthEventIcon(HealthEventType t) {
  switch (t) {
    case HealthEventType.doctorVisit:
      return Icons.medical_services_outlined;
    case HealthEventType.vaccination:
      return Icons.vaccines_outlined;
    case HealthEventType.illness:
      return Icons.sick_outlined;
    case HealthEventType.medication:
      return Icons.medication_outlined;
    case HealthEventType.growthCheck:
      return Icons.straighten_outlined;
    case HealthEventType.labTest:
      return Icons.science_outlined;
    case HealthEventType.allergy:
      return Icons.warning_amber_rounded;
    case HealthEventType.note:
      return Icons.sticky_note_2_outlined;
    case HealthEventType.emergency:
      return Icons.emergency_outlined;
    case HealthEventType.assessment:
      return Icons.favorite_border;
  }
}

String healthEventLabel(HealthEventType t) {
  switch (t) {
    case HealthEventType.doctorVisit:
      return 'Doctor visit';
    case HealthEventType.vaccination:
      return 'Vaccination';
    case HealthEventType.illness:
      return 'Illness';
    case HealthEventType.medication:
      return 'Medication';
    case HealthEventType.growthCheck:
      return 'Growth check';
    case HealthEventType.labTest:
      return 'Lab test';
    case HealthEventType.allergy:
      return 'Allergy';
    case HealthEventType.note:
      return 'Note';
    case HealthEventType.emergency:
      return 'Emergency';
    case HealthEventType.assessment:
      return 'Assessment';
  }
}

/// The child's health timeline — HER events, newest first.
///
/// This used to return `kHealthTimeline`: eleven invented events (a 4-month
/// well-baby check, a 14-week vaccination, a mild cold) presented as this
/// child's history. A timeline is a claim about what happened to one specific
/// baby, so it can only be built from what the parent recorded.
///
/// Built from her doctor visits plus the vaccine doses she has marked given.
/// The vaccine SCHEDULE stays bundled content (it is the same for everyone);
/// only "she marked this one done" is her data.
List<HealthEvent> healthTimelineSorted() {
  final events = <HealthEvent>[...HealthStore.instance.visits];

  final vax = VaxStore.instance;
  for (final v in kVaxVisits) {
    if (vax.statusOf(v) != VaxStatus.done) continue;
    events.add(HealthEvent(
      id: 'vax_${v.id}',
      type: HealthEventType.vaccination,
      date: v.date,
      title: v.vaccines.map((x) => x.shortName).join(', '),
      summary: v.ageLabel,
      sortKey: v.ageDays,
    ));
  }

  // Symptoms she logged read as illness entries.
  for (final s in HealthStore.instance.symptoms) {
    events.add(HealthEvent(
      id: 'sym_${s.id}',
      type: HealthEventType.illness,
      date: s.date,
      title: s.name,
      summary: s.note,
      sortKey: 0,
    ));
  }

  events.sort((a, b) => b.sortKey.compareTo(a.sortKey));
  return events;
}

// =============================================================================
//  HealthStore - mutable health record (seeded from the constants above). Holds
//  the parent's doctor-visit questions plus full CRUD over medications,
//  allergies, symptoms and reports. A ChangeNotifier singleton like the app's
//  other stores; a real backend slots in behind these same methods later.
// =============================================================================
class HealthStore extends ChangeNotifier {
  HealthStore._();
  static final HealthStore instance = HealthStore._();

  // EMPTY, not seeded. These used to start as copies of kMedications /
  // kPrescriptions / kAllergies / kSymptoms / kReports, which meant every
  // parent opened the app already "having" a fictional child's medications and
  // allergies - and, once this store syncs, would have had them written into
  // her account as real medical records. The seed constants are kept in this
  // file (demo/reference, per the keep-don't-delete rule) but are no longer
  // loaded. A parent who has entered nothing now correctly sees the
  // invitation state. See BACKEND-PARENTING-BRIEF §5.
  final List<String> _questions = [];
  final List<Medication> _medications = [];
  final List<Prescription> _prescriptions = [];
  final List<Allergy> _allergies = [];
  final List<SymptomEntry> _symptoms = [];
  final List<MedicalReport> _reports = [];
  // Parent-added doctor visits. The seeded visits still come from the health
  // timeline (read-only); these are ones the parent records themselves.
  final List<HealthEvent> _visits = [];

  bool _loaded = false;

  // The child this record belongs to. Health is child-scoped and co-parented:
  // rows key to a child_id, and BOTH paired parents read and write them.
  String? get _childId => ChildProfileStore.instance.activeChildId;

  static String _newId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  // === persistence ==========================================================
  //  LOCAL-FIRST: prefs is the instant, offline-capable source; Supabase syncs
  //  on top. A cloud failure is never a crash - every call below is wrapped and
  //  degrades to local-only, silently (BACKEND-PARENTING-BRIEF §2).

  static const _prefsKey = 'pp_health';

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) _applyLocal(Map<String, dynamic>.from(jsonDecode(raw)));
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();

    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  void _applyLocal(Map<String, dynamic> j) {
    void fill<T>(String key, List<T> into, T Function(Map<String, dynamic>) make) {
      final list = j[key];
      if (list is! List) return;
      into
        ..clear()
        ..addAll(list.map((e) => make(Map<String, dynamic>.from(e))));
    }

    final qs = j['questions'];
    if (qs is List) {
      _questions
        ..clear()
        ..addAll(qs.map((e) => e.toString()));
    }
    fill('medications', _medications, _medFrom);
    fill('prescriptions', _prescriptions, _presFrom);
    fill('allergies', _allergies, _allergyFrom);
    fill('symptoms', _symptoms, _symptomFrom);
    fill('reports', _reports, _reportFrom);
    fill('visits', _visits, _visitFrom);
    _growthEntered = j['growthEntered'] == true;
    _vaxEntered = j['vaxEntered'] == true;
    _emergencyFrom(j['emergency']);
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({
          'questions': _questions,
          'medications': _medications.map(_medRow).toList(),
          'prescriptions': _prescriptions.map(_presRow).toList(),
          'allergies': _allergies.map(_allergyRow).toList(),
          'symptoms': _symptoms.map(_symptomRow).toList(),
          'reports': _reports.map(_reportRow).toList(),
          'visits': _visits.map(_visitRow).toList(),
          'growthEntered': _growthEntered,
          'vaxEntered': _vaxEntered,
          'emergency': _emergencyJson(),
        }),
      );
    } catch (_) {}
  }

  /// Merge each table cloud-side, exactly as the pregnancy stores do: fetch the
  /// child's rows, push up anything only we have, adopt the union.
  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    final childId = _childId;
    // No child yet (still on the seeded placeholder) → nothing to key rows to.
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      await _mergeTable('pp_medications', childId, _medications, _medRow, _medFrom, (m) => m.id);
      await _mergeTable('pp_prescriptions', childId, _prescriptions, _presRow, _presFrom, (p) => p.id);
      await _mergeTable('pp_allergies', childId, _allergies, _allergyRow, _allergyFrom, (a) => a.id);
      await _mergeTable('pp_symptoms', childId, _symptoms, _symptomRow, _symptomFrom, (s) => s.id);
      await _mergeTable('pp_reports', childId, _reports, _reportRow, _reportFrom, (r) => r.id);
      await _mergeTable('pp_doctor_visits', childId, _visits, _visitRow, _visitFrom, (v) => v.id);
      await _mergeQuestions(childId);
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> _mergeTable<T>(
    String table,
    String childId,
    List<T> local,
    Map<String, dynamic> Function(T) toRow,
    T Function(Map<String, dynamic>) fromRow,
    String Function(T) idOf,
  ) async {
    final rows = await SupabaseRepo.fetchByChild(table, childId);
    final byId = {for (final r in rows) r['id'].toString(): fromRow(r)};
    for (final item in local) {
      final id = idOf(item);
      // Empty id = seeded demo content. Never upload our fiction.
      if (id.isEmpty || byId.containsKey(id)) continue;
      byId[id] = item;
      await SupabaseRepo.insert(table, {...toRow(item), 'child_id': childId});
    }
    local
      ..clear()
      ..addAll(byId.values);
  }

  // Questions are plain strings in the app but need a stable row id in the
  // cloud, so they're matched on their text.
  Future<void> _mergeQuestions(String childId) async {
    final rows = await SupabaseRepo.fetchByChild('pp_doctor_questions', childId);
    final cloud = {for (final r in rows) (r['question'] ?? '').toString()};
    for (final q in _questions) {
      if (q.isEmpty || cloud.contains(q)) continue;
      cloud.add(q);
      await SupabaseRepo.insert('pp_doctor_questions', {
        'id': _newId('q'),
        'child_id': childId,
        'question': q,
      });
    }
    _questions
      ..clear()
      ..addAll(cloud);
  }

  /// Push one row for a co-parented table (insert or update as needed).
  Future<void> _push(String table, String id, Map<String, dynamic> row) async {
    final childId = _childId;
    if (id.isEmpty || childId == null || !SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.upsert(table, {...row, 'child_id': childId},
          onConflict: 'id');
    } catch (_) {/* offline - reconciled on the next sync */}
  }

  Future<void> _remove(String table, String id) async {
    if (id.isEmpty || !SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.deleteShared(table, id);
    } catch (_) {}
  }

  /// Saves locally, then pushes - the shape every mutation below shares.
  Future<void> _after(Future<void> Function() cloud) async {
    await _persist();
    await cloud();
  }

  // ---- camelCase model <-> snake_case columns ------------------------------
  // Private to the store, mirroring MedicineStore on the pregnancy side.
  // `user_id` is never written here: SupabaseRepo.insert attaches it, and it
  // records WHO typed the row, not who may touch it.

  static List<Map<String, dynamic>> _attachRows(List<Attachment> a) => a
      .map((x) => {'kind': x.kind.name, 'path': x.path, 'name': x.name})
      .toList();

  static List<Attachment> _attachFrom(Object? v) {
    if (v is! List) return const [];
    return v.map((e) {
      final m = Map<String, dynamic>.from(e);
      return Attachment(
        AttachKind.values.firstWhere(
          (k) => k.name == m['kind'],
          orElse: () => AttachKind.image,
        ),
        (m['path'] ?? '').toString(),
        (m['name'] ?? '').toString(),
      );
    }).toList();
  }

  static Map<String, dynamic> _medRow(Medication m) => {
        'id': m.id,
        'name': m.name,
        'reason': m.reason,
        'doctor': m.doctor,
        'dosage': m.dosage,
        'duration': m.duration,
        'frequency': m.frequency,
        'completed': m.completed,
        'date': m.date,
        'reminder_on': m.reminderOn,
        'reminder_hour': m.reminderHour,
        'reminder_minute': m.reminderMinute,
        'reminder_id': m.reminderId,
      };

  static Medication _medFrom(Map<String, dynamic> r) => Medication(
        id: (r['id'] ?? '').toString(),
        name: (r['name'] ?? '').toString(),
        reason: (r['reason'] ?? '').toString(),
        doctor: (r['doctor'] ?? '').toString(),
        dosage: (r['dosage'] ?? '').toString(),
        duration: (r['duration'] ?? '').toString(),
        frequency: (r['frequency'] ?? '').toString(),
        completed: r['completed'] == true,
        date: (r['date'] ?? '').toString(),
        reminderOn: r['reminder_on'] == true,
        reminderHour: (r['reminder_hour'] as num?)?.toInt(),
        reminderMinute: (r['reminder_minute'] as num?)?.toInt(),
        reminderId: (r['reminder_id'] as num?)?.toInt(),
      );

  static Map<String, dynamic> _presRow(Prescription p) => {
        'id': p.id,
        'name': p.name,
        'doctor': p.doctor,
        'date': p.date,
        'notes': p.notes,
        'attachments': _attachRows(p.attachments),
      };

  static Prescription _presFrom(Map<String, dynamic> r) => Prescription(
        id: (r['id'] ?? '').toString(),
        name: (r['name'] ?? '').toString(),
        doctor: (r['doctor'] ?? '').toString(),
        date: (r['date'] ?? '').toString(),
        notes: (r['notes'] ?? '').toString(),
        attachments: _attachFrom(r['attachments']),
      );

  static Map<String, dynamic> _allergyRow(Allergy a) => {
        'id': a.id,
        'name': a.name,
        'status': a.status.name,
        'severity': a.severity,
        'note': a.note,
      };

  static Allergy _allergyFrom(Map<String, dynamic> r) => Allergy(
        (r['name'] ?? '').toString(),
        AllergyStatus.values.firstWhere(
          (s) => s.name == r['status'],
          orElse: () => AllergyStatus.known,
        ),
        (r['severity'] ?? '').toString(),
        (r['note'] ?? '').toString(),
        id: (r['id'] ?? '').toString(),
      );

  static Map<String, dynamic> _symptomRow(SymptomEntry s) => {
        'id': s.id,
        'name': s.name,
        'date': s.date,
        'note': s.note,
      };

  static SymptomEntry _symptomFrom(Map<String, dynamic> r) => SymptomEntry(
        (r['name'] ?? '').toString(),
        (r['date'] ?? '').toString(),
        (r['note'] ?? '').toString(),
        id: (r['id'] ?? '').toString(),
      );

  static Map<String, dynamic> _reportRow(MedicalReport r) => {
        'id': r.id,
        'name': r.name,
        'date': r.date,
        'summary': r.summary,
        'doctor': r.doctor,
        'report_values': r.values
            .map((v) => {'label': v.label, 'value': v.value, 'flag': v.flag})
            .toList(),
        'attachments': _attachRows(r.attachments),
      };

  static MedicalReport _reportFrom(Map<String, dynamic> r) {
    final vals = r['report_values'];
    return MedicalReport(
      id: (r['id'] ?? '').toString(),
      name: (r['name'] ?? '').toString(),
      date: (r['date'] ?? '').toString(),
      summary: (r['summary'] ?? '').toString(),
      doctor: r['doctor']?.toString(),
      values: vals is List
          ? vals.map((e) {
              final m = Map<String, dynamic>.from(e);
              return ReportValue((m['label'] ?? '').toString(),
                  (m['value'] ?? '').toString(), (m['flag'] ?? '').toString());
            }).toList()
          : const [],
      attachments: _attachFrom(r['attachments']),
    );
  }

  static Map<String, dynamic> _visitRow(HealthEvent v) => {
        'id': v.id,
        'type': v.type.name,
        'date': v.date,
        'title': v.title,
        'summary': v.summary,
        'sort_key': v.sortKey,
        'doctor': v.doctor,
        'notes': v.notes,
        'attachments': v.attachments,
        'upcoming': v.upcoming,
      };

  static HealthEvent _visitFrom(Map<String, dynamic> r) => HealthEvent(
        id: (r['id'] ?? '').toString(),
        type: HealthEventType.values.firstWhere(
          (t) => t.name == r['type'],
          orElse: () => HealthEventType.doctorVisit,
        ),
        date: (r['date'] ?? '').toString(),
        title: (r['title'] ?? '').toString(),
        summary: (r['summary'] ?? '').toString(),
        sortKey: (r['sort_key'] as num?)?.toInt() ?? 0,
        doctor: r['doctor']?.toString(),
        notes: r['notes']?.toString(),
        attachments: (r['attachments'] as num?)?.toInt() ?? 0,
        upcoming: r['upcoming'] == true,
      );

  // ---- entered-vs-seeded ----------------------------------------------------
  //  The snapshot, growth and vaccination figures above are SEED data - they are
  //  the same constants for everyone, so today the app cannot tell a parent who
  //  has logged nothing from one who has logged everything. That is how "Overall:
  //  good" ends up shown to someone who has never entered a thing.
  //
  //  These flags are the front end of the fix. They are false until the parent
  //  actually enters something, so every health section can render its
  //  not-yet-entered state now. When the backend lands, the only change needed
  //  is for these to be derived from real rows instead of local writes - no
  //  screen has to change. See docs/PERSONALIZATION.md section 3 for why the
  //  empty state is an invitation and never a hidden section.
  bool _growthEntered = false;
  bool _vaxEntered = false;

  bool get growthEntered => _growthEntered;
  bool get vaxEntered => _vaxEntered;

  /// True once she has told us ANYTHING - the cue for the snapshot to be
  /// meaningful rather than a restatement of our own seed data.
  ///
  /// This used to be true at launch for EVERY parent: `_reports` was seeded
  /// from kReports (non-empty), so the flag meant to detect "has she entered
  /// anything" always said yes. The collections now start empty, so it finally
  /// answers the question it was written for.
  bool get hasAnyEntry =>
      _growthEntered ||
      _vaxEntered ||
      _visits.isNotEmpty ||
      _reports.isNotEmpty ||
      _medications.isNotEmpty ||
      _prescriptions.isNotEmpty ||
      _allergies.isNotEmpty ||
      _symptoms.isNotEmpty;

  void markGrowthEntered() {
    if (_growthEntered) return;
    _growthEntered = true;
    notifyListeners();
    _persist();
  }

  /// Test-only: the store is a singleton, so a test that flips a flag has to
  /// put it back or it leaks into whatever runs next.
  @visibleForTesting
  void resetEnteredForTest() {
    _growthEntered = false;
    _vaxEntered = false;
    notifyListeners();
  }

  void markVaxEntered() {
    if (_vaxEntered) return;
    _vaxEntered = true;
    notifyListeners();
    _persist();
  }

  // Every mutation below keeps its ORIGINAL signature (still void, still
  // index-based) so no screen changes - it just saves now. Adds assign a real
  // id, which is what separates a parent's row from our seed content.

  // ---- doctor-visit questions ----
  List<String> get questions => List.unmodifiable(_questions);
  void addQuestion(String q) {
    final t = q.trim();
    if (t.isEmpty) return;
    _questions.add(t);
    notifyListeners();
    _after(() async {
      final childId = _childId;
      if (childId == null || !SupabaseRepo.isLoggedIn) return;
      try {
        await SupabaseRepo.insert('pp_doctor_questions',
            {'id': _newId('q'), 'child_id': childId, 'question': t});
      } catch (_) {}
    });
  }

  void removeQuestion(int i) {
    if (i < 0 || i >= _questions.length) return;
    final q = _questions.removeAt(i);
    notifyListeners();
    _after(() async {
      final childId = _childId;
      if (childId == null || !SupabaseRepo.isLoggedIn) return;
      try {
        // Questions have no client-side id, so they're matched on text.
        final rows =
            await SupabaseRepo.fetchByChild('pp_doctor_questions', childId);
        for (final r in rows) {
          if ((r['question'] ?? '').toString() == q) {
            await SupabaseRepo.deleteShared(
                'pp_doctor_questions', r['id'].toString());
          }
        }
      } catch (_) {}
    });
  }

  // ---- medications (also covers prescriptions) ----
  List<Medication> get medications => List.unmodifiable(_medications);
  void addMedication(Medication m) {
    final row = m.id.isEmpty ? m.withId(_newId('med')) : m;
    _medications.insert(0, row);
    notifyListeners();
    _after(() => _push('pp_medications', row.id, _medRow(row)));
  }

  void updateMedication(int i, Medication m) {
    if (i < 0 || i >= _medications.length) return;
    final row = m.id.isEmpty ? m.withId(_medications[i].id) : m;
    _medications[i] = row;
    notifyListeners();
    _after(() => _push('pp_medications', row.id, _medRow(row)));
  }

  void removeMedication(int i) {
    if (i < 0 || i >= _medications.length) return;
    final row = _medications.removeAt(i);
    notifyListeners();
    _after(() => _remove('pp_medications', row.id));
  }

  // ---- prescriptions (the script itself; may carry image/PDF attachments) ----
  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);
  void addPrescription(Prescription p) {
    final row = p.id.isEmpty ? p.withId(_newId('pres')) : p;
    _prescriptions.insert(0, row);
    notifyListeners();
    _after(() => _push('pp_prescriptions', row.id, _presRow(row)));
  }

  void updatePrescription(int i, Prescription p) {
    if (i < 0 || i >= _prescriptions.length) return;
    final row = p.id.isEmpty ? p.withId(_prescriptions[i].id) : p;
    _prescriptions[i] = row;
    notifyListeners();
    _after(() => _push('pp_prescriptions', row.id, _presRow(row)));
  }

  void removePrescription(int i) {
    if (i < 0 || i >= _prescriptions.length) return;
    final row = _prescriptions.removeAt(i);
    notifyListeners();
    _after(() => _remove('pp_prescriptions', row.id));
  }

  // ---- allergies ----
  List<Allergy> get allergies => List.unmodifiable(_allergies);
  List<Allergy> get knownAllergies => _allergies.where((a) => a.status == AllergyStatus.known).toList();
  void addAllergy(Allergy a) {
    final row = a.id.isEmpty ? a.withId(_newId('alg')) : a;
    _allergies.insert(0, row);
    notifyListeners();
    _after(() => _push('pp_allergies', row.id, _allergyRow(row)));
  }

  void updateAllergy(int i, Allergy a) {
    if (i < 0 || i >= _allergies.length) return;
    final row = a.id.isEmpty ? a.withId(_allergies[i].id) : a;
    _allergies[i] = row;
    notifyListeners();
    _after(() => _push('pp_allergies', row.id, _allergyRow(row)));
  }

  void removeAllergy(int i) {
    if (i < 0 || i >= _allergies.length) return;
    final row = _allergies.removeAt(i);
    notifyListeners();
    _after(() => _remove('pp_allergies', row.id));
  }

  // ---- symptoms ----
  List<SymptomEntry> get symptoms => List.unmodifiable(_symptoms);
  void addSymptom(SymptomEntry s) {
    final row = s.id.isEmpty ? s.withId(_newId('sym')) : s;
    _symptoms.insert(0, row);
    notifyListeners();
    _after(() => _push('pp_symptoms', row.id, _symptomRow(row)));
  }

  void updateSymptom(int i, SymptomEntry s) {
    if (i < 0 || i >= _symptoms.length) return;
    final row = s.id.isEmpty ? s.withId(_symptoms[i].id) : s;
    _symptoms[i] = row;
    notifyListeners();
    _after(() => _push('pp_symptoms', row.id, _symptomRow(row)));
  }

  void removeSymptom(int i) {
    if (i < 0 || i >= _symptoms.length) return;
    final row = _symptoms.removeAt(i);
    notifyListeners();
    _after(() => _remove('pp_symptoms', row.id));
  }

  // ---- reports (manual records; may carry image/PDF attachments) ----
  List<MedicalReport> get reports => List.unmodifiable(_reports);
  void addReport(MedicalReport r) {
    final row = r.id.isEmpty ? r.withId(_newId('rep')) : r;
    _reports.insert(0, row);
    notifyListeners();
    _after(() => _push('pp_reports', row.id, _reportRow(row)));
  }

  void updateReport(int i, MedicalReport r) {
    if (i < 0 || i >= _reports.length) return;
    final row = r.id.isEmpty ? r.withId(_reports[i].id) : r;
    _reports[i] = row;
    notifyListeners();
    _after(() => _push('pp_reports', row.id, _reportRow(row)));
  }

  void removeReport(int i) {
    if (i < 0 || i >= _reports.length) return;
    final row = _reports.removeAt(i);
    notifyListeners();
    _after(() => _remove('pp_reports', row.id));
  }

  // ---- doctor visits (parent-added; the seeded ones stay in the timeline) ----
  List<HealthEvent> get visits => List.unmodifiable(_visits);
  void addVisit(HealthEvent v) {
    _visits.insert(0, v);
    notifyListeners();
    _after(() => _push('pp_doctor_visits', v.id, _visitRow(v)));
  }

  void updateVisit(int i, HealthEvent v) {
    if (i < 0 || i >= _visits.length) return;
    _visits[i] = v;
    notifyListeners();
    _after(() => _push('pp_doctor_visits', v.id, _visitRow(v)));
  }

  void removeVisit(int i) {
    if (i < 0 || i >= _visits.length) return;
    final row = _visits.removeAt(i);
    notifyListeners();
    _after(() => _remove('pp_doctor_visits', row.id));
  }

  // ---- emergency card (create / edit / delete) ----
  // NULL, not kEmergency. The seeded card carried a blood group ("B+"), a
  // paediatrician's name and phone, and two parents' phone numbers - none of
  // them real. This is the screen a parent opens in an emergency, or hands to
  // someone else to act on, so a plausible-looking wrong blood group here is
  // the most dangerous fabricated data in the app. The screen already has a
  // "No emergency card yet" state that invites her to create it.
  EmergencyProfile? _emergency;
  EmergencyProfile? get emergency => _emergency;
  void setEmergency(EmergencyProfile e) {
    _emergency = e;
    notifyListeners();
    _persist();
  }

  void clearEmergency() {
    _emergency = null;
    notifyListeners();
    _persist();
  }

  // The card is child-scoped in spirit, but it is a single small record rather
  // than a collection, so it rides along in the local blob. (A table for it can
  // follow if it ever needs to be queried.)
  Map<String, dynamic>? _emergencyJson() {
    final e = _emergency;
    if (e == null) return null;
    return {
      'name': e.name,
      'dob': e.dob,
      'weight': e.weight,
      'bloodGroup': e.bloodGroup,
      'allergies': e.allergies,
      'pediatrician': e.pediatrician,
      'medications': e.medications,
      'contacts': e.contacts
          .map((c) => {'name': c.name, 'relation': c.relation, 'phone': c.phone})
          .toList(),
    };
  }

  void _emergencyFrom(Object? v) {
    if (v is! Map) return;
    final raw = v['contacts'];
    _emergency = EmergencyProfile(
      name: (v['name'] ?? '').toString(),
      dob: (v['dob'] ?? '').toString(),
      weight: (v['weight'] ?? '').toString(),
      bloodGroup: (v['bloodGroup'] ?? '').toString(),
      allergies: (v['allergies'] ?? '').toString(),
      pediatrician: (v['pediatrician'] ?? '').toString(),
      medications: (v['medications'] ?? '').toString(),
      contacts: raw is List
          ? raw.map((e) {
              final m = Map<String, dynamic>.from(e);
              return (
                name: (m['name'] ?? '').toString(),
                relation: (m['relation'] ?? '').toString(),
                phone: (m['phone'] ?? '').toString(),
              );
            }).toList()
          : const <EmergencyContact>[],
    );
  }
}

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

import 'package:flutter/material.dart';

import 'pp_attachments.dart';

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

class Medication {
  const Medication({
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
}

enum AllergyStatus { known, suspected, resolved }

class Allergy {
  const Allergy(this.name, this.status, this.severity, this.note);
  final String name;
  final AllergyStatus status;
  final String severity;
  final String note;
}

class ReportValue {
  const ReportValue(this.label, this.value, this.flag); // flag: 'normal'|'high'|'low'
  final String label;
  final String value;
  final String flag;
}

class MedicalReport {
  const MedicalReport({required this.name, required this.date, required this.summary, this.doctor, this.values = const [], this.attachments = const []});
  final String name;
  final String date;
  final String summary;
  final String? doctor;
  final List<ReportValue> values;
  final List<Attachment> attachments; // scanned images / PDFs of the report
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
}

class SymptomEntry {
  const SymptomEntry(this.name, this.date, this.note);
  final String name;
  final String date;
  final String note;
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
const String kGrowthInterpretation = 'Aarav is growing steadily and following his own healthy curve - weight, length and head size are all tracking together, which is exactly what we like to see.';

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
  'Aarav has grown steadily along his own curve for four months - weight, length and head size all tracking together.',
  'All vaccinations are up to date. The next, PCV dose 3, is due around 22 July.',
  'No allergies have been recorded so far.',
  'His only illnesses have been a mild seasonal cold and brief post-vaccine fever - both common and self-limiting.',
];

// ---- emergency profile ------------------------------------------------------
const EmergencyProfile kEmergency = EmergencyProfile(
  name: 'Aarav',
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

List<HealthEvent> healthTimelineSorted() {
  final l = [...kHealthTimeline]..sort((a, b) => b.sortKey.compareTo(a.sortKey));
  return l;
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

  final List<String> _questions = [...kSeedDoctorQuestions];
  final List<Medication> _medications = [...kMedications];
  final List<Prescription> _prescriptions = [...kPrescriptions];
  final List<Allergy> _allergies = [...kAllergies];
  final List<SymptomEntry> _symptoms = [...kSymptoms];
  final List<MedicalReport> _reports = [...kReports];
  // Parent-added doctor visits. The seeded visits still come from the health
  // timeline (read-only); these are ones the parent records themselves.
  final List<HealthEvent> _visits = [];

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
  bool get hasAnyEntry =>
      _growthEntered || _vaxEntered || _visits.isNotEmpty || _reports.isNotEmpty;

  void markGrowthEntered() {
    if (_growthEntered) return;
    _growthEntered = true;
    notifyListeners();
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
  }

  // ---- doctor-visit questions ----
  List<String> get questions => List.unmodifiable(_questions);
  void addQuestion(String q) {
    final t = q.trim();
    if (t.isEmpty) return;
    _questions.add(t);
    notifyListeners();
  }

  void removeQuestion(int i) {
    if (i >= 0 && i < _questions.length) {
      _questions.removeAt(i);
      notifyListeners();
    }
  }

  // ---- medications (also covers prescriptions) ----
  List<Medication> get medications => List.unmodifiable(_medications);
  void addMedication(Medication m) {
    _medications.insert(0, m);
    notifyListeners();
  }

  void updateMedication(int i, Medication m) {
    if (i >= 0 && i < _medications.length) {
      _medications[i] = m;
      notifyListeners();
    }
  }

  void removeMedication(int i) {
    if (i >= 0 && i < _medications.length) {
      _medications.removeAt(i);
      notifyListeners();
    }
  }

  // ---- prescriptions (the script itself; may carry image/PDF attachments) ----
  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);
  void addPrescription(Prescription p) {
    _prescriptions.insert(0, p);
    notifyListeners();
  }

  void updatePrescription(int i, Prescription p) {
    if (i >= 0 && i < _prescriptions.length) {
      _prescriptions[i] = p;
      notifyListeners();
    }
  }

  void removePrescription(int i) {
    if (i >= 0 && i < _prescriptions.length) {
      _prescriptions.removeAt(i);
      notifyListeners();
    }
  }

  // ---- allergies ----
  List<Allergy> get allergies => List.unmodifiable(_allergies);
  List<Allergy> get knownAllergies => _allergies.where((a) => a.status == AllergyStatus.known).toList();
  void addAllergy(Allergy a) {
    _allergies.insert(0, a);
    notifyListeners();
  }

  void updateAllergy(int i, Allergy a) {
    if (i >= 0 && i < _allergies.length) {
      _allergies[i] = a;
      notifyListeners();
    }
  }

  void removeAllergy(int i) {
    if (i >= 0 && i < _allergies.length) {
      _allergies.removeAt(i);
      notifyListeners();
    }
  }

  // ---- symptoms ----
  List<SymptomEntry> get symptoms => List.unmodifiable(_symptoms);
  void addSymptom(SymptomEntry s) {
    _symptoms.insert(0, s);
    notifyListeners();
  }

  void updateSymptom(int i, SymptomEntry s) {
    if (i >= 0 && i < _symptoms.length) {
      _symptoms[i] = s;
      notifyListeners();
    }
  }

  void removeSymptom(int i) {
    if (i >= 0 && i < _symptoms.length) {
      _symptoms.removeAt(i);
      notifyListeners();
    }
  }

  // ---- reports (manual records; may carry image/PDF attachments) ----
  List<MedicalReport> get reports => List.unmodifiable(_reports);
  void addReport(MedicalReport r) {
    _reports.insert(0, r);
    notifyListeners();
  }

  void updateReport(int i, MedicalReport r) {
    if (i >= 0 && i < _reports.length) {
      _reports[i] = r;
      notifyListeners();
    }
  }

  void removeReport(int i) {
    if (i >= 0 && i < _reports.length) {
      _reports.removeAt(i);
      notifyListeners();
    }
  }

  // ---- doctor visits (parent-added; the seeded ones stay in the timeline) ----
  List<HealthEvent> get visits => List.unmodifiable(_visits);
  void addVisit(HealthEvent v) {
    _visits.insert(0, v);
    notifyListeners();
  }

  void updateVisit(int i, HealthEvent v) {
    if (i >= 0 && i < _visits.length) {
      _visits[i] = v;
      notifyListeners();
    }
  }

  void removeVisit(int i) {
    if (i >= 0 && i < _visits.length) {
      _visits.removeAt(i);
      notifyListeners();
    }
  }

  // ---- emergency card (create / edit / delete) ----
  EmergencyProfile? _emergency = kEmergency;
  EmergencyProfile? get emergency => _emergency;
  void setEmergency(EmergencyProfile e) {
    _emergency = e;
    notifyListeners();
  }

  void clearEmergency() {
    _emergency = null;
    notifyListeners();
  }
}
